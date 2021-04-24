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
  variable tplid   [list]
  variable tplkeys [list]
  variable tplKEYS [list]
  variable tplkey ""
  variable tpl ""
  variable place 1
  variable ilast -1
  variable win $::alited::al(WIN).fraTpl
}

proc unit_tpl::Ok {args} {
  variable win
  variable tplpos
  variable tplcont
  variable tplpla
  namespace upvar ::alited al al obDl2 obDl2
  if {[set isel [Selected index]] eq ""} {
    focus [$obDl2 TreeTpl]
    return
  }
  set tex [lindex $tplcont $isel]
  set pos [lindex $tplpos $isel]
  set pla [lindex $tplpla $isel]
  SaveIni
  $obDl2 res $win [list $tex $pos $pla]
}

proc unit_tpl::Cancel {args} {
  variable win
  namespace upvar ::alited obDl2 obDl2
  SaveIni
  $obDl2 res $win 0
}

proc unit_tpl::Message {msg {first 1}} {
  namespace upvar ::alited obDl2 obDl2
  alited::Message $msg $first [$obDl2 LabTpl]
}

proc unit_tpl::UpdateTree {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  variable tplkeys
  variable tplid
  set tree [$obDl2 TreeTpl]
  $tree delete [$tree children {}]
  set tplid [list]
  foreach tpl $tpllist tplkey $tplkeys {
    set item [$tree insert {} end -values [list $tpl $tplkey]]
    lappend tplid $item
  }
  ClearCbx
}

proc unit_tpl::ClearCbx {} {
  namespace upvar ::alited obDl2 obDl2
  [$obDl2 CbxKey] selection clear
}

proc unit_tpl::Selected {what {domsg yes}} {
  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  set tree [$obDl2 TreeTpl]
  if {[set isel [$tree selection]] eq "" && [set isel [$tree focus]] eq "" \
  && $domsg} {
    Message $al(MC,tplsel) 4
  }
  if {$isel ne "" && $what eq "index"} {
    set isel [$tree index $isel]
  }
  return $isel
}

proc unit_tpl::Pos {{pos ""}} {
  namespace upvar ::alited obDl2 obDl2
  set wtxt [$obDl2 TexTpl]
  if {$wtxt eq [focus] || $pos eq ""} {
    return [$wtxt index insert]
  }
  return $pos
}

proc unit_tpl::Text {} {
  namespace upvar ::alited obDl2 obDl2
  return [[$obDl2 TexTpl] get 1.0 "end -1 char"]
}

proc unit_tpl::InText {wtxt} {
  variable tplpos
  namespace upvar ::alited obDl2 obDl2
  if {[set isel [Selected index no]] ne ""} {
    set pos [lindex $tplpos $isel]
    ::tk::TextSetCursor $wtxt $pos
  }
}

proc unit_tpl::Select {{item ""}} {
  variable tpllist
  variable tplkey
  variable tplkeys
  variable tplcont
  variable tplid
  variable tplpla
  variable tpl
  variable place
  namespace upvar ::alited obDl2 obDl2
  if {$item eq ""} {set item [Selected item no]}
  if {$item ne ""} {
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
  }
}

proc unit_tpl::Focus {isel} {
  namespace upvar ::alited obDl2 obDl2
  set tree [$obDl2 TreeTpl]
  $tree selection set $isel
  $tree see $isel
}

proc unit_tpl::Add {} {
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
  if {$tplkey ne ""} {
    set isel2 [lsearch -exact $tplkeys $tplkey]
  } else {
    set isel2 -1
  }
  if {$tpl ne "" && $txt ne "" && ( \
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
    Message $al(MC,tplexists) 4
    return
  } elseif {$tpl eq ""} {
    focus [$obDl2 EntTpl]
    Message $al(MC,tplent1) 4
    return
  } elseif {[string trim $txt] eq ""} {
    focus [$obDl2 TexTpl]
    Message $al(MC,tplent2) 4
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
  Message $msg
}

proc unit_tpl::Change {} {
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
  if {[set isel [Selected index]] eq ""} return
  set tpllist [lreplace $tpllist $isel $isel $tpl]
  set tplcont [lreplace $tplcont $isel $isel [Text]]
  set tplpos [lreplace $tplpos $isel $isel [Pos [lindex $tplpos $isel]]]
  set tplpla [lreplace $tplpla $isel $isel $place]
  set tplkeys [lreplace $tplkeys $isel $isel $tplkey]
  UpdateTree
  Select $isel
  set msg [string map [list %n [incr isel]] $al(MC,tplupd)]
  Message $msg
}

proc unit_tpl::Delete {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable tpllist
  variable tplcont
  variable tplpos
  variable tplpla
  variable tplkeys
  variable tplid
  variable win
  if {[set isel [Selected index]] eq ""} return
  set nsel [expr {$isel+1}]
  set msg [string map [list %n $nsel] $al(MC,tpldelq)]
  set geo "-geometry root=$win"
  if {![alited::msg yesno warn $msg NO -title $al(MC,warning) {*}$geo]} {
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
  Message $msg
}

proc unit_tpl::ReadIni {} {
  namespace upvar ::alited al al
  foreach tv {tpllist tplcont tplkeys tplpos tplpla} {
    variable $tv
    set $tv [list]
  }
  foreach lst $al(TPL,list) {
    if {![catch {lassign $lst tpl key cont pos pla}]} {
      set cont [string map [list $::alited::EOL \n] $cont]
      if {$tpl ne "" && $cont ne "" && $pos ne ""} {
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

proc unit_tpl::RegisterKeys {} {
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

proc unit_tpl::GetKeyList {} {
  namespace upvar ::alited obDl2 obDl2
  RegisterKeys
  set keys [linsert [alited::keys::VacantList] 0 ""]
  [$obDl2 CbxKey] configure -values $keys
}

proc unit_tpl::SaveIni {} {
  variable ilast
  RegisterKeys
  set ilast [Selected index no]
}

proc unit_tpl::_create {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable tpllist
  variable ilast
  variable tplkey
  variable tplKEYS
#alited::keys::Test [alited::keys::UserList]
  $obDl2 untouchWidgets *.texTpl
  $obDl2 makeWindow $win $al(MC,tpl)
  $obDl2 paveWindow $win {
    {fralab - - 2 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.lab1 - - 1 10 {-st ew} {-t "$alited::al(MC,tpl1)"}}
    {.lab2 fralab.lab1 T 1 10 {-st ew} {-t "$alited::al(MC,tpl2)"}}
    {fraTreeTpl fralab T 10 10 {-st nswe -pady 8} {}}
    {.fra - - - - {pack -side right -fill both} {}}
    {.fra.buTAdd - - - - {pack -side top -anchor n} {-takefocus 0 -com ::alited::unit_tpl::Add -tooltip {$alited::al(MC,tpladd)}}}
    {.fra.buTChange - - - - {pack -side top} {-takefocus 0 -com ::alited::unit_tpl::Change -tooltip {$alited::al(MC,tplchg)}}}
    {.fra.buTDelete - - - - {pack -side top} {-takefocus 0 -com ::alited::unit_tpl::Delete -tooltip {$alited::al(MC,tpldel)}}}
    {.TreeTpl - - - - {pack -side left -expand 1 -fill both} {-h 7 -show headings -columns {C1 C2} -displaycolumns {C1 C2} -columnoptions "C2 {-width 20}"}}
    {.sbvTpls fraTreeTpl.TreeTpl L - - {pack -side left -fill both}}
    {fra1 fraTreeTpl T 10 10 {-st nsew}}
    {.labTpl - - 1 1 {-st we} {-anchor center -t "$alited::al(MC,tpl4)"}}
    {.EntTpl fra1.labTpl L 1 8 {-st we} {-tvar ::alited::unit_tpl::tpl -w 30 -tooltip {$alited::al(MC,tplent1)}}}
    {.CbxKey fra1.EntTpl L 1 1 {-st we} {-tvar ::alited::unit_tpl::tplkey -postcommand ::alited::unit_tpl::GetKeyList -state readonly -h 16 -w 16 -tooltip {$alited::al(MC,tplcbx)}}}
    {fra1.fratex fra1.labTpl T 10 10 {-st nsew} {}}
    {.TexTpl - - - - {pack -side left -expand 1 -fill both} {-h 10 -w 60 -tooltip {$alited::al(MC,tplent2) -font $alited::al(FONT,monosmall)}}}
    {.sbvTpl .TexTpl L - - {pack -side left -fill both} {}}
    {fra2 fra1 T 1 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack -side left} {-t {$alited::al(MC,tplloc)}}}
    {.radA - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc1)} -var ::alited::unit_tpl::place -value 1 -tooltip {$al(MC,tplttloc1)}}}
    {.radB - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc2)} -var ::alited::unit_tpl::place -value 2 -tooltip {$al(MC,tplttloc2)}}}
    {.radC - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc3)} -var ::alited::unit_tpl::place -value 3 -tooltip {$al(MC,tplttloc3)}}}
    {.radD - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,tplloc4)} -var ::alited::unit_tpl::place -value 4 -tooltip {$al(MC,tplttloc4)}}}
    {fra3 fra2 T 1 10 {-st nsew}}
    {.LabTpl - - - - {pack -side left -expand 1 -fill both}}
    {.butOK - - - - {pack -side left} {-t "$alited::al(MC,select)" -command ::alited::unit_tpl::Ok}}
    {.butCancel - - - - {pack -side left} {-t Cancel -command ::alited::unit_tpl::Cancel}}
  }
  set tree [$obDl2 TreeTpl]
  $tree heading C1 -text $al(MC,tplhd1)
  $tree heading C2 -text $al(MC,tplhd2)
  UpdateTree
  set wtxt [$obDl2 TexTpl]
  bind $tree <<TreeviewSelect>> "::alited::unit_tpl::Select"
  bind $tree <Delete> "::alited::unit_tpl::Delete"
  bind $tree <Double-Button-1> "::alited::unit_tpl::Ok"
  bind $tree <Return> "::alited::unit_tpl::Ok"
  bind $wtxt <FocusIn> "::alited::unit_tpl::InText $wtxt"
  bind [$obDl2 CbxKey] <FocusOut> "::alited::unit_tpl::ClearCbx"
  if {[llength $tpllist]} {set foc $tree} {set foc [$obDl2 EntTpl]}
  if {$ilast>-1} {Select $ilast}
  set res [$obDl2 showModal $win -resizable {0 0} \
    -onclose ::alited::unit_tpl::Cancel -focus $foc]
  if {[llength $res] < 2} {set res ""}
  return $res
}

proc unit_tpl::_run {} {

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
#RUNF1: alited.tcl
