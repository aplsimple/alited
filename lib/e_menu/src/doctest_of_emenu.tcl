#! /usr/bin/env tclsh
#########################################################################
#
# This utility allows a user to doctest TCL scripts and their data files.
# See README.md for details.
#
#########################################################################
#
# Test cases for TKE e_menu plugin.
# #ARGS<N>: means arguments for 'Run me' menu item.
# First case without "-" will be run:
#
#-ARGS0: /home/apl/PG/Tcl-Tk/projects/pave/paveme.tcl
#-ARGS1: -s 1 -v 1 /home/apl/PG/Tcl-Tk/projects/pave/paveme.tcl
#-ARGS2: -s 0 -v 1 -b 2 /home/apl/PG/Tcl-Tk/projects/pave/paveme.tcl
#-ARGS3: -s 0 -v -1 -b 2 /home/apl/PG/Tcl-Tk/projects/pave/paveme.tcl
#-ARGS4: -s 0 -v 1 -b 2 -b 1 /home/apl/PG/Tcl-Tk/projects/pave/paveme.tcl
#-ARGS5: -v 0 /home/apl/TKE-clone/TKE-clone/plugins/doctest/README.md
#-ARGS6: -v -1 /home/apl/TKE-clone/TKE-clone/plugins/doctest/README.md
#-ARGS7: -v 1 /home/apl/TKE-clone/TKE-clone/plugins/doctest/README.md
#-ARGS8: -v 1 -b factorial /home/apl/PG/Tcl-Tk/projects/doctest/README.md
#-ARGS9: -v 0 -s 0 /home/apl/TKE-clone/TKE-clone/plugins/e_menu/e_menu/e_menu.tcl
#ARGS10: -v 1 /home/apl/PG/Tcl-Tk/projects/doctest/README.md
#
#########################################################################

namespace eval doctest {

  variable SYNOPSIS "This is used for doctesting Tcl code.

Usage:
  tclsh doctest.tcl ?options? filename
where
  filename - path to Tcl source file
  options:
    -s 1 | 0      - safe (default) | unsafe execution
    -v 1 | 0 | -1 - verbose (default) | short | silent mode
    -b block      - name of block to be tested
    --            - switches options off (for filename)

The -b option may be repeated. If -b
omitted, all of the file is checked
for the doctest blocks to execute.
See README.md for details."
  variable TEST       "doctest"
  variable TEST_BEGIN "#% $TEST"
  variable TEST_END   "#> $TEST"
  variable TEST_COMMAND "#%"
  variable TEST_RESULT  "#>"
  variable NOTHING "\nNo\nNo"
  variable ntestedany
  variable UNDER \n[string repeat "=" 60]
  variable HINT1 "

Make the doctest blocks as

  $doctest::TEST_BEGIN ?name-of-block?

  ...
  #% tested-command
  \[#% tested-command\]
  #> output of tested-command
  \[#> output of tested-command\]
  ...

  $doctest::TEST_END

See details in README.md"
  variable options
}

###################################################################
# Show info message, e.g.: MES "Info title" $st == $BL_END \n\n ...

proc doctest::MES {title args} {

  puts "\n $title:"
  foreach ls $args {
    puts ""
    foreach l [split $ls \n] {
      puts " $l"
    }
  }
}

proc doctest::ERR {args} { MES ERROR {*}$args }

###################################################################
# Get line stripped of spaces and uppercased

proc doctest::strip_upcase {st} {

  return [string toupper [string map {{ } _} [string trim $st { _}]]]
}

# previous proc's value, with \n (to find an exact "-b" block name)
proc doctest::strip_upcase_nn {st} {

  return "\n[strip_upcase $st]\n"
}

###################################################################
# Make string of args (1 2 3 ... be string of "1 2 3 ...")

proc doctest::string_of_args {args} {

  set msg ""; foreach m $args {set msg "$msg $m"}
  return [string trim $msg " \{\}"]
}

###################################################################
# Show synopsis and exit

proc doctest::exit_on_error { {ams ""}} {

  variable SYNOPSIS
  variable UNDER
  MES SYNOPSIS $SYNOPSIS $UNDER $ams
  exit
}

###################################################################
# Get line's contents

proc doctest::get_line_contents {ind} {

  variable options
  return [lindex $options(cnt) [incr ind -1]]
}

###################################################################
# Get test blocks (TEST_BEGIN ... TEST_END)

proc doctest::get_test_block {begin end} {

  set block ""
  for {set i $begin} {$i<=$end} {incr i} {
    append block [get_line_contents $i] "\n"
  }
  return $block
}

proc doctest::get_test_blocks {} {

  variable BL_BEGIN
  variable BL_END
  variable options
  set test_blocks [list]
  set block_begins 0
  set ind 0
  set doit 0
  foreach st $options(cnt) {
    incr ind
    set st [strip_upcase $st]
    if {[string first $BL_BEGIN $st]==0} {
      set blk [string trimright " [string range $st [string len $BL_BEGIN]+1 end]"]
      if {$block_begins} {
        return [list 1 [list]]     ;# unpaired begins
      }
      set tname [strip_upcase_nn [string range $st [string len $BL_BEGIN] end]]
      set doit [expr {$options(-b)=="" || [string first $tname $options(-b)]>=0}]
      if {$doit} {
        lappend test_blocks [expr {$ind + 1}] ;# begin of block
        set block_begins 1
      }
    } elseif {$st == $BL_END && $doit} {
      if {!$block_begins} {
        return [list 2 [list]]     ;# unpaired ends
      }
      lappend test_blocks [expr {$ind - 1}] $blk ;# end of block
      set block_begins 0
    }
  }
  if {![llength $test_blocks]} {
    if {$options(-b)==""} {
      set test_blocks [list 1 [llength $options(cnt)]]  ;# testing all of file
    }
  } elseif {$block_begins} {
    lappend test_blocks [llength $options(cnt)]  ;# testing to the end of file
  }
  return [list 0 $test_blocks]
}

###################################################################
# Get line of command or command's waited result

proc doctest::get_line {type i prevcontinuedName} {

  upvar $prevcontinuedName prevcontinued
  variable NOTHING
  variable TEST_RESULT
  set st [get_line_contents $i]
  set strimmed [string trimleft $st]
  set tpos [string first $type $strimmed]
  if {!$prevcontinued || $tpos == 0} {
    set st $strimmed
  } else {
    set st "$type $st"    ;# continuing from previous line
  }
  set prevcontinued [expr {[string index $st end] eq "\\"}]
  if {$prevcontinued && $type eq $TEST_RESULT} {
    set st [string range $st 0 end-1]
  }
  if {[set i [string first $type $st]] == 0} {
    return [string range $st [expr {[string length $type]+1}] end]
  }
  return $NOTHING
}

###################################################################
# Get command/result lines
# Input:
#   - type - type of line (COMMAND or RESULT)
#   - i1   - starting line to process
#   - i2   - ending line to process
# Returns:
#   - command/result lines
#   - next line to process

proc doctest::get_com_res {type i1 i2} {

  variable TEST
  variable NOTHING
  variable TEST_COMMAND
  set comres $NOTHING
  set prevcontinued 0
  for {set i $i1; set res ""} {$i <= $i2} {incr i} {
    set line [string trim [get_line $type $i prevcontinued] " "]
    if {[string index $line 0] eq "\"" && [string index $line end] eq "\""} {
      set line [string range $line 1 end-1]
    }
    if {[string first $TEST $line]==0} {
      continue             ;# this may occur when block is selection
    }
    if {$line == $NOTHING} {
      break
    } else {
      if {$comres==$NOTHING} {
        set comres ""
      }
      if {$type eq $TEST_COMMAND && [string index $comres end] eq "\\"} {
        set comres "[string trimright [string range $comres 0 end-1]] "
      } elseif {$comres != ""} {
        set comres "$comres\n"
      }
      set comres "$comres$line"
    }
  }
  return [list $comres $i]
}

###################################################################
# Get commands' results

proc doctest::get_commands {i1 i2} {

  variable TEST_COMMAND
  return [get_com_res $TEST_COMMAND $i1 $i2]
}

###################################################################
# Get waited results

proc doctest::get_results {i1 i2} {

  variable TEST_RESULT
  return [get_com_res $TEST_RESULT $i1 $i2]
}

###################################################################
# Execute commands and compare their results to waited ones

proc doctest::execute_and_check {block safe commands results} {

  set err ""
  set ok 0
  if {[catch {
      if {$safe} {
        set tmpi [interp create -safe]
      } else {
        set tmpi [interp create]
      }
      set res [interp eval $tmpi $block\n$commands]
      interp delete $tmpi
      if {$res eq $results} {
        set ok 1
      }
    } e]
  } {
    if {$e eq $results} {
      set ok 1
    }
    set res $e
  }
  return [list $ok $res]
}

###################################################################
# Test block of commands and their results

proc doctest::do_block {begin end blk safe verbose} {

  variable UNDER
  variable options
  variable NOTHING
  variable ntestedany
  set block_ok -1
  set block [get_test_block $begin $end]
  set i1 $begin
  set i2 $end
  for {set i $i1} {$i <= $i2} {} {
    lassign [get_commands $i $i2] commands i ;# get commands
    if {$commands != "" && $commands != $NOTHING} {
      lassign [get_results $i $i2] results i ;# get waited results
      lassign [execute_and_check $block $safe $commands $results] ok res
      if {$results==$NOTHING} {
        # no result waited, for GUI tests
        set ok true
        set res ""
      } else {
        incr ntestedany
      }
      set coms "% $commands\n\n"
      if {$ok} {
        if {$verbose==1} {
          MES "DOCTEST$blk" "${coms}> $res\n\nOK$UNDER"
        }
        if {$block_ok==-1} {set block_ok 1}
      } else {
        if {$verbose==1} {
          MES "ERROR OF DOCTEST$blk" "${coms}GOT:\n\"$res\"
            \nWAITED:\n\"$results\"
            \nFAILED$UNDER"
        }
        set block_ok 0
      }
    } else {
      incr i
    }
  }
  return $block_ok
}

proc doctest::do_test {blocks safe verbose} {

  variable HINT1
  variable UNDER
  variable ntestedany
  set all_ok -1
  set ptested [set ntested [set ntestedany 0]]
  foreach {begin end blk} $blocks {
    set block_ok [do_block $begin $end $blk $safe $verbose]
    if {$block_ok!=-1} {
      if {$block_ok} {
        incr ptested
      } else {
        incr ntested
      }
      if {$block_ok==1 && $all_ok==-1} {
        set all_ok 1
      } elseif {$block_ok==0} {
        set all_ok 0
      }
    }
  }
  if {($ptested + $ntested)==0} {
    ERR "Nothing to test.$HINT1"
  } elseif {(!$verbose || ($verbose==-1 && !$all_ok)) && $ntestedany} {
    if {$all_ok} {
      MES "DOCTEST" "  Tested ${ptested} block(s)\n\nOK$UNDER"
    } else {
      MES "ERROR OF DOCTEST" "  Failed ${ntested} block(s)\n\nFAILED$UNDER"
    }
  }
}

  ###################################################################
  # check if "doctest source" and return sourced name or ""

  proc doctest::sourced_line {line} {

    variable TEST_COMMAND
    return [regexp -nocase -inline \
        "^\\s*$TEST_COMMAND\\s+DOCTEST\\s+SOURCE\\s+" $line]

  }

  ###################################################################
  # check if the line is "doctest quote"

  proc doctest::is_quoted_line {line} {

    variable BL_BEGIN
    variable BL_END
    if {[sourced_line $line] eq ""} {
      set st [strip_upcase $line]
      if {[string first $BL_BEGIN $st]==0} { return 1 }
      if {[string first $BL_END $st]==0}   { return 2 }
    }
    return 0

  }

###################################################################
# Get text of file and options

proc doctest::init {args} {

  variable options
  variable TEST_COMMAND
  variable TEST_BEGIN
  variable TEST_END
  variable BL_BEGIN [strip_upcase $TEST_BEGIN]
  variable BL_END   [strip_upcase $TEST_END]
  array set options {fn "" cnt {} -s 1 -v 1 -b {}}
  if {[llength $args] == 0} exit_on_error
  set off 0
  foreach {opt val} $args {
    if {$off} {
      append options(fn) " $opt $val"
      continue
    }
    switch -glob $opt {
      -s - -v { set options($opt) $val }
      -b      { set options($opt) "$options($opt) [strip_upcase_nn $val] " }
      --      { set off 1 }
      default {
        append options(fn) " $opt $val"
      }
    }
  }
  if {[lsearch {1 0} $options(-s)]==-1 || \
      [lsearch {1 0 -1} $options(-v)]==-1} {
    exit_on_error
  }
  set options(fn) [string trim $options(fn)]
  if {[catch {set ch [open $options(fn)]}]} {
    exit_on_error "\"$options(fn)\" not open"
  }
  chan configure $ch -encoding utf-8
  set cnt [split [read $ch] \n]
  close $ch
  # source all tests (by #% source ...)
  set isany [set isopen 0]
  foreach line $cnt {
    if {[is_quoted_line $line]==1} { set isany 1;  break }
  }
  set options(cnt) {}
  foreach line $cnt {
    set sll [string length [sourced_line $line]]
    if {$isany && !$sll} {
      if {[is_quoted_line $line]==1} { set isopen 1 }
      if {[is_quoted_line $line]==2} { set isopen 0 }
    }
    if {$sll} {
      if {!$isany || $isopen} {  ;# ignore 'source' outside of any blocks
        set fn [string trim [string range $line $sll-2 end]]
        if {[catch {set ch [open $fn]}]} {
          exit_on_error "PWD: [pwd]\n\"$fn\" not open by\n $line"
        }
        chan configure $ch -encoding utf-8
        foreach l [split [read $ch] \n] { lappend options(cnt) $l }
        close $ch
      }
    } else {
      lappend options(cnt) $line
    }
  }
}

###################################################################
# Perform doctest

proc doctest::do {} {

  variable TEST_BEGIN
  variable TEST_END
  variable HINT1
  variable options
  lassign [get_test_blocks] error blocks
  switch $error {
    0 { do_test $blocks $options(-s) $options(-v)}
    1 { ERR "Unpaired: $TEST_BEGIN$HINT1" }
    2 { ERR "Unpaired: $TEST_END$HINT1" }
  }
}

#####################################################################
# main program huh

doctest::init {*}$::argv
doctest::do

