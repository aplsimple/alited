#! /usr/bin/env tclsh
###########################################################
# Name:    preview.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/06/2023
# Brief:   Previews some widgets of chosen theme & CS.
# License: MIT.
###########################################################

package require Tk
wm withdraw .
if {$::argc != 1} {
  puts "\nUsed by alited as follows:\n  [info nameofexecutable] [info script] argfile\n"
  exit
}

# _________________________ NS preview ________________________ #

namespace eval preview {
  variable argfile [lindex $::argv 0]
  variable theme alt CS -2 tint 0 algeom +1+1 title Test
  variable SCRIPT [file normalize [info script]]
  variable DIR [file dirname [file dirname $SCRIPT]]
  variable LIBDIR [file join $DIR lib]
  variable PAVEDIR [file join $LIBDIR e_menu src]
  source [file join $preview::PAVEDIR apaveinput.tcl]
}

# ________________________ Procedures _________________________ #

proc preview::InitArgs {} {
  # Reads arguments to preview.

  variable argfile
  variable theme
  variable CS
  variable tint
  variable algeom
  variable title
  if {![file exists $argfile]} exit
  set ch [open $argfile]
  set line [gets $ch]
  close $ch
  lassign $line algeom theme CS tint title
}
#_______________________

proc preview::Rerun {obj win} {
  # Reads arguments and at need reruns the preview.
  #   obj - apave object
  #   win - window's path

  variable theme
  variable CS
  variable tint
  set theme_saved $theme
  set CS_saved $CS
  set tint_saved $tint
  InitArgs
  if {$theme_saved ne $theme || $CS_saved!=$CS || $tint_saved!=$tint} {
    exit
  }
  after idle [list after 100 "preview::Rerun $obj $win"]
}
#_______________________

proc preview::Run {} {
  # Creates a window to preview widgets.

  variable LIBDIR
  variable theme
  variable CS
  variable tint
  variable algeom
  variable SCRIPT
  variable title
  ::apave::InitTheme $theme $LIBDIR
  ::apave::initWM -theme $theme -cs $CS
  ::apave::obj csToned $CS $tint yes
  set obj previewobj
  set win .win
  catch {::apave::APaveInput create $obj $win}
  set ::en1 {Entry value}
  set ::en2 {Combo 1}
  set ::v1 [set ::c1 1]
  set ttl [$obj csGetName $preview::CS]
  set ttl [string range $ttl [string first { } $ttl]+1 end]
  $obj makeWindow $win.fra "$title: $preview::theme, $ttl, $tint"
  $obj paveWindow $win.fra {
    {lab1 - - 1 1    {-st wsn}  {-t "Entry: "}}
    {Ent1 lab1 L 1 4 {-st wes} {-tvar ::en1}}
    {labm lab1 T 1 1 {-st wsn} {-t "Radiobutton: "}}
    {radA labm L 1 1 {-st ws} {-t "Choice 1" -var ::v1 -value 1}}
    {radB radA L 1 1 {-st ws} {-t "Choice 2" -var ::v1 -value 2}}
    {lab2 labm T 1 1 {-st wsn} {-t "Switch: "}}
    {swi1 lab2 L 1 1 {-st ws} {-t "Switch 1" -var ::c1}}
    {lab3 lab2 T 1 1 {-st wsn} {-t "Combobox: "}}
    {cbx1 + L 1 1 {-st ws} {-w 12 -tvar ::en2 -state readonly -values {"Combo 1" "Combo 2" "Combo 3"}}}
    {lab4 lab3 T 1 1 {-st en} {-t "Labelframe:\nText:\nTooltip:\nScrollbar:\nTool button:\nPopup menu:"}}
    {ftx1 lab4 L 1 4 {-st wesn -cw 1 -rw 1} {-h 5 -w 50 -ro 0 -tvar ::preview::SCRIPT -title {Pick a file to view} -filetypes {{{Tcl scripts} .tcl} {{Text files} {.txt .test}}} -wrap none -tabnext .win.fra.but5 -tip "After choosing a file\nthe text will be read-only."}}
    {seh3 lab4 T 1 5 {-st ewn}}
    {h_ seh3 T 1 4 {-st ew}}
    {but5 h_ L 1 1 {-st e} {-t "Close" -com exit}}
  }
  after 100 "preview::Rerun $obj $win"
  $obj showModal $win -focus [$obj Ent1] -geometry $algeom
  destroy $win
  $obj destroy
}

# ________________________ Run me _________________________ #

  preview::InitArgs
  preview::Run

# ________________________ EOF _________________________ #
