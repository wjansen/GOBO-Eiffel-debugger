note

	description: "Generator of C code of the debugger."
	library: "Gobo Eiffel Tools Library"

class ET_TABLE_EXTENSION

inherit

	ET_EXTENSION
		redefine
			print_defines,
			print_typedefs
		end

	EXCEPTIONS
	
	DOUBLE_MATH
	
create

	make
	
feature -- Basic operation
	
	save_system (a_target_system: IS_SYSTEM)
		local
			id: INTEGER
		do
			print_extension
			h_file.put_string ("#define ")
			h_file.put_string (c_names.table_name)
			h_file.put_new_line
			put_class_table 
			put_names_table
			put_typeset_table 
			put_type_tables
			put_onces_table
			-- Declare `root'
			if attached compilee.root_type as rt then
				id := rt.ident
				put_global_integer (id, c_names.c_root_name, False)
			end
			if attached compilee.any_type as at then
				id := at.ident
				put_global_integer (id, c_names.c_any_name, False)
			end
			put_global_integer (compilee.compilation_time, c_names.c_time_name, True)
			put_global_string (compilee.name, c_names.c_system_name)
			c_generator.flush_to_c_file
		end
	
feature {NONE} -- Extension parts

	print_defines
		do
		end
	
feature {NONE} -- Print C structs 

	print_typedefs 
		once
			put_struct_declaration (c_names.field_struct_name, Void, field_struct)
			put_struct_declaration (c_names.type_struct_name, c_names.c_type_name,
															simple_type_struct)
			put_struct_declaration (c_names.boxed_type_struct_name, Void,
															boxed_struct)
			put_struct_declaration (c_names.agent_struct_name, Void,
															agent_struct)
		end

	put_type_struct_fields (a_type: ET_IS_TYPE)
		local
			l_type: ET_IS_TYPE
			l_dynamic: ET_DYNAMIC_TYPE
			id, m, ng, na, nr: INTEGER
			boxed: BOOLEAN
		do
			break_line (24)
			id := a_type.ident
			if a_type.is_agent and then attached {ET_IS_AGENT_TYPE} a_type as at then
				l_dynamic := at.declared_type.origin
			else
				l_dynamic := a_type.origin
			end
			if a_type.is_alive then
				na := a_type.field_count
				if compilee.needs_routines then
					nr := a_type.routine_count
				end
			end
			ng := a_type.generic_count
			boxed := a_type.is_subobject and then a_type.generic_count = 0
			if (boxed or else a_type.is_agent) then
				c_file.put_character ('{')
			end
				-- Simple type struct: 
			c_file.put_integer (a_type.flags)
			c_file.put_character (',')
			break_line (3)
			if attached a_type.base_class as bc then
				c_file.put_integer (bc.ident)
				break_line (3)
			else
				c_file.put_integer (0)
				break_line (2)
			end
			c_file.put_character (',')
			if a_type.is_alive then
				c_file.put_string (sizeof)
				c_generator.print_type_name (l_dynamic, c_file)
				c_file.put_character (')')
				c_file.put_character (',')
				if a_type.is_meta_type then
					c_file.put_string (zero2)
					break_line (4)
				else
					if a_type.is_subobject then
						if a_type.flags & {IS_BASE}.Missing_id_flag /= 0 then
							c_file.put_string (c_generator.c_ge_boxed)
							c_file.put_integer (id)
							break_line (20)
						else
							c_file.put_character ('0')
							break_line (1)
						end
					else
						c_file.put_string (c_generator.c_ge_new)
						c_file.put_integer (l_dynamic.id)
						break_line (11)
					end
					c_file.put_character (',')
					c_file.put_character ('&')
					c_generator.print_default_name (l_dynamic, c_file)
					break_line (14)
				end
			else
				c_file.put_string (zero3)
				break_line (8)
			end
			c_file.put_character (',')
			break_line (2)
			if na > 0 then
				c_file.put_string (c_names.c_field_name)
				c_file.put_integer (id)
				break_line (6)
			else
				c_file.put_integer (0)
				break_line (2)
			end
			c_file.put_character (',')
			c_file.put_integer (na)
			c_file.put_character (',')
			if nr > 0 then
				c_file.put_string (c_names.c_routine_name)
				c_file.put_integer (id)
				break_line (6)
			else
				c_file.put_integer (0)
				break_line (2)
			end			
			c_file.put_character (',')
			c_file.put_integer (nr)
			c_file.put_character (',')
			if ng > 0 then
				c_file.put_string (c_names.c_generic_name)
				c_file.put_integer (id)
				break_line (6)
			else
				c_file.put_integer (0)
				break_line (2)
			end
			c_file.put_character (',')
			c_file.put_integer (ng)
			if (boxed or else a_type.is_agent) then
				c_file.put_character ('}')
			end

			if a_type.is_agent and then attached {ET_IS_AGENT_TYPE} a_type as at then
				c_file.put_character (',')
				c_file.put_integer (at.declared_type.ident)
				c_file.put_character (',')
				break_line (6)
				c_file.put_integer (at.closed_operands_tuple.ident)
				c_file.put_character (',')
				break_line (6)
				m := compilee.index_of_name (at.routine_name)
				c_file.put_integer (m)
				c_file.put_character (',')
				break_line (4)
				c_file.put_character ('"')
				c_file.put_string (at.open_closed_pattern)
				c_file.put_character ('"')
				c_file.put_character (',')
				break_line (8)
				c_file.put_character ('&')
				l_dynamic := at.declared_type.origin
				c_generator.print_default_name (l_dynamic, c_file)
				c_file.put_character ('.')
				c_generator.print_attribute_routine_function_name (l_dynamic, c_file)
				c_file.put_character (',')
				break_line (9)
				at.print_function (c_file, c_generator)
			elseif boxed then
				-- Boxed type struct: 
				c_file.put_character (',')
				c_file.put_string (sizeof)
				c_generator.print_boxed_type_name (l_dynamic, c_file)
				c_file.put_character (')')
				c_file.put_character (',')
				break_line (14)
				c_file.put_string (void_address)
				c_file.put_string (c_names.c_boxed_name)
				c_file.put_integer (a_type.ident)
				c_file.put_character (',')
				break_line (20)
				c_file.put_string (void_address)
				c_file.put_string (c_names.c_boxed_name)
				c_file.put_integer (id)
				c_file.put_character ('.')
				c_generator.print_boxed_attribute_item_name (l_dynamic, c_file)
			elseif a_type.is_subobject then
				c_file.put_character (',')
				c_file.put_string (sizeof)
				c_generator.print_type_name (l_dynamic, c_file)
				break_line (14)
				c_file.put_character (')')
				c_file.put_character (',')
				c_file.put_string (void_address)
				c_generator.print_default_name (l_dynamic, c_file)
				c_file.put_character (',')
				break_line (20)
				c_file.put_string (void_address)
				c_generator.print_default_name (l_dynamic, c_file)
			end
		end

	put_type_struct (a_type: ET_IS_TYPE)
		local
			id: INTEGER
		do
			id := a_type.ident
			if a_type.is_subobject then
				tmp_str.copy (c_names.boxed_type_struct_name)
			elseif a_type.is_agent then
				tmp_str.copy (c_names.agent_struct_name)
			else
				tmp_str.copy (c_names.type_struct_name)
			end
			tmp_str.extend (' ')
			if a_type.is_agent then
				tmp_str.append (c_names.c_agent_name)
			else
				tmp_str.append (c_names.c_type_name)
			end
			tmp_str.append_integer (id)
			c_file.put_string (static)
			c_file.put_string (tmp_str)
			c_file.put_character ('=')
			c_file.put_character ('{')
			put_type_struct_fields (a_type)
			c_file.put_string (close_nl)
		end

	put_class_table 
		local
			i, n: INTEGER
		do
			line_len := 0
			n := compilee.class_count
			tmp_str.copy ("char *")
			tmp_str.append (c_names.c_class_name)
			tmp_str.extend ('[')
			h_file.put_string (extern)
			h_file.put_string (tmp_str)
			h_file.put_character (']')
			h_file.put_character (';')
			h_file.put_new_line
			tmp_str.append_integer (n)
			tmp_str.append ("]={0")
			from i := 1 until i = n loop
				tmp_str.extend (',')
				write_line (tmp_str)
				tmp_str.clear_all
				if attached compilee.class_at (i) as c then
					tmp_str.extend ('"')
					c.append_name (tmp_str)
					tmp_str.extend ('"')
				else
					tmp_str.extend ('0')
				end
				i := i + 1
			end
			tmp_str.append ("};%N")
			c_file.put_string (tmp_str)

			line_len := 0
			tmp_str.wipe_out
			tmp_str.copy ("int ")
			tmp_str.append (c_names.c_class_flag_name)
			tmp_str.extend ('[')
			h_file.put_string (extern)
			h_file.put_string (tmp_str)
			h_file.put_character (']')
			h_file.put_character (';')
			h_file.put_new_line
			tmp_str.append_integer (n)
			tmp_str.append ("]={0")
			from i := 1 until i = n loop
				tmp_str.extend (',')
				write_line (tmp_str)
				tmp_str.clear_all
				if attached compilee.class_at (i) as c then
					tmp_str.append_integer (c.flags)
				else
					tmp_str.extend ('0')
				end
				i := i + 1
			end
			tmp_str.append ("};%N")
			c_file.put_string (tmp_str)
			put_global_integer (n, c_names.c_class_count_name, False)
			c_generator.flush_to_c_file
		end

	put_type_tables
		local
			i, nt, na: INTEGER
			boxed: BOOLEAN
		do
			nt := compilee.type_count
			from
				i := 1
			until i = nt loop
				if attached compilee.type_at (i) as t then
					if t.is_special and then attached {ET_IS_SPECIAL_TYPE} t as st then
						put_c_special (st)
					elseif t.is_tuple and then attached {ET_IS_TUPLE_TYPE} t as tt then
						put_c_tuple (tt)
					elseif t.is_agent and then attached {ET_IS_AGENT_TYPE} t as at then
						put_c_agent (at)
					else
						put_c_normal (t)
					end
				end
				i := i + 1
			end
			line_len := 0
			tmp_str.copy (c_names.type_struct_name)
			tmp_str.extend (' ')
			tmp_str.extend ('*')
			tmp_str.append (c_names.c_type_name)
			tmp_str.extend ('[')
			tmp_str.append_integer (nt)
			tmp_str.append ("]={0")
			from i := 1 until i = nt loop
				tmp_str.extend (',')
				write_line (tmp_str)
				tmp_str.clear_all
				if attached compilee.type_at (i) as t then
					if t.is_subobject or else t.is_agent then
						tmp_str.extend ('(')
						tmp_str.append (c_names.type_struct_name)
						tmp_str.extend ('*')
						tmp_str.extend (')')
					end
					tmp_str.extend ('&')
					if t.is_agent then
						tmp_str.append (c_names.c_agent_name)
					else
						tmp_str.append (c_names.c_type_name)
					end
					tmp_str.append_integer (i)
				else
					tmp_str.extend ('0')
				end
				i := i + 1
			end
			tmp_str.append (close_nl)
			c_file.put_string (tmp_str)
			put_global_integer (nt, c_names.c_type_count_name, False)
			c_generator.flush_to_c_file
		end

  put_names_table 
    local
      l_names: ARRAY [READABLE_STRING_8]
      l_name: READABLE_STRING_8
      i, j, m, n: INTEGER
			c: CHARACTER
    do
      l_names := compilee.names_array
      n := l_names.count
      open_array_declaration (-1, n + 1, "char*", c_names.c_names_name, False)
      c_file.put_character ('0')
      from until i = n loop
        c_file.put_character (',')
        i := i + 1
        tmp_str.clear_all
        l_name := l_names [i]
				if attached l_name as nm then
					tmp_str.extend ('"')
					c := nm[1]
					if c.is_alpha then
						tmp_str.append(nm)
					else
						from
							j := 0
						until j = nm.count loop
							j := j + 1
							c := nm[j]
							if c ='\' then
								tmp_str.extend ('\')
							end
							tmp_str.extend (c)
						end
					end
					tmp_str.extend ('"')
				else
					tmp_str.extend ('0')
				end
        break_line (tmp_str.count + 1)
        c_file.put_string (tmp_str)
      end
      close_array_declaration
      put_global_integer (n + 1, c_names.c_names_count_name, False)
      c_generator.flush_to_c_file
    end

feature -- Building runtime descriptors 

	put_c_normal (a_type: ET_IS_TYPE)
		local
			i, ng, na: INTEGER
		do
			if a_type.is_alive then
				na := a_type.field_count
			end
			if na > 0 then
				put_field_table (a_type)
			end
			if compilee.needs_routines then
				put_routine_table (a_type)
			end
			ng := a_type.generic_count
			if ng > 0 then
				put_generic_table (a_type)
			end
			if a_type.is_subobject and then ng = 0 then
				c_file.put_string (static)
				c_generator.print_boxed_type_name (a_type.origin, c_file)
				c_file.put_character (' ')
				c_file.put_string (c_names.c_boxed_name)
				c_file.put_integer (a_type.ident)
				c_file.put_character ('=')
				c_file.put_character ('{')
				c_file.put_integer (a_type.ident)
				c_file.put_string (close_nl)
			end
			put_type_struct (a_type)
		end

	put_c_special (a_type: ET_IS_SPECIAL_TYPE)
		do
			if a_type.is_alive then
				put_field_table (a_type)
			end
			if compilee.needs_routines then
				put_routine_table (a_type)
			end
			put_generic_table (a_type)
			put_type_struct (a_type)
		end

	put_c_tuple (a_type: ET_IS_TUPLE_TYPE)
		do
			if a_type.generic_count > 0 then
				if a_type.is_alive then
					put_field_table (a_type)
				end
				put_generic_table (a_type)
			end
			if compilee.needs_routines then
				put_routine_table (a_type)
			end
			put_type_struct (a_type)
		end

	put_c_agent (a_type: ET_IS_AGENT_TYPE)
		local
			i, id: INTEGER
		do
			put_field_table (a_type)
			put_type_struct (a_type)
		end

	put_generic_table (a_type: ET_IS_TYPE)
		require
			has_generics: a_type.generic_count > 0
			not_agent: not a_type.is_agent
		local
			i, n: INTEGER
		do
			n := a_type.generic_count
			open_array_declaration (a_type.ident, n, int, c_names.c_generic_name, True)
			from i := 0 until i = n loop
				if i > 0 then
					c_file.put_character (',')
				end
				c_file.put_integer (a_type.generic_at (i).ident)
				i := i + 1
			end
			close_array_declaration
		end

	put_field_table (a_type: ET_IS_TYPE)
		require
			is_alive: a_type.is_alive
			not_agent: not a_type.is_agent
		local
			l_type, l_declared_type: ET_IS_TYPE
			l_field: ET_IS_FIELD
			l_name, l_field_name: STRING
			i, m, n, n1: INTEGER
		do
			n1 := a_type.field_count
			n := n1
			l_name := c_names.field_struct_name
			if a_type.is_agent and then attached {ET_IS_AGENT_TYPE} a_type as at then
				l_type := at.closed_operands_tuple
				n := l_type.field_count
				if at.result_type /= Void then
					l_declared_type := at.declared_type
				end
			else
				l_type := a_type
			end
			check n <= n1 and n1 <= n + 1 end
			open_array_declaration (a_type.ident, n1, l_name, c_names.c_field_name, True)
			from i := 0 until i = n1 loop
				if i = n then
					-- agent result: replace field description but not its name
					l_type := l_declared_type
					l_field := l_type.field_at (2)
				else
					l_field := l_type.field_at (i)
				end
				l_field_name := a_type.field_at (i).name
				tmp_str.clear_all
				if i > 0 then
					tmp_str.extend (',')
					tmp_str.extend ('%N')
					tmp_str.extend (' ')
					tmp_str.extend (' ')
				end
				tmp_str.extend ('{')
				tmp_str.append (void_address)
				c_file.put_string (tmp_str)
				tmp_str.clear_all				
				c_generator.print_default_name (l_type.origin, c_file)
 				c_file.put_character ('.')
				if l_type.is_normal then
					c_generator.print_attribute_name (l_field.origin, l_field.type.origin, c_file)
				elseif l_type.is_special and then attached {ET_IS_SPECIAL_TYPE} l_type as l_special then
					inspect i
					when 0 then
						c_generator.print_attribute_special_count_name (l_special.origin, c_file)
					when 1 then
						c_generator.print_attribute_special_capacity_name (l_special.origin, c_file)
					when 2 then
						c_generator.print_attribute_special_item_name (l_special.origin, c_file)
					else
					end
				elseif l_type.is_tuple and then attached {ET_IS_TUPLE_TYPE} l_type as l_tuple then
					c_generator.print_attribute_tuple_item_name (i + 1, l_tuple.origin, c_file)
				end
 				c_file.put_character (',')
				c_file.put_integer (l_field.type.ident)
 				c_file.put_character (',')
				m := compilee.index_of_name (l_field_name)
				c_file.put_integer (m)
				if with_typesets and then attached l_field.type_set as ts
					and then compilee.typeset_table.has (ts) 
				 then
					c_file.put_character (',')
					c_file.put_integer (compilee.typeset_table.item (ts))
				end
				c_file.put_character ('}')
				i := i + 1
			end
			close_array_declaration
		end

	put_routine_table (a_type: ET_IS_TYPE)
		local
			r: ET_IS_ROUTINE
			i, n: INTEGER
		do
			n := a_type.routine_count
			open_array_declaration (a_type.ident, n, "void*", c_names.c_routine_name, True)
			from
			until i = n loop
				r := a_type.routine_at (i)
				r.print_name(c_file, c_generator)
				c_file.put_character(',')
				break_line (10)
				i := i + 1
			end
			close_array_declaration
		end

	put_typeset_table 
		require
			has_typesets: attached compilee.typeset_table
		local
			table: DS_HASH_TABLE [INTEGER, IS_SET [ET_IS_TYPE]]
			linear: ARRAY [IS_SET [ ET_IS_TYPE]]
			ts: IS_SET [ET_IS_TYPE]
			ts_name: STRING
			i, j, k, l, n: INTEGER
		do
			table := compilee.typeset_table
			ts_name := c_names.c_typeset_name
			if compilee.needs_typeset then
				n := table.count
			end
			if n > 0 then
				with_typesets := compilee.needs_typeset 
				create linear.make (1, n * 2)
				l := log(compilee.type_count).floor + 2
				from 
					n := 0
					table.start
				until table.after loop
					i := table.item_for_iteration
					if i > n then
						n := i
					end
					ts := table.key_for_iteration
					k := ts.count
					if k > 0 then
						linear.force (ts, i)
						open_array_declaration (i, k, int, ts_name, True)
						from
							j := 0
						until j = k loop
							c_file.put_integer (ts [j].ident)
							c_file.put_character (',')
							break_line (l)
							j := j + 1
						end
						close_array_declaration
					end
					table.forth
				end
			end
			open_array_declaration (-1, n + 1, "int*", ts_name, False)
			l := log10(n).floor
			l := ts_name.count + l + 2	-- about `l' digits and 2 special chars
			from
				i := 1
				c_file.put_character ('0')
			until i > n loop
				c_file.put_character (',')
				if attached linear [i] then
					break_line (l)
					c_file.put_string (ts_name)
					c_file.put_integer (i)
				else
					break_line (2)
					c_file.put_character ('0')
				end
				i := i + 1
			end
			close_array_declaration
			c_generator.flush_to_c_file
			open_array_declaration (-1, n + 1, int, c_names.c_typeset_size_name, False)
			from
				i := 1
				c_file.put_character ('0')
			until i > n loop
				c_file.put_character (',')
				break_line (2)
				if attached linear [i] as set then
					c_file.put_integer (set.count)
				else
					c_file.put_character ('0')
				end
				i := i + 1
			end
			close_array_declaration
			c_generator.flush_to_c_file
		end
	
	put_onces_table
		local
			i, n: INTEGER
		do
			from
				n := compilee.once_count
				open_array_declaration (-1, n, "void*", c_names.c_once_name, False)
			until i = n loop
				if attached compilee.once_at (i) as o then
					o.print_init (c_file, c_generator)
					break_line (14)
				else
						c_file.put_character ('0')
						break_line (2)
				end
				c_file.put_character (',')
				i := i + 1
			end
			close_array_declaration
			c_generator.flush_to_c_file
			
			open_array_declaration (-1, n, "void*", c_names.c_once_value_name, False)
			from
				i := 0
			until i = n loop
				if attached compilee.once_at (i) as o and then o.is_function then
					o.print_value (c_file, c_generator)
					break_line (14)
				else
					c_file.put_character ('0')
					break_line (2)
				end
				c_file.put_character (',')
				i := i + 1
			end
			close_array_declaration
			c_generator.flush_to_c_file
			put_global_integer (n, c_names.c_once_count_name, False)
			
			n := compilee.constant_count
			open_array_declaration (-1, n, "void*", c_names.c_ms_name, False)
			from
				i := 0
			until i = n loop
				if attached compilee.constant_at (i) as c
					and then not c.type.is_basic
				 then
					c.print_name (c_file, c_generator)
					break_line (14)
				else
					c_file.put_character ('0')
					break_line (2)
				end
				c_file.put_character (',')
				i := i + 1
			end
			close_array_declaration
			c_generator.flush_to_c_file
			put_global_integer (n, c_names.c_ms_count_name, False)
		end
	
feature {NONE} -- Implementation 

	put_struct_declaration (struct: STRING; c_name: detachable STRING;
													declaration: STRING)
		do
			h_file.put_string ("typedef struct ")
			h_file.put_string (struct)
			h_file.put_character ('_')
			h_file.put_character (' ')
			h_file.put_string (struct)
			h_file.put_character (';')
			h_file.put_new_line
			h_file.put_string ("struct ")
			h_file.put_string (struct)
			h_file.put_character ('_')
			h_file.put_string (" {%N")
			h_file.put_string (declaration)
			h_file.put_string ("};%N")
			if attached c_name as cn then
				h_file.put_string ("extern ")
				h_file.put_string (struct)
				h_file.put_character (' ')
				h_file.put_character ('*')
				h_file.put_string (cn)
				h_file.put_string ("[];%N")
			end
		end

	int: STRING = "int"
	
	static: STRING = "static "
	
	extern: STRING = "extern "
	
	sizeof: STRING = "sizeof("

	zero2: STRING = "0,0"
	
	zero3: STRING = "0,0,0"

	comma_nl: STRING = ",%N  "
	
	close_nl: STRING = "};%N"

	with_typesets: BOOLEAN
	
	field_struct: STRING =
	"{ 
	 void *def; 
	 int type_id; 
	 int name_id;
	 int typeset_id;
	 
	 }"
	 
	simple_type_struct: STRING =
	"{ 
	 int flags; 
	 int class_id;
	 int size; 
	 void *alloc; 
	 void *def; 
	 GEIP_F *fields; 
	 int nfields; 
	 void *routines; 
	 int nroutines; 
	 int *generics; 
	 int ngenerics; 
	 
	 }"
		
	boxed_struct: STRING =
	"{
	 GEIP_T simple;
	 int boxed_size; 
	 void *boxed_def; 
	 void *subobject; 
	 
	 }"
	 
	agent_struct: STRING =
	"{
	 GEIP_T simple;
	 int declared_id;
	 int closed_tuple_id;
	 int routine_name;
	 char *open_closed;
	 void *call_field;
	 void *call;
	 
	}"

invariant
	
note

	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
