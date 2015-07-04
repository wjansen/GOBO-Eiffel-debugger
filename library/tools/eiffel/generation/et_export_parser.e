note
 
  description: "Parser of GEC debugger expressions" 
  
class ET_EXPORT_PARSER
 
inherit 
 
	YY_PARSER_SKELETON 
		rename 
			make as make_parser_skeleton 
		redefine
			report_error 
		end 
 
	ET_EXPORT_SCANNER 

	UT_ERROR_HANDLER
		rename
		report_error as ut_report_error
	end
  
create 
 
	make 
 

feature {NONE} -- Implementation

	yy_build_parser_tables
			-- Build parser tables.
		do
			yytranslate := yytranslate_template
			yyr1 := yyr1_template
			yytypes1 := yytypes1_template
			yytypes2 := yytypes2_template
			yydefact := yydefact_template
			yydefgoto := yydefgoto_template
			yypact := yypact_template
			yypgoto := yypgoto_template
			yytable := yytable_template
			yycheck := yycheck_template
		end

	yy_create_value_stacks
			-- Create value stacks.
		do
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
			create yyspecial_routines4
			yyvsc4 := yyInitial_yyvs_size
			yyvs4 := yyspecial_routines4.make (yyvsc4)
		end

	yy_init_value_stacks
			-- Initialize value stacks.
		do
			yyvsp1 := -1
			yyvsp2 := -1
			yyvsp3 := -1
			yyvsp4 := -1
		end

	yy_clear_value_stacks
			-- Clear objects in semantic value stacks so that
			-- they can be collected by the garbage collector.
		do
			yyvs1.keep_head (0)
			yyvs2.keep_head (0)
			yyvs3.keep_head (0)
			yyvs4.keep_head (0)
		end

	yy_push_last_value (yychar1: INTEGER)
			-- Push semantic value associated with token `last_token'
			-- (with internal id `yychar1') on top of corresponding
			-- value stack.
		do
			inspect yytypes2.item (yychar1)
			when 1 then
				yyvsp1 := yyvsp1 + 1
				if yyvsp1 >= yyvsc1 then
					debug ("GEYACC")
						std.error.put_line ("Resize yyvs1")
					end
					yyvsc1 := yyvsc1 + yyInitial_yyvs_size
					yyvs1 := yyspecial_routines1.aliased_resized_area (yyvs1, yyvsc1)
				end
				yyspecial_routines1.force (yyvs1, last_detachable_any_value, yyvsp1)
			when 2 then
				yyvsp2 := yyvsp2 + 1
				if yyvsp2 >= yyvsc2 then
					debug ("GEYACC")
						std.error.put_line ("Resize yyvs2")
					end
					yyvsc2 := yyvsc2 + yyInitial_yyvs_size
					yyvs2 := yyspecial_routines2.aliased_resized_area (yyvs2, yyvsc2)
				end
				yyspecial_routines2.force (yyvs2, last_string_value, yyvsp2)
			else
				debug ("GEYACC")
					std.error.put_string ("Error in parser: not a token type: ")
					std.error.put_integer (yytypes2.item (yychar1))
					std.error.put_new_line
				end
				abort
			end
		end

	yy_push_error_value
			-- Push semantic value associated with token 'error'
			-- on top of corresponding value stack.
		local
			yyval1: detachable ANY
		do
			yyvsp1 := yyvsp1 + 1
			if yyvsp1 >= yyvsc1 then
				debug ("GEYACC")
					std.error.put_line ("Resize yyvs1")
				end
				yyvsc1 := yyvsc1 + yyInitial_yyvs_size
				yyvs1 := yyspecial_routines1.aliased_resized_area (yyvs1, yyvsc1)
			end
			yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
		end

	yy_pop_last_value (yystate: INTEGER)
			-- Pop semantic value from stack when in state `yystate'.
		local
			yy_type_id: INTEGER
		do
			yy_type_id := yytypes1.item (yystate)
			inspect yy_type_id
			when 1 then
				yyvsp1 := yyvsp1 - 1
			when 2 then
				yyvsp2 := yyvsp2 - 1
			when 3 then
				yyvsp3 := yyvsp3 - 1
			when 4 then
				yyvsp4 := yyvsp4 - 1
			else
				debug ("GEYACC")
					std.error.put_string ("Error in parser: unknown type id: ")
					std.error.put_integer (yy_type_id)
					std.error.put_new_line
				end
				abort
			end
		end

	yy_run_geyacc
			-- You must run geyacc to regenerate this class.
		do
		end

feature {NONE} -- Semantic actions

	yy_do_action (yy_act: INTEGER)
			-- Execute semantic action.
		do
			inspect yy_act
			when 1 then
					--|#line 41 "et_export_parser.y"
				yy_do_action_1
			when 2 then
					--|#line 42 "et_export_parser.y"
				yy_do_action_2
			when 3 then
					--|#line 43 "et_export_parser.y"
				yy_do_action_3
			when 4 then
					--|#line 46 "et_export_parser.y"
				yy_do_action_4
			when 5 then
					--|#line 47 "et_export_parser.y"
				yy_do_action_5
			when 6 then
					--|#line 51 "et_export_parser.y"
				yy_do_action_6
			when 7 then
					--|#line 54 "et_export_parser.y"
				yy_do_action_7
			when 8 then
					--|#line 59 "et_export_parser.y"
				yy_do_action_8
			when 9 then
					--|#line 65 "et_export_parser.y"
				yy_do_action_9
			when 10 then
					--|#line 66 "et_export_parser.y"
				yy_do_action_10
			when 11 then
					--|#line 77 "et_export_parser.y"
				yy_do_action_11
			when 12 then
					--|#line 81 "et_export_parser.y"
				yy_do_action_12
			when 13 then
					--|#line 87 "et_export_parser.y"
				yy_do_action_13
			when 14 then
					--|#line 88 "et_export_parser.y"
				yy_do_action_14
			else
				debug ("GEYACC")
					std.error.put_string ("Error in parser: unknown rule id: ")
					std.error.put_integer (yy_act)
					std.error.put_new_line
				end
				abort
			end
		end

	yy_do_action_1
			--|#line 41 "et_export_parser.y"
		local
			yyval1: detachable ANY
		do
--|#line 41 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 41")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
		end

	yy_do_action_2
			--|#line 42 "et_export_parser.y"
		local
			yyval1: detachable ANY
		do
--|#line 42 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 42")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
		end

	yy_do_action_3
			--|#line 43 "et_export_parser.y"
		local
			yyval1: detachable ANY
		do
--|#line 43 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 43")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp1 >= yyvsc1 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs1")
		end
		yyvsc1 := yyvsc1 + yyInitial_yyvs_size
		yyvs1 := yyspecial_routines1.aliased_resized_area (yyvs1, yyvsc1)
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
		end

	yy_do_action_4
			--|#line 46 "et_export_parser.y"
		local
			yyval1: detachable ANY
		do
--|#line 46 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 46")
end

associations.force(yyvs2.item (yyvsp2 - 1), yyvs3.item (yyvsp3)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -1
	yyvsp2 := yyvsp2 -2
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
		end

	yy_do_action_5
			--|#line 47 "et_export_parser.y"
		local
			yyval1: detachable ANY
		do
--|#line 47 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 47")
end

			yyvs3.item (yyvsp3).set_as_creation(True)
			associations.force(yyvs2.item (yyvsp2 - 1), yyvs3.item (yyvsp3))
 		
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp1 := yyvsp1 -1
	yyvsp3 := yyvsp3 -1
	yyvsp2 := yyvsp2 -2
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
		end

	yy_do_action_6
			--|#line 51 "et_export_parser.y"
		local
			yyval1: detachable ANY
		do
--|#line 51 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 51")
end

clear_token ; recover 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
		end

	yy_do_action_7
			--|#line 54 "et_export_parser.y"
		local
			yyval3: ET_COMPILATION_ORDER
		do
--|#line 54 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 54")
end

			last_order := yyvs3.item (yyvsp3)
			yyval3 := yyvs3.item (yyvsp3)
			yyval3.set_feature_name(yyvs2.item (yyvsp2))
		
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -1
	yyvsp2 := yyvsp2 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_8
			--|#line 59 "et_export_parser.y"
		local
			yyval3: ET_COMPILATION_ORDER
		do
--|#line 59 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 59")
end

			yyval3 := last_order
			yyval3.set_feature_name(yyvs2.item (yyvsp2))
		
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp3 >= yyvsc3 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs3")
		end
		yyvsc3 := yyvsc3 + yyInitial_yyvs_size
		yyvs3 := yyspecial_routines3.aliased_resized_area (yyvs3, yyvsc3)
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_9
			--|#line 65 "et_export_parser.y"
		local
			yyval3: ET_COMPILATION_ORDER
		do
--|#line 65 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 65")
end

create yyval3.make (yyvs2.item (yyvsp2)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp3 >= yyvsc3 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs3")
		end
		yyvsc3 := yyvsc3 + yyInitial_yyvs_size
		yyvs3 := yyspecial_routines3.aliased_resized_area (yyvs3, yyvsc3)
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_10
			--|#line 66 "et_export_parser.y"
		local
			yyval3: ET_COMPILATION_ORDER
		do
--|#line 66 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 66")
end

			create yyval3.make (yyvs2.item (yyvsp2))
			from
				yyvs4.item (yyvsp4).start
			until yyvs4.item (yyvsp4).after loop
				yyval3.add_suborder(yyvs4.item (yyvsp4).item_for_iteration)
				yyvs4.item (yyvsp4).forth
			end
		
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -2
	yyvsp4 := yyvsp4 -1
	if yyvsp3 >= yyvsc3 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs3")
		end
		yyvsc3 := yyvsc3 + yyInitial_yyvs_size
		yyvs3 := yyspecial_routines3.aliased_resized_area (yyvs3, yyvsc3)
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_11
			--|#line 77 "et_export_parser.y"
		local
			yyval4: DS_ARRAYED_LIST [ET_COMPILATION_ORDER]
		do
--|#line 77 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 77")
end

			create yyval4.make(2)
			yyval4.put_last (yyvs3.item (yyvsp3))
		
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp4 := yyvsp4 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp4 >= yyvsc4 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs4")
		end
		yyvsc4 := yyvsc4 + yyInitial_yyvs_size
		yyvs4 := yyspecial_routines4.aliased_resized_area (yyvs4, yyvsc4)
	end
	yyspecial_routines4.force (yyvs4, yyval4, yyvsp4)
end
		end

	yy_do_action_12
			--|#line 81 "et_export_parser.y"
		local
			yyval4: DS_ARRAYED_LIST [ET_COMPILATION_ORDER]
		do
--|#line 81 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 81")
end

			yyval4 := yyvs4.item (yyvsp4)
			yyval4.put_last (yyvs3.item (yyvsp3))
		
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines4.force (yyvs4, yyval4, yyvsp4)
end
		end

	yy_do_action_13
			--|#line 87 "et_export_parser.y"
		local
			yyval2: STRING
		do
--|#line 87 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 87")
end

yyval2 := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
		end

	yy_do_action_14
			--|#line 88 "et_export_parser.y"
		local
			yyval2: STRING
		do
--|#line 88 "et_export_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'et_export_parser.y' at line 88")
end

yyval2 := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
		end

	yy_do_error_action (yy_act: INTEGER)
			-- Execute error action.
		do
			inspect yy_act
			when 28 then
					-- End-of-file expected action.
				report_eof_expected_error
			else
					-- Default action.
				report_error ("parse error")
			end
		end

feature {NONE} -- Table templates

	yytranslate_template: SPECIAL [INTEGER]
			-- Template for `yytranslate'
		once
			Result := yyfixed_array (<<
			    0,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    8,    2,   12,    2,    9,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    7,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,   10,    2,   11,    2,    2,    2,    2,    2,    2,

			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,

			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    1,    2,    3,    4,
			    5,    6, yyDummy>>)
		end

	yyr1_template: SPECIAL [INTEGER]
			-- Template for `yyr1'
		once
			Result := yyfixed_array (<<
			    0,   17,   17,   17,   18,   18,   18,   14,   14,   13,
			   13,   15,   15,   16,   16, yyDummy>>)
		end

	yytypes1_template: SPECIAL [INTEGER]
			-- Template for `yytypes1'
		once
			Result := yyfixed_array (<<
			    1,    1,    2,    2,    1,    3,    3,    1,    1,    3,
			    1,    2,    1,    1,    1,    1,    2,    3,    4,    2,
			    2,    2,    2,    2,    1,    1,    2,    2,    3,    1,
			    1, yyDummy>>)
		end

	yytypes2_template: SPECIAL [INTEGER]
			-- Template for `yytypes2'
		once
			Result := yyfixed_array (<<
			    1,    1,    1,    2,    2,    2,    2,    1,    1,    1,
			    1,    1,    1, yyDummy>>)
		end

	yydefact_template: SPECIAL [INTEGER]
			-- Template for `yydefact'
		once
			Result := yyfixed_array (<<
			    0,    0,    3,    9,    0,    0,    0,    0,    1,    0,
			    0,    6,    0,    0,    2,    0,    9,   11,    0,    7,
			   14,   13,    0,    0,    0,   10,    4,    5,   12,    0,
			    0, yyDummy>>)
		end

	yydefgoto_template: SPECIAL [INTEGER]
			-- Template for `yydefgoto'
		once
			Result := yyfixed_array (<<
			    5,    6,   18,   22,    7,    8, yyDummy>>)
		end

	yypact_template: SPECIAL [INTEGER]
			-- Template for `yypact'
		once
			Result := yyfixed_array (<<
			    2,   23, -32768,    5,   20,   15,   14,    1, -32768,    4,
			    3, -32768,   10,   16, -32768,   16,   13, -32768,    6, -32768,
			 -32768, -32768,   17,   11,    3, -32768, -32768, -32768, -32768,    8,
			 -32768, yyDummy>>)
		end

	yypgoto_template: SPECIAL [INTEGER]
			-- Template for `yypgoto'
		once
			Result := yyfixed_array (<<
			  -10,   28, -32768,   12, -32768,   21, yyDummy>>)
		end

	yytable_template: SPECIAL [INTEGER]
			-- Template for `yytable'
		once
			Result := yyfixed_array (<<
			   17,   29,    4,    4,    3,    3,   16,    2,   30,    1,
			    1,   15,   -8,   19,   28,   10,   27,   25,   24,   21,
			   20,   13,   26,   10,   12,   11,    3,   23,   14,    9, yyDummy>>)
		end

	yycheck_template: SPECIAL [INTEGER]
			-- Template for `yycheck'
		once
			Result := yyfixed_array (<<
			   10,    0,    1,    1,    3,    3,    3,    5,    0,    8,
			    8,    7,    7,    3,   24,   10,    5,   11,   12,    3,
			    4,    7,    5,   10,    9,    5,    3,   15,    7,    1, yyDummy>>)
		end

feature {NONE} -- Semantic value stacks

	yyvs1: SPECIAL [detachable ANY]
			-- Stack for semantic values of type detachable ANY

	yyvsc1: INTEGER
			-- Capacity of semantic value stack `yyvs1'

	yyvsp1: INTEGER
			-- Top of semantic value stack `yyvs1'

	yyspecial_routines1: KL_SPECIAL_ROUTINES [detachable ANY]
			-- Routines that ought to be in SPECIAL [detachable ANY]

	yyvs2: SPECIAL [STRING]
			-- Stack for semantic values of type STRING

	yyvsc2: INTEGER
			-- Capacity of semantic value stack `yyvs2'

	yyvsp2: INTEGER
			-- Top of semantic value stack `yyvs2'

	yyspecial_routines2: KL_SPECIAL_ROUTINES [STRING]
			-- Routines that ought to be in SPECIAL [STRING]

	yyvs3: SPECIAL [ET_COMPILATION_ORDER]
			-- Stack for semantic values of type ET_COMPILATION_ORDER

	yyvsc3: INTEGER
			-- Capacity of semantic value stack `yyvs3'

	yyvsp3: INTEGER
			-- Top of semantic value stack `yyvs3'

	yyspecial_routines3: KL_SPECIAL_ROUTINES [ET_COMPILATION_ORDER]
			-- Routines that ought to be in SPECIAL [ET_COMPILATION_ORDER]

	yyvs4: SPECIAL [DS_ARRAYED_LIST [ET_COMPILATION_ORDER]]
			-- Stack for semantic values of type DS_ARRAYED_LIST [ET_COMPILATION_ORDER]

	yyvsc4: INTEGER
			-- Capacity of semantic value stack `yyvs4'

	yyvsp4: INTEGER
			-- Top of semantic value stack `yyvs4'

	yyspecial_routines4: KL_SPECIAL_ROUTINES [DS_ARRAYED_LIST [ET_COMPILATION_ORDER]]
			-- Routines that ought to be in SPECIAL [DS_ARRAYED_LIST [ET_COMPILATION_ORDER]]

feature {NONE} -- Constants

	yyFinal: INTEGER = 30
			-- Termination state id

	yyFlag: INTEGER = -32768
			-- Most negative INTEGER

	yyNtbase: INTEGER = 13
			-- Number of tokens

	yyLast: INTEGER = 29
			-- Upper bound of `yytable' and `yycheck'

	yyMax_token: INTEGER = 261
			-- Maximum token id
			-- (upper bound of `yytranslate'.)

	yyNsyms: INTEGER = 19
			-- Number of symbols
			-- (terminal and nonterminal)

feature -- User-defined features

 
 
feature {NONE} -- Initialization 
 
	make(f: KL_TEXT_INPUT_FILE)
		do 
			make_with_file (f)
			make_parser_skeleton
			create associations.make(10)
			make_standard
		end 
 
feature -- Error handling 
 
	report_error (orig_msg: STRING) 
		local
			msg: STRING
		do
			msg := "Export file at ("
			msg.append_integer(line)
			msg.append_character(',')
			msg.append_integer(column)
			msg.append_string(") : ")
			msg.append_string(orig_msg)
			msg.append_character('%N')
			report_warning_message (msg)
		end 
 
feature -- Access 

	associations: DS_HASH_TABLE [STRING, ET_COMPILATION_ORDER]

feature {NONE} -- Implementation 
 
	last_order: ET_COMPILATION_ORDER


invariant 
 
note
	copyright: "Copyright (c) 20015, Wolfgang Jansen and others" 
	license: "MIT License" 
	date: "$Date$" 
	revision: "$Revision$" 
	compilation: "geyacc -t ET_EXPORT_TOKENS -o et_export_parser.e et_export_parser.y" 

end
