using Gtk;
using Gedb;

public class HelpPart {

	public void help_system(System* s) {
		Pango.FontDescription font 
			= Pango.FontDescription.from_string("Monospace");

		MessageDialog dialog = new MessageDialog(
			null,
			DialogFlags.DESTROY_WITH_PARENT, 
			s!=null ? MessageType.INFO : MessageType.WARNING,
			ButtonsType.CLOSE, 
			"", "title");

		if (s!=null) {
			DateTime dt = new DateTime.from_unix_utc((int64)s.compilation_time/1000);
			dt = dt.to_local();
			var root = s.root_type;
			var cls = ((Gedb.Type*)root).base_class;
			var routine = s.root_creation_procedure;
			dialog.format_secondary_markup(
"""<span><tt>System            : %s</tt></span>
<span><tt>Root class        : %s</tt></span>
<span><tt>Root creation     : %s</tt></span>

<span><tt>Assertion check   : %s</tt></span>
<span><tt>Garbage collection: %s</tt></span>

<span><tt>Compiler          : %s</tt></span>
<span><tt>Compilation time  : %s</tt></span>""",
				((Gedb.Name*)s).fast_name,
				((Gedb.Name*)cls).fast_name,
				((Gedb.Name*)routine).fast_name,
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
"""<b>The following colors and markers are used to highlight 
specific positions in source code (besides syntax highlighting):
</b>"""
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
		rgba.parse("#25b221");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		rgba.parse("white");
		tag.override_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 0, 1, 1);
		text.set_text("Actual stop position");
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
		rgba.parse("#ec0000");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		rgba.parse("white");
		tag.override_color(StateFlags.NORMAL, rgba);
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
		rgba.parse("orange");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.selectable = true;
		tag.show.connect((w) => { ((w as Label).select_region(0, 5)); });
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 4, 1, 1);
		text.set_text("String found by last search command");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		table.attach(tag, 0, 5, 1, 1);
		tag.set_markup("<tt>lmno</tt>");
		rgba.parse("#fff670");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.selectable = true;
		tag.show.connect((w) => { ((w as Label).select_region(0, 5)); });
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 5, 1, 1);
		text.set_text("Other matching strings of last search command");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>pqrs</tt>");
		table.attach(tag, 0, 6, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#cbe1ff");
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 6, 1, 1);
		text.set_markup(
"""Name of the feature or class under the mouse pointer
whose definition in source code can be displayed 
(click mouse button <span><i>3 (right)</i></span> to activate)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>tuvw</tt>");
		table.attach(tag, 0, 7, 1, 1);
		rgba = new Gdk.RGBA();
		rgba.parse("#fcc3f7"); 
		tag.override_background_color(StateFlags.NORMAL, rgba);
		tag.hexpand = false;
		tag.vexpand = false;
		tag.halign = Align.START;
		tag.valign = Align.START;
		text = new Label("");
		table.attach(text, 1, 7, 1, 1);
		text.set_markup(
"""Expression under the mouse pointer that can be computed
(double click mouse button <span><i>3 (right)</i></span> to activate)""");
		text.set_justify(Justification.LEFT);
		text.halign = Align.START;

		tag = new Label("");
		tag.set_markup("<tt>xyz </tt>");
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
		str += "<tt>      ";
		str += "<span background='#ffa500'>   </span> ";
		str += "<span background='#fff670'>   </span> ";
		str += "<span background='#ec0000'>   </span> ";
		str += "<span background='#228b22'>   </span> ";
		str += "<span background='#fcc3f7'>   </span> ";
		str += "<span background='#cbe1ff'>   </span> ";
		str += "<span background='#e0ffc4'>   </span> ";
		str += "<span background='#dddddc'>   </span>";
		str += "</tt>";
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
