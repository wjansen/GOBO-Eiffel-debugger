/**
   author: "Wolfgang Jansen"
   date: "$Date$"
   revision: "$Revision$"
**/

namespace Gedb {

	public enum TypeIdent {
		BOOLEAN = 1,
		CHARACTER_8,
		CHARACTER_32,
		INTEGER_8,
		INTEGER_16,
		INTEGER_32,
		INTEGER_64,
		NATURAL_8,
		NATURAL_16,
		NATURAL_32,
		NATURAL_64,
		REAL_32,
		REAL_64,
		POINTER,
		MAX_BASIC = 14,
		STRING_8 = 17,
		STRING_32 = 18,
		ANY = 19,
		NONE = 20,
		NAME,
		TYPE,
		NORMAL_TYPE,
		EXPANDED_TYPE,
		SPECIAL_TYPE,
		TUPLE_TYPE,
		AGENT_TYPE,
		CLASS_TEXT,
		FEATURE_TEXT,
		ROUTINE_TEXT,
		ENTITY,
		CONSTANT,
		FIELD,
		LOCAL,
		ROUTINE,
		SCOPE_VARIABLE,
		ONCE,
 		SYSTEM
	}

	public enum SystemFlag {
		FOREIGN = 0x08,
		SCOOP = 0x10,
		NO_GC = 0x20
	}

	public enum ClassFlag {
		SUBOBJECT = 1,
		REFERENCE = 2,
		PROXY = 3,
		FLEXIBLE = 4,
		MEMORY_CATEGORY = 7,
		BASIC_EXPANDED = 0x9,
		BITS = 0x11,
		TUPLE = 0x10,
		AGENT = 0x20,
		ANONYMOUS = 0x30,
		TYPE_CATEGORY = 0x3f,
		ACTIONABLE = 0x40,
		INVARIANT = 0x80,
		DEBUGGER = 0x100,
	}

	public enum TypeFlag {
		SUBOBJECT = 1,
		REFERENCE = 2,
		PROXY = 3,
		FLEXIBLE = 4,
		MEMORY_CATEGORY = 7,
		BASIC_EXPANDED = 0x9,
		BITS = 0x11,
		TUPLE = 0x10,
		AGENT = 0x20,
		ANONYMOUS = 0x30,
		TYPE_CATEGORY = 0x3f,
		ATTACHED = 0x40,
		COPY_SEMANTICS = 0x200,
		MISSING_ID = 0x800,
		AGENT_EXPRESSION = 0x1000,
		META_TYPE = 0x2000
	}

	public enum RoutineFlag {
		DO = 0,
		EXTERNAL = 1,
		ONCE = 2,
		DEFERRED = 3,
		IMPLEMENTATION = 3,
		FUNCTION = 4,
		OPERATOR = 0xC,
		BRACKET = 0x14,
		CREATION = 0x20,
		DEFAULT_CREATION = 0x60,
		INVARIANT = 0x80,
		PRECURSOR = 0x100,
		RESCUE = 0x200,
		NO_CURRENT = 0x400,
		ANONYMOUS_ROUTINE = 0x800,
		INLINED = 0x1000,
		FROZEN = 0x2000,
		SIDE_EFFECT = 0x4000,
		ROUTINE = 0x8000
	}

/* ---------------------------------------------------------------------- */
	
	public void add<N> (N[] list, N d) {
		list.resize(list.length+1);
		list[list.length++] = d;
	}
	
	public void clean<N> (N[] list) {
		N di, dk;
		uint i, k;
		if (list.length<=1) return;
		for (k=list.length-1, dk=list[k]; k>0;) {
			di = dk;
			--k;
			dk = list[k];
			if (dk==di) {
				--list.length;
				for (i=k; i==list.length; ++i) list[i] = list[i+1];
			}
		}
	}
	
	public void sort<N> (N[] list, LessFunc<N> comp) {
			N d, d1, temp;
			uint parent, child, child_1, i, n;
			for (n=list.length, i=n%2; n>0;) {
				if (i>0) {
					--i;
					temp = list[i];
				} else {
					--n;
					temp = list[n];
					if (n>0) 
						list[n] = list[0];
				}
				if (n>0) {
					for (parent=i, child=i*2+1; child<n;) {
						d = list[child];
						child_1 = child+1;
						if (child_1<n) {
							d1 = list[child_1];
							if (comp(d, d1)) {
								child = child_1;
								d = d1;
							}
						}
						if (comp(temp, d)) {
							list[parent] = d;
							parent = child;
							child = parent*2 + 1;
						} else {
							child = n;
						}
					}
					list[parent] = temp;
				}
			}
		}
				
	public delegate bool LessFunc<N>(N u, N v);

	public uint position_as_integer(uint l, uint c) { return 256*l+c; }
	public uint line_of_position(uint p) { return p/256; }
	public uint column_of_position(uint p) { return p%256; }

/* ---------------------------------------------------------------------- */

	internal Name* query_from_list(string name, Name*[] list, out uint n) {
		Name* best=null;
		int l0, l=int.MAX, count=0;
		foreach (var x in list) {
			if (x.has_name(name)) {
				n = 1;
				return x;
			} else if (x.has_prefix(name)) {
				l0 = x.fast_name.length;
				if (l0<l) {
					l = l0;
					best = x;
					count = 1;
				} else {
					++count;
				}
				++n;
			}
		}
		return count>1 ? null : best;
	}
	
/**
   Name component of internal descriptors.
**/
	public struct Name {
		
/**
   @return Name for comparisons.
**/
		public int _id;

		public string fast_name;

/**
   @return Is `to_string()' equal to `s' when ignoring letter case?
**/
		public bool has_name(string name) {
			return fast_name.ascii_casecmp(name)==0;
		}
		
/**
   @return Does `to_string()' start with `pre' when ignoring letter case?
**/
		public bool has_prefix(string pre) {
			return pre.length <= fast_name.length
				&& fast_name.ascii_ncasecmp(pre, pre.length)==0;
		}
		
/**  
	 @return Printable format of `this'.
**/
		public string to_string() { return fast_name; }
		
		/**
		   @return  `name' apended to `to'.
		**/	
		public string append_name(string to) { return to + fast_name; }
		
		public string append_indented_name(string to, int indent) {
			string s = string.nfill(indent, ' ');
			return s + append_name(to);
		}
/**
   Append `to_string' to `to' and as many blanks as needed
   to append totally at least `n' characters.
**/
		public string pad_right(string to, uint n) {
			string s = append_name(to);
			int l = s.length - to.length;
			if (l>0) s += string.nfill(l, ' ');	
			return s;
		}

/**
   Append `to_string' to `to' and insert before that
   as many blanks as needed to append totally
   at least `n' characters.
 **/
		public string pad_left(string to, uint n) {
			string s = append_name(to);
			int l = s.length - to.length;
			if (l>0) s = string.nfill(l, ' ') + s; 
			return s;			
		}

		public bool is_less(Name? other) {
 			return fast_name.ascii_casecmp(other.fast_name)<0;
		}
		
		public bool is_system() { return _id==TypeIdent.SYSTEM; }
		public bool is_entity() { return _id==TypeIdent.ENTITY; }
		public bool is_field() { return _id==TypeIdent.FIELD; }
		public bool is_local() { return _id==TypeIdent.LOCAL; }
		public bool is_scope_var() { return _id==TypeIdent.SCOPE_VARIABLE; }
		public bool is_routine() { return _id==TypeIdent.ROUTINE; }
		public bool is_once() { return _id==TypeIdent.ONCE; }
		public bool is_constant() { return _id==TypeIdent.CONSTANT; }
		public bool is_class_text() { return _id==TypeIdent.CLASS_TEXT; }
		public bool is_feature_text() { return _id==TypeIdent.FEATURE_TEXT; }
		public bool is_routine_text() { return _id==TypeIdent.ROUTINE_TEXT; }
		public bool is_type() { return _id==TypeIdent.TYPE; }
		public bool is_normal_type() { return _id==TypeIdent.NORMAL_TYPE; }
		public bool is_expanded_type() { return _id==TypeIdent.EXPANDED_TYPE; }
		public bool is_special_type() { return _id==TypeIdent.SPECIAL_TYPE; }
		public bool is_tuple_type() { return _id==TypeIdent.TUPLE_TYPE; }
		public bool is_agent_type() { return _id==TypeIdent.AGENT_TYPE; }

	} /* struct Name */

/* ---------------------------------------------------------------------- */

	public struct Offsets { int area; int item; }

/**
   Descriptor of an Eiffel system.
**/
	public struct System {

		public Name _name;

		public int flags;

		public AgentType*[] all_agents;
		public Type*[] all_types;
		public ClassText*[] all_classes;
		public Constant*[] all_constants;
		public Once*[] all_onces;
		
/**
   @return Does the system support garbage collection?
**/
		public bool has_gc() { 
			return (flags & SystemFlag.NO_GC) == 0; 
		}

		public bool is_scoop() {
			return (flags & SystemFlag.SCOOP) == 0; 
		}

		public bool is_debugging() {
			return (flags & ClassFlag.DEBUGGER) == 0; 
		}

		public int assertion_check;

/**
   @return Number of classes in the system.
**/
		public uint class_count() { 
			return all_classes==null ? 0 : all_classes.length; 
		}

/**
   @return `i'-th class of the system.
**/
		public ClassText* class_at(uint i) { return all_classes[i]; }
/**
   @return Number of types in the system.
**/
		public uint type_count() { 
			return all_types==null ? 0 : all_types.length; 
		}

/**
   @return `i'-th type of the system.
**/
		public Type* type_at(uint i) { return all_types[i]; }
/**
   @return Number of agentes in the system.
**/
		public uint agent_count() { 
			return all_agents==null ? 0 : all_agents.length; 
		}

/**
   @return `i'-th agent of the system.
**/
		public AgentType* agent_at(uint i) {
			return all_agents[i];
		}

/**
   @return Number of onces in the system.
**/
		public uint once_count() { 
			return all_onces==null ? 0 : all_onces.length; 
		}

/**
   @return `i'-th once of the system.
**/
		public Once* once_at(uint i) {
			return all_onces[i];
		}

/**
   @return Number of constants in the system.
**/
		public uint constant_count() { 
			return all_constants==null ? 0 : all_constants.length; 
		}

/**
   @return `i'-th constant of the system.
**/
		public Constant* constant_at(uint i) {
			return all_constants[i];
		}

/**
   Routine creating the root object.
 **/
		public Routine* root_creation_procedure;

/**
   Type of root object. 
 **/
		public NormalType* root_type;

/**
   Maximum instance size of all types in `all_types'.
 **/
		public uint max_bytes;
/**
   CUT time when the system has been Eiffel compiled. 
**/
		public uint64 compilation_time;

/**
   CUT time when the system has been created. 
**/
		public uint64 creation_time;

/**
   Compiler name and version.
 **/
		public string compiler;

/**
   The unique Type implementing `ct'.
 **/
		public Type* as_type(ClassText* ct) requires (ct.is_basic()) {
			switch (((Name*)ct).fast_name) {
			case "BOOLEAN":
				return type_at(TypeIdent.BOOLEAN);
			case "CHARACTER_8":
				return type_at(TypeIdent.CHARACTER_8);
			case "CHARACTER_32":
				return type_at(TypeIdent.CHARACTER_32);
			case "INTEGER_8":
				return type_at(TypeIdent.INTEGER_8);
			case "INTEGER_16":
				return type_at(TypeIdent.INTEGER_16);
			case "INTEGER_32":
				return type_at(TypeIdent.INTEGER_32);
			case "INTEGER_64":
				return type_at(TypeIdent.INTEGER_64);
			case "NATURAL_8":
				return type_at(TypeIdent.NATURAL_8);
			case "NATURAL_16":
				return type_at(TypeIdent.NATURAL_16);
			case "NATURAL_32":
				return type_at(TypeIdent.NATURAL_32);
			case "NATURAL_64":
				return type_at(TypeIdent.NATURAL_64);
			case "REAL_32":
				return type_at(TypeIdent.REAL_32);
			case "REAL_64":
				return type_at(TypeIdent.REAL_64);
			case "POINTER":
				return type_at(TypeIdent.POINTER);
			}
			return null;
		}

/**
   @return Descriptor of the class of name `nm';
   `null' if no class has this name.
 **/
		public ClassText* class_by_name (string name) {
			var list = new Name*[0];
			string nm = name.up();
			ClassText* c;
			uint n;
			switch (nm) {
			case "CHARACTER":
				nm = "CHARACTER_8";
				break;
			case "INTEGER":
				nm = "INTEGER_32";
				break;
			case "NATURAL":
				nm = "NATURAL_32";
				break;
			case "REAL":
				nm = "REAL_32";
				break;
			case "DOUBLE":
				nm = "REAL_64";
				break;
			case "STRING":
				nm = "STRING_8";
				break;
			}
			for (uint i=class_count(); i-->0;) {
				c = class_at(i); 
				if (c!=null) list += (Name*)c;
			}
			var res = query_from_list(nm.up(), list, out n);
			return (res!=null && res.is_class_text()) ? (ClassText*) res : null;
		}
		
		public static void push_type(System* s, uint id) {
			Type* t=s.all_types[id];
			if (t!=null) {
				uint i = s.type_stack_count;
				uint n = s.type_stack.length;
				if (i>=n) {
					n = i==0 ? 4 : 2*i;
					if (n==0) s.type_stack = new Type*[n+1];
					else  s.type_stack.resize((int)n);
				}
				s.type_stack[i] = t;
				++s.type_stack_count;
			}
		}
		
		public static Type* top_type(System* s) { 
			return s.type_stack[s.type_stack_count-1]; 
		}

		public static Type* below_top_type(System*s, uint n) {
			return s.type_stack[s.type_stack_count-1-n];
		} 
		
/**
   Pop `n' types from the `type_stack'.
**/
		public static void pop_types(System* s, uint n) {
			if (n>0) s.type_stack_count -= n;
		}

		public Type* basic_type(uint id) {
			Type* t = null;
			switch (id) {
			case TypeIdent.BOOLEAN:
				t = all_types[1];
				break;
			case TypeIdent.CHARACTER_8:
				t = all_types[2];
				break;
			case TypeIdent.CHARACTER_32:
				t = all_types[3];
				break;
			case TypeIdent.INTEGER_8:
				t = all_types[4];
				break;
			case TypeIdent.INTEGER_16:
				t = all_types[5];
				break;
			case TypeIdent.INTEGER_32:
				t = all_types[6];
				break;
			case TypeIdent.INTEGER_64:
				t = all_types[7];
				break;
			case TypeIdent.NATURAL_8:
				t = all_types[8];
				break;
			case TypeIdent.NATURAL_16:
				t = all_types[9];
				break;
			case TypeIdent.NATURAL_32:
				t = all_types[10];
				break;
			case TypeIdent.NATURAL_64:
				t = all_types[11];
				break;
			case TypeIdent.REAL_32:
				t = all_types[13];
				break;
			case TypeIdent.REAL_64:
				t = all_types[13];
				break;
			case TypeIdent.POINTER:
				t = all_types[14];
				break;
			case TypeIdent.STRING_8:
				t = all_types[17];
				break;
			case TypeIdent.STRING_32:
				t = all_types[18];
				break;
			default:
				t = all_types[19];
				break;
			}
			return t;
		}
/**
   @return 	
   Descriptor of the type with base class name `nm'
   and actual generic `gc' parameters (pushed by `push_type').
   `Void' if no such type exists.
 **/	
		public Type* type_by_class_and_generics(string nm, uint gc, bool attac) {
			Type* t, g, u, result=null;
			uint penalty=0, p, m=uint.MAX;
			uint j, l, n;
			for (n=type_count(); n-->0;) { 
				t = all_types[n];
 				if (t==null || t.is_agent()) continue;
				if (t.generic_count()==gc && t.class_name==nm) {
					penalty = t.is_attached() != attac ? 0 : 1;
				} else {
					penalty = uint.MAX;
					continue;
				}
				for (l=gc, j=0; l-->0; ++j) {
					g = t.generic_at(j);
					u = type_stack[type_stack_count-l-1];
					p = g==u ? 0 : (g.does_effect(u) ? 2 : uint.MAX);
					if (p < uint.MAX-penalty) {
						penalty += p;
					} else {
						penalty = uint.MAX;
						t = null;
						break;
					}
				}
				if (t!=null && penalty<m) {
					result = t;
					m = penalty;
				}
				if (m==0) break;
			}
			return result;
		}
		
/**
   @return 
   Descriptor of a tuple type that matches best the
   actual generic `gc' parameters (pushed by `push_type').
   
**/
		public TupleType* tuple_type_by_generics(uint gc, bool attac) {
			Type* t, g, s, result=null;
			uint penalty=0, p, m=uint.MAX;
			uint i, k, l, n;
			for (n=type_count(); m>0 && n-->0; ) {
				t = type_at(n);
				if (t!=null && t.is_tuple()) {
					penalty = 0;
					k = t.generic_count();
					if (k>gc) {
						t = null;
					} else {
						penalty += gc - k;
						for (l=gc-1, i=0; t!=null && i<k; --l, ++i) {
							g = t.generic_at(i);
							s = type_stack[type_stack_count-l-1];
							p = g==s ? 0 : (g.does_effect(s) ? 2 : uint.MAX);
							if (p < uint.MAX-penalty) {
								penalty += p;
							} else {
								penalty = uint.MAX;
								t = null;
							}
						}
					}
					if (t!=null && penalty<m) {
						result = t;
						m = penalty;
					}
				}
			}
			return (TupleType*)result;
		}

/**
   @return Descriptor of the SPECIAL type of `it' items.
**/
		public SpecialType* special_type_by_item_type (Type* it, bool attac) {
			push_type(&this, it.ident);
			Type* t = type_by_class_and_generics ("SPECIAL", 1, attac);
			pop_types(&this, 1);
			return (SpecialType*)t;
		}

/**
   @base base type wanted
   @ocp open-closed-pattern wanted
   @nm routine name wanted
   @return Agent of specific settings.
 **/
		public AgentType* agent_by_base_and_routine(Type* bt, string ocp, string nm) {
			AgentType* result;
			for (uint i=type_count(); i-->0;) {
				result = (AgentType*)type_at(i);
				if (result!=null && bt==result.base_type 
					&& ocp==result.open_closed_pattern 
					&& result.routine!=null 
					&& result.routine._entity.has_name(nm)) {
					return result;
				}
			}
			return null;
		}

/**
   @return Type of specific settings.
   @type_name wanted name
 **/
		public Type* type_by_name(string type_name, bool attac=false) {
			var name = type_name.strip();
			return type_by_subname (ref name, attac);
		}

/**
   @return Once call of specific settings.
   @nm wanted function name
   @cls wanted defining class
 **/
		public Entity* global_by_name_and_class(string nm, ClassText* cls,
												bool as_function, bool init,
												out uint n=null) {
			Name*[] list = new Name*[0];
			Once* o;
			for (uint i=once_count(); i-->0;) {
				o = once_at(i);
				if (o!=null && (!init || o.is_initialized()) 
					&& (!as_function || o._routine.is_function()) 
					&& cls.is_descendant(o.home))
					list += (Name*)o;
			}
			Constant* c;
			for (uint i=constant_count(); i-->0;) {
				c = constant_at(i);
				if (cls.is_descendant(c.home))
					list += (Name*)c;
			}
			var e = query_from_list(nm.down(), list, out n);
			if (e==null) return null;
			return (e.is_once() || e.is_constant()) ? (Entity*)e : null;
		}
		
		public uint object_type_id(uint8* addr, bool is_home_addr, Type* stat) {
			NormalType* dt;
			AgentType* ag;
			uint8* faddr;
			uint i, flags, tid;
			if (addr==null) return TypeIdent.NONE;
			flags = stat.flags;
			if ((flags & TypeFlag.MEMORY_CATEGORY)!=0
				&& (flags & TypeFlag.REFERENCE)==0) return stat.ident;
			if (is_home_addr && addr!=null) addr = *(void**)addr;
			if (addr==null) return TypeIdent.NONE;
			tid = *(uint*)addr;
			if ((flags & TypeFlag.AGENT_EXPRESSION)==0 
				&& (flags & TypeFlag.AGENT)==0) return tid;
			for (i=all_agents.length; i-->0;) {
				ag = all_agents[i];
				if (ag==null) continue;
				dt = ag.declared_type;
                if (dt._type.ident!=tid) continue;
                faddr = addr+ag.function_offset;
                if (ag.call_function!=*(void**)faddr) continue;
                return ag._type.ident;
			}
			return tid;
		}
		
/**
   @return String format listing all types.
   @s: string to be extended
 **/
		public string append_name(string to) {
			Type* t;
			string s=to;
			uint i, n;
			for (i=0, n=type_count(); i<n; ++i) {
				t = type_at(i);
				if (t!=null) {
					s += "%d %s\n".printf((int)i, t._name.to_string());
				}
			}
			return s;
		}
				
/**
   @return String format listing all types in alphabetic order.
   @s string to be extended
**/
		public string append_alphabetically (string to) {
			Type* t;
			uint i, n=type_count();
			Type*[] list = {};
			for (i=n; i-->0;) {
				t = type_at(i);
				if (t!=null) add(list, t);
			}
 			sort<Type*>(list, (LessFunc)Type.is_name_less);
			clean<Type*>(list); 
			string s=to;
			for (; i<n; ++i) {
				t = list[i];
				s += "%d %s\n".printf((int)i, t._name.to_string());
			}
			return s;
		}

		public Type*[] type_stack;
		public uint type_stack_count;

/**
   @return 
   Descriptor of the type whose name is the leading portion of `nm'.
   `null' if no type has this name.
   Caution: the function has a side-effect: it consumes `nm'.
 **/
		public Type* type_by_subname(ref string nm, bool attac) {
			ClassText* cls;
			Type* g, result=null;
			string cls_name, str;
			uint gc=0;
			int ll = nm.index_of_char('[');
			int lr = nm.index_of_char(']');
			int lc = nm.index_of_char(',');
			int l = ll;
			if (l<0 || (lr>=0 && lr<l)) l = lr;
			if (l<0 || (lc>=0 && lc<l)) l = lc;
			cls_name = l<0 ? nm : nm.substring(0, l);
			cls = class_by_name(cls_name.strip().up());
			str = l<0 ? nm.strip() : nm.substring(l);
			nm = str;
			if (cls!=null) {
				if (l>=0 && l==ll) {
					while (true) {
						str = nm.substring(1).strip();
						nm = str;
						g = type_by_subname(ref nm, false);
						if (g!=null) {
							push_type(&this, g.ident);
							++gc;
						} else {
							break;
						}
						if (nm[0]==']') break;
					}
					str = nm.substring(1).strip();
					nm = str;
				}
				result = type_by_class_and_generics(cls_name, gc, attac);
				pop_types(&this, gc);
			}
			return result;
		}

		public Type* type_of_any (void* a, Type* stat=null) {
			if (stat!=null && stat.is_subobject()) return stat;
			if (a==null) return all_types[TypeIdent.NONE];
			Type* t = type_at(c_ident(a));
			if (t!=null && (t.flags & TypeFlag.AGENT_EXPRESSION) > 0) {
				var at = (Type*)as_agent(a);
				if (at!=null) return at;
			} 
			return t;
		}

/**
   @return "Cast type of `any' to an AgentType.
 **/
		internal AgentType* as_agent(uint8* a) {
			AgentType* at=null;
			uint8* addr;
			if (a==null) return null;
			uint did = c_ident(a);
			for (uint i=agent_count(); at==null && i-->0;) {
				at = agent_at(i);
				if (at!=null) {
					addr = a + at.function_offset;
					if (addr!=null && at.declared_type._type.ident!=did 
						|| at.call_function!=*(void**)addr)	
					at = null;
				}
			}
			return at;
		}

		public static Offsets string_offsets;
		public static Offsets unicode_offsets;
		
	} /* struct System */
	
/* ---------------------------------------------------------------------- */

/**
   Internal description of entities of an Eiffel class.
**/

	public struct Entity {

		public Name _name;

/**
   Type of the entity, `null' if `this' describes a procedure.
 **/
		public Type* type;

/**
   Caller's type of the entity, `null' if `this' describes a once routine.
 **/
		public Type* target;

/**
   Dynamic types of the entity. 
**/
		public Type*[] type_set;

/**
   The corresponding feature in class text. 
 **/
		public FeatureText* text;
	
/**
   Alias name of the entity (if any). 
 **/
		public string? alias_name;

/**
   @return Compare `alias_name's if not void.
**/
		public bool is_less(Entity* other) {
			string s = alias_name!=null ? alias_name : _name.fast_name;
			string o = other.alias_name!=null ? 
				other.alias_name : other._name.fast_name;
			return s.ascii_casecmp(o)<0;
		}

/**
   @return Is `to_string()' equal to `s' when ignoring letter case?
**/
		public bool has_name (string name) { 
			return _name.fast_name.ascii_casecmp(name)==0 || alias_name==name;
		}
		
/**
   @return Does `to_string()' start with `pre' when ignoring letter case?
**/
		public bool has_prefix(string pre) {
			string s = _name.fast_name;
			int l = pre.length;
			return (l<=s.length && s.ascii_ncasecmp(pre, l)==0) 
				|| alias_name==pre;
		}
		
/**  
	 @return Printable format of `this'.
**/
		public string to_string() { return append_name(""); }
		
		/**
		   @return  `name' apended to `to'.
		**/	
		public string append_name(string to) {
			if (alias_name!=null) 
				return to+alias_name;
			return _name.append_name(to);
		}

		public bool is_field() { return _name._id==TypeIdent.FIELD; }
		public bool is_local() { 
			return _name._id==TypeIdent.LOCAL || is_scope_var(); 
		}
		public bool is_scope_var() { return _name._id==TypeIdent.SCOPE_VARIABLE;}
		public bool is_routine() { return _name._id==TypeIdent.ROUTINE; }
		public bool is_once() { return _name._id==TypeIdent.ONCE; }
		public bool is_constant() { return _name._id==TypeIdent.CONSTANT; }
		
		public bool is_assignable_from(Gedb.Type* rhs) {
			if (type==null || rhs==null) return false;
			if (type.ident==rhs.ident) return true;
			switch (rhs.ident) {
			case TypeIdent.BOOLEAN:
				return type.ident == TypeIdent.BOOLEAN;
			case TypeIdent.CHARACTER_32:
			case TypeIdent.CHARACTER_8:
				return type.ident == TypeIdent.CHARACTER_8
					|| type.ident == TypeIdent.CHARACTER_32; 
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				switch (type.ident) {
				case TypeIdent.INTEGER_8:
				case TypeIdent.INTEGER_16:
				case TypeIdent.INTEGER_32:
				case TypeIdent.INTEGER_64:
				case TypeIdent.NATURAL_8:
				case TypeIdent.NATURAL_16:
				case TypeIdent.NATURAL_32:
				case TypeIdent.REAL_32:
				case TypeIdent.REAL_64:
					return true;
				}
				break;
			case TypeIdent.REAL_32:
			case TypeIdent.REAL_64:
				switch (type.ident) {
				case TypeIdent.REAL_32:
				case TypeIdent.REAL_64:
					return true;
				}
				break;
			case TypeIdent.POINTER:
				return type.ident == TypeIdent.POINTER
					|| rhs.ident >= TypeIdent.ANY;
			default:
				for (int i=type_set.length; i-->0;) {
					if (type_set[i]==rhs) return true;
				}
				break;
			}	
			return false;
		}
		
	} /* struct Entity */

/* ---------------------------------------------------------------------- */

/**
   Internal description of attributes of a type. 
 **/
	public struct Field {

		public Entity _entity;

/**
   Relative location within an object or a stack frame. 
 **/
		public int offset;

	} /* struct Field */

/* ---------------------------------------------------------------------- */

/**
   Internal description of local variables of a routine. 
 **/
	public struct Local {

		public Entity _entity;

/**
   Relative location within an object or a stack frame. 
 **/
		public int offset;

		public bool is_scope_var() { 
			return _entity._name._id==TypeIdent.SCOPE_VARIABLE;
		}

	} /* struct Local */

/* ---------------------------------------------------------------------- */

/**
   Internal description of object test locals of a routine. 
 **/
	public struct ScopeVariable {

		public Local _local;

		public bool is_object_test;

		private int lower_scope_limit;
		private int upper_scope_limit;

/**
   @return Is position `line,col' in `Currents''s scope?
 **/
		public bool in_scope(uint line, uint col) {
			uint p = 256*line + col;
			return (lower_scope_limit<=p) && (p<=upper_scope_limit);
		}

		public void set_lower_scope_limit(int l) { lower_scope_limit=l; }
		public void set_upper_scope_limit(int l) { upper_scope_limit=l; }

	} /* struct ScopeVariable */

/* ---------------------------------------------------------------------- */

/**
   Internal description of a routine. 
 **/
	public struct Routine {

		public Entity _entity;

		public uint flags;

/**
   Defining class. 
 **/
		public Gedb.Type* target;

/**
   If `this' is routine of an inline agent 
   then the defining agent; `null' else. 
 **/
		public AgentType* inline_agent;

/**
   Convenience method: turn `text' into a `RoutineText'.
 */
		public RoutineText* routine_text() ensures (result!=null) {
			Routine* r = &this;
			FeatureText* ft = ((Entity*)r).text;
			return ft.is_routine() ? (RoutineText*)ft : null;			
		}

/**
   @return Does `this' describe a procedure?
 **/
		public bool is_procedure() { return !is_function(); }

/**
   @return Does `this' describe a function?
 **/
		public bool is_function() {
			return (flags & RoutineFlag.FUNCTION)==RoutineFlag.FUNCTION;
		}

/**
   @return Does `Current' describe an alias operator (except bracket)?
 **/
		public bool is_operator() {
			return (flags & RoutineFlag.OPERATOR)==RoutineFlag.OPERATOR;
		}

/**
   @return Does `Current' describe the bracket operator?
 **/
		public bool is_bracket() {
			return (flags & RoutineFlag.BRACKET)==RoutineFlag.BRACKET;
		}

/**
 **/
		public bool is_prefix() { 
			return argument_count<=1 && _entity.alias_name!=null;
		 }

/**
   @return Does `Current' describe a creation procedure?
 **/
		public bool is_creation() {
			return (flags & RoutineFlag.CREATION)==RoutineFlag.CREATION;
		}

/**
   @return Does `Current' describe the default creation procedure?
 **/
		public bool is_default_creation() {
			return (flags & RoutineFlag.DEFAULT_CREATION)==
				RoutineFlag.DEFAULT_CREATION;
		}

/**
   @return Does `Current' describe the precursor of a routine?
 **/
		public bool is_precursor() {
			return (flags & RoutineFlag.PRECURSOR)==RoutineFlag.PRECURSOR;
		}

/**
   @return Does `Current' describe a once routine?
 **/
		public bool is_once() {
			return (flags & RoutineFlag.IMPLEMENTATION)==RoutineFlag.ONCE;
		}

/**
   @return Does `Current' describe an external routine?
 **/
		public bool is_external() {
			return (flags & RoutineFlag.IMPLEMENTATION)==RoutineFlag.EXTERNAL;
		}

/**
   @return Does `Current' describe an inlined routine?
 **/
		public bool is_inlined() {
			return (flags & RoutineFlag.INLINED)==RoutineFlag.INLINED;
		}

/**
   @return Does `Current' describe an external routine?
 **/
		public bool uses_current() {
			return (flags & RoutineFlag.NO_CURRENT)==0;
		}

/**
   @return Does routine use a result value?
 **/
		public bool has_result() {
			return is_function() && !is_external();
		}

/**
   @return Has the routine a rescue clause?
 **/
		public bool has_rescue() {
			return (flags & RoutineFlag.RESCUE)==RoutineFlag.RESCUE;
		}

		public uint argument_count; 

/**
   Number of local variables (including `Result' in case of a function). 
**/
		public uint local_count;
		
/**
   Number of object test variables.
**/
		public uint scope_var_count;
		
/**
   Number of old variables .
 **/
		public uint old_value_count;
		
/**
   Number of temporary variables.   
 **/
		public uint temp_var_count;
		
/**
   @return: 
   Total number of arguments (including the implicit `Current')
   and local variables (including `Result' in case of a function).
**/
		public uint variable_count() { return vars.length; }
		
/**
   @return Is `i' a valid index for an argument or a local variable?
 **/
		public bool valid_var(uint i) {
			return  i < vars.length && vars[i]!=null;
		}
		
/**
   @return:
   `i'-th argument or local variable.
   argument at `i=0' means `Current'. 
   If the routine a function then `i=variable_count-1' means `Result'.
**/
		public Local* var_at(uint i) { return vars[i]; }
				
/**
   @return Local variable corresponding to `Result'.
 **/
		public Local* result_field() { 
			return vars[argument_count]; 
		}
		
		public uint inline_routine_count() { 
			return inline_routines==null ? 0 : inline_routines.length;
		}
		
/**
   @return `i'-th inline routine defined within `Current'.
**/
		public Routine* inline_routine_at(uint i) {
			return inline_routines==null ? &this : inline_routines[i];
		}
		
/**
   @return 
   Index of `Current's argument, local variable, or old value
   of name `nm'; `Void' if no such entity exists.
**/
		public Local* var_by_name (string nm) {
			Local* l;
			uint i;
			for (i=vars.length; i-->0;) {
				l = vars[i];
				if (l!=null && l._entity.has_name(nm)) return l;
			}
			return null;
		}
		
		public bool is_less(Routine* other) {
			bool result = _entity.is_less(&other._entity);
			if (!result && _entity.to_string()==other._entity.to_string()) {
				result = argument_count < other.argument_count;
			}
			return result;
		}
		
		public string append_name (string to) {
			Local* a;
			uint i, n=argument_count;
			string s = append_name(to);
			if (n>0) {
				s += string.nfill(1, '(');
				for (i=0; i<n; ++i) {
					a = vars[i];
					if (i>0 && a!=null) {
						s += string.nfill(1, ',');
						s = a._entity.append_name(s);
					}
					s += string.nfill(1, ')');
				}
			}
			if (is_function()) {
				s += ": ";
				s = result_field()._entity.type._name.append_name (s);
			}
			return s;
		}
		
		public Local*[] vars;
		
		public Routine*[] inline_routines;
		
		public Routine*[] precursors;
		
/**
   Absolute location of the routine call.
 **/
		public void* call;

		public uint wrap;
		
	} /* struct Routine */
		
/* ---------------------------------------------------------------------- */

/**
   Internal description of the status of once routines. 
**/
	
	public struct Once {
		
		public Routine _routine;

/**
   ClassText containing `Current'. 
**/
		public ClassText* home;
		
		public void* value_address;

		internal void* init_address;

/**
   @return Does `this' describe a function?
 **/
		public bool is_function() { return _routine.is_function(); }

/**
   @return Has `Current' already been computed?
**/
		public bool is_initialized() {
			return init_address==null || *(uint8*)init_address!=0;
		}
		
/**
   Reset the object to initialized state.
**/
		public void re_initialize() { *(uint8*)init_address = 1; }
		
/**
   Reset the object into the virgin state.
**/			
		public void refresh() { *(uint8*)init_address = 0; }
		
	} /* struct Once */
	
/* ---------------------------------------------------------------------- */	

/**
   Internal description of a constant of a class.
**/
	public struct Constant {

		public Entity _entity;

		public uint flags;

		public ClassText* home;

/**
   Value of the constant (bitwise as long integer).
 **/
		public uint64 basic;

/**
   String value of the constant.
 **/
		public void* ms;

	} /* struct Constant */
	
/* ---------------------------------------------------------------------- */

/**
   Internal description of a class in an Eiffel system.
 **/
	public struct ClassText {

		public Name _name;

		public uint ident;

		public uint flags;

		public string? path;

		public bool is_expanded() {
			return (flags & TypeFlag.SUBOBJECT) != 0;
		}

		public bool is_basic() {
			return (flags & TypeFlag.BASIC_EXPANDED) == TypeFlag.BASIC_EXPANDED;
		}

		public bool is_separate() {
			return (flags & TypeFlag.PROXY) != 0;
		}

		public bool is_deferred() {
			return (flags & TypeFlag.MEMORY_CATEGORY) == 0;
		}

		public bool is_actionable() {
			return (flags & ClassFlag.ACTIONABLE) != 0;
		}

		public bool is_debug_enabled() {
			return (flags & ClassFlag.DEBUGGER) != 0;
		}

		public bool supports_invariant() {
			return (flags & RoutineFlag.INVARIANT) != 0;
		}

		public bool is_special() {
			return _name.fast_name == "SPECIAL";
		}

		public bool is_tuple() {
			return _name.fast_name == "TUPLE";
		}

		internal ClassText*[] parents;
		internal FeatureText*[] features;
		
/**
   @return Number of direct parent classes.
 **/
		public uint parent_count() {
			return parents==null ? 0 : parents.length; 
		}

		public bool valid_parent(uint i) { return i<parent_count(); }

/**
   @return The `i'-th direct parent.
**/
		public ClassText* parent_at(uint i) requires (valid_parent(i)) {
			return parents[i]; 
		}

/**
   @return Number of features.
 **/
		public uint feature_count() { 
			return features==null ? 0 : features.length; 
		}

		public bool valid_feature(uint i) { return i<feature_count(); }


/**
   @return The `i'-th feature.
**/
		public FeatureText* feature_at(uint i) requires (valid_feature(i)) {
			return features[i]; 
		}

/**
   @return: Index of `Current's feature with name `nm';
   `null' if no such feature exists.
 **/
		public FeatureText* feature_by_name(string nm, bool deep=false) {
			FeatureText* ft;
			for (uint i=feature_count(); i-->0;) {
				ft = feature_at(i);
				if (ft._name.has_name(nm)) return ft;
			}
			if (deep) {
				FeatureText* found = null;
				for (uint j=parent_count(); j-->0;) {
					ft = parent_at(j).feature_by_name(nm, true);
					if (found==null) found = ft;
					else if (found!=ft) return null;
				}
				return found;
			}
			return null;
		}

		public FeatureText* feature_by_line(uint l) {
			FeatureText* ft;
			for (uint i=feature_count(); i-->0;) {
				ft = feature_at(i);
				if (ft.home._name.fast_name==_name.fast_name 
					&& ft.first_line()<=l && l<=ft.last_line()) return ft;
			}
			return null;
		}

/**
How good does `Current' conform to `other'?
`Result=0' means exact match, `Result=uint.MAX' means no match.
other value means `other' is a parent class.
**/
		public uint descendance (ClassText* other) {
			ClassText* cls;
			uint i, p, result=0;
			if (other.ident!=ident) {
				result = uint.MAX;
				for (i=parent_count(); i-->0;) {
					cls = parent_at(i);
					if (cls!=&this) {
						p = cls.descendance(other);
						if (p<result - 1) result = p+1;
					}
				}
			}
			return result;
		}

/**
   @return Does `Current' inherit from `other'?"
 **/
		public bool is_descendant (ClassText* other) {
			return descendance(other) < uint.MAX;
		}

/**
   Current's query given by a name prefix;
   `null' if not found or not unique.
 **/
		public FeatureText* query_by_name(out uint n,
										  string name, bool as_prefix=false, 
										  RoutineText* within=null) {
			FeatureText* ft;
			RoutineText* rt;
			var list = new Name*[0];
			uint i;
			if (within!=null) {
				for (i=within.vars.length; i-->1;) {
					ft = within.vars[i];
					if (ft!=null) list += (Name*)ft;
				}
			}
			for (i=features.length; i-->0;) {
				ft = features[i];
				if (ft.result_text==null) continue;
				rt = ft.is_routine() ? (RoutineText*)ft : null;
				if (rt!=null) {
					if ((rt.argument_count<2)!=as_prefix) continue;
				}
				if (name==ft.alias_name) {
					n = 1;
					return ft;
				}
				list += (Name*)ft;
			} 
			return (FeatureText*)query_from_list(name.down(), list, out n);
		}
		
	} /* struct ClassText */

/* ---------------------------------------------------------------------- */

/**
   Internal description of a feature text of a class.
**/
	public struct FeatureText {

		public Name _name;

		public string? alias_name;

		public int flags;

		public bool is_attribute() { return (flags & RoutineFlag.ROUTINE)==0; }
		public bool is_routine() { return (flags & RoutineFlag.ROUTINE)!=0; }
		public bool is_constant() { return (flags & RoutineFlag.ONCE)!=0; }
		public bool is_variable() { return (flags & RoutineFlag.ONCE)==0; }
		
/**
   Tuple labels if the feature result is of a TUPLE type. 
 **/
		public FeatureText*[] tuple_labels;	

/**
   Class containing `Current'. 
 **/
		public ClassText* home;
	
/**
   Class of 'Result'. 
 **/
		public ClassText* result_text;
	
/**
   Class and feature where `Current' is defined. 
 **/
		public FeatureText* definition () {
			return renames!=null ? renames : &this;
		}
	
		public bool has_line (uint l) {
			return (first_line()<=l) && (l<=last_line());
		}

		public bool has_position(uint l, uint c) {
			return (first_line()==l) && (column()==c);
		}

		public uint first_line() { return line_of_position (first_pos); }
		public uint last_line() { return line_of_position (last_pos); }
		public uint column() { return column_of_position (first_pos); }

		public FeatureText* renames;

		public uint first_pos;
		public uint last_pos;

        public string append_label (string to, string item) 
		requires (tuple_labels!=null) {
			FeatureText* tli;
			string str = to;
			uint i=0, k, l;
			int c, c0;
			bool failed = !item.has_prefix("item_");
			if (!failed) {
				c0 = (int)'0';
				for (k=5, l=item.length; !failed && k<l;) {
					c = (int)item.@get(k) - c0;
					failed = c<0 || 9<c;
					i = 10*i + c;
				}
			}
			if (!failed && i<=tuple_labels.length) {
				tli = tuple_labels[i-1];
				str = tli._name.append_name(str);
			} else {
				str += item;
			}
			return str;
		}

/**
   Index of tuple label.
   
   @param name Label name to look for
   @return -1: not found, <-1: multiply found, >=0: valid index
 */
		public int item_by_label(string name) {
			Name* found;
			uint n;
			var labels = tuple_labels;
			if (labels==null) return -1;
			var list = new Name*[0];
			for (int i=labels.length; i-->0;) 
				list += (Name*)labels[i];
			found = query_from_list(name.down(), list, out n);
			if (n>1) return -(int)n;
			if (n<1) return -1;
			for (int i=labels.length; i-->0;) 
				if ((Name*)labels[i]==found) return i;
			return -1;
		}		

	} /* struct FeatureText */

/* ---------------------------------------------------------------------- */

/**
   Internal description of a routine text of a class.
 **/
	public struct RoutineText {

		public FeatureText _feature;

		public bool has_position(uint l, uint c, bool body_only=true) {
			uint p = position_as_integer(l, c);
			bool ok = body_only ? (entry_pos<=p) && (p<=exit_pos)
				: (_feature.first_pos<=p) && (p<=_feature.last_pos);
			for (uint i=inline_texts.length; i-->0;) {
				var inl = inline_texts[i];
				ok &= !inl.has_position(l, c, false);
			}
			return ok;
		}

		public bool has_rescue() { return rescue_pos>0; } 

		public uint var_count() { 
			return vars==null ? 0 : vars.length; 
		}

		public FeatureText* var_at(uint i) requires(i<var_count()) {
			return vars[i];
		}

		public uint entry_pos; 
		public uint rescue_pos;
		public uint exit_pos;

		public FeatureText*[] vars;
		public int argument_count;
		public int local_count;
		public int scope_var_count;

		public FeatureText* var_by_name(string name) {
			FeatureText* loc;
			for (uint i=var_count(); i-->0;) {
				loc = vars[i];
				if (loc!=null && loc._name.fast_name==name) return loc;
			}
			return null;
		}

		public int inline_text_count() { return inline_texts.length; }

		public RoutineText*[] inline_texts;

		public uint[] instruction_positions;

		public uint next_position(int p) {
			uint i, n, result=uint.MAX;
			if (instruction_positions==null) return result;
			for (i=instruction_positions.length; i-->0;) {
				n = instruction_positions[i];
				if (n<result && p<=n) result = n;
			}
			return result;
		}

	} /* struct RoutineText */

/* ---------------------------------------------------------------------- */

/**
   Internal description of a type. 
 **/

	public struct Type {
		
		public Name _name;
	
/**
   System wide constant identifier. 
 **/
		public uint ident;

/**
   Descriptor of underlying class text.
 **/
		public ClassText* base_class;
	
		public string class_name;

		internal Type*[] generics;
		internal Type*[] effectors;
		internal Routine*[] routines;
		internal Field*[] fields;
		internal Constant*[] constants;
		
/**
   @return Number of generics parameters.
 **/
		public uint generic_count() {
			return generics==null ? 0 : generics.length;
		}

		public bool valid_generic (uint i) { return i<generic_count(); }

/**
   @return: Type of the `i'-th actual generic parameter.
 **/		
		public Type* generic_at (uint i) requires (valid_generic(i)) {
			return generics[i];
		}

/**
   @return Number of effectors parameters.
 **/
		public uint effector_count() {
			return effectors==null ? 0 : effectors.length;
		}

		public bool valid_effector (uint i) { return i<effector_count(); }

/**
   @return: The `i'-th effector.
 **/		
		public Type* effector_at (uint i) requires (valid_effector(i)) {
			return effectors[i];
		}

/**
   @return Number of fields.
 **/
		public uint field_count() {
			return fields==null ? 0 : fields.length;
		}

		public bool valid_field (uint i) { return i<field_count(); }

/**
   @return: The `i'-th fiedg.
 **/		
		public Field* field_at (uint i) requires (valid_field(i)) {
			return fields[i];
		}

/**
   @return Number of constants.
 **/
		public uint constant_count() {
			return constants==null ? 0 : constants.length;
		}

		public bool valid_constant (uint i) { return i<constant_count(); }

/**
   @return: The `i'-th constant.
 **/		
		public Constant* constant_at (uint i) requires (valid_constant(i)) {
			return constants[i];
		}

/**
   @return Number of routines.
 **/
		public uint routine_count() {
			return routines==null ? 0 : routines.length;
		}

		public bool valid_routine (uint i) { return i<routine_count(); }

/**
   @return: The `i'-th routine.
 **/		
		public Routine* routine_at (uint i) requires (valid_routine(i)) {
			return routines[i];
		}


/**
   @return  Procedure implementing `default_create' from class ANY
   if it is a creation procedure of the type, may be `null'.
**/
		public Routine* default_creation() {
			Routine* r;
			if (routines==null) return null;
			for (uint i=routine_count(); i-->0;) {
				r = routine_at(i);
				if (r.is_default_creation()) return r;
			}
			return null;
		}

/**
   @return: Function computing the class invariant, may be `null'.
 **/
		public Routine* invariant_function() { return null; }

/**
   @return Has `Current' a bracket function?
 **/
		public bool has_bracket() { return bracket!=null; }

/**
   @return The type's bracket function, if any.
 **/
		public Routine* bracket() {
			Routine* r;
			for (uint i=routine_count(); i-->0;) {
				r = routine_at(i);
				if (r.is_bracket()) return r;
			}
			return null;
		}

		public uint flags;

		public bool is_none() { return _name.has_name("NONE"); }

		public bool is_boolean() { return ident==TypeIdent.BOOLEAN; }
		public bool is_character() { return ident==TypeIdent.CHARACTER_8; }
		public bool is_char8() { return ident==TypeIdent.CHARACTER_8; }
		public bool is_char32() { return ident==TypeIdent.CHARACTER_32; }
		public bool is_integer() { 
			return TypeIdent.INTEGER_8<=ident && ident<=TypeIdent.INTEGER_64;
		}
		public bool is_int8() { return ident==TypeIdent.INTEGER_8; }
		public bool is_int16() { return ident==TypeIdent.INTEGER_16; }
		public bool is_int32() { return ident==TypeIdent.INTEGER_32; }
		public bool is_int64() { return ident==TypeIdent.INTEGER_64; }
		public bool is_natural() { 
			return TypeIdent.NATURAL_8<=ident && ident<=TypeIdent.NATURAL_64; 
		}
		public bool is_nat8() { return ident==TypeIdent.NATURAL_8; }
		public bool is_nat16() { return ident==TypeIdent.NATURAL_16; }
		public bool is_nat32() { return ident==TypeIdent.NATURAL_32; }
		public bool is_nat64() { return ident==TypeIdent.NATURAL_64; }
  		public bool is_real() { 
			return ident==TypeIdent.REAL_32 || ident==TypeIdent.REAL_64; 
		}
  		public bool is_real32() { return ident==TypeIdent.REAL_32; }
  		public bool is_real64() { return ident==TypeIdent.REAL_64; }
		public bool is_pointer() { return ident==TypeIdent.POINTER; }
		public bool is_string() { return ident==TypeIdent.STRING_8; }
		public bool is_unicode() { return ident==TypeIdent.STRING_32; }

		public bool is_subobject() { 
			return (flags & TypeFlag.SUBOBJECT) > 0;
		}

		public bool is_basic() { 
			return (flags & TypeFlag.BASIC_EXPANDED) == TypeFlag.BASIC_EXPANDED;
		}

		public bool is_reference() { return !is_subobject(); }

		public bool is_separate() { 
			return (flags & TypeFlag.PROXY) == TypeFlag.PROXY;
		}

		public bool is_anonymous() {
			return (flags & TypeFlag.ATTACHED) == TypeFlag.ATTACHED;
		}

		public bool is_attached() {
			return (flags & TypeFlag.ANONYMOUS) == TypeFlag.ANONYMOUS;
		}

		public bool is_meta_type() {
			return (flags & TypeFlag.META_TYPE) == TypeFlag.META_TYPE;
		}

		public bool is_actionable() { 
			return (flags & ClassFlag.ACTIONABLE) > 0;
		}

		public bool is_normal() { 
			return (flags & 
					(TypeFlag.FLEXIBLE
					 |TypeFlag.TUPLE
					 |TypeFlag.AGENT)) == 0;
		} 
		
		public bool is_expanded() { 
			return (flags & TypeFlag.SUBOBJECT) !=0;
		} 

		public bool is_nonbasic_expanded() { 
			return (flags & TypeFlag.SUBOBJECT) !=0 
				&& (flags & TypeFlag.BASIC_EXPANDED) < TypeFlag.BASIC_EXPANDED;
		}

		public bool is_special() { 
			return (flags & TypeFlag.FLEXIBLE) !=0;
		} 

		public bool is_tuple() {
			return (flags & TypeFlag.TUPLE) !=0;
		} 

		public bool is_agent () {
			return (flags & TypeFlag.AGENT) !=0;
		} 

		public bool conforms_to(Type* t) {
			if (t==null) return false;
			if (t.ident==ident) return true;
			for (uint i=effector_count(); i-->0;) 
				if (effector_at(i)==t) return true;
			return false;
		}

/**
   @return Is the type alive (i.e. can instances be created) ?"
 **/
		public bool is_alive() { 
			return (flags & TypeFlag.MEMORY_CATEGORY)>0 
			&& (flags & TypeFlag.META_TYPE)==0; 
		}

/**
   @return "Does the type's base class define an invariant clause?
 **/
		public bool has_invariant() {
			return base_class.supports_invariant();
		}
		
/**
   Memory size (in bytes) of instances of the current type. 
 **/
		public uint instance_bytes;

/**
   @return Memory size (in bytes) of objects within other objects.	
**/	
		public uint field_bytes() {
			return is_subobject() ? instance_bytes : (uint)sizeof(void*);
		}
/**
   @return Comparison by ident.
 **/
		public bool is_less(Type* other) {
			return other!=null ? ident < other.ident : true;
		}

/**
   @return Comparison by name.
**/
		public bool is_name_less(Type* other) {
			uint i, n;
			int sign;
			if (other==null) return true;
			n = uint.min(other.generic_count(), generic_count());
			sign = class_name.ascii_casecmp(other.class_name);
			if (sign==0) {
				for (i=0; i<n; ++i) {
					if (generic_at(i).is_name_less(other.generic_at(i))) 
						return true;
				}
			}
			return false;
		}
		
/**
   Does type described by `Current' effect the type described by `other'?
 **/
		public bool does_effect(Type* other) {
			for (uint i=other.effectors.length; i-->0;) {
				if (other.effectors[i]==&this) return true;
			}
			return false;
		}
/**
   @return Current's field of given name. 
   `null' if no such field exists.
 **/
		public Field* field_by_name (string nm) {
			Field* f;
			for (uint i=field_count(); i-->0;) {
				f = field_at(i);
				if (f._entity.has_name(nm)) return f;
			}
			return null;
		}

/**
   @return Current's routine of given name. 
   `null' if no such routine exists.
 **/
		public Routine* routine_by_name (string nm, bool creation) {
			Routine* r;
			for (uint i=routine_count(); i-->0;) {
				r = routine_at(i);
				if (r.is_precursor()) continue;
				bool cr = ((r.flags & RoutineFlag.CREATION)>0) == creation;
				if (r._entity.has_name(nm) && cr) return r;
			}
			return null;
		}
		
/**
   Current's query given by a name prefix;
   `null' if not found or not unique.
   Set `n' to the number of queries found.
 **/
		public Entity* query_by_name(out uint n, string name, bool as_prefix,
									 Routine* within=null) {
			Entity* e;
			Routine* r;
			var list = new Name*[0];
			uint i;
			if (within!=null) {
				var ag = within.inline_agent;
				if (ag==null) {
					for (i=within.vars.length; i-->0;) {
						e = (Entity*)within.vars[i];
						if (e!=null) list += (Name*)e;
					}
				} else {
					uint j=0, l=within.argument_count, k=l, m=within.vars.length;
					for (i=0; i<m; ++i) {
						if (i<l && ag.is_closed_operand(i)) {
							e = (Entity*)ag._type.fields[j];
							++j;
						} else {
							e = (Entity*)within.vars[k];
							++k;
						}
						if (e!=null) list += (Name*)e;
					}
				}
			}
			if (within==null || within.inline_agent==null) {
				for (i=fields.length; i-->0;) {
					e = (Entity*)fields[i];
					string fn = e._name.fast_name;
					if (e.text==null) 
						if (fn=="[]" || (is_special() && fn=="item")) {
							n = 1;
							return e;
						}
						else continue;
					if (name==e.text.alias_name) {
						n = 1;
						return e;
					}
					list += (Name*)e;
				} 
			}
			for (i=constants.length; i-->0;) {
				e = (Entity*)constants[i];
				if (e.alias_name!=null) continue;
				if (name==e.text.alias_name) {
					n = 1;
					return e; 
				}
				list += (Name*)e;
			} 
			for (i=routines.length; i-->0;) {
				r = routines[i];
				if (!r.is_function()) continue;
				if (r._entity.alias_name!=null && r.is_prefix()!=as_prefix)
					continue;
				if (name==r._entity.text.alias_name) {
					n = 1;
					return (Entity*)r; 
				}
				list += (Name*)r;
			} 
			return (Entity*)query_from_list(name.down(), list, out n);
		}
		
		public string append_name(string to) {
			string str = to;
			uint i, n;
			str += class_name;
			n = generic_count();
			if (n>0) {
				for (i=0; i<n; ++i) {
					str += string.nfill(1, i==0 ? '[' : ',');
					str += generic_at(i).append_name(str);
				}
				str += string.nfill(1, ']');
			}
			return str;
		}

		public void* default_instance;

		public void* new_instance(bool use_default_creation) 
		requires (is_alive()) {
			void* obj;
			obj = c_new_object(allocate);
			if (use_default_creation) {
				Routine* dc = default_creation();
				if (dc!=null) c_call_create(dc.call, obj);
			}
			return obj;
		}
		
		public void* allocate;
		
		public uint8* dereference(void* addr) {
			return (addr!=null && !is_subobject()) ? 
				*(void**)addr : addr;
		}
		
	} /* struct Type */

/* ---------------------------------------------------------------------- */

/**
   Internal description of types in an Eiffel system.
 **/

	public struct NormalType {

		public Type _type;

	} /* struct NormalType */

/* ---------------------------------------------------------------------- */

/**
   Internal description of expanded types in an Eiffel system.
 **/

	public struct ExpandedType {

		public NormalType _normal;
/**
   Memory size of boxed instances. 
 **/
		public uint boxed_bytes;

/**
   Offset of unboxed item within boxed instance. 
**/
		public uint boxed_offset;
		
		public void set_boxed_bytes(uint x) { boxed_bytes = x; }
		public void set_boxed_offset(uint o) { boxed_offset = o; }

		internal void* unboxed_location;
		
		public void* new_instance(bool use_default_creation) { 
			void* obj;
			if ((_normal._type.flags & TypeFlag.MISSING_ID) == 0)
				obj = c_new_boxed_object(_normal._type.allocate);
			else
				obj = c_new_object(_normal._type.allocate);
			return obj;
		}

	} /* struct ExpandedType */

/* ---------------------------------------------------------------------- */

/**
   Internal description of types in an Eiffel system.
 **/

	public struct SpecialType {

		public Type _type;

/**
   @return Attribute describing field at index 0
   (e.g. the offset of the C array within an instance).
 **/
		public Field* count() { 
			bool ok = _type.fields!=null;
			if (ok) return _type.fields[0];
			return null; 
		}

		public Field* item_0() { 
			bool ok = _type.fields!=null;
			if (ok) return _type.fields[2];
			return null; 
		}

/**
 **/
		public Type* item_type() requires (_type.fields!=null) { 
			return _type.generic_at (0); 
		}
/**
   @return Memory size (in bytes) of array items.
 **/
		public uint item_bytes() { return item_type().field_bytes(); }

/**
   @return 	Offset (in bytes) of the `i'-th entry
   of the SPECIAL object (of type given by `Current'),
**/
		public int item_offset (uint i) requires (_type.fields!=null) {
			return (int)(item_0().offset + i*item_bytes());
		}

		public void* new_instance(bool use_default_creation) { 
			return new_array(0);
		}

/**
   @return Create a new `SPECIAL' of type `s' and length `n'.
 **/
		public void* new_array(uint n) {
			return c_new_array(_type.allocate, n);
		}

		public uint capacity (uint8* a) requires (a!=null) {
			Field* c = count();
			if (c!=null) {
				uint8* addr = a + c.offset;
				return *(uint*)addr;
			}
			return 0;
		}
		
/**
   @return Number of items of SPECIAL object at `addr'.
 **/
		public uint special_count(uint8* addr) {
			if (addr==null) return 0;
			if (_type.fields.length==0) return 0;
			addr += count().offset;
			return *(uint*)addr;
		}
		
/**
   @return Item array of SPECIAL object at `addr'.
 **/
		public uint8* base_address(uint8* addr) {
			if (addr==null) return null;
			return  addr+item_0().offset;
		}

	} /* struct SpecialType */

/* ---------------------------------------------------------------------- */

/**
   Internal description of types in an Eiffel system.
 **/

	public struct TupleType {

		public Type _type;

/**
   Append TUPLE label.
   @field: TUPLE item
   @str: String to be extended
 **/
		public string append_labeled_type_name(Field* field, string to) 
		requires (field._entity.type==&_type) {
			FeatureText* text = field._entity.text;
			uint i, n = _type.generic_count();
			string str = to; 
			if (text!=null && n>0) {
				str += _type.class_name;
				for (i=0; i<n; ++i) {
					str += i==0 ? "[" : ", ";
					if (text.tuple_labels!=null) { 
						str = text.append_label(str, _type.fields[i]._entity.to_string());
						str += ": ";
					}
					str = _type.generic_at(i).append_name(str);
				}
				str += "]";
			} else {
				str = _type.append_name(str);
			}
			return str;
		}

		public Field* item_by_label(string name, FeatureText* labeled,
			out uint n) 
			requires (labeled==null || labeled.tuple_labels==null
					  || labeled.tuple_labels.length>=_type.fields.length)
 {
			Field* f;
			Name* found;
			var labels = labeled!=null ? labeled.tuple_labels : null;
			var list = new Name*[0];
			int i;
			for (i=_type.fields.length; i-->0;) {
				f = _type.fields[i];
				list += (Name*)f;
				if (labels!=null)
					list += (Name*)labels[i];
			}
			found = query_from_list(name.down(), list, out n);
			if (found==null) return null;
			if (found.is_field()) return (Field*)found;
			var found_name = found.fast_name;
			for (i=_type.fields.length; i-->0;)
				if (((Name*)labels[i]).has_name(found_name)) 
					return _type.fields[i];
			return null;
		}		
		
	} /* struct TupleType */

/* ---------------------------------------------------------------------- */

/**
   Internal description of types in an Eiffel system.
 **/

	public struct AgentType {

		public Type _type;

		public static const char open_operand_indicator = '?';
		public static const char closed_operand_indicator = '_';

/**
   Type descriptor of the routine's base class. 
 **/	
		public Type* base_type;
	
/**
   @return Is the routine's target a closed operand?
**/
		public bool base_is_closed() {
			return open_closed_pattern.@get(0) == closed_operand_indicator;
		}

/**
   @return Is the routine's target an open operand?
**/
		public bool base_is_open() { return !base_is_closed(); }

		public string open_closed_pattern;

/**
   @return Is `pos' a valid argument index?
**/	
		public bool valid_arg_index(uint pos) { 
			return pos < open_closed_pattern.length;
		}

/**
   Number of open operands. 
 **/
		public uint open_operand_count;

/**
   @return Is `pos'-th arg of the routine open in the agent?
**/
		public bool is_open_operand(uint pos) 
			requires (valid_arg_index(pos)) {
			return open_closed_pattern[pos] == open_operand_indicator;
		}
		
/**
   @return Is `pos'-th arg of the routine closed in the agent?
**/
		public bool is_closed_operand(uint pos) 
			requires (valid_arg_index(pos)) {
			return open_closed_pattern[pos] == closed_operand_indicator;
		}
		
/**
   Number of closed operands. 
 **/
		public uint closed_operand_count;
	
/**
   Type of `Current's declaration. 
**/
		public NormalType* declared_type;

/**
   Tuple of closed operands (GEC specific). 
**/	
		public TupleType* closed_operands_tuple;

/**
   @return Type descriptor of the routine's result type
   (`null' if the routine is a procedure
   or if the result value is not implemented).
 **/	
		public Type* result_type () {
			Field* lr = last_result();
			return lr!=null ? lr._entity.type: null;
		}
/**
   @return Descriptor of `last_result' if it has been defined.
**/
		public Field* last_result() {
			if (_type.field_count()>closed_operand_count) 
				return _type.field_at(closed_operand_count);
			else
				return null;
		}

/**
   Descriptor of agent's routine. 
 **/
		public Routine* routine;
	
/**
   Name of agent's routine. 
 **/
		public string routine_name;

		public string append_name(string to) {
			string str = to;
			uint i, n;
			str += "agent ";
			if (!is_closed_operand(0)) str += "{";
			str = base_type.append_name(str);
			if (!is_closed_operand(0)) str += "}";
			str += ".";
			str += routine_name;
			for (i=1, n=open_operand_count+closed_operand_count; i<n; ++i) {
				str += i==1 ? "(" : ",";
				if (is_closed_operand(i))
					str += string.nfill(1, closed_operand_indicator);
				else
					str += string.nfill(1, open_operand_indicator);
			}
			if (n>1) str += ")";
			return str;
		}

		public void* call_function;

		internal void* function_location;

		public int function_offset;

		public uint8* closed_operands(uint8* id) {
			Field* cot = declared_type._type.fields[0];
			return (uint8*)id + cot.offset;
		}

		public uint8* closed_operand(uint8* id, uint i) {
			uint8* addr = closed_operands(id);
			addr = *(uint8**)addr;
			return addr + closed_operands_tuple._type.fields[i].offset;
		}

	} /* struct AgentType */

/**
   Internal description of a frame of the call stack.
**/
	public struct StackFrame {

/*
  The `depth' member must be the first member of the struct: 
  some routines use it to obtain the address of the object itself.
*/
		public int depth;

		public int scope_depth;

		public StackFrame* caller;

		public uint pos;

		public uint line() { return line_of_position(pos); }
		public uint column() { return column_of_position(pos); }
		public void set_position(int l, int c) { 
			pos = position_as_integer(l, c); 
		}

		public uint class_id;

		public Routine* routine;

/**
   @return Type of actual target
 */
		public Type* target_type() { return routine.target; }

	} /* struct StackFrame */

/**
   @return Address of actual target
 */
	public static uint8* target(StackFrame* f) {
		var v0 = f.routine.vars[0];
		if (v0==null) return null;
		var obj = (uint8*)f;
		obj += v0.offset;
		return *(uint8**)obj;
	}
		
	internal void* stack_address(StackFrame* f, uint i) { 
		uint8* addr = (uint8*)f;
		addr += f.routine.vars[i].offset;
		return addr;
	}

	internal uint c_ident(void *a) { return a!=null ? *(int*)a : 0; }
	
	private delegate void* NewObject(bool init);
	private delegate void* NewArray(uint n, bool init);
	private delegate void Init(void* obj);
	
	internal void* c_new_object(void *call) {
		return ((NewObject)call)(true);
	}
	
	internal void* c_new_boxed_object(void *call) {
		return ((NewObject)call)(true);
	}
	
	internal void* c_new_array (void* call, uint n) {
		return ((NewArray)call)(n,true);
	}
	
	internal void c_call_create(void* call, void* obj) { ((Init)call)(obj); }	
	
} /* namespace */

private Object dummy;	// Make the compiler happy!
