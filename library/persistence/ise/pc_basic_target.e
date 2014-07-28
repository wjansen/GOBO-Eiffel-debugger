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
			post_object,
			post_special,
			put_string,
			put_unicode,
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

feature {NONE} -- Initialization 

	default_create
		do
			make_filled_area (0, 4096)
			reset
		end

feature -- Initialization 

	reset
		note
			action: "Clear table of known objects."
		do
			Precursor
			set_file (Void)
			buffer_count := 0
			flushed_count := 0
		end

feature -- Access 

	must_expand_strings: BOOLEAN = False

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
			is_open: attached m as m_ implies m_.is_open_write
		do
			if attached m then
				medium := m
			else
				medium := io.output
			end
			if attached {like file} medium as f then
				file := f
				flushed_count := f.position
			else
				file := Void
				flushed_count := 0
			end
			buffer_count := 0
			start_position := position
		ensure
			when_not_void: attached m implies medium = m
		end

feature -- Duplication and Compatison

	copy (other: like Current)
		do
			Precursor {PC_ABSTRACT_TARGET} (other)
			Precursor {TO_SPECIAL} (other)
		end
	
	is_equal (other: like Current): BOOLEAN
		local
		do
			Result := Precursor {PC_ABSTRACT_TARGET} (other)
				and Precursor {TO_SPECIAL} (other)
		end
	
feature {PC_DRIVER} -- Pre and post handling of data 

	post_object (t: IS_TYPE; id: NATURAL)
		do
			if attached file as f then
				f.flush
			end
		end

	post_special (t: IS_SPECIAL_TYPE; id: NATURAL)
		do
			if attached file as f then
				f.flush
			end
		end

	finish (top: NATURAL)
		do
			if attached file then
				file.put_data ($area, buffer_count)
				file.flush
			end
			put_known_ident (top)
			top_ident := top
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

	put_new_special (t: IS_SPECIAL_TYPE; cap: NATURAL)
		do
			next_ident
			put_type_ident (t.ident)
			write_uint (cap)
		end

	put_once (oc: detachable IS_ONCE_CALL; t: detachable IS_TYPE; id: NATURAL)
		do
			last_ident := id
			if attached oc as o then
				write_int (o.home.ident)
				tmp_str.wipe_out
				o.append_name (tmp_str)
				write_str (tmp_str)
			else
				write_int (0)
			end
		end

feature {NONE} -- Type components 

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

	put_known_ident (id: NATURAL)
		do
			write_uint (id)
		end

feature {PC_BASE} -- Writing of header information 

	write_header (src: IS_SYSTEM)
		do
			if attached {FILE} medium as f then
				flushed_count := f.position
			end
		end

feature {PC_SERIALIZER} -- Implementation 

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
			check_buffer(5)
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
				area.put(b, buffer_count)
				buffer_count := buffer_count + 1
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			if b >= 0x40 then
				area.put(b + 0x80, buffer_count)
				buffer_count := buffer_count + 1
				b := 0
			end
			if neg then
				b := b + 0x40
			end
			area.put(b, buffer_count)
			buffer_count := buffer_count + 1
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
			check_buffer(5)
			k := n
				-- get 7 lowest bits 
			b := (k \\ 0x80).to_natural_8
				-- shift 7 bits to the right 
			k := k // 0x80
			from
			until k = 0 loop
					-- put continuation bit 
				b := b + 0x80
				area.put(b, buffer_count)
				buffer_count := buffer_count + 1
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			area.put(b, buffer_count)
			buffer_count := buffer_count + 1
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
			check_buffer(10)
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
				area.put(b, buffer_count)
				buffer_count := buffer_count + 1
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			if b >= 0x40 then
				area.put(b + 0x80, buffer_count)
				buffer_count := buffer_count + 1
				b := 0
			end
			if neg then
				b := b + 0x40
			end
			area.put(b, buffer_count)
			buffer_count := buffer_count + 1
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
			check_buffer(10)
			k := n
				-- get 7 lowest bits 
			b := (k \\ 0x80).to_natural_8
				-- shift 7 bits to the right 
			k := k // 0x80
			from
			until k = 0 loop
					-- put continuation bit 
				b := b + 0x80
				area.put(b, buffer_count)
				buffer_count := buffer_count + 1
					-- get next 7 bits 
				b := (k \\ 0x80).to_natural_8
					-- shift 7 bits to the right 
				k := k // 0x80
			end
			area.put(b, buffer_count)
			buffer_count := buffer_count + 1
		end

	write_mantissa (m: NATURAL_64; neg: BOOLEAN)
		note
			action: "Write left aligned unsigned mantissa `m' to `medium'."
			neg: "fraction is negative"
		local
			n: NATURAL_64
			b: NATURAL_8
		do
			check_buffer(10)
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
			area.put(b, buffer_count)
			buffer_count := buffer_count + 1
			from
			until n = 0 loop
				b := (n |>> 57).to_natural_8
				n := n |<< 7
					-- >> 
				if n /= 0 then
					b := b | 0x80
				end
				area.put(b, buffer_count)
				buffer_count := buffer_count + 1
			end
		end

	write_str (str: detachable STRING)
		note
			action: "Write `str' to `medium'."
		require
			is_open: medium.is_open_write
		local
			n: INTEGER
		do
			if attached str as s then
				n := s.count
				write_int (n)
				if attached file then
					file.put_data ($area, buffer_count)
					flushed_count := flushed_count + buffer_count
					buffer_count := 0
				end
				medium.put_string (s)
				flushed_count := flushed_count + n
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
			if attached file then
				check_buffer (1)
				area.put(i, buffer_count)
				buffer_count := buffer_count + 1
			else
				medium.put_natural_8 (i)
			end
		end

feature {NONE} -- Implementation 

	file: detachable RAW_FILE

	start_position: INTEGER

	buffer_count: INTEGER

	flushed_count: INTEGER
	
	check_buffer (n: INTEGER)
		require
			medium_is_file: attached file
		local
			m: INTEGER
		do
			m := area.count
			if buffer_count + n >= m then
				file.put_data ($area, buffer_count)
				file.flush
				flushed_count := flushed_count + buffer_count
				buffer_count := 0
				if n > m then
					make_filled_area (0, 2 * n)
				end
			end
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

feature {NONE} -- External implementation 

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

invariant

	when_file: attached file as f implies f = medium

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
