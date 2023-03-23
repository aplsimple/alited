###########################################################
# Name:    run.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/14/2023
# Brief:   Handles "Tool/Run..." menu item.
# License: MIT.
###########################################################

namespace eval run {
  variable win .alwin.rundlg
  variable vent {}
}

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

proc run::RunOptions {args} {
  # Sets options of "Run..." dialogue.

  namespace upvar ::alited al al obRun obRun
  set cbx [$obRun CbxfiL]
  set com [$cbx get]
  set al(comForceLs) [$cbx cget -values]
  set befrun [[$obRun Tex2] get 1.0 end]
  set al(comForce) [string trim $com]
  set i [lsearch -exact $al(comForceLs) $com]
  set al(comForceLs) [lreplace $al(comForceLs) $i $i]
  if {[llength $al(comForceLs)]<2} {set al(comForceLs) [list {}]}
  set al(comForceLs) [linsert $al(comForceLs) 1 $com]
  set al(comForceLs) [lrange $al(comForceLs) 0 $al(prjmaxcoms)]
  set al(prjbeforerun) [string map [list \n $alited::EOL] [string trim $befrun]]
}

# ________________________ Button commands _________________________ #

proc run::Run {} {
  # Runs a command of "Run..." dialogue.

  namespace upvar ::alited al al
  variable win
  wm attributes $win -topmost 0  ;# let Run dialogue be hidden
  RunOptions
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

proc run::Save {} {
  # Saves settings of "Run..." dialogue.

  namespace upvar ::alited al al obRun obRun
  variable win
  set al(runGeometry) [wm geometry $win]
  RunOptions
  SaveRunOptions
  alited::ini::SaveIniPrj
  alited::main::UpdateProjectInfo
  catch {$obRun res $win 1}
}
#_______________________

proc run::Cancel {args} {
  # Handles hitting "Cancel" button.

  namespace upvar ::alited al al obRun obRun
  variable win
  RestoreRunOptions
  catch {
    set al(runGeometry) [wm geometry $win]
    $obRun res $win 0
  }
}
#_______________________

proc run::Help {} {
  # Shows Run's help.

  variable win
  wm attributes $win -topmost 1  ;# let Run dialogue be not hidden
  alited::tool::HelpTool %w 2
}

# ________________________ GUI _________________________ #


proc run::InitTex12 {tex1 tex2 cbx} {
  # Initializes texts & combobox (colors, events, highlighting etc.).
  #   tex1 - 1st text's path
  #   tex2 - 2nd text's path
  #   cbx - compobox's path

  namespace upvar ::alited al al obRun obRun
  ::hl_tcl::hl_init $tex1 -dark [$obRun csDark] -plaintext 1 \
    -cmd ::alited::run::FillCbx -cmdpos ::alited::run::FillCbx \
    -font $al(FONT) -insertwidth $al(CURSORWIDTH) -dobind yes
  ::hl_tcl::hl_text $tex1
  ::hl_tcl::hl_init $tex2 -dark [$obRun csDark] -plaintext 1 \
    -font $al(FONT) -insertwidth $al(CURSORWIDTH) \
    -cmdpos ::alited::None -dobind yes
  ::hl_tcl::hl_text $tex2
  bind $tex1 <FocusIn> {set alited::al(run_checkmaxcomms) 1}
  bind $cbx <FocusOut> alited::run::FillTex1
  bind $cbx <<ComboboxSelected>> alited::run::FillTex1
  ChbForced
}
#_______________________

proc run::FillTex1 {args} {
  # Fills command content text.

  namespace upvar ::alited al al obRun obRun
  set tex1 [$::alited::obRun Tex1]
  set tex2 [$::alited::obRun Tex2]
  set cbx [$obRun CbxfiL]
  if {$al(_startRunDialogue)} {
    set al(_startRunDialogue) no
    InitTex12 $tex1 $tex2 $cbx
  }
  if {!$al(comForceCh)} {
    $obRun displayText $tex1 [[$::alited::obRun Ent] get]
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
  $obRun displayText $tex1 $coms
}
#_______________________

proc run::FillCbx {args} {
  # Fill the command combobox.

  namespace upvar ::alited al al obRun obRun
  if {!$al(comForceCh)} return
  set tex1 [$::alited::obRun Tex1]
  if {!$al(comForceCh) || [focus] ne $tex1} return
  set cbx [$obRun CbxfiL]
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
    selection clear -displayof $cbx
    $cbx selection range 0 end
  }
  RunOptions
}
#_______________________

proc run::DeleteForcedRun {} {
  # Clears current combobox' value.

  namespace upvar ::alited al al obRun obRun
  set cbx [$obRun CbxfiL]
  if {[set val [string trim [$cbx get]]] eq {}} return
  set values [$cbx cget -values]
  if {[set i [lsearch -exact $values $val]]>-1} {
    set al(comForceLs) [lreplace $values $i $i]
    $cbx configure -values $al(comForceLs)
  }
  $cbx set {}
}
#_______________________

proc run::ChbForced {} {
  # Check buttons' value for RunDialogue.

  namespace upvar ::alited al al obRun obRun
  set cbx [$obRun CbxfiL]
  set tex [$obRun Tex1]
  set ent [$obRun Ent]
  if {$al(comForceCh)} {
    $cbx configure -state normal
    $ent configure -state disabled
  } else {
    $cbx configure -state disabled
    $ent configure -state normal
  }
  $tex configure -state [$cbx cget -state]
  FillTex1
}
#_______________________

proc run::RunDialogue {} {
  # Dialogue to define a command for "Tools/Run".

  namespace upvar ::alited al al obRun obRun
  variable win
  variable vent
  SaveRunOptions
  set al(_startRunDialogue) yes
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
  set fname [alited::bar::FileName]
  if {![llength $al(comForceLs)] && $fname ne $al(MC,nofile)} {
    set al(comForceLs) [list {} $fname]
  }
  lassign [alited::tool::RunArgs] ar rf
  set vent "$ar$rf"
  set run [string map [list $alited::EOL \n] $al(prjbeforerun)]
  $obRun makeWindow $win.fra $al(MC,run)
  $obRun paveWindow $win.fra {
    {h_ - - 1 5} \
    {lab T + 1 1 {-st e -pady 5} {-t Run:}} \
    {Rad1 + L 1 2 {} {-tvar alited::al(MC,inconsole) -value 1 -var alited::al(prjincons)}} \
    {rad2 + L 1 1 {} {-tvar alited::al(MC,intkcon) -value 0 -var alited::al(prjincons)}} \
    {seh1 lab T 1 5 {-pady 5}} \
    {rad3 + T 1 1 {-st w -padx 4} {-t {By command #RUNF:} -value 0 -var alited::al(comForceCh) -com alited::run::ChbForced}} \
    {Ent + L 1 4 {-st ew -pady 5} {-state disabled -tip {-BALTIP ! -COMMAND {[$::alited::obRun Ent] get} -UNDER 2 -PER10 0} -tvar alited::run::vent}} \
    {rad4 rad3 T 1 1 {-st w -padx 4} {-t {By command:} -value 1 -var alited::al(comForceCh) -com alited::run::ChbForced}} \
    {FiL + L 1 4 {-st ew} {-h 12 -cbxsel "$alited::al(comForce)" -clearcom alited::run::DeleteForcedRun -values "$alited::al(comForceLs)"}} \
    {fra1 rad4 T 1 5 {-st nsew -cw 1 -rw 1}} \
    {.Tex1 - - - - {pack -side left -fill both -expand 1} {-w 40 -h 9 -tabnext *Tex2 -afteridle alited::run::FillTex1 -tabnext *tex2}} \
    {.sbv + L - - {pack -side left}} \
    {seh3 fra1 T 1 5 {-pady 5}} \
    {lab2 + T 1 5 {} {-t { OS or Tcl commands to be run before running a current file:}}} \
    {fra2 + T 1 5 {-st nsew}} \
    {.Tex2 - - - - {pack -side left -fill both -expand 1} {-w 40 -h 4 -tabnext *OK}} \
    {.sbv + L - - {pack -side left}} \
    {seh2 fra2 T 1 5 {-pady 5}} \
    {butHelp + T 1 1 {-st w -padx 2} {-t Help -com alited::run::Help}} \
    {h_2 + L 1 2 {-st ew}} \
    {fra3 + L 1 2 {-st e}} \
    {.butRun - - 1 1 {-padx 2} {-t Run -com alited::run::Run}} \
    {.butSave + L 1 1 {} {-t Save -com alited::run::Save}} \
    {.butCancel + L 1 1 {-padx 2} {-t Cancel -com alited::run::Cancel}} \
  }
  bind $win <F1> alited::run::Help
  bind $win <F5> alited::run::Run
  set geo $al(runGeometry)
  if {$geo ne {}} {set geo "-geometry $geo"}
  $obRun showModal $win -modal no -waitvar yes -onclose alited::run::Cancel -resizable 1 -focus [$obRun Rad1] -decor 1 -minsize {300 200} {*}$geo
  catch {destroy $win}
  ::apave::deiconify $al(WIN)
}
#_______________________

proc run::RunDlg {} {

  variable win
  if {[winfo exists $win]} {
    ::apave::withdraw $win
    ::apave::deiconify $win
  } else {
    RunDialogue
  }
}

# ________________________ EOF _________________________ #

#! let this commented stuff be a code snippet for tracing apave variables, huh:
#proc run::TraceComForce {name1 name2 op} {
#  # Traces al(comForce) to enable/disable the text field in "Before Run" dialogue.
#
#  namespace upvar ::alited obRun obRun
#  catch {
#    set txt [$obRun Tex2]
#    if {[set $name1] eq {}} {set st normal} {set st disabled}
#    $txt configure -state $st
#    $obRun makePopup $txt no yes
#    set cbx [$obRun CbxfiL]
#    if {[focus] ne $cbx && $st eq {disabled}} {
#      after 300 "focus $cbx"
#    }
#  }
#  return {}
#}

#! let this commented stuff be a code snippet for tracing apave variables, huh:
#  after idle [list after 0 " \
#    set tvar \[$obRun varName cbx\] ;\
#    trace add variable \$tvar write ::alited::run::TraceComForce ;\
#    set \$tvar \[set \$tvar\]
#  "]
