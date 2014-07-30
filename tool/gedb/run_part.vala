using Gtk;
using Gee;
using Gedb;

public class RunPart : Box {
	
	private enum PrintItem {
		TEXT,
		EXPR,
		ROUTINE,
		NUM_COLS
	}

	private const int FK_CONT = 3;
	private int mode;
	private int repeat;
	
	private Driver dg;
	private StackPart stack;
	private ConsolePart? console;
	private Status status;

	private ButtonBox buttons;
	private Widget stop;
	private ComboBoxText marks;
	private Entry print;
	private ExpressionChecker checker;
	private Gee.List<Widget> invert_list;
	private Gee.List<Widget> at_end_list;
	private Gee.Map<string,Expression> aliases;
  	private string[] arg_list;
	private bool at_end;

	private void issue_command(int cmd, int mode, int rep) {
		uint id;
		id = status.get_context_id("stop-reason");
		status.remove_all(id);
		status.push (id, "Program is running");
		status_changed(dg.ProgramState.Running, null, null);
		dg.target_go(cmd, mode, rep);
	}

	private void do_run(string name) {
		string cmd1, cmd2;
		int cmd = 0;
		int rep = repeat;
		switch (mode) {
		case 1:
			cmd1 = " trace";
			break;
		case 2:
			cmd1 = " silent";
			break;
		default:
			cmd1 = "";
			break;
		}
		switch (name[0].tolower()) {
		case 'c':
			cmd = dg.RunCommand.cont;
			break;
		case 'n':
			cmd = dg.RunCommand.next;
			break;
		case 's':
			cmd = dg.RunCommand.step;
			break;
		case 'e':
			cmd = dg.RunCommand.end;
			break;
		case 'b':
			rep = stack.level;
			cmd = dg.RunCommand.back;
			break;
		case 0:
			name = "Stop";
			cmd = dg.RunCommand.stop;
			break;
		}
		cmd2 = "%s%s".printf(name, cmd1);
		if (rep>1) cmd2 += " %d".printf(rep);
		cmd2 += "\n";
		if (console!=null) console.put_log_info(cmd2, Log.GO);
		if (cmd==dg.RunCommand.stop) 
			Process.raise(ProcessSignal.INT);
		else 
			issue_command(cmd, mode, rep);
	}

	private void add_mark(StackFrame* f) requires (f!=null) {
		Routine* r = f.routine;
		var list = marks.get_model() as ListStore;
		string str;
		RoutineText* rt = r.text;
		str = "%s.%s:%u:%u".printf(rt._feature.home._name.fast_name, 
								   rt._feature._name.fast_name,
								   f.line(), f.column());
		marks.prepend_text(str);
		marks.set_active(-1);
	}

	private void update_markers(uint mc) {
		for (uint i=(uint)marks.model.iter_n_children(null); i-->mc;)
			marks.@remove(0);
		marks.set_active(-1);
	}

	private void do_mark() {
		string cmd = "Mark\n";
		if (console!=null) console.put_log_info(cmd, Log.INFO);
		issue_command(dg.RunCommand.mark, 0, 0);
		add_mark(stack.top);
	}

	private void do_reset(ComboBox combo) {
		int n = marks.model.iter_n_children(null);
		int rep = marks.active;
		if (rep<0) return;
		string cmd = "Reset %d\n".printf(repeat);
		if (console!=null) console.put_log_info(cmd, Log.INFO);
		issue_command(dg.RunCommand.reset, 0, n-1-rep);
		at_end = false;
		set_deep_sensitive(buttons, true, null, invert_list);
		marks.active = -1;
		var e = combo.get_child() as Entry;
		e.set_text("");
	}

	private void do_restart(Button b) {
		at_end = false;
		dg.args = arg_list[0:arg_list.length];
		issue_command(dg.RunCommand.restart, 0, 0);
		set_deep_sensitive(buttons, true, null, invert_list);
	}

	private void do_check_expression() {
		StackFrame* f = stack.frame();
		if (f==null || f.depth==0) return;
		checker.reset();
		var e = print_history.get_child() as Entry;
		string str = e.get_text();
		if (str.strip().length==0) return; 
		checker.check_with_idents(str, f, dg.rts, aliases);
		var expr = checker.parsed;
		if (expr==null) return;
		str = expr.append_name();
		var path = print_history.add_item(str);
		TreeIter iter;
		total_list.get_iter(out iter, path);
		total_list.@set(iter, 
						   PrintItem.EXPR, expr,
						   PrintItem.ROUTINE, f.routine, 
						   -1);
	}

	private void do_set_args(string text) {
		GLib.FileStream p;
		string cmd = null;
		bool ok = false;
#if POSIX
		string str = null;
		try {
			cmd = Environment.get_variable("GOBO");
			cmd = @"$cmd/bin/gedb.sh ";
			cmd += text;
			p = (GLib.FileStream)Posix.FILE.popen(cmd, "r");
			ok = true;
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
		}
		if (!ok) return;
		cmd = arg_list[0];
		str = p.read_line();
		int n = int.parse(str);
		++n;
		arg_list = new string[n];
		for (int i=1; i<n; ++i)
			arg_list[i] = p.read_line();
		arg_list[0] = cmd;
		Posix.close(p.fileno());
#else
		string[] args;
		try {
			ok = GLib.Shell.parse_argv(text, out args);
		} catch (Error e) {
		}
		if (!ok) return;
		cmd = arg_list[0];
		uint n = args.length;
		arg_list = new string[n+1];
		arg_list[0] = cmd;
		for (uint i=0; i<n; ++i) arg_list[i+1] = args[i];
#endif
		arg_history.add_item(text);
	}

	private Gtk.Menu menu;
	private bool do_show_args(Gdk.EventButton ev) {	
		if (ev.type!=Gdk.EventType.BUTTON_PRESS || ev.button!=3)  return false;
		menu = new Gtk.Menu();
		for (uint i=1; i<arg_list.length; ++i) {
			var item = new Gtk.MenuItem.with_label(arg_list[i]);
			menu.append(item);
			item.show();
		}
		menu.popup(null, null, null, ev.button, ev.time);
		return true;
	}

	private void do_new_exe(Loader ld) {
		assert (dg is Driver);
		var dg = ld as Driver;
		this.dg = dg;
		total_list.clear();
		arg_history.clear();
		string aa = "";
		arg_list = dg.args;
		for (int j=1; j<arg_list.length; ++j) aa += arg_list[j] + " ";
		do_set_args(aa);
		at_end = false;
	}

	private void treat_response(int reason, Gee.List<Breakpoint>? match,
							   StackFrame* frame, uint mc) { 
		update_markers(mc);
		switch (reason) {
		case dg.ProgramState.Running:
		case dg.ProgramState.Still_waiting:
			return;
			break;
		}
		status_changed(reason, frame, match);

		ClassText* cls;
		Breakpoint bp; 
		string str = ""; 
		string name, comment;
		uint pos;
		cls = dg.rts.class_at(frame.class_id);
		name = cls._name.fast_name;
		pos = frame.pos;
		comment = "Stop at %s:%u:%u\n".printf(name, pos/256, pos%256);
		switch(reason) {
		case dg.ProgramState.Step_by_step: 
			str = "Step by step";
			break;
		case dg.ProgramState.At_breakpoint: 
			Gee.Iterator<Breakpoint> iter;
			str = "Stop at breakpoint";
			for (iter=match.iterator(); iter.next();) {
				bp = iter.@get();
				str += " " + bp.id.to_string();
				comment += bp.to_string(frame, dg.rts);				
			}
			break;
		case dg.ProgramState.Debug_clause: 
			str = "Stop at debug clause";
			comment += "Debug clause entered\n";
			break;
		case dg.ProgramState.Interrupt: 
			str = "Program interrupted";
			comment += "Interrupt\n";
			break;
		case dg.ProgramState.Program_end: 
			str = "Program finished";
			comment += str+"\n";
			at_end = true;
			break;
		case dg.ProgramState.Crash: 
			str = "Program crashed";
			if (match!=null && match.size>0) {
				bp = match.@get(0);
				str += ": ";
				str += bp.catch_to_string();
			}
			comment += str+"\n";
			at_end = true;
			break;
		default:
			break;
		}
		uint id = status.get_context_id("stop-reason");
		status.remove_all(id);
		status.push(id, str);
		print_history.update();
		var path = print_history.top();
		if (path!=null) {
			Expression ex;
			TreeIter iter;
			var m = print_history.model;
			m.get_iter(out iter, path);
			m.@get(iter, PrintItem.EXPR, out ex, -1);
			try {
				ex.compute_in_stack(frame, dg.rts);
				var exb = ex.bottom();
				if (exb.dynamic_type!=null)
					comment += exb.format_values(2, 
						exb.Format.WITH_NAME |
						exb.Format.WITH_TYPE |
						exb.Format.INDEX_VALUE ,
						frame);
			} catch (ExpressionError e) {
				ex = ex.next;
			}
		}
		GLib.Idle.@add(() => { return do_stop_comment(comment); });
	}

	private Widget add_button(string name, int cmd,
							  AccelGroup accel, string comment) {
		int key;
		if (cmd!=dg.RunCommand.stop) {
			key = FK_CONT + (cmd-dg.RunCommand.cont);
			key += Gdk.Key.F1-1;
		}  else {
			key = Gdk.Key.Pause;
			name = "";
		}
		Button item = new Button(); 
		AccelLabel label = new AccelLabel(name);
		label.accel_widget = item;
		item.@add(label);
		item.clicked.connect(() => { do_run(name); });
		item.add_accelerator("clicked", accel, key, 0, AccelFlags.VISIBLE);
		item.set_tooltip_markup(comment);
		buttons.@add(item);
		if (cmd>=dg.RunCommand.stop) buttons.set_child_secondary(item, true);
		return item;
	}
	
	public RunPart(Driver dg, StackPart s, ConsolePart? c, 
				   Status i, AccelGroup accel, Gee.Map<string,Expression> list) {
		this.dg = dg;
		stack = s;
		console = c;
		status = i;
		aliases = list;
		orientation = Orientation.VERTICAL;
		
		Label label;
		Box box;
		buttons = new ButtonBox(Orientation.HORIZONTAL); 
		pack_start(buttons);
		buttons.set_layout(ButtonBoxStyle.START);
		add_button("Cont", dg.RunCommand.cont, accel, 
				   "Continue to next breakpoint.");
		add_button("End", dg.RunCommand.end, accel, 
				   "Continue to next `end' keyword.");
		add_button("Next", dg.RunCommand.next, accel, 
				   "Continue to next instruction,\ndo not enter called routines.");
		add_button("Step", dg.RunCommand.step, accel, 
				   "Continue to next instruction\nor expression, enter called routines.");
		add_button("Back", dg.RunCommand.back, accel, 
		 		   "Finish called routines\nuntil back at caller. ");
		stop = add_button("Stop", dg.RunCommand.stop, accel, 
						 "Stop running system.");
		
		box = new Box(Orientation.HORIZONTAL, 0); 
		pack_start(box);
		buttons = new ButtonBox(Orientation.HORIZONTAL); 
		box.pack_start(buttons, false, false, 3);
		buttons.set_layout(ButtonBoxStyle.START);
		
		var normal = new RadioButton.with_label(null, "break");
		buttons.@add(normal);
		normal.set_tooltip_text("Treat breakpoints as defined.");
		normal.has_tooltip = true;
		normal.clicked.connect(() => { mode=0; });
		var trc = new RadioButton.with_label_from_widget(normal, "trace");
		buttons.@add(trc);
		trc.set_tooltip_text("Treat breakpoints like tracepoints.");
		trc.has_tooltip = true;
		trc.clicked.connect(() => { mode=1; });
		var mute = new RadioButton.with_label_from_widget(normal, "silent");
		buttons.@add(mute);
		mute.set_tooltip_text("Ignore breakpoints of any kind.");
		mute.has_tooltip = true;
		mute.clicked.connect(() => { mode=2; });
		normal.set_active(true);
		Adjustment adj = new Adjustment(1.0, 1.0, 1000000.0, 1.0, 10.0, 0.0);
		SpinButton spin = new SpinButton(adj, 0, 0);
		box.pack_end(spin, false, false, 0);
		adj.value_changed.connect(() => { repeat = spin.get_value_as_int();});
		spin.set_numeric(true);
		spin.set_snap_to_ticks(true);
		spin.set_wrap(false);
		spin.set_tooltip_text(
"""Repeat count for
continuation commands.""");
		spin.has_tooltip = true;
		repeat = spin.get_value_as_int();

		Label space = new Label("repeat: ");
		box.pack_end(space, false, false, 3);

		box = new Box(Orientation.HORIZONTAL, 0); 
		pack_start(box);
		buttons = new ButtonBox(Orientation.HORIZONTAL); 
		box.pack_start(buttons, false, false, 0);
		buttons.set_layout(ButtonBoxStyle.START);
		Button mark = new Button.with_label("Mark");
		buttons.@add(mark);
		mark.set_tooltip_text("Mark actual position\nfor later reset.");
		mark.has_tooltip = true;
		mark.clicked.connect(() => { do_mark(); });
		marks = new ComboBoxText.with_entry();
		buttons.@add(marks);
		marks.add_tearoffs = true;
		marks.tearoff_title = compose_title("Marked positions", dg.rts);
		var me = marks.get_child() as Entry;
		me.editable = false;
		me.placeholder_text = "Reset";
		me.width_chars = 3;
		marks.popup_fixed_width = false;
		marks.set_active(-1);
		marks.set_tooltip_text("Select previously marked\nposition for reset.");
		marks.has_tooltip = true;
		marks.changed.connect(() => { do_reset(marks); });
		
		label = new Label(" ");
		buttons.@add(label);
		Button restart = new Button.with_label("Restart");
		buttons.@add(restart);
		restart.clicked.connect(do_restart);
		label = new Label("Arguments:");
		buttons.@add(label);
		arg_history = new HistoryBox("Command line arguments");
		box.pack_end(arg_history, true, true, 0);
		var args = arg_history.get_child() as Entry;
		args.activate.connect((e) => 
			{ do_set_args(e.get_text()); });
		args.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.CLEAR);
		args.icon_release.connect((e) => { args.set_text(""); });
		args.button_press_event.connect(do_show_args);
		args.set_tooltip_text(
"""Command line arguments.
Click right mouse button to show parsed argument list.""");
		args.has_tooltip = true;
		box = new Box(Orientation.HORIZONTAL, 0); 
		pack_end(box);
		buttons = new ButtonBox(Orientation.HORIZONTAL); 
		box.pack_start(buttons, false, false, 0);
		label = new Label("");
		buttons.@add(label);
		checker = new ExpressionChecker();
		box.pack_end(checker, true, true, 0);

		box = new Box(Orientation.HORIZONTAL, 0); 
		pack_end(box);
		buttons = new ButtonBox(Orientation.HORIZONTAL); 
		box.pack_start(buttons, false, false, 0);
		label = new Label("Print on stop");
		buttons.@add(label);
		total_list = new ListStore(PrintItem.NUM_COLS, 
									  typeof(string),		// TEXT
									  typeof(Expression?),	// EXPR
									  typeof(void*));		// ROUTINE
		var filter = new TreeModelFilter(total_list, null);
		filter.set_visible_func((m,i) => { 
				Routine* r;
				m.@get(i, PrintItem.ROUTINE, out r, -1); 
				return r==null || r==dg.top.routine;
			});
		print_history = new MergedHistoryBox("Print expression", filter);
		box.pack_end(print_history, true, true, 0);
		print_history.selected.connect(
			(h) => { do_check_expression(); });
		print = print_history.get_child() as Entry;
		print.activate.connect((e) => { do_check_expression(); });
		print.set_icon_from_stock(EntryIconPosition.SECONDARY, Stock.CLEAR);
		print.icon_release.connect((e) => 
			{ print.set_text(""); print.grab_focus(); });
		print.placeholder_text = "Expression list";
		
		pack_end(new Separator(Orientation.HORIZONTAL), false, false, 3);

		invert_list = new Gee.ArrayList<Widget>();
		invert_list.@add(stop);
		at_end_list = new Gee.ArrayList<Widget>();
		at_end_list.@add(restart);
		at_end_list.@add(arg_history);
		dg.notify["is-running"].connect(
			(g,p) => { do_set_sensitive(dg.is_running); });
		dg.response.connect(treat_response);
		dg.new_executable.connect((g) => { do_new_exe(g); });
	} 

	public HistoryBox arg_history { get; private set; }
	public MergedHistoryBox print_history { get; private set; }
	private ListStore total_list;

	private bool do_stop_comment(string str) {
		if (console!=null) console.put_log_info(str, Log.STOP);
		if (at_end) 
			set_deep_sensitive(this, false, null, at_end_list); 
		return false;
	}

	public void simple_cont(bool hard) {
		issue_command(dg.RunCommand.cont, hard ? silent : mode, 1);
	}

	public void do_set_sensitive(bool is_running) { 
		set_deep_sensitive(this, !is_running, null, invert_list);
		if (is_running)  stop.grab_focus();
		if (at_end) set_deep_sensitive(buttons, false);
	}

	public signal void status_changed(uint code, StackFrame* frame,
									  Gee.List<Breakpoint>? match);
	
}