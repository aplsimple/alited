#! /usr/bin/env tclsh
###########################################################
# Name:    hl_html.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 13, 2023
# Brief:   Handles highlighting .htm, .html files.
# License: MIT.
###########################################################

namespace eval hl_html {}
#_______________________

proc hl_html::init {w font szfont args} {
  # Initializes highlighting .html text.
  #   w - the text
  #   font - the text's font
  #   szfont - the font's size
  #   args - highlighting colors

  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT
  dict set font -size $szfont
  $w tag config htmVAL -font $font -foreground $clrSTR
  $w tag config htmARG -font $font -foreground $clrOPT
  dict set font -weight bold
  $w tag config htmTAG -font $font -foreground $clrCOM
  dict set font -weight normal
  dict set font -slant italic
  $w tag config htmCMN -font $font -foreground $clrCMN
  foreach t {TAG CMN} {after idle $w tag raise htm$t}
  return [namespace current]::line
}
#_______________________

proc hl_html::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of .html text.
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  foreach t {TAG VAL ARG CMN} {$w tag remove htm$t $il.0 $il.end}
  if {$prevQtd==-1} {
    # comments continued (would work with 1 continued line)
    set i [string first --> $line]
    if {$i<0} {
      $w tag add htmCMN $il.0 $il.end
      return -1
    }
    set line [string repeat { } [incr i 2]][string range $line [incr i] end]
    $w tag add htmCMN $il.0 $il.$i
  }
  set specs [regexp -inline -all -indices {&[a-zA-Z]+;} $line]
  foreach l2 $specs {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add htmTAG $il.$p1 $il.[incr p2]
    }
  }
  set htms [regexp -inline -all -indices {(<{1}/?\w+)([^>]*>{1})} $line]
  foreach {l1 l2 -} $htms {
    lassign $l1 p1 p2
    if {$p1<$p2} {
      lassign $l2 r1 r2
      $w tag add htmTAG $il.$r1 $il.[incr r2]
      $w tag add htmTAG $il.$p2 $il.[incr p2]
      set subline [$w get $il.$r2 $il.[incr p2 -1]]
      # inside a tag: options may be quoted and not
      while 1 {
        # first, get an option's name
        lassign [lindex [regexp -inline -indices {\w+=} $subline] 0] p1 p2
        if {$p1 eq {}} break
        # then, get an option's value
        incr p2
        if {[string index $subline $p2] eq {"}} {
          lassign [lindex [regexp -inline -indices {"[^"]*\"} $subline] 0] s1 s2
          if {$s2 eq {}} {
            set s1 $p2
            set s2 [string length $subline]
          } else {
            incr s2
          }
        } else {
          set s1 $p2
          set s2 [string first { } $subline $s1]
          if {$s2<0} {set s2 [string length $subline]}
        }
        # erase the currently processed option
        if {$p1 > $s2} break
        set subline [string replace $subline $p1 $s2 [string repeat { } [expr {$s2-$p1+1}]]]
        # highlight name & value
        incr p1 $r2
        incr p2 $r2
        $w tag add htmARG $il.$p1 $il.$p2
        incr s1 $r2
        incr s2 $r2
        $w tag add htmVAL $il.$s1 $il.$s2
      }
    }
  }
  set cmns [regexp -inline -all -indices {<{1}![^>]*>{1}} $line]
  foreach l2 $cmns {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add htmCMN $il.$p1 $il.[incr p2]
    }
  }
  set cmns [regexp -inline -all -indices {<{1}!--[^>]*$} $line]
  foreach l2 $cmns {
    lassign $l2 p1 p2
    if {$p1<$p2} {
      $w tag add htmCMN $il.$p1 $il.end
      return -1 ;# comments to be continued
    }
  }
  return 0
}

# ________________________ EOF _________________________ #
