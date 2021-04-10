#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The favorites' procedures of alited.
# _______________________________________________________________________ #

namespace eval favor {
  variable tipID ""
}

proc favor::IsSelected {wtreeN IDN nameN fnameN snameN headerN lineN} {
  namespace upvar ::alited al al obPav obPav
  upvar 1 $wtreeN wtree $IDN ID $nameN name $fnameN fname $snameN sname
  upvar 1 $headerN header $lineN line
  if {[set ID [alited::tree::CurrentItem TreeFavor]] eq ""} {return no}
  set wtree [$obPav TreeFavor]
  lassign [$wtree item $ID -values] name fname header line
  set sname [file tail $fname]
  return yes
}

proc favor::Add {{undermouse yes}} {
  namespace upvar ::alited al al obPav obPav
  lassign [alited::tree::CurrentItemByLine] - - itemID name values
  set name [string trim $name]
  if {$name eq ""} return
  if {$undermouse} {set geo "-geometry pointer+10+10"} {set geo ""}
  set fname [alited::bar::FileName]
  set sname [file tail $fname]
  foreach it [alited::tree::GetTree {} TreeFavor] {
    lassign [lindex $it 4] name2 fname2
    if {$name eq $name2 && $fname eq $fname2} {
      set msg [string map [list %n $name %f $sname] $al(MC,addexist)]
      alited::msg ok err $msg -title $al(MC,error) {*}$geo
      return
    }
  }
  set msg [string map [list %n $name %f $sname] $al(MC,addfavor)]
  if {[alited::msg yesno ques $msg YES -title $al(MC,question) {*}$geo]} {
    set wtree [$obPav Tree]
    set header [alited::unit::GetHeader [$obPav Tree] $itemID]
    set pos [[alited::main::CurrentWTXT] index insert]
    lassign [$wtree item $itemID -values] l1 l2
    set line [expr {($l1 eq "" || $l2 eq "" || $l1>$pos || $l2<$pos) ? 0 : \
      [alited::p+ $pos -$l1]}]
    set wt2 [$obPav TreeFavor]
    set ID2 [$wt2 insert {} end -values [list $name $fname $header $line]]
    $wt2 tag add tagNorm $ID2
  }
}

proc favor::Delete {{undermouse yes}} {
  namespace upvar ::alited al al
  if {![IsSelected wtree favID name fname sname header line]} return
  set msg [string map [list %n $name %f $sname] $al(MC,delfavor)]
  if {$undermouse} {set geo "-geometry pointer+10+10"} {set geo ""}
  if {[alited::msg yesno warn $msg NO -title $al(MC,warning) {*}$geo]} {
    $wtree delete $favID
  }
}

proc favor::Select {{favID ""}} {
  namespace upvar ::alited obPav obPav
  set wtree [$obPav TreeFavor]
  if {$favID ne ""} {
    lassign [$wtree item $favID -values] name fname header line
    set sname [file tail $fname]
  } elseif {![IsSelected wtree favID name fname sname header line]} {
    return
  }
  if {[set TID [alited::file::OpenFile $fname]] eq ""} return
  set values [$wtree item $favID -values]
  $wtree delete $favID
  set favID [$wtree insert {} 0 -values $values]
  $wtree tag add tagNorm $favID
  $wtree tag add tagBold $favID
  alited::unit::SelectByHeader $header $line
  after idle "alited::favor::ShowSelection $wtree $favID"
}

proc favor::ShowSelection {wtree favID} {
  if {[set sel [$wtree selection]] ne ""} {
    $wtree selection remove $sel
  }
  $wtree see $favID
  $wtree focus $favID
  $wtree selection add $favID
}

proc favor::UpdatePos {fname header pos} {
  namespace upvar ::alited obPav obPav
  foreach it [alited::tree::GetTree {} TreeFavor] {
    lassign $it - - ID - values
    lassign $values name2 fname2 header2
    if {$fname eq $fname2 && $header eq $header2} {
      [$obPav TreeFavor] item $ID -values [list $name2 $fname2 $header2 $pos]
      break
    }
  }
}

proc favor::CopyDeclaration {wtree ID} {
  clipboard clear
  clipboard append [lindex [$wtree item $ID -values] 2]
}

proc favor::ShowPopupMenu {ID X Y} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  set popm $wtree.popup
  catch {destroy $popm}
  menu $popm -tearoff 0
  set sname [lindex [$wtree item $ID -values] 0]
  if {[string length $sname]>25} {set sname "[string range $sname 0 21]..."}
  set msgsel [string map [list %t $sname] $al(MC,selfavor)]
  $popm add command -label $msgsel -command "::alited::favor::Select $ID"
  $popm add separator
  $popm add command -label $al(MC,FavLists) -command "::alited::favor::Lists $wtree"
  $popm add command -label $al(MC,favoradd) -command "::alited::favor::Add no"
  $popm add command -label $al(MC,favordel) -command "::alited::favor::Delete no"
  $popm add separator
  $popm add command -label $al(MC,copydecl) \
    -command "::alited::favor::CopyDeclaration $wtree $ID"
  tk_popup $popm $X $Y
}

proc favor::PopupMenu {x y X Y} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  set ID [$wtree identify item $x $y]
  if {![$wtree exists $ID]} return
  if {[set sel [$wtree selection]] ne ""} {
    $wtree selection remove $sel
  }
  $wtree selection add $ID
  ShowPopupMenu $ID $X $Y
}


proc favor::TooltipOff {} {
  namespace upvar ::alited al al obPav obPav
  variable tipID
  ::baltip hide $al(WIN)
  set tipID ""
}

proc favor::Tooltip {x y X Y} {
  namespace upvar ::alited al al obPav obPav
  variable tipID
  set wtree [$obPav TreeFavor]
  set ID [$wtree identify item $x $y]
  if {![$wtree exists $ID]} {
    TooltipOff
  } elseif {$tipID ne $ID} {
    set decl [lindex [$wtree item $ID -values] 2]
    set fname [lindex [$wtree item $ID -values] 1]
    append tip $decl \n $fname
    ::baltip tip $al(WIN) $tip -geometry +$X+$Y -per10 4000 -pause 5 -fade 5
  }
  set tipID $ID
}

proc favor::_init {} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  alited::tree::AddTags $wtree
  $wtree tag bind tagNorm <Return> {::alited::favor::Select}
  $wtree tag bind tagNorm <Double-Button-1> {::alited::favor::Select}
  $wtree tag bind tagNorm <ButtonRelease-3> {alited::favor::PopupMenu %x %y %X %Y}
  $wtree tag bind tagNorm <Motion> {after idle {alited::favor::Tooltip %x %y %X %Y}}
  bind $wtree <Leave> {alited::favor::TooltipOff}
  $wtree heading #1 -text [msgcat::mc $al(MC,favorites)]
  foreach curfav $al(FAV,current) {
    catch {
      lassign $curfav - - - - values
      if {$values ne ""} {
        set itemID [$wtree insert {} end -values $values]
        $wtree tag add tagNorm $itemID
      }
    }
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
