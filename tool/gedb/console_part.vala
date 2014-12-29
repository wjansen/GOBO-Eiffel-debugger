using Gtk;
using Posix;

public enum Log { GO, INFO, STOP }

public class ConsolePart : ScrolledWindow {

	private IOChannel in_channel;
	private IOChannel out_channel;
	private IOChannel err_channel;
	private TextBuffer buffer;
	private TextMark end_mark;
	private TextMark input_mark;
	private weak Searcher source;
	private StringBuilder in_line;
	private StringBuilder out_line;


	private void fill_tag_table(TextBuffer buf) {
		TextTag tag; 
		tag = buf.create_tag("go", 
							 "foreground", "#6cd306", "foreground-set", true, 
							 null);
		tag = buf.create_tag("info", 
							 "foreground", "yellow", "foreground-set", true, 
							 null);
		tag = buf.create_tag("stop", 
							 "foreground", "red", "foreground-set", true, 
							 null);
		tag = buf.create_tag("input", 
							 "foreground", "#83caff", "foreground-set", true, 
							 null);
		tag = buf.create_tag("error", 
							 "foreground", "#ed72dc", "foreground-set", true, 
							 null);
		tag.underline = Pango.Underline.SINGLE;
		tag = buf.create_tag("searched", 
							 "background", "#85593f", "background-set", true, 
							 null);
		tag = buf.create_tag("found", 
							 "background", "orange", "background-set", true, 
							 "foreground", "black", "foreground-set", true, 
							 null);
	}

	private void flush_out(IOStatus status) {
		TextIter end;
		buffer.get_iter_at_mark(out end, end_mark);
		if (status==IOStatus.NORMAL) 
			buffer.insert(ref end, out_line.str, -1); 
		else 
			buffer.insert_with_tags_by_name(end, out_line.str, -1, "error", null);
		out_line.erase();
		buffer.get_iter_at_mark(out end, end_mark);
		buffer.move_mark(input_mark, end);
		view.scroll_mark_onscreen(end_mark);
	}

	private bool do_input(Gdk.EventKey e, IOChannel ch) {
		TextIter left, right;
		TextMark insert;
		string line;
		uint code;
		uint l, r;
		if (e.type != Gdk.EventType.KEY_PRESS) return false;
		code = e.keyval;
		if ((e.state & Gdk.ModifierType.CONTROL_MASK)>0) {
			switch (code) {
			case 'f':
			case 'r':
				return source.handle_key(e, view);
			}
			return false;
		}
		if (source.search_state!=source.SearchMode.NO_SEARCH) 
			return source.handle_key(e, view);
//		end.backward_char();
//		view.scroll_to_iter(end, 0.0, false, 1.0, 0.0);
		if (code>'~')  {
			switch (code) {
			case Gdk.Key.Return:
			case Gdk.Key.KP_Enter:
				code = '\n';
				break;
			case Gdk.Key.Tab:
				code = '\t';
				break;
			case Gdk.Key.BackSpace:
				code = '\b';
				break;
			default:
				return false;
			}
		}
		lock (buffer) {
			buffer.get_iter_at_mark(out left, input_mark);
			l = left.get_offset();
			insert = buffer.get_insert();
			buffer.get_iter_at_mark(out right, insert);
			r = right.get_offset();
			if (r<l) {
				buffer.move_mark(insert, left);
				r = l;
			}
			if (code=='\b') {
				if (l<r)  buffer.backspace(right, true, true);
			} else {
				if (code=='\n') {
					size_t n;
					buffer.get_iter_at_mark(out right, end_mark);
					buffer.move_mark(insert, right);
					buffer.insert_at_cursor("\n", 1);
					buffer.get_iter_at_mark(out right, end_mark);
					buffer.get_iter_at_mark(out left, input_mark);
					buffer.move_mark(input_mark, right);
					line = buffer.get_text(left, right, true);
					try {
						ch.write_chars(line.to_utf8(), out n);
						ch.flush();
					} catch (IOError e) {						
						GLib.stderr.printf("%s\n", e.message);
					}
				} else {
					line = string.nfill(1, (char)code);
					buffer.insert_with_tags_by_name(right, line, 1, "input", null);
				}
			}
			return true;
		}
	}

	private bool do_output(IOChannel ch, IOCondition cond) {
		unichar uni;
		size_t n;
		IOStatus status;
		if (cond!=IOCondition.IN) return false;
		lock (buffer) {
			try {
				status = ch.read_unichar(out uni);
//				status = ch.read_line(out line, out n, null);
			} catch (Error e) {
				status = IOStatus.ERROR;
				flush_out(status);
			}
			if (status==IOStatus.NORMAL) {
				out_line.append_unichar(uni);
				if (uni=='\n') flush_out(status);
				return true;
			}
		}
		return false;
	}

	private bool do_focus(Widget w, Gdk.EventFocus ev) {
		if (ev.@in!=0) 
			view.override_background_color(0, active_bg);
		else
		view.override_background_color(0, inactive_bg);
		return false;
	}

	private Gdk.RGBA active_bg;
	private Gdk.RGBA inactive_bg;

	private ConsolePart.basic(TextBuffer tb) {
		buffer = tb;
		view = new TextView.with_buffer(buffer);
		add(view); 
		view.set_editable(false);
		Pango.FontDescription font = 
			Pango.FontDescription.from_string("Monospace 9");
		view.modify_font(font);
		active_bg.parse("#242c2c");
		// inactive_bg.parse("#2e3436");
		inactive_bg = active_bg;
		view.override_background_color(0, active_bg);
		Gdk.RGBA color = {0.0, 0.0, 0.0, 0.0};
		color.parse("#e4e7e7");
		view.override_color(0, color); 
		view.key_press_event.connect(
			(e) => { return do_input(e, out_channel); });
	}

	public ConsolePart() { 
		this.basic(new TextBuffer(null));
		IOCondition c;
		TextIter iter;
		fill_tag_table(buffer);
		buffer.get_start_iter(out iter);
		end_mark = buffer.create_mark("console", iter, false);
		input_mark = buffer.create_mark("input", iter, true);
		shadow_type = ShadowType.OUT;
		in_line = new StringBuilder();		
		out_line = new StringBuilder();		
		int in_id, out_id;
		int pfd[2];
		
		pipe(pfd);
		in_id = pfd[0];
		out_id = pfd[1];
		dup2(in_id, 0);
		close(in_id);
		out_channel = new IOChannel.unix_new(out_id);
		c = IOCondition.OUT;
//	to be activated when input is requested:
//		out_channel.add_watch(c, (ch,c) => { return false; }); 
		
		pipe(pfd);
		in_id = pfd[0];
		out_id = pfd[1];
		dup2(out_id, 1);
		close(out_id);
		in_channel = new IOChannel.unix_new(in_id);
		c = IOCondition.IN|IOCondition.HUP;
		in_channel.add_watch(c, (ch,c) => { return do_output(ch,c); });
/*
		pipe(pfd);
		in_id = pfd[0];
		out_id = pfd[1];
		dup2(out_id, 2);
		close(out_id);
		err_channel = new IOChannel.unix_new(in_id);
		c = IOCondition.IN|IOCondition.HUP;
		err_channel.add_watch(c, (ch,c) => { return do_output(ch,c); });
*/
	}

	public ConsolePart.as_separate(ConsolePart main) {
		this.basic(main.buffer);
		in_channel = main.in_channel;
		out_channel = main.out_channel;
		end_mark = main.end_mark;
		set_min_content_width(720);
		set_min_content_height(452);
	}
	
	public void init_input() {
		lock (buffer) { flush_out(IOStatus.NORMAL); }
		view.grab_focus();
	}

	public void put_log_info(string info, int type) {
		TextTag tag;
		TextMark insert;
		TextIter at;
		lock (buffer) {
			var tags = buffer.get_tag_table();
			switch (type) {
			case Log.GO:
				tag = tags.lookup("go");
				break;
			case Log.STOP:
				tag = tags.lookup("stop");
				break;
			default:
				tag = tags.lookup("info");
				break;
			}
			buffer.get_end_iter(out at);
			insert = buffer.get_insert();
			buffer.move_mark(insert, at);
			buffer.insert_with_tags(at, info, -1, tag, null);
			buffer.get_end_iter(out at);
			buffer.move_mark(end_mark, at);
			view.scroll_mark_onscreen(end_mark);
		}
	}

	public void clear() {
		lock (buffer) {
			buffer.set_text("");
		}		
	}

	public TextView view;

	public void set_searcher(Searcher s) { 
		source = s; 
		s.prepare_client(view);
	}

	public signal void watch_input();
}
