%{ 
note
 
	description: "Parser of TOOL command lines." 
 
class PC_TOOL_PARSER 
 
inherit 
 
	YY_PARSER_SKELETON 
		rename 
			make as make_parser_skeleton 
		end 
 
	PC_TOOL_SCANNER 
		rename 
			make as make_scanner 
		end 
 
	PC_BASE 
 
create 
 
	make_parser 
 
%} 
 
%token <INTEGER> Actual_code, Print_CODE Size_CODE Types_CODE Fields_code 
%token <INTEGER> Objects_CODE Qualifier_CODE Long_code Rename_CODE
%token <INTEGER> Load_CODE Ise2gec_CODE Gec2ise_CODE Xml_CODE Cc_CODE 
%token <INTEGER> Select_CODE Extract_CODE 
%token <INTEGER> Help_CODE Quit_CODE NO_CODE 
%token <INTEGER> E_ALL E_FROM PC_SORT PC_WHERE 
%token <STRING> E_IDENTIFIER E_STRING PC_REFERENCE PC_ALIAS
%token <STRING> '^'  E_MOD E_DIV '*' '/' '+' '-'
%token <NATURAL_64> E_NATURAL
%token <REAL_64> E_REAL
%token E_AS
 
%type <INTEGER> command 
%type <INTEGER> actual size print types fields 
%type <INTEGER> objects qualifier long rename extract 
%type <INTEGER> load ise2gec gec2ise xml cc 
%type <INTEGER> help quit 
%type <STRING> filename
%type <ARRAYED_LIST[PC_TOOL_VALUE]> select_data 
%type <PC_TOOL_VALUE> select_where 
%type <PC_TOOL_VALUE> select_left single expr aliased_expr
%type <ARRAYED_LIST[INTEGER]> select_sort
%type <INTEGER> select_sort_item 
%type <TUPLE[STRING,STRING,STRING]> dict_entry
 
%left E_IMPLIES 
%left E_OR E_XOR 
%left E_AND 
%left '=' E_NE '<' '>' E_LE E_GE 
%left '+' '-' 
%left '*' '/' E_DIV E_MOD 
%right '^' 
%left E_NOT

%start command 
 
%% 
----------------------------------------------------------------------------- 
 
command:	actual 
	|	size 
	|	print 
	|	types 
	|	fields 
	|	objects 
	|	qualifier 
	|	long 
	|	rename 
	|	extract 
	|	select
	|	load 
	|	ise2gec 
	|	gec2ise 
	|	cc 
	|	xml 
	|	help 
	|	quit 
	|	dict_entry
	|	NO_CODE 
			{ raise(once "Unknown command.") } 
	; 
 
actual	:	Actual_CODE 
	; 
 
size	:	Size_CODE 
	; 
 
print	:	Print_CODE 
			{ filename := "" } 
	|	Print_CODE filename
	; 
 
types	:	Types_CODE 
	; 
 
fields	:	Fields_CODE E_NATURAL 
			{ ident := $2.to_integer_32 } 
	; 
 
objects	:	Objects_CODE E_NATURAL 
			{ ident := $2.to_integer_32 } 
	; 
 
qualifier:	Qualifier_CODE PC_REFERENCE
			{ ident := ref_to_integer($2) } 
	|	Qualifier_CODE error 
			{ raise(No_integer) } 
 	; 
 
long	:	Long_CODE PC_REFERENCE
			{ ident := ref_to_integer($2) } 
	|	Long_CODE error 
			{ raise(No_integer) } 
 	; 
 
rename	:	Rename_CODE filename
	|	Rename_CODE error
			{ raise(No_filename) } 
;

extract:	Extract_CODE PC_REFERENCE filename 
			{ ident := ref_to_integer($2) } 
	|	Extract_CODE E_NATURAL error 
			{ raise(No_filename) } 
	|	Extract_CODE error 
			{ raise(No_integer) } 
	; 
 
select	:	SELECT_CODE select_data E_FROM E_NATURAL select_where select_sort
			{ selection := [$2, $4.to_integer_32, $5, $6] }
	|	SELECT_CODE select_data E_FROM E_NATURAL error
			{ raise (once "When or sort clause expected.") } 
	|	SELECT_CODE select_data E_FROM error
			{ raise (once "Invalid type number.") } 
	|	SELECT_CODE select_data error
			{ raise (once "Keyword `from' expected.") } 
	;

select_data :	select_left
			{ create $$.make (4) 
			  $$.force ($1)
			}
	|	select_data ',' select_left
			{ $$ := $1 
			  $$.force ($3) 
			}
	|	error 
			{ raise ("Columns to print expected.") }
	;

select_left:	E_ALL
			{ create $$
			  $$.set_name (all_name)
			}
	|	{ col := column} aliased_expr
			{ $$ := $2 }
	;

aliased_expr:	expr
			{ $$ := $1 
			  if not attached $$.head_name then
			    expr_name := full_line.substring (col, column-1)
			    expr_name.left_adjust
			    expr_name.right_adjust
			    $$.set_name (expr_name)
			  end
			}
	|	expr E_AS PC_ALIAS
			{ $$ := $1 
			  $$.set_name ($3)
			  alias_names.force ($$, $3)
			}
	;

select_where : 	-- empty
			{ $$ := Void }
	|	PC_WHERE expr
			{ $$ := $2 }
	|	PC_WHERE error
			{ raise ("Comparison expected.") }
	;

select_sort : 	-- empty
			{ $$ := Void }
	|	':' select_sort_item
			{ create $$.make (4)
			    $$.extend ($2)
			}
	|	select_sort ',' select_sort_item
			{ $$ := $1
			    $$.extend ($3) 
			}
	;

select_sort_item: E_NATURAL
			{ $$ := $1.to_integer_32 }
	|	E_NATURAL '+'
			{ $$ := $1.to_integer_32 }
	|	E_NATURAL '-'
			{ $$ := - $1.to_integer_32 }
	;

single	:	E_IDENTIFIER
			{ create {PC_TOOL_FIELD} $$.make_qualified (Void, "") 
			  if attached {PC_TOOL_FIELD} $$ as top then
			    create {PC_TOOL_FIELD} $$.make_qualified (top, $1) 
			  end
			}
	|	'?'
			{ create {PC_TOOL_FIELD} $$.make_qualified (Void, "") }
	|	PC_ALIAS
			{ if alias_names.has ($1) then
			    $$ := alias_names [$1]
			  else
			    raise ("Alias name not defined.")
			  end
			}
	|	PC_REFERENCE
			{ create $$ 
			  $$.set_ident (ref_to_integer($1).to_natural_32, 0) }
	|	single '.' E_IDENTIFIER
			{ if attached {PC_TOOL_FIELD} $1 as f then
			    create {PC_TOOL_FIELD} $$.make_qualified (f, $3)
			  end
			}
	|	'(' expr ')' 
			{ $$ := $2.twin }
	;

expr	:	single
			{ $$ := $1 }
	|       E_NATURAL
			{ create $$
			  $$.set_natural ($1.to_natural_32) 
			}
	|       E_REAL
			{ create $$
			  $$.set_real ($1) 
			}
	|	E_NOT expr
			{ create {PC_TOOL_OPERATOR} $$.make_1 ({PC_TOOL_OPERATOR}.not_op, $2) 
			}
	|	'+' expr %prec E_NOT 
			{ create {PC_TOOL_OPERATOR} $$.make_1 ({PC_TOOL_OPERATOR}.plus_op, $2) 
			}
	|	'-' expr %prec E_NOT 
			{ create {PC_TOOL_OPERATOR} $$.make_1 ({PC_TOOL_OPERATOR}.minus_op, $2) 
			}
	|	expr '^' expr 
			{ create{PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.power_op, $1, $3)
			}
	|	expr '*' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.mult_op, $1, $3) 
			}
	|	expr '/' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.div_op, $1, $3) 
			}
	|	expr E_DIV expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.idiv_op, $1, $3) 
			}
	|	expr E_MOD expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.imod_op, $1, $3) 
			}
	|	expr '+' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.plus_op, $1, $3) 
			}
	|	expr '-' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.minus_op, $1, $3) 
			}
	|	expr '=' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.eq_op, $1, $3) 
			}
	|	expr E_NE expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.ne_op, $1, $3) 
			}
	|	expr '<' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.lt_op, $1, $3) 
			}
	|	expr E_LE expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.le_op, $1, $3)
			}
	|	expr '>' expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.gt_op, $1, $3) 
			}
	|	expr E_GE expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.ge_op, $1, $3)
			}
	|	expr E_OR expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.or_op, $1, $3) 
			}
	|	expr E_XOR expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.xor_op, $1, $3) 
			}
	|	expr E_AND expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.and_op, $1, $3) 
			}
	|	expr E_IMPLIES expr 
			{ create {PC_TOOL_OPERATOR} $$.make ({PC_TOOL_OPERATOR}.implies_op, $1, $3) 
			}
	;

load	:	Load_CODE filename 
	|	Load_code error 
			{ raise(No_filename) } 
	; 
 
ise2gec:	Ise2gec_CODE filename filename 
			{ isename := $2;  filename := $3 } 
	|	Ise2gec_CODE error 
			{ raise(No_filename) } 
	; 
 
gec2ise:	Gec2ise_CODE filename 
			{ isename := $2 } 
	|	Gec2ise_CODE error 
			{ raise(No_filename) } 
	; 
 
xml	:	Xml_CODE filename 
	|	Xml_CODE error 
			{ raise(No_filename) } 
	; 
 
cc	:	Cc_CODE filename 
	|	Cc_CODE error 
			{ raise(No_filename) } 
	;

filename:	E_IDENTIFIER
			{ filename := $1 }
	|	E_STRING
			{ filename := $1 }
	;

help	:	Help_CODE 
	; 
 
quit	:	Quit_CODE 
	; 
 
dict_entry:	E_IDENTIFIER E_IDENTIFIER
			{ $$ := [$1.as_upper, Void, $2] 
			  rename_tuple := $$
			}
	|	E_IDENTIFIER '.' E_IDENTIFIER E_IDENTIFIER
			{ $$ := [$1.as_upper, $3.as_lower, $4.as_lower] 
			  rename_tuple := $$
			}
	|	'.' E_IDENTIFIER E_IDENTIFIER
			{ $$ := [Void, $2.as_lower, $3.as_lower] 
			  rename_tuple := $$
			}
	|	error
			{ raise ("Error in dictionary.") }
;

----------------------------------------------------------------------------- 
%% 
 
feature {NONE} -- Initialization 
 
	make_parser 
		do 
			make_scanner 
			make_parser_skeleton 
			filename := ""
			isename := ""
			full_line := ""
			create expression
			alias_names.wipe_out
		end 
 
feature -- Access 
 
	all_name: STRING = "all"

	filename, isename: STRING 

	ident: INTEGER 
 
	selection: TUPLE [what: ARRAYED_LIST [like expression]; 
			  type: INTEGER; 
			  where: like expression; 
			  sort: ARRAYED_LIST [INTEGER]]

	alias_names: HASH_TABLE [PC_TOOL_VALUE, STRING]
		once
			create Result.make (50)
		end

	rename_tuple: TUPLE [cls,f,new: STRING]

feature -- Basic operation 
 
	parse_line(l: STRING) 
		do 
			reset 
			set_input_buffer(new_string_buffer(l)) 
			full_line := l
			parse 
		end 

	parse_rename (l: STRING)
		do
			reset 
			set_input_buffer(new_string_buffer(l)) 
			set_start_condition(RENAMES)
			parse 
		end

feature {NONE} -- Implementation 
 
	expression: PC_TOOL_VALUE

	No_filename: STRING = "File name parameter expected."

	No_integer: STRING = "Integer parameter expected."

	full_line: STRING

	expr_name: detachable STRING

	col: INTEGER

	ref_to_integer(str: STRING): INTEGER
		do
			Result := str.substring (2, str.count).to_integer
		end

invariant
	
note 
	copyright: "Copyright (c) 2010, Wolfgang Jansen and others" 
	license: "MIT License" 
	date: "$Date$" 
	revision: "$Revision$" 
 	compilation: "geyacc -t PC_TOOL_TOKENS -o pc_tool_parser.e pc_tool_parser.y"  
end 
