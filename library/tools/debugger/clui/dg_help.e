note

	description: "Help information of the debugger."

class DG_HELP

inherit

	DG_GLOBALS
		redefine
			default_create
		end

create

	default_create

feature {NONE} -- Initialization 

	default_create
		do
			create menu_items.make_empty
			if attached help_data.more as more then
				more.force (help_assign, more.upper + 1)
			end
		end

feature -- Basic operation 

	help
		local
			retried: BOOLEAN
		do
			if not retried then
				next_help (help_intro)
			end
		rescue
			retried := True
			ui_file.put_line (empty)
			retry
		end

	next_help (text: DG_HELP_TEXT)
		local
			ready, found: BOOLEAN
			i, j: INTEGER
			c, def: CHARACTER
		do
			from
			until ready loop
				text.display
				menu_items.make_empty
				i := 0
				if attached text.more as m then
					from
						j := m.lower
					until j > m.upper loop
						if attached m [j] as mj then
							i := i + 1
							menu_items.force (mj.topic, i)
							if def = '%U' then
								def := mj.topic [1]
							end
						end
						j := j + 1
					end
				end
				i := i + 1
				menu_items.force (go_back, i)
				if def = '%U' then
					def := '^'
				end
				i := i + 1
				menu_items.force (exit, i)
				if def = '%U' then
					def := '-'
				end
				c := ui_file.menu (prompt, menu_items, def)
				if c = '-' then
					raise (exit)
				elseif c = '^' then
					ready := True
				elseif attached text.more as more then
					from
						found := False
						j := more.lower
					until found or else j > more.upper loop
						if attached more [j] as mj and then mj.topic [1] = c then
							next_help (mj)
							def := '^'
							found := True
						end
						j := j + 1
					end
				end
			end
		end

feature -- Help texts 

	help_intro: DG_HELP_TEXT
		once
			create Result.make ("intro", "help itself", "[ 
The help information is split into many pages. 
Each page offers a menu asking how to proceed: 
- switch to a related page (if any) 
- go back to the previous page: choice "^" 
- leave help: choice "--". 
 
For example, the related pages of this page are 
  commands  for help on debugger commands 
  repeat    for help on command repetition 
  names     for help on naming conventions. 
 
  Only the first character of the answer is checked for matching 
  a menu entry. Further, the menu offers a default answer enclosed 
  in brackets (here, [c]). 
]", Void, <<help_commands, help_names, help_repeat>>)
		end

	help_commands: DG_HELP_TEXT
		local
			text: STRING
			next: ARRAY [DG_HELP_TEXT]
		once
			text := "[ 
The post mortem analyser provides commands for the following topics: 
 
]"
			if not pma then
				text.append ("[			 
 - running the program in a stop-and-go manner 
 - defining and manipulating breakpoints 
 
]")
				next := <<help_run, help_break, help_stack, help_data, help_list, help_misc>>
			else
				next := <<help_stack, help_data, help_list, help_misc>>
			end
			text.append ("[ 
 - moving up and down the call stack 
 - displaying data 
 - listing source code. 
 
Commands start with a keyword denoting the command, 
then possibly followed by more ore less sophisticated 
parameters. Command names and the possible parameters are described 
under the corresponding help subtopics. The command descriptions 
use a Backus-Naur form analogously to the one used in ETL. 
]")
			create Result.make ("commands", "commands", text, Void, next)
		end

	help_repeat: DG_HELP_TEXT
		once
			create Result.make_leave ("repeat", "command repetition", "[ 
Entering an empty command line repeats, in general, the previous command. 
This rule is often modified, e.g. if an error occurred or if precise 
repetition does not make sense. The modification may affect 
the command parameters (possibly dropping the parameters at all) 
or may be a related command. For example, if the command is unknown 
then the command "repetition" is the "?" command. 
The command descriptions contain a hint on the actual repetition mode. 
]", Void)
		end

	help_names: DG_HELP_TEXT
		once
			create Result.make_leave ("naming", "naming conventions", "[ 
Command names may be abbreviated. If so then the first command 
(according to the ordering shown by command "?") 
that starts with the abbreviation is selected. Moreover, some commands 
include specific keywords within parameter specifications. 
They serve mainly as separators to minimise conflicts with other 
command parts. Some keywords are also keywords of Eiffel. The meaning of 
those keywords has nothing to do with their meaning in Eiffel class texts. 
The parameter keywords (except those which are also Eiffel keywords) 
may be abbreviated, too. 
 
The class, type, and feature names occurring in command parameters 
may be rather long and typing them may become error prone. 
To ease the typing effort a bit, those names may be abbreviated 
to as many characters as necessary to make the name unique. 
Thereby, the letter case is ignored. Alternatively, the type's 
internal number may be used in place of TYPE_NAME parameters 
(the internal number is available by command "universe"). 
Further, a TYPE_NAME may be specified as "like" EXPRESSION 
where the EXPRESSION is evaluated and its dynamic type yields the TYPE_NAME. 
Finally, in case of a generic type the naming rules apply 
to its base class name as well as to all generic parameters.								 
]", Void)
		end

	help_stack: DG_HELP_TEXT
		once
			create Result.make_leave ("stack", "managing the call stack", "[ 
Command "where"  displays the call stack, one line per stack frame 
using the format 
  indicators frame_level CLASS_NAME.feature_name:line 
 
The frame_level starts with 0 for the innermost called routine. 
The indicators may be the following characters: 
  *  indicates the actually selected stack frame 
  -  indicates a stack frame whose routine has been compiled 
     whithout any stack information 
  >  indicates a stack frame whose routine has a rescue clause. 
 
The following commands select a stack frame at a certain level. 
  "up" [n]    Go n levels up (to higher level numbers), default: n=1. 
  "down" [n]  Go n levels down (to lower level numbers), default: n=1. 
  "." [n]     Go to level n, default: the actually chosen level. 
 
These commands display the source code around the program point of 
the new frame level and the value of `Current' at that level. 
]", "the same command without paramters")
		end

	help_data: DG_HELP_TEXT
		once
			create Result.make ("data", "displaying data, type info etc.", "[ 
The following commands commands display 
  "print [x]"    displays contents of data "x"; 
  "closure [x]"  displays persistence closure of expression "x"; 
  "globals"      displays contents of global data like once functions; 
  "queries [T]"  dispalys list of known queries in type "T"; 
  "universe"     displays a list of known classes and types; 
]", Void, <<help_print, help_closure, help_global, help_type>>)
		end

	help_global: DG_HELP_TEXT
		once
			create Result.make_leave ("global", "displaying global data", "[ 
"globals" Lists all once routines where not yet initialized ones 
          are indicated by a leading comment "--". 
          In case of once functions also the values are displayed. 
]", Void)
		end

	help_print: DG_HELP_TEXT
		once
			create Result.make ("print", "displaying data", "[ 
The values of variables and expressions built of them can be 
computed an displayed by command 
  "print" ["/"FORMAT] [DETAILED_EXPR {"," ...}] 
 
If the DETAILED_EXPR parameter is not specified then the command displays 
the values of `Current', the arguments, and local variables 
of the routine at the execution point. 
 
The FORMAT may be a non-empty sequence of characters "g", "x", "a". 
If applicable then any item to be displayed is formatted as follows: 
"g" : the item is treated as global data; 
"x" : the value is displayed in hexadecimal form of an INTEGER_*, NATURAL_*, 
      CHARACTER_* item; 
"a" : the address of a non-void reference item is displayed additionally;
"n" : entries of a SPECIAL object are displayed only if of non-default value;
"l" : long output of STRING_*s: all characters are displayed, otherwise,
	    output is cut before the first newline character or after 48 characters.
]", "same command with the parameters corrected if necessary", <<help_single, help_global>>)
		end

	help_single: DG_HELP_TEXT
		once
			create Result.make ("expression", "expressions", "[ 
An EXPRESSION is like an Eiffel expression: a multi-dot expression 
like "x.y.z" or composed of calls to infix and prefix functions with 
target argument a multi-dot expression. The multi-dot expressions may 
include function calls (the arguments are, recursively, expressions as well) 
and the first item may be one of 
 - a query of the current class provided that C code has been generated; 
 - an argument or local variable of the actual routine; 
 - a manifest of BOOLEAN, INTEGER, REAL_64, CHARACTER, STRING; 
 - the predefined entities `Current', `Result', `Void', `True', `False'; 
 - constant definition or an already initialized once function 
   written as "{CLASS_NAME}.feature_name"; 
 - an alias name or the ident within an object's persistence closure; 
 - in specific contexts: a question mark "?" or a colon ":". 
Each of the following items has to be a query in the dynamic type 
of its left neighbour. If the left neighbour is of a TUPLE type 
then its fields are `item_1', `item_2' etc. 
 
In general, the evaluation starts at `Current' of the shown stack level 
but it is also possible to start at a stack level above. 
To this end, the first item of a multi-dot expression is to be preceded 
by one or more "^" characters (or by "^"n"^" meaning n "^" characters): 
the evaluation starts n stack levels above the shown one. 
]", Void, <<help_multi, help_special, help_create, help_alias>>)
		end

	help_create: DG_HELP_TEXT
		once
			create Result.make_leave ("create", "object creation", "[ 
New objects can be created within an expression: to this end, 
the first item of a multi-dot expression is to be specified as 
 
  "!" TYPE_NAME [ ":" feature_name [ "("args")" ] ] "!" 
 
where feature_name denotes a creation procedure TYPE_NAME. 
If feature_name is missing then the type's version of `default_create' 
is used, provided that this is a creation procedure. 
]", Void)
		end

	help_multi: DG_HELP_TEXT
		once
			create Result.make ("multi", "multiple expressions", "[ 
EXPRESSION_LIST := { DETAILED_EXPR} "," }+ 
DETAILED_EXPR   := EXPRESSION [ "[[" INDEX_RANGE "]]" ] [DETAILS ] 
DETAILS         := "{{" EXPRESSION_LIST "}}" 
                 | "{{" "all" [n] "}}" 
 
The expressions within the double braces of DETAILS may start 
(besides the start item of arbitrary EXPRESSIONs) with one or more 
placeholders "?" referring to the value of the EXPRESSION in front 
of the braces (if just one "?") or in front of the p-th nested braces 
(if p placeholders "?"). 
The last variant selects all attributes, attributes of attributes, ... 
up to depth "n" of the EXPRESSION (default: n=1; n=0 means no attributes). 
In contrast to EXPRESSIONs, DETAILED_EXPRs may not be further referenced. 
 
The "print" command adds "{{all 1}}" if details are not specified. 
]", Void, <<help_special>>)
		end

	help_special: DG_HELP_TEXT
		once
			create Result.make_leave ("special", "displaying SPECIAL objects", "[ 
Single items of a SPECIAL object are accessible in C like notation: 
appending the index (once again a EXPRESSION) in double brackets. 
The result is a EXPRESSION and may be further referenced. 
 
Multiple array items may be selected by specifying an INDEX_RANGE 
by one of the following within double brackets: 
 - two comma separated limit indices: select the closed interval 
 - keyword "all": select all items 
 - keyword "if" followed by a boolean EXPRESSION: 
   select the items satisfying this EXPRESSION where the running array item 
   and index are referred to by "?" and ":", respecively. 
Each of these notations defines a DETAILED_EXPR that cannot 
be further referenced, but details in braces may be added. 
 
Example: If query `table' is of a HASH_TABLE type then command 
 
  print table.keys [[if ? /= Void]] {{ table.content(?) }} 
 
displays key/item pairs of all elements of `table'. 
]", Void)
		end

	help_alias: DG_HELP_TEXT
		once
			create Result.make_leave ("alias", "alias names", "[ 
To ease the repeated typing of the same complicated expression, commands 
  "_" name ":=" EXPRESSION 
  "_" name "->" DETAILED_EXPR 
  "info alias" 
define the alias name "name" (this may be any valid Eiffel identifier) 
or display all defined alias names and their definitions, respectively. 
 
Within the DETAILED_EXPR to be composed the alias name is replaced 
by its value (in case of ":=") or by a copy of its defining DETAILED_EXPR 
(in case of "->"). The resulting DETAILED_EXPR is in fact an EXPRESSION 
if the defining DETAILED_EXPR does not contain an INDEX_RANGE. 
In this case it may be further referenced. 
]", "info alias")
		end

	help_closure: DG_HELP_TEXT
		once
			create Result.make_leave ("closure", "displaying the persistence closure", "[ 
Command 
  "closure" ["/"FORMAT] 
displays the persistence closure of the resulting object of an expression 
Touched reference objects are numbered consecutively. 
The number is displayed with a leading tilde when it is defined 
and when it is referred to, e.g. 
   _123 : SOME_CLASS 
      some_attribute = _45 
 
Formats "x" and "a" have the same meaning as for the "print" command and 
format "d" forces deep nesting of output instead of the default flat output. 
Command
  "verbose" ["/t"] ident
displays the multi-dot name of object "ident" within the corresponding
closure's top level object, type names are added if format "t" is specified. 
	
The numbers are accumulated in each interactive round of the debugger 
and they are cancelled by each dynamic command (i.e. "cont" etc.); 
they may  also be cancelled by command 
  "closure --" 
During its life time such a number may be the first item of EXPRESSIONs. 
]", Void)
		end

	help_type: DG_HELP_TEXT
		once
			create Result.make_leave ("type", "type description: ", "[ 
Command "queries" [TYPE_NAME ] displays a list of the attributes 
and functions of type TYPE_NAME which may be used to build expressions. 
If no parameter is given then the type of `Current' at the actual program 
point is used. In this case, also the arguments and local variables 
of the current routine are listed. 
 
Command "universe [r]" displays an overview of the types and classes 
whose names match the regular expression "r" (default: all types and classes) 
and which may be used as TYPE_NAME or CLASS_NAME in commands. 
Each row shows the internal type or class number, possibly some 
indicators, and the type resp. class name. The indicators are: 
  C : class is a valid CLASS_NAME 
  T : type is a valid TYPE_NAME 
  d : class is deferred 
  x : type or class is expanded 
  b : type or class is basic expanded 
  c : reference type has `default_create' as creation procedure 
]", "command %"universe%"")
		end

	help_definition: DG_HELP_TEXT
		once
			create Result.make_leave ("feature", "displaying defintion of a feature", "[ 
A variant of displaying a feature text is command 
  "def" POSITION
\end{description}
where POSITION must denote a position within a routine body. 
The declared type of the expression (feature or local variable) 
at this position is evaluated and the feature definition in the 
corresponding class text is displayed.
]", "command %"list%"")
		end

	help_list: DG_HELP_TEXT
		once
			create Result.make ("listing", "displaying source code", "[ 
Source files (or parts thereof) can be listed by command 
  "list" LINE_RANGE 
 
Each line listed is preceded by the line number and zero ore more 
of the following indicators: 
  +  a breakpoint has been set at this line 
  |  a tracepoint but no breakpoint has been set at this line 
Additionally, if the line is the stop point of the actual stack level 
then the actual position is marked by a circumflex in the next printed line. 

A LINE_RANGE is always implicitly defined when the program point 
of a certain stack level is displayed, in particular after entering 
the interactive phase of the debugger. This line range establishes 
the default values for forthcoming LINE_RANGE specifications. 
]", "Repetition: same command without parameter.", <<help_line_range, help_search>>)
		end

	help_line_range: DG_HELP_TEXT
		once
			create Result.make ("line_range", "specifying a position or a line range", "[ 
A POSITION is to be specified as 
  [CLASS_NAME] ":" first_line_no ["`" column_no]
A LINE_RANGE of a class text may be specified explicitly by one of 
  [CLASS_NAME] [":" first_line_no] ["`" line_count] 
  [CLASS_NAME] [":" first_line_no] ["," last_line_no] 
  [CLASS_NAME] "." feature_name 
  "like" EXPRESSION 
  "-" [line_offset] ["`" line_count] 
The first two variants of a line range select the specified range of lines. 
The third variant selects all lines of the feature's definition.  
The last variant defines a relative LINE_RANGE. 
The following default rules apply: 
 - if CLASS_NAME is absent then the CLASS_NAME of the most recently 
   listed class is selected 
 - if the first_line_no is absent then it is set to the most recently 
   listed line number + 1 (or to 1 if end of file had been reached) 
 - if line_count is absent then its setting depends on the command: 
   1 when defining a breakpoint and 
 - if column_no is absent then it is set to 1.
]", Void, <<help_relative, help_definition, help_single>>)
		end

	help_relative: DG_HELP_TEXT
		once
			create Result.make_leave ("relative", "relative line range", "[ 
A line range of the form 
  "-" [line_offset] ["`" line_count] 
is relative to the program point of the actual stack level. 
As indicated by the minus sign, the line_offset is taken negative. 
The default = 0, i.e. the line range starts at the program point. 
The default of line_count is the modulus of line_offset plus 1, 
i.e. the default line range ends at the program point. 
 
After specification, the relative line range is replaced internally 
by the corresponding absolute line range. This is then also 
the default for forthcoming line range specifications. 
]", Void)
		end

	help_search: DG_HELP_TEXT
		once
			create Result.make_leave ("search", "searching strings in source code", "[ 
Commands 
  "/"REGEXP 
  "/" 
search a string matching the regular expression REGEXP (if specified) or 
the REGEXP of the previous "/" command (if not specified) in source code. 
 
The REGEXP may be constructed like a basic regular expression 
in the sense of the GEDB library class RX_REGULAR_EXPRESSION. 
The source code to be searched is related to the "list" command: 
the search starts at the line that would be displayed first by an 
argumentless "list" command. If a match is found then the corresponding 
line is displayed, and the default line range for the forthcoming "list" 
(consequently, also for the "/") commands gets adjusted to the next line. 
 
Warning: All characters (in particular, white space) following 
the command key "/" contribute to the REGEXP. 
]", "command %"/%" without parameter")
		end

	help_assign: DG_HELP_TEXT
		once
			create Result.make_leave ("assign", "assignment", "[ 
Command 
  "_" TARGET ":=" SOURCE 
(where TARGET and SOURCE are EXPRESSIONs) assigns the value of SOURCE 
to TARGET. TARGET may be an attribute in some class, a field of an SPECIAL 
object, or a local variable in the actual stack frame. 
SOURCE may any expression whose type belongs to the typeset of TARGET. 
 
Command 
  "typeset" EXPRESSSION 
displays the possible source types of EXPRESSION when used 
as assignment target. 
]", "command %"print%" TARGET")
		end

	help_run: DG_HELP_TEXT
		once
			create Result.make ("run", "running the system", "[ 
The system can be run in a stop-and-go manner by the following commands: 
 
  "cont" [mode] [n]  n-times continue the execution to the next breakpoint 
  "next" [mode] [n]  execute next n instructions, do not step into routines 
  "step" [mode] [n]  execute next n instructions, step into called routines 
  "finish" [mode]    return from called routines until the selected stack leval. 
  "end" [mode]       Continue to the "end" keyword of routine at selected stack level. 
  "off" [mode] [n]   Executes the system until n nested loops are completed. 
The default value of "n" = 0 in case of "end" and 1 otherwise. 
Commands "finish" and "end" allow also for parameter ".": 
all routines are finished until the actually shown stack level is reached. 
 
Parameter "mode" is one of the keywords "break" (default), "trace" or "silent". 
If "mode" equals "break" then these commands check for breakpoints 
and tracepoints on the way: print a message if a tracepoint is passed, 
stop (in case of "next", "step", "finish") if a breakpoint has been reached, 
or stop after the n-th breakpoint (in case of "cont"). 
If "mode" equals "trace" then breakpoints are treated as tracepoints, 
and if "mode" equals "silent" then breakpoints and tracepoints are ignored. 
]", "the same command without parameters", <<help_mark>>)
		end

	help_mark: DG_HELP_TEXT
		once
			create Result.make_leave ("mark", "mark and reset", "[ 
The system state at interesting points can be saved. 
"mark"      Saves the system state and marks the program point to be 
            recovered. The program point is available for reset 
            as long as the current routine has not been left to its caller. 
"reset" m   Restores the marked system no. "m" 
            and resets the program point. 
"info mark" Displays all marked program points. 
 
Warnings: 
- Non-Eiffel data, e.g. file contents, are not saved/restored. 
  This may cause the system state to be incorrect after "reset". 
- Debugger settings such as breakpoint definitions are not saved/restored. 
- The system state is written to a binary file 
  This file should not be viewed or printed and must not be modified. 
]", "command %"info mark%"")
		end

	help_go: DG_HELP_TEXT
		once
			create Result.make_leave ("go", "system exectution", "[ 
 
 
]", Void)
		end

	help_break: DG_HELP_TEXT
		once
			create Result.make ("break", "managing breakpoints", "[ 
Breakpoints are defined by command 
  "break" [n] [CONDITION] [ACTION] 
 
The command creates a new breakpoint if "n" is not specified or edits 
the existing breakpoint no. "n". CONDITION and ACTION may themselves consist 
of several parts. 
 
The following commands manipulate breakpoints: 
  "info break" show the definition of all breakpoints 
  "+" bl       enable breakpoint in list "bl" 
  "-" bl       disable breakpoint in list "bl" 
  "kill" bl    delete breakpoint in list "bl" 
Parameter "bl" is a comma separated list of existing breakpoint numbers 
or it may be the keyword  "all". 
]", "command %"info break%"", <<help_conditions, help_actions>>)
		end

	help_conditions: DG_HELP_TEXT
		once
			create Result.make ("conditions", "break conditions", "[ 
The matching conditions for a breakpoint match are specified by 
the parameters 
 
   ["catch" x] ["at" p] ["depth" d ["++"]] ["watch" e] ["type" T] ["if" b] 
 
where "x" is a keyword, "p" is a position, "d" is an integer, 
"e" is an expression, "T" is a TYPE_NAME, and "b" is a boolean expression. 
These parameters must be specified in the order  given.							 
 
The breakpoint matches if the conjunction (in the sense of `and then') 
of all conditions evaluates to `True' (where not specified conditions 
are considered `True'). 
]", Void, <<help_catch, help_at_stack_watch, help_type_if>>)
		end

	help_catch: DG_HELP_TEXT
		once
			create Result.make_leave ("catch", "catching exceptions", "[ 
The condition is satisfied if an exception of kind "x" (see below) occurs 
that will be rescued in the line range given by "at l". More precisely: 
- if the range is not specified then all rescue clauses of all classes match; 
- if a CLASS_NAME is specified but no feature_name 
  then all rescue clauses of this class match; 
- if (a CLASS\_NAME and) a feature_name is specified 
  then only the rescue clause of this feature matches; 
- if first_line_no or line_count are given then they will be ignored. 
 
  Keyword "x" | Meaning 
  ------------------------------------- 
  void        | call on void target 
  memory      | no more memory 
  failure     | routine failure 
  when        | incorrect inspect value
  signal      | OS signal other than interrupt
  catcall     | CAT-call 
  developer   | call to routine `raise' 
  all         | all exceptions 
																											 
If the breakpoint matches then the debugger will be invoked before the 
call stack gets unwound, i.e. at the place where the exception occurred. 
Moreover, all breakpoint parameters except "at" refer to this program point. 
]", Void)
		end

	help_type_if: DG_HELP_TEXT
		once
			create Result.make ("type_if", "conformance condition", "[ 
The parameter "T" of the "type" condition may be a TYPE_NAME 
The condition is satified if the dynamic type of `Current' conforms to "T". 
 
The "if" part specifies a boolean expression that is evaluated at the 
breakpoints (with `Current' at the breakpoint to start the evaluation). 
Not surprising, the condition becomes true if the expression is `True'. 
Moreover, the debugger is invoked if the condition has errors 
or does not result in a BOOLEAN value. 
 
Hint: The "type" part may be used to ensure that the "if" expression 
is defined for `Current' at the breakpoint. 
]", Void, <<help_type, help_single>>)
		end

	help_actions: DG_HELP_TEXT
		once
			create Result.make ("actions", "breakpoint action", "[ 
When a breakpoint matches then its associated actions will be performed. 
The actions include displaying a message consisting 
of the breakpoint number and, possibly, much more. 
 
Other behaviour can be set in the "break" command: 
 
  ["print" e] ["cont"] 
 
where "e" is an EXPRESSION-LIST. These parameters must be specified 
in the given order and order and must follow the CONDITIONS. 
 
If "print e" is specified then the message includes the values 
of "e" evaluated at the matching point. 
 
If "cont" is specified then the program does not stop if the breakpoint 
matches. This means the breakpoint is turned into a tracepoint. 
]", Void, <<help_data>>)
		end

	help_at_stack_watch: DG_HELP_TEXT
		once
			create Result.make ("at_depth_watch", "line range, stack depth, and watch", "[ 
The line range "l" specifies a part of a class text. 
It is to be written just like the line range of the "list" command. 
If "catch" is not specified then the condition is satisfied 
if the program performs an instruction within the line range. 
 
The stack depth condition is satisfied if the depth of the call stack 
is ar least "d". If the break point matches (i.e. all conditions 
are satisfied ) and if "++" is set then "d" is set to the actual stack 
depth plus one. 
 
The watch expression "e" specifies a memory address to be watched 
for changes of its contents. The expression is evaluated just 
after definition of the breakpoint, and its address and value 
are stored for forthcoming comparisons. The contents of that memory 
location is then compared during program run with the stored value. 
The condition is satisfied if the value has changed. 
The value will be replaced by the new one if the breakpoint matches 
(i.e. if all break conditions are also true). 
Restriction: The expression must result in the attribute of some class 
and it must be of reference type or of a basic expanded type. 
]", Void, <<help_line_range, help_single>>)
		end

	help_misc: DG_HELP_TEXT
		local
			text: STRING
		once
			text := "[ 
"?"        Displays a compact description of all commands. 
 
"info" s   Displays and manipulates debugger status where "s" may be 
           one of the keywords "system", "alias", "break", "match". 
 
">" [file] Stores the alias names of the "->" form as well as 
           breakpoint and tracepoint definitions to file "file" 
           for use in later system runs. 
"<" [file] Restores alias names and breakpoint definitions 
           from file "file". The alias names and breakpoints get added 
           to the list of already existing alias names and breakpoints. 
           The default of the filename "f" is the name of the running system 
           with extension ".dg". 
 
															 ]"
			if pma then
				text.append ("[ 
 
"go"       Continues system execution after interrupt. 
 
]")
			end
			text.append ("[ 
	 
"quit"     Quits the program. 
]")
			create Result.make_leave ("misc", "miscellanous commands", text, Void)
		end

feature {NONE} -- Implementation
	
	go_back: STRING = "^"

	exit: STRING = "--"

	prompt: STRING = "%NMore help"

	empty: STRING = ""

	menu_items: ARRAY [STRING]

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
