using Gtk;
using Gedb;

internal class SqlQuery {

	private static System* rts;

	internal static Gee.List<Expression> prefix;
	
	private Gedb.Type* _from;
	internal Gedb.Type* from { 
		get { return _from; }
		private set{
			select = null;
			where = null;
			_from = value;
			prefix = new Gee.ArrayList<Expression>();
			if (value!=null)
				prefix.insert(0, new ManifestExpression.typed(value, "?"));
		}
	}

	private Expression _select;
	internal Expression select { 
		get { return _select; }
		private set {
			_select = value!=null ? value.clone_resolved(prefix) : null; 
			flat_exs = {_select};
			flat_fields = {null};
			flat_features = {null};
		}
	}

	private Expression _where;
	internal Expression where { 
		get { return _where; }
		private set { 
			_where = value!=null ? value.clone_resolved(prefix) : null; 
		}
	}

	internal Expression[] flat_exs;
	internal Field*[] flat_fields;	
	internal FeatureText*[] flat_features;	

	internal SqlQuery(System*s, Gedb.Type* t) 
	requires (s!=null) {
		rts = s;
		from = t; 
	}

	internal SqlQuery.from_pattern(SqlQuery q, Gedb.Type* t) 
	requires (t!=null && t.is_alive()) {
		rts = q.rts;
		from = t;
		select = q.select;
		where = q.where;
		flat_exs = {select};
		flat_fields = {null};
		Field* f = null;
		uint i, n = q.flat_exs.length;
		for (i=1; i<n; ++i) {
			var ex = q.flat_exs[i];
			if (ex!=null && ex.static_check(from.base_class, null, rts, null)) 
				flat_exs += ex;
			else 
				flat_exs += null;
			f = q.flat_fields[i];
			if (f==null) {
				var ft = q.flat_features[i];
				f = ft!=null ? t.field_by_name(((Name*)ft).fast_name) : null;
			}
			flat_fields += f;
			flat_features += null;
		}
	}
	
	internal Gedb.Type* type(uint i) {
		var f = (Entity*)flat_fields[i];
		if (f!=null) return f.type;
		var ex = flat_exs[i];
		if (ex!=null) return ex.bottom().dynamic_type;		
		return null;
	}

	private void set_object_in(Expression ex, uint8* obj) {
		AliasExpression al = ex as AliasExpression;
		if (al==null) return;
		ManifestExpression me = al.alias as ManifestExpression;
		if (me==null) return;
		me.set_result(obj);
	}

	internal void set_object(uint8* obj) {
		if (_select!=null) set_object_in(_select, obj);
		if (_where!=null) set_object_in(_where, obj);
	}
}

public class SqlPart : Window {

	private ListStore all_types;
	private ListStore alive_types;

	private Debuggee dg;
	private DataPart data;

	private Entry select;
	private Entry from;
	private Entry where;
	private Label count;
	private ScrolledWindow scroll;
	private TreeView view;
	private ListStore store;
	private CellRendererText id_cell;
	private CellRendererText basic_cell;
	private ExpressionChecker checker;

	private ToggleButton conform;
	private Button update;

	private StackFrame* frame;
	private uint[] ident_col;
	private Gee.Map<string,Expression> aliases;
	private Gee.Map<Gedb.Type*,SqlQuery> conformings;
	private SqlQuery actual;
	private Gedb.Type* base_type;
	private bool as_default;

	public bool obsolete { get; private set; }

	private void build_view() {
		Entity* f;
		GLib.Type[] mcs;
		TreeViewColumn col;
		TreeIter iter;
		string text;
		uint k;
		int i;
		bool ok;
		ok = select_history.list.get_iter_first(out iter);
		if (ok) {
			select_history.list.@get(iter, 0, out text, -1);
			var e = select_history.get_child() as Entry;
			e.text = text;
			ok = text.length>0;
		}
		as_default = !ok;
		ok = where_history.list.get_iter_first(out iter);
		if (ok) {
			where_history.list.@get(iter, 0, out text, -1);
			var e = where_history.get_child() as Entry;
			e.text = text;
		} else {
			actual.where = null;
		}
		for (i=(int)view.get_n_columns(); i-->0;) {
			col = view.get_column(i);
			view.remove_column(col);
		}
		col = new TreeViewColumn.with_attributes("", id_cell, "text", 1, null);
		col.set_data<uint>("column", 1);
		col.max_width = 50;
		col.resizable = true;
		col.expand = true;
		col.set_sort_column_id(1);
		col.set_cell_data_func(id_cell, do_format_id);
		view.append_column(col);

		ident_col = {1};
		mcs = {typeof(void*),typeof(int)};
		if (as_default) {
			if (base_type.is_alive()) 
				mcs = expand_type(base_type, null, null, mcs);
			else 
				mcs = expand_type(null, base_type.base_class, null, mcs);
		} else {
			mcs = flat_entries(actual.select, mcs);
		}
		store = new ListStore.newv(mcs);
		store.set_sort_column_id(1, SortType.ASCENDING);
		view.set_model(store);
		conformings = new Gee.HashMap<Gedb.Type*,SqlQuery>();
		conformings[actual.from] = actual;
		for (k=base_type.effector_count(); k-->0;) {
			var eff = base_type.effectors[k];
			if (eff==base_type || !eff.is_alive()) continue;
			if (!eff.is_normal() || eff.is_subobject()) continue;
			var q = new SqlQuery.from_pattern(actual, eff);
			conformings[eff] = q;
		}
		int w = 0;
		for (i=(int)view.get_n_columns(); i-->0;) {
			col = view.get_column(i);
			w += col.max_width;
		}
		w = int.min(w, (int)(0.9*get_screen().width()));
		scroll.set_min_content_width(w);
		obsolete = false;
	}		
	
	private GLib.Type[] add_column(Field* f, FeatureText* ft, Expression? ex, 
								   string name, GLib.Type[] mcs) 
	requires (f!=null || ft!=null || ex!=null) {
		GLib.Type[] tt = mcs[0:mcs.length];
		GLib.Type ms = typeof(int);
		Gedb.Type* t = null;
		ClassText* ct = null;
		string tn = "";
		int width = 0;
		uint next_id = ident_col[ident_col.length-1]+1;
		actual.flat_fields += f;
		actual.flat_features += ft;
		actual.flat_exs += ex;
		if (f!=null) {
			t = ((Entity*)f).type;
		} else if (ft!=null) {
			ct = ft.result_text;
		} else {
			var exb = ex.bottom();
			t = exb.dynamic_type;
		}
		if (t!=null) {
			if (!t.is_subobject()) ++next_id;
			tn = ((Name*)t).fast_name;
		} else if (ct!=null) {
			if (!ct.is_expanded()) {
				++next_id;
			} else if (ct.is_basic()) {
				t = dg.rts.as_type(ct);
			}
			tn = ((Name*)ct).fast_name;
		}
		ident_col += next_id;
		TreeViewColumn column = null; 
		if (t!=null && t.is_basic()) {
			column = new TreeViewColumn.with_attributes
				(name, basic_cell, "text", next_id, null);
			switch (t.ident) {
			case TypeIdent.BOOLEAN:
				ms = typeof(bool);
				width = 50;
				column.set_cell_data_func(basic_cell, do_format_bool);
				break;
			case TypeIdent.CHARACTER_8:
			case TypeIdent.CHARACTER_32:
				ms = typeof(unichar);
				width = 20;
				break;
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				ms = typeof(int32);
				width = 50;
				break;
			case TypeIdent.INTEGER_64:
				ms = typeof(int64);
				width = 50;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				ms = typeof(uint32);
				width = 50;
				break;
			case TypeIdent.NATURAL_64:
				ms = typeof(uint64);
				width = 50;
				break;
			case TypeIdent.REAL_32:
				ms = typeof(float);
				width = 80;
				column.set_cell_data_func(basic_cell, (l,c,m,i) => 
					{ do_format_real(l,c,i,false);} );
				break;
			case TypeIdent.REAL_64:
				ms = typeof(double);
				width = 120;
				column.set_cell_data_func(basic_cell, (l,c,m,i) => 
					{ do_format_real(l,c,i,true);} );
				break;
			case TypeIdent.POINTER:
				ms = typeof(string);
				width = 60;
				break;
			}
			tt += ms;
		} else {
			column = new TreeViewColumn.with_attributes
				(name, id_cell, "text", next_id, null);
			tt += typeof(void*);
			tt += typeof(int);
			width = 50;
			column.set_cell_data_func(id_cell, do_format_id);
		}
		column.set_data<uint>("column", next_id);
		column.set_resizable(true);
		column.set_expand(true);
		column.set_sort_column_id((int)next_id);
		var label = new Label(name); 
		column.set_widget(label);
		string nm = ex!=null ?
			ex.top().append_qualified_name(null, null, fmt) : name;
		int tnl = tn.length;
		if (tnl>24) 
			tn = tn.substring(0,11) + "..." + tn.substring(tnl-11);
		label.set_tooltip_text(nm + ":\n" + tn);
		label.has_tooltip = true;
		label.show();
		column.max_width = width;
		view.append_column(column);
		return tt;
	}

	private GLib.Type[] expand_type(Gedb.Type* t, ClassText* ct,
									string? qualifier, 
									GLib.Type[] tt, Expression? parent=null) 
	//requires ((t!=null && t.is_alive()) || ct!=null) 
	{ // workaround
		GLib.Type[] mcs = tt[0:tt.length];
		string name;
		uint i, n;
		if (t!=null) {
			Gedb.Type* tf;
			Field* f;
			n = t.field_count();
			for (i=0; i<n; ++i) {
				f = t.fields[i];
				tf = ((Entity*)f).type;
				name = ((Name*)f).fast_name;
				if (qualifier!=null && qualifier.length>0)
					name = qualifier + "." + name;
				if (tf.is_nonbasic_expanded()) 
					mcs = expand_type(tf, null, name, mcs, parent);
				else 
					mcs = add_column(f, null, parent, name, mcs);
			}
		} else {
			ClassText* cf;
			FeatureText* ft;
			n = ct.feature_count();
			for (i=0; i<n; ++i) {
				ft = ct.features[i];
				if (ft.is_routine() || ft.is_constant()) continue;
				cf = ft.result_text;
				name = ((Name*)ft).fast_name;
				if (qualifier!=null && qualifier.length>0)
					name = qualifier + "." + name;
				if (cf.is_expanded() && !cf.is_basic()) 
					mcs = expand_type(null, cf, name, mcs, parent);
				else 
					mcs = add_column(null, ft, parent, name, mcs);
			}
		}
		return mcs;
	}

	private Expression.Format fmt = Expression.Format.EXPAND_PH;

	private GLib.Type[] flat_entries(Expression ex, GLib.Type[] tt) {
		GLib.Type[] mcs = tt[0:tt.length];
		Expression? next;
		Expression exb = ex;
		Expression? exd;
		Gedb.Type* t;
		string name;
		for (next=ex; next!=null; next=next.next) {
			exb = next.bottom();
			t = exb.dynamic_type;
			if (t==null) continue;
			name = next.append_qualified_name(null, exb);
			if (t.is_nonbasic_expanded()) {
				mcs = expand_type(t, null, name, mcs, exb);
			} else {
				mcs = add_column(null, null, next, name, mcs);
			}
			exd = exb.detail;
			if (exd!=null) {
				mcs = flat_entries(exd, mcs);
			}
		}
		return mcs;
	}

	private bool do_type(TreeModel m, TreeIter at) {
		Gedb.Type* old = base_type;
		uint tid = 0;
		bool ok;
		if (dg.rts==null) return false;
		m.@get(at, TypeEnum.TYPE_IDENT, out tid, -1);
	    base_type = dg.rts.type_at(tid);
		from.set_text(((Name*)base_type).fast_name);
		obsolete |= base_type!=old;
		if (obsolete) {
			actual = new SqlQuery(dg.rts, null);
			actual.from = base_type;
			select_history.add_item("", true);
			where_history.add_item("", true);
		}
		return true;
	}

	private void do_check_expression(HistoryBox h, bool as_cond) {
		checker.reset();
		if (actual.from==null) return;
		Expression? ex = null;
		var e = h.get_child() as Entry;
		string str = e.get_text();
		if (str.strip().length>0) {
			bool ok = checker.check_dynamic
			(str, actual.from, dg.frame(), dg.rts, false, 
				 aliases, actual.prefix);
			if (!ok) return;
			ex = (!) checker.parsed;
			str = ex.append_name();
		}
		if (as_cond) actual.where = ex;
		else actual.select = ex;
		h.add_item(str, false);
		e.set_text(str);
		obsolete = true;
	}

	private void do_refresh(StackFrame* f) {
		frame = f;
		if (f==null) {
			if (store!=null) store.clear();
			return;
		}
		if (actual.from!=null) {
			data.refill_known_objects();
			do_update();
		}
	}

	private void do_toggle() {
		bool conf = conform.get_active();
		conform.set_label(conf ? "conform" : "precise");
		from.completion.set_model(conf ? all_types : alive_types);
		if (!conf && !base_type.is_alive()) {
			string name = ((Name*)base_type).fast_name;
			conform.active = true;
			checker.show_message("Type is not alive:", "", name);
		}
		obsolete = true;
	}

	private void do_update() {
		if (actual.from==null) return;
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
		bool conform = this.conform.active;
		for (iter = ko.map_iterator(); iter.next();) {
			obj = iter.get_key();
			od = iter.get_value();
			t = dg.rts.type_of_any(obj, actual.from);
			if (t!=actual.from) {
				if (conform) {
					var act = conformings[t];
					if (act==null) continue;
					else actual = act;
				} else {
					continue;
				}
			}
			try {
				actual.set_object(obj);
				if (actual.where!=null) {
					actual.where.compute_in_object
						(obj, t, dg.rts, dg.frame(), obj);
					var bottom = actual.where.bottom();
					if (bottom.address()==null) {
						// issue message
						continue;
					}
					if (bottom.dynamic_type==null 
						|| bottom.dynamic_type.ident!=TypeIdent.BOOLEAN) {
						// issue message
						continue;
					}
					if (!bottom.as_bool()) continue;
				}
				store.append(out at);
				store.@set(at, 0, obj, 1, od, -1);
				if (as_default) {
					scan_fields(at, 1, obj, t);
				} else {
					actual.select.compute_in_object
						(obj, t, dg.rts, dg.frame(), obj);
					Gedb.Type* ft;
					Field* f;
					Expression ex;
					uint8* addr;
					bool is_home;
					uint k = actual.flat_exs.length;
					for (uint i=1; i<k; ++i) {
						f = actual.flat_fields[i];
						ex = actual.flat_exs[i];
						if (f!=null) {
							ft = ((Entity*)f).type;
							ex = actual.flat_exs[i];
							addr = ex!=null ? ex.bottom().address() : obj;
							addr += f.offset;
							is_home = ex!=null;
						} else if (ex!=null) {
							ex = ex.bottom();
							addr = ex.address();
							ft = ex.dynamic_type;
							is_home = false;
						} else {
							continue;
						}
						update_column(at, i, addr, is_home, ft);
					}
				}
				++n;
			} catch (ExpressionError err) {
			// issue message
				stderr.printf("%s\n", err.message);
				continue;
			}
		}
		count.set_text(@"$n");
		var screen = get_screen();
		int h = (int)(0.5*screen.height());
		scroll.set_min_content_height(int.min(n*24+30,h));
	}

	private uint scan_fields(TreeIter at, uint first_col,
							uint8* obj, Gedb.Type* t) {
		Gedb.Type* ft;
		Field* f, flat;
		uint8* addr = obj;
		uint col = first_col;
		uint i, n = t.fields.length;
		for (i=0; i<n; ++i) {
			f = t.fields[i];
			flat = actual.flat_fields[col];
			if (flat==null) {	// `flat' not implemented, try `f' again
				++col;
				--i;
				continue;
			}
			ft = ((Entity*)f).type;
			addr = obj+f.offset;
			if (ft.is_nonbasic_expanded()) {
				col = scan_fields(at, col, addr, ft);
			} else if (f!=flat) {	// `f' not in base type, skip
				continue;
			} else {
				update_column(at, col, addr, true, ft);
				++col;
			}
		}
		return col;
	}

	private void update_column(TreeIter at, uint col, 
							   uint8* addr, bool is_home, Gedb.Type* t) {
		string str;
		uint j;
		void* p;
		if (addr==null) return;
		j = ident_col[col];
		if (t.is_basic()) {
			switch (t.ident) {
			case TypeIdent.BOOLEAN:
				store.@set(at, j, *(bool*)addr, -1);
				break;
			case TypeIdent.CHARACTER_8:
				store.@set(at, j, *(char*)addr, -1);
					break;
			case TypeIdent.CHARACTER_32:
				store.@set(at, j, *(char*)addr, -1);
					break;
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				store.@set(at, j, *(int32*)addr, -1);
				break;
			case TypeIdent.INTEGER_64:
				store.@set(at, j, *(int64*)addr, -1);
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				store.@set(at, j, *(uint32*)addr, -1);
				break;
			case TypeIdent.NATURAL_64:
				store.@set(at, j, *(uint64*)addr, -1);
				break;
			case TypeIdent.REAL_32:
				store.@set(at, j, *(float*)addr, -1);
				break;
			case TypeIdent.REAL_64:
				store.@set(at, j, *(double*)addr, -1);
				break;
			case TypeIdent.POINTER:
				p = *(void**)addr;
				str = p!=null ? "%p".printf(p) : "0x0";
				store.@set(at, j, str, -1);
				break;
			}
		} else {
			if (is_home) addr = *(void**)addr;
			store.@set(at, j, data.known_objects[addr], j-1, addr, -1);
		}
	}

	private void do_format_id(CellLayout layout, CellRenderer cell,
							  TreeModel model, TreeIter iter) {
		var ct = cell as CellRendererText;
		var col = layout as TreeViewColumn;
		int id;
		store.@get(iter, col.sort_column_id, out id, -1);
		if (id<0) ct.text = "_?";
		else  ct.text = "_%d".printf(id);
	}

	private void do_format_bool(CellLayout layout, CellRenderer cell,
								TreeModel model, TreeIter iter) {
		var ct = cell as CellRendererText;
		var col = layout as TreeViewColumn;
		bool b = false;
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
		if (e.type!=Gdk.EventType.BUTTON_PRESS || e.button!=3) return false;
		TreePath path;
		TreeIter iter;
		TreeViewColumn col;
		int i, n, x, y;
		view.get_path_at_pos((int)e.x, (int)e.y, 
							 out path, out col, out x, out y);
		if (path==null) return true;
		store.get_iter(out iter, path);
		n = col.sort_column_id;
		for (i=ident_col.length; i-->0;) 
			if (ident_col[i]==n) break;
		if (i<0) return true;
		if (i>0 && ident_col[i-1]==n-1) return true;
		var info = data.deep_info;
		uint8* obj = null;
		uint od;
		store.@get(iter, n, out od, n-1, out obj, -1);
		if (obj==null) return true;
		var menu = new FeatureMenu(info[od], obj, data, 0, dg.rts);
		menu.popup(null, null, null, e.button, e.time);
		return true;
	}

	private bool do_close() { 
		hide(); 
		if (store!=null) store.clear();
		return true; 
	}

	private string do_deep(TreeModel model, TreeIter at, uint col) {
		Gedb.Type* t = null;
		void* addr = null;
		string name = null;
		uint od;
		int i = 0;
		if (obsolete) return "";
		for (i=ident_col.length; i-->0;) {
			if (ident_col[i]==col) break;
		}
		if (i<0) return "";
		if (i==0 || ident_col[i-1]==col-2) { // column of idents
			var ko = data.known_objects;
			store.@get(at, col, out od, col-1, out addr, -1);
			if (addr==null || !ko.has_key(addr)) return "";
			var info = data.deep_info[od];
			name = data.dotted_name(info);
			t = dg.rts.type_of_any(addr, info.tp);
		} else { // column of basic expanded type
			name = view.get_column(i).title;
			t = actual.type(i);
			if (t==null) return "";
			bool b = false;
			unichar c = ' ';
			int64 i64 = 0;
			uint64 n64 = 0;
			float f = 0;
			double d = 0;
			void* p = null;
			switch (t.ident) {
			case TypeIdent.BOOLEAN:
				store.@get(at, col, out b, -1);
				p = &b;
				break;
			case TypeIdent.CHARACTER_8:
			case TypeIdent.CHARACTER_32:
				store.@get(at, col, out c, -1);
				p = &c;
				break;
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
				store.@get(at, col, out i64, -1);
				p = &i64;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				store.@get(at, col, out n64, -1);
				p = &n64;
				break;
			case TypeIdent.REAL_32:
				store.@get(at, col, out f, -1);
				p = &f;
				break;
			case TypeIdent.REAL_64:
				store.@get(at, col, out d, -1);
				p = &d;
				break;
			case TypeIdent.POINTER:
				store.@get(at, col, out p, -1);
				p = &p;
				break;
			}
			addr = (uint8*)p;
			name += " = " + format_value(addr, 0, false, t, 0);
		}
		name += " : " + format_type(addr, 0, false, t);
		return name;
	}

	private void do_new_exe(Debuggee dg) {
		where_history.clear();
		select_history.clear();
		base_type = dg.frame().target_type();
		all_types = new_type_list(dg.rts, (t) => 
			{ return !t.is_subobject(); });
		alive_types = new_type_list(dg.rts, (t) => 
			{ return t.is_alive() && !t.is_subobject(); });
		var compl = from.completion;
		compl.set_model(all_types);
		int n = all_types.iter_n_children(null);
		n = n>1 ? (int)(Math.log2(n)/3.0) : 0;
		compl.set_minimum_key_length(n);
		actual = new SqlQuery(dg.rts, null);
		conformings = null;
		do_toggle();
	}
	
	public SqlPart(Debuggee dg, StackPart stack, DataPart data, Status status,
				   Gee.Map<string,Expression> aliases) {
		this.dg = dg;
		this.data = data;
		this.aliases = aliases;

		title = compose_title("SQL", dg.rts);
		id_cell = new CellRendererText();
		id_cell.set_alignment(1.0F, 0.5F);
		basic_cell = new CellRendererText();
		basic_cell.set_alignment(1.0F, 0.5F);
		basic_cell.ellipsize = Pango.EllipsizeMode.START;

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
		store = new ListStore (1, typeof(int));
		view = new TreeView.with_model(store);
		scroll.@add(view);
		view.headers_visible = true;
		view.reorderable = true;
		view.get_selection().mode = SelectionMode.NONE;
		TreeViewColumn col = new TreeViewColumn.with_attributes
			("", id_cell, "text", 0, null);
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
		from.completion = compl;
		compl.set_text_column(TypeEnum.TYPE_NAME);
		compl.set_match_func((c,k,i) =>
			{ return checker.do_filter_type_name(c,k,i,dg.rts); });
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

		label = new Label("Type policy: ");
		hbox.pack_start(label, false, false, 0);
		conform = new ToggleButton();
		conform.active = false;
		buttons.@add(conform);
		buttons.set_child_secondary(conform, true);
		conform.set_tooltip_text("Precise or corforming types?");
		conform.has_tooltip = true;
		conform.clicked.connect((b) => { do_toggle(); });
		conform.active = false;
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

		do_new_exe(dg);
		do_refresh(stack.frame());
		show_all();
	}

	public HistoryBox where_history { get; private set; }
	public HistoryBox select_history { get; private set; }

	public void do_set_sensitive(bool is_running) {
		select.sensitive = !is_running;
		from.sensitive = !is_running;
		where.sensitive = !is_running;
	}

}
