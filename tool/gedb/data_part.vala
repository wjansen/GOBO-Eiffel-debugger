using Gtk;
using Gedb;

public class DataCore : Box {

	protected StackPart stack;
	protected Status status;
	public DataPart? main;
	public Debuggee dg;

	protected TreeStore store;
	protected TreeView view {get; protected set; }
	protected CellRendererText cell;
	protected Gee.List<uint> info_list;
	public bool tree_lines { get; set; }

	public StackFrame* frame { get; protected set; }
	protected Routine* routine;
	
	protected virtual FormatStyle format_style() { return FormatStyle.ADDRESS; }

	protected void set_value(TreeIter iter, uint8* addr, 
							 Entity* e, SpecialType* st, uint idx,
							 char mode, string? name, string value,
							 Expression? ex=null) 
	requires (e!=null || st!=null || ex!=null) {
		Gedb.Type* t = st!=null 
			? st.item_type()
			: (e!=null ? e.type : ex.dynamic_type);
		int off = e.is_local() ? ((Local*)e).offset : ((Field*)e).offset;
		string nm = name!=null ? name : e._name.fast_name; 
		if (!t.is_subobject()) t = dg.rts.type_of_any(addr, t);
		var tid = dg.rts.object_type_id(addr, false, t);
		var type = format_type(addr, 0, false, t, e!=null ? e.text:null);
		store.@set(iter, 
				   ItemFlag.EXPR, ex,
				   ItemFlag.FIELD, e,
				   ItemFlag.ADDR, addr,
				   ItemFlag.INDEX, st!=null ? idx : -1,
				   ItemFlag.MODE, (int)mode,
				   ItemFlag.NAME, nm, 
				   ItemFlag.VALUE, value, 
				   ItemFlag.TYPE, type, 
				   ItemFlag.TYPE_ID, tid, 
				   -1);
	}

	internal void reformat_tree(TreeIter iter) {
		Gedb.Type *t;
		Entity* e;
		Expression ex;
		TreeIter child;
		uint8* addr;
		uint tid;
		int i, n;
		char c;
		FormatStyle fmt = format_style(); 
		store.@get(iter, ItemFlag.ADDR, out addr, 
				   ItemFlag.TYPE_ID, out tid, -1);
		t = dg.rts.type_at(tid);
		var value = format_value(addr, 0, false, t, fmt, known_objects);
		store.@set(iter, ItemFlag.VALUE, value, -1);
		n = store.iter_n_children(iter);
		for (i=0; i<n; ++i) {
			store.iter_nth_child(out child, iter, i);
			reformat_tree(child);
		} 
	}

	private void clear_subtree(TreeIter? iter) {
		TreeIter child;
		if (store.iter_nth_child(out child, iter, 0)) {
			for (; store.@remove(ref child););
		}
	}
	
	internal void update_subtree(TreeIter iter, uint8* addr) {
		Gedb.Type* t;
		Gedb.Type* ft;
		Field* f;
		Entity* e;
		Entity* pe;
		FeatureText*[] labels;
		Expression? ex;
		TreePath path = store.get_path(iter);
		TreeIter child = iter;
		string str, old_val, old_type, value, type;
		uint8* old_addr, heap;
		uint n, n_old, tid, tid_old, step;
		int i, off, idx;
		char mode;
		bool ok=true, changed;
		FormatStyle fmt = format_style();
		store.@get(iter, 
				   ItemFlag.MODE, out i,
				   ItemFlag.EXPR, out ex,
				   ItemFlag.FIELD, out e,
				   ItemFlag.INDEX, out idx,
				   ItemFlag.ADDR, out old_addr,
				   ItemFlag.NAME, out str,
				   ItemFlag.VALUE, out old_val, 
				   ItemFlag.TYPE, out old_type, 				   
				   ItemFlag.TYPE_ID, out tid_old, 
				   -1);
		mode = (char)i;
		if (ex!=null) {
			t = ex.dynamic_type;
			addr = ex.address();
			ok = false;
		} else {
			if (e!=null) t = e.type;
			else if (idx>=0) t = dg.rts.type_at(tid_old);
			else return;
			if (!t.is_subobject()) t = dg.rts.type_of_any(addr, t);
		}
		tid = t!=null ? t.ident : 0;
		value = format_value(addr, 0, false, t, fmt, known_objects);
		type = format_type(addr, 0, false, t, e!=null ? e.text : null);
		changed = value!=old_val || type!=old_type;
		if (changed) {
			store.@set(iter, ItemFlag.ADDR, addr, ItemFlag.VALUE, value, 
					   ItemFlag.TYPE_ID, tid, ItemFlag.TYPE, type, -1);
		}
		store.@set(iter, ItemFlag.CHANGED, changed, -1);
		n_old = store.iter_n_children(iter);
		if (t.is_special()) {
			SpecialType* st = (SpecialType*)t;				
			n = st.special_count(addr);
		} else {
			n = t.field_count();
		}
		bool expand = tid==tid_old;
		if (!expand) do_collapse(iter);
		else expand &= view.is_row_expanded(path);
		if (!expand) {
			// Children have been replaced by a dummy child,
			// make sure that this will not be shown:
			view.collapse_row(path);
			return;
		}
		mode = DataMode.FIELD;
		if (t.is_special()) {
			SpecialType* st = (SpecialType*)t;				
			e = (Entity*)st.item_0();
			uint8* faddr = st.base_address(addr);
			step = st.item_type().field_bytes();
			for (i=0; i<n; ++i, faddr+=step) {
				// if (is_default_value(faddr, TRUE, fid))  continue;
				heap = e.type.dereference(faddr);
				if (i<n_old) {
					store.iter_nth_child(out child, iter, i);
					update_subtree(child, heap);
				} else {
					store.append(out child, iter);
					ft = dg.rts.type_of_any(heap, e.type);
					str = "[%d]".printf(i);
					value = format_value(faddr, 0, true, ft, 
										 fmt, known_objects);
					set_value(child, heap, e, st, i, mode, str, value);
					store.@set(child, ItemFlag.CHANGED, true, -1);
					add_dummy_item(child, ft);
				}
			}
			for (; i<n_old; ++i) {
				store.iter_nth_child(out child, iter, (int)n);
				store.@remove(ref child);
			}
			for (; i<n_old; ++i) {
				store.iter_nth_child(out child, iter, i);
				store.@remove(ref child);
			}
		} else if (!t.is_string()) {
			if (t.is_agent()) {
				AgentType* ag = (AgentType*)t;
				f = ag.declared_type._type.fields[0];
				off = f.offset;
				old_addr = addr;
				addr = f._entity.type.dereference(addr+off);
				n = ag.closed_operand_count;
			}
			for (i=0; i<n; ++i) {
				f = t.fields[i];
				heap = f._entity.type.dereference(addr+f.offset);
				if (store.iter_nth_child(out child, iter, i)) 
					update_subtree(child, heap);
			}
			if (t.is_agent() && n<t.field_count()) {
				f = t.field_at(n);
				heap = f._entity.type.dereference(old_addr+f.offset);
				if (store.iter_nth_child(out child, iter, i)) 
					update_subtree(child, heap);				
			}
		}
	}

	protected void do_display_mode(CellRendererText ct, TreeIter iter) {
		int mode;
		store.@get(iter, ItemFlag.MODE, out mode, -1);
		ct.text = "%c".printf((char)mode);
	}

	protected virtual void do_refresh(StackFrame* f, uint class_id, uint pos)  {
		Gedb.Type* lt;
		AgentType* ag; 
		Routine* r;
		Local* loc, e;
		TreePath path;
		TreeIter iter;
		string name, value=null, old_value=null;
		uint8* addr, target, laddr;
		uint n, ico=0, tid, old=0;
		int i, j=0, k, off, mode;
		char ch = ' ';
		bool ok=false, exp;
		FormatStyle fmt = format_style();
		known_objects = null;
		if (fmt==FormatStyle.IDENT) {
			refill_known_objects();
		}
		for (n=store.iter_n_children(null); n-->0;) {
			store.iter_nth_child(out iter, null, (int)n);
			store.@get(iter, ItemFlag.MODE, out ch, -1);
			if (ch==DataMode.EXTERN)  store.@remove(ref iter);
			else  break;
		}
		if (f==null) {
			clear_subtree(null);
			return;
		}
		r = f.pos>0 ? f.routine : null;
		if (r==null || r.vars.length==0) {
			clear_subtree(null);
			return;
		}
		frame = f;
		item_selected(null);
		loc = r.vars[0];
		off = loc.offset;
		lt = loc._entity.type;
		addr = (uint8*)frame;
		target = addr+loc.offset;
		target = *(void**)target;  // target is always a pointer
		ag = r.inline_agent;
		if (ag!=null && ag.base_is_closed()) {
			var cot = (Gedb.Type*)ag.closed_operands_tuple;
			target = target + cot.fields[0].offset;
			target = lt.dereference(target);
			++ico;
		}
		store.get_iter_first(out iter);
		ok = r==routine;
		routine = r;
		if (ok) {
			update_subtree(iter, target);
		} else {
			clear_subtree(null);
			value = format_value(addr, off, true, lt, fmt, known_objects);
			store.append(out iter, null);
			set_value(iter, target, (Entity*)loc, null, -1, 
					  DataMode.CURRENT, null, value);
			store.@set(iter, ItemFlag.CHANGED, true, -1);
			add_dummy_item(iter, lt); 
			path = store.get_path(iter);
			view.expand_row(path, false);
		}
		++j;
		n = r.vars.length;
		uint ac = r.argument_count;
		uint lc = r.local_count;
		uint sc = r.scope_var_count;
		for (i=1; i<n; ++i) {
			loc = r.vars[i];
			if (loc==null) continue;
			e = null;
			addr = (uint8*)f;
			if (ok && store.iter_nth_child(out iter, null, j)) {
				// Compare j-th field of `store' with `loc':
				store.@get(iter, ItemFlag.FIELD, out e, -1);
				if (loc!=e)
					store.@remove(ref iter);
			}
			laddr = loc._entity.type.dereference(addr+loc.offset);
			if (i<ac) {
				ch = DataMode.ARGUMENT;
				if (ag!=null && ag.is_closed_operand(i)) {
					for (j=0,k=0; j<i; ++j) 
						if (ag.is_closed_operand(j)) ++k;
					Local* l0 = r.vars[0];
					addr = loc._entity.type.dereference(addr+l0.offset);
					l0 = (Local*)ag._type.fields[k];
					laddr = loc._entity.type.dereference(addr+l0.offset);
				}
			} else if (i<ac+lc) {
				ch = DataMode.LOCAL;
			} else {
				ch = DataMode.SCOPE_VAR;
				ScopeVariable* ot = (ScopeVariable*)loc;
				if (ot.in_scope(frame.pos/256, frame.pos%256)) {
				} else {
					if (loc==e) store.@remove(ref iter);
					continue;
				}
			}
			lt = dg.rts.type_of_any(laddr, loc._entity.type);
			value = format_value(laddr, 0, false, lt, fmt, known_objects);
			if (ok && loc==e) {
				update_subtree(iter, laddr);
			} else {
				store.insert(out iter, null, j);
				set_value(iter, laddr, (Entity*)loc, null, -1, ch, null, value);
				store.@set(iter, ItemFlag.CHANGED, true, -1);
				add_dummy_item(iter, lt); 
			}
			++j;
		}
	}

	protected void add_dummy_item(TreeIter iter, Gedb.Type* t) {
		if (t.is_string() || t.is_unicode() || t.field_count()==0) return;
		TreeIter child;
		store.append(out child, iter);
		store.@set(child, ItemFlag.MODE, DataMode.DUMMY, -1);
		if (t.is_nonbasic_expanded()) {
			var path = store.get_path(iter);
			view.expand_row(path, false);
		}
	}

	protected virtual void do_expand(TreeIter iter) {
		Gedb.Type* t, ft;
		Field* f;
		Entity* e, pe;
		Expression? ex;
		TreeIter child;
		string str, value, type;
		uint8* addr, heap;
		uint i, n, tid;
		DataMode mode;
		bool more;
		FormatStyle fmt = format_style();
		n = store.iter_n_children(iter);
		if (n>1) return;
		if (n==1) {
			store.iter_nth_child(out child, iter, 0);
			store.@get(child, ItemFlag.MODE, out i, -1);
			switch (i) {
			case DataMode.DUMMY:
				break;
			case DataMode.EXTERN:
				adjust_visibility(iter);
				return;
			default:
				return;
			}
		}
		more = n==0;	// `n>0' means that the dummy item is to be replaced
		store.@get(iter, 
				   ItemFlag.ADDR, out addr,
				   ItemFlag.TYPE_ID, out tid, 
				   ItemFlag.EXPR, out ex,
				   -1);
		if (addr==null && ex!=null) addr = ex.address();
		assert (addr!=null);
		mode = DataMode.FIELD;
		t = dg.rts.type_at(tid);
		if (t.is_special()) {
			SpecialType* st = (SpecialType*)t;
			n = st.special_count(addr);
			if (n==0) return;
			e = (Entity*)st.item_0();
			uint8* faddr = st.base_address(addr);
			uint step = st.item_type().field_bytes();
			for (i=0; i<n; ++i, faddr+=step) {
				// if (is_default_value(faddr, TRUE, fid))  continue;
				heap = e.type.dereference(faddr);
				if (more) 
					store.append(out child, iter);
				else
					store.iter_nth_child(out child, iter, 0);
				ft = dg.rts.type_of_any(heap, e.type);
				str = "[%u]".printf(i);
				value = format_value(heap, 0, false, ft, fmt, known_objects);
				set_value(child, heap, e, st, i, mode, str, value);
				if (ft.is_nonbasic_expanded()) 
					view.expand_row(store.get_path(child), false);
				else 
					add_dummy_item(child, ft);
				more = true;
			}
		} else if (!t.is_string() && !t.is_unicode()) {
			uint8* ag_addr = null;
			n = t.fields.length;
			if (t.is_agent()) {
				AgentType* ag = (AgentType*)t;
				f = ag.declared_type._type.fields[0];
				ag_addr = addr;
				addr = f._entity.type.dereference(addr+f.offset);
				n = ag.closed_operand_count;
			}
			if (n==0) return;
			for (i=0; i<n; ++i) {
				f = t.fields[i];
				heap = f._entity.type.dereference(addr+f.offset);
				add_item(iter, (Entity*)f, heap, mode, more ? -1 : 0,
						 -1, t.is_tuple() ? (int)i : -1);
				more = true;
			}
			if (t.is_agent()) {
				AgentType* ag = (AgentType*)t;
				if (n<t.field_count()) {
					f = t.field_at(n);
					heap = f._entity.type.dereference(ag_addr+f.offset);
					add_item(iter, (Entity*)f, heap, mode, more ? -1 : 0);
					more = true;
				}
				}
		}
		if (n>0) {
			adjust_visibility(iter);
		}
	}

	private void adjust_visibility(TreeIter iter) {
		TreePath path;
		TreeIter child;
		int n = store.iter_n_children(iter);
		if (n>1) {
			store.iter_nth_child(out child, iter, n-1);
			path = store.get_path(child);
			view.scroll_to_cell(path, null, false, 1.0F, 0.0F);
		}
		path = store.get_path(iter);
		view.scroll_to_cell(path, null, false, 0.5F, 0.0F);
	}

	private void add_item(TreeIter iter, Entity*e, uint8* addr, DataMode mode,
						  int replace=-1, int array_idx=-1, int tuple_idx=-1) {
		TreeIter child;
		FormatStyle fmt = format_style();
		int off = e.is_local() ? ((Local*)e).offset : ((Field*)e).offset;
		var ft = dg.rts.type_of_any(addr, e.type);
		string str, value, type;
		if (replace>=0) 
			store.iter_nth_child(out child, iter, replace);
		else
			store.append(out child, iter);
		if (array_idx>=0) {
			str = "[%d]".printf(array_idx);
		} else {
			str = e._name.fast_name;
		}
		value = format_value(addr, 0, false, ft, fmt, known_objects);
		str = null;
		if (tuple_idx>=0) {
			Entity* pe;
			store.@get(iter, ItemFlag.FIELD, out pe, -1);
			if (pe.text!=null && pe.text.tuple_labels!=null) 
				str = pe.text.tuple_labels[tuple_idx]._name.fast_name;
		}
		set_value(child, addr, e, null, -1, DataMode.FIELD, str, value);
		add_dummy_item(child, ft);
	}

	protected virtual void do_collapse(TreeIter iter) {
		Gedb.Type* t;
		Expression? ex;
		TreeIter child;
		uint tid;
		int mode;
		store.@get(iter, ItemFlag.TYPE_ID, out tid, ItemFlag.EXPR, out ex, -1);
		if (ex!=null) return;
		int i, n = store.iter_n_children(iter);
		for (i=n; i-->0;) {
			store.iter_nth_child(out child, iter, i);
			store.@remove(ref child);
		}
		t = dg.rts.type_at(tid);
		if (t!=null && t.field_count()>0) {
			add_dummy_item(iter, dg.rts.type_at(tid)); 
		}
	}

	private string add_short_type(string name, Entity* e) requires (e!=null) {
		string type = e.type._name.fast_name;
		if (type.length>20)  type = type.substring(0,18) + "...";
		return name + " : " + type;
	}

	private static int compare_routines(Routine* u, Routine* v) {
		if (u==v)  return 0;
		return  ((Entity*)u).is_less((Entity*)v) ? -1 : 1;
	}

	protected virtual bool valid_feature(TreeIter iter) { return true; }

	private Gtk.Menu typeset_menu;

	private bool do_typeset(Gdk.EventButton ev, TreeIter iter) {
		Gedb.Type* type;
		Gedb.Type*[] typeset;
		Entity* e;
		Gtk.MenuItem item, sel = null;
		uint tid;
		int i, n, mode;
		store.@get(iter,
				   ItemFlag.FIELD, out e,
				   ItemFlag.TYPE_ID, out tid, 
				   ItemFlag.MODE, out mode,
				   -1);
		switch (mode) {
		case DataMode.FIELD:
		case DataMode.ARGUMENT:
		case DataMode.LOCAL:
			break;
		default:
			return true;	
		}
		type = e.type;
		typeset = e.type_set;
		n = typeset!=null ? typeset.length : 0;
		if (typeset==null || n==0 || type.is_subobject()) return true;
		typeset_menu = new Gtk.Menu();
		for (i=0; i<n; ++i) {
			type = typeset[i];
			item = new Gtk.MenuItem.with_label(type._name.fast_name);
			typeset_menu.append(item);
			item.show();
			if (type.ident==tid) sel = item;
		}
		typeset_menu.popup(null, null, null, ev.button, ev.time);		
		if (sel!=null) typeset_menu.select_item(sel);
		return true;
	}

	private Gtk.Menu menu;

	private bool do_features(Gdk.EventButton ev) {	
		if (ev.type!=Gdk.EventType.BUTTON_PRESS || ev.button!=3) return false;
		TreeViewColumn col;
		TreePath path;
		TreeIter iter;
		int x=(int)ev.x, y=(int)ev.y;
		int mode;
		view.get_path_at_pos(x, y, out path, out col, null, null);
		store.get_iter(out iter, path);
		if (col.title=="Type") return do_typeset(ev, iter);
		Entity* e;
		DeepInfo? last=null, info=null, pinfo;
		Expression? ex;
		uint8* addr=null;
		string name;
		uint tid;
		int i;
		bool ok;
		if (!valid_feature(iter)) return false;
		for (ok=true; ok; ok=store.iter_parent(out iter, iter)) {
			store.@get(iter, 
					   ItemFlag.MODE, out mode,
					   ItemFlag.EXPR, out ex,
					   ItemFlag.ADDR, out addr,
					   ItemFlag.FIELD, out e,
					   ItemFlag.INDEX, out i, 
					   ItemFlag.TYPE_ID, out tid,
					   ItemFlag.NAME, out name, 
					   -1);
			if (name==null || name=="")  break;
			pinfo = ex!=null && ex.bottom().address()!=null 
				? new DeepInfo.from_expression(ex, dg.rts) 
				: new DeepInfo(null, e, dg.rts, i, 0, tid);
			if (info==null)  last = pinfo;
			else  info.parent = pinfo;
			info = pinfo;
		}
		uint up = (main!=null && frame!=null) ? 
			main.frame.depth-frame.depth : 0;
		menu = new FeatureMenu(last, addr, this, up, dg.rts);
		menu.popup(null, null, null, ev.button, ev.time);
		return true;
	}

	protected void do_tree_lines() {
		var d = main!=null ? main : this;
		view.enable_tree_lines = d.tree_lines;
	}

	protected virtual void do_set_sensitive(bool is_running) {
		set_deep_sensitive(this, !is_running);
	}

	private string do_deep(TreeModel model, TreeIter at, uint col) {
		string text;
		store.@get(at, col, out text, -1);	
		if (col==ItemFlag.VALUE && format_style()==FormatStyle.IDENT
			&& text.length>0) {
			text = text.substring(1);
			int id = int.parse(text);
			if (id<=0)  return "";
			var info = deep_info[id];
			text = dotted_name(info);
			bool valued = false;	// TODO: for future use
			if (!valued || info.addr==null)  return text;
			text += " = " + format_value(info.addr, 0, false, info.tp, 0);
			text += " : " + format_type(info.addr, 0, false, info.tp);
			return text;
		} else if (col==ItemFlag.NAME) {
			TreeIter p = at;
			string str;
			for (; model.iter_parent(out p, at); at=p) {
				model.@get(p, col, out str, -1);
				if (text.@get(0)!='[')  str += ".";
				text = str+text;
			}
			return text;
		} else {
			return text;
		}
	}
	
	internal DataCore(Debuggee dg, StackPart stack, Status state, 
					  bool as_main) {
		this.dg = dg;
		this.stack = stack;
		status = state;
		orientation = Orientation.VERTICAL;

		store = new TreeStore(ItemFlag.NUM_COLS, 
							  typeof(Expression?),	// expr
							  typeof(Entity*),		// field
							  typeof(uint8*),		// addr
							  typeof(int),			// index
							  typeof(int),			// mode
							  typeof(string),		// name
							  typeof(string),		// value
							  typeof(string),		// type
							  typeof(uint),			// type_id
							  typeof(bool));		// changed
		view = new TreeView.with_model(store);
		view.headers_visible = true;
		view.enable_search = true;
		view.search_column = ItemFlag.NAME;

		TreeViewColumn name, mode, value, type;
		cell = new CellRendererText();
		cell.background = "#fff6e0";
		cell.ellipsize = Pango.EllipsizeMode.MIDDLE;
		name = new TreeViewColumn.with_attributes
			("Name", cell, "text", ItemFlag.NAME, null);
		name.set_data<uint>("column", ItemFlag.NAME);
		name.add_attribute(cell, "background-set", ItemFlag.CHANGED);
		name.min_width = 40;
		name.resizable = true;
		name.expand = true;
		name.clickable = true;
		view.append_column(name);

		mode = new TreeViewColumn.with_attributes
			("", cell, "text", ItemFlag.MODE, null);
		mode.set_data<uint>("column", ItemFlag.MODE);
		mode.add_attribute(cell, "background-set", ItemFlag.CHANGED);
		mode.min_width = 10;
		mode.set_cell_data_func(cell, 
			(l,r,m,i) => { do_display_mode(cell,i); });
		mode.resizable = false;
		view.append_column(mode);
		
		value = new TreeViewColumn.with_attributes
			("Value", cell, "text", ItemFlag.VALUE, null);
		value.set_data<uint>("column", ItemFlag.VALUE);
		value.add_attribute(cell, "background-set", ItemFlag.CHANGED);
		value.min_width = 40;
		value.resizable = true;
		value.expand = true;
		view.append_column(value);

		type = new TreeViewColumn.with_attributes
			("Type", cell, "text", ItemFlag.TYPE, null);
		type.set_data<uint>("column", ItemFlag.TYPE);
		type.add_attribute(cell, "background-set", ItemFlag.CHANGED);
		type.min_width = 40;
		type.resizable = true;
		type.expand = true;
		type.clickable = true;
		view.append_column(type);
		do_tree_lines();

		ScrolledWindow scroll = new ScrolledWindow(null, null);
		pack_start(scroll, true, true, 3);
		scroll.min_content_width = 400;
		scroll.min_content_height = 240;
		scroll.@add(view);

		view.row_expanded.connect((i,p)=> { do_expand(i); });
		view.row_collapsed.connect((i,p)=> { do_collapse(i); });
		view.button_press_event.connect((e) => { return do_features(e); });
		info_list= new Gee.ArrayList<uint>();
		info_list.@add(ItemFlag.NAME);
		info_list.@add(ItemFlag.VALUE);
		info_list.@add(ItemFlag.TYPE);
		view.motion_notify_event.connect((ev) =>
			{ return status.set_long_string(ev, view, info_list, do_deep); });
		view.leave_notify_event.connect((ev) =>
			{ return status.remove_long_string(); });
		dg.notify["is-running"].connect(
			(g,p) => { do_set_sensitive(dg.is_running); });
	}

	private EvalPart _eval;
	public EvalPart eval { 
		get { return main!=null ? main.eval : _eval; }
		set { _eval = value; }
	}
	
	public Gee.HashMap<void*,uint> known_objects;

	private DeepInfo[] _deep_info;
	public DeepInfo[] deep_info { 
		get { return main!=null ? main.deep_info : _deep_info; }
		private set { _deep_info = value; }
	}

	private DeepInfo info; 
	private DeepSource deep_source;

	private void add_deep_info(uint od, void* id) {
		if (_deep_info.length<=od)  _deep_info.resize((int)(2*od+1));
		_deep_info[od] = info;
	}

	private void improve_deep_info(uint od, void* id) {
		if (info.depth < _deep_info[od].depth)  _deep_info[od] = info;
	}

	internal void fill_info(uint od, Entity* e, int idx, int d) {
		info = new DeepInfo(deep_info[od], e, dg.rts, idx, d);
	}

	public string dotted_name(DeepInfo info) {
		if (info==null)  return "";
		DeepInfo? pinfo = info.parent;
		string name = info.field._name.fast_name;
		if (name==null)  name = "";
		if (info.field.is_once()) {
			var o = (Gedb.Once*)info.field;
			name = "{" + o.home._name.fast_name + "}." + name;
		}
		if (pinfo!=null) {
			int i = info.index;
			string text = dotted_name(pinfo);
			return i<0 ? "%s.%s".printf(text, name)	: "%s[%i]".printf(text, i);
		}
		return name;
	}

	public void refill_known_objects() {
		if (main!=null || known_objects!=null) return;
		deep_info = new DeepInfo[99];
		var d = new Persistence<uint,void*>();
		deep_source = new DeepSource(frame, dg.rts, this, d);
		d.when_new.connect((od,id,t,n) => { add_deep_info(od,id); });
		d.when_known.connect((od,id,t,n) => { improve_deep_info(od,id); });
		d.traverse_stack(new NullTarget(), deep_source, frame, dg.rts, true); 
		known_objects = d.known_objects;
	}

	private TextExpression? id2expr(DeepInfo info) {
		var p = info.parent;
		var f = info.field;
		if (p!=null) {
			var pex = id2expr(p);
			if (pex!=null) {
				pex.bottom().set_child(pex.Child.DOWN,  
					pex.new_typed(p.expr, f, null));
				return pex;
			}
		} 
		if (f.text!=null) {
			return Expression.new_typed(null, f, null) as TextExpression;
		}
		return null;
	}

	public TextExpression? id_to_expr(uint id) {
		if (known_objects==null) return null;
		if (id>=_deep_info.length) return null;
		var info = _deep_info[id];
		if (info==null) return null;
		var iex = id2expr(info);
		if (iex==null) return null;
		var tex = iex.top() as TextExpression;
		if (tex!=null) {
			var e = tex.entity;
			try {
				if (e!=null && e.is_once()) {
					var o = (Gedb.Once*)e;
					var addr = o.value_address;
					var t = ((Entity*)o).type;
					addr = t.dereference(addr);
					tex.compute_in_object(addr, t, dg.rts, frame);
				} else {
					tex.compute_in_stack(frame, dg.rts);
				}
			} catch (ExpressionError e) {
				return null;
			}
		}
		return tex;
	}

	public signal void item_selected(DataItem? item);
	public signal void reformatted(FormatStyle fmt);
}

public class DataPart : DataCore {

	private RadioButton addr;
	private RadioButton ident;
	private RadioButton hex;
	internal Gee.Map<string,Expression> aliases;

	private void do_reformat(ToggleButton b) {
		if (!b.active)  return;
		FormatStyle fmt = format_style();
		switch (fmt) {
		case FormatStyle.IDENT: 
			refill_known_objects();
			break;
		default:
			known_objects = null;
			break;
		}
		TreeIter iter;
		if (store.get_iter_first(out iter)) {
			do { 
				reformat_tree(iter);
			} while (store.iter_next(ref iter));	
		}
		reformatted(fmt);
	}

	private bool do_select(TreeSelection s, TreeModel m, TreePath p, bool yes) {
		TreeIter iter;
		int mode;
		m.get_iter(out iter, p);
		m.@get(iter, ItemFlag.MODE, out mode, -1);
		return mode!=DataMode.CURRENT && mode!=DataMode.EXTERN;
	}

	protected override FormatStyle format_style() {
		return hex.active ? FormatStyle.HEX :
			addr.active ? FormatStyle.ADDRESS : FormatStyle.IDENT;
	}

	public DataPart(Debuggee dg, StackPart sp, Status state,
					Gee.Map<string,Expression> aliases) {
		base(dg, sp, state, true);
		main = null;
		this.aliases = aliases;
		eval = new EvalPart(dg, this);
		TreeSelection sel = view.get_selection();
		sel.mode = SelectionMode.SINGLE;
		sel.set_select_function(do_select);
		ButtonBox buttons = new ButtonBox(Orientation.HORIZONTAL); 
		pack_start(buttons, false, false, 3);
		buttons.set_layout(ButtonBoxStyle.START);
		buttons.@add(new Label("Format:"));
		addr = new RadioButton.with_label(null, "natural");
		buttons.@add(addr);
		addr.set_tooltip_text(
"""Show address 
of reference objects.""");
		addr.has_tooltip = true;
		addr.toggled.connect(do_reformat);
		ident = new RadioButton.with_label(addr.get_group(), "ident");
		buttons.@add(ident);
		ident.set_tooltip_text(
"""Show internal ident
of reference objects.""");
		ident.has_tooltip = true;
		ident.toggled.connect(do_reformat);
		hex = new RadioButton.with_label(addr.get_group(), "hex");
		buttons.@add(hex);
		hex.set_tooltip_text(
"""Use hexadecimal form
in print commands.""");
		hex.has_tooltip = true;
		hex.toggled.connect(do_reformat);
		
		notify["tree-lines"].connect((d,p) => { do_tree_lines(); });
		if (dg!=null) 
			dg.new_executable.connect(() => { ExtraData.part_count=0; });
		sel.changed.connect((s) => { 
				TreeModel model;
				TreeIter iter;
				bool ok = s.get_selected(out model, out iter);
				if (!ok) return;
				var item = new DataItem(model, iter);
				item_selected(item); 
			});
		stack.level_selected.connect(
			(s,f,i,p) => { do_refresh(f,i,p); });
		
	}

	public DataItem? selected_item() {
		TreeSelection sel = view.get_selection();
		TreeIter iter;
		TreeModel model;
		return sel.get_selected(out model, out iter) ? 
			new DataItem(store, iter) : null;
	}
	
	public void assign(Expression rhs) requires (rhs.dynamic_type!=null) {
		var lhs = selected_item(); 
		if (lhs==null)  return;
		var linfo = new WatchInfo.from_data(lhs, frame, dg.rts);
		Entity* e = lhs.field;
		Gedb.Type* t = e.type;
		uint8* left = linfo.address;
		uint8* right = rhs.address();
		bool b = false;
		char c = 0;
		unichar u = 0;
		long i = 0;
		ulong n = 0;
		double d = 0;
		void* p = null;
		switch (rhs.dynamic_type.ident) {
		case TypeIdent.BOOLEAN:
			b = *(bool*)right;
			break;
		case TypeIdent.CHARACTER_8:
			c = *(char*)right;
			u = c;
			break;
		case TypeIdent.CHARACTER_32:
			u = *(unichar*)right;
			break;
		case TypeIdent.INTEGER_8:
			i = *(int8*)right;
			n = i;
			d = i;
			break;
		case TypeIdent.INTEGER_16:
			i = *(int16*)right;
			n = i;
			d = i;
			break;
		case TypeIdent.INTEGER_32:
			i = *(int32*)right;
			n = i;
			d = i;
			break;
		case TypeIdent.INTEGER_64:
			i = *(long*)right;
			n = i;
			d = i;
			break;
		case TypeIdent.NATURAL_8:
			n = *(uint8*)right;
			i = (long)n;
			d = n;
			break;
		case TypeIdent.NATURAL_16:
			n = *(uint16*)right;
			i = (long)n;
			d = n;
			break;
		case TypeIdent.NATURAL_32:
			n = *(uint32*)right;
			i = (long)n;
			d = n;
			break;
		case TypeIdent.NATURAL_64:
			n = *(ulong*)right;
			i = (long)n;
			d = n;
			break;
		case TypeIdent.REAL_32:
			d = *(float*)right;
			break;
		case TypeIdent.REAL_64:
			d = *(double*)right;
			break;
		case TypeIdent.POINTER:
			p = *(void**)right;
			break;
		default:
			break;
		}
		switch (t.ident) {
		case TypeIdent.BOOLEAN:
			*(bool*)left = b;
			break;
		case TypeIdent.CHARACTER_8:
			*(char*)left = c;
			break;
		case TypeIdent.INTEGER_8:
			*(int8*)left = i;
			break;
		case TypeIdent.INTEGER_16:
			*(int16*)left = i;
			break;
		case TypeIdent.INTEGER_32:
			*(int32*)left = i;
			break;
		case TypeIdent.INTEGER_64:
			*(long*)left = i;
			break;
		case TypeIdent.NATURAL_8:
			*(uint8*)left = n;
			break;
		case TypeIdent.NATURAL_16:
			*(uint16*)left = n;
			break;
		case TypeIdent.NATURAL_32:
			*(uint32*)left = n;
			break;
		case TypeIdent.NATURAL_64:
			*(ulong*)left = n;
			break;
		case TypeIdent.REAL_32:
			*(float*)left = d;
			break;
		case TypeIdent.REAL_64:
			*(double*)left = d;
			break;
		case TypeIdent.POINTER:
			*(bool*)left = p;
			break;
		default:
			if (t.is_subobject())
				copy_value(left, right, t.field_bytes());  
			else
				left = right;
			break;
		}
		string value = format_value(right, 0, false, t, format_style(),
									known_objects);
		string type = format_type(right, 0, false, t);
		store.@set(lhs.iter, 
				   ItemFlag.VALUE, value, 
				   ItemFlag.TYPE, type, 
				   ItemFlag.TYPE_ID, t.ident,
				   -1);
		update_subtree(lhs.iter, left);
	}

	internal void add_expression(Expression expr, TreeIter? at=null,
		bool expand=false) {
		if (main!=null)  return;
		Gedb.Type* t;
		Entity* e = null;
		Expression ex, exb;
		Expression? exd = null;
		TextExpression? ext = null;
		TupleExpression? exu;
		ItemExpression? exi = null;		
		AliasExpression? exa = null;
		RangeExpression? exr = null;		
		uint8* addr;
		TreePath path;
		TreeIter iter;
		string name, val, type;
		char c = DataMode.EXTERN;
		FormatStyle style = format_style();
		uint fmt = expr.Format.INDEX_VALUE;
		for (ex=expr; ex!=null; ex=ex.next) {
			exb = ex.bottom();
			exa = exb as AliasExpression;
			if (exa!=null) exb = exa.alias;
			t = exb.dynamic_type;
			addr = exb.address(); 
			name = ex.append_qualified_name(null, null, fmt);
			val = format_value(addr, 0, false, t, style, known_objects);
			store.append(out iter, at);
			ext = exb as TextExpression;
			exi = exb as ItemExpression;
			exu = exb as TupleExpression;
			e = exi!=null 
				? (Entity*)exi.special_type.item_0() 
				: (ext!=null ? ext.entity : null);
			set_value(iter, addr, e, null, -1, c, name, val, exb);
			exr = exb.range;
			exd = exb.detail;
			if (exr!=null) {
				try {
					if (at!=null) iter = at;
					view.expand_row(store.get_path(iter), false);
					exr.traverse_range(
						(r) => { add_expression(r, iter, true); }, 
						frame, dg.rts, null, true);
				} catch (Error e) {
					stderr.printf("Error !!\n");
				}
			} else if (exd!=null) {
				add_expression(exd, iter, true);
			} else if (exu!=null && exu.arg!=null) {
				add_expression(exu.arg, iter); 
			} else { 
				add_dummy_item(iter, t);
			}
		}
		if (at!=null) {
			path = store.get_path(at);
			if (expand) view.expand_row(path, false);
			view.scroll_to_cell(path, null, false, 0.5F, 0.0F);
		}
	}

}

public class ExtraData : DataCore {

	internal static int part_count = 0;
	private bool updated;

	protected override void do_set_sensitive(bool is_running) {
		updated &= !is_running;
		set_deep_sensitive(this, updated);
		view.sensitive = updated;
	}

	public void update() {
		updated = true;
		var f = stack.frame();
		do_refresh(f, f.class_id, f.pos);
		view.sensitive = true;
	}

	public ExtraData(Debuggee dg, DataPart main, StackPart own) {
		base(dg, own, main.status, false);
		this.main = main;
		++part_count;
		id = part_count;
		updated = true;
		own.level_selected.connect((s,f,i,p) => { do_refresh(f,i,p); });
		main.notify["tree-lines"].connect((d,p) => { do_tree_lines(); });
	}

	public int id { get; private set; }

} /* class ExtraData */

public class MoreDataPart : Window {

	private bool do_close_data() { 
// Delay closing until all events haven been served:
		GLib.Idle.@add(() => { destroy();  return false; });
		return true;
	}


	public MoreDataPart(Debuggee dg, DataPart d, StackPart s) {
		destroy_with_parent = true;
		Box box = new Box(Orientation.VERTICAL, 3);
		add(box);
		StackPart sp = new StackPart.additionally(dg, s);
		box.pack_start(sp, false, false, 0);
		ExtraData dp = new ExtraData(dg, d, sp);
		set_title(compose_title(@"Data $(dp.id)", dg.rts));
		box.pack_start(dp, true, true, 0);
		Box hbox = new Box(Orientation.HORIZONTAL, 3);
		box.pack_end(hbox, false, false, 3);
		ButtonBox buttons = new ButtonBox(Orientation.HORIZONTAL);
		buttons.set_layout(ButtonBoxStyle.END);
		hbox.pack_end(buttons, true, true, 0);

		Label label = new Label("Update policy: ");
		hbox.pack_start(label, false, false, 0);
		ToggleButton policy = new ToggleButton();
		buttons.@add(policy);
		buttons.set_child_secondary(policy, true);
		policy.toggled.connect((t) => { sp.update_policy(t); });
		sp.update_policy(policy);

		Button update = new Button.with_label("Update");
		buttons.@add(update);
		update.set_tooltip_text("Update data to new system state.");
		update.has_tooltip = true;
		update.clicked.connect((b) => { sp.update(); dp.update(); });
		sp.update();

		Button close = new Button.with_label("Close");
		buttons.@add(close);
		close.clicked.connect((b) => { do_close_data(); });
		delete_event.connect((e) => { return do_close_data(); });
		if (dg!=null)
			dg.new_executable.connect(() => { destroy(); });

		has_resize_grip = true;
	}

} 

public class FixedPart : DataCore {

	private enum Item {
		CLS = ItemFlag.NUM_COLS,
		CID,
		FRESH,
		NUM_COLS
	}

	private Window w;
	private uint min_length;

	private bool do_close() { w.destroy(); return true; }

	private void set_once_value(TreeIter at, Gedb.Once* o, FormatStyle fmt) 
	requires (o!=null) {
		Gedb.Type* t = null;
		Entity* e = (Entity*)o;
		string value="", type="";
		uint8* addr=null;
		bool fresh = !o.is_initialized();
		if (o.is_function()) {
			t = e.type;
			if (!fresh) {
				addr = (uint8*)o.value_address;
				t = e.type;
				addr = t.dereference(addr);
				if (!t.is_subobject())  t = dg.rts.type_of_any(addr, t);
				value = format_value(addr, 0, false, t, 
									 fmt, main.known_objects);
				type = t._name.fast_name;
			} else {
				value = "";
				type = t._name.fast_name;
			}
		}
		store.@set(at, ItemFlag.FIELD, o, ItemFlag.ADDR, addr, 
				   ItemFlag.VALUE, value, ItemFlag.TYPE, type, 
				   Item.FRESH, fresh, -1);
		if (!fresh) add_dummy_item(at, t);
	}

	protected override FormatStyle format_style() {
		return main.format_style();
	}

	protected override bool valid_feature(TreeIter iter) { 
		Entity* e;
		bool fresh;
		store.@get(iter, Item.FRESH, out fresh, ItemFlag.FIELD, out e, -1);
		return !fresh && e!=null; 
	}

	protected override void do_refresh(StackFrame* f, uint cid, uint pos) {
		Gedb.Once* o;
		Entity* e;
		TreeIter iter, child;
		string value, type;
		int k, n;
		int m;
		bool fresh;
		FormatStyle fmt = format_style();
		bool ok = store.get_iter_first(out iter);
		n = store.iter_n_children(iter);
		if (store.get_iter_first(out iter)) {
			do { 
				n = store.iter_n_children(iter);
				for (k=0; k<n; ++k) {
					store.iter_nth_child(out child, iter, k);
					store.@get(child, 
							   ItemFlag.FIELD, out e, 
							   Item.FRESH, out fresh,
							   ItemFlag.MODE, out m, 
							   -1);
					if (m!=DataMode.ONCE)  continue;
					o = (Gedb.Once*)e;
					if (fresh==o.is_initialized()) {
						fresh = !fresh;
						set_once_value(child, o, fmt);
						store.@set(child, Item.FRESH, fresh,
								   ItemFlag.CHANGED, true, -1);
					} else {
						store.@set(child, ItemFlag.CHANGED, false, -1);
					}
					if (!fresh) add_dummy_item(child, e.type);
				} 
			} while (store.iter_next(ref iter)); 
		}
	}

	protected override void do_expand(TreeIter iter) {
		TreeIter child;
		var path = store.get_path(iter);
		if (path.get_depth()>0) {
			base.do_expand(iter);
		} else if (store.iter_children(out child, iter)) {
			Expression? ex = null;
			string name;
			bool fresh;
			do {
				store.@get(child, Item.FRESH, out fresh,
						   ItemFlag.EXPR, out ex, ItemFlag.NAME, out name, -1);
				if (fresh || ex==null) continue;
				update_subtree(child, ex.address());
			} while (store.iter_next(ref child));
		}
	}

	protected override void do_collapse(TreeIter iter) {
		var path = store.get_path(iter);
		if (path.get_depth()<=1) return;
	}

	private void do_reformat(FormatStyle fmt) {
		Entity* e;
		TreeIter iter, child;
		int k, n;
		int m;
		bool fresh;
		bool ok = store.get_iter_first(out iter);
		known_objects = fmt==FormatStyle.IDENT ? main.known_objects : null;
		if (store.get_iter_first(out iter)) {
			do { 
				n = store.iter_n_children(iter);
				for (k=0; k<n; ++k) {
					store.iter_nth_child(out child, iter, k);
					store.@get(child, ItemFlag.FIELD, out e, 
							   Item.FRESH, out fresh, 
							   ItemFlag.MODE, out m, 
							   -1);
					if (fresh) continue;
					if (m==DataMode.CONSTANT) { // to be improved 
					} else {
						set_once_value(child, (Gedb.Once*)e, fmt);
					}
				}
			} while (store.iter_next(ref iter)); 
		}
	}

	private bool do_search(string key) {
		if (key.length<min_length) return true;
		TreeIter iter, child;
		var found = new Gee.ArrayList<TreePath>();
		string name;
		if (store.get_iter_first(out iter)) {
			do { 
				if (store.iter_children(out child, iter)) {
					do { 
						store.@get(child, ItemFlag.NAME, out name, -1);
						if (name.has_prefix(key)) {
							found.@add(store.get_path(child));
						}
					} while (store.iter_next(ref child));	
				}
			} while (store.iter_next(ref iter));	
		}
		TreePath? path = null;
		var sel = view.get_selection();
		sel.unselect_all();
		if (found.size>0) {
			foreach (var p in found) {
				store.get_iter(out child, p);
				sel.select_iter(child);
				store.iter_parent(out iter, child);
				path = store.get_path(iter);
				view.expand_to_path(path);
			}
		}
		if (path!=null) {
			var col = view.get_column(ItemFlag.NAME);;
			view.scroll_to_cell(path, col, false, 0, 0);
		}
		return true;
	}

	public FixedPart(Debuggee dg, StackPart stack, DataPart data, 
					 Status status) {
		base(dg, stack, status, false);
		main = data;
		w = new Window();
		w.title = compose_title("Fixed data", dg.rts);
		w.@add(this);

		var buttons = new ButtonBox(Orientation.HORIZONTAL);
		pack_end(buttons, false, false, 0);
		buttons.set_layout(ButtonBoxStyle.END);
		var close = new Button.with_label("Close");
		buttons.@add(close);
		close.clicked.connect((b) => { do_close(); });
		delete_event.connect((e) => { return do_close(); });
		w.destroy.connect(() => { hide(); });
		
		TreePath path;
		TreeRowReference row;
		TreeIter iter, child;
		store = new TreeStore(Item.NUM_COLS, 
							  typeof(Expression?),	// expr
							  typeof(Entity*),		// field
							  typeof(uint8*),		// addr
							  typeof(int),			// index
							  typeof(int),			// mode
							  typeof(string),		// name
							  typeof(string),		// value
							  typeof(string),		// type
							  typeof(uint),			// type_id
							  typeof(bool),			// changed
							  typeof(string),		// cls
							  typeof(uint),			// cid
							  typeof(bool));	   	// fresh
		view.model = store;
		var sel = view.get_selection();
		sel.mode = SelectionMode.MULTIPLE;
		uint i=0, k=0, n, cid, tid;
		uint nt=dg.rts.class_count();
		uint nc=dg.rts.all_constants.length;
		uint no=dg.rts.all_onces.length;
		var rows = new TreeRowReference[nt];
		ClassText* ct;
		Gedb.Type* t;
		Constant* c = null;
		Gedb.Once* o = null;
		Entity* e = null;
		string? chn = null, ohn = null, cn = null ,on = null;
		string name = "", value = "", type = "";
		uint8* addr = null;
		char m;
		bool is_const, fresh;
		FormatStyle fmt = format_style();
		while (i<nc || k<no) {
			if (i<nc && c==null) {
				c = dg.rts.all_constants[i++];
				chn = c.home._name.fast_name;
				cn = c._entity._name.fast_name;
			}
			if (k<no && o==null) {
				o = dg.rts.all_onces[k++];
				ohn = o.home._name.fast_name;
				on = o._routine._entity._name.fast_name;
			}
			if (c!=null && o!=null) {
				if (chn.collate(ohn)<0) is_const = true;
				else if (chn.collate(ohn)>0) is_const = false;
				else if (cn.collate(on)<0) is_const = true;
				else  is_const = false;
			} else if (c!=null) {
				is_const = true;
			} else if (o!=null) {
				is_const = false;
			} else {
				break;
			}
			ct = is_const ? c.home : o.home;
			e = is_const ? (Entity*)c : (Entity*)o;
			t = e.type;
			tid = t!=null ? t.ident : 0;
			if (is_const) {
				m = DataMode.CONSTANT;
				name = e._name.fast_name;
				if (t.is_basic()) 
					addr = (uint8*)(&c.basic);
				else 
					addr = *(void**)c.ms;
				value = format_value(addr, 0, false, t, 0);
				type = t._name.fast_name;
				fresh = false;
			} else {
				m = DataMode.ONCE;
				e = (Entity*)o;
				name = on;
				value = "";
				if (o.is_function()) {
					type = t._name.fast_name;
					addr = o.value_address;
				} else {
					type = "";
					addr = null;
				}
				fresh = !o.is_initialized();
			}
			cid = ct.ident;
			if (rows[cid]==null) {
				store.append(out iter, null);
				store.@set(iter, 
						   Item.CLS, ct._name.fast_name, 
						   Item.CID, cid, 
						   ItemFlag.NAME, "",
						   ItemFlag.VALUE, "",
						   ItemFlag.TYPE, "", 
						   Item.FRESH, false,
						   -1);
				path = store.get_path(iter);
				rows[cid] = new TreeRowReference(store, path);
			} else {
				path = rows[cid].get_path();
				store.get_iter(out iter, path);
			}
			store.append(out child, iter);
			store.@set(child, ItemFlag.FIELD, e, 
					   ItemFlag.ADDR, addr, 
					   ItemFlag.NAME, name,
					   ItemFlag.VALUE, value, 
					   ItemFlag.TYPE, type,
					   ItemFlag.TYPE_ID, tid,
					   ItemFlag.MODE, (int)m, 
					   Item.FRESH, fresh,
					   -1);
			if (is_const) {
				c = null;
			} else {
				if (!fresh) set_once_value(child, o, fmt);
				o = null;
			}
		}
		n = nc+no;
		if (n>0) {
			n = (uint)(Math.log2(n)/3.0);
			min_length = n>0 ? n : 1;
		}	

		TreeViewColumn cls, name_col;
		cls = new TreeViewColumn.with_attributes("In Class", cell, 
												 "text", Item.CLS, null);
		cls.set_data<uint>("column", Item.CLS);
		cls.min_width = 80;
		cls.resizable = true;
		view.insert_column(cls, 0);
		view.search_column = Item.CLS;
		cell.strikethrough = true;
		name_col = view.get_column(0);
		name_col.add_attribute(cell, "strikethrough-set", Item.FRESH);
		view.expander_column = view.get_column(1);
		view.enable_search = true;
		view.search_column = ItemFlag.NAME;
		view.set_search_equal_func((m,c,s,i) => { return do_search(s); });

		info_list.@add(Item.CLS);

		main.reformatted.connect(do_reformat);
		main.notify["tree-lines"].connect((d,p) => { do_tree_lines(); });
		stack.level_selected.connect(
			(s,f,i,p) => { do_refresh(f,i,p); });
		show_all();
	}

} /* FixedPart */

public class DeepInfo { 

	public DeepInfo(DeepInfo? p, Entity* e, System* s, 
					int i=-1, int d=0, uint tid=0) {
		parent = p;
		field = e;
		index = i;
		depth = d;
		tp = tid>0 ? s.type_at(tid) : e.type;
	}

	public DeepInfo.from_expression(Expression ex, System* s) 
	requires (ex.bottom().address()!=null) {
		var tex = ex.bottom() as TextExpression;
		assert (tex!=null);
		this(null, tex.entity, s);
		expr = ex;
		tp = ex.dynamic_type;
		addr = ex.address();
	}

	public DeepInfo? parent { get; set; } 
	public Gedb.Type* tp { get; private set; } 
	public Expression? expr { get; private set; }
	public Entity* field { get; private set; } 
	public int index { get; private set; } 
	public int depth { get; private set; } 
	public uint8* addr { get; private set; } 
} 

public class DeepSource : MemorySource {

	private DataCore data;
	private Persistence<uint,void*> driver;

	public DeepSource(StackFrame* f, System* s, 
					  DataCore d, Persistence<uint,void*> io) { 
		base(f, s); 
		data = d;
		driver = io;
	}

	public override void set_local(Local* l, StackFrame* f) {
		base.set_local(l, f);
		if (!l._entity.type.is_subobject())
			fill_info(null, (Entity*)l, -1);
	}

	public override void set_once(Gedb.Once* o) {
		base.set_once(o);
		Entity* e = (Entity*)o;
		if (o._routine.is_function() && !e.type.is_subobject())
			fill_info(null, e, -1);
	}
	
	public override void set_field(Field* f, void* in_id) { 
		base.set_field(f, in_id);
		if (!f._entity.type.is_subobject())
			fill_info(in_id, (Entity*)f, -1);
	}

	public override void set_index(SpecialType* st, uint i, void* in_id) {
		base.set_index(st, i, in_id);
		Gedb.Type* it = st.item_type();
		if (!it.is_subobject())
			fill_info(in_id, (Entity*)st.item_0(), (int)i);
	}
	  
	private void fill_info(void* obj, Entity* e, int idx) {
		uint od = obj!=null ? driver.known_objects.@get(obj) : 0;
		data.fill_info(od, e, idx, offsets.depth());
	}

} /* class DeepSource */

public class FeatureMenu : Gtk.Menu {

	private DataCore data;
	private EvalPart eval;
	private Gee.HashMap<Gtk.MenuItem,DeepInfo> items;
	private uint up;

	private void do_feature(Gtk.MenuItem item) { 
		Entity* e;
		DeepInfo deep, right=null;
		string name, all="", prefix=null;
		int i = -1;
		for (deep=items.@get(item); deep!=null; deep=deep.parent) {
			e = deep.field;
			i = deep.index;
			if (right==null) {
				// extract name from menu item
				all = item.label;
				if (all=="") {
					all = deep.expr!=null ?
						deep.expr.append_name() : e._name.fast_name;
				} else { 
					var l = all.index_of_char(':');
					all = all.substring(0,l).strip();
					if (e.is_routine()) {
						var r = (Routine*)e;
						if (r.is_prefix()) {
							prefix = all;
							all = "";
						}
					}
				}
			} else {
				// compose name from parent
				name = deep.expr!=null 
					? deep.expr.append_name()
					: (i<0 ? e._name.fast_name : "[%u]".printf(i));
				if (name=="Current") ;
				else if (right.index<0 && right.field.text.alias_name==null) 
					all = name + "." + all;
				else 
					all = name + all;
			}
			right = deep;
		}
		switch (up) {
		case 0:
			break;
		case 1:
			all = "^" + all;
			break;
		case 2:
			all = "^^" + all;
			break;
		case 3:
			all = "^^^" + all;
			break;
		default:
			all = @"^$up^$all";
			break;
		}
		if (prefix!=null) all = @"$prefix($all)";
		eval.insert(all); 
	}

	private string add_short_type(string name, Entity* e) requires (e!=null) {
		string type = e.type._name.fast_name;
		if (type.length>20)  type = type.substring(0,18) + "...";
		return name + " : " + type;
	}

	private static int compare_routines(Routine* u, Routine* v) {
		if (u==v)  return 0;
		return  ((Entity*)u).is_less((Entity*)v) ? -1 : 1;
	}

	public FeatureMenu(DeepInfo deep, uint8* obj,
					   DataCore data, uint up, System* s) {
		ClassText* ct;
		Gedb.Type* t;
		Entity* e;
		Routine* r;
		FeatureText* x;
		DeepInfo down;
		Expression ex, arg, prev;
		Gtk.MenuItem item;
		string name;
		uint tid;
		uint i, j, m, n;
		bool alias;

		this.data = data;
		this.up = up;
		eval = data.main!=null ? 
			data.main.eval : (data as DataPart).eval;
		items = new Gee.HashMap<Gtk.MenuItem,DeepInfo>();
		t = deep.tp;

		item = new Gtk.MenuItem.with_label("");	// self
		append(item);
		++size;
		item.show();
		item.activate.connect(do_feature);
		items.@set(item, deep);

		ct = t.base_class;
		i = 0;
		for (j=t.constant_count(); j-->0;) {
			Constant* c = t.constant_at(j);
			e = (Entity*)c;
			if (i==0) {
				item = new SeparatorMenuItem();
				append(item);
				item.show();
				item = new Gtk.MenuItem.with_label("Constants");
				append(item);
				item.show();
				item.sensitive = false;	
			}
			x = e.text;
			alias = x.alias_name!=null;
			name = alias ? x.alias_name : e._name.fast_name;
			name = add_short_type(name, e);
			item = new Gtk.MenuItem.with_label(name);
			append(item);
			++size;
			item.show();
			item.activate.connect(do_feature);
			down = new DeepInfo(deep, e, s, -1, deep.depth+1);
			items.@set(item, down);
			++i;
		}

		n = t.field_count();
		if (n>0) {
			item = new SeparatorMenuItem();
			append(item);
			item.show();
			item = new Gtk.MenuItem();
			item.label = t.is_agent() ? "Closed operands" : "Attributes";
			append(item);
			item.show();
			item.sensitive = false;
			for (i=0; i<n; i++) {
				e = (Entity*)t.fields[i];
				x = e.text;
				if (x==null)  continue;
				alias = x.alias_name!=null;
				name = alias ? x.alias_name : e._name.fast_name;
				name = add_short_type(name, e);
				item = new Gtk.MenuItem.with_label(name);
				append(item);
				++size;
				item.show();
				item.activate.connect(do_feature);
				down = new DeepInfo(deep, e, s, -1, deep.depth+1);
				items.@set(item, down);
			}
		}

		n = t.routine_count();
		if (!t.is_basic()) 
			if (!t.base_class.is_debug_enabled()) n = 0;
		var flist = new Gee.ArrayList<Routine*>();
		for (i=n; i-->0;) {
			r = t.routines[i];
			if (r.is_function()) flist.@add(r);
		}
		n = flist.size;
		if (n>0) {
			flist.sort(compare_routines);
			item = new SeparatorMenuItem();
			append(item);
			item.show();
			item = new Gtk.MenuItem.with_label("Functions");
			append(item);
			item.show();
			item.sensitive = false;
			for (i=0; i<n; i++) {
				r = flist.@get((int)i);
				if (r.is_once())  continue;
				e = (Entity*)r;
				x = e.text;
				if (x==null)  continue;
				item = new Gtk.MenuItem();
				append(item);
				++size;
				item.show();
				item.activate.connect(do_feature);
				down = new DeepInfo(deep, e, s, -1, deep.depth+1);
				items.@set(item, down);
				m = r.argument_count;
				if (x.alias_name=="[]") {
					name = "["; 
				} else if (x.alias_name!=null) {
					name = x.alias_name;
				} else {
					name = e._name.fast_name;
					if (m>1) name += "(";
				}
				for (j=1; j<m; ++j) {
					if (j>1) name += ",";
					name += bullet;
				}
				if (x.alias_name=="[]") name += "]";
				else if (m>1 && x.alias_name==null) name += ")";
				name = add_short_type(name, e);
				item.label = name;
			}
		}

		ct = t.base_class;
		i = 0;
		for (j=s.once_count(); j-->0;) {
			Gedb.Once* o = s.once_at(j);
			if (o.home!=ct || !o.is_function() || !o.is_initialized()) continue;
			if (i==0) {
				item = new SeparatorMenuItem();
				append(item);
				item.show();
				item = new Gtk.MenuItem.with_label("Once functions");
				append(item);
				item.show();
				item.sensitive = false;	
			}
			e = (Entity*)o;
			x = e.text;
			alias = x.alias_name!=null;
			name = alias ? x.alias_name : x._name.fast_name;
			name = add_short_type(name, e);
			item = new Gtk.MenuItem.with_label(name);
			append(item);
			++size;
			item.show();
			item.activate.connect(do_feature);
			down = new DeepInfo(deep, e, s, -1, deep.depth+1);
			items.@set(item, down);
			++i;
		}
	}

	public uint size { get; private set; }

} /* class FeatureMenu */

enum Query {
	NAME = 0,
	ARGS,
	ENTITY,
	KIND, 
	NUM_COLS
}
	
public class EvalPart : Grid {

	private DataPart? data;
	private Entry result;
	private Entry edit;
	private Expression? result_expr;
	private ExpressionChecker checker;
	private StackFrame* frame;

	private Gee.Map<string,Expression> aliases;
	private ulong moved_id;
	private bool changed;
	private bool expanding = true;

	private static Expression? id_to_expr(uint id, Object data) {
		var dp = data as DataPart;
		return dp!=null ? dp.id_to_expr(id) : null;
	}

	private void set_result(Expression? expr) {
		string text = "";
		result_expr = expr;
		if (expr!=null) {
			int pos = edit.cursor_position;
			var ex = checker.expression_at(pos, false);
			if (ex!=null) {
				int fmt = -1;
				if (!expanding) 
					fmt -= ex.Format.EXPAND_ALIAS + ex.Format.EXPAND_PH;
				text = ex.format_one_value(fmt);
				do_data_selected(data.selected_item());
			} 
		}
		result.set_text(text); 
	}
	
	private bool do_check_expression() {
		checker.reset();
		string str = edit.get_text();
		if (str.strip().length==0) return false; 
		bool ok = checker.check_dynamic
			(str, null, data.frame, data.dg.rts, true, 
			 aliases, null, id_to_expr, data);
		if (!ok) return false;
		var ex = (!) checker.parsed;
		history.add_item(ex.append_name(), false);
		changed = false;
		set_result(ex);
		return true;
	}
	
	private void do_moved(Object obj) { 
		int pos = edit.cursor_position;
		if (changed) return;
		var ex = checker.expression_at(pos, false);
		set_result(ex); 
	}
	
	private void do_changed() { 
		changed = true; 
		set_result(null);
	}

	private void do_edit_icon(EntryIconPosition pos) {
		if (pos==EntryIconPosition.PRIMARY) {
			if (checker.parsed!=null) data.add_expression(checker.parsed);
		} else {
			checker.reset();
			edit.text = "";
			result.text = "";
			edit.grab_focus();
		}
	}
	
	private void do_data_selected(DataItem? sel) {
		result.primary_icon_sensitive = 
			sel!=null && result_expr!=null
			&& sel.mode!=DataMode.CURRENT 
			&& sel.mode!=DataMode.EXTERN 
			&& sel.field.is_assignable_from(result_expr.bottom().dynamic_type);
	}

	private void do_result_icon(EntryIconPosition pos) {
		if (pos==EntryIconPosition.PRIMARY) {		
			if (result_expr==null)  return;
			data.assign(result_expr.bottom());
		} else {
			expanding = !expanding;
			string zoom = expanding ? Stock.ZOOM_OUT : Stock.ZOOM_IN;
			result.set_icon_from_stock(EntryIconPosition.SECONDARY, zoom);
			set_result(result_expr);
		}
	}
	
	private void do_set_sensitive(bool is_running) {
		sensitive = !is_running;
	}

	private void do_new_exe(Debuggee dg) {
		history.clear();
	}

	public EvalPart(Debuggee dg, DataPart d) {
		Label label;
		
		aliases = d.aliases;
		data = d;
		checker = new ExpressionChecker();

		label = new Label("Value ");
		attach(label, 0, 0, 1, 1);
		label.hexpand = false;
		label.halign = Align.START;
		result = new Entry();
		attach(result, 1, 0, 3, 1);
		result.hexpand = true;
		result.editable = false;
		result.set_icon_from_stock(EntryIconPosition.PRIMARY, Stock.APPLY);
		result.primary_icon_tooltip_text =
			"Assign value to selected item\nin data list.";
		result.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.ZOOM_OUT);
		result.secondary_icon_tooltip_text = 
			"Toggle placeholder representation.";
		expanding = true;
		result.icon_release.connect((p,ev) => { do_result_icon(p); });
		
		label = new Label("Expr");
		attach(label, 0, 1, 1, 1);
		label.hexpand = false;
		label.halign = Align.START;
		history = new HistoryBox("Expressions");
		attach(history, 1, 1, 3, 1);
		history.selected.connect((h) => { do_check_expression(); });
		edit = history.get_child() as Entry;
		edit.hexpand = true;
		edit.editable = true;
		edit.placeholder_text = "Expression list";
		edit.set_icon_from_stock(EntryIconPosition.PRIMARY, Stock.PASTE);
		edit.primary_icon_tooltip_text = "Copy values to data list.";
		edit.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.CLEAR);
		edit.icon_release.connect((p,ev) => { do_edit_icon(p); });
		edit.activate.connect((e) => { do_check_expression(); });
//		edit.changed.connect(do_changed);
		moved_id = edit.notify["cursor-position"].connect_after(
			(e,p) => { do_moved(e); });
		attach(checker, 1, 3, 3, 1);

		data.item_selected.connect(do_data_selected);
		dg.new_executable.connect(() => { do_new_exe(dg); });
		dg.notify["is-running"].connect(
			(g,p) => { do_set_sensitive(dg.is_running); });
	}
	
	public HistoryBox history { get; private set; }

	public void compute(string str, bool move_cursor_at_end=false) {
		edit.text = str;
		edit.activate();
		if (move_cursor_at_end) 
			edit.move_cursor(MovementStep.VISUAL_POSITIONS, str.length, false);
	}
	
	public void insert(string str) { 
		int n = edit.cursor_position;
		string text = edit.text;
		text = text.splice(n, n, str);
		edit.text = text;
		edit.move_cursor(MovementStep.LOGICAL_POSITIONS, text.length, false);
	}

} /* EvalPart */
