note

	description: "Parser token codes"
	generator: "geyacc version 3.9"

class DG_TOKENS

inherit

	YY_PARSER_TOKENS

feature -- Last values

	last_any_value: ANY
	last_integer_value: INTEGER
	last_string_value: STRING
	last_character_value: CHARACTER
	last_double_value: DOUBLE

feature -- Access

	token_name (a_token: INTEGER): STRING
			-- Name of token `a_token'
		do
			inspect a_token
			when 0 then
				Result := "EOF token"
			when -1 then
				Result := "Error token"
			when Cont_CODE then
				Result := "Cont_CODE"
			when Next_CODE then
				Result := "Next_CODE"
			when Step_CODE then
				Result := "Step_CODE"
			when Finish_CODE then
				Result := "Finish_CODE"
			when End_CODE then
				Result := "End_CODE"
			when Off_CODE then
				Result := "Off_CODE"
			when Go_CODE then
				Result := "Go_CODE"
			when Mark_CODE then
				Result := "Mark_CODE"
			when Reset_CODE then
				Result := "Reset_CODE"
			when Gc_CODE then
				Result := "Gc_CODE"
			when Break_CODE then
				Result := "Break_CODE"
			when Enable_CODE then
				Result := "Enable_CODE"
			when Disable_CODE then
				Result := "Disable_CODE"
			when Kill_CODE then
				Result := "Kill_CODE"
			when Where_CODE then
				Result := "Where_CODE"
			when To_CODE then
				Result := "To_CODE"
			when Up_CODE then
				Result := "Up_CODE"
			when Down_CODE then
				Result := "Down_CODE"
			when Assign_CODE then
				Result := "Assign_CODE"
			when Typeset_CODE then
				Result := "Typeset_CODE"
			when Processor_CODE then
				Result := "Processor_CODE"
			when Scoop_CODE then
				Result := "Scoop_CODE"
			when Print_CODE then
				Result := "Print_CODE"
			when Globals_CODE then
				Result := "Globals_CODE"
			when Alias_CODE then
				Result := "Alias_CODE"
			when Closure_CODE then
				Result := "Closure_CODE"
			when Nameof_CODE then
				Result := "Nameof_CODE"
			when Queries_CODE then
				Result := "Queries_CODE"
			when Creates_CODE then
				Result := "Creates_CODE"
			when Universe_CODE then
				Result := "Universe_CODE"
			when System_CODE then
				Result := "System_CODE"
			when List_CODE then
				Result := "List_CODE"
			when At_CODE then
				Result := "At_CODE"
			when Def_CODE then
				Result := "Def_CODE"
			when Search_CODE then
				Result := "Search_CODE"
			when Status_CODE then
				Result := "Status_CODE"
			when Overview_CODE then
				Result := "Overview_CODE"
			when Help_CODE then
				Result := "Help_CODE"
			when Quit_CODE then
				Result := "Quit_CODE"
			when LINE_CODE then
				Result := "LINE_CODE"
			when CATCH_CODE then
				Result := "CATCH_CODE"
			when WATCH_CODE then
				Result := "WATCH_CODE"
			when DEPTH_CODE then
				Result := "DEPTH_CODE"
			when TYPE_CODE then
				Result := "TYPE_CODE"
			when Stop_CODE then
				Result := "Stop_CODE"
			when Trace_CODE then
				Result := "Trace_CODE"
			when Silent_CODE then
				Result := "Silent_CODE"
			when Store_CODE then
				Result := "Store_CODE"
			when Restore_CODE then
				Result := "Restore_CODE"
			when NO_CODE then
				Result := "NO_CODE"
			when DG_COMMENT then
				Result := "DG_COMMENT"
			when DG_LBB then
				Result := "DG_LBB (%"[[%")"
			when DG_LCC then
				Result := "DG_LCC (%"{{%")"
			when DG_RCC then
				Result := "DG_RCC (%"}}%")"
			when DG_PP then
				Result := "DG_PP (%"++%")"
			when DG_INLINE then
				Result := "DG_INLINE"
			when DG_ALIAS then
				Result := "DG_ALIAS"
			when DG_CLOSURE then
				Result := "DG_CLOSURE"
			when DG_PLACEHOLDER then
				Result := "DG_PLACEHOLDER"
			when DG_ARROW then
				Result := "DG_ARROW"
			when DG_FORMAT then
				Result := "DG_FORMAT"
			when DG_UP_FRAME then
				Result := "DG_UP_FRAME"
			when E_CHARACTER then
				Result := "E_CHARACTER"
			when E_INTEGER then
				Result := "E_INTEGER"
			when E_REAL then
				Result := "E_REAL"
			when E_IDENTIFIER then
				Result := "E_IDENTIFIER"
			when E_STRING then
				Result := "E_STRING"
			when E_WHEN then
				Result := "E_WHEN"
			when E_CHECK then
				Result := "E_CHECK"
			when E_UNTIL then
				Result := "E_UNTIL"
			when E_CLASS then
				Result := "E_CLASS"
			when E_IF then
				Result := "E_IF"
			when E_LOOP then
				Result := "E_LOOP"
			when E_DO then
				Result := "E_DO"
			when E_FROM then
				Result := "E_FROM"
			when E_ALL then
				Result := "E_ALL"
			when E_DEBUG then
				Result := "E_DEBUG"
			when E_ONCE then
				Result := "E_ONCE"
			when E_CREATE then
				Result := "E_CREATE"
			when E_OLD then
				Result := "E_OLD"
			when DG_ASSIGN then
				Result := "DG_ASSIGN"
			when E_LIKE then
				Result := "E_LIKE"
			when E_NE then
				Result := "E_NE"
			when E_NOT_TILDE then
				Result := "E_NOT_TILDE"
			when E_GE then
				Result := "E_GE"
			when E_LE then
				Result := "E_LE"
			when E_MOD then
				Result := "E_MOD"
			when E_DIV then
				Result := "E_DIV"
			when E_FREEOP then
				Result := "E_FREEOP"
			when E_DOTDOT then
				Result := "E_DOTDOT"
			when E_CHARERR then
				Result := "E_CHARERR"
			when E_INTERR then
				Result := "E_INTERR"
			when E_REALERR then
				Result := "E_REALERR"
			when E_STRERR then
				Result := "E_STRERR"
			when E_IMPLIES then
				Result := "E_IMPLIES"
			when E_OR then
				Result := "E_OR"
			when E_XOR then
				Result := "E_XOR"
			when E_AND then
				Result := "E_AND"
			when E_NOT then
				Result := "E_NOT"
			else
				Result := yy_character_token_name (a_token)
			end
		end

feature -- Token codes

	Cont_CODE: INTEGER = 258
	Next_CODE: INTEGER = 259
	Step_CODE: INTEGER = 260
	Finish_CODE: INTEGER = 261
	End_CODE: INTEGER = 262
	Off_CODE: INTEGER = 263
	Go_CODE: INTEGER = 264
	Mark_CODE: INTEGER = 265
	Reset_CODE: INTEGER = 266
	Gc_CODE: INTEGER = 267
	Break_CODE: INTEGER = 268
	Enable_CODE: INTEGER = 269
	Disable_CODE: INTEGER = 270
	Kill_CODE: INTEGER = 271
	Where_CODE: INTEGER = 272
	To_CODE: INTEGER = 273
	Up_CODE: INTEGER = 274
	Down_CODE: INTEGER = 275
	Assign_CODE: INTEGER = 276
	Typeset_CODE: INTEGER = 277
	Processor_CODE: INTEGER = 278
	Scoop_CODE: INTEGER = 279
	Print_CODE: INTEGER = 280
	Globals_CODE: INTEGER = 281
	Alias_CODE: INTEGER = 282
	Closure_CODE: INTEGER = 283
	Nameof_CODE: INTEGER = 284
	Queries_CODE: INTEGER = 285
	Creates_CODE: INTEGER = 286
	Universe_CODE: INTEGER = 287
	System_CODE: INTEGER = 288
	List_CODE: INTEGER = 289
	At_CODE: INTEGER = 290
	Def_CODE: INTEGER = 291
	Search_CODE: INTEGER = 292
	Status_CODE: INTEGER = 293
	Overview_CODE: INTEGER = 294
	Help_CODE: INTEGER = 295
	Quit_CODE: INTEGER = 296
	LINE_CODE: INTEGER = 297
	CATCH_CODE: INTEGER = 298
	WATCH_CODE: INTEGER = 299
	DEPTH_CODE: INTEGER = 300
	TYPE_CODE: INTEGER = 301
	Stop_CODE: INTEGER = 302
	Trace_CODE: INTEGER = 303
	Silent_CODE: INTEGER = 304
	Store_CODE: INTEGER = 305
	Restore_CODE: INTEGER = 306
	NO_CODE: INTEGER = 307
	DG_COMMENT: INTEGER = 308
	DG_LBB: INTEGER = 309
	DG_LCC: INTEGER = 310
	DG_RCC: INTEGER = 311
	DG_PP: INTEGER = 312
	DG_INLINE: INTEGER = 313
	DG_ALIAS: INTEGER = 314
	DG_CLOSURE: INTEGER = 315
	DG_PLACEHOLDER: INTEGER = 316
	DG_ARROW: INTEGER = 317
	DG_FORMAT: INTEGER = 318
	DG_UP_FRAME: INTEGER = 319
	E_CHARACTER: INTEGER = 320
	E_INTEGER: INTEGER = 321
	E_REAL: INTEGER = 322
	E_IDENTIFIER: INTEGER = 323
	E_STRING: INTEGER = 324
	E_WHEN: INTEGER = 325
	E_CHECK: INTEGER = 326
	E_UNTIL: INTEGER = 327
	E_CLASS: INTEGER = 328
	E_IF: INTEGER = 329
	E_LOOP: INTEGER = 330
	E_DO: INTEGER = 331
	E_FROM: INTEGER = 332
	E_ALL: INTEGER = 333
	E_DEBUG: INTEGER = 334
	E_ONCE: INTEGER = 335
	E_CREATE: INTEGER = 336
	E_OLD: INTEGER = 337
	DG_ASSIGN: INTEGER = 338
	E_LIKE: INTEGER = 339
	E_NE: INTEGER = 340
	E_NOT_TILDE: INTEGER = 341
	E_GE: INTEGER = 342
	E_LE: INTEGER = 343
	E_MOD: INTEGER = 344
	E_DIV: INTEGER = 345
	E_FREEOP: INTEGER = 346
	E_DOTDOT: INTEGER = 347
	E_CHARERR: INTEGER = 348
	E_INTERR: INTEGER = 349
	E_REALERR: INTEGER = 350
	E_STRERR: INTEGER = 351
	E_IMPLIES: INTEGER = 352
	E_OR: INTEGER = 353
	E_XOR: INTEGER = 354
	E_AND: INTEGER = 355
	E_NOT: INTEGER = 356

end
