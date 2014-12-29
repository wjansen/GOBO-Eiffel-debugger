note

	description: "Compile time description of an Eiffel system."

class ET_IS_SYSTEM

inherit
	
	IS_SYSTEM
		redefine
			class_at,
			type_at,
			agent_at,
			once_at,
			constant_at,
			root_creation_procedure
		end

	ET_IS_ORIGIN [attached ET_DYNAMIC_SYSTEM, IS_SYSTEM]
		redefine
			pre_store,
			post_store
		end
	
	IS_SET [attached ET_IS_TYPE]
		rename
 			make as typeset_make,
			data as typeset_data,
			count as typeset_count,
			add as typeset_add,
			default_sort as typeset_sort,
			internal_hash_code as type_set_hash_code
		undefine
			default_create,
			hash_code,
			copy,
			is_equal,
			out
		end

	KL_EQUALITY_TESTER [IS_SET [attached ET_IS_TYPE]]
		rename
			test as test_effectors
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			test_effectors
		end

	KL_GOBO_VERSION
		undefine
			default_create,
			copy,
			is_equal,
			out
		end
	
create

	declare, declare_from_pattern

feature {NONE} -- Initialization 

	declare (o: like origin; fl: INTEGER; a: NATURAL;
			needs: like needed_categories)
		note
			action: "Create object corresponding to `o'."
			fl: "flags"
			a: "code of assertion check"
			needs: "[
							collection of values from
							`With_root_creation',
							`With_parents', `With_actionable', `With_texts ', 
							`With_once_values', `With_effectors', `With_attributes',
							`With_routines', `With_constants', `With_default_creation',
							`With_locals', `With_signatures', `With_typeset',
							`With_c_names'
							]"
		local
			cls: ET_CLASS
			i, n: INTEGER
		do
			compilation_time := actual_time_as_integer
			make_origin (o)
			default_create
			needed_categories := needs
			flags := fl
			assertion_check := a
			create {STRING} fast_name.make_from_string (o.current_system.system_name)
			create origin_table.make (1001)
			create no_ident_types.make (17)
			n := o.dynamic_types.count
			all_types.resize (n)
			name_pool.reset
			if needs_typeset then
				create typeset_table.make (1001)
				typeset_table.set_key_equality_tester (Current)
				create type_stack
			else
				create typeset_table.make (1)
			end
			force_type (origin.none_type)
			if attached {like none_type} last_type as t then
				none_type := t
			end
			force_type (origin.any_type)
			if attached {like any_type} last_type as t then
				any_type := t
			end
			if needs_actionable then
				from
					i := o.dynamic_types.count
				until i = 0 loop
					cls := o.dynamic_types.item (i).base_class
					if STRING_.same_string (cls.upper_name, actionable_name) then
						force_class (cls)
						actionable_class := last_class
						actionable_class.add_flag (Actionable_flag)
						i := 0 
					else
						i := i - 1
					end
				end
			end
			if needs & With_root_creation /= 0 then
				force_type (o.root_type)
				root_type := last_type
				if attached root_type as rt
					and then attached o.root_creation_procedure as ocr
				 then
					if attached rt.routine_by_origin (ocr, Current) as r then
						root_creation_procedure := r
					else
						rt.force_routine (ocr, True, Current)
						root_creation_procedure := rt.last_routine
					end
				end
			else
				needed_categories := 0
				force_type (o.root_type)
				root_type := last_type
				needed_categories := needs
			end
			compiler := "GEC " + Version_number
		ensure
			origin_set: origin = o
		end

	declare_from_pattern (p: ET_IS_SYSTEM; names: like class_name_dictionary)
		note
			action: "Create object corresponding to `p'."
		do
			class_name_dictionary := names
			declare (p.origin, p.flags, p.assertion_check, p.needed_categories)
		end
	
feature -- Initialization 

	define
		local
			old_onces: like all_onces
			oi: like once_at
			i: INTEGER
		do
			if not defined then
				defined := True
				from
					i := class_count
				until i = 0 loop
					i := i - 1
					if attached all_classes [i] as ci then
						ci.define (Current)
					end
				end
				resolve_no_ident_types
				from
					i := type_count
				until i = 0 loop
					i := i - 1
					if attached all_types [i] as ti then
						ti.define (Current)
					end
				end
				from
					i := once_count
					old_onces := all_onces
					if i > 0 then
						create all_onces.make (i, old_onces[0])
					end
				until i = 0 loop
					i := i - 1
					oi := old_onces [i]
					if oi.origin.is_generated then 
						oi.define (Current)
						-- Workaround: once_call may be created erroneously
						all_onces.add (oi)
					end
				end
				all_onces.sort (agent once_less)
				all_constants.sort (agent const_less)
			end
		end

feature -- Constants and once functions

	With_root_creation: INTEGER = 1

	With_parents: INTEGER = 2

	With_texts: INTEGER = 4

	With_once_values: INTEGER = 8

	With_effectors: INTEGER = 0x10

	With_attributes: INTEGER = 0x20

	With_routines: INTEGER = 0x40

	With_default_creation: INTEGER = 0x80

	With_constants: INTEGER = 0x100

	With_locals: INTEGER = 0x200

	With_signatures: INTEGER = 0x400

	With_typeset: INTEGER = 0x800

	With_actionable: INTEGER = 0x1000

	With_c_names: INTEGER = 0x2000

	Actionable_name: STRING = "PC_ACTIONABLE"
	
feature -- Access 

	any_type: attached ET_IS_NORMAL_TYPE

	none_type: like any_type

	needs_root_creation: BOOLEAN
		do
			Result := needed_categories & With_root_creation = With_root_creation
		end

	needs_parents: BOOLEAN
		do
			Result := needed_categories & With_parents = With_parents
				or else needs_actionable
		end

	needs_feature_texts: BOOLEAN
		do
			Result := needed_categories & With_texts = With_texts
		end

	needs_once_values: BOOLEAN
		do
			Result := needed_categories & With_once_values = With_once_values
		end

	needs_effectors: BOOLEAN
		do
			Result := needed_categories & With_effectors = With_effectors
		end

	needs_attributes: BOOLEAN
		do
			Result := needed_categories & With_attributes = With_attributes
		end

	needs_routines: BOOLEAN
		do
			Result := needed_categories & With_routines = With_routines
		end

	needs_default_creation: BOOLEAN
		do
			Result := needed_categories & With_default_creation = With_default_creation
		end

	needs_constants: BOOLEAN
		do
			Result := needed_categories & With_constants = With_constants
		end

	needs_locals: BOOLEAN
		do
			Result := needed_categories & With_locals = With_locals
		end

	needs_signatures: BOOLEAN
		do
			Result := needed_categories & With_signatures = With_signatures
		end

	needs_typeset: BOOLEAN
		do
			Result := needed_categories & With_typeset = With_typeset
		end

	needs_actionable: BOOLEAN
		do
			Result := needed_categories & With_actionable = With_actionable
		end

	needs_c_names: BOOLEAN
		do
			Result := needed_categories & With_c_names = With_c_names
		end

	class_at (i: INTEGER): ET_IS_CLASS_TEXT
		do
			Result := all_classes [i]
		end

	special_class: detachable ET_IS_CLASS_TEXT

	tuple_class: detachable ET_IS_CLASS_TEXT

	type_at (i: INTEGER): detachable ET_IS_TYPE
		do
			Result := all_types [i]
		end

	agent_at (i: INTEGER): attached ET_IS_AGENT_TYPE
		do
			Result := all_agents [i]
		end

	once_at (i: INTEGER): attached ET_IS_ONCE
		do
			Result := all_onces [i]
		end

	constant_at (i: INTEGER): attached ET_IS_CONSTANT
		do
			Result := all_constants [i]
		end

	last_class: attached like class_at
			-- Class provided by `force_class'. 

	last_type: attached like type_at
			-- Type provided by `force_type'. 

	last_agent: detachable ET_IS_AGENT_TYPE
			-- Agent type provided by `force_agent'. 

	last_once: detachable like once_at
			-- Once routine provided by `force once'
	
	max_class_ident: INTEGER
			-- Maiximum of class idents. 

	root_creation_procedure: detachable ET_IS_ROUTINE

	actionable_class: like class_at

	origin_table: DS_MULTIARRAYED_HASH_TABLE [IS_NAME, HASHABLE]
			-- Hashtable of diverse ET_IS_* objects for fast access. 

	typeset_table: DS_HASH_TABLE [INTEGER, like type_set]
			-- Table of entities' typesets, the value is a unique integer. 

	typeset_index: INTEGER
	
	names_array: ARRAY [READABLE_STRING_8]
		do
			Result := name_pool.to_array
		end

	index_of_name (s: READABLE_STRING_8): INTEGER
		do
			if name_pool.has (s) then
				Result := name_pool.item (s)
			end
		end
			
feature -- Status setting
	
	add_flag (f: INTEGER)
		do
			flags := flags | f
		ensure
			flag_added: flags & f = f
		end
	
	set_type_max (n: INTEGER)
		do
			all_types.force (Void, n + 1)
		ensure
			type_count_large_enough: type_count > n
		end

	set_special_class (cls: attached like class_at)
		do
			special_class := cls
		ensure
			special_class_set: special_class = cls
		end

	set_tuple_class (cls: attached like class_at)
		do
			tuple_class := cls
		ensure
			tuple_class_set: tuple_class = cls
		end

	set_type (t: attached like type_at)
		local
			id: INTEGER
		do
			id := t.ident
			if id = 0 then
				no_ident_types.force (t)
			end
			all_types.force (t, id)
		end

	add_constant (c: like constant_at)
		do
			all_constants.add (c)
		ensure
			constant_set: all_constants.has(c)
		end

feature -- Searching 

	class_by_origin (o: ET_CLASS): like last_class
		note
			return: "Current's class having origin `o'."
			o: "original class"
		do
			origin_table.search (o)
			if origin_table.found and then
				attached {attached like last_class} origin_table.found_item as c
			 then
				Result := c
			end
		ensure
			when_found: attached Result as r implies r.origin = o
		end

	type_by_origin (o: ET_DYNAMIC_TYPE): like last_type
		note
			return: "Current's type having origin `o'."
			o: "original type"
		do
			origin_table.search (o)
			if origin_table.found and then
				attached {attached like last_type} origin_table.found_item as t
			 then
				Result := t
			end
		ensure
			when_found: attached Result as r implies r.origin = o
		end

	agent_by_origin (o: ET_AGENT): like last_agent
		note
			return: "Current's agent type having origin `o'."
			o: "original agent"
		do
			origin_table.search (o)
			if origin_table.found and then
				attached {attached like last_agent} origin_table.found_item as a
			 then
				Result := a
			end
		ensure
			when_found: attached Result as r implies r.orig_agent = o
		end
	
	once_by_origin (o: ET_FEATURE): like once_at
		note
			return: "Current's type having origin `o'."
			o: "original once call"
		local
			i: INTEGER
		do
			from
				i := once_count
			until i = 0 loop
				i := i - 1
				if attached all_onces [i] as oi
					and then oi.origin.static_feature.implementation_feature = o
				 then
					Result := oi
					i := 0
				end
			end
		ensure
			when_found: Result /= Void implies Result.origin.static_feature.implementation_feature = o
		end

	constant_by_origin (f: ET_DYNAMIC_FEATURE): detachable like constant_at
		note
			return: "Current's type having origin `f'."
			f: "original constant attribute"
		local
			static, rs: ET_FEATURE
			i: INTEGER
		do
			static := f.static_feature.implementation_feature
			from
				i := constant_count
			until i = 0 loop
				i := i - 1
				Result := all_constants [i]
				rs := Result.origin.static_feature.implementation_feature
				if rs /= static then
					Result := Void
				else
					i := 0
				end
			end
		ensure
			when_found: Result /= Void implies Result.origin = f
		end

feature -- Factory 

	resolve_no_ident_types
		local
			t: attached like type_at
		do
			
			from
			until no_ident_types.is_empty loop
				no_ident_types.start
				t := no_ident_types.item_for_iteration
				t.resolve_ident
				no_ident_types.remove (t)
				set_type (t)
			end
			all_types.force(Void, 0)
		end

	force_class (c: ET_CLASS)
		local
			id: INTEGER
		do
			if attached class_by_origin (c) as last then
				last_class := last
			else
				max_class_ident := max_class_ident + 1
				id := max_class_ident
				create last_class.declare (c, id, Current)
				all_classes.force (last_class, id)
			end
		ensure
			not_void: attached last_class
		end

	force_type (t: ET_DYNAMIC_TYPE)
		local
			last: like last_type
			id: INTEGER
		do
			last := type_by_origin (t)
			if attached last then
			else
				id := t.id
				if t.is_special and then attached {ET_DYNAMIC_SPECIAL_TYPE} t as s then
					create {ET_IS_SPECIAL_TYPE} last.declare (s, id, Current)
				elseif t.is_agent_type then
					create {ET_IS_NORMAL_TYPE} last.declare (t, id, Current)
				elseif attached {ET_DYNAMIC_TUPLE_TYPE} t as u then
					create {ET_IS_TUPLE_TYPE} last.declare (u, id, Current)
				elseif t.is_expanded then
					create {ET_IS_EXPANDED_TYPE} last.declare (t, id, Current)
				else
					create {ET_IS_NORMAL_TYPE} last.declare (t, id, Current)
				end
				set_type (last)
			end
			last_type := last
		ensure
			not_void: attached last_type
		end

	force_agent (a: ET_AGENT; dt: ET_DYNAMIC_TYPE;
			w: attached ET_DYNAMIC_FEATURE; t: ET_DYNAMIC_TYPE; i: INTEGER)
		note
			action:
			"[
			 Search agent corresponding to `a'.
			 Create `last_agent' if not found but its base type is found.
			 ]"
			dt: "declared type"
			w: "enclosing routine of agent clause"
			t: "type hosting the enclosing routine"
			i: "ident of original agent within `w'"
		local
			last: like last_agent
			base: ET_TYPE
			id: INTEGER
		do
			last := agent_by_origin (a)
			if attached last as l and then
				(l.where /= w or else l.in_type /= t or else l.name_id /= i)
			 then
				last := Void
			end
			if attached last then
			elseif attached {ET_GENERIC_CLASS_TYPE} dt.base_type as d then
				base := d.actual_parameters.actual_parameter (1).type
				if attached type_by_origin (origin.dynamic_type (base, d)) then
					id := all_types.count
					create last.declare (a, dt, w, t, i, id, Current)
					all_agents.add (last)
					all_types.force (last, last.ident)
					origin_table.force (last, a)
				end
			end
			last_agent := last
		end

	force_root (root: ET_DYNAMIC_TYPE; proc: detachable ET_DYNAMIC_FEATURE)
		do
			force_type (root)
			root_type := last_type
			if proc /= Void and then attached root_type as rt then
				if attached rt.routine_by_origin (proc, Current) as p then 
					root_creation_procedure := p
				else
					create root_creation_procedure.declare (proc, rt, Current)
				end
			end
		ensure
			root_type_not_void: attached root_type
			root_type_origin: root_type.origin = root
			when_proc: attached proc as p
								 implies attached root_creation_procedure as rcp
								 and then rcp.origin = p
		end

	force_type_from_pattern (t: ET_IS_TYPE)
		local
			params: ET_ACTUAL_PARAMETER_LIST
			types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			last, gen: ET_DYNAMIC_TYPE
			tg: ET_IS_TYPE
			nm: STRING
			i, k, ng: INTEGER
			ok: BOOLEAN
		do
			force_type (t.origin)
			nm := t.class_name
			if class_name_dictionary.has (nm) then
				nm := class_name_dictionary.item (nm)
				ok := False
			else
				ok := True
			end
			ng := t.generic_count
			from
			until i = ng loop
				tg := t.generic_at (i)
				force_type_from_pattern (tg)
				type_stack.push (last_type)
				ok := ok and then last_type = tg
				i := i + 1
			end
			if not ok then
				if attached type_by_class_and_generics (nm, ng, t.is_attached) as lt then
					last_type := lt
				else
					from
						types := origin.dynamic_types
						k := types.count
					until ok or else k = 0 loop
						last := types.item (k)
						ok := STRING_.same_string (last.base_class.upper_name, nm) 
						if ok then
							if ng > 0 and then
								attached {ET_GENERIC_CLASS_TYPE} last.base_type as base
							 then
								from
									params := base.actual_parameters
									i := ng
								until not ok or else i = 0 loop
									gen := origin.dynamic_type (params.actual_parameter (i).type, base)
									ok := type_stack.below_top (ng - i).origin = gen 
									i := i - 1
								end
							elseif attached {ET_TUPLE_TYPE} last.base_type as tt and then
								attached tt.actual_parameters as pp
							 then
								ok := pp.count = ng
								from
									i := ng
								until not ok or else i = 0 loop
									gen := origin.dynamic_type (pp.actual_parameter (i).type, tt)
									ok := type_stack.below_top (ng - i).origin = gen 
									i := i - 1
								end
							else
								ok := ng = 0
							end
						end
						k := k - 1
					end
					if ok then
						if t.is_subobject and then attached {ET_IS_EXPANDED_TYPE} t as et then
							create {ET_IS_EXPANDED_TYPE} last_type.declare_from_pattern (last, et, Current)
						elseif t.is_normal and then attached {ET_IS_NORMAL_TYPE} t as nt then
							create {ET_IS_NORMAL_TYPE} last_type.declare_from_pattern (last, nt, Current)
						elseif t.is_special and then attached {ET_IS_SPECIAL_TYPE} t as st
							and then attached {ET_DYNAMIC_SPECIAL_TYPE} last as sl
						 then
							create {ET_IS_SPECIAL_TYPE} last_type.declare_from_pattern (sl, st, Current)
						elseif t.is_tuple and then attached {ET_IS_TUPLE_TYPE} t as tt
							and then attached {ET_DYNAMIC_TUPLE_TYPE} last as tl
						 then
							create {ET_IS_TUPLE_TYPE} last_type.declare_from_pattern (tl, tt, Current)
						elseif t.is_agent and then attached {ET_IS_AGENT_TYPE} t as at then
						create {ET_IS_AGENT_TYPE} last_type.declare_from_pattern (last, at, Current)
						end
					end
				end
			end
			type_stack.pop (ng)
		end
			
	force_routine (f: attached ET_DYNAMIC_FEATURE; t: ET_IS_TYPE;
			locals, as_create: BOOLEAN)
		note
			action: "{
			Search routine corresponding to `f' in `h'.
			Create it if not found and add it to `h''s routines.
			}"
			f: "original routine"
			t: "home type"
			locals: "set temporarily `with_locals' to true"
		require
			is_routine: f.static_feature.is_function
									or else f.static_feature.is_procedure
		local
			old_needs: like needed_categories
		do
			if origin_table.has (f) then

			else
				old_needs := needed_categories
				if locals then
					needed_categories := needed_categories | with_locals
				end
				t.force_routine (f, as_create, Current)
				needed_categories := old_needs
			end
		end

	force_once (o: attached ET_DYNAMIC_FEATURE; target: attached ET_IS_TYPE)
		local
			static: ET_FEATURE
		do
			static := o.static_feature
			if static.is_once then
				last_once := once_by_origin (static)
				if last_once = Void then
					create last_once.declare(o, target, Current)
					if attached last_once as lo then
						all_onces.add (lo)
					end
				end
			else
				last_once := Void
			end
		end
	
feature -- Basic operation 

	internal_name (s: READABLE_STRING_8): READABLE_STRING_8
		local
			new: STRING
		do
			name_pool.search (s)
			if name_pool.found then
				Result := name_pool.found_string
			else
				create new.make_from_string (s)
				name_pool.force (new)
				Result := new
			end
		end

	type_set (static: attached ET_IS_TYPE; list: detachable ET_DYNAMIC_TYPE_SET;
			attach: BOOLEAN): detachable IS_SET [attached ET_IS_TYPE]
		require
			needs_typeset: needs_typeset
		local
			set: attached like type_set
			dyn: ET_DYNAMIC_TYPE
			i, i0, n: INTEGER
		do
			i0 := type_stack.count
			if not attach then
				type_stack.push (none_type)
			end
			if attached list as ts then
				from
					i := list.count
				until i = 0 loop
					dyn := list.dynamic_type (i)
					if dyn /= Void and then 
						attached type_by_origin (dyn) as t and then t.is_alive then
						type_stack.push (t)
						if needs_effectors then
							static.add_effector (t)
						end
					end
					i := i - 1
				end
			elseif static.is_alive then
				type_stack.push (static)
				if needs_effectors then
					static.add_effector (static)
				end
			end
			i := type_stack.count
			n := i - i0
			if n > 0 then
				typeset_count := 0
				from
				until i = i0 loop
					typeset_add (type_stack.top)
					type_stack.pop (1)
					i := i - 1
				end
				typeset_table.search (Current)
				if typeset_table.found then
					Result := typeset_table.found_key
				else
					typeset_index := typeset_index + 1
					create set.make (n, none_type)
					set.copy_contents (Current)
					typeset_table.force (typeset_index, set)
					Result := set
				end
			end
		ensure
			type_stack_unchaged: type_stack.count = old type_stack.count
		end

feature -- ET_IS_ORIGIN 

	print_name (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
		end

feature -- DS_EQUALITY_TESTER 

	test_effectors (v, u: IS_SET [attached ET_IS_TYPE]): BOOLEAN
		local
			vi, ui: IS_TYPE
			i: INTEGER
		do
			if v = u then
				Result := True
			elseif not attached v or else not attached u then
			elseif v.count = u.count then
				from
					i := v.count
					Result := True
				until not Result or else i = 0 loop
					i := i - 1
					vi := v [i]
					ui := u [i]
					Result := vi.ident = ui.ident
				end
			end
		end

feature {NONE} -- PC_ACTIONABLE

	pre_store
		do
			preserve
			comparator := Void
		end

	post_store
		do
			restore
		end
	
feature {IS_BASE} -- Implementation 

	needed_categories: INTEGER
	
	class_name_dictionary: detachable DS_HASH_TABLE [STRING, STRING]
	
	name_pool: ET_IS_NAMES
		once
			create Result
		end

	once_less (u, v: attached ET_IS_ONCE): BOOLEAN
		do
			Result := u.home.is_less(v.home)
			if not Result and then u.home.is_equal(v.home) then
				Result := u.is_less(v)
			end
		end
	
	const_less (u, v: attached ET_IS_CONSTANT ): BOOLEAN
		do
			Result := u.home.is_less(v.home)
			if not Result and then u.home.is_equal(v.home) then
				Result := u.is_less(v)

			end
		end
	
	no_ident_types: DS_HASH_SET [attached like type_at]

	tmp_type_set: like type_set

	has_special: BOOLEAN

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
