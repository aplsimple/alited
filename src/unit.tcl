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

proc unit::GetHeader {wtree ID {NC ""} {wtxt ""} {tip ""} {l1 0} {l2 0}} {
  # Gets a header of unit: declaration + initial comments.
  #   wtree - unit tree widget
  #   ID - ID of item in the unit tree
  #   NC - index of column of the unit tree
  #   wtxt - text widget
  #   tip - unit's name
  #   l1 - 1st line of unit
  #   l2 - last line of unit

  namespace upvar ::alited al al
  if {$wtree ne {}} {
    set tip [string trim [$wtree item $ID -text]]
    lassign [$wtree item $ID -values] l1 l2 - id
    if {!$al(TREE,isunits)} {
      return $l2  ;# for file tree, it's a full file name
    }
  }
  if {$NC eq {#1}} {
    set tip "[string map {al #} $id]\n$l1 - [expr {max($l1,$l2)}]"
    set ID {}
  } else {
    catch {
      if {$wtxt eq {}} {
        set wtxt [alited::main::CurrentWTXT]
      }
      set tip2 [string trim [$wtxt get $l1.0 $l1.end]]
      if {[string match "*\{" $tip2]} {
        set tip [string trim $tip2 " \{"]
      }
      if {$NC eq {}} {
        return $tip  ;# returns a declaration only
      }
      # find first commented line, after the proc/method declaration
      for {} {$l1<$l2} {} {
        incr l1
        set line [string trim [$wtxt get $l1.0 $l1.end]]
        if {[string index $line end] ni [list \\ \{] && \
        $line ni {{} # //} && ![regexp $al(RE,proc) $line]} {
          if {[string match #* $line]} {
            append tip \n [string trim [string range $line 1 end]]
          } elseif {[string match //* $line]} {
            append tip \n [string trim [string range $line 2 end]]
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
  set isLeaf [expr {$al(INI,LEAF) && $al(RE,leaf) ne {}}]
  set isProc [expr {(!$al(INI,LEAF) || \
    [alited::file::IsTcl [alited::bar::FileName $TID]]) && $al(RE,proc) ne {}}]
  set i [set lev [set leaf [set icomleaf -1]]]
  foreach line $textcont {
    incr i
    set flag1 0
    if {[set flag [regexp $al(RE,branch) $line -> cmn1 title]]} {
      # a branch
      set leaf [set icomleaf 0]
      set lev [expr {max(0,[string length $cmn1]-1)}]
    } elseif { \
    $isLeaf && [regexp $al(RE,leaf) $line -> t1 t2 t3 t4 t5 t6 t7] || \
    $isProc && [regexp $al(RE,proc) $line -> t1 t2 t3 t4 t5 t6 t7]} {
      set title $t1  ;# default title: just after found string
      foreach t {t7 t6 t5 t4 t3 t2} {
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
          set treeID [alited::tree::NewItemID [incr iit]]
          lappend retlist [list $lev 1 $al(INI,LEAF) "" 1 $l1 $treeID]
        }
        lassign [lindex $retlist end] levE leafE flE namE l1E - treeIDE
        lassign $item levC leafC flC namC l1C
        if {$flE eq "1" && $flC eq "0" && $levE==$levC && $leafE==$leafC} {
          # found a named previous leaf
          if {$namE eq ""} {set namE $namC}
          # update the named leaf
          set retlist [lreplace $retlist end end \
            [list $levE $leafE $flE $namE $l1E $i $treeIDE]]
        } else {
          # add l2 (last line of unit), ID of unit
          set treeID [alited::tree::NewItemID [incr iit]]
          lappend retlist [lappend item $i $treeID]
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
    set treeID [alited::tree::NewItemID [incr iit]]
    lappend retlist [list 1 1 1 $name 1 $llen $treeID]
  }
  return $retlist
}
#_______________________

proc unit::SwitchUnits {} {
  # Switches between last two active units.

  namespace upvar ::alited al al
  if {[llength $al(FAV,visited)]<2} return
  lassign [lindex $al(FAV,visited) 1 4] name fname header
  if {[set TID [alited::favor::OpenSelectedFile $fname]] eq {}} return
  alited::favor::GoToUnit $TID $name $header
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
    %d [alited::tool::FormatDate $sec] \
    %t [clock format $sec -format $al(TPL,%t)] \
    %u $al(TPL,%u) \
    %U $al(TPL,%U) \
    %m $al(TPL,%m) \
    %w $al(TPL,%w) \
    %F $fname \
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
#_______________________

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

# ________________________ Moving units _________________________ #

proc unit::DropUnits {wtree fromIDs toID} {
  # Moves unit(s) from one location in the unit tree to other.
  #   wtree - unit tree's path
  #   fromIDs - IDs of tree item "to move from"
  #   toID - ID of tree item "to move to"

  namespace upvar ::alited obPav obPav
  set tree [alited::tree::GetTree]
  set wtxt [alited::main::CurrentWTXT]
  set wtree [$obPav Tree]
  $wtxt configure -autoseparators no
  $wtxt edit separator
  # firstly, cut all moved lines
  set ijust 0
  set movedlines [list]
  # we must cut from below, so sort units reversely:
  set fromIDs [lsort -decreasing -dictionary $fromIDs]
  set headers [list]
  foreach fromID $fromIDs {
    if {$fromID eq $toID} continue
    # simply for each unit: find its moved lines and a destination line
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
      lappend headers [GetHeader $wtree $fromID]
      # if the unit is above the destination, the destination should be adjusted
      if {$i2<$io} {set ijust [expr {$ijust-$i2+$i1-1}]}
      set ind2 [$wtxt index "$i2.end +1 char"]
      set lines [$wtxt get $i1.0 $ind2]
      $wtxt delete $i1.0 $ind2
      # the cut lines are saved, to paste them afterwards
      lappend movedlines $lines
    }
  }
  # secondly, paste all moved lines
  if {[llength $movedlines]} {
    incr io $ijust
    foreach lines $movedlines {
      $wtxt insert $io.0 $lines
    }
    ::tk::TextSetCursor $wtxt $io.0
    alited::main::UpdateAll $headers
    alited::main::FocusText
  }
  $wtxt edit separator
  $wtxt configure -autoseparators yes
}
#_______________________

proc unit::MoveL1L2 {wtxt i1 i2 io {dosep yes}} {
  # Moves a text lines to other location.
  #   wtxt - text widget's path
  #   i1 - first line to be moved
  #   i2 - last line to be moved
  #   io - destination line (to insert the moved lines before)
  #   dosep - yes, if "edit separator" is required
  # Returns a position of destination line, if the moving was successful.

  set ind2 [$wtxt index "$i2.end +1 char"]
  if {($i1<=$io && $io<=$i2) || $io<1 || $i1<1 || $i2<1 || \
  [set linesmoved [$wtxt get $i1.0 $ind2]] eq ""} {
    return "" ;# nothing to do
  }
  if {$dosep} {
    $wtxt configure -autoseparators no
    $wtxt edit separator
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
  if {$dosep} {
    $wtxt edit separator
    $wtxt configure -autoseparators yes
  }
  return $io
}
#_______________________

proc unit::MoveUnit {wtree to hd headers f1112 {dosep yes}} {
  # Moves a unit up/down the unit tree.
  #   wtree - unit tree's path
  #   to - direction (up/down)
  #   hd - header of the moved unit
  #   headers - headers of all selected units
  #   f1112 - yes, if run by F11/F12 keys
  #   dosep - yes, if "edit separator" is required

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
  if {[set pos [MoveL1L2 $wtxt $i1 $i2 $io $dosep]] ne {}} {
    ::tk::TextSetCursor $wtxt [expr {int($pos)}].0
    alited::tree::RecreateTree $wtree $headers
  } else {
    return no
  }
  return yes
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
    DropUnits $wtree $itemIDs $f1112
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
  $wtxt configure -autoseparators no
  $wtxt edit separator
  foreach hd $headers {
    if {![MoveUnit $wtree $to $hd $headers $f1112 no]} {
      break
    }
  }
  $wtxt edit separator
  $wtxt configure -autoseparators yes
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

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
