CC ?= cc
CFLAGS ?= -g `pkg-config --cflags glib-2.0 gobject-2.0 gio-2.0 gee-0.8 gtk+-3.0`
LIBS ?= `pkg-config --libs glib-2.0 gobject-2.0 gtk+-3.0 gio-2.0 gee-0.8`
LEX ?= lex
LEMON ?= lemon
CFLAGS_VALA ?= -X "-I."
#SOBJECT ?= libeval_parser.a
SOBJECT ?= libeval_parser.so

all : ${SOBJECT} eval_parser.vapi

_EvalParserParser2.h _EvalParserParser.vapi _EvalParserLexer.lex _EvalParserParser.lemon: eval_parser.vala
	#vala-lemon-extractor
	~/vala-lemon-extractor/vle

_EvalParserLexer.c : _EvalParserLexer.lex
	${LEX} -o _EvalParserLexer.c _EvalParserLexer.lex

_EvalParserParser.c _EvalParserParser.h : _EvalParserParser.lemon
	${LEMON} -c _EvalParserParser.lemon

eval_parser.vapi eval_parser.c _EvalParser.h : eval_parser.vala _EvalParserParser.vapi \
../extern.vapi ../inspect.vapi ../misc.vapi ../expression.vapi ../breakpoint.vapi
	valac ${CFLAGS_VALA} \
	--vapidir=. --vapi=eval_parser.vapi \
	--disable-warnings -g -C -H _EvalParser.h -X -I.. \
	--pkg=gtk+-3.0 --pkg=gee-0.8 _EvalParserParser.vapi \
	../extern.vapi ../inspect.vapi ../misc.vapi ../expression.vapi ../breakpoint.vapi \
	eval_parser.vala 

_EvalParserParser.o : _EvalParser.h _EvalParserLexer.c _EvalParserParser.c _EvalParserParser.h
	cat _EvalParser.h _EvalParserLexer.c _EvalParserParser.c > _Parser.tmp.c
	${CC} ${CFLAGS} -I. -I.. -c -g -fPIC _Parser.tmp.c -o _EvalParserParser.o

eval_parser.o: eval_parser.c _EvalParserParser.c
	${CC} ${CFLAGS} -I. -I.. -c -g -fPIC -c eval_parser.c

${SOBJECT} : eval_parser.o _EvalParserParser.o
	#${AR} q ${SOBJECT} eval_parser.o _EvalParserParser.o 
	${CC} -o ${SOBJECT} -shared eval_parser.o _EvalParserParser.o 

clean :
	rm -f *.lex *.lemon *.[hco] *.out* _Makefile*

clobber:
	rm -f ${SOBJECT} *.vapi *.lex *.lemon *.[hco] *.out* _Makefile*
