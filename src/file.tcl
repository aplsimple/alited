#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The file procedures.
# _______________________________________________________________________ #

namespace eval file {}

proc file::IsModified {{TID ""}} {
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  return [expr {[lsearch -index 0 [alited::bar::BAR listFlag m] $TID]>-1}]
}

proc file::IsNoName {fname} {

  namespace upvar ::alited al al
  if {[file tail $fname] in [list $al(MC,nofile) {No name} {}]} {
    return yes
  }
  return no
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

proc file::OutwardChange {TID {docheck yes}} {
  namespace upvar ::alited al al
  set fname [alited::bar::FileName $TID]
  lassign [alited::bar::BAR $TID cget --mtime --mtimefile] mtime mtimefile
  if {[file exists $fname]} {
    set curtime [file mtime $fname]
  } elseif {$fname ne $al(MC,nofile)} {
    set curtime ?
  } else {
    set curtime {}
  }
  if {$docheck && $mtime ne {} && $curtime ne $mtime && $fname eq $mtimefile} {
    set isfile [file exists $fname]
    if {$isfile} {
      set msg [string map [list %f [file tail $fname]] $al(MC,modiffile)]
    } else {
      set msg [string map [list %f [file tail $fname]] $al(MC,wasdelfile)]
    }
    if {[alited::msg yesno warn $msg YES -title $al(MC,saving)]} {
      # if the answer was "no save", let the text remains a while for further considerations
      if {$isfile} {
        MakeThemReload $TID
        OpenFile $fname yes
      } else {
        SaveFile $TID
        set curtime [file mtime $fname]
      }
    }
  }
  alited::bar::BAR $TID configure --mtime $curtime --mtimefile $fname
}

proc file::MakeThemReload {{tabs ""}} {
  if {$tabs eq {}} {
    set tabs [alited::bar::BAR listTab]
  }
  foreach tab $tabs {
    alited::bar::BAR [lindex $tab 0] configure --reload yes
  }
}

proc file::ReadFile {TID curfile} {
  namespace upvar ::alited al al
  set filecont [::apave::readTextFile $curfile]
  set al(_unittree,$TID) [alited::unit::GetUnits $TID $filecont]
  return $filecont
}

proc file::DisplayFile {TID curfile wtxt} {
  namespace upvar ::alited al al obPav obPav
  set filecont [ReadFile $TID $curfile]
  $obPav displayText $wtxt $filecont
  $obPav makePopup $wtxt no yes
}

proc file::NewFile {} {

  namespace upvar ::alited al al
  if {[set TID [alited::bar::FileTID $al(MC,nofile)]] eq {}} {
    set TID [alited::bar::InsertTab $al(MC,nofile) $al(MC,nofile)]
  }
  alited::bar::BAR $TID show
}

proc file::OpenFile {{fname ""} {reload no}} {

  namespace upvar ::alited al al obPav obPav
  set al(filename) {}
  set chosen no
  if {$fname eq {}} {
    set chosen yes
    set fname [$obPav chooser tk_getOpenFile alited::al(filename) \
      -initialdir [file dirname [alited::bar::CurrentTab 2]] -parent $al(WIN)]
  }
  if {[file exists $fname]} {
    set exts {tcl, tm, msg, c, h, cc, cpp, hpp, html, css, md, txt, ini}
    set ext [string tolower [string trim [file extension $fname] .]]
    if {!$reload && $ext ni [split [string map {{ } {}} $exts] ,]} {
      set msg [string map [list %f [file tail $fname] %s $exts] $al(MC,nottoopen)]
      if {![alited::msg yesno warn $msg NO]} {
        return ""
      }
    }
    if {[set TID [alited::bar::FileTID $fname]] eq ""} {
      # close  "no name" tab if it's the only one and not changed
      set tabs [alited::bar::BAR listTab]
      set tabm [alited::bar::BAR listFlag "m"]
      if {[llength $tabs]==1 && [llength $tabm]==0} {
        set tid [lindex $tabs 0 0]
        if {[alited::bar::FileName $tid] eq $al(MC,nofile)} {
          alited::bar::BAR $tid close
        }
      }
      # open new tab
      set tab [alited::bar::UniqueListTab $fname]
      set TID [alited::bar::InsertTab $tab $fname]
    }
    alited::file::AddRecent $fname
    alited::bar::BAR $TID show
    return $TID
  }
  return ""
}

proc file::OpenOfDir {dname} {
  if {![catch {set flist [glob -directory $dname *]}]} {
    foreach fname [lsort -decreasing $flist] {
      if {[file isfile $fname] && [IsTcl $fname]} {
        OpenFile $fname
      }
    }
  }
}

proc file::IsTcl {fname} {
  if {[string tolower [file extension $fname]] in {.tcl .tm .msg}} {
    return yes
  }
  return no
}

proc file::SaveFileByName {TID fname} {
  # Saves the current file.
  set wtxt [alited::bar::GetTabState $TID --wtxt]
  set fcont [$wtxt get 1.0 "end - 1 chars"]  ;# last \n excluded
  if {![::apave::writeTextFile $fname fcont]} {
    alited::msg ok err [::apave::error $fname] -w 50 -text 1
    return 0
  }
  $wtxt edit modified no
  alited::unit::Modified $TID $wtxt
  alited::main::HighlightText $TID $fname $wtxt
  OutwardChange $TID no
  RecreateFileTree
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

  namespace upvar ::alited al al obPav obPav
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  set alited::al(filename) [file tail $fname]
  if {$alited::al(filename) in [list "" $al(MC,nofile)]} {
    set alited::al(filename) ""
  }
  set fname [$obPav chooser tk_getSaveFile alited::al(filename) -title \
    $al(MC,saveas) -initialdir [file dirname $fname] -parent $al(WIN)]
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
      if {![SaveFile $TID]} {return no}
    }
  }
  return yes
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
  alited::bar::BAR $TID configure -text "" -tip ""
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

proc file::CloseFile {{TID ""} {checknew yes}} {
  # Closes a file.

  namespace upvar ::alited al al obPav obPav
  set res 1
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
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
    if {$checknew} CheckForNew
    alited::ini::SaveCurrentIni $al(INI,save_onclose)
    RecreateFileTree
  }
  if {$al(closefunc) != 1} {  ;# close func = 1 means "close all"
    alited::file::AddRecent $fname
  }
  return $res
}

proc file::RecreateFileTree {} {

  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits)} {
    catch {after cancel $al(_AFT_RECR_)}
    set al(_AFT_RECR_) [after 100 ::alited::tree::RecreateTree]
  }
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

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  set al(closefunc) $func ;# disables "recent files" at closing all
  alited::bar::BAR closeAll $::alited::al(BID) $TID $func yesnocancel
  set al(closefunc) 0
  return [expr {[llength [alited::bar::BAR listFlag "m"]]==0}]
}

proc file::MoveExternal {f1112} {
  namespace upvar ::alited al al
  set fname [alited::bar::FileName]
  if {$al(prjroot) eq "" || [string first $al(prjroot) $fname]==0} {
    return no  ;# no project directory or the file is inside it
  }
  DoMoveFile $fname $al(prjroot) $f1112
  return yes
}

proc file::MoveFile1 {wtree fromID toID} {
  if {![$wtree exists $fromID] || ![$wtree exists $toID]} return
  set curfile [lindex [$wtree item $fromID -values] 1]
  set dirname [lindex [$wtree item $toID -values] 1]
  if {![file isdirectory $dirname]} {
    set dirname [file dirname $dirname]
  }
  if {[file isdirectory $curfile]} {
    if {$curfile ne $dirname} {
      alited::msg ok err [msgcat::mc "Only files are moved by alited."] \
        -geometry pointer+10+-100
    }
    return
  }
  if {[file dirname $curfile] ne $dirname} {
    DoMoveFile $curfile $dirname no
    alited::main::ShowHeader yes
  }
}

proc file::MoveFile {wtree to itemID f1112} {

  set tree [alited::tree::GetTree]
  set idx [alited::unit::SearchInBranch $itemID $tree]
  if {$idx<0} return
  if {$to eq {move}} {
    MoveFile1 $wtree $itemID $f1112
    return
  }
  set curfile [alited::bar::FileName]
  set curdir [file dirname $curfile]
  set selparent [$wtree parent $itemID]
  set dirname {}
  set increment [expr {$to eq {up} ? -1 : 1}]
  for {set i $idx} {1} {incr i $increment} {
    lassign [lindex $tree $i 4] files fname isfile id
    if {$fname eq {}} break
    if {$isfile} {
      set parent [$wtree parent $id]
      if {$parent ne $selparent && $parent ne {} && [file dirname $fname] ne $curdir} {
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
  alited::main::ShowHeader yes
}

proc file::RemoveFile {fname dname mode} {
  namespace upvar ::alited al al
  set ftail [file tail $fname]
  set dtail [file tail $dname]
  set fname2 [file join $dname $ftail]
  if {[file exists $fname2]} {
    if {$mode eq "move"} {
      set msg [string map [list %f $ftail %d $dname] $al(MC,fileexist)]
      alited::msg ok warn $msg
      return
    }
    catch {file delete $fname2}
  }
  if {[catch {file copy $fname $dname} err]} {
    set msg [string map [list %f $ftail %d $dname] $al(MC,errcopy)]
    if {![alited::msg yesno warn "$err\n\n$msg" NO]} return
  }
  catch {file mtime $fname2 [file mtime $fname]}
  file delete $fname
  alited::Message [string map [list %f $ftail %d $dtail] $al(MC,removed)]
  if {$mode eq "move"} {
    set TID [alited::bar::CurrentTabID]
    alited::bar::SetTabState $TID --fname $fname2
    alited::bar::BAR $TID configure -tip $fname2
  }
  alited::tree::RecreateTree
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
  if {![info exists al(_ANS_MOVE_)] || $al(_ANS_MOVE_)!=11} {
    set al(_ANS_MOVE_) [alited::msg yesno ques $msg \
      $defb -title $al(MC,moving) {*}$geo -ch "Don't ask again"]
    if {!$al(_ANS_MOVE_)} return
  }
  RemoveFile $fname $dname move
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
      alited::msg ok err $err
    }
  }
}

proc file::Delete {ID wtree} {
  namespace upvar ::alited al al BAKDIR BAKDIR
  set name [$wtree item $ID -text]
  set fname [lindex [$wtree item $ID -values] 1]
  set TID [alited::bar::FileTID $fname]
  if {$TID ne ""} {
    bell
    alited::msg ok warn $al(MC,nodelopen)
    alited::bar::BAR $TID show
    return
  }
  set msg [string map [list %f $name] $al(MC,delfile)]
  if {[alited::msg yesno ques $msg NO]} {
    RemoveFile $fname $BAKDIR backup
  }
}

proc file::InsertRecent {fname pos} {
  namespace upvar ::alited al al
  if {![IsNoName $fname]} {
    if {[set i [lsearch $al(RECENTFILES) $fname]]>-1} {
      set al(RECENTFILES) [lreplace $al(RECENTFILES) $i $i]
    }
    set al(RECENTFILES) [linsert $al(RECENTFILES) $pos $fname]
    catch {
      set al(RECENTFILES) [lreplace $al(RECENTFILES) $al(INI,RECENTFILES) end]
    }
  }
}

proc file::AddRecent {fname} {
  namespace upvar ::alited al al
  InsertRecent $fname 0
  alited::menu::FillRecent
}

proc file::ChooseRecent {idx} {
  namespace upvar ::alited al al
  set fname [lindex $al(RECENTFILES) $idx]
  AddRecent $fname
  OpenFile $fname
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
