###########################################################
# Name:    complete.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/27/2021
# Brief:   Handles auto completion.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval complete {
  variable win .pickcommand
  variable comms [list]   ;# list of available commands
  variable commsorig [list]
  variable word {}
  variable wordorig {}
  variable obj {}
  variable maxwidth 20    ;# maximum width of command
  variable tclcoms [list] ;# list of Tcl/Tk commands with arguments
}

# ________________________ Common _________________________ #

proc complete::CursorCoordsChar {wtxt shift} {
  # Gets cursor's screen coordinates and a character under cursor in a text.
  #   wtxt - text's path
  #   shift - shift from the cursor where to get non-empty char
  # Returns a list of X, Y coordinates and a character under the cursor.

  set poi [$wtxt index insert]
  set ch [$wtxt get $poi [$wtxt index {insert +1c}]]
  set nl [expr {int($poi)}]
  if {[$wtxt get $nl.0 $nl.end] eq {}} {
    lassign [$wtxt bbox insert] X Y - h
    set w 0
    set ch -
  } else {
    if {[string trim $ch] eq {}} {set pos "insert $shift"} {set pos insert}
    set pos [$wtxt index $pos]
    lassign [$wtxt bbox $pos] X Y w h
  }
  if {$h eq {}} {set X [set Y [set w [set h 0]]]}
  incr X $w
  incr Y $h
  set p [winfo parent $wtxt]
  while 1 {
    lassign [split [winfo geometry $p] x+] w h x y
    incr X $x
    incr Y $y
    if {[catch {set p [winfo parent $p]}] || $p in {{} {.}}} break
  }
  return [list $X $Y $ch]
}
#_______________________

proc complete::TextCursorCoordinates {wtxt} {
  # Gets cursor's screen coordinates under cursor in a text.
  # Also, sets the focus on the text (to make this task be possible at all).
  #   wtxt - text's path
  # Returns a list of X and Y coordinates.

  focus $wtxt
  set res [CursorCoordsChar $wtxt {}]
  lassign $res X Y ch
  if {$ch eq {} || $ch eq "\n"} {
    # EOL => get a previous char's coordinates
    set res [CursorCoordsChar $wtxt -1c]
  }
  return $res
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
{(?:(((^\s*|\[\s*|\{\s*)+((set|unset|append|lappend|incr|variable|global)\s+))|\$)([:a-zA-Z0-9_]*[\(]*[:a-zA-Z0-9_,\$]*[\)]*))}
  foreach line [split [$wtxt get $l1.0 [incr l2].0] \n] {
    foreach {- - - - - - v} [regexp -all -inline $RE $line] {
      if {[string match *(* $v] || [string match *)* $v]} {
        if {![string match *(*) $v]} {
          set v [string trim $v ()]
        }
      }
      if {$v ni {{} : ::} && [lsearch -exact $res $v]==-1} {
        if {![string match \$* $v]} {set v \$$v}
        lappend res $v
      }
    }
  }
  set idx1 [expr {int([$wtxt index insert])}].$idx1
  set isdol [expr {[$wtxt get "$idx1 -1 c"] eq {$}}]
  set isdol1 [expr {[$wtxt get "$idx1 -2 c" $idx1] eq {$:}}]
  set isdol2 [expr {[$wtxt get "$idx1 -3 c" $idx1] eq {$::}}]
  if {$isdol1 || $isdol2} {
    foreach v [info vars ::*] {
      if {[llength $v]==1} {lappend res \$$v}
    }
  }
  # if it's not a variable's value, add also commands
  if {$isdol || $isdol1 || $isdol2} {
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
          catch {dict set al(_SessionCommands) $ttl [lindex [split $h \n] 0 2]}
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

proc complete::IsMatch {curword com} {
  # Check matching a word to a command.
  #   curword - the word
  #   com - the command

  return [expr {[string match ${curword}* $com] || \
    [string match ${curword}* [namespace tail $com]] || \
    [regexp "^\[\$\]?${curword}" $com]}]
}
#_______________________

proc complete::MatchedCommands {{curword ""} args} {
  # Gets commands that are matched to a current (under cursor) word.
  #   curword - current word to match
  #   args - contains idx1, idx2 indices
  # Returns list of current word, begin and end of it.

  variable comms
  variable commsorig
  variable maxwidth
  if {$curword eq {}} {
    lassign [alited::find::GetWordOfText noselect2 yes] curword idx1 idx2
  } else {
    lassign $args idx1 idx2
  }
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
    if {$incl && [IsMatch $curword $com]} {
      lappend comms $com
      set maxwidth [expr {max($maxwidth,[string length $com])}]
    }
  }
  set commsorig $comms
  set comms [lsort -dictionary -unique $comms]
  return [list $curword $idx1 $idx2]
}

# ________________________ GUI _________________________ #

proc complete::SelectCommand {obj lbx} {
  # Handles a selection of command for auto completion.
  #   obj - apave object
  #   lbx - listbox's path

  variable win
  $obj res $win [lindex $::alited::complete::comms [$lbx curselection]]
}
#_______________________

proc complete::WinGeometry {lht} {
  # Checks and corrects the completion window's geometry (esp. for KDE).
  #   lht - height of completion list

  variable win
  update
  lassign [split [wm geometry $win] x+] w h x y
  set h2 [winfo reqheight $win]
  if {$h2>20} {
    wm geometry $win ${w}x${h2}+${x}+${y}
  } else {
    wm geometry $win 220x325+${x}+${y}
  }
}
#_______________________

proc complete::PickCommand {wtxt} {
  # Shows a frame of commands for auto completion,
  # allowing a user to select from it.
  #   wtxt - text's path

  variable win
  variable obj
  variable word
  variable comms
  variable commsorig
  variable wordorig
  if {[set llen [llength $comms]]==0} {return {}}
  set word $wordorig
  # check for variables if any exist
  for {set il 0; set icv -1} {$il<$llen}  {incr il} {
    set cv [lindex $comms $il]
    if {[string first \$ $cv]<0} break
    if {$cv eq "\$$wordorig"} {set icv $il}
  }
  if {$icv>=0 && $il>1 && [string length $wordorig]==1} {
    set i 0
    foreach c $commsorig {if {$c eq "\$wordorig"} {incr i}}
    if {$i<2} { ;# 1 occurence of 1 letter => remove it
      set comms [lreplace $comms $icv $icv]
      incr llen -1
      incr il -1
    }
  }
  set commsorig $comms
  set mlen 16
  set lht [expr {max(min($llen,$mlen),1)}]
  set obj ::alited::pavedPickCommand
  catch {destroy $win}
  if {$::alited::al(IsWindows)} {
    toplevel $win
  } else {
    frame $win
    wm manage $win
    # the line below is of an issue in kubuntu (KDE?): small sizes of the popup window
    after idle [list ::alited::complete::WinGeometry $lht]
  }
  wm withdraw $win
  wm overrideredirect $win 1
  catch {$obj destroy}
  ::apave::APave create $obj $win
  set lwidgets [list \
    "Ent - - - - {pack -expand 1 -fill x} {-w $::alited::complete::maxwidth -tvar ::alited::complete::word -validate key -validatecommand {alited::complete::PickValid $wtxt %V %d %i %s %S}}" \
    "fra - - - - {pack -expand 1 -fill both}" \
    ".Lbx - - - - {pack -side left -expand 1 -fill both} {-h $lht -w $::alited::complete::maxwidth -lvar ::alited::complete::comms -exportselection 0}"
  ]
  if {$llen>$mlen} {
    # add vertical scrollbar if number of items exceeds max.height
    lappend lwidgets {.sbvPick + L - - {pack -side left -fill both} {}}
  }
  $obj paveWindow $win $lwidgets
  set ent [$obj Ent]
  set lbx [$obj Lbx]
  foreach ev {ButtonPress-1 Return KP_Enter KeyPress-space} {
    catch {bind $lbx <$ev> "after idle {::alited::complete::SelectCommand $obj $lbx}"}
  }
  ColorPick $wtxt
  $lbx selection set 0
  lassign [TextCursorCoordinates $wtxt] X Y
  if {$::alited::al(IsWindows)} {
    incr X 10
    incr Y 40
    after 100 "wm deiconify $win"
  }
  after idle "alited::CursorAtEnd $ent"
  bind $ent <Return> {+ alited::complete::EntReturn}
  bind $win <FocusOut> {alited::complete::PickFocusOut %W}
  set res [$obj showModal $win -focus $ent -modal no -geometry +$X+$Y]
  destroy $win
  $obj destroy
  if {$res ne "0"} {return $res}
  return {}
}
#_______________________

proc complete::ColorPick {wtxt} {
  # Sets colors for pick list.
  #   wtxt - text's path

  variable obj
  variable comms
  set lbx [$obj Lbx]
  set llen [llength $comms]
  lassign [::hl_tcl::hl_colors $wtxt] fgcom - - fgvar
  set i 0
  foreach com $comms {
    if {[string index $com 0] eq {$}} {
      $lbx itemconfigure $i -foreground $fgvar  ;# variable
    } else {
      $lbx itemconfigure $i -foreground $fgcom  ;# command
    }
    incr i
  }
}
#_______________________

proc complete::EntReturn {} {
  # Handles pressing Return on entry.

  variable win
  variable obj
  variable word
  set lbx [$obj Lbx]
  set idx [$lbx curselection]
  if {$idx eq {} || [set com [$lbx get $idx]] eq {}} {
    set com $word
  }
  if {$com ne {}} {$obj res $win $com}
}
#_______________________

proc complete::PickValid {wtxt V d i s S} {
  # Validates the word picker's input.
  #   wtxt - text's path
  #   V - %V of -validatecommand: validation condition
  #   d - %d of -validatecommand: 1 for insert, 0 for delete
  #   i - %i of -validatecommand: index of character
  #   s - %s of -validatecommand: current value of entry
  #   S - %S of -validatecommand: string being inserted/deleted

  variable win
  variable obj
  variable comms
  variable commsorig
  variable wordorig
  if {$V eq {focusin}} {
    alited::CursorAtEnd [$obj Ent]
  }
  switch $d {
    0 {
      set curword [string replace $s $i $i]
      set lc [string length $curword]
      if {$lc && $lc<[string length $wordorig]} {
        $obj res $win [list _alited_ $curword] ;# to remake the list
      }
    }
    1 {
      set curword [string range $s 0 $i]$S[string range $s $i end]
      if {[string length $curword]==1 && $curword ne $wordorig} {
        $obj res $win [list _alited_ $curword] ;# to remake the list
      }
    }
  }
  if {$d != -1} {
    set fltcomms [list]
    foreach com $commsorig {
      if {[IsMatch $curword $com]} {
        lappend fltcomms $com
      }
    }
    set comms $fltcomms
    ColorPick $wtxt
    update
  }
  catch {
    set lbx [$obj Lbx]
    $lbx selection clear 0 end
    $lbx selection set 0
    $lbx activate 0
    $lbx see 0
    lassign [$obj csGet] - - - - - bg fg
    $lbx itemconfigure 0 -selectbackground $bg -selectforeground $fg
  }
  return 1
}
#_______________________

proc complete::PickFocusOut {w} {
  # Closes the word picker at "focus out" event.
  #   w - a current widget

  variable win
  variable obj
  if {[focus] ni [list [$obj Ent] [$obj Lbx]]} {
    $obj res $win 0
  }
}

# ________________________ Main _________________________ #

proc complete::AutoCompleteCommand {} {
  # Runs auto completion of commands.

  namespace upvar ::alited al al
  variable tclcoms
  variable wordorig
  set wtxt [alited::main::CurrentWTXT]
  set pos [$wtxt index insert]
  set row [expr {int($pos)}]
  set charsOn [$wtxt get "$pos -1 char" "$pos +1 char"]
  set leftpart [string trim [$wtxt get $row.0 $pos]]
  if {$al(acc_19) eq {Tab} && (![regexp {[[:alnum:]_]} $charsOn] || $leftpart eq {})} {
    # (if the cursor isn't over a word)
    # Tab is the indentation on the line's beginning or Tab char otherwise
    if {$leftpart eq {}} {
      lassign [alited::main::CalcIndentation $wtxt] pad padchar
      $wtxt insert $pos [string repeat $padchar $pad]
    } else {
      $wtxt insert $pos \t
    }
    return
  }
  if {![llength $tclcoms]} {
    set tclcoms [::hl_tcl::hl_commands]
    foreach cmd {exit break continue pwd pid} {
      # these commands mostly without arguments: below, don't add { } after them
      if {[set i [lsearch -exact $tclcoms $cmd]]>-1} {
        set tclcoms [lreplace $tclcoms $i $i]
      }
    }
  }
  lassign [MatchedCommands] wordorig idx1 idx2
  while 1 {
    set com [PickCommand $wtxt]
    if {[llength $com]==2 && [lindex $com 0] eq {_alited_}} {
      set wordorig [lindex $com 1]
      MatchedCommands $wordorig $idx1 $idx2
    } else {
      break
    }
  }
  if {$com ne {}} {
    set isvar [string match \$* $com]
    if {[$wtxt get "$row.$idx1 -1 c"] eq "\$"} {
      incr idx1 -1
    } elseif {[$wtxt get "$row.$idx1 -2 c" $row.$idx1] eq "\$:"} {
      incr idx1 -2
    } elseif {[$wtxt get "$row.$idx1 -3 c" $row.$idx1] eq "\$::"} {
      incr idx1 -3
    } elseif {[$wtxt get $row.$idx1] eq "\$"} {
      # replace $variable
    } elseif {$isvar} {
      set com [string range $com 1 end]
    }
    $wtxt delete $row.$idx1 $row.[incr idx2]
    set pos $row.$idx1
    if {!$isvar} {
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
    }
    $wtxt insert $pos $com
    ::alited::main::HighlightLine
  }
  focus -force $wtxt
}
# _________________________________ EOF _________________________________ #
