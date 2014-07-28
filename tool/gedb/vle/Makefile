CFLAGS=-O2

all : vala-lemon-extractor

vala-lemon-extractor : vala-lemon-extractor.c
	gcc ${CFLAGS} vala-lemon-extractor.c -o vala-lemon-extractor

clean :
	rm -f vala-lemon-extractor

install : all
	cp vala-lemon-extractor /usr/bin/
	chmod a+x /usr/bin/vala-lemon-extractor
