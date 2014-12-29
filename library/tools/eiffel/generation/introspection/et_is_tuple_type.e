note

	description: "Compile time description of types in an Eiffel system."

class ET_IS_TUPLE_TYPE

inherit

	ET_IS_TYPE
		undefine
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
			generic_count,
			class_name
		redefine
			declare,
			declare_from_pattern,
			define,
			base_class
		end

	IS_TUPLE_TYPE
		undefine
			generic_at,
			effector_at,
			field_at,
			constant_at,
			routine_at,
			set_fields,
			is_equal
		redefine
			base_class
		end

create 

	declare, declare_from_pattern

feature {NONE} -- Initialization 

	declare (o: like origin; id: INTEGER; s: ET_IS_SYSTEM)
		local
			sets: ET_DYNAMIC_TYPE_SET_LIST
			dynamic: ET_DYNAMIC_TYPE
			t: ET_IS_TYPE
			a: ET_IS_FIELD
			x: ET_IS_FEATURE_TEXT
			i, k, n: INTEGER
		do
			Precursor (o, id, s)
			s.set_tuple_class (base_class)
			if attached {ET_DYNAMIC_TUPLE_TYPE} o as ot then
				sets := ot.item_type_sets
			end
			n := sets.count
			if n > 0 then
				from
					i := 0
					k := s.type_stack_count
				until i = n loop
					i := i + 1
					dynamic := sets.item (i).static_type
					s.force_type (dynamic)
					s.push_type (s.last_type.ident)
				end
				generics := s.extract_types (n, False, True)
			end
			if n > 0 and then s.needs_attributes and then origin.is_alive then
				from
					i := 0
				until i = n loop
					t := generic_at (i)
					if attached item_id (i + 1, s) as item then
						create a.declare_without_origin (i, item.lower_name, t, Current, s)
						if attached {ET_DECLARED_TYPE} t.origin.base_type as d then
							create x.declare_from_declaration (item, a.fast_name, d, base_class, s)
							if i = 0 then
								x.declare_tuple_labels (t.origin.base_type, s)
							elseif attached x.tuple_labels as tl then
								x.set_tuple_labels (tl)
							end
							a.set_text (x)
						end
						if not attached fields then
							create fields.make (n, a)
						end
						if attached fields as aa then
							aa.add (a)
						end
					end
					i := i + 1
				end
			end
			if o.is_alive and then s.needs_routines then
				declare_routines (s)
			end
		end

	declare_from_pattern (o: like origin; p: like Current; s: ET_IS_SYSTEM)
		local
			a: attached ET_IS_FIELD
			i, n: INTEGER
		do
			Precursor (o, p, s)
			if o.is_alive and then s.needs_attributes then
				from
					n := generic_count
				until i = n loop
					a := p.field_at (i)
					create a.declare_without_origin (i, a.fast_name, a.type, Current, s)
					if not attached fields then
						create fields.make (n, a)
					end
					fields.add (a)
					i := i + 1
				end
			end
		end
	
feature -- Initialization
	
	define (s: ET_IS_SYSTEM)
		local
			sets: ET_DYNAMIC_TYPE_SET_LIST
			list: ET_DYNAMIC_TYPE_SET
			a: like field_at
			i: INTEGER
		do
			if not defined then
				Precursor (s)
				if s.needs_typeset
					and then attached {ET_DYNAMIC_TUPLE_TYPE} origin as ot 
				 then
					sets := ot.item_type_sets
					from
						i := field_count
					until i = 0 loop
						list := sets.item (i)
						i := i - 1
						a := field_at (i)
						a.set_type_set (s.type_set (a.type, list, a.is_attached))
						a.define (s)
					end
				end
			end
		end

feature -- Access 

	base_class: attached ET_IS_CLASS_TEXT

feature -- ET_IS_ORIGIN 

	print_item (file: KI_TEXT_OUTPUT_STREAM; i: INTEGER; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_attribute_tuple_item_name (i, origin, file)
		end

feature {NONE} -- Implementation

	item_ids: ARRAY [detachable ET_IDENTIFIER]
		once
			create Result.make_filled (Void, 0, 20)
		end

	item_id (i: INTEGER; s: ET_IS_SYSTEM): ET_IDENTIFIER
		require
			i_not_negative: i >= 0
		local
			nm: STRING
		do
			if item_ids.upper < i then
				Result := item_ids [i]
			end
			if not attached Result then
				nm := item_name (i)
				nm := s.internal_name (nm)
				create Result.make (nm)
				item_ids.force (Result, i)
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
