#!/bin/sh
# the next line restarts using tclsh \
exec wish "$0" "$@"

#### Geometry definitions

if {[info exists small]} {
    set breakH 3
    set sourceH 16
    set stackH 6
    set dataH 12
    set fp 3
    toplevel .main0
} else {
    set breakH 6
    set sourceH 24
    set stackH 8
    set dataH 18
    set fp 5
}

#### Global variables

proc getenv {name} {
# Workaround
   set fn [pid]
   set fn "$fn.dat" 
   exec echo $name > $fn
   set dat [open $fn r]
   set val [gets $dat]
   file delete $fn
   return $val
}

set io ""
set timeout 0
set process 0
set debuggee ""
set directory ""
set title "gedb:"
set gobo [getenv "GOBO"]
set sys ""
set running false
set atend false
set awaited 0
set lastCommand ""
set skip 0
set classes {}
set actClass {}
set posList {}
set likeList {}
set names {}
set firstFound ""
set lastFound ""
set forward 1
set nocase 0
set calls ""
set stopReason ""
set nameof ""
set infoSystem ""
set errorDetail "" 

#### Connection to debuggee
proc serverOpen {channel addr port} {
    global io
    set io $channel
    fileevent $channel readable "getAnswer"
}

proc timedout {port} {
    global erroInfo errorDetail
    set errorInfo "Socket connection not established."
    set errorDetail "Port $port already in use."
    showError
    initVariables
}

proc startup {sys} {
    global process io timeout awaited skip
    global title debuggee directcory
    set pf [array get tcl_platform platform]
    set fn [lindex $sys 0]
    set args [lrange $sys 1 end]
    set fn [file nativename $fn]
    if {$::tcl_platform(platform)=="windows"} { 
	set fn [file attributes $fn -shortname]
    }
    if {[llength [auto_execok $fn]]==0} { 
        set errorInfo "Load error."
        set errorDetail "\"$fn\" is not executable."
        showError
    }
    set debuggee [file tail $sys]
    set directory [file dirname $sys]
    set maxport 2012
    for {set port 1947} {$port<$maxport} {incr port} {
	if {[catch { socket -server serverOpen $port }]==0} { break }
    }
    if {$port>=$maxport} {
	timedout $port
    }
    set args [concat $args "\#$port\#"]
    set process [exec $fn $args &]
    set awaited "other"
    set skip 1
    while {$awaited!=0} { vwait awaited }

    wm title . "$title $debuggee"
    if {[winfo exists .main0]} { wm title .main0 "$title $debuggee - Data" }
    putCommand "universe" "types"
    doStack 0 1
    showAlias
    putBreakCommand "" ""
}

#### Procedures

proc activateFrame {w yes} {
    set type [winfo class $w]
    if {[string first "Tree" $type]>=0 || [string first "rame" $type]>=0}  {
	if {$yes} {
	    $w state !disabled
	} else {
	    $w state disabled
	}
	foreach sub [winfo children $w] {
	    activateFrame $sub $yes
	}
    } elseif {[string first "utton" $type]>=0 || [string first "box" $type]>=0 || [string first "ntry" $type]>=0}  {
	if {$yes} {
	    $w state !disabled
	} else {
	    $w state disabled
	}
    }
}

proc activate {yes} {
    global running stackframe runbp data0 stop
    activateFrame $runbp.run $yes
    activateFrame $runbp.break $yes
    activateFrame $stackframe $yes
    activateFrame [dict get $data0 vars] $yes
    if {$yes} {
	set running false
	$stop configure -state disabled
    } else {
	set running true
	$stop configure -state normal
    }
}

proc activateUpdated {yes} {
    global dataSet data0
    set d0 [dict get $data0 vars]
    dict for {id d} $dataSet { 
	if {$id != 0} {
	    set win [winfo parent [winfo parent [dict get $d vars]]]
	    activateFrame $win.vars.list $yes 
	    set win [winfo parent $win]
	    activateFrame $win.stack $yes 
	}
    }
}

proc activateMove {} {
    global dataSet data data0
    set depth0 [[dict get $data0 stack] selection]
    if {$data==$data0} {
	dict for {id d} $dataSet { 
	    if {$id != 0} {
		set depth [[dict get $d stack] current]
		set do [winfo parent [winfo parent [dict get $d expr]]]
		activateFrame $do.do.level [expr $depth>=$depth0]
	    }
	}
    } else {
	set depth [[dict get $data stack] current]
	set do [winfo parent [winfo parent [dict get $data expr]]]
	activateFrame $do.do.level [expr $depth>=$depth0]
    }
}

proc showError {} {
    global errorInfo errorDetail title debuggee
    set t "$title $debuggee - Message" 
    if {$errorDetail==""} {
	tk_messageBox -message $errorInfo -icon info -type ok -title $t
    } else {
	tk_messageBox -message $errorInfo -detail $errorDetail \
	    -icon error -type ok -title $t
	set errorDetail ""
    }
    set errorInfo ""
}

proc highlightStop {name} {
    global stack classField source
    set item [inStack $name]
    if {$item=={}} {
	set item [$stack selection] 
    } else {
	set item [lindex $item 0]
    }
    set vals [$stack item $item -values ]
    set cls [lindex $vals 1]
    if {[$classField get]==$cls} {
	set row [lindex $vals 3]
	if {$row!={}} {
	    set col [lindex $vals 4]
	    if {$col=={}} { set col 1 }
	    set idx "$row.$col -1 char"
	    $source tag add rowtag "$idx linestart" "$idx lineend"
	    $source tag add actualtag $idx
	    $source see $idx
	}
    }
}

proc highlightBreak {at} {
    global source classField
    if {$at!=""} {
	set words [split $at ":"]
	if {[$classField get]==[lindex $words 0]} {
	    if {[llength $words]>2} {
		set c [expr [lindex $words 2] -1]
		set idx [lindex $words 1].$c
		$source tag add breaktag "$idx" 
	    }
	}
    }
}

proc setActClass {cls} {
    global classes actClass posList
    if {$actClass=={} || [dict get $actClass name]!=$cls} { 
	set posList [lreplace $posList 0 end] 
	foreach c $classes {
	    if {[dict get $c name]==$cls} { 
		set actClass $c
		break
	    }
	}
    } 
}

proc showSource {cls} {
    global classField source lines breaks stack instack
    global actClass running
    $classField set $cls
    setActClass $cls
    if {[readSource $source]} {   
	$source configure -state disabled
	foreach b [$breaks children {}] {
	    highlightBreak [lindex [$breaks item $b -values] 2]
	}
	highlightPos 1
	selection clear $classField
	highlightStop [dict get $actClass name]
	$lines configure -state normal 
	$lines delete 1.0 end
	set ln [$source count -lines 1.0 end]
	for {set n 1} {$n<$ln} {incr n} { $lines insert end [format "%6d\n" "$n"] }
	$lines configure -state disabled
    }
    set instack [inStack [dict get $actClass name]]
}

proc highlightPos {yes} {
    global source actClass posList running editable
    set cls [dict get $actClass name]
    if {$yes} {
	if {$running || (!$editable && [inStack $cls]=={}) } { return }
	if {$posList=={}} {
	    putCommand "\#$cls" "pos"
	}
	foreach p $posList {
	    set idx "[expr $p/256].[expr $p%256] -1 char"
	    set c [$source get $idx] 
	    if {$c==" " || $c=="	"} {
		$source tag add postag $idx "$idx +2 char"
	    } else {
		$source tag add postag $idx 
	    }
	}
    } elseif {[inStack $cls]=={}} {
	$source tag remove postag 1.0 end
    }
}

proc readSource {text} {
    global source errorCode keywords running
    global actClass
    set errorCode 0
    set file [dict get $actClass file]
    if {$file=={}} {
	set file [dict get $actClass name]
	putCommand "\#\#$file" "pos" 
	set file [dict get $actClass file]
    }
    catch { set f [open $file] }
    if {$errorCode==0} {
	$text configure -state normal
	$text delete 1.0 end
	
	set line ""
	set l 0
	set n 0
	set instring 0
	while {$n>=0} {
	    set n [gets $f line]
	    $text insert end $line
	    $text insert end "\n"
	    if {$text==$source} {
		incr l
		highlightSyntax $l
	    }
	}
	close $f
	dict set actClass len [$source count -lines 1.0 end]
	return 1
    }
    return 0
}

proc highlightSyntax {l} {
    global source keywords
    set idx "$l.0"
    set idxstart $idx
    set incomment 0
    set instring 0
    set idxend [$source index "$idx lineend"]
    for {} {[$source compare $idx <= $idxend]} {set idx [$source index "$idx +1 chars"]} {
	set ch [$source get $idx]
	set last [$source compare $idx == $idxend]
	switch $ch {
	    "\"" { 
		if {$incomment} {
		} elseif {$instring} {
		    set instring 0
		    $source tag add stringtag $idxstart $idx  
		} else {
		    set instring 1
		    set idxstart [$source index "$idx +1 chars"]
		}
	    }
	    "-" { 
		if {$instring || $incomment} {
		} elseif {!$last} {
		    if {[$source get "$idx +1 chars"]=="-"} {
			set incomment 1
			$source tag add commenttag $idx $idxend 
			break
		    }
		}
	    }
	    default {
		if {$instring || $incomment} {
		} elseif {[regexp {[A-Za-z]} $ch]} {
		    set idxword [$source index "$idx wordend"]
		    set word [$source get $idx $idxword]
		    if {[lsearch -nocase $keywords $word]>=0} {
			$source tag add keywordtag $idx $idxword 
		    }
		    set idx [$source index "$idxword -1 chars"]
		}
	    }	
	}
    }
}

proc toSource {} {
    global source classField textIndex actClass
    set cls [.ftext.class.name cget -text]
    setActClass $cls
    readSource $source
    $classField set $cls
    $source see $textIndex
    wm withdraw .ftext
}

proc showLikeMenu {idx} {
    global likeMenu source actClass stack instack
    $likeMenu entryconfigure 0 -state normal
    $likeMenu entryconfigure 1 -state disabled
    $likeMenu entryconfigure 2 -state disabled
    if {$instack=={}} { return }
    set tags [$source tag names $idx]
    set tagged 0 
    foreach t $tags {
	switch $t {
	    featuretag { set tagged 1}
	}
    }
    if {$tagged} {
	$likeMenu entryconfigure 1 -state normal
	set last [$source index featuretag.last]
	set next [$source search -regexp {[^ ]} $last]
	if {[regexp {[,.)]} [$source get $next]]} { 
	    $likeMenu entryconfigure 2 -state normal 
	}
    }
}

proc showLikeSource {} {
    global source liketext likeList textIndex actClass
    global title debuggee
    if {[llength $likeList]<2} { return }
    set old $actClass
    set cls [lindex $likeList 0]
    setActClass $cls
    if {[readSource $liketext]} {
	$liketext tag remove foundtag 1.0 end
	set f [lindex $likeList 1]
	set first [$liketext index $f.0]
	set l [lindex $likeList end]
	set last [$liketext index "$l.0 lineend"]
	set n [$liketext cget -height]
	set l [expr $l-$f+1]
	if {$l>$n} {
	    set textIndex [$liketext index "[expr $f+$n/2].0"]
	} else {
	    set textIndex [$liketext index "[expr $f+$l/2].0"]
	}
	$liketext see $textIndex	    
	$liketext tag add foundtag $first $last
	set ftext [winfo toplevel $liketext]
	$ftext.class.name configure -text $cls
	wm title .ftext "$title $debuggee - Feature"
	wm transient $ftext 
	wm deiconify $ftext
    }
    set actClass $old
}

proc showLike {idx} {
    global source liketext featureStart actClass
    global errorInfo errorDetail
    if {$idx==""} {
	set errorInfo "Not in a feature."
	showError 
	return 
    }
    if {![string is wordchar [$source get $featureStart]]} { 
	set errorInfo "Not at an expression."
	showError 
	return 
    }
    set likeList {}
    set xy [split [$source index "$featureStart +1 chars"] "."]
    set pos [lindex $xy 0]:[lindex $xy 1]
    $liketext delete 1.0 end
    putCommand "def [dict get $actClass name]:$pos" "like"
}

proc printLike {idx} {
    global source expr actClass
    global running errorInfo errorDetail
    set pos [highlightFeature $idx]
    set range [dict get $actClass range]
    if {[llength $range]<3} { return } 
    if {($pos<[lindex $range 2]) || ([lindex $range 1]<$pos)} { return }
    $expr delete 1.0 end
#    $expr insert 1.0 $ex
#    focus $expr
#    doPrint 0 1
}

proc highlightFeature {idx} {
    global source featureStart featureEnd running
    global actClass stack instack
    set ok 1
    if {$running} { set ok 0 }
    if {![string is wordchar [$source get $idx]]} { set ok 0 }
    set tags [$source tag names $idx]
    foreach t $tags {
	switch $t {
	    keywordtag { set ok 0 }
	    stringtag { set ok 0 }
	    commenttag { set ok 0 }
	}
    }
    if {!$ok} {
        $source tag remove featuretag $featureStart $featureEnd    
        return 
    }
    set st [$stack item $instack -values]
    putCommand "\#\$[lindex $st 1].[lindex $st 2]" "pos"
    set l [$source index "$idx wordend"]
    set n [$source index "$idx wordstart"]
    $source tag remove featuretag $featureStart $featureEnd    
    set featureStart $n
    set featureEnd $l
    $source tag add featuretag $featureStart $featureEnd
    return [$source index "$n +1 chars"]
}

proc searchSource {pattern incremental} {
    global source searchIndex forward nocase firstFound lastFound actClass
    global errorCode errorInfo errorDetail
    clearFoundSource
    set n 0
    if {$incremental} {
        if {$forward} {
	    set firstFound [$source search -nocase -count n $pattern $searchIndex]
        } else {
	    set firstFound [$source search -nocase -backwards -count n $pattern $searchIndex]
	} 
    } else {
        set errorCode 0
        catch {regexp $pattern ""}
        if {$errorCode!=0} {
	    set errorDetail $pattern
	    showError 
	    return
        }
        if {$forward} {
	    if {$nocase} {
	        set firstFound [$source search -regexp -nocase -count n $pattern $searchIndex]
	    } else {
	        set firstFound [$source search -regexp -count n $pattern $searchIndex]
	    }
        } else {
	    if {$nocase} {
	        set firstFound [$source search -regexp -nocase -backwards -count n $pattern $searchIndex]
	    } else {
	        set firstFound [$source search -regexp -backwards -count n $pattern $searchIndex]
	    }
	} 
    }
    set lastFound "$firstFound + $n chars"
    if {$firstFound!=""} { 
	$source tag add foundtag $firstFound $lastFound
	$source see $firstFound
	if {$forward} {
	    $source mark set insert "$lastFound"
	} else {
	    $source mark set insert "$firstFound - 1 char"
	}
	if {!$incremental} {
	    if {$forward} { 
	        set searchIndex "$lastFound +1 chars"
	    } else {
		set searchIndex "$firstFound -1 chars"
	    }
	}
    }
}

proc clearFoundSource {} {
    global source firstFound lastFound
    set l -1
    if {$firstFound!=""} { 
	set firstFound [$source index $firstFound]
	set lastFound [$source index $lastFound]
	$source tag remove foundtag $firstFound $lastFound 
	set l [string first "." $firstFound]	
    }
}

proc showStatus {txt} {
    global status
    set status $txt
}

proc showAt {prompt xy} {
    global source 
    showStatus "$prompt [$source index "$xy + 1 char" ]"
}

proc showReason {} {
    global stopReason source
    if { $stopReason!=""} {  
	showStatus "Stopped because of $stopReason" 
        if {[string first "Breakpoint" $stopReason]>=0} {
            breakClear 0
            putCommand "info break" "ibreak"
        }
    } else {
	showStatus ""
    }
}

proc doGo {cmd} {
    global cont next step end finish 
    global runmode runcount 
    global data data0 markable markList breaks
    global log stopReason needBreaks
    global data data0
    if {$runmode=="break"} {
	set mode ""
    } else {
	set mode $runmode
    }
    set needBreaks 0
    $breaks selection set {}
    set stopReason "step-by-step"
    showStatus "Running"
    set cmd "$cmd $mode $runcount"
    set prev [$log index end]
    putLog "\n$cmd" 0
    activate 0
    activateUpdated 0
    putCommand $cmd "current"
    activate 1
    set runcount 1 
    set markable 1
    set markList {}
    putCommand "info mark" "imark"
    set data $data0
    doStack 0 1
    showReason
    if {$needBreaks} { 
	putBreakCommand "" "" 
	foreach c [$breaks children {}] {
	    set vals [$breaks item $c -values]
	    if {[lindex $vals 0]==$needBreaks} {
		$breaks selection set $c
		break
	    }
	}
	set needBreaks 0 
    }
}

proc interruptProcess {code} {
    global process errorCode errorInfo errorDetail
    if {!$code} {
	set errorCode 0
	catch {exec kill -s INT $process}
	if {$errorCode!=0}  { set code 1 }
    } 
    if {$code} {
	set errorInfo "Debuggee process is not longer alive."
	set errorDetail ""
	showError
	initVariables
    }
}

proc doStop {} {
    global running stopReason awaited
    interruptProcess 0 
    activate 1
    if {$running} { 
	set awaited "other"
	set stopReason "interrupt" 
    }
}

proc doStack {item refresh} {
    global stack calls source data
    global cont next step off end finish stop
    global stopReason 
    global mark markable log
    global errorCode
    set old ""
    set vars [dict get $data vars]
    set oldsel ""
    set old [lindex [$vars children {}] 0]
    set sel [$stack selection]
    if {$sel!={} && $old!={} && [$vars item $old -text]=="Current"} {
	set old [$stack item $sel -values]
	set old [lrange $old 1 2]
	set oldsel [$vars selection]
    } else {
	set old {}
    }
    if {$refresh} { 
	set calls "" 
	putCommand "where" "where" 
	set errorCode 0
	catch { $stack delete [$stack children {}] } 
	if {$errorCode!=0} { $stack configure -values {} }
	set i 0
	foreach c $calls { 
	    $stack insert {} end -id $i -values $c
	    incr i
	}
    }
    putCommand ". $item" "other"
    [dict get $data expr] delete 1.0 end
    if {[llength $calls]==0} {
	set item -1
	doPrint 0 1
	$source configure -state normal
	$source delete 1.0 end
    }
    if {$item>=0} {
	$stack selection set $item
	if {$refresh} { set vals [$stack item [$stack selection] -values]
	    putLog "[lindex $vals 1].[lindex $vals 2]:[lindex $vals 3]:[lindex $vals 4]" 1
	}
	$cont configure -state normal
	$next configure -state normal
	$step configure -state normal
	$off configure -state normal
	$end configure -state normal
	if {$item==0} {
	    $finish configure -state disabled
	    if {$markable} {
		$mark configure -state normal
	    } else {
		$mark configure -state disabled
	    }
	} else {
	    $finish configure -state normal
	    $mark configure -state disabled
	} 
	set s 0
	if {$old!={}} {
	    set new [$stack item [$stack selection] -values]
	    set new [lrange $new 1 2]
	    if {[lindex $old 0]==[lindex $new 0] && [lindex $old 1]==[lindex $new 1] } { 
		set s 1
	    }
	}
	set words [split [lindex $calls $item]]
	if {$words!=0} {
	    showSource [lindex $words 1]
	    $vars selection set {}
	    doPrint $s 1
	    if {[$vars exists $oldsel]} { $vars selection set $oldsel }
	}
	activateMove 
    } else {
	$cont configure -state disabled
	$next configure -state disabled
	$step configure -state disabled
	$off configure -state disabled
	$end configure -state disabled
	$finish configure -state disabled
	$stop configure -state disabled
	$mark configure -state disabled
	$source delete 1.0 end
	set stopReason "program end" 
    }
}

proc doExtraStack {} {
    global calls data
    set st [dict get $data stack] 
    set vals [split [$st get] " :"]
    set item [lindex $vals 0]
    putCommand ". $item" "other"
    doPrint 0 1
    activateMove 
}

proc statusStack {item kind} {
    global stack 
    set vals [$stack item $item -values]
    set detail ""
    switch $kind {
	"#2" { set detail [lindex $vals 1]
	    if {$detail!=""} { set detail "Class: $detail" }
	}
	"#3" { set detail [lindex $vals 2]
	    if {$detail!=""} { set detail "Routine: $detail" }
	}
	default { }
    }
    showStatus $detail
}

proc inStack {cls} {
    global stack
    set item [$stack selection]
    set vals [$stack item $item -values]
    if {$cls=="" || $cls==[lindex $vals 1]} { 
	return $item
    } else {
	foreach c [$stack children {}] { 
	    set vals [$stack item $c -values]
	    if {[lindex $vals 1]==$cls} {
		return $c
	    }
	}
    }
    return {}
}

proc doMark {} {
    global mark markList markable runbp
    putCommand "mark" "other"
    set markable 0
    set markList {}
    $runbp.run.reset configure -values {}
    putCommand "info mark" "imark"
    $mark configure -state disabled
    putLog "mark [expr [llength $markList] -1]" 0
}

proc doReset {m} {
    global atend source mark runbp
    set idx [lindex [split $m] 0]
    set cmd "reset $idx"
    putLog " --------------------------------------\n$cmd" 0
    set atend false
    putCommand $cmd "other"
    set markable 0
    set markList {}
    $runbp.run.reset configure -values {}
    putCommand "info mark" "imark"
    $mark configure -state disabled
    activate 1
    doStack 0 1
    breakClear 0
    putCommand "info break" "ibreak"
}

proc doPrint {sel cmd} {
    global data varcount varstack vartop printQueue needTreeRemoval
    set vars [dict get $data vars]
    set expr [dict get $data expr]
    set var [$expr get 1.0 end]
    if {$sel} {
	set item [$vars selection]
	if {$item=={}} {
	    set var ""
	} else {
	    set var [prependParents $vars $item ""]
	}
    } else {
	set item {}
    }
    set vartop $item
    set varstack [list $vartop]
    if {$cmd==1} { 
	set c "print" 
    } else {
	set c "closure"
    }
    if {[[dict get $data hex] instate selected]} {
	set f "/xan"
    } else {
	set f "/an"
    }
    set needTreeRemoval 0
    if {!$sel} {
	set needTreeRemoval 1
        set vartop {}
        set varstack [list $vartop]
        set item {}
    }
    activate 0
    putCommand "$c $f [string trim $var]" "print"
    while {[llength $printQueue]>0} {
	set item [lindex $printQueue 0]
	set printQueue [lreplace $printQueue 0 0]
	set name [$vars item $item -text]
	set name [expandExpr $vars $item $name]
	$vars selection set $item
	doPrint 1 1
    }
    activate 1
    if {$item=={}} {
	set ch [$vars children $item]
	if {[llength $ch]>0} { set item [lindex $ch 0] }
    }
    $vars item $item -open true
}

proc prependParents {vars item ex} {
    for {set p $item} {$p!=""} {set p [$vars parent $p]} {
	set name [$vars item $p -text]
	if {$ex==""} {
	    set ex [$vars item $p -text]
	} elseif {[string first "\[" $ex]==0} {
	    set ex [format "%s%s" $name "$ex"] 
	} elseif {[regexp {[^][A-Za-z0-9_ ]} $name]>0} {
	    set ex [format "(%s).%s" $name "$ex"] 
	} else {
	    set ex [format "%s.%s" $name "$ex"] 
	}
    }
    return $ex
}

proc expandExpr {vars item expr} {
    if {[llength [$vars children $item]==0]} { 
	set ex [prependParents $vars $item ""]
	set n [expr [string length $ex]-1]
	return [string range $ex 0 $n]
    } else {
	return ""
    }
}

proc fillExpr {vars item sel} {
    set colon [string first ":" $sel]
    if {$colon>=0} { set sel [string range $sel 0 $colon-1] }
    set full [prependParents $vars $item $sel]
    if {[string match {[Cc]urrent} $full]} {
	set full ""
    } else {
	set curr ""
	regexp {^[Cc]urrent\.} $full curr
	if {$curr!=""} { set full [string range $full 8 end] }
    }
    return $full
}

proc expandArgs {call} {
    global argList 
    set l [string first "(" $call]
    if {$l>=0} {
       set name [string trim [string range $call 0 $l-1]]
           set args [dict get $argList id $name]
           set call [string replace $call $l end $args]
    }
    set l [string first "(" $call]
    if {$l>=0} {
       set name [string trim [string range $call 0 $l-1]]
           set args [dict get $argList id $name]
           set call [string replace $call $l end $args]
    }
    return $call
}

proc setExpr {data item sel} {
    set vars [dict get $data vars]
    set expr [dict get $data expr]
    set sel [expandArgs $sel]
    set sel [fillExpr $vars $item $sel]
    invalidateExpr $expr [$expr index insert] $sel
}

proc invalidateExpr {text where what} {
    $text insert $where $what
    set to [$text index insert]
    set c [string index $what end]
    if {![string is wordchar $c]} { 
        switch $c {
            "]" { set c "[" }
            ")" { set c "(" }
            default {}
        }
        set at [string last $c $what]
        incr at
        set where [$text index "$where +$at indices"]
        set to [$text index "$to -1 indices"]
        $text tag add placeholdertag $where $to
    }
    $text see $where
    focus $text
}

proc checkExpr {text} {
    set idx ""
    if {![catch {$text index placeholdertag.first} idx]} {
        $text mark set insert $idx 
        focus $text
        return false
    }
    return true
}

proc moveExpr {expr d} {
    global data0
    if {$expr==""} { set expr "Current" }
    set d0 [[dict get $data0 stack] selection]
    set depth [[dict get $d stack] current]
    if {$d0<=$depth} {
	set hats $expr
	for {set i $d0} {$i<$depth} {incr i} { set hats [format "^%s" $hats] }
	set dex [dict get $data0 expr]
	$dex insert [$dex index insert] $hats
    }
}

proc showQueries {vars item x y} {
    global queryMenu
    if {$item!={}} {
	$queryMenu delete 1 end
	set vals [$vars item $item -values]
	set t [lindex $vals 1]
	if {$t!=""} {
	    if {[$vars item $item -text]=="Current"} { 
		set t ""
	    } else {
		set count ""
		regexp { \[[0-9]+\]} $t count
		if {$count!=""} {
		    set n [string first $count $t]
		    set t "SPECIAL\[[string replace $t $n end]\]"
		}
	    }
	    putCommand "queries $t" "queries"
	}
	tk_popup $queryMenu $x $y
    }
}

proc statusData {vars item kind} {
    global nameof
    set vals [$vars item $item -values]
    set detail ""
    switch $kind {
	"#0" { 
	    set name [$vars item $item -text]
	    if {[regexp {^_[0-9]+$} $name]} { 
		set name [string replace $name 0 0 ]
		set nameof ""
		putCommand "verbose _$name" "nameof" 
		set name $nameof
	    }
	    set detail "Name: $name" 
	}
	"#1" { set detail [lindex $vals 0]
	    if {$detail!=""} { set detail "Value: $detail" }
	}
	"#2" { set detail [lindex $vals 1]
	    if {$detail!=""} { set detail "Type: $detail" }
	}
	default { }
    }
    showStatus $detail
}

proc newData {n} {
    global data title debuggee fp
    toplevel .main$n
    set ntop .main$n
    grid [ttk::frame $ntop.bg -padding $fp] -column 0 -row 0 -stick nsew
    ttk::combobox $ntop.bg.stack -width 50 -height 20
    grid $ntop.bg.stack -column 0 -row 0 -sticky we
    bind $ntop.bg.stack <<ComboboxSelected>> \
	{ doExtraStack ; %W selection clear }
    grid [ttk::frame $ntop.bg.data] -column 0 -row 1 -sticky nswe
    set frame $ntop.bg.data
    grid [ttk::separator $ntop.bg.space -orient horizontal] \
        -column 0 -row 2 -sticky we
    grid [ttk::frame $ntop.bg.action] -column 0 -row 3
    ttk::button $ntop.bg.action.sync -text "Update" \
	-command { syncData [dict get $data vars] ; activateUpdated 1 }
    grid $ntop.bg.action.sync -column 0 -row 0 
    ttk::button $ntop.bg.action.close -text "Close"
    grid $ntop.bg.action.close -column 1 -row 0
    bind $ntop.bg.action.close <1> { closeData %W }
    wm title $ntop "$title $debuggee - Data $n" 
    set d [fillData $n $ntop.bg.data $ntop.bg.stack]
    grid columnconfigure $ntop.bg all -weight 1
    grid rowconfigure $ntop.bg 1 -weight 1
    grid columnconfigure $ntop all -weight 1
    grid rowconfigure $ntop all -weight 1
    showAlias 
    syncData $ntop
}

proc closeData {w} {
    global data dataSet data0
    set data $data0
    set w [winfo toplevel $w]
    set rid {}
    dict for {id d} $dataSet {
	dict with d {
	    if {$top==$w} {
		set rid $id
		break
	    }
	}
    }
    if {$rid!={}} { set dataSet [dict remove $dataSet $rid] }
    after idle { destroy $w } 
}

proc showLogfile {} {
    global title debuggee
    wm title .log "$title $debuggee - Log info"
    wm transient .log 
    wm deiconify .log
}

proc showSystem {} {
    global infoSystem title debuggee
    if {$infoSystem==""} {
	set infoSystem ""
	putCommand "info system" "isystem"
    }
    tk_messageBox -title "$title $debuggee - System info" -type ok \
	-message $infoSystem 
}

proc showHelpText {} {
    global title debuggee gobo
    set sep [file separator]
    set text "Sorry, online help is not yet implemented, please read:\n"
    append text "$gobo$sep"
    append text "doc$sep"
    append text "debugger$sep"
    append text "debug.pdf"
    tk_messageBox -icon info -type ok -title "$title $debuggee - Help" \
	-message $text 
}

set hc 0
proc doQuit {} {
    global sys running process io
    if {$running} { catch {exec kill -s INT $process} }
    if {$sys!=""} { putCommand "quit" 0 }
    if {$io!=""} { close $io }
    exit
}

##################################

set executableFiles {
    {"Executable files" "" }
    {"Executable files" ".exe" }
    {"All files" "*" }
}

set storeFiles {
    {"Store files" ".edg" }
    {"All files"   "*" }
}

proc initVariables {} {
    set breakDef {}
    set actClass {}
    set classes {}
    set actClass {}
    set posList {}
    set likeList {}
    set names {}
    set firstFound ""
    set lastFound ""
    set forward 1
    set nocase 0
    set calls ""
    set stopReason ""
    set nameof ""
    set infoSystem ""
    set running false
    set atend false
    set awaited 0
    set lastCommand ""
    set skip 0
    set markList ""
    set markable 0
    set universeList [list]
    set types ""
    set creates [list {}]
    set editable 0
    set needBreaks 0
    set insource 0
    set fastforward 0
    set searching 0
    set oldPattern ""
    set searchPattern ""
    set dataCount 0
    set dataSet {}
    set printQueue {}
    set aliasidx 0
    set aliasmode 1
}

### Window construction
wm resizable . 1 1
wm title . "$title <no executable loaded>"

menu .menubar 
. configure -menu .menubar 

menu .menubar.file -tearoff 0
.menubar add cascade -menu .menubar.file -label "File"
.menubar.file add command -label "Load executable" -command {
    set sys [tk_getOpenFile] 
    if {$sys!=""} { 
         initVariables
         startup $sys 
    }
}
.menubar.file add separator 
.menubar.file add command -label "Save settings" -command {
    set fn [tk_getSaveFile \
		-initialdir $directory \
		-initialfile "$debuggee.edg" \
		-filetypes $storeFiles] 
    putCommand "> \"$fn\"" "other"
}
.menubar.file add command -label "Restore settings" -command {
    set fn [tk_getOpenFile \
		-initialdir $directory \
		-initialfile "$debuggee.edg" \
		-filetypes $storeFiles] 
    putCommand "< \"$fn\"" "other"
    putBreakCommand "" ""
}
.menubar.file add separator 
.menubar.file add command -label "Quit" -accelerator <C-q> \
    -command { doQuit }

.menubar add cascade -menu [menu .window -tearoff 0] -label "Window"
.window add command -label "Log info" -accelerator <C-l> \
    -command { showLogfile }
.window add command -label "New data window" -accelerator <C-n> \
    -command { incr dataCount ; newData $dataCount }
.window add command -label "Edit aliases" -accelerator <C-a> \
    -command { showEditAlias }
.menubar add cascade -menu [menu .help -tearoff 0] -label "Help"
.help add command -label "System" -command { showSystem }
.help add command -label "On .." -command { showHelpText }
bind . <Control-l> { showLogfile }
bind . <Control-n> { incr dataCount ; newData $dataCount }
bind . <Control-a> { showEditAlias }
bind . <Control-q> { doQuit }

ttk::panedwindow .main -orient horizontal 
grid .main -column 0 -row 0 -columnspan 2 -sticky nwes -padx 6 -pady 6
grid rowconfigure    . 0 -weight 1
grid columnconfigure . 0 -weight 1

set status ""
grid [ttk::entry .status -textvariable status -state readonly] \
    -column 0 -row 1 -columnspan 3 -sticky we
grid [ttk::sizegrip .resize] -column 1 -row 1 -sticky se

ttk::frame .main.left 
grid .main.left -column 0 -row 0
.main add .main.left
ttk::notebook .main.left.rbe 
grid .main.left.rbe -column 0 -row 0 -sticky we

# Stop and go:
ttk::frame .main.left.rbe.re
set runbp .main.left.rbe.re
.main.left.rbe add $runbp -text "Run & Breakpoints"

ttk::frame $runbp.run -padding $fp 
#-text "Run" 
grid $runbp.run -column 0 -row 0 -sticky we
bind $runbp.run <Motion> { showReason }
ttk::button $runbp.run.cont -text "Cont\n   <F5>" -command { doGo "cont" } 
bind . <F5> { $cont invoke }
set cont $runbp.run.cont
ttk::button $runbp.run.next -text "Next\n   <F6>" -command { doGo "next" }
set next $runbp.run.next
bind . <F6> { $next invoke }
ttk::button $runbp.run.step -text "Step\n   <F7>" -command { doGo "step" }
set step $runbp.run.step
bind . <F7> { $step invoke }
ttk::button $runbp.run.off -text "Off\n   <F8>" -command { doGo "off" }
set off $runbp.run.off
bind . <F8> { $off invoke }
ttk::button $runbp.run.end -text "End\n   <F9>" -command { doGo "end" }
set end $runbp.run.end
bind . <F9> { $end invoke }
ttk::button $runbp.run.finish -text "Finish\n   <F10>" -command { doGo "finish" }
set finish $runbp.run.finish
bind . <F10> { $finish invoke }
ttk::button $runbp.run.stop -text "Stop\n   <Esc>" -command { doStop } 
set stop $runbp.run.stop
bind . <Escape> { doStop }
ttk::frame $runbp.run.mc
ttk::spinbox $runbp.run.mc.mode -textvariable runmode -width 6 \
    -values [list "break" "trace" "silent"] -wrap true -state readonly
$runbp.run.mc.mode set "break"
ttk::spinbox $runbp.run.mc.count -textvariable runcount -width 6 \
    -from 1 -to 999 -increment 1
$runbp.run.mc.count set 1
grid $cont -column 0 -row 0 -sticky w
grid $next -column 1 -row 0 -sticky w
grid $step -column 2 -row 0 -sticky w
grid $off -column 3 -row 0 -sticky w
grid $end -column 4 -row 0 -sticky w
grid $finish -column 5 -row 0 -sticky w
grid $runbp.run.mc -column 6 -row 0 -sticky w
grid $runbp.run.mc.mode -column 0 -row 0
grid $runbp.run.mc.count -column 0 -row 1 
grid $stop -column 7 -row 0 -sticky e

set markList ""
set markable 0

ttk::button $runbp.run.mark -text "Mark" -command { doMark } 
set mark $runbp.run.mark
grid $mark -column 0 -row 1 -sticky w
grid [ttk::label $runbp.run.resetlabel -text " Reset: "] -column 1 -row 1 -sticky e
ttk::combobox $runbp.run.reset -height 20 -state readonly
set marks $runbp.run.reset
bind $runbp.run.reset <<ComboboxSelected>> \
    { doReset [$marks get] ; %W selection clear } 
grid $marks -column 2 -columnspan 6 -row 1 -sticky we
grid columnconfigure $runbp.run [list 0 1 2 3 4 5 7] -uniform do -weight 1 -pad 3
grid rowconfigure $runbp.run all -pad 10

# Universe 

set universeList [list]

proc selectTypes {combo pattern} {
    global universeList 
    global errorCode errorInfo errorDetail
    set universeList [lreplace $universeList 0 end]
    regsub -all {\[} $pattern {\\[} tp0
    regsub -all {\\\\} $tp0 {\\} tp1
    set errorCode 0
    catch {regexp $tp1 ""} 
	if {$errorCode!=0} {
	set errorInfo "Bad regular expression:"
	set errorDetail $tp1
	showError 
	return
    }
    putCommand "universe $tp1" "universe" 
    $combo configure -values $universeList
}

# Breakpoints

set types ""
set creates [list {}]

proc breakItems {breaks bl} {
    set l ""
    foreach i $bl {
	set val [lindex [$breaks item $i -values] 0]
	if {$val!="new"} {
	    if {$l!=""} { set l "$l, " }
	    set l "$l $val"
	}
    }
    return $l
}

set editable 0

proc breakClear {init} {
    global breaks breakDef bnew source
    if {!$init} {
        $breaks delete [$breaks children {}]
        $breaks insert {} 0 -values $bnew
        $source tag remove breaktag 1.0 end 
    }
    set breakDef [concat $bnew]
}

proc putBreakCommand {bl act} {
    global breaks bnew source
    if {$act=="edit" } {
	putCommand "break $bl" "other"
    } else {
	set items [breakItems $breaks $bl]
	if {[llength $items]>0} {
	    switch $act {
		"enable" { putCommand "+ $items" "other" }
		"disable" { putCommand "- $items" "other" }
		"kill" { putCommand "kill $items" "other" }
		default {}
	    }
	}
    }
    breakClear 0
    putCommand "info break" "ibreak"
}

proc statusBreak {item kind} {
    global breaks
    set vals [$breaks item $item -values]
    set detail ""
    switch $kind {
	"#3" { set detail [lindex $vals 2]
	    if {$detail!=""} { set detail "at: $detail" }
	}
	"#6" { set detail [lindex $vals 5]
	    if {$detail!=""} { 
		set detail "watch: $detail , value = [lindex $vals 10]" }
	}
	"#7" { set detail [lindex $vals 6]
	    if {$detail!=""} { set detail "type: $detail" }
	}
	"#8" { set detail [lindex $vals 7]
	    if {$detail!=""} { set detail "if: $detail" }
	}
	"#9" { set detail [lindex $vals 8]
	    if {$detail!=""} { set detail "print: $detail" }
	}
	default { }
    }
    showStatus $detail
}

proc editBreak {} {
    global edit breaks bitem types editable
    global bcatch bat bdepth bpp bwatch btype bif bprint bcont
    global vwatch source runbp
    set vals [$breaks item $bitem -values]
    set bn [lindex $vals 0]
    $bcatch set [lindex $vals 1]
    set bat [lindex $vals 2]
    if {$bat!=""} { 
	set pos [split $bat ":"]
	showSource [lindex $pos 0]
	clearBreak $bat -1 
    }
    set bdepth [lindex $vals 3]
    if {$bdepth==""} { 
	set bdepth 0
	set bpp 0
    } else {
	if {[lindex $vals 4]==""} { 
	    set bpp 0
	} else {
	    set bpp 1
	}
    }
    set w [lindex $vals 5]
    if {$w!=""} {
	set vwatch $w
    } else {
	set vwatch ""
    }
    set val [lindex $vals 6]
    $btype configure -values $types
    $btype set $val 
    set bif [lindex $vals 7]
    set bprint [lindex $vals 8]
    if {[lindex $vals 9]==""} {
	set bcont 0
    } else {
	set bcont 1
    }
    set editable 1
    highlightPos 1
    if {$bn=="new"} {
        set title "New breakpoint"
    } else {
        set title "Breakpoint $bn"
    }
    .main.left.rbe.edit.cond.label configure -text $title
    .main.left.rbe hide $runbp
}

proc storeBreak {} {
    global breaks bitem editable
    global bcatch bat bdepth bpp bwatch btype bif bprint bcont vwatch
    set vals [$breaks item $bitem -values]
    set bn [lindex $vals 0]
    if {$bn=="new"} { set bn "" } 
    set vals [list $bn [$bcatch get] $bat $bdepth $bpp \
		  $vwatch [$btype get] $bif $bprint $bcont]
    for {set i 1} {$i<10} {incr i} {
	set val [lindex $vals $i]
	if {$val=="" || $val==0} { lset vals $i "--" }
    }
    set cond ""
    set cond "$cond catch [lindex $vals 1]"
    set at [lindex $vals 2]
    if {$at!={}} {
	set cond "$cond at $at" 
	clearBreak $at 1
    }
    set val [lindex $vals 3]
    set cond "$cond depth $val"
    if {$val!="--" && [lindex $vals 4]!="--"} {  set cond "$cond ++" }
    if {$vwatch==""} {
        set cond "$cond watch --"
    } elseif {[string first "0x" $vwatch]<0} {
	set cond "$cond watch $vwatch"
    }
    set cond "$cond type [lindex $vals 6]"
    set cond "$cond if [lindex $vals 7]"
    set cond "$cond print [lindex $vals 8]"
    set cond "$cond cont"
    if {[lindex $vals 9]=="--"} { set cond "$cond --" }
    putBreakCommand "$bn $cond" "edit"
    set editable 0
    highlightPos 0
}

proc restoreBreak {} {
    global breaks bitem bat source editable
    set vals [$breaks item $bitem -values]
    set at [lindex $vals 2]
    if {$at!={}} { clearBreak $at 1 }
    set editable 0
    highlightPos 0
}

proc setBreakAt {} {
    global bat source actClass posList
    if {$bat!={}} { clearBreak $bat 0 }
    set pos [$source index current]
    set r [split $pos "."]
    set l [lindex $r 0]
    set c [expr [lindex $r 1] +1]
    set p0 0
    set p1 [expr 256*$l+$c]
    foreach p $posList {
	if {$p0<$p && $p<=$p1} { set p0 $p }
    }
    set l [expr $p0/256]
    set c [expr $p0%256]
    set bat "[dict get $actClass name]:$l:$c" 
    incr c -1
    $source tag add newbreaktag "$l.$c"
}

proc clearBreak {at accept} {
    global source actClass
    set pos [split $at ":"]
    if {[dict get $actClass name]==[lindex $pos 0]} {
	set pos "[lindex $pos 1].[expr [lindex $pos 2] -1]"
	set pos [$source index $pos] 
	$source tag remove breaktag $pos
	$source tag remove newbreaktag $pos
	if {$accept<0} {
	    $source tag add newbreaktag $pos 
	} elseif {$accept>0} {
	    $source tag add breaktag $pos
	}
    }
}

proc selectBreak {n} {
    global breaks
    foreach b [$breaks children {}] {
	set vals [$breaks item $b -values]
	if {[lindex $vals 0]==$n} {
	    $breaks selection set $b
	    break
	}
    }
}

grid [ttk::separator $runbp.sep -orient horizontal] -column 0 -row 1 -sticky we
ttk::frame $runbp.break -padding $fp 
grid $runbp.break -column 0 -row 2 -sticky we
grid [ttk::frame $runbp.break.scrolled -padding 2] \
    -column 0 -row 0 -sticky nesw
grid $runbp.break.scrolled -column 0 -row 0 -sticky nswe
grid [ttk::scrollbar $runbp.break.scrolled.y -orient vertical] \
    -column 1 -row 0 -sticky ns
ttk::treeview $runbp.break.scrolled.list -show headings -height $breakH \
    -columns "number catch at depth ++ watch type if print cont" \
    -yscrollcommand {.main.left.rbe.re.break.scrolled.y set} -selectmode extended
set breaks $runbp.break.scrolled.list
grid $breaks -column 0 -row 0 -sticky nesw
$runbp.break.scrolled.y configure -command { $breaks yview }
grid columnconfigure $runbp.break.scrolled 0 -weight 100
grid columnconfigure $runbp.break all -weight 1
grid rowconfigure $runbp.break all -weight 1

$breaks heading \#1 
$breaks column \#1 -width 30 -minwidth 20 -anchor e 
$breaks heading \#2 -text catch
$breaks column \#2 -width 50 -minwidth 20 -anchor w
$breaks heading \#3 -text at
$breaks column \#3 -width 120 -minwidth 30 -anchor w -stretch 1 
$breaks heading \#4 -text depth
$breaks column \#4 -width 40 -minwidth 20 -anchor e
$breaks heading \#5 
$breaks column \#5 -width 20 -minwidth 20 -anchor e
$breaks heading \#6 -text watch
$breaks column \#6 -width 60 -minwidth 20 -anchor e
$breaks heading \#7 -text type
$breaks column \#7 -width 80 -minwidth 20 -anchor w -stretch 1
$breaks heading \#8 -text if
$breaks column \#8 -width 100 -minwidth 20 -anchor w -stretch 1
$breaks heading \#9 -text print
$breaks column \#9 -width 100 -minwidth 20 -anchor w -stretch 1
$breaks heading \#10 -text cont
$breaks column \#10 -width 40 -minwidth 10 -anchor e
set bnew [list "new" "" "" "" "" "" "" "" "" "" ""]
set breakDef {}
breakClear 1
$breaks insert {} 0 -values $breakDef
bind $breaks <Motion> { set item [$breaks identify item %x %y]
    statusBreak $item [$breaks identify column %x %y] 
}
bind $breaks <Leave> { showStatus "" }
set bitem "new"
bind .main.left.rbe <<NotebookTabChanged>> { 
    if {[.main.left.rbe select]==".main.left.rbe.edit"} {
        set bitem [$breaks selection] ; editBreak 
    }
}
$breaks tag configure disabletag -background lightgrey

ttk::frame $runbp.break.action 
grid $runbp.break.action -column 0 -row 1 -sticky nswe 
ttk::button $runbp.break.action.enable -text "enable" \
    -command { putBreakCommand [$breaks selection] "enable" }
ttk::button $runbp.break.action.disable -text "disable" \
    -command { putBreakCommand [$breaks selection] "disable" }
ttk::button $runbp.break.action.kill -text "kill" \
    -command { putBreakCommand [$breaks selection] "kill" }
set bdebug 1
ttk::checkbutton $runbp.break.action.debug -text "enable debug clauses" \
    -variable bdebug -command { 
	if {$bdebug} {
	    set s "+"
	} else {
	    set s "-"
	}
	putCommand "$s debug" "other"
}
grid $runbp.break.action.enable -column 0 -row 1
grid $runbp.break.action.disable -column 1 -row 1 
grid $runbp.break.action.kill -column 2 -row 1 
grid $runbp.break.action.debug -column 3 -row 1 -padx 5
grid columnconfigure $runbp.break.action [list 0 1 2] -uniform brk -pad 3
grid columnconfigure $runbp all -weight 1
grid rowconfigure $runbp all -weight 1 -pad 3

dict set catches void "call on void target" 
dict set catches memory "no more memory" 
dict set catches failure "routine failure" 
dict set catches catcall "catcall" 
dict set catches developer "routine \`raise\' called" 
dict set catches all "any exception"  

set needBreaks 0

# Edit breakpoint 
ttk::frame .main.left.rbe.edit
set edit .main.left.rbe.edit
grid $edit -column 0 -row 0 -sticky we
.main.left.rbe add $edit -text "Edit breakpoint"
grid [ttk::frame $edit.cond -padding $fp] -column 0 -row 0 -sticky we
grid [ttk::label $edit.cond.label -text ""] -column 0 -row 0 -sticky w
grid [ttk::label $edit.cond.catchlabel -text "catch"] \
    -column 0 -row 1 -sticky w
ttk::combobox $edit.cond.catch -width 8 -state readonly \
    -values [list "" "void" "memory" "failure" "when" "catcall" "developer" "all"]
set bcatch $edit.cond.catch
$bcatch set ""
grid $bcatch -column 1 -row 1 -sticky w
grid [ttk::label $edit.cond.atlabel -text "at"] \
    -column 0 -row 2 -sticky w
ttk::entry $edit.cond.pos -textvariable bat -state readonly
grid  $edit.cond.pos -column 1 -row 2 -columnspan 4 -sticky we
ttk::button $edit.cond.atclear -text "clear" -command { set bat "" }
grid $edit.cond.atclear -column 5 -row 2 -sticky e
grid [ttk::label $edit.cond.depthlabel -text "depth"] \
    -column 0 -row 3 -sticky w
ttk::spinbox $edit.cond.depth -from 0 -to 999 -width 8 -textvariable bdepth
grid $edit.cond.depth -column 1 -row 3 -sticky w
set bdepth 0
ttk::checkbutton $edit.cond.depthpp -text "" -variable bpp -text "++"
grid $edit.cond.depthpp -column 2 -row 3 -sticky w
grid [ttk::label $edit.cond.watchlabel -text "watch"] \
    -column 0 -row 4 -sticky w
set vwatch ""
ttk::entry $edit.cond.watch -textvariable vwatch -state readonly 
grid $edit.cond.watch -column 1 -row 4 -columnspan 2 -sticky we 
grid [ttk::label $edit.cond.space1 -text "   "] -column 3 -row 4
ttk::button $edit.cond.data -text "from data" \
    -command { set vars [dict get $data0 vars]
        set vwatch [$vars item [$vars selection] -text]
    }
grid $edit.cond.data -column 4 -row 4 -sticky w
ttk::button $edit.cond.watchclear -text "clear" \
    -command { set vwatch "" }
grid $edit.cond.watchclear -column 5 -row 4 -sticky w
grid [ttk::label $edit.cond.typelabel -text "type"] \
    -column 0 -row 5 -sticky w
ttk::combobox $edit.cond.type  -textvariable breaktypes \
    -postcommand { selectTypes $edit.cond.type $breaktypes }
set btype $edit.cond.type
$btype set ""
bind $btype <<ComboboxSelected>> { %W selection clear }
grid $btype -column 1 -row 5 -columnspan 5 -sticky we
grid [ttk::label $edit.cond.iflabel -text "if"] \
    -column 0 -row 6 -sticky we
set bif ""
ttk::entry $edit.cond.if -textvariable bif
grid $edit.cond.if -column 1 -row 6 -columnspan 5 -sticky we
grid [ttk::label $edit.cond.printlabel -text "print "] \
    -column 0 -row 7 -sticky we
set bprint ""
ttk::entry $edit.cond.print -textvariable bprint
grid $edit.cond.print -column 1 -row 7 -columnspan 5 -sticky we
grid [ttk::label $edit.cond.contlabel -text "cont"] \
    -column 0 -row 8 -sticky we
ttk::checkbutton $edit.cond.cont -text "" -variable bcont
grid $edit.cond.cont -column 1 -row 8 -sticky we
grid rowconfigure $edit.cond all -uniform be 
grid [ttk::frame $edit.action -padding $fp] -column 0 -row 1
ttk::button $edit.action.ok -text "OK" -command {
    storeBreak 
    after idle { .main.left.rbe add $runbp ; .main.left.rbe select $runbp }
}
grid $edit.action.ok -column 0 -row 1 -sticky e
ttk::button $edit.action.cancel -text "Cancel" -command { 
    restoreBreak 
    after idle { .main.left.rbe add $runbp ; .main.left.rbe select $runbp }
}
grid $edit.action.cancel -column 1 -row 1 -sticky w
grid columnconfigure $edit.cond [list 4 5] -uniform bw
grid columnconfigure $edit.cond 2 -weight 1
#grid rowconfigure $edit.cond all -uniform cond 
grid columnconfigure $edit all -weight 1 
grid columnconfigure .main.left.rbe all -weight 1 -pad 2
lower $edit

#Source: 
ttk::labelframe .main.left.source -text "Source" -padding $fp 
grid .main.left.source -column 0 -row 1 -sticky nswe

ttk::frame .main.left.source.class
grid .main.left.source.class -column 0 -row 0 -sticky we
ttk::label .main.left.source.class.label -text "Class  " 
ttk::combobox .main.left.source.class.name -state readonly 
set classField .main.left.source.class.name
bind $classField <<ComboboxSelected>> {
     showSource [lindex [$classField cget -values] [$classField current]]
    %W selection clear } 
grid .main.left.source.class.label -column 0 -row 0 -sticky w
grid .main.left.source.class.name -column 1 -row 0 -sticky we
grid columnconfigure .main.left.source.class 1 -weight 100 -pad 3

proc vertSource {scroll y0 y1} {
    global source lines actClass
    $scroll set $y0 $y1
    if {$actClass!={}} {
	set len [dict get $actClass len]
	if {$len==0} { dict set actClass len [$source count -lines 1.0 end] }
        $lines yview moveto $y0
    }
}

set fam "Inconsolata"
if {[lsearch [font families] $fam] <0} { set fam "Courier"} 
font create fixedF -family $fam -size -14 -weight normal -slant roman
font create boldF -family $fam -size -14 -weight bold -slant roman 
set fixed fixedF
set bold boldF

ttk::frame .main.left.source.scrolled 
grid .main.left.source.scrolled -column 0 -row 1 -sticky nesw
ttk::frame .main.left.source.scrolled.both 
grid .main.left.source.scrolled.both -column 0 -row 0 -sticky nesw
text .main.left.source.scrolled.both.lines -width 6 -wrap none \
    -background \#d9d9d9 -foreground black \
    -font $fixed -state disabled
set lines .main.left.source.scrolled.both.lines
grid $lines -column 0 -row 0 -sticky nsw
text .main.left.source.scrolled.both.text -width 80 -height $sourceH -wrap none \
    -tabs "[expr {3 * [font measure $fixed 0]}] left" -tabstyle wordprocessor \
    -yscrollcommand  "vertSource .main.left.source.scrolled.y" \
    -xscrollcommand ".main.left.source.scrolled.x set" \
    -background white -font $fixed -state disabled
set source .main.left.source.scrolled.both.text
grid $source -column 1 -row 0 -sticky nesw
grid [ttk::scrollbar .main.left.source.scrolled.y -orient vertical \
	  -command "$source yview" ] \
    -column 1 -row 0 -sticky ns
grid [ttk::scrollbar .main.left.source.scrolled.x -orient horizontal \
	  -command {$source xview} ] \
    -column 0 -row 1 -sticky we

bind $source <Enter> { set insource 1 }
bind $source <Motion> { 
    set idx [$source index @%x,%y]
    showAt "Cursor at" "$idx"
    highlightFeature $idx
}
bind $source <Leave> { 
    showStatus "" 
    set insource 0 
    terminateFastSearch 
}
bind .main.left.source <Enter> { setActClass [$classField get] }
$source tag configure breaktag -background red
$source tag configure newbreaktag -background \#ff9393
$source tag configure actualtag -background \#66FF00
$source tag configure featuretag -background lightgrey
$source tag configure rowtag -background \#e0ffc4
$source tag configure postag -underline 1 
$source tag bind postag <1> { if {$editable} {setBreakAt} } 
$source tag configure foundtag -background black -foreground white
$source tag configure stringtag -foreground forestgreen
$source tag configure commenttag -foreground grey
$source tag configure keywordtag -font $bold
$source tag lower breaktag newbreaktag
$source tag lower actualtag breaktag
$source tag lower featuretag actualtag
$source tag lower rowtag featuretag
$source tag lower stringtag foundtag
$source tag lower commenttag foundtag

set featureStart [$source index 1.0]
set featureEnd [$source index 1.0]

set keywords [list "agent" "alias" "all" "and" "as" "assign" "attached" ]
lappend keywords "attribute" "check" "class" "convert" "create" "debug"
lappend keywords "deferred" "detachable" "do" "else" "elseif" "end" "ensure" 
lappend keywords "expanded" "export" "external" "feature" "from" "frozen"
lappend keywords "if" "implies" "inherit" "inspect" "invariant" "like"
lappend keywords "local" "loop" "not" "note" "obsolete" "old" "once" "only"
lappend keywords "or" "redefine" "rename" "require" "rescue"
lappend keywords "retry" "select" "separate" "then"
lappend keywords "undefine" "until" "variant" "when" "xor" 
#lappend keywords "Current" "False" "Precursor" "Result" "True" "TUPLE" "Void"

ttk::frame .main.left.source.search -padding $fp
grid .main.left.source.search -column 0 -row 2 -sticky we
ttk::label .main.left.source.search.label -text "Search " 
ttk::entry .main.left.source.search.pattern \
    -textvariable searchPattern
bind .main.left.source.search.pattern <KeyPress-Return> {
    set searchIndex [$source index insert]
    searchSource $searchPattern 0
    if {$firstFound!=""} {
	showAt "Found at " $firstFound 
	$source mark set insert $searchIndex
    } else {
	showStatus "Not found"
    } 
} 
bind .main.left.source.search.pattern <Leave> { showStatus "" }

ttk::checkbutton .main.left.source.search.forward -text "forward" \
    -variable forward
bind .main.left.source.search.forward <1> \
    { if {$firstFound!=""} { 
	if {$forward} { $source mark set insert $firstFound }
	$source tag remove foundtag $firstFound $lastFound ; set FirstFound ""}
} 
ttk::checkbutton .main.left.source.search.nocase -text "no case" \
    -variable nocase
grid .main.left.source.search.label -column 0 -row 0 -sticky w
grid .main.left.source.search.pattern -column 1 -row 0 -sticky we 
grid .main.left.source.search.forward -column 2 -row 0 -sticky e
grid .main.left.source.search.nocase -column 3 -row 0 -sticky e
grid columnconfigure .main.left.source.search all -pad 5
grid columnconfigure .main.left.source.search 1 -weight 1
grid rowconfigure .main.left.source.scrolled.both 0 -weight 1 
grid columnconfigure .main.left.source.scrolled.both 1 -weight 1 
grid rowconfigure .main.left.source.scrolled 0 -weight 1 
grid columnconfigure .main.left.source.scrolled 0 -weight 1 
grid rowconfigure .main.left.source 1 -weight 1 
grid rowconfigure .main.left.source all -pad 1
grid columnconfigure .main.left.source all -weight 1 -pad 3
grid columnconfigure .main.left all -weight 1 
grid rowconfigure .main.left 1 -weight 1 

ttk::panedwindow .main.right -orient vertical 
.main add .main.right 

set textIndex "1.0"
menu .likemenu -tearoff 0
set likeMenu .likemenu

bind $source <3> { if {$running} { return } 
    set textIndex [$source index @%x,%y ] 
    showLikeMenu $textIndex
    tk_popup $likeMenu %X %Y 
}

toplevel .ftext
wm withdraw .ftext
ttk::frame .ftext.class -padding $fp
grid .ftext.class -column 0 -row 0 -sticky we
ttk::label .ftext.class.label -text "Class " 
grid .ftext.class.label -column 0 -row 0 -sticky w
ttk::label .ftext.class.name  
grid .ftext.class.name -column 1 -row 0 -sticky w
ttk::frame .ftext.text -padding $fp
grid .ftext.text -column 0 -row 1 -sticky nesw
text .ftext.text.text -width 80 -height $sourceH -wrap none \
    -tabs "[expr {3 * [font measure $fixed 0]}] left" -tabstyle wordprocessor \
    -yscrollcommand ".ftext.text.scrolly set" \
    -xscrollcommand ".ftext.text.scrollx set" \
    -background white -font $fixed -state disabled
set liketext .ftext.text.text
grid $liketext -column 0 -row 0 -sticky nesw
grid [ttk::scrollbar .ftext.text.scrolly -orient vertical \
	  -command {$liketext yview} ] \
    -column 1 -row 0 -sticky ns
grid [ttk::scrollbar .ftext.text.scrollx -orient horizontal \
	  -command {$liketext xview} ] \
    -column 0 -row 1 -sticky we
$liketext tag configure foundtag -background black -foreground white

ttk::separator .ftext.space -orient horizontal
grid .ftext.space -column 0 -row 2 -sticky we
grid [ttk::frame .ftext.buttons -padding $fp] -column 0 -row 3 
ttk::button .ftext.buttons.close -text "Close" \
    -command { wm withdraw .ftext }
grid .ftext.buttons.close -column 0 -row 0
ttk::button .ftext.buttons.tosource -text "To Source" -command { toSource }
grid .ftext.buttons.tosource -column 1 -row 0
grid columnconfigure .ftext.text 0 -weight 1 -pad $fp
grid rowconfigure .ftext.text 0 -weight 1 -pad $fp
grid columnconfigure .ftext 0 -weight 1 -pad $fp
grid rowconfigure .ftext 0 -weight 1 -pad $fp

#Stack:

set instack ""
if {[winfo exists .main0]} {
    ttk::labelframe .main0.stack -text "Stack" -padding $fp
    set stackframe .main0.stack
    grid .main0.stack -column 0 -row 0 -sticky nesw
} else {
    ttk::labelframe .main.right.stack -text "Stack" -padding $fp
    set stackframe .main.right.stack
    .main.right add $stackframe 
}

grid [ttk::frame $stackframe.scrolled -padding 2] \
    -column 0 -row 0 -sticky nesw
ttk::treeview $stackframe.scrolled.list -height $stackH -show headings \
    -yscrollcommand "$stackframe.scrolled.y set" -selectmode browse \
    -columns "level class routine row col" 
set stack $stackframe.scrolled.list
grid $stack -column 0 -row 0 -sticky nesw
grid [ttk::scrollbar $stackframe.scrolled.y \
	  -command "$stack yview" -orient vertical] \
    -column 1 -row 0 -sticky ns
grid columnconfigure $stackframe.scrolled 0 -weight 1
grid rowconfigure $stackframe.scrolled 0 -weight 1
grid columnconfigure $stackframe all -weight 1
grid rowconfigure $stackframe all -weight 1
$stack heading \#1 
$stack column \#1 -width 40 -minwidth 10 -anchor e
$stack heading \#2 -text "Class"
$stack column \#2 -width 120 -minwidth 60 -anchor w -stretch 1
$stack heading \#3 -text "Routine"
$stack column \#3 -width 170 -minwidth 80 -anchor w -stretch 1
$stack heading \#4 -text "Line"
$stack column \#4 -width 45 -minwidth 10 -anchor e
$stack heading \#5 -text "Col"
$stack column \#5 -width 25 -minwidth 10 -anchor e
bind $stack <1> { doStack [$stack identify item %x %y] 0 }
bind $stack <Motion> { set item [$stack identify item %x %y]
    statusStack $item [$stack identify column %x %y]
}
bind $stack <Leave> { showStatus "" }

proc sourcePos {rootx rooty colon} {
    global source
    set x [expr $rootx-[winfo rootx $source]]
    set y [expr $rooty-[winfo rooty $source]]
    set xy [split [$source index @$x,$y] "."]    
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    if {$colon} { 
        return "$x:[expr $y+1]" 
    }
    return "$x.$y"
}

bind . <Control-period> { if {$insource && !$running} { doStack [$stack selection] 0 } }
bind . <Control-g> { if {$insource && !$running} { 
        set pos [$source index "1.0"]
        $source see $pos
    } 
}
bind . <Control-d> { if {$insource && !$running} { 
        set pos [sourcePos %X %Y 0]
        showLike $pos 
    } 
}
bind . <Control-p> { if {$insource && !$running} {  
        set pos [sourcePos %X %Y 0]
        printLike $pos 
    } 
}
bind . <Control-b> { if {$insource && !$running} { 
        set cls [dict get $actClass name]
        set pos [sourcePos %X %Y 1]
        putBreakCommand "at $cls:$pos" "edit" 
    } 
}
bind . <Control-k> { if {$insource && !$running} { 
        set pos [sourcePos %X %Y 1]
        set cls [dict get $actClass name]
        set pos $cls:$pos
        foreach b [$breaks children {}] {
            set vals [$breaks item $b -values]
            set at [lindex $vals 2]
            if {$at==$pos} {
                putBreakCommand "$b" "kill" 
                return
            }
        }
    } 
}

# Fast searching

set insource 0
set fastforward 0
set searching 0
set oldPattern ""
set searchPattern ""

bind . <Control-s> { if {$insource} { initFastSearch [sourcePos %X %Y 0] 1} }
bind . <Control-r> { if {$insource} { initFastSearch [sourcePos %X %Y 0] 0} } 
bind . <Control-Key> { terminateFastSearch } 
bind . <BackSpace> {
    if {$searching && [string length $searchPattern]>0} {
	set searchPattern [string replace $searchPattern end end]
	if {[string length $searchPattern]==0} {
	    set searchIndex 0
	    set searchStart 0
	} else {
	    set forward [expr !$forward]
	    fastSearch 
	    set forward [expr !$forward]
	}
    }
} 
bind . <KeyPress-Shift_L> { set nocase 1 } 
bind . <KeyPress-Shift_R> { set nocase 1 } 
bind . <KeyPress-Shift_Lock> { set nocase 1 } 
bind . <KeyPress-Caps_Lock> { set nocase 1 } 
bind . <KeyPress> {
    if {!$searching} { return }
    if {"%N">=32 && "%N"<128} {
	append searchPattern "%A"
	fastSearch
    } else {
	terminateFastSearch 
    }
}

proc initFastSearch { xy f } {
    global source 
    global searchPattern oldPattern forward 
    global searching searchIndex searchStart
    set forward $f; 
    if {$searching} {
	set searchPattern $oldPattern	
	fastSearch
    } else {
	set searchStart $xy
	set searchIndex $searchStart
	set searching 1
    }
}

proc fastSearch {} {
    global source forward nocase searchPattern oldPattern 
    set nocase 1
    searchSource $searchPattern 1
    set oldPattern $searchPattern 
}

proc terminateFastSearch {} {
    global searchPattern searching insource
    set searching 0
    if {$insource} {
	set searchPattern ""
	clearFoundSource
    }
}

# Data:
set varname ""
set varcount 0
set vartop {}
set varstack [list $vartop]

set aliases {}
set ranges {}
set details {}

set argList [dict create]

proc fillData {id frame stack} {
    global stopData data dataSet
    global aliases aliasMenu
    global fp dataH 
    set topwindow [winfo toplevel $frame]
    dict set dataSet $id top $topwindow
    dict set dataSet $id stack $stack
    ttk::frame $frame.vars -padding 2
    grid $frame.vars -column 0 -row 0 -columnspan 2 -sticky nswe
    ttk::treeview $frame.vars.list -selectmode browse -height $dataH \
	-yscrollcommand "$frame.vars.y set" \
	-columns "value type" 
    set d $frame.vars.list
    dict set dataSet $id vars $d
    grid $d -column 0 -row 0 -sticky nesw
    grid [ttk::scrollbar $frame.vars.y \
	      -command "$d yview" -orient vertical] -column 1 -row 0 -sticky ns
    grid columnconfigure $frame.vars 0 -weight 1
    grid rowconfigure $frame.vars 0 -weight 1
    $d heading \#0 -text Name
    $d heading \#1 -text Value 
    $d heading \#2 -text Type
    $d column \#0 -width 180 -minwidth 120 -anchor w -stretch 1
    $d column \#1 -width 80 -minwidth 70 -anchor e
    $d column \#2 -width 140 -minwidth 90  -anchor w
    bind $d <1> { set vars [dict get $data vars]
	if {[$vars instate disabled]} {
	} else {
	    set item [$vars identify item %x %y]
	    if {$item!=""} {
		if {[llength [$vars children $item]]==0} {
		    $vars selection set $item
		    doPrint 1 1
		}
	    }
	} 
    }
    bind $d <3> { set vars [dict get $data vars]
        dict remove callname
	set item [$vars identify item %x %y]
	if {$item!=""} { showQueries $vars $item %X %Y }
    } 
    bind $d <Motion> { set vars [dict get $data vars]
	set item [dataItem $vars %x %y]
	statusData $vars $item [$vars identify column %x %y] 
    }
    
    ttk::frame $frame.expr -padding $fp
    grid $frame.expr -column 0 -row 1 -sticky we
    grid [ttk::label $frame.expr.aliaslabel -text "Alias "] \
	-column 0 -row 0 -sticky w
    ttk::combobox $frame.expr.alias -values $aliases -state readonly
    dict set dataSet $id alias $frame.expr.alias
    grid $frame.expr.alias -column 1 -row 0 -sticky we 

    ttk::label $frame.expr.label -text "Expr "
    grid $frame.expr.label -column 0 -row 1 -sticky w
    text $frame.expr.text -height 1 -width 60
    dict set dataSet $id expr $frame.expr.text
    grid $frame.expr.text -column 1 -row 1 -sticky we
    bind $frame.expr.text <Return> { set varcount 0 ;
        if {[checkExpr [dict get $data expr]]} { doPrint 0 1} }
    $frame.expr.text tag configure placeholdertag -foreground red
    grid columnconfigure $frame.expr 1 -weight 1
    grid rowconfigure $frame.expr all -pad 5

    grid [ttk::frame $frame.do -padding $fp] \
	-column 0 -row 2 -sticky w
    ttk::button $frame.do.print -text "Print"  \
	-command { set varcount 0 ; if {[checkExpr [dict get $data expr]]} {doPrint 0 1}}
    ttk::button $frame.do.closure -text "Closure" \
	-command { set varcount 0 ; if {[checkExpr [dict get $data expr]]} {doPrint 0 0} }
    ttk::checkbutton $frame.do.hex -text "hex " -width 5
    dict set dataSet $id hex $frame.do.hex
    grid $frame.do.print -column 0 -row 0 -sticky w
    grid $frame.do.closure -column 1 -row 0 -sticky w
    grid $frame.do.hex -column 2 -row 0 -sticky w
    if {$id} {
	ttk::button $frame.do.level -text "To Main"  \
	    -command { set expr [dict get $data expr]
		moveExpr [$expr get 1.0 end] $data
		$expr delete 1.0 end 
	    }
	grid $frame.do.level -column 3 -row 0 -sticky w
    } else {
	ttk::button $frame.do.assign -text "Assign" \
	    -command { set expr [dict get $data expr]
		if {[checkExpr [dict get $data expr]]} {putAssignCommand [$expr get 1.0 end]}
	    }
	grid $frame.do.assign -column 3 -row 0 -sticky w
    }
    grid columnconfigure $frame.do [list 0 1 3] -uniform fd -pad 3
    grid rowconfigure $frame 0 -weight 3
    grid rowconfigure $frame all -pad 5
    grid columnconfigure $frame all -weight 1

    bind $frame.expr.alias <<ComboboxSelected>> \
	{ aliasExpr $data ; %W selection clear }
    bind $topwindow <Enter> { 
	set w [winfo toplevel %W]
	dict for {id d} $dataSet {
	    dict with d { 
		if {$top==$w} {
		    if {$d==$data} { break }
		    set data $d
		    set st [dict get $data stack]
		    if {$d==$data0} {
			set vals [$st item [$st selection] -values]
			set level [lindex $vals 0]
		    } else {
			set level [$st current]
		    }
		    if {$level!=""} { putCommand ". $level" "other" }
		    break
		}
	    }
	}
    }
    return [dict get $dataSet $id]
}

proc dataFromComponent {comp} {
    global dataSet
    set t [winfo toplevel $comp]
    dict for {id d} $dataSet {
	if {[dict get $d top]==$t} { return $d }
    }
    rerurn {}
}

proc syncData {comp} {
    global calls data
    set data [dataFromComponent $comp]
    set st [dict get $data stack]
    set list {}
    foreach vals $calls {
	if {[llength $vals]==5} {
	    set line "[lindex $vals 0] [lindex $vals 1].[lindex $vals 2]:[lindex $vals 3]:[lindex $vals 4]"
	    lappend list $line
	}
    }
    $st configure -values $list
    if {[llength $list]>0} { $st set [lindex $list 0] }
    set expr [dict get $data expr]
    $expr delete 1.0 end
    putCommand ". 0" "other"
    doPrint 0 1 
}

set dataCount 0
set dataSet {}
set printQueue {}

if {[winfo exists .main0]} {
    ttk::labelframe .main0.data -text "Data" -padding $fp
    grid .main0.data -column 0 -row 1 -sticky nesw
    set data0 [fillData 0 .main0.data $stack]
    grid columnconfigure .main0 all -weight 1
    grid rowconfigure .main0 all -weight 1
} else {
    ttk::labelframe .main.right.data -text "Data" -padding $fp
    set data0 [fillData 0 .main.right.data $stack]
    .main.right add .main.right.data
    grid columnconfigure .main.right all -weight 1
    grid rowconfigure .main.right all -weight 1
}
set data $data0

menu .queryMenu -tearoff 0
.queryMenu add command -label "" -command { setExpr $data $item "" }

set queryMenu .queryMenu
set queries {}

menu .queryMenu.args -tearoff 0
.queryMenu add cascade -menu .queryMenu.args -label "Arguments"
dict set queryTopics args .queryMenu.args 
menu .queryMenu.locals -tearoff 0
.queryMenu add cascade -menu .queryMenu.locals -label "Local variables"
dict set queryTopics locals .queryMenu.locals
menu .queryMenu.olds -tearoff 0
.queryMenu add cascade -menu .queryMenu.olds -label "Old values"
dict set queryTopics olds .queryMenu.olds 
menu .queryMenu.tests -tearoff 0
.queryMenu add cascade -menu .queryMenu.tests -label "Object test locals"
dict set queryTopics tests .queryMenu.tests 
menu .queryMenu.attrs -tearoff 0
.queryMenu add cascade -menu .queryMenu.attrs -label "Attributes"  
dict set queryTopics attrs .queryMenu.attrs 
menu .queryMenu.funcs -tearoff 0
.queryMenu add cascade -menu .queryMenu.funcs -label "Functions" 
dict set queryTopics funcs .queryMenu.funcs 
menu .queryMenu.onces -tearoff 0
.queryMenu add cascade -menu .queryMenu.onces -label "Once functions"
dict set queryTopics onces .queryMenu.onces 
menu .queryMenu.consts -tearoff 0
.queryMenu add cascade -menu .queryMenu.consts -label "Constants" 
dict set queryTopics consts .queryMenu.consts 

proc addQueryMenu {label} {
    global queryTopics 
    if {[string first "Arg" $label ]==0} {
	return [dict get $queryTopics args]
    } elseif {[string first "Loc" $label]==0} {
	return [dict get $queryTopics locals]
    } elseif {[string first "Old" $label]==0} {
	return [dict get $queryTopics olds]
    } elseif {[string first "Obj" $label]==0} {
	return [dict get $queryTopics tests]
    } elseif {[string first "Att" $label]==0} {
	return [dict get $queryTopics attrs]
    } elseif {[string first "Fun" $label]==0} {
	return [dict get $queryTopics funcs]
    } elseif {[string first "Onc" $label]==0} {
	return [dict get $queryTopics onces]
    } elseif {[string first "Con" $label]==0} {
	return [dict get $queryTopics consts]
    } else {
    }
}

proc dataItem {data x y} {
    return [$data identify item $x $y]
}

toplevel .log
grid [ttk::frame .log.frame -padding $fp] -column 0 -row 0 -sticky nswe
text .log.frame.text -width 40 -state disabled \
    -yscrollcommand ".log.frame.scrolly set" \
    -xscrollcommand ".log.frame.scrollx set" 
set log .log.frame.text
grid $log -column 0 -row 0 -sticky nswe
grid [ttk::scrollbar .log.frame.scrolly -command "$log yview" \
	  -orient vertical] \
    -column 1 -row 0 -sticky ns
grid [ttk::scrollbar .log.frame.scrollx -command "$log xview" \
	  -orient horizontal] \
    -column 0 -row 1 -sticky we
grid [ttk::separator .log.sep -orient horizontal] -column 0 -row 1 -sticky we
grid [ttk::frame .log.action -padding $fp] -column 0 -row 2 
ttk::button .log.action.close -text "Close" -command { wm withdraw .log }
grid .log.action.close -column 0 -row 0 -sticky we
grid columnconfigure .log.frame 0 -weight 1
grid rowconfigure .log.frame 0 -weight 1
grid columnconfigure .log all -weight 1 -pad 5
grid rowconfigure .log 0 -weight 1
wm withdraw .log
$log tag configure intag -foreground \#b50000
$log tag configure outtag -foreground forestgreen

proc putLog {line in} {
    global log
    $log configure -state normal
    $log insert end "$line\n"
    if {$in} {
	$log tag add intag [$log index "end -2 lines"] [$log index "end -1 lines"] 
    } else {
	$log tag add outtag [$log index "end -2 lines"] [$log index "end -1 lines"] 
    }
    $log see end 
    $log configure -state disabled 
}

set aliasidx 0
set aliasmode 1
toplevel .alias
ttk::combobox .alias.list -height 20 -state readonly
bind .alias.list <<ComboboxSelected>> { \
        if {[.alias.createbutton instate selected]} {
            createObject
        } else {
            editAlias
        } 
    }
grid .alias.list -column 0 -row 0 -sticky we 
ttk::radiobutton .alias.editbutton -text "Edit alias" -variable aliasmode -value 1 \
    -command { activateFrame .alias.edit 1 
        activateFrame .alias.create 0 
        editAlias
    }
grid .alias.editbutton -column 0 -row 1 -sticky w 
grid [ttk::frame .alias.edit] -column 0 -row 2 -sticky we

grid [ttk::label .alias.edit.namelabel -text "Name " -width 6] \
    -column 0 -row 0 -sticky w
grid [ttk::entry .alias.edit.name -width 12] \
    -column 1 -row 0 -sticky w
grid [ttk::label .alias.edit.modelabel -text "  Mode "] \
    -column 2 -row 0 -sticky w
ttk::spinbox .alias.edit.mode -width 2 -wrap 1 -values [list "->" ":="] 
grid .alias.edit.mode -column 3 -row 0 -sticky w
grid [ttk::label .alias.edit.exprlabel -text "Value " -width 6] \
    -column 0 -row 1 -sticky nsw
grid [ttk::entry .alias.edit.value] \
    -column 1 -row 1 -columnspan 3 -sticky we 

set createtypes {}
ttk::radiobutton .alias.createbutton -text "Create object" -variable aliasmode -value 0 \
    -command { activateFrame .alias.create 1 
        activateFrame .alias.edit 0 
        createObject 
     }
grid .alias.createbutton -column 0 -row 3 -sticky w
grid [ttk::frame .alias.create] -column 0 -row 4 -sticky we
grid [ttk::label .alias.create.namelabel -text "Name " -width 6] \
    -column 0 -row 0 -sticky w
grid [ttk::entry .alias.create.name -width 12] \
    -column 1 -row 0 -sticky w
grid [ttk::label .alias.create.typelabel -text  "Type" -width 6] \
    -column 0 -row 1 -sticky w
grid [ttk::combobox .alias.create.types -height 20 -width 40 \
	  -textvariable createtypes \
	  -postcommand { selectTypes .alias.create.types $createtypes }] \
    -column 1 -row 1 -columnspan 3 -sticky w
grid [ttk::label .alias.create.proclabel -text "Proc " -width 6] \
    -column 0 -row 2 -sticky w
grid [ttk::combobox .alias.create.procs -height 20 -width 40 -state readonly] \
    -column 1 -row 2 -sticky w
grid [ttk::label .alias.create.argslabel -text "Args " -width 6] \
    -column 0 -row 3 -sticky we
grid [text .alias.create.args  -height 1 -width [.alias.create.procs cget -width]] \
    -column 1 -row 3 -columnspan 3 -sticky we
bind .alias.create.types <<ComboboxSelected>> {
    set cr [winfo parent %W]
    set creates [lreplace $creates 0 end]
    putCommand "creates [%W get]" "creates"
    $cr.args delete 1.0 end
    $cr.procs configure -values $creates
    if {[llength $creates]>0} {
        $cr.procs current 0
        event generate $cr.procs <<ComboboxSelected>>
    }
    %W selection clear
}
bind .alias.create.procs <<ComboboxSelected>> {
    set cr .alias.create
    set pr [$cr.procs get]
    $cr.args configure -state normal
    $cr.args delete 1.0 end
    set idx [string first "(" $pr]
    if {$pr!="" && $idx>0} { set pr [expandArgs $pr]
        invalidateExpr $cr.args 1.0 [string range $pr $idx end]
    } else {
        $cr.args configure -state disabled
    }
    %W selection clear
}
.alias.create.args tag configure placeholdertag -foreground red
bind .alias.create.args <Return> { if {[.alias.createbutton instate selected]} { 
           storeObject
        } else {
           storeAlias
        }
     }

grid [ttk::separator .alias.sep -orient horizontal] -column 0 -row 5 -sticky we
grid [ttk::frame .alias.action -padding $fp] -column 0 -row 6 
ttk::button .alias.action.apply -text "Apply" \
    -command { if {[.alias.createbutton instate selected]} { 
           storeObject
        } else {
           storeAlias
        }
     }
grid .alias.action.apply -column 0 -row 0 -sticky we
ttk::button .alias.action.close -text "Close" \
    -command { wm withdraw .alias 
         activateFrame .alias.edit 0
         activateFrame .alias.create 0 
     }
grid .alias.action.close -column 1 -row 0 -sticky we
grid columnconfigure .alias all -pad 5
grid rowconfigure .alias all -pad 5
wm withdraw .alias

proc showEditAlias {} {
    global title debuggee aliases
    .alias.list configure -values $aliases
    .alias.list current 0
   .alias.editbutton invoke
    wm title .alias "$title $debuggee - Edit aliases"
    wm transient .alias 
    wm deiconify .alias
}

proc showAlias {} {
    global aliases dataSet
    set aliases [list ""]
    putCommand "info alias" "ialias"
    set al .alias.list
    set m [$al current]
    set n [expr [llength $aliases] -1]
    if {0==$n || ($n>$m && $m>0)} { set n 0 }
    $al configure -values $aliases
    $al current $n
    dict for {id d} $dataSet {
        set al [dict get $d alias]
        $al configure -values $aliases
        $al current $n
    }
}

proc aliasExpr {d} {
    set al [dict get $d alias]
    set vals [$al get]
    set expr [dict get $d expr] 
    set idx [$expr index insert]
    $expr insert $idx [lindex $vals 0]
    focus $expr
    selection clear $expr
}

proc editAlias {} {
    global aliasidx aliasval
    set al .alias.list
    set ed .alias.edit
    set val [$al get]
    set aliasidx [$al current]
    $ed.name configure -state normal
    $ed.name delete 0 end
    if {$aliasidx==0} {
	$ed.mode set 0
    } else {
	set name [string range [lindex $val 0] 1 end]
	$ed.name insert 0 $name
	$ed.name configure -state readonly
    }
    set mode [lindex $val 1]
    switch $mode {
	"=" { set mode ":=" }
	":" { set mode ":=" }
	default { set mode "->" }
    }
    $ed.mode set $mode
    $ed.value delete 0 end
    $ed.value insert 0 [lindex $val 2]
}

proc storeAlias {} {
    global aliasidx
    global erroInfo errorDetail
    set al .alias.list
    set ed .alias.edit
    set name [$ed.name get]
    if {$name==""} { 
        set errorInfo "Invalid alias definition"
        set errorDetail "Alias name empty."
        showError
        return
    }
    set mode [$ed.mode get]
    set expr [$ed.value get]
    if {$expr==""} {
	set name [string range [lindex $expr 0] 1 end]
	putCommand "_$name --" "other"
    } else {
        putCommand "_$name $mode $expr" "other"
    }
    showAlias
}

proc createObject {} {
    global types aliasidx
    set al .alias.list
    set ed .alias.create
    set val [$al get]
    set aliasidx [$al current]
    $ed.types configure -values $types
    $ed.name configure -state normal
    $ed.name delete 0 end
    if {$aliasidx==0} {
	.alias.edit.mode set ":="
    } else {
	set name [string range [lindex $val 0] 1 end]
	$ed.name insert 0 $name
	$ed.name configure -state readonly
    }
    $ed.args delete 1.0 end
    $ed.args insert 1.0 [lindex $val 2]
}

proc storeObject {} {
    global aliasidx
    global erroInfo errorDetail
    set al .alias.list
    set cr .alias.create
    set name [$cr.name get]
    if {$name==""} { 
        set errorInfo "Invalid alias definition."
        set errorDetail "Alias name empty."
        showError
        return
    }
    set tp [$cr.types get]
    if {$tp==""} { 
        set errorInfo "Invalid alias definition."
        set errorDetail "No type chosen."
        showError
        return
    }
    set pr [$cr.procs get]
    if { $pr!=""} { 
	set aliasidx [string first "(" $pr]
	if {$aliasidx>0} { set pr [string range $pr 0 $aliasidx-1] }
	if {[checkExpr $cr.args]} { 
            set args [$cr.args get 1.0 "end -1 chars"]
	    set tp "$tp:$pr$args" 
	    putCommand "_$name := !$tp!" "other"
	    showAlias
	}
    }
}

proc putAssignCommand {val} {
    global data
    set vars [dict get $data vars]
    set item [$vars selection]
    if {$item!=""} {
	set expr [dict get $data expr]
	set var [expandExpr $vars $item ""]
	set cmd "assign $var := $val"
	putLog $cmd 0 
	putCommand $cmd "other"
	$vars selection set {}
	doPrint 1 1
	if {[$vars exists $item]} { $vars selection set $item }
    }
}

proc putCommand {cmd w} {
    global io awaited lastCommand
    set awaited $w
    set lastCommand $cmd
#    puts "Command: $cmd"
    if {[catch {puts $io $cmd}]} { interruptProcess 1 }
    flush $io
    while {$awaited!=0} { vwait awaited }
}

proc showFrame {line} {
    global calls
    set depth ""
    regexp {[0-9]+} $line depth
    set i [string first $depth $line]
    set i [string wordend $line $i]
    set line [string range $line $i end]
    set line [string trim $line]
    set words [split $line ".:"]
    lappend calls [concat $depth $words]
}

proc addMark {m} {
    global markList
    set idx ""
    regexp {[0-9]+} $m idx
    set i [string first $idx $m]
    if {$i>0} { set m [string range $m $i end] }
    lappend markList $m 
}

dict set longTypenames I8 INTEGER_8
dict set longTypenames I16 INTEGER_16
dict set longTypenames I32 INTEGER_32
dict set longTypenames I64 INTEGER_64
dict set longTypenames N8 NATURAL_8
dict set longTypenames N16 NATURAL_16
dict set longTypenames N32 NATURAL_32
dict set longTypenames N64 NATURAL_64
dict set longTypenames R32 REAL_32
dict set longTypenames R64 REAL_64
dict set longTypenames C8 CHARACTER
dict set longTypenames C32 CHARACTER
dict set longTypenames S8 STRING_8
dict set longTypenames S32 STRING32
dict set longTypenames S8 STRING_8
dict set longTypenames S32 STRING32

proc addData {vars line} {
    global varcount varstack vartop printQueue needTreeRemoval
    global longTypenames
    set val ""
    set t ""
    if {$needTreeRemoval} {
	$vars delete [$vars children {}]
	set needTreeRemoval 0
    }
    if {$vartop!={}} {
	lappend varstack $vartop
	set vartop {}
    } else {
	regexp { at 0x[A-F0-9]+} $line val
	if {$val!=""} {
	    set l [string last $val $line] 
	    set val [string range $line [expr $l+4] end]
	    set line [string range $line 0 [expr $l-1]]
            set val $val 
	}
	set chars ""
	regexp {[^ ]+} $line chars
        set d [string first $chars $line]
	regexp { [:=] } $line chars
	set l [string first $chars $line] 
	set name [string range $line $d [expr $l-1]]
	if {[string first "=" $chars]<0} {
	    set l [string first ":" $line]
	    set t [string range $line [expr $l+2] end]
	} else {
	    set line [string range $line [expr $l+2] end]
	    regexp { [CINRS][0-9]+} $line t
	    if {$t!=""} {
		set l [string last $t $line]
		set t [string range $line $l+1 end]
		set t [dict get $longTypenames $t]
		set val [string range $line 0 $l]
	    } else {
		set val [string trim $line]
                set c [string index $val 0]
                if {$val=="Void"} { set t "NONE"
                } elseif {[string is boolean $val]} { set t "BOOLEAN"
                } elseif {$c=="\""} { set t "STRING_8" 
                } elseif {$c=="\'"} { set t "CHARACTER_8"
                } elseif {[string first "." $val]>=0} { set t "REAL_64"
                } elseif {$c=="-"} { set t "INTEGET_32"
                } else { set t "NATURAL_32"
                }
	    }
	}
	incr varcount
	set max [llength $varstack] ; incr max -1
	set d [expr $d/2]
	set idx end
	if {$d>=$max} { 
	    set anchor [lindex $varstack $max]
	    lappend varstack $varcount
	    set d [llength $varstack] ; incr d -1
	} else {
	    set anchor [lindex $varstack $d]
	    incr d
	    set varstack [lreplace $varstack $d $max $varcount]
	}
	set child {}
	if {[$vars exists $anchor]} {
	    foreach c [$vars children $anchor] {
		if {[$vars item $c -text]==$name} {
		    set oldvals [$vars item $c -values]
		    set oldtype [lindex $oldvals 1]
		    if {$oldtype!=$t} { 
			$vars delete [$vars children $c] 
			set idx [$vars index $c]
			$vars delete $c
			if {$anchor=={}} { }
		    } else {
			set child $c
		    }
		    break
		}
	    }
	}
	if {$child!={}} {
	    $vars item $child -values [list $val $t]
	    lset varstack $d $child
	    set ch [$vars children $child]
	    if {$name!="Current"  && [llength $ch]>0} { 
		if [$vars item $child -open] {
		    lappend printQueue $child 
		} else {
		    $vars delete $ch
		}
	    }
	} else {
	    $vars insert $anchor $idx -id $varcount -text $name \
		-values [list $val $t]
	}
    }
}

proc addBreak {line} {
    global breaks breakDef bdebug
    global source catches
    set words [split $line]
    set l [string first ":" $line]
    set val [string range $line [expr $l+2] end]
    switch [lindex $words 0] {
	"Breakpoint" { lset breakDef 0 [lindex $words 1]; lset breakDef 9 "" }
	"Tracepoint" { lset breakDef 0 [lindex $words 1]; lset breakDef 9 "y" }
	"catch" { 
	    dict for {short long} $catches {
		if {$long==$val} {
		    lset breakDef 1 $short
		    break
		}
	    }
	}
	"at" { lset breakDef 2 $val 
	    highlightBreak $val
	}
	"depth" { set words [split $val]
	    lset breakDef 3 [lindex $words 0] 
	    if {[llength $words]>1} { lset breakDef 4 "++" }
	}
	"watch" { set l [string first "=" $val]
	    if {$l<0} {
		lset breakDef 5 $val
	    } else {
		lset breakDef 5 [string trim [string range $val 0 [expr $l-1]]]
		lset breakDef 10 [string trim [string range $val [expr $l+1] end]]
            }
        }
        "type" { lset breakDef 6 $val }
        "if" { lset breakDef 7 $val }
        "print" { lset breakDef 8 $val }
        "enabled:" { set item [$breaks insert {} 1 -values $breakDef]
            if {[string first "no" $line]>0} {
                $breaks item $item -tags disabletag
            } else {
                $breaks item $item -tags {}
            }
            breakClear 1
        }
        "Break" {
            if {[string first "Break at debug clauses" $line]==0} {
                if {[lindex $words 4]=="disabled."} {
                    set bdebug 0
                } else {
                    set bdebug 1
                }
            }
        }
        default {}
    }
}

proc addAlias {line} {
    global aliases
    set mode ""
    regexp {[=:-]} $line mode
    set idx0 [string first $mode $line]
    set name [string range $line 0 [expr $idx0-2]]
    if {$mode=="-"} { 
	set mode "->" ; set idx1 [expr $idx0+1] 
    } else {
	set idx1 $idx0 
    }
    set val [string range $line [expr $idx1+2] end]
    lappend aliases "$name $mode $val"
}

proc fillClassList {} {
    global classField names
    $classField configure -values $names
}

proc addTypeOrClass {line} {
    global types classes names skip
    if {$skip && [string first "matching types or classes" $line]>0} {
	set skip 0
    } else {
	set tc ""
	regexp {^[ 0-9]+[TC]{1,2}} $line tc
	set idx [string first "C" $tc]
	if {$idx>=0} {
	    set c [string range $line [expr $idx+5] end]
	    set idx [string first "\[" $c]
	    if {$idx>=0} {
		set c [string range $c 9 [expr $idx-1]]
	    }
	    dict set tmp name $c
	    dict set tmp file ""
	    dict set tmp len 0
	    dict set tmp range {}
	    lappend classes $tmp
	    lappend names $c
	}
    }
}

proc addPos {line} {
    global actClass posList
    set c [string index $line 0]
    if {0<=$c && $c<=9} {
	set words [split $line ] 
	foreach n $words {
	    if {$n=="0"} { 
		break 
	    } elseif {$n!={}} {
		lappend posList $n
	    }
	}
    } elseif {$c=="%"} {
	dict set actClass range [string range $line 1 end]
    } else {
	dict set actClass file $line
    }
}

proc addTypeset {line} {
    global queries types 
    set parts [split $line]
    set name [lindex $parts end]
    if {[string first "Static" $line]==0} {
	$queries add command -label $name -state disabled
    } elseif {[string first "dynamic" $line]<0} {
	if {0} {
	    $queries add command -label $name -command { 
		putAssignCommand "\![$queries entrycget active -label]\!" }
	} else {
	    $queries add command -label $name -state disabled
	}
    } else {
	$queries add separator
    }
}

proc extractArgs {line} {
    global argList
    set l [string first "(" $line]
    if {$l>0} {
	set r [string last ")" $line]
	set args [string range $line $l $r]
	dict set argList id [string trim [string range $line 0 $l-1]] $args
	set line [string replace $line $l $r "(...)"]
    }
    set line [string trim $line]
    return $line
}
proc getAnswer {} {
    global io awaited timeout
    global stopReason atend needBreaks
    global errorCode errorInfo errorDetail lastCommand
    global class likeList
    global calls
    global data nameof 
    global marks markList
    global types queries queryMenu creates 
    global log universeList infoSystem
    after cancel $timeout
    set words ""
    set errorCode 0
    catch {set l [gets $io got]} 
    if {$errorCode!=0} {
	set errorDetail ""
	showError 
	initVariables
    }
    set needbreaks 0
    if {$l<0} { 
	fileevent $io readable {}
	after idle {close $io ; set out 1}
	return
    }
    foreach line [split $got "\n"] {
	if {[string compare $line "gedb> "]==0} {
#	    puts "awaited: $awaited"
	    switch $awaited {
		"types" { set types [linsert $types 0 ""] ; fillClassList }
		"current" { }
		"where" { }
		"ialias" { }
		"ibreak" { }
		"imark" {
		    $marks configure -values $markList 
		    $marks set [lindex $markList 0]
		}
		"print" {
		    set vars [dict get $data vars]
		    if {[llength [$vars children {}]]>0} { 
			catch {$vars selection set 1}
		    } 
		}
		"like" { showLikeSource }
		default { }
	    }
	    set awaited 0
	} elseif {[string first "gedb: " $line]==0} {
	    if {!$atend} {
		set errorInfo "[string range $line 6 end]"
		set atend [string match "*System has completed successfully." $line]
		showError 
	    }
	} elseif {[string index $line 0]=="."} {
	    if {!$atend} {
		if {$errorDetail==""} {
		    set errorDetail "$lastCommand\n[string range $line 6 end]" 
		} else {
		    set errorDetail "$errorDetail\n$line" 
		}
	    }
	} elseif {[string index $line 0]=="?"} {
	    if {!$atend} { set errorDetail "$errorDetail\n$line" }
	} else { 
	    switch $awaited {
		"pos" { addPos $line }
		"types" { addTypeOrClass $line }
		"current" { 
		    set b [string first "Breakpoint" $line]
		    set t [string first "Tracepoint" $line]
		    if {$b==0} {
			putLog "$line" 1
			set stopReason $line
			set b [string first " " $line]
			set b [string trim [string range $line $b end]]
			selectBreak $b
			set needBreaks $b
		    } elseif {$t==0} {
			putLog "$line" 1
			set stopReason $line
			set t [string first " " $line]
			set t [string trim [string range $line $t end]]
			set needBreaks $t
		    } elseif {$needBreaks} {
			if {[string first "class" $line]==0} {
			    set needBreaks 0
			} else {
			    putLog "$line" 1
			}
		    }
		}
		"where" { if {[string first "=" $line]<0} { showFrame $line } }
		"ialias" { 
		    if {[string index $line 0]=="_"} {
		    addAlias [string trim $line] }
		}
		"ibreak" { addBreak [string trim $line]}
		"imark" { addMark $line }
		"print" { addData [dict get $data vars] $line }
		"queries" { 
		    if {[string index $line 0]!=" "} {
			if {[string first "type " $line]<0} { 
			    set queries [addQueryMenu $line]
			    $queries delete 0 end
			    $queryMenu add cascade -menu $queries -label $line
			}
		    } elseif {[string first "type" $line]!=0} {
			$queries add command -label [extractArgs $line] \
			    -command { 
				set q [$queryMenu entrycget active -menu]
				if {$q!=""} { 
				    setExpr $data $item [$q entrycget active -label] 
				}
			    }
		    }
		}
		"creates" { 
		    if {[string index $line 0]=="*"} {
			set creates [linsert $creates 0 ""]
		    } elseif {[string index $line 0]==" "} {
			lappend creates [extractArgs $line]
		    }
		}
		"nameof" { set nameof $line }
		"like" { 
		    set words [split [string trim $line]]
		    set w0 [lindex $words 0]
		    if {[llength $likeList]==0} {
			lappend likeList [lindex $words 1] 
		    } elseif {$w0!="\[EOF\]"} {
			lappend likeList $w0
		    }
		}
		"universe" { 
		    if {[regexp {^ *[1-9][0-9]* *[TC]} $line ]} {
			set line [string replace $line 0 [string last " " $line]]
			lappend universeList "$line" 
		    }
		}
		"isystem" { set infoSystem "$infoSystem\n$line" }
	    default {  }
	    }
	}
    }
}

#########

if {$argc>0} { set sys $argv ; startup $sys }
