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

  # flag "at opening the dialogue"
  variable atopen yes
}

# ________________________ Checking _________________________ #

proc check::ShowResults {} {
  # Displays results of checking.

  variable errors
  variable fileerrors
  variable atopen
  if {$errors || $fileerrors} {
    set msg [msgcat::mc {Found %f file error(s), %u unit error(s).}]
    set msg [string map [list %f $fileerrors %u $errors] $msg]
    if {$atopen} bell
  } else {
    set msg [msgcat::mc {No errors found.}]
  }
  alited::info::Put $msg {} yes
  set atopen no
}
#_______________________

proc check::PosInfo {TID pos1} {
  # Gets an info on a unit's position (for Put procedure).
  #   TID - tab's ID
  #   pos1 - starting position of the unit in the text
  # Returns a list of TID and the normalized unit's position.
  # See also: info::Put

  if {$TID eq {}} {
    set res {}
  } else {
    set res [list $TID [expr {[string is double -strict $pos1] ? int($pos1) : 1}]]
  }
  return $res
}
#_______________________

proc check::CheckUnit {wtxt pos1 pos2 {TID ""} {title ""} {bold no} {see no}} {
  # Checks a unit.
  #   wtxt - text's path
  #   pos1 - starting position of the unit in the text
  #   pos2 - ending position of the unit in the text
  #   TID - tab's ID
  #   title - title of the unit
  #   bold - if yes, displays errors bolded
  #   see - if yes, displays errors in red color
  # See also: info::Put

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
  set mapB1 [list "{\[}" {}] ;# skip this usage (not regexp's alas)
  set mapB2 [list "{\]}" {}]
  set mapP1 [list "{\(}" {}]
  set mapP2 [list "{\)}" {}]
  set mapQ [list "{\"}" {}]
  foreach line [split [$wtxt get $pos1 $pos2] \n] {
    if {[string match -nocase *#*alited*check* $line] \
    ||  [string match -nocase *#*check*alited* $line]} {
      # if a line is "checked by alited", skip this unit as checked by a human
      return 0
    }
    if {$chBrace} {
      incr cc1 [::apave::countChar $line \{]
      incr cc2 [::apave::countChar $line \}]
    }
    if {$chBracket} {
      incr ck1 [::apave::countChar [string map $mapB1 $line] \[]
      incr ck2 [::apave::countChar [string map $mapB2 $line] \]]
    }
    if {$chParenthesis} {
      incr cp1 [::apave::countChar [string map $mapP1 $line] (]
      incr cp2 [::apave::countChar [string map $mapP2 $line] )]
    }
    if {$chQuotes} {
      incr cq1 [::apave::countChar [string map $mapQ $line] \"]
    }
  }
  set err 0
  set arg [list [PosInfo $TID $pos1] $bold $see]
  if {$cc1 != $cc2} {
    incr err
    incr errors1
    if {$TID ne {}} {alited::info::Put "$title: inconsistent \{\}: $cc1 != $cc2" {*}$arg}
  }
  if {$ck1 != $ck2} {
    incr err
    incr errors2
    if {$TID ne {}} {alited::info::Put "$title: inconsistent \[\]: $ck1 != $ck2" {*}$arg}
  }
  if {$cp1 != $cp2} {
    incr err
    incr errors3
    if {$TID ne {}} {alited::info::Put "$title: inconsistent (): $cp1 != $cp2" {*}$arg}
  }
  if {$cq1 % 2} {
    incr err
    incr errors4
    if {$TID ne {}} {alited::info::Put "$title: inconsistent \"\": $cq1" {*}$arg}
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
  if {$fname ne [alited::bar::FileName] && ![alited::file::IsTcl $fname]} {
    # do check only a current file and Tcl scripts
    return
  }
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
      if {$prevtitle eq $title && $title ni {constructor destructor}} {
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
  variable atopen
  variable errors
  variable fileerrors
  alited::info::Clear
  alited::info::Put $al(MC,wait) {} yes yes
  set errors [set fileerrors 0]
  if {$atopen || $what==1} {  ;# at start, check a current file
    CheckFile
  } elseif {$what==2} {
    CheckAll
  }
  ShowResults
}

# ________________________ Button handlers _________________________ #

proc check::Cancel {args} {
  # Handles hitting "Cancel" button.

  namespace upvar ::alited al al
  variable win
  set al(checkgeo) [wm geometry $win]
  alited::CloseDlg
  destroy $win
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
    {chb1 labHead T 1 1 {-st sw -pady 1 -padx 22} {-var ::alited::check::chBrace -t {Consistency of {} }}}
    {chb2 + T 1 1 {-st sw -pady 5 -padx 22} {-var ::alited::check::chBracket -t {Consistency of []}}}
    {chb3 + T 1 1 {-st sw -pady 1 -padx 22} {-var ::alited::check::chParenthesis -t {Consistency of ()}}}
    {chb4 + T 1 1 {-st sw -pady 5 -padx 22} {-var ::alited::check::chQuotes -t {Consistency of ""}}}
    {chb9 + T 1 1 {-st sw -pady 1 -padx 22} {-var ::alited::check::chDuplUnits -t {Duplicate units}}}
    {v_2 + T}
    {fra + T 1 1 {-st nsew -pady 0 -padx 3} {-padding {5 5 5 5} -relief groove}}
    {fra.lab - - - - {pack -side left} {-t "Check:"}}
    {fra.radA - - - - {pack -side left -padx 9}  {-t "current file" -var ::alited::check::what -value 1}}
    {fra.radB - - - - {pack -side left -padx 9}  {-t "all of session files" -var ::alited::check::what -value 2}}
    {fra2 fra T 1 1 {-st nsew -pady 3 -padx 3} {-padding {5 5 5 5} -relief groove}}
    {.ButHelp - - - - {pack -side left} {-t {$al(MC,help)} -tip F1 -com ::alited::check::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.ButOK - - - - {pack -side left -padx 2} {-t "Check" -com ::alited::check::Check}}
    {.butCancel - - - - {pack -side left} {-t Cancel -com ::alited::check::Cancel}}
  }
  bind $win <F1> "[$obCHK ButHelp] invoke"
  if {[set geo $al(checkgeo)] ne {}} {
    set geo [string range $geo [string first + $geo] end]
    set geo "-geometry $geo"
  }
  $obCHK showModal $win -modal no -waitvar no -onclose alited::check::Cancel \
    -focus [$obCHK ButOK] {*}$geo -ontop [::isKDE]
}

proc check::_run {} {
  # Runs "Checking" dialogue.

  namespace upvar ::alited al al obCHK obCHK
  variable win
  variable atopen
  set atopen yes
  if {[::apave::repaintWindow $win "$obCHK ButOK"]} {
    wm deiconify $win
  } else {
    after idle alited::check::Check
    _create
  }
}
# _________________________________ EOF _________________________________ #
