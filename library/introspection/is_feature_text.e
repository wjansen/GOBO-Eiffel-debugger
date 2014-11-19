note

	description: "Internal description of a feature text of a class."

class IS_FEATURE_TEXT

inherit

	IS_NAME
		redefine
			is_equal,
			is_less,
			hash_code
		end

create

	make

feature {NONE} -- Initialization 

	make (nm: READABLE_STRING_8; anm: detachable STRING_8; fl, l, c: INTEGER)
		note
			action: "Create a `IS_FEATURE_TEXT'."
		require
			valid_position: 0 <= l and 0 <= c
		do
			fast_name := nm
			alias_name := anm
			flags := fl
			if l < 0 then
				-- Make `renames' alive:
				renames := Current
			end
			first_pos := position_as_integer (l, c)
			last_pos := first_pos
		ensure
			name_set: fast_name.is_equal (nm)
			flags_set: flags = fl
			first_line_set: first_line = l
			last_line_set: first_line = l
			column_set: column = c
			definition_set: definition = Current
		end

feature -- Access 

	alias_name: detachable STRING_8

	tuple_labels: detachable IS_SEQUENCE [IS_FEATURE_TEXT]
			-- Tuple labels if the feature result is of a TUPLE type. 

	home: IS_CLASS_TEXT
			-- Class containing `Current'. 

	result_text: detachable like home
			-- Class of `Result' type (if any). 

	renames: detachable IS_FEATURE_TEXT
		-- Feature text in base class renamed by `Current'
	
	flags: INTEGER
	
	definition: like Current
			-- Class and feature where `Current' is defined. 
		do
			if renames /= Void then
				Result := renames
			else
				Result := Current
			end
		end
	
	has_line (l: INTEGER): BOOLEAN
		do
			Result := first_line <= l and then l <= last_line
		end

	has_position (l, c: INTEGER): BOOLEAN
		do
			Result := first_line = l and then column = c
		end

	first_line: INTEGER
		do
			Result := line_of_position (first_pos)
		end

	last_line: INTEGER
		do
			Result := line_of_position (last_pos)
		end

	column: INTEGER
		do
			Result := column_of_position (first_pos)
		end

	first_pos, last_pos: NATURAL

feature -- Status

	is_attribute: BOOLEAN
		do
			Result := flags & Routine_flag = 0
		ensure
			definition: Result = (flags & Routine_flag = 0)
		end
	
	is_routine: BOOLEAN
		do
			Result := flags & Routine_flag /= 0
		ensure
			definition: Result = (flags & Routine_flag /= 0)
		end

	is_constant: BOOLEAN
		do
			Result := flags & Once_flag /= 0
		ensure
			definition: Result = (flags & Once_flag /= 0)
		end
		
	is_variable: BOOLEAN
		do
			Result := flags & Once_flag = 0
		ensure
			definition: Result = (flags & Once_flag = 0)
		end
		
feature -- Status setting 

	set_name (nm: READABLE_STRING_8)
		do
			fast_name := nm.twin
		ensure
			name_set: has_name (nm)
		end

	set_tuple_labels (tl: like tuple_labels)
		do
			tuple_labels := tl
		ensure
			tuple_labels_set: tuple_labels = tl
		end

	set_home (h: like home)
		do
			home := h
		ensure
			home_set: home = h
		end

	set_result_text (r: like result_text)
		do
			result_text := r
		ensure
			result_text_set: result_text = r
		end

	set_bounds (first_l, first_c: INTEGER; last_l, last_c: INTEGER)
		require
			positive: frist_l > 0 and frist_c > 0 and last_l > 0 and last_c > 0
			last_below_first: last_l >= first_l
		do
			first_pos := position_as_integer (first_l, first_c)
			last_pos := position_as_integer (last_l, last_c)
		ensure
			first_line_set: first_line = first_l
			first_col_set: first_col = first_c
			last_line_set: last_line = last_l
			last_col_set: last_col = last_c
		end

feature -- Basic operation 

	position_as_integer (l, c: INTEGER): NATURAL
		do
			Result := (l * 256 + c).as_natural_32
				-- GEC specific 
		end

	line_of_position (p: NATURAL): INTEGER
		do
			Result := (p // 256).as_integer_32
				-- GEC specific 
		end

	column_of_position (p: NATURAL): INTEGER
		do
			Result := (p \\ 256).as_integer_32
				-- GEC specific 
		end

	append_label (item: READABLE_STRING_8; s: STRING)
		require
			labels_not_void: attached tuple_labels
		local
			tli: IS_FEATURE_TEXT
			i, k, l, c, c0: INTEGER
			failed: BOOLEAN
		do
			failed := not item.starts_with (once "item_")
			if not failed then
				c0 := ('0').code
				from
					k := 5
					l := item.count
				until failed or else k = l loop
					k := k + 1
					c := item [k].code - c0
					failed := c < 0 or else 9 < c
					i := 10 * i + c
				end
			end
			if not failed and then attached tuple_labels as tl and then i <= tl.count then
				tli := tl [i - 1]
				tli.append_name (s)
			else
				s.append (item)
			end
		end

feature -- Comparison 

	is_equal (other: like Current): BOOLEAN
		do
			Result := same_name (other)
		end

	is_less alias "<" (other: IS_FEATURE_TEXT): BOOLEAN
		do
			if not same_name (other) then
				Result := not other.is_name_less (fast_name)
			end
		end

feature -- HASHABLE

	hash_code: INTEGER
		do
			Result := internal_hash_code
			if Result = 0 then
				Result := fast_name.hash_code
				if Result < {INTEGER}.max_value / 2 then
					Result := Result |<< 1;
				end
				Result := Result.bit_xor (home.hash_code)
				internal_hash_code := Result
			end
		end
	
feature {IS_NAME} -- Implementation

	fast_name: STRING_8

invariant

	when_attribute: is_attribute implies routine_tex /= Void
	last_below_first: last_line >= first_line

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
