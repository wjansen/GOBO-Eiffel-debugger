note

	description:
		"[ 
		 Generator of header file C code needed in both, the system 
		 and its runtime system. 
		 ]"
	library: "Gobo Eiffel Tools Library"

class ET_IMPORT

inherit
	
	KL_SHARED_FILE_SYSTEM
		export
			{} all
			{ANY} deep_copy, deep_twin, is_deep_equal, standard_is_equal
		undefine
			copy,
			is_equal,
			out
		redefine
			default_create
		end
	
	KL_SHARED_EXECUTION_ENVIRONMENT
		export
			{} all
			{ANY} deep_copy, deep_twin, is_deep_equal, standard_is_equal
		redefine
			default_create
		end
	
create

	default_create
	
feature {NONE} -- Initialization

	default_create
		do
			-- "GEIP" stands for "Gobo Eiffel Introspection & Persistence".
			struct_prefix.copy("GEIP_")	-- constants and types
			feature_prefix.copy("geip_")	-- variables and functions
			make_c_names ("")
		end

feature -- Access

	table_name: STRING
	
	rts_filename: STRING 
	
	type_struct_name: STRING

	boxed_type_struct_name: STRING

	agent_struct_name: STRING

	field_struct_name: STRING

	once_struct_name: STRING

	frame_struct_name: STRING

	float_32_union_name: STRING

	float_64_union_name: STRING

	c_system_name: STRING

	c_time_name: STRING

	c_class_name: STRING

	c_class_flag_name: STRING

	c_class_count_name: STRING

	c_type_name: STRING

	c_type_count_name: STRING

	c_agent_name: STRING

	c_agent_count_name: STRING

	c_root_name: STRING

	c_any_name: STRING

	c_generic_name: STRING

	c_field_name: STRING

	c_agent_field_name: STRING

	c_once_name: STRING

	c_once_count_name: STRING

	c_ms_name: STRING

	c_ms_count_name: STRING

	c_routine_name: STRING

	c_boxed_name: STRING

	c_type_default_name: STRING

	c_once_call_name: STRING

	c_once_value_name: STRING

	c_ident_name: STRING

	c_block_name: STRING

	c_names_name: STRING

	c_names_count_name: STRING

	c_typeset_name: STRING

	c_typeset_size_name: STRING

	c_typeset_count_name: STRING

	c_active_name: STRING

	c_rts_name: STRING

	c_set_attribute: STRING

	c_get_agent: STRING

	c_set_call: STRING

	c_alloc_name: STRING

	c_free_name: STRING

	infix_name: STRING

feature {NONE} -- Implementation 
	
	make_c_names (an_infix: READABLE_STRING_8)
		do
			infix_name := an_infix
			table_name := struct_prefix.twin
			table_name.append ("TABLES")
			type_struct_name := struct_prefix.twin
			type_struct_name.extend ('T')
			boxed_type_struct_name := struct_prefix.twin
			boxed_type_struct_name.append ("Tb")
			agent_struct_name := struct_prefix.twin
			agent_struct_name.extend ('A')
			field_struct_name := struct_prefix.twin
			field_struct_name.extend ('F')
			once_struct_name := struct_prefix.twin
			once_struct_name.extend ('O')
			frame_struct_name := struct_prefix.twin
			frame_struct_name.extend ('S')
			float_32_union_name := struct_prefix.twin
			float_32_union_name.append ("U32")
			float_64_union_name := struct_prefix.twin
			float_64_union_name.append ("U64")
			c_system_name := feature_prefix.twin
			c_system_name.append ("self")
			c_time_name := feature_prefix.twin
			c_time_name.append ("time")
			c_class_name := feature_prefix.twin
			c_class_name.extend ('c')
			c_class_flag_name := feature_prefix.twin
			c_class_flag_name.append ("cf")
			c_class_count_name := feature_prefix.twin
			c_class_count_name.append ("cc")
			c_type_name := feature_prefix.twin
			c_type_name.extend ('t')
			c_type_count_name := feature_prefix.twin
			c_type_count_name.append ("tc")
			c_root_name := feature_prefix.twin
			c_root_name.append ("root")
			c_any_name := feature_prefix.twin
			c_any_name.append ("any")
			c_agent_name := feature_prefix.twin
			c_agent_name.extend ('a')
			c_agent_count_name := feature_prefix.twin
			c_agent_count_name.append ("ac")
			c_generic_name := feature_prefix.twin
			c_generic_name.extend ('g')
			c_field_name := feature_prefix.twin
			c_field_name.extend ('f')
			c_agent_field_name := feature_prefix.twin
			c_agent_field_name.append ("fa")
			c_routine_name := feature_prefix.twin
			c_routine_name.extend ('r')
			c_once_name := feature_prefix.twin
			c_once_name.extend ('o')
			c_once_count_name := feature_prefix.twin
			c_once_count_name.append ("oc")
			c_ms_name := feature_prefix.twin
			c_ms_name.append ("ms")
			c_ms_count_name := feature_prefix.twin
			c_ms_count_name.append ("msc")
			c_boxed_name := feature_prefix.twin
			c_boxed_name.append ("box")
			c_type_default_name := feature_prefix.twin
			c_type_default_name.append ("def")
			c_once_call_name := feature_prefix.twin
			c_once_call_name.append ("os")
			c_once_value_name := feature_prefix.twin
			c_once_value_name.append ("ov")
			c_block_name := feature_prefix.twin
			c_block_name.append ("blk")
			c_ident_name := feature_prefix.twin
			c_ident_name.extend ('i')
			c_names_name := feature_prefix.twin
			c_names_name.extend ('n')
			c_names_count_name := feature_prefix.twin
			c_names_count_name.append ("nc")
			c_typeset_name := feature_prefix.twin
			c_typeset_name.append ("ts")
			c_typeset_size_name := feature_prefix.twin
			c_typeset_size_name.append ("tss")
			c_typeset_count_name := feature_prefix.twin
			c_typeset_count_name.append ("tsc")
			c_active_name := feature_prefix.twin
			c_active_name.append ("act")
			c_rts_name := feature_prefix.twin
			c_rts_name.append ("rts")
			c_set_attribute := feature_prefix.twin
			c_set_attribute.append ("field")
			c_get_agent := feature_prefix.twin
			c_get_agent.append ("agent")
			c_set_call := feature_prefix.twin
			c_set_call.append ("call")
			c_alloc_name := feature_prefix.twin
			c_alloc_name.append ("realloc")
			c_alloc_name := feature_prefix.twin
			c_alloc_name.append ("realloc")
			c_free_name := feature_prefix.twin
			c_free_name.append ("free")
		end

	put_struct_declaration (struct: STRING; c_name: detachable STRING; declaration: STRING; h_file: KI_TEXT_OUTPUT_STREAM)
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

	struct_prefix: STRING = "GEIP_"

	feature_prefix: STRING = "geip_"

invariant
	
note

	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
