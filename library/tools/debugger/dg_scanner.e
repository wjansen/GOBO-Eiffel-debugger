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
yy_set_line_column
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 37 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 37")
end
-- ignore separators
else
	yy_column := yy_column + 8
	yy_position := yy_position + 8
--|#line 39 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 39")
end

		last_token := BEGIN_TYPEDEF
		set_start_condition(TYPEDEF)
	
end
else
if yy_act = 3 then
	yy_column := yy_column + 7
	yy_position := yy_position + 7
--|#line 44 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 44")
end

		last_token := BEGIN_STRUCT 
		set_start_condition(STRUCT)
	
else
	yy_column := yy_column + 7
	yy_position := yy_position + 7
--|#line 50 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 50")
end

		last_token := BEGIN_STRUCT 
	
end
end
else
if yy_act <= 6 then
if yy_act = 5 then
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 53 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 53")
end

		last_token := BEGIN_ENUM 
		set_start_condition(ENUM)
	
else
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 57 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 57")
end

		last_token := text[1].code 
	
end
else
if yy_act = 7 then
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 60 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 60")
end

		last_token := END_TYPEDEF
		set_start_condition(INITIAL)
	
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 67 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 67")
end

		last_token := ENUM_NAME
		last_string_value := text.twin
	
end
end
end
else
if yy_act <= 12 then
if yy_act <= 10 then
if yy_act = 9 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 71 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 71")
end

		last_token := INTEGER
		last_integer_value := text.to_integer
	
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 75 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 75")
end

		last_token := INTEGER
		last_integer_value := text.to_integer
	
end
else
if yy_act = 11 then
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 79 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 79")
end

		last_token := text[1].code 
	
else
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 82 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 82")
end

		last_token := END_ENUM
		set_start_condition(INITIAL)
	
end
end
else
if yy_act <= 14 then
if yy_act = 13 then
	yy_column := yy_column + 2
	yy_position := yy_position + 2
--|#line 89 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 89")
end

		last_token := END_STRUCT
		set_start_condition(INITIAL)

else
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 93 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 93")
end

		last_token := text[1].code 
	
end
else
if yy_act = 15 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 99 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 99")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 103 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 103")
end

		last_token := CLASS_NAME
		last_string_value := text.twin
	
end
end
end
end
else
if yy_act <= 24 then
if yy_act <= 20 then
if yy_act <= 18 then
if yy_act = 17 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 107 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 107")
end

		last_token := STRUCT_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + 8
	yy_position := yy_position + 8
--|#line 111 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 111")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
end
else
if yy_act = 19 then
	yy_column := yy_column + 4
	yy_position := yy_position + 4
--|#line 115 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 115")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + 7
	yy_position := yy_position + 7
--|#line 119 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 119")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
end
end
else
if yy_act <= 22 then
if yy_act = 21 then
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 123 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 123")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 127 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 127")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
end
else
if yy_act = 23 then
	yy_column := yy_column + 6
	yy_position := yy_position + 6
--|#line 131 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 131")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + 8
	yy_position := yy_position + 8
--|#line 135 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 135")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
end
end
end
else
if yy_act <= 28 then
if yy_act <= 26 then
if yy_act = 25 then
	yy_column := yy_column + 13
	yy_position := yy_position + 13
--|#line 139 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 139")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + 5
	yy_position := yy_position + 5
--|#line 143 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 143")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
end
else
if yy_act = 27 then
	yy_column := yy_column + 4
	yy_position := yy_position + 4
--|#line 147 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 147")
end

		last_token := TYPE_NAME
		last_string_value := text.twin
	
else
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 154 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 154")
end

		last_token := IDENTIFIER
		last_string_value := text.twin
	
end
end
else
if yy_act <= 30 then
if yy_act = 29 then
	yy_column := yy_column + yy_end - yy_start - yy_more_len
	yy_position := yy_position + yy_end - yy_start - yy_more_len
--|#line 158 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 158")
end

		last_token := IDENTIFIER
		last_string_value := text.twin
	
else
	yy_column := yy_column + 1
	yy_position := yy_position + 1
--|#line 164 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 164")
end
-- ignore
end
else
yy_set_line_column
	yy_position := yy_position + 1
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
			yy_set_beginning_of_line
		end

	yy_execute_eof_action (yy_sc: INTEGER)
			-- Execute EOF semantic action.
		do
			inspect yy_sc
when 0, 1, 2, 3 then
--|#line 165 "dg_scanner.l"
debug ("GELEX")
	std.error.put_line ("Executing scanner user-code from file 'dg_scanner.l' at line 165")
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
			  124,   51,   32,   32,   32,  124,  124,  124,   74,   36,
			  124,  124,  124,   39,  110,   94,   47,   62,   63,   46,
			   13,   14,   10,   11,   12,   11,   15,   15,   15,   10,
			   10,   10,   10,   16,   10,   17,   17,   17,   17,   18,
			   17,   19,   20,   20,   20,   20,   21,   20,   22,   20,
			   20,   20,   20,   20,   20,   20,   20,   20,   23,   20,
			   20,   24,   20,   20,   20,   10,   10,   10,   25,   10,
			   49,   49,   49,   49,   25,  124,  124,  124,  124,  124,

			  124,   49,   49,   49,   49,  124,  124,   20,   58,  124,
			  124,  124,   57,   61,   59,   60,   56,   64,  124,   20,
			   65,   73,  124,   50,   72,  124,   25,   26,   10,   25,
			   10,   76,  124,   75,  124,   25,   77,  124,   87,  124,
			  124,  124,  124,   81,  124,  124,  124,   78,   20,   79,
			  113,   92,  124,   80,   88,  124,  124,   89,  124,   90,
			   20,   91,   93,  101,  124,  103,   95,   25,   26,   10,
			   10,   27,   28,   29,   29,   29,   30,   27,  124,  102,
			  105,  124,   31,  124,  104,  124,  114,  124,  124,   20,
			  124,  124,  112,  124,  124,  124,  124,  124,  111,  124,

			  124,   20,   37,  106,  117,  116,  119,   37,   27,   27,
			  124,  118,  120,  124,   40,   41,  121,  123,  115,  109,
			  122,   42,   66,   66,   66,   66,   66,   43,  108,   44,
			  124,   45,  107,  107,  107,  107,   99,   98,  107,  107,
			  107,  107,  107,  107,  107,   10,   10,   10,   10,   10,
			   10,   10,   10,   35,   35,   35,   35,   35,   35,   35,
			   85,   85,   85,   85,   85,   85,   85,  100,  100,  100,
			  100,  100,  100,  100,   97,   96,  124,   86,   84,   83,
			   82,   71,   70,   69,   68,   67,   55,  124,   54,   53,
			   52,   48,  124,   38,   36,   34,   33,  124,    9,  124,

			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124, yy_Dummy>>)
		end

	yy_chk_template: SPECIAL [INTEGER]
			-- Template for `yy_chk'
		once
			Result := yy_fixed_array (<<
			    0,    0,    1,    1,    1,    2,    2,    2,   11,   11,
			   11,   12,   12,   12,   29,   29,   29,   29,   21,   23,
			   24,   31,   32,   32,   32,   58,   44,   45,   58,   31,
			   80,  101,  123,   21,  101,   80,   24,   44,   45,   23,
			    2,    2,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    5,    5,    5,
			   28,   28,   28,   28,    5,   39,   40,   43,   41,   46,

			   42,   49,   49,   49,   49,   57,  118,    5,   41,   47,
			   56,   60,   40,   43,   41,   42,   39,   46,   59,    5,
			   47,   57,   62,   28,   56,   61,    5,    5,    6,    6,
			    6,   60,   64,   59,   63,    6,   61,   65,   72,   74,
			   75,   73,   79,   65,   78,   90,   77,   62,    6,   63,
			  105,   78,   72,   64,   73,  116,   88,   74,  105,   75,
			    6,   77,   79,   88,   91,   90,   81,    6,    6,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,   81,   89,
			   93,  103,    7,   94,   91,  104,  106,   93,  111,    7,
			  110,   89,  104,  112,  113,  117,  120,  119,  103,  122,

			  106,    7,  127,   94,  111,  110,  117,  127,    7,    7,
			   22,  112,  119,  121,   22,   22,  120,  122,  109,   98,
			  121,   22,  128,  128,  128,  128,  128,   22,   97,   22,
			   92,   22,   96,   96,   96,   96,   85,   84,   96,   96,
			   96,   96,   96,   96,   96,  125,  125,  125,  125,  125,
			  125,  125,  125,  126,  126,  126,  126,  126,  126,  126,
			  129,  129,  129,  129,  129,  129,  129,  130,  130,  130,
			  130,  130,  130,  130,   83,   82,   76,   71,   69,   68,
			   67,   55,   54,   53,   52,   51,   38,   37,   36,   34,
			   33,   26,   20,   19,   18,   14,   13,    9,  124,  124,

			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124,  124,  124,  124,  124,  124,  124,
			  124,  124,  124,  124, yy_Dummy>>)
		end

	yy_base_template: SPECIAL [INTEGER]
			-- Template for `yy_base'
		once
			Result := yy_fixed_array (<<
			    0,    0,    3,   41,    0,   82,  123,  164,    0,  297,
			  298,    6,    9,  258,  253,  298,  298,    0,  269,  275,
			  274,    0,  192,    1,    2,  298,  279,  298,   82,    6,
			  298,    4,   20,  254,  254,    0,  264,  269,  261,   77,
			   78,   80,   82,   79,    8,    9,   81,   91,  298,   93,
			    0,  269,  245,  258,  260,  257,   92,   87,    7,  100,
			   93,  107,  104,  116,  114,  119,    0,  265,  256,  254,
			    0,  255,  134,  123,  121,  122,  258,  128,  126,  124,
			   12,  160,  255,  236,  212,  230,    0,  298,  138,  173,
			  127,  146,  212,  169,  165,  298,  224,  224,  193,  298,

			    0,   13,  298,  163,  167,  140,  182,    0,  298,  214,
			  172,  170,  175,  176,  298,  298,  137,  177,   88,  179,
			  178,  195,  181,   14,  298,  244,  251,  200,  220,  258,
			  265, yy_Dummy>>)
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
			   29,   29,   29,   29,   29,   14,   30,   11,    9,    9,
			   12,   28,    1,    0,    0,   28,   28,   29,    0,   29,
			   29,   29,   29,   29,   29,   29,   29,   29,   13,    9,
			    0,   28,    0,    0,   28,    0,   29,   29,   29,   29,
			   29,   29,   29,   29,   29,   29,   10,   28,    0,    0,
			   28,    0,   29,   29,   29,   29,   19,   29,   29,   29,
			   29,   27,   28,    0,    0,   16,    0,    5,   29,   29,
			   29,   29,   22,   21,   29,   26,   28,    0,    0,   15,

			   17,   29,   23,   29,   29,   29,   29,    8,    3,    0,
			   29,   29,   29,   20,    4,    2,   18,   29,   24,   29,
			   29,   29,   29,   25,    0, yy_Dummy>>)
		end

feature {NONE} -- Constants

	yyJam_base: INTEGER = 298
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
