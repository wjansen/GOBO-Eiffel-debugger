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
