using Gedb;

public enum OpCode {
	assign = 1,
	not,
	and, and_then, or, or_else, xor, implies,
	eq, ne, sim, nsim, lt, le, gt, ge,
	pos, neg, plus, minus, mult, div, idiv, imod, power, 
	bit_or, bit_and, l_shift, r_shift, 
	interval,
	free1, free2, 
	bracket 
}

public enum ConstCode {
	placeholder = -1,
	any = 0, 
	boolean, char_8, char_32, int_64, nat_64, real_64, string_8, string_32 
}

public enum RangeCode { interval, dollar, all, iff }

public const string  bullet = "•"; // "●" "⚫" "•"


public void copy_value(uint8* left, uint8* right, size_t size) {
	if (left!=right) Posix.memcpy (left, right, size);
}

public bool are_values_equal(uint8* left, uint8* right, size_t size) {
	if (left==right) return true;
	return Posix.memcmp(left, right, size) == 0;
}

public void clear_value(uint8* val, uint size) {
	for (uint i=0; i<size; i++, val++) *val = 0;
}

public bool is_zero_value(uint8* val, uint size) {
	for (uint i=0; i<size; i++, val++) if (*val != 0) return false;
	return true;
}

	public static void compute_basic_infix(Gedb.Type* lt, uint8* left,
										  Gedb.Type* rt, uint8* right,
										  uint op, uint8* result) 
	requires (lt.is_basic() && rt.is_basic()) {
		uint lid = lt.ident;
	
		uint rid = rt.ident;
		bool b = *(bool*)left;
		int64 i = 0;
		uint64 n = 0;
		double d = 0;
		bool rb = *(bool*)right;
		int64 ri = 0;
		uint64 rn = 0;
		double rd = 0;
		
		switch (rid) {
		case TypeIdent.INTEGER_8:
			ri = *(int8*)right;
			rn = ri;
			rd = ri;
			rid = TypeIdent.INTEGER_64;
			break;
		case TypeIdent.INTEGER_16:
			ri = *(int16*)right;
			rn = ri;
			rd = ri;
			rid = TypeIdent.INTEGER_64;
			break;
		case TypeIdent.INTEGER_32:
			ri = *(int32*)right;
			rn = ri;
			rd = ri;
			rid = TypeIdent.INTEGER_64;
			break;
		case TypeIdent.INTEGER_64:
			ri = *(int64*)right;
			rn = ri;
			rd = ri;
			break;
		case TypeIdent.NATURAL_8:
			rn = *(uint8*)right;
			ri = (int64)rn;
			rd = ri;
			rid = TypeIdent.NATURAL_64;
			break;
		case TypeIdent.NATURAL_16:
			rn = *(uint16*)right;
			ri = (int64)rn;
			rd = rn;
			rid = TypeIdent.NATURAL_64;
			break;
		case TypeIdent.NATURAL_32:
			rn = *(uint32*)right;
			ri = (int64)rn;
			rd = rn;
			rid = TypeIdent.NATURAL_64;
			break;
		case TypeIdent.NATURAL_64:
			rn = *(uint64*)right;
			ri = (int64)rn;
			rd = rn;
			break;
		case TypeIdent.REAL_32:
			rd = *(float*)right;
			rid = TypeIdent.REAL_64;
			break;
		case TypeIdent.REAL_64:
			rd = *(double*)right;
			break;
		}

		switch (lid) {
		case TypeIdent.INTEGER_8:
			i = *(int8*)left;
			n = i;
			d = i;
			lid = TypeIdent.INTEGER_64;
			break;
		case TypeIdent.INTEGER_16:
			i = *(int16*)left;
			n = i;
			d = i;
			lid = TypeIdent.INTEGER_64;
			break;
		case TypeIdent.INTEGER_32:
			i = *(int32*)left;
			n = i;
			d = i;
			lid = TypeIdent.INTEGER_64;
			break;
		case TypeIdent.INTEGER_64:
			i = *(int64*)left;
			n = i;
			d = i;
			break;
		case TypeIdent.NATURAL_8:
			n = *(uint8*)left;
			i = (int64)n;
			d = n;
			lid = TypeIdent.NATURAL_64;
			break;
		case TypeIdent.NATURAL_16:
			n = *(uint16*)left;
			i = (int64)n;
			d = n;
			lid = TypeIdent.NATURAL_64;
			break;
		case TypeIdent.NATURAL_32:
			n = *(uint32*)left;
			i = (int64)n;
			d = n;
			lid = TypeIdent.NATURAL_64;
			break;
		case TypeIdent.NATURAL_64:
			n = *(uint64*)left;
			i = (int64)n;
			d = n;
			break;
		case TypeIdent.REAL_32:
			d = *(float*)left;
			lid = TypeIdent.REAL_64;
			break;
		case TypeIdent.REAL_64:
			d = *(double*)left;
			break;
		}

		switch(op) {
		case OpCode.assign:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
			   i = ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = rn;
				break;
			case TypeIdent.REAL_64:
				d = rd;
				break;
			}
			break;
		case OpCode.plus:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
			   i = i + ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = n + rn;
				break;
			case TypeIdent.REAL_64:
				d = d + rd;
				break;
			}
			break;
		case OpCode.minus:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
				i = i - ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = n - rn;
				break;
			case TypeIdent.REAL_64:
				d = d - rd;
				break;
			}
			break;
		case OpCode.mult:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
				i = i * ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = n * rn;
				break;
			case TypeIdent.REAL_64:
				d = d * rd;
				break;
			}
			break;
		case OpCode.div:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
			case TypeIdent.REAL_32:
			case TypeIdent.REAL_64:
				d = d / rd;
				break;
			}
			break;
		case OpCode.idiv:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				i = i / (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				i = i / ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				n = n / (int32)rn;
				break;
			case TypeIdent.NATURAL_64:
				n = n / rn;
				break;
			}
			break;
		case OpCode.imod:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				i = i % (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				i = i % ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				n = n % (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				n = n % (uint32)rn;
				break;
			}
			break;
		case OpCode.bit_and:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
				i = i & ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = n & rn;
				break;
			}
			break;
		case OpCode.bit_or:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
				i = i | ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = n | rn;
				break;
			}
			break;
		case OpCode.l_shift:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
			case TypeIdent.INTEGER_64:
				i = i << (int8)ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
			case TypeIdent.NATURAL_64:
				n = n << (uint8)rn;
				break;
			}
			break;
		case OpCode.r_shift:
			switch (lid) {
			case TypeIdent.INTEGER_8:
				*(int8*)result = (int8)i >> (int8)ri;
				break;
			case TypeIdent.INTEGER_16:
				*(int16*)result = (int16)i >> (int8)ri;
				break;
			case TypeIdent.INTEGER_32:
				*(int32*)result = (int32)i >> (int8)ri;
				break;
			case TypeIdent.INTEGER_64:
				*(int64*)result = i >> (int8)ri;
				break;
			case TypeIdent.NATURAL_8:
				*(uint8*)result = (uint8)n >> (uint8)rn;
				break;
			case TypeIdent.NATURAL_16:
				*(uint16*)result = (uint16)n >> (uint8)rn;
				break;
			case TypeIdent.NATURAL_32:
				*(uint32*)result = (uint32)n >> (uint8)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(uint64*)result = n >> (uint8)rn;
				break;
			}
			break;
		case OpCode.power:
			d = Math.ldexp(*(double*)left, (int8)rd);
			break;
		case OpCode.eq:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				*(bool*)result = (int32)i == (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				*(bool*)result = i == ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				*(bool*)result = (uint32)n == (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(bool*)result = n == rn;
				break;
			case TypeIdent.REAL_64:
				*(bool*)result = d == rd;
				break;
			}
			break;
		case OpCode.ne:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				*(bool*)result = (int32)i != (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				*(bool*)result = i != ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				*(bool*)result = (uint32)n != (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(bool*)result = n != rn;
				break;
			case TypeIdent.REAL_64:
				*(bool*)result = d != rd;
				break;
			}
			break;
		case OpCode.lt:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				*(bool*)result = (int32)i < (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				*(bool*)result = i < ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				*(bool*)result = (uint32)n < (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(bool*)result = n < rn;
				break;
			case TypeIdent.REAL_64:
				*(bool*)result = d < rd;
				break;
			}
			break;
		case OpCode.le:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				*(bool*)result = (int32)i <= (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				*(bool*)result= i <= ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				*(bool*)result= (uint32)n <= (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(bool*)result = n <= rn;
				break;
			case TypeIdent.REAL_64:
				*(bool*)result = d <= rd;
				break;
			}
			break;
		case OpCode.gt:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				*(bool*)result= (int32)i > (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
				*(bool*)result= i > ri;
				break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				*(bool*)result = (uint32)n > (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(bool*)result = n > rn;
				break;
			case TypeIdent.REAL_64:
				*(bool*)result = d > rd;
				break;
			}
			break;
		case OpCode.ge:
			switch (lid) {
			case TypeIdent.INTEGER_8:
			case TypeIdent.INTEGER_16:
			case TypeIdent.INTEGER_32:
				*(bool*)result = (int32)i >= (int32)ri;
				break;
			case TypeIdent.INTEGER_64:
			  *(bool*)result = i >= ri;
			  break;
			case TypeIdent.NATURAL_8:
			case TypeIdent.NATURAL_16:
			case TypeIdent.NATURAL_32:
				*(bool*)result= (uint32)n >= (uint32)rn;
				break;
			case TypeIdent.NATURAL_64:
				*(bool*)result = n >= rn;
				break;
			case TypeIdent.REAL_64:
				*(bool*)result = d >= rd;
				break;
			}
			break;
		case OpCode.and:
			*(bool*)result = b && rb;
			break;
		case OpCode.or:
			*(bool*)result = b || rb;
			break;
		case OpCode.xor:
			*(bool*)result = b != rb;
			break;
		case OpCode.implies:
			*(bool*)result = !b | rb;
			break;
		}

		switch (op) {
		case OpCode.plus:
		case OpCode.minus:
		case OpCode.mult:
		case OpCode.div:
		case OpCode.idiv:
		case OpCode.imod:
		case OpCode.bit_or:
		case OpCode.bit_and:
		case OpCode.l_shift:
		case OpCode.power:
			switch (lt.ident) {
			case TypeIdent.INTEGER_8:
				*(int8*)result = i;
				return;
			case TypeIdent.INTEGER_16:
				*(int16*)result = i;
				return;
			case TypeIdent.INTEGER_32:
				*(int32*)result = i;
				return;
			case TypeIdent.INTEGER_64:
				*(int64*)result = i;
				return;
			case TypeIdent.NATURAL_8:
				*(uint8*)result = n;
				return;
			case TypeIdent.NATURAL_16:
				*(uint16*)result = n;
				return;
			case TypeIdent.NATURAL_32:
				*(uint32*)result = n;
				return;
			case TypeIdent.NATURAL_64:
				*(uint64*)result = n;
				return;
			case TypeIdent.REAL_32:
				*(float*)result = d;
				return;
			case TypeIdent.REAL_64:
				*(double*)result = d;
				return;
			}
			break;
		}
	}

public errordomain ExpressionError { 
	UNKNOWN,
	REDEFINED,
	VOID_TARGET,
	NOT_IMPLEMENTED, 
	NOT_INITIALIZED, 
	NOT_FUNCTION,
	INVALID_ARGUMENTS,
	INVALID_ITEM,
	CALL_ERROR,
	NO_OBJECT,
	NO_STACK,
	UNKNOWN_TYPE,
	NO_PARENT
}

/* -------------------------------------------------------------------- */

/**
   Hashmap whose data are Eiffel reference objects which will be protected
   against memory reclamation by Eiffel's garbage collection. 
 */
public class EiffelObjects : Object {

	private unowned void*[] data;
	private uint[] counts;
	private uint last_code;

	~EiffelObjects() { free_func(data); }

	private void resize(uint n) {
		if (n<=counts.length) return;
		void* d;
		uint h, i;
		uint old_size = size;
		uint old_last_code = last_code;
		var old_data = data;
		var old_counts = counts;
		data = (void*[])realloc_func(null, n*sizeof(void*));
		*eif_results = data;
		counts = new uint[n];
		for (i=0; i<n; ++i) data[i] = null;
		for (i=0; i<old_size; ++i) {
			d = old_data[i];
			if (d==null) continue;
			h = (uint)d;
			data[h] = d;
			counts[h] = old_counts[i];
			if (i==old_last_code) last_code = h;
		}
	}

	internal uint size { get; set; }

	internal EiffelObjects(uint n=0) { clear(n); }

/**
   Does the table contain Eiffel object `obj'?
   Caution: the function has side effects on private fields:
   `last_code' is set to the found values (or to the next free slot).
 */
	internal bool contains(void* obj) {
		if (obj==null) return false;
		void* d;
		uint cap = counts.length;
		uint h = ((uint)obj) % cap;
		last_code = h;
		for (d=data[h]; d!=null; ) {
			if (d==obj) {
				return true;
			} else {
				h = (h+1) % cap;
				d = data[h];
				last_code = h;
			}
		}
		return false;
	}

/**
   Insert `obj'.
 */
	internal void add(void* obj) {
		uint cap = counts.length;
		bool ok = contains(obj);
		uint h = last_code;
		if (ok) {
			counts[h] = counts[h]+1;
		} else {
			if (2*size>cap) {
				cap = 3*size + 1;
				resize(cap);
				h = last_code;
			}
			data[h] = obj;
			counts[h] = 1;
			size = size+1;
		}
	}

/**
   Remove `obj'.
 */
	internal void remove(void* obj) {
		if (!contains(obj)) return;
		uint h0 = last_code;
		counts[h0] = counts[h0]-1;
		if (counts[h0]>0) return;
		void* d = null;
		uint cap = counts.length;
		for (uint h=(h0+1)%cap; d!=null && h!=h0; h=(h+1)%cap) {
			d = data[h];
			if (d!=null && ((uint)d)%cap==h0) {
				data[h0] = data[h];
				counts[h0] = counts[h];
				h0 = h;
			}
		} 
		data[h0] = null;
		counts[h0] = 0;
		size = size-1;
		last_code = h0;
	}

	/**
	   Remove all data.
	   @n minimum capacity to preserve.
	 */
	internal void clear(uint n=10) ensures (size==0) {
		if (n<10) n = 10;
		n = 2*n+1;
		data = (void*[])realloc_func(null, n*sizeof(void*));
		*eif_results = data;
		counts = new uint[n];
		for (uint i=0; i<n; ++i) data[i] = null;
		last_code = 0;
		size = 0;
	}

	public static void** eif_results;

} /* class EiffelObjects */

/* -------------------------------------------------------------------- */

public abstract class Expression : Object { 
	
	public enum Format { 
		EXPAND_PH = 1<<1,
		EXPAND_ALIAS = 1<<2,
		EXPAND_RANGE = 1<<3,
		INDEX_VALUE = 1<<4,
		NAME_FLAGS = (1<<5)-1,
		WITH_NAME = 1<<6,
		WITH_TYPE = 1<<7,
	}

	~Expression() { 
		if (dynamic_type!=null && dynamic_type.is_basic()) return;
		void* r = result!=null ? *(void**)result : null;
		if (r!=null) results.@remove(r);
	}

	protected uint8[] result;

	protected virtual void adjust_to_parent() requires (parent!=null) {}

	public static Expression new_named(Expression? parent, string name, 
									 Expression? args) 
		ensures (result.arg==args) {
		Expression ex;
		string alias = null;
		unichar c = name.get_char(0);
		if (!c.isalpha() && c!='?' && c!='!') alias = name;
		if (c=='[') {
			ex = new ItemExpression.named(parent, args);
		} else if (args!=null) {
			if (alias!=null) {
				if (parent==null)
					throw new ExpressionError.NO_PARENT
						("Missing parent expression.");
				ex = new OperatorExpression.named(parent, name, args);
			} else {
				ex = new TextExpression.named(name);
			}
		} else  {
			ex = new RoutineExpression.named(name, null);
			ex.arg = args;
		}
		return ex;
	}

	public static Expression new_text(Expression? parent, FeatureText* ft, 
									 Expression? args) 
	throws ExpressionError 
	requires (ft!=null && ft.result_text!=null) 
		ensures (result.arg==args) {
		Expression ex;
		var alias = ft.alias_name;
		if (alias!=null &&((Name*)parent.base_class()).has_name("SPECIAL")){
			ex = new ItemExpression(parent, args);
		} else if (ft.is_routine()) {
			var rt = (RoutineText*)ft;
			if (alias!=null) {
				if (parent==null)
					throw new ExpressionError.NO_PARENT
						("Missing parent expression.");
				if (alias=="[]") {
					if (parent.base_class().is_special()) 
						ex = new ItemExpression(parent, args);
					else
						ex = new RoutineExpression(rt, args);
				}
				else
					ex = new OperatorExpression(parent, rt, args);
			} else {
				ex = new RoutineExpression(rt, args);
			}
		} else  {
			ex = new TextExpression(ft);
			ex.arg = args;
		}
		return ex;
	}

	public static Expression new_typed(Expression? parent, 
									  Entity* e, Expression? args) 
	throws ExpressionError 
	requires (e!=null && e.type!=null && e.text!=null) 
	ensures (result.arg==args) {
		Expression ex;
		var alias = e.text.alias_name;
		if (e.is_routine() && !e.is_once()) {
			var r = (Routine*)e;
			if (alias!=null) {
				if (parent==null) {
					throw new ExpressionError.NO_PARENT
						("Missing parent expression.");
				} else {
					if (alias=="[]") {
						if (parent.dynamic_type.is_special()) 
							ex = new ItemExpression.typed(parent, args);
						else
							ex = new RoutineExpression.typed(r, args);
					} else {
						ex = new OperatorExpression.typed(parent, r, args);
					}
				}
			} else {
				ex = new RoutineExpression.typed(r, args);
			}
		} else  {
			if (alias!=null && parent==null) 
				alias = null;
			if (alias!=null && parent.dynamic_type.is_special()) {
				ex = new ItemExpression.typed(parent, args);
			} else if (e.is_once()) {
				var o = (Gedb.Once*)e;
				if (!o.is_initialized())
					throw new ExpressionError.NOT_INITIALIZED
						("Once function not yet initialized.");
				ex = new OnceExpression(o);
			} else if (e.is_constant()) {
				ex = new ConstantExpression((Constant*)e);
			} else {
				ex = new TextExpression.typed(e);
				ex.set_child(Child.ARG, args);
			}
		}
		return ex;
	}

	public static Expression? predef(string name, RoutineText* rt, System* s) {
		string lower = name.down();
		switch (lower.@get(0)) {
		case 'c':
			if ("current".has_prefix(lower)) return current(rt);
			break;
		case 'r':
			if ("result".has_prefix(lower)) return result_texted(rt);
			break;
		case 'v':
			if ("void".has_prefix(lower)) return void_constant(s);
			break;
		case 'f':
			if ("false".has_prefix(lower)) return false_constant(s);
			break;
		case 't':
			if ("true".has_prefix(lower)) return true_constant(s);
			break;
		}
		return null;
	}

	public static Expression? predef_typed(string name, Routine* r, System* s) {
		string lower = name.down();
		switch (lower.@get(0)) {
		case 'c':
			if ("current".has_prefix(lower)) return current_typed(r);
			break;
		case 'r':
			if ("result".has_prefix(lower)) return result_typed(r);
			break;
		case 'v':
			if ("void".has_prefix(lower)) return void_constant(s);
			break;
		case 'f':
			if ("false".has_prefix(lower)) return false_constant(s);
			break;
		case 't':
			if ("true".has_prefix(lower)) return true_constant(s);
			break;
		}
		return null;
	}

/**
   Create a clone of `this'.

   Create a clone of `this' including (recursively) clones of the children 
   but do not set the `parent'. 

   @return newly created `Expression'
 */
	public Expression clone() ensures (result.parent==null) {
		return clone_with_parent(null);
	}
	
/**
   Create a clone of `this'.
   
   Create a clone of `this' including (recursively) clones of the children 
   and set parent to `p'.

   @p expression to become `parent' of `this'
   @return newly created `Expression'
 */
	protected Expression clone_with_parent(Expression? p) 
	ensures (result.parent==p) {
		var t = get_type();
		var ex = @new(t) as Expression;
		ex.parent = p;
		ex.copy(this);
		for (uint i=0; i<Child.COUNT; ++i) {
			var ci = children[i];
			if (ci!=null) 
				ex.set_child(i, ci.clone_with_parent(ex));
		}
		return ex;
	}
	
/**
   Make `this' a clone of `ex'.
   
   Copy fields of `ex' to fields of `this' but do not clone children. 
   Suppose that `parent' has already been set. 

   @ex pattern to be copied
*/
	protected virtual void copy(Expression ex) {
		dynamic_type = ex.dynamic_type;
		upframe_count = ex.upframe_count;
		var r = ex.result;
		if (r!=null) {
			uint n = r.length;
			result = new uint8[n];
			copy_value(result, r, n);
		} else {
			result = null;
		}

	}
	
/**
   Create a clone of `this' with leading placeholders resolved.

   Create a clone of `this' including (recursively) clones of the children 
   but do not set the `parent'. Placeholders pointing outside will be set 
   to new targets (other placeholders are resolved internally as in `clone').

   @ph placeholders targets for outside pointing placeholders
   @return newly created `Expression'
 */
	public Expression clone_resolved(Gee.List<Expression> ph) 
	ensures (result.parent==null) {
		return expanded(null, ph);
	}
	
	protected Expression? search(Expression what, Expression where) {
		Expression? w;
		Expression? ex;
		for (ex=this, w=where; ex!=null; ex=ex.parent, w=w.parent) {
			if (w==what) return ex;
		}
		return null;
	}
	
	protected void set_constant_value(string value) {
		char c0 = value.@get(1);
		char* cp;
		string val;
		switch (_dynamic_type.ident) {
		case TypeIdent.BOOLEAN:
			*(bool*)result = c0.toupper() == 'T';
			break;
		case TypeIdent.CHARACTER_8:
			cp = (char*)result;
			*cp = c0;
			if (c0=='%') {
				cp += 1;
				*cp = (char)value.@get(2);
			}
			break;
		case TypeIdent.CHARACTER_32:
			*(unichar*)result = value.get_char(1);
			break;	
		case TypeIdent.INTEGER_64:
			val = value.down();
			if (val.length>1 && val.@get(1)=='x')
				val.scanf("0x%x", (ulong*)result);
			else
				*(ulong*)result = long.parse(value);
			break;
		case TypeIdent.NATURAL_64:
			val = value.down();
			if (val.length>1 && val.@get(1)=='x')
				val.scanf("0x%x", (ulong*)result);
			else
				*(ulong*)result = long.parse(value);
			break;
		case TypeIdent.REAL_64:
			*(double*)result = double.parse(value);
			break;
		}
	}
	
	private static ManifestExpression _false_constant;
	internal static ManifestExpression false_constant(System* s) {
		if (_false_constant==null) {
			_false_constant = 
			new ManifestExpression(s.type_at(TypeIdent.BOOLEAN), "False");
		} 
		return _false_constant;
	} 
	private static ManifestExpression _true_constant;
	internal static ManifestExpression true_constant(System* s) {
		if (_true_constant==null) {
			_true_constant = 
			new ManifestExpression(s.type_at(TypeIdent.BOOLEAN), "True");
			*(bool*)_true_constant.result = true;
		} 
		return _true_constant;
	}
	
	private static ManifestExpression _void_constant;
	internal static ManifestExpression void_constant(System* s) {
		if (_void_constant==null) {
			var t = s.type_at(TypeIdent.NONE);
			_void_constant = new ManifestExpression.typed(t, "Void");
		} 
		return _void_constant;
	}
	
	internal static Expression? current(RoutineText *rt) {
		if (rt.vars.length==0) return null;
		return new PredefExpression(rt.vars[0]);
	}
	
	internal static Expression? current_typed(Routine *r) {
		if (r.vars.length==0) return null;
		var ex = new PredefExpression.typed((Entity*)r.vars[0]);
		return ex;
	}

	internal static Expression? result_texted(RoutineText *rt) {
		if (rt._feature.result_text==null) return null;
		return new PredefExpression(rt.vars[0]);
	}
	
	internal static Expression? result_typed(Routine *r) {
		uint nr = r.argument_count;
		var res = nr<r.vars.length ? r.vars[nr] : null;
		if (res==null) return null;
		var ex = new PredefExpression.typed((Entity*)res);
		return ex;
	}
	
	private weak Expression? _parent;
	public weak Expression? parent { 
		get { return _parent; }
		protected set { _parent = value; }
	}
	
	protected Expression(uint n_bytes) {
		result = new uint8[n_bytes];
		if (results==null) results = new EiffelObjects();
	}
	
	protected enum Child { ARG, DOWN, RANGE, DETAIL, NEXT, COUNT }
	
	protected Expression children[5];	// 5 == Child.COUNT
	
	public Expression? arg { 
		get { return children[Child.ARG]; }
		private set { set_child(Child.ARG, value); }
	}
	
	public Expression? down { 
		get { return children[Child.DOWN]; }
		private set { 
			set_child(Child.DOWN, value);
			if (value!=null) value.adjust_to_parent();
		}
	}
	
	public RangeExpression? range { 
		get { return children[Child.RANGE] as RangeExpression; }
		set { set_child(Child.RANGE, value); }
	}
	
	public Expression? detail { 
		get { return children[Child.DETAIL]; }
		private set { set_child(Child.DETAIL, value); }
	}
	
	public Expression? next { 
		get { return children[Child.NEXT]; }
		private set { set_child(Child.NEXT, value); }
	}
	
	public void set_child(uint i, Expression? val) {
		if (children[i]!=null) children[i].parent = null;
		children[i] = val;
		if (val!=null) val.parent = this;
	}
	
	public Expression root() {
		return parent!=null ? parent.root() : this;
	}
	
	public weak Expression top() {
		return is_down() ? parent.top() : this;
	}
	
	public Expression bottom() {
		Expression ex, prev=this;
		for (ex=this; ex!=null; ex=ex.down) { prev = ex; }
		return prev;
	}
	
	public Expression first() {
		return is_next() ? parent.first() : this;
	}
	
	public Expression last() {
		Expression ex, prev=this;
		for (ex=this; ex!=null; ex=ex.next) { prev = ex; }
		return prev;
	}
	
	public abstract string name() ;
	public virtual string dynamic_name() { return name(); }
	public abstract ClassText* base_class() ;
	public Gedb.Type* dynamic_type { get; protected set; }
	public abstract uint8* address() ;
	
	public uint upframe_count;
	
	public bool as_bool () {
		uint8* addr = address();
		uint8 ok = addr!=null ? *(uint8*)addr : 0;
		return ok!=0;
	} 
	
	public char as_char() {
		uint8* addr = address();
		if (addr==null) return 0;
		unichar u;
		switch (dynamic_type.ident) {
		case TypeIdent.CHARACTER_8:
			return *(char*)addr;
			break;
		case TypeIdent.CHARACTER_32:
			u = *(unichar*)addr;
			if (u.to_utf8(null)==1) {
				string utf = "      ";
				u.to_utf8(utf);
				return (char)utf.data[0];
			} 
			break;
		}
		return 0;
	} 
	
	public unichar as_unichar() {
		uint8* addr = address();
		if (addr==null) return 0;
		char c;
		unichar u;
		switch (dynamic_type.ident) {
		case TypeIdent.CHARACTER_8:
			c = *(char*)addr;
			return (unichar)c;
			break;
		case TypeIdent.CHARACTER_32:
			return *(unichar*)addr;
			break;
		}
		return 0;
	}
	
	public int as_int() { return (int)as_long(); }
	
	public int64 as_long() {
		uint8* addr = address();
		if (addr==null) return 0;
		int64 i = 0;
		uint64 n;
		switch (dynamic_type.ident) {
		case TypeIdent.INTEGER_8:
			i = *(int8*)addr;
			break;
		case TypeIdent.INTEGER_16:
			i = *(int16*)addr;
			break;
		case TypeIdent.INTEGER_32:
			i = *(int32*)addr;
			break;
		case TypeIdent.INTEGER_64:
			i = *(int64*)addr;
			break;
		case TypeIdent.NATURAL_8:
			n = *(uint8*)addr;
			i = (int64)n;
			break;
		case TypeIdent.NATURAL_16:
			n = *(uint16*)addr;
			i = (int64)n;
			break;
		case TypeIdent.NATURAL_32:
			n = *(uint32*)addr;
			i = (int64)n;
			break;
		case TypeIdent.NATURAL_64:
			n = *(uint64*)addr;
			i = (int64)n;
			break;
		}
		return i;
	}
	
	public uint as_uint() { return (uint)as_ulong(); }
	
	public uint64 as_ulong() {
		uint8* addr = address();
		if (addr==null) return 0;
		int64 i;
		uint64 n = 0;
		switch (dynamic_type.ident) {
		case TypeIdent.INTEGER_8:
			i = *(int8*)addr;
			n = (uint64)i;
			break;
		case TypeIdent.INTEGER_16:
			i = *(int16*)addr;
			n = (uint64)i;
			break;
		case TypeIdent.INTEGER_32:
			i = *(int32*)addr;
			n = (uint64)i;
			break;
		case TypeIdent.INTEGER_64:
			i = *(int64*)addr;
			n = (uint64)i;
			break;
		case TypeIdent.NATURAL_8:
			n = *(uint8*)addr;
			break;
		case TypeIdent.NATURAL_16:
			n = *(uint16*)addr;
			break;
		case TypeIdent.NATURAL_32:
			n = *(uint32*)addr;
			break;
		case TypeIdent.NATURAL_64:
			n = *(uint64*)addr;
			break;
		}
		return n;
	}

	public float as_float() {
		uint8* addr = address();
		if (addr==null) return 0;
		int64 i;
		float f = 0;
		double d;
		switch (dynamic_type.ident) {
		case TypeIdent.INTEGER_8:
		case TypeIdent.INTEGER_16:
		case TypeIdent.INTEGER_32:
		case TypeIdent.INTEGER_64:
			i = as_long();
			f = (float)i;
			break;
		case TypeIdent.NATURAL_8:
		case TypeIdent.NATURAL_16:
		case TypeIdent.NATURAL_32:
		case TypeIdent.NATURAL_64:
			i = (long)as_ulong();
			f = (float)i;
			break;
		case TypeIdent.REAL_32:
			f = *(float*)addr;
			break;
		case TypeIdent.REAL_64:
			d = *(double*)addr;
			f = (float)d;
			break;
		}
		return f;
	}

	public double as_double() {
		uint8* addr = address();
		if (addr==null) return 0;
		int64 i;
		float f;
		double d = 0;
		switch (dynamic_type.ident) {
		case TypeIdent.INTEGER_8:
		case TypeIdent.INTEGER_16:
		case TypeIdent.INTEGER_32:
		case TypeIdent.INTEGER_64:
			i = as_long();
			d = (double)i;
			break;
		case TypeIdent.NATURAL_8:
		case TypeIdent.NATURAL_16:
		case TypeIdent.NATURAL_32:
		case TypeIdent.NATURAL_64:
			i = (int64)as_ulong();
			d = (double)i;
			break;
		case TypeIdent.REAL_32:
			f = *(float*)addr;
			d = (double)f;
			break;
		case TypeIdent.REAL_64:
			d = *(double*)addr;
			break;
		}
		return d;
	} 

	public void* as_pointer() { return address(); } 

	public string as_string(System* s) {
		uint8* addr = address();
		if (addr==null) return null;
		switch (dynamic_type.ident) {
		case TypeIdent.STRING_8:
			addr += s.string_offsets.area;
			addr = *(void**)addr;
			addr += s.string_offsets.item;
			break;
		case TypeIdent.STRING_32:
			addr += s.unicode_offsets.area;
			addr = *(void**)addr;
			addr += s.unicode_offsets.item;
			break;
		default:
			return null;
			break;
		}
		return (string*)addr;
	}

	public virtual bool is_placeholder() { return false; }

	public bool is_arg() { return parent!=null ? parent.arg==this : false; }
	public bool is_down() { return parent!=null ? parent.down==this : false; }
	public bool is_next() { return parent!=null ? parent.next==this : false; }
	public bool is_range() { return parent!=null ? parent.range==this : false; }
	public bool is_detail() {return parent!=null ? parent.detail==this : false;}

	public string append_name(string? to=null, uint fmt=0) {
		string here = to!=null ? to : "";
		string more;
		here = append_qualified_name(here, null, fmt);
		var b = bottom();
		var d = b.detail;
		if (b.range!=null) {
			here = b.range.append_single_name(here, fmt);
			d = b.range.detail;
		}
		if (d!=null) {
			more = d.append_name(null, fmt);
			if (more.length>0) here += " { " + more + " }";
		}
		if (next!=null) {
			more = next.append_name(null, fmt);
			if (more.length>0) here += ", " + more;
		}
		return here;
	}

	public string append_qualified_name(string? to=null, 
			Expression? up_to=null, uint fmt=0) {
		string here;
		here = append_single_name(to, fmt);
		var tex = this as TextExpression;
		if (down!=null && this!=up_to) 
			here = down.append_qualified_name(here, up_to, fmt);
		return here;
	}

	public virtual string append_single_name(string? to=null, uint fmt=0) {
		return name();
	}

 /**
	Format value of `this' including its qualifiers and arguments. 
  */
	public string format_one_value(uint fmt=0) {
		uint8* addr = address();
		Gedb.Type* t = dynamic_type;
		string str = (fmt & Format.WITH_NAME)!=0 ? 
			top().append_qualified_name(null, this, fmt) + " = " : "";
		str += format_value(addr, 0, false, t, FormatStyle.ADDRESS);
		if ((fmt & Format.WITH_TYPE)!=0 && addr!=null) {
			FeatureText* ft = null;
			var tex = this as TextExpression;
			if (tex!=null) ft = tex.text;
			str += " : " + format_type(addr, 0, false, t, ft);
		}
		return str;
	}

	private void append_item(ItemExpression rng, ref string str, 
							uint indent, uint incr, uint fmt, 
							 StackFrame* f, System* s) {
		string here = str!=null ? str : "";
		here = rng.append_next_value(here, indent, incr, fmt, f, s);
		str = here;
	}

	private string append_next_value(string to, uint indent, uint incr, 
									 uint fmt, StackFrame* f, System* s) {
		var exb = bottom();
		string str = to;
		str += indent>0 ? string.nfill(indent, ' ') : "";
		str += exb.format_one_value(fmt);
		str += "\n";
		var exa = exb as AliasExpression;
		var ex = exa!=null ? exa.alias : exb; 
		if (ex.range!=null) {
			ex.range.traverse_range((r) => 
				{ ex.append_item(r, ref str, indent+incr, incr, fmt, f, s); }, 
									f, s);
		} else if (ex.detail!=null) {
			str = ex.detail.append_next_value(str, indent+incr, incr, fmt, f, s);
		}
		if (ex.next!=null) 
			str = ex.next.append_next_value(str, indent, incr, fmt, f, s);
		return str;
	}

	public string format_values(uint indent, uint fmt, StackFrame* f, System* s) {
		return append_next_value("", indent, indent, fmt, f, s);
	}

	public delegate void ExpressionFunc(Expression ex);

	public void traverse(ExpressionFunc func, Expression? up_to=null,
						bool with_detail=true, bool with_next=true) {
		func(this);
		if (this==up_to) return;
		if (arg!=null) arg.traverse(func, up_to, with_detail, with_next);
		if (down!=null) down.traverse(func, up_to, with_detail, with_next);
		if (with_detail &&range!=null) 
			range.traverse(func, up_to, with_detail, with_next);
		if (with_detail && detail!=null) 
			detail.traverse(func, up_to, with_detail, with_next);
		if (with_next && next!=null) 
			next.traverse(func, up_to, with_detail, with_next);
	}

	public bool clean_up() {
		Expression? ex;
		if (address()==null) return false;
		for (int i=0; i<Child.COUNT; ++i) {
			ex = children[i];
			if (ex!=null && !ex.clean_up()) children[i] = null;
		}
		return true;
	}

	public bool cut_before(Expression ex) requires (ex!=this) {
		int i;
		for (i=Child.COUNT; i-->0;) {
			if (children[i]==ex) { 
				children[i] = null;
				return true;
			} 
		}
		for (i=Child.COUNT; i-->0;) 
			if (children[i]!=null && children[i].cut_before(ex)) return true;
		return false;
	}

	public void cut_children(bool preserve_simple) {
		next = null;
		detail = null;
		range = null;
		if (!preserve_simple) {
			down = null;
			arg = null;
		}
		if (arg!=null) arg.cut_children(preserve_simple);
		if (down!=null) down.cut_children(preserve_simple);
	}

	protected static EiffelObjects results;

	internal virtual Expression? resolve_alias() { return this; }

	public bool uses_alias(string name) {
		var ci = this as AliasExpression;
		string cnm = ci!=null ? ci.name() : null;
		if (cnm==name) return true;
		for (uint i=0; i<Child.COUNT; ++i) {
			ci = children[i] as AliasExpression;
			if (ci==null) continue;
			cnm = ci.name();
			if (cnm==name) return true;
		}
		return false;
	}

	internal Expression expanded(Expression? p, Gee.List<Expression> pl) {
		var ex = resolved(p, pl);
		if (ex==null) return null;
		Expression? ci, cx;
		int n = pl.size;
		for (uint i=0; i<Child.COUNT; ++i) {
			ci = children[i];
			if (ci!=null) {
				switch (i) {
				case Child.RANGE:
					pl.insert(n, ex);
					break;
				case Child.DETAIL:
					if (!is_range()) {
						pl.insert(n, ex);
					}
					break;
				}
				cx = ci.expanded(ex, pl);
				ex.set_child(i, cx);
				switch (i) {
				case Child.RANGE:
					pl.remove_at(n);
					break;
				case Child.DETAIL:
					if (!is_range()) {
						pl.remove_at(n);
					}
					break;
				}
			}
		}
		return ex;
	}

/**
   Create a clone of `this' such that `name()' denotes an Eiffel entity.

   Create a clone of `this' (without cloning children) 
   such that `name()' corresponds to an Eiffel entity. 
   The Eiffel entity is searched in the class or type of `p' (if not void) 
   then in `f' if not found.
   
   @p already resolved new parent, used to resolve the name 
   @f `StackFrame' to resolve the name  
   @return new `Expression' if name was resolved, `null' else 
 */
	protected virtual Expression resolved(Expression? p, 
		Gee.List<Expression> pl) 
//	ensures (result==null || result.parent==p) 
	{	// workaround
		var t = get_type();
		var ex = @new(t) as Expression;
		ex.parent = p;
		ex.copy(this);
		return ex;
	}

	public bool static_check(ClassText* ct, RoutineText* rt, 
							 System* s, StackFrame* f) 
//	requires ((ct!=null && rt!null) || (f!=null && s!=null)) {
	requires (ct!=null) { // workaround
		uint n = 0;
		bool ok = true;
		if (ct==null) {
			if (is_down()) {
				ct = parent.base_class();
			} else {
				if (f!=null) {
					ct = s.class_at(f.class_id);
					rt = f.routine.routine_text();
				}
			}
		}
		if (!(this is EqualityExpression)) {
			ct.query_by_name(out n, name(), arg==null, rt);
			if (n!=1) return false;
		}
		Expression? ci;
		for (uint i=0; i<Child.COUNT; ++i) {
			ci = children[i] as AliasExpression;
			if (ci==null) continue;
			ok = ci.static_check(ct, rt, s, f);
			if (!ok) return false;
		}
		return ok;
	}

 /**
	Adjust the description of `this' when computed as a field 
	of an object of dynamic type `pt' or as local variable of routine `r'. 
	Default action: do nothing.
  */
	protected abstract bool set_dyn_type(Gedb.Type* pt, StackFrame* f);

 /**
	Compute `this' as field of an object at `addr', 
	or within `f' if the field is a local variable,
	or else get its value as a global variable.
  */
	protected abstract void compute(uint8* addr, StackFrame* f, System* s) 
	throws ExpressionError;

 /**
	Compute a query of an object. This includes the computation 
	of the `arg', `down', `range', `detail', and `next' expressions. 
	@object Address of object one of whose queries is to be computed
		(`null' in case of local variables)
	@t Static type of `object' (needed for objects with type info missing)
	@s System to obtain dynamic type from static type
	@f stack frame to compute local variables 
		and as start object for `arg' and 'next' when `object==null'
	@env alternative start object for `arg' and `next' 
		when `object==null' and `f==null'
  */
	public void compute_in_object(uint8* object, Gedb.Type* t, System* s, 
								 StackFrame* f, uint8* env=null) 
	throws ExpressionError 
	requires ((object!=null && t!=null) || f!=null || env!=null
 //			&& (t.is_subobject() || s.type_of_any(object).conforms_to(t))) {
		) {	// workaround
		ExpressionError? error = null;
		if (arg!=null) 
			try {
				arg.compute_in_object(null, t, s, f, env);
			} catch (ExpressionError e) {
				stderr.printf("%s\n", e.message);
				if (is_down()) parent.down = null;
 /*
				else throw e;
 */
			}
		uint8* addr = object;
		Routine* r = f!=null ? f.routine : null;
		var aex = this as AliasExpression;
		if (object==null) {
			if (f!=null) {
				addr = target(f);
				t = f.target_type();
			} else if (env!=null) {
				addr = env;
				t = s.type_of_any(env);
			}
		} else {
			if (!t.is_subobject()) t = s.type_of_any(object);
		}
		bool ok = aex!=null;
		if (!ok && is_down()) t = parent.dynamic_type;
		ok = set_dyn_type(t, f);
		if (!ok && env!=null && f!=null) {	// try again in fallback mode
			addr = env;
			t = s.type_of_any(env);
			ok = set_dyn_type(t, f);
		}
		if (!ok) throw new ExpressionError.UNKNOWN 
			("Unknown feature `"+name()+"'");
		compute(addr, f, s);
		addr = address();
		if (addr!=null) {
			dynamic_type = s.type_of_any(addr, dynamic_type);
			if (down!=null) {
				if (addr!=null || dynamic_type.is_subobject()) {
					if (t.is_agent()) {
						var ag = (AgentType*)dynamic_type;
						addr = ag.closed_operands(addr);
					}
					down.compute_in_object(addr, dynamic_type, s, f, env);
				}
			}
			if (range!=null) {
				range.compute_in_object(addr, dynamic_type, s, f, env);
			}
			if (detail!=null) {
				detail.compute_in_object(addr, dynamic_type, s, f, env);
			}
		}
		if (next!=null) {
			next.compute_in_object(null, t, s, f, env);
		}
		if (error!=null) throw error;
	}

 /**
	Compute value of a variable located on stack (possibly `Current')
	@f StackFrame where `Current' resides
	@cut_void Whether `this' is to be cut when a void target is encountered
  */
	public void compute_in_stack(StackFrame* f, System* s) 
	throws ExpressionError requires (f!=null) {
		compute_in_object(null, f.target_type(), s, f);
	}

	public bool compare_to(Expression right, bool as_ref=false) {
		Gedb.Type* rt = right.dynamic_type;		
		uint8* addr = address();
		switch (dynamic_type.ident) {
		case TypeIdent.BOOLEAN:
			return as_bool() == right.as_bool();
		case TypeIdent.CHARACTER_8:
		case TypeIdent.CHARACTER_32:
			return as_char() == right.as_char();
		case TypeIdent.INTEGER_8:
		case TypeIdent.INTEGER_16:
		case TypeIdent.INTEGER_32:
		case TypeIdent.INTEGER_64:
			return as_long() == right.as_long();
		case TypeIdent.NATURAL_8:
		case TypeIdent.NATURAL_16:
		case TypeIdent.NATURAL_32:
		case TypeIdent.NATURAL_64:
			return as_ulong() == right.as_ulong();
		case TypeIdent.REAL_32:
			return as_float() == right.as_float();
		case TypeIdent.REAL_64:
			return as_double() == right.as_double();
		case TypeIdent.POINTER:
			return as_pointer() == right.as_pointer();
		default:
			if (!as_ref || rt.is_subobject()) {
				uint8* l_addr = address();
				uint8* r_addr = right.address();
				for (uint i=rt.instance_bytes; i-->0;)
					if (l_addr[i]!=r_addr[i]) return false;
				return true;
			} else {
				return address() == right.address();
			}
			break;
		}
		return false;
	}

	public void to_integer(System* rts) requires (dynamic_type.is_natural()) {
		switch (dynamic_type.ident) {
		case TypeIdent.NATURAL_8:
			_dynamic_type = rts.type_at(TypeIdent.INTEGER_8);
			break;
		case TypeIdent.NATURAL_16:
			_dynamic_type = rts.type_at(TypeIdent.INTEGER_16);
			break;
		case TypeIdent.NATURAL_32:
			_dynamic_type = rts.type_at(TypeIdent.INTEGER_32);
			break;
		case TypeIdent.NATURAL_64:
			_dynamic_type = rts.type_at(TypeIdent.INTEGER_64);
			break;
		}
	}

 }

 /* -------------------------------------------------------------------- */

 public class TextExpression : Expression {

	internal string work_name { get; protected set; }

	protected override void copy(Expression ex) {
		base.copy(ex);
		var tex = ex as TextExpression;
		entity = tex._entity;
		_text = tex._text;
		work_name = tex.work_name;
	}

	protected virtual void adjust_to_parent() {
		ClassText* ct = null;
		var p = parent as TextExpression;
		if (p==null) return;
		var pe = p.entity;
		if (pe==null) {
			invalidate();
			return;
		}
		uint n;
		if (pe.type.is_tuple()) {
			var tt = (TupleType*)pe.type;
			entity = (Entity*)tt.item_by_label(name(), p.text, out n);
		} else {
			var e = pe.type.query_by_name(out n, name(), arg==null);
			entity = n==1 ? e : null;
		}
		if (down!=null) down.adjust_to_parent();
	}

	private void invalidate() {
		TextExpression? ex;
		for (int i=0; i<Child.NEXT; ++i) {
			ex = children[i] as TextExpression;
			if (ex!=null) {
				ex.result = null;
				ex.entity = null;
			}
		}
	}

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		string name = text!=null ? text._name.fast_name : work_name;
		name = name.down();
		uint n;
		Entity* e;
		for (uint i=upframe_count; i-->0;) {
			if (f==null) 
				throw new ExpressionError.NO_STACK ("No valid stack frame.");
			f = f.caller;
		}
		Routine* r = f!=null ? f.routine : null;
		if (pt==null) 
			pt = r.vars[0]._entity.type;
		e = pt.query_by_name(out n, name, arg==null, r);
		if (n==1 && e!=entity) invalidate();
		entity = e;
		n = (uint)sizeof(void*);
		if (n>result.length) result = new uint8[n];	
		return e!=null;
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s) 
	throws ExpressionError {
		if (entity==null) 
			throw new ExpressionError.UNKNOWN ("Unknown feature "+name()+".");
		else if (entity.is_routine()) 
			throw new ExpressionError.REDEFINED ("Feature "+name()+" redefined."); 
		for (uint i=upframe_count; i-->0;) {
			if (f==null) 
				throw new ExpressionError.NO_STACK ("No valid stack frame.");
			f = f.caller;
		}
		Entity* e = entity;
		uint8* addr = null;
		int off = 0;
		if (e.is_local()) {
			addr = (uint8*)f;
			off = ((Local*)e).offset;
		} else {
			addr = obj;
			if (is_down() && parent.dynamic_type.is_agent()) {
				var t = parent.dynamic_type;
				var at = (AgentType*)t;
				var dt = (Gedb.Type*)at.declared_type;
				var cot = (Gedb.Type*)at.closed_operands_tuple;
				if (e!=(Entity*)t.fields[t.field_count()-1]) {
					off = dt.fields[0].offset;
					addr = cot.dereference(addr+off);
				}
			}
			off = ((Field*)e).offset; 
		}
		addr += off;
		addr = e.type.dereference(addr);
		*(void**)result = addr;
	}

	public FeatureText* text { get; internal set; }

	protected Entity* _entity;
	public Entity* entity { 
		get { return _entity; }
		internal set {
			_entity = value;
			dynamic_type = value!=null ? value.type : null;
		}
	}

	public TextExpression.named(string name) { 
		base(0);
		work_name = name;
	}

	public TextExpression(FeatureText* ft) requires (ft!=null) { 
		base((uint)sizeof(void*));
		text = ft;
		work_name = ft._name.fast_name;
	}

	public TextExpression.typed(Entity* e) 
	requires (e!=null && e.text!=null) {
		this(e.text);
		entity = e;
	}

	public TextExpression.computed(Entity* e, void* obj, System *s) 
	requires (e!=null && !e.type.is_subobject() 
			  && s.type_of_any(obj).conforms_to(e.type)) {
		this.typed(e);
		*(void**)result = obj;
	}

	public override string name() { 
		return entity!=null 
			? entity._name.fast_name 
			: (_text!=null ? _text._name.fast_name : work_name);
	}

	public override string dynamic_name() { 
		var e = entity;
		return e!=null ? e._name.fast_name : name();
	}

	public override ClassText* base_class() { 
		return _text!=null ? _text.result_text : null;
	}

	public override uint8* address() { 
		if (entity==null || result==null) return null;
		return *(void**)result;
	}

	public override string append_single_name(string? to, uint fmt=0) {
		var here = to!=null ? to : "";
		fmt &= Format.NAME_FLAGS;
		var txt = entity!=null ? entity.text : _text;
		string nm = txt!=null ? txt.alias_name : null;
		if (nm==null) nm = name();
		var pt = parent!=null ? parent.dynamic_type : null;
		if (is_down() && pt!=null) {
			if (pt.is_tuple()) {
				var tex = parent.resolve_alias() as TextExpression;
				if (tex!=null) {
					var labels = tex.text.tuple_labels;
					if (labels!=null) {
						// remove prefix "item_":
						nm = txt._name.fast_name.substring(5);	
						int i = int.parse(nm)-1;
						nm = labels[i]._name.fast_name;
					}
				}
			} else if (pt.is_agent()) {
				nm = entity._name.fast_name;
			}
		} 
		if (is_down()) {
			Expression p = parent;
			bool no_dot = false;
			if (here==bullet || here=="Current" ) {
				here = "";
				no_dot = true;
			} else {
				no_dot = pt!=null && pt.is_special() && arg!=null;
			}
			if (!no_dot) nm = "." + nm;
		} else if (upframe_count>0) {
			if (upframe_count<=3) 
				here += string.nfill(upframe_count, '^');
			else
				here += "^%u^".printf(upframe_count);
		} else if (_entity!=null) {
			ClassText* ct = null;
			if (_entity.is_constant()) {
				ct = ((Constant*)_entity).home;
			} else if (_entity.is_once()) {
				ct = ((Gedb.Once*)_entity).home;
			}
			if (ct!=null)
				nm = "{" + ct._name.fast_name + "}." + nm;
		}
		here += nm;
		return here;
	}

 }

 /* -------------------------------------------------------------------- */

 public class PredefExpression : TextExpression {

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		Routine* r = f.routine;
		uint nr = name().@get(0)=='C' ? 0 : r.argument_count;
		entity = nr<r.vars.length ? (Entity*)r.vars[nr] : null;
		return entity!=null;
	}

	public PredefExpression(FeatureText* ft) requires (ft!=null) { 
		base(ft);
	}

	public PredefExpression.typed(Entity* e) requires (e!=null) {
		base.typed(e);
	}

 }

 /* -------------------------------------------------------------------- */

 public class RoutineExpression : TextExpression {

	protected void check_args(bool typed) 
	throws ExpressionError 
		requires (entity!=null && entity.is_routine()) {
		Routine* r = (Routine*)entity;
		Entity* e;
		Expression a, ab;
		uint i, n = r.argument_count;
		for (i=1, a=arg; a!=null; a=a.next) ++i;
		if (i<n)
			throw new ExpressionError.INVALID_ARGUMENTS
				("%u too less function arguments.".printf(n-i));
		else if (i>n)
			throw new ExpressionError.INVALID_ARGUMENTS
				("%u too many function arguments.".printf(i-n));
		if (!typed) return;
		for (a=arg, i=1; a!=null && i<n; a=a.next, ++i) {
			ab = a.bottom();
			e = (Entity*)r.vars[i];
			if (!e.is_assignable_from(ab.dynamic_type)) 
				throw new ExpressionError.INVALID_ARGUMENTS
					(@"Argument $i is does not conform to formal type.");
		}
		for (a=arg; a!=null; a=a.next) {
			if (a.down!=null) a.down.adjust_to_parent();
		} 
	}

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		base.set_dyn_type(pt, f);
		if (entity==null) return false;
		uint n = entity.type.field_bytes();		
		if (n>result.length) new uint8[n];
		return true;
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s)
	throws ExpressionError {
		if (entity.is_field()) {	// function redefined as attribute
			base.compute(obj, f, s);
		} else {
			Expression? ex;
			Local* l;
			var r = (Routine*)entity;
			uint k, n = r.argument_count;
			int old_range, vi;
			check_args(true);
			void*[] addresses = n>1 ? new void*[n-1] : null;
			try {
				for (k=0, ex=arg; ex!=null; ex=ex.next, ++k) 
					addresses[k] = ex.bottom().address();
				wrap_func(r.wrap, r.call, obj, &addresses[0], result);
			} catch (Error err) {
				throw new ExpressionError.CALL_ERROR
					("Error in called function.");
			}
		}
		if (!dynamic_type.is_subobject()) results.@add(*(void**)result);
	}

	public RoutineExpression.named(string name, Expression? args) {
		base.named(name);
		set_child(Child.ARG, args);
	}

	public RoutineExpression(RoutineText* rt, Expression? args) {
		base((FeatureText*)rt);
		set_child(Child.ARG, args);
	}

	public RoutineExpression.typed(Routine* r, Expression? args) 
	throws ExpressionError {
		base.typed((Entity*)r);
		if (!dynamic_type.is_basic()) result = null;
		set_child(Child.ARG, args);
		check_args(false);
	}

	public override uint8* address() {
		if (entity.is_field()) return base.address();
		return (uint8*)dynamic_type.dereference((uint8*)result);
	}

	public override string append_single_name(string? to, uint fmt=0) {
		Expression arg_i;
		string here;
		var pt = parent!=null ? parent.dynamic_type : null;
		if (arg!=null) {
			bool bracket = text.alias_name=="[]";
			bool need_comma=false;
			if (bracket) {
				here = to!=null ? to : "";
				here += " [";
			} else {
				here = base.append_single_name(to, fmt);
				here += " (";
			}
			for (arg_i=arg; arg_i!=null; arg_i=arg_i.next) {
				if (need_comma) here += ", ";
				here += arg_i.append_single_name(null, fmt);
				need_comma = true;
			}
			here += bracket ? "]" : ")";
		} else {
			here = base.append_single_name(to, fmt);
		}
		return here;
	}

	public uint hash() { return (uint)this; }
	public bool equal_to(Object obj) { return this==obj; }
 }

 /* -------------------------------------------------------------------- */

 public interface Operatable : Expression {

	public abstract uint op_code { get; set; }
	public abstract uint prec { get; set; }

	protected void set_operator(string name, bool prefix=false) {
		switch (name) {
		case "not":
			op_code = OpCode.not;
			prec = 12;
			break;
		case "&":
			op_code = OpCode.bit_and;
			prec = 11;
			break;
		case "|":
			op_code = OpCode.bit_or;
			prec = 11;
			break;
		case "|<<":
			op_code = OpCode.l_shift;
			prec = 11;
			break;
		case "|>>":
			op_code = OpCode.r_shift;
			prec = 11;
			break;
		case "^":
			op_code = OpCode.power;
			prec = 10;
			break;
		case "*":
			op_code = OpCode.mult;
			prec = 9;
			break;
		case "/":
			op_code = OpCode.div;
			prec = 9;
			break;
		case "//":
			op_code = OpCode.idiv;
			prec = 9;
			break;
		case "\\\\":
			op_code = OpCode.imod;
			prec = 9;
			break;
		case "+":
			op_code = OpCode.plus;
			prec = prefix ? 12 : 8;
			break;
		case "-":
			op_code = OpCode.minus;
			prec = prefix ? 12 : 8;
			break;
		case "..":
			op_code = OpCode.interval;
			prec = 7;
			break;
		case "=":
			op_code = OpCode.eq;
			prec = 6;
			break;
		case "/=":
			op_code = OpCode.ne;
			prec = 6;
			break;
		case "/~":
			op_code = OpCode.nsim;
			prec = 6;
			break;
		case "<":
			op_code = OpCode.lt;
			prec = 6;
			break;
		case ">":
			op_code = OpCode.gt;
			prec = 6;
			break;
		case "<=":
			op_code = OpCode.le;
			prec = 6;
			break;
		case ">=":
			op_code = OpCode.ge;
			prec = 6;
			break;
		case "and":
			op_code = OpCode.and;
			prec = 5;
			break;
		case "and then":
			op_code = OpCode.and_then;
			prec = 5;
			break;
		case "or":
			op_code = OpCode.or;
			prec = 4;
			break;
		case "or else":
			op_code = OpCode.or_else;
			prec = 4;
			break;
		case "xor":
			op_code = OpCode.xor;
			prec = 4;
			break;
		case "implies":
			op_code = OpCode.implies;
			prec = 3;
			break;
		default:
			op_code = prefix ? OpCode.free1 : OpCode.free2;
			prec = 11;
			break;
		}
	}

	public string format(string lhs, Expression ex, uint fmt=0) {
		string here = "";
		var tex = ex as TextExpression;
		var name = ex.name();
		if (tex!=null && tex.text!=null) name = tex.text.alias_name;
		var po = ex.parent as Operatable;
		uint op = op_code;
		uint pr = prec;
		if (ex.arg==null) { 
			if (po!=null) {
				if (po.prec<pr) 
					here = @"($lhs)";
				else 
					here += @" $lhs";
			} else {
				if (op!=OpCode.pos && op!=OpCode.neg) here = " ";
				here += @"$lhs";
			}
			here = name + here;
		} else { 
			here = lhs;
			if (po!=null  
				&& (po.prec<pr | (po.prec==pr && op==OpCode.power)))
				here = "(" + here + ")";
			string rhs = ex.arg.append_qualified_name(null, null, fmt);
			var ao = ex.arg.bottom() as Operatable;
			if (ao!=null
				&& (ao.prec<pr || (ao.prec==pr && op!=OpCode.power)))
				rhs = "(" + rhs + ")";
			here = here + " " + name + " " + rhs;
		}
		return here;
	}

 }

 /* -------------------------------------------------------------------- */

 public class OperatorExpression : RoutineExpression, Operatable {

	protected override void copy(Expression ex) {
		base.copy(ex);
		var oex = ex as OperatorExpression;
		_op_code = oex.op_code;
		_prec = oex.prec;
	}

	protected virtual uint op_code { get; set; }
	protected virtual uint prec { get; set; }

	private void compute_basic_prefix() 
	requires (parent.dynamic_type.is_basic())
	requires (prec==11 || prec==12)
	requires (arg==null) {
		var pt = parent.dynamic_type;
		uint8* left = parent.result;
		uint n = pt.field_bytes();
		switch(op_code) {
		case OpCode.not:
			*(bool*)result = ! parent.as_bool();
			break;
		case OpCode.neg:
			switch (pt.ident) {
			case TypeIdent.INTEGER_8:
				*(int8*)result = - (int8)parent.as_int();
				break;
			case TypeIdent.INTEGER_16:
				*(int16*)result = - (int16)parent.as_int();
				break;
			case TypeIdent.INTEGER_32:
				*(int32*)result = - parent.as_int();
				break;
			case TypeIdent.INTEGER_64:
				*(int64*)result= - parent.as_long();
				break;
			case TypeIdent.REAL_32:
				*(float*)result = - parent.as_float();
				break;
			case TypeIdent.REAL_64:
				*(double*)result = - parent.as_double();
				break;
			default:
				break;
			}
			break;
		}
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s)
	throws ExpressionError {
		var t = entity.type;
		if (t.is_basic() && 0<op_code && op_code<OpCode.free1) {
			if (arg==null) {
				compute_basic_prefix();
			} else {
				var ab = arg.bottom();
				switch (op_code) {
				case OpCode.and_then:
					*(bool*)result = !parent.as_bool() ? false : ab.as_bool();
					return;
				case OpCode.or_else:
					*(bool*)result = parent.as_bool() ? true : ab.as_bool();
					return;
				}
				compute_basic_infix(parent.dynamic_type, parent.address(), 
									ab.dynamic_type, ab.address(), 
									op_code, result);
			}
		} else {
			base.compute(obj, f, s);
		}
	}

	public OperatorExpression.named(Expression lhs, string name, Expression? rhs) {
		base.named(name, rhs);
		set_operator(name);
		lhs.set_child(Child.DOWN, this);
	}

	public OperatorExpression(Expression lhs, RoutineText* rt, Expression? rhs) 
	requires (rt!=null) ensures (lhs.down==this) { 
		base(rt, rhs);
		set_operator(text.alias_name);
		lhs.set_child(Child.DOWN, this);
	}

	public OperatorExpression.typed(Expression lhs, Routine* r, Expression? rhs) 
	requires (r!=null) ensures (lhs.down==this) { 
		base.typed(r, rhs);
		set_operator(text.alias_name, rhs==null);
		lhs.set_child(Child.DOWN, this);
	}

	public override string append_single_name(string? to, uint fmt=0) {
		string here = to!=null ? to : "";
		return format(here, this, fmt);
	}

 }

 /* -------------------------------------------------------------------- */

 public class EqualityExpression : Expression, Operatable {

	private bool ok;
	private string _name;

	protected override void copy(Expression ex) {
		base.copy(ex);
		var qex = ex as EqualityExpression;
		_name = qex._name;
		_op_code = qex.op_code;
		_prec = qex.prec;
		ok = qex.ok;
	}

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		return true;
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s) 
	throws ExpressionError {
		ok = parent.compare_to(arg, op_code==OpCode.eq || op_code==OpCode.ne);
		if (op_code==OpCode.ne) ok = !ok;
		return;
	}

	public uint op_code { get; protected set; }	
	public uint prec { get; set; }

	public EqualityExpression(Expression lhs, string name, Expression rhs, 
		Gedb.Type* bool_type) { 
		base(0);
		set_operator(name);
		lhs.set_child(Child.DOWN, this);
		set_child(Child.ARG, rhs);
		_name = name;
		dynamic_type = bool_type;
	}

	public override string name() { return _name; }

	public override ClassText* base_class() { 
		return dynamic_type.base_class;
	}

	public override uint8* address() { 
		void* addr = &ok;
		return (uint8*)addr;
	}

	public override string append_single_name(string? to, uint fmt=0) {
		return format(to, this, fmt);
	}

 }

 /* -------------------------------------------------------------------- */

 public class OnceExpression : TextExpression {

	public OnceExpression(Gedb.Once* o) 
	requires (o.is_function) requires (o.is_initialized()) {
		base.typed((Entity*)o);
	}

	public override uint8* address() { 
		var o = (Gedb.Once*)entity;
		uint8* addr = (uint8*)o.value_address;
		return dynamic_type.dereference(addr);
	}

	public override string append_single_name(string? to, uint fmt=0) {
		string nm;
		if (is_down()) {
			nm = base.append_single_name(to, fmt);
		} else {
			var o = (Gedb.Once*)entity;
			nm =  "{" + o.home._name.fast_name + "}." + name();
		}
		return nm;
	}

 }

 /* -------------------------------------------------------------------- */

 public class ConstantExpression : TextExpression {

	public ConstantExpression(Constant* c) { base.typed((Entity*)c); }

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		return true;
	}

	protected override void compute(uint8* obj, Gedb.Type* t, System* s) 
	throws ExpressionError {}

	public override uint8* address() { 
		var c = (Constant*)entity;
		void* addr = dynamic_type.is_basic() ?
			&c.basic : dynamic_type.dereference(c.ms);
		return (uint8*)addr;
	}

	public override string append_single_name(string? to, uint fmt=0) {
		string nm;
		if (is_down()) {
			nm = base.append_single_name(to, fmt);
		} else {
			var c = (Constant*)entity;
		    nm = "{" + c.home._name.fast_name + "}." + name();
		}
		return nm;
	}

 }

 /* -------------------------------------------------------------------- */

 public class ItemExpression : TextExpression {

	private bool implicit;
	internal Expression special;

	protected override void copy(Expression ex) {
		base.copy(ex);
		var iex = ex as ItemExpression;
		special = search(iex.special, ex);
		cls = iex.cls;
		special_type = iex.special_type;
		implicit = iex.implicit;
		_index = iex.index;
	}

	protected void set_type_and_class() {
		var old = special_type;
		special_type = (SpecialType*)special.dynamic_type;
		if (special_type==old || special_type==null) return;
		var it = special_type.item_type();
		cls = it.base_class;
		entity = (Entity*)special_type.item_0();
	}

	protected ClassText* cls;

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		set_type_and_class();
		if (special_type!=null) entity = (Entity*)special_type.item_0();
		return entity!=null;
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s)
	throws ExpressionError {
		if (implicit) index = arg.bottom().as_int();
	}

	protected ItemExpression.fixed(Expression array) 
	requires (array.base_class()._name.fast_name=="SPECIAL") {
		uint n;
		var bc = array.base_class();
		var item = bc.query_by_name(out n, "item", false, null);
		if (n!=1) item = null;
		base(item);
		special = array;
		set_type_and_class();
	}

	public ItemExpression.named(Expression array, Expression? idx) 
	ensures (arg==idx) {
		base.named("[]");
		special = array;
		set_child(Child.ARG, idx);
		implicit = idx!=null;
	}

	public ItemExpression(Expression array, Expression idx) 
	requires (array.base_class()._name.fast_name=="SPECIAL") 
	ensures (arg==idx) {
		this.fixed(array);
		set_child(Child.ARG, idx);
		implicit = true;
	}

	public ItemExpression.typed(Expression array, Expression idx) 
	requires (array.dynamic_type.is_special()) 
	ensures (arg==idx) {
		this.fixed(array);
		set_child(Child.ARG, idx);
		implicit = true;
	}

	public ItemExpression.computed(Expression array, uint idx, System* s) 
	requires (array.dynamic_type.is_special()) {
		this.fixed(array);
		index = (int)idx;
	}

	public override string name() { return implicit ? "[]" : @"[$index]"; }

	public override ClassText* base_class() { return cls; }

	public override uint8* address() { 
		uint8* addr = special.address();
		if (addr==null) return null;
		if (special_type==null) set_type_and_class();
		if (special_type==null) return null;
		addr = 0<=index && index<size() 
			? special_type.item_type().dereference
				(addr+special_type.item_offset(index))
			: null;
		return addr;
	}

	public override string append_single_name(string? to, uint fmt=0) {
		string here;
		if ((fmt&Format.INDEX_VALUE)!=0 || arg==null) {
			here = @"$index";
		} else {
			here = arg.append_qualified_name(null, null, fmt);
		}
		here = "[" + here + "]";
		if (to!=null) here = to+here;
		return here;
	}

	public int index { 
		get; 
		protected set; }

	public SpecialType* special_type { get; private set; }

	public uint size() {
		set_type_and_class();
		if (special_type==null) return 0;
		var addr = special.address();
		return addr!=null ? special_type.special_count(addr) : 0;
	}

 }

 /* -------------------------------------------------------------------- */

 public class RangeExpression : ItemExpression {

	private ClassText* cls;
	private uint item_size;

	protected override void copy(Expression ex) {
		base.copy(ex);
		var rex = ex as RangeExpression;
		cls = rex.cls;
		item_size = rex.item_size;
		_code = rex._code;
	}

	protected override Expression resolved(Expression? p, 
		Gee.List<Expression> pl) {
		var rex = base.resolved(p, pl) as RangeExpression;
		rex.set_type_and_class();
		return rex;
	}

	public RangeCode code { get; set; }
	public uint item_count { get; private set; }

	public RangeExpression.named(Expression array) {
		base.named(array, null);
		index = -1;
		array.range = this;
		work_name = "[[]]";
	}

	public RangeExpression(Expression array) 
		requires (array.base_class()._name.fast_name=="SPECIAL") 
		ensures (array.range==this) {
		base.fixed(array);
		cls = array.base_class();
		index = -1;
		array.range = this;
		work_name = "[[]]";
	}

	public override string append_single_name(string? to, uint fmt=0) {
		if (index>=0)
			return base.append_single_name(to,fmt);
		var arg_i = arg;
		var here = to!=null ? to : "";
		here += " [[";
		switch (code) {
		case RangeCode.interval:
			here += arg_i.append_qualified_name(null, null, fmt);
			here += " : ";
			arg_i = arg_i.next;
			here += arg_i.append_qualified_name(null, null, fmt);
				break;
		case RangeCode.dollar:
			here += arg_i.append_qualified_name(null, null, fmt);
			here += " $ ";
			arg_i = arg_i.next;
			here += arg_i.append_qualified_name(null, null, fmt);
			break;
		case RangeCode.all:
			here += "all";
			break;
		case RangeCode.iff:
			here += "if ";
			here += arg_i.append_qualified_name(null, null, fmt);
			break;
		default:
			break;
		}
		here += "]]";
		return here;
	}

	public delegate void RangeFunc(ItemExpression rng);

	public ItemExpression as_item(StackFrame* f) {
		var item = new ItemExpression.fixed(special);
		item.index = index;
		item.parent = parent;
		if (detail!=null) 
			item.set_child(Child.DETAIL, detail.clone_with_parent(item));
		return item;
	}

	public void traverse_range(RangeFunc func, StackFrame* f, System* s, 
							 uint8* env=null, bool new_item=false) 
	throws ExpressionError {
		item_count = 0;
		uint8* addr = parent.address();
		if (addr==null) return;
		Gedb.Type* t = parent.dynamic_type;
		Expression p = (!) parent;
		Expression? exif = null;
		ItemExpression item;
		int first = 0, beyond = 0, max = (int)size();
		switch (code) {
		case RangeCode.interval:
			first = arg.bottom().as_int();
			beyond = arg.next.bottom().as_int() + 1;
			break;
		case RangeCode.dollar:
			first = arg.bottom().as_int();
			beyond = arg.next.bottom().as_int() + first;
			break;
		case RangeCode.all:
			beyond = max;
			break;
		case RangeCode.iff:
			exif = arg.bottom();
			beyond = max;
			break;
		}
		if (beyond>max) beyond = max;
		for (int i=first; i<beyond; ++i) {
			index = i;
			if (exif!=null) {
				exif.top().compute_in_object(addr, t, s, f, env);
				if (exif!=null && !exif.dynamic_type.is_boolean()) continue;
				if (!exif.as_bool()) continue;
			}
			item = this; //new_item ? as_item(f) : this;
			item.compute_in_object(parent.address(), t, s, f, env);
			func(item);
			item_count++;
		}
	}

}

 /* -------------------------------------------------------------------- */

 public class ManifestExpression : Expression {

	protected override void copy(Expression ex) {
		base.copy(ex);
		var mex = ex as ManifestExpression;
		_name = mex._name;
	}

	private string _name;

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		return true;
	}

	protected override void compute(uint8* obj, Gedb.Type* t, System* s) 
	throws ExpressionError {}

	public ManifestExpression(Gedb.Type *t, string value) 
	requires (t.is_basic()) {
		base((uint)sizeof(double));
		_name = value;
		dynamic_type = t;
		set_constant_value(value);
	}

	public ManifestExpression.string(Gedb.Type* t, string value) 
	requires (t.is_string()) {
		base((uint)sizeof(void*));
		dynamic_type = t;
		_name = value;
		uint8* str = (uint8*)t.new_instance(true);
		*(uint8**)result = str;
		results.@add(str);
		int l = value.length-2;
		if (l<=0) return;
		string bar = value.slice(1, l+1);
		Field* f = t.field_by_name("count");
		uint8* addr = str+f.offset;
		*(int*)addr = l;
		f = t.field_by_name("area");
		addr = str+f.offset;
		var st = (SpecialType*)f._entity.type;
		f = st.item_0();
		str = st.new_array(l);
		copy_value(str+f.offset, ((uint8*)bar), l+1);
		*(void**)addr = str;
		l = 0;
	}

	public ManifestExpression.typed(Gedb.Type* t, string value) 
	requires (!t.is_subobject()) {
		base((uint)sizeof(void*));
		dynamic_type = t;
		_name = value;
	}

	public void set_result(uint8* res) 
		requires (!dynamic_type.is_subobject()) {
		*(void**)result = res;
	}

	public override string name() { return _name; }
	public override ClassText* base_class() { 
		return (dynamic_type).base_class; 
	}
	public override uint8* address() { 
		return dynamic_type.is_basic() ? (uint8*)result : *(uint8**)result;
	}

	public override string append_single_name(string? to, uint fmt=0) {
		string here = to!=null ? to : "";
		return here+_name;
	}

 }

 /* -------------------------------------------------------------------- */

 public class TupleExpression : Expression {

	private ClassText* _class;
	private TupleType* tt;

	protected override void copy(Expression ex) {
		base.copy(ex);
		var tex = ex as TupleExpression;
		_class = tex._class;
		tt = tex.tt;
		_item_count = tex.item_count;
	}

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		return true;
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s) 
	throws ExpressionError { 
		var t = (Gedb.Type*)dynamic_type;
		uint8* addr = t.new_instance(true);
		*(uint8**)result = addr;
		results.@add(addr);
		Expression? a = arg;
		Field* e;
		uint8* eaddr;
		uint n = uint.min(_item_count,t.field_count());
		for (uint i=0; i<n; ++i) {
			assert (a!=null);
			e = t.fields[i];
			Gedb.Type* ft = e._entity.type;
			eaddr = ft.is_subobject() ? a.address() : (uint8*)a.result;
			copy_value(addr+e.offset, eaddr, ft.field_bytes());
			a = a.next;
		}
	}

	public Expression? items() { return arg; }
	public uint item_count { get; protected set; }

	public TupleExpression(Expression? items, TupleType* tt, ClassText* ct) {
		base((uint)sizeof(void*));
		set_child(Child.ARG, items);
		for (Expression? ex=arg; ex!=null; ex=ex.next) ++item_count;
		this.tt = tt;
		dynamic_type = (Gedb.Type*)tt;
		_class= ct;
	}

	public override string name() { return "TUPLE"; }
	public override ClassText* base_class() { return _class; }
	public override uint8* address() { return *(void**)result; }

	public override string append_single_name(string? to, uint fmt=0) {
		string here = to!=null ? to : "";
		here += arg!=null ? "[" + arg.append_name(null, fmt) + "]" : "[]";
		return here;
	}

 }

 /* -------------------------------------------------------------------- */

 public class AliasExpression : Expression { 

	protected string _name;
	protected Expression? alias_top { get; private set; }

	protected override void copy(Expression ex) {
		base.copy(ex);
		var aex = ex as AliasExpression;
		_name = aex.name();
		if (alias_top!=null) {
			alias_top = aex.alias_top.clone();
			alias = alias_top.bottom();
		}
	}

	protected override Expression resolved(Expression? p, 
		Gee.List<Expression> pl) {
		var aex = base.resolved(p, pl) as AliasExpression;
		aex.parent = p;
		aex._name = _name;
		if (alias==null) return aex;
		Expression ex;
		int i=0, n=0;
		for (ex=alias_top.bottom(); ex!=alias_top; ex=ex.parent) {
			++n;
			if (i==0 && ex!=alias) ++i;
		}
		var top = alias_top.expanded(p, pl);
		for (ex=top.bottom(); i-->0;) ex = ex.parent;
		aex.alias = ex;
		return aex;
	}

	protected override bool set_dyn_type(Gedb.Type* pt, StackFrame* f) {
		dynamic_type = alias.dynamic_type;
		return dynamic_type!=null; 
	}

	protected override void compute(uint8* obj, StackFrame* f, System* s) 
	throws ExpressionError {
		Expression? p = is_down() ? parent : null;
		if (p!=null) 
			alias_top.compute_in_object(p.address(), p.dynamic_type, s, f); 
		else
			alias_top.compute_in_stack(f, s);
		dynamic_type = alias.dynamic_type;
	}

	internal override Expression? resolve_alias() { 
		return alias!=null ? alias.resolve_alias() : null;
	}

	public AliasExpression(string name, Expression? ex, 
						   Gee.List<Expression>? pl=null) { 
		base(0);
		alias = pl!=null ? ex.expanded(null, pl) : ex;
		_name = name;
	}

	private Expression? _alias;
	public Expression? alias { 
		get { return _alias; }
		protected set {
			if (value!=null) {
				_alias_top = value.top();
				_alias = _alias_top.bottom();
				dynamic_type = value.dynamic_type;
			} else {
				_alias_top = null;
				_alias = null;
				dynamic_type = null;
			}
		}
	}

	public Gee.ArrayList<AliasExpression> depends;

	public static bool is_cyclic(Expression ex, string name,
								 Gee.ArrayList<string>? cycle=null) {
		AliasExpression? ci;
		string cnm;
		for (uint i=0; i<Child.COUNT; ++i) {
			ci = ex.children[i] as AliasExpression;
			if (ci==null) continue;
			cnm = ci.name();
			if (cnm==name || is_cyclic(ci.alias_top, name, cycle)) {
				if (cycle!=null) 
					cycle.insert(0, cnm[1:cnm.length]);
				return true;
			}
		}
		return false;
	}

	public override string name() { return _name; }
	public override ClassText* base_class() { return alias.base_class(); }
	public override uint8* address() { return alias.address(); }

	public override string append_single_name(string? to, uint fmt=0) {
		string here = to!=null ? to : "";
		if (is_down()) here += ".";
		if ((fmt&Format.EXPAND_ALIAS)!=0) 
			here += alias_top.append_qualified_name(here, null, fmt);
		else 
			here += _name;
		return here;
	}

 }

 /* -------------------------------------------------------------------- */

 public class Placeholder : AliasExpression {

	protected override void copy(Expression ex) {
		var ph = ex as Placeholder;
		_name = ph._name;
		alias = ph.alias!=null ? search(ph.alias, ph) : null;
// type does not follow `alias' if `is_index()', so set it explicitly:
		dynamic_type = ex.dynamic_type;
	}

	protected override Expression resolved(Expression? p, 
		Gee.List<Expression> pl) {
		int n = pl.size;
		int l = _name.length;
		var t = get_type();
		var ph = @new(t) as Placeholder;
		ph._name = _name;
		if (l==0) return null;
		ph.alias = pl[n-l];
		return ph;
	}
	
	protected override void compute(uint8* obj, StackFrame* f, System* s) 
	throws ExpressionError {
		// target is already computed
		dynamic_type = alias.dynamic_type;
	}

	public Placeholder.named(string name, Gedb.Type* int_type) {
		base(name, null);
		if (is_index()) 
			dynamic_type = int_type;
	}

	public Placeholder(Expression ex, string name, Gedb.Type* int_type) { 
		base(name, ex);
		if (is_index()) 
			dynamic_type = int_type;
	}

	public uint level() { return _name.length; }
	public bool is_index() { return _name.@get(0)=='!'; }

	public override bool is_placeholder() { return true; }

	public override string append_single_name(string? to, uint fmt=0) {
		if ((fmt&Format.EXPAND_PH)!=0) fmt |= Format.EXPAND_ALIAS;
		return base.append_single_name(to, fmt);
	}

 }

/* -------------------------------------------------------------------- */

public class RangePlaceholder : Placeholder {
	
	private NormalType* int_type;
	private uint idx;

	protected override void copy(Expression ex) {
		base.copy(ex);
		var rp = ex as RangePlaceholder;
		int_type = rp.int_type;
		idx = rp.idx;
	}

	protected override Expression resolved(Expression? p, 
		Gee.List<Expression> pl) {
		var rp = base.resolved(p, pl) as RangePlaceholder;
		rp.int_type = int_type;
		rp.idx = idx;
		if (is_index()) rp.dynamic_type = (Gedb.Type*)int_type;
		return rp;
	}

	public RangePlaceholder(RangeExpression rng, string name, Gedb.Type* it)
		requires (it.ident=TypeIdent.INTEGER_32) {
		base(rng, name, it);
		int_type = (NormalType*)it;
	}
	
	public override ClassText* base_class() {
		if (!is_index()) return base.base_class();
		return ((Gedb.Type*)int_type).base_class;		
	}

	public override uint8* address() {
		if (!is_index()) return base.address();
		idx = index();
		uint* addr = &idx;
		return (uint8*)addr;
	}

	public override string append_single_name(string? to, uint fmt=0) {
		if ((fmt&Format.EXPAND_PH)!=0) {
			var rng = alias as RangeExpression;
			if (rng!=null)
				return rng.special.append_single_name(to, fmt);
		} 
		return base.append_single_name(to, fmt);
	}

	public uint index() { return (alias.range as ItemExpression).index; }

}
