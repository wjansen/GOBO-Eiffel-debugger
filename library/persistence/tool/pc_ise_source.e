note

description:
	"[
	 Writing the persistence closure of an objects in SED format
	 of the ISE compiler.
	 ]"

class PC_ISE_SOURCE

inherit

	PC_MEDIUM_SOURCE 
		rename
			system as parser,
			make as make_medium
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			medium,
			parser,
			pre_object,
			post_object,
			set_field
		end
	
	SED_MEDIUM_READER_WRITER
		rename
			make as make_sed,
			read_boolean as read_bool,
			read_character_8 as read_char8,
			read_character_32 as read_char32,
			read_integer_8 as read_int_8,
			read_integer_16 as read_int_16,
			read_integer_32 as read_int_32,
			read_integer_64 as read_int_64,
			read_natural_8 as read_nat_8,
			read_natural_16 as read_nat_16,
			read_natural_32 as read_nat_32,
			read_natural_64 as read_nat_64,
			read_pointer as read_ptr
		redefine
			medium,
			read_header
		end

	SED_UTILITIES
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

	KL_COMPARATOR [STRING]
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			less_than
		end
	
create

	make

feature {NONE} -- Initialization

	make (m: like medium)
		do
			create type_names.make (200)
			create type_defs.make (200)
			create parser.make (type_defs)
			make_source (Deep_flag)
			make_sed (m)
			set_for_reading
			read_header
			if attached {FILE} medium as f then
				f.flush
			end
		end

feature -- Constants

	has_integer_indices: BOOLEAN = True
	
	can_expand_strings: BOOLEAN = True
	
	must_expand_strings: BOOLEAN = True

feature -- Access

	medium: IO_MEDIUM
	
	parser: PC_SED_PARSER
	
feature {PC_DRIVER} -- Reading structure definitions 

	read_next_ident
		do
			if on_top then
				if last_ident = void_ident then
					last_ident := read_compressed_natural_32
				else
					on_top := False
				end
			elseif last_ident = object_count then
				last_ident := void_ident 
			else
				if not fast then
					read_object (read_compressed_natural_32.to_integer_32)
					last_dynamic_type := last_object.t
					last_capacity := last_object.cap.to_natural_32
				end
				last_ident := read_compressed_natural_32
				last_object := objects.item (last_ident.to_integer_32)
				contexts.to_reread (last_ident, last_object.t, last_object.cap)
			end
		end

	read_field_ident
		do
			last_ident := read_compressed_natural_32
		end

	read_context (id: NATURAL)
		local
			obj: like last_object
		do
			if fast then
				obj := objects [id.to_integer_32]
				last_dynamic_type := obj.t
				last_capacity := obj.cap
			end
		end
	
feature {PC_DRIVER} -- Reading object definitions

	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: NATURAL)
		do
			Precursor (t, as_ref, id)
			in_tuple := t.is_tuple 
			in_agent := t.is_agent
		end

	post_object (t: IS_TYPE; id: NATURAL)
		do
			Precursor (t, id)
			in_tuple := False
			in_agent := False
		end	

feature {PC_DRIVER} -- Object location

	set_field (f: attached like field; in: NATURAL)
		local
			n8: NATURAL_8
		do
			Precursor (f, in)
			if in_tuple then
				n8 := read_nat_8
			end
		end
	
feature {PC_DRIVER, PC_HEADER} -- Reading elementary data 

	read_boolean
		do
			last_boolean := read_bool
		end

	read_character
		do
			last_character := read_char8
		end

	read_character_32
		do
			last_character_32 := read_char32
		end

	read_integer_8
		do
			last_integer := read_int_8
		end

	read_integer_16
		do
			last_integer := read_int_16
		end

	read_integer
		do
			last_integer := read_int_32
		end

	read_integer_64
		do
			last_integer_64 := read_int_64
		end

	read_natural_8
		do
			last_natural := read_nat_8
		end

	read_natural_16
		do
			last_natural := read_nat_16
		end

	read_natural
		do
			last_natural := read_nat_32
		end

	read_natural_64
		do
			last_natural_64 := read_nat_64
		end

	read_real
		do
			last_real := read_real_32
		end

	read_double
		do
			last_double := read_real_64
		end

	read_pointer
		local
			ptr: POINTER
		do
			ptr := read_ptr
		end

	read_string
		do
		end

	read_unicode
		do
		end

feature {NONE} -- Implementation

	process_ident (id: like last_ident)
		do
		end
	
feature {NONE} -- Implementation

	object_count: NATURAL

	objects: ARRAY [detachable like last_object]

	last_object: TUPLE [t, it: IS_TYPE; cap: NATURAL]
	
	file: FILE

	fast: BOOLEAN

	on_top: BOOLEAN

	in_tuple, in_agent: BOOLEAN
	
	type_names: DS_ARRAYED_LIST [STRING]

	type_defs: HASH_TABLE [INTEGER, STRING]

	read_header 
		local
			t: IS_TYPE
			f: IS_FIELD
			ff: detachable IS_SEQUENCE [IS_FIELD]
			sorter: DS_QUICK_SORTER [STRING]
			name: STRING
			i, id, j, m, n, oid: INTEGER
		do
			Precursor
			object_count := read_compressed_natural_32
			from
				n := read_compressed_natural_32.to_integer_32
				i := 0
			until i = n loop
				i := i + 1
				id := read_compressed_natural_32.to_integer_32
				name := read_string_8.twin
				type_names.force_last (name)
				type_defs.put (id, name)
			end
			from
				i := 0
				m := read_compressed_natural_32.to_integer_32
			until i = m loop
				i := i + 1
				id := read_compressed_natural_32.to_integer_32
				name := read_string_8.twin
				type_names.force_last (name)
				type_defs.put (id, name)
			end
			create sorter.make (Current)
			sorter.sort (type_names)
			parser.update
			from
				i := 0
				n := type_names.count
			until i = n loop
				i := i + 1
				name := type_names.item (i)
				parser.parse_line (name, type_defs.item(name))
				m := parser.dense_type_idents.count
			end
			from
				i := 0
				n := read_compressed_natural_32.to_integer_32
			until i = n loop
				i := i + 1
				id := read_compressed_natural_32.to_integer_32
				id := parser.dense_type_idents.item (id)
				t := parser.type_at (id)
				m := read_compressed_natural_32.to_integer_32
				if m > 0 then
					from
						j := 0
						create ff.make (m, no_field)
					until j = m loop
						id := read_compressed_natural_32.to_integer_32 
						id := parser.dense_type_idents.item (id)
						create f.make (read_string_8, parser.type_at (id), Void, Void)
						ff.add (f)
						j := j + 1
					end
					t.set_attributes (ff)
				end
			end
			fast := read_bool
			if fast then
				n := object_count.to_integer_32
				create objects.make_filled (Void, 1, n)
				from
					i := 0
				until i = n loop
					id := read_compressed_natural_32.to_integer_32
					id := parser.dense_type_idents.item (id)
					if id > 0 then
						oid := read_compressed_natural_32.to_integer_32
						read_object (id)
						objects.force (last_object, oid)
					end
					i := i + 1
				end
				last_object := objects [objects.lower]
				parser.set_root (last_object.t)
				on_top := True
			else
				create objects.make_filled (Void, 1, 0)
			end
		end

	read_object (tid: INTEGER)
		local
			sid: INTEGER
			cap: NATURAL
		do
			inspect read_nat_8
			when is_special_flag then
				sid := read_compressed_integer_32
				cap := read_compressed_integer_32.to_natural_32
			else
				sid := 0
				cap := 0
			end
			last_object := [parser.type_at (tid), parser.type_at (sid), cap]
		end
	
	less_than (u, v: STRING): BOOLEAN
		do
			Result := u.occurrences ('[') < v.occurrences ('[') 
		end
	
	no_field: IS_FIELD
		once
			create Result.make ("", parser.none_type, Void, Void)
		end
	
end
