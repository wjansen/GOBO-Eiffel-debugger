note

	description: "Parser token codes"
	generator: "geyacc version 3.9"

deferred class DG_TOKENS

inherit

	YY_PARSER_TOKENS

feature -- Last values

	last_detachable_any_value: detachable ANY
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
			when BEGIN_TYPEDEF then
				Result := "BEGIN_TYPEDEF"
			when END_TYPEDEF then
				Result := "END_TYPEDEF"
			when BEGIN_STRUCT then
				Result := "BEGIN_STRUCT"
			when END_STRUCT then
				Result := "END_STRUCT"
			when BEGIN_ENUM then
				Result := "BEGIN_ENUM"
			when END_ENUM then
				Result := "END_ENUM"
			when INTEGER then
				Result := "INTEGER"
			when IDENTIFIER then
				Result := "IDENTIFIER"
			when ENUM_NAME then
				Result := "ENUM_NAME"
			when CLASS_NAME then
				Result := "CLASS_NAME"
			when TYPE_NAME then
				Result := "TYPE_NAME"
			when STRUCT_NAME then
				Result := "STRUCT_NAME"
			else
				Result := yy_character_token_name (a_token)
			end
		end

feature -- Token codes

	BEGIN_TYPEDEF: INTEGER = 258
	END_TYPEDEF: INTEGER = 259
	BEGIN_STRUCT: INTEGER = 260
	END_STRUCT: INTEGER = 261
	BEGIN_ENUM: INTEGER = 262
	END_ENUM: INTEGER = 263
	INTEGER: INTEGER = 264
	IDENTIFIER: INTEGER = 265
	ENUM_NAME: INTEGER = 266
	CLASS_NAME: INTEGER = 267
	TYPE_NAME: INTEGER = 268
	STRUCT_NAME: INTEGER = 269

end
