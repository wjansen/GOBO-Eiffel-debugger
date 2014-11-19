namespace Gedb {

	public class Scanner : ScannerParser {

		/**
		   @match matched string
		 */
		public signal void scanned(string match);
		
		/**
		   number of line (starting at 0) where last match is located  	   
		 */
		public int line_count;
		
		/**
		   Is the match in a `note' clause ?
		 */
		public bool in_note;

		[Flex(token="OPERATOR IDENTIFIER KEYWORD MANIFEST")]
		public override void on_default_token(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
		}
		
		/* Eiffel symbols */
		
		[Flex(pattern="\\.")]
		public void dot(string value, int value_len) {
			scanned(value);
		}
		
		[Flex(pattern="\\(|\\[|\\{|<<")]
		public void left(string value, int value_len) {
			scanned(value);
		}
		
		[Flex(pattern="\\)|]|\\}|>>")]
		public void right(string value, int value_len) {
			scanned(value);
		}
		
		[Flex(pattern="[-+*^<>=~$]")]
		public void op1(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		} 

		[Flex(pattern="\\/")]
		public void op2(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			if (value[0].isalpha()) 
				stderr.printf("%s\n", value);
			scanned(value);
		} 

		[Flex(pattern="<=|>=|\\/=|\\/~|\\/\\/|\\\\\\\\|\\.\\.")]
		public void op3(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		}
		
		[Flex(pattern="\\?=|:=")]
		public void assign(string value, int value_len) { 
			scanned(value);
		}	
		
		/* Eiffel free operators */
		
		[Flex(pattern="[&#@\\|\\\\%]")]
		public void free_op(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		}
		
		[Flex(define="OP_CODE [+<>*/\\\\^&#@|%~!?]", pattern="{OP_CODE}{2,}")]
		public void free1(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		}
		
		[Flex(pattern="({OP_CODE}+-)+{OP_CODE}*")]
		public void free2(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		}
		
		[Flex(pattern="-({OP_CODE}+-)+")]
		public void free3(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		}
		
		[Flex(pattern="-({OP_CODE}+-)*{OP_CODE}+")]
		public void free4(string value, int value_len) {
			token_code = TokenCode.OPERATOR;
			scanned(value);
		}
		
		/* Eiffel identifiers */
/* // Experimantal:
		[Flex(pattern="[Ff][Aa][Ll][Ss][Ee]")]
		public void false_manifest(string value, int value_len) {
			token_code = TokenCode.MANIFEST;
			scanned(value);
		}
		
		[Flex(pattern="[Tt][Rr][Uu][Ee]")]
		public void true_manifest(string value, int value_len) {
			token_code = TokenCode.MANIFEST;
			scanned(value);
		}
		
		[Flex(pattern="[Vv][Oo][Ii][Dd]")]
		public void void_manifest(string value, int value_len) {
			token_code = TokenCode.MANIFEST;
			scanned(value);
		}
*/		
		[Flex(pattern="[a-zA-Z][a-zA-Z0-9_]*/[ \\t\\r\\n]*\\(")]
		public void identifier2(string value, int value_len) {
			token_code = process_identifier(value);
			scanned(value);
		}
		
		[Flex(pattern="[a-zA-Z][a-zA-Z0-9_]*/[ \\t\\r\\n]*\\[")]
		public void identifier3(string value, int value_len) {
			token_code = process_identifier(value);
			scanned(value);
		}
		
		[Flex(pattern="[a-zA-Z][a-zA-Z0-9_]*")]
		public void identifier(string value, int value_len) {
			token_code = process_identifier(value);
			scanned(value);
		}
		
		/* Eiffel integers */
		
		[Flex(pattern="[0-9]+")]
		public void integer(string value, int value_len) {
			scanned(value);
		}
		
		[Flex(pattern="[0-9]+(_+[0-9]+)+")]
		public void integer2(string value, int value_len) {
			token_code = TokenCode.INTEGER;
			scanned(value);
		}
		
		[Flex(pattern="0[cC][0-7]+(_+[0-7]+)*")]
		public void integer3(string value, int value_len) {
			token_code = TokenCode.INTEGER;
			scanned(value);
		}
		
		[Flex(pattern="0[bB][0-1]+(_+[0-1]+)*")]
		public void integer4(string value, int value_len) {
			token_code = TokenCode.INTEGER;
			scanned(value);
		}
		
		/* Eiffel reals */
		
		[Flex(pattern="[0-9]+\\./[^.0-9]")]
		public void real(string value, int value_len) {
			scanned(value);
		}
		
		[Flex(pattern="[0-9]+\\.[0-9]*[eE][+-]?[0-9]+")]
		public void real2(string value, int value_len) {
			token_code = TokenCode.REAL;
			scanned(value);
		}
		
		[Flex(pattern="[0-9]*\\.[0-9]+([eE][+-]?[0-9]+)?")]
		public void real3(string value, int value_len) {
			token_code = TokenCode.REAL;
			scanned(value);
		}
		
		[Flex(pattern="[0-9]+(_+[0-9]+)+\\./[^.0-9]")]
		public void real4(string value, int value_len) {
			token_code = TokenCode.REAL;
			scanned(value);
		}
		
		[Flex(pattern="[0-9]+(_+[0-9]+)*\\.([0-9]+(_+[0-9]+)*)?[eE][+-]?[0-9]+(_+[0-9]+)*")]
		public void real5(string value, int value_len) {
			token_code = TokenCode.REAL;
			scanned(value);
		}
		
		[Flex(pattern="([0-9]+(_+[0-9]+)*)?\\.[0-9]+(_+[0-9]+)*([eE][+-]?[0-9]+(_+[0-9]+)*)?")]
		public void real6(string value, int value_len) {
			token_code = TokenCode.REAL;
			scanned(value);
		}
		
		/* Eiffel characters */
		
		[Flex(pattern="\'[^%\\n]\'")]
		public void character(string value, int value_len) {
			scanned(value);
		}
		
		[Flex(pattern="\'%.\'")]
		public void char2(string value, int value_len) {
			token_code = TokenCode.CHARACTER;
			scanned(value);
		}
		
		[Flex(define="CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))", 
			  pattern="\'%\\/{CHAR_CODE}\\/\'")]
		public void char3(string value, int value_len) {
			token_code = TokenCode.CHARACTER;
			scanned(value);
		}
		
		/* Eiffel strings */
		
		[Flex(token="STRING", pattern="\\\"[^%\\n ]*\\\"")]
		public void string1(string value, int value_len) {
			token_code = TokenCode.STRING;
			scanned(value);
		}
		
		[Flex(pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+\\\"")]  
		public void string2(string value, int value_len) { 
			token_code = TokenCode.STRING;
			scanned(value);
		}
		
		[Flex(pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+\\\"/([ \\t\\r\\n]|\"--\")")]  
		public void string3(string value, int value_len) {  
			token_code = TokenCode.STRING;
			scanned(value);
		}
		
		/* Verbatim string: */
		
		[Flex(x="VS1 VS2 VS3", pattern="\\\"[^\\n\"]*\"{\"/[ \\t\\r]*\\n")]
		public void verbatim1(string value, int value_len) {
			marker = other_marker(value);
			token_code = TokenCode.NO_ADD_TOKEN; 
			scanned(value);
			push_state(State.VS1);
		}
		
		[Flex(state="VS1", pattern="[ \\t\\r]*\\n")]
		public void verbatim2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
			pop_state();
			push_state(State.VS2);
		}
		
		[Flex(state="VS2", pattern="[ \\t\\r]*\"}\"[^\\n\"]*\\\"")]
		public void verbatim3(string value, int value_len) { 
			if (value.strip()==marker) {
				marker = "";
				token_code = TokenCode.STRING;
				pop_state();
			} else {
				token_code = TokenCode.NO_ADD_TOKEN;
				pop_state();
				push_state(State.VS3);
			}
			scanned(value);
		}
	
		[Flex(state="VS2", pattern="[^\"\\n]*\\\"")]  
		public void verbatim4(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			pop_state();
			push_state(State.VS3);
		}
		
		[Flex(state="VS2", pattern="[^\"\\n]*\\n")] 
		public void verbatim5(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
		}
		
		[Flex(state="VS2", pattern="[^\"\\n]*\\n")]
		public void verbatim6(string value, int value_len) { /*"*/
			++line_count;
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="VS3", pattern=".*\\n")]
		public void verbatim7(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
			pop_state();
			push_state(State.VS2);
		} 
		
		/* Left-aligned verbatim string */
		
		[Flex(x="LAVS1 LAVS2 LAVS3",
			  pattern="\\\"[^\\n\"]*\"[\"/[ \\t\\r]*\\n")]
		public void left_verbatim1(string value, int value_len) {
			marker = other_marker(value);
			token_code = TokenCode.NO_ADD_TOKEN; 
			scanned(value);
			push_state(State.LAVS1);
		}
		
		[Flex(state="LAVS1", pattern="[ \\t\\r]*\\n")]
		public void left_verbatim2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
			pop_state();
			push_state(State.LAVS2);
		}
		
		[Flex(state="LAVS2", pattern="[ \\t\\r]*\"]\"[^\\n\"]*\\\"")]
		public void left_verbatim3(string value, int value_len) { /*"*/	
			if (value.strip()==marker) {
				marker = "";
				token_code = TokenCode.STRING;
				pop_state();
			} else {
				token_code = TokenCode.NO_ADD_TOKEN;
				pop_state();
				push_state(State.LAVS3);
			}
			scanned(value);
		}
		
		[Flex(state="LAVS2", pattern="[^\"\\n]*\\\"")]  
		public void left_verbatim4(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			pop_state();
			push_state(State.LAVS3);
		}
		
		[Flex(state="LAVS2", pattern="[^\"\\n]*\\n")] 
		public void left_verbatim5(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
		}
		
		[Flex(state="LAVS2", pattern="[^\"\\n]*\\n")]
		public void left_verbatim6(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
		}
		
		[Flex(state="LAVS3", pattern=".*\\n")]
		public void left_verbatim7(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
			pop_state();
			push_state(State.LAVS2);	
		}
		
		/* Multiline string: */
		
		[Flex(x="MS MSN", 
			  pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))*")]
		public void ms1(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			push_state(State.MS);
		}
		
		[Flex(state="MS", pattern="%[ \\t\\r]*\\n")]
		public void ms2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
			pop_state();
			push_state(State.MSN);
		}
		
		[Flex(state="MS", pattern="%\\/{CHAR_CODE}\\/")]
		public void ms3(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
		}
		
		[Flex(state="MS", 
			  pattern="([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+")]
		public void ms4(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
		}
		
		[Flex(state="MS", 
			  pattern="([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))*\\\"")]
		public void ms5(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
		}
		
		[Flex(state="MS", pattern="\\\"")]
		public void ms6(string value, int value_len) {
			token_code = TokenCode.STRING;
			scanned(value);
			pop_state();
		}
		
		[Flex(state="MSN", pattern="[ \\r\\t]*%")]
		public void ms7(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			pop_state();
			push_state(State.MS);
		}
		
		/* Miscellaneous */ 
		
		[Flex(state="INITIAL", pattern="\"--\".*\\n")]
		public void comment(string value, int value_len) {
			scanned(value);
			++line_count;
		}
		
		[Flex(state="INITIAL", pattern="[ \\t\\r]*")]
		public void space(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
		}
		
		[Flex(state="INITIAL", pattern="\\n")]
		public void newline(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
		}
		
		[Flex(state="INITIAL", pattern="\\r\\n")]
		public void newline2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			scanned(value);
			++line_count;
		}
		
		static HashTable<string,int> keywords;
		
		private static uint nocase_hash(string s) {
			return str_hash(s.down());
		}
		
		private static bool nocase_equal(string a, string b) {
			return a.ascii_casecmp(b) == 0;
		}
		
		private ScannerParser.TokenCode process_identifier(string str) {
			if (keywords==null) {
				keywords = new HashTable<string,int>(nocase_hash, nocase_equal);
				keywords.insert("across", TokenCode.KEYWORD);
				keywords.insert("agent", TokenCode.KEYWORD);
				keywords.insert("alias", TokenCode.KEYWORD);
				keywords.insert("all", TokenCode.KEYWORD);
				keywords.insert("and", TokenCode.KEYWORD);
				keywords.insert("as", TokenCode.KEYWORD);
				keywords.insert("assign", TokenCode.KEYWORD);
				keywords.insert("attached", TokenCode.KEYWORD);
				keywords.insert("attribute", TokenCode.KEYWORD);
				keywords.insert("check", TokenCode.KEYWORD);
				keywords.insert("class", TokenCode.KEYWORD);
				keywords.insert("convert", TokenCode.KEYWORD);
				keywords.insert("create", TokenCode.KEYWORD);
				keywords.insert("debug", TokenCode.KEYWORD);
				keywords.insert("deferred", TokenCode.KEYWORD);
				keywords.insert("detachable", TokenCode.KEYWORD);
				keywords.insert("do", TokenCode.KEYWORD);
				keywords.insert("else", TokenCode.KEYWORD);
				keywords.insert("elseif", TokenCode.KEYWORD);
				keywords.insert("end", TokenCode.KEYWORD);
				keywords.insert("ensure", TokenCode.KEYWORD);
				keywords.insert("expanded", TokenCode.KEYWORD);
				keywords.insert("export", TokenCode.KEYWORD);
				keywords.insert("external", TokenCode.KEYWORD);
				keywords.insert("feature", TokenCode.KEYWORD);
				keywords.insert("from", TokenCode.KEYWORD);
				keywords.insert("frozen", TokenCode.KEYWORD);
				keywords.insert("if", TokenCode.KEYWORD);
				keywords.insert("implies", TokenCode.KEYWORD);
				keywords.insert("inherit", TokenCode.KEYWORD);
				keywords.insert("inspect", TokenCode.KEYWORD);
				keywords.insert("invariant", TokenCode.KEYWORD);
				keywords.insert("like", TokenCode.KEYWORD);
				keywords.insert("local", TokenCode.KEYWORD);
				keywords.insert("loop", TokenCode.KEYWORD);
				keywords.insert("not", TokenCode.KEYWORD);
				keywords.insert("note", TokenCode.KEYWORD);
				keywords.insert("obsolete", TokenCode.KEYWORD);
				keywords.insert("old", TokenCode.KEYWORD);
				keywords.insert("once", TokenCode.KEYWORD);
				keywords.insert("only", TokenCode.KEYWORD);
				keywords.insert("or", TokenCode.KEYWORD);
				keywords.insert("redefine", TokenCode.KEYWORD);
				keywords.insert("rename", TokenCode.KEYWORD);
				keywords.insert("require", TokenCode.KEYWORD);
				keywords.insert("rescue", TokenCode.KEYWORD);
				keywords.insert("retry", TokenCode.KEYWORD);
				keywords.insert("select", TokenCode.KEYWORD);
				keywords.insert("separate", TokenCode.KEYWORD);
				keywords.insert("some", TokenCode.KEYWORD);
				keywords.insert("then", TokenCode.KEYWORD);
				keywords.insert("undefine", TokenCode.KEYWORD);
				keywords.insert("until", TokenCode.KEYWORD);
				keywords.insert("variant", TokenCode.KEYWORD);
				keywords.insert("when", TokenCode.KEYWORD);
				keywords.insert("xor", TokenCode.KEYWORD);
			}
			if (str=="note") {
				in_note = true;
				return TokenCode.COMMENT;
			} else {
				if (keywords.contains(str)) {
					in_note = false;
					return (ScannerParser.TokenCode)keywords.@get(str);
				} else {
					return TokenCode.IDENTIFIER;
				}
			}
		}
		
		private string other_marker(string text) requires (text.length>1) {
			string m = text.strip();
			int l = m.length;
			char c = m[l-1];
			switch(c) {
			case '{':
				c = '}';
				break;
			case '[':
				c = ']';
				break;
			default:
				break;
			}
			m = "%c%s\"".printf(c, m.substring(1, l-2));
			return m;
		}
	
		private string marker;
		
	}
	
} /* namespace*/
