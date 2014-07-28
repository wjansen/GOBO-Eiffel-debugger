note

	description:
	"[ 
	 Abstract class to prepare treatment of local variables and 
		once routines during mark/reset commands. 
	 ]"

deferred class DG_MS_TARGET [TI_]

inherit

	PC_TARGET [TI_]
		undefine
			default_create,
			reset,
			pre_object,
			post_object,
			pre_agent,
			post_agent,
			pre_special,
			post_special,
			put_once
		end

feature {PC_DRIVER, PC_TARGET} -- Push and pop structures 

	pre_routine (r: IS_ROUTINE)
		note
			action: "Start description of routine `r'."
		deferred
		end

	post_routine (r: IS_ROUTINE)
		note
			action: "End action begun by the last `pre_routine'."
		deferred
		end

feature -- Writing elementary data 

	put_scope_var (t: BOOLEAN)
		note
			action: "Put validity `t' of actual local variable."
		deferred
		end

feature {PC_DRIVER} -- Object location 

	set_local (l: IS_LOCAL)
		note
			action: "{
Set the descriptor for the next argument or local
variable to be treated.
}"
			l: "local variable descriptor"
		deferred
		end

	set_once (o: IS_ONCE_CALL; init: BOOLEAN)
		note
			action: "{
Set the descriptor for the next once function value
to be treated.
}"
			o: "once call descriptor"
			init: "initialize"
		deferred
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
