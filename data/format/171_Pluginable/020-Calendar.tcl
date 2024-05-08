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

# Shows alternative calendar (of tklib).
#
# If there is a selected text, it's treated as a date value according to
# setting "Preferences/Template/Date format" and a new selected date will
# replace it.
#
# If there is no selected text, a date will be inserted at the cursor.
#
# Escape key closes the calendar not changing the text.

# ________________________ settings _________________________ #

Mode = 6

#! uncomment "icon=" to be active
#! icon = C

events = <Alt-T>, <Alt-t>

command =

# ________________________ procs _________________________ #

proc dateChooser {tvar args} {
  # Standard calendar widget of tklib.
  #   tvar - name

  array set a $args
  set ttl [msgcat::mc Date]
  if {[info exists a(-title)]} {set ttl $a(-title)}
  set df %%d.%%m.%%Y
  catch {set df $a(-dateformat)}
  if {[set $tvar] eq {}} {
    catch {set $tvar [clock format [clock seconds] -format $df]}
  } else {
    if {[catch {clock scan [set $tvar] -format $df} err]} {
      set $tvar {}
    }
  }
  set lng [msgcat::mclocale]
  if {$lng ni {de en es fr gr he it ja sv pl pt zh fi tr nl ru}} {
    set lng en
  }
  set wpar [winfo toplevel %W]
  set wcal $wpar.calendarTk
  catch {destroy $wcal}
  wm title [toplevel $wcal] $ttl
  wm transient $wcal $wpar
  wm protocol $wcal WM_DELETE_WINDOW [list set $tvar ""]
  if {[::asKDE]} {wm attributes $wcal -topmost 1}
  bind $wcal <Escape> [list set $tvar ""]
  after idle focus $wcal.c
  widget::calendar $wcal.c -dateformat $df -enablecmdonkey 0 -command \
    [list set $tvar] -textvariable $tvar -language $lng -font [alited::Font]
  pack $wcal.c -fill both -expand 0
  grab set $wcal
  tkwait variable $tvar
  update
  destroy $wcal
  return [set $tvar]
}

# ________________________ main _________________________ #

set _ ""
if {[catch {package require widget::calendar} e]} {
  alited::Msg "widget::calendar error\n$e" err
} else {
  set var [namespace current]::DATETIME
  if {![info exists $var] || {%v} ne {}} {
    set $var {%v}
  }
  if {[catch {set _ [dateChooser $var -dateformat "%d"]} e]} {
    alited::MessageError "Error: $e"
  }
}
set _