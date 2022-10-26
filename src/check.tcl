###########################################################
# Name:    check.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles checkings Tcl code.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval check {

  # "Check" dialogue's path
  variable win $::alited::al(WIN).diaCheck

  # flags to check braces, brackets, parenthesis
  variable chBrace 1
  variable chBracket 1
  variable chParenthesis 1
  variable chQuotes 1
  variable chDuplUnits 1

  # what to check: 1 - current file, 2 - all files
  variable what 1

  # counts for errors in units and in whole files
  variable errors 0 errors1 0 errors2 0 errors3 0 errors4 0 fileerrors 0
}

# ________________________ Checking _________________________ #

proc check::ShowResults {} {
  # Displays results of checking.

  variable errors
  variable fileerrors
  if {$errors || $fileerrors} {
    set msg [msgcat::mc {Found %f file error(s), %u unit error(s).}]
    set msg [string map [list %f $fileerrors %u $errors] $msg]
  } else {
    set msg [msgcat::mc {No errors found.}]
  }
  alited::info::Put $msg {} yes
}
#_______________________

proc check::PosInfo {TID pos1} {
  # Gets an info on a unit's position (for Put procedure).
  #   TID - tab's ID
  #   pos1 - starting position of the unit in the text
  # Returns a list of TID and the normalized unit's position.
  # See also: ::alited::info::Put

  if {$TID eq {}} {
    set res {}
  } else {
    set res [list $TID [expr {[string is double -strict $pos1] ? int($pos1) : 1}]]
  }
  return $res
}
#_______________________

proc check::CheckUnit {wtxt pos1 pos2 {TID ""} {title ""}} {
  # Checks a unit.
  #   wtxt - text's path
  #   pos1 - starting position of the unit in the text
  #   pos2 - ending position of the unit in the text
  #   TID - tab's ID
  #   title - title of the unit

  variable chBrace
  variable chBracket
  variable chParenthesis
  variable chQuotes
  variable chDuplUnits
  variable errors1
  variable errors2
  variable errors3
  variable errors4
  set cc1 [set cc2 [set ck1 [set ck2 [set cp1 [set cp2 [set cq1 0]]]]]]
  foreach line [split [$wtxt get $pos1 $pos2] \n] {
    if {$chBrace} {
      incr cc1 [::apave::countChar $line \{]
      incr cc2 [::apave::countChar $line \}]
    }
    if {$chBracket} {
      incr ck1 [::apave::countChar $line \[]
      incr ck2 [::apave::countChar $line \]]
    }
    if {$chParenthesis} {
      incr cp1 [::apave::countChar $line (]
      incr cp2 [::apave::countChar $line )]
    }
    if {$chQuotes} {
      incr cq1 [::apave::countChar $line \"]
    }
  }
  set err 0
  set info [PosInfo $TID $pos1]
  if {$cc1 != $cc2} {
    incr err
    incr errors1
    if {$TID ne {}} {alited::info::Put "$title: inconsistent \{\}: $cc1 != $cc2" $info}
  }
  if {$ck1 != $ck2} {
    incr err
    incr errors2
    if {$TID ne {}} {alited::info::Put "$title: inconsistent \[\]: $ck1 != $ck2" $info}
  }
  if {$cp1 != $cp2} {
    incr err
    incr errors3
    if {$TID ne {}} {alited::info::Put "$title: inconsistent (): $cp1 != $cp2" $info}
  }
  if {$cq1 % 2} {
    incr err
    incr errors4
    if {$TID ne {}} {alited::info::Put "$title: inconsistent \"\": $cq1" $info}
  }
  return $err
}
#_______________________

proc check::CheckFile {{fname ""} {wtxt ""} {TID ""}} {
  # Checks a file.
  #   fname - file name
  #   wtxt - the file's text widget
  #   TID - the file's tab ID

  variable errors
  variable fileerrors
  variable errors1
  variable errors2
  variable errors3
  variable errors4
  variable chDuplUnits
  if {$fname eq {}} {
    set fname [alited::bar::FileName]
    set wtxt [alited::main::CurrentWTXT]
    set TID [alited::bar::CurrentTabID]
  }
  if {![alited::file::IsTcl $fname]} return
  set curfile [file tail $fname]
  set textcont [$wtxt get 1.0 end]
  set unittree [alited::unit::GetUnits $TID $textcont]
  # check for errors of a whole file
  set errors1 [set errors2 [set errors3 [set errors4 0]]]
  set fileerrs [CheckUnit $wtxt 1.0 end]
  # check for duplicate units
  set errduplist [list]
  if {$chDuplUnits} {
    set prevtitle "\{\$\}"
    set errmsg [msgcat::mc {duplicate unit:}]
    set uniterr 0
    foreach item [lsort -index 3 $unittree] {
      lassign $item lev leaf fl1 title l1
      if {$prevtitle eq $title} {
        set uniterr 1
        lappend errduplist [list "$curfile: $errmsg $title" $l1]
      }
      set prevtitle $title
    }
    if {!$fileerrs} {set fileerrs $uniterr}
  }
  # put a whole file's statistics on errors
  incr fileerrors $fileerrs
  set und [string repeat _ 30]
  set pos1 [alited::bar::GetTabState $TID --pos]
  if {![string is double -strict $$pos1]} {set pos1 1.0}
  set info [list $TID [expr {int($pos1)}]]
  alited::info::Put "$und $fileerrs ($errors1/$errors2/$errors3/$errors4) file errors of $curfile $und$und$und" $info
  # put a list of duplicate units
  foreach errdup $errduplist {
    lassign $errdup msg pos1
    alited::info::Put $msg [PosInfo $TID $pos1]
  }
  # check for errors of specific units
  foreach item $unittree {
    lassign $item lev leaf fl1 title l1 l2
    if {!$leaf || $title eq {}} continue
    set title "$curfile: $title"
    set err [CheckUnit $wtxt $l1.0 $l2.end $TID $title]
    if {$err} {
      incr errors $err
    }
  }
}
#_______________________

proc check::CheckAll {} {
  # Checks all files of session.

  update
  set allfnd [list]
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    lassign [alited::main::GetText $TID] curfile wtxt
    CheckFile $curfile $wtxt $TID
  }
}
#_______________________

proc check::Check {} {
  # Runs checking.

  namespace upvar ::alited al al
  variable what
  variable errors
  variable fileerrors
  alited::info::Clear
  alited::info::Put $al(MC,wait) {} yes yes
  set errors [set fileerrors 0]
  switch $what {
    1 CheckFile
    2 CheckAll
  }
  alited::info::Clear 0
  ShowResults
}

# ________________________ Button handlers _________________________ #

proc check::Ok {args} {
  # Handles hitting "OK" button.

  namespace upvar ::alited obCHK obCHK
  variable win
  alited::CloseDlg
  $obCHK res $win 1
}
#_______________________

proc check::Cancel {args} {
  # Handles hitting "Cancel" button.

  namespace upvar ::alited obCHK obCHK
  variable win
  alited::CloseDlg
  $obCHK res $win 0
}
#_______________________

proc check::Help {args} {
  # Handles hitting "Help" button.

  variable win
  alited::Help $win
}

# ________________________ Main _________________________ #

proc check::_create {} {
  # Creates "Checking" dialogue.

  namespace upvar ::alited al al obCHK obCHK
  variable win
  catch {destroy $win}
  $obCHK makeWindow $win.fra $al(MC,checktcl)
  $obCHK paveWindow $win.fra {
    {v_ - -}
    {labHead v_ T 1 1 {-st w -pady 4 -padx 8} {-t "Checks available:"}}
    {chb1 labHead T 1 1 {-st sw -pady 1 -padx 22} {-var alited::check::chBrace -t {Consistency of {} }}}
    {chb2 chb1 T 1 1 {-st sw -pady 5 -padx 22} {-var alited::check::chBracket -t {Consistency of []}}}
    {chb3 chb2 T 1 1 {-st sw -pady 1 -padx 22} {-var alited::check::chParenthesis -t {Consistency of ()}}}
    {chb4 chb3 T 1 1 {-st sw -pady 5 -padx 22} {-var alited::check::chQuotes -t {Consistency of ""}}}
    {chb9 chb4 T 1 1 {-st sw -pady 1 -padx 22} {-var alited::check::chDuplUnits -t {Duplicate units}}}
    {v_2 chb9 T}
    {fra v_2 T 1 1 {-st nsew -pady 0 -padx 3} {-padding {5 5 5 5} -relief groove}}
    {fra.lab - - - - {pack -side left} {-t "Check:"}}
    {fra.radA - - - - {pack -side left -padx 9}  {-t "current file" -var ::alited::check::what -value 1}}
    {fra.radB - - - - {pack -side left -padx 9}  {-t "all of session files" -var ::alited::check::what -value 2}}
    {fra2 fra T 1 1 {-st nsew -pady 3 -padx 3} {-padding {5 5 5 5} -relief groove}}
    {.ButHelp - - - - {pack -side left} {-t {$alited::al(MC,help)} -tip F1 -command ::alited::check::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.ButOK - - - - {pack -side left -padx 2} {-t "Check" -command ::alited::check::Ok}}
    {.butCancel - - - - {pack -side left} {-t Cancel -command ::alited::check::Cancel}}
  }
  bind $win <F1> "[$obCHK ButHelp] invoke"
  if {[set geo $al(checkgeo)] ne {}} {
    set geo [string range $geo [string first + $geo] end]
    set geo "-geometry $geo"
  }
  set res [$obCHK showModal $win -resizable no -focus [$obCHK ButOK] \
    {*}$geo -modal no -onclose alited::check::Cancel]
  set al(checkgeo) [wm geometry $win]
  if {!$res} {destroy $win}
  return $res
}

proc check::_run {} {
  # Runs "Checking" dialogue.

  variable win
  if {[winfo exists $win]} {
    focus -force $win
    return
  }
  while {1} {
    if {[_create]} {
      Check
    } else {
      break
    }
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
