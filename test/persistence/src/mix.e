class MIX

inherit
	
	STORABLE
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
			i1 := {INTEGER_32}.max_value
			i2 := i1
			i3 := i2 + 2
			r1 := {REAL_32}.max_value
			r2 := r1
			r3 := r2 * 2.0
			create some_object
			create another_object
			func := agent compare (some_object.s, ?)
		end

feature -- Access

	i1: INTEGER_32

	i2: INTEGER_64

	i3: INTEGER_64

	r1: REAL_32

	r2: REAL_64

	r3: REAL_64

	persona: PERSONA

	some_object: SOME_CLASS

	another_object: ANOTHER_CLASS
	
	func: FUNCTION [ANY, TUPLE [STRING], INTEGER]

feature -- Basic operation

	compare (s1, s2: STRING): INTEGER
		do
			if s1 > s2 then
				Result := 1
			elseif s1 < s2 then
				Result := -1
			end
		end
	
feature -- Output

	out: STRING
		do
			create Result.make (100)
			Result.append (tagged ("i1", i1.generator))
			Result.append_integer (i1)
			Result.append_character ('%N')
			Result.append (tagged ("i2", i2.generator))
			Result.append_integer_64 (i2)
			Result.append_character ('%N')
			Result.append (tagged ("i3", i3.generator))
			Result.append_integer_64 (i3)
			Result.append_character ('%N')
			Result.append (tagged ("r1", r1.generator))
			Result.append_real (r1)
			Result.append_character ('%N')
			Result.append (tagged ("r2", r2.generator))
			Result.append_double (r2)
			Result.append_character ('%N')
			Result.append (tagged ("r3", r3.generator))
			Result.append_double (r3)
			Result.append_character ('%N')
			Result.append (tagged ("p", persona.generator))
			Result.append_character ('%N')
			Result.append (persona.out)
			Result.append (tagged ("so", some_object.generator))
			Result.append_character ('%N')
			Result.append (some_object.out)
			Result.append (tagged ("ao", another_object.generator))
			Result.append_character ('%N')
			Result.append (another_object.out)
			Result.append (tagged ("func", func.generator))
			Result.append_string (func.out)
			Result.append_character ('%N')
		end

feature {NONE} -- Output

	tagged (name, type: STRING): STRING
		do
			Result := name + ":%T" + type + " = "
		end
	
end
