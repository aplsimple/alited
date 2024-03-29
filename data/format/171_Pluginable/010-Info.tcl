
# The mode=6 means that the formatter can be run by events.
#
# The "events=..." line sets a list of events which triggers the formatter.
#
# The events are separated with commas and/or spaces, e.g.:
# events = <Control-Q>, <Control-q>
#
# The events must not overlap the alited's key mappings (as set in
# Preferences/Keys and Templates).
#
# The command can include wildcards:
#   %w for current text's path
#   %f for current edited file
#   %v for selected text (or current line)
#
# After "events=..." line, there follows "command=" line meaning that
# the rest of file is treated as Tcl code block.
#
# It's the regular usage of mode=6, so the formatter files have normally
# .tcl extension.
#
# The commands may include calls to alited procedures, mostly of alited::
# namespace. Details in alited's Reference:
#   https://aplsimple.github.io/en/tcl/alited/alited.html
#
# The result of commands is ignored.

# ===========================================================================

# Shows information about the current text.
#
# Also demonstrates, how to use
#   command= to treat the rest of file as Tcl code block
#   proc
#   alited::Msg

Mode = 6

events = <Control-Q>, <Control-q>

command =
#_______________________

proc MAXARRNAME {arrvarname} {
  # Gets a maximum length of array keys.
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
  # Returns longest and shortest lines.
  #
  # Created in alited::format namespace that doesn't contain UPPERCASE proc names.

  set ilong 0
  set ishort 0
  set maxlen 0
  set minlen 9999999999
  set cont [split [%w get 1.0 end] \n]
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
#_______________________

lassign [INFO] ishort ilong minlen maxlen
set lin(1) "Shortest line :  $ishort (length: $minlen)"
set lin(2) "Longest line  :  $ilong (length: $maxlen)"
set lin(3) "Locale          : [msgcat::mclocale]"
set lin(4) "MC preferences  : [msgcat::mcpreferences]"
set lin(5) "Encoding system : [encoding system]"
set lin(6) "File volumes    : [file volumes]"
set ln 6
set tclver "Tcl v[info patchlevel]"
set tclexn [info nameofexecutable]
set platfinfo [lsort [array names ::tcl_platform]]
set platfinfo [linsert $platfinfo 0 $tclver]
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
set maxl 0
foreach n [array names lin] {
  if {[set ll [string length $lin($n)]] > $maxl} {
    set maxl $ll
  }
}
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
# show message with icon=info in text mode
alited::Msg $message info -text 1 -width [incr maxl 2]

# returned value (meaning "no insertion in current text")
set _ {}
