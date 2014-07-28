note

	description:
		"[ 
		 Generator of header file C code needed in both, the system 
		 and its runtime system. 
		 ]"
	library: "Gedb Eiffel Tools Library"

class DG_IMPORT

inherit
	
	ET_IMPORT
		redefine
			default_create,
			make_c_names
		end
	
create

	default_create
	
feature {} -- Initialization

	default_create
		local
			i, n: INTEGER
		do
			gec_prefix.copy("gedb_")
			struct_prefix.copy("Gedb")
			make_c_names ("_")
		end

feature -- Access

	c_frame_name: STRING

	c_stacktop_name: STRING

	c_debug_name: STRING

	c_break_name: STRING

	c_handler_name: STRING

	c_signal_name: STRING

	c_wrapper_name: STRING

	c_skip_name: STRING

	c_pos_name: STRING

	c_jump_name: STRING

	c_errno_name: STRING
	
	c_object_name: STRING

	c_debugger_name: STRING

	c_set_field: STRING

	c_field_offset_name: STRING

	c_get_type: STRING

	c_set_local: STRING

	c_local_offset_name: STRING

	c_get_routine: STRING

	routine_struct_name: STRING

	c_init_name: STRING

	c_longjmp_name: STRING
	
	c_jmp_buffer_name: STRING

	c_jmp_buf0_name: STRING
	
	c_markers_name: STRING

	c_results_name: STRING

	feature {} -- Implementation

	make_c_names (an_infix: READABLE_STRING_8)
		do
			c_frame_name := "s"
			Precursor (an_infix)
			c_object_name := gec_prefix.twin
			c_skip_name := gec_prefix.twin
			c_stacktop_name := gec_prefix.twin
			c_stacktop_name.append ("top")
			c_debug_name := gec_prefix.twin
			c_debug_name.append ("debug")
			c_break_name := gec_prefix.twin
			c_break_name.append ("break")
			c_handler_name := gec_prefix.twin
			c_handler_name.append ("int")
			c_signal_name := gec_prefix.twin
			c_signal_name.append ("sgn")
			c_wrapper_name := gec_prefix.twin
			c_wrapper_name.append ("wrap")
			c_set_field := gec_prefix.twin
			c_set_field.append ("field")
			c_field_offset_name := gec_prefix.twin
			c_field_offset_name.append ("field_offset")
			c_get_type := gec_prefix.twin
			c_get_type.append ("type")
			c_get_routine := gec_prefix.twin
			c_get_routine.append ("routine")
			c_local_offset_name := gec_prefix.twin
			c_local_offset_name.append ("local_offset")
			c_set_local := gec_prefix.twin
			c_set_local.append ("local")
			routine_struct_name := struct_prefix.twin
			routine_struct_name.extend ('R')
			c_skip_name.append ("skip")
			c_pos_name := gec_prefix.twin
			c_pos_name.append ("pos")
			c_jump_name := gec_prefix.twin
			c_jump_name.append ("jump")
			c_errno_name := gec_prefix.twin
			c_errno_name.append ("errno")
			c_debugger_name := gec_prefix.twin
			c_debugger_name.append ("dg")
			c_longjmp_name := gec_prefix.twin
			c_longjmp_name.append ("longjmp")
			c_jmp_buffer_name := gec_prefix.twin
			c_jmp_buffer_name.append ("jmp_buffer")
			c_jmp_buf0_name := gec_prefix.twin
			c_jmp_buf0_name.append ("buf0")
			c_markers_name := gec_prefix.twin
			c_markers_name.append ("markers")
			c_results_name := gec_prefix.twin
			c_results_name.append ("results")
			c_init_name := gec_prefix.twin
			c_init_name.append ("make")
		end
	
invariant
	
note

	copyright: "Copyright (c) 2010 Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
