#! /usr/bin/env tclsh
###########################################################
# Name:    file.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/29/2021
# Brief:   Handles files and file tree.
# License: MIT.
###########################################################

namespace eval file {}

# _________________________ Common ________________________ #

proc file::IsModified {{TID ""}} {
  # Checks if a text of tab is modified.
  #   TID - ID of tab

  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  return [expr {[lsearch -index 0 [alited::bar::BAR listFlag m] $TID]>-1}]
}
#_______________________

proc file::IsNoName {fname} {
  # Checks if a file name is "No name".
  #   fname - file name

  namespace upvar ::alited al al
  if {[file tail $fname] in [list $al(MC,nofile) {No name} {}]} {
    return yes
  }
  return no
}
#_______________________

proc file::IsSaved {TID} {
  # Checks if a file is modified and if yes, offers to save it.
  #   TID - ID of tab
  # Returns 1 for "yes, needs saving", 2 for "needs no saving", 0 for "cancel".

  namespace upvar ::alited al al
  if {[IsModified $TID]} {
    set fname [alited::bar::BAR $TID cget -text]
    set ans [alited::msg yesnocancel warn [string map [list %f $fname] \
      $al(MC,notsaved)] YES -title $al(MC,saving)]
    return $ans
  }
  return 2  ;# as if "No" chosen
}
#_______________________

proc file::MakeThemHighlighted {{tabs ""}} {
  # Sets flag "highlight file(s) anyway".
  #   tabs - list of tabs to set the flag for
  # Useful when you need update the files' highlightings.

  namespace upvar ::alited al al
  if {$tabs eq {}} {
    set tabs [alited::bar::BAR listTab]
  }
  foreach tab $tabs {
    set wtxt [alited::main::GetWTXT [lindex $tab 0]]
    set al(HL,$wtxt) {..}
  }
}

#_______________________

proc file::ToBeHighlighted {wtxt} {
  # Checks flag "highlight text anyway".
  #   wtxt - text's path

  namespace upvar ::alited al al
  return [expr {![info exists al(HL,$wtxt)] || $al(HL,$wtxt) eq {..}}]
}
#_______________________

proc file::FileAttrs {TID} {
  # Returns a file attributes: name & time.
  #   TID - tab's ID

  namespace upvar ::alited al al
  set fname [alited::bar::FileName $TID]
  lassign [alited::bar::BAR $TID cget --mtime --mtimefile] mtime mtimefile
  set isfile [file exists $fname]
  if {$isfile} {
    set curtime [file mtime $fname]
  } elseif {$fname ne $al(MC,nofile)} {
    set curtime ?
  } else {
    set curtime {}
  }
  return [list $fname $isfile $mtime $mtimefile $curtime]
}
#_______________________

proc file::OutwardChange {TID {docheck yes}} {
  # Checks for change of file by an external application.
  #   TID - ID of tab
  #   docheck - yes for "do check", no for "just save the file's mtime"

  namespace upvar ::alited al al
  lassign [FileAttrs $TID] fname isfile mtime mtimefile curtime
  if {$docheck && $mtime ne {} && $curtime ne $mtime && $fname eq $mtimefile} {
    if {$isfile} {
      set msg [string map [list %f [file tail $fname]] $al(MC,modiffile)]
    } else {
      set msg [string map [list %f [file tail $fname]] $al(MC,wasdelfile)]
    }
    # at any answer, the tab should be marked as "modified"
    alited::bar::BAR markTab $TID
    alited::edit::CheckSaveIcons yes
    if {[alited::msg yesno warn $msg YES -title $al(MC,saving)]} {
      if {$isfile} {
        set wtxt [alited::main::GetWTXT $TID]
        set pos [$wtxt index insert]
        DisplayFile $TID $fname $wtxt yes
        alited::main::UpdateAll
        catch {
          ::tk::TextSetCursor $wtxt $pos
          ::alited::main::CursorPos $wtxt
        }
      } else {
        alited::bar::BAR $TID configure --mtime {}
        SaveFileAs $TID
        if {[catch {set curtime [file mtime $fname]}]} {set curtime {}}
      }
    }
    set do_update_tree yes
  }
  lassign [FileAttrs $TID] fname isfile mtime mtimefile curtime
  alited::bar::BAR $TID configure --mtime $curtime --mtimefile $fname \
    -tip [FileStat $fname]
  if {[info exists do_update_tree]} {
    ::alited::tree::RecreateTree {} $fname
  }
}
#_______________________

proc file::IsTcl {fname} {
  # Checks if a file is of Tcl.
  #   fname - file name

  if {[string tolower [file extension $fname]] in $alited::al(TclExtensions)} {
    return yes
  }
  return no
}
#_______________________

proc file::IsClang {fname} {
  # Checks if a file is of C/C++.
  #   fname - file name

  if {[string tolower [file extension $fname]] in $alited::al(ClangExtensions)} {
    return yes
  }
  return no
}
#_______________________

proc file::IsUnitFile {fname} {
  # Checks if a file has a unit tree.
  #   fname - file name

  return [expr {[IsTcl $fname]}]
}
#_______________________

proc file::ReadFileByTID {TID {getcont no}} {
  # Reads a file of tab, if needed.
  #   TID - ID of the tab
  #   getcont - if yes, returns a content of the file

  namespace upvar ::alited al al
  if {![info exist al(_unittree,$TID)]} {
    return [ReadFile $TID [alited::bar::FileName $TID]]
  }
  if {$getcont} {
    set wtxt [alited::main::GetWTXT $TID]
    return [$wtxt get 1.0 "end - 1 chars"]
  }
}
#_______________________

proc file::FileSize {bsize} {
  # Formats a file's size.
  #   bsize - file size in bytes

  set res "$bsize bytes"
  set bsz $bsize
  foreach m {Kb Mb Gb Tb} {
    if {$bsz<1024} break
    set rsz [expr {$bsz/1024.0}]
    set res "[format %.1f $rsz] $m ($bsize bytes)"
    set bsz [expr {int($bsz/1024)}]
  }
  return $res
}
#_______________________

proc file::FileStat {fname} {
  # Gets a file's attributes: times & size.
  #   fname - file name
  # Returns a string with file name and attributes divided by \n.

  set res {}
  array set ares {}
  if {$alited::al(TREE,showinfo) && ![catch {file stat $fname ares}]} {
    set dtf "%D %T"
    set res "\n\
\nCreated: [clock format $ares(ctime) -format $dtf]\
\nModified: [clock format $ares(mtime) -format $dtf]\
\nAccessed: [clock format $ares(atime) -format $dtf]\
\nSize: [FileSize $ares(size)]"
  }
  return [append fname $res]
}
#_______________________

proc file::UpdateFileStat {} {
  # Updates tips in tab bar (file info).

  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    set fname [alited::bar::FileName $TID]
    alited::bar::BAR $TID configure -tip [FileStat $fname]
  }
}
#_______________________

proc file::WrapLines {} {
  # Switches wrap word mode for a current text.

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  if {[set al(wrapwords) [expr {[$wtxt cget -wrap] ne {word}}]]} {
    $wtxt configure -wrap word
  } else {
    $wtxt configure -wrap none
  }
}

# ________________________ Helpers _________________________ #

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
#_______________________

proc file::RenameFile {TID fname {doshow yes}} {
  # Renames a file.
  #   TID - ID of tab
  #   fname - file name
  #   doshow - flag "show the file's text"

  alited::bar::SetTabState $TID --fname $fname
  alited::bar::BAR $TID configure -text {} -tip {}
  set tab [alited::bar::UniqueListTab $fname]
  set sname [file tail $fname]
  alited::bar::BAR $TID configure -text $sname -tip [FileStat $fname]
  if {$doshow} {
    alited::bar::BAR $TID show
  }
}
#_______________________

proc file::DoRenameFileInTree {wtree ID fname name2} {
  # Performs renaming a current file in a file tree.
  #   wtree - file tree's path
  #   ID    - ID of the file in the file tree
  #   fname - old file name (full)
  #   name2 - new file name (tail)

  set fsplit [file split $fname]
  set fname2 [file join [file dirname $fname] $name2]
  if {[catch {file rename $fname $fname2} err]} {
    alited::msg ok err $err -text 1 -w 40 -h {5 7}
    return
  }
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    set fname1 [alited::bar::FileName $TID]
    if {$fname1 eq $fname} {
      RenameFile $TID $fname2 no
      break
    }
    set fsplit1 [file split $fname1]
    if {[string first $fsplit $fsplit1]==0} {
      set fname1 [file join $fname2 {*}[lrange $fsplit1 [llength $fsplit] end]]
      RenameFile $TID $fname1 no
    }
  }
  alited::bar::BAR draw
  RecreateFileTree
}
#_______________________

proc file::RenameFileInTree {{geo ""}} {
  # Renames a current file in a file tree.
  #   geo - geometry for dialogue

  namespace upvar ::alited al al obPav obPav obDl2 obDl2
  set wtree [$obPav Tree]
  set ID [$wtree selection]
  if {[llength $ID]!=1} {
    alited::Message [msgcat::mc {Select one file in the tree.}] 4
    return
  }
  set name [$wtree item $ID -text]
  set fname [lindex [$wtree item $ID -values] 1]
  lassign [$obDl2 input {} $al(MC,renamefile) [list \
    ent "{} {} {-w 32}" "$name"] \
    -head [msgcat::mc {File name:}] {*}$geo] res name2
  set name2 [string trim $name2]
  if {$res && $name2 ne {} && $name2 ne $name} {
    DoRenameFileInTree $wtree $ID $fname $name2
  }
}
#_______________________

proc file::CheckForNew {{docheck no}} {
  # Checks if there is a file in bar of tabs and creates "No name" tab, if no tab exists.
  #   docheck - if yes, does checking, if no - run itself with docheck=yes

  if {$docheck} {
    if {![llength [alited::bar::BAR listTab]]} {
      alited::file::NewFile
    }
  } else {
    after idle {::alited::file::CheckForNew yes}
  }
}

# ________________________ "File" menu _________________________ #

proc file::ReadFile {TID fname} {
  # Reads a file, creates its unit tree.
  #   TID - ID of tab
  #   fname - file name
  # Returns the file's contents.

  namespace upvar ::alited al al
  set filecont [::apave::readTextFile $fname]
  set al(_unittree,$TID) [alited::unit::GetUnits $TID $filecont]
  return $filecont
}
#_______________________

proc file::DisplayFile {TID fname wtxt doreload} {
  # Displays a file's contents.
  #   TID - ID of tab
  #   fname - file name
  #   wtxt - text widget's path
  #   doreload - if yes, forces reloading (at external changes of file)

  namespace upvar ::alited al al obPav obPav
  # this is most critical: displayed text should correspond to the tab
  if {$wtxt ne [alited::main::GetWTXT $TID]} {
    set errmsg "\n ERROR file::DisplayFile: \
      \n ($TID) $wtxt != [alited::main::GetWTXT $TID] \
      \n Please, notify alited's authors!\n"
    puts $errmsg
    return -code error $errmsg
  }
  # another critical point: read the file only at need
  if {$doreload || [set filecont [ReadFileByTID $TID yes]] eq {}} {
    # last check point: 0 bytes of the file => read it anyway
    set filecont [ReadFile $TID $fname]
  }
  $obPav displayText $wtxt $filecont
  $obPav makePopup $wtxt no yes
}
#_______________________

proc file::NewFile {} {
  # Handles "New file" menu item.

  namespace upvar ::alited al al
  if {[set TID [alited::bar::FileTID $al(MC,nofile)]] eq {}} {
    set TID [alited::bar::InsertTab $al(MC,nofile) $al(MC,nofile)]
  }
  alited::bar::BAR $TID show
}
#_______________________

proc file::OpenFile {{fnames ""} {reload no} {islist no}} {
  # Handles "Open file" menu item.
  #   fnames - file name (if not set, asks for it)
  #   reload - if yes, loads the file even if it has a "strange" extension
  #   islist - if yes, *fnames* is a file list
  # Returns the file's tab ID if it's loaded, or {} if not loaded.

  namespace upvar ::alited al al obPav obPav
  set al(filename) {}
  set chosen no
  if {$fnames eq {}} {
    set chosen yes
    set fnames [$obPav chooser tk_getOpenFile alited::al(filename) -multiple 1 \
      -initialdir [file dirname [alited::bar::CurrentTab 2]] -parent $al(WIN)]
    set fnames [lsort -decreasing $fnames]
  } elseif {!$islist} {
    set fnames [list $fnames]
  }
  set TID {}
  foreach fname $fnames {
    if {[file exists $fname]} {
      set exts $al(TclExtensions)
      append exts { } $al(ClangExtensions)
      set exts [string trim [string map {{ } {, } . {}} $exts]]
      append exts "\nhtml, htm, css, md, txt, sh, bat, ini"
      set ext [string tolower [string trim [file extension $fname] .]]
      set esp [split [string map [list { } {} \n ,] $exts] ,]
      if {!$reload && $ext ni $esp} {
        set msg [string map [list %f [file tail $fname] %s $exts] $al(MC,nottoopen)]
        if {![alited::msg yesno warn $msg NO]} {
          break
        }
      }
      if {[set TID [alited::bar::FileTID $fname]] eq {}} {
        # close  "no name" tab if it's the only one and not changed
        set tabs [alited::bar::BAR listTab]
        set tabm [alited::bar::BAR listFlag m]
        if {[llength $tabs]==1 && [llength $tabm]==0} {
          set tid [lindex $tabs 0 0]
          if {[alited::bar::FileName $tid] eq $al(MC,nofile)} {
            alited::bar::BAR $tid close
          }
        }
        # open new tab
        set tab [alited::bar::UniqueListTab $fname]
        set TID [alited::bar::InsertTab $tab [FileStat $fname]]
        alited::file::AddRecent $fname
      }
    }
  }
  if {$TID ne {} && $TID ne [alited::bar::CurrentTabID]} {
    alited::bar::BAR $TID show
  }
  RecreateFileTree
  return $TID
}
#_______________________

proc file::SaveFileByName {TID fname} {
  # Saves a file.
  #   TID - ID of tab
  #   fname - file name

  set wtxt [alited::main::GetWTXT $TID]
  set fcont [$wtxt get 1.0 "end - 1 chars"]  ;# last \n excluded
  if {![::apave::writeTextFile $fname fcont]} {
    alited::msg ok err [::apave::error $fname] -w 50 -text 1
    return 0
  }
  alited::edit::BackupFile $TID
  $wtxt edit modified no
  alited::edit::Modified $TID $wtxt
  alited::main::HighlightText $TID $fname $wtxt
  OutwardChange $TID no
  RecreateFileTree
  return 1
}
#_______________________

proc file::SaveFile {{TID ""}} {
  # Saves the current file.
  #   TID - ID of tab

  namespace upvar ::alited al al
  if {$TID eq {}} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  if {$fname in [list {} $al(MC,nofile)]} {
    return [SaveFileAs $TID]
  }
  set res [SaveFileByName $TID $fname]
  alited::ini::SaveCurrentIni "$res && $al(INI,save_onsave)"
  alited::main::ShowHeader yes
  alited::tree::RecreateTree {} $fname
  return $res
}
#_______________________

proc file::SaveFileAs {{TID ""}} {
  # Saves the current file "as".
  #   TID - ID of tab

  namespace upvar ::alited al al obPav obPav
  if {$TID eq {}} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  set alited::al(filename) [file tail $fname]
  if {$alited::al(filename) in [list {} $al(MC,nofile)]} {
    set alited::al(filename) {}
  }
  set fname [$obPav chooser tk_getSaveFile alited::al(filename) -title \
    [msgcat::mc {Save as}] -initialdir [file dirname $fname] -parent $al(WIN) \
    -defaultextension .tcl]
  if {$fname in [list {} $al(MC,nofile)]} {
    set res 0
  } elseif {[set res [SaveFileByName $TID $fname]]} {
    RenameFile $TID $fname
    alited::main::ShowHeader yes
    alited::tree::RecreateTree {} $fname
  }
  return $res
}
#_______________________

proc file::SaveFileAndClose {} {
  # Saves and closes the current file.
  # This handles pressing Ctrl+W.

  if {[IsModified] && ![SaveFile]} return
  alited::bar::BAR [alited::bar::CurrentTabID] close
}
#_______________________

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
# _______________________ Close file(s) _______________________ #

proc file::CloseFile {{TID ""} {checknew yes}} {
  # Closes a file.
  #   TID - tab's ID
  #   checknew - if yes, checks if new file's tab should be created
  # Returns 0, if a user selects "Cancel".

  namespace upvar ::alited al al obPav obPav
  set res 1
  if {$TID eq ""} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
  if {$TID ni {{-1} {}} && $wtxt ne {}} {
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
      destroy $wtxt
      destroy $wsbv
    }
    if {$checknew} CheckForNew
    alited::ini::SaveCurrentIni $al(INI,save_onclose)
    alited::tree::UpdateFileTree
  }
  if {$al(closefunc) != 1} {  ;# close func = 1 means "close all"
    alited::file::AddRecent $fname
  }
  return $res
}
#_______________________

proc file::CloseFileMenu {} {
  # Closes the current file from the menu.

  if {[set TID [alited::bar::CurrentTabID]] ne ""} {
    alited::bar::BAR $TID close
  }
}
#_______________________

proc file::CloseAll {func args} {
  # Closes files.
  #   func - "1/2/3" means closing "all/to left/to right"
  #   args - may contain -skipsel to not close selected tabs

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  set al(closefunc) $func ;# disables "recent files" at closing all
  alited::bar::BAR closeAll $::alited::al(BID) $TID $func {*}$args
  set al(closefunc) 0
  return [expr {[llength [alited::bar::BAR listFlag "m"]]==0}]
}
#_______________________

proc file::OpenFiles {} {
  # Opens files selected in the file tree.

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set fnames [list]
  foreach selID [$wtree selection] {
    lassign [$wtree item $selID -values] - fname isfile
    if {$isfile} {lappend fnames $fname}
  }
  OpenFile [lsort -decreasing -dictionary $fnames] no yes
}
#_______________________

# ________________________ File tree _________________________ #

proc file::RecreateFileTree {} {
  # Creates the file tree.

  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits)} {
    [$obPav Tree] selection set {}
    catch {after cancel $al(_AFT_RECR_)}
    set al(_AFT_RECR_) [after 100 ::alited::tree::RecreateTree]
  }
}
#_______________________

proc file::OpenOfDir {dname} {
  # Opens all Tcl files of a directory.
  #   dname - directory's name

  set msg [msgcat::mc "All Tcl files of this directory:\n  \"%f\"  \nwill be open.\n\nThis may be expensive!"]
  set msg [string map [list %f [file tail $dname]] $msg]
  if {[alited::msg okcancel warn $msg NO]} {
    if {![catch {set flist [glob -directory $dname *]}]} {
      set fnames [list]
      foreach fname [lsort -decreasing -dictionary $flist] {
        if {[file isfile $fname] && [IsTcl $fname]} {
          lappend fnames $fname
        }
      }
      OpenFile $fnames no yes
    }
  }
}
#_______________________

proc file::DoMoveFile {fname dname f1112 {addmsg {}}} {
  # Asks and moves a file to a directory.
  #   fname - file name
  #   dname - directory name
  #   f1112 - yes, if run by pressing F11/F12 keys
  #   addmsg - additional message (for external moves)

  namespace upvar ::alited al al
  if {[file isdirectory $fname]} {
    set msg [msgcat::mc {%f is a directory}]
    alited::Message [string map [list %f $fname] $msg] 4
    return
  }
  set tailname [file tail $fname]
  if {$f1112 || $addmsg ne {}} {
    set defb NO
    set geo ""
  } else {
    set defb YES
    set geo "-geometry pointer+10+10"
  }
  if {![info exists al(_ANS_MOVE_)] || $al(_ANS_MOVE_)!=11} {
    append addmsg [string map [list %f $tailname %d $dname] $al(MC,movefile)]
    set al(_ANS_MOVE_) [alited::msg yesno ques $addmsg \
      $defb -title $al(MC,moving) {*}$geo -ch "Don't ask again"]
    if {!$al(_ANS_MOVE_)} return
  }
  return [RemoveFile $fname $dname move]
}
#_______________________

proc file::MoveExternal {f1112} {
  # Moves an external file to a project's directory.
  #   f1112 - yes, if run by F11/F12 keys

  namespace upvar ::alited al al
  set fname [alited::bar::FileName]
  if {$al(prjroot) eq {} || [string first $al(prjroot) $fname]==0} {
    return no  ;# no project directory or the file is inside it
  }
  set addmsg [msgcat::mc {THE EXTERNAL FILE IS MOVED TO THE PROJECT!}]
  set fname2 [DoMoveFile $fname $al(prjroot) $f1112 "$addmsg\n\n"]
  alited::tree::RecreateTree {} $fname2
  alited::main::ShowHeader yes
  return yes
}
#_______________________

proc file::DropFiles {wtree fromIDs toID} {
  # Moves a group of selected files to other tree position.
  #   wtree - file tree widget
  #   fromIDs- tree IDs to move the file from
  #   toID - tree ID to move the file to
  # The destination position is freely chosen by "Drop here" menu item.

  if {![$wtree exists $toID]} return
  set dirname [lindex [$wtree item $toID -values] 1]
  if {![file isdirectory $dirname]} {
    set dirname [file dirname $dirname]
  }
  set movedfiles [list]
  foreach fromID $fromIDs {
    if {![$wtree exists $fromID]} continue
    set curfile [lindex [$wtree item $fromID -values] 1]
    lappend movedfiles $curfile
  }
  if {![llength $movedfiles]} return
  foreach curfile $movedfiles {
    if {[file isdirectory $curfile]} {
      if {$curfile ne $dirname} {
        alited::Message [msgcat::mc {Only files are moved by alited.}] 4
      }
      continue
    }
    if {[file dirname $curfile] ne $dirname} {
      lappend newnames [DoMoveFile $curfile $dirname yes]
    }
  }
  if {[info exists newnames]} {
    alited::tree::RecreateTree {} $newnames
    alited::main::ShowHeader yes
  }
}
#_______________________

proc file::MoveFiles {wtree to itemIDs f1112} {
  # Moves  file(s).
  #   wtree - file tree widget
  #   to - "move", "up" or "down" (direction of moving)
  #   itemIDs - file's tree IDs to be moved
  #   f1112 - yes for pressing F11/F12 or file's tree ID
  # For to=move, f1112 is a file's ID to be moved to.

  set tree [alited::tree::GetTree]
  set itemID [lindex $itemIDs 0]
  set idx [alited::unit::SearchInBranch $itemID $tree]
  if {$to eq {move}} {
    if {$idx>=0} {
      DropFiles $wtree $itemIDs $f1112
    }
    return
  }
  set curfile [alited::bar::FileName]
  set curdir [file dirname $curfile]
  set isexternal [expr {[string first [file normalize $alited::al(prjroot)] \
    [file normalize $curdir]]<0}]
  if {!$isexternal} {
    if {$idx<0} {bell; return}
    # the edited file is not external => try to move selected files of the tree
    lassign [$wtree item $itemID -values] -> curfile
    set curdir [file dirname $curfile]
  }
  if {$to eq {up}} {set ito 0} {set ito end}
  set selparent [$wtree parent [lindex $itemIDs $ito]]
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
    } elseif {$id ne $selparent && $fname ne $curdir} {
      set dirname $fname
      break
    }
  }
  if {$dirname eq {}} {
    if {$selparent ne {}} {
      set dirname $alited::al(prjroot)
    } else {
      bell
      return
    }
  }
  set movedfiles [list]
  if {$isexternal} {
    # this file is external to the project - ask to move it into the project
    lappend movedfiles [DoMoveFile $curfile $dirname $f1112]
  } else {
    set f1112 [expr {$f1112 || [llength $itemIDs]>1}]
    foreach ID $itemIDs {
      set curfile [lindex [$wtree item $ID -values] 1]
      lappend movedfiles [DoMoveFile $curfile $dirname $f1112]
    }
  }
  $wtree selection set {}
  alited::tree::RecreateTree {} $movedfiles
  alited::main::ShowHeader yes
}
#_______________________

proc file::RemoveFile {fname dname mode} {
  # Removes or backups a file, trying to save it in a directory.
  #   fname - file name
  #   dname - name of directory
  #   mode - if "move", then moves a file to a directory, otherwise backups it
  # Returns a destination file's name.

  namespace upvar ::alited al al
  set ftail [file tail $fname]
  set dtail [file tail $dname]
  set fname2 [file join $dname $ftail]
  if {[file exists $fname2]} {
    if {$mode eq "move"} {
      set msg [string map [list %f $ftail %d $dname] $al(MC,fileexist)]
      alited::msg ok warn $msg
      return {}
    }
    catch {file delete $fname2}
  }
  if {[catch {file copy $fname $dname} err]} {
    set msg [string map [list %f $ftail %d $dname] $al(MC,errcopy)]
    if {![alited::msg yesno warn "$err\n\n$msg" NO]} {return {}}
  }
  catch {file mtime $fname2 [file mtime $fname]}
  if {[catch {file delete $fname} err]} {
    alited::msg ok err "Error of deleting\n$fname\n\n$err"
  } else {
    alited::Message [string map [list %f $ftail %d $dtail] $al(MC,removed)]
    if {$mode eq "move" && [set TID [alited::bar::FileTID $fname]] ne {}} {
      alited::bar::SetTabState $TID --fname $fname2
      alited::bar::BAR $TID configure -tip [FileStat $fname2]
    }
  }
  return $fname2
}
#_______________________

proc file::Add {ID} {
  # Creates a file at the file tree.
  #   ID - tree item's ID

  namespace upvar ::alited al al obPav obPav obDl2 obDl2
  if {$ID eq {}} {set ID [alited::tree::CurrentItem]}
  set wtree [$obPav Tree]
  set dname [lindex [$wtree item $ID -values] 1]
  if {[file isdirectory $dname]} {
    set fname {}
  } else {
    set fname [file tail $dname]
    set dname [file dirname $dname]
  }
  set head [string map [list %d $dname] $al(MC,filesadd2)]
  while {1} {
    set res [$obDl2 input {} $al(MC,filesadd) [list \
      seh {{} {-pady 10}} {} \
      ent {{File name:} {} {-w 40}} "{$fname}" \
      chb [list {} {-padx 5} [list -toprev 1 -t Directory]] {0} ] \
      -head $head -family "{[::apave::obj basicTextFont]}"]
    lassign $res res fname isdir
    if {$res && $fname eq {}} bell else break
  }
  if {$res} {
    set fname [file join $dname $fname]
    if {[catch {
      if {$isdir} {
        file mkdir $fname
      } else {
        if {[file extension $fname] eq {}} {append fname .tcl}
        if {![file exists $fname]} {close [open $fname w]}
        OpenFile $fname
      }
      $wtree selection set {}
      alited::tree::RecreateTree
      if {$isdir} {
        # find the created directory
        foreach item [alited::tree::GetTree] {
          lassign $item - - ID - data
          if {[set dname [lindex $data 1]] eq $fname} {
            catch {$wtree selection remove [$wtree selection]}
            $wtree selection add $ID
            $wtree see $ID
            break
          }
        }
      }
    } err]} then {
      alited::msg ok err $err
    }
  }
}
#_______________________

proc file::Delete {ID wtree} {
  # Deletes a file at the file tree.
  #   ID - tree item's ID
  #   wtree file tree widget

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
    $wtree selection set {}
    alited::tree::RecreateTree
  }
}

# ________________________ Recent files _________________________ #


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
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
