#######################################################################
# etprof - trivial exclusive time profiler
# I wrote this because my feeling is that exclusiveRunTime info
# of the TclLib's profiler is broken.
#
# Usage: source it as first line in your application
#        and check the standard output for profiling information
#        at runtime.
#
# Copyright (C) 2004 Salvatore Sanfilippo
#######################################################################

# ________________________ ::etprof _________________________ #

namespace eval ::etprof {
  variable tracedcommands [list *]  ;# patterns of traced commands' names
}

# Unset the specified var and returns the old content
proc ::etprof::getunset varName {
  upvar $varName var
  set t $var
  unset var
  return $t
}

proc ::etprof::lpop listVar {
  upvar $listVar list
  set retval [lindex $list end]
  set list [lrange [::etprof::getunset list] 0 end-1]
  return $retval
}

proc ::etprof::TraceHandler {name cmd args} {
  # We need to misure the elapsed time as early as possible.
  set enter_clicks [clock clicks]
  set elapsed [expr {$enter_clicks-$::etprof::timer}]


  #####################################################################
  # Starting from this point it's possible to do potentially slow
  # operations. They will not be accounted as time spent in procedures
  #####################################################################

  # Show profiling information every 50000 calls to the profiler
  if {[incr ::etprof::hits] >= 50000} {
    set ::etprof::hits 0
    ::etprof::printLiveInfo
  }

  # The following is a flag that may be turned on inside [switch].
  # If true the [clock clicks] value will be added to the cumulative_timers
  # list as later as possible before to exit this function.
  set non_recursive_enter 0;
  switch -- [lindex $args end] {
    enter {
      # Try to guess the caller function. If we are at toplevel
      # set it to TOPLEVEL, in the hope there isn't another function
      # with this name.
      if {[info level] == 1} {
        set caller TOPLEVEL
      } else {
        # Otherwise use [info level] to get the caller name.
        set caller [lindex [info level -1] 0]
        set callerns [uplevel 1 namespace current]
        set caller [::etprof::fullyQualifiedName $caller $callerns]
      }

      set depth [incr ::etprof::depth($name)]
      ::etprof::enterHandler $name $caller $elapsed
      if {$depth == 1} {
        set non_recursive_enter 1
      }
    }
    leave {
      if {$::etprof::depth($name) == 1} {
        set t [lpop ::etprof::cumulative_timers]
        set cum_elapsed [expr {$enter_clicks-$t}]
        incr ::etprof::cumulative($name) $cum_elapsed
      }
      ::etprof::leaveHandler $name $elapsed
      incr ::etprof::depth($name) -1
    }
  }

  #####################################################################
  # Don't add slow operations after this comment.
  # The following lines should only be used to get [clock clicks]
  # values at near as possible to the leave from this function.
  #####################################################################

  # Add the time spent inside the handler to every element
  # of the cumulative timers list. Note that the time needed
  # to perform the following operation will be accounted to user code
  # as comulative, but from worst-case tests performed this does not
  # seems to alter the output in a significant way.
  if {[llength $::etprof::cumulative_timers]} {
    set spent [expr {[clock clicks]-$enter_clicks}]
    foreach t $::etprof::cumulative_timers {
      lappend newlist [expr {$t+$spent}]
    }
    set ::etprof::cumulative_timers $newlist
  }
  # Note that we take the 'timer' sample as the last operation.
  # Basically this profiler try to be more accurate in
  # the exclusive measure.
  if {$non_recursive_enter} {
    lappend ::etprof::cumulative_timers [clock clicks]
  }
  set ::etprof::timer [clock clicks]
}

proc ::etprof::enterHandler {name caller elapsed} {
  # The caller may not exists in the arrays because may be a built-in
  # like [eval].
  if {[info exists ::etprof::exclusive($caller)]} {
    incr ::etprof::exclusive($caller) $elapsed
  }
  incr ::etprof::calls($name)
}

proc ::etprof::leaveHandler {name elapsed} {
  # The program is leaving the function. Add the current time value
  # to it. And reset the value.
  incr ::etprof::exclusive($name) $elapsed
}

# That comes from the TclLib's profiler, seems working but
# I wonder if there is a better (faster) way to get the fully-qualified
# names.
proc ::etprof::fullyQualifiedName {name ns} {
  if { ![string equal $ns "::"] } {
    if { ![string match "::*" $name] } {
      set name "${ns}::${name}"
    }
  }
  if { ![string match "::*" $name] } {
    set name "::$name"
  }
  return $name
}

# That comes from the TclLib's profiler, seems working but
# I wonder if there is a better way to get the fully-qualified
# name of the procedure to create without pattern matching.
proc ::etprof::profProc {name arglist body} {
  # Get the fully qualified name of the proc
  set ns [uplevel [list namespace current]]
  set name [::etprof::fullyQualifiedName $name $ns]
  # If the proc call did not happen at the global context and it did not
  # have an absolute namespace qualifier, we have to prepend the current
  # namespace to the command name
  if { ![string equal $ns "::"] } {
    if { ![string match "::*" $name] } {
      set name "${ns}::${name}"
    }
  }
  if { ![string match "::*" $name] } {
    set name "::$name"
  }

  uplevel 1 [list ::etprof::oldProc $name $arglist $body]
  trace add execution $name {enter leave} \
          [list ::etprof::TraceHandler $name]
  ::etprof::initProcInfo $name
  return
}

proc ::etprof::initProcInfo name {
  set ::etprof::calls($name) 0
  set ::etprof::exclusive($name) 0
  set ::etprof::cumulative($name) 0
  set ::etprof::depth($name) 0
}

proc ::etprof::init {} {
  rename ::proc ::etprof::oldProc
  rename ::etprof::profProc ::proc
  set ::etprof::timer [clock clicks]
  set ::etprof::hits 0
  array set ::etprof::exclusive {}
  array set ::etprof::cumulative {}
  array set ::etprof::calls {}
  set ::etprof::cumulative_timers {}
  ::etprof::initProcInfo TOPLEVEL
  set ::etprof::calls(TOPLEVEL) 1
  set ::etprof::cumulative(TOPLEVEL) {NOT AVAILABLE}
  return
}

proc ::etprof::printInfoLine {ml name exTot exTotPerc callsNum avgExPerCall cumulTot {sep |}} {
  puts [format "$sep%-$ml.${ml}s$sep%14.14s$sep%6.6s$sep%8.8s$sep%14.14s$sep%14.14s$sep" \
    $name $exTot $exTotPerc% $callsNum $avgExPerCall $cumulTot]
}

proc ::etprof::printInfoSeparator {ml} {
  set hline [string repeat - 50]
  ::etprof::printInfoLine $ml $hline $hline $hline $hline $hline $hline +
}

proc ::etprof::percentage {part total} {
  if {$total<=0} {
    set p 0
  } else {
    set p [expr {($part*100.0)/$total}]
  }
  format "%.02f" $p
}

proc ::etprof::printLiveInfo {} {
  variable tracedcommands
  set info {}
  foreach {key val} [array get ::etprof::exclusive] {
    foreach tc $tracedcommands {
      if {[string match $tc $key]} {
        lappend info [list $key $val]
        break
      }
    }
  }
  set info [lsort -decreasing -index 1 -integer $info]
  # Sum all the exclusive times to print infos in percentage
  set totalExclusiveTime 0
  set namemaxlen 12
  foreach i $info {
    foreach {name exclusiveTime} $i break
    if {[set ll [string length $name]]>$namemaxlen} {
      set namemaxlen $ll
    }
    incr totalExclusiveTime $exclusiveTime
  }
  set namemaxlen [expr {min($namemaxlen,50)}]
  ::etprof::printInfoSeparator $namemaxlen
  ::etprof::printInfoLine $namemaxlen PROCNAME EXCLUSIVETOT {} CALLNUM AVGPERCALL CUMULTOT
  ::etprof::printInfoSeparator $namemaxlen
  foreach i $info {
    foreach {name exclusiveTime} $i break
    set cumulativeTime $::etprof::cumulative($name)
    set calls $::etprof::calls($name)
    if {$calls} {
      set avgTimePerCall [expr {int($exclusiveTime/$calls)}]
    } else {
      set avgTimePerCall 0
    }
    if {$::etprof::depth($name)} {
      set cumulativeTime "(*)$cumulativeTime"
    }
    ::etprof::printInfoLine $namemaxlen $name $exclusiveTime [::etprof::percentage $exclusiveTime $totalExclusiveTime] $calls $avgTimePerCall $cumulativeTime
  }
  ::etprof::printInfoSeparator $namemaxlen
  puts "(*) = Incomplete result, program inside that function."
}

# ________________________ ::PR _________________________ #

# It's a wrapper of ::etprof.
# Use "::PR start ?pattern ...?" to start profiling.
# Use "::PR end" to end profiling and output results.
# The ?pattern ...? are glob patterns of command names.

namespace eval ::PR {
  namespace export start end
  namespace ensemble create
  proc start {args} {
    if {[llength $args]} {
      set ::etprof::tracedcommands $args
    }
    ::etprof::init
  }
  proc end {} {::etprof::printLiveInfo} ;# alited_checked
}
