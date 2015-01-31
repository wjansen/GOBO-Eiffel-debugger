class MIX

inherit
	
	ANY
		redefine
			out
		end
	
create

	make

feature {NONE} -- Initialization

	make
		local
			play: PLAY
			s: PC_SERIALIZER
		do
			create play.make
			persona := play.personae [3]
			i1 := {INTEGER_64}.max_value
			i2 := {INTEGER_32}.max_value
			i3 := i2 - 1
			r1 := {REAL_64}.max_value
			r2 := {REAL_32}.max_value
			r3 := r2 / 2.0
			create some_object
			create another_object
		end

feature -- Access

	i1: INTEGER_64

	i2: INTEGER_32

	i3: INTEGER_32

	r1: REAL_64

	r2: REAL_32

	r3: REAL_32

	persona: PERSONA

	some_object: SOME_CLASS

	another_object: ANOTHER_CLASS
	
feature -- Output

	out: STRING
		do
			create Result.make (100)
			Result.append (tagged ("i1", i1.generator))
			Result.append_integer_64 (i1)
			Result.append_character ('%N')
			Result.append (tagged ("i2", i2.generator))
			Result.append_integer (i2)
			Result.append_character ('%N')
			Result.append (tagged ("i3", i3.generator))
			Result.append_integer (i3)
			Result.append_character ('%N')
			Result.append (tagged ("r1", r1.generator))
			Result.append_double (r1)
			Result.append_character ('%N')
			Result.append (tagged ("r2", r2.generator))
			Result.append_real (r2)
			Result.append_character ('%N')
			Result.append (tagged ("r3", r3.generator))
			Result.append_real (r3)
			Result.append_character ('%N')
			if persona /= Void then
				Result.append (tagged ("p", persona.generator))
				Result.append_character ('%N')
				Result.append (persona.out)
			else
				Result.append ("p = Void%N")
			end
			if some_object /= Void then
				Result.append (tagged ("so", some_object.generator))
				Result.append_character ('%N')
				Result.append (some_object.out)
			else
				Result.append ("so = Void%N")
			end
			if another_object /= Void then
				Result.append (tagged ("ao", another_object.generator))
				Result.append_character ('%N')
				Result.append (another_object.out)
			else
				Result.append ("ao = Void%N")
			end
		end

feature {NONE} -- Output

	tagged (name, type: STRING): STRING
		do
			Result := name + ":%T" + type + " = "
		end
	
end
