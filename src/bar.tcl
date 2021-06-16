#! /usr/bin/env tclsh
#
# Name:    bar.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    05/13/2021
# Brief:   Handles bar of tabs.
# License: MIT.

# _________________________ Main procs of bar ________________________ #

namespace eval bar {
  variable ctrltablist [list]
}

proc bar::BAR {args} {
  # Runs the tab bar's method.
  #   args - method's name and its arguments

  namespace upvar ::alited al al
  return [al(bts) $al(BID) {*}$args]
}

proc bar::FillBar {wframe {newproject no}} {
  namespace upvar ::alited al al obPav obPav
  set wbase [$obPav LbxInfo]
  set lab0 [msgcat::mc "(Un)Select"]
  set lab1 [msgcat::mc "... Visible"]
  set lab2 [msgcat::mc "... All at Left"]
  set lab3 [msgcat::mc "... All at Right"]
  set lab4 [msgcat::mc "... All"]
  set bar1Opts [list -wbar $wframe -wbase $wbase -pady 2 -scrollsel no -lifo yes \
    -lowlist $al(FONTSIZE,small) -lablen $al(INI,barlablen) -tiplen $al(INI,bartiplen) \
    -menu [list \
      sep \
      "com {$lab0} {::alited::bar::SelTab %t} {} {}" \
      "com {$lab1} {::alited::bar::SelTabVis} {} {}" \
      "com {$lab2} {::alited::bar::SelTabLeft %t} {} {{\[::alited::bar::IsTabLeft %t\]}}" \
      "com {$lab3} {::alited::bar::SelTabRight %t} {} {{\[::alited::bar::IsTabRight %t\]}}" \
      "com {$lab4} {::alited::bar::SelTabAll} {} {}"] \
    -separator no -font apaveFontDefTypedsmall \
    -csel2 {alited::bar::OnTabSelection %t} \
    -cdel {alited::file::CloseFile %t} \
    -cmov2 alited::bar::OnTabMove]
  set tabs [set files [set posis [list]]]
  foreach tab $al(tabs) {
    lassign [split $tab \t] tab pos
    lappend files $tab
    lappend posis $pos
    set tab [UniqueTab $tabs [file tail $tab]]
    lappend tabs $tab
    lappend bar1Opts -tab $tab
  }
  set curname [lindex $tabs $al(curtab)]
  if {$newproject || [catch {
    ::bartabs::Bars create al(bts)   ;# al(bts) is Bars object
    set al(BID) [al(bts) create al(bt) $bar1Opts $curname]
  }]} then {
    foreach tab $tabs {BAR insertTab $tab}
  }
  set tabs [BAR listTab]
  foreach tab $tabs fname $files pos $posis {
    set tid [lindex $tab 0]
    SetTabState $tid --fname $fname --pos $pos
    BAR $tid configure -tip $fname
  }
  set curname [lindex $files $al(curtab)]
  SetBarState "-1" $curname [$obPav Text] [$obPav SbvText]
  ColorBar
  alited::file::CheckForNew
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

# ________________________ Menu additions _________________________ #

proc bar::SelTab {tab {mode -1}} {
  set selected [BAR cget -select]
  if {$mode == 1 || $tab in $selected} {
    BAR unselectTab $tab
  } elseif {$mode == 0 || $tab ni $selected} {
    BAR selectTab $tab
  }
}

proc bar::SelTabVis {} {
  foreach tab [BAR listFlag v] {
    SelTab $tab
  }
}

proc bar::SelTabAll {} {
  set mode [expr {[llength [BAR cget -select]]>0}]
  foreach tab [BAR listTab] {
    SelTab [lindex $tab 0] $mode
  }
}

proc bar::SelTabLeft {tab} {
  foreach t [BAR listTab] {
    set t [lindex $t 0]
    if {$t eq $tab} break
    SelTab $t
  }
}

proc bar::SelTabRight {tab} {
  set cntrd no
  foreach t [BAR listTab] {
    set t [lindex $t 0]
    if {$t eq $tab} {
      set cntrd yes
    } elseif {$cntrd} {
      SelTab $t
    }
  }
  
}

proc bar::IsTabLeft {tab} {
  set i [CurrentTab 3 $tab]
  if {$i} {return 0}
  return 1  ;# disables "select all at left"
}

proc bar::IsTabRight {tab} {
  set i [CurrentTab 3 $tab]
  if {$i < ([llength [BAR listTab]]-1)} {return 0}
  return 1  ;# disables "select all at right"
}
# ________________________ Identification  _________________________ #

proc bar::CurrentTabID {} {
  # Gets ID of the current tab.

  return [BAR cget -tabcurrent]
}

proc bar::CurrentTab {io {TID ""}} {
  # Gets an attribute of the current tab.
  #   io - 0 to get ID, 1 - short name (tab label), 2 - full name, 3 - index

  if {$TID eq ""} {set TID [CurrentTabID]}
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

proc bar::FileTID {fname} {

  set TID ""
  foreach tab [BAR listTab] {
    set TID2 [lindex $tab 0]
    if {$fname eq [FileName $TID2]} {
      set TID $TID2
      break
    }
  }
  return $TID
}

# ________________________ State of bar / tab _________________________ #

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

# ________________________ Event handlers _________________________ #

proc bar::OnTabMove {} {
  namespace upvar ::alited al al
  alited::ini::SaveCurrentIni $al(INI,save_onmove)
}

proc bar::OnTabSelection {TID} {

  namespace upvar ::alited al al
  alited::main::ShowText
  alited::find::ClearTags
  alited::ini::SaveCurrentIni $al(INI,save_onselect)
  alited::unit::CheckSaveIcons [alited::file::IsModified $TID]
  alited::unit::CheckUndoRedoIcons [alited::main::CurrentWTXT] $TID
  CurrentControlTab [FileName $TID]
}

# ________________________ Handlers Ctrl+Tab keys ______________________ #

proc bar::CurrentControlTab {{fname ""}} {
  variable ctrltablist
  if {[set ret [expr {$fname eq ""}]]} {
    set fname [FileName]
  }
  if {[set i [lsearch -exact $ctrltablist $fname]]>-1} {
    set ctrltablist [lreplace $ctrltablist $i $i]
  }
  if {$ret} {return $fname}
  set ctrltablist [linsert $ctrltablist 0 $fname]
}

proc bar::ControlTab {} {
  # Switches last two active tabs.
  variable ctrltablist
  set fname [CurrentControlTab]
  set found no
  while {[llength $ctrltablist]} {
    set fnext [lindex $ctrltablist 0]
    foreach tab [BAR listTab] {
      set TID [lindex $tab 0]
      if {$fnext eq [FileName $TID]} {
        set found yes
        break
      }
    }
    if {$found} break
    # if the file was closed, remove it from the ctrl-tabbed
    set ctrltablist [lreplace $ctrltablist 0 0]
  }
  CurrentControlTab $fname
  if {$found} {
    # select the first of open files that was next to the current
    BAR $TID show
  }
}

# ________________________ Service  _________________________ #

proc bar::ColorBar {} {
  namespace upvar ::alited obPav obPav
  set cs [$obPav csCurrent]
  if {$cs>-1} {
    lassign [$obPav csGet $cs] cfg2 cfg1 cbg2 cbg1 cfhh - - - - fgmark
    BAR configure -fgmark $fgmark
  }
}

proc bar::InsertTab {tab tip} {
  namespace upvar ::alited al al
  set TID [BAR insertTab $tab 0]
  BAR $TID configure -tip $tip
  SetTabState $TID --fname $tip
  alited::ini::SaveCurrentIni $al(INI,save_onadd)
  return $TID
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
