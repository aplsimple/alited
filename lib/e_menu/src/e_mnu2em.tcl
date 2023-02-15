#! /usr/bin/env tclsh
###########################################################
# Name:    e_mnu2em.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    02/06/2023
# Brief:   Handles converting .mnu files to .em files.
# License: MIT.
###########################################################

proc menuit {line lt left {a 0}} {
  # taken from old e_menu.tcl

  set i [string first $lt $line]
  if {$i < 0} {return {}}
  if {$left} {
    return [string range $line 0 [expr $i+($a)]]
  } else {
    return [string range $line $i+[string length $lt] end]
  }
}
#_______________________

proc getRSIM {line} {
  # Gets R:, R/ etc type from a line.

  if {[regexp {^\s*[RSIM]{1}[WE]?:\s*} $line]} {
    set div :
  } elseif {[regexp {^\s*[RSIM]{1}[WE]?/\s*} $line]} {
    set div /
  } else {
    return {}
  }
  set line [string trim $line]
  set i [string first $div $line]
  set typ [string range $line 0 $i]
  return $typ
}
#_______________________

proc convert {fin fout} {
  # Converts .mnu file to .em file.
  #   fin - .mnu file name
  #   fout - .em file name

  if {[catch {set chin [open $fin]} err]} {
    puts $err
    return no
  }
  if {[catch {set chout [open $fout w]} err]} {
    close $chin
    puts $err
    return no
  }
  set prname ?
  set OPTIONS [set MENU [set HIDDEN [set DATA [list]]]]
  set isopt [set ishidden 0]
  set ismenu 1
  foreach line [split [read $chin] \n] {
    set ln [string trim $line]
    switch -exact -- $ln {
      {[OPTIONS]} {
        set prname ?
        set isopt 1
        set ismenu [set ishidden 0]
        continue
      }
      {[MENU]} {
        set prname ?
        set ismenu 1
        set isopt [set ishidden 0]
        continue
      }
      {[HIDDEN]} {
        set prname ?
        set ishidden 1
        set ismenu [set isopt 0]
        continue
      }
    }
    if {$isopt} {
      if {[string first %# $ln] == 0} {
        lappend DATA $line  ;# writeable command
      } else {
        lappend OPTIONS $line
      }
    }
    if {$ismenu || $ishidden} {
      if {[regexp {^%M[^ ] } $ln]} {
        lappend MENU $line ;# body of macro
        continue
      }
      set typ [getRSIM $line]
      if {$typ ne {}} {
        set line [menuit $line $typ 0]
        set name [string trim [menuit $line $typ 1 -1]]
        set prog [string trimleft [menuit $line $typ 0]]
        if {$name in {{} {-}} && ($prog eq {} || [string is integer $prog])} {
          set line "SEP = $name$prog"
          set prname ?
        } else {
          if {$prname ne $name} {
            if {$ismenu} {
              lappend MENU "ITEM = $name"
            } else {
              lappend HIDDEN "ITEM = $name"
            }
            set prname $name
          }
          if {[string match M* $typ]} {
            set prog [string map {.mnu .em} $prog]
          }
          set line "$typ $prog"
        }
      }
      if {$ismenu} {
        lappend MENU $line
      } else {
        lappend HIDDEN $line
      }
    }
  }
  set lf {}
  foreach sect {OPTIONS MENU HIDDEN DATA} {
    set slist [set $sect]
    if {[lindex $slist end] eq {}} {
      catch {set slist [lreplace $slist end end]}
    }
    if {[llength $slist]} {
      puts $chout "$lf\[$sect\]\n"
      foreach line $slist {puts $chout $line}
      set lf \n
    }
  }
  close $chin
  close $chout
  return yes
}
#_______________________

set iforce [lsearch $::argv -force]
set force [expr {$iforce>-1}]
if {$force} {
  set ::argv [lreplace $::argv $iforce $iforce]
  set ::argc [llength $::argv]
}
if {$::argc>1} {
  puts "To convert .mnu files to .em files, run this script as follows: \
    \n  tclsh [file tail [info script]] ?-force? ?mnudir?"
  exit
}
if {$::argc<1} {
  set dir .
} else {
  set dir [lindex $::argv 0]
}
set dir [file normalize $dir]

puts "Converting .mnu to .em in $dir :"
foreach fin [glob -nocomplain [file join $dir *.mnu]] {
  set fout [file rootname $fin].em
  if {!$force && [file exists $fout]} {
    puts "  [file tail $fout] already exists."
    continue
  }
  if {[convert $fin $fout]} {
    set fin [file tail $fin]
    set ll [expr {max(12,[string length $fin])}]
    set fin [string range $fin\ [string repeat { } $ll] 0 $ll]
    puts "  converted $fin to $fout"
  }
}
exit