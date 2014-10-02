/**
   Scenner/Parser of Eiffel source code to produce tags in the debugger's 
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
	public class Start : Object {
		[Lemon(pattern="FeatureDecl(f)")]
		public Start(Parser h, FeatureDecl f) {}
	}
	
	[Lemon(extra_argument=true,
		   nonassoc="SEMICOLON",
		   nonassoc="COLON",
		   nonassoc="COMMA",
		   right="ASSIGN",
		   nonassoc="CREATE AGENT ATTACHED LIKE",
		   left="IMPLIES", left="OR ORELSE XOR", left="AND ANDTHEN",
		   left="EQ NE SIM NSIM LT LE GT GE", 
		   left="DOTDOT", 
		   left="PLUS MINUS",
		   left="TIMES DIV IDIV IMOD", right="POWER", 
		   left="FREE_OP", right="NOT ADDRESS OLD",
		   right="LPAREN LBRACKET LBRACE   ",
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
		
		public override void on_syntax_error() {
//		public override void on_parse_failed() {
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
			token = new Token(value, n_chars_read);
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
	
	public class FeatureDecl : Object {
		[Lemon(pattern="ExtendedNameList(el) ResultTyp(rt) Obsolete(o)")]
		public FeatureDecl._1(Parser h, ExtendedNameList el,  ResultTyp rt,
							  Obsolete o) {}
		[Lemon(pattern="ExtendedNameList(el) ResultTyp(rt) EQ Manifest(m) Obsolete(o)")]
		public FeatureDecl._2(Parser h, ExtendedNameList el,  
							  ResultTyp rt, Manifest m, Obsolete o) {}
		[Lemon(pattern="ExtendedNameList(el) ResultTyp(rt) Obsolete(o) NoteList(nl) RoutineDecl(rd)")]
		public FeatureDecl._3(Parser h, ExtendedNameList el, ResultTyp rt, 
							  Obsolete o, NoteList nl, RoutineDecl rd) {}
		[Lemon(pattern="ExtendedNameList(el) LPAREN DeclarationList(dl) RPAREN ResultTyp(rt) Obsolete(o) NoteList(nl) RoutineDecl(rd)")]
		public FeatureDecl._4(Parser h, ExtendedNameList el, 
						  DeclarationList dl, ResultTyp rt, 
						  Obsolete o, NoteList nl, RoutineDecl rd) {}
		[Lemon(pattern="AGENT InlineAgent(ia)")]
		public FeatureDecl._5(Parser h, InlineAgent ia) {}
	}

	public class RoutineDecl : Object {

		[Lemon(pattern="Require(r) Locals(ll) Body(b)")]
		public RoutineDecl._1(Parser h, Require r, Locals ll, Body b) {}

	}

	public class ExtendedNameList : Object {

		[Lemon(pattern="ExtendedName(en)")]
		public ExtendedNameList._1(Parser h, ExtendedName en) {}

		[Lemon(pattern="ExtendedNameList(el) COMMA ExtendedName(en)")]
		public ExtendedNameList._2(Parser h, ExtendedNameList el, ExtendedName e) {}		

	}

	public class ExtendedName : Object {

		[Lemon(pattern="IDENTIFIER(i)")]
		public ExtendedName._1(Parser h, Token i) {}

		[Lemon(pattern="IDENTIFIER ALIAS STRING")]
		public ExtendedName._2(Parser h) {}

		[Lemon(pattern="FROZEN IDENTIFIER")]
		public ExtendedName._3(Parser h) {}

		[Lemon(pattern="FROZEN IDENTIFIER ALIAS STRING")]
		public ExtendedName._4(Parser h) {}

	}

	public class DeclarationList : Object {

		[Lemon(pattern="Declarations(dd)")]
		public DeclarationList._1(Parser h, Declarations dd) {}

		[Lemon(pattern="DeclarationList(dl) Declarations(dd)")]
		public DeclarationList._2(Parser h, DeclarationList dl, Declarations dd) {}
	}

	public class Declarations : Object {

		[Lemon(pattern="Key(k) Typ(t)")]
		public Declarations._1(Parser h, Key k, Typ t) {}

		[Lemon(pattern="Key(k) Typ(t) SEMICOLON")]
		public Declarations._2(Parser h, Key k, Typ t) {}

		[Lemon(pattern="IDENTIFIER(i) COMMA Declarations(dd)")]
		public Declarations._3(Parser h, Token i, Declarations dd) {}
	}

	public class ResultTyp : Object {

		[Lemon(pattern="")]
		public ResultTyp._1(Parser h) {}

		[Lemon(pattern="COLON Typ(t)")]
		public ResultTyp._2(Parser h, Typ t) {}

		[Lemon(pattern="COLON Typ(t) ASSIGN Identifier(i)")]
		public ResultTyp._3(Parser h, Typ t, Identifier i) {}

	}

	public class Obsolete : Object {

		[Lemon(pattern="")]
		public Obsolete._1(Parser h) {}

		[Lemon(pattern="OBSOLETE STRING(s)")]
		public Obsolete._2(Parser h, Token s) {}
	}

	public class NoteList : Object {

		[Lemon(pattern="")]
		public NoteList._1(Parser h) {}

		[Lemon(pattern="NOTE")]
		public NoteList._2(Parser h) {}

		[Lemon(pattern="NOTE Notes(nn)")]
		public NoteList._3(Parser h, Notes nn) {}
	}

	public class Notes : Object {

		[Lemon(pattern="Note(n)")]
		public Notes._1(Parser h, Note n) {}

		[Lemon(pattern="Notes(nn) Note(n)")]
		public Notes._2(Parser h, Notes nn, Note n) {}

		[Lemon(pattern="Notes(nn) SEMICOLON Note(n)")]
		public Notes._3(Parser h, Notes nn, Note n) {}
	}

	public class Note : Object {

		[Lemon(pattern="Key(k) NoteValues(vv)")]
		public Note._1(Parser h, Token k, NoteValues vv) {}

	}

	public class NoteValues : Object {

		[Lemon(pattern="NoteValue(v)")]
		public NoteValues._1(Parser h, NoteValue v) {}

		[Lemon(pattern="NoteValues(vv) COMMA NoteValue(v)")]
		public NoteValues._2(Parser h, NoteValues vv, NoteValue v) {}
	}

	public class NoteValue : Object {

		[Lemon(pattern="IDENTIFIER(i)")]
		public NoteValue._1(Parser h, Token i) {}

		[Lemon(pattern="Manifest(m)")]
		public NoteValue._2(Parser h, Manifest m) {}
	}

	public class Require : Object {

		[Lemon(pattern="")]
		public Require._1(Parser h) {}

		[Lemon(pattern="REQUIRE")]
		public Require._2(Parser h) {}

		[Lemon(pattern="REQUIRE Assertions(aa)")]
		public Require._3(Parser h, Assertions aa) {}

		[Lemon(pattern="REQUIRE ELSE")]
		public Require._4(Parser h) {}

		[Lemon(pattern="REQUIRE ELSE Assertions(aa)")]
		public Require._5(Parser h, Assertions aa) {}
	}
	
	public class Locals : Object {

		[Lemon(pattern="")]
		public Locals._1(Parser h) {}

		[Lemon(pattern="LOCAL")]
		public Locals._2(Parser h) {}

		[Lemon(pattern="LOCAL(l) DeclarationList(dl)")]
		public Locals._3(Parser h, Token l, DeclarationList dl) {}
	}
	
	public class Body : Object {

		[Lemon(pattern="DO Compound(c) Ensure(e) Rescue(r) END")]
		public Body._1(Parser h, Compound c, Ensure e, Rescue r) {}

		[Lemon(pattern="ONCE Compound(c) Ensure(e) Rescue(r) END")]
		public Body._2(Parser h, Compound c, Ensure e, Rescue r) {}

		[Lemon(pattern="EXTERNAL STRING Ensure(e) END")]
		public Body._3(Parser h, Ensure e) {}

		[Lemon(pattern="EXTERNAL STRING ALIAS STRING Ensure(e) END")]
		public Body._4(Parser h, Ensure e) {}
	}
	
	public class Ensure : Object {

		[Lemon(pattern="")]
		public Ensure._1(Parser h) {}

		[Lemon(pattern="ENSURE")]
		public Ensure._2(Parser h) {}

		[Lemon(pattern="ENSURE Assertions(aa)")]
		public Ensure._3(Parser h, Assertions aa) {}

		[Lemon(pattern="ENSURE THEN")]
		public Ensure._4(Parser h) {}

		[Lemon(pattern="ENSURE THEN Assertions(aa)")]
		public Ensure._5(Parser h, Assertions aa) {}
	}
	
	public class Rescue : Object {

		[Lemon(pattern="")]
		public Rescue._1(Parser h) {}

		[Lemon(pattern="RESCUE Compound(c)")]
		public Rescue._2(Parser h, Compound c) {}
	}
	
	public class Compound : Object {

		[Lemon(pattern="")]
		public Compound._0(Parser h) {}

		[Lemon(pattern="Compound(c) Instruction(i)")]
		public Compound._1(Parser h, Compound c, Instruction i) {}
	}
	
	public class Instruction : Object {

		[Lemon(pattern="MultiDot(m)")]
		public Instruction._0(Parser h, MultiDot m) {}

		[Lemon(pattern="Parenthesized(p)")]
		public Instruction._1(Parser h, Parenthesized p) {}

		[Lemon(pattern="Create(c)")]
		public Instruction._2(Parser h, Create c) {}

		[Lemon(pattern="Assign(a)")]
		public Instruction._3(Parser h, Assign a) {}

		[Lemon(pattern="Condition(c)")]
		public Instruction._4(Parser h, Condition c) {}

		[Lemon(pattern="Inspect(i)")]
		public Instruction._5(Parser h, Inspect i) {}

		[Lemon(pattern="Loop(l)")]
		public Instruction._6(Parser h, Loop l) {}

		[Lemon(pattern="Across(a)")]
		public Instruction._7(Parser h, Across a) {}

		[Lemon(pattern="Debug(d)")]
		public Instruction._8(Parser h, Debug d) {}

		[Lemon(pattern="Check(c)")]
		public Instruction._9(Parser h, Check c) {}

		[Lemon(pattern="Retry")]
		public Instruction._10(Parser h) {}

		[Lemon(pattern="Instruction(i) SEMICOLON")]
		public Instruction._11(Parser h, Instruction i) {}
	}
	
	public class Create : Object {

		[Lemon(pattern="CREATE Identifier(i) DOT Query(q)")]
		public Create._1(Parser h, Identifier i, Query q) { 
			h.ident_matched(q);
		}

		[Lemon(pattern="CREATE Identifier(i)")]
		public Create._2(Parser h, Identifier i) {}

		[Lemon(pattern="CREATE ExplicitTyp(ct) Identifier(i) DOT Query(q)")]
		public Create._3(Parser h, ExplicitTyp ct, Identifier i, Query q) { 
			q.set_parent(ct.cn);
			h.ident_matched(q);
		}

		[Lemon(pattern="CREATE ExplicitTyp(ct) Identifier(i)")]
		public Create._4(Parser h, ExplicitTyp ct, Identifier i) {}
	}

	public class ExplicitTyp : Typ {
		private ExplicitTyp(Typ t) { base(t); }

		[Lemon(pattern="LBRACE Typ(t) RBRACE")]
		public ExplicitTyp._1(Parser h, Typ t) { base(t); }
	}

	public class Typ : DirectTyp {
		private Typ(DirectTyp y) { cn = y.cn; }

		[Lemon(pattern="DirectTyp(y)")]
		public Typ._1(Parser h, DirectTyp y) { this(y); }
		[Lemon(pattern="QUESTION_MARK DirectTyp(y)")]
		public Typ._2(Parser h, DirectTyp y) { this(y); }
		[Lemon(pattern="EXCLAMATION_MARK DirectTyp(y)")]
		public Typ._3(Parser h, DirectTyp y) { this(y); }
		[Lemon(pattern="ATTACHED DirectTyp(y)")]
		public Typ._4(Parser h, DirectTyp y) { this(y); }
		[Lemon(pattern="DETACHABLE DirectTyp(y)")]
		public Typ._5(Parser h, DirectTyp y) { this(y); }	
	}
	
	public class DirectTyp : Object {

		public ClassName? cn;

		[Lemon(pattern="IDENTIFIER(i) LBRACKET Types(tt) RBRACKET")]
		public DirectTyp._1(Parser h, Token i, Types tt) {
			cn = new ClassName(h, i);
		}

		[Lemon(pattern="IDENTIFIER(i)", prec="COLON")]
		public DirectTyp._2(Parser h, Token i) { cn = new ClassName(h, i); }

		[Lemon(pattern="TUPLE(t) LBRACKET DeclarationList(dl) RBRACKET")]
		public DirectTyp._3(Parser h, Token t, DeclarationList dl) {
			cn = new ClassName(h, t);
		}

		[Lemon(pattern="TUPLE(t) LBRACKET Types(tt) RBRACKET")]
		public DirectTyp._4(Parser h, Token t, Types tt) {
			cn = new ClassName(h, t);
		}

		[Lemon(pattern="TUPLE(t) LBRACKET RBRACKET")]
		public DirectTyp._5(Parser h, Token t) { cn = new ClassName(h, t); }

		[Lemon(pattern="TUPLE(t)", prec="COLON")]
		public DirectTyp._6(Parser h, Token t) { cn = new ClassName(h, t); }

		[Lemon(pattern="LIKE Expr(x)")]
		public DirectTyp._7(Parser h, Expr x) {
			FeatureText* ft = x.q.ft;
			if (ft!=null) cn = new ClassName.from_text(ft.home);
		}

	}

	public class Types : Object {

		[Lemon(pattern="Typ(t)")]
		public Types._1(Parser h, Typ t) {}

		[Lemon(pattern="Types(tt) COMMA Typ(t)")]
		public Types._2(Parser h, Types tt, Typ t) {}
	}
	
	public class ClassName : Classified {

		public ClassName(Parser h, Token c) {
			base.from_token(h.ft, c);
			q.cls = h.system.class_by_name(c.name);
			if (q.cls!=null) h.ident_matched(this);	
		}

		public ClassName.from_text(ClassText* x) { base.empty(); }
	}

	public class Assign : Object {
		[Lemon(pattern="MultiDot(m) ASSIGN Expr(x)")]
		public Assign._1(Parser h, MultiDot m, Expr x) {}
	}
	
	public class Condition : Object {
		[Lemon(pattern="IF ThenParts(t) END")]
		public Condition._1(Parser h, ThenParts t) {}
		[Lemon(pattern="IF ThenParts(t) ElsePart(e) END")]
		public Condition._2(Parser h, ThenParts t, ElsePart e) {}
	}
	
	public class ThenParts : Object {
		[Lemon(pattern="ThenPart(t)")]
		public ThenParts._1(Parser h, ThenPart t) {}
		[Lemon(pattern="ThenParts(tt) ELSEIF ThenPart(t)")]
		public ThenParts._2(Parser h, ThenParts tt, ThenPart t) {}
	}
	
	public class ThenPart : Object {
		[Lemon(pattern="Expr(i) THEN Compound(c)")]
		public ThenPart._1(Parser h, Expr i, Compound c) {}
	}
	
	public class ElsePart : Object {
		[Lemon(pattern="ELSE Compound(c)")]
		public ElsePart._1(Parser h, Compound c) {}
	}
	
	public class Inspect : Object {
		[Lemon(pattern="InspectInit(ii) WhenParts(wp) InspectElse(ie)")]
		public Inspect._1(Parser h, InspectInit ii, WhenParts wp, InspectElse ie) {}
	}
	
	public class InspectInit : Object {
		[Lemon(pattern="INSPECT Expr(x)")]
		public InspectInit._1(Parser h, Expr x) { h.in_inspect = true; }
	}
	
	public class InspectElse : Object {
		[Lemon(pattern="END")]
		public InspectElse._1(Parser h) { h.in_inspect = false; }
		[Lemon(pattern="ElsePart(e) END")]
		public InspectElse._2(Parser h, ElsePart e) { h.in_inspect = false; }
	}
	
	public class WhenParts : Object {
		[Lemon(pattern="WhenPart(w)")]
		public WhenParts._1(Parser h, WhenPart w) {}
		[Lemon(pattern="WhenParts(ww) WhenPart(w)")]
		public WhenParts._2(Parser h, WhenParts ww, WhenPart w) {}
	}
	
	public class WhenPart : Object {
		[Lemon(pattern="WHEN Choices(cc) THEN Compound(c)")]
		public WhenPart._1(Parser h, Choices cc, Compound c) {}
	}
	
	public class Choices : Object {
		[Lemon(pattern="ChoiceRange(cr)")]
		public Choices._1(Parser h, ChoiceRange cr) {}
		[Lemon(pattern="Choices(cc) COMMA ChoiceRange(cr)")]
		public Choices._2(Parser h, Choices cc, ChoiceRange cr) {}
	}
	
	public class ChoiceRange : Object {
		[Lemon(pattern="Choice(c)")]
		public ChoiceRange._1(Parser h, Choice c) {}
		[Lemon(pattern="Choice(l) DOTDOT Choice(r)")]
		public ChoiceRange._2(Parser h, Choice l, Choice r) {}
	}
	
	public class Choice : Object {
		[Lemon(pattern="Manifest(m)")]
		public Choice._1(Parser h, Manifest m) {}
		[Lemon(pattern="MultiDot(m)")]
		public Choice._2(Parser h, MultiDot m) {}
		[Lemon(pattern="Typ(t)")]
		public Choice._3(Parser h, Typ t) {}
	}
	
	public class Loop : Object {
		[Lemon(pattern="From(i) LoopInvariant(li) Until(u) LoopBody(b)")]
		public Loop._1(Parser h, From i, LoopInvariant li, Until u, LoopBody b) {}
	}
	
	public class From : Object {
		[Lemon(pattern="FROM Compound(c)")]
		public From._2(Parser h, Compound c) {}
	}
	
	public class Until : Object {

		[Lemon(pattern="UNTIL Expr(x)")]
		public Until._1(Parser h, Expr x) {}
	}
	
	public class LoopBody : Object {

		[Lemon(pattern="LOOP Compound(c) END")]
		public LoopBody._1(Parser h, Compound c) {}
	}

	public class LoopInvariant : Object {

		[Lemon(pattern="")]
		public LoopInvariant._0(Parser h) { }

		[Lemon(pattern="INVARIANT")]
		public LoopInvariant._1(Parser h) { }

		[Lemon(pattern="INVARIANT Assertions(aa)")]
		public LoopInvariant._2(Parser h, Assertions aa) {}
	}
	
	public class Across : Object {
		private Across(Classified v) { base(v); }

		[Lemon(pattern="AcrossHeader(ah) FromOpt(f) LoopInvariant(li) UntilOpt(u) AcrossBody(b)")]
		public Across._1(Parser h, AcrossHeader ha, From f, LoopInvariant li, 
						 UntilOpt u, AcrossBody b) {}

	}

	public class AcrossHeader : Object {
		[Lemon(pattern="ACROSS Expr(x) AS IDENTIFIER(i)")]
		public AcrossHeader._1(Parser h, Expr x, Token i) {}
	}

	public class FromOpt : Object {
		[Lemon(pattern="")]
		public FromOpt._0(Parser h){}

		[Lemon(pattern="From(f)")]
		public FromOpt._1(Parser h, From f) {}
	}

	public class UntilOpt : Object {
		[Lemon(pattern="")]
		public UntilOpt._0(Parser h) {}

		[Lemon(pattern="Until(f)")]
		public UntilOpt._1(Parser h, Until u) {}
	}

	public class AcrossBody : Object {

 		[Lemon(pattern="LoopBody(lb)")]
		public AcrossBody._1(Parser h, LoopBody lb) {}

		[Lemon(pattern="SOME Expr(x) Variant(v) END")]
		public AcrossBody._2(Parser h, Expr x, Variant v) {}

		[Lemon(pattern="ALL Expr(x) Variant(v) END")]
		public AcrossBody._3(Parser h, Expr x, Variant v) {}
	}

	public class Assertions : Object {

		[Lemon(pattern="Assertion(a)")]
		public Assertions._1(Parser h, Assertion a) {}

		[Lemon(pattern="Assertions(aa) Assertion(a)")]
		public Assertions._2(Parser h, Assertions aa, Assertion a) {}
	}

	public class Assertion : Object {

		[Lemon(pattern="Expr(x)", prec="NOT")]
		public Assertion._1(Parser h, Expr x) {}

		[Lemon(pattern="Key(k) Expr(x)", prec="NOT")]
		public Assertion._2(Parser h, Token k, Expr x) {}
	}
	
	public class Variant : Object {

		[Lemon(pattern="")]
		public Variant._0(Parser h) {}

		[Lemon(pattern="VARIANT Expr(x)")]
		public Variant._1(Parser h, Expr x) {}

		[Lemon(pattern="VARIANT IDENTIFIER(i) COLON Expr(x)")]
		public Variant._2(Parser h, Token i, Expr x) {}
	}
	
	public class Debug : Object {
		[Lemon(pattern="DEBUG Compound(c) END")]
		public Debug._1(Parser h, Compound c) {}
		[Lemon(pattern="DEBUG_LPAREN Manifests(mm) RPAREN Compound(c) END")]
		public Debug._2(Parser h, Manifests mm, Compound c) {}
	}
	
	public class Manifests : Object {
		[Lemon(pattern="Manifest(m)")]
		public Manifests._1(Parser h, Manifest m) {}
		[Lemon(pattern="Manifests(mm) COMMA Manifest(m)")]
		public Manifests._2(Parser h, Manifests mm, Manifest m) {}
	}
	
	public class Check : Object {
		[Lemon(pattern="CHECK Assertions(aa) NoteList END")]
		public Check._1(Parser h, Assertions aa) {}
		[Lemon(pattern="CHECK Assertion(a) THEN END")]
		public Check._2(Parser h, Assertion a) {}
	}
	
	public class Retry : Object {
		[Lemon(pattern="RETRY")]
		public Retry._1(Parser h) {}
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
			if (arg!=null)  q.size += (arg.at-at) + (arg.size-1);
			ClassText* home = null;
			if (p!=null) {
				set_parent(p);
			} else if (ft!=null) {
				uint n;
				home = ft.home;
				RoutineText* rt = ft.is_routine_text() ? 
					(RoutineText*)ft : null; 
				q.ft = home.query_by_name(out n, name, arg==null, rt);
				if (n==1 && q.ft==null)
					q.ft = home.feature_by_name(name, true);
			}
		}
		
		protected Classified(Classified v) {
			base(v.name, v.at, v.size); 
			q = v.q;
		}

		public void set_parent(Classified p) {
			ClassText* home = p.q.ft!=null ? p.q.ft.result_text : p.q.cls;
			uint n;
			if (home==null) return;
			q.p = p.q;
			q.ft = home.query_by_name(out n, name);
			if (n==1 && q.ft==null) 
				q.ft = home.feature_by_name(name, true);
		}
	}
	
	public class Identifier : Classified {
		
		private Identifier(Classified v) { base(v); }
		
		[Lemon(pattern="IDENTIFIER(i)")]
		public Identifier._1(Parser h, Token i) {
			base.from_token(h.ft, i);
			h.ident_matched(this);
		}
	}
	
	public class Key : Identifier  {
		
		private Key(Identifier v) { base(v); }
		
		[Lemon(pattern="IDENTIFIER(i) COLON")]
		public Key._1(Parser h, Token i) {
			base.from_token(h.ft, i);
		}
	}
	
	public class Query : Classified {
		
		private Query(Classified v) { base(v); }
		
		[Lemon(pattern="Identifier(i)", prec="CREATE")]
		public Query._1(Parser h, Identifier i) { base(i); }
		
		[Lemon(pattern="Identifier(i) LPAREN Args(aa) RPAREN(r)")]
		public Query._2(Parser h, Identifier i, Args aa, Token r) { 
			base.from_token(h.ft, i, null, aa);
		}
				
		[Lemon(pattern="CREATE ExplicitTyp(ct) DOT Query(q)")]
		public Query._3(Parser h, ExplicitTyp ct, Query q) { 
			base(ct.cn);
			q.set_parent(ct.cn);
			h.ident_matched(q);
		}

		[Lemon(pattern="CREATE ExplicitTyp(ct)")]
		public Query._4(Parser h, ExplicitTyp ct) { base(ct.cn); }
	}

	public class Precursor : Classified {

		private Precursor(Classified v) { base(v); }
		
		[Lemon(pattern="PRECURSOR", prec="CREATE")]
		public Precursor._1(Parser h) { base.empty(); }

		[Lemon(pattern="PRECURSOR LPAREN Args(aa) RPAREN")]
		public Precursor._2(Parser h, Args aa) { base.empty(); }

		[Lemon(pattern="PRECURSOR LBRACE Typ RBRACE", prec="LBRACE")]
		public Precursor._3(Parser h) { base.empty(); }

		[Lemon(pattern="PRECURSOR LBRACE Typ RBRACE LPAREN Args(aa) RPAREN")]
		public Precursor._4(Parser h, Args aa) { base.empty(); }

	}
	
	public class MultiDot : Classified {
		
		private MultiDot(Classified v) { base(v); }
		
		[Lemon(pattern="Query(q)")]
		public MultiDot._1(Parser h, Query q) { base(q); }
		
		[Lemon(pattern="ExplicitTyp(et) DOT Query(q)")]
		public MultiDot._3(Parser h, ExplicitTyp et, Query q) { 
			base.from_token(h.ft, q); 
			if (et.cn!=null) {
				q.set_parent(et.cn);
				h.ident_matched(q);
			}
		}
		
		[Lemon(pattern="Precursor(p)")]
		public MultiDot._4(Parser h, Precursor p) { base(p); }

		[Lemon(pattern="MultiDot(m) DOT Query(q)")]
		public MultiDot._5(Parser h, MultiDot m, Query q) { 
			base.from_token(h.ft, q, m); 
			h.ident_matched(this);
		}

		[Lemon(pattern="MultiDot(m) LBRACKET Args(aa) RBRACKET(r)")]
		public MultiDot._6(Parser h, MultiDot m, Args aa, Token r) {
			base.from_token(h.ft, m, null, aa);
		}
	}
	
	public class Parenthesized : Classified {
		
		private Parenthesized(Classified v) { base(v); }
		
		[Lemon(pattern="LPAREN Expr(x) RPAREN")]
		public Parenthesized._1(Parser h, Expr x) { base(x); }

		[Lemon(pattern="Parenthesized(p) DOT Query(q)")]
		public Parenthesized._2(Parser h, Parenthesized p, Query q) { 
			base.from_token(h.ft, p, null, q); 
			h.ident_matched(this);
		}
		[Lemon(pattern="Parenthesized(p) LBRACKET Args(aa) RBRACKET(r)")]
		public Parenthesized._3(Parser h, Parenthesized p, Args aa, Token r) {
			base.from_token(h.ft, p, null, aa);
			h.ident_matched(this);
		}
		
	}
	
	public class Expr : Classified {
		
		private Expr(Classified v) { base(v); }
		
		[Lemon(pattern="MultiDot(m)")]
		public Expr._0(Parser h, MultiDot m) { base(m); }
		
		[Lemon(pattern="Parenthesized(p)", prec="NOT")]
		public Expr._1(Parser h, Parenthesized p) { 
			base.from_token(h.ft, p); 
		}
		
		[Lemon(pattern="PLUS(op) Expr(x)", prec="NOT")]
		public Expr._2(Parser h, Token op, Expr x) {
			base.from_token(h.ft, op, x);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="MINUS(op) Expr(x)", prec="NOT")]
		public Expr._3(Parser h, Token op, Expr x) {
			base.from_token(h.ft, op, x);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="NOT(op) Expr(x)")]
		public Expr._4(Parser h, Token op, Expr x) {
			base.from_token(h.ft, op, x);
			h.ident_matched(this);
		}

		[Lemon(pattern="ADDRESS(op) Expr(x)")]
		public Expr._5(Parser h, Token op, Expr x) {
			base.from_token(h.ft, op, x);
			h.ident_matched(this);
		}

		[Lemon(pattern="FREE_OP(op) Expr(x)", prec="NOT")]
		public Expr._6(Parser h, Token op, Expr x) {
			base.from_token(h.ft, op, x);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) FREE_OP(op) Expr(r)")]
		public Expr._7(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) POWER(op) Expr(r)")]
		public Expr._8(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}

		[Lemon(pattern="Expr(l) TIMES(op) Expr(r)")]
		public Expr._9(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) DIV(op) Expr(r)")]
		public Expr._10(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) IDIV(op) Expr(r)")]
		public Expr._11(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) IMOD(op) Expr(r)")]
		public Expr._12(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) PLUS(op) Expr(r)")]
		public Expr._13(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) MINUS(op) Expr(r)")]
		public Expr._14(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) DOTDOT(op) Expr(r)")]
		public Expr._15(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) EQ(op) Expr(r)")]
		public Expr._16(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) NE(op) Expr(r)")]
		public Expr._17(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) SIM(op) Expr(r)")]
		public Expr._18(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) NSIM(op) Expr(r)")]
		public Expr._19(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) LT(op) Expr(r)")]
		public Expr._20(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) LE(op) Expr(r)")]
		public Expr._21(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) GT(op) Expr(r)")]
		public Expr._22(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) GE(op) Expr(r)")]
		public Expr._23(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) AND(op) Expr(r)")]
		public Expr._24(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) ANDTHEN(op) Expr(r)")]
		public Expr._25(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) OR(op) Expr(r)")]
		public Expr._26(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) ORELSE(op) Expr(r)")]
		public Expr._27(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) XOR(op) Expr(r)")]
		public Expr._28(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="Expr(l) IMPLIES(op) Expr(r)")]
		public Expr._29(Parser h, Expr l, Token op, Expr r) {
			base.from_token(h.ft, op, l, r);
			h.ident_matched(this);
		}
		
		[Lemon(pattern="AttachTest(ot)")]
		public Expr._31(Parser h, AttachTest ot) { base(ot); }
		
		[Lemon(pattern="AGENT Agent(a)")]
		public Expr._32(Parser h, Agent a) { base(a); }
		
		[Lemon(pattern="LMA Args(aa) RMA")]
		public Expr._33(Parser h, Args aa) { base.empty(); }
		
		[Lemon(pattern="LBRACKET RBRACKET")]
		public Expr._34(Parser h) { base.empty(); }
		
		[Lemon(pattern="LBRACKET Args(aa) RBRACKET")]
		public Expr._35(Parser h, Args aa) { base.empty(); }
		
		[Lemon(pattern="OLD Expr(x)")]
		public Expr._36(Parser h, Expr x) { base.from_token(h.ft, x); }

		[Lemon(pattern="Across(a)")]
		public Expr._37(Parser h, Across a) { base.empty(); }

		[Lemon(pattern="Manifest(m)")]
		public Expr._38(Parser h, Manifest m) { base.from_token(h.ft, m); }
	}
	
	public class AttachTest : Classified {
		
		private AttachTest(Classified v) { base(v); }
		
		[Lemon(pattern="ATTACHED Expr(x) AS IDENTIFIER", prec="AS")]
		public AttachTest._1(Parser h, Expr x) { base(x); }

		[Lemon(pattern="ATTACHED Expr(x)")]
		public AttachTest._2(Parser h, Expr x) { base(x); }

		[Lemon(pattern="ATTACHED ExplicitTyp(et) Expr(x) AS IDENTIFIER", prec="AS")]
		public AttachTest._3(Parser h, ExplicitTyp et, Expr x) { base(x); }

		[Lemon(pattern="ATTACHED ExplicitTyp(et) Expr(x)")]
		public AttachTest._4(Parser h, ExplicitTyp et, Expr x) { base(x); }

		[Lemon(pattern="LBRACE Key(k) Typ(t) RBRACE Expr(x)")]
		public AttachTest._5(Parser h, Key k, Typ t, Expr x) { base(x); }

	}
	
	public class Agent : Classified {
		
		private Agent(Classified v) { base(v); }
		
		[Lemon(pattern="AgentUnqualified(au)")]
		public Agent._1(Parser h, AgentUnqualified au) { base(au); }

		[Lemon(pattern="AgentTarget(at) DOT AgentUnqualified(au)")]
		public Agent._2(Parser h, AgentTarget at, AgentUnqualified au) {
			base.from_token(h.ft, au, at);
		}

		[Lemon(pattern="InlineAgent(ia)", prec="AGENT")]
		public Agent._3(Parser h, InlineAgent ia) { base(ia); }

		[Lemon(pattern="InlineAgent(ia) LPAREN AgentArgs RPAREN")]
		public Agent._4(Parser h, InlineAgent ia) { base(ia); }
	}
	
	public class AgentUnqualified : Classified {
		
		private AgentUnqualified(Classified v) { base(v); }
		
		[Lemon(pattern="Identifier(i) LPAREN AgentArgs(aa) RPAREN")]
		public AgentUnqualified._1(Parser h, Identifier i, AgentArgs aa) {
			base.empty();
		}
		
		[Lemon(pattern="Identifier(i)", prec="AGENT")]
		public AgentUnqualified._2(Parser h, Identifier i) { base.empty(); }	
	}
	
	public class AgentTarget : Classified {
		
		private AgentTarget(Classified v) { base(v); }
		
		[Lemon(pattern="Identifier(i)")]
		public AgentTarget._1(Parser h, Identifier i) { base(i); }

		[Lemon(pattern="ExplicitTyp(et)")]
		public AgentTarget._3(Parser h, ExplicitTyp et) { base.empty(); }
	}
	
	public class AgentArgs : Object {
		
		[Lemon(pattern="QUESTION_MARK")]
		public AgentArgs._1(Parser h) {}

		[Lemon(pattern="Expr(x)")]
		public AgentArgs._2(Parser h, Expr x) {}

		[Lemon(pattern="AgentArgs(a) COMMA QUESTION_MARK")]
		public AgentArgs._3(Parser h, AgentArgs a) {}

		[Lemon(pattern="AgentArgs(a) COMMA Expr(x)")]
		public AgentArgs._4(Parser h, AgentArgs a, Expr x) {}
	}
	
	public class InlineAgent : Classified {

		private InlineAgent(Classified v) { base(v); }
		
		[Lemon(pattern="ResultTyp(rt) RoutineDecl(rd)")]
		public InlineAgent._1(Parser h, ResultTyp rt, RoutineDecl rd) { 
			base.empty();
		}

		[Lemon(pattern="LPAREN DeclarationList(dl) RPAREN ResultTyp(rt) RoutineDecl(rd)")]
		public InlineAgent._2(Parser h, DeclarationList dl, 
							  ResultTyp rt, RoutineDecl rd) { 
			base.empty();
		}
	}

	public class Args : Classified {
		
		private Args(Classified v) { base(v); }
		
		[Lemon(pattern="Expr(x)")]
		public Args._1(Parser h, Expr x) { base(x); }

		[Lemon(pattern="Args(a) COMMA Expr(x)")]
		public Args._2(Parser h, Args aa, Expr x) { 
			base.from_token(h.ft, x, aa); 
		}
	}
	
	public class Manifest : Token {
		
		private Manifest(Token t) { base(t.name, t.at, t.size); }
		
		[Lemon(pattern="MANIFEST(m)")]
		public Manifest._1(Parser h, Token m) { this(m); }

		[Lemon(pattern="CHARACTER(c)")]
		public Manifest._3(Parser h, Token c) { this(c); }

		[Lemon(pattern="STRING(s)")]
		public Manifest._4(Parser h, Token s) { this(s); }

		[Lemon(pattern="INTEGER(i)")]
		public Manifest._5(Parser h, Token i) { this(i); }

		[Lemon(pattern="REAL(r)")]
		public Manifest._6(Parser h, Token r) { this(r); }
	}
	
} /* namespace*/
