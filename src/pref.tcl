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

  # number of bar/menu items
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
  }
}
#_______________________

proc pref::SavedOptions {} {
  # Returns a list of names of main settings.

  fetchVars
  return [array name al]
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

  return ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$%&*=
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
    {.Cannbk .butHome L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButChange .butHome T 1 1 {-st we -pady 1} {-t "Editor" -com "alited::pref::Tab nbk2" -style TButtonWest}}
    {.Cannbk2 .butChange L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButCategories .butChange T 1 1 {-st we -pady 0} {-t "Units" -com "alited::pref::Tab nbk3" -style TButtonWest}}
    {.Cannbk3 .butCategories L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButActions .butCategories T 1 1 {-st we -pady 1} {-t "Templates" -com "alited::pref::Tab nbk4" -style TButtonWest}}
    {.Cannbk4 .butActions L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButKeys .butActions T 1 1 {-st we -pady 0} {-image alimg_kbd -compound left -t "Keys" -com "alited::pref::Tab nbk5" -style TButtonWest}}
    {.Cannbk5 .butKeys L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
    {.ButTools .butKeys T 1 1 {-st we -pady 1} {-t "Tools" -com "alited::pref::Tab nbk6" -style TButtonWest}}
    {.Cannbk6 .butTools L 1 1 {-st ns} {-w 2 -h 10 -highlightthickness 1 -afteridle {alited::pref::fillCan %w}}}
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
        f3 {-t bar/menu}
        f4 {-t Tkcon}
    }}
    {#LabMess fraL T 1 2 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {seh fraL T 1 2 {-st nsew -pady 2}}
    {fraB seh T 1 2 {-st nsew} {-padding {2 2}}}
    {.ButHelp - - - - {pack -side left} {-t {$alited::al(MC,help)} -tip F1 -com ::alited::pref::Help}}
    {.LabMess - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 50}}
    {.butOK - - - - {pack -side left -anchor s -padx 2} {-t Save -command ::alited::pref::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -command ::alited::pref::Cancel}}
  }
}
#_______________________

proc pref::Ok {args} {
  # Handler of "OK" button.

  fetchVars
  alited::CloseDlg
  set ans [alited::msg okcancel info [msgcat::mc "For the settings to be active,\nalited application should be restarted."] OK -geometry root=$win]
  if {$ans} {
    GetEmSave out
    # check options that can make alited unusable
    if {$al(INI,HUE)<-50 || $al(INI,HUE)>50} {set al(INI,HUE) 0}
    if {$al(FONTSIZE,small)<8 || $al(FONTSIZE,small)>72} {set al(FONTSIZE,small) 10}
    if {$al(FONTSIZE,std)<9 || $al(FONTSIZE,std)>72} {set al(FONTSIZE,std) 11}
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
    after 1000 "wm geometry $win \[wm geometry $win\]"
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
    azure-light azure-dark -- forest-light forest-dark -- sun-valley-light sun-valley-dark"]
  if {[string first $alited::al(THEME) $opcThemes]<0} {
    set opc1 [lindex $opcThemes 0]
  } else {
    set opc1 $alited::al(THEME)
  }
  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labTheme - - 1 1 {-st w -pady 1 -padx 3} {-t "Ttk theme:"}}
    {.opc1 .labTheme L 1 1 {-st sw -pady 1} {::alited::pref::opc1 alited::pref::opcThemes {-width 21 -tip {-indexedtips \
      5 {$alited::al(MC,needcs)} \
      }} {}}}
    {.labCS .labTheme T 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.opc2 .labCS L 1 1 {-st sw -pady 1} {::alited::pref::opcc alited::pref::opcColors {-width 21 -tip {-indexedtips \
      0 {$alited::al(MC,nocs)} \
      2 {$alited::al(MC,fitcs): awlight} \
      3 {$alited::al(MC,fitcs): azure-light} \
      4 {$alited::al(MC,fitcs): forest-light} \
      5 {$alited::al(MC,fitcs): sun-valley-light} \
      26 {$alited::al(MC,fitcs): sun-valley-dark} \
      27 {$alited::al(MC,fitcs): awdark} \
      28 {$alited::al(MC,fitcs): azure-dark} \
      29 {$alited::al(MC,fitcs): forest-dark} \
      30 {$alited::al(MC,fitcs): sun-valley-dark} \
      }} {alited::pref::opcToolPre %a}}}
    {.labHue .labCS T 1 1 {-st w -pady 1 -padx 3} {-t "Tint:"}}
    {.SpxHue .labHue L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,HUE) -from -50 -to 50 -justify center -w 9 -tip {$alited::al(MC,hue)}}}
    {seh_ .labHue T 1 2 {-pady 4}}
    {fra2 seh_ T 1 2 {-st nsew -cw 1}}
    {.labLocal - - 1 1 {-st w -pady 1 -padx 3} {-t "Preferable locale:" -tip {$alited::al(MC,locale)}}}
    {.cbxLocal .labLocal L 1 1 {-st sew -pady 1 -padx 3} {-tvar alited::al(LOCAL) -values {$alited::pref::locales} -w 4 -tip {$alited::al(MC,locale)} -state readonly -selcombobox alited::pref::GetLocaleImage -afteridle alited::pref::GetLocaleImage}}
    {.LabLocales .cbxLocal L}
    {.labFon .labLocal T 1 1 {-st w -pady 1 -padx 3} {-t "Font:"}}
    {.fonTxt .labFon L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(FONT) -w 40}}
    {.labFsz1 .labFon T 1 1 {-st w -pady 1 -padx 3} {-t "Small font size:"}}
    {.spxFsz1 .labFsz1 L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(FONTSIZE,small) -from 8 -to 72 -justify center -w 9}}
    {.labFsz2 .labFsz1 T 1 1 {-st w -pady 1 -padx 3} {-t "Middle font size:"}}
    {.spxFsz2 .labFsz2 L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(FONTSIZE,std) -from 9 -to 72 -justify center -w 9}}
    {.labCurw .labFsz2 T 1 1 {-st w -pady 1 -padx 3} {-t "Cursor width:"}}
    {.spxCurw .labCurw L 1 9 {-st sw -pady 1 -padx 3} {-tvar alited::al(CURSORWIDTH) -from 1 -to 8 -justify center -w 9}}
    {seh_2 fra2 T 1 2 {-pady 4}}
    {lab seh_2 T 1 2 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra3 lab T 1 2 {-st nsew -rw 1 -cw 1}}
    {.TexNotes - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 90 -wrap word -tabnext $alited::pref::win.fra.fraB.butHelp -tip {-BALTIP {$alited::al(MC,notes)} -MAXEXP 1}}}
    {.sbv .TexNotes L - - {pack -side left}}
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
    {.cbxport .labport L 1 1 {-st sw -pady 5} {-tvar alited::al(comm_port) -values {$alited::al(comm_port_list)} -w 8 -tip "The empty value allows\nmultiple alited apps."}}
    {.labConf .labport T 1 1 {-st w -pady 1 -padx 3} {-t "Confirm exit:"}}
    {.swiConf .labConf L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,confirmexit)}}
    {.seh1 .labConf T 1 4 {-st ew -pady 5}}
    {.labS .seh1 T 1 1 {-st w -pady 1 -padx 3} {-t "Save configuration on"}}
    {.labSonadd .labS T 1 1 {-st e -pady 1 -padx 3} {-t "opening a file:"}}
    {.swiOnadd .labSonadd L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onadd)}}
    {.labSonclose .labSonadd T 1 1 {-st e -pady 1 -padx 3} {-t "closing a file:"}}
    {.swiOnclose .labSonclose L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onclose)}}
    {.labSonsave .labSonclose T 1 1 {-st e -pady 1 -padx 3} {-t "saving a file:"}}
    {.swiOnsave .labSonsave L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onsave)}}
    {.seh2 .labSonsave T 1 4 {-st ew -pady 5}}
    {.labSave .seh2 T 1 1 {-st w -pady 1 -padx 3} {-t "Save before bar/menu runs:"}}
    {.cbxSave .labSave L 1 2 {-st sw -pady 1} {-values {$alited::al(pref,saveonrun)} -tvar alited::al(EM,save) -state readonly -w 20}}
    {.seh3 .labSave T 1 4 {-st ew -pady 5}}
    {.labRecnt .seh3 T 1 1 {-st w -pady 1 -padx 3} {-t "'Recent Files' length:"}}
    {.spxRecnt .labRecnt L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,RECENTFILES) -from 10 -to 50 -justify center -w 9}}
    {.labMaxLast .labRecnt T 1 1 {-st w -pady 1 -padx 3} {-t "'Last Visited' length:"}}
    {.spxMaxLast .labMaxLast L 1 1 {-st sw -pady 1} {-tvar alited::al(FAV,MAXLAST) -from 10 -to 100 -justify center -w 9}}
    {.labMaxFiles .labMaxLast T 1 1 {-st w -pady 1 -padx 3} {-t "Maximum of project files:"}}
    {.spxMaxFiles .labMaxFiles L 1 1 {-st sw -pady 1} {-tvar alited::al(MAXFILES) -from 1000 -to 9999 -justify center -w 9}}
    {.seh4 .labMaxFiles T 1 4 {-st ew -pady 5}}
    {.labBackup .seh4 T 1 1 {-st w -pady 1 -padx 3} {-t "Back up files to a project's subdirectory:"}}
    {.CbxBackup .labBackup L 1 1 {-st sw -pady 1} {-tvar alited::al(BACKUP) -values {{} .bak} -state readonly -w 6 -tip "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup." -afteridle alited::pref::CbxBackup -selcombobox alited::pref::CbxBackup}}
    {.LabMaxBak .CbxBackup L 1 1 {-st w -pady 1 -padx 1} {-t "  Maximum:"}}
    {.SpxMaxBak .labMaxBak L 1 1 {-st sw -pady 1 -padx 1} {-tvar alited::al(MAXBACKUP) -from 1 -to 99 -justify center -w 9 -tip {$alited::al(MC,maxbak)}}}
    {.labBell .labBackup T 1 1 {-st w -pady 1 -padx 3} {-t "Bell at warnings:"}}
    {.swiBell .labBell L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,belltoll)}}
  }
}
#_______________________

proc pref::General_Tab3 {} {
  # Serves to layout "General/Projects" tab.

  return {
    {v_ - - 1 10}
    {fra2 v_ T 1 2 {-st nsew -cw 1}}
    {.labDef - - 1 1 {-st w -pady 1 -padx 3} {-t {Default values for new projects:}}}
    {.swiDef .labDef L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(PRJDEFAULT) -com alited::pref::CheckUseDef -afteridle alited::pref::CheckUseDef}}
    {.seh .labDef T 1 10 {-st ew -pady 3 -padx 3}}
    {.labIgn .seh T 1 1 {-st w -pady 8 -padx 3} {-t {$alited::al(MC,Ign:)}}}
    {.EntIgn .labIgn L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(DEFAULT,prjdirign) -w 50}}
    {.labEOL .labIgn T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,EOL:)}}}
    {.CbxEOL .labEOL L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(DEFAULT,prjEOL) -values {{} LF CR CRLF} -state readonly -w 9}}
    {.labIndent .labEOL T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,indent:)}}}
    {.SpxIndent .labIndent L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(DEFAULT,prjindent) -w 9 -from 0 -to 8 -justify center -com ::alited::pref::CheckIndent}}
    {.ChbIndAuto .SpxIndent L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(DEFAULT,prjindentAuto) -t {$alited::al(MC,indentAuto)}}}
    {.labRedunit .labIndent T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,redunit)}}}
    {.SpxRedunit .labRedunit L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(DEFAULT,prjredunit) -w 9 -from $alited::al(minredunit) -to 100 -justify center}}
    {.labMult .labRedunit T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,multiline)} -tip {$alited::al(MC,notrecomm)}}}
    {.SwiMult .labMult L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(DEFAULT,prjmultiline) -tip {$alited::al(MC,notrecomm)}}}
    {.labTrWs .labMult T 1 1 {-st w -pady 1 -padx 3} {-t {$alited::al(MC,trailwhite)}}}
    {.SwiTrWs .labTrWs L 1 1 {-st sw -pady 1} {-var alited::al(DEFAULT,prjtrailwhite)}}
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

# ________________________ Tab "Editor" _________________________ #

proc pref::Edit_Tab1 {} {
  # Serves to layout "Editor" tab.

  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labFon - - 1 1 {-st w -pady 8 -padx 3} {-t "Font:"}}
    {.fonTxt .labFon L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONT,txt) -w 40}}
    {.labSp1 .labFon T 1 1 {-st w -pady 1 -padx 3} {-t "Space above lines:"}}
    {.spxSp1 .labSp1 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp1) -from 0 -to 16 -justify center -w 9}}
    {.labSp3 .labSp1 T 1 1 {-st w -pady 1 -padx 3} {-t "Space below lines:"}}
    {.spxSp3 .labSp3 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp3) -from 0 -to 16 -justify center -w 9}}
    {.labSp2 .labSp3 T 1 1 {-st w -pady 1 -padx 3} {-t "Space between wraps:"}}
    {.spxSp2 .labSp2 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp2) -from 0 -to 16 -justify center -w 9}}
    {.seh .labSp2 T 1 2 {-pady 3}}
    {.labLl .seh T 1 1 {-st w -pady 1 -padx 3} {-t "Tab bar label's length:"}}
    {.spxLl .labLl L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(INI,barlablen) -from 10 -to 100 -justify center -w 9}}
    {.labTl .labLl T 1 1 {-st w -pady 1 -padx 3} {-t "Tab bar tip's length:"}}
    {.spxTl .labTl L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(INI,bartiplen) -from 10 -to 100 -justify center -w 9}}
    {.seh2 .labTl T 1 2 {-pady 3}}
    {.labGW .seh2 T 1 1 {-st w -pady 1 -padx 3} {-t "Gutter's width:"}}
    {.spxGW .labGW L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,gutterwidth) -from 3 -to 7 -justify center -w 9}}
    {.labGS .labGW T 1 1 {-st w -pady 1 -padx 3} {-t "Gutter's shift from text:"}}
    {.spxGS .labGS L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,guttershift) -from 0 -to 10 -justify center -w 9}}
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
    {.entExt .labExt L 1 1 {-st swe -pady 3} {-tvar alited::al(TclExtensions) -w 40}}
    {.labCOM .labExt T 1 1 {-st w -pady 3 -padx 3} {-t "Color of Tcl commands:"}}
    {.clrCOM .labCOM L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrCOM) -w 20}}
    {.labCOMTK .labCOM T 1 1 {-st w -pady 3 -padx 3} {-t "Color of Tk commands:"}}
    {.clrCOMTK .labCOMTK L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrCOMTK) -w 20}}
    {.labSTR .labCOMTK T 1 1 {-st w -pady 3 -padx 3} {-t "Color of strings:"}}
    {.clrSTR .labSTR L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrSTR) -w 20}}
    {.labVAR .labSTR T 1 1 {-st w -pady 3 -padx 3} {-t "Color of variables:"}}
    {.clrVAR .labVAR L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrVAR) -w 20}}
    {.labCMN .labVAR T 1 1 {-st w -pady 3 -padx 3} {-t "Color of comments:"}}
    {.clrCMN .labCMN L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrCMN) -w 20}}
    {.labPROC .labCMN T 1 1 {-st w -pady 3 -padx 3} {-t "Color of proc/methods:"}}
    {.clrPROC .labPROC L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrPROC) -w 20}}
    {.labOPT .labPROC T 1 1 {-st w -pady 3 -padx 3} {-t "Color of options:"}}
    {.clrOPT .labOPT L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrOPT) -w 20}}
    {.labBRA .labOPT T 1 1 {-st w -pady 3 -padx 3} {-t "Color of brackets:"}}
    {.clrBRA .labBRA L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrBRA) -w 20}}
    {.seh .labBRA T 1 2 {-pady 3}}
    {fraTab2.scf.FraDefClr1 .seh T 1 2 {-st nsew}}
    {.but - - 1 1 {-st w -padx 0} {-t {Default} -com {alited::pref::Tcl_Default 0}}}
    {.but1 .but L 1 1 {-st w -padx 8} {-t {Default 2} -com {alited::pref::Tcl_Default 1}}}
    {.but2 .but1 L 1 1 {-st w -padx 0} {-t {Default 3} -com {alited::pref::Tcl_Default 2}}}
    {.but3 .but2 L 1 1 {-st w -padx 8} {-t {Default 4} -com {alited::pref::Tcl_Default 3}}}
    {fraTab2.scf.sehclr fraTab2.scf.FraDefClr1 T 1 2 {-pady 5}}
    {fraTab2.scf.fra2 fraTab2.scf.sehclr T 1 2 {-st nsew}}
    {.lab - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Code snippet:"}}
    {.TexSample - - - - {pack -side left -fill both -expand 1} {-h 7 -w 48 -afteridle alited::pref::UpdateSyntaxTab}}
    {.sbv .TexSample L - - {pack -side right}}
    {fraTab2.scf.seh3 fraTab2.scf.fra2 T 1 2 {-pady 5}}
    {fraTab2.scf.fra3 fraTab2.scf.seh3 T 1 2 {-st nsew}}
    {.labAddKeys - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Your commands:"}}
    {.TexTclKeys - - - - {pack -side left -fill both -expand 1} {-h 3 -w 48 -wrap word -tabnext $alited::pref::win.fraB.butOK}}
    {.sbv .TexTclKeys L - - {pack -side right}}
  }
}
#_______________________

proc pref::Edit_Tab3 {} {
  # Serves to layout "C/C++ syntax" tab.

  return {
    {v_ - - 1 1}
    {FraTab3 v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fraTab3.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "C/C++ files' extensions:"}}
    {.entExt .labExt L 1 1 {-st swe -pady 3} {-tvar alited::al(ClangExtensions) -w 40}}
    {.labCOM2 .labExt T 1 1 {-st w -pady 3 -padx 3} {-t "Color of C key words:"}}
    {.clrCOM2 .labCOM2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCOM) -w 20}}
    {.labCOMTK2 .labCOM2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of C++ key words:"}}
    {.clrCOMTK2 .labCOMTK2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCOMTK) -w 20}}
    {.labSTR2 .labCOMTK2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of strings:"}}
    {.clrSTR2 .labSTR2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrSTR) -w 20}}
    {.labVAR2 .labSTR2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of punctuation:"}}
    {.clrVAR2 .labVAR2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrVAR) -w 20}}
    {.labCMN2 .labVAR2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of comments:"}}
    {.clrCMN2 .labCMN2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCMN) -w 20}}
    {.labPROC2 .labCMN2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of return/goto:"}}
    {.clrPROC2 .labPROC2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrPROC) -w 20}}
    {.labOPT2 .labPROC2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of your key words:"}}
    {.clrOPT2 .labOPT2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrOPT) -w 20}}
    {.labBRA2 .labOPT2 T 1 1 {-st w -pady 3 -padx 3} {-t "Color of brackets:"}}
    {.clrBRA2 .labBRA2 L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrBRA) -w 20}}
    {.seh .labBRA2 T 1 2 {-pady 3}}
    {fraTab3.scf.FraDefClr2 .seh T 1 2 {-st nsew}}
    {.but - - 1 1 {-st w -padx 0} {-t {Default} -com {alited::pref::C_Default 0}}}
    {.but1 .but L 1 1 {-st w -padx 8} {-t {Default 2} -com {alited::pref::C_Default 1}}}
    {.but2 .but1 L 1 1 {-st w -padx 0} {-t {Default 3} -com {alited::pref::C_Default 2}}}
    {.but3 .but2 L 1 1 {-st w -padx 8} {-t {Default 4} -com {alited::pref::C_Default 3}}}
    {fraTab3.scf.sehclr fraTab3.scf.fraDefClr2 T 1 2 {-pady 5}}
    {fraTab3.scf.fra2 fraTab3.scf.sehclr T 1 2 {-st nsew}}
    {.lab - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Code snippet:"}}
    {.TexCSample - - - - {pack -side left -fill both -expand 1} {-h 7 -w 48 -wrap word}}
    {.sbv .TexCSample L - - {pack -side right}}
    {fraTab3.scf.seh3 fraTab3.scf.fra2 T 1 2 {-pady 5}}
    {fraTab3.scf.fra3 fraTab3.scf.seh3 T 1 2 {-st nsew}}
    {.lab - - - - {pack -side left -anchor ne -pady 3 -padx 3} {-t "Your key words:"}}
    {.TexCKeys - - - - {pack -side left -fill both -expand 1} {-h 3 -w 48 -wrap word -tabnext $alited::pref::win.fraB.butOK}}
    {.sbv .TexCKeys L - - {pack -side right}}
  }
}
#_______________________

proc pref::Edit_Tab4 {} {
  # Serves to layout "Misc syntax" tab.

  return {
    {v_ - - 1 1}
    {FraTab4 v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fraTab4.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "Plain texts' extensions:"}}
    {.entExt .labExt L 1 1 {-st swe -pady 3} {-tvar alited::al(TextExtensions) -w 54}}
    {.seh .labExt T 1 2 {-pady 3}}
    {.but .seh T 1 1 {-st w} {-t Default -com alited::pref::Text_Default}}
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

proc pref::InitSyntaxTcl {colornames} {
  # Initializes syntax stuff for Tcl.
  #    colornames - names of colors

  fetchVars
  set tex [$obDl2 TexSample]
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
  ::hl_tcl::hl_init $tex -dark [CsDark] \
    -multiline 1 -keywords $keywords \
    -font $al(FONT,txt) -colors $colornames \
    -insertwidth $al(CURSORWIDTH)
  ::hl_tcl::hl_text $tex
}
#_______________________

proc pref::InitSyntaxC {colornames} {
  # Initializes syntax stuff for C/C++.
  #    colornames - names of colors

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
  ::hl_c::hl_init $tex -dark [CsDark] \
    -multiline 1 -keywords $keywords \
    -font $al(FONT,txt) -colors $colornames \
    -insertwidth $al(CURSORWIDTH)
  ::hl_c::hl_text $tex
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
    {.labU .labH T 1 1 {-st w -pady 1 -padx 3} {-t "User name:"}}
    {.entU .labU L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%U) -w 40}}
    {.labu .labU T 1 1 {-st w -pady 1 -padx 3} {-anc e -t "Login:"}}
    {.entu .labu L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%u) -w 30}}
    {.labm .labu T 1 1 {-st w -pady 1 -padx 3} {-t "E-mail:"}}
    {.entm .labm L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%m) -w 40}}
    {.labw .labm T 1 1 {-st w -pady 1 -padx 3} {-t "WWW:"}}
    {.entw .labw L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%w) -w 40}}
    {.labd .labw T 1 1 {-st w -pady 1 -padx 3} {-t "Date format:"}}
    {.entd .labd L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%d) -w 30}}
    {.labt .labd T 1 1 {-st w -pady 1 -padx 3} {-t "Time format:"}}
    {.entt .labt L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%t) -w 30}}
    {.seh .labt T 1 2 {-pady 3}}
    {.but .seh T 1 1 {-st w} {-t {$::alited::al(MC,tpllist)} -com {alited::unit_tpl::_run no "-geometry root=$::alited::pref::win"}}}
  }
}

# ________________________ Tab "Keys" _________________________ #

proc pref::Keys_Tab1 {} {
  # Serves to layout "Keys" tab.

  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {tcl {
        set pr -
        for {set i 0} {$i<$alited::pref::stdkeysSize} {incr i} {
          set lab "lab$i"
          set cbx "CbxKey$i"
          lassign [dict get $alited::pref::stdkeys $i] text key
          set lwid ".$lab $pr T 1 1 {-st w -pady 1 -padx 3} {-t \"$text\"}"
          %C $lwid
          set lwid ".$cbx .$lab L 1 1 {-st we} {-tvar ::alited::pref::keys($i) -postcommand {::alited::pref::GetKeyList $i} -selcombobox {::alited::pref::SelectKey $i} -state readonly -h 16 -w 20}"
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
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labBr - - 1 1 {-st w -pady 1 -padx 3} {-t "Branch's regexp:"}}
    {.entBr .labBr L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,branch) -w 70}}
    {.labPr .labBr T 1 1 {-st w -pady 1 -padx 3} {-t "Proc's regexp:"}}
    {.entPr .labPr L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,proc) -w 70}}
    {.seh_0 .labPr T 1 2 {-pady 5}}
    {.labLf2 .seh_0 T 1 1 {-st w -pady 1 -padx 3} {-t "Check branch's regexp:"}}
    {.entLf2 .labLf2 L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,leaf2) -w 70}}
    {.labPr2 .labLf2 T 1 1 {-st w -pady 1 -padx 3} {-t "Check proc's regexp:"}}
    {.entPr2 .labPr2 L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,proc2) -w 70}}
    {.seh_1 .labPr2 T 1 2 {-pady 5}}
    {.labUself .seh_1 T 1 1 {-st w -pady 1 -padx 3} {-t "Use leaf's regexp:"}}
    {.swiUself .labUself L 1 1 {-st sw -pady 1} {-var alited::al(INI,LEAF) -onvalue yes -offvalue no -com alited::pref::CheckUseLeaf -afteridle alited::pref::CheckUseLeaf}}
    {.labLf .labUself T 1 1 {-st w -pady 1 -padx 3} {-t "Leaf's regexp:"}}
    {.EntLf .labLf L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,leaf) -w 70}}
    {.seh_2 .labLf T 1 2 {-pady 5}}
    {.labUnt .seh_2 T 1 1 {-st w -pady 1 -padx 3} {-t "Untouched top lines:"}}
    {.spxUnt .labUnt L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,LINES1) -from 2 -to 200 -w 9}}
    {.seh_3 .labUnt T 1 2 {-pady 5}}
    {.but .seh_3 T 1 1 {-st w} {-t Default -com alited::pref::Units_Default}}
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
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labTcl - - 1 1 {-st w -pady 1 -padx 3} {-t "tclsh, wish or tclkit:"}}
    {.fiLTcl .labTcl L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,Tcl) -values {$alited::al(TCLLIST)} -w 48 -initialdir $alited::al(TCLINIDIR) -clearcom {alited::main::ClearCbx %w ::alited::al(TCLLIST)}}}
    {.labRun .labTcl T 1 1 {-st w -pady 1 -padx 3} {-t "$al(MC,run):"}}
    {.fraRun .labRun L 1 1 {-st sw -pady 5}}
    {.fraRun.radRunCons - - 1 1 {} {-var alited::al(tkcon,topmost) -value 1 -t {$alited::al(MC,inconsole)} -tip {Also, this makes "tkcon" topmost.}}}
    {.fraRun.radRunTkcon .fraRun.radRunCons L 1 1 {-padx 10} {-var alited::al(tkcon,topmost) -value 0 -t {$alited::al(MC,intkcon)}}}
    {.labDoc .labRun T 1 1 {-st w -pady 1 -padx 3} {-t "Path to man/tcl:"}}
    {.dirDoc .labDoc L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,h=) -w 48}}
    {.labTT .labDoc T 1 1 {-st w -pady 1 -padx 3} {-t "Linux terminal:"}}
    {.cbxTT .labTT L 1 1 {-st swe -pady 5} {-tvar alited::al(EM,tt=) -w 48 -values {$alited::al(TTLIST)} -clearcom {alited::main::ClearCbx %w ::alited::al(TTLIST)}}}
    {.labWT .labTT T 1 1 {-st w -pady 1 -padx 3} {-t "MS Windows shell:"}}
    {.cbxWT .labWT L 1 1 {-st swe -pady 5} {-tvar alited::al(EM,wt=) -w 48 -values {$alited::al(WTLIST)}}}
    {.labDF .labWT T 1 1 {-st w -pady 1 -padx 3} {-t "Diff tool:"}}
    {.filDF .labDF L 1 1 {-st sw -pady 1} {-tvar alited::al(EM,DiffTool) -w 48}}
  }
}

## ________________________ e_menu _________________________ ##

proc pref::Default_e_menu {} {
  # Set default a_menu settings.

  fetchVars
  set al(EM,exec) yes
  set al(EM,ownCS) no
  set al(EM,geometry) +1+31
  set emdir [file join $::alited::USERDIR e_menu]
  set al(EM,mnudir) [file join $emdir menus]
  set al(EM,mnu) [file join $al(EM,mnudir) menu.mnu]
  set al(EM,PD=) [file join $emdir em_projects]
}
#_______________________

proc pref::Test_e_menu {} {
  # Tests a_menu settings.

  fetchVars
  set cs $al(EM,CS)
  set al(EM,CS) [GetCS 2]
  alited::tool::e_menu o=0
  set al(EM,CS) $cs
}
#_______________________

proc pref::Emenu_Tab {} {
  # Serves to layout "Tools/e_menu" tab.

  set al(EM,exec) yes
# just now, "internal" e_menu isn't working with alited's "Run"
#    #\{.labExe - - 1 1 #\{-st w -pady 1 -padx 3#\} #\{-t "Run as external app:"#\}#\}
#    #\{.swiExe .labExe L 1 1 #\{-st sw -pady 5#\} #\{-var alited::al(EM,exec) -onvalue yes -offvalue no -com alited::pref::OwnCS#\}#\}
#    #\{.labCS .labExe T 1 1 #\{-st w -pady 1 -padx 3#\} #\{-t "Color scheme:"#\}#\}
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labCS - - 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.SwiCS .labCS L 1 1 {-st sw -pady 5} {-t {e_menu's own} -var alited::al(EM,ownCS) -com alited::pref::OwnCS -afteridle alited::pref::OwnCS}}
    {.OpcCS .swiCS L 1 1 {-st sw -pady 5} {::alited::pref::opcc2 alited::pref::opcColors {-width 21} {alited::pref::opcToolPre %a}}}
    {.labGeo .labCS T 1 1 {-st w -pady 1 -padx 3} {-t "Geometry:"}}
    {.entGeo .labGeo L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,geometry) -w 22}}
    {.labDir .labGeo T 1 1 {-st w -pady 1 -padx 3} {-t "Directory of menus:"}}
    {.dirEM .labDir L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,mnudir) -w 48}}
    {.labMenu .labDir T 1 1 {-st w -pady 1 -padx 3} {-t "Main menu:"}}
    {.filMenu .labMenu L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,mnu) -w 48 -filetypes {{{Menus} .mnu} {{All files} .* }}}}
    {.labPD .labMenu T 1 1 {-st w -pady 1 -padx 3} {-t "Projects (%PD wildcard):"}}
    {.filPD .labPD L 1 2 {-st sw -pady 5} {-tvar alited::al(EM,PD=) -w 48}}
    {.seh .labPD T 1 3 {-st ew -pady 5}}
    {.h_ .seh T}
    {.but1 .h_ L 1 1 {-st w} {-t Default -com alited::pref::Default_e_menu}}
    {.but2 .but1 L 1 1 {-st w} {-t Test -com alited::pref::Test_e_menu}}
  }
}

## ________________________ tkcon _________________________ ##

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
  set al(tkcon,rows) 20
  set al(tkcon,cols) 100
  set al(tkcon,fsize) 13
  set al(tkcon,geo) +1+31
  set al(tkcon,topmost) [expr {!$al(IsWindows)}]
}
#_______________________

proc pref::Tkcon_Default1 {} {
  # Sets light theme colors for Tkcon.

  fetchVars
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
  foreach {clr val} { \
  bg #25292b blink #929281 cursor #FFFFFF disabled #999797 proc #66FF10 \
  var #565608 prompt #ffff00 stdin #FFFFFF stdout #aeaeae stderr #ff7272} {
    set al(tkcon,clr$clr) $val
  }
}
#_______________________

proc pref::Tkcon_Tab {} {
  # Serves to layout "Tools/Tkcon" tab.

  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {fra.scf.lfr - - 1 1  {pack -fill x} {-t Colors}}
    {.Labbg - - 1 1 {-st w -pady 1 -padx 3} {-t "bg:"}}
    {.clrbg .labbg L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrbg) -w 20}}
    {.labblink .labbg T 1 1 {-st w -pady 1 -padx 3} {-t "blink:"}}
    {.clrblink .labblink L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrblink) -w 20}}
    {.labcursor .labblink T 1 1 {-st w -pady 1 -padx 3} {-t "cursor:"}}
    {.clrcursor .labcursor L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrcursor) -w 20}}
    {.labdisabled .labcursor T 1 1 {-st w -pady 1 -padx 3} {-t "disabled:"}}
    {.clrdisabled .labdisabled L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrdisabled) -w 20}}
    {.labproc .labdisabled T 1 1 {-st w -pady 1 -padx 3} {-t "proc:"}}
    {.clrproc .labproc L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrproc) -w 20}}
    {.labvar .labproc T 1 1 {-st w -pady 1 -padx 3} {-t "var:"}}
    {.clrvar .labvar L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrvar) -w 20}}
    {.labprompt .labvar T 1 1 {-st w -pady 1 -padx 3} {-t "prompt:"}}
    {.clrprompt .labprompt L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrprompt) -w 20}}
    {.labstdin .labprompt T 1 1 {-st w -pady 1 -padx 3} {-t "stdin:"}}
    {.clrstdin .labstdin L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrstdin) -w 20}}
    {.labstdout .labstdin T 1 1 {-st w -pady 1 -padx 3} {-t "stdout:"}}
    {.clrstdout .labstdout L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrstdout) -w 20}}
    {.labstderr .labstdout T 1 1 {-st w -pady 1 -padx 3} {-t "stderr:"}}
    {.clrstderr .labstderr L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,clrstderr) -w 20}}
    {.but1 .clrstderr L 1 1 {-padx 8} {-t Default -com {alited::pref::Tkcon_Default1; alited::pref::UpdateTkconTab}}}
    {.but2 .but1 L 1 1 {-padx 0} {-t {Default 2} -com {alited::pref::Tkcon_Default2; alited::pref::UpdateTkconTab}}}
    {.but3 .but2 L 1 1 {-padx 20} {-t Test -com alited::tool::tkcon}}
    {fra.scf.v_ fra.scf.lfr T 1 1  {pack} {-h 10}}
    {fra.scf.lfr2 fra.scf.v_ T 1 1  {pack -fill x} {-t Options}}
    {.labRows - - 1 1 {-st w -pady 1 -padx 3} {-t "Rows:"}}
    {.spxRows .labRows L 1 2 {-st sw -pady 1} {-tvar alited::al(tkcon,rows) -from 4 -to 40 -w 9}}
    {.labCols .labRows T 1 1 {-st w -pady 1 -padx 3} {-t "Columns:"}}
    {.spxCols .labCols L 1 2 {-st sw -pady 1} {-tvar alited::al(tkcon,cols) -from 15 -to 150 -w 9}}
    {.labFsize .labCols T 1 1 {-st w -pady 1 -padx 3} {-t "Font size:"}}
    {.spxFS .labFsize L 1 2 {-st sw -pady 1} {-tvar alited::al(tkcon,fsize) -from 8 -to 20 -w 9}}
    {.labGeo .labFsize T 1 1 {-st w -pady 1 -padx 3} {-t "Geometry:"}}
    {.entGeo .labGeo L 1 2 {-st sw -pady 1} {-tvar alited::al(tkcon,geo) -w 20}}
  }
}

## ________________________ bar/menu _________________________ ##

proc pref::Runs_Tab {tab} {
  # Prepares and layouts "Tools/bar/menu" tab.
  #   tab - a tab to open (saved at previous session) or {}

  fetchVars
  # get a list of all available icons for "bar/menu" actions
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
      lappend em_Icons [string index [TextIcons] [expr {$ii -10}]]
    }
    incr icr
  }
  EmSeparators no
  # get a layout of "bar/menu" tab
  set res {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1} {-afteridle {::alited::pref::EmSeparators yes}}}
    {fra.ScfRuns - - 1 1  {pack -fill both -expand 1}}
    {tcl {
        set prt "- -"
        for {set i 0} {$i<$::alited::pref::em_Num} {incr i} {
          set nit [expr {$i+1}]
          set lwid ".buTAdd$i $prt 1 1 {-padx 0} {-tip {Inserts a new line.} -com {::alited::pref::EmAddLine $i} -takefocus 0 -relief flat -overrelief raised -highlightthickness 0 -image alimg_add}"
          %C $lwid
          set lwid ".buTDel$i .buTAdd$i L 1 1 {-padx 1} {-tip {Deletes a line.} -com {::alited::pref::EmDelLine $i} -takefocus 0 -relief flat -overrelief raised -highlightthickness 0 -image alimg_delete}"
          %C $lwid
          set lwid ".ChbMT$i .buTDel$i L 1 1 {-padx 10} {-t separator -var ::alited::pref::em_sep($i) -tip {If 'yes', means a separator of the toolbar/menu.} -com {::alited::pref::EmSeparators yes}}"
          %C $lwid
          set lwid ".OpcIco$i .ChbMT$i L 1 1 {-st nsw} {::alited::pref::em_ico($i) alited::pref::em_Icons {-width 10 -tooltip {{An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar.}}} {alited::pref::opcIcoPre %a}}"
          %C $lwid
          set lwid ".ButMnu$i .OpcIco$i L 1 1 {-st sw -pady 1 -padx 10} {-t {$::alited::pref::em_mnu($i)} -com {alited::pref::PickMenuItem $i} -style TButtonWest -tip {{The run item for the menu and/or the toolbar.\nSelect it from the e_menu items.}}}"
          %C $lwid
          set prt ".buTAdd$i T"
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

proc pref::EmAddLine {idx} {
  # Inserts a new "bar/menu" action before a current one.
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
  EmSeparators yes
}
#_______________________

proc pref::EmDelLine {idx} {
  # Deletes a current "bar/menu" action.
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
  EmSeparators yes
  ScrollRuns
}
#_______________________

proc pref::EmSeparators {upd} {
  # Handles separators of bar/menu.
  #   upd - if yes, displays the widgets of bar/menu settings.
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
      [$obDl2 OpcIco$i] configure -state $state
    }
  }
  if {$upd} ScrollRuns
}
#_______________________

proc pref::PickMenuItem {it} {
  # Selects e_menu's action for a "bar/menu" item.
  #   it - index of "bar/menu" item

  fetchVars
  ::alited::source_e_menu
  set w [$obDl2 ButMnu$it]
  set X [winfo rootx $w]
  set Y [winfo rooty $w]
  set res [::em::main -prior 1 -modal 1 -remain 0 -noCS 1 \
    {*}[alited::tool::EM_Options "pk=yes dk=dock o=-1 t=1 g=+[incr X 5]+[incr Y 25]"]]
  lassign $res menu idx item
  if {$item ne {}} {
    set i [lindex [alited::tool::EM_Structure $menu] $idx-1 1]
    set item2 [string range $i [string first - $i]+1 end]
    if {$item2 ne $item && [string match *.mnu $item2]} {
      append item2 ": $item"  ;# it's a menu call title
      set idx - ;# to open the whole menu
    }
    $w configure -text $item2
    set em_mnu($it) $item2
    set em_inf($it) [list [file tail $menu] $idx $item2]
    ScrollRuns
  }
}
#_______________________

proc pref::ScrollRuns {} {
  # Updates scrollbars of bar/menu tab because its contents may have various length.

  fetchVars
  update
  ::apave::sframe resize [$obDl2 ScfRuns]
}
#_______________________

proc pref::opcIcoPre {args} {
  # Gets an item for icon list of a bar/menu action.
  #   args - contains a name of current icon

  fetchVars
  lassign $args a
  if {[set i [lsearch $listIcons $a]]>-1} {
    set img [::apave::iconImage [lindex $listIcons $i]]
    set res "-image $img"
  } else {
    set res "-image alimg_none"
  }
  append res " -compound left -label $a"
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

# ________________________ GUI procs _________________________ #

proc pref::_create {tab} {
  # Creates "Preferences" dialogue.
  #   tab - a tab to open (saved at previous session) or {}

  fetchVars
  InitLocales
  set tipson [baltip::cget -on]
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
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
