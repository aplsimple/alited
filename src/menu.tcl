###########################################################
# Name:    menu.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/20/2021
# Brief:   Handles menus.
# License: MIT.
###########################################################

namespace eval menu {
  variable tint; array set tint [list]
}

# ________________________ procs _________________________ #

proc menu::CheckMenuItems {} {
  # Disables/enables "File/Close All..." menu items.

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  foreach idx {10 11 12} {
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

proc menu::CheckTint {{doit no}} {
  # Sets a check in menu "Tint" according to the current tint.
  #   doit - "yes" at restarting this procedure after a pause

  namespace upvar ::alited al al obPav obPav
  variable tint
  if {!$doit} {
    # we can postpone updating the Tint menu
    after idle {after 500 {alited::menu::CheckTint yes}}
    return
  }
  set fg1 [lindex [alited::FgFgBold] 1]
  set fg2 [$al(SETUP) entrycget 0 -foreground]
  set ti 0
  for {set i 50} {$i>=-50} {incr i -5} {
    set tint($i) [alited::IsRoundInt $::apave::_CS_(HUE) $i]
    if {[alited::IsRoundInt $al(INI,HUE) $i]} {
      set fg $fg1
    } else {
      set fg $fg2
    }
    incr ti
    $al(SETUP).tint entryconfigure $ti -variable alited::menu::tint($i) -foreground $fg
  }
}
#_______________________

proc menu::SetTint {tint} {
  # Sets a tint of a current color scheme.
  #   tint - value of the tint

  namespace upvar ::alited al al obPav obPav
  $obPav csToned $al(INI,CS) $tint yes
  alited::file::MakeThemHighlighted
  alited::main::ShowText
  alited::bar::BAR update
  CheckTint
  alited::ini::initStyles
}
#_______________________

proc menu::MapRunItems {fname} {
  # Gets a map list to map %f & %D wildcards to the current file & directory names.
  #  fname - the current file name

  namespace upvar ::alited al al
  set ftail [file tail $fname]
  return [list %PD $al(prjroot) %D [file dirname $fname] %f $fname %F $ftail \$::FILETAIL $ftail]
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
        $m.runs entryconfigure [expr {$i+1}] -label $txt
      }
    }
  }
}
#_______________________

proc menu::Configurations {} {
  #

  if {![alited::ini::GetConfiguration]} return
  set alited::ARGV $::alited::CONFIGDIR
  alited::Exit - 1 no
}

# ________________________ Fill Menu _________________________ #

proc menu::FillMenu {} {
  # Populates alited's main menu.

  # alited_checked

  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu

  ## ________________________ File _________________________ ##

  set m [set al(MENUFILE) $al(WIN).menu.file]
  $m add command -label $al(MC,new) -command alited::file::NewFile -accelerator Ctrl+N
  $m add command -label $al(MC,open...) -command alited::file::OpenFile -accelerator Ctrl+O
  menu $m.recentfiles -tearoff 1
  $m add cascade -label [msgcat::mc {Recent Files}] -menu $m.recentfiles
  $m add separator

  ### ________________________ Save _________________________ ###

  $m add command -label $al(MC,save) -command alited::file::SaveFile -accelerator $al(acc_0)
  $m add command -label $al(MC,saveas...) -command alited::file::SaveFileAs -accelerator $al(acc_1)
  $m add command -label $al(MC,saveall) -command alited::file::SaveAll -accelerator Ctrl+Shift+S
  $m add command -label [msgcat::mc {Save and Close}] -command alited::file::SaveAndClose -accelerator Ctrl+W
  $m add separator

  ### ________________________ Close _________________________ ###

  $m add command -label $al(MC,close) -command alited::file::CloseFileMenu
  $m add command -label $al(MC,clall) -command {alited::file::CloseAll 1}
  $m add command -label $al(MC,clallleft) -command {alited::file::CloseAll 2}
  $m add command -label $al(MC,clallright) -command {alited::file::CloseAll 3}
  $m add command -label [msgcat::mc {Close and Delete}] -command alited::file::CloseAndDelete -accelerator Ctrl+Alt+W
  $m add separator

  ### ________________________ Reload _________________________ ###

  menu $m.eol -tearoff 1 -title EOL
  $m add cascade -label [msgcat::mc {Reload with EOL}] -menu $m.eol
  foreach eol {LF CR CRLF - auto} {
    if {$eol eq {-}} {
      $m.eol add separator
    } else {
      $m.eol add command -label "    $eol        " \
        -command [list alited::file::Reload1 $eol]
    }
  }
  menu $m.encods -tearoff 1
  $m add cascade -label [msgcat::mc {Reload with Encoding}] -menu $m.encods
  foreach enc [lsort -dictionary [encoding names]] {
    if {[incr icbr]%25} {set cbr {}} {set cbr {-columnbreak 1}}
    $m.encods add command -label $enc -command [list alited::file::Reload2 $enc] {*}$cbr
  }
  $m add separator
  $m add command -label $al(MC,quit) -command {alited::Exit - 0 no}

  ## ________________________ Edit _________________________ ##

  set m [set al(MENUEDIT) $al(WIN).menu.edit]
  $m add command -label $al(MC,moveupU) -command {alited::tree::MoveItem up yes} -accelerator $al(acc_15)
  $m add command -label $al(MC,movedownU) -command {alited::tree::MoveItem down yes} -accelerator $al(acc_16)
  $m add separator
  $m add command -label $al(MC,indent) -command alited::edit::Indent -accelerator $al(acc_6)
  $m add command -label $al(MC,unindent) -command alited::edit::UnIndent -accelerator $al(acc_7)
  $m add command -label $al(MC,corrindent) -command alited::edit::NormIndent
  $m add separator
  $m add command -label $al(MC,comment) -command alited::edit::Comment -accelerator $al(acc_8)
  $m add command -label $al(MC,uncomment) -command alited::edit::UnComment -accelerator $al(acc_9)
  $m add separator
  $m add command -label [msgcat::mc {Put New Line}] -command alited::main::InsertLine -accelerator $al(acc_18)
  $m add command -label [msgcat::mc {Remove Trailing Whitespaces}] -command alited::edit::RemoveTrailWhites
  $m add separator
  menu $m.hlcolors -tearoff 1 -title [msgcat::mc Colors]
  $m add cascade -label [msgcat::mc {Color values #hhhhhh}] -menu $m.hlcolors
  $m.hlcolors add command -label $al(MC,hlcolors) -command alited::edit::ShowColorValues
  $m.hlcolors add command -label [msgcat::mc {Hide colors}] -command alited::edit::HideColorValues

  ## ________________________ Search _________________________ ##

  set m [set al(SEARCH) $al(WIN).menu.search]
  $m add command -label $al(MC,findreplace) -command alited::find::_run -accelerator Ctrl+F
  $m add command -label $al(MC,findnext) -command {alited::find::Next ; after idle alited::main::SaveVisitInfo} -accelerator $al(acc_12)
  $m add separator
  $m add command -label $al(MC,lookdecl) -command alited::find::LookDecl -accelerator $al(acc_13)
  $m add command -label $al(MC,lookword) -command alited::find::SearchWordInSession -accelerator $al(acc_14)
  $m add command -label [msgcat::mc {Find Unit}] -command alited::find::FindUnit -accelerator Ctrl+Shift+F
  $m add command -label [msgcat::mc {Find by List}] -command alited::find::SearchByList
  $m add separator
  $m add command -label [msgcat::mc {To Last Visited}] -command alited::unit::SwitchUnits -accelerator Alt+BackSpace
  $m add command -label $al(MC,tomatched) -command {alited::main::GotoBracket yes} -accelerator $al(acc_20)
  $m add separator
  $m add command -label $al(MC,toline) -command alited::main::GotoLine -accelerator $al(acc_17)

  ## ________________________ Tools _________________________ ##

  set m [set al(TOOLS) $al(WIN).menu.tool]
  $m add command -label [msgcat::mc Run...] -command alited::tool::RunMode
  $m add command -label e_menu -command {alited::tool::e_menu o=0} -accelerator $al(acc_2)
  $m add command -label Tkcon -command alited::tool::tkcon

    ### ________________________ Runs _________________________ ###

  for {set i [set emwas 0]} {$i<$em_Num} {incr i} {
    if {[info exists em_ico($i)] && ($em_mnu($i) ne {} || $em_sep($i))} {
      if {[incr emwas]==1} {
        menu $m.runs -tearoff 1
        $m add cascade -label bar-menu -menu $m.runs
      }
      if {$em_sep($i)} {
        $m.runs add separator
      } else {
        set txt $em_mnu($i)
        $m.runs add command -label $txt -command [alited::tool::EM_command $i]
      }
    }
  }

    ### ________________________ Other tools _________________________ ###

  $m add separator
  $m add command -label $al(MC,checktcl) -command alited::CheckRun
  menu $m.filelist -tearoff 0
  $m add cascade -label $al(MC,filelist) -menu $m.filelist
  $m.filelist add command -label $al(MC,filelist) -command {alited::bar::BAR popList} -accelerator $al(acc_21)
  $m.filelist add checkbutton -label [msgcat::mc {Sorted}] -variable alited::al(sortList)
  $m add separator
  $m add command -label $al(MC,colorpicker) -command alited::tool::ColorPicker
  $m add command -label $al(MC,datepicker) -command alited::tool::DatePicker
  $m add separator
  $m add command -label [msgcat::mc {Screen Loupe}] -command alited::tool::Loupe

  ## ________________________ Setup _________________________ ##

  set m [set al(SETUP) $al(WIN).menu.setup]
  $m add command -label [msgcat::mc Projects...] -command alited::project::_run
  $m add command -label [msgcat::mc Templates...] -command alited::unit::Add
  $m add command -label [msgcat::mc {Favorites Lists...}] -command alited::favor::Lists
  $m add separator

  $m add checkbutton -label [msgcat::mc {Wrap Lines}] \
    -variable alited::al(wrapwords) -command alited::file::WrapLines
  $m add checkbutton -label [msgcat::mc {Tip File Info}] \
    -variable alited::al(TREE,showinfo) -command alited::file::UpdateFileStat

  menu $m.tipson -tearoff 1
  $m add cascade -label [msgcat::mc {Tips on / off}] -menu $m.tipson
  $m.tipson add checkbutton -label $al(MC,projects) -variable alited::al(TIPS,Projects) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,tpl) -variable alited::al(TIPS,Templates) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,pref) -variable alited::al(TIPS,Preferences) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,FavLists) -variable alited::al(TIPS,SavedFavorites) -command alited::ini::SaveIni
  $m.tipson add separator
  $m.tipson add checkbutton -label [msgcat::mc Units] -variable alited::al(TIPS,Tree) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,favorites) -variable alited::al(TIPS,TreeFavor) -command alited::ini::SaveIni

  menu $m.tint -tearoff 1
  $m add cascade -label [msgcat::mc Tint] -menu $m.tint
  for {set ti 50} {$ti>=-50} {incr ti -5} {
    set ti1 [string range "   $ti" end-2 end]
    if {$ti<0} {
      set ti2 "[msgcat::mc Darker:] $ti1"
    } elseif {$ti>0} {
      set ti2 "[msgcat::mc Lighter:]$ti1"
    } else {
      set ti3 [::apave::obj csGetName $al(INI,CS)]
      set ti2 CS\ #[string trim $ti3]
    }
    $m.tint add checkbutton -label $ti2 -command "alited::menu::SetTint $ti" -variable alited::menu::tint($ti)
  }
  CheckTint
  $m add separator

  $m add command -label [msgcat::mc {For Start...}] -command alited::tool::AfterStartDlg
  $m add separator
  $m add command -label [msgcat::mc Configurations...] -command alited::menu::Configurations
  $m add separator
  $m add command -label $al(MC,pref...) -command alited::pref::_run

  ## ________________________ Help _________________________ ##

  set m [set al(MENUHELP) $al(WIN).menu.help]
  $m add command -label Tcl/Tk -command alited::tool::Help -accelerator F1
  $m add command -label alited -command alited::HelpAlited
  $m add separator
  $m add command -label $al(MC,updateALE) -command {alited::ini::CheckUpdates yes}
  $m add separator
  $m add command -label [msgcat::mc "About..."] -command alited::HelpAbout
  alited::file::FillRecent
}

# _________________________________ EOF _________________________________ #
