using Gedb;

public delegate int MainFunc(int argc, char **argv);
public delegate void RaiseFunc(int code);
internal delegate void* JumpBufferFunc();
internal delegate void* LongjmpFunc(void* buf, int val);

internal JumpBufferFunc jump_buffer_func;
internal LongjmpFunc longjmp_func;
internal RaiseFunc raise_func; 	
public void** eif_markers;
	
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
			markers = (Marker*[])realloc_func(*eif_markers, cap*sizeof(Marker*));
		}
		*eif_markers = markers;
		markers[n] = m;
		string fn = "%s.m%u".printf(s._name.fast_name, n);
		m.path = Path.build_filename(GLib.Environment.get_tmp_dir(), fn);
		SaveMemorySource src = new SaveMemorySource(f, s, &m.objects);
		StreamTarget tgt = new StreamTarget(m.path, s);
		var d = new Gedb.Driver<uint,void*>();
		d.traverse_stack(tgt, src, f, s, true);
		return m;
	}

	internal static Marker* at(uint n) { return markers[n]; }

	internal static void keep(uint n) {
		for (uint i=count; i-->n;) {
			Marker* m = markers[i];
			m.clear();
			free_func(m);
		}
		count = n;
		if (count==0 && cap>0) {
			free_func(markers);
			markers = null;
			cap = 0;
		}
	}

	internal static void clear_to_depth(uint d) {
		uint n;
		for (n=count; n-->1;) {
			Marker* m = markers[n];
			if (m.depth>d) {
				m.clear();
				free_func(m);
				markers[n] = null;
			}
			else break;
		}
		++n;
		count = n;		
		if (count==0 && cap>0) {
			free_func(markers);
			markers = null;
			cap = 0;
		}
	}

	internal StackFrame* restore (System* s) {
		frame.pos = pos;
		if (path!=null) {
			StreamSource source = new StreamSource(path, s);
			MemoryTarget target = new MemoryTarget(s, objects);
			var driver = new Gedb.Driver<void*,uint>();
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

	private void clear() { 
		free_func(buffer);
		free_func(objects);
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

extern void* gedb_longjmp;
extern void* gedb_jmp_buffer;
extern void* gedb_realloc;
extern void* gedb_free;
extern void* gedb_wrap;
extern void* gedb_chars;
extern void* gedb_unichars;
extern void* gedb_zt;
extern void* gedb_zo;
extern void* gedb_zov;
extern void* gedb_zms;
extern void* gedb_results;
extern void* gedb_markers;
extern void* gedb_rts;
extern void* gedb_top;
extern void* GE_argv;
extern int* GE_argc;

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

public class Loader : Object {

	protected GE_ZT** zt;
	protected void** zo;
	protected void** zov;
	protected void** zms;
	protected void* argv;
	protected int* argc;

	protected void set_offsets() {
		Field* f;
		Routine* r;
		Gedb.Type* t, dt;
		Gedb.Once* o;
		Constant* c;
		void** addr;
		GE_ZT* ext;
		GE_ZF* ext_f;
		size_t off;
		uint i, j, n=rts.all_types.length;
		for (i=0; i<n; ++i) {
			t = rts.all_types[i];
			if (t==null || !t.is_alive()) continue;
			addr = zt+i;
			ext = *(GE_ZT**)addr;
			t.instance_bytes = ext.size;
			if (t.is_subobject()) {
				GE_ZTb* b = (GE_ZTb*)ext;
				ExpandedType* et = (ExpandedType*)t;
				et.boxed_bytes = b.boxed_size;
				off = (size_t)b.subobject - (size_t)b.boxed_def;
				et.boxed_offset = (int)off;
			}
			if (t.is_agent()) { 
				GE_ZA* a = (GE_ZA*)ext;
				AgentType* at = (AgentType*)t;
				Gedb.Type* cot = (Gedb.Type*)at.closed_operands_tuple;
				if (t.field_count()>0) {
					j = cot.field_count();
					if (j<t.field_count()) {
						dt = (Gedb.Type*)at.declared_type;				
						off = dt.fields[2].offset;
						f = t.field_at(j);
						f.offset = (int)off;
					}
					for (j=cot.field_count(); j-->0;) {
						f = t.field_at(j);
						off = cot.fields[j].offset;
						f.offset = (int)off;
					}
				}
				off = (size_t)a.call_field - (size_t)ext.def;
				at.function_offset = (int)off;
				at.call_function = a.call;
			} else {
				for (j=t.field_count(); j-->0;) {
					ext_f = &(ext.fields[j]);
					f = t.field_at(j);
					off = (size_t)ext_f.def - (size_t)ext.def;
					f.offset = (int)off;
				}
				if (t.is_normal()) {
					for (j=t.routine_count(); j-->0;) {
						r = t.routine_at (j);
						r.call = ext.routines[j];
					}
				}
			}
			if (t.class_name==null) {
				if (t.is_agent()) {
					t.class_name = "AGENT";
				} else {
					string name = t._name.fast_name;
					int l = name.index_of_char('[');
					if (l>=0) name = name.substring(0, l).strip();
					t.class_name = name;
				}
			}
		}
		for (i=rts.once_count(); i-->0;) {
			o = rts.all_onces[i];
			addr = zo+i;
			o.init_address = *(uint8**)addr;
			addr = zov+i;
			o.value_address = addr!=null ? *(uint8**)addr : null;
		}
		for (i=rts.constant_count(); i-->0;) {
			c = rts.all_constants[i];
			if (c._entity.type.is_basic()) continue;
			addr = zms+i;
			c.eif_ms = addr!=null ? *(uint8**)addr : null;
		}
	}

	protected StackFrame** top0;
	protected GLib.Module module;

	public string[] args { get; set; }
	public bool is_running { get; protected set; }

	public string home;

	public Loader(string[] args) { this.args = args; }

	public virtual bool load(string? libname) {
		void* addr;
		string lib = null;
		bool ok = true;
		module = GLib.Module.open(libname, 0);//ModuleFlags.BIND_LOCAL);
		if (module==null) return false;
		lib = module.name();

		ok &= module.symbol("gedb_longjmp", out addr);
		addr = *(void**)addr;
		longjmp_func = (LongjmpFunc)addr;
		ok &= module.symbol("gedb_jmp_buffer", out addr);
		addr = *(void**)addr;
		jump_buffer_func = (JumpBufferFunc)addr;
		ok &= module.symbol("gedb_realloc", out addr);
		addr = *(void**)addr;
		realloc_func = (ReallocFunc)addr;
		ok &= module.symbol("gedb_free", out addr);
		addr = *(void**)addr;
		free_func = (FreeFunc)addr;
		ok &= module.symbol("gedb_wrap", out addr);
		addr = *(void**)addr;
		wrap_func = (WrapFunc)addr;
		ok &= module.symbol("gedb_chars", out addr);
		addr = *(void**)addr;
		chars_func = (CharsFunc)addr;
		ok &= module.symbol("gedb_unichars", out addr);
		addr = *(void**)addr;
		unichars_func = (UnicharsFunc)addr;
		ok &= module.symbol("gedb_results", out addr);
		eif_results = (void**)addr;
		gedb_results = addr;
		ok &= module.symbol("gedb_markers", out addr);
		eif_markers = (void**)addr;
		gedb_markers = addr;
		ok &= module.symbol("gedb_rts", out addr);
		if (addr!=null) rts = *(System**)addr;
		ok &= module.symbol("gedb_top", out addr);
		top0 = (StackFrame**)addr;
		ok &= module.symbol("gedb_zt", out addr);
		addr = *(void**)addr;
		zt = (void**)addr;
		ok &= module.symbol("gedb_zo", out addr);
		addr = *(void**)addr;
		zo = (void**)addr;
		ok &= module.symbol("gedb_zov", out addr);
		addr = *(void**)addr;
		zov = (void**)addr;
		ok &= module.symbol("gedb_zms", out addr);
		addr = *(void**)addr;
		zms = (void**)addr;
		ok &= module.symbol("GE_argc", out addr);
		argc = (int*)addr;
		ok &= module.symbol("GE_argv", out addr);
		argv = addr;
		if (!ok) {
			// Guru section:
 			// force some global names to be included into the library.
			gedb_longjmp = null;
			gedb_jmp_buffer = null;
			gedb_realloc = null;
			gedb_free = null;
			gedb_wrap = null;
			gedb_chars = null;
			gedb_unichars = null;
			gedb_results = null;
			gedb_markers = null;
			gedb_rts = null;
			gedb_top = null;
			gedb_zt = null;
			gedb_zo = null;
			gedb_zov = null;
			gedb_zms = null;
			GE_argc = null;
			GE_argv = null;
			return false;
		}
		set_offsets(); 
		if (libname!=null) home = Path.get_dirname(libname);
		return ok;
	}

	public System* rts;

	public void crash_response() {
		is_running = false;
		response(Driver.ProgramState.Crash, null, *top0, 0);
	}

	public signal void new_executable();
	public signal void response(int reason, Gee.List<Breakpoint>? match,
								Gedb.StackFrame* f, uint mc);
}

public class Driver : Loader {

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

	private SourceFunc cb = null;

	private Gee.List<Breakpoint> breakpoints;
	private Gee.List<Breakpoint> match;
	
	public void update_breakpoints(Gee.List<Breakpoint> list) {
		breakpoints = list;
	}

	public void target_go(uint run, uint mode, uint repeat) {
		if (pma) return;
		if (timeout==0) {
			uint run_cmd = run;
			timeout = GLib.Timeout.@add(20, () => {
					timeout = 0;	
					switch (run_cmd) {
					case RunCommand.cont:
					case RunCommand.next:
					case RunCommand.step:
					case RunCommand.end:
					case RunCommand.back:
						is_running = true;
						break;
					default:
						is_running = false;
						break;			
					}
					return false;
				});
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
		check(IseCode.Signal_exception);
		os_signal = 0;
		intern = old_intern;
	}

	public void* check(int reason) {
		if (intern) return null;
		top = gedb_top; //*(StackFrame**)top0;
		StackFrame* rescue = null;
		Marker* m;
		interactive = just_marked;
		just_marked = false;
		bool stoppable = false;
		bool old_intern = intern;
		intern = true;
		switch(reason) {
		case Start_program_break:
			stop_code = ProgramState.Program_start;
			intern = old_intern;
			Marker.keep(0);
			m = Marker.create(top, rts);
			just_marked = true;
			return m.buffer;
		case Instruction_break:
		case Call_break:
		case Assignment_break:
		case Begin_compound_break:
			stoppable = breakpoints!=null && breakpoints.size>0;
			break;
		case Debug_break:
			if (debug_clause_enabled && run_mode!=silent) {
				interactive = true;
				stop_code = ProgramState.Debug_clause;
			}
			break;
		case After_mark_break:
			just_marked = true;
			interactive = true;
			if (stop_code!=ProgramState.Program_start) 
				stop_code = ProgramState.Still_waiting;
			break;
		case After_reset_break:
			just_marked = true;
			interactive = true;
			stop_code = ProgramState.At_reset;
			break;
		case End_program_break:
			interactive = true;
			just_marked = true;
			stoppable = false;
			stop_code = ProgramState.Program_end;
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
			stoppable = true;
		}
		if (!interactive) {
			check_step(reason);
			if (interactive) stop_code = ProgramState.Step_by_step;
		}
		if (stoppable) {
			match.clear();
			check_breakpoints(reason, top, rescue, rts, match);
			if (match.size>0) 
				stop_code = interactive 
					? ProgramState.At_breakpoint
					: ProgramState.At_tracepoint;
		}
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
//			case ProgramState.Crash:
				qm.list = match;
				stop_code = ProgramState.Still_waiting;
				break;
			}
			minimum_stack_size = top!=null ? top.depth : 0;
			if (pma) {
				new_executable();
				var bp = new Breakpoint();
				bp.exc = reason;
				match.@add(bp);
				response(stop_code, match, top, 0);
			} else {
				if (timeout!=0) {
					GLib.Source.@remove(timeout);
					timeout = 0;
				}
				target_to_gui.push(qm);
				qm = gui_to_target.pop();
			}
			just_marked = false;
			repeat = qm.code;
			cmd = repeat & 0x0f;
			repeat >>= 4;
			run_mode = repeat & 0x0f;
			repeat >>= 4;
			switch (cmd) {
			case RunCommand.cont:
				interactive = false;
				break;
			case RunCommand.next:
				target_depth = ss;
				interactive = false;
				break;
			case RunCommand.step:
				target_depth = int.MAX;
				interactive = false;
				break;
			case RunCommand.end:
				target_depth = ss;
				compound_limit = top->scope_depth-(int)repeat;
				if (compound_limit<0) compound_limit = 0;
				interactive = false;
				break;
			case RunCommand.back:
				target_depth = ss-(int)repeat;
				interactive = false;
				break;
			case RunCommand.mark:
				m = Marker.create(top, rts);
				just_marked = true;
				intern = old_intern;
				return m.buffer;
			case RunCommand.reset:
				m = Marker.at(repeat+1);
				Marker.clear_to_depth(m.depth);
				top = m.restore(rts);
				just_marked = true;
				intern = old_intern;
				longjmp_func(m.buffer, 1);
				break;
			case RunCommand.restart:
				Marker.keep(1);
				m = Marker.at(0);
				top = m.restore(rts);
				just_marked = true;
				*argc = args!=null ? args.length : 0;
				*(void**)argv = args;
				intern = old_intern;
				longjmp_func(m.buffer, 2);
				break;
			case RunCommand.exit:
				intern = false;
				Marker.keep(1);
				th.exit(0);
				break;
			}
		}
		if (os_signal>0 && rescue!=null) raise_func(0);
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
			if (r.text.rescue_pos!=0) break; 
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
				uint rid = l._entity.type.ident;
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
			interactive = (repeat<=0 && 
				(top.routine.text._feature.home.flags&ClassFlag.DEBUGGER)!=0);
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
		if (the_dg!=null) the_dg.catch_signal(sig);
	}

	private static void interrupt_handler(int sig) {
		if (the_dg!=null) the_dg.interrupted = true;
	}

	~Driver() { Marker.clear_to_depth(0); }

	public Driver(string[] args) {
		base(args);
		the_dg = this;
		pma = false;
		stop_code = ProgramState.Program_start;
		cmd = 0;
		match = new Gee.ArrayList<Breakpoint>();
		if (pma) {
			is_running = true;
		} else {
			target_to_gui = new AsyncQueue<QueueMember>();
			gui_to_target = new AsyncQueue<QueueMember>();
			queue_source = new QueueSource();
			queue_source.queue = target_to_gui;
			queue_source.attach(null);
			queue_source.set_callback(@callback);
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
	}

	public StackFrame* top { get; private set; }

	public override bool load(string? libname) {
		stop();
		if (module!=null) {
			jump_buffer_func = null;
			longjmp_func = null;
			realloc_func = null;
			free_func = null;
			wrap_func = null;
			chars_func = null;
			unichars_func = null;
			raise_func = null;
			zt = null;
			zo = null;
			zov = null;
			zms = null;
			eif_results = null;
			eif_markers = null;
			rts = null;
			top = null;
			module = null;
		}
 		void* addr;
		string lib = null;
		bool ok = true;
		module = GLib.Module.open(libname, 0);
		if (module==null) return false;
		lib = module.name();

		ok &= module.symbol("gedb_longjmp", out addr);
		addr = *(void**)addr;
		longjmp_func = (LongjmpFunc)addr;
		gedb_longjmp = addr;

		ok &= module.symbol("gedb_jmp_buffer", out addr);
		addr = *(void**)addr;
		jump_buffer_func = (JumpBufferFunc)addr;
		gedb_jmp_buffer = addr;

		ok &= module.symbol("gedb_realloc", out addr);
		addr = *(void**)addr;
		realloc_func = (ReallocFunc)addr;
		gedb_realloc = addr;

		ok &= module.symbol("gedb_free", out addr);
		addr = *(void**)addr;
		free_func = (FreeFunc)addr;
		gedb_free = addr;

		ok &= module.symbol("gedb_wrap", out addr);
		addr = *(void**)addr;
		wrap_func = (WrapFunc)addr;
		gedb_wrap = addr;

		ok &= module.symbol("gedb_chars", out addr);
		addr = *(void**)addr;
		chars_func = (CharsFunc)addr;
		gedb_chars = addr;

		ok &= module.symbol("gedb_unichars", out addr);
		addr = *(void**)addr;
		unichars_func = (UnicharsFunc)addr;
		gedb_unichars = addr;

		ok &= module.symbol("gedb_zt", out addr);
		addr = *(void**)addr;
		zt = (void**)addr;
		ok &= module.symbol("gedb_zo", out addr);
		addr = *(void**)addr;
		zo = (void**)addr;
		ok &= module.symbol("gedb_zov", out addr);
		addr = *(void**)addr;
		zov = (void**)addr;
		ok &= module.symbol("gedb_zms", out addr);
		addr = *(void**)addr;
		zms = (void**)addr;
		ok &= module.symbol("GE_argc", out addr);
		argc = (int*)addr;
		ok &= module.symbol("GE_argv", out addr);
		argv = addr;
		ok &= module.symbol("gedb_results", out addr);
		eif_results = addr;
		*eif_results = null;
		ok &= module.symbol("gedb_markers", out addr);
		eif_markers = addr;	
		*eif_markers = null;
		ok &= module.symbol("gedb_rts", out addr);
		if (addr!=null) rts = *(System**)addr;
		gedb_rts = rts;
		ok &= module.symbol("gedb_top", out addr);
		top0 = (StackFrame**)addr;
		gedb_top = *(void**)top0;
		set_offsets(); 
		if (libname!=null) {
			ok &= module.symbol("GE_raise", out addr);
			var raise = (RaiseFunc)addr;
			ok &= module.symbol("GE_main", out addr);
			var main = (MainFunc)addr;
			if (ok) ok = run(main, raise);
		}
		return ok;
	}

	public bool run(MainFunc main, RaiseFunc raise) {
		raise_func = raise;
		new_executable();
		try {
			th = new Thread<int>("Debuggee", () => 
				{ return main(args.length, (void**)args); });
		} catch (Error e) { 
			return false;
		}
		return true;
	}

	public void stop() {
		if (th!=null) {
			var qm = new QueueMember(RunCommand.exit);
			gui_to_target.push(qm);
			th.join();
			th = null;
		}
	}

}

private weak Driver the_dg;
