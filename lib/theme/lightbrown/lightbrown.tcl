###########################################################
# Name:    lightbrown.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/28/2023
# Brief:   Handles lightbrown ttk theme.
# License: MIT.
###########################################################

# ________________________ lightbrown NS _________________________ #

namespace eval ttk::theme::lightbrown {

  proc LoadImages {imgdir} {
    foreach pattern {*.gif *.png} {
      foreach file [glob -directory $imgdir $pattern] {
        set img [file tail [file rootname $file]]
        set fmt [string trimleft [file extension $file] .]
        if {![info exists images($img)]} {
          set images($img) [image create photo -file $file -format $fmt]
        }
      }
    }
    return [array get images]
  }

  variable I
  array set I [LoadImages [file join [file dirname [info script]] lightbrown]]

  ## ________________________ Theme _________________________ ##

  ttk::style theme create lightbrown -parent clam -settings {

    ## ________________________ Colors _________________________ ##

    variable fontdef [font actual TkDefaultFont]
    variable \
      tfg2 #00002f \
      tfg1 #00001a \
      tbg2 #f6f4f2 \
      tbg1 #f6f4f2 \
      thlp #7b3e30 \
      tbgS #edc89b \
      tfgS #000000 \
      tcur #682800 \
      tfgD #808080 \
      tbgD #f6f4f2 \
      bclr #d59e6d \
      tfgI #000000 \
      tbgI #deb98c \
      tfgM #00001a \
      tbgM #dfdddb \
      twfg #000000 \
      twbg #ffff45 \
      tHL2 #e3e2e0 \
      tbHL #a30000 \
      chkHL #900000 \
      aclr #890970

    ttk::style configure "." \
      -background        $tbg1 \
      -foreground        $tfg1 \
      -bordercolor       $tfgD \
      -darkcolor         $tbg1 \
      -lightcolor        $tbg1 \
      -troughcolor       $tbg1 \
      -arrowcolor        $tfg1 \
      -selectbackground  $tbgS \
      -selectforeground  $tfgS \
      ;#-selectborderwidth 0
    ttk::style map "." \
      -background       [list disabled $tbg1 active $tbg2] \
      -foreground       [list disabled grey active $tfg1]
    # configuring themed widgets
    foreach ts {TLabel TButton TCheckbutton TRadiobutton TMenubutton} {
      ttk::style configure $ts -font $fontdef
      ttk::style configure $ts -foreground $tfg1
      ttk::style configure $ts -background $tbg1
      ttk::style map $ts -background [list pressed $tbg2 active $tbg2 focus $tbgS alternate $tbg2]
      ttk::style map $ts -foreground [list disabled $tfgD pressed $tfgS active $aclr focus $tfgS alternate $tfg2 focus $tfg2 selected $tfg1]
      ttk::style map $ts -bordercolor [list focus $bclr pressed $bclr]
      ttk::style map $ts -lightcolor [list focus $bclr]
      ttk::style map $ts -darkcolor [list focus $bclr]
    }
    ttk::style configure TLabelframe.Label -foreground $thlp  ;# bclr $tfg2
    ttk::style configure TLabelframe.Label -background $tbg1
    ttk::style configure TLabelframe.Label -font $fontdef
    foreach ts {TNotebook TFrame} {
      ttk::style configure $ts -background $tbg1
      ttk::style map $ts -background [list focus $tbg1 !focus $tbg1]
    }
    foreach ts {TNotebook.Tab} {
      ttk::style configure $ts -font $fontdef
      ttk::style map $ts -foreground [list {selected !active} $tfgS {!selected !active} $tfgM active $aclr {selected active} $aclr]
      ttk::style map $ts -background [list {selected !active} $tbgS {!selected !active} $tbgM {!selected active} $tbg2 {selected active} $tbg2]
    }
    foreach ts {TEntry Treeview TSpinbox TCombobox TCombobox.Spinbox TMatchbox TNotebook.Tab TScale} {
      ttk::style map $ts -lightcolor [list focus $bclr active $bclr]
      ttk::style map $ts -darkcolor [list focus $bclr active $bclr]
    }
    ttk::style map TScrollbar -troughcolor [list !active $tbg1 active $tbg2]
    ttk::style map TScrollbar -background [list !active $tbg1 disabled $tbg1 {!selected !disabled active} $tbgS]
    ttk::style map TProgressbar -troughcolor [list !active $tbg2 active $tbg1]
    ttk::style configure TProgressbar -background $tbgS
    ttk::style conf TSeparator -background #3c3c3c
    foreach ts {TEntry Treeview TSpinbox TCombobox TCombobox.Spinbox TMatchbox} {
      ttk::style configure $ts -font $fontdef
      ttk::style configure $ts -selectforeground $tfgS
      ttk::style configure $ts -selectbackground $tbgS
      ttk::style map $ts -selectforeground [list !focus $tfg1]
      ttk::style map $ts -selectbackground [list !focus $tbg1]
      ttk::style configure $ts -fieldforeground $tfg2
      ttk::style configure $ts -fieldbackground $tbg2
      ttk::style configure $ts -insertcolor $tcur
      ttk::style map $ts -bordercolor [list focus $bclr active $bclr]
      if {$ts eq {TCombobox}} {
        # combobox is sort of individual
        ttk::style configure $ts -foreground $tfg1
        ttk::style configure $ts -background $tbg1
        ttk::style map $ts -background [list {readonly focus} $tbg2 {active focus} $tbg2]
        ttk::style map $ts -foreground [list {readonly focus} $tfg2 {active focus} $tfg2]
        ttk::style map $ts -fieldforeground [list {active focus} $tfg2 readonly $tfg2 disabled $tfgD]
        ttk::style map $ts -fieldbackground [list {active focus} $tbg2 {readonly focus} $tbg2 {readonly !focus} $tbg1 disabled $tbgD]
        ttk::style map $ts -focusfill	[list {readonly focus} $tbgS]
      } else {
        ttk::style configure $ts -foreground $tfg2
        ttk::style configure $ts -background $tbg2
        if {$ts eq {Treeview}} {
          ttk::style map $ts -foreground [list readonly $tfgD disabled $tfgD {selected focus} $tfgS {selected !focus} $thlp]
          ttk::style map $ts -background [list readonly $tbgD disabled $tbgD {selected focus} $tbgS {selected !focus} $tbg1]
        } else {
          ttk::style map $ts -foreground [list readonly $tfgD disabled $tfgD selected $tfgS]
          ttk::style map $ts -background [list readonly $tbgD disabled $tbgD selected $tbgS]
          ttk::style map $ts -fieldforeground [list readonly $tfgD disabled $tfgD]
          ttk::style map $ts -fieldbackground [list readonly $tbgD disabled $tbgD]
        }
      }
    }
    ttk::style configure Heading -font $fontdef -relief raised -padding 1 -background $tbg1
    ttk::style map Heading -foreground [list active $aclr]
    option add *Listbox.font $fontdef
    option add *Menu.font $fontdef
    ttk::style configure TMenubutton -foreground $tfgM
    ttk::style configure TMenubutton -background $tbgM
    ttk::style map TMenubutton -arrowcolor [list disabled $tfgD]
    ttk::style configure TButton -foreground $tfgM
    ttk::style configure TButton -background $tbgM
    foreach {nam clr} {back tbg2 fore tfg2 selectBack tbgS selectFore tfgS} {
      option add *Listbox.${nam}ground [set $clr]
    }
    foreach {nam clr} {back tbgM fore tfgM selectBack tbgS selectFore tfgS} {
      option add *Menu.${nam}ground [set $clr]
    }
    foreach ts {TRadiobutton TCheckbutton} {
      ttk::style map $ts -background [list focus $tbg2 !focus $tbg1]
    }
    # esp. for default/alt/classic themes and dark CS:
    # checked buttons to be lighter
    foreach ts {TCheckbutton TRadiobutton} {
      ttk::style configure $ts -indicatorcolor $tbgM
      ttk::style map $ts -indicatorcolor [list pressed $tbg2 selected $chkHL]
    }

    ## ________________________ Treeview _________________________ ##

    ttk::style element create Treeheading.cell image \
      [list $I(tree-n) \
        selected $I(tree-p) \
        disabled $I(tree-d) \
        pressed $I(tree-p) \
        active $I(tree-h) \
      ] -border 4 -sticky ew

    ## ________________________ Button _________________________ ##

    ttk::style configure TButton -padding 3 -width -11 -anchor center
    ttk::style layout TButton {
      Button.focus -children {
        Button.button -children {
          Button.padding -children {
            Button.label
          }
        }
      }
    }
    ttk::style element create Button.button image \
      [list $I(button-n) \
        pressed $I(button-a) \
        active $I(button-s) \
        focus $I(button-a) \
        disabled $I(button-d) \
      ] -border {4 9} -padding 3 -sticky nsew

    ## ________________________ Checkbutton _________________________ ##

    ttk::style element create Checkbutton.indicator image \
      [list $I(check-nu) \
        {disabled selected} $I(check-dc) \
        disabled $I(check-du) \
        {pressed selected} $I(check-nc) \
        pressed $I(check-nu) \
        {active selected} $I(check-nc) \
        active $I(check-nu) \
        selected $I(check-nc) \
      ] -width 24 -sticky w

    ttk::style configure TCheckbutton -padding 1

    ## ________________________ Radiobutton _________________________ ##

    ttk::style element create Radiobutton.indicator image \
      [list $I(radio-nu) \
        {disabled selected} $I(radio-dc) \
        disabled $I(radio-du) \
        {pressed selected} $I(radio-nc) \
        pressed $I(radio-nu) \
        {active selected} $I(radio-nc) \
        active $I(radio-nu) \
        selected $I(radio-nc) \
      ] -width 24 -sticky w

    ttk::style configure TRadiobutton -padding 1

    ## ________________________ Menubutton _________________________ ##

    ttk::style element create Menubutton.border image \
      [list $I(button-n) \
        selected $I(button-a) \
        disabled $I(button-d) \
        active $I(button-a) \
      ] -border 4 -sticky ew

    ## ________________________ Toolbutton _________________________ ##

    ttk::style configure Toolbutton -anchor center
    ttk::style configure Toolbutton -padding -5 -relief flat
    ttk::style configure Toolbutton.label -padding 0 -relief flat

    ttk::style element create Toolbutton.border image \
      [list $I(blank) \
        pressed $I(toolbutton-p) \
        {selected active} $I(toolbutton-pa) \
        selected $I(toolbutton-p) \
        active $I(toolbutton-a) \
        disabled $I(blank)
      ] -border 11 -sticky nsew

    ## ________________________ Entry _________________________ ##

    ttk::style configure TEntry -padding 1 -insertwidth 1

    ## ________________________ Combobox _________________________ ##

    ttk::style element create Combobox.downarrow image \
      [list $I(comboarrow-n) \
        disabled $I(comboarrow-d) \
        pressed $I(comboarrow-p) \
        active $I(comboarrow-a) \
      ] -border 1 -sticky {}

    ttk::style element create Combobox.field image \
      [list $I(combo-n) \
        {readonly disabled} $I(combo-rd) \
        {readonly pressed} $I(combo-rp) \
        {readonly focus} $I(combo-rf) \
        {!readonly focus} $I(combo-rf) \
        readonly $I(combo-rn) \
      ] -border 4 -sticky ew
    ttk::style configure ComboboxPopdownFrame -borderwidth 1 -relief groove

    ## ________________________ Notebook _________________________ ##

    ttk::style element create tab \
     	image [list $I(notebook_inactive) \
      {selected focus} $I(notebook_active_foc) \
      {selected !focus} $I(notebook_active) \
     	] -border {2 2 2 1} -width 8
    ttk::style configure TNotebook.Tab -padding {4 2}
    ttk::style configure TNotebook -expandtab {2 1}
    ttk::style map TNotebook.Tab \
     	-expand [list selected {0 0 0 1} !selected {0 0}]

    ## ________________________ Labelframe _________________________ ##

    ttk::style configure TLabelframe -borderwidth 2 -relief groove

    ## ________________________ Scrollbar _________________________ ##

    ttk::style element create Horizontal.Scrollbar.trough image $I(scroll-hor-trough) -sticky ew -border 3
    ttk::style element create Horizontal.Scrollbar.thumb image [list \
        $I(scroll-hor-thumb)  \
        disabled  $I(scroll-hor-trough) \
        pressed $I(scroll-hor-hover) \
        active $I(scroll-hor-hover) \
      ] -sticky ew -border 3

    ttk::style element create Horizontal.Scrollbar.rightarrow image $I(scroll-right) -sticky {} -width 12
    ttk::style element create Horizontal.Scrollbar.leftarrow image $I(scroll-left) -sticky {} -width 12

    ttk::style element create Vertical.Scrollbar.trough image $I(scroll-vert-trough) -sticky ns -border 3
    ttk::style element create Vertical.Scrollbar.thumb image [list \
      $I(scroll-vert-thumb) \
        disabled  $I(scroll-vert-trough) \
        pressed $I(scroll-vert-hover) \
        active $I(scroll-vert-hover) \
      ] -sticky ns -border 3

    ttk::style element create Vertical.Scrollbar.uparrow image $I(scroll-up) -sticky {} -height 12
    ttk::style element create Vertical.Scrollbar.downarrow image $I(scroll-down) -sticky {} -height 12

    ## ________________________ Scale _________________________ ##


    ## ________________________ Progressbar _________________________ ##

    ttk::style element create Horizontal.Progressbar.trough \
    	image $I(through_h) -border  {3 3}
    ttk::style element create Vertical.Progressbar.trough \
    	image $I(through) -border  {3 3}
    ttk::style element create Horizontal.Progressbar.pbar image $I(progress-h) \
      -border {3 3} -padding 1
    ttk::style element create Vertical.Progressbar.pbar image $I(progress-v) \
      -border {3 3} -padding 1

    ## ________________________ Sizegrip _________________________ ##

    ttk::style element create sizegrip image $I(sizegrip)

    ## ________________________ Sash _________________________ ##

    ttk::style configure Sash -sashthickness 6 -gripcount 16

    ## ________________________ Switch _________________________ ##

    ttk::style layout Switch.TCheckbutton {
      Switch.button -children {
        Switch.padding -children {
          Switch.indicator -side left
          Switch.label -side right -expand true
        }
      }
    }
    ttk::style element create Switch.indicator image \
      [list $I(swi-off) \
        {selected disabled} $I(swi-on) \
        disabled $I(swi-off) \
        {active selected} $I(swi-on-act) \
        active $I(swi-off-act) \
        {focus selected} $I(swi-on-act) \
        {!focus selected} $I(swi-on) \
        {focus !selected} $I(swi-off-act) \
        {!focus !selected} $I(swi-off) \
      ] -width 46 -sticky w

  }

  # ________________________ EONS _________________________ #

}
