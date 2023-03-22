#! /usr/bin/env tclsh
###########################################################
# Name:    hl_ini.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 16, 2023
# Brief:   Handles highlighting .ini files (of e_menu).
# License: MIT.
###########################################################

# _________________________ hl_ini ________________________ #

namespace eval hl_ini {
}
#_______________________

proc hl_ini::init {w font szfont args} {
  # Initializes highlighting .ini text.
  #   w - the text
  #   font - font
  #   szfont - font's size
  #   args - highlighting colors

  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC
  dict set font -weight bold
  $w tag config iniSECT -font $font -foreground $clrPROC
  dict set font -weight normal
  $w tag config iniOPT -font $font -foreground $clrCOM
  $w tag config iniVAL -font $font -foreground $clrSTR
  dict set font -slant italic
  $w tag config iniCMNT -font $font -foreground $clrCMN
  foreach t {SECT OPT VAL CMNT} {after idle $w tag raise ini$t}
  return [namespace current]::line
}
#_______________________

proc hl_ini::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of .ini text.
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  if {[string trim $line] eq {}} {return yes}
  foreach t {SECT OPT VAL CMNT} {$w tag remove ini$t $il.0 $il.end}
  if {[regexp "^\s*#" $line]} {
    $w tag add iniCMNT $il.0 $il.end
    return yes
  }
  lassign [regexp -inline {^\s*\[.+\]\s*$} $line] lre
  if {$lre ne {}} {
    set p1 [string length $lre]
    $w tag add iniSECT $il.0 $il.$p1
    return yes
  }
  set opts [regexp -inline -all -indices {^\s*([^=]+)\s*(=)\s*(.*)$} $line]
  foreach {- l1 - l2} $opts {
    lassign $l1 p1 p2
    if {$p1<$p2} {
      $w tag add iniOPT $il.$p1 $il.[incr p2]
      lassign $l2 p1 p2
      $w tag add iniVAL $il.$p1 $il.[incr p2]
    }
  }
  return yes
}

# ________________________ EOF _________________________ #
