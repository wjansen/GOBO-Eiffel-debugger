note

	description:
		"[ 
		 Scanning the persistence closure from a file. 
		 The information is taken form the current system.
		 ]"

class PC_BASIC_SOURCE

inherit

	PC_SOURCE [NATURAL]
		redefine
			must_expand_strings,
			reset,
			read_once
		end

	IS_BASE
		undefine
			default_create,
			copy, is_equal, out
		end 
	
create

	make

feature -- Initialization

	make (flags: INTEGER)
		do
			system := runtime_system
			make_source
			reset
			must_expand_strings := False
			can_expand_strings := False
			has_consecutive_indices := flags & Non_consecutive_flag = 0 
			has_position_indices := flags & File_position_flag /= 0 
			has_capacities := flags & Capacity_flag /= 0 
		end
	
	reset
		do
			Precursor
			max_ident := 0
			position := 0
			start_position := 0
			last_str := ""
		end

feature -- Access

	has_position_indices: BOOLEAN

	has_consecutive_indices: BOOLEAN

	has_capacities: BOOLEAN
	
	void_ident: NATURAL = 0

	top_ident: NATURAL

	system: IS_SYSTEM

	medium: IO_MEDIUM

	file: detachable FILE
	
	has_integer_indices: BOOLEAN = True

	can_expand_strings: BOOLEAN

	must_expand_strings: BOOLEAN

	is_serial: BOOLEAN
		do
			Result := True
		end
	
	byte_count: INTEGER
		do
			Result := position - start_position
		end

feature -- Status setting
	
	set_version (major, minor: INTEGER)
		do
		end
	
	set_file (m: like medium)
		do
			medium := m
			if attached {FILE} m as f and then not attached {CONSOLE} f then
				file := f
				position := f.position
			else
				position := 0
			end
			start_position := position
		end

	set_options (opts: INTEGER)
		do
			has_capacities := (opts & Capacity_flag) = Capacity_flag
		ensure
			has_capacities_set: has_capacities = opts & Capacity_flag = Capacity_flag
		end
	
feature {PC_BASE} -- Reading header information

	read_header
		do
			if attached {FILE} medium as f then
				position := f.position
			end
		end

feature {PC_BASE} -- Reading structure definitions
	
	set_ident (id: like last_ident)
		do
			last_ident := id
		end
	
	read_next_ident
		do
			read_uint
			last_ident := last_uint
		end

	read_field_ident
		do
			read_uint
			last_ident := last_uint
		end
	
	read_once (id: NATURAL)
		local
			cid: INTEGER
		do
			last_class := Void
			read_int
			cid := last_int.to_integer
			if cid > 0 then
				last_class := system.class_at (cid)
				read_str
				last_string := last_str
			end
		end

feature {PC_BASE} -- Reading object definitions 

	read_description
		do
			read_int
			read_type (last_int)
			if attached last_dynamic_type as t and then t.is_special then
				read_uint
				last_count := last_uint
				if has_capacities then
					read_uint
					last_capacity := last_uint
				else
					last_capacity := last_count
				end
			else
				last_count := 0
				last_capacity := 0
			end			
		end
	
	pre_special (s: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		local
			it: IS_TYPE
		do
			it := s.item_type
			inspect it.ident
			when Boolean_ident then
				read_booleans (n)
			when Character_ident then
				read_characters (n)
			when Char32_ident then
				read_characters_32 (n)
			when Int8_ident then
				read_integers_8 (n)
			when Int16_ident then
				read_integers_16 (n)
			when Integer_ident then
				read_integers (n)
			when Int64_ident then
				read_integers_64 (n)
			when Nat8_ident then
				read_naturals_8 (n)
			when Nat16_ident then
				read_naturals_16 (n)
			when Nat32_ident then
				read_naturals (n)
			when Nat64_ident then
				read_naturals_64 (n)
			when Real32_ident then
				read_reals (n)
			when Real64_ident then
				read_doubles (n)
			when Pointer_ident then
				read_pointers (n)
			else
			end
		end

feature {PC_BASE} -- Reading elementary data

	read_boolean
		do
			read_byte
			last_boolean := last_byte /= 0
		end

	read_character
		do
			read_byte
			last_character := last_byte.to_character_8
		end

	read_character_32
		do
			read_int
			last_character_32 := last_int.to_character_32
		end

	read_integer_8
		do
			read_int
			last_integer := last_int
		end

	read_integer_16
		do
			read_int
			last_integer := last_int
		end

	read_integer
		do
			read_int
			last_integer := last_int
		end

	read_integer_64
		do
			read_int64
			last_integer_64 := last_int64
		end

	read_natural_8
		do
			read_uint
			last_natural := last_uint
		end

	read_natural_16
		do
			read_uint
			last_natural := last_uint
		end

	read_natural
		do
			read_uint
			last_natural := last_uint
		end

	read_natural_64
		do
			read_uint64
			last_natural_64 := last_uint64
		end

	read_real
		local
			exp, n: NATURAL_32
			k: INTEGER
		do
			read_int
			exp := (last_int + 127).to_natural_32
			read_mantissa
			n := last_natural_64.to_natural_32
			k := 23 - last_int.to_integer
			if k > 0 then
				n := n |<< k
					-- >>
			elseif k < 0 then
				n := n |>> -k
					-- >>
			end
			n := n | (exp |<< 23)
				-- >>
			last_real := c_32_float (n)
			if last_boolean then
				last_real := -last_real
			end
		end

	read_double
		local
			exp, n: NATURAL_64
			k: INTEGER
		do
			read_int
			exp := (last_int + 1023).to_natural_64
			read_mantissa
			n := last_natural_64
			k := 52 - last_int
			if k > 0 then
				n := n |<< k
					-- >>
			elseif k < 0 then
				n := n |>> -k
					-- >>
			end
			n := n | (exp |<< 52)
				-- >>
			last_double := c_64_float (n)
			if last_boolean then
				last_double := -last_double
			end
		end

	read_pointer
		do
		end

	read_string
		do
			read_str
			last_string := last_str
		end

	read_unicode
		do
			read_str
			last_unicode := last_str
		end

feature {PC_DRIVER} -- Object location
	
	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: NATURAL)
		do
		end

feature {NONE} -- Implementation

	start_position: INTEGER

	last_int: INTEGER_32

	last_uint: NATURAL_32

	last_int64: INTEGER_64

	last_uint64: NATURAL_64

	last_str: STRING

	last_byte: NATURAL_8

	read_int
		note
			action: "Read a signed integer from `medium' into `last_int'."
		require
			is_open: medium.is_open_read
		local
			offset: INTEGER
			b: INTEGER_32
			neg, ready: BOOLEAN
		do
			from
				last_int := 0
			until ready loop
				read_byte
				b := last_byte
				ready := b < 0x80
				if ready then
					neg := b >= 0x40
					if neg then
						b := b - 0x40
					end
				else
					-- remove continuation bit
					b := b - 0x80
				end
				-- shift to the left
				b := b |<< offset
				-- >>
				-- update shift distance
				offset := offset + 7
				-- put into result
				last_int := last_int + b
			end
			if neg then
				-- apply one's complement
				last_int := -last_int - 1
			end
		end

	read_uint
		note
			action: "Read an unsigned integer from `medium' into `last_uint'."
		local
			offset: INTEGER
			b: NATURAL_32
			ready: BOOLEAN
		do
			from
				last_uint := 0
			until ready loop
				read_byte
				b := last_byte
				ready := b < 0x80
				if not ready then
					-- remove continuation bit
					b := b - 0x80
				end
				-- shift to the left
				b := b |<< offset
				-- >>
				-- update shift distance
				offset := offset + 7
				-- put into result
				last_uint := last_uint + b
			end
		end

	read_int64
		note
			action: "Read a signed integer from `medium' into `last_int64'."
		local
			offset: INTEGER
			b: INTEGER_64
			neg, ready: BOOLEAN
		do
			from
				last_int64 := 0
			until ready loop
				read_byte
				b := last_byte
				ready := b < 0x80
				if ready then
					neg := b >= 0x40
					if neg then
						b := b - 0x40
					end
				else
						-- remove continuation bit
					b := b - 0x80
				end
					-- shift to the left
				b := b |<< offset
					-- >>
					-- update shift distance
				offset := offset + 7
					-- put into result
				last_int64 := last_int64 + b
			end
			if neg then
					-- apply one's complement
				last_int64 := -last_int64 - 1
			end
		end

	read_uint64
		note
			action: "Read an unsigned integer from `medium' into `last_uint64'."
		local
			offset: INTEGER
			b: NATURAL_64
			ready: BOOLEAN
		do
			from
				last_uint64 := 0
			until ready loop
				read_byte
				b := last_byte
				ready := b < 0x80
				if not ready then
						-- remove continuation bit
					b := b - 0x80
				end
					-- shift to the left
				b := b |<< offset
					-- >>
					-- update shift distance
				offset := offset + 7
					-- put into result
				last_uint64 := last_uint64 + b
			end
		end

	read_mantissa
		local
			m: NATURAL_64
			b: NATURAL_8
			k: INTEGER
			cont: BOOLEAN
		do
			read_byte
			b := last_byte
			last_boolean := (b & 0x40) /= 0
			cont := (b & 0x80) /= 0
			m := b & 0x3f
			k := 6
			from
			until not cont loop
				m := m |<< 7
					-- >>
				read_byte
				b := last_byte
				cont := (b & 0x80) /= 0
				m := m | (b & 0x7f)
					-- >>
				k := k + 7
			end
			last_natural_64 := m
			last_int := k
		end

	read_str
		note
			action:
			"[
			 Read a string from `medium' into the newly
			 created `last_str'.
			 ]"
		do
			read_int
			read_chars (last_int)
		end

	read_chars (n: INTEGER)
		note
			action:
			"[
			 Read `n' characters from `medium' into the newly
			 created `last_str'.
			 ]"
		local
			i: INTEGER
		do
			create last_str.make (n)
			from
			until i = n loop
				read_byte
				last_str.extend (last_byte.to_character_8)
				i := i + 1
			end
		end

	read_byte
		note
			action: "Read a byte from `medium' into `last_byte'."
		do
			medium.read_natural_8
			if medium.bytes_read = 0 then
				last_byte := 0
			else
				last_byte := medium.last_natural_8
				position := position + 1
			end
		end

	position: INTEGER

	read_type (tid: INTEGER)
		do
			last_dynamic_type := system.type_at (tid)
		end

	read_booleans (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > booleans.count then
				booleans := booleans.aliased_resized_area_with_default (False, k)
			end
			from
			until i = k loop
				read_boolean
				booleans [i] := last_boolean
				i := i + 1
			end
		end

	read_characters (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > characters.count then
				characters := characters.aliased_resized_area_with_default ('%U', k)
			end
			from
			until i = k loop
				read_character
				characters [i] := last_character
				i := i + 1
			end
		end

	read_characters_32 (n: NATURAL)
		local
			i,k: INTEGER
		do
			k := n.to_integer_32
			if k > characters_32.count then
				characters_32 := characters_32.aliased_resized_area_with_default ('%U', k)
			end
			from
			until i = k loop
				read_character_32
				characters_32 [i] := last_character_32
				i := i + 1
			end
		end

	read_integers_8 (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > integers_8.count then
				integers_8 := integers_8.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_integer_8
				integers_8 [i] := last_integer.to_integer_8
				i := i + 1
			end
		end

	read_integers_16 (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > integers_16.count then
				integers_16 := integers_16.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_integer_16
				integers_16 [i] := last_integer.to_integer_16
				i := i + 1
			end
		end

	read_integers (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > integers.count then
				integers := integers.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_integer
				integers [i] := last_integer
				i := i + 1
			end
		end

	read_integers_64 (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > integers_64.count then
				integers_64 := integers_64.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_integer_64
				integers_64 [i] := last_integer_64
				i := i + 1
			end
		end

	read_naturals_8 (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > naturals_8.count then
				naturals_8 := naturals_8.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_natural_8
				naturals_8 [i] := last_natural.to_natural_8
				i := i + 1
			end
		end

	read_naturals_16 (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := k.to_integer_32
			if k > naturals_16.count then
				naturals_16 := naturals_16.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_natural_16
				naturals_16 [i] := last_natural.to_natural_16
				i := i + 1
			end
		end

	read_naturals (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > naturals.count then
				naturals := naturals.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_natural
				naturals [i] := last_natural
				i := i + 1
			end
		end

	read_naturals_64 (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > naturals_64.count then
				naturals_64 := naturals_64.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_natural_64
				naturals_64 [i] := last_natural_64
				i := i + 1
			end
		end

	read_reals (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > reals.count then
				reals := reals.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_real
				reals [i] := last_real
				i := i + 1
			end
		end

	read_doubles (n: NATURAL)
		local
			i, k: INTEGER
		do
			k := n.to_integer_32
			if k > doubles.count then
				doubles := doubles.aliased_resized_area_with_default (0, k)
			end
			from
			until i = k loop
				read_double
				doubles [i] := last_double
				i := i + 1
			end
		end

	read_pointers (n: NATURAL)
		local
			null: POINTER
			k: INTEGER
		do
			k := n.to_integer_32
			if k > pointers.count then
				pointers := pointers.aliased_resized_area_with_default (null, k)
			end
		end

feature {NONE} -- Implementation

	scoop: BOOLEAN

	max_ident: NATURAL

	process_ident (id: like last_ident)
		do
		end

feature {NONE} -- External implementation

	c_32_float (n: NATURAL_32): REAL_32
		external
			"C inline"
		alias
			"((union { EIF_REAL_32 f;  EIF_INTEGER_32 i;}*)&$n)->f"
		end

	c_64_float (n: NATURAL_64): REAL_64
		external
			"C inline"
		alias
			"((union { EIF_REAL_64 f;  EIF_INTEGER_64 i;}*)&$n)->f"
		end

invariant

	when_not_serial: not serial implies file /= Void
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
