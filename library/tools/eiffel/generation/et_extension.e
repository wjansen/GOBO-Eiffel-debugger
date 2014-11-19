note

	description: "Generator of additional C code of the debuggee."
	library: "Gobo Eiffel Tools Library"

deferred class ET_EXTENSION
	
inherit
	
	PC_BASE
	
feature {NONE} -- Initialization
	
	make (a_generator: like c_generator; a_compilee: like compilee;
			a_c_names: like c_names)
		require
			a_generator_has_c_names: attached a_generator.c_names 
		do
			c_generator := a_generator
			compilee := a_compilee
			c_names := a_c_names
			h_file := c_generator.header_file
			c_file := c_generator.current_file
		ensure
			generator_set: c_generator = a_generator
			c_names_set: c_names = a_c_names
		end
	
feature -- Access
	
	c_generator: ET_INTROSPECT_GENERATOR
	
feature -- Basic operation 
	
	save_system (a_target_system: IS_SYSTEM)
		note
			action: "Store `compilee' as C code to file `c-file'."
			a_target_system: "description of the storing system"
		deferred
		end
         
feature {NONE} -- Extension parts
         
	print_extension 
		do
			print_typedefs
			print_defines
			print_callbacks
			h_file.flush
			c_generator.flush_to_c_file
		end
	
	print_defines
		do
			h_file.put_string ("#ifndef ")
			h_file.put_string (c_names.struct_name)
			h_file.put_string ("INTRO%N#define ")
			h_file.put_string (c_names.struct_name)
			h_file.put_string ("INTRO%N#endif%N")
		end
	
	print_typedefs
		do
		end
	
	print_callbacks
		do
		end

feature {NONE} -- Elementary IO 
	
	put_global_integer (n: INTEGER_64; name: STRING; long: BOOLEAN)
		note
			action: "Print declaration, definition and initialization of a global integer."
			n: "init value"
			name: "variable name"
			long: "is it ann int64_t variable?"
		do
			if long then
				tmp_str.copy (once "EIF_INTEGER_64 ")
			else
				tmp_str.copy (once "EIF_INTEGER_32 ")
			end
			tmp_str.append (name)
			if attached h_file as h then
				h_file.put_string ("extern ")
				h_file.put_string (tmp_str)
				h_file.put_character (';')
				h_file.put_new_line
			end
			c_file.put_string (tmp_str)
			c_file.put_character ('=')
			c_file.put_integer_64 (n)
			if long then
				c_file.put_character ('L')
				c_file.put_character ('L')
			end
			c_file.put_character (';')
			c_file.put_new_line
		end
	
	put_global_string (str: READABLE_STRING_8; name: STRING)
		note
			action: "Print declaration, definition and initialization of a global string."
			str: "init value"
			name: "variable name"
		do
			tmp_str.copy (once "char *")
			tmp_str.append (name)
			if attached h_file as h then
				h_file.put_string ("extern ")
				h_file.put_string (tmp_str)
				h_file.put_character (';')
				h_file.put_new_line
			end
			c_file.put_string (tmp_str)
			c_file.put_character ('=')
			c_file.put_character ('"')
			c_file.put_string (str)
			c_file.put_character ('"')
			c_file.put_character (';')
			c_file.put_new_line
		end
	
	print_c_declaration (type, name: STRING)
		note
			action: "[
							 Print a C declaration like "extern type name;"
							 to the header file.
							 ]"
			type: "type name in C"
			name: "top object name in C"
		do
			if attached h_fiel as h then
				h_file.put_string (once "extern ")
				h_file.put_string (type)
				h_file.put_character (' ')
				h_file.put_string (name)
				h_file.put_character (';')
				h_file.put_new_line
				h_file.flush
			end
		end
	
	print_c_definition (type, name, value: STRING)
		note
			action:
			"[
			 Print a C definition like "type name = value;"
			 to the C file.
			]"
			type: "type name in C"
			name: "top object name in C"
			value: "value of top object as C expression"
		do
			c_file.put_string (type)
			c_file.put_character (' ')
			c_file.put_string (name)
			c_file.put_string (" = ")
			c_file.put_string (value)
			c_file.put_character (';')
			c_file.put_new_line
			h_file.flush
		end
	
	print_forward_variable (as_address: BOOLEAN; a_type, a_name: STRING;
		a_value: detachable STRING)
		note
			action:
			"[
			 Print declaration of a global C variable.
			 If `c_file=Void' then only the `extern' declaration is printed.
			 ]"
			as_address: "whether to add an asterisc to the C type"
			a_type: "C type"
			a_name: "C variable name"
			a_value:
			"[
			 C initial value, `Void' means declaration only,
			 empty means print C definition except value and closing semicolon.
			 ]"
		require
			type_not_empty: not a_type.is_empty
			name_not_empty: not a_name.is_empty
		do
			tmp_str.clear_all
			tmp_str.copy (a_type)
			tmp_str.extend (' ')
			if as_address then
				tmp_str.extend ('*')
			end
			tmp_str.append (a_name)
			if attached h_file as h then
				h_file.put_string ("extern ")
				h_file.put_string (tmp_str)
				h_file.put_character (';')
				h_file.put_new_line
			end
			if attached a_value then
				c_file.put_string (tmp_str)
				c_file.put_character ('=')
				if not a_value.is_empty then
					c_file.put_string (a_value)
					c_file.put_character (';')
					c_file.put_new_line
				end
			end
		end
	
	print_forward_function (a_result: detachable STRING; a_function: STRING;
		a_target, an_args: detachable STRING;
		a_value: detachable STRING;
		as_intern, as_export: BOOLEAN)
		note
			action:
			"[
			 Print declaration of a C function pointer.
			 If `a_value=Void' then only the `extern' declaration is printed.
			 ]"
			a_result: "C result type (`Void' for procedures)"
			a_function: "C function name"
			a_target: "C target type (`Void' for creation routine)"
			an_args: "C argument types, comma separated"
			a_value:
		"[
		 Name of fuction pointer, `Void' means declaration only,
		 empty means print C definition except value and closing semicolon.
		 ]"
		require
			function_not_void: not a_function.is_empty
		local
			l_comma: BOOLEAN
		do
			if attached a_result as r and then not r.is_empty then
				tmp_str.copy (r)
			else
				tmp_str.copy (once "void")
			end
			tmp_str.append (once " (*")
			tmp_str.append (a_function)
			tmp_str.append (")(")
			if attached a_target as t and then not t.is_empty then
				if l_comma then
					tmp_str.extend (',')
				end
				tmp_str.append (t)
				l_comma := True
			end
			if attached an_args as a and then not a.is_empty then
				if l_comma then
					tmp_str.extend (',')
				end
				tmp_str.append (a)
				l_comma := True
			end
			if not l_comma then
				tmp_str.append (once "void")
			end
			tmp_str.extend (')')
			if as_intern then
				h_file.put_string ("extern ")
			elseif as_export then
				h_file.put_string ("DllExport ")
			else
				h_file.put_string ("DllImport ")
			end
			h_file.put_string (tmp_str)
			h_file.put_character (';')
			h_file.put_new_line
			if attached a_value then
				c_file.put_string (tmp_str)
				c_file.put_character ('=')
				if not a_value.is_empty then
					c_file.put_string(a_value)
					c_file.put_character (';')
					c_file.put_new_line
				end
			end
		end
	
	array_declaration_is_open: BOOLEAN
	
	open_array_declaration (id, n: INTEGER; struct_name, field_name: STRING; static: BOOLEAN)
		require
			n_not_negative: n >= 0
		do
			array_declaration_is_open := n > 0
			if attached struct_name as sn then
				tmp_str.copy (sn)
				tmp_str.extend (' ')
			else
				tmp_str.clear_all
				tmp_str.append (once "void* ")
			end
			if n = 0 then
				tmp_str.extend ('*')
			end
			tmp_str.append (field_name)
			if id >= 0 then
				tmp_str.append_integer (id)
			end
			if static then
				c_file.put_string (c_generator.c_static)
				c_file.put_character (' ')
				line_len := 7
			elseif attached h_file as h then
				h_file.put_string (c_generator.c_extern)
				h_file.put_character (' ')
				h_file.put_string (tmp_str)
				if n > 0 then
					h_file.put_character ('[')
					h_file.put_character (']')
				end
				h_file.put_character (';')
				h_file.put_new_line
				line_len := 0
			end
			if n > 0 then
				tmp_str.extend ('[')
				tmp_str.append_integer (n)
				tmp_str.append (once "]={")
			else
				tmp_str.extend ('=')
				tmp_str.extend ('0')
			end
			c_file.put_string (tmp_str)
			line_len := line_len + tmp_str.count
		end
	
	close_array_declaration
		do
			if array_declaration_is_open then
				c_file.put_character ('}')
			end
			c_file.put_character (';')
			c_file.put_new_line
			c_file.flush
		end
	
	line_len, file_size: INTEGER
	
	max_line_len: INTEGER = 76
	
	break_line (l: INTEGER)
		do
			line_len := line_len + l
			if line_len > max_line_len then
				c_file.put_string (once "%N  ")
				line_len := l + 2
			end
			file_size := file_size + l
		end
	
	write_line (s: STRING)
		local
			l: INTEGER
		do
			l := s.count
			if line_len + l > max_line_len then
				c_file.put_string (once "%N  ")
				line_len := 2
			end
			c_file.put_string (s)
			line_len := line_len + l
			file_size := file_size + l
		end
	
	append_c_char (s: STRING; c: CHARACTER)
		do
			inspect c
			when '\', '%'', '"' then
				s.extend ('\')
				s.extend (c)
			when '%N' then
				s.extend ('\')
				s.extend ('n')
			when '%T' then
				s.extend ('\')
				s.extend ('t')
			else
				s.extend (c)
			end
		end
	
feature {NONE} -- Implementation
	
	c_file, h_file: KI_TEXT_OUTPUT_STREAM
	
	c_names: ET_IMPORT
	
	compilee: ET_IS_SYSTEM

	void_address: STRING = "(void*)&"
	
	tmp_str: STRING = "                                                  "
	
invariant
	
note
	
	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	author: "Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"
         
end
