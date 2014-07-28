%{
note

	description:

		"Scanners for Eiffel parsers %
                %Extract from class ET_EIFFEL_SCANNER:%
		%multi line strings and most keywords have been dropped."

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
		export {NONE} all end

	DG_GLOBALS

%}

CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))

%x IS_STR
%x PARAM
%x BREAK

%option nodefault line outfile="dg_scanner.e"

%%

----------/** Separators **/-------------------------------------------------
<INITIAL,PARAM,BREAK> {

[ \t\r]+			-- Ignore separators
"..."\n				-- Line continuation
\n				terminate


} -- <INITIAL,PARAM,BREAK> 

----------/** Eiffel symbols **/---------------------------------------------

<PARAM> {
[-+*/^=~><$]		{
				process_one_char_symbol (text_item (1))
			}
("//"|"\\\\"|"/="|"/~"|">="|"<="|"..")	{
				process_two_char_symbol (text_item (1), text_item (2))
			}

----------/** More symbols **/-----------------------------------------------

[Cc][Aa][Tt][Cc][Hh]	last_token := CATCH_CODE
[Aa][Tt]		last_token := LINE_CODE
[Dd][Ee][Pp][Tt][Hh]	last_token := DEPTH_CODE
[Ww][Aa][Tt][Cc][Hh]	last_token := WATCH_CODE
[Tt][Yy][Pp][EE]	last_token := TYPE_CODE
[Pp][Rr][In][Nn][Tt]	last_token := PRINT_CODE
[Cc][Oo][Nn][Tt]	last_token := CONT_CODE

":="			last_token := DG_ASSIGN
"--"			last_token := DG_COMMENT
"++"			last_token := DG_PP
"->"			last_token := DG_ARROW
"[["			last_token := DG_LBB
"{{"			last_token := DG_LCC
"}}"			last_token := DG_RCC

(%|\?)\?*		{	-- |
				last_token := DG_PLACEHOLDER
				last_string_value := text
			}
"/"[a-z]+		{	
				last_token := DG_FORMAT
				last_string_value := text
			}

----------/** Reserved words **/---------------------------------------------

[Ff][Rr][Oo][Mm]		last_token := E_FROM
[Ww][Hh][Ee][Nn]		last_token := E_WHEN
[Ii][Ff]			last_token := E_IF
[Cc][Ll][Aa][Ss][Ss]		last_token := E_CLASS
[Dd][Oo]			last_token := E_DO
[Ll][Oo][Oo][Pp]		last_token := E_LOOP
[Ll][Ii][Kk][Ee]		last_token := E_LIKE
[Aa][Ll][Ll]			last_token := E_ALL
[Dd][Ee][Bb][Uu][Gg]		last_token := E_DEBUG
[Oo][Ll][Dd]			last_token := E_OLD
[Cc][Rr][Ee][Aa][Tt][EE]	last_token := E_CREATE
[Oo][Nn][Cc][Ee]		last_token := E_ONCE
[Oo][Rr]			last_token := E_OR
[Xx][Oo][Rr]			last_token := E_XOR
[Aa][Nn][Dd]			last_token := E_AND
[Ii][Mm][Pp][Ll][Ii][Ee][Ss]	last_token := E_IMPLIES
[Nn][Oo][Tt]			last_token := E_NOT

----------/** Eiffel identifiers **/-----------------------------------------

[a-zA-Z][a-zA-Z0-9_]*	{
                                last_token := E_IDENTIFIER
                                last_string_value := text
			}
(_[1-9][0-9]*)+[a-zA-Z][a-zA-Z0-9_]*	{
				last_token := DG_INLINE
				last_string_value := text
			}


_[a-zA-Z][a-zA-Z0-9_]*	{
				last_token := DG_ALIAS
				last_string_value := text
			}

_[1-9][0-9]*		{
				last_token := DG_CLOSURE
				last_string_value := text
			}

----------/** Eiffel free operators **/--------------------------------------

"#" |
"#"[-+*] |
"#"[-+*][^a-zA-Z0-9_%" \t\r\n][^%" \t\r\n]* |
"#"[^+\-*%" \t\r\n][^%" \t\r\n]* |
[@|&][^%" \t\r\n]* |
"#"/[ \t\r\n] |
"#"[-+*]/[ \t\r\n] |
"#"[-+*][^a-zA-Z0-9_%" \t\r\n][^%" \t\r\n]*/[ \t\r\n] |
"#"[^+\-*%" \t\r\n][^%" \t\r\n]*/[ \t\r\n] |
[@|&][^%" \t\r\n]*/[ \t\r\n]	{
				last_token := E_FREEOP
                                last_string_value := text
			}

----------/** Eiffel characters **/------------------------------------------

\'[^%\n']\'             last_token := E_CHARACTER; last_character_value := text_item (2)
\'%A\'                  last_token := E_CHARACTER; last_character_value := '%A'
\'%B\'                  last_token := E_CHARACTER; last_character_value := '%B'
\'%C\'                  last_token := E_CHARACTER; last_character_value := '%C'
\'%D\'                  last_token := E_CHARACTER; last_character_value := '%D'
\'%F\'                  last_token := E_CHARACTER; last_character_value := '%F'
\'%H\'                  last_token := E_CHARACTER; last_character_value := '%H'
\'%L\'                  last_token := E_CHARACTER; last_character_value := '%L'
\'%N\'                  last_token := E_CHARACTER; last_character_value := '%N'
\'%Q\'                  last_token := E_CHARACTER; last_character_value := '%Q'
\'%R\'                  last_token := E_CHARACTER; last_character_value := '%R'
\'%S\'                  last_token := E_CHARACTER; last_character_value := '%S'
\'%T\'                  last_token := E_CHARACTER; last_character_value := '%T'
\'%U\'                  last_token := E_CHARACTER; last_character_value := '%U'
\'%V\'                  last_token := E_CHARACTER; last_character_value := '%V'
\'%%\'                  last_token := E_CHARACTER; last_character_value := '%%'
\'%\'\'                 last_token := E_CHARACTER; last_character_value := '%''
\'%\"\'                 last_token := E_CHARACTER; last_character_value := '%"'
\'%\(\'                 last_token := E_CHARACTER; last_character_value := '%('
\'%\)\'                 last_token := E_CHARACTER; last_character_value := '%)'
\'%<\'                  last_token := E_CHARACTER; last_character_value := '%<'
\'%>\'                  last_token := E_CHARACTER; last_character_value := '%>'
\'%\/[0-9]+\/\'         {
                                code_ := text_substring (4, text_count - 2).to_integer
                                if code_ > Platform.Maximum_character_code then
                                        last_token := E_CHARERR
                                else
                                        last_token := E_CHARACTER
                                        last_character_value := INTEGER_.to_character (code_)
                                end
                        }
\"[^%\n"]*\"            {
                                last_token := E_STRING
                                last_string_value := text_substring (2, text_count - 1)
                        }
\"[^%\n"]*      {
                                if text_count > 1 then
                                        eif_buffer.append_string (text_substring (2, text_count))
                                end
                                set_start_condition (IS_STR)
                        }

----------/** Eiffel bits **/------------------------------------------------

[0-1]+[bB]/([ \t\r\n]|"--")	{
                                last_token := E_INTEGER
                                last_integer_value := text.to_integer
			}


----------/** Eiffel integers **/--------------------------------------------

[0-9]+                  {
                                last_token := E_INTEGER
                                last_integer_value := text.to_integer
                        }
[0-9]{1,3}(_[0-9]{3})+  {
                                last_token := E_INTEGER
                                str_ := text
                                nb_ := text_count
                                from 
					i_ := 1 
				until i_ > nb_ loop
                                        char_ := str_[i_]
                                        if char_ /= '_' then
                                                eif_buffer.append_character (char_)
                                        end
                                        i_ := i_ + 1
                                end
                                last_integer_value := eif_buffer.to_integer
                                        eif_buffer.wipe_out
                        }
0[xX][0-9a-fA-F]+       {
                                last_token := E_INTEGER
                                last_integer_value := text.to_integer
                        }
[0-9_]+                 last_token := E_INTERR  -- Catch-all rule (no backing up)

---------/** Eiffel reals **/------------------------------------------------

[0-9]+\.$                               |
[0-9]+\./[^.0-9]                        |
[0-9]+\.[0-9]*[eE][+-]?[0-9]+           |
[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?        {
                                                last_token := E_REAL
                                                last_double_value := text.to_double
                                        }
[0-9]{1,3}(_[0-9]{3})+\.$               |
[0-9]{1,3}(_[0-9]{3})+\./[^.0-9]        |
[0-9]{1,3}(_[0-9]{3})*\.([0-9]{1,3}(_[0-9]{3})*)?[eE][+-]?[0-9]{1,3}(_[0-9]{3})*        |
([0-9]{1,3}(_[0-9]{3})*)?\.[0-9]{1,3}(_[0-9]{3})*([eE][+-]?[0-9]{1,3}(_[0-9]{3})*)?     {
                                                last_token := E_REAL
                                                str_ := text
                                                nb_ := text_count
                                                from 
							i_ := 1 
						until i_ > nb_ loop                                                        char_ := str_[i_]
                                                        if char_ /= '_' then
                                                                eif_buffer.append_character (char_)
                                                        end
                                                        i_ := i_ + 1
                                                end
                                                last_double_value := eif_buffer.to_double
                                                eif_buffer.wipe_out
                                        }

----------/** Debugger symbols **/-------------------------------------------

\^{2,}			{
				last_token := DG_UP_FRAME
				last_integer_value := text_count
			}
\^[1-9][0-9]*\^		{
				last_token := DG_UP_FRAME
				tmp_str.copy(text)
				tmp_str.remove(1)
				tmp_str.remove(tmp_str.count)
				last_integer_value := tmp_str.to_integer
			}
.			last_token := text_item (1).code
} -- <PARAM>

----------/** Eiffel strings **/---------------------------------------------

<IS_STR>[^%\n"]+	eif_buffer.append_string (text)
<IS_STR>%A		eif_buffer.append_character ('%A')
<IS_STR>%B		eif_buffer.append_character ('%B')
<IS_STR>%C		eif_buffer.append_character ('%C')
<IS_STR>%D		eif_buffer.append_character ('%D')
<IS_STR>%F		eif_buffer.append_character ('%F')
<IS_STR>%H		eif_buffer.append_character ('%H')
<IS_STR>%L		eif_buffer.append_character ('%L')
<IS_STR>%N		eif_buffer.append_character ('%N')
<IS_STR>%Q		eif_buffer.append_character ('%Q')
<IS_STR>%R		eif_buffer.append_character ('%R')
<IS_STR>%S		eif_buffer.append_character ('%S')
<IS_STR>%T		eif_buffer.append_character ('%T')
<IS_STR>%U		eif_buffer.append_character ('%U')
<IS_STR>%V		eif_buffer.append_character ('%V')
<IS_STR>%%		eif_buffer.append_character ('%%')
<IS_STR>%\'		eif_buffer.append_character ('%'')
<IS_STR>%\"		eif_buffer.append_character ('%"')
<IS_STR>%\(		eif_buffer.append_character ('%(')
<IS_STR>%\)		eif_buffer.append_character ('%)')
<IS_STR>%<		eif_buffer.append_character ('%<')
<IS_STR>%>		eif_buffer.append_character ('%>')
<IS_STR>%\/[0-9]+\/	{
				code_ := text_substring (3, text_count - 1).to_integer
				if (code_ > Platform.Maximum_character_code) then
					last_token := E_STRERR
				else
					eif_buffer.append_character (INTEGER_.to_character (code_))
				end
			}
<IS_STR>.|\n			|
<IS_STR>%\/([0-9]+(\/)?)?	|
<IS_STR><<EOF>>			{	-- Catch-all rules (no backing up)
						last_token := E_STRERR
						set_start_condition (INITIAL)
				}

----------/** Debugger commands **/------------------------------------------

<INITIAL> {
[A-Za-z]+|"."|"_"|"/"|"^"|"<"|">"|"+"|"-"|"?"|"%"|"@"	{ 
		 	if attached keyword(text, commands, once "command") as lk then
				last_key := lk
				command_name := lk.name
				command_code := lk.code
				last_token := command_code
			end
			inspect command_code
			when BREAK_CODE then
				set_start_condition(BREAK)
			else
				set_start_condition(PARAM)
			end
		}
.		{
			last_token := NO_CODE
			command_code := last_token
		}
} -- INITIAL

<BREAK> {
[Aa][Ll][Ll]	last_token := E_ALL
[A-Za-z]+	{ 
		 	if attached keyword(text, breaks, once "keyword") as lk then
				last_key := lk
				last_token := lk.code
				shorten_break_keys(last_token)
			end
			set_start_condition(PARAM)
		}
[1-9][0-9]*	{
			last_token := E_INTEGER
			last_integer_value := text.to_integer
		}

"+"|"-"|","	last_token := text[1].code
"--"		last_token := DG_COMMENT

.|\n		default_action

} -- BREAK

-----------------------------------------------------------------------------

<INITIAL,PARAM><<EOF>>	terminate

-----------------------------------------------------------------------------

%%

feature {NONE} -- Local variables

	i_, nb_: INTEGER
	char_: CHARACTER
	str_: STRING 
	code_: INTEGER
	last_key: like no_command
	idx_, token_: INTEGER

feature {NONE} -- Initialization

	make
			-- Create a new Eiffel scanner.
		do
			make_with_buffer (Empty_buffer)
			create eif_buffer.make (Init_buffer_size)
			create_keyword := True		
			create msg_.make(100)
			create pretty_command.make(100)
			create orig_breaks.make(8)
			create modes.make(3)
			make_tokens
			make_catch_keys
			breaks := orig_breaks.twin
			command_name := "."
			print_format := ""
			str_ := ""
		end

feature -- Initialization

	reset
			-- Reset scanner before scanning next input.
		do
			reset_compressed_scanner_skeleton
			eif_buffer.wipe_out
			command_code := NO_CODE
			msg_.wipe_out
			pretty_command.wipe_out
			breaks.copy(orig_breaks)
		end

feature -- Access

	eif_buffer: STRING
			-- Buffer for lexical tokens

	is_operator: BOOLEAN
			-- Parsing an operator declaration?

	command_code: INTEGER

	command_name: STRING

	pretty_command: STRING

	print_format: STRING 

	modes, breaks, orig_breaks, catch_keys: like commands

feature -- Status report

	create_keyword: BOOLEAN
			-- Should `create' be considered as
			-- a keyword (otherwise identifier)?

feature {NONE} -- Constants

	Init_buffer_size: INTEGER = 256
				-- Initial size for `eif_buffer'

feature {NONE} -- Implementation

	break_mode: INTEGER
	
	keyword(str: STRING; words: like commands; category: STRING): like no_command
		local
			cmd: attached like no_command
			i, n: INTEGER
			ok: BOOLEAN
		do
			str.to_lower
			from 
				n := words.count
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
				from 
					i := 0
				until ok or i = n loop
					if i > 0 then
						msg_.extend(',')
					end
					msg_.extend(' ')
					i := i + 1
					cmd := words[i]
					if attached cmd.name as w then
						if msg_.count > 56 then
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
				message(msg_,column)
			end
		ensure
			valid: attached Result as r words.has(r)
		end

	make_tokens
		once
			orig_breaks.force([CATCH_CODE, "catch", "", ""])
			orig_breaks.force([LINE_CODE, "at", "", ""])
			orig_breaks.force([DEPTH_CODE, "depth", "", ""])
			orig_breaks.force([WATCH_CODE, "watch", "", ""])
			orig_breaks.force([TYPE_CODE, "type", "", ""])
			orig_breaks.force([E_IF, "if", "", ""])
			orig_breaks.force([PRINT_CODE, "print", "", ""])
			orig_breaks.force([CONT_CODE, "cont", "", ""])
			modes.force([BREAK_CODE, "break", "", ""])
			modes.force([TRACE_CODE, "trace", "", ""])
			modes.force([SILENT_CODE, "silent", "", ""])
		end

	make_catch_keys
		do
                        create catch_keys.make(15)
catch_keys.force([Void_call_target, "void", "", "call on void target"])
			catch_keys.force([No_more_memory, "memory", "", "no more memory"])
--                      catch_keys.force([Precondition, "require", "", "violation of precondition"])
--                      catch_keys.force([Postcondition, "ensure", "", "violation of postcondition"])
--                      catch_keys.force([Class_invariant, "invariant", "", "violation of class invariant"])
--                      catch_keys.force([Check_instruction, "check", "", "violation of check instruction"])
                        catch_keys.force([Routine_failure, "failure", "", "routine failure"])
			catch_keys.force([Incorrect_inspect_value, "when", "", "violation of inspect value"])
--                      catch_keys.force([Loop_invariant, "loop", "", "violation of loop invariant or variant"])
--                      catch_keys.force([Signal_exception, "signal", "", "operating system signal"])
			catch_keys.force([Eiffel_runtime_panic, "catcall", "", "catcall"])
			catch_keys.force([Developer_exception, "developer", "", "routine `raise' called"])
			catch_keys.force([32, "all", "", "any exception"])
		end

	shorten_break_keys(code: INTEGER)
		local
			cmd: attached like no_command
			i, n: INTEGER
			found: BOOLEAN
		do
			from 
				n := breaks.count 
			until found or else i = n loop
				i := i + 1
				cmd := breaks[i]
				found := cmd.code = code
			end
			if found then 
				from 
					n := i 
				until n = 0 loop
					breaks.start
					breaks.remove
					n := n - 1
				end
			end
		end

	msg_: STRING 

feature {NONE} -- Processing from ET_EIFFEL_SCANNER_SKELETON

	process_operator (op: INTEGER): INTEGER
			-- Process current token as operator `op' or as
			-- an Eiffel string depending on the context
		require
			text_count_large_enough: text_count > 2
		do
			if is_operator then
				is_operator := False
				Result := op
			else
				Result := E_STRING
				last_string_value := text_substring (2, text_count - 1)
			end
		end

	process_one_char_symbol (c: CHARACTER) 
			-- Process Eiffel symbol with made up of only
			-- one character `c'.
		require
			one_char: text_count >= 1
			-- valid_string: ([-+*/^=~><$]).recognizes (text_substring (1, 1))
			valid_c: text_item (1) = c
		do
			inspect c
			when '-', '+', '*', '/', '^', '=', '~', '>', '<', '$' then
				last_token := c.code
			else
			end
		end

	process_two_char_symbol (c1, c2: CHARACTER)
			-- Process Eiffel symbol with made up of exactly
			-- two characters `c1' and `c2'.
		require
			two_chars: text_count >= 2
			-- valid_string: ("//"|"\\\\"|"/="|"/~"|">="|"<="|"..").recognizes (text_substring (1, 2))
			valid_c1: text_item (1) = c1
			valid_c2: text_item (2) = c2
		do
			inspect c1
			when '/' then
				inspect c2
				when '/' then
					last_token := E_DIV
				when '=' then
					last_token := E_NE
				when '~' then
					last_token := E_NOT_TILDE
				else
				end
			when '\' then
				check valid_symbol: c2 = '\' end
				last_token := E_MOD
			when '>' then
				check valid_symbol: c2 = '=' end
				last_token := E_GE
			when '<' then
				check valid_symbol: c2 = '=' end
				last_token := E_LE
			when '.' then
				check valid_symbol: c2 = '.' end
				last_token := E_DOTDOT
			else
			end
		end


        message(msg: STRING; at: INTEGER)  
                deferred
                end 
 
invariant

note
	date: "$Data$"
	revision: "$Revision$"
	compilation: "gelex -o dg_scanner.e dg_scanner.l"

end
