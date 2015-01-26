note

	description: "Generator of C code of the debuggee."
	library: "Gedb Eiffel Tools Library"

class DG_EXTENSION
	
inherit
	
	ET_TABLE_EXTENSION
		rename
			make as make_tables
		redefine
			c_generator,
			c_names,
			save_system,
			print_typedefs,
			print_defines
		end
	
	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		undefine
			default_create,
			copy, is_equal, out
		end

	DOUBLE_MATH
		undefine
			default_create,
			copy, is_equal, out
		end
	
	KL_IMPORTED_STRING_ROUTINES
		undefine
			copy,
			is_equal,
			out
		end

create

	make

feature {NONE} -- Initialization
	
	make (a_generator: like c_generator; a_compilee: like compilee;
			a_c_names: like c_names; max_line, max_column: INTEGER)
		local
			n, id_bits, line_bits, col_bits: INTEGER
		do
			make_tables (a_generator, a_compilee, a_c_names)
			from
				n := a_compilee.class_count
			until n = 0 loop
				id_bits := id_bits + 1
				n := n |>> 1
			end
			from
				n := max_line
			until n = 0 loop
				line_bits := line_bits + 1
				n := n |>> 1
			end
			from
				n := max_column
			until n = 0 loop
				col_bits := col_bits + 1
				n := n |>> 1
			end
			if id_bits + line_bits + col_bits > 32 then
				line_shift := 0
			else
				line_shift := col_bits
			end
			id_shift := line_bits + line_shift
		end
	
feature -- Access

	c_generator: DG_GENERATOR

	c_names: DG_IMPORT

feature -- Basic operation 
	
	save_system (a_target_system: DG_SYSTEM)
		note
			action: "Store `a_debuggee' as C code to file `c-file'."
			a_target_system: "description of the storing system"
		local
			l_file: PLAIN_TEXT_FILE
			l_table: PC_ANY_TABLE [PC_TYPED_IDENT [NATURAL]]
			l_source: DG_SOURCE
			l_target: DG_TARGET
			l_driver: PC_FORWARD_DRIVER [NATURAL, attached ANY]
			l_name: STRING
			l_filename: PATH
		do
--			Precursor (a_target_system)	-- for future use
			print_extension	-- workaround
			l_name := compilee.name
			create l_filename.make_current
			l_filename := l_filename.extended(l_name + "0.c")
			create c0_file.make (l_filename.out)
			c0_file.open_write
			c_generator.c_filenames.force_last (".c", l_name + "0")
			c0_file.put_string (preamble)
			c0_file.put_string ("#include %"")
			c0_file.put_string (l_name)
			c0_file.put_string (".h%"%N%N")
			put_structs (False)
			create l_filename.make_from_string(item("GOBO"))
			l_filename := l_filename.extended("library")
			l_filename := l_filename.extended("tools")
			l_filename := l_filename.extended("debugger")
			l_filename := l_filename.extended("dg.c")
			create l_file.make_open_read (l_filename.out)
			l_file.copy_to (c0_file)
			l_file.close
			c0_file.put_string ("static T2* chars_(void* obj, int* nc) {%N")
			if attached compilee.type_at ({IS_BASE}.String8_ident) as s8
				and then s8.is_alive 
			 then
				c0_file.put_string (
"[
  *nc = 0;
  if (obj==0) return 0;
  if (*(int*)obj!=17) return 0;
  if (((T17*)obj)->a1==0) return 0;
  *nc = ((T17*)obj)->a2;
  return ((T15*)((T17*)obj)->a1)->z2;
}	

]")
			else
				c0_file.put_string ("  return 0;%N}%N")
			end
			c0_file.put_string ("static T3* unichars_(void* obj, int* nc) {%N")
			if attached compilee.type_at ({IS_BASE}.String32_ident) as s32
				and then s32.is_alive
			 then
				c0_file.put_string (
"[
  *nc = 0;
  if (obj==0) return 0;
  if (*(int*)obj!=18) return 0;
  if (((T18*)obj)->a1==0) return 0;
  *nc = ((T18*)obj)->a2;
  return ((T16*)((T18*)obj)->a1)->z2;
}

]")
			else
				c0_file.put_string ("  return 0;%N}%N")
			end
			put_wrappers
			c0_file.put_new_line
			create l_source.make (a_target_system, c_generator.runtime_system,
														c_generator, compilee)			
			l_source.set_actionable (True)
			create l_target.make (c0_file, "T", "x",
														c_names.c_rts_name, a_target_system)
			create l_table.make (997)
			create l_driver.make (l_target, l_source, l_table)
			l_driver.traverse (compilee)
			c0_file.close
		end

feature {NONE} -- Extension parts

	print_defines
		do
--			Precursor	-- for future use
			h_file.put_string ("{

#ifdef EIF_WINDOWS
#define DllImport __declspec(dllimport)
#define DllExport __declspec(dllexport)
#else
#define DllImport extern
#define DllExport extern
#endif

													}")
			-- Define debug flag
			h_file.put_string ("#define ")
			h_file.put_string (c_names.c_debug_flag)
			h_file.put_character (' ')
			if c_generator.pma_only then
				h_file.put_integer (1)
			else
				h_file.put_integer (2)
			end
			h_file.put_new_line
			-- Define system and frame struct
			print_forward_variable (True, c_names.frame_struct_name,
															c_names.c_stacktop_name, "0")
			print_forward_variable (False, "int", c_names.c_interrupt_name, "0")
			print_forward_variable (False, "int", c_names.c_step_name, "1")
			h_file.put_string ("extern void ")
			h_file.put_string (c_names.c_crash_name)
			h_file.put_string ("(EIF_NATURAL_32 code,EIF_NATURAL_32 sig);%N")
			if not c_generator.pma_only then
				-- Define `break'
				h_file.put_string ("DllImport ")
				if c_generator.supports_marking then
					h_file.put_string ("GE_jmp_buf * ")
				else
					h_file.put_string ("EIF_NATURAL_32")
				end
				h_file.put_string (c_names.c_info_name)
				h_file.put_string ("(EIF_NATURAL_32 code);%N")
				h_file.put_string ("DllImport ")
				if c_generator.supports_marking then
					h_file.put_string ("GE_jmp_buf * ")
				else
					h_file.put_string ("int")
				end
				h_file.put_string (c_names.c_break_name)
				h_file.put_string ("(EIF_INTEGER_32 code);%N")
			end
			
			print_pos_definition
			-- Declare `routine', `local_offset'
			h_file.put_string ("void* ")
			h_file.put_string (c_names.c_get_routine)
			h_file.put_string ("(EIF_NATURAL_32,EIF_NATURAL_32);%N")
			h_file.put_string ("void ")
			h_file.put_string (c_names.c_local_offset_name)
			h_file.put_string ("(void*,EIF_INTEGER_32,EIF_NATURAL_32);%N")
			h_file.put_string ("#define ")
			h_file.put_string (c_names.c_set_local)
			h_file.put_string ("(name,index) ")
			h_file.put_string (c_names.c_local_offset_name)
			h_file.put_character ('(')
			if c_generator.exception_trace_mode then
				h_file.put_character ('0')
				h_file.put_character (',')
			end
			h_file.put_string ("e,(EIF_INTEGER)((size_t)&name-(size_t)&")
			h_file.put_string (c_names.c_frame_name)
			h_file.put_string ("),index)%N")
			-- Declare `type', `field_offset'
			h_file.put_string ("void* ")
			h_file.put_string (c_names.c_get_type)
			h_file.put_string ("(EIF_NATURAL_32);%N")
			h_file.put_string ("void ")
			h_file.put_string (c_names.c_field_offset_name)
			h_file.put_string ("(void*,EIF_INTEGER_32,EIF_NATURAL_32);%N")
			h_file.put_string ("#define ")
			h_file.put_string (c_names.c_set_field)
			h_file.put_string ("(def,name,index) ")
			h_file.put_string (c_names.c_field_offset_name)
			h_file.put_character ('(')
			if c_generator.exception_trace_mode then
				h_file.put_character ('0')
				h_file.put_character (',')
			end
			h_file.put_string ("e,(EIF_INTEGER)((size_t)&def.name-(size_t)&def),index)%N")
			c_generator.flush_to_c_file
		end

feature {NONE} -- Print C structs 

	id_shift, line_shift: INTEGER
	
	print_pos_definition
		once
				-- Define `skip', `info', `pos', `jump' 
			h_file.put_string ("#define ")
			h_file.put_string (c_names.c_skip_name)
			h_file.put_string ("(l,c)  s.pos=l*256+c;")
			if c_generator.pma_only then
				h_file.put_new_line
			else
				h_file.put_string ("  if (")
				h_file.put_string (c_names.c_interrupt_name)
				h_file.put_character (')')
				h_file.put_character (' ')
				h_file.put_string (c_names.c_break_name)
				h_file.put_string ("(12);%N")
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_id_shift_name)
				h_file.put_character (' ')
				h_file.put_integer (id_shift)
				h_file.put_new_line
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_line_shift_name)
				h_file.put_character (' ')
				h_file.put_integer (line_shift)
				h_file.put_new_line
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_status_name)
				h_file.put_string ("(l,c,code)  s.pos=l*256+c;  ")
				h_file.put_string (c_names.c_info_name)
				h_file.put_string ("1(code);%N")
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_pos_name)
				h_file.put_string ("(l,c,code)  s.pos=l*256+c;  ")
				h_file.put_string ("if (")
				h_file.put_string (c_names.c_step_name)
				h_file.put_string (" && ")
				h_file.put_string (c_names.c_interrupt_name)
				h_file.put_character (')')
				h_file.put_character (' ')
				h_file.put_string (c_names.c_break_name)
				h_file.put_string ("(code);%N")
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_jump_name)
				h_file.put_string ("(id,l,c,code)  s.pos=l*256+c; \%N")
				h_file.put_string ("  if (")
				h_file.put_string (c_names.c_break_name)
				h_file.put_string ("1(id<<")
				h_file.put_string(c_names.c_id_shift_name)
				if line_shift > 0 then 
					h_file.put_string (" | l<<")
					h_file.put_string(c_names.c_line_shift_name)
					h_file.put_string (" | c")
				else
					h_file.put_string (" | l")
				end
				h_file.put_string (", code)) { \%N")
				if c_generator.supports_marking then
					h_file.put_string ("    buf=")
					h_file.put_string (c_names.c_break_name)
					h_file.put_string("(code); \%N")
					h_file.put_string ("    if (buf) { if (GE_setjmp(*buf)) { ")
					h_file.put_string (c_names.c_stacktop_name)
					h_file.put_string ("=&s; ")
					h_file.put_string (c_names.c_info_name)
					h_file.put_character ('(')
					h_file.put_integer (c_generator.After_reset_break)
					h_file.put_string ("); } \%N      else ")
					h_file.put_string (c_names.c_info_name)
					h_file.put_character ('(')
					h_file.put_integer (c_generator.After_mark_break)
					h_file.put_string ("); }}%N")
				end
			end
			h_file.flush
		end
	
	put_declarations
		note
			action:
			"[
			 Print several C definitions and declarations to the header or C files.

			 The routine is currently not used. It should be used when
			 file '$GOBO/library/tools/debugger/dg.c' is out of date.
			 ]"
		local
			l_type: IS_TYPE
			l_string: STRING
		do
				-- Define global data
			c0_file.put_string ("GE_jmp_buf ")
			c0_file.put_string (c_names.c_jmp_buf0_name)
			c0_file.put_character(';')
			c0_file.put_new_line
			-- Define `free', `realloc', `jmp_buffer'
			c0_file.put_string ("static void ")
			c0_file.put_string (c_names.c_free_name);
			c0_file.put_string ("_(void* p) {%N")
			c0_file.put_string ("#ifndef EIF_BOEHM_GC%N  if (p) free(p);%N#endif%N}%N")
			c0_file.put_string ("void (*")
			c0_file.put_string (c_names.c_free_name);
			c0_file.put_string (")(void*) = ")
			c0_file.put_string (c_names.c_free_name);
			c0_file.put_string ("_;%N")
			c0_file.put_string ("static void* ")
			c0_file.put_string (c_names.c_alloc_name)
			c0_file.put_string ("_(void* p, size_t n) {%N")
			c0_file.put_string ("  if (n==0) (")
			c0_file.put_string (c_names.c_free_name)
			c0_file.put_string (")(p);%N")
			c0_file.put_string ("  return GE_null(GE_realloc(p, n));%N}%N")
			c0_file.put_string ("void* (*")
			c0_file.put_string (c_names.c_alloc_name)
			c0_file.put_string (")(void*, size_t) = ")
			c0_file.put_string (c_names.c_alloc_name)
			c0_file.put_string ("_;%N")			
			c0_file.put_string ("static void* ")
			c0_file.put_string (c_names.c_jmp_buffer_name)
			c0_file.put_string ("_() {%N  return (")
			c0_file.put_string (c_names.c_alloc_name)
			c0_file.put_string (")(0, sizeof(GE_jmp_buf));%N}%N")
			c0_file.put_string ("void* (*")
			c0_file.put_string (c_names.c_jmp_buffer_name)
			c0_file.put_string (")() = ")
			c0_file.put_string (c_names.c_jmp_buffer_name)
			c0_file.put_string ("_;%N")
			-- Define `longjmp'
			c0_file.put_string ("static void ")
			c0_file.put_string (c_names.c_longjmp_name)
			c0_file.put_string ("_(void* buf, EIF_NATURAL_32 jmp) {%N  ")
			c0_file.put_string ("GE_longjmp(*(GE_jmp_buf*)buf,jmp);%N}%N")
			c0_file.put_string ("void (*")
			c0_file.put_string (c_names.c_longjmp_name);
			c0_file.put_string (")(void*,EIF_NATURAL_32) = ")
			c0_file.put_string (c_names.c_longjmp_name);
			c0_file.put_string ("_;%N")
			-- Define `type', `field_offset'
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			l_string := l_type.c_name
			c0_file.put_string (l_string)
			c0_file.put_character ('*')
			c0_file.put_character (' ')
			c0_file.put_string (c_names.c_get_type)
			c0_file.put_string ("(EIF_NATURAL_32 t_id) {%N  ")
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			l_string := l_type.c_name
			c0_file.put_string("return ((GedbSystem*)")
			c0_file.put_string(c_names.c_rts_name)
			c0_file.put_string(")->all_types[t_id];%N}%N")
			c0_file.put_string ("void ")
			c0_file.put_string (c_names.c_field_offset_name)
			c0_file.put_string ("(void* t, EIF_NATURAL_32 off, EIF_NATURAL_32 f_id) {%N  ")
			c0_file.put_string (l_string)
			c0_file.put_string ( "* type = (")
			c0_file.put_string (l_string)
			c0_file.put_string ("*)t;%N  ")
			l_type := c_generator.debugger.type_by_name("ENTITY", True)
			l_string := l_type.c_name
			c0_file.put_string (l_string)
			c0_file.put_string ("* field = type->fields[f_id];%N  ")
			c0_file.put_string ("field->offset = off;%N}%N")
			-- Define `routine', `local_offset'
			l_type := c_generator.debugger.type_by_name("ROUTINE", True)
			l_string := l_type.c_name
			c0_file.put_string (l_string)
			c0_file.put_character ('*')
			c0_file.put_character (' ')
			c0_file.put_string (c_names.c_get_routine)
			c0_file.put_string ("(EIF_NATURAL_32 t_id, EIF_NATURAL_32 r_id) {%N  ")
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			l_string := l_type.c_name
			c0_file.put_string(l_string)
			c0_file.put_string("* t = ((GedbSystem*)")
			c0_file.put_string(c_names.c_rts_name)
			c0_file.put_string(")->all_types[t_id];%N  ")
			c0_file.put_string("return t->routines[r_id];%N")
			c0_file.put_string("}%N")
			l_type := c_generator.debugger.type_by_name("ROUTINE", True)
			l_string := l_type.c_name
			c0_file.put_string ("void ")
			c0_file.put_string (c_names.c_local_offset_name)
			c0_file.put_string ("(void* r, EIF_INTEGER_32 off, EIF_NATURAL_32 l_id) {%N  ")
			c0_file.put_string (l_string)
			c0_file.put_string ( "* routine = (")
			c0_file.put_string (l_string)
			c0_file.put_string ("*)r;%N  ")
			l_type := c_generator.debugger.type_by_name("ENTITY", True)
			l_string := l_type.c_name
			c0_file.put_string (l_string)
			c0_file.put_string ("* local = routine->vars[l_id];%N  ")
			c0_file.put_string ("local->offset = off;%N}%N")
			-- Define `chars', `unichars'
			c0_file.put_string ("static T2* gedb_chars_(void* obj, EIF_INTEGER_32* nc) {")
			l_type := c_generator.debugger.string_type
			if l_type /= Void and then l_type.is_alive then
				c0_file.put_string ("%N  *nc = 0;%N")
				c0_file.put_string ("  if (obj==0) return 0;%N")
				c0_file.put_string ("  if (*(EIF_INTEGER_32*)obj!=17) return 0;%N")
				c0_file.put_string ("  if (((T17*)obj)->a1==0) return 0;%N")
				c0_file.put_string ("  *nc = ((T17*)obj)->a2;%N")
				c0_file.put_string ("  return ((T15*)((T17*)obj)->a1)->z2;%N")
			else
				c0_file.put_string (" return 0; ")
			end
			c0_file.put_string ("}%N")
			c0_file.put_string ("T2* (*")
			c0_file.put_string ("gedb_chars");
			c0_file.put_string (")(void*,EIF_INTEGER_32*) = ")
			c0_file.put_string ("gedb_chars");
			c0_file.put_string ("_;%N")
			c0_file.put_string ("static T3* gedb_unichars_(void* obj, EIF_INTEGER_32* nc) {")
			l_type := c_generator.debugger.string32_type
			if l_type /= Void and then l_type.is_alive then
				c0_file.put_string ("%N  *nc = 0;%N")
				c0_file.put_string ("  if (obj==0) return 0;%N")
				c0_file.put_string ("  if (*(EIF_INTEGER_32*)obj!=18) return 0;%N")
				c0_file.put_string ("  if (((T18*)obj)->a1==0) return 0;%N")
				c0_file.put_string ("  *nc = ((T18*)obj)->a2;%N")
				c0_file.put_string ("  return ((T16*)((T18*)obj)->a1)->z2;%N")
			else
				c0_file.put_string (" return 0; ")
			end
			c0_file.put_string ("}%N")
			c0_file.put_string ("T3* (*")
			c0_file.put_string ("gedb_unichars");
			c0_file.put_string (")(void*,EIF_INTEGER_32*) = ")
			c0_file.put_string ("gedb_unichars");
			c0_file.put_string ("_;%N")
			c0_file.put_string ("void* ")
			c0_file.put_string (c_names.c_markers_name)
			c0_file.put_string ("=0;%N")
			c0_file.put_string ("void* ")
			c0_file.put_string (c_names.c_results_name)
			c0_file.put_string ("=0;%N")
			c_file.put_string ("=0;%N")
		end
	
feature {NONE} -- Print C structs 

	print_typedefs
		local
			s: IS_SYSTEM
			j, n: INTEGER
		do
--			Precursor	-- for future use
			s := c_generator.debugger
			from
				n := s.type_count
				j := 20	-- ident of NONE type
			until j = n loop
				if attached s.type_at(j) as t then
					if t.is_normal and then not t.is_basic and then t.c_name /= Void
						and then attached {IS_NORMAL_TYPE} t as nt
					 then
						if not nt.is_subobject then
							h_file.put_string ("typedef struct ")
							h_file.put_character ('_')
							h_file.put_string (nt.c_name)
							h_file.put_character (' ')
							h_file.put_string (nt.c_name)
							h_file.put_character (';')
							h_file.put_new_line
						end
					end
				end
				j := j + 1
			end
			put_structs (True)
			h_file.flush
		end

	put_structs (as_stack: BOOLEAN)
		local
			s: IS_SYSTEM
			j, n: INTEGER
		do
			s := c_generator.debugger
			from
				n := s.type_count
				j := 20
			until j = n loop
				if attached s.type_at(j) as t then
					if t.is_normal and then not t.is_basic and then t.c_name /= Void
						and then attached {IS_NORMAL_TYPE} t as nt
					 then
						if nt.base_class.has_name ("STACKFRAME") then
							if as_stack then
								put_struct (nt, h_file)
								-- only this C struct is needed in the header file
								h_file.put_string ("typedef struct _")
								h_file.put_string (nt.c_name)
								h_file.put_character (' ')
								h_file.put_string ( c_names.frame_struct_name)
								h_file.put_character (';')
								h_file.put_new_line
								h_file.flush
							end
						elseif not as_stack then
							put_struct (nt, c0_file)
							h_file.flush
						end
					end
				end
				j := j + 1
			end
		end

	put_struct (nt: IS_NORMAL_TYPE; f: KI_TEXT_OUTPUT_STREAM)
		local
			ft: IS_TYPE
			a: IS_FIELD
			i, m: INTEGER
		do
			if not nt.is_subobject then
--				f.put_string ("typedef ")
			end
			f.put_string ("struct ")
			f.put_character ('_')
			f.put_string (nt.c_name)
			f.put_character (' ')
			f.put_character ('{')
			f.put_new_line
			from
				m := nt.field_count
				i := 0
			until i = m loop
				a := nt.field_at (i)
				ft := a.type
				f.put_character (' ')
				f.put_character (' ')
				f.put_string (ft.c_name)
				if not ft.is_subobject then
					f.put_character ('*')
				end
				if ft.is_special and then attached {IS_SPECIAL_TYPE} ft as st
					and then not st.item_type.is_subobject
				 then
					f.put_character ('*')
				end
				f.put_character (' ')
				f.put_string (a.name)
				f.put_character (';')
				f.put_new_line
				if ft.is_special then
					f.put_string ("  int32_t ")
					f.put_string (a.name)
					f.put_string ("_length;%N")
				end
				i := i + 1
			end
			f.put_character ('}')
--			if not nt.is_subobject then
--				f.put_character (' ')
--				f.put_string (nt.c_name)
--			end			
			f.put_character (';')
			f.put_new_line
			f.flush
		end
		
	put_wrappers
		local
			l_array: ARRAY [STRING]
			l_pool: DS_HASH_TABLE [INTEGER, STRING]
			l_signature: STRING
			i, k, n, pos0, pos1: INTEGER
			is_ref, has_current, l_comma: BOOLEAN
		once
			l_pool := c_generator.signature_pool
			c0_file.put_string ("static void ")
			c0_file.put_string (c_names.c_wrapper_name)
			c0_file.put_string ("_(EIF_NATURAL_32 i,void *call,void *C,void **args,void *R) {%N")
			c0_file.put_string ("  switch (i) {%N")
			n := l_pool.count
			n := l_pool.count
			from
				create l_array.make_filled ("", 0, n)
				l_pool.start
			until l_pool.after loop
				l_signature := l_pool.key_for_iteration
				k := l_pool.item_for_iteration
				l_array[k] := l_signature
				l_pool.forth
			end
			from
			until i = n loop
				tmp_str.wipe_out
				l_signature := l_array [i]
				l_comma := False
				c0_file.put_string (once "  case ")
				c0_file.put_integer (i)
				c0_file.put_string (once ":  ")
				check
					l_signature.has ('=')
				end
				pos0 := l_signature.index_of ('=', 1)
				if pos0 > 1 then
						-- function 
					if l_signature [pos0 - 1] = '*' then
							-- reference type 
						c0_file.put_string (once "*(T0**)")
					else
							-- expanded type 
						put_expanded_arg (l_signature.substring (2, pos0 - 1), False)
					end
					c0_file.put_character ('R')
					c0_file.put_string (once "=((")
					c0_file.put_string (l_signature.substring (1, pos0 - 1))
						-- type name 
				else
						-- procedure 
					c0_file.put_string (once "((void")
				end
				c0_file.put_string (once "(*)(")
				if c_generator.exception_trace_mode then
					c0_file.put_string (c_generator.c_ge_call)
					c0_file.put_character ('*')
					l_comma := True
				end
				check
					l_signature.has (';')
				end
				pos1 := l_signature.index_of (';', pos0 + 1)
				if pos1 = 0 then
					pos1 := l_signature.count
				end
				has_current := pos1 > pos0 + 1
				if has_current then
					if l_comma then
						c0_file.put_character (',')
					end
						-- current type 
					c0_file.put_string (l_signature.substring (pos0 + 1, pos1 - 1))
					l_comma := True
				end
				if pos1 < l_signature.count then
					if l_comma then
						c0_file.put_character (',')
					end
						-- argument types 
					c0_file.put_string (l_signature.substring
														 (pos1 + 1, l_signature.count - 1))
				end
				c0_file.put_string (once "))call)(")
				l_comma := False
				if c_generator.exception_trace_mode then
					c0_file.put_character ('0')
					l_comma := True
				end
				if has_current then
					if l_comma then
						c0_file.put_character (',')
					end
					if l_signature [pos0 + 1] = 'v' then
						c0_file.put_string (once "(T0*)")
					elseif l_signature [pos1 - 1] = '*' then
						put_expanded_arg (l_signature.substring (pos0 + 2, pos1 - 2), True)
					else
						put_expanded_arg (l_signature.substring (pos0 + 2, pos1 - 1), True)
					end
					c0_file.put_character ('C')
					l_comma := True
				end
				from
					k := 0
				until pos1 = l_signature.count loop
					if l_comma then
						c0_file.put_character (',')
					end
					pos0 := pos1
					pos1 := l_signature.index_of (',', pos0 + 1)
					is_ref := l_signature [pos1 - 1] = '*'
					if is_ref then
						c0_file.put_string (once "(T0*)")
							-- reference 
					else
						put_expanded_arg (l_signature.substring (pos0 + 2, pos1 - 1), False)
							-- type no. 
					end
					c0_file.put_string (once "args[")
					c0_file.put_integer (k)
					c0_file.put_string (once "]")
					l_comma := True
					pos0 := pos1
					k := k + 1
				end
				c0_file.put_string (once ");  break;%N")
				i := i + 1
			end
			c0_file.put_string ("  default: R=NULL;%N  }%N}%N")
			c0_file.put_string ("void (*")
			c0_file.put_string (c_names.c_wrapper_name);
			c0_file.put_string (")(EIF_NATURAL_32,void*,void*,void**,void*) = ")
			c0_file.put_string (c_names.c_wrapper_name);
			c0_file.put_string ("_;%N")
		end

	put_expanded_arg (s: STRING; as_address: BOOLEAN)
		do
			if not as_address then
				c0_file.put_character ('*')
			end
			c0_file.put_character ('(')
			c0_file.put_character ('T')
			c0_file.put_string (s)
			c0_file.put_character ('*')
			c0_file.put_character (')')
		end

feature {NONE} -- Implementation

	c0_file: KL_TEXT_OUTPUT_FILE

	preamble: STRING =
	"[
	/*
	  This file has been generated automaticlly, do not modify!
	*/
	
	
	 ]"
	 
invariant

	when_pma: c_generator.pma_only implies not c_generator.supports_marking 

note

	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
