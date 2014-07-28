#!/bin/sh
# the next line restarts using tclsh \
exec wish "$0" "$@"

set small 1
source "$env(GOBO)/bin/gedb.tcl"
