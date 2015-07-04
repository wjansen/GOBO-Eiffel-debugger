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


feature -- Status report

	valid_start_condition (sc: INTEGER): BOOLEAN
			-- Is `sc' a valid start condition?
		do
			Result := (sc = INITIAL)
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
		end

	yy_execute_action (yy_act: INTEGER)
			-- Execute semantic action.
		do
if yy_act <= 5 then
if yy_act <= 3 then
if yy_act <= 2 then
if yy_act = 1 then
		--|#line 33 "et_export_scanner.l"
	yy_execute_action_1
else
		--|#line 38 "et_export_scanner.l"
	yy_execute_action_2
end
else
		--|#line 43 "et_export_scanner.l"
	yy_execute_action_3
end
else
if yy_act = 4 then
		--|#line 45 "et_export_scanner.l"
	yy_execute_action_4
else
		--|#line 47 "et_export_scanner.l"
	yy_execute_action_5
end
end
else
if yy_act <= 7 then
if yy_act = 6 then
		--|#line 49 "et_export_scanner.l"
	yy_execute_action_6
else
		--|#line 51 "et_export_scanner.l"
	yy_execute_action_7
end
else
if yy_act = 8 then
		--|#line 53 "et_export_scanner.l"
	yy_execute_action_8
else
		--|#line 0 "et_export_scanner.l"
	yy_execute_action_9
end
end
end
		end

	yy_execute_action_1
			--|#line 33 "et_export_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 33 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 33")
end

		last_token := E_IDENTIFIER
		last_string_value := text.twin
		

		end

	yy_execute_action_2
			--|#line 38 "et_export_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 38 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 38")
end

		last_token := C_IDENTIFIER
		last_string_value := text.twin
		

		end

	yy_execute_action_3
			--|#line 43 "et_export_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 43 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 43")
end
 last_token := text[1].code 

		end

	yy_execute_action_4
			--|#line 45 "et_export_scanner.l"
		do
	yy_line := yy_line + 1
	yy_column := 1
	yy_position := yy_position + 2
--|#line 45 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 45")
end
-- Continuation at next line

		end

	yy_execute_action_5
			--|#line 47 "et_export_scanner.l"
		do
	yy_end := yy_end - 1
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 47 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 47")
end
--{ last_token := EOL }

		end

	yy_execute_action_6
			--|#line 49 "et_export_scanner.l"
		do
yy_set_line_column
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 49 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 49")
end
 last_token := EOL 

		end

	yy_execute_action_7
			--|#line 51 "et_export_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 51 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 51")
end
-- Ignore separators

		end

	yy_execute_action_8
			--|#line 53 "et_export_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 53 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 53")
end
 last_token := OTHER 

		end

	yy_execute_action_9
			--|#line 0 "et_export_scanner.l"
		do
yy_set_line_column
	yy_position := yy_position + 1
--|#line 0 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 0")
end
last_token := yyError_token
fatal_error ("scanner jammed")

		end

	yy_execute_eof_action (yy_sc: INTEGER)
			-- Execute EOF semantic action.
		do
			inspect yy_sc
when 0 then
--|#line 55 "et_export_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'et_export_scanner.l' at line 55")
end
terminate
			else
				terminate
			end
		end

feature {NONE} -- Table templates

	yy_nxt_template: SPECIAL [INTEGER]
			-- Template for `yy_nxt'
		once
			Result := yy_fixed_array (<<
			    0,    4,    5,    6,    7,    8,    9,    4,   10,   11,
			   12,   19,   20,   19,   20,   15,   15,   15,   18,   16,
			   14,   13,   17,   15,   13,   21,    3,   21,   21,   21,
			   21,   21,   21,   21,   21,   21,   21, yy_Dummy>>)
		end

	yy_chk_template: SPECIAL [INTEGER]
			-- Template for `yy_chk'
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,   15,   15,   20,   20,   25,   25,   25,   24,   23,
			   22,   13,   11,    9,    5,    3,   21,   21,   21,   21,
			   21,   21,   21,   21,   21,   21,   21, yy_Dummy>>)
		end

	yy_base_template: SPECIAL [INTEGER]
			-- Template for `yy_base'
		once
			Result := yy_fixed_array (<<
			    0,    0,    0,   25,   26,   22,    0,    0,   26,   17,
			    0,   19,    0,   19,    0,    8,    0,   26,    0,   26,
			   10,   26,   18,   16,   15,   14, yy_Dummy>>)
		end

	yy_def_template: SPECIAL [INTEGER]
			-- Template for `yy_def'
		once
			Result := yy_fixed_array (<<
			    0,   21,    1,   21,   21,   21,   22,   22,   21,   21,
			   23,   21,   24,   21,   22,   25,   23,   21,   24,   21,
			   25,    0,   21,   21,   21,   21, yy_Dummy>>)
		end

	yy_ec_template: SPECIAL [INTEGER]
			-- Template for `yy_ec'
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    2,
			    3,    1,    1,    4,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    2,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    5,    1,    5,    6,    5,    1,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    1,    1,
			    1,    5,    1,    1,    1,    8,    8,    8,    8,    8,
			    8,    8,    8,    8,    8,    8,    8,    8,    8,    8,
			    8,    8,    8,    8,    8,    8,    8,    8,    8,    8,
			    8,    5,    9,    5,    1,   10,    1,    8,    8,    8,

			    8,    8,    8,    8,    8,    8,    8,    8,    8,    8,
			    8,    8,    8,    8,    8,    8,    8,    8,    8,    8,
			    8,    8,    8,    1,    1,    1,    1,    1,    1,    1,
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
			-- Template for `yy_meta'
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    2,    2,    1,    1,    3,    3,    1,
			    3, yy_Dummy>>)
		end

	yy_accept_template: SPECIAL [INTEGER]
			-- Template for `yy_accept'
		once
			Result := yy_fixed_array (<<
			    0,    0,    0,   10,    8,    7,    6,    6,    3,    8,
			    1,    8,    2,    7,    6,    0,    1,    4,    2,    5,
			    5,    0, yy_Dummy>>)
		end

feature {NONE} -- Constants

	yyJam_base: INTEGER = 26
			-- Position in `yy_nxt'/`yy_chk' tables
			-- where default jam table starts

	yyJam_state: INTEGER = 21
			-- State id corresponding to jam state

	yyTemplate_mark: INTEGER = 22
			-- Mark between normal states and templates

	yyNull_equiv_class: INTEGER = 1
			-- Equivalence code for NULL character

	yyReject_used: BOOLEAN = false
			-- Is `reject' called?

	yyVariable_trail_context: BOOLEAN = false
			-- Is there a regular expression with
			-- both leading and trailing parts having
			-- variable length?

	yyReject_or_variable_trail_context: BOOLEAN = false
			-- Is `reject' called or is there a
			-- regular expression with both leading
			-- and trailing parts having variable length?

	yyNb_rules: INTEGER = 9
			-- Number of rules

	yyEnd_of_buffer: INTEGER = 10
			-- End of buffer rule code

	yyLine_used: BOOLEAN = true
			-- Are line and column numbers used?

	yyPosition_used: BOOLEAN = true
			-- Is `position' used?

	INITIAL: INTEGER = 0
			-- Start condition codes

feature -- User-defined features



invariant

note
	date: "$Data$"
	revision: "$Revision$"
	compilation: "gelex -o et_export_scanner.e -x et_export_scanner.l"

end
