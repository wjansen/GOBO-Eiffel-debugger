note

	description:
		"[ 
		 Abstract class to prepare treatment of local variables and 
		once routines during mark/reset commands. 
		 ]"
		 
deferred class DG_MS_SOURCE [SI_]

inherit

	PC_SOURCE [SI_]
		undefine
			default_create,
			reset,
			pre_object,
			post_object,
			pre_agent,
			post_agent,
			post_special,
			set_field,
			read_once
		end

feature -- Access 

	last_once_init: BOOLEAN

	last_scope_var: BOOLEAN

feature {PC_DRIVER} -- Routine structure and call stack data 

	read_routine
		deferred
		end

	read_scope_var
		note
			action: "Set `last_scope_var' for actual local variable."
		deferred
		end

feature {PC_DRIVER} -- Object location 

	set_local (l: IS_LOCAL)
		note
			action: "{
			Set the descriptor for the next argument
				or local variable to be treated.
}"
			l: "local variable descriptor"
		deferred
		end

	set_once (c: IS_ONCE_CALL)
		note
			action: "{
Set the descriptor for the next once function value to be treated.
}"
			c: "once call ldescriptor"
		deferred
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
