using Gtk;

internal class MultiDebugger : Object {

	private GLib.Module module;
	private Driver dr;
	private GUI gui;

	internal void do_load(string fn) {
		module = GLib.Module.open(fn, ModuleFlags.BIND_LAZY);
		string err = GLib.Module.error();
		if (module==null) 
			err = "Library not loadable: " + fn;
		void* addr;
		bool ok = true;
		ok = module.symbol("gedb_address_by_name", out addr);
		if (!ok) 
			err = "Not a debuggable GoboEiffel program in " + fn;
		if (err!=null); // Show error message 
	}

	internal MultiDebugger.empty() {
		gui = new GUI.rta(new Driver(), true);
		gui.new_debuggee.connect((g,fn) => { do_load(fn); });
		gui.show_all();
	}

	internal MultiDebugger(string[] args) requires (args.length>1) {
		this.empty();
		var aa = args[1:args.length];
		string fn = aa[0];
		if (!GLib.Path.is_absolute(fn)) {
			string cwd = GLib.Environment.get_current_dir();
			aa[0] = GLib.Path.build_filename(cwd, fn);
		}
		do_load(aa[0]);
	}

	internal void run() {
		while (true) ;
	}
}

public static int main(string[] args) {
	Gtk.init(ref args);
	var md = args.length>1 ? 
		new MultiDebugger(args) : new MultiDebugger.empty();
	md.run();

	return 0;
}
