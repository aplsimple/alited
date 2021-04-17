#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The favorites' lists.
# _______________________________________________________________________ #

namespace eval ::alited::info {
  variable list [list]
}

proc ::alited::info::Get {} {
  variable list
}

proc ::alited::info::Put {msg} {
  variable list
  lappend list $msg
}

proc ::alited::info::Clear {} {
  variable list
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
