note

	description: "Compile time description of an Eiffel system."

class ET_IS_NAMES

inherit

	DS_HASH_TABLE [INTEGER, READABLE_STRING_8]
		rename
			force as force_int,
			found_key as found_string,
			to_array as to_item_array
		redefine
			default_create
		end

	KL_EQUALITY_TESTER [READABLE_STRING_8]
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			test
		end

	KL_IMPORTED_STRING_ROUTINES
		undefine
			default_create,
			copy,
			is_equal,
			out
		end
	
create

	default_create

feature {NONE} -- Initialization

	default_create
		do
			make_with_equality_testers (1000, Void, Current)
			create keywords.make_equal (20)
			keywords.force ("Current", "current")
			keywords.force ("Result", "result")
			keywords.force ("False", "false")
			keywords.force ("True", "true")
			keywords.force ("Void", "void")
			keywords.force ("Precursor", "precursor")
			reset
		end

feature -- Initialization

	reset
		do
			wipe_out
			from
				keywords.start
			until keywords.after loop
				force (keywords.item_for_iteration)
				keywords.forth
			end	
		end

feature -- Access

	to_array: ARRAY [READABLE_STRING_8]
		do
			create Result.make (1, count)
			from
				start
			until after loop
				Result.put (key_for_iteration, item_for_iteration)
				forth
			end
		end
	
feature -- Basic operation

	force (s: READABLE_STRING_8)
		do
			force_int (count+1, s)
		end
	
feature -- Comparison

	test (u, v: detachable READABLE_STRING_8): BOOLEAN
		do
			if u = v then
				Result := True
			elseif attached u as u_ and then attached v as v_ then
				Result := STRING_.same_string (u_, v_)
			end
		end
	
feature {NONE} -- Implementation 

	keywords: DS_HASH_TABLE [READABLE_STRING_8, READABLE_STRING_8]
	
invariant
	
end

