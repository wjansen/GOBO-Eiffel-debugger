note

	description:
	"[
	 Effecting of class PC_TARGET that does nothing except providing
	 object idents, just to read from source. 
	 ]"

class PC_NO_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			must_expand_strings,
			has_capacities,
			put_string,
			put_unicode,
			set_field,
			set_index
		end

create

	default_create

feature -- Access 

	must_expand_strings: BOOLEAN = False

	has_capacities: BOOLEAN = False

feature {PC_HEADER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
		end

	put_character (c: CHARACTER)
		do
		end

	put_character_32 (c: CHARACTER_32)
		do
		end

	put_integer (i: INTEGER_32)
		do
		end

	put_natural (n: NATURAL_32)
		do
		end

	put_integer_64 (i: INTEGER_64)
		do
		end

	put_natural_64 (n: NATURAL_64)
		do
		end

	put_real (r: REAL_32)
		do
		end

	put_double (d: REAL_64)
		do
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

	put_known_ident (id: NATURAL; t: IS_TYPE)
		do
		end

feature {PC_DRIVER} -- Object location
	
	set_field (f: like field; in: NATURAL)
		do
		end

	set_index (s: IS_SPECIAL_TYPE; n: NATURAL; in: NATURAL)
		do
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
