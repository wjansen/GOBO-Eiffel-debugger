note

	description: "Parser token codes"
	generator: "geyacc version 3.9"

class PC_TOKENS

inherit

	YY_PARSER_TOKENS

feature -- Last values

	last_any_value: ANY
	last_integer_value: INTEGER
	last_string_value: STRING

feature -- Access

	token_name (a_token: INTEGER): STRING
			-- Name of token `a_token'
		do
			inspect a_token
			when 0 then
				Result := "EOF token"
			when -1 then
				Result := "Error token"
			when Actual_code then
				Result := "Actual_code"
			when Print_CODE then
				Result := "Print_CODE"
			when Size_CODE then
				Result := "Size_CODE"
			when Types_CODE then
				Result := "Types_CODE"
			when Fields_code then
				Result := "Fields_code"
			when Objects_CODE then
				Result := "Objects_CODE"
			when Qualifier_CODE then
				Result := "Qualifier_CODE"
			when Long_code then
				Result := "Long_code"
			when Extract_CODE then
				Result := "Extract_CODE"
			when Load_CODE then
				Result := "Load_CODE"
			when Ise2gec_CODE then
				Result := "Ise2gec_CODE"
			when Gec2ise_CODE then
				Result := "Gec2ise_CODE"
			when Xml_CODE then
				Result := "Xml_CODE"
			when Cc_CODE then
				Result := "Cc_CODE"
			when Help_CODE then
				Result := "Help_CODE"
			when Quit_CODE then
				Result := "Quit_CODE"
			when NO_CODE then
				Result := "NO_CODE"
			when INTEGER then
				Result := "INTEGER"
			when FILE_NAME then
				Result := "FILE_NAME"
			else
				Result := yy_character_token_name (a_token)
			end
		end

feature -- Token codes

	Actual_code: INTEGER = 258
	Print_CODE: INTEGER = 259
	Size_CODE: INTEGER = 260
	Types_CODE: INTEGER = 261
	Fields_code: INTEGER = 262
	Objects_CODE: INTEGER = 263
	Qualifier_CODE: INTEGER = 264
	Long_code: INTEGER = 265
	Extract_CODE: INTEGER = 266
	Load_CODE: INTEGER = 267
	Ise2gec_CODE: INTEGER = 268
	Gec2ise_CODE: INTEGER = 269
	Xml_CODE: INTEGER = 270
	Cc_CODE: INTEGER = 271
	Help_CODE: INTEGER = 272
	Quit_CODE: INTEGER = 273
	NO_CODE: INTEGER = 274
	INTEGER: INTEGER = 275
	FILE_NAME: INTEGER = 276

end
