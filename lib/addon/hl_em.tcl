#! /usr/bin/env tclsh
###########################################################
# Name:    hl_em.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 13, 2023
# Brief:   Handles highlighting .em files (of e_menu).
# License: MIT.
###########################################################

# _________________________ hl_em ________________________ #

namespace eval hl_em {
}
#_______________________

proc hl_em::init {w font szfont args} {
  # Initializes highlighting .em text (e_menu's menu).
  #   w - the text
  #   font - font
  #   szfont - font's size
  #   args - highlighting colors

  lassign $args clrCOM fg1 clrSTR clrVAR fg3 bg2
  if {[::apave::obj csDark]} {
    set fg2 black
  } else {
    set fg2 white
  }
  dict set font -weight bold
  $w tag config tagRSIM -font $font -foreground $fg1
  $w tag config tagMARK -font $font -foreground $bg2
  $w tag config tagSECT -font $font -foreground $fg2 -background $bg2
  dict set font -weight normal
  dict set font -slant italic
  $w tag config tagCMNT -font $font -foreground $fg3
  foreach t {tagRSIM tagMARK tagSECT tagCMNT} {after idle $w tag raise $t}
  return [namespace current]::line
}

# _________________________ borrowed from e_menu ________________________ #

proc hl_em::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of .em text (e_menu's menu).
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  foreach t {RSIM MARK SECT CMNT} {$w tag remove tag$t $il.0 $il.end}
  set res no
  lassign [getRSIM $line {ITEM\s*=|SEP\s*=|%M[^ ] |%C |\[MENU\]\s*$|\[OPTIONS\]\s*$|\[HIDDEN\]\s*$|\[DATA\]\s*$|^\s*#}] marker pg ln
  if {$marker ne {}} {
    set p1 [string first $marker $line]
    set p2 [expr {$p1+[string length $marker]}]
    if {$pg ne {-}} {
      set tag tagRSIM
    } else {
      switch -- [string index $ln 0] {
        \[ {set tag tagSECT}
        \# {set tag tagCMNT; set p2 end}
        default {
          set tag tagMARK
          if {[string first = $marker]>0} {set p2 end}
        }
      }
    }
    $w tag add $tag $il.$p1 $il.$p2
    set res yes
  }
  return $res
}
#_______________________

proc hl_em::getRSIM {line {markers {}}} {
  # Gets R:, R/ etc type from a line.

  if {[regexp {^\s*[RSIM]{1}[WE]?:\s*} $line]} {
    set div :
  } elseif {[regexp {^\s*[RSIM]{1}[WE]?/\s*} $line]} {
    set div /
  } else {
    if {$markers ne {}} {
      set marker [lindex [regexp -inline "^($markers)" $line] 0]
      return [list $marker - [string trim $line]]
    }
    return {}
  }
  set line [string trim $line]
  set i [string first $div $line]
  set typ [string range $line 0 $i]
  set prog [string trimleft [string range $line $i+1 end]]
  return [list $typ $prog $line]
}

# ________________________ EOF _________________________ #
