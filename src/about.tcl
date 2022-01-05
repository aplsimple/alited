#! /usr/bin/env tclsh
###########################################################
# Name:    about.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles 'About' form of alited.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval about {
  variable textTags  ;# text tags to highlight strings
}

# ________________________ Procedures _________________________ #

proc about::About {} {
  # Shows "About" dialogue.

  namespace upvar ::alited al al
  variable textTags
  lassign [::apave::obj csGet] fg - bg - - bS fS
  set textTags [list \
    [list "red" " -font {[::apave::obj csFontDef] -weight bold} -foreground $fS -background $bS"] \
    [list "link1" "::apave::openDoc %t@@https://%l@@"] \
    [list "link2" "::apave::openDoc %t@@https://wiki.tcl-lang.org@@"] \
    [list "linkapl" "::apave::openDoc %t@@https://github.com/aplsimple/@@"] \
    [list "linkCN" "::apave::openDoc %t@@https://www.nemethi.de/@@"] \
    [list "linkSH" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Steve+Huntley@@"] \
    [list "linkHE" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/HE@@"] \
    [list "linkRD" "::apave::openDoc %t@@https://github.com/rdbende@@"] \
    [list "linkMIT" "::apave::openDoc %t@@https://en.wikipedia.org/wiki/MIT_License@@"] \
    ]
  set long1 [msgcat::mc {And well fit for programming with it.}]
  set long2 __________________________________________
  set long3 [info nameofexecutable]
  set msg "  <red>alited v[package require alited]</red> [msgcat::mc {stands for}] \"a lite editor\".\n\n \
    [msgcat::mc {Written in pure Tcl/Tk.}] \n \
    $long1\n\n \
    [msgcat::mc {Details:}] \n\n \
      \u2022 <link1>aplsimple.github.io/en/tcl/alited</link1>\n \
      \u2022 <link1>github.com/aplsimple/alited</link1>\n \
      \u2022 <link1>chiselapp.com/user/aplsimple/repository/alited</link1>\n\n \
    [msgcat::mc {Authors:}] \n\n \
      \u2022 <linkapl>Alex Plotnikov</linkapl>\n\n \
    [msgcat::mc {License:}] <linkMIT>MIT</linkMIT>\n \
    $long2\n \
    \n \
    <red> $long3 </red>\n \
    \n \
    <red> $alited::tcltk_version </red> <link2></link2>\n \
    \n \
    <red> $::tcl_platform(os) $::tcl_platform(osVersion) </red>"
  set wmax [expr {4+max([string length $long1], \
    [string length $long2],[string length $long3])}]
  set ackn [msgcat::mc "Many thanks to the following people\n who have contributed to this project:"]
  set ::alited::AcknText "\n $ackn\n\n \
      \u2022 <linkCN>Csaba Nemethi</linkCN>\n \
      \u2022 <linkSH>Steve Huntley</linkSH>\n \
      \u2022 <linkHE>Holger Ewert</linkHE>\n \
      \u2022 <linkRD>rdbende</linkRD>\n \
      "
  set tab2 [list Information Acknowledgements "{fra - - 1 99 {-st nsew -rw 1 -cw 1}} {.TexAckn - - - - {pack -side left -expand 1 -fill both} {-w $wmax -h 31 -rotext ::alited::AcknText -tags ::alited::about::textTags}} {.sbv .texAckn L - - {pack -side right}}"]
  ::alited::msg ok {} $msg \
    -title [msgcat::mc About] -t 1 -w $wmax -h {30 30} -scroll 0 \
    -tags alited::about::textTags -my "after idle {alited::about::textImaged %w}" \
    -tab2 $tab2
}
#_______________________

proc about::textImaged {w} {
  # Makes the feather blink.
  #  w - window's path

  ::apave::obj labelFlashing [::apave::obj textLink $w 5] "" 1 \
    -data $::alited::img::_AL_IMG(feather) -pause 0.5 -incr 0.1 -after 40
}

# _____________________________ EOF _____________________________________ #
#RUNF1: alited.tcl DEBUG
