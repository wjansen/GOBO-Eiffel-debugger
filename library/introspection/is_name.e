note

	description:

		"Name component of internal descriptors."

deferred class IS_NAME

inherit

	IS_BASE
		redefine
			is_equal,
			out
		end

	COMPARABLE
		redefine
			is_equal,
			out
		end

	HASHABLE
		redefine
			is_equal,
			out
		end

	PLATFORM
		redefine
			is_equal,
			out
		end

	KL_IMPORTED_STRING_ROUTINES
		redefine
			is_equal,
			out
		end
	
feature -- Access 

	name: READABLE_STRING_8
		note
			return: "Name for comparisons."
		do
			Result := fast_name
		end

feature -- Status 

	name_count: INTEGER
		note
			return: "Count of `out'."
		do
			Result := fast_name.count
		ensure
			defintition: Result = fast_name.count
		end

	has_name (s: READABLE_STRING_8): BOOLEAN
		note
			return: "Is `out' equal to `s' when ignoring letter case?"
		local
			nm: STRING
		do
			if fast_name /= Void then
				nm := fast_name
			else
				nm := name
			end
			Result := nm.count = s.count and then name_has_prefix (s)
		end

	name_has_prefix (s: READABLE_STRING_8): BOOLEAN
		note
			return: "Does `out' start with `s' when ignoring letter case?"
		local
			j: INTEGER
		do
			if attached fast_name as fn and then s.count <= fn.count then
					-- may be `Void' during startup 
				from
					j := s.count
					Result := True
				until not Result or else j = 0 loop
					Result := fn [j].as_lower = s [j].as_lower
					j := j - 1
				end
			end
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
		do
			Result := same_name (other)
		end
	
feature -- Output 

	out: STRING
		do
			Result := ""
			append_name (Result)
		end

	append_name (s: STRING)
		note
			action: "Append `out' to `s'."
		do
			if attached fast_name as fn then
				s.append (fn)
			end
		end

	pad_right (s: STRING; n: INTEGER)
		note
			action:
				"[
				 Append `out' to `s' and as many blanks as needed
				 to append totally at least `n' characters.
				 ]"
		require
			not_negative: n >= 0
		local
			i, l: INTEGER
		do
			l := s.count
			append_name (s)
			from
				i := n - (s.count - l)
			until i <= 0 loop
				s.extend (' ')
				i := i - 1
			end
		end

	pad_left (s: STRING; n: INTEGER)
		note
			action:
				"[
				 Append `out' to `s' and insert before that
				 as many blanks as needed to append totally
				 at least `n' characters.
				 ]"
		require
			not_negative: n >= 0
		local
			i, l: INTEGER
		do
			l := s.count
			append_name (s)
			from
				i := n - (s.count - l)
			until i <= 0 loop
				s.insert_character (' ', l)
				i := i - 1
			end
		end

feature -- COMPARABLE

	same_name (other: IS_NAME): BOOLEAN
		note
			return: "Have `Current' and `other' the same name?"
		do
			Result := STRING_.same_string (other.fast_name, fast_name)
		end

	is_less alias "<" (other: like Current): BOOLEAN
		do
			if not same_name (other) then
				Result := is_name_less (other.fast_name)
			end
		end

	is_name_less (str: READABLE_STRING_8): BOOLEAN
		do
			Result := STRING_.three_way_comparison (str , fast_name) = 1
		end

feature -- HASHABLE 

	hash_code: INTEGER
		do
			if internal_hash_code = 0 then
				internal_hash_code := ($Current).to_integer_32 // Pointer_bytes
			end
			Result := internal_hash_code
		end

feature {IS_NAME} -- Implementation 

	fast_name: STRING_8
		deferred
		end

	no_name: READABLE_STRING_8
		note
			return: "Dummy name."
		once
			Result := ""
		end

feature {NONE} -- Implementation 

	internal_hash_code: INTEGER

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
