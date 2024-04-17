# ________________________ help _________________________ #

# The mode=6 means that the formatter can be run by events.
#
# The "events=..." line sets a list of events which will trigger the formatter.
#
# The events are separated with commas and/or spaces. At that, if present,
# 1st event's letter is recommended to be in upper case which is
# only used at getting accelerators and engaged keys, e.g.:
#   events = <Control-Q>, <Control-q>
#
# The events must not overlap the alited's key mappings (as set in
# Preferences/Keys and Templates).
#
# After "events=..." line, there follows "command=" line meaning that
# the rest of file is treated as Tcl code block.
#
# The code block can include wildcards:
#   %W for current text's path
#   %f for current edited file name
#   %v for selected text (or current line)
#
# The commands may include calls to alited procedures, mostly of alited::
# namespace. Details in alited's Reference:
#   https://aplsimple.github.io/en/tcl/alited/alited.html
#
# This is the regular usage of mode=6, so the pluginables have normally
# .tcl extension.
#
# If not empty, the result of last command is inserted at the current text
# position or replaces selected text.

# ________________________ settings _________________________ #

# Shows information about the current text & platform.
#
# Also demonstrates, how to use
#   - "command=" line to treat the rest of file as Tcl code block
#   - "proc" commands creating procedures in alited::format namespace
#   - alited::Msg to show messages
#   - separator for tool bar
#   - icon for tool bar

Mode = 6

#! comment "sep=" to be inactive
sep = 1

#! comment "icon=" to be inactive
icon = info

events = <Alt-I>, <Alt-i>

command =

# ________________________ procs _________________________ #

proc MAXARRNAME {arrvarname} {
  # Gets a maximum length of array names.
  #   arrvarname - array variable's name

  upvar $arrvarname arrvar
  set maxl 0
  foreach n [array names arrvar] {
    if {[set ll [string length $arrvar($n)]] > $maxl} {
      set maxl $ll
    }
  }
  return $maxl
}
#_______________________

proc INFO {} {
  # Gets longest and shortest lines' numbers.

  set ilong 0
  set ishort 0
  set maxlen 0
  set minlen 9999999999
  set cont [split [%W get 1.0 end] \n]
  foreach line $cont {
    incr il
    if {[set len [string length $line]]} {
      if {$maxlen < $len} {
        set ilong $il
        set maxlen $len
      }
      if {$minlen > $len} {
        set ishort $il
        set minlen $len
      }
    }
  }
  set ll [string length $ilong]
  set pad [string repeat { } $ll]
  set ishort [string range $ishort$pad 0 $ll]
  set ilong [string range $ilong$pad 0 $ll]
  list $ishort $ilong $minlen $maxlen
}

# ________________________ main _________________________ #

# current file info
lassign [INFO] ishort ilong minlen maxlen
set lin(1) "Shortest line :  $ishort (length: $minlen)"
set lin(2) "Longest line  :  $ilong (length: $maxlen)"

# misc info
set lin(3) "Locale          : [msgcat::mclocale]"
set lin(4) "MC preferences  : [msgcat::mcpreferences]"
set lin(5) "Encoding system : [encoding system]"
set lin(6) "File volumes    : [file volumes]"
set ln 6

# platform info
set tclver "Tcl v[info patchlevel]"
set tclexn [info nameofexecutable]
set platfinfo [lsort [array names ::tcl_platform]]
set platfinfo [linsert $platfinfo 0 $tclver]
# align prompts
set maxl 0
foreach nam $platfinfo {
  if {[set ll [string length $nam]] > $maxl} {
    set maxl $ll
  }
}
set pad [string repeat { } $maxl]
foreach pn $platfinfo {
  incr ln
  if {$pn eq $tclver} {
    set val $tclexn
  } else {
    set val $::tcl_platform($pn)
  }
  set pn [string range $pn$pad 0 $maxl]
  set lin($ln) "$pn: $val"
}

# format info message
set maxl [MAXARRNAME lin]
set maxl [expr {min($maxl,99)}]
set under_ [string repeat _ $maxl]
set message "\
$lin(1) \n\
$lin(2) \n\
$under_ \n\n\
$lin(3) \n\
$lin(4) \n\
$lin(5) \n\
$lin(6) \n\
$under_ \n\n"
for {set i 0} {$i<[llength $platfinfo]} {incr i} {
  set idx [expr {$i+7}]
  append message " $lin($idx) \n"
}
set message [string trimright $message \n]

# message with icon=info in text mode
alited::Msg $message info -text 1 -width [incr maxl 2]
set _ ""