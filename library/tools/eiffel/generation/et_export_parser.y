%{ 
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
 
%} 
 
%token <STRING> E_IDENTIFIER C_IDENTIFIER EOL OTHER
 
%type <ET_COMPILATION_ORDER> type feature
%type <DS_ARRAYED_LIST[ET_COMPILATION_ORDER]> type_list
%type <STRING> identifier

%start associations

%% 
----------------------------------------------------------------------------- 

associations: 	association 
	|	associations association 
	|	EOL
	;

association: feature '=' identifier EOL { associations.force($3, $1) }
	|	'*' feature '=' identifier EOL {
			$2.set_as_creation(True)
			associations.force($4, $2)
 		}
	|	error EOL { clear_token ; recover }
	;

feature:	type '.' E_IDENTIFIER {
			last_order := $1
			$$ := $1
			$$.set_feature_name($3)
		}
	|	E_IDENTIFIER {
			$$ := last_order
			$$.set_feature_name($1)
		}
	;

type:		E_IDENTIFIER { create $$.make ($1) }
	|	E_IDENTIFIER '[' type_list ']' {
			create $$.make ($1)
			from
				$3.start
			until $3.after loop
				$$.add_suborder($3.item_for_iteration)
				$3.forth
			end
		}
	;

type_list:	type { 
			create $$.make(2)
			$$.put_last ($1)
		}
	|	type_list ',' type {
			$$ := $1
			$$.put_last ($3)
		} 
	; 

identifier:	E_IDENTIFIER { $$ := $1 }
	|	C_IDENTIFIER { $$ := $1 }
	; 

----------------------------------------------------------------------------- 
%% 
 
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
