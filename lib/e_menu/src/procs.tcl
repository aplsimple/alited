####################################################################

# Procs for creating the code samples summaries snatched
# from Tcl guides. See ch_.tcl, ch14_tcloo.tcl as examples of use.

####################################################################
# namespace import, package require etc. to run the related code

namespace import ::tcl::mathop::*
namespace forget ::tcl::mathop::%  ;# used here

####################################################################

# few common procs

proc print_text {up args} {
  # outputting messages passed in args
  if {[llength args] > 0} {
    puts -nonewline "   "
    foreach a $args {
      if {$up} {
        puts -nonewline [string toupper " $a"]
      } else {
        puts -nonewline " $a"
      }
    }
  }
  puts ""
}

proc print_list {args} {
  # outputting messages passed in args as list
  global HALLO
  if {[llength args] > 0} {
    foreach a $args {
      foreach b $a { print_text 0 "$HALLO$b" }
    }
  }
}
proc // {args} {
  # printing COMMENTS
  print_text 0 [string trim $args \{\}]
}

proc % {incom} {
  # innocent mimicry of command line (don't mix it with ::tcl::mathop::%)
  # - execute 'incom' and show its results or catched error
  global HALLO
  global com
  set com $incom
  if {[string length $com] > 0} {
    if { [catch {set rez [uplevel #0 $com]} err] } {
      set err [string map {\" \'} $err]
      print_text 0 "${HALLO}ERROR: $err"
    } else {
      if {[llength $rez] > 0} {
        print_text 0 "${HALLO}$rez"
      }
    }
  }
}

proc Exe {com} {
  # showing and executing command 'com'
  global SPACE
  global COMMD
  set com [string trimright [reformat $com] "\n"]
  set FRICK "<ABRAcadABRA>"
  set repl {"\n"}
  set repl [lappend repl $FRICK]
  set com [string map $repl $com]
  set repl $FRICK
  set repl [lappend repl "\n$SPACE"]
  set com [string map $repl $com]
  print_text 0 "\n$COMMD$com"
  % $com
}

proc d { {arg ""} } {
  # 'stop machine' - for debugging only
  puts -nonewline "\n$arg: "
  gets stdin
}

####################################################################
# borrowed from http://wiki.tcl.tk/15731

proc count {string char} {
  set count 0
  while {[set idx [string first $char $string]]>=0} {
    set backslashes 0
    set nidx $idx
    while {[string equal [string index $string [incr nidx -1]] \\]} {
      incr backslashes
    }
    if {$backslashes % 2 == 0} {
      incr count
    }
    set string [string range $string [incr idx] end]
  }
  return $count
}

#====== Reformat the code

proc reformat {tclcode {pad 2}} {

  set lines [split $tclcode \n]
  set out ""
  set nquot 0   ;# count of quotes
  set ncont 0   ;# count of continued strings
  set line [lindex $lines 0]
  set indent [expr {([string length $line]-[string length [string trimleft $line \ \t]])/$pad}]
  set padst [string repeat " " $pad]
  foreach orig $lines {
    incr lineindex
    if {$lineindex>1} {append out \n}
    set newline [string trim $orig]
    if {$newline==""} continue
    set is_quoted $nquot
    set is_continued $ncont
    if {[string index $orig end] eq "\\"} {
      incr ncont
    } else {
      set ncont 0
    }
    if { [string index $newline 0]=="#" } {
      set line $orig   ;# don't touch comments
    } else {
      set npad [expr {$indent * $pad}]
      set line [string repeat $padst $indent]$newline
      set ns 0         ;# count of slashes
      set nl 0         ;# count of left brace
      set nr 0         ;# count of right brace
      set body 0
      for {set i 0; set n [string length $newline]} {$i<$n} {incr i} {
        set ch [string index $newline $i]
        if {$ch=="\\"} {
          set ns [expr {[incr ns] % 2}]
        } elseif {!$ns} {
          if {$ch=="\""} {
            set nquot [expr {[incr nquot] % 2}]
          } elseif {!$nquot} {
            switch $ch {
              "\{" {
                incr nl
                set body -1
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
      set nbbraces [expr {$nl - $nr}]
      incr totalbraces $nbbraces
      if {$totalbraces<0} {
        api::show_error "\nLine $lineindex: unbalanced braces!\n"
        return ""
      }
      incr indent $nbbraces
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
    }
    append out $line
  }
  return $out
}

####################################################################
# main program, huh

set com ""
set SPACE "    "
set COMMD "  % "
set HALLO "==> "
set COM_STRING "\n% "
set PUT_STRING "\n//"
set COM_LENGTH [string length $COM_STRING]
set PUT_LENGTH [string length $PUT_STRING]
#? set bun ""
#? foreach st [split $bundle \n] {
#?   if {![string first "#" $st] || ![string first "//" $st]} {
#?     set st "// \{[string trimleft $st {#/ }]\} \
#?           [expr {[string index $st 1]!="#"}]"
#?   }
#?   append bun \n $st
#? }
#? set bundle $bun
if {[info exists show_bundle]} {
  puts [reformat $bundle]
}
set BUN_LENGTH [string length $bundle]
for {set i 0} {$i < $BUN_LENGTH} {} {
  set ifound [string first $COM_STRING $bundle $i]
  if {$ifound<0} {
    % [string range $bundle $i end]
    break
  } else {
    % [string range $bundle $i $ifound]
    incr ifound $COM_LENGTH
    set ifound2 [string first $COM_STRING $bundle $ifound]
    set ifound3 [string first $PUT_STRING $bundle $ifound]
    if {$ifound2 < 0} { set ifound2 $BUN_LENGTH }
    if {$ifound3 < $ifound2 && $ifound3 >= 0} {
      Exe [string range $bundle $ifound [expr $ifound3 - 1]]
      set i $ifound3
    } elseif {$ifound2 >= 0} {
      Exe [string range $bundle $ifound [expr $ifound2 - 1]]
      set i $ifound2
    } else {
      Exe [string range $bundle $ifound end]
      break
    }
  }
}

