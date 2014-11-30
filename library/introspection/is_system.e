note

	description: "Abstract descriptor of an Eiffel system."

deferred class IS_SYSTEM

inherit

	IS_NAME
		redefine
			default_create
		end

	PLATFORM
		undefine
			copy,
			is_equal,
			out
		redefine
			default_create
		end

feature {NONE} -- Initialization 

	default_create
		do
			creation_time := actual_time_as_integer
			create all_classes.make (0, Void)
			create all_types.make (0, Void)
			create all_agents
			create all_onces
			create all_constants
			create type_stack
			compiler := "GEC"
		end

	make (nm: READABLE_STRING_8; fl: INTEGER;
				root: like root_type; proc: like root_creation_procedure;
				any, none: attached like type_at;
				c: like all_classes; t: like all_types;
				o: like all_onces; u: like all_constants)
		note
			action: "Create the descriptor."
		require
			same_size: c.count = t.count
		do
			default_create
			fast_name := nm.twin
			flags := fl
			all_classes.copy (c)
			all_types.copy (t)
			all_onces.copy (o)
			all_constants.copy (u)
			root_creation_procedure := proc
			root_type := root
		ensure
			name_set: has_name (nm)
			flags_set: flags = fl
		end

feature -- Access 

	flags: INTEGER

	has_foreign_main: BOOLEAN
		note
			return: "Is the system's main routine written in a foreign language?"
		do
			Result := (flags & Foreign_flag) /= 0
		end

	has_gc: BOOLEAN
		note
			return: "Is the system a SCOOP application?"
		do
			Result := (flags & No_gc_flag) = 0
		end

	is_scoop: BOOLEAN
		note
			return: "Is the system a SCOOP application?"
		do
			Result := (flags & Scoop_flag) /= 0
		end

	is_debugging: BOOLEAN
		note
			return: "Has the system compiled for debugging?"
		do
			Result := (flags & Debugger_flag) /= 0
		end

	assertion_check: NATURAL
			-- Degree of assertion checking. 

	class_count: INTEGER
		note
			return: "Number of classes in the system."
		do
			Result := all_classes.count
		ensure
			not_negative: 0 <= Result
		end

	valid_class (i: INTEGER): BOOLEAN
		note
			return: "Is `i' the index of a class?"
		do
			Result := 0 <= i and then i < class_count 
		ensure
			validity: Result = (0 <= i and then i < class_count)
		end

	class_at (i: INTEGER): detachable IS_CLASS_TEXT
		note
			return: "`i'-th class of the system."
		require
			valid_class: valid_class (i)
		do
			Result := all_classes [i]
		end

	type_count: INTEGER
		note
			return: "Number of types in the system."
		do
			if attached all_types as ts then
				Result := ts.count
			end
		ensure
			not_negative: 0 <= Result
		end

	valid_type (i: INTEGER): BOOLEAN
		note
			return: "Is `i' the index of a type?"
		do
			Result := 0 <= i and then i < type_count and then attached all_types as ts and then attached ts [i]
		ensure
			validity: Result = (0 <= i and then i < type_count and then attached all_types as ts and then attached ts [i])
		end

	type_at (i: INTEGER): detachable IS_TYPE
		note
			return: "`i'-th type of the system"
		require
			valid_type: valid_type (i)
		do
			Result := all_types [i]
		end

	root_creation_procedure: detachable IS_ROUTINE
			-- Routine creating the root object. 

	root_type: like type_at
			-- Type of root object. 

	boolean_type: attached like type_at
		note
			return: "Descriptor of type `BOOLEAN'"
		local
			t: like type_at
		do
			if valid_type (Boolean_ident) then
				t := type_at (Boolean_ident)
			end
			check attached t end
			Result := t
		end

	character_type: attached like type_at
		note
			return: "Descriptor of type `CHARACTER'"
		local
			t: like type_at
		do
			if valid_type (Character_ident) then
				t := type_at (Character_ident)
			end
			check attached t end
			Result := t
		end

	integer_type: attached like type_at
		note
			return: "Descriptor of type `INTEGER'"
		local
			t: like type_at
		do
			if valid_type (Integer_ident) then
				t := type_at (Integer_ident)
			end
			check attached t end
			Result := t
		end

	real_type: attached like type_at
		note
			return: "Descriptor of type `REAL_32'"
		local
			t: like type_at
		do
			if valid_type (Real32_ident) then
				t := type_at (Real32_ident)
			end
			check attached t end
			Result := t
		end

	double_type: attached like type_at
		note
			return: "Descriptor of type `REAL_64'"
		local
			t: like type_at
		do
			if valid_type (Real64_ident) then
				t := type_at (Real64_ident)
			end
			check attached t end
			Result := t
		end

	pointer_type: attached like type_at
		note
			return: "Descriptor of type `POINTER'"
		local
			t: like type_at
		do
			if valid_type (Pointer_ident) then
				t := type_at (Pointer_ident)
			end
			check attached t end
			Result := t
		end

	string_type: like type_at
		note
			return: "Descriptor of type `STRING'"
		do
			if valid_type (String8_ident) then
				Result := type_at (String8_ident)
			end
		end

	string32_type: like type_at
		note
			return: "Descriptor of type `STRING'"
		do
			if valid_type (String32_ident) then
				Result := type_at (String32_ident)
			end
		end

	char32_type: attached like type_at
		note
			return: "Descriptor of type `CHARACTER_32'"
		local
			t: like type_at
		do
			if valid_type (Char32_ident) then
				t := type_at (Char32_ident)
			end
			check attached t end
			Result := t
		end

	int8_type: attached like type_at
		note
			return: "Descriptor of type `INTEGER_8'"
		local
			t: like type_at
		do
			if valid_type (Int8_ident) then
				t := type_at (Int8_ident)
			end
			check attached t end
			Result := t
		end

	int16_type: attached like type_at
		note
			return: "Descriptor of type `INTEGER_16'"
		local
			t: like type_at
		do
			if valid_type (Int16_ident) then
				t := type_at (Int16_ident)
			end
			check attached t end
			Result := t
		end

	int32_type: attached like type_at
		note
			return: "Descriptor of type `INTEGER_32'"
		local
			t: like type_at
		do
			if valid_type (Int32_ident) then
				t := type_at (Int32_ident)
			end
			check attached t end
			Result := t
		end

	int64_type: attached like type_at
		note
			return: "Descriptor of type `INTEGER_64'"
		local
			t: like type_at
		do
			if valid_type (Int64_ident) then
				t := type_at (Int64_ident)
			end
			check attached t end
			Result := t
		end

	nat8_type: attached like type_at
		note
			return: "Descriptor of type `NATURAL_8'"
		local
			t: like type_at
		do
			if valid_type (Nat8_ident) then
				t := type_at (Nat8_ident)
			end
			check attached t end
			Result := t
		end

	nat16_type: attached like type_at
		note
			return: "Descriptor of type `NATURAL_16'"
		local
			t: like type_at
		do
			if valid_type (Nat16_ident) then
				t := type_at (Nat16_ident)
			end
			check attached t end
			Result := t
		end

	nat32_type: attached like type_at
		note
			return: "Descriptor of type `NATURAL_32'"
		local
			t: like type_at
		do
			if valid_type (Nat32_ident) then
				t := type_at (Nat32_ident)
			end
			check attached t end
			Result := t
		end

	nat64_type: attached like type_at
		note
			return: "Descriptor of type `NATURAL_64'"
		local
			t: like type_at
		do
			if valid_type (Nat64_ident) then
				t := type_at (Nat64_ident)
			end
			check attached t end
			Result := t
		end

	any_type: IS_NORMAL_TYPE
		note
			return: "Descriptor of type ANY."
		deferred
		end
	
	none_type: like any_type
		note
			return: "Descriptor of type NONE."
		deferred
		end
	
	agent_count: INTEGER
		note
			return: "Number of agent type function descriptions"
		do
			if attached all_agents as aa then
				Result := aa.count
			end
		end

	valid_agent (i: INTEGER): BOOLEAN
		note
			return: "Is `i' the index of an agent type?"
			i: ""
		do
			Result := 0 <= i and then i < agent_count and then attached all_agents [i]
		ensure
			vaidity: Result = (0 <= i and then i < agent_count and then attached all_agents as aa and then attached aa [i])
		end

	agent_at (i: INTEGER): IS_AGENT_TYPE
		note
			return: "`i'-th agent type of the system"
		require
			valid_type: valid_agent (i)
		do
			Result := all_agents [i]
		end

	once_count: INTEGER
		note
			return: "Number of once function descriptions"
		do
			if attached all_onces as os then
				Result := os.count
			end
		end

	valid_once (i: INTEGER): BOOLEAN
		note
			return: "Is `i' the index of a once value?"
		do
			Result := 0 <= i and then i < once_count
		ensure
			vaidity: Result = (0 <= i and then i < once_count)
		end

	once_at (i: INTEGER): IS_ONCE
		note
			return: "`i'-th once function of the system."
		require
			valid_once: valid_once (i)
		do
			Result := all_onces [i]
		end

	search_once (a: detachable ANY): detachable like once_at
		do
		end

	constant_count: INTEGER
		note
			return: "Number of constant values."
		do
			Result := all_constants.count
		ensure
			not_negative: Result >= 0
		end

	constant_at (i: INTEGER): IS_CONSTANT
		require
			valid_index: 0 < i and then i < constant_count
		do
			Result := all_constants [i]
		end

	search_unique (i: INTEGER): detachable like constant_at
		local
			c: IS_CONSTANT
			n: INTEGER
		do
			from
				n := constant_count
			until attached Result or else i = 0 loop
				n := n - 1
				c := all_constants[n]
				if c.type.is_integer and then c.integer_32_value = i then
					Result := c
				end
			end
		end
	
	compilation_time: INTEGER_64
			-- CUT time when the system has been Eiffel compiled. 

	creation_time: INTEGER_64
			-- CUT time when the system has been created. 

	compiler: STRING
			-- Comiler name and version.
	
feature -- Searching 

	class_by_name (nm: READABLE_STRING_8): detachable like class_at
		note
			return:
			"[
			 Descriptor of the class of name `nm';
			 `Void' if no class has this name.
			 ]"
		local
			i: INTEGER
		do
			from
				i := class_count
			until i = 0 loop
				i := i - 1
				if attached class_at (i) as c and then c.has_name (nm) then
					Result := c
					i := 0
				end
			end
		ensure
			when_found: attached Result as r implies r.has_name (nm) and then all_classes.has (r)
		end

	type_stack_count: INTEGER

	push_type (id: INTEGER)
		require
			not_negative: id >= 0
		do
			if attached type_at (id) as t then
				type_stack.push (t)
			else
				type_stack.push (Void)
			end
			type_stack_count := type_stack.count
		ensure
			stack_size: type_stack_count = old type_stack_count + 1
		end

	top_type: attached like type_at
		require
			type_stack_not_empty: type_stack_count > 0
		do
			Result := type_stack.top
		ensure
			stack_size: type_stack_count = old type_stack_count
			on_top: Result = type_stack [type_stack_count - 1]
		end

	below_top_type (n: INTEGER): attached like type_at
		require
			enough_items: n < type_stack_count
		do
			Result := type_stack.below_top (n)
		ensure
			stack_size: type_stack_count = old type_stack_count
		end
	
	pop_types (n: INTEGER)
		note
			action: "Pop `n' types from the `type_stack'."
		require
			not_negative: n >= 0
			type_stack_large_enough: n <= type_stack_count
		do
			if n > 0 then
				type_stack.pop (n)
				type_stack_count := type_stack.count
			end
		ensure
			type_stack_size: type_stack.count = old type_stack.count - n
		end

	extract_types (n: INTEGER; reverse, popped: BOOLEAN): IS_SEQUENCE [attached like type_at]
		note
			action: "Create `Result' filled by top `n' entries of `type_stack'."
		require
			n_valid: 0 <= n and n <= type_stack_count
		do
			create Result.make_from_array (n, type_stack, type_stack.count - n)
			if popped then
				pop_types (n)
			end
		ensure
			result_count: Result.count = n
			direction: (reverse implies Result [0] = old top_type)
								 and (not reverse implies Result [n-1] = old top_type) 
		end
	
	type_by_class_and_generics (nm: READABLE_STRING_8; gc: INTEGER; attac: BOOLEAN): like type_at
		note
			return:
			"[
			 Descriptor of the type with base class name `nm'
			 and actual generic `gc' parameters (pushed by `push_type').
			 `Void' if no such type exists.
			 ]"
		require
			class_not_void: not nm.is_empty
			gc_not_negative: gc >= 0
			type_stack_large_enough: gc <= type_stack_count
		local
			this: like type_at
			penalty, p, m: INTEGER
			j, l, n: INTEGER
		do
			from
				n := type_count
				m := {INTEGER}.max_value
			until m = 0 or else n = 0 loop
				n := n - 1
				this := Void
				if attached all_types [n] as t then
					if t.generic_count = gc and then STRING_.same_string( nm, t.class_name) then
						this := t
						if t.is_attached /= attac then
							penalty := 0
						else
							penalty := 1
						end
					end
				end
				from
					l := gc
					j := 0
				until not attached this as t or else j = gc loop
					l := l - 1
					if attached type_stack.below_top (l) as g then
						p := t.generic_at (j).conformance (g)
					else
						p := {INTEGER}.max_value
					end
					if p < {INTEGER}.max_value - penalty then
							penalty := penalty + p
					else
						this := Void
					end
					j := j + 1
				end
				if attached this and then penalty < m then
					Result := this
					m := penalty
				end
			end
		ensure
			when_found: attached Result as r implies all_types.has (r)
			type_stack_size: type_stack.count = old type_stack.count
		end

	tuple_type_by_generics (gc: INTEGER; attac: BOOLEAN): detachable IS_TUPLE_TYPE
		note
			return:
				"[
				 Descriptor of a tuple type that matches best the
				 actual generic `gc' parameters (pushed by `push_type').
				 ]"
		require
			not_negative: gc >= 0
			type_stack_large_enough: gc <= type_stack_count
		local
			this: like type_at
			penalty, p, m: INTEGER
			i, k, l, n: INTEGER
		do
			m := {INTEGER}.max_value
			from
				n := type_count
			until m = 0 or else n = 0 loop
				n := n - 1
				if valid_type (n) then
					this := type_at (n)
					penalty := 0
					check attached this end
					k := this.generic_count
					if not (this.is_tuple and then k <= gc) then
						this := Void
					else
						penalty := penalty + (gc - k)
						check not attached this end
						from
							l := gc - 1
							i := 0
						until not attached this or else i = k loop
							p := type_stack.below_top (l).conformance (this.generic_at (i))
							if p < {INTEGER}.max_value then
								penalty := penalty + p
							else
								this := Void
							end
							l := l - 1
							i := i + 1
						end
					end
				end
				if attached {IS_TUPLE_TYPE} this as t and then penalty < m then
					Result := t
					m := penalty
				end
			end
		ensure
			when_found: attached Result as r implies r.is_tuple and then all_types.has (r)
		end

	special_type_by_item_type (it: IS_TYPE; attac: BOOLEAN): detachable IS_SPECIAL_TYPE
		note
			return: "Descriptor of the SPECIAL type of `it' items."
		do
			push_type (it.ident)
			if attached {IS_SPECIAL_TYPE} type_by_class_and_generics (once "SPECIAL", 1, attac) as s then
				Result := s
			end
			pop_types (1)
		ensure
			when_found: attached Result as r implies r.is_special and then r.generic_at (0) = it and then all_types.has (r)
		end

	agent_by_base_and_routine (base: IS_TYPE; ocp, nm: READABLE_STRING_8): detachable IS_AGENT_TYPE
		note
			return: "Agent of specific settings."
			base: "base type wanted"
			ocp: "open-closed-pattern wanted"
			nm: "routine name wanted"
		local
			i: INTEGER
		do
			from
				i := type_count
			until i = 0 loop
				i := i - 1
				if attached {IS_AGENT_TYPE} type_at (i) as a 
					and then base = a.base
					and then ocp.is_equal (a.open_closed_pattern)
					and then STRING_.same_string(a.routine_name, nm)
				 then
					Result := a
					i := 0
				end
			end
		ensure
			when_found: attached Result as r implies nm.is_equal (r.routine_name)
									and then r.open_closed_pattern.is_equal (ocp)
									and then r.base = base and then all_types.has (r)
		end

	type_by_name (type_name: READABLE_STRING_8; attac: BOOLEAN): detachable like type_at
		note
			return: "Type of specific settings."
			type_name: "wanted name"
		local
			nm: STRING_8
		do
			nm := type_name
			nm.right_adjust
			nm.left_adjust
			Result := type_by_subname (nm, attac)
		end

	once_by_name_and_class (nm: READABLE_STRING_8; cls: like class_at): detachable like once_at
		note
			return: "Once call of specific settings."
			nm: "wanted function name"
			cls: "wanted defining class"
		local
			i: INTEGER
		do
			from
				i := once_count
			until i = 0 loop
				i := i - 1
				if attached once_at (i) as o then
					if o.has_name (nm) and then cls.is_descendant (o.home) then
						Result := o
						i := 0
					end
				end
			end
		ensure
			when_found: attached Result as r implies r.has_name (nm)
									and then all_onces.has (r)
		end

feature -- Output 

	append_out (s: STRING)
		note
			action: "String format listing all types."
			s: "STRING to be extended"
		local
			td: like type_at
			i, n: INTEGER
		do
			n := type_count
			from
			until i = n loop
				if valid_type (i) then
					td := type_at (i)
					check attached td end
					s.append (i.out)
					s.extend (' ')
					td.append_name (s)
					s.append_character ('%N')
				end
				i := i + 1
			end
		end

	append_alphabetically (s: STRING)
		note
			action: "String format listing all types in alphabetic order."
			s: "STRING to be extended"
		local
			td: attached like type_at
			list: IS_SEQUENCE [IS_TYPE]
			i, n: INTEGER
		do
			from
				n := type_count
				create list.make (n, any_type)
			until i = n loop
				if valid_type (i) and then attached type_at (i) as t then
					list.add (t)
				end
				i := i + 1
			end
			check attached list end	
			list.sort (agent compare_names)
			list.clean 
			from
				i := 0
				n := list.count
			until i = n loop
				td := list [i]
				s.append_integer (td.ident)
				s.extend (' ')
				td.append_name (s)
				s.append_character ('%N')
				i := i + 1
			end
		end

feature {IS_BASE} -- Implementation 

	all_classes: IS_SPARSE_ARRAY [like class_at]

	all_types: IS_SPARSE_ARRAY [like type_at]

	all_agents: IS_SEQUENCE [like agent_at]

	all_onces: IS_SEQUENCE [like once_at]

	all_constants: IS_SEQUENCE [like constant_at]

feature {IS_NAME} -- Implementation 

	fast_name: STRING_8

feature {NONE} -- Implementation 

	type_stack: IS_STACK [attached like type_at]

	type_by_subname (nm: STRING_8; attac: BOOLEAN): like type_at
		note
			return:
			"[
			 Descriptor of the type whose name is the leading portion of `nm'.
			 `Void' if no type has this name.
			 Caution: the function has a side-effect: it consumes `nm'.
			 ]"
		local
			cls_name: STRING_8
			l, gc: INTEGER
			bracket_awaited: BOOLEAN
		do
			l := nm.index_of ('[', 1)
			if l > 0 then
				bracket_awaited := True
			else
				l := nm.index_of (']', 1)
				if l = 0 then
					l := nm.index_of (',', 1)
					if l = 0 then
						l := nm.count + 1
					end
				end
			end
			l := l - 1
			cls_name := nm.substring (1, l)
			cls_name.right_adjust
			cls_name.to_upper
			if attached class_by_name (cls_name) as cls then
				nm.remove_head (l)
				from
				until nm.is_empty or else nm [1] = ']' loop
					nm.remove (1)
					nm.left_adjust
					if attached type_by_subname (nm, False) as g then
						push_type (g.ident)
						gc := gc + 1
					else
						nm.wipe_out
					end
				end
				if bracket_awaited and then not nm.is_empty then
					nm.remove (1)
				end
				Result := type_by_class_and_generics (cls.fast_name, gc, attac)
				pop_types (gc)
			else
				nm.wipe_out
			end
		end

	compare_names (u, v: attached like type_at): BOOLEAN
		local
			u_name, v_name: STRING
			i, n: INTEGER
		do
			u_name := u.class_name
			v_name := v.class_name
			if u_name < v_name then
				Result := True
			elseif u_name = v_name then
				from
					n := u.generic_count
				until Result or else i = n loop
					Result := compare_names (u.generic_at (i), v.generic_at (i))
					i := i + 1
				end
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
