#! /usr/bin/env tclsh
###########################################################
# Name:    hl_md.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 11, 2023
# Brief:   Handles highlighting .md files (markdown).
# License: MIT.
###########################################################

namespace eval hl_md {}
#_______________________

proc hl_md::init {w font szfont args} {
  # Initializes highlighting .md text (markdown).
  #   w - the text
  #   font - the text's font
  #   szfont - the font's size
  #   args - highlighting colors

  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT
  dict set font -size $szfont
  $w tag config tagCMNT -font $font -foreground $clrCMN
  $w tag config tagAPOS -font $font -foreground $clrVAR
  dict set font -weight bold; dict set font -slant italic
  $w tag config tagBOIT -font $font -foreground $clrVAR
  dict set font -weight normal
  $w tag config tagITAL -font $font -foreground $clrVAR
  dict set font -weight bold;  set font [dict remove $font -slant]
  $w tag config tagBOLD -font $font -foreground $clrVAR
  $w tag config tagLIST -font $font -foreground $clrCOM
  dict set font -weight normal
  $w tag config tagLINK -font $font -foreground $clrOPT
  $w tag config tagTAG -font $font -foreground $clrSTR
  foreach t {LINK TAG CMNT APOS BOIT ITAL BOLD LIST} {after idle $w tag raise tag$t}
  foreach t {6 5 4 3 2 1} {
    dict set font -weight bold
    dict set font -size [expr {$szfont + [incr sz] -1}]
    $w tag config tagHEAD$t -font $font -foreground $clrPROC
    after idle $w tag raise tagHEAD$t
  }
  return [namespace current]::line
}
#_______________________

proc hl_md::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of .md text (markdown).
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  foreach t {LINK TAG CMNT APOS BOIT ITAL BOLD LIST} {$w tag remove tag$t $il.0 $il.end}
  foreach t {6 5 4 3 2 1} {$w tag remove tagHEAD$t $il.0 $il.end}
  if {[string match "    *" $line] || [string match "\t*" $line]} {
    return no ;# Tcl code to be processed by hl_tcl.tcl
  }
  lassign [regexp -inline "^#{1,6}\[^#\]" $line] lre
  if {$lre ne {}} {
    set p1 [expr {min(6,max(1,[string length $lre]-1))}]
    $w tag add tagHEAD$p1 $il.$p1 $il.end
    $w tag add tagCMNT $il.0 $il.$p1
    return yes
  }
  lassign [regexp -inline {^(\s*[*+-]\s)} $line] lre
  if {$lre ne {}} {
    set p1 [string length $lre]
    $w tag add tagLIST $il.0 $il.$p1
    set line [string replace $line [incr p1 -2] $p1 { }]
  }
  set apos [regexp -inline -all -indices {(^|[^`])+(`[^`]+`)+([^`]|$)} $line]
  foreach {- - l2 -} $apos {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add tagCMNT $il.$p1 $il.[incr p1]
      $w tag add tagAPOS $il.$p1 $il.$p2
      $w tag add tagCMNT $il.$p2 $il.[incr p2]
    }
  }
  set italic [regexp -inline -all -indices {(^|[^*])+(\*[^*]+\*)+([^*]|$)} $line]
  foreach {- - l2 -} $italic {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add tagCMNT $il.$p1 $il.[incr p1]
      $w tag add tagITAL $il.$p1 $il.$p2
      $w tag add tagCMNT $il.$p2 $il.[incr p2]
    }
  }
  set bold [regexp -inline -all -indices {(^|[^*])+(\*\*[^*]+\*\*)+([^*]|$)} $line]
  foreach {- - l2 -} $bold {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add tagCMNT $il.$p1 $il.[incr p1 2]
      $w tag add tagBOLD $il.$p1 $il.[incr p2 -1]
      $w tag add tagCMNT $il.$p2 $il.[incr p2 2]
    }
  }
  set bolditalic [regexp -inline -all -indices {(^|[^*])+(\*\*\*[^*]+\*\*\*)+([^*]|$)} $line]
  foreach {- - l2 -} $bolditalic {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add tagCMNT $il.$p1 $il.[incr p1 3]
      $w tag add tagBOIT $il.$p1 $il.[incr p2 -2]
      $w tag add tagCMNT $il.$p2 $il.[incr p2 3]
    }
  }
  set links [regexp -inline -all -indices {(\[{1}[^\(\)]+\]{1}\({1}[^\(\)]+\){1})||(&[a-zA-Z]+;)} $line]
  foreach l2 $links {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add tagLINK $il.$p1 $il.[incr p2]
    }
  }
  set tags [regexp -inline -all -indices {<{1}/?\w+[^>]*>{1}} $line]
  foreach l2 $tags {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add tagTAG $il.$p1 $il.[incr p2]
    }
  }
  return yes
}

# ________________________ EOF _________________________ #
