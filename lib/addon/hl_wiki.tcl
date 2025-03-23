#! /usr/bin/env tclsh
###########################################################
# Name:    hl_wiki.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 11, 2023
# Brief:   Handles highlighting files of wiki.tcl-lang.org.
# License: MIT.
###########################################################

namespace eval hl_wiki {
  variable data; array set data {}
}
#_______________________

proc hl_wiki::init {w font szfont args} {
  # Initializes highlighting .wiki text.
  #   w - the text
  #   font - the text's font
  #   szfont - the font's size
  #   args - highlighting colors

  variable data
  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT
  dict set font -size $szfont
  $w tag config wikiCMNT -font $font -foreground $clrCMN
  $w tag config wikiAPOS -font $font -foreground $clrCOMTK
  $w tag config wikiCTGR -font $font -foreground $clrPROC
  dict set font -slant italic
  $w tag config wikiITAL -font $font
  dict set font -weight bold;  set font [dict remove $font -slant]
  $w tag config wikiBOLD -font $font
  $w tag config wikiLIST -font $font -foreground $clrCOM
  dict set font -weight normal
  $w tag config wikiLINK -font $font -foreground $clrOPT
  $w tag config wikiTAG -font $font -foreground $clrSTR
  foreach t {ITAL BOLD LIST} {after idle $w tag raise wiki$t}
  foreach t {6 5 4 3 2 1} {
    dict set font -weight bold
    dict set font -size [expr {$szfont + [incr sz] -1}]
    $w tag config wikiHEAD$t -font $font -foreground $clrPROC
    after idle $w tag raise wikiHEAD$t
  }
  set data($w,code) [list]
  return [namespace current]::line
}
#_______________________

proc hl_wiki::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of .wiki text.
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  variable data
  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  foreach t {LINK TAG CMNT APOS CTGR ITAL BOLD LIST} {$w tag remove wiki$t $il.0 $il.end}
  foreach t {6 5 4 3 2 1} {$w tag remove wikiHEAD$t $il.0 $il.end}
  if {[string match "    *" $line] || [string match "\t*" $line]} {
    return no ;# Tcl code to be processed by hl_tcl.tcl
  }
  if {[regexp {^\s*<<[^<>]+>>} $line]} {
    $w tag add wikiCTGR $il.0 $il.end
    return yes
  }
  set idxcode [lsearch -exact $data($w,code) $il]
  if {[string trim $line] eq {======}} {
    # add start/end of Tcl code
    if {$idxcode<0} {
      lappend data($w,code) $il
      set data($w,code) [lsort -integer $data($w,code)]
    }
    return yes
  } else {
    # check for Tcl code
    set data($w,code) [lreplace $data($w,code) $idxcode $idxcode]
    if {$idxcode>=0} {return yes}
    set llen [llength $data($w,code)]
    for {set i [set k 0]} {$i<$llen} {} {
      set ilc [lindex $data($w,code) $i]
      if {$ilc>$il} {
        if {$k} {return no} ;# inside Tcl code
        break
      }
      set k [expr {[incr k]%2}]
      if {[incr i]==$llen && $k} {
        return no ;# inside Tcl code
      }
    }
  }
  lassign [regexp -inline "^\\*{1,6}\[^\*\]+\\*{1,6}" $line] lre
  if {$lre ne {}} {
    set lrs [string trimleft $lre *]
    set p1 [expr {min(6,max(1,[string length $lre]-[string length $lrs]))}]
    $w tag add wikiHEAD$p1 $il.$p1 "$il.end -$p1 char"
    $w tag add wikiCMNT $il.0 $il.$p1
    $w tag add wikiCMNT "$il.end -[incr p1] char" $il.end
    return yes
  }
  # list beginning with *, +, -
  lassign [regexp -inline {^(\s+[*+-]\s)} $line] lre
  if {$lre ne {}} {
    set p1 [string length $lre]
    $w tag add wikiLIST $il.0 $il.$p1
    set line [string replace $line [incr p1 -2] $p1 { }]
  }
  # underline beginning with ----
  if {[regexp {^----+\s*$} $line]} {
    $w tag add wikiLIST $il.0 $il.end
  }
  set italic [regexp -inline -all -indices {(?!'<)'{2}(?!').*?'{2}(?!'>)} $line]
  foreach l2 $italic {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add wikiCMNT $il.$p1 $il.[incr p1 2]
      $w tag add wikiITAL $il.$p1 $il.[incr p2 -1]
      $w tag add wikiCMNT $il.$p2 $il.[incr p2 2]
    }
  }
  set bold [regexp -inline -all -indices {(?!'<)'{3}(?!').*?'{3}(?!'>)} $line]
  foreach l2 $bold {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add wikiCMNT $il.$p1 $il.[incr p1 3]
      $w tag add wikiBOLD $il.$p1 $il.[incr p2 -2]
      $w tag add wikiCMNT $il.$p2 $il.[incr p2 3]
    }
  }
  set links [regexp -inline -all -indices {(\[{1})[^\]]+(\]{1})} $line]
  foreach l2 $links {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add wikiLINK $il.$p1 $il.[incr p2]
      foreach l2 [regexp -inline -all -indices {%\|%} $line] {
        lassign $l2 p1 p2
        if {$p1<$p2} {
          $w tag add wikiAPOS $il.$p1 $il.[incr p2]
        }
      }
    }
  }
  set tags [regexp -inline -all -indices {<{1}/?\w+[^>]*>{1}} $line]
  foreach l2 $tags {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add wikiTAG $il.$p1 $il.[incr p2]
    }
  }
  return yes
}

# ________________________ EOF _________________________ #
