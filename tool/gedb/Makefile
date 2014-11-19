GLIB = `pkg-config --libs --cflags gtk+-3.0 gtksourceview-3.0 gee-0.8 gmodule-2.0`
CC = gcc
CFLAGS ?= $(CG) -w -fPIC -Ihome -Ieval -Isrc -w $(GLIB) 
LIBFLAGS ?= $(CG) -shared -fPIC -Wl,-rpath,$(GOBO)/bin 
LDFLAGS ?= $(CG) -fPIC -Wl,-rpath,$(GOBO)/bin 
VFLAGS = $(VG) --save-temps --disable-warnings -X -I. -X -Ihome -X -Ieval -X -Isrc -X -w -X -fPIC 
PKG = --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=gtksourceview-3.0 --target-glib=2.32 
# Define extensions
o=.o
l=.so 
e=
prelib=lib

VALA := inspect.vala misc.vala expression.vala breakpoint.vala \
  checker.vala persist.vala driver.vala \
  abstract_part.vala info_part.vala console_part.vala \
  stack_part.vala data_part.vala sql_part.vala \
  run_part.vala break_part.vala source_part.vala gui.vala 
VAPI := $(VALA:%.vala=%.vapi) 
OBJ := $(VALA:%.vala=%.o) help_part$o
C := $(OBJ:%$o=%.c)
H := $(OBJ:%$o=%.h)
EXTLIB = \
  home/home_parser.o home/_GedbParserParser.o \
  eval/eval_parser.o eval/_EvalParserParser.o \
  src/src_scanner.o src/_GedbScannerParser.o
DLL = $(GOBO)/bin/$(prelib)gedb$l
EXE = $(GOBO)/bin/gedb
VLE = vle/vala-lemon-extractor

.PHONY: all
.PHONY: home
.PHONY: eval
.PHONY: src

# ----------

all: $(VLE) $(EXE) $(DLL)

$(VLE): vle/vala-lemon-extractor.c
	cd vle && $(MAKE)

$(EXE): $(DLL) main$o 
	$(CC) -o $@ main$o $(LDFLAGS) $(DLL) $(GLIB) -ldl

$(DLL): $(OBJ) 
	$(CC) -o $@ $(LIBFLAGS) $(OBJ) $(EXTLIB) $(GLIB) -lm

src: $(VLE)
	cd src && $(MAKE)

home: $(VLE)
	cd home && $(MAKE)

eval: $(VLE) inspect.vapi misc.vapi expression.vapi breakpoint.vapi
	cd eval && $(MAKE)

inspect$o: inspect.vala
	valac -c $(VFLAGS) --vapi=inspect.vapi -h inspect.h $(PKG) $^
inspect.h: inspect.vapi
inspect.vapi: inspect.vala

misc$o: misc.vala inspect.vapi 
	valac -c $(VFLAGS) --vapi=misc.vapi $(PKG) -h misc.h $^
misc.h: misc.vapi
misc.vapi: misc.vala

expression$o: expression.vala inspect.vapi misc.vapi
	valac -c $(VFLAGS) --vapi=expression.vapi -h expression.h $(PKG) --pkg=posix $^
expression.h: expression.vapi
expression.vapi: expression.vala

breakpoint$o: breakpoint.vala inspect.vapi misc.vapi expression.vapi
	valac -c $(VFLAGS) --vapi=breakpoint.vapi -h breakpoint.h $(PKG) $^
breakpoint.vapi: breakpoint.vala

persist$o: persist.vala inspect.vapi misc.vapi
	valac -c $(VFLAGS) --vapi=persist.vapi -h persist.h $(PKG) $^
persist.vapi: persist.vala

driver$o: driver.vala inspect.vapi misc.vapi breakpoint.vapi persist.vapi \
 expression.vapi 
	valac -c $(VFLAGS) --vapi=driver.vapi -h driver.h $(PKG) $^
driver.vapi: driver.vala

checker$o: checker.vala inspect.vapi misc.vapi \
 expression.vapi breakpoint.vapi misc.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=checker.vapi -h checker.h $(PKG) $^
checker.vapi: checker.vala

abstract_part$o: abstract_part.vala inspect.vapi misc.vapi breakpoint.vapi \
 persist.vapi expression.vapi driver.vapi 
	valac -c $(VFLAGS) --vapi=abstract_part.vapi -h abstract_part.h $(PKG) $^
abstract_part.vapi: abstract_part.vala

info_part$o: info_part.vala
	valac -c $(VFLAGS) --vapi=info_part.vapi -h info_part.h $(PKG) $^
info_part.vapi: info_part.vala

console_part$o: console_part.vala misc.vapi inspect.vapi
	valac -c $(VFLAGS) --vapi=console_part.vapi -h console_part.h $(PKG) --pkg=posix $^
console_part.vapi: console_part.vala

stack_part$o: stack_part.vala inspect.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi info_part.vapi abstract_part.vapi
	valac -c $(VFLAGS) --vapi=stack_part.vapi -h stack_part.h $(PKG) $^
stack_part.vapi: stack_part.vala

data_part$o: data_part.vala inspect.vapi persist.vapi \
 misc.vapi expression.vapi breakpoint.vapi \
 driver.vapi abstract_part.vapi info_part.vapi stack_part.vapi checker.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=data_part.vapi -h data_part.h $(PKG) $^
data_part.vapi: data_part.vala

sql_part$o: sql_part.vala inspect.vapi persist.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi checker.vapi \
 info_part.vapi abstract_part.vapi stack_part.vapi data_part.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=sql_part.vapi -h sql_part.h $(PKG) $^
sql_part.vapi: sql_part.vala

run_part$o: run_part.vala inspect.vapi misc.vapi expression.vapi \
 breakpoint.vapi driver.vapi checker.vapi info_part.vapi \
 abstract_part.vapi console_part.vapi stack_part.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) -D POSIX --vapi=run_part.vapi -h run_part.h $(PKG) --pkg=posix $^
run_part.vapi: run_part.vala

break_part$o: break_part.vala inspect.vapi persist.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi checker.vapi \
 abstract_part.vapi info_part.vapi stack_part.vapi data_part.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=break_part.vapi -h break_part.h $(PKG) $^
break_part.vapi: break_part.vala

source_part$o: source_part.vala inspect.vapi persist.vapi \
 misc.vapi expression.vapi breakpoint.vapi driver.vapi info_part.vapi \
 abstract_part.vapi console_part.vapi stack_part.vapi data_part.vapi \
 run_part.vapi break_part.vapi \
 home/home_parser.vapi home/_GedbParserParser.vapi \
 src/src_scanner.vapi src/_GedbScannerParser.vapi
	valac -c $(VFLAGS) --vapi=source_part.vapi -h source_part.h $(PKG) $^
source_part.vapi: source_part.vala

gui$o help_part$o: gui.vala help_part.vala inspect.vapi misc.vapi \
 persist.vapi expression.vapi breakpoint.vapi driver.vapi info_part.vapi \
 abstract_part.vapi console_part.vapi stack_part.vapi data_part.vapi \
 sql_part.vapi checker.vapi run_part.vapi break_part.vapi source_part.vapi \
 src/src_scanner.vapi src/_GedbScannerParser.vapi \
 home/home_parser.vapi home/_GedbParserParser.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --library gui -h gui.h $(PKG) --pkg=posix $^
gui.vapi: gui.vala eval
#help_part.vapi: help_part.vala

main$o: main.vala gui.vapi inspect.vapi persist.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi \
 abstract_part.vapi info_part.vapi console_part.vapi stack_part.vapi \
 data_part.vapi  sql_part.vapi checker.vapi run_part.vapi break_part.vapi \
 source_part.vapi \
 src/src_scanner.vapi src/_GedbScannerParser.vapi \
 home/home_parser.vapi home/_GedbParserParser.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) $(PKG) --pkg=gmodule-2.0 $^

libgedb.a: gui.o inspect.o persist.o misc.o \
 expression.o breakpoint.o driver.o \
 abstract_part.o info_part.o console_part.o stack_part.o \
 data_part.o  sql_part.o checker.o run_part.o break_part.o \
 source_part.o help_part.o \
 src/src_scanner.o src/_GedbScannerParser.o \
 home/home_parser.o home/_GedbParserParser.o \
 eval/eval_parser.o eval/_EvalParserParser.o 
	$(AR) q libgedb.a $^


src/src_scanner.vapi src/_GedbParser.vapi: src
home/home_parser.vapi home/_GedbParserParser.vapi: home
eval/eval_parser.vapi eval/_EvalParserParser.vapi: eval

# ----------

clean:
	$(RM) $(OBJ) $(H) $(C) main.[hco]
	cd src && $(MAKE) clean
	cd home && $(MAKE) clean
	cd eval && $(MAKE) clean

clobber:
	$(RM) *.h $(OBJ) $(H) $(C) main.[hco]  $(VAPI) $(DLL) $(EXE)
	cd src && $(MAKE) clobber
	cd home && $(MAKE) clobber
	cd eval && $(MAKE) clobber
