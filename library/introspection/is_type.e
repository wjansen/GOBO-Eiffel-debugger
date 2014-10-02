note

	description:
		"[ 
		 Internal description of a type. 
		 The description is immutable up to the `size' and `allocate' 
		 which may be set later. 
		 ]"

deferred class IS_TYPE

inherit

	IS_NAME
		redefine
			is_equal,
			is_less,
			name,
			append_name,
			hash_code
		end

feature -- Access 

	c_name: detachable STRING
		-- Type name for use in C programs.

	name: STRING
		do
			Result := ""
			append_name (Result)
		end
	
	ident: INTEGER
			-- System wide unique identifier. 

	class_name: READABLE_STRING_8
		deferred
		end

	generic_count: INTEGER
		note
			return: "Number of generics parameters."
		do
			if attached generics as gs then
				Result := gs.count
			end
		ensure
			not_negative: Result >= 0
		end

	valid_generic (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < generic_count and then attached generics as gs and then attached gs [i]
		ensure
			validity: Result = (0 <= i and then i < generic_count)
		end

	generic_at (i: INTEGER): IS_TYPE
		note
			return: "Type of the `i'-th actual generic parameter."
		require
			valid_index: valid_generic (i)
		local
			g: detachable like generic_at
		do
			if attached generics as gg then
				g := gg [i]
			end
			check attached g end
			Result := g
		end

	effector_count: INTEGER
		note
			return: "Number of `Currents''s effecting types."
		do
			if attached effectors as es then
				Result := es.count
			end
		ensure
			not_negative: Result >= 0
		end

	valid_effector (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < effector_count
				and then attached effectors as es and then attached es [i]
		ensure
			validity: Result = (0 <= i and then i < effector_count)
		end

	effector_at (i: INTEGER): IS_TYPE
		note
			return: "Type of `i'-th effective descentant."
		require
			valid: valid_effector (i)
		do
			if attached effectors as es then
				Result := es [i]
			else
				-- should not happen, just to make the routine void safe
				Result := Current
			end
		end

	field_count: INTEGER
		note
			return: "Number of variable fields."
		do
			if attached fields as a then
				Result := a.count
			end
		ensure
			not_negative: Result >= 0
		end

	valid_field (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < field_count
				and then attached fields as a and then attached a [i]
		ensure
			validity: Result = (0 <= i and then i < field_count)
		end

	field_at (i: INTEGER): IS_FIELD
		note
			return: "`i'-th variable field."
		require
			valid_index: valid_field (i)
		local
			aa: like fields
		do
			aa := fields
			check attached aa end
			Result := aa [i]
		end

	constant_count: INTEGER
		note
			return: "Number of variable constants."
		do
			if attached constants as a then
				Result := a.count
			end
		ensure
			not_negative: Result >= 0
		end

	valid_constant (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < constant_count
				and then attached constants as a and then attached a [i]
		ensure
			validity: Result = (0 <= i and then i < constant_count)
		end

	constant_at (i: INTEGER): IS_CONSTANT
		note
			return: "`i'-th variable constant."
		require
			valid_index: valid_constant (i)
		local
			aa: like constants
		do
			aa := fields
			check attached aa end
			Result := aa [i]
		end

	routine_count: INTEGER
		note
			return: "Number of routines."
		do
			if attached routines as rs then
				Result := rs.count
			end
		ensure
			not_negative: Result >= 0
		end

	valid_routine (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < routine_count
				and then attached routines as rs and then attached rs [i]
		ensure
			validity: Result = (0 <= i and then i < routine_count)
		end

	routine_at (i: INTEGER): IS_ROUTINE
		note
			return: "`i'-th routine."
		require
			valid_index: valid_routine (i)
		local
			rr: like routines
		do
			rr := routines
			check attached rr end
			Result := rr [i]
		end

	default_creation: detachable like routine_at
		note
			return:
			"[
			 Procedure implementing `default_create' from class ANY
			 if it is a creation procedure of the type, may be `Void'.
			 ]"
		local
			i: INTEGER
		do
			if attached routines as rr then
				from
					i := routine_count
				until i = 0 loop
					i := i - 1
					Result := rr [i]
					if attached Result as r and then r.is_default_creation then
						i := 0
					else
						Result := Void
					end
				end
			end
		ensure
			when_found: attached Result as r
									implies r.is_default_creation and then r.type = Current
		end

	invariant_function: detachable like routine_at
		note
			return: "Function computing the class invariant, may be `Void'."
		do
		end

	has_bracket: BOOLEAN
		note
			return: "Has `Current' a bracket function?"
		do
			Result := attached bracket
		end

	bracket: detachable IS_ROUTINE
		note
			return: "The type's bracket function, if any."
		local
			i: INTEGER
		do
			if attached routines as rr then
				from
					i := routine_count
				until i = 0 loop
					i := i - 1
					Result := rr [i]
					if Result.is_bracket then
						i := 0
					else
						Result := Void
					end
				end
			end
		end

feature -- Status 

	flags: INTEGER

	is_none: BOOLEAN
		do
			Result := has_name (once "NONE")
		end

	is_boolean: BOOLEAN
		do
			Result := ident = Boolean_ident
		end

	is_character: BOOLEAN
		do
			Result := ident = Character_ident
		end

	is_integer: BOOLEAN
		do
			Result := ident = Integer_ident
		end

	is_real: BOOLEAN
		do
			Result := ident = Real32_ident
		end

	is_double: BOOLEAN
		do
			Result := ident = Real64_ident
		end

	is_pointer: BOOLEAN
		do
			Result := ident = Pointer_ident
		end

	is_char8: BOOLEAN
		do
			Result := ident = Char8_ident
		end

	is_char32: BOOLEAN
		do
			Result := ident = Char32_ident
		end

	is_int8: BOOLEAN
		do
			Result := ident = Int8_ident
		end

	is_int16: BOOLEAN
		do
			Result := ident = Int16_ident
		end

	is_int32: BOOLEAN
		do
			Result := ident = Int32_ident
		end

	is_int64: BOOLEAN
		do
			Result := ident = Int64_ident
		end

	is_nat8: BOOLEAN
		do
			Result := ident = Nat8_ident
		end

	is_nat16: BOOLEAN
		do
			Result := ident = Nat16_ident
		end

	is_nat32: BOOLEAN
		do
			Result := ident = Nat32_ident
		end

	is_nat64: BOOLEAN
		do
			Result := ident = Nat64_ident
		end

	is_string: BOOLEAN
		do
			Result := ident = String8_ident
		end

	is_unicode: BOOLEAN
		do
			Result := ident = String32_ident
		end

	is_subobject: BOOLEAN
		do
			Result := flags & Subobject_flag > 0
		end

	is_basic: BOOLEAN
		do
			Result := flags & Basic_expanded_flag = Basic_expanded_flag
		ensure
			is_subobject: Result implies is_subobject
		end

	is_reference: BOOLEAN
		do
			Result := not is_subobject
		end

	is_separate: BOOLEAN
		do
			Result := flags & Proxy_flag = Proxy_flag
		end

	is_normal: BOOLEAN
		deferred
		end

	is_special: BOOLEAN
		deferred
		end

	is_tuple: BOOLEAN
		deferred
		end

	is_agent: BOOLEAN
		deferred
		end

	is_anonymous: BOOLEAN
		do
			Result := flags & Anonymous_flag = Anonymous_flag
		end

	is_attached: BOOLEAN
		do
			Result := flags & Attached_flag = Attached_flag
		end

	is_meta_type: BOOLEAN
		do
			Result := flags & Meta_type_flag = Meta_type_flag
		end

	is_alive: BOOLEAN
		note
			return: "Is the type alive (i.e. can instances be created) ?"
		do
			Result := flags & Alive_flag /= 0
		end

	is_actionable: BOOLEAN
		note
			return: "Does the type's base class inherit from PC_ACTIONABLE?"
		do
		ensure
			when_actionable: Result implies not is_subobject
		end

	has_invariant: BOOLEAN
		note
			return: "Does the type's base class define an invariant clause?"
		do
			if attached {IS_NORMAL_TYPE} Current as normal then
				Result := normal.base_class.supports_invariant
			end
		end

feature {IS_SYSTEM} -- Status setting

	set_fields (ff: like fields)
		do
			fields := ff
		ensure
			fields_set: fields = ff
		end

	set_routines (rr: like routines)
		do
			routines := rr
		ensure
			fields_set: routines = rr
		end

	set_c_name (c: like c_name)
		do
			c_name := c
		ensure
			c_name_set: c_name = c
		end
	
feature {IS_FACTORY} -- Factory 

	set_generics (f: IS_FACTORY)
		local
			gg: attached like generics
			id, gid: INTEGER
			i, n: INTEGER
			to_fill: BOOLEAN
		do
			if is_basic then
			else
				n := f.generic_count (id)
				if n > 0 then
					from
						if attached generics as gs then
							gg := gs
						else
							create gg.make (n, Current)
							generics := gg
						end
						id := ident
						to_fill := f.to_fill
					until i = n loop
						gid := f.generic (id, i)
						f.new_type (gid, False)
						if to_fill and then attached {like generic_at} f.last_type as g then
							gg.add (g)
						end
						i := i + 1
					end
				end
			end
		ensure
			same_generics: attached old generics as gen implies gen = generics
		end

feature {IS_FIELD} -- Factory 

	field_typeset (f: IS_FACTORY; i: INTEGER): detachable IS_SEQUENCE [IS_TYPE]
		do
			f.set_field_typeset (Current, i)
			Result := f.last_typeset
		end

feature {IS_NAME} -- Implementation
	
	fast_name: STRING_8
	
feature -- Instance sizes 

	instance_bytes: NATURAL
			-- Memory size (in bytes) of instances of the current type. 

	field_bytes: NATURAL
		note
			return: "Memory size (in bytes) of objects within other objects."
		do
			if is_subobject then
				Result := instance_bytes
			else
				Result := pointer_bytes.to_natural_32
			end
		ensure
			not_negative: 0 <= Result
			when_expanded: is_subobject implies Result = instance_bytes
		end

	allocate: POINTER
			-- Pointer to a function to allocate a new object of the type. 

feature -- Comparison 

	is_equal (other: IS_TYPE): BOOLEAN
		note
			return: "Comparison by ident."
		do
			Result := ident = other.ident
		end

	is_less alias "<" (other: IS_TYPE): BOOLEAN
		note
			return: "Comparison by ident."
		do
			Result := ident < other.ident
		end

	less_by_name (other: IS_TYPE): BOOLEAN
		note
			return: "Comparison by name."
		local
			i, n, sign: INTEGER
		do
			n := other.generic_count.min (generic_count)
			from 
				i := 0
				sign := class_name.three_way_comparison (other.class_name)
				if sign = 0 then
					sign := flags.three_way_comparison (other.flags)
				end
			until sign /= 0 or else i = n loop
				if generic_at (i) < other.generic_at (i) then
					sign := -1
				elseif other.generic_at (i) < generic_at (i) then
					sign := 1
				end
				i := i + 1
			end
			Result := sign < 0
			if not Result and then sign = 0 then
				Result := n < other.generic_count
			end
		end

	conformance (other: IS_TYPE): INTEGER
		note
			return:
			"[
			 How good does `Current' conform to `other'?
			 `Result=0' means exact match, `Result=Maximum_integer' means no match,
			 i.e. assignment like `other_obj:=current_obj' is not possible.
			 ]"
		local
			penalty: INTEGER
			i, ng: INTEGER
		do
			if attached {IS_NORMAL_TYPE} Current as normal
				and then attached {IS_NORMAL_TYPE} other as o
			 then
				Result := normal.base_class.descendance (o.base_class)
			elseif not STRING_.same_string (class_name, other.class_name) then
				Result := {INTEGER}.max_value
			end
			if Result < {INTEGER}.max_value then
				i := generic_count 
				ng := other.generic_count - i
				if is_tuple and then ng > 0 then
					Result := Result + ng
					ng := 0
				end
				if ng = 0 then
					from
					until Result = {INTEGER}.max_value or else i = 0 loop
						i := i - 1
						penalty := other.generic_at (i).conformance (generics [i])
						if penalty = {INTEGER}.max_value then
							Result := penalty
						else
							Result := Result + penalty
						end
					end
				end
			end
			if is_basic and then Result < {INTEGER}.max_value then
				if ident = other.ident then
					Result := 0
				elseif other.instance_bytes > 0 then
					inspect ident
					when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
						inspect other.ident
						when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
							Result := (2 + instance_bytes // other.instance_bytes).to_integer_32
						else
						end
					else
					end
				end
			end
		ensure
			not_negative: Result >= 0
		end

	frozen conforms_to_type (other: IS_TYPE): BOOLEAN
		note
			return:
			"[
			 Does type described by `Current' conform to type
			 described by `other'?
			 ]"
		do
			Result := does_effect (other)
			if not Result then
				Result := conformance (other) < {INTEGER}.max_value
			end
		end

	frozen does_effect (other: IS_TYPE): BOOLEAN
		note
			return:
			"[
			 Does type described by `Current' effect the type
			 described by `other'?
			 ]"
		local
			i: INTEGER
		do
			from
				i := other.effector_count
			until Result or else i = 0 loop
				i := i - 1
				Result := Current = other.effector_at (i)
			end
		end

feature -- Searching 

	field_by_name (nm: READABLE_STRING_8): detachable like field_at
		note
			return:
			"[
			 `Current's field of given name. 
			 `Void' if no such field exists.
			 ]"
			nm: "wanted field name"
		local
			a: like field_at
			i: INTEGER
		do
			from
				i := field_count
			until i = 0 loop
				i := i - 1
				a := field_at (i)
				if a.has_name (nm) then
					Result := a
					i := 0
				end
			end
		ensure
			when_found: attached Result as r implies r.has_name (nm)
									and then attached fields as aa and then aa.has (r)
		end

	routine_by_name (nm: READABLE_STRING_8; as_create: BOOLEAN): detachable like routine_at
		note
			return:
			"[
			 Routine in `Current's class of given name. 
			 `Void' if no such routine exists.
			 ]"
			nm: "wanted routine name"
			as_create: "look for creation routines only"
		local
			ri: like routine_at
			i: INTEGER
		do
			from
				i := routine_count
			until i = 0 loop
				i := i - 1
				ri := routine_at (i) 
				if ri.has_name (nm) and then ri.is_creation = as_create then
					Result := ri
					i := 0
				end
			end
		ensure
			when_found: attached Result as r implies r.has_name (nm)
									and then attached routines as rr and then rr.has (r)
		end

	push_type (t: IS_TYPE)
		do
			type_stack.push (t)
		ensure
			stack_size: type_stack.count = old type_stack.count + 1
		end

	top_type: IS_TYPE
		do
			Result := type_stack.top
		ensure
			on_top: Result = type_stack.top
			stack_size: type_stack.count = old type_stack.count
		end

	pop_types (n: INTEGER)
		note
			action: "Pop `n' types from the `type_stack'."
		require
			not_negative: n >= 0
		do
			if n > 0 then
				type_stack.pop (n)
			end
		ensure
			type_stack_size: type_stack.count = old type_stack.count - n
		end

	routine_by_signature (res: IS_LOCAL; na: INTEGER; previous: detachable like routine_at): detachable like routine_at
		note
			return:
			"[
			 Routine in `Current's class of given argument types 
			 (which must have been pushed previously to the type_stack)
			 and result type. Result is the next routine found
			 (or `Void' if no more such routines).
			 ]"
			res: "wanted result type (`Void' in case of a procedure)"
			na: "number of arguments"
			previous: "end of previous search (`Void' for the first call)."
		require
			na_not_negative: na >= 0
		local
			i, k, l, n: INTEGER
		do
			n := type_stack.count - na
			from
				i := routine_count
			until Result = previous or else i = 0 loop
				i := i - 1
				Result := routine_at (i)
			end
			from
				Result := Void
			until attached Result or else i = 0 loop
				i := i - 1
				Result := routine_at (i)
				if attached Result as r then
					if r.type /= res.type then
						Result := Void
					elseif r.argument_count /= na then
						Result := Void
					else
						from
							k := na
						until k = 0 loop
							k := k - 1
							if attached r.arg_at (k) as ak and then ak.type = type_stack.below_top (l) then
								Result := Void
								k := 0
							else
								k := k - 1
							end
							l := l + 1
						end
					end
				end
			end
		end

feature -- Output 

	append_name (str: STRING)
		local
			i, n: INTEGER
		do
			str.append (class_name)
			n := generic_count
			if n > 0 then
				str.extend ('[')
				from
				until i = n loop
					if i > 0 then
						str.extend (',')
					end
					generic_at (i).append_name (str)
					i := i + 1
				end
				str.extend (']')
			end
		end

	append_indented (s: STRING; indent, indent_increment: INTEGER)
		note
			action: "Printable format of `Current' closed by a new line character."
			s: "STRING to be extended"
			indent: "size of indentation"
		require
			indent_not_negative: indent >= 0
			increment_not_negative: indent_increment >= 0
		local
			i, j, n, indent2: INTEGER
		do
			pad_right (s, indent)
			n := field_count
			s.extend ('%N')
			if n > 0 then
				indent2 := indent + indent_increment
				from
					i := 0
				until i = n loop
					from
						j := indent2
					until j = 0 loop
						j := j - 1
						s.extend (' ')
					end
					field_at (i).append_name (s)
					s.extend ('%N')
					i := i + 1
				end
			end
		end

feature -- Status setting 

	set_bytes (s: NATURAL)
		note
			action:
				"Set `instance_bytes' to 's'."
		require
			s_not_negative: s >= 0
		do
			instance_bytes := s
		ensure
			instance_bytes_set: instance_bytes = s
		end

	set_default (d: POINTER)
		do
			default_instance := d
		ensure
			default_instance_set: default_instance = d
		end

	set_allocate (a: POINTER)
		do
			allocate := a
		ensure
			alocate_set: allocate = a
		end

	adapt_flags (other: IS_TYPE)
		require
			same_name: other.class_name.is_equal (class_name)
		do
			flags := flags | other.flags
		ensure
			flags_set: flags = old flags | other.flags
		end

feature -- HASHABLE

	hash_code: INTEGER
		do
			Result := internal_hash_code
			if Result = 0 then
				Result := ident
				if Result = 0 then
					Result := out.hash_code
				end
				internal_hash_code := Result
			end
		end
	
feature {IS_RUNTIME_SYSTEM}

	default_instance: POINTER
	
feature {IS_BASE} -- Implementation 

	generics: detachable IS_SEQUENCE [like generic_at]

	effectors: detachable IS_SET [like effector_at]

	fields: detachable IS_SEQUENCE [like field_at]

	constants: detachable IS_SEQUENCE [like constant_at]

	routines: detachable IS_SEQUENCE [like routine_at]

	type_stack: IS_STACK [IS_TYPE]
		once
			create Result
		end

	internal_has_code: INTEGER
	
invariant

	ident_not_negative: ident >= 0

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
