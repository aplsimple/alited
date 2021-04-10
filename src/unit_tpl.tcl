#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The unit template procedures.
# _______________________________________________________________________ #

namespace eval ::alited::unit_tpl {
  variable tpllist [list]
  variable tplcont [list]
  variable tplpos  [list]
  variable tplpla  [list]
  variable tpl ""
  variable place 1
  variable ilast -1
  variable win $::alited::al(WIN).fraTpl
}

proc ::alited::unit_tpl::Show {} {
  variable win
  variable tpllist
  variable ilast
  namespace upvar ::alited al al obDl2 obDl2
  $obDl2 makeWindow $win $al(MC,tpl)
  $obDl2 paveWindow $win {
    {fralab - - 2 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.lab1 - - 1 10 {-st ew} {-t "$alited::al(MC,tpl1)"}}
    {.lab2 fralab.lab1 T 1 10 {-st ew} {-t "$alited::al(MC,tpl2)"}}
    {fraLbxTpl fralab T 10 10 {-st nswe -pady 8} {}}
    {fraLbxTpl.labTpls - - - - {pack -side top -fill x -anchor nw} {-t "$alited::al(MC,tpl3)"}}
    {fraLbxTpl.fra - - - - {pack -side right -fill both} {}}
    {fraLbxTpl.fra.buTAdd - - - - {pack -side top -anchor n} {-takefocus 0 -com ::alited::unit_tpl::Add -tooltip {$alited::al(MC,tpladd)}}}
    {fraLbxTpl.fra.buTChange - - - - {pack -side top} {-takefocus 0 -com ::alited::unit_tpl::Change -tooltip {$alited::al(MC,tplchg)}}}
    {fraLbxTpl.fra.buTDelete - - - - {pack -side top} {-takefocus 0 -com ::alited::unit_tpl::Delete -tooltip {$alited::al(MC,tpldel)}}}
    {fraLbxTpl.LbxTpl - - - - {pack -side left -expand 1 -fill both} {-h 8 -w 40 -lvar ::alited::unit_tpl::tpllist -selectmode single}}
    {fraLbxTpl.sbvTpls fraLbxTpl.LbxTpl L - - {pack -side left -fill both} {}}
    {fra1 fraLbxTpl T 10 10 {-st nsew}}
    {.labTpl - - 1 1 {-st we} {-anchor center -t "$alited::al(MC,tpl4)"}}
    {.EntTpl fra1.labTpl L 1 9 {-st we} {-tvar ::alited::unit_tpl::tpl -w 50 -tooltip {$alited::al(MC,tplent1)}}}
    {fra1.fratex fra1.labTpl T 10 10 {-st nsew} {}}
    {.TexTpl - - - - {pack -side left -expand 1 -fill both} {-h 10 -w 60 -tooltip {$alited::al(MC,tplent2)}}}
    {.sbvTpl .TexTpl L - - {pack -side left -fill both} {}}
    {fra2 fra1 T 1 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack -side left} {-t {$alited::al(MC,tplloc)}}}
    {.radA - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc1)} -var ::alited::unit_tpl::place -value 1}}
    {.radB - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc2)} -var ::alited::unit_tpl::place -value 2}}
    {.radC - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc3)} -var ::alited::unit_tpl::place -value 3}}
    {fra3 fra2 T 1 10 {-st nsew}}
    {.LabTpl - - - - {pack -side left -expand 1 -fill both}}
    {.butOK - - - - {pack -side left} {-t "$alited::al(MC,select)" -command ::alited::unit_tpl::Ok}}
    {.butCancel - - - - {pack -side left} {-t Cancel -command ::alited::unit_tpl::Cancel}}
  }
  set lbx [$obDl2 LbxTpl]
  set wtxt [$obDl2 TexTpl]
  bind $lbx <<ListboxSelect>> "::alited::unit_tpl::Select"
  bind $lbx <Delete> "::alited::unit_tpl::Delete"
  bind $lbx <Double-Button-1> "::alited::unit_tpl::Ok"
  bind $wtxt <FocusIn> "::alited::unit_tpl::InText $wtxt"
  if {[llength $tpllist]} {set foc $lbx} {set foc [$obDl2 EntTpl]}
  if {$ilast>-1} {::alited::unit_tpl::Select $ilast}
  set res [$obDl2 showModal $win -resizable {0 0} \
    -onclose ::alited::unit_tpl::Cancel -focus $foc]
  if {[llength $res] < 2} {set res ""}
  return $res
}

proc ::alited::unit_tpl::Ok {args} {
  variable win
  variable tplpos
  variable tplcont
  variable tplpla
  namespace upvar ::alited al al obDl2 obDl2
  if {[set isel [Selected]] eq ""} {
    focus [$obDl2 LbxTpl]
    return
  }
  set pla [lindex $tplpla $isel]
  set pos [lindex $tplpos $isel]
  set tex [lindex $tplcont $isel]
  SaveIni
  $obDl2 res $win [list $pla $pos $tex]
}

proc ::alited::unit_tpl::Cancel {args} {
  variable win
  namespace upvar ::alited obDl2 obDl2
  SaveIni
  $obDl2 res $win 0
}

proc ::alited::unit_tpl::Message {msg {first 1}} {
  namespace upvar ::alited obDl2 obDl2
  alited::Message $msg $first [$obDl2 LabTpl]
}

proc ::alited::unit_tpl::Selected {} {
  variable tpllist
  namespace upvar ::alited al al obDl2 obDl2
  if {[set isel [[$obDl2 LbxTpl] curselection]] eq ""} {
    Message $al(MC,tplsel) 2
  }
  return $isel
}

proc ::alited::unit_tpl::Pos {} {
  namespace upvar ::alited obDl2 obDl2
  return [[$obDl2 TexTpl] index insert]
}

proc ::alited::unit_tpl::Text {} {
  namespace upvar ::alited obDl2 obDl2
  return [[$obDl2 TexTpl] get 1.0 "end -1 char"]
}

proc ::alited::unit_tpl::InText {wtxt} {
  variable tplpos
  if {[set isel [Selected]] ne ""} {
    set pos [lindex $tplpos $isel]
    ::tk::TextSetCursor $wtxt $pos
  }
}

proc ::alited::unit_tpl::Select {{isel ""}} {
  variable tpllist
  variable tplcont
  variable tplpla
  variable tpl
  variable place
  namespace upvar ::alited obDl2 obDl2
  set lbx [$obDl2 LbxTpl]
  if {$isel eq ""} {set isel [$lbx curselection]}
  set tpl [lindex $tpllist $isel]
  set place [lindex $tplpla $isel]
  set wtxt [$obDl2 TexTpl]
  $wtxt delete 1.0 end
  $wtxt insert end [lindex $tplcont $isel]
  Focus $isel
}

proc ::alited::unit_tpl::Focus {isel} {
  namespace upvar ::alited obDl2 obDl2
  set lbx [$obDl2 LbxTpl]
  $lbx selection clear 0 end
  $lbx selection set $isel $isel
  $lbx see $isel
}

proc ::alited::unit_tpl::Add {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable tpl
  variable place
  set tpl [string trim $tpl]
  set txt [Text]
  if {$tpl ne "" && $txt ne "" && ( \
  [set isl1 [lsearch -exact $tpllist $tpl]]>-1 ||
  [set isel [lsearch -exact $tplcont $txt]]>-1 )} {
    if {$isl1>-1} {
      set isel $isl1
      focus [$obDl2 EntTpl]
    } else {
      set wtxt [$obDl2 TexTpl]
      focus $wtxt
      set pos [lindex $tplpos $isel]
      ::tk::TextSetCursor $wtxt $pos
    }
    Message $al(MC,tplexists) 2
  } elseif {$tpl eq ""} {
    focus [$obDl2 EntTpl]
    Message $al(MC,tplent1) 2
    return
  } elseif {[string trim $txt] eq ""} {
    focus [$obDl2 TexTpl]
    Message $al(MC,tplent2) 2
    return
  } else {
    set isel end
    lappend tpllist $tpl
    lappend tplcont $txt
    lappend tplpos [Pos]
    lappend tplpla $place
    set msg [string map [list %n [llength $tpllist]] $al(MC,tplnew)]
    Message $msg
  }
  Focus $isel
}

proc ::alited::unit_tpl::Change {} {
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable place
  variable tpl
  namespace upvar ::alited al al
  if {[set isel [Selected]] eq ""} return
  set tpllist [lreplace $tpllist $isel $isel $tpl]
  set tplcont [lreplace $tplcont $isel $isel [Text]]
  set tplpos [lreplace $tplpos $isel $isel [Pos]]
  set tplpla [lreplace $tplpla $isel $isel $place]
  set msg [string map [list %n [incr isel]] $al(MC,tplupd)]
  Message $msg
}

proc ::alited::unit_tpl::Delete {} {
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  namespace upvar ::alited al al
  if {[set isel [Selected]] eq ""} return
  set nsel [expr {$isel+1}]
  set msg [string map [list %n $nsel] $al(MC,tpldelq)]
  if {![alited::msg yesno warn $msg NO -title $al(MC,warning)]} {
    return
  }
  set tpllist [lreplace $tpllist $isel $isel]
  set tplcont [lreplace $tplcont $isel $isel]
  set tplpos [lreplace $tplpos $isel $isel]
  set tplpla [lreplace $tplpla $isel $isel]
  set llen [expr {[llength $tpllist]-1}]
  if {$isel>$llen} {set isel $llen}
  if {$llen>=0} {Select $isel}
  set msg [string map [list %n $nsel] $al(MC,tplrem)]
  Message $msg
}

proc ::alited::unit_tpl::IniFile {} {
  return [file join $alited::INIDIR unit_tpl.ini]
}

proc ::alited::unit_tpl::ReadIni {} {
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  namespace upvar ::alited al al
  set tpllist [list]
  set tplcont [list]
  set tplpos [list]
  if {[catch {set chan [open [IniFile]]}]} return
  foreach lst [split [read $chan] \n] {
    if {![catch {lassign $lst tpl cont pos pla}]} {
      set cont [string map {\\n \n} $cont]
      if {$tpl ne "" && $cont ne "" && $pos ne ""} {
        if {![string is double -strict $pos]} {set pos 1.0}
        lappend tpllist $tpl
        lappend tplcont $cont
        lappend tplpos $pos
        lappend tplpla $pla
      }
    }
  }
  close $chan
}

proc ::alited::unit_tpl::SaveIni {} {
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable ilast
  namespace upvar ::alited al al
  set fname [IniFile]
  if {[catch {set chan [open $fname w]} err]} {
    set msg [string map [list %f $fname] $al(MC,tplerrsav)]
    append msg \n\n $err
    alited::msg ok err $msg -title $al(MC,error)
    return
  }
  foreach tpl $tpllist cont $tplcont pos $tplpos pla $tplpla {
    set cont [string map {\n \\n} $cont]
    puts $chan [list $tpl $cont $pos $pla]
  }
  close $chan
  set ilast [Selected]
}

proc ::alited::unit_tpl::_run {} {

  variable win
  ReadIni
  set res [Show]
  destroy $win
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
