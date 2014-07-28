note

	description:
	"[ 
     Class for accessing elementary components in memory 
		 and grouping marks in the course of deep object traversal. 
		 ]"

class DG_MARK_TARGET

inherit

	PC_BASIC_TARGET

	DG_MS_TARGET [NATURAL]
		undefine
			put_next_ident,
			put_void_ident,
			finish,
			copy,
			is_equal,
			out
		end

create

	default_create

feature {PC_DRIVER, PC_TARGET} -- Push and pop structures 

	pre_routine (r: IS_ROUTINE)
		do
			if attached r.target as t then
				write_int (t.type.ident)
			else
				write_int (0)
			end
			write_int (r.flags)
			write_str (r.name)
		end

	post_routine (r: IS_ROUTINE)
		do
		end

feature -- Writing elementary data 

	put_scope_var (t: BOOLEAN)
		do
			put_boolean (t)
		end

feature {PC_DRIVER} -- Object location 

	set_local (l: IS_LOCAL)
		do
		end

	set_once (c: IS_ONCE_CALL; init: BOOLEAN)
		do
			put_boolean (init)
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
