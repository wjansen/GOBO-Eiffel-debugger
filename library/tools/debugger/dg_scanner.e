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


feature -- Status report

	valid_start_condition (sc: INTEGER): BOOLEAN
			-- Is `sc' a valid start condition?
		do
			Result := (INITIAL <= sc and sc <= ENUM)
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
if yy_act <= 16 then
if yy_act <= 8 then
if yy_act <= 4 then
if yy_act <= 2 then
if yy_act = 1 then
		--|#line 37 "dg_scanner.l"
	yy_execute_action_1
else
		--|#line 39 "dg_scanner.l"
	yy_execute_action_2
end
else
if yy_act = 3 then
		--|#line 42 "dg_scanner.l"
	yy_execute_action_3
else
		--|#line 47 "dg_scanner.l"
	yy_execute_action_4
end
end
else
if yy_act <= 6 then
if yy_act = 5 then
		--|#line 48 "dg_scanner.l"
	yy_execute_action_5
else
		--|#line 51 "dg_scanner.l"
	yy_execute_action_6
end
else
if yy_act = 7 then
		--|#line 52 "dg_scanner.l"
	yy_execute_action_7
else
		--|#line 58 "dg_scanner.l"
	yy_execute_action_8
end
end
end
else
if yy_act <= 12 then
if yy_act <= 10 then
if yy_act = 9 then
		--|#line 61 "dg_scanner.l"
	yy_execute_action_9
else
		--|#line 64 "dg_scanner.l"
	yy_execute_action_10
end
else
if yy_act = 11 then
		--|#line 67 "dg_scanner.l"
	yy_execute_action_11
else
		--|#line 70 "dg_scanner.l"
	yy_execute_action_12
end
end
else
if yy_act <= 14 then
if yy_act = 13 then
		--|#line 74 "dg_scanner.l"
	yy_execute_action_13
else
		--|#line 75 "dg_scanner.l"
	yy_execute_action_14
end
else
if yy_act = 15 then
		--|#line 81 "dg_scanner.l"
	yy_execute_action_15
else
		--|#line 84 "dg_scanner.l"
	yy_execute_action_16
end
end
end
end
else
if yy_act <= 24 then
if yy_act <= 20 then
if yy_act <= 18 then
if yy_act = 17 then
		--|#line 87 "dg_scanner.l"
	yy_execute_action_17
else
		--|#line 90 "dg_scanner.l"
	yy_execute_action_18
end
else
if yy_act = 19 then
		--|#line 93 "dg_scanner.l"
	yy_execute_action_19
else
		--|#line 96 "dg_scanner.l"
	yy_execute_action_20
end
end
else
if yy_act <= 22 then
if yy_act = 21 then
		--|#line 99 "dg_scanner.l"
	yy_execute_action_21
else
		--|#line 102 "dg_scanner.l"
	yy_execute_action_22
end
else
if yy_act = 23 then
		--|#line 105 "dg_scanner.l"
	yy_execute_action_23
else
		--|#line 108 "dg_scanner.l"
	yy_execute_action_24
end
end
end
else
if yy_act <= 28 then
if yy_act <= 26 then
if yy_act = 25 then
		--|#line 111 "dg_scanner.l"
	yy_execute_action_25
else
		--|#line 114 "dg_scanner.l"
	yy_execute_action_26
end
else
if yy_act = 27 then
		--|#line 117 "dg_scanner.l"
	yy_execute_action_27
else
		--|#line 123 "dg_scanner.l"
	yy_execute_action_28
end
end
else
if yy_act <= 30 then
if yy_act = 29 then
		--|#line 126 "dg_scanner.l"
	yy_execute_action_29
else
		--|#line 131 "dg_scanner.l"
	yy_execute_action_30
end
else
		--|#line 0 "dg_scanner.l"
	yy_execute_action_31
end
end
end
end
		end

	yy_execute_action_1
			--|#line 37 "dg_scanner.l"
		do
yy_set_line_column
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 37 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 37")
end
-- ignore separators

		end

	yy_execute_action_2
			--|#line 39 "dg_scanner.l"
		do
	yy_column := yy_column + 8
	yy_position := yy_position + 8
--|#line 39 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 39")
end
	last_token := BEGIN_TYPEDEF
				set_start_condition(TYPEDEF)
			

		end

	yy_execute_action_3
			--|#line 42 "dg_scanner.l"
		do
	yy_column := yy_column + 7
	yy_position := yy_position + 7
--|#line 42 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 42")
end
	last_token := BEGIN_STRUCT 
				set_start_condition(STRUCT)
			

		end

	yy_execute_action_4
			--|#line 47 "dg_scanner.l"
		do
	yy_column := yy_column + 7
	yy_position := yy_position + 7
--|#line 47 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 47")
end
	last_token := BEGIN_STRUCT 

		end

	yy_execute_action_5
			--|#line 48 "dg_scanner.l"
		do
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 48 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 48")
end
	last_token := BEGIN_ENUM 
				set_start_condition(ENUM)
			

		end

	yy_execute_action_6
			--|#line 51 "dg_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 51 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 51")
end
	last_token := text[1].code 

		end

	yy_execute_action_7
			--|#line 52 "dg_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 52 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 52")
end
	last_token := END_TYPEDEF
				set_start_condition(INITIAL)
			

		end

	yy_execute_action_8
			--|#line 58 "dg_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 58 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 58")
end
	last_token := END_ENUM
				set_start_condition(INITIAL)
			

		end

	yy_execute_action_9
			--|#line 61 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 61 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 61")
end
	last_token := ENUM_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_10
			--|#line 64 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 64 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 64")
end
	last_token := INTEGER
				last_integer_value := text.to_integer
			

		end

	yy_execute_action_11
			--|#line 67 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 67 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 67")
end
	last_token := INTEGER
				last_integer_value := text.to_integer
			

		end

	yy_execute_action_12
			--|#line 70 "dg_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 70 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 70")
end
	last_token := text[1].code 

		end

	yy_execute_action_13
			--|#line 74 "dg_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 74 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 74")
end
	last_token := text[1].code 

		end

	yy_execute_action_14
			--|#line 75 "dg_scanner.l"
		do
	yy_column := yy_column + 2
	yy_position := yy_position + 2
--|#line 75 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 75")
end
	last_token := END_STRUCT
				set_start_condition(INITIAL)
			

		end

	yy_execute_action_15
			--|#line 81 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 81 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 81")
end
	last_token := CLASS_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_16
			--|#line 84 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 84 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 84")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_17
			--|#line 87 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 87 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 87")
end
	last_token := STRUCT_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_18
			--|#line 90 "dg_scanner.l"
		do
	yy_column := yy_column + 8
	yy_position := yy_position + 8
--|#line 90 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 90")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_19
			--|#line 93 "dg_scanner.l"
		do
	yy_column := yy_column + 4
	yy_position := yy_position + 4
--|#line 93 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 93")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_20
			--|#line 96 "dg_scanner.l"
		do
	yy_column := yy_column + 7
	yy_position := yy_position + 7
--|#line 96 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 96")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_21
			--|#line 99 "dg_scanner.l"
		do
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 99 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 99")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_22
			--|#line 102 "dg_scanner.l"
		do
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 102 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 102")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_23
			--|#line 105 "dg_scanner.l"
		do
	yy_column := yy_column + 6
	yy_position := yy_position + 6
--|#line 105 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 105")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_24
			--|#line 108 "dg_scanner.l"
		do
	yy_column := yy_column + 8
	yy_position := yy_position + 8
--|#line 108 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 108")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_25
			--|#line 111 "dg_scanner.l"
		do
	yy_column := yy_column + 13
	yy_position := yy_position + 13
--|#line 111 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 111")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_26
			--|#line 114 "dg_scanner.l"
		do
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 114 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 114")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_27
			--|#line 117 "dg_scanner.l"
		do
	yy_column := yy_column + 4
	yy_position := yy_position + 4
--|#line 117 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 117")
end
	last_token := TYPE_NAME
				last_string_value := text.twin
			

		end

	yy_execute_action_28
			--|#line 123 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 123 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 123")
end
	last_token := IDENTIFIER
				last_string_value := text.twin
			

		end

	yy_execute_action_29
			--|#line 126 "dg_scanner.l"
		do
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 126 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 126")
end
	last_token := IDENTIFIER
				last_string_value := text.twin
			

		end

	yy_execute_action_30
			--|#line 131 "dg_scanner.l"
		do
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 131 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 131")
end
-- ignore

		end

	yy_execute_action_31
			--|#line 0 "dg_scanner.l"
		do
yy_set_line_column
	yy_position := yy_position + 1
--|#line 0 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 0")
end
last_token := yyError_token
fatal_error ("scanner jammed")

		end

	yy_execute_eof_action (yy_sc: INTEGER)
			-- Execute EOF semantic action.
		do
			inspect yy_sc
when 0, 1, 2, 3 then
--|#line 132 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 132")
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
			    0,  124,   11,   12,   11,   11,   12,   11,   32,   32,
			   32,   32,   32,   32,   49,   49,   49,   49,  124,  124,
			  124,   51,   32,   32,   32,   49,   49,   49,   49,   36,
			  124,  124,  124,   39,   74,   94,   47,   13,   14,   46,
			   13,   14,   10,   11,   12,   11,   15,   15,   15,   10,
			   10,   10,   10,   16,   10,   17,   17,   17,   17,   18,
			   17,   19,   20,   20,   20,   20,   21,   20,   22,   20,
			   20,   20,   20,   20,   20,   20,   20,   20,   23,   20,
			   20,   24,   20,   20,   20,   10,   10,   10,   25,   10,
			   49,   49,   49,   49,   25,  124,  124,  124,  124,  124,

			  124,  124,  124,  124,  124,  124,  124,   20,   58,  124,
			   62,  124,   57,   61,   59,   60,   56,   63,   72,   20,
			   64,   73,   65,   50,   75,  124,   25,   26,   10,   25,
			   10,  124,  124,  124,  124,   25,   87,  124,  124,  124,
			  124,  124,   77,   81,  124,   76,   92,  124,   20,   79,
			  124,   88,   95,  102,   80,  124,   91,   78,   89,  124,
			   20,  124,  101,   90,  124,  124,  124,   25,   26,   10,
			   10,   27,   28,   29,   29,   29,   30,   27,  105,   93,
			  124,  103,   31,  124,  124,  124,  104,  110,  124,   20,
			  112,  113,  114,  124,  124,  115,  124,  124,  124,  124,

			  106,   20,  124,  109,  119,  111,  124,  124,   27,   27,
			  124,  116,  118,  117,   40,   41,  124,  120,  121,   37,
			  108,   42,  124,  122,   37,  123,   99,   43,   98,   44,
			   97,   45,  107,  107,  107,  107,   96,  124,  107,  107,
			  107,  107,  107,  107,  107,   10,   10,   10,   10,   10,
			   10,   10,   10,   35,   35,   35,   35,   35,   35,   35,
			   66,   66,   66,   66,   66,   85,   85,   85,   85,   85,
			   85,   85,  100,  100,  100,  100,  100,  100,  100,   86,
			   84,   83,   82,   71,   70,   69,   68,   67,   55,  124,
			   54,   53,   52,   48,  124,   38,   36,   34,   33,  124,

			    9,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124, yy_Dummy>>)
		end

	yy_chk_template: SPECIAL [INTEGER]
			-- Template for `yy_chk'
		once
			Result := yy_fixed_array (<<
			    0,    0,    1,    1,    1,    2,    2,    2,   11,   11,
			   11,   12,   12,   12,   29,   29,   29,   29,   21,   23,
			   24,   31,   32,   32,   32,   49,   49,   49,   49,   31,
			   80,   58,  123,   21,   58,   80,   24,    1,    1,   23,
			    2,    2,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    5,    5,    5,
			   28,   28,   28,   28,    5,   39,   40,   43,   41,   44,

			   42,  118,   46,  116,   56,   57,   45,    5,   41,   59,
			   44,   47,   40,   43,   41,   42,   39,   45,   56,    5,
			   46,   57,   47,   28,   59,   60,    5,    5,    6,    6,
			    6,   61,   62,   64,   63,    6,   72,   65,   73,   78,
			   74,   77,   61,   65,   75,   60,   78,  113,    6,   63,
			   72,   73,   81,   89,   64,   88,   77,   62,   74,   79,
			    6,   90,   88,   75,   81,   89,   91,    6,    6,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,   93,   79,
			   94,   90,    7,  104,  101,   93,   91,  101,  103,    7,
			  104,  105,  106,  117,  112,  109,  110,  111,  120,  105,

			   94,    7,  119,   98,  117,  103,  106,  122,    7,    7,
			   22,  110,  112,  111,   22,   22,  121,  119,  120,  127,
			   97,   22,   92,  121,  127,  122,   85,   22,   84,   22,
			   83,   22,   96,   96,   96,   96,   82,   76,   96,   96,
			   96,   96,   96,   96,   96,  125,  125,  125,  125,  125,
			  125,  125,  125,  126,  126,  126,  126,  126,  126,  126,
			  128,  128,  128,  128,  128,  129,  129,  129,  129,  129,
			  129,  129,  130,  130,  130,  130,  130,  130,  130,   71,
			   69,   68,   67,   55,   54,   53,   52,   51,   38,   37,
			   36,   34,   33,   26,   20,   19,   18,   14,   13,    9,

			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124, yy_Dummy>>)
		end

	yy_base_template: SPECIAL [INTEGER]
			-- Template for `yy_base'
		once
			Result := yy_fixed_array (<<
			    0,    0,    3,   41,    0,   82,  123,  164,    0,  299,
			  300,    6,    9,  260,  255,  300,  300,    0,  271,  277,
			  276,    0,  192,    1,    2,  300,  281,  300,   82,    6,
			  300,    4,   20,  256,  256,    0,  266,  271,  263,   77,
			   78,   80,   82,   79,   81,   88,   84,   93,  300,   17,
			    0,  271,  247,  260,  262,  259,   86,   87,   13,   91,
			  107,  113,  114,  116,  115,  119,    0,  267,  258,  256,
			    0,  257,  132,  120,  122,  126,  219,  123,  121,  141,
			   12,  146,  216,  192,  203,  220,    0,  300,  137,  147,
			  143,  148,  204,  167,  162,  300,  224,  216,  177,  300,

			    0,  166,  300,  170,  165,  181,  188,    0,  300,  191,
			  178,  179,  176,  129,  300,  300,   85,  175,   83,  184,
			  180,  198,  189,   14,  300,  244,  251,  217,  258,  263,
			  270, yy_Dummy>>)
		end

	yy_def_template: SPECIAL [INTEGER]
			-- Template for `yy_def'
		once
			Result := yy_fixed_array (<<
			    0,  125,  125,  124,    3,    3,    3,    3,    7,  124,
			  124,  124,  124,  124,  124,  124,  124,  126,  126,  127,
			  127,  127,  127,  127,  127,  124,  124,  124,  124,  124,
			  124,  126,  124,  124,  124,  126,  126,  127,  124,  127,
			  127,  127,  127,  127,  127,  127,  127,  127,  124,  124,
			  128,  126,  124,  124,  126,  124,  127,  127,  127,  127,
			  127,  127,  127,  127,  127,  127,  128,  126,  124,  124,
			  129,  124,  127,  127,  127,  127,  127,  127,  127,  127,
			  127,  127,  126,  124,  124,  129,  130,  124,  127,  127,
			  127,  127,  127,  127,  127,  124,  126,  124,  124,  124,

			  130,  127,  124,  127,  127,  127,  127,   96,  124,  124,
			  127,  127,  127,  127,  124,  124,  127,  127,  127,  127,
			  127,  127,  127,  127,    0,  124,  124,  124,  124,  124,
			  124, yy_Dummy>>)
		end

	yy_ec_template: SPECIAL [INTEGER]
			-- Template for `yy_ec'
		once
			Result := yy_fixed_array (<<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    2,
			    3,    1,    1,    2,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    4,    1,    1,    1,    1,    1,    1,    1,
			    5,    5,    6,    1,    7,    1,    1,    1,    8,    9,
			    9,    9,   10,    9,   11,    9,    9,    9,    1,   12,
			    1,   13,    1,    1,    1,   14,   15,   14,   16,   17,
			   14,   18,   19,   19,   19,   19,   19,   19,   19,   19,
			   19,   19,   19,   19,   19,   19,   19,   19,   19,   19,
			   19,    1,    1,    1,    1,   20,    1,   21,   22,   23,

			   24,   25,   26,   27,   28,   29,   30,   30,   31,   32,
			   33,   34,   35,   30,   36,   37,   38,   39,   40,   30,
			   41,   42,   43,   44,    1,   45,    1,    1,    1,    1,
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
			    0,    1,    1,    1,    1,    1,    1,    1,    2,    2,
			    2,    2,    1,    1,    3,    4,    5,    6,    7,    8,
			    7,    2,    2,    2,    2,    2,    2,    7,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
			    7,    7,    7,    7,    1,    1, yy_Dummy>>)
		end

	yy_accept_template: SPECIAL [INTEGER]
			-- Template for `yy_accept'
		once
			Result := yy_fixed_array (<<
			    0,    0,    0,    0,    0,    0,    0,    0,    0,   32,
			   30,    1,    1,   30,   30,    6,    7,   28,   28,   29,
			   29,   29,   29,   29,   29,   13,   30,   12,   10,   10,
			    8,   28,    1,    0,    0,   28,   28,   29,    0,   29,
			   29,   29,   29,   29,   29,   29,   29,   29,   14,   10,
			    0,   28,    0,    0,   28,    0,   29,   29,   29,   29,
			   29,   29,   29,   29,   29,   29,   11,   28,    0,    0,
			   28,    0,   29,   29,   29,   29,   19,   29,   29,   29,
			   29,   27,   28,    0,    0,   15,    0,    5,   29,   29,
			   29,   29,   22,   21,   29,   26,   28,    0,    0,   16,

			   17,   29,   23,   29,   29,   29,   29,    9,    3,    0,
			   29,   29,   29,   20,    4,    2,   18,   29,   24,   29,
			   29,   29,   29,   25,    0, yy_Dummy>>)
		end

feature {NONE} -- Constants

	yyJam_base: INTEGER = 300
			-- Position in `yy_nxt'/`yy_chk' tables
			-- where default jam table starts

	yyJam_state: INTEGER = 124
			-- State id corresponding to jam state

	yyTemplate_mark: INTEGER = 125
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

	yyNb_rules: INTEGER = 31
			-- Number of rules

	yyEnd_of_buffer: INTEGER = 32
			-- End of buffer rule code

	yyLine_used: BOOLEAN = true
			-- Are line and column numbers used?

	yyPosition_used: BOOLEAN = true
			-- Is `position' used?

	INITIAL: INTEGER = 0
	TYPEDEF: INTEGER = 1
	STRUCT: INTEGER = 2
	ENUM: INTEGER = 3
			-- Start condition codes

feature -- User-defined features



feature -- Access

	c_name: STRING

invariant

note
	date: "$Data$"
	revision: "$Revision$"
	compilation: "gelex -o dg_scanner.e -x dg_scanner.l"

end
