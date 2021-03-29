#! /usr/bin/env tclsh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# It's a template to create the code samples summaries snatched from
# Tcl guides. See ch14_tcloo.tcl for example.
#
# This is runnable in Geany IDE if its 'Run command' set as:
#   "./%f"
# or, more pedantically,
#   tclsh "./%f"
#
# The terminal outputs contain:
#   - an underline             (     ~~~~~~~~~~~~~~~~~~~~~~~~ )
#   - a comment to commands    (     COMMENT                  )
#   - a command to execute     (   % command                  )
#   - a command's message      (   message                    )
#   - a command's result       (     ==> result               )
#   - a catched error message  (     ==> ERROR: error message )
#
# The samples are inserted into the bundle variable (see below).
#
# You can insert your own commands into the bundle variable as well as
# the d command that makes a debugging pause in the flow of commands.
#
# You should place "% " before commands to visualize them in terminal.
# Don't place "% " before a command if you don't want it being shown.
#
# Example of using % and d:
#
#     set bundle {
#     //...
#     //... Begin of commands bundle
#     //...
#     % oo::class create MyOwnClass {
#         //...
#         # all code from % to the end of command
#         # (i.e. enclosing brace) is visible in terminal
#         //...
#     }
#     d   ;# this suspends the execution till pressing Enter key
#     //...
#     % myObject do something
#     //...
#     d 2 ;# 2nd stop-over shown as 2:
#     //...
#     //... End of commands bundle
#     //...
#     }
#
# So, your samples should be inserted into the bundle variable
# (just below) between "// START" and "// FINISH" lines.
#
# See e.g. "TclOO Tricks" article available here:
#   http://wiki.tcl.tk/21595
#
# Scripted by Alex Plotnikov (aplsimple@mail.ru).
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

####################################################################
# namespace import, package require etc. to run the related code

#namespace import ::tcl::mathop::*
#namespace forget ::tcl::mathop::%  ;# used here

####################################################################
# Begin of commands bundle

set bundle {

//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// START
//

// Insert here your samples...
//
#  You can use // or # at 1st column to comment the samples.
#
##  You can use ## at 1st column to comment without uppercasing.
#
#  Note that comments may contain special characters "{}[]$\"
#  though "{" and "}" must be balanced.

//
// FINISH
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
}
# End of commands bundle
####################################################################

if {$::argc} {
  # read from a file (its name - 1st argument of this)
  # and put its contents into 'bundle' variable to process
  if {[catch {
    set ch [open [set fname [lindex $::argv 0]]]
    chan configure $ch -encoding utf-8
    set bundle [read $ch]   ;# take samples from a file
    close $ch
    set show_bundle true
    cd [file dirname $fname]
  } e]} {
    puts "\nError:\n$e\n"
  }
}
source [file join [file dirname $::argv0] "procs.tcl"]
exit

