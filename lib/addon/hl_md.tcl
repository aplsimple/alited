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
  $w tag config mdCMNT -font $font -foreground $clrCMN
  $w tag config mdAPOS -font $font -foreground $clrVAR
  dict set font -weight bold; dict set font -slant italic
  $w tag config mdBOIT -font $font -foreground $clrVAR
  dict set font -weight normal
  $w tag config mdITAL -font $font -foreground $clrVAR
  dict set font -weight bold;  set font [dict remove $font -slant]
  $w tag config mdBOLD -font $font -foreground $clrVAR
  $w tag config mdLIST -font $font -foreground $clrCOM
  dict set font -weight normal
  $w tag config mdLINK -font $font -foreground $clrOPT
  $w tag config mdTAG -font $font -foreground $clrSTR
  foreach t {BOIT ITAL BOLD LIST} {after idle $w tag raise md$t}
  foreach t {6 5 4 3 2 1} {
    dict set font -weight bold
    dict set font -size [expr {$szfont + [incr sz] -1}]
    $w tag config mdHEAD$t -font $font -foreground $clrPROC
    after idle $w tag raise mdHEAD$t
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
  foreach t {LINK TAG CMNT APOS BOIT ITAL BOLD LIST} {$w tag remove md$t $il.0 $il.end}
  foreach t {6 5 4 3 2 1} {$w tag remove mdHEAD$t $il.0 $il.end}
  if {[string match "    *" $line] || [string match "\t*" $line]} {
    return no ;# Tcl code to be processed by hl_tcl.tcl
  }
  # header
  lassign [regexp -inline "^#{1,6}\[^#\]" $line] lre
  if {$lre ne {}} {
    set p1 [expr {min(6,max(1,[string length $lre]-1))}]
    $w tag add mdHEAD$p1 $il.$p1 $il.end
    $w tag add mdCMNT $il.0 $il.$p1
    return yes
  }
  # list beginning with *, -, 1. 2. ..
  lassign [regexp -inline {^(\s*(([*+-])|(\d+\.))\s)} $line] lre
  if {$lre ne {}} {
    set p1 [string length $lre]
    $w tag add mdLIST $il.0 $il.$p1
    set line [string replace $line [incr p1 -2] $p1 { }]
  }
  # back apostrophes for code snippets
  set apos [regexp -inline -all -indices {(^|[^`])+(`[^`]+`)+([^`]|$)} $line]
  foreach {- - l2 -} $apos {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add mdCMNT $il.$p1 $il.[incr p1]
      $w tag add mdAPOS $il.$p1 $il.$p2
      $w tag add mdCMNT $il.$p2 $il.[incr p2]
    }
  }
  # font highlightings: italic, bold, bold italic
  set italic [regexp -inline -all -indices {(^|[^*])+(\*[^*]+\*)+([^*]|$)} $line]
  foreach {- - l2 -} $italic {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add mdCMNT $il.$p1 $il.[incr p1]
      $w tag add mdITAL $il.$p1 $il.$p2
      $w tag add mdCMNT $il.$p2 $il.[incr p2]
    }
  }
  set bold [regexp -inline -all -indices {(^|[^*])+(\*\*[^*]+\*\*)+([^*]|$)} $line]
  foreach {- - l2 -} $bold {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add mdCMNT $il.$p1 $il.[incr p1 2]
      $w tag add mdBOLD $il.$p1 $il.[incr p2 -1]
      $w tag add mdCMNT $il.$p2 $il.[incr p2 2]
    }
  }
  set bolditalic [regexp -inline -all -indices {(^|[^*])+(\*\*\*[^*]+\*\*\*)+([^*]|$)} $line]
  foreach {- - l2 -} $bolditalic {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add mdCMNT $il.$p1 $il.[incr p1 3]
      $w tag add mdBOIT $il.$p1 $il.[incr p2 -2]
      $w tag add mdCMNT $il.$p2 $il.[incr p2 3]
    }
  }
  # html link
  set links [regexp -inline -all -indices {(\[{1}[^\(\)]*\]{1}\({1}[^\(\)]+\){1})||(&[a-zA-Z]+;)} $line]
  foreach l2 $links {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add mdLINK $il.$p1 $il.[incr p2]
    }
  }
  # html tag
  set tags [regexp -inline -all -indices {<{1}/?\w+[^>]*>{1}} $line]
  foreach l2 $tags {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add mdTAG $il.$p1 $il.[incr p2]
    }
  }
  return yes
}

# ________________________ EOF _________________________ #
