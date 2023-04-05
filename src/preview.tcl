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
  source [file join $preview::PAVEDIR apave.tcl]
}

# ________________________ Procedures _________________________ #

proc ::tracer {args} {
  set ::sc2 [expr {round($::sc)}]
}
#_______________________

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
  catch {::apave::APave create $obj $win}
  set ::en1 {Entry value}
  set ::en2 {Combo 1}
  set ::v1 [set ::v2 [set ::c1 [set ::c2 1]]]
  set ::sc [set ::sc2 50]
  trace add variable ::sc write ::tracer
  set ::opc default
  set ::opcSet [list default clam classic alt -- {{light / dark} awlight awdark -- forest-light forest-dark -- lightbrown darkbrown -- plastik}]
  set ttl [$obj csGetName $preview::CS]
  set ttl [string range $ttl [string first { } $ttl]+1 end]
  $obj makeWindow $win.fra "$title: $preview::theme, $ttl, $tint"
  $obj paveWindow $win.fra {
    {nbk - - - - {pack -expand 1 -fill both} {
      f1 {-text " Notebook " -underline 2}
      f2 {-text " Tab #2 " -underline 2}
    }}
    {seh3 - - - - {pack -fill x}}
    {h_ - - - - {pack}}
    {but5 - - - - {pack -side right} {-t "Close" -com exit}}
  }
  $obj paveWindow $win.fra.nbk.f1 {
    {lab1 - - 1 1    {-st wsn}  {-t "Entry: "}}
    {Ent1 + L 1 4 {-st wes} {-tvar ::en1}}
    {labm lab1 T 1 1 {-st wsn} {-t "Radiobutton: "}}
    {radA + L 1 1 {-st ws} {-t "Choice 1" -var ::v1 -value 1}}
    {radB + L 1 1 {-st ws} {-t "Choice 2" -var ::v1 -value 2}}
    {lab2 labm T 1 1 {-st wsn} {-t "Swi/Chb: "}}
    {swi1 + L 1 1 {-st ws} {-t "Switch" -var ::c1}}
    {chb1 + L 1 1 {-st ws} {-t "Checkbox" -var ::c2}}
    {lab3 lab2 T 1 1 {-st wsn} {-t "Combobox: "}}
    {cbx1 + L 1 1 {-st ws} {-w 12 -tvar ::en2 -state readonly -values {"Combo 1" "Combo 2" "Combo 3"}}}
    {lab4 lab3 T 1 1 {-st en} {-t "Labelframe:\nText:\nTooltip:\nScrollbar:\nTool button:\nPopup menu:"}}
    {ftx1 + L 1 4 {-st wesn -cw 1 -rw 1} {-h 5 -w 50 -ro 0 -tvar ::preview::SCRIPT -title {Pick a file to view} -filetypes {{{Tcl scripts} .tcl} {{Text files} {.txt .test}}} -wrap none -tabnext .win.fra.but5 -tip "After choosing a file\nthe text will be read-only."}}
  }
  $obj paveWindow $win.fra.nbk.f2 {
    {lab0 - - 1 1 {-st wsn}  {-t "Spinbox: "}}
    {spx + L 1 1 {-st wes} {-tvar ::v2 -from 1 -to 99 -w 5 -justify center}}
    {h_ + L 1 1 {-st ew -cw 1}}
    {v_ lab0 T 1 1 {-pady 10}}
    {lab1 + T 1 1 {-st wsn}  {-t "Progress: "}}
    {pro + L 1 2 {-st ew} {-mode indeterminate -afteridle {%w start}}}
    {h_2 lab1}
    {lab2 + L 1 2 {-st ew} {-tvar ::sc2 -anchor center}}
    {lab3 h_2 T 1 1 {-st wsn} {-t "Scale: "}}
    {sca + L 1 2 {-st we} {-length 200 -orient horiz -var ::sc -from 0 -to 100}}
    {h_3 lab3}
    {lab4 h_3 T 1 1 {-st wsn} {-t "OptCascade: "}}
    {opc + L 1 1 {-st we} {::opc ::opcSet {-width 12}}}
    {v_2 lab4 T 1 1 {-st ew -rw 1}}
    {pro2 h_ L 9 1 {-st ns} {-orient vert -mode indeterminate -afteridle {%w start}}}
  }
  after 100 "preview::Rerun $obj $win"
  $obj showModal $win -focus [$obj Ent1] -geometry $algeom
  destroy $win
  $obj destroy
}

# ________________________ Run me _________________________ #

  preview::InitArgs
  preview::Run
  exit

# ________________________ EOF _________________________ #
