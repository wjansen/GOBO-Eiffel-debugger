public class EvaluationEntry0 : ExpressionEntry {

	private EntryCompletion compl;
	private ListStore store;
	private uint compl_tid;
	private GedbEval.Valued? act_value;
	private GedbEval.Valued? extendable;

	private void fill_completion(ListStore store, uint tid, Routine* r) {
		if (rts==null)  return;
		Gedb.Type* t = rts.type_at(tid);
		Field* field;
		Local* loc;
		string name;
		TreeIter iter;
		uint i, n;
		store.clear();
		if ((t.flags & 0x04)!=0) {
			string brackets = "[%s]".printf(bullet);
			//store.append(out iter);
			//store.@set(iter, Query.NAME, brackets, Query.ENTITY, field,
			//Query.KIND, 'B', -1);
		} else {
			for (i=0, n=t.fields.length; i<n; ++i) {
				field = t.fields[i];
				name = field._entity._name.fast_name;
				store.append(out iter);
				store.@set(iter, Query.NAME, name, Query.ENTITY, field, 
								   Query.KIND, 'A', -1);
			}
		}
		if (r!=null) {
			for (i=1, n=r.vars.length; i<n; ++i) {
				loc = r.vars[i];
				if (loc!=null) {
					name = loc._entity._name.fast_name;
					store.append(out iter);
					store.@set(iter, Query.NAME, name,  Query.ENTITY, loc,
									   Query.KIND, 'L', -1);
				}
			}
		}
	}
	
	private void do_set_model(Expression to) {
		Expression p;
		uint old, tid;
		int pos;
		tid = to.entity.type.ident;
		if (tid!=0 && to.address()==null)  tid = 0;
		if (tid==0 && to.text._name._id==0) {   //placeholder
			// !!
		}
		old = compl_tid;
		if (tid!=old) {
			fill_completion(store, tid, null);
			compl_tid = tid;
		}
	}
	
	private bool do_filter(EntryCompletion compl, string key, TreeIter iter) {
		if (extendable==null)  return false;
		string prefix = extendable.expr.name();
		string name;
		store.get(iter, Query.NAME, out name, -1);
		return name==null || prefix==null ? false : name.has_prefix(prefix);
	}
	
	private bool do_select_query(TreeModel model, TreeIter iter,
		DataPart data) {
		Entity* entity;
		string name;
		model.@get(iter, Query.NAME, out name, Query.ENTITY, out entity, -1);
		// !! extendable.expr.text = entity;
		extendable.expr.compute_in_stack(data.frame, rts, false);
		value_changed(extendable.expr);
		return false;
	}

	public void do_set_basis(StackFrame* frame) {
		return;
		// !!
		Expression basic;
		Routine* routine;
		Local* loc;
		Gedb.Type* t;
		EntryCompletion compl = get_completion();
		ListStore store = (ListStore)compl.get_model();
		TreeIter iter;
		string name;
		uint tid;
		int i, n;
		parser = new GedbEval.Ex.in_stack(rts, frame);
		parser.select.connect((t) => 
			{ insert_at_cursor(t.name); });
		act_value = null;
		if (frame==null) {
			store.clear();
			return;
		}
		routine = frame.routine;
		loc = routine.vars[0];
		t = loc._entity.type;
		tid = t.ident;
		fill_completion(store, tid, routine);
		this.compl_tid = tid;
		parser = new GedbEval.Ex.in_stack(rts, frame);
		parser.add_string(bullet);
		parser.end();
		act_value = parser.result;
		extendable= act_value;
		set_text(bullet);
		value_changed(act_value.expr);
	}
	
	private bool do_key(Entry entry, Gdk.EventKey ev) {
		if (ev.type != Gdk.EventType.KEY_PRESS)  return false;
		uint code = ev.keyval;
		int n = entry.cursor_position;
		string str = string.nfill(1, (char)code);
		if (' '<= code && code<='~') {
			string prefix = get_text();
			int l = prefix.char_count(); 
			n = n<l ? prefix.index_of_char(n) : prefix.length;
			n -= extendable.at;
			prefix = extendable.expr.name();
			prefix = prefix.splice(n, n, str);
			prefix = prefix.replace(bullet, "").strip();
			// reset expr.name
			parser.add_string(prefix);
			parser.end();
			if (!parser.is_match) 
				return false;
			else 
				return true;
		}
		return false;
	}

	private bool do_focus (Entry entry) {
		Expression expr;
		string text = get_text();
		entry.set_text("");
		return false;
	}

	public EvaluationEntry0(System* s, DataPart d) {
		base(s);
		store = new ListStore(Query.NUM_COLS, typeof(string), typeof(string),
							  typeof(void*), typeof(char));
		compl = new EntryCompletion();
		set_completion(compl);
		compl.popup_set_width = false;
		compl.set_model(store);
		compl.set_text_column(Query.NAME);
		compl.popup_completion = true;
		compl.inline_completion = true;
		compl.set_match_func((c,k,i) => { return do_filter(c,k,i); });
		//compl.cursor_on_match.connect(do_select_query);
		compl.match_selected.connect(
			(c,m,i) => { return do_select_query(m,i,d); });
		key_press_event.connect((e,ev) => { return do_key((Entry)e,ev); });
		//focus_in_event.connect((e) => { return do_focus(edit); });
	}

	public signal void value_changed(Expression ex);
} /* */
