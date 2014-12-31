using Gtk;
using Gedb;

internal ConsolePart the_console;

private const string regexp_string = "Regular expression to search";

public class SourcePart : Box, AbstractPart, ClassPosition, Searcher { 

	private Entry search;
	private ToggleButton precise;
	private string hot_needle;
	private string strong_needle;
	private bool is_hot;
	private bool forward = true;

	internal SourceView feature_view;
	internal Label feature_class;
	internal Label feature_lines;

	internal Debuggee? dg;

	internal RunPart? run;
	internal BreakPart? brk;
	internal StackPart stack;
	internal DataPart data;
	internal ConsolePart? console;
	internal ConsolePart? separate_console;
	internal Window? console_window;
	internal Notebook pages;
	internal Status status;
	internal Window feature_window;
	internal ListStore class_list;
	internal TextTagTable tags;
	internal Pango.FontDescription? font;
	internal int mono_width;
	internal Entry go_to;
	internal Entry plus;
	internal bool active; 

	private bool _wrap_mode;
	public bool wrap_mode { 
		get { return _wrap_mode; }
		set {
			_wrap_mode = value;
			WrapMode mode = _wrap_mode ? 
				WrapMode.WORD_CHAR : WrapMode.NONE;
			var src = act_source();
			src.text_view.wrap_mode = mode;
			if (feature_view!=null) 
				feature_view.wrap_mode = mode;
		}
	}

	public bool value_as_tooltip { get; set; }

	private int _tab_width = 3;
	public int tab_width {
		get { return _tab_width; }
		set {
			_tab_width = value;
			var src = act_source();
			if (src!=null) src.text_view.tab_width = value;
			if (feature_view!=null) 
				feature_view.tab_width = value;
		}
	}

	private void fill_tag_table() {
		TextTag tag;
		tags = new TextTagTable();
		tag = new TextTag("mono"); 
		tag.foreground = "black"; 
		tag.foreground_set = true;
		
		tags.@add(tag);
		tag = new TextTag("keyword");
		tag.weight = Pango.Weight.BOLD;
		tag.weight_set = true;
		tags.@add(tag);
		tag = new TextTag("dot"); 
		tag.weight = 1000;
		tag.weight_set = true;
		tags.@add(tag);
		tag = new TextTag("comment");
		tag.foreground = "#a0a0a0"; 
		tag.foreground_set = true; 
		tags.@add(tag);
		tag = new TextTag("ident-or-op");
		tags.@add(tag);
		tag = new TextTag("literal");
		tag.foreground = "#6a1802";
		tag.foreground_set = true; 
		tags.@add(tag);
		tag = new TextTag("actual-line");
		tag.background = "#e0ffc4";	
		tag.background_set = true; 
		tags.@add(tag);
		tag = new TextTag("listable");
		tag.background = "#cbe1ff";
		tag.background_set = true;
		tags.@add(tag);
		tag = new TextTag("computable");
		tag.background = "#fcc3f7";
		tag.background_set = true; 
		tags.@add(tag);
		tag = new TextTag("paren-mark");
		tags.@add(tag);
		tag = new TextTag("paren");
		tag.foreground = "magenta";
		tag.foreground_set = true; 
		tag.weight = 1000;
		tag.weight_set = true;
		tags.@add(tag);
		tag = new TextTag("actual");
		tag.background = "#25b221"; 
		tag.background_set = true; 
		tag.foreground = "white";
		tag.foreground_set = true; 
		tags.@add(tag);
		tag = new TextTag("stoppable"); 
		tag.underline = Pango.Underline.DOUBLE;
		tag.underline_set = true;
		tags.@add(tag);
		tag = new TextTag("break");
		tag.background = "#ec0000";
		tag.background_set = true; 
		tag.foreground = "white";
		tag.foreground_set = true; 
		tags.@add(tag);
		tag = new TextTag("searched");
		tag.background = "#fff670";
		tag.foreground_set = true; 
		tags.@add(tag);
		tag = new TextTag("found");
		tag.background = "#ffa500";
		tag.background_set = true; 
		tags.@add(tag);
	}
	
	private static bool do_filter_class(EntryCompletion compl, 
										string key, TreeIter iter) {
		TreeModel model = compl.get_model();
		GLib.Regex regex;
		GLib.MatchInfo info;
		string name=null;
		bool ok;
		try {
			regex = new GLib.Regex(key, GLib.RegexCompileFlags.CASELESS, 0);
			model.@get(iter, ClassEnum.CLASS_NAME, out name, -1);
			ok = regex.match(name);
		} catch (RegexError e) {
			print("invalid REGEX\n");
			return false;
		} 
		return ok;
	}
  
	private bool do_select_class(TreeModel model, TreeIter iter, Entry e) {
		uint id = 0;
		model.@get(iter, ClassEnum.CLASS_IDENT, out id, -1);
		do_actual(null, id, 257);
		e.set_text("");
		return true;
	}

	internal void do_actual(StackFrame* f, uint id, uint pos) {
		if (dg==null) return;
 		ClassText* cls = null;
		ClassText* cls_new = dg.rts.class_at(id);
		StackFrame* sf;
		FullSource? src = null;
		int i;
		bool as_source = console==null ||
			pages.page_num(console)!=pages.get_current_page();
		for (i=pages.get_n_pages(); i-->0;) {
			src = pages.get_nth_page(i) as FullSource;
			if (src==null) continue;
			cls = src.current_class();
			if (cls==null) continue;
			for (sf=f; sf!=null; sf=sf.caller) {
				if (sf.class_id==cls.ident) {
					src.highlight_actual(sf, sf.pos);
					break;
				}
			}
			if (sf==null) src.highlight_actual(null, 0);
		}
		for (i=pages.get_n_pages(); i-->0;) {
			src = pages.get_nth_page(i) as FullSource;
			if (src==null) continue;
			cls = src.current_class();
			if (cls==null) continue;
			if (cls.ident==id) break;
			Name* nm = (Name*)cls;
			cls = null;
			if (nm.is_less(cls_new._name)) break;
		}
		if (cls==null) {
			++i;
			cls = dg.rts.class_at(id);
			src = new FullSource(dg, this);
			src.show_main_class(cls);
			var name = cls._name.fast_name;
			var box = new Box(Orientation.HORIZONTAL,5);
			var label = new Label(name);
			if (!cls.is_debug_enabled()) 
				label.set_markup("<s>"+name+"</s>");
			box.pack_start(label, true ,true, 0);
			var button = new Button();
			button.set_relief(ReliefStyle.NONE);
			button.set_image(new Image.from_stock(Stock.CLOSE, IconSize.MENU));
			button.clicked.connect((b) => {
					int ip = pages.page_num(src);
					if (ip==pages.page) return;
					pages.remove_page(ip);
				});
			box.pack_end(button);
			box.show_all();
			var menu = new Label(name);
			menu.xalign = 0.0F;
			pages.insert_page_menu(src, box, menu, i);
			src.show_all();
			as_source = true;
			if (f!=null) src.highlight_actual(f, pos);
		} else {
			src.show_line((int)pos/256-1);
		}
		pages.set_current_page(i);
	}

	private void do_switch(FullSource? src) {
		if (src==null) return;	// the `Console' case
		src.set_frame(stack);
	}

	private void show_console() {
		if (console==null) return;
		if (the_console==separate_console) return;
		Widget page = pages.get_nth_page(-1);
		page.hide();
		var top = separate_console.get_toplevel();
		top.show_all();
		the_console = separate_console;
	}

	private void close_console(Widget top) {
		if (console==null || console==the_console) return;
		Widget w = top;
		for (Widget p=top; p!=null; p=p.parent) w = p;
		w.hide();
		Widget page = pages.get_nth_page(-1);
		page.show();
		the_console = console;
	}

	private void do_to_main(Widget top) requires (dg!=null) {
		top.hide();
		string c_name = feature_class.get_text();
		ClassText* cls = dg.rts.class_by_name(c_name);
		if (cls==null) return;
		string[] l_names = feature_lines.get_text().split(" -");
		int first = int.parse(l_names[0]);
		int last = int.parse(l_names[1]);
		do_actual(null, cls.ident, (uint)256*first);
	}

	public int search_state { get; set; } 

	internal void prepare_client(TextView view) {
		TextIter iter;
 		var buf = view.buffer;
		buf.get_iter_at_mark(out iter, buf.get_insert());
		
		view.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;
		view.enter_notify_event.connect(do_enter);
		view.leave_notify_event.connect(do_leave);
		view.focus_in_event.connect(do_focus);		
		view.focus_out_event.connect(do_focus);	
	}

	public bool handle_key(Gdk.EventKey ev, TextView view) {
		if (ev.type != Gdk.EventType.KEY_PRESS) return false;
		ClassText* cls;
		Breakpoint bp;
		var text = view.buffer;
		var src = text as SourceBuffer;
		uint code = ev.keyval;
		string value;
		uint l, p;
		if ((ev.state & Gdk.ModifierType.CONTROL_MASK) > 0) {
			switch (code) {
			case 'f':
				adjust_up_down();
				precise.set_active(false);
				adjust_mark(view);
				switch (search_state) {
				case SearchMode.NO_SEARCH:
				case SearchMode.GO_TO:
					search_state = SearchMode.INIT_SEARCH;
					break;
				default:
					if (hot_needle.length>0) {
						search_state = SearchMode.SEARCHING;
						forward = true;
						adjust_up_down();
						simple_search(view, true);
					}
					break;
				}
				break;
			case 'r':
				if (search_state==SearchMode.SEARCHING) {
					forward = false;
					adjust_up_down();
					simple_search(view, true);
				}
				break;
			default:
				return false;
			}
		} else if (code==Gdk.Key.Escape) {
			end_search(view, true);
		} else if (ev.is_modifier==0) {
			string str="";
			switch (search_state) {
			case SearchMode.INIT_SEARCH:
			case SearchMode.SEARCHING:
				if (code==Gdk.Key.BackSpace) { 
					l = hot_needle.length;
					if (l>0) {
						hot_needle = hot_needle.substring(0, l-1);
						forward = false;
						adjust_up_down();
						simple_search(view, false);
					}
				} else if (code<' ' || code>'~') {
					end_search(view, code==Gdk.Key.Escape);
					return false;
				} else {
					if (search_state==SearchMode.INIT_SEARCH) hot_needle = "";
					hot_needle = "%s%c".printf(hot_needle, (int)code);
					search_state = SearchMode.SEARCHING;
					forward = true;
					adjust_up_down();
					simple_search(view, false);
				}
				break;
			default:
				end_search(view);
				return false;
				break;
			}
		}
		return true;
	}
	
	private bool do_focus(Widget w, Gdk.EventFocus ev) {
		var scroll = w.get_parent() as ScrolledWindow;
		if (scroll==null) return false;
		var window = scroll.get_window();
		scroll.shadow_type = ev.@in!=0 ? ShadowType.OUT : ShadowType.NONE;
		return false;
	}

	private bool do_enter(Widget w, Gdk.EventCrossing ev) {
		w.has_focus = true;
		search.placeholder_text = "Simple search string";
		search.set_text("");
		return false;
	}

	private bool do_leave(Widget w, Gdk.EventCrossing ev) {
		w.has_focus = false;
		search.placeholder_text = regexp_string;
		search.set_text(strong_needle);
		return false;
	}

	private void do_search() {
		var e = pattern_history.get_child() as Entry;
		TreeIter iter;
		TreePath path = null;
		string str = e.get_text();
		bool same = str==strong_needle;
		strong_needle = str;
		pattern_history.add_item(strong_needle);
		var full = act_source();
		if (full!=null)
			complex_expression(full.text_view, same);
		else if (the_console!=separate_console)
			complex_expression(the_console.view, same);
		search.override_color(StateFlags.NORMAL, 
							  found ? found_bg : not_found_bg);
	}
	
	private void do_search_icon(EntryIconPosition pos) {
		if (pos==EntryIconPosition.PRIMARY) {
			forward = !forward;
		} else {
			strong_needle = "";
			search.set_text(strong_needle);
			search.grab_focus(); 
		}
		adjust_up_down();
	}

	internal void adjust_up_down() {
		string up_down = forward ? Stock.GO_DOWN : Stock.GO_UP;
		search.set_icon_from_stock(EntryIconPosition.PRIMARY, up_down);
	}

	internal void do_toggle(ToggleButton toggle) {
		bool act = toggle.get_active();
		toggle.set_label(act ? "precise" : "no cases");
	}

	private void do_goto(Entry entry) {
		var full = act_source();
		if (full!=null) full.do_goto(entry);
	}

	internal void end_search(TextView view, bool clear=false) {
		if (clear) {
			TextIter start, end;
			var text = view.buffer;
			text.get_bounds(out start, out end);
			text.remove_tag_by_name("searched", start, end);
			text.remove_tag_by_name("found", start, end);
		}
		search_state = SearchMode.NO_SEARCH; 
		search.placeholder_text = regexp_string;
		search.set_text(strong_needle);
	}

	private void adjust_mark(TextView view) {
		var text = view.get_buffer();
		var insert = text.get_insert();
		var mark = text.get_selection_bound();
		TextIter at;
		text.get_iter_at_mark(out at, mark);
		text.move_mark(insert, at);
	}

	private Gdk.RGBA? found_bg;
	private Gdk.RGBA not_found_bg;
	private bool found;

	private void simple_search(TextView view, bool same) {
		var text = view.get_buffer();
		var insert = text.get_insert();
		TextIter at, start, end, first, last;
		search.override_color(StateFlags.NORMAL, found_bg);
		search.set_text(hot_needle);
		text.get_bounds(out start, out end);
		same &= is_hot;
		is_hot = true;
		if (same && !found) text.move_mark(insert, forward ? start : end);
 		text.get_iter_at_mark(out at, insert);
		if (forward) {
			if (same) at.forward_chars(1);
			found = at.forward_search(hot_needle,
									  TextSearchFlags.CASE_INSENSITIVE,
									  out first, out last, null);
		} else {
			if (same) at.backward_chars(1);
			found = at.backward_search(hot_needle,
									   TextSearchFlags.CASE_INSENSITIVE, 
									   out last, out first, null);
		}
		if (found) {
			text.remove_tag_by_name("found", start, end);
			if (!same) {
				text.remove_tag_by_name("searched", start, end);
				int n = text.get_line_count();
				bool ok;
				for (int i=0; i<n; ++i) {
					text.get_iter_at_line(out start, i);
					ok = start.forward_search(hot_needle,
											  TextSearchFlags.CASE_INSENSITIVE,
											  out start, out end, null);
					if (ok) text.apply_tag_by_name("searched", start, end);
				}
			} 
			text.apply_tag_by_name("found", first, last);
			text.move_mark(insert, first);
			text.place_cursor(forward ? first : last);
			view.scroll_to_mark(insert, 0.05, false, 0.0, 0.0);
		} else {
			search.override_color(StateFlags.NORMAL, not_found_bg);
		}
	}
	
	internal void complex_expression(TextView view, bool same) {
		var text = view.get_buffer();
		var insert = text.get_insert();
		var f_tag = text.tag_table.lookup("found");
		var s_tag = text.tag_table.lookup("searched");
		TextIter at, start, end;
		GLib.MatchInfo match = null;
		string all;
		text.get_bounds(out start, out end);
		same &= !is_hot;
		is_hot = false;
		if (same && !found) text.move_mark(insert, forward ? start : end);
		text.get_iter_at_mark(out at, insert);
		int now = at.get_offset();
		if (same) now += forward ? 1 : -1;
		all = text.get_text(start, end, false);
		try {
			GLib.RegexCompileFlags flags = (GLib.RegexCompileFlags)0;
			if (precise.active) flags |= GLib.RegexCompileFlags.CASELESS;
			var regex = new GLib.Regex(strong_needle, flags, 0);
			found = regex.match(all, 0, out match);
		} catch (GLib.Error e) {
			found = false;
		}
		int left = -1, right = -1;
		if (found) {
			found = false;
			text.remove_tag(f_tag, start, end);
			text.remove_tag(s_tag, start, end);
			int l, r;
			for (bool ok=true; ok; ok=match.next()) {
				match.fetch_pos(0, out l, out r);
				text.get_iter_at_offset(out start, l);
				text.get_iter_at_offset(out end, r);
				text.apply_tag(s_tag, start, end); 
				if (!found) {
					if (forward && l>=now) {
						left = l;
						right = r;
						found = true;
					} else if (!forward && r>=now) {
						found = true;
					} else {
						left = l;
						right = r;
					}
				}
			}
		}
		if (found) {
			text.get_iter_at_offset(out start, left);
			text.get_iter_at_offset(out end, right);
			text.apply_tag(f_tag, start, end); 
			if (forward) {
				text.place_cursor(start);
				text.move_mark(insert, start);
			} else {
				text.place_cursor(end);
				text.move_mark(insert, end);
			}
			view.scroll_to_mark(insert, 0.05, false, 0.0, 0.0);	
		} else {
			search.override_color(StateFlags.NORMAL, not_found_bg);
		}
	}

	private void do_set_sensitive(bool is_running) { active = !is_running; }

	private Notebook new_pages() {
		var pages = new Notebook();
		pages.enable_popup = true;
		pages.scrollable = true;
		plus = new Entry();
		plus.width_chars = 12;
		plus.placeholder_text = "More classes";
		var compl = new EntryCompletion();
		plus.set_completion(compl);
		compl.set_text_column(ClassEnum.CLASS_NAME);
		compl.set_match_func(do_filter_class);
		compl.match_selected.connect(
			(c,m,i) => { return do_select_class(m,i,plus); });
		pages.set_action_widget(plus, PackType.START);
		plus.show();

		if (console!=null) {
			var cb = new Box(Orientation.HORIZONTAL,5);
			var label = new Label("Console");
			label.set_tooltip_text("Show standard I/O instead of class text.");
			cb.pack_start(label, true ,true, 0);
			var button = new Button();
			button.set_relief(ReliefStyle.NONE);
			var icon = new Image.from_stock(Stock.PASTE, IconSize.MENU);
			button.set_image(icon);
			icon.tooltip_text = "Show separate console window.";
			button.clicked.connect((b) => { show_console(); });
			cb.pack_end(button);
			cb.show_all();
			var menu = new Label("Console");
			menu.xalign = 0.0F;
			pages.append_page_menu(console, cb, menu);
			console_window = new Window();
			console_window.deletable = false;
			var sb = new Box(Orientation.VERTICAL, 0);
			console_window.@add(sb);
			console_window.delete_event.connect((e) => 
				{ close_console(separate_console); return true; });
			separate_console = new ConsolePart.as_separate(console);
			sb.pack_start(separate_console, true, true, 0);
			var buttons = new ButtonBox(Orientation.HORIZONTAL);
			sb.pack_end(buttons);
			buttons.set_layout(ButtonBoxStyle.END);
			buttons.set_spacing(6);
			button = new Button.with_label("Close");
			buttons.@add(button);
			button.set_tooltip_text(
"""Close window and move contents
back to source window.""");
			button.has_tooltip = true;
			button.clicked.connect(() => { close_console(separate_console); });
			separate_console.set_searcher(this);
		}
		return pages;
	}

	private Window new_feature_window() {
		var w = new Window();
		var box = new Box(Orientation.VERTICAL, 3);
		w.@add(box);
		Grid grid = new Grid();
		box.pack_start(grid, false, false, 0);
		var label = new Label("Class ");
		grid.attach(label, 0, 0, 1, 1);
		feature_class = new Label("");
		grid.attach(feature_class, 1, 0, 1, 1);
		feature_class.halign = Align.START;
		label = new Label("Lines ");
  		grid.attach(label, 0, 1, 1, 1);
		feature_lines = new Label("");
  		grid.attach(feature_lines, 1, 1, 1, 1);
		feature_lines.halign = Align.START;
		var feature_source = new SingleSource(this);
		feature_view = feature_source.text_view;
		box.pack_start(feature_source, true, true, 3);
		
		var buttons = new ButtonBox(Orientation.HORIZONTAL);
		box.pack_end(buttons, false, false, 3);
		buttons.set_layout(ButtonBoxStyle.END);
		Button to_main = new Button.with_label("To source");
		buttons.@add(to_main);
		to_main.set_tooltip_text(
"""Show class and feature in main window 
and close feature window.""");
		to_main.has_tooltip = true;
		to_main.clicked.connect(() => { do_to_main(w); });
		var button = new Button.with_label("Close");
		buttons.@add(button);
		button.set_tooltip_text("Button window");
		button.has_tooltip = true;
		button.clicked.connect(() => { w.hide(); });
		return w;
	}

	public SourcePart(BreakPart? b, RunPart? r, DataPart d, ConsolePart? c, 
					  StackPart s, Status status) {
		run = r;
		brk = b;
		stack = s;
		data = d;
		console = c;
		the_console = console;
		this.status = status;
		hot_needle = "";
		strong_needle = "";

		orientation = Orientation.VERTICAL;
		if (font==null) 
			font = Pango.FontDescription.from_string("Inconsolata 11");
		if (font==null) 
			font = Pango.FontDescription.from_string("Andale Mono 10");
		if (font==null)
			font = Pango.FontDescription.from_string("FreeMono 11");
		if (font==null) 
			font = Pango.FontDescription.from_string("Monospace 10");
		mono_width = font!=null ? 7 : 9;
		fill_tag_table();

		ButtonBox buttons;
		Button button;
		Label label;
		
		pages = new_pages();
		pack_start(pages, true, true, 0);

		var entry = new Entry();
		Box box = new Box(Orientation.HORIZONTAL, 3);
		pack_end(box, false, false, 0);

		Box search_box = new Box(Orientation.HORIZONTAL, 3);
		box.pack_start(search_box, true, true, 0);
		pattern_history = new HistoryBox(null);
		search = pattern_history.get_child() as Entry;
		search_box.pack_start(pattern_history, true, true, 0);
		search.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.FIND);
		search.set_icon_from_stock(EntryIconPosition.PRIMARY, Stock.GO_DOWN);
		search.icon_release.connect(do_search_icon);
		search.placeholder_text = regexp_string;
		search.set_tooltip_markup(
"""Pattern to search, may be a regular expression.
Shortcut: press <span><i>&lt;Control&gt;f</i></span>  in the text field to start
fast incremental search (but no regular expressions).""");
		search.has_tooltip = true;
		not_found_bg = new Gdk.RGBA();
		not_found_bg.parse("#ef2929");

		precise = new ToggleButton.with_label("precise");
		search_box.pack_start(precise, false, false, 3);
		precise.active = false;
		precise.set_tooltip_text("Case sensitive search?");
		precise.has_tooltip = true;

		go_to = new Entry();
		go_to.set_width_chars(12);
		go_to.placeholder_text = "Line number";
		go_to.set_icon_from_stock(EntryIconPosition.PRIMARY, Stock.JUMP_TO);
		go_to.set_tooltip_markup(
"""Make text around a specific line visible.
Shortcut: <span><i>&lt;CTRL&gt;L</i></span>""");
		go_to.has_tooltip = true;
		box.pack_end(go_to, false, false, 0);
		Separator sep = new Separator(Orientation.VERTICAL);
		box.pack_end(sep, false, false, 6);

		feature_window = new_feature_window();

		search.activate.connect(() => { do_search(); });
		precise.clicked.connect(() => { do_toggle(precise); });
		go_to.activate.connect(() => { do_goto(go_to); });
		stack.level_selected.connect((s,f,i,p) => { do_actual(f,i,p); });
		pages.switch_page.connect((s,w,i) => { do_switch(w as FullSource); });

		the_source = this;
	}

	public HistoryBox pattern_history;

	public FullSource? act_source() { 
		int i = pages.get_current_page(); 
		return pages.get_nth_page(i) as FullSource;
	}
	
	public void switch_to_top() {
		StackFrame* f = stack.top;
		if (f==null) return;
		FullSource src=null;
		uint cid = f.class_id;
		int i;
		for (i=pages.get_n_pages(); i-->0; ) {
			src = pages.get_nth_page(i) as FullSource;
			if (src==null) continue;	// may be the ConsolePart
			if (src.cid==cid) {
				pages.set_current_page(i);
				return;
			}
			src = null;
		}
	}

	public void get_position(out uint cid, out uint pos) {
		var src = act_source();
		if (src!=null) {
			cid = src.cid; 
			pos = src.insert_position(true);
		} else {
			cid = 0; 
			pos = 0;
		}
	}

	public void init_input() {
		GLib.Idle.@add(() => { 
				if (the_console==console) pages.page = -1; 
				the_console.init_input();  
				return false; 
			});
	}

	public void set_debuggee(Debuggee? dg) { 
		this.dg = dg;
		for (int n=pages.get_n_pages()-1; n-->0;) pages.remove_page(n);
		set_sensitive(dg!=null);
		if (dg!=null) {
			class_list = new_class_list(dg.rts);
			plus.completion.set_model(class_list);
			feature_window.get_toplevel().hide();
			feature_window.title = compose_title("Feature text", dg.rts);
			if (console_window!=null)
				console_window.set_title(compose_title("Console", dg.rts));
			dg.notify["is-running"].connect(
				(g,p) => { do_set_sensitive(dg.is_running); });
		} 
	} 

} /* class SourcePart */

internal SourcePart the_source;

public static void gedb_init_stdin() { the_source.init_input(); }

public class SingleSource : Box {
	
	protected SourcePart source;
	internal SourceView text_view;
	protected Gee.HashMap<int,int> parenths;

	private void do_scanned(Gedb.Scanner scanner, string match, 
							SourceBuffer buf, int first, int last,
							Gee.List<int> lparen) {
		var ln = scanner.line_count+1;
		if (ln<first || ln>last) return;
		TextIter end;
		int lpos, rpos;
		int code = scanner.in_note 
			? ScannerParser.TokenCode.COMMENT 
			: scanner.token_code;
		buf.get_end_iter(out end);
		switch (code) {
		case ScannerParser.TokenCode.KEYWORD:
		case ScannerParser.TokenCode.OPERATOR:
		case ScannerParser.TokenCode.ASSIGN:
			buf.insert_with_tags_by_name(end, match, -1, "keyword", null);
			break;
		case ScannerParser.TokenCode.INTEGER:
		case ScannerParser.TokenCode.REAL:
		case ScannerParser.TokenCode.CHARACTER:
		case ScannerParser.TokenCode.STRING:
		case ScannerParser.TokenCode.MANIFEST:
			buf.insert_with_tags_by_name(end, match, -1, "literal", null);
			break;
		case ScannerParser.TokenCode.DOT:
			buf.insert_with_tags_by_name(end, match, -1, "dot", null);
			break;
		case ScannerParser.TokenCode.COMMENT:
			buf.insert_with_tags_by_name(end, match, -1, "comment", null);
			break;
		case ScannerParser.TokenCode.LEFT:
			lpos = end.get_offset();
			lparen.@add(lpos);
			buf.insert_with_tags_by_name(end, match, -1, "paren-mark", null);
			break;
		case ScannerParser.TokenCode.RIGHT:
			rpos = end.get_offset();
			lpos = lparen.last();
			lparen.remove_at(lparen.size-1);
			parenths.@set(rpos, lpos);
			parenths.@set(lpos, rpos);
			buf.insert_with_tags_by_name(end, match, -1, "paren-mark");
			break;
		default:
			buf.insert_at_cursor(match, -1);
			break;
		}
	}

	protected void show_class(SourceBuffer buf, ClassText* cls, 
							int first=1, int last=int.MAX) {
		// lines `first', `last' are included
		TextIter iter;
		var fs = FileStream.open(cls.path, "r");
		buf.set_text("");
		var lp = new Gee.ArrayList<int>();
		var scanner = new Gedb.Scanner();
		scanner.scanned.connect(
			(s,m) => { do_scanned(s,m,buf,first,last,lp); });
		scanner.add_stream(fs);
	}
	
	public uint cid { get; protected set; }

	public SingleSource(SourcePart s) {
		SourceBuffer text_buf;
		TextIter iter;
		Gdk.RGBA color;

		source = s;

		orientation = Orientation.VERTICAL;
		
		text_buf = new SourceBuffer(s.tags);
		text_buf.highlight_matching_brackets = false;

		text_view = new SourceView.with_buffer(text_buf);
		text_view.editable = false;
		text_view.cursor_visible = false;
		text_view.show_line_numbers = false;
		text_view.show_line_marks = false;
		text_view.show_right_margin = false;
		text_view.highlight_current_line = false;
		text_view.wrap_mode = source.wrap_mode ? 
			WrapMode.WORD_CHAR : WrapMode.NONE;
		text_view.tab_width = source.tab_width;
		if (s.font!=null) text_view.override_font(s.font);
		color = new Gdk.RGBA();
		color.parse("white");
		text_view.override_background_color(StateFlags.NORMAL, color);

		ScrolledWindow tbox = new ScrolledWindow(null, null);
		tbox.@add(text_view);
		tbox.set_min_content_width(86*s.mono_width);
#if HIDDEN_BP
#else
		tbox.set_min_content_height(320);
#endif
		tbox.shadow_type = ShadowType.OUT;
		pack_start(tbox);

		parenths = new Gee.HashMap<int,int>();
	}

	public ClassText* current_class() { 
		return source.dg!=null ? source.dg.rts.class_at(cid) : null; }

} /* class SingleSource */

public class FullSource : SingleSource {
	
	private Gee.HashMap<int,Qualified?> identifier_table;
	private Gee.HashSet<string> predefs;

	private void highlight_feature(FeatureText* ft, Classified v) {
		var text = text_view.get_buffer() as SourceBuffer;
		var tag = text.tag_table.lookup("ident-or-op");
		TextIter start, end;
		string name = v.name;
		if (predefs.contains(name.down())) return;
		int pos = (int)ft.first_pos;
		if (pos==0) return;
		int ln=pos/256-1, cn=pos%256-1;
		text.get_start_iter(out start);
		start.set_line(ln);
		start.forward_chars(cn+v.at);
		end = start;
		end.forward_chars(name=="[]" ? 1 : name.length);
		ln = start.get_line()+1;
		cn = start.get_line_offset()+1;
		text.apply_tag(tag, start, end);
		identifier_table.@set(256*ln+cn, v.q);
	}

	private BreakPart? brk;
	private DataPart data;
	private Status status;

	private StackFrame* frame;
	private uint pos;
	private uint actual_pos;
	private int other_paren = -1;
	private SourceMark? actual_line; 

	public bool show_line(int ln) {
		var text = text_view.get_buffer() as SourceBuffer;
		TextIter at;		
		text.get_iter_at_line(out at, ln);
		text.place_cursor(at);
		var mark = text.get_insert();
		text_view.scroll_to_mark(mark, 0.05, false, 0.0, 0.0);
		text_view.forward_display_line(at);
		return false;
	}

	private void show_feature(SourcePart s) {
		var buf = text_view.get_buffer() as SourceBuffer;
		var tag = buf.tag_table.lookup("listable");
		bool all;
		TextIter start, end;
		string word, name="";
		uint i, j;
		int pos;
		buf.get_bounds(out start, out end);
		start.forward_to_tag_toggle(tag);
		end.assign(start);
		end.forward_to_tag_toggle(tag);
		word = buf.get_text(start, end, false);
		pos = 256*(start.get_line()+1) + (start.get_line_offset()+1);
		Qualified? q = identifier_table.@get(pos);
		if (q==null) return;
		ClassText* cls = q.cls;
		FeatureText* ft = q.ft;
		RoutineText* rt = null;
		if (cls==null && ft==null) return;
		if (ft==null) {
			s.do_actual(null, cls.ident, 257);
			return;
		}
		if (ft.renames!=null) ft = ft.renames;
		int m, n;
		string cn = ft.home._name.fast_name;
		s.feature_view.get_toplevel().show_all();
		s.feature_class.set_text(cn);
		m = (int)ft.first_pos/256;
		if (m==0) return;
		n = (int)ft.last_pos/256;
		name = ft._name.fast_name;
		s.feature_lines.set_text("%d - %d".printf(m, n));
		buf = s.feature_view.get_buffer() as SourceBuffer;
		show_class(buf, ft.home, m, n);
		buf.get_start_iter(out start);
		bool ok=false;
		do {
			ok = start.forward_search(name, TextSearchFlags.CASE_INSENSITIVE,
									  out start, out end, null);
			if (!ok) break;
			unichar c = end.get_char();
			ok = !c.isalnum() && c!='_';
				if (ok) {
					buf.apply_tag(tag, start, end);
				} else {
					start.assign(end);
				}
		} while (!ok);
	}
	
	private bool compute_value(bool now) {
		var buf = text_view.get_buffer() as SourceBuffer;
		var tag = buf.tag_table.lookup("computable");
		TextIter start, end;
		string word;
		int ln, cn, pos, after; 
		buf.get_bounds(out start, out end);
		if (!start.forward_to_tag_toggle(tag)) return false;
		ln = start.get_line();
		cn = start.get_line_offset();
		pos = 256*(ln+1) + (cn+1);
		Qualified? q = identifier_table.@get(pos);
		if (q==null || q.ft==null) return false;
		pos = (int)q.pos;
		start.backward_chars(pos);	// now at routine entry
		after = (int)(pos+q.size);
		end.assign(start);
		end.forward_chars(after);	// after name and args
		for (q=q.p; q!=null; q=q.p) pos = (int)q.pos;
		start.forward_chars(pos);	// at left most target
		word = buf.get_text(start, end, true);
		word = word.delimit("\t\r\n", ' '); 
		if (now) {
			data.eval.compute(word, true); 
		} else {
			data.eval.insert(word); 
		}
		return true;
	}

	public int insert_position(bool stoppable) {
		var buffer = text_view.get_buffer() as SourceBuffer;
		TextMark mark;
		TextIter at;
		int line, col;
		mark = buffer.get_insert();
		buffer.get_iter_at_mark(out at, mark);
		if (stoppable) {
			TextTagTable tags = buffer.get_tag_table();
			TextTag *stop = tags.lookup("stoppable");
			if (at.has_tag(stop)) {
				at.backward_char();
				at.backward_to_tag_toggle (stop);
				at.backward_char();
			} else {
				at.backward_to_tag_toggle (stop);
				if (!at.has_tag(stop)) at.backward_char();
			}
		}
		line = at.get_line()+1;
		col = at.get_line_offset()+1;
		return 256*line + col;
	}
	
	void highlight_breakpoint(uint class_id, int pos) {
		if (class_id==0 || class_id!=cid || source.dg==null) return;
		ClassText* cls = source.dg.rts.class_at(class_id);
		var text = text_view.get_buffer() as SourceBuffer;
		var tags = text.get_tag_table();
		var tag = tags.lookup("break");
		TextIter start, end;
		int line = pos/256-1, col=pos%256-1;
		text.get_bounds(out start, out end);
		start.set_line(line);
		start.set_line_offset(col);
		end.assign(start);
		end.forward_char();
		text.apply_tag(tag, start, end);
	}
	
	void lowlight_breakpoint(uint class_id, int pos) {
		if (class_id==0 || class_id!=cid || source.dg==null) return;
		ClassText* cls = source.dg.rts.class_at(class_id);
		var text = text_view.get_buffer() as SourceBuffer;
		var tags = text.get_tag_table();
		TextIter start, end;
		int line = pos/256-1, col=pos%256-1;
		text.get_bounds(out start, out end);
		start.set_line(line);
		start.set_line_offset(col);
		end.assign(start);
		end.forward_char();
		text.remove_tag_by_name("break", start, end);
	}
	
	private void highlight_one_breakpoint(Breakpoint? old_bp, Breakpoint new_bp) {
		if (old_bp!=null && old_bp.cid==cid) {
			lowlight_breakpoint(cid, (int)old_bp.pos);
		}
		if (new_bp.cid==cid) {
			highlight_breakpoint(cid, (int)new_bp.pos);
		}
	}
	
	private void highlight_all_breakpoints(Gee.List<Breakpoint> list) {
		Breakpoint bp;
		var text = text_view.get_buffer() as SourceBuffer;
		TextIter start, end;
		text.get_bounds(out start, out end);
		text.remove_tag_by_name("break", start, end);
		for (Gee.Iterator<Breakpoint> iter=list.iterator(); iter.next();) {
			bp = iter.@get();
			highlight_one_breakpoint(null, bp);
		}
	} 
	
	internal void do_goto(Entry entry) {
		var text = text_view.get_buffer() as SourceBuffer;
		TextIter start, end;
		double frac;
		int ln = text.get_line_count();
		int n = int.parse(entry.get_text());
		int now;
		if (n<0) n = ln+n;
		--n;
		bool ok = text_view.place_cursor_onscreen();
		text.get_iter_at_mark(out start, text.get_insert());
		now = start.get_line();
		frac = now<n ? 0.2 : 0.8;
		start.set_line(n);
		text_view.scroll_to_iter(start, 0.05, false, 0.0, frac);
		source.go_to.set_text("");
		show_line(n);
		text_view.set_highlight_current_line(true);
		text_view.grab_focus();
	}
	
	private bool do_motion (Gdk.EventMotion ev, SourcePart s) {
		if ((int)cid<0 || source.dg==null) return false;
		ClassText* cls = source.dg.rts.class_at(cid);
		FeatureText* ft = null;
		int[] pos;
		if (!text_view.has_focus) return false;
		var text = text_view.get_buffer() as SourceBuffer;
		TextIter start, end, loc;
		TextTag id_op = text.tag_table.lookup("ident-or-op");
		TextTag list = text.tag_table.lookup("listable");
		TextTag comp = text.tag_table.lookup("computable");
		TextTag pm = text.tag_table.lookup("paren-mark");
		TextTag paren = text.tag_table.lookup("paren");
		int x, y;
		uint i, j;
		int p = 0, at;
		uint id = status.get_context_id("");
		status.remove_all(id);

		text.get_bounds(out start, out end);
		text.remove_tag(paren, start, end);
		text.remove_tag(list, start, end);
		text.remove_tag(comp, start, end);
		text_view.window_to_buffer_coords(TextWindowType.TEXT,
			(int)ev.x, (int)ev.y, out x,out y);
		text_view.get_iter_at_location(out loc, x, y);
		other_paren = -1;
		if (loc.has_tag(id_op)) {
			start.assign(loc);
			if (!start.begins_tag(id_op)) start.backward_to_tag_toggle(id_op);
			int line = start.get_line()+1;
			int col = start.get_line_offset()+1;
			at = 256*(line) + col;
			Qualified? q = identifier_table.@get(at);	
			end.assign(start);
			end.forward_to_tag_toggle(id_op);
			if (q.cls==null) ft = q.ft;
			if (ft==null && (q==null || q.cls==null)) return false;
			text.apply_tag(list, start, end);
			if (ft==null) return true;
			string name = "";
			if (ft.home!=cls) 
				name += "Class " + ft.home._name.fast_name;
			Expression? ex = null;
			if (s.active && frame!=null && ft.result_text!=null) {
				RoutineText* rt = frame.routine.routine_text();
				if (rt.has_position(line, col)) {
					end.assign(start);
					end.forward_chars((int)q.size);
					text.apply_tag(comp, start, end);
					ex = simple_value(q);
					if (ex!=null) {
						try {
							ex.compute_in_stack(frame, source.dg.rts);
							if (name.length>0) name += "  ;  ";
							name += ex.bottom().format_one_value
								(ex.Format.WITH_NAME | ex.Format.WITH_TYPE);
						} catch (GLib.Error e) {
						}
					}
				}
			} 
//			if (source.value_as_tooltip && ex!=null) ; 	else 
			status.push(id, name);
		} else if (loc.has_tag(pm)) {
			int off;
			bool single;
			start.assign(loc);
			off = start.get_offset();
			single = true; //!parenths.contains(off);
			if (!single) {
				off = off-1;
				start.backward_chars(1);
			}
			end.assign(start);
			end.forward_chars(single ? 1 : 2);
			text.apply_tag(paren, start, end);
			other_paren = parenths.@get(off);
			start.set_offset(other_paren);
			end.assign(start);
			end.forward_chars(single ? 1 : 2);
			text.apply_tag(paren, start, end);
		}
		return false;
	}
	
	private Expression? simple_value(Qualified? q) {
		if (q==null || q.ft==null) return null;
		Expression? ex = null;
		Expression? pex = null;
		Entity* e = null;
		string name = q.ft._name.fast_name;
		uint n;
		if (q.ft.is_routine()) return null;
		if (q.p!=null) {
			pex = simple_value(q.p);
			if (pex==null) return null;
			e = (Entity*)pex.dynamic_type.field_by_name(name);
		} else if (frame!=null) {
			e = frame.target_type().
				query_by_name(out n, name, false, frame.routine);
		}
		ex = (e!=null && !e.is_scope_var()) ? 
			Expression.new_typed(pex, e, null) : null;
		if (pex==null) return ex;
		pex.set_child(pex.Child.DOWN, ex);
		return pex;
	}

	private void set_once_breakpoint(uint class_id, uint pos, bool hard) {
		if (source.brk==null || source.run==null || source.dg==null) return;
		RoutineText* rt = frame!=null ? frame.routine.routine_text() : null;
		if (rt==null || !rt.has_position(pos/256, pos%256)) {
			// TODO: Error message
			// stderr.printf("Error: routine not active\n");
			return;
		}
		Breakpoint bp = new Breakpoint.with_location(class_id, pos, false);
		bp.depth = frame.depth;	
		bp.enabled = true;
		Gee.List<Breakpoint> list = source.brk.breakpoints(false);
		list.insert(0, bp);
		var dr = source.dg as Driver;
		if (dr!=null) {
			dr.update_breakpoints(list);
			source.run.simple_cont(hard);
		}
	}

	private uint b3_id;
	private uint b3_count;

	private bool do_b3(SourcePart s) {
		switch (b3_count) {
		case 1:
			show_feature(s);
			break;
		case 2:
			compute_value(false);
			break;
		case 3:
			compute_value(true);
			break;
		}
		b3_count = 0;
		b3_id = 0;
		return false;
	}

	private bool do_button(Gdk.EventButton ev, SourcePart s) {
		if (ev.button!=3) return false;
		switch (ev.type) {
		case Gdk.EventType.BUTTON_PRESS:
			b3_count = 1;
			break;
		case Gdk.EventType.@2BUTTON_PRESS:	
			b3_count = 2;
			break;
		case Gdk.EventType.@3BUTTON_PRESS:
			b3_count = 3;
			break;
		}
		if (b3_id==0) b3_id = Timeout.@add(600, () => { return do_b3(s); });
		return true;
	}

	private bool do_key(Gdk.EventKey ev, SourcePart s ) {
		if (ev.type != Gdk.EventType.KEY_PRESS) return false;
		ClassText* cls;
		Breakpoint bp;
		Gdk.Window w;
		var text = text_view.buffer as SourceBuffer;
		uint code = ev.keyval;
		string value;
		uint l, p, x, y;
		if ((ev.state & Gdk.ModifierType.CONTROL_MASK) > 0) {
			if (!s.active) {
				switch (code) {
				case '.':
				case 'b':
				case 'k':
				case 'u':
				case 'U':
				case 'e':
				case 'E':
				case 'p':
					return false;
				}
			}
			switch (code) {
			case 'x':
				b3_count = 1;
				do_b3(source);
				break;
			case 'e': 
				b3_count = 2;
				do_b3(source);
				break;
			case 'E': 
				b3_count = 3;
				do_b3(source);
				break;
			case '.': 
				if (frame==null) 
					frame = source.stack.frame();
				if (frame!=null) 
					highlight_actual(frame, frame.pos);
				break;
			case 'p':
				if (other_paren>=0) {
					TextIter iter;
					text.get_iter_at_offset(out iter, other_paren);
					var mark = text.get_insert();
					text.place_cursor(iter);
					text_view.scroll_to_mark(mark, 0.05, false, 0.0, 0.0);
				}
				break;
			case 'b': 
				if (brk!=null) {
					cls = current_class();
					if (!cls.is_debug_enabled()) break;
					actual_pos = insert_position(true);
					bp = new Breakpoint.with_location(cls.ident, actual_pos, true);
					brk.add_breakpoint(bp);
				}
				break;
			case 'k':
				if (brk!=null) {
					actual_pos = insert_position(true);
					cls = current_class();
					brk.kill_breakpoint(cls.ident, actual_pos);
				}
				break;
			case 'u': 
			case 'U': 
				cls = current_class();
				p = insert_position(true);
				set_once_breakpoint(cls.ident, p, code=='U');
				break;
			case 'l':
				s.search_state = s.SearchMode.GO_TO;
				break;
			case 'f':
			case 'r':
				return s.handle_key(ev,text_view);
			default:
				return false;
			}
		} else if (ev.is_modifier==0) {
			string str="";
			switch (s.search_state) {
			case s.SearchMode.GO_TO:
				value = source.go_to.get_text();
				l = value.length;
				switch (code) {
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					value = "%s%c".printf(value, (int)code);
					source.go_to.set_text(value);
					break;
				case '-':
					if (value.length==0) {
						value = "-%s".printf(value);
						source.go_to.set_text(value);
					}
					break;
				case Gdk.Key.BackSpace:
					if (l>0) {
						value = value.substring(l-1);
						source.go_to.set_text(value);
					}
					break;
				case Gdk.Key.Return:
				case Gdk.Key.KP_Enter:
					do_goto(source.go_to);
					s.end_search(text_view);
					break;
				default:
					break;
				}
				break;
			default:
				return s.handle_key(ev,text_view);
			}
		}
		return true;
	}
	
	private bool do_leave(Widget w, Gdk.EventCrossing ev) {
		var text = text_view.get_buffer() as SourceBuffer;
		var tag = text.tag_table.lookup("listable");
		TextIter start, end;
		text.get_bounds(out start, out end);
		if (start.forward_to_tag_toggle(tag)) 
			text.remove_tag(tag, start, end);	
		source.end_search(text_view);
		return false;
	}

	public FullSource(Debuggee dg, SourcePart s) {
		base(s);
		TextIter iter;
		Label label;
		identifier_table = new Gee.HashMap<int,Qualified?>();
		predefs = new Gee.HashSet<string>();
		predefs.@add("current");
		predefs.@add("result");
		predefs.@add("void");
		predefs.@add("false");
		predefs.@add("true");
		predefs.@add("precursor");

		brk = s.brk;
		data = s.data;
		status = s.status;

		var attr = new SourceMarkAttributes();
		var color = new Gdk.RGBA();
		color.parse("#e0ffc4");
		attr.background = color;
		text_view.set_mark_attributes("actual-line", attr, 0);
		text_view.highlight_current_line = true;
		text_view.show_line_numbers = true;
		text_view.show_line_marks = true;
		text_view.cursor_visible = true;

		text_view.button_press_event.connect(
			(eb) => { return do_button(eb, s); });
		text_view.key_press_event.connect((ek) => { return do_key(ek,s); });
		text_view.motion_notify_event.connect((e) => { return do_motion(e,s);});
		text_view.leave_notify_event.connect((e) => 
			{ return do_leave(text_view,e);});
 		var buf = text_view.buffer as SourceBuffer;
		buf.highlight_matching_brackets = false;
		source.prepare_client(text_view);
		if (brk!=null) {
			brk.edited.connect((b,o,n) => { highlight_one_breakpoint(o,n); });
			brk.set_changed.connect((b,l) => { highlight_all_breakpoints(l); });
		}
	}

	public void set_frame(StackPart stack) {
		if (frame!=null && !stack.has_frame(frame)) frame = null;
		if (frame==null) frame = stack.frame_of_class(cid);
	}

	public void show_main_class(ClassText* cls) {
		if (cls.ident==cid || source.dg==null) return;
		FeatureText* ft;
		RoutineText* rt;
		var text = text_view.get_buffer() as SourceBuffer;
		var tags = text.get_tag_table();
		var stop = tags.lookup("stoppable");
		TextIter iter, before;
		string block;
		uint32 *pos;
		uint p;
		int line, len;
		int i,j,n;
		cid = cls.ident;
		show_class(text, cls, 1, int.MAX);
		text.get_bounds(out before, out iter);
		identifier_table.clear();
		for (i=cls.features.length; i-->0;) {
			ft = cls.features[i];
			if (ft.home!=cls || ft.renames!=null) continue;
			if (ft.is_routine()) {
				rt = (RoutineText*)ft;
				pos = rt.instruction_positions;
				if (pos==null && ft.renames!=null)
					rt = (RoutineText*)ft.renames;
				n = rt.instruction_positions.length;
				for (j=n; j-->0;) {
					p = pos[j];
					if (p==0) continue;
					line = (int)p/256-1;
					len = (int)p%256;
					iter.set_line(line);
					iter.forward_chars(len);
					before.assign(iter);
					before.backward_char();
					text.apply_tag(stop, before, iter);
				}
			}
			text.get_bounds(out before, out iter);
			p = ft.first_pos;
			if (p==0) continue;
			line = (int)p/256-1;
			len = (int)p%256;
			before.set_line(line);
			before.forward_chars(len-1);
			p = ft.last_pos;
			line = (int)p/256-1;
			len = (int)p%256;
			iter.set_line(line);
			iter.forward_chars(len);
			block = text.get_text(before, iter, false);
			var parser = new Parser(ft, source.dg.rts);
			parser.ident_matched.connect((v) => { highlight_feature(ft,v); });
			parser.class_matched.connect((v) => { highlight_feature(ft,v); });
			parser.add_string(block); 
			parser.end();
		}
		text.get_start_iter(out iter);
		text.place_cursor(iter);
		if (brk!=null) {
			Gee.List<Breakpoint> list = brk.breakpoints(false);
			highlight_all_breakpoints(list);
		}
	}
	
	public void highlight_actual(StackFrame* f, uint pos) {
		if (source.dg==null) return;
		var text = text_view.get_buffer() as SourceBuffer;
		var tags = text.get_tag_table();
		var actual = tags.lookup("actual");
		TextIter start, end;
		int line, col;
		text.get_bounds(out start, out end);
		text.remove_tag(actual, start, end);
		frame = f;
		int level = f!=null ? f.depth : -1;
		if (level>=0) {
			uint old = cid;
			ClassText* cls = source.dg.rts.class_at(f.class_id);
			show_main_class(cls);
			line = (int)(pos/256-1);
			col = (int)(pos%256-1);
			text.get_iter_at_line(out start, line);
			start.forward_chars(col);
			if (actual_line==null || old!=cid) 
				actual_line = text.create_source_mark(null, "actual-line", start);
			else 
				text.move_mark(actual_line, start);
			end = start;
			end.forward_char();
			text.apply_tag(actual, start, end); 
			GLib.Idle.@add(() => { return show_line(line); });
		} else if (actual_line!=null) {
			text.delete_mark(actual_line);
			actual_line = null;
		}
	}
	
} /* class FullSource */
