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
      $al(MC,notsaved)] YES -title $al(MC,saving)]
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
    return $TID
  }
  return ""
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
  alited::unit::Modified $TID $wtxt
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

proc file::MoveFile {wtree to itemID f1112} {

  set tree [alited::tree::GetTree]
  set idx [alited::unit::SearchInBranch $itemID $tree]
  if {$idx<0} {
    bell
    return
  }
  set curfile [alited::bar::FileName]
  set curdir [file dirname $curfile]
  set selfile [lindex [$wtree item $itemID -values] 1]
  set selparent [$wtree parent $itemID]
  set dirname ""
  set increment [expr {$to eq "up" ? -1 : 1}]
  for {set i $idx} {1} {incr i $increment} {
    lassign [lindex $tree $i 4] files fname isfile id
    if {$fname eq ""} break
    if {$isfile} {
      set parent [$wtree parent $id]
      if {$parent ne $selparent && $parent ne ""} {
        lassign [$wtree item $parent -values] files fname isfile id
        set dirname $fname
        break
      }
    } elseif {$id ne $selparent || $fname ne $curdir} {
      set dirname $fname
      break
    }
  }
  if {$dirname eq ""} {
    if {$selparent ne ""} {
      set dirname $alited::al(prjroot)
    } else {
      bell
      return
    }
  }
  DoMoveFile $curfile $dirname $f1112
}

proc file::RemoveFile {fname dname} {
  namespace upvar ::alited al al
  set ftail [file tail $fname]
  set dtail [file tail $dname]
  set fname2 [file join $dname $ftail]
  if {[file exists $fname2]} {catch {file delete $fname2}}
  if {[catch {file copy $fname $dname} err]} {
    set msg [string map [list %f $ftail %d $dname] $al(MC,errcopy)]
    alited::msg ok err "$msg\n\n$err" -title $al(MC,error)
  } else {
    file mtime $fname2 [file mtime $fname]
    file delete $fname
    alited::Message [string map [list %f $ftail %d $dtail] $al(MC,removed)]
    set TID [alited::bar::CurrentTabID]
    alited::bar::SetTabState $TID --fname $fname2
    alited::bar::BAR $TID configure -tip $fname2
    alited::tree::RecreateTree
  }
}

proc file::DoMoveFile {fname dname f1112} {

  namespace upvar ::alited al al
  set tailname [file tail $fname]
  if {$f1112} {
    set defb NO
    set geo ""
  } else {
    set defb YES
    set geo "-geometry pointer+10+10"
  }
  set msg [string map [list %f $tailname %d $dname] $al(MC,movefile)]
  if {![alited::msg yesno ques $msg $defb -title $al(MC,moving) {*}$geo]} {
    return
  }
  RemoveFile $fname $dname
}

proc file::Add {ID} {
  namespace upvar ::alited al al obPav obPav obDl2 obDl2
  if {$ID eq ""} {set ID [alited::tree::CurrentItem]}
  set dname [lindex [[$obPav Tree] item $ID -values] 1]
  if {[file isdirectory $dname]} {
    set fname ""
  } else {
    set fname [file tail $dname]
    set dname [file dirname $dname]
  }
  set head [string map [list %d $dname] $al(MC,filesadd2)]
  while {1} {
    set res [$obDl2 input "" $al(MC,filesadd) [list \
      seh {{} {-pady 10}} {} \
      ent "{$al(MC,filename)}" "{$fname}" \
      chb [list {} {-padx 5} [list -toprev 1 -t $al(MC,directory)]] {0} ] \
      -head $head -family "{[::apave::obj basicTextFont]}"]
    if {[lindex $res 0] && $fname eq ""} bell else break
  }
  lassign $res res fname isdir
  if {$res} {
    set fname [file join $dname $fname]
    if {[catch {
      if {$isdir} {
        file mkdir $fname
      } else {
        if {[file extension $fname] eq ""} {append fname .tcl}
        if {![file exists $fname]} {close [open $fname w]}
        OpenFile $fname
      }
      alited::tree::RecreateTree
    } err]} then {
      alited::msg ok err $err -title $al(MC,error)
    }
  }
}

proc file::Delete {ID wtree} {
  namespace upvar ::alited al al BAKDIR BAKDIR
  set name [$wtree item $ID -text]
  set fname [lindex [$wtree item $ID -values] 1]
  set msg [string map [list %f $name] $al(MC,delfile)]
  if {[alited::msg yesno ques $msg NO -title $al(MC,question)]} {
    RemoveFile $fname $BAKDIR
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
