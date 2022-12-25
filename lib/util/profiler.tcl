#######################################################################
# Name:    cp_profiler.tcl
# Author:  Federico Ferri (+ Alex Plotnikov as a wrapper)
# Date:    12/22/2022
# Brief:   Wraps the Tcl profiler originally made by Federico Ferri.
# License: MIT.
#######################################################################

namespace eval ::PR {
  namespace export start end
  namespace ensemble create
}

# ________________________ profiler _________________________ #

namespace eval ::PR::profiler {
  variable cnt
  variable sum
  variable min
  variable max
  variable cmdlist {}
  variable tmstart 0
  variable tmend 0
  variable tmp

  proc add {cmdlist_a} {
    variable cmdlist
    set cmdlist [concat $cmdlist $cmdlist_a]
    set cmdlist [lsort -unique $cmdlist]
  }

  proc enter {cmd op} {
    variable db
    lappend db [list [clock microseconds] 1 $cmd]
  }

  proc leave {cmd code result op} {
    variable db
    lappend db [list [clock microseconds] 0 $cmd]
  }

  proc begin {args} {
    variable cmdlist
    variable tmstart
    foreach cmd $cmdlist {
      trace add execution $cmd enter ::PR::profiler::enter
      trace add execution $cmd leave ::PR::profiler::leave
    }
    set tmstart [clock microseconds]
  }

  proc end {args} {
    variable cmdlist
    variable tmstart
    variable tmend
    variable db
    variable cnt
    variable sum
    set tmend [clock microseconds]
    foreach cmd $cmdlist {
      trace remove execution $cmd enter ::PR::profiler::enter
      trace remove execution $cmd leave ::PR::profiler::leave
    }
    set under [string repeat - 99]
    puts $under
    if {![llength $cmdlist]} {
      puts {Nothing to profile. Provide a list of command(s) for "::PR start ?command ...?"}
      puts $under
      return
    }
    array set tmp {}
    array set cnt {}
    array set sum {}
    array set min {}
    array set max {}
    set totaltime 0
    foreach i $db {
      lassign $i clk enter cmdline
      set cmd [lindex $cmdline 0]
      if {![info exists cnt($cmd)]} {set cnt($cmd) 0}
      if {![info exists sum($cmd)]} {set sum($cmd) 0}
      if {![info exists min($cmd)]} {set min($cmd) 0}
      if {![info exists max($cmd)]} {set max($cmd) 0}
      if {$enter} {
        lappend tmp($cmd) $clk
      } else {
        set delta [expr {$clk-[lindex $tmp($cmd) end]}]
        if {[llength $tmp($cmd)] == 1} {
          unset tmp($cmd)
        } else {
          set tmp($cmd) [lrange $tmp($cmd) 0 end-1]
        }
        incr cnt($cmd) 1
        incr sum($cmd) $delta
        incr totaltime $delta
        if {$min($cmd) == 0 || $delta < $min($cmd)} {set min($cmd) $delta}
        if {$max($cmd) == 0 || $delta > $max($cmd)} {set max($cmd) $delta}
      }
    }
    set db {}
    puts "Total time: [expr {($tmend-$tmstart)/1000.0}] ms ([format %.2f%% [expr {$totaltime*100.0/($tmend-$tmstart)}]] overhead+non-profiled commands)\n"
    puts [format "%-30s %-12s %-12s %-12s %-12s %-8s %s" \
      command min max avg total calls percent]
    puts $under
    for {set i [llength $cmdlist]} {$i} {} {
      set cmd [lindex $cmdlist [incr i -1]]
      if {![info exists cnt($cmd)]} {set cmdlist [lreplace $cmdlist $i $i]}
    }
    set cmdlist [lsort -decreasing -command ::PR::profiler::compare $cmdlist]
    foreach cmd $cmdlist {
      set avg [expr {int(1.0*$sum($cmd)/$cnt($cmd))}]
      set percent [expr {$sum($cmd)*100.0/($totaltime)}]
      puts [format "%-30s %-12s %-12s %-12s %-12s %-8s %.2f%%" \
        $cmd $min($cmd) $max($cmd) $avg $sum($cmd) $cnt($cmd) $percent]
    }
    puts $under
  }
  #_______________________

  proc compare {a b} {
    # Compares numbers.
    #   a - 1st number
    #   b - 2nd number

    variable sum
    if {$sum($a) < $sum($b)} {
      return -1
    } elseif {$sum($a) > $sum($b)} {
      return 1
    }
    return [string compare $a $b]
  }

  ## ________________________ EONS profiler _________________________ ##

}

# ________________________ PR _________________________ #

# It's a wrapper for profiler.
# Use "PR start {commands}" to start profiling.
# Use "PR end" to end profiling and output results.

proc ::PR::start {args} {
  # Starts profiling, with an optional list of commands to be profiled.

  foreach cmd $args {::PR::profiler::add $cmd}
  ::PR::profiler::begin
}
#_______________________

proc ::PR::end {args} {
  # Ends profiling.

  ::PR::profiler::end
}

# ________________________ EOF _________________________ #
