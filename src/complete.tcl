#! /usr/bin/env tclsh
###########################################################
# Name:    complete.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/27/2021
# Brief:   Handles auto completion.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval complete {
  variable comms [list]
}

# ________________________ Common _________________________ #

proc complete::TextCursorCoordinates {wtxt} {
  # Gets screen coordinates (X, Y) under cursor in a text.
  #   wtxt - text's path
  # Returns a list of X and Y coordinates.

  set ch [$wtxt get [$wtxt index insert] [$wtxt index {insert +1c}]]
  if {[string trim $ch] eq {}} {set pos {insert -1c}} {set pos insert}
  lassign [$wtxt bbox [$wtxt index $pos]] X Y w h
  incr X $w
  incr Y $h
  set p [winfo parent $wtxt]
  while 1 {
    lassign [split [winfo geometry $p] x+] w h x y
    incr X $x
    incr Y $y
    if {[catch {set p [winfo parent $p]}] || $p eq {.}} break
  }
  return [list $X $Y]
}
#_______________________

proc complete::AllSessionCommands {{currentTID ""}} {
  # Gets all commands available in Tcl/Tk and in session files.
  #   currentTID - ID of a current tab
  # If currentTID is set, the commands of this TID are shown unqualified.

  namespace upvar ::alited al al
  set res [list]
  foreach tab [alited::find::SessionList] {
    set TID [lindex $tab 0]
    if {![info exist al(_unittree,$TID)]} {
      alited::file::ReadFile $TID [alited::bar::FileName $TID]
    }
    foreach it $al(_unittree,$TID) {
      lassign $it lev leaf fl1 ttl l1 l2
      if {$leaf && [llength $ttl]==1} {
        if {$TID eq $currentTID} {
          lappend res [lindex [split $ttl :] end]
        } else {
          lappend res $ttl
        }
      }
    }
  }
  return $res
}
#_______________________

proc complete::MatchedCommands {} {
  # Gets commands that are matched to a current (under cursor) word.
  # Returns list of current word, begin and end of it, matched commands.

  lassign [alited::find::GetWordOfText noselect2] curword idx1 idx2
  if {![namespace exists ::alited::repl]} {
    namespace eval ::alited {
      source [file join $::alited::LIBDIR repl repl.tcl]
    }
  }
  set allcomms [lindex [::alited::repl::complete command {}] 1]
  lappend allcomms {*}[AllSessionCommands [alited::bar::CurrentTabID]]
  set comms [list]
  set excluded [list {[._]*} alimg_* bts_* \$*]
  foreach com $allcomms {
    set incl 1
    foreach ex $excluded {
      if {[string match $ex $com]} {
        set incl 0
        break
      }
    }
    if {$incl && [string match "${curword}*" $com]} {lappend comms $com}
  }
  return [list $curword $idx1 $idx2 [lsort $comms]]
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
  frame $win
  wm manage $win
  wm withdraw $win
  wm overrideredirect $win 1
  set obj pavedPickCommand
  ::apave::APaveInput create $obj $win
  $obj paveWindow $win {
    {LbxPick - - - - {pack -side left -expand 1 -fill both} {-h 16 -w 32 -lvar ::alited::complete::comms}}
    {sbvPick LbxPick L - - {pack -side left -fill both} {}}
  }
  set lbx [$obj LbxPick]
  foreach ev {ButtonPress-1 Return KP_Enter KeyPress-space} {
    catch {bind $lbx <$ev> "::alited::complete::SelectCommand $win $obj $lbx"}
  }
  $lbx selection set 0
  lassign [TextCursorCoordinates $wtxt] X Y
  set res [$obj showModal $win -decor 0 -focus $lbx -geometry +$X+$Y]
  destroy $win
  $obj destroy
  if {$res ne "0"} {return $res}
  return {}
}

# ________________________ Main _________________________ #

proc complete::AutoCompleteCommand {} {
  # Runs auto completion of commands.
  
  lassign [MatchedCommands] curword idx1 idx2 alited::complete::comms
  set wtxt [alited::main::CurrentWTXT]
  if {[set com [PickCommand $wtxt]] ne {}} {
    set TID [alited::bar::CurrentTabID]
    set row [expr {int([$wtxt index insert])}]
    $wtxt delete $row.$idx1 $row.[incr idx2]
    set pos $row.$idx1
    $wtxt insert $pos $com
  }
  focus -force $wtxt
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
