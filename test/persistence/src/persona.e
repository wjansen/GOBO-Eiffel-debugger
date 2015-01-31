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

	loves: detachable PERSONA

	lord: detachable PERSONA

feature -- Status setting

	set_loves (an_other: detachable PERSONA)
		do
			loves := an_other
		ensure
			loves_set: loves = an_other
		end
	
	set_lord (an_other: detachable PERSONA)
		do
			lord := an_other
		ensure
			loves_set: lord = an_other
		end

feature -- Output

	out: STRING
		do
			create Result.make (100)
			Result.append ("  name  = ")
			Result.append (name)
			Result.append_character ('%N')
			Result.append ("  lord  = ")
			if lord /= Void then
				Result.append (lord.name)
			else
				Result.append ("Nobody")
			end
			Result.append_character ('%N')
			Result.append ("  loves = ")
			if loves /= Void then
				Result.append (loves.name)
			else
				Result.append ("Nobody")
			end
			Result.append_character ('%N')
		end
end
