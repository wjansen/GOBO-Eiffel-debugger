using Gtk;
using Gedb;

internal class History : Dialog {

	private weak GUI gui;

	private SpinButton expr;
	private int expr_size = 10;
	private SpinButton pattern;
	private int pattern_size = 10;
	private SpinButton arg;
	private int arg_size = 5;

	private void set_sizes() {
		gui.source.pattern_history.max_size = pattern_size;
		gui.eval.history.max_size = expr_size;
		if (gui.sql!=null) {
			gui.sql.select_history.max_size = expr_size;
			gui.sql.where_history.max_size = expr_size;
		}
		if (gui.run!=null) {
			gui.run.print_history.max_size = expr_size;
			gui.run.arg_history.max_size = arg_size;
		}
	}

	private void do_history(Dialog d, int response) {
		switch (response) {
		case ResponseType.CANCEL:
			expr.value = expr_size;
			pattern.value = pattern_size;
			arg.value = arg_size;
			break;
		case ResponseType.CLOSE:
			expr_size = (int)expr.value;
			pattern_size = (int)pattern.value;
			arg_size = (int)arg.value;
			set_sizes();
			break;
		}
		hide();
	}

	internal History(GUI gui) {
		this.gui = gui;
		transient_for = gui;
		title = compose_title("History sizes", null);
		add_button(Gtk.Stock.CANCEL, ResponseType.CANCEL);
		add_button(Gtk.Stock.CLOSE, ResponseType.CLOSE);

		var content = get_content_area () as Box;
		var grid = new Grid();
		content.@add(grid);
		grid.margin= 5;
		grid.row_spacing = 5;
		grid.column_spacing = 8;

		Label label, prev;

		label = new Label(
"""Expressions
(<span><i>Print on stop</i> of <b>Run</b>,
<i>Expr</i> of <b>Evaluation</b>,
<i>select</i>, <i>where</i> of <b>SQL</b>)</span>"""
			);
		label.use_markup = true;
		grid.attach(label, 0, 0, 1, 1);
		label.halign = Align.START;
		expr = new SpinButton.with_range(1, 100, 1);
		grid.attach_next_to(expr, label, PositionType.RIGHT, 1, 1);
		expr.value = expr_size;

		prev = label;
		label = new Label(
"""Search patterns
(<span><i>Regular expression</i>
of <b>Source/Console</b>) </span>"""
			);
		label.use_markup = true;
		grid.attach_next_to(label, prev, PositionType.BOTTOM, 1, 1);
		label.halign = Align.START;
		pattern = new SpinButton.with_range(1, 100, 1);
		grid.attach_next_to(pattern, label, PositionType.RIGHT, 1, 1);
		pattern.value = pattern_size;

		prev = label;
		label = new Label("Command line arguments");
		grid.attach_next_to(label, prev, PositionType.BOTTOM, 1, 1);
		label.halign = Align.START;
		arg = new SpinButton.with_range(1, 100, 1);
		grid.attach_next_to(arg, label, PositionType.RIGHT, 1, 1);
		arg.value = arg_size;

		set_sizes();
		response.connect(do_history);
	}

}

internal class Appearance : Dialog {

	private weak GUI gui;

	private SpinButton tabs;
	private int tab_width = 3;
	private CheckButton wrap;
	private bool wrap_mode = false;
	private CheckButton val;
	private bool value_mode = false;
	private CheckButton tree;
	private bool tree_lines = false;
	private CheckButton tips;
	private bool tooltips = true;

	private void set_values() {
		tab_width = (int)tabs.value;
		gui.source.tab_width = tab_width;
		wrap_mode = wrap.active;
		gui.source.wrap_mode = wrap_mode;
		// value_mode = val.active;
		// gui.source.value_as_tooltip = value_mode;;
		tree_lines = tree.active;
		gui.data.tree_lines = tree_lines;;
		tooltips = tips.active;
		gui.set_tooltip(tooltips);
	}

	private void do_appearance(int response) {
		switch (response) {
		case ResponseType.APPLY:
			set_values();
			break;
		case ResponseType.CLOSE:
			hide();
			tabs.value = tab_width;
			wrap.active = wrap_mode;
			tree.active = tree_lines;
			// val.active = value_mode;
			tips.active = tooltips;
			break;
		}
	}

	internal Appearance(GUI gui) {
		this.gui = gui;
		title = compose_title("Appearance", null);
		add_button(Gtk.Stock.APPLY, ResponseType.APPLY);
		add_button(Gtk.Stock.CLOSE, ResponseType.CLOSE);
		transient_for = gui;

		var content = get_content_area () as Box;
		var grid = new Grid();
		content.@add(grid);
		grid.margin= 5;

		Label label, prev, headline;
		Separator sep;
		headline = new Label("");
		headline.use_markup = true;
		headline.set_markup("<span><b>Source part</b></span>");
		headline.justify = Justification.LEFT;
		grid.attach(headline, 0, 0, 2, 1);
		label = new Label("Tabulator width ");
		grid.attach_next_to(label, headline, PositionType.BOTTOM, 1, 1);
		label.halign = Align.START;
		tab_width = gui.source.tab_width;
		tabs = new SpinButton.with_range(1, 8, 1);
		tabs.numeric = true;
		tabs.value = tab_width;
		grid.attach_next_to(tabs, label, PositionType.RIGHT, 1, 1);
		prev = label;
		label = new Label("Wrap long lines ");
		grid.attach_next_to(label, prev, PositionType.BOTTOM, 1, 1);
		wrap_mode = gui.source.wrap_mode;
		wrap = new CheckButton();
		wrap.active = wrap_mode;
		grid.attach_next_to(wrap, label, PositionType.RIGHT, 1, 1);
		sep = new Separator(Orientation.HORIZONTAL);
		grid.attach_next_to(sep, label, PositionType.BOTTOM, 2, 1);
/* 
		val = new CheckButton.with_label("Show values as tips");
		val.active = gui.source.value_as_tooltip;
		content.pack_start(val, false, false, 0);
*/
		headline = new Label("");
		headline.use_markup = true;
		headline.set_markup("<span><b>Data part</b></span>");
		headline.justify = Justification.LEFT;
		grid.attach_next_to(headline, sep, PositionType.BOTTOM, 2, 1);
		prev = label;
		label = new Label("Show tree lines ");
		grid.attach_next_to(label, headline, PositionType.BOTTOM, 1, 1);
		label.halign = Align.START;
		tree_lines = gui.data.tree_lines;
		tree = new CheckButton();
		tree.active = tree_lines;
		grid.attach_next_to(tree, label, PositionType.RIGHT, 1, 1);
		sep = new Separator(Orientation.HORIZONTAL);
		grid.attach_next_to(sep, label, PositionType.BOTTOM, 2, 1);

		headline = new Label("");
		headline.use_markup = true;
		headline.set_markup("<span><b>Tooltips</b></span>");
		headline.justify = Justification.LEFT;
		grid.attach_next_to(headline, sep, PositionType.BOTTOM, 2, 1);
		label = new Label("Show tooltips ");
		label.halign = Align.START;
		grid.attach_next_to(label, headline, PositionType.BOTTOM, 1, 1);
		tooltips = true;
		tips = new CheckButton();
		tips.active = tooltips;
		grid.attach_next_to(tips, label, PositionType.RIGHT, 1, 1);
		
		sep = new Separator(Orientation.HORIZONTAL);
		content.pack_start(sep, false, false, 5);

		response.connect(do_appearance);
	}
}

internal class Menus : GLib.Object {

	private weak GUI gui;

	private void dialog_close(Dialog d) { d.destroy(); }

	private static int alias_less(string a, string b, 
								  Gee.HashMap<string,Expression> list) {
		Expression ex = list[a];
		if (ex.uses_alias("_"+b)) return 1;
		ex = list[b];
		if (ex.uses_alias("_"+a)) return -1;
		return a.ascii_casecmp(b);
	}

	private void store(FileStream fs) {
		Gee.ArrayList<string> al = new Gee.ArrayList<string>();
		string str;
		for (var iter=gui.alias_list.map_iterator(); iter.next();) {
			str = iter.get_key();
			al.insert(0, str);
		}
		al.sort((a,b) => { return alias_less(a,b,gui.alias_list); });
		foreach (var nm in al) {
			var ex = gui.alias_list[nm];
			fs.printf("alias %s -> %s\n", nm, ex.append_name());			
		}
		Breakpoint bp;
		var rts = gui.dg.rts;
		var list = gui.brk.breakpoints(true);
		for (var iter=list.list_iterator(); iter.next();) {
			bp = iter.@get();
			if (bp.watch!=null) continue;
			str = "break";
			if (bp.exc>0) 
				str += " catch " + bp.catch_to_short_string();
			if (bp.cid>0) 
				str += " at %s:%u:%u".printf(((Gedb.Name*)rts.class_at(bp.cid)).fast_name, 
											 bp.pos/256, bp.pos%256);
			if (bp.depth>0)
				str += " depth %u".printf(bp.depth);
			if (bp.tid>0) 
				str += " type %s".printf(((Gedb.Name*)rts.type_at(bp.tid)).fast_name);
			if (bp.iff!=null)
				str = bp.iff.append_name(str + " if ");
			if (bp.print!=null)
				str = bp.print.append_name(str + " print ");
			if (bp.cont) str += " cont";
			if (!bp.enabled) str += " disabled";
			fs.printf("%s\n",str);
		}
		if (gui.brk.debug.active) fs.printf("debug\n");
	}

	private FileStream? compose_file(bool save) requires (gui.dg!=null) {
		var title = compose_title("Store file", gui.dg.rts);
		string? fn = null;
		FileChooserAction mode = save 
			? FileChooserAction.SAVE 
			: FileChooserAction.OPEN;
		string button = save ? "_Save" : "_Open";
		var dialog = new FileChooserDialog(title, null, mode, 
										   "_Cancel", ResponseType.CANCEL,
										   button, ResponseType.ACCEPT);
		dialog.select_multiple = false;
		var filter = new FileFilter();
		filter.set_filter_name("Store files");
		filter.add_pattern("*.edg");
		dialog.add_filter(filter);
		filter = new FileFilter();
		filter.set_filter_name("All files");
		filter.add_pattern("*");
		dialog.add_filter(filter);
		if (dialog.run () == ResponseType.ACCEPT) 
			fn = dialog.get_filename();
		dialog.close();
		return fn!=null ? FileStream.open(fn, save ? "w" : "r") : null;
	}

	private bool do_check_exe(FileFilterInfo ffi) {
		string fn = ffi.filename;
		string mime = GLib.ContentType.from_mime_type(ffi.mime_type);
		return mime.index_of("sharedlib")>=0;
	}

	private void do_load(Gtk.Action a) {
		string? fn = null;
		var title = compose_title("Debuggee", null);
		var dialog = 
			new FileChooserDialog(title, null, FileChooserAction.OPEN,
								  "_Cancel", ResponseType.CANCEL,
								  "_Open", ResponseType.ACCEPT);
		dialog.select_multiple = false;
		var filter = new FileFilter();
		filter.set_filter_name("Loadable Libs");
		filter.add_pattern("*.so");	// or ".dll"
		dialog.add_filter(filter);
		filter = new FileFilter();
		filter.set_filter_name("All files");
		filter.add_pattern("*");
		dialog.add_filter(filter);
		if (dialog.run () == ResponseType.ACCEPT) {
			fn = dialog.get_filename();
			gui.new_debuggee(fn);
		}
		dialog.close();
	}

	private void do_store_def(Gtk.Action a) {
		if (!def_store.sensitive) return;
		var fn = gui.command+".edg";
		var fs = FileStream.open(fn, "w");
		if (fs!=null) store(fs);
	}

	private void do_store(Gtk.Action a) {
		var fs = compose_file(true); 
		if (fs!=null) store(fs);
	}

	private void do_restore(Gtk.Action a) {
		var fs = compose_file(false);
		if (fs!=null) gui.restore(fs);
	}

	private void do_cont(Gtk.Action a) { if (cont.sensitive) gui.cont(); }	

	private void do_quit(Gtk.Action a) { gui.quit(); }	

	private void do_stack_data(Gtk.Action a) {
		Window extra = new MoreDataPart(gui.dg, gui.data, gui.stack);
		extra.show_all();
	}

	private void do_global(Gtk.Action a) { gui.show_global(); }
	private void do_sql(Gtk.Action a) { gui.show_sql(); }
	private void do_alias(Gtk.Action a) { gui.show_alias(); }

	private void do_history(Gtk.Action a) {
		var hist = gui.history;
		hist.show_all();
		hist.run();
	}

	private void do_appearance(Gtk.Action a) { 
		var app = gui.appearance;
		app.show_all();
		app.run();
	}

	private void help_on(Gtk.Action a) { 
		string gedb = Environment.get_variable("GOBO");
		var fn = GLib.Path.build_filename(gedb, "doc", "debugger", "index.html");
		string uri = @"file://$fn";
		try {
			show_uri(null, uri, Gdk.CURRENT_TIME);
		} catch (Error e) {
		}
	}
	private void help_colors(Gtk.Action a) { help.help_colors(gui); }

	private void help_system(Gtk.Action a) { 
		help.help_system(gui.dg!=null ? gui.dg.rts : null); 
	}

	private void help_about(Gtk.Action a) { help.help_about(gui); }

	private const Gtk.ActionEntry[] entries = {
		{ "FileMenu", null, "_File" },   
		{"Load", null, "_Load", null, "Load debuggee", do_load},
		{"Cont", null, "Co_ntinue", "F3", "Continue debuggee", do_cont},
		{"Store_def", null, "_Store", "<control>S", 
		 "Store breakpoints and alias definitions \nto default path", 
		 do_store_def},
		{"Store", null, "Store _as ...", null, 
		 "Store breakpoints and alias definitions \nto chosen path", 
		 do_store},
		{"Restore", null, "_Restore from ...", null, 
		 "Restore breakpoints and alias definitions\nfrom chosen path", 
		 do_restore},
		{"Quit", null, "_Quit", "<control>Q", "Quit debugger", do_quit},
		
		{ "WindowMenu", null, "_Window" },   
		{"Data", null, "New _data", "<control>D", 
		 "Open new data window", do_stack_data},
		{"Global", null, "_Global data", "<control>G", 
		 "Open window showing constants\nand once routines", 
		 do_global},
		{"Sql", null, "SQL _table", "<control>T", "Open SQL window", do_sql},
		{"Alias", null, "_Alias definition", "<control>A", 
		 "Manipulat definitions\nof alias names", do_alias},
		
		{"PreferenceMenu", null, "_Preferences" },   
		{"Appearance", null, "_Appearance", null, null, do_appearance},
		{"History", null, "_History sizes", null, null, do_history},

		{"HelpMenu", null, "_Help" },   
		{"Manual", null, "_Manual", "F1", "Help on debugger", help_on},
		{"System", null, "_System", null, "Show system info", help_system},
		{"Colors", null, "_Colors", null,
		 "Explain highlight colors\nin source part", 
		 help_colors},
		{"About", null, "_About", null, "", help_about},
	};

	private static const string ui_info_head = """
<ui>
  <menubar name='Menubar'>
    <menu action='FileMenu'>
""";

	private static const string ui_info_cont = """
      <menuitem action='Cont'/>
      <separator/>
""";

	private static const string ui_info_load = """
      <menuitem action='Load'/>
      <separator/>
""";

	private static const string ui_info_tail = """
      <menuitem action='Store_def'/>
      <menuitem action='Store'/>
      <menuitem action='Restore'/>
      <separator/>
      <menuitem action='Quit'/>
    </menu>
    <menu action='WindowMenu'>
      <menuitem action='Data'/>
      <menuitem action='Global'/>
      <menuitem action='Sql'/>
      <menuitem action='Alias'/>
    </menu>
    <menu action='PreferenceMenu'>
      <menuitem action='Appearance'/>
      <menuitem action='History'/>
    </menu>
    <menu action='HelpMenu'>
      <menuitem action='Manual'/>
      <menuitem action='Colors'/>
      <menuitem action='System'/>
      <menuitem action='About'/>
    </menu>
  </menubar>
</ui>
""";

	private HelpPart help;
	private Gee.ArrayList<Widget> preserve_list;

	internal void set_continue(bool b) {
		cont.set_sensitive(b);		
	}

	internal void do_set_sensitive(bool is_running) {
		set_deep_sensitive(menubar, !is_running, preserve_list);
	}

	public Menus(GUI gui, bool with_cont, bool with_load) {
		this.gui = gui;
		Gtk.ActionGroup actions = new Gtk.ActionGroup("Actions");
		actions.add_actions(entries, this);
		UIManager ui = new UIManager();
		ui.insert_action_group(actions, 0);
		accel = ui.get_accel_group();
		string info = ui_info_head;
		if (with_cont) info += ui_info_cont;
		if (with_load) info += ui_info_load;
		info += ui_info_tail;
		ui.add_ui_from_string(info, -1);
		menubar = ui.get_widget("/Menubar") as MenuBar;
		help = new HelpPart();

		preserve_list = new Gee.ArrayList<Widget>();
		preserve_list.@add(ui.get_widget("/Menubar/PreferenceMenu"));
		preserve_list.@add(ui.get_widget("/Menubar/HelpMenu"));
		if (with_cont) {
			cont = ui.get_widget("/Menubar/FileMenu/Cont") as Gtk.MenuItem;
			cont.set_sensitive(false);
			preserve_list.@add(cont);
		}
		if (with_load) {
			load = ui.get_widget("/Menubar/FileMenu/Load") as Gtk.MenuItem;
		}
		def_store = ui.get_widget("/Menubar/FileMenu/Store_def") as Gtk.MenuItem;
		if (gui.dg!=null)
			gui.dg.notify["is-running"].connect(
				(g,p) => { do_set_sensitive(gui.dg.is_running); });
	}

	public Gtk.AccelGroup accel { get; private set; }
	public MenuBar menubar { get; private set; }
	public Gtk.MenuItem cont { get ; private set; }
	public Gtk.MenuItem load { get ; private set; }
	public Gtk.MenuItem def_store { get ; private set; }

}

internal class AliasDef : Window {
	
	internal enum Item {
		NAME,
		VALUE,
		EXPR,
		BAD_NAME,
		BAD_VALUE,
		SEP,
		NUM_COLS
	}

	private weak GUI gui;

	private TreeView view;
	private ListStore store;
	private ExpressionChecker checker;

	private Gee.Map<string,Expression> list;

	private void do_pre_edit(CellRenderer cell, CellEditable editor,
							 string path_string) {
		var entry = editor as Entry;
		string text = entry.get_text();
		if (text==bullet) entry.set_text("");
	}

	private void do_post_edit(CellRendererText cell, string path_string,
							  string? text, uint col) {
		TreeIter iter;
		var path = new TreePath.from_string(path_string);
		store.get_iter(out iter, path);
		string val = text!=null ? text.strip() : null;
		uint l = val!=null ? val.length : 0;
		uint i = 0;
		unichar c = 0;
		string old;
		bool ok, bad;
		Expression ex;
		store.@get(iter, Item.NAME, out old, Item.EXPR, out ex, 
				   Item.BAD_NAME, out bad, -1);
		switch (col) {
		case Item.NAME:
			if (l==0) {
				store.@remove(iter);
				list.@remove(old);
			} else {
				if (old!=val) list.@remove(old);
				ok = true;
				for (i=0; ok && i<l; i++) {
					c = val.get_char(i);
					ok = i==0 ? c.isalpha() : (c=='_' || c.isalnum());
				}
				store.@set(iter, col, val, Item.BAD_NAME, !ok, -1);
				if (ok) {
					checker.clear_message();
					if (ex!=null) list.@set(val, ex);
				} else {
					checker.show_message("Invalid alias name:",
										 val[0:i-1], @"$c", val[i:l]);
				}
			}
			break;
		case Item.VALUE:
			if (l==0) val = bullet;
			ok = l>0 && checker.check_syntax(val, gui.dg.rts, list);
			ex = checker.parsed;
			var cycle = new Gee.ArrayList<string>();
			if (ok && AliasExpression.is_cyclic(ex, "_"+old, cycle)) {
				string msg = "";
				cycle.@foreach((c) => { msg += @" -> $c "; return true; });
				checker.show_message("Cyclic alias name definition:", 
									 "", @"$old", msg);
				ok = false;
			}
			store.@set(iter, Item.EXPR, ex, 
					   Item.VALUE, ok ? ex.append_name() : val, 
					   Item.BAD_VALUE, !ok,
					   -1);
			list.@set(old, ex);
			break;
		}
	}

	private void do_new() {
		TreeIter iter;
		store.append(out iter);
		store.@set(iter, Item.NAME, bullet, Item.VALUE, bullet, 
				   Item.BAD_NAME, true, Item.BAD_VALUE, true, -1);
		var sel = view.get_selection();
		sel.select_iter(iter);
	}

	private void do_close() { hide(); }

	private static int compare(TreeModel m, TreeIter a_iter, TreeIter b_iter) {
		string a, b;
		bool bad_a_name, bad_a_value, bad_b_name, bad_b_value;
		bool bad_a, bad_b, sep_a, sep_b;
		m.@get(a_iter, Item.NAME, out a, 
			   Item.BAD_NAME, out bad_a_name, 
			   Item.BAD_VALUE, out bad_a_value, 
			   Item.SEP, out sep_a, -1);
		m.@get(b_iter, Item.NAME, out b, 
			   Item.BAD_NAME, out bad_b_name, 
			   Item.BAD_VALUE, out bad_b_value,
			   Item.SEP, out sep_b, -1);
		bad_a = bad_a_name || bad_a_value;
		bad_b = bad_b_name || bad_b_value;
		if (sep_a && sep_b) return 0;
		if (sep_a) return bad_b ? -1 : 1;
		if (sep_b) return bad_a ? 1 : -1;
		if (bad_a!=bad_b) {
			return bad_a ? 1 : -1;
		} else {
			return a.collate(b);
		}
	}

	private bool do_sep(TreeModel m, TreeIter at) {
		bool sep;
		m.@get(at, Item.SEP, out sep, -1);
		return sep;
	}

	public AliasDef(GUI gui, Gee.Map<string, Expression> list) {
		this.gui = gui;
		this.list = list;
		checker = new ExpressionChecker();
		checker.parser.set_aliases(list);
		set_title(compose_title("Alias definition", gui.dg.rts));
		var vbox = new Box(Orientation.VERTICAL, 0);
		add(vbox);

		store = new ListStore(Item.NUM_COLS, 
							  typeof(string),
							  typeof(string),
							  typeof(Expression?),
							  typeof(bool),
							  typeof(bool),
							  typeof(bool));
		store.set_sort_func(Item.NAME, compare);
		store.set_sort_column_id(Item.NAME, SortType.ASCENDING);
		TreeIter iter;
		store.append(out iter);
		store.@set(iter, Item.SEP, true);

		view = new TreeView();
		view.headers_visible = true;
		view.set_model(store);
		view.set_search_column(Item.NAME);
		var sel = view.get_selection();
		sel.mode = SelectionMode.SINGLE;

		TreeViewColumn col;
		CellRendererText cell;
		cell = new CellRendererText(); 
		cell.strikethrough = true;
		cell.editable = true;
		cell.editing_started.connect(do_pre_edit);
		cell.edited.connect(
			(c,p,t) => { do_post_edit(c, p, t, Item.NAME); });
		col = new TreeViewColumn.with_attributes("Name", cell, 
												 "text", Item.NAME, null);
		col.set_data<uint>("bad", Item.NAME);
		col.add_attribute(cell, "strikethrough-set", Item.BAD_NAME);
		col.set_min_width(40);
		col.set_resizable(true);
		view.append_column(col);		

		cell = new CellRendererText(); 
		cell.strikethrough = true;
		cell.editable = true;
		cell.set_data<uint>("bad", Item.VALUE);
		cell.set_data<uint>("bad", Item.NAME);
		cell.editing_started.connect(do_pre_edit);
		cell.edited.connect(
			(c,p,t) => { do_post_edit(c, p, t, Item.VALUE); });
		col = new TreeViewColumn.with_attributes("Expression", cell, 
												 "text", Item.VALUE, null);
		col.set_data<uint>("bad", Item.VALUE);
		col.add_attribute(cell, "strikethrough-set", Item.BAD_VALUE);
		col.set_min_width(120);
		col.set_resizable(true);
		view.append_column(col);
		view.set_row_separator_func(do_sep);

		ScrolledWindow scroll = new ScrolledWindow(null, null);
		vbox.pack_start(scroll, true, true, 3);
		scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.ALWAYS);
		scroll.set_min_content_height(125);
		scroll.set_min_content_width(300);
		scroll.@add(view);

		vbox.pack_start(checker, false, false, 0);

		var buttons = new ButtonBox(Orientation.HORIZONTAL);
		buttons.set_layout(ButtonBoxStyle.START);
		vbox.pack_end(buttons, false, false, 0);
		
		var create = new Button.with_label("New");
		buttons.@add(create);
		create.set_tooltip_text("Define a new alias name");
		create.clicked.connect(() => { do_new(); });
		var close = new Button.with_label("Close");
		buttons.@add(close);
		buttons.set_child_secondary(close, true);
		close.clicked.connect((b) => { do_close(); });
		delete_event.connect((e) => { do_close(); return true; });
		
		update(list);
		show_all();
	}

	internal void update(Gee.Map<string,Expression> list) {
		TreeIter at;
		Expression ex;
		string name;
		this.list = list;
		store.clear();
		for (var iter=list.map_iterator(); iter.next();) {
			name = iter.get_key();
			ex = iter.get_value();
			store.append(out at);
			store.@set(at, Item.NAME, name, Item.BAD_NAME, false,
					   Item.VALUE, ex.append_name(), 
					   Item.BAD_VALUE, false, Item.EXPR, ex, -1);
		}		   
		TreeIter iter;
		store.append(out iter);
		store.@set(iter, Item.SEP, true);
	}
}

public class GUI : Window {

	private Menus menus;
	private FixedPart fixed;
	private AliasDef alias_def;
	private Paned panel;

	private string gedb;
	private string home;
	private string pwd;

	internal string command;
	internal Debuggee dg;
	internal Driver? dr;
	internal bool as_pma;
	
	public void show_global() {
		if (fixed==null) 
			fixed = new FixedPart(dg, stack, data, status);
		((Gtk.Window)fixed.get_toplevel()).present();
	}

	public void show_sql() { 
		if (sql==null) 
			sql = new SqlPart(dg, stack, data, status, alias_list);
		sql.present();
	}

	public void show_alias() {
		if (alias_def==null)
			alias_def = new AliasDef(this, alias_list);
		alias_def.present();
	}

	private Frame new_frame(string name) {
		string mark = "<span><b>%s</b></span>".printf(name);
		var label = new Label(null);
		label.set_markup(mark);
		var frame = new Frame(null);
		frame.set_label_widget(label);
		return frame;
	}

	internal void new_exe(Debuggee dg) {
		this.dg = dg;
		dr = dg as Driver;
		if (fixed!=null) {
// Delay closing `fixed' until all events have been served:
			GLib.Idle.@add(() => { 
					fixed.get_toplevel().destroy(); 
					return false;
				});
		}
		if (sql!=null) {
// Delay closing `sql' until all events have been served:
			GLib.Idle.@add(() => { 
					sql.get_toplevel().destroy(); 
					return false;
				});
			sql = null;
		}
		if (alias_def!=null) {
// Delay closing `sql' until all events have been served:
			GLib.Idle.@add(() => { 
					alias_def.get_toplevel().destroy(); 
					return false;
				});
			alias_def = null;
		}
		AbstractPart[] abs = {run, brk, source, stack, data};
		foreach (var a in abs) 
			if (a!=null) a.set_debuggee(dg);
		string fn = ((Gedb.Name*)dg.rts).fast_name;
		command = Path.build_filename(pwd, fn);
		fn = command + ".edg";
		var fs = FileStream.open(fn, "r");
		if (fs!=null) restore(fs);
		if (dg!=null) title = compose_title(null, dg.rts);
	}
		
	internal void set_continue(bool b) {
		menus.set_continue(b);
	}

	internal GUI(Debuggee dg, bool as_rta, bool loadable) {
		Frame frame;
		Label label;

		gedb = Environment.get_variable("GOBO");
		home = Environment.get_variable("HOME");
		pwd = Environment.get_variable("PWD");
		try {
			string fn = GLib.Path.build_filename
		   		(gedb, "tool", "gedb", "gobo-icon.jpeg");
			var gobo_icon = new Gdk.Pixbuf.from_file(fn);
			set_default_icon(gobo_icon);
		} catch (GLib.Error e) {
		}

		alias_list = new Gee.HashMap<string,Expression>();

		title = compose_title(null, null);
		resizable = true;
		has_resize_grip = true;

		Box vbox = new Box (Orientation.VERTICAL, 5);
		@add(vbox);

		menus = new Menus(this, !as_rta, as_rta&&loadable);
		accel = menus.accel;
		add_accel_group(accel);
		status = new Status();
		stack = new StackPart(status);
		data = new DataPart(stack, status, alias_list);
		eval = data.eval;
		if (as_rta) {
			console = new ConsolePart();
			run = new RunPart(stack, console, status, accel, alias_list);
			brk = new BreakPart(data, status, alias_list);
		}
		source = new SourcePart(brk, run, data, console, stack, status);
		history = new History(this);
		appearance = new Appearance(this);
		// Set part members which could not be set during construction
		// because of cyclic dependencies:
		if (brk!=null) brk.source = source;
		if (console!=null) console.set_searcher(source);

		MenuBar menubar = menus.menubar;
		vbox.pack_start(menubar, false, false, 0);
		vbox.pack_end(status, false, false, 0);
		panel = new Paned(Orientation.HORIZONTAL);
		vbox.pack_start(panel, true, true, 0);
		Box left = new Box(Orientation.VERTICAL, 5);
		Paned right = new Paned(Orientation.VERTICAL);
		panel.add1(left);
		panel.add2(right);
		if (run!=null) {
			frame = new_frame("Run");
			frame.@add(run);
			left.pack_start(frame, false, false, 0);
		}
		if (brk!=null) {
			frame = new_frame("Breakpoints");
			frame.@add(brk);
#if HIDDEB_BP
			var exp = new Expander("Show breakpoints");
			exp.@add(frame);
			exp.resize_toplevel = false;
			exp.notify["expanded"].connect((e,p) => 
				{ exp.label = exp.expanded ? "" : "Show breakpoints"; });
			left.pack_start(exp, false, false, 0);
#else
			left.pack_start(frame, false, false, 0);
#endif
		}
		var src = console!=null ? "Source/Console" : "Source";
		frame = new_frame(src);
		frame.@add(source);
		left.pack_end(frame, true, true, 0);
		frame = new_frame("Call stack");
		frame.@add(stack);
		right.add1(frame);
		var box = new Box(Orientation.VERTICAL, 0);
		frame = new_frame("Data");
		frame.@add(data);
		box.pack_start(frame, true, true, 0);
		frame = new_frame("Evaluation");
		frame.@add(eval);
		box.pack_start(frame, false, false, 0);
		right.add2(box);
		has_resize_grip = true;
//		set_default_size(1024,800);
		destroy.connect(quit);

		new_exe(dg);
	}
	
	public Gtk.AccelGroup accel { get; set; }
	public RunPart? run { get; private set; }
	public BreakPart? brk { get; private set; }
	public SourcePart source { get; private set; }
	public ConsolePart? console { get; private set; }
	public StackPart stack { get; private set; }
	public DataPart data { get; private set; }
	public EvalPart eval { get; private set; }
	public SqlPart sql { get; private set; }
	public Status status { get; private set; }
	public Gee.HashMap<string,Expression> alias_list;

	internal Appearance appearance { get; private set; }
	internal History history { get; private set; }

	internal bool interrupt;
	internal bool interactive;

	internal void cont() { 
		interrupt = true;
		interactive = false;
		hide();
		Gtk.main_quit();
	}

	internal void restore(FileStream fs) {
		Eval.Parser parser;
		Eval.Alias? al;
		Breakpoint? bp;
		string? line="";
		for (line=fs.read_line(); line!=null; line=fs.read_line()) {
			int l = line.index_of("--");
			if (l>=0) line = line.substring(0, l);
			line = line.strip();
			if (line.length==0) continue;
			parser = new Eval.Parser.as_command(dg.rts);
			parser.set_aliases(alias_list);
			parser.add_string(line);
			parser.end();
			al = parser.al;
			if (al==null) {
				if (brk!=null) {
					bp = parser.bp;
					if (bp==null) brk.set_debug_clause(true);
					else brk.add_breakpoint(bp);
				}
			} else {
				alias_list.@set(al.name, al.expr);
			}
		}
		if (alias_def!=null) 
			alias_def.update(alias_list);
	}

	internal void set_tooltip(bool yes) {
		set_deep_tooltip(this, yes);
		if (sql!=null) set_deep_tooltip(sql, yes);
		if (alias_def!=null) set_deep_tooltip(alias_def, yes);
	}

	public GUI.pma(Debuggee dg) {
		this(dg, false, false);
		new_exe(dg);
	}

	public GUI.rta(Driver dr, bool loadable) {
		this(dr, true, loadable);
		menus.do_set_sensitive(false);
		show_all();
	}

	public void quit() {
		destroy();
		if (the_gui!=null && the_gui.dr!=null) the_gui.dr.stop();
		Gtk.main_quit(); 
		Posix.exit(0); 
	}

	public signal void new_debuggee(string fn);
}

namespace Gedb {

	private Thread<int> thread;
	private void*[] orig_handlers;

	private static void sig_handler(int sig) {
		the_gui.dr.catch_signal(sig);
	}

	private static void interrupt_handler(int sig) {
		if (the_gui==null) return;
		if (the_gui.dr!=null) {
			if (thread==Thread.self<int>()) {
				the_gui.dr.set_interrupt();
			} else {
				the_gui.dr.catch_signal(sig);
			}
		} else if(the_gui.interactive) {
			Process.exit(1);	// To be imptoved!
			// the_gui.dg.interrupt_action();
		} else {
			crash(IseCode.Signal_exception, sig);
		}
	}

	internal GUI the_gui;

	public void make_rta(int* argc, uint8*** argv, AddressFunc af) {
		var dr = new Driver.with_args(argc, argv, af);
		if (the_gui==null) {
			unowned string[] args = dr.args;
			Gtk.init(ref args);
			the_gui = new GUI.rta(dr, false);
		}
		orig_handlers = new void*[32];
		for (int sig=32; sig-->0;) {
			switch (sig) {
			case ProcessSignal.ILL:
			case ProcessSignal.ABRT:
			case ProcessSignal.FPE:
			case ProcessSignal.SEGV:
				//orig_handlers[sig] =
				Process.@signal((ProcessSignal)sig, sig_handler);
				break;
			case ProcessSignal.INT:
				//orig_handlers[sig] =
				Process.@signal((ProcessSignal)sig, interrupt_handler);
				break;
			}
		}
		try {
			thread = new Thread<int>("GUI", () => 
				{ Gtk.main(); return 0; });
		} catch (Error e) { 
			stderr.printf("%s\n", e.message);
			Posix.exit(1);
		}
	}

	public void make_pma(string[] args, AddressFunc af) {
		var dg = new Debuggee(args, af);
		if (the_gui==null) {
			Gtk.init(ref args);
			the_gui = new GUI.pma(dg);
			the_gui.new_exe(dg);
			Process.@signal(ProcessSignal.INT, interrupt_handler);
		}
	}
	
	public void* crash(int reason, uint sig=0) { 
		var dr = the_gui.dg as Driver;
		if (dr!=null) 
			return dr.treat_stop(reason);
		bool ctrl_c = reason==IseCode.Signal_exception && sig==ProcessSignal.INT;
		if (!ctrl_c && the_gui.dg.has_rescue()) return null;
		var rts = the_gui.dg.rts;
		var bp = new Breakpoint();
		bp.exc = reason;
		string msg = bp.catch_to_string();
		string comment;
		uint id = the_gui.status.get_context_id("stop-reason");
		if (!the_gui.interrupt) {
			if (ctrl_c) {
				comment = "Program interrupted";
				the_gui.status.push(id, comment);
				comment = "Eiffel system <span><b>";
				comment += ((Gedb.Name*)rts).fast_name;
				comment += "</b></span> has been interrupted.";
				the_gui.set_continue(true);
			} else {
				comment = "Program crashed: ";
				the_gui.status.push(id, comment+msg);
				comment = "Eiffel system <span><b>";
				comment += ((Gedb.Name*)rts).fast_name;
				comment += "</b></span> has crashed.";
			}
			var dialog = new MessageDialog(the_gui, DialogFlags.MODAL,
										   MessageType.ERROR,
										   ButtonsType.YES_NO, comment);
			dialog.use_markup = true;
			dialog.secondary_use_markup = true;
			if (ctrl_c) 
				comment = "";
			else 
				comment = "Reason: <span foreground='red'>" + msg + "</span>\n\n";
			comment += "You may now run the Post Mortem Analyser";
			dialog.secondary_text = comment;
			dialog.title = compose_title("Crash", rts);
			dialog.response.connect((ans) => { 
					dialog.destroy(); 
					if (ans==Gtk.ResponseType.NO) GLib.Process.exit(0);
				});
			dialog.run();
		}
		the_gui.dg.crash_response(ctrl_c);
		the_gui.interactive = true;
		the_gui.show_all();
		Gtk.main();
		if (the_gui!=null && the_gui.interrupt) return null;
		the_gui = null;
		GLib.Process.exit(0);
	}

	public void* inform(int reason) { 
		return the_gui.dr.treat_info(reason);
	}

	public void* stop(int reason) { 
		return the_gui.dr.treat_stop(reason);
	}
}
