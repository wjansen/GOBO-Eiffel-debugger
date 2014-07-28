using Gtk;
using Gedb;

public class HelpPart {

	private weak GUI gui;

	public HelpPart(GUI gui) { this.gui = gui; }
	
	public void help_system(Window main, System* s) {
		if (s==null) return;
		NormalType* root = s.root_type;
		ClassText* cls = root.base_class;
		Routine* routine = s.root_creation_procedure;
		DateTime dt = new DateTime.from_unix_utc((int64)s.compilation_time/1000);
		dt = dt.to_local();
		Pango.FontDescription font 
			= Pango.FontDescription.from_string("Monospace");

		MessageDialog dialog = new MessageDialog(
			main,
			DialogFlags.DESTROY_WITH_PARENT, MessageType.INFO,
			ButtonsType.CLOSE, 
			"", "title");

		if (s!=null) {
			dialog.format_secondary_markup(
"""<span><tt>System            : %s</tt></span>
<span><tt>Root class        : %s</tt></span>
<span><tt>Root creation     : %s</tt></span>

<span><tt>Assertion check   : %s</tt></span>
<span><tt>Garbage collection: %s</tt></span>

<span><tt>Compiler          : %s</tt></span>
<span><tt>Compilation time  : %s</tt></span>""",
				s._name.fast_name,
				cls._name.fast_name,
				routine._entity._name.fast_name,
				"Void target",
				(s.flags & SystemFlag.NO_GC)==0 ? "yes" : "no",
				s.compiler,
				dt.format("%Y-%m-%d %H:%M:%S"));
			} else {
				dialog.format_secondary_markup("System is not yet loaded.");	
			};
		dialog.title = compose_title("System info", s);

		dialog.run();
		dialog.destroy();
	}
	
	public void help_colors(Window main) {
		Gdk.RGBA rgba;
		Dialog dialog = new Dialog.with_buttons(
			compose_title("Help on colors", null),
			main,
			DialogFlags.DESTROY_WITH_PARENT, MessageType.INFO,
			ButtonsType.CLOSE, Gtk.ResponseType.OK, null);
		var box = dialog.get_content_area() as Box;
		box.margin = 12;
		
		SizeGroup group = new SizeGroup(SizeGroupMode.HORIZONTAL);

		Label headline = new Label("");
		headline.set_markup(
"""<b>The following colors are used to highlight 
-- besides syntax highlighting --
specific positions in source code:</b>"""
			);
		box.pack_start(headline, false, false, 5);
		group.add_widget(headline);
		headline.set_justify(Justification.LEFT);
		headline.halign = Align.START;
		
		Label tag, text;
		Grid table = new Grid();
		box.pack_start(table, true, true, 5);
		table.set_row_spacing(12);
		table.set_column_spacing(10);

		tag = new Label("");
		table.attach(tag, 0, 0, 1, 1);
		tag.set_markup("<tt>a</tt>");
		rgba = new Gdk.RGBA();
		rgba.parse("#00d600");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 0, 1, 1);
		text.set_text(
"""Actual stop position if the class belongs to the call stack""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>bcde</tt>");
		table.attach(tag, 0, 1, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#e0ffc4");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 1, 1, 1);
		text.set_text(
"""Line of actual stop position 
(to make the stop position better detectable)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		table.attach(tag, 0, 2, 1, 1);
		tag.set_markup("<tt><span underline='double'>f</span></tt>");
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 2, 1, 1);
		text.set_markup(
"""Possible position for the <b>At</b> condition of breakpoints""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		table.attach(tag, 0, 3, 1, 1);
		tag.set_markup("<tt>g</tt>");
		rgba = new Gdk.RGBA();
		rgba.parse("red");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 3, 1, 1);
		text.set_markup(
"""Position of the <b>At</b> condition of a breakpoint""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		table.attach(tag, 0, 4, 1, 1);
		tag.set_markup("<tt>hijk</tt>");
		rgba.parse("#ffd475");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.selectable = true;
		tag.show.connect((w) => { ((w as Label).select_region(0, 5)); });
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 4, 1, 1);
		text.set_text("""String found by a search command""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>lmno</tt>");
		table.attach(tag, 0, 5, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#abc4ff");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 5, 1, 1);
		text.set_markup(
"""Name of the class under the mouse pointer
whose source code can be displayed 
(click mouse button <span><i>3 (right)</i></span> to activate)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>pqrs</tt>");
		table.attach(tag, 0, 6, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#d9e9ff");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 6, 1, 1);
		text.set_markup(
"""Name of the feature under the mouse pointer
whose definition in source code can be displayed 
(click mouse button <span><i>3 (right)</i></span> to activate)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>tuvw</tt>");
		table.attach(tag, 0, 7, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#fce4fa"); 
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 7, 1, 1);
		text.set_markup(
"""Like the item above where additionally the value  
of the expression under the mouse pointer can be computed
(double click mouse button <span><i>3 (right)</i></span> to activate)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>xyz.</tt>");
		table.attach(tag, 0, 8, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#dddddc"); 
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 8, 1, 1);
		text.set_markup(
"""Line of insertion cursor
(to make the cursor position better detectable)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		string str = 
			"The various background colors take the priorities (high to low):\n";
		str += "   <span background='#ffd475'> 	 </span>, ";
		str += "<span background='red'> 	 </span>, ";
		str += "<span background='#00d600'> 	 </span>, ";
		str += "<span background='#fce4fa'> 	 </span>, ";
		str += "<span background='#d9e9ff'> 	 </span>, ";
		str += "<span background='#abc4ff'> 	 </span>, ";
		str += "<span background='#e0ffc4'> 	 </span>, ";
		str += "<span background='#dddddc'> 	 </span>.";
		Label priority = new Label(str);
		box.pack_start(priority, false, false, 5);
		group.add_widget(priority);
		priority.use_markup = true;
		priority.set_justify(Justification.LEFT);
		priority.halign = Align.START;

		dialog.add_button(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		dialog.show_all();
		dialog.response.connect(() => { dialog.destroy(); });
	}

	public void help_about(Window main) {
		AboutDialog dialog = new AboutDialog();
		dialog.transient_for = main;
		string[] authors = {"Wolfgang Jansen <wo.jansen@kabelmail.de>"};
		dialog.set_program_name("Debugger for GEC");
		dialog.set_version("0.1");
		dialog.set_copyright("© 2013 Wolfgang Jansen");
		dialog.set_license(
"""Gedb: MIT License <http://opensource.org/licenses/mit-license.php>
Gtk+: LGPL 2.1 <http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>
Vala: LGPL 2.1
""");
		dialog.transient_for = main;
		dialog.set_authors(authors);
		dialog.run();
		dialog.destroy();
	}
	
}
