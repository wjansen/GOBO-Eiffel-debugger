note

	description: "Generator of C code and introspection data"
	library: "Gobo Eiffel Tools Library"

class ET_INTROSPECT_GENERATOR

inherit

	ET_C_GENERATOR
		rename
			make as make_generator
		export
			{ET_EXTENSION, ET_IS_ORIGIN}
				all
		redefine
			print_agent_declaration,
			print_extension
		end

	IS_BASE
		undefine
			copy,
			is_equal,
			out
		end

	KL_SHARED_STRING_EQUALITY_TESTER
		export
			{NONE} all
		end

create

	make_all,
	make_self

feature {NONE} -- Initialization 

	make_all (a_system: like current_dynamic_system; a_rts: ET_DYNAMIC_TYPE)
		note
			action: "Create code generator for parsed system `a_system'."
		require
			is_rts: STRING_.same_string(a_rts.base_class.upper_name, "IS_RUNTIME_SYSTEM")
		local
			l_dynamic: ET_DYNAMIC_TYPE
			l_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			n: INTEGER
		do
			needed_categories := 0
				| {ET_IS_SYSTEM}.With_root_creation
				| {ET_IS_SYSTEM}.With_default_creation
				| {ET_IS_SYSTEM}.With_attributes
				| {ET_IS_SYSTEM}.With_typeset
				| {ET_IS_SYSTEM}.With_once_values
				| {ET_IS_SYSTEM}.With_parents	-- needed for `With_actionable'
				| {ET_IS_SYSTEM}.With_actionable
			make (a_system, a_system.root_type, needed_categories, False, False)
			from
				l_types := compilee.origin.dynamic_types
				n := l_types.count
			until n = 0 loop
				l_dynamic := l_types.item (n)
				if l_dynamic.is_alive then
					compilee.force_type (l_dynamic)
				end
				n := n - 1
			end
			add_runtime_system (a_system)
		end

	make_self (a_system: like current_dynamic_system; a_root: ET_DYNAMIC_TYPE)
		note
			action: "Create code generator for `a_system' describing GEC."
		require
			is_self: STRING_.same_string(a_root.base_class.upper_name, "GEC")
		do
			is_self := True
			needed_categories := 0
				| {ET_IS_SYSTEM}.With_attributes
				| {ET_IS_SYSTEM}.With_once_values
				| {ET_IS_SYSTEM}.With_parents	-- needed for `With_actionable'
				| {ET_IS_SYSTEM}.With_actionable -- some ET_IS_* classes are actionable
			make (a_system, Void, needed_categories, False, False)
				-- We need also ET_IS_SYSTEM since it describes the compiler. 
			  -- ET_..._TYPE etc. must be added explicitely since they do not occur
				-- as declared types.
			if attached dynamic_type_by_name ("ET_IS_SYSTEM", a_system) as s then
				compilee.force_type (s)
			end
			if attached dynamic_type_by_name ("ET_IS_NORMAL_TYPE", a_system) as nt then
				compilee.force_type (nt)
			end
			if attached dynamic_type_by_name ("ET_IS_EXPANDED_TYPE", a_system) as et then
				compilee.force_type (et)
			end
			if attached dynamic_type_by_name ("ET_IS_SPECIAL_TYPE", a_system) as st then
				compilee.force_type (st)
			end
			if attached dynamic_type_by_name ("ET_IS_TUPLE_TYPE", a_system) as tt then
				compilee.force_type (tt)
			end
			if attached dynamic_type_by_name ("ET_IS_AGENT_TYPE", a_system) as at then
				compilee.force_type (at)
			end
			if attached dynamic_type_by_name ("ET_IS_SCOPE_VARIABLE", a_system) as sv then
				compilee.force_type (sv)
			end
		end
	
	make (a_system: like current_dynamic_system;
				a_root: detachable ET_DYNAMIC_TYPE;
				a_categories: INTEGER; as_runtime, as_debugging: BOOLEAN)
		note
			action: "Create code generator for parsed system `a_system'."
			root: "Root type"
			categories: "Needed categories of the created `compilee'"
		do
			create import
			make_generator (a_system)
			if attached a_system as s then
				build_system (s, a_root, a_categories, as_debugging, True)
			end
		end

feature -- Access 

	needed_categories: INTEGER
			-- List of indicators of topics to be generated. 

	compilee: ET_IS_SYSTEM
			-- Compilee's system description. 

	import: ET_IMPORT

	is_self: BOOLEAN
			-- Does GEC compile itself?
	
	remote_to_self: DS_HASH_TABLE [STRING, STRING]
			-- Names of the own types corresponding to names of the remote types. 
		once
			create Result.make (50)
			Result.put ("ET_IS_SYSTEM", "IS_RUNTIME_SYSTEM")
			Result.put ("ET_IS_CLASS_TEXT", "IS_CLASS_TEXT")
			Result.put ("ET_IS_FEATURE_TEXT", "IS_FEATURE_TEXT")
			Result.put ("ET_IS_ROUTINE_TEXT", "IS_ROUTINE_TEXT")
			Result.put ("ET_IS_TYPE", "IS_TYPE")
			Result.put ("ET_IS_NORMAL_TYPE", "IS_NORMAL_TYPE")
			Result.put ("ET_IS_EXPANDED_TYPE", "IS_EXPANDED_TYPE")
			Result.put ("ET_IS_SPECIAL_TYPE", "IS_SPECIAL_TYPE")
			Result.put ("ET_IS_TUPLE_TYPE", "IS_TUPLE_TYPE")
			Result.put ("ET_IS_AGENT_TYPE", "IS_AGENT_TYPE")
			Result.put ("ET_IS_FIELD", "IS_FIELD")
			Result.put ("ET_IS_LOCAL", "IS_LOCAL")
			Result.put ("ET_IS_SCOPE_VARIABLE", "IS_SCOPE_VARIABLE ")
			Result.put ("ET_IS_CONSTANT", "IS_CONSTANT")
			Result.put ("ET_IS_ROUTINE", "IS_ROUTINE")
			Result.put ("ET_IS_ONCE", "IS_ONCE")
		end
	
	self_to_remote: DS_HASH_TABLE [STRING, STRING]
			-- Names of the remote types corresponding to names of the own types. 
		local
			remote: like remote_to_self
		once
			remote := remote_to_self
			create Result.make (3 * remote.count + 1)
			from
				remote.start
			until remote.after loop
				Result.force (remote.key_for_iteration, remote.item_for_iteration)
				remote.forth
			end
		end

feature -- Basic operation 

	build_system (a_system: attached like current_dynamic_system;
								a_root: detachable ET_DYNAMIC_TYPE;
								a_need: INTEGER; as_debugging, with_types: BOOLEAN)
		note
			action:
			"[
			 Create and fill `compilee'. Besides `a_root' it will contain also
			 the descriptions of the basic expanded types as well as of ANY, NONE.
			 ]"
			a_system: "parsed system"
			a_need: "bitwise OR of flags"
		local
			l_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			n: INTEGER
		do
			if as_debugging then
				n := n | {IS_BASE}.Debugger_flag
			end
			if not current_system.use_boehm_gc then
				n := n | {IS_BASE}.No_gc_flag
			end
			set_type_ids (a_system)
			create compilee.declare (a_system, n, 1, a_need)
			compilee.force_type (a_system.any_type)
			compilee.force_type (a_system.none_type)
			from
					-- Add all basic expanded types.
				l_types := compilee.origin.dynamic_types
				n := {IS_BASE}.Pointer_ident
			until n = 0 loop
				if attached l_types.item (n) as t then 
					compilee.force_type (t)
				end
				n := n - 1
			end
			if attached a_root as root then
				compilee.force_root (root, Void)
			end
		end

feature {NONE} -- Feature generation 

  print_agent_declaration (i: INTEGER; an_agent: ET_AGENT)
		local
			l_type: ET_DYNAMIC_TYPE
    do
      actual_agent_ident := i
      Precursor (i, an_agent)
			if not is_self and then attached current_feature as cf then
				l_type := dynamic_type_set (an_agent).static_type
				compilee.resolve_no_ident_types
				compilee.force_agent (an_agent, l_type, cf, current_type, i)
			end
      actual_agent_ident := 0
		end
	
	print_extension
		local
			l_system: like compilee
			l_extension: ET_EXTENSION
			i: INTEGER
		do
			if is_self then
				l_system := compilee
				create compilee.declare_from_pattern (l_system, remote_to_self)
				compilee.force_type (l_system.origin.root_type)
				from
					i := l_system.type_count
				until i = 0 loop
					i := i - 1
					if l_system.valid_type (i) then
						compilee.force_type(l_system.origin.dynamic_types.item (i))
					end
				end
			end
			if not use_boehm_gc then
				compilee.add_flag (compilee.No_gc_flag)
			end
			compilee.define
			header_file.flush
			flush_to_c_file
			create {ET_TABLE_EXTENSION} l_extension.make (Current, compilee, import)
			l_extension.save_system (compilee)	
			header_file.flush
			flush_to_c_file
		end

feature {NONE} -- 
		
	close_c_args: STRING = ");%N" 

feature -- Searching 
	
	dynamic_type_by_name (a_name: READABLE_STRING_8;
		a_system: detachable ET_DYNAMIC_SYSTEM): detachable ET_DYNAMIC_TYPE
		local
			l_system: ET_DYNAMIC_SYSTEM
			l_list: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			l_name: READABLE_STRING_8
			i: INTEGER
		do
			if attached a_system as sys then
				l_system := sys
			else
				l_system := current_dynamic_system
			end
			from
				l_list := l_system.dynamic_types
				i := l_list.count
			until attached Result or else i = 0 loop
				Result := l_list.item (i)
				l_name := Result.base_type.upper_name
				if not STRING_.same_string (l_name, a_name) then
					Result := Void
				end
				i := i - 1
			end
		end

	dynamic_feature_by_name (a_dynamic_type: ET_DYNAMIC_TYPE;
		a_name: READABLE_STRING_8): detachable ET_DYNAMIC_FEATURE
		local
			l_list: ET_DYNAMIC_FEATURE_LIST
			l_name: READABLE_STRING_8
			i: INTEGER
		do
			from
				l_list := a_dynamic_type.queries
				i := l_list.count
			until attached Result or else i = 0 loop
				Result := l_list.item (i)
				l_name := Result.static_feature.name.name
				if not STRING_.same_string (l_name, a_name) then
					Result := Void
					i := i - 1
				end
			end
			from
				l_list := a_dynamic_type.procedures
				i := l_list.count
			until attached Result or else i = 0 loop
				Result := l_list.item (i)
				l_name := Result.static_feature.name.name
				if not STRING_.same_string (l_name, a_name) then
					Result := Void
					i := i - 1
				end
			end
		end

feature {NONE} -- Implementation 

	actual_agent_ident: INTEGER

	tmp_str: STRING = "..................................................."

	add_runtime_system (a_system: like current_dynamic_system)
		do
			if attached dynamic_type_by_name ("IS_RUTIME_SYSTEM", a_system) as rts then
				compilee.force_type (rts)
			end
		end

	set_type_ids (a_system: like current_dynamic_system)
		local
			l_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			l_type: ET_DYNAMIC_TYPE
			l_base: ET_BASE_TYPE
			l_class: ET_CLASS
			l_params: ET_ACTUAL_PARAMETER_LIST
			l_generic: ET_DYNAMIC_TYPE
			i, j: INTEGER
		do
			from
				l_types := a_system.dynamic_types
			until i = l_types.count loop
				i := i + 1
				l_type := l_types.item (i)
				l_type.set_id(i)
				l_base := l_type.base_type
				if l_base.is_generic then
					-- Make sure that actual generic parameter types are created.
					-- List `a_system.dynamic_types' may grow,
					-- so newly created types are traversed, too.
					l_class := l_base.base_class
					from
						l_params := l_base.actual_parameters
						j := l_params.count
					until j = 0 loop
						l_generic := a_system.dynamic_type (l_params.item (j).type, l_class)
						j := j - 1 
					end
				end
			end
		end

note

	copyright: "Copyright (c) 2010, Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
