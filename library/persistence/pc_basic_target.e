note

	description:
		"[ 
		 Writing the persistence closure of one object 
		 (without type information) in binary format. 
		 ]"

class PC_BASIC_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			default_create,
			reset,
			must_expand_strings,
			next_ident,
			put_string,
			put_unicode,
			put_void_ident,
			put_next_ident,
			put_new_object,
			put_new_special,
			put_once,
			finish,
			copy,
			is_equal
		end

	TO_SPECIAL [NATURAL_8]
		undefine
			out
		redefine
			default_create,
			copy,
			is_equal
		end
	
create

	default_create

feature {} -- Initialization 

	default_create
		do
			make_filled_area (0, buffer_capacity)
			reset
			create buffer_pointer.make (0)
		end

feature -- Initialization 

	reset
		note
			action: "Clear counters and set `file' to `io.output'."
		do
			Precursor
			file := io.output
			medium := file
			buffer_count := 0
			flushed_count := 0
		end

feature -- Access 

	must_expand_strings: BOOLEAN = False

	has_capacities: BOOLEAN

	medium: IO_MEDIUM

	position: INTEGER
		do
			Result := flushed_count + buffer_count
		end
	
	byte_count: INTEGER
		do
			Result := position - start_position
		end
	
feature -- Status setting 

	set_file (m: detachable like medium)
		require
			is_open: m /= Void implies m.is_open_write
		do
			file := Void
			flushed_count := 0
			buffer_count := 0
			if m /= Void then
				medium := m
			else
				medium := io.output
			end
			if attached {like file} medium as f then
				file := f
				if not attached {CONSOLE} f then
					flushed_count := f.position
				end
			end
			start_position := position
		ensure
			when_not_void: m /= Void implies medium = m
		end

	set_options (opts: INTEGER)
		do
			has_capacities := (opts & Capacity_flag) = Capacity_flag
		ensure
			has_capacities_set: has_capacities = opts & Capacity_flag = Capacity_flag
		end
	
feature -- Duplication and Compatison

	copy (other: like Current)
		do
			Precursor {PC_ABSTRACT_TARGET} (other)
			Precursor {TO_SPECIAL} (other)
		end
	
	is_equal (other: like Current): BOOLEAN
		do
			Result := Precursor {PC_ABSTRACT_TARGET} (other)
				and Precursor {TO_SPECIAL} (other)
		end
	
feature {PC_DRIVER} -- Pre and post handling of data 

	finish (top: PC_TYPED_IDENT [NATURAL])
		do
			put_known_ident (top.ident, Void)
			if file /= Void then
				buffer_flush
			end
		end

feature {PC_DRIVER} -- Forward  data 

	put_next_ident (id: NATURAL)
		do
			write_uint (id)
		end

	put_new_object (t: IS_TYPE)
		do
			next_ident
			put_type_ident (t.ident)
		end

	put_new_special (t: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			next_ident
			put_type_ident (t.ident)
			write_uint (n)
			if has_capacities then
				write_uint (cap)
			end
		end

	put_once (cls: detachable IS_CLASS_TEXT; nm: STRING; id: NATURAL)
		do
			last_ident := id
			if attached cls as c then
				write_int (c.ident)
				write_str (nm)
			else
				write_int (0)
			end
		end

feature {} -- Type components 

	put_no_once
		do
			write_str (Void)
		end

feature {PC_HEADER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
			if b then
				write_byte (1)
			else
				write_byte (0)
			end
		end

	put_character (c: CHARACTER)
		do
			write_byte (c.code.to_natural_8)
		end

	put_character_32 (c: CHARACTER_32)
		do
			write_int (c.code)
		end

	put_integer (i: INTEGER_32)
		do
			write_int (i)
		end

	put_natural (n: NATURAL_32)
		do
			write_uint (n)
		end

	put_integer_64 (i: INTEGER_64)
		do
			write_int64 (i)
		end

	put_natural_64 (n: NATURAL_64)
		do
			write_uint64 (n)
		end

	put_real (r: REAL_32)
		local
			exp: INTEGER_32
			n: NATURAL_32
		do
			n := c_32_int (r)
			exp := ((n |>> 23) & 0xff).to_integer_32 - 127
			put_integer (exp)
			n := n |<< 9
				-- >> 
			write_mantissa (n, r < 0)
		end

	put_double (d: REAL_64)
		local
			exp: INTEGER_32
			n: NATURAL_64
		do
			n := c_64_int (d)
			exp := ((n |>> 52) & 0x7ff).to_integer_32 - 1023
			put_integer (exp)
			n := n |<< 12
				-- >> 
			write_mantissa (n, d < 0)
		end

	put_pointer (p: POINTER)
		do
		end

	put_string (s: STRING)
		do
			write_str (s)
		end

	put_unicode (u: STRING_32)
		do
			write_str (u.to_string_8)
		end

	put_known_ident (id: NATURAL; t: IS_TYPE)
		do
			write_uint (id)
		end

	put_void_ident (stat: detachable IS_TYPE)
		do
			write_uint (0)
		end

feature {PC_BASE} -- Writing of header information 

	write_header (src: IS_SYSTEM)
		do
			if attached {FILE} medium as f then
				flushed_count := f.position
			end
		end

feature {} -- Implementation 

	write_int (i: INTEGER_32)
		note
			action: "Write `i' to `medium'."
		require
			is_open: medium.is_open_write
		local
			k: INTEGER_32
			b: NATURAL_8
			neg: BOOLEAN
		do
			neg := i < 0
			if neg then
					-- apply one's complement 
				k := -(i + 1)
			else
				k := i
			end
			from
					-- get 7 lowest bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			until k = 0 loop
					-- put continuation bit 
				b := b + 0x80
				write_byte (b)
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			if b >= 0x40 then
				b := b + 0x80
				write_byte (b)
				b := 0
			end
			if neg then
				b := b + 0x40
			end
			write_byte (b)
		end

	write_uint (n: NATURAL_32)
		note
			action: "Write `n' to `medium'."
		require
			is_open: medium.is_open_write
		local
			k: NATURAL_64
			b: NATURAL_8
		do
			k := n
				-- get 7 lowest bits 
			b := (k \\ 0x80).to_natural_8
				-- shift 7 bits to the right 
			k := k // 0x80
			from
			until k = 0 loop
					-- put continuation bit 
				b := b + 0x80
				write_byte (b)
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			write_byte (b)
		end

	write_int64 (i: INTEGER_64)
		note
			action: "Write `i' to `medium'."
		require
			is_open: medium.is_open_write
		local
			k: INTEGER_64
			b: NATURAL_8
			neg: BOOLEAN
		do
			neg := i < 0
			if neg then
					-- apply one's complement 
				k := -(i + 1)
			else
				k := i
			end
			from
					-- get 7 lowest bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			until k = 0 loop
					-- put continuation bit 
				b := b + 0x80
				write_byte (b)
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			if b >= 0x40 then
				b := b + 0x80
				write_byte (b)
				b := 0
			end
			if neg then
				b := b + 0x40
			end
			write_byte (b)
		end

	write_uint64 (n: NATURAL_64)
		note
			action: "Write `n' to `medium'."
		require
			is_open: medium.is_open_write
		local
			k: NATURAL_64
			b: NATURAL_8
		do
			k := n
				-- get 7 lowest bits 
			b := (k \\ 0x80).to_natural_8
				-- shift 7 bits to the right 
			k := k // 0x80
			from
			until k = 0 loop
					-- put continuation bit 
				b := b + 0x80
				write_byte (b)
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			write_byte (b)
		end

	write_mantissa (m: NATURAL_64; neg: BOOLEAN)
		note
			action: "Write left aligned unsigned mantissa `m' to `medium'."
			neg: "fraction is negative"
		local
			n: NATURAL_64
			b: NATURAL_8
		do
			n := m
			b := (n |>> 58).to_natural_8
			if neg then
				b := b | 0x40
			end
			n := n |<< 6
				-- >> 
			if n /= 0 then
				b := b | 0x80
			end
			write_byte (b)
			from
			until n = 0 loop
				b := (n |>> 57).to_natural_8
				n := n |<< 7
					-- >> 
				if n /= 0 then
					b := b | 0x80
				end
				write_byte (b)
			end
		end

	write_str (str: detachable STRING)
		note
			action: "Write `str' to `medium'."
		require
			is_open: medium.is_open_write
		local
			a: SPECIAL[CHARACTER]
			n: INTEGER
		do
			if attached str as s then
				n := s.count
				write_int (n)
				a := s.area
				buffer_add($a, n)
			else
				write_int (0)
			end
		end

	write_byte (i: NATURAL_8)
		note
			action: "Write `i' to `medium'."
		require
			is_open: medium.is_open_write
		do
			if file /= Void then
				if buffer_count >= buffer_capacity then
					buffer_flush
				end
				area [buffer_count] := i
				buffer_count := buffer_count + 1
			else
				medium.put_natural_8 (i)
			end
		end

feature {} -- Implementation 

	file: detachable FILE

	start_position: INTEGER

	buffer_count: INTEGER

	flushed_count: INTEGER

	buffer_capacity: INTEGER = 4096

	buffer_pointer: MANAGED_POINTER
	
	buffer_add (p: POINTER; n: INTEGER)
		require
			medium_is_file: attached file
		local
			k, l, m: INTEGER
		do
			from
				k := n
			until k <= 0 loop
				m := k.min (buffer_capacity - buffer_count)
				c_copy ($area + buffer_count, p + l, m)
				buffer_count := buffer_count + m
				if buffer_count = buffer_capacity then
					buffer_flush
				end
				l := l + m
				k := k - m
			end
		end

	buffer_flush
		do
			buffer_pointer.set_from_pointer ($area, buffer_count)
			file.put_managed_pointer (buffer_pointer, 0, buffer_count)
			file.flush
			flushed_count := flushed_count + buffer_count
			buffer_count := 0
		ensure
			buffer_cleared: buffer_count = 0
		end
	
	next_ident
		do
			Precursor
			write_uint (last_ident)
		end

	put_type_ident (id: INTEGER)
		note
			action: "Put `id' to the file."
		do
			write_int (id)
		end

feature {} -- External implementation 

	c_32_int (r: REAL_32): NATURAL_32
		external
			"C inline"
		alias
			"((union { EIF_REAL_32 f;  EIF_INTEGER_32 i;}*)&$r)->i"
		end

	c_64_int (d: REAL_64): NATURAL_64
		external
			"C inline"
		alias
			"((union { EIF_REAL_64 f;  EIF_INTEGER_64 i;}*)&$d)->i"
		end

	c_copy (dest, src: POINTER; n: INTEGER)
		external
			"C inline"
		alias
			"memcpy($dest,$src,$n)"
		end
	
invariant

	when_file: attached file as f implies f = medium
	area_count: area.count = buffer_capacity

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
