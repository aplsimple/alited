#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The favorites' lists.
# _______________________________________________________________________ #

namespace eval ::alited::favor_ls {
  variable favlist [list]
  variable favlistsaved [list]
  variable favcont [list]
  variable favpla  [list]
  variable currents [list]
  variable fav ""
  variable place 1
  variable win $::alited::al(WIN).fraFavs
}

proc favor_ls::Save_favlist {} {
  variable favlist
  variable favlistsaved
  set favlistsaved $favlist
}

proc favor_ls::Restore_favlist {} {
  variable favlist
  variable favlistsaved
  set favlist $favlistsaved
}

proc favor_ls::Ok {{res 0}} {
  namespace upvar ::alited obDl2 obDl2
  variable win
  variable favcont
  variable favpla
  if {!$res} {
    if {[set isel [Selected]] eq ""} {
      focus [$obDl2 LbxFav]
      return
    }
    set pla [lindex $favpla $isel]
    set cont [lindex $favcont $isel]
    set res [list $pla [Split $cont]]
  }
  Save_favlist
  $obDl2 res $win $res
}

proc favor_ls::Cancel {args} {
  namespace upvar ::alited obDl2 obDl2
  variable win
  Save_favlist
  $obDl2 res $win 0
}

proc favor_ls::Message {msg {first 1}} {
  namespace upvar ::alited obDl2 obDl2
  alited::Message $msg $first [$obDl2 LabFav]
}

proc favor_ls::Selected {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable favlist
  if {[set isel [[$obDl2 LbxFav] curselection]] eq ""} {
    Message $al(MC,favsel) 4
  }
  return $isel
}

proc favor_ls::Text {} {
  namespace upvar ::alited obDl2 obDl2
  return [[$obDl2 TexFav] get 1.0 "end -1 char"]
}

proc favor_ls::Select {{isel ""}} {
  namespace upvar ::alited obDl2 obDl2
  variable favlist
  variable favcont
  variable favpla
  variable fav
  variable place
  set lbx [$obDl2 LbxFav]
  if {$isel eq ""} {set isel [$lbx curselection]}
  if {$isel ne ""} {
    set fav [lindex $favlist $isel]
    set place [lindex $favpla $isel]
    set cont [Split [lindex $favcont $isel]]
    GetCurrentList {*}$cont
    Focus $isel
  }
}

proc favor_ls::Focus {isel} {
  namespace upvar ::alited obDl2 obDl2
  set lbx [$obDl2 LbxFav]
  $lbx selection clear 0 end
  $lbx selection set $isel $isel
  $lbx see $isel
}

proc favor_ls::Add {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable favlist
  variable favcont
  variable favpla
  variable currents
  variable fav
  variable place
  if {[set isel [[$obDl2 LbxFav] curselection]]==""} {
    set cont $currents
  } else {
    set cont [lindex $favcont $isel]
  }
  set found no
  set isel 0
  foreach f $favlist p $favpla c $favcont {
    if {$fav eq $f || ($p eq $place && $c eq $cont)} {
      set found yes
      break
    }
    incr isel
  }
  set fav [string trim $fav]
  if {$fav ne "" && $cont ne "" && $found} {
    Message $al(MC,favexists) 4
    Select $isel
    return
  } elseif {$fav eq ""} {
    focus [$obDl2 EntFav]
    Message $al(MC,favent1) 4
    return
  } elseif {[string trim $cont] eq ""} {
    Message $al(MC,favent3) 4
    return
  } else {
    set isel end
    lappend favlist $fav
    lappend favcont $cont
    lappend favpla $place
    set msg [string map [list %n [llength $favlist]] $al(MC,favnew)]
    Message $msg
  }
  Focus $isel
}

proc favor_ls::Change {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable favlist
  variable favpla
  variable place
  variable fav
  if {[set isel [Selected]] eq ""} return
  if {[set isl1 [lsearch -exact $favlist $fav]]!=$isel} {
    Message $al(MC,favexists) 4
    Select $isl1
  } else {
    set favlist [lreplace $favlist $isel $isel $fav]
    set favpla [lreplace $favpla $isel $isel $place]
    set msg [string map [list %n [incr isel]] $al(MC,favupd)]
    Message $msg
  }
}

proc favor_ls::Delete {} {
  namespace upvar ::alited al al
  variable favlist
  variable favcont
  variable favpla
  if {[set isel [Selected]] eq ""} return
  set nsel [expr {$isel+1}]
  set msg [string map [list %n $nsel] $al(MC,favdelq)]
  if {![alited::msg yesno warn $msg NO -title $al(MC,warning)]} {
    return
  }
  set favlist [lreplace $favlist $isel $isel]
  set favcont [lreplace $favcont $isel $isel]
  set favpla [lreplace $favpla $isel $isel]
  set llen [expr {[llength $favlist]-1}]
  if {$isel>$llen} {set isel $llen}
  if {$llen>=0} {Select $isel}
  set msg [string map [list %n $nsel] $al(MC,favrem)]
  Message $msg
}

proc favor_ls::IniFile {} {
  return [file join $alited::INIDIR favor_ls.ini]
}

proc favor_ls::GetCurrentList {args} {
  namespace upvar ::alited obDl2 obDl2
  variable currents
  set text [set currents ""]
  if {![llength $args]} {set args [alited::tree::GetTree {} TreeFavor]}
  foreach it $args {
    if {$text ne ""} {
      append text \n
      append currents $::alited::EOL
    }
    append text [lindex $it 4 0]
    append currents $it 
  }
  set w [$obDl2 TexFav]
  $obDl2 readonlyWidget $w no
  $obDl2 displayText $w $text
  $obDl2 readonlyWidget $w yes
}

proc favor_ls::Split {lines} {
  return [split [string map [list $::alited::EOL \n] $lines] \n]
}

proc favor_ls::GetIni {lines} {
  variable favlist
  variable favcont
  variable favpla
  set lines [Split $lines]
  if {[llength $lines]<3} {
    # initialize arrays
    set favlist [list]
    set favcont [list]
  } else {
    lappend favlist [lindex $lines 0]
    lappend favpla  [lindex $lines 1]
    lappend favcont [join [lrange $lines 2 end] $::alited::EOL]
  }
  Save_favlist
}

proc favor_ls::PutIni {} {
  variable favlist
  variable favcont
  variable favpla
  Restore_favlist
  set res [list]
  foreach fav $favlist pla $favpla cont $favcont {
    set r1 $fav
    append r1 $::alited::EOL
    append r1 $pla
    append r1 $::alited::EOL
    append r1 $cont
    lappend res $r1
  }
  return $res
}

proc favor_ls::_create {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable favlist
  variable fav
  $obDl2 untouchWidgets *.texFav
  $obDl2 makeWindow $win $al(MC,favorites)
  $obDl2 paveWindow $win {
    {fralab - - 2 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.lab1 - - 1 10 {-st ew} {-t "$alited::al(MC,fav1)"}}
    {.lab2 fralab.lab1 T 1 10 {-st ew} {-t "$alited::al(MC,fav2)"}}
    {fraLbxFav fralab T 10 10 {-st nswe -pady 8} {}}
    {.labFavs - - - - {pack -side top -fill x -anchor nw} {-t "$alited::al(MC,fav3)"}}
    {.fra - - - - {pack -side right -fill both} {}}
    {.fra.buTAdd - - - - {pack -side top -anchor n} {-takefocus 0 -com ::alited::favor_ls::Add -tooltip {$alited::al(MC,favadd)}}}
    {.fra.buTChange - - - - {pack -side top} {-takefocus 0 -com ::alited::favor_ls::Change -tooltip {$alited::al(MC,favchg)}}}
    {.fra.buTDelete - - - - {pack -side top} {-takefocus 0 -com ::alited::favor_ls::Delete -tooltip {$alited::al(MC,favdel)}}}
    {.LbxFav - - - - {pack -side left -expand 1 -fill both} {-h 7 -w 40 -lvar ::alited::favor_ls::favlist}}
    {.sbvFavs fraLbxFav.LbxFav L - - {pack -side left -fill both} {}}
    {fra1 fraLbxFav T 10 10 {-st nsew}}
    {.labFav - - 1 1 {-st we} {-anchor center -t "$alited::al(MC,fav4)"}}
    {.EntFav fra1.labFav L 1 9 {-st we} {-tvar ::alited::favor_ls::fav -w 40 -tooltip {$alited::al(MC,favent1)}}}
    {fra1.fratex fra1.labFav T 10 10 {-st nsew} {}}
    {.TexFav - - - - {pack -side left -expand 1 -fill both} {-h 7 -w 50 -tooltip {$alited::al(MC,favent2) -font $alited::al(FONT,monosmall)} -ro 1}}
    {.sbvFav .TexFav L - - {pack -side left -fill both}}
    {fra2 fra1 T 1 10 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack -side left} {-t {$alited::al(MC,favloc)}}}
    {.radA - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,favloc1)} -var ::alited::favor_ls::place -value 1 -tooltip {$al(MC,favtip1)}}}
    {.radB - - - - {pack -side left -padx 8}  {-t {$alited::al(MC,favloc2)} -var ::alited::favor_ls::place -value 2 -tooltip {$al(MC,favtip2)}}}
    {fra3 fra2 T 1 10 {-st nsew}}
    {.LabFav - - - - {pack -side left -expand 1 -fill both}}
    {.butUndo - - - - {pack -side left} {-t "$alited::al(MC,favinit)" -command {::alited::favor_ls::Ok 3} -tip {$alited::al(MC,favtip3)}}}
    {.butOK - - - - {pack -side left} {-t "$alited::al(MC,select)" -command ::alited::favor_ls::Ok}}
    {.butCancel - - - - {pack -side left} {-t Cancel -command ::alited::favor_ls::Cancel}}
  }
  set fav ""
  set lbx [$obDl2 LbxFav]
  set wtxt [$obDl2 TexFav]
  GetCurrentList
  Restore_favlist
  bind $lbx <<ListboxSelect>> "::alited::favor_ls::Select"
  bind $lbx <Delete> "::alited::favor_ls::Delete"
  bind $lbx <Double-Button-1> "::alited::favor_ls::Ok"
  bind $lbx <Return> "::alited::favor_ls::Ok"
  if {[llength $favlist]} {set foc $lbx} {set foc [$obDl2 EntFav]}
  set res [$obDl2 showModal $win -resizable {0 0} \
    -onclose ::alited::favor_ls::Cancel -focus $foc]
  return $res
}

proc favor_ls::_run {} {

  variable win
  set res [_create]
  destroy $win
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
