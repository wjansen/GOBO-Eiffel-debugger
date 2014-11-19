note

	description:

		"Compile time description of constants of a type or of arguments."

class ET_IS_CONSTANT

inherit

	IS_CONSTANT 
		redefine
			type,
			text,
			home
		end

	ET_IS_ORIGIN [ET_DYNAMIC_FEATURE, IS_NAME]

create

	declare

feature {NONE} -- Initialization 

	declare (o: like origin; s: ET_IS_SYSTEM)
		note
			action: "Create `Current' according to `o'."
		local
			nm: STRING
			dynamic: ET_DYNAMIC_TYPE
			static: ET_FEATURE
			real_value: REAL_64
			int_value: INTEGER_64
			nat_value: NATURAL_64
			n: INTEGER
			ok: BOOLEAN
		do
			make_origin (o)
			static := o.static_feature
			fast_name := s.internal_name (static.lower_name)
			s.force_class (static.implementation_class)
			home := s.last_class
			if attached o.result_type_set.static_type as t then
				s.force_type (t)
			end
			type := s.last_type
			s.origin_table.force (Current, o)
			if attached {ET_UNIQUE_ATTRIBUTE} static as u then
				int_value := s.origin.current_system.registered_feature_count
					- u.implementation_feature.id + 1
				set_integer_value (int_value.to_integer_32)
			elseif attached {ET_CONSTANT_ATTRIBUTE} static as c then
				inspect type.ident
				when Boolean_ident then
					ok := attached {ET_TRUE_CONSTANT} c.constant 
					set_boolean_value (ok)
				when Char8_ident then
					if attached {ET_CHARACTER_CONSTANT} c.constant as char then
						set_character_value(char.value.to_character_8)
					end
				when Char32_ident then
					if attached {ET_CHARACTER_CONSTANT} c.constant as char then
						set_character_32_value(char.value)
					end
				when Int8_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as int then
						int_value := int.literal.to_integer_64
						set_integer_8_value (int_value.as_integer_8)
					end
				when Int16_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as int then
						int_value := int.literal.to_integer_64
						set_integer_16_value (int_value.as_integer_16)
					end
				when Int32_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as int then
						int_value := int.literal.to_integer_64
						set_integer_32_value (int_value.as_integer_32)
					end
				when Int64_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as int then
						int_value := int.literal.to_integer_64
						set_integer_64_value (int_value)
					end
				when Nat8_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as nat then
						nat_value := nat.literal.to_natural_64
						set_natural_8_value (nat_value.as_natural_8)
					end
				when Nat16_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as nat then
						nat_value := nat.literal.to_natural_64
						set_natural_16_value (nat_value.as_natural_16)
					end
				when Nat32_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as nat then
						nat_value := nat.literal.to_natural_64
						set_natural_32_value (nat_value.as_natural_32)
					end
				when Nat64_ident then
					if attached {ET_INTEGER_CONSTANT} c.constant as nat then
						nat_value := nat.literal.to_natural_64
						set_natural_64_value (nat_value)
					end
				when Real32_ident then
					if attached {ET_REAL_CONSTANT} c.constant as real then
						real_value := real.literal.to_double
						if attached real.sign as sgn and then sgn.is_prefix_minus then
							real_value := -real_value
						end
						set_real_32_value (real_value.truncated_to_real)
					end
				when Real64_ident then
					if attached {ET_REAL_CONSTANT} c.constant as real then
						real_value := real.literal.to_double
						if attached real.sign as sgn and then sgn.is_prefix_minus then
							real_value := -real_value
						end
						set_real_64_value (real_value)
					end
				when String8_ident then
					if attached {ET_MANIFEST_STRING} c.constant as str then
						set_string_value (str.value)
					end
				when String32_ident then
					if attached {ET_MANIFEST_STRING} c.constant as str then
						set_string_32_value (str.value)
					end
				else
				end
			end
			if s.needs_feature_texts then
				create text.declare_from_declaration (static, fast_name,
																							type.origin.base_type, home, s)
				home.add_text (text)
			end
		ensure
			origin_set: origin = o
		end

feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		note
			action: "Complete construction of `Current'."
		do
			if not defined then
				defined := True
				home.define (s)
				type.define (s)
			end
		end

feature -- Access 

	type: ET_IS_TYPE

	text: ET_IS_FEATURE_TEXT

	home: ET_IS_CLASS_TEXT
	
feature -- ET_IS_ORIGIN 

	print_name (a_file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			a_file.put_character ('&')
			g.print_once_value_name (origin.static_feature, a_file)
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
