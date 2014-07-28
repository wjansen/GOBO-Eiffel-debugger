note

	description: 
		"[
		 Objects for accessing elementary components in memory 
		 and grouping marks in the course of deep object traversal. 
		 ]"
		 
class PC_MEMORY_SOURCE

inherit

	PC_SOURCE [ANY]
		undefine
			set_field
		redefine
			field, 
			reset,
			pre_object,
			post_object,
			pre_agent,
			post_agent, 
			post_special,
			read_once
		end

	PC_MEMORY_ACCESS
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			field, 
			make_memory,
			object
		end

create

	make
	
feature {NONE} -- Initialization 

	make (s: like system; ord: INTEGER)
		do
			make_memory (s)
			make_source (ord)
		end

	make_memory (s: like system)
		do
			Precursor (s)
				-- Guru section: set `last_ident' to a potentially non-void reference 
			last_string := ""
			last_unicode := last_string
			last_ident := last_string
		end

feature -- Initialization 

	reset
		do
			Precursor
			make_memory (system)
			contexts.reset
			field_type := Void
			last_dynamic_type := Void
			top_object := Void
		end

feature -- Access 

	is_serial: BOOLEAN = False

	has_integer_indices: BOOLEAN = False

	has_consecutive_indices: BOOLEAN = False

	has_position_indices: BOOLEAN = False

	can_expand_strings: BOOLEAN = True

	must_expand_strings: BOOLEAN = False

	actionable: BOOLEAN = False
			-- Do PC_ACTIONABLE objects need special treatment? 

	mode: INTEGER
			-- Traversal mode, one of `Lifo_flag', `Fifo_flag'. 

	void_ident: detachable ANY

	top_object: detachable ANY
			-- Root of persistence closure 

	field: detachable IS_ENTITY [INTEGER]

feature -- Status setting 

	set_mode (m: INTEGER)
		note
			action: "Set traversal mode."
			m: "new mode"
		require
			lifo_or_fifo: m & Flat_flag = Lifo_flag or m & Flat_flag = Fifo_flag
		local
			flat: INTEGER
		do
			flat := m & Flat_flag
			if mode /= flat then
			end
			mode := flat
		end

	set_actionable (yes_no: BOOLEAN)
		note
			action: "Not applicable."
		do
		end

	set_top_object (obj: detachable ANY)
		do
			top_object := obj
			if attached obj as o then
				-- Add typset of `obj' to typeset of `top_array.item': 
				top_array.extend (o)
				top_array.wipe_out
			end
		ensure
			top_object_set: top_object = obj
		end

feature {PC_DRIVER} -- Reading structure definitions 

	read_next_ident
		local
			id: like last_ident
		do
			contexts.next_ident
			id := contexts.last_ident
			if id = void_ident then
				id := top_object
			end
			process_ident (id)
		end

	read_field_ident
		do
			process_ident (actual_object)
		end

	read_context (id: like void_ident)
		do
			process_ident (id)
		end

feature {PC_DRIVER} -- Reading structure definitions 

	read_once (id: ANY)
		do
			last_once := Void
			if attached {IS_ONCE_VALUE} system.once_by_address (as_pointer(id), False) as value then
				if value.call.is_initialized then
					last_once := value.call
				end
			end
		end

feature {PC_DRIVER} -- Reading object definitions 

	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: ANY)
		do
			if as_ref then
				push_offset (t, id)
			else
				push_expanded_offset
			end
		end

	post_object (t: IS_TYPE; id: ANY)
		do
			pop_offset
		end

	pre_agent (a: IS_AGENT_TYPE; id: ANY)
		local
			obj: ANY
		do
			obj := system.closed_operands (id, a)
			push_offset (a, obj)
		end

	post_agent (a: IS_AGENT_TYPE; id: ANY)
		do
			pop_offset
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: ANY)
		do
			object_is_special := True
			push_offset (s, id)
			if s.item_type.is_subobject then
				inspect s.item_type.ident
					when Boolean_ident then
					if attached {like booleans} id as sp then
						booleans := sp
					end
					when Char8_ident then
					if attached {like characters} id as sp then
						characters := sp
					end
					when Char32_ident then
					if attached {like characters_32} id as sp then
						characters_32 := sp
					end
					when Int8_ident then
					if attached {like integers_8} id as sp then
						integers_8 := sp
					end
					when Int16_ident then
					if attached {like integers_16} id as sp then
						integers_16 := sp
					end
					when Int32_ident then
					if attached {like integers} id as sp then
						integers := sp
					end
					when Int64_ident then
					if attached {like integers_64} id as sp then
						integers_64 := sp
					end
					when Nat8_ident then
					if attached {like naturals_8} id as sp then
						naturals_8 := sp
					end
					when Nat16_ident then
					if attached {like naturals_16} id as sp then
						naturals_16 := sp
					end
					when Nat32_ident then
					if attached {like naturals} id as sp then
						naturals := sp
					end
					when Nat64_ident then
					if attached {like naturals_64} id as sp then
						naturals_64 := sp
					end
					when Real32_ident then
					if attached {like reals} id as sp then
						reals := sp
					end
					when Real64_ident then
					if attached {like doubles} id as sp then
						doubles := sp
					end
					when Pointer_ident then
					if attached {like pointers} id as sp then
						pointers := sp
					end
				else
				end
			else
				if attached {like references} id as sp then
					references := sp
				end
			end
		end

	post_special (t: IS_SPECIAL_TYPE; id: ANY)
		do
			pop_offset
			object_is_special := False
		end

feature {PC_DRIVER} -- Reading elementary data 

	read_boolean
		do
			if object_is_special then
				last_boolean := booleans [offset]
			else
				last_boolean := boolean_field (offset, object)
			end
		end

	read_character
		do
			if object_is_special then
				last_character := characters [offset]
			else
				last_character := character_8_field (offset, object)
			end
		end

	read_character_32
		do
			if object_is_special then
				last_character_32 := characters_32 [offset]
			else
				last_character_32 := integer_32_field (offset, object).to_character_32
			end
		end

	read_integer_8
		do
			if object_is_special then
				last_integer := integers_8 [offset]
			else
				last_integer := integer_8_field (offset, object)
			end
		end

	read_integer_16
		do
			if object_is_special then
				last_integer := integers_16 [offset]
			else
				last_integer := integer_16_field (offset, object)
			end
		end

	read_integer
		do
			if object_is_special then
				last_integer := integers [offset]
			else
				last_integer := integer_32_field (offset, object)
			end
		end

	read_integer_64
		do
			if object_is_special then
				last_integer_64 := integers_64 [offset]
			else
				last_integer_64 := integer_64_field (offset, object)
			end
		end

	read_natural_8
		do
			if object_is_special then
				last_natural := naturals_8 [offset]
			else
				last_natural := natural_8_field (offset, object)
			end
		end

	read_natural_16
		do
			if object_is_special then
				last_natural := naturals_16 [offset]
			else
				last_natural := natural_16_field (offset, object)
			end
		end

	read_natural
		do
			if object_is_special then
				last_natural := naturals [offset]
			else
				last_natural := natural_32_field (offset, object)
			end
		end

	read_natural_64
		do
			if object_is_special then
				last_natural_64 := naturals_64 [offset]
			else
				last_natural_64 := natural_64_field (offset, object)
			end
		end

	read_real
		do
			if object_is_special then
				last_real := reals [offset]
			else
				last_real := real_32_field (offset, object)
			end
		end

	read_double
		do
			if object_is_special then
				last_double := doubles [offset]
			else
				last_double := real_64_field (offset, object)
			end
		end

	read_pointer
		do
			if object_is_special then
				last_pointer := pointers [offset]
			else
				last_pointer := pointer_field (offset, object)
			end
		end

	read_string
		do
			if attached {STRING} as_any (address) as s then
				last_string.copy (s)
			end
		end

	read_unicode
		do
			if attached {STRING_32} as_any (address) as u then
				last_unicode.copy (u)
			end
		end

	read_references (cap: NATURAL)
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				references [i] := as_any (address)
				address := address + field_increment
				i := i + 1
			end
		end

feature {NONE} -- Implementation 

	object: ANY

	actual_object: detachable ANY
		note
			return: "Object at field in `object' according to the `offset'."
		do
			if object_is_special then
				if field_type.is_subobject then
					inspect field_type.ident
					when Boolean_ident then
						Result := booleans [offset]
					when Char8_ident then
						Result := characters [offset]
					when Char32_ident then
						Result := characters_32 [offset]
					when Int8_ident then
						Result := integers_8 [offset]
					when Int16_ident then
						Result := integers_16 [offset]
					when Int32_ident then
						Result := integers [offset]
					when Int64_ident then
						Result := integers_64 [offset]
					when Nat8_ident then
						Result := naturals_8 [offset]
					when Nat16_ident then
						Result := naturals_16 [offset]
					when Nat32_ident then
						Result := naturals [offset]
					when Nat64_ident then
						Result := naturals_64 [offset]
					when Real32_ident then
						Result := reals [offset]
					when Real64_ident then
						Result := doubles [offset]
					when Pointer_ident then
						Result := pointers [offset]
					else
					end
				else
					Result := references [offset]
				end
			else
				Result := int_field (offset, object)
			end
		end
	
	process_ident (id: like last_ident)
		do
			last_ident := void_ident
			last_dynamic_type := Void
			last_capacity := 0
			if id /= void_ident and then attached id as si then
				if attached system.type_of_any (si, field_type) as t then
					last_ident := si
					last_dynamic_type := t
					if t.is_special and then attached {IS_SPECIAL_TYPE} t as s then
						last_capacity := system.special_capacity (id, s)
					end
					if t.is_string then
						if attached {STRING} id as s then
							last_string.copy (s)
						end
					elseif t.is_unicode then
						if attached {STRING_32} id as u then
							last_unicode.copy (u)
						end
					end
				end
			end
		end

	read_booleans (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= booleans.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				booleans [i] := boolean_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_characters (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= characters.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				characters [i] := character_8_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_characters_32 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= characters_32.capacity
		local
			i, n: INTEGER
		do
			from
			until i = n loop
				characters_32 [i] := character_32_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_integers_8 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= integers_8.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				integers [i] := integer_8_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_integers_16 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= integers_16.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				integers [i] := integer_16_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_integers (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= integers.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				integers [i] := integer_32_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_integers_64 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= integers_64.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				integers_64 [i] := integer_64_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_naturals_8 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= naturals_8.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				naturals [i] := natural_8_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_naturals_16 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= naturals_16.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				naturals [i] := natural_16_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_naturals (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= naturals.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				naturals [i] := natural_32_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_naturals_64 (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= naturals_64.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				naturals_64 [i] := natural_64_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_reals (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= reals.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				reals [i] := real_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_doubles (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= doubles.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				doubles [i] := double_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_pointers (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= pointers.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				pointers [i] := pointer_field (i, object)
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_strings (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= strings.capacity
		local
			i,n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				if attached {STRING} as_any (address) as s then
					strings [i] := s
				else
					strings [i] := Void
				end
				offset := offset + field_increment
				i := i + 1
			end
		end

	read_unicodes (cap: NATURAL)
		require
			capacity_large_enough: cap.to_integer_32 <= unicodes.capacity
		local
			i, n: INTEGER
		do
			from
				n := cap.to_integer_32
			until i = n loop
				if attached {STRING_32} as_any (address) as u then
					unicodes [i] := u
				else
					unicodes [i] := Void
				end
				offset := offset + field_increment
				i := i + 1
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
