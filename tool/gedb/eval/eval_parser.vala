using Gedb;

namespace Eval {
	
	public enum ErrorCode {
		OK = 0,
		NO_CLASS,
		NO_TUPLE,
		NO_ONCE,
		NOT_INIT,
		NO_ALIAS,
		NO_IDENT,
		NO_RANGE,
		UNKNOWN,
		LESS_ARGS,
		MORE_ARGS,
		BAD_ARG,
		BAD_PH_POS,
		BAD_PH_COUNT,
		NO_STACK,
		VOID,
		NOT_COMPUTED,
		OTHER
	}
	
	public delegate Expression? IdentToExpression(uint id, Object data);
	
	[Lemon(token_type=true)]
	public class Token : GLib.Object {
		public int code { get; internal set; }
		public string name { get; internal set; }
		public int at { get; internal set; }
		public int size { get; internal set; }
		public SourceFunc cb { get; internal set; }
		
		public Token(int code, string value, int start_col, int size=0) { 
			this.code = code;
			this.name = value;
			this.at = start_col;
			this.size = size==0 ? value.char_count() : size;
		}
		
		public Token twin() { return new Token(code, name, at, size); }
	}
	
	[Lemon(extra_argument=true,
		   left="ALIAS_CMD ARROW BREAK_CMD DEBUG_CMD",
		   left="EXC AT DEPTH TYP IFF PRINT CONT DIS",
		   right="ASSIGN",
		   left="IMPLIES", left="OR XOR", left="AND",
		   left="EQ NE SIM NSIM LT LE GT GE", left="INTERVAL", 
		   left="PLUS MINUS", left="TIMES DIV IDIV IMOD", right="UP", 
		   left="FREE_OP", left="BIT_OR BIT_AND LEFT_SHIFT RIGHT_SHIFT", 
		   left="NOT", left="DOT")]
	public class Parser : ParserParser {

	    override ~Parser() { values = null; }

		public Parser() {}

		public void init_syntax(System* s) {
			reset(true);
			system = s;
			syntax_only = true;
		}

		public void init_text(ClassText* ct, RoutineText* rt, System* s) 
		requires (s!=null) {
			reset(true);
			system = s;
			base_class = ct;
			act_text = rt;
			syntax_only = false;
		}

		public void init_typed(Gedb.Type* t, StackFrame* f, System* s, 
							   bool compute_now) 
		requires (t!=null || f!=null) requires (s!=null) {
			reset(true);
			frame = f;
			system = s;
			if (t!=null) {
				root_type = t;
				base_class = root_type.base_class;
			} else if (f!=null) {
				root_type = f.target_type();
				base_class = system.class_at(f.class_id);
				act_routine = f.routine;
			}
			if (f!=null) {
				act_routine = f.routine;
				act_text = act_routine.routine_text();
			}
			syntax_only = false;
			now = compute_now;
		}

		public void reset(bool totally=false) {
			values = new Gee.HashMap<Expression,Nonterm>();
			places = new Gee.LinkedList<Expression>(); 
			result = null;
			is_match = true;
			n_chars_read = 0;
			n_tokens_matched = 0;
			last_token = null;
			last_value = null;
			al = null;
			bp = null;
			missing_alias = null;
			missing_ident = 0;
			error = ErrorCode.OK;
			syntax_only = true;
			if (totally) {
				system = null;
				frame = null;
				root_type = null;
				act_routine = null;
				base_class = null;
				act_text = null;
				act_routine = null;
				set_aliases(null);
				set_idents(null);
				set_prefix(null);
			}
		}

		public Parser.as_command(System* s) requires (s!=null) {
			init_text(null, null, s);
			as_cmd = true;
			push_state(State.CMD);
		}
		
		public override void on_syntax_error() {
			if (error==ErrorCode.OK) {
				error = ErrorCode.OTHER;
				last_token = token_gobject as Token;
			}
			is_match = false;
			// stderr.printf("Syntax: at %d after matching `%s'\n", n_chars_read, last_token.name);
		}
		
		public void set_aliases(Gee.Map<string,Expression>? al) {
			aliases = al;
		}
		
		public void set_idents(IdentToExpression? id2expr, Object? data=null) {
			this.id2expr = id2expr;
			this.data = data;
		}
		
		public void set_prefix(Gee.List<Expression>? pref) {
			prefix = pref;
			prefix_ph = pref!=null ? pref.size : 0;
		}
		

		private Nonterm? _result;
		public Nonterm? result { 
			get { return is_match ? _result : null; }
			set { _result = value; } 
		}
		
		public Alias? al;
		public Breakpoint? bp;
		public bool debug;

		public Nonterm? token_at(Expression ex) { return values.@get(ex); }		
		public Token? last_token;	// first incorrect token
		public Nonterm? last_value;	// last correct value
		public string missing_alias;
		public uint missing_ident;
		public bool not_unique;
		public ErrorCode error;
		
		public Nonterm? value_at(int pos, bool with_range) {
			return result!=null ? result.child_at(this, pos, with_range) : null;
		}
		
		public signal void select(Token t);
		
		public System* system;
		public StackFrame* frame;
		public Gedb.Type* root_type;
		public Routine* act_routine;
		public ClassText* base_class;
		public RoutineText* act_text;
		
		internal string query;
		internal bool syntax_only;
		internal bool now;

		internal void register(Nonterm v, 
							   bool to_compute=false, bool in_object=false) 
		requires (v.expr!=null) {
			var ex = (!) v.expr;
			values[ex] = v;
			last_value = v;
			if (to_compute && !syntax_only) {
				if (ex is AliasExpression) {
					var aex = ex as AliasExpression;
					if (aex.alias!=null) return; //ex = aex.alias.top();
				}
				if (now) {
					try {
						if (frame!=null && !in_object) {
							ex.compute_in_stack(frame, system); 
						} else  {
							Expression? p = ex.parent;
							uint8* pa = p!=null ? p.address() : null;
							if (pa==null) return;
							var t = system.type_of_any(pa, p.dynamic_type);
							ex.compute_in_object(pa, t, system, frame, null);
						}
					} catch (ExpressionError err) {
						error = ErrorCode.NOT_COMPUTED;
						last_token = v.token;
						is_match = false;
					}
				} else if (!syntax_only) {
					var ct = ex.is_down() ?
						ex.parent.base_class() : base_class;
					is_match &= ex.static_check(ct, act_text, system, frame);
					if (!is_match) {
						error = ErrorCode.UNKNOWN;
						last_token = v.token;
					}
				}
			}
		}

		internal Nonterm? nonterm_of(Expression ex) { return values.@get(ex); }

		internal Gee.List<Expression> places;

		internal void push_place(Expression ex, RangeExpression? range) {
			Expression pl;
			if (last_range!=null) 
				pl = last_range;
			else 
				pl = ex;
			places.insert(0, pl);
		}
		
		internal void pop_place(bool save_range) 
		requires (places.size>0) { 
			last_range = save_range ? places.@get(0) : null; 
			places.remove_at(0);
		}
		
		internal uint places_size() { return places.size + prefix_ph; }

		internal Expression last_range;

		internal Expression get_place(uint i) 
		requires (places.size+prefix_ph>i) { 
			int n = places.size;
			int j = (int)i;
			return j<n? places.@get(j) : prefix.@get(j-n); 
		}

		internal Expression? number_alias(uint id) { 
			return id2expr!=null ? id2expr(id, data) : null;
		}

		internal Gee.Map<string,Expression>? aliases;

		Gee.HashMap<void*,uint> known_objects;
		private Gee.HashMap<Expression,Nonterm> values;
		private Gee.List<Expression> prefix;
		private IdentToExpression? id2expr;
		private Object? data;
		private uint prefix_ph;
		private bool as_cmd;
		
/* ------------------- Scanner ------------------- */

		[Flex(x="IDENT CMD", token="ALL ELSE IF THEN")]
		public override void on_default_token(string value, int value_len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
		
		[Flex(state="CMD", pattern="alias")]
		public void alias_cmd(string value, int len) {
			syntax_only = true;
			token = new Token(token_code, value, n_chars_read, len);
			pop_state();
		}
		
		[Flex(state="CMD", pattern="break")]
		public void break_cmd(string value, int len) {
			syntax_only = false;
			token = new Token(token_code, value, n_chars_read, len);
			pop_state();
		}
		
		[Flex(state="CMD", pattern="debug")]
		public void debug_cmd(string value, int len) {
			syntax_only = false;
			token = new Token(token_code, value, n_chars_read, len);
			pop_state();
		}
/*		
		[Flex(state="INITIAL", pattern="break")]
		public void break_cmd_ident(string value, int len) {
			token_code = TokenCode.IDENTIFIER;
			token = new Token(token_code, value, n_chars_read, len);
		}
*/
		[Flex(pattern="catch")]
		public void exc(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="at")]
		public void at(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}

		[Flex(pattern="depth")]
		public void depth(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="type")]
		public void typ(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="if")]
		public void iff(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="print")]
		public void print(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="cont")]
		public void cont(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="disabled")]
		public void dis(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		/*
		  [Flex(x="IDENT", token="ALIAS")]
		  public override void on_default_token(string value, int value_len) {
		  token_code = TokenCode.NO_ADD_TOKEN;
		  }
		*/
	/* Miscellaneous */ 
		
		[Flex(pattern="->")]
		public void arrow(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
			syntax_only = true;
		}
		
		[Flex(pattern="\\^+")]
		public void upframe(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\^[0-9]+\\^")]
		public void upframe_count(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
	
		[Flex(pattern="[!?]\\?*")]
		public void placeholder(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		/* Eiffel symbols */
		
		[Flex(pattern="\\.")]
		public void dot(string value, int value_len) {}
		
		[Flex(pattern=",")]
		public void comma(string value, int value_len) {}
		
		[Flex(pattern=":")]
		public void colon(string value, int value_len) {}
	
		[Flex(state="INITIAL", pattern="\\(")]
		public void lparen(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(state="IDENT", pattern="\\(")]
		public void ident_lparen(string value, int len) {
			token.size = n_chars_read - token.at;
			pop_state();
		}
		
		[Flex(pattern="\\)")]
		public void rparen(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		//[Flex(pattern="\\[")]
		[Flex(state="INITIAL", pattern="\\[")]
		public void lbracket(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(state="IDENT", pattern="\\[")]
		public void ident_lbracket(string value, int len) {
			token.size = n_chars_read - token.at;
			pop_state();
		}
		
		[Flex(pattern="]")]
		public void rbracket(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		[Flex(pattern="\\[\\[")]
		public void lbb(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}

		[Flex(pattern="]]")]
		public void rbb(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}		

		[Flex(pattern="\\{")]
		public void lbrace(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}	
		
		[Flex(pattern="\\}")]
		public void rbrace(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}	
		
		[Flex(pattern="<<")]
		public void lma(string value, int len) {}
		
		[Flex(pattern=">>")]
		public void rma(string value, int len) {}
		
		[Flex(pattern="-")]
		public void minus(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		} 
	
		[Flex(pattern="\\+")]
		public void plus(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\*")]
		public void times(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\/")]
		public void div(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\^")]
		public void up(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="<")]
		public void lt(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
	
		[Flex(pattern=">")]
		public void gt(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="=")]
		public void eq(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="~")]
		public void sim(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\$")]
		public void dollar(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		/*
		  [Flex(pattern="\\?=|:=")]
		  public void assign(string value, int len) {
		  token = new Token(token_code, value, n_chars_read, len);
		  }	
		*/
		[Flex(pattern="\\/=")]
		public void ne(string value, int len) {
		token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="~=")]
		public void nsim(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\/\\/")]
		public void idiv(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\\\\\\\")]
		public void imod(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="<=")]
		public void le(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern=">=")]
		public void ge(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\.\\.")]
		public void dotdot(string value, int len) {
			token_code = TokenCode.INTERVAL;
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		/* Eiffel free operators */
		
		[Flex(pattern="\\|")]
		public void bit_or(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="&")]
		public void bit_and(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\|<<")]
		public void left_shift(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\|>>")]
		public void right_shift(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="[&#@\\|\\\\%]")]
		public void free_op(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="\\|\\.\\.\\|")]
		public void interval(string value, int len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(define="OP_CODE [+<>*/\\\\^&#@|%~]", pattern="{OP_CODE}{2,}")]
		public void free1(string value, int len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="({OP_CODE}+-)+{OP_CODE}*")]
		public void free2(string value, int len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(token_code, value, n_chars_read, len);
		}
	
		[Flex(pattern="-({OP_CODE}+-)+")]
		public void free3(string value, int len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="-({OP_CODE}+-)*{OP_CODE}+")]
		public void free4(string value, int len) {
			token_code = TokenCode.FREE_OP;
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		/* Eiffel identifiers */
		
		[Flex(pattern="⚫")]
		public void bullet(string value, int len) {
			token_code = TokenCode.IDENTIFIER;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		[Flex(pattern="[a-zA-Z][a-zA-Z0-9_]*",
			  token="CURRENT", token="RESULT", 
			  token="FALSE", token="TRUE", token="VOID")]
		public void identifier(string value, int len) {
			token_code = process_identifier(value);
			token = new Token(token_code, value, n_chars_read, len);
			/*
			if (token_code==TokenCode.IDENTIFIER) {
				  var loop = new MainLoop();
				  string name = null;
				  wait_for_select.begin(token, (h, s) => 
				  { wait_for_select.end(s, out name); loop.quit(); });
				  loop.run();
				  stderr.printf("%s\n",name);
			}
			*/
		}
		
		private async void wait_for_select(Token t, out string name) {
			t.cb = wait_for_select.callback;
			select(t); 
			name = "xy";
		}
		
		[Flex(pattern="[a-zA-Z][a-zA-Z0-9_]*/[ \\t\\r\\n]*\\(")]
		public void identifier2(string value, int len) {
			token_code = process_identifier(value);
			if (token_code==TokenCode.IDENTIFIER) {
				token_code = TokenCode.NO_ADD_TOKEN;
				token = new Token(token_code, value, n_chars_read);
				push_state(State.IDENT);
			//select(token);
			}
		}
		
		[Flex(pattern="_[1-9][0-9]*")]
		public void heapvar(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		[Flex(pattern="_[a-z][a-z0-9_]*")]
		public void alias(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
	/* Reserved words */
		
		[Flex(pattern="[oO][nN][cC][eE][ \\t\\r]*/[\"{]")] 
		public void once_string(string value, int len) {
			token_code = TokenCode.STRING;
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		/* Eiffel integers */
		
		[Flex(pattern="[0-9]+")]
		public void integer(string value, int len) {
			token_code = TokenCode.INTEGER;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		[Flex(pattern="0[Xx][A-Fa-f0-9]+")]
		public void integer2(string value, int len) {
			token_code = TokenCode.INTEGER;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		/* Eiffel reals */
	
		[Flex(pattern="[0-9]+\\./[^.0-9]")]
		public void real(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len); 
		}
		
		[Flex(pattern="[0-9]+\\.[0-9]*[eE][+-]?[0-9]+")]
		public void real2(string value, int len) {
			token_code = TokenCode.REAL;
		token = new Token(token_code, value, n_chars_read, len);		
		}
		
		[Flex(pattern="[0-9]*\\.[0-9]+([eE][+-]?[0-9]+)?")]
		public void real3(string value, int len) {
			token_code = TokenCode.REAL;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		/* Eiffel characters */
		
		[Flex(pattern="\\'[^%\\n]\\'")]
		public void character(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		[Flex(pattern="\\'%[ABCDFHLNQRSTUV%'\"()<>]\\'")]
		public void char2(string value, int len) {
			token_code = TokenCode.CHARACTER;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		[Flex(define="CHAR_CODE (0*([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))", 
			  pattern="\\'%\\/{CHAR_CODE}\\/\\'")]
		public void char3(string value, int len) {
			token_code = TokenCode.CHARACTER;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		/* Eiffel strings */
		
		[Flex(token="STRING", pattern="\\\"[^%\\n ]*\\\"")]
		public void string1(string value, int len) {
			token_code = TokenCode.STRING;
			token = new Token(token_code, value, n_chars_read, len);		
	}
		
		[Flex(pattern="\\\"([^%\\n\"]|%([ABCDFHLNQRSTUV%'\"()<>]|\\/{CHAR_CODE}\\/))+\\\"")]  
		public void string2(string value, int len) {  /*"*/	
			token_code = TokenCode.STRING;
			token = new Token(token_code, value, n_chars_read, len);		
		}
		
		/* Miscellaneous */ 
		
		[Flex(pattern="[ \\t]")]
		public void space(string value, int len) {
			token_code = TokenCode.NO_ADD_TOKEN;
		}
	
		[Flex(pattern="\\n")]
		public void newline(string value, int len) {
			token_code = TokenCode.END_OF_INPUT;
		}
		
		[Flex(pattern="\\r\\n")]
		public void newline2(string value, int len) {
		token_code = TokenCode.END_OF_INPUT;
		}
		
		[Flex(pattern=":=")]
		public void assign(string value, int len) {
			token = new Token(token_code, value, n_chars_read, len);
		}
		
		/* Internal class members */
		
		static HashTable<string,int> keywords;
		
		private static uint nocase_hash(string s) {
		 return str_hash(s.down());
		}
		
		private static bool nocase_equal(string a, string b) {
			return a.ascii_casecmp(b) == 0;
		}
		
		private ParserParser.TokenCode process_identifier(string str) {
			if (keywords==null) {
				keywords = new HashTable<string,int>(nocase_hash, nocase_equal);
				// keywords.insert("alias", TokenCode.ALIAS);
				keywords.insert("all", TokenCode.ALL);
				keywords.insert("and", TokenCode.AND);
				keywords.insert("else", TokenCode.ELSE);
				keywords.insert("if", TokenCode.IF);
				keywords.insert("implies", TokenCode.IMPLIES);
				keywords.insert("not", TokenCode.NOT);
				keywords.insert("or", TokenCode.OR);
				keywords.insert("then", TokenCode.THEN);

				keywords.insert("current", TokenCode.CURRENT);
				keywords.insert("result", TokenCode.RESULT);
				keywords.insert("false", TokenCode.FALSE);
				keywords.insert("true", TokenCode.TRUE);
				keywords.insert("void", TokenCode.VOID);
			}
			int val = keywords.lookup(str);
			if (val!=0) {
				return (ParserParser.TokenCode)val;
			} else {
				return TokenCode.IDENTIFIER;
			}
		}
		
		private int line_number;

	} /* class EvalParser */
	
	[Lemon(start_symbol=true)]
	public class Parsed : GLib.Object {
		[Lemon(pattern="Command(c)")]
		public Parsed(Parser h, Command c) {}
	}
	
	public class Command : GLib.Object {
		
		public Nonterm? val { get; internal set; }
		public Alias? al { get; internal set; }
		public Breakpoint? bp { get; internal set; }

		[Lemon(pattern="Multi(m)")]
		public Command._1(Parser h, Multi m) {
			val = m;
			h.result = m;
		}
		
		[Lemon(pattern="Alias(a)")]
		public Command._2(Parser h, Alias a) { 
			al = a;
			h.al = a; 
		}
		[Lemon(pattern="Break(b)")]
		public Command._3(Parser h, Break b) { 
			bp = b;
			h.bp = b; 
		}

		[Lemon(pattern="Debug(g)")]
		public Command._4(Parser h, Debug g) { 
			h.debug = true;
		}

	}
	
	public class Alias : Object {
		
		public string name;
		public Expression expr;

		[Lemon(pattern="ALIAS_CMD IDENTIFIER(i) ARROW Detailed(d)")]
		public Alias._1(Parser h, Token i, Detailed d) {
			base();
			expr = d.expr;
			name = i.name;
		}
	}
	
	public class Break : Breakpoint {
		
		[Lemon(pattern="BREAK_CMD Cmd(e) At(a) Depth(d) Typ(t) Iff(i) Print(p) Cont(c) Dis(n)")]
		public Break._1(Parser h, Cmd e, At a, Depth d, Typ t, Iff i, Print p, Cont c, Dis n) {
			base();
			exc = e.exc;
			cid = a.cid;
			pos = a.pos;
			depth = d.depth;
			tid = t.tid;
			iff = i.iff;
			print = p.print;
			cont = c.cont;
			enabled = !n.dis;
		}
	}
	
	public class Cmd : Breakpoint {
		
		[Lemon(pattern="")]
		public Cmd._0(Parser h) { base.with_ident(0); }
		
		[Lemon(pattern="EXC IDENTIFIER(e)")]
		public Cmd._1(Parser h, Token e) {
			base.with_ident(0);
			var name = e.name.down();
			exc = code_of_catch(name);
		}
	}
	
	public class At : Breakpoint {
		
		[Lemon(pattern="")]
		public At._0(Parser h) { base.with_ident(0); }

		[Lemon(pattern="AT IDENTIFIER(n) COLON INTEGER(l) COLON INTEGER(c)")]
		public At._1(Parser h, Token n, Token l, Token c) {
			base.with_ident(0);
			ClassText* cls = h.system.class_by_name(n.name);
			FeatureText* ft;
			uint ln = int.parse(l.name);
			uint cn = int.parse(c.name);
			if (cls!=null) {
				cid = cls.ident;
				pos = 256*ln + cn;
			ft = cls.feature_by_line(ln);
			if (ft!=null && ft.is_routine()) {
				h.base_class = cls;
				h.act_text = (RoutineText*)ft;
			}
		}
		}
	}
	
	public class Depth : Breakpoint {
		
		[Lemon(pattern="")]
		public Depth._0(Parser h) { base.with_ident(0); }
		
		[Lemon(pattern="DEPTH INTEGER(d)")]
		public Depth._1(Parser h, Token d) {
			base.with_ident(0);
			depth = int.parse(d.name);
		}
	}
	
	public class Typ : Breakpoint {
		
		[Lemon(pattern="")]
		public Typ._0(Parser h) { base.with_ident(0); }
		
		[Lemon(pattern="TYP Typename(n)")]
		public Typ._1(Parser h, Typename n) {
			base.with_ident(0);
			Gedb.Type* tp = h.system.type_by_name(n.name, true);
			if (tp!=null) {
				tid = tp.ident;
				h.root_type = tp;
				if (h.act_text!=null) {
					var name = h.act_text._feature._name.fast_name;
				h.act_routine = tp.routine_by_name(name, false);
				}
			}
		}
	}
	
	public class Iff : Breakpoint {
		
		[Lemon(pattern="")]
		public Iff._0(Parser h) { base.with_ident(0); }
		
		[Lemon(pattern="IFF Single(s)")]
		public Iff._1(Parser h, Single s) {
			base.with_ident(0);
			var ex = s.expr.bottom();
			iff = null;
			if (ex.range!=null || ex.detail!=null || ex.next!=null)  return;
			ClassText* ct = ex.base_class();
			if (ct!=null && ct._name.fast_name=="BOOLEAN")  iff = s.expr;
		}
	}
	
	public class Print : Breakpoint {
		
		[Lemon(pattern="")]
		public Print._0(Parser h) { base.with_ident(0); }
		
		[Lemon(pattern="PRINT Multi(m)")]
		public Print._1(Parser h, Multi m) {
			base.with_ident(0);
			print = m.expr;
		}
	}
	
	public class Cont : Breakpoint {
		
		[Lemon(pattern="")]
		public Cont._0(Parser h) { base.with_ident(0); }
		
		[Lemon(pattern="CONT")]
		public Cont._1(Parser h) {
			base.with_ident(0);
			cont = true;
		}
	}
	
	public class Dis : Object {
		
		public bool dis;

		[Lemon(pattern="")]
		public Dis._0(Parser h) {}
		
		[Lemon(pattern="DIS")]
		public Dis._1(Parser h) { dis = true; }
	}
	
	public class Debug : Object {
		
		[Lemon(pattern="DEGUG_CMD")]
		public Debug._1(Parser h) {}
	}

	public class Typename : GLib.Object {
		
		internal string name;
		
		[Lemon(pattern="IDENTIFIER(t)")]
		public Typename._1(Parser h, Token t) { name = t.name; }
		
		[Lemon(pattern="IDENTIFIER(t) LBRACKET Typelist(tt) RBRACKET")]
		public Typename._2(Parser h, Token t, Typelist tt) {
			Gee.ArrayList<Typename> tl = tt.ll;
			int n = ((Gee.Collection)tl).size;
			name = t.name;
			name += "[";
			for (int i=0; i<n; ++i) {
				if (i>0)  name += ",";
			name += tl.@get(i).name;
			}
			name += "]";
		}
	}
	
	public class Typelist : GLib.Object {
		
		internal Gee.ArrayList<Typename> ll;
		
		[Lemon(pattern="Typename(t)")]
		public Typelist._1(Parser h, Typename t) {
			ll = new Gee.ArrayList<Typename>();
			ll.@add(t);
		}
		
		[Lemon(pattern="Typelist(tt) COMMA Typename(t)")]
		public Typelist._2(Parser h, Typelist tt, Typename t) { 
			ll = tt.ll;
			ll.@add(t); 
		}
	}

	
	public class Nonterm : GLib.Object {
		
		public int at { get; internal set; }
		public int size { get; internal set; }
		public Expression expr { get; protected set; }
		public Token token { get; protected set; }
		
		public Nonterm? child_at(Parser h, int pos, bool with_range) {
			int p = at;
			Nonterm? v = null;
			Nonterm best = this;
			if (pos<=p) {
				if (expr.down!=null) {
					// `down' may be a prefix operator 
					v = h.nonterm_of(expr.down);
					return v!=null ? v.child_at(h, pos, with_range) : null;
				} else {
					return null;
				}
			}
			if (p+size<=pos) p += size;
			if (expr.arg!=null) {
				v = h.nonterm_of(expr.arg);
				v = v.child_at(h, pos, with_range);
				if (v!=null && v.at>=p) {
					p = v.at;
					best = v;
				}
			}
			if (expr.down!=null) {
				v = h.nonterm_of(expr.down);
				v = v.child_at(h, pos, with_range);
				if (v!=null && v.at>=p) {
					p = v.at;
					best = v;
				}
			}
			if (with_range && expr.range!=null) {
				v = h.nonterm_of(expr.range);
				v = v.child_at(h, pos, with_range);
				if (v!=null && v.at>=p) {
					p = v.at;
					best = v;
				}
			}
			if (expr.detail!=null) {
				v = h.nonterm_of(expr.detail);
				v = v.child_at(h, pos, with_range);
				if (v!=null && v.at>=p) {
					p = v.at;
					best = v;
				}
			}
			if (expr.next!=null) {
				v = h.nonterm_of(expr.next);
				v = v.child_at(h, pos, with_range);
				if (v!=null && v.at>=p) {
					p = v.at;
					best = v;
				}
			}
			return best;
		}

		protected void end_by(Token t) { size = (t.at+t.size) - at; }
		
		protected void set_down(Parser h, Nonterm d) {
			if (!h.is_match) return;
			string name = d.token.name;
			Expression? dex = d.expr;
			var ex = expr.bottom();
			var u = d as Unqualified;
			var args = u!=null && u.args!=null ? u.args.expr : null;
			if (dex!=null) {
			} else if (h.syntax_only) {
				dex = Expression.new_named(ex, name, args);
			} else {
				var tex = ex as TextExpression;
				var tp = ex.dynamic_type;
				ClassText* ct = null;
				FeatureText* ef = null;
				Entity* e = null;
				uint n = 0;
				int li = -1;
				bool pref = args==null;
				if (tex!=null) 
					li = tex.text.item_by_label(name);
				if (tp!=null) {
					if (li>=-1) {
						if (li>=0) name = @"item_$(li+1)";
						e = tp.query_by_name(out n, name, pref);
						if (n!=1) e = null;
						tex = dex as TextExpression;
						if (e!=null && (tex==null || e!=tex.entity)) {
							try {
								dex = Expression.new_typed(ex, e, args);
							} catch (ExpressionError err) {
								if (err is ExpressionError.INVALID_ARGUMENTS) {
									
								}
							}
						}
					}
				} 
				if (dex==null && !h.now) {
					if (li>=-1) {
						if (li>=0) {
							ef = tex.text.tuple_labels[li];
						} else {
							ct = ex.base_class();
							ef = ct.query_by_name(out n, name, pref);
							if (n!=1) ef = null;
						}
					}
					if (ef!=null) 
						dex = Expression.new_text(ex, ef, args);
				}
				if (ef==null && e==null) {
					dex = null;
					h.not_unique = n>0;
				}
				if (dex==null)
					h.error = ErrorCode.UNKNOWN;
			}
			ex.set_child(ex.Child.DOWN, dex);
			d.expr = dex;
			if (dex!=null) h.register(d, true, true);
			if (dex==null) {
				h.last_token = d.token;
				if (h.error==0) h.error = ErrorCode.UNKNOWN;
				h.is_match = false;
			}
		}
		
		protected void set_root(Parser h, Upframe? up, Unqualified? u) {
			var f = h.frame;
			var tp = h.root_type;
			var ct = h.base_class;
			string name = token.name;
			uint n = 0;	
			Expression? ex = u!=null ? u.expr : null;
			FeatureText* ft;
			Entity* e;
			var a = u.args!=null ? u.args.expr : null;
			var aex = u.expr as AliasExpression;
			if (aex!=null) {
				ex = aex;
			} else if (h.syntax_only) {
				ex = Expression.new_named(null, name, a);
			} else {
				var r = h.act_routine;
				uint nu = up!=null ? up.count : 0;
				for (uint i=nu; i-->0;) {
					if (f==null) {
						h.last_token = up.token;
						h.error = ErrorCode.NO_STACK;
						h.is_match = false;
						return;
					}
					f = f.caller;
				}
				if (up!=null) {
					r = f.routine;
					tp = f.target_type();
					e = tp.query_by_name(out n, name, a==null, r);
					if (n!=1) e = null;
					try {
						if (n==0) {
							ex = Expression.predef_typed(name, h.act_routine,
														 h.system);
						} else if (e!=null) {
							ex = Expression.new_typed(null, e, a);
						}
						} catch (ExpressionError err) {
					}
				} else if (tp!=null) {
					e = tp.query_by_name(out n, name, a==null, r);
					if (n!=1) e = null;
					var tex = expr as TextExpression;
					try {
						if (n==0) {
							ex = Expression.predef_typed(name, h.act_routine,
														 h.system);
						} else if (e!=null && (tex==null || e!=tex.entity)) {
							ex = Expression.new_typed(null, e, a);
						} else {
							ex = expr;
						}
						tex = ex as TextExpression;
						if (tex!=null && tex.entity.is_scope_var()) {
							var sv = (ScopeVariable*)tex.entity;
							uint pos = h.frame!=null ? h.frame.pos : 0;
							if (!sv.in_scope(pos/256, pos%256)) ex = null;
						}
					} catch (ExpressionError err) {
						if (err is ExpressionError.NOT_INITIALIZED) 
							h.error = ErrorCode.NOT_INIT;
					}
				} else {
					ft = ct.query_by_name(out n, name, u.args==null,
										  h.act_text);
					if (n==0)
						ex = Expression.predef(name, h.act_text, h.system);
					else if (n==1 && ft!=null) 
						ex = Expression.new_text(null, ft, a);
					else
						ex = null;
				}
			}
			if (ex!=null) {
				try {
					if (expr!=null && ex!=expr) 
						ex.set_child(ex.Child.NEXT, expr.next);
					expr = ex;
					h.register(this, true, false);
				} catch (Error e) {
					ex = null;
				}
			}
			if (ex==null && h.is_match) {
				h.last_token = u.token;
				h.last_value = null; 
				h.not_unique = n>0;
				if (h.error==0) h.error = ErrorCode.UNKNOWN;
				h.is_match = false;
			}
		}

		protected Nonterm.from_token(Parser h, Token t, Token? end=null, 
									string? alternative=null, 
									bool pref=true) { 
			token = t;
			at = t.at;
			size = t.size;
			if (end!=null)  end_by(end);
		}
		
		protected Nonterm.from_manifest(Parser h, Token t, 
									   string value, TypeIdent tid, 
									   Token? end=null) { 
			token = t;
			at = t.at;
			size = t.size;
			if (end!=null)  end_by(end);
			var tp = h.system.type_at(tid);
			if (tp.is_basic()) 
				expr = new ManifestExpression(tp, value);
			else if (tp.is_string())
				expr = new ManifestExpression.string(tp, value);
			else
				expr = new ManifestExpression.typed(tp, value);
			h.register(this);
		}
		
		protected Nonterm.from_alias(Parser h, Token t) { 
			this.from_token(h, t);
			Expression? ex = null;
			AliasExpression? aex = null;
			int id = 0;
			bool is_id = false;
			if (t.name[1].isdigit()) {
				is_id = true;
				id = int.parse(t.name.substring(1));
				ex = h.number_alias(id);
				if (ex!=null) 
					aex = new AliasExpression(t.name, ex.bottom());
			} else if (h.aliases!=null) {
				string name = t.name[1:t.name.length];
				ex = h.aliases[name];
				if (ex!=null)
					aex = new AliasExpression(t.name, ex, h.places);
			}
			if (aex!=null) {
				expr = aex;
				h.register(this);
			} else {
				h.last_token = t;
				h.missing_ident = id;
				h.error = is_id ? ErrorCode.NO_IDENT : ErrorCode.NO_ALIAS;
				h.is_match = false;
			}
		}
		
		protected Nonterm.copy(Parser h, Nonterm v) {
			token = v.token;
			at = v.at;
			size = v.size;
			expr = v.expr;
		}
		
	}
	
	public class Multi : Nonterm {
		
		private Multi(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Detailed(d)")]
		public Multi._1(Parser h, Detailed d) { this.copy(h, d); }
		
		[Lemon(pattern="Multi(m) COMMA Detailed(d)")]
		public Multi._2(Parser h, Multi m, Detailed d) {
			this.copy(h, m);
			end_by(d.token);
			expr.last().set_child(expr.Child.NEXT, d.expr);
		}
	}
	
	public class Detailed : Nonterm {
		
		private Detailed(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Range(r)")]
		public Detailed._1(Parser h, Range r) {
			this.copy(h, r); 
		}
		
		[Lemon(pattern="OpenDetail(od) Multi(m) RBRACE(r)")]
		public Detailed._2(Parser h, OpenDetail od, Multi m, Token r) {
			this.copy(h, od);
			end_by(r);
			var ex = expr.bottom();
			if (ex.range!=null) ex = ex.range;
			ex.set_child(ex.Child.DETAIL, m.expr);
			h.pop_place(false);
		}
	}

	public class OpenDetail : Nonterm {
		
		private OpenDetail(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Range(r) LBRACE(b)")]
		public OpenDetail._1(Parser h, Range r, Token b) {
			this.copy(h, r);
			end_by(b);
			h.push_place(r.expr.bottom(), null);
		}

	}
	
	public class Range : Nonterm {
	
		private Range(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Single(s)")]
		public Range._1(Parser h, Single s) {
			this.copy(h, s);
		}
		
		[Lemon(pattern="OpenIndices(oi) Indices(ii) RBB(r)")]
		public Range._2(Parser h, OpenIndices oi, Indices ii, Token r) {
			this.copy(h, oi);
			end_by(r);
			int diff = oi.at-oi.pos;
			oi.at = oi.pos;
			oi.size -= diff;
			var rng = oi.rng;
			if (rng!=null) {
				oi.expr = rng;
				h.register(oi);
				rng.code = ii.code;
				rng.set_child(rng.Child.ARG, ii.expr);
				h.pop_place(true);
			} else {
				h.last_token = oi.token;
				h.error = ErrorCode.NO_RANGE;
				h.is_match = false;				
			}
		}
	}
	
	public class OpenIndices : Nonterm {

		internal RangeExpression rng;
		internal int pos;

		private OpenIndices(Parser h, Nonterm v) { this.copy(h, v); }

		[Lemon(pattern="Single(s) LBB(l)")]
		public OpenIndices._1(Parser h, Single s, Token l) {
			this.copy(h, s);
			end_by(l);
			pos = l.at;
			var sb = s.expr.bottom();
			var cls = sb.base_class();
			bool ok = cls !=null ? cls._name.fast_name=="SPECIAL" : false;
			rng = h.syntax_only
				? new RangeExpression.named(sb)
				: (ok ? new RangeExpression(sb) : null);
			if (rng!=null) {
				h.push_place(sb, rng);
				h.register(this);
			} else {
				h.last_token = l;
				h.error = ErrorCode.NO_RANGE;
				h.is_match = false;
			}
		}
	}
	
	public class Indices : Nonterm {
	
		internal RangeCode code;

		private Indices(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Single(f) COLON Single(l)")]
		public Indices._1(Parser h, Single f, Single l) {
			this.from_token(h, f.token);
			end_by(l.token);
			code = RangeCode.interval;
			expr = f.expr;
			expr.set_child(expr.Child.NEXT, l.expr);
		}
		
		[Lemon(pattern="Single(l) DOLLAR Single(c)")]
		public Indices._2(Parser h, Single f, Single c) {
			this.from_token(h, f.token);
			end_by(c.token);
			code = RangeCode.dollar;
			expr = f.expr;
			expr.set_child(expr.Child.NEXT, c.expr);
		}
		
		[Lemon(pattern="ALL(a)")]
		public Indices._3(Parser h, Token a) {
			base.from_token(h, a);
			code = RangeCode.all;
		}
		
		[Lemon(pattern="IFF(i) Single(s)")]
		public Indices._4(Parser h, Token i, Single s) {
			base.from_token(h, i);
			code = RangeCode.iff;
			expr = s.expr;
		}
	}
	
	public class Left : Nonterm {
		
		private Left(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Unqualified(u)")]
		public Left._1(Parser h, Unqualified u) {
			this.copy(h, u);
			set_root(h, null, u);
		}
		
		[Lemon(pattern="Upframe(f) Unqualified(u)")]
		public Left._1u(Parser h, Upframe f, Unqualified u) {
			this.copy(h, u);
			set_root(h, f, u);
			if (h.is_match) expr.upframe_count = f.count;
			else h.error = ErrorCode.NO_STACK;
		}
		
		[Lemon(pattern="Left(l) DOT Unqualified(u)")]
		public Left._2(Parser h, Left l, Unqualified u) {
			this.copy(h, l);
			set_down(h, u);
		}
		
		[Lemon(pattern="Left(l) Brackets(b)")]
		public Left._3(Parser h, Left l, Brackets b) {
			this.copy(h, l);
			Expression? ex = null;
			Expression exb = expr.bottom();
			string name = "[]";
			uint n = 0;
			if (h.syntax_only) {
				ex = Expression.new_named(exb, name, b.expr);
			} else {
				var tp = exb.dynamic_type;
				if (tp!=null) {
					Entity* e = tp.query_by_name(out n, name, false);
					if (n!=1) e = null;
					if (e!=null) {
						try {
							ex = Expression.new_typed(exb, e, b.expr);
						} catch (ExpressionError err) {
						}
					}
				} else {
					var ct = expr.base_class();
					FeatureText* ft = ct.query_by_name(out n, name, false);
					if (n!=1) ft = null;
					if (ft!=null) 
						ex = Expression.new_text(exb, ft, b.expr);
				}
			}
			if (ex!=null) {
				exb.set_child(exb.Child.DOWN, ex);
				b.expr = ex;
				h.register(b);
			} else if (h.is_match) {
				h.not_unique = n>1;
				h.last_token = b.token;
				h.error = ErrorCode.UNKNOWN;
				h.is_match = false;
			}
		}
		
		[Lemon(pattern="LPAREN(l) Single(s) RPAREN(r)")]
		public Left._4(Parser h, Token l, Single s, Token r) {
			this.copy(h, s);
			at = l.at;
			end_by(r);
		}
		
		private TupleType* get_tt(Parser h, Brackets b) {
			System* s = h.system;
			Expression? ex;
			uint n = 0;
			for (ex=b.expr; ex!=null; ex=ex.next) {
				s.push_type(s, ex.dynamic_type.ident);
				++n;
			}
			var tt = s.tuple_type_by_generics(n, false);
			s.pop_types(s, n);
			if (tt==null) {
				h.last_token = b.token;
				h.error = ErrorCode.NO_TUPLE;
				h.is_match = false;
			}
			return tt;
		}
		
		[Lemon(pattern="LBRACKET(l) RBRACKET(r)")]
		public Left._5(Parser h, Token l, Token r) { 
			base.from_token(h, l, r, "[...]");
			var ct = h.system.class_by_name("TUPLE");
			var tt = get_tt(h, null);
			if (tt==null) return;
			expr = new TupleExpression(null, tt, ct);
			h.register(this, true, false);
		}
		
		[Lemon(pattern="Brackets(b)")]
		public Left._6(Parser h, Brackets b) {
			base.from_token(h, b.token);
			var ct = h.system.class_by_name("TUPLE");
			var tt = get_tt(h, b);
			if (tt==null) return;
			expr = new TupleExpression(b.expr, tt, ct);
			expr.set_child(expr.Child.ARG, b.expr);
			h.register(this, true, false);
		}
		
		[Lemon(pattern="ClassSpecifier(c) DOT Unqualified(u)")]
		public Left._7(Parser h, ClassSpecifier c, Unqualified u) {  
			this.copy(h, u);
			end_by(u.token); 
			uint n;
			var old = expr;
			var g = h.system.global_by_name_and_class(u.token.name, c.cls,
													  true, false, out n);
			if (g!=null) {
				if (g.is_once()) {
					var o = (Gedb.Once*)g;
					if (!o.is_initialized()) 
						h.error = ErrorCode.NOT_INIT;
					else
						expr = new OnceExpression(o);
				} else {
					expr = new ConstantExpression((Constant*)g);
					h.register(this, true);
				}
			}
			if (expr==old) {
				h.last_token = u.token;
				h.not_unique = n>0;
				if (h.error==0) h.error = ErrorCode.NO_ONCE;
				h.is_match = false;
			}
		}
		
		[Lemon(pattern="HEAPVAR(hv)")]
		public Left._8(Parser h, Token hv) { 
			this.from_alias(h, hv); 
			if (h.is_match) h.register(this, true); 
		}
		
		[Lemon(pattern="PLACEHOLDER(p)")]
		public Left._10(Parser h, Token p) {
			base.from_token(h, p);
			uint sn = h.places_size();
			uint pn = p.name.length;
			if (h.syntax_only) {
			} else if (sn==0) {
				h.last_token = p;
				h.error = ErrorCode.BAD_PH_POS;
				h.is_match= false;
				return;
			} else if (sn<pn) {
				h.last_token = p;
				h.error = ErrorCode.BAD_PH_COUNT;
				h.is_match= false;
				return;
			}
			Gedb.Type* it = h.system.type_at(TypeIdent.INTEGER_32);
			if (sn<pn) {
				expr = new Placeholder.named(p.name, it);
			} else {
				var pl = h.get_place(pn-1);
				expr = pl.range!=null
				? new RangePlaceholder(pl.range, p.name, it)
				: new Placeholder(pl, p.name, it);
			}
			h.register(this, true);
		}
		
	}
	
	public class ClassSpecifier : Nonterm {
		
		private ClassSpecifier(Parser h, Nonterm v) { this.copy(h, v); }
		
		public ClassText* cls;
		
		[Lemon(pattern="LBRACE(l) IDENTIFIER(i) RBRACE(r)")]
		public ClassSpecifier._1(Parser h, Token l, Token i, Token r) {
			base.from_token(h, l);
			end_by(r);
			token = i;
			cls = h.system.class_by_name(token.name);
			if (cls==null) {
				h.last_token = token;
				h.error = ErrorCode.NO_CLASS;
				h.is_match = false;
			}
		}
	}

	public class Upframe : Nonterm {

		internal uint count;

		[Lemon(pattern="UPFRAME(u)")]
		public Upframe._1(Parser h, Token u) { 
			this.from_token(h, u);
			count = u.name.length;
		}
		
		[Lemon(pattern="UPFRAME_COUNT(u)")]
		public Upframe._2(Parser h, Token u) {
			this.from_token(h, u);
			string str = u.name;
			str = str.slice(1, str.length-2);
			count = int.parse(str);
		}
	}

	public class Single : Nonterm {
		
		private Single(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Left(l)")]
		public Single._1(Parser h, Left l) { 
			this.copy(h, l);
		}
		
		[Lemon(pattern="PLUS(op) Single(s)")]
		public Single._3(Parser h, Token op, Single s) {
			this.copy(h, s);
			complete_op(h, op, null);
		}
		
		[Lemon(pattern="MINUS(op) Single(s)")]
		public Single._4(Parser h, Token op, Single s) {
			this.copy(h, s);
			complete_op(h, op, null);
		}

		[Lemon(pattern="NOT(op) Single(s)")]
		public Single._5(Parser h, Token op, Single s) {
			this.copy(h, s);
			complete_op(h, op, null);
		}
		
		[Lemon(pattern="FREE_OP(op) Single(s)")]
		public Single._6(Parser h, Token op, Single s) {
			this.copy(h, s);
			complete_op(h, op, null);
		}
		
		[Lemon(pattern="Single(l) FREE_OP(op) Single(r)")]
		public Single._7(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) UP(op) Single(r)")]
		public Single._8(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) TIMES(op) Single(r)")]
		public Single._9(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}

		[Lemon(pattern="Single(l) DIV(op) Single(r)")]
		public Single._10(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) IDIV(op) Single(r)")]
		public Single._11(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
		complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) IMOD(op) Single(r)")]
		public Single._12(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) PLUS(op) Single(r)")]
		public Single._13(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}

		[Lemon(pattern="Single(l) MINUS(op) Single(r)")]
		public Single._14(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) EQ(op) Single(r)")]
		public Single._16(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			compose_comparison(h, op, OpCode.eq, r);
		}
		
		[Lemon(pattern="Single(l) NE(op) Single(r)")]
		public Single._17(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			compose_comparison(h, op, OpCode.ne, r);
		}
		
		[Lemon(pattern="Single(l) SIM(op) Single(r)")]
		public Single._18(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			compose_comparison(h, op, OpCode.sim, r);
		}
		
		[Lemon(pattern="Single(l) NSIM(op) Single(r)")]
		public Single._19(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			compose_comparison(h, op, OpCode.nsim, r);
		}
		
		[Lemon(pattern="Single(l) LT(op) Single(r)")]
		public Single._20(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) LE(op) Single(r)")]
		public Single._21(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) GT(op) Single(r)")]
		public Single._22(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) GE(op) Single(r)")]
		public Single._23(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
	}
		
		[Lemon(pattern="Single(l) AND(op) Single(r)")]
		public Single._24(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) AND(op) THEN Single(r)")]
		public Single._25(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			op.name = "and then";
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) OR(op) Single(r)")]
		public Single._26(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) OR(op) ELSE Single(r)")]
		public Single._27(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			op.name = "or else";
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) XOR(op) Single(r)")]
		public Single._28(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Single(l) IMPLIES(op) Single(r)")]
		public Single._29(Parser h, Single l, Token op, Single r) {
			this.copy(h, l);
			complete_op(h, op, r);
		}
		
		[Lemon(pattern="Manifest(m)")]
		public Single._31(Parser h, Manifest m) {
			this.copy(h, m);
		}
		
		private void complete_op(Parser h, Token op, Single? r) {
			if (!h.is_match) return;
			var v = new Nonterm.from_token(h, op);
			Expression? rhs = r!=null ? r.expr : null;
			Expression? ex = null;
			var b = expr.bottom();
			var nm = op.name;
			uint n = 0;
			if (h.syntax_only) {
				ex = Expression.new_named(b, nm, rhs);
				ex.set_child(ex.Child.ARG, rhs);
				b.set_child(b.Child.DOWN, ex);
			} else {
				var t = b.dynamic_type;
				if (t!=null) {
					if (nm=="-" && t.is_natural()) {
						b.to_integer(h.system);
						t = b.dynamic_type; 
					}
					var e = t.query_by_name(out n, nm, rhs==null);
					if (n!=1) e = null;
					if (e!=null) ex = Expression.new_typed(b, e, rhs);
				} else {
					var c = b.base_class();
					var ft = c.query_by_name(out n, nm, rhs==null);
					if (n!=1) ft = null;
					if (ft!=null && ft.is_routine()) 
						ex = Expression.new_text(b, ft, rhs);
				}
			}
			if (ex!=null) {
				v.expr = ex;
				h.register(v, true, true);
			} else {
				h.not_unique = n>0;
				h.last_token = op;
				h.error = ErrorCode.UNKNOWN;
				h.is_match = false;	  		
			}
		}
		
		private void compose_comparison(Parser h, Token eq, int code, Single r) {
			var v = new Nonterm.from_token(h, eq);
			var bex = expr.bottom();
			Gedb.Type* bt = h.system.type_at(TypeIdent.BOOLEAN);
			v.expr = new EqualityExpression(bex, eq.name, r.expr, bt);
			h.register(v, true, true);
		}
		
	}

	public class Args : Nonterm {
		
		private Args(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="Single(s)")]
		public Args._1(Parser h, Single s) { 
			this.copy(h, s);
		}
		
		[Lemon(pattern="Args(aa) COMMA Single(s)")]
		public Args._2(Parser h, Args aa, Single s) { 
			this.copy(h, aa);
			expr.last().set_child(expr.Child.NEXT, s.expr);
		}
	}	
	
	public class Unqualified : Nonterm {

		internal Nonterm? args;
		
		[Lemon(pattern="IDENTIFIER(i)")]
		public Unqualified(Parser h, Token i) {
			base.from_token(h, i);
		}
		
		[Lemon(pattern="ALIAS(a)")]
		public Unqualified._1(Parser h, Token a) {
			base.from_alias(h, a);
		}
		
		[Lemon(pattern="IDENT_LPAREN(l) Args(aa) RPAREN(r)")]
		public Unqualified._2(Parser h, Token l, Args aa, Token r) {
			this(h, l);
			end_by(r);
			args = aa;
		}

	}

	public class Brackets : Nonterm {

		private Brackets(Parser h, Nonterm v) { this.copy(h, v); }

		[Lemon(pattern="LBRACKET(l) Args(aa) RBRACKET(r)")]
		public Brackets._1(Parser h, Token l, Args aa, Token r) {  
			this.from_token(h, l);
			end_by(r);
			expr = aa.expr;
		}
	}

	public class Manifest : Nonterm {
		
		private Manifest(Parser h, Nonterm v) { this.copy(h, v); }
		
		[Lemon(pattern="CHARACTER(c)")]
		public Manifest._3(Parser h, Token c) { 
			base.from_manifest(h, c, c.name, TypeIdent.CHARACTER_8); 
		}
		
		[Lemon(pattern="STRING(s)")]
		public Manifest._4(Parser h, Token s) { 
			base.from_manifest(h, s, s.name, TypeIdent.STRING_8); 
		}
		
		[Lemon(pattern="INTEGER(i)")]
		public Manifest._5(Parser h, Token i) { 
			base.from_manifest(h, i, i.name, TypeIdent.NATURAL_64); 
		}
		
		[Lemon(pattern="REAL(r)")]
		public Manifest._6(Parser h, Token r) { 
			base.from_manifest(h, r, r.name, TypeIdent.REAL_64); 
		}
		
		[Lemon(pattern="CURRENT(c)")]
		public Manifest._7(Parser h, Token c) { 
			base.from_manifest(h, c, c.name, TypeIdent.ANY); 
		}
		
		[Lemon(pattern="RESULT(r)")]
		public Manifest._8(Parser h, Token r) { 
			base.from_manifest(h, r, r.name, TypeIdent.REAL_64); 
		}
		
		[Lemon(pattern="FALSE(f)")]
		public Manifest._9(Parser h, Token f) { 
			base.from_manifest(h, f, f.name, TypeIdent.BOOLEAN); 
		}
		
		[Lemon(pattern="TRUE(t)")]
		public Manifest._10(Parser h, Token t) { 
			base.from_manifest(h, t, t.name, TypeIdent.BOOLEAN); 
		}
		
		[Lemon(pattern="VOID(v)")]
		public Manifest._11(Parser h, Token v) { 
			base.from_manifest(h, v, v.name, TypeIdent.NONE); 
		}
		
	}
/*
  public class Alias : Nonterm {
  
  private Alias(Parser h, Nonterm v) { this.copy(h, v); }
  
  [Lemon(pattern="Alias(a) ASSIGN Single(s)")]
  public Alias._1(Parser h, Token a, Single s) {
  this.copy(h, s);
  }
  
  }
*/
} /* namespace*/
