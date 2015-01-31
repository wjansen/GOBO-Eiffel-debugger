expanded class SOME_CLASS

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
			i := 123
			s := "abc"
		end

feature -- Access

	i: INTEGER

	s: STRING
	
feature -- Output

	out: STRING
		do
			create Result.make (100)
			Result.append ("  i = ")
			Result.append_integer (i)
			Result.append_character ('%N')
			Result.append ("  s = ")
			if s /= Void then
				Result.append (s)
			else
				Result.append ("Void")
			end
			Result.append_character ('%N')
		end
	
end

