note

	description:
		"[ 
		 Internal description of arguments and local variables of a routine. 
		 The description is immutable up to the `offset' which may be set later. 
		 ]"
	 
class IS_LOCAL

inherit

	IS_ENTITY 

create

	make

feature {NONE} -- Initialization 

	make (nm: READABLE_STRING_8; t: like type; ts: like type_set; f: like text)
		note
			action: "Initialize `Current'."
		do
			make_entity (nm, f)
			type := t
			type_set := ts
			offset := -1
		ensure
			name_set: has_name (nm)
			type_set: type = t
			type_set_set: type_set = ts
			text_set: text = f
		end

feature -- Access 

	is_attached: BOOLEAN 

feature {IS_BASE} -- Implemention

	offset: INTEGER
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
