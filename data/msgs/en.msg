#! /usr/bin/env tclsh
###########################################################
# Name:    en.msg
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/06/2021
# Brief:   Handles specific messages.
# License: MIT.
###########################################################

# ________________________ alited NS - Specific cases (en) _________________________ #
namespace eval ::alited {

  ::msgcat::mcmset en {
    "Consistency of braces" "Consistency of {}"
  }

}

# _________________________________ EOF _________________________________ #
#RUNF1: tclsh ../../src/alited.tcl DEBUG
