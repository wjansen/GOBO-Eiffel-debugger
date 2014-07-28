%{ 
note
 
	description: 
 
		"Scanner for PC_TOOL parser % 
                %Extract from class ET_EIFFEL_SCANNER:% 
		%multi line strings and most keywords have been dropped." 
 
	copyright: "Copyright (c) 1999-2003, Eric Bezault and others" 
	base_source: "et_eiffel_scanner.l" 
 
class PC_TOOL_SCANNER 
 
inherit 
 
	YY_COMPRESSED_SCANNER_SKELETON 
		rename 
			make as make_compressed_scanner_skeleton, 
			reset as reset_compressed_scanner_skeleton 
		end 
 
	PC_TOOL_TOKENS 
		export {NONE} all end 
 
 
        EXCEPTIONS 
                undefine 
                        default_create, 
                        copy, is_equal, out 
                redefine 
                        raise 
                end 

create 
 
	make 
%} 
 
CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])) 
 
%x IS_STR 
%x PARAM 
%x SELECTS
%x RENAMES
 
%option nodefault line outfile="pc_tool_scanner.e" 
 
%% 
 
----------/** Commands **/--------------------------------------------------- 
 
<INITIAL> { 
[A-Za-z]+		{	if attached keyword(text, commands, once "command") as lk then
				 	last_key := keyword(text, commands, once "command") 
					command_name := last_key.name 
					command_code := last_key.code 
					last_token := command_code 
				end
				inspect command_code
					when SELECT_CODE then
					set_start_condition(SELECTS)
				else
					set_start_condition(PARAM)
				end
			} 
} -- INITIAL 
 
----------/** Operators and numbers **/--------------------------------------
 
<SELECTS> {

[Aa][[Ll][Ll]			last_token := E_ALL
[Ff][Rr][Oo][Mm]		last_token := E_FROM
[Oo][Rr]			last_token := E_OR
[Xx][Oo][Rr]			last_token := E_XOR
[Aa][Nn][Dd]			last_token := E_AND
[Ii][Mm][Pp][Ll][Ii][Ee][Ss]	last_token := E_IMPLIES
[Nn][Oo][Tt]			last_token := E_NOT
[Aa][Ss]			last_token := E_AS
[Ww][Hh][Ee][Rr][Ee]		last_token := PC_WHERE
[Ss][Oo][Rr][Tt]		last_token := PC_SORT

"/="				last_token := E_NE
"<="				last_token := E_LE
">="				last_token := E_GE
"//"				last_token := E_DIV
"\\\\"				last_token := E_MOD

[-+*/^=<>.,:?]			last_token := text_item (1).code

[0-9]+\.$                               |
[0-9]+\./[^.0-9]                        |
[0-9]+\.[0-9]*[eE][+-]?[0-9]+           |
[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?        {
                                                last_token := E_REAL
                                                last_real_64_value := text.to_double
                                        }
} -- <SELECTS>

----------/** Parameters **/------------------------------------------------- 
 
<PARAM,SELECTS> { 
 
[a-zA-Z][a-zA-Z0-9_]*	{
				last_token := E_IDENTIFIER
				last_string_value := text
                        }

"_"[1-9][0-9_]*		{
				last_token := PC_REFERENCE
				last_string_value := text
                        }

"_"[A-Za-z][A-Za-z0-9_]*		{
				last_token := PC_ALIAS
				last_string_value := text
                        }

[0-9]+                  {
                                last_token := E_NATURAL
                                last_natural_64_value := text.to_natural_64
                        }

[ \t\r]+			-- Ignore separators 
 
 
} -- <PARAM,SELECTS> 
  
<PARAM> {

\"[^%\n"]*\"		{
				last_token := E_STRING
				last_string_value := text_substring (2, text_count - 1)
			}

} -- <PARAM> 
 
<RENAMES> {

[a-zA-Z][a-zA-Z0-9_]*	{
				last_token := E_IDENTIFIER
				last_string_value := text
                        }

\.				last_token := text_item (1).code

"--".*				-- Ignore comment

} -- <RENAMES>

----------------------------------------------------------------------------- 
 
<INITIAL,PARAM,SELECTS,RENAMES> {

\n			terminate 
.			default_action

} 

----------------------------------------------------------------------------- 
 
%% 
 
feature {NONE} -- Initialization 
 
	make 
			-- Create a new Eiffel scanner. 
		do 
			make_with_buffer (Empty_buffer) 
			create eif_buffer.make (Init_buffer_size) 
			create msg_.make(100) 
			create command_name.make(100) 
			create pretty_command.make(100) 
			last_string_value := ""
		end 
 
feature -- Initialization 
 
	reset 
			-- Reset scanner before scanning next input. 
		do 
			reset_compressed_scanner_skeleton 
			eif_buffer.wipe_out 
			command_code := NO_CODE 
			pretty_command.wipe_out 
		end 
 
feature -- Access 
 
	commands: ARRAYED_LIST[TUPLE[ INTEGER, STRING, detachable STRING, detachable STRING]] 
		once 
			create Result.make(50) 
			Result.force([Load_CODE, "load", "fn", "Load store file with name %"fn%"."]) 
			Result.force([Actual_CODE, "info", "", "Show header info of actually loaded store file."]) 
			Result.force([Size_Code, "size", "", "Print statistics of the store file."]) 
			Result.force([Print_CODE, "data", "", "Print the data to standard output."]) 
			Result.force([Types_CODE, "types", "", "Print the list of types to standard output."]) 
			Result.force([Fields_CODE, "fields", "tid", "Print field names of type %"tid%"."]) 
			Result.force([Objects_CODE, "objects", "tid", "Print object idents having type %"tid%"."]) 
			Result.force([Qualifier_CODE, "name", "id", "Print the qualified name of object %"id%"."]) 
			Result.force([Long_CODE, "verbose", "id", "Like %"name id%" including type name at each level."]) 
			Result.force([Rename_CODE, "rename", "f", "Rename classes and attributes from dictonary in file %"f%"."]) 
			Result.force([Select_code, "select", "from T", "select closure idents of type %"T%" having specific properties"]) 
			Result.force([Extract_CODE, "extract", "id fn", "Store persistence closure of object %"id%" to file %"fn%"."]) 
			Result.force([CC_CODE, "cc", "fn", "Write data in C code format to file %"fn%"."]) 
			Result.force([Xml_CODE, "xml", "fn", "Write data in XML format to file %"fn%"."]) 
			Result.force([Help_CODE, "help", "", "Print this help text."]) 
			Result.force([Quit_CODE, "quit", "", "Quit the tool."]) 
		end 
 
	command_code: INTEGER 
 
	command_name: STRING 

	pretty_command: STRING 
 
feature -- Exception handling 
 
	raise(msg: STRING) 
		do 
			original_msg.copy(msg) 
			Precursor(original_msg) 
		end 
 
feature {} -- Constants

		eq_comp: INTEGER = 1
		ne_comp: INTEGER = 2
		lt_comp: INTEGER = 3
		gt_comp: INTEGER = 4
		le_comp: INTEGER = 5
		ge_comp: INTEGER = 6

feature {} -- Constants 
 
	eif_buffer: detachable STRING 
			-- Buffer for lexical tokens 
 
	Init_buffer_size: INTEGER = 256 
				-- Initial size for `eif_buffer' 

feature {} -- Implementation 

	last_key: like no_command 
 
	no_command: detachable TUPLE[code: INTEGER; name: STRING; help_arg, help_line: detachable STRING] 
 
	keyword(str: STRING; words: like commands; category: STRING): like no_command 
		require 
			str_not_empty: not str.is_empty 
		local 
			cmd: like no_command 
			i, n: INTEGER 
			ok: BOOLEAN 
		do 
			str.to_lower 
			from n := words.count 
			until attached Result or else i = n loop 
				i := i + 1 
				cmd := words[i] 
				if attached cmd.name as w and then w.starts_with(str) then 
					Result := cmd 
				end 
			end 
			if attached Result as r then 
				pretty_command.append(r.name) 
				pretty_command.extend(' ') 
			else 
				msg_.copy(once "One of ") 
				msg_.append(category) 
				msg_.extend('s') 
				msg_.extend(' ') 
				from i := 0 
				until ok or i = n loop 
					if i > 0 then 
						msg_.extend(',') 
					end 
					msg_.extend(' ') 
					i := i + 1 
					cmd := words[i] 
					if attached cmd.name as w then 
						if msg_.count > 52 then 
							msg_.append(once "...") 
					 		ok := True 
						else 
							msg_.extend('`') 
							msg_.append(w) 
							msg_.extend('%'') --' 
						end 
					end 
				end 
				msg_.append(once " expected.") 
				raise(msg_) 
			end 
		ensure 
			valid: attached Result as r implies words.has(r) 
		end 

	original_msg: STRING = "................................................." 
	msg_: STRING 
 
invariant 
 
	eif_buffer_not_void: attached eif_buffer 
 
note 
	license: "MIT License" 
	date: "$Data$" 
	revision: "$Revision$" 
	compilation: "gelex -o pc_tool_scanner.e pc_tool_scanner.l" 
 
end 
