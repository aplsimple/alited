#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The file procedures.
# _______________________________________________________________________ #

namespace eval file {}

proc file::FillMenu {} {
  # Populates alited's main menu.

  namespace upvar ::alited al al
  set m [set al(MENUFILE) $al(WIN).menu.file]
  $m add command -label "New" -command {alited::file::NewFile} -accelerator Ctrl+N
  $m add command -label "Open..." -command {alited::file::OpenFile} -accelerator Ctrl+O
  $m add separator
  $m add command -label "Save" -command {alited::file::SaveFile} -accelerator F2
  $m add command -label "Save As..." -command {alited::file::SaveFileAs} -accelerator Ctrl+S
  $m add command -label "Save All" -command {alited::file::SaveAll} -accelerator Shift+Ctrl+S
  $m add separator
  $m add command -label "Close" -command {alited::file::CloseFileMenu}
  $m add command -label "Close All" -command {alited::file::CloseAll 1}
  $m add command -label "Close All at Left" -command {alited::file::CloseAll 2}
  $m add command -label "Close All at Right" -command {alited::file::CloseAll 3}
  $m add separator
  $m add command -label "Restart" -command {set alited::al(RESTART) yes; alited::Exit}
  $m add separator
  $m add command -label "Quit" -command {alited::Exit}
  set m [set al(MENUEDIT) $al(WIN).menu.edit]
  $m add command -label "Cut" -command {alited::msg ok ques "This is just a demo: no action."}
  $m add command -label "Copy" -command {alited::msg ok warn "This is just a demo: no action."}
  $m add command -label "Paste" -command {alited::msg ok err "This is just a demo: no action."}
  $m add separator
  $m add command -label "Find..." -command {::t::findTclFirst yes}
  $m add command -label "Find Next" -command {::t::findTclNext yes}
  $m add separator
  $m add command -label "Reload the bar of tabs" -command {::t::RefillBar}
  set m [set al(MENUHELP) $al(WIN).menu.help]
  $m add command -label "About" -command alited::HelpAbout
}

proc file::CheckMenuItems {} {
  # Disables/enables "File/Close All..." menu items.

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  foreach idx {7 8 9} {
    set dsbl [alited::bar::BAR checkDisabledMenu $al(BID) $TID [incr item]]
    if {$dsbl} {
      set state "-state disabled"
    } else {
      set state "-state normal"
    }
    $al(MENUFILE) entryconfigure $idx {*}$state
  }
}

proc file::SearchFileTID {fname} {

  set TID ""
  foreach tab [alited::bar::BAR listTab] {
    set TID2 [lindex $tab 0]
    if {$fname eq [alited::bar::FileName $TID2]} {
      set TID $TID2
      break
    }
  }
  return $TID
}

proc file::IsModified {{TID ""}} {
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  return [expr {[lsearch -index 0 [alited::bar::BAR listFlag "m"] $TID]>-1}]
}

proc file::IsSaved {TID} {

  namespace upvar ::alited al al
  if {[IsModified $TID]} {
    set fname [alited::bar::BAR $TID cget -text]
    set ans [alited::msg yesnocancel warn [string map [list %f $fname] \
      $al(MC,notsaved)] -title $al(MC,saving)]
    return $ans
  }
  return 2  ;# as if "No" chosen
}

proc file::ReadFile {TID curfile wtxt} {
  namespace upvar ::alited al al obPav obPav
  set filecont [::apave::readTextFile $curfile]
  $obPav displayText $wtxt $filecont
  set al(_unittree,$TID) [alited::unit::GetUnits $filecont]
  $obPav makePopup $wtxt no yes
}

proc file::NewFile {} {

  namespace upvar ::alited al al
  if {[set TID [SearchFileTID $al(MC,nofile)]] eq ""} {
    set TID [alited::bar::InsertTab $al(MC,nofile) $al(MC,nofile)]
  }
  alited::bar::BAR $TID show
}

proc file::OpenFile {{fname ""}} {

  namespace upvar ::alited al al
  set al(filename) ""
  if {$fname eq ""} {
    set fname [::apave::obj chooser tk_getOpenFile alited::al(filename) \
      -initialdir [file dirname [alited::bar::CurrentTab 2]] -parent $al(WIN)]
  }
  if {[file exists $fname]} {
    if {[set TID [SearchFileTID $fname]] eq ""} {
      set tab [alited::bar::UniqueListTab $fname]
      set TID [alited::bar::InsertTab $tab $fname]
    }
    alited::bar::BAR $TID show
  }
}

proc file::SaveFileByName {TID fname} {
  # Saves the current file.
  set wtxt [alited::bar::GetTabState $TID --wtxt]
  set fcont [$wtxt get 1.0 "end - 1 chars"]  ;# last \n excluded
  if {![::apave::writeTextFile $fname fcont]} {
    alited::msg ok err [::apave::error $fname] -w 50 -text 1 -title "Error"
    return 0
  }
  $wtxt edit modified no
  alited::bar::TextModified $TID $wtxt
  alited::main::HighlightText $fname $wtxt
  return 1
}

proc file::SaveFile {{TID ""}} {
  # Saves the current file.

  namespace upvar ::alited al al
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  if {$fname in [list "" $al(MC,nofile)]} {
    return [SaveFileAs $TID]
  }
  set res [SaveFileByName $TID $fname]
  alited::ini::SaveCurrentIni "$res && $al(INI,save_onsave)"
  return $res
}

proc file::SaveFileAs {{TID ""}} {
  # Saves the current file "as".

  namespace upvar ::alited al al
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  set alited::al(filename) [alited::bar::FileName $TID]
  if {$alited::al(filename) in [list "" $al(MC,nofile)]} {
    set alited::al(filename) ""
  }
  set fname [::apave::obj chooser tk_getSaveFile alited::al(filename) -title \
    $al(MC,saveas) -initialdir [file dirname $alited::al(filename)] \
    -parent $al(WIN)]
  if {$fname in [list "" $al(MC,nofile)]} {
    set res 0
  } elseif {[set res [SaveFileByName $TID $fname]]} {
    RenameFile $TID $fname
  }
  return $res
}

proc file::SaveFileAndClose {} {
  # Saves and closes the current file.

  if {[IsModified] && ![SaveFile]} return
  alited::bar::BAR [alited::bar::CurrentTabID] close
}

proc file::SaveAll {} {
  # Saves all files.

  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    if {[IsModified $TID]} {
      if {![SaveFile $TID]} break
    }
  }
}

proc file::AllSaved {} {
  # Checks whether all files are saved. Saves them if not.

  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    switch [IsSaved $TID] {
      0 { ;# "Cancel" chosen for a modified
        return no
      }
      1 { ;# "Save" chosen for a modified
        set res [SaveFile $TID]
      }
    }
  }
  return yes
}

proc file::RenameFile {TID fname} {
  # Renames a file.

  namespace upvar ::alited al al
  alited::bar::SetTabState $TID --fname $fname
  set tab [alited::bar::UniqueListTab $fname]
  alited::bar::BAR $TID configure -text $tab -tip $fname
  alited::bar::BAR $TID show
}

proc file::CheckForNew {{docheck no}} {
  if {$docheck} {
    if {![llength [alited::bar::BAR listTab]]} {
      alited::file::NewFile
    }
  } else {
    after idle {::alited::file::CheckForNew yes}
  }
}

proc file::CloseFile {{TID ""}} {
  # Closes a file.

  namespace upvar ::alited al al obPav obPav
  set res 1
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
  if {$TID ni {"-1" ""} && $wtxt ne ""} {
    switch [IsSaved $TID] {
      0 { ;# "Cancel" chosen for a modified
        return 0
      }
      1 { ;# "Save" chosen for a modified
        set res [SaveFile $TID]
      }
    }
    if {$wtxt ne [$obPav Text]} {
      # [$obPav Text] was made by main::_open, let it be alive
      catch {destroy $wtxt}
      catch {destroy $wsbv}
      catch {destroy "${wtxt}_S2"}
      catch {destroy "${wsbv}_S2"}
    }
    alited::file::CheckForNew
    alited::ini::SaveCurrentIni $al(INI,save_onclose)
  }
  return $res
}

proc file::CloseFileMenu {} {
  # Closes the current file from the menu.

  if {[set TID [alited::bar::CurrentTabID]] ne ""} {
    alited::bar::BAR $TID close
  }
}

proc file::CloseAll {func} {
  # Closes files.
  #   func - "1/2/3" means closing "all/to left/to right"

  set TID [alited::bar::CurrentTabID]
  alited::bar::BAR closeAll $::alited::al(BID) $TID $func yesnocancel
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl -CS 24 -fontsize 11
