note

	description: "Character in a theatre play."

class PERSONA

inherit

	ANY
		redefine
			out
		end

create

	make

feature {NONE} -- Initialization

	make (a_name: STRING)
		do
			name := a_name
		ensure
			name_set: name = a_name
		end

feature -- Access

	name: STRING

	in_love_to: detachable PERSONA

	lord: detachable PERSONA

feature -- Status setting

	set_in_love_to (an_other: detachable PERSONA)
		do
			in_love_to := an_other
		ensure
			in_love_to_set: in_love_to = an_other
		end
	
	set_lord (an_other: detachable PERSONA)
		do
			lord := an_other
		ensure
			in_love_to_set: lord = an_other
		end

feature -- Output

	out: STRING
		do
			create Result.make (100)
			Result.append ("  name = ")
			Result.append (name)
			Result.append_character ('%N')
			Result.append ("  lord = ")
			if lord /= Void then
				Result.append (lord.name)
			else
				Result.append ("Nobody")
			end
			Result.append_character ('%N')
			Result.append ("  in_love_to = ")
			if in_love_to /= Void then
				Result.append (in_love_to.name)
			else
				Result.append ("Nobody")
			end
			Result.append_character ('%N')
		end
end
