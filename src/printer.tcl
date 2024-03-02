#! /usr/bin/env tclsh
###########################################################
# Name:    printer.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 01, 2024
# Brief:   Handles html copy of a project to be printed.
# License: MIT.
###########################################################

# _________________________ printer ________________________ #

namespace eval printer {
  variable win $::alited::al(WIN).printer
  variable geometry root=$::alited::al(WIN)
}
#_______________________

proc printer::_create  {} {
  # Creates Project Printer dialogue.

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable geometry
  $obDl2 makeWindow $win.fra [msgcat::mc {Project Printer}]
  $obDl2 paveWindow $win.fra {
    {lab - - - - {} {-t {Project Printer: TODO}}}
  }
  set res [$obDl2 showModal $win -resizable 1 -minsize {200 100} -geometry $geometry]
  catch {destroy $win}
}
#_______________________

proc printer::_run  {} {
  # Runs Project Printer dialogue.

  _create
}
