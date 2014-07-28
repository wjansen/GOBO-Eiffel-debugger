note

	description:
		"[ 
		 Abstract base class for treating object fields within a deep traversal. 
		 The treatment of data grouping marks and of types is implemented 
		 as no-operation. 
		 ]"

deferred class PC_ABSTRACT_TARGET

inherit

	PC_TARGET [NATURAL]
		redefine
			reset
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			field := Void
			max_ident := void_ident
		end

feature -- Access 

	has_integer_indices: BOOLEAN = True

	has_consecutive_indices: BOOLEAN
		do
			Result := True
		end

	has_position_indices: BOOLEAN
		do
		end

	void_ident: NATURAL = 0

	can_expand_strings: BOOLEAN
		do
			Result := True
		end

	must_expand_strings: BOOLEAN
		do
		end

feature {PC_DRIVER} -- Push and pop data 

	put_new_object (t: IS_TYPE)
		do
			next_ident
		end

	put_new_special (s: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			next_ident
		end

feature {PC_DRIVER} -- Object location 

	set_field (f: like field; in: NATURAL)
		do
			field := f
			field_type := f.type
			index := -1
		end

	set_index (s: IS_SPECIAL_TYPE; n: NATURAL; in: NATURAL)
		do
			field_type := s.item_type
			field := s.item_0
			index := n.to_integer_32
		end

	next_index
		do
			index := index + 1
		end
	
feature {PC_DRIVER} -- Writing array data
	
	put_booleans (bb: SPECIAL [BOOLEAN]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_boolean (bb [index])
				index := index + 1
			end
		end
	
	put_characters (cc: SPECIAL [CHARACTER]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_character (cc [index])
				index := index + 1
			end
		end
	
	put_characters_32 (cc: SPECIAL [CHARACTER_32]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_character_32 (cc [index])
				index := index + 1
			end
		end
	
	put_integers_8 (ii: SPECIAL [INTEGER_8]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_integer (ii [index])
				index := index + 1
			end
		end
	
	put_integers_16 (ii: SPECIAL [INTEGER_16]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_integer (ii [index])
				index := index + 1
			end
		end
	
	put_integers (ii: SPECIAL [INTEGER_32]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_integer (ii [index])
				index := index + 1
			end
		end
	
	put_integers_64 (ii: SPECIAL [INTEGER_64]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_integer_64 (ii [index])
				index := index + 1
			end
		end
	
	put_naturals_8 (nn: SPECIAL [NATURAL_8]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_natural (nn [index])
				index := index + 1
			end
		end
	
	put_naturals_16 (nn: SPECIAL [NATURAL_16]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_natural (nn [index])
				index := index + 1
			end
		end
	
	put_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_natural (nn [index])
				index := index + 1
			end
		end
	
	put_naturals_64 (nn: SPECIAL [NATURAL_64]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_natural_64 (nn [index])
				index := index + 1
			end
		end
	
	put_reals (rr: SPECIAL [REAL_32]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_real (rr [index])
				index := index + 1
			end
		end
	
	put_doubles (dd: SPECIAL [REAL_64]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_double (dd [index])
				index := index + 1
			end
		end
	
	put_pointers (pp: SPECIAL [POINTER]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_pointer (pp [index])
				index := index + 1
			end
		end
	
	put_strings (ss: SPECIAL [detachable STRING_8]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				if attached ss [index] as s then 
					put_string (s)
				else
					put_void_ident (Void)
				end
				index := index + 1
			end
		end
	
	put_unicodes (uu: SPECIAL [detachable STRING_32]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				if attached uu [index] as u then 
					put_unicode (u)
				else
					put_void_ident (Void)
				end
				index := index + 1
			end
		end
	
	put_references (rr: SPECIAL [NATURAL]; n: INTEGER)
		do
			from
				index := 0
			until index = n loop
				put_known_ident (rr [index], field_type)
				index := index + 1
			end
		end
	
feature {} -- Implementation 

	max_ident: NATURAL

	field_type: detachable IS_TYPE

	index: INTEGER

	next_ident
		do
			max_ident := max_ident + 1
			last_ident := max_ident
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
