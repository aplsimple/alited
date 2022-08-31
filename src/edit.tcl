###########################################################
# Name:    edit.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    08/29/2021
# Brief:   Handles editing procedures.
# License: MIT.
###########################################################


namespace eval edit {}
# ________________________ Indent _________________________ #

proc edit::SelectedLines {{wtxt ""}} {
  # Gets a range of lines of text that are selected at least partly.
  #   wtxt - text's path
  # Returns a list of the text widget's path, the range of lines, "selection".

  if {$wtxt eq {}} {set wtxt [alited::main::CurrentWTXT]}
  lassign [$wtxt tag ranges sel] pos1 pos2
  if {[set selection $pos1] ne {}} {
    set pos21 [$wtxt index "$pos2 linestart"]
    if {[$wtxt get $pos21 $pos2] eq {}} {
      set pos2 [$wtxt index "$pos2 - 1 line"]
    }
  } else {
    set pos1 [set pos2 [$wtxt index insert]]
  }
  set l1 [expr {int($pos1)}]
  set l2 [expr {int($pos2)}]
  return [list $wtxt $l1 $l2 $selection]
}
#_______________________

proc edit::Indent {} {
  # Indent selected lines of text.

  lassign [SelectedLines] wtxt l1 l2
  set indent $::apave::_AP_VARS(INDENT)
  set len [string length $::apave::_AP_VARS(INDENT)]
  for {set l $l1} {$l<=$l2} {incr l} {
    set line [$wtxt get $l.0 $l.end]
    if {[string trim $line] eq {}} {
      $wtxt replace $l.0 $l.end {}
    } else {
      set leadsp [::apave::obj leadingSpaces $line]
      set sp [expr {$leadsp % $len}]
      # align by the indent edge
      if {$sp==0} {
        set ind $indent
      } else {
        set ind [string repeat " " [expr {$len - $sp}]]
      }
      $wtxt insert $l.0 $ind
    }
  }
  alited::main::HighlightLine
}
#_______________________

proc edit::UnIndent {} {
  # Unindent selected lines of text.

  lassign [SelectedLines] wtxt l1 l2
  set len [string length $::apave::_AP_VARS(INDENT)]
  set spaces [list { } \t]
  for {set l $l1} {$l<=$l2} {incr l} {
    set line [$wtxt get $l.0 $l.end]
    if {[string trim $line] eq {}} {
      $wtxt replace $l.0 $l.end {}
    } elseif {[string index $line 0] in $spaces} {
      set leadsp [::apave::obj leadingSpaces $line]
      # align by the indent edge
      set sp [expr {$leadsp % $len}]
      if {$sp==0} {set sp $len}
      $wtxt delete $l.0 "$l.0 + ${sp}c"
    }
  }
}
#_______________________

proc edit::NormIndent {} {
  # Normalizes a current text's indenting.

  alited::main::UpdateProjectInfo
  if {![namespace exists alited::indent]} {
    namespace eval alited {
      source [file join $alited::SRCDIR indent.tcl]
    }
  }
  alited::indent::normalize
}

# ________________________ Comment in / out _________________________ #

proc edit::SelectLines {wtxt l1 l2} {
  # Selects lines (all their contents) of text.
  #   wtxt - text's path
  #   l1 - starting line
  #   l2 - ending line

  $wtxt tag remove sel 1.0 end
  $wtxt tag add sel $l1.0 [incr l2].0 ;# $l1.0 $l2.end
}
#_______________________

proc edit::CommentChar {} {
  # Returns the commenting chars for a current file.

  set fname [alited::bar::FileName]
  if {[alited::file::IsClang $fname]} {
    return //
  }
  return #
}
#_______________________

proc edit::Comment {} {
  # Comments selected lines of text.
  # See also: UnComment

  if {[set ch [CommentChar]] eq {}} {bell; return}
  lassign [SelectedLines] wtxt l1 l2
  for {set l $l1} {$l<=$l2} {incr l} {
    $wtxt insert $l.0 $ch
    if {$ch eq "#"} {
      # for Tcl code: it needs to disable also all braces with #\{ #\} patterns
      set line [$wtxt get $l.0 $l.end]
      $wtxt replace $l.0 $l.end [string map [list \} #\\\} \{ #\\\{] $line]
    }
  }
  SelectLines $wtxt $l1 $l2
}
#_______________________

proc edit::UnComment {} {
  # Uncomments selected lines of text.
  # See also: Comment

  namespace upvar ::alited obPav obPav
  if {[set ch [CommentChar]] eq {}} {bell; return}
  set lch [string length $ch]
  set lch0 [expr {$lch-1}]
  lassign [SelectedLines] wtxt l1 l2
  for {set l $l1} {$l<=$l2} {incr l} {
    set line [$wtxt get $l.0 $l.end]
    set isp [$obPav leadingSpaces $line]
    if {[string range $line $isp $isp+$lch0] eq $ch} {
      $wtxt delete $l.$isp "$l.$isp + ${lch}c"
      if {$ch eq "#"} {
        # for Tcl code: it needs to enable also all braces with #\{ #\} patterns
        set line [$wtxt get $l.0 $l.end]
        $wtxt replace $l.0 $l.end [string map [list #\\\} \} #\\\{ \{] $line]
      }
    }
  }
  SelectLines $wtxt $l1 $l2
}

# ________________________ Conversions _________________________ #

proc edit::ChangeEncoding {} {
  # Changes encoding of file(s).

  tk_messageBox -message "edit::ChangeEncoding - stub"
}
#_______________________

proc edit::ChangeEOL {} {
  # Changes EOL of file(s).

  tk_messageBox -message "edit::ChangeEOL - stub"
}
# ________________________ At modifications _________________________ #

proc edit::BackupFile {TID {mode {}}} {
  # Makes a backup copy of a file after the first modification of it.
  #   TID - tab's ID of the file
  #   mode - if {orig}, makes an original copy of a file, otherwise makes .bak copy

  namespace upvar ::alited al al
  lassign [BackupDirFileNames $TID] dir fname fname2
  if {$dir ne {}} {
    if {$mode eq {}} {
      set fname2 [BackupFileName $fname2]
    }
    catch {
      file copy -force $fname $fname2
      ::apave::logMessage "backup $fname -> $fname2"
    }
  }
}
#_______________________

proc edit::BackupDirFileNames {TID} {
  # Gets directory and file names for backuping.
  #   TID - current tab's ID
  # Returns a list of names:
  #   directory, source file, target original file

  namespace upvar ::alited al al
  if {$al(BACKUP) eq {}} {return {}}
  set dir [file join $al(prjroot) $al(BACKUP)]
  set fname [alited::bar::FileName $TID]
  set fname2 [file join $dir [file tail $fname]]
  if {![file exists $dir] && [catch {file mkdir $dir} err]} {
    alited::msg ok err $err
    return {}
  }
  set fname3 [file join $dir [file tail $fname]]
  return [list $dir $fname $fname2]
}
#_______________________

proc edit::BackupFileName {fname {iincr 1}} {
  # Gets a backup name for a file (checking for backup's maximum).
  #   fname - name of target file
  #   iincr - incrementation for backup index
  # The iincr parameter is used to get the last backup's name:
  # if no backups, the empty string is returned.

  namespace upvar ::alited al al
  if {$al(MAXBACKUP)>1} {
    if {[catch {set baks [glob ${fname}*]}]} {
      set nbak 1
      if {!$iincr} {return {}} ;# no backups yet
    } else {
      foreach bak $baks {
        lappend bakdata [list [file mtime $bak] $bak]
      }
      set bakdata [lsort -decreasing $bakdata]
      set bak1 [lindex $bakdata 0 1]
      set nbak [lindex [split $bak1 -.] end-1]
      foreach delbak [lrange $bakdata $al(MAXBACKUP) end] {
        catch {file delete [lindex $delbak 1]}
      }
      if {[catch {incr nbak $iincr}] || $nbak>$al(MAXBACKUP)} {set nbak 1}
    }
    append fname -$nbak.bak
  }
  return $fname
}
#_______________________

proc edit::CheckUndoRedoIcons {wtxt TID} {
  # Checks for states of undo/redo button for a file being modified.
  #   wtxt - text's path
  #   TID - tab's ID of the file

  set TIDundo [alited::bar::BAR cget --TIDundo]
  set oldundo [alited::bar::BAR $TID cget --undo]
  set oldredo [alited::bar::BAR $TID cget --redo]
  set newundo [$wtxt edit canundo]
  set newredo [$wtxt edit canredo]
  if {$TIDundo ne $TID || $oldundo ne $newundo} {
    if {$newundo} {set stat normal} {set stat disabled}
    [alited::tool::ToolButName undo] configure -state $stat
    alited::bar::BAR $TID configure --undo $newundo
  }
  if {$TIDundo ne $TID || $oldredo ne $newredo} {
    if {$newredo} {set stat normal} {set stat disabled}
    [alited::tool::ToolButName redo] configure -state $stat
    alited::bar::BAR $TID configure --redo $newredo
  }
  if {$oldundo ne {} && !$oldundo && !$oldredo && $newundo} {
    BackupFile $TID orig
  }
  alited::bar::BAR configure --TIDundo $TID
}
#_______________________

proc edit::CheckSaveIcons {modif} {
  # Checks for states of save buttons at modifications of files.
  #   modif - yes, if a file has been modified

  namespace upvar ::alited al al
  set marked [alited::bar::BAR listFlag "m"]
  set b_save [alited::tool::ToolButName SaveFile]
  set b_saveall [alited::tool::ToolButName saveall]
  if {![llength $marked]} {
    foreach but {SaveFile saveall} {
      [alited::tool::ToolButName $but] configure -state disabled
    }
  } else {
    if {$modif} {set stat normal} {set stat disabled}
    $b_save configure -state $stat
    $b_saveall configure -state normal
  }
  $al(MENUFILE) entryconfigure 4 -state [$b_save cget -state]
  $al(MENUFILE) entryconfigure 6 -state [$b_saveall cget -state]
}
#_______________________

proc edit::Modified {TID wtxt {l1 0} {l2 0} args} {
  # Handles a modification of file, recreating the unit tree at need.
  #   TID - tab's ID
  #   wtxt - text's path
  #   l1 - 1st line of unit
  #   l2 - last line of unit

  namespace upvar ::alited al al obPav obPav
  if {[alited::bar::BAR isTab $TID]} {
    set old [alited::file::IsModified $TID]
    set new [$wtxt edit modified]
    if {$old != $new} {
      if {$new} {
        alited::bar::BAR markTab $TID
      } else {
        alited::bar::BAR unmarkTab $TID
      }
      CheckSaveIcons $new
    }
    CheckUndoRedoIcons $wtxt $TID
    if {$al(TREE,isunits)} {
      set pos [$wtxt index insert]
      set wtree [$obPav Tree]
      set todoTree no
      catch {set todoTree [$wtree tag has tagTODO [alited::tree::CurrentItem]]}
      # when text's TODO tag isn't equal to tree's, recreate the tree
      lassign [$wtxt tag nextrange tagCMN2 \
        [$wtxt index "$pos linestart"] [$wtxt index "$pos lineend"]] p1 p2
      if {$p2 ne {} && [$wtxt compare $pos >= $p1] && [$wtxt compare $pos <= $p2]} {
        set todo [expr {!$todoTree}]
      } else {
        set todo $todoTree
      }
      if {$todo} {
        alited::tree::RecreateTree
      } elseif {![info exists al(RECREATE)] || $al(RECREATE)} {
        set doit no
        if {[set llen [llength $al(_unittree,$TID)]]} {
          set lastrow [lindex $al(_unittree,$TID) $llen-1 5]
          set doit [expr {$lastrow != int([$wtxt index {end -1c}])}]
        }
        set l1 [expr {int($pos)}]
        set notfound [catch {set ifound [lsearch -index 4 $al(_unittree,$TID) $l1]}]
        if {$doit || (!$notfound && $ifound>-1) || \
        $al(INI,LEAF) && [regexp $al(RE,leaf2) $args] || \
        [regexp $al(RE,proc2) $args]} {
          alited::tree::RecreateTree
        } else {
          set line [$wtxt get $l1.0 $l1.end]
          if {$al(INI,LEAF) && [regexp $al(RE,leaf) $line] || \
          !$al(INI,LEAF) && [regexp $al(RE,proc) $line] || \
          [regexp $al(RE,branch) $line]} {
            alited::tree::RecreateTree
          }
        }
      }
    }
  }
  alited::main::ShowHeader
}
#_______________________

proc edit::RemoveTrailWhites {{TID ""} {doit no} {skipGUI no}} {
  # Removes trailing spaces of lines - all of lines or a selection of lines.
  #   TID - tab ID
  #   doit - if yes, trimright all of text without questions
  #   skipGUI - if yes, no updating GUI

  namespace upvar ::alited al al
  set ans 1
  if {!$doit} {
    set TID [alited::bar::CurrentTabID]
    # ask about trailing all lines of a current file (with option: all of other files)
    set msg [msgcat::mc "Remove trailing whitespaces of all lines\nof \"%f\"?"]
    set msg [string map [list %f [file tail [alited::bar::FileName]]] $msg]
    set ans [alited::msg yesno ques $msg \
      YES -title {Remove trailing whitespaces} -ch $al(MC,otherfiles)]
    if {![set doit $ans]} return
  }
  set waseditcurr no
  foreach tab [alited::bar::BAR listTab] {
    set tid [lindex $tab 0]
    if {$ans==11 || $tid eq $TID} {
      lassign [alited::main::GetText $tid no no] -> wtxt
      set l1 1
      set l2 [expr {int([$wtxt index {end -1c}])}]
      set wasedit no
      for {set l $l1} {$l<=$l2} {incr l} {
        set line [$wtxt get $l.0 $l.end]
        if {[set trimmed [string trimright $line]] ne $line} {
          if {!$wasedit} {$wtxt edit separator}
          set wasedit yes
          $wtxt replace $l.0 $l.end $trimmed
        }
      }
      if {$wasedit} {
        $wtxt edit separator
        alited::bar::BAR markTab $tid
        if {$wtxt eq [alited::main::CurrentWTXT]} {
          set waseditcurr yes  ;# update the current text's view only
        }
      }
    }
  }
  if {!$skipGUI} {
    if {$waseditcurr} {
      alited::main::UpdateTextGutterTreeIcons
    } else {
      alited::main::UpdateIcons
    }
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
