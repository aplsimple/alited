###########################################################
# Name:    menu.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/20/2021
# Brief:   Handles menus.
# License: MIT.
###########################################################

namespace eval menu {
  variable tint; array set tint [list]
  variable inctint 5
}

# ________________________ procs _________________________ #

proc menu::Configurations {} {
  #

  if {![alited::ini::GetConfiguration]} return
  set ::alited::ARGV $::alited::CONFIGDIR
  alited::Exit - 1 no
}
#_______________________

proc menu::CheckMenuItems {} {
  # Disables/enables "File/Close All..." menu items.

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  foreach idx {11 12 13} {
    if {[alited::bar::BAR isTab $TID]} {
      set dsbl [alited::bar::BAR checkDisabledMenu $al(BID) $TID [incr item]]
    } else {
      set dsbl yes
    }
    if {$dsbl} {
      set state {-state disabled}
    } else {
      set state {-state normal}
    }
    $al(MENUFILE) entryconfigure $idx {*}$state
  }
  if {[alited::file::IsNoName [alited::bar::FileName]]} {
    set state {-state disabled}
  } else {
    set state {-state normal}
  }
  $al(MENUFILE) entryconfigure 2 {*}$state
}
#_______________________

proc menu::TintRange {} {
  # Gets the range for tints, counting the current one as the middle point.

  namespace upvar ::alited al al
  variable inctint
  set MT 50
  set mt 30
  for {set i $MT} {$i>=-$MT} {incr i -$inctint} {
    set tint($i) [::apave::IsRoundInt $::apave::_CS_(HUE) $i]
    if {[::apave::IsRoundInt $al(INI,HUE) $i]} {
      if {$i>0} {
        set max [expr {min($i+$mt,$MT)}]
        set min [expr {max(min($max-2*$mt,0),-$MT)}]
      } else {
        set min [expr {max($i-$mt,-$MT)}]
        set max [expr {min(max($min+2*$mt,0),$MT)}]
      }
      return [list $max $min]
    }
  }
  return [list $mt -$mt]
}
#_______________________

proc menu::CheckTint {{doit no}} {
  # Sets a check in menu "Tint" according to the current tint.
  #   doit - "yes" at restarting this procedure after a pause

  namespace upvar ::alited al al
  variable tint
  variable inctint
  if {!$doit} {
    # we can postpone updating the Tint menu
    after idle {after 500 {alited::menu::CheckTint yes}}
    return
  }
  set fg1 [lindex [alited::FgFgBold] 1]
  set fg2 [$al(SETUP) entrycget 0 -foreground]
  set ti 0
  lassign [TintRange] max min
  for {set i $max} {$i>=$min} {incr i -$inctint} {
    set tint($i) [::apave::IsRoundInt $::apave::_CS_(HUE) $i]
    if {[::apave::IsRoundInt $al(INI,HUE) $i]} {
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
  alited::main::UpdateMarkBar
  alited::file::MakeThemHighlighted
  alited::main::ShowText
  alited::bar::BAR update
  CheckTint
  alited::ini::initStyles
  # the infobar listbox needs colorizing by force
  set fg [ttk::style configure TLabel -foreground]
  set bg [ttk::style configure TLabel -background]
  set bs [lindex [$obPav csGet] 5]
  [$obPav LbxInfo] configure -foreground $fg -background $bg -selectbackground $bs
  # Find/Replace dialogue may be open at start (and presently) - update it too
  if {[winfo exists $::alited::find::win]} {
    alited::find::CloseFind
    alited::find::_run
  }
  set TID [alited::bar::CurrentTabID]
  after 500 "alited::bar::OnTabSelection $TID"
}
#_______________________

proc menu::MapRunItems {fname} {
  # Gets a map list to map %f & %D wildcards to the current file & directory names.
  #  fname - the current file name

  namespace upvar ::alited al al
  set ftail [file tail $fname]
  list %PD $al(prjroot) %D [file dirname $fname] %f $fname %F $ftail \$::FILETAIL $ftail
}
#_______________________

proc menu::FillRunItems {fname} {
  # Fills Tools/e_menu items, depending on a currently edited file.
  #   fname - the current file name
  # Maps %f & %D wildcards to the current file & directory names.

  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num em_mnu em_mnu
  set m $al(TOOLS)
  set maplist [MapRunItems $fname]
  set em_N [alited::ini::Em_Number $em_Num]
  for {set i 0} {$i<$em_N} {incr i} {
    if {[info exists em_ico($i)] && $em_mnu($i) ne {}} {
      set txt [string map $maplist $em_mnu($i)]
      $m.runs entryconfigure [expr {$i+1}] -label $txt
    }
  }
}
#_______________________

proc menu::MacroOptions {ca am} {
  # Gets play macro item's options.
  #   ca - argument of command
  #   am - label of macro

  namespace upvar ::alited al al
  if {$am eq $al(activemacro)} {
    set fg [lindex [alited::FgFgBold] 1]
    set opts "-accelerator $al(acc_16) -foreground $fg"
  } else {
    set opts {}
  }
  list -label $am -command [list alited::edit::DispatchMacro $ca] {*}$opts
}
#_______________________

proc menu::CompareFnames {n1 n2} {
  # Comapares two names of files, by their rootnames.
  #   n1 - 1st name
  #   n2 - 2nd name

  set n1 [file rootname [file tail $n1]]
  set n2 [file rootname [file tail $n2]]
  if {$n1 eq $n2} {return 0}
  set ls [lsort -dictionary [list $n1 $n2]]
  if {$n1 eq [lindex $ls 0]} {return -1}
  return 1
}
#_______________________

proc menu::FillMacroItems {} {
  # Fills play macro items.

  namespace upvar ::alited al al
  set m $al(MENUEDIT).playtkl
  set imax 99
  set pmax 34
  for {set i 0} {$i<[expr {$imax+$pmax}]} {incr i} {
    if {[catch {$m delete 1}]} break
  }
  set isaccel 0
  set pattern [alited::edit::MacroFileName *$al(macroext)]
  set lmacro [lsort -command alited::menu::CompareFnames [glob -nocomplain $pattern]]
  set imax [expr {min([llength $lmacro],$imax-2)}]
  for {set i [set idx 0]} {$i<$imax} {incr i} {
    set am [lindex $lmacro $i]
    if {[alited::edit::MacroFileName $am] ne [alited::edit::MacroFileName $al(MC,quickmacro)]} {
      set am [file rootname [file tail $am]]
      set opts [MacroOptions item$idx $am]
      if {[incr idx]%$pmax} {set cbr {}} {set cbr {-columnbreak 1}}
      $m add command {*}$opts {*}$cbr
      if {{-accelerator} in $opts} {set isaccel 1}
    }
  }
  if {!$idx} {
    if {[catch {set _ [$m entrycget 1 -label]}]} {
      after idle {
        alited::ini::CreateMacrosDir  ;# initialize macros
        alited::menu::FillMacroItems  ;# and refill this menu
      }
    }
    $m add command {*}[MacroOptions item0 $al(MC,new)]
  }
  $m add separator
  if {!$isaccel} {set al(activemacro) $al(MC,quickmacro)}
  $m add command {*}[MacroOptions quickrec $al(MC,quickmacro)]
  $m add command -label $al(MC,open...) -command alited::edit::OpenMacroFile
  $m add separator
  $m add command -label $al(MC,help) -command alited::edit::HelpOnMacro
}
#_______________________

proc menu::Paver {mode} {
  # Loads and calls Paver tool.
  #   mode - 0 run paver; 1 auto update flag; 2 view code; 3 help

  if {![namespace exists ::alited::paver]} {
    namespace eval ::alited {
      source [file join $::alited::SRCDIR paver.tcl]
    }
  }
  switch $mode {
    0 ::alited::paver::_run
    1 ::alited::paver::AutoUpdate
    2 ::alited::paver::Viewer
    3 ::alited::paver::Help
  }
}
#_______________________

proc menu::FormatsItemName {fname} {
  # Gets a Formats item's name.
  #   fname - formatter file's name

  return [file rootname [string range [file tail $fname] 4 end]]
}
#_______________________

proc menu::FillFormatItems {mnu {dir ""} {lev 0} {mnuID 0}} {
  # Fills Edit/Format submenu with items taken from "alited/data/format" directory.
  #   mnu - submenu's path
  #   dir - directory name
  #   lev - current level of subdirectory
  #   mnuID - menu's ID

  namespace upvar ::alited al al
  if {$dir eq {}} {
    set dir [file join $::alited::DATADIR format]
  }
  set al(FORMATNAMES) [list]
  set fnames [glob -nocomplain -directory $dir *]
  foreach fn [lsort -dictionary $fnames] {
    if {[string tolower [file tail $fn]] eq {init.tcl}} continue
    # first 4 chars for sorting
    set it [FormatsItemName $fn]
    set it [string map [list _ { }] $it]
    if {[file isdirectory $fn]} {
      if {$lev<3} {  ;# prohibit too deep diving
        set subm [MenuCascade $mnu m[incr mnuID] $it]
        alited::menu::FillFormatItems $subm $fn [expr {$lev+1}] $mnuID
      }
    } elseif {$it eq {}} {
      $mnu add separator
    } else {
      if {[incr idx] % 25} {set cbr {}} {set cbr {-columnbreak 1}}
      $mnu add command -label $it -command [list alited::edit::RunFormat $fn] {*}$cbr
      lappend al(FORMATNAMES) [list [file tail $fn] $fn]
    }
  }
  if {!$lev} {
    $mnu add separator
    $mnu add command -label $al(MC,open...) -command [list alited::edit::OpenFormatFile $dir]
  }
}

## ________________________ Tear-off menus _________________________ ##

proc menu::MenuCascade {mnu mnuName mnuTitle {subTitle ""}} {
  # Creates a cascade submenu, saving its title (for saved/restored submenus).
  #   mnu - parent menu's path
  #   mnuName - submenu name
  #   mnuTitle - parent's title
  #   subTitle - submenu's title
  # See also: SaveCascadeMenuGeo

  set mnuPath $mnu.$mnuName
  set mnuTitle [msgcat::mc $mnuTitle]
  if {$subTitle eq {}} {
    set subTitle $mnuTitle
  } else {
    set subTitle [msgcat::mc $subTitle]
  }
  set submnu [menu $mnuPath -tearoff 1 -title $subTitle]
  $mnu add cascade -label $mnuTitle -menu $submnu
  set ::alited::al(MNUMEM,$mnuName) [list $submnu $subTitle]
  return $mnuPath
}
#_______________________

proc menu::SaveCascadeMenuGeo {} {
  # Saves the geometry of tear-off menus.
  # See also: MenuCascade, RestoreCascadeMenu

  namespace upvar ::alited al al
  # clear all geometry data of menus
  foreach n [array names al -glob MNUGEO,*] {unset al($n)}
  # set the currently existing tearoff menus' geometry data
  foreach w [winfo children $al(WIN)] {
    # only tearoff menus counted:
    if {[regexp {\.tearoff\d+$} $w]} {
      set mtitle [wm title $w]
      # find the tearoff menu among those registered by MenuCascade
      foreach mMem [array names al -glob MNUMEM,*] {
        lassign $al($mMem) mnuPath mnuTitle
        if {$mtitle eq $mnuTitle} {
          set mgeo MNUGEO,$mnuPath
          set al($mgeo) [list $mnuPath [wm geometry $w]]
          break
        }
      }
    }
  }
}
#_______________________

proc menu::RestoreCascadeMenu {} {
  # Restores cascade menus at starting alited.

  namespace upvar ::alited al al
  foreach mn [array names al -glob MNUGEO,*] {
    lassign $al($mn) mnu mnugeo
    if {[winfo exists $mnu]} {
      incr itearoff
      set mtearoff $al(WIN).tearoff$itearoff
      after 1000 [list alited::menu::TearoffCascadeMenu $mnu $mtearoff $mnugeo]
    }
  }
}
#_______________________

proc menu::TearoffCascadeMenu {mnu mtearoff mnugeo} {
  # Tear off a cascade menus at starting alited.
  #   mnu - menu's path
  #   mtearoff - tearoff menu's path
  #   mnugeo - geometry of menu

  $mnu invoke 0
  catch {
    wm geometry $mtearoff $mnugeo
    if {[::isunix]} {wm iconphoto $mtearoff -default alimg_none}
  }
}

# ________________________ Fill Menu _________________________ #

proc menu::FillMenu {} {
  # Populates alited's main menu.

  variable inctint
  # alited_checked
  ::apave::msgcatDialogs

  namespace upvar ::alited al al DATADIR DATADIR DIR DIR
  namespace upvar ::alited::pref em_Num em_Num em_ico em_ico em_inf em_inf em_mnu em_mnu

  ## ________________________ File _________________________ ##

  set m [set al(MENUFILE) $al(WIN).menu.file]
  $m add command -label $al(MC,new) -command alited::file::NewFile -accelerator Ctrl+N
  $m add command -label $al(MC,open...) -command alited::file::OpenFile -accelerator Ctrl+O
  $m add command -label [msgcat::mc Clone...] -command {alited::file::CloneFile no no}
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

  ### ________________________ Detach _________________________ ###

  menu $m.detach -tearoff 1 -title $al(MC,detach)
  $m add cascade -label $al(MC,detach) -menu $m.detach
  $m.detach add command -label $al(MC,detach) -command alited::file::Detach
  $m.detach add command -label $al(MC,open...) -command alited::file::OpenDetach
  $m.detach add separator
  $m.detach add checkbutton -label [string trim $al(MC,middlefont) :] -variable ::alited::al(fontdetach)
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
  $m add command -label $al(MC,indent) -command alited::edit::Indent -accelerator $al(acc_6)
  $m add command -label $al(MC,unindent) -command alited::edit::UnIndent -accelerator $al(acc_7)
  $m add command -label $al(MC,corrindent) -command alited::edit::NormIndent
  $m add separator

  ### ________________________ Comments _________________________ ###

  set ttl [msgcat::mc Comments]
  menu $m.comment -tearoff 1 -title $ttl
  $m add cascade -label $ttl -menu $m.comment
  $m.comment add command -label $al(MC,comment) -command alited::edit::Comment -accelerator $al(acc_8)
  $m.comment add command -label $al(MC,uncomment) -command alited::edit::UnComment -accelerator $al(acc_9)
  $m.comment add separator
  $m.comment add radiobutton -variable ::alited::al(commentmode) -value 0 -label TODO
  $m.comment add radiobutton -variable ::alited::al(commentmode) -value 1 -label Classic
  $m.comment add radiobutton -variable ::alited::al(commentmode) -value 2 -label Sticky

  ### ________________________ Formats _________________________ ###

  MenuCascade $m format [msgcat::mc Formats]
  set al(MENUFORMATS) $m.format
  FillFormatItems $al(MENUFORMATS)
  $m add separator

  $m add command -label [msgcat::mc {Put New Line}] -command alited::main::InsertLine -accelerator $al(acc_18)
  $m add command -label [msgcat::mc {Remove Trailing Whitespaces}] -command alited::edit::RemoveTrailWhites
  $m add separator

  ### ________________________ Rectangular Selection _________________________ ###

  MenuCascade $m rectsel [msgcat::mc {Rectangular Selection}]
  $m.rectsel add checkbutton -label [msgcat::mc Start] -command {alited::edit::RectSelection 0} -variable ::alited::al(rectSel) -compound left -image alimg_run
  $m.rectsel add separator
  $m.rectsel add command -label [msgcat::mc Cut] -command {alited::edit::RectSelection 2}
  $m.rectsel add command -label [msgcat::mc Copy] -command {alited::edit::RectSelection 3}
  $m.rectsel add command -label [msgcat::mc Paste] -command {alited::edit::RectSelection 4}

  ### ________________________ Color Values _________________________ ###

  MenuCascade $m hlcolors [msgcat::mc {Color Values #hhhhhh}] [msgcat::mc Colors]
  $m.hlcolors add command -label $al(MC,hlcolors) -command alited::edit::ShowColorValues
  $m.hlcolors add command -label [msgcat::mc {Hide Colors}] -command alited::edit::HideColorValues

  ### ________________________ Macro _________________________ ###

  MenuCascade $m playtkl $::alited::al(MC,playtkl)
  FillMacroItems

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
  $m add command -label $al(MC,run) -command alited::tool::_run -accelerator $al(acc_3)
  $m add command -label $al(MC,runAsIs) -command alited::tool::RunFile -accelerator $al(acc_22)
  $m add separator
  $m add command -label e_menu -command {alited::tool::e_menu o=0} -accelerator $al(acc_2)
  $m add command -label Tkcon -command alited::tool::tkcon

  ### ________________________ bar-menu _________________________ ###

  set em_N [alited::ini::Em_Number $em_Num]
  for {set i [set emwas 0]} {$i<$em_N} {incr i} {
    if {[info exists em_inf($i)]} {
      if {[incr emwas]==1} {
        menu $m.runs -tearoff 1
        $m add cascade -label bar-menu -menu $m.runs
      }
      if {$em_inf($i) eq {}} {
        $m.runs add separator
      } else {
        set com [alited::tool::EM_command $i]
        if {$com ne {}} {
          set txt $em_mnu($i)
          $m.runs add command -label $txt -command $com
        }
      }
    }
  }

  ### ___________________ Check, File list __________________ ###

  $m add separator
  menu $m.filelist -tearoff 0
  $m add cascade -label $al(MC,filelist) -menu $m.filelist
  $m.filelist add command -label $al(MC,filelist) -command {alited::bar::BAR popList} -accelerator $al(acc_21)
  $m.filelist add checkbutton -label [msgcat::mc {Sorted}] -variable ::alited::al(sortList) -command alited::ini::SaveIni
  $m add command -label $al(MC,checktcl...) -command alited::CheckRun
  $m add command -label [msgcat::mc {Project Printer...}] -command alited::PrinterRun

  ### ________________________ Paver _________________________ ###

  $m add separator
  MenuCascade $m paver Paver

  $m.paver add command -label Paver -command {alited::menu::Paver 0}
  $m.paver add separator
  $m.paver add checkbutton -label [msgcat::mc {Auto Update}] \
    -variable ::alited::al(paverauto) -command {alited::menu::Paver 1}
  $m.paver add command -label [msgcat::mc {Widget List}] -command {alited::menu::Paver 2}
  $m.paver add separator
  $m.paver add command -label $al(MC,Help) -command {alited::menu::Paver 3}

  ### ________________________ DockingFW _________________________ ###

  MenuCascade $m dockingFW {Paned GUI}
  $m.dockingFW add command -label {Docking Framework} -command alited::tool::DFWokay
  $m.dockingFW add separator
  $m.dockingFW add command -label DFW_Layout \
    -command alited::tool::DFWdocklayout
  $m.dockingFW add command -label apave_Layout \
    -command alited::tool::DFWapavelayout
  $m.dockingFW add separator
  $m.dockingFW add command -label $al(MC,open...) \
    -command alited::tool::DFWopen
  $m.dockingFW add command -label [msgcat::mc Setup...] \
    -command alited::tool::DFWtool
  $m.dockingFW add separator
  $m.dockingFW add command -label $al(MC,Help) -command alited::tool::DFWhelp
  ::baltip::tip $m.dockingFW "$al(MC,run):\n\ntclsh [alited::tool::DFWscript]\
    \"DFW_Layout.tcl\" -load" -index 3 -per10 4000
  ::baltip::tip $m.dockingFW "$al(MC,run):\n\ntclsh \"apave_Layout.tcl\"" -index 4
  ::baltip::tip $m.dockingFW \
    "$al(MC,open...)\n\nDFW_Layout.tcl\napave_Layout.tcl" -index 6

  ### ________________________ Pickers _________________________ ###

  $m add separator
  $m add command -label $al(MC,datepicker) -command alited::tool::DatePicker
  $m add command -label $al(MC,colorpicker) -command alited::tool::ColorPicker
  $m add command -label [msgcat::mc {Screen Loupe}] -command alited::tool::Loupe

  ## ________________________ Setup _________________________ ##

  set m [set al(SETUP) $al(WIN).menu.setup]
  $m add command -label [msgcat::mc Projects...] -command alited::project::_run
  $m add command -label [msgcat::mc {Favorites Lists...}] -command alited::favor::Lists
  $m add separator
  $m add command -label [msgcat::mc Templates...] -command alited::unit::Add

  set al(TYPETPLMENU) $m.typetpl
  menu $al(TYPETPLMENU) -tearoff 1
  $m add cascade -label [msgcat::mc {Type Templates}] -menu $al(TYPETPLMENU)
  $al(TYPETPLMENU) add command -label $al(MC,open...) -command alited::unit::OpenTypeTemplate
  $m add separator

  $m add checkbutton -label $al(MC,icoprev2) \
    -variable ::alited::al(wrapwords) -command alited::file::WrapLines
  $m add checkbutton -label [msgcat::mc {Tip File Info}] \
    -variable ::alited::al(TREE,showinfo) -command alited::file::UpdateFileStat
  $m add separator

  MenuCascade $m tint [msgcat::mc Tint]
  lassign [TintRange] max min
  for {set ti $max} {$ti>=$min} {incr ti -$inctint} {
    set ti1 [string range "   $ti" end-2 end]
    if {$ti<0} {
      set ti2 "[msgcat::mc Darker:] $ti1"
    } elseif {$ti>0} {
      set ti2 "[msgcat::mc Lighter:]$ti1"
    } else {
      set ti2 CS\ #$al(INI,CS)
    }
    $m.tint add checkbutton -label $ti2 -command "alited::menu::SetTint $ti" -variable alited::menu::tint($ti)
  }
  CheckTint

  menu $m.tipson -tearoff 1
  $m add cascade -label [msgcat::mc {Tips on / off}] -menu $m.tipson
  $m.tipson add checkbutton -label $al(MC,projects) -variable ::alited::al(TIPS,Projects) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,tpl) -variable ::alited::al(TIPS,Templates) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,pref) -variable ::alited::al(TIPS,Preferences) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,FavLists) -variable ::alited::al(TIPS,SavedFavorites) -command alited::ini::SaveIni
  $m.tipson add separator
  $m.tipson add checkbutton -label [msgcat::mc Units] -variable ::alited::al(TIPS,Tree) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,favorites) -variable ::alited::al(TIPS,TreeFavor) -command alited::ini::SaveIni
  $m.tipson add checkbutton -label $al(MC,marks) -variable ::alited::al(TIPS,Marks) -command {alited::main::UpdateMarkBar; alited::ini::SaveIni}

  menu $m.weekcal -tearoff 0
  $m add cascade -label [msgcat::mc {Weeks in Calendar}] -menu $m.weekcal
  $m.weekcal add radiobutton -value 0 -label None \
    -variable ::alited::al(klndweeks) -command alited::ini::SaveIni
  $m.weekcal add radiobutton -value 1 -label Classic \
    -variable ::alited::al(klndweeks) -command alited::ini::SaveIni
  $m.weekcal add radiobutton -value 2 -label Sticky \
    -variable ::alited::al(klndweeks) -command alited::ini::SaveIni

  $m add separator
  $m add command -label $al(MC,formatdesc...) -command alited::edit::FormatUnitDesc
  $m add separator

  $m add command -label [msgcat::mc {For Start...}] -command alited::tool::AfterStartDlg
  $m add command -label [msgcat::mc Configurations...] -command alited::menu::Configurations
  $m add separator
  $m add command -label $al(MC,pref...) -command alited::pref::_run

  ## ________________________ Help _________________________ ##

  set m $al(WIN).menu.help
  menu $m.help -tearoff 0
  $m add cascade -label Tcl/Tk -menu $m.help
  $m.help add command -label $al(MC,Help) -command alited::tool::Help -accelerator F1
  $m.help add command -label {Tcl Wiki} -command {alited::tool::Help Wiki}
  $m.help add separator
  $m.help add command -label Tcllib -command {alited::tool::Help Tcllib}
  $m.help add command -label Tklib -command {alited::tool::Help Tklib}
  $m.help add command -label {Thread package} -command {alited::tool::Help Thread}
  $m.help add command -label {Math functions} -command {alited::tool::Help Math}
  $m.help add separator
  $m.help add command -label StackOverflow -command {alited::tool::Help SOF}
  $m add separator
  menu $m.ale -tearoff 0
  $m add cascade -label alited -menu $m.ale
  $m.ale add command -label $al(MC,Help) -command alited::HelpAlited
  $m.ale add command -label alited/src -command alited::AlitedSrc
  menu $m.helps -tearoff 1
  $m add cascade -label [msgcat::mc Context] -menu $m.helps
  foreach {hlp lab} [HelpFiles] {
    if {$hlp eq {-}} {
      $m.helps add separator
    } else {
      if {[set i [string first \\ $lab]]<0} {
        set lab [msgcat::mc $lab]
      } else {
        set lab1 [msgcat::mc [string range $lab 0 $i-1]]
        set lab2 [msgcat::mc [string range $lab $i+1 end]]
        set lab "$lab1 / $lab2"
      }
      $m.helps add command -label $lab -command [list alited::HelpFile $al(WIN) [file join $DATADIR help $hlp] -head $lab -weight bold -ale1Help yes]
    }
  }
  $m add separator
  $m add command -label Changelog -command \
    [list alited::file::OpenFile [file join $DIR CHANGELOG.md]]
  $m add command -label $al(MC,updateALE) -command {alited::ini::CheckUpdates yes}
  $m add separator
  $m add command -label [msgcat::mc "About..."] -command alited::HelpAbout
  alited::file::FillRecent
  RestoreCascadeMenu
}
#_______________________

proc menu::HelpFiles {} {
  # Gets a list of Help/Context (file names and labels).

  list \
    pref-nbk-f1.txt {Preferences\General} \
    pref-nbk-f2.txt {Preferences\Saving} \
    pref-nbk-f3.txt {Preferences\Projects} \
    pref-nbk2-f1.txt {Preferences\Editor} \
    pref-nbk2-f2.txt {Preferences\Tcl syntax} \
    pref-nbk2-f3.txt {Preferences\C/C++ syntax} \
    pref-nbk2-f4.txt {Preferences\Plain text} \
    pref-nbk3-f1.txt {Preferences\Units} \
    pref-nbk4-f1.txt {Preferences\Templates} \
    pref-nbk5-f1.txt {Preferences\Keys} \
    pref-nbk6-f1.txt {Preferences\Tools} \
    pref-nbk6-f2.txt {Preferences\e_menu} \
    pref-nbk6-f3.txt {Preferences\bar-menu} \
    pref-nbk6-f4.txt {Preferences\Tkcon} \
    - - \
    project.txt {Projects\Information} \
    project2.txt {Projects\Options} \
    project3.txt {Projects\Templates} \
    project4.txt {Projects\Commands} \
    project5.txt {Projects\Files} \
    - - \
    unit_tpl.txt {Setup\Templates...} \
    favor_ls.txt {Setup\Favorites Lists...} \
    format1.txt {Setup\Moving Unit Descriptions...} \
    tool.txt {Setup\For Start...} \
    ini.txt {Setup\Configurations...} \
    - - \
    editmacro.txt {Edit\Play Macro} \
    mainmark.txt {Edit\Marks} \
    find2.txt {Search\Find by List} \
    maingoline.txt {Search\Go to Line} \
    run.txt {Tools\Run...} \
    check.txt {Tools\Check Tcl...} \
    printer.txt {Tools\Project Printer...} \
    paver.txt {Tools\Paver}

}

# _________________________________ EOF _________________________________ #
