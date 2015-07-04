%{
note

	description:

		"Scanners for Vala generated C header files %
                %Extract from class ET_EIFFEL_SCANNER"

	copyright: "Copyright (c) 1999-2003, Eric Bezault and others"
	license: "MIT License"
	base_source: "et_eiffel_scanner.l"

deferred class ET_EXPORT_SCANNER

inherit

	YY_COMPRESSED_SCANNER_SKELETON
		rename
			make as make_compressed_scanner_skeleton,
			reset as reset_compressed_scanner_skeleton
		end

	ET_EXPORT_TOKENS
		export {NONE} all end

%}

%option position
%option nodefault line outfile="et_export_scanner.e"

%%

[A-Za-z][A-Za-z0-9_]*	{
		last_token := E_IDENTIFIER
		last_string_value := text.twin
		}

_[A-Za-z0-9_]*	{
		last_token := C_IDENTIFIER
		last_string_value := text.twin
		}

[][,=.*]		{ last_token := text[1].code }

\\\n		-- Continuation at next line

"--".*/[\n\r]	--{ last_token := EOL }

[\n\r]+		{ last_token := EOL }

[ \t]+		-- Ignore separators

.		{ last_token := OTHER }

<*><<EOF>>	terminate

%%

invariant

note
	date: "$Data$"
	revision: "$Revision$"
	compilation: "gelex -o et_export_scanner.e -x et_export_scanner.l"

end
