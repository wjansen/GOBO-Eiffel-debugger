using Gtk;
using Posix;

public enum Log { GO, INFO, STOP }

public class ConsolePart : ScrolledWindow {

	private IOChannel in_channel;
	private IOChannel out_channel;
	private IOChannel err_channel;
	private TextView view;
	private TextBuffer buffer;
	private TextMark end_mark;

	private void fill_tag_table() {
		TextTag tag; 
		tag = buffer.create_tag("go", "foreground", "green",
								"foreground-set", true, null);
		tag = buffer.create_tag("info", "foreground", "yellow", 
								"foreground-set", true, null);
		tag = buffer.create_tag("stop", "foreground", "red", 
								"foreground-set", true, null);
		tag = buffer.create_tag("input", "foreground", "#83caff",
								"foreground-set", true, null);
		tag = buffer.create_tag("error", "foreground", "#ed72dc",
								"foreground-set", true, null);
		tag.underline = Pango.Underline.SINGLE;
	}

	private bool do_input(Gdk.EventKey e, IOChannel ch) {
		TextMark insert;
		TextIter left, right;
		string line;
		uint code;
		uint l, r;
		if (e.type != Gdk.EventType.KEY_PRESS) return false;
		if (e.is_modifier>0 && (e.state & Gdk.ModifierType.CONTROL_MASK)>0)
			return false;
		TextIter end;
		view.buffer.get_end_iter(out end);
		end.backward_char();
		view.scroll_to_iter(end, 0.0, false, 1.0, 0.0);
		code = e.keyval;
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
			buffer.get_iter_at_mark(out left, end_mark);
			l = left.get_offset();
			insert = buffer.get_insert();
			buffer.get_iter_at_mark(out right, insert);
			r = right.get_offset();
			if (r<l) {
				right.assign(left);
				buffer.move_mark(insert, right);
				r = l;
			}
			if (code=='\b') {
				if (l<r)  buffer.backspace(right, true, true);
			} else {
				if (code=='\n') {
					size_t n;
					buffer.get_end_iter(out right);
					buffer.place_cursor(right);
					buffer.insert_at_cursor("\n", 1);
					buffer.get_iter_at_mark(out right, insert);
					buffer.get_iter_at_mark(out left, end_mark);
					line = buffer.get_text(left, right, true);
					try {
						ch.write_chars(line.to_utf8(), out n);
						ch.flush();
					} catch (IOError e) {						
						GLib.stderr.printf("%s\n", e.message);
					}
				} else {
					line = string.nfill(1, (char)code);
					buffer.get_iter_at_mark(out left, insert);
					buffer.insert_with_tags_by_name(left, line, 1, "input", null);
				}
			}
			return true;
		}
	}

	private bool do_output(IOChannel ch, IOCondition cond) {
		TextIter start, end;
		unichar uni;
		var chars = new char[80];
		size_t n;
		IOStatus status;
		if (cond!=IOCondition.IN) return false;
		lock (buffer) {
			buffer.get_end_iter(out end);
			buffer.place_cursor(end);
			try {
				status = ch.read_unichar(out uni);
			} catch (Error e) {
				status = IOStatus.ERROR;
			}
			if (status==IOStatus.NORMAL) {
				buffer.insert_at_cursor(uni.to_string(), -1); 
				buffer.get_end_iter(out end);
				start = end;
				start.backward_char();
				buffer.move_mark(end_mark, end); 
				if (ch==err_channel) 
					buffer.apply_tag_by_name("error", start, end);
				view.scroll_mark_onscreen(end_mark);
				return true;
			}
		}
		return false;
	}

	private bool do_enter(Widget w, Gdk.EventCrossing ev) {
		w.has_focus = true;
		return false;
	}

	private bool do_leave(Widget w, Gdk.EventCrossing ev) {
		w.has_focus = false;
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
		fill_tag_table();
		buffer.get_start_iter(out iter);
		end_mark = buffer.create_mark("console", iter, true);
		shadow_type = ShadowType.OUT;
		
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
		view.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;
		view.enter_notify_event.connect(do_enter);
		view.leave_notify_event.connect(do_leave);
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
		lock (buffer) { view.scroll_mark_onscreen(end_mark); }
		view.grab_focus();
	}

	public void put_log_info(string info, int type) {
		TextTag tag;
		TextMark insert;
		TextIter at;
		lock (buffer) {
			TextTagTable tags = buffer.get_tag_table();
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

	public signal void watch_input();
}
