CC ?= cc
CFLAGS ?= $(DG) `pkg-config --cflags glib-2.0 gobject-2.0`
LIBS ?= `pkg-config --libs glib-2.0 gobject-2.0`
LEX ?= lex
CFLAGS_VALA ?= $(DG) -X -I.
SOBJECT = src_scanner.o _GedbScannerParser.o

all : ${SOBJECT} src_scanner.vapi

_GedbScannerParser.vapi _GedbScannerLexer.lex _GedbScannerParser2.h : src_scanner.vala
	../vle/vala-lemon-extractor

src_scanner.vapi src_scanner.c _GedbScanner.h : src_scanner.vala _GedbScannerParser.vapi ../inspect.vapi
	valac ${CFLAGS_VALA} --disable-warnings --vapidir=. --vapi=src_scanner.vapi -C -H _GedbScanner.h src_scanner.vala ../inspect.vapi _GedbScannerParser.vapi

_GedbScannerParser.c : _GedbScannerLexer.lex
	${LEX} -o _GedbScannerParser.c _GedbScannerLexer.lex

_GedbScannerParser.o : _GedbScanner.h _GedbScannerParser.c
	cat _GedbScanner.h _GedbScannerParser.c > _GedbParser.tmp.c
	${CC} ${CFLAGS} -fPIC -I. -I.. -c _GedbParser.tmp.c -o _GedbScannerParser.o

src_scanner.o: src_scanner.c _GedbScannerParser.c
	${CC} ${CFLAGS} -I. -I.. -fPIC -c src_scanner.c

clean :
	rm -f _M* *.lex *.[hco] *.out

clobber :
	rm -f _M* *.lex *.vapi *.[hco] *.out ${SOBJECT}

