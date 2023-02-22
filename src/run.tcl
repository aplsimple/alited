###########################################################
# Name:    run.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/14/2023
# Brief:   Handles "Tool/Run..." menu item.
# License: MIT.
###########################################################

namespace eval run {}

# ________________________ Options _________________________ #


proc run::SaveRunOptions {} {
  # Saves options of "Run..." dialogue.

  namespace upvar ::alited al al
  set al(_SavedRunOptions_) [list \
    $al(prjincons) $al(comForce) $al(comForceLs) $al(comForceCh) $al(prjbeforerun)]
}
#_______________________

proc run::RestoreRunOptions {} {
  # Restores options of "Run..." dialogue.

  namespace upvar ::alited al al
  lassign $al(_SavedRunOptions_) \
    al(prjincons) al(comForce) al(comForceLs) al(comForceCh) al(prjbeforerun)
}
#_______________________

proc run::SetRunOptions {{mode ""} {com ""} {ch1 ""} {befrun ""}} {
  # Sets options of "Run..." dialogue.
  #   mode - selected mode (forced command / RUNF)
  #   com - forced command
  #   ch1 - check of 1st checkbox
  #   befrun - commands run before

  namespace upvar ::alited al al obDl2 obDl2
  if {$mode eq {}} {
    set cbx [$obDl2 CbxfiL]
    set mode [Mode]
    set com [$cbx get]
    set befrun [[$obDl2 Tex2] get 1.0 end]
    set al(comForceLs) [$cbx cget -values]
    set ch1 $al(TMPchb1)
  }
  set al(prjincons) $mode
  set al(comForce) [string trim $com]
  set i [lsearch -exact $al(comForceLs) $com]
  set al(comForceLs) [lreplace $al(comForceLs) $i $i]
  if {[llength $al(comForceLs)]<2} {set al(comForceLs) [list {}]}
  set al(comForceLs) [linsert $al(comForceLs) 1 $com]
  set al(comForceLs) [lrange $al(comForceLs) 0 $al(prjmaxcoms)]
  set al(comForceCh) $ch1
  set al(prjbeforerun) [string map [list \n $alited::EOL] [string trim $befrun]]
}

# ________________________ Run, test _________________________ #

proc run::Mode {} {
  # Gets a mode of run (in console or in Tkcon).
  # Returns 1 if it's in console.

  namespace upvar ::alited al al obDl2 obDl2
  set mode [set [[$obDl2 Rad1] cget -variable]]
  return [expr {$mode eq $al(MC,inconsole)}]
}
#_______________________

proc run::Run {} {
  # Runs a command of "Run..." dialogue

  namespace upvar ::alited al al
  if {![alited::file::IsTcl [alited::bar::FileName]]} {
    set in {}
  } elseif {$al(prjincons)} {
    set in terminal
  } else {
    set in tkcon
  }
  alited::tool::_run {} $in
}
#_______________________

proc run::Test {} {
  # Tests a command of "Run..." dialogue

  SetRunOptions
  Run
}

# ________________________ GUI _________________________ #


proc run::InitTex12 {tex1 tex2 cbx} {
  # Initializes texts & combobox (colors, events, highlighting etc.).
  #   tex1 - 1st text's path
  #   tex2 - 2nd text's path
  #   cbx - compobox's path

  namespace upvar ::alited al al obDl2 obDl2
  ::hl_tcl::hl_init $tex1 -dark [$obDl2 csDark] -plaintext 1 \
    -cmd ::alited::run::FillCbx -cmdpos ::alited::run::FillCbx \
    -font $al(FONT) -insertwidth $al(CURSORWIDTH)
  ::hl_tcl::hl_text $tex1
  ::hl_tcl::hl_init $tex2 -dark [$obDl2 csDark] -plaintext 1 \
    -font $al(FONT) -insertwidth $al(CURSORWIDTH) \
    -cmdpos ::alited::None
  ::hl_tcl::hl_text $tex2
  bind $tex1 <FocusIn> {set alited::al(run_checkmaxcomms) 1}
  bind $cbx <FocusOut> alited::run::FillTex1
  bind $cbx <<ComboboxSelected>> alited::run::FillTex1
  ChbForced 0
}
#_______________________

proc run::FillTex1 {args} {
  # Fills command content text.

  namespace upvar ::alited al al obDl2 obDl2
  set tex1 [$::alited::obDl2 Tex1]
  set tex2 [$::alited::obDl2 Tex2]
  set cbx [$obDl2 CbxfiL]
  if {$al(_startRunDialogue)} {
    set al(_startRunDialogue) no
    InitTex12 $tex1 $tex2 $cbx
  }
  if {!$al(TMPchb1)} {
    $obDl2 displayText $tex1 [[$::alited::obDl2 Ent] get]
    return
  }
  if {[focus] eq $tex1} return
  set com [$cbx get]
  set coms {}
  set l1 0
  foreach c [$cbx cget -values] {
    incr l
    set c [string trim $c]
    if {$c eq $com && !$l1} {set l1 $l}
    if {$c ne {}} {
      append coms $c\n\n
    }
  }
  if {$l1} {
    catch {::tk::TextSetCursor $tex1 $l1.0}
  } else {
    set coms $com\n\n$coms
  }
  $obDl2 displayText $tex1 $coms
}
#_______________________

proc run::FillCbx {args} {
  # Fill the command combobox.

  namespace upvar ::alited al al obDl2 obDl2
  if {!$al(TMPchb1)} return
  set tex1 [$::alited::obDl2 Tex1]
  if {!$al(TMPchb1) || [focus] ne $tex1} return
  set cbx [$obDl2 CbxfiL]
  set lst [list]
  set curline {}
  set l1 [expr {int([$tex1 index insert])}]
  foreach line [split [$tex1 get 1.0 end] \n] {
    incr l
    if {$l==1 || [set line [string trim $line]] ne {}} {
      lappend lst $line
    }
    if {$l==$l1} {
      set curline $line
    }
  }
  set llen [llength $lst]
  if {$llen<$al(prjmaxcoms)} {
    alited::Message {}
  } else {
    if {[info exists al(run_checkmaxcomms)] && $al(run_checkmaxcomms)} {
      set mm 4 ;# bell + red message
    } else {
      set mm 6 ;# only red message
    }
    set al(run_checkmaxcomms) 0
    set msg [msgcat::mc {Maximum commands reached: %n, current: %i (see Project/Options)}]
    alited::Message [string map [list %i $llen %n $al(prjmaxcoms)] $msg] $mm
  }
  if {[lindex $lst 0] ne {}} {set lst [linsert $lst 0 {}]}
  $cbx configure -values $lst
  set curline [string trim $curline]
  if {$curline ne {}} {
    $cbx set $curline
  }
  SetRunOptions
}
#_______________________

proc run::DeleteForcedRun {} {
  # Clears current combobox' value.

  namespace upvar ::alited al al obDl2 obDl2
  set cbx [$obDl2 CbxfiL]
  if {[set val [string trim [$cbx get]]] eq {}} return
  set values [$cbx cget -values]
  if {[set i [lsearch -exact $values $val]]>-1} {
    set al(comForceLs) [lreplace $values $i $i]
    $cbx configure -values $al(comForceLs)
  }
  $cbx set {}
}
#_______________________

proc run::ChbForced {chb} {
  # Sets checkbuttons' value for RunDialogue.
  #   chb - number of checkbutton (1 or 2)
  # See also: RunDialogue

  namespace upvar ::alited al al obDl2 obDl2
  if {$chb==1} {
    set al(TMPchb2) [expr {!$al(TMPchb1)}]
  } elseif {$chb==2} {
    set al(TMPchb1) [expr {!$al(TMPchb2)}]
  }
  set cbx [$obDl2 CbxfiL]
  set tex [$obDl2 Tex1]
  if {$al(TMPchb1)} {
    $cbx configure -state normal
  } else {
    $cbx configure -state disabled
  }
  $tex configure -state [$cbx cget -state]
  FillTex1
}
#_______________________

proc run::RunDialogue {} {
  # Dialogue to define a command for "Tools/Run"

  namespace upvar ::alited al al obDl2 obDl2
  set al(_startRunDialogue) yes
  set lr 20
  set filler [string repeat { } $lr]
  set head \n\ [alited::bar::FileName]
  set prompt0 [string range $al(MC,run):$filler 0 $lr]
  set prompt1 [string range [msgcat::mc {By command:}]$filler 0 $lr]
  set prompt2 [string range [msgcat::mc {By command #RUNF:}]$filler 0 $lr]
  if {[catch {
    if {[lindex $al(comForceLs) 0] eq {-}} {
      set al(comForceLs) [lreplace $al(comForceLs) 0 0]  ;# legacy
    }
    if {[lindex $al(comForceLs) 0] ne {}} {
      set i [lsearch $al(comForceLs) {}]
      set al(comForceLs) [lreplace $al(comForceLs) $i $i]
      set al(comForceLs) [linsert $al(comForceLs) 0 {}]  ;# to allow blank value
    }
  }]} {
    set al(comForceLs) [list]
  }
  if {$al(prjincons)} {
    set vrad $al(MC,inconsole)
  } else {
    set vrad $al(MC,intkcon)
  }
  set fname [alited::bar::FileName]
  if {![llength $al(comForceLs)] && $fname ne $al(MC,nofile)} {
    set al(comForceLs) [list {} $fname]
  }
  set al(TMPchb1) $al(comForceCh)
  set al(TMPchb2) [expr {!$al(TMPchb1)}]
  lassign [alited::tool::RunArgs] ar rf
  set vent "$ar$rf"
  set run [string map [list $alited::EOL \n] $al(prjbeforerun)]
  lassign [$obDl2 input {} $al(MC,run) [list \
    Rad [list $prompt0 {}] [list $vrad $al(MC,inconsole) $al(MC,intkcon)] \
    seh1 {{} {-pady 5}} {} \
    FiL [list $prompt1 {-fill x} [list -h 12 -cbxsel $::alited::al(comForce) -clearcom alited::run::DeleteForcedRun -tip {-BALTIP ! -COMMAND {[$::alited::obDl2 CbxfiL] get} -UNDER 2 -PER10 0}]] [list $al(comForce) {*}$al(comForceLs)] \
    chb1 [list {} {-padx 5} {-toprev 1 -t {Run it} -var alited::al(TMPchb1) -com {alited::run::ChbForced 1}}] $al(TMPchb1) \
    Ent [list $prompt2 {-fill x -pady 5} [list -state disabled -tip {-BALTIP ! -COMMAND {[$::alited::obDl2 Ent] get} -UNDER 2 -PER10 0}]] "{$vent}" \
    chb2 [list {} {-padx 5} {-toprev 1 -t {Run it} -var alited::al(TMPchb2) -com {alited::run::ChbForced 2}}] $al(TMPchb2) \
    Tex1 "{} {} {-w 80 -h 9 -tabnext *Tex2 -afteridle alited::run::FillTex1}" {} \
    seh3 {{} {-pady 5}} {} \
    lab {{} {} {-t { OS or Tcl commands to be run before running a current file:}}} {} \
    Tex2 "{} {} {-w 80 -h 9 -tabnext *OK}" $run \
  ] -head $head -weight bold -help {alited::tool::HelpTool %w 2} -buttons {butTest Test ::alited::run::Test}] \
  res mode com - - - - befrun
  set mode [expr {$mode eq $al(MC,inconsole)}]
  set res [list $res $mode $com $al(TMPchb1) $befrun]
  unset -nocomplain al(TMPchb2)
  unset -nocomplain al(TMPchb1)
  return $res
}
#_______________________

proc run::RunDlg {} {
  # Runs "Before Run" dialogue and does its chosen action.

  SaveRunOptions
  lassign [RunDialogue] res mode com ch1 befrun
  if {$res} {
    SetRunOptions $mode $com $ch1 $befrun
    alited::ini::SaveIniPrj
    alited::main::UpdateProjectInfo
  } else {
    RestoreRunOptions
  }
  return $res
}

# ________________________ EOF _________________________ #

#! let this commented stuff be a code snippet for tracing apave variables, huh:
#proc run::TraceComForce {name1 name2 op} {
#  # Traces al(comForce) to enable/disable the text field in "Before Run" dialogue.
#
#  namespace upvar ::alited obDl2 obDl2
#  catch {
#    set txt [$obDl2 Tex2]
#    if {[set $name1] eq {}} {set st normal} {set st disabled}
#    $txt configure -state $st
#    $obDl2 makePopup $txt no yes
#    set cbx [$obDl2 CbxfiL]
#    if {[focus] ne $cbx && $st eq {disabled}} {
#      after 300 "focus $cbx"
#    }
#  }
#  return {}
#}

#! let this commented stuff be a code snippet for tracing apave variables, huh:
#  after idle [list after 0 " \
#    set tvar \[$obDl2 varName cbx\] ;\
#    trace add variable \$tvar write ::alited::run::TraceComForce ;\
#    set \$tvar \[set \$tvar\]
#  "]
