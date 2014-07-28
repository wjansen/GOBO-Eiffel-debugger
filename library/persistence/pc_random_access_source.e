note

	description:
	"[ 
	 Abstract class accessing elementary components of freely chosen objects 
	 in the course of deep object traversal. 
	 ]"

deferred class PC_RANDOM_ACCESS_SOURCE [I_]
	-- I_: type of object idents 

inherit

	PC_SOURCE [I_]

feature -- Access
	
	has_consecutive_indices: BOOLEAN = False

	is_serial: BOOLEAN = False

feature -- Status setting

	set_ident (id: like last_ident)
		note
			action:
			"[
			 Set `last_ident' to `id' and adjust `last_dynamic_type', `last_count'. 
			 ]"
		require
			is_object: id /= void_ident
		deferred
		ensure
			last_ident_set: last_ident = id
			lst_dynamic_type_set: last_dynamic_type /= Void
		end
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
