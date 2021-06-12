#! /usr/bin/env tclsh
###########################################################
# Name:    indent.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/11/2021
# Brief:   Handles indenting Tcl file.
# License: MIT.
###########################################################

namespace eval indent {
}

proc indent::indent {tclcode pad indcnt} {

  set lines [split $tclcode \n]
  set out {}
  set nquot 0   ;# count of quotes
  set ncont 0   ;# count of continued strings
  set padst [string repeat { } $pad]
  foreach orig $lines {
    incr lineindex
    if {$lineindex>1} {append out \n}
    set newline [string trim $orig]
    if {$newline eq {}} continue
    set is_quoted $nquot
    set is_continued $ncont
    if {[string index $orig end] eq "\\"} {
      incr ncont
    } else {
      set ncont 0
    }
    set npad [expr {$indcnt * $pad}]
    set line [string repeat $padst $indcnt]$newline
    set ns [set nl [set nr [set body 0]]]
    if {[string index $newline 0] ne {#}} {
      for {set i 0; set n [string length $newline]} {$i<$n} {incr i} {
        set ch [string index $newline $i]
        if {$ch eq "\\"} {
          set ns [expr {[incr ns] % 2}]
        } elseif {!$ns} {
          if {$ch eq {"}} {
            set nquot [expr {[incr nquot] % 2}]
          } elseif {!$nquot} {
            switch $ch {
              "\{" {
                if {[string range $newline $i $i+2] eq "\{\"\}"} {
                  # quote in braces - correct (though tricky)
                  incr i 2
                } else {
                  incr nl
                  set body -1
                }
              }
              "\}" {
                incr nr
                set body 0
              }
            }
          }
        } else {
          set ns 0
        }
      }
    }
    set nbbraces [expr {$nl - $nr}]
    incr totalbraces $nbbraces
    if {$totalbraces<0} {
      set msg [msgcat::mc "The line %n: unbalanced brace!"]
      set msg [string map [list %n $lineindex] $msg]
      alited::msg ok err $msg
      return {}
    }
    incr indcnt $nbbraces
    if {$nbbraces==0} { set nbbraces $body }
    if {$is_quoted || $is_continued} {
      set line $orig     ;# don't touch quoted and continued strings
    } else {
      set np [expr {- $nbbraces * $pad}]
      if {$np>$npad} { ;# for safety too
        set np $npad
      }
      set line [string range $line $np end]
    }
    append out $line
  }
  return $out
}

proc indent::normalize {} {

  set txt [alited::main::CurrentWTXT]
  set pad $alited::al(prjindent)
  set indcnt 0
  if {$pad<1} {
    alited::msg ok err "No indentation set.\nSee 'Setup/Projects/Options'."
    return
  }
  set msg [msgcat::mc "Correct the indentation of \"%f\" ?"]
  set msg [string map [list %f [file tail [alited::bar::FileName]]] $msg]
  if {[alited::msg yesno ques $msg YES]} {
    set contents [$txt get 1.0 {end -1 chars}]
    set contents [indent $contents $pad $indcnt]
    if {$contents ne {}} {
      $txt replace 1.0 end $contents
    }
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
