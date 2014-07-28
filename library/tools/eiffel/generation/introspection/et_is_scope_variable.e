note

	description:

		"Compile time description of object test locals of a routine."

class ET_IS_SCOPE_VARIABLE

inherit

	IS_SCOPE_VARIABLE
		redefine
			type,
			text,
			is_attached
		end

	ET_IS_LOCAL
		rename
			make as make_local,
			declare as declare_local
		redefine
			type,
			text,
			is_attached
		end

create

	declare

feature {} -- Initialization

	declare (id: ET_IDENTIFIER; t: ET_DYNAMIC_TYPE; as_object_test: BOOLEAN;
			h: like home; x: like text; s: ET_IS_SYSTEM)
		do
			declare_local (id, Void, t, h, x, s)
			if as_object_test then
				is_object_test := True
			else
				is_across_component := True
			end			
		end

feature -- Access 

	type: ET_IS_TYPE

	text: detachable ET_IS_FEATURE_TEXT

	is_attached: BOOLEAN

feature -- Status setting

	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
