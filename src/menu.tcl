#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The menu procedures.
# _______________________________________________________________________ #

namespace eval menu {}

# ________________________ procs _________________________ #

proc menu::CheckMenuItems {} {
  # Disables/enables "File/Close All..." menu items.

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  foreach idx {8 9 10} {
    if {[alited::bar::BAR isTab $TID]} {
      set dsbl [alited::bar::BAR checkDisabledMenu $al(BID) $TID [incr item]]
    } else {
      set dsbl yes
    }
    if {$dsbl} {
      set state "-state disabled"
    } else {
      set state "-state normal"
    }
    $al(MENUFILE) entryconfigure $idx {*}$state
  }
}

proc menu::FillMenu {} {
  # Populates alited's main menu.

  namespace upvar ::alited al al

## ________________________ File _________________________ ##
  set m [set al(MENUFILE) $al(WIN).menu.file]
  $m add command -label $al(MC,new) -command alited::file::NewFile -accelerator Ctrl+N
  $m add command -label $al(MC,open...) -command alited::file::OpenFile -accelerator Ctrl+O
  $m add separator
  $m add command -label $al(MC,save) -command alited::file::SaveFile -accelerator $al(acc_0)
  $m add command -label $al(MC,saveas...) -command alited::file::SaveFileAs -accelerator $al(acc_1)
  $m add command -label $al(MC,saveall) -command alited::file::SaveAll -accelerator Ctrl+Shift+S
  $m add separator
  $m add command -label $al(MC,close) -command alited::file::CloseFileMenu
  $m add command -label $al(MC,clall) -command {alited::file::CloseAll 1}
  $m add command -label $al(MC,clallleft) -command {alited::file::CloseAll 2}
  $m add command -label $al(MC,clallright) -command {alited::file::CloseAll 3}
  $m add separator
  $m add command -label $al(MC,restart) -command {alited::Exit - 1}
  $m add separator
  $m add command -label $al(MC,quit) -command alited::Exit

## ________________________ Edit _________________________ ##
  set m [set al(MENUEDIT) $al(WIN).menu.edit]
  $m add command -label $al(MC,moveupU) -command {alited::main::MoveItem up yes} -accelerator $al(acc_15)
  $m add command -label $al(MC,movedownU) -command {alited::main::MoveItem down yes} -accelerator $al(acc_16)
  $m add separator
  $m add command -label $al(MC,indent) -command alited::unit::Indent -accelerator $al(acc_6)
  $m add command -label $al(MC,unindent) -command alited::unit::UnIndent -accelerator $al(acc_7)
  $m add separator
  $m add command -label $al(MC,comment) -command alited::unit::Comment -accelerator $al(acc_8)
  $m add command -label $al(MC,uncomment) -command alited::unit::UnComment -accelerator $al(acc_9)
  $m add separator
  $m add command -label $al(MC,findreplace) -command alited::find::_run -accelerator Ctrl+F
  $m add command -label $al(MC,findnext) -command alited::find::Next -accelerator $al(acc_12)
  $m add command -label [msgcat::mc "Look for declaration"] -command alited::find::SearchUnit -accelerator $al(acc_13)
  $m add command -label [msgcat::mc "Look for word"] -command alited::find::SearchWordInSession -accelerator $al(acc_14)

## ________________________ Tools _________________________ ##
  set m [set al(TOOLS) $al(WIN).menu.tool]
  $m add command -label $al(MC,run) -command alited::tool::_run -accelerator $al(acc_3)
  $m add command -label "e_menu" -command alited::tool::_run -accelerator $al(acc_2)
  $m add command -label $al(MC,checktcl) -command alited::check::_run

## ________________________ Setup _________________________ ##
  set m [set al(SETUP) $al(WIN).menu.setup]
  $m add command -label $al(MC,projects) -command alited::project::_run
  $m add command -label $al(MC,tpl) -command alited::unit::Add
  $m add separator
  $m add command -label $al(MC,pref...) -command alited::pref::_run

## ________________________ Help _________________________ ##
  set m [set al(MENUHELP) $al(WIN).menu.help]
  $m add command -label "$al(MC,help) Tcl/Tk" -command alited::tool::Help -accelerator F1
  $m add separator
  $m add command -label $al(MC,about...) -command alited::HelpAbout
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
