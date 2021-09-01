#! /usr/bin/env tclsh
###########################################################
# Name:    unit_tpl.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/01/2021
# Brief:   Handles templates of code.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval ::alited::unit_tpl {

  # "Templates" dialogue's path
  variable win $::alited::al(WIN).fraTpl

  variable tpllist [list]  ;# list of templates' names
  variable tplcont [list]  ;# list of content of templates
  variable tplpos  [list]  ;# list of position of cursor for templates
  variable tplpla  [list]  ;# list of "where to place" of templates
  variable tplid   [list]  ;# list of IDs of templates (in treeview)
  variable tplkeys [list]  ;# list of keys of templates
  variable tplkey {}       ;# current template's keys
  variable tpl {}          ;# current template's name
  variable place 1         ;# current template's "where to place"
  variable ilast -1        ;# last selection in the list of templates
}

# ________________________ Ini _________________________ #

proc unit_tpl::ReadIni {} {
  # Gets templates' data from al(TPL,list) saved in alited.ini.

  namespace upvar ::alited al al
  foreach tv {tpllist tplcont tplkeys tplpos tplpla} {
    variable $tv
    set $tv [list]
  }
  foreach lst $al(TPL,list) {
    if {![catch {lassign $lst tpl key cont pos pla}]} {
      set cont [string map [list $::alited::EOL \n] $cont]
      if {$tpl ne {} && $cont ne {} && $pos ne {}} {
        if {![string is double -strict $pos]} {set pos 1.0}
        lappend tpllist $tpl
        lappend tplcont $cont
        lappend tplkeys $key
        lappend tplpos $pos
        lappend tplpla $pla
      }
    }
  }
}
#_______________________

proc unit_tpl::SaveIni {} {
  # Puts templates' data to al(TPL,list) to save in alited.ini.

  variable ilast
  RegisterKeys
  set ilast [Selected index no]
}

# ________________________ Keys _________________________ #

proc unit_tpl::RegisterKeys {} {
  # Registers key bindings of templates, to save them to alited.ini afterwards.

  namespace upvar ::alited al al
  variable tpllist
  variable tplcont
  variable tplkeys
  variable tplpos
  variable tplpla
  variable ilast
  alited::keys::Delete template
  set al(TPL,list) [list]
  foreach tpl $tpllist key $tplkeys cont $tplcont pos $tplpos pla $tplpla {
    set cont [string map [list \n $::alited::EOL] $cont]
    lappend al(TPL,list) [list $tpl $key $cont $pos $pla]
    alited::keys::Add template $tpl $key [list $cont $pos $pla]
  }
}
#_______________________

proc unit_tpl::GetKeyList {} {
  # Creates a key list for "Keys" combobox.

  namespace upvar ::alited obDl2 obDl2
  RegisterKeys
  set keys [linsert [alited::keys::VacantList] 0 ""]
  [$obDl2 CbxKey] configure -values $keys
}

# ________________________ List _________________________ #

proc unit_tpl::Focus {isel} {
  # Sets the focus on the template list's item.
  #   isel - index of item

  namespace upvar ::alited obDl2 obDl2
  set tree [$obDl2 TreeTpl]
  $tree selection set $isel
  $tree see $isel
  $tree focus $isel
}
#_______________________

proc unit_tpl::UpdateTree {} {
  # Updates the template list.

  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  variable tplkeys
  variable tplid
  variable ilast
  set tree [$obDl2 TreeTpl]
  $tree delete [$tree children {}]
  set tplid [list]
  set item0 {}
  foreach tpl $tpllist tplkey $tplkeys {
    set item [$tree insert {} end -values [list $tpl $tplkey]]
    if {$item0 eq {}} {set item0 $item}
    lappend tplid $item
  }
  if {$item0 ne {} && $ilast<0} {Focus $item0}
  ClearCbx
}
#_______________________

proc unit_tpl::Select {{item ""}} {
  # Selects an item of the template list.
  #   item - index (ID) of template list

  variable tpllist
  variable tplkey
  variable tplkeys
  variable tplcont
  variable tplid
  variable tplpla
  variable tpl
  variable place
  namespace upvar ::alited obDl2 obDl2
  if {$item eq {}} {set item [Selected item no]}
  if {$item ne {}} {
    if {[string is digit $item]} {  ;# the item is an index
      set item [lindex $tplid $item]
    }
    set tree [$obDl2 TreeTpl]
    set isel [$tree index $item]
    set tpl [lindex $tpllist $isel]
    set tplkey [lindex $tplkeys $isel]
    set place [lindex $tplpla $isel]
    set wtxt [$obDl2 TexTpl]
    $wtxt delete 1.0 end
    $wtxt insert end [lindex $tplcont $isel]
    if {[$tree selection] ne $item} {
      $tree selection set $item
    }
    $tree see $item
    $tree focus $item
  }
}
#_______________________

proc unit_tpl::Selected {what {domsg yes}} {
  # Gets ID or index of currently selected item of the template list.
  #   what - if "index", gets a current item's index
  #   domsg - if yes, shows a message about the selection

  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  set tree [$obDl2 TreeTpl]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq {} && $domsg} {
    alited::Message2 $al(MC,tplsel) 4
  }
  if {$isel ne {} && $what eq {index}} {
    set isel [$tree index $isel]
  }
  return $isel
}

# ________________________ Text of template _________________________ #

proc unit_tpl::Pos {{pos ""}} {
  # Returns a cursor position in the template's text.
  #   pos - if not "", it's a position to be returned by default

  namespace upvar ::alited obDl2 obDl2
  set wtxt [$obDl2 TexTpl]
  if {$wtxt eq [focus] || $pos eq {}} {
    return [$wtxt index insert]
  }
  return $pos
}
#_______________________

proc unit_tpl::Text {} {
  # Returns the contents of the template's text.

  namespace upvar ::alited obDl2 obDl2
  return [[$obDl2 TexTpl] get 1.0 {end -1 char}]
}
#_______________________

proc unit_tpl::InText {wtxt} {
  # Goes into the template's text and sets the cursor on it.
  #   wtxt - text's path

  variable tplpos
  namespace upvar ::alited obDl2 obDl2
  if {[set isel [Selected index no]] ne {}} {
    set pos [lindex $tplpos $isel]
    ::tk::TextSetCursor $wtxt $pos
  }
}

# ________________________ GUI Handlers _________________________ #

proc unit_tpl::Ok {args} {
  # Handles "OK" button.

  variable win
  variable tplpos
  variable tplcont
  variable tplpla
  namespace upvar ::alited al al obDl2 obDl2
  if {[set isel [Selected index]] eq {}} {
    focus [$obDl2 TreeTpl]
    return
  }
  set tex [lindex $tplcont $isel]
  set pos [lindex $tplpos $isel]
  set pla [lindex $tplpla $isel]
  SaveIni
  $obDl2 res $win [list $tex $pos $pla]
}
#_______________________

proc unit_tpl::Cancel {args} {
  # Handles "Cancel" button.

  variable win
  namespace upvar ::alited obDl2 obDl2
  SaveIni
  $obDl2 res $win 0
}
#_______________________

proc unit_tpl::Help {args} {
  # Handles "Help" button.

  variable win
  alited::Help $win
}

## ________________________ GUI cont. _________________________ ##

proc unit_tpl::ClearCbx {} {
  # Helper to clear the combobox's selection.

  namespace upvar ::alited obDl2 obDl2
  [$obDl2 CbxKey] selection clear
}
#_______________________

proc unit_tpl::Add {} {
  # Handles "Add template" button.

  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  variable tpl
  variable tplcont
  variable tplpos
  variable tplpla
  variable place
  variable tplkeys
  variable tplkey
  variable tplid
  set tpl [string trim $tpl]
  set txt [Text]
  set tree [$obDl2 TreeTpl]
  if {$tplkey ne {}} {
    set isel2 [lsearch -exact $tplkeys $tplkey]
  } else {
    set isel2 -1
  }
  if {$tpl ne {} && $txt ne {} && ( \
  [set isel1 [lsearch -exact $tpllist $tpl]]>-1 || $isel2>-1 ||
  [set isel3 [lsearch -exact $tplcont $txt]]>-1 )} {
    if {$isel1>-1} {
      focus [$obDl2 EntTpl]
    } elseif {$isel2>-1} {
      focus [$obDl2 CbxKey]
    } else {
      set wtxt [$obDl2 TexTpl]
      focus $wtxt
      set pos [lindex $tplpos $isel3]
      ::tk::TextSetCursor $wtxt $pos
    }
    alited::Message2 $al(MC,tplexists) 4
    return
  } elseif {$tpl eq {}} {
    focus [$obDl2 EntTpl]
    alited::Message2 $al(MC,tplent1) 4
    return
  } elseif {[string trim $txt] eq {}} {
    focus [$obDl2 TexTpl]
    alited::Message2 $al(MC,tplent2) 4
    return
  }
  lappend tpllist $tpl
  lappend tplcont $txt
  lappend tplpos [Pos]
  lappend tplpla $place
  set msg [string map [list %n [llength $tpllist]] $al(MC,tplnew)]
  set item [$tree insert {} end -values [list $tpl $tplkey]]
  lappend tplkeys $tplkey
  UpdateTree
  set item [lindex [$tree children {}] end]
  lappend tplid $item
  Select [expr {[llength $tplid]-1}]
  alited::Message2 $msg
}
#_______________________

proc unit_tpl::Change {} {
  # Handles "Change template" button.

  namespace upvar ::alited obDl2 obDl2
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable place
  variable tplkeys
  variable tplkey
  variable tpl
  namespace upvar ::alited al al
  if {[set isel [Selected index]] eq {}} return
  set tpllist [lreplace $tpllist $isel $isel $tpl]
  set tplcont [lreplace $tplcont $isel $isel [Text]]
  set tplpos [lreplace $tplpos $isel $isel [Pos [lindex $tplpos $isel]]]
  set tplpla [lreplace $tplpla $isel $isel $place]
  set tplkeys [lreplace $tplkeys $isel $isel $tplkey]
  UpdateTree
  Select $isel
  set msg [string map [list %n [incr isel]] $al(MC,tplupd)]
  alited::Message2 $msg
}
#_______________________

proc unit_tpl::Delete {} {
  # Handles "Delete template" button.

  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable tplkeys
  variable tplid
  variable win
  if {[set isel [Selected index]] eq {}} return
  set nsel [expr {$isel+1}]
  set msg [string map [list %n $nsel] $al(MC,tpldelq)]
  set geo "-geometry root=$win"
  if {![alited::msg yesno warn $msg NO {*}$geo]} {
    return
  }
  foreach tl {tpllist tplcont tplpos tplpla tplid tplkeys} {
    set $tl [lreplace [set $tl] $isel $isel]
  }
  set llen [expr {[llength $tpllist]-1}]
  if {$isel>$llen} {set isel $llen}
  UpdateTree
  if {$llen>=0} {Select $isel}
  set msg [string map [list %n $nsel] $al(MC,tplrem)]
  alited::Message2 $msg
}

# ________________________ Main _________________________ #

proc unit_tpl::_create {} {
  # Creates "Templates" dialogue.

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable tpllist
  variable ilast
  variable tplkey
  $obDl2 makeWindow $win $al(MC,tpl)
  $obDl2 paveWindow $win {
    {fraTreeTpl - - 10 10 {-st nswe -pady 8} {}}
    {.fra - - - - {pack -side right -fill both} {}}
    {.fra.buTAd - - - - {pack -side top -anchor n} {-takefocus 0 -com ::alited::unit_tpl::Add -tip "Add a template" -image alimg_add-big}}
    {.fra.buTChg - - - - {pack -side top} {-takefocus 0 -com ::alited::unit_tpl::Change -tip "Change a template" -image alimg_change-big}}
    {.fra.buTDel - - - - {pack -side top} {-takefocus 0 -com ::alited::unit_tpl::Delete -tip "Delete a template" -image alimg_delete-big}}
    {.TreeTpl - - - - {pack -side left -expand 1 -fill both} {-h 7 -show headings -columns {C1 C2} -displaycolumns {C1 C2} -columnoptions "C2 {-stretch 0}"}}
    {.sbvTpls fraTreeTpl.TreeTpl L - - {pack -side left -fill both}}
    {fra1 fraTreeTpl T 10 10 {-st nsew}}
    {.labTpl - - 1 1 {-st we} {-anchor center -t "Current template:"}}
    {.EntTpl .labTpl L 1 8 {-st we} {-tvar ::alited::unit_tpl::tpl -w 50 -tip {$alited::al(MC,tplent1)}}}
    {.CbxKey .EntTpl L 1 1 {-st we} {-tvar ::alited::unit_tpl::tplkey -postcommand ::alited::unit_tpl::GetKeyList -state readonly -h 16 -w 16 -tip "Choose a hot key combination\nfor the template insertion."}}
    {fra1.fratex fra1.labTpl T 10 10 {-st nsew} {}}
    {.TexTpl - - - - {pack -side left -expand 1 -fill both} {-h 10 -w 80 -tip {$alited::al(MC,tplent2)}}}
    {.sbvTpl .TexTpl L - - {pack -side left -fill both} {}}
    {fra2 fra1 T 1 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack -side left} {-t "Place after:"}}
    {.radA - - - - {pack -side left -padx 8}  {-t "line" -var ::alited::unit_tpl::place -value 1 -tip "Inserts a template\nbelow a current line"}}
    {.radB - - - - {pack -side left -padx 8}  {-t "unit" -var ::alited::unit_tpl::place -value 2 -tip "Inserts a template\nbelow a current unit"}}
    {.radC - - - - {pack -side left -padx 8}  {-t "cursor" -var ::alited::unit_tpl::place -value 3 -tip "Inserts a template at the cursor\n(good for one-liners)"}}
    {.radD - - - - {pack -side left -padx 8}  {-t "file's beginning" -var ::alited::unit_tpl::place -value 4 -tip "Inserts a template after 1st line of a file\n(License, Introduction etc.)"}}
    {LabMess fra2 T 1 10 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {fra3 labMess T 1 10 {-st nsew}}
    {.butHelp - - - - {pack -side left} {-t "$alited::al(MC,help)" -command ::alited::unit_tpl::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.butOK - - - - {pack -side left -padx 2} {-t "$alited::al(MC,select)" -command ::alited::unit_tpl::Ok}}
    {.butCancel - - - - {pack -side left} {-t Cancel -command ::alited::unit_tpl::Cancel}}
  }
  set tree [$obDl2 TreeTpl]
  $tree heading C1 -text [msgcat::mc Template]
  $tree heading C2 -text [msgcat::mc {Hot keys}]
  UpdateTree
  Select
  set wtxt [$obDl2 TexTpl]
  bind $tree <<TreeviewSelect>> ::alited::unit_tpl::Select
  bind $tree <Delete> ::alited::unit_tpl::Delete
  bind $tree <Double-Button-1> ::alited::unit_tpl::Ok
  bind $tree <Return> ::alited::unit_tpl::Ok
  bind $wtxt <FocusIn> "::alited::unit_tpl::InText $wtxt"
  bind [$obDl2 CbxKey] <FocusOut> ::alited::unit_tpl::ClearCbx
  if {[llength $tpllist]} {set foc $tree} {set foc [$obDl2 EntTpl]}
  if {$ilast>-1} {
    Select $ilast
    after idle "alited::unit_tpl::Select $ilast"  ;# just to highlight
  }
  set res [$obDl2 showModal $win -resizable {0 0} \
    -onclose ::alited::unit_tpl::Cancel -focus $foc]
  if {[llength $res] < 2} {set res {}}
  return $res
}
#_______________________

proc unit_tpl::_run {} {
  # Runs "Templates" dialogue.

  variable win
  set wtxt [alited::main::CurrentWTXT]
  alited::keys::UnBindKeys $wtxt template
  ReadIni
  set res [_create]
  destroy $win
  alited::keys::BindKeys $wtxt template
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
