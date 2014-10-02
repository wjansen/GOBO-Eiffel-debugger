using Gtk;
using Gedb;

public class SqlPart : Window {

	private ListStore type_list;

	private Debuggee dg;
	private DataPart data;

	private Entry select;
	private Entry from;
	private Entry where;
	private Label count;
	private ScrolledWindow scroll;
	private TreeView view;
	private ListStore store;
	private CellRendererText left_cell;
	private CellRendererText right_cell;
	private ExpressionChecker checker;

	private Button update;

	private StackFrame* frame;
	private NormalType* type;
	private TextExpression expr;
	private Gee.Map<string,Expression> aliases;
	private Expression cond;
	private Expression[] flat;
	private uint[] ident_col;
	public bool obsolete { get; private set; }

	private void build_view() {
		Entity* f;
		TreeViewColumn col;
		TreeIter iter;
		GLib.Type[] mcs;
		int sum_width;
		uint i, n;
		string text;
		bool ok;
		ok = select_history.list.get_iter_first(out iter);
		if (ok) {
			select_history.list.@get(iter, 0, out text, -1);
			var e = select_history.get_child() as Entry;
			e.text = text;
		}
		ok = where_history.list.get_iter_first(out iter);
		if (ok) {
			where_history.list.@get(iter, 0, out text, -1);
			var e = where_history.get_child() as Entry;
			e.text = text;
		}
		for (i=view.get_n_columns(); i-->1;) {
			col = view.get_column((int)i);
			view.remove_column(col);
		}
		if (expr==null) {
			n = ((Gedb.Type*)type).field_count();
			TextExpression next;
			Expression? last = null;
			for (i=0; i<n; ++i) {
				f = (Entity*)((Gedb.Type*)type).field_at(i);
				next = new TextExpression.typed(f);
				if (expr==null) expr = next;
				else last.set_child(last.Child.NEXT, next);
				last = next; 
			}
		}
		flat = {expr};
		mcs = {typeof(uint)};
		ident_col = {0};
		if (expr!=null) mcs = flat_types(expr, mcs);
		store = new ListStore.newv(mcs);
		store.set_sort_column_id(0, SortType.ASCENDING);
		view.set_model(store);
		var cell = right_cell;
		col = new TreeViewColumn.with_attributes("", cell, "text", 0, null);
		col.resizable = true;
		col.expand = true;
		col.set_sort_column_id(0);
		col.set_cell_data_func(cell, do_format_id);
		sum_width = 50 + flat_build(mcs);
		var screen = get_screen();
		int w = (int)(0.9*screen.width());
		w = int.min(sum_width, w);
		scroll.set_min_content_width(w);
		obsolete = false;
	}		

	private GLib.Type[] flat_subobject_type(Expression ex, GLib.Type[] types) 
	requires (ex.dynamic_type!=null && ex.dynamic_type.is_subobject()) {
		GLib.Type[] mcs = types[0:types.length];
		Expression sub;
		Gedb.Type* t = ex.dynamic_type;
		Field* f;
		string name;
		string prefix = @"$(ex.top().append_qualified_name())";
		uint n = t.field_count();
		for (uint i=0; i<n; ++i) {
			f = t.fields[i];
			name = prefix + ((Gedb.Name*)f).fast_name;
			sub = new AliasExpression(prefix, ex);
			sub.set_child(sub.Child.DOWN,
						  new TextExpression.typed((Entity*)f));
			mcs = flat_types(sub, mcs);
		}
		return mcs;
	}
	
	private GLib.Type[] flat_types(Expression ex, GLib.Type[] types) {
		Expression? next;
		Expression exb = ex;
		Gedb.Type* t;
		GLib.Type mc = typeof(void*);
		GLib.Type[] mcs = types[0:types.length];
		uint i = types.length;
		for (next=ex; next!=null; next=next.next) {
			exb = next.bottom();
			t = exb.dynamic_type;
			if (t.is_basic()) {
				switch (t.ident) {
				case TypeIdent.BOOLEAN:
					mc = typeof(bool);
					break;
				case TypeIdent.CHARACTER_8:
				case TypeIdent.CHARACTER_32:
					mc = typeof(unichar);
					break;
				case TypeIdent.INTEGER_8:
				case TypeIdent.INTEGER_16:
				case TypeIdent.INTEGER_32:
				case TypeIdent.INTEGER_64:
					mc = typeof(int64);
					break;
				case TypeIdent.NATURAL_8:
				case TypeIdent.NATURAL_16:
				case TypeIdent.NATURAL_32:
				case TypeIdent.NATURAL_64:
					mc = typeof(uint64);
					break;
				case TypeIdent.REAL_32:
					mc = typeof(float);
					break;
				case TypeIdent.REAL_64:
					mc = typeof(double);
					break;
				case TypeIdent.POINTER:
					mc = typeof(string);
					break;
				}
				mcs += mc;
				flat += next;
				++i;
			} else if (t.is_subobject()) {
				mcs = flat_subobject_type(exb, mcs);
				i = mcs.length;
			} else {
				ident_col += i;
				mcs += typeof(uint);
				flat += next;
				++i;
			}
			if (exb.detail!=null) {
				mcs = flat_types(exb.detail, mcs);
			}
		}
		return mcs;
	}

	private int flat_build(GLib.Type[] types) 
	requires (types.length==flat.length) {
		Expression? next;
		Expression ex;
		Gedb.Type* t;
		TreeViewColumn? col = null;
		CellRendererText? cell = null;
		Label label;
		string header;
		int width = 0, sum_width = 0;
		uint i, n = types.length;
		for (i=1; i<n; ++i) {
			ex = flat[i].bottom();
			t = ex.dynamic_type;
			header = ex.top().append_qualified_name(null, ex);
			if (t.is_basic()) {
				switch (t.ident) {
				case TypeIdent.BOOLEAN:
					cell = left_cell;
					width = 50;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
					col.set_cell_data_func(cell, do_format_bool);
					break;
				case TypeIdent.CHARACTER_8:
				case TypeIdent.CHARACTER_32:
					cell = left_cell;
					width = 20;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
					break;
				case TypeIdent.INTEGER_8:
				case TypeIdent.INTEGER_16:
				case TypeIdent.INTEGER_32:
				case TypeIdent.INTEGER_64:
					cell = right_cell;
					width = 50;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
					break;
				case TypeIdent.NATURAL_8:
				case TypeIdent.NATURAL_16:
				case TypeIdent.NATURAL_32:
				case TypeIdent.NATURAL_64:
					cell = right_cell;
					width = 50;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
					break;
				case TypeIdent.REAL_32:
					cell = right_cell;
					width = 80;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
						col.set_cell_data_func(cell, (l,c,m,i) => 
							{ do_format_real(l,c,i,false);} );
					break;
				case TypeIdent.REAL_64:
					cell = right_cell;
					width = 120;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
					col.set_cell_data_func(cell, (l,c,m,i) => 
						{ do_format_real(l,c,i,true);} );
					break;
				case TypeIdent.POINTER:
					cell = right_cell;
					width = 60;
					col = new TreeViewColumn.with_attributes
						(header, cell, "text", i, null);
					break;
				}
			} else {
				cell = right_cell;
				width = +50;
				col = new TreeViewColumn.with_attributes
					(header, cell, "text", i, null);
				col.set_cell_data_func(cell, do_format_id);
			}
			cell.ellipsize = Pango.EllipsizeMode.START;
			col.set_resizable(true);
			col.set_expand(true);
			col.set_sort_column_id((int)i);
			col.set_data<uint>("column", i);
			label = new Label(header); 
			col.set_widget(label);
			label.set_tooltip_text(header + ":\n" + t.class_name);
			label.has_tooltip = true;
			label.show();
			col.max_width = width;
			sum_width += width;
			view.append_column(col);
		}
		return sum_width;
	}

	private bool is_normal(Gedb.Type* t) {
		return !t.is_subobject() && t.is_alive(); 
	}

	private bool do_type(TreeModel m, TreeIter at) {
		NormalType* old = type;
		uint tid = 0;
		bool ok;
		if (dg.rts==null)  return false;
		m.@get(at, TypeEnum.TYPE_IDENT, out tid);
		Gedb.Type* t = dg.rts.type_at(tid);
		ok = t!=null && t.is_normal() && !t.is_subobject();
		if (ok)  type = (NormalType*) t;
		from.set_text(ok ? ((Gedb.Name*)type).fast_name : "");
		obsolete |= type!=old;
		return true;
	}

	private void do_check_expression(HistoryBox h, bool as_cond) {
		checker.reset();
		if (type==null) return;
		var e = h.get_child() as Entry;
		string str = e.get_text();
		if (str.strip().length==0) return; 
		bool ok = checker.check_static(str, 
			((Gedb.Type*)type).ident, type.base_class.ident, 
			0, aliases, dg.rts, as_cond);
		if (!ok) return;
		var ex = (!) checker.parsed;
		if (as_cond) cond = ex;
		else expr = ex as TextExpression;
		h.add_item(ex.append_name(), false);
		obsolete = true;
	}

	private void do_refresh(StackFrame* f) {
		frame = f;
		if (f==null) {
			if (store!=null) store.clear();
			return;
		}
		if (type!=null) {
			data.refill_known_objects();
			do_update();
		}
	}

	private void do_update() {
		if (type==null) return;
		Gedb.Type* t;
		TreeIter at;
		string str;
		uint8* obj;
		uint od;
		int n = 0;
		if (store!=null) store.clear();
		if (obsolete) build_view();
		data.refill_known_objects();
		Gee.HashMap<void*,uint> ko = data.known_objects;
		Gee.MapIterator<void*,uint> iter;
		for (iter = ko.map_iterator(); iter.next();) {
			obj = iter.get_key();
			od = iter.get_value();
			t = dg.rts.type_of_any(obj, (Gedb.Type*)type);
			if (t!=(Gedb.Type*)type) continue;
			try {
				if (cond!=null) {
					cond.compute_in_object(null, t, dg.rts, frame, obj);
					var bottom = cond.bottom();
					if (bottom.address()==null) {
						// issue message
						continue;
					}
					if (bottom.dynamic_type==null 
						|| bottom.dynamic_type.ident!=TypeIdent.BOOLEAN) {
						// issue message
						continue;
					}
					if (!bottom.as_bool())  continue;
				}
				uint k = flat.length;
				if (expr!=null) 
					expr.compute_in_object(null, t, dg.rts, frame, obj);
				for (uint i=1; i<k; ++i) {
					var ex = flat[i];
					if (ex!=expr && ex.parent==null)
						ex.compute_in_object(null, t, dg.rts, frame, obj);
				}
			} catch (ExpressionError err) {
			// issue message
				stderr.printf("%s\n", err.message);
				continue;
			}
			++n;
			store.append(out at);
			str = "_%d".printf((int)od);
			store.@set(at, 0, od, -1);
			update_flat(at);
		}
		count.set_text(@"$n");
		var screen = get_screen();
		int h = (int)(0.5*screen.height());
		scroll.set_min_content_height(int.min(n*24+30,h));
	}

	private void update_flat(TreeIter at) {
		Gedb.Type* t;
		Expression ex;
		uint8* obj, addr;
		string str;
		uint j, n = flat.length;
		uint od;
		Gee.HashMap<void*,uint> ko = data.known_objects;
		for (j=1; j<n; ++j) {
			ex = flat[j].bottom();
			addr = ex.address();
			if (addr==null) {
				store.@set(at, j, 0, -1);
			} else {
				t = ex.dynamic_type;
				if (t.is_basic()) {
					switch (t.ident) {
					case TypeIdent.BOOLEAN:
						store.@set(at, j, ex.as_bool(), -1);
						break;
					case TypeIdent.CHARACTER_8:
						store.@set(at, j, ex.as_char(), -1);
						break;
					case TypeIdent.CHARACTER_32:
						store.@set(at, j, ex.as_unichar(), -1);
						break;
					case TypeIdent.INTEGER_8:
					case TypeIdent.INTEGER_16:
					case TypeIdent.INTEGER_32:
						store.@set(at, j, (int64)ex.as_int(), -1);
						break;
					case TypeIdent.INTEGER_64:
						store.@set(at, j, ex.as_long(), -1);
						break;
					case TypeIdent.NATURAL_8:
					case TypeIdent.NATURAL_16:
					case TypeIdent.NATURAL_32:
						store.@set(at, j, (uint64)ex.as_uint(), -1);
						break;
					case TypeIdent.NATURAL_64:
						store.@set(at, j, ex.as_ulong(), -1);
						break;
					case TypeIdent.REAL_32:
						store.@set(at, j, ex.as_float(), -1);
						break;
					case TypeIdent.REAL_64:
						store.@set(at, j, ex.as_double(), -1);
						break;
					case TypeIdent.POINTER:
						void* p = ex.as_pointer();
						if (p!=null) p = *(void**)p;
						str = p!=null ? "%p".printf(p) : "0x0";
						store.@set(at, j, str, -1);
						break;
					}
				} else {
					od = ko.contains(addr) ? ko.@get(addr) : -1;
					store.@set(at, j, od, -1);
				}
			} 
		}
	}

	private void do_format_id(CellLayout layout, CellRenderer cell,
							  TreeModel model, TreeIter iter) {
		var ct = cell as CellRendererText;
		var col = layout as TreeViewColumn;
		int id=0;
		int col_id = col.sort_column_id;
		store.@get(iter, col_id, out id, -1);
		if (id<0)  ct.text = "_?";
		else  ct.text = "_%d".printf(id);
	}

	private void do_format_bool(CellLayout layout, CellRenderer cell,
							  TreeModel model, TreeIter iter) {
		var ct = cell as CellRendererText;
		var col = layout as TreeViewColumn;
		bool b=false;
		store.@get(iter, col.sort_column_id, out b, -1);
		ct.text = b ? "True" : "False";
	}

	private void do_format_real(CellLayout layout, CellRenderer cell,
								TreeIter iter, bool wide) {
		var ct = cell as CellRendererText;
		var col = layout as TreeViewColumn;
		float f;
		double d;
		if (wide) {
			store.@get(iter, col.sort_column_id, out d, -1);
			ct.text = "%#15.8g".printf(d);
		} else {
			store.@get(iter, col.sort_column_id, out f, -1);
			d = f;
			ct.text = "%#11.5g".printf(d);
		}
	}

	private bool do_button(Gdk.EventButton e) {
		if (e.button!=3)  return false;
		TreePath path;
		TreeIter iter;
		TreeViewColumn col;
		int i, n, x, y;
		
		view.get_path_at_pos((int)e.x, (int)e.y, 
							 out path, out col, out x, out y);
		if (path==null)  return true;
		store.get_iter(out iter, path);
		n = col.sort_column_id;
		if (n>0) {
			for (i=ident_col.length; i-->0;) {
				if (ident_col[i]==n)  break;
				if (ident_col[i]<n)  return false;
			}
		}
		store.@get(iter, n, out i, -1);
		if (i==0)  return true;
		var menu = new FeatureMenu(data.deep_info[i], data, 0, dg.rts);
		menu.popup(null, null, null, e.button, e.time);
		return true;
	}

	private bool do_close() { 
		hide(); 
		if (store!=null) store.clear();
		return true; 
	}

	private string do_deep(TreeModel model, TreeIter at, uint col) {
		int id = 0;
		for (id=ident_col.length; id-->0;) {
			if (ident_col[id]==col)  break;
		}
		if (id<0) return "";
		store.@get(at, col, out id, -1);
		return id<=0 ? "" : data.dotted_name(data.deep_info[id]);
	}

	private void do_new_exe(Debuggee dg) {
		where_history.clear();
		select_history.clear();
	}
	
	public SqlPart(Debuggee dg, StackPart stack, DataPart data, Status status,
				   ListStore types, Gee.Map<string,Expression> list) {
		this.dg = dg;
		this.data = data;
		type_list = types;
		aliases = list;

		title = compose_title("SQL", dg.rts);
		left_cell = new CellRendererText();
		right_cell = new CellRendererText();
		right_cell.set_alignment(1.0F, 0.5F);

		Box box = new Box(Orientation.VERTICAL, 3);
		add(box);
		var hbox = new Box(Orientation.HORIZONTAL, 3);
		box.pack_start(hbox, false, false, 0);
		hbox.pack_start(new Label("Count: "), false, false, 0);
		count = new Label("");
		hbox.pack_start(count, false, false, 0);

		scroll = new ScrolledWindow(null, null);
		scroll.set_policy(PolicyType.AUTOMATIC,PolicyType.AUTOMATIC);
		box.pack_start(scroll, true, true, 0);
		view = new TreeView();
		scroll.@add(view);
		view.headers_visible = true;
		view.reorderable = true;
		TreeViewColumn col = new TreeViewColumn.with_attributes
			("", right_cell, "text", 0, null);
		col.set_sort_column_id(0);
		col.set_data<uint>("column", 0);
		col.set_cell_data_func(right_cell, do_format_id);
		view.append_column(col);


		Grid grid = new Grid();
		box.pack_start(grid, false, false, 0);
		grid.margin = 5;

		Label label = new Label("select ");
		grid.attach(label, 0, 0, 1, 1);
		label.halign = Align.START;
		select_history = new HistoryBox("SQL select");
		grid.attach(select_history, 1, 0, 1, 1);
		select_history.selected.connect(
			(h) => { do_check_expression(select_history, false); });
		select = select_history.get_child() as Entry;
		select.hexpand = true;
		select.editable = true;
		select.placeholder_text = "Expression list";
		select.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.CLEAR);
		select.icon_release.connect((e) => 
			{ select.set_text("");  select.grab_focus(); });
		select.activate.connect(
			(e) => { do_check_expression(select_history, false); });
		label = new Label("from ");
		grid.attach(label, 0, 1, 1, 1);
		label.halign = Align.START;
		from = new Entry();
		grid.attach(from, 1, 1, 1, 1);
		from.hexpand = true;
		from.editable = true;
		from.placeholder_text = "Type name";
		from.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.CLEAR);
		from.icon_release.connect((e) => 
			{ from.set_text("");  from.grab_focus(); });
		EntryCompletion compl = new EntryCompletion();
		from.set_completion(compl);
		compl.set_model(type_list);
		compl.set_text_column(TypeEnum.TYPE_NAME);
        compl.set_match_func((c,k,i) => 
			{ return checker.do_filter_type_name(c,k,i,dg.rts,is_normal); });
		int n = type_list.iter_n_children(null);
		n = n>1 ? (int)(Math.log2(n)/3.0) : 0;
		compl.set_minimum_key_length(n);
		compl.match_selected.connect((c,m,i) => { return do_type(m,i); });

		label = new Label("where ");
		grid.attach(label, 0, 2, 1, 1);
		label.halign = Align.START;
		where_history = new HistoryBox("SQL where");
		grid.attach(where_history, 1, 2, 1, 1);
		where_history.selected.connect(
			(h) => { do_check_expression(where_history, true); });
		where = where_history.get_child() as Entry;
		where.hexpand = true;
		where.editable = true;
		where.placeholder_text = "Boolean expression";
		where.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.CLEAR);
		where.activate.connect(
			(e) => { do_check_expression(where_history, true); });
		where.icon_release.connect((e) => 
			{ where.set_text("");  where.grab_focus(); });
		checker = new ExpressionChecker();
		grid.attach(checker, 1, 3, 1, 1);

		hbox = new Box(Orientation.HORIZONTAL, 3);
		box.pack_end(hbox, false, false, 3);
		ButtonBox buttons = new ButtonBox(Orientation.HORIZONTAL);
		buttons.set_layout(ButtonBoxStyle.END);
		hbox.pack_end(buttons, true, true, 0);

		update = new Button.with_label("Update");
		buttons.@add(update);
		update.set_tooltip_text("Perform SQL selection.");
		update.has_tooltip = true;
		update.clicked.connect((b) => { do_update(); });
		Button close = new Button.with_label("Close");
		buttons.@add(close);
		close.set_tooltip_text("Close window.");
		close.has_tooltip = true;
		close.clicked.connect((b) => { do_close(); });
		delete_event.connect((e) => { return do_close(); });

		dg.new_executable.connect((g) => { do_new_exe(g); });
		dg.notify["is-running"].connect(
			(g,p) => { do_set_sensitive(dg.is_running); });
 		stack.level_selected.connect(
			(s,l,i,p) => { do_refresh(s.frame()); });
		view.button_press_event.connect(do_button);
		view.motion_notify_event.connect((ev) => 
			{ return status.set_long_string(ev, view, null, do_deep); });
		view.leave_notify_event.connect((ev) =>
			{ return status.remove_long_string(); });

		obsolete = true;
		notify["obsolete"].connect(
			(t,p) => { update.sensitive = obsolete; });

		do_refresh(stack.frame());
	}

	public HistoryBox where_history { get; private set; }
	public HistoryBox select_history { get; private set; }

	public void do_set_sensitive(bool is_running) {
		select.sensitive = !is_running;
		from.sensitive = !is_running;
		where.sensitive = !is_running;
	}

}
