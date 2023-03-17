#! /usr/bin/env tclsh
###########################################################
# Name:    hl_alm.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 11, 2023
# Brief:   Handles highlighting .alm files (alited macros).
# License: MIT.
###########################################################

namespace eval hl_alm {}
#_______________________

proc hl_alm::init {w font szfont args} {
  # Initializes highlighting .alm text (alited's macro).
  #   w - the text
  #   font - the text's font
  #   szfont - the font's size
  #   args - highlighting colors

  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT
  dict set font -size $szfont
  dict set font -weight bold;
  $w tag config almKEY -font $font -foreground $clrCOM
  dict set font -weight normal
  $w tag config almPATH -font $font -foreground $clrVAR
  $w tag config almARG -font $font -foreground $clrOPT
  dict set font -slant italic
  $w tag config almCMNT -font $font -foreground $clrCMN
  foreach t {KEY PATH ARG CMNT} {after idle $w tag raise alm$t}
  return [namespace current]::line
}
#_______________________

proc hl_alm::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of .alm text (alited's macro).
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  if {[string trim $line] eq {}} {return yes}
  foreach t {KEY PATH ARG CMNT} {$w tag remove alm$t $il.0 $il.end}
  if {[regexp "^\s*#" $line]} {
    $w tag add almCMNT $il.0 $il.end
    return yes
  }
  lassign [regexp -inline {^\s*[^\s]+} $line] lre
  if {$lre ne {}} {
    set p1 [string length $lre]
    $w tag add almKEY $il.0 $il.$p1
  }
  set path [regexp -inline -all -indices {\s{1}[.]{1}[^\s]+} $line]
  foreach l2 $path {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add almPATH $il.$p1 $il.[incr p2]
    }
  }
  set key [regexp -inline -all -indices {\s%.=} $line]
  foreach l2 $key {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add almARG $il.$p1 $il.[incr p2]
    }
  }
  return yes
}

# ________________________ EOF _________________________ #
