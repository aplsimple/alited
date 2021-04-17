#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The bar procedures.
# _______________________________________________________________________ #

namespace eval bar {}

proc bar::FillBar {wframe} {
  namespace upvar ::alited al al obPav obPav
  set wbase [$obPav LbxInfo]
  set bar1Opts [list -wbar $wframe -wbase $wbase -lablen 16 -pady 2 \
    -menu "" \
    -csel2 {alited::bar::OnTabSelection %t} \
    -cdel {alited::file::CloseFile %t} \
    -cmov2 alited::bar::OnTabMove]
  set tabs [set files [set posis [set posis2 [list]]]]
  foreach tab $al(tabs) {
    lassign [split $tab \t] tab pos pos_S2
    lappend files $tab
    lappend posis $pos
    lappend posis2 $pos_S2
    set tab [UniqueTab $tabs [file tail $tab]]
    lappend tabs $tab
    lappend bar1Opts -tab $tab
  }
  set curname [lindex $tabs $al(curtab)]
  ::bartabs::Bars create al(bts)   ;# al(bts) is Bars object
  set al(BID) [al(bts) create al(bt) $bar1Opts $curname]
  set tabs [BAR listTab]
  foreach tab $tabs fname $files pos $posis pos_S2 $posis2 {
    set tid [lindex $tab 0]
    SetTabState $tid --fname $fname --pos $pos --pos_S2 $pos_S2
    BAR $tid configure -tip $fname
  }
  set curname [lindex $files $al(curtab)]
  SetBarState "-1" $curname [$obPav Text] [$obPav SbvText]
  ColorBar
  alited::file::CheckForNew
}

proc bar::BAR {args} {
  # Runs the tab bar's method.
  #   args - method's name and its arguments

  namespace upvar ::alited al al
  return [al(bts) $al(BID) {*}$args]
}

proc bar::UniqueTab {tabs tab args} {
  set cnttab 1
  set taborig $tab
  while {1} {
    if {[lsearch {*}$args $tabs $tab]==-1} break
    set tab "$taborig ([incr cnttab])"
  }
  return $tab
}

proc bar::UniqueListTab {fname} {

  set tabs [alited::bar::BAR listTab]
  set tab [file tail $fname]
  return [UniqueTab $tabs $tab -index 1]
}

proc bar::SetBarState {TID args} {
  BAR configure -ALITED [list $TID {*}$args]
}

proc bar::GetBarState {} {
  return [BAR cget -ALITED]
}

proc bar::SetTabState {TID args} {
  if {![BAR isTab $TID]} return
  BAR $TID configure {*}$args
}

proc bar::GetTabState {{TID ""} args} {
  if {$TID eq ""} {set TID [CurrentTabID]}
  if {![BAR isTab $TID]} {return ""}
  return [BAR $TID cget {*}$args]
}

proc bar::CurrentTabID {} {
  # Gets ID of the current tab.

  return [BAR cget -tabcurrent]
}

proc bar::CurrentTab {io} {
  # Gets an attribute of the current tab.
  #   io - 0 to get ID, 1 - short name (tab label), 2 - full name, 3 - index

  set TID [CurrentTabID]
  switch $io {
    0 {set res $TID}
    1 {set res [BAR $TID cget -text]}
    2 {set res [FileName $TID]}
    3 {set res [lsearch -index 0 [BAR listTab] $TID]}
    default {set res ""}
  }
  return $res
}

proc bar::FileName {{TID ""}} {
  if {$TID eq ""} {set TID [CurrentTabID]}
  return [BAR $TID cget -tip]
}

proc bar::ColorBar {} {
  namespace upvar ::alited obPav obPav
  set cs [$obPav csCurrent]
  if {$cs>-1} {
    lassign [$obPav csGet $cs] cfg2 cfg1 cbg2 cbg1 cfhh - - - - fgmark
    BAR configure -fgmark $fgmark
  }
}

proc bar::OnTabMove {} {
  namespace upvar ::alited al al
  alited::ini::SaveCurrentIni $al(INI,save_onmove)
}

proc bar::OnTabSelection {TID} {

  namespace upvar ::alited al al
  alited::main::ShowText
  alited::ini::SaveCurrentIni $al(INI,save_onselect)
}

proc bar::InsertTab {tab tip} {
  namespace upvar ::alited al al
  set TID [BAR insertTab $tab]
  BAR $TID configure -tip $tip
  SetTabState $TID --fname $tip
  alited::ini::SaveCurrentIni $al(INI,save_onadd)
  return $TID
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
