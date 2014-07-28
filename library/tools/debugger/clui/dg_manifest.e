note

	description:

		"Descriptors of several specil entitits: Current, Result etc."


class DG_MANIFEST

inherit

	IS_ENTITY 
		rename
			runtime_system as debuggee
		undefine
			debuggee
		end

	DG_GLOBALS
		undefine
			copy,
			is_equal,
			out
		end

create

	make,
	default_create

feature {NONE} -- Initialization 

	make (nm: STRING; t: attached like type)
		do
			type := t
			fast_name := nm
			create text.make (nm, Void, 0, 0)
		end

feature -- Access 

	type: IS_TYPE

	is_attached: BOOLEAN
		do
			Result := type /= debuggee.none_type
		end
	
feature -- Status setting 

	set_type (t: IS_TYPE)
		do
			type := t
		ensure
			type_set: type = t
		end

feature {NONE} -- Implementation 

	offset: INTEGER = 0


note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
