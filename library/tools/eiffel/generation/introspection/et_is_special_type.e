note

	description: "Compile time description of types in an Eiffel system."

class ET_IS_SPECIAL_TYPE

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
			field_count
		redefine
			declare,
			declare_from_pattern,
			define,
			generics,
			origin
		end

	IS_SPECIAL_TYPE
		undefine
			effector_at,
			routine_at,
			generic_at,
			field_at,
			constant_at,
			set_fields,
			is_equal
		redefine
			generics
		end

create
	
	declare, declare_from_pattern

feature {} -- Initialization 

	declare (o: like origin; id: INTEGER; s: ET_IS_SYSTEM)
		local
			df: ET_DYNAMIC_FEATURE
			bc: like base_class
			it: like item_type
			a2: like field_at
			r: ET_IS_ROUTINE
			i: INTEGER
		do
			Precursor (o, id, s)
			s.set_special_class (base_class)
			if origin.queries.count = 0 then
				flags := 0
			end
			s.force_type (o.item_type_set.static_type)
			it := s.last_type
			create generics.make_1 (it)
			if o.is_alive then
				declare_fields (s)
				create a2.declare_without_origin (2, once "item", it, Current, s)
				fields.add (a2)
				declare_routines (s)
				from
					if o.queries /= Void then
						i := o.queries.count
					end
				until i = 0 loop
					df := o.queries.item (i)
					if STRING_.same_string(df.static_feature.lower_name, "item") then
						i := 0
					else
						df := Void
						i := i - 1
					end
				end
				if df /= Void then
					create r.declare (df, Current, False, s)
					a2.set_text (r.text)
				end
			end
		end

	declare_from_pattern (o: like origin; p: like Current; s: ET_IS_SYSTEM)
		local
			a2: like field_at
		do
			Precursor (o, p, s)
			flags := Flexible_flag
			if o.is_alive then
				flags := flags | Reference_flag
				create a2.declare_from_pattern (Void, p.item_0, Current, 2, s)
				fields.add (a2)
			end
		end
	
feature -- Initialization
	
	define (s: ET_IS_SYSTEM)
		do
			if not defined then
				Precursor (s)
				if s.needs_typeset and then attached origin as o
				 and then attached item_0 as i0 then
					i0.set_type_set (s.type_set (item_type, o.item_type_set, i0.is_attached))
				end				
			end
		end
	
feature -- Access 

	origin: ET_DYNAMIC_SPECIAL_TYPE

feature -- ET_IS_ORIGIN 

	print_count (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_field_special_count_name (origin, file)
		end

	print_item (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_field_special_item_name (origin, file)
		end

feature {IS_BASE} -- Implementation 

	generics: IS_SEQUENCE [like generic_at]

feature {} -- Implementation 

	count_feature (s: ET_IS_SYSTEM): ET_IS_FEATURE_TEXT
		local
			dt: ET_DYNAMIC_TYPE
			df: ET_DYNAMIC_FEATURE
			id: ET_IDENTIFIER
			attr: ET_ATTRIBUTE
		once
			dt := s.origin.integer_32_type
			create id.make (s.internal_name (once "count"))
			create attr.make (id, dt.base_type, dt.base_class)
			create df.make (attr, dt, s.origin)
			create Result.declare_from_feature (base_class, df.static_feature, s)
		end

	item_feature (s: ET_IS_SYSTEM): ET_IS_FEATURE_TEXT
		local
			dt: ET_DYNAMIC_TYPE
			df: ET_DYNAMIC_FEATURE
			id: ET_IDENTIFIER
			attr: ET_ATTRIBUTE
		do
			dt := generic_at (0).origin
			create id.make (s.internal_name (once "item"))
			create attr.make (id, dt.base_type, dt.base_class)
			create df.make (attr, dt, s.origin)
			create Result.declare_from_feature (base_class, df.static_feature, s)
		end
	
feature {} -- Implementation 

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
