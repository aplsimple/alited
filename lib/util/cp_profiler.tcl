#######################################################################
# Name:    cp_profiler.tcl
# Author:  Federico Ferri (+ Alex Plotnikov as a wrapper)
# Date:    12/22/2022
# Brief:   Wraps the Tcl profiler originally made by Federico Ferri.
# License: MIT.
#######################################################################

# ________________________ PR _________________________ #

namespace eval ::PR {
  namespace export start end
  namespace ensemble create
  variable db_t; array set db_t {}   ;# times array
  variable db_c; array set db_c {}   ;# counts array
  variable last [clock microseconds] ;# 'last' initialized (for time delta)
}

## ________________________ profiler by FF _________________________ ##

proc ::PR::profiler {id} {
  # A bit modified profiler originally made by Federico Ferri.
  #   id - checkpoint's ID or "start" or "end"
  # If $id eq "start", it starts the profiling.
  # If $id eq "end", it ends the profiling.
  # All other $id mean checkpoints to be profiled.

  variable db_t
  variable db_c
  variable last
  switch -- $id {
    start {
      set last [clock microseconds]
    }
    end {
      set lres [list]
      foreach ik [array names db_t] {
        lappend lres [list [expr {1.0*$db_t($ik)/$db_c($ik)}] $ik $db_t($ik) $db_c($ik)]
      }
      set lres [lsort -decreasing -command ::PR::compare $lres]
      puts \n[format {%16s %16s %16s %16s} checkpoint: time: count: avgtime:]
      foreach res $lres {
        lassign $res val ik t c
        puts [format {%16s %16s %16s %16.1f} $ik $t $c $val]
      }
      array unset db_t
      array unset db_c
    }
    default {
      set delta [expr {[clock microseconds]-$last}]
      set last [clock microseconds]
      if {[info exists db_t($id)]} {incr db_t($id) $delta} {set db_t($id) $delta}
      if {[info exists db_c($id)]} {incr db_c($id) 1     } {set db_c($id) 1     }
    }
  }
}

## ________________________ additions by AP _________________________ ##

proc ::PR::start {args} {
  # Runs the profiler.
  #   args - if "", starts the profiler, else sets "$args" checkpoint.
  # The checkpoint can be any string, excluding "start" and "end".

  if {$args in {start end}} {
    error "::PR start - checkpoint can't be \"start\" nor \"end\"\n"
  } elseif {[llength $args]} {
    profiler $args
  } else {
    profiler start
  }
}
#_______________________

proc ::PR::end {} {
  # Ends the profiler and outputs its results.
  # After "end", the profiler can be "start"ed again.

  profiler end
}
#_______________________

proc ::PR::compare {a b} {
  # Compares numbers of two items containing "number name ...".
  #   a - 1st item
  #   b - 2nd item

  set a0 [lindex $a 0]
  set b0 [lindex $b 0]
  if {$a0 < $b0} {
    return -1
  } elseif {$a0 > $b0} {
    return 1
  }
  return [string compare [lindex $a 1] [lindex $b 1]]
}

# ________________________ EOF _________________________ #
