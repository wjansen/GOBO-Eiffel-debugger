note

	description: "Internal description of a constant of a class."

class IS_CONSTANT
	
inherit

	IS_ENTITY

create

	make

feature {NONE} -- Initialization 

	make (nm: READABLE_STRING_8; fl: INTEGER; h: like home;
			t: like type; f: like text)
		note
			action: "Create a `IS_CONSTANT'."
		do
			make_entity (nm, f)
			flags := fl
			home := h
			type := t
			basic := 0
			ms := ""
		ensure
			name_set: fast_name.is_equal (nm)
			home_set: home = h
			type_set: type = t
			value_set: value = v
			flags_set: flags = fl
			text_set: text = f
		end

feature -- Access 

	flags: INTEGER

	home: IS_CLASS_TEXT
			-- Declaring class

feature -- Status 

	is_constant: BOOLEAN = True

	is_field: BOOLEAN = False

	is_routine: BOOLEAN = False

	is_attached: BOOLEAN = True

	boolean_value: BOOLEAN
		do
			Result := basic /= 0
		end
	
	character_value, character_8_value: CHARACTER_8
		do
			Result := c_char(basic)
		end

	character_32_value: CHARACTER_32
		do
			Result := c_char32(basic)
		end

	integer_8_value: INTEGER_8
		do
			Result := basic.to_integer_8
		end
	
	integer_16_value: INTEGER_16
		do
			Result := basic.to_integer_16
		end
	
	integer_value, integer_32_value: INTEGER_32
		do
			Result := basic.to_integer_32
		end
	
	integer_64_value: INTEGER_64
		do
			Result := basic.to_integer_64
		end
	
	natural_8_value: NATURAL_8
		do
			Result := basic.to_natural_8
		end
	
	natural_16_value: NATURAL_16
		do
			Result := basic.to_natural_16
		end
	
	natural_32_value: NATURAL_32
		do
			Result := basic.to_natural_32
		end
	
	natural_64_value: NATURAL_64
		do
			Result := basic.to_natural_64
		end
	
	real_32_value: REAL_32
		do
			Result := c_float($basic)
		end
	
	real_64_value: REAL_64
		do
			Result := c_double($basic)
		end
	
	string_8_value: STRING_8
		do
			Result := c_string(ref)
		end
	
	string_value, string_32_value: STRING_32
		do
			Result := c_unicode(ref)
		end
	
feature {IS_BASE} -- Status setting 

	set_boolean_value (b: BOOLEAN)
		do
			if b then
				basic := 1
			else
				basic := 0
			end
		ensure
			boolean_value_set: boolean_value = b
		end

	set_character_value (c: CHARACTER)
		do
			basic := c.code.to_natural_64
		ensure
			character_value_set: character_value = c
		end

	set_character_32_value (c: CHARACTER_32)
		do
			basic := c.code.to_natural_64
		ensure
			character_value_set: character_32_value = c
		end

	set_integer_8_value (i: INTEGER_8)
		do
			basic := i.to_natural_64
		ensure
			character_value_set: integer_8_value = i
		end

	set_integer_16_value (i: INTEGER_16)
		do
			basic := i.to_natural_64
		ensure
			character_value_set: integer_16_value = i
		end

	set_integer_value, set_integer_32_value (i: INTEGER_32)
		do
			basic := i.to_natural_64
		ensure
			character_value_set: integer_32_value = i
		end

	set_integer_64_value (i: INTEGER_64)
		do
			basic := i.to_natural_64
		ensure
			character_value_set: integer_64_value = n
		end

	set_natural_8_value (n: NATURAL_8)
		do
			basic := n.to_natural_64
		ensure
			character_value_set: natural_8_value = n
		end

	set_natural_16_value (n: NATURAL_16)
		do
			basic := n.to_natural_64
		ensure
			character_value_set: natural_16_value = n
		end

	set_natural_32_value (n: NATURAL_32)
		do
			basic := n.to_natural_64
		ensure
			character_value_set: natural_32_value = n
		end

	set_natural_64_value (n: NATURAL_64)
		do
			basic := n.to_natural_64
		ensure
			character_value_set: natural_64_value = n
		end

	set_real_32_value (r: REAL_32)
		do
			basic := c_from_float($r)
		ensure
			character_value_set: real_32_value = n
		end

	set_real_64_value (r: REAL_64)
		do
			basic := c_from_double($r)
		ensure
			character_value_set: real_64_value = n
		end

	set_string_value (s: STRING)
		do
			ms := s
		ensure
			character_value_set: string_value = s
		end

	set_string_32_value (s: STRING_32)
		do
			ms := s
		ensure
			character_value_set: string_32_value = s
		end

feature -- Status setting 

	set_value (p: POINTER)
		do
		end

feature -- Output 

	indented_out (indent: INTEGER): STRING
		do
			create Result.make (0)
			pad_right (Result, indent)
			append_name (Result)
			Result.append (once " = ")
			Result.append (value.out)
		end

feature {IS_BASE} -- Access

	basic: NATURAL_64
			-- Buffer of value if `type.is_basic',
			-- needs bitwise conersion when accessed.
	
	ms: detachable STRING
		-- Value if `type.is_string', UTF8 of value if `type.is_unicode'.
	
feature {NONE} -- External implementation

	c_double(p: POINTER): REAL_64
		external "C inline"
		alias "*(double*)$n"
		end
	
	c_float(p: POINTER): REAL_32
		external "C inline"
		alias "*(float*)$n"
		end
	
	c_char(n: NATURAL_64): CHARACTER_8
		external "C inline"
		alias "(char)$n"
		end
	
	c_char32(n: NATURAL_64): CHARACTER_32
		external "C inline"
		alias "$n"
		end
	
	c_string(p: POINTER): STRING_8
		external "C inline"
		alias "$r"
		end
	
	c_unicode(p: POINTER): STRING_32
		external "C inline"
		alias "$p"
		end

	c_from_float(p: POINTER): NATURAL_64
		external "C inline"
		alias "*(EIF_NATURAL_64*)$p"
		end
	
	c_from_double(p: POINTER) : NATURAL_64
		external "C inline"
		alias "*(EIF_NATURAL_32*)$p"
		end
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
