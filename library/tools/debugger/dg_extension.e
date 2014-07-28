note

	description: "Generator of C code of the debuggee."
	library: "Gedb Eiffel Tools Library"

class DG_EXTENSION

inherit
	
	ET_EXTENSION
		redefine
			c_generator,
			c_names,
			print_callbacks,
			print_defines
		end
	
	KL_SHARED_EXECUTION_ENVIRONMENT
		export
			{} all
		undefine
			default_create,
			copy, is_equal, out
		end
	
create

	make

feature -- Access

	c_generator: DG_GENERATOR

	c_names: DG_IMPORT
	
feature -- Basic operation 
	
	save_system (a_target_system: IS_SYSTEM; with_c_names: BOOLEAN)
		note
			action: "Store `a_compilee' as C code to file `c-file'."
			a_target_system: "description of the storing system"
			a_target: "formatter to be used; use a default format if `Void'"
		local
			l_table: PC_ANY_TABLE [PC_TYPED_IDENT [NATURAL]]
			l_source: DG_SOURCE
			l_target: DG_TARGET
			l_driver: PC_FORWARD_DRIVER [NATURAL, ANY]
			l_value_name: STRING
			i: INTEGER
		do
			c_0_file.open_append
			c_file := c_0_file
			print_extension
			l_value_name := "x" 
			l_value_name.append (c_names.infix_name)
			create l_source.make (a_target_system, c_generator.runtime_system,
														c_generator, compilee)
			l_source.set_actionable (True)
			create l_target.make (c_file, "", l_value_name,
														c_names.c_rts_name, c_generator, l_source,
														with_c_names)
			create l_table.make (997)
			create l_driver.make (l_target, l_source, l_table)
			l_driver.traverse (compilee)
			c_file.close
		end
         
feature {} -- Extension parts

	print_callbacks
		do
			-- Define `free', `realloc', `jmp_buffer'
			c_file.put_string ("static void ")
			c_file.put_string (c_names.c_free_name);
			c_file.put_string ("_(void* p) {%N")
			c_file.put_string ("#ifndef EIF_BOEHM_GC%N  if (p) free(p);%N#endif%N}%N")
			c_file.put_string ("void (*")
			c_file.put_string (c_names.c_free_name);
			c_file.put_string (")(void*) = ")
			c_file.put_string (c_names.c_free_name);
			c_file.put_string ("_;%N")
			c_file.put_string ("static void* ")
			c_file.put_string (c_names.c_alloc_name)
			c_file.put_string ("_(void* p, size_t n) {%N")
			c_file.put_string ("  if (n==0) (")
			c_file.put_string (c_names.c_free_name)
			c_file.put_string (")(p);%N")
			c_file.put_string ("  return GE_null(GE_realloc(p, n));%N}%N")
			c_file.put_string ("void* (*")
			c_file.put_string (c_names.c_alloc_name)
			c_file.put_string (")(void*, size_t) = ")
			c_file.put_string (c_names.c_alloc_name)
			c_file.put_string ("_;%N")
			
			c_file.put_string ("static void* ")
			c_file.put_string (c_names.c_jmp_buffer_name)
			c_file.put_string ("_() {%N  return (")
			c_file.put_string (c_names.c_alloc_name)
			c_file.put_string (")(0, sizeof(GE_jmp_buf));%N}%N")
			c_file.put_string ("void* (*")
			c_file.put_string (c_names.c_jmp_buffer_name)
			c_file.put_string (")() = ")
			c_file.put_string (c_names.c_jmp_buffer_name)
			c_file.put_string ("_;%N")

			c_file.flush
		end

	print_defines
		local
			l_type: IS_TYPE
			fn, line: STRING
		do
			put_typedefs
			put_structs
			print_frame_struct_definition
			-- Declare `routine', `local_offset'
			l_type := c_generator.debugger.type_by_name("ROUTINE", True)
			h_file.put_string (l_type.c_name)
			h_file.put_character ('*')
			h_file.put_character (' ')
			h_file.put_string (c_names.c_get_routine,)
			h_file.put_string ("(int,int);%N")
			h_file.put_string ("void ")
			h_file.put_string (c_names.c_local_offset_name,)
			h_file.put_string ("(void*,int,int);%N")
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
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			h_file.put_string (l_type.c_name)
			h_file.put_character ('*')
			h_file.put_character (' ')
			h_file.put_string (c_names.c_get_type,)
			h_file.put_string ("(int);%N")
			h_file.put_string ("void ")
			h_file.put_string (c_names.c_field_offset_name,)
			h_file.put_string ("(void*,int,int);%N")
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
			-- Define others
			print_debuggee_declarations
			-- Print wrappers
			put_wrappers
		end

feature -- Print C structs 

	print_frame_struct_definition
		local
			s: IS_SYSTEM
			n: INTEGER
		once
			h_file.put_string ("#define ")
			h_file.put_string (c_names.c_debug_flag)
			h_file.put_character (' ')
			if c_generator.pma_only then
				h_file.put_integer (1)
			else
				h_file.put_integer (2)
			end
			h_file.put_new_line
				-- Define `skip', `pos', `jump' 
			h_file.put_string ("#define ")
			h_file.put_string (c_names.c_skip_name)
			h_file.put_string ("(l,c)  s.pos = l*256+c;%N")
			if not c_generator.pma_only then
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_pos_name)
				h_file.put_string ("(l,c,code)  s.pos = l*256+c;  ")
				if not c_generator.pma_only then
					h_file.put_string (c_names.c_debug_name)
					h_file.put_character ('(')
					h_file.put_string (c_names.c_debugger_name)
					h_file.put_string (",code);")
				end
				h_file.put_new_line
				h_file.put_string ("#define ")
				h_file.put_string (c_names.c_jump_name)
				h_file.put_string ("(l,c,code)  s.pos = l*256+c;  ")
			end
			if c_generator.supports_marking and then not c_generator.pma_only then
				h_file.put_string ("{ buf=")
				h_file.put_string (c_names.c_debug_name)
				h_file.put_character ('(')
				h_file.put_string (c_names.c_debugger_name)
				h_file.put_string (",code); \%N  if (buf) { if (GE_setjmp(*buf)) { ")
				h_file.put_string (c_names.c_stacktop_name)
				h_file.put_string ("=&s; ")
				h_file.put_string (c_names.c_debug_name)
				h_file.put_character ('(')
				h_file.put_string (c_names.c_debugger_name)
				h_file.put_character (',')
				h_file.put_integer (c_generator.After_reset_break)
				h_file.put_string ("); } \%N    else ")
				h_file.put_string (c_names.c_debug_name)
				h_file.put_character ('(')
				h_file.put_string (c_names.c_debugger_name)
				h_file.put_character (',')
				h_file.put_integer (c_generator.After_mark_break)
				h_file.put_string ("); }}%N")
			end
			h_file.flush
		end
	
	print_debuggee_declarations
		note
			action:
			"Print several C definitions and declarations to the header or C files."
		local
			l_type: IS_TYPE
			l_string: STRING
			i: INTEGER
		do
			h_file.put_string ("{

#ifdef EIF_WINDOWS 
#define DllImport __declspec(dllimport) 
#define DllExport __declspec(dllexport) 
#else 
#define DllImport extern 
#define DllExport extern 
#endif

												 }")
				-- Define `rts'
			l_type := c_generator.debugger.type_by_name("SYSTEM", True)
			c_file.put_string ("extern ")
			c_file.put_string (l_type.c_name)
			c_file.put_character ('*')
			c_file.put_character (' ')
			c_file.put_string (c_names.c_rts_name)
			c_file.put_character (';')
			c_file.put_new_line
				-- Define frame struct
			print_forward_variable (True, c_names.frame_struct_name,
															c_names.c_stacktop_name, "0")
				-- Define global data
			c_file.put_string ("GE_jmp_buf ")
			c_file.put_string (c_names.c_jmp_buf0_name)
			c_file.put_character(';')
			c_file.put_new_line
			c_file.put_string ("void* ")
			c_file.put_string (c_names.c_markers_name)
			c_file.put_string ("=0;%N")
			c_file.put_string ("void* ")
			c_file.put_string (c_names.c_results_name)
			c_file.put_string ("=0;%N")
			-- Define `make'
			print_forward_variable (True, "void", c_names.c_debugger_name, "0")
			h_file.put_string ("DllImport void* ")
			h_file.put_string (c_names.c_init_name)
				-- order of `argc', `argv' changed to match VALA's calling order:
			h_file.put_string ("(char** argv,int argc, int pma);%N")
			-- Define `zt' etc.
			c_file.put_string ("void* gedb_zt = GE_zt;%N")
			c_file.put_string ("void* gedb_zo = GE_zo;%N")
			c_file.put_string ("void* gedb_zov = GE_zov;%N")
			c_file.put_string ("void* gedb_zms = GE_zms;%N")
			if not c_generator.pma_only then
				-- Define `break'
				h_file.put_string ("DllImport ")
				if c_generator.supports_marking then
					h_file.put_string ("GE_jmp_buf * ")
				else
					h_file.put_string ("int")
				end
				h_file.put_string (c_names.c_debug_name)
				h_file.put_string ("(void* dg, int code);%N")
			end
			-- Define `longjmp'
			c_file.put_string ("static void ")
			c_file.put_string (c_names.c_longjmp_name)
			c_file.put_string ("_(void* buf, int jmp) {%N  ")
			c_file.put_string ("GE_longjmp(*(GE_jmp_buf*)buf,jmp);%N}%N")
			c_file.put_string ("void (*")
			c_file.put_string (c_names.c_longjmp_name);
			c_file.put_string (")(void*,int) = ")
			c_file.put_string (c_names.c_longjmp_name);
			c_file.put_string ("_;%N")
			-- Define `type', `field_offset'
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			l_string := l_type.c_name
			c_file.put_string (l_string)
			c_file.put_character ('*')
			c_file.put_character (' ')
			c_file.put_string (c_names.c_get_type)
			c_file.put_string ("(int t_id) {%N  ")
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			l_string := l_type.c_name
			c_file.put_string("return ")
			c_file.put_string(c_names.c_rts_name)
			c_file.put_string("->all_types[t_id];%N}%N")
			c_file.put_string ("void ")
			c_file.put_string (c_names.c_field_offset_name)
			c_file.put_string ("(void* t, int off, int f_id) {%N  ")
			c_file.put_string (l_string)
			c_file.put_string ( "* type = (")
			c_file.put_string (l_string)
			c_file.put_string ("*)t;%N  ")
			l_type := c_generator.debugger.type_by_name("FIELD", True)
			l_string := l_type.c_name
			c_file.put_string (l_string)
			c_file.put_string ("* field = type->fields[f_id];%N  ")
			c_file.put_string ("field->offset = off;%N}%N")
			-- Define `routine', `local_offset'
			l_type := c_generator.debugger.type_by_name("ROUTINE", True)
			l_string := l_type.c_name
			c_file.put_string (l_string)
			c_file.put_character ('*')
			c_file.put_character (' ')
			c_file.put_string (c_names.c_get_routine)
			c_file.put_string ("(int t_id, int r_id) {%N  ")
			l_type := c_generator.debugger.type_by_name("TYPE", True)
			l_string := l_type.c_name
			c_file.put_string(l_string)
			c_file.put_string("* t = ")
			c_file.put_string(c_names.c_rts_name)
			c_file.put_string("->all_types[t_id];%N  ")
			c_file.put_string("return t->routines[r_id];%N")
			c_file.put_string("}%N")
			l_type := c_generator.debugger.type_by_name("ROUTINE", True)
			l_string := l_type.c_name
			c_file.put_string ("void ")
			c_file.put_string (c_names.c_local_offset_name)
			c_file.put_string ("(void* r, int off, int l_id) {%N  ")
			c_file.put_string (l_string)
			c_file.put_string ( "* routine = (")
			c_file.put_string (l_string)
			c_file.put_string ("*)r;%N  ")
			l_type := c_generator.debugger.type_by_name("LOCAL", True)
			l_string := l_type.c_name
			c_file.put_string (l_string)
			c_file.put_string ("* local = routine->vars[l_id];%N  ")
			c_file.put_string ("local->offset = off;%N}%N")
			-- Define `chars', `unichars'
			c_file.put_string ("static T2* gedb_chars_(void* obj, int* nc) {")
			l_type := c_generator.debugger.string_type
			if l_type /= Void and then l_type.is_alive then
				c_file.put_string ("%N  *nc = 0;%N")
				c_file.put_string ("  if (obj==0) return 0;%N")
				c_file.put_string ("  if (*(int*)obj!=17) return 0;%N")
				c_file.put_string ("  if (((T17*)obj)->a1==0) return 0;%N")
				c_file.put_string ("  *nc = ((T17*)obj)->a2;%N")
				c_file.put_string ("  return ((T15*)((T17*)obj)->a1)->z2;%N")
			else
				c_file.put_string (" return 0; ")
			end
			c_file.put_string ("}%N")
			c_file.put_string ("T2* (*")
			c_file.put_string ("gedb_chars");
			c_file.put_string (")(void*,int*) = ")
			c_file.put_string ("gedb_chars");
			c_file.put_string ("_;%N")
			c_file.put_string ("static T3* gedb_unichars_(void* obj, int* nc) {")
			l_type := c_generator.debugger.string32_type
			if l_type /= Void and then l_type.is_alive then
				c_file.put_string ("%N  *nc = 0;%N")
				c_file.put_string ("  if (obj==0) return 0;%N")
				c_file.put_string ("  if (*(int*)obj!=18) return 0;%N")
				c_file.put_string ("  if (((T18*)obj)->a1==0) return 0;%N")
				c_file.put_string ("  *nc = ((T18*)obj)->a2;%N")
				c_file.put_string ("  return ((T16*)((T18*)obj)->a1)->z2;%N")
			else
				c_file.put_string (" return 0; ")
			end
			c_file.put_string ("}%N")
			c_file.put_string ("T3* (*")
			c_file.put_string ("gedb_unichars");
			c_file.put_string (")(void*,int*) = ")
			c_file.put_string ("gedb_unichars");
			c_file.put_string ("_;%N")
			c_file.flush
		end
	
feature {} -- Print C structs 

	base_types: DS_HASH_TABLE[IS_TYPE, IS_CLASS_TEXT]
		once
			create Result.make (99)
		end
	
	put_typedefs
		local
			s: IS_SYSTEM
			j, n: INTEGER
		do
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
						base_types.put (nt, nt.base_class)
					end
				end
				j := j + 1
			end
			h_file.flush
		end

	put_structs
		local
			f: like c_file
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
							-- only this C struct is needed in the header file
							f := h_file
							h_file.put_string ("typedef struct _")
							h_file.put_string (nt.c_name)
							h_file.put_character (' ')
							h_file.put_string ( c_names.frame_struct_name)
							h_file.put_character (';')
							h_file.put_new_line
						else
							f := c_file
						end
						put_struct (nt, f)
						f.flush
					end
				end
				j := j + 1
			end
		end

	put_struct (nt: IS_NORMAL_TYPE; file: like c_file)
		local
			ft: IS_TYPE
			f: IS_FIELD
			nm: STRING
			i, m: INTEGER
		do
			file.put_string ("struct ")
			file.put_character ('_')
			file.put_string (nt.c_name)
			file.put_character (' ')
			file.put_character ('{')
			file.put_new_line
			from
				m := nt.field_count
				i := 0
			until i = m loop
				f := nt.field_at (i)
				ft := f.type
				file.put_character (' ')
				file.put_character (' ')
				if ft.is_subobject then
					if not ft.is_basic and then attached {IS_NORMAL_TYPE} ft as nn then
						nm := nn.base_class.parent_at (0). name
						ft := c_generator.debugger.type_by_class_and_generics(nm, 0, True)
					end
					file.put_string (ft.c_name)
				else
					file.put_string (ft.c_name)					
					file.put_character ('*')
				end
				if ft.is_special and then attached {IS_SPECIAL_TYPE} ft as st
					and then not st.item_type.is_subobject
				 then
					file.put_character ('*')
				end
				file.put_character (' ')
				file.put_string (f.name)
				file.put_character (';')
				file.put_new_line
				if ft.is_special then
					file.put_string ("  int32_t ")
					file.put_string (f.name)
					file.put_string ("_length;%N")
				end
				i := i + 1
			end
			file.put_character ('}')
			file.put_character (';')
			file.put_new_line
			file.flush
		end
		
	put_wrappers
		local
			l_array: DS_ARRAYED_LIST [STRING]
			l_pool: DS_HASH_TABLE [INTEGER, STRING]
			l_signature: STRING
			i, k, pos0, pos1: INTEGER
			is_ref, has_current, l_comma: BOOLEAN
		once
			l_pool := c_generator.signature_pool
			tmp_str.copy ("static void ")
			tmp_str.append (c_names.c_wrapper_name)
			tmp_str.append ("_(int i,void *call,void *C,void **args,void *R)")
			c_file.put_string (tmp_str)
			c_file.put_string (" %N{%N  switch (i) {%N")
			from
				create l_array.make (l_pool.count)
				l_pool.start
			until l_pool.after loop
				l_signature := l_pool.key_for_iteration
				l_array.put_last (l_signature)
				l_pool.forth
			end
			from
				l_array.start
			until l_array.after loop
				tmp_str.clear_all
				l_signature := l_array.item_for_iteration
				l_comma := False
				c_file.put_string (once "  case ")
				c_file.put_integer (i)
				i := i + 1
				c_file.put_string (once ":  ")
				check
					l_signature.has ('=')
				end
				pos0 := l_signature.index_of ('=', 1)
				if pos0 > 1 then
						-- function 
					if l_signature [pos0 - 1] = '*' then
							-- reference type 
						c_file.put_string (once "*(T0**)")
					else
							-- expanded type 
						put_expanded_arg (l_signature.substring (2, pos0 - 1), False)
					end
					c_file.put_character ('R')
					c_file.put_string (once "=((")
					c_file.put_string (l_signature.substring (1, pos0 - 1))
						-- type name 
				else
						-- procedure 
					c_file.put_string (once "((void")
				end
				c_file.put_string (once "(*)(")
				if c_generator.exception_trace_mode then
					c_file.put_string (c_generator.c_ge_call)
					c_file.put_character ('*')
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
						c_file.put_character (',')
					end
						-- current type 
					c_file.put_string (l_signature.substring (pos0 + 1, pos1 - 1))
					l_comma := True
				end
				if pos1 < l_signature.count then
					if l_comma then
						c_file.put_character (',')
					end
						-- argument types 
					c_file.put_string (l_signature.substring
														 (pos1 + 1, l_signature.count - 1))
				end
				c_file.put_string (once "))call)(")
				l_comma := False
				if c_generator.exception_trace_mode then
					c_file.put_character ('0')
					l_comma := True
				end
				if has_current then
					if l_comma then
						c_file.put_character (',')
					end
					if l_signature [pos0 + 1] = 'v' then
						c_file.put_string (once "(T0*)")
					elseif l_signature [pos1 - 1] = '*' then
						put_expanded_arg (l_signature.substring (pos0 + 2, pos1 - 2), True)
					else
						put_expanded_arg (l_signature.substring (pos0 + 2, pos1 - 1), True)
					end
					c_file.put_character ('C')
					l_comma := True
				end
				from
					k := 0
				until pos1 = l_signature.count loop
					if l_comma then
						c_file.put_character (',')
					end
					pos0 := pos1
					pos1 := l_signature.index_of (',', pos0 + 1)
					is_ref := l_signature [pos1 - 1] = '*'
					if is_ref then
						c_file.put_string (once "(T0*)")
							-- reference 
					else
						put_expanded_arg (l_signature.substring (pos0 + 2, pos1 - 1), False)
							-- type no. 
					end
					c_file.put_string (once "args[")
					c_file.put_integer (k)
					c_file.put_string (once "]")
					l_comma := True
					pos0 := pos1
					k := k + 1
				end
				c_file.put_string (once ");  break;%N")
				l_array.forth
			end
			c_file.put_string ("  default: R=NULL;%N  }%N}%N")
			c_file.put_string ("void (*")
			c_file.put_string (c_names.c_wrapper_name);
			c_file.put_string (")(int,void*,void*,void**,void*) = ")
			c_file.put_string (c_names.c_wrapper_name);
			c_file.put_string ("_;%N")
			c_file.flush
		end

	put_expanded_arg (s: STRING; as_address: BOOLEAN)
		do
			if not as_address then
				c_file.put_character ('*')
			end
			c_file.put_character ('(')
			c_file.put_character ('T')
			c_file.put_string (s)
			c_file.put_character ('*')
			c_file.put_character (')')
		end

feature {} -- Implementation
	
	intro_c_names: ET_IMPORT

invariant

	when_pma: c_generator.pma_only implies not c_generator.supports_marking 

note

	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
