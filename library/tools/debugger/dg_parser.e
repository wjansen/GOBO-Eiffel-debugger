note
 
  description: "Parser of GEC debugger expressions" 
  
class DG_PARSER 
 
inherit 
 
	YY_PARSER_SKELETON 
		rename 
			make as make_parser_skeleton 
		redefine 
			report_error 
		end 
 
	DG_SCANNER 
		rename 
			make as make_scanner 
		redefine 
			reset
		end 
 
	DG_GLOBALS 

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
		end

	yy_init_value_stacks
			-- Initialize value stacks.
		do
			yyvsp1 := -1
			yyvsp2 := -1
			yyvsp3 := -1
			yyvsp4 := -1
			yyvsp5 := -1
			yyvsp6 := -1
			yyvsp7 := -1
			yyvsp8 := -1
			yyvsp9 := -1
		end

	yy_clear_value_stacks
			-- Clear objects in semantic value stacks so that
			-- they can be collected by the garbage collector.
		local
			l_yyvs1_default_item: ANY
			l_yyvs2_default_item: INTEGER
			l_yyvs3_default_item: STRING
			l_yyvs4_default_item: CHARACTER
			l_yyvs5_default_item: DOUBLE
			l_yyvs6_default_item: DG_EXPRESSION
			l_yyvs7_default_item: IS_TYPE
			l_yyvs8_default_item: IS_CLASS_TEXT
			l_yyvs9_default_item: IS_FEATURE_TEXT
		do
			if yyvs1 /= Void then
				yyvs1.fill_with (l_yyvs1_default_item, 0, yyvs1.upper)
			end
			if yyvs2 /= Void then
				yyvs2.fill_with (l_yyvs2_default_item, 0, yyvs2.upper)
			end
			if yyvs3 /= Void then
				yyvs3.fill_with (l_yyvs3_default_item, 0, yyvs3.upper)
			end
			if yyvs4 /= Void then
				yyvs4.fill_with (l_yyvs4_default_item, 0, yyvs4.upper)
			end
			if yyvs5 /= Void then
				yyvs5.fill_with (l_yyvs5_default_item, 0, yyvs5.upper)
			end
			if yyvs6 /= Void then
				yyvs6.fill_with (l_yyvs6_default_item, 0, yyvs6.upper)
			end
			if yyvs7 /= Void then
				yyvs7.fill_with (l_yyvs7_default_item, 0, yyvs7.upper)
			end
			if yyvs8 /= Void then
				yyvs8.fill_with (l_yyvs8_default_item, 0, yyvs8.upper)
			end
			if yyvs9 /= Void then
				yyvs9.fill_with (l_yyvs9_default_item, 0, yyvs9.upper)
			end
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
					if yyvs1 = Void then
						debug ("GEYACC")
							std.error.put_line ("Create yyvs1")
						end
						create yyspecial_routines1
						yyvsc1 := yyInitial_yyvs_size
						yyvs1 := yyspecial_routines1.make (yyvsc1)
					else
						debug ("GEYACC")
							std.error.put_line ("Resize yyvs1")
						end
						yyvsc1 := yyvsc1 + yyInitial_yyvs_size
						yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
					end
				end
				yyspecial_routines1.force (yyvs1, last_any_value, yyvsp1)
			when 2 then
				yyvsp2 := yyvsp2 + 1
				if yyvsp2 >= yyvsc2 then
					if yyvs2 = Void then
						debug ("GEYACC")
							std.error.put_line ("Create yyvs2")
						end
						create yyspecial_routines2
						yyvsc2 := yyInitial_yyvs_size
						yyvs2 := yyspecial_routines2.make (yyvsc2)
					else
						debug ("GEYACC")
							std.error.put_line ("Resize yyvs2")
						end
						yyvsc2 := yyvsc2 + yyInitial_yyvs_size
						yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
					end
				end
				yyspecial_routines2.force (yyvs2, last_integer_value, yyvsp2)
			when 3 then
				yyvsp3 := yyvsp3 + 1
				if yyvsp3 >= yyvsc3 then
					if yyvs3 = Void then
						debug ("GEYACC")
							std.error.put_line ("Create yyvs3")
						end
						create yyspecial_routines3
						yyvsc3 := yyInitial_yyvs_size
						yyvs3 := yyspecial_routines3.make (yyvsc3)
					else
						debug ("GEYACC")
							std.error.put_line ("Resize yyvs3")
						end
						yyvsc3 := yyvsc3 + yyInitial_yyvs_size
						yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
					end
				end
				yyspecial_routines3.force (yyvs3, last_string_value, yyvsp3)
			when 4 then
				yyvsp4 := yyvsp4 + 1
				if yyvsp4 >= yyvsc4 then
					if yyvs4 = Void then
						debug ("GEYACC")
							std.error.put_line ("Create yyvs4")
						end
						create yyspecial_routines4
						yyvsc4 := yyInitial_yyvs_size
						yyvs4 := yyspecial_routines4.make (yyvsc4)
					else
						debug ("GEYACC")
							std.error.put_line ("Resize yyvs4")
						end
						yyvsc4 := yyvsc4 + yyInitial_yyvs_size
						yyvs4 := yyspecial_routines4.resize (yyvs4, yyvsc4)
					end
				end
				yyspecial_routines4.force (yyvs4, last_character_value, yyvsp4)
			when 5 then
				yyvsp5 := yyvsp5 + 1
				if yyvsp5 >= yyvsc5 then
					if yyvs5 = Void then
						debug ("GEYACC")
							std.error.put_line ("Create yyvs5")
						end
						create yyspecial_routines5
						yyvsc5 := yyInitial_yyvs_size
						yyvs5 := yyspecial_routines5.make (yyvsc5)
					else
						debug ("GEYACC")
							std.error.put_line ("Resize yyvs5")
						end
						yyvsc5 := yyvsc5 + yyInitial_yyvs_size
						yyvs5 := yyspecial_routines5.resize (yyvs5, yyvsc5)
					end
				end
				yyspecial_routines5.force (yyvs5, last_double_value, yyvsp5)
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
			yyval1: ANY
		do
			yyvsp1 := yyvsp1 + 1
			if yyvsp1 >= yyvsc1 then
				if yyvs1 = Void then
					debug ("GEYACC")
						std.error.put_line ("Create yyvs1")
					end
					create yyspecial_routines1
					yyvsc1 := yyInitial_yyvs_size
					yyvs1 := yyspecial_routines1.make (yyvsc1)
				else
					debug ("GEYACC")
						std.error.put_line ("Resize yyvs1")
					end
					yyvsc1 := yyvsc1 + yyInitial_yyvs_size
					yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
				end
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
			when 5 then
				yyvsp5 := yyvsp5 - 1
			when 6 then
				yyvsp6 := yyvsp6 - 1
			when 7 then
				yyvsp7 := yyvsp7 - 1
			when 8 then
				yyvsp8 := yyvsp8 - 1
			when 9 then
				yyvsp9 := yyvsp9 - 1
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
		local
			yyval2: INTEGER
			yyval1: ANY
			yyval3: STRING
			yyval4: CHARACTER
			yyval9: IS_FEATURE_TEXT
			yyval7: IS_TYPE
			yyval8: IS_CLASS_TEXT
			yyval6: DG_EXPRESSION
		do
			inspect yy_act
when 1 then
--|#line 110 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 110")
end

go_count := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 2 then
--|#line 110 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 110")
end

int := 1;  min := 1;  max := {INTEGER}.max_value 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 3 then
--|#line 113 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 113")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 4 then
--|#line 114 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 114")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 5 then
--|#line 115 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 115")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 6 then
--|#line 116 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 116")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 7 then
--|#line 117 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 117")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 8 then
--|#line 118 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 118")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 9 then
--|#line 119 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 119")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 10 then
--|#line 120 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 120")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 11 then
--|#line 121 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 121")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 12 then
--|#line 122 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 122")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 13 then
--|#line 123 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 123")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 14 then
--|#line 124 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 124")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 15 then
--|#line 125 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 125")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 16 then
--|#line 126 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 126")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 17 then
--|#line 127 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 127")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 18 then
--|#line 128 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 128")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 19 then
--|#line 129 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 129")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 20 then
--|#line 130 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 130")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 21 then
--|#line 131 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 131")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 22 then
--|#line 132 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 132")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 23 then
--|#line 133 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 133")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 24 then
--|#line 134 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 134")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 25 then
--|#line 135 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 135")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 26 then
--|#line 136 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 136")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 27 then
--|#line 137 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 137")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 28 then
--|#line 138 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 138")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 29 then
--|#line 139 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 139")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 30 then
--|#line 140 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 140")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 31 then
--|#line 141 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 141")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 32 then
--|#line 142 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 142")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 33 then
--|#line 143 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 143")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 34 then
--|#line 144 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 144")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 35 then
--|#line 145 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 145")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 36 then
--|#line 146 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 146")
end

message(once "Unknown command.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 37 then
--|#line 150 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 150")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 38 then
--|#line 151 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 151")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 39 then
--|#line 152 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 152")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 40 then
--|#line 153 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 153")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 41 then
--|#line 156 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 156")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 42 then
--|#line 159 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 159")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 43 then
--|#line 162 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 162")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 44 then
--|#line 163 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 163")
end

if attached keyword(yyvs3.item (yyvsp3), modes, once "keyword") as key then
			    go_mode := key.code 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 45 then
--|#line 170 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 170")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 46 then
--|#line 173 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 173")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 47 then
--|#line 176 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 176")
end

reset_ident := checked_int(yyvs2.item (yyvsp2), False) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 48 then
--|#line 176 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 176")
end

min := 0;  max := debugger.marker_count-1 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 49 then
--|#line 180 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 180")
end

message(No_integer, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 50 then
--|#line 184 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 184")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 51 then
--|#line 185 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 185")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 52 then
--|#line 185 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 185")
end

int:=0 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp1 := yyvsp1 + 1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 53 then
--|#line 186 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 186")
end

message(No_integer, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 54 then
--|#line 189 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 189")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 55 then
--|#line 190 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 190")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 56 then
--|#line 190 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 190")
end

int:=0 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp1 := yyvsp1 + 1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 57 then
--|#line 191 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 191")
end

message(No_integer, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 58 then
--|#line 194 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 194")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 59 then
--|#line 194 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 194")
end

int:=1 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp1 := yyvsp1 + 1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 60 then
--|#line 195 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 195")
end

message(No_integer, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 61 then
--|#line 198 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 198")
end

if not breakpoints.valid_index(yyvs2.item (yyvsp2)) 
			      or else breakpoints[yyvs2.item (yyvsp2)] = Void then 
			    message(once "No such breakpoint.",column) 
			  else
			    break_idents.force(yyvs2.item (yyvsp2)) 
			  end
			  set_start_condition(PARAM) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 62 then
--|#line 207 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 207")
end

if not breakpoints.valid_index(yyvs2.item (yyvsp2)) 
			      or else breakpoints[yyvs2.item (yyvsp2)] = Void then 
			    message(once "No such breakpoint.",column) 
			  elseif attached break_idents as bi then
			    bi.force(yyvs2.item (yyvsp2)) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 63 then
--|#line 215 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 215")
end

			  if attached break_idents as bi then
			    bi.force({INTEGER}.max_value) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 64 then
--|#line 221 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 221")
end

if int/=0 then
			    message(once "Keyword %"debug%" not allowed here.",column) 
			  end
			  if attached break_idents as bi then
			    bi.force(0) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 65 then
--|#line 231 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 231")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 66 then
--|#line 231 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 231")
end

in_break:=True 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 67 then
--|#line 232 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 232")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp2 := yyvsp2 -2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 68 then
--|#line 232 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 232")
end

in_break:=True 
			  if not breakpoints.valid_index(yyvs2.item (yyvsp2)) 
			      or else breakpoints[yyvs2.item (yyvsp2)] = Void then 
			    message(once "Not a breakpoint number.", column) 
			  end 
			  if attached breakpoints[yyvs2.item (yyvsp2)] as b then
			    breakpoint.copy(b) 
			  end
			  break_idents.force(yyvs2.item (yyvsp2)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 69 then
--|#line 246 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 246")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 8
	yyvsp1 := yyvsp1 + 1
	yyvsp3 := yyvsp3 -8
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 70 then
--|#line 249 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 249")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 71 then
--|#line 250 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 250")
end

breakpoint.set_catch(keyword(yyvs3.item (yyvsp3), catch_keys, once "keyword")) 
			  set_start_condition(BREAK) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 72 then
--|#line 254 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 254")
end

breakpoint.set_catch(keyword("all", catch_keys, once "keyword")) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 73 then
--|#line 254 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 254")
end

set_start_condition(BREAK) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 74 then
--|#line 257 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 257")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_catch(Void) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 75 then
--|#line 264 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 264")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 76 then
--|#line 265 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 265")
end

set_start_condition(BREAK)
			  if attached lines.cls as cls and then not cls.is_debug_enabled then
			    msg_.copy(once "Debugger information not available for class ")
			    msg_.append(cls.name)
			    msg_.extend('.')
			    message(msg_,int)
			    abort
			  else
			    if lines.text = Void then
			      put_back(text)
			    end
			    breakpoint.set_range(lines) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 77 then
--|#line 265 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 265")
end

int:=column
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 78 then
--|#line 280 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 280")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_range(Void) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 79 then
--|#line 287 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 287")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 80 then
--|#line 288 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 288")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_stack_level(yyvs2.item (yyvsp2)) 
			  breakpoint.set_automatic_stack(False) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -2
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 81 then
--|#line 294 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 294")
end

set_start_condition(BREAK) 
			  breakpoint.set_stack_level(yyvs2.item (yyvsp2)) 
			  breakpoint.set_automatic_stack(True) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -2
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 82 then
--|#line 299 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 299")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_stack_level(0) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 83 then
--|#line 306 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 306")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 84 then
--|#line 307 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 307")
end

set_start_condition(BREAK) 
			  put_back(text) 
			  column := column - text.count + 1
			  breakpoint.set_watch(yyvs6.item (yyvsp6), debugger.shown_frame) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp6 := yyvsp6 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 85 then
--|#line 313 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 313")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_watch(Void, debugger.shown_frame) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 86 then
--|#line 320 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 320")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 87 then
--|#line 321 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 321")
end

set_start_condition(BREAK) 
			  if text.is_empty or else text[1] = ']' then
			    -- ignore bad scan
			  else
			    put_back(text)
			  end
			  breakpoint.set_type(yyvs7.item (yyvsp7)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp7 := yyvsp7 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 88 then
--|#line 331 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 331")
end

set_start_condition(BREAK) 
			  put_back(text) 
			  breakpoint.set_type(Void) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 89 then
--|#line 338 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 338")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 90 then
--|#line 339 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 339")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_condition(yyvs6.item (yyvsp6)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -1
	yyvsp6 := yyvsp6 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 91 then
--|#line 339 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 339")
end

forbidden_closure := True 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 92 then
--|#line 346 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 346")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_condition(Void) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp1 := yyvsp1 -2
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 93 then
--|#line 353 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 353")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 94 then
--|#line 354 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 354")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_action(yyvs6.item (yyvsp6)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp2 := yyvsp2 -1
	yyvsp4 := yyvsp4 -1
	yyvsp6 := yyvsp6 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 95 then
--|#line 354 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 354")
end

forbidden_closure := True
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 96 then
--|#line 359 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 359")
end

set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_action(Void) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 97 then
--|#line 366 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 366")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 98 then
--|#line 367 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 367")
end

breakpoint.set_trace_only(True) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 99 then
--|#line 369 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 369")
end

breakpoint.set_trace_only(False) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp3 >= yyvsc3 then
		if yyvs3 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs3")
			end
			create yyspecial_routines3
			yyvsc3 := yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.make (yyvsc3)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs3")
			end
			yyvsc3 := yyvsc3 + yyInitial_yyvs_size
			yyvs3 := yyspecial_routines3.resize (yyvs3, yyvsc3)
		end
	end
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 100 then
--|#line 373 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 373")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 101 then
--|#line 376 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 376")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 102 then
--|#line 379 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 379")
end

stack_count := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 103 then
--|#line 379 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 379")
end

int := debugger.bottom_frame.depth - debugger.shown_frame.depth 
			  min := 0;  max := {INTEGER}.max_value 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 104 then
--|#line 385 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 385")
end

stack_count := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 105 then
--|#line 385 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 385")
end

int := 1;  min := 1;  max := {INTEGER}.max_value 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 106 then
--|#line 389 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 389")
end

stack_count := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 107 then
--|#line 389 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 389")
end

int := 1;  min := 1;  max := {INTEGER}.max_value 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 108 then
--|#line 395 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 395")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp4 := yyvsp4 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 109 then
--|#line 396 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 396")
end

multi := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp4 := yyvsp4 -1
	yyvsp6 := yyvsp6 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 110 then
--|#line 399 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 399")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp4 := yyvsp4 + 1
	if yyvsp4 >= yyvsc4 then
		if yyvs4 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs4")
			end
			create yyspecial_routines4
			yyvsc4 := yyInitial_yyvs_size
			yyvs4 := yyspecial_routines4.make (yyvsc4)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs4")
			end
			yyvsc4 := yyvsc4 + yyInitial_yyvs_size
			yyvs4 := yyspecial_routines4.resize (yyvs4, yyvsc4)
		end
	end
	yyspecial_routines4.force (yyvs4, yyval4, yyvsp4)
end
when 111 then
--|#line 400 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 400")
end

check_format(once "lnagx", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines4.force (yyvs4, yyval4, yyvsp4)
end
when 112 then
--|#line 404 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 404")
end

single := as_closure(current_closure) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp4 := yyvsp4 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 113 then
--|#line 406 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 406")
end

single := as_closure(yyvs6.item (yyvsp6)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp4 := yyvsp4 -1
	yyvsp6 := yyvsp6 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 114 then
--|#line 408 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 408")
end

single := Void 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 115 then
--|#line 410 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 410")
end

message(once "Expression expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp4 := yyvsp4 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 116 then
--|#line 414 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 414")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp4 := yyvsp4 + 1
	if yyvsp4 >= yyvsc4 then
		if yyvs4 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs4")
			end
			create yyspecial_routines4
			yyvsc4 := yyInitial_yyvs_size
			yyvs4 := yyspecial_routines4.make (yyvsc4)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs4")
			end
			yyvsc4 := yyvsc4 + yyInitial_yyvs_size
			yyvs4 := yyspecial_routines4.resize (yyvs4, yyvsc4)
		end
	end
	yyspecial_routines4.force (yyvs4, yyval4, yyvsp4)
end
when 117 then
--|#line 415 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 415")
end

check_format(once "naxd", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines4.force (yyvs4, yyval4, yyvsp4)
end
when 118 then
--|#line 419 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 419")
end

command_code := NAMEOF_CODE
			  single := yyvs6.item (yyvsp6)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp6 := yyvsp6 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 119 then
--|#line 423 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 423")
end

command_code := NAMEOF_CODE
			  single := yyvs6.item (yyvsp6)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp1 := yyvsp1 -1
	yyvsp2 := yyvsp2 -1
	yyvsp4 := yyvsp4 -1
	yyvsp6 := yyvsp6 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 120 then
--|#line 423 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 423")
end

int:=column
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp1 := yyvsp1 + 1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 121 then
--|#line 423 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 423")
end

check_format(once "t", int) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp1 := yyvsp1 + 1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 122 then
--|#line 431 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 431")
end

message(once "Closure ident expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 123 then
--|#line 436 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 436")
end

target := yyvs6.item (yyvsp6 - 1)
			  if attached target as t then
			    t.compute(debugger.shown_frame, value_stack) 
			  end
			  single := yyvs6.item (yyvsp6)
			  if attached single as s then
			    s.compute(debugger.shown_frame, value_stack) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp6 := yyvsp6 -2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 124 then
--|#line 446 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 446")
end

message(once "Source expression expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 125 then
--|#line 448 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 448")
end

message(once "Assignment operator expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 126 then
--|#line 450 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 450")
end

message(once "Target expression expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 127 then
--|#line 454 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 454")
end

single := yyvs6.item (yyvsp6)  
			  if attached single as s then
			    s.compute(debugger.shown_frame, value_stack) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp6 := yyvsp6 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 128 then
--|#line 460 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 460")
end

message(once "Expression expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 129 then
--|#line 464 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 464")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 130 then
--|#line 467 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 467")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 131 then
--|#line 469 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 469")
end

type := Void 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 132 then
--|#line 471 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 471")
end

type := yyvs7.item (yyvsp7) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp7 := yyvsp7 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 133 then
--|#line 473 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 473")
end

message(No_type, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 134 then
--|#line 476 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 476")
end

type := Void 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 135 then
--|#line 478 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 478")
end

type := yyvs7.item (yyvsp7) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp7 := yyvsp7 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 136 then
--|#line 480 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 480")
end

message(No_type, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 137 then
--|#line 483 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 483")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 138 then
--|#line 486 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 486")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 139 then
--|#line 489 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 489")
end

lines.set_count(max_lines - 2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 140 then
--|#line 491 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 491")
end

in_list := False 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 141 then
--|#line 491 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 491")
end

in_list := True 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 142 then
--|#line 494 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 494")
end

check attached lines.cls as cls end
			  if not attached {IS_ROUTINE_TEXT} lines.cls.feature_by_line (lines.first_line) as rt then
			    message(once "Not in a feature_body.", column)
			  elseif not attached rt.instruction_positions as p then
			    message(once "Instruction positions not generated.", column)
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 143 then
--|#line 502 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 502")
end

message(once "Position expected.",column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 144 then
--|#line 506 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 506")
end

lines.set_class(debugger.shown_frame.routine.home) 
			  lines.set_first_line(debugger.shown_frame.line - yyvs2.item (yyvsp2)) 
			  int := yyvs2.item (yyvsp2) + 1
			  lines.set_count(int) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp3 := yyvsp3 -1
	yyvsp2 := yyvsp2 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 145 then
--|#line 512 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 512")
end

lines.set_class(debugger.shown_frame.routine.home) 
			  lines.set_first_line(debugger.shown_frame.line - yyvs2.item (yyvsp2 - 1)) 
			  min := 1;  max := {INTEGER}.max_value
			  lines.set_count(checked_int(yyvs2.item (yyvsp2), False)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -1
	yyvsp2 := yyvsp2 -2
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 146 then
--|#line 518 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 518")
end

message(once "Line count expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp1 := yyvsp1 -1
	yyvsp3 := yyvsp3 -1
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 147 then
--|#line 520 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 520")
end

message(once "Line offset expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 148 then
--|#line 524 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 524")
end

lines.set_first_line(1) 
		          lines.set_count(max_lines - 2) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp8 := yyvsp8 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 149 then
--|#line 528 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 528")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 + 1
	yyvsp8 := yyvsp8 -1
	yyvsp9 := yyvsp9 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 150 then
--|#line 529 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 529")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 151 then
--|#line 530 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 530")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp9 := yyvsp9 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 152 then
--|#line 531 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 531")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 153 then
--|#line 534 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 534")
end

yyval9 := feature_by_name(yyvs3.item (yyvsp3), lines.cls, False)
			  lines.set_text(yyval9, in_break) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp9 := yyvsp9 + 1
	yyvsp1 := yyvsp1 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp9 >= yyvsc9 then
		if yyvs9 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs9")
			end
			create yyspecial_routines9
			yyvsc9 := yyInitial_yyvs_size
			yyvs9 := yyspecial_routines9.make (yyvsc9)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs9")
			end
			yyvsc9 := yyvsc9 + yyInitial_yyvs_size
			yyvs9 := yyspecial_routines9.resize (yyvs9, yyvsc9)
		end
	end
	yyspecial_routines9.force (yyvs9, yyval9, yyvsp9)
end
when 154 then
--|#line 537 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 537")
end

yyval9 := feature_by_name(yyvs3.item (yyvsp3), lines.cls, False)
			  lines.set_text(yyval9, in_break) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp9 := yyvsp9 + 1
	yyvsp1 := yyvsp1 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp9 >= yyvsc9 then
		if yyvs9 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs9")
			end
			create yyspecial_routines9
			yyvsc9 := yyInitial_yyvs_size
			yyvs9 := yyspecial_routines9.make (yyvsc9)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs9")
			end
			yyvsc9 := yyvsc9 + yyInitial_yyvs_size
			yyvs9 := yyspecial_routines9.resize (yyvs9, yyvsc9)
		end
	end
	yyspecial_routines9.force (yyvs9, yyval9, yyvsp9)
end
when 155 then
--|#line 540 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 540")
end

message(once "Feature name expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp9 := yyvsp9 + 1
	yyvsp1 := yyvsp1 -2
	if yyvsp9 >= yyvsc9 then
		if yyvs9 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs9")
			end
			create yyspecial_routines9
			yyvsc9 := yyInitial_yyvs_size
			yyvs9 := yyspecial_routines9.make (yyvsc9)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs9")
			end
			yyvsc9 := yyvsc9 + yyInitial_yyvs_size
			yyvs9 := yyspecial_routines9.resize (yyvs9, yyvsc9)
		end
	end
	yyspecial_routines9.force (yyvs9, yyval9, yyvsp9)
end
when 156 then
--|#line 544 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 544")
end

lines.set_first_line(yyvs2.item (yyvsp2))
			  if in_list then 
			    lines.set_count(max_lines - 2) 
			  else 
			    lines.set_count(1) 
			  end 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 157 then
--|#line 554 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 554")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 158 then
--|#line 555 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 555")
end

lines.set_line_column (lines.first_line, yyvs2.item (yyvsp2)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 159 then
--|#line 557 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 557")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 160 then
--|#line 558 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 558")
end

lines.set_line_column (lines.first_line, yyvs2.item (yyvsp2)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp2 := yyvsp2 -1
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 161 then
--|#line 560 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 560")
end

message(once "Line number expected.",column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 + 1
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 162 then
--|#line 562 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 562")
end

message(once "Column number expected.",column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 163 then
--|#line 564 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 564")
end

message(once "Column number expected.",column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 164 then
--|#line 569 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 569")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 165 then
--|#line 570 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 570")
end

min := 1;  max := {INTEGER}.max_value; 
			  lines.set_count(checked_int(yyvs2.item (yyvsp2), False)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 166 then
--|#line 573 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 573")
end

min := lines.first_line;  max := {INTEGER}.max_value; 
			  lines.set_count(checked_int(yyvs2.item (yyvsp2), False)-lines.first_line+1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp2 := yyvsp2 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 167 then
--|#line 577 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 577")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 168 then
--|#line 578 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 578")
end

message(once "Line number expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 169 then
--|#line 580 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 580")
end

message(once "Line count expected.",column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 170 then
--|#line 582 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 582")
end

message(once "Last line number expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 171 then
--|#line 586 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 586")
end

if attached system.type_at(yyvs2.item (yyvsp2)) as t then
			    yyval7 := t
			  else
			    message(once "Invalid type number.", column) 
			  end 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp7 := yyvsp7 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 172 then
--|#line 593 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 593")
end

class_text := yyvs8.item (yyvsp8) 
			  if attached system.type_by_class_and_generics(yyvs8.item (yyvsp8).name, 0, False) as t then
			    yyval7 := t
			  else
			     message(once "Type not known.", column) 
			  end			 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp7 := yyvsp7 + 1
	yyvsp8 := yyvsp8 -1
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 173 then
--|#line 601 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 601")
end

int := count_stack.item
			  count_stack.remove
			  if attached system.type_by_class_and_generics(yyvs8.item (yyvsp8).name, int, False) as t then
			    yyval7 := t
			    system.pop_types(int) 
			  else
			    system.pop_types(int) 
			    message(once "Type not known.", column) 
			  end			 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp7 := yyvsp7 + 1
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -2
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 174 then
--|#line 612 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 612")
end

yyvs6.item (yyvsp6).compute(debugger.shown_frame, value_stack) 
			  if attached yyvs6.item (yyvsp6).bottom.type as bt then
			    yyval7 := bt
			  end
			  value_stack.pop(1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp7 := yyvsp7 + 1
	yyvsp1 := yyvsp1 -1
	yyvsp6 := yyvsp6 -1
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 175 then
--|#line 619 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 619")
end

count_stack.wipe_out
			  message(once "Right bracket expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp7 := yyvsp7 + 1
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -2
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 176 then
--|#line 622 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 622")
end

count_stack.wipe_out
			  message(once "Generic parameters expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp7 := yyvsp7 + 1
	yyvsp8 := yyvsp8 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 177 then
--|#line 627 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 627")
end

yyval8 := yyvs8.item (yyvsp8) 
			  count_stack.force(0)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines8.force (yyvs8, yyval8, yyvsp8)
end
when 178 then
--|#line 632 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 632")
end

system.push_type(yyvs7.item (yyvsp7).ident) 
			  count_stack.replace(count_stack.item + 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp1 := yyvsp1 + 1
	yyvsp7 := yyvsp7 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 179 then
--|#line 636 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 636")
end

system.push_type(yyvs7.item (yyvsp7).ident) 
			  count_stack.replace(count_stack.item + 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -1
	yyvsp7 := yyvsp7 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 180 then
--|#line 642 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 642")
end

yyval8 := class_by_name(yyvs3.item (yyvsp3))
			  lines.set_class(yyval8) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp8 := yyvsp8 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp8 >= yyvsc8 then
		if yyvs8 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs8")
			end
			create yyspecial_routines8
			yyvsc8 := yyInitial_yyvs_size
			yyvs8 := yyspecial_routines8.make (yyvsc8)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs8")
			end
			yyvsc8 := yyvsc8 + yyInitial_yyvs_size
			yyvs8 := yyspecial_routines8.resize (yyvs8, yyvsc8)
		end
	end
	yyspecial_routines8.force (yyvs8, yyval8, yyvsp8)
end
when 181 then
--|#line 647 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 647")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 182 then
--|#line 650 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 650")
end

status_what := 0 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 183 then
--|#line 652 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 652")
end

if attached keyword(yyvs3.item (yyvsp3), status_commands, once "keyword") as key then  
			    status_what := key.code   
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 184 then
--|#line 657 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 657")
end

if attached keyword(once "", status_commands, once "keyword") as key then  
			    status_what := key.code   
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 185 then
--|#line 664 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 664")
end

status_what := Store_CODE 
			  file_name := ""
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 186 then
--|#line 668 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 668")
end

status_what := Store_CODE 
			  file_name := yyvs3.item (yyvsp3)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 187 then
--|#line 672 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 672")
end

status_what := Store_CODE 
			  file_name := yyvs3.item (yyvsp3)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 188 then
--|#line 676 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 676")
end

message(No_file_name, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 189 then
--|#line 680 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 680")
end

status_what := Restore_CODE 
			  file_name := ""
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 190 then
--|#line 684 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 684")
end

status_what := Restore_CODE 
			  file_name := yyvs3.item (yyvsp3)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 191 then
--|#line 688 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 688")
end

status_what := Restore_CODE 
			  file_name := yyvs3.item (yyvsp3)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 + 1
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp1 >= yyvsc1 then
		if yyvs1 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs1")
			end
			create yyspecial_routines1
			yyvsc1 := yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.make (yyvsc1)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs1")
			end
			yyvsc1 := yyvsc1 + yyInitial_yyvs_size
			yyvs1 := yyspecial_routines1.resize (yyvs1, yyvsc1)
		end
	end
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 192 then
--|#line 692 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 692")
end

message(No_file_name, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines1.force (yyvs1, yyval1, yyvsp1)
end
when 193 then
--|#line 696 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 696")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 194 then
--|#line 699 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 699")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 195 then
--|#line 702 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 702")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 196 then
--|#line 706 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 706")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 197 then
--|#line 708 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 708")
end

yyval6 := yyvs6.item (yyvsp6 - 1) 
			  yyval6.last.set_next(yyvs6.item (yyvsp6)) 
			  if yyval6.is_detailed then 
			    placeholders.finish
			    placeholders.remove
			  end 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 198 then
--|#line 716 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 716")
end

yyval6 := yyvs6.item (yyvsp6) 
			  message(No_expression,column-1) 
			  recover 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 199 then
--|#line 723 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 723")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 200 then
--|#line 725 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 725")
end

yyval6 := yyvs6.item (yyvsp6 - 1) 
			  yyval6.set_detail(yyvs6.item (yyvsp6)) 
			  check not placeholders.is_empty end 
			  placeholders.finish
			  placeholders.remove
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 201 then
--|#line 732 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 732")
end

message(once "Right double brace expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 202 then
--|#line 734 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 734")
end

message(once "Expression expected.", column) 
			  recover 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 203 then
--|#line 741 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 741")
end

yyval6 := yyvs6.item (yyvsp6) 
			  placeholders.force(yyvs6.item (yyvsp6).bottom) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 204 then
--|#line 745 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 745")
end

message(once "Left double brace expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 205 then
--|#line 749 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 749")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 206 then
--|#line 751 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 751")
end

create yyval6.make_as_all(1, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 207 then
--|#line 753 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 753")
end

create yyval6.make_as_all(yyvs2.item (yyvsp2), column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -1
	yyvsp2 := yyvsp2 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 208 then
--|#line 757 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 757")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 209 then
--|#line 759 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 759")
end

yyval6 := yyvs6.item (yyvsp6 - 1) 
			  yyval6.bottom.set_arg(yyvs6.item (yyvsp6)) 
			  placeholders.finish
			  placeholders.remove
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 210 then
--|#line 765 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 765")
end

message(once "Right double bracket expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 211 then
--|#line 767 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 767")
end

message(once "Indices expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 212 then
--|#line 771 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 771")
end

create {DG_RANGE_EXPRESSION} yyval6.make(yyvs6.item (yyvsp6), yyvs6.item (yyvsp6).column) 
			  placeholders.force(yyval6) 
			  yyval6 := yyvs6.item (yyvsp6) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 213 then
--|#line 778 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 778")
end

yyval6 := yyvs6.item (yyvsp6 - 1) 
			  yyval6.set_next(yyvs6.item (yyvsp6)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 214 then
--|#line 782 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 782")
end

create yyval6.make(yyvs6.item (yyvsp6).column)
			  yyval6.set_entity(count_entity)
			  yyval6.set_arg(yyvs6.item (yyvsp6))
			  yyvs6.item (yyvsp6 - 1).set_next(yyval6)
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 215 then
--|#line 789 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 789")
end

create yyval6.make(column)
			  yyval6.set_entity(all_entity) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 216 then
--|#line 793 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 793")
end

create yyval6.make(yyvs6.item (yyvsp6).column)
			  yyval6.set_down(yyvs6.item (yyvsp6)) 
			  yyval6.set_entity(if_entity) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 217 then
--|#line 798 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 798")
end

message(No_expression, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -2
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 218 then
--|#line 800 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 800")
end

message(once "Count or upper index expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 219 then
--|#line 802 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 802")
end

message(once "Upper index expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 220 then
--|#line 806 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 806")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 221 then
--|#line 808 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 808")
end

compose_prefix(yyvs6.item (yyvsp6), plus_op) 
			  yyval6 := yyvs6.item (yyvsp6) 
			 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 222 then
--|#line 812 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 812")
end

compose_prefix(yyvs6.item (yyvsp6), minus_op) 
			  yyval6 := yyvs6.item (yyvsp6) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 223 then
--|#line 816 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 816")
end

compose_prefix(yyvs6.item (yyvsp6), not_op) 
			  yyval6 := yyvs6.item (yyvsp6) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 224 then
--|#line 820 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 820")
end

compose_free(Void, yyvs6.item (yyvsp6), yyvs3.item (yyvsp3)) 
			  yyval6 := yyvs6.item (yyvsp6) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 225 then
--|#line 824 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 824")
end

message(once "Operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 226 then
--|#line 826 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 826")
end

message(once "Operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 227 then
--|#line 828 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 828")
end

message(once "Operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -2
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 228 then
--|#line 830 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 830")
end

message(once "Operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 229 then
--|#line 832 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 832")
end

compose_free(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),yyvs3.item (yyvsp3)) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 230 then
--|#line 836 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 836")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),power_op,7,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 231 then
--|#line 840 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 840")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),mult_op,6,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 232 then
--|#line 844 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 844")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),div_op,6,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 233 then
--|#line 848 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 848")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),idiv_op,6,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 234 then
--|#line 852 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 852")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),imod_op,6,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 235 then
--|#line 856 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 856")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),plus_op,5,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 236 then
--|#line 860 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 860")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),minus_op,5,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 237 then
--|#line 864 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 864")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),interval_op,5,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 238 then
--|#line 868 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 868")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),eq_op,4,equality_entity) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 239 then
--|#line 872 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 872")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),ne_op,4,equality_entity) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 240 then
--|#line 876 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 876")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),sim_op,4,equality_entity) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 241 then
--|#line 880 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 880")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),nsim_op,4,equality_entity) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 242 then
--|#line 884 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 884")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),lt_op,4,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 243 then
--|#line 888 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 888")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),le_op,4,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 244 then
--|#line 892 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 892")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),gt_op,4,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 245 then
--|#line 896 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 896")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),ge_op,4,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp3 := yyvsp3 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 246 then
--|#line 900 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 900")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),and_op,3,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 247 then
--|#line 904 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 904")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),or_op,2,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 248 then
--|#line 908 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 908")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),2,xor_op,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 249 then
--|#line 912 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 912")
end

compose_infix(yyvs6.item (yyvsp6 - 1),yyvs6.item (yyvsp6),implies_op,1,Void) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 250 then
--|#line 916 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 916")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 251 then
--|#line 918 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 918")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 252 then
--|#line 920 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 920")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 253 then
--|#line 922 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 922")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 254 then
--|#line 924 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 924")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 255 then
--|#line 926 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 926")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 256 then
--|#line 928 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 928")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 257 then
--|#line 930 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 930")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 258 then
--|#line 932 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 932")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 259 then
--|#line 934 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 934")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 260 then
--|#line 936 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 936")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 261 then
--|#line 938 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 938")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 262 then
--|#line 940 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 940")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 263 then
--|#line 942 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 942")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 264 then
--|#line 944 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 944")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 265 then
--|#line 946 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 946")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 266 then
--|#line 948 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 948")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 267 then
--|#line 950 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 950")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 268 then
--|#line 952 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 952")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 269 then
--|#line 954 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 954")
end

message(once "Right operand expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 270 then
--|#line 958 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 958")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 271 then
--|#line 960 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 960")
end

yyval6 := yyvs6.item (yyvsp6 - 1) 
			  if yyvs6.item (yyvsp6).entity = details_entity then 
			    yyval6.bottom.set_detail(yyvs6.item (yyvsp6)) 
			    yyvs6.item (yyvsp6).set_parent(yyval6.bottom) 
			  else 
			    yyval6.bottom.set_down(yyvs6.item (yyvsp6)) 
			  end 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 272 then
--|#line 969 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 969")
end

create yyval6.make_as_down(yyvs6.item (yyvsp6 - 1), yyvs6.item (yyvsp6).column) 
			  yyval6.set_entity(bracket_entity) 
			  yyval6.set_arg(yyvs6.item (yyvsp6)) 
			  yyval6 := yyvs6.item (yyvsp6 - 1) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 273 then
--|#line 977 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 977")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 274 then
--|#line 979 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 979")
end

if yyvs6.item (yyvsp6).is_manifest and then yyvs6.item (yyvsp6).entity /= details_entity then 
			    message(once "Immediate alias name must not be qualified.", column) 
			  end 
			  yyval6 := yyvs6.item (yyvsp6) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 275 then
--|#line 987 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 987")
end

yyval2 := 1 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 276 then
--|#line 989 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 989")
end

yyval2 := yyvs2.item (yyvsp2) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 277 then
--|#line 993 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 993")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 278 then
--|#line 995 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 995")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 279 then
--|#line 997 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 997")
end

yyval6 := yyvs6.item (yyvsp6) 
			  yyval6.set_up_frame_count(yyvs2.item (yyvsp2)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp2 := yyvsp2 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 280 then
--|#line 1001 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1001")
end

if yyvs6.item (yyvsp6).entity = details_entity then 
			    message(once "Details may not start an expression.", column) 
			  end 
			  yyval6 := yyvs6.item (yyvsp6) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 281 then
--|#line 1007 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1007")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 282 then
--|#line 1009 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1009")
end

message(once "Right parenthesis expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 283 then
--|#line 1011 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1011")
end

message(No_expression, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -3
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 284 then
--|#line 1013 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1013")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 285 then
--|#line 1015 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1015")
end

create yyval6.make(column) 
			  yyval6.set_manifest(Character_ident, text) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp4 := yyvsp4 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 286 then
--|#line 1019 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1019")
end

create yyval6.make(column)
			  yyval6.set_manifest(String8_ident, yyvs3.item (yyvsp3)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 287 then
--|#line 1022 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1022")
end

create yyval6.make(column)
			  yyval6.set_manifest(Integer_ident, text) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp2 := yyvsp2 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 288 then
--|#line 1025 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1025")
end

create yyval6.make(column)
			  yyval6.set_manifest(Real64_ident, text) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp5 := yyvsp5 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 289 then
--|#line 1035 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1035")
end

create yyval6.make_from_feature(yyvs8.item (yyvsp8), feature_by_name(yyvs3.item (yyvsp3), yyvs8.item (yyvsp8), False), column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -3
	yyvsp8 := yyvsp8 -1
	yyvsp3 := yyvsp3 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 290 then
--|#line 1037 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1037")
end

if placeholders.is_empty then 
			    message(once "Placeholders are not allowed here.", column) 
			  elseif placeholders.count < yyvs3.item (yyvsp3).count then 
			    message(once "Not as many nested details.", column)
			  end 
			  ph := placeholders[placeholders.count-yyvs3.item (yyvsp3).count+1]
			  if attached ph as p then
			    if yyvs3.item (yyvsp3)[1]=':' and then not p.is_range then 
			      message(once "Index placeholders are not allowed here.", column) 
			    end 
			    create yyval6.make(column - 1)
			    yyval6.set_entity(placeholder_entity) 
			    yyval6.set_name(yyvs3.item (yyvsp3)) 
			    yyval6.set_parent(p) 
			  end 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 291 then
--|#line 1056 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1056")
end

alias_name := yyvs3.item (yyvsp3) 
			  single := yyvs6.item (yyvsp6) 
			  if attached single as s then
			    s.compute(debugger.shown_frame, value_stack)
			  end
			  is_lazy := False 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyvsp6 := yyvsp6 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 292 then
--|#line 1064 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1064")
end

alias_name := yyvs3.item (yyvsp3 - 1) 
			  single := yyvs6.item (yyvsp6) 
			  is_lazy := True 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp2 := yyvsp2 -1
	yyvsp3 := yyvsp3 -2
	yyvsp6 := yyvsp6 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 293 then
--|#line 1064 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1064")
end

forbidden_closure := True
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 294 then
--|#line 1069 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1069")
end

if attached single as s then
			    s.set_detail(yyvs6.item (yyvsp6)) 
			  end
			  is_lazy := True 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 8
	yyvsp2 := yyvsp2 -2
	yyvsp3 := yyvsp3 -2
	yyvsp1 := yyvsp1 -2
	yyvsp6 := yyvsp6 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 295 then
--|#line 1069 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1069")
end

forbidden_closure := True
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 296 then
--|#line 1069 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1069")
end

			  alias_name := yyvs3.item (yyvsp3 - 1) 
			  create single.make(column) 
			  if attached single as s then
				  s.set_entity(details_entity) 
				  placeholders.force(s) 
			  end
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 297 then
--|#line 1084 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1084")
end

alias_name := yyvs3.item (yyvsp3);  single := Void 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 298 then
--|#line 1086 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1086")
end

message(once "Expression expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 299 then
--|#line 1088 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1088")
end

message(once "Expression expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 300 then
--|#line 1090 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1090")
end

message(once "One of `->', `:=' or `--' expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 301 then
--|#line 1092 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1092")
end

message(once "Alias name to be defined expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp1 := yyvsp1 -1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 302 then
--|#line 1096 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1096")
end

yyval3 := yyvs3.item (yyvsp3) 
			  op_column := column
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 303 then
--|#line 1100 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1100")
end

yyval3 := yyvs3.item (yyvsp3) 
			  op_column := column
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
when 304 then
--|#line 1106 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1106")
end

yyval6 := as_alias(yyvs3.item (yyvsp3))
			  yyval6 := yyval6.twin
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 305 then
--|#line 1112 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1112")
end

tmp_str.copy(yyvs3.item (yyvsp3))
			  tmp_str.remove(1)
			  yyval6 := int_to_closure(tmp_str.to_natural_32)
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 306 then
--|#line 1119 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1119")
end

create yyval6.make(op_column) 
			  yyval6.set_name(yyvs3.item (yyvsp3)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 307 then
--|#line 1123 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1123")
end

create yyval6.make(op_column) 
			  yyval6.set_name(yyvs3.item (yyvsp3)) 
			  yyval6.set_arg(yyvs6.item (yyvsp6)) 
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 308 then
--|#line 1128 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1128")
end

message(No_expression, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -2
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 309 then
--|#line 1130 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1130")
end

message(once "Right parenthesis expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 310 then
--|#line 1132 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1132")
end

message(No_expression, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 + 1
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -2
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 311 then
--|#line 1136 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1136")
end

create yyval6.make_from_type(yyvs7.item (yyvsp7), Void, int) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp7 := yyvsp7 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 312 then
--|#line 1138 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1138")
end

create yyval6.make_from_type(yyvs7.item (yyvsp7), yyvs6.item (yyvsp6), int) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp7 := yyvsp7 -1
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 313 then
--|#line 1140 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1140")
end

message(once "Exclamation mark or colon expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp7 := yyvsp7 -1
	yyvsp1 := yyvsp1 -1
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 314 then
--|#line 1144 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1144")
end

yyval7 := yyvs7.item (yyvsp7) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp7 := yyvsp7 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 315 then
--|#line 1144 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1144")
end

int:=column
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp7 := yyvsp7 + 1
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 316 then
--|#line 1146 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1146")
end

message(No_type, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp7 := yyvsp7 + 1
	yyvsp1 := yyvsp1 -2
	if yyvsp7 >= yyvsc7 then
		if yyvs7 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs7")
			end
			create yyspecial_routines7
			yyvsc7 := yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.make (yyvsc7)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs7")
			end
			yyvsc7 := yyvsc7 + yyInitial_yyvs_size
			yyvs7 := yyspecial_routines7.resize (yyvs7, yyvsc7)
		end
	end
	yyspecial_routines7.force (yyvs7, yyval7, yyvsp7)
end
when 317 then
--|#line 1150 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1150")
end

yyval6 := yyvs6.item (yyvsp6) 
			  op_column := column
			
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 318 then
--|#line 1154 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1154")
end

message(once "Right bracket expected.", column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 319 then
--|#line 1156 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1156")
end

message(No_expression, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp6 := yyvsp6 + 1
	yyvsp1 := yyvsp1 -2
	if yyvsp6 >= yyvsc6 then
		if yyvs6 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs6")
			end
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs6")
			end
			yyvsc6 := yyvsc6 + yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.resize (yyvs6, yyvsc6)
		end
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 320 then
--|#line 1160 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1160")
end

yyval6 := yyvs6.item (yyvsp6) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 321 then
--|#line 1162 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1162")
end

yyval6 := yyvs6.item (yyvsp6 - 1);  yyval6.last.set_next(yyvs6.item (yyvsp6)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp6 := yyvsp6 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 322 then
--|#line 1164 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1164")
end

message(No_expression, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
when 323 then
--|#line 1168 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1168")
end

yyval2 := checked_int(int, True) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp2 := yyvsp2 + 1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 324 then
--|#line 1170 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1170")
end

yyval2 := checked_int(yyvs2.item (yyvsp2), False) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
when 325 then
--|#line 1172 "dg_parser.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_parser.y' at line 1172")
end

message(No_integer, column) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp2 := yyvsp2 + 1
	yyvsp1 := yyvsp1 -1
	if yyvsp2 >= yyvsc2 then
		if yyvs2 = Void then
			debug ("GEYACC")
				std.error.put_line ("Create yyvs2")
			end
			create yyspecial_routines2
			yyvsc2 := yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.make (yyvsc2)
		else
			debug ("GEYACC")
				std.error.put_line ("Resize yyvs2")
			end
			yyvsc2 := yyvsc2 + yyInitial_yyvs_size
			yyvs2 := yyspecial_routines2.resize (yyvs2, yyvsc2)
		end
	end
	yyspecial_routines2.force (yyvs2, yyval2, yyvsp2)
end
			else
				debug ("GEYACC")
					std.error.put_string ("Error in parser: unknown rule id: ")
					std.error.put_integer (yy_act)
					std.error.put_new_line
				end
				abort
			end
		end

	yy_do_error_action (yy_act: INTEGER)
			-- Execute error action.
		do
			inspect yy_act
			when 428 then
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
			    2,    2,    2,  121,    2,    2,    2,    2,    2,    2,
			  118,  119,   94,   98,  111,   99,  114,   95,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,  113,    2,
			   91,   85,   89,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,  116,    2,  115,   92,    2,  112,    2,    2,    2,

			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,  117,    2,  120,  109,    2,    2,    2,
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
			    5,    6,    7,    8,    9,   10,   11,   12,   13,   14,
			   15,   16,   17,   18,   19,   20,   21,   22,   23,   24,
			   25,   26,   27,   28,   29,   30,   31,   32,   33,   34,
			   35,   36,   37,   38,   39,   40,   41,   42,   43,   44,

			   45,   46,   47,   48,   49,   50,   51,   52,   53,   54,
			   55,   56,   57,   58,   59,   60,   61,   62,   63,   64,
			   65,   66,   67,   68,   69,   70,   71,   72,   73,   74,
			   75,   76,   77,   78,   79,   80,   81,   82,   83,   84,
			   86,   87,   88,   90,   93,   96,   97,  100,  101,  102,
			  103,  104,  105,  106,  107,  108,  110, yyDummy>>)
		end

	yyr1_template: SPECIAL [INTEGER]
			-- Template for `yyr1'
		once
			Result := yyfixed_array (<<
			    0,  122,  188,  122,  122,  122,  122,  122,  122,  122,
			  122,  122,  122,  122,  122,  122,  122,  122,  122,  122,
			  122,  122,  122,  122,  122,  122,  122,  122,  122,  122,
			  122,  122,  122,  122,  122,  122,  122,  123,  123,  123,
			  123,  189,  190,  187,  187,  191,  124,  125,  199,  125,
			  192,  192,  200,  192,  193,  193,  201,  193,  194,  202,
			  194,  127,  127,  127,  127,  126,  204,  126,  205,  203,
			  131,  131,  131,  206,  131,  128,  128,  207,  128,  132,
			  132,  132,  132,  133,  133,  133,  129,  129,  129,  130,
			  130,  208,  130,  134,  134,  209,  134,  135,  135,  135,

			  154,  136,  137,  210,  137,  211,  137,  212,  138,  138,
			  185,  185,  139,  139,  139,  139,  186,  186,  195,  195,
			  213,  214,  195,  141,  141,  141,  141,  196,  196,  144,
			  146,  142,  142,  142,  143,  143,  143,  145,  148,  147,
			  147,  215,  149,  149,  216,  216,  216,  216,  181,  181,
			  181,  181,  181,  178,  178,  178,  179,  180,  180,  180,
			  180,  180,  180,  180,  182,  182,  182,  182,  182,  182,
			  182,  174,  174,  174,  174,  174,  174,  177,  217,  217,
			  176,  150,  151,  151,  151,  197,  197,  197,  197,  198,
			  198,  198,  198,  152,  153,  155,  170,  170,  170,  168,

			  168,  168,  168,  169,  169,  171,  171,  171,  166,  166,
			  166,  166,  167,  163,  163,  163,  163,  163,  163,  163,
			  165,  165,  165,  165,  165,  165,  165,  165,  165,  165,
			  165,  165,  165,  165,  165,  165,  165,  165,  165,  165,
			  165,  165,  165,  165,  165,  165,  165,  165,  165,  165,
			  165,  165,  165,  165,  165,  165,  165,  165,  165,  165,
			  165,  165,  165,  165,  165,  165,  165,  165,  165,  165,
			  156,  156,  156,  161,  161,  183,  183,  157,  157,  157,
			  157,  157,  157,  157,  157,  157,  157,  157,  157,  157,
			  157,  140,  140,  218,  140,  219,  220,  140,  140,  140,

			  140,  140,  173,  173,  160,  172,  158,  158,  158,  158,
			  158,  159,  159,  159,  175,  221,  175,  164,  164,  164,
			  162,  162,  162,  184,  184,  184, yyDummy>>)
		end

	yytypes1_template: SPECIAL [INTEGER]
			-- Template for `yytypes1'
		once
			Result := yyfixed_array (<<
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    3,    3,    1,    3,    3,
			    1,    3,    1,    3,    2,    1,    8,    2,    2,    2,
			    2,    1,    2,    1,    7,    8,    8,    1,    7,    3,

			    1,    6,    1,    4,    1,    4,    3,    1,    4,    4,
			    1,    1,    1,    1,    3,    3,    3,    3,    3,    3,
			    5,    2,    4,    2,    3,    3,    3,    1,    6,    6,
			    6,    6,    6,    6,    6,    3,    7,    2,    1,    6,
			    2,    2,    2,    1,    1,    3,    1,    1,    3,    1,
			    1,    2,    2,    1,    2,    3,    3,    3,    3,    3,
			    3,    3,    2,    1,    1,    1,    1,    3,    8,    9,
			    2,    2,    2,    1,    6,    1,    1,    7,    1,    4,
			    1,    6,    1,    3,    1,    1,    6,    6,    6,    6,
			    6,    6,    1,    7,    1,    6,    8,    1,    6,    1,

			    6,    1,    6,    1,    6,    1,    1,    6,    1,    1,
			    1,    1,    1,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    1,
			    1,    1,    1,    6,    1,    1,    2,    1,    2,    2,
			    2,    1,    1,    2,    2,    2,    2,    2,    2,    3,
			    1,    2,    2,    2,    2,    1,    3,    3,    1,    2,
			    1,    1,    9,    1,    1,    1,    1,    1,    1,    1,
			    1,    6,    1,    2,    2,    1,    1,    1,    1,    1,
			    1,    6,    6,    1,    1,    6,    6,    1,    7,    1,
			    1,    1,    1,    1,    6,    6,    6,    6,    6,    1,

			    6,    1,    6,    1,    6,    1,    6,    1,    6,    6,
			    1,    6,    1,    6,    1,    6,    1,    6,    1,    6,
			    1,    6,    1,    6,    1,    6,    1,    6,    1,    6,
			    1,    6,    1,    6,    1,    6,    1,    6,    1,    6,
			    1,    1,    6,    6,    1,    6,    1,    1,    1,    3,
			    1,    2,    3,    1,    1,    1,    2,    2,    1,    2,
			    1,    7,    6,    6,    1,    1,    6,    1,    1,    1,
			    1,    2,    1,    1,    1,    6,    1,    1,    1,    1,
			    1,    1,    1,    2,    3,    1,    3,    2,    3,    2,
			    2,    1,    2,    1,    6,    1,    6,    3,    1,    6,

			    2,    2,    1,    2,    3,    6,    1,    1,    6,    2,
			    3,    1,    1,    7,    1,    3,    1,    3,    2,    3,
			    6,    1,    3,    2,    3,    4,    1,    6,    2,    1,
			    1, yyDummy>>)
		end

	yytypes2_template: SPECIAL [INTEGER]
			-- Template for `yytypes2'
		once
			Result := yyfixed_array (<<
			    1,    1,    1,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    1,    1,    1,    1,    1,    3,    3,
			    3,    3,    3,    4,    2,    4,    2,    5,    3,    3,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    3,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,

			    3,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1, yyDummy>>)
		end

	yydefact_template: SPECIAL [INTEGER]
			-- Template for `yydefact'
		once
			Result := yyfixed_array (<<
			    0,   36,    0,    0,  195,  194,  193,    0,  181,    0,
			    0,  141,  130,  137,    0,    0,    0,  116,    0,  129,
			  110,    0,    0,  107,  105,  103,  101,    0,    0,    0,
			   66,  100,    0,   46,   45,   43,   43,   43,   43,   43,
			   43,    2,    6,    7,    8,   13,   14,   15,   16,   18,
			   19,   22,   23,   21,   24,   25,   26,   27,   28,   29,
			   30,   33,   34,   12,   35,    3,    4,    5,    9,   10,
			   11,   17,   20,   31,   32,  191,  190,  192,  187,  186,
			  188,  183,  184,  180,  156,  143,    0,  157,  142,  138,
			    0,    0,  171,  136,  135,  172,    0,  133,  132,  305,

			  122,  118,    0,  117,  114,    0,    0,  301,  111,  108,
			    0,    0,    0,    0,    0,    0,    0,  275,  286,  302,
			  288,  287,  285,  276,  290,  304,  303,  128,  220,  270,
			  277,  278,  280,  127,  284,  306,    0,    0,  126,    0,
			    0,    0,    0,   60,    0,   54,   57,    0,   50,   53,
			    0,   68,   70,   49,    0,   44,   40,   42,   41,   39,
			   38,   37,    0,    0,  161,    0,    0,    0,  148,  151,
			  152,    0,  140,  167,  174,  177,  176,  178,    0,  121,
			  115,  113,    0,    0,  297,  300,  208,  199,    0,  196,
			    0,  109,  316,    0,    0,    0,    0,  227,  223,  226,

			  222,  225,  221,  228,  224,    0,    0,  272,    0,    0,
			    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
			    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
			  311,    0,  313,  279,    0,  125,  324,  325,  106,  104,
			  102,   64,   63,   61,   58,   55,   51,   70,    0,   75,
			   65,   47,    1,    0,  158,  163,  153,  154,  155,  144,
			  147,    0,  149,    0,    0,  168,  173,    0,  175,    0,
			  298,  291,  299,    0,    0,  212,  204,  203,  215,    0,
			  211,    0,  218,  206,  202,  205,    0,    0,  314,  283,
			  281,  282,    0,  319,    0,  320,  273,  274,  271,  264,

			  240,  266,  246,  268,  248,  267,  247,  269,  249,  237,
			  257,  236,  256,  235,  250,  229,  254,  233,  253,  232,
			  252,  231,  255,  234,  251,  230,  260,  242,  262,  243,
			  261,  244,  263,  245,  265,  241,  259,  239,  258,  238,
			  308,  310,    0,    0,  124,  123,    0,   67,   73,   71,
			   74,   77,   79,    0,  162,    0,  150,  165,  169,  166,
			  170,  179,  119,  292,  296,  217,  216,    0,  210,    0,
			    0,  207,  200,  201,  198,  197,    0,  317,    0,  318,
			  307,  309,  312,   62,   72,   78,    0,    0,   83,  160,
			  145,  146,    0,  209,  214,  219,  213,  289,  322,  321,

			   76,   80,   82,    0,   86,    0,   81,   85,   84,    0,
			   89,  294,   88,   87,   91,   93,   92,    0,   95,   97,
			   90,   96,  110,   98,   69,    0,   99,   94,    0,    0,
			    0, yyDummy>>)
		end

	yydefgoto_template: SPECIAL [INTEGER]
			-- Template for `yydefgoto'
		once
			Result := yyfixed_array (<<
			  428,   41,   42,   43,   44,  244,  352,  410,  415,  249,
			  388,  404,  419,  424,   45,   46,   47,   48,   49,   50,
			   51,   52,   53,   54,   55,   56,   57,   58,   59,   60,
			   61,   62,   63,   64,  128,  129,  130,  131,  132,  298,
			  294,  281,  207,  186,  187,  188,  189,  190,  191,  286,
			  134,  135,   94,  136,   95,   96,  169,   87,   88,  171,
			  172,  137,  238,  109,  105,  156,  162,   65,   66,   67,
			   68,   69,   70,   71,   72,   73,   74,  154,  150,  147,
			  144,  250,  152,  247,  384,  386,  417,  422,  142,  141,
			  140,  102,  269,   90,  173,  178,  273,  274,  392,  193, yyDummy>>)
		end

	yypact_template: SPECIAL [INTEGER]
			-- Template for `yypact'
		once
			Result := yyfixed_array (<<
			 2010, -32768,   28,   18, -32768, -32768, -32768,   44, -32768,   47,
			   -2,  352, -32768, -32768,  149,   14,  243,  234,   48, -32768,
			   26, 1723, 1654, -32768, -32768, -32768, -32768,  169,  171,   76,
			  285, -32768,  185, -32768, -32768,  279,  279,  279,  279,  279,
			  279, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768,   31,  232, -32768, -32768,
			  186, 1866, -32768, -32768, -32768,  230,  173, -32768, -32768, -32768,

			 -32768, -32768,  280, -32768, -32768,   42,   16, -32768, -32768, 1866,
			  152, 1639,  276, 1570, 1555, 1486, 1471, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,  150, -32768,
			 -32768, -32768, -32768, 2043, -32768,  224,    8,   -1, -32768, 1795,
			   25,   25,   25, -32768,  -16, -32768, -32768,  -16, -32768, -32768,
			  -16, -32768,  294, -32768,  275, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768,   25,  238, -32768,  177,  113,  174,  -67, -32768,
			 -32768,   34, -32768, -32768, 2043, -32768, -32768, -32768,   21, -32768,
			 -32768, 2043, 1402,  295, -32768, -32768, 1903,  -44,   59, -32768,
			  210,  -91, -32768,  199,  221, 1760,  218, -32768, -32768, -32768,

			 -32768, -32768, -32768, -32768, -32768, 1387,  231, -32768, 1318, 1303,
			 1234, 1219, 1150, 1866, 1135, 1066, 1051,  982,  967,  898,
			  883,  814,  799,  730,  715,  646,  631,  562,  547,  163,
			 -32768, 1866, -32768, -32768,  478, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768,  228,  228,  228,  294,  -17,  288,
			 -32768, -32768, -32768,   30, -32768, -32768, -32768, -32768, -32768,  193,
			 -32768,  238, -32768,  172,  146, -32768, -32768,  199, -32768,  241,
			 -32768, 2043, -32768, 1866,  240, -32768, -32768, -32768, -32768,  463,
			 -32768,   23, 2015,  227, -32768,  -91,   15,  394, -32768, -32768,
			 -32768, -32768,  184, -32768,   20, 2043, -32768, -32768, -32768, -32768,

			  219, -32768, 1714, -32768, 2093, -32768, 2093, -32768, 2068,  195,
			 -32768,  229, -32768,  229, -32768, -32768, -32768,  194, -32768,  194,
			 -32768,  194, -32768,  194, -32768,  194, -32768,  219, -32768,  219,
			 -32768,  219, -32768,  219, -32768,  219, -32768,  219, -32768,  219,
			 -32768, -32768,   11, 1978, -32768, 2043,  206, -32768, -32768, -32768,
			 -32768,  200,  201,  179, -32768,   22, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, 2043,  119, -32768, 1866,
			  379, -32768, -32768, -32768, -32768, -32768,  158, -32768,  309, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768,   -2,  -26,  181, -32768,
			 -32768, -32768, 1866, -32768, 2043, -32768, 2043, -32768, -32768, 2043,

			 -32768,  157, -32768, 1852,  139,  -43, -32768, -32768, 2043,  -12,
			   92, -32768, -32768, -32768,  130,  140, -32768, 1866,  109,  145,
			 2043, -32768,   26,    6, -32768, 1866, -32768,  -91,   65,   52,
			 -32768, yyDummy>>)
		end

	yypgoto_template: SPECIAL [INTEGER]
			-- Template for `yypgoto'
		once
			Result := yyfixed_array (<<
			 -32768, -32768, -32768, -32768, -32768,   69, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -127, -32768,  166, -32768,
			  142, -32768, -32768,  -21, -32768, -32768, -234, -32768, -183, -32768,
			  -10, -32768,  -11, -32768,   -7, -32768,  198,  -82,   -5, -32768,
			 -32768, -32768, -104,  -57, -32768,  296, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768,  111, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768,
			 -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, -32768, yyDummy>>)
		end

	yytable_template: SPECIAL [INTEGER]
			-- Template for `yytable'
		local
			an_array: ARRAY [INTEGER]
		once
			create an_array.make_filled (0, 0, 2202)
			yytable_template_1 (an_array)
			yytable_template_2 (an_array)
			yytable_template_3 (an_array)
			Result := yyfixed_array (an_array)
		end

	yytable_template_1 (an_array: ARRAY [INTEGER])
			-- Fill chunk #1 of template for `yytable'.
		do
			yyarray_subcopy (an_array, <<
			  133,  139,   86,   86,   98,   89,  101,  285,  170,  232,
			  233,  277,  381,  411, -131,   97,  373,  185, -185,   80,
			  287,  379,  268,  391,  368, -323,  237,  402, -189,   77,
			 -159,  354,  164, -159, -164,  265,  350,  239,  240,  363,
			  401,  412, -112,  180, -182,   82,  261,  166,   85,  107,
			  243,  349,  430,  375,   92, -159,   83,  126,  252,  426,
			  280,  348,  242,  241,   84,  429,   83,  119,  287,  184,
			  174,  372,   91,  276, -159, -159, -159,  149,  183,  296,
			   92,  253,   83,  168,  181,  177,   79,   78,  390,  108,
			  195,  236,  198,  200,  202,  204,   76,   75,   91,  182,

			  126,  125,   99,  124, -159,  196,  123,  122,  121,  120,
			  119,  118,   81,   84,  258,   83,  106,  126,  125,   99,
			  124,  231,  378,  123,  122,  121,  120,  119,  118,  230,
			  380,  378,  267,  279,  117,  377,  266,  278,  367,  116,
			  115,  114,  -52,  353,  163,  264,  263,  360,  423, -134,
			   93,  117,  113,  192,  -52,  -52,  116,  115,  114,  112,
			  111,  271,  421,  110,  341,  418,  414,  282,  148,  113,
			  143,  257,  146,  358,  176,  260,  112,  111,  255,  356,
			  110,  256,  288,  416,  295,  409,  153,  300,  302,  304,
			  306,  308,  309,  311,  313,  315,  317,  319,  321,  323,

			  325,  327,  329,  331,  333,  335,  337,  339,  295,  405,
			  343,  284,  359,  345,  406,   92,  245,   83, -315,  246,
			 -315,  126,  125,   99,  124,  403,  397,  123,  122,  121,
			  120,  119,  118,   91,  393,  -59, -315,  -56,  357,   92,
			  259,   83,  427,  254,  100,  389,  387,  -59,  -59,  -56,
			  -56,  -48,   84,  385,   83,  117,  361,   91,  366,  362,
			  116,  115,  114,  145,  206,   92,  205,   83,  126,  125,
			   99,  124,  383,  113,  123,  122,  121,  120,  119,  118,
			  112,  111,  340,   91,  110,  167,  221,  104,  283,  126,
			  125,  216,  216,  371,  213,  364,  272,  103,  376,  119,

			  166,   99,  117,   99,   84,  355, -120,  116,  115,  114,
			  398,  221,  220,  219,  218,  217,  216,  215,  214,  213,
			  113,  221,  220,  219,  218,  217,  216,  112,  111,  213,
			  351,  110,  157,  158,  159,  160,  161,  248,  292,  346,
			  289,  251,  229,  179,   83,  165,  175,  155,  394,  396,
			 -295,  151, -139, -293, -293, -293, -293,  399,  347, -293,
			 -293, -293, -293, -293, -293,  425,  262,  126,  125,   99,
			  124,  342,  297,  123,  122,  121,  120,  119,  118,   86,
			  395,  400,  408,    0,    0,    0,    0, -293,    0,    0,
			    0,    0, -293, -293, -293,  374,  420,    0,  413,    0,

			    0,  117,    0,    0,    0, -293,  116,  115,  114,    0,
			    0,    0, -293, -293,    0,    0, -293,    0,    0,  113,
			    0,    0,    0,    0,    0,    0,  112,  111,    0,    0,
			  110,    0,    0,    0,    0,    0,    0,  126,  125,   99,
			  124,    0,    0,  123,  122,  121,  120,  119,  118,    0,
			    0,    0,  126,  125,   99,  124,    0,    0,  123,  122,
			  121,  120,  119,  118,  365,    0,    0,    0,    0,    0,
			    0,  117,    0,    0,    0,    0,  116,  115,  114,  344,
			    0,    0,    0,    0,    0,    0,  117,    0,    0,  113,
			    0,  116,  115,  114,    0,    0,  112,  111,    0,    0,

			  110,    0,    0,    0,  113,    0,    0,    0,    0,    0,
			    0,  112,  111,    0,    0,  110,    0,    0,    0,    0,
			    0,  126,  125,   99,  124,    0,    0,  123,  122,  121,
			  120,  119,  118,    0,    0,    0,  126,  125,   99,  124,
			    0,    0,  123,  122,  121,  120,  119,  118,  338,    0,
			    0,    0,    0,    0,    0,  117,    0,    0,    0,    0,
			  116,  115,  114,  336,    0,    0,    0,    0,    0,    0,
			  117,    0,    0,  113,    0,  116,  115,  114,    0,    0,
			  112,  111,    0,    0,  110,    0,    0,    0,  113,    0,
			    0,    0,    0,    0,    0,  112,  111,    0,    0,  110,

			    0,    0,    0,    0,    0,  126,  125,   99,  124,    0,
			    0,  123,  122,  121,  120,  119,  118,    0,    0,    0,
			  126,  125,   99,  124,    0,    0,  123,  122,  121,  120,
			  119,  118,  334,    0,    0,    0,    0,    0,    0,  117,
			    0,    0,    0,    0,  116,  115,  114,  332,    0,    0,
			    0,    0,    0,    0,  117,    0,    0,  113,    0,  116,
			  115,  114,    0,    0,  112,  111,    0,    0,  110,    0,
			    0,    0,  113,    0,    0,    0,    0,    0,    0,  112,
			  111,    0,    0,  110,    0,    0,    0,    0,    0,  126,
			  125,   99,  124,    0,    0,  123,  122,  121,  120,  119,

			  118,    0,    0,    0,  126,  125,   99,  124,    0,    0,
			  123,  122,  121,  120,  119,  118,  330,    0,    0,    0,
			    0,    0,    0,  117,    0,    0,    0,    0,  116,  115,
			  114,  328,    0,    0,    0,    0,    0,    0,  117,    0,
			    0,  113,    0,  116,  115,  114,    0,    0,  112,  111,
			    0,    0,  110,    0,    0,    0,  113,    0,    0,    0,
			    0,    0,    0,  112,  111,    0,    0,  110,    0,    0,
			    0,    0,    0,  126,  125,   99,  124,    0,    0,  123,
			  122,  121,  120,  119,  118,    0,    0,    0,  126,  125,
			   99,  124,    0,    0,  123,  122,  121,  120,  119,  118,

			  326,    0,    0,    0,    0,    0,    0,  117,    0,    0,
			    0,    0,  116,  115,  114,  324,    0,    0,    0,    0,
			    0,    0,  117,    0,    0,  113,    0,  116,  115,  114,
			    0,    0,  112,  111,    0,    0,  110,    0,    0,    0,
			  113,    0,    0,    0,    0,    0,    0,  112,  111,    0,
			    0,  110,    0,    0,    0,    0,    0,  126,  125,   99,
			  124,    0,    0,  123,  122,  121,  120,  119,  118,    0,
			    0,    0,  126,  125,   99,  124,    0,    0,  123,  122,
			  121,  120,  119,  118,  322,    0,    0,    0,    0,    0,
			    0,  117,    0,    0,    0,    0,  116,  115,  114,  320,

			    0,    0,    0,    0,    0,    0,  117,    0,    0,  113,
			    0,  116,  115,  114,    0,    0,  112,  111,    0,    0,
			  110,    0,    0,    0,  113,    0,    0,    0,    0,    0,
			    0,  112,  111,    0,    0,  110,    0,    0,    0,    0,
			    0,  126,  125,   99,  124,    0,    0,  123,  122,  121,
			  120,  119,  118,    0,    0,    0,  126,  125,   99,  124,
			    0,    0,  123,  122,  121,  120,  119,  118,  318,    0,
			    0,    0,    0,    0,    0,  117,    0,    0,    0,    0,
			  116,  115,  114,  316,    0,    0,    0,    0,    0,    0,
			  117,    0,    0,  113,    0,  116,  115,  114,    0,    0, yyDummy>>,
			1, 1000, 0)
		end

	yytable_template_2 (an_array: ARRAY [INTEGER])
			-- Fill chunk #2 of template for `yytable'.
		do
			yyarray_subcopy (an_array, <<
			  112,  111,    0,    0,  110,    0,    0,    0,  113,    0,
			    0,    0,    0,    0,    0,  112,  111,    0,    0,  110,
			    0,    0,    0,    0,    0,  126,  125,   99,  124,    0,
			    0,  123,  122,  121,  120,  119,  118,    0,    0,    0,
			  126,  125,   99,  124,    0,    0,  123,  122,  121,  120,
			  119,  118,  314,    0,    0,    0,    0,    0,    0,  117,
			    0,    0,    0,    0,  116,  115,  114,  312,    0,    0,
			    0,    0,    0,    0,  117,    0,    0,  113,    0,  116,
			  115,  114,    0,    0,  112,  111,    0,    0,  110,    0,
			    0,    0,  113,    0,    0,    0,    0,    0,    0,  112,

			  111,    0,    0,  110,    0,    0,    0,    0,    0,  126,
			  125,   99,  124,    0,    0,  123,  122,  121,  120,  119,
			  118,    0,    0,    0,  126,  125,   99,  124,    0,    0,
			  123,  122,  121,  120,  119,  118,  310,    0,    0,    0,
			    0,    0,    0,  117,    0,    0,    0,    0,  116,  115,
			  114,  307,    0,    0,    0,    0,    0,    0,  117,    0,
			    0,  113,    0,  116,  115,  114,    0,    0,  112,  111,
			    0,    0,  110,    0,    0,    0,  113,    0,    0,    0,
			    0,    0,    0,  112,  111,    0,    0,  110,    0,    0,
			    0,    0,    0,  126,  125,   99,  124,    0,    0,  123,

			  122,  121,  120,  119,  118,    0,    0,    0,  126,  125,
			   99,  124,    0,    0,  123,  122,  121,  120,  119,  118,
			  305,    0,    0,    0,    0,    0,    0,  117,    0,    0,
			    0,    0,  116,  115,  114,  303,    0,    0,    0,    0,
			    0,    0,  117,    0,    0,  113,    0,  116,  115,  114,
			    0,    0,  112,  111,    0,    0,  110,    0,    0,    0,
			  113,    0,    0,    0,    0,    0,    0,  112,  111,    0,
			    0,  110,    0,    0,    0,    0,    0,  126,  125,   99,
			  124,    0,    0,  123,  122,  121,  120,  119,  118,    0,
			    0,    0,  126,  125,   99,  124,    0,    0,  123,  122,

			  121,  120,  119,  118,  301,    0,    0,    0,    0,    0,
			    0,  117,    0,    0,    0,    0,  116,  115,  114,  299,
			    0,    0,    0,    0,    0,    0,  117,    0,    0,  113,
			    0,  116,  115,  114,    0,    0,  112,  111,    0,    0,
			  110,    0,    0,    0,  113,    0,    0,    0,    0,    0,
			    0,  112,  111,    0,    0,  110,    0,    0,    0,    0,
			    0,  126,  125,   99,  124,    0,    0,  123,  122,  121,
			  120,  119,  118,    0,    0,    0,  126,  125,   99,  124,
			    0,    0,  123,  122,  121,  120,  119,  118,  293,    0,
			    0,    0,    0,    0,    0,  117,    0,    0,    0,    0,

			  116,  115,  114,  270,    0,    0,    0,    0,    0,    0,
			  117,    0,    0,  113,    0,  116,  115,  114,    0,    0,
			  112,  111,    0,    0,  110,    0,    0,    0,  113,    0,
			    0,    0,    0,    0,    0,  112,  111,    0,    0,  110,
			    0,    0,    0,    0,    0,  126,  125,   99,  124,    0,
			    0,  123,  122,  121,  120,  119,  118,    0,    0,    0,
			  126,  125,   99,  124,    0,    0,  123,  122,  121,  120,
			  119,  118,  203,    0,    0,    0,    0,    0,    0,  117,
			    0,    0,    0,    0,  116,  115,  114,  201,    0,    0,
			    0,    0,    0,    0,  117,    0,    0,  113,    0,  116,

			  115,  114,    0,    0,  112,  111,    0,    0,  110,    0,
			    0,    0,  113,    0,    0,    0,    0,    0,    0,  112,
			  111,    0,    0,  110,    0,    0,    0,    0,    0,  126,
			  125,   99,  124,    0,    0,  123,  122,  121,  120,  119,
			  118,    0,    0,    0,  126,  125,   99,  124,    0,    0,
			  123,  122,  121,  120,  119,  118,  199,    0,    0,    0,
			    0,    0,    0,  117,    0,    0,    0,    0,  116,  115,
			  114,  197,    0,    0,    0,    0,    0,    0,  117,    0,
			    0,  113,    0,  116,  115,  114,    0,    0,  112,  111,
			    0,    0,  110,    0,    0,    0,  113,    0,    0,    0,

			    0,    0,    0,  112,  111,    0,    0,  110,    0,    0,
			    0,    0,    0,  126,  125,   99,  124,    0,    0,  123,
			  122,  121,  120,  119,  118,    0,    0,    0,  126,  125,
			   99,  124,    0,    0,  123,  122,  121,  120,  119,  118,
			  194,    0,    0,    0,    0,    0,    0,  117,    0,    0,
			    0,    0,  116,  115,  114,  138,    0,    0,    0,    0,
			    0,    0,  117,    0,    0,  113,    0,  116,  115,  114,
			    0,    0,  112,  111,    0,    0,  110,    0,    0,    0,
			  113,    0,    0,    0,    0,    0,    0,  112,  111,    0,
			    0,  110,    0,    0,    0,    0,    0,  126,  125,   99,

			  124,    0,    0,  123,  122,  121,  120,  119,  118,    0,
			    0,    0,  126,  125,   99,  124,    0,    0,  123,  122,
			  121,  120,  119,  118,  127,    0,    0,    0,    0,    0,
			    0,  117,    0,    0,    0,    0,  116,  115,  114,    0,
			    0,    0,    0,    0,    0,    0,  117,    0,    0,  113,
			    0,  116,  115,  114,    0,    0,  112,  111,    0,    0,
			  110,  291,    0,    0,  113,    0,    0,    0,    0,    0,
			    0,  112,  111,    0,    0,  110,    0,    0,    0,    0,
			    0,  126,  125,   99,  124,    0,    0,  123,  122,  121,
			  120,  119,  118,    0,    0,    0,  235,    0,    0,  228,

			  227,  226,  225,  224,  223,  222,  221,  220,  219,  218,
			  217,  216,  215,  214,  213,  117,    0,    0,    0,    0,
			  116,  115,  114,  208,    0,    0,    0,    0,    0,    0,
			    0,    0,    0,  113,    0,    0,    0,    0,    0,    0,
			  112,  111,    0,    0,  110,  228,  227,  226,  225,  224,
			  223,  222,  221,  220,  219,  218,  217,  216,  215,  214,
			  213,    0,    0,    0,    0,  212,  211,  210,  209,  208,
			    0,    0,    0,    0,    0,    0,    0,    0,  234,  290,
			  228,  227,  226,  225,  224,  223,  222,  221,  220,  219,
			  218,  217,  216,  215,  214,  213,    0,    0,    0,    0,

			  212,  211,  210,  209,  208,  407,    0,    0,    0,    0,
			  126,  125,   99,  124,    0,    0,  123,  122,  121,  120,
			  119,  118,    0,    0,  126,  125,   99,  124,    0,    0,
			  123,  122,  121,  120,  119,  118,    0,    0,    0,    0,
			    0,    0,    0,    0,  117,    0,    0,    0,    0,  116,
			  115,  114,    0,    0,    0,    0,    0,  275,  117,    0,
			    0,    0,  113,  116,  115,  114,    0,    0,    0,  112,
			  111,    0,    0,  110,    0,    0,  113,    0,    0,    0,
			    0,    0,    0,  112,  111,    0,    0,  110,  228,  227,
			  226,  225,  224,  223,  222,  221,  220,  219,  218,  217, yyDummy>>,
			1, 1000, 1000)
		end

	yytable_template_3 (an_array: ARRAY [INTEGER])
			-- Fill chunk #3 of template for `yytable'.
		do
			yyarray_subcopy (an_array, <<
			  216,  215,  214,  213,    0,    0,    0,    0,  212,  211,
			  210,  209,  208,   40,   39,   38,   37,   36,   35,   34,
			   33,   32,   31,   30,   29,   28,   27,   26,   25,   24,
			   23,   22,   21,    0,    0,   20,   19,   18,   17,   16,
			   15,   14,   13,   12,   11,   10,    9,    8,    7,    6,
			    5,    4,    0,    0,    0,    0,    0,    0,    0,    0,
			    3,    2,    1,  228,  227,  226,  225,  224,  223,  222,
			  221,  220,  219,  218,  217,  216,  215,  214,  213,    0,
			    0,    0,    0,  212,  211,  210,  209,  208,    0,    0,
			    0,    0,    0,    0,    0,    0,    0,    0,    0,  382,

			  228,  227,  226,  225,  224,  223,  222,  221,  220,  219,
			  218,  217,  216,  215,  214,  213,    0,    0,    0,    0,
			  212,  211,  210,  209,  208,    0,  370,  369,  228,  227,
			  226,  225,  224,  223,  222,  221,  220,  219,  218,  217,
			  216,  215,  214,  213,    0,    0,    0,    0,  212,  211,
			  210,  209,  208,  228,  227,  226,  225,  224,  223,  222,
			  221,  220,  219,  218,  217,  216,  215,  214,  213,    0,
			    0,    0,    0,    0,  211,  210,  209,  208,  228,  227,
			  226,  225,  224,  223,  222,  221,  220,  219,  218,  217,
			  216,  215,  214,  213,    0,    0,    0,    0,    0,    0,

			    0,  209,  208, yyDummy>>,
			1, 203, 2000)
		end

	yycheck_template: SPECIAL [INTEGER]
			-- Template for `yycheck'
		local
			an_array: ARRAY [INTEGER]
		once
			create an_array.make_filled (0, 0, 2202)
			yycheck_template_1 (an_array)
			yycheck_template_2 (an_array)
			yycheck_template_3 (an_array)
			Result := yyfixed_array (an_array)
		end

	yycheck_template_1 (an_array: ARRAY [INTEGER])
			-- Fill chunk #1 of template for `yycheck'.
		do
			yyarray_subcopy (an_array, <<
			   21,   22,    9,   10,   15,   10,   16,  190,   90,    1,
			  137,   55,    1,   56,    0,    1,    1,    1,    0,    1,
			  111,    1,    1,    1,    1,    0,    1,   53,    0,    1,
			    0,    1,    1,    3,    0,    1,   53,  141,  142,  273,
			   66,   53,    0,    1,    0,    1,  113,  114,    1,    1,
			   66,   68,    0,  287,   66,   25,   68,   58,  162,   53,
			    1,   78,   78,   79,   66,    0,   68,   68,  111,   53,
			   91,   56,   84,  117,   44,   45,   46,    1,   62,  206,
			   66,  163,   68,   90,  105,   96,   68,   69,   66,   63,
			  111,   66,  113,  114,  115,  116,   68,   69,   84,   83,

			   58,   59,   60,   61,   74,  112,   64,   65,   66,   67,
			   68,   69,   68,   66,    1,   68,   68,   58,   59,   60,
			   61,  113,  111,   64,   65,   66,   67,   68,   69,  121,
			  119,  111,  111,   74,   92,  115,  115,   78,  115,   97,
			   98,   99,   66,  113,  113,  111,  112,    1,    3,    0,
			    1,   92,  110,    1,   78,   79,   97,   98,   99,  117,
			  118,  182,   53,  121,    1,   25,   74,  188,   92,  110,
			    1,   58,    1,    1,    1,    1,  117,  118,    1,  261,
			  121,   68,  193,   53,  205,   46,    1,  208,  209,  210,
			  211,  212,  213,  214,  215,  216,  217,  218,  219,  220,

			  221,  222,  223,  224,  225,  226,  227,  228,  229,  392,
			  231,    1,   66,  234,   57,   66,  147,   68,   66,  150,
			   68,   58,   59,   60,   61,   44,   68,   64,   65,   66,
			   67,   68,   69,   84,  115,   66,   84,   66,   66,   66,
			   66,   68,  425,   66,    1,   66,   45,   78,   79,   78,
			   79,   66,   66,   53,   68,   92,  267,   84,  279,  269,
			   97,   98,   99,   92,  114,   66,  116,   68,   58,   59,
			   60,   61,   66,  110,   64,   65,   66,   67,   68,   69,
			  117,  118,  119,   84,  121,   99,   92,   53,   78,   58,
			   59,   97,   97,   66,  100,   55,    1,   63,  114,   68,

			  114,   60,   92,   60,   66,  112,   63,   97,   98,   99,
			    1,   92,   93,   94,   95,   96,   97,   98,   99,  100,
			  110,   92,   93,   94,   95,   96,   97,  117,  118,  100,
			   42,  121,   36,   37,   38,   39,   40,   43,  120,  111,
			  119,   66,  118,   63,   68,  113,  116,   68,  369,  370,
			   55,   66,    0,   58,   59,   60,   61,  378,  247,   64,
			   65,   66,   67,   68,   69,  422,  168,   58,   59,   60,
			   61,  229,  206,   64,   65,   66,   67,   68,   69,  386,
			    1,  386,  403,   -1,   -1,   -1,   -1,   92,   -1,   -1,
			   -1,   -1,   97,   98,   99,    1,  417,   -1,  409,   -1,

			   -1,   92,   -1,   -1,   -1,  110,   97,   98,   99,   -1,
			   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,  110,
			   -1,   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,   -1,
			  121,   -1,   -1,   -1,   -1,   -1,   -1,   58,   59,   60,
			   61,   -1,   -1,   64,   65,   66,   67,   68,   69,   -1,
			   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,
			   66,   67,   68,   69,    1,   -1,   -1,   -1,   -1,   -1,
			   -1,   92,   -1,   -1,   -1,   -1,   97,   98,   99,    1,
			   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,
			   -1,   97,   98,   99,   -1,   -1,  117,  118,   -1,   -1,

			  121,   -1,   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,
			   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,
			   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,   66,
			   67,   68,   69,   -1,   -1,   -1,   58,   59,   60,   61,
			   -1,   -1,   64,   65,   66,   67,   68,   69,    1,   -1,
			   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,
			   97,   98,   99,    1,   -1,   -1,   -1,   -1,   -1,   -1,
			   92,   -1,   -1,  110,   -1,   97,   98,   99,   -1,   -1,
			  117,  118,   -1,   -1,  121,   -1,   -1,   -1,  110,   -1,
			   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,   -1,  121,

			   -1,   -1,   -1,   -1,   -1,   58,   59,   60,   61,   -1,
			   -1,   64,   65,   66,   67,   68,   69,   -1,   -1,   -1,
			   58,   59,   60,   61,   -1,   -1,   64,   65,   66,   67,
			   68,   69,    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,
			   -1,   -1,   -1,   -1,   97,   98,   99,    1,   -1,   -1,
			   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,   -1,   97,
			   98,   99,   -1,   -1,  117,  118,   -1,   -1,  121,   -1,
			   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,   -1,  117,
			  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,   -1,   58,
			   59,   60,   61,   -1,   -1,   64,   65,   66,   67,   68,

			   69,   -1,   -1,   -1,   58,   59,   60,   61,   -1,   -1,
			   64,   65,   66,   67,   68,   69,    1,   -1,   -1,   -1,
			   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,   97,   98,
			   99,    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,
			   -1,  110,   -1,   97,   98,   99,   -1,   -1,  117,  118,
			   -1,   -1,  121,   -1,   -1,   -1,  110,   -1,   -1,   -1,
			   -1,   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,
			   -1,   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,
			   65,   66,   67,   68,   69,   -1,   -1,   -1,   58,   59,
			   60,   61,   -1,   -1,   64,   65,   66,   67,   68,   69,

			    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,
			   -1,   -1,   97,   98,   99,    1,   -1,   -1,   -1,   -1,
			   -1,   -1,   92,   -1,   -1,  110,   -1,   97,   98,   99,
			   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,
			  110,   -1,   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,
			   -1,  121,   -1,   -1,   -1,   -1,   -1,   58,   59,   60,
			   61,   -1,   -1,   64,   65,   66,   67,   68,   69,   -1,
			   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,
			   66,   67,   68,   69,    1,   -1,   -1,   -1,   -1,   -1,
			   -1,   92,   -1,   -1,   -1,   -1,   97,   98,   99,    1,

			   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,
			   -1,   97,   98,   99,   -1,   -1,  117,  118,   -1,   -1,
			  121,   -1,   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,
			   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,
			   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,   66,
			   67,   68,   69,   -1,   -1,   -1,   58,   59,   60,   61,
			   -1,   -1,   64,   65,   66,   67,   68,   69,    1,   -1,
			   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,
			   97,   98,   99,    1,   -1,   -1,   -1,   -1,   -1,   -1,
			   92,   -1,   -1,  110,   -1,   97,   98,   99,   -1,   -1, yyDummy>>,
			1, 1000, 0)
		end

	yycheck_template_2 (an_array: ARRAY [INTEGER])
			-- Fill chunk #2 of template for `yycheck'.
		do
			yyarray_subcopy (an_array, <<
			  117,  118,   -1,   -1,  121,   -1,   -1,   -1,  110,   -1,
			   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,   -1,  121,
			   -1,   -1,   -1,   -1,   -1,   58,   59,   60,   61,   -1,
			   -1,   64,   65,   66,   67,   68,   69,   -1,   -1,   -1,
			   58,   59,   60,   61,   -1,   -1,   64,   65,   66,   67,
			   68,   69,    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,
			   -1,   -1,   -1,   -1,   97,   98,   99,    1,   -1,   -1,
			   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,   -1,   97,
			   98,   99,   -1,   -1,  117,  118,   -1,   -1,  121,   -1,
			   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,   -1,  117,

			  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,   -1,   58,
			   59,   60,   61,   -1,   -1,   64,   65,   66,   67,   68,
			   69,   -1,   -1,   -1,   58,   59,   60,   61,   -1,   -1,
			   64,   65,   66,   67,   68,   69,    1,   -1,   -1,   -1,
			   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,   97,   98,
			   99,    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,
			   -1,  110,   -1,   97,   98,   99,   -1,   -1,  117,  118,
			   -1,   -1,  121,   -1,   -1,   -1,  110,   -1,   -1,   -1,
			   -1,   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,
			   -1,   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,

			   65,   66,   67,   68,   69,   -1,   -1,   -1,   58,   59,
			   60,   61,   -1,   -1,   64,   65,   66,   67,   68,   69,
			    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,
			   -1,   -1,   97,   98,   99,    1,   -1,   -1,   -1,   -1,
			   -1,   -1,   92,   -1,   -1,  110,   -1,   97,   98,   99,
			   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,
			  110,   -1,   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,
			   -1,  121,   -1,   -1,   -1,   -1,   -1,   58,   59,   60,
			   61,   -1,   -1,   64,   65,   66,   67,   68,   69,   -1,
			   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,

			   66,   67,   68,   69,    1,   -1,   -1,   -1,   -1,   -1,
			   -1,   92,   -1,   -1,   -1,   -1,   97,   98,   99,    1,
			   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,
			   -1,   97,   98,   99,   -1,   -1,  117,  118,   -1,   -1,
			  121,   -1,   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,
			   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,
			   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,   66,
			   67,   68,   69,   -1,   -1,   -1,   58,   59,   60,   61,
			   -1,   -1,   64,   65,   66,   67,   68,   69,    1,   -1,
			   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,

			   97,   98,   99,    1,   -1,   -1,   -1,   -1,   -1,   -1,
			   92,   -1,   -1,  110,   -1,   97,   98,   99,   -1,   -1,
			  117,  118,   -1,   -1,  121,   -1,   -1,   -1,  110,   -1,
			   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,   -1,  121,
			   -1,   -1,   -1,   -1,   -1,   58,   59,   60,   61,   -1,
			   -1,   64,   65,   66,   67,   68,   69,   -1,   -1,   -1,
			   58,   59,   60,   61,   -1,   -1,   64,   65,   66,   67,
			   68,   69,    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,
			   -1,   -1,   -1,   -1,   97,   98,   99,    1,   -1,   -1,
			   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,   -1,   97,

			   98,   99,   -1,   -1,  117,  118,   -1,   -1,  121,   -1,
			   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,   -1,  117,
			  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,   -1,   58,
			   59,   60,   61,   -1,   -1,   64,   65,   66,   67,   68,
			   69,   -1,   -1,   -1,   58,   59,   60,   61,   -1,   -1,
			   64,   65,   66,   67,   68,   69,    1,   -1,   -1,   -1,
			   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,   97,   98,
			   99,    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,
			   -1,  110,   -1,   97,   98,   99,   -1,   -1,  117,  118,
			   -1,   -1,  121,   -1,   -1,   -1,  110,   -1,   -1,   -1,

			   -1,   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,
			   -1,   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,
			   65,   66,   67,   68,   69,   -1,   -1,   -1,   58,   59,
			   60,   61,   -1,   -1,   64,   65,   66,   67,   68,   69,
			    1,   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,
			   -1,   -1,   97,   98,   99,    1,   -1,   -1,   -1,   -1,
			   -1,   -1,   92,   -1,   -1,  110,   -1,   97,   98,   99,
			   -1,   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,
			  110,   -1,   -1,   -1,   -1,   -1,   -1,  117,  118,   -1,
			   -1,  121,   -1,   -1,   -1,   -1,   -1,   58,   59,   60,

			   61,   -1,   -1,   64,   65,   66,   67,   68,   69,   -1,
			   -1,   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,
			   66,   67,   68,   69,    1,   -1,   -1,   -1,   -1,   -1,
			   -1,   92,   -1,   -1,   -1,   -1,   97,   98,   99,   -1,
			   -1,   -1,   -1,   -1,   -1,   -1,   92,   -1,   -1,  110,
			   -1,   97,   98,   99,   -1,   -1,  117,  118,   -1,   -1,
			  121,    1,   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,
			   -1,  117,  118,   -1,   -1,  121,   -1,   -1,   -1,   -1,
			   -1,   58,   59,   60,   61,   -1,   -1,   64,   65,   66,
			   67,   68,   69,   -1,   -1,   -1,    1,   -1,   -1,   85,

			   86,   87,   88,   89,   90,   91,   92,   93,   94,   95,
			   96,   97,   98,   99,  100,   92,   -1,   -1,   -1,   -1,
			   97,   98,   99,  109,   -1,   -1,   -1,   -1,   -1,   -1,
			   -1,   -1,   -1,  110,   -1,   -1,   -1,   -1,   -1,   -1,
			  117,  118,   -1,   -1,  121,   85,   86,   87,   88,   89,
			   90,   91,   92,   93,   94,   95,   96,   97,   98,   99,
			  100,   -1,   -1,   -1,   -1,  105,  106,  107,  108,  109,
			   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   83,  119,
			   85,   86,   87,   88,   89,   90,   91,   92,   93,   94,
			   95,   96,   97,   98,   99,  100,   -1,   -1,   -1,   -1,

			  105,  106,  107,  108,  109,   53,   -1,   -1,   -1,   -1,
			   58,   59,   60,   61,   -1,   -1,   64,   65,   66,   67,
			   68,   69,   -1,   -1,   58,   59,   60,   61,   -1,   -1,
			   64,   65,   66,   67,   68,   69,   -1,   -1,   -1,   -1,
			   -1,   -1,   -1,   -1,   92,   -1,   -1,   -1,   -1,   97,
			   98,   99,   -1,   -1,   -1,   -1,   -1,   54,   92,   -1,
			   -1,   -1,  110,   97,   98,   99,   -1,   -1,   -1,  117,
			  118,   -1,   -1,  121,   -1,   -1,  110,   -1,   -1,   -1,
			   -1,   -1,   -1,  117,  118,   -1,   -1,  121,   85,   86,
			   87,   88,   89,   90,   91,   92,   93,   94,   95,   96, yyDummy>>,
			1, 1000, 1000)
		end

	yycheck_template_3 (an_array: ARRAY [INTEGER])
			-- Fill chunk #3 of template for `yycheck'.
		do
			yyarray_subcopy (an_array, <<
			   97,   98,   99,  100,   -1,   -1,   -1,   -1,  105,  106,
			  107,  108,  109,    3,    4,    5,    6,    7,    8,    9,
			   10,   11,   12,   13,   14,   15,   16,   17,   18,   19,
			   20,   21,   22,   -1,   -1,   25,   26,   27,   28,   29,
			   30,   31,   32,   33,   34,   35,   36,   37,   38,   39,
			   40,   41,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
			   50,   51,   52,   85,   86,   87,   88,   89,   90,   91,
			   92,   93,   94,   95,   96,   97,   98,   99,  100,   -1,
			   -1,   -1,   -1,  105,  106,  107,  108,  109,   -1,   -1,
			   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  121,

			   85,   86,   87,   88,   89,   90,   91,   92,   93,   94,
			   95,   96,   97,   98,   99,  100,   -1,   -1,   -1,   -1,
			  105,  106,  107,  108,  109,   -1,  111,  112,   85,   86,
			   87,   88,   89,   90,   91,   92,   93,   94,   95,   96,
			   97,   98,   99,  100,   -1,   -1,   -1,   -1,  105,  106,
			  107,  108,  109,   85,   86,   87,   88,   89,   90,   91,
			   92,   93,   94,   95,   96,   97,   98,   99,  100,   -1,
			   -1,   -1,   -1,   -1,  106,  107,  108,  109,   85,   86,
			   87,   88,   89,   90,   91,   92,   93,   94,   95,   96,
			   97,   98,   99,  100,   -1,   -1,   -1,   -1,   -1,   -1,

			   -1,  108,  109, yyDummy>>,
			1, 203, 2000)
		end

feature {NONE} -- Semantic value stacks

	yyvs1: SPECIAL [ANY]
			-- Stack for semantic values of type ANY

	yyvsc1: INTEGER
			-- Capacity of semantic value stack `yyvs1'

	yyvsp1: INTEGER
			-- Top of semantic value stack `yyvs1'

	yyspecial_routines1: KL_SPECIAL_ROUTINES [ANY]
			-- Routines that ought to be in SPECIAL [ANY]

	yyvs2: SPECIAL [INTEGER]
			-- Stack for semantic values of type INTEGER

	yyvsc2: INTEGER
			-- Capacity of semantic value stack `yyvs2'

	yyvsp2: INTEGER
			-- Top of semantic value stack `yyvs2'

	yyspecial_routines2: KL_SPECIAL_ROUTINES [INTEGER]
			-- Routines that ought to be in SPECIAL [INTEGER]

	yyvs3: SPECIAL [STRING]
			-- Stack for semantic values of type STRING

	yyvsc3: INTEGER
			-- Capacity of semantic value stack `yyvs3'

	yyvsp3: INTEGER
			-- Top of semantic value stack `yyvs3'

	yyspecial_routines3: KL_SPECIAL_ROUTINES [STRING]
			-- Routines that ought to be in SPECIAL [STRING]

	yyvs4: SPECIAL [CHARACTER]
			-- Stack for semantic values of type CHARACTER

	yyvsc4: INTEGER
			-- Capacity of semantic value stack `yyvs4'

	yyvsp4: INTEGER
			-- Top of semantic value stack `yyvs4'

	yyspecial_routines4: KL_SPECIAL_ROUTINES [CHARACTER]
			-- Routines that ought to be in SPECIAL [CHARACTER]

	yyvs5: SPECIAL [DOUBLE]
			-- Stack for semantic values of type DOUBLE

	yyvsc5: INTEGER
			-- Capacity of semantic value stack `yyvs5'

	yyvsp5: INTEGER
			-- Top of semantic value stack `yyvs5'

	yyspecial_routines5: KL_SPECIAL_ROUTINES [DOUBLE]
			-- Routines that ought to be in SPECIAL [DOUBLE]

	yyvs6: SPECIAL [DG_EXPRESSION]
			-- Stack for semantic values of type DG_EXPRESSION

	yyvsc6: INTEGER
			-- Capacity of semantic value stack `yyvs6'

	yyvsp6: INTEGER
			-- Top of semantic value stack `yyvs6'

	yyspecial_routines6: KL_SPECIAL_ROUTINES [DG_EXPRESSION]
			-- Routines that ought to be in SPECIAL [DG_EXPRESSION]

	yyvs7: SPECIAL [IS_TYPE]
			-- Stack for semantic values of type IS_TYPE

	yyvsc7: INTEGER
			-- Capacity of semantic value stack `yyvs7'

	yyvsp7: INTEGER
			-- Top of semantic value stack `yyvs7'

	yyspecial_routines7: KL_SPECIAL_ROUTINES [IS_TYPE]
			-- Routines that ought to be in SPECIAL [IS_TYPE]

	yyvs8: SPECIAL [IS_CLASS_TEXT]
			-- Stack for semantic values of type IS_CLASS_TEXT

	yyvsc8: INTEGER
			-- Capacity of semantic value stack `yyvs8'

	yyvsp8: INTEGER
			-- Top of semantic value stack `yyvs8'

	yyspecial_routines8: KL_SPECIAL_ROUTINES [IS_CLASS_TEXT]
			-- Routines that ought to be in SPECIAL [IS_CLASS_TEXT]

	yyvs9: SPECIAL [IS_FEATURE_TEXT]
			-- Stack for semantic values of type IS_FEATURE_TEXT

	yyvsc9: INTEGER
			-- Capacity of semantic value stack `yyvs9'

	yyvsp9: INTEGER
			-- Top of semantic value stack `yyvs9'

	yyspecial_routines9: KL_SPECIAL_ROUTINES [IS_FEATURE_TEXT]
			-- Routines that ought to be in SPECIAL [IS_FEATURE_TEXT]

feature {NONE} -- Constants

	yyFinal: INTEGER = 430
			-- Termination state id

	yyFlag: INTEGER = -32768
			-- Most negative INTEGER

	yyNtbase: INTEGER = 122
			-- Number of tokens

	yyLast: INTEGER = 2202
			-- Upper bound of `yytable' and `yycheck'

	yyMax_token: INTEGER = 356
			-- Maximum token id
			-- (upper bound of `yytranslate'.)

	yyNsyms: INTEGER = 222
			-- Number of symbols
			-- (terminal and nonterminal)

feature -- User-defined features

 
 
feature {NONE} -- Initialization 
 
	make(dg: ANY)
		local
			d: detachable like debugger
		do 
			if attached {like debugger} dg as dg_ then
				d := dg_
			end
			check attached d end
			debugger := d
		  	system := debugger.debuggee 
			create placeholders.make(4)
			make_scanner
			make_parser_skeleton 
			create target.make(0) 
			create multi.make(0) 
			create lines 
			create break_idents.make(10)
			create breakpoint.make(0, Void) 
			create count_stack.make(10) 
			last_string_value := ""
			last_any_value := last_string_value
		end 
 
feature -- Initialization 
 
	reset 
		do 
			Precursor 
			single := Void 
			target := Void 
			range := Void 
			multi := Void 
			type := Void 
			placeholders.wipe_out 
			breakpoint.clear
			go_mode := 0
			go_count := 1 
			reset_ident := 0 
			lines.set_line_column(0, 0)
			break_idents.wipe_out 
			break_change := '%U' 
			stack_count := 0 
			count_stack.wipe_out 
			in_list := False 
			print_format := ""
			alias_name := ""
			in_break := False 
			forbidden_closure := False 
			op_column  := 0
		end 
 
feature -- Error handling 
 
	report_error (msg: STRING) 
		do 
			msg_.copy(msg) 
		end 
 
feature -- Access 
 
	single, target: detachable DG_EXPRESSION 
 
	range: detachable DG_RANGE_EXPRESSION 
 
	multi: detachable DG_EXPRESSION 

	current_closure: DG_EXPRESSION
		once
			create Result.make(0) 
			Result.set_entity(current_entity) 
			Result.set_name("Current")
		end

	type: detachable IS_TYPE 
 
	class_text: detachable IS_CLASS_TEXT 
 
	alias_name, file_name: detachable STRING 
 
	lines: DG_LINE_RANGE 
 
	breakpoint: DG_BREAKPOINT 
 
	break_change: CHARACTER 
 
	break_idents: detachable ARRAYED_LIST[INTEGER]

	go_count, go_mode, reset_ident: INTEGER 
	stack_count, status_what, proc_ident: INTEGER 

	is_lazy, forbidden_closure: BOOLEAN 
 
feature -- Status setting 
 
	set_lines(l: like lines) 
		require 
		do 
			lines.copy(l) 
		ensure 
			lines_set: lines.is_equal(l) 
		end 
 
feature -- Basic operation 
 
	parse_line(l: STRING) 
		require 
			not_void: attached l
		do 
			reset 
			set_input_buffer(new_string_buffer(l)) 
			parse 
		end 
 
feature {NONE} -- Implementation 
 
	once_call: detachable IS_ONCE_CALL 
	once_value: detachable IS_ONCE_VALUE 
 
	ph: detachable DG_EXPRESSION 
	placeholders: ARRAYED_LIST[DG_EXPRESSION] 
 
	No_type: STRING = "Type name expected." 
	No_normal_type: STRING = "Name of normal type expected." 
	No_integer: STRING = "Manifest integer expected." 
	No_expression: STRING = "Expression expected." 
	No_file_name: STRING = "File name within quotation marks expected."
	Detailed: STRING = "Detailed expression cannot be a qualifier." 

	debugger: GEDB 
 
	system: IS_RUNTIME_SYSTEM 
 
	count_stack: ARRAYED_STACK[INTEGER] 

	feature_text: detachable IS_FEATURE_TEXT

	routine: detachable IS_ROUTINE

	string: detachable STRING 
 
	normal_type: detachable IS_NORMAL_TYPE 
 
	int, min, max: INTEGER 
 
	nat: NATURAL

	op_column: INTEGER

		 in_list, in_break: BOOLEAN 

	as_alias (s: STRING): attached like single 
		require 
			not_empty: s.count > 0 
		local 
			ok: BOOLEAN 
		do 
			create Result.make(0) 
			tmp_str.copy(s) 
			ok := tmp_str[1] = '_' 
		  	if ok then 
				tmp_str.remove(1) 
			  	if attached debugger.aliases[tmp_str] as a then
					Result := a
				else
					message(once "Alias name not defined.", column) 
				end 
			end 
		end 
 
	int_to_closure (n: NATURAL): DG_EXPRESSION
		do
			if closure_roots.is_empty then
				message(once "Persistence closure is empty.", column)
			end
			if closure_roots.last.max < n then
				tmp_str.copy(once "Closure ident <= ")
				tmp_str.append_natural_32(closure_roots.last.max)
				tmp_str.append(once " expected.")
				column := column + 1
				message(tmp_str, column)
			end
			create Result.make(column - text_count)
			Result.set_entity(closure_entity) 
			tmp_str.wipe_out
			-- tmp_str.extend('_')
			tmp_str.append_natural_32(n)
			Result.set_name(tmp_str) 
		end

	as_closure (ex: DG_EXPRESSION): DG_EXPRESSION
		do
			value_stack.clear 
			ex.compute(debugger.shown_frame, value_stack)
			if attached ex.bottom.type as t and then t.is_subobject then
				column := column - ex.bottom.name_count
				message(once "Reference type expected.",column)
			end
			Result := ex
		end

	compose_infix (left, right: DG_EXPRESSION; code, prec: INTEGER; e: detachable DG_MANIFEST) 
		local 
			op: DG_OPERATOR 
			nm: STRING
		do 
			create op.make_as_down(left, column - text_count) 
			op.set_entity(e) 
			op.set_arg(right) 
			op.set_code(code) 
			inspect code 
			when power_op then
				nm := once "^"
			when interval_op then
				nm := once ".."
			when plus_op then
				nm := once "+"
			when minus_op then
				nm := once "-"
			when mult_op then
				nm := once "*"
			when div_op then
				nm := once "/"
			when idiv_op then
				nm := once "//"
			when imod_op then
				nm := once "\\"
			when eq_op then
				nm := once "="
			when ne_op then
				nm := once "/="
			when lt_op then
				nm := once "<"
			when le_op then
				nm := once "<="
			when gt_op then
				nm := once ">"
			when ge_op then
				nm := once ">="
			when sim_op then
				nm := once "~"
			when nsim_op then
				nm := once "/~"
			when and_op then
				nm := once "and"
			when or_op then
				nm := once "or"
			when xor_op then
				nm := once "xor"
			when implies_op then
				nm := once "implies"
			when not_op then
				nm := once "not"
			else
			end
			op.set_name(nm) 
			op.set_precedence(prec) 
		end 
 
	compose_prefix (right: DG_EXPRESSION; code: INTEGER) 
		local 
			op: DG_OPERATOR 
			nm: STRING
		do 
			create op.make_as_down(right, column - text_count) 
			op.set_code(code)
			inspect code 
			when plus_op then
				nm := once "+"
			when minus_op then
				nm := once "-"
			when not_op then
				nm := once "not"
			else
			end
			op.set_name(nm) 
			op.set_precedence(9) 
		end 
 
	compose_free (left, right: DG_EXPRESSION; nm: STRING) 
		local 
			op: DG_OPERATOR 
		do 
			if attached left as l then
				create op.make_as_down(l, column - text_count) 
			else
				create op.make_as_down(right, column - text_count) 
			end
			op.set_code(free_op)
			op.set_name(nm) 
			if attached left then
				op.set_arg(right) 
			end
			op.set_precedence(9) 
		end 
 
	class_by_name(name: STRING): IS_CLASS_TEXT 
		local 
			cls: detachable IS_CLASS_TEXT
			i, n: INTEGER 
		  	exact: BOOLEAN 
		do 
			from 
				i := system.class_count 
			until exact or else i = 0 loop 
				i := i - 1 
				if attached system.class_at(i) as c then 
					if c.has_name(name) then 
						cls := c 
						exact := True 
				        elseif c.name_has_prefix(name) then 
						cls := c 
						n := n + 1 
					end 
				end 
			end 
			if not attached cls then 
				message(once "Unknown class.", column) 
			end 
			check attached cls end
			Result := cls
		end 
 
	feature_by_name (name: STRING; cls: detachable IS_CLASS_TEXT; silent: BOOLEAN): IS_FEATURE_TEXT  
		local 
			c: detachable IS_CLASS_TEXT 
			f: detachable IS_FEATURE_TEXT 
			i, n: INTEGER 
		  	exact: BOOLEAN 
		do 
			if attached cls as cls_ then 
				c := cls_ 
			else 
				c := debugger.list_range.cls 
			end 
			check attached c end
			from 
				i := c.feature_count 
			until exact or else i = 0 loop 
				i := i - 1 
				if attached c.feature_at(i) as f_ then
					if f_.has_name(name) then 
						f := f_
						exact := True 
		        		elseif f_.name_has_prefix(name) then 
						f := f_
						n := n + 1
					end 
				end 
			end 
			if attached f as f_ then 
				if not silent and not exact and n > 1 then 
					msg_.copy(once "Feature is not unique in class ")
					c.append_name(msg_)
					msg_.extend('.')
					message(msg_, column)
				end
				Result := f_
			elseif not silent then
				msg_.copy(once "Feature not found in class ")
				c.append_name(msg_)
				msg_.extend('.')
				message(msg_, column)
			end 
		end 
 
	lines_like_expression (ex: DG_EXPRESSION)
		local
			b: DG_EXPRESSION
			c: IS_CLASS_TEXT
			x: IS_FEATURE_TEXT
			col: INTEGER
		do
			ex.set_best_entity(debugger.shown_frame, Void, True, False)
			if attached {IS_NORMAL_TYPE} ex.type as nt then
				c := nt.base_class
			elseif attached {IS_AGENT_TYPE} ex.type as at then
				c := at.declared_type.base_class
			end
			lines.set_text(c, ex.entity.text, False)
			from
				b := ex.down
				col := column
			until not attached b loop
				column := b.column
				if attached feature_by_name(b.name, c, False) as f then
					x := f.definition
					lines.set_text(Void, x, False)
					c := x.home
					b := b.down
				else
					b := Void
				end
			end
			column := col
		end 
 
	checked_int(i: INTEGER; correct: BOOLEAN): INTEGER 
		require 
			correct_range: min <= max 
		do 
			Result := i 
			msg_.wipe_out 
			if min = max and then i /= min then 
				msg_.append(once "Integer value ") 
				msg_.append_integer(min) 
				msg_.append(once " expected.") 
				message(msg_, column) 
			elseif i < min then 
				if correct then 
					Result := min 
				else 
					if min = 0 then 
						msg_.append(once "Non-negative integer") 
					elseif min = 1 then 
						msg_.append(once "Positive integer") 
					else 
						msg_.append(once "integer >= ") 
						msg_.append_integer(min) 
					end 
					msg_.append(once " expected.") 
					message(msg_, column) 
				end 
			elseif i > max then 
				if correct then 
					Result := max 
				else 
					msg_.wipe_out 
					msg_.append(once "Integer <= ") 
					msg_.append_integer(max) 
					msg_.append(once " expected.") 
					message(msg_, column) 
				end 
			end 
		end 
 
	check_format(fmt: STRING; col: INTEGER)
		require
			not_empty: fmt.count > 0
		local
			i, k, l: INTEGER
			c: CHARACTER
			ok: BOOLEAN
		do
			print_format := last_string_value.twin
			from 
				k := 2
				l := 2
			until k > last_string_value.count loop
				c := last_string_value[k]
				from 
					i := fmt.count 
					ok := False
				until ok or else i = 0 loop
					ok := fmt[i] = c
					i := i - 1
				end
				if not ok then
					i := fmt.count
					if i = 1 then
						tmp_str.copy(once "Format ")
					else
						tmp_str.copy(once "One of formats ")
					end
					from 
					until i = 0 loop
						tmp_str.extend('%'')
						tmp_str.extend(fmt[i])
						tmp_str.extend('%'')
						i := i - 1
						if i > 0 then
							tmp_str.extend(',')
							tmp_str.extend(' ')
						end
					end
					tmp_str.append(" expected.")
					message(tmp_str, col+k-1)
					print_format.remove (l)
				else
					l := l + 1
				end
				k := k + 1
       			end
		end

	put_back(s: STRING) 
		local
			i: INTEGER
		do
			from 
				i := s.count 
			until i = 0 loop
				unread_character(s[i])
				i := i - 1
			end
			read_token
		end

        message(msg: STRING; at: INTEGER) 
		local 
			after: INTEGER 
		do 
			after := debugger.command_prompt.count + at - 1 
                        debugger.output.command_message(msg, after) 
			debugger.output.set_silent (True)
			raise (msg)
                end 
 
invariant 
 
note
	copyright: "Copyright (c) 1999-2003, Wolfgang Jansen and others" 
	license: "MIT License" 
	date: "$Date$" 
	revision: "$Revision$" 
	compilation: "geyacc -t DG_TOKENS -o dg_parser.e dg_parser.y" 

end
