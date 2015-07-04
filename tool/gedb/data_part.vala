using Gtk;
using Gedb;

public class DataCore : Box, AbstractPart {

	protected StackPart stack;
	protected Status status;
	public DataPart? main;
	public Debuggee? dg;
	public FormatStyle style { get; protected set; }

	protected Adjustment items;
	protected Scrollbar items_bar;
	protected TreePath? items_path;
	protected TreeStore store;
	protected TreeView view { get; protected set; }
	protected CellRendererText cell;
	protected Gee.List<uint> info_list;
	public bool tree_lines { get; set; }
	public bool dense { get; set; }
	public int max_items { get; set; }
	public int float_prec { get; set; }
	public int double_prec { get; set; }

	public StackFrame* frame { get; protected set; }
	protected Routine* routine;
	
	protected void set_value(TreeIter iter, uint8* addr, bool is_home,
							 Entity* e, SpecialType* st, int idx,
							 char mode, string? name=null,
							 Expression? ex=null)
	requires (e!=null || st!=null || ex!=null || dg==null) {
		Gedb.Type* t = st!=null
			? st.item_type()
			: (e!=null ? e.type : ex.dynamic_type);
		string nm = name!=null ? name : ((Name*)e).fast_name;
		int off = 0;
		if (is_home) {
			if (idx<0) {
				if (e.is_field()) off = ((Field*)e).offset;
				if (e.is_local()) off = ((Local*)e).offset;
			} else {
				off = st.item_offset(idx);
			}
			addr += off;
			addr = t.dereference(addr);
		}
		if (!t.is_subobject()) {
			var old_t = t;
			t = dg.rts.type_of_any(addr, old_t);
			addr = dg.rts.unboxed(addr, old_t);
		}
		string value, type;
		uint tid;
		if (t==null) {
			value = "???";
			type = "???";
			tid = TypeIdent.NONE;
		} else {
			value = format_value(addr, 0, false, t, style, known_objects);
			type = format_type(addr, 0, false, t, e!=null ? e.text : null);
			tid = dg.rts.object_type_id(addr, false, t);
		}
		store.@set(iter,
				   ItemFlag.EXPR, ex,
				   ItemFlag.FIELD, e,
				   ItemFlag.ADDR, addr,
				   ItemFlag.INDEX, st!=null ? idx : -1,
				   ItemFlag.FIRST, 0,
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
		if (dg==null) return;
		store.@get(iter, ItemFlag.ADDR, out addr,
				   ItemFlag.TYPE_ID, out tid, -1);
		t = dg.rts.type_at(tid);
		var value = format_value(addr, 0, false, t, style, known_objects);
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
	
	internal void update_subtree(TreeIter iter, uint8* addr, bool prec_only) {
		if (dg==null) return;
		Gedb.Type* t;
		Gedb.Type* ft;
		Field* f;
		Entity* e;
		Entity* pe;
		FeatureText*[] labels;
		Expression? ex;
		TreePath path = store.get_path(iter);
		TreeIter child = iter;
		string str, old_val, value, old_type, type;
		uint8* old_addr, heap;
		uint n, m_old, tid, tid_old, step;
		int i, j, m, off, idx, first;
		char mode;
		bool ok=true, changed;
		store.@get(iter,
				   ItemFlag.MODE, out i,
				   ItemFlag.EXPR, out ex,
				   ItemFlag.FIELD, out e,
				   ItemFlag.INDEX, out idx,
				   ItemFlag.FIRST, out first,
				   ItemFlag.ADDR, out old_addr,
				   ItemFlag.NAME, out str,
				   ItemFlag.VALUE, out old_val,
				   ItemFlag.TYPE, out old_type, 				
				   ItemFlag.TYPE_ID, out tid_old,
				   -1);
		mode = (char)i;
		if (addr==null)
			addr = old_addr;
		if (ex!=null) {
			t = ex.dynamic_type;
			addr = ex.address();
			ok = false;
		} else {
			if (e!=null) t = e.type;
			else if (idx>=0) t = dg.rts.type_at(tid_old);
			else return;
			if (t==null || !t.is_subobject()) t = dg.rts.type_of_any(addr, t);
		}
		addr = dg.rts.unboxed(addr, e.type);
		tid = t!=null ? t.ident : 0;
		value = format_value(addr, 0, false, t, style, known_objects);
		type = format_type(addr, 0, false, t, e!=null ? e.text : null);
		changed = value!=old_val || type!=old_type;
		if (changed) {
			store.@set(iter, ItemFlag.ADDR, addr, ItemFlag.VALUE, value,
					   ItemFlag.TYPE_ID, tid, ItemFlag.TYPE, type, -1);
		}
		if (!prec_only)
			store.@set(iter, ItemFlag.CHANGED, changed, -1);
		m_old = store.iter_n_children(iter);
		if (t.is_special()) {
			SpecialType* st = (SpecialType*)t;				
			n = st.special_count(addr);
		} else {
			n = t.field_count();
		}
		bool expand = n>0 && tid==tid_old;
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
			if (n==0) {	// remove the dummy ident
				while (store.iter_nth_child(out child, iter, (int)n))
					store.@remove(ref child);
			}
			move_items(iter, first, !prec_only);
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
				heap = dg.rts.unboxed(heap, f._entity.type);
				if (store.iter_nth_child(out child, iter, i))
					update_subtree(child, heap, prec_only);
			}
			if (t.is_agent() && n<t.field_count()) {
				f = t.field_at(n);
				heap = f._entity.type.dereference(old_addr+f.offset);
				if (store.iter_nth_child(out child, iter, i))
					update_subtree(child, heap, prec_only);
			}
		}
	}

	protected void do_display_mode(CellRendererText ct, TreeIter iter) {
		int mode;
		store.@get(iter, ItemFlag.MODE, out mode, -1);
		ct.text = "%c".printf((char)mode);
	}

	protected void do_precision(bool as_double) {
		TreeIter iter;
		store.get_iter_first(out iter);
		update_subtree(iter, null, true);
	}

	protected virtual void do_refresh(StackFrame* f, uint class_id, uint pos) {
		if (dg==null) return;
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
		known_objects = null;
		if (style==FormatStyle.IDENT) {
			refill_known_objects(dg.rts);
		}
		for (n=store.iter_n_children(null); n-->0;) {
			store.iter_nth_child(out iter, null, (int)n);
			store.@get(iter, ItemFlag.MODE, out ch, -1);
			if (ch==DataMode.EXTERN) store.@remove(ref iter);
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
			update_subtree(iter, target, false);
		} else {
			clear_subtree(null);
			value = format_value(addr, off, true, lt, style, known_objects);
			store.append(out iter, null);
			set_value(iter, target, false, (Entity*)loc, null, -1,
					  DataMode.CURRENT);
			store.@set(iter, ItemFlag.CHANGED, true, -1);
			add_dummy_item(iter, lt, false);
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
			if (ok && loc==e) {
				update_subtree(iter, laddr, false);
			} else {
				store.insert(out iter, null, j);
				set_value(iter, laddr, false, (Entity*)loc, null, -1, ch);
				store.@set(iter, ItemFlag.CHANGED, true, -1);
				add_dummy_item(iter, lt, false);
			}
			++j;
		}
	}

	protected void add_dummy_item(TreeIter iter, Gedb.Type* t, bool anyway) {
		int k = store.iter_n_children(iter);
		if (k>1) return;
		if (k==1) {
			TreeIter child;
			int mode;
			store.iter_nth_child(out child, iter, 0);
			store.@get(child, ItemFlag.MODE, out mode, -1);
			if (mode==DataMode.DUMMY) return;
		}
		if (!anyway) {
			if (t.is_string() || t.is_unicode() || t.field_count()==0) 
				return;
			if (t.is_special()) {
				var st = (SpecialType*)t;
				uint8* addr;
				store.@get(iter, ItemFlag.ADDR, out addr, -1);
				uint n = st.special_count(addr);
				if (n==0) return;
			}
		}
		TreeIter child;
		store.append(out child, iter);
		store.@set(child, ItemFlag.MODE, DataMode.DUMMY, -1);
	}

	protected virtual void do_expand(TreeIter iter) {
		if (dg==null) return;
		Gedb.Type* t, ft;
		Field* f;
		Entity* e, pe;
		Expression? ex, exb, detail;
		TreeIter child;
		string str, type;
		uint8* addr, heap;
		uint i, tid;
		int first;
		DataMode mode;
		uint n = store.iter_n_children(iter);
		if (n>1) return;
		if (n==1) {
			store.iter_nth_child(out child, iter, 0);
			store.@get(child, ItemFlag.MODE, out i, -1);
			switch (i) {
			case DataMode.DUMMY:
			case DataMode.EXTERN:
				break;
			default:
				return;
			}
		}
		bool more = n==0; // `n>0' means that the dummy item is to be replaced
		store.@get(iter,
				   ItemFlag.ADDR, out addr,
				   ItemFlag.FIRST, out first,
				   ItemFlag.TYPE_ID, out tid,
				   ItemFlag.EXPR, out ex,
				   -1);
		if (addr==null && ex!=null) addr = ex.address();
		assert (addr!=null);
		mode = DataMode.FIELD;
		t = dg.rts.type_at(tid);
		detail = ex!=null ? ex.resolve_alias().bottom().detail : null;
		if (detail!=null) {
			mode = DataMode.EXTERN;
			n = 0;
			for (; detail!=null; detail=detail.next) {
				if (!more)
					store.iter_nth_child(out child, iter, 0);
				else
					store.append(out child, iter);
				exb = detail.bottom();
				heap = exb.address();
				str = detail.append_qualified_name(null, exb);
				set_value(child, heap, false, null, null, -1, mode, str, exb);
				add_dummy_item(child, ex.dynamic_type, true);
				do_expand(child);
				view.expand_row(store.get_path(child), false);
				more = true;
				++n;
			}
		} else if (t.is_special()) {
			SpecialType* st = (SpecialType*)t;
			n = st.special_count(addr);
			if (store.iter_nth_child(out child, iter, 0))
				store.@remove(ref child);
			move_items(iter, first, false);
			n = store.iter_n_children(iter);
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
		view.expand_row(store.get_path(iter), false);
		adjust_visibility(iter);
	}

	protected void do_reformat() {
		if (dg==null) return;
		switch (style) {
		case FormatStyle.IDENT:
			refill_known_objects(dg.rts);
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
		reformatted(style);
	}

	protected void adjust_visibility(TreeIter iter) {
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

	private void add_item(TreeIter iter, Entity* e, uint8* addr, DataMode mode,
						  int replace=-1, int array_idx=-1, int tuple_idx=-1) {
		if (dg==null) return;
		TreeIter child;
		int off = e.is_local() ? ((Local*)e).offset : ((Field*)e).offset;
		var ft = dg.rts.type_of_any(addr, e.type);
		string str;
		if (replace>=0)
			store.iter_nth_child(out child, iter, replace);
		else
			store.append(out child, iter);
		if (array_idx>=0) {
			str = "[%d]".printf(array_idx);
		} else {
			str = e._name.fast_name;
		}
		str = null;
		if (tuple_idx>=0) {
			Entity* pe;
			store.@get(iter, ItemFlag.FIELD, out pe, -1);
			if (pe!=null && pe.text!=null && pe.text.tuple_labels!=null)
				str = pe.text.tuple_labels[tuple_idx]._name.fast_name;
		}
		set_value(child, addr, false, e, null, -1, DataMode.FIELD, str);
		add_dummy_item(child, ft, false);
	}

	protected virtual void do_collapse(TreeIter iter) {
		if (dg==null) return;
		Gedb.Type* t;
		Expression? ex;
		TreeIter child;
		uint tid;
		int mode;
		store.@get(iter, 
				   ItemFlag.TYPE_ID, out tid, 
				   ItemFlag.EXPR, out ex, 
				   -1);
		int i, n = store.iter_n_children(iter);
		for (i=n; i-->0;) {
			store.iter_nth_child(out child, iter, i);
			store.@remove(ref child);
		}
		bool deep = ex!=null ? ex.detail!=null : false;
		t = dg.rts.type_at(tid);
		if (deep || t!=null && t.field_count()>0) 
			add_dummy_item(iter, dg.rts.type_at(tid), deep);
	}

	private string add_short_type(string name, Entity* e) requires (e!=null) {
		string type = e.type._name.fast_name;
		if (type.length>20) type = type.substring(0,18) + "...";
		return name + " : " + type;
	}

	private static int compare_routines(Routine* u, Routine* v) {
		if (u==v) return 0;
		return ((Entity*)u).is_less((Entity*)v) ? -1 : 1;
	}

	protected virtual bool valid_feature(TreeIter iter) { return true; }

	private void move_items(TreeIter iter, int first, bool as_changed) {
		Gedb.Type* t, ft;
		Expression? ex;
		RangeExpression? exr = null;
		ItemExpression? exi = null;
		Expression? exd = null;
		TreeIter child;
		uint8* addr=null, faddr, heap;
		string val=null, str;
		uint tid;
		int i, j, n, idx=0;
		store.@get(iter,
				   ItemFlag.ADDR, out addr,
				   ItemFlag.TYPE_ID, out tid,
				   ItemFlag.EXPR, out ex,
				   -1);
	    t = dg.rts.type_at(tid);
		if (t==null || !t.is_special()) return;
		if (ex!=null) {
			exr = ex.resolve_alias().bottom().range as RangeExpression;
			if (exr==null) return;
		}
		SpecialType* st = (SpecialType*)t;
		Entity* e = (Entity*)st.item_0();
		faddr = addr + st.item_offset(first);
		uint step = st.item_type().field_bytes();
		n = (int)st.special_count(addr);
		j = store.iter_n_children(iter);
		if (j==1) {
			store.iter_nth_child(out child, iter, 0);
			store.@get(child, ItemFlag.MODE, out i, -1);
			if (i==DataMode.DUMMY) store.remove(ref child);
		}
		for (i=first,idx=i+1, j=0; j<max_items && i<n; ++i, faddr+=step) {
			// `i' points to the next not yet treated array item
			// `j' points to the next not yet checked table item
			heap = e.type.dereference(faddr);
			if (dense && (heap==null || is_zero_value(heap,step))) 
				continue;
			for (; store.iter_nth_child(out child, iter, j);) {
				store.@get(child, ItemFlag.INDEX, out idx, -1);
				if (idx>=i) break;
				store.@remove(ref child);
				idx = i+1;	// make last `idx' invalid;
			}
			if (idx==i) {	// accept item at `idx' but update contents
				++j;
				if (!as_changed) continue;
				store.@get(child, ItemFlag.VALUE, out val, -1);	
			} else {
				store.insert(out child, iter, j);
				++j;
			}
			ft = dg.rts.type_of_any(heap, e.type);
			if (exr!=null) {
				if (!exr.in_range(i, frame, dg.rts)) continue;
				exi = exr.as_item(i);
				exi.compute_in_object(addr, t, dg.rts, frame);
				exd = exi.detail;
			}
			add_dummy_item(child, ft, exd!=null);
			set_value(child, heap, false, e, st, i, DataMode.FIELD, @"[$i]", exi);
			if (exd!=null) do_expand(child);
			if (as_changed) store.@set(child, ItemFlag.CHANGED, true, -1);
		}
		for (; store.iter_nth_child(out child, iter, j);) 
			store.@remove(ref child);
		store.@set(iter, ItemFlag.FIRST, first, -1);
	}

	protected virtual bool do_select(TreeSelection s,
									 TreeModel m, TreePath p, bool yes) {
		Gedb.Type* t;
		TreeIter iter, child;
		uint tid;
		m.get_iter(out iter, p);
		m.@get(iter, ItemFlag.TYPE_ID, out tid, -1);
		t = dg.rts.type_at(tid);
		if (t==null || !t.is_special() || !view.is_row_expanded(p)) {
			items_bar.sensitive = false;
			items_path = null;
			return true;
		}
		SpecialType* st = (SpecialType*)t;
		uint8* addr;
		int low, high, l, n;
		m.@get(iter, ItemFlag.ADDR, out addr, -1);
		n = (int)st.capacity(addr);
		l = m.iter_n_children(iter)-1;
		assert (l>=0);
		m.iter_nth_child(out child, iter, 0);
		m.@get(child, ItemFlag.INDEX, out low, -1);
		m.iter_nth_child(out child, iter, l);
		m.@get(child, ItemFlag.INDEX, out high, -1);
		items.lower = 0;
		items.upper = n-1;
		items.page_size = high-low;
		items.value = low;
		items_bar.sensitive = true;
		items_path = store.get_path(iter);
		return true;
	}

	uint move_timeout;

	private void do_move_items() {
		if (!items_bar.sensitive) return;
		if (move_timeout==0)
			move_timeout = GLib.Timeout.@add(40, () => {
					TreeIter iter;
					move_timeout = 0;
					if (items_path==null) return false;
					store.get_iter(out iter, items_path);
					move_items(iter, (int)items.value, false);
					return false;
				});
	}

	private Gtk.Menu typeset_menu;

	private bool do_typeset(Gdk.EventButton ev, TreeIter iter) {
		Gedb.Type* type;
		Gedb.Type*[] typeset;
		Entity* e;
		Gtk.MenuItem item, sel = null;
		uint tid;
		int idx, i, n, mode;
		store.@get(iter,
				   ItemFlag.FIELD, out e,
				   ItemFlag.INDEX, out idx,
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
		if (dg==null) return false;
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
			if (name==null || name=="") break;
			pinfo = ex!=null && ex.bottom().address()!=null
				? new DeepInfo.from_expression(ex)
				: new DeepInfo(null, e, i, addr, dg.rts.type_at(tid));
			if (info==null) last = pinfo;
			else  info.parent = pinfo;
			info = pinfo;
		}
		uint up = (main!=null && frame!=null) ?
			main.frame.depth-frame.depth : 0;
		menu = new FeatureMenu(dotted_name(last), up, last.tp, this, dg.rts);
		menu.popup(null, null, null, ev.button, ev.time);
		return true;
	}

	protected void do_tree_lines() {
		var d = main!=null ? main : this;
		view.enable_tree_lines = d.tree_lines;
	}

	protected void do_items() {
		if (main!=null) {
			dense = main.dense;
			max_items = main.max_items;
		}
		StackFrame* f = stack.frame();
		if (f!=null) do_refresh(f, f.class_id, f.pos);
	}
	
	protected virtual void do_set_sensitive(bool is_running) {
		set_deep_sensitive(this, !is_running);
	}

	public string do_deep(TreeModel model, TreeIter at, uint col) {
		string text;
		store.@get(at, col, out text, -1);	
		if (col==ItemFlag.VALUE && style==FormatStyle.IDENT) {
			if (text.length<1 || text[0]!='_') return text;
			text = text.substring(1);
			int id = int.parse(text);
			if (id<=0) return "";
			var info = deep_info[id];
			text = dotted_name(info);
			if (info.addr==null) return text;
			text += " = " + format_value(info.addr, 0, false, info.tp, 0);
			text += " : " + format_type(info.addr, 0, false, info.tp);
			return text;
		} else if (col==ItemFlag.NAME) {
			TreeIter p = at;
			string str;
			for (; model.iter_parent(out p, at); at=p) {
				model.@get(p, col, out str, -1);
				if (text.@get(0)!='[') str += ".";
				text = str+text;
			}
			return text;
		} else {
			return text;
		}
	}
	
	protected DataCore(StackPart stack, Status state, FormatStyle[] ff) {
		this.stack = stack;
		status = state;
		orientation = Orientation.VERTICAL;

		store = new TreeStore(ItemFlag.NUM_COLS,
							  typeof(Expression?),	// expr
							  typeof(Entity*),		// field
							  typeof(uint8*),		// addr
							  typeof(int),			// index
							  typeof(int),			// first
							  typeof(int),			// mode
							  typeof(string),		// name
							  typeof(string),		// value
							  typeof(string),		// type
							  typeof(uint),			// type_id
							  typeof(bool));		// changed
		view = new TreeView.with_model(store);
		view.headers_visible = true;
		view.headers_clickable = false;
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

		var box = new Box(Orientation.HORIZONTAL, 0);
		pack_start(box, true, true, 3);
		items = new Adjustment(10.0, 1.0, 100.0, 1.0, 10.0, 0.0);
		items_bar = new Scrollbar(Orientation.VERTICAL, items);
		items_bar.sensitive = false;
		box.pack_start(items_bar, false,false, 3);
		items.value_changed.connect((i) =>  do_move_items());

		ScrolledWindow scroll = new ScrolledWindow(null, null);
		box.pack_start(scroll, true, true, 0);
		scroll.min_content_width = 360;
		scroll.min_content_height = 300;
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

		if (ff==null || ff.length==0) return;
		ButtonBox buttons = new ButtonBox(Orientation.HORIZONTAL);
		buttons.set_layout(ButtonBoxStyle.START);
		buttons.@add(new Label("Format:"));
		pack_start(buttons, false, false, 3);
		unowned GLib.SList<RadioButton> group = null;
		RadioButton rb = null;
		foreach (var f in ff) {
			switch (f) {
			case FormatStyle.ADDRESS:
				rb = add_format(buttons, rb!=null ? rb.get_group() : null,
								f, "natural",
								"Show address\nof reference objects.");
				break;
			case FormatStyle.IDENT:
				rb = add_format(buttons, rb!=null ? rb.get_group() : null,
								f, "ident",
								"Show internal ident\nof reference objects.");
				break;
			case FormatStyle.HEX:
				rb = add_format(buttons, rb!=null ? rb.get_group() : null,
								f, "hex",
								"Show hexadecimal form\nof all values.");
				break;
			}
		}
	}

	protected DataCore.additionally(DataPart d, StackPart s, FormatStyle[] ff) {
		this(s, d.status, ff);
		main = d;
		dg = d.dg;
	}
	
	private RadioButton add_format(ButtonBox bb, GLib.SList<RadioButton>? g,
								   FormatStyle f, string name, string tt) {
		var rb = new RadioButton.with_label(g, name);
		rb.active = g==null;
		bb.@add(rb);
		rb.set_tooltip_text(tt);
		rb.has_tooltip = true;
		rb.toggled.connect((b) => {
				if (style==f) return;
				style=f;
				do_reformat();
			});
		return rb;
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

	private MemorySource deep_source;

	private void add_deep_info(uint od, void* id, Gedb.Type* t,
							   void* w, Entity* e, int i) {
		if (_deep_info.length<=od) _deep_info.resize((int)(2*od+1));
		var p = deep_info[known_objects[w]];
		_deep_info[od] = new DeepInfo(p, e, i, id, t);
	}

	private void improve_deep_info(uint od, void *w, Entity* e, int i) {
		var old = _deep_info[od];
		if (old.parent==null) return; // cannot be improved;
		if (w==null) { // is root
			old.reparent(null, e, i);
		} else {
			var now = _deep_info[known_objects[w]];
			if (old.parent.depth > now.depth) old.reparent(now, e, i);
		}
	}

	public string dotted_name(DeepInfo info, bool with_current=false) {
		if (info==null) return "";
		int idx = info.index;
		Entity* f = info.field;
		string name;
		if (f!=null) {
			name = ((Name*)f).fast_name;
			if (info.field.is_once()) {
				var o = (Gedb.Once*)info.field;
				name = "{" + ((Name*)o.home).fast_name + "}." + name;
			} else if (info.field.is_constant()) {
				var o = (Gedb.Constant*)info.field;
				name = "{" + ((Name*)o.home).fast_name + "}." + name;
			}
		} else {
			name = @"$idx";
		}
		if (name==null) name = "";
		DeepInfo? pinfo = info.parent;
		if (pinfo!=null) {
			string text = dotted_name(pinfo);
			if (!with_current && text=="Current") return name;
			return idx<0 ? @"$text.$name" : @"$text[$name]";
		}
		return name;
	}

	public void refill_known_objects(System* s) {
		if (known_objects!=null) return;
		deep_info = new DeepInfo[99];
		var d = new Persistence<uint,void*>();
		known_objects = d.known_objects;
		d.when_new.connect((od,id,t,n,p,e,i) =>
			{ add_deep_info(od,id,t,p,e,i); });
		d.when_known.connect((od,id,t,n,p,e,i) =>
			{ improve_deep_info(od,p,e,i); });
		deep_source = new MemorySource(frame, s);
		d.traverse_stack(new NullTarget(), deep_source, frame, s, true);
	}

	private TextExpression? id2expr(DeepInfo info) {
		var p = info.parent;
		var f = info.field;
		Expression? pex = p!=null ? id2expr(p) : null;
		TextExpression tex = null;
		if (info.index>=0)
			tex = new ItemExpression.computed(pex, info.index, dg.rts);
		 else if (f.text!=null)
			tex = new TextExpression.computed(f, info.addr, dg.rts);
		info.expr = tex;
		if (pex!=null) pex.set_child(pex.Child.DOWN, tex);
		return tex;
	}

	public TextExpression? id_to_expr(uint id) {
		if (known_objects==null || dg==null) return null;
		if (id>=_deep_info.length) return null;
		var info = _deep_info[id];
		if (info==null) return null;
		return id2expr(info);
	}

	public void set_debuggee(Debuggee? dg) {
		this.dg = dg;
		eval.set_debuggee(dg);
		var dp = this as DataPart;
		if (dp!=null) dp.more_data.clear();
		set_sensitive(dg!=null);
		if (dg!=null) {
			dg.notify["is-running"].connect(
				(g,p) => { do_set_sensitive(dg.is_running); });
		}
	}

	public signal void item_selected(DataItem? item);
	public signal void reformatted(FormatStyle style);
}

public class DataPart : DataCore {

	internal Gee.List<MoreDataPart> more_data;
	internal Gee.Map<string,Expression> aliases;

	protected override bool do_select(TreeSelection s,
									  TreeModel m, TreePath p, bool yes) {
		bool ok = base.do_select(s, m, p, yes);
		TreeIter iter;
		int mode;
		m.get_iter(out iter, p);
		m.@get(iter, ItemFlag.MODE, out mode, -1);
		return mode!=DataMode.CURRENT && mode!=DataMode.EXTERN;
	}

	public DataPart(StackPart sp, Status state,
					Gee.Map<string,Expression> aliases) {
		base(sp, state, {FormatStyle.ADDRESS,FormatStyle.IDENT,FormatStyle.HEX});
		main = null;
		more_data = new Gee.ArrayList<MoreDataPart>();
		this.aliases = aliases;
		eval = new EvalPart(this);
		TreeSelection sel = view.get_selection();
		sel.mode = SelectionMode.SINGLE;
		sel.set_select_function(do_select);

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
		
		tree_lines = false;
		dense = false;
		max_items = 10;
		notify["tree-lines"].connect((d,p) => { do_tree_lines(); });
		notify["max-items"].connect((d,p) => { do_items(); });
		notify["dense"].connect((d,p) => { do_items(); });
		notify["float-prec"].connect((d,p) => { do_precision(false); });
		notify["double-prec"].connect((d,p) => { do_precision(true); });
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
		if (lhs==null) return;
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
		string value = format_value(right, 0, false, t, style,
									known_objects);
		string type = format_type(right, 0, false, t);
		store.@set(lhs.iter,
				   ItemFlag.VALUE, value,
				   ItemFlag.TYPE, type,
				   ItemFlag.TYPE_ID, t.ident,
				   -1);
		update_subtree(lhs.iter, left, false);
	}

	internal void add_expression(Expression expr, TreeIter? at=null,
		bool expand=false) {
		if (main!=null) return;
		Gedb.Type* t;
		Entity* e = null;
		Expression ex, exb;
		Expression? exd = null;
		TupleExpression? exu;
		RangeExpression? exr = null;
		AliasExpression? exa = null;
		uint8* addr;
		TreePath path;
		TreeIter iter;
		string name;
		char c = DataMode.EXTERN;
		uint fmt = expr.Format.INDEX_VALUE | style ;
		for (ex=expr; ex!=null; ex=ex.next) {
//			exa = ex as AliasExpression;
//			exb = exa!=null ? exa.alias : ex;
			exb = ex.resolve_alias().bottom();
			t = exb.dynamic_type;
			addr = exb.address();
			name = ex.append_qualified_name(null, null, fmt);
			store.append(out iter, at);
			exu = exb as TupleExpression;
			set_value(iter, addr, false, e, null, -1, c, name, exb);
			exr = exb.range;
			exd = exb.detail;
			if (exr!=null) {
				do_expand(iter);
			} else if (exd!=null) {
				expand = true;
				add_expression(exd, iter, true);
			} else if (exu!=null && exu.arg!=null) {
				expand = true;
				add_expression(exu.arg, iter);
			} else {
				add_dummy_item(iter, t, true);
			}
		}
		if (at!=null) {
			path = store.get_path(at);
			if (expand) view.expand_row(path, false);
			adjust_visibility(at);
		}
	}

	public void add_more(MoreDataPart m) { more_data.insert(0,m); }

} /* class DataPart */

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

	public ExtraData(DataPart main, StackPart own) {
		base.additionally(main, own, {FormatStyle.ADDRESS,FormatStyle.HEX});
		++part_count;
		id = part_count;
		updated = true;
		own.level_selected.connect((s,f,i,p) => { do_refresh(f,i,p); });
		tree_lines = main.tree_lines;
		dense = main.dense;
		max_items = main.max_items;
		main.notify["tree-lines"].connect((d,p) => { do_tree_lines(); });
		main.notify["non-defaults"].connect((d,p) => { do_items(); });
		main.notify["max-items"].connect((d,p) => { do_items(); });
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
		ExtraData dp = new ExtraData(d, sp);
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
		policy.set_tooltip_text
("""How are the data updated
when the program state changes?""");
		policy.has_tooltip = true;
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

		has_resize_grip = true;

		d.add_more(this);
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

	private void set_once_value(TreeIter at, Gedb.Once* o, FormatStyle style)
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
				addr = dg.rts.unboxed(addr, t);
				if (!t.is_subobject()) t = dg.rts.type_of_any(addr, t);
				value = format_value(addr, 0, false, t,
									 style, main.known_objects);
				type = t._name.fast_name;
			} else {
				value = "";
				type = t._name.fast_name;
			}
		}
		store.@set(at, ItemFlag.FIELD, o, ItemFlag.INDEX, -1,
				   ItemFlag.ADDR, addr,
				   ItemFlag.VALUE, value, ItemFlag.TYPE, type,
				   Item.FRESH, fresh, -1);
		if (!fresh) add_dummy_item(at, t, true);
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
					if (m!=DataMode.ONCE) continue;
					o = (Gedb.Once*)e;
					if (fresh==o.is_initialized()) {
						fresh = !fresh;
						set_once_value(child, o, style);
						store.@set(child, Item.FRESH, fresh,
								   ItemFlag.CHANGED, true, -1);
					} else {
						store.@set(child, ItemFlag.CHANGED, false, -1);
					}
					if (!fresh) add_dummy_item(child, e.type, true);
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
				update_subtree(child, ex.address(), false);
			} while (store.iter_next(ref child));
		}
	}

	protected override void do_collapse(TreeIter iter) {
		var path = store.get_path(iter);
		if (path.get_depth()<=1) return;
	}

	private void do_reformat(FormatStyle style) {
		Entity* e;
		TreeIter iter, child;
		int k, n;
		int m;
		bool fresh;
		bool ok = store.get_iter_first(out iter);
		known_objects = style==FormatStyle.IDENT ? main.known_objects : null;
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
						set_once_value(child, (Gedb.Once*)e, style);
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
		base(stack, status, {FormatStyle.ADDRESS,FormatStyle.HEX});
		main = data;
		this.dg = dg;
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
							  typeof(int),			// first
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
					   ItemFlag.INDEX, -1,
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
				if (!fresh) set_once_value(child, o, style);
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
		var scroll = view.parent as ScrolledWindow;
		if (scroll!=null) scroll.min_content_width = 480;

		info_list.@add(Item.CLS);

		main.reformatted.connect(do_reformat);
		tree_lines = main.tree_lines;
		dense = main.dense;
		max_items = main.max_items;
		main.notify["tree-lines"].connect((d,p) => { do_tree_lines(); });
		main.notify["non-defaults"].connect((d,p) => { do_items(); });
		main.notify["max-items"].connect((d,p) => { do_items(); });
		stack.level_selected.connect((s,f,i,p) => { do_refresh(f,i,p); });
		show_all();
	}

} /* FixedPart */

public class DeepInfo {

	public DeepInfo(DeepInfo? p, Entity* e, int i=-1, uint8* obj, Gedb.Type* t)
	//	requires (p==null || ((i>=0) == p.tp.is_special()))
	{ // workaround
		addr = obj;
		tp = t;
		reparent(p, e, i);
	}

	public DeepInfo.from_expression(Expression ex)
	requires (ex.bottom().address()!=null) {
		var tex = ex.bottom() as TextExpression;
		var f = tex!=null ? tex.entity : null;
		var iex = tex as ItemExpression;
		int idx = iex!=null ? iex.index : -1;
		this(null, f, idx, ex.address(), ex.dynamic_type);
		expr = ex;
		tp = ex.dynamic_type;
		assert (addr==ex.address());
	}

/**
   Parent of object, `null' for root objects
   (local variables of actual routine, once function values)
 **/
	public DeepInfo? parent { get; set; }

/**
   Associated Expression.
 **/
	public Expression? expr { get; internal set; }

/**
   Entity of object if `parent' is not of SPECIAL type
 **/
	public Entity* field { get; private set; }

/**
   Index of object if `parent' is of SPECIAL type
 **/
	public int index { get; private set; }

/**
   Traversal depth of object
 **/
	public int depth { get; private set; }

/**
   Dynamic type of object
 **/
	public Gedb.Type* tp { get; private set; }

/**
   Object address
 **/
	public uint8* addr { get; private set; }

	public void reparent(DeepInfo? p, Entity* e, int i) {
		parent = p;
		field = e;
		index = i;
		depth = p!=null ? p.depth+1 : 0;
	}
}

public class FeatureMenu : Gtk.Menu {

	private DataCore data;
	private EvalPart eval;
	private Gee.HashMap<Gtk.MenuItem,string> names;
	private string prefix;
	private uint up;

	private void do_feature(Gtk.MenuItem item) {
		bool is_prefix = false;
		string name = names[item];
		string all = prefix;
		char c = name[0];
		if (c=='_' || c.isalpha()) { // query or placeholder
			if (prefix.length>0) all += "." + name;
			else all = name;
		} else if (name.index_of(bullet)<0) { // prefix operator
			is_prefix = true;
		} else { // infix or bracket operator
			all = prefix + " " + name;
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
		if (is_prefix) all = name + " " + all;
		eval.insert(all);
	}

	private string add_short_type(string name, Entity* e) requires (e!=null) {
		string type = e.type._name.fast_name;
		if (type.length>20) type = type.substring(0,18) + "...";
		return name + " : " + type;
	}

	private static int compare_routines(Routine* u, Routine* v) {
		if (u==v) return 0;
		return  ((Entity*)u).is_less((Entity*)v) ? -1 : 1;
	}

	public FeatureMenu(string prefix, uint up, Gedb.Type* t,
					   DataCore data, System* s) {
		ClassText* ct;
		Entity* e;
		Routine* r;
		FeatureText* x;
		Expression ex, arg, prev;
		Gtk.MenuItem item;
		string name, typed_name;
		uint i, j, m, n;
		bool alias, header;

		this.data = data;
		this.prefix = prefix!="Current" ? prefix : "";
		this.up = up;
		eval = data.main!=null ?
			data.main.eval : (data as DataPart).eval;
		names = new Gee.HashMap<Gtk.MenuItem,string>();

		item = new Gtk.MenuItem.with_label("");	// self
		append(item);
		item.show();
		names.@set(item,"");
		item.activate.connect(do_feature);

		i = 0;
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
				if (x==null) continue;
				alias = x.alias_name!=null;
				name = alias ? x.alias_name : e._name.fast_name;
				typed_name = add_short_type(name, e);
				item = new Gtk.MenuItem.with_label(typed_name);
				append(item);
				item.show();
				item.activate.connect(do_feature);
				names.@set(item,name);
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
		header = false;
		flist.sort(compare_routines);
		n = flist.size;
		for (i=0; i<n; i++) {
			r = flist.@get((int)i);
			if (r.is_once()) continue;
			e = (Entity*)r;
			x = e.text;
			if (x==null || r.is_precursor()) continue;
			if (!header) {
				item = new SeparatorMenuItem();
				append(item);
				item.show();
				item = new Gtk.MenuItem.with_label("Functions");
				append(item);
				item.show();
				item.sensitive = false;
				header = true;
			}
			item = new Gtk.MenuItem();
			append(item);
			item.show();
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
			item.activate.connect(do_feature);
			item.label = add_short_type(name, e);
			names.@set(item,name);
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
			typed_name = add_short_type(name, e);
			item = new Gtk.MenuItem.with_label(typed_name);
			append(item);
			item.show();
			item.activate.connect(do_feature);
			names.@set(item,name);
			++i;
		}

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
			typed_name = add_short_type(name, e);
			item = new Gtk.MenuItem.with_label(typed_name);
			append(item);
			item.show();
			item.activate.connect(do_feature);
			names.@set(item,name);
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
	
public class EvalPart : Grid, AbstractPart, Cancellable {

	private DataPart? data;
	private Entry result;
	private Entry edit;
	private Expression? result_expr;
	private ExpressionChecker checker;
	private StackFrame* frame;

	private Gee.Map<string,Expression> aliases;
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
					fmt ^= ex.Format.EXPAND_ALIAS ^ ex.Format.EXPAND_PH;
				text = ex.format_one_value(fmt);
				do_data_selected(data.selected_item());
			}
		}
		result.set_text(text);
	}
	
	private void do_check_expression() {
		data.dg.call_delayed(this);
	}
	
	private void do_moved(Object obj) {
		int pos = edit.cursor_position;
		var ex = checker.expression_at(pos, false);
		set_result(ex);
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
			if (result_expr==null) return;
			data.assign(result_expr.bottom());
		} else {
			expanding = !expanding;
			string zoom = expanding ? Stock.ZOOM_OUT : Stock.ZOOM_IN;
			result.set_icon_from_stock(EntryIconPosition.SECONDARY, zoom);
			set_result(result_expr);
		}
	}
	
	private string bbullet = "⚫";
	private ulong sig_id;

	private void do_pretty_print() {
		var buffer = edit.buffer;
		string text = edit.text;
		int p = edit.cursor_position;
		int k = text.index_of_nth_char(p);
		int l = text.index_of(bullet, k);
		int lb = text.index_of(bbullet);
		string rest;
		unichar c;
		if (lb<0 && l<0) return;
		if (lb<p || (l>=0 && lb>l)) {
			SignalHandler.block (edit, sig_id);
			if (lb>=0) {
				text = text.splice(lb, lb+bbullet.length, bullet);
			}
			if (l>=0) {
				text = text.splice(l, l+bullet.length, bbullet);
			}
			edit.text = text;
			edit.move_cursor(MovementStep.LOGICAL_POSITIONS, p, false);	
			SignalHandler.unblock (edit, sig_id);
		}
	}

	private void do_set_sensitive(bool is_running) {
		sensitive = !is_running;
	}

	public EvalPart(DataPart d) {
		Label label;
		
		aliases = d.aliases;
		data = d;
		checker = new ExpressionChecker();

		label = new Label("Value ");
		attach(label, 0, 2, 1, 1);
		label.hexpand = false;
		label.halign = Align.START;
		result = new Entry();
		attach(result, 1, 2, 3, 1);
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
		attach(label, 0, 0, 1, 1);
		label.hexpand = false;
		label.halign = Align.START;
		history = new HistoryBox("Expressions");
		attach(history, 1, 0, 3, 1);
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
		edit.notify["cursor-position"].connect_after(
			(e,p) => { do_moved(e); });
		sig_id = edit.notify["cursor-position"].connect((e,p) =>
			{ do_pretty_print(); });
		attach(checker, 1, 1, 3, 1);

		data.item_selected.connect(do_data_selected);
	}
	
	public HistoryBox history { get; private set; }

	public void insert(string str) {
		var model = edit.buffer;
		string text = edit.text;
		int q, p = edit.cursor_position;
		int l = text.index_of(bbullet);
		if (l<0) {
			q = text.char_count();
			char c = str[0];
			if (text.length>0 && (c=='_' || c.isalpha())) {
				model.insert_text(q,{'.'});
				++q;
			}
		} else {
			int k = text.index_of_nth_char(p);
			unichar c;
			for (q=p; l>k; ++q) {
				text.get_prev_char(ref l, out c);
			}
			model.delete_text(q,1);
		}
		model.insert_text(q,str.data);
		q = q==p ? 1 : q-p;
		edit.move_cursor(MovementStep.VISUAL_POSITIONS, q, false);
 	}

	public void compute(string str, bool move_cursor_at_end=false) {
		edit.text = str;
		edit.activate();
		if (move_cursor_at_end)
			edit.move_cursor(MovementStep.VISUAL_POSITIONS, str.length, false);
	}
	
	public void set_debuggee(Debuggee? dg) {
		if (dg!=null) {
			dg.notify["is-running"].connect(
				(g,p) => { do_set_sensitive(dg.is_running); });
			var dr = dg as Driver;
		}
	}

	public void action() {
		checker.reset();
		string str = edit.get_text();
		if (str.strip().length==0 || data.dg==null) return;
		checker.check_dynamic(str, null, data.frame, data.dg.rts,
							  true, aliases, null, id_to_expr, data);
	}

	public void post_action() {
	    var ex = checker.parsed;
		if (ex==null) return;
		history.add_item(ex.append_name(), false);
		set_result(ex);
	}

	public void post_cancel(StackFrame* f) {
		string msg = "Evaluation cancelled";
		string bad = f!=null ? f.to_string(data.dg.rts) : "";
		checker.show_message(msg, "", bad, null);
	}

} /* EvalPart */
