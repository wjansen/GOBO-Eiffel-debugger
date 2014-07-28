using Gtk; 
using Gedb; 

public class BreakPart : Box {
	
	private enum Item {
		ID = 0,
		CATCH,
		AT, CLS, POS,
		DEPTH,
		PP,
		WATCH, WATCH_TEXT,
		TYPE, TYPE_ID,
		IF, IF_TEXT,
		PRINT, PRINT_TEXT,
		CONT,
		DISABLED, 
		NUM_COLS
	}

	private enum Action { KILL, ENABLE, DISABLE }

	private Driver dg;
	private DataPart data;
	private Status status;
	private Expander info;
	private Label info_text;

	private TreeView view;
	private ListStore store;
	private ListStore type_list;
	private ExpressionChecker checker;
	private Gee.Map<string,Expression> aliases;

	private static void*[] watch_buffer;

	/**
	   Caution:
	   This variable has to be set after construction
	   (because of cyclic dependencies it has not yet been set)!
	 */
	public weak ClassPosition source;
	public CheckButton debug { get; private set; }

	private static int type_less(string tp1, string tp2) {
		return tp1.ascii_casecmp(tp2);
	}

	private Breakpoint filled_bp(TreeModel model, TreeIter iter) {
		Expression? iff, print;
		WatchInfo? watch;
		uint id, exc, cid, pos, depth, tid;
		bool pp, cont, dis;
		model.@get(iter, 
				   Item.ID, out id, 
				   Item.CATCH, out exc, 
				   Item.CLS, out cid, 
				   Item.POS, out pos, 
				   Item.DEPTH, out depth, 
				   Item.PP, out pp, 
				   Item.WATCH, out watch, 
				   Item.TYPE_ID, out tid, 
				   Item.IF, out iff, 
				   Item.PRINT, out print, 
				   Item.CONT, out cont, 
				   Item.DISABLED, out dis,
				   -1);
		Breakpoint bp = new Breakpoint.with_ident(id);
		bp.exc = exc;
		bp.cid = cid;
		bp.pos = pos;
		bp.depth = depth;
		bp.pp = pp;
		bp.watch = watch;
		bp.tid = tid;
		bp.iff = iff;
		bp.print = print;
		bp.cont = cont;
		bp.enabled = !dis;
		return bp;
	}

	private void do_create() { add_breakpoint(new Breakpoint()); }

	private void do_single_break(TreeModel model, TreeIter iter, int flag) {
		ListStore store = model as ListStore;
		uint id = 0;
		bool ok = true;
		store.@get(iter, Item.ID, out id, -1);
		switch (flag) {
		case Action.ENABLE:
		case Action.DISABLE:
			store.@set(iter, Item.DISABLED, flag==Action.DISABLE, -1);
			break;
		default:
			ok = false;
			break;
		}
		var list = breakpoints(false);
		dg.update_breakpoints(list);
		set_changed(list);	
	}

	private void ident_of_row(TreePath path, Gee.List<int> ids) {
		TreeIter iter;
		int id;
		store.get_iter(out iter, path);
		store.@get(iter, Item.ID, out id, -1);
		ids.@add(id);
	}

	private void kill_breakpoints(Gee.List<int> ids) {
		TreeIter at;
		int id, kill, n;
		bool ok;
		for (n=ids.size; n-->0;) {
			kill = ids.@get(n);
			for (ok=store.get_iter_first(out at); ok;
				 ok=store.iter_next(ref at)) {
				store.@get(at, Item.ID, out id, -1);
				if (id==kill) {
					store.@remove(at);
					break;
				}
			}
		}
		var list = breakpoints(true);
		dg.update_breakpoints(list);
		set_changed(list);	
	}

    private void do_manage(int code) {
		TreeSelection sel = view.get_selection();
		if (code==Action.KILL) {
			TreeModel model;
			var rows = sel.get_selected_rows(out model);
			var ids = new Gee.ArrayList<int>();
			rows.@foreach((p) => { ident_of_row(p, ids); });
			kill_breakpoints(ids);
		} else {
			sel.selected_foreach((m,p,i) => { do_single_break(m,i,code); });
		}
		sel.unselect_all();
	}

	private void do_debug(Button b) {
		bool ok =  (b as CheckButton).get_active();
		// issue enable debug command
	}

	private bool do_button(Gdk.EventButton e) {
		if (e.button==3) {
			TreePath path;
			TreeViewColumn col;
			int x, y;
			view.get_path_at_pos((int)e.x, (int)e.y, 
								  out path, out col, out x, out y);
			if (path==null)  return true;
			view.set_cursor(path, col, true);
			return true;
		}
		return false;
	}

	private void do_format_expr(CellRenderer cell,
								TreeModel model, TreeIter iter, uint col) {
		var ct = cell as CellRendererText;
		Expression? ex=null;
		model.@get(iter, col, out ex, -1);
		ct.text = ex!=null ? ex.append_name() : "";
	}

	private void do_format_catch(CellRenderer cell,
								TreeModel model, TreeIter iter) {
		var ct = cell as CellRendererText;
		uint cat;
		model.@get(iter, Item.CATCH, out cat, -1);
		string? str = Breakpoint.short_name_of_catch(cat);
		ct.text = str!=null ? str : "";
	}
	
	private void do_format_boolean(CellRenderer cell,
								   TreeModel model, TreeIter iter, int id) {
		var ct = cell as CellRendererText;
		bool ok;
		switch (id) {
		case 'c':
			model.@get(iter, Item.CONT, out ok, -1);
			ct.text = ok ? "T" : "B";
			break;
		case 'p':
			model.@get(iter, Item.PP, out ok, -1);
			ct.text = ok ? "++" : "";
			break;
		default:
			break;
		}
	}
	
	private void do_format_watch(CellRenderer cell,
								 TreeModel model, TreeIter iter) {
        var ct = cell as CellRendererText;
        WatchInfo? wi;
        model.@get(iter, Item.WATCH, out wi, -1);
		ct.text = (wi!=null && wi.address!=null) ? "%p".printf(wi.address) : "";
	}
	
	private bool do_set_type(CellRenderer cell, TreeIter at, TreeIter iter) {
		TreePath path = store.get_path(iter);
        var ct = cell as CellRendererText;
		string name;
		uint id;
		type_list.@get(at, TypeEnum.TYPE_NAME,
					   out name, TypeEnum.TYPE_IDENT, out id, -1);
		store.@set(iter, Item.TYPE, name, Item.TYPE_ID, id, -1);
		return true;
	}

	private void do_check_expression(Entry entry, uint col, TreeIter iter) {
		checker.reset();
		string str = entry.get_text();
		if (str.strip().length==0) {
			entry.editing_done();
			return;
		}
		uint tid, cid, pos;
		store.@get(iter, Item.TYPE_ID, out tid, 
				   Item.CLS, out cid, Item.POS, out pos, -1);
		if (tid>0 && cid==0) {
			Gedb.Type* t = dg.rts.type_at(tid);
			ClassText* ct;
			if (t.is_normal()) {
				NormalType* nt = (NormalType*)t;
				ct = nt.base_class;
			} else {
				ct = dg.rts.class_by_name(t.class_name);
			}
			cid = ct.ident;
		} 
		if (cid>0) 
			checker.check_static(str, tid, cid, pos, aliases, dg.rts, col==Item.IF);
	}

	private void do_pre_edit(CellRenderer cell, CellEditable editor,
							 string path_string) {
		TreePath path;
		TreeRowReference tref;
		TreeIter iter;
		EntryCompletion compl;
		Adjustment adj;
		Entry entry;
		Gee.List<void*> list;
		uint tid;
		int n = 0;
		uint col = cell.get_data<uint>("column");
		view.get_selection().unselect_all();
		path  = new TreePath.from_string(path_string);
		store.get_iter(out iter, path);
		switch (col) {
		case Item.AT:
			break;
		case Item.DEPTH:
			break;
			adj = (cell as CellRendererSpin).adjustment;
			store.@get(iter, Item.DEPTH, out n, -1);
			adj.set_value(n);
			break;
		case Item.TYPE:
			entry = editor as Entry;
			compl = new EntryCompletion();
			compl.set_match_func((c,k,i) => 
				{ return checker.do_filter_type_name(c,k,i,null); });
			compl.set_model(type_list);
			compl.set_text_column(TypeEnum.TYPE_NAME);
			n = type_list.iter_n_children(null);
			n = (int)(Math.log2(n)/3.0);
			compl.set_minimum_key_length(n);
			compl.match_selected.connect(
				(c,m,i) => { return do_set_type(cell,i,iter); });
			compl.insert_action_text (0, "clear");
			compl.action_activated.connect(
				(c,i) => { 
					store.@set(iter, Item.TYPE, "", Item.TYPE_ID, 0, -1);
					entry.activate();
				});
			entry.set_completion(compl);
			entry.set_has_frame(true);
			break;  
		case Item.IF_TEXT:
		case Item.PRINT_TEXT:
			entry = editor as Entry;
			entry.set_has_frame(true);
			col = col==Item.IF_TEXT ? Item.IF : Item.PRINT;
			entry.activate.connect((e) => { do_check_expression(e,col,iter); });
			break;
		default:
			break;
		}
	}

	private void do_post_edit(CellRendererText cell, string path_string,
							  string? text) {
		if (text==null) return;
		Eval.Parser parser;
		Expression ex;
		TreePath path;
		TreeIter iter;
		string value = text;
		uint col=0, n=0, pos;
		bool ok=false;
		path = new TreePath.from_string(path_string);
		store.get_iter(out iter, path);
		Breakpoint bp_old = filled_bp(store, iter);
		col = cell.get_data<uint>("column");
		switch (col) {
		case Item.CONT:
			ok = text[0].tolower()=='t';
			store.@set(iter, col, ok, -1);
			value = ok ? "B" : "T";
			break;  
		case Item.CATCH:
			n = Breakpoint.code_of_catch(text);
			store.@set(iter, col, n, -1);
			break;  
		case Item.AT:
			ok = false;
			if (text[0].tolower()=='s') {
				source.get_position(out n, out pos);
				ClassText* cls = dg.rts.class_at(n);
				value = "%s:%u:%u".printf(cls._name.fast_name, pos/256, pos%256);
			} else {
				value = "";
				n = 0;
				pos = 0;
			}
			store.@set(iter, Item.AT, value, Item.CLS, n, Item.POS, pos, -1);
			break; 
		case Item.DEPTH:
			store.@set(iter, col, int.parse(value), -1);
			break; 
		case Item.WATCH_TEXT: 
			if (text[0].tolower()=='s') {
				var sel = data.selected_item();
				var wi = new WatchInfo.from_data(sel, data.frame, dg.rts);
				ok = wi.address!=null;
				if (ok) {
					value = "%p".printf(wi.address);
					store.@set(iter, Item.WATCH, wi, Item.WATCH_TEXT, value, -1);
				} else {
					checker.set_message("No valid data item selected.", "");
				}
			} 
			if (!ok)
				store.@set(iter, Item.WATCH, null, Item.WATCH_TEXT, "", -1);
			break;
		case Item.TYPE:
			break;
		case Item.IF_TEXT:
		case Item.PRINT_TEXT:
			if (checker.parsed!=null || value.strip().length==0) {
				col = col==Item.IF_TEXT ? Item.IF : Item.PRINT;
				store.@set(iter, col, checker.parsed, -1);
			} else {
				store.@set(iter, col, text, -1);
			}
			break; 
		default:
			store.@set(iter, col, value, -1);
			break;
		}
		cell.text = value;
		Breakpoint bp_new = filled_bp(store, iter);
		dg.update_breakpoints(breakpoints(false));
		edited(bp_old, bp_new);
	}
	
	private string do_show_watch(TreeModel model, TreeIter iter, uint col) {
		Gedb.Type* t;
		string val;
		uint8* at;
		uint tid;
		if (col==Item.WATCH_TEXT) {
			WatchInfo? wi;
			store.@get(iter, Item.WATCH, out wi, -1);
			if (wi==null) return "";
			return "%p -> %s".printf(wi.address, wi.append_to());
		} else {
			store.@get(iter, col, out val, -1);
			return val!=null ? val : "";
		}
	}
	
	private void treat_response(int reason, Gee.List<Breakpoint>? match,
								StackFrame* frame, uint mc) { 
		var sel = view.get_selection();
		sel.unselect_all();
		if (match==null) return;
		view.model.@foreach((m,p,i) => { 
				Breakpoint bp0 = null;
				uint id, n = match.size;
				m.@get(i, Item.ID, out id, -1);
				foreach (var bp in match) {
					if (bp.id==id) {
						sel.select_iter(i); 
						bp0 = bp;
						set_breakpoint(bp, i);
						--n;
						break;
					}
				}
				if (n==0 && bp0!=null) { 
					view.scroll_to_cell(p, view.get_column(0), false, 0, 0); 
				}
				return n==0;
			});
	}

	private void do_set_sensitive(bool is_running) { 
		set_deep_sensitive(this, !is_running);
	}

	public BreakPart(Driver dg, DataPart d, Status st, 
					 ListStore types, Gee.Map<string,Expression> aliases) {
		this.dg = dg;
		data = d;
		status = st;
		type_list = types;
		this.aliases = aliases;
		orientation = Orientation.VERTICAL;

		view = new TreeView();
		TreeSelection sel = view.get_selection();
		sel.mode = SelectionMode.MULTIPLE;
		view.headers_visible = true;

		store = new ListStore(Item.NUM_COLS, 
							  typeof(uint),			// id
							  typeof(uint),			// catch
							  typeof(string),		// at
							  typeof(uint),			// class 
							  typeof(uint),			// pos
							  typeof(uint),			// depth
							  typeof(bool),			// pp
							  typeof(WatchInfo?),	// watch
							  typeof(string),		// watch_text
							  typeof(string),		// type
							  typeof(uint),			// type_id 
							  typeof(Expression?),	// if
							  typeof(string),		// if_text
							  typeof(Expression?),	// print
							  typeof(string),		// print_text
							  typeof(bool),			// cont
							  typeof(bool));		// disabled
		view.set_model(store);
		view.set_search_column(Item.AT);
		
		TreeViewColumn col;
		{ /* "ID" column */
			CellRendererText cell = new CellRendererText();
			col = new TreeViewColumn.with_attributes("", cell,
													 "text", Item.ID, null);
			cell.strikethrough = true;
			cell.editable = false;
			cell.set_alignment(1.0F, 0.5F);
			col.set_data<uint>("column", Item.ID);
			col.set_sort_column_id(Item.ID);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_min_width(20);
			view.append_column(col);
		}
		{ /* "Cont" column */
			ListStore submodel = new ListStore(1, typeof(string));
			CellRendererCombo cell = new CellRendererCombo();
			TreeIter iter;
			cell.strikethrough = true;
			cell.model = submodel;
			cell.text_column = 0;
			cell.has_entry = false;
			cell.editable = true;
			cell.set_data<uint>("column", Item.CONT);
			submodel.append(out iter);
			submodel.@set(iter, 0, "Breakpoint", -1);
			submodel.append(out iter);
			submodel.@set(iter, 0, "Tracepoint", -1);
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			col = new TreeViewColumn.with_attributes(" ", cell, 
													 "text", Item.CONT, null);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_cell_data_func(cell, 
								   (l,r,m,i) => do_format_boolean(r,m,i,'c'));
			col.set_min_width(20);
			view.append_column(col);
		}
		{ /* "Catch" column */
			CellRendererCombo cell = new CellRendererCombo(); 
			ListStore submodel = new ListStore(1, typeof(string));
			TreeIter iter;
			string? str;
			cell.strikethrough = true;
			cell.model = submodel;
			cell.text_column = 0;
			cell.has_entry = false;
			cell.editable = true;
			cell.set_data<uint>("column", Item.CATCH);
			for (uint i=Breakpoint.catch_codes_count(); i-->0;) {
				str = Breakpoint.short_name_of_catch(i);
				if (str!=null) {
					submodel.prepend(out iter);
					submodel.@set(iter, 0, str, -1);
				}
			}
			submodel.prepend(out iter);
			submodel.@set(iter, 0, "", -1);
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			col = new TreeViewColumn.with_attributes("Catch", cell, 
													 "text", Item.CATCH, null);
			col.set_sort_column_id(Item.ID);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_cell_data_func(cell, 
								   (l,r,m,i) => do_format_catch(r,m,i));
			col.set_min_width(20);
			view.append_column(col);
		}
		{/* "At" column */
			CellRendererCombo cell = new CellRendererCombo(); 
			ListStore submodel = new ListStore(1, typeof(string));
			TreeIter iter;
			cell.ellipsize = Pango.EllipsizeMode.MIDDLE;
			cell.strikethrough = true;
			cell.model = submodel;
			cell.text_column = 0;
			cell.has_entry = false;
			cell.editable = true;
			cell.set_data<uint>("column", Item.AT);
			submodel.append(out iter);
			submodel.@set(iter, 0, "set from source", -1);
			submodel.append(out iter);
			submodel.@set(iter, 0, "clear", -1);
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			col = new TreeViewColumn.with_attributes("At", cell, 
													 "text", Item.AT, null);
			col.set_data<uint>("column", Item.AT);
			col.set_sort_column_id(Item.AT);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_min_width(80);
			col.set_resizable(true);
			// col.set_expand(true);
			view.append_column(col);
		}
		{ /* "Depth" column */
			CellRendererSpin cell = new CellRendererSpin();
			Adjustment *adj = new Adjustment(0.0, 0.0, 1000.0, 1.0, 10.0, 0.0);
			cell.strikethrough = true;
			cell.adjustment = adj;
			cell.climb_rate = 10.0; 
			cell.digits = 0;
			cell.editable = true; 
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			cell.set_data<uint>("column", Item.DEPTH);
			col = new TreeViewColumn.with_attributes("Depth", cell, 
													 "text", Item.DEPTH, null);
			col.set_sort_column_id(Item.DEPTH);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_min_width(60);
			col.set_resizable(true);
			// col.set_expand(true);
			view.append_column(col);
			/*
			 CellRenderer pp_cell; 
			  gtk_tree_view_column_pack_end(depth, pp_cell, FALSE);
			  gtk_tree_view_column_set_cell_data_func(depth, pp_cell, do_format_boolean, 
			  GINT_TO_POINTER('p'), NULL);
			  gtk_tree_view_column_add_attribute(depth, pp_cell, 
			  "strikethrough-set", DISABLED);
			*/
		}
		{/* "Watch" column */
			CellRendererCombo cell = new CellRendererCombo(); 
			ListStore submodel = new ListStore(1, typeof(string));
			TreeIter iter;
			cell.strikethrough = true;
			cell.model = submodel;
			cell.text_column = 0;
			cell.has_entry = false;
			cell.editable = true;
			cell.set_data<uint>("column", Item.WATCH_TEXT);
			submodel.append(out iter);
			submodel.@set(iter, 0, "set from data", -1);
			submodel.append(out iter);
			submodel.@set(iter, 0, "clear", -1);
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			col = new TreeViewColumn.with_attributes("Watch", cell, 
				"text", Item.WATCH_TEXT, null);
			col.set_cell_data_func(cell,
				(l,r,m,i) => do_format_watch(r,m,i));
			col.set_data<uint>("column", Item.WATCH_TEXT);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_min_width(50);
			view.append_column(col);
		}
		{ /* "Type" column */
			CellRendererText cell = new CellRendererText();	
			cell.ellipsize = Pango.EllipsizeMode.MIDDLE;
			cell.strikethrough = true;
			cell.editable = true;
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			cell.set_data<uint>("column", Item.TYPE);
			col = new TreeViewColumn.with_attributes("Type", cell, 
													 "text", Item.TYPE, null);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_data<uint>("column", Item.TYPE);
			col.set_min_width(100);
			col.set_resizable(true);
			col.set_expand(true);
			col.set_sort_column_id(Item.TYPE);
			view.append_column(col);
		}
		{ /* "If" column */
			CellRendererText cell = new CellRendererText();
			cell.strikethrough = true;
			cell.editable = true;
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			cell.set_data<uint>("column", Item.IF_TEXT);
			col = new TreeViewColumn.with_attributes("If", cell, 
				"text", Item.IF_TEXT, null);
			col.set_cell_data_func(cell, 
				(l,r,m,i) => do_format_expr(r,m,i,Item.IF));
			col.set_data<uint>("column", Item.IF_TEXT);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_min_width(40);
			col.set_resizable(true);
			// col.set_expand(true);
			view.append_column(col);
		}
		{ /* "Print" column */
			CellRendererText cell = new CellRendererText();
			cell.ellipsize = Pango.EllipsizeMode.MIDDLE;
			cell.strikethrough = true;
			cell.editable = true;
			cell.editing_started.connect(do_pre_edit);
			cell.edited.connect(do_post_edit);
			cell.set_data<uint>("column", Item.PRINT_TEXT);
			col = new TreeViewColumn.with_attributes("Print", cell, 
				"text", Item.PRINT_TEXT, null);
			col.set_cell_data_func(cell, 
				(l,r,m,i) => do_format_expr(r,m,i,Item.PRINT));
			col.set_data<uint>("column", Item.PRINT_TEXT);
			col.add_attribute(cell, "strikethrough-set", Item.DISABLED);
			col.set_min_width(40);
			col.set_resizable(true);
			// col.set_expand(true);
			view.append_column(col);

		}

		ScrolledWindow scroll = new ScrolledWindow(null, null);
		pack_start(scroll, true, true, 3);
		scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.ALWAYS);
		scroll.@add(view);
		scroll.set_min_content_height(125);
		
		checker = new ExpressionChecker();
		pack_start(checker);
		
		Box box = new Box(Orientation.HORIZONTAL, 0);
		pack_end(box);
		ButtonBox buttons = new ButtonBox(Orientation.HORIZONTAL);
		box.pack_start(buttons, true, true, 0);
		buttons.set_layout(ButtonBoxStyle.END);
		Button button;
		button = new Button.with_label("New");
		buttons.@add(button);
		buttons.set_child_secondary(button, true);
		button.set_tooltip_text("Button a new breakpoint.");
		button.has_tooltip = true;
		button.clicked.connect(() => { do_create(); });
		button = new Button.with_label("Enable");
		buttons.@add(button);
		button.set_tooltip_text("Enable selected breakpoints.");
		button.has_tooltip = true;
		button.clicked.connect(() => { do_manage(Action.ENABLE); });
		button = new Button.with_label("Disable");
		buttons.@add(button);
		button.set_tooltip_text("Disable selected breakpoints.");
		button.has_tooltip = true;
		button.clicked.connect(() => { do_manage(Action.DISABLE); });
		button = new Button.with_label("Delete");
		buttons.@add(button);
		button.set_tooltip_text("Delete selected breakpoints.");
		button.has_tooltip = true;
		button.clicked.connect(() => { do_manage(Action.KILL); });
		debug = new CheckButton.with_label("Debug clauses");
		box.pack_end(debug);
		debug.set_tooltip_text(
"""Are debug clauses to be
treated as breakpoints?""");
		debug.clicked.connect((b) => { do_debug(b); });
		
		Gee.List<uint> list = new Gee.ArrayList<uint>();
		list.@add(Item.AT);
		list.@add(Item.WATCH_TEXT);
		list.@add(Item.TYPE);
		list.@add(Item.IF_TEXT);
		list.@add(Item.PRINT_TEXT);
		view.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;
		view.events |= Gdk.EventMask.BUTTON_PRESS_MASK;
		view.button_press_event.connect(do_button);
		view.enter_notify_event.connect((ev) =>
			{ view.has_focus=true; return false; });
		view.motion_notify_event.connect((ev) => 
			{ return status.set_long_string(ev, view, list, do_show_watch); });
		view.leave_notify_event.connect((ev) =>
			{ return status.remove_long_string(); });
		dg.response.connect(treat_response);
		dg.new_executable.connect((g) => { store.clear(); });
		dg.response.connect(treat_response);
		dg.notify["is-running"].connect(
			(g,p) => { do_set_sensitive(dg.is_running); });
	}
	
	public Gee.ArrayList<Breakpoint> breakpoints(bool all) {
		var list = new Gee.ArrayList<Breakpoint>();
		store.foreach((m,p,i) => { return fill_bp_in_list(m,i,all,list); });
		return list;
	}
	
	private bool fill_bp_in_list(TreeModel model, TreeIter iter, bool all,
								 Gee.List<Breakpoint> list) {
		uint id;
		bool dis;
		model.@get(iter, Item.DISABLED, out dis, Item.ID, out id, -1);
		if (all || !dis) {
			Breakpoint bp = filled_bp(model, iter);
			list.@add(bp);
		}
		return false;
	}
	
	public void add_breakpoint(Breakpoint bp) {
		TreeIter iter;
		store.append(out iter);
		set_breakpoint(bp, iter);
	}
	
	private void set_breakpoint(Breakpoint bp, TreeIter iter) {
		ClassText* cls = null;
		string at, type;
		if (bp.pos>0) {
			cls = dg.rts.class_at(bp.cid);
			at = cls._name.fast_name;
			at = "%s:%d:%d".printf(at, (int)(bp.pos/256), (int)(bp.pos%256));
		} else {
			at = "";
		}
		type = bp.tid>0 ? dg.rts.type_at(bp.tid)._name.fast_name : "";
		store.@set(iter,
				   Item.ID, bp.id,
				   Item.CATCH, bp.exc,
				   Item.AT, at, 
				   Item.CLS, bp.cid,
				   Item.POS, bp.pos,
				   Item.DEPTH, bp.depth,
				   Item.PP, bp.pp,
				   Item.WATCH, bp.watch,
				   Item.WATCH_TEXT, bp.watch!=null ? bp.watch.append_to() : "",
				   Item.TYPE, type,
				   Item.TYPE_ID, bp.tid,
				   Item.IF, bp.iff,
				   Item.IF_TEXT, bp.iff!=null ? bp.iff.append_name() : "",
				   Item.PRINT, bp.print,
				   Item.PRINT_TEXT, bp.print!=null ? bp.print.append_name() : "",
				   Item.CONT, bp.cont,
				   Item.DISABLED, !bp.enabled,
				  -1);
		if (bp.enabled) {
			Gee.List<Breakpoint> list = breakpoints(false);
			dg.update_breakpoints(list);
			set_changed(list);
		}
	}
	
	public void set_debug_clause(bool yes) { debug.active = yes; }

	public void update_by_list(Gee.List<Breakpoint> list) {
		Gee.ListIterator<Breakpoint> iter;
		Breakpoint bp;
		TreeIter at;
		int id;
		int n = list.size;
		if (store.get_iter_first(out at)) {
			do {
				store.@get(at, Item.ID, out id, -1);
				for (iter=list.list_iterator(); iter.next();) {
					bp = iter.@get();
					if (bp.id==id) {
						if (bp.depth>0) 
							store.@set(at, Item.DEPTH, bp.depth, -1);
						if (bp.watch!=null) {
							if (bp.watch.address!=null) {
								store.@set(at, Item.WATCH, bp.watch, 
										   Item.WATCH_TEXT, bp.watch.append_to(), -1);
							} else {
								store.@set(at, Item.WATCH, null, -1);
							}
						}
						--n;
						if (n==0)  return;
						break;
					}
				}
			} while (store.iter_next(ref at));
		}

	}

	public void kill_breakpoint(uint cid, uint pos) {
		Breakpoint bp;
		Gee.List<Breakpoint> list = breakpoints(true);
		Gee.ArrayList<int> ids = null;
		Gee.ListIterator<Breakpoint> iter;
		for (iter=list.list_iterator(); iter.next();) {
			 bp = iter.@get();
			 if (bp.pos==pos && bp.cid==cid) {
				 ids = new Gee.ArrayList<int>();
				 ids.@add((int)bp.id);
				 break;
			 }
		}
		if (ids!=null)  kill_breakpoints(ids);
	}

	public signal void edited(Breakpoint old_bp, Breakpoint new_bp);
	public signal void set_changed(Gee.List<Breakpoint> list);
}