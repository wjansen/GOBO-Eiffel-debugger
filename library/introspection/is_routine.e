note

	description:
		"[ 
		 Internal description of a routine. 
		 The description is immutable up to the `call' which may be set later. 
		 ]"

class IS_ROUTINE

inherit

	IS_ENTITY 
		redefine
			text,
			is_less
		end

create

	make

feature {NONE} -- Initialization 

	make (nm: READABLE_STRING_8; anm: detachable READABLE_STRING_8;
				ia: like inline_agent; fl: INTEGER; t: like target;
				ac, lc, oc, cc, tc: INTEGER; v: like vars; x: like text)
		note
			action: "[
				Create `Current'.
				The arguments count `ac' must include the ficticious argument
				for the routine's target. The locals count `lc' must include
				the ficticious local variable for the routine's result.
				]"
		require
			ac_positive: ac > 0
			lc_positive: lc > 0
			oc_not_negative: oc >= 0
			enough_varables: v.count = ac + lc + oc
		local
			t0: like type
		do
			if lc > 0 then
				if attached v [ac] as r then
					t0 := r.type
				end
			end
			make_entity (nm, x)
			flags := fl
			target := t
			alias_name := anm
			vars := v
			if attached v as v_ and then v.count > 0 then
				type := v_[0].type
			end
			argument_count := ac
			local_count := lc
			old_value_count := oc
			scope_var_count := cc
			temp_var_count := tc
			inline_agent := ia
			wrap := 1
		ensure
			name_set: has_name (nm)
			flags_set: flags = fl or else flags = fl | Once_flag
			target_set: target = t
			inline_agent_set: inline_agent = ia
			argument_count_set: argument_count = ac
			local_count_set: local_count = lc
			old_value_count_set: old_value_count = oc
			vars_set: vars = v
		end

feature -- Access. 

	flags: INTEGER

	inline_agent: detachable IS_AGENT_TYPE
			-- If `Current' is routine of an inline agent 
			-- then the defining agent; `Void' else. 

	text: detachable IS_ROUTINE_TEXT

	is_procedure: BOOLEAN
		note
			return: "Does `Current' describe a procedure?"
		do
			Result := not is_function
		end

	is_function: BOOLEAN
		note
			return: "Does `Current' describe a function?"
		do
			Result := flags & Function_flag = Function_flag 
		end

	is_operator: BOOLEAN
		note
			return: "Does `Current' describe an alias operator (except bracket)?"
		do
			Result := flags & Operator_flag = Operator_flag
		ensure
			when_operator: Result implies is_function
		end

	is_bracket: BOOLEAN	
		note
			return: "Does `Current' describe the bracket operator?"
		do
			Result := flags & Bracket_flag = Bracket_flag
		ensure
			when_operator: Result implies is_function
		end

	is_prefix: BOOLEAN
		note
			return: "Does `Current' describe a prefix operator?"
		do
			Result := is_operator and then argument_count <= 1
		ensure
			when_prefix: Result implies is_operator
		end

	is_creation: BOOLEAN
		note
			return: "Does `Current' describe a creation procedure?"
		do
			Result := flags & Creation_flag = Creation_flag
		end

	is_default_creation: BOOLEAN
		note
			return: "Does `Current' describe the default creation procedure?"
		do
			Result := flags & Default_creation_flag = Default_creation_flag
		end

	is_precursor: BOOLEAN
		note
			return: "Is `Current' the precursor of call of another routine?"
		do
			Result := flags & Precursor_flag = Precursor_flag
		end

	is_once: BOOLEAN
		note
			return: "Does `Current' describe a once routine?"
		do
			Result := flags & Implementation_flag = Once_flag 
		end

	is_external: BOOLEAN
		note
			return: "Is `Current' an external routine?"
		do
			Result := flags & Implementation_flag = External_flag
		end

	is_inlined: BOOLEAN
		note
			return: "Is `Current''s body inlined?"
		do
			Result := flags & Inlined_flag = Inlined_flag
		end

	is_anonymous: BOOLEAN
		note
			return: "Is `Current' the routine of an inline agent?"
		do
			Result := flags & Anonymous_routine_flag = Anonymous_routine_flag 
		end

	uses_current: BOOLEAN
		note
			return: "Does the routine use the call's target?"
		do
			Result := flags & No_current_flag = 0
		ensure
			when_uses_curent: Result implies vars.count > 0
		end

	has_result: BOOLEAN
		note
			return: "Does routine use a result value?"
		do
			Result := is_function and then not is_external
		end

	is_attached: BOOLEAN 
		do
			if attached result_field as rf then
				Result := rf.is_attached
			end
		end

	has_rescue: BOOLEAN
		note
			return: "Has the routine a rescue clause?"
		do
			Result := flags & Rescue_flag = Rescue_flag
		end

	argument_count: INTEGER
			-- Number of arguments (including `Current'). 

	local_count: INTEGER
			-- Number of local variables 
			-- (including `Result' in case of a function). 

	old_value_count: INTEGER
			-- Number of old variables 

	scope_var_count: INTEGER
			-- Number of object test variables 

	temp_var_count: INTEGER
			-- Number of temporary variables 

	variable_count: INTEGER
		note
			return: "[
							 Total number of arguments (including the implicit `Current')
							 and local variables (including `Result' in case of a function).
							 ]"
		do
			if attached vars as vv then 
				Result := vv.count
			end
		ensure
			sum_of_args_and_locs: Result = argument_count + local_count + old_value_count + scope_var_count + temp_var_count
		end

	valid_var (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index for an argument or a local variable?"
		do
			Result := 0 <= i and then i < vars.count and then attached vars [i]
		end

	var_at (i: INTEGER): detachable IS_LOCAL
		note
			return: "[
				`i'-th argument or local variable.
				argument at `i=0' means `Current'. If the routine
				a function then `i=variable_count-1' means `Result'.
				]"
		do
			Result := vars [i]
		end

	valid_arg (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index for an argument?"
		do
			Result := 0 <= i and then i <= argument_count
		end

	arg_at (i: INTEGER): like var_at
		note
			return: "`i'-th argument, `Current' is argument at `i=0'."
		require
			valid: valid_arg (i)
		do
			Result := vars [index_of_arg (i)]
		end

	index_of_arg (i: INTEGER): INTEGER
		note
			return: "Index of `i-th' argument within `vars'."
		require
			valid_index: valid_arg (i)
		do
			Result := i
		end

	valid_loc (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index for a local variable?"
		do
			Result := 0 <= i and then i < local_count
		end

	local_at (i: INTEGER): like var_at
		note
			return: "`i'-th local variable, `Result' is local variable at `i=0'."
		do
			Result := vars [index_of_local (i)]
		end

	index_of_local (i: INTEGER): INTEGER
		note
			return: "Index of `i-th' local variable within `vars'."
		require
			valid_index: valid_loc (i)
		do
			Result := argument_count + i
		end

	valid_old (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index for an old	variable?"
		do
			Result := 0 <= i and then i < old_value_count
		end

	old_at (i: INTEGER): like var_at
		note
			return: "`i'-th old variable."
		do
			Result := vars [index_of_old (i)]
		end

	index_of_old (i: INTEGER): INTEGER
		note
			return: "Index of `i-th' old value within `vars'."
		require
			valid_index: valid_old (i)
		do
			Result := argument_count + local_count + i
		end

	valid_scope_var (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index for an object test variable?"
		do
			Result := 0 <= i and then i < scope_var_count
		end

	scope_var_at (i: INTEGER): like var_at
		note
			return: "`i'-th object test variable."
		require
			valid_index: valid_scope_var (i)
		do
			Result := vars [index_of_scope_var (i)]
		end

	index_of_scope_var (i: INTEGER): INTEGER
		note
			return: "Index of `i-th' object test within `vars'."
		require
			valid_index: valid_scope_var (i)
		do
			Result := argument_count + local_count + old_value_count + i
		end

	valid_temp (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index for an temporary variable?"
		do
			Result := 0 <= i and then i < temp_var_count
		end

	temp_var_at (i: INTEGER): like var_at
		note
			return: "`i'-th temporary variable."
		require
			valid_index: valid_temp (i)
		do
			Result := vars [index_of_temp_var (i)]
		end

	index_of_temp_var (i: INTEGER): INTEGER
		note
			return: "Index of `i-th' temp value within `vars'."
		require
			valid_index: valid_temp (i)
		do
			Result := argument_count + local_count + old_value_count + scope_var_count + i
		end

	result_field: like var_at
		note
			return: "Local variable corresponding to `Result'."
		do
			if is_function then
				Result := local_at (0)
			end
		ensure
			when_function: has_result implies attached Result
		end

	inline_routine_count: INTEGER
		do
			if attached inline_routines as ir then
				Result := ir.count
			end
		end

	valid_inline_routine (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < inline_routine_count
		end

	inline_routine_at (i: INTEGER): attached IS_ROUTINE
		note
			return: "`i'-th inline routine defined within `Current'."
		require
			valid_index: valid_inline_routine (i)
		do
			if attached inline_routines as ir then
				Result := ir [i]
			else
				-- should not happen, just to make routine void safe:
				Result := Current
			end
		end

	call: POINTER
			-- Entry address.
	
	wrap: INTEGER
			-- 

feature -- Status setting
	
	set_call (a: POINTER)
		do
			call := a
		ensure
			call_set: call = a
		end

feature -- Searching 

	var_by_name (nm: READABLE_STRING_8): detachable like var_at
		note
			return: "[
							 Index of `Current's argument, local variable, or old value
							 of name `nm'; `Void' if no such entity exists.
							 ]"
		local
			i: INTEGER
		do
			from
				i := variable_count
			until i = 0 loop
				i := i - 1
				if attached var_at (i) as v and then v.has_name (nm) then
					Result := v
					i := 0
				end
			end
		ensure
			when_found: attached Result as r implies r.has_name (nm) and then vars.has (r)
		end

feature -- COMPARABLE 

	is_less alias "<" (other: attached IS_ROUTINE): BOOLEAN
		do
			Result := Precursor (other)
			if not Result and then same_name (other) then
				Result := argument_count < other.argument_count
					-- prefix < infix 
			end
		end

feature -- Output 

	append_indented_out (s: STRING; indent: INTEGER)
		note
			action: "Append printable format of `Current'."
			s: "STRING to be extented"
			indent: "size of indentation"
		local
			i, n: INTEGER
		do
			n := argument_count
			pad_right (s, indent)
			append_name (s)
			if n > 0 then
				s.append_character ('(')
				from
					i := 0
				until i = n loop
					if i > 0 and then attached arg_at (i) as ai then
						s.append_character (',')
						s.append (ai.out)
					end
					i := i + 1
				end
				s.append_character (')')
			end
			if is_function and then attached type as t then
				s.append_character (':')
				s.append_character (' ')
				t.append_name (s)
			end
		end

feature {IS_BASE} -- Implementation 

	vars: IS_SPARSE_ARRAY [like var_at]

feature {NONE} -- Implementation 

	inline_routines: detachable IS_SEQUENCE [like inline_routine_at]

invariant

	when_function: is_function implies variable_count > 0 

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
