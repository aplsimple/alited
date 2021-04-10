#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The unit procedures of alited.
# _______________________________________________________________________ #

namespace eval unit {
}

proc unit::SelectUnit {} {

  namespace upvar ::alited al al
  set TID [alited::bar::CurrentTabID]
  lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
  set suf [alited::main::CurrentSUF $TID]
  pack forget $wtxt$suf
  pack forget $wsbv$suf
  if {$suf eq ""} {set suf "_S2"} else {set suf ""}
  alited::main::ShowText $suf
}

proc unit::GetUnits {textcont} {
  # Gets a unit structure from a text.
  #   textcont - contents of text
  # Returns a list of unit items.
  # An item contains:
  #   - level
  #   - 0 (branch) or 1 (leaf)
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
    $al(LEAF)  && $al(RE,leaf) ne {} && [regexp $al(RE,leaf) $line -> t1 t2 t3 t4 t5 t6 t7] || \
    !$al(LEAF) && $al(RE,proc) ne {} && [regexp $al(RE,proc) $line -> t1 t2 t3 t4 t5 t6 t7]} {
      set title $t2  ;# default title: just after found string
      foreach t {t7 t6 t5 t4 t3} {
        if {[set _ [set $t]] ne ""} {
          set title $_  ;# last non-empty group of others is a real title
          break
        }
      }
      set flag1 $al(LEAF)
      set flag [set leaf 1]
    } else {
      set flag [expr {$i>=$llen}]
    }
    if {$flag} {
      if {[llength $item]} {
        set l1 [expr {[lindex $item 4]-1}]
        if {$l1>0 && ![llength $retlist]} {
          # first found at line>1 => create a starting leaf
          lappend retlist [list $lev 1 $al(LEAF) "" 1 $l1]
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
  return $retlist
}

proc unit::Add {} {
  namespace upvar ::alited obPav obPav
  if {![info exists ::alited::unit_tpl::ilast]} {
    source [file join $alited::SRCDIR unit_tpl.tcl]
  }
  set res [::alited::unit_tpl::_run]
  if {$res ne ""} {
    lassign $res place pos tex
    set wtxt [alited::main::CurrentWTXT]
    switch $place {
      3 { ;# after cursor
        set pos0 [$wtxt index insert]
      }
      2 { ;# after unit
        lassign [alited::tree::CurrentItemByLine "" 1] itemID lev leaf fl1 title l1 l2
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
    set p2 [string range $pos [string first . $pos] end]
    set pos "[expr {int($pos)-1}]$p2"
    set pos [alited::p+ $pos0 $pos]
    $wtxt insert $pos0 $tex
    ::tk::TextSetCursor $wtxt $pos
  }
}

proc unit::Delete {wtree fname} {
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
    set ans [alited::msg yesnocancel ques $msg NO -title $al(MC,question)]
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

proc unit::MoveUnit {wtree to itemID headers f1112} {

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  set tree [alited::tree::GetTree]
  set newparent [set oldparent ""]
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
  if {$io<$al(INTRO_LINES)} {
    set msg [string map [list %n $al(INTRO_LINES)] $al(MC,introln2)]
    if {$f1112} {set geo ""} else {set geo "-geometry pointer+10+10"}
    alited::msg ok err $msg -title $al(MC,introln1) {*}$geo
    return no
  }
  if {[set pos [MoveL1L2 $wtxt $i1 $i2 $io]] ne ""} {
    ::tk::TextSetCursor $wtxt [expr {int($pos)}].0
    alited::tree::RecreateTree $wtree $headers
  }
  return yes
}

proc unit::MoveUnits {wtree to itemIDs f1112} {
  # save the headers of moved items (as unique references)
  namespace upvar ::alited al al
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
  # find the item IDs (by headers) and move items one by one
  set ok yes
  foreach hd $headers {
    foreach item [alited::tree::GetTree] {
      lassign $item lev cnt ID
      if {[GetHeader $wtree $ID] eq $hd} {
        set ok [MoveUnit $wtree $to $ID $headers $f1112]
        break
      }
    }
    if {!$ok} break
  }
  after idle "set alited::al(RECREATE) 1"
}

proc unit::GetHeader {wtree ID {NC ""}} {

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

proc unit::BranchLines {ID} {
  # Gets a line range of a branch.
  #   ID - ID of the branch

  set branch [alited::tree::GetTree $ID]
  set l1 [lindex $branch 0 4 0]
  set l2 [lindex $branch end 4 1]
  return [list $l1 $l2]
}

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

proc unit::SearchByHeader {header} {
  namespace upvar ::alited obPav obPav
  set wtree [$obPav Tree]
  foreach item [alited::tree::GetTree] {
    set ID [lindex $item 2]
    set header2 [GetHeader $wtree $ID]
    if {$header eq $header2} {return $ID}
  }
  return ""
}

proc unit::SelectByHeader {header line} {
  if {[set ID [SearchByHeader $header]] ne ""} {
    after idle "alited::tree::NewSelection $ID $line"
  }
}

proc unit::Modified {TID wtxt {l1 0} {l2 0} args} {

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
    }
    if {$al(TREE,isunits) && (![info exists al(RECREATE)] || $al(RECREATE))} {
      if {$l1<$l2 || $al(LEAF) && [regexp $al(RE,leaf2) $args] || \
      !$al(LEAF) && [regexp $al(RE,proc2) $args]} {
        alited::tree::RecreateTree
      } elseif {[lsearch -index 4 $al(_unittree,$TID) $l1]>-1} {
        alited::tree::RecreateTree
      } else {
        set line [$wtxt get $l1.0 $l1.end]
        if {$al(LEAF) && [regexp $al(RE,leaf) $line] || \
        !$al(LEAF) && [regexp $al(RE,proc) $line]} {
          alited::tree::RecreateTree
        }
      }
    }
  }
  alited::main::ShowHeader
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
