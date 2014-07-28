note

	description: "Internal description of a class in a system."

class PC_CLASS_TEXT

inherit

	IS_CLASS_TEXT

create

	make,
	make_in_system

feature -- Status setting 

	set_name (nm: READABLE_STRING_8)
		do
			fast_name := nm
		ensure
			name_set: fast_name.is_equal (nm)
		end

invariant

	ident_not_negative: ident >= 0

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
