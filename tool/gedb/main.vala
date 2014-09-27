using Gtk;

public static int main(string[] args) {
	Gtk.init(ref args);
	string fn = GLib.Path.get_basename(args[0]);
	var dg = new Driver(args[1:args.length]);
	var gui = new GUI(dg);
	gui.show_all();
	if (args.length>1) {
		fn = args[1];
		if (!GLib.Path.is_absolute(fn)) {
			string cwd = GLib.Environment.get_current_dir();
			fn = GLib.Path.build_filename(cwd, fn);
		}
		dg.load(fn);
		gui.title = compose_title(null, null);
	}
	Gtk.main();
	return 0;
}

public void* gedb_longjmp = null;
public void* gedb_jmp_buffer = null;
public void* gedb_realloc = null;
public void* gedb_free = null;
public void* gedb_wrap = null;
public void* gedb_chars = null;
public void* gedb_unichars = null;
public void* gedb_results = null;
public void* gedb_markers = null;
public void* gedb_rts = null;
public void* gedb_top = null;
public void* gedb_t;
public void* gedb_o;
public void* gedb_ov;
public void* gedb_ms;
public void* GE_argv;
public int* GE_argc;
