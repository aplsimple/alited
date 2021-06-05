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
  foreach idx {9 10 11} {
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

proc menu::FillRecent {} {
  namespace upvar ::alited al al
  set m $al(MENUFILE).recentfiles
  $m delete 0 end
  if {[llength $al(RECENTFILES)]} {
    $al(MENUFILE) entryconfigure 2 -state normal
    set i 0
    foreach rf $al(RECENTFILES) {
      $m add command -label $rf -command "alited::file::ChooseRecent $i"
      incr i
    }
  } else {
    $al(MENUFILE) entryconfigure 2 -state disabled
  }
}

proc menu::FillMenu {} {
  # Populates alited's main menu.

  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu

## ________________________ File _________________________ ##
  set m [set al(MENUFILE) $al(WIN).menu.file]
  $m add command -label $al(MC,new) -command alited::file::NewFile -accelerator Ctrl+N
  $m add command -label $al(MC,open...) -command alited::file::OpenFile -accelerator Ctrl+O
  menu $m.recentfiles -tearoff 0
  $m add cascade -label  [msgcat::mc "Recent Files"] -menu $m.recentfiles
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
  $m add command -label $al(MC,restart) -command {alited::Exit - 1 no}
  $m add separator
  $m add command -label $al(MC,quit) -command {alited::Exit - 0 no}

## ________________________ Edit _________________________ ##
  set m [set al(MENUEDIT) $al(WIN).menu.edit]
  $m add command -label $al(MC,moveupU) -command {alited::main::MoveItem up yes} -accelerator $al(acc_15)
  $m add command -label $al(MC,movedownU) -command {alited::main::MoveItem down yes} -accelerator $al(acc_16)
  $m add separator
  $m add command -label [msgcat::mc {Add Line}] -command alited::main::InsertLine -accelerator Ctrl+Insert
  $m add command -label $al(MC,indent) -command alited::unit::Indent -accelerator $al(acc_6)
  $m add command -label $al(MC,unindent) -command alited::unit::UnIndent -accelerator $al(acc_7)
  $m add separator
  $m add command -label $al(MC,comment) -command alited::unit::Comment -accelerator $al(acc_8)
  $m add command -label $al(MC,uncomment) -command alited::unit::UnComment -accelerator $al(acc_9)
  $m add separator
  $m add command -label $al(MC,findreplace) -command alited::find::_run -accelerator Ctrl+F
  $m add command -label $al(MC,findnext) -command alited::find::Next -accelerator $al(acc_12)
  $m add command -label [msgcat::mc {Look for Declaration}] -command alited::find::SearchUnit -accelerator $al(acc_13)
  $m add command -label [msgcat::mc {Look for Word}] -command alited::find::SearchWordInSession -accelerator $al(acc_14)
  $m add command -label [msgcat::mc {Find Unit}] -command alited::find::FindUnit -accelerator Ctrl+Shift+F
  $m add separator
  $m add command -label [msgcat::mc {Go to Line}] -command alited::main::GotoLine -accelerator $al(acc_17)

## ________________________ Tools _________________________ ##
  set m [set al(TOOLS) $al(WIN).menu.tool]
  $m add command -label $al(MC,run) -command alited::tool::_run -accelerator $al(acc_3)
  $m add command -label e_menu -command alited::tool::e_menu -accelerator $al(acc_2)
  $m add command -label tkcon -command alited::tool::tkcon
  $m add separator
  $m add command -label $al(MC,checktcl) -command alited::check::_run
  $m add separator
  $m add command -label $al(MC,colorpicker) -command alited::tool::ColorPicker
  $m add command -label [msgcat::mc {Screen Loupe}] -command alited::tool::Loupe

### ________________________ Runs _________________________ ###

  for {set i [set emwas 0]} {$i<$em_Num} {incr i} {
    if {[info exists em_ico($i)] && ($em_mnu($i) ne {} || $em_sep($i))} {
      if {[incr emwas]==1} {
        menu $m.runs -tearoff 0
        $m add cascade -label [msgcat::mc Misc.] -menu $m.runs
      }
      if {$em_sep($i)} {
        $m.runs add separator
      } else {
        if {[string length $em_ico($i)]==1} {
          set txt $em_ico($i)
        } else {
          set txt $em_mnu($i)
        }
        lassign $em_inf($i) mnu idx
        set ex "ex=[alited::tool::EM_HotKey $idx]"
        $m.runs add command -label $txt -command "alited::tool::e_menu \"m=$mnu\" $ex"
      }
    }
  }

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
  $m add command -label [msgcat::mc "Help of alited"] -command alited::HelpAlited
  $m add command -label [msgcat::mc "About..."] -command alited::HelpAbout
  FillRecent
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
