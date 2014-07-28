GLIB = `pkg-config --libs --cflags gtk+-3.0 gtksourceview-3.0 gee-0.8 gmodule-2.0`
CC = gcc
CFLAGS ?= -g -w -fPIC -Ihome -Ieval -Isrc -w $(GLIB) 
LIBFLAGS ?= -shared -fPIC -Wl,-rpath,$(GOBO)/bin 
LDFLAGS ?= -fPIC -Wl,-rpath,$(GOBO)/bin 
VFLAGS = -g --save-temps --disable-warnings -X -I. -X -Ihome -X -Ieval -X -Isrc -X -w -X -fPIC 
PKG = --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=gtksourceview-3.0 --pkg=gmodule-2.0 --target-glib=2.32 
# Define extensions
o=.o
l=.so 
e=
prelib=lib

VALA := extern.vala inspect.vala persist.vala \
  misc.vala expression.vala breakpoint.vala driver.vala \
  checker.vala info_part.vala console_part.vala \
  stack_part.vala data_part.vala sql_part.vala \
  run_part.vala break_part.vala source_part.vala gui.vala 
VAPI := $(VALA:%.vala=%.vapi) 
OBJ := $(VALA:%.vala=%.o) help_part$o
C := $(OBJ:%$o=%.c)
H := $(OBJ:%$o=%.h)
EXTLIB = \
  -L./home -Wl,-rpath,$(PWD)/home -lhome_parser \
  -L./eval -Wl,-rpath,$(PWD)/eval -leval_parser \
  -L./src -Wl,-rpath,$(PWD)/src -lsrc_scanner
DLL = $(GOBO)/bin/$(prelib)gedb$l
EXE = $(GOBO)/bin/gedb

.PHONY: all
.PHONY: home
.PHONY: eval
.PHONY: src

# ----------

all: $(EXE) $(DLL)

$(EXE): $(DLL) main$o 
	$(CC) -o $@ main$o $(LDFLAGS) $(DLL) $(GLIB) -ldl

$(DLL): $(OBJ) 
	$(CC) -o $@ $(OBJ) $(LIBFLAGS) $(LDFLAGS) $(EXTLIB) $(GLIB) -lm

src:
	cd src && $(MAKE)

home:
	cd home && $(MAKE)

eval: extern.vapi inspect.vapi misc.vapi expression.vapi breakpoint.vapi
	cd eval && $(MAKE)

extern$o: extern.vala
	valac -c $(VFLAGS) --vapi=extern.vapi -h extern.h $(PKG) extern.vala
extern.vapi: extern.vala

inspect$o: inspect.vala extern.vapi
	valac -c $(VFLAGS) --vapi=inspect.vapi -h inspect.h $(PKG) $^
inspect.h: inspect.vapi
inspect.vapi: inspect.vala

persist$o: persist.vala inspect.vapi extern.vapi
	valac -c $(VFLAGS) --vapi=persist.vapi -h persist.h $(PKG) $^
persist.vapi: persist.vala

expression$o: expression.vala extern.vapi inspect.vapi misc.vapi
	valac -c $(VFLAGS) --vapi=expression.vapi -h expression.h $(PKG) --pkg=posix $^
expression.h: expression.vapi
expression.vapi: expression.vala

misc$o: misc.vala extern.vapi inspect.vapi 
	valac -c $(VFLAGS) --vapi=misc.vapi $(PKG) -h misc.h $^
misc.h: misc.vapi
misc.vapi: misc.vala

breakpoint$o: breakpoint.vala extern.vapi inspect.vapi misc.vapi expression.vapi
	valac -c $(VFLAGS) --vapi=breakpoint.vapi -h breakpoint.h $(PKG) $^
breakpoint.vapi: breakpoint.vala

driver$o: driver.vala breakpoint.vapi inspect.vapi persist.vapi extern.vapi \
 misc.vapi expression.vapi 
	valac -c $(VFLAGS) --vapi=driver.vapi -h driver.h $(PKG) $^
driver.vapi: driver.vala

checker$o: checker.vala extern.vapi inspect.vapi extern.vapi misc.vapi \
 expression.vapi breakpoint.vapi misc.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=checker.vapi -h checker.h $(PKG) $^
checker.vapi: checker.vala

info_part$o: info_part.vala
	valac -c $(VFLAGS) --vapi=info_part.vapi -h info_part.h $(PKG) $^
info_part.vapi: info_part.vala

console_part$o: console_part.vala
	valac -c $(VFLAGS) --vapi=console_part.vapi -h console_part.h $(PKG) --pkg=posix $^
console_part.vapi: console_part.vala

stack_part$o: stack_part.vala extern.vapi inspect.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi info_part.vapi 
	valac -c $(VFLAGS) --vapi=stack_part.vapi -h stack_part.h $(PKG) $^
stack_part.vapi: stack_part.vala

data_part$o: data_part.vala extern.vapi inspect.vapi extern.vapi persist.vapi \
 misc.vapi expression.vapi breakpoint.vapi \
 driver.vapi info_part.vapi stack_part.vapi checker.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=data_part.vapi -h data_part.h $(PKG) $^
data_part.vapi: data_part.vala

sql_part$o: sql_part.vala inspect.vapi persist.vapi extern.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi checker.vapi \
 info_part.vapi stack_part.vapi data_part.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=sql_part.vapi -h sql_part.h $(PKG) $^
sql_part.vapi: sql_part.vala

run_part$o: run_part.vala inspect.vapi extern.vapi misc.vapi expression.vapi \
 breakpoint.vapi driver.vapi checker.vapi info_part.vapi \
 console_part.vapi stack_part.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) -D POSIX --vapi=run_part.vapi -h run_part.h $(PKG) --pkg=posix $^
run_part.vapi: run_part.vala

break_part$o: break_part.vala inspect.vapi extern.vapi persist.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi checker.vapi \
 info_part.vapi stack_part.vapi data_part.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --vapi=break_part.vapi -h break_part.h $(PKG) $^
break_part.vapi: break_part.vala

source_part$o: source_part.vala inspect.vapi extern.vapi persist.vapi \
 misc.vapi expression.vapi breakpoint.vapi driver.vapi info_part.vapi \
 console_part.vapi stack_part.vapi data_part.vapi run_part.vapi \
 break_part.vapi \
 home/home_parser.vapi home/_GedbParserParser.vapi \
 src/src_scanner.vapi src/_GedbScannerParser.vapi
	valac -c $(VFLAGS) --vapi=source_part.vapi -h source_part.h $(PKG) $^
source_part.vapi: source_part.vala

gui$o help_part$o: gui.vala help_part.vala inspect.vapi extern.vapi misc.vapi \
 persist.vapi expression.vapi breakpoint.vapi driver.vapi info_part.vapi \
 console_part.vapi stack_part.vapi data_part.vapi sql_part.vapi checker.vapi \
 run_part.vapi break_part.vapi source_part.vapi \
 src/src_scanner.vapi src/_GedbScannerParser.vapi \
 home/home_parser.vapi home/_GedbParserParser.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) --library gui -h gui.h $(PKG) --pkg=posix $^
gui.vapi: gui.vala eval
#help_part.vapi: help_part.vala

main$o: main.vala gui.vapi inspect.vapi extern.vapi persist.vapi misc.vapi \
 expression.vapi breakpoint.vapi driver.vapi \
 info_part.vapi console_part.vapi stack_part.vapi data_part.vapi \
 sql_part.vapi checker.vapi run_part.vapi break_part.vapi source_part.vapi \
 src/src_scanner.vapi src/_GedbScannerParser.vapi \
 home/home_parser.vapi home/_GedbParserParser.vapi \
 eval/eval_parser.vapi eval/_EvalParserParser.vapi 
	valac -c $(VFLAGS) $(PKG) $^

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
