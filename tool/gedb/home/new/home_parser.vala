/**
   Scanner/Parser of Eiffel source code to produce tags in the debugger's 
   text buffer. 
 */

namespace Gedb {

	[Lemon(token_type=true)]
	protected class Token : Object { 
		public string name;
		public int at;
		public int size;
		
		public Token(string value, int at, int size=0) { 
			this.name = value; 
			this.at = at;
			this.size = size==0 ? value.char_count() : size;
		}
	}
	
	[Lemon(start_symbol=true)]
	public class Start : Classified {
		[Lemon(pattern="FeatureDecl(f)")]
		public Start(Parser h, FeatureDecl f) {}
	}
	
	[Lemon(extra_argument=true,
		   nonassoc="COLON",
		   nonassoc="COMMA",
		   nonassoc="QUOTE",
		   right="ASSIGN",
		   nonassoc="CREATE AGENT ATTACHED LIKE",
		   left="IMPLIES", left="OR ORELSE XOR", left="AND ANDTHEN",
		   left="EQ NE SIM NSIM LT LE GT GE", 
		   left="DOTDOT", 
		   left="PLUS MINUS",
		   left="TIMES DIV IDIV IMOD", right="POWER", 
		   left="FREE_OP", right="NOT ADDRESS OLD",
		   right="LPAREN LBRACKET LBRA   ",
		   left="DOT AS"
			)]
	public class Parser : ParserParser {

		internal int line_count; 

		public Parser(FeatureText* ft, System* s) { 
			token = new Token("", 0);
			this.ft = ft;
			system = s;
		}

		public System* system;
		public FeatureText* ft { get; private set; }
		public signal void ident_matched(Classified v);
		public signal void class_matched(Classified v);
		
//		public override void on_syntax_error() {
		public override void on_parse_failed() {
			stderr.printf("Syntax: `%s'\t%s:%u, off=%d\n", 
						  token.name, ((Gedb.Name*)ft.home).fast_name,
						  ft.first_pos/256, n_chars_read-line_count);
		}
		
/* ------------------- Scanner ------------------- */
		
		[Flex(token="
		ACROSS
		AGENT
		ALIAS
		ALL
		AND
		AS
		ASSIGN
		ATTACHED
		ATTRIBUTE
		CHECK
		CLASS
		CONVERT
		CREATE
		DEBUG
		DEFERRED
		DETACHABLE
		DO
		ELSE
		ELSEIF
		END
		ENSURE
		EXPANDED
		EXPORT
		EXTERNAL
		FEATURE
		FROM
		FROZEN
		IF
		IMPLIES
		INHERIT
		INSPECT
		INVARIANT
		LIKE
		LOCAL
		LOOP
		NOT
		NOTE
		OBSOLETE
		OLD
		ONCE
		ONLY
		OR
		REDEFINE
		RENAME
		REQUIRE
		RESCUE
		RETRY
		SELECT
		SEPARATE
		SOME
		THEN
		UNDEFINE
		UNTIL
		VARIANT
		WHEN
		XOR
		TUPLE
		PRECURSOR
		MANIFEST
		"
		)]
		public override void on_default_token(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		/* Eiffel symbols */
		
		[Flex(pattern="\\.")]
		public void dot(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern=",")]
		public void comma(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern=":")]
		public void colon(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern=";")]
		public void semicolon(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(pattern="!")]
		public void exclamation_mark(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\?")]
		public void question_mark(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\(")]
		public void lparen(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\)")]
		public void rparen(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\[")]
		public void lbracket(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="]")]
		public void rbracket(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\$")]
		public void address(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\{")]
		public void lbrace(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\}")]
		public void rbrace(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="<<")]
		public void lma(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern=">>")]
		public void rma(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="-")]
		public void minus(string value, int value_len) {
			token = new Token(value, n_chars_read);
		} 
		
		[Flex(pattern="\\+")]
		public void plus(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\*")]
		public void times(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\/")]
		public void div(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\^")]
		public void power(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="<")]
		public void lt(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern=">")]
		public void gt(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="=")]
		public void eq(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="~")]
		public void sim(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="[\"]")]
		public void quote(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="or[ ]+else")]
		public void orelse(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="and[ ]+then")]
		public void andthen(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\$")]
		public void dollar(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\?=|:=")]
		public void assign(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}	
		
		[Flex(pattern="\\/=")]
		public void ne(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="~=")]
		public void nsim(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\/\\/")]
		public void idiv(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\\\\\\\")]
		public void imod(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="<=")]
		public void le(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern=">=")]
		public void ge(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\\.\\.")]
		public void dotdot(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}

		[Flex(pattern="\\[]")]
		public void brackets(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
	/* Eiffel free operators */
		
		[Flex(pattern="[&#@\\|\\\\%]")]
		public void free_op(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(define="OP_CODE [+<>*/\\\\^&#@|%~!?]", pattern="{OP_CODE}{2,}")]
		public void free1(string value, int value_len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(value, n_chars_read);
		}
	
		[Flex(pattern="({OP_CODE}+-)+{OP_CODE}*")]
		public void free2(string value, int value_len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="-({OP_CODE}+-)+")]
		public void free3(string value, int value_len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="-({OP_CODE}+-)*{OP_CODE}+")]
		public void free4(string value, int value_len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(value, n_chars_read);
		}
		
		/* Reserved words */
		
		[Flex(pattern="[oO][nN][cC][eE][ \\t]*/[\"{]")] 
		public void once_string(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(pattern="[dD][eE][bB][uU][gG][ \\t]*/\\(")]
		public void debug_lparen(string value, int value_len) {
			token = new Token(value, n_chars_read);		
		}
		
		[Flex(pattern="[Ff][Aa][Ll][Ss][Ee]")]
		public void false_manifest(string value, int value_len) {
			token_code = TokenCode.MANIFEST;
			token = new Token(value, n_chars_read);		
		}
		
		[Flex(pattern="[Tt][Rr][Uu][Ee]")]
		public void true_manifest(string value, int value_len) {
			token_code = TokenCode.MANIFEST;
			token = new Token(value, n_chars_read);		
		}
		
		[Flex(pattern="[Vv][Oo][Ii][Dd]")]
		public void void_manifest(string value, int value_len) {
			token_code = TokenCode.MANIFEST;
			token = new Token(value, n_chars_read);		
		}
		
		/* Eiffel identifiers */
		
		[Flex(pattern="[a-zA-Z][a-zA-Z0-9_]*")]
		public void identifier(string value, int value_len) {
			token_code = process_identifier(value);
			token = new Token(value, n_chars_read);
		}
		
		/* Eiffel integers */
		
		[Flex(pattern="[0-9]+")]
		public void integer(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="[0-9]+(_+[0-9]+)+")]
		public void integer2(string value, int value_len) {
			token_code = TokenCode.INTEGER;
		}
		
		[Flex(pattern="0[xX][0-9A-Fa-f]+(_+[0-9A-Fa-f]+)*")]
		public void integer3(string value, int value_len) {
			token_code = TokenCode.INTEGER;
		}
		
		[Flex(pattern="0[cC][0-7]+(_+[0-7]+)*")]
		public void integer4(string value, int value_len) {
			token_code = TokenCode.INTEGER;
		}
		
		[Flex(pattern="0[bB][0-1]+(_+[0-1]+)*")]
		public void integer5(string value, int value_len) {
			token_code = TokenCode.INTEGER;
		}
		
		/* Eiffel reals */
		
		[Flex(pattern="[0-9]+\\./[^.0-9]")]
		public void real(string value, int value_len) {
			token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="[0-9]+\\.[0-9]*[eE][+-]?[0-9]+")]
		public void real2(string value, int value_len) {
			token_code = TokenCode.REAL;
		}
		
		[Flex(pattern="[0-9]*\\.[0-9]+([eE][+-]?[0-9]+)?")]
		public void real3(string value, int value_len) {
			token_code = TokenCode.REAL;
		}
		
		[Flex(pattern="[0-9]+(_+[0-9]+)+\\./[^.0-9]")]
		public void real4(string value, int value_len) {
			token_code = TokenCode.REAL;
		}
		
		[Flex(pattern="[0-9]+(_+[0-9]+)*\\.([0-9]+(_+[0-9]+)*)?[eE][+-]?[0-9]+(_+[0-9]+)*")]
		public void real5(string value, int value_len) {
			token_code = TokenCode.REAL;
		}
		
		[Flex(pattern="([0-9]+(_+[0-9]+)*)?\\.[0-9]+(_+[0-9]+)*([eE][+-]?[0-9]+(_+[0-9]+)*)?")]
		public void real6(string value, int value_len) {
			token_code = TokenCode.REAL;
		}
		
		/* Eiffel characters */
		
		[Flex(pattern="\'[^%\\n]\'")]
		public void character(string value, int value_len) {
							token = new Token(value, n_chars_read);
		}
		
		[Flex(pattern="\'%.\'")]
		public void char2(string value, int value_len) {
			token_code = TokenCode.CHARACTER;
		}
		
		[Flex(define="CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))", 
			  pattern="\'%\\/{CHAR_CODE}\\/\'")]
		public void char3(string value, int value_len) {
			token_code = TokenCode.CHARACTER;
		}
		
		/* Eiffel strings */
		
		[Flex(token="STRING", pattern="\\\"[^%\\n]*\\\"")]
		public void string1(string value, int value_len) {
			token_code = TokenCode.STRING;
			token = new Token(value, n_chars_read);			
		}
		
		[Flex(pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+\\\"")]  
		public void string2(string value, int value_len) { 
			token_code = TokenCode.STRING;
			token = new Token(value, n_chars_read);			
		}
		
		[Flex(pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+\\\"/([ \\t\\r\\n]|\"--\")")]  
		public void string3(string value, int value_len) {  
			token_code = TokenCode.STRING;
			token = new Token(value, n_chars_read);			
		}
		
		/* Verbatim string: */
		
		[Flex(x="VS1 VS2 VS3", pattern="\\\"[^\\n\"]*\"{\"/[ \\t\\r]*\\n")]
		public void verbatim1(string value, int value_len) {
			marker = other_marker(value);
			token_code = TokenCode.NO_ADD_TOKEN; 
			push_state(State.VS1);
		}
		
		[Flex(state="VS1", pattern="[ \\t\\r]*\\n")]
		public void verbatim2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.VS2);
		}
		
		[Flex(state="VS2", pattern="[ \\t\\r]*\"}\"[^\\n\"]*\\\"")]
		public void verbatim3(string value, int value_len) { 
			if (value.strip()==marker) {
				marker = "";
				token_code = TokenCode.STRING;
				token = new Token(value, n_chars_read);			
				pop_state();
			} else {
				token_code = TokenCode.NO_ADD_TOKEN;
				pop_state();
				push_state(State.VS3);
			}
		}
		
		[Flex(state="VS2", pattern="[^\"\\n]*\\\"")]  
		public void verbatim4(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.VS3);
		}
		
		[Flex(state="VS2", pattern="[^\"\\n]*\\r\\n")] 
		public void verbatim5(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="VS2", pattern="[^\"\\n]*\\n")]
		public void verbatim6(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="VS3", pattern=".*\\n")]
		public void verbatim7(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.VS2);
		} 
		
		[Flex(state="VS3", pattern=".*\\r\\n")]
		public void verbatim8(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.VS2);
		}
		
		[Flex(state="VS3", pattern=".*\\n")]
		public void verbatim9(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.VS2);
		}
		
		/* Left-aligned verbatim string */
		
		[Flex(x="LAVS1 LAVS2 LAVS3",
			  pattern="\\\"[^\\n\"]*\"[\"/[ \\t\\r]*\\n")]
		public void left_verbatim1(string value, int value_len) {
			marker = other_marker(value);
			token_code = TokenCode.NO_ADD_TOKEN; 
			push_state(State.LAVS1);
		}
		
		[Flex(state="LAVS1", pattern="[ \\t\\r]*\\n")]
		public void left_verbatim2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.LAVS2);
		}
		
		[Flex(state="LAVS2", pattern="[ \\t\\r]*\"]\"[^\\n\"]*\\\"")]
		public void left_verbatim3(string value, int value_len) { 
			if (value.strip()==marker) {
				marker = "";
				token_code = TokenCode.STRING;
				token = new Token(value, n_chars_read);			
				pop_state();
			} else {
				token_code = TokenCode.NO_ADD_TOKEN;
				pop_state();
				push_state(State.LAVS3);
			}
		}
		
		[Flex(state="LAVS2", pattern="[^\"\\n]*\\\"")]  
		public void left_verbatim4(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.LAVS3);
		}
		
		[Flex(state="LAVS2", pattern="[^\"\\n]*\\n")] 
		public void left_verbatim5(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="LAVS2", pattern="[^\"\\n]*\\n")]
		public void left_verbatim6(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="LAVS3", pattern=".*\\n")]
		public void left_verbatim7(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.LAVS2);	
		}
		
		[Flex(state="LAVS3", pattern=".*\\n")]
		public void left_verbatim8(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.LAVS2);
		}
		
		/* Multiline string: */
		
		[Flex(x="MS MSN", 
			  pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))*")]
		public void ms1(string value, int value_len) { 
			token_code = TokenCode.NO_ADD_TOKEN;
			push_state(State.MS);
		}
		
		[Flex(state="MS", pattern="%[ \\t\\r]*\\n")]
		public void ms2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.MSN);
		}
		
		[Flex(state="MS", pattern="%\\/{CHAR_CODE}\\/")]
		public void ms3(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="MS", 
			  pattern="([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+")]
		public void ms4(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="MS", 
			  pattern="([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))*\\\"")]
		public void ms5(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="MS", pattern="\\\"")]
		public void ms6(string value, int value_len) {
			token_code = TokenCode.STRING;
			token = new Token(value, n_chars_read);			
			pop_state();
		}
		
		[Flex(state="MSN", pattern="[ \\r\\t]*%")]
		public void ms7(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			pop_state();
			push_state(State.MS);
		}
		
		/* Miscellaneous */ 
		
		[Flex(pattern="\"--\".*\\n")]
		public void comment(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(pattern="[ \\t\\r]*")]
		public void space(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(pattern="\\n")]
		public void newline(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
			++line_count;
		}
		
		[Flex(pattern="\\r\\n")]
		public void newline2(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		internal void pop_states() {
			while (state!=State.INITIAL) pop_state();
		}

		private static HashTable<string,ParserParser.TokenCode> keywords;
		
		private static uint nocase_hash(string s) {
			return str_hash(s.down());
		}
		
		private static bool nocase_equal(string a, string b) {
			return a.ascii_casecmp(b) == 0;
		}
		
		private ParserParser.TokenCode process_identifier(string str) {
			if (keywords==null) {
				keywords = new HashTable<string,ParserParser.TokenCode>
				(nocase_hash, nocase_equal);
				keywords.insert("across", TokenCode.ACROSS);
				keywords.insert("agent", TokenCode.AGENT);
				keywords.insert("alias", TokenCode.ALIAS);
				keywords.insert("all", TokenCode.ALL);
				keywords.insert("and", TokenCode.AND);
				keywords.insert("as", TokenCode.AS);
				keywords.insert("assign", TokenCode.ASSIGN);
				keywords.insert("attached", TokenCode.ATTACHED);
				keywords.insert("attribute", TokenCode.ATTRIBUTE);
				keywords.insert("check", TokenCode.CHECK);
				keywords.insert("class", TokenCode.CLASS);
				keywords.insert("convert", TokenCode.CONVERT);
				keywords.insert("create", TokenCode.CREATE);
				keywords.insert("debug", TokenCode.DEBUG);
				keywords.insert("deferred", TokenCode.DEFERRED);
				keywords.insert("detachable", TokenCode.DETACHABLE);
				keywords.insert("do", TokenCode.DO);
				keywords.insert("else", TokenCode.ELSE);
				keywords.insert("elseif", TokenCode.ELSEIF);
				keywords.insert("end", TokenCode.END);
				keywords.insert("ensure", TokenCode.ENSURE);
				keywords.insert("expanded", TokenCode.EXPANDED);
				keywords.insert("export", TokenCode.EXPORT);
				keywords.insert("external", TokenCode.EXTERNAL);
				keywords.insert("feature", TokenCode.FEATURE);
				keywords.insert("from", TokenCode.FROM);
				keywords.insert("frozen", TokenCode.FROZEN);
				keywords.insert("if", TokenCode.IF);
				keywords.insert("implies", TokenCode.IMPLIES);
				keywords.insert("inherit", TokenCode.INHERIT);
				keywords.insert("inspect", TokenCode.INSPECT);
				keywords.insert("invariant", TokenCode.INVARIANT);
				keywords.insert("like", TokenCode.LIKE);
				keywords.insert("local", TokenCode.LOCAL);
				keywords.insert("loop", TokenCode.LOOP);
				keywords.insert("not", TokenCode.NOT);
				keywords.insert("note", TokenCode.NOTE);
				keywords.insert("obsolete", TokenCode.OBSOLETE);
				keywords.insert("old", TokenCode.OLD);
				keywords.insert("once", TokenCode.ONCE);
				keywords.insert("only", TokenCode.ONLY);
				keywords.insert("or", TokenCode.OR);
				keywords.insert("redefine", TokenCode.REDEFINE);
				keywords.insert("rename", TokenCode.RENAME);
				keywords.insert("require", TokenCode.REQUIRE);
				keywords.insert("rescue", TokenCode.RESCUE);
				keywords.insert("retry", TokenCode.RETRY);
				keywords.insert("select", TokenCode.SELECT);
				keywords.insert("separate", TokenCode.SEPARATE);
				keywords.insert("some", TokenCode.SOME);
				keywords.insert("then", TokenCode.THEN);
				keywords.insert("undefine", TokenCode.UNDEFINE);
				keywords.insert("until", TokenCode.UNTIL);
				keywords.insert("variant", TokenCode.VARIANT);
				keywords.insert("when", TokenCode.WHEN);
				keywords.insert("xor", TokenCode.XOR);
				keywords.insert("tuple", TokenCode.TUPLE);
				keywords.insert("precursor", TokenCode.PRECURSOR);
			}
			var name = str.down();
			if (keywords.contains(name)) {
				in_note = false;
				return keywords.@get(name);
			} else {
				return TokenCode.IDENTIFIER;
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
		internal bool in_note;
		internal bool in_inspect;
		
	}
	
	public class Qualified {
		public ClassText* cls;
		public FeatureText* ft;
		public uint pos;
		public uint size;
		public Qualified? p;
		
		public Qualified.empty() {}
		public Qualified(Token t) {
			pos = t.at;
			size = t.size;
		}
	}
	
	public class Classified : Token {

		public Qualified q;
		
		protected Classified.empty() {
			base("", 0, 0);
			q = new Qualified.empty();
		}

		protected Classified.from_token(FeatureText* ft, Token t,
				Classified? p=null, Classified? arg=null) {
			base(t.name, t.at, t.size);
			var c = t as Classified;
			q = new Qualified(t);
			q.size = c!=null ? c.q.size : size;
			ClassText* home = null;
			RoutineText* rt = null;
			uint n;
			if (p!=null) {
				set_parent(p);
			} else if (ft!=null) {
				home = ft.home;
				rt = ft.is_routine() ? (RoutineText*)ft : null;
				q.ft = home.query_by_name(out n, name, arg==null, rt);
				if (n==1 && q.ft==null)
					q.ft = null; //home.feature_by_name(name, true);
			}
		}
		
		protected Classified(Classified v) {
			base(v.name, v.at, v.size);
			q = v.q;
		}
		
		protected void end_by(Token t) { q.size = t.size+(t.at-q.pos); }
		
		public void set_parent(Classified p) {
			ClassText* home = p.q.ft!=null ? p.q.ft.result_text : p.q.cls;
			uint n = 0;
			q.p = p.q;
			if (home==null) return;
			q.ft = home.feature_by_name(name, true);
		}
	}
	
	public class FeatureDecl : Classified {
		private FeatureDecl(Classified c) { base(c); }

		[Lemon(pattern="QueryDecl(qd)")]
			public FeatureDecl._1(Parser h,QueryDecl qd) {}
		[Lemon(pattern="ProcDecl(pd)")]
			public FeatureDecl._2(Parser h,ProcDecl pd) {}
	}

	public class QueryDecl : Classified {
		private QueryDecl(Classified c) { base(c); }

		[Lemon(pattern="SingleQueryDecl(sqd)")]
			public QueryDecl._1(Parser h,SingleQueryDecl sqd) {}
		[Lemon(pattern="FROZEN SingleQueryDecl(sqd)")]
			public QueryDecl._2(Parser h,SingleQueryDecl sqd) {}
		[Lemon(pattern="ExtFeatureName(efn) COMMA QueryDecl(sqd)")]
			public QueryDecl._3(Parser h,ExtFeatureName efn, QueryDecl qd) {}
		[Lemon(pattern="FROZEN ExtFeatureName(efn) COMMA QueryDecl(sqd)")]
			public QueryDecl._4(Parser h,ExtFeatureName efn, QueryDecl qd) {}

	}

	public class ProcDecl : Classified {
		private ProcDecl(Classified c) { base(c); }

		[Lemon(pattern="SingleProcDecl(sqd)")]
			public ProcDecl._1(Parser h,SingleProcDecl sqd) {}
		[Lemon(pattern="FROZEN SingleProcDecl(sqd)")]
			public ProcDecl._2(Parser h,SingleProcDecl sqd) {}
		[Lemon(pattern="ExtFeatureName(efn) COMMA ProcDecl(sqd)")]
			public ProcDecl._3(Parser h,ExtFeatureName efn, ProcDecl qd) {}
		[Lemon(pattern="FROZEN ExtFeatureName(efn) COMMA ProcDecl(sqd)")]
			public ProcDecl._4(Parser h,ExtFeatureName efn, ProcDecl qd) {}

	}

	public class SingleQueryDecl : Classified {
		private SingleQueryDecl(Classified c) { base(c); }

		[Lemon(pattern="ExtFeatureName(efn) COLON Typ(t) Assigner")]
			public SingleQueryDecl._1(Parser h,ExtFeatureName efn, Typ t) {}
		[Lemon(pattern="FeatureName(efn) COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl AttributeCombound(ac) PostCond Rescue END")]
			public SingleQueryDecl._2(Parser h,ExtFeatureName efn, Typ t, AttributeCombound ac) {}
		[Lemon(pattern="FeatureName(efn) COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl DO DoCombound(dc) PostCond Rescue END")]
			public SingleQueryDecl._3(Parser h,ExtFeatureName efn, Typ t, DoCombound dc) {}
		[Lemon(pattern="FeatureName(efn) FormalArgs COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl DO DoCombound(dc) PostCond Rescue END")]
			public SingleQueryDecl._4(Parser h,ExtFeatureName efn, Typ t, DoCombound dc) {}
		[Lemon(pattern="FeatureName(efn) COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl ONCE OnceCombound(oc) PostCond Rescue END")]
			public SingleQueryDecl._5(Parser h,ExtFeatureName efn, Typ t, OnceCombound oc) {}
		[Lemon(pattern="FeatureName(efn) FormalArgs COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl ONCE OnceCombound(oc) PostCond Rescue END")]
			public SingleQueryDecl._6(Parser h,ExtFeatureName efn, Typ t, OnceCombound oc) {}
		[Lemon(pattern="FeatureName(efn) COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl DEFERRED DeferredCombound(dc) PostCond Rescue END")]
			public SingleQueryDecl._7(Parser h,ExtFeatureName efn, Typ t, DeferredCombound dc) {}
		[Lemon(pattern="FeatureName(efn) FormalArgs COLON Typ(t) Assigner Indexing Obsolete PreCond LocalDecl DEFERRED DeferredCombound(dc) PostCond Rescue END")]
			public SingleQueryDecl._8(Parser h,ExtFeatureName efn, Typ t, DeferredCombound dc) {}

	}

	public class SingleProcDecl : Classified {
		private SingleProcDecl(Classified c) { base(c); }

		[Lemon(pattern="FeatureName(efn)  Indexing Obsolete PreCond LocalDecl DO DoCombound(dc) PostCond Rescue END")]
			public SingleProcDecl._1(Parser h,ExtFeatureName efn, Typ t, DoCombound dc) {}
		[Lemon(pattern="FeatureName(efn) FormalArgs  Indexing Obsolete PreCond LocalDecl DO DoCombound(dc) PostCond Rescue END")]
			public SingleProcDecl._2(Parser h,ExtFeatureName efn, Typ t, DoCombound dc) {}
		[Lemon(pattern="FeatureName(efn)  Indexing Obsolete PreCond LocalDecl ONCE OnceCombound(oc) PostCond Rescue END")]
			public SingleProcDecl._3(Parser h,ExtFeatureName efn, Typ t, OnceCombound oc) {}
		[Lemon(pattern="FeatureName(efn) FormalArgs  Indexing Obsolete PreCond LocalDecl ONCE OnceCombound(oc) PostCond Rescue END")]
			public SingleProcDecl._4(Parser h,ExtFeatureName efn, Typ t, OnceCombound oc) {}
		[Lemon(pattern="FeatureName(efn)  Indexing Obsolete PreCond LocalDecl DEFERRED DeferredCombound(dc) PostCond Rescue END")]
			public SingleProcDecl._5(Parser h,ExtFeatureName efn, Typ t, DeferredCombound dc) {}
		[Lemon(pattern="FeatureName(efn) FormalArgs  Indexing Obsolete PreCond LocalDecl DEFERRED DeferredCombound(dc) PostCond Rescue END")]
			public SingleProcDecl._6(Parser h,ExtFeatureName efn, Typ t, DeferredCombound dc) {}

	}

	public class Indexing : Classified {

		[Lemon(pattern="")]
		public Indexing._0(Parser h) {}
// TODO
	}

	public class Obsolete : Classified {
		[Lemon(pattern="")]
		public Obsolete._0(Parser h) {}
// TODO
	}

	public class Assertions : Classified {
		private Assertions(Classified c) { base(c); }

		[Lemon(pattern="Expr(x)")]
		public Assertions._1(Parser h,Expr x) {}
		[Lemon(pattern="Identifier COLON")]
		public Assertions._2(Parser h) {}
		[Lemon(pattern="Assertions Expr(x)")]
		public Assertions._3(Parser h,Expr x) {}
		[Lemon(pattern="Assertions Identifier")]
		public Assertions._4(Parser h) {}
	}
	
	public class PreCond : Assertions {
		private PreCond(Classified c) { base(c); }

		[Lemon(pattern="REQUIRE")]
		public PreCond._1(Parser h) {}
		[Lemon(pattern="REQUIRE ELSE")]
		public PreCond._2(Parser h) {}
		[Lemon(pattern="REQUIRE Assertions")]
		public PreCond._3(Parser h) {}
		[Lemon(pattern="REQUIRE ELSE Assertions")]
		public PreCond._4(Parser h) {}
	}

	public class PostCond : Assertions {
		private PostCond(Classified c) { base(c); }

		[Lemon(pattern="ENSURE")]
		public PostCond._1(Parser h) {}
		[Lemon(pattern="ENSURE THEN")]
		public PostCond._2(Parser h) {}
		[Lemon(pattern="ENSURE Assertions")]
		public PostCond._3(Parser h) {}
		[Lemon(pattern="ENSURE THEN Assertions")]
		public PostCond._4(Parser h) {}
	}

	public class Invariant : Assertions {
		private Invariant(Classified c) { base(c); }

		[Lemon(pattern="")]
		public Invariant._0(Parser h) {}
		[Lemon(pattern="INVARIANT")]
		public Invariant._1(Parser h) {}
		[Lemon(pattern="INVARIANT Assertions")]
		public Invariant._2(Parser h) {}
	}

	public class Variant : Classified {
		private Variant(Classified c) { base(c); }

		[Lemon(pattern="")]
		public Variant._0(Parser h) {}
		[Lemon(pattern="VARIANT Expr(x)")]
		public Variant._1(Parser h) {}
		[Lemon(pattern="VARIANT Identifier COLON Expr(x)")]
		public Variant._2(Parser h) {}
	}

	public class Assigner : Classified {

		[Lemon(pattern="")]
			public Assigner._1(Parser h) {}
		[Lemon(pattern="ASSIGN FeatureName(fn)")]
			public Assigner._2(Parser h,FeatureName fn) {}
	}

	public class FeatureName : Classified {
		private FeatureName(Classified c) { base(c); }
		
		[Lemon(pattern="Identifier(i)")]
			public FeatureName._1(Parser h,Token i) {}
		[Lemon(pattern="Identifier(i) INFIX QUOTE BinaryOperator(op) QUOTE")]
			public FeatureName._2(Parser h,Token i) {}
		[Lemon(pattern="Identifier(i) PREFIX QUOTE FREE_OP(op) QUOTE")]
			public FeatureName._3(Parser h,Token i) {}
		[Lemon(pattern="Identifier(i) PREFIX QUOTE NOT(op) QUOTE")]
			public FeatureName._4(Parser h,Token i) {}
		[Lemon(pattern="Identifier(i) PREFIX QUOTE PLUS(op) QUOTE")]
			public FeatureName._5(Parser h,Token i) {}
		[Lemon(pattern="Identifier(i) PREFIX QUOTE MINUS(op) QUOTE")]
			public FeatureName._6(Parser h,Token i) {}
	}

	public class ExtFeatureName : FeatureName {
		private ExtFeatureName(Classified c) { base(c); }
		
		[Lemon(pattern="FeatureName(fn)")]
		public ExtFeatureName._1(Parser h,FeatureName fn) {}
		[Lemon(pattern="Identifier(i) ALIAS AliasName(an)")]
		public ExtFeatureName._2(Parser h,Token i, AliasName an) {}
	}

	public class AliasName : FeatureName {
		private AliasName(Classified c) { base(c); }
		
		[Lemon(pattern="")]
		public AliasName._1(Parser h,FeatureName fn) {}
		[Lemon(pattern="Identifier(i) ALIAS QUOTE BinaryOperator(op) QUOTE")]
		public AliasName._2(Parser h,Token i, BinaryOperator op) {}
		[Lemon(pattern="Identifier(i) ALIAS QUOTE NOT(op) QUOTE")]
		public AliasName._3(Parser h,Token i, Token op) {}
		[Lemon(pattern="Identifier(i) ALIAS QUOTE FREE_OP(op) QUOTE")]
		public AliasName._4(Parser h,Token i, Token op) {}
		[Lemon(pattern="Identifier(i) ALIAS QUOTE BRACKETS QUOTE")]
		public AliasName._5(Parser h,Token i) {}
	}
	
	public class BinaryOperator : Classified {
		private BinaryOperator(Classified c) { base(c); }
		
		[Lemon(pattern="PLUS(op)")]
		public BinaryOperator._1(Parser h,Token op) {}
		[Lemon(pattern="MINUS(op)")]
		public BinaryOperator._2(Parser h,Token op) {}
		[Lemon(pattern="TIMES(op)")]
		public BinaryOperator._3(Parser h,Token op) {}
		[Lemon(pattern="DIV(op)")]
		public BinaryOperator._4(Parser h,Token op) {}
		[Lemon(pattern="IDIV(op)")]
		public BinaryOperator._5(Parser h,Token op) {}
		[Lemon(pattern="IMOD(op)")]
		public BinaryOperator._6(Parser h,Token op) {}
		[Lemon(pattern="LT(op)")]
		public BinaryOperator._7(Parser h,Token op) {}
		[Lemon(pattern="LE(op)")]
		public BinaryOperator._8(Parser h,Token op) {}
		[Lemon(pattern="EQ(op)")]
		public BinaryOperator._9(Parser h,Token op) {}
		[Lemon(pattern="NE(op)")]
		public BinaryOperator._10(Parser h,Token op) {}
		[Lemon(pattern="GE(op)")]
		public BinaryOperator._11(Parser h,Token op) {}
		[Lemon(pattern="GT(op)")]
		public BinaryOperator._12(Parser h,Token op) {}
		[Lemon(pattern="SIM(op)")]
		public BinaryOperator._13(Parser h,Token op) {}
		[Lemon(pattern="NSIM(op)")]
		public BinaryOperator._14(Parser h,Token op) {}
		[Lemon(pattern="AND(op)")]
		public BinaryOperator._15(Parser h,Token op) {}
		[Lemon(pattern="AND_THEN(op)")]
		public BinaryOperator._16(Parser h,Token op) {}
		[Lemon(pattern="OR(op)")]
		public BinaryOperator._17(Parser h,Token op) {}
		[Lemon(pattern="OR_ELSE(op)")]
		public BinaryOperator._18(Parser h,Token op) {}
		[Lemon(pattern="XOR(op)")]
		public BinaryOperator._19(Parser h,Token op) {}
		[Lemon(pattern="IMPLIES(op)")]
		public BinaryOperator._20(Parser h,Token op) {}
		[Lemon(pattern="DOTDOT(op)")]
		public BinaryOperator._21(Parser h,Token op) {}
	}

	public class FormalArgs : Classified {
		private FormalArgs(Classified c) { base(c); }
		
		[Lemon(pattern="LPAREN RPAREN")]
		public FormalArgs._1(Parser h) {}
		[Lemon(pattern="LeftParen FormalArgList")]
		public FormalArgs._2(Parser h) {}
	}

	public class LeftParen : Classified {
		private LeftParen(Classified c) { base(c); }
		
		[Lemon(pattern="LPAREN")]
			public LeftParen._1(Parser h) {}
	}

	public class FormalArgList : Classified {
		private FormalArgList(Classified c) { base(c); }
		
		[Lemon(pattern="FormalArg(fa) PAREN")]
			public FormalArgList._1(Parser h,FormalArg fa) {}
		[Lemon(pattern="FormalArg(fa) COMMA FormalArgList")]
			public FormalArgList._2(Parser h,FormalArg fa) {}
	}

	public class FormalArg : Classified {
		private FormalArg(Classified c) { base(c); }
		
		[Lemon(pattern="Identifier(i) COLON Typ(t)")]
			public FormalArg._1(Parser h,Token i, Typ t) {}
	}

	public class LocalDecl : Classified {
		private LocalDecl(Classified c) { base(c); }
		
		[Lemon(pattern="")]
			public LocalDecl._1(Parser h) {}
		[Lemon(pattern="LOCAL")]
			public LocalDecl._2(Parser h) {}
		[Lemon(pattern="LOCAL LocalList")]
			public LocalDecl._3(Parser h) {}
	}

	public class LocalList : Classified {
		private LocalList(Classified c) { base(c); }
		
		[Lemon(pattern="Locals")]
			public LocalList._1(Parser h) {}
		[Lemon(pattern="Locals LocalList")]
			public LocalList._2(Parser h) {}
	}

	public class Locals : Classified {
		private Locals(Classified c) { base(c); }
		
		[Lemon(pattern="LocalVar(l)")]
			public Locals._1(Parser h,Local l) {}
		[Lemon(pattern="LocalVar(l) COMMA Locals")]
			public Locals._2(Parser h,Local l) {}
	}

	public class LocalVar : Classified {
		private LocalVar(Classified c) { base(c); }
		
		[Lemon(pattern="Identifier(i) COLON Typ(t)")]
			public LocalVar._1(Parser h,Token i, Typ t) {}
	}

	public class ClassName : Classified {
		private ClassName(Classified c) { base(c); }

		internal string cn;

		[Lemon(pattern="Identifier(i)")]
		public ClassName._1(Parser h,Token i) {}
	}

	public class Typ : Classified {
		private Typ(Classified c) { base(c); }
		
		[Lemon(pattern="DirectTyp(dt)")]
			public Typ._1(Parser h,DirectTyp dt) {}
		[Lemon(pattern="EXPANDED DirectTyp(dt)")]
			public Typ._2(Parser h,ClassName cn) {}
		[Lemon(pattern="SEPARATE DirectTyp(dt)")]
			public Typ._3(Parser h,ClassName cn) {}
		[Lemon(pattern="ATTACHED DirectTyp(dt)")]
			public Typ._4(Parser h,ClassName cn) {}
		[Lemon(pattern="DETACHABLE DirectTyp(dt)")]
			public Typ._5(Parser h,ClassName cn) {}
		[Lemon(pattern="QUESTION_MARK DirectTyp(dt)")]
			public Typ._6(Parser h,ClassName cn) {}
		[Lemon(pattern="EXCLAMATION_MARK DirectTyp(dt)")]
			public Typ._7(Parser h,ClassName cn) {}
	}

	public class DirectTyp : Classified {
		private DirectTyp(Classified c) { base(c); }
		
		[Lemon(pattern="ClassName(cn)")]
			public DirectTyp._1(Parser h,ClassName cn) {}
		[Lemon(pattern="ClassName(cn) ActualParams")]
			public DirectTyp._2(Parser h,ClassName cn) {}
		[Lemon(pattern="TUPLE LBRACKET RBRACKET")]
			public DirectTyp._3(Parser h) {}
		[Lemon(pattern="TUPLE LBRACKET ActualParamList RBRACKET")]
			public DirectTyp._4(Parser h) {}
		[Lemon(pattern="TUPLE LBRACKET FormalArgList RBRACKET")]
			public DirectTyp._5(Parser h,ClassName cn) {}
		[Lemon(pattern="AnchoredTyp")]
			public DirectTyp._6(Parser h) {}
	}

	public class AnchoredTyp : Classified {
		private AnchoredTyp(Classified c) { base(c); }

		[Lemon(pattern="LIKE Identifier(i)")]
			public AnchoredTyp._1(Parser h,Token i) {}
		[Lemon(pattern="LIKE CURRENT")]
			public AnchoredTyp._2(Parser h) {}
		[Lemon(pattern="LIKE LBRACE Typ(t) RBRACE DOT Identifier(i)")]
			public AnchoredTyp._3(Parser h,Typ t, Token i) {}
		[Lemon(pattern="LIKE AnchoredTyp DOT Identifier(i)")]
			public AnchoredTyp._4(Parser h,Token i) {}
	}

	public class ActualParams : Classified {
		private ActualParams(Classified c) { base(c); }

		[Lemon(pattern="LBRACKET ActualParamList")]
		public ActualParams._1(Parser h) {}
	}

	public class ActualParamList : Classified {

		[Lemon(pattern="Typ(t) RBRACKET")]
		public ActualParamList._1(Parser h,Typ t) {}
		[Lemon(pattern="Typ(t) COMMA ActualParamList")]
		public ActualParamList._2(Parser h,Typ t) {}
		[Lemon(pattern="TUPLE(t) COMMA ActualParamList")]
		public ActualParamList._3(Parser h,Token t) {}
	}

	public class Combound : Classified {

		[Lemon(pattern="")]
		public Combound._0(Parser h) {}
		[Lemon(pattern="InstructionList")]
		public Combound._1(Parser h) {}
	}

	public class ExplicitCombound : Combound {

//		[Lemon(pattern="")]
//		public ExplicitCombound._0(Parser h) {}
		[Lemon(pattern="Combound")]
		public ExplicitCombound._1(Parser h) {}
	}

	public class DoCombound : Combound {

		[Lemon(pattern="DO Combound")]
		public DoCombound._1(Parser h) {}
	}

	public class OnceCombound : Combound {

		[Lemon(pattern="ONCE Combound")]
		public OnceCombound._1(Parser h) {}
	}

	public class DeferredCombound : Combound {

		[Lemon(pattern="DEFERRED Combound")]
		public DeferredCombound._1(Parser h) {}
	}

	public class AttributeCombound : Combound {

		[Lemon(pattern="ATTRIBUTE Combound")]
		public AttributeCombound._1(Parser h) {}
	}


	public class ThenCombound : Combound {

		[Lemon(pattern="THEN Combound")]
		public ThenCombound._1(Parser h) {}
	}

	public class ExplicitThenCombound : Combound {

		[Lemon(pattern="THEN ExplicitCombound")]
		public ExplicitThenCombound._1(Parser h) {}
	}

	public class ElseCombound : Combound {

		[Lemon(pattern="ELSE Combound")]
		public ElseCombound._1(Parser h) {}
	}

	public class ExplicitElseCombound : Combound {

		[Lemon(pattern="ELSE ExplicitCombound")]
		public ExplicitElseCombound._1(Parser h) {}
	}

	public class FromCombound : Combound {

		[Lemon(pattern="")]
		public FromCombound._0(Parser h) {}
		[Lemon(pattern="FROM Combound")]
		public FromCombound._1(Parser h) {}
	}

	public class LoopCombound : Combound {

		[Lemon(pattern="LOOP Combound")]
		public LoopCombound._1(Parser h) {}
	}

	public class InstructionList : Classified {

		[Lemon(pattern="Instruction")]
		public InstructionList._1(Parser h) {}
	}

	public class Instruction : Classified {

		[Lemon(pattern="CreateInstruction")]
		public Instruction._1(Parser h) {}
		[Lemon(pattern="CallInstruction")]
		public Instruction._2(Parser h) {}
		[Lemon(pattern="Writable ASSIGN Expr")]
		public Instruction._4(Parser h) {}
		[Lemon(pattern="BracketExpr ASSIGN Expr")]
		public Instruction._5(Parser h) {}
		[Lemon(pattern="Conditional")]
		public Instruction._6(Parser h) {}
		[Lemon(pattern="MultiBranch")]
		public Instruction._7(Parser h) {}
		[Lemon(pattern="FromCombound Invariant Variant UNTIL Expr LoopCombound END")]
		public Instruction._8(Parser h) {}
		[Lemon(pattern="FromCombound Invariant UNTIL Expr LoopCombound Variant END")]
		public Instruction._9(Parser h) {}
		[Lemon(pattern="AcrossHeader FromCombound Invariant UntilExpr LoopCombound Variant END")]
		public Instruction._10(Parser h) {}
		[Lemon(pattern="DebugInstruction")]
		public Instruction._11(Parser h) {}
		[Lemon(pattern="CheckInstruction")]
		public Instruction._12(Parser h) {}
		[Lemon(pattern="RETRY")]
		public Instruction._13(Parser h) {}
	}

	public class CheckInstruction : Instruction {

		[Lemon(pattern="CHECK END")]
		public CheckInstruction._1(Parser h) {}
		[Lemon(pattern="CHECK Assertions END")]
		public CheckInstruction._2(Parser h) {}
		[Lemon(pattern="CHECK ExplicitThenCombound END")]
		public CheckInstruction._3(Parser h) {}
		[Lemon(pattern="CHECK Assertions ExplicitThenCombound END")]
		public CheckInstruction._4(Parser h) {}
	}

	public class CreateInstruction : Instruction {

		[Lemon(pattern="EXPLAMATION_MARK Typ(t) EXCLAMATON_MARK Writable(w)")]
		public CreateInstruction._1(Parser h,Typ t, Writable w) {}
		[Lemon(pattern="EXPLAMATION_MARK Typ(t) EXCLAMATON_MARK Writable(w) DOT Actuals")]
		public CreateInstruction._2(Parser h,Typ t, Writable w) {}
		[Lemon(pattern="EXPLAMATION_MARK EXCLAMATON_MARK Identifier(i)")]
		public CreateInstruction._3(Parser h,Token i) {}
		[Lemon(pattern="EXPLAMATION_MARK EXCLAMATON_MARK Identifier(i) DOT Actuals")]
		public CreateInstruction._4(Parser h,Token i) {}
		[Lemon(pattern="CREATE LBRACE Typ(t) RBRACE Writable(w)")]
		public CreateInstruction._5(Parser h,Typ t, Writable w) {}
		[Lemon(pattern="CREATE LBRACE Typ(t) RBRACE Writable(w) DOT Actuals")]
		public CreateInstruction._6(Parser h,Typ t, Writable w) {}
		[Lemon(pattern="CREATE Writable(w)")]
		public CreateInstruction._7(Parser h,Writable w) {}
		[Lemon(pattern="CREATE Writable(w) DOT Identifier(i) Actuals")]
		public CreateInstruction._8(Parser h,Writable w) {}
	}

	public class CreateExpr : Expr {

		[Lemon(pattern="CREATE LBRACE Typ(t) RBRACE")]
		public CreateExpr._1(Parser h,Typ t) {}
		[Lemon(pattern="CREATE LBRACE Typ(t) RBRACE DOT Identifier(i) Actuals")]
		public CreateExpr._2(Parser h,Typ t, Token i) {}
	}

	public class Conditional : Instruction {

		[Lemon(pattern="IF Expr(x) ThenCombound END")]
		public Conditional._1(Parser h,Expr x) {}
		[Lemon(pattern="IF Expr(x) ThenCombound ElseCombound END")]
		public Conditional._2(Parser h,Expr x) {}
		[Lemon(pattern="IF Expr(x) ThenCombound ElseifList END")]
		public Conditional._3(Parser h,Expr x) {}
		[Lemon(pattern="IF Expr(x) ThenCombound ElseifList ElseCombound END")]
		public Conditional._4(Parser h,Expr x) {}
	}

	public class ElseifList : Classified {

		[Lemon(pattern="Elseif")]
		public ElseifList._1(Parser h) {}
		[Lemon(pattern="Elseif ElseifList")]
		public ElseifList._2(Parser h) {}
	}

	public class Elseif : Classified {

		[Lemon(pattern="ELSEIF Expr(x) ThenCombound END")]
		public Elseif._1(Parser h,Expr x) {}
	}

	public class MultiBranch : Instruction {

		[Lemon(pattern="INSPECT Expr(x) WhenList ExplicitElseCombound END")]
		public MultiBranch._1(Parser h,Expr x) {}
	}

	public class WhenList : Classified {

		[Lemon(pattern="")]
		public WhenList._0(Parser h) {}
		[Lemon(pattern="WhenPart")]
		public WhenList._1(Parser h) {}
		[Lemon(pattern="WhenList WhenPart")]
		public WhenList._2(Parser h) {}
	}

	public class WhenPart : Classified {

		[Lemon(pattern="Choices ThenCombound")]
		public WhenPart._1(Parser h) {}
	}

	public class Choices : Classified {

		[Lemon(pattern="WHEN")]
		public Choices._0(Parser h) {}
		[Lemon(pattern="WHEN ChoiceList")]
		public Choices._1(Parser h) {}
	}

	public class ChoiceList : Classified {

		[Lemon(pattern="Choice")]
		public ChoiceList._1(Parser h) {}
		[Lemon(pattern="Choice COMMA ChoiceList")]
		public ChoiceList._2(Parser h) {}
	}

	public class Choice : Classified {

		[Lemon(pattern="ChoiceConstant")]
		public Choice._1(Parser h) {}
		[Lemon(pattern="ChoiceConstant DOTDOT ChoiceConstant")]
		public Choice._2(Parser h) {}
	}

	public class ChoiceConstant : Classified {

		[Lemon(pattern="ManifestConstant(m)")]
		public ChoiceConstant._1(Parser h,ManifestConstant m) {}
		[Lemon(pattern="Identifier(i)")]
		public ChoiceConstant._2(Parser h,Token i) {}
		[Lemon(pattern="StaticCallExpr(x)")]
		public ChoiceConstant._3(Parser h,StaticCallExpr x) {}
	}

	public class AcrossHeader : Classified {

		[Lemon(pattern="ACROSS Expr(x) AS Identifier(i)")]
		public AcrossHeader._1(Parser h,Expr x, Token i) {}
	}

	public class UntilExpr : Expr {

		[Lemon(pattern="")]
		public UntilExpr._0(Parser h) {}
		[Lemon(pattern="UNTIL Expr(x)")]
		public UntilExpr._1(Parser h,Expr x) {}
	}

	public class DebugInstruction : Instruction {

		[Lemon(pattern="DEBUG ParenStringList Combound END")]
		public DebugInstruction._1(Parser h) {}
	}

	public class ParenStringList : Classified {

		[Lemon(pattern="")]
		public ParenStringList._0(Parser h) {}
		[Lemon(pattern="LPAREN RPAREN")]
		public ParenStringList._1(Parser h) {}
		[Lemon(pattern="LPAREN ManifestStringList")]
		public ParenStringList._3(Parser h) {}
	}

	public class ManifestStringList : Classified {

		[Lemon(pattern="UntypedManifestString RPAREN")]
		public ManifestStringList._1(Parser h) {}
		[Lemon(pattern="UntypedManifestString COMMA ManifestStringList")]
		public ManifestStringList._3(Parser h) {}
	}

	public class CallInstruction : Instruction {

		[Lemon(pattern="Identifier(i) Actuals")]
		public CallInstruction._1(Parser h,Token i) {}
		[Lemon(pattern="TypedCallChain DOT Identifier(i) Actuals")]
		public CallInstruction._2(Parser h,Token i) {}
		[Lemon(pattern="Identifier(i) UntypedCallChain Actuals")]
		public CallInstruction._3(Parser h,Token i) {}
		[Lemon(pattern="PRECURSOR Actuals")]
		public CallInstruction._4(Parser h) {}
		[Lemon(pattern="PRECURSOR LBRACE ClassName(cn) RBRACE Actuals")]
		public CallInstruction._5(Parser h,ClassName cn) {}
		[Lemon(pattern="FEATURE LBRACE Typ(t) RBRACE DOT Identifier(i) Actuals")]
		public CallInstruction._6(Parser h,Typ t, Token i) {}
		[Lemon(pattern="LBRACE Typ(t) RBRACE DOT Identifier(i) Actuals")]
		public CallInstruction._7(Parser h,Token i) {}
	}

	public class Rescue : Instruction {

		[Lemon(pattern="")]
		public Rescue._1(Parser h) {}
		[Lemon(pattern="RESCUE Combound")]
		public Rescue._2(Parser h) {}
	}

	public class UntypedCallExpr : Expr {

		[Lemon(pattern="Identifier(i) Actuals")]
		public UntypedCallExpr._1(Parser h,Token i) {}
		[Lemon(pattern="UntypedCallChain DOT Identifier(i) Actuals")]
		public UntypedCallExpr._2(Parser h,Token i) {}
	}	

	public class TypedCallExpr : Expr {

		[Lemon(pattern="TypedCallChain DOT Identifier(i) Actuals")]
		public TypedCallExpr._1(Parser h,Token i) {}
	}	

	public class StaticCallExpr : Expr {

		[Lemon(pattern="FEATURE LBRACE Typ(t) RBRACE DOT Identifier(i) Actuals")]
		public StaticCallExpr._1(Parser h,Typ t, Token i) {}
		[Lemon(pattern="LBRACE Typ(t) RBRACE DOT Identifier(i) Actuals")]
		public StaticCallExpr._2(Parser h,Typ t, Token i) {}
	}	

	public class PrecursorExpr : Expr {

		[Lemon(pattern="PRECURSOR Actuals")]
		public PrecursorExpr._1(Parser h) {}
		[Lemon(pattern="PRECURSOR LBRACE ClassName(cn) RBRACE Actuals")]
		public PrecursorExpr._3(Parser h,ClassName cn) {}
	} 

	public class UntypedCallChain : Classified {

		[Lemon(pattern="Identifier(i) Actuals")]
		public UntypedCallChain._1(Parser h,Token i) {}
		[Lemon(pattern="RESULT")]
		public UntypedCallChain._2(Parser h) {}
		[Lemon(pattern="CURRENT")]
		public UntypedCallChain._3(Parser h) {}
		[Lemon(pattern="ParenExpr(x)")]
		public UntypedCallChain._4(Parser h,ParenExpr x) {}
		[Lemon(pattern="PrecursorExpr(x)")]
		public UntypedCallChain._5(Parser h,Expr x) {}
		[Lemon(pattern="UntypedBracketExpr(x)")]
		public UntypedCallChain._6(Parser h,UntypedBracketExpr x) {}
		[Lemon(pattern="StaticCallExpr(x)")]
		public UntypedCallChain._7(Parser h,StaticCallExpr x) {}
		[Lemon(pattern="UntypedCallChain Identifier(i) DOT Actuals")]
		public UntypedCallChain._8(Parser h,Token i) {}
	} 

	public class TypedCallChain : Classified {

		[Lemon(pattern="TypedBracketExpr(x)")]
		public TypedCallChain._1(Parser h,Expr x) {}
		[Lemon(pattern="TypedCallChain Identifier(i) Actuals")]
		public TypedCallChain._2(Parser h,Token i) {}
	} 

	public class Actuals : Classified {

		[Lemon(pattern="")]
		public Actuals._0(Parser h) {}
		[Lemon(pattern="LPAREN RPAREN")]
		public Actuals._1(Parser h) {}
		[Lemon(pattern="LPAREN ActualList")]
		public Actuals._2(Parser h) {}
	} 

	public class ActualList : Classified {

		[Lemon(pattern="Expr(x) RPAREN")]
		public ActualList._1(Parser h,Expr x) {}
		[Lemon(pattern="Expr(x) COMMA ActualList")]
		public ActualList._2(Parser h,Expr x) {}
	} 

	public class Address : Expr {

		[Lemon(pattern="DOLLAR FeatureName(fn)")]
		public Address._1(Parser h,FeatureName fn) {}
		[Lemon(pattern="DOLLAR CURRENT")]
		public Address._2(Parser h) {}
		[Lemon(pattern="DOLLAR RESULT")]
		public Address._3(Parser h) {}
		[Lemon(pattern="DOLLAR ParenExpr(x)")]
		public Address._4(Parser h,ParenExpr x) {}
	} 

	public class Writable : Expr {

		[Lemon(pattern="Identifier(i)")]
		public Writable._1(Parser h,Token i) {}
		[Lemon(pattern="RESULT")]
		public Writable._2(Parser h) {}
	}

	public class Expr : Classified {

		[Lemon(pattern="BinaryExpr(x)")]
		public Expr._1(Parser h,BinaryExpr x) {}
		[Lemon(pattern="NonBinaryExpr(x)")]
		public Expr._2(Parser h,NonBinaryExpr x) {}
	}

	public class BinaryExpr : Expr {

		[Lemon(pattern="Expr(l) FREE_OP(op) Expr(r)")]
		public BinaryExpr._1(Parser h,Expr l, Token op, Expr r) {}
		[Lemon(pattern="Expr(l) BinaryOperator(op) Expr(r)")]
		public BinaryExpr._2(Parser h,Expr l, Token op, Expr r) {}
	}

	public class NonBinaryExpr : Expr {

		[Lemon(pattern="NonBinaryAndTypedExpr(x)")]
		public NonBinaryExpr._1(Parser h,NonBinaryAndTypedExpr x) {}
 		[Lemon(pattern="TypedIntConstant")]
		public NonBinaryExpr._2(Parser h) {}
		[Lemon(pattern="TypedRealConstant")]
		public NonBinaryExpr._3(Parser h) {}
		[Lemon(pattern="TypedBracketTarget")]
		public NonBinaryExpr._4(Parser h) {}
		[Lemon(pattern="TypedBracketExpr(x)")]
		public NonBinaryExpr._5(Parser h,TypedBracketTarget x) {}
		[Lemon(pattern="LBRACE Typ(t) RBRACE")]
		public NonBinaryExpr._6(Parser h,Typ t) {}		
	}

	public class NonBinaryAndTypedExpr : Expr {

		[Lemon(pattern="UntypedBracketTarget(x)")]
		public NonBinaryAndTypedExpr._1(Parser h,UntypedBracketTarget x) {}
		[Lemon(pattern="CreateExpr(x)")]
		public NonBinaryAndTypedExpr._2(Parser h,CreateExpr x) {}
		[Lemon(pattern="AcrossSome(x)")]
		public NonBinaryAndTypedExpr._3(Parser h,AcrossSome x) {}
		[Lemon(pattern="AcrossAll(x)")]
		public NonBinaryAndTypedExpr._4(Parser h,AcrossAll x) {}
		[Lemon(pattern="ManifestTuple")]
		public NonBinaryAndTypedExpr._5(Parser h) {}
		[Lemon(pattern="INTEGER")]
		public NonBinaryAndTypedExpr._6(Parser h) {}
		[Lemon(pattern="REAL")]
		public NonBinaryAndTypedExpr._7(Parser h) {}
		[Lemon(pattern="PLUS(op) NonBinaryExpr(r)",prec="NOT")]
		public NonBinaryAndTypedExpr._8(Parser h,Token op, NonBinaryExpr r) {}
		[Lemon(pattern="MINUS(op) NonBinaryExpr(r)",prec="NOT")]
		public NonBinaryAndTypedExpr._9(Parser h,Token op, NonBinaryExpr r) {}
		[Lemon(pattern="NOT(op) NonBinaryExpr(r)")]
		public NonBinaryAndTypedExpr._10(Parser h,Token op, NonBinaryExpr r) {}
		[Lemon(pattern="FREE_OP(op) NonBinaryExpr(r)")]
		public NonBinaryAndTypedExpr._11(Parser h,Token op, NonBinaryExpr r) {}
		[Lemon(pattern="OLD NonBinaryExpr(r)")]
		public NonBinaryAndTypedExpr._12(Parser h,NonBinaryExpr r) {}
		[Lemon(pattern="LBRACE Identifier COLON Typ(t) RBRACE NonBinaryExpr(r)")]
		public NonBinaryAndTypedExpr._13(Parser h,Typ t, NonBinaryExpr r) {}
		[Lemon(pattern="ATTACHED NonBinaryAndTypedExpr(r)")]
		public NonBinaryAndTypedExpr._14(Parser h,NonBinaryAndTypedExpr r) {}
		[Lemon(pattern="ATTACHED LBRACE Typ(t) RBRACE NonBinaryAndTypedExpr")]
		public NonBinaryAndTypedExpr._15(Parser h,Typ t, NonBinaryAndTypedExpr r) {}
		[Lemon(pattern="ATTACHED NonBinaryAndTypedExpr(r) AS Identifier")]
		public NonBinaryAndTypedExpr._16(Parser h,NonBinaryAndTypedExpr r) {}
		[Lemon(pattern="ATTACHED LBRACE Typ(t) RBRACE NonBinaryAndTypedExpr(r) AS Identifier")]
		public NonBinaryAndTypedExpr._17(Parser h) {}
	}

	public class UntypedBracketTarget : Expr {

		[Lemon(pattern="UntypedCallExpr(x)")]
		public UntypedBracketTarget._1(Parser h,UntypedCallExpr x) {}
		[Lemon(pattern="StaticCallExpr(x)")]
		public UntypedBracketTarget._2(Parser h,StaticCallExpr x) {}
		[Lemon(pattern="PrecursorExpr(x)")]
		public UntypedBracketTarget._3(Parser h,PrecursorExpr x) {}
		[Lemon(pattern="CRURRENT")]
		public UntypedBracketTarget._4(Parser h) {}
		[Lemon(pattern="RESULT")]
		public UntypedBracketTarget._5(Parser h) {}
		[Lemon(pattern="ParenExpr(x)")]
		public UntypedBracketTarget._6(Parser h,ParenExpr x) {}
		[Lemon(pattern="CallAgent(x)")]
		public UntypedBracketTarget._7(Parser h,CallAgent x) {}
		[Lemon(pattern="InlineAgent(x)")]
		public UntypedBracketTarget._8(Parser h,InlineAgent x) {}
		[Lemon(pattern="VOID")]
		public UntypedBracketTarget._9(Parser h) {}
		[Lemon(pattern="UntypedCharConstant")]
		public UntypedBracketTarget._10(Parser h,Expr x) {}
		[Lemon(pattern="UntypedManifestString")]
		public UntypedBracketTarget._11(Parser h,Expr x) {}
		[Lemon(pattern="ONCE_STRING STRING")]
		public UntypedBracketTarget._12(Parser h,Expr x) {}
		[Lemon(pattern="ManifestArray(x)")]
		public UntypedBracketTarget._13(Parser h,ManifestArray x) {}
		[Lemon(pattern="Address(x)")]
		public UntypedBracketTarget._14(Parser h,Address x) {}
	}

	public class TypedBracketTarget : Expr {

		[Lemon(pattern="TypedCallExpr(x)")]
		public TypedBracketTarget._1(Parser h,TypedCallExpr x) {}
		[Lemon(pattern="TypedManifestString")]
		public TypedBracketTarget._2(Parser h) {}
		[Lemon(pattern="TypedCharConstant")]
		public TypedBracketTarget._3(Parser h) {}
	}

	public class BracketExpr : Expr {

		[Lemon(pattern="TypedBracketExpr(x)")]
		public BracketExpr._1(Parser h,TypedBracketExpr x) {}
		[Lemon(pattern="UntypedBracketExpr(x)")]
		public BracketExpr._2(Parser h,UntypedBracketExpr x) {}
	}

	public class TypedBracketExpr : BracketExpr {

		[Lemon(pattern="TypedBracketTarget(x) LBRACKET BracketActualList")]
		public TypedBracketExpr._1(Parser h,TypedBracketTarget x) {}
	}

	public class UntypedBracketExpr : BracketExpr {

		[Lemon(pattern="UntypedBracketTarget(x) LBRACKET BracketActualList")]
		public UntypedBracketExpr._1(Parser h,UntypedBracketTarget x) {}
	}

	public class BracketActualList : Classified {

		[Lemon(pattern="Expr(x) RBRACKET")]
		public BracketActualList._1(Parser h,Expr x) {}
		[Lemon(pattern="Expr(x) COMMA BracketActualList")]
		public BracketActualList._2(Parser h,Expr x) {}
	}

	public class ParenExpr : Expr {

		[Lemon(pattern="LeftParen Expr(x) RPAREN")]
		public ParenExpr._1(Parser h,Expr x) {}
	}

	public class ManifestArray : Expr {

		[Lemon(pattern="LBRACKET RMA")]
		public ManifestArray._1(Parser h) {}
		[Lemon(pattern="LBRACKET ManifestArrayList")]
		public ManifestArray._2(Parser h) {}
	}

	public class ManifestArrayList : Expr {

		[Lemon(pattern="Expr(x) RMA")]
		public ManifestArrayList._1(Parser h,Expr x) {}
		[Lemon(pattern="Expr(x) COMMA ManifestArrayList")]
		public ManifestArrayList._2(Parser h,Expr x) {}
	}

	public class ManifestTuple : Expr {

		[Lemon(pattern="LBRACKET RBRACKET")]
		public ManifestTuple._1(Parser h) {}
		[Lemon(pattern="LBRACKET ManifestTupleList")]
		public ManifestTuple._2(Parser h) {}
	}

	public class ManifestTupleList : Expr {

		[Lemon(pattern="Expr(x) RBRACKET")]
		public ManifestTupleList._1(Parser h,Expr x) {}
		[Lemon(pattern="Expr(x) COMMA ManifestTupleList")]
		public ManifestTupleList._2(Parser h,Expr x) {}
	}

	public class ManifestConstant : Expr {

		[Lemon(pattern="BoolConstant")]
		public ManifestConstant._1(Parser h) {}
		[Lemon(pattern="CharConstant")]
		public ManifestConstant._2(Parser h) {}
		[Lemon(pattern="IntConstant")]
		public ManifestConstant._3(Parser h) {}
		[Lemon(pattern="RealConstant")]
		public ManifestConstant._4(Parser h) {}
		[Lemon(pattern="ManifestString")]
		public ManifestConstant._5(Parser h) {}
	}

	public class AcrossSome : Expr {

		[Lemon(pattern="AcrossHeader Invariant UntilExpr SOME Expr(x) Variant END")]
		public AcrossSome._1(Parser h,Expr x) {}
	}

	public class AcrossAll : Expr {

		[Lemon(pattern="AcrossHeader Invariant UntilExpr ALL Expr(x) Variant END")]
		public AcrossAll._1(Parser h,Expr x) {}
	}

	public class CallAgent : Expr {

		[Lemon(pattern="AGENT FeatureName(fn) AgentActuals")]
		public CallAgent._1(Parser h,FeatureName fn) {}
		[Lemon(pattern="AGENT AgentTarget DOT FeatureName(fn) AgentActuals")]
		public CallAgent._2(Parser h,FeatureName fn) {}
	}

	public class InlineAgent : Expr {

		[Lemon(pattern="InlineAgentNoActuals AgentActuals")]
		public InlineAgent._1(Parser h) {}
	}

	public class InlineAgentNoActuals : Classified {

		[Lemon(pattern="AGENT NoInlineAgentFormalArgs COLON Typ(t) PreCond LocalDecl DoCombound PostCond Rescue END")]
		public InlineAgentNoActuals._1(Parser h,Typ t) {}
		[Lemon(pattern="AGENT InlineAgentFormalArgs COLON Typ(t) PreCond LocalDecl DoCombound PostCond Rescue END")]
		public InlineAgentNoActuals._2(Parser h,Typ t) {}
		[Lemon(pattern="AGENT NoInlineAgentFormalArgs COLON Typ(t) PreCond LocalDecl ONCE ParenStringList Combound PostCond Rescue END")]
		public InlineAgentNoActuals._3(Parser h,Typ t) {}
		[Lemon(pattern="AGENT InlineAgentFormalArgs COLON Typ(t) PreCond LocalDecl ONCE ParenStringList PostCond Rescue END")]
		public InlineAgentNoActuals._4(Parser h,Typ t) {}
		[Lemon(pattern="AGENT NoInlineAgentFormalArgs COLON Typ(t) PreCond EXTERNAL UntypedManifestString ExternalName PostCond Rescue END")]
		public InlineAgentNoActuals._5(Parser h,Typ t) {}
		[Lemon(pattern="AGENT InlineAgentFormalArgs COLON Typ(t) PreCond EXTERNAL UntypedManifestString ExternalName PostCond Rescue END")]
		public InlineAgentNoActuals._6(Parser h,Typ t) {}
		
		[Lemon(pattern="AGENT NoInlineAgentFormalArgs PreCond LocalDecl DoCombound PostCond Rescue END")]
		public InlineAgentNoActuals._7(Parser h) {}
		[Lemon(pattern="AGENT InlineAgentFormalArgs PreCond LocalDecl DoCombound PostCond Rescue END")]
		public InlineAgentNoActuals._8(Parser h) {}
		[Lemon(pattern="AGENT NoInlineAgentFormalArgs PreCond LocalDecl ONCE ParenStringList Combound PostCond Rescue END")]
		public InlineAgentNoActuals._9(Parser h) {}
		[Lemon(pattern="AGENT InlineAgentFormalArgs PreCond LocalDecl ONCE ParenStringList PostCond Rescue END")]
		public InlineAgentNoActuals._10(Parser h) {}
		[Lemon(pattern="AGENT NoInlineAgentFormalArgs PreCond EXTERNAL UntypedManifestString ExternalName PostCond Rescue END")]
		public InlineAgentNoActuals._11(Parser h) {}
		[Lemon(pattern="AGENT InlineAgentFormalArgs PreCond EXTERNAL UntypedManifestString ExternalName PostCond Rescue END")]
		public InlineAgentNoActuals._12(Parser h) {}
	}


	public class ExternalName : Classified {

		[Lemon(pattern="")]
		public ExternalName._0(Parser h) {}
		[Lemon(pattern="ALIAS UntypedManifestString")]
		public ExternalName._1(Parser h) {}
	}


	public class InlineAgentFormalArgs : Classified {

		[Lemon(pattern="FormalArgs")]
		public InlineAgentFormalArgs._1(Parser h) {}
	}

	public class NoInlineAgentFormalArgs : Classified {

		[Lemon(pattern="")]
		public NoInlineAgentFormalArgs._0(Parser h) {}
	}

	public class AgentTarget : Expr {
		
		[Lemon(pattern="Identifier(i)")]
		public AgentTarget._1(Parser h,Token i) {}
		[Lemon(pattern="ParenExpr(x)")]
		public AgentTarget._2(Parser h,ParenExpr x) {}
		[Lemon(pattern="RESULT")]
		public AgentTarget._3(Parser h) {}
		[Lemon(pattern="CURRENT")]
		public AgentTarget._4(Parser h) {}
		[Lemon(pattern="LBRACE Typ(t) RBRACE")]
		public AgentTarget._5(Parser h,Typ t) {}
	}

	public class AgentActuals : Expr {
		
		[Lemon(pattern="")]
		public AgentActuals._0(Parser h) {}
		[Lemon(pattern="LPAREN RPAREN")]
		public AgentActuals._1(Parser h) {}
		[Lemon(pattern="LPAREN AgentActualList")]
		public AgentActuals._2(Parser h) {}
	}

	public class AgentActualList : Expr {
		
		[Lemon(pattern="AgentActual(aa) RPAREN")]
		public AgentActualList._1(Parser h,AgentActual aa) {}
		[Lemon(pattern="AgentActual COMMA AgentActualList")]
		public AgentActualList._2(Parser h,AgentActual aa) {}
	}

	public class AgentActual : Expr {
		
		[Lemon(pattern="Expr(x)")]
		public AgentActual._1(Parser h,Expr x) {}
		[Lemon(pattern="QUESTION_MARK")]
		public AgentActual._2(Parser h) {}
		[Lemon(pattern="LBRACE Typ(t) RBRACE QUESTION_MARK")]
		public AgentActual._3(Parser h,Typ t) {}
	}

	public class ManifestString : Expr {
		
		[Lemon(pattern="UntypedManifestString")]
		public ManifestString._1(Parser h) {}
		[Lemon(pattern="TypedManifestString")]
		public ManifestString._2(Parser h) {}
	}

	public class UntypedManifestString : ManifestString {
		
		[Lemon(pattern="STRING")]
		public UntypedManifestString._1(Parser h) {}
	}

	public class TypedManifestString : ManifestString {
		
		[Lemon(pattern="LBRACE Typ(t) RBRACE UntypedManifestString")]
		public TypedManifestString._1(Parser h) {}
	}

	public class BoolConstant : Expr {
		
		[Lemon(pattern="FALSE")]
		public BoolConstant._1(Parser h) {}
		[Lemon(pattern="TRUE")]
		public BoolConstant._2(Parser h) {}
	}

	public class CharConstant : Expr {
		
		[Lemon(pattern="UntypedCharConstant")]
		public CharConstant._1(Parser h) {}
		[Lemon(pattern="TypedCharConstant")]
		public CharConstant._2(Parser h) {}
	}

	public class UntypedCharConstant : CharConstant {
		
		[Lemon(pattern="CHARACTER")]
		public UntypedCharConstant._1(Parser h) {}
	}

	public class TypedCharConstant : CharConstant {
		
		[Lemon(pattern="LBRACE Typ(t) RBRACE UntypedCharConstant")]
		public TypedCharConstant._1(Parser h) {}
	}

	public class IntConstant : Expr {
		
		[Lemon(pattern="UntypedIntConstant")]
		public IntConstant._1(Parser h) {}
		[Lemon(pattern="TypedIntConstant")]
		public IntConstant._2(Parser h) {}
	}

	public class UntypedIntConstant : IntConstant {
		
		[Lemon(pattern="INTEGER")]
		public UntypedIntConstant._1(Parser h) {}
		[Lemon(pattern="PLUS INTEGER")]
		public UntypedIntConstant._2(Parser h) {}
		[Lemon(pattern="MINUS INTEGER")]
		public UntypedIntConstant._3(Parser h) {}
	}

	public class TypedIntConstant : IntConstant {
		
		[Lemon(pattern="LBRACE Typ(t) RBRACE UntypedIntConstant")]
		public TypedIntConstant._1(Parser h) {}
	}

	public class RealConstant : Expr {
		
		[Lemon(pattern="UntypedRealConstant")]
		public RealConstant._1(Parser h) {}
		[Lemon(pattern="TypedRealConstant")]
		public RealConstant._2(Parser h) {}
	}

	public class UntypedRealConstant : RealConstant {
		
		[Lemon(pattern="REAL")]
		public UntypedRealConstant._1(Parser h) {}
		[Lemon(pattern="PLUS REAL")]
		public UntypedRealConstant._2(Parser h) {}
		[Lemon(pattern="MINUS REAL")]
		public UntypedRealConstant._3(Parser h) {}
	}

	public class TypedRealConstant : RealConstant {
		
		[Lemon(pattern="LBRACE Typ(t) RBRACE UntypedRealConstant")]
		public TypedRealConstant._1(Parser h) {}
	}

	public class Identifier : Classified {
		
		[Lemon(pattern="IDENTIFIER(i)")]
		public Identifier._1(Parser h,Token i) {}
	}

// --------------------------------------------------------------------
} /* namespace*/
