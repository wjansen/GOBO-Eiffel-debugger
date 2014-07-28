note

	description:
	"[ 
	 Abstract class accessing elementary components of freely chosen objects 
	 in the course of deep object traversal. 
	 ]"

deferred class PC_SERIAL_SOURCE [SI_]

inherit

	PC_SOURCE [SI_]

feature -- Access
	
	has_consecutive_indices: BOOLEAN
	
	has_capacities: BOOLEAN = False

	is_serial: BOOLEAN = True

feature {PC_DRIVER} -- Reading object definitions 

	read_next_ident
		note
			action:
			"[
			 Read a next object ident and put it into `last_ident'
			 and its type into `last_type'.
			 ]"
		deferred
		end

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
