note

	description:

		"Compile time description of unique attributes."

class ET_IS_UNIQUE

inherit

	ET_IS_CONSTANT 
		redefine
			home,
			type,
			text
		end
	
	IS_UNIQUE
		redefine
			home,
			type,
			text
		end
	
create

	declare

feature -- Access
	
	home: ET_IS_CLASS_TEXT

	type: ET_IS_TYPE

	text: ET_IS_FEATURE_TEXT

end
