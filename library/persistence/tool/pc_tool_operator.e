note

	description: "Elementary data read from store file."

class PC_TOOL_OPERATOR

inherit

	PC_TOOL_VALUE
		redefine
			evaluate
		end
	
create

	make, make_1
	
feature {} -- Initialization

	make (op: INTEGER; l, r: PC_TOOL_VALUE)
		require
			-- valid_code: 
		do
			ptr := c_new
			op_code := op
			left := l
			right := r
			inspect op
			when and_op, or_op, xor_op, implies_op then
				type := Boolean_ident
			when eq_op, ne_op, lt_op, le_op, gt_op, ge_op then
				type := Boolean_ident
			else
				type := l.type
			end
		ensure
			op_code_set: op_code = op
			left_set: left = l
			right_set: right = r
		end
	
	make_1 (op: INTEGER; r: PC_TOOL_VALUE)
		require
			-- valid_code: 
		do
			ptr := c_new
			op_code := op
			left := Void
			right := r
			inspect op
			when not_op then
				type := Boolean_ident
			else
				type := r.type
			end
		ensure
			op_code_set: op_code = op
			no_left: left = Void
			right_set: right = r
		end

feature -- Constants

	not_op: INTEGER = 1
	and_op: INTEGER = 2
	or_op: INTEGER = 3
	xor_op: INTEGER = 4
	implies_op: INTEGER = 5
	
	eq_op: INTEGER = 11
	ne_op: INTEGER = 12
	lt_op: INTEGER = 13
	le_op: INTEGER = 14
	gt_op: INTEGER = 15
	ge_op: INTEGER = 16
	
	plus_op: INTEGER = 21
	minus_op: INTEGER = 22
	mult_op: INTEGER = 23
	div_op: INTEGER = 24
	idiv_op: INTEGER = 25
	imod_op: INTEGER = 26
	power_op: INTEGER = 27

feature -- Access

	op_code: INTEGER

	left, right: PC_TOOL_VALUE
	
feature -- Basic operation

	evaluate (id: NATURAL; driver: PC_SELECT_DRIVER) 
		do
			if attached left as l then
				l.evaluate (id, driver)
			end
			right.evaluate (id, driver)
			if not attached left then
				inspect op_code
				when not_op then
					set_boolean (not right.boolean_value)
				when plus_op then
					inspect right.type
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (right.integer_value)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_integer (right.natural_value.to_integer_64)
					when Real32_ident, Real64_ident then
						set_real (right.real_value)
					else
					end
				when minus_op then
					inspect right.type
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (- right.integer_value)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_integer (- right.natural_value.to_integer_64)
					when Real32_ident, Real64_ident then
						set_real (- right.real_value)
					else
					end
				else
				end
			else
				evaluate_for_operands (left, right)
			end
		end
	
	evaluate_for_operands (l, r: PC_TOOL_VALUE)
		local
			old_type: like type
		do
			-- Convert r operand according to numeric l operand:
			old_type := type
			if op_code /= power_op then
				inspect l.type
				when Real32_ident, Real64_ident then
					inspect r.type
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_real (r.integer_value.to_double)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_real (r.natural_value.to_real_64)
					when Real32_ident, Real64_ident then
						set_real (r.real_value)
					else
						raise ("Numeric type expected.")
					end
				when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
					inspect r.type
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (r.integer_value)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_integer (r.natural_value.to_integer_64)
					when Real32_ident, Real64_ident then
						set_integer (r.real_value.truncated_to_integer_64)
					else
						raise ("Numeric type expected.")
					end
				when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
					inspect r.type
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_natural (r.integer_value.to_natural_64)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_natural (r.natural_value)
					when Real32_ident, Real64_ident then
						set_natural (r.real_value.truncated_to_integer_64.to_natural_64)
					else
						raise ("Numeric type expected.")
					end
				when Boolean_ident then
					if r.type /= Boolean_ident then
						raise ("Boolean type expected.")
					end
					set_boolean (r.boolean_value)
				else
					if not r.is_reference then
						raise ("Reference type expected.")
					end
					set_ident (r.ident_value, r.type)
				end
				-- Evaluate:
				inspect op_code
				when and_op then
					set_boolean (l.boolean_value and then r.boolean_value)
				when or_op then
					set_boolean (l.boolean_value or else r.boolean_value)
				when xor_op then
					set_boolean (l.boolean_value xor r.boolean_value)
				when implies_op then
					set_boolean (l.boolean_value implies r.boolean_value)
				when eq_op then
					inspect l.type
					when Boolean_ident then
						set_boolean (l.boolean_value = r.boolean_value)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_boolean (l.natural_value = natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_boolean (l.integer_value = integer_value)
					when Real32_ident, Real64_ident then
						set_boolean (l.real_value = real_value)
					else
						set_boolean (l.ident_value = r.ident_value)
					end
				when ne_op then
					inspect l.type
					when Boolean_ident then 
						set_boolean (l.boolean_value /= r.boolean_value)
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_boolean (l.natural_value /= natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_boolean (l.integer_value /= integer_value)
					when Real32_ident, Real64_ident then
						set_boolean (l.real_value /= real_value)
					else
						set_boolean (l.ident_value /= r.ident_value)
					end
				when lt_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_boolean (l.natural_value < natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_boolean (l.integer_value < integer_value)
					when Real32_ident, Real64_ident then
						set_boolean (l.real_value < real_value)
					else
						set_boolean (l.ident_value < ident_value)
					end
				when le_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_boolean (l.natural_value <= natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_boolean (l.integer_value <= integer_value)
					when Real32_ident, Real64_ident then
						set_boolean (l.real_value <= real_value)
					else
						set_boolean (l.ident_value <= ident_value)
					end
				when gt_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_boolean (l.natural_value > natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_boolean (l.integer_value > integer_value)
					when Real32_ident, Real64_ident then
						set_boolean (l.real_value > real_value)
					else
						set_boolean (l.ident_value > ident_value)
					end
				when ge_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_boolean (l.natural_value >= natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_boolean (l.integer_value >= integer_value)
					when Real32_ident, Real64_ident then
						set_boolean (l.real_value >= real_value)
					else
						set_boolean (l.ident_value >= ident_value)
					end
				when plus_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_natural (l.natural_value + natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (l.integer_value + integer_value)
					when Real32_ident, Real64_ident then
						set_real (l.real_value + real_value)
					else
						raise ("Numeric type expected.")
					end
				when minus_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_natural (l.natural_value - natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (l.integer_value - integer_value)
					when Real32_ident, Real64_ident then
						set_real (l.real_value - real_value)
					else
						raise ("Numeric type expected.")
					end
				when mult_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_natural (l.natural_value * natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (l.integer_value * integer_value)
					when Real32_ident, Real64_ident then
						set_real (l.real_value * real_value)
					else
						raise ("Numeric type expected.")
					end
				when div_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_real (l.natural_value / natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_real (l.integer_value / integer_value)
					when Real32_ident, Real64_ident then
						set_real (l.real_value / real_value)
					else
						raise ("Numeric type expected.")
					end
				when idiv_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_natural (l.natural_value // natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (l.integer_value // integer_value)
					else
						raise ("Integer type expected.")
					end
				when imod_op then
					inspect l.type
					when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
						set_natural (l.natural_value \\ natural_value)
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						set_integer (l.integer_value \\ integer_value)
					else
						raise ("Integer type expected.")
					end
				end
			else
				inspect r.type
				when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
					set_real (r.integer_value.to_double)
				when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
					set_real (r.natural_value.to_real_64)
				when Real32_ident, Real64_ident then
					set_real (r.real_value)
				else
					raise ("Numeric type expected.")
				end
				inspect l.type
				when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
					set_real (l.natural_value ^ natural_value)
				when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
					set_real (l.integer_value ^ integer_value)
				when Real32_ident, Real64_ident then
					set_real (l.real_value ^ real_value)
				else
					raise ("Numeric type expected.")
				end
			end
			inspect op_code
			when plus_op, minus_op, mult_op, idiv_op, imod_op then
				inspect r.type
					when Int64_ident, Nat64_ident, Real64_ident then
				else
					type := old_type
				end
			when div_op then
				inspect r.type
				when Int64_ident, Nat64_ident, Real64_ident then
				else
					type := Real32_ident
				end
			else
			end
		end

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
