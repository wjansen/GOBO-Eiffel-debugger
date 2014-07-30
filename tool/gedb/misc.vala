using Gtk;
using Gedb;

public enum ClassEnum {
	CLASS_IDENT,
	CLASS_NAME,
	NUM_CLASS_COLS
}

public enum TypeEnum {
	TYPE_IDENT,
	TYPE_NAME,
	NUM_TYPE_COLS
}

public enum ItemFlag {
	EXPR, 
	FIELD,
	ADDR,  
	INDEX,
	MODE,
	NAME,
	VALUE, 
	TYPE, TYPE_ID,
	CHANGED,
	NUM_COLS
}

public enum DataMode {
	CURRENT = '*',
	FIELD = ' ',
	ARGUMENT = 'A',
	LOCAL = 'L',
	SCOPE_VAR = 'S',
	CONSTANT = 'C',
	ONCE = 'O',
	EXTERN = 'X',
	DUMMY = '?'
}

public string compose_title(string? addendum, System* rts) {
	string title = "Gedb";
	if (rts!=null)  title += ": " + rts._name.fast_name;
	if (addendum!=null)  title += " -- " + addendum;
	return title;
}

private Gdk.Cursor watch_cursor; 

public void set_deep_sensitive(Container cont, bool yes_no, 
						  Gee.List<Widget>? preserve=null,
						  Gee.List<Widget>? invert=null) {
	if (watch_cursor==null) watch_cursor = new Gdk.Cursor(Gdk.CursorType.WATCH);
	GLib.List<weak Widget> list = cont.get_children();
	Gdk.Window win = null;
	bool ok = false;
	list.foreach ((w) => { 
			if (preserve==null || !preserve.contains(w)) {
				ok = yes_no;
				if (invert!=null && invert.contains(w)) ok = !ok;
				var c = w as Container;
				if (c!=null) {
					set_deep_sensitive(c, ok, preserve, invert);
				} else {
					w.sensitive = ok;
				}
				var item = w as Gtk.MenuItem;
				if (item!=null) {
					var sm = item.submenu;
					if (sm!=null) 
						set_deep_sensitive(sm, yes_no, preserve, invert);
				} else {
					win = w.get_window();
					if (win!=null) win.cursor = ok ? null : watch_cursor;
				}
			}
		});
	if (cont as ScrolledWindow == null) {
		ok = yes_no;
		if (!ok) 
			list.foreach ((w) => { ok |= w.sensitive; });
		cont.sensitive = ok;
		win = cont.get_window();
		if (win!=null) win.cursor = ok ? null : watch_cursor;
	}
}

public void set_deep_tooltip(Widget widget, bool yes) {
	var cont = widget as Container;
	if (cont!=null) {
		GLib.List<weak Widget> list = cont.get_children();
		list.foreach ((w) => { set_deep_tooltip(w, yes); });	
	}
	var nb = widget as Notebook;
	if (nb!=null) {
		for (int i=nb.get_n_pages(); i-->0;) {
			var p = nb.get_tab_label(nb.get_nth_page(i));
			set_deep_tooltip(p, yes);
		}
	}
	var b = widget as Button;
	if (b!=null && b.image!=null) 
		set_deep_tooltip(b.image, yes);
	if (yes) {
		var tt = widget.tooltip_text;
		if (tt!=null) tt = widget.tooltip_markup;
		if (tt!=null) widget.has_tooltip = true;
	} else {
		widget.has_tooltip = false;
	}
}

public class HistoryBox : ComboBoxText {

	public ListStore list { get; protected construct; }

	protected virtual void list_iter(out TreeIter l_iter, TreeIter m_iter) {
		l_iter = m_iter;
	}

	protected virtual void @remove(TreeIter iter) { list.@remove(iter); }

	private int _max_size;
	public int max_size { 
	default = 10;
		get { return _max_size; }
		construct set {
			_max_size = value<1 ? 1 : value;
			if (model==null) return;
			int n = model.iter_n_children(null);
			if (n<=_max_size) return;
			TreeIter iter, l_iter;
			for (int i=n; i>_max_size; --i) {
				model.iter_nth_child(out iter, null, _max_size);
				@remove(iter);
			}
		}
	}

	public HistoryBox(string? title) {
		var store = new ListStore(1, typeof(string));
		Object(has_entry: true, 
			   model: store, id_column: 0, list: store,
			   add_tearoffs: title!=null, tearoff_title: title
			);
	}

	construct {}

	public TreePath add_item(string item, bool set_entry=true) {
		TreeIter iter; 
		TreePath path = null;
		int col = id_column;
		model.@foreach((m,p,i) => {
				string t;
				m.@get(i, col, out t, -1);
				if (t==item) {
					path = p;
					return true;
				}
				return false;
			});
		if (path!=null) {
			model.get_iter(out iter, path);
			@remove(iter);
		}
		list.prepend(out iter);
		list.@set(iter, id_column, item, -1);
		update();
 		if (set_entry) {
			var e = get_child() as Entry;
			e.set_text(item);
		}
		return list.get_path(iter);
	}

	public TreePath? top() {
		TreeIter iter;
		bool ok = model.get_iter_first(out iter);
		return ok ? model.get_path(iter) : null;
	}

	public virtual void update() { 
		if (model.iter_n_children(null)==0) {
			var e = get_child() as Entry;
			e.set_text("");
		}
	}

	public override void changed() {
		if (active>0) {
			TreeIter act, it0, iter;
			get_active_iter(out iter);
			list_iter(out act, iter);
			list.get_iter_first(out it0);
			list.swap(act, it0);
			update();
			active = 0;
			selected();
		}
	}
	
	public signal void selected();
}

public class MergedHistoryBox : HistoryBox {

	protected override void list_iter(out TreeIter l_iter, TreeIter m_iter) {
		var filter = model as TreeModelFilter;
		filter. convert_iter_to_child_iter(out l_iter, m_iter);
	}

	protected override void @remove(TreeIter iter) {
		TreeIter l_iter;
		var filter = model as TreeModelFilter;
		filter.convert_iter_to_child_iter(out l_iter, iter);
		list.@remove(l_iter);
	}

	public MergedHistoryBox(string? title, TreeModelFilter f, int id=0) 
	requires (f.child_model is ListStore) {
		ListStore l = (!) f.child_model as ListStore;
		Object(has_entry: true, 
			   model: f, id_column: id, list: l,
			   add_tearoffs: title!=null, tearoff_title: title
			);
	}

	construct {}

	public override void update() {
		var filter = model as TreeModelFilter;
		filter.refilter();
		base.update();
	}

}

public enum FormatStyle { ADDRESS, IDENT, HEX}

private static void append_char(StringBuilder sb, void* addr, bool wide) {
	if (!wide) {
		char* cp = (char*)addr;
		char c = *cp;
		if (c<' ') {
			sb.append_c('%');
			switch (c) {
			case 0:
				sb.append_c('U');
				break;
			case '\b':
				sb.append_c('B');
				break;
			case '\t':
				sb.append_c('T');
				break;
			case '\n':
				sb.append_c('N');
				break;
			case '\f':
				sb.append_c('F');
				break;
			case '\r':
				sb.append_c('R');
				break;
			default:
				sb.append_printf("/%d/", (int)c);
				break;
			}
		} else if (c=='%') {
				sb.append_c(c);
				cp += 1;
				sb.append_c(*cp);
		} else if (c<='~') {
			if (c=='\'' || c== '"') sb.append_c('%');
			sb.append_c(c);
		} else {
			wide = true;
		}
	} 
	if (wide) {
		sb.append_unichar(*(unichar*)addr);
	}
}

public static string format_value(uint8* addr, int off, bool is_home_addr, 
								  Gedb.Type* t, FormatStyle fmt,
								  Gee.HashMap<void*,uint>? idents=null) {
	string str = "";
	if (addr==null)  return is_home_addr ? str : "Void";
	if (t.is_nonbasic_expanded())  return "";
	if (is_home_addr && t.is_nonbasic_expanded())  return str;
	uint8* orig = addr;
	weak uint8[] cc;
	weak unichar[] uu;
	if (is_home_addr) addr = t.dereference(addr+off);
	if (fmt==FormatStyle.HEX) {
		if (addr==null)  return "0x0";
		if ((t.flags & TypeFlag.BASIC_EXPANDED) == TypeFlag.BASIC_EXPANDED) { 
			switch (t.ident) {
			case 1:
			case 2:
			case 4:
			case 8:
				str = "0x%02x".printf(*(uint8*)addr);
				break;
			case 3:
			case 5:
			case 9:
				str = "0x%04x".printf(*(uint16*)addr);
				break;
			case 6:
			case 10:
			case 12:
				str = "0x%08x".printf(*(uint32*)addr);
				break;
			case 7:
			case 11:
			case 13:
				str = "0x%016lx".printf(*(ulong*)addr);
				break;
			case 14:
				if (addr!=null && *(void**)addr!=null) {
					if (sizeof(size_t) == 4)
						str = "%08p".printf(*(void**)addr);
					else
						str = "%016lp".printf(*(void**)addr);
				} else {
					if (sizeof(size_t) == 4)
						str = "0x%08x".printf(0);
					else
						str = "0x%016x".printf(0);
				}
				break;
			}
		} else {
			if (sizeof(size_t) == 4)
				str = "%08p".printf(addr);
			else
				str ="%016p".printf(addr);
		}
	} else {
		if (addr==null)  return "Void";
		StringBuilder sb;
		int nc = 0;
		switch (t.ident) {
		case 1:
			str = *(char*)addr!=0 ? "True" : "False";
			break;
		case 2: 
		case 3: {
			sb = new StringBuilder.sized(8);
			sb.append_c('\'');
			append_char(sb, addr, t.ident==TypeIdent.CHARACTER_32);
			sb.append_c('\'');
			str = sb.str;
			break;
		}
		case 4:
			str = "%d".printf(*(int8*)addr);
			break;
		case 5:
			str = "%d".printf(*(int16*)addr);
			break;
		case 6:
			str = "%d".printf(*(int32*)addr);
			break;
		case 7:
			str = "%ld".printf(*(long*)addr);
			break;
		case 8:
			str = "%d".printf(*(int8*)addr);
			break;
		case 9:
			str = "%d".printf(*(int16*)addr);
			break;
		case 10:
			str = "%d".printf(*(int32*)addr);
			break;
		case 11:
			str = "%ld".printf(*(long*)addr);
			break;
		case 12:
			str = "%.7g".printf(*(float*)addr);
			break;
		case 13:
			str = "%.16g".printf(*(double*)addr);
			break;
		case 14:
			if (addr!=null && *(void**)addr!=null)
				str = "%p".printf(*(void**)addr);
			else
				str = "0x0";
			break;
		case 17:
			if (fmt==FormatStyle.IDENT && idents!=null) {
				uint od = idents.@get(addr);
				str = "_%d".printf((int)od);
			} else {
				cc = chars_func(addr, &nc);
				str = (string)cc;
				str = str.substring(0, nc);
				str =  cc!=null ? "\"" + str + "\"" : "\"\"";
			}
			break;
		case 18:
			if (fmt==FormatStyle.IDENT && idents!=null) {
				uint od = idents.@get(addr);
				str = "_%d".printf((int)od);
			} else {
				uu = unichars_func(addr, &nc);
				str = (string)uu;
				str = str.substring(0, nc);
				str = uu!=null ? "\"" + str + "\"" : "\"\"";
			}
			break;
		default:
			if (fmt==FormatStyle.IDENT && idents!=null) {
				uint od = idents.@get(addr);
				str = "_%d".printf((int)od);
			} else {
				str = "0x%lx".printf((long)addr);
			}
			break;
		}
	}
	return str;
}

public string format_type(uint8* addr, int off, bool is_home_addr, 
						  Gedb.Type* t, FeatureText* ft=null) {
	string str;
	uint n;
	if (addr==null)  return "";
	str = t._name.fast_name;
	if (!t.is_subobject()) {
		addr = is_home_addr && addr!=null ? *(void**)(addr+off) : addr;
		if (t.is_special()) {
			var st = (SpecialType*)t;
			n = st.special_count(addr);
			str = st.item_type()._name.fast_name;
			str = "[%d] %s".printf((int)n, str);
		} else if (t.is_tuple() && ft!=null) {
			var tl = ft.tuple_labels;
			if (tl!=null) {
				FeatureText* tli;
				n = t.generics.length;
				str = "TUPLE";
				for (uint i=0; i<n; ++i) {
					tli = tl[i];
					if (tli==null) break;
					str += i==0 ? "[" : "; ";
					str += tli._name.fast_name;
					str += ": ";
					str += t.generics[i]._name.fast_name;
				}
				str += "]";
			}
		}
	}
	return str;
}

public interface ClassPosition {
	public abstract void get_position(out uint cid, out uint pos);
}

public class DataItem {
	
	public TreeModel model { get; private set; }
	public TreeIter iter;
	
	public Entity* field;
	public int idx;
	public uint8* home; 
	public uint tid;
	public int mode;

	public DataItem(TreeModel model, TreeIter iter) {
		this.model = model;
		this.iter = iter;
		model.@get(iter,
				   ItemFlag.FIELD, out field,
				   ItemFlag.INDEX, out idx,
				   ItemFlag.MODE, out mode, 
				   ItemFlag.TYPE_ID, out tid, -1);  
		if (mode==DataMode.FIELD) {
			TreeIter piter;
			if (model.iter_parent(out piter, iter)) {
				model.@get(piter, ItemFlag.ADDR, out home, -1);
			}
		}
	}

	public DataItem? parent() {	
		TreeIter p;
		return model.iter_parent(out p, iter) ?
			new DataItem(model, p) : null;
	}
}

/**
   Hashmap whose data are Eiffel objects which will be protected
   against memory reclamation by Eiffel's garbage collection.
   The keys' class must `H' must be hashable. 
 */
public class EiffelObjects : Object {

	private unowned void*[] data;
	private uint[] counts;
	private uint last_code;

	~EiffelObjects() { free_func(data); }

	private void resize(uint n) {
		if (n<=counts.length) return;
		void* d;
		uint h, i;
		uint old_size = size;
		var old_data = data;
		var old_counts = counts;
		data = (void*[])realloc_func(*eif_results, n*sizeof(void*));
		*eif_results = data;
		counts = new uint[n];
		for (i=0; i<n; ++i) data[i] = null;
		for (i=0; i<old_size; ++i) {
			d = old_data[i];
			if (d==null) continue;
			h = (uint)d;
			data[h] = old_data[i];
			counts[i] = old_counts[i];
			if (i==last_code) last_code = h;
		}
	}

	public uint size { get; set; }

	public EiffelObjects(uint n=0) { clear(n); }

/**
   Does the table Eiffel object `obj'?
   Caution: the function has side effects on private fields:
   `last_code' is set to the found values (or to the next free slot).
 */
	public bool contains(void* obj) {
		if (obj==null) return false;
		void* d;
		uint cap = counts.length;
		uint h = ((uint)obj) % cap;
		last_code = h;
		for (d=data[h]; d!=null; ) {
			if (d==obj) {
				return true;
			} else {
				h = (h+1) % cap;
				d = data[h];
				last_code = h;
			}
		}
		return false;
	}

/**
   Insert `obj'.
 */
	public void add(void* obj) {
		uint cap = counts.length;
		bool ok = contains(obj);
		uint h = last_code;
		if (ok) {
			counts[h] = counts[h]+1;
		} else {
			if (2*size>cap) {
				cap = 3*size + 1;
				resize(cap);
				contains(obj);	// adjust `last_code'
				h = last_code;
			}
			data[h] = obj;
			counts[h] = 1;
			size = size+1;
		}
	}

/**
   Remove `obj'.
 */
	public void remove(void* obj) {
		if (!contains(obj)) return;
		uint h0 = last_code;
		counts[h0] = counts[h0]-1;
		if (counts[h0]>0) return;
		void* d = null;
		uint cap = counts.length;
		for (uint h=(h0+1)%cap; d!=null && h!=h0; h=(h+1)%cap) {
			d = data[h];
			if (d!=null && ((uint)d)%cap==h0) {
				data[h0] = data[h];
				counts[h0] = counts[h];
				h0 = h;
			}
		} 
		data[h0] = null;
		counts[h0] = 0;
		size = size-1;
		last_code = h0;
	}

	/**
	   Remove all data.
	   @n minimum capacity to preserve.
	 */
	public void clear(uint n=10) ensures (size==0) {
		if (n<10) n = 10;
		n = 2*n+1;
		data = (void*[])realloc_func(null, n*sizeof(void*));
		*eif_results = data;
		counts = new uint[n];
		for (uint i=0; i<n; ++i) data[i] = null;
		last_code = 0;
		size = 0;
	}

} /* class EiffelObjects */