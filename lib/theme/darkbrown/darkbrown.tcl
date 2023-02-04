###########################################################
# Name:    darkbrown.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/25/2023
# Brief:   Handles darkbrown ttk theme.
# License: MIT.
###########################################################

# ________________________ darkbrown NS _________________________ #

namespace eval ttk::theme::darkbrown {

  proc LoadImages {imgdir} {
    variable I
    foreach file [glob -directory $imgdir *.gif *.png] {
      set img [file tail [file rootname $file]]
      set fmt [string trimleft [file extension $file] .]
      set I($img) [image create photo -file $file -format $fmt]
    }
  }

  ## ________________________ Theme _________________________ ##

  LoadImages [file join [file dirname [info script]] darkbrown]

  ttk::style theme create darkbrown -parent clam -settings {

    ## ________________________ Colors _________________________ ##

    variable fontdef [font actual TkDefaultFont]
    variable \
      tfg1 #bebebe \
      tbg1 #232323 \
      tfg2 #bebebe \
      tbg2 #0a0a0a \
      tfgS #ffffff \
      tbgS #765632 \
      tfgD #616161 \
      tbgD #232323 \
      tcur #f4f49f \
      bclr #aa7d3d \
      thlp #de9e5e \
      tfgI #000000 \
      tbgI #767676 \
      tbgM #303030 \
      twfg #000000 \
      twbg #9d9d60 \
      tHL2 #131313 \
      tbHL #ffc341 \
      chkHL #dda11f \
      tfgM #bebebe \
      aclr #ff9dff

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

    ## _____ Buttons, check*, radio*, menu* ________ ##

    ttk::style layout TButton {
      Button.button -children {Button.focus -children Button.label}
    }
    ttk::style configure TButton -padding 3 -width -11 -anchor center
    ttk::style element create Button.button image [list $I(buttonNorm) \
	    pressed $I(buttonPressed) \
      active $I(through) \
      focus $I(button) \
     	] -border {4 9} -padding 3 -sticky nsew
    ttk::style element create Checkbutton.indicator \
     	image [list $I(checkbox_unchecked) \
     	  {!selected focus} $I(checkbox_unchecked_foc) \
     	  {selected focus} $I(checkbox_checked_foc) \
     	  {selected !focus} $I(checkbox_checked) \
     	] -width 20 -sticky w
    ttk::style element create Radiobutton.indicator \
     	image [list $I(option_out) \
     	  {!selected focus} $I(option_out_foc) \
     	  {selected focus} $I(option_in_foc) \
     	  {selected !focus} $I(option_in) \
     	] -width 20 -sticky w

    ## ________________ Scrollbars ________________ ##

    ttk::style element create Horizontal.Scrollbar.thumb image [list \
    	$I(scroll_horizontal) \
      disabled  $I(horizontal_trough) \
      active $I(scroll_hor_actv) \
    ] -border 3 -width 15 -height 0 -sticky nsew
    ttk::style element create Horizontal.Scrollbar.trough \
    	image [list \
    	$I(horizontal_trough) \
    	active $I(horizontal_trough_actv) \
    	!active $I(horizontal_trough) \
    	] -sticky ew -border {1 1}
    ttk::style element create Vertical.Scrollbar.thumb image [list \
    	$I(scroll_vertical) \
      disabled $I(vertical_trough) \
      active $I(scroll_ver_actv) \
    ] -border 3 -width 0 -height 15 -sticky nsew
    ttk::style element create Vertical.Scrollbar.trough \
    	image [list \
    	$I(vertical_trough_actv) \
    	active $I(vertical_trough_actv) \
    	!active $I(vertical_trough) \
    	] -sticky ns -border {1 1}

    ## ________________________ Scales _________________________ ##

    ttk::style element create Horizontal.Scale.trough \
    	image [list \
    	$I(trough_scale) \
    	active $I(trough_scale_actv) \
    	!active $I(trough_scale) \
    	] -sticky ew -border {1 1}
    ttk::style element create Vertical.Scale.trough \
    	image [list \
    	$I(trough_scale) \
    	active $I(trough_scale_actv) \
    	!active $I(trough_scale) \
    	] -sticky ns -border {1 1}

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

    ## ________________________ Combobox _________________________ ##

    ttk::style layout TCombobox {
      Combobox.field -sticky nsew -children {
        Combobox.padding -expand 1 -sticky nsew -children {
          Combobox.textarea -sticky nsew
        }
      }
      null -side right -sticky ns -children {
        Combobox.arrow -sticky nsew
      }
    }
    ttk::style element create Combobox.field image \
      [list $I(combo-n) focus $I(combo-f) readonly $I(combo-rn) \
      ] -padding {6 4 20 4} -border 4 -sticky ew
    ttk::style element create Combobox.arrow image [list $I(arrow_down) disabled $I(arrow_down_dsbl)] -width 20 -sticky {}
    ttk::style configure ComboboxPopdownFrame -borderwidth 1 -relief groove

    ## ________________________ Progressbars _________________________ ##

    ttk::style element create Horizontal.Progressbar.trough \
    	image $I(through_h) -border  {3 3}
    ttk::style element create Vertical.Progressbar.trough \
    	image $I(through) -border  {3 3}
    ttk::style element create Horizontal.Progressbar.pbar \
	    image $I(progress-h) -border {3 3}
    ttk::style element create Vertical.Progressbar.pbar \
	    image $I(progress-v) -border {3 3}

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
