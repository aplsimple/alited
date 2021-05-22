#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The Settings procedures.
# _______________________________________________________________________ #

namespace eval pref {
  variable win $::alited::al(WIN).fraPref
  variable geo root=$::alited::al(WIN)
  variable minsize ""
  variable data; array set data [list]
  variable keys; array set keys [list]
  variable prevkeys; array set prevkeys [list]
  variable savekeys; array set savekeys [list]
  variable arrayTab; array set arrayTab [list]
  variable curTab "nbk"
  variable oldTab ""
  variable opcColors [list]
  variable opcc ""
  variable stdkeys
  set stdkeys [dict create \
     0 [list "Save File" F2] \
     1 [list "Save File as" Control-S] \
     2 [list "Run e_menu" F4] \
     3 [list "Run file" F5] \
     4 [list "Double Selection" Control-D] \
     5 [list "Delete Line" Control-Y] \
     6 [list "Indent" Control-I] \
     7 [list "Unindent" Control-U] \
     8 [list "Comment" Control-bracketleft] \
     9 [list "Uncomment" Control-bracketright] \
    10 [list "Highlight First" Alt-Q] \
    11 [list "Highlight Last" Alt-W] \
    12 [list "Find Next Match" F3] \
    13 [list "Look for Declaration" Control-L] \
    14 [list "Look for Word" Control-Shift-L] \
    15 [list "Item up" F11] \
    16 [list "Item down" F12] \
    17 [list "Go to Line" Control-G] \
  ]
  variable stdkeysSize [dict size $stdkeys]
}

proc pref::EditPreferences {} {
  # Direct editing of the settings file. Just for completeness.
  namespace upvar ::alited al al obPav obPav
  set filecont [::apave::readTextFile $al(INI)]
  $obPav vieweditFile $al(INI) "" -ro 0 -h 25
  if {$filecont ne [::apave::readTextFile $al(INI)]} {
    alited::Exit - 2
  }
}

# ________________________ Common procedures _________________________ #

proc pref::SavedOptions {} {
  namespace upvar ::alited al al
  return [array name al]
}

proc pref::SaveSettings {} {
  namespace upvar ::alited al al
  variable data
  foreach o [SavedOptions] {
    set data($o) $al($o)
  }
}

proc pref::RestoreSettings {} {
  namespace upvar ::alited al al
  variable data
  variable keys
  variable stdkeys
  variable savekeys
  variable prevkeys
  foreach o [SavedOptions] {
    set al($o) $data($o)
  }
  dict for {k info} $stdkeys {
    set keys($k) $savekeys($k)
    SelectKey $k
  }
}

# ________________________ Main Frame _________________________ #

proc pref::MainFrame {} {
  namespace upvar ::alited al al obDl2 obDl2
  return {
    {fraL - - 1 1 {-st nws -rw 2}}
    {.ButHome - - 1 1 {-st we} {-t "General" -com "alited::pref::Tab nbk" -style TButtonWest}}
    {.butChange fraL.butHome T 1 1 {-st we} {-t "Editor" -com "alited::pref::Tab nbk2" -style TButtonWest}}
    {.butCategories fraL.butChange T 1 1 {-st we} {-t "Units" -com "alited::pref::Tab nbk3" -style TButtonWest}}
    {.butActions fraL.butCategories T 1 1 {-st we} {-t "Templates" -com "alited::pref::Tab nbk4" -style TButtonWest}}
    {.butKeys fraL.butActions T 1 1 {-st we} {-image alimg_kbd -compound left -t "Keys" -com "alited::pref::Tab nbk5" -style TButtonWest}}
    {.butTools fraL.butKeys T 1 1 {-st we} {-t "Tools" -com "alited::pref::Tab nbk6" -style TButtonWest}}
    {.v_  fraL.butTools T 1 1 {-st ns} {-h 30}}
    {fraR fraL L 1 1 {-st nsew -cw 1}}
    {fraR.Nbk - - - - {pack -side top -expand 1 -fill both} {
      f1 {-t "View"}
      f2 {-t "Options"}
      -traverse yes -select f1
    }}
    {fraR.nbk2 - - - - {pack forget -side top} {
      f1 {-t "View"}
      f2 {-t "Syntax"}
      -tr {just to test "-tr*" to call ttk::notebook::enableTraversal}
    }}
    {fraR.nbk3 - - - - {pack forget -side top} {
      f1 {-t "Units"}
    }}
    {fraR.nbk4 - - - - {pack forget -side top} {
      f1 {-t "Templates"}
    }}
    {fraR.nbk5 - - - - {pack forget -side top} {
      f1 {-t "Keys"}
    }}
    {fraR.nbk6 - - - - {pack forget -side top} {
      f1 {-t "Tools"}
      f2 {-t "e_menu"}
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
  namespace upvar ::alited al al obDl2 obDl2
  variable opcc
  variable win
  set ans [alited::msg yesnocancel info [msgcat::mc "For the settings to be active\nthe application should be restarted.\n\nRestart it just now?"] YES -geometry root=$win]
  if {$ans in {1 2}} {
    set al(INI,CS) [scan $opcc %d:]
    if {![string is digit -strict $al(INI,CS)]} {set al(INI,CS) -1}
    $obDl2 res $win 1
    if {$ans == 1} {alited::Exit - 1}
  }
}

proc pref::Cancel {args} {
  namespace upvar ::alited obDl2 obDl2
  variable win
  RestoreSettings
  $obDl2 res $win 0
}

proc pref::Tab {tab {nt ""} {doit no} {dotip no}} {
  # changing the current tab: we need to save the old tab's selection
  # in order to restore the selection at the tab's return.
  variable arrayTab
  variable curTab
  variable win
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
  variable curTab
  variable win
  set sel [lindex [split [$win.fraR.$curTab select] .] end]
  alited::Help $win "-${curTab}-$sel"
}

# ________________________ Tabs "General" _________________________ #

## ________________________ General / View _________________________ ##

proc pref::General_Tab1 {} {
  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labCS - - 1 1 {-st w -pady 1 -padx 3} {-t "Color scheme:"}}
    {.opc fra1.labCS L 1 1 {-st sw -pady 5} {::alited::pref::opcc alited::pref::opcColors {-width 20} {alited::pref::opcToolPre %a}}}
    {.labHue fra1.labCS T 1 1 {-st w -pady 1 -padx 3} {-t "Tint:"}}
    {.spxHue fra1.labHue L 1 1 {-st sw -pady 5} {-tvar alited::al(INI,HUE) -from -40 -to 40 -justify center -w 3}}
    {.labFsz1 fra1.labHue T 1 1 {-st w -pady 8 -padx 3} {-t "Small font's size:"}}
    {.spxFsz1 fra1.labFsz1 L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONTSIZE,small) -from 8 -to 14 -justify center -w 3}}
    {.labFsz2 fra1.labFsz1 T 1 1 {-st w -pady 8 -padx 3} {-t "Middle font's size:"}}
    {.spxFsz2 fra1.labFsz2 L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONTSIZE,std) -from 9 -to 16 -justify center -w 3}}
    {.labFsz3 fra1.labFsz2 T 1 1 {-st w -pady 8 -padx 3} {-t "Large font's size:"}}
    {.spxFsz3 fra1.labFsz3 L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(FONTSIZE,txt) -from 10 -to 18 -justify center -w 3}}
    {lab fra1 T 1 2 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra2 lab T 1 2 {-st nsew -rw 1 -cw 1}}
    {.TexNotes - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 77 -wrap word -tabnext $alited::pref::win.fraB.butOK -tip {$alited::al(MC,notes)}}}
    {.sbv fra2.TexNotes L - - {pack -side left}}
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

## ________________________ General / Options _________________________ ##

proc pref::General_Tab2 {} {
  return {
    {v_ - - 1 10}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labEOL - - 1 1 {-st w -pady 1 -padx 3} {-t "End of line:"}}
    {.cbxEOL fra1.labEOL L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,EOL) -values {{} LF CR CRLF} -w 5 -state readonly}}
    {.labIndent fra1.labEOL T 1 1 {-st w -pady 1 -padx 3} {-t "Indentation:"}}
    {.spXIndent fra1.labIndent L 1 1 {-st sw -pady 5 -padx 3} {-tvar alited::al(ED,indent) -w 3 -from 2 -to 8 -justify center}}
    {.labMult fra1.labIndent T 1 1 {-st w -pady 1 -padx 3} {-t "Multi-line strings:" -tip {$alited::al(MC,notrecomm)}}}
    {.chbMult fra1.labMult L 1 1 {-st sw -pady 5 -padx 3} {-var alited::al(ED,multiline) -tip {$alited::al(MC,notrecomm)}}}
    {#.labFlist fra2.labMult T 1 1 {-pady 5 -padx 3} {-t "List of files:"}}
    {#fraFlist fra2.labFlist T 1 2 {-st nswe -padx 3 -cw 1 -rw 1}}
    {#.LbxFlist - - - - {pack -side left -fill both -expand 1}}
    {#.sbvFlist fraFlist.lbxFlist L - - {pack -side left}}
  }
}

# ________________________ Tabs "Edit" _________________________ #

## ________________________ Edit / View _________________________ ##

proc pref::Edit_Tab1 {} {
}

## ________________________ Edit / Syntax _________________________ ##

proc pref::Edit_Tab2 {} {
}

# ________________________ Tab "Units" _________________________ #

proc pref::Units_Tab1 {} {
}

# ________________________ Tab "Template" _________________________ #

proc pref::Template_Tab1 {} {

  return {
    {v_ - - 1 1}
    {fra v_ T 1 2 {-st nsew -cw 1}}
    {.labH - - 1 2 {-st w -pady 5 -padx 3} {-t "Enter %U, %u, %m, %w, %d, %t wildcards of templates:"}}
    {.labU fra.labH T 1 1 {-st w -pady 1 -padx 3} {-t "User name:"}}
    {.entU fra.labU L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%U) -w 40}}
    {.labu fra.labU T 1 1 {-st w -pady 1 -padx 3} {-t "Login:"}}
    {.entu fra.labu L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%u) -w 30}}
    {.labm fra.labu T 1 1 {-st w -pady 1 -padx 3} {-t "E-mail:"}}
    {.entm fra.labm L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%m) -w 40}}
    {.labw fra.labm T 1 1 {-st w -pady 1 -padx 3} {-t "WWW:"}}
    {.entw fra.labw L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%w) -w 40}}
    {.labd fra.labw T 1 1 {-st w -pady 1 -padx 3} {-t "Date format:"}}
    {.entd fra.labd L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%d) -w 30}}
    {.labt fra.labd T 1 1 {-st w -pady 1 -padx 3} {-t "Time format:"}}
    {.entt fra.labt L 1 1 {-st sw -pady 5} {-tvar alited::al(TPL,%t) -w 30}}
  }
}

# ________________________ Tab "Keys" _________________________ #

proc pref::Keys_Tab1 {} {
  return {
    {v_ - - 1 10}
    {fra v_ T 1 2 {-st nsew -cw 1}}
    {tcl {
      set pr -
      for {set i 0} {$i<$alited::pref::stdkeysSize} {incr i} {
        set lab "lab$i"
        set cbx "CbxKey$i"
        lassign [dict get $alited::pref::stdkeys $i] text key
        set lwid ".$lab $pr T 1 1 {-st w -pady 1 -padx 3} {-t \"$text\"}"
        %C $lwid
        set lwid ".$cbx fra.$lab L 1 1 {-st we} {-tvar ::alited::pref::keys($i) -postcommand {::alited::pref::GetKeyList $i} -selcombobox {::alited::pref::SelectKey $i} -state readonly -h 16 -w 20}"
        %C $lwid
        set pr fra.$lab
      }
    }}
  }
}

proc pref::RegisterKeys {} {
  variable keys
  variable stdkeysSize
  alited::keys::Delete preference
  for {set k 0} {$k<$stdkeysSize} {incr k} {
    alited::keys::Add preference $k [set keys($k)] "alited::pref::BindKey $k {%k}"
  }
}

proc pref::GetKeyList {nk} {
  namespace upvar ::alited obDl2 obDl2
  RegisterKeys
  [$obDl2 CbxKey$nk] configure -values [alited::keys::VacantList]
}

proc pref::SelectKey {nk} {
  namespace upvar ::alited obDl2 obDl2
  variable keys
  variable prevkeys
  alited::keys::Delete "" $prevkeys($nk)
  set prevkeys($nk) $keys($nk)
  GetKeyList $nk
}

proc pref::KeyAccelerator {nk defk} {
  set acc [BindKey $nk - $defk]
  return [::apave::KeyAccelerator $acc]
}

proc pref::KeyAccelerators {} {
  namespace upvar ::alited al al
  variable stdkeys
  dict for {k info} $stdkeys {
    set al(acc_$k) [KeyAccelerator $k [lindex $info 1]]
  }
}

proc pref::BindKey {nk {key ""} {defk ""}} {
  variable keys
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
  variable keys
  variable prevkeys
  variable savekeys
  variable stdkeys
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

# ________________________ Tab "Tools" _________________________ #

proc pref::TODO_Tab {} {
  return {
    {buT - - 1 1 {pack -fill both -expand 1} {-t TODO}}
  }
}

# ________________________ GUI procs _________________________ #
proc pref::_create {} {

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable geo
  variable minsize
  variable prjlist
  variable arrayTab
  variable curTab
  variable oldTab
  $obDl2 makeWindow $win "$al(MC,pref) :: $::alited::USERDIR"
  $obDl2 paveWindow \
    $win [MainFrame] \
    $win.fraR.nbk.f1 [General_Tab1] \
    $win.fraR.nbk.f2 [General_Tab2] \
    $win.fraR.nbk2.f1 [TODO_Tab] \
    $win.fraR.nbk2.f2 [TODO_Tab] \
    $win.fraR.nbk3.f1 [TODO_Tab] \
    $win.fraR.nbk4.f1 [Template_Tab1] \
    $win.fraR.nbk5.f1 [Keys_Tab1] \
    $win.fraR.nbk6.f1 [TODO_Tab] \
    $win.fraR.nbk6.f2 [TODO_Tab]
  if {$minsize eq ""} {      ;# save default min.sizes
    after idle [list after 100 {
      set ::alited::pref::minsize "-minsize {[winfo width $::alited::pref::win] [winfo height $::alited::pref::win]}"
    }]
  }
  if {$oldTab ne ""} {
    Tab $oldTab $arrayTab($oldTab) yes
  }
  set fnotes [file join $::alited::USERDIR notes.txt]
  if {[file exists $fnotes]} {
    [$obDl2 TexNotes] insert end [::apave::readTextFile $fnotes]
  }
  set res [$obDl2 showModal $win  -geometry $geo {*}$minsize \
    -onclose ::alited::pref::Cancel]
  set fcont [[$obDl2 TexNotes] get 1.0 "end -1c"]
  ::apave::writeTextFile $fnotes fcont
  if {[llength $res] < 2} {set res ""}
  set geo [wm geometry $win] ;# save the new geometry of the dialogue
  set oldTab $curTab
  set arrayTab($curTab) [$win.fraR.$curTab select]
  destroy $win
  return $res
}

proc pref::_init {} {
  namespace upvar ::alited al al
  variable opcColors
  variable opcc
  variable curTab
  SaveSettings
  set curTab "nbk"
  set opcc [msgcat::mc {Color schemes}]
  set opcColors [list "{$opcc}"]
  for {set i -1; set n [apave::cs_MaxBasic]} {$i<=$n} {incr i} {
    if {(($i+2) % ($n/2+2)) == 0} {lappend opcColors "|"}
    set csname [::apave::obj csGetName $i]
    lappend opcColors [list $csname]
    if {$i == $al(INI,CS)} {
      set opcc $csname
    }
  }
  IniKeys
}

proc pref::_run {} {

  _init
  set res [_create]
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
