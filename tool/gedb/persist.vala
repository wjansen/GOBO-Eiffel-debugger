/**
   author: "Wolfgang Jansen"
   date: "$Date$"
   revision: "$Revision$"
*/

internal int dp;
internal int max_dp;

namespace Gedb {

	public class Persistence<O,I> {

		private I last_id;
		private Entity* last_e;
		private int last_idx;

		public Persistence() {
			known_objects = new Gee.HashMap<I,O>();
		}

/**
   Deep traversal of a memory object or a stored
   persistence closure given in `src' and to be treated by `tgt'.

   @tgt target to store to
   @src source to read from
 */
		public void traverse(Target<O> tgt, Source<I> src) {
			source = src;
			target = tgt;
			process_closure();
		}
		
/**
   Deep traversal of the variables of an active routine 
   (i.e. `Current', arguments, local variables, object test variables, 
   and across iterators). 
   
   @tgt target to store to
   @src source to read from
   @f the routine's stack frame (it identifies the routine uniquely)
   @s the Eiffel system
   @with_onces whether to include values of once functions
 */
		public void traverse_stack(Target<O> tgt, Source<I> src,
								   StackFrame* f, System* s,
								   bool with_onces) {
			uint i, n;
			source = src;
			target = tgt;
			Routine* r = f!=null ? f.routine : null;
			Local* l;
			if (r!=null) {
				n = r.argument_count + r.local_count + r.old_value_count;
				for (i=0; i<n; ++i) {
					l = r.vars[i];
					if (l!=null) {
						source.set_local(l, f);
						target.set_local(l, f);
						last_id = source_void_ident;
						last_e = (Entity*)l;
						last_idx = -1;
						process_entity((Entity*)l);
					}
				}
				n += r.scope_var_count;
				for (; i<n; ++i) {
					l = r.vars[i];
					if (l!=null) {
						source.set_local(l, f);
						target.set_local(l, f);
						last_e = (Entity*)l;
						last_id = source_void_ident;
						last_idx = -1;
						if (source.last_scope_var) process_entity((Entity*)l);
					}
				}
			}
			if (!with_onces) return;
			Once* o;
			bool init;
			for (i=0, n=s.once_count(); i<n; ++i) {
				o = s.once_at(i);
				source.set_once(o);
				init = source.last_once_init;
				target.set_once(o, init);
				if (((Routine*)o).is_function() && init) {
					last_id = source_void_ident;
					last_idx = -1;
					last_e = (Entity*)o;
					process_entity((Entity*)o);
				}
			}	
		}

		public signal void when_new(O od, I id, Gedb.Type* t, uint n,
									I where, Entity* e, int i);
		public signal void when_known(O od, I id, Gedb.Type* t, uint n,
									I where, Entity* e, int i);

		protected virtual void process_closure() {
			I id, id1=source_void_ident;
			bool ready = false;
			do {
				source.read_next_ident();
				id = source.last_ident;
				ready = id==source_void_ident; 
				if (!ready) {
					if (id1==source_void_ident) id1 = id;
					if (!known_objects.contains(id)) {
						process_announcement(id, true);
					} else if (source.is_reread(id)) {
						source.reread();
						ready = id==id1;
						if (!ready) process_data(id, source.last_dynamic_type);
					} else {
					}
				}
			} while (!ready);
		}

		protected void process_announcement(I id, bool to_reread) {
			source.read_context(id);
			Gedb.Type* t = source.last_dynamic_type;
			uint n = source.last_cap;
			if (to_reread) source.to_reread(id);
			string str;
			if (t!=null) {
				if (t.is_special()) {
					str = @"[$n] ";
					target.put_new_special((SpecialType*)t, n);
				} else {
					str = "%s".printf(((Gedb.Name*)t).fast_name);
					target.put_new_object(t);
				}
				O od = target.last_ident;
				known_objects[id] = od;
				when_new(od, id, t, n, last_id, last_e, last_idx);
				process_data(id, t);
			} else {
				known_objects[id] = null;
			}
		}

		protected virtual void process_data(I id, Gedb.Type* t) {
			O od = known_objects[id];
			if (t.is_special()) {
				process_special((SpecialType*)t, source.last_cap, id, od);
			} else if (t.is_agent()) {
				process_agent((AgentType*)t, id, od);
			} else {
				process_normal_or_tuple(t, true, id, od);
			}
		}
		
		protected void process_normal_or_tuple(Gedb.Type* t, bool as_ref, I id, O od) {
			source.pre_object(t, as_ref, id);
			target.pre_object(t, as_ref, od);
			Field* f;
			uint k, n=t.field_count();
			for (k=0; k<n; ++k) {
				f = t.field_at(k);
				source.set_field(f, id);
				target.set_field(f, od);
				last_id = id;
				last_e = (Entity*)f;
				last_idx = -1;
				process_entity((Entity*)f);
			}
			source.post_object(t, as_ref, id);
			target.post_object(t, as_ref, od);
		}
		
		protected void process_agent(AgentType* at, I id, O od) {
			Gedb.Type* t = (Gedb.Type*)at;
			TupleType* tt;
			Field* f;
			uint k, n=at.closed_operand_count;
			source.pre_object(t, true, id);
			target.pre_object(t, true, od);
			if (n>0) {
				source.pre_agent(at, id);
				target.pre_agent(at, od);
				for (k=0; k<n; ++k) {
					f = t.field_at(k);
					source.set_field(f, id);
					target.set_field(f, od);
					last_id = id;
					last_e = (Entity*)f;
					last_idx = -1;
					process_entity((Entity*)f);
				}
				source.post_agent(at, id);
				target.post_agent(at, od);
			}
			f = at.last_result();
			if (f!=null) {
				source.set_field(f, id);
				target.set_field(f, od);
				last_id = id;
				last_e = (Entity*)f;
				last_idx = -1;
				process_entity((Entity*)f);
			}
			source.post_object(t, true, id);
			target.post_object(t, true, od);
		}
			
		protected void process_special(SpecialType* st, uint cap, I id, O od) {
			Gedb.Type* it = st.item_type();
			Entity* f = (Entity*)st.item_0();
			source.pre_special(st, cap, id);
			target.pre_special(st, cap, od);
			switch (it.ident) {
			case 3:
				source.read_chars(cap);
				target.put_chars(od, source.last_chars, cap, st);
				break;
			case 6:
				source.read_int32s(cap);
				target.put_int32s(od, source.last_int32s, cap, st);
				break;
			case TypeIdent.REAL_64:
				source.read_doubles(cap);
				target.put_doubles(od, source.last_doubles, cap, st);
				break;
			default:
				for (uint k=0; k<cap; ++k) {
					source.set_index(st, k, id);
					target.set_index(st, k, od);
					last_id = id;
					last_e = null;
					last_idx = (int)k;
					process_entity(f);
				}
				break;
			}
			source.post_special(st, id);
			target.post_special(st, od);
		}
		
		public void process_entity(Entity* f) {
			Gedb.Type* t = f.type;
			if (t==null) return;
			if (t.is_basic()) {
				process_basic_field(t);
			} else if (t.is_subobject()) {
				process_normal_or_tuple(t, false, source_void_ident, target_void_ident);
			} else {
				source.read_field_ident();
				I id = source.last_ident;
				if (id!=source_void_ident) {
					if (known_objects.contains(id)) {
						Gedb.Type* dyn = source.last_dynamic_type;
						uint n = source.last_cap;
						O od = known_objects[id];
						target.put_known_ident(od, dyn);
						when_known(od, id, dyn, n, last_id, last_e, last_idx);
					} else {
						process_announcement(id, false);
					}
				} else {
					target.put_void_ident(t);
				}
			}
		}
		
		public void process_basic_field(Gedb.Type* t) {
			switch (t.ident) {
			case 1:
				source.read_bool();
				target.put_bool(source.last_bool);
				break;
			case 2:
				source.read_char();
				target.put_char(source.last_char);
				break;
			case 3:
				source.read_char32();
				target.put_char32(source.last_char32);
				break;
			case 4:
				source.read_int8();
				target.put_int8(source.last_int8);
				break;
			case 5:
				source.read_int16();
				target.put_int16(source.last_int16);
				break;
			case 6:
				source.read_int32();
				target.put_int32(source.last_int32);
				break;
			case 7:
				source.read_int64();
				target.put_int64(source.last_int64);
				break;
			case 8:
				source.read_nat8();
				target.put_nat8(source.last_nat8);
				break;
			case 9:
				source.read_nat16();
				target.put_nat16(source.last_nat16);
				break;
			case 10:
				source.read_nat32();
				target.put_nat32(source.last_nat32);
				break;
			case 11:
				source.read_nat64();
				target.put_nat64(source.last_nat64);
				break;
			case 12:
				source.read_real();
				target.put_real(source.last_real);
				break;
			case 13:
				source.read_double();
				target.put_double(source.last_double);
				break;
			case 14:
				source.read_pointer();
				target.put_pointer(source.last_pointer);
				break;
			default:
				break;
			}
		}

		public Source<I> source;
		public Target<O> target;

		public I source_void_ident { get; protected set; }
		public O target_void_ident { get; protected set; }

		public Gee.HashMap<I,O> known_objects { get; set; }

	} /* class Persistence */

	public abstract class Source<I> {

		public I void_ident { get; protected set; }
		public I last_ident { get; protected set; }
		
		public Gedb.Type* last_dynamic_type { get; protected set; }
		
		public bool last_bool { get; protected set; }
		public char last_char { get; protected set; }
		public uint32 last_char32 { get; protected set; }
		public int8 last_int8 { get; protected set; }
		public int16 last_int16 { get; protected set; }
		public int32 last_int32 { get; protected set; }
		public int64 last_int64 { get; protected set; }
		public uint8 last_nat8 { get; protected set; }
		public uint16 last_nat16 { get; protected set; }
		public uint32 last_nat32 { get; protected set; }
		public uint64 last_nat64 { get; protected set; }
		public float last_real { get; protected set; }
		public double last_double { get; protected set; }
		public void* last_pointer { get; protected set; }
		public bool last_once_init { get; protected set; }
		public bool last_scope_var { get; protected set; }

		public unowned char[] last_chars;
		public unowned int32[] last_int32s;
		public unowned double[] last_doubles;

		public Entity* field;
		public Gedb.Type* field_type() { 
			return field!=null ? field.type : null; 
		}


/**
   Read a top level object ident and put it into `last_ident'.
 */
		public abstract void read_next_ident();

/**
   Read object ident of a field and put it into `last_ident'.
 */
		public abstract void read_field_ident();

/**
   Read dynamic type of `id' and put it into `last_dynamic_type',
   in case of a SPECIAL object read also its capacity. 
 */
		public abstract void read_context(I id);
		
		/**
		   Begin treatment of an object.
		   @t dynamic object type
		   @as_ref is reference (boxed if `t' is subobject type)
		   @id "object ident
		*/
		public abstract void pre_object(Gedb.Type* t, bool as_ref, I id);

		/**
		   Finish treatment of an object.
		*/
		public abstract void post_object(Gedb.Type* t, bool as_ref, I id);

		/**
		   Begin treatment of an agent object.
		   @t dynamic object type
		   @id "object ident
		*/
		public abstract void pre_agent(AgentType* at, I id);

		/**
		   Finish treatment of an agent object.
		*/
		public abstract void post_agent(AgentType* at, I id);

		/**
		   Begin treatment of an array object.
		   @st dynamic object type
		   @cap array size
		   @id "object ident
		*/
		public abstract void pre_special(SpecialType* st, uint cap, I id);

		/**
		   Finish treatment of an array object.
		*/
		public abstract void post_special(SpecialType* st, I id);

		public abstract void read_bool();
		public abstract void read_char();
		public abstract void read_char32();
		public abstract void read_int8();
		public abstract void read_int16();
		public abstract void read_int32();
		public abstract void read_int64();
		public abstract void read_nat8();
		public abstract void read_nat16();
		public abstract void read_nat32();
		public abstract void read_nat64();
		public abstract void read_real();
		public abstract void read_double();
		public abstract void read_pointer();
		public abstract void read_chars(uint cap);
		public abstract void read_int32s(uint cap);
		public abstract void read_doubles(uint cap);
		public abstract void read_scope_var();

		/**
		   Set the descriptor for the next local variable to be treated.
		   @l variable descriptor
		   @in ident of enclosing object
		 */
		public virtual void set_local(Local* l, StackFrame* f) {
			field = (Entity*)l;
			last_ident = id0;
		}

/**
   Set the descriptor for the next once function value to be treated.
 */
		public virtual void set_once(Once* o) {
			field = (Entity*)o;
			last_ident = id0;
		}

		/**
		   Set the descriptor for the next field to be treated.
		   @f field descriptor
		   @in ident of enclosing object
		 */
		public virtual void set_field(Field* f, I in_id) { 
			field = (Entity*)f; 
		}

/**
   Set the array index `i' and of the next array field to be treated.
   @st type descriptor
   @in ident of enclosing object
*/
		public virtual void set_index(SpecialType* st, uint i, I in_id) {
			field = (Entity*)st.item_0();
		}
	  
		public uint last_cap;

		public Context<I> contexts;

		/**
		   Put object ident `id' back into source for rereading.
		 */
		public void to_reread(I id) {
			Gedb.Type* t = last_dynamic_type;
			contexts.to_reread(id, t, last_cap);
		}

/**
   Reread context of last object into `last_dynamic_type',
   `last_cap' and remove the context.
*/
		public void reread() {
			contexts.reread();
			last_dynamic_type = contexts.type;
			last_cap = contexts.cap;
		}

/**
   Is `id' the last reread ident?
 */
		public bool is_reread(I id) {
			return contexts.is_reread(id);
		}
		
		public abstract void process_ident(I id);

		private I id0;

	} /* class Source */

	public class StreamSource : Source<uint> {

		public StreamSource(string path, System* s) {
			file = FileStream.open(path, "r");
			system = s;
			contexts = new Context<uint>();
		}

		public size_t pos { get; protected set; }

		public System* system { get; protected set; }
		protected FileStream file;

		public override void read_next_ident() {
			read_int();
		}

		public override void set_once(Once* o) {
			read_bool();
			last_once_init = last_bool;
		}

		public override void read_field_ident() {
			read_int();
			last_ident = (uint)last_int;
		}

		public override void read_context(uint id) {
			if (id==0) {
				last_dynamic_type = null;
				last_cap = 0;
			} else {
				read_int();
				last_dynamic_type = system.type_at(last_int);
				if (last_dynamic_type.is_special()) {
					read_int();
					last_cap = (uint)last_int;
				} else {
					last_cap = 0;
				}
			}
		}

		public override void pre_object(Gedb.Type* t, bool as_ref, uint id) {}
		public override void post_object(Gedb.Type* t, bool as_ref, uint id) {}
		public override void pre_agent(AgentType* at, uint id) {}
		public override void post_agent(AgentType* at, uint id) {}
		
		public override void pre_special(SpecialType* st, uint cap, uint id) {}

		public override void post_special(SpecialType* st, uint id) {}
		
		public override void read_bool() {
			int i = file.getc();
			++pos;
			last_bool = i!=0;
		}
		
		public override void read_char() {
			int i = file.getc();
			++pos;
			last_char = (char)i;
		}
		
		public override void read_char32() {
			read_int();
			last_char32 = last_int;
		}

		public override void read_int8() {
			int i = file.getc();
			++pos;
			last_int8 = (int8)i;
		}
		
		public override void read_int16() {
			int i1 = file.getc();
			int i0 = file.getc();
			pos += 2;
			last_int16 = (int16)(i1<<8+i0);
		}
		
		public override void read_int32() {
			read_int();
			last_int32 = last_int;
		}
		
		public override void read_int64() {
			read_long();
			last_int64 = last_long;
		} 
		public override void read_nat8() {
			int i = file.getc();
			++pos;
			last_nat8 = (uint8)i;
		}
		
		public override void read_nat16() {
			int i1 = file.getc();
			int i0 = file.getc();
			pos += 2;
			last_nat16 = (uint16)(i1<<8+i0);
		}
		
		public override void read_nat32() {
			read_int();
			last_nat32 = (uint32)last_int;
		}
		
		public override void read_nat64() {
			read_int64();
			last_nat64 = (uint64)last_long;
		}
		
		public override void read_real() {
			read_int();
			void* addr = &last_int;
			last_real = *(float*)addr;
		}
		
		public override void read_double() {
			read_long();
			void* addr = &last_long;
			last_double = *(double*)addr;
		}
		
		public override void read_pointer() {
			read_long();
			last_pointer = &last_long;
		}
		
		public override void read_chars(uint cap) {
			last_chars.resize((int)cap);
			for (uint i=0; i<cap; ++i) {
				read_char();
				last_chars[i] = last_char;
			}			
		}

		public override void read_int32s(uint cap) {
			last_int32s.resize((int)cap);
			for (uint i=0; i<cap; ++i) {
				read_int32();
				last_int32s[i] = last_int32;
			}			
		}

		public override void read_doubles(uint cap) {
			last_doubles.resize((int)cap);
			for (uint i=0; i<cap; ++i) {
				read_double();
				last_doubles[i] = last_double;
			}			
		}

		public override void read_scope_var() {
			read_bool();
			last_scope_var = last_bool;
		}
		
		protected override void process_ident(uint id) {}

		protected void read_int() {
			uint8 buf[4];
			pos += file.read(buf);
			last_int = *(int*)buf;
		}

		protected void read_long() {
			uint8 buf[8];
			pos += file.read(buf);
			last_long = *(int64*)buf;
		}

		protected void read_str() {
			last_str = file.read_line();
			pos += last_str.length+1;
		}

		protected int32 last_int;
		protected int64 last_long;
		protected string last_str;

	} /* class StreamSource */

	public class MemorySource : Source<void*> {
		
		public System* system { get; protected set; }

		public MemorySource(StackFrame* f, System* s) { 
			frame = f;
			system = s;
			any_type = s.type_at(TypeIdent.ANY);
			offsets = new OffsetStack();
			contexts = new Context<void*>();
		}

		public void set_frame(StackFrame* f) { frame = f; }

		public override void set_local(Local* l, StackFrame* f) { 
			field = (Entity*)l; 
			offsets = new OffsetStack();
			offsets.push_offset(f);
			offsets.set_field_offset(field);
			top = null;
		}

		public override void set_once(Once* o) {
			last_once_init = o.is_initialized();
			if (last_once_init && ((Routine*)o).is_function()) {
				field = (Entity*)o; 
				offsets = new OffsetStack();
				offsets.push_offset(o.value_address);
			}
			top = null;
		}

		public override void set_field(Field* f, void* in_id) { 
			field = (Entity*)f; 
			offsets.set_field_offset(field);
		}

		public override void set_index(SpecialType* st, uint i, void* in_id) {
			field = (Entity*)st.item_0();
			field_increment = st.item_type().field_bytes();
			offsets.set_indexed_offset(st, i);
		}

		public override void read_next_ident() {
			contexts.next_ident();
			void* id = contexts.ident;
			if (id==null) id = top;
		}

		public override void read_field_ident() {
			Gedb.Type* t = field_type();
			process_ident(offsets.actual_object(t));
		}

		public override void read_context(void* id) {
			process_ident(id);
		}		

		public override void pre_object(Gedb.Type* t, bool as_ref, void* id) {
			if (as_ref) offsets.push_offset(id);
			else  offsets.push_expanded_offset();
		}

		public override void post_object(Gedb.Type* t, bool as_ref, void* id) {
			offsets.pop_offset();
		}

		public override void pre_agent(AgentType* at, void* id) {
			void* obj = *(void**)at.closed_operands((uint8*)id);
			offsets.push_offset(obj);
		}

		public override void post_agent(AgentType* at, void* id) {
			offsets.pop_offset();
		}

		public override void pre_special(SpecialType* st, uint cap, void* id) {
			offsets.push_offset(id);			
		}

		public override void post_special(SpecialType* st, void* id) {
			offsets.pop_offset();
		}

		public override void read_bool() {
			last_bool = *(bool*)offsets.home_address();
		}

		public override void read_char() {
			last_char = *(char*)offsets.home_address();
		}

		public override void read_char32() {
			last_char32 = *(uint32*)offsets.home_address();
		}

		public override void read_int8() {
			last_int8 = *(int8*)offsets.home_address();
		}

		public override void read_int16() {
			last_int16 = *(int16*)offsets.home_address();
		}

		public override void read_int32() {
			last_int32 = *(int32*)offsets.home_address();
		}

		public override void read_int64() {
			last_int64 = *(int64*)offsets.home_address();
		}

		public override void read_nat8() {
			last_nat8 = *(uint8*)offsets.home_address();
		}

		public override void read_nat16() {
			last_nat16 = *(uint16*)offsets.home_address();
		}

		public override void read_nat32() {
			last_nat32 = *(uint32*)offsets.home_address();
		}

		public override void read_nat64() {
			last_nat64 = *(uint64*)offsets.home_address();
		}

		public override void read_real() {
			last_real = *(float*)offsets.home_address();
		}

		public override void read_double() {
			last_double = *(double*)offsets.home_address();
		}

		public override void read_pointer() {
			last_pointer = offsets.home_address();
		}

		public override void read_chars(uint cap) {
			last_chars = (char[])offsets.home_address();
		}

		public override void read_int32s(uint cap) {
			last_int32s = (int32[])offsets.home_address();
		}

		public override void read_doubles(uint cap) {
			last_doubles = (double[])offsets.home_address();
		}

		public override void read_scope_var() {
			ScopeVariable* ot = (ScopeVariable*)field;
			last_scope_var = ot.in_scope(frame.line(), frame.column());
		}

		public override void process_ident(uint8* id) {
			last_ident = void_ident;
			last_dynamic_type = null;
			last_cap = 0;
			if (id==null) return;
			Gedb.Type* t = system.type_of_any(id, any_type);
			if (t==null) return;
			id = system.unboxed(id, any_type);
			last_ident = id;
			last_dynamic_type = t;
			if (t.is_special()) 
				last_cap = ((SpecialType*)t).special_count(id);
		}

		protected StackFrame* frame;
		protected OffsetStack offsets;
		protected void* top;
		protected uint field_increment;
		protected Gedb.Type* any_type;

	} /* class MemorySource */

	public class SaveMemorySource : MemorySource {

		public SaveMemorySource(StackFrame* f, System* s, void** oo) { 
			base(f, s);
			objects = oo;
		}

		public override void pre_object(Gedb.Type* t, bool as_ref, void* id) {
			base.pre_object(t, as_ref, id);
			if (!as_ref) return;
			++object_index;
			size_t n = (sizeof(void*))*(object_index+1);
			unowned void*[] oo = (void*[])realloc_func(*objects, n);
			*objects = oo;
			oo[object_index] = id;
		}

		public override void pre_agent(AgentType* at, void* id) {
			base.pre_agent(at, id);
			++object_index;
			size_t n = (sizeof(void*))*(object_index+1);
			unowned void*[] oo = (void*[])realloc_func(*objects, n);
			*objects = oo;
			var obj = *(void**)at.closed_operands((uint8*)id);
			oo[object_index] = obj;
		}

		public override void pre_special(SpecialType* st, uint cap, void* id) {
			base.pre_special(st, cap, id);
			++object_index;
			size_t n = (sizeof(void*))*(object_index+1);
			unowned void*[] oo = (void*[])realloc_func(*objects, n);
			*objects = oo;
			oo[object_index] = id;
		}

		protected unowned void** objects; 
		protected uint object_index;

	} /* */

	public abstract class Target<O> {

		public int index;
		public Entity* field;

		public Gedb.Type* field_type() { 
			return field!=null ? field.type : null; 
		}

		public O void_ident { get; protected set; }
		public O last_ident { get; protected set; }
		public O top_ident { get; protected set; }

		/**
		   Begin treatment of an object.
		   @t dynamic object type
		   @as_ref is reference (boxed if `t' is subobject type)
		   @id "object ident
		*/
		public abstract void pre_object(Gedb.Type* t, bool as_ref, O id);

		/**
		   Finish treatment of an object.
		*/
		public abstract void post_object(Gedb.Type* t, bool as_ref, O id);

		/**
		   Begin treatment of an agent object.
		   @t dynamic object type
		   @id "object ident
		*/
		public abstract void pre_agent(AgentType* t, O id);

		/**
		   Finish treatment of an agent object.
		*/
		public abstract void post_agent(AgentType* t, O id);

		/**
		   Begin treatment of an array object.
		   @st dynamic object type
		   @cap array size
		   @id "object ident
		*/
		public abstract void pre_special(SpecialType* st, uint cap, O id);
		public abstract void post_special(SpecialType* st, O id);

		public abstract void finish(O top, Gedb.Type* t);

		public abstract void put_bool(bool b);
		public abstract void put_char(char c);
		public abstract void put_char32(uint32 c);
		public abstract void put_int8(int8 i);
		public abstract void put_int16(int16 i);
		public abstract void put_int32(int32 i);
		public abstract void put_int64(int64 i);
		public abstract void put_nat8(uint8 n);
		public abstract void put_nat16(uint16 n);
		public abstract void put_nat32(uint32 n);
		public abstract void put_nat64(uint64 n);
		public abstract void put_real(float r);
		public abstract void put_double(double d);
		public abstract void put_pointer(void* p);
		public abstract void put_known_ident(O id, Gedb.Type* t);
		public abstract void put_void_ident(Gedb.Type* t);
		public abstract void put_new_object(Gedb.Type* t);
		public abstract void put_new_special(SpecialType* st, uint cap);
		public abstract void put_scope_var(bool ot);

		public abstract void put_chars(O id, char[] cc, uint cap,
										 SpecialType* st);
		public abstract void put_int32s(O id, int32[] ii, uint cap,			
										   SpecialType* st);

		public abstract void put_doubles(O id, double[] dd, uint cap, 
										   SpecialType* st);

		public virtual void set_local(Local* l, StackFrame* f) {
			field = (Entity*)l;
			index = -1;
			last_ident = id0;
		}

		public virtual void set_once(Once* o, bool init) {
			field = (Entity*)o;
			index = -1;
			last_ident = id0;
		}

		public virtual void set_field(Field* f, O id) {
			field = (Entity*)f;
			index = -1;
		}

		public virtual void set_index(SpecialType* st, uint i, O id) {
			field = (Entity*)st.item_0();
			index = (int)i;
		}

		private O id0;

	} /* class Target */

	public class NullTarget : Target<uint> {
		
		public override void pre_object(Gedb.Type* t, bool as_ref, uint id) {}
		public override void post_object(Gedb.Type* t, bool as_ref, uint id) {}
		public override void pre_agent(AgentType* t, uint id) {}
		public override void post_agent(AgentType* t, uint id) {}
		public override void pre_special(SpecialType* st, uint cap, uint id) {}
		public override void post_special(SpecialType* st, uint id) {}
		
		public override void put_new_object(Gedb.Type* t) {
			next_ident();
		}
		
		public override void put_new_special(SpecialType* st, uint cap) {
			next_ident();
		}
		
		public override void put_chars(uint id, char[] cc, uint cap,
										 SpecialType* st) {
			for (uint i=0; i<cap; ++i) put_char(cc[i]);
		}

		public override void finish(uint top, Gedb.Type* t) {}

		public override void put_bool(bool b) {}
		public override void put_char(char c) {}
		public override void put_char32(uint32 c) {}
		public override void put_int8(int8 i) {}
		public override void put_int16(int16 i) {}
		public override void put_int32(int32 i) {}
		public override void put_int64(int64 i) {}
		public override void put_nat8(uint8 n) {}
		public override void put_nat16(uint16 n) {}
		public override void put_nat32(uint32 n) {}
		public override void put_nat64(uint64 n) {}
		public override void put_real(float r) {}
		public override void put_double(double d) {}
		public override void put_pointer(void* p) {}
		public override void put_scope_var(bool ot) {}
		public override void put_known_ident(uint id, Gedb.Type* t) {}
		public override void put_void_ident(Gedb.Type* t) {}

		public override void put_int32s(uint id, int32[] ii, uint cap,
										   SpecialType* st) {
			for (uint i=0; i<cap; ++i) put_int32(ii[i]);
		}

		public override void put_doubles(uint id, double[] dd, uint cap,
										   SpecialType* st) {
			for (uint i=0; i<cap; ++i) put_double(dd[i]);
		}

		protected void next_ident() {
			++max_ident;
			last_ident = max_ident;
		}

		protected uint max_ident;

	} /* class NullTarget */

	public class StreamTarget : NullTarget {

		public StreamTarget(string path, System* s, bool append=false) {
			file = FileStream.open(path, append ? "a" : "w");
			system = s;
		}

		public size_t pos { get; protected set; }

		public System* system { get; protected set; }
		protected FileStream file;

		public override void post_object(Gedb.Type* t, bool as_ref, uint id) {
			file.flush();
		}
		
		public override void post_agent(AgentType* t, uint id) { 
			file.flush();
		}
		
		public override void post_special(SpecialType* st, uint id) {
			file.flush();
		}
		
		public override void finish(uint top, Gedb.Type* t) {
			put_known_ident(top, t);
			top_ident = top;
			file.flush();
		}

		public override void put_new_object(Gedb.Type* t) {
			next_ident();
			write_int((int)last_ident);
			write_int((int)t.ident);
		}

		public override void put_new_special(SpecialType* st, uint cap) {
			next_ident();
			write_int((int)last_ident);
			write_int((int)((Gedb.Type*)st).ident);
			write_int((int)cap);
		}

		public override void set_once(Once* o, bool init) {
			put_bool(init);
		}

		public override void put_bool(bool b) {
			file.putc(b ? 1 : 0);
			++pos;
		}

		public override void put_char(char c) {
			file.putc(c);
			++pos;
		}

		public override void put_char32(uint32 c) {
			write_int((int)c);
		}

		public override void put_int8(int8 i) {
			file.putc((char)i);
			++pos;
		}
		
		public override void put_int16(int16 i) {
			file.putc((char)(i & 0xff));
			file.putc((char)(i >> 8));
			pos += 2;
		}

		public override void put_int32(int32 i) {
			write_int(i);
		}

		public override void put_int64(int64 i) {
			write_long(i);
		}

		public override void put_nat8(uint8 n) {
			file.putc((char)n);
			++pos;
		}
		
		public override void put_nat16(uint16 n) {
			file.putc((char)(n & 0xff));
			file.putc((char)(n >> 8));
			pos += 2;
		}

		public override void put_nat32(uint32 n) {
			write_int((int)n);
		}

		public override void put_nat64(uint64 n) {
			write_long((int64)n);
		}

		public override void put_real(float r) {
			void* addr = &r;
			write_int(*(int*)addr);
		}

		public override void put_double(double d) {
			void* addr = &d;
			write_long(*(int64*)addr);
		}

		public override void put_pointer(void* p) {
			write_long(*(int64*)p);
		}

		public override void put_known_ident(uint id, Gedb.Type* t) {
			write_int((int)id);
		}

		public override void put_void_ident(Gedb.Type* t) { 
			write_int(0); 
		}

		public override void put_scope_var(bool ot) {
			put_bool(ot);
		}
		
		protected void write_int(int32 i) {
			uint8 buf[4];
			*(int32*)buf = i;
			pos += file.write(buf);
		}

		protected void write_long(int64 i) {
			uint8 buf[8];
			*(int64*)buf = i;
			pos += file.write(buf);
		}

	} /* class StreamTarget */

	public class MemoryTarget : Target<void*> {

		public MemoryTarget(System* s, void*[] oo) {
			system = s;
			objects = oo;
			offsets = new OffsetStack();
		}

		public void* top_object { get; protected set; }

		public override void pre_object(Gedb.Type* t, bool as_ref, void* id) {
			if (as_ref) offsets.push_offset(id);
			else  offsets.push_expanded_offset();
		}

		public override void post_object(Gedb.Type* t, bool as_ref, void* id) {
			offsets.pop_offset();
		}

		public override void pre_agent(AgentType* at, void* id) {
			void* obj = *(void**)at.closed_operands((uint8*)id);
			offsets.push_offset(obj);
			put_new_object((Gedb.Type*)at.closed_operands_tuple);
		}

		public override void post_agent(AgentType* at, void* id) {
			offsets.pop_offset();
		}

		public override void pre_special(SpecialType* st, uint cap, void* id) {
			offsets.push_offset(id);
		}

		public override void post_special(SpecialType* st, void* id) {
			offsets.pop_offset();
		} 

		public override void finish(void* top, Gedb.Type* t) {
			top_object = top;
		}
		
		public override void put_bool(bool b) { 
			*(bool*)offsets.home_address() = b;
		}
		
		public override void put_char(char c) {
			*(char*)offsets.home_address() = c;
		}
		
		public override void put_char32(uint32 c) {
			*(uint32*)offsets.home_address() = c;
		}
		
		public override void put_int8(int8 i) {
			*(int8*)offsets.home_address() = i;
		}
		
		public override void put_int16(int16 i) {
			*(int16*)offsets.home_address() = i;
		}
		
		public override void put_int32(int32 i) {
			*(int32*)offsets.home_address() = i;
		}
		
		public override void put_int64(int64 i) {
			*(int64*)offsets.home_address() = i;
		}
		
		public override void put_nat8(uint8 n) {
			*(uint8*)offsets.home_address() = n;
		}
		
		public override void put_nat16(uint16 n) {
			*(uint16*)offsets.home_address() = n;
		}
		
		public override void put_nat32(uint32 n) {
			*(uint32*)offsets.home_address() = n;
		}
		
		public override void put_nat64(uint64 n) {
			*(uint64*)offsets.home_address() = n;
		}
		
		public override void put_real(float r) {
			*(float*)offsets.home_address() = r;
		}
		
		public override void put_double(double d) {
			*(double*)offsets.home_address() = d;
		}
		
		public override void put_pointer(void* p) {}
		
		public override void put_known_ident(void* id, Gedb.Type* t) {
			put_object(id, null);
		}
		
		public override void put_void_ident(Gedb.Type* t) {
			put_object(null, null);
		}

		public override void put_new_object(Gedb.Type* t) {
			++object_index;
			last_ident = objects[object_index];
			put_object(last_ident, t);
		}

		public override void put_new_special(SpecialType* st, uint cap) {
			++object_index;
			last_ident = objects[object_index];
			put_object(last_ident, (Gedb.Type*)st);
		}

		public override void put_scope_var(bool ot) {} 

		public override void put_chars(void* id, char[] cc, uint cap,
			SpecialType* st) {
			unowned char[] ca = (char[])st.base_address(id);
			ca = cc;
		}
		
		public override void put_int32s(void* id, int32[] ii, uint cap, 
			SpecialType* st) {
			unowned int32[] ia = (int32[])st.base_address(id);
			ia = ii;
		}

		public override void put_doubles(void* id, double[] dd, uint cap, 
			SpecialType* st) {
			unowned double[] da = (double[])st.base_address(id);
			da = dd;
		}

		public override void set_local(Local* l, StackFrame* f) {
			field = (Entity*)l; 
			offsets = new OffsetStack();
			offsets.push_offset(f);
			offsets.set_field_offset(field);
		}

		public override void set_field(Field* f, void* in_id) { 
			field = (Entity*)f; 
			offsets.set_field_offset(field);
		}

		public override void set_index(SpecialType* st, uint i, void* in_id) {
			field = (Entity*)st.item_0();
			field_increment = st.item_type().field_bytes();
			offsets.set_indexed_offset(st, i);
		}

		public override void set_once(Once* o, bool init) {
			if (init) {
				if (((Routine*)o).is_function()) {
					field = (Entity*)o; 
					offsets = new OffsetStack();
					offsets.push_offset(o.value_address);
				}
				o.re_initialize();
			} else {
				o.refresh();
			}
		}

		protected void put_object(void* id, Gedb.Type* t) {
			void* addr = offsets.home_address();
			*(void**)addr = id;
		}

		protected System* system;
		protected OffsetStack offsets;
		protected unowned void*[] objects;
		protected uint object_index;
		protected uint field_increment;

	} /* class MemoryTarget */
	
public class Context<I> {

		public I ident;
		public uint cap;
		public Gedb.Type* type;

		public void to_reread(I id, Gedb.Type* t, uint cap) {
			top = id;
			type = t;
			this.cap = cap;
		}

		public void reread() { top = null; }
		public bool is_reread(I id) { return id==top; }

		public void next_ident() { ident = top; }

		protected I top;

	} /* class Context */

	public class OffsetStack {

		public OffsetStack() {
			address_stack = new Gee.ArrayList<void*>();
			offset_stack = new Gee.ArrayList<int>();
		}

		public int offset { get; protected set; }

		public void set_field_offset(Entity* e) {
			int off = e.is_field() ? ((Field*)e).offset : ((Local*)e).offset;
			offset = offset_sum + off;
		}

		public void set_indexed_offset(SpecialType* st, uint i) {
			offset = st.item_offset(i);
		}

		public void push_offset(void* obj) {
			offset_stack.@add(offset_sum);
			offset_sum = 0;
			address_stack.@add(address);
			address = obj;
		}

		public void push_expanded_offset() {
			offset_stack.@add(offset_sum);
			offset_sum = offset;
			address_stack.@add(address);
		}

		public void pop_offset() {
			int n = offset_stack.size;
			offset = offset_sum;
			offset_sum = offset_stack.last();
			offset_stack.remove_at(n-1);
			address = address_stack.last();
			address_stack.remove_at(n-1);
		}

		public void* actual_object(Gedb.Type* t) {
			void* obj=null;
			if (address!=null && t!=null) {
				obj = ((uint8*)address)+offset;
				obj = t.dereference(obj);
			}
			return obj;
		}

		public void* home_address() {
			return address!=null ? ((uint8*)address)+offset : null;
		}

		public int depth() { return offset_stack.size; }

		protected Gee.ArrayList<void*> address_stack;
		protected Gee.ArrayList<int> offset_stack;
		protected int offset_sum;
		protected uint8* address;

	} /* class OffsetStack */

} /* namespace */
