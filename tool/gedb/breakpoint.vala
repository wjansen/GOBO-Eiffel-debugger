using Gedb;

public const int trace = 1;
public const int silent = 2;

public const int Instruction_break = 0;
public const int Call_break = -1;
public const int Step_into_break = -2;
public const int Assignment_break = -3;
public const int Debug_break = -4;
public const int Begin_compound_break = -5;
public const int End_compound_break = -6;
public const int Start_program_break = -7;
public const int End_program_break = -8;
public const int After_mark_break = -9;
public const int After_reset_break = -10;

public enum IseCode {
  Void_call_target = 1,
  No_more_memory,
  Precondition,
  Postcondition,
  Floating_point_exception,
  Class_invariant,
  Check_instruction,
  Routine_failure,
  Incorrect_inspect_value,
  Loop_variant,
  Loop_invariant,
  Signal_exception,
  Eiffel_runtime_panic,
  Rescue_exception,
  Out_of_memory,
  Resumption_failed,
  Create_on_deferred,
  External_event,
  Void_assigned_to_expanded,
  Exception_in_signal_handler,
  Io_exception,
  Operating_system_exception,
  Retrieve_exception,
  Developer_exception,
  Eiffel_runtime_fatal_error,
  Dollar_applied_to_melted,
  Runtime_io_exception,
  Com_exception,
  Runtime_check_exception,
  Old_exception,
  Serialization_exception,
  number_of_codes
}

public class WatchInfo  : GLib.Object {

	private Gedb.Type* _type;
	private uint8[] value;
	private uint8[] previous;

	public Entity* entity { get; private set; }
	public int depth { get; private set; }
	public Gedb.Type* type() { return _type; }
	public uint8* address { get; private set; }

	public bool value_changed(int depth) { 
		if (depth<this.depth) {
			invalidate();
			return true;
		}
		if (address==null) return false;
		uint size = value.length;
		return !are_values_equal(address, value, size);
	}

	public void invalidate() { address = null; }

	private WatchInfo() {}

	public WatchInfo.from_data(DataItem? data, StackFrame* f, System* s) {
		if (data==null)  return;
		DataItem? iter;
		bool ok = false;
		for (iter=data; iter!=null; iter=iter.parent()) {
			switch (iter.mode) {
			case DataMode.EXTERN:
				if (iter==data) return;
				break;
			case DataMode.CURRENT:
			case DataMode.FIELD:
				_type = s.type_at(iter.tid);
				ok |= !_type.is_subobject(); 
				continue;
				break;
			}
		}
		if (!ok) depth = f!=null ? f.depth : 0;
		entity = data.field;
		_type = s.type_at(data.tid);
		uint size = _type.field_bytes();
		int off = entity.is_local() ?
			((Local*)entity).offset : ((Field*)entity).offset;
		address = data.home!=null ? data.home : (uint8*)f;
		address += off;
		if (data.idx>=0)  address += data.idx*size;
		value = new uint8[size];
		copy_value(value, address, size);
	}

	public void refresh(System* s) {
		if (_address==null) return;
		var size = _type.field_bytes();
		if (!_type.is_subobject()) {
			_type = s.type_of_any(_type.dereference(_address), _type);
		}
		previous = value;
		value = new uint8[size];
		copy_value(value, _address, size);
	}

	public string append_to(string? to=null, bool old=false) {
		var here = to!=null ? to : "";
		if (address==null) return here;
		uint8[] val = old ? previous : value;
		here += format_value(val, 0, true, _type, FormatStyle.ADDRESS);
		if (!is_zero_value(val, _type.field_bytes())) {
			here += " : ";
			here += format_type(val, 0, true, _type);
		}
		return here;
	}

}

public class Breakpoint : GLib.Object {

	private static int max = 0;

	private static string?[] names;
	private static string?[] short_names;
	private static Gee.HashMap<string,int> codes;
	private static uint[] code_map;

	private static void fill_catches() 
	ensures (names!=null) ensures (short_names!=null) ensures (codes!=null) {
		if (names==null) {
			int i, n=IseCode.number_of_codes;
			names = new string[n];
			short_names = new string[n+1];
			codes = new Gee.HashMap<string,int>();
			code_map = new uint[n];

			names[IseCode.Void_call_target] = "call on void target";
			names[IseCode.No_more_memory] = "no more memory";
			names[IseCode.Check_instruction] = "failed check instruction";
			names[IseCode.Routine_failure] = "routine failure";
			names[IseCode.Incorrect_inspect_value] = "incorrect inspect value";
			names[IseCode.Signal_exception] = "severe OS signal";
			// names[IseCode.Out_of_memory] = "out of memory";
			// names[IseCode.Create_on_deferred] = "create on deferred";
			// names[IseCode.External_event] = "external event";
			names[IseCode.Eiffel_runtime_panic] = "CATcall";
			names[IseCode.Io_exception] = "I/O error";
			names[IseCode.Developer_exception] = "developer exception";
			// names[IseCode.Eiffel_runtime_fatal_error] = "fatal error";
			
			short_names[IseCode.Void_call_target] = "void";
			short_names[IseCode.No_more_memory] = "memory";
			short_names[IseCode.Check_instruction] = "check";
			short_names[IseCode.Routine_failure] = "failure";
			short_names[IseCode.Incorrect_inspect_value] = "when";
			// short_names[IseCode.Out_of_memory] = "out of memory";
			short_names[IseCode.Signal_exception] = "signal";
			// short_names[IseCode.Create_on_deferred] = "create on deferred";
			// short_names[IseCode.External_event] = "external event";
			short_names[IseCode.Eiffel_runtime_panic] = "eiffel";
			short_names[IseCode.Io_exception] = "io";
			short_names[IseCode.Developer_exception] = "raise";
			// short_names[IseCode.Eiffel_runtime_fatal_error] = "fatal";
			short_names[IseCode.number_of_codes] = "all";
			
			codes.@set("void", IseCode.Void_call_target);
			codes.@set("memory", IseCode.No_more_memory);
			// codes.@set("require", IseCode.PRE);
			// codes.@set("ensure", IseCode.POST);
			// codes.@set("invariant", IseCode.INV);
			codes.@set("check", IseCode.Check_instruction);
			codes.@set("failure", IseCode.Routine_failure);
			codes.@set("when", IseCode.Incorrect_inspect_value);
			// codes.@set("loop", IseCode.LOOP);
			// codes.@set("old", IseCode.OLD);
			codes.@set("eiffel", IseCode.Eiffel_runtime_panic);
			codes.@set("signal", IseCode.Signal_exception);
			// codes.@set("serial", IseCode.SERIAL);
			codes.@set("io", IseCode.Io_exception);
			codes.@set("raise", IseCode.Developer_exception);
			codes.@set("all", IseCode.number_of_codes);

			for (i=0; i<n; ++i) code_map[i] = i;
			code_map[15] = IseCode.No_more_memory;
			code_map[22] = IseCode.Signal_exception;
			code_map[18] = IseCode.Io_exception;
			code_map[21] = IseCode.Io_exception;
			code_map[27] = IseCode.Io_exception;
			code_map[25] = IseCode.Eiffel_runtime_panic;
		}
	}

	public static string? name_of_catch(uint i) {
		fill_catches();
		return (0<i && i<=32) ? names[i] : null;
	}

	public static string? short_name_of_catch(uint i) {
		fill_catches();
		return (0<i && i<=IseCode.number_of_codes) ? short_names[i] : null;
	}

	public static uint code_of_catch(string name) {
		fill_catches();
		int n = codes.@get(name);
		return codes.has_key(name) ? n : 0;
	}

	public static uint map_code(uint n) {
		return code_map[n];
	}

	public static uint catch_codes_count() { 
		fill_catches();
		return short_names.length; 
	}

	public static uint catch_count() { 
		fill_catches();
		return codes.size; 
	}

	public Breakpoint() { this.with_ident(++max); }

	public Breakpoint.with_location(uint cid, uint pos, bool next_id) {
		this.with_ident(next_id ? ++max : 0);
		this.cid = cid;
		this.pos = pos;
	}

	public Breakpoint.with_ident(uint id) { 
		this.id = id; 
		this.enabled = true;
	}

	public uint id { get; private set; }
	public uint exc { get; set; }
	public uint cid { get; set; }
	public uint pos { get; set; }
	public uint depth { get; set; }
	public bool pp { get; set; }
	public WatchInfo? watch { get; set; }
	public uint tid { get; set; }
	public Expression? iff { get; set; }
	public Expression? print { get; set; }
	public bool cont { get; set; }
	public bool enabled { get; set; }

	public string? catch_to_string() { 
		uint code = exc % 256;
		uint sig = exc / 256;
		string str = name_of_catch(code); 
		if (sig>0) {
 			str += " (";
			switch (sig) {
			case ProcessSignal.ILL:
				str += "illegal instruction";
				break;
			case ProcessSignal.ABRT:
				str += "abort signal";
				break;
			case ProcessSignal.FPE:
				str += "floating point exception";
				break;
			case ProcessSignal.SEGV:
				str += "invalid memory reference";
				break;
				}
			str += ")";
		}
		return str;
	}

	public string? catch_to_short_string() { return short_name_of_catch(exc); }

	public string to_string(Gedb.StackFrame* f=null, System* s=null) {
		string str;
		if (id==0) {
			str = "Temporary breakpoint";
			if (pos==0) str += " out of scope";
			return str + "\n";
		}
		str = cont ? "Tracepoint" : "Breakpoint";
		str += " %d\n".printf((int)id);
		if (exc>0) {
			str += "  exception: ";
			str += catch_to_string();
			str += "\n";
		}
		if (watch!=null) {
			if (watch.address!=null) {
				str += watch.append_to("  old : ", true);
				str += "\n";
				str += watch.append_to("  new : ");
				str += "\n";
			} else {
				str += "Watch address has gone out of scope.\n";
			}
		}
		if (print!=null && f!=null && s!=null) {
			try {
				print.compute_in_stack(f, s);
				str += print.bottom().format_values(2,
					print.Format.WITH_NAME |
					print.Format.WITH_TYPE |
					print.Format.INDEX_VALUE ,
					f, s);
			} catch (Error e) {
				// TODO show parse error 
			}
		}
		return str;
	}

}
