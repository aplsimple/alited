###########################################################
# Name:    unit_tpl.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/01/2021
# Brief:   Handles templates of code.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval ::alited::unit_tpl {

  # apave object of Templates
  variable obTpl pavedTemplates

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
      set cont [::alited::ProcEOL $cont in]
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

  set ::alited::unit::ilast [Selected index no]
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
  alited::keys::Delete template
  set al(TPL,list) [list]
  foreach tpl $tpllist key $tplkeys cont $tplcont pos $tplpos pla $tplpla {
    set cont [::alited::ProcEOL $cont out]
    lappend al(TPL,list) [list $tpl $key $cont $pos $pla]
    alited::keys::Add template $tpl $key [list $cont $pos $pla]
  }
}
#_______________________

proc unit_tpl::GetKeyList {} {
  # Creates a key list for "Keys" combobox.

  variable obTpl
  RegisterKeys
  set keys [linsert [alited::keys::VacantList] 0 ""]
  [$obTpl CbxKey] configure -values $keys
}

# ________________________ List _________________________ #

proc unit_tpl::Focus {isel} {
  # Sets the focus on the template list's item.
  #   isel - index of item

  variable obTpl
  set tree [$obTpl TreeTpl]
  $tree selection set $isel
  $tree see $isel
  $tree focus $isel
}
#_______________________

proc unit_tpl::UpdateTree {{saveini yes}} {
  # Updates the template list.
  #   saveini - save templates in ini-file

  variable obTpl
  variable tpllist
  variable tplkeys
  variable tplid
  set tree [$obTpl TreeTpl]
  $tree delete [$tree children {}]
  set tplid [list]
  set item0 {}
  foreach tpl $tpllist tplkey $tplkeys {
    set item [$tree insert {} end -values [list $tpl $tplkey]]
    if {$item0 eq {}} {set item0 $item}
    lappend tplid $item
  }
  if {$item0 ne {} && $::alited::unit::ilast<0} {Focus $item0}
  ClearCbx [$obTpl CbxKey]
  if {$saveini} SaveIni
}
#_______________________

proc unit_tpl::Select {{item ""}} {
  # Selects an item of the template list.
  #   item - index (ID) of template list

  variable obTpl
  variable tpllist
  variable tplkey
  variable tplkeys
  variable tplcont
  variable tplid
  variable tplpla
  variable tpl
  variable place
  if {$item eq {}} {set item [Selected item no]}
  if {$item ne {}} {
    if {[string is digit $item]} {  ;# the item is an index
      set item [lindex $tplid $item]
    }
    catch {
      set tree [$obTpl TreeTpl]
      set isel [$tree index $item]
      set tpl [lindex $tpllist $isel]
      set tplkey [lindex $tplkeys $isel]
      set place [lindex $tplpla $isel]
      set cont [lindex $tplcont $isel]
      set wtxt [$obTpl TexTpl]
      ::hl_tcl::iscurline $wtxt no
      $wtxt delete 1.0 end
      $wtxt insert end $cont
      InText $wtxt
      if {[$tree selection] ne $item} {
        $tree selection set $item
      }
      focus $tree
      $tree see $item
      $tree focus $item
    }
  }
}
#_______________________

proc unit_tpl::Selected {what {domsg yes}} {
  # Gets ID or index of currently selected item of the template list.
  #   what - if "index", gets a current item's index
  #   domsg - if yes, shows a message about the selection

  variable obTpl
  variable tpllist
  set tree [$obTpl TreeTpl]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq {} && $domsg} {
    Message $::alited::al(MC,tplsel) 4
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

  variable obTpl
  set wtxt [$obTpl TexTpl]
  if {$wtxt eq [focus] || $pos eq {}} {
    return [$wtxt index insert]
  }
  return $pos
}
#_______________________

proc unit_tpl::Text {} {
  # Returns the contents of the template's text.

  variable obTpl
  return [[$obTpl TexTpl] get 1.0 {end -1 char}]
}
#_______________________

proc unit_tpl::InText {wtxt} {
  # Goes into the template's text and sets the cursor on it.
  #   wtxt - text's path

  variable tplpos
  if {[set isel [Selected index no]] ne {}} {
    set pos [lindex $tplpos $isel]
    after idle " \
      ::hl_tcl::iscurline $wtxt yes ; \
      ::tk::TextSetCursor $wtxt $pos ; \
      event generate $wtxt <Enter> ;# to force highlighting
      "
  }
}
#_______________________

proc unit_tpl::SyntaxText {wtxt} {
  # Prepares syntax highlighting of template's text
  #   wtxt - the text's path

  alited::SyntaxHighlight tcl $wtxt [alited::SyntaxColors]
}

# ________________________ GUI handlers _________________________ #

proc unit_tpl::Ok {args} {
  # Handles "OK" button.

  variable obTpl
  variable win
  variable tplpos
  variable tplcont
  variable tplpla
  variable dosel
  if {!$dosel || [set isel [Selected index]] eq {}} {
    focus [$obTpl TreeTpl]
    return
  }
  set tex [lindex $tplcont $isel]
  set pos [lindex $tplpos $isel]
  set pla [lindex $tplpla $isel]
  SaveIni
  $obTpl res $win [list $tex $pos $pla]
}
#_______________________

proc unit_tpl::Cancel {args} {
  # Handles "Cancel" button.

  variable obTpl
  variable win
  SaveIni
  $obTpl res $win 0
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

proc unit_tpl::ClearCbx {cbx} {
  # Helper to clear the combobox's selection.

  $cbx selection clear
}
#_______________________

proc unit_tpl::Add {{inpos ""}} {
  # Handles "Add template" button.
  #   inpos - cursor position in template text
  # Returns 1, if the template was added, else returns 0.

  namespace upvar ::alited al al
  variable obTpl
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
  set tree [$obTpl TreeTpl]
  if {$tplkey ne {}} {
    set isel2 [lsearch -exact $tplkeys $tplkey]
  } else {
    set isel2 -1
  }
  if {$tpl ne {} && $txt ne {} && ( \
  [set isel1 [lsearch -exact $tpllist $tpl]]>-1 || $isel2>-1 ||
  [set isel3 [lsearch -exact $tplcont $txt]]>-1 )} {
    if {$isel1>-1} {
      focus [$obTpl EntTpl]
    } elseif {$isel2>-1} {
      focus [$obTpl CbxKey]
    } else {
      set wtxt [$obTpl TexTpl]
      focus $wtxt
      set pos [lindex $tplpos $isel3]
      ::tk::TextSetCursor $wtxt $pos
    }
    Message $al(MC,tplexists) 4
    return 0
  } elseif {$tpl eq {}} {
    focus [$obTpl EntTpl]
    Message $al(MC,tplent1) 4
    return 0
  } elseif {[string trim $txt] eq {}} {
    focus [$obTpl TexTpl]
    Message $al(MC,tplent2) 4
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
  set isel [expr {[llength $tplid]-1}]
  after idle "::alited::unit_tpl::Select $isel"
  Message $msg 3
  return 1
}
#_______________________

proc unit_tpl::Change {} {
  # Handles "Change template" button.

  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable place
  variable tplkeys
  variable tplkey
  variable tpl
  if {[set isel [Selected index]] eq {}} return
  set tpllist [lreplace $tpllist $isel $isel $tpl]
  set tplcont [lreplace $tplcont $isel $isel [Text]]
  set tplpos [lreplace $tplpos $isel $isel [Pos [lindex $tplpos $isel]]]
  set tplpla [lreplace $tplpla $isel $isel $place]
  set tplkeys [lreplace $tplkeys $isel $isel $tplkey]
  UpdateTree
  after idle "::alited::unit_tpl::Select $isel"
  set msg [string map [list %n [incr isel]] $::alited::al(MC,tplupd)]
  Message $msg 3
}
#_______________________

proc unit_tpl::Delete {} {
  # Handles "Delete template" button.

  namespace upvar ::alited al al
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable tplkeys
  variable tplid
  variable win
  variable dosel
  if {!$dosel || [set isel [Selected index]] eq {}} return
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
  Message $msg 3
}
#_______________________

proc unit_tpl::Import {} {
  # Handles "Import templates" button.

  namespace upvar ::alited al al DATAUSERINI DATAUSERINI
  variable obTpl
  variable tpl
  variable tplkey
  variable place
  variable win
  set al(TMPfname) alited.ini
  set fname [$obTpl chooser tk_getOpenFile ::alited::al(TMPfname) \
    -initialdir $DATAUSERINI -parent $win]
  unset al(TMPfname)
  if {$fname eq {}} return
  set imported 0
  set wtxt [$obTpl TexTpl]
  foreach line [textsplit [readTextFile $fname]] {
    if {[string match tpl=* $line]} {
      set line [string range $line 4 end]
      if {![catch {lassign $line tpl tplkey cont pos place}]} {
        set cont [::alited::ProcEOL $cont in]
        if {$tpl ne {} && $cont ne {} && $pos ne {}} {
          if {![string is double -strict $pos]} {set pos 1.0}
          $wtxt delete 1.0 end
          $wtxt insert end $cont
          incr imported [Add $pos]
        }
      }
    }
  }
  set msg [string map "%n $imported" [msgcat::mc "Number of imported templates: %n"]]
  Message $msg 3
}
#_______________________

proc unit_tpl::Message {msg {mode 2}} {
  # Displays a message in statusbar of templates dialogue.
  #   msg - message
  #   mode - mode of Message

  variable obTpl
  alited::Message $msg $mode [$obTpl LabMess]
}
#_______________________

proc unit_tpl::ProcMessage {} {
  # Handles clicking on message label.

  variable obTpl
  set msg [baltip cget [$obTpl LabMess] -text]
  Message $msg 3
}

# ________________________ Main _________________________ #

proc unit_tpl::_create {{geom ""}} {
  # Creates "Templates" dialogue.
  #   geom - "-geometry" option for showModal

  namespace upvar ::alited al al tplgeometry tplgeometry
  variable obTpl
  variable win
  variable tpllist
  variable tplkey
  variable dosel
  set tipson [baltip::cget -on]
  baltip::configure -on $al(TIPS,Templates)
  if {$dosel} {
    set forget {}
    set ::alited::unit_tpl::BUTEXIT Cancel
  } else {
    set forget forget
    set ::alited::unit_tpl::BUTEXIT Close
  }
  ::apave::APave create $obTpl $win
  $obTpl makeWindow $win $al(MC,tpl)
  $obTpl paveWindow $win {
    {fraTreeTpl - - 10 10 {-st nswe -rw 3 -pady 8} {}}
    {.fra - - - - {pack -side right -fill both} {}}
    {.fra.btTAd - - - - {pack $forget -side top -anchor n}
      {-com alited::unit_tpl::Add -tip "Add a template" -image alimg_add-big}}
    {.fra.btTChg - - - - {pack $forget -side top}
      {-com alited::unit_tpl::Change -tip "Change a template" -image alimg_change-big}}
    {.fra.btTDel - - - - {pack $forget -side top}
      {-com alited::unit_tpl::Delete -tip "Delete a template" -image alimg_delete-big}}
    {.fra.v_ - - - - {pack -side top -expand 1 -fill x -pady 2} {}}
    {.fra.btTImp - - - - {pack $forget -side top}
      {-com alited::unit_tpl::Import \
      -tip "Import templates\nfrom external alited.ini" -image alimg_plus-big}}
    {.TreeTpl - - - - {pack -side left -expand 1 -fill both}
      {-h 12 -show headings -columns {C1 C2} -displaycolumns {C1 C2}
      -columnoptions "C2 {-stretch 0}" -onevent {
      <<TreeviewSelect>> alited::unit_tpl::Select
      <Delete> alited::unit_tpl::Delete
      <Double-Button-1> alited::unit_tpl::Ok
      <Return> alited::unit_tpl::Ok}}}
    {.sbvTpls + L - - {pack -side left -fill both}}
    {fra1 fraTreeTpl T 10 10 {-st nsew}}
    {.h_ - - 1 1 {-st we} {-h 20}}
    {.labTpl .h_ T 1 1 {-st e} {-anchor center -t "Current template:"}}
    {.EntTpl .labTpl L 1 8 {-st we}
      {-tvar ::alited::unit_tpl::tpl -w 45 -tip {-BALTIP {$al(MC,tplent1)} -MAXEXP 1}}}
    {.CbxKey + L 1 1 {-st w}
      {-tvar ::alited::unit_tpl::tplkey -postcommand alited::unit_tpl::GetKeyList
      -state readonly -h 16 -w 16 -tip {-BALTIP {$al(MC,tplent3)} -MAXEXP 1}
      -onevent {<FocusOut> "alited::unit_tpl::ClearCbx %w"}}}
    {fratex fra1 T 10 10 {-st nsew -rw 1 -cw 1} {}}
    {.TexTpl - - - - {pack -side left -expand 1 -fill both}
    {-h 10 -w 80 -tip {-BALTIP {$al(MC,tplent2)} -MAXEXP 1} -onevent {
    <FocusIn> "alited::unit_tpl::InText %w"}}}
    {.sbvTpl + L - - pack {}}
    {fra2 fratex T 1 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack -side left} {-t "Place after:"}}
    {.radA - - - - {pack -side left -padx 8}
      {-t "line" -var ::alited::unit_tpl::place -value 1
      -tip {-BALTIP {$al(MC,tplaft1)} -UNDER 4}}}
    {.radB - - - - {pack -side left -padx 8}
      {-t "unit" -var ::alited::unit_tpl::place -value 2
      -tip {-BALTIP {$al(MC,tplaft2)} -UNDER 4}}}
    {.radC - - - - {pack -side left -padx 8}
      {-t "cursor" -var ::alited::unit_tpl::place -value 3
      -tip {-BALTIP {$al(MC,tplaft3)} -UNDER 4}}}
    {.radD - - - - {pack -side left -padx 8}
      {-t "file's beginning" -var ::alited::unit_tpl::place -value 4
      -tip {-BALTIP {$al(MC,tplaft4)} -UNDER 4}}}
    {LabMess fra2 T 1 10 {-st nsew -pady 0 -padx 3} {-style TLabelFS
      -onevent {<Button-1> alited::unit_tpl::ProcMessage}}}
    {fra3 + T 1 10 {-st nsew}}
    {.ButHelp - - - - {pack -side left}
      {-t {$al(MC,help)} -tip F1 -com alited::unit_tpl::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.butOK - - - - {pack $forget -side left -padx 2}
      {-t "$al(MC,select)" -com alited::unit_tpl::Ok}}
    {.butCancel - - - - {pack -side left}
      {-t $::alited::unit_tpl::BUTEXIT -com alited::unit_tpl::Cancel}}
  }
  set tree [$obTpl TreeTpl]
  $tree heading C1 -text [msgcat::mc Template]
  $tree heading C2 -text [msgcat::mc {Hot keys}]
  UpdateTree no
  Select
  SyntaxText [$obTpl TexTpl]
  bind $win <F1> "[$obTpl ButHelp] invoke"
  if {[llength $tpllist]} {set foc $tree} {set foc [$obTpl EntTpl]}
  if {[set il $::alited::unit::ilast] > -1} {
    Select $il
    after idle "alited::unit_tpl::Select $il"  ;# just to highlight
  }
  after 500 ::alited::unit_tpl::HelpMe ;# show an introduction after a short pause
  set geo {-resizable 1 -minsize {640 480}}
  if {$geom ne {}} {
    set geo $geom
  } elseif {$tplgeometry ne {}} {
    append geo " -geometry $tplgeometry"
  }
  set res [$obTpl showModal $win -onclose ::alited::unit_tpl::Cancel -focus $foc {*}$geo]
  if {$geom eq {}} {
    set tplgeometry [wm geometry $win]
  }
  baltip::configure {*}$tipson
  catch {destroy $win}
  $obTpl destroy
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
