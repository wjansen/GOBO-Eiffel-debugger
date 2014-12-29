note
 
  description: "Parser of Vala generated C header files" 
  
     class DG_SYSTEM
 
inherit 
 
	YY_PARSER_SKELETON 
		rename 
			make as make_parser_skeleton 
		redefine 
			default_create,
			report_error
		end 
 
	DG_SCANNER 
		undefine
			copy, is_equal, out
		redefine 
			default_create
		end 


	IS_SYSTEM
		rename 
			make as make_system 
		undefine
			copy, is_equal, out
		redefine 
			default_create,
			type_by_name
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
			create yyspecial_routines5
			yyvsc5 := yyInitial_yyvs_size
			yyvs5 := yyspecial_routines5.make (yyvsc5)
			create yyspecial_routines6
			yyvsc6 := yyInitial_yyvs_size
			yyvs6 := yyspecial_routines6.make (yyvsc6)
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
		end

	yy_clear_value_stacks
			-- Clear objects in semantic value stacks so that
			-- they can be collected by the garbage collector.
		do
			yyvs1.keep_head (0)
			yyvs2.keep_head (0)
			yyvs3.keep_head (0)
			yyvs4.keep_head (0)
			yyvs5.keep_head (0)
			yyvs6.keep_head (0)
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
				yyspecial_routines2.force (yyvs2, last_integer_value, yyvsp2)
			when 3 then
				yyvsp3 := yyvsp3 + 1
				if yyvsp3 >= yyvsc3 then
					debug ("GEYACC")
						std.error.put_line ("Resize yyvs3")
					end
					yyvsc3 := yyvsc3 + yyInitial_yyvs_size
					yyvs3 := yyspecial_routines3.aliased_resized_area (yyvs3, yyvsc3)
				end
				yyspecial_routines3.force (yyvs3, last_string_value, yyvsp3)
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
			when 5 then
				yyvsp5 := yyvsp5 - 1
			when 6 then
				yyvsp6 := yyvsp6 - 1
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
					--|#line 57 "dg_system.y"
				yy_do_action_1
			when 2 then
					--|#line 58 "dg_system.y"
				yy_do_action_2
			when 3 then
					--|#line 59 "dg_system.y"
				yy_do_action_3
			when 4 then
					--|#line 60 "dg_system.y"
				yy_do_action_4
			when 5 then
					--|#line 61 "dg_system.y"
				yy_do_action_5
			when 6 then
					--|#line 64 "dg_system.y"
				yy_do_action_6
			when 7 then
					--|#line 66 "dg_system.y"
				yy_do_action_7
			when 8 then
					--|#line 68 "dg_system.y"
				yy_do_action_8
			when 9 then
					--|#line 71 "dg_system.y"
				yy_do_action_9
			when 10 then
					--|#line 75 "dg_system.y"
				yy_do_action_10
			when 11 then
					--|#line 76 "dg_system.y"
				yy_do_action_11
			when 12 then
					--|#line 79 "dg_system.y"
				yy_do_action_12
			when 13 then
					--|#line 84 "dg_system.y"
				yy_do_action_13
			when 14 then
					--|#line 92 "dg_system.y"
				yy_do_action_14
			when 15 then
					--|#line 98 "dg_system.y"
				yy_do_action_15
			when 16 then
					--|#line 101 "dg_system.y"
				yy_do_action_16
			when 17 then
					--|#line 102 "dg_system.y"
				yy_do_action_17
			when 18 then
					--|#line 105 "dg_system.y"
				yy_do_action_18
			when 19 then
					--|#line 108 "dg_system.y"
				yy_do_action_19
			when 20 then
					--|#line 111 "dg_system.y"
				yy_do_action_20
			when 21 then
					--|#line 116 "dg_system.y"
				yy_do_action_21
			when 22 then
					--|#line 120 "dg_system.y"
				yy_do_action_22
			when 23 then
					--|#line 123 "dg_system.y"
				yy_do_action_23
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
			--|#line 57 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 57 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 57")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 0
	yyvsp3 := yyvsp3 + 1
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

	yy_do_action_2
			--|#line 58 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 58 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 58")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp4 := yyvsp4 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_3
			--|#line 59 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 59 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 59")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp4 := yyvsp4 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_4
			--|#line 60 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 60 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 60")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_5
			--|#line 61 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 61 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 61")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_6
			--|#line 64 "dg_system.y"
		local
			yyval4: IS_TYPE
		do
--|#line 64 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 64")
end

yyval4 := type_of_name (as_class_name (yyvs3.item (yyvsp3)), yyvs3.item (yyvsp3)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp4 := yyvsp4 + 1
	yyvsp2 := yyvsp2 -3
	yyvsp3 := yyvsp3 -2
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

	yy_do_action_7
			--|#line 66 "dg_system.y"
		local
			yyval4: IS_TYPE
		do
--|#line 66 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 66")
end

yyval4 := type_of_name (as_class_name (yyvs3.item (yyvsp3)), yyvs3.item (yyvsp3)) 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 4
	yyvsp4 := yyvsp4 + 1
	yyvsp2 := yyvsp2 -2
	yyvsp3 := yyvsp3 -2
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

	yy_do_action_8
			--|#line 68 "dg_system.y"
		local
			yyval4: IS_TYPE
		do
--|#line 68 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 68")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp4 := yyvsp4 + 1
	yyvsp2 := yyvsp2 -2
	yyvsp1 := yyvsp1 -1
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

	yy_do_action_9
			--|#line 71 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 71 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 71")
end

enum_val := 0 
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 7
	yyvsp3 := yyvsp3 -1
	yyvsp2 := yyvsp2 -3
	yyvsp1 := yyvsp1 -2
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_10
			--|#line 75 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 75 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 75")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_11
			--|#line 76 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 76 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 76")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_12
			--|#line 79 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 79 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 79")
end

yyval3 := yyvs3.item (yyvsp3)
	      treat_enum (yyvs3.item (yyvsp3))
	      enum_val := enum_val + 1
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_13
			--|#line 84 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 84 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 84")
end

yyval3 := yyvs3.item (yyvsp3)
	      enum_val := last_integer_value
	      treat_enum (yyvs3.item (yyvsp3))
	      enum_val := enum_val+1
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp1 := yyvsp1 -1
	yyvsp2 := yyvsp2 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_14
			--|#line 92 "dg_system.y"
		local
			yyval4: IS_TYPE
		do
--|#line 92 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 92")
end

yyval4 := type_of_name (as_struct_name (yyvs3.item (yyvsp3)), yyvs3.item (yyvsp3))
	      yyval4.set_fields(yyvs6.item (yyvsp6))
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 5
	yyvsp4 := yyvsp4 + 1
	yyvsp2 := yyvsp2 -2
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyvsp6 := yyvsp6 -1
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

	yy_do_action_15
			--|#line 98 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 98 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 98")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 10
	yyvsp3 := yyvsp3 -2
	yyvsp2 := yyvsp2 -2
	yyvsp1 := yyvsp1 -5
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_16
			--|#line 101 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 101 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 101")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_17
			--|#line 102 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 102 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 102")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp3 := yyvsp3 -1
	yyvsp1 := yyvsp1 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_18
			--|#line 105 "dg_system.y"
		local
			yyval3: STRING
		do
--|#line 105 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 105")
end


if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp3 := yyvsp3 -1
	yyspecial_routines3.force (yyvs3, yyval3, yyvsp3)
end
		end

	yy_do_action_19
			--|#line 108 "dg_system.y"
		local
			yyval6: IS_SEQUENCE [attached IS_FIELD]
		do
--|#line 108 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 108")
end

create yyval6.make_1 (yyvs5.item (yyvsp5)) 
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 1
	yyvsp6 := yyvsp6 + 1
	yyvsp5 := yyvsp5 -1
	if yyvsp6 >= yyvsc6 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs6")
		end
		yyvsc6 := yyvsc6 + yyInitial_yyvs_size
		yyvs6 := yyspecial_routines6.aliased_resized_area (yyvs6, yyvsc6)
	end
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
		end

	yy_do_action_20
			--|#line 111 "dg_system.y"
		local
			yyval6: IS_SEQUENCE [attached IS_FIELD]
		do
--|#line 111 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 111")
end

yyval6 := yyvs6.item (yyvsp6) ; yyval6.add (yyvs5.item (yyvsp5)) 
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 2
	yyvsp5 := yyvsp5 -1
	yyspecial_routines6.force (yyvs6, yyval6, yyvsp6)
end
		end

	yy_do_action_21
			--|#line 116 "dg_system.y"
		local
			yyval5: attached IS_FIELD
		do
--|#line 116 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 116")
end

create yyval5.make (yyvs3.item (yyvsp3), expanded_type (as_class_name(yyvs3.item (yyvsp3 - 1)), yyvs3.item (yyvsp3 - 1)), Void, Void)
	      yyval5.set_as_subobject
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp5 := yyvsp5 + 1
	yyvsp3 := yyvsp3 -2
	yyvsp1 := yyvsp1 -1
	if yyvsp5 >= yyvsc5 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs5")
		end
		yyvsc5 := yyvsc5 + yyInitial_yyvs_size
		yyvs5 := yyspecial_routines5.aliased_resized_area (yyvs5, yyvsc5)
	end
	yyspecial_routines5.force (yyvs5, yyval5, yyvsp5)
end
		end

	yy_do_action_22
			--|#line 120 "dg_system.y"
		local
			yyval5: attached IS_FIELD
		do
--|#line 120 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 120")
end

create yyval5.make (yyvs3.item (yyvsp3), type_of_name (as_type_name(yyvs3.item (yyvsp3 - 1)), yyvs3.item (yyvsp3 - 1)), Void, Void) 
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 3
	yyvsp5 := yyvsp5 + 1
	yyvsp3 := yyvsp3 -2
	yyvsp1 := yyvsp1 -1
	if yyvsp5 >= yyvsc5 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs5")
		end
		yyvsc5 := yyvsc5 + yyInitial_yyvs_size
		yyvs5 := yyspecial_routines5.aliased_resized_area (yyvs5, yyvsc5)
	end
	yyspecial_routines5.force (yyvs5, yyval5, yyvsp5)
end
		end

	yy_do_action_23
			--|#line 123 "dg_system.y"
		local
			yyval5: attached IS_FIELD
		do
--|#line 123 "dg_system.y"
debug ("GEYACC")
	std.error.put_line ("Executing parser user-code from file 'dg_system.y' at line 123")
end

create yyval5.make (yyvs3.item (yyvsp3 - 2), new_special_type 
			      (type_of_name (as_type_name(yyvs3.item (yyvsp3 - 3)), yyvs3.item (yyvsp3 - 3))), 
			      Void, Void) 
	    
if yy_parsing_status >= yyContinue then
	yyssp := yyssp - 7
	yyvsp5 := yyvsp5 + 1
	yyvsp3 := yyvsp3 -4
	yyvsp1 := yyvsp1 -3
	if yyvsp5 >= yyvsc5 then
		debug ("GEYACC")
			std.error.put_line ("Resize yyvs5")
		end
		yyvsc5 := yyvsc5 + yyInitial_yyvs_size
		yyvs5 := yyspecial_routines5.aliased_resized_area (yyvs5, yyvsc5)
	end
	yyspecial_routines5.force (yyvs5, yyval5, yyvsp5)
end
		end

	yy_do_error_action (yy_act: INTEGER)
			-- Execute error action.
		do
			inspect yy_act
			when 60 then
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
			   19,   21,   20,    2,   17,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,   22,
			    2,   18,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,

			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
			    2,    2,    2,   15,    2,   16,    2,    2,    2,    2,
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
			    5,    6,    7,    8,    9,   10,   11,   12,   13,   14, yyDummy>>)
		end

	yyr1_template: SPECIAL [INTEGER]
			-- Template for `yyr1'
		once
			Result := yyfixed_array (<<
			    0,   23,   23,   23,   23,   23,   30,   30,   30,   24,
			   25,   25,   26,   26,   31,   27,   28,   28,   29,   33,
			   33,   32,   32,   32, yyDummy>>)
		end

	yytypes1_template: SPECIAL [INTEGER]
			-- Template for `yytypes1'
		once
			Result := yyfixed_array (<<
			    3,    3,    2,    2,    3,    3,    4,    4,    3,    3,
			    3,    2,    2,    1,    1,    1,    3,    1,    3,    2,
			    3,    3,    5,    6,    1,    2,    3,    3,    3,    3,
			    1,    3,    3,    2,    5,    3,    1,    1,    1,    2,
			    3,    1,    1,    1,    2,    3,    3,    1,    1,    2,
			    3,    3,    3,    3,    3,    3,    1,    1,    1,    2,
			    3,    1,    1, yyDummy>>)
		end

	yytypes2_template: SPECIAL [INTEGER]
			-- Template for `yytypes2'
		once
			Result := yyfixed_array (<<
			    1,    1,    1,    2,    2,    2,    2,    2,    2,    2,
			    3,    3,    3,    3,    3,    1,    1,    1,    1,    1,
			    1,    1,    1, yyDummy>>)
		end

	yydefact_template: SPECIAL [INTEGER]
			-- Template for `yydefact'
		once
			Result := yyfixed_array (<<
			    1,    0,    0,    0,    4,    5,    2,    3,    0,    0,
			    0,    0,    0,    0,    0,    0,    0,    0,    0,    8,
			    0,    0,   19,    0,    0,    7,   12,    0,   10,    0,
			    0,    0,    0,   14,   20,    0,    0,    0,    0,    6,
			    0,   22,   21,    0,   13,   11,    0,    0,    0,    9,
			    0,    0,    0,   16,    0,   18,    0,    0,   23,   15,
			   17,    0,    0, yyDummy>>)
		end

	yydefgoto_template: SPECIAL [INTEGER]
			-- Template for `yydefgoto'
		once
			Result := yyfixed_array (<<
			    1,    4,   27,   28,    5,   52,   53,    6,    7,   22,
			   23, yyDummy>>)
		end

	yypact_template: SPECIAL [INTEGER]
			-- Template for `yypact'
		once
			Result := yyfixed_array (<<
			 -32768,    5,   38,   -1, -32768, -32768, -32768, -32768,   36,   35,
			   34,   33,   30,   32,    4,   27,   31,   15,   28, -32768,
			   -9,   29, -32768,    1,   26, -32768,   23,  -14, -32768,   25,
			   24,   21,   11, -32768, -32768,   16,   22,   15,   20, -32768,
			    8, -32768, -32768,    9, -32768, -32768,   19,   12,    7, -32768,
			   14,   13,   -2, -32768,    0, -32768,   17,    7, -32768, -32768,
			 -32768,   18, -32768, yyDummy>>)
		end

	yypgoto_template: SPECIAL [INTEGER]
			-- Template for `yypgoto'
		once
			Result := yyfixed_array (<<
			 -32768, -32768, -32768,   39, -32768, -32768,  -15, -32768, -32768,   37,
			 -32768, yyDummy>>)
		end

	yytable_template: SPECIAL [INTEGER]
			-- Template for `yytable'
		once
			Result := yyfixed_array (<<
			   13,   31,   38,   37,   12,   61,   11,   33,    3,   10,
			    2,   30,    9,   21,   20,   57,   21,   20,   62,   56,
			   51,   59,   58,   55,   54,   50,   26,   49,   48,   39,
			   47,   44,   46,   42,   40,   25,   19,   43,   35,   32,
			   29,   36,   60,   41,   18,    0,   16,   24,   17,    0,
			    0,   14,    8,    0,   15,    0,    0,    0,    0,    0,
			   34,    0,    0,    0,    0,    0,    0,    0,    0,    0,
			    0,    0,    0,    0,    0,    0,   45, yyDummy>>)
		end

	yycheck_template: SPECIAL [INTEGER]
			-- Template for `yycheck'
		once
			Result := yyfixed_array (<<
			    1,   10,   16,   17,    5,    0,    7,    6,    3,   10,
			    5,   20,   13,   12,   13,   17,   12,   13,    0,   21,
			   13,    4,   22,   10,   10,   13,   11,    8,   19,    4,
			   22,    9,   12,   22,   10,    4,    4,   21,   12,   10,
			   12,   18,   57,   22,   14,   -1,   12,   20,   15,   -1,
			   -1,   15,   14,   -1,   19,   -1,   -1,   -1,   -1,   -1,
			   23,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
			   -1,   -1,   -1,   -1,   -1,   -1,   37, yyDummy>>)
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

	yyvs4: SPECIAL [IS_TYPE]
			-- Stack for semantic values of type IS_TYPE

	yyvsc4: INTEGER
			-- Capacity of semantic value stack `yyvs4'

	yyvsp4: INTEGER
			-- Top of semantic value stack `yyvs4'

	yyspecial_routines4: KL_SPECIAL_ROUTINES [IS_TYPE]
			-- Routines that ought to be in SPECIAL [IS_TYPE]

	yyvs5: SPECIAL [attached IS_FIELD]
			-- Stack for semantic values of type attached IS_FIELD

	yyvsc5: INTEGER
			-- Capacity of semantic value stack `yyvs5'

	yyvsp5: INTEGER
			-- Top of semantic value stack `yyvs5'

	yyspecial_routines5: KL_SPECIAL_ROUTINES [attached IS_FIELD]
			-- Routines that ought to be in SPECIAL [attached IS_FIELD]

	yyvs6: SPECIAL [IS_SEQUENCE [attached IS_FIELD]]
			-- Stack for semantic values of type IS_SEQUENCE [attached IS_FIELD]

	yyvsc6: INTEGER
			-- Capacity of semantic value stack `yyvs6'

	yyvsp6: INTEGER
			-- Top of semantic value stack `yyvs6'

	yyspecial_routines6: KL_SPECIAL_ROUTINES [IS_SEQUENCE [attached IS_FIELD]]
			-- Routines that ought to be in SPECIAL [IS_SEQUENCE [attached IS_FIELD]]

feature {NONE} -- Constants

	yyFinal: INTEGER = 62
			-- Termination state id

	yyFlag: INTEGER = -32768
			-- Most negative INTEGER

	yyNtbase: INTEGER = 23
			-- Number of tokens

	yyLast: INTEGER = 76
			-- Upper bound of `yytable' and `yycheck'

	yyMax_token: INTEGER = 269
			-- Maximum token id
			-- (upper bound of `yytranslate'.)

	yyNsyms: INTEGER = 34
			-- Number of symbols
			-- (terminal and nonterminal)

feature -- User-defined features

 
 
feature {NONE} -- Initialization 

	default_create
		do
			make_compressed_scanner_skeleton
			make_parser_skeleton
			Precursor {IS_SYSTEM} 
		end
 
	make (pattern: IS_SYSTEM; f: KI_TEXT_INPUT_STREAM)
		local
			tid: INTEGER
		do
			default_create
			origin := pattern
			force_type (Boolean_ident, pattern)
			force_type (Char8_ident, pattern)
			force_type (Char32_ident, pattern)
			force_type (Int32_ident, pattern)
			force_type (Int64_ident, pattern)
			force_type (Nat32_ident, pattern)
			force_type (Nat64_ident, pattern)
			force_type (Pointer_ident, pattern)
			force_type (String8_ident, pattern)
			force_type (String32_ident, pattern)
			tid := pattern.any_type.ident
			force_type (tid, pattern)
			if attached {like any_type} type_at (tid) as a then
				any_type := a
			end
			max_type_id := max_type_id.max (20)	-- type ident of NONE
			create type_enums.make_equal (199)
			int64 := type_at(Int64_ident)
			make_with_file (f)
		end 
 
feature -- Access

	any_type: attached IS_NORMAL_TYPE

	none_type: like any_type

	type_enums: DS_HASH_TABLE[INTEGER, STRING]

feature -- Error handling

	report_error (msg: STRING)
		do
			io.error.put_string (msg)
			io.error.put_character (' ')
			io.error.put_integer (line)
			io.error.put_character (':')
			io.error.put_integer (column)
			io.error.put_new_line
		end

feature -- Basic operation

	type_by_name (tn: READABLE_STRING_8; attac: BOOLEAN): attached like type_at
		local
			bc: IS_CLASS_TEXT
			nm: STRING
			id: INTEGER
		do
			create nm.make_from_string (tn)
			if attached {IS_NORMAL_TYPE} Precursor (nm, True) as nt then
				Result := nt 
			else
				max_class_id := max_class_id + 1
				create bc.make (max_class_id, tn, 0, Void, Void, Void)
				if STRING_.same_string (tn, "STRING_8") then 
					id := {IS_BASE}.String8_ident
				else
					max_type_id := max_type_id + 1
					id := max_type_id
				end
				create {IS_NORMAL_TYPE} Result.make(id, bc, 
					Reference_flag, Void, Void, Void, Void, Void)
				all_classes.force (bc, bc.ident)
				all_types.force (Result, Result.ident)
			end
		end

	new_special_type (ti: attached IS_TYPE): attached IS_TYPE
		local
			tc: IS_TYPE
			ts: IS_SPECIAL_TYPE
			f: IS_FIELD
			ff: IS_SEQUENCE [attached IS_FIELD]
			fl: INTEGER
		do
			if attached special_type_by_item_type (ti, True) as st then
				Result := st
			else
				max_type_id := max_type_id + 1
				tc := type_by_name ("INTEGER_32", True)
				create f.make ("count", tc, Void, Void);
				create ff.make (3, f);
				ff.add (f)
				create f.make ("capacity", tc, Void, Void);
				ff.add (f)
				create f.make ("item", ti, Void, Void);
				ff.add (f)
				ts := origin.special_type_by_item_type (ti, True)
				if ts /= Void then
					fl := ts.flags
				elseif ti.is_basic then
					fl := Reference_flag
				else 
					fl := ti.flags & Reference_flag
				end
				create {IS_SPECIAL_TYPE} 
				  Result.make (max_type_id, fl, special_class, ti, ff, Void, Void)
				Result.set_c_name (ti.c_name)
				all_types.force (Result, Result.ident)
			end
		end
	
	force_type (tid: INTEGER; pattern: IS_SYSTEM)
		local
			nt: IS_NORMAL_TYPE
			cls: IS_CLASS_TEXT
			cid: INTEGER
		do
			if pattern.valid_type(tid)
				and then attached {IS_NORMAL_TYPE} pattern.type_at(tid) as t
			then
				max_class_id := max_class_id + 1
				cid := max_class_id
				create cls.make(cid, t.class_name, 0, Void, Void, Void)
				all_classes.force (cls, cid)
				if t.is_subobject then
					create {IS_EXPANDED_TYPE} nt.make (tid, cls, t.flags, Void, Void, Void, Void, Void)
				else
					create nt.make (tid, cls, t.flags, Void, Void, Void, Void, Void)
				end
				all_types.force (nt, tid)
				max_type_id := max_type_id.max(tid)
			end
		end
	
feature {NONE} -- Implementation

	max_type_id: INTEGER
	max_class_id: INTEGER

	enum_val: INTEGER

	underscore: STRING = "_"

	id_name: STRING = "_id"

	int64: IS_TYPE

	origin: IS_SYSTEM

	as_class_name (cn: STRING): STRING
		do
			Result := cn.twin
			Result.remove_head (4)
			Result.to_upper
		end

	as_type_name (tn: STRING): STRING
		do
			if STRING_.same_string (tn, "gboolean") then
				Result := "BOOLEAN"
			elseif STRING_.same_string (tn, "gint") then
				Result := "INTEGER_32"
			elseif STRING_.same_string (tn, "gint") then
				Result := "INTEGER_32"
			elseif STRING_.same_string (tn, "guint") then
				Result := "NATURAL_32"
			elseif STRING_.same_string (tn, "guint64") then
				Result := "NATURAL_64"
			elseif STRING_.same_string (tn, "gsize") then
				Result := "NATURAL_64"
			elseif STRING_.same_string (tn, "gchar*") then
				Result := "STRING_8"
			elseif STRING_.same_string (tn, "gpointer") then
				Result := "POINTER"
			elseif STRING_.same_string (tn, "gconstpointer") then
				Result := "POINTER"
			elseif STRING_.same_string (tn, "void*") then
				Result := "POINTER"
			else
				Result := tn.twin
				Result.remove_head (4)
				Result.remove_tail (1)
				Result.right_adjust
			end
			Result.to_upper
		end

	as_struct_name (sn: STRING): STRING
		do
			Result := sn.twin
			Result.remove_head (5)
			Result.to_upper
		end

	type_of_name (nm, c: STRING): attached IS_TYPE
		local
			cn: STRING
		do
			Result := type_by_name (nm, True)
			if Result.c_name = Void then
				inspect Result.ident
				when Boolean_ident then
					cn := "char"
				when Int32_ident then
					cn := "int32_t"
				when Nat32_ident then
					cn := "uint32_t"
				when Nat64_ident then
					cn := "uint64_t"
				when Real32_ident then
					cn := "float"
				when Real64_ident then
					cn := "double"
				when Pointer_ident then
					cn := "void*"
				when String8_ident, String32_ident then
					cn := "char"
				else
					cn := c
				end
				Result.set_c_name (cn)
			end
		end

	expanded_type (nm, cn: STRING): attached IS_EXPANDED_TYPE
		local
			base, ft: attached IS_TYPE
			f: attached IS_FIELD
			ff: IS_SEQUENCE[attached IS_FIELD]
			id, i, n: INTEGER
		do
			base := type_of_name (nm, cn)
			if not base.is_subobject 
				and then attached {IS_NORMAL_TYPE} base as nt 
			 then
				max_type_id := max_type_id + 1
				id := max_type_id
				from
					n := base.field_count
					if n > 0 then
						create ff.make (n, base.field_at(0))
					end
				until i = n loop
					f := base.field_at(i)
					ft := f.type
					if f.name_has_prefix (underscore) and then not f.has_name (id_name) then
						ft := expanded_type (as_class_name (ft.c_name), ft.c_name)
					end
					create f.make (f.fast_name, ft, Void, Void)
					ff.add (f)
					i := i + 1
				end
				create Result.make (id, nt.base_class, 
					Subobject_flag, Void, Void, ff, Void, Void)
				Result.set_c_name (cn)
			end
		end

	treat_enum (nm: STRING)
		local
			i, l: INTEGER
			c: CHARACTER
		do
			l := nm.substring_index(type_ident_name, 1)
			if l > 0 then
				nm.remove_head (type_ident_name.count)
				from
					l := nm.count
					i := 2
				until i > l loop
					c := nm[i]
					if c = '_' then
						nm.remove (i)
					else
						nm[i] := c.as_lower
					end
					i := i + 1
				end
				type_enums.force (enum_val, "Gedb" + nm)
			end
		end

	special_class: IS_CLASS_TEXT
		once
			max_class_id := max_class_id + 1
			create Result.make (max_class_id, "SPECIAL", 0, Void, Void, Void)
		end

	type_ident_name: STRING = "GEDB_TYPE_IDENT_"

invariant 
 
note
	copyright: "Copyright (c) 2013-2014, Wolfgang Jansen and others" 
	license: "MIT License" 
	date: "$Date$" 
	revision: "$Revision$" 
	compilation: "geyacc -t DG_TOKENS -o dg_system.e -x dg_system.y" 

end
