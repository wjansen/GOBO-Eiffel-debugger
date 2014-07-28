note

	description: "Extracting per object information from a persistence closure."

class PC_SELECT_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			pre_object,
			post_object,
			pre_special,
			post_special,
			put_new_object,
			put_new_special,
			field,
			set_field,
			set_index
		end

create

	make

feature {} -- Initialization 

	make
		do
			create no_value
			create values.make (12)
			default_create
		ensure
		end

feature -- Access 

	has_capacities: BOOLEAN = False
	
	field: detachable IS_FIELD
	
	values: PC_INTEGER_TABLE [like object_values]
	
feature {PC_DRIVER} -- Pre and post handling of data

	pre_object (t: IS_TYPE; id: like last_ident)
		local
			v: ARRAY [PC_TOOL_VALUE]
		do
			create v.make_filled (no_value, 0, t.field_count - 1)
			values.put (v, id)
			object_values := v
		end

	post_object (t: IS_TYPE; id: like last_ident)
		do
			field_value := Void
		end
	
	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: like last_ident)
		local
			v: ARRAY [PC_TOOL_VALUE]
		do
			create v.make_filled (no_value, 0, cap.to_integer_32 - 1)
			values.put (v, id)
			object_values := v
		end

	post_special (s: IS_SPECIAL_TYPE; id: like last_ident)
		do
			field_value := Void			
		end
	
feature {PC_DRIVER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
			field_value.set_boolean (b)
		end

	put_character (c: CHARACTER)
		do
		end

	put_character_32 (c: CHARACTER_32)
		do
		end

	put_integer (i: INTEGER_32)
		do
			field_value.set_integer (i)
		end

	put_natural (n: NATURAL_32)
		do
			field_value.set_natural (n)
		end

	put_integer_64 (i: INTEGER_64)
		do
			field_value.set_integer (i)
		end

	put_natural_64 (n: NATURAL_64)
		do
			field_value.set_natural (n)
		end

	put_real (r: REAL_32)
		do
			field_value.set_real (r)
		end

	put_double (d: REAL_64)
		do
			field_value.set_real (d)
		end

	put_pointer (p: POINTER)
		do
		end

	put_string (s: STRING)
		do
		end

	put_unicode (u: STRING_32)
		do
		end

	put_known_ident (id: like void_ident; t: IS_TYPE)
		local
			m: INTEGER
		do
			if id /= void_ident then
				m := Max_basic_ident + 1
			end
			field_value.set_ident (id, m)
		end

	put_new_object (t: IS_TYPE)
		do
			if attached field_value as fv then
				fv.set_ident (last_ident, t.ident)
			end
		end

	put_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			if attached field_value as fv then
				fv.set_ident (last_ident, st.ident)
			end
		end
	
feature {PC_DRIVER} -- Object location

	set_field (f: like field; in: like last_ident)
		local
			off: INTEGER
		do
			field := f
			field_type := f.type
			create field_value
			off := f.offset
			if off >= 0 then
				object_values [off] := field_value
			end
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: like last_ident)
		do
			index := i.to_integer_32
			field := Void
			field_type := s.item_type
			create field_value
			object_values [i.to_integer_32] := field_value 
		end

	set_next_ident (id: like last_ident)
		do
			last_ident := id
		end
	
feature {} -- Implementation 

 	field_value: detachable PC_TOOL_VALUE

	no_value: PC_TOOL_VALUE

	object_values: ARRAY [PC_TOOL_VALUE]
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
