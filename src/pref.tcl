###########################################################
# Name:    pref.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    05/25/2021
# Brief:   Handles "Preferences".
# License: MIT.
###########################################################

# ________________________ Variables _________________________ #

namespace eval pref {

  # "Preferences" dialogue's path
  variable win $::alited::al(WIN).diaPref

  # geometry for message boxes: to center in "Preferences" dialogue
  variable geo root=$::alited::al(WIN)

  # saved data of settings
  variable data; array set data [list]

  # data of keys
  variable keys; array set keys [list]

  # saved data of previous keys
  variable prevkeys; array set prevkeys [list]

  # saved data of keys
  variable savekeys; array set savekeys [list]

  # saved tabs
  variable arrayTab; array set arrayTab [list]

  # current tab
  variable curTab nbk

  # saved tab
  variable oldTab {}

  # list of color themes
  variable opcThemes [list]
  variable opc1 {}

  # list of color schemes
  variable opcColors [list]

  # current CS of alited
  variable opcc {}

  # current CS of e_menu
  variable opcc2 {}

  # number of bar-menu items
  variable em_Num 32

  # bar/e_menu action
  variable em_mnu; array set em_mnu [list]

  # bar/e_menu icon
  variable em_ico; array set em_ico [list]

  # bar/e_menu separator flag
  variable em_sep; array set em_sep [list]

  # bar/e_menu full info
  variable em_inf; array set em_inf [list]

  # list of e_menu icons
  variable em_Icons [list]

  # list of alited icons
  variable listIcons [list]

  # list of e_menu menus
  variable listMenus [list]

  # dictionary of standard keys' data
  variable stdkeys

  # standard keys' data
  set stdkeys [dict create \
     0 [list {Save File} F2] \
     1 [list {Save File as} Control-S] \
     2 [list {Run e_menu} F4] \
     3 [list {Run File} F5] \
     4 [list {Double Selection} Control-D] \
     5 [list {Delete Line} Control-Y] \
     6 [list $::alited::al(MC,indent) Control-I] \
     7 [list $::alited::al(MC,unindent) Control-U] \
     8 [list $::alited::al(MC,comment) Control-bracketleft] \
     9 [list $::alited::al(MC,uncomment) Control-bracketright] \
    10 [list {Highlight First} Alt-Q] \
    11 [list {Highlight Last} Alt-W] \
    12 [list {Find Next Match} F3] \
    13 [list $::alited::al(MC,lookdecl) Control-L] \
    14 [list $::alited::al(MC,lookword) Control-Shift-L] \
    15 [list {Item up} F11] \
    16 [list {Item down} F12] \
    17 [list $::alited::al(MC,toline) Control-G] \
    18 [list {Put New Line} Control-P] \
    19 [list {Complete Commands} Tab] \
    20 [list $::alited::al(MC,tomatched) Alt-B] \
    21 [list $::alited::al(MC,filelist) F9] \
  ]

  # size of standard keys' data
  variable stdkeysSize [dict size $stdkeys]

  # locales
  variable locales [list]

  # preview flag
  variable preview 0
}

# ________________________ Common procedures _________________________ #

proc pref::fetchVars {} {
  # Delivers namespace variables to a caller.

  uplevel 1 {
    namespace upvar ::alited al al obDl2 obDl2
    variable win
    variable geo
    variable data
    variable keys
    variable prevkeys
    variable savekeys
    variable arrayTab
    variable curTab
    variable oldTab
    variable opcThemes
    variable opc1
    variable opcColors
    variable opcc
    variable opcc2
    variable em_Num
    variable em_mnu
    variable em_ico
    variable em_sep
    variable em_inf
    variable em_Icons
    variable listIcons
    variable listMenus
    variable stdkeys
    variable stdkeysSize
    variable locales
    variable preview
  }
}
#_______________________

proc pref::SavedOptions {} {
  # Returns a list of names of main settings.

  fetchVars
  return [array names al]
}
#_______________________

proc pref::SaveSettings {} {
  # Saves original settings.

  fetchVars
  foreach o [SavedOptions] {
    set data($o) $al($o)
  }
  for {set i 0} {$i<$em_Num} {incr i} {
    catch {
      set data(em_mnu,$i) $em_mnu($i)
      set data(em_ico,$i) $em_ico($i)
      set data(em_sep,$i) $em_sep($i)
      set data(em_inf,$i) $em_inf($i)
    }
  }
  set data(INI,CSsaved) $data(INI,CS)
  if {[info exists ::em::geometry]} {set ::em::geometry $al(EM,geometry)}
}
#_______________________

proc pref::RestoreSettings {} {
  # Restores original settings.

  fetchVars
  foreach o [SavedOptions] {
    catch {set al($o) $data($o)}
  }
  dict for {k info} $stdkeys {
    set keys($k) $savekeys($k)
    SelectKey $k
  }
  for {set i 0} {$i<$em_Num} {incr i} {
    catch {
      set em_mnu($i) $data(em_mnu,$i)
      set em_ico($i) $data(em_ico,$i)
      set em_sep($i) $data(em_sep,$i)
      set em_inf($i) $data(em_inf,$i)
    }
  }
  if {[info exists ::em::geometry]} {set ::em::geometry $al(EM,geometry)}
}
#_______________________

proc pref::TextIcons {} {
  # Returns a list of letters to be toolbar "icons".

  return &~=@$#%ABCDEFGHIJKLMNOPQRSTUVWXYZ
}
#_______________________

proc pref::ReservedIcons {} {
  # Returns a list of icons already engaged by alited.

  return [list file OpenFile box SaveFile saveall undo redo help replace run other ok color]
}

# ________________________ Main Frame _________________________ #

proc pref::MainFrame {} {
  # Creates a main frame of the dialogue.

  fetchVars
  $obDl2 untouchWidgets *.cannbk*
  return {
    {fraL - - 1 1 {-st nws -rw 2}}
    {.ButHome - - 1 1 {-st we -pady 0} {-t "General" -com "alited::pref::Tab nbk" -style TButtonWest}}
    {.Cannbk + L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButChange .butHome T 1 1 {-st we -pady 1} {-t "Editor" -com "alited::pref::Tab nbk2" -style TButtonWest}}
    {.Cannbk2 + L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButCategories .butChange T 1 1 {-st we -pady 0} {-t "Units" -com "alited::pref::Tab nbk3" -style TButtonWest}}
    {.Cannbk3 + L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButActions .butCategories T 1 1 {-st we -pady 1} {-t "Templates" -com "alited::pref::Tab nbk4" -style TButtonWest}}
    {.Cannbk4 + L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButKeys .butActions T 1 1 {-st we -pady 0} {-image alimg_kbd -compound left -t "Keys" -com "alited::pref::Tab nbk5" -style TButtonWest}}
    {.Cannbk5 + L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButTools .butKeys T 1 1 {-st we -pady 1} {-t "Tools" -com "alited::pref::Tab nbk6" -style TButtonWest}}
    {.Cannbk6 + L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.v_  .butTools T 1 1 {-st ns} {-h 30}}
    {fraR fraL L 1 1 {-st nsew -cw 1}}
    {fraR.nbk - - - - {pack -side top -expand 1 -fill both} {
        f1 {-t View}
        f2 {-t Saving}
        f3 {-t Projects}
    }}
    {fraR.nbk2 - - - - {pack forget -side top} {
        f1 {-t Editor}
        f2 {-t "Tcl syntax"}
        f3 {-t "C/C++ syntax"}
        f4 {-t "Plain text"}
    }}
    {fraR.nbk3 - - - - {pack forget -side top} {
        f1 {-t Units}
    }}
    {fraR.nbk4 - - - - {pack forget -side top} {
        f1 {-t Templates}
    }}
    {fraR.nbk5 - - - - {pack forget -side top} {
        f1 {-t Keys}
    }}
    {fraR.nbk6 - - - - {pack forget -side top} {
        f1 {-t Common}
        f2 {-t e_menu}
        f3 {-t bar-menu}
        f4 {-t Tkcon}
    }}
    {seh fraL T 1 2 {-st nsew -pady 2}}
    {fraB + T 1 2 {-st nsew} {-padding {2 2}}}
    {.ButHelp - - - - {pack -side left} {-t {$alited::al(MC,help)} -tip F1 -com ::alited::pref::Help}}
    {.BtTUp - - - - {pack forget -side left} {-image alimg_up -com ::alited::pref::UpRun}}
    {.BtTDown - - - - {pack forget -side left} {-image alimg_down -com ::alited::pref::DownRun}}
    {.LabMess - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 40}}
    {.ButOK - - - - {pack -side left -anchor s -padx 2} {-t Save -command ::alited::pref::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -command ::alited::pref::Cancel}}
  }
}
#_______________________

proc pref::Ok {args} {
  # Handler of "OK" button.

  fetchVars
  alited::CloseDlg
  CheckTheming no
  if {$al(INI,confirmexit)>1} {
    set timo "-timeout {$al(INI,confirmexit) ButOK}"
  } else {
    set timo {}
  }
  set ans [alited::msg okcancel info $al(MC,restart) OK -centerme $win {*}$timo]
  if {$ans} {
    GetEmSave out
    # check options that can make alited unusable
    if {$al(INI,HUE)<-50 || $al(INI,HUE)>50} {set al(INI,HUE) 0}
    if {$al(FONTSIZE,small)<6 || $al(FONTSIZE,small)>72} {set al(FONTSIZE,small) 9}
    if {$al(FONTSIZE,std)<7 || $al(FONTSIZE,std)>72} {set al(FONTSIZE,std) 10}
    if {$al(INI,RECENTFILES)<10 || $al(INI,RECENTFILES)>50} {set al(INI,RECENTFILES) 16}
    if {$al(FAV,MAXLAST)<10 || $al(FAV,MAXLAST)>100} {set al(FAV,MAXLAST) 100}
    if {$al(MAXFILES)<1000 || $al(MAXFILES)>9999} {set al(MAXFILES) 2000}
    if {$al(INI,barlablen)<10 || $al(INI,barlablen)>100} {set al(INI,barlablen) 16}
    if {$al(INI,bartiplen)<10 || $al(INI,bartiplen)>100} {set al(INI,bartiplen) 32}
    if {$al(CURSORWIDTH)<1 || $al(CURSORWIDTH)>8} {set al(CURSORWIDTH) 2}
    set al(THEME) $opc1
    set al(INI,CS) [GetCS]
    if {![string is integer -strict $al(INI,CS)]} {set al(INI,CS) -1}
    set al(EM,CS)  [GetCS 2]
    if {![string is integer -strict $al(EM,CS)]} {set al(EM,CS) -1}
    set al(ED,TclKeyWords) [[$obDl2 TexTclKeys] get 1.0 {end -1c}]
    set al(ED,TclKeyWords) [string map [list \n { }] $al(ED,TclKeyWords)]
    set al(ED,CKeyWords) [[$obDl2 TexCKeys] get 1.0 {end -1c}]
    set al(ED,CKeyWords) [string map [list \n { }] $al(ED,CKeyWords)]
    set al(BACKUP) [string trim $al(BACKUP)]
    catch {set al(TCLLIST) [lreplace $al(TCLLIST) 32 end]}
    set al(EM,TclList) $al(EM,Tcl)
    foreach tcl $al(TCLLIST) {
      if {[::apave::lsearchFile [split $al(EM,TclList) \t] $tcl]<0} {
        append al(EM,TclList) \t $tcl
      }
    }
    set al(EM,TclList) [string trim $al(EM,TclList)]
    catch {set al(TTLIST) [lreplace $al(TTLIST) 32 end]}
    set al(EM,tt=List) $al(EM,tt=)
    foreach tt $al(TTLIST) {
      if {[::apave::lsearchFile [split $al(EM,tt=List) \t] $tt]<0} {
        append al(EM,tt=List) \t $tt
      }
    }
    set al(EM,tt=List) [string trim $al(EM,tt=List)]
    catch {set al(WTLIST) [lreplace $al(WTLIST) 32 end]}
    set al(EM,wt=List) $al(EM,wt=)
    foreach wt $al(WTLIST) {
      if {$wt ni [split $al(EM,wt=List) \t]} {append al(EM,wt=List) \t $wt}
    }
    set al(EM,wt=List) [string trim $al(EM,wt=List)]
    set plst [lsort [list {} $al(comm_port) {*}$al(comm_port_list)]]
    set al(comm_port_list) [list]
    foreach pt $plst {
      if {$pt ni $al(comm_port_list)} {lappend al(comm_port_list) $pt}
      if {[llength $al(comm_port_list)]>32} break
    }
    set al(EM,DiffTool) [file join {*}[file split $al(EM,DiffTool)]]
    $obDl2 res $win 1
    alited::Exit - 1 no
  }
}
#_______________________

proc pref::Cancel {args} {
  # Handler of "Cancel" button.

  fetchVars
  RestoreSettings
  GetEmSave out
  alited::CloseDlg
  $obDl2 res $win 0
}
#_______________________

proc pref::Tab {tab {nt ""} {doit no}} {
  # Handles changing tabs of notebooks.
  #   tab - name of notebook
  #   nt - tab of notebook
  #   doit - if yes, forces changing tabs.
  # At changing the current notebook: we need to save the old selection
  # in order to restore the selection at returning to the notebook.
  fetchVars
  foreach nbk {nbk nbk2 nbk3 nbk4 nbk5 nbk6} {fillCan [$obDl2 Can$nbk]}
  foreach but {Home Change Categories Actions Keys Tools} {
    [$obDl2 But$but] configure -style TButtonWest
  }
  switch $tab {
    nbk  {set but Home}
    nbk2 {set but Change}
    nbk3 {set but Categories}
    nbk4 {set but Actions}
    nbk5 {set but Keys}
    nbk6 {set but Tools}
  }
  ShowUpDownArrows [expr {$tab ne "nbk6"}]
  CheckTheming no
  [$obDl2 But$but] configure -style TButtonWestHL
  fillCan [$obDl2 Can$tab] yes
  if {$tab ne $curTab || $doit} {
    if {$curTab ne {}} {
      set arrayTab($curTab) [$win.fra.fraR.$curTab select]
      pack forget $win.fra.fraR.$curTab
    }
    set curTab $tab
    pack $win.fra.fraR.$curTab -expand yes -fill both
    catch {
      if {$nt eq {}} {set nt $arrayTab($curTab)}
      $win.fra.fraR.$curTab select $nt
    }
  }
  if {$tab eq {nbk2}} {
    # check if a color scheme is switched light/dark - if yes, disable colors
    set cs [GetCS]
    if {$data(INI,CSsaved)!=$cs} {
      Tcl_Default 0 yes
      C_Default 0 yes
      UpdateSyntaxTab
      UpdateSyntaxTab 2
    }
    lassign [$obDl2 csGet $cs] fg - bg - - sbg sfg ibg
    [$obDl2 TexSample] configure -fg $fg -bg $bg \
      -selectbackground $sbg -selectforeground $sfg -insertbackground $ibg
    [$obDl2 TexCSample] configure -fg $fg -bg $bg \
      -selectbackground $sbg -selectforeground $sfg -insertbackground $ibg
    set data(INI,CSsaved) $cs
  }
  if {[string match root* $geo]} {
    # the geometry of the dialogue - its first setting
    # (makes sense at switching tabs, when open 1st time)
    after 10 [list after 10 [list after 10 [list after 10 "wm geometry $win \[wm geometry $win\]"]]]
  }
  foreach w [$win.fra.fraR.$curTab tabs] {
    if {[string match *$nt $w]} {
      after 10 [list after 10 [list after 10 [list after 10 "::apave::focusFirst $w"]]]
      break
    }
  }
}
#_______________________

proc pref::Help {} {
  # Shows a help on a current tab.

  fetchVars
  set sel [lindex [split [$win.fra.fraR.$curTab select] .] end]
  alited::Help $win "-${curTab}-$sel"
}
#_______________________

proc pref::fillCan {w {selected no}} {

  fetchVars
  catch {$w delete $data(CANVAS,$w)}
  lassign [$obDl2 csGet] - - - bg selbg - - - - hotbg
  if {$selected} {
    set bg $hotbg
    $w configure -highlightbackground $hotbg
  } else {
    $w configure -highlightbackground $bg
  }
  set data(CANVAS,$w) [$w create rectangle {0 0 10 100} -fill $bg -outline $selbg]
}
# ________________________ Tabs "General" _________________________ #

proc pref::General_Tab1 {} {
  # Serves to layout "General" tab.

  fetchVars
  set opcc [set opcc2 [msgcat::mc {-2: Default}]]
  set opcColors [list "{$opcc}"]
  for {set i -1; set n [apave::cs_MaxBasic]} {$i<=$n} {incr i} {
    if {(($i+2) % ($n/2+2)) == 0} {lappend opcColors |}
    set csname [$obDl2 csGetName $i]
    lappend opcColors [list $csname]
    if {$i == $al(INI,CS)} {set opcc $csname}
    if {$i == $al(EM,CS)} {set opcc2 $csname}
  }
  set lightdark [msgcat::mc {Light / Dark}]
  set opcThemes [list default clam classic alt -- "{$lightdark} awlight awdark -- \
    azure-light azure-dark -- forest-light forest-dark -- sun-valley-light sun-valley-dark -- lightbrown darkbrown -- plastik"]
  if {$al(IsWindows)} {
    lappend opcThemes -- "{[msgcat::mc {Windows themes}]} vista xpnative winnative"
  }
  if {[string first $alited::al(THEME) $opcThemes]<0} {
    set opc1 [lindex $opcThemes 0]
  } else {
    set opc1 $alited::al(THEME)
  }
  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labTheme - - 1 1 {-st w -pady 1 -padx 3} {-t "Ttk theme:"}}
    {.opc1 + L 1 1 {-st sw -pady 1} {::alited::pref::opc1 alited::pref::opcThemes {-width 21 -compound left -image alimg_gulls -tip {-indexedtips 5 "-BALTIP {$alited::al(MC,needcs)} -MAXEXP 1"}} {}}}
    {.chbPrv + L 1 1 {-padx 20} {-t "$alited::al(MC,test)" -var alited::pref::preview -com {alited::pref::CheckTheming yes yes}}}
    {.labCS .labTheme T 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.opc2 + L 1 1 {-st sw -pady 1} {::alited::pref::opcc alited::pref::opcColors {-width 21 -compound left -image alimg_color -tip {-indexedtips \
      0 {$alited::al(MC,nocs)} \
      2 {$alited::al(MC,fitcs): awlight} \
      3 {$alited::al(MC,fitcs): azure-light} \
      4 {$alited::al(MC,fitcs): forest-light} \
      5 {$alited::al(MC,fitcs): sun-valley-light} \
      6 {$alited::al(MC,fitcs): lightbrown} \
      26 {$alited::al(MC,fitcs): sun-valley-dark} \
      27 {$alited::al(MC,fitcs): awdark} \
      28 {$alited::al(MC,fitcs): azure-dark} \
      29 {$alited::al(MC,fitcs): forest-dark} \
      30 {$alited::al(MC,fitcs): sun-valley-dark} \
      31 {$alited::al(MC,fitcs): darkbrown} \
      }} {alited::pref::opcToolPre %a}}}
    {.labHue .labCS T 1 1 {-st w -pady 1 -padx 3} {-t "Tint:"}}
    {.SpxHue + L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,HUE) -from -50 -to 50 -tip {$alited::al(MC,hue)}}}
    {seh_ .labHue T 1 2 {-pady 4}}
    {fra2 + T 1 2 {-st nsew -cw 1}}
    {.labLocal - - 1 1 {-st w -pady 1 -padx 3} {-t "Preferable locale:" -tip {$alited::al(MC,locale)}}}
    {.cbxLocal + L 1 1 {-st sew -pady 1 -padx 3} {-tvar alited::al(LOCAL) -values {$alited::pref::locales} -w 4 -tip {$alited::al(MC,locale)} -state readonly -selcombobox alited::pref::GetLocaleImage -afteridle alited::pref::GetLocaleImage}}
    {.LabLocales + L}
    {.labFon .labLocal T 1 1 {-st w -pady 1 -padx 3} {-t "Font:"}}
    {.fonTxt1 + L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(FONT) -w 40}}
    {.labFsz1 .labFon T 1 1 {-st w -pady 1 -padx 3} {-t "Small font size:"}}
    {.spxFsz1 + L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(FONTSIZE,small) -from 6 -to 72}}
    {.labFsz2 .labFsz1 T 1 1 {-st w -pady 1 -padx 3} {-t "Middle font size:"}}
    {.spxFsz2 + L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(FONTSIZE,std) -from 7 -to 72}}
    {.labCurw .labFsz2 T 1 1 {-st w -pady 1 -padx 3} {-t "Cursor width:"}}
    {.spxCurw + L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(CURSORWIDTH) -from 1 -to 8}}
    {seh_2 fra2 T 1 2 {-pady 4}}
    {lab + T 1 2 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra3 + T 1 2 {-st nsew -rw 1 -cw 1}}
    {.TexNotes - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 90 -wrap word -tabnext {alited::Tnext *.spxCurw} -tip {-BALTIP {$alited::al(MC,notes)} -MAXEXP 1}}}
    {.sbv + L - - {pack -side left}}
  }
}
#_______________________

proc pref::General_Tab2 {} {
  # Serves to layout "General/Saving" tab.

  GetEmSave in
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labport - - 1 1 {-st w -pady 1 -padx 3} {-t "Port to listen alited:"}}
    {.cbxport + L 1 1 {-st sw -pady 5} {-tvar alited::al(comm_port) -values {$alited::al(comm_port_list)} -w 8 -tip "The empty value allows\nmultiple alited apps."}}
    {.labConf .labport T 1 1 {-st w -pady 1 -padx 3} {-t "Confirm exit:"}}
    {.spxConf + L 1 1 {-st sw -pady 1 -padx 3} {-tvar alited::al(INI,confirmexit) -from 0 -to 60 -tip {"> 1" : N sec.}}}
    {.seh1 .labConf T 1 4 {-st ew -pady 5}}
    {.labS + T 1 1 {-st w -pady 1 -padx 3} {-t "Save configuration on"}}
    {.labSonadd + T 1 1 {-st e -pady 1 -padx 3} {-t "opening a file:"}}
    {.swiOnadd + L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onadd)}}
    {.labSonclose .labSonadd T 1 1 {-st e -pady 1 -padx 3} {-t "closing a file:"}}
    {.swiOnclose + L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onclose)}}
    {.labSonsave .labSonclose T 1 1 {-st e -pady 1 -padx 3} {-t "saving a file:"}}
    {.swiOnsave + L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onsave)}}
    {.seh2 .labSonsave T 1 4 {-st ew -pady 5}}
    {.labSave + T 1 1 {-st w -pady 1 -padx 3} {-t "Save before bar-menu runs:"}}
    {.cbxSave + L 1 2 {-st sw -pady 1} {-values {$alited::al(pref,saveonrun)} -tvar alited::al(EM,save) -state readonly -w 20}}
    {.seh3 .labSave T 1 4 {-st ew -pady 5}}
    {.labRecnt + T 1 1 {-st w -pady 1 -padx 3} {-t "'Recent Files' length:"}}
    {.spxRecnt + L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,RECENTFILES) -from 10 -to 50}}
    {.labMaxLast .labRecnt T 1 1 {-st w -pady 1 -padx 3} {-t "'Last Visited' length:"}}
    {.spxMaxLast + L 1 1 {-st sw -pady 1} {-tvar alited::al(FAV,MAXLAST) -from 10 -to 100}}
    {.labMaxFiles .labMaxLast T 1 1 {-st w -pady 1 -padx 3} {-t "Maximum of project files:"}}
    {.spxMaxFiles + L 1 1 {-st sw -pady 1} {-tvar alited::al(MAXFILES) -from 1000 -to 9999}}
    {.seh4 .labMaxFiles T 1 4 {-st ew -pady 5}}
    {.labBackup + T 1 1 {-st w -pady 1 -padx 3} {-t "Back up files to a project's subdirectory:"}}
    {.CbxBackup + L 1 1 {-st sw -pady 1} {-tvar alited::al(BACKUP) -values {{} .bak} -state readonly -w 6 -tip "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." -afteridle alited::pref::CbxBackup -selcombobox alited::pref::CbxBackup}}
    {.LabMaxBak + L 1 1 {-st w -pady 1 -padx 1} {-t "  Maximum:"}}
    {.SpxMaxBak + L 1 1 {-st sw -pady 1 -padx 1} {-tvar alited::al(MAXBACKUP) -from 1 -to 99 -tip {$alited::al(MC,maxbak)}}}
    {.labBell .labBackup T 1 1 {-st w -pady 1 -padx 3} {-t "Bell at warnings:"}}
    {.swiBell + L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,belltoll) -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::General_Tab3 {} {
  # Serves to layout "General/Projects" tab.

  return {
    {v_ - - 1 10}
    {fra2 v_ T 1 2 {-st nsew -cw 1}}
    {.labDef - - 1 1 {-st w -pady 1 -padx 3} {-t {Default values for new projects:}}}
    {.swiDef + L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(PRJDEFAULT) -com alited::pref::CheckUseDef -afteridle alited::pref::CheckUseDef}}
    {.seh .labDef T 1 10 {-st ew -pady 3 -padx 3}}
    {.labIgn + T 1 1 {-st w -pady 8 -padx 3} {-t {$alited::al(MC,Ign:)}}}
    {.EntIgn + L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(DEFAULT,prjdirign) -w 50}}
    {.labEOL .labIgn T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,EOL:)}}}
    {.CbxEOL + L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(DEFAULT,prjEOL) -values {{} LF CR CRLF} -state readonly -w 9}}
    {.labIndent .labEOL T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,indent:)}}}
    {.SpxIndent + L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(DEFAULT,prjindent) -from 0 -to 8 -com ::alited::pref::CheckIndent}}
    {.ChbIndAuto + L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(DEFAULT,prjindentAuto) -t {$alited::al(MC,indentAuto)}}}
    {.labRedunit .labIndent T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,redunit)}}}
    {.SpxRedunit + L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(DEFAULT,prjredunit) -from $alited::al(minredunit) -to 100}}
    {.labMult .labRedunit T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,multiline)} -tip {$alited::al(MC,notrecomm)}}}
    {.SwiMult + L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(DEFAULT,prjmultiline) -tip {$alited::al(MC,notrecomm)}}}
    {.labTrWs .labMult T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,trailwhite)}}}
    {.SwiTrWs + L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(DEFAULT,prjtrailwhite) -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::opcToolPre {args} {
  # Gets colors for "Color schemes" items.
  #   args - a color scheme's index and name, separated by ":"

  lassign $args a
  set a [string trim $a :]
  if {[string is integer $a]} {
    lassign [::apave::obj csGet $a] - fg - bg
    return "-background $bg -foreground $fg"
  } else {
    return {}
  }
}
#_______________________

proc pref::CbxBackup {} {
  # Check for access to SpxMaxBak field.
  # If CbxBackup is empty (no backup), SpxMaxBak should be disabled.

  fetchVars
  if {$alited::al(BACKUP) eq {}} {set state disabled} {set state normal}
  [$obDl2 SpxMaxBak] configure -state $state
  [$obDl2 LabMaxBak] configure -state $state
}
#_______________________

proc pref::GetEmSave {to} {
  # Gets a name of setting "Save before run".
  #   to - if "in", gets a localized name; if "out", gets English name

  fetchVars
  set savcur [msgcat::mc {Current file}]
  set savall [msgcat::mc {All files}]
  set al(pref,saveonrun) [list {} $savcur $savall]
  if {$to eq {in}} {
    switch -exact $al(EM,save) {
      Current {set al(EM,save) $savcur}
      All     {set al(EM,save) $savall}
    }
  } elseif {$al(EM,save) eq $savcur} {
    set al(EM,save) Current
  } elseif {$al(EM,save) eq $savall} {
    set al(EM,save) All
  }
}
#_______________________

proc pref::CheckUseDef {} {
  # Enables/disables the project default fields.

  fetchVars
  if {$al(PRJDEFAULT)} {
    set state normal
    [$obDl2 CbxEOL] configure -state readonly
  } else {
    set state disabled
    [$obDl2 CbxEOL] configure -state $state
  }
  foreach w {EntIgn SpxIndent SpxRedunit SwiMult ChbIndAuto SwiTrWs} {
    [$obDl2 $w] configure -state $state
  }
}
#_______________________

proc pref::GetCS {{ncc {}}} {
  # Gets a color scheme's index from *opcc* / *opcc2*  variable.
  #   ncc - {} for opcc, {2} for opcc2

  fetchVars
  return [scan [set opcc$ncc] %d:]
}
#_______________________

proc pref::CsDark {{cs ""}} {
  # Gets a lightness of a color scheme.
  #   cs - the color scheme's index (if omitted, the chosen one's)

  if {$cs eq {}} {set cs [GetCS]}
  return [::apave::obj csDark $cs]
}
#_______________________

proc pref::GetLocaleImage {} {

  fetchVars
  [$obDl2 LabLocales] configure -image alited::pref::LOC$alited::al(LOCAL)
}
#_______________________

proc pref::InitLocales {} {
  # Creates flag images to display at "Preferable locale".

  fetchVars
  if {[llength $locales]} return
  set imd [file join $::alited::DATADIR img]
  set locales [list]
  foreach lm [list en {*}[glob -nocomplain [file join $::alited::MSGSDIR *]]] {
    set loc [file rootname [file tail $lm]]
    catch { ;# no duplicates due to 'catch'
      image create photo alited::pref::LOC$loc -file [file join $imd $loc.png]
      lappend locales $loc
    }
  }
  set locales [lsort $locales]
}
#_______________________

proc pref::CheckIndent {{pre "DEFAULT,"}} {
  # Sets "auto indentation", if indent is 1 (for indentation by Tabs)
  #   pre - prefix: if {}, refers to a project's settings, by default to preferences'

  namespace upvar ::alited al al
  if {$al(${pre}prjindent)<=1} {set al(${pre}prjindentAuto) 1}
}
#_______________________

proc pref::CheckTheming {{doit yes} {force no}} {
  # Checks periodically theming options and, if changed, shows their preview.
  #   doit - if no, deletes both a temporary file and the possible preview
  #   force - if yes, shows the preview by force
  # The theming cannot be nice viewed "on fly", so we need to use a separate app.

  namespace upvar ::alited SRCDIR SRCDIR
  fetchVars
  set fname [file join [alited::tool::EM_dir] preview~]
  if {!$force && (!$doit || !$preview || ![winfo exists $win])} {
    catch {file delete $fname}
    catch {unset al(CheckTheming)}
    return
  }
  set foc [focus]
  set thopts "$opc1 [GetCS] $al(INI,HUE)"
  set timo 100
  if {$force && $preview || \
  [info exists al(CheckTheming)] && $al(CheckTheming) ne $thopts} {
    lassign [split [wm geometry $win] x+] w h x y
    set ch [open $fname w]
    puts $ch "+[expr {$x+$w/6}]+[expr {$y+$h/3}] $thopts $alited::al(MC,test)"
    close $ch
    after 100 [list alited::Run [file join $SRCDIR preview.tcl] $fname]
    set timo 500
  }
  set al(CheckTheming) $thopts
  after $timo alited::pref::CheckTheming
  focus -force $foc
}

# ________________________ Tab "Editor" _________________________ #

proc pref::Edit_Tab1 {} {
  # Serves to layout "Editor" tab.

  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labFon - - 1 1 {-st w -pady 8 -padx 3} {-t Font:}}
    {.fonTxt2 + L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONT,txt) -w 40}}
    {.labSp1 .labFon T 1 1 {-st w -pady 1 -padx 3} {-t {Space above lines:}}}
    {.spxSp1 .labSp1 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp1) -from 0 -to 16}}
    {.labSp3 .labSp1 T 1 1 {-st w -pady 1 -padx 3} {-t {Space below lines:}}}
    {.spxSp3 + L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp3) -from 0 -to 16}}
    {.labSp2 .labSp3 T 1 1 {-st w -pady 1 -padx 3} {-t {Space between wraps:}}}
    {.spxSp2 + L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp2) -from 0 -to 16}}
    {.seh .labSp2 T 1 10 {-pady 3}}
    {.labGW + T 1 1 {-st w -pady 1 -padx 3} {-t {Gutter's width:}}}
    {.spxGW + L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,gutterwidth) -from 3 -to 7}}
    {.labGS .labGW T 1 1 {-st w -pady 1 -padx 3} {-t {Gutter's shift from text:}}}
    {.spxGS + L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,guttershift) -from 0 -to 10}}
    {.seh2 .labGS T 1 10 {-pady 3}}
    {.labLl + T 1 1 {-st w -pady 1 -padx 3} {-t {Tab bar label's length:}}}
    {.spxLl + L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(INI,barlablen) -from 10 -to 100}}
    {.labTl .labLl T 1 1 {-st w -pady 1 -padx 3} {-t {Tab bar tip's length:}}}
    {.spxTl + L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(INI,bartiplen) -from 10 -to 100}}
    {.labBD .labTl T 1 1 {-st w -pady 1 -padx 3} {-t {Border for bar tabs:}}}
    {.swiBD + L 1 1 {-st sw -pady 5 -padx 3} {-var ::alited::al(ED,btsbd) -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::Edit_Tab2 {} {
  # Serves to layout "Tcl syntax" tab.

  return {
    {v_ - - 1 1}
    {FraTab2 v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fraTab2.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "Tcl files' extensions:"}}
    {.entExt + L 1 1 {-st swe -pady 3} {-tvar alited::al(TclExtensions) -w 40}}
    {.labCOM .labExt T 1 1 {-st w -pady 3 -padx 3} {-t "Color of Tcl commands:"}}
    {.clrCOM + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrCOM) -w 20}}
    {.labCOMTK .labCOM T 1 1 {-st w -pady 3 -padx 3} {-t "Color of Tk commands:"}}
    {.clrCOMTK + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrCOMTK) -w 20}}
    {.labSTR .labCOMTK T 1 1 {-st w -pady 3 -padx 3} {-t "Color of strings:"}}
    {.clrSTR + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrSTR) -w 20}}
    {.labVAR .labSTR T 1 1 {-st w -pady 3 -padx 3} {-t "Color of variables:"}}
    {.clrVAR + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrVAR) -w 20}}
    {.labCMN .labVAR T 1 1 {-st w -pady 3 -padx 3} {-t "Color of comments:"}}
    {.clrCMN + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrCMN) -w 20}}
    {.labPROC .labCMN T 1 1 {-st w -pady 3 -padx 3} {-t "Color of proc/methods:"}}
    {.clrPROC + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrPROC) -w 20}}
    {.labOPT .labPROC T 1 1 {-st w -pady 3 -padx 3} {-t "Color of options:"}}
    {.clrOPT + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrOPT) -w 20}}
    {.labBRA .labOPT T 1 1 {-st w -pady 3 -padx 3} {-t "Color of brackets:"}}
    {.clrBRA + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrBRA) -w 20}}
    {.seh .labBRA T 1 2 {-pady 3}}
    {fraTab2.scf.FraDefClr1 + T 1 2 {-st nsew}}
    {.but - - 1 1 {-st w -padx 0} {-t {Default} -com {alited::pref::Tcl_Default 0}}}
    {.but1 + L 1 1 {-st w -padx 8} {-t {Default 2} -com {alited::pref::Tcl_Default 1}}}
    {.but2 + L 1 1 {-st w -padx 0} {-t {Default 3} -com {alited::pref::Tcl_Default 2}}}
    {.but3 + L 1 1 {-st w -padx 8} {-t {Default 4} -com {alited::pref::Tcl_Default 3}}}
    {fraTab2.scf.sehclr fraTab2.scf.FraDefClr1 T 1 2 {-pady 5}}
    {fraTab2.scf.fra2 + T 1 2 {-st nsew}}
    {.lab - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Code snippet:"}}
    {.TexSample - - - - {pack -side left -fill both -expand 1} {-h 7 -w 48 -afteridle alited::pref::UpdateSyntaxTab -tabnext "*.texTclKeys *.but3"}}
    {.sbv + L - - {pack -side right}}
    {fraTab2.scf.seh3 fraTab2.scf.fra2 T 1 2 {-pady 5}}
    {fraTab2.scf.fra3 + T 1 2 {-st nsew}}
    {.labAddKeys - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Your commands:"}}
    {.TexTclKeys - - - - {pack -side left -fill both -expand 1} {-h 3 -w 48 -wrap word -tabnext {alited::Tnext *.texSample}}}
    {.sbv + L - - {pack -side right}}
  }
}
#_______________________

proc pref::Edit_Tab3 {} {
  # Serves to layout "C/C++ syntax" tab.

  return {
    {v_ - - 1 1}
    {FraTab3 + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fraTab3.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "C/C++ files' extensions:"}}
    {.entExt + L 1 1 {-st swe -pady 3} {-tvar alited::al(ClangExtensions) -w 40}}
    {.labCOM2 .labExt T 1 1 {-st w -pady 3 -padx 3} {-t "Color of C key words:"}}
    {.clrCOM2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCOM) -w 20}}
    {.labCOMTK2 .labCOM2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of C++ key words:"}}
    {.clrCOMTK2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCOMTK) -w 20}}
    {.labSTR2 .labCOMTK2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of strings:"}}
    {.clrSTR2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrSTR) -w 20}}
    {.labVAR2 .labSTR2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of punctuation:"}}
    {.clrVAR2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrVAR) -w 20}}
    {.labCMN2 .labVAR2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of comments:"}}
    {.clrCMN2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCMN) -w 20}}
    {.labPROC2 .labCMN2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of return/goto:"}}
    {.clrPROC2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrPROC) -w 20}}
    {.labOPT2 .labPROC2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of your key words:"}}
    {.clrOPT2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrOPT) -w 20}}
    {.labBRA2 .labOPT2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of brackets:"}}
    {.clrBRA2 + L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrBRA) -w 20}}
    {.seh .labBRA2 T 1 2 {-pady 3}}
    {fraTab3.scf.FraDefClr2 + T 1 2 {-st nsew}}
    {.but - - 1 1 {-st w -padx 0} {-t {Default} -com {alited::pref::C_Default 0}}}
    {.but1 + L 1 1 {-st w -padx 8} {-t {Default 2} -com {alited::pref::C_Default 1}}}
    {.but2 + L 1 1 {-st w -padx 0} {-t {Default 3} -com {alited::pref::C_Default 2}}}
    {.but3 + L 1 1 {-st w -padx 8} {-t {Default 4} -com {alited::pref::C_Default 3}}}
    {fraTab3.scf.sehclr fraTab3.scf.fraDefClr2 T 1 2 {-pady 5}}
    {fraTab3.scf.fra2 + T 1 2 {-st nsew}}
    {.lab - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Code snippet:"}}
    {.TexCSample - - - - {pack -side left -fill both -expand 1} {-h 7 -w 48 -wrap word -tabnext "*.texCKeys *.but3"}}
    {.sbv + L - - {pack -side right}}
    {fraTab3.scf.seh3 fraTab3.scf.fra2 T 1 2 {-pady 5}}
    {fraTab3.scf.fra3 + T 1 2 {-st nsew}}
    {.lab - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Your key words:"}}
    {.TexCKeys - - - - {pack -side left -fill both -expand 1} {-h 3 -w 48 -wrap word -tabnext {alited::Tnext *.texCSample}}}
    {.sbv + L - - {pack -side right}}
  }
}
#_______________________

proc pref::Edit_Tab4 {} {
  # Serves to layout "Misc syntax" tab.

  return {
    {v_ - - 1 1}
    {FraTab4 + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fraTab4.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "Plain texts' extensions:"}}
    {.entExt + L 1 1 {-st swe -pady 3} {-tvar alited::al(TextExtensions) -w 54}}
    {.seh .labExt T 1 2 {-pady 3}}
    {.but + T 1 1 {-st w} {-t Default -com alited::pref::Text_Default -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::Tcl_Default {isyn {init no}} {
  # Sets default colors to highlight Tcl.
  #   isyn - index of syntax colors
  #   init - yes, if only variables should be initialized

  fetchVars
  set al(TclExtensions) $al(TclExtensionsDef)
  set Dark [CsDark]
  set clrnams [::hl_tcl::hl_colorNames]
  set clrvals [::hl_tcl::hl_colors $isyn $Dark]
  foreach nam $clrnams val $clrvals {
    set al(ED,$nam) $val
  }
  set al(ED,Dark) $Dark
  if {!$init} UpdateSyntaxTab
  set al(syntaxidx) $isyn
}
#_______________________

proc pref::C_Default {isyn {init no}} {
  # Sets default colors to highlight C.
  #   isyn - index of syntax colors
  #   init - yes, if only variables should be initialized

  fetchVars
  set al(ClangExtensions) $al(ClangExtensionsDef)
  set Dark [CsDark]
  set clrnams [::hl_tcl::hl_colorNames]
  set clrvals [::hl_c::hl_colors $isyn $Dark]
  foreach nam $clrnams val $clrvals {
    set al(ED,C$nam) $val
  }
  if {!$init} {UpdateSyntaxTab 2}
  set al(syntaxidx) $isyn
}
#_______________________

proc pref::Text_Default {} {
  # Sets defaults for plain text.

  fetchVars
  set al(TextExtensions) $al(TextExtensionsDef)
  update
}
#_______________________

proc pref::InitSyntax {lng} {
  # Updates and initializes color fields.
  #   lng - {} for Tcl, {2} for C/C++

  fetchVars
  foreach nam {COM COMTK STR VAR CMN PROC OPT BRA} {
    set ent [$obDl2 Entclr$nam$lng] ;# method's name, shown by -debug attribute
    set lab [string map [list .entclr .labclr] $ent]  ;# colored label
    $lab configure -background [$ent get]
    ::apave::bindToEvent $ent <FocusIn> alited::pref::UpdateSyntaxTab $lng
    ::apave::bindToEvent $ent <FocusOut> alited::pref::UpdateSyntaxTab $lng
  }
}
#_______________________

proc pref::InitSyntaxTcl {colors} {
  # Initializes syntax stuff for Tcl.
  #    colors - highlighting colors

  fetchVars
  set tex [$obDl2 TexSample]
  lassign [$obDl2 csGet] - - - - - - - - tfgD bclr
  $tex configure -highlightbackground $tfgD -highlightcolor $bclr
  set texC [$obDl2 TexCSample]
  $texC configure -highlightbackground $tfgD -highlightcolor $bclr
  if {[string trim [$tex get 1.0 end]] eq {}} {
  $obDl2 displayText $tex {proc foo {args} {
  # Tcl code to test colors.
  set var "(Multiline string)
    Args=$args"
  winfo interps -displayof [lindex $args 0]
  return $var ;#! text of TODO
}}}
  set wk [$obDl2 TexTclKeys]
  ::apave::bindToEvent $wk <FocusOut> alited::pref::UpdateSyntaxTab
  set keywords [string trim [$wk get 1.0 end]]
  alited::SyntaxHighlight tcl $tex $colors [GetCS] -keywords $keywords
}
#_______________________

proc pref::InitSyntaxC {colors} {
  # Initializes syntax stuff for C/C++.
  #    colors - highlighting colors

  fetchVars
  set tex [$obDl2 TexCSample]
  if {[string trim [$tex get 1.0 end]] eq {}} {
    $obDl2 displayText $tex {static sample(const char *ptr) {
  /*   C/C++ code to test colors.   */
  char *text, *st;
  text = read_text();
  st   = read_string();
  if (strstr(text, st) != text) return FALSE;
  text += strlen(st);
  ptr = strstr(text + 1, "My string"); // error
  return TRUE
}}}
  set wk [$obDl2 TexCKeys]
  ::apave::bindToEvent $wk <FocusOut> alited::pref::UpdateSyntaxTab 2
  set keywords [string trim [$wk get 1.0 end]]
  alited::SyntaxHighlight c $tex $colors [GetCS] -keywords $keywords
}
#_______________________

proc pref::UpdateSyntaxTab {{lng ""}} {
  # Updates color labels at clicking "Default" button.
  #   lng - {} for Tcl, {2} for C/C++

  fetchVars
  catch {
    InitSyntax $lng
    foreach nam [::hl_tcl::hl_colorNames] {
      lappend colors $al(ED,$nam)
      lappend Ccolors $al(ED,C$nam)
    }
    lassign [::hl_tcl::addingColors [CsDark] {} [GetCS]] clrCURL clrCMN2
    lappend colors $clrCURL $clrCMN2
    lappend Ccolors $clrCURL $clrCMN2
    InitSyntaxTcl $colors
    InitSyntaxC $Ccolors
  }
}

# ________________________ Tab "Template" _________________________ #

proc pref::Template_Tab {} {
  # Serves to layout "Template" tab.

  return {
    {v_ - - 1 1}
    {fra v_ T 1 2 {-st nsew -cw 1}}
    {.labH - - 1 2 {-st w -pady 5 -padx 3} {-t "Enter %U, %u, %m, %w, %d, %t wildcards of templates:"}}
    {.labU + T 1 1 {-st w -pady 1 -padx 3} {-t "User name:"}}
    {.entU + L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%U) -w 40}}
    {.labu .labU T 1 1 {-st w -pady 1 -padx 3} {-anc e -t "Login:"}}
    {.entu + L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%u) -w 30}}
    {.labm .labu T 1 1 {-st w -pady 1 -padx 3} {-t "E-mail:"}}
    {.entm + L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%m) -w 40}}
    {.labw .labm T 1 1 {-st w -pady 1 -padx 3} {-t "WWW:"}}
    {.entw + L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%w) -w 40}}
    {.labd .labw T 1 1 {-st w -pady 1 -padx 3} {-t "Date format:"}}
    {.entd + L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%d) -w 30}}
    {.labt .labd T 1 1 {-st w -pady 1 -padx 3} {-t "Time format:"}}
    {.entt + L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%t) -w 30}}
    {.seh .labt T 1 2 {-pady 3}}
    {.but + T 1 1 {-st w} {-t {$::alited::al(MC,tpllist)} -com {alited::unit_tpl::_run no "-centerme $::alited::pref::win"} -tabnext alited::Tnext}}
  }
}

# ________________________ Tab "Keys" _________________________ #

proc pref::Keys_Tab1 {} {
  # Serves to layout "Keys" tab.

  return {
    {after idle}
    {v_ - - 1 1}
    {fra + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {tcl {
        set pr -
        for {set i 0} {$i<$alited::pref::stdkeysSize} {incr i} {
          set lab "lab$i"
          set cbx "CbxKey$i"
          lassign [dict get $alited::pref::stdkeys $i] text key
          set lwid ".$lab $pr T 1 1 {-st w -pady 1 -padx 3} {-t \"$text\"}"
          %C $lwid
          if {($i+1)==$alited::pref::stdkeysSize} {
            set pr {-tabnext alited::Tnext}
          } else {
            set pr {}
          }
          set lwid ".$cbx + L 1 1 {-st we} {-tvar ::alited::pref::keys($i) -postcommand {::alited::pref::GetKeyList $i} -selcombobox {::alited::pref::SelectKey $i} -state readonly -h 16 -w 20 $pr}"
          %C $lwid
          set pr .$lab
        }
    }}
  }
}
#_______________________

proc pref::RegisterKeys {} {
  # Adds key bindings to keys array.

  fetchVars
  alited::keys::Delete preference
  for {set k 0} {$k<$stdkeysSize} {incr k} {
    alited::keys::Add preference $k [set keys($k)] "alited::pref::BindKey $k {%k}"
  }
}
#_______________________

proc pref::GetKeyList {nk} {
  # Gets a list of available (not engaged) key combinations.
  #   nk - index of combobox that will get the list as -values option

  fetchVars
  RegisterKeys
  [$obDl2 CbxKey$nk] configure -values [alited::keys::VacantList]
}
#_______________________

proc pref::SelectKey {nk} {
  # Handles <<ComboboxSelected>> event on a combobox of keys.
  #   nk - index of combobox

  fetchVars
  alited::keys::Delete {} $prevkeys($nk)
  set prevkeys($nk) $keys($nk)
  GetKeyList $nk
}
#_______________________

proc pref::KeyAccelerator {nk defk} {
  # Gets a key accelerator for a combobox of keys, bound to an action.
  #   nk - index of combobox
  #   defk - default key combination

  set acc [BindKey $nk - $defk]
  return [::apave::KeyAccelerator $acc]
}
#_______________________

proc pref::KeyAccelerators {} {
  # Gets a full list of key accelerators,

  fetchVars
  dict for {k info} $stdkeys {
    set al(acc_$k) [KeyAccelerator $k [lindex $info 1]]
  }
}
#_______________________

proc pref::BindKey {nk {key ""} {defk ""}} {
  # Binds a key event to a key combination.
  #   nk - index of combobox corresponding to the event
  #   key - key combination or "-" (for not engaged keys)
  #   defk - default key combination
  # Returns a bound keys for not engaged keys or {} for others.

  fetchVars
  if {$key eq {-}} {
    # not engaged event: bind to a new combination if defined
    if {[info exists keys($nk)]} {
      return $keys($nk)
    }
    # otherwise bind to the default
    return $defk
  }
  switch $nk {
    4 { ;# "Double Selection"
      ::apave::setTextHotkeys CtrlD $keys($nk)
    }
    5 { ;# "Delete Line"
      ::apave::setTextHotkeys CtrlY $keys($nk)
    }
    10 { ;# "Highlight First"
      ::apave::setTextHotkeys AltQ $keys($nk)
    }
    11 { ;# "Highlight Last"
      ::apave::setTextHotkeys AltW $keys($nk)
    }
  }
  return {}
}
#_______________________

proc pref::IniKeys {} {
  # Gets key settings at opening "Preferences" dialogue.

  fetchVars
  # default settings
  dict for {k info} $stdkeys {
    set keys($k) [set prevkeys($k) [set savekeys($k) [lindex $info 1]]]
  }
  # new settings
  foreach kitem [alited::keys::EngagedList preference] {
    lassign $kitem key comi
    lassign $comi com k
    set keys($k) [set prevkeys($k) [set savekeys($k) $key]]
  }
}

# ________________________ Units _________________________ #

proc pref::Units_Tab {} {
  # Serves to layout "Units" tab.

  return {
    {v_ - - 1 1}
    {fra + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labBr - - 1 1 {-st w -pady 1 -padx 3} {-t "Branch's regexp:"}}
    {.entBr + L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,branch) -w 70}}
    {.labPr .labBr T 1 1 {-st w -pady 1 -padx 3} {-t "Proc's regexp:"}}
    {.entPr + L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,proc) -w 70}}
    {.seh_0 .labPr T 1 2 {-pady 5}}
    {.labLf2 + T 1 1 {-st w -pady 1 -padx 3} {-t "Check branch's regexp:"}}
    {.entLf2 + L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,leaf2) -w 70}}
    {.labPr2 .labLf2 T 1 1 {-st w -pady 1 -padx 3} {-t "Check proc's regexp:"}}
    {.entPr2 + L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,proc2) -w 70}}
    {.seh_1 .labPr2 T 1 2 {-pady 5}}
    {.labUself + T 1 1 {-st w -pady 1 -padx 3} {-t "Use leaf's regexp:"}}
    {.swiUself + L 1 1 {-st sw -pady 1} {-var alited::al(INI,LEAF) -onvalue yes -offvalue no -com alited::pref::CheckUseLeaf -afteridle alited::pref::CheckUseLeaf}}
    {.labLf .labUself T 1 1 {-st w -pady 1 -padx 3} {-t "Leaf's regexp:"}}
    {.EntLf + L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,leaf) -w 70}}
    {.seh_2 .labLf T 1 2 {-pady 5}}
    {.labUnt + T 1 1 {-st w -pady 1 -padx 3} {-t "Untouched top lines:"}}
    {.spxUnt + L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,LINES1) -from 2 -to 200 -w 9}}
    {.seh_3 .labUnt T 1 2 {-pady 5}}
    {.but + T 1 1 {-st w} {-t Default -com alited::pref::Units_Default -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::Units_Default {} {
  # Sets the default settings of units.

  fetchVars
  set al(INI,LINES1) 10
  set al(INI,LEAF) 0
  set al(RE,branch) $al(RE,branchDEF)
  set al(RE,leaf) $al(RE,leafDEF)
  set al(RE,proc) $al(RE,procDEF)
  set al(RE,leaf2) $al(RE,leaf2DEF)
  set al(RE,proc2) $al(RE,proc2DEF)

}
#_______________________

proc pref::CheckUseLeaf {} {
  # Enables/disables the "Regexp of a leaf" field.

  fetchVars
  if {$al(INI,LEAF)} {set state normal} {set state disabled}
  [$obDl2 EntLf] configure -state $state
}

# ________________________ Tab "Tools" _________________________ #

proc pref::Common_Tab {} {
  # Serves to layout "Tools/Common" tab.

  fetchVars
  if {$al(EM,Tcl) eq {}} {
    set al(TCLINIDIR) [info nameofexecutable]
  } else {
    set al(TCLINIDIR) $al(EM,Tcl)
  }
  set al(TCLINIDIR) [file dirname $al(TCLINIDIR)]
  set al(TCLLIST) [split $al(EM,TclList) \t]
  set al(TTLIST) [split $al(EM,tt=List) \t]
  set al(WTLIST) [split $al(EM,wt=List) \t]
  return {
    {v_ - - 1 1}
    {fra + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labTcl - - 1 1 {-st w -pady 1 -padx 3} {-t "tclsh, wish or tclkit:"}}
    {.fiLTcl + L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,Tcl) -values {$alited::al(TCLLIST)} -w 48 -initialdir $alited::al(TCLINIDIR) -clearcom {alited::main::ClearCbx %w ::alited::al(TCLLIST)}}}
    {.labDoc .labTcl T 1 1 {-st w -pady 1 -padx 3} {-t "Path to man/tcl:"}}
    {.dirDoc + L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,h=) -w 48}}
    {.labTT .labDoc T 1 1 {-st w -pady 1 -padx 3} {-t "Linux terminal:"}}
    {.cbxTT + L 1 1 {-st swe -pady 5} {-tvar alited::al(EM,tt=) -w 48 -values {$alited::al(TTLIST)} -clearcom {alited::main::ClearCbx %w ::alited::al(TTLIST)}}}
    {.labWT .labTT T 1 1 {-st w -pady 1 -padx 3} {-t "MS Windows shell:"}}
    {.cbxWT + L 1 1 {-st swe -pady 5} {-tvar alited::al(EM,wt=) -w 48 -values {$alited::al(WTLIST)}}}
    {.labDF .labWT T 1 1 {-st w -pady 1 -padx 3} {-t "Diff tool:"}}
    {.filDF + L 1 1 {-st sw -pady 1} {-tvar alited::al(EM,DiffTool) -w 48 -tabnext alited::Tnext}}
  }
}

## ________________________ e_menu _________________________ ##

proc pref::Emenu_Tab {} {
  # Serves to layout "Tools/e_menu" tab.

  set al(EM,exec) yes
# just now, "internal" e_menu isn't working with alited's "Run"
#    #\{.labExe - - 1 1 #\{-st w -pady 1 -padx 3#\} #\{-t "Run as external app:"#\}#\}
#    #\{.swiExe .labExe L 1 1 #\{-st sw -pady 5#\} #\{-var alited::al(EM,exec) -onvalue yes -offvalue no -com alited::pref::OwnCS#\}#\}
#    #\{.labCS .labExe T 1 1 #\{-st w -pady 1 -padx 3#\} #\{-t "Color scheme:"#\}#\}
  return {
    {v_ - - 1 1}
    {fra + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labCS - - 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.SwiCS + L 1 1 {-st sw -pady 5} {-t {e_menu's own} -var alited::al(EM,ownCS) -com alited::pref::OwnCS -afteridle alited::pref::OwnCS}}
    {.OpcCS + L 1 1 {-st sew -pady 5} {::alited::pref::opcc2 alited::pref::opcColors {-width 21 -compound left -image alimg_color} {alited::pref::opcToolPre %a}}}
    {.labGeo .labCS T 1 1 {-st w -pady 1 -padx 3} {-t Geometry:}}
    {.entGeo + L 1 2 {-st sew -pady 5} {-tvar alited::al(EM,geometry)}}
    {.labDir .labGeo T 1 1 {-st w -pady 1 -padx 3} {-t "Directory of menus:"}}
    {.dirEM + L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,mnudir) -w 48}}
    {.labMenu .labDir T 1 1 {-st w -pady 1 -padx 3} {-t "Main menu:"}}
    {.filMenu + L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,mnu) -w 48 -filetypes {{{Menus} .em} {{All files} .* }}}}
    {.labPD .labMenu T 1 1 {-st w -pady 1 -padx 3} {-t "Projects (%PD wildcard):"}}
    {.filPD + L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,PD=) -w 48}}
    {.seh .labPD T 1 3 {-st ew -pady 5}}
    {.h_ + T}
    {.but1 .h_ L 1 1 {-st w} {-t Default -com alited::pref::Default_e_menu}}
    {.butok + L 1 1 {-st w} {-t "$alited::al(MC,test)" -com alited::pref::Test_e_menu -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::Default_e_menu {} {
  # Set default a_menu settings.

  fetchVars
  set al(EM,exec) yes
  set al(EM,ownCS) no
  set al(EM,geometry) {}
  set emdir [file join $::alited::USERDIR e_menu]
  set al(EM,mnudir) [file join $emdir menus]
  set al(EM,mnu) [file join $al(EM,mnudir) menu.em]
  set al(EM,PD=) [file join $emdir em_projects]
}
#_______________________

proc pref::Test_e_menu {} {
  # Tests a_menu settings.

  fetchVars
  set cs $al(EM,CS)
  set al(EM,CS) [GetCS 2]
  alited::tool::e_menu o=0 TEST_ALITED
  set al(EM,CS) $cs
}

## ________________________ tkcon _________________________ ##

proc pref::Tkcon_Tab {} {
  # Serves to layout "Tools/Tkcon" tab.

  return {
    {v_ - - 1 1}
    {fra + T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {fra.scf.lfr - - 1 1  {pack -fill x} {-t Colors}}
    {.Labbg - - 1 1 {-st w -pady 1 -padx 3} {-t "bg:"}}
    {.clrbg + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrbg) -w 20}}
    {.labblink .labbg T 1 1 {-st w -pady 1 -padx 3} {-t "blink:"}}
    {.clrblink + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrblink) -w 20}}
    {.labcursor .labblink T 1 1 {-st w -pady 1 -padx 3} {-t "cursor:"}}
    {.clrcursor + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrcursor) -w 20}}
    {.labdisabled .labcursor T 1 1 {-st w -pady 1 -padx 3} {-t "disabled:"}}
    {.clrdisabled + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrdisabled) -w 20}}
    {.labproc .labdisabled T 1 1 {-st w -pady 1 -padx 3} {-t "proc:"}}
    {.clrproc + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrproc) -w 20}}
    {.labvar .labproc T 1 1 {-st w -pady 1 -padx 3} {-t "var:"}}
    {.clrvar + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrvar) -w 20}}
    {.labprompt .labvar T 1 1 {-st w -pady 1 -padx 3} {-t "prompt:"}}
    {.clrprompt + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrprompt) -w 20}}
    {.labstdin .labprompt T 1 1 {-st w -pady 1 -padx 3} {-t "stdin:"}}
    {.clrstdin + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrstdin) -w 20}}
    {.labstdout .labstdin T 1 1 {-st w -pady 1 -padx 3} {-t "stdout:"}}
    {.clrstdout + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrstdout) -w 20}}
    {.labstderr .labstdout T 1 1 {-st w -pady 1 -padx 3} {-t "stderr:"}}
    {.clrstderr + L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrstderr) -w 20}}
    {fra.scf.v_ fra.scf.lfr T 1 1  {pack} {-h 10}}
    {fra.scf.lfr2 - - - - {pack -fill x} {-t Options}}
    {.entopts - - 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,options) -w 80}}
    {fra.scf.frabuts - - - - {pack -fill x}}
    {.but1 - - - - {-pady 8} {-t Default -com {alited::pref::Tkcon_Default1; alited::pref::UpdateTkconTab}}}
    {.but2 + L 1 1 {-padx 8} {-t {Default 2} -com {alited::pref::Tkcon_Default2; alited::pref::UpdateTkconTab}}}
    {.butok + L 1 1 {} {-t "$alited::al(MC,test)" -com alited::tool::tkcon -tabnext alited::Tnext}}
  }
}
#_______________________

proc pref::UpdateTkconTab {} {
  # Updates color labels for "Tools/Tkcon" tab.

  fetchVars
  set lab1 [$obDl2 Labbg]
  foreach nam {bg blink cursor disabled proc var prompt stdin stdout stderr} {
    set lab [string map [list labbg labclr$nam] $lab1]
    set ent [string map [list labbg entclr$nam] $lab1]
    $lab configure -background [$ent get]
  }
}
#_______________________

proc pref::Tkcon_Default {} {
  # Sets defaults for "Tools/Tkcon" tab.

  fetchVars
  set al(tkcon,options) {-rows 24 -cols 80 -fontsize 13 -geometry {} -showmenu 1 -topmost 0}
}
#_______________________

proc pref::Tkcon_Default1 {} {
  # Sets light theme colors for Tkcon.

  fetchVars
  Tkcon_Default
  foreach {clr val} { \
  bg #FFFFFF blink #FFFF00 cursor #000000 disabled #4D4D4D proc #008800 \
  var #FFC0D0 prompt #8F4433 stdin #000000 stdout #0000FF stderr #FF0000} {
    set al(tkcon,clr$clr) $val
  }
}
#_______________________

proc pref::Tkcon_Default2 {} {
  # Sets dark theme colors for Tkcon.

  fetchVars
  Tkcon_Default
  foreach {clr val} { \
  bg #25292b blink #929281 cursor #FFFFFF disabled #999797 proc #66FF10 \
  var #565608 prompt #ffff00 stdin #FFFFFF stdout #aeaeae stderr #ff7272} {
    set al(tkcon,clr$clr) $val
  }
}

## ________________________ bar-menu _________________________ ##

proc pref::Runs_Tab {tab} {
  # Prepares and layouts "Tools/bar-menu" tab.
  #   tab - a tab to open (saved at previous session) or {}

  fetchVars
  # get a list of all available icons for "bar-menu" actions
  set listIcons [::apave::iconImage]
  set em_Icons [list]
  set n [llength $listIcons]
  set icr 0
  set ncr 0
  for {set i 0} {$i<($n+43)} {incr i} {
    if {$icr && ($icr % 13) == 0} {lappend em_Icons |}
    set ii [expr {$icr-$ncr}]
    if {$i<$n} {
      set ico [lindex $listIcons $i]
      if {$ico in [ReservedIcons]} continue
      lappend em_Icons $ico
      incr ncr
    } elseif {$ii<10} {
      lappend em_Icons $ii
    } else {
      set ico [string index [TextIcons] [expr {$ii -10}]]
      lappend em_Icons [alited::TextIcon $ico]
    }
    incr icr
  }
  Em_ShowAll no
  # get a layout of "bar-menu" tab
  set res {
    {v_ - - 1 1}
    {fra + T 1 1 {-st nsew -cw 1 -rw 1} {-afteridle ::alited::pref::Em_ShowAll}}
    {fra.ScfRuns - - 1 1  {pack -fill both -expand 1}}
    {tcl {
        set prt "- -"
        for {set i 0} {$i<$::alited::pref::em_Num} {incr i} {
          set nit [expr {$i+1}]
          set lwid ".btTAdd$i $prt 1 1 {-padx 0} {-tip {Inserts a new line.} -com {::alited::pref::Em_AddLine $i} -image alimg_add}"
          %C $lwid
          set lwid ".btTDel$i + L 1 1 {-padx 1} {-tip {Deletes a line.} -com {::alited::pref::Em_DelLine $i} -image alimg_delete}"
          %C $lwid
          set lwid ".ChbMT$i + L 1 1 {-padx 10} {-t separator -var ::alited::pref::em_sep($i) -tip {If 'yes', means a separator of the toolbar/menu.} -com {::alited::pref::Em_Chbox $i}}"
          %C $lwid
          set lwid ".OpcIco$i + L 1 1 {-st nsw} {::alited::pref::em_ico($i) alited::pref::em_Icons {-width 9 -com alited::pref::Em_ShowAll -tooltip {{An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar.}}} {alited::pref::opcIcoPre %a}}"
          %C $lwid
          set lwid ".ButMnu$i + L 1 1 {-st sw -pady 1 -padx 10} {-t {$::alited::pref::em_mnu($i)} -com {alited::pref::PickMenuItem $i} -style TButtonWest -tip {{The run item for the menu and/or the toolbar.\nSelect it from the e_menu items.}}}"
          %C $lwid
          set prt ".btTAdd$i T"
      }}
    }
  }
  if {$tab eq {Emenu_Tab} || \
  ($oldTab ne {} && [string match *nbk6.f3 $arrayTab($oldTab)])} {
    # "Run" items should be displayed immediately
    return $res
  }
  # "Run" items can be created with a little delay
  # imperceptible for a user, saving his/her time
  return [linsert $res 0 {after 500}]
}
#_______________________

proc pref::Em_AddLine {idx} {
  # Inserts a new "bar-menu" action before a current one.
  #   idx - index of a current action

  fetchVars
  for {set i $em_Num} {$i>$idx} {} {
    incr i -1
    if {$i==$idx} {
      lassign {} em_mnu($i) em_ico($i) em_inf($i)
      set em_sep($i) 0
    } else {
      # lower all the rest actions
      set ip [expr {$i-1}]
      set em_sep($i) $em_sep($ip)
      set em_ico($i) $em_ico($ip)
      set em_mnu($i) $em_mnu($ip)
      set em_inf($i) $em_inf($ip)
    }
  }
  Em_ShowAll
}
#_______________________

proc pref::Em_DelLine {idx} {
  # Deletes a current "bar-menu" action.
  #   idx - index of a current action

  fetchVars
  for {set i $idx} {$i<$em_Num} {incr i} {
    if {$i==($em_Num-1)} {
      lassign {} em_mnu($i) em_ico($i) em_inf($i)
      set em_sep($i) 0
    } else {
      # make upper all the rest actions
      set ip [expr {$i+1}]
      set em_sep($i) $em_sep($ip)
      set em_ico($i) $em_ico($ip)
      set em_mnu($i) $em_mnu($ip)
      set em_inf($i) $em_inf($ip)
    }
  }
  Em_ShowAll
  ScrollRuns
}
#_______________________

proc pref::Em_ShowAll {{upd yes}} {
  # Handles separators of bar-menu.
  #   upd - if yes, displays the widgets of bar-menu settings.
  fetchVars
  for {set i 0} {$i<$em_Num} {incr i} {
    if {![info exists em_sep($i)]} {
      lassign {} em_inf($i) em_mnu($i) em_ico($i) em_sep($i)
    }
    set em_sep($i) [string is true -strict $em_sep($i)]
    if {$em_sep($i)} {
      lassign {} em_inf($i) em_mnu($i) em_ico($i)
    }
    if {$upd} {
      if {$em_sep($i)} {set state disabled} {set state normal}
      [$obDl2 ButMnu$i] configure -text $em_mnu($i) -state $state
      set ico [$obDl2 OpcIco$i]
      if {[set k [lsearch $listIcons [$ico cget -text]]]>-1} {
        set img [::apave::iconImage [lindex $listIcons $k]]
        set cmpd left
      } else {
        set img alimg_none
        set cmpd right
      }
      $ico configure -state $state -image $img -compound $cmpd
    }
  }
  if {$upd} ScrollRuns
}
#_______________________

proc pref::Em_Chbox {it} {
  # Handles "bar-menu" checkbox's clicking.
  #   it - index of "bar-menu" item
  # Saves "bar-menu" item to restore it after 2nd click.

  fetchVars
  set sv ::alited::pref::Chbox_savedinfo
  set svico ::alited::pref::Chbox_savedinfoico
  set svmnu ::alited::pref::Chbox_savedinfomnu
  set svinf ::alited::pref::Chbox_savedinfoinf
  if {![info exists $sv] || [set $sv] != $it} {
    set $sv $it
    set $svico {}
    set $svico {}
    set $svmnu {}
    set $svinf {}
  }
  if {$em_sep($it)} {
    set $svico $em_ico($it)
    set $svmnu $em_mnu($it)
    set $svinf $em_inf($it)
  } else {
    set em_ico($it) [set $svico]
    set em_mnu($it) [set $svmnu]
    set em_inf($it) [set $svinf]
  }
  Em_ShowAll
}
#_______________________

proc pref::PickMenuItem {it} {
  # Selects e_menu's action for a "bar-menu" item.
  #   it - index of "bar-menu" item

  fetchVars
  ::alited::source_e_menu
  set w [$obDl2 ButMnu$it]
  set X [winfo rootx $w]
  set Y [winfo rooty $w]
  set res [::em::main -prior 1 -modal 1 -remain 0 -noCS 1 \
    {*}[alited::tool::EM_Options \
    "pk=yes dk=dock o=-1 t=1 g=+[incr X 5]+[incr Y 25] mp=1"]]
  lassign $res menu idx item
  if {$item ne {}} {
    set item1 [lindex [alited::tool::EM_Structure $menu] $idx-1 1]
    lassign [split $item1 -\n] -> item2 item3
    if {$item2 ne $item3 && [string match *.em $item2]} {
      append item2 ": $item3"  ;# it's a menu call title
      set idx - ;# to open the whole menu
    }
    $w configure -text $item2
    set em_mnu($it) [alited::NormalizeName $item2]
    set em_inf($it) [list [file tail $menu] $idx $item2]
    ScrollRuns
  }
  focus -force $w
}
#_______________________

proc pref::ScrollRuns {} {
  # Updates scrollbars of bar-menu tab because its contents may have various length.

  fetchVars
  update
  ::apave::sframe resize [$obDl2 ScfRuns]
}
#_______________________

proc pref::opcIcoPre {args} {
  # Gets an item for icon list of a bar-menu action.
  #   args - contains a name of current icon

  fetchVars
  lassign $args a
  if {[set i [lsearch $listIcons $a]]>-1} {
    set img [::apave::iconImage [lindex $listIcons $i]]
    set res "-image $img -compound left "
  } else {
    set res {}
  }
  append res "-label " [alited::TextIcon $a]
}
#_______________________

proc pref::OwnCS {} {
  # Looks for onwCS option.

  fetchVars
  if {$al(EM,exec)} {set st normal} {set st disabled; set al(EM,ownCS) no}
  [$obDl2 SwiCS] configure -state $st
  if {$al(EM,ownCS)} {set st normal} {set st disabled}
  [$obDl2 OpcCS] configure -state $st
}

### ________________________ Up/Down buttons _________________________ ###

proc pref::ShowUpDownArrows {{hide no}} {
  # Shows two buttons for menu-bar tab.
  #   hide - if yes, hides buttons

  fetchVars
  CheckTheming no
  set nt [$win.fra.fraR.nbk6 select]
  set bh [$obDl2 ButHelp]
  set bu [$obDl2 BtTUp]
  set bd [$obDl2 BtTDown]
  if {$hide || $nt ne "$win.fra.fraR.nbk6.f3"} {
    pack forget $bu
    pack forget $bd
  } else {
    pack $bu -side left -after $bh -padx 8
    pack $bd -side left -after $bu
  }
}
#_______________________

proc pref::FocusedRun {} {
  # Gets an index of current run.

  fetchVars
  set fr -1
  for {set i 0} {$i<$::alited::pref::em_Num} {incr i} {
    set foc [focus]
    if {$foc in [list [$obDl2 ChbMT$i] [$obDl2 OpcIco$i] [$obDl2 ButMnu$i]]} {
      set fr $i
      break
    }
  }
  if {$fr<0} {
    alited::Message2 [msgcat::mc {Select any of run item}] 3
  }
  return $fr
}
#_______________________

proc pref::ExchangeRuns {f1 f2} {
  # Exchanges two run items.
  #   f1 - 1st item
  #   f2 - 2nd item

  fetchVars
  set sep1 $em_sep($f2)
  set ico1 $em_ico($f2)
  set mnu1 $em_mnu($f2)
  set inf1 $em_inf($f2)
  set em_sep($f2) $em_sep($f1)
  set em_ico($f2) $em_ico($f1)
  set em_mnu($f2) $em_mnu($f1)
  set em_inf($f2) $em_inf($f1)
  set em_sep($f1) $sep1
  set em_ico($f1) $ico1
  set em_mnu($f1) $mnu1
  set em_inf($f1) $inf1
  Em_ShowAll
  set foc [focus]
  if       {$foc eq [$obDl2 OpcIco$f1]} {focus [$obDl2 OpcIco$f2]
  } elseif {$foc eq [$obDl2 ButMnu$f1]} {focus [$obDl2 ButMnu$f2]
  } else                                {focus [$obDl2 ChbMT$f2]}
}
#_______________________

proc pref::UpRun {} {
  # Move a current run item up.

  if {[set fr [FocusedRun]]<0} return
  if {$fr==0} {
    bell
  } else {
    set f2 [expr {$fr - 1}]
    ExchangeRuns $fr $f2
  }
}
#_______________________

proc pref::DownRun {} {
  # Move a current run item down.

  if {[set fr [FocusedRun]]<0} return
  set f2 [expr {$fr + 1}]
  if {$f2>=$::alited::pref::em_Num} {
    bell
  } else {
    ExchangeRuns $fr $f2
  }
}

# ________________________ GUI procs _________________________ #

proc pref::_create {tab} {
  # Creates "Preferences" dialogue.
  #   tab - a tab to open (saved at previous session) or {}

  fetchVars
  InitLocales
  set tipson [baltip::cget -on]
  set preview 0
  baltip::configure -on $al(TIPS,Preferences)
  $obDl2 makeWindow $win.fra "$al(MC,pref) :: $::alited::USERDIR"
  $obDl2 paveWindow \
    $win.fra [MainFrame] \
    $win.fra.fraR.nbk.f1 [General_Tab1] \
    $win.fra.fraR.nbk.f2 [General_Tab2] \
    $win.fra.fraR.nbk.f3 [General_Tab3] \
    $win.fra.fraR.nbk2.f1 [Edit_Tab1] \
    $win.fra.fraR.nbk2.f2 [Edit_Tab2] \
    $win.fra.fraR.nbk2.f3 [Edit_Tab3] \
    $win.fra.fraR.nbk2.f4 [Edit_Tab4] \
    $win.fra.fraR.nbk3.f1 [Units_Tab] \
    $win.fra.fraR.nbk4.f1 [Template_Tab] \
    $win.fra.fraR.nbk5.f1 [Keys_Tab1] \
    $win.fra.fraR.nbk6.f1 [Common_Tab] \
    $win.fra.fraR.nbk6.f2 [Emenu_Tab] \
    $win.fra.fraR.nbk6.f3 [Runs_Tab $tab] \
    $win.fra.fraR.nbk6.f4 [Tkcon_Tab]
  set wtxt [$obDl2 TexNotes]
  set fnotes [file join $::alited::USERDIR notes.txt]
  if {[file exists $fnotes]} {
    $wtxt insert end [::apave::readTextFile $fnotes]
  }
  $wtxt edit reset; $wtxt edit modified no
  [$obDl2 TexTclKeys] insert end $al(ED,TclKeyWords)
  [$obDl2 TexCKeys] insert end $al(ED,CKeyWords)
  if {$tab ne {}} {
    switch -exact $tab {
      Emenu_Tab {
        set nbk nbk6
        set nt $win.fra.fraR.nbk6.f3
      }
    }
    after idle "::alited::pref::Tab $nbk $nt yes"
  } elseif {$oldTab ne {}} {
    after idle "::alited::pref::Tab $oldTab $arrayTab($oldTab) yes"
  } else {
    after idle "::alited::pref::Tab nbk" ;# first entering
  }
  bind $win.fra.fraR.nbk6 <<NotebookTabChanged>> alited::pref::ShowUpDownArrows
  bind $win.fra.fraR.nbk <<NotebookTabChanged>> {alited::pref::CheckTheming no}
  bind $win <Control-o> alited::ini::EditSettings
  bind $win <F1> "[$obDl2 ButHelp] invoke"
  $obDl2 untouchWidgets *.texSample *.texCSample

  # open Preferences dialogue
  set res [$obDl2 showModal $win -geometry $geo -minsize {800 600} -resizable 1 \
    -onclose ::alited::pref::Cancel]

  set fcont [$wtxt get 1.0 {end -1c}]
  ::apave::writeTextFile $fnotes fcont
  if {[llength $res] < 2} {set res ""}
  set geo [wm geometry $win] ;# save the new geometry of the dialogue
  set oldTab $curTab
  set arrayTab($curTab) [$win.fra.fraR.$curTab select]
  destroy $win
  CheckTheming no
  baltip::configure {*}$tipson
  return $res
}
#_______________________

proc pref::_init {} {
  # Initializes "Preferences" dialogue.

  fetchVars
  SaveSettings
  set curTab "nbk"
  IniKeys
}
#_______________________

proc pref::_run {{tab {}}} {
  # Runs "Preferences" dialogue.
  # Returns "true", if settings were saved.

  update  ;# if run from menu: there may be unupdated space under it (in some DE)
  _init
  set res [_create $tab]
  return $res
}

# _________________________________ EOF _________________________________ #
