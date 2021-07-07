#! /usr/bin/env tclsh
###########################################################
# Name:    unit.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/30/2021
# Brief:   Handles units (branches and leaves).
# License: MIT.
###########################################################

namespace eval unit {
}

# ________________________ Common _________________________ #

proc unit::GetHeader {wtree ID {NC ""}} {
  # Gets a header of unit: declaration + initial comments.
  #   wtree - unit tree widget
  #   ID - ID of item in the unit tree
  #   NC - index of column of the unit tree

  namespace upvar ::alited al al
  set tip [$wtree item $ID -text]
  lassign [$wtree item $ID -values] l1 l2 - id
  if {$NC eq "#1"} {
    set tip "[string map {al #} $id]\n$l1 - $l2"
    set ID ""
  } else {
    catch {
      set wtxt [alited::main::CurrentWTXT]
      set tip2 [string trim [$wtxt get $l1.0 $l1.end]]
      if {[string match "*\{" $tip2]} {
        set tip [string trim $tip2 " \{"]
      }
      if {$NC eq ""} {
        return $tip  ;# returns a declaration only
      }
      # find first commented line, after the proc/method declaration
      for {} {$l1<$l2} {} {
        incr l1
        set line [string trim [$wtxt get $l1.0 $l1.end]]
        if {[string index $line end] ni [list \\ \{] && \
        $line ni {"" "#"} && ![regexp $al(RE,proc) $line]} {
          if {[string match "#*" $line]} {
            append tip \n [string trim [string range $line 1 end]]
          }
          break
        }
      }
    }
  }
  return $tip
}
#_______________________

proc unit::BranchLines {ID} {
  # Gets a line range of a branch.
  #   ID - ID of the branch

  set branch [alited::tree::GetTree $ID]
  set l1 [lindex $branch 0 4 0]
  set l2 [lindex $branch end 4 1]
  return [list $l1 $l2]
}
#_______________________

proc unit::GetUnits {TID textcont} {
  # Gets a unit structure from a text.
  #   TID - tab ID of the text
  #   textcont - contents of the text
  # Returns a list of unit items.
  # An item contains:
  #   - level
  #   - 0 (branch) or 1 (INI,LEAF)
  #   - title
  #   - line1 - first text line for the item 
  #   - line2 - last text line for the item 
  #
  # The procedure searhes "branch" units in commented lines, e.g. for:
  #   # ___ level 1 _____ #
  #   ## ___ level 2 _____ ##
  #   ### ___ level 3 _____ ###
  # using regexp {^\s*(#+) [_]+([^_]+)[_]+ (#+)} $line -> cmn1 title cmn2
  # it extracts two comment marks (#, ## or ###) and a title (level 1/2/3).
  #
  # To search "leaf" units (containing procs and methods), another `regexp`
  # is used, e.g. for:
  #   # _____
  #   # _____ my leaf 1
  # regexp {^\s*# [_]+([^_]*)$} $line -> title
  # extracts a title (my leaf 1).
  #
  # If "leaf" title is empty, it's taken from the proc/method name, e.g. for
  #   proc unit::SelectUnit {} {...}
  #   method unit::SelectUnit {} {...}
  # regexp {^\s*(proc|method)\s+([[:alnum:]_:]+)\s.+} $line -> type title
  # extracts a type (proc/method) and a title (unit::SelectUnit).
  # The last non-empty group is taken for the title.

  namespace upvar ::alited al al
  set retlist [set item [set title [list]]]
  set textcont [split $textcont \n]
  set llen [llength $textcont]
  lappend textcont ""  ;# to save a last unit to the retlist
  set i [set lev [set leaf [set icomleaf -1]]]
  foreach line $textcont {
    incr i
    set flag1 0
    if {[set flag [regexp $al(RE,branch) $line -> cmn1 title]]} {
      # a branch
      set leaf [set icomleaf 0]
      set lev [expr {max(0,[string length $cmn1]-1)}]
    } elseif { \
    $al(INI,LEAF)  && $al(RE,leaf) ne {} && [regexp $al(RE,leaf) $line -> t1 t2 t3 t4 t5 t6 t7] || \
    !$al(INI,LEAF) && $al(RE,proc) ne {} && [regexp $al(RE,proc) $line -> t1 t2 t3 t4 t5 t6 t7]} {
      set title $t2  ;# default title: just after found string
      foreach t {t7 t6 t5 t4 t3} {
        if {[set _ [set $t]] ne ""} {
          set title $_  ;# last non-empty group of others is a real title
          break
        }
      }
      if {[set cl [string last :: $title]]>-1 && [set cl [string last :: $title $cl]]>-1} {
        # let only a last namespace be present in the titles
        set title [string range $title $cl+2 end]
      }
      set flag1 $al(INI,LEAF)
      set flag [set leaf 1]
    } else {
      set flag [expr {$i>=$llen}]
    }
    if {$flag} {
      if {[llength $item]} {
        set l1 [expr {[lindex $item 4]-1}]
        if {$l1>0 && ![llength $retlist]} {
          # first found at line>1 => create a starting leaf
          lappend retlist [list $lev 1 $al(INI,LEAF) "" 1 $l1]
        }
        lassign [lindex $retlist end] levE leafE flE namE l1E
        lassign $item levC leafC flC namC l1C
        if {$flE eq "1" && $flC eq "0" && $levE==$levC && $leafE==$leafC} {
          # found a named previous leaf
          if {$namE eq ""} {set namE $namC}
          # update the named leaf
          set retlist [lreplace $retlist end end \
            [list $levE $leafE $flE $namE $l1E $i]]
        } else {
          lappend retlist [lappend item $i]
        }
      }
      # prepare an item for saving
      set item [list \
        [expr {$lev+$leaf}] $leaf $flag1 [string trim $title " #"] [expr {$i+1}]]
    }
  }
  if {![llength $retlist]} {
    set name [file tail [alited::bar::FileName $TID]]
    set name [string map [list %f $name] $al(MC,alloffile)]
    lappend retlist [list 1 1 1 $name 1 $llen]
  }
  return $retlist
}

# ________________________ Templates _________________________ #

proc unit::TemplateData {wtxt l1 tpldata} {
  # Replaces the template wildcards with data of current text and unit.
  #   wtxt - text's path
  #   l1 - 1st line of current unit
  #   tpldata - template

  namespace upvar ::alited al al
  lassign $tpldata tex pos place
  set sec [clock seconds]
  set fname [alited::bar::FileName]
  # fill the common wildcards
  set tex [string map [list \
    %d [clock format $sec -format $al(TPL,%d)] \
    %t [clock format $sec -format $al(TPL,%t)] \
    %u $al(TPL,%u) \
    %U $al(TPL,%U) \
    %m $al(TPL,%m) \
    %w $al(TPL,%w) \
    %f [file tail $fname] \
    %n [file rootname [file tail $fname]] \
    ] $tex]
  # get a list of proc/method's arguments:
  # from "proc pr {ar1 ar2 ar3} " and a template "  # %a -\n"
  # to get
  #   # ar1 -
  #   # ar2 -
  #   # ar3 -
  if {[catch {set textcont [$wtxt get $l1.0 $l1.end]}]} {set textcont ""}
  lassign [split $textcont "\{\}"] proc iarg
  catch {
    set tpla [string map [list \\n \n] $al(TPL,%a)]
    set oarg [set st1 ""]
    foreach a $iarg {
      set st [string map [list %a $a] $tpla]
      if {$st1 eq ""} {set st1 $st}
      append oarg $st
    }
    if {[string first %a $tex]>-1} {
      set place 0
      set pos 1.[string length $st1]
    }
    set tex [string map [list \\n \n %a $oarg] $tex]
  }
  set ll1 [string length $tex]
  set tex [string map [list %p [lindex $proc 1]] $tex]
  set ll2 [string length $tex]
  if {[set ll [expr {$ll2-$ll1}]]} {
    lassign [split $pos .] r c
    if {[string is digit -strict $c]} {
      set pos $r.[expr {$c+$ll}]
    }
  }
  return [list $tex $pos $place]
}
#_______________________

proc unit::InsertTemplate {tpldata} {
  # Inserts a template into a current text.
  #   tpldata - template

  # for noname file - save it beforehand, as templates refer to a file name
  if {[alited::file::IsNoName [alited::bar::FileName]]} {
    if {![alited::file::SaveFile]} return
  }
  set wtxt [alited::main::CurrentWTXT]
  lassign [alited::tree::CurrentItemByLine "" 1] itemID - - - - l1 l2
  lassign [TemplateData $wtxt $l1 $tpldata] tex pos place
  set col0 [string range $pos [string first . $pos] end]
  switch $place {
    0 { ;# returned by TemplateData: after a declaration
      set pos0 [expr {$l1+1}].0
    }
    4 { ;# after 1st line
      set pos0 1.0
    }
    3 { ;# after cursor
      set pos0 [$wtxt index insert]
    }
    2 { ;# after unit
      if {$l2 ne ""} {
        set pos0 [$wtxt index "$l2.0 +1 line linestart"]
        if {[string index $tex end] ne "\n"} {append tex \n}
      } else {
        set place 1
      }
    }
    default { ;# after line
      set place 1
    }
  }
  if {$place == 1} {
    set pos0 [$wtxt index "insert +1 line linestart"]
    if {[string index $tex end] ne "\n"} {append tex \n}
  }
  set pos "[expr {int($pos)-1}]$col0"
  set pos [alited::p+ $pos0 $pos]
  $wtxt insert $pos0 $tex
  ::tk::TextSetCursor $wtxt $pos
}
#_______________________

proc unit::Add {} {
  # Runs a dialog "Add Template" and adds a chosen template to a text.

  set res [::alited::unit_tpl::_run]
  if {$res ne ""} {
    InsertTemplate $res
  }
  alited::keys::BindKeys [alited::main::CurrentWTXT] template
}

# ________________________ Moving units _________________________ #

proc unit::Delete {wtree fname} {
  # Deletes a unit from a text.
  #   wtree - unit tree's path
  #   fname - file name

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  set selection [$wtree selection]
  set wasdel no
  for {set i [llength $selection]} {$i} {} {
    # delete units from the text's bottom (text selection is sorted by items)
    incr i -1
    set ID [lindex $selection $i]
    set name [$wtree item $ID -text]
    set msg [string map [list %n $name %f [file tail $fname]] $al(MC,delitem)]
    set ans [alited::msg yesnocancel ques $msg NO]
    switch $ans {
      0 break
      2 {}
      1 {
        lassign [$wtree item $ID -values] l1 l2
        set ind2 [$wtxt index "$l2.end +1 char"]
        $wtxt delete $l1.0 $ind2
        set wasdel yes
      }
    }
  }
}
#_______________________

proc unit::MoveL1L2 {wtxt i1 i2 io} {
  # Moves a text lines to other location.
  #   wtxt - text widget's path
  #   i1 - first line to be moved
  #   i2 - last line to be moved
  #   io - destination line (to insert the moved lines before)
  # Returns a position of destination line, if the moving was successful.

  set ind2 [$wtxt index "$i2.end +1 char"]
  if {($i1<=$io && $io<=$i2) || $io<1 || $i1<1 || $i2<1 || \
  [set linesmoved [$wtxt get $i1.0 $ind2]] eq ""} {
    return "" ;# nothing to do
  }
  $wtxt delete $i1.0 $ind2
  if {$io>$i2} {
    # 3. i1    if moved below, the moved (deleted) lines change 'io', so
    # 4. i2    'io' is shifted up (by range of moved lines i.e. i1-i2-1)
    # 5.
    # 6. io    resulting io = io-(i2-i1+1) = io+i1-i2-1 (6+3-4-1=4)
    set io [expr {$io+$i1-$i2-1}]
  }
  if {$io == int([$wtxt index end])} {
    # "If index refers to the end of the text (the character after the last newline) then the new text is inserted just before the last newline instead." (The text manual page)
    $wtxt insert "end" \n$linesmoved
    $wtxt delete [$wtxt index "end -1 char"] end
  } else {
    $wtxt insert $io.0 $linesmoved
  }
  return $io
}
#_______________________

proc unit::MoveUnit {wtree to hd headers f1112} {
  # Moves a unit up/down the unit tree.
  #   wtree - unit tree's path
  #   to - direction (up/down)
  #   hd - header of the moved unit
  #   headers - headers of all selected units
  #   f1112 - yes, if run by F11/F12 keys

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  set tree [alited::tree::GetTree]
  set itemID [SearchByHeader $hd]
  set newparent [set oldparent {}]
  set newlev [set oldlev [set iold -1]]
  set i1 [set i2 [set io 0]]
  foreach item $tree {
    lassign $item lev cnt id title values
    lassign $values l1 l2 prl id lev leaf fl1
    if {$id eq $itemID} {
      set oldlev $lev
      set i1 $l1
      set i2 $l2
      if {$to eq "up"} break
    } elseif {$to ne "up" && $oldlev>-1} {
      set io [expr {$l2+1}]
      break
    }
    set io $l1
  }
  if {$io<$al(INI,LINES1)} {
    set msg [string map [list %n $al(INI,LINES1)] $al(MC,introln2)]
    if {$f1112} {set geo ""} else {set geo "-geometry pointer+10+10"}
    alited::msg ok err $msg -title $al(MC,introln1) {*}$geo
    return no
  }
  if {[set pos [MoveL1L2 $wtxt $i1 $i2 $io]] ne {}} {
    ::tk::TextSetCursor $wtxt [expr {int($pos)}].0
    alited::tree::RecreateTree $wtree $headers
  } else {
    return no
  }
  return yes
}
#_______________________

proc unit::MoveUnit1 {wtree fromID toID} {
  # Moves a unit from one location in the unit tree to other.
  #   wtree - unit tree's path
  #   fromID - ID of tree item "to move from"
  #   toID - ID of tree item "to move to"

  if {$fromID eq $toID} return
  set wtxt [alited::main::CurrentWTXT]
  set tree [alited::tree::GetTree]
  set i1 [set i2 [set io 0]]
  foreach item $tree {
    lassign $item lev cnt id title values
    lassign $values l1 l2 prl id lev leaf fl1
    if {$id eq $fromID} {
      set i1 $l1
      set i2 $l2
    } elseif {$id eq $toID} {
      set io $l1
    }
  }
  if {$i1 && $i2 && $io} {
    if {[set pos [MoveL1L2 $wtxt $i1 $i2 $io]] ne {}} {
      ::tk::TextSetCursor $wtxt [expr {int($pos)}].0
      alited::tree::RecreateTree
    }
  }
}
#_______________________

proc unit::MoveUnits {wtree to itemIDs f1112} {
  # Moves selected units up/down the unit tree.
  #   wtree - unit tree's path
  #   to - direction (up/down)
  #   itemIDs - tree item IDs of selected units
  #   f1112 - yes, if run by F11/F12 keys

  namespace upvar ::alited al al
  # update the unit tree, to act for sure
  alited::tree::RecreateTree
  # check the moved units for the consistency of braces
  set wtxt [alited::main::CurrentWTXT]
  foreach ID $itemIDs {
    lassign [$wtree item $ID -values] l1 l2 - id
    set cc1 [set cc2 0]
    foreach line [split [$wtxt get $l1.0 $l2.end] \n] {
      incr cc1 [::apave::countChar $line \{]
      incr cc2 [::apave::countChar $line \}]
    }
    if {$cc1!=$cc2} {
      set tip [string trim [$wtree item $ID -text]]
      set msg [string map [list %n $tip %1 $cc1 %2 $cc2] $al(MC,errmove)]
      alited::Message $msg 4
      return
    }
  }
  if {$to eq "move"} {
    MoveUnit1 $wtree $itemIDs $f1112
    return
  }
  set al(RECREATE) 0
  set headers [list]
  foreach ID $itemIDs {
    set hd [GetHeader $wtree $ID]
    if {$to eq "up"} {
      lappend headers $hd
    } else {
      set headers [linsert $headers 0 $hd]
    }
  }
  # move items one by one, by their headers
  foreach hd $headers {
    if {![MoveUnit $wtree $to $hd $headers $f1112]} {
      break
    }
  }
  after idle "set alited::al(RECREATE) 1 ; alited::tree::RecreateTree"
  if {[set sel [$wtree selection]] ne ""} {
    after idle [list after 10 "$wtree selection set {$sel}"]
  }
}

# ________________________ Search _________________________ #

proc unit::SearchInBranch {unit {branch {}}} {
  # Checks whether a unit is in a branch.
  #   unit - ID of the unit
  #   branch - the branch or its ID
  # If *branch* is omitted, searches in all of the tree.
  # If *branch* is set as ID, the branch is fetched from this ID.
  # Returns the unit's index in the branch or -1 if not found.

  if {[llength $branch]<2} {
    set branch [alited::tree::GetTree $branch]
  }
  return [lsearch -exact -index 2 $branch $unit]
}
#_______________________

proc unit::SearchByHeader {header} {
  # Gets tree item ID of a units by its header (declaration+initial comment).

  namespace upvar ::alited obPav obPav
  set wtree [$obPav Tree]
  foreach item [alited::tree::GetTree] {
    set ID [lindex $item 2]
    set header2 [GetHeader $wtree $ID]
    if {$header eq $header2} {return $ID}
  }
  return {}
}
#_______________________

proc unit::SelectByHeader {header line} {
  # Selects a unit in the text, by the unit's header.
  #   header - unit's header (declaration+initial comment)
  #   line - relational line number inside the unit

  if {[set ID [SearchByHeader $header]] ne ""} {
    after idle "alited::tree::NewSelection $ID $line"
  }
}

# ________________________ Indent _________________________ #

proc unit::SelectedLines {} {
  # Gets a range of lines of text that are selected at least partly.

  set wtxt [alited::main::CurrentWTXT]
  lassign [$wtxt tag ranges sel] pos1 pos2
  if {$pos1 eq ""} {
    set pos1 [set pos2 [$wtxt index insert]]
  } else {
    set pos21 [$wtxt index "$pos2 linestart"]
    if {[$wtxt get $pos21 $pos2] eq ""} {
      set pos2 [$wtxt index "$pos2 - 1 line"]
    }
  }
  set l1 [expr {int($pos1)}]
  set l2 [expr {int($pos2)}]
  return [list $wtxt $l1 $l2]
}
#_______________________

proc unit::Indent {} {
  # Indent selected lines of text.

  lassign [SelectedLines] wtxt l1 l2
  set indent $::apave::_AP_VARS(INDENT)
  set len [string length $::apave::_AP_VARS(INDENT)]
  for {set l $l1} {$l<=$l2} {incr l} {
    set line [$wtxt get $l.0 $l.end]
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
  alited::main::HighlightLine
}
#_______________________

proc unit::UnIndent {} {
  # Unindent selected lines of text.

  lassign [SelectedLines] wtxt l1 l2
  set len [string length $::apave::_AP_VARS(INDENT)]
  for {set l $l1} {$l<=$l2} {incr l} {
    set line [$wtxt get $l.0 $l.end]
    if {[string first " " $line]==0} {
      set leadsp [::apave::obj leadingSpaces $line]
      # align by the indent edge
      set sp [expr {$leadsp % $len}]
      if {$sp==0} {set sp $len}
      $wtxt delete $l.0 "$l.0 + ${sp}c"
    }
  }
}
#_______________________

proc unit::NormIndent {} {
  # Normalizes a current text's indenting.

  if {![namespace exists alited::indent]} {
    namespace eval alited {
      source [file join $alited::SRCDIR indent.tcl]
    }
  }
  alited::indent::normalize
  alited::main::UpdateTextAndGutter
}

# ________________________ Comment in / out _________________________ #

proc unit::CommentChar {} {
  # Returns the commenting chars for a current file.

  set fname [alited::bar::FileName]
  if {[alited::file::IsTcl $fname]} {
    return #
  } elseif {[alited::file::IsClang $fname]} {
    return //
  }
  return {}
}

proc unit::Comment {} {
  # Comments selected lines of text.

  if {[set ch [CommentChar]] eq {}} {bell; return}
  lassign [SelectedLines] wtxt l1 l2
  for {set l $l1} {$l<=$l2} {incr l} {
    $wtxt insert $l.0 $ch
  }
}
#_______________________

proc unit::UnComment {} {
  # Uncomments selected lines of text.

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
    }
  }
}

# ________________________ Modified _________________________ #

proc unit::BackupFile {TID} {
  # Makes a backup copy of a file after the first modification of it.
  #   TID - tab's ID of the file

  namespace upvar ::alited al al
  if {$al(BACKUP) ne {}} {
    set fname [alited::bar::FileName $TID]
    set dir [file join $al(prjroot) $al(BACKUP)]
    set fname2 [file join $dir [file tail $fname]]
    if {![file exists $dir] && [catch {file mkdir $dir} err]} {
      alited::msg ok err $err
    }
    if {[file exists $dir]} {
      catch {file copy -force $fname $fname2}
    }
  }
}
#_______________________

proc unit::CheckUndoRedoIcons {wtxt TID} {
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
    BackupFile $TID
  }
  alited::bar::BAR configure --TIDundo $TID
}
#_______________________

proc unit::CheckSaveIcons {modif} {
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

proc unit::Modified {TID wtxt {l1 0} {l2 0} args} {
  # Handles a modification of file, recreating the unit tree at need.
  #   TID - tab's ID
  #   wtxt - text's path
  #   l1 - 1st line of unit
  #   l2 - last line of unit

  namespace upvar ::alited al al
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
      if {![info exists al(RECREATE)] || $al(RECREATE)} {
        set doit no
        if {[set llen [llength $al(_unittree,$TID)]]} {
          set lastrow [lindex $al(_unittree,$TID) $llen-1 5]
          set doit [expr {$lastrow != int([$wtxt index "end -1c"])}]
        }
        if {$l1<$l2 || $al(INI,LEAF) && [regexp $al(RE,leaf2) $args] || \
        !$al(INI,LEAF) && [regexp $al(RE,proc2) $args]} {
          alited::tree::RecreateTree
        } elseif {[lsearch -index 4 $al(_unittree,$TID) $l1]>-1} {
          alited::tree::RecreateTree
        } else {
          set line [$wtxt get $l1.0 $l1.end]
          if {$al(INI,LEAF) && [regexp $al(RE,leaf) $line] || \
          !$al(INI,LEAF) && [regexp $al(RE,proc) $line] || \
          [regexp $al(RE,branch) $line] || $doit} {
            alited::tree::RecreateTree
          }
        }
      }
    }
  }
  alited::main::ShowHeader
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
