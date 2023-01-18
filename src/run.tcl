###########################################################
# Name:    run.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/14/2023
# Brief:   Handles "Tool/Run..." menu item.
# License: MIT.
###########################################################

namespace eval run {}

#! let this commented stuff be a code snippet for tracing apave variables, huh:
#proc run::TraceComForce {name1 name2 op} {
#  # Traces al(comForce) to enable/disable the text field in "Before Run" dialogue.
#
#  namespace upvar ::alited obDl2 obDl2
#  catch {
#    set txt [$obDl2 Tex]
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
##_______________________

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

  namespace upvar ::alited al al
  if {$chb==1} {
    set al(TMPchb2) [expr {!$al(TMPchb1)}]
  } else {
    set al(TMPchb1) [expr {!$al(TMPchb2)}]
  }
}
#_______________________

proc run::RunDialogue {} {
  # Dialogue to define a command for "Tools/Run"

  namespace upvar ::alited al al obDl2 obDl2
  set lr 20
  set filler [string repeat { } $lr]
  set head \n\ [alited::bar::FileName]
  set prompt0 [string range $al(MC,run):$filler 0 $lr]
  set prompt1 [string range [msgcat::mc {By command:}]$filler 0 $lr]
  set prompt2 [string range [msgcat::mc {By command #RUNF:}]$filler 0 $lr]
  if {[lindex $al(comForceLs) 0] eq {-}} {
    set al(comForceLs) [lreplace $al(comForceLs) 0 0]  ;# legacy
  }
  if {[lindex $al(comForceLs) 0] ne {}} {
    set i [lsearch $al(comForceLs) {}]
    set al(comForceLs) [lreplace $al(comForceLs) $i $i]
    set al(comForceLs) [linsert $al(comForceLs) 0 {}]  ;# to allow blank value
  }
#! let this commented stuff be a code snippet for tracing apave variables, huh:
#  after idle [list after 0 " \
#    set tvar \[$obDl2 varName cbx\] ;\
#    trace add variable \$tvar write ::alited::run::TraceComForce ;\
#    set \$tvar \[set \$tvar\]
#  "]
  if {$al(prjincons)} {
    set vrad $al(MC,inconsole)
  } else {
    set vrad $al(MC,intkcon)
  }
  if {[alited::tool::ComForced]} {
    set al(TMPchb1) 1
    set al(TMPchb2) 0
  } else {
    set al(TMPchb1) 0
    set al(TMPchb2) 1
  }
  lassign [alited::tool::RunArgs] ar rf
  set vent "$ar$rf"
  set run [string map [list $alited::EOL \n] $al(prjbeforerun)]
  lassign [$obDl2 input {} $al(MC,run) [list \
    rad1 [list $prompt0 {}] [list $vrad $al(MC,inconsole) $al(MC,intkcon)] \
    seh1 {{} {-pady 5}} {} \
    fiL [list $prompt1 {-fill x} [list -h 12 -cbxsel $::alited::al(comForce) -clearcom alited::run::DeleteForcedRun]] [list $al(comForce) {*}$al(comForceLs)] \
    chb1 [list {} {-padx 5} {-toprev 1 -t {Run it} -var alited::al(TMPchb1) -com {alited::run::ChbForced 1}}] $al(TMPchb1) \
    ent [list $prompt2 {-fill x -pady 5} [list -state disabled]] "{$vent}" \
    chb2 [list {} {-padx 5} {-toprev 1 -t {Run it} -var alited::al(TMPchb2) -com {alited::run::ChbForced 2}}] $al(TMPchb2) \
    seh2 {{} {-pady 5}} {} \
    lab {{} {} {-t { OS or Tcl commands to be run before running a current file:}}} {} \
    Tex "{} {} {-w 80 -h 9 -tabnext *OK}" $run \
  ] -head $head -weight bold -help {alited::tool::HelpTool %w 2}] \
  res mode com - - - run
  set mode [expr {$mode eq $al(MC,inconsole)}]
  set res [list $res $mode $com $al(TMPchb1) $run]
  unset al(TMPchb2)
  unset al(TMPchb1)
  return $res
}

#_______________________

proc run::RunDlg {} {
  # Runs "Before Run" dialogue and does its chosen action.

  namespace upvar ::alited al al
  set savForceLs $al(comForceLs)
  lassign [RunDialogue] res mode com ch1 run
  if {!$res} {
    set al(comForceLs) $savForceLs
  } else {
    set al(prjincons) $mode
    set al(comForce) [string trim $com]
    set i [lsearch -exact $al(comForceLs) $com]
    set al(comForceLs) [lreplace $al(comForceLs) $i $i]
    if {[llength $al(comForceLs)]<2} {set al(comForceLs) [list {}]}
    set al(comForceLs) [linsert $al(comForceLs) 1 $com]
    set al(comForceLs) [lrange $al(comForceLs) 0 $al(INI,RECENTFILES)]
    set al(comForceCh) $ch1
    set al(prjbeforerun) [string map [list \n $alited::EOL] [string trim $run]]
    alited::ini::SaveIniPrj
    alited::main::UpdateProjectInfo
  }
  return $res
}
