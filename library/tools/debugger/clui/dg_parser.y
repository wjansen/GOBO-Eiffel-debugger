%{ 
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
 
%} 
 
%token <INTEGER> Cont_CODE Next_CODE Step_CODE Finish_CODE End_CODE Off_CODE 
%token <INTEGER> Go_CODE
%token <INTEGER> Mark_CODE Reset_CODE Gc_CODE 
%token <INTEGER> Break_CODE Enable_CODE Disable_CODE Kill_CODE
%token <INTEGER> Where_CODE To_CODE Up_CODE Down_CODE 
%token <INTEGER> Assign_CODE Typeset_CODE 
%token <INTEGER> Processor_CODE Scoop_CODE 
%token <INTEGER> Print_CODE Globals_CODE Alias_CODE 
%token <INTEGER> Closure_CODE Nameof_CODE 
%token <INTEGER> Queries_CODE Creates_CODE Universe_CODE System_CODE 
%token <INTEGER> List_CODE At_CODE Def_CODE Search_CODE Status_CODE 
%token <INTEGER> Overview_CODE Help_CODE Quit_CODE 
%token <INTEGER> LINE_CODE CATCH_CODE WATCH_CODE DEPTH_CODE TYPE_CODE 
%token <INTEGER> Stop_CODE Trace_CODE Silent_CODE 
%token <INTEGER> Store_CODE Restore_CODE 
%token <INTEGER> NO_CODE 

%token DG_COMMENT 
%token DG_LBB "[[" 
%token DG_LCC "{{" 
%token DG_RCC "}}" 
%token DG_PP "++" 
%token <STRING> DG_INLINE DG_ALIAS DG_CLOSURE DG_PLACEHOLDER 
%token <STRING> DG_ARROW 
%token <CHARACTER> DG_FORMAT
%token <INTEGER> DG_UP_FRAME 
%token <CHARACTER> E_CHARACTER 
%token <INTEGER> E_INTEGER 
%token <DOUBLE> E_REAL 
%token <STRING> E_IDENTIFIER E_STRING 
%token E_WHEN E_CHECK E_UNTIL E_CLASS E_IF E_LOOP E_DO E_FROM
%token E_ALL E_DEBUG E_ONCE E_CREATE E_OLD DG_ASSIGN E_LIKE 
%token <STRING> '=' E_NE E_NOT_TILDE E_GE '>' E_LE '<' 
%token <STRING> '^'  E_MOD '*' '/' E_DIV E_FREEOP '+' '-' E_DOTDOT 
%token E_CHARERR E_INTERR E_REALERR E_STRERR 
 
%left E_IMPLIES 
%left E_OR E_XOR 
%left E_AND 
%left '=' E_NE '<' '>' E_LE E_GE '~' E_NOT_TILDE 
%left '+' '-' 
%left '*' '/' E_DIV E_MOD 
%right '^' 
%left E_DOTDOT 
%left E_FREEOP 
%left E_NOT 
 
%type <INTEGER> command 
%type <INTEGER> go mark reset 
%type <INTEGER> break break_idents
%type <STRING> break_at break_type break_if break_catch 
%type <STRING> break_depth break_watch 
%type <STRING> break_print break_trace 
%type <INTEGER> where stack print closure alias assign 
%type <INTEGER> queries creates globals universe system 
%type <INTEGER> list at def search 
%type <INTEGER> info overview help gc quit 
 
%type <DG_EXPRESSION> multi_dot left query create alias_name qualified 
%type <DG_EXPRESSION> args indices 
%type <DG_EXPRESSION> brackets 
%type <DG_EXPRESSION> single range open_indices detailed open_detail 
%type <DG_EXPRESSION> multi multi_or_all 
%type <DG_EXPRESSION> closure_id 
%type <STRING> ident
%type <IS_TYPE> type open_create
%type <IS_CLASS_TEXT> class generic
%type <IS_FEATURE_TEXT> feature 
%type <INTEGER> first_line position single_line line_range
%type <INTEGER> up_frame maybe_int 
%type <CHARACTER> format closure_format 
%type <STRING> go_mode 
 
%start command 
 
%% 
----------------------------------------------------------------------------- 
 
command:	go 
		{ int := 1;  min := 1;  max := {INTEGER}.max_value } maybe_int 
			{ go_count := $3 } 
	|	finish 
	|	end 
	|	cont_pma
	|	mark 
	|	reset 
	|	break 
	|	enable
	|	disable
	|	kill
	|	gc 
	|	where	 
	|	stack	 
	|	print 
	|	closure 
	|	nameof
	|	alias	 
	|	assign	 
	|	typeset 
	|	globals	 
	|	queries	 
	|	creates	 
	|	universe	 
	|	system 
	|	list 
	|	at 
	|	def 
	|	search	 
	|	info 
	|	store
	|	restore
	|	overview	 
	|	help 
	|	quit 
	|	NO_CODE 
			{ message(once "Unknown command.", column) } 
	; 
 
go	:    	CONT_CODE go_mode 
	|	NEXT_CODE go_mode 
	|	STEP_CODE go_mode 
	|	OFF_CODE go_mode 
	; 
 
finish	:	FINISH_CODE go_mode 
	; 
 
end	:	END_CODE go_mode 
	; 
 
go_mode	:	-- empty 
	|	E_IDENTIFIER 
			{ if attached keyword($1, modes, once "keyword") as key then
			    go_mode := key.code 
			  end
			}
; 
 
cont_pma:	GO_CODE
	;

mark	:	MARK_CODE 
	; 
 
reset	:	RESET_CODE 
			{ min := 0;  max := debugger.marker_count-1 } 
		E_INTEGER 
			{ reset_ident := checked_int($3, False) } 
	|	RESET_CODE error 
			{ message(No_integer, column) } 
	; 
 
enable	:	ENABLE_CODE '^'
	|	ENABLE_CODE { int:=0 } break_idents
	|	ENABLE_CODE error { message(No_integer, column) }
	;

disable	:	DISABLE_CODE '^' 
	|	DISABLE_CODE { int:=0 } break_idents
	|	DISABLE_CODE error { message(No_integer, column) }
	;

kill	:	KILL_CODE { int:=1 } break_idents
	|	KILL_CODE error { message(No_integer, column) }
	;

break_idents:	E_INTEGER
			{ if not breakpoints.valid_index($1) 
			      or else breakpoints[$1] = Void then 
			    message(once "No such breakpoint.",column) 
			  else
			    break_idents.force($1) 
			  end
			  set_start_condition(PARAM) 
			}
	|	break_idents ',' E_INTEGER
			{ if not breakpoints.valid_index($3) 
			      or else breakpoints[$3] = Void then 
			    message(once "No such breakpoint.",column) 
			  elseif attached break_idents as bi then
			    bi.force($3) 
			  end
			}
	|	E_ALL
			{ 
			  if attached break_idents as bi then
			    bi.force({INTEGER}.max_value) 
			  end
			}
	|	E_DEBUG
			{ if int/=0 then
			    message(once "Keyword %"debug%" not allowed here.",column) 
			  end
			  if attached break_idents as bi then
			    bi.force(0) 
			  end
			}
	;

break	:      	BREAK_CODE { in_break:=True } break_params
	|	BREAK_CODE E_INTEGER 
			{ in_break:=True 
			  if not breakpoints.valid_index($2) 
			      or else breakpoints[$2] = Void then 
			    message(once "Not a breakpoint number.", column) 
			  end 
			  if attached breakpoints[$2] as b then
			    breakpoint.copy(b) 
			  end
			  break_idents.force($2) 
			} 
		break_params
	;

break_params:  	break_catch break_at break_depth break_watch break_type break_if break_print break_trace
	;

break_catch:	-- emtpy
	|	CATCH_CODE E_IDENTIFIER 
			{ breakpoint.set_catch(keyword($2, catch_keys, once "keyword")) 
			  set_start_condition(BREAK) 
			} 
	|	CATCH_CODE E_ALL
			{ set_start_condition(BREAK) }
			{ breakpoint.set_catch(keyword("all", catch_keys, once "keyword")) } 
	|	CATCH_CODE DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_catch(Void) 
			} 
	; 
 
break_at:	-- emtpy 
        |       LINE_CODE {int:=column} position
			{ set_start_condition(BREAK)
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
			}
	|	LINE_CODE DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_range(Void) 
			} 
	; 
 
break_depth:	-- emtpy
	|	DEPTH_CODE E_INTEGER 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_stack_level($2) 
			  breakpoint.set_automatic_stack(False) 
			} 
	|	DEPTH_CODE E_INTEGER DG_PP 
			{ set_start_condition(BREAK) 
			  breakpoint.set_stack_level($2) 
			  breakpoint.set_automatic_stack(True) 
			} 
	|	DEPTH_CODE DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_stack_level(0) 
			} 
	; 
 
break_watch:	-- emtpy
	|	WATCH_CODE single 
			{ set_start_condition(BREAK) 
			  put_back(text) 
			  column := column - text.count + 1
			  breakpoint.set_watch($2, debugger.shown_frame) 
			} 
	|	WATCH_CODE DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_watch(Void, debugger.shown_frame) 
			} 
 	; 
 
break_type:	-- emtpy
	|	TYPE_CODE 
		type 
			{ set_start_condition(BREAK) 
			  if text.is_empty or else text[1] = ']' then
			    -- ignore bad scan
			  else
			    put_back(text)
			  end
			  breakpoint.set_type($2) 
			} 
	|	TYPE_CODE DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text) 
			  breakpoint.set_type(Void) 
			} 
	; 
 
break_if:	-- emtpy
	|	E_IF 
			{ forbidden_closure := True }
		single 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_condition($3) 
			} 
	|	E_IF DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_condition(Void) 
			} 
	; 
 
break_print:	-- emtpy
	|	PRINT_CODE {forbidden_closure := True} format multi 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_action($4) 
			} 
	|	PRINT_CODE DG_COMMENT 
			{ set_start_condition(BREAK) 
			  put_back(text)
			  breakpoint.set_action(Void) 
			} 
	; 
 
break_trace:	-- empty 
	|	CONT_CODE 
			{ breakpoint.set_trace_only(True) } 
	|	CONT_CODE DG_COMMENT 
			{ breakpoint.set_trace_only(False) } 
	; 
 
gc	:	GC_CODE 
	; 
 
where	:	WHERE_CODE 
	; 
 
stack	:	TO_CODE 
			{ int := debugger.bottom_frame.depth - debugger.shown_frame.depth 
			  min := 0;  max := {INTEGER}.max_value 
			} 
		maybe_int 
			{ stack_count := $3 } 
	|	UP_CODE 
			{ int := 1;  min := 1;  max := {INTEGER}.max_value } 
		maybe_int 
			{ stack_count := $3 } 
	|	DOWN_CODE 
			{ int := 1;  min := 1;  max := {INTEGER}.max_value } 
		maybe_int 
			{ stack_count := $3 } 
	; 
 
print	:	PRINT_CODE format
	|	PRINT_CODE format multi { multi := $3 }
	;
 
format	:	-- empty 
	|	DG_FORMAT 
			{ check_format(once "lnagx", column) }
	; 
 
closure	:	CLOSURE_CODE closure_format 
			{ single := as_closure(current_closure) } 
	|	CLOSURE_CODE closure_format single 
			{ single := as_closure($3) } 
	|	CLOSURE_CODE DG_COMMENT 
			{ single := Void } 
	|	CLOSURE_CODE closure_format error
			{ message(once "Expression expected.", column) } 
	; 
 
closure_format:	-- empty 
	|	DG_FORMAT 
			{ check_format(once "naxd", column) }
	; 
 
nameof	:	NAMEOF_CODE closure_id
			{ command_code := NAMEOF_CODE
			  single := $2
			}
	|	NAMEOF_CODE 
		{int:=column} 
		DG_FORMAT 
		{ check_format(once "t", int) }
		closure_id
			{ command_code := NAMEOF_CODE
			  single := $5
			}
	|	NAMEOF_CODE error
			{ message(once "Closure ident expected.", column) } 

	;
 
assign	:	ASSIGN_CODE single DG_ASSIGN single 
			{ target := $2
			  if attached target as t then
			    t.compute(debugger.shown_frame, value_stack) 
			  end
			  single := $4
			  if attached single as s then
			    s.compute(debugger.shown_frame, value_stack) 
			  end
			} 
	|	ASSIGN_CODE single DG_ASSIGN error 
			{ message(once "Source expression expected.", column) } 
	|	ASSIGN_CODE single error 
			{ message(once "Assignment operator expected.", column) } 
	|	ASSIGN_CODE error 
			{ message(once "Target expression expected.", column) } 
	; 
 
typeset	:	TYPESET_CODE single 
			{ single := $2  
			  if attached single as s then
			    s.compute(debugger.shown_frame, value_stack) 
			  end
			}
	|	TYPESET_CODE error 
			{ message(once "Expression expected.", column) } 
	; 
 
globals	:	GLOBALS_CODE 
	; 
 
system	:	SYSTEM_CODE 
	; 
queries	:	QUERIES_CODE 
			{ type := Void } 
	| 	QUERIES_CODE type 
			{ type := $2 } 
	|	QUERIES_CODE error { message(No_type, column) }
	; 
 
creates	:	CREATES_CODE 
			{ type := Void } 
	| 	CREATES_CODE type 
			{ type := $2 } 
	|	CREATES_CODE error { message(No_type, column) }
	; 
 
universe:	UNIVERSE_CODE 
	; 
 
at	:	AT_CODE position 
	;
 
list	:	LIST_CODE 
			{ lines.set_count(max_lines - 2) } 
	|	LIST_CODE { in_list := True } line_range { in_list := False } 
	;
 
def	:	DEF_CODE position 
			{ check attached lines.cls as cls end
			  if not attached {IS_ROUTINE_TEXT} lines.cls.feature_by_line (lines.first_line) as rt then
			    message(once "Not in a feature_body.", column)
			  elseif not attached rt.instruction_positions as p then
			    message(once "Instruction positions not generated.", column)
			  end
			} 
	|	DEF_CODE error 
			{ message(once "Position expected.",column) } 
	; 
 
relative_lines:	'-' E_INTEGER 
			{ lines.set_class(debugger.shown_frame.routine.home) 
			  lines.set_first_line(debugger.shown_frame.line - $2) 
			  int := $2 + 1
			  lines.set_count(int) 
			} 
	|	'-' E_INTEGER '`' E_INTEGER
			{ lines.set_class(debugger.shown_frame.routine.home) 
			  lines.set_first_line(debugger.shown_frame.line - $2) 
			  min := 1;  max := {INTEGER}.max_value
			  lines.set_count(checked_int($4, False)) 
			} 
	|	'-' E_INTEGER '`' error 
			{ message(once "Line count expected.", column) } 
	|	'-' error 
			{ message(once "Line offset expected.", column) } 
	; 
 
single_line:	class 
			{ lines.set_first_line(1) 
		          lines.set_count(max_lines - 2) 
			} 
	|	class feature
	|	class ':' first_line
	|	feature
	|	first_line
	; 
 
feature	:	'.' E_IDENTIFIER 
			{ $$ := feature_by_name($2, lines.cls, False)
			  lines.set_text($$, in_break) }
	|	'.' DG_INLINE 
			{ $$ := feature_by_name($2, lines.cls, False)
			  lines.set_text($$, in_break) } 
	|	'.' error 
			{ message(once "Feature name expected.", column) } 
	; 
 
first_line:	E_INTEGER 
			{ lines.set_first_line($1)
			  if in_list then 
			    lines.set_count(max_lines - 2) 
			  else 
			    lines.set_count(1) 
			  end 
			}
	; 
	 
position:	first_line
	|	first_line ':' E_INTEGER
			{ lines.set_line_column (lines.first_line, $3) }
	|	class ':' first_line
	|	class ':' first_line ':' E_INTEGER
			{ lines.set_line_column (lines.first_line, $5) }
	|	class error 
			{ message(once "Line number expected.",column) } 
	|	class ':' first_line error 
			{ message(once "Column number expected.",column) } 
	|	first_line ':' error 
			{ message(once "Column number expected.",column) } 
	; 
 
	 
line_range:	single_line
	|       single_line '`' E_INTEGER
			{ min := 1;  max := {INTEGER}.max_value; 
			  lines.set_count(checked_int($3, False)) } 
	|	single_line ',' E_INTEGER
			{ min := lines.first_line;  max := {INTEGER}.max_value; 
			  lines.set_count(checked_int($3, False)-lines.first_line+1) 
			} 
	|	relative_lines 
	|	single_line error
			{ message(once "Line number expected.", column) } 
	|	single_line '`' error 
			{ message(once "Line count expected.",column) } 
	|	single_line ',' error 
			{ message(once "Last line number expected.", column) } 
	; 
	 
type	:	E_INTEGER 
			{ if attached system.type_at($1) as t then
			    $$ := t
			  else
			    message(once "Invalid type number.", column) 
			  end 
			} 
	|	class 
			{ class_text := $1 
			  if attached system.type_by_class_and_generics($1.name, 0, False) as t then
			    $$ := t
			  else
			     message(once "Type not known.", column) 
			  end			 
			} 
	|	generic type_list ']'
			{ int := count_stack.item
			  count_stack.remove
			  if attached system.type_by_class_and_generics($1.name, int, False) as t then
			    $$ := t
			    system.pop_types(int) 
			  else
			    system.pop_types(int) 
			    message(once "Type not known.", column) 
			  end			 
			}
	|	E_LIKE single 
			{ $2.compute(debugger.shown_frame, value_stack) 
			  if attached $2.bottom.type as bt then
			    $$ := bt
			  end
			  value_stack.pop(1) 
			} 
	|	generic type_list error 
			{ count_stack.wipe_out
			  message(once "Right bracket expected.", column) } 
	|	generic error 
			{ count_stack.wipe_out
			  message(once "Generic parameters expected.", column) } 
	;	 
 
generic:	class '[' 
			{ $$ := $1 
			  count_stack.force(0)
			} 
	;	 
type_list:	type 
			{ system.push_type($1.ident) 
			  count_stack.replace(count_stack.item + 1) 
			} 
	|	type_list ',' type 
			{ system.push_type($3.ident) 
			  count_stack.replace(count_stack.item + 1) 
			} 
	; 
 
class	:	E_IDENTIFIER 
			{ $$ := class_by_name($1)
			  lines.set_class($$) } 
	; 
 
search	:	SEARCH_CODE 
	; 
 
info	:	STATUS_CODE 
			{ status_what := 0 } 
	|	STATUS_CODE E_IDENTIFIER  
			{ if attached keyword($2, status_commands, once "keyword") as key then  
			    status_what := key.code   
			  end
			}
	|	STATUS_CODE error 
			{ if attached keyword(once "", status_commands, once "keyword") as key then  
			    status_what := key.code   
			  end
			}
	; 
 
store	:	STORE_CODE 
			{ status_what := Store_CODE 
			  file_name := ""
			} 
	|	STORE_CODE E_IDENTIFIER 
			{ status_what := Store_CODE 
			  file_name := $2
			} 
	|	STORE_CODE E_STRING 
			{ status_what := Store_CODE 
			  file_name := $2
			} 
	|	STORE_CODE error 
			{ message(No_file_name, column) }
	;

restore	:	RESTORE_CODE 
			{ status_what := Restore_CODE 
			  file_name := ""
			} 
	|	RESTORE_CODE E_IDENTIFIER 
			{ status_what := Restore_CODE 
			  file_name := $2
			} 
	|	RESTORE_CODE E_STRING 
			{ status_what := Restore_CODE 
			  file_name := $2
			} 
	|	RESTORE_CODE error 
			{ message(No_file_name, column) }
	;

overview:	OVERVIEW_CODE 
	; 
 
help	:	HELP_CODE 
	; 
 
quit	:	QUIT_CODE 
	; 
 
 
multi	:	detailed 
			{ $$ := $1 } 
	| 	multi ',' detailed 
			{ $$ := $1 
			  $$.last.set_next($3) 
			  if $$.is_detailed then 
			    placeholders.finish
			    placeholders.remove
			  end 
			} 
	| 	multi ',' error 
			{ $$ := $1 
			  message(No_expression,column-1) 
			  recover 
			} 
	; 
 
detailed:	range 
			{ $$ := $1 } 
	|	open_detail multi_or_all DG_RCC 
			{ $$ := $1 
			  $$.set_detail($2) 
			  check not placeholders.is_empty end 
			  placeholders.finish
			  placeholders.remove
			} 
	|	open_detail multi_or_all error 
			{ message(once "Right double brace expected.", column) }
	|	open_detail error 
			{ message(once "Expression expected.", column) 
			  recover 
			} 
	; 
 
 
open_detail:	range DG_LCC 
			{ $$ := $1 
			  placeholders.force($1.bottom) 
			} 
		|	range '{'
			{ message(once "Left double brace expected.", column) }
	; 
 
multi_or_all:	multi 
			{ $$ := $1 } 
	|	E_ALL 
			{ create $$.make_as_all(1, column) } 
	|	E_ALL E_INTEGER
			{ create $$.make_as_all($2, column) } 
	; 
 
range	:	single 
			{ $$ := $1 } 
	|	open_indices indices ']' ']' 
			{ $$ := $1 
			  $$.bottom.set_arg($2) 
			  placeholders.finish
			  placeholders.remove
			} 
	|	open_indices indices error 
			{ message(once "Right double bracket expected.", column) } 
	|	open_indices error 
			{ message(once "Indices expected.", column) } 
	; 
 
open_indices:	single DG_LBB 
			{ create {DG_RANGE_EXPRESSION} $$.make($1, $1.column) 
			  placeholders.force($$) 
			  $$ := $1 
			} 
	; 
 
indices	:	single ',' single 
			{ $$ := $1 
			  $$.set_next($3) 
			} 
	|	single '`' single 
			{ create $$.make($3.column)
			  $$.set_entity(count_entity)
			  $$.set_arg($3)
			  $1.set_next($$)
			  $$ := $1 
			} 
	|	E_ALL 
			{ create $$.make(column)
			  $$.set_entity(all_entity) 
			} 
	|	E_IF single 
			{ create $$.make($2.column)
			  $$.set_down($2) 
			  $$.set_entity(if_entity) 
			} 
	| 	E_IF error 
			{ message(No_expression, column) } 
	|	single 
			{ message(once "Count or upper index expected.", column) } 
	|	single ',' error 
			{ message(once "Upper index expected.", column) } 
	; 
 
single	:	multi_dot 
			{ $$ := $1 } 
	|	'+' single %prec E_NOT 
			{ compose_prefix($2, plus_op) 
			  $$ := $2 
			} 
	|	'-' single %prec E_NOT 
			{ compose_prefix($2, minus_op) 
			  $$ := $2 
			} 
	|	E_NOT single 
			{ compose_prefix($2, not_op) 
			  $$ := $2 
			} 
	|	E_FREEOP single
			{ compose_free(Void, $2, $1) 
			  $$ := $2 
			} 
	|	'+' error 
			{ message(once "Operand expected.", column) } 
	|	'-' error 
			{ message(once "Operand expected.", column) } 
	|	E_NOT error 
			{ message(once "Operand expected.", column) } 
	|	E_FREEOP error 
			{ message(once "Operand expected.", column) } 
	|	single E_FREEOP single 
			{ compose_free($1,$3,$2) 
			  $$ := $1 
			} 
	|	single '^' single 
			{ compose_infix($1,$3,power_op,7,Void) 
			  $$ := $1 
			} 
	|	single '*' single 
			{ compose_infix($1,$3,mult_op,6,Void) 
			  $$ := $1 
			} 
	|	single '/' single 
			{ compose_infix($1,$3,div_op,6,Void) 
			  $$ := $1 
			} 
	|	single E_DIV single 
			{ compose_infix($1,$3,idiv_op,6,Void) 
			  $$ := $1 
			} 
	|	single E_MOD single 
			{ compose_infix($1,$3,imod_op,6,Void) 
			  $$ := $1 
			} 
	|	single '+' single 
			{ compose_infix($1,$3,plus_op,5,Void) 
			  $$ := $1 
			} 
	|	single '-' single 
			{ compose_infix($1,$3,minus_op,5,Void) 
			  $$ := $1 
			} 
	|	single E_DOTDOT single 
			{ compose_infix($1,$3,interval_op,5,Void) 
			  $$ := $1 
			} 
	|	single '=' single 
			{ compose_infix($1,$3,eq_op,4,equality_entity) 
			  $$ := $1 
			} 
	|	single E_NE single 
			{ compose_infix($1,$3,ne_op,4,equality_entity) 
			  $$ := $1 
			} 
	|	single '~' single 
			{ compose_infix($1,$3,sim_op,4,equality_entity) 
			  $$ := $1 
			} 
	|	single E_NOT_TILDE single 
			{ compose_infix($1,$3,nsim_op,4,equality_entity) 
			  $$ := $1 
			} 
	|	single '<' single 
			{ compose_infix($1,$3,lt_op,4,Void) 
			  $$ := $1 
			} 
	|	single E_LE single 
			{ compose_infix($1,$3,le_op,4,Void) 
			  $$ := $1 
			} 
	|	single '>' single 
			{ compose_infix($1,$3,gt_op,4,Void) 
			  $$ := $1 
			} 
	|	single E_GE single 
			{ compose_infix($1,$3,ge_op,4,Void) 
			  $$ := $1 
			} 
	|	single E_AND single 
			{ compose_infix($1,$3,and_op,3,Void) 
			  $$ := $1 
			} 
	|	single E_OR single 
			{ compose_infix($1,$3,or_op,2,Void) 
			  $$ := $1 
			} 
	|	single E_XOR single 
			{ compose_infix($1,$3,2,xor_op,Void) 
			  $$ := $1 
			} 
	|	single E_IMPLIES single 
			{ compose_infix($1,$3,implies_op,1,Void) 
			  $$ := $1 
			} 
	|	single E_FREEOP error 
			{ message(once "Right operand expected.", column) } 
	|	single '^' error 
			{ message(once "Right operand expected.", column) } 
	|	single '*' error 
			{ message(once "Right operand expected.", column) } 
	|	single '/' error 
			{ message(once "Right operand expected.", column) } 
	|	single E_DIV error 
			{ message(once "Right operand expected.", column) } 
	|	single E_MOD error 
			{ message(once "Right operand expected.", column) } 
	|	single '+' error 
			{ message(once "Right operand expected.", column) } 
	|	single '-' error 
			{ message(once "Right operand expected.", column) } 
	|	single '=' error 
			{ message(once "Right operand expected.", column) } 
	|	single E_NE error 
			{ message(once "Right operand expected.", column) } 
	|	single '<' error 
			{ message(once "Right operand expected.", column) } 
	|	single '>' error 
			{ message(once "Right operand expected.", column) } 
	|	single E_LE error 
			{ message(once "Right operand expected.", column) } 
	|	single E_GE error 
			{ message(once "Right operand expected.", column) } 
	|	single '~' error 
			{ message(once "Right operand expected.", column) } 
	|	single E_NOT_TILDE error 
			{ message(once "Right operand expected.", column) } 
	|	single E_AND error 
			{ message(once "Right operand expected.", column) } 
	|	single E_OR error 
			{ message(once "Right operand expected.", column) } 
	|	single E_XOR error 
			{ message(once "Right operand expected.", column) } 
	|	single E_IMPLIES error 
			{ message(once "Right operand expected.", column) } 
	; 
 
multi_dot:	left 
			{ $$ := $1 } 
	| 	multi_dot '.' qualified 
			{ $$ := $1 
			  if $3.entity = details_entity then 
			    $$.bottom.set_detail($3) 
			    $3.set_parent($$.bottom) 
			  else 
			    $$.bottom.set_down($3) 
			  end 
			} 
	|	multi_dot brackets 
			{ create $$.make_as_down($1, $2.column) 
			  $$.set_entity(bracket_entity) 
			  $$.set_arg($2) 
			  $$ := $1 
			} 
	; 
 
qualified:	query 
			{ $$ := $1 } 
	|	alias_name 
			{ if $1.is_manifest and then $1.entity /= details_entity then 
			    message(once "Immediate alias name must not be qualified.", column) 
			  end 
			  $$ := $1 
			} 
	; 
 
up_frame:	'^' 
			{ $$ := 1 } 
	|      DG_UP_FRAME 
			{ $$ := $1 } 
	; 
 
left	:	query 
			{ $$ := $1 } 
	|	create 
			{ $$ := $1 } 
	| 	up_frame query 
			{ $$ := $2 
			  $$.set_up_frame_count($1) 
			} 
	|	alias_name 
			{ if $1.entity = details_entity then 
			    message(once "Details may not start an expression.", column) 
			  end 
			  $$ := $1 
			} 
	| 	'(' single ')' 
			{ $$ := $2 } 
	|	'(' single error 
			{ message(once "Right parenthesis expected.", column) } 
	|	'(' error ')' 
			{ message(No_expression, column) } 
	|	closure_id 
			{ $$ := $1 }
	| 	E_CHARACTER 
			{ create $$.make(column) 
			  $$.set_manifest(Character_ident, text) 
			} 
	| 	E_STRING 
			{ create $$.make(column)
			  $$.set_manifest(String8_ident, $1) } 
	| 	E_INTEGER 
			{ create $$.make(column)
			  $$.set_manifest(Integer_ident, text) } 
	| 	E_REAL 
			{ create $$.make(column)
			  $$.set_manifest(Real64_ident, text) } 
--	| 	E_OLD ':' E_INTEGER 
--			{ create $$.make(column)
--			  $$.set_entity(old_entity) 
--			  $$.set_name(text) 
--			} 
--	|	E_OLD error 
--			{ message(once "Colon expected.", column) } 
	|	'{' class '}' '.' E_IDENTIFIER 
			{ create $$.make_from_feature($2, feature_by_name($5, $2, False), column) } 
	|	DG_PLACEHOLDER 
			{ if placeholders.is_empty then 
			    message(once "Placeholders are not allowed here.", column) 
			  elseif placeholders.count < $1.count then 
			    message(once "Not as many nested details.", column)
			  end 
			  ph := placeholders[placeholders.count-$1.count+1]
			  if attached ph as p then
			    if $1[1]=':' and then not p.is_range then 
			      message(once "Index placeholders are not allowed here.", column) 
			    end 
			    create $$.make(column - 1)
			    $$.set_entity(placeholder_entity) 
			    $$.set_name($1) 
			    $$.set_parent(p) 
			  end 
			} 
	; 
 
alias	:	ALIAS_CODE E_IDENTIFIER DG_ASSIGN single 
			{ alias_name := $2 
			  single := $4 
			  if attached single as s then
			    s.compute(debugger.shown_frame, value_stack)
			  end
			  is_lazy := False 
			} 
	|	ALIAS_CODE E_IDENTIFIER DG_ARROW {forbidden_closure := True} detailed 
			{ alias_name := $2 
			  single := $5 
			  is_lazy := True 
			} 
	|	ALIAS_CODE E_IDENTIFIER DG_ARROW {forbidden_closure := True} DG_LCC 
			{ 
			  alias_name := $2 
			  create single.make(column) 
			  if attached single as s then
				  s.set_entity(details_entity) 
				  placeholders.force(s) 
			  end
			} 
		multi DG_RCC 
			{ if attached single as s then
			    s.set_detail($7) 
			  end
			  is_lazy := True 
			} 
	|	ALIAS_CODE E_IDENTIFIER DG_COMMENT 
			{ alias_name := $2;  single := Void } 
	|	ALIAS_CODE E_IDENTIFIER DG_ASSIGN error 
			{ message(once "Expression expected.", column) } 
	|	ALIAS_CODE E_IDENTIFIER DG_ARROW error 
			{ message(once "Expression expected.", column) } 
	|	ALIAS_CODE E_IDENTIFIER error 
			{ message(once "One of `->', `:=' or `--' expected.", column) } 
	|	ALIAS_CODE error 
			{ message(once "Alias name to be defined expected.", column) } 
	; 
 
ident	:	E_IDENTIFIER 
			{ $$ := $1 
			  op_column := column
			} 
	|	DG_INLINE 
			{ $$ := $1 
			  op_column := column
			} 
	; 
 
alias_name:	DG_ALIAS 
			{ $$ := as_alias($1)
			  $$ := $$.twin
			} 
	; 
 
closure_id:	DG_CLOSURE 
			{ tmp_str.copy($1)
			  tmp_str.remove(1)
			  $$ := int_to_closure(tmp_str.to_natural_32)
			} 
	;

query	:	ident 
			{ create $$.make(op_column) 
			  $$.set_name($1) 
			} 
	|	ident '(' args ')' 
			{ create $$.make(op_column) 
			  $$.set_name($1) 
			  $$.set_arg($3) 
			} 
	|	ident '(' ')' 
			{ message(No_expression, column) } 
	|	ident '(' args error
			{ message(once "Right parenthesis expected.", column) } 
	|	ident '(' error 
			{ message(No_expression, column) } 
	; 
 
create	:	open_create '!'
			{ create $$.make_from_type($1, Void, int) } 
	|	open_create ':' single '!'
			{ create $$.make_from_type($1, $3, int) } 
 	|	open_create error
			{ message(once "Exclamation mark or colon expected.", column) }
	;

open_create:	'!' {int:=column} type 
			{ $$ := $3 } 
 	|	'!' error
			{ message(No_type, column) }
	;

brackets:	'[' args ']' 
			{ $$ := $2 
			  op_column := column
			} 
	|	'[' args error
			{ message(once "Right bracket expected.", column) } 
	|	'[' error 
			{ message(No_expression, column) } 
	; 
 
args:		single 
			{ $$ := $1 } 
	|	args ',' single 
			{ $$ := $1;  $$.last.set_next($3) } 
  	| 	args ',' error 
			{ message(No_expression, column) } 
	; 
 
maybe_int:	-- empty 
			{ $$ := checked_int(int, True) } 
	|	E_INTEGER 
			{ $$ := checked_int($1, False) } 
	|	error
			{ message(No_integer, column) } 
	; 
	 
----------------------------------------------------------------------------- 
%% 
 
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
