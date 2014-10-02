note

	description: "Compiler's origin of a descriptor."

deferred class ET_IS_ORIGIN [O_, S_ -> IS_NAME]

inherit
	
	PC_ACTIONABLE
		undefine
			default_create,
			pre_store,
			post_store,
			copy,
			is_equal,
			out
		end

feature {} -- Initialization 

	make_origin (o: attached like origin)
		do
			origin := o
		ensure
			origin_set: origin = o
		end

feature -- Access 

	origin: detachable O_

	defined: BOOLEAN
			-- Has definition pass already been run? 

	system: ET_IS_SYSTEM
		once
			create Result
		end

feature -- Printing 

	print_name (a_file: KI_TEXT_OUTPUT_STREAM; a_generator: ET_C_GENERATOR)
		require
			origin_not_void: attached origin
		deferred
		end

feature {} -- PC_ACTIONABLE

	pre_store
		local
			o0: O_
		do
				origin := o0
		end

	post_store
		do
			restore
		end
	
feature {} -- Implementation

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
