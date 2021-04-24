#! /usr/bin/env tclsh

############################################################################
#
# Runs pave dialogs from CLI.
# Scripted by Alex Plotnikov.
#
# After choosing 'OK' in a dialog, the dialog's result is written to stdout.
# The output would be sort of:
#   #!/bin/bash
#   export var1='value 1'
#   export var2='value 2'
#   ...
#   export varN='value 3'
# The output may be redirected to temp file. After analizing the result of
# dialog (1 if 'OK', otherwise 0), the output temp file may be sourced to
# execute the "export ..." commands. So that the dialog's variable values
# would be assigned to the environment variables with appropriate names,
# within the current shell.
#
# Example:
#
# tclsh ~/UTILS/pave/pavecli.tcl "" "TEST OF pavecli" \
    {    ent1  {"   Find: "} {"$::EN1 2 3"}    ent2  {"Replace: "} \
    {"$::EN2 $::EN4"}  labo {{} {-anchor w} {-t "\\nOptions:" -font \
    {-weight bold}}}  {}    radA  {{Match:   }} {{RE  } Exact "Glob" \
    {RE  }}    seh   {{} {} {}} {}    chb1  {{Match whole word only}} \
    {1}    chb2  {{Match case           }} {1}    seh2  {{} {} {}} {}  \
    v_    {{} {} {}} {}    cbx1  {{Where:   }} {{"in file"} {in file}  \
    {in session} {in directory}}    } -head "Enter data:" -weight bold \
    == EN1 EN2 V1 C1 C2 W1 > tmp.sh ; \
 if [ $? -eq 1 ]; then source tmp.sh; fi ; \
 rm tmp.sh ; \
 echo "EN1=$EN1, EN2=$EN2, V1=$V1, C1=$C1, C2=$C2, W1=$W1"
#
# The end of command looks like this:
#   == EN1 EN2 V1 C1 C2 W1  > tmp.sh
# which sets the EN1, EN2, V1, C1, C2 and W1 output variables and redirects
# their assignment to tmp.sh file. After checking the command's result, the
# tmp.sh file is executed in the current shell, by 'source' command.
#
# So the EN1, EN2, V1, C1, C2 and W1 environment variables would correspond
# to the  dialog's variables.
#
# See also:
#    https://aplsimple.github.io/en/tcl/pave
#
############################################################################

if {[catch {package require apave}]} {
  set ::apavedir [file dirname [info script]]
  lappend auto_path $::apavedir
  if {[catch {package require apave}]} {
    lset auto_path end $::apavedir/pave
    package require apave
  }
}

namespace eval apavecli {
}

#=== Input dialog for getting data
proc ::apavecli::input {args} {

  ::apave::APaveInput create dialog
  set cmd [subst -nocommands -novariables [string range $args 1 end-1]]
  set dp [string last " ==" $cmd]
  if {$dp<0} {set dp 999999}
  set data [string range $cmd $dp+3 end]
  set data [split [string trim $data]]
  set cmd "dialog input [string range $cmd 0 $dp-1]"
  set res [eval $cmd]
  set r [lindex $res 0]
  if {$r && $data ne ""} {
    set rind 0
    puts "#!/bin/bash"
    foreach res [lrange $res 1 end] {
      puts "export [lindex $data $rind]='$res'"
      incr rind
    }
  }
  return $r
}

#=== Run dialog
proc ::apavecli::run {} {

  apave::initWM
  set res [::apavecli::input $::argv]
  ::apave::APaveInput destroy
  exit $res
}

::apavecli::run

#%   DOCTEST   SOURCE   tests/apavecli.test
