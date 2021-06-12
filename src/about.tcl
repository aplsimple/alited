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
    ::alited::msg ok {} "  <red>alited v[package require alited]</red> [msgcat::mc {stands for}] \"a lite editor\".\n\n \
  [msgcat::mc {Written in pure Tcl/Tk.}] \n \
  [msgcat::mc {And well fit for programming with it.}]\n\n \
  [msgcat::mc {Details:}] \n\n \
    \u2022 <link1>aplsimple.github.io/en/tcl/alited</link1>\n\n \
  [msgcat::mc {Authors:}] \n\n \
    \u2022 <linkapl>Alex Plotnikov</linkapl>\n\n \
  [msgcat::mc {License:}] <linkMIT>MIT</linkMIT>\n \
  __________________________________________\n \
\n \
  <red> $alited::tcltk_version </red> <link3></link3>\n \
\n \
  <red> $::tcl_platform(os) $::tcl_platform(osVersion) </red>\n" \
-title [msgcat::mc About] -t 1 -w 46 -scroll 0 \
-tags alited::about::textTags -my "after idle {alited::about::textImaged %w}"
  }

  proc textImaged {w} {
    # Makes the feather blink.
    #  w - window's path
    ::apave::obj labelFlashing [::apave::obj textLink $w 3] "" 1 \
      -data $::alited::img::_AL_IMG(feather) -pause 0.5 -incr 0.1 -after 40
  }

}
# _____________________________ EOF _____________________________________ #
#RUNF1: alited.tcl DEBUG
