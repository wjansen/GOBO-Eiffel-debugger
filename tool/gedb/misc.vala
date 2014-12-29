using Gtk;
using Gedb;

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
	if (rts!=null) title += ": " + ((Gedb.Name*)rts).fast_name;
	if (addendum!=null) title += " -- " + addendum;
	return title;
}

public delegate void* ReallocFunc(void* orig, size_t n);
public delegate void FreeFunc(void* orig);
public delegate void WrapFunc(uint i, void* call, void* C, void** args, void* R);
public delegate weak unichar[] UnicharsFunc(void* obj, int *nc);
public delegate weak uint8[] CharsFunc(void* obj, int *nc);

public ReallocFunc realloc_func;
public FreeFunc free_func;
public WrapFunc wrap_func;
public CharsFunc chars_func;
public UnicharsFunc unichars_func;

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

private static int class_less(ClassText* cls1, ClassText* cls2) {
	string n1 = ((Gedb.Name*)cls1).fast_name;
	string n2 = ((Gedb.Name*)cls2).fast_name;
	return n1.ascii_casecmp(n2);
}

public enum ClassEnum {
	CLASS_IDENT,
	CLASS_NAME,
	NUM_CLASS_COLS
}

public delegate bool ClassFilterFunc(ClassText* ct, void* data=null);

public Gtk.ListStore new_class_list(System* s, ClassFilterFunc filter=null,
									void* filter_data=null) 
requires (s!=null) {
	ClassText* cls;
	uint n;
	Gee.ArrayList<ClassText*> list = new Gee.ArrayList<ClassText*>();
	for (n=s.class_count(); n-->0;) {
		cls = s.class_at(n);
		if (cls==null || cls.ident==0) continue;
		if (filter!=null && !filter(cls,filter_data)) continue;
		list.@add(cls);
	}
	list.sort(class_less);
	var store = new ListStore(2, typeof(uint), typeof(string));
	TreeIter at;
	Gee.Iterator<ClassText*> citer;
	for (citer=list.iterator(); citer.next(); ) {
		cls = citer.@get();
		store.append(out at);
		store.@set(at, ClassEnum.CLASS_IDENT, cls.ident,
				   ClassEnum.CLASS_NAME, ((Gedb.Name*)cls).fast_name, -1);
	}
	return store;
}

public enum TypeEnum {
	TYPE_IDENT,
	TYPE_NAME,
	NUM_TYPE_COLS
}

public delegate bool TypeFilterFunc(Gedb.Type* t, void* data=null);

public Gtk.ListStore new_type_list(System* s, TypeFilterFunc filter=null,
								   void* filter_data=null) {
	Gedb.Type* t;
	string name;
	uint n;
	var store = new ListStore(2, typeof(uint), typeof(string));
	Gee.ArrayList<string> list = new Gee.ArrayList<string>();
	Gee.HashMap<string,uint> table = new Gee.HashMap<string,uint>();
	for (n=s.type_count(); n-->0;) {
		t = s.type_at(n);
		if (t==null) continue;
		if (filter!=null && !filter(t,filter_data)) continue;
		name = ((Gedb.Name*)t).fast_name;
		list.@add(name);
		table.@set(name, t.ident);
	}
	list.sort();
	Gee.Iterator<string> titer;
	TreeIter at;
	for (titer=list.iterator(); titer.next(); ) {
		name = titer.@get();
		store.append(out at);
		store.@set(at, TypeEnum.TYPE_IDENT, table.@get(name),
				   TypeEnum.TYPE_NAME, name, -1);
	}
	return store;
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

	public HistoryBox.with_list(string? title, ListStore ls, int col) {
		Object(has_entry: true, 
			   model: ls, id_column: col, list: ls,
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
		var store = f.child_model as ListStore;
		Object(has_entry: true, 
			   model: f, id_column: id, list: store,
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
	if (t==null) return "";
	if (addr==null) return is_home_addr ? str : "Void";
	if (t.is_nonbasic_expanded()) return "";
	if (is_home_addr && t.is_nonbasic_expanded()) return str;
	uint8* orig = addr;
	weak uint8[] cc;
	weak unichar[] uu;
	if (is_home_addr) addr = t.dereference(addr+off);
	if (fmt==FormatStyle.HEX) {
		if (addr==null) return "0x0";
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
		if (addr==null) return "Void";
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
				str = cc!=null ? "\"" + str.substring(0, nc) + "\"" : "\"\"";
			}
			break;
		case 18:
			if (fmt==FormatStyle.IDENT && idents!=null) {
				uint od = idents.@get(addr);
				str = "_%d".printf((int)od);
			} else {
				uu = unichars_func(addr, &nc);
				if (uu!=null) {
					sb = new StringBuilder();
					for (int i=0; i<nc; i++) sb.append_unichar(uu[i]);
					str = @"\"$(sb.str)\"";
				} else {
					str = "";
				}
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
	if (addr==null) return "";
	str = ((Gedb.Name*)t).fast_name;
	if (!t.is_subobject()) {
		addr = is_home_addr && addr!=null ? *(void**)(addr+off) : addr;
		if (t.is_special()) {
			var st = (SpecialType*)t;
			n = st.special_count(addr);
			str = ((Gedb.Name*)st.item_type()).fast_name;
			str = "[%d] %s".printf((int)n, str);
		} else if (t.is_tuple() && ft!=null) {
			var tl = ft.tuple_labels;
			n = t.generics.length;
			if (tl!=null && tl.length>=n) {
				FeatureText* tli;
				str = "TUPLE";
				for (uint i=0; i<n; ++i) {
					tli = tl[i];
					str += i==0 ? "[" : "; ";
					str += ((Gedb.Name*)tli).fast_name;
					str += ": ";
					str += ((Gedb.Name*)t.generics[i]).fast_name;
				}
				str += "]";
			}
		}
	}
	return str;
}

/**
   Interface for actions to be run in a separate thread
   and that can be canncelled from outside.
 */
public interface Cancellable : Object {

/**
   Action to be run in a separate thread.
 */
	public abstract void action();

/**
   Action to be run in the calling thread after normal end of `action'.
 */
	public abstract void post_action();

/**
   Action to be run in the calling thread after cancellation of `action'.
   @f StackFrame of the Eiffel routine (if any) called by `action'.
 */
	public abstract void post_cancel(StackFrame* f);
}

public interface ClassPosition {
	public abstract void get_position(out uint cid, out uint pos);
}

public interface Searcher {

	public enum SearchMode {
		NO_SEARCH, INIT_SEARCH, SEARCHING, NOT_FOUND, GO_TO }

	public abstract void prepare_client (TextView view);
	public abstract bool handle_key(Gdk.EventKey ev, TextView view);
	public abstract int search_state { get; set; } 
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
