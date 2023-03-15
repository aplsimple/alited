###########################################################
# Name:    playtkl.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 01, 2023
# Brief:   Handles playing macro & testing Tk apps.
# License: MIT.
###########################################################

package provide playtkl 1.0.1

# _________________________ playtkl ________________________ #

namespace eval playtkl {
  variable fields {-time %t -keysym %K -button %b -x %x -y %y -state %s -data %d}
  variable dd; array set dd {timing 1 endkey "" pausekey ""}
}
#_______________________

proc playtkl::Data {w data} {
  # Extracts event's data of wildcard
  #   w - the wildcard
  #   data - full list of %w=data

  set i [lsearch -glob $data $w*]
  set d [lindex $data $i]
  return [string range $d [string first = $d]+1 end]
}
#_______________________

proc playtkl::Mapping {win} {
  # Maps a recorded window to a played one.
  #   win - the recorded window's path
  # At recording, some widgets may be dynamic, with their pathes not equal to current ones
  # => map them.

  variable dd
  foreach {w1 w2} $dd(mappings) {
    if {[string match $w1 $win]} {return $w2}
  }
  return $win
}
#_______________________

proc playtkl::Recording {win ev args} {
  # Saves data of an event occured on a window.
  #   win - window's path
  #   ev - event
  #   args - data

  variable dd
  if {![isend]} {
    set key [Data %K $args]
    if {$key eq $dd(endkey)} {
      end
    } else {
      set t [Data %t $args]
      if {[string is integer -strict $t] && $t>0} {
        if {$ev eq {KeyRelease} && $dd(prevev) ne {KeyPress} && $key in {Tab Return}} {
          set t %t=[expr {[Data %t $args]-1}]
          lappend dd(fcont) KeyPress\ $win\ $args\ $t
        }
        lappend dd(fcont) $ev\ $win\ $args
      } else {
        inform yes
        inform "BUG? (time received 0): $ev $win $args"
      }
      set dd(prevev) $ev
    }
  }
}
#_______________________

proc playtkl::Playing {} {
  # Plays a current record.

  variable fields
  variable dd
  set llen [llength $dd(fcont)]
  if {[incr dd(idx)]>=$llen} {
    end
    return
  }
  if {$dd(pause)} {
    after 200 ::playtkl::Playing
    return
  }
  set line [lindex $dd(fcont) $dd(idx)]
  if {[regexp {^\s*#+} $line#]} { ;# skip empty or commented
    after idle ::playtkl::Playing
    return
  }
  lassign $line ev win
  set win [Mapping $win]
  if {$dd(timing) eq {YES}} {inform "$dd(idx): $line"} ;# to debug
  set data [lrange $line 2 end]
  # mouse buttons: pressed on one window, released on other not existing yet
  if {![winfo exists $win]} {
    for {set i $dd(idx)} {$i<$llen && $win ne $dd(win)} {incr i} {
      set l1 [lindex $dd(fcont) $i]
      lassign $l1 e1 w1
      set w1 [Mapping $w1]
      if {$e1 in {ButtonPress ButtonRelease} && [winfo exists $w1]} {
        set dd(fcont) [lreplace $dd(fcont) $i $i]
        set t [Data %t $dd(data)]
        set dd(fcont) [linsert $dd(fcont) $dd(idx) "$l1 %t=[incr t]"]
        incr dd(idx) -1
        break
      }
    }
    after idle ::playtkl::Playing
    return
  }
  set opts {}
  set time 0
  foreach wdt $data {
    set wc [string range $wdt 0 1]
    set dt [string range $wdt 3 end] ;# e.g. %x=657
    if {$dt ne {??}} {
      if {$wc eq {%t}} {
        set time $dt
        continue
      }
      if {$wc eq {%x}} {set X $dt}
      if {$wc eq {%y}} {set Y $dt}
      set i [lsearch -exact $fields $wc]
      append opts { } [lindex $fields $i-1 0] { } $dt
    }
  }
  set dd(win) $win
  set dd(data) $data
  if {$ev eq {Motion} && [info exists X] && [info exists Y]} {
    after idle [list event generate $win <Motion> -warp 1 -x $X -y $Y]
  } else {
    after idle [list event generate $win <$ev> {*}$opts]
  }
  set line [lindex $dd(fcont) $dd(idx)+1]
  set time1 [Data %t [lrange $line 2 end]]
  if {!$time || ![string is integer -strict $time1]} {
    set aft idle
  } else {
    set aft [expr {max(0,$time1-$time)}]
  }
  after $aft ::playtkl::Playing
}
#_______________________

proc playtkl::PausePlaying {pausekey key} {
  # Pauses / resumes the playing.
  #   pausekey - key to pause/resume
  #   key - pressed key

  variable dd
  if {$pausekey eq $key} {
    if {[set dd(pause) [expr {!$dd(pause)}]]} {inform Paused} {inform Resumed}
  }
}

# ________________________ Record _________________________ #

proc playtkl::inform {msg} {
  # Puts out a message and the current time.
  #   msg - the message or yes/no to switch the puts on/off

  variable dd
  if {[string is boolean $msg]} {
    set dd(timing) $msg
  } elseif {$dd(timing)} {
    if {[string length $msg]<11} {
      bell
      set msg [string range "          $msg" end-10 end]
    }
    set msg "playtkl: $msg: [clock format [clock seconds] -format %T]"
    puts $msg
  } else {
    set msg {}
  }
  return $msg
}
#_______________________

proc playtkl::record {fname {endkey ""}} {
  # Starts the recording.
  #   fname - name of file to store the recording
  #   endkey - key to stop the recording

  variable fields
  variable dd
  set dd(isrec) yes
  if {![info exists dd(msgbeg)]} {
    foreach {o w} $fields {append opts " {%$w=$w}"}
    foreach ev {KeyPress KeyRelease ButtonPress ButtonRelease Motion} {
      bind all <$ev> "+ ::playtkl::Recording %W $ev $opts"
    }
  }
  set dd(fname) $fname
  set dd(endkey) $endkey
  set dd(idx) -1
  lassign {} dd(prevev) dd(fcont) dd(win)
  set dd(msgbeg) [inform Recording]
}

# ________________________ Playback _________________________ #

proc playtkl::play {fname {pausekey ""}} {
  # Starts the playback.
  #   fname - name of file to store the recording
  #   pausekey - key to pause/resume the playing

  variable dd
  if {$pausekey ne {} && $pausekey ne $dd(pausekey)} {
    bind all <KeyPress> [list + ::playtkl::PausePlaying $pausekey %K]
    set dd(pausekey) $pausekey
  }
  replay $fname {} {} no
}
#_______________________

proc playtkl::replay {{fname ""} {cbreplay ""} {mappings {}} {ismacro yes}} {
  # Replays a read/written recording, fastly at replaying a macro.
  #   fname - name of file to store the recording
  #   cbreplay - callback after replaying (e.g with "text edit separator")
  #   mappings - mappings of some widgets' pathes to currently used ones
  #   ismacro - yes for fast replaying a macro (used by playtkl)

  variable dd
  if {$fname ne {}} {
    set ch [open $fname]
    set dd(fcont) [split [string trim [read $ch]] \n]
    close $ch
  }
  set line [lindex $dd(fcont) 0]
  lassign $line dd(prevev) dd(win)
  set dd(data) [lrange $line 2 end]
  set dd(idx) -1
  set dd(isrec) no
  set dd(pause) no
  set dd(cbreplay) $cbreplay
  set dd(mappings) $mappings
  if {$ismacro} {
    set fcont [list]
    set time 0
    foreach line $dd(fcont) {
      if {![regexp {^\s*#+} $line#]} { ;# skip empty or commented
        set ln [lrange $line 0 1]
        append ln " %t=[incr time 2] " [lrange $line 3 end]
        lappend fcont $ln
      }
    }
    set dd(fcont) $fcont
  }
  inform Playing
  Playing
}

# ________________________ Game over _________________________ #

proc playtkl::end {} {
  # Closes the recording/playing.

  variable dd
  set msgend [inform End]
  if {$dd(isrec)} {
    set dd(fcont) [lsort -index 2 -dictionary $dd(fcont)] ;# sort by time
    if {$msgend ne {}} {
      set dd(fcont) [linsert $dd(fcont) 0 "# $dd(msgbeg)" "# $msgend" #]
    }
    set ch [open $dd(fname) w]
    foreach line $dd(fcont) {puts $ch $line}
    close $ch
  }
  if {[info exists dd(cbreplay)] && $dd(cbreplay) ne {}} {
    {*}$dd(cbreplay)
  }
  unset -nocomplain dd(cbreplay)
  set dd(isrec) 0
  set dd(endkey) -
}
#_______________________

proc playtkl::isend {} {
  # Checks if the recording is done.

  variable dd
  expr {!$dd(isrec)}
}

# _______________________ EOF _______________________ #
