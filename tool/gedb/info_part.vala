using Gtk;

public class Status : Statusbar {

	public delegate string LongStringFormatter(TreeModel model, TreeIter at, uint col);
	
	public Status () {
		var box = get_message_area() as Box;
		var list = box.get_children();
		var label = list.nth_data(0) as Label;
		label.use_markup = true;
		label.ellipsize = Pango.EllipsizeMode.END;
	}

	public bool set_long_string(Gdk.EventMotion ev,
								TreeView view, Gee.List<uint>? cols,
								LongStringFormatter format=null) {
		TreeViewColumn col;
		TreePath path;
		string? text=null;
		int x=(int)ev.x, y=(int)ev.y;
		bool ok = view.get_path_at_pos(x, y, out path, out col, null, null);
		uint id = get_context_id("long-string");
		remove_all(id);
		if (!ok)  return false;
		TreeModel model = view.get_model();
		TreeIter at;
		uint n = col.get_data<uint>("column");
		string title = col.title;
		if (cols!=null && cols.index_of(n)<0)  return false;
		model.get_iter(out at, path);
		if (format!=null)  text = format(view.get_model(), at, n);
		else  model.@get(at, n, out text, -1);
		if (text==null)  text = "";
		push (id, text);
		return false;
	}

	public bool remove_long_string() {
		uint id = get_context_id("long-string");
		remove_all(id);
		return false;
	}
}