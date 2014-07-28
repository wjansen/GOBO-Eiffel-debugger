note

	description: "Restoring the persistence closure of one object in memory."

class DG_RESET_SOURCE

inherit

	PC_BASIC_SOURCE
	
	DG_MS_SOURCE [NATURAL]
		undefine
			copy,
			is_equal,
			out
		end

create

	make

feature {PC_DRIVER} -- Routine structure and call stack data 

	read_routine
		local
			t: detachable IS_TYPE
			cr: BOOLEAN
		do
			read_int
			t := system.type_at (last_int)
			check attached t end
			read_int
			cr := last_int & {IS_BASE}.Creation_flag = {IS_BASE}.Creation_flag
			read_str
			last_routine := t.routine_by_name (last_str, cr)
		end

	read_scope_var
		do
			read_boolean
			last_scope_var := last_boolean
		end

feature {PC_DRIVER} -- Object location 

	set_local (l: IS_LOCAL)
		do
		end

	set_once (c: IS_ONCE_CALL)
		do
			read_boolean
			last_once_init := last_boolean
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
