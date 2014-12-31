%option reentrant noyywrap stack prefix="gedb_scanner_parser_"
%option extra-type="GedbScannerParser*"
%{
#	include <_GedbScannerParser2.h>
%}
OP_CODE [+<>*/\\^&#@|%~!?]
CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))
%x GEDB_SCANNER_PARSER_S_VS1
%x GEDB_SCANNER_PARSER_S_VS2
%x GEDB_SCANNER_PARSER_S_VS3
%x GEDB_SCANNER_PARSER_S_LAVS1
%x GEDB_SCANNER_PARSER_S_LAVS2
%x GEDB_SCANNER_PARSER_S_LAVS3
%x GEDB_SCANNER_PARSER_S_MS
%x GEDB_SCANNER_PARSER_S_MSN
%%

(?x:\.) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_DOT; gedb_scanner_dot((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_DOT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\()|(?x:\[)|(?x:\{)|(?x:<<) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT; gedb_scanner_left((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\))|(?x:])|(?x:\})|(?x:>>) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_RIGHT; gedb_scanner_right((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_RIGHT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[-+*^<>=~$]) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_OP1; gedb_scanner_op1((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_OP1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\/) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_OP2; gedb_scanner_op2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_OP2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:<=)|(?x:>=)|(?x:\/=)|(?x:\/~)|(?x:\/\/)|(?x:\\\\)|(?x:\.\.) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_OP3; gedb_scanner_op3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_OP3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\?=)|(?x::=) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_ASSIGN; gedb_scanner_assign((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_ASSIGN, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[&#@\|\\%]) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_FREE_OP; gedb_scanner_free_op((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_FREE_OP, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:{OP_CODE}{2,}) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_FREE1; gedb_scanner_free1((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_FREE1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:({OP_CODE}+-)+{OP_CODE}*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_FREE2; gedb_scanner_free2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_FREE2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-({OP_CODE}+-)+) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_FREE3; gedb_scanner_free3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_FREE3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:-({OP_CODE}+-)*{OP_CODE}+) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_FREE4; gedb_scanner_free4((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_FREE4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[a-zA-Z][a-zA-Z0-9_]*)/(?x:[ \t\r\n]*\() {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_IDENTIFIER2; gedb_scanner_identifier2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_IDENTIFIER2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[a-zA-Z][a-zA-Z0-9_]*)/(?x:[ \t\r\n]*\[) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_IDENTIFIER3; gedb_scanner_identifier3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_IDENTIFIER3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[a-zA-Z][a-zA-Z0-9_]*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_IDENTIFIER; gedb_scanner_identifier((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_IDENTIFIER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_INTEGER; gedb_scanner_integer((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_INTEGER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+(_+[0-9]+)+) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_INTEGER2; gedb_scanner_integer2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_INTEGER2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:0[cC][0-7]+(_+[0-7]+)*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_INTEGER3; gedb_scanner_integer3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_INTEGER3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:0[bB][0-1]+(_+[0-1]+)*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_INTEGER4; gedb_scanner_integer4((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_INTEGER4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+\.)/(?x:[^.0-9]) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_REAL; gedb_scanner_real((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_REAL, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+\.[0-9]*[eE][+-]?[0-9]+) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_REAL2; gedb_scanner_real2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_REAL2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_REAL3; gedb_scanner_real3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_REAL3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+(_+[0-9]+)+\.)/(?x:[^.0-9]) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_REAL4; gedb_scanner_real4((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_REAL4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:[0-9]+(_+[0-9]+)*\.([0-9]+(_+[0-9]+)*)?[eE][+-]?[0-9]+(_+[0-9]+)*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_REAL5; gedb_scanner_real5((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_REAL5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:([0-9]+(_+[0-9]+)*)?\.[0-9]+(_+[0-9]+)*([eE][+-]?[0-9]+(_+[0-9]+)*)?) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_REAL6; gedb_scanner_real6((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_REAL6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:'[^%\n]') {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_CHARACTER; gedb_scanner_character((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_CHARACTER, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:'%.') {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_CHAR2; gedb_scanner_char2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_CHAR2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:'%\/{CHAR_CODE}\/') {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_CHAR3; gedb_scanner_char3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_CHAR3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^%\n ]*\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_STRING1; gedb_scanner_string1((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_STRING1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_STRING2; gedb_scanner_string2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_STRING2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+\")/(?x:([ \t\r\n]|"--")) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_STRING3; gedb_scanner_string3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_STRING3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^\n"]*"{")/(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM1; gedb_scanner_verbatim1((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_VS1>(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM2; gedb_scanner_verbatim2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_VS2>(?x:[ \t\r]*"}"[^\n"]*\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM3; gedb_scanner_verbatim3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_VS2>(?x:[^"\n]*\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM4; gedb_scanner_verbatim4((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_VS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM5; gedb_scanner_verbatim5((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_VS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM6; gedb_scanner_verbatim6((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_VS3>(?x:.*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_VERBATIM7; gedb_scanner_verbatim7((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_VERBATIM7, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"[^\n"]*"[")/(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM1; gedb_scanner_left_verbatim1((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_LAVS1>(?x:[ \t\r]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM2; gedb_scanner_left_verbatim2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_LAVS2>(?x:[ \t\r]*"]"[^\n"]*\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM3; gedb_scanner_left_verbatim3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_LAVS2>(?x:[^"\n]*\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM4; gedb_scanner_left_verbatim4((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_LAVS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM5; gedb_scanner_left_verbatim5((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_LAVS2>(?x:[^"\n]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM6; gedb_scanner_left_verbatim6((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_LAVS3>(?x:.*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_LEFT_VERBATIM7; gedb_scanner_left_verbatim7((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_LEFT_VERBATIM7, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
(?x:\"([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS1; gedb_scanner_ms1((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS1, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_MS>(?x:%[ \t\r]*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS2; gedb_scanner_ms2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_MS>(?x:%\/{CHAR_CODE}\/) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS3; gedb_scanner_ms3((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS3, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_MS>(?x:([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))+) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS4; gedb_scanner_ms4((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS4, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_MS>(?x:([^%\n"]|%([ABCDFHLNQRSTUV%'"()<>]|\/{CHAR_CODE}\/))*\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS5; gedb_scanner_ms5((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS5, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_MS>(?x:\") {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS6; gedb_scanner_ms6((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS6, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<GEDB_SCANNER_PARSER_S_MSN>(?x:[ \r\t]*%) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_MS7; gedb_scanner_ms7((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_MS7, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<INITIAL>(?x:"--".*\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_COMMENT; gedb_scanner_comment((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_COMMENT, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<INITIAL>(?x:[ \t\r]*) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_SPACE; gedb_scanner_space((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_SPACE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<INITIAL>(?x:\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_NEWLINE; gedb_scanner_newline((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_NEWLINE, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}
<INITIAL>(?x:\r\n) {
	yyextra->token_code = GEDB_SCANNER_PARSER_T_NEWLINE2; gedb_scanner_newline2((GedbScanner*)(yyextra), yytext, yyleng); gedb_scanner_parser_trace_token(yyextra, yyleng, GEDB_SCANNER_PARSER_T_NEWLINE2, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;
	}

%%

#	include <_GedbScannerParser2.h>

#	define GEDB_SCANNER_PARSER_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), GEDB_TYPE_SCANNER_PARSER, GedbScannerParserPrivate)) // for lex
#	define yy_accept gedb_accept // lex's version conflicts with lemon one

#	ifdef GEDB_SCANNER_PARSER_LEMON_ENABLED
		void *GedbLemonAlloc(void *(*mallocProc)(size_t));
		void GedbLemonFree(void *p, void (*freeProc)(void*));
		void GedbLemon(void *yyp, int yymajor, GObject *yyminor, GedbScanner *l_ea);
#	endif

GType gedb_scanner_parser_t_get_type (void) {
	static volatile gsize gedb_scanner_parser_t_type_id__volatile = 0;
	if (g_once_init_enter (&gedb_scanner_parser_t_type_id__volatile)) {
		static const GEnumValue values[] = {{GEDB_SCANNER_PARSER_T_END_OF_INPUT, "GEDB_SCANNER_PARSER_T_END_OF_INPUT", "END_OF_INPUT"}, {GEDB_SCANNER_PARSER_T_NO_ADD_TOKEN, "GEDB_SCANNER_PARSER_T_NO_ADD_TOKEN", "NO_ADD_TOKEN"}, {GEDB_SCANNER_PARSER_T_OPERATOR, "GEDB_SCANNER_PARSER_T_OPERATOR", "OPERATOR"}, {GEDB_SCANNER_PARSER_T_IDENTIFIER, "GEDB_SCANNER_PARSER_T_IDENTIFIER", "IDENTIFIER"}, {GEDB_SCANNER_PARSER_T_KEYWORD, "GEDB_SCANNER_PARSER_T_KEYWORD", "KEYWORD"}, {GEDB_SCANNER_PARSER_T_MANIFEST, "GEDB_SCANNER_PARSER_T_MANIFEST", "MANIFEST"}, {GEDB_SCANNER_PARSER_T_DOT, "GEDB_SCANNER_PARSER_T_DOT", "DOT"}, {GEDB_SCANNER_PARSER_T_LEFT, "GEDB_SCANNER_PARSER_T_LEFT", "LEFT"}, {GEDB_SCANNER_PARSER_T_RIGHT, "GEDB_SCANNER_PARSER_T_RIGHT", "RIGHT"}, {GEDB_SCANNER_PARSER_T_OP1, "GEDB_SCANNER_PARSER_T_OP1", "OP1"}, {GEDB_SCANNER_PARSER_T_OP2, "GEDB_SCANNER_PARSER_T_OP2", "OP2"}, {GEDB_SCANNER_PARSER_T_OP3, "GEDB_SCANNER_PARSER_T_OP3", "OP3"}, {GEDB_SCANNER_PARSER_T_ASSIGN, "GEDB_SCANNER_PARSER_T_ASSIGN", "ASSIGN"}, {GEDB_SCANNER_PARSER_T_FREE_OP, "GEDB_SCANNER_PARSER_T_FREE_OP", "FREE_OP"}, {GEDB_SCANNER_PARSER_T_FREE1, "GEDB_SCANNER_PARSER_T_FREE1", "FREE1"}, {GEDB_SCANNER_PARSER_T_FREE2, "GEDB_SCANNER_PARSER_T_FREE2", "FREE2"}, {GEDB_SCANNER_PARSER_T_FREE3, "GEDB_SCANNER_PARSER_T_FREE3", "FREE3"}, {GEDB_SCANNER_PARSER_T_FREE4, "GEDB_SCANNER_PARSER_T_FREE4", "FREE4"}, {GEDB_SCANNER_PARSER_T_IDENTIFIER2, "GEDB_SCANNER_PARSER_T_IDENTIFIER2", "IDENTIFIER2"}, {GEDB_SCANNER_PARSER_T_IDENTIFIER3, "GEDB_SCANNER_PARSER_T_IDENTIFIER3", "IDENTIFIER3"}, {GEDB_SCANNER_PARSER_T_INTEGER, "GEDB_SCANNER_PARSER_T_INTEGER", "INTEGER"}, {GEDB_SCANNER_PARSER_T_INTEGER2, "GEDB_SCANNER_PARSER_T_INTEGER2", "INTEGER2"}, {GEDB_SCANNER_PARSER_T_INTEGER3, "GEDB_SCANNER_PARSER_T_INTEGER3", "INTEGER3"}, {GEDB_SCANNER_PARSER_T_INTEGER4, "GEDB_SCANNER_PARSER_T_INTEGER4", "INTEGER4"}, {GEDB_SCANNER_PARSER_T_REAL, "GEDB_SCANNER_PARSER_T_REAL", "REAL"}, {GEDB_SCANNER_PARSER_T_REAL2, "GEDB_SCANNER_PARSER_T_REAL2", "REAL2"}, {GEDB_SCANNER_PARSER_T_REAL3, "GEDB_SCANNER_PARSER_T_REAL3", "REAL3"}, {GEDB_SCANNER_PARSER_T_REAL4, "GEDB_SCANNER_PARSER_T_REAL4", "REAL4"}, {GEDB_SCANNER_PARSER_T_REAL5, "GEDB_SCANNER_PARSER_T_REAL5", "REAL5"}, {GEDB_SCANNER_PARSER_T_REAL6, "GEDB_SCANNER_PARSER_T_REAL6", "REAL6"}, {GEDB_SCANNER_PARSER_T_CHARACTER, "GEDB_SCANNER_PARSER_T_CHARACTER", "CHARACTER"}, {GEDB_SCANNER_PARSER_T_CHAR2, "GEDB_SCANNER_PARSER_T_CHAR2", "CHAR2"}, {GEDB_SCANNER_PARSER_T_CHAR3, "GEDB_SCANNER_PARSER_T_CHAR3", "CHAR3"}, {GEDB_SCANNER_PARSER_T_STRING, "GEDB_SCANNER_PARSER_T_STRING", "STRING"}, {GEDB_SCANNER_PARSER_T_STRING1, "GEDB_SCANNER_PARSER_T_STRING1", "STRING1"}, {GEDB_SCANNER_PARSER_T_STRING2, "GEDB_SCANNER_PARSER_T_STRING2", "STRING2"}, {GEDB_SCANNER_PARSER_T_STRING3, "GEDB_SCANNER_PARSER_T_STRING3", "STRING3"}, {GEDB_SCANNER_PARSER_T_VERBATIM1, "GEDB_SCANNER_PARSER_T_VERBATIM1", "VERBATIM1"}, {GEDB_SCANNER_PARSER_T_VERBATIM2, "GEDB_SCANNER_PARSER_T_VERBATIM2", "VERBATIM2"}, {GEDB_SCANNER_PARSER_T_VERBATIM3, "GEDB_SCANNER_PARSER_T_VERBATIM3", "VERBATIM3"}, {GEDB_SCANNER_PARSER_T_VERBATIM4, "GEDB_SCANNER_PARSER_T_VERBATIM4", "VERBATIM4"}, {GEDB_SCANNER_PARSER_T_VERBATIM5, "GEDB_SCANNER_PARSER_T_VERBATIM5", "VERBATIM5"}, {GEDB_SCANNER_PARSER_T_VERBATIM6, "GEDB_SCANNER_PARSER_T_VERBATIM6", "VERBATIM6"}, {GEDB_SCANNER_PARSER_T_VERBATIM7, "GEDB_SCANNER_PARSER_T_VERBATIM7", "VERBATIM7"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM1, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM1", "LEFT_VERBATIM1"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM2, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM2", "LEFT_VERBATIM2"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM3, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM3", "LEFT_VERBATIM3"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM4, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM4", "LEFT_VERBATIM4"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM5, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM5", "LEFT_VERBATIM5"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM6, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM6", "LEFT_VERBATIM6"}, {GEDB_SCANNER_PARSER_T_LEFT_VERBATIM7, "GEDB_SCANNER_PARSER_T_LEFT_VERBATIM7", "LEFT_VERBATIM7"}, {GEDB_SCANNER_PARSER_T_MS1, "GEDB_SCANNER_PARSER_T_MS1", "MS1"}, {GEDB_SCANNER_PARSER_T_MS2, "GEDB_SCANNER_PARSER_T_MS2", "MS2"}, {GEDB_SCANNER_PARSER_T_MS3, "GEDB_SCANNER_PARSER_T_MS3", "MS3"}, {GEDB_SCANNER_PARSER_T_MS4, "GEDB_SCANNER_PARSER_T_MS4", "MS4"}, {GEDB_SCANNER_PARSER_T_MS5, "GEDB_SCANNER_PARSER_T_MS5", "MS5"}, {GEDB_SCANNER_PARSER_T_MS6, "GEDB_SCANNER_PARSER_T_MS6", "MS6"}, {GEDB_SCANNER_PARSER_T_MS7, "GEDB_SCANNER_PARSER_T_MS7", "MS7"}, {GEDB_SCANNER_PARSER_T_COMMENT, "GEDB_SCANNER_PARSER_T_COMMENT", "COMMENT"}, {GEDB_SCANNER_PARSER_T_SPACE, "GEDB_SCANNER_PARSER_T_SPACE", "SPACE"}, {GEDB_SCANNER_PARSER_T_NEWLINE, "GEDB_SCANNER_PARSER_T_NEWLINE", "NEWLINE"}, {GEDB_SCANNER_PARSER_T_NEWLINE2, "GEDB_SCANNER_PARSER_T_NEWLINE2", "NEWLINE2"}, {0, NULL, NULL}};
		GType gedb_scanner_parser_t_type_id;
		gedb_scanner_parser_t_type_id = g_enum_register_static ("GedbT", values);
		g_once_init_leave (&gedb_scanner_parser_t_type_id__volatile, gedb_scanner_parser_t_type_id);
	}
	return gedb_scanner_parser_t_type_id__volatile;
}

GType gedb_scanner_parser_s_get_type (void) {
	static volatile gsize gedb_scanner_parser_s_type_id__volatile = 0;
	if (g_once_init_enter (&gedb_scanner_parser_s_type_id__volatile)) {
		static const GEnumValue values[] = {{GEDB_SCANNER_PARSER_S_INITIAL, "GEDB_SCANNER_PARSER_S_INITIAL", "INITIAL"}, {GEDB_SCANNER_PARSER_S_VS1, "GEDB_SCANNER_PARSER_S_VS1", "VS1"}, {GEDB_SCANNER_PARSER_S_VS2, "GEDB_SCANNER_PARSER_S_VS2", "VS2"}, {GEDB_SCANNER_PARSER_S_VS3, "GEDB_SCANNER_PARSER_S_VS3", "VS3"}, {GEDB_SCANNER_PARSER_S_LAVS1, "GEDB_SCANNER_PARSER_S_LAVS1", "LAVS1"}, {GEDB_SCANNER_PARSER_S_LAVS2, "GEDB_SCANNER_PARSER_S_LAVS2", "LAVS2"}, {GEDB_SCANNER_PARSER_S_LAVS3, "GEDB_SCANNER_PARSER_S_LAVS3", "LAVS3"}, {GEDB_SCANNER_PARSER_S_MS, "GEDB_SCANNER_PARSER_S_MS", "MS"}, {GEDB_SCANNER_PARSER_S_MSN, "GEDB_SCANNER_PARSER_S_MSN", "MSN"}, {0, NULL, NULL}};
		GType gedb_scanner_parser_s_type_id;
		gedb_scanner_parser_s_type_id = g_enum_register_static ("GedbS", values);
		g_once_init_leave (&gedb_scanner_parser_s_type_id__volatile, gedb_scanner_parser_s_type_id);
	}
	return gedb_scanner_parser_s_type_id__volatile;
}

	GedbScannerParser* gedb_scanner_parser_construct(GType object_type)
	{	GedbScannerParser * self = NULL;
		self = (GedbScannerParser*) g_object_new (object_type, NULL);
		self->token_code = 0;
		self->token_gobject = NULL;
		self->is_match = TRUE;
		self->n_tokens_matched = 0;
		self->n_chars_read = 0;
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			gedb_scanner_parser_lex_init_extra(self, (yyscan_t*)&self->priv->lex_resource);
#		endif
#		ifdef GEDB_SCANNER_PARSER_LEMON_ENABLED
			self->priv->lemon_resource = GedbLemonAlloc(g_malloc);
#		endif
		return self;
	}

	GedbScannerParser* gedb_scanner_parser_new(void)
	{	return gedb_scanner_parser_construct(GEDB_TYPE_SCANNER_PARSER);
	}

	void gedb_scanner_parser_add_token(GedbScannerParser *self, gint token_code, void *token)
	{	self->n_tokens_matched++;
#		ifdef GEDB_SCANNER_PARSER_LEMON_ENABLED
			GObject *token_obj;
			g_return_if_fail(self != NULL);
			token_obj = token==NULL ? NULL : G(g_object_ref(G_OBJECT(token)));
			GedbLemon(self->priv->lemon_resource, token_code, token_obj, GEDB_(self));
#		endif
	}

	void gedb_scanner_parser_end(GedbScannerParser *self)
	{
#		ifdef GEDB_SCANNER_PARSER_LEMON_ENABLED
			g_return_if_fail(self != NULL);
			GedbLemon(self->priv->lemon_resource, 0, NULL, GEDB_(self));
#		endif
	}

#	ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
		YY_BUFFER_STATE gedb_scanner_parser__create_buffer(FILE *file,int size ,yyscan_t yyscagedber );
		void gedb_scanner_parser_push_buffer_state(YY_BUFFER_STATE new_buffer ,yyscan_t yyscagedber );
		void gedb_scanner_parser_pop_buffer_state(yyscan_t yyscagedber );
#	endif

	void gedb_scanner_parser_add_stream(GedbScannerParser *self, FILE *stream)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			gint token_code;
			yyscan_t scagedber;
			if (self->is_match)
			{	scagedber = (yyscan_t)self->priv->lex_resource;
				gedb_scanner_parser_push_buffer_state(gedb_scanner_parser__create_buffer(stream, YY_BUF_SIZE, scagedber), scagedber);
				while ((token_code = gedb_scanner_parser_lex(scagedber)) && self->is_match)
				{	if (token_code != GEDB_SCANNER_PARSER_T_NO_ADD_TOKEN)
					{	gedb_scanner_parser_add_token(self, token_code, self->token_gobject);
					}
				}
				gedb_scanner_parser_pop_buffer_state(scagedber);
			}
#		endif
	}

	void gedb_scanner_parser_add_string(GedbScannerParser *self, char *str)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			gint token_code;
			yyscan_t scagedber;
			YY_BUFFER_STATE buffer;
			if (self->is_match)
			{	scagedber = (yyscan_t)self->priv->lex_resource;
				buffer = gedb_scanner_parser__scan_string(str, scagedber);
				while ((token_code = gedb_scanner_parser_lex(scagedber)) && self->is_match)
				{	if (token_code != GEDB_SCANNER_PARSER_T_NO_ADD_TOKEN)
					{	gedb_scanner_parser_add_token(self, token_code, self->token_gobject);
					}
				}
				gedb_scanner_parser__delete_buffer(buffer, scagedber);
			}
#		endif
	}

	void gedb_scanner_parser_push_state(GedbScannerParser *self, int state)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			g_return_if_fail(self != NULL);
			yy_push_state(state, self->priv->lex_resource);
#		endif
	}

	void gedb_scanner_parser_pop_state(GedbScannerParser *self)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			g_return_if_fail(self != NULL);
			yy_pop_state(self->priv->lex_resource);
#		endif
	}

	int gedb_scanner_parser_top_state(GedbScannerParser *self)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			g_return_if_fail(self != NULL);
			return (((struct yyguts_t*)self->priv->lex_resource)->yy_start - 1) / 2 /*yy_top_state(self->priv->lex_resource)*/;
#		else
			return 0;
#		endif
	}

	static void gedb_scanner_parser_instance_init(GedbScannerParser *self)
	{	self->priv = GEDB_SCANNER_PARSER_GET_PRIVATE(self);
	}

	static void gedb_scanner_parser_finalize(GObject *obj)
	{	GedbScannerParser * self;
		self = GEDB_SCANNER_PARSER (obj);
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			gedb_scanner_parser_lex_destroy((yyscan_t)self->priv->lex_resource);
#		endif
#		ifdef GEDB_SCANNER_PARSER_LEMON_ENABLED
			GedbLemonFree(self->priv->lemon_resource, g_free);
#		endif
		if (self->token_gobject != NULL)
		{	g_object_unref(self->token_gobject);
		}
		G_OBJECT_CLASS(gedb_scanner_parser_parent_class)->finalize(obj);
	}

	static void gedb_scanner_parser_real_on_default_token(GedbScannerParser *self, const gchar *value, gint value_len)
	{
#		ifdef GEDB_SCANNER_PARSER_TRACE_TOKENS
			fprintf(stderr, "*TRACE on_default_token(): %s\n", value);
#		endif
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			self->is_match = FALSE;
#		endif
	}

	static void gedb_scanner_parser_real_on_parse_failed(GedbScannerParser *self)
	{	self->is_match = FALSE;
	}

	static void gedb_scanner_parser_real_on_syntax_error(GedbScannerParser *self)
	{	self->is_match = FALSE;
	}

	static void gedb_scanner_parser_real_on_parse_accept(GedbScannerParser *self)
	{
	}

	void gedb_scanner_parser_on_default_token(GedbScannerParser *self, const gchar *value, gint value_len)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			GEDB_SCANNER_PARSER_GET_CLASS(self)->on_default_token(self, value, value_len);
#		endif
	}

	void gedb_scanner_parser_on_parse_failed(GedbScannerParser *self)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			GEDB_SCANNER_PARSER_GET_CLASS(self)->on_parse_failed(self);
#		endif
	}

	void gedb_scanner_parser_on_syntax_error(GedbScannerParser *self)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			GEDB_SCANNER_PARSER_GET_CLASS(self)->on_syntax_error(self);
#		endif
	}

	void gedb_scanner_parser_on_parse_accept(GedbScannerParser *self)
	{
#		ifdef GEDB_SCANNER_PARSER_LEX_ENABLED
			GEDB_SCANNER_PARSER_GET_CLASS(self)->on_parse_accept(self);
#		endif
	}

	static void gedb_scanner_parser_class_init(GedbScannerParserClass *klass)
	{	gedb_scanner_parser_parent_class = g_type_class_peek_parent(klass);
		g_type_class_add_private(klass, sizeof(GedbScannerParserPrivate));
		G_OBJECT_CLASS(klass)->finalize = gedb_scanner_parser_finalize;
		GEDB_SCANNER_PARSER_CLASS(klass)->on_default_token = gedb_scanner_parser_real_on_default_token;
		GEDB_SCANNER_PARSER_CLASS(klass)->on_parse_failed = gedb_scanner_parser_real_on_parse_failed;
		GEDB_SCANNER_PARSER_CLASS(klass)->on_syntax_error = gedb_scanner_parser_real_on_syntax_error;
		GEDB_SCANNER_PARSER_CLASS(klass)->on_parse_accept = gedb_scanner_parser_real_on_parse_accept;
	}

	GType gedb_scanner_parser_get_type(void)
	{	static volatile gsize gedb_scanner_parser_type_id__volatile = 0;
		if (g_once_init_enter (&gedb_scanner_parser_type_id__volatile)) {
			static const GTypeInfo g_define_type_info = { sizeof (GedbScannerParserClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) gedb_scanner_parser_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (GedbScannerParser), 0, (GInstanceInitFunc) gedb_scanner_parser_instance_init, NULL };
			GType gedb_scanner_parser_type_id;
			gedb_scanner_parser_type_id = g_type_register_static (G_TYPE_OBJECT, "GedbScannerParser", &g_define_type_info, 0);
			g_once_init_leave (&gedb_scanner_parser_type_id__volatile, gedb_scanner_parser_type_id);
		}
		return gedb_scanner_parser_type_id__volatile;
	}

int gedb_scanner_parser_input(GedbScannerParser *self)
{	self->n_chars_read++;
	return input(self->priv->lex_resource);
}

void gedb_scanner_parser_unput(GedbScannerParser *self, int c)
{	self->n_chars_read--;
	return yyunput(c, ((struct yyguts_t*)self->priv->lex_resource)->yytext_ptr, self->priv->lex_resource);
}
