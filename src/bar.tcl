###########################################################
# Name:    bar.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/01/2021
# Brief:   Handles bar of tabs.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval bar {
  variable ctrltablist [list]  ;# selected tabs (with Ctrl+click)
  variable whilesorting no
}

# _________________________ Main procs ________________________ #

proc bar::BAR {args} {
  # Runs the tab bar's method.
  #   args - method's name and its arguments

  namespace upvar ::alited al al
  if {[lindex $args 0] eq {popList}} {
    if {[llength $args] eq 1} {lappend args {} {}}
    lappend args $al(sortList)
  }
  return [al(bts) $al(BID) {*}$args]
}
#_______________________

proc bar::PopupTip {wmenu idx TID} {
  # Makes tooltips (full file names) for popup menu items.
  # wmenu - path to popup menu
  # idx - index of item
  # TID - ID of item's tab

  if {[$wmenu cget -tearoff]} {incr idx}
  ::baltip::tip $wmenu [alited::file::FileStat [FileName $TID]] -index $idx -shiftX 10
}
#_______________________

proc bar::FillBar {wframe {newproject no}} {
  # Fills the bar of tabs.
  #   wframe - frame's path to place the bar in
  #   newproject - if yes, creates the bar from scratch

  namespace upvar ::alited al al obPav obPav
  set wbase [$obPav LbxInfo]
  set lab0 [msgcat::mc (Un)Select]
  set lab1 [msgcat::mc {... Visible}]
  set lab2 [msgcat::mc {... All at Left}]
  set lab3 [msgcat::mc {... All at Right}]
  set lab4 [msgcat::mc {... All}]
  if {$al(ED,btsbd)} {set bd {-bd 2 -relief sunken}} {set bd {}}
  set bar1Opts [list -wbar $wframe -wbase $wbase -pady 2 -scrollsel no -lifo $al(lifo) \
    -lowlist $al(FONTSIZE,small) -lablen $al(INI,barlablen) -tiplen $al(INI,bartiplen) \
    -bg [lindex [$obPav csGet] 3] -popuptip ::alited::bar::PopupTip \
    -menu [list \
      sep \
      "com {$lab0} {::alited::bar::SelTab %t} {} {}" \
      "com {$lab1} {::alited::bar::SelTabVis} {} {}" \
      "com {$lab2} {::alited::bar::SelTabLeft %t} {} {{\[::alited::bar::DisableTabLeft %t\]}}" \
      "com {$lab3} {::alited::bar::SelTabRight %t} {} {{\[::alited::bar::DisableTabRight %t\]}}" \
      "com {$lab4} {::alited::bar::SelTabAll} {} {}"] \
    -separator no -font apaveFontDefTypedsmall \
    -csel2 {alited::bar::OnTabSelection %t} \
    -csel3 alited::bar::OnControlClick \
    -cdel {alited::file::CloseFile %t yes} \
    -cmov2 alited::bar::OnTabMove \
    -title $al(MC,filelist) \
    -expand 9 -padx 0 {*}$bd]
  set tabs [set files [set posis [set wraps [list]]]]
  foreach tab $al(tabs) {
    lassign [split $tab \t] tab pos wrap
    lappend files $tab
    lappend posis $pos
    lappend wraps $wrap
    set tab [UniqueTab $tabs [file tail $tab]]
    lappend tabs $tab
    lappend bar1Opts -tab $tab
  }
  set byname [msgcat::mc Sort]
  set bydate [msgcat::mc {... by date}]
  set bysize [msgcat::mc {... by size}]
  set byextn [msgcat::mc {... by extension}]
  set ttl [msgcat::mc {Files to Beginning}]
  set tip [msgcat::mc \
    "If it's checked, open files would be placed\nonto the beginning page of the bar."]
  lappend bar1Opts -menu [list \
    sep \
    "com {$byname} {alited::bar::Sort Name}" \
    "com {$bydate} {alited::bar::Sort Date {\n$bydate}}" \
    "com {$bysize} {alited::bar::Sort Size {\n$bysize}}" \
    "com {$byextn} {alited::bar::Sort Extn {\n$byextn}}" \
    sep \
    "chb {$ttl} alited::bar::Lifo {} {} {$tip} ::alited::al(lifo)" \
    ]
  set curname [lindex $tabs $al(curtab)]
  catch {::bartabs::Bars create al(bts)}   ;# al(bts) is Bars object
  if {$newproject || [catch {set al(BID) [al(bts) create al(bt) $bar1Opts $curname]}]} {
    foreach tab $tabs {BAR insertTab $tab}
  }
  set tabs [BAR listTab]
  foreach tab $tabs fname $files pos $posis wrap $wraps {
    set tid [lindex $tab 0]
    SetTabState $tid --fname $fname --pos $pos --wrap $wrap
    BAR $tid configure -tip [alited::file::FileStat $fname]
  }
  set curname [lindex $files $al(curtab)]
  SetBarState -1 $curname [$obPav Text] [$obPav SbvText]
  ColorBar
  alited::file::CheckForNew
}
#_______________________

proc bar::UniqueTab {tabs tab args} {
  # Returns a unique name for a tab.
  #   tabs - list of tabs
  #   tab - tab name to be checked for its duplicate
  #   args - options of lsearch to find a duplicate name
  # If some file has a tail name (tab name) equal to an existing one's,
  # the new tab name should get "(N)" suffix to be unique.
  # This is required by bartabs package: no duplicates allowed.

  set cnttab 1
  set taborig $tab
  while {1} {
    if {[lsearch {*}$args $tabs $tab]==-1} break
    set tab "$taborig ([incr cnttab])"
  }
  return $tab
}
#_______________________

proc bar::UniqueListTab {fname} {
  # Returns a unique tab name for a file.
  #   fname - file name

  return [UniqueTab [BAR listTab] [file tail $fname] -index 1]
}

# ________________________ Menu additions _________________________ #

proc bar::SelTab {tab {mode -1}} {
  # Makes a tab selected / unselected.
  #   tab - tab's ID
  #   mode - if 1, selects the tab

  set selected [BAR cget -select]
  if {$mode == 1 || $tab in $selected} {
    BAR unselectTab $tab
  } elseif {$mode == 0 || $tab ni $selected} {
    BAR selectTab $tab
  }
}
#_______________________

proc bar::SelTabVis {} {
  # Makes visible tabs selected / unselected.

  foreach tab [BAR listFlag v] {
    SelTab $tab
  }
}
#_______________________

proc bar::SelTabAll {} {
  # Makes all tabs selected / unselected.

  set mode [expr {[llength [BAR cget -select]]>0}]
  foreach tab [BAR listTab] {
    SelTab [lindex $tab 0] $mode
  }
}
#_______________________

proc bar::SelTabLeft {tab} {
  # Makes all left tabs selected / unselected.
  #   tab - tab's ID

  foreach t [BAR listTab] {
    set t [lindex $t 0]
    if {$t eq $tab} break
    SelTab $t
  }
}
#_______________________

proc bar::SelTabRight {tab} {
  # Makes all right tabs selected / unselected.
  #   tab - tab's ID

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
#_______________________

proc bar::DisableTabLeft {tab} {
  # Checks for left tabs to disable "select all at left".
  #   tab - tab's ID
  # Returns 1, if no left tab exists, thus disabling the menu's item.

  set i [CurrentTab 3 $tab]
  if {$i} {return 0}
  return 1
}
#_______________________

proc bar::DisableTabRight {tab} {
  # Checks for right tabs to disable "select all at right".
  #   tab - tab's ID
  # Returns 1, if no right tab exists, thus disabling the menu's item.

  set i [CurrentTab 3 $tab]
  if {$i < ([llength [BAR listTab]]-1)} {return 0}
  return 1
}
#_______________________

proc bar::SortData {{tab ""}} {
  # Sets or gets data for sorting bar tabs.
  #   tab - tab info (if empty, sets all tabs' data)
  # Returns a list of file's name, extension, date and size.

  if {$tab eq {}} {
    set sortdata [list]
    foreach tab [BAR listTab] {
      set tid [lindex $tab 0]
      set fname [FileName $tid]
      if {![catch {file stat $fname ares}]} {
        BAR $tid configure --sortdate $ares(mtime) --sortsize $ares(size)
      }
    }
    return {}
  } else {
    set tid [lindex $tab 0]
    lassign [BAR $tid cget -text --sortdate --sortsize] fname date size
    set ext [file extension $fname]
    if {[set i [string first " \(" $ext]]>-1} {
      set ext [string range $ext 0 $i-1]
    }
    return [list $fname $ext $date $size]
  }
}
#_______________________

proc bar::CompareByDate {t1 t2} {
  # Compares two tabs by date.
  #   t1 - 1st tab
  #   t2 - 2nd tab

  lassign [SortData $t1] fname1 - date1
  lassign [SortData $t2] fname2 - date2
  if {$date1 < $date2} {
    set res -1
  } elseif {$date1 > $date2} {
    set res 1
  } elseif {$::alited::al(incdec) eq {increasing}} {
    set res [string compare -nocase $fname1 $fname2]
  } else {
    set res [string compare -nocase $fname2 $fname1]
  }
  return $res
}
#_______________________

proc bar::CompareBySize {t1 t2} {
  # Compares two tabs by size.
  #   t1 - 1st tab
  #   t2 - 2nd tab

  lassign [SortData $t1] fname1 - - size1
  lassign [SortData $t2] fname2 - - size2
  if {$size1 < $size2} {
    set res -1
  } elseif {$size1 > $size2} {
    set res 1
  } elseif {$::alited::al(incdec) eq {increasing}} {
    set res [string compare -nocase $fname1 $fname2]
  } else {
    set res [string compare -nocase $fname2 $fname1]
  }
  return $res
}
#_______________________

proc bar::CompareByExtn {t1 t2} {
  # Compares two tabs by extension.
  #   t1 - 1st tab
  #   t2 - 2nd tab

  lassign [SortData $t1] fname1 ext1
  lassign [SortData $t2] fname2 ext2
  if {[set res [string compare -nocase $ext1 $ext2]]==0} {
    if {$::alited::al(incdec) eq {increasing}} {
      set res [string compare -nocase $fname1 $fname2]
    } else {
      set res [string compare -nocase $fname2 $fname1]
    }
  }
  return $res
}
#_______________________

proc bar::Sort {by {ttl ""}} {
  # Sorts tabs.
  #   by - sort type (by name is default)
  #   ttl - sort title

  namespace upvar ::alited obDl2 obDl2
  variable whilesorting
  set ::alited::al(incdec) [set ::alited::al(incdec$by)]
  lassign [$obDl2 input {} [msgcat::mc Sort] [list \
    radA  {{  }} {"$::alited::al(incdec)" increasing decreasing} \
  ] -head [msgcat::mc {Sort files}]$ttl] res ::alited::al(incdec)
  if {$res} {
    set whilesorting yes
    SortData
    if {$by eq {Name}} {set cmd {}} {set cmd alited::bar::CompareBy$by}
    if {$::alited::al(incdec) in [list increasing [msgcat::mc increasing]]} {
      set ::alited::al(incdec) increasing
    } else {
      set ::alited::al(incdec) decreasing
    }
    BAR sort -$::alited::al(incdec) $cmd
    set ::alited::al(incdec$by) $::alited::al(incdec)
    set whilesorting no
  }
}
#_______________________

proc bar::SelFile {tip} {
  # Open a file from the file list even when it's closed
  # (the file list may be open due to -tearoff option).

  lassign [split $tip \n] fname
  alited::file::OpenFile $fname yes
}
#_______________________

proc bar::Lifo {} {
  # Sets -lifo option of the bar.

  namespace upvar ::alited al al
  BAR configure -lifo $al(lifo)
}

# ________________________ Identification  _________________________ #

proc bar::CurrentTabID {} {
  # Gets ID of the current tab.

  return [BAR cget -tabcurrent]
}
#_______________________

proc bar::CurrentTab {io {TID ""}} {
  # Gets an attribute of the current tab.
  #   io - 0 to get ID, 1 - short name (tab label), 2 - full name, 3 - index
  #   TID - tab's ID

  if {$TID eq {}} {set TID [CurrentTabID]}
  switch $io {
    0 {set res $TID}
    1 {set res [BAR $TID cget -text]}
    2 {set res [FileName $TID]}
    3 {set res [lsearch -index 0 [BAR listTab] $TID]}
    default {set res {}}
  }
  return $res
}
#_______________________

proc bar::FileName {{TID ""}} {
  # Gets a file name of a tab.
  #   TID - tab's ID

  if {$TID eq {}} {set TID [CurrentTabID]}
  set tip [BAR $TID cget -tip]
  return [lindex [split $tip \n] 0]
}
#_______________________

proc bar::FileTID {fname} {
  # Gets a tab's ID of a file name.
  #   fname - file name

  set TID {}
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
  # Sets attributes of the tab bar that are specific for alited.
  #   TID - tab's ID
  #   args - list of attributes + values

  BAR configure -ALITED [list $TID {*}$args]
}
#_______________________

proc bar::GetBarState {} {
  # Gets attributes of a tab that are specific for alited.

  return [BAR cget -ALITED]
}
#_______________________

proc bar::SetTabState {TID args} {
  # Sets attributes of a tab.
  #   TID - tab's ID
  #   args - list of attributes + values

  if {![BAR isTab $TID]} return
  BAR $TID configure {*}$args
}
#_______________________

proc bar::GetTabState {{TID ""} args} {
  # Gets attributes of a tab.
  #   TID - tab's ID (current one by default)
  #   args - list of attributes + values

  if {$TID eq {}} {set TID [CurrentTabID]}
  if {![BAR isTab $TID]} {return {}}
  return [BAR $TID cget {*}$args]
}

# ________________________ Event handlers _________________________ #

proc bar::OnTabMove {} {
  # Handles moving a tab in the bar.

  namespace upvar ::alited al al
  alited::ini::SaveCurrentIni $al(INI,save_onmove)
}
#_______________________

proc bar::OnTabSelection {TID} {
  # Handles selecting a tab in the bar.
  #   TID - tab's ID

  namespace upvar ::alited al al
  variable whilesorting
  if {$whilesorting} return
  set fname [FileName $TID]
  alited::main::ShowText
  alited::file::SbhText
  alited::find::ClearTags
  alited::ini::SaveCurrentIni $al(INI,save_onselect)
  alited::edit::CheckSaveIcons [alited::file::IsModified $TID]
  alited::edit::CheckUndoRedoIcons [alited::main::CurrentWTXT] $TID
  if {[alited::edit::CommentChar] ne {}} {set cmnst normal} {set cmnst disabled}
  if {[set wtxt [alited::main::GetWTXT $TID]] ne {}} {
    set al(wrapwords) [expr {[$wtxt cget -wrap] eq {word}}]
  }
  CurrentControlTab $fname
  alited::menu::FillRunItems $fname
  alited::main::HighlightLine
  lassign [alited::main::CalcIndentation] indent indentchar
  ::apave::setTextIndent $indent $indentchar
  if {$al(prjindentAuto)} {alited::main::UpdateProjectInfo $indent}
  after 10 {::alited::tree::SeeSelection; ::alited::main::UpdateGutter}
}
#_______________________

proc bar::OnControlClick {} {
  # Shows a number of tabs selected by Ctrl+Click.

  set llen [llength [alited::bar::BAR cget -select]]
  set msg [string map "%n $llen" [msgcat::mc {Selected files: %n}]]
  alited::Message $msg 3
}

# ________________________ Handle Ctrl+Tab keys ______________________ #

proc bar::CurrentControlTab {{fname ""}} {
  # Keeps a list of last switched files, to switch between last two.
  #   fname - file name

  variable ctrltablist
  if {[set ret [expr {$fname eq {}}]]} {
    set fname [FileName]
  }
  if {[set i [lsearch -exact $ctrltablist $fname]]>-1} {
    set ctrltablist [lreplace $ctrltablist $i $i]
  }
  if {$ret} {
    set ctrltablist [linsert $ctrltablist 1 $fname]
  } else {
    set ctrltablist [linsert $ctrltablist 0 $fname]
  }
  return $fname
}
#_______________________

proc bar::ControlTab {} {
  # Switches between last two active tabs.

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
  if {$found} {
    CurrentControlTab $fname
    BAR $TID show
  }
  after idle {focus [alited::main::CurrentWTXT]}
}

# ________________________ Service  _________________________ #

proc bar::ColorBar {} {
  # Makes the bar of tabs to have a "marked tab" color
  # consistent with current color scheme.

  namespace upvar ::alited obPav obPav
  set cs [$obPav csCurrent]
  if {$cs>-1} {
    lassign [$obPav csGet $cs] cfg2 cfg1 cbg2 cbg1 cfhh - - - - - - - - - - - - fgmark
    BAR configure -fgmark $fgmark -comlist {::alited::bar::SelFile "%t"}
  }
}
#_______________________

proc bar::InsertTab {tab tip} {
  # Inserts a new tab into the beginning of bar of tabs.
  #   tab - the tab
  #   tip - the tab's tip

  namespace upvar ::alited al al
  set TID [BAR insertTab $tab 0]
  BAR $TID configure -tip $tip
  SetTabState $TID --fname $tip
  alited::ini::SaveCurrentIni $al(INI,save_onadd)
  return $TID
}

# _________________________________ EOF _________________________________ #
