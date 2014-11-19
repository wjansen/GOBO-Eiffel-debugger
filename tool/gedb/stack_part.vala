using Gtk;
using Gedb;

public class StackPart : Box, AbstractPart {

	private enum Column {
		LEVEL = 0,
		RESCUE,
		CLASS, CLASS_ID, 
		ROUTINE,
		LINE,
		COL,
		VERBOSE,
		POOR,
		NUM_COLS
	}

	Status status;
	
	private static const string rescue_arrow = "↳";	//"►";

	private Debuggee? dg;
	private StackPart? main;
	private Label depth_label;
	private ComboBox? combo;
	private TreeView? view;
	private ListStore store;
	private int depth;
	private bool automatic;
	private bool updated;

	private void set_row(TreeIter iter, int level, uint cid, 
						 string rout, bool rescue, int line, int col) {
		if (dg==null) return;
		ClassText* cls = dg.rts.class_at(cid);
		string name = ((Gedb.Name*)cls).fast_name;
		string str = "%d  %s.%s:%d:%d".printf(level, name, rout, line, col);
		bool poor = cls!=null ? !cls.is_debug_enabled() : true;
		store.@set(iter,
				   Column.LEVEL,    level, 
				   Column.RESCUE,   rescue ? rescue_arrow : " ",
				   Column.CLASS,    name, 
				   Column.CLASS_ID, cid, 
				   Column.ROUTINE,  rout, 
				   Column.LINE,     line, 
				   Column.COL,      col, 
				   Column.VERBOSE,  str,
				   Column.POOR,		poor,
				  -1);
	}

	private void refresh(StackFrame* frame) {
		ClassText* cls;
		RoutineText* rt;
		TreeIter iter;
		string str, name;
		uint pos;
		int old_depth, new_depth, min, i, old_level;
		old_depth = depth;
		TreeSelection sel;
		if (dg==null) return;
		if (main==null) {
			sel = view.get_selection();
			sel.unselect_all();
		} else {
			old_level = combo.get_active();
		}
		new_depth = frame!=null ? frame.depth : 0;
		min = old_depth<new_depth ? old_depth : new_depth;
		depth = new_depth;
		top = new_depth>0 ? frame : null;

		for (i=0, store.get_iter_first(out iter);
			 i<min; 
			 ++i, frame=frame.caller, store.iter_next(ref iter)) {
			cls = dg.rts.class_at(frame.class_id);
			rt = frame.routine.routine_text();
			name = ((Gedb.Name*)rt).fast_name;
			pos = frame.pos;
			set_row(iter, i, cls.ident, name, rt.rescue_pos>0,
					(int)pos/256, (int)pos%256);
		}
		for (; i<new_depth; ++i, frame=frame.caller) {
			cls = dg.rts.class_at(frame.class_id);
			rt = frame.routine.routine_text();
			name = ((Gedb.Name*)rt).fast_name;
			store.append(out iter);
			pos = frame.pos;
			set_row(iter, i, cls.ident, name, rt.rescue_pos>0,
					(int)pos/256, (int)pos%256);
		}
		for (; i<old_depth && store.iter_nth_child(out iter, null, i);)
			store.@remove(iter);
		if (main==null && store.iter_n_children(null)>0) {
			sel = view.get_selection();
			if (store.get_iter_first(out iter)) sel.select_iter(iter);
		} else if (store.get_iter_first(out iter)) {
			combo.set_active_iter(iter);
			combo.changed();
		}
		if (main==null) depth_label.set_text(depth.to_string());
	}
	
	private void do_list_select(TreeSelection sel) {
		TreeModel model=null;
		TreeIter iter;
		int l = sel.count_selected_rows();
		if (l!=1) return;
		sel.get_selected(out model, out iter);
		model.@get(iter, Column.LEVEL, out l, -1);
		this.level = l;
		StackFrame* f;
		for (f=top; f!=null && l>0; --l) f = f.caller;
		if (f!=null) level_selected(f, f.class_id, f.pos);
	}
	
	private void do_row_activated(TreePath path) {
		TreeSelection sel = view.get_selection();
		sel.select_path(path);
		do_list_select(sel);
	}

	private void do_combo_select(ComboBox combo) requires (main!=null) {
		if (top==null) return;
		TreeIter iter;
		int l = combo.get_active();
		this.level = l;
		depth_label.label = @"Level $l:";
		StackFrame* f;
		for (f=top; f!=null && l>0; --l) f = f.caller;
		level_selected(f, f.class_id, f.pos);// !!
	}
	
	private Widget new_list_stack() {
		CellRendererText render_rescue, render_cls, render_rout, render_n;
		TreeViewColumn level, rescue, cls, rout, line, col;
		
		ScrolledWindow scroll = new ScrolledWindow(null, null);
		scroll.set_policy(PolicyType.AUTOMATIC,PolicyType.ALWAYS);
		scroll.set_min_content_height(120);
		
		view = new TreeView.with_model(store);
		scroll.@add(view);
		view.headers_visible = true;

		render_rescue = new CellRendererText();
		render_cls = new CellRendererText();
		render_cls.ellipsize = Pango.EllipsizeMode.MIDDLE;
		render_cls.strikethrough = true;
		render_rout = new CellRendererText();
		render_rout.ellipsize = Pango.EllipsizeMode.MIDDLE;
		render_rout.strikethrough = true;
		render_n = new CellRendererText();
		render_n.set_alignment(1.0F, 0.5F);
		
		rescue = new TreeViewColumn.with_attributes("", render_rescue, "text", 
												   Column.RESCUE, null);
		rescue.set_data<uint>("column", Column.RESCUE);
		rescue.set_min_width(12);
		view.append_column(rescue);

		level = new TreeViewColumn.with_attributes("", render_n, "text", 
												   Column.LEVEL, null);
		level.set_min_width(15);
		view.append_column(level);

		cls = new TreeViewColumn.with_attributes("Class", render_cls, "text", 
												 Column.CLASS, null);
		cls.set_min_width(50);
		cls.resizable = true;
		cls.expand = true;
		cls.add_attribute(render_cls, "strikethrough-set", Column.POOR);
		view.append_column(cls);
		view.set_search_column(Column.CLASS);
		
		rout = new TreeViewColumn.with_attributes("Routine", render_rout, 
												  "text", Column.ROUTINE, null);
		rout.resizable = true;
		rout.expand = true;
		rout.add_attribute(render_rout, "strikethrough-set", Column.POOR);
		view.append_column(rout);
		
		line = new TreeViewColumn.with_attributes("Line", render_n, "text", 
												  Column.LINE, null);
		line.set_min_width(30);
		view.append_column(line);
		
		col = new TreeViewColumn.with_attributes("Col", render_n, "text", 
												 Column.COL, null);
		col.set_min_width(20);
		view.append_column(col);
		
		Gee.List<uint> list = new Gee.ArrayList<uint>();
		list.@add(Column.CLASS);
		list.@add(Column.ROUTINE);
		view.motion_notify_event.connect((ev) =>
			{ return status.set_long_string(ev, view, list); });
		view.leave_notify_event.connect((ev) =>
			{ return status.remove_long_string(); });
		TreeSelection sel = view.get_selection();
		sel.mode = SelectionMode.SINGLE;
		sel.changed.connect(do_list_select);
		view.row_activated.connect((p,c) => { do_row_activated(p); });

		return scroll;
	}

	private void do_set_sensitive(bool is_running) {
		if (main==null) {
			set_deep_sensitive(this, !is_running);
		} else {
			updated &= !is_running;
			combo.sensitive = updated;
		}
	}

	private void core_part() {
		orientation = Orientation.VERTICAL;
		store = new ListStore(Column.NUM_COLS, 
							  typeof(uint),		// level
							  typeof(string),	// rescue
							  typeof(string),	// class
							  typeof(uint),		// class_id
							  typeof(string),	// routine
							  typeof(uint),		// line 
							  typeof(uint),		// col
							  typeof(string),	// verbose
							  typeof(bool));	// poor
	}

	public StackPart.additionally(Debuggee dg, StackPart main) { 
		this.main = main;
		set_debuggee(dg);
		status = main.status;
		view = null;
		core_part();
		var box = new Box(Orientation.HORIZONTAL, 5);
		depth_label = new Label("");
		depth_label.width_chars = 5;
		depth_label.justify = Justification.RIGHT;
		depth_label.halign = Align.END;
		depth_label.tooltip_text = "Stack level.";
		box.pack_start(depth_label, false, false, 0);
		combo = new ComboBox.with_model_and_entry(store);
		box.pack_end(combo, true, true, 0);
		Entry entry = combo.get_child() as Entry;
		entry.editable = false; 
		combo.set_id_column(Column.CLASS);
		combo.set_entry_text_column(Column.VERBOSE);
		combo.set_tooltip_text("Choose call stack level form list.");
		combo.has_tooltip = true;
		combo.changed.connect((c) => { do_combo_select(c); });
		top = main.top;
		GLib.Idle.@add(() => { refresh(top); return false; });
		@add(box);
	}
	
	public StackPart(Status s) { 
		status = s;
		main = null;
		combo = null;
		var hbox = new Box(Orientation.HORIZONTAL, 3);
		pack_start(hbox, false, false, 0);
		hbox.pack_start(new Label("Depth: "), false, false, 0);
		depth_label = new Label("");
		hbox.pack_start(depth_label, false, false, 0);
		core_part();
		pack_start(new_list_stack(), true, true, 0);
	}

	public int level { get; private set; }

	public StackFrame* top { get; private set; }

	public StackFrame* frame() {
		StackFrame* frame = top;
		int l = level;
		if (l<0) return frame;
		for (; frame!=null && l>0; --l) frame = frame.caller;
		return frame;
	}
	
	public void update() {
		updated = true;
		if (main!=null && !automatic) {
			refresh(top);
			combo.sensitive = true;
		}
	}
	
	public void update_policy(ToggleButton toggle) {
		bool active = toggle.get_active();
		toggle.set_label(active ? "automatic" : "manually");
		if (active && !automatic) update();
		automatic = active;
	}

	private void do_refresh(int reason) { 
		if (main!=null && !automatic || dg==null) return;
		Driver? dr = dg as Driver;
		if (dr!=null && reason==dr.ProgramState.Running) return;
		StackFrame* f = dg.frame();
		refresh(f);
		level = 0;
	}
	
	public bool has_frame(StackFrame* f) {
		StackFrame* sf;
		for (sf=top; sf!=null; sf=sf.caller) {
			if (sf==f) return true;
		}
		return false;
	}

	public StackFrame* frame_of_class(uint cid) {
		StackFrame* f = top;
		TreeIter iter;
		uint id;
		if (store.get_iter_first(out iter)) {
			while (f!=null && store.iter_next(ref iter)) {
				store.@get(iter, Column.CLASS_ID, out id, -1);
				if (id==cid) return f;
				f = f.caller;
			} 
		}
		return null;
	}

	public void set_debuggee(Debuggee? dg) { 
		this.dg = dg; 
		top = null;
		level = 0;
		if (dg!=null) {
			dg.response.connect((dg,r,m,f,mc) => { do_refresh(r); });
			dg.notify["is-running"].connect(
				(g,p) => { do_set_sensitive(dg.is_running); });
		}
	}

	public signal void level_selected (StackFrame* f, uint cid, uint pos);
}
