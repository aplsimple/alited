###########################################################
# Name:    playtkl.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 01, 2023
# Brief:   Handles playing macro & testing Tk apps.
# License: MIT.
###########################################################

package provide playtkl 1.4.1

# _________________________ playtkl ________________________ #

namespace eval playtkl {
  variable fields {-time %t -keysym %K -button %b -x %x -y %y -state %s -data %d -delta %D}
  variable dd; array set dd {timing 1 endkey "" pausekey ""}
}
#_______________________

proc playtkl::Data {wc data} {
  # Extracts event's data of wildcard
  #   wc - the wildcard
  #   data - full list of %w=data

  set i [lsearch -glob $data $wc=*]
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
      if {!$dd(mouse) && $ev in {ButtonPress ButtonRelease Motion MouseWheel}} return
      set t [Data %t $args]
      if {[string is integer -strict $t] && $t>0} {
        set t %t=[expr {[Data %t $args]-1}]
        set ifound -1
        if {$key in {Tab Return}} {
          if {$ev eq {KeyRelease} && $dd(prevev) ne {KeyPress}} {
            lappend dd(fcont) "KeyPress $win $args $t"
          }
        } elseif {$ev eq {KeyRelease} && ([string length $key]==1 || \
        $key in {Left Right Up Down Home End Next Prior \
        F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12})} {
          # KeyRelease of "Ctrl/Alt/Shift + char/navigating/function key" sets the problem:
          #   the previous KeyPress can be not registered by Tk (only Control's etc.)
          #   => no response from KeyPress bindings
          set ifound [FindPrevEvent $key KeyPress $ev $win {*}$args]
          if {$ifound<0} {
            lappend dd(fcont) "KeyPress $win $args $t %B=??" ;# %B stands for DEBUG
          }
        }
        if {$ifound<0} {
          lappend dd(fcont) "$ev $win $args"
        }
      } else {
        inform yes
        inform "BUG? (time received 0): $ev $win $args"
      }
      set dd(prevev) $ev
    }
  }
}
#_______________________

proc playtkl::FindPrevEvent {key ev ev2 win args} {
  # Searches events "ev" and "ev2" in dd(fcont) list.
  #   key - current key
  #   ev - the main event to search
  #   ev2 - the event tied to the main event
  #   win - current widget's path
  #   args - parameters of current event

  variable dd
  set ifound -1
  for {set i [llength $dd(fcont)]} {$i} {incr i -1} {
    set item [lindex $dd(fcont) $i]
    lassign $item e w
    set k [Data %K $item]
    if {$e in "$ev $ev2" && $w eq $win && $k eq $key} {
      if {$e eq $ev} {set ifound $i}
      break
    }
  }
  return $ifound
}
#_______________________

proc playtkl::Playing {} {
  # Plays a current record.

  variable fields
  variable dd
  if {$dd(pause)} {
    after 200 ::playtkl::Playing
    return
  }
  set llen [llength $dd(fcont)]
  if {[incr dd(idx)]>=$llen} {
    catch {
      if {$dd(ismacro)} {
        focus [winfo toplevel $dd(wfocus)]
        focus $dd(wfocus)
      }
    }
    end
    return
  }
  set line [lindex $dd(fcont) $dd(idx)]
  if {[regexp {^\s*#+} $line#]} { ;# skip empty or commented
    puts $line
    after idle ::playtkl::Playing
    return
  }
  if {[string match {stop *} $line]} {
    bell
    set scom [string range $line 5 end]
    set slin "Line#[expr {$dd(idx)+1}]: $scom ="
    if {[catch {set line "$slin [expr $scom]"}]} {
      catch {set line "$slin [eval $scom]"}
    }
    puts -nonewline stdout "$line : "
    chan flush stdout
    gets stdin _
    puts {}
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
    GenerateEvent $win Motion -warp 1 -x $X -y $Y -state [dict get $opts -state]
  } else {
    GenerateEvent $win $ev {*}$opts
  }
  set line [lindex $dd(fcont) $dd(idx)+1]
  set time1 [Data %t [lrange $line 2 end]]
  if {!$time || ![string is integer -strict $time1] || $dd(ismacro)} {
    set aft idle
  } else {
    set aft [expr {max(0,$time1-$time)}]
  }
  after $aft ::playtkl::Playing
}
#_______________________

proc playtkl::GenerateEvent {win ev args} {
  # Generates an event for a widget.
  #   win - widget's path
  #   ev - event

  variable dd
  if {[winfo exists $win]} {
    if {$dd(ismacro)} {
      event generate $win <$ev> {*}$args
    } else {
      after idle [list after 0 event generate $win <$ev> {*}$args]
    }
  }
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
    set msg "playtkl: $msg: [clock format [clock seconds] -format {%T   %b %d, %Y}]"
    puts $msg
  } else {
    set msg {}
  }
  return $msg
}
#_______________________

proc playtkl::record {fname {endkey ""} {mouse yes} {details ""}} {
  # Starts the recording.
  #   fname - name of file to store the recording
  #   endkey - key to stop the recording
  #   mouse - "no" to disable  mouse events
  #   details - additional info on the recording

  variable fields
  variable dd
  set dd(isrec) yes
  set dd(mouse) $mouse
  set dd(details) [string map [list \n "\n# "] $details]
  if {![info exists dd(msgbeg)]} {
    foreach {o w} $fields {append opts " {%$w=$w}"}
    foreach ev {KeyPress KeyRelease ButtonPress ButtonRelease Motion MouseWheel} {
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

proc playtkl::readcontents {fname} {
  # Reads (updates) a log file's contents. Useful at changing the file manually.
  #   fname - file name

  variable dd
  catch {
    set ch [open $fname]
    set dd(fcont) [split [string trim [read $ch]] \n]
    close $ch
  }
}
#_______________________

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

proc playtkl::replay {{fname ""} {cbreplay ""} {mappings {}} {ismacro yes} {wfocus ""}} {
  # Replays a read/written recording, fastly at replaying a macro.
  #   fname - name of file to store the recording
  #   cbreplay - callback after replaying (e.g with "text edit separator")
  #   mappings - mappings of some widgets' pathes to currently used ones
  #   ismacro - yes for fast replaying a macro (used by playtkl)
  #   wfocus - currently focused widget

  variable dd
  if {$wfocus eq {}} {set wfocus [focus]}
  set dd(wfocus) $wfocus
  set dd(ismacro) $ismacro
  if {$fname ne {}} {readcontents $fname}
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
    foreach line $dd(fcont) {
      if {![regexp {^\s*#+} $line#]} { ;# skip empty or commented
        set ln [lrange $line 0 1]
        append ln " %t=0 " [lrange $line 3 end]
        lappend fcont $ln
      }
    }
    set dd(fcont) $fcont
  }
  inform Playing
  Playing
}

# ________________________ Game over _________________________ #

proc playtkl::end {{macrodetails ""}} {
  # Closes the recording/playing.
  #   macrodetails - comments to macro to be recorded

  variable dd
  set msgend [inform End]
  if {$dd(isrec)} {
    set dd(fcont) [lsort -index 2 -dictionary $dd(fcont)] ;# sort by time
    if {$msgend ne {}} {
      set details {}
      catch {append details "# $::argv0 $::argv"}
      append details "\n# $dd(details)"
      set tp "# Tcl v[info tclversion] : [info nameofexecutable]"
      foreach a [lsort [array names ::tcl_platform]] {
        append tp "\n# $a = " $::tcl_platform($a)
      }
      set dd(fcont) [linsert $dd(fcont) 0 $details # $tp # "# $dd(msgbeg)" "# $msgend" #]
    }
    if {$macrodetails ne {}} {
      set macrodetails #[string trim $macrodetails #\n]
      set dd(fcont) [linsert $dd(fcont) 0 [string map [list \n \n#] $macrodetails]]
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
