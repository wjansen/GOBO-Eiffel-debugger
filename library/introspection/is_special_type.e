note

	description: "Internal description of types in an Eiffel system."

class IS_SPECIAL_TYPE

inherit

	IS_TYPE
		redefine
			is_subobject,
			is_basic,
			is_separate,
			is_reference,
			is_none,
			is_boolean,
			is_character,
			is_integer,
			is_real,
			is_double,
			is_pointer,
			is_int8,
			is_int16,
			is_int32,
			is_int64,
			is_string,
			is_unicode,
			generics
		end

create {IS_SYSTEM, IS_TYPE}

	make,
	make_in_system

feature {} -- Initialization 

	make (id: INTEGER; fl: INTEGER; it: like item_type;
				a: attached like fields; e: like effectors; r: like routines)
		note
			action: "Construct the descriptor."
		require
			not_negative: id >= 0
			a_count: attached a as aa implies aa.count = 3
		do
			ident := id
			flags := fl | Flexible_flag
			fields := a
			effectors := e
			routines := r
			create generics.make (1, it)
			generics.add (it)
			instance_bytes := pointer_bytes.to_natural_32
			default_instance := default_pointer
			fast_name := out
		ensure
			ident_set: ident = id
			flags_set: flags = fl | Flexible_flag
			fields_set: fields = a
		end

	make_in_system (tid, fl: INTEGER; f: IS_FACTORY)
		local
			it: like item_type
			a0, a1, a2: like field_at
		do
			ident := tid
			flags := fl
			f.add_type (Current)
			create generics
			it := f.integer_type
			generics.add (it)
			if is_alive then
				flags := 0
				create a0.make_in_system (once "count", it, Current, 0, f)
				create a1.make_in_system (once "capacity", it, Current, 1, f)
				create a2.make_in_system (once "item", it, Current, 2, f)
				create fields.make (3, a0)
				fields.add (a0)
				fields.add (a1)
				fields.add (a2)
			end
			flags := fl
			scan_in_system (f)
		ensure
			ident_set: ident = tid
			flags_set: flags = fl
		end
	
feature {IS_FACTORY} -- Initialization 

	scan_in_system (f: IS_FACTORY)
		local
			a0, a1, a2: like field_at
			old_flags: INTEGER
		do
			f.set_single_generic_of_type (Current)
			if f.to_fill and then attached {like item_type} f.last_type as it then
				if is_alive then
					old_flags := flags
					flags := 0
					a2 := field_at (2)
					if a2.type /= it then
						a0 := fields [0]
						a1 := fields [1]
						create a2.make_in_system (once "item", it, Current, 2, f)
						fields.clear
						fields.add (a0)
						fields.add (a1)
						fields.add (a2)
					end
					flags := old_flags
				end
				generics.clear
				generics.add (it)
			end
		end

feature -- Access 

	class_name: READABLE_STRING_8
		once
			Result := "SPECIAL"
		end

	count: detachable like field_at
		note
			return: "Field describing the array's `count'."
		do
			if attached fields as aa then
				Result := aa [0]
			end
		ensure
			definition: is_alive implies attached fields as aa and then Result = aa [0]
		end

	capacity: detachable like field_at
		note
			return: "Field describing the array's `capacity'."
		do
			if attached fields as aa then
				Result := aa [1]
			end
		ensure
			definition: is_alive implies attached fields as aa and then Result = aa [0]
		end

	item_0: detachable like field_at
		note
			return:
			"[
			 Field describing field at index 0
			 (e.g. the offset of the C array within an instance).
			 ]"
		do
			if attached fields as aa then
				Result := aa [2]
			end
		ensure
			definition: is_alive implies attached fields as aa and then Result = aa [1]
		end

feature -- Status 

	is_none: BOOLEAN = False

	is_subobject: BOOLEAN = False

	is_basic: BOOLEAN = False

	is_reference: BOOLEAN = True

	is_separate: BOOLEAN = False

	is_boolean: BOOLEAN = False

	is_character: BOOLEAN = False

	is_integer: BOOLEAN = False

	is_real: BOOLEAN = False

	is_double: BOOLEAN = False

	is_pointer: BOOLEAN = False

	is_int8: BOOLEAN = False

	is_int16: BOOLEAN = False

	is_int32: BOOLEAN = False

	is_int64: BOOLEAN = False

	is_string: BOOLEAN = False

	is_unicode: BOOLEAN = False

	is_normal: BOOLEAN = False

	is_special: BOOLEAN = True

	is_tuple: BOOLEAN = False

	is_agent: BOOLEAN = False

	item_type: like generic_at
		note
			return: "Type of items. "
		do
			Result := generic_at (0)
		end
	
feature -- Item size and offsets 

	item_bytes: NATURAL
		note
			return: "Memory size (in bytes) of array items."
		do
			Result := item_type.field_bytes
		end

	item_offset (i: INTEGER): INTEGER
		note
			return:
			"[
			 Offset (in bytes) of the `i'-th entry
			 of the SPECIAL object (of type given by `Current').
			 ]"
		require
			valid_index: 0 <= i
		do
			if attached item_0 as i0 then
				Result := i0.offset + i * item_bytes.to_integer_32
			else
				Result := -1
			end
		end

feature {IS_BASE} -- Implementation 

	generics: IS_SEQUENCE [like generic_at]

invariant

	generic_count: generic_count = 1
	field_count: is_alive implies field_count = 3
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
