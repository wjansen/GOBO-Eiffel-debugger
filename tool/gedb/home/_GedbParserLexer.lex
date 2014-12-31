%option reentrant noyywrap stack prefix="gedb_parser_parser_"
%option extra-type="GedbParserParser*"
%{
#	include <_GedbParserParser2.h>
%}
OP_CODE [+<>*/\\^&#@|%~!?]
CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))
%x GEDB_PARSER_PARSER_S_VS1
%x GEDB_PARSER_PARSER_S_VS2
%x GEDB_PARSER_PARSER_S_VS3
%x GEDB_PARSER_PARSER_S_LAVS1
%x GEDB_PARSER_PARSER_S_LAVS2
%x GEDB_PARSER_PARSER_S_LAVS3
%x GEDB_PARSER_PARSER_S_MS
%x GEDB_PARSER_PARSER_S_MSN
%%

(?x:\.) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_DOT; gedb_parser_dot((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_DOT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:,) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_COMMA; gedb_parser_comma((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_COMMA, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x::) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_COLON; gedb_parser_colon((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_COLON, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:;) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_SEMICOLON; gedb_parser_semicolon((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_SEMICOLON, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:!) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_EXCLAMATION_MARK; gedb_parser_exclamation_mark((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_EXCLAMATION_MARK, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\?) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_QUESTION_MARK; gedb_parser_question_mark((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_QUESTION_MARK, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\() {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LPAREN; gedb_parser_lparen((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LPAREN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\)) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_RPAREN; gedb_parser_rparen((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_RPAREN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\[) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LBRACKET; gedb_parser_lbracket((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LBRACKET, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_RBRACKET; gedb_parser_rbracket((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_RBRACKET, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\$) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_ADDRESS; gedb_parser_address((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_ADDRESS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\{) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LBRACE; gedb_parser_lbrace((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LBRACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\}) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_RBRACE; gedb_parser_rbrace((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_RBRACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<<) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LMA; gedb_parser_lma((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LMA, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:>>) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_RMA; gedb_parser_rma((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_RMA, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MINUS; gedb_parser_minus((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MINUS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_PLUS; gedb_parser_plus((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_PLUS, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_TIMES; gedb_parser_times((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_TIMES, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_DIV; gedb_parser_div((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_DIV, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\^) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_POWER; gedb_parser_power((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_POWER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LT; gedb_parser_lt((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:>) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_GT; gedb_parser_gt((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_GT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:=) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_EQ; gedb_parser_eq((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_EQ, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:~) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_SIM; gedb_parser_sim((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_SIM, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:or[ ]+else) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_ORELSE; gedb_parser_orelse((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_ORELSE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:and[ ]+then) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_ANDTHEN; gedb_parser_andthen((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_ANDTHEN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\$) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_DOLLAR; gedb_parser_dollar((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_DOLLAR, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\?=)|(?x::=) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_ASSIGN; gedb_parser_assign((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_ASSIGN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/=) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_NE; gedb_parser_ne((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_NE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:~=) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_NSIM; gedb_parser_nsim((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_NSIM, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/\/) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_IDIV; gedb_parser_idiv((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_IDIV, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\\\\) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_IMOD; gedb_parser_imod((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_IMOD, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<=) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LE; gedb_parser_le((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:>=) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_GE; gedb_parser_ge((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_GE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\.\.) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_DOTDOT; gedb_parser_dotdot((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_DOTDOT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[&#@\|\\%]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_FREE_OP; gedb_parser_free_op((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_FREE_OP, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:{OP_CODE}{2,}) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_FREE1; gedb_parser_free1((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_FREE1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:({OP_CODE}+-)+{OP_CODE}*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_FREE2; gedb_parser_free2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_FREE2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-({OP_CODE}+-)+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_FREE3; gedb_parser_free3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_FREE3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-({OP_CODE}+-)*{OP_CODE}+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_FREE4; gedb_parser_free4((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_FREE4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[oO][nN][cC][eE][ \t]*)/(?x:["{]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_ONCE_STRING; gedb_parser_once_string((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_ONCE_STRING, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[dD][eE][bB][uU][gG][ \t]*)/(?x:\() {
	yyextra->token_code = GEDB_PARSER_PARSER_T_DEBUG_LPAREN; gedb_parser_debug_lparen((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_DEBUG_LPAREN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[Ff][Aa][Ll][Ss][Ee]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_FALSE_MANIFEST; gedb_parser_false_manifest((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_FALSE_MANIFEST, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[Tt][Rr][Uu][Ee]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_TRUE_MANIFEST; gedb_parser_true_manifest((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_TRUE_MANIFEST, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[Vv][Oo][Ii][Dd]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VOID_MANIFEST; gedb_parser_void_manifest((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VOID_MANIFEST, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[a-zA-Z][a-zA-Z0-9_]*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_IDENTIFIER; gedb_parser_identifier((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_IDENTIFIER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_INTEGER; gedb_parser_integer((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_INTEGER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+(_+[0-9]+)+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_INTEGER2; gedb_parser_integer2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_INTEGER2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:0[xX][0-9A-Fa-f]+(_+[0-9A-Fa-f]+)*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_INTEGER3; gedb_parser_integer3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_INTEGER3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:0[cC][0-7]+(_+[0-7]+)*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_INTEGER4; gedb_parser_integer4((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_INTEGER4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:0[bB][0-1]+(_+[0-1]+)*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_INTEGER5; gedb_parser_integer5((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_INTEGER5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+\.)/(?x:[^.0-9]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_REAL; gedb_parser_real((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_REAL, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+\.[0-9]*[eE][+-]?[0-9]+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_REAL2; gedb_parser_real2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_REAL2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_REAL3; gedb_parser_real3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_REAL3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+(_+[0-9]+)+\.)/(?x:[^.0-9]) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_REAL4; gedb_parser_real4((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_REAL4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+(_+[0-9]+)*\.([0-9]+(_+[0-9]+)*)?[eE][+-]?[0-9]+(_+[0-9]+)*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_REAL5; gedb_parser_real5((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_REAL5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:([0-9]+(_+[0-9]+)*)?\.[0-9]+(_+[0-9]+)*([eE][+-]?[0-9]+(_+[0-9]+)*)?) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_REAL6; gedb_parser_real6((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_REAL6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:'[^%\n]') {
	yyextra->token_code = GEDB_PARSER_PARSER_T_CHARACTER; gedb_parser_character((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_CHARACTER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:'%.') {
	yyextra->token_code = GEDB_PARSER_PARSER_T_CHAR2; gedb_parser_char2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_CHAR2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:'%\/{CHAR_CODE}\/') {
	yyextra->token_code = GEDB_PARSER_PARSER_T_CHAR3; gedb_parser_char3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_CHAR3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^%\n]*\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_STRING1; gedb_parser_string1((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_STRING1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_STRING2; gedb_parser_string2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_STRING2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+\")/(?x:([ \t\r\n]|"--")) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_STRING3; gedb_parser_string3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_STRING3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^\n"]*"{")/(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM1; gedb_parser_verbatim1((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS1>(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM2; gedb_parser_verbatim2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS2>(?x:[ \t\r]*"}"[^\n"]*\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM3; gedb_parser_verbatim3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS2>(?x:[^"\n]*\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM4; gedb_parser_verbatim4((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS2>(?x:[^"\n]*\r\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM5; gedb_parser_verbatim5((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM6; gedb_parser_verbatim6((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS3>(?x:.*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM7; gedb_parser_verbatim7((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM7, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS3>(?x:.*\r\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM8; gedb_parser_verbatim8((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM8, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_VS3>(?x:.*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_VERBATIM9; gedb_parser_verbatim9((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_VERBATIM9, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^\n"]*"[")/(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM1; gedb_parser_left_verbatim1((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS1>(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM2; gedb_parser_left_verbatim2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS2>(?x:[ \t\r]*"]"[^\n"]*\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM3; gedb_parser_left_verbatim3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS2>(?x:[^"\n]*\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM4; gedb_parser_left_verbatim4((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM5; gedb_parser_left_verbatim5((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM6; gedb_parser_left_verbatim6((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS3>(?x:.*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM7; gedb_parser_left_verbatim7((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM7, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_LAVS3>(?x:.*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_LEFT_VERBATIM8; gedb_parser_left_verbatim8((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_LEFT_VERBATIM8, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS1; gedb_parser_ms1((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_MS>(?x:%[ \t\r]*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS2; gedb_parser_ms2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_MS>(?x:%\/{CHAR_CODE}\/) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS3; gedb_parser_ms3((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_MS>(?x:([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS4; gedb_parser_ms4((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_MS>(?x:([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))*\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS5; gedb_parser_ms5((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_MS>(?x:\") {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS6; gedb_parser_ms6((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_PARSER_PARSER_S_MSN>(?x:[ \r\t]*%) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_MS7; gedb_parser_ms7((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_MS7, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:"--".*\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_COMMENT; gedb_parser_comment((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_COMMENT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[ \t\r]*) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_SPACE; gedb_parser_space((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_SPACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_NEWLINE; gedb_parser_newline((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_NEWLINE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\r\n) {
	yyextra->token_code = GEDB_PARSER_PARSER_T_NEWLINE2; gedb_parser_newline2((GedbParser*)(yyextra), yytext, yyleng); gedb_parser_parser_trace_token(yyextra, yyleng, GEDB_PARSER_PARSER_T_NEWLINE2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}

%%

int gedb_parser_parser_input(GedbParserParser *self)
{	self->n_chars_read++;
	return input(self->priv->lex_resource);
}

void gedb_parser_parser_unput(GedbParserParser *self, int c)
{	self->n_chars_read--;
	return yyunput(c, ((struct yyguts_t*)self->priv->lex_resource)->yytext_ptr, self->priv->lex_resource);
}
