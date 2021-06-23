#! /usr/bin/env tclsh
###########################################################
# Name:    pref.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    05/25/2021
# Brief:   Handles "Preferences".
# License: MIT.
###########################################################

namespace eval pref {
  variable win $::alited::al(WIN).diaPref
  variable geo root=$::alited::al(WIN)
  variable minsize ""
  variable data; array set data [list]
  variable keys; array set keys [list]
  variable prevkeys; array set prevkeys [list]
  variable savekeys; array set savekeys [list]
  variable arrayTab; array set arrayTab [list]
  variable curTab nbk
  variable oldTab {}
  variable opcColors [list]
  variable opcc {}
  variable opcc2 {}
  variable em_Num 32
  variable em_mnu; array set em_mnu [list]
  variable em_ico; array set em_ico [list]
  variable em_sep; array set em_sep [list]
  variable em_inf; array set em_inf [list]
  variable em_Menus [list]
  variable em_Icons [list]
  variable listIcons [list]
  variable listMenus [list]
  variable stdkeys
  set stdkeys [dict create \
     0 [list {Save File} F2] \
     1 [list {Save File as} Control-S] \
     2 [list {Run e_menu} F4] \
     3 [list {Run File} F5] \
     4 [list {Double Selection} Control-D] \
     5 [list {Delete Line} Control-Y] \
     6 [list {Indent} Control-I] \
     7 [list {Unindent} Control-U] \
     8 [list {Comment} Control-bracketleft] \
     9 [list {Uncomment} Control-bracketright] \
    10 [list {Highlight First} Alt-Q] \
    11 [list {Highlight Last} Alt-W] \
    12 [list {Find Next Match} F3] \
    13 [list {Look for Declaration} Control-L] \
    14 [list {Look for Word} Control-Shift-L] \
    15 [list {Item up} F11] \
    16 [list {Item down} F12] \
    17 [list {Go to Line} Control-G] \
    18 [list {Put New Line} Control-P] \
  ]
  variable stdkeysSize [dict size $stdkeys]
}

# ________________________ Common procedures _________________________ #

proc pref::fetchVars {} {
  uplevel 1 {
    namespace upvar ::alited al al obDl2 obDl2
    variable win
    variable geo
    variable minsize
    variable data
    variable keys
    variable prevkeys
    variable savekeys
    variable arrayTab
    variable curTab
    variable oldTab
    variable opcColors
    variable opcc
    variable opcc2
    variable em_Num
    variable em_mnu
    variable em_ico
    variable em_sep
    variable em_inf
    variable em_Menus
    variable em_Icons
    variable listIcons
    variable listMenus
    variable stdkeys
    variable stdkeysSize
  }
}

proc pref::SaveSettings {} {
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
}

proc pref::RestoreSettings {} {
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
}

proc pref::SavedOptions {} {
  fetchVars
  return [array name al]
}

proc pref::TextIcons {} {
  return ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$%&*=
}

proc pref::ReservedIcons {} {
  return [list file OpenFile box SaveFile saveall undo redo help replace run other ok color]
}

# ________________________ Main Frame _________________________ #

proc pref::MainFrame {} {

  return {
    {fraL - - 1 1 {-st nws -rw 2}}
    {.ButHome - - 1 1 {-st we} {-t "General" -com "alited::pref::Tab nbk" -style TButtonWest}}
    {.butChange .butHome T 1 1 {-st we} {-t "Editor" -com "alited::pref::Tab nbk2" -style TButtonWest}}
    {.butCategories .butChange T 1 1 {-st we} {-t "Units" -com "alited::pref::Tab nbk3" -style TButtonWest}}
    {.butActions .butCategories T 1 1 {-st we} {-t "Templates" -com "alited::pref::Tab nbk4" -style TButtonWest}}
    {.butKeys .butActions T 1 1 {-st we} {-image alimg_kbd -compound left -t "Keys" -com "alited::pref::Tab nbk5" -style TButtonWest}}
    {.butTools .butKeys T 1 1 {-st we} {-t "Tools" -com "alited::pref::Tab nbk6" -style TButtonWest}}
    {.v_  .butTools T 1 1 {-st ns} {-h 30}}
    {fraR fraL L 1 1 {-st nsew -cw 1}}
    {fraR.Nbk - - - - {pack -side top -expand 1 -fill both} {
        f1 {-t General}
        f2 {-t Saving}
    }}
    {fraR.nbk2 - - - - {pack forget -side top} {
        f1 {-t Editor}
        f2 {-t "Tcl syntax"}
        f3 {-t "C/C++ syntax"}
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
        f1 {-t e_menu}
        f2 {-t tkcon}
        f3 {-t bar/menu}
    }}
    {#LabMess fraL T 1 2 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {fraB fraL T 1 2 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.butHelp - - - - {pack -side left} {-t "Help" -com ::alited::pref::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 50}}
    {.butOK - - - - {pack -side left -anchor s -padx 2} {-t Save -command ::alited::pref::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -command ::alited::pref::Cancel}}
  }
}

proc pref::Ok {args} {
  fetchVars
  set ans [alited::msg yesnocancel info [msgcat::mc "For the settings to be active\nthe application should be restarted.\n\nRestart it just now?"] YES -geometry root=$win]
  if {$ans in {1 2}} {
    GetEmSave out
    # check options that can make alited unusable
    if {$al(INI,HUE)<-40 || $al(INI,HUE)>40} {set al(INI,HUE) 0}
    if {$al(FONTSIZE,small)<8 || $al(FONTSIZE,small)>14} {set al(FONTSIZE,small) 10}
    if {$al(FONTSIZE,std)<9 || $al(FONTSIZE,std)>18} {set al(FONTSIZE,std) 11}
    if {$al(INI,RECENTFILES)<10 || $al(INI,RECENTFILES)>50} {set al(INI,RECENTFILES) 16}
    if {$al(FAV,MAXLAST)<10 || $al(FAV,MAXLAST)>100} {set al(FAV,MAXLAST) 100}
    if {$al(MAXFILES)<1000 || $al(MAXFILES)>9999} {set al(MAXFILES) 2000}
    if {$al(INI,barlablen)<10 || $al(INI,barlablen)>100} {set al(INI,barlablen) 16}
    if {$al(INI,bartiplen)<10 || $al(INI,bartiplen)>100} {set al(INI,bartiplen) 32}
    set al(INI,CS) [scan $opcc %d:]
    if {![string is integer -strict $al(INI,CS)]} {set al(INI,CS) -1}
    set al(EM,CS)  [scan $opcc2 %d:]
    if {![string is integer -strict $al(EM,CS)]} {set al(EM,CS) -1}
    set al(ED,CKeyWords) [[$obDl2 TexCKeys] get 1.0 {end -1c}]
    set al(ED,CKeyWords) [string map [list \n { }] $al(ED,CKeyWords)]
    set al(BACKUP) [string trim $al(BACKUP)]
    $obDl2 res $win 1
    if {$ans == 1} {alited::Exit - 1 no}
  }
}

proc pref::Cancel {args} {
  fetchVars
  RestoreSettings
  GetEmSave out
  $obDl2 res $win 0
}

proc pref::Tab {tab {nt ""} {doit no} {dotip no}} {
  # changing the current tab: we need to save the old tab's selection
  # in order to restore the selection at the tab's return.
  fetchVars
  if {$tab ne $curTab || $doit} {
    if {$curTab ne ""} {
      set arrayTab($curTab) [$win.fraR.$curTab select]
      pack forget $win.fraR.$curTab
    }
    set curTab $tab
    pack $win.fraR.$curTab -expand yes -fill both
    catch {
      if {$nt eq ""} {set nt $arrayTab($curTab)}
      $win.fraR.$curTab select $nt
    }
  }
}

proc pref::Help {} {
  fetchVars
  set sel [lindex [split [$win.fraR.$curTab select] .] end]
  alited::Help $win "-${curTab}-$sel"
}

# ________________________ Tabs "General" _________________________ #

proc pref::General_Tab1 {} {
  fetchVars
  set opcc [set opcc2 [msgcat::mc {Color schemes}]]
  set opcColors [list "{$opcc}"]
  for {set i -1; set n [apave::cs_MaxBasic]} {$i<=$n} {incr i} {
    if {(($i+2) % ($n/2+2)) == 0} {lappend opcColors |}
    set csname [::apave::obj csGetName $i]
    lappend opcColors [list $csname]
    if {$i == $al(INI,CS)} {set opcc $csname}
    if {$i == $al(EM,CS)} {set opcc2 $csname}
  }
  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labCS - - 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.opc .labCS L 1 1 {-st sw -pady 5} {::alited::pref::opcc alited::pref::opcColors {-width 20} {alited::pref::opcToolPre %a}}}
    {.labHue .labCS T 1 1 {-st w -pady 1 -padx 3} {-t "Tint:"}}
    {.spxHue .labHue L 1 1 {-st sw -pady 5} {-tvar alited::al(INI,HUE) -from -40 -to 40 -justify center -w 3}}
    {.labFsz1 .labHue T 1 1 {-st w -pady 8 -padx 3} {-t "Small font size:"}}
    {.spxFsz1 .labFsz1 L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONTSIZE,small) -from 8 -to 14 -justify center -w 3}}
    {.labFsz2 .labFsz1 T 1 1 {-st w -pady 8 -padx 3} {-t "Middle font size:"}}
    {.spxFsz2 .labFsz2 L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONTSIZE,std) -from 9 -to 18 -justify center -w 3}}
    {lab fra1 T 1 2 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra2 lab T 1 2 {-st nsew -rw 1 -cw 1}}
    {.TexNotes - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 90 -wrap word -tabnext $alited::pref::win.fraB.butOK -tip {$alited::al(MC,notes)}}}
    {.sbv .TexNotes L - - {pack -side left}}
  }
}

proc pref::General_Tab2 {} {

  GetEmSave in
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labConf - - 1 1 {-st w -pady 1 -padx 3} {-t "Confirm exit:"}}
    {.chbConf .labConf L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,confirmexit)}}
    {.seh1 .labConf T 1 2 {-st ew -pady 5}}
    {.labS .seh1 T 1 1 {-st w -pady 1 -padx 3} {-t "Save configuration on"}}
    {.labSonadd .labS T 1 1 {-st e -pady 1 -padx 3} {-t "opening a file:"}}
    {.chbOnadd .labSonadd L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onadd)}}
    {.labSonclose .labSonadd T 1 1 {-st e -pady 1 -padx 3} {-t "closing a file:"}}
    {.chbOnclose .labSonclose L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onclose)}}
    {.labSonsave .labSonclose T 1 1 {-st e -pady 1 -padx 3} {-t "saving a file:"}}
    {.chbOnsave .labSonsave L 1 1 {-st sw -pady 1 -padx 3} {-var alited::al(INI,save_onsave)}}
    {.seh2 .labSonsave T 1 2 {-st ew -pady 5}}
    {.labSave .seh2 T 1 1 {-st w -pady 1 -padx 3} {-t "Save before bar/menu runs:"}}
    {.cbxSave .labSave L 1 1 {-st sw -pady 1} {-values {$alited::al(pref,saveonrun)} -tvar alited::al(EM,save) -state readonly -w 20}}
    {.seh3 .labSave T 1 2 {-st ew -pady 5}}
    {.labRecnt .seh3 T 1 1 {-st w -pady 1 -padx 3} {-t "'Recent Files' length:"}}
    {.spxRecnt .labRecnt L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,RECENTFILES) -from 10 -to 50 -justify center -w 3}}
    {.labMaxLast .labRecnt T 1 1 {-st w -pady 1 -padx 3} {-t "'Last Visited' length:"}}
    {.spxMaxLast .labMaxLast L 1 1 {-st sw -pady 1} {-tvar alited::al(FAV,MAXLAST) -from 10 -to 100 -justify center -w 3}}
    {.labMaxFiles .labMaxLast T 1 1 {-st w -pady 1 -padx 3} {-t "Maximum of project files:"}}
    {.spxMaxFiles .labMaxFiles L 1 1 {-st sw -pady 1} {-tvar alited::al(MAXFILES) -from 1000 -to 9999 -justify center -w 5}}
    {.seh4 .labMaxFiles T 1 2 {-st ew -pady 5}}
    {.labBackup .seh4 T 1 1 {-st w -pady 1 -padx 3} {-t "Back up files to a project's subdirectory:"}}
    {.entBackup .labBackup L 1 1 {-st sw -pady 1} {-tvar alited::al(BACKUP) -w 20 -tip "A subdirectory of projects where backup copies of files will be saved to.\nSet the field blank to cancel the backup."}}
  }
}

proc pref::opcToolPre {args} {
  lassign $args a
  set a [string trim $a ":"]
  if {[string is integer $a]} {
    lassign [::apave::obj csGet $a] - fg - bg
    return "-background $bg -foreground $fg"
  } else {
    return ""
  }
}

proc pref::GetEmSave {to} {
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

# ________________________ Tab "Editor" _________________________ #

proc pref::Edit_Tab1 {} {
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labFon - - 1 1 {-st w -pady 8 -padx 3} {-t "Font:"}}
    {.fonTxt .labFon L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONT,txt) -w 40}}
    {.labSp1 .labFon T 1 1 {-st w -pady 1 -padx 3} {-t "Space above lines:"}}
    {.spxSp1 .labSp1 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp1) -from 0 -to 16 -justify center -w 3}}
    {.labSp2 .labSp1 T 1 1 {-st w -pady 1 -padx 3} {-t "Space between wraps:"}}
    {.spxSp2 .labSp2 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp2) -from 0 -to 16 -justify center -w 3}}
    {.labSp3 .labSp2 T 1 1 {-st w -pady 1 -padx 3} {-t "Space below lines:"}}
    {.spxSp3 .labSp3 L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,sp3) -from 0 -to 16 -justify center -w 3}}
    {.seh .labSp3 T 1 2 {-pady 3}}
    {.labLl .seh T 1 1 {-st w -pady 1 -padx 3} {-t "Tab bar label's length:"}}
    {.spxLl .labLl L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(INI,barlablen) -from 10 -to 100 -justify center -w 3}}
    {.labTl .labLl T 1 1 {-st w -pady 1 -padx 3} {-t "Tab bar tip's length:"}}
    {.spxTl .labTl L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(INI,bartiplen) -from 10 -to 100 -justify center -w 3}}
    {.seh2 .labTl T 1 2 {-pady 3}}
    {.labGW .seh2 T 1 1 {-st w -pady 1 -padx 3} {-t "Gutter's width:"}}
    {.spxGW .labGW L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,gutterwidth) -from 3 -to 7 -justify center -w 3}}
    {.labGS .labGW T 1 1 {-st w -pady 1 -padx 3} {-t "Gutter's shift from text:"}}
    {.spxGS .labGS L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,guttershift) -from 0 -to 10 -justify center -w 3}}
  }
}

proc pref::Edit_Tab2 {} {
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "Tcl files' extensions:"}}
    {.entExt .labExt L 1 3 {-st sw -pady 3} {-tvar alited::al(TclExtensions) -w 30}}
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
    {.clrPROC .labPROC L 1 1 {-st sw -pady } {-tvar alited::al(ED,clrPROC) -w 20}}
    {.labOPT .labPROC T 1 1 {-st w -pady 3 -padx 3} {-t "Color of options:"}}
    {.clrOPT .labOPT L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrOPT) -w 20}}
    {.labBRA .labOPT T 1 1 {-st w -pady 3 -padx 3} {-t "Color of brackets:"}}
    {.clrBRA .labBRA L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,clrBRA) -w 20}}
    {.seh .labBRA T 1 2 {-pady 3}}
    {.but .seh T 1 1 {-st w} {-t Default -com alited::pref::TclSyntax_Default}}
  }
}

proc pref::Edit_Tab3 {} {
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {.labExt - - 1 1 {-st w -pady 3 -padx 3} {-t "C/C++ files' extensions:"}}
    {.entExt .labExt L 1 3 {-st sw -pady 3} {-tvar alited::al(ClangExtensions) -w 30}}
    {.labCOM .labExt T 1 1 {-st w -pady 3 -padx 3} {-t "Color of C key words:"}}
    {.clrCOM .labCOM L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCOM) -w 20}}
    {.labCOMTK .labCOM T 1 1 {-st w -pady 3 -padx 3} {-t "Color of C++ key words:"}}
    {.clrCOMTK .labCOMTK L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCOMTK) -w 20}}
    {.labSTR .labCOMTK T 1 1 {-st w -pady 3 -padx 3} {-t "Color of strings:"}}
    {.clrSTR .labSTR L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrSTR) -w 20}}
    {.labVAR .labSTR T 1 1 {-st w -pady 3 -padx 3} {-t "Color of punctuation:"}}
    {.clrVAR .labVAR L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrVAR) -w 20}}
    {.labCMN .labVAR T 1 1 {-st w -pady 3 -padx 3} {-t "Color of comments:"}}
    {.clrCMN .labCMN L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrCMN) -w 20}}
    {.labPROC .labCMN T 1 1 {-st w -pady 3 -padx 3} {-t "Color of return/goto:"}}
    {.clrPROC .labPROC L 1 1 {-st sw -pady } {-tvar alited::al(ED,CclrPROC) -w 20}}
    {.labOPT .labPROC T 1 1 {-st w -pady 3 -padx 3} {-t "Color of your key words:"}}
    {.clrOPT .labOPT L 1 1 {-st sw -pady } {-tvar alited::al(ED,CclrOPT) -w 20}}
    {.labBRA .labOPT T 1 1 {-st w -pady 3 -padx 3} {-t "Color of brackets:"}}
    {.clrBRA .labBRA L 1 1 {-st sw -pady 3} {-tvar alited::al(ED,CclrBRA) -w 20}}
    {.seh .labBRA T 1 2 {-pady 3}}
    {.but .seh T 1 1 {-st w} {-t Default -com alited::pref::CSyntax_Default}}
    {.seh2 .but T 1 2 {-pady 10}}
    {fra.scf.fra2 .seh2 T 1 2 {-st nsew}}
    {.labAddKeys - - 1 1 {-st nw -pady 3} {-t "Your key words:"}}
    {.TexCKeys .labAddKeys L 1 1 {-st new} {-h 7 -w 40 -wrap word -tabnext $alited::pref::win.fraB.butOK}}
  }
}

proc pref::TclSyntax_Default {} {
  fetchVars
  set Dark [::apave::obj csDarkEdit]
  set clrnams [::hl_tcl::hl_colorNames]
  set clrvals [::hl_tcl::hl_colors {} $Dark]
  foreach nam $clrnams val $clrvals {
    set al(ED,$nam) $val
  }
  set al(ED,Dark) $Dark
}

proc pref::CSyntax_Default {} {
  fetchVars
  set Dark [::apave::obj csDarkEdit]
  set clrnams [::hl_tcl::hl_colorNames]
  set clrvals [::hl_c::hl_colors {} $Dark]
  foreach nam $clrnams val $clrvals {
    set al(ED,C$nam) $val
  }
}

# ________________________ Tab "Template" _________________________ #

proc pref::Template_Tab {} {

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
  }
}

# ________________________ Tab "Keys" _________________________ #

proc pref::Keys_Tab1 {} {
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

proc pref::RegisterKeys {} {
  fetchVars
  alited::keys::Delete preference
  for {set k 0} {$k<$stdkeysSize} {incr k} {
    alited::keys::Add preference $k [set keys($k)] "alited::pref::BindKey $k {%k}"
  }
}

proc pref::GetKeyList {nk} {
  fetchVars
  RegisterKeys
  [$obDl2 CbxKey$nk] configure -values [alited::keys::VacantList]
}

proc pref::SelectKey {nk} {
  fetchVars
  alited::keys::Delete "" $prevkeys($nk)
  set prevkeys($nk) $keys($nk)
  GetKeyList $nk
}

proc pref::KeyAccelerator {nk defk} {
  set acc [BindKey $nk - $defk]
  return [::apave::KeyAccelerator $acc]
}

proc pref::KeyAccelerators {} {
  fetchVars
  dict for {k info} $stdkeys {
    set al(acc_$k) [KeyAccelerator $k [lindex $info 1]]
  }
}

proc pref::BindKey {nk {key ""} {defk ""}} {
  fetchVars
  if {$key eq "-"} {
    if {[info exists keys($nk)]} {
      return $keys($nk)
    }
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
  return ""
}

proc pref::IniKeys {} {
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
    {.chbUself .labUself L 1 1 {-st sw -pady 1} {-var alited::al(INI,LEAF) -onvalue yes -offvalue no -com alited::pref::CheckUseLeaf -afteridle alited::pref::CheckUseLeaf}}
    {.labLf .labUself T 1 1 {-st w -pady 1 -padx 3} {-t "Leaf's regexp:"}}
    {.EntLf .labLf L 1 1 {-st sw -pady 1} {-tvar alited::al(RE,leaf) -w 70}}
    {.seh_2 .labLf T 1 2 {-pady 5}}
    {.labUnt .seh_2 T 1 1 {-st w -pady 1 -padx 3} {-t "Untouched top lines:"}}
    {.spxUnt .labUnt L 1 1 {-st sw -pady 1} {-tvar alited::al(INI,LINES1) -from 2 -to 200 -w 4}}
    {.seh_3 .labUnt T 1 2 {-pady 5}}
    {.but .seh_3 T 1 1 {-st w} {-t Default -com alited::pref::Units_Default}}
  }
}

proc pref::Units_Default {} {
  fetchVars
  set al(INI,LINES1) 10
  set al(INI,LEAF) 0
  set al(RE,branch) {^\s*(#+) [_]+\s+([^_]+[^[:blank:]]*)\s+[_]+ (#+)$}         ;#  # _ lev 1 _..
  set al(RE,leaf) {^\s*##\s*[-]*([^-]*)\s*[-]*$}   ;#  # --  / # -- abc / # --abc--
  set al(RE,proc) {^\s*(((proc|method)\s+([^[:blank:]]+))|((constructor|destructor)))\s.+}
  set al(RE,leaf2) {^\s*(#+) [_]+}                       ;#  # _  / # _ abc
  set al(RE,proc2) {^\s*(proc|method|constructor|destructor)\s+} ;# proc abc {}...
}

proc pref::CheckUseLeaf {} {
  fetchVars
  if {$al(INI,LEAF)} {set state normal} {set state disabled}
  [$obDl2 EntLf] configure -state $state
}

# ________________________ Tab "Tools" _________________________ #

proc pref::Emenu_Tab {} {
  set alited::al(EM,menu) [file join $alited::al(EM,menudir) \
    [file tail $alited::al(EM,menu)]]
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode x}}
    {.labExe - - 1 1 {-st w -pady 1 -padx 3} {-t "Run as external app:"}}
    {.chbExe .labExe L 1 1 {-st sw -pady 5} {-var alited::al(EM,exec) -onvalue yes -offvalue no}}
    {.labCS .labExe T 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.opc .labCS L 1 1 {-st sw -pady 5} {::alited::pref::opcc2 alited::pref::opcColors {-width 20} {alited::pref::opcToolPre %a}}}
    {.labGeo .labCS T 1 1 {-st w -pady 1 -padx 3} {-t "Geometry:"}}
    {.entGeo .labGeo L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,geometry) -w 40}}
    {.labDir .labGeo T 1 1 {-st w -pady 1 -padx 3} {-t "Directory of menus:"}}
    {.dirEM .labDir L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,menudir) -w 40}}
    {.labMenu .labDir T 1 1 {-st w -pady 1 -padx 3} {-t "Main menu:"}}
    {.filMenu .labMenu L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,menu) -w 40 -filetypes {{{Menus} .mnu} {{All files} .* }}}}
    {.labPD .labMenu T 1 1 {-st w -pady 1 -padx 3} {-t "Projects (%PD wildcard):"}}
    {.filPD .labPD L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,PD=) -w 40}}
    {.labDoc .labPD T 1 1 {-st w -pady 1 -padx 3} {-t "Path to man/tcl8.6:"}}
    {.dirDoc .labDoc L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,h=) -w 40}}
    {.labTT .labDoc T 1 1 {-st w -pady 1 -padx 3} {-t "Linux terminal:"}}
    {.entTT .labTT L 1 1 {-st sw -pady 5} {-tvar alited::al(EM,tt=) -w 40}}
    {.labDF .labTT T 1 1 {-st w -pady 1 -padx 3} {-t "Diff tool:"}}
    {.entDF .labDF L 1 1 {-st sw -pady 1} {-tvar alited::al(EM,DiffTool) -w 40}}
  }
}

proc pref::Tkcon_Default {} {
  fetchVars
  set al(tkcon,clrbg) #25292b
  set al(tkcon,clrblink) #929281
  set al(tkcon,clrcursor) #FFFFFF
  set al(tkcon,clrdisabled) #999797
  set al(tkcon,clrproc) #FF6600
  set al(tkcon,clrvar) #602B06
  set al(tkcon,clrprompt) #66FF10
  set al(tkcon,clrstdin) #FFFFFF
  set al(tkcon,clrstdout) #CECECE
  set al(tkcon,clrstderr) #FB44C0
  set al(tkcon,rows) 10
  set al(tkcon,cols) 80
  set al(tkcon,fsize) 13
  set al(tkcon,geo) +300+100
  set al(tkcon,topmost) 1
}

proc pref::Tkcon_Tab {} {
  if {![info exists alited::al(tkcon,clrbg)]} Tkcon_Default
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1}}
    {fra.scf - - 1 1  {pack -fill both -expand 1} {-mode y}}
    {fra.scf.lfr - - 1 1  {pack -fill x} {-t Colors}}
    {.labbg - - 1 1 {-st w -pady 1 -padx 3} {-t "bg:"}}
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
    {fra.scf.v_ fra.scf.lfr T 1 1  {pack} {-h 10}}
    {fra.scf.lfr2 fra.scf.v_ T 1 1  {pack -fill x} {-t Options}}
    {.labRows - - 1 1 {-st w -pady 1 -padx 3} {-t "Rows:"}}
    {.spxRows .labRows L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,rows) -from 4 -to 40 -w 4}}
    {.labCols .labRows T 1 1 {-st w -pady 1 -padx 3} {-t "Columns:"}}
    {.spxCols .labCols L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,cols) -from 15 -to 150 -w 4}}
    {.labFsize .labCols T 1 1 {-st w -pady 1 -padx 3} {-t "Font size:"}}
    {.spxFS .labFsize L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,fsize) -from 8 -to 20 -w 4}}
    {.labGeo .labFsize T 1 1 {-st w -pady 1 -padx 3} {-t "Geometry:"}}
    {.entGeo .labGeo L 1 1 {-st sw -pady 1} {-tvar alited::al(tkcon,geo) -w 20}}
    {.labTopmost .labGeo T 1 1 {-st w -pady 1 -padx 3} {-t "Stay on top:"}}
    {.chbTopmost .labTopmost L 1 1 {-st sw -pady 1} {-var alited::al(tkcon,topmost)}}
    {fra.scf.but - - - - {pack -side left} {-t Default -com alited::pref::Tkcon_Default -w 20}}
    {fra.scf.but2 - - - - {pack -side left} {-t Test -com alited::tool::tkcon -w 20}}
  }
}

proc pref::Runs_Tab {} {

  fetchVars
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
  set em_Menus {}
  set curmenu menu.mnu
  set curlev 0
  set listMenus [alited::tool::EM_AllStructure $curmenu]
  foreach mit $listMenus {
    lassign $mit lev mnu hk item
    set item [string map [list \{ \\\{ \} \\\} \" \\\" \$ \\\$] $item]
    if {$lev>$curlev} {
      append em_Menus " \{$mnu"
    } elseif {$lev<$curlev} {
      append em_Menus "\} \"$item\""
    } else {
      append em_Menus " \"$item\""
    }
    set curlev $lev
  }
  append em_Menus [string repeat \} $curlev]
  return {
    {v_ - - 1 1}
    {fra v_ T 1 1 {-st nsew -cw 1 -rw 1} {-afteridle {::alited::pref::EmSeparators yes}}}
    {fra.ScfRuns - - 1 1  {pack -fill both -expand 1}}
    {tcl {
        set prt "- -"
        for {set i 0} {$i<$::alited::pref::em_Num} {incr i} {
          set nit [expr {$i+1}]
          set lwid ".buTAdd$i $prt 1 1 {-padx 0} {-tip {Inserts a new line.} -com {::alited::pref::EmAddLine $i} -takefocus 0 -relief flat -image alimg_add}"
          %C $lwid
          set lwid ".buTDel$i .buTAdd$i L 1 1 {-padx 1} {-tip {Deletes a line.} -com {::alited::pref::EmDelLine $i} -takefocus 0 -relief flat -image alimg_delete}"
          %C $lwid
          set lwid ".lab$i .buTDel$i L 1 1 {-st w -padx 3} {-t {Item$nit: }}"
          %C $lwid
          set lwid ".ChbMT$i .lab$i L 1 1 {-padx 10} {-t separator -var ::alited::pref::em_sep($i) -tip {If 'yes', means a separator of the toolbar/menu.} -com {::alited::pref::EmSeparators yes}}"
          %C $lwid
          set lwid ".OpcIco$i .ChbMT$i L 1 1 {-st nsw} {::alited::pref::em_ico($i) alited::pref::em_Icons {-width 10 -tooltip {{An icon puts the run into the toolbar.\nBlank or 'none' excludes it from the toolbar.}}} {alited::pref::opcIcoPre %a}}"
          %C $lwid
          set lwid ".ButMnu$i .OpcIco$i L 1 1 {-st sw -pady 1 -padx 10} {-t {$::alited::pref::em_mnu($i)} -com {alited::pref::PickMenuItem $i} -style TButtonWest -tip {{The run item for the menu and/or the toolbar.\nSelect it from the e_menu items.}}}"
          %C $lwid
          set prt ".buTAdd$i T"
      }}
    }
  }
}

proc pref::EmAddLine {idx} {
  fetchVars
  for {set i $em_Num} {$i>$idx} {} {
    incr i -1
    if {$i==$idx} {
      lassign {} em_mnu($i) em_ico($i) em_inf($i)
      set em_sep($i) 0
    } else {
      set ip [expr {$i-1}]
      set em_sep($i) $em_sep($ip)
      set em_ico($i) $em_ico($ip)
      set em_mnu($i) $em_mnu($ip)
      set em_inf($i) $em_inf($ip)
    }
  }
  EmSeparators yes
}

proc pref::EmDelLine {idx} {
  fetchVars
  for {set i $idx} {$i<$em_Num} {incr i} {
    if {$i==($em_Num-1)} {
      lassign {} em_mnu($i) em_ico($i) em_inf($i)
      set em_sep($i) 0
    } else {
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

proc pref::EmSeparators {upd} {
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

proc pref::PickMenuItem {it} {
  fetchVars
  if {![info exists ::em::geometry]} {
    source [file join $::e_menu_dir e_menu.tcl]
  }
  set w [$obDl2 ButMnu$it]
  set X [winfo rootx $w]
  set Y [winfo rooty $w]
  set res [::em::main -prior 1 -modal 1 -remain 0 -noCS 1 \
    {*}[alited::tool::EM_Options "pk=yes dk=dock o=0 t=1 g=+[incr X 5]+[incr Y 25]"]]
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

proc pref::ScrollRuns {} {
  # Updates scrollbars of Runs tab because its contents may have various length.
  fetchVars
  update
  ::apave::sframe resize [$obDl2 ScfRuns]
}

proc pref::opcIcoPre {args} {
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

proc pref::opcMnuPre {args} {
  fetchVars
  lassign $args a b c
  return "-label $args"
}

# ________________________ GUI procs _________________________ #
proc pref::_create {tab} {

  fetchVars
  $obDl2 makeWindow $win "$al(MC,pref) :: $::alited::USERDIR"
  $obDl2 paveWindow \
    $win [MainFrame] \
    $win.fraR.nbk.f1 [General_Tab1] \
    $win.fraR.nbk.f2 [General_Tab2] \
    $win.fraR.nbk2.f1 [Edit_Tab1] \
    $win.fraR.nbk2.f2 [Edit_Tab2] \
    $win.fraR.nbk2.f3 [Edit_Tab3] \
    $win.fraR.nbk3.f1 [Units_Tab] \
    $win.fraR.nbk4.f1 [Template_Tab] \
    $win.fraR.nbk5.f1 [Keys_Tab1] \
    $win.fraR.nbk6.f1 [Emenu_Tab] \
    $win.fraR.nbk6.f2 [Tkcon_Tab] \
    $win.fraR.nbk6.f3 [Runs_Tab]
  if {$minsize eq ""} {      ;# save default min.sizes
    after idle [list after 100 {
      set ::alited::pref::minsize "-minsize {[winfo width $::alited::pref::win] [winfo height $::alited::pref::win]}"
    }]
  }
  set fnotes [file join $::alited::USERDIR notes.txt]
  if {[file exists $fnotes]} {
    [$obDl2 TexNotes] insert end [::apave::readTextFile $fnotes]
  }
  [$obDl2 TexCKeys] insert end $al(ED,CKeyWords)
  if {$tab ne {}} {
    switch -exact $tab {
      Emenu_Tab {
        set nbk nbk6
        set nt $win.fraR.nbk6.f3
      }
    }
    Tab $nbk $nt yes
  } elseif {$oldTab ne {}} {
    Tab $oldTab $arrayTab($oldTab) yes
  }
  set res [$obDl2 showModal $win -geometry $geo {*}$minsize \
    -onclose ::alited::pref::Cancel]
  set fcont [[$obDl2 TexNotes] get 1.0 {end -1c}]
  ::apave::writeTextFile $fnotes fcont
  if {[llength $res] < 2} {set res ""}
  set geo [wm geometry $win] ;# save the new geometry of the dialogue
  set oldTab $curTab
  set arrayTab($curTab) [$win.fraR.$curTab select]
  destroy $win
  return $res
}

proc pref::_init {} {
  fetchVars
  SaveSettings
  set curTab "nbk"
  IniKeys
}

proc pref::_run {{tab {}}} {

  _init
  set res [_create $tab]
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
