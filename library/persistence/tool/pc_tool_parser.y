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
 
%token <INTEGER> Actual_code, Size_CODE Types_CODE Fields_CODE 
%token <INTEGER> Objects_CODE Qualifier_CODE Long_code Rename_CODE
%token <INTEGER> Load_CODE Print_CODE Xml_CODE Cc_CODE 
%token <INTEGER> Extract_CODE 
%token <INTEGER> Help_CODE Quit_CODE NO_CODE 
%token <INTEGER> E_ALL E_FROM PC_SORT PC_WHERE 
%token <STRING> E_IDENTIFIER E_STRING PC_ALIAS
%token <NATURAL_64> E_NATURAL
%token E_AS
 
%type <INTEGER> command 
%type <INTEGER> actual size print types fields 
%type <INTEGER> objects qualifier long rename extract 
%type <INTEGER> load xml cc 
%type <INTEGER> help quit 
%type <STRING> filename
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
	|	load 
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
 
qualifier:	Qualifier_CODE E_NATURAL
			{ ident := $2.to_integer_32 } 
	|	Qualifier_CODE error 
			{ raise(No_integer) } 
 	; 
 
long	:	Long_CODE E_NATURAL
			{ ident := $2.to_integer_32 } 
	|	Long_CODE error 
			{ raise(No_integer) } 
 	; 
 
rename	:	Rename_CODE filename
	|	Rename_CODE error
			{ raise(No_filename) } 
;

extract:	Extract_CODE E_NATURAL filename 
			{ ident := $2.to_integer_32 } 
	|	Extract_CODE E_NATURAL error 
			{ raise(No_filename) } 
	|	Extract_CODE error 
			{ raise(No_integer) } 
	; 
 
load	:	Load_CODE filename 
	|	Load_code error 
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
			{ filename := $1 ; need_extension := True }
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
			need_extension := False
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

	need_extension: BOOLEAN 

	expression: PC_TOOL_VALUE

	No_filename: STRING = "File name parameter expected."

	No_integer: STRING = "Object ident expected."

	full_line: STRING

	expr_name: detachable STRING

	col: INTEGER

invariant
	
note 
	copyright: "Copyright (c) 2010, Wolfgang Jansen and others" 
	license: "MIT License" 
	date: "$Date$" 
	revision: "$Revision$" 
 	compilation: "geyacc -t PC_TOOL_TOKENS -o pc_tool_parser.e pc_tool_parser.y"  
end 
