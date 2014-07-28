note

	description: "Node of a parsed expression tree representing an operator."

class DG_OPERATOR

inherit

	DG_EXPRESSION
		redefine
			is_single,
			is_range,
			is_operator,
			is_prefix,
			is_infix,
			compute_qualified,
			copy
		end

create

	make_as_down

feature -- Access 

	precedence: INTEGER

feature -- Status 

	is_single: BOOLEAN = False

	is_range: BOOLEAN = False

	is_operator: BOOLEAN = True

	is_infix: BOOLEAN
		do
			Result := attached arg
		end

	is_prefix: BOOLEAN
		do
			Result := not attached arg
		end

	has_precedence (over: DG_OPERATOR): BOOLEAN
		do
			Result := not attached over
			if not Result then
				Result := precedence > over.precedence
			end
		end

feature -- Status setting 

	set_code (c: INTEGER)
		do
			code := c
		ensure
			code_set: code = c
		end
	
	set_precedence (p: INTEGER)
		require
			is_infix: is_infix
			not_negative: p > 0
		do
			precedence := p
		ensure
			precedence_set: precedence = p
		end

feature -- Comparison & duplication 

	copy (other: like Current)
		do
			Precursor (other)
			precedence := other.precedence
		end

feature {DG_EXPRESSION} -- Output 

	append_infix (s: STRING; l: INTEGER; stop_at_error: BOOLEAN; arg_of: detachable DG_EXPRESSION): BOOLEAN
		require
			is_infix: is_infix
		local
			need_parens: BOOLEAN
		do
			Result := True
			need_parens := attached down
			if need_parens then
				if attached {DG_OPERATOR} down as op1 and then not op1.has_precedence (Current) then
					need_parens := False
				end
			end
			if not need_parens then
				if attached {DG_OPERATOR} arg_of as op2 and then not has_precedence (op2) then
					need_parens := True
				end
			end
			if need_parens then
				s.insert_character ('(', l)
			end
			s.extend (' ')
			if not stop_at_error then
				s.append (fast_name)
			else
				Result := False
			end
			if Result and then attached arg as a then
				s.extend (' ')
				Result := a.append_checked_out (s, stop_at_error, arg_of)
				if Result and then need_parens then
					s.extend (')')
				end
			end
		end

	append_prefix (s: STRING; l: INTEGER; stop_at_error: BOOLEAN): BOOLEAN
		require
			is_prefix: is_prefix
		local
			k: INTEGER
			need_parens: BOOLEAN
		do
			Result := True
			k := l
			need_parens := attached down
			if need_parens then
				if attached {DG_OPERATOR} down as op and then not op.has_precedence (Current) then
					need_parens := False
				end
			end
			if need_parens then
				s.insert_character ('(', k)
				k := k + 1
			end
			tmp_str.wipe_out
			if type.is_basic then
				tmp_str.append (fast_name)
			elseif	attached entity as e then
				e.append_name (tmp_str)
			elseif not stop_at_error then
				tmp_str.append (fast_name)
			else
				Result := False
			end
			if Result then
				tmp_str.extend (' ')
				s.insert_string (tmp_str, k)
				if need_parens then
					s.append_character (')')
				end
			else
				s.keep_head (k - 1)
			end
		end

feature {DG_EXPRESSION} -- Computation 

	compute_qualified (ds: IS_STACK_FRAME; values: DG_VALUE_STACK; left: BOOLEAN)
		local
			lt: IS_TYPE
		do
			if attached parent as p then
				lt := p.type
			elseif left then
				lt := ds.target_type
			else
			end
			if lt.is_basic and then code /= free_op then
				in_object := Void
				copy_value (parent)
				fix_value
				values.put (Current)
				if attached arg as a then
					compute_2_basic (a, ds, values)
				else
					compute_1_basic (ds, values)
				end
				entity := basic_op_entity
				adjust_address
			else
				Precursor (ds, values, left)
			end
		end

feature {} -- Implementation

	code: INTEGER
	
	compute_1_basic (ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		require
			has_target: attached parent
			no_args: not attached arg
			is_basic: type.is_basic
		do
			inspect code
			when not_op then
				put_boolean (not as_boolean)
			when plus_op then
				inspect type.ident
				when Nat8_ident then
					put_integer_8 (as_natural_8.to_integer_8)
				when Nat16_ident then
					put_integer_16 (as_natural_16.to_integer_16)
				when Nat32_ident then
					put_integer_32 (as_natural_32.to_integer_32)
				when Nat64_ident then
					put_integer_64 (as_natural_64.to_integer_64)
				else
				end
			when minus_op then
				inspect type.ident
				when Int8_ident then
					put_integer_8 (- as_integer_8)
				when Int16_ident then
					put_integer_16 (- as_integer_16)
				when Int32_ident then
					put_integer_32 (- as_integer_32)
				when Int64_ident then
					put_integer_64 (- as_integer_64)
				when Nat8_ident then
					put_integer_8 (- as_natural_8.to_integer_8)
					type := debuggee.int8_type
				when Nat16_ident then
					put_integer_16 (- as_natural_16.to_integer_16)
					type := debuggee.int16_type
				when Nat32_ident then
					put_integer_32 (- as_natural_32.to_integer_32)
					type := debuggee.int32_type
				when Nat64_ident then
					put_integer_64 (- as_natural_64.to_integer_64)
				when Real32_ident then
					put_real (- as_real)
				when Real64_ident then
					put_double (- as_double)
				else
				end
			else
			end
		end
	
	compute_2_basic (right: DG_EXPRESSION; ds: IS_STACK_FRAME; values: DG_VALUE_STACK)
		require
			has_target: attached parent
			one_arg: attached arg 
			is_basic: type.is_basic
		local
			rt: IS_TYPE
			l, r: DG_C_VALUE
			int: INTEGER_64
			nat: NATURAL_64
			dbl: REAL_64
			m: INTEGER
		do
			right.compute_one (ds, values)
			rt := right.bottom.type
			m := type.instance_bytes.max (rt.instance_bytes)
			r := converted_right
			r.set_type (rt)
			r.copy_value (values.top)
			values.pop (1)
			l := converted_left
			l.set_type (type)
			l.copy_value (parent)
			inspect type.ident
			when Int8_ident, Int16_ident, Int32_ident then
				l.convert_to (debuggee.Int64_type)
			when Nat8_ident, Nat16_ident, Nat32_ident then
				l.convert_to (debuggee.Nat64_type)
			when Real32_ident then
				l.convert_to (debuggee.double_type)
			when Pointer_ident then
				if code /= plus_op then
					raise_with_code (0, once "Operation `+' expected.")
				elseif l.type.ident /= Nat64_ident then
					raise_with_code (0, once "INTEGER_* type expected.")
				end
			when Char8_ident then
				inspect code
				when eq_op .. nsim_op then
				when plus_op, minus_op then
					inspect r.type.ident
					when Int64_ident, Nat64_ident then
						r.convert_to (debuggee.Int32_type)
						put_character (l.as_character + r.as_integer_32)	
					else
						raise_with_code (0, once "INTEGER_* type expected.")
					end
				else
					raise_with_code (0, once "Comparison or one of operations `+', `-' expected.")	
				end
			when  Char32_ident then
				inspect code
				when eq_op .. nsim_op then
				else
					raise_with_code (0, once "Comparison expected.")	
				end
			else
			end
			inspect rt.ident
			when Int8_ident, Int16_ident, Int32_ident then
				r.convert_to (debuggee.Int64_type)
			when Nat8_ident, Nat16_ident, Nat32_ident then
				r.convert_to (debuggee.Nat64_type)
			when Real32_ident then
				r.convert_to (debuggee.double_type)
			else
			end
			inspect code
			when power_op then
				inspect r.type.ident
				when Int64_ident, Nat64_ident then
					r.convert_to (debuggee.double_type)
				else
				end
			else
				-- Argument conversion:
				inspect l.type.ident
				when Real64_ident then
					r.convert_to (debuggee.double_type)
				else
					-- Target conversion:
					inspect r.type.ident
					when Real64_ident then
						l.convert_to (debuggee.double_type)
					else
					end
				end
			end

			inspect code
			when and_op then
				put_boolean (l.as_boolean and then r.as_boolean)
			when or_op then
				put_boolean (l.as_boolean or else r.as_boolean)
			when xor_op then
				put_boolean (l.as_boolean xor r.as_boolean)
			when implies_op then
				put_boolean (l.as_boolean implies r.as_boolean)
			when eq_op, sim_op then
				inspect l.type.ident
				when Boolean_ident then
					put_boolean (l.as_boolean = r.as_boolean)
				when Nat64_ident then
					put_boolean (l.as_natural_64 = r.as_natural_64)
				when Int64_ident then
					put_boolean (l.as_integer_64 = r.as_integer_64)
				when Real64_ident then
					put_boolean (l.as_double = r.as_double)
				when Char8_ident then
					put_boolean (l.as_character = r.as_character)
				when Char32_ident then
					put_boolean (l.as_character_32 = r.as_character_32)
				else
				end
			when ne_op, nsim_op then
				inspect l.type.ident
				when Boolean_ident then 
					put_boolean (l.as_boolean /= r.as_boolean)
				when Nat64_ident then
					put_boolean (l.as_natural_64 /= r.as_natural_64)
				when Int64_ident then
					put_boolean (l.as_integer_64 /= r.as_integer_64)
				when Real64_ident then
					put_boolean (l.as_double /= r.as_double)
				when Char8_ident then
					put_boolean (l.as_character /= r.as_character)
				when Char32_ident then
					put_boolean (l.as_character_32 /= r.as_character_32)
				else
				end
			when lt_op then
				inspect l.type.ident
				when Nat64_ident then
					put_boolean (l.as_natural_64 < r.as_natural_64)
				when Int64_ident then
					put_boolean (l.as_integer_64 < r.as_integer_64)
				when Real64_ident then
					put_boolean (l.as_double < r.as_double)
				when Char8_ident then
					put_boolean (l.as_character < r.as_character)
				when Char32_ident then
					put_boolean (l.as_character_32 < r.as_character_32)
				else
				end
			when le_op then
				inspect l.type.ident
				when Nat64_ident then
					put_boolean (l.as_natural_64 <= r.as_natural_64)
				when Int64_ident then
					put_boolean (l.as_integer_64 <= r.as_integer_64)
				when Real64_ident then
					put_boolean (l.as_double <= r.as_double)
				when Char8_ident then
					put_boolean (l.as_character <= r.as_character)
				when Char32_ident then
					put_boolean (l.as_character_32 <= r.as_character_32)
				else
				end
			when gt_op then
				inspect l.type.ident
				when Nat64_ident then
					put_boolean (l.as_natural_64 > r.as_natural_64)
				when Int64_ident then
					put_boolean (l.as_integer_64 > r.as_integer_64)
				when Real64_ident then
					put_boolean (l.as_double > r.as_double)
				when Char8_ident then
					put_boolean (l.as_character > r.as_character)
				when Char32_ident then
					put_boolean (l.as_character_32 > r.as_character_32)
				else
				end
			when ge_op then
				inspect l.type.ident
				when Nat64_ident then
					put_boolean (l.as_natural_64 >= r.as_natural_64)
				when Int64_ident then
					put_boolean (l.as_integer_64 >= r.as_integer_64)
				when Real64_ident then
					put_boolean (l.as_double >= r.as_double)
				when Char8_ident then
					put_boolean (l.as_character >= r.as_character)
				when Char32_ident then
					put_boolean (l.as_character_32 >= r.as_character_32)
				else
				end
			when plus_op then
				inspect l.type.ident
				when Nat64_ident then
					put_natural_64 (l.as_natural_64 + r.as_natural_64)
				when Int64_ident then
					put_integer_64 (l.as_integer_64 + r.as_integer_64)
				when Real64_ident then
					put_double (l.as_double + r.as_double)
				else
				end
			when minus_op then
				inspect l.type.ident
				when Nat64_ident then
					put_natural_64 (l.as_natural_64 - r.as_natural_64)
				when Int64_ident then
					put_integer_64 (l.as_integer_64 - r.as_integer_64)
				when Real64_ident then
					put_double (l.as_double - r.as_double)
				else
				end
			when mult_op then
				inspect l.type.ident
				when Nat64_ident then
					put_natural_64 (l.as_natural_64 * r.as_natural_64)
				when Int64_ident then
					put_integer_64 (l.as_integer_64 * r.as_integer_64)
				when Real64_ident then
					put_double (l.as_double * r.as_double)
				else
				end
			when div_op then
				inspect l.type.ident
				when Nat64_ident then
					put_double (l.as_natural_64 / r.as_natural_64)
				when Int64_ident then
					put_double (l.as_integer_64 / r.as_integer_64)
				when Real64_ident then
					put_double (l.as_double / r.as_double)
				else
				end
			when idiv_op then
				inspect l.type.ident
				when Nat64_ident then
					put_natural_64 (l.as_natural_64 // r.as_natural_64)
				when Int64_ident then
					put_integer_64 (l.as_integer_64 // r.as_integer_64)
				else
				end
			when imod_op then
				inspect l.type.ident
				when Nat64_ident then
					put_natural_64 (l.as_natural_64 \\ r.as_natural_64)
				when Int64_ident then
					put_integer_64 (l.as_integer_64 \\ r.as_integer_64)
				else
				end
			when power_op then
				inspect l.type.ident
				when Nat64_ident then
					put_double (l.as_natural_64 ^ r.as_double)
				when Int64_ident then
					put_double (l.as_integer_64 ^ r.as_double)
				when Real64_ident then
					put_double (l.as_double ^ r.as_double)
				else
				end
			else
			end

			if m < 64 then
				inspect type.ident
				when Int64_ident then
					int := as_integer_64
					if {INTEGER}.min_value <= int and int <= {INTEGER}.max_value then
					end
				else
				end
			end
		end

	basic_op_entity: IS_ROUTINE
		local
			h: IS_CLASS_TEXT
			v: IS_SPARSE_ARRAY [detachable IS_LOCAL]
		once
			h := debuggee.any_type.base_class
			create v.make (0, Void)
			create Result.make("+", Void, Void, 0, h, 0,0,0,0,0, v, Void, Void)
		end
	
	converted_left: DG_C_VALUE
		once
			create Result
		end
	
	converted_right: DG_C_VALUE
		once
			create Result
		end
	
invariant

	when_infix: is_infix xor precedence = 0
	not_negative_precedence: precedence >= 0

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
