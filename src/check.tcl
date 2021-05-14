#! /usr/bin/env tclsh
#
# Name:    check.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    05/13/2021
# Brief:   Handles checkings Tcl code.
# License: MIT.

# _________________________ Variables ________________________ #

namespace eval check {
  variable win $::alited::al(WIN).fraCheck
  variable chBrace 1
  variable chBracket 1
  variable chParenthesis 1
  variable what 1
  variable errors 0 errors1 0 errors2 0 errors3 0 fileerrors 0
}

# ________________________ Display _________________________ #

proc check::Help {args} {
  variable win
  alited::Help $win
}

proc check::ShowResults {} {
  variable errors
  variable fileerrors
  if {$errors || $fileerrors} {
    set msg [msgcat::mc "Found %f file error(s), %u unit error(s)."]
    set msg [string map [list %f $fileerrors %u $errors] $msg]
  } else {
    set msg [msgcat::mc "No errors found."]
  }
  alited::info::Put $msg "" yes
}

# ________________________ Checking _________________________ #

proc check::CheckUnit {wtxt pos1 pos2 {TID ""} {title ""}} {
  variable chBrace 1
  variable chBracket 1
  variable chParenthesis 1
  variable errors1
  variable errors2
  variable errors3
  set cc1 [set cc2 [set ck1 [set ck2 [set cp1 [set cp2 0]]]]]
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
  }
  set err 0
  if {$TID ne ""} {
    set info [list $TID [expr {[string is double -strict $pos1] ? int($pos1) : 1}]]
  }
  if {$cc1 != $cc2} {
    incr err
    incr errors1
    if {$TID ne ""} {alited::info::Put "$title: inconsistent \{\}: $cc1 != $cc2" $info}
  }
  if {$ck1 != $ck2} {
    incr err
    incr errors2
    if {$TID ne ""} {alited::info::Put "$title: inconsistent \[\]: $ck1 != $ck2" $info}
  }
  if {$cp1 != $cp2} {
    incr err
    incr errors3
    if {$TID ne ""} {alited::info::Put "$title: inconsistent (): $cp1 != $cp2" $info}
  }
  return $err
}

proc check::CheckFile {{fname ""} {wtxt ""} {TID ""}} {
  variable errors
  variable fileerrors
  variable errors1
  variable errors2
  variable errors3
  if {$fname eq ""} {
    set fname [alited::bar::FileName]
    set wtxt [alited::main::CurrentWTXT]
    set TID [alited::bar::CurrentTabID]
  }
  if {![alited::file::IsTcl $fname]} return
  set curfile [file tail $fname]
  set textcont [$wtxt get 1.0 end]
  set errors1 [set errors2 [set errors3 0]]
  set fileerrs [CheckUnit $wtxt 1.0 end]
  incr fileerrors $fileerrs
  set und [string repeat _ 30]
  set pos1 [alited::bar::GetTabState $TID --pos]
  set info [list $TID [expr {int($pos1)}]]
  alited::info::Put "$und $fileerrs ($errors1/$errors2/$errors3) file errors of $curfile $und$und$und" $info
  set unittree [alited::unit::GetUnits $TID $textcont]
  foreach item $unittree {
    lassign $item lev leaf fl1 title l1 l2
    if {!$leaf || $title eq ""} continue
    set title "$curfile: $title"
    set err [CheckUnit $wtxt $l1.0 $l2.end $TID $title]
    if {$err} {
      incr errors $err
#      alited::info::Put "$title: $err errors" [list $fname $l1 $l2]
    }
  }
}
proc check::CheckAll {} {
  namespace upvar ::alited al al
  update
  set allfnd [list]
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    if {![info exist al(_unittree,$TID)]} {
      alited::file::ReadFile $TID [alited::bar::FileName $TID]
    }
    lassign [alited::main::GetText $TID] curfile wtxt
    CheckFile $curfile $wtxt $TID
  }
}

proc check::Check {} {
  namespace upvar ::alited al al
  variable what
  variable errors
  variable fileerrors
  alited::info::Clear
  alited::info::Put $al(MC,wait) "" yes
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
  namespace upvar ::alited obDl2 obDl2
  variable win
  $obDl2 res $win 1
  return
}

proc check::Cancel {args} {
  namespace upvar ::alited obDl2 obDl2
  variable win
  $obDl2 res $win 0
}

# ________________________ Main _________________________ #

proc check::_create {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable win
  $obDl2 makeWindow $win $al(MC,checktcl)
  $obDl2 paveWindow $win {
    {v_ - -}
    {labHead v_ T 1 1 {-st w -pady 4 -padx 8} {-t "Checks available:"}}
    {chb1 labHead T 1 1 {-st sw -pady 1 -padx 22} {-var alited::check::chBrace -t "Consistency of \{\}"}}
    {chb2 chb1 T 1 1 {-st sw -pady 5 -padx 22} {-var alited::check::chBracket -t "Consistency of \[\]"}}
    {chb3 chb2 T 1 1 {-st sw -pady 1 -padx 22} {-var alited::check::chParenthesis -t "Consistency of ()"}}
    {v_2 chb3 T}
    {fra v_2 T 1 1 {-st nsew -pady 0 -padx 3} {-padding {5 5 5 5} -relief groove}}
    {fra.lab - - - - {pack -side left} {-t "Check:"}}
    {fra.radA - - - - {pack -side left -padx 9}  {-t "current file" -var ::alited::check::what -value 1}}
    {fra.radB - - - - {pack -side left -padx 9}  {-t "all of session files" -var ::alited::check::what -value 2}}
    {fra2 fra T 1 1 {-st nsew -pady 3 -padx 3} {-padding {5 5 5 5} -relief groove}}
    {.butHelp - - - - {pack -side left} {-t "Help" -command ::alited::check::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.ButOK - - - - {pack -side left -padx 2} {-t "Check" -command ::alited::check::Ok}}
    {.butCancel - - - - {pack -side left} {-t Cancel -command ::alited::check::Cancel}}
  }
  set res [$obDl2 showModal $win -decor 1 -resizable {0 0} -focus [$obDl2 ButOK] \
    -onclose alited::check::Cancel]
  destroy $win
  return $res
}

proc check::_run {} {
  if {[_create]} Check
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
