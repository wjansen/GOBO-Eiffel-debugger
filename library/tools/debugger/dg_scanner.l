%{
note

	description:

		"Scanners for Vala generated C header files %
                %Extract from class ET_EIFFEL_SCANNER"

	copyright: "Copyright (c) 1999-2003, Eric Bezault and others"
	license: "MIT License"
	base_source: "et_eiffel_scanner.l"

deferred class DG_SCANNER

inherit

	YY_COMPRESSED_SCANNER_SKELETON
		rename
			make as make_compressed_scanner_skeleton,
			reset as reset_compressed_scanner_skeleton
		end

	DG_TOKENS
		export {} all end

%}

%x TYPEDEF
%x STRUCT
%x ENUM

%option position
%option nodefault line outfile="et_debug_scanner.e"

%%

<*>[ \t\r\n]+			-- ignore separators

<INITIAL>^"typedef "	{
		last_token := BEGIN_TYPEDEF
		set_start_condition(TYPEDEF)
	}

<INITIAL>^"struct "	{
		last_token := BEGIN_STRUCT 
		set_start_condition(STRUCT)
	} 

<TYPEDEF> {
"struct "	{
		last_token := BEGIN_STRUCT 
	}
"enum "	{
		last_token := BEGIN_ENUM 
		set_start_condition(ENUM)
	}
[(,)*]	{
		last_token := text[1].code 
	}
";"	{
		last_token := END_TYPEDEF
		set_start_condition(INITIAL)
	}
}

<ENUM> {
"GEDB_"[A-Z0-9_]+	{
		last_token := ENUM_NAME
		last_string_value := text.twin
	}
[0-9]+	{
		last_token := INTEGER
		last_integer_value := text.to_integer
	}
0x[0-9A-Fa-f]+	{
		last_token := INTEGER
		last_integer_value := text.to_integer
	}
[{,=}]	{
		last_token := text[1].code 
	}
";"	{
		last_token := END_ENUM
		set_start_condition(INITIAL)
	}
}

<STRUCT> {
"{"|";"|"*"	{
		last_token := text[1].code 
	}
"};"	{
		last_token := END_STRUCT
		set_start_condition(INITIAL)
	}
}

<TYPEDEF,STRUCT,ENUM> {
"Gedb"[A-Za-z0-9_]+"*"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"Gedb"[A-Za-z0-9_]+	{
		last_token := CLASS_NAME
		last_string_value := text.twin
	}
"_Gedb"[A-Za-z0-9_]+	{
		last_token := STRUCT_NAME
		last_string_value := text.twin
	}
"gboolean"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"gint"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"guint64"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"guint"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"gsize"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"gchar*"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"gpointer"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"gconstpointer"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"void*"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
"void"	{
		last_token := TYPE_NAME
		last_string_value := text.twin
	}
}

<TYPEDEF,STRUCT,ENUM> {
[A-Z][_A-Za-z0-9]*	{
		last_token := IDENTIFIER
		last_string_value := text.twin
	}
[_a-z][_a-z0-9]*	{
		last_token := IDENTIFIER
		last_string_value := text.twin
	}
}

<*>.			-- ignore
<*><<EOF>>		terminate

%%

feature -- Access

	c_name: STRING

invariant

note
	date: "$Data$"
	revision: "$Revision$"
	compilation: "gelex -o dg_scanner.e -x dg_scanner.l"

end
