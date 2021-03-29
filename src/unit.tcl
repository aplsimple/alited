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

  namespace upvar ::alited al al
  set retlist [set item [set title [list]]]
  set eof {\=#,q@9.*/$3`_!J-}  ;# 'eof' to save a last unit to the retlist
  append textcont "\n$eof"
  set i [set lev [set leaf [set icomleaf -1]]]
  foreach line [split $textcont \n] {
    incr i
    if {[set flag [regexp $al(RE,branch) $line -> cmn1 title]]} {
      # a branch
      set leaf [set icomleaf [set flag1 0]]
      set lev [expr {min(0,[string length $cmn1]-1)}]
    } elseif {[set flag1 "[regexp $al(RE,leaf) $line -> title]"] eq "1" || \
              [set flag2 [regexp $al(RE,abc) $line -> type title]]} {
      set flag [set leaf 1]
    } else {
      set flag [expr {$line eq $eof}]
    }
    if {$flag} {
      if {[llength $item]} {
        set l1 [expr {[lindex $item 4]-1}]
        if {$l1>0 && ![llength $retlist]} {
          # first found at line>1 => create a starting leaf
          lappend retlist [list $lev 0 0 "" 1 $l1]
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

proc unit::MoveUnit {to} {
  namespace upvar ::alited al al obPav obPav
  set TID [alited::bar::CurrentTabID]
  set curunit ""
  set wtree [$obPav Tree]
  set wtxt [$obPav Text]
  foreach item $al(_unittree,$TID) {
    set itemID [alited::tree::ItemID [incr iit]]
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl -CS 23 -hue 0 -fontsize 11
