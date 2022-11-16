###########################################################
# Name:    complete.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/27/2021
# Brief:   Handles auto completion.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval complete {
  variable comms [list]   ;# list of available commands
  variable maxwidth 20    ;# maximum width of command
  variable tclcoms [list] ;# list of Tcl/Tk commands with arguments
}

# ________________________ Common _________________________ #

proc complete::TextCursorCoordinates {wtxt} {
  # Gets screen coordinates (X, Y) under cursor in a text.
  #   wtxt - text's path
  # Returns a list of X and Y coordinates.

  set poi [$wtxt index insert]
  set ch [$wtxt get $poi [$wtxt index {insert +1c}]]
  if {[string trim $ch] eq {}} {set pos {insert -1c}} {set pos insert}
  set pos [$wtxt index $pos]
  if {int($pos)!=int($poi)} {return -1}
  lassign [$wtxt bbox $pos] X Y w h
  if {$w eq {}} {return -1}
  incr X $w
  incr Y $h
  set p [winfo parent $wtxt]
  while 1 {
    lassign [split [winfo geometry $p] x+] w h x y
    incr X $x
    incr Y $y
    if {[catch {set p [winfo parent $p]}] || $p in {{} {.}}} break
  }
  return [list $X $Y]
}
#_______________________

proc complete::AllSessionCommands {{currentTID ""} {idx1 0}} {
  # Gets all commands available in Tcl/Tk and in session files.
  #   currentTID - ID of a current tab
  #   idx1 - starting position of the current word
  # If currentTID is set, the commands of this TID are shown unqualified.
  # Returns a list of "proc variables + commands" and a flag "with commands"

  namespace upvar ::alited al al
  if {[set isread [info exists al(_SessionCommands)]]} {
    unset al(_SessionCommands)
  } else {
    alited::info::Put $al(MC,wait) {} yes yes
    update
  }
  set al(_SessionCommands) [dict create]
  set res [list]
  # first, add variables
  set wtxt [alited::main::CurrentWTXT]
  lassign [alited::favor::CurrentName] itemID name l1 l2
  catch {
    # get variables from the current proc's header
    lassign [split [$wtxt get $l1.0 [expr {$l1+4}].0] \n] h1 h2 h3 h4
    foreach i {2 3 4} {
      incr l1
      if {[string index $h1 end] eq "\\"} {
        set h1 [string trimright $h1 \\]\ [set h$i]
      } else {
        break
      }
    }
    lassign [string trimright $h1 \{] typ - argums
    if {$typ in {proc method}} {
      foreach v $argums {
        lappend res \$[lindex $v 0]
      }
    }
  }
  # get variables from the current proc's body
  set RE \
{(?:(^|\[|\{)*\s*((set|unset|append|lappend|incr|variable|global)\s+|\$)([():a-zA-Z0-9,_\-]*))}
  foreach line [split [$wtxt get $l1.0 [incr l2].0] \n] {
    foreach {- - - - v} [regexp -all -inline $RE $line] {
      if {[string match *(* $v] || [string match *)* $v]} {
        if {![string match *(*) $v]} {
          set v [string trim $v ()]
        }
      }
      if {$v ne {} && [lsearch -exact $res $v]==-1} {lappend res \$$v}
    }
  }
  # if it's not a variable's value, add also commands
  set idx1 [expr {int([$wtxt index insert])}].$idx1
  if {[$wtxt get "$idx1 -1 c"] eq "\$"} {
    set withcomm no
  } else {
    set withcomm yes
    # get commands available in files of current session
    foreach tab [alited::find::SessionList] {
      set TID [lindex $tab 0]
      lassign [alited::main::GetText $TID no no] curfile wtxt
      foreach it $al(_unittree,$TID) {
        lassign $it lev leaf fl1 ttl l1 l2
        if {$leaf && [llength $ttl]==1} {
          if {$TID eq $currentTID} {
            set ttl [lindex [split $ttl :] end]
          }
          lappend res $ttl
          # save arguments of proc/method
          set h [alited::unit::GetHeader {} {} 0 $wtxt $ttl $l1 $l2]
          dict set al(_SessionCommands) $ttl [lindex [split $h \n] 0 2]
        }
      }
    }
    if {[llength $al(ED,TclKeyWords)]} {
      lappend res {*}$al(ED,TclKeyWords)  ;# user's commands
    }
  }
  if {!$isread} {alited::info::Clear end}
  return [list $res $withcomm]
}
#_______________________

proc complete::MatchedCommands {} {
  # Gets commands that are matched to a current (under cursor) word.
  # Returns list of current word, begin and end of it.

  variable comms
  variable maxwidth
  lassign [alited::find::GetWordOfText noselect2 yes] curword idx1 idx2
  if {![namespace exists ::alited::repl]} {
    namespace eval ::alited {
      source [file join $::alited::LIBDIR repl repl.tcl]
    }
  }
  lassign [AllSessionCommands [alited::bar::CurrentTabID] $idx1] allcomms withcomms
  if {$withcomms} {
    lappend allcomms {*}[lindex [::alited::repl::complete command {}] 1]
  }
  set comms [list]
  set excluded [list {[._]*} alimg_* bts_*]
  set maxwidth 20
  foreach com $allcomms {
    set incl 1
    foreach ex $excluded {
      if {[string match $ex $com]} {
        set incl 0
        break
      }
    }
    if {$incl && ([string match ${curword}* $com] || \
    [regexp "^\[\$\]?${curword}" $com])} {
      lappend comms $com
      set maxwidth [expr {max($maxwidth,[string length $com])}]
    }
  }
  set comms [lsort -dictionary -unique $comms]
  return [list $curword $idx1 $idx2]
}

# ________________________ GUI _________________________ #

proc complete::SelectCommand {win obj lbx} {
  # Handles a selection of command for auto completion.
  #   win - window of command list
  #   obj - apave object
  #   lbx - listbox's path

  $obj res $win [lindex $alited::complete::comms [$lbx curselection]]
}
#_______________________

proc complete::PickCommand {wtxt} {
  # Shows a frame of commands for auto completion,
  # allowing a user to select from it.
  #   wtxt - text's path

  if {![llength $alited::complete::comms]} {return {}}
  set win .pickcommand
  catch {destroy $win}
  if {$::alited::al(IsWindows)} {
    toplevel $win
  } else {
    frame $win
    wm manage $win
    # the line below is of an issue in kubuntu (KDE?): small sizes of the popup window
    set afterid [after idle [subst -nocom {wm geometry $win [regsub {([0-9]+x[0-9]+)} [wm geometry $win] 220x325]}]]
  }
  wm withdraw $win
  wm overrideredirect $win 1
  set obj pavedPickCommand
  catch {$obj destroy}
  ::apave::APaveInput create $obj $win
  $obj paveWindow $win {
    {LbxPick - - - - {pack -side left -expand 1 -fill both} {-h 16 -w $::alited::complete::maxwidth -lvar ::alited::complete::comms}}
    {#sbvPick LbxPick L - - {pack -side left -fill both} {}}
  }
  set lbx [$obj LbxPick]
  foreach ev {ButtonPress-1 Return KP_Enter KeyPress-space} {
    catch {bind $lbx <$ev> "after idle {::alited::complete::SelectCommand $win $obj $lbx}"}
  }
  $lbx selection set 0
  lassign [TextCursorCoordinates $wtxt] X Y
  if {$X==-1} {
    lassign [winfo pointerxy $wtxt] X Y  ;# popup at mouse pointer (not at caret)
  }
  if {$::alited::al(IsWindows)} {
    incr X 10
    incr Y 40
    after 100 "wm deiconify $win"
  }
  set res [$obj showModal $win -focus $lbx -geometry +$X+$Y -ontop yes]
  destroy $win
  $obj destroy
  if {$res ne "0"} {return $res}
  return {}
}

# ________________________ Main _________________________ #

proc complete::AutoCompleteCommand {} {
  # Runs auto completion of commands.

  namespace upvar ::alited al al
  variable tclcoms
  if {![llength $tclcoms]} {
    set tclcoms [::hl_tcl::hl_commands]
    foreach cmd {exit break continue pwd pid} {
      # these commands mostly without arguments: below, don't add { } after them
      if {[set i [lsearch -exact $tclcoms $cmd]]>-1} {
        set tclcoms [lreplace $tclcoms $i $i]
      }
    }
  }
  lassign [MatchedCommands] curword idx1 idx2
  set wtxt [alited::main::CurrentWTXT]
  if {[set com [PickCommand $wtxt]] ne {}} {
    set row [expr {int([$wtxt index insert])}]
    if {[$wtxt get "$row.$idx1 -1 c"] eq "\$"} {
      incr idx1 -1
    } elseif {[string match \$* $com]} {
      set com [string range $com 1 end]
    }
    $wtxt delete $row.$idx1 $row.[incr idx2]
    set pos $row.$idx1
    if {[dict exists $al(_SessionCommands) $com]
    && [set argums [dict get $al(_SessionCommands) $com]] ne {}} {
      # add all of the unit's arguments
      catch {
        foreach ar $argums {
          if {[llength $ar]==1} {
            append com " \$$ar"
          } else {
            append com " {\$$ar}" ;# default value to be seen
          }
        }
      }
    } elseif {$com in $tclcoms} {
      append com { }
    }
    $wtxt insert $pos $com
    ::alited::main::HighlightLine
  }
  focus -force $wtxt
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
