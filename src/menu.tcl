###########################################################
# Name:    menu.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/20/2021
# Brief:   Handles menus.
# License: MIT.
###########################################################

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
#_______________________

proc menu::CheckPrjItems {} {
  # Checks for states of menu items related to projects.

  namespace upvar ::alited al al
  if {![info exists al(_check_menu_state_)] || $al(_check_menu_state_)} {
    if {$al(prjtrailwhite)} {set state disabled} {set state normal}
    $al(MENUEDIT) entryconfigure 11 -state $state
    set al(_check_menu_state_) 0
  }
}
#_______________________

proc menu::FillRecent {} {
  # Creates "Recent Files" menu items.

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
#_______________________

proc menu::SetTint {tint} {
  # Sets a tint of a current color scheme.
  #   tint - value of the tint

  namespace upvar ::alited al al obPav obPav
  $obPav csToned $al(INI,CS) $tint
  alited::file::MakeThemHighlighted
  alited::main::ShowText
  alited::bar::BAR update
}
#_______________________

proc menu::MapRunItems {fname} {
  # Gets a map list to map %f & %D wildcards to the current file & directory names.
  #  fname - the current file name

  set ftail [file tail $fname]
  return [list %D [file dirname $fname] %f $fname %F $ftail \$::FILETAIL $ftail]
}
#_______________________

proc menu::FillRunItems {fname} {
  # Fills Tools/e_menu items, depending on a currently edited file.
  #   fname - the current file name
  # Maps %f & %D wildcards to the current file & directory names.

  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu
  set m $al(TOOLS)
  set maplist [MapRunItems $fname]
  for {set i [set emwas 0]} {$i<$em_Num} {incr i} {
    if {[info exists em_ico($i)] && ($em_mnu($i) ne {} || $em_sep($i))} {
      if {!$em_sep($i)} {
        set txt [string map $maplist $em_mnu($i)]
        $m.runs entryconfigure $i -label $txt
      }
    }
  }
}
#_______________________

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
  $m add command -label $al(MC,moveupU) -command {alited::tree::MoveItem up yes} -accelerator $al(acc_15)
  $m add command -label $al(MC,movedownU) -command {alited::tree::MoveItem down yes} -accelerator $al(acc_16)
  $m add separator
  $m add command -label $al(MC,indent) -command alited::edit::Indent -accelerator $al(acc_6)
  $m add command -label $al(MC,unindent) -command alited::edit::UnIndent -accelerator $al(acc_7)
  $m add command -label [msgcat::mc {Correct Indentation}] -command alited::edit::NormIndent
  $m add separator
  $m add command -label $al(MC,comment) -command alited::edit::Comment -accelerator $al(acc_8)
  $m add command -label $al(MC,uncomment) -command alited::edit::UnComment -accelerator $al(acc_9)
  $m add separator
  $m add command -label [msgcat::mc {Put New Line}] -command alited::main::InsertLine -accelerator $al(acc_18)
  $m add command -label [msgcat::mc {Remove Trailing Whitespaces}] -command alited::edit::RemoveTrailWhites

    ### ________________________ Conversions _________________________ ###
#  $m add separator
#  menu $m.convert -tearoff 0
#  $m add cascade -label [msgcat::mc Conversions] -menu $m.convert
#  $m.convert add command -label [msgcat::mc {Change Encoding...}] -command alited::edit::ChangeEncoding
#  $m.convert add command -label [msgcat::mc {Change EOL...}] -command alited::edit::ChangeEOL

  ## ________________________ Search _________________________ ##
  set m [set al(SEARCH) $al(WIN).menu.search]
  $m add command -label $al(MC,findreplace) -command alited::find::_run -accelerator Ctrl+F
  $m add command -label $al(MC,findnext) -command {alited::find::Next ; after idle alited::main::SaveVisitInfo} -accelerator $al(acc_12)
  $m add separator
  $m add command -label [msgcat::mc {Look for Declaration}] -command alited::find::SearchUnit -accelerator $al(acc_13)
  $m add command -label [msgcat::mc {Look for Word}] -command alited::find::SearchWordInSession -accelerator $al(acc_14)
  $m add command -label [msgcat::mc {Find Unit}] -command alited::find::FindUnit -accelerator Ctrl+Shift+F
  $m add command -label [msgcat::mc {Find by List}] -command alited::find::SearchByList
  $m add separator
  $m add command -label [msgcat::mc {To Last Visited}] -command alited::unit::SwitchUnits -accelerator Alt+BackSpace
  $m add command -label [msgcat::mc {To Matched Bracket}] -command {alited::main::GotoBracket yes} -accelerator $al(acc_20)
  $m add separator
  $m add command -label [msgcat::mc {Go to Line}] -command alited::main::GotoLine -accelerator $al(acc_17)

  ## ________________________ Tools _________________________ ##
  set m [set al(TOOLS) $al(WIN).menu.tool]
  $m add command -label $al(MC,run) -command alited::tool::_run -accelerator $al(acc_3)
  $m add command -label e_menu -command {alited::tool::e_menu o=0} -accelerator $al(acc_2)

    ### ________________________ Runs _________________________ ###
  for {set i [set emwas 0]} {$i<$em_Num} {incr i} {
    if {[info exists em_ico($i)] && ($em_mnu($i) ne {} || $em_sep($i))} {
      if {[incr emwas]==1} {
        menu $m.runs -tearoff 0
        $m add cascade -label bar/menu -menu $m.runs
      }
      if {$em_sep($i)} {
        $m.runs add separator
      } else {
        set txt $em_mnu($i)
        $m.runs add command -label $txt -command [alited::tool::EM_command $i]
      }
    }
  }
  $m add command -label tkcon -command alited::tool::tkcon

    ### ________________________ Other tools _________________________ ###
  $m add separator
  $m add command -label $al(MC,checktcl) -command alited::CheckRun
  $m add separator
  $m add command -label $al(MC,colorpicker) -command alited::tool::ColorPicker
  $m add command -label [msgcat::mc {Screen Loupe}] -command alited::tool::Loupe
  $m add command -label $al(MC,datepicker) -command alited::tool::DatePicker

  ## ________________________ Setup _________________________ ##
  set m [set al(SETUP) $al(WIN).menu.setup]
  $m add command -label $al(MC,projects) -command alited::project::_run
  $m add command -label $al(MC,tpllist) -command alited::unit::Add
  $m add command -label $alited::al(MC,FavLists) -command alited::favor::Lists
  $m add separator
  menu $m.tint -tearoff 0
  if {[::apave::obj apaveTheme]} {set state normal} {set state disabled}
  $m add cascade -label [msgcat::mc Tint] -menu $m.tint -state $state
  foreach ti {50 45 40 35 30 25 20 15 10 5 0 -5 -10 -15 -20 -25 -30 -35 -40 -45 -50} {
    set ti1 [string range "   $ti" end-2 end]
    if {$ti<0} {
      set ti2 "[msgcat::mc Darker:] $ti1"
    } elseif {$ti>0} {
      set ti2 "[msgcat::mc Lighter:]$ti1"
    } else {
      set ti3 [::apave::obj csGetName $al(INI,CS)]
      set ti2 [msgcat::mc {Color scheme:}]
      append ti2 { } [string range $ti3 [string first { } $ti3] end]
    }
    $m.tint add command -label $ti2 -command "alited::menu::SetTint $ti"
  }
  $m add checkbutton -label [msgcat::mc {Wrap Lines}] \
    -variable alited::al(wrapwords) -command alited::file::WrapLines
  $m add checkbutton -label [msgcat::mc {Tip File Info}] \
    -variable alited::al(TREE,showinfo) -command alited::file::UpdateFileStat
  $m add separator
  $m add command -label [msgcat::mc {After Start...}] -command alited::tool::AfterStartDlg
  $m add command -label [msgcat::mc {Before Run...}] -command alited::tool::BeforeRunDlg
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
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
