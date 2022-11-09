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
  variable dosel yes       ;# if yes, enables "Select" action
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
  set ilast [Selected index no]
  RegisterKeys
  alited::ini::SaveIni
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

  namespace upvar ::alited obDl3 obDl3
  RegisterKeys
  set keys [linsert [alited::keys::VacantList] 0 ""]
  [$obDl3 CbxKey] configure -values $keys
}

# ________________________ List _________________________ #

proc unit_tpl::Focus {isel} {
  # Sets the focus on the template list's item.
  #   isel - index of item

  namespace upvar ::alited obDl3 obDl3
  set tree [$obDl3 TreeTpl]
  $tree selection set $isel
  $tree see $isel
  $tree focus $isel
}
#_______________________

proc unit_tpl::UpdateTree {{saveini yes}} {
  # Updates the template list.
  #   saveini - save templates in ini-file

  namespace upvar ::alited al al obDl3 obDl3
  variable tpllist
  variable tplkeys
  variable tplid
  variable ilast
  set tree [$obDl3 TreeTpl]
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
  if {$saveini} SaveIni
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
  namespace upvar ::alited obDl3 obDl3
  if {$item eq {}} {set item [Selected item no]}
  if {$item ne {}} {
    if {[string is digit $item]} {  ;# the item is an index
      set item [lindex $tplid $item]
    }
    set tree [$obDl3 TreeTpl]
    set isel [$tree index $item]
    set tpl [lindex $tpllist $isel]
    set tplkey [lindex $tplkeys $isel]
    set place [lindex $tplpla $isel]
    set wtxt [$obDl3 TexTpl]
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

  namespace upvar ::alited al al obDl3 obDl3
  variable tpllist
  set tree [$obDl3 TreeTpl]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq {} && $domsg} {
    alited::Message3 $al(MC,tplsel) 4
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

  namespace upvar ::alited obDl3 obDl3
  set wtxt [$obDl3 TexTpl]
  if {$wtxt eq [focus] || $pos eq {}} {
    return [$wtxt index insert]
  }
  return $pos
}
#_______________________

proc unit_tpl::Text {} {
  # Returns the contents of the template's text.

  namespace upvar ::alited obDl3 obDl3
  return [[$obDl3 TexTpl] get 1.0 {end -1 char}]
}
#_______________________

proc unit_tpl::InText {wtxt} {
  # Goes into the template's text and sets the cursor on it.
  #   wtxt - text's path

  variable tplpos
  namespace upvar ::alited obDl3 obDl3
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
  variable dosel
  namespace upvar ::alited al al obDl3 obDl3
  alited::CloseDlg
  if {!$dosel || [set isel [Selected index]] eq {}} {
    focus [$obDl3 TreeTpl]
    return
  }
  set tex [lindex $tplcont $isel]
  set pos [lindex $tplpos $isel]
  set pla [lindex $tplpla $isel]
  SaveIni
  $obDl3 res $win [list $tex $pos $pla]
}
#_______________________

proc unit_tpl::Cancel {args} {
  # Handles "Cancel" button.

  variable win
  namespace upvar ::alited obDl3 obDl3
  alited::CloseDlg
  SaveIni
  $obDl3 res $win 0
}
#_______________________

proc unit_tpl::Help {args} {
  # Handles "Help" button.

  variable win
  alited::Help $win
}
#_______________________

proc unit_tpl::HelpMe {args} {
  # 'Help' for start.

  variable win
  alited::HelpMe $win
}

## ________________________ GUI cont. _________________________ ##

proc unit_tpl::ClearCbx {} {
  # Helper to clear the combobox's selection.

  namespace upvar ::alited obDl3 obDl3
  [$obDl3 CbxKey] selection clear
}
#_______________________

proc unit_tpl::Add {{inpos ""}} {
  # Handles "Add template" button.
  #   inpos - cursor position in template text
  # Returns 1, if the template was added, else returns 0.

  namespace upvar ::alited al al obDl3 obDl3
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
  set tree [$obDl3 TreeTpl]
  if {$tplkey ne {}} {
    set isel2 [lsearch -exact $tplkeys $tplkey]
  } else {
    set isel2 -1
  }
  if {$tpl ne {} && $txt ne {} && ( \
  [set isel1 [lsearch -exact $tpllist $tpl]]>-1 || $isel2>-1 ||
  [set isel3 [lsearch -exact $tplcont $txt]]>-1 )} {
    if {$isel1>-1} {
      focus [$obDl3 EntTpl]
    } elseif {$isel2>-1} {
      focus [$obDl3 CbxKey]
    } else {
      set wtxt [$obDl3 TexTpl]
      focus $wtxt
      set pos [lindex $tplpos $isel3]
      ::tk::TextSetCursor $wtxt $pos
    }
    alited::Message3 $al(MC,tplexists) 4
    return 0
  } elseif {$tpl eq {}} {
    focus [$obDl3 EntTpl]
    alited::Message3 $al(MC,tplent1) 4
    return 0
  } elseif {[string trim $txt] eq {}} {
    focus [$obDl3 TexTpl]
    alited::Message3 $al(MC,tplent2) 4
    return 0
  }
  if {$inpos eq {}} {set inpos [Pos]}
  lappend tpllist $tpl
  lappend tplcont $txt
  lappend tplpos $inpos
  lappend tplpla $place
  set msg [string map [list %n [llength $tpllist]] $al(MC,tplnew)]
  set item [$tree insert {} end -values [list $tpl $tplkey]]
  lappend tplkeys $tplkey
  UpdateTree
  set item [lindex [$tree children {}] end]
  lappend tplid $item
  Select [expr {[llength $tplid]-1}]
  alited::Message3 $msg 3
  return 1
}
#_______________________

proc unit_tpl::Change {} {
  # Handles "Change template" button.

  namespace upvar ::alited obDl3 obDl3
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
  alited::Message3 $msg 3
}
#_______________________

proc unit_tpl::Delete {} {
  # Handles "Delete template" button.

  namespace upvar ::alited al al obDl3 obDl3
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
  if {![alited::msg yesno warn $msg NO -centerme $win]} {
    return
  }
  foreach tl {tpllist tplcont tplpos tplpla tplid tplkeys} {
    set $tl [lreplace [set $tl] $isel $isel]
  }
  set llen [expr {[llength $tpllist]-1}]
  if {$isel>$llen} {set isel $llen}
  UpdateTree
  if {$llen>=0} {after idle "alited::unit_tpl::Select $isel"}
  set msg [string map [list %n $nsel] $al(MC,tplrem)]
  alited::Message3 $msg 3
}
#_______________________

proc unit_tpl::Import {} {
  # Handles "Import templates" button.

  namespace upvar ::alited al al obDl3 obDl3 DATAUSERINI DATAUSERINI
  variable tpl
  variable tplkey
  variable place
  variable win
  set al(filename) alited.ini
  set fname [$obDl3 chooser tk_getOpenFile alited::al(filename) \
    -initialdir $DATAUSERINI -parent $win]
  if {$fname eq {}} return
  set imported 0
  set wtxt [$obDl3 TexTpl]
  set filecont [::apave::readTextFile $fname]
  foreach line [split $filecont \n] {
    if {[string match tpl=* $line]} {
      set line [string range $line 4 end]
      if {![catch {lassign $line tpl tplkey cont pos place}]} {
        set cont [string map [list $::alited::EOL \n] $cont]
        if {$tpl ne {} && $cont ne {} && $pos ne {}} {
          if {![string is double -strict $pos]} {set pos 1.0}
          $wtxt delete 1.0 end
          $wtxt insert end $cont
          incr imported [Add $pos]
        }
      }
    }
  }
  alited::Message3 [string map "%n $imported" [msgcat::mc "Number of imported templates: %n"]] 3
}

# ________________________ Main _________________________ #

proc unit_tpl::_create {{geom ""}} {
  # Creates "Templates" dialogue.
  #   geom - "-geometry" option for showModal

  namespace upvar ::alited al al obDl3 obDl3
  variable win
  variable tpllist
  variable ilast
  variable tplkey
  variable dosel
  set tipson [baltip::cget -on]
  baltip::configure -on $al(TIPS,Templates)
  if {$dosel} {
    set ::alited::unit_tpl::PACKOK {}
    set ::alited::unit_tpl::BUTEXIT Cancel
  } else {
    set ::alited::unit_tpl::PACKOK forget
    set ::alited::unit_tpl::BUTEXIT Close
  }
  $obDl3 makeWindow $win $al(MC,tpllist)
  $obDl3 paveWindow $win {
    {fraTreeTpl - - 10 10 {-st nswe -pady 8} {}}
    {.fra - - - - {pack -side right -fill both} {}}
    {.fra.btTAd - - - - {pack -side top -anchor n} {-com ::alited::unit_tpl::Add -tip "Add a template" -image alimg_add-big}}
    {.fra.btTChg - - - - {pack -side top} {-com ::alited::unit_tpl::Change -tip "Change a template" -image alimg_change-big}}
    {.fra.btTDel - - - - {pack -side top} {-com ::alited::unit_tpl::Delete -tip "Delete a template" -image alimg_delete-big}}
    {.fra.v_ - - - - {pack -side top -expand 1 -fill x -pady 2} {}}
    {.fra.btTImp - - - - {pack -side top} {-com ::alited::unit_tpl::Import -tip "Import templates\nfrom external alited.ini" -image alimg_plus-big}}
    {.TreeTpl - - - - {pack -side left -expand 1 -fill both} {-h 12 -show headings -columns {C1 C2} -displaycolumns {C1 C2} -columnoptions "C2 {-stretch 0}"}}
    {.sbvTpls + L - - {pack -side left -fill both}}
    {fra1 fraTreeTpl T 10 10 {-st nsew}}
    {.h_ - - 1 1 {-st we} {-h 20}}
    {.labTpl .h_ T 1 1 {-st we} {-anchor center -t "Current template:"}}
    {.EntTpl .labTpl L 1 8 {-st we} {-tvar ::alited::unit_tpl::tpl -w 50 -tip {-BALTIP {$alited::al(MC,tplent1)} -MAXEXP 1}}}
    {.CbxKey + L 1 1 {-st we} {-tvar ::alited::unit_tpl::tplkey -postcommand ::alited::unit_tpl::GetKeyList -state readonly -h 16 -w 16 -tip {-BALTIP {$alited::al(MC,tplent3)} -MAXEXP 1}}}
    {fra1.fratex fra1.labTpl T 10 10 {-st nsew} {}}
    {.TexTpl - - - - {pack -side left -expand 1 -fill both} {-h 10 -w 80 -tip  {-BALTIP {$alited::al(MC,tplent2)} -MAXEXP 1}}}
    {.sbvTpl + L - - {pack -side left -fill both} {}}
    {fra2 fra1 T 1 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack -side left} {-t "Place after:"}}
    {.radA - - - - {pack -side left -padx 8}  {-t "line" -var ::alited::unit_tpl::place -value 1 -tip {-BALTIP {$al(MC,tplaft1)} -UNDER 4}}}
    {.radB - - - - {pack -side left -padx 8}  {-t "unit" -var ::alited::unit_tpl::place -value 2 -tip {-BALTIP {$al(MC,tplaft2)} -UNDER 4}}}
    {.radC - - - - {pack -side left -padx 8}  {-t "cursor" -var ::alited::unit_tpl::place -value 3 -tip {-BALTIP {$al(MC,tplaft3)} -UNDER 4}}}
    {.radD - - - - {pack -side left -padx 8}  {-t "file's beginning" -var ::alited::unit_tpl::place -value 4 -tip {-BALTIP {$al(MC,tplaft4)} -UNDER 4}}}
    {LabMess fra2 T 1 10 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {fra3 + T 1 10 {-st nsew}}
    {.ButHelp - - - - {pack -side left} {-t {$alited::al(MC,help)} -tip F1 -command ::alited::unit_tpl::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.butOK - - - - {pack $::alited::unit_tpl::PACKOK -side left -padx 2} {-t "$alited::al(MC,select)" -command ::alited::unit_tpl::Ok}}
    {.butCancel - - - - {pack -side left} {-t $::alited::unit_tpl::BUTEXIT -command ::alited::unit_tpl::Cancel}}
  }
  set tree [$obDl3 TreeTpl]
  $tree heading C1 -text [msgcat::mc Template]
  $tree heading C2 -text [msgcat::mc {Hot keys}]
  UpdateTree no
  Select
  set wtxt [$obDl3 TexTpl]
  bind $tree <<TreeviewSelect>> ::alited::unit_tpl::Select
  bind $tree <Delete> ::alited::unit_tpl::Delete
  bind $tree <Double-Button-1> ::alited::unit_tpl::Ok
  bind $tree <Return> ::alited::unit_tpl::Ok
  bind $wtxt <FocusIn> "::alited::unit_tpl::InText $wtxt"
  bind [$obDl3 CbxKey] <FocusOut> ::alited::unit_tpl::ClearCbx
  bind $win <F1> "[$obDl3 ButHelp] invoke"
  if {[llength $tpllist]} {set foc $tree} {set foc [$obDl3 EntTpl]}
  if {$ilast>-1} {
    Select $ilast
    after idle "alited::unit_tpl::Select $ilast"  ;# just to highlight
  }
  after 500 ::alited::unit_tpl::HelpMe ;# show an introduction after a short pause
  set res [$obDl3 showModal $win -onclose ::alited::unit_tpl::Cancel -focus $foc {*}$geom]
  baltip::configure {*}$tipson
  if {[llength $res] < 2} {set res {}}
  return $res
}
#_______________________

proc unit_tpl::_run {{doselect yes} {geom ""}} {
  # Runs "Templates" dialogue.
  #   doselect - if yes, enables "Select" action
  #   geom - "-geometry" option for showModal

  variable win
  variable dosel
  if {[winfo exists $win]} {return {}}
  set dosel $doselect
  set wtxt [alited::main::CurrentWTXT]
  alited::keys::UnBindKeys $wtxt template
  ReadIni
  set res [_create $geom]
  destroy $win
  alited::keys::BindKeys $wtxt template
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
