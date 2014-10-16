CC ?= cc
CFLAGS ?= $(CG) -w `pkg-config --cflags glib-2.0 gobject-2.0 gio-2.0 gee-0.8 gtk+-3.0`
LIBS ?= `pkg-config --libs glib-2.0 gobject-2.0 gtk+-3.0 gio-2.0 gee-0.8`
LEX ?= lex
LEMON ?= lemon
CFLAGS_VALA ?= $(VG) -X -I.
SOBJECT = home_parser.o _GedbParserParser.o

all : ${SOBJECT} home_parser.vapi

_GedbParserParser2.h _GedbParserParser.vapi _GedbParserLexer.lex _GedbParserParser.lemon: home_parser.vala
	../vle/vala-lemon-extractor

_GedbParserLexer.c : _GedbParserLexer.lex
	${LEX} -o _GedbParserLexer.c _GedbParserLexer.lex

_GedbParserParser.c _GedbParserParser.h : _GedbParserParser.lemon
	! ${LEMON} -c _GedbParserParser.lemon 2>&1 | grep -v conflict | grep '.'

home_parser.vapi home_parser.c _HomeParser.h : home_parser.vala _GedbParserParser.vapi \
../inspect.vapi
	valac ${CFLAGS_VALA} \
	--vapidir=. --vapi=home_parser.vapi \
	--disable-warnings -C -H _HomeParser.h -X -I.. \
	--pkg=gtk+-3.0 --pkg=gee-0.8 _GedbParserParser.vapi \
	../inspect.vapi \
	home_parser.vala

_GedbParserParser.o : _HomeParser.h _GedbParserLexer.c _GedbParserParser.c _GedbParserParser.h
	cat _HomeParser.h _GedbParserLexer.c _GedbParserParser.c > _Parser.tmp.c
	${CC} ${CFLAGS} -I. -I.. -c -fPIC _Parser.tmp.c -o _GedbParserParser.o

home_parser.o: home_parser.c _GedbParserParser.c
	${CC} ${CFLAGS} -I. -I.. -c -fPIC -c home_parser.c

clean :
	rm -f *.lex *.lemon *.[hco] *.out* _Makefile*

clobber:
	rm -f ${SOBJECT} *.vapi *.lex *.lemon *.[hco] *.out* _Makefile*
