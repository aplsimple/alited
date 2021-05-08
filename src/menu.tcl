#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The menu procedures.
# _______________________________________________________________________ #

namespace eval menu {}

proc menu::FillMenu {} {
  # Populates alited's main menu.

  namespace upvar ::alited al al
  set m [set al(MENUFILE) $al(WIN).menu.file]
  $m add command -label "New" -command alited::file::NewFile -accelerator Ctrl+N
  $m add command -label "Open..." -command alited::file::OpenFile -accelerator Ctrl+O
  $m add separator
  $m add command -label "Save" -command alited::file::SaveFile -accelerator F2
  $m add command -label "Save As..." -command alited::file::SaveFileAs -accelerator Ctrl+S
  $m add command -label "Save All" -command alited::file::SaveAll -accelerator Shift+Ctrl+S
  $m add separator
  $m add command -label "Close" -command alited::file::CloseFileMenu
  $m add command -label "Close All" -command {alited::file::CloseAll 1}
  $m add command -label "Close All at Left" -command {alited::file::CloseAll 2}
  $m add command -label "Close All at Right" -command {alited::file::CloseAll 3}
  $m add separator
  $m add command -label "Preferences..." -command alited::pref::Preferences
  $m add separator
  $m add command -label "Restart" -command alited::Restart
  $m add separator
  $m add command -label "Quit" -command alited::Exit
  set m [set al(MENUEDIT) $al(WIN).menu.edit]
  $m add command -label "Move Unit Up" -command {alited::main::MoveItem up yes} -accelerator F11
  $m add command -label "Move Unit Down" -command {alited::main::MoveItem down yes} -accelerator F12
  $m add separator
  $m add command -label "Indent" -command alited::unit::Indent -accelerator Ctrl+I
  $m add command -label "Unindent" -command alited::unit::UnIndent -accelerator Ctrl+U
  $m add separator
  $m add command -label "Comment" -command alited::unit::Comment -accelerator "Ctrl+\["
  $m add command -label "Uncomment" -command alited::unit::UnComment -accelerator "Ctrl+\]"
  $m add separator
  $m add command -label $al(MC,icoreplace) -command alited::find::_run -accelerator Ctrl+F
  $m add command -label "Find Next" -command alited::find::Next -accelerator F3
  set m [set al(TOOLS) $al(WIN).menu.tool]
  $m add command -label $al(MC,projects) -command alited::project::_run
  $m add command -label $al(MC,tpl) -command alited::unit::Add
  $m add separator
  $m add command -label "Run" -command alited::tool::Run -accelerator F5
  $m add command -label "e_menu" -command alited::tool::Run -accelerator F4
  $m add command -label "Tcl/Tk Help" -command alited::tool::Help -accelerator F1
  set m [set al(MENUHELP) $al(WIN).menu.help]
  $m add command -label "About..." -command alited::HelpAbout
}

proc menu::CheckMenuItems {} {
  # Disables/enables "File/Close All..." menu items.

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  foreach idx {8 9 10} {
    set dsbl [alited::bar::BAR checkDisabledMenu $al(BID) $TID [incr item]]
    if {$dsbl} {
      set state "-state disabled"
    } else {
      set state "-state normal"
    }
    $al(MENUFILE) entryconfigure $idx {*}$state
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
