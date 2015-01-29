class ANOTHER_CLASS

	inherit ANY
		redefine
			default_create,
			out
		end

create

	default_create

feature {NONE} -- Initalization

	default_create
		do
			n := -99
			t := "zyx"
		end

feature -- Access

	n: INTEGER

	t: STRING
	
feature -- Output

	out: STRING
		do
			create Result.make (100)
			Result.append ("  n = ")
			Result.append_integer (n)
			Result.append_character ('%N')
			Result.append ("  t = ")
			if t /= Void then
				Result.append (t)
			else
				Result.append ("Void")
			end
			Result.append_character ('%N')
		end
	
end

