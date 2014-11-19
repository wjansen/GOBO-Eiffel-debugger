note

description:
	"[
	 Writing the persistence closure of an objects in SED format
	 of the ISE compiler.
	 ]"

class PC_ISE_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			can_expand_strings,
			must_expand_strings,
			pre_object,
			pre_special,
			finish
		end
	
	SED_MEDIUM_READER_WRITER
		rename
			make as make_sed,
			write_boolean as put_boolean,
			write_character_8 as put_character,
			write_character_32 as put_character_32,
			write_integer_64 as put_integer_64,
			write_natural_64 as put_natural_64,
			write_real_32 as put_real,
			write_real_64 as put_double,
			write_pointer as put_pointer
		undefine
			copy, is_equal, out
		redefine
			write_header
		end

	SED_UTILITIES
		undefine
			copy, is_equal, out
		end
	
create

	make

feature {NONE} -- Initialization

	make (m: like medium; src: like source; t: like types; c: like capacities)
		do
			source := src
			types := t
			capacities := c
			make_sed (m)
			write_header
		end

feature -- Access

	can_expand_strings: BOOLEAN = True
	
	must_expand_strings: BOOLEAN = False

	source: PC_TOOL_SOURCE

	version: NATURAL

feature -- Status setting

	set_version (v: like version)
		do
			version := v
		ensure
			version_set: version = v
		end
	
feature {PC_DRIVER} -- Pre and post handling of data

	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: detachable NATURAL)
		do
			write_compressed_natural_32 (id)
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		do
			write_compressed_natural_32 (id)
		end
	
	finish (top: NATURAL)
		do
			write_footer
			if attached {FILE} medium as f then
				f.flush
				f.close
			end
		end
	
feature {PC_DRIVER} -- Writing elementary data

	put_integer (i: INTEGER_32)
		do
			inspect field.type.ident
			when Int8_ident then
				write_integer_8 (i.to_integer_8)
			when Int16_ident then
				write_integer_16 (i.to_integer_16)
			else
				write_integer_32 (i)
			end
		end
	
	put_natural (n: NATURAL_32)
		do
			inspect field.type.ident
			when Nat8_ident then
				write_natural_8 (n.to_natural_8)
			when Nat16_ident then
				write_natural_16 (n.to_natural_16)
			else
				write_natural_32 (n)
			end
		end
	
	put_string (s: STRING_8)
		do
		end

	put_unicode (u: STRING_32)
		do
		end

	put_string0 (s: STRING)
		local
			i, n: INTEGER
		do
			if not source.can_expand_strings then
				next_ident
--				write_compressed_natural_32 (last_ident.to_natural_32)
				from
					n := s.count
					write_compressed_natural_32 (n.to_natural_32)
				until
					i = n
				loop
					put_character (s [i])
					i := i + 1
				end
			end
		end

	put_unicode0 (u: STRING_32)
		local
			i, n: INTEGER
		do
			if not source.can_expand_strings then
				next_ident
--				write_compressed_natural_32 (last_ident.to_natural_32)
				from
					n := u.count
					write_compressed_natural_32 (n.to_natural_32)
				until
					i = n
				loop
					put_character_32 (u [i])
					i := i + 1
				end
			end
		end

	put_known_ident (id: NATURAL)
		do
			if id /= void_ident then
				write_compressed_natural_32 (id)
			else
				write_compressed_natural_32 (0)
			end
		end

feature {NONE} -- Implementation

	file: FILE
	
	types: PC_LINEAR_TABLE [detachable IS_TYPE]

	capacities: PC_LINEAR_TABLE [NATURAL]

	write_header 
		local
			tt, tt_plus: IS_SET [IS_TYPE]
			t: IS_TYPE
			f: IS_FIELD
			i, j, m, n: INTEGER
		do
			write_compressed_natural_32 (types.count.to_natural_32)
			Precursor
			if version > 0 then
				write_compressed_natural_32 (version)
			end
			create tt.make (100, source.any_type)
			types.do_keys (agent add_to_table (tt, tt, ?))
			from
				i := 0
				n := tt.count
				write_compressed_natural_32 (n.to_natural_32)
			until i = n loop
				t := tt [i] 
				write_compressed_natural_32 (t.ident.to_natural_32)
				fine_type_name (t)
				write_string_8 (type_name)
				if version >= {SED_VERSIONS}.recoverable_version_6_6 then
					put_boolean (False)
				end
				i := i + 1
			end
			create tt_plus.make (100, source.any_type)
			types.do_keys (agent add_to_table (tt_plus, tt, ?))
			from
				i := 0
				n := tt_plus.count
				write_compressed_natural_32 (n.to_natural_32)
			until i = n loop
				t := tt_plus [i] 
				write_compressed_natural_32 (t.ident.to_natural_32)
				fine_type_name (t)
				write_string_8 (type_name)
				if version >= {SED_VERSIONS}.recoverable_version_6_6 then
					put_boolean (False)
				end
				i := i + 1
			end
			from
				i := 0
				n := tt.count
				write_compressed_natural_32 (n.to_natural_32)
			until i = n loop
				t := tt [i]
				write_compressed_natural_32 (t.ident.to_natural_32)
				from
					j := 0
					m := t.attribute_count
					write_compressed_natural_32 (m.to_natural_32)
				until j = m loop
					f := t.attribute_at (j)
					write_compressed_natural_32 (f.type.ident.to_natural_32)
					write_string_8 (f.fast_name)
					j := j + 1
				end
				i := i + 1
			end
			types.do_keys (agent write_object_type (?))
		end

	add_to_table (set, exclude: IS_SET [IS_TYPE]; i: NATURAL)
		do
			if attached types [i] as t and then not exclude.has (t) then
				set.add (t)
			end
		end

	write_object_type (i: NATURAL)
		do
			if attached types [i] as t then
				write_compressed_natural_32 (t.ident.to_natural_32)
				if t.is_special then
					write_natural_8 (is_special_flag)
					write_compressed_natural_32 (capacities [i.to_natural_32])
				elseif t.is_tuple then
					write_natural_8 (is_tuple_flag)
				else
					write_natural_8 (0)
				end
			end
		end

	type_name: STRING = ""
	
	fine_type_name (t: IS_TYPE)
		local
			i: INTEGER
		do
			type_name.wipe_out
			t.append_name (type_name)
			from
				i := 1
			until i > type_name.count loop
				inspect type_name [i]
				when ',' then
					i := i + 1
					type_name.insert_character (' ', i)
				when '[' then
					type_name.insert_character (' ', i)
					i := i + 1
				else
				end
				i := i + 1
			end
		end
	
end
