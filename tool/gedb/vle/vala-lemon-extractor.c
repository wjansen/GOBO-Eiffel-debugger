/*	Version: 0.0
 	Author: Jeremiah Shaulov
 	License: Lesser GPL
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include <stdarg.h>
#include <glob.h>

const char *USAGE_INFO =
"vala-lemon-extractor, $Revision: 47 $\n"
"Usage: vala-lemon-extractor\n"
"Searches for *.vala files in current directory and extracts from them metadata (attributes)\n"
"with instructions for the\n"
"	1) \"flex\" lexical scanner generator\n"
"	2) \"lemon\" LALR(1) parser generator\n"
"Then generates source files for flex/lemon, *.vapi files and a makefile. The former ones are\n"
"to be converted to *.c/*.h by the `flex`/`lemon` command line tools installed on your system.\n"
"The *.vapi are to be given to valac during compilation of your *.vala sources.\n"
"They bridge vala to generated C sources.\n"
"Usually, after calling vala-lemon-extractor, you need to edit the generated _MakefileParser\n"
"according to your needs. Then execute it:\n"
"OUTPUT=my-program make -f _MakefileParser all\n"
"\n";

/*	The following substitutions must be applied:
	Nn = NameSpace
	NN = NAME_SPACE
	nn = name_space
	Pp = ParserClass
	PP = PARSER_CLASS
	pp = parser_class
	Tt = TokenClass
	TT = TOKEN_CLASS
	Mm = NameSpaceAndClassOfToken
	MM = NAME_SPACE_AND_CLASS_OF_TOKEN
	Ee = ExtraArgumentClass
	EE = EXTRA_ARGUMENT_CLASS
	@T = LIST_OF, TERMINAL, TOKENS (not namespace/class prefixed)
	@S = LIST_OF, START, CONDITIONS (not namespace/class prefixed)
	bb = start_symbol
*/
const char *INCLUDE_H_GLOB =
"#ifdef ECHO\n"
"#	undef ECHO\n"
"#endif\n"
"#define ECHO do {yyextra->token_code = 0; nn_pp_on_default_token(NN_PP(yyextra), yytext, yyleng); yyextra->n_chars_read += yyleng; return yyextra->token_code;} while (0)\n"
"\n";

const char *INCLUDE_H =
"#define NN_PP_T_END_OF_INPUT 0\n"
"#define NN_PP_T_NO_ADD_TOKEN -1\n"
"#define NN_PP_S_INITIAL 0\n"
"\n"
"#include <stdio.h>\n"
"#include <assert.h>\n"
"#include <glib.h>\n"
"#include <glib-object.h>\n"
"\n"
"G_BEGIN_DECLS\n"
"\n"
"#	ifdef NN_PP_TRACE_TOKENS\n"
"#		define nn_pp_trace_token(self, yyleng, token_code, final_token_code) \\\n"
"		{	GEnumClass *class_ref; \\\n"
"			class_ref = (GEnumClass*)g_type_class_ref(NN_TYPE_PP_T); \\\n"
"			if (token_code == final_token_code) \\\n"
"				fprintf(stderr, \"*TRACE NnPp: add_token(%s)\", g_enum_get_value(class_ref, token_code)->value_nick); \\\n"
"			else if (final_token_code!=NN_PP_T_END_OF_INPUT && final_token_code!=NN_PP_T_NO_ADD_TOKEN) \\\n"
"				fprintf(stderr, \"*TRACE NnPp: add_token(%s as %s)\", g_enum_get_value(class_ref, token_code)->value_nick, g_enum_get_value(class_ref, final_token_code)->value_nick); \\\n"
"			else \\\n"
"				fprintf(stderr, \"*TRACE NnPp: not adding token %s\", g_enum_get_value(class_ref, token_code)->value_nick); \\\n"
"			fprintf(stderr, \" at offset %d len %d\\n\", self->n_chars_read, yyleng); \\\n"
"			g_type_class_unref(class_ref); \\\n"
"		}\n"
"#	else\n"
"#		define nn_pp_trace_token(self, yyleng, token_code, final_token_code)\n"
"#	endif\n"
"\n"
"#define NN_TYPE_PP_T (nn_pp_t_get_type ())\n"
"#define NN_TYPE_PP_S (nn_pp_s_get_type ())\n"
"\n"
"#define NN_TYPE_PP (nn_pp_get_type ())\n"
"#define NN_PP(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), NN_TYPE_PP, NnPp))\n"
"#define NN_PP_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), NN_TYPE_PP, NnPpClass))\n"
"#define NN_IS_PP(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), NN_TYPE_PP))\n"
"#define NN_IS_PP_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), NN_TYPE_PP))\n"
"#define NN_PP_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), NN_TYPE_PP, NnPpClass))\n"
"\n"
"GType nn_pp_t_get_type (void) G_GNUC_CONST;\n"
"GType nn_pp_s_get_type (void) G_GNUC_CONST;\n"
"\n"
"typedef struct _NnPpPrivate NnPpPrivate;\n"
"typedef struct _NnPp NnPp;\n"
"typedef struct _NnPpClass NnPpClass;\n"
"\n"
"struct _NnPpPrivate\n"
"{	void *lex_resource;\n"
"	void *lemon_resource;\n"
"};\n"
"\n"
"struct _NnPp\n"
"{	GObject parent_instance;\n"
"	gint token_code;\n"
"	GObject *token_gobject;\n"
"	NnPpPrivate *priv;\n"
"	gboolean is_match;\n"
"	gint n_tokens_matched;\n"
"	gint n_chars_read;\n"
"};\n"
"\n"
"struct _NnPpClass\n"
"{	GObjectClass parent_class;\n"
"	void (*finalize) (NnPp *obj);\n"
"	void (*on_default_token) (NnPp *self, const gchar *value, gint value_len);\n"
"	void (*on_parse_failed) (NnPp *self);\n"
"	void (*on_syntax_error) (NnPp *self);\n"
"	void (*on_parse_accept) (NnPp *self);\n"
"};\n"
"\n"
"static gpointer nn_pp_parent_class = NULL;\n"
"static void nn_pp_finalize (GObject *obj);\n"
"\n"
"\n"
"GType nn_pp_get_type (void) G_GNUC_CONST;\n"
"NnPp *nn_pp_new (void);\n"
"NnPp *nn_pp_construct (GType object_type);\n"
"void nn_pp_add_token (NnPp *self, gint token_code, void *token);\n"
"void nn_pp_end(NnPp *self);\n"
"void nn_pp_add_stream(NnPp *self, FILE *stream);\n"
"void nn_pp_add_string(NnPp *self, char *str);\n"
"\n"
"\n"
"void nn_pp_push_state(NnPp *self, int state);\n"
"void nn_pp_pop_state(NnPp *self);\n"
"int nn_pp_top_state(NnPp *self);\n"
"\n"
"\n"
"void nn_pp_on_default_token(NnPp *self, const gchar *value, gint value_len);\n"
"void nn_pp_on_parse_failed(NnPp *self);\n"
"void nn_pp_on_syntax_error(NnPp *self);\n"
"void nn_pp_on_parse_accept(NnPp *self);\n"
"\n"
"\n"
"G_END_DECLS\n"
"\n";

const char *INCLUDE_C =
"#	include <_NnPp2.h>\n"
"\n"
"#	define NN_PP_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), NN_TYPE_PP, NnPpPrivate)) // for lex\n"
"#	define yy_accept nn_accept // lex's version conflicts with lemon one\n"
"\n"
"#	ifdef NN_PP_LEMON_ENABLED\n"
"		void *NnLemonAlloc(void *(*mallocProc)(size_t));\n"
"		void NnLemonFree(void *p, void (*freeProc)(void*));\n"
"		void NnLemon(void *yyp, int yymajor, Mm *yyminor, NnEe *l_ea);\n"
"#	endif\n"
"\n"
"GType nn_pp_t_get_type (void) {\n"
"	static volatile gsize nn_pp_t_type_id__volatile = 0;\n"
"	if (g_once_init_enter (&nn_pp_t_type_id__volatile)) {\n"
"		static const GEnumValue values[] = {{NN_PP_T_END_OF_INPUT, \"NN_PP_T_END_OF_INPUT\", \"END_OF_INPUT\"}, {NN_PP_T_NO_ADD_TOKEN, \"NN_PP_T_NO_ADD_TOKEN\", \"NO_ADD_TOKEN\"}, @t{0, NULL, NULL}};\n"
"		GType nn_pp_t_type_id;\n"
"		nn_pp_t_type_id = g_enum_register_static (\"NnT\", values);\n"
"		g_once_init_leave (&nn_pp_t_type_id__volatile, nn_pp_t_type_id);\n"
"	}\n"
"	return nn_pp_t_type_id__volatile;\n"
"}\n"
"\n"
"GType nn_pp_s_get_type (void) {\n"
"	static volatile gsize nn_pp_s_type_id__volatile = 0;\n"
"	if (g_once_init_enter (&nn_pp_s_type_id__volatile)) {\n"
"		static const GEnumValue values[] = {{NN_PP_S_INITIAL, \"NN_PP_S_INITIAL\", \"INITIAL\"}, @s{0, NULL, NULL}};\n"
"		GType nn_pp_s_type_id;\n"
"		nn_pp_s_type_id = g_enum_register_static (\"NnS\", values);\n"
"		g_once_init_leave (&nn_pp_s_type_id__volatile, nn_pp_s_type_id);\n"
"	}\n"
"	return nn_pp_s_type_id__volatile;\n"
"}\n"
"\n"
"	NnPp* nn_pp_construct(GType object_type)\n"
"	{	NnPp * self = NULL;\n"
"		self = (NnPp*) g_object_new (object_type, NULL);\n"
"		self->token_code = 0;\n"
"		self->token_gobject = NULL;\n"
"		self->is_match = TRUE;\n"
"		self->n_tokens_matched = 0;\n"
"		self->n_chars_read = 0;\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			nn_pp_lex_init_extra(self, (yyscan_t*)&self->priv->lex_resource);\n"
"#		endif\n"
"#		ifdef NN_PP_LEMON_ENABLED\n"
"			self->priv->lemon_resource = NnLemonAlloc(g_malloc);\n"
"#		endif\n"
"		return self;\n"
"	}\n"
"\n"
"	NnPp* nn_pp_new(void)\n"
"	{	return nn_pp_construct(NN_TYPE_PP);\n"
"	}\n"
"\n"
"	void nn_pp_add_token(NnPp *self, gint token_code, void *token)\n"
"	{	self->n_tokens_matched++;\n"
"#		ifdef NN_PP_LEMON_ENABLED\n"
"			Mm *token_obj;\n"
"			g_return_if_fail(self != NULL);\n"
"			token_obj = token==NULL ? NULL : MM(g_object_ref(G_OBJECT(token)));\n"
"			NnLemon(self->priv->lemon_resource, token_code, token_obj, NN_EE(self));\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_end(NnPp *self)\n"
"	{\n"
"#		ifdef NN_PP_LEMON_ENABLED\n"
"			g_return_if_fail(self != NULL);\n"
"			NnLemon(self->priv->lemon_resource, 0, NULL, NN_EE(self));\n"
"#		endif\n"
"	}\n"
"\n"
"#	ifdef NN_PP_LEX_ENABLED\n"
"		YY_BUFFER_STATE nn_pp__create_buffer(FILE *file,int size ,yyscan_t yyscanner );\n"
"		void nn_pp_push_buffer_state(YY_BUFFER_STATE new_buffer ,yyscan_t yyscanner );\n"
"		void nn_pp_pop_buffer_state(yyscan_t yyscanner );\n"
"#	endif\n"
"\n"
"	void nn_pp_add_stream(NnPp *self, FILE *stream)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			gint token_code;\n"
"			yyscan_t scanner;\n"
"			if (self->is_match)\n"
"			{	scanner = (yyscan_t)self->priv->lex_resource;\n"
"				nn_pp_push_buffer_state(nn_pp__create_buffer(stream, YY_BUF_SIZE, scanner), scanner);\n"
"				while ((token_code = nn_pp_lex(scanner)) && self->is_match)\n"
"				{	if (token_code != NN_PP_T_NO_ADD_TOKEN)\n"
"					{	nn_pp_add_token(self, token_code, self->token_gobject);\n"
"					}\n"
"				}\n"
"				nn_pp_pop_buffer_state(scanner);\n"
"			}\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_add_string(NnPp *self, char *str)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			gint token_code;\n"
"			yyscan_t scanner;\n"
"			YY_BUFFER_STATE buffer;\n"
"			if (self->is_match)\n"
"			{	scanner = (yyscan_t)self->priv->lex_resource;\n"
"				buffer = nn_pp__scan_string(str, scanner);\n"
"				while ((token_code = nn_pp_lex(scanner)) && self->is_match)\n"
"				{	if (token_code != NN_PP_T_NO_ADD_TOKEN)\n"
"					{	nn_pp_add_token(self, token_code, self->token_gobject);\n"
"					}\n"
"				}\n"
"				nn_pp__delete_buffer(buffer, scanner);\n"
"			}\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_push_state(NnPp *self, int state)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			g_return_if_fail(self != NULL);\n"
"			yy_push_state(state, self->priv->lex_resource);\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_pop_state(NnPp *self)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			g_return_if_fail(self != NULL);\n"
"			yy_pop_state(self->priv->lex_resource);\n"
"#		endif\n"
"	}\n"
"\n"
"	int nn_pp_top_state(NnPp *self)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			g_return_if_fail(self != NULL);\n"
"			return (((struct yyguts_t*)self->priv->lex_resource)->yy_start - 1) / 2 /*yy_top_state(self->priv->lex_resource)*/;\n"
"#		else\n"
"			return 0;\n"
"#		endif\n"
"	}\n"
"\n"
"	static void nn_pp_instance_init(NnPp *self)\n"
"	{	self->priv = NN_PP_GET_PRIVATE(self);\n"
"	}\n"
"\n"
"	static void nn_pp_finalize(GObject *obj)\n"
"	{	NnPp * self;\n"
"		self = NN_PP (obj);\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			nn_pp_lex_destroy((yyscan_t)self->priv->lex_resource);\n"
"#		endif\n"
"#		ifdef NN_PP_LEMON_ENABLED\n"
"			NnLemonFree(self->priv->lemon_resource, g_free);\n"
"#		endif\n"
"		if (self->token_gobject != NULL)\n"
"		{	g_object_unref(self->token_gobject);\n"
"		}\n"
"		G_OBJECT_CLASS(nn_pp_parent_class)->finalize(obj);\n"
"	}\n"
"\n"
"	static void nn_pp_real_on_default_token(NnPp *self, const gchar *value, gint value_len)\n"
"	{\n"
"#		ifdef NN_PP_TRACE_TOKENS\n"
"			fprintf(stderr, \"*TRACE on_default_token(): %s\\n\", value);\n"
"#		endif\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			self->is_match = FALSE;\n"
"#		endif\n"
"	}\n"
"\n"
"	static void nn_pp_real_on_parse_failed(NnPp *self)\n"
"	{	self->is_match = FALSE;\n"
"	}\n"
"\n"
"	static void nn_pp_real_on_syntax_error(NnPp *self)\n"
"	{	self->is_match = FALSE;\n"
"	}\n"
"\n"
"	static void nn_pp_real_on_parse_accept(NnPp *self)\n"
"	{\n"
"	}\n"
"\n"
"	void nn_pp_on_default_token(NnPp *self, const gchar *value, gint value_len)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			NN_PP_GET_CLASS(self)->on_default_token(self, value, value_len);\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_on_parse_failed(NnPp *self)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			NN_PP_GET_CLASS(self)->on_parse_failed(self);\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_on_syntax_error(NnPp *self)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			NN_PP_GET_CLASS(self)->on_syntax_error(self);\n"
"#		endif\n"
"	}\n"
"\n"
"	void nn_pp_on_parse_accept(NnPp *self)\n"
"	{\n"
"#		ifdef NN_PP_LEX_ENABLED\n"
"			NN_PP_GET_CLASS(self)->on_parse_accept(self);\n"
"#		endif\n"
"	}\n"
"\n"
"	static void nn_pp_class_init(NnPpClass *klass)\n"
"	{	nn_pp_parent_class = g_type_class_peek_parent(klass);\n"
"		g_type_class_add_private(klass, sizeof(NnPpPrivate));\n"
"		G_OBJECT_CLASS(klass)->finalize = nn_pp_finalize;\n"
"		NN_PP_CLASS(klass)->on_default_token = nn_pp_real_on_default_token;\n"
"		NN_PP_CLASS(klass)->on_parse_failed = nn_pp_real_on_parse_failed;\n"
"		NN_PP_CLASS(klass)->on_syntax_error = nn_pp_real_on_syntax_error;\n"
"		NN_PP_CLASS(klass)->on_parse_accept = nn_pp_real_on_parse_accept;\n"
"	}\n"
"\n"
"	GType nn_pp_get_type(void)\n"
"	{	static volatile gsize nn_pp_type_id__volatile = 0;\n"
"		if (g_once_init_enter (&nn_pp_type_id__volatile)) {\n"
"			static const GTypeInfo g_define_type_info = { sizeof (NnPpClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) nn_pp_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (NnPp), 0, (GInstanceInitFunc) nn_pp_instance_init, NULL };\n"
"			GType nn_pp_type_id;\n"
"			nn_pp_type_id = g_type_register_static (G_TYPE_OBJECT, \"NnPp\", &g_define_type_info, 0);\n"
"			g_once_init_leave (&nn_pp_type_id__volatile, nn_pp_type_id);\n"
"		}\n"
"		return nn_pp_type_id__volatile;\n"
"	}\n"
"\n";

const char *VAPI =
"namespace Nn\n"
"{	[CCode(cheader_filename = \"@0\", cname = \"NnPp\", cprefix = \"nn_pp_\", type_id = \"NN_TYPE_PP\", ref_function = \"g_object_ref\", unref_function = \"g_object_unref\")]\n"
"	public class Pp\n"
"	{	/**	END_OF_INPUT - instructs Flex to stop reading input data.\n"
"			NO_ADD_TOKEN - instructs Flex to ignore this token, that is, not to call add_token().\n"
"			Then all known terminal symbols that include:\n"
"			1) Names of functions marked with [Flex()] attribute.\n"
"			2) Words occured in Lemon patterns consisting from capital letters only.\n"
"			3) Words defined by [Flex(token = \"NAME1 NAME2 NAME3\")].\n"
"			4) Words defined by [Lemon(left = \"NAME1 NAME2 NAME3\")].\n"
"			5) Words defined by [Lemon(right = \"NAME1 NAME2 NAME3\")].\n"
"			6) Words defined by [Lemon(nonassoc = \"NAME1 NAME2 NAME3\")].\n"
"		 **/\n"
"		[CCode (cprefix = \"NN_PP_T_\", type_id = \"NN_TYPE_PP_T\", cname = \"int\")]\n"
"		public enum TokenCode\n"
"		{	END_OF_INPUT,NO_ADD_TOKEN,@T\n"
"		}\n"
"\n"
"		/**	INITIAL - the initial state of Flex (before push_state() is called).\n"
"			Then states defined by [Flex(s = \"...\")] or [Flex(x = \"...\")].\n"
"			To enter a state call push_state(State.THE_STATE_NAME).\n"
"			To leave state call pop_state().\n"
"			To check current state - use this.state.\n"
"		 **/\n"
"		[CCode (cprefix = \"NN_PP_S_\", type_id = \"NN_TYPE_PP_S\", cname = \"int\")]\n"
"		public enum State\n"
"		{	INITIAL,@S\n"
"		}\n"
"\n"
"		/**	Always chain to this. This creates instances of Flex and/or Lemon.\n"
"		 **/\n"
"		public Pp();\n"
"\n"
"		/**	Temporary place where default token_code is stored before entering Flex action.\n"
"			The action is welcome to modify it.\n"
"			After action finishes, this code will be passed to add_token().\n"
"		 **/\n"
"		public TokenCode token_code; // place where token_code is stored temporarily before executing each action, so the action can modify it\n"
"\n"
"		public GLib.Object? token_gobject; // temporary place\n"
"\n"
"		/**	Same purpose as token_code. Each token in addition to token_code can have\n"
"			such object where you can store text value of a token. E.g. token \"10\" can\n"
"			have token_code = TokenCode.NUMBER, and token = new Token(\"10\").\n"
"			It's also practical to store location of the token in input source (line number).\n"
"		 **/\n"
"		public Mm? token {get {return (Mm?)token_gobject;} set {token_gobject = (GLib.Object)value;}} // temporary place\n"
"\n"
"		/**	Boolean value, initially true, that Flex action is welcome to set to false.\n"
"			If set to false, Flex scan will be terminated. This is the same effect as\n"
"			setting token_code = TokenCode.END_OF_INPUT, but later you can decide\n"
"			that scan was unsuccessful if !is_match.\n"
"		 **/\n"
"		public bool is_match;\n"
"\n"
"		/**	Initially 0. Is incremented by add_token().\n"
"		 **/\n"
"		public int n_tokens_matched;\n"
"\n"
"		/**	Initially 0. Grows as characters are read from Flex input source.\n"
"			This allows you to implement line counting. Declare your variable n_line.\n"
"			When \\n arrives, increment it, and reset n_chars_read to 0. In this usage\n"
"			pattern n_chars_read will be character position on current line.\n"
"		 **/\n"
"		public int n_chars_read;\n"
"\n"
"		/**	Convenience property to consider there was \"whole match\".\n"
"		 **/\n"
"		public bool is_whole_match {get {return is_match && n_tokens_matched==1;}}\n"
"\n"
"		/**	Wrapper around Lemon's ParseTrace().\n"
"		 **/\n"
"		[CCode (cname = \"NnLemonTrace\")]\n"
"		public static void lemon_trace(GLib.FileStream stream, string prefix);\n"
"\n"
"		/**	1) Increments n_tokens_matched.\n"
"			2) If there is Lemon parser created for this class, calls Lemon's Parse().\n"
"		 **/\n"
"		public void add_token(TokenCode token_code, Mm? token);\n"
"\n"
"		/**	Call to indicate that no more tokens will be added for current parsing session.\n"
"			Calls Lemon's Parse(0, NULL).\n"
"			If the start symbol doesn't match at this time, syntax error is reported.\n"
"		 **/\n"
"		public void end();\n"
"\n"
"		/**	Initializes Flex scan. Calls add_token() for each determined token in input stream.\n"
"			Can be called recursively from a Flex action. In this case \"include\" effect is achieved.\n"
"		 **/\n"
"		public void add_stream(GLib.FileStream stream);\n"
"\n"
"		/**	Initializes Flex scan from a string. Flex crashes if this function calls add_stream()\n"
"			to include file/stream, but it seems that recursive add_string() works.\n"
"		 **/\n"
"		public void add_string(string str);\n"
"\n"
"		/**	Enter a state.\n"
"		 **/\n"
"		public void push_state(State state);\n"
"\n"
"		/**	Exit last entered state.\n"
"		 **/\n"
"		public void pop_state();\n"
"\n"
"		/**	Get next char from input buffer.\n"
"		 **/\n"
"		public int input();\n"
"\n"
"		/**	Put char back to input buffer.\n"
"		 **/\n"
"		public void unput(int c);\n"
"\n"
"		/**	The current state. Initially State.INITIAL.\n"
"		 **/\n"
"		public State state\n"
"		{	[CCode (cname = \"nn_pp_top_state\")]\n"
"			get;\n"
"		}\n"
"\n"
"		/**	Override to hook default tokens (one that don't match any of defined).\n"
"			This is the Flex's default action (ECHO).\n"
"		 **/\n"
"		public virtual void on_default_token(string value, int value_len);\n"
"\n"
"		/**	Override to hook Lemon's parse failure.\n"
"			This is called from Lemon's %parse_failed directive.\n"
"		 **/\n"
"		public virtual void on_parse_failed();\n"
"\n"
"		/**	Override to hook Lemon's syntax error.\n"
"			This is called from Lemon's %syntax_error directive.\n"
"		 **/\n"
"		public virtual void on_syntax_error();\n"
"\n"
"		/**	Override to hook Lemon's parse accept.\n"
"			This is called from Lemon's %parse_accept directive.\n"
"		 **/\n"
"		public virtual void on_parse_accept();\n"
"	}\n"
"}\n";

const char *LEX_HEAD =
"%option reentrant noyywrap stack prefix=\"nn_pp_\"\n"
"%option extra-type=\"NnPp*\"\n"
"%{\n"
"#	include <_NnPp2.h>\n"
"%}\n";

const char *LEX_FOOT =
"int nn_pp_input(NnPp *self)\n"
"{	self->n_chars_read++;\n"
"	return input(self->priv->lex_resource);\n"
"}\n"
"\n"
"void nn_pp_unput(NnPp *self, int c)\n"
"{	self->n_chars_read--;\n"
"	return yyunput(c, ((struct yyguts_t*)self->priv->lex_resource)->yytext_ptr, self->priv->lex_resource);\n"
"}\n";

const char *LEMON_FOOT =
"l_translation_unit ::= bb.\n"
"%start_symbol {l_translation_unit}\n"
"%name NnLemon\n"
"%token_prefix NN_PP_T_\n"
"%token_destructor\n"
"{	if ($$ != NULL) g_object_unref($$);\n"
"}\n"
"%default_destructor\n"
"{	g_object_unref($$);\n"
"}\n"
"%parse_failure\n"
"{\n"
"#	ifdef NN_PP_TRACE_SYMBOLS\n"
"		fprintf(stderr, \"*TRACE on_parse_failed()\\n\");\n"
"#	endif\n"
"	nn_pp_on_parse_failed(NN_PP(l_ea));\n"
"}\n"
"%syntax_error\n"
"{\n"
"#	ifdef NN_PP_TRACE_SYMBOLS\n"
"		fprintf(stderr, \"*TRACE on_syntax_error()\\n\");\n"
"#	endif\n"
"	nn_pp_on_syntax_error(NN_PP(l_ea));\n"
"}\n"
"%parse_accept\n"
"{\n"
"#	ifdef NN_PP_TRACE_SYMBOLS\n"
"		fprintf(stderr, \"*TRACE on_parse_accept()\\n\");\n"
"#	endif\n"
"	nn_pp_on_parse_accept(NN_PP(l_ea));\n"
"}\n"
"%token_type {Mm*}\n"
"%extra_argument {NnEe *l_ea}\n"
"\n";

const char *MAKEFILE_HEAD =
"CC ?= cc\n"
"CFLAGS ?= `pkg-config --cflags glib-2.0 gobject-2.0`\n"
"LIBS ?= `pkg-config --libs glib-2.0 gobject-2.0`\n"
"LEX ?= lex\n"
"LEMON ?= lemon\n"
"CFLAGS_VALA ?=\n"
"OUTPUT ?= a.out\n"
"\n";

enum {START_SYMBOL=1, TOKEN_TYPE=2, EXTRA_ARGUMENT=3, FATAL_ERROR=4};
enum {IDENT_SIZE=64, N_NESTED_CLASSES=5};
const char *WITH_BRACES = ",stack_size,";

typedef struct
{	char *namespace_name, *prefix, *extra_argument_class; // copy by strdup()
	int with_flex;
	int with_lemon;
}	maketarget_t;

typedef struct
{	char class_name[IDENT_SIZE], term_tokens_lex[8*1024], start_conds[4*1024];
	FILE *h_out_lex;
	FILE *h_out_lex_body;
	int trace_tokens;
}	lex_t;

typedef struct _namespace_arr_t
{	struct _namespace_t
	{	char name[IDENT_SIZE]; 
		char name_lower[IDENT_SIZE]; 
		char cur_class[IDENT_SIZE*N_NESTED_CLASSES]; 
		char start_symbol_class[IDENT_SIZE*N_NESTED_CLASSES]; 
		char token_type_class[IDENT_SIZE*N_NESTED_CLASSES]; 
		char token_type_class_dot[IDENT_SIZE*N_NESTED_CLASSES]; 
		char extra_argument_class[IDENT_SIZE*N_NESTED_CLASSES]; 
		char extra_argument_class_dot[IDENT_SIZE*N_NESTED_CLASSES]; 
		char term_tokens[8*1024]; 
		char tokens[16*1024];
		FILE *h_out_lemon;
		lex_t lex_with_lemon, lex;
		lex_t *cur_lex; // points to one of lex_with_lemon, lex
		int trace_symbols;
		struct _namespace_arr_t *parent;
	}	arr[32];
	int size;
	char *parser_class;
	maketarget_t *maketargets;
	int n_maketargets;
	char vala_files[2*1024]; 
	char c_files[2*1024]; 
	char vapi_files[2*1024]; 
	char vapi_pkgs[2*1024]; 
	char o_files[2*1024]; 
	char make_temp_files[4*1024]; 
	char make_temp_files_ext[4*1024];
}	namespace_arr_t;

typedef struct _namespace_t namespace_t;

void str_toupper(char *pbuffer)
{	while (*pbuffer != '\0')
	{	*pbuffer = toupper(*pbuffer);
		pbuffer++;
	}
}

/**	@param
 *	@param
 *	@param word - may not be null-terminated
 *	@param word_len - number of bytes that word occupies. I will access word[word_len] (one byte more), so it must be valid address.
 *	@return true if appended
 **/
int append_if_not_present(char *append_to, int sizeof_append_to, char *word, int word_len, char separ)
{	int len;
	char c, *found, *find_from;
	/* begin */
	len = strlen(append_to);
	if (len+word_len+1 < sizeof_append_to) // plus separ
	{	found = NULL;
		if (len > 0)
		{	append_to[len++] = separ;
			c = word[word_len];
			word[word_len] = '\0';
			find_from = append_to;
			while (1)
			{	found = strstr(find_from, word);
				if (found == NULL) break; // not found
				if (found==append_to && append_to[word_len]==separ) break; // found
				if (found[-1]==separ && found[word_len]==separ) break; // found
				find_from = found + 1;
			}
			word[word_len] = c;
		}
		if (found == NULL)
		{	memcpy(append_to+len, word, word_len);
			append_to[len + word_len] = '\0';
			return 1;
		}
		else
		{	append_to[len-1] = '\0';
		}
	}
	return 0;
}

/**	Converts words in pbuffer from TypicalRepresentation1 to typical_representation_1.
 *	Words consisting of [A-Z0-9_] only (no lowercase letters) are ignored.
 *	@param pbuffer - pointer to character buffer with which to proceed.
 *	@param sizeof_buffer - the sizeof(pbuffer). There must be a little room after \0, so i can add characters.
 *	@param prefix_capitals - if not NULL, will add this prefix (converted to uppercase) plus '_' char before each [A-Z0-9_]+ word.
 *	@param append_capitals_to - if not NULL, will append to this string uppercase words that was found in pbuffer. Only those which are not present yet are appended. Uses ',' as separator.
 *	@param sizeof_append_capitals_to - the sizeof(append_capitals_to).
 *	@return false if there was not enough room.
 **/
int from_camel_case(char *pbuffer, int sizeof_buffer, char *prefix_capitals, char *append_capitals_to, int sizeof_append_capitals_to)
{	char *p, *q;
	int insert_pos[5*1024], insert_pos_size=0; // insert underscores at each of this positions
	char insert_cap[sizeof(insert_pos) / sizeof(insert_pos[0])];
	int from, to, n_insert_cap=0, prefix_capitals_len=0, grow_by, is_prev_digit;
	/* begin */
	for (p=pbuffer; *p!='\0'; p++)
	{	if (isalpha(*p) || *p=='_')
		{	// 1. skip words consisting of CAPITALS_AND_UNDERSCORES_ONLY
			if ((*p>='A' && *p<='Z') || *p=='_' || isdigit(*p))
			{	for (q=p+1; (*q>='A' && *q<='Z') || *q=='_' || isdigit(*q); q++);
				if (!isalnum(*q) && *q!='_') // all letters are capital
				{	if (prefix_capitals != NULL)
					{	if (insert_pos_size == sizeof(insert_pos)/sizeof(insert_pos[0]))
						{	return 0;
						}
						insert_cap[insert_pos_size] = 1;
						insert_pos[insert_pos_size++] = p - 1 - pbuffer;
						n_insert_cap++;
					}
					if (append_capitals_to != NULL)
					{	append_if_not_present(append_capitals_to, sizeof_append_capitals_to, p, q-p, ',');
					}
					p = q - 1;
					continue;
				}
			}
			// 2. from camel case
			*p = tolower(*p);
			for (p+=1; isalnum(*p) || *p=='_'; p++)
			{	if (*p>='A' && *p<='Z')
				{	if (insert_pos_size == sizeof(insert_pos)/sizeof(insert_pos[0]))
					{	return 0;
					}
					insert_cap[insert_pos_size] = 0;
					insert_pos[insert_pos_size++] = p - 1 - pbuffer;
					*p = tolower(*p);
				}
			}
			// Previously used the following. That was not the algorithm that valac uses to convert from CamelCase.
			/*is_prev_digit = 0;
			for (p+=1; isalnum(*p) || *p=='_'; p++)
			{	if (*p>='A' && *p<='Z' || !is_prev_digit && isdigit(*p))
				{	if (insert_pos_size == sizeof(insert_pos)/sizeof(insert_pos[0]))
					{	return 0;
					}
					insert_cap[insert_pos_size] = 0;
					insert_pos[insert_pos_size++] = p - 1 - pbuffer;
					*p = tolower(*p);
				}
				is_prev_digit = isdigit(*p);
			}*/
			p--;
		}
	}
	assert(*p == '\0');
	if (prefix_capitals != NULL)
	{	prefix_capitals_len = strlen(prefix_capitals) + 1; // count additional '_' at end
	}
	grow_by = insert_pos_size + n_insert_cap*(prefix_capitals_len-1);
	if ((p - pbuffer) + grow_by >= sizeof_buffer)
	{	return 0;
	}
	for (from=p-pbuffer, to=from+grow_by; from>=-1; from--, to--)
	{	if (insert_pos_size>0 && from==insert_pos[insert_pos_size-1])
		{	// add '_'
			pbuffer[to--] = '_';
			if (insert_cap[insert_pos_size-1])
			{	// add prefix
				for (q=prefix_capitals+prefix_capitals_len-2; q>=prefix_capitals; q--)
				{	pbuffer[to--] = toupper(*q);
				}
			}
			insert_pos_size--;
		}
		if (from >= 0)
		{	pbuffer[to] = pbuffer[from];
		}
	}
	assert(from==-2 && to==-2);
	return 1;
}

/**	Copy NnPp | NN_PP | nn_pp to pprefix.
 *	what_case: -1 - lower, 0 - camel, 1 - upper.
 **/
void copy_prefix(namespace_t *cur_namespace, lex_t *lex, int what_case, char *pprefix, int sizeof_prefix)
{	char class_name[IDENT_SIZE*4];
	int len;
	/* begin */
	assert(sizeof_prefix >= 2 * (IDENT_SIZE + sizeof(lex->class_name) + sizeof(cur_namespace->name)));
	strcpy(pprefix, what_case==0 ? cur_namespace->name : cur_namespace->name_lower);
	if (what_case > 0)
	{	str_toupper(pprefix);
	}
	if (what_case != 0)
	{	strcat(pprefix, "_");
	}
	len = strlen(pprefix);
	if (lex == &cur_namespace->lex_with_lemon)
	{	strcpy(pprefix+len, cur_namespace->extra_argument_class);
	}
	else
	{	strcpy(pprefix+len, lex->class_name);
	}
	strcat(pprefix+len, cur_namespace->parent->parser_class);
	if (what_case == 0)
	{	return;
	}
	from_camel_case(pprefix+len, sizeof_prefix-len, NULL, NULL, 0);
	if (what_case < 0)
	{	return;
	}
	str_toupper(pprefix+len);
}

void print_list_to_enum_def(FILE *output, char *namespace_upper, char *parser_class_upper, char *type, char *list)
{	char *p;
	/* begin */
	if (*list != '\0')
	{	while (1)
		{	p = strchr(list, ',');
			if (p != NULL)
			{	*p = '\0';
			}
			fprintf(output, "{%s_%s_%s_%s, \"%s_%s_%s_%s\", \"%s\"}, ", namespace_upper, parser_class_upper, type, list, namespace_upper, parser_class_upper, type, list, list);
			if (p == NULL) break;
			*p = ',';
			list = p + 1;
		}
	}
}

/**	is_vapi: 1) nested class names are printed with dots. 2) current namespace is omitted in Mm (if there is class named C inside namespace C, then C.X means "X" inside "class C", not "X" inside "namespace C" as desired)
 **/
void subst_print(FILE *stream, const char *str, namespace_t *cur_namespace, int is_vapi, lex_t *lex, char **custom_strings, int n_custom_strings)
{	int n_str;
	char *NameSpace, NAME_SPACE[IDENT_SIZE*2], *name_space;
	char ParserClass[IDENT_SIZE*2], PARSER_CLASS[IDENT_SIZE*4], parser_class[IDENT_SIZE*4];
	char *TokenClass, TOKEN_CLASS[IDENT_SIZE*2];
	char NamespaceAndClassOfToken[IDENT_SIZE*2];
	char NAMESPACE_AND_CLASS_OF_TOKEN[IDENT_SIZE*2];
	char *ExtraArgumentClass, EXTRA_ARGUMENT_CLASS[IDENT_SIZE*2];
	char *TERMINAL_TOKENS;
	char *START_CONDS;
	char start_symbol[IDENT_SIZE*2];
	/* begin */
	assert(lex == &cur_namespace->lex || lex == &cur_namespace->lex_with_lemon);
	// NameSpace
	NameSpace = cur_namespace->name;
	// name_space
	name_space = cur_namespace->name_lower;
	// NAME_SPACE
	strcpy(NAME_SPACE, name_space);
	str_toupper(NAME_SPACE);
	// ParserClass
	if (lex == &cur_namespace->lex)
	{	strcpy(ParserClass, lex->class_name);
	}
	else
	{	strcpy(ParserClass, cur_namespace->extra_argument_class);
	}
	strcat(ParserClass, cur_namespace->parent->parser_class);
	// parser_class
	strcpy(parser_class, ParserClass);
	from_camel_case(parser_class, sizeof(parser_class), NULL, NULL, 0);
	// PARSER_CLASS
	strcpy(PARSER_CLASS, parser_class);
	str_toupper(PARSER_CLASS);
	// TokenClass
	TokenClass = is_vapi ? cur_namespace->token_type_class_dot : cur_namespace->token_type_class;
	if (TokenClass[0] == '\0')
	{	TokenClass = "Object";
	}
	// TOKEN_CLASS
	if (cur_namespace->token_type_class[0] != '\0')
	{	strcpy(TOKEN_CLASS, cur_namespace->token_type_class);
		from_camel_case(TOKEN_CLASS, sizeof(TOKEN_CLASS), NULL, NULL, 0);
		str_toupper(TOKEN_CLASS);
	}
	else
	{	strcpy(TOKEN_CLASS, "OBJECT");
	}
	// NamespaceAndClassOfToken
	if (cur_namespace->token_type_class[0] != '\0')
	{	if (!is_vapi)
		{	strcpy(NamespaceAndClassOfToken, cur_namespace->name);
		}
		else
		{	NamespaceAndClassOfToken[0] = '\0';
		}
	}
	else
	{	if (!is_vapi)
		{	strcpy(NamespaceAndClassOfToken, "G");
		}
		else
		{	strcpy(NamespaceAndClassOfToken, "GLib");
		}
	}
	if (is_vapi && NamespaceAndClassOfToken[0]!='\0')
	{	strcat(NamespaceAndClassOfToken, ".");
	}
	strcat(NamespaceAndClassOfToken, TokenClass);
	// NAMESPACE_AND_CLASS_OF_TOKEN
	if (cur_namespace->token_type_class[0] != '\0')
	{	strcpy(NAMESPACE_AND_CLASS_OF_TOKEN, NamespaceAndClassOfToken);
		from_camel_case(NAMESPACE_AND_CLASS_OF_TOKEN, sizeof(NAMESPACE_AND_CLASS_OF_TOKEN), NULL, NULL, 0);
		str_toupper(NAMESPACE_AND_CLASS_OF_TOKEN);
	}
	else
	{	strcpy(NAMESPACE_AND_CLASS_OF_TOKEN, "G");
	}
	// ExtraArgumentClass
	if (lex == &cur_namespace->lex)
	{	ExtraArgumentClass = lex->class_name;
	}
	else
	{	ExtraArgumentClass = is_vapi ? cur_namespace->extra_argument_class_dot : cur_namespace->extra_argument_class;
	}
	// EXTRA_ARGUMENT_CLASS
	strcpy(EXTRA_ARGUMENT_CLASS, cur_namespace->extra_argument_class);
	from_camel_case(EXTRA_ARGUMENT_CLASS, sizeof(EXTRA_ARGUMENT_CLASS), NULL, NULL, 0);
	str_toupper(EXTRA_ARGUMENT_CLASS);
	// TERMINAL_TOKENS
	TERMINAL_TOKENS = lex==&cur_namespace->lex_with_lemon ? cur_namespace->term_tokens : lex->term_tokens_lex;
	// START_CONDS
	START_CONDS = cur_namespace->cur_lex->start_conds;
	// start_symbol
	strcpy(start_symbol, cur_namespace->start_symbol_class);
	from_camel_case(start_symbol, sizeof(start_symbol), NULL, NULL, 0);
	// Print
	while (str[0]!='\0' && str[1]!='\0')
	{	if (n_custom_strings>0 && str[0]=='@' && isdigit(str[1]))
		{	assert(custom_strings != NULL);
			n_str = str[1] - '0';
			if (n_str < n_custom_strings)
			{	fputs(custom_strings[n_str], stream);
				str++;
			}
		}
		else switch (str[0] + 256*str[1])
		{	case 'N' + 256*'n': fputs(NameSpace, stream); str++; break;
			case 'N' + 256*'N': fputs(NAME_SPACE, stream); str++; break;
			case 'n' + 256*'n': fputs(name_space, stream); str++; break;
			case 'P' + 256*'p': fputs(ParserClass, stream); str++; break;
			case 'P' + 256*'P': fputs(PARSER_CLASS, stream); str++; break;
			case 'p' + 256*'p': fputs(parser_class, stream); str++; break;
			case 'T' + 256*'t': fputs(TokenClass, stream); str++; break;
			case 'T' + 256*'T': fputs(TOKEN_CLASS, stream); str++; break;
			case 'M' + 256*'m': fputs(NamespaceAndClassOfToken, stream); str++; break;
			case 'M' + 256*'M': fputs(NAMESPACE_AND_CLASS_OF_TOKEN, stream); str++; break;
			case 'E' + 256*'e': fputs(ExtraArgumentClass, stream); str++; break;
			case 'E' + 256*'E': fputs(EXTRA_ARGUMENT_CLASS, stream); str++; break;
			case 'b' + 256*'b': fputs(start_symbol, stream); str++; break;
			case '@' + 256*'T': fputs(TERMINAL_TOKENS, stream); str++; break;
			case '@' + 256*'S': fputs(START_CONDS, stream); str++; break;
			case '@' + 256*'t': print_list_to_enum_def(stream, NAME_SPACE, PARSER_CLASS, "T", TERMINAL_TOKENS); str++; break;
			case '@' + 256*'s': print_list_to_enum_def(stream, NAME_SPACE, PARSER_CLASS, "S", START_CONDS); str++; break;
			default: fputc(str[0], stream);
		}
		str++;
	}
	if (str[0] != '\0')
	{	fputc(str[0], stream);
	}
}

namespace_t *select_namespace(namespace_arr_t *namespaces, char *name)
{	int i;
	namespace_t *p;
	/* begin */
	for (i=namespaces->size-1; i>=0; i--)
	{	if (strcmp(namespaces->arr[i].name, name) == 0)
		{	return &namespaces->arr[i];
		}
	}
	if (namespaces->size >= sizeof(namespaces->arr)/sizeof(namespaces->arr[0]))
	{	fprintf(stderr, "Too many namespaces in single source file\n");
		return NULL;
	}
	p = &namespaces->arr[namespaces->size];
	strncpy(p->name, name, IDENT_SIZE);
	strncpy(p->name_lower, name, IDENT_SIZE);
	from_camel_case(p->name_lower, IDENT_SIZE, NULL, NULL, 0);
	p->parent = namespaces;
	p->name[IDENT_SIZE-1] = '\0';
	p->cur_class[0] = '\0';
	p->start_symbol_class[0] = '\0';
	p->token_type_class[0] = '\0';
	p->token_type_class_dot[0] = '\0';
	p->extra_argument_class[0] = '\0';
	p->extra_argument_class_dot[0] = '\0';
	p->term_tokens[0] = '\0';
	p->tokens[0] = '\0';
	p->h_out_lemon = NULL;
	p->cur_lex = &p->lex_with_lemon;
	p->trace_symbols = 0;
	// lex_with_lemon
	p->lex_with_lemon.class_name[0] = '\0';
	p->lex_with_lemon.term_tokens_lex[0] = '\0';
	p->lex_with_lemon.start_conds[0] = '\0';
	p->lex_with_lemon.h_out_lex = NULL;
	p->lex_with_lemon.h_out_lex_body = NULL;
	p->lex_with_lemon.trace_tokens = 0;
	// lex
	p->lex.class_name[0] = '\0';
	p->lex.term_tokens_lex[0] = '\0';
	p->lex.start_conds[0] = '\0';
	p->lex.h_out_lex = NULL;
	p->lex.h_out_lex_body = NULL;
	p->lex.trace_tokens = 0;
	// done
	namespaces->size++;
	return p;
}

void generate_vapi(namespace_t *cur_namespace, lex_t *lex)
{	char filename[IDENT_SIZE*8+8], prefix[IDENT_SIZE*8], headers[IDENT_SIZE*16+32], *args[1];
	FILE *stream;
	/* begin */
	copy_prefix(cur_namespace, lex, 0, prefix, sizeof(prefix));
	sprintf(filename, "_%s.vapi", prefix);
	stream = fopen(filename, "w");
	if (stream == NULL)
	{	perror(filename);
	}
	else
	{	if (lex == &cur_namespace->lex)
		{	sprintf(headers, "_%s2.h", prefix);
		}
		else
		{	sprintf(headers, "_%s.h,_%s2.h", prefix, prefix);
		}
		args[0] = headers;
		subst_print(stream, VAPI, cur_namespace, 1, lex, args, 1);
		fclose(stream);
		// vapi_files
		sprintf(filename, "_%s.vapi", prefix);
		append_if_not_present(cur_namespace->parent->vapi_files, sizeof(cur_namespace->parent->vapi_files), filename, strlen(filename), ' ');
		// vapi_pkgs
		sprintf(filename, "--pkg _%s", prefix);
		append_if_not_present(cur_namespace->parent->vapi_pkgs, sizeof(cur_namespace->parent->vapi_pkgs), filename, strlen(filename), ' ');
	}
}

void copy_stream(FILE *from, FILE *to)
{	char io_buffer[8*1024];
	int read;
	/* begin */
	fseek(from, 0, SEEK_SET);
	while (!feof(from))
	{	read = fread(io_buffer, 1, sizeof(io_buffer), from);
		fwrite(io_buffer, 1, read, to);
	}
}

void add_maketarget(namespace_t *cur_namespace, lex_t *lex, char *extra_argument_class, int with_flex, int with_lemon)
{	maketarget_t *p;
	char prefix[IDENT_SIZE*8];
	/* begin */
	cur_namespace->parent->n_maketargets++;
	cur_namespace->parent->maketargets = realloc(cur_namespace->parent->maketargets, cur_namespace->parent->n_maketargets*sizeof(*cur_namespace->parent->maketargets));
	p = &cur_namespace->parent->maketargets[cur_namespace->parent->n_maketargets-1];
	p->namespace_name = strdup(cur_namespace->name);
	p->extra_argument_class = strdup(extra_argument_class);
	p->with_flex = with_flex;
	p->with_lemon = with_lemon;
	copy_prefix(cur_namespace, lex, 0, prefix, sizeof(prefix));
	p->prefix = strdup(prefix);
}

FILE *fopen_header2(namespace_t *cur_namespace, lex_t *lex)
{	char filename[IDENT_SIZE*8+32], prefix[IDENT_SIZE*8];
	FILE *h_headers;
	/* begin */
	copy_prefix(cur_namespace, lex, 0, prefix, sizeof(prefix));
	sprintf(filename, "_%s2.h", prefix);
	h_headers = fopen(filename, "w");
	if (h_headers == NULL)
	{	perror(filename);
		return NULL;
	}
	subst_print(h_headers, "#ifndef __NN_PP_H__\n#define __NN_PP_H__\n\n", cur_namespace, 0, lex, NULL, 0);
	if (lex->h_out_lex != NULL)
	{	subst_print(h_headers, "#define NN_PP_LEX_ENABLED\n", cur_namespace, 0, lex, NULL, 0);
	}
	if (lex==&cur_namespace->lex_with_lemon && cur_namespace->h_out_lemon!=NULL)
	{	// there are Lemon rules
		subst_print(h_headers, "#define NN_PP_LEMON_ENABLED\n", cur_namespace, 0, lex, NULL, 0);
	}
	if (lex->trace_tokens)
	{	subst_print(h_headers, "#define NN_PP_TRACE_TOKENS\n", cur_namespace, 0, lex, NULL, 0);
	}
	if (lex==&cur_namespace->lex_with_lemon && cur_namespace->trace_symbols)
	{	subst_print(h_headers, "#define NN_PP_TRACE_SYMBOLS\n", cur_namespace, 0, lex, NULL, 0);
	}
	fputc('\n', h_headers);
	subst_print(h_headers, INCLUDE_H, cur_namespace, 0, lex, NULL, 0);
	return h_headers;
}

void fclose_header2(namespace_t *cur_namespace, lex_t *lex, FILE *h_headers)
{	if (h_headers != NULL)
	{	fprintf(h_headers, "\n#endif\n\n");
		subst_print(h_headers, INCLUDE_H_GLOB, cur_namespace, 0, lex, NULL, 0);
		fclose(h_headers);
	}
}

void finalize_lemon(namespace_t *cur_namespace, int with_flex)
{	char filename[IDENT_SIZE*8+32], prefix[IDENT_SIZE*8];
	FILE *fh;
	/* begin */
	if (cur_namespace->h_out_lemon != NULL)
	{	copy_prefix(cur_namespace, &cur_namespace->lex_with_lemon, 0, prefix, sizeof(prefix));
		sprintf(filename, "_%s.lemon", prefix);
		fh = fopen(filename, "w"); // previously filename was not known
		if (fh == NULL)
		{	perror(filename);
		}
		else
		{	// copy_stream
			copy_stream(cur_namespace->h_out_lemon, fh);
			// foot
			subst_print(fh, LEMON_FOOT, cur_namespace, 0, &cur_namespace->lex_with_lemon, NULL, 0);
			// the c file
			fputs("%include\n{", fh);
			subst_print(fh, INCLUDE_C, cur_namespace, 0, &cur_namespace->lex_with_lemon, NULL, 0);
			fputs("}\n", fh);
			// VAPI
			generate_vapi(cur_namespace, &cur_namespace->lex_with_lemon);
			// headers
			if (!with_flex) // otherwise finalize_lex was worked
			{	fclose_header2(cur_namespace, &cur_namespace->lex_with_lemon, fopen_header2(cur_namespace, &cur_namespace->lex_with_lemon));
			}
			// add_maketarget
			add_maketarget(cur_namespace, &cur_namespace->lex_with_lemon, cur_namespace->extra_argument_class, with_flex, 1);
			// o_files
			assert(sizeof(filename) > sizeof(prefix)+4);
			sprintf(filename, "_%s.o", prefix);
			append_if_not_present(cur_namespace->parent->o_files, sizeof(cur_namespace->parent->o_files), filename, strlen(filename), ' ');
			// make_temp_files, make_temp_files_ext
			sprintf(filename, "_%s2.h", prefix);
			append_if_not_present(cur_namespace->parent->make_temp_files, sizeof(cur_namespace->parent->make_temp_files), filename, strlen(filename), ' ');
			sprintf(filename, "_%s%s%s.lemon", cur_namespace->name, cur_namespace->extra_argument_class, cur_namespace->parent->parser_class);
			append_if_not_present(cur_namespace->parent->make_temp_files, sizeof(cur_namespace->parent->make_temp_files), filename, strlen(filename), ' ');
			sprintf(filename, "_%s%s%s.c", cur_namespace->name, cur_namespace->extra_argument_class, cur_namespace->parent->parser_class);
			append_if_not_present(cur_namespace->parent->make_temp_files_ext, sizeof(cur_namespace->parent->make_temp_files_ext), filename, strlen(filename), ' ');
			sprintf(filename, "_%s%s%s.h", cur_namespace->name, cur_namespace->extra_argument_class, cur_namespace->parent->parser_class);
			append_if_not_present(cur_namespace->parent->make_temp_files_ext, sizeof(cur_namespace->parent->make_temp_files_ext), filename, strlen(filename), ' ');
		}
		fclose(cur_namespace->h_out_lemon);
		fclose(fh);
	}
	cur_namespace->h_out_lemon = NULL;
}

void finalize_lex(lex_t *lex, namespace_t *cur_namespace)
{	int i, j, len, lex_closed=0;
	char filename[IDENT_SIZE*8+8], prefix[IDENT_SIZE*8], prefix_upper[IDENT_SIZE*8], *p_tokens, *p;
	FILE *h_headers;
	/* begin */
	if (lex->h_out_lex != NULL)
	{	assert(lex->h_out_lex_body != NULL);
		assert(lex->class_name[0] != '\0');
		fputs("%%\n\n", lex->h_out_lex);
		copy_stream(lex->h_out_lex_body, lex->h_out_lex);
		copy_prefix(cur_namespace, lex, 0, prefix, sizeof(prefix));
		copy_prefix(cur_namespace, lex, 1, prefix_upper, sizeof(prefix_upper));
		h_headers = fopen_header2(cur_namespace, lex);
		if (h_headers != NULL)
		{	// Start conditions
			p_tokens = lex->start_conds;
			j = 1;
			if (*p_tokens != '\0')
			{	while (1)
				{	p = strchr(p_tokens, ',');
					if (p != NULL)
					{	*p = '\0';
					}
					fprintf(h_headers, "#define %s_S_%s %d\n", prefix_upper, p_tokens, j);
					j++;
					if (p == NULL) break;
					*p = ',';
					p_tokens = p + 1;
				}
			}
			// Lemon defines terminal tokens that he knows about them, but there can be tokens used by Lex only.
			// I will define such tokens in the header file, and add them to cur_namespace->term_tokens, so they will be printed to VAPI as well.
			p_tokens = lex->term_tokens_lex;
			j = 10000;
			if (*p_tokens != '\0')
			{	while (1)
				{	p = strchr(p_tokens, ',');
					if (p != NULL)
					{	*p = '\0';
					}
					if (lex==&cur_namespace->lex || append_if_not_present(cur_namespace->term_tokens, sizeof(cur_namespace->term_tokens), p_tokens, strlen(p_tokens), ','))
					{	// successfully appended - that means this token was used by lex only (not by lemon)
						fprintf(h_headers, "#define %s_T_%s %d\n", prefix_upper, p_tokens, j);
						j++;
					}
					if (p == NULL) break;
					*p = ',';
					p_tokens = p + 1;
				}
			}
			{	char *args[1], extra_argument_class[IDENT_SIZE*2];
				args[0] = cur_namespace->parent->parser_class;
				if (lex == &cur_namespace->lex)
				{	strcpy(extra_argument_class, lex->class_name);
					add_maketarget(cur_namespace, lex, extra_argument_class, 1, 0);
				}
				else
				{	strcpy(extra_argument_class, cur_namespace->extra_argument_class);
				}
				assert(sizeof(filename) > sizeof(prefix)+4);
				// o_files
				sprintf(filename, "_%s.o", prefix);
				append_if_not_present(cur_namespace->parent->o_files, sizeof(cur_namespace->parent->o_files), filename, strlen(filename), ' ');
				// make_temp_files, make_temp_files_ext
				sprintf(filename, "_%s%sLexer.lex", cur_namespace->name, extra_argument_class);
				append_if_not_present(cur_namespace->parent->make_temp_files, sizeof(cur_namespace->parent->make_temp_files), filename, strlen(filename), ' ');
				sprintf(filename, "_%s%sLexer.c", cur_namespace->name, extra_argument_class);
				append_if_not_present(cur_namespace->parent->make_temp_files_ext, sizeof(cur_namespace->parent->make_temp_files_ext), filename, strlen(filename), ' ');
				sprintf(filename, "_%s2.h", prefix);
				append_if_not_present(cur_namespace->parent->make_temp_files, sizeof(cur_namespace->parent->make_temp_files), filename, strlen(filename), ' ');
				// header
				if (lex==&cur_namespace->lex || cur_namespace->h_out_lemon==NULL)
				{	// The C file
					fputs("\n%%\n\n", lex->h_out_lex);
					lex_closed = 1;
					subst_print(lex->h_out_lex, INCLUDE_C, cur_namespace, 0, lex, NULL, 0);
					// The VAPI
					generate_vapi(cur_namespace, lex);
				}
				else
				{	// till cur_namespace->lex_with_lemon is alive
					finalize_lemon(cur_namespace, 1); // this will produce C and VAPI
				}
			}
			fclose_header2(cur_namespace, lex, h_headers);
		}
		if (!lex_closed)
		{	fputs("\n%%\n\n", lex->h_out_lex);
		}
		subst_print(lex->h_out_lex, LEX_FOOT, cur_namespace, 0, lex, NULL, 0);
		fclose(lex->h_out_lex);
		fclose(lex->h_out_lex_body);
	}
	lex->h_out_lex = NULL;
	lex->h_out_lex_body = NULL;
	lex->class_name[0] = '\0';
	lex->term_tokens_lex[0] = '\0';
	lex->start_conds[0] = '\0';
	lex->trace_tokens = 0;
}

void namespace_free(namespace_t *cur_namespace)
{	int i, j, len;
	char filename[IDENT_SIZE+32], prefix[IDENT_SIZE*8], io_buffer[8*1024], *p_tokens, *p;
	/* begin */
	finalize_lex(&cur_namespace->lex_with_lemon, cur_namespace);
	finalize_lex(&cur_namespace->lex, cur_namespace);
	finalize_lemon(cur_namespace, 0); // must be last
}

/**	Set cur_namespace->cur_lex to proper pointer, and ensure cur_namespace->cur_lex->h_out_lex and cur_namespace->cur_lex->h_out_lex_body are not NULL.
 **/
int enable_lex(namespace_t *cur_namespace)
{	char filename[IDENT_SIZE*8+32];
	FILE  *fh;
	/* begin */
	assert(cur_namespace->cur_class[0] != '\0');
	assert(cur_namespace->cur_lex == &cur_namespace->lex || cur_namespace->cur_lex == &cur_namespace->lex_with_lemon);
	if (cur_namespace->cur_lex==&cur_namespace->lex && strcmp(cur_namespace->lex.class_name, cur_namespace->cur_class)!=0)
	{	finalize_lex(cur_namespace->cur_lex, cur_namespace); // entered to a new class
	}
	if (strcmp(cur_namespace->cur_class, cur_namespace->extra_argument_class) != 0)
	{	cur_namespace->cur_lex = &cur_namespace->lex;
	}
	else
	{	cur_namespace->cur_lex = &cur_namespace->lex_with_lemon;
	}
	if (cur_namespace->cur_lex->h_out_lex == NULL)
	{	assert(cur_namespace->cur_lex->h_out_lex_body == NULL);
		strcpy(cur_namespace->cur_lex->class_name, cur_namespace->cur_class);
		if (cur_namespace->cur_lex == &cur_namespace->lex_with_lemon)
		{	sprintf(filename, "_%s%sLexer.lex", cur_namespace->name, cur_namespace->extra_argument_class);
		}
		else
		{	sprintf(filename, "_%s%sLexer.lex", cur_namespace->name, cur_namespace->cur_lex->class_name);
		}
		fh = fopen(filename, "w");
		if (fh == NULL)
		{	perror(filename);
			return 0;
		}
		cur_namespace->cur_lex->h_out_lex = fh;
		subst_print(fh, LEX_HEAD, cur_namespace, 0, cur_namespace->cur_lex, NULL, 0);
		cur_namespace->cur_lex->h_out_lex_body = tmpfile();
		if (cur_namespace->cur_lex->h_out_lex_body == NULL)
		{	perror("");
			return 0;
		}
	}
	return 1;
}

/**	Ensure cur_namespace->h_out_lemon is not NULL.
 **/
int enable_lemon(namespace_t *cur_namespace)
{	if (cur_namespace->h_out_lemon == NULL)
	{	cur_namespace->h_out_lemon = tmpfile();
		if (cur_namespace->h_out_lemon == NULL)
		{	perror("");
			return 0;
		}
	}
	return 1;
}

typedef struct
{	FILE *fh;
	char *filename;
	int line, line_char;
}	input_t;

int input_fopen(input_t *input, char *filename)
{	FILE * stream;
	/* begin */
	stream = fopen(filename, "r");
	if (stream == NULL)
	{	perror(filename);
		return 0;
	}
	input->fh = stream;
	input->filename = strdup(filename);
	input->line = 1;
	input->line_char = 1;
	return 1;
}

void input_fclose(input_t *input)
{	fclose(input->fh);
	free(input->filename);
}

int input_getc(input_t *input)
{	int c;
	/* begin */
	c = fgetc(input->fh);
	if (c == '\n')
	{	input->line++;
		input->line_char = 1;
	}
	else
	{	input->line_char++;
	}
	return c;
}

/**	@return true if skipped the whole string. In this case *last_char will be the last char of str (right before it's '\0').
 **/
int scan_skip_str(input_t *input, int ignore_leading_space, char *str, int *last_char)
{	int c;
	/* begin */
	assert(*str != '\0');
	if (ignore_leading_space)
	{	while (isspace(c = input_getc(input))); // skip space
	}
	else
	{	c = input_getc(input);
	}
	if (c != EOF)
	{	while (((char)c) == *str)
		{	if (*(++str) == '\0') break;
			c = input_getc(input);
			if (c == EOF) break;
		}
	}
	*last_char = c;
	return *str=='\0';
}

/**	Param last_char is input/output. If EOF, adds no first char to pbuffer.
 *	@return true if read an identifier and the last char read was not an EOF.
 **/
int scan_ident(input_t *input, int ignore_leading_space, char *pbuffer, int sizeof_buffer, int *last_char)
{	int c;
	char *pbuffer_pos;
	/* begin */
	assert(sizeof_buffer > 1);
	assert(!isspace(EOF));
	pbuffer_pos = pbuffer + 1;
	if (ignore_leading_space)
	{	if (*last_char==EOF || isspace(*last_char))
		{	while (isspace(*last_char = input_getc(input))); // skip space
			if (*last_char == EOF) return 0;
		}
	}
	if (*last_char == EOF)
	{	*last_char = input_getc(input);
	}
	c = *last_char;
	if (c==EOF || !(isalpha(c) || c=='_')) return 0;
	*pbuffer = (char)c;
	sizeof_buffer--;
	while ((c = input_getc(input)) != EOF)
	{	if (!isalnum(c) && c!='_') break;
		if (--sizeof_buffer <= 0)
		{	*last_char = c;
			return 0;
		}
		*(pbuffer_pos++) = (char)c;
	}
	*pbuffer_pos = '\0';
	while (isspace(c)) c = input_getc(input);
	*last_char = c;
	return c != EOF;
}

int read_string(input_t *input, char *pbuffer, int sizeof_buffer, int *last_char)
{	int c;
	char *pbuffer_pos;
	/* begin */
	assert(sizeof_buffer > 0);
	pbuffer_pos = pbuffer;
	while (isspace(c = input_getc(input)));
	if (c != EOF)
	{	if (isdigit(c))
		{	*(pbuffer_pos++) = (char)c;
			while ((c = input_getc(input)) != EOF)
			{	if (!isdigit(c)) break;
				*(pbuffer_pos++) = (char)c;
			}
		}
		else if (isalpha(c) || c=='_')
		{	*(pbuffer_pos++) = (char)c;
			while ((c = input_getc(input)) != EOF)
			{	if (!isalnum(c) && c!='_') break;
				*(pbuffer_pos++) = (char)c;
			}
		}
		else if (c == '"')
		{	while ((c = input_getc(input)) != EOF)
			{	if (c == '\\')
				{	if ((c = input_getc(input)) == EOF) break;
				}
				else if (c == '"')
				{	break;
				}
				if (--sizeof_buffer <= 0)
				{	*last_char = c;
					return 0;
				}
				*(pbuffer_pos++) = (char)c;
			}
			c = input_getc(input);
		}
		while (isspace(c)) c = input_getc(input);
		*last_char = c;
		*pbuffer_pos = '\0';
		return 1;
	}
	return 0;
}

void report_error(input_t *input, char *message, ...)
{	va_list args;
	/* begin */
	va_start(args, message);
	fprintf(stderr, "***ERROR in file %s (line %d:%d). ", input->filename, input->line, input->line_char);
	vfprintf(stderr, message, args);
	fputs("\n\n", stderr);
	va_end(args);
}

/**	Assumes that will read from input something like this:
 *	@code
 *	public Expression.from_number(...
 *	@endcode
 *	or:
 *	@code
 *	public static Expression from_number(...
 *	@endcode
 *	Sets pbuffer to "from_number" or to "" (if Expression()) and returns true on success.
 **/
int read_method_name(int is_lex, input_t *input, char *cur_class, char *pbuffer, int sizeof_buffer, int *last_char, int *is_static)
{	int is_public=0, cur_class_found=0;
	/* begin */
	pbuffer[0] = '\0';
	*last_char = EOF;
	*is_static = 0;
	while (1)
	{	if (strcmp(pbuffer, "public") == 0)
		{	is_public = 1;
		}
		else if (strcmp(pbuffer, "static") == 0)
		{	*is_static = 1;
			if (is_lex)
			{	report_error(input, "Method must not be static");
				goto E;
			}
		}
		else if (strcmp(pbuffer, cur_class) == 0)
		{	cur_class_found = 1;
		}
		if (scan_ident(input, 1, pbuffer, sizeof_buffer, last_char))
		{	if (*last_char == '(')
			{	if (!is_public)
				{	report_error(input, "Constructor/method \"%s\" must be public", pbuffer);
					goto E;
				}
				if (strcmp(pbuffer, cur_class) == 0)
				{	*pbuffer = '\0';
				}
				else if (!is_lex && !cur_class_found)
				{	if (*is_static)
					{	report_error(input, "Expected something like: public static %s %s(...)", cur_class, pbuffer);
					}
					else
					{	report_error(input, "Expected something like: public %s.%s(...)", cur_class, pbuffer);
					}
					goto E;
				}
				return 1;
			}
		}
		else if (*last_char!='.' && *last_char!='[' && *last_char!=']' && *last_char!='*' && *last_char!='?') // not a return type declaration
		{	break;
		}
		else
		{	*last_char = EOF;
		}
	}
	report_error(input, "Expected constructor or method declaration");
E:	*pbuffer = '\0';
	return 0;
}

char *escape_letters(char *str)
{	char *result, *presult;
	/* begin */
	presult = result = malloc(strlen(str)*4+1);
	while (*str != '\0')
	{	if (!isalpha(*str))
		{	*(presult++) = *str;
		}
		else
		{	sprintf(presult, "\\x%02X", (int)*str);
			presult += 4;
		}
		str++;
	}
	*presult = '\0';
	return result;
}

/**	Prints arguments to function that used in code block, and then destructors.
 *	Prints something like ", a, b); g_object_unref(a); g_object_unref(b);}\n".
 *	@param cur_namespace - Will print to cur_namespace->h_out_lemon.
 *	@param lemon_expr - Expression like "Expression(a) PLUS Expression(b)"
 **/
void write_code_block(namespace_t *cur_namespace, char *lemon_expr)
{	int print_on=0, is_printed=0;
	char *p, *args[2];
	/* begin */
	for (p=lemon_expr; *p!='\0'; p++)
	{	if (*p == '(')
		{	print_on = 1;
			fputs(", ", cur_namespace->h_out_lemon);
		}
		else if (*p == ')')
		{	print_on = 0;
		}
		else if (print_on)
		{	fputc(*p, cur_namespace->h_out_lemon);
		}
	}
	for (p=lemon_expr; *p!='\0'; p++)
	{	if (*p == '(')
		{	print_on = 1;
			if (!is_printed)
			{	args[0] = escape_letters(lemon_expr); // escape, so lemon will not substitute internal variables in trace message
				args[1] = cur_namespace->cur_class;
				subst_print
				(	cur_namespace->h_out_lemon,
					");\n"
					"	#ifdef NN_PP_TRACE_SYMBOLS\n"
					"		fprintf(stderr, \"*TRACE: @0 {new Nn@1 is %p}\\n\", l_this);\n"
					"	#endif\n"
					"	g_object_unref(",
					cur_namespace, 0, &cur_namespace->lex_with_lemon, args, 2
				);
				free(args[0]);
				is_printed = 1;
			}
			else
			{	fputs(");\n\tg_object_unref(", cur_namespace->h_out_lemon);
			}
		}
		else if (*p == ')')
		{	print_on = 0;
		}
		else if (print_on)
		{	fputc(*p, cur_namespace->h_out_lemon);
		}
	}
	fputs(");\n}\n", cur_namespace->h_out_lemon);
}

int add_lex(namespace_t *cur_namespace, char *name, char *states, char *pattern)
{	char name_upper[IDENT_SIZE*3], token_name[IDENT_SIZE*3], current_class_lower[IDENT_SIZE*N_NESTED_CLASSES*2], prefix[IDENT_SIZE*8], *args[4];
	int len, i, inside, level;
	FILE *stream;
	/* begin */
	assert(name!=NULL && pattern!=NULL);
	if (!enable_lex(cur_namespace))
	{	return 0;
	}
	copy_prefix(cur_namespace, cur_namespace->cur_lex, 1, prefix, sizeof(prefix));
	// 1. Append to list of known tokens that used by lex
	strcpy(name_upper, name);
	str_toupper(name_upper);
	append_if_not_present(cur_namespace->cur_lex->term_tokens_lex, sizeof(cur_namespace->cur_lex->term_tokens_lex), name_upper, strlen(name_upper), ',');
	// 2. Print pattern to cur_namespace->cur_lex->h_out_lex_body
	while (isspace(*pattern))
	{	pattern++;
	}
	len = strlen(pattern);
	while (len>0 && isspace(pattern[len-1]))
	{	len--;
	}
	if (len == 0)
	{	return 1;
	}
	assert(strlen(cur_namespace->name_lower) + strlen(name) < sizeof(token_name));
	sprintf(token_name, "%s_T_%s", prefix, name);
	str_toupper(token_name);
	strcpy(current_class_lower, cur_namespace->cur_class);
	from_camel_case(current_class_lower, sizeof(current_class_lower), NULL, NULL, 0);
	stream = cur_namespace->cur_lex->h_out_lex_body;
	if (states[0] != '\0')
	{	fprintf(stream, "<%s>", states); // commaseparated list of prefix_S_statename
	}
	// for each char in pattern...
	if (*pattern == '^')
	{	fputc('^', stream);
		pattern++;
		len--;
	}
	inside = 0;
	while (len > 0)
	{	if (*pattern=='\\' && pattern[1]!='\0')
		{	if (!inside)
			{	fputs("(?x:", stream);
				inside = 1;
			}
			fputc(*pattern, stream);
			pattern++;
			len--;
		}
		else if (*pattern=='/' || *pattern=='|' || (*pattern=='$' && len==1))
		{	if (inside)
			{	fputc(')', stream);
				inside = 0;
			}
		}
		else
		{	if (!inside)
			{	fputs("(?x:", stream);
				inside = 1;
			}
			if (*pattern == '(')
			{	level = 0;
				while (len > 0)
				{	if (*pattern == '(')
					{	level++;
					}
					else if (*pattern == ')')
					{	if (--level == 0) break;
					}
					fputc(*pattern, stream);
					pattern++;
					len--;
				}
				if (len <= 0) return 0;
			}
		}
		fputc(*pattern, stream);
		pattern++;
		len--;
	}
	if (inside)
	{	fputc(')', stream);
	}
	args[0] = token_name;
	args[1] = current_class_lower;
	args[2] = name;
	args[3] = cur_namespace->cur_class;
	subst_print
	(	stream,
		" {\n\tyyextra->token_code = @0; nn_@1_@2((Nn@3*)(yyextra), yytext, yyleng); nn_pp_trace_token(yyextra, yyleng, @0, yyextra->token_code); yyextra->n_chars_read += yyleng; return yyextra->token_code;\n\t}\n",
		cur_namespace, 0, cur_namespace->cur_lex, args, 4
	);
	return 1;
}

/**	Param last_char is input/output, like in scan_ident().
 **/
int read_lemon_pattern(input_t *input, namespace_t *cur_namespace, 
		       char *cur_class, int *last_char)
{	
  char attr_buffer[64];
  char value_buffer[1024]; 
  char pattern_buffer[20*1024]; 
  char prec_buffer[IDENT_SIZE*8]; 
  char *p, *p2, c, attr_name, last_letter; 
  char prefix[IDENT_SIZE*8]; 
  char states[sizeof(value_buffer)*8]; 
  char class_lower[IDENT_SIZE*N_NESTED_CLASSES]; 
  char state_ident[IDENT_SIZE*8];
  int result=0, with_braces, add_prefix, is_lex, is_pattern_read=0, is_static;
	/* begin */
	pattern_buffer[0] = '\0';
	prec_buffer[0] = '\0';
	states[0] = '\0';
	if (!scan_ident(input, 1, attr_buffer, sizeof(attr_buffer), last_char))
	{	return 0;
	}
	if (*last_char!='(' || strcmp(attr_buffer, "Flex")!=0 && strcmp(attr_buffer, "Lemon")!=0)
	{	return 0;
	}
	is_lex = attr_buffer[0] == 'F';
	while (1)
	{	*last_char = EOF;
		if (!scan_ident(input, 1, attr_buffer+1, sizeof(attr_buffer)-2, last_char))
		{	if (*last_char == ')') break;
			return 0;
		}
		if (*last_char != '=')
		{	return 0;
		}
		if (strcmp(attr_buffer+1, "pattern") == 0)
		{	if (!read_string(input, pattern_buffer, sizeof(pattern_buffer), last_char))
			{	report_error(input, "Value of \"pattern\" attribute must be string");
				return 0;
			}
			if (cur_namespace->cur_class[0] == '\0')
			{	report_error(input, "\"Pattern\" must be at method declaration");
				return 0;
			}
			if (!is_lex)
			{	from_camel_case(pattern_buffer, sizeof(pattern_buffer), NULL, cur_namespace->term_tokens, sizeof(cur_namespace->term_tokens));
			}
			is_pattern_read = 1;
		}
		else if (strcmp(attr_buffer+1, "prec") == 0) 
		{	if (!read_string(input, prec_buffer+1, sizeof(prec_buffer-1), last_char))
			{	report_error(input, "Value of \"prec\" attribute must be string");
				return 0;
			}
			prec_buffer[0] = '[';
			strcat(prec_buffer, "]");
		}
		else if (is_lex)
		{	if (!read_string(input, value_buffer, sizeof(value_buffer), last_char))
			{	report_error(input, "Value of attribute must be string/boolean");
				return 0;
			}
			if (strcmp(attr_buffer+1, "define") == 0)
			{	if (!enable_lex(cur_namespace))
				{	return FATAL_ERROR;
				}
				fprintf(cur_namespace->cur_lex->h_out_lex, "%s\n", value_buffer);
			}
			else if (strcmp(attr_buffer+1, "trace") == 0)
			{	if (!enable_lex(cur_namespace))
				{	return FATAL_ERROR;
				}
				cur_namespace->cur_lex->trace_tokens = 1;
			}
			else if (strcmp(attr_buffer+1, "state")==0 || strcmp(attr_buffer+1, "token")==0 || strcmp(attr_buffer+1, "s")==0 || strcmp(attr_buffer+1, "x")==0)
			{	attr_name = attr_buffer[2]=='t' ? 'S' : attr_buffer[1]; /* 'S'=state, 't'=token, 's'=s, 'x'=x */
				str_toupper(value_buffer);
				p = value_buffer;
				assert(!isspace('\0'));
				if (!enable_lex(cur_namespace))
				{	return FATAL_ERROR;
				}
				copy_prefix(cur_namespace, cur_namespace->cur_lex, 1, prefix, sizeof(prefix));
				assert(p != NULL);
				if (attr_name == 'S')
				{	while (isspace(*p)) p++;
					if (*p == '*')
					{	p++;
						while (isspace(*p)) p++;
						if (*p == '\0')
						{	/* asterisk */
							strcpy(states, "*");
							p = NULL;
						}
					}
				}
				if (p != NULL)
				{	while (1)
					{	while (isspace(*p) || *p==',') p++;
						if (*p == '\0') break;
						p2 = p;
						while (isalnum(*p) || *p=='_') p++;
						if (p == p2)
						{	report_error(input, "Flex.token must be space/commaseparated list of identifiers. Found: %s", value_buffer);
							break;
						}
						c = *p;
						*p = '\0';
						if (attr_name == 't') // token
						{	if (!add_lex(cur_namespace, p2, "", ""))
							{	return FATAL_ERROR;
							}
						}
						else if (attr_name == 'S') // state
						{	if (strcmp(p2, "INITIAL") == 0)
							{	append_if_not_present(states, sizeof(states), p2, 7, ',');
							}
							else
							{	sprintf(state_ident, "%s_S_%.*s", prefix, (int)(p-p2), p2);
								append_if_not_present(states, sizeof(states), state_ident, strlen(state_ident), ',');
							}
						}
						else // s, x
						{	fprintf(cur_namespace->cur_lex->h_out_lex, "%%%c %s_S_%s\n", attr_name, prefix, p2);
							append_if_not_present(cur_namespace->cur_lex->start_conds, sizeof(cur_namespace->cur_lex->start_conds), p2, p-p2, ',');
						}
						*p = c;
					}
				}
			}
			else
			{	if (!enable_lex(cur_namespace))
				{	return FATAL_ERROR;
				}
				if (value_buffer[0] == '\0')
				{	fprintf(cur_namespace->cur_lex->h_out_lex, "%%option %s\n", attr_buffer+1);
				}
				else
				{	fprintf(cur_namespace->cur_lex->h_out_lex, "%%option %s=\"%s\"\n", attr_buffer+1, value_buffer); // TODO: addslashes(value_buffer)
				}
			}
		}
		else
		{	if (!read_string(input, value_buffer, sizeof(value_buffer), last_char))
			{	report_error(input, "Value of attribute must be string/boolean");
				return 0;
			}
			if (strcmp(attr_buffer+1, "start_symbol")==0 || strcmp(attr_buffer+1, "token_type")==0 || strcmp(attr_buffer+1, "extra_argument")==0)
			{	if (attr_buffer[1] == 's') result = START_SYMBOL;
				else if (attr_buffer[1] == 't') result = TOKEN_TYPE;
				else result = EXTRA_ARGUMENT;
			}
			else if (strcmp(attr_buffer+1, "trace") == 0)
			{	cur_namespace->trace_symbols = 1;
			}
			else
			{	if (!enable_lemon(cur_namespace))
				{	return FATAL_ERROR;
				}
				fprintf(cur_namespace->h_out_lemon, "%%%s ", attr_buffer+1);
				add_prefix = strcmp(attr_buffer+1, "left")==0 || strcmp(attr_buffer+1, "right")==0 || strcmp(attr_buffer+1, "nonassoc")==0;
				attr_buffer[0] = ',';
				strcat(attr_buffer, ",");
				with_braces = strstr(WITH_BRACES, attr_buffer) != NULL;
				if (add_prefix)
				{	from_camel_case(value_buffer, sizeof(value_buffer), NULL, cur_namespace->term_tokens, sizeof(cur_namespace->term_tokens));
				}
				if (with_braces)
				{	fprintf(cur_namespace->h_out_lemon, "{%s}\n", value_buffer);
				}
				else
				{	fprintf(cur_namespace->h_out_lemon, "%s.\n", value_buffer);
				}
			}
		}
		if (*last_char == ')') break;
		if (*last_char != ',')
		{	report_error(input, "Comma expected");
			return 0;
		}
	}
	if (*last_char!=')' || !scan_skip_str(input, 1, "]", last_char))
	{	report_error(input, "Invalid attribute syntax");
		return 0;
	}
	if (is_pattern_read && is_lex || cur_class[0]!='\0' && strcmp(cur_class, cur_namespace->extra_argument_class)==0)
	{	last_letter = cur_class[strlen(cur_class) - 1];
		if (last_letter>='A' && last_letter<='Z')
		{	// This confuses valac. E.g. valac converts FooB to FOO_B, and FooBParser to FOO_BPARSER
			report_error(input, "Parser class name must not end with capital letter: %s", cur_class);
		}
	}
	// pattern
	if (is_pattern_read && read_method_name(is_lex, input, cur_class, attr_buffer, sizeof(attr_buffer), last_char, &is_static))
	{	if (is_lex)
		{	if (attr_buffer[0] != '\0')
			{	if (!add_lex(cur_namespace, attr_buffer, states, pattern_buffer))
				{	return FATAL_ERROR;
				}
			}
		}
		else
		{	strcpy(class_lower, cur_namespace->cur_class);
			from_camel_case(class_lower, sizeof(class_lower), NULL, NULL, 0);
			if (!enable_lemon(cur_namespace))
			{	return FATAL_ERROR;
			}
			if (append_if_not_present(cur_namespace->tokens, sizeof(cur_namespace->tokens), class_lower, strlen(class_lower), ','))
			{	fprintf(cur_namespace->h_out_lemon, "%%type %s {%s%s*}\n", class_lower, cur_namespace->name, cur_namespace->cur_class);
			}
			if (!is_static)
			  {	fprintf(cur_namespace->h_out_lemon, "%s(l_this) ::= %s. %s\n{\tl_this = %s_%s_new%c%s(l_ea", class_lower, pattern_buffer, prec_buffer, cur_namespace->name_lower, class_lower, attr_buffer[0]=='\0' ? ' ' : '_', attr_buffer);
			}
			else if (attr_buffer[0] != '_')
			  {	fprintf(cur_namespace->h_out_lemon, "%s(l_this) ::= %s. %s\n{\tl_this = %s_%s_%s(l_ea", class_lower, pattern_buffer, prec_buffer, cur_namespace->name_lower, class_lower, attr_buffer);
			}
			else /* valac's behavior: prepend the whole method name with '_' if Vala internal name starts with it */
			  {	fprintf(cur_namespace->h_out_lemon, "%s(l_this) ::= %s. %s\n{\tl_this = _%s_%s%s(l_ea", class_lower, pattern_buffer, prec_buffer, cur_namespace->name_lower, class_lower, attr_buffer);
			}
			// arguments
			write_code_block(cur_namespace, pattern_buffer);
		}
	}
	return result;
}

void copy_classname(char *copy_to, char class_nesting[N_NESTED_CLASSES][IDENT_SIZE], int class_nesting_level, int with_dot)
{	int i, len=0, len2;
	/* begin */
	assert(class_nesting_level >= 0);
	for (i=0; i<=class_nesting_level; i++)
	{	len2 = strlen(class_nesting[i]);
		memcpy(copy_to + len, class_nesting[i], len2);
		len += len2;
		if (with_dot)
		{	copy_to[len++] = '.';
		}
	}
	if (with_dot) len--;
	copy_to[len] = '\0';
}

int extract(input_t *input, namespace_arr_t *namespaces)
{	int i, c, qt, result, at_new_stmt=1, isset=0, class_nesting_level=-1; // -1 means outside class declarations
  char class_nesting[N_NESTED_CLASSES][IDENT_SIZE];
  char current_symbol[IDENT_SIZE*N_NESTED_CLASSES];
	int class_nesting_at[N_NESTED_CLASSES], braces_level=0;
	namespace_t *cur_namespace=NULL;
	/* begin */
	assert(!isspace('\0'));
	assert(!isspace(EOF));
	while (1)
	{	c = input_getc(input);
N:		if (c == EOF)
		{	break;
		}
		else if (c == '/')
		{	c = input_getc(input);
			if (c == '/')
			{	// line comment
				while ((c = input_getc(input)) != EOF)
				{	if (c=='\r' || c=='\n') break;
				}
			}
			else if (c == '*')
			{	// normal comment
				while ((c = input_getc(input)) != EOF)
				{	if (c == '*')
					{	c = input_getc(input);
						if (c==EOF || c=='/') break;
					}
				}
			}
			if (c == EOF) break;
			continue; // preserve at_new_stmt
		}
		else if (c=='"' || c=='\'')
		{	// string or char const
			qt = c;
			i = 1; // read 1 quote
			while ((c = input_getc(input)) != EOF)
			{	i++;
				if (c == '\\')
				{	if ((c = input_getc(input)) == EOF) break;
					i = 100;
				}
				else if (c == qt)
				{	if (qt=='"' && i==2) // read 2 double quotes - can be verbatim string
					{	if ((c = input_getc(input)) == EOF) break;
						if (c != '"') break;
						// skip verbatim string
						i = 0;
						while ((c = input_getc(input)) != EOF)
						{	if (c != '"')
							{	i = 0;
							}
							else
							{	if (++i == 3) break;
							}
						}
					}
					break;
				}
			}
			if (c == EOF) break;
		}
		else if (c==';' || c=='{' || c=='}')
		{	// end of statement
			at_new_stmt = 1;
			if (c == '{')
			{	braces_level++;
			}
			else if (c == '}')
			{	braces_level--;
				if (class_nesting_level>=0 && braces_level==class_nesting_at[class_nesting_level])
				{	class_nesting_level--;
					if (class_nesting_level == -1)
					{	cur_namespace->cur_class[0] = '\0';
					}
					else
					{	copy_classname(cur_namespace->cur_class, class_nesting, class_nesting_level, 0);
					}
				}
			}
			continue;
		}
		else if (isspace(c))
		{	continue;
		}
		else if (at_new_stmt)
		{	if (c == 'n')
			{	if (scan_skip_str(input, 0, "amespace", &c))
				{	c = EOF;
					if (scan_ident(input, 1, current_symbol, sizeof(current_symbol), &c))
					{	cur_namespace = select_namespace(namespaces, current_symbol);
						at_new_stmt = 1;
						isset = 0;
					}
					goto N; // c contains next char
				}
			}
			else if (c == 'p')
			{	if (scan_ident(input, 1, current_symbol, sizeof(current_symbol), &c))
				{	if (c=='c' && (strcmp(current_symbol, "public")==0 || strcmp(current_symbol, "private")==0))
					{	goto C;
					}
				}
				goto N;
			}
			else if (c == 'c')
			{	/* catch class declaration */
C:				if (cur_namespace != NULL && class_nesting_level < N_NESTED_CLASSES-1)
				{	if (scan_skip_str(input, 0, "lass", &c))
					{	c = EOF;
						if (scan_ident(input, 1, class_nesting[class_nesting_level+1], sizeof(class_nesting[class_nesting_level+1]), &c))
						{	class_nesting_at[class_nesting_level+1] = braces_level;
							class_nesting_level++;
							copy_classname(cur_namespace->cur_class, class_nesting, class_nesting_level, 0);
							if (isset == START_SYMBOL)
							{	strcpy(cur_namespace->start_symbol_class, cur_namespace->cur_class);
							}
							else if (isset == TOKEN_TYPE)
							{	strcpy(cur_namespace->token_type_class, cur_namespace->cur_class);
								copy_classname(cur_namespace->token_type_class_dot, class_nesting, class_nesting_level, 1);
							}
							else if (isset == EXTRA_ARGUMENT)
							{	strcpy(cur_namespace->extra_argument_class, cur_namespace->cur_class);
								copy_classname(cur_namespace->extra_argument_class_dot, class_nesting, class_nesting_level, 1);
							}
						}
					}
					at_new_stmt = 0;
					isset = 0;
					goto N;
				}
			}
			else if (c=='[' && cur_namespace!=NULL) // Alleluyah!
			{	c = EOF;
				result = read_lemon_pattern(input, cur_namespace, class_nesting_level==-1 ? "" : class_nesting[class_nesting_level], &c);
				at_new_stmt = 1;
				isset = 0;
				if (result == FATAL_ERROR)
				{	return EXIT_FAILURE;
				}
				else if (result==START_SYMBOL || result==TOKEN_TYPE || result==EXTRA_ARGUMENT)
				{	isset = result;
				}
				if (c == EOF) break;
				continue;
			}
		}
		at_new_stmt = 0;
		isset = 0;
	}
	return EXIT_SUCCESS;
}

int main(int argc, char **argv)
{	int i, retcode=0, len;
	glob_t files;
	FILE *stream;
	input_t input;
	namespace_t *cur_namespace;
	namespace_arr_t namespaces = {{}, 0, "Parser", NULL, 0, "", "", "", "", "", "", ""};
	char filename[IDENT_SIZE+32], prefix[IDENT_SIZE*8];
	maketarget_t *maketarget;
	FILE *h_makefile;
	/* begin */
	// 1. usage?
	if (argc>=2 && (strcmp(argv[1], "--help")==0 || strcmp(argv[1], "-h")==0 || strcmp(argv[1], "/?")==0))
	{	fputs(USAGE_INFO, stderr);
		exit(EXIT_SUCCESS);
	}
	// 2. glob + extract
	glob("*.vala", 0, NULL, &files);
	for (i=0; i<files.gl_pathc; i++)
	{	if (input_fopen(&input, files.gl_pathv[i]))
		{	retcode |= extract(&input, &namespaces);
			input_fclose(&input);
		}
		len = strlen(files.gl_pathv[i]);
		append_if_not_present(namespaces.vala_files, sizeof(namespaces.vala_files), files.gl_pathv[i], len, ' ');
		assert(strcmp(files.gl_pathv[i] + len - 5, ".vala") == 0);
		files.gl_pathv[i][len-4] = 'c';
		files.gl_pathv[i][len-3] = '\0';
		append_if_not_present(namespaces.c_files, sizeof(namespaces.c_files), files.gl_pathv[i], len, ' ');
	}
	// 3. add %include + generate the second header file and the VAPI
	for (i=0; i<namespaces.size; i++)
	{	namespace_free(&namespaces.arr[i]);
	}
	// 4. makefile
	sprintf(filename, "_Makefile%s", namespaces.parser_class);
	h_makefile = fopen(filename, "w");
	if (h_makefile == NULL)
	{	perror(filename);
	}
	else
	{	fputs(MAKEFILE_HEAD, h_makefile);
		fprintf(h_makefile, "%s : %s\n\t%s\n\n", namespaces.make_temp_files, namespaces.vala_files, argv[0]);
		fprintf(h_makefile, "%s _%s.h : %s %s\n\tvalac ${CFLAGS_VALA} --vapidir=. -C -H _%s.h %s %s\n\n", namespaces.c_files, namespaces.parser_class, namespaces.vala_files, namespaces.vapi_files, namespaces.parser_class, namespaces.vapi_pkgs, namespaces.vala_files);
		fprintf(h_makefile, "${OUTPUT} : %s %s\n\t${CC} ${CFLAGS} -I. -o ${OUTPUT} %s %s ${LIBS}\n\n", namespaces.c_files, namespaces.o_files, namespaces.c_files, namespaces.o_files);
		for (i=0; i<namespaces.n_maketargets; i++)
		{	maketarget = &namespaces.maketargets[i];
			if (maketarget->with_flex)
			{	fprintf(h_makefile, "_%s%sLexer.c : _%s%sLexer.lex\n", maketarget->namespace_name, maketarget->extra_argument_class, maketarget->namespace_name, maketarget->extra_argument_class);
				fprintf(h_makefile, "	${LEX} -o _%s%sLexer.c _%s%sLexer.lex\n", maketarget->namespace_name, maketarget->extra_argument_class, maketarget->namespace_name, maketarget->extra_argument_class);
				fprintf(h_makefile, "\n");
			}
			if (maketarget->with_lemon)
			{	fprintf(h_makefile, "_%s.c _%s.h : _%s.lemon\n", maketarget->prefix, maketarget->prefix, maketarget->prefix);
				fprintf(h_makefile, "	${LEMON} -q _%s.lemon\n", maketarget->prefix);
				fprintf(h_makefile, "\n");
			}
			fprintf(h_makefile, "_%s.o : _%s.h %s\n", maketarget->prefix, namespaces.parser_class, namespaces.make_temp_files_ext);
			if (maketarget->with_flex && maketarget->with_lemon)
			{	fprintf(h_makefile, "	cat _%s.h _%s%sLexer.c _%s.c > _%s.tmp.c\n", namespaces.parser_class, maketarget->namespace_name, maketarget->extra_argument_class, maketarget->prefix, namespaces.parser_class);
			}
			else if (maketarget->with_flex)
			{	fprintf(h_makefile, "	cat _%s.h _%s%sLexer.c > _%s.tmp.c\n", namespaces.parser_class, maketarget->namespace_name, maketarget->extra_argument_class, namespaces.parser_class);
			}
			else if (maketarget->with_lemon)
			{	fprintf(h_makefile, "	cat _%s.h _%s.c > _%s.tmp.c\n", namespaces.parser_class, maketarget->prefix, namespaces.parser_class);
			}
			fprintf(h_makefile, "	${CC} ${CFLAGS}  -I. -c _%s.tmp.c -o _%s.o\n", namespaces.parser_class, maketarget->prefix);
			fprintf(h_makefile, "\n");
			free(maketarget->namespace_name);
			free(maketarget->prefix);
			free(maketarget->extra_argument_class);
		}
		free(namespaces.maketargets);
		fprintf(h_makefile, "clean :\n\trm -f %s %s %s %s %s _%s.h _%s.tmp.c ${OUTPUT}\n\n", namespaces.make_temp_files, namespaces.make_temp_files_ext, namespaces.c_files, namespaces.vapi_files, namespaces.o_files, namespaces.parser_class, namespaces.parser_class);
		fprintf(h_makefile, "all : ${OUTPUT}\n");
		fclose(h_makefile);
	}
	return retcode;
}
