note

	description: "Generator of C code for debugging."
	library: "Gedb Eiffel Tools Library"

class DG_GENERATOR

inherit

	ET_INTROSPECT_GENERATOR
		rename
			compilee as debuggee
		redefine
			print_extension,
			import,
			generate_c_code,
			print_agent_declaration,
			print_rescue_position,
			print_across_instruction,
			print_assigner_instruction,
			print_assignment,
			print_assignment_attempt,
			print_check_instruction,
			print_creation_instruction,
			print_debug_instruction,
			print_if_instruction,
			print_inspect_instruction,
			print_loop_instruction,
			print_precursor_instruction,
			print_qualified_call_instruction,
			print_retry_instruction,
			print_unqualified_call_instruction,
			print_unqualified_identifier_call_instruction,
			print_call_position,
			print_routine_entry,
			print_inline_agent_entry,
			print_debug_exit,
			print_until_position
	end

	DG_CONSTANTS
		undefine
			is_equal,
			copy,
			out
		end

	PC_BASE
		undefine
			default_create,
			copy,
			is_equal,
			out
		end
	
	IS_FEATURE_TEXT
		rename
			make as make_feature
		export
			{} all
			{ANY}
				position_as_integer,
				line_of_position,
				column_of_position
		undefine
			copy,
			is_equal,
			out
		end

	KL_SHARED_EXECUTION_ENVIRONMENT
		export
			{} all
		undefine
			is_equal,
			copy,
			out
		end

	EXCEPTIONS
		undefine
			is_equal,
			copy,
			out
		end

create

	make_debug

feature {} -- Initialization 

	make_debug (a_system: like current_dynamic_system; as_pmd: BOOLEAN)
		note
			action: "Create code generator."
			a_system: "description of the debuggee"
			as_pmd: "only post mortem analyser"
		local
			l_dynamic: ET_DYNAMIC_TYPE
			l_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			l_type: IS_TYPE
			n: INTEGER
		do
			c0 := c_clock
			supports_marking := not as_pmd
			create signature_pool.make_with_equality_testers
				(100, Void, string_equality_tester)
			signature_pool.force (0, "=")
			create positions_buffer.make_empty (1000)
			pma_only := as_pmd
			if attached dynamic_type_by_name ("IS_RUNTIME_SYSTEM", a_system) as rts then
				make_all (a_system, rts)
				intro_compilee := debuggee
			else
				make_generator (a_system)
			end
			needed_categories := 0
				| {ET_IS_SYSTEM}.With_root_creation
				| {ET_IS_SYSTEM}.With_parents
				| {ET_IS_SYSTEM}.With_texts
				| {ET_IS_SYSTEM}.With_once_values
				| {ET_IS_SYSTEM}.With_effectors
				| {ET_IS_SYSTEM}.With_attributes
				| {ET_IS_SYSTEM}.With_default_creation
				| {ET_IS_SYSTEM}.With_routines
				| {ET_IS_SYSTEM}.With_constants
				| {ET_IS_SYSTEM}.With_locals
				| {ET_IS_SYSTEM}.With_signatures
				| {ET_IS_SYSTEM}.With_typeset
			build_system (a_system, a_system.root_type, needed_categories, True, False)
			from
				l_types := debuggee.origin.dynamic_types
				n := l_types.count
			until n = 0 loop
				l_dynamic := l_types.item (n)
				if l_dynamic.is_alive or else n <= 14 then	-- <= ident of POINTER
					debuggee.force_type (l_dynamic)
				end
				n := n - 1
			end
			from
				n := debuggee.type_count
			until n = 0 loop
				n := n - 1 
				if attached debuggee.type_at (n) as t 
					and then t.is_normal and then attached t.fields as aa
				 then
					aa.default_sort
				end
			end
			create import
			entity_declaration := "static "
			l_type := debugger.type_by_name("ROUTINE", True)
			entity_declaration.append (l_type.c_name)
			entity_declaration.append ("* e = 0;%N")
			field_declaration := "static "
			l_type := debugger.type_by_name("TYPE", True)
			field_declaration.append (l_type.c_name)
			field_declaration.append ("* e = 0;%N")
			c1 := c_clock
			io.error.put_string("Compile time: ")
			io.error.put_double((c1-c0)/c_factor)
			io.error.put_new_line
		end

feature -- Access 

	pma_only: BOOLEAN
			-- Is code to be generated for the post mortem analyzer only?
	
	debugger: detachable DG_SYSTEM
		local
			l_filename: STRING
			l_file: KL_TEXT_INPUT_FILE
		once
			l_filename := execution_environment.variable_value ("GOBO")
 			l_filename := file_system.pathname (l_filename, "tool")
			l_filename := file_system.pathname (l_filename, "gedb")
			l_filename := file_system.pathname (l_filename, "inspect.h")
			create l_file.make(l_filename)
			l_file.open_read
			create Result.make (debuggee, l_file)
			Result.parse
			l_file.close
		end

	debugger_root_procedure: detachable ET_DYNAMIC_FEATURE
			-- Creation procedure of class `GEDB'. 

	supports_marking: BOOLEAN
			-- Does the debugger support the mark command? 
	
	import: DG_IMPORT

	frame_ident: INTEGER

	signature_pool: DS_HASH_TABLE [INTEGER, STRING]
	
	refill_remote_to_self
			-- Names of the own types corresponding to names of the remote types. 
		local
			to_self: like remote_to_self
			to_remote: like self_to_remote
		do
			to_self := remote_to_self
			to_self.wipe_out
			to_self.put ("ET_IS_SYSTEM", "SYSTEM")
			to_self.put ("ET_IS_CLASS_TEXT", "CLASSTEXT")
			to_self.put ("ET_IS_FEATURE_TEXT", "FEATURETEXT")
			to_self.put ("ET_IS_ROUTINE_TEXT", "ROUTINETEXT")
			to_self.put ("ET_IS_TYPE", "TYPE")
			to_self.put ("ET_IS_NORMAL_TYPE", "NORMALTYPE")
			to_self.put ("ET_IS_EXPANDED_TYPE", "EXPANDEDTYPE")
			to_self.put ("ET_IS_SPECIAL_TYPE", "SPECIALTYPE")
			to_self.put ("ET_IS_TUPLE_TYPE", "TUPLETYPE")
			to_self.put ("ET_IS_AGENT_TYPE", "AGENTTYPE")
			to_self.put ("ET_IS_ENTITY", "ENTITY")
			to_self.put ("ET_IS_FIELD", "FIELD")
			to_self.put ("ET_IS_LOCAL", "LOCAL")
			to_self.put ("ET_IS_SCOPE_VARIABLE", "SCOPEVARIABLE")
			to_self.put ("ET_IS_CONSTANT", "CONSTANT")
			to_self.put ("ET_IS_ROUTINE", "ROUTINE")
			to_self.put ("ET_IS_ONCE", "ONCE")
			from
				to_remote := self_to_remote
				to_remote.wipe_out
				to_self.start
			until to_self.after loop
				to_remote.force (to_self.key_for_iteration, to_self.item_for_iteration)
				to_self.forth
			end

		end
	
feature {} -- Feature generation 

  print_agent_declaration (i: INTEGER; an_agent: ET_AGENT)
		local
			l_type: ET_DYNAMIC_TYPE
    do
      Precursor (i, an_agent)
			if attached intro_compilee as ic then
				ic.resolve_no_ident_types
				l_type := dynamic_type_set (an_agent).static_type
				ic.force_agent (an_agent, l_type, current_feature, current_type, i)
			end
		end
	
	print_extension
		local
			l_intro_ext: ET_TABLE_EXTENSION
			l_extension: DG_EXTENSION
			l_import: ET_IMPORT
			l_routine: ET_IS_ROUTINE
			l_names: HASH_TABLE [STRING, IS_TYPE]
			l_filename: STRING
			i, j, k: INTEGER
			l_append: BOOLEAN
		do
			debuggee.define
			refill_remote_to_self
			from
				i := debuggee.type_count
			until i = 0 loop
				i := i - 1
				if attached debuggee.type_at (i) as t then
					from
						j := t.routine_count
					until j = 0 loop
						j := j - 1
						l_routine := t.routines [j]
						k := signature_index (l_routine)
						l_routine.set_wrap (k)
					end
				end
			end
			include_runtime_header_file ("eif_dir.h", True, header_file)
			include_runtime_header_file ("eif_file.h", True, header_file)	
			include_runtime_header_file ("eif_memory.h", True, header_file)
			included_runtime_c_files.force ("eif_dir.c")
			included_runtime_c_files.force ("eif_file.c")
			included_runtime_c_files.force ("eif_memory.c")
			create l_import
			create l_intro_ext.make (Current, debuggee, l_import)
			l_intro_ext.save_system (debuggee)
			if attached {DG_SYSTEM} debugger as rts then
				create import
				create l_extension.make (Current, debuggee, import)
				c0 := c_clock
				l_extension.save_system (rts)
				c1 := c_clock
				io.error.put_string("Store DG time:   ")
				io.error.put_double((c1-c0)/c_factor)
				io.error.put_new_line
			end
		end

	c0, c1, c2: REAL_64
	
	c_clock: REAL_64
		external
			"C inline use <time.h>"
		alias
			"(EIF_REAL_64)clock()"
		end
	
	c_factor: REAL_64
		external
			"C inline use <time.h>"
		alias
			"(EIF_REAL_64)CLOCKS_PER_SEC"
		end
	
feature {} -- Feature generation 

	generate_c_code (a_system_name: STRING)
		do
			if attached debugger_root_procedure as drp then
				called_features.force_last (drp)
				drp.set_generated (True)
			end
			Precursor (a_system_name)
		end

	orig_handler: SPECIAL[POINTER]
	
	print_across_instruction (an_instruction: ET_ACROSS_INSTRUCTION)
		do
			enter_scope (an_instruction)
			Precursor (an_instruction)
			leave_scope (an_instruction.end_keyword)
		end

	print_assigner_instruction (an_instruction: ET_ASSIGNER_INSTRUCTION)
		do
			print_position_handling (an_instruction.assign_symbol, Step_into_break)
			Precursor (an_instruction)
		end

	print_assignment (an_instruction: ET_ASSIGNMENT)
		do
			print_position_handling (an_instruction.assign_symbol, Assignment_break)
			Precursor (an_instruction)
		end

	print_assignment_attempt (an_instruction: ET_ASSIGNMENT_ATTEMPT)
		do
			print_position_handling (an_instruction.assign_attempt_symbol, Assignment_break)
			Precursor (an_instruction)
		end

	print_check_instruction (an_instruction: ET_CHECK_INSTRUCTION)
		do
			print_position_handling (an_instruction.check_keyword, Instruction_break)
			Precursor (an_instruction)
		end

	print_creation_instruction (an_instruction: ET_CREATION_INSTRUCTION)
		do
			print_position_handling (an_instruction, Instruction_break)
			Precursor (an_instruction)
		end

	print_debug_instruction (an_instruction: ET_DEBUG_INSTRUCTION)
		do
			enter_scope (an_instruction)
			print_position_handling (an_instruction, Debug_break)
			Precursor (an_instruction)
			leave_scope (an_instruction.end_keyword)
		end

	print_if_instruction (an_instruction: ET_IF_INSTRUCTION)
		do
			enter_scope (an_instruction)
			Precursor (an_instruction)
			leave_scope (an_instruction.end_keyword)
		end

	print_inspect_instruction (an_instruction: ET_INSPECT_INSTRUCTION)
		do
			enter_scope (an_instruction)
			Precursor (an_instruction)
			leave_scope (an_instruction.end_keyword)
		end

	print_loop_instruction (an_instruction: ET_LOOP_INSTRUCTION)
		do
			enter_scope (an_instruction)
			Precursor (an_instruction)
			leave_scope (an_instruction.end_keyword)
		end

	print_precursor_instruction (an_instruction: ET_PRECURSOR_INSTRUCTION)
		do
			print_position_handling (an_instruction.precursor_keyword, Call_break)
			Precursor (an_instruction)
		end

	print_qualified_call_instruction (an_instruction: ET_FEATURE_CALL_INSTRUCTION)
		do
			if attached {ET_CALL_INSTRUCTION} an_instruction as instr then
				already_called := instr.qualified_name
			end
			print_position_handling (an_instruction, Call_break)
			Precursor (an_instruction)
		end

	print_retry_instruction (an_instruction: ET_RETRY_INSTRUCTION)
		do
			print_position_handling (an_instruction, Instruction_break)
			Precursor (an_instruction)
		end

	print_static_call_instruction0 (an_instruction: ET_STATIC_CALL_INSTRUCTION)
		do
			print_position_handling (an_instruction, Call_break)
			Precursor (an_instruction)
		end

	print_unqualified_call_instruction (an_instruction: ET_FEATURE_CALL_INSTRUCTION)
		do
			if attached {ET_CALL_INSTRUCTION} an_instruction as instr then
				already_called := instr.qualified_name
			end
			print_position_handling (an_instruction, Call_break)
			Precursor (an_instruction)
		end

	print_unqualified_identifier_call_instruction (an_identifier: ET_IDENTIFIER)
		do
			already_called := an_identifier
			print_position_handling (an_identifier, Call_break)
			Precursor (an_identifier)
		end
	
feature {} -- Debugging code 

	actual_routine: detachable ET_IS_ROUTINE

	print_routine_entry (as_create: BOOLEAN)
		local
			l_type: detachable ET_IS_TYPE
			l_name: READABLE_STRING_8
		do
			l_type := debuggee.type_by_origin (current_type)
			if attached {ET_IS_AGENT_TYPE} l_type as l_agent then
				l_type := l_agent.declared_type
			end
			if attached l_type as t then
				actual_routine := t.routine_by_origin (current_feature, debuggee)
				if as_create and then attached actual_routine as act then
					l_name := act.fast_name
					actual_routine := t.routine_by_name (l_name, True)
				end
			else
				actual_routine := Void
			end
			if attached actual_routine as act and then act.is_external then
				actual_routine := Void
			end
			if attached actual_routine as act
				and then attached act.target.routines as rr
			 then
				print_stack_initialization (rr.index_of (act))
			end
		end

	print_inline_agent_entry (an_agent: ET_INTERNAL_ROUTINE_INLINE_AGENT)
		local
			l_type: ET_DYNAMIC_TYPE
		do
			actual_routine := Void
			if actual_agent_ident > 0 then
				if attached debuggee.type_by_origin (current_type) then
					if not attached debuggee.last_agent as la
						or else la.orig_agent /= an_agent
					 then
						l_type := dynamic_type_set (an_agent).static_type
						debuggee.force_agent (an_agent, l_type, current_feature, current_type, actual_agent_ident)
					end
					if attached debuggee.last_agent as ag then
						actual_routine := ag.routine
					end
				end
				if attached actual_routine as act and then act.is_external then
					actual_routine := Void
				end
				if attached actual_routine then
					print_stack_initialization (0)
				end
			end
		end

	print_debug_exit (a_last: BOOLEAN)
		local
			l_keyword: detachable ET_KEYWORD
		do
			if attached actual_routine as act then
				if attached act.origin as orig then
					if attached {ET_ROUTINE} orig.static_feature as r then
						l_keyword := r.end_keyword
					end
				elseif attached act.inline_agent as inline then
					if attached {ET_ROUTINE_INLINE_AGENT} inline.orig_agent as orig then
						l_keyword := orig.end_keyword
					end
				end
				check
					attached l_keyword
				end
				print_stack_termination (l_keyword)
			end
			if a_last then
				actual_routine := Void
			end
		end

	entity_declaration: STRING
	field_declaration: STRING

	buffer_declaration: STRING = "GE_jmp_buf *buf = 0;%N"

	assign_string: STRING = " = "
	
	print_stack_initialization (an_index: INTEGER)
		require
			has_actual: actual_routine /= Void
		local
			l_target: ET_IS_TYPE
			l_routine: ET_IS_ROUTINE
			l_agent: detachable ET_IS_AGENT_TYPE
			l_compound: detachable ET_COMPOUND
			l_rescue: detachable ET_COMPOUND
			l_node: ET_AST_NODE
			i, j, k, n: INTEGER
			is_root: BOOLEAN
		do
			l_routine := actual_routine
			l_agent := l_routine.inline_agent
			if l_agent /= Void then
				if attached {ET_INTERNAL_ROUTINE_CLOSURE} l_agent.orig_agent as ag then
					l_compound := ag.compound
					l_rescue := ag.rescue_clause
				end
			else
				if attached {ET_INTERNAL_ROUTINE} l_routine.origin.static_feature as sf then
					l_compound := sf.compound
					l_rescue := sf.rescue_clause
				end
			end
			l_target := l_routine.target
			is_root := l_routine = debuggee.root_creation_procedure
			actual_text := l_routine.text
			actual_debugged := l_routine.in_class.is_debug_enabled
				or else l_routine = debuggee.root_creation_procedure
				-- Define stack frame variable: 
			print_indentation
			current_file.put_string (import.frame_struct_name)
			current_file.put_string (once " s = {0};%N")
			if supports_marking then
				print_indentation
				current_file.put_string (buffer_declaration)
			end
			print_indentation
			current_file.put_character ('{')
			current_file.put_new_line
			indent			
			print_indentation
			current_file.put_string (entity_declaration)
			print_indentation
			current_file.put_string (once "if (!e) {%N")
			indent
			print_indentation
			current_file.put_string (once "e = ")
			current_file.put_string (import.c_get_routine)
			current_file.put_character ('(')
			current_file.put_integer (l_target.ident)
			current_file.put_character (',')
			if attached l_agent then
				current_file.put_integer (l_target.routines.index_of (l_routine))
			else
				current_file.put_integer (an_index)
			end
			current_file.put_string (close_c_args)
				-- Compute offsets of local variables:
			if attached l_agent then 
				if attached l_routine.arg_at (0) then
					print_indentation
					current_file.put_string (import.c_set_local)
					current_file.put_character ('(')
					print_argument_name (formal_argument (1), current_file)
					current_file.put_character (',')
					current_file.put_integer (j)
					current_file.put_string (close_c_args)
				end
			elseif l_routine.uses_current then
				print_indentation
				current_file.put_string (import.c_set_local)
				current_file.put_character ('(')
				print_current_name (current_file)
				current_file.put_character (',')
				current_file.put_integer (j)
				current_file.put_string (close_c_args)
			end
			if l_routine.target.base_class.is_debug_enabled then
					-- Local variables other than `Current' exist only
					-- if the enclosing class is enabled for debugging.
				j := j + 1
				if attached l_agent as ag then
					from
						i := 1
						n := l_routine.argument_count
					until i >= n loop
						if ag.is_open_operand (i) then
							print_indentation
							current_file.put_string (import.c_set_local)
							current_file.put_character ('(')
							k := k + 1
							ag.print_open_operand_name (k, current_file, Current)
							current_file.put_character (',')
							current_file.put_integer (j)
							current_file.put_string (close_c_args)
						end
						j := j + 1
						i := i + 1
					end
				else
					from
						i := 1
						n := l_routine.argument_count
					until i >= n loop
						if attached l_routine.arg_at (i) as v
							and then attached {ET_IDENTIFIER} v.origin as id 
						 then
							print_indentation
							current_file.put_string (import.c_set_local)
							current_file.put_character ('(')
							print_argument_name (id, current_file)
							current_file.put_character (',')
							current_file.put_integer (j)
							current_file.put_string (close_c_args)
						end
						j := j + 1
						i := i + 1
					end
				end
				if attached l_routine.result_field then
					print_indentation
					current_file.put_string (import.c_set_local)
					current_file.put_character ('(')
					print_result_name (current_file)
					current_file.put_character (',')
					current_file.put_integer (j)
					current_file.put_string (close_c_args)
				end
				j := j + 1
				from
					i := 1
					n := l_routine.local_count
				until i >= n loop
					if attached l_routine.local_at (i) as v
						and then attached {ET_IDENTIFIER} v.origin as id 
					 then
						print_indentation
						current_file.put_string (import.c_set_local)
						current_file.put_character ('(')
						print_local_name (id, current_file)
						current_file.put_character (',')
						current_file.put_integer (j)
						current_file.put_string (close_c_args)
					end
					j := j + 1
					i := i + 1
				end
				from
					i := 0
					n := l_routine.scope_var_count
				until i = n loop
					if attached {ET_IS_SCOPE_VARIABLE} l_routine.scope_var_at (i) as v
						and then attached {ET_IDENTIFIER} v.origin as id 
					 then
						print_indentation
						current_file.put_string (import.c_set_local)
						current_file.put_character ('(')
						if v.is_object_test then
							print_object_test_local_name (id, current_file)
						else
							print_across_cursor_name (id, current_file)
						end
							current_file.put_character (',')
							current_file.put_integer (j)
							current_file.put_string (close_c_args)
					end
					j := j + 1
					i := i + 1
				end
			end
			dedent
			print_indentation
			current_file.put_character ('}')
			current_file.put_new_line
				-- Set stack frame descriptor: 
			print_indentation
			current_file.put_string (once "s.routine = e;%N")
			dedent
			print_indentation
			current_file.put_character ('}')
			current_file.put_new_line
			print_indentation
			current_file.put_string (once "s.class_id = ")
			current_file.put_integer (l_routine.in_class.ident)
			current_file.put_character (';')
			current_file.put_new_line
			print_indentation
			current_file.put_string (once "s.caller = ")
			current_file.put_string (import.c_stacktop_name)
			current_file.put_character (';')
			current_file.put_new_line
			print_indentation
			current_file.put_string (once "s.depth = ")
			current_file.put_string (import.c_stacktop_name)
			if is_root then
				current_file.put_string ("!=0 ? ")
				current_file.put_string (import.c_stacktop_name)
				current_file.put_string (once "->depth+1 : 1;%N")
			else
				current_file.put_string (once "->depth+1;%N")
			end
			if not pma_only then
				print_indentation
				current_file.put_string (once "s.scope_depth = ")
				current_file.put_string (import.c_stacktop_name)
				if is_root then
					current_file.put_string ("!=0 ? ")
					current_file.put_string (import.c_stacktop_name)
					current_file.put_string (once "->scope_depth+1 : 1;%N")
				else
					current_file.put_string (once "->scope_depth+1;%N")
				end
			end
			print_indentation
			current_file.put_string (import.c_stacktop_name)
			current_file.put_string (address_s)
			actual_text := Void
			if attached l_routine.text as text
				and then text.home = l_routine.in_class
			 then
				actual_text := text
			end
			if attached l_compound as c then
				if l_routine.is_creation then
					delayed_enter := c
				else
					enter_scope (c.keyword)
				end
			end
		end

	print_stack_termination (a_keyword: ET_KEYWORD)
		do
			if attached actual_routine as ar then
				leave_scope (a_keyword)
				-- force printing of possibly repeated position:
				if ar = debuggee.root_creation_procedure then
					print_indentation
					current_file.put_string ("if (s.caller==0)%N")
					indent
					print_position_handling(a_keyword, End_program_break)
					dedent
				end
				actual_position := 0
				print_indentation
				current_file.put_string (import.c_stacktop_name)
				current_file.put_string (once " = s.caller;%N")
				if actual_debugged and then attached actual_text as x then
					x.copy_instruction_positions(positions_buffer)
				end
			end
			positions_buffer.wipe_out
			actual_text := Void
			actual_position := 0
		end
			
	print_new_initialization (a_type: ET_IS_TYPE)
		local
			l_origin: ET_DYNAMIC_TYPE
			l_field: ET_IS_FIELD
			i, k, n: INTEGER
		do
			i := a_type.ident
			l_origin := a_type.origin
			print_indentation
			current_file.put_character ('{')
			current_file.put_string (field_declaration)
			indent
				-- Compute offsets of local variables: 
			print_indentation
			current_file.put_string (once "if (!e) {%N")
			indent
			print_indentation
			current_file.put_string (once "e = ")
			current_file.put_string (import.c_get_type)
			current_file.put_character ('(')
			current_file.put_integer (i)
			current_file.put_string (close_c_args)
			from
				k := 0
				n := a_type.field_count
				if n = 0 and then a_type.is_subobject then
					n := 1;
				end
			until k = n loop
				print_indentation
				current_file.put_string (import.c_set_field)
				current_file.put_character ('(')
				if a_type.is_subobject then
					current_file.put_character ('(')
					current_file.put_character ('*')
					current_file.put_character ('(')
					current_file.put_character ('T')
					current_file.put_character ('b')
					current_file.put_integer (i)
					current_file.put_character ('*')
					current_file.put_character (')')
					current_file.put_character ('R')
					current_file.put_character (')')
				else
					current_file.put_string (c_ge_default)
					current_file.put_integer (i)
					l_field := a_type.fields[k]
				end
				current_file.put_character (',')
				if a_type.is_tuple then
					print_attribute_tuple_item_name (k+1, l_origin, current_file);
				elseif a_type.is_special and then l_field.has_name(once "item") then
					print_attribute_special_item_name (l_origin, current_file)
				elseif a_type.is_subobject then
					print_boxed_attribute_item_name (l_origin, current_file)
				else
					print_attribute_name (l_field.origin, l_origin, current_file)
				end
				current_file.put_character (',')
				current_file.put_integer (k)
				current_file.put_string (close_c_args)
				k := k + 1
			end
			dedent
			print_indentation
			current_file.put_character ('}')
			current_file.put_new_line
			dedent
			print_indentation
			current_file.put_character ('}')
			current_file.put_new_line
		end

	flush_delayed
		require
			is_delayed: attached delayed_enter
		local
			de: like delayed_enter
		do
			de := delayed_enter	
			delayed_enter := Void
			if actual_routine = debuggee.root_creation_procedure then
				print_indentation
				current_file.put_string ("if (")
				current_file.put_string (import.c_stacktop_name)
				current_file.put_string ("->caller==0) {%N")
				indent
				print_indentation
				current_file.put_string (import.c_debugger_name)
				current_file.put_string (" = ")
				current_file.put_string (import.c_init_name)
				current_file.put_string ("(GE_argv,GE_argc,")
				if pma_only then
					current_file.put_integer (1)
				else
					current_file.put_integer (0)
				end
				current_file.put_string (");%N")
				print_position_handling(de, Start_program_break)
				dedent
				print_indentation
				current_file.put_string ("} else {%N")
				indent
				print_position_handling(de, Begin_scope_break)
				dedent
				print_indentation
				current_file.put_string ("}%N")
			else
				print_indentation
				print_position_handling (de, Begin_scope_break)
			end
		ensure
			is_delayed: not attached delayed_enter
		end
	
	print_position_handling (a_node: ET_AST_NODE; code: INTEGER)
		local
			pos: NATURAL
			n, l, c: INTEGER
			pure_pos, for_instruction: BOOLEAN
		do
			if attached delayed_enter then
				flush_delayed
			end
			pos := position (a_node).as_natural_32
			if --pos /= actual_position and then
				attached actual_routine as ar
			 then
				pure_pos := pma_only or else not actual_debugged
				for_instruction := ar.uses_current
				inspect code
				when Call_break then
					pos := (pos - 1).max (1)
				when Step_into_break, End_program_break then
					for_instruction := False
				when End_scope_break then
					for_instruction := False
				else
				end
				tmp_str.clear_all
				if pure_pos then
					tmp_str.append (import.c_skip_name)
				elseif supports_marking and then for_instruction then
					tmp_str.append (import.c_jump_name)
				else
					tmp_str.append (import.c_pos_name)
				end
				tmp_str.extend ('(')
				tmp_str.append_integer (line_of_position (pos))
				tmp_str.extend (',')
				tmp_str.append_integer (column_of_position (pos))
				if not pure_pos then
					tmp_str.extend (',')
					tmp_str.append_integer (code)
				end
				tmp_str.extend (')')
				tmp_str.extend (';')
				tmp_str.extend ('%N')
				print_indentation
				current_file.put_string (tmp_str)
				actual_position := pos
				if not pure_pos and then for_instruction then
					n := positions_buffer.count
					if n >= positions_buffer.capacity then
						positions_buffer := positions_buffer.aliased_resized_area (2 * n)
					end
					positions_buffer.extend (pos)
				end
			end
		end

	position (a_node: ET_AST_NODE): NATURAL
		local
			first: ET_POSITION
			l: INTEGER
		do
			l := a_node.position.line
			if l = 0 then
				first := a_node.first_position
				Result := position_as_integer (first.line, first.column)
			else
				Result := position_as_integer (l, a_node.position.column)
			end
		end

	break_string: STRING = "                                     "

	open_parentheses: INTEGER

	actual_position: NATURAL
			-- Last written position. 

	actual_text: detachable ET_IS_ROUTINE_TEXT

	actual_debugged: BOOLEAN

	old_pos: INTEGER
	
feature {} -- Routine signatures 

	signature_index (a_routine: ET_IS_ROUTINE): INTEGER
		note
			return:
			"[
			 Append C signature of `a_routine' to `a_string'.
			 BNF:  [res_type] "=" [type] ";" {arg_type ","}
			]"
		do
			tmp_str.clear_all
			append_signature (a_routine, tmp_str)
			if signature_pool.has (tmp_str) then
				Result := signature_pool.item (tmp_str)
			else
				Result := signature_pool.count
				signature_pool.force (Result, tmp_str.twin)
			end
		end

	append_signature (a_routine: ET_IS_ROUTINE; a_string: STRING)
		note
			action:
			"[
			 Append C signature of `a_routine' to `a_string'.
			 BNF:  [res_type] "=" [type] ";" {arg_type ","}
			]"
		local
			l_dynamic: ET_DYNAMIC_FEATURE
			l_type: detachable ET_IS_TYPE
			j, ac: INTEGER
		do
			l_dynamic := a_routine.origin
			if a_routine.is_creation then
				l_type := a_routine.var_at (0).type
			else
				l_type := a_routine.type
			end
			if attached l_type as t then
				if t.is_subobject then
					a_string.extend ('T')
					a_string.append_integer (t.ident)
				else
					a_string.append (once "void*")
				end
			end
			a_string.extend ('=')
			if a_routine.uses_current and then not a_routine.is_creation then
				l_type := a_routine.target
				check
					attached l_type
				end
				if l_type.is_subobject then
					a_string.extend ('T')
					a_string.append_integer (l_type.ident)
					a_string.extend ('*')
				else
					a_string.append (once "void*")
				end
			end
			a_string.extend (';')
			from
				ac := a_routine.argument_count
				j := 1
			until j = ac loop
				a_string.extend ('T')
				l_type := a_routine.arg_at (j).type
				if l_type.is_subobject then
					a_string.append_integer (l_type.ident)
				else
					a_string.extend ('0')
					a_string.extend ('*')
				end
				a_string.extend (',')
				j := j + 1
			end
		end

feature {} -- Extended code generation 

	step_into_position_disabled: BOOLEAN

	positions_buffer: SPECIAL[NATURAL]
	
	address_s: STRING = " = &s;%N"

	print_call_position (a_node: ET_AST_NODE; as_procedure: BOOLEAN)
		local
			l_name: detachable ET_AST_NODE
			l_node: ET_AST_NODE
			l_code: INTEGER
			needs_position: BOOLEAN
		do
			if attached {ET_FEATURE_CALL_INSTRUCTION} a_node as ci then
				l_name := ci.name
				needs_position := True
			else
				needs_position := in_operand
			end
			if attached l_name then
				l_node := l_name
			else
				l_node := a_node
				if attached {ET_CONVERT_TO_EXPRESSION} l_node as ct then
					l_node := ct.expression
				elseif attached {ET_CONVERT_FROM_EXPRESSION} l_node as cf then
					l_node := cf.expression
				end
				needs_position := needs_position
					and then not attached {ET_CURRENT} l_node
					and then not attached {ET_ARGUMENT_NAME} l_node
					and then not attached {ET_CONSTANT} l_node
					and then not attached {ET_WRITABLE} l_node
			end
			if needs_position then
				if attached {ET_CALL_EXPRESSION} l_node as ce then
					l_node := ce.name
				end
				if not as_procedure or else a_node = already_called then
					l_code := Step_into_break
				else
					l_code := Call_break
				end
				print_position_handling (l_node, l_code)
			end
		end

	print_rescue_position (a_rescue: ET_COMPOUND)
		do
			if attached actual_routine then
				print_indentation
				current_file.put_string (import.c_stacktop_name)
				current_file.put_string (address_s)
				current_file.put_new_line
			end
		end

	print_until_position (a_node: ET_AST_NODE)
		do
			print_position_handling (a_node, Instruction_break)
			Precursor (a_node)
		end
				
	delayed_enter: detachable ET_AST_NODE

	enter_scope (a_node: ET_AST_NODE)
		do
			if actual_routine /= Void and then not pma_only then
				print_indentation
				current_file.put_string ("++s.scope_depth;%N")			
				print_position_handling (a_node, Begin_scope_break)
			end
		end
	
	leave_scope (a_node: ET_AST_NODE)
		do
			if actual_routine /= Void and then not pma_only then
				print_indentation
				current_file.put_string ("--s.scope_depth;%N")
				print_position_handling (a_node, End_scope_break)
			end
		end
	
feature {} -- Implementation 

	already_called: detachable ET_AST_NODE

	intro_compilee: detachable like debuggee

	index_of_field (a_type: IS_TYPE; a_name: READABLE_STRING_8): INTEGER
		local
			i: INTEGER
		do
			from
				i := a_type.field_count
			until i = 0 loop
				i := i - 1
				if a_type.field_at (i).has_name (a_name) then
					Result := i
					i := 0
				end
			end
		end

note

	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
