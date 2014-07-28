note

	description:

		"Scanners for Eiffel parsers %
                %Extract from class ET_EIFFEL_SCANNER:%
		%multi line strings and most keywords have been dropped."

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
		export {NONE} all end

	DG_GLOBALS


feature -- Status report

	valid_start_condition (sc: INTEGER): BOOLEAN
			-- Is `sc' a valid start condition?
		do
			Result := (INITIAL <= sc and sc <= BREAK)
		end

feature {NONE} -- Implementation

	yy_build_tables
			-- Build scanner tables.
		do
			yy_nxt := yy_nxt_template
			yy_chk := yy_chk_template
			yy_base := yy_base_template
			yy_def := yy_def_template
			yy_ec := yy_ec_template
			yy_meta := yy_meta_template
			yy_accept := yy_accept_template
			yy_acclist := yy_acclist_template
		end

	yy_execute_action (yy_act: INTEGER)
			-- Execute semantic action.
		do
if yy_act <= 64 then
if yy_act <= 32 then
if yy_act <= 16 then
if yy_act <= 8 then
if yy_act <= 4 then
if yy_act <= 2 then
if yy_act = 1 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 44 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 44")
end
-- Ignore separators
else
	yy_line := yy_line + 1
	yy_column := 1
--|#line 45 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 45")
end
-- Line continuation
end
else
if yy_act = 3 then
	yy_line := yy_line + 1
	yy_column := 1
--|#line 46 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 46")
end
terminate
else
	yy_column := yy_column + 1
--|#line 54 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 54")
end

				process_one_char_symbol (text_item (1))
			
end
end
else
if yy_act <= 6 then
if yy_act = 5 then
	yy_column := yy_column + 2
--|#line 57 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 57")
end

				process_two_char_symbol (text_item (1), text_item (2))
			
else
	yy_column := yy_column + 5
--|#line 63 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 63")
end
last_token := CATCH_CODE
end
else
if yy_act = 7 then
	yy_column := yy_column + 2
--|#line 64 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 64")
end
last_token := LINE_CODE
else
	yy_column := yy_column + 5
--|#line 65 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 65")
end
last_token := DEPTH_CODE
end
end
end
else
if yy_act <= 12 then
if yy_act <= 10 then
if yy_act = 9 then
	yy_column := yy_column + 5
--|#line 66 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 66")
end
last_token := WATCH_CODE
else
	yy_column := yy_column + 4
--|#line 67 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 67")
end
last_token := TYPE_CODE
end
else
if yy_act = 11 then
	yy_column := yy_column + 5
--|#line 68 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 68")
end
last_token := PRINT_CODE
else
	yy_column := yy_column + 4
--|#line 69 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 69")
end
last_token := CONT_CODE
end
end
else
if yy_act <= 14 then
if yy_act = 13 then
	yy_column := yy_column + 2
--|#line 71 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 71")
end
last_token := DG_ASSIGN
else
	yy_column := yy_column + 2
--|#line 72 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 72")
end
last_token := DG_COMMENT
end
else
if yy_act = 15 then
	yy_column := yy_column + 2
--|#line 73 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 73")
end
last_token := DG_PP
else
	yy_column := yy_column + 2
--|#line 74 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 74")
end
last_token := DG_ARROW
end
end
end
end
else
if yy_act <= 24 then
if yy_act <= 20 then
if yy_act <= 18 then
if yy_act = 17 then
	yy_column := yy_column + 2
--|#line 75 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 75")
end
last_token := DG_LBB
else
	yy_column := yy_column + 2
--|#line 76 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 76")
end
last_token := DG_LCC
end
else
if yy_act = 19 then
	yy_column := yy_column + 2
--|#line 77 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 77")
end
last_token := DG_RCC
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 79 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 79")
end
	-- |
				last_token := DG_PLACEHOLDER
				last_string_value := text
			
end
end
else
if yy_act <= 22 then
if yy_act = 21 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 83 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 83")
end
	
				last_token := DG_FORMAT
				last_string_value := text
			
else
	yy_column := yy_column + 4
--|#line 90 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 90")
end
last_token := E_FROM
end
else
if yy_act = 23 then
	yy_column := yy_column + 4
--|#line 91 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 91")
end
last_token := E_WHEN
else
	yy_column := yy_column + 2
--|#line 92 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 92")
end
last_token := E_IF
end
end
end
else
if yy_act <= 28 then
if yy_act <= 26 then
if yy_act = 25 then
	yy_column := yy_column + 5
--|#line 93 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 93")
end
last_token := E_CLASS
else
	yy_column := yy_column + 2
--|#line 94 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 94")
end
last_token := E_DO
end
else
if yy_act = 27 then
	yy_column := yy_column + 4
--|#line 95 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 95")
end
last_token := E_LOOP
else
	yy_column := yy_column + 4
--|#line 96 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 96")
end
last_token := E_LIKE
end
end
else
if yy_act <= 30 then
if yy_act = 29 then
	yy_column := yy_column + 3
--|#line 97 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 97")
end
last_token := E_ALL
else
	yy_column := yy_column + 5
--|#line 98 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 98")
end
last_token := E_DEBUG
end
else
if yy_act = 31 then
	yy_column := yy_column + 3
--|#line 99 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 99")
end
last_token := E_OLD
else
	yy_column := yy_column + 6
--|#line 100 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 100")
end
last_token := E_CREATE
end
end
end
end
end
else
if yy_act <= 48 then
if yy_act <= 40 then
if yy_act <= 36 then
if yy_act <= 34 then
if yy_act = 33 then
	yy_column := yy_column + 4
--|#line 101 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 101")
end
last_token := E_ONCE
else
	yy_column := yy_column + 2
--|#line 102 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 102")
end
last_token := E_OR
end
else
if yy_act = 35 then
	yy_column := yy_column + 3
--|#line 103 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 103")
end
last_token := E_XOR
else
	yy_column := yy_column + 3
--|#line 104 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 104")
end
last_token := E_AND
end
end
else
if yy_act <= 38 then
if yy_act = 37 then
	yy_column := yy_column + 7
--|#line 105 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 105")
end
last_token := E_IMPLIES
else
	yy_column := yy_column + 3
--|#line 106 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 106")
end
last_token := E_NOT
end
else
if yy_act = 39 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 110 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 110")
end

                                last_token := E_IDENTIFIER
                                last_string_value := text
			
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 114 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 114")
end

				last_token := DG_INLINE
				last_string_value := text
			
end
end
end
else
if yy_act <= 44 then
if yy_act <= 42 then
if yy_act = 41 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 120 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 120")
end

				last_token := DG_ALIAS
				last_string_value := text
			
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 125 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 125")
end

				last_token := DG_CLOSURE
				last_string_value := text
			
end
else
if yy_act = 43 then
	yy_column := yy_column + 1
--|#line 132 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 132")
end

				last_token := E_FREEOP
                                last_string_value := text
			
else
	yy_column := yy_column + 2
--|#line 133 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 133")
end

				last_token := E_FREEOP
                                last_string_value := text
			
end
end
else
if yy_act <= 46 then
if yy_act = 45 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 134 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 134")
end

				last_token := E_FREEOP
                                last_string_value := text
			
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 135 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 135")
end

				last_token := E_FREEOP
                                last_string_value := text
			
end
else
if yy_act = 47 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 136 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 136")
end

				last_token := E_FREEOP
                                last_string_value := text
			
else
	yy_end := yy_end - 1
	yy_column := yy_column + 1
--|#line 137 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 137")
end

				last_token := E_FREEOP
                                last_string_value := text
			
end
end
end
end
else
if yy_act <= 56 then
if yy_act <= 52 then
if yy_act <= 50 then
if yy_act = 49 then
	yy_end := yy_end - 1
	yy_column := yy_column + 2
--|#line 138 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 138")
end

				last_token := E_FREEOP
                                last_string_value := text
			
else
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 139 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 139")
end

				last_token := E_FREEOP
                                last_string_value := text
			
end
else
if yy_act = 51 then
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 140 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 140")
end

				last_token := E_FREEOP
                                last_string_value := text
			
else
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 141 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 141")
end

				last_token := E_FREEOP
                                last_string_value := text
			
end
end
else
if yy_act <= 54 then
if yy_act = 53 then
	yy_column := yy_column + 3
--|#line 148 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 148")
end
last_token := E_CHARACTER; last_character_value := text_item (2)
else
	yy_column := yy_column + 4
--|#line 149 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 149")
end
last_token := E_CHARACTER; last_character_value := '%A'
end
else
if yy_act = 55 then
	yy_column := yy_column + 4
--|#line 150 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 150")
end
last_token := E_CHARACTER; last_character_value := '%B'
else
	yy_column := yy_column + 4
--|#line 151 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 151")
end
last_token := E_CHARACTER; last_character_value := '%C'
end
end
end
else
if yy_act <= 60 then
if yy_act <= 58 then
if yy_act = 57 then
	yy_column := yy_column + 4
--|#line 152 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 152")
end
last_token := E_CHARACTER; last_character_value := '%D'
else
	yy_column := yy_column + 4
--|#line 153 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 153")
end
last_token := E_CHARACTER; last_character_value := '%F'
end
else
if yy_act = 59 then
	yy_column := yy_column + 4
--|#line 154 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 154")
end
last_token := E_CHARACTER; last_character_value := '%H'
else
	yy_column := yy_column + 4
--|#line 155 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 155")
end
last_token := E_CHARACTER; last_character_value := '%L'
end
end
else
if yy_act <= 62 then
if yy_act = 61 then
	yy_column := yy_column + 4
--|#line 156 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 156")
end
last_token := E_CHARACTER; last_character_value := '%N'
else
	yy_column := yy_column + 4
--|#line 157 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 157")
end
last_token := E_CHARACTER; last_character_value := '%Q'
end
else
if yy_act = 63 then
	yy_column := yy_column + 4
--|#line 158 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 158")
end
last_token := E_CHARACTER; last_character_value := '%R'
else
	yy_column := yy_column + 4
--|#line 159 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 159")
end
last_token := E_CHARACTER; last_character_value := '%S'
end
end
end
end
end
end
else
if yy_act <= 96 then
if yy_act <= 80 then
if yy_act <= 72 then
if yy_act <= 68 then
if yy_act <= 66 then
if yy_act = 65 then
	yy_column := yy_column + 4
--|#line 160 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 160")
end
last_token := E_CHARACTER; last_character_value := '%T'
else
	yy_column := yy_column + 4
--|#line 161 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 161")
end
last_token := E_CHARACTER; last_character_value := '%U'
end
else
if yy_act = 67 then
	yy_column := yy_column + 4
--|#line 162 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 162")
end
last_token := E_CHARACTER; last_character_value := '%V'
else
	yy_column := yy_column + 4
--|#line 163 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 163")
end
last_token := E_CHARACTER; last_character_value := '%%'
end
end
else
if yy_act <= 70 then
if yy_act = 69 then
	yy_column := yy_column + 4
--|#line 164 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 164")
end
last_token := E_CHARACTER; last_character_value := '%''
else
	yy_column := yy_column + 4
--|#line 165 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 165")
end
last_token := E_CHARACTER; last_character_value := '%"'
end
else
if yy_act = 71 then
	yy_column := yy_column + 4
--|#line 166 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 166")
end
last_token := E_CHARACTER; last_character_value := '%('
else
	yy_column := yy_column + 4
--|#line 167 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 167")
end
last_token := E_CHARACTER; last_character_value := '%)'
end
end
end
else
if yy_act <= 76 then
if yy_act <= 74 then
if yy_act = 73 then
	yy_column := yy_column + 4
--|#line 168 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 168")
end
last_token := E_CHARACTER; last_character_value := '%<'
else
	yy_column := yy_column + 4
--|#line 169 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 169")
end
last_token := E_CHARACTER; last_character_value := '%>'
end
else
if yy_act = 75 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 170 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 170")
end

                                code_ := text_substring (4, text_count - 2).to_integer
                                if code_ > Platform.Maximum_character_code then
                                        last_token := E_CHARERR
                                else
                                        last_token := E_CHARACTER
                                        last_character_value := INTEGER_.to_character (code_)
                                end
                        
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 179 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 179")
end

                                last_token := E_STRING
                                last_string_value := text_substring (2, text_count - 1)
                        
end
end
else
if yy_act <= 78 then
if yy_act = 77 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 183 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 183")
end

                                if text_count > 1 then
                                        eif_buffer.append_string (text_substring (2, text_count))
                                end
                                set_start_condition (IS_STR)
                        
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 192 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 192")
end

                                last_token := E_INTEGER
                                last_integer_value := text.to_integer
			
end
else
if yy_act = 79 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 200 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 200")
end

                                last_token := E_INTEGER
                                last_integer_value := text.to_integer
                        
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 204 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 204")
end

                                last_token := E_INTEGER
                                str_ := text
                                nb_ := text_count
                                from 
					i_ := 1 
				until i_ > nb_ loop
                                        char_ := str_[i_]
                                        if char_ /= '_' then
                                                eif_buffer.append_character (char_)
                                        end
                                        i_ := i_ + 1
                                end
                                last_integer_value := eif_buffer.to_integer
                                        eif_buffer.wipe_out
                        
end
end
end
end
else
if yy_act <= 88 then
if yy_act <= 84 then
if yy_act <= 82 then
if yy_act = 81 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 220 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 220")
end

                                last_token := E_INTEGER
                                last_integer_value := text.to_integer
                        
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 224 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 224")
end
last_token := E_INTERR  -- Catch-all rule (no backing up)
end
else
if yy_act = 83 then
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 228 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 228")
end

                                                last_token := E_REAL
                                                last_double_value := text.to_double
                                        
else
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 229 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 229")
end

                                                last_token := E_REAL
                                                last_double_value := text.to_double
                                        
end
end
else
if yy_act <= 86 then
if yy_act = 85 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 230 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 230")
end

                                                last_token := E_REAL
                                                last_double_value := text.to_double
                                        
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 231 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 231")
end

                                                last_token := E_REAL
                                                last_double_value := text.to_double
                                        
end
else
if yy_act = 87 then
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 235 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 235")
end

                                                last_token := E_REAL
                                                str_ := text
                                                nb_ := text_count
                                                from 
							i_ := 1 
						until i_ > nb_ loop                                                        char_ := str_[i_]
                                                        if char_ /= '_' then
                                                                eif_buffer.append_character (char_)
                                                        end
                                                        i_ := i_ + 1
                                                end
                                                last_double_value := eif_buffer.to_double
                                                eif_buffer.wipe_out
                                        
else
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 236 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 236")
end

                                                last_token := E_REAL
                                                str_ := text
                                                nb_ := text_count
                                                from 
							i_ := 1 
						until i_ > nb_ loop                                                        char_ := str_[i_]
                                                        if char_ /= '_' then
                                                                eif_buffer.append_character (char_)
                                                        end
                                                        i_ := i_ + 1
                                                end
                                                last_double_value := eif_buffer.to_double
                                                eif_buffer.wipe_out
                                        
end
end
end
else
if yy_act <= 92 then
if yy_act <= 90 then
if yy_act = 89 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 237 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 237")
end

                                                last_token := E_REAL
                                                str_ := text
                                                nb_ := text_count
                                                from 
							i_ := 1 
						until i_ > nb_ loop                                                        char_ := str_[i_]
                                                        if char_ /= '_' then
                                                                eif_buffer.append_character (char_)
                                                        end
                                                        i_ := i_ + 1
                                                end
                                                last_double_value := eif_buffer.to_double
                                                eif_buffer.wipe_out
                                        
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 238 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 238")
end

                                                last_token := E_REAL
                                                str_ := text
                                                nb_ := text_count
                                                from 
							i_ := 1 
						until i_ > nb_ loop                                                        char_ := str_[i_]
                                                        if char_ /= '_' then
                                                                eif_buffer.append_character (char_)
                                                        end
                                                        i_ := i_ + 1
                                                end
                                                last_double_value := eif_buffer.to_double
                                                eif_buffer.wipe_out
                                        
end
else
if yy_act = 91 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 256 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 256")
end

				last_token := DG_UP_FRAME
				last_integer_value := text_count
			
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 260 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 260")
end

				last_token := DG_UP_FRAME
				tmp_str.copy(text)
				tmp_str.remove(1)
				tmp_str.remove(tmp_str.count)
				last_integer_value := tmp_str.to_integer
			
end
end
else
if yy_act <= 94 then
if yy_act = 93 then
	yy_column := yy_column + 1
--|#line 267 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 267")
end
last_token := text_item (1).code
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 272 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 272")
end
eif_buffer.append_string (text)
end
else
if yy_act = 95 then
	yy_column := yy_column + 2
--|#line 273 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 273")
end
eif_buffer.append_character ('%A')
else
	yy_column := yy_column + 2
--|#line 274 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 274")
end
eif_buffer.append_character ('%B')
end
end
end
end
end
else
if yy_act <= 112 then
if yy_act <= 104 then
if yy_act <= 100 then
if yy_act <= 98 then
if yy_act = 97 then
	yy_column := yy_column + 2
--|#line 275 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 275")
end
eif_buffer.append_character ('%C')
else
	yy_column := yy_column + 2
--|#line 276 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 276")
end
eif_buffer.append_character ('%D')
end
else
if yy_act = 99 then
	yy_column := yy_column + 2
--|#line 277 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 277")
end
eif_buffer.append_character ('%F')
else
	yy_column := yy_column + 2
--|#line 278 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 278")
end
eif_buffer.append_character ('%H')
end
end
else
if yy_act <= 102 then
if yy_act = 101 then
	yy_column := yy_column + 2
--|#line 279 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 279")
end
eif_buffer.append_character ('%L')
else
	yy_column := yy_column + 2
--|#line 280 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 280")
end
eif_buffer.append_character ('%N')
end
else
if yy_act = 103 then
	yy_column := yy_column + 2
--|#line 281 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 281")
end
eif_buffer.append_character ('%Q')
else
	yy_column := yy_column + 2
--|#line 282 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 282")
end
eif_buffer.append_character ('%R')
end
end
end
else
if yy_act <= 108 then
if yy_act <= 106 then
if yy_act = 105 then
	yy_column := yy_column + 2
--|#line 283 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 283")
end
eif_buffer.append_character ('%S')
else
	yy_column := yy_column + 2
--|#line 284 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 284")
end
eif_buffer.append_character ('%T')
end
else
if yy_act = 107 then
	yy_column := yy_column + 2
--|#line 285 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 285")
end
eif_buffer.append_character ('%U')
else
	yy_column := yy_column + 2
--|#line 286 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 286")
end
eif_buffer.append_character ('%V')
end
end
else
if yy_act <= 110 then
if yy_act = 109 then
	yy_column := yy_column + 2
--|#line 287 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 287")
end
eif_buffer.append_character ('%%')
else
	yy_column := yy_column + 2
--|#line 288 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 288")
end
eif_buffer.append_character ('%'')
end
else
if yy_act = 111 then
	yy_column := yy_column + 2
--|#line 289 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 289")
end
eif_buffer.append_character ('%"')
else
	yy_column := yy_column + 2
--|#line 290 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 290")
end
eif_buffer.append_character ('%(')
end
end
end
end
else
if yy_act <= 120 then
if yy_act <= 116 then
if yy_act <= 114 then
if yy_act = 113 then
	yy_column := yy_column + 2
--|#line 291 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 291")
end
eif_buffer.append_character ('%)')
else
	yy_column := yy_column + 2
--|#line 292 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 292")
end
eif_buffer.append_character ('%<')
end
else
if yy_act = 115 then
	yy_column := yy_column + 2
--|#line 293 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 293")
end
eif_buffer.append_character ('%>')
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 294 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 294")
end

				code_ := text_substring (3, text_count - 1).to_integer
				if (code_ > Platform.Maximum_character_code) then
					last_token := E_STRERR
				else
					eif_buffer.append_character (INTEGER_.to_character (code_))
				end
			
end
end
else
if yy_act <= 118 then
if yy_act = 117 then
yy_set_line_column
--|#line 302 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 302")
end
	-- Catch-all rules (no backing up)
						last_token := E_STRERR
						set_start_condition (INITIAL)
				
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 303 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 303")
end
	-- Catch-all rules (no backing up)
						last_token := E_STRERR
						set_start_condition (INITIAL)
				
end
else
if yy_act = 119 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 312 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 312")
end
 
		 	if attached keyword(text, commands, once "command") as lk then
				last_key := lk
				command_name := lk.name
				command_code := lk.code
				last_token := command_code
			end
			inspect command_code
			when BREAK_CODE then
				set_start_condition(BREAK)
			else
				set_start_condition(PARAM)
			end
		
else
	yy_column := yy_column + 1
--|#line 326 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 326")
end

			last_token := NO_CODE
			command_code := last_token
		
end
end
end
else
if yy_act <= 124 then
if yy_act <= 122 then
if yy_act = 121 then
	yy_column := yy_column + 3
--|#line 333 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 333")
end
last_token := E_ALL
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 334 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 334")
end
 
		 	if attached keyword(text, breaks, once "keyword") as lk then
				last_key := lk
				last_token := lk.code
				shorten_break_keys(last_token)
			end
			set_start_condition(PARAM)
		
end
else
if yy_act = 123 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
--|#line 342 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 342")
end

			last_token := E_INTEGER
			last_integer_value := text.to_integer
		
else
	yy_column := yy_column + 1
--|#line 347 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 347")
end
last_token := text[1].code
end
end
else
if yy_act <= 126 then
if yy_act = 125 then
	yy_column := yy_column + 2
--|#line 348 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 348")
end
last_token := DG_COMMENT
else
yy_set_line_column
--|#line 350 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 350")
end
default_action
end
else
yy_set_line_column
--|#line 0 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 0")
end
last_token := yyError_token
fatal_error ("scanner jammed")
end
end
end
end
end
end
		end

	yy_execute_eof_action (yy_sc: INTEGER)
			-- Execute EOF semantic action.
		do
			inspect yy_sc
when 0, 2 then
--|#line 0 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 0")
end
terminate
when 1 then
--|#line 0 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 0")
end
	-- Catch-all rules (no backing up)
						last_token := E_STRERR
						set_start_condition (INITIAL)
				
			else
				terminate
			end
		end

feature {NONE} -- Table templates

	yy_nxt_template: SPECIAL [INTEGER]
		local
			an_array: ARRAY [INTEGER]
		once
			create an_array.make_filled (0, 0, 1317)
			yy_nxt_template_1 (an_array)
			yy_nxt_template_2 (an_array)
			Result := yy_fixed_array (an_array)
		end

	yy_nxt_template_1 (an_array: ARRAY [INTEGER])
		do
			yy_array_subcopy (an_array, <<
			    0,   10,   11,   12,   10,   10,   10,   13,   10,   10,
			   10,   10,   10,   13,   10,   13,   14,   13,   10,   10,
			   10,   10,   13,   10,   13,   13,   13,   15,   15,   15,
			   15,   15,   15,   15,   15,   15,   15,   15,   15,   15,
			   15,   15,   15,   15,   15,   15,   15,   15,   15,   15,
			   15,   15,   10,   10,   13,   13,   15,   15,   15,   15,
			   15,   15,   15,   15,   15,   15,   15,   15,   15,   15,
			   15,   15,   15,   15,   15,   15,   15,   15,   15,   10,
			   10,   10,   17,   17,   17,   17,   18,  297,   18,   19,
			   20,   12,   21,   22,   23,   24,   25,   26,   19,   19,

			   23,   27,   19,   28,   29,   30,   31,   32,   33,   34,
			   35,   23,   36,   24,   25,   37,   38,   39,   40,   38,
			   41,   38,   38,   42,   38,   38,   43,   38,   44,   45,
			   46,   38,   38,   38,   47,   38,   38,   48,   49,   38,
			   50,   51,   52,   53,   37,   38,   39,   40,   38,   41,
			   38,   38,   42,   38,   38,   43,   38,   44,   45,   46,
			   38,   38,   47,   38,   48,   49,   38,   54,   55,   23,
			   56,   57,   58,   56,   56,   56,   56,   56,   56,   56,
			   56,   56,   59,   59,   60,   61,   56,   56,   62,   62,
			   56,   56,   56,   56,   56,   56,   63,   64,   64,   64,

			   64,   64,   64,   64,   64,   64,   64,   64,   64,   64,
			   64,   64,   64,   64,   64,   64,   64,   64,   64,   64,
			   64,   56,   56,   56,   56,   63,   64,   64,   64,   64,
			   64,   64,   64,   64,   64,   64,   64,   64,   64,   64,
			   64,   64,   64,   64,   64,   64,   64,   64,   56,   56,
			   56,   69,   94,   94,   70,  279,   71,   72,   73,   98,
			   98,  102,   95,   95,   74,   95,  106,  272,  125,   75,
			  103,   76,  106,  303,   77,   78,   79,   80,  123,   81,
			  104,   82,  105,  105,  105,   83,  207,   84,  124,  130,
			   85,   86,   87,   88,   89,   90,  125,  108,  290,  109,

			  109,  110,  108,  138,  109,  109,  110,  123,  108,  111,
			  110,  110,  110,  116,  111,  117,  128,  124,  130,  126,
			  207,  118,  129,  119,  265,  134,  127,  135,  153,  153,
			  106,  112,  138,  131,  120,  132,  113,  121,  111,  133,
			  122,  113,  116,  111,  117,  128,  150,  113,  126,  118,
			  136,  129,  119,  134,  135,  127,  192,  137,  112,  140,
			  140,  188,  131,  120,  132,  240,  121,  133,  122,  142,
			  143,  143,  148,  148,  148,  150,  152,  152,  152,  136,
			  155,  155,   98,   98,  239,  192,  137,  179,  179,  179,
			  338,  188,  188,  193,  141,  108,  338,  187,  187,  187,

			  180,  191,  191,  191,  189,  238,  142,  157,  194,  237,
			  158,  204,  159,  160,  161,  195,  196,  148,  148,  148,
			  162,  236,  193,  197,  181,  163,  235,  164,  234,  180,
			  165,  166,  167,  168,  113,  169,  194,  170,  142,  204,
			  183,  171,  233,  172,  195,  196,  173,  174,  175,  176,
			  177,  178,  197,  198,  338,  184,  184,  184,  200,  108,
			  201,  186,  186,  187,  202,  203,  205,  199,  185,  232,
			  206,  111,  208,  231,  209,  210,  230,  211,  140,  140,
			  140,  215,  198,  142,  142,  142,  229,  200,  228,  201,
			  143,  143,  143,  202,  203,  205,  199,  185,  113,  206,

			  111,  208,  209,  253,  210,  211,  217,  152,  152,  152,
			  215,  218,  218,  227,  212,  224,  224,  224,  226,  225,
			  142,  241,  241,  241,  242,  223,  242,  214,  254,  243,
			  243,  243,  253,  222,  180,  244,  244,  244,  245,  245,
			  245,  248,  255,  248,  256,  259,  249,  249,  249,  257,
			  108,  246,  250,  250,  251,  258,  254,  108,  181,  251,
			  251,  251,  111,  180,  252,  252,  252,  221,  260,  261,
			  255,  262,  220,  256,  259,  247,  263,  257,  264,  266,
			  246,  267,  219,  258,  142,  268,  268,  216,  141,  113,
			  282,  111,  269,  224,  224,  224,  113,  260,  261,  151,

			  262,  142,  270,  270,  270,  263,  156,  264,  266,  283,
			  267,  243,  243,  243,   96,  180,  271,  271,  271,  282,
			   92,  142,  273,  273,  273,  274,  274,  274,  275,  285,
			  275,  151,   65,  276,  276,  276,  286,  283,  246,  181,
			  277,  277,  277,  284,  180,  249,  249,  249,  278,  278,
			  278,  287,  280,  272,  250,  250,  251,  280,  285,  251,
			  251,  251,  247,  289,  111,  286,  288,  246,  281,  281,
			  281,  284,  268,  268,  268,  270,  270,  270,   66,  147,
			  287,  292,  292,  292,   65,  279,  146,  145,  291,  106,
			  139,  142,  289,  111,  288,  106,  142,  293,  293,  293,

			  294,  294,  294,  106,  114,  142,  295,  295,  295,  214,
			  276,  276,  276,  296,  296,  296,  183,  291,  272,  246,
			  298,  298,  298,  299,  299,  299,  300,  300,  300,  304,
			  101,  295,  295,  295,  100,  302,   96,  142,  142,  142,
			  305,  308,  305,  247,  301,  306,  306,  306,  246,   92,
			  297,  306,  306,  306,  307,  307,  307,   65,  304,   66,
			  279,   65,  295,  295,  295,  181,  310,  310,  310,  320,
			  308,  338,  338,  301,  113,  309,  311,  311,  311,  312,
			  312,  312,  313,  313,  313,  314,  314,  314,  272,  315,
			  317,  315,  338,  338,  313,  313,  313,  320,  306,  306,

			  306,  338,  338,  297,  309,  318,  318,  318,  306,  306,
			  306,  321,  321,  321,  327,  322,  338,  322,  319,  279,
			  323,  323,  323,  324,  338,  324,  338,  338,  325,  325,
			  325,  325,  325,  325,  326,  326,  326,  338,  247,  313,
			  313,  313,  338,  327,  328,  328,  328,  319,  313,  313,
			  313,  329,  329,  329,  330,  338,  330,  338,  338,  331,
			  331,  331,  338,  338,  327,  323,  323,  323,  297,  332,
			  332,  332,  325,  325,  325,  325,  325,  325,  333,  333,
			  333,  312,  312,  312,  334,  338,  334,  338,  247,  335,
			  335,  335,  338,  327,  327,  331,  331,  331,  336,  336,

			  336,  321,  321,  321,  338,  338,  272,  335,  335,  335,
			  337,  337,  337,  328,  328,  328,  338,  338,  247,  333,
			  333,  333,  338,  327,  154,  154,  338,  107,  154,  154,
			  154,  107,  338,  338,  154,  279,  338,  338,  272,  107,
			  107,  107,  107,  107,  190,  190,  190,  297,  190,  190,
			  279,  338,  338,  338,  338,  190,  297,   16,   16,   16,
			   16,   16,   16,   16,   16,   16,   16,   16,   16,   16,
			   16,   16,   16,   16,   16,   16,   16,   16,   16,   16,
			   67,   67,   67,   67,   67,   67,  338,   67,   67,   67,
			   67,   67,   68,  338,  338,  338,   68,   68,   68,   68, yy_Dummy>>,
			1, 1000, 0)
		end

	yy_nxt_template_2 (an_array: ARRAY [INTEGER])
		do
			yy_array_subcopy (an_array, <<
			   68,   68,   68,   68,   68,   68,   68,   68,   68,   68,
			   68,   68,   68,   68,   68,   91,  338,   91,  338,   91,
			   91,   91,   91,   91,   91,   91,   91,   91,   91,   91,
			   91,   91,   91,   91,   91,   91,   91,   91,   93,   93,
			  338,  338,   93,   93,   93,   93,   93,   93,   93,   93,
			   93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
			   93,   97,   97,  338,  338,   97,   97,   97,   97,   97,
			   97,   97,   97,   97,   97,   97,   97,   97,   97,   97,
			   97,   97,   97,   97,   99,  338,   99,   99,  338,   99,
			   99,   99,   99,   99,   99,   99,   99,   99,   99,   99,

			   99,   99,   99,   99,   99,   99,   99,  115,  115,  115,
			  338,  115,  115,  115,  115,  115,  115,  115,  115,  115,
			  115,  115,  115,  144,  144,  144,  338,  144,  144,  144,
			  144,  144,  144,  144,  144,  144,  144,  144,  144,  149,
			  149,  149,  149,  149,  149,  338,  149,  149,  149,  149,
			  149,  182,  182,  182,  182,  182,  338,  182,  182,  182,
			  182,  182,  182,  182,  182,  182,  182,  182,  182,  182,
			  182,  182,  182,  182,  213,  213,  213,  338,  213,  213,
			  213,  213,  213,  213,  213,  213,  213,  213,  213,  213,
			  154,  154,  338,  338,  154,  154,  154,  154,  154,  154,

			  154,  154,  154,  154,  154,  154,  154,  154,  154,  154,
			  154,  154,  154,  316,  316,  316,  316,  316,  338,  316,
			  316,  316,  316,  316,  316,  316,  316,  316,  316,  316,
			  316,  316,  316,  316,  316,  316,    9,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,

			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338, yy_Dummy>>,
			1, 318, 1000)
		end

	yy_chk_template: SPECIAL [INTEGER]
		local
			an_array: ARRAY [INTEGER]
		once
			create an_array.make_filled (0, 0, 1317)
			yy_chk_template_1 (an_array)
			yy_chk_template_2 (an_array)
			Result := yy_fixed_array (an_array)
		end

	yy_chk_template_1 (an_array: ARRAY [INTEGER])
		do
			yy_array_subcopy (an_array, <<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    3,    3,    4,    4,    3,  333,    4,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,

			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    5,    5,    5,    5,    5,    5,    5,    5,    5,    5,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,

			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,   18,   22,   22,   18,  328,   18,   18,   18,   25,
			   25,   28,   22,   22,   18,   22,   30,  321,   41,   18,
			   28,   18,   30,  284,   18,   18,   18,   18,   40,   18,
			   29,   18,   29,   29,   29,   18,  134,   18,   40,   44,
			   18,   18,   18,   18,   18,   18,   41,   31,  269,   31,

			   31,   31,   32,   49,   32,   32,   32,   40,   33,   31,
			   33,   33,   33,   37,   32,   37,   43,   40,   44,   42,
			  134,   37,   43,   39,  208,   46,   42,   47,   93,   93,
			   30,   31,   49,   45,   39,   45,   31,   39,   31,   45,
			   39,   32,   37,   32,   37,   43,   63,   33,   42,   37,
			   48,   43,   39,   46,   47,   42,  116,   48,   31,   52,
			   52,  189,   45,   39,   45,  178,   39,   45,   39,   53,
			   53,   53,   62,   62,   62,   63,   74,   74,   74,   48,
			   95,   95,   97,   97,  177,  116,   48,  105,  105,  105,
			  107,  111,  111,  117,   52,  110,  107,  110,  110,  110,

			  105,  113,  113,  113,  111,  176,   53,  100,  119,  175,
			  100,  130,  100,  100,  100,  120,  121,  148,  148,  148,
			  100,  174,  117,  122,  105,  100,  173,  100,  172,  105,
			  100,  100,  100,  100,  110,  100,  119,  100,  113,  130,
			  108,  100,  171,  100,  120,  121,  100,  100,  100,  100,
			  100,  100,  122,  123,  107,  108,  108,  108,  125,  109,
			  127,  109,  109,  109,  128,  129,  131,  123,  108,  170,
			  132,  109,  135,  169,  136,  137,  168,  138,  140,  140,
			  140,  150,  123,  142,  142,  142,  167,  125,  166,  127,
			  143,  143,  143,  128,  129,  131,  123,  108,  109,  132,

			  109,  135,  136,  194,  137,  138,  152,  152,  152,  152,
			  150,  154,  154,  165,  140,  162,  162,  162,  164,  163,
			  142,  179,  179,  179,  180,  161,  180,  143,  195,  180,
			  180,  180,  194,  160,  179,  181,  181,  181,  184,  184,
			  184,  185,  196,  185,  197,  200,  185,  185,  185,  198,
			  186,  184,  186,  186,  186,  199,  195,  187,  179,  187,
			  187,  187,  186,  179,  191,  191,  191,  159,  201,  202,
			  196,  203,  158,  197,  200,  184,  206,  198,  207,  209,
			  184,  210,  157,  199,  214,  214,  214,  151,  141,  186,
			  253,  186,  224,  224,  224,  224,  187,  201,  202,  104,

			  203,  191,  241,  241,  241,  206,   99,  207,  209,  254,
			  210,  242,  242,  242,   96,  241,  243,  243,  243,  253,
			   91,  214,  244,  244,  244,  245,  245,  245,  246,  257,
			  246,   66,   65,  246,  246,  246,  258,  254,  245,  241,
			  247,  247,  247,  256,  241,  248,  248,  248,  249,  249,
			  249,  260,  250,  243,  250,  250,  250,  251,  257,  251,
			  251,  251,  245,  266,  250,  258,  264,  245,  252,  252,
			  252,  256,  268,  268,  268,  270,  270,  270,   61,   60,
			  260,  271,  271,  271,   57,  249,   55,   54,  270,   51,
			   50,  250,  266,  250,  264,   36,  251,  272,  272,  272,

			  273,  273,  273,   35,   34,  252,  274,  274,  274,  268,
			  275,  275,  275,  276,  276,  276,  280,  270,  271,  274,
			  277,  277,  277,  278,  278,  278,  279,  279,  279,  287,
			   27,  280,  280,  280,   26,  281,   24,  281,  281,  281,
			  291,  294,  291,  274,  280,  291,  291,  291,  274,   21,
			  276,  292,  292,  292,  293,  293,  293,   20,  287,   14,
			  278,   11,  295,  295,  295,  294,  296,  296,  296,  304,
			  294,    9,    0,  280,  281,  295,  297,  297,  297,  298,
			  298,  298,  299,  299,  299,  300,  300,  300,  292,  301,
			  302,  301,    0,    0,  301,  301,  301,  304,  305,  305,

			  305,    0,    0,  296,  295,  302,  302,  302,  306,  306,
			  306,  307,  307,  307,  312,  308,    0,  308,  302,  299,
			  308,  308,  308,  309,    0,  309,    0,    0,  309,  309,
			  309,  310,  310,  310,  311,  311,  311,    0,  312,  313,
			  313,  313,    0,  312,  314,  314,  314,  302,  315,  315,
			  315,  318,  318,  318,  319,    0,  319,    0,    0,  319,
			  319,  319,    0,    0,  318,  322,  322,  322,  310,  323,
			  323,  323,  324,  324,  324,  325,  325,  325,  326,  326,
			  326,  329,  329,  329,  327,    0,  327,    0,  318,  327,
			  327,  327,    0,  318,  329,  330,  330,  330,  331,  331,

			  331,  332,  332,  332,    0,    0,  323,  334,  334,  334,
			  335,  335,  335,  336,  336,  336,    0,    0,  329,  337,
			  337,  337,    0,  329,  350,  350,    0,  346,  350,  350,
			  350,  346,    0,    0,  350,  331,    0,    0,  332,  346,
			  346,  346,  346,  346,  352,  352,  352,  335,  352,  352,
			  336,    0,    0,    0,    0,  352,  337,  339,  339,  339,
			  339,  339,  339,  339,  339,  339,  339,  339,  339,  339,
			  339,  339,  339,  339,  339,  339,  339,  339,  339,  339,
			  340,  340,  340,  340,  340,  340,    0,  340,  340,  340,
			  340,  340,  341,    0,    0,    0,  341,  341,  341,  341, yy_Dummy>>,
			1, 1000, 0)
		end

	yy_chk_template_2 (an_array: ARRAY [INTEGER])
		do
			yy_array_subcopy (an_array, <<
			  341,  341,  341,  341,  341,  341,  341,  341,  341,  341,
			  341,  341,  341,  341,  341,  342,    0,  342,    0,  342,
			  342,  342,  342,  342,  342,  342,  342,  342,  342,  342,
			  342,  342,  342,  342,  342,  342,  342,  342,  343,  343,
			    0,    0,  343,  343,  343,  343,  343,  343,  343,  343,
			  343,  343,  343,  343,  343,  343,  343,  343,  343,  343,
			  343,  344,  344,    0,    0,  344,  344,  344,  344,  344,
			  344,  344,  344,  344,  344,  344,  344,  344,  344,  344,
			  344,  344,  344,  344,  345,    0,  345,  345,    0,  345,
			  345,  345,  345,  345,  345,  345,  345,  345,  345,  345,

			  345,  345,  345,  345,  345,  345,  345,  347,  347,  347,
			    0,  347,  347,  347,  347,  347,  347,  347,  347,  347,
			  347,  347,  347,  348,  348,  348,    0,  348,  348,  348,
			  348,  348,  348,  348,  348,  348,  348,  348,  348,  349,
			  349,  349,  349,  349,  349,    0,  349,  349,  349,  349,
			  349,  351,  351,  351,  351,  351,    0,  351,  351,  351,
			  351,  351,  351,  351,  351,  351,  351,  351,  351,  351,
			  351,  351,  351,  351,  353,  353,  353,    0,  353,  353,
			  353,  353,  353,  353,  353,  353,  353,  353,  353,  353,
			  354,  354,    0,    0,  354,  354,  354,  354,  354,  354,

			  354,  354,  354,  354,  354,  354,  354,  354,  354,  354,
			  354,  354,  354,  355,  355,  355,  355,  355,    0,  355,
			  355,  355,  355,  355,  355,  355,  355,  355,  355,  355,
			  355,  355,  355,  355,  355,  355,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,

			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338, yy_Dummy>>,
			1, 318, 1000)
		end

	yy_base_template: SPECIAL [INTEGER]
		once
			Result := yy_fixed_array (<<
			    0,    0,    0,   79,   81,   88,    0,  169,    0,  771,
			 1236,  759, 1236, 1236,  743,    0,    0, 1236,  247, 1236,
			  755,  745,  250, 1236,  711,  257,  727,  717,  246,  264,
			  249,  281,  286,  292,  681,  680,  672,  275,    0,  296,
			  247,  224,  287,  281,  248,  295,  281,  276,  323,  262,
			  638,  636,  340,  351,  608,  606, 1236,  682, 1236, 1236,
			  664,  662,  354,  308,    0,  630,  615,    0,    0, 1236,
			 1236, 1236, 1236, 1236,  358, 1236, 1236, 1236, 1236, 1236,
			 1236, 1236, 1236, 1236, 1236, 1236, 1236, 1236, 1236, 1236,
			 1236,  616, 1236,  326, 1236,  378,  589,  380, 1236,  597,

			  403, 1236, 1236, 1236,  583,  369, 1236,  373,  437,  443,
			  379,  389,    0,  383, 1236,    0,  318,  363,    0,  362,
			  388,  376,  392,  425,    0,  417,    0,  418,  427,  424,
			  365,  436,  441,    0,  251,  430,  428,  444,  433, 1236,
			  460,  534,  465,  472,    0, 1236, 1236, 1236,  399,    0,
			  443,  584,  489, 1236,  509, 1236, 1236,  573,  563,  558,
			  524,  516,  497,  510,  509,  504,  479,  477,  467,  464,
			  460,  433,  419,  417,  412,  400,  396,  375,  356,  503,
			  511,  517, 1236, 1236,  520,  528,  534,  541, 1236,  346,
			    0,  546,    0,    0,  474,  483,  496,  517,  502,  509,

			  506,  530,  538,  529,    0,    0,  545,  538,  293,  550,
			  541,    0, 1236,    0,  566,    0, 1236, 1236, 1236, 1236,
			 1236, 1236, 1236, 1236,  575, 1236, 1236, 1236, 1236, 1236,
			 1236, 1236, 1236, 1236, 1236, 1236, 1236, 1236, 1236, 1236,
			 1236,  584,  593,  598,  604,  607,  615,  622,  627,  630,
			  636,  641,  650,  556,  564,    0,  597,  596,  602,    0,
			  616,    0,    0,    0,  620,    0,  629,    0,  654,  289,
			  657,  663,  679,  682,  688,  692,  695,  702,  705,  708,
			  713,  719,    0,    0,  242,    0,    0,  698,    0,    0,
			 1236,  727,  733,  736,  710,  744,  748,  758,  761,  764,

			  767,  776,  787,    0,  724,  780,  790,  793,  802,  810,
			  813,  816,  783,  821,  826,  830, 1236, 1236,  833,  841,
			    0,  212,  847,  851,  854,  857,  860,  871,  200,  863,
			  877,  880,  883,   32,  889,  892,  895,  901, 1236,  956,
			  968,  991, 1014, 1037, 1060, 1083,  920, 1099, 1115, 1127,
			  923, 1150,  936, 1166, 1189, 1212, yy_Dummy>>)
		end

	yy_def_template: SPECIAL [INTEGER]
		once
			Result := yy_fixed_array (<<
			    0,  338,    1,  339,  339,  338,    5,  338,    7,  338,
			  338,  338,  338,  338,  338,  340,  341,  338,  338,  338,
			  338,  342,  343,  338,  338,  344,  345,  338,  338,  338,
			  346,  338,  338,  338,  338,  338,  338,  347,  347,  347,
			  347,  347,  347,  347,  347,  347,  347,  347,  347,  347,
			  338,  338,  338,  348,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  349,  349,  338,  338,  340,  341,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  342,  338,  343,  338,  350,  338,  344,  338,  338,

			  338,  338,  338,  338,  338,  338,  338,  346,  351,  338,
			  338,  338,  352,  338,  338,  347,  347,  347,  347,  347,
			  347,  347,  347,  347,  347,  347,  347,  347,  347,  347,
			  347,  347,  347,  347,  347,  347,  347,  347,  347,  338,
			  338,  338,  338,  353,  348,  338,  338,  338,  338,  349,
			  349,  338,  338,  338,  354,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  352,  338,  347,  347,  347,  347,  347,  347,  347,  347,

			  347,  347,  347,  347,  347,  347,  347,  347,  347,  347,
			  347,  347,  338,  353,  338,  349,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  347,  347,  347,  347,  347,  347,  347,
			  347,  347,  347,  347,  347,  347,  347,  347,  353,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  351,  338,  347,  347,  347,  347,  347,  347,  347,  347,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,

			  338,  338,  355,  347,  347,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  347,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,    0,  338,
			  338,  338,  338,  338,  338,  338,  338,  338,  338,  338,
			  338,  338,  338,  338,  338,  338, yy_Dummy>>)
		end

	yy_ec_template: SPECIAL [INTEGER]
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    2,
			    3,    1,    1,    2,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    2,    1,    4,    5,    6,    7,    8,    9,
			   10,   11,   12,   13,   14,   15,   16,   17,   18,   19,
			   20,   20,   20,   20,   20,   20,   20,   20,   21,    1,
			   22,   23,   24,   25,   26,   27,   28,   29,   30,   31,
			   32,   33,   34,   35,   36,   37,   38,   39,   40,   41,
			   42,   43,   44,   45,   46,   47,   48,   49,   50,   51,
			   36,   52,   53,    1,   54,   55,    1,   56,   57,   58,

			   59,   60,   61,   62,   63,   64,   65,   66,   67,   68,
			   69,   70,   71,   65,   72,   73,   74,   75,   65,   76,
			   77,   78,   65,   79,    8,   80,   81,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,

			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1, yy_Dummy>>)
		end

	yy_meta_template: SPECIAL [INTEGER]
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    2,    3,    1,    1,    4,    1,    5,
			    1,    1,    1,    1,    1,    1,    6,    7,    8,    9,
			   10,    1,    1,   11,    1,    1,    1,   12,   12,   13,
			   12,   12,   12,   14,   14,   14,   14,   14,   14,   14,
			   14,   14,   14,   14,   14,   14,   14,   14,   14,   15,
			   16,   17,    1,    1,    1,   18,   19,   19,   19,   19,
			   19,   19,   20,   20,   20,   20,   20,   20,   20,   20,
			   20,   20,   20,   20,   20,   20,   21,   22,   23,    1,
			    1,    7, yy_Dummy>>)
		end

	yy_accept_template: SPECIAL [INTEGER]
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    2,    4,    7,    9,   12,   15,   18,   21,   23,   25,
			   27,   30,   33,   36,   39,   42,   45,   47,   50,   53,
			   55,   58,   62,   66,   70,   72,   75,   78,   81,   84,
			   87,   90,   93,   96,   99,  102,  105,  108,  111,  114,
			  117,  119,  121,  124,  127,  129,  131,  133,  136,  139,
			  142,  145,  147,  150,  153,  156,  157,  157,  158,  159,
			  160,  161,  162,  163,  164,  165,  166,  167,  168,  169,
			  170,  171,  172,  173,  174,  175,  176,  177,  178,  179,
			  180,  181,  182,  183,  184,  185,  186,  187,  188,  189,

			  189,  189,  190,  191,  192,  193,  195,  196,  197,  197,
			  199,  201,  202,  202,  203,  204,  205,  206,  207,  209,
			  210,  211,  212,  213,  214,  216,  217,  219,  220,  221,
			  222,  223,  224,  225,  227,  228,  229,  230,  231,  232,
			  233,  233,  234,  235,  237,  238,  239,  240,  241,  242,
			  243,  244,  244,  245,  246,  247,  248,  249,  249,  249,
			  249,  249,  249,  249,  249,  249,  249,  249,  249,  249,
			  249,  249,  249,  249,  249,  249,  249,  249,  249,  249,
			  251,  251,  251,  252,  254,  256,  257,  259,  261,  262,
			  262,  263,  264,  266,  268,  269,  270,  271,  272,  273,

			  274,  275,  276,  277,  278,  280,  282,  283,  284,  285,
			  286,  287,  289,  290,  291,  292,  294,  295,  297,  298,
			  299,  300,  301,  302,  303,  303,  304,  305,  306,  307,
			  308,  309,  310,  311,  312,  313,  314,  315,  316,  317,
			  318,  319,  321,  321,  323,  323,  325,  325,  325,  325,
			  327,  329,  331,  332,  333,  334,  336,  337,  338,  339,
			  341,  342,  344,  346,  348,  349,  351,  352,  354,  355,
			  355,  356,  358,  358,  358,  360,  360,  364,  364,  366,
			  366,  366,  368,  370,  372,  373,  375,  377,  378,  380,
			  382,  383,  383,  385,  385,  386,  387,  391,  391,  391,

			  393,  393,  394,  394,  396,  397,  397,  398,  398,  398,
			  398,  402,  402,  403,  404,  404,  404,  405,  407,  408,
			  409,  411,  412,  412,  413,  413,  415,  415,  415,  416,
			  417,  417,  418,  419,  421,  421,  423,  424,  426,  426, yy_Dummy>>)
		end

	yy_acclist_template: SPECIAL [INTEGER]
		once
			Result := yy_fixed_array (<<
			    0,  128,  120,  127,    1,  120,  127,    3,  127,  119,
			  120,  127,  119,  120,  127,  119,  120,  127,   94,  117,
			  127,  117,  127,  117,  127,   93,  127,    1,   93,  127,
			   77,   93,  127,   43,   93,  127,    4,   93,  127,   20,
			   93,  127,   47,   93,  127,   93,  127,    4,   93,  127,
			    4,   93,  127,   93,  127,    4,   93,  127,   79,   82,
			   93,  127,   79,   82,   93,  127,   79,   82,   93,  127,
			   93,  127,    4,   93,  127,    4,   93,  127,   39,   93,
			  127,   39,   93,  127,   39,   93,  127,   39,   93,  127,
			   39,   93,  127,   39,   93,  127,   39,   93,  127,   39,

			   93,  127,   39,   93,  127,   39,   93,  127,   39,   93,
			  127,   39,   93,  127,   39,   93,  127,   93,  127,   93,
			  127,    4,   93,  127,   82,   93,  127,   93,  127,   93,
			  127,  126,  127,    1,  126,  127,    3,  126,  127,  124,
			  126,  127,  124,  126,  127,  126,  127,  123,  126,  127,
			  122,  126,  127,  122,  126,  127,    1,  119,   94,  111,
			  109,  110,  112,  113,  118,  114,  115,   95,   96,   97,
			   98,   99,  100,  101,  102,  103,  104,  105,  106,  107,
			  108,   77,   76,   46,   48,   44,   20,   47,   52,   15,
			   14,   16,    5,   86,   90,    5,   21,   79,   82,   79,

			   82, -205,   82,   13,   39,   39,   39,    7,   39,   39,
			   39,   39,   39,   39,   26,   39,   39,   24,   39,   39,
			   39,   39,   39,   39,   39,   34,   39,   39,   39,   39,
			   39,   39,   17,   91,   82,   42,   82,   41,   18,   19,
			  125,  123,  122,  122,  118,   51,   45,   49,   53,   86,
			   90,   84,   83,   84,   86,   90,   84,   79,   82,   79,
			   82,  -78,   81,   82,   29,   39,   36,   39,   39,   39,
			   39,   39,   39,   39,   39,   39,   39,   39,   38,   39,
			   31,   39,   39,   39,   39,   39,   39,   35,   39,   92,
			   40,   82,  121,  122,    2,  116,  118,   50,   70,   68,

			   69,   71,   72,   73,   74,   54,   55,   56,   57,   58,
			   59,   60,   61,   62,   63,   64,   65,   66,   67,   86,
			   90,   86,   90,   86,   90,   85,   89,   79,   82,   79,
			   82,   82,   39,   39,   12,   39,   39,   39,   39,   22,
			   39,   39,   28,   39,   27,   39,   33,   39,   39,   10,
			   39,   39,   23,   39,   82,   86,   86,   90,   86,   90,
			   85,   86,   89,   90,   85,   89,   80,   82,    6,   39,
			   25,   39,   39,   30,   39,    8,   39,   39,   11,   39,
			    9,   39,   75,   86,   90,   90,   86,   85,   86,   89,
			   90,   85,   89,   84,   32,   39,   39,   86,   85,   86,

			   89,   90,   90,   85,   88,   87,   88,   90,   88,   37,
			   39,   90,   90,   85,   86,   89,   90,   89,   90,   89,
			   90,   89,   90,   89,   89,   90, yy_Dummy>>)
		end

feature {NONE} -- Constants

	yyJam_base: INTEGER = 1236
			-- Position in `yy_nxt'/`yy_chk' tables
			-- where default jam table starts

	yyJam_state: INTEGER = 338
			-- State id corresponding to jam state

	yyTemplate_mark: INTEGER = 339
			-- Mark between normal states and templates

	yyNull_equiv_class: INTEGER = 1
			-- Equivalence code for NULL character

	yyReject_used: BOOLEAN = false
			-- Is `reject' called?

	yyVariable_trail_context: BOOLEAN = true
			-- Is there a regular expression with
			-- both leading and trailing parts having
			-- variable length?

	yyReject_or_variable_trail_context: BOOLEAN = true
			-- Is `reject' called or is there a
			-- regular expression with both leading
			-- and trailing parts having variable length?

	yyNb_rules: INTEGER = 127
			-- Number of rules

	yyEnd_of_buffer: INTEGER = 128
			-- End of buffer rule code

	yyLine_used: BOOLEAN = true
			-- Are line and column numbers used?

	yyPosition_used: BOOLEAN = false
			-- Is `position' used?

	INITIAL: INTEGER = 0
	IS_STR: INTEGER = 1
	PARAM: INTEGER = 2
	BREAK: INTEGER = 3
			-- Start condition codes

feature -- User-defined features



feature {NONE} -- Local variables

	i_, nb_: INTEGER
	char_: CHARACTER
	str_: STRING 
	code_: INTEGER
	last_key: like no_command
	idx_, token_: INTEGER

feature {NONE} -- Initialization

	make
			-- Create a new Eiffel scanner.
		do
			make_with_buffer (Empty_buffer)
			create eif_buffer.make (Init_buffer_size)
			create_keyword := True		
			create msg_.make(100)
			create pretty_command.make(100)
			create orig_breaks.make(8)
			create modes.make(3)
			make_tokens
			make_catch_keys
			breaks := orig_breaks.twin
			command_name := "."
			print_format := ""
			str_ := ""
		end

feature -- Initialization

	reset
			-- Reset scanner before scanning next input.
		do
			reset_compressed_scanner_skeleton
			eif_buffer.wipe_out
			command_code := NO_CODE
			msg_.wipe_out
			pretty_command.wipe_out
			breaks.copy(orig_breaks)
		end

feature -- Access

	eif_buffer: STRING
			-- Buffer for lexical tokens

	is_operator: BOOLEAN
			-- Parsing an operator declaration?

	command_code: INTEGER

	command_name: STRING

	pretty_command: STRING

	print_format: STRING 

	modes, breaks, orig_breaks, catch_keys: like commands

feature -- Status report

	create_keyword: BOOLEAN
			-- Should `create' be considered as
			-- a keyword (otherwise identifier)?

feature {NONE} -- Constants

	Init_buffer_size: INTEGER = 256
				-- Initial size for `eif_buffer'

feature {NONE} -- Implementation

	break_mode: INTEGER
	
	keyword(str: STRING; words: like commands; category: STRING): like no_command
		local
			cmd: attached like no_command
			i, n: INTEGER
			ok: BOOLEAN
		do
			str.to_lower
			from 
				n := words.count
			until attached Result or else i = n loop
				i := i + 1
				cmd := words[i]
				if attached cmd.name as w and then w.starts_with(str) then
					Result := cmd
				end
			end
			if attached Result as r then
				pretty_command.append(r.name)
				pretty_command.extend(' ')
			else
				msg_.copy(once "One of ")
				msg_.append(category)
				msg_.extend('s')
				msg_.extend(' ')
				from 
					i := 0
				until ok or i = n loop
					if i > 0 then
						msg_.extend(',')
					end
					msg_.extend(' ')
					i := i + 1
					cmd := words[i]
					if attached cmd.name as w then
						if msg_.count > 56 then
							msg_.append(once "...")
					 		ok := True
						else
							msg_.extend('`')
							msg_.append(w)
							msg_.extend('%'') --'
						end
					end
				end
				msg_.append(once " expected.")
				message(msg_,column)
			end
		ensure
			valid: attached Result as r words.has(r)
		end

	make_tokens
		once
			orig_breaks.force([CATCH_CODE, "catch", "", ""])
			orig_breaks.force([LINE_CODE, "at", "", ""])
			orig_breaks.force([DEPTH_CODE, "depth", "", ""])
			orig_breaks.force([WATCH_CODE, "watch", "", ""])
			orig_breaks.force([TYPE_CODE, "type", "", ""])
			orig_breaks.force([E_IF, "if", "", ""])
			orig_breaks.force([PRINT_CODE, "print", "", ""])
			orig_breaks.force([CONT_CODE, "cont", "", ""])
			modes.force([BREAK_CODE, "break", "", ""])
			modes.force([TRACE_CODE, "trace", "", ""])
			modes.force([SILENT_CODE, "silent", "", ""])
		end

	make_catch_keys
		do
                        create catch_keys.make(15)
catch_keys.force([Void_call_target, "void", "", "call on void target"])
			catch_keys.force([No_more_memory, "memory", "", "no more memory"])
--                      catch_keys.force([Precondition, "require", "", "violation of precondition"])
--                      catch_keys.force([Postcondition, "ensure", "", "violation of postcondition"])
--                      catch_keys.force([Class_invariant, "invariant", "", "violation of class invariant"])
--                      catch_keys.force([Check_instruction, "check", "", "violation of check instruction"])
                        catch_keys.force([Routine_failure, "failure", "", "routine failure"])
			catch_keys.force([Incorrect_inspect_value, "when", "", "violation of inspect value"])
--                      catch_keys.force([Loop_invariant, "loop", "", "violation of loop invariant or variant"])
--                      catch_keys.force([Signal_exception, "signal", "", "operating system signal"])
			catch_keys.force([Eiffel_runtime_panic, "catcall", "", "catcall"])
			catch_keys.force([Developer_exception, "developer", "", "routine `raise' called"])
			catch_keys.force([32, "all", "", "any exception"])
		end

	shorten_break_keys(code: INTEGER)
		local
			cmd: attached like no_command
			i, n: INTEGER
			found: BOOLEAN
		do
			from 
				n := breaks.count 
			until found or else i = n loop
				i := i + 1
				cmd := breaks[i]
				found := cmd.code = code
			end
			if found then 
				from 
					n := i 
				until n = 0 loop
					breaks.start
					breaks.remove
					n := n - 1
				end
			end
		end

	msg_: STRING 

feature {NONE} -- Processing from ET_EIFFEL_SCANNER_SKELETON

	process_operator (op: INTEGER): INTEGER
			-- Process current token as operator `op' or as
			-- an Eiffel string depending on the context
		require
			text_count_large_enough: text_count > 2
		do
			if is_operator then
				is_operator := False
				Result := op
			else
				Result := E_STRING
				last_string_value := text_substring (2, text_count - 1)
			end
		end

	process_one_char_symbol (c: CHARACTER) 
			-- Process Eiffel symbol with made up of only
			-- one character `c'.
		require
			one_char: text_count >= 1
			-- valid_string: ([-+*/^=~><$]).recognizes (text_substring (1, 1))
			valid_c: text_item (1) = c
		do
			inspect c
			when '-', '+', '*', '/', '^', '=', '~', '>', '<', '$' then
				last_token := c.code
			else
			end
		end

	process_two_char_symbol (c1, c2: CHARACTER)
			-- Process Eiffel symbol with made up of exactly
			-- two characters `c1' and `c2'.
		require
			two_chars: text_count >= 2
			-- valid_string: ("//"|"\\\\"|"/="|"/~"|">="|"<="|"..").recognizes (text_substring (1, 2))
			valid_c1: text_item (1) = c1
			valid_c2: text_item (2) = c2
		do
			inspect c1
			when '/' then
				inspect c2
				when '/' then
					last_token := E_DIV
				when '=' then
					last_token := E_NE
				when '~' then
					last_token := E_NOT_TILDE
				else
				end
			when '\' then
				check valid_symbol: c2 = '\' end
				last_token := E_MOD
			when '>' then
				check valid_symbol: c2 = '=' end
				last_token := E_GE
			when '<' then
				check valid_symbol: c2 = '=' end
				last_token := E_LE
			when '.' then
				check valid_symbol: c2 = '.' end
				last_token := E_DOTDOT
			else
			end
		end


        message(msg: STRING; at: INTEGER)  
                deferred
                end 
 
invariant

note
	date: "$Data$"
	revision: "$Revision$"
	compilation: "gelex -o dg_scanner.e dg_scanner.l"

end
