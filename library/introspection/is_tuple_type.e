note

	description: "Internal description of types in an Eiffel system."

class IS_TUPLE_TYPE

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
			class_name
		end

create {IS_SYSTEM, IS_TYPE}

	make,
	make_in_system

feature {NONE} -- Initialization 

	make (id: INTEGER; fl: INTEGER; ct: like base_class;
			g: like generics; e: like effectors; a: like fields; r: like routines)
		note
			action: "Construct the descriptor."
		require
			not_negative: id >= 0
			ct_is_special: ct.has_name ("TUPLE")
		local
			ai: like field_at
			i, j: INTEGER
		do
			ident := id
			flags := fl | Tuple_flag
			base_class := ct
			generics := g
			effectors := e
			if attached a then
				fields := a
			elseif is_alive and then generic_count > 0 then
				from
				until i = generic_count loop
					j := i + 1
					create ai.make (item_name (j), g [i], Void, Void)
					if i = 0 then
						create fields.make (generic_count, ai)
					end
					fields.add (ai)
					i := j
				end
			end
			routines := r
			instance_bytes := pointer_bytes.to_natural_32
			default_instance := default_pointer
			fast_name := out
		ensure
			ident_set: ident = id
			flags_set: flags = fl | Tuple_flag
		end

	make_in_system (tid, fl: INTEGER; f: IS_FACTORY)
		require
			valid_index: 0 < tid 
			when_made: ident > 0 implies ident = tid
		do
			ident := tid
			flags := fl
			f.add_type (Current)
			scan_in_system (f)
		ensure
			ident_set: ident = tid
			flags_set: flags = fl
		end
	
feature {IS_FACTORY} -- Initialization
	
	scan_in_system (f: IS_FACTORY)
		local
			a: like field_at
			nm: STRING
			i, n: INTEGER
		do
			f.set_generics_of_type (Current)
			if f.to_fill then
				if is_alive and then attached {like generics} f.last_types as gg then
					generics := gg
					from
						n := gg.count
					until i = n loop
						nm := f.item_name (i + 1)
						create a.make_in_system (nm, gg [i], Current, i, f)
						if not attached fields then
							create fields.make (n, a)
						end
						if attached fields as aa then
							aa.add (a)
						end
						i := i + 1
					end
				end
			end
		end

feature -- Access
	
	class_name: READABLE_STRING_8
		once
			Result := "TUPLE"
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

	is_special: BOOLEAN = False

	is_tuple: BOOLEAN = True

	is_agent: BOOLEAN = False

feature -- Output 

	append_labeled_type_name (field: IS_ENTITY; str: STRING)
		note
			action: "Append TUPLE label"
			field: "TUPLE item"
			str: "STRING to be extended"
		require
			field_type: field.type = Current
		local
			i, n: INTEGER
		do
			n := generic_count
			if attached {IS_FEATURE_TEXT} field.text as text and then n > 0 then
				str.append (class_name)
				str.extend ('[')
				from
				until i = n loop
					if i > 0 then
						str.extend (',')
						str.extend (' ')
					end
					if attached text.tuple_labels then
						text.append_label (field_at (i).fast_name, str)
						str.extend (':')
						str.extend (' ')
					end
					generic_at (i).append_name (str)
					i := i + 1
				end
				str.extend (']')
			else
				append_name (str)
			end
		end

feature {NONE} -- Implementation

	item_names: ARRAY [detachable READABLE_STRING_8]
		once
			create Result.make_filled (Void , 0, 20)
		end

	item_name (i: INTEGER): READABLE_STRING_8
		require
			i_not_negative: i >= 0
		local
			str: STRING
		do
			if i <= item_names.upper then
				Result := item_names [i]
			end
			if not attached Result then
				create str.make (8)
				str.append (once "item_")
				str.append_integer (i)
				item_names.force (str, i)
				Result := str
			end
		end

invariant

	when_alive: is_alive implies field_count = generic_count

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
