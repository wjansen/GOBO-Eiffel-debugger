#!/bin/sh
gcc -w -fPIC   -c tool0.c
gcc -w -fPIC   -c tool3.c
gcc -w -fPIC   -c tool2.c
gcc -w -fPIC   -c tool1.c
gcc  -shared  -o libtool.so tool1.o tool2.o tool3.o tool0.o   -lm
