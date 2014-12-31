%option reentrant noyywrap stack prefix="eval_parser_parser_"
%option extra-type="EvalParserParser*"
%{
#	include <_EvalParserParser2.h>
%}
%x EVAL_PARSER_PARSER_S_IDENT
%x EVAL_PARSER_PARSER_S_CMD
OP_CODE [+<>*/\\^&#@|%~]
CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))
%%

<EVAL_PARSER_PARSER_S_CMD>(?x:alias) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_ALIAS_CMD; eval_parser_alias_cmd((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_ALIAS_CMD, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<EVAL_PARSER_PARSER_S_CMD>(?x:break) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_BREAK_CMD; eval_parser_break_cmd((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_BREAK_CMD, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<EVAL_PARSER_PARSER_S_CMD>(?x:debug) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DEBUG_CMD; eval_parser_debug_cmd((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DEBUG_CMD, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:catch) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_EXC; eval_parser_exc((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_EXC, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:at) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_AT; eval_parser_at((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_AT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:depth) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DEPTH; eval_parser_depth((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DEPTH, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:type) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_TYP; eval_parser_typ((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_TYP, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:if) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IFF; eval_parser_iff((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IFF, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:print) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_PRINT; eval_parser_print((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_PRINT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:cont) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_CONT; eval_parser_cont((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_CONT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:disabled) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DIS; eval_parser_dis((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DIS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:->) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_ARROW; eval_parser_arrow((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_ARROW, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\^+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_UPFRAME; eval_parser_upframe((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_UPFRAME, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\^[0-9]+\^) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_UPFRAME_COUNT; eval_parser_upframe_count((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_UPFRAME_COUNT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[!?]\?*) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_PLACEHOLDER; eval_parser_placeholder((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_PLACEHOLDER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\.) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DOT; eval_parser_dot((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DOT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:,) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_COMMA; eval_parser_comma((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_COMMA, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x::) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_COLON; eval_parser_colon((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_COLON, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<INITIAL>(?x:\() {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LPAREN; eval_parser_lparen((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LPAREN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<EVAL_PARSER_PARSER_S_IDENT>(?x:\() {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IDENT_LPAREN; eval_parser_ident_lparen((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IDENT_LPAREN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\)) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_RPAREN; eval_parser_rparen((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_RPAREN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<INITIAL>(?x:\[) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LBRACKET; eval_parser_lbracket((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LBRACKET, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<EVAL_PARSER_PARSER_S_IDENT>(?x:\[) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IDENT_LBRACKET; eval_parser_ident_lbracket((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IDENT_LBRACKET, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:]) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_RBRACKET; eval_parser_rbracket((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_RBRACKET, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\[\[) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LBB; eval_parser_lbb((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LBB, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:]]) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_RBB; eval_parser_rbb((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_RBB, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\{) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LBRACE; eval_parser_lbrace((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LBRACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\}) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_RBRACE; eval_parser_rbrace((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_RBRACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<<) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LMA; eval_parser_lma((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LMA, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:>>) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_RMA; eval_parser_rma((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_RMA, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_MINUS; eval_parser_minus((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_MINUS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_PLUS; eval_parser_plus((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_PLUS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\*) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_TIMES; eval_parser_times((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_TIMES, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DIV; eval_parser_div((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DIV, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\^) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_UP; eval_parser_up((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_UP, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LT; eval_parser_lt((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:>) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_GT; eval_parser_gt((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_GT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:=) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_EQ; eval_parser_eq((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_EQ, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:~) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_SIM; eval_parser_sim((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_SIM, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\$) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DOLLAR; eval_parser_dollar((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DOLLAR, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/=) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_NE; eval_parser_ne((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_NE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:~=) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_NSIM; eval_parser_nsim((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_NSIM, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/\/) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IDIV; eval_parser_idiv((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IDIV, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\\\\) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IMOD; eval_parser_imod((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IMOD, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<=) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LE; eval_parser_le((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:>=) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_GE; eval_parser_ge((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_GE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\.\.) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_DOTDOT; eval_parser_dotdot((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_DOTDOT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\|) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_BIT_OR; eval_parser_bit_or((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_BIT_OR, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:&) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_BIT_AND; eval_parser_bit_and((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_BIT_AND, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\|<<) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_LEFT_SHIFT; eval_parser_left_shift((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_LEFT_SHIFT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\|>>) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_RIGHT_SHIFT; eval_parser_right_shift((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_RIGHT_SHIFT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[&#@\|\\%]) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_FREE_OP; eval_parser_free_op((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_FREE_OP, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\|\.\.\|) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_INTERVAL; eval_parser_interval((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_INTERVAL, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:{OP_CODE}{2,}) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_FREE1; eval_parser_free1((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_FREE1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:({OP_CODE}+-)+{OP_CODE}*) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_FREE2; eval_parser_free2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_FREE2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-({OP_CODE}+-)+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_FREE3; eval_parser_free3((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_FREE3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-({OP_CODE}+-)*{OP_CODE}+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_FREE4; eval_parser_free4((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_FREE4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:⚫) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_BULLET; eval_parser_bullet((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_BULLET, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[a-zA-Z][a-zA-Z0-9_]*) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IDENTIFIER; eval_parser_identifier((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IDENTIFIER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[a-zA-Z][a-zA-Z0-9_]*)/(?x:[ \t\r\n]*\() {
	yyextra->token_code = EVAL_PARSER_PARSER_T_IDENTIFIER2; eval_parser_identifier2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_IDENTIFIER2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:_[1-9][0-9]*) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_HEAPVAR; eval_parser_heapvar((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_HEAPVAR, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:_[a-z][a-z0-9_]*) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_ALIAS; eval_parser_alias((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_ALIAS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[oO][nN][cC][eE][ \t\r]*)/(?x:["{]) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_ONCE_STRING; eval_parser_once_string((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_ONCE_STRING, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_INTEGER; eval_parser_integer((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_INTEGER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:0[Xx][A-Fa-f0-9]+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_INTEGER2; eval_parser_integer2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_INTEGER2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+\.)/(?x:[^.0-9]) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_REAL; eval_parser_real((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_REAL, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+\.[0-9]*[eE][+-]?[0-9]+) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_REAL2; eval_parser_real2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_REAL2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_REAL3; eval_parser_real3((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_REAL3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\'[^%\n]\') {
	yyextra->token_code = EVAL_PARSER_PARSER_T_CHARACTER; eval_parser_character((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_CHARACTER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\'%[ABCDFHLNQRSTUV%'"()<>]\') {
	yyextra->token_code = EVAL_PARSER_PARSER_T_CHAR2; eval_parser_char2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_CHAR2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\'%\/{CHAR_CODE}\/\') {
	yyextra->token_code = EVAL_PARSER_PARSER_T_CHAR3; eval_parser_char3((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_CHAR3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^%\n ]*\") {
	yyextra->token_code = EVAL_PARSER_PARSER_T_STRING1; eval_parser_string1((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_STRING1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+\") {
	yyextra->token_code = EVAL_PARSER_PARSER_T_STRING2; eval_parser_string2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_STRING2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[ \t]) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_SPACE; eval_parser_space((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_SPACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\n) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_NEWLINE; eval_parser_newline((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_NEWLINE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\r\n) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_NEWLINE2; eval_parser_newline2((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_NEWLINE2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x::=) {
	yyextra->token_code = EVAL_PARSER_PARSER_T_ASSIGN; eval_parser_assign((EvalParser*)(yyextra), yytext, yyleng); eval_parser_parser_trace_token(yyextra, yyleng, EVAL_PARSER_PARSER_T_ASSIGN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}

%%

int eval_parser_parser_input(EvalParserParser *self)
{	self->n_chars_read++;
	return input(self->priv->lex_resource);
}

void eval_parser_parser_unput(EvalParserParser *self, int c)
{	self->n_chars_read--;
	return yyunput(c, ((struct yyguts_t*)self->priv->lex_resource)->yytext_ptr, self->priv->lex_resource);
}
