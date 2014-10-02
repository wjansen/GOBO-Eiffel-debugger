note

	description: "Internal description of types in an Eiffel system."

class IS_AGENT_TYPE

inherit

	IS_TYPE
		redefine
			is_subobject,
			is_basic,
			is_separate,
			is_reference,
			is_none,
			is_boolean,
			is_character,
			is_integer,
			is_real,
			is_double,
			is_pointer,
			is_int8,
			is_int16,
			is_int32,
			is_int64,
			is_string,
			is_unicode,
			generic_count,
			append_name
		end

create {IS_SYSTEM, IS_TYPE}

	make,
	make_in_system

feature {} -- Initialization 

	make (id: INTEGER; d: like declared_type; f: like fields; 
				ocp: like open_closed_pattern; r: like routine)
		note
			action: "Create `Current'."
		require
			abstract_agent: (d.flags & Agent_expression_flag) /= 0
			may_be_routine: d.generic_count >= 2
		do
			ident := id
			declared_type := d
			base := d.generic_at (0)
			if attached {like closed_operands_tuple} d.field_at (0) as cot then
				closed_operands_tuple := cot
			end
			open_operand_count := d.generic_at (1).generic_count
			open_closed_pattern := ocp.twin
			routine := r
			if attached r as r_ then
				routine_name := r_.fast_name
			else
				routine_name := no_name
			end
			fields := f
			if attached f as f_ then
				closed_operand_count := f_.count
			end
			instance_bytes := pointer_bytes.to_natural_32
			fast_name := out
		ensure
			ident_set: ident = id
			declared_type_set: declared_type = d
			fields_set: fields = f
			open_closed_pattern_set: open_closed_pattern.is_equal (ocp)
			routine_name_set: routine = r
		end

	make_in_system (tid, fl: INTEGER; nm, ocp: READABLE_STRING_8; f: IS_FACTORY)
		require
			valid_index: 0 < tid 
			nm_not_empty: not nm.is_empty
			ocp_not_empty: not ocp.is_empty
		local
			at: like base
			ff: IS_FIELD
		do
			ident := tid
			flags := fl
			routine_name := nm
			open_closed_pattern := ocp
			f.add_type (Current)
			open_operand_count := ocp.occurrences (open_operand_indicator)
			closed_operand_count := ocp.occurrences (closed_operand_indicator)
			at := f.any_type
			base := at
			create ff.make (no_name, at, Void, Void)
			scan_in_system (f)
		ensure
			ident_set: ident = tid
			flags_set: flags = fl
			routine_name_set: routine_name = nm
			open_closed_pattern_set: open_closed_pattern = ocp
		end
	
feature {IS_FACTORY} -- Initialization 

	scan_in_system (f: IS_FACTORY)
		local
			co: like field_at
			i, j, n: INTEGER
		do
			f.set_agent_base (Current)
			if f.to_fill and then attached {like base} f.last_type as ft then
				base := ft
			end
			f.set_fields_of_type (Current)
			if f.to_fill and then attached {like fields} f.last_fields as ff then
				fields := ff
				from
					n := closed_operand_count
				until i = n loop
					from
					until is_closed_operand (j) loop
						j := j + 1
					end
					co := field_at (i)
					if not attached co.fast_name as conm or else conm.is_empty then
						co.set_name (f.operand_name (ident, i, j))
					end
					j := j + 1
					i := i + 1
				end
				if field_count > n then
					co := field_at (n)
					if not attached co.fast_name as conm or else conm.is_empty then
						co.set_name (f.operand_name (ident, i, j))
					end
				end
			end
		end

feature -- Constants 

	open_operand_indicator: CHARACTER = '?'

	closed_operand_indicator: CHARACTER = '_'

feature -- Access

	is_none: BOOLEAN = False

	is_subobject: BOOLEAN = False

	is_basic: BOOLEAN = False

	is_reference: BOOLEAN = True

	is_separate: BOOLEAN = False

	is_boolean: BOOLEAN = False

	is_character: BOOLEAN = False

	is_integer: BOOLEAN = False

	is_real: BOOLEAN = False

	is_double: BOOLEAN = False

	is_pointer: BOOLEAN = False

	is_int8: BOOLEAN = False

	is_int16: BOOLEAN = False

	is_int32: BOOLEAN = False

	is_int64: BOOLEAN = False

	is_string: BOOLEAN = False

	is_unicode: BOOLEAN = False

	is_normal: BOOLEAN = False

	is_tuple: BOOLEAN = False

	is_special: BOOLEAN = False

	is_agent: BOOLEAN = True

	class_name: READABLE_STRING_8 
		once
			Result := "AGENT"
		end

	base: IS_TYPE
			-- Type descriptor of the routine's base class 
	
	base_is_closed: BOOLEAN
		note
			return: "Is the routine's target a closed operand?"
		do
			Result := open_closed_pattern [1] = closed_operand_indicator
		end

	base_is_open: BOOLEAN
		note
			return: "Is the routine's target an open operand?"
		do
			Result := not base_is_closed
		end

	open_closed_pattern: READABLE_STRING_8

	open_operand_count: INTEGER
			-- Number of open operands. 

	valid_arg_index (pos: INTEGER): BOOLEAN
		note
			return: "Is `pos' a valid argument index?"
		do
			Result := 0 <= pos and then pos < open_closed_pattern.count
		end

	is_open_operand (pos: INTEGER): BOOLEAN
		note
			return: "Is `pos'-th arg of the routine open in the agent?"
		require
			valid_pos: valid_arg_index (pos)
		do
			Result := open_closed_pattern [pos + 1] = open_operand_indicator
		ensure
			Result implies open_closed_pattern [pos + 1] = open_operand_indicator
		end

	closed_operand_count: INTEGER
			-- Number of closed operands. 

	is_closed_operand (pos: INTEGER): BOOLEAN
		note
			return: "Is `pos'-th routine argument closed in the agent?"
		do
			Result := open_closed_pattern [pos + 1] = closed_operand_indicator
		ensure
			Result implies open_closed_pattern [pos + 1] = closed_operand_indicator
		end

	valid_closed_operand (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index of the dense array of closed operands?"
		do
			Result := 0 <= i and then i < closed_operand_count
		end

	result_type: detachable like base
		note
			return:
				"[
				 Type descriptor of the routine's result type
				 (`Void' if the routine is a procedure
				 or if the result value is not implemented).
				 ]"
		do
			if attached last_result as lr then
				Result := lr.type
			end
		ensure
			when_last_result: attached last_result as lr implies Result = lr.type
		end

	last_result: detachable like field_at
		note
			return: "Descriptor of `last_result' if it has been defined."
		do
			if field_count > closed_operand_count then
				Result := field_at (closed_operand_count)
			end
		end

	routine_name: READABLE_STRING_8
			-- Name of agent's routine. 

	generic_count: INTEGER = 0
	
	in_routine: detachable IS_ROUTINE
			-- In case of an inline agent the descriptor of the enclosing routine. 

	declared_type: detachable IS_NORMAL_TYPE
			-- ROUTINE type of `Current's declaration (GEC specific)

	closed_operands_tuple: detachable IS_TUPLE_TYPE
			-- Tuple of closed operands (GEC specific). 
	
	routine: detachable IS_ROUTINE
			-- Descriptor of agent's routine. 

feature -- Status setting

	set_declared_type (dt: like declared_type)
		do
			declared_type := dt
		ensure
			declared_type_set: declared_type = dt
		end
	
	set_closed_operands_tuple (cot: like closed_operands_tuple)
		do
			closed_operands_tuple := cot
		ensure
			closed_operands_tuple_set: closed_operands_tuple = cot
		end

feature -- Output 

	append_name (str: STRING)
		note
			action: "Pretty-print name of the agent in `str'."
		local
			i, n: INTEGER
		do
			str.append (once "agent ")
			if not is_closed_operand (0) then
				str.extend ('{')
			end
			base.append_name (str)
			if not is_closed_operand (0) then
				str.extend ('}')
			end
			str.extend ('.')
			str.append (routine_name)
			from 
				i := 1
				n := open_operand_count + closed_operand_count
			until i = n loop
				if i = 1 then
					str.extend ('(')
				else
					str.extend (',')
				end
				if is_closed_operand (i) then
					str.extend (closed_operand_indicator)
				else
					str.extend (open_operand_indicator)
				end
				i := i + 1
			end
			if n > 1 then
				str.extend (')')
			end
		end

feature {IS_BASE} -- Implementation

	call_function: POINTER

	set_call_function (p: POINTER)
		do
			call_function := p
		ensure
			call_function_set: call_function = p 
		end
	
	function_location: POINTER
			-- Offset of the function pointer within the declared_type instances
			-- (GEC specific). 

	set_function_location (loc: POINTER)
		require
			has_declard_type: attached declared_type
		do
			function_location := loc
		ensure
			function_location_set: function_location = loc
		end

	function_offset: INTEGER
		do
			Result := function_location.to_integer_32 - default_instance.to_integer_32
		end
	
invariant

	function_field_set: function_field = declared_type.field_by_name (function_name)
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
