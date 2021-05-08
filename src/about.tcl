#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The 'About' form of alited.
# _______________________________________________________________________ #

namespace eval about {

  variable textTags

  proc About {} {
    # Shows "About" dialogue.

  namespace upvar ::alited al al
  variable textTags
  lassign [::apave::obj csGet] fg - bg - - bS fS
  set textTags [list \
      [list "red" " -font {[::apave::obj csFontDef] -weight bold} -foreground $fS -background $bS"] \
      [list "link1" "::apave::openDoc %t@@https://%l@@"] \
      [list "link2" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/%l/%l.html@@"] \
      [list "link3" "::apave::openDoc %t@@https://wiki.tcl-lang.org@@"] \
      [list "linkapl" "::apave::openDoc %t@@https://github.com/aplsimple/@@"] \
      [list "linkMIT" "::apave::openDoc %t@@https://en.wikipedia.org/wiki/MIT_License@@"] \
      ]
    ::alited::msg ok info "  <red>alited v[package require alited]</red> stands for \"a lite editor\".

  Well fit for Tcl/Tk programming.

  Details: \

    \u2022 <link1>aplsimple.github.io/en/tcl/alited</link1>

  Authors: \

    \u2022 <linkapl>Alex Plotnikov</linkapl>

  License: <linkMIT>MIT</linkMIT>
  __________________________________________

  <red> $alited::tcltk_version </red> <link3></link3>

  <red> $::tcl_platform(os) $::tcl_platform(osVersion) </red>
" -title $al(MC,about) -t 1 -w 46 -scroll 0 \
-tags alited::about::textTags -my "after idle {alited::about::textImaged %w}"
  }

  proc textImaged {w} {
    ::apave::obj labelFlashing [::apave::obj textLink $w 3] "" 1 \
      -data $::alited::img::_AL_IMG(feather) -pause 0.5 -incr 0.1 -after 40
  }

}
# _____________________________ EOF _____________________________________ #
#RUNF1: alited.tcl DEBUG
