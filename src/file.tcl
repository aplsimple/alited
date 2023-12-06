###########################################################
# Name:    file.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/29/2021
# Brief:   Handles files and file tree.
# License: MIT.
###########################################################

#package require control

namespace eval file {
  variable ansSave 0
  variable ansOpen 0
  variable firstSave -1
  variable ansOpenOfDir 0
}

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

proc file::IsSaved {TID args} {
  # Checks if a file is modified and if yes, offers to save it.
  #   TID - ID of tab
  #   args - options of dialogue
  # The appearance of dialogue is controled by $ansSave and $firstSave:
  #   if $ansSave>10, no dialogue at all, meaning the answer = $ansSave
  #   if $firstSave==-1, no "No ask anymore" (if run by "Close" menu item or "x" icon of tabbar)
  # Returns 1 for "yes, needs saving", 2 - "no saving", 0 - "cancel".

  variable ansSave
  variable firstSave
  namespace upvar ::alited al al
  if {[IsModified $TID]} {
    set fname [alited::bar::BAR $TID cget -text]
    if {$ansSave<10} {
      if {$firstSave==-1} {
        set ch {}
      } else {
        # the option for "save/not save other changed files, without further questions"
        set ch [list -ch $al(MC,noask)]
      }
      set ansSave [alited::msg yesnocancel warn [string map [list %f $fname] \
        $al(MC,notsaved)] YES -title $al(MC,saving) {*}$ch {*}$args]
    }
    return $ansSave
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
    if {[set wtxt [alited::main::GetWTXT [lindex $tab 0]]] ne {}} {
      set al(HL,$wtxt) {..}
    }
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
  if {[winfo exists .em] || [info exists al(_NO_OUTWARD_)]} {
    return  ;# no actions if "internal" e_menu is open
  }
  if {$docheck && $TID ne [alited::bar::CurrentTabID]} {
    return  ;# not a current tab: no questions
  }
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
    lassign [FileAttrs $TID] fname isfile mtime mtimefile curtime
  }
  alited::bar::BAR $TID configure --mtime $curtime --mtimefile $fname \
    -tip [FileStat $fname]
  if {[info exists do_update_tree]} {
    if {$al(TREE,isunits)} {set fname {}}
    ::alited::tree::RecreateTree {} $fname
  }
}
#_______________________

proc file::IsTcl {fname} {
  # Checks if a file is of Tcl.
  #   fname - file name

  if {[string tolower [file extension $fname]] in $::alited::al(TclExts)} {
    return yes
  }
  return no
}
#_______________________

proc file::IsClang {fname} {
  # Checks if a file is of C/C++.
  #   fname - file name

  if {[string tolower [file extension $fname]] in $::alited::al(ClangExts)} {
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
  if {$::alited::al(TREE,showinfo) && ![catch {file stat $fname ares}]} {
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

proc file::SbhText {} {
  # Shows/hides the horizontal scrollbar of the text.

  namespace upvar ::alited al al obPav obPav
  if {[info exist al(isSbhText)]} {
    set wtxt [alited::main::CurrentWTXT]
    set wfra [$obPav FraSbh]
    set wsbh [$obPav SbhText]
    set wrap [$wtxt cget -wrap]
    if {$wrap eq {word}} {
      if {$al(isSbhText)} {pack forget $wfra}
      set al(isSbhText) no
    } else {
      if {!$al(isSbhText)} {
        if {![info exist al(isfindunit)] || !$al(isfindunit)} {
          pack $wfra -side bottom -fill x -after [$obPav GutText]
        } else {
          pack forget [$obPav FraHead]
          pack $wfra -side bottom -fill x -after [$obPav GutText]
          pack [$obPav FraHead] -side bottom -fill x -pady 3 -after [$obPav GutText]
        }
      }
      $wtxt configure -xscrollcommand "$wsbh set"
      $wsbh configure -command "$wtxt xview"
      set al(isSbhText) yes
    }
  }
}
#_______________________

proc file::WrapLines {{wrapnone no}} {
  # Switches wrap word mode for a current text.
  #  wrapnone - yes, if 'none' wrapping is needed

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  set al(wrapwords) [expr {!$wrapnone && [$wtxt cget -wrap] ne {word}}]
  if {$al(wrapwords)} {
    $wtxt configure -wrap word
  } else {
    $wtxt configure -wrap none
  }
  if {![info exist al(isSbhText)]} {set al(isSbhText) no}
  SbhText
}
#_______________________

proc file::Encoding {{fname ""} {enc ""}} {
  # Gets/sets a file's encoding.
  #   fname - file's name
  #   enc - if "", gets the encoding, otherwise sets the encoding of the file.

  namespace upvar ::alited al al
  if {$fname eq {}} {set fname [alited::bar::FileName]}
  if {$enc ne {}} {
    set al(ENCODING,$fname) $enc
  } else {
    if {[info exists al(ENCODING,$fname)]} {
      set enc [list -encoding $al(ENCODING,$fname)]
    } else {
      set enc {}
    }
  }
  return $enc
}
#_______________________

proc file::EOL {{fname ""} {eol ""}} {
  # Gets/sets a file's translation.
  #   fname - file's name
  #   eol - if "", gets the translation, otherwise sets the translation of the file.

  namespace upvar ::alited al al
  if {$fname eq {}} {set fname [alited::bar::FileName]}
  if {$eol ne {}} {
    set al(EOL,$fname) $eol
  } else {
    if {[info exists al(EOL,$fname)]} {
      set eol [list -translation $al(EOL,$fname)]
    } else {
      set eol {}
    }
  }
  return $eol
}

# ________________________ Helpers _________________________ #

proc file::AllSaved {} {
  # Checks whether all files are saved. Saves them if not.

  variable ansSave
  variable firstSave
  set ansSave 0
  set firstSave 1
  set res 1
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    switch [IsSaved $TID] {
      0 { ;# "Cancel" chosen for a modified
        set res 0
        break
      }
      1 - 11 { ;# "Save" chosen for a modified
        if {![set res [SaveFile $TID yes]]} break
      }
    }
  }
  set ansSave 0
  set firstSave -1
  return $res
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
    alited::bar::BAR $TID show yes
  }
}
#_______________________

proc file::DoRenameFileInTree {wtree ID fname fname2} {
  # Performs renaming a current file in a file tree.
  #   wtree - file tree's path
  #   ID    - ID of the file in the file tree
  #   fname - old file name (full)
  #   fname2 - new file name (full)

  set fsplit [file split $fname]
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

proc file::RenameFileInTree {{undermouse yes} args} {
  # Renames a current file in a file tree.
  #   undermouse - if yes, run by mouse click
  #   args - options for query

  namespace upvar ::alited al al obPav obPav obDl2 obDl2
  set wtree [$obPav Tree]
  set ID [$wtree selection]
  if {[llength $ID]!=1} {
    alited::msg ok err [msgcat::mc {Select one file in the tree.}]
    return
  }
  set name [$wtree item $ID -text]
  set fname [lindex [$wtree item $ID -values] 1]
  switch -exact -- $args {
    {} {
      set args [alited::favor::GeoForQuery $undermouse]
    }
    - {
      set args {}
    }
  }
  lassign [$obDl2 input {} $al(MC,renamefile) [list \
    ent "{} {} {-w 32}" "{$name}"] \
    -head [msgcat::mc {File name:}] {*}$args] res name2
  set name2 [string trim $name2]
  if {$res && $name2 ne {} && $name2 ne $name} {
    set fname2 [file join [file dirname $fname] $name2]
    DoRenameFileInTree $wtree $ID $fname $fname2
    alited::tree::RecreateTree $wtree -
    set ltree [alited::tree::GetTree]
    set i [lsearch -exact -index {4 1} $ltree $fname2]
    if {$i>-1} {set ID [lindex $ltree $i 2]}
    SelectInTree $wtree $ID
  }
}
#_______________________

proc file::CheckForNew {{docheck no}} {
  # Checks if there is a file in bar of tabs and creates "No name" tab, if no tab exists.
  #   docheck - if yes, does checking, if no - run itself with docheck=yes
  # See also: project::Ok

  namespace upvar ::alited al al
  if {$docheck} {
    if {![llength [alited::bar::BAR listTab]] && ![info exists al(project::Ok)]} {
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
  set enc [Encoding $fname]
  append enc { } [EOL $fname]
  set filecont [::apave::readTextFile $fname {} 0 {*}$enc]
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
  #control::assert {$wtxt eq [alited::main::GetWTXT $TID]}
  if {$wtxt ne [alited::main::GetWTXT $TID]} {
    puts [set msg "\n ERROR file::DisplayFile: \
      \n ($TID) $wtxt != [alited::main::GetWTXT $TID] \
      \n Please, notify alited's authors!\n"]
    return -code error $msg
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

proc file::NewFile {{fname ""}} {
  # Handles "New file" menu item.
  #   fname - a file name

  namespace upvar ::alited al al
  if {[set TID [alited::bar::FileTID $al(MC,nofile)]] eq {}} {
    if {$fname eq {}} {
      set tab [set fname $al(MC,nofile)]
    } else {
      set tab [alited::bar::UniqueListTab $fname]
      set fname [alited::file::FileStat $fname]
    }
    set TID [alited::bar::InsertTab $tab $fname]
  }
  alited::bar::BAR $TID show
}
#_______________________

proc file::OpenFile {{fnames ""} {reload no} {islist no} {Message {}}} {
  # Handles "Open file" menu item.
  #   fnames - file name (if not set, asks for it)
  #   reload - if yes, loads the file even if it has a "strange" extension
  #   islist - if yes, *fnames* is a file list
  #   Message - name of procedure for "open file" message
  # Returns the file's tab ID if it's loaded, or {} if not loaded.

  namespace upvar ::alited al al obPav obPav
  variable ansOpen
  set chosen no
  if {$fnames eq {}} {
    set al(TMPfname) {}
    set chosen yes
    set fnames [$obPav chooser tk_getOpenFile ::alited::al(TMPfname) -multiple 1 \
      -initialdir [file dirname [alited::bar::CurrentTab 2]] -parent $al(WIN)]
    if {$al(lifo)} {set fnames [lsort -decreasing $fnames]}
    unset al(TMPfname)
  } elseif {!$islist} {
    set fnames [list $fnames]
  }
  if {[set llen [llength $fnames]]==0} {return {}}
  set TID {}
  set many [expr {$llen>1}]
  foreach fname $fnames {
    if {[file exists $fname]} {
      set exts $al(TclExts)
      append exts { } $al(ClangExts)
      append exts { } $al(TextExts)
      set sexts [string map {. {}} "  $al(TclExts)\n  $al(ClangExts)\n  $al(TextExts)"]
      set exts [string trim [string map {{ } {, } . {}} $exts]]
      lassign [alited::ExtTrans $fname] ext istrans
      set ext [string tolower [string trim $ext .]]
      set esp [split [string map [list { } {} \n ,] $exts] ,]
      if {!$reload && $ext ni $esp && !$istrans && $ansOpen<11} {
        set msg [string map [list %f [file tail $fname] %s $sexts] $al(MC,nottoopen)]
        set ansOpen [alited::msg yesnocancel warn $msg YES -ch $al(MC,noask)]
        if {!$ansOpen || $ansOpen==12} break
        if {$ansOpen==2} continue
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
        if {$Message ne {}} {
          $Message "[msgcat::mc {Open file:}] $fname"
        }
      } elseif {$al(lifo)} {
        # in -lifo mode: move all open files to 1st position
        # (but if it's one file to be move, then only if it's not visible)
        if {(![alited::bar::BAR $TID visible] && !$many) || $many} {
          if {$many} {
            alited::bar::BAR moveTab $TID 0  ;# one tab is shown by "show" method below
          }
          set many yes
        }
      }
    }
  }
  if {$TID ne {} && ($al(lifo) || $TID ne [alited::bar::CurrentTabID])} {
    alited::bar::BAR $TID show $many $many
  }
  RecreateFileTree
  if {$chosen} {
    after idle {focus -force [alited::main::CurrentWTXT]}
  }
  return $TID
}
#_______________________

proc file::SaveFileByName {TID fname {doit no}} {
  # Saves a file.
  #   TID - ID of tab
  #   fname - file name
  #   doit - flag "do save now, without any GUI"

  namespace upvar ::alited al al
  if {[info exists al(THIS-ENCODING)]} {
    set enc "-encoding $al(THIS-ENCODING)" ;# at saving "no name"
  } else {
    set enc [Encoding $fname]
  }
  if {[info exists al(THIS-EOL)]} {
    set eol "-translation $al(THIS-EOL)" ;# at saving "no name"
  } else {
    set eol [EOL $fname]
  }
  append enc " $eol"
  set al(_NO_OUTWARD_) {}
  set wtxt [alited::main::GetWTXT $TID]
  if {$al(prjtrailwhite)} {alited::edit::RemoveTrailWhites $TID yes $doit}
  set fcont [$wtxt get 1.0 "end - 1 chars"]  ;# last \n excluded
  if {![::apave::writeTextFile $fname fcont 0 1 {*}$enc]} {
    alited::msg ok err [::apave::error $fname] -w 50 -text 1
    unset al(_NO_OUTWARD_)
    return 0
  }
  unset al(_NO_OUTWARD_)
  OutwardChange $TID no
  alited::edit::BackupFile $TID
  if {!$doit} {
    $wtxt edit modified no
    alited::edit::Modified $TID $wtxt
    alited::main::HighlightText $TID $fname $wtxt
    RecreateFileTree
  }
  return 1
}
#_______________________

proc file::SaveFile {{TID ""} {doit no}} {
  # Saves the current file.
  #   TID - ID of tab
  #   doit - flag "do save now, without any GUI"
  # See also: ini::SaveCurrentIni

  namespace upvar ::alited al al
  if {$TID eq {}} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  if {[IsNoName $fname]} {
    return [SaveFileAs $TID]
  }
  set res [SaveFileByName $TID $fname $doit]
  alited::ini::SaveCurrentIni "$res && $al(INI,save_onsave)" $doit
  if {!$doit} {
    alited::main::ShowHeader yes
    if {$al(TREE,isunits)} {set fname {}}
    alited::tree::RecreateTree {} $fname
    alited::tree::SeeSelection
  }
  return $res
}
#_______________________

proc file::SaveFileAs {{TID ""}} {
  # Saves the current file "as".
  #   TID - ID of tab

  namespace upvar ::alited al al obPav obPav
  if {$TID eq {}} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::FileName $TID]
  set ::alited::al(TMPfname) [file tail $fname]
  if {[IsNoName $fname]} {
    set ::alited::al(TMPfname) {}
    set defext .tcl
    set inidir $al(prjroot)
  } else {
    set defext [file extension $fname]
    set inidir [file dirname $fname]
  }
  set fname [$obPav chooser tk_getSaveFile ::alited::al(TMPfname) -initialdir $inidir \
    -defaultextension $defext -title [msgcat::mc {Save as}] -parent $al(WIN)]
  unset al(TMPfname)
  if {[IsNoName $fname]} {
    set res 0
  } elseif {[set res [SaveFileByName $TID $fname]]} {
    RenameFile $TID $fname
    alited::main::ShowHeader yes
    alited::edit::MacroUpdate $fname
    if {$al(TREE,isunits)} {set fname {}}
    alited::tree::RecreateTree {} $fname
    alited::tree::SeeSelection
  }
  return $res
}
#_______________________

proc file::SaveAndClose {} {
  # Saves and closes the current file.
  # This handles pressing Ctrl+W.
  # Returns yes if the file was closed.

  if {[IsModified] && ![SaveFile]} {return no}
  set fname [lindex $::alited::bar::ctrltablist 1]
  alited::bar::BAR [alited::bar::CurrentTabID] close
  # go to a previously viewed file
  if {[set TID [alited::bar::FileTID $fname]] ne {}} {
    alited::bar::BAR $TID show
  }
  return yes
}
#_______________________

proc file::CloseAndDelete {} {
  # Closes and deletes the current file.

  namespace upvar ::alited al al
  set fname [alited::bar::FileName]
  if {[IsNoName $fname]} {
    # for a new file: to save first if modified (to think twice)
    if {[IsModified]} {SaveFile} else {SaveAndClose}
    return
  }
  set msg [string map [list %f [file tail $fname]] $al(MC,delfile)]
  if {[alited::msg yesno warn $msg NO]} {
    # to save first (for normal closing only)
    if {[SaveAndClose]} {
      DeleteFile $fname
      if {!$al(TREE,isunits)} {alited::tree::RecreateTree {} {} yes}
      alited::edit::MacroUpdate $fname
    }
  }
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
#_______________________

proc file::Reload1 {eol} {
  # Reloads a current file with EOL.
  #   eol - the end of line

  namespace upvar ::alited al al
  set eol [string trim $eol]
  set wtxt [alited::main::CurrentWTXT]
  set TID [alited::bar::CurrentTabID]
  set fname [alited::bar::FileName]
  set dosave no
  if {[IsNoName $fname]} {
    set dosave yes
  } elseif {[IsModified]} {
    if {![info exists al(EOLASKED)] || $al(EOLASKED)<10} {
      set msg [msgcat::mc "Save the file:\n%F ?"]
      set msg [string map [list %F $fname] $msg]
      set al(EOLASKED) [alited::msg yesnocancel warn $msg CANCEL -ch $al(MC,noask)]
      if {!$al(EOLASKED)} return
      if {$al(EOLASKED) in {1 11}} {set dosave yes}
    }
    $wtxt edit modified no
    alited::edit::Modified $TID $wtxt
  }
  if {$dosave} {
    set al(THIS-EOL) $eol
    set dosave [SaveFile]
    unset al(THIS-EOL)
    if {!$dosave} return
  }
  set fname [alited::bar::FileName]
  set pos [$wtxt index insert]
  EOL $fname $eol
  DisplayFile $TID $fname $wtxt yes
  catch {::tk::TextSetCursor $wtxt $pos}
  alited::main::UpdateProjectInfo
  alited::main::UpdateAll
}
#_______________________

proc file::Reload2 {enc} {
  # Reloads a current file with an encoding.
  #   enc - the encoding

  namespace upvar ::alited al al
  lassign [split $enc] enc
  set wtxt [alited::main::CurrentWTXT]
  set TID [alited::bar::CurrentTabID]
  set fname [alited::bar::FileName]
  set dosave no
  if {[IsNoName $fname]} {
    set dosave yes
  } elseif {[IsModified]} {
    if {![info exists al(ENCODINGASKED)] || $al(ENCODINGASKED)<10} {
      set msg [msgcat::mc \
        "Saving and reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nSave the file:\n%F ?"]
      set msg [string map [list %e $enc %f [file tail $fname] %F $fname] $msg]
      set al(ENCODINGASKED) [alited::msg yesnocancel warn $msg CANCEL -ch $al(MC,noask)]
      if {!$al(ENCODINGASKED)} return
      if {$al(ENCODINGASKED) in {1 11}} {set dosave yes}
    }
    $wtxt edit modified no
    alited::edit::Modified $TID $wtxt
  } else {
    if {![info exists al(ENCODINGASKED2)] || $al(ENCODINGASKED2)<10} {
      set msg [msgcat::mc \
        "Reloading \"%f\"\nwith the encoding \"%e\" may turn out to be wrong.\n\nReload the file:\n%F ?"]
      set msg [string map [list %e $enc %f [file tail $fname] %F $fname] $msg]
      set al(ENCODINGASKED2) [alited::msg yesno warn $msg YES -ch $al(MC,noask)]
      if {!$al(ENCODINGASKED2)} return
    }
  }
  if {$dosave} {
    set al(THIS-ENCODING) $enc
    set dosave [SaveFile]
    unset al(THIS-ENCODING)
    if {!$dosave} return
  }
  set fname [alited::bar::FileName]
  set pos [$wtxt index insert]
  Encoding $fname $enc
  DisplayFile $TID $fname $wtxt yes
  catch {::tk::TextSetCursor $wtxt $pos}
  alited::main::UpdateProjectInfo
  alited::main::UpdateAll
}

# _______________________ Close file(s) _______________________ #

proc file::CloseFile {TID checknew args} {
  # Closes a file.
  #   TID - tab's ID
  #   checknew - if yes, checks if new file's tab should be created
  #   args - arguments added by bartabs
  # Returns 0, if a user selects "Cancel".

  namespace upvar ::alited al al obPav obPav
  variable ansSave
  variable firstSave
  lassign [::apave::extractOptions args -withicon 0 -first -1] withicon first
  if {$withicon || $first} {
    set ansSave 0
    set nmark [llength [alited::bar::BAR listFlag "m"]]
    if {$nmark<2 || $withicon} {
      set firstSave -1
      if {$withicon} {lappend args -geometry pointer+-100+20}
    } else {
      set firstSave $first ;# controls "No ask anymore" checkbox at questions
    }
  }
  set res 1
  set fname [alited::bar::FileName $TID]
  lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
  if {$TID ni {{-1} {}} && $wtxt ne {}} {
    switch [IsSaved $TID {*}$args] {
      0 { ;# "Cancel" chosen for a modified
        return 0
      }
      1 - 11 { ;# "Save" chosen for a modified
        set res [SaveFile $TID]
      }
    }
    if {$wtxt ne [$obPav Text]} { ;# let [$obPav Text] be alive, as needed by 'pack'
      destroy $wtxt $wsbv
    }
    if {$checknew} CheckForNew
    alited::ini::SaveCurrentIni $al(INI,save_onclose)
    after 9999 [list alited::file::ClearupOnClose $TID $wtxt $fname]
  }
  alited::tree::UpdateFileTree
  if {$al(closefunc) != 1} {  ;# close func = 1 means "close all"
    alited::file::AddRecent $fname
  }
  after idle [list alited::bar::RenameTitles $TID]
  return $res
}
#_______________________

proc file::ClearupAlTag {tag tab} {
  # Clears *al* array of *tag,tab* data.
  #   tag - the tag
  #   tab - the tab's pattern

  namespace upvar ::alited al al
  foreach n [array names al $tag,$tab] {unset al($n)}
}
#_______________________

proc file::ClearupOnClose {TID wtxt fname} {
  # Clearance after closing a file.
  #   TID - tab's ID
  #   wtxt - text's path
  #   fname - file name

  namespace upvar ::alited al al obPav obPav
  $obPav fillGutter $wtxt
  catch {if {[IsClang $fname]} {::hl_c::clearup $wtxt} {::hl_tcl::clearup $wtxt}}
  unset -nocomplain al(_unittree,$TID)
  ClearupAlTag HL *_$TID
  ClearupAlTag _INDENT_ *_$TID
  ClearupAlTag CPOS *$TID,*
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
  variable ansSave
  set ansSave 0
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

# ________________________ File tree _________________________ #

proc file::RecreateFileTree {} {
  # Creates the file tree.

  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits) && ![winfo exists $::alited::project::win]} {
    [$obPav Tree] selection set {}
    catch {after cancel $al(_AFT_RECR_)}
    set al(_AFT_RECR_) [after 100 ::alited::tree::RecreateTree]
  }
}
#_______________________

proc file::OpenOfDir {dname} {
  # Opens all Tcl files of a directory.
  #   dname - directory's name

  namespace upvar ::alited al al
  variable ansOpenOfDir
  set msg [msgcat::mc "All Tcl files of this directory:\n  \"%f\"  \nwill be open. This may be expensive!"]
  set msg [string map [list %f [file tail $dname]] $msg]
  if {$ansOpenOfDir<11} {
    set ansOpenOfDir [alited::msg okcancel warn $msg OK -ch $al(MC,noask)]
  }
  if {$ansOpenOfDir} {
    if {![catch {set flist [glob -directory $dname *]}]} {
      set fnames [list]
      foreach fname [lsort -decreasing -dictionary $flist] {
        if {[file isfile $fname] && [IsTcl $fname]} {
          lappend fnames $fname
        }
      }
      OpenFile $fnames no yes
      after idle {focus -force [alited::main::CurrentWTXT]}
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
      $defb -title $al(MC,moving) {*}$geo -ch $al(MC,noask)]
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
  set fname [DoMoveFile $fname $al(prjroot) $f1112 "$addmsg\n\n"]
  alited::tree::RecreateTree {} $fname
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
      if {[set name [DoMoveFile $curfile $dirname yes]] ne {}} {
        lappend newnames $name
      }
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
  set isexternal [expr {[string first [file normalize $::alited::al(prjroot)] \
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
      set dirname $::alited::al(prjroot)
    } else {
      bell
      return
    }
  }
  if {$isexternal} {
    # this file is external to the project - ask to move it into the project
    if {[set name [DoMoveFile $curfile $dirname $f1112]] ne {}} {
      lappend movedfiles $name
    }
  } else {
    set f1112 [expr {$f1112 || [llength $itemIDs]>1}]
    foreach ID $itemIDs {
      set curfile [lindex [$wtree item $ID -values] 1]
      if {[set name [DoMoveFile $curfile $dirname $f1112]] ne {}} {
        lappend movedfiles $name
      }
    }
  }
  if {[info exists movedfiles]} {
    $wtree selection set {}
    alited::tree::RecreateTree {} $movedfiles
    alited::main::ShowHeader yes
  }
}
#_______________________

proc file::DeleteFile {fname} {
  # Deletes a file.
  #  fname - file name

  if {[catch {file delete $fname} err]} {
    alited::msg ok err "Error of deleting\n$fname\n\n$err"
    return no
  }
  return yes
}
#_______________________

proc file::RemoveFile {fname dname mode} {
  # Removes or backups a file, trying to save it in a directory.
  #   fname - file name
  #   dname - name of directory
  #   mode - if "move", then moves a file to a directory, otherwise backups it
  # Returns a destination file's name or {} if error.

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
    # more zeal than sense: to show $err here
  }
  catch {file mtime $fname2 [file mtime $fname]}
  if {![DeleteFile $fname]} {
    return {}
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
      alited::tree::RecreateTree $wtree -
      if {$isdir} {
        # find the created directory
        foreach item [alited::tree::GetTree] {
          lassign $item - - ID - data
          if {[set dname [lindex $data 1]] eq $fname} {
            catch {$wtree selection remove [$wtree selection]}
            SelectInTree $wtree $ID
            break
          }
        }
      }
    } err]} then {
      alited::msg ok err $err
    }
    if {!$isdir} {after 200 alited::main::FocusText}
  }
}
#_______________________

proc file::DeleteOne {ID wtree dlg dlgopts res} {
  # Deletes a file at the file tree.
  #   ID - tree item's ID
  #   wtree - file tree widget
  #   dlg - dialogue's type (yesno / yesnocancel)
  #   dlgopts - dialogue's options
  #   res - previous answer
  # Returns 1 for deleted, -1 for not deleted, 0 for error/cancel

  namespace upvar ::alited al al BAKDIR BAKDIR
  set name [$wtree item $ID -text]
  set fname [lindex [$wtree item $ID -values] 1]
  set TID [alited::bar::FileTID $fname]
  if {$TID ne ""} {
    bell
    alited::bar::BAR $TID show no no
    alited::msg ok warn "$al(MC,nodelopen)\n$fname"
    return 0
  }
  set msg [string map [list %f $name] $al(MC,delfile)]
  if {$res<11} {
    set res [alited::msg $dlg ques $msg NO {*}$dlgopts]
  }
  switch $res {
    1 - 11 {
      if {[RemoveFile $fname $BAKDIR backup] eq {}} {
        set res 0
      }
    }
  }
  return $res
}
#_______________________

proc file::Delete {ID wtree sy} {
  # Deletes file(s) at the file tree.
  #   ID - tree item's ID
  #   wtree - file tree widget
  #   sy - relative Y-coordinate for a query

  namespace upvar ::alited al al
  set wasdel 0
  set selection [$wtree selection]
  if {[llength $selection]>1} {
    set dlg yesnocancel
    set dlgopts [list -ch $al(MC,noask)]
  } else {
    set dlg yesno
    set dlgopts [alited::tree::syOption $sy]
    set selection $ID
  }
  set ltree [alited::tree::GetTree]
  set id1 [lindex $selection 0]
  set in1 [lsearch -exact -index 2 $ltree $id1]
  set ans 1
  foreach id $selection {
    set ans [DeleteOne $id $wtree $dlg $dlgopts $ans]
    switch $ans {
      1 - 11 {set wasdel 1; $wtree delete $id}
      0 - 12 break
    }
  }
  if {$wasdel} {
    set ltree [alited::tree::GetTree]
    if {$in1>=[llength $ltree]} {set in1 end}
    set id1 [lindex $ltree $in1 2]
    $wtree selection set {}
    SelectInTree $wtree $id1
  }
}
#_______________________

proc file::SelectInTree {wtree id} {
  # Selects an item in the file tree.
  #   wtree - file tree widget
  #   id - item's id

  catch {
    $wtree selection add $id
    $wtree see $id
  }
  after idle [list after 200 \
    "catch {focus $wtree ;  $wtree selection set $id ; $wtree focus $id}"]
}

# ________________________ Recent files _________________________ #

proc file::FillRecent {{delit ""}} {
  # Creates "Recent Files" menu items.
  #   delit - index of Recent Files item to be deleted

  namespace upvar ::alited al al
  if {[string is integer -strict $delit] && \
  $delit>-1 && $delit<[llength $al(RECENTFILES)]} {
    set al(RECENTFILES) [lreplace $al(RECENTFILES) $delit $delit]
  }
  set m $al(MENUFILE).recentfiles
  $m configure -tearoff 0
  $m delete 0 end
  if {[llength $al(RECENTFILES)]} {
    $al(MENUFILE) entryconfigure 2 -state normal
    foreach rf $al(RECENTFILES) {
      $m add command -label $rf -command "alited::file::ChooseRecent {$rf}"
    }
  } else {
    $al(MENUFILE) entryconfigure 2 -state disabled
  }
  $m configure -tearoff 1
}
#_______________________

proc file::InsertRecent {fname pos} {
  namespace upvar ::alited al al
  if {![IsNoName $fname]} {
    ::alited::PushInList al(RECENTFILES) $fname $pos $al(INI,RECENTFILES)
  }
}

proc file::AddRecent {fname} {
  namespace upvar ::alited al al
  InsertRecent $fname 0
  FillRecent
}

proc file::ChooseRecent {fname} {
  namespace upvar ::alited al al
  AddRecent $fname
  if {[OpenFile $fname] eq {} && ![file exists $fname]} {
    FillRecent 0
    alited::Balloon1 $fname
  }
}

# _________________________________ EOF _________________________________ #
