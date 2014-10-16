using Gedb;
public delegate void* JumpBufferFunc();
public delegate void* LongjmpFunc(void* buf, int val);
public delegate void PositionFunc(uint id, uint l, uint c);
public delegate void LimitsFunc(uint d, uint s);
public delegate void OffsetFunc();
public delegate void* AddressFunc(char* name);
public delegate int MainFunc(int argc, char **argv);
public delegate void RaiseFunc(int code);

internal JumpBufferFunc jump_buffer_func;
internal LongjmpFunc longjmp_func;

internal void** eif_markers;

internal class QueueMember : Object {
	internal int code;
	internal string name;
	internal StackFrame* top;
	internal Breakpoint? bp;
	internal Gee.List<Breakpoint>? list;

	internal QueueMember(int code) { this.code = code; }
}

internal class QueueSource : GLib.Source {

	public AsyncQueue<QueueMember> queue;
	
	public QueueSource() { 	base(); }

	protected override bool prepare(out int timeout) {
		timeout = -1;
		return false;
	}
	
	protected override bool check() {
		return queue.length() > 0;
	}
	
	protected override bool dispatch(SourceFunc cb) {
		return cb!=null ? cb() : false;
	}
	
}

/**
   Structure containing a saved program state.

   Caution:
   The saved state contains references to GEC objects
   which are subjected to GEC garbage collection.
   Therefore, the objects of the structure must also 
   be subjected to GEC garbage collection 
   (in particular, implementation as Vala class is not possible).
 **/
internal struct Marker {

	internal static Marker* create(StackFrame* f, System* s) {
		Marker* m = realloc_func(null, sizeof(Marker));
		*m = m0;
		m.frame = f;
		m.pos = f.pos;
		m.depth = f.depth;
		m.buffer = jump_buffer_func();
		uint n = count;
		++count;
		if (count>cap) {
			cap = 2*count+1;
			markers = (Marker*[])realloc_func(markers, cap*sizeof(Marker*));
			*eif_markers = markers;
		}
		markers[n] = m;
		string fn = "%s.m%u".printf(((Gedb.Name*)s).fast_name, n);
		m.path = Path.build_filename(GLib.Environment.get_tmp_dir(), fn);
		SaveMemorySource src = new SaveMemorySource(f, s, &m.objects);
		StreamTarget tgt = new StreamTarget(m.path, s);
		var d = new Persistence<uint,void*>();
		d.traverse_stack(tgt, src, f, s, true);
		return m;
	}

	internal static Marker* at(uint n) { return markers[n]; }

	internal static void reset(bool all) {
		uint n = all ? 0 : 1;
		for (uint i=count; i-->n;) {
			Marker* m = markers[i];
			m.clear(!all);
			free_func(m);
		}
		count = n;
		if (all) {
			if (cap>0) free_func(markers);
			cap = 0;
		}
	}

	internal static void clear_to_depth(uint d) requires (d>0) {
		uint n;
		for (n=count; n-->1;) {
			Marker* m = markers[n];
			if (m.depth<=d) break;
			m.clear(true);
			free_func(m);
			markers[n] = null;
		}
		++n;
		count = n;		
		if (count==0 && cap>0) {
			free_func(markers);
			markers = null;
			*eif_markers = markers;
			cap = 0;
		}
	}

	internal StackFrame* restore (System* s) {
		frame.pos = pos;
		if (path!=null) {
			StreamSource source = new StreamSource(path, s);
			MemoryTarget target = new MemoryTarget(s, objects);
			var driver = new Persistence<void*,uint>();
			driver.traverse_stack(target, source, frame, s, true);
		} else {
			for (uint n=s.once_count(); n-->0;) {
				Gedb.Once* o = s.once_at(n);
				o.refresh();
			}  
		}
		clear_to_depth(depth);
		return frame;
	}

	private void clear(bool buffered) { 
		if (buffered) {
			free_func(buffer);
			free_func(objects);
		}
		if (path!=null) {
			File f = File.new_for_path(path);
			f.delete();
			path = null;
		}
	}

	private StackFrame* frame;
	private void* buffer;
	private uint pos;
	private int depth;

	private string path;
	private unowned void*[] objects;

	private static unowned Marker*[] markers;
	private static uint count;
	private static uint cap;
	private static Marker m0;
}

protected struct GE_ZF {
	void* def;
	int type_id;
	int name_id;
	int typeset_id;
}

public struct GE_ZT {
	int flags;
	int class_id;
	int size;
	void* alloc;
	void* def;
	GE_ZF* fields;
	int nfields;
	void** routines;
	int nroutines;
	int* generics;
	int ngenerics;
}

public struct GE_ZTb {
	GE_ZT simple;
	int boxed_size;
	void* boxed_def;
	void* subobject;
}

internal struct GE_ZA {
	GE_ZT simple;
	int declared_id;
	int closed_tuple_id;
	int routine_name;
	char* open_closed;
	void* call_field;
	void* call;
}

public class Debuggee : Object {

	protected StackFrame** top0;

	protected RaiseFunc raise_func; 	
	protected PositionFunc set_pos_func;
	protected LimitsFunc set_limits_func;
	protected OffsetFunc offset_func;

	protected Debuggee.by_args(string[] args) {
		this.args = args[0:args.length];
	}

	protected virtual void set_addresses_and_offsets(AddressFunc af) {
		rts = *(System**)af("rts");
		top0 = (StackFrame**)af("top");
		EiffelObjects.eif_results = af("results");
		realloc_func = (ReallocFunc)af("realloc");
		free_func = (FreeFunc)af("free");
		chars_func = (CharsFunc)af("chars");
		unichars_func = (UnicharsFunc)af("unichars");
		offset_func = (OffsetFunc)af("set_offsets");
		offset_func();
	}

	public string[] args { get; internal set; }
	public bool is_running { get; protected set; }

	public string home;

	protected Debuggee.dummy() {}	// Make the Vala compiler happy!

	public Debuggee(string[] args, AddressFunc address_of) { 
		this.by_args(args);
		set_addresses_and_offsets(address_of);
	}

	public System* rts;

	public StackFrame* frame() { return top0!=null ? *top0 : null; }

	public void crash_response() {
		is_running = false;
		response(Driver.ProgramState.Crash, null, *top0, 0);
	}

	public signal void response(int reason, Gee.List<Breakpoint>? match,
								Gedb.StackFrame* f, uint mc);
}

public class Driver : Debuggee {

	public const int Instruction_break = 0;
	public const int Call_break = -1;
	public const int Step_into_break = -2;
	public const int Assignment_break = -3;
	public const int Debug_break = -4;
	public const int End_compound_break = -5;
	public const int End_routine_break = -6;
	public const int Start_program_break = -7;
	public const int End_program_break = -8;
	public const int After_mark_break = -9;
	public const int After_reset_break = -10;
	
	public enum RunCommand {
		cont = 1, 
		end, 
		next,
		step,
		back,
		mark,
		reset,
		restart,
		load,
		edit_bp,
		bp_set, 
		once_bp,
		stop, 
		exit
	}
	
	public enum ProgramState {
		Running,
		Program_start,
		At_reset,
		Step_by_step,
		At_breakpoint,
		At_tracepoint,
		Debug_clause,
		Interrupt,
		Catch,
		Crash,
		Program_end,
		Abort,
		Still_waiting
	}
	
	private AsyncQueue<QueueMember> gui_to_target;
	private AsyncQueue<QueueMember> target_to_gui;
	private QueueSource queue_source;

	private Thread<int> th;

	private FreeFunc free;

	private uint cmd;
	private uint run_mode;
	private uint repeat;
	private bool debug_clause_enabled;
	
	private int minimum_stack_size;
	private int target_depth;
	private int compound_limit;

	private bool pma;
	private bool just_marked;
	private bool interactive;
	private bool interrupted;
	private bool after_end;
	private bool intern;

	private int stop_code;
	private int os_signal;
	private uint timeout;
	private int* step;

	private void* argv;
	private int* argc;

	private SourceFunc cb = null;

	private Gee.List<Breakpoint> breakpoints;
	private Gee.List<Breakpoint> match;
	
	public void update_breakpoints(Gee.List<Breakpoint>? list) {
		breakpoints = list;
		int n = 0;
		bool ok = true;
		set_pos_func(0, 0, 1);
		if (list==null) return;
		foreach (var bp in list) {
			if (bp.exc==0) {
				if (bp.pos==0) {
					ok = false;
					break;
				} else {
					set_pos_func(bp.cid, bp.pos/256, bp.pos%256);
					++n;
				}
			}
		}
		if (!ok || n>20) set_pos_func(0, 0, 0);
	}

	public void target_go(uint run, uint mode, uint repeat) {
		if (pma) return;
		switch (run) {
		case RunCommand.cont:
		case RunCommand.next:
		case RunCommand.step:
		case RunCommand.end:
		case RunCommand.back:
			if (timeout==0) {
				timeout = GLib.Timeout.@add(20, () => {
						timeout = 0;	
						is_running = true;
						return false;
					});
			}
			break;
		default:
			timeout = 0;
			is_running = false;
			break;
		}
		var qm = new QueueMember((int)(run + (mode<<4) + (repeat<<8)));
		gui_to_target.push(qm);
	}
	
	private bool callback() {
		if (pma) return true;
		var qm = target_to_gui.pop();
		int stop = qm.code;
		StackFrame* f = qm.top;
		Gee.List<Breakpoint>? list = qm.list;
		is_running = stop==ProgramState.Running;
		response(stop, list, f, Marker.count);
		return true;
	}

	internal void catch_signal(int sgn) {
		bool old_intern = intern;
		intern = interactive;
		os_signal = sgn;
		treat_stop(IseCode.Signal_exception);
		os_signal = 0;
		intern = old_intern;
	}

	public void* treat_info(int reason) {
		if (intern) return null;
		top = *(StackFrame**)top0;
		interactive = just_marked;
		just_marked = false;
		bool old_intern = intern;
		intern = true;
		switch(reason) {
		case End_compound_break:
			if (cmd==RunCommand.end) 
				interactive = top.scope_depth<=compound_limit;
			break;
		case End_routine_break:
			if (cmd==RunCommand.back) 
				interactive = top.depth<=target_depth;
			break;
		case End_program_break:
			interactive = true;
			just_marked = true;
			stop_code = ProgramState.Program_end;
			break;
		case After_mark_break:
			just_marked = true;
			interactive = true;
			if (stop_code!=ProgramState.Program_start) 
				stop_code = ProgramState.Still_waiting;
			else if (breakpoints!=null)
				update_breakpoints(breakpoints);
			break;
		case After_reset_break:
			just_marked = true;
			interactive = true;
			stop_code = ProgramState.Still_waiting;
			break;
		}
		void* res = interactive ? treat_commands(reason, old_intern) : null;
		intern = old_intern;
		return res;
	}

	public void* treat_stop(int reason) {
		if (intern) return null;
		top = *(StackFrame**)top0;
		StackFrame* rescue = null;
		bool old_intern = intern;
		intern = true;
		Marker* m;
		switch(reason) {
		case Start_program_break:
			stop_code = ProgramState.Program_start;
			minimum_stack_size = 1;
			intern = old_intern;
			m = Marker.create(top, rts);
			just_marked = true;
			interactive = true;
			return m.buffer;	
		case Debug_break:
			if (debug_clause_enabled && run_mode!=silent) {
				interactive = true;
				stop_code = ProgramState.Debug_clause;
			}
			break;
		}
		if (interrupted) {
			interactive = true;
			interrupted = false;
			stop_code = ProgramState.Interrupt;
		}
		if (old_intern && reason>0) {
			stderr.printf("ERROR in function evaluation\n");
		}
		if (!interactive && reason>0) {
			rescue = check_reason(reason, top);
			stop_code = rescue!=null ? ProgramState.Catch : ProgramState.Crash;
		}
		if (!interactive) {
			check_step(reason);
			if (interactive) stop_code = ProgramState.Step_by_step;
		}
		match.clear();
		check_breakpoints(reason, top, rescue, rts, match);
		if (match.size>0) {
			stop_code = interactive ?
				ProgramState.At_breakpoint : ProgramState.At_tracepoint;
		}
		void* res = interactive ? treat_commands(reason, old_intern) : null;
		if (os_signal>0 && rescue!=null) raise_func(0);
		intern = old_intern;
		return res;
	}

	private void* treat_commands(int reason, bool old_intern) 
	requires (interactive) {
		Marker* m;
		while (interactive) {
			int ss = top.depth;
			if (ss<minimum_stack_size) minimum_stack_size = ss;
			Marker.clear_to_depth(minimum_stack_size);
			if (breakpoints!=null) {
				// forget temporary breakpoint:
				var bb = breakpoints;
				foreach (var bp in bb) {
					if (bp!=null && bp.id==0) {
						bb.@remove(bp);
						break;
					}
				}
			}
			var qm = new QueueMember(stop_code);
			qm.top = top;
			switch (stop_code) {
			case ProgramState.At_breakpoint:
			case ProgramState.At_tracepoint:
				qm.list = match;
				stop_code = ProgramState.Still_waiting;
				break;
			case ProgramState.Crash:
				var bp = new Breakpoint();
				bp.exc = reason;
				match.clear();
				match.@add(bp);
				qm.list = match;
				break;
			}
			minimum_stack_size = top!=null ? top.depth : 0;
			if (timeout!=0) {
				GLib.Source.@remove(timeout);
				timeout = 0;
			}
			target_to_gui.push(qm);
			qm = gui_to_target.pop();
			just_marked = false;
			repeat = qm.code;
			cmd = repeat & 0x0f;
			repeat >>= 4;
			run_mode = repeat & 0x0f;
			repeat >>= 4;
			switch (cmd) {
			case RunCommand.cont:
				interactive = false;
				*step = 0;
				set_limits_func(0, 0);
				break;
			case RunCommand.next:
				target_depth = ss;
				interactive = false;
				*step = 1;
				set_limits_func(0, 0);
				break;
			case RunCommand.step:
				target_depth = int.MAX;
				interactive = false;
				*step = 1;
				set_limits_func(0, 0);
				break;
			case RunCommand.end:
				target_depth = ss;
				compound_limit = top.scope_depth-(int)repeat;
				if (compound_limit<0) compound_limit = 0;
				interactive = false;
				*step = 0;
				set_limits_func(0, compound_limit);
				break;
			case RunCommand.back:
				target_depth = ss-(int)repeat;
				interactive = false;
				*step = 0;
				set_limits_func(target_depth, 0);
				break;
			case RunCommand.mark:
				stop_code = ProgramState.Running;
				m = Marker.create(top, rts);
				just_marked = true;
				intern = old_intern;
				return m.buffer;
			case RunCommand.reset:
				stop_code = ProgramState.Running;
				m = Marker.at(repeat+1);
				Marker.clear_to_depth(m.depth);
				top = m.restore(rts);
				just_marked = true;
				intern = old_intern;
				longjmp_func(m.buffer, 1);
				break;
			case RunCommand.restart:
				Marker.reset(false);
				m = Marker.at(0);
				top = m.restore(rts);
				just_marked = true;
// Set args
				intern = old_intern;
				longjmp_func(m.buffer, 2);
				break;
			case RunCommand.exit:
				intern = false;
				th.exit(0);
				break;
			}
		}
		intern = old_intern;
		return null;
	}

	private StackFrame* check_reason(int reason, StackFrame* frame) 
	requires (reason>0) {
		StackFrame* rescue;
		Routine* r;
		for (rescue=frame; rescue!=null; rescue=rescue.caller) {
			r = rescue.routine;
			if (r==null) break;
			RoutineText* rt = r.routine_text();
			if (rt.rescue_pos!=0) break; 
		}
		if (rescue==null) {
			interactive = true;
			stop_code = ProgramState.Crash;
			Breakpoint bp = new Breakpoint.with_ident(0);
			bp.exc = reason;
			match.@add(bp);
			return null;
		} 
		interactive |= reason>0 && rescue==null;
		return rescue;
	}
	
	private void check_breakpoints(int reason, StackFrame* frame, 
								   StackFrame* rescue, System* s,
								   Gee.List<Breakpoint>match) {
		StackFrame* at;
		var bb = breakpoints;	// avoid `lock/unlock' by elementary instruction
		if (bb==null) return;
		Breakpoint found;
		WatchInfo? wi = null;
		uint n;
		foreach (var bp in bb) {
			if (bp==null || !bp.enabled) continue;
			if (run_mode==silent && bp.id!=0) continue;
			found = null;
			at = frame;
			n = bp.exc;
			if (n>0 && reason>0) {
				uint code = bp.map_code(reason);
				if (n<code) continue;  
				at = rescue;
				if (found==null) found = new Breakpoint.with_ident(bp.id);
				found.exc = code + 256*os_signal;
			}
			n = bp.depth;
			if (n>0) {
				int d = frame.depth;
				if (bp.id==0) {
					if (n<=d) continue;
					else bp.pos = 0;
				} else {
					if (n>d) continue;
				}
				if (found==null) found = new Breakpoint.with_ident(bp.id);
				found.depth = bp.depth;
			}
			n = bp.pos;
			if (n>0) {
				if (n!=at.pos || bp.cid!=at.class_id) continue;
				if (found==null) found = new Breakpoint.with_ident(bp.id);
				found.cid = bp.cid;
				found.pos = bp.pos;
			}
			wi = bp.watch;
			if (wi!=null) {
				if (wi.depth>top.depth) wi.invalidate();
				if (!wi.value_changed(top.depth)) continue;
				if (found==null) found = new Breakpoint.with_ident(bp.id);
				found.watch = wi;
			}			
			n = bp.tid;
			if (n>0) {
				Routine* r = frame.routine;
				Local* l = r.vars[0];
				uint rid = ((Entity*)l).type.ident;
				if (n!=rid) continue;
				if (found==null) found = new Breakpoint.with_ident(bp.id);
				found.tid = rid;
			}
			if (bp.iff!=null) {
				try {
					bp.iff.compute_in_stack(frame, s);
					if (!bp.iff.bottom().as_bool()) continue;
					if (found==null) found = new Breakpoint.with_ident(bp.id);
					found.iff = bp.iff;
				} catch (Error e) {
					stderr.printf("IF condition: %s\n", e.message);
				}
			}
			if (found!=null) {
				if (bp.depth>0 && bp.pp) bp.depth = frame.depth+1;
				found.print = bp.print;
				if (found.watch!=null) {
					if (wi.depth>top.depth) {
						found.watch.invalidate();
					} else {
						bp.watch.refresh(s);
					}
				}
				match.@add(found);
				interactive |= run_mode!=trace && !bp.cont;
			}
		}
	}
	
	private void check_step(int reason) {
		uint ss = top.depth;
		switch(cmd) {
		case RunCommand.cont:
			break;
		case RunCommand.end:
			interactive = top->scope_depth<=compound_limit;
			break;
		case RunCommand.step:
			--repeat;
			FeatureText* ft = ((Entity*)top.routine).text;
			interactive = (repeat<=0 && 
						   (ft.home.flags & ClassFlag.DEBUGGER)!=0);
			break;
		case RunCommand.next:
			if (ss<=target_depth && reason!=Step_into_break) --repeat;
			interactive = (repeat==0);
			break;
		case RunCommand.back:
			interactive = ss<=target_depth;
			break;
		default:
			break;
		}
		if (interactive) stop_code = ProgramState.Step_by_step;
	}
	
	private void*[] orig_handlers;

	private static void sig_handler(int sig) {
		the_driver.catch_signal(sig);
	}

	private static void interrupt_handler(int sig) {
		the_driver.interrupted = true;
	}

	~Driver() { Marker.reset(true); }

	protected override void set_addresses_and_offsets(AddressFunc address_of) {
		base.set_addresses_and_offsets(address_of);
		longjmp_func = (LongjmpFunc)address_of("longjmp");
		jump_buffer_func = (JumpBufferFunc)address_of("jmp_buffer");
		eif_markers = address_of("markers");
		raise_func = (RaiseFunc)address_of("raise");
		set_pos_func = (PositionFunc)address_of("set_bp_pos");
		set_limits_func = (LimitsFunc)address_of("set_limits");
		step = (int*)address_of("step");
	}

	public Driver() {
		base.dummy();
		pma = false;
		cmd = 0;
		match = new Gee.ArrayList<Breakpoint>();
		if (pma) {
			is_running = true;
			stop_code = ProgramState.Running;
		} else {
			target_to_gui = new AsyncQueue<QueueMember>();
			gui_to_target = new AsyncQueue<QueueMember>();
			queue_source = new QueueSource();
			queue_source.queue = target_to_gui;
			queue_source.attach(null);
			queue_source.set_callback(@callback);
			stop_code = ProgramState.Program_start;
		}
		orig_handlers = new void*[32];
		for (int sig=32; sig-->0;) {
			switch (sig) {
			case ProcessSignal.ILL:
			case ProcessSignal.ABRT:
			case ProcessSignal.FPE:
			case ProcessSignal.SEGV:
				//orig_handlers[sig] =
				Process.@signal((ProcessSignal)sig, sig_handler);
				break;
			case ProcessSignal.INT:
				//orig_handlers[sig] =
				Process.@signal((ProcessSignal)sig, interrupt_handler);
				break;
			}
		}
		the_driver = this;
	}

	public Driver.with_args(string[] args, AddressFunc af) {
		this();
		this.args = args;
		set_addresses_and_offsets(af);		
	}

	public StackFrame* top { get; private set; }

	public void stop() {
		if (th!=null) {
			var qm = new QueueMember(RunCommand.exit);
			gui_to_target.push(qm);
			th.join();
			th = null;
		}
		Marker.reset(true);
	}

}

namespace Gedb {
	
	private static weak Driver the_driver;
	
	public void* inform(int reason) { 
		return the_driver.treat_info(reason);
	}

	public void* stop(int reason) { 
		return the_driver.treat_stop(reason);
	}

}