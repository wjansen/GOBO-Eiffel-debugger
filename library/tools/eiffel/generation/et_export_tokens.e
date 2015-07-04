note

	description: "Parser token codes"
	generator: "geyacc version 3.9"

deferred class ET_EXPORT_TOKENS

inherit

	YY_PARSER_TOKENS

feature -- Last values

	last_detachable_any_value: detachable ANY
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
			when E_IDENTIFIER then
				Result := "E_IDENTIFIER"
			when C_IDENTIFIER then
				Result := "C_IDENTIFIER"
			when EOL then
				Result := "EOL"
			when OTHER then
				Result := "OTHER"
			else
				Result := yy_character_token_name (a_token)
			end
		end

feature -- Token codes

	E_IDENTIFIER: INTEGER = 258
	C_IDENTIFIER: INTEGER = 259
	EOL: INTEGER = 260
	OTHER: INTEGER = 261

end
