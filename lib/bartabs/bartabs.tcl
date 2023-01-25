###########################################################
# Name:    bartabs.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/12/2023
# Brief:   Handles the tab bar widget.
# License: MIT.
###########################################################

package provide bartabs 1.6.3

# ________________________ NS bartabs _________________________ #

namespace eval bartabs {

  # IDs for new bars & tabs
  variable NewBarID -1 NewTabID -1 NewTabNo -1
  variable NewAfterID;  array set NewAfterID [list]

  # images made by base64
  image create photo bts_ImgLeft \
  -data {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAElBMVEUAAABJSUmSkpJtbW22trbb
29vYK8X/AAAAAXRSTlMAQObYZgAAAEBJREFUCNdjAANGBigQhNKMjlCGEJTBqAplCIVCGIwqKopg
hrATjKGkZAiRMgIyIEJABlTIEGYDjMEoiGQp3BkAc58E+W1dC9QAAAAASUVORK5CYII=}
  image create photo bts_ImgRight \
  -data {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAElBMVEUAAABJSUmSkpJtbW22trbb
29vYK8X/AAAAAXRSTlMAQObYZgAAAEBJREFUCNdjYGAQYIACQRhDRADGUIQxggSgjFCokJCTkwCU
oWIIZggrKcEYygIQBlAAwgAKQBiCMLsE0C2FCAAAa1IEzBjs2sUAAAAASUVORK5CYII=}
  image create photo bts_ImgNone \
  -data {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAAA1BMVEUAAACnej3aAAAAAXRSTlMA
QObYZgAAAAtJREFUCNdjIBEAAAAwAAFletZ8AAAAAElFTkSuQmCC}
  image create photo bts_ImgClose \
  -data {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAALVBMVEUAAAAAACTb29u2trbt4+Ll
4eHw4eD/6N/y3Nv85N/94t3m29vn0dPjz8/dyssim+gAAAAAAXRSTlMAQObYZgAAAEdJREFUCNdj
wAvaFZiWgWgORSUlYQcgg11QSFFQAchgUhQUFLoAkjskKKgNVqwkKKjHAJMCqeGEKWYzBGoPAMk5
KTCp4rURAEWmB5A5tzUJAAAAAElFTkSuQmCC}

  variable BarsList [list]
; proc drawAll {} {
    # Draws all bars. Used at updating themes etc.
    foreach bars $bartabs::BarsList {$bars drawAll}
  }
  #_______________________

  proc messageBox {type ttl msg args} {
    # Runs Tk's or apave's ok/yes/no/cancel dialogue.
    #  type - ok, yesno or yesnocancel
    #  ttl - title
    #  ttl - message
    # args - additional arguments of tk_messageBox
    # Returns 1 if 'yes' chosen, 2 if 'no', 0 otherwise.

    # try the apave package's dialogue
    if {[catch {set res [::apave::obj $type ques $ttl $msg]}]} {
      # or run the standard tk_messageBox
      set res [tk_messageBox -title $ttl -message $msg -type $type \
        -icon question {*}$args]
      set res [expr {$res eq {yes} ? 1 : ($res eq {no} ? 2 : 0)}]
    }
    return $res
  }

  ## ____________ EONS bartabs ____________ ##

}


# ____________ bartabs class hierarchy ____________ #

oo::class create bartabs::Tab {
}

oo::class create bartabs::Bar {
  superclass bartabs::Tab
}

oo::class create bartabs::Bars {
  superclass bartabs::Bar
}

# ________________________ Tab _______________________ #

## ____________ Private methods of Tab ____________ ##

oo::define bartabs::Tab {

method My {ID} {
# Creates a caller of method.
#   ID - ID of caller

  set t [string range $ID 0 2]
  oo::objdefine [self] "method $ID {args} { \
    set m \[lindex \$args 0\] ; \
    if {\$m in {{} -1}} {return {}} ; \
    if {\$m in {create} && {$t} eq {bar} || \$m in {cget configure} && {$t} eq {tab}} { \
    set args \[lreplace \$args 0 0 Tab_\$m\]} ; \
    return \[my {*}\$args\]}"
}
#_______________________

method ID {} {
# Gets ID of caller.

  return [lindex [uplevel 1 {self caller}] 2]
}
#_______________________

method IDs {TID} {
# Returns a pair of TID and BID.

  return [list $TID [my $TID cget -BID]]
}
#_______________________

method Tab_Create {BID TID w text} {
# Creates a tab widget (frame, label, button).
#   w - parent frame
#   text - tab's label
# Returns a list of created widgets of the tab.

  lassign [my $BID cget -relief -bd -padx -pady -BGMAIN] relief bd padx pady bgm
  lassign [my $TID cget -wb -wb1 -wb2] wb wb1 wb2
  if {!$bd} {set relief flat}
  if {![my Tab_Is $wb]} {
    if {$wb eq {}} {
      set bartabs::NewTabNo [expr {($bartabs::NewTabNo+1)%1000000}]
      set wb $w.$TID[format %06d $bartabs::NewTabNo]
      set wb1 $wb.l
      set wb2 $wb.b
    }
    my $TID configure -wb $wb -wb1 $wb1 -wb2 $wb2
    ttk::frame $wb -borderwidth [expr {$bd? $bd : 2}]
    ttk::label $wb1
    if {[my TtkTheme]} {
      ttk::button $wb2 -style ClButton$BID -image bts_ImgNone \
        -command [list [self] $TID close yes -withicon yes] -takefocus 0
    } else {
      button $wb2 -relief flat -borderwidth 0 -highlightthickness 0 -image bts_ImgNone \
        -command [list [self] $TID close yes -withicon yes] -takefocus 0 -background $bgm
    }
  }
  $wb configure -relief $relief
  $wb1 configure -relief flat -padding "$padx $pady $padx $pady" \
    {*}[my Tab_Font $BID]
  lassign [my Tab_TextEllipsed $BID $text] text ttip
  if {[set tip [my $TID cget -tip]] ne {}} {
    my $TID configure -tip $tip  ;# run baltip after creating $wb1 & $wb2
  }
  $wb1 configure -text $text -background $bgm
  if {[my Tab_Iconic $BID]} {
    $wb2 configure -state normal
  } else {
    $wb2 configure -state disabled -image {}
  }
  return [list $wb $wb1 $wb2]
}
#_______________________

method Tab_create {tabCom label} {
  # Creates tab method and registers it. Defined by "My".

  set BID [my ID]
  if {[set TID [my $BID tabID $label]] eq {}} {
    return -code error "No label {$label} in $BID"
  }
; proc $tabCom {args} "return \[[self] $TID {*}\$args\]"
  set lObj [my $BID cget -TABCOM]
  my $BID configure -TABCOM [lappend lObj [list $TID $tabCom]]
}
#_______________________

method Tab_ExpandOption {BID expand} {
  # Gets a real -expand option, counting that it may be set as a number>1
  # meaning "starting from this number do expanding, otherwise not"
  #   expand - original value of -expand option

  if {[string is digit $expand] && $expand>1} {
    set tabs [my $BID cget -TABS]
    set expand [expr {$expand<[llength $tabs]}]
  }
  return $expand
}
#_______________________

method Tab_cget {args} {
# Gets options of tab.
#   args - list of options
# Returns a list of values or one value if args is one option.

  variable btData
  lassign [my Tab_BID [set TID [my ID]]] BID i tab
  lassign $tab tID tdata
  set llen [dict get $btData $BID -LLEN]
  set res [list]
  foreach opt $args {
    switch -- $opt {
      -BID {lappend res $BID}
      -text - -wb - -wb1 - -wb2 - -pf {
        if {[catch {lappend res [dict get $tdata $opt]}]} {
          lappend res {}
        }
      }
      -index {if {$i<($llen-1)} {lappend res $i} {lappend res end}}
      -width {  ;# width of tab widget
        lassign [my Tab_DictItem $tab] tID text wb wb1 wb2
        if {![my Tab_Is $wb]} {
          lappend res 0
        } else {
          set b1 [ttk::style configure TLabel -borderwidth]
          if {$b1 eq {}} {set b1 0}
          lassign [my $BID cget -bd -expand -static] bd expand static
          set bd [expr {$bd?2*$b1:0}]
          set b2 [expr {[my Aux_WidgetWidth $wb2]-3}]
          set expand [my Tab_ExpandOption $BID $expand]
          set expand [expr {$expand||![my Tab_Iconic $BID]?2:0}]
          lappend res [expr {[my Aux_WidgetWidth $wb1]+$b2+$bd+$expand}]
        }
      }
      default {  ;# user's options
        if {[catch {lappend res [dict get $tdata $opt]}]} {lappend res {}}
      }
    }
  }
  if {[llength $args]==1} {return [lindex $res 0]}
  return $res
}
#_______________________

method Tab_configure {args} {
# Sets values of options for a tab.
#   args - list of pairs "option value"

  lassign [my Tab_BID [set TID [my ID]]] BID i tab
  lassign $tab tID data
  foreach {opt val} $args {
    dict set data $opt $val
    if {$opt eq {-tip}} {   ;# configure the tab's tip
      lassign [my $TID cget -wb1 -wb2] wb1 wb2
      if {$wb1 ne {}} {
        catch {
          baltip::tip $wb1 $val -under 3
          baltip::tip $wb2 $val -under 3
        }
      }
    }
  }
  set tab [list $TID $data]
  my $BID configure -TABS [lreplace [my $BID cget -TABS] $i $i $tab]
}
#_______________________

method Tab_DictItem {TID {data ""}} {
# Gets item data from a tab item (ID + data).
#   TID - tab ID or the tab item (ID + data).
#   data - tab's data (list of option-value)
# If 'data' omitted, TID is a tab item (ID + data).
# If the tab's attribute is absent, it's meant to be "".
# Returns a list of values: ID, text, wb, wb1, wb2, pf.

  if {$data eq {}} {lassign $TID TID data}
  set res [list $TID]
  foreach a {-text -wb -wb1 -wb2 -pf} {
    if {[dict exists $data $a]} {
      lappend res [dict get $data $a]
    } else {
      lappend res {}
    }
  }
  return $res
}
#_______________________

method Tab_ItemDict {TID text {wb ""} {wb1 ""} {wb2 ""} {pf ""}} {
# Gets a tab item (ID + data) from item data.
#   text - tab's text;
#   wb - tab's frame widget
#   wb1 - tab's label widget
#   wb2 - tab's button widget
#   pf - "p" for tab packed, "" for tab forgotten
# Returns a tab item (ID + data).

  return [list $TID [list -text $text -wb $wb -wb1 $wb1 -wb2 $wb2 -pf $pf]]
}
#_______________________

method Tab_Data {BID text} {
# Creates data of new tab.
#   text - new tab's label
# The bar is checked for a duplicate of 'text'.
# Returns a tab item or "" (if duplicated).

  variable btData
  if {[dict exists $btData $BID] && [my $BID tabID $text] ne {}} {return {}}
  my My tab[incr bartabs::NewTabID]
  return [my Tab_ItemDict tab$bartabs::NewTabID $text]
}
#_______________________

method Tab_BID {TID {act ""}} {
# Gets BID from TID.
#   act - if "check", only checks the existance of TID
# If 'act' is "check" and a bar not found, -1 is returned, otherwise BID.
# Returns a list of 1. BID (or -1 if no bar found) 2. index of the tab in tab list 3. the tab data.

  variable btData
  set BID {}
  dict for {bID bInfo} $btData {
    set tabs [my $bID cget -TABS]
    if {[set i [my Aux_IndexInList $TID $tabs]] > -1} {
      set BID $bID
      break
    }
  }
  if {$act eq {check}} {return $BID}
  if {$BID eq {}} {
    return -code error "bartabs: tab ID $TID not found in the bars"
  }
  return [list $BID $i [lindex $tabs $i]]
}
#_______________________

method Tab_Bindings {BID} {
# Sets bindings on events of tabs.

  lassign [my $BID cget -static -FGOVER -BGOVER -WWID] static fgo bgo wwid
  foreach tab [my $BID listTab] {
    lassign $tab TID text wb wb1 wb2
    if {[my Tab_Is $wb]} {
      set bar "[self] $BID"
      set tab "[self] $TID"
      set ctrlBP "$tab OnCtrlClick ; break"
      foreach w [list $wb $wb1 $wb2] {
        bind $w <Enter> "$bar OnEnterTab $TID $wb1 $wb2 $fgo $bgo"
        bind $w <Leave> "[self] $TID OnLeaveTab $wb1 $wb2"
        bind $w <Button-3> "[self] $TID OnPopup %X %Y"
        bind $w <Control-ButtonPress> $ctrlBP
      }
      bind $wb <Control-ButtonPress> $ctrlBP
      bind $wb <ButtonPress> "[self] $BID OnButtonPress $TID $wb1 {}"
      bind $wb1 <ButtonPress> "[self] $BID OnButtonPress $TID $wb1 %x"
      bind $wb1 <ButtonRelease> "[self] $BID OnButtonRelease $wb1 %x"
      bind $wb1 <Motion> "[self] $BID OnButtonMotion $wb $wb1 %x %y"
    }
  }
  bind [lindex $wwid 0] <Button-3> "[self] $BID OnPopup %X %Y $BID"
}
#_______________________

method Tab_Font {BID} {
# Gets a font attributes for tab label.

  set font [my $BID cget -font]
  if {$font eq {}} {
    if {[set font [ttk::style configure TLabel -font]] eq {}} {
      set font TkDefaultFont
    }
    set font [font actual $font]
  }
  return "-font {$font}"
}
#_______________________

method Tab_MarkAttrs {BID TID {withbg yes} {wb2 ""}} {
# Gets image & mark attributes of marks.
#   TID - ID of current tab
#   withbg - if true, gets also background
#   wb2 - tab's button
# Returns string of attributes if any.

  lassign [my $BID cget \
    -mark -imagemark -fgmark -bgmark -IMAGETABS -FGMAIN -BGMAIN -FGDSBL -BGDSBL] \
    marktabs imagemark fgm bgm imagetabs fgmain bgmain fgdsbl bgdsbl
  set res {}
  if {[my Disabled $TID]} {
    set imagemark {}
    if {$wb2 ne {}} {$wb2 configure -state disabled}
    set res " -foreground $fgdsbl"
    if {$withbg} {append res " -background $bgdsbl"}
  } elseif {[lsearch $marktabs $TID]>-1} {
    if {$imagemark eq {}} {
      if {$fgm eq {}} {set fgm $fgmain}  ;# empty value - no markable tabs
      set res " -foreground $fgm"
      if {$withbg} {
        if {$bgm eq {}} {set bgm $bgmain}
        append res " -background $bgm"
      }
      if {$wb2 ne {}} {$wb2 configure -image bts_ImgNone}
    }
  } else {
    set imagemark {}
    if {[set i [lsearch -index 0 $imagetabs $TID]]>-1} {
      set imagemark [lindex $imagetabs $i 1]
    } elseif {$wb2 ne {}} {
      $wb2 configure -image bts_ImgNone
    }
  }
  if {$imagemark ne {}} {
    set res " -image $imagemark"
    if {$wb2 ne {}} {
      $wb2 configure {*}$res
      catch {$wb2 configure -style ClButton$BID}
    }
  }
  return $res
}
#_______________________

method Tab_SelAttrs {fnt fgsel bgsel} {
# Gets font attributes of selected tab.
#   fnt - original font attributes
#   fgsel - foreground for selection
#   bgsel - background for selection
# If both set, fgsel and bgsel mean colors
# If bgsel=="", fgsel!="", fgsel is a widget to get attributes
# If fgsel=="", 'selection' is 'underlining'

  lassign $fnt opt val
  if {$fgsel eq {}} {
    set val [dict set val -underline 1]
  } else {
    if {$bgsel eq {}} {
      set bgsel [ttk::style configure $fgsel -selectbackground]
      set fgsel [ttk::style configure $fgsel -selectforeground]
    }
    set opt "-foreground $fgsel -background $bgsel $opt"
  }
  return "$opt {$val}"
}
#_______________________

method Tab_MarkBar {BID {TID "-1"}} {
# Marks the tabs of a bar .
#   TID - ID of the current tab

  lassign [my $BID cget -tabcurrent -fgsel -bgsel -select -FGMAIN -BGMAIN] \
    tID fgs bgs fewsel fgm bgm
  if {$TID in {{} {-1}}} {set TID $tID}
  foreach tab [my $BID listTab] {
    lassign $tab tID text wb wb1 wb2
    if {[my Tab_Is $wb]} {
      set font [my Tab_Font $BID]
      set selected [expr {$tID == $TID || [lsearch $fewsel $tID]>-1}]
      if {$selected} {set font [my Tab_SelAttrs $font $fgs $bgs]}
      $wb1 configure {*}$font
      set attrs [my Tab_MarkAttrs $BID $tID [expr {!$selected}] $wb2]
      if {$attrs ne {} && {-image} ni $attrs } {
        $wb1 configure {*}$attrs
      } elseif {!$selected} {
        $wb1 configure -foreground $fgm -background $bgm
      }
    }
  }
  my $BID configure -tabcurrent $TID
}
#_______________________

method Tab_MarkBars {{BID -1} {TID -1}} {
# Marks the tabs.
#   BID - bar ID (if omitted, all bars are scanned)
#   TID - ID of the current tab

  variable btData
  if {$BID == -1} {
    dict for {BID barOpts} $btData {my Tab_MarkBar $BID}
  } else {
    my Tab_MarkBar $BID $TID
  }
}
#_______________________

method Tab_TextEllipsed {BID text {lneed -1}} {
# Gets a tab's label and tip
#   text - label
#   lneed - label length anyway
# Returns a pair "label tip".

  lassign [my $BID cget -lablen -ELLIPSE] lablen ellipse
  if {$lneed ne -1} {set lablen $lneed}
  if {$lablen && [string length $text]>$lablen} {
    set ttip $text
    set text [string range $text 0 $lablen-1]
    append text $ellipse
  } else {
    set ttip {}
  }
  return [list $text $ttip]
}
#_______________________

method Tab_Iconic {BID} {
# Gets a flag "tabs with icons".
# Returns "yes", if tabs are supplied with icons.

  return [expr {![my $BID cget -static]}]
}
#_______________________

method Tab_Pack {BID TID wb wb1 wb2} {

# Packs a tab widget.
#   wb, wb1, wb2 - tab's widgets
  lassign [my $BID cget -static -expand] static expand
  if {[my Tab_Iconic $BID]} {
    pack $wb1 -side left
    pack $wb2 -side left
  } else {
    pack $wb1 -side left -fill x
    pack forget $wb2
  }
  set expand [my Tab_ExpandOption $BID $expand]
  if {$expand} {
    pack $wb -side left -fill x -expand 1
  } else {
    pack $wb -side left
  }
  my $TID configure -pf "p"
}
#_______________________

method Tab_RemoveLinks {BID TID} {
# Removes a tab's links to lists.

  foreach o {-IMAGETABS -TABCOM -mark -disable -select} {
    set l [my $BID cget $o]
    for {set i 0} {$i>-1} {} {
      if {[set i [lsearch -index 0 $l $TID]]>-1} {
        set l [lreplace $l $i $i]
        my $BID configure $o $l
      }
    }
  }
  my Tab_MarkBars $BID
}
#_______________________

method Tab_Is {wb} {
# Checks if 'wb' is an existing tab widget.
#   wb - path

  return [expr {$wb ne {} && [winfo exists $wb]}]
}
#_______________________

method Tab_CloseFew {{TID -1} {left no} args} {
# Closes tabs of bar.
#   TID - ID of the current tab or -1 if to close all
#   left - "yes" if to close all at left of TID, "no" if at right
#   args - options (if contains -skipsel, selected tabs aren't closed)

  set BID [my ID]
  if {$TID ne {-1}} {lassign [my Tab_BID $TID] BID icur}
  set tabs [my $BID listTab]
  set skipsel [expr {[lsearch $args -skipsel]>-1}]
  set seltabs [my $BID cget -select]
  set doupdate no
  set first 1
  for {set i [llength $tabs]} {$i} {} {
    incr i -1
    set tID [lindex $tabs $i 0]
    if {!$skipsel || $tID ni $seltabs} {
      if {$TID eq {-1} || ($left && $i<$icur) || (!$left && $i>$icur)} {
        if {![set res [my $tID close no -first $first]]} break
        if {$res==1} {set doupdate yes}
        set first 0  ;# -first option is "1" for the very first closed tab
      }
    }
  }
  if {$doupdate} {
    my $BID clear
    if {$TID eq {-1}} {
      my $BID Refill 0 yes
    } else {
      my $BID $TID show yes
    }
  }
}
#_______________________

method PrepareCmd {TID BID opt args} {
# Prepares a command bound to an action on a tab.
#   opt - command option (-csel, -cmov, -cdel)
#   args - additional argumens of the command
# The commands can include wildcards: %b for bar ID, %t for tab ID, %l for tab label.
# Returns "" or the command if 'opt' exists in 'args'.

  variable btData
  if {[dict exists $btData $BID $opt]} {
    set com [dict get $btData $BID $opt]
    if {$TID>-1} {
      set label [my $TID cget -text]
    } else {
      set label {}
    }
    set label [string map {\{ ( \} )} $label]
    lappend com {*}$args
    return [string map [list %b $BID %t $TID %l $label] $com]
  }
  return {}
}

#_______________________

method Tab_Cmd {opt args} {
# Executes a command bound to an action on a tab.
#   opt - command option (-csel, -cmov, -cdel)
#   args - additional argumens of the command
# The commands can include wildcards: %b for bar ID, %t for tab ID, %l for tab label.
# Returns 1, if no command set; otherwise: 1 for Yes, 0 for No, -1 for Cancel.

  lassign [my IDs [my ID]] TID BID
  if {[set com [my PrepareCmd $TID $BID $opt {*}$args]] ne {}} {
    if {[catch {set res [{*}$com]}]} {set res yes}
    if {$res eq {} || !$res} {return 0}
    return $res
  }
  return 1
}

#_______________________

method Tab_BeCurrent {} {
# Makes the tab be currently visible.

  if {[set TID [my ID]] in {{} {-1}} || [my Disabled $TID]} return
  set BID [my $TID cget -BID]
  my $TID Tab_Cmd -csel  ;# command before the selection shown
  my Tab_MarkBar $BID $TID
  if {[set wb2 [my $TID cget -wb2]] ne {} && \
  ![string match "bartabs::*" [$wb2 cget -image]] &&
  $TID ni [my $BID listFlag "m"]} {
    $wb2 configure -image bts_ImgNone
  }
  my $BID Bar_Cmd2 -csel2 $TID ;# command after the selection shown
}
#_______________________

method Disabled {TID} {
  # Checks if the tab is disabled.

  set dsbltabs [my [my $TID cget -BID] cget -disable]
  return [expr {[lsearch $dsbltabs $TID]>-1}]
}

## ____________ Event handlers ____________ ##

method DestroyMoveWindow {} {
  # Destroys the moving window zombi.

  set BID [my ID]
  set movWin [lindex [my $BID cget -MOVWIN] 0]
  catch {destroy $movWin}
  my $BID configure -MOVX {} -wb1 {}
}
#_______________________

method OnEnterTab {TID wb1 wb2 fgo bgo} {
# Handles the mouse pointer entering a tab.
#   wb1, wb2 - tab's widgets
#   fgo, bgo - colors of "mouse over the tab"

  if {[my Disabled $TID]} return
  $wb1 configure -foreground $fgo -background $bgo
  if {[my Tab_Iconic [my ID]]} {$wb2 configure -image bts_ImgClose}
}
#_______________________

method OnLeaveTab {wb1 wb2} {
# Handles the mouse pointer leaving a tab.
#   wb1, wb2 - tab's widgets

  lassign [my IDs [my ID]] TID BID
  if {[my Disabled $TID]} return
  if {![winfo exists $wb1]} return
  lassign [my $BID cget -FGMAIN -BGMAIN] fgm bgm
  $wb1 configure -foreground $fgm -background $bgm
  my Tab_MarkBars $BID
  if {"-image" ni [set attrs [my Tab_MarkAttrs $BID $TID 0 $wb2]] && \
  [my Tab_Iconic $BID]} {
    $wb2 configure -image bts_ImgNone
    catch {$wb2 configure -style ClButton$BID}
  }
}
#_______________________

method OnButtonPress {TID wb1 x} {
# Handles the mouse clicking a tab.
#   wb1 - tab's label
#   x - x position of the mouse pointer

  if {[my Disabled $TID]} return
  my [set BID [my ID]] configure -MOVX $x
  set TID [my $BID tabID [$wb1 cget -text]]
  my $TID Tab_BeCurrent
}
#_______________________

method OnButtonMotion {wb wb1 x y} {
# Handles the mouse moving over a tab.
#   wb - tab's frame
#   wb1 - tab's label
#   x, y - positions of the mouse pointer

  lassign [my [set BID [my ID]] cget \
    -static -FGMAIN -FGOVER -BGOVER -MOVWIN -MOVX -MOVX0 -MOVX1 -MOVY0] \
    static fgm fgo bgo movWin movX movx movx1 movY0
  if {$movX eq {} || $static} return
  # dragging the tab
  if {![winfo exists $movWin]} {
    # make the tab's replica to be dragged
    toplevel $movWin
    if {$::tcl_platform(platform) == "windows"} {
      wm attributes $movWin -alpha 0.0
    } else {
      wm withdraw $movWin
    }
    if {[tk windowingsystem] eq "aqua"} {
      ::tk::unsupported::MacWindowStyle style $movWin help none
    } else {
      wm overrideredirect $movWin 1
    }
    set movx [set movx1 $x]
    set movX [expr {[winfo pointerx .]-$x}]
    set movY0 [expr {[winfo pointery .]-$y}]
    label $movWin.label -text [$wb1 cget -text] -relief solid \
      -foreground black -background #7eeeee  {*}[my Tab_Font $BID]
    pack $movWin.label -expand 1 -fill both -ipadx 1
    wm minsize $movWin [winfo reqwidth $movWin.label] [winfo reqheight $wb1]
    set againstLooseFocus "[self] $BID DestroyMoveWindow"
    bind $movWin <Leave> $againstLooseFocus
    bind $movWin <ButtonPress> $againstLooseFocus
    $wb1 configure -foreground $fgm
    my $BID configure -wb1 $wb1 -MOVX1 $movx1 -MOVY0 $movY0
  }
  lassign [my $BID cget -WWID] wframe wlarr
  lassign [split [winfo geometry $wframe] x+] wflen
  lassign [split [winfo geometry $wlarr] x+] walen
  lassign [split [winfo geometry $wb] x+] wbl - wbx
  if {abs($x-$movx)>1 && ($wflen-$wbx+$movx1+$walen)>$x && ($wbx+$wbl-$movx1+$x)>0} {
    wm geometry $movWin +$movX+$movY0
    if {$::tcl_platform(platform) == "windows"} {
      if {[wm attributes $movWin -alpha] < 0.1} {wm attributes $movWin -alpha 1.0}
    } else {
      catch {wm deiconify $movWin ; raise $movWin}
    }
  }
  my $BID configure -MOVX [expr {$movX+$x-$movx}] -MOVX0 $x
}
#_______________________

method OnButtonRelease {wb1o x} {
# Handles the mouse releasing a tab.
#   wb1o - original tab's label
#   x - x position of the mouse pointer

  lassign [my [set BID [my ID]] cget \
    -MOVWIN -MOVX -MOVX1 -MOVY0 -FGMAIN -wb1 -tleft -tright -wbar -static] \
    movWin movX movx1 movY0 fgm wb1 tleft tright wbar static
  my $BID DestroyMoveWindow
  if {$movX eq {} || $wb1o ne $wb1 || $static} return
  # dropping the tab - find a tab being dropped at
  $wb1 configure -foreground $fgm
  lassign [my Aux_InitDraw $BID no] bwidth vislen bd arrlen llen
  set vislen1 $vislen
  set vlist [list]
  set i 0
  set iw1 -1
  set tabssav [set tabs [my $BID cget -TABS]]
  foreach tab $tabs {
    lassign [my Tab_DictItem $tab] tID text _wb _wb1 _wb2 _pf
    if {$_pf ne {}} {
      if {$_wb1 eq $wb1} {
        set vislen0 $vislen
        set tab1 $tab
        set iw1 $i
        set TID $tID
      }
      set wl [expr {[winfo reqwidth $_wb1]+[winfo reqwidth $_wb2]}]
      lappend vlist [list $i $vislen $wl]
      incr vislen $wl
    }
    incr i
  }
  if {$iw1==-1} return  ;# for sure
  if {[my $TID Tab_Cmd -cmov] ni {"1" "yes" "true"}} return ;# chosen to not move
  set vislen2 [expr {$vislen0+$x-$movx1}]
  foreach vl $vlist {
    lassign $vl i vislen wl
    set rightest [expr {$i==$tright && $vislen2>(10+$vislen)}]
    if {$iw1==($i+1) && $x<0} {incr vislen2 $wl}
    if {($vislen>$vislen2 || $rightest)} {
      set tabs [lreplace $tabs $iw1 $iw1]
      set i [expr {$rightest||$iw1>$i?$i:$i-1}]
      if {$rightest && $i<($llen-1) && $i==$iw1} {incr i}
      set tabs [linsert $tabs $i $tab1]
      set left yes
      if {$rightest} {
        set left no
        set tleft $i
      } elseif {$i<$tleft} {
        set tleft $i
      }
      break
    }
  }
  if {$tabssav ne $tabs} {
    my $BID configure -TABS $tabs
    my $BID Refill $tleft $left
    my $BID Bar_Cmd2 -cmov2 $TID ;# command after the action
  }
}
#_______________________

method OnCtrlClick {} {
# Handles a selection of tabs with Ctrl+click.

  lassign [my IDs [my ID]] TID BID
  lassign [my $BID cget -static -select] static fewsel
  if {$static} return
  if {[set i [lsearch $fewsel $TID]]>-1} {
    set fewsel [lreplace $fewsel $i $i]
  } else {
    lappend fewsel $TID
  }
  my $BID configure -select $fewsel
  my Tab_MarkBar $BID
  my $BID Bar_Cmd2 -csel3 $TID ;# command after the action
}
#_______________________

method OnPopup {X Y {BID "-1"} {TID "-1"} {textcur ""}} {
# Handles the mouse right-clicking on a tab.
#   X, Y - positions of the mouse pointer

  if {$BID eq "-1"} {
    lassign [my IDs [my ID]] TID BID
    set textcur [my $TID cget -text]
  }
  lassign [my $BID cget -wbar -menu -USERMNU -UMNU -TABS -static -hidearrows -WWID] \
    wbar popup usermnu popup0 tabs static hidearr wwid
  if {$static && $hidearr && !$usermnu} {
    lassign $wwid wframe wlarr wrarr
    if {[catch {pack info $wlarr}] && [catch {pack info $wrarr}]} {
      return ;# static absolutely
    }
  }
  set pop $wbar.popupMenu
  if {[winfo exist $pop]} {destroy $pop}
  my $BID configure -LOCKDRAW 1
  menu $pop -tearoff 0
  set ipops [set lpops [list]]
  if {$TID eq "-1"} {
    set popup [list [lindex $popup 0] s {*}$popup0]  ;# let "List" be in
  }
  foreach p $popup {
    lassign $p typ label comm menu dsbl tip var
    if {$menu ne {}} {set popc $pop.$menu} {set popc $pop}
    foreach opt {label comm menu dsbl} {
      set $opt [string map [list %b $BID %t $TID %l $textcur] [set $opt]]
    }
    if {[info commands [lindex $dsbl 0]] ne {}} {
      ;# 0/1/2 image label hotkey
      lassign [{*}$dsbl $BID $TID $label] dsbl comimg comlabel hotk
    } else {
      lassign $dsbl dsbl comimg comlabel hotk
      if {$dsbl ne {}} {set dsbl [expr $dsbl]}
      set dsbl [expr {([string is boolean $dsbl] && $dsbl ne {})?$dsbl:0}]
    }
    if {$dsbl eq {2}} continue  ;# 2 - "hide"; 1 - "disable"; 0 - "normal"
    if {$dsbl} {set dsbl {-state disabled}} {set dsbl {}}
    if {$comimg ne {}} {set comimg "-image $comimg"}
    if {$comlabel ne {}} {set label $comlabel}
    if {$comimg eq {}} {set comimg {-image bts_ImgNone}}
    if {$hotk ne {}} {set hotk "-accelerator $hotk"}
    switch [string index $typ 0] {
      s {$popc add separator}
      c {
        switch [string index $typ 1] {
          o - {} { ;# command
            $popc add command -label $label -command $comm \
              {*}$dsbl -compound left {*}$comimg {*}$hotk
          }
          h { ;# checkbutton
            if {$comm ne {}} {set comm [list -command $comm]}
            $popc add checkbutton -label $label {*}$comm -variable $var
          }
        }
      }
      m {
        if {$menu eq {bartabs_cascade} && !$usermnu && $static} {
          set popc $pop  ;# no user mnu & static: only list of tabs be shown
        } else {
          if {[winfo exist $popc]} {destroy $popc}
          menu $popc -tearoff 0
          set popm [string range $popc 0 [string last . $popc]-1]
          $popm add cascade -label $label -menu $popc \
            {*}$dsbl -compound left {*}$comimg {*}$hotk
        }
        if {[string match {bartabs_cascade*} $menu]} {
          set popi $popc
          lappend lpops $popi
          set ipops [my $BID FillMenuList $BID $popi $TID $menu]
        }
      }
    }
    if {$tip ne {}} {
      catch {baltip::tip $popc $tip -index [$popc index end]}
    }
  }
  if {[llength $lpops]} {
    catch {::apave::obj themePopup $pop}
    my Bar_MenuList $BID $TID $pop ;# main menu
    foreach popi $lpops {my Bar_MenuList $BID $TID $popi $ipops}
    if {$TID ne {-1}} {
      lassign [my $TID cget -wb1 -wb2] wb1 wb2
      bind $pop <Unmap> [list [self] $TID OnLeaveTab $wb1 $wb2]
    }
    my $BID DestroyMoveWindow
    tk_popup $pop $X $Y
  } else {
    my $BID popList $X $Y
  }
  my $BID configure -LOCKDRAW {}
}

## ____________ Public methods of Tab ____________ ##

method show {{refill no} {lifo yes}} {
# Shows a tab in a bar and sets it current.
#   refill - if "yes", update the bar
#   lifo - if "yes", allows moving a tab to 0th position
# When refill=no and lifo=no, just shows a tab in its current position.

  lassign [my IDs [my ID]] TID BID
  if {$refill} {my $BID clear}
  set itab 0
  foreach tab [my $BID listTab]  {
    lassign $tab tID text wb wb1 wb2 pf
    if {$TID eq $tID} {
      set refill [expr {$pf eq {}}]  ;# check if visible
      break
    }
    incr itab
  }
  if {$refill && $lifo && [my $BID cget -lifo] && (![my $TID visible] || \
  [string is true -strict [my $BID cget -lifoest]])} {
    my $BID moveTab $TID 0
    set itab 0
  }
  if {$refill} {my $BID Refill $itab no yes}
  my $TID Tab_BeCurrent
}
#_______________________

method close {{redraw yes} args} {
# Closes a tab and updates the bar.
#   redraw - if "yes", update the bar and select the new tab
#   args - additional argumens of the -cdel command
# Returns "1" if the deletion was successful, otherwise 0 (no) or -1 (cancel).

  lassign [my Tab_BID [set TID [my ID]]] BID icurr
  if {[my Disabled $TID]} {
    set ttl [msgcat::mc Closing]
    set t [my $TID cget -text]
    set msg [msgcat::mc "Can't close the disabled\n\"%t\"\n\nClose others?"]
    set msg [string map [list %t $t] $msg]
    return [expr {[::bartabs::messageBox yesno $ttl $msg -icon question]==1}]
  }
  set cdel [my $BID cget -cdel]
  if {$cdel eq {}} {
    set res 1
  } else {
    set cdel [my PrepareCmd $TID $BID -cdel {*}$args]
    if {[catch {set res [{*}$cdel]}]} {
      set res [my $TID Tab_Cmd -cdel {*}$args]
    }
  }
  if {$res ni {1 yes true}} {return $res}
  if {$redraw} {my $BID clear}
  lassign [my $BID cget -TABS -tleft -tright -tabcurrent] tabs tleft tright tcurr
  my Tab_RemoveLinks $BID $TID
  destroy [my $TID cget -wb]
  set tabs [lreplace $tabs $icurr $icurr]
  my $BID configure -TABS $tabs
  if {$redraw} {
    if {$icurr>=$tleft && $icurr<[llength $tabs]} {
      my $BID draw
      my [lindex $tabs $icurr 0] Tab_BeCurrent
    } else {
      if {[set TID [lindex $tabs end 0]] ne {}} {
        my $TID show yes ;# last tab deleted: show the new last if any
      }
    }
  }
  my $BID Bar_Cmd2 -cdel2  ;# command after the action
  return 1
}
#_______________________

method visible {} {
# Checks if a tab is visible.
# Returns yes if the tab is visible,.

  lassign [my IDs [my ID]] TID BID
  lassign [my $BID cget -tleft -tright] tleft tright
  set tabs [my $BID listTab]
  for {set i $tleft} {$i<=$tright} {incr i} {
    if {$TID eq [lindex $tabs $i 0]} {
      return yes
    }
  }
  return no
}

## ________________________ EOC Tab _________________________ ##

}

# ________________________ Bar _________________________ #

## ____________ Private methods of Bar ____________ ##

oo::define bartabs::Bar {

method Bar_Data {barOptions} {
# Puts data of new bar in btData.
#   barOptions - new bar's options
# Returns BID of new bar.

  variable btData
  set BID bar[incr bartabs::NewBarID]
  # defaults:
  set barOpts [dict create -wbar {}  -wbase {} -wproc {} -static no -lowlist no \
    -hidearrows no -scrollsel yes -lablen 0 -tiplen 0 -tleft 0 -tright end \
    -disable [list] -select [list] -mark [list] -fgmark #800080  -fgsel "." \
    -relief groove -padx 1 -pady 1 -expand 0 -tabcurrent -1 -dotip no \
    -bd 0 -separator 1 -lifo 0 -fg {} -bg {} -popuptip {} -sortlist 0 -comlist {} \
    -ELLIPSE "\u2026" -MOVWIN {.bt_move} -ARRLEN 0 -USERMNU 0 -LLEN 0 -title Tabs]
  set tabinfo [set imagetabs [set popup [list]]]
  my Bar_DefaultMenu $BID popup
  foreach {optnam optval} $barOptions {
    switch -exact -- $optnam {
      -tab - -imagetab {
        if {$optnam eq "-imagetab"} {lassign $optval optval img}
        # no duplicates allowed:
        if {[lsearch -index {1 1} -exact $tabinfo $optval]==-1} {
          lappend tabinfo [set tab [my Tab_Data $BID $optval]]
          dict set barOpts -TABS $tabinfo
          dict set barOpts -LLEN [llength $tabinfo]
          if {$optnam eq "-imagetab"} {
            lappend imagetabs [list [lindex $tab 0] $img]
            dict set barOpts -IMAGETABS $imagetabs
          }
        }
      }
      -menu {
        lappend popup {*}$optval
        dict set barOpts -menu $popup
        dict set barOpts -USERMNU 1
        lappend mnu {*}$optval
        if {[string index [lindex $mnu 0] 0] eq "s"} {set mnu [lrange $mnu 1 end]}
        dict set barOpts -UMNU $mnu
      }
      default {
        dict set barOpts $optnam $optval
      }
    }
  }
  set wbar [dict get $barOpts -wbar]
  if {$wbar eq {}} {return -code error {bartabs: -wbar option is obligatory}}
  set wbase [dict get $barOpts -wbase]
  set wproc [dict get $barOpts -wproc]
  foreach o {-tleft -tright} {
    set v [dict get $barOpts $o]
    set v [expr [string map [list end [llength $tabinfo]-1] $v]]
    dict set barOpts $o $v
  }
  if {$wbase ne {} && $wproc eq {}} {
    dict set barOpts -wproc "expr {\[winfo width $wbase\]-80}" ;# 80 for ornithology
  }
  dict set btData $BID $barOpts
  return $BID
}
#_______________________

method Bar_DefaultMenu {BID popName} {
# Creates default menu items.
#   popName - variable name for popup's data

  upvar 1 $popName pop
  set bar "[self] $BID"
  set dsbl "{$bar CheckDsblPopup}"
  lassign [my Mc_MenuItems] list behind close closeall closeleft closeright
  foreach item [list \
  "m {$list} {} bartabs_cascade" \
  "s {} {} {} $dsbl" \
  "m {BHND} {} bartabs_cascade2 $dsbl" \
  "s {} {} {} $dsbl" \
  "c {$close} {[self] %t close yes -first -1} {} $dsbl" \
  "c {$closeall} {$bar closeAll $BID -1 1} {} $dsbl" \
  "c {$closeleft} {$bar closeAll $BID %t 2} {} $dsbl" \
  "c {$closeright} {$bar closeAll $BID %t 3} {} $dsbl"] {
    lappend pop $item
  }
}
#_______________________

method Bar_MenuList {BID TID popi {ilist ""} {pop ""}} {
# Tunes "List" menu item for colors & underlining.
#   popi - menu of tab items
#   ilist - list of "s" (separators) and TIDs
#   pop - menu to be themed in apave package

  if {$pop eq {}} {set pop $popi}
  catch {::apave::obj themePopup $pop}
  lassign [my $BID cget -tabcurrent -select -FGOVER -BGOVER -lowlist] \
    tabcurr fewsel fgo bgo ll
  if {$ll || [catch {set fs "-size [dict get [$pop cget -font] -size]"}]} {
    if {$ll && [string is digit $ll] && $ll>1} {
      set fs "-size $ll"
    } else {
      set fs {}
    }
  }
  # ALERT: "font actual TkDefaultFont" may be wasteful with tclkits
  set font [list -font "[font actual TkDefaultFont] $fs"]
  set llen [llength $ilist]
  if {[$popi cget -tearoff]} {
    set ito 1
    set TID $tabcurr
  } else {
    set ito 0
  }
  for {set i 0} {$i<$llen} {incr i} {
    if {[set tID [lindex $ilist $i]] eq {s}} continue
    set opts [my Tab_MarkAttrs $BID $tID no]
    if {"-image" ni $opts} {append opts " -image bts_ImgNone"}
    append opts " -compound left"
    if {$tID==$tabcurr || [lsearch $fewsel $tID]>-1} {
      set font2 [my Tab_SelAttrs $font {} {}]
    } else {
      set font2 $font
    }
    append opts " $font2"
    if {$tID==$TID} {append opts " -foreground $fgo -background $bgo"}
    if {[string match *bartabs_cascade2 $popi] && [my Disabled $tID]} {
      append opts " -foreground [my $BID cget -FGMAIN]"  ;# move behind any
    }
    catch {$popi entryconfigure [expr {$i+$ito}] {*}$opts}
  }
}
#_______________________

method Bar_Cmd2 {comopt2 {TID ""}} {
# Executes a command after an action.
#   comopt2 - the command's option (-csel2, -cdel2, -cmov2)

  set BID [my ID]
  if {[set com2 [my $BID cget $comopt2]] ne {}} {
    {*}[string map [list %t $TID] $com2]
  }
}
#_______________________

method Mc_MenuItems {} {
  # Returns localized menu items' label.

  namespace eval ::bartabs {
    return [list [msgcat::mc List] \
                 [msgcat::mc behind] \
                 [msgcat::mc Close] \
                 [msgcat::mc {... All}] \
                 [msgcat::mc {... All at Left}] \
                 [msgcat::mc {... All at Right}]]
  }
}
#_______________________

method InitColors {} {
# Initializes colors of a bar.

  set BID [my ID]
  if {[set fgmain [my $BID cget -fg]] eq {}} {
    set fgmain [ttk::style configure . -foreground]
  }
  if {[set bgmain [my $BID cget -bg]] eq {}} {
    set bgmain [ttk::style configure . -background]
  }
  if {[catch {set fgdsbl [dict get [ttk::style map . -foreground] disabled]}]} {
    set fgdsbl $fgmain
  }
  if {[catch {set bgdsbl [dict get [ttk::style map . -background] disabled]}]} {
    set bgdsbl $bgmain
  }
  if {[catch { \

    set fgo [ttk::style map TButton -foreground]
    if {[dict exists $fgo active]} {
      set fgo [dict get $fgo active]
    } else {
      set fgo $fgmain
    }
    set bgo [ttk::style map TButton -background]
    if {[dict exists $bgo active]} {
      set bgo [dict get $bgo active]
    } else {
      set bgo $bgmain
    }
  }]} {
    set bgo $fgmain  ;# reversed
    set fgo $bgmain
    if {$bgo in {black #000000}} {set bgo #444444; set fgo #FFFFFF}
  }
  my $BID configure -FGMAIN $fgmain -BGMAIN $bgmain \
    -FGDSBL $fgdsbl -BGDSBL $bgdsbl -FGOVER $fgo -BGOVER $bgo
  my $BID Style
}
#_______________________

method Style {} {
# Sets styles a bar's widgets.

  set BID [my ID]
  set bg [my $BID cget -BGMAIN]
  ttk::style configure ClButton$BID {*}[ttk::style configure TButton]
  ttk::style configure ClButton$BID -relief flat -padx 0 -bd 0 -highlightthickness 0
  ttk::style map ClButton$BID {*}[ttk::style map TButton]
  ttk::style map ClButton$BID -background [list active $bg !active $bg]
  ttk::style layout ClButton$BID [ttk::style layout TButton]
}
#_______________________

method ScrollCurr {dir} {
# Scrolls the current tab to the left/right.
#   dir - 1/-1 for scrolling to the right/left

  lassign [my [set BID [my ID]] cget -scrollsel -tabcurrent] sccur tcurr
  if {!$sccur || $tcurr eq {}} {return no}
  set tabs [my $BID listFlag]
  if {[set i [my Aux_IndexInList $tcurr $tabs]]==-1} {return no}
  incr i $dir
  set TID [lindex $tabs $i 0]
  if {[lindex $tabs $i 2] eq "1" && ![my Disabled $TID]} {
    my $TID Tab_BeCurrent  ;# TID visible & enabled
    return yes
  }
  return no
}
#_______________________

method ArrowsState {tleft tright sright} {
# Sets a state of scrolling arrows.
#   tleft, tright - index of left/right tab
#   sright - state of a right arrow ("no" for disabled)

  lassign [my [set BID [my ID]] cget -WWID -hidearrows -tiplen] wwid hidearr tiplen
  lassign $wwid wframe wlarr wrarr
  set tabs [my $BID listTab]
  if {$tleft} {
    if {$hidearr && [catch {pack $wlarr -before $wframe -side left}]} {
      pack $wlarr -side left
    }
    set state normal
  } else {
    if {$hidearr} {
      set state normal
      pack forget $wlarr
    } else {
      catch {pack $wlarr -before $wframe -side left}
      set state disabled
    }
  }
  $wlarr configure -state $state
  set tip {}
  if {$state eq {normal} && $tiplen>=0} {
    for {set i [expr {$tleft-1}]} {$i>=0} {incr i -1} {
      if {$tiplen && [incr cntl]>$tiplen} {
        append tip "..."
        break
      }
      set text [lindex [my Tab_TextEllipsed $BID [lindex $tabs $i 1]] 0]
      append tip "$text\n"
    }
  }
  catch {::baltip::tip $wlarr [string trim $tip]}
  if {$sright} {
    if {$hidearr && [catch {pack $wrarr -after $wframe -side right -anchor e}]} {
      pack $wrarr -side right -anchor e
    }
    set state normal
  } else {
    if {$hidearr} {
      set state normal
      pack forget $wrarr
    } else {
      catch {pack $wrarr -after $wframe -side right -anchor e}
      set state disabled
    }
  }
  $wrarr configure -state $state
  set tip {}
  if {$state eq {normal} && $tiplen>=0} {
    for {set i [expr {$tright+1}]} {$i<[llength $tabs]} {incr i} {
      if {$tiplen && [incr cntr]>$tiplen} {
        append tip ...
        break
      }
      set text [lindex [my Tab_TextEllipsed $BID [lindex $tabs $i 1]] 0]
      append tip "$text\n"
    }
  }
  catch {::baltip::tip $wrarr [string trim $tip]}
}
#_______________________

method FillMenuList {BID popi {TID -1} {mnu ""} {mustBeSorted {}}} {
# Fills "List of tabs" item of popup menu.
#   popi - menu of tab items
#   TID - clicked tab ID
#   mnu - root menu
#   mustBeSorted - flag "sorted list"
# Return a list of items types: s (separator) and TID.

  lassign [my $BID cget -tiplen -popuptip -sortlist -comlist] tiplen popuptip sortlist comlist
  set vis [set seps 0] ;# flags for separators: before/after visible items
  set idx [set icom -1]
  set res [list]
  set tabs [my [set BID [my ID]] listFlag]
  if {$mustBeSorted ne {}} {set sortlist $mustBeSorted}
  if {$sortlist} {
    set tabs [lsort -index 1 -dictionary $tabs]
  }
  foreach tab $tabs {
    incr icom
    lassign $tab tID text vsbl
    if {!$sortlist} {
      if {$vsbl && !$seps || !$vsbl && $vis} {
        incr idx
        $popi add separator
        lappend res s
        incr seps
        set vis 0
      } elseif {$vsbl} {
        set vis 1
      }
      if {!$seps && $vis} { ;# no invisible at left
        incr idx
        $popi add separator
        lappend res s
        incr seps
      }
    }
    set dsbl {}
    if {$TID == -1 || $mnu eq {bartabs_cascade}} {
      if {$comlist eq {}} {
        set comm "[self] $tID show yes"
      } else {
        set tip [my $tID cget -tip]
        set comm [string map [list %i $icom %t $tip] $comlist]
      }
      if {[my Disabled $tID]} {set dsbl {-state disabled}}
    } else {
      set comm "[self] moveSelTab $TID $tID"
    }
    if {[set cbr [expr {$tiplen>0 && [incr ccnt]>$tiplen}]]} {set ccnt 0}
    incr idx
    if {$popuptip ne {}} {
      # make a tip for menu items
      $popuptip $popi $idx $tID
    }
    $popi add command -label $text -command $comm {*}$dsbl -columnbreak $cbr
    lappend res $tID
  }
  if {$seps<2 && !$sortlist} { ;# no invisible at right
    $popi add separator
    lappend res s
  }
  return $res
}
#_______________________

method Width {} {
# Calculates and returns the bar width to place tabs.

  lassign [my [set BID [my ID]] cget \
    -tleft -tright -LLEN -wbase -wbar -ARRLEN -hidearrows -WWID -BWIDTH -wproc] \
    tleft tright llen wbase wb arrlen hidearrows wwid bwidth1 wproc
  set iarr 2
  if {$hidearrows} {  ;# how many arrows are visible?
    if {!$tleft} {incr iarr -1}
    if {$tright==($llen-1)} {incr iarr -1}
  }
  set minus2len [expr {-$iarr*$arrlen}]
  set bwidth2 0
  if {$wproc ne {}} {
    set bwidth2 [{*}[string map [list %b $BID] $wproc]]
  }
  if {$bwidth2<2 && [set wbase_exist [winfo exists $wbase]]} {
    # 'wbase' is a base widget to get the bartabs' width from
    set bwidth2 [my Aux_WidgetWidth $wbase]
  }
  incr bwidth2 $minus2len
  set wbase_exist [expr {$bwidth2>1}]
  if {$wbase_exist} {
    set bwidth $bwidth2
  } else {
    if {$bwidth1 eq {} || $bwidth1<=1} {set bwidth1 100}
    set bwidth [expr {$wbase_exist ? min($bwidth1,$bwidth2) : $bwidth1}]
  }
  if {[set winw [winfo width .]]<2} {set winw [winfo reqwidth .]}
  incr winw $minus2len
  if {$bwidth<=0} { ;# last refuge
    set bwidth [expr {max($winw,[winfo reqwidth $wb],[winfo width $wb])}]
  } elseif {$wbase eq {} && $bwidth1 && $winw>1 && $bwidth1>$winw} {
    set bwidth $winw
  }
  return $bwidth
}
#_______________________

method FillFromLeft {{ileft ""} {tright "end"}} {
# Fills a bar with tabs from the left to the right (as much tabs as possible).
#   ileft - index of a left tab
#   tright - index of a right tab

  lassign [my Aux_InitDraw [set BID [my ID]]] bwidth vislen bd arrlen llen tleft hidearr tabs wframe
  if {$ileft ne {}} {set tleft $ileft}
  for {set i $tleft} {$i<$llen} {incr i} {
    lassign [my Tab_DictItem [lindex $tabs $i]] TID text wb wb1 wb2 pf
    lassign [my Tab_Create $BID $TID $wframe $text] wb wb1 wb2
    if {[my Aux_CheckTabVisible $wb $wb1 $wb2 $i $tleft tright vislen \
    $llen $hidearr $arrlen $bd $bwidth tabs $TID $text]} {
      my Tab_Pack $BID $TID $wb $wb1 $wb2
    }
  }
  my Aux_EndDraw $BID $tleft $tright $llen
}
#_______________________

method FillFromRight {tleft tright behind} {
# Fills a bar with tabs from the right to the left (as much tabs as possible).
#   tleft, tright - index of left/right tab
#   behind - flag "go behind the right tab"

  set llen [my [set BID [my ID]] cget -LLEN]
  if {$tright eq "end" || $tright>=$llen} {set tright [expr {$llen-1}]}
  my $BID configure -tleft $tright -tright $tright
  lassign [my Aux_InitDraw $BID] bwidth vislen bd arrlen llen tleft hidearr tabs wframe
  set totlen 0
  for {set i $tright} {$i>=0} {incr i -1} {
    lassign [my Tab_DictItem [lindex $tabs $i]] TID text wb wb1 wb2 pf
    lassign [my Tab_Create $BID $TID $wframe $text] wb wb1 wb2
    incr vislen [set wlen [my $TID cget -width]]
    if {$i<$tright && ($vislen+($tright<($llen-1)||!$hidearr?$arrlen:0))>$bwidth} {
      set pf {}
    } else {
      set tleft $i
      set pf p
      incr totlen $wlen
    }
    set tabs [lreplace $tabs $i $i [my Tab_ItemDict $TID $text $wb $wb1 $wb2 $pf]]
  }
  set i $tright
  while {$behind && [incr i]<$llen && $totlen<$bwidth} {
    # go behind the right tab as far as possible
    lassign [my Tab_DictItem [lindex $tabs $i]] TID text wb wb1 wb2 pf
    lassign [my Tab_Create $BID $TID $wframe $text] wb wb1 wb2
    incr totlen [my $TID cget -width]
    if {($totlen+($i<($llen-1)||!$hidearr?$arrlen:0))>$bwidth} {
      set pf {}
    } else {
      set tright $i
      set pf p
    }
    set tabs [lreplace $tabs $i $i [my Tab_ItemDict $TID $text $wb $wb1 $wb2 $pf]]
  }
  for {set i $tleft} {$i<$llen} {incr i} {
    lassign [my Tab_DictItem [lindex $tabs $i]] TID text wb wb1 wb2 pf
    if {[my Tab_Is $wb] && $pf ne {}} {my Tab_Pack $BID $TID $wb $wb1 $wb2}
  }
  my Aux_EndDraw $BID $tleft $tright $llen
}
#_______________________

method Locked {BID} {
# Checks for "draw locked" mode: protects the menu.

  return [expr {[my $BID cget -LOCKDRAW] ne {}}]
}
#_______________________

method Refill {itab left {behind false}} {
# Fills a bar with tabs.
#   itab - index of tab
#   left - if "yes", fill from left to right
#   behind - flag "go behind the right tab"

  if {[my Locked [set BID [my ID]]]} return
  my $BID clear
  if {$itab eq "end" || $itab==([my $BID cget -LLEN]-1)} {set left 0}
  if {$left} {
    my $BID FillFromLeft $itab
  } else {
    my $BID FillFromRight 0 $itab $behind
  }
}
#_______________________

method CheckDsblPopup {BID TID mnuit} {
# Controls disabling of Close* menu items.
#   mnuit - menu label
# Returns "yes" for disabled menu item

  lassign [my Tab_BID $TID] BID icur
  lassign [my $BID cget -static -LLEN] static llen
  set dsbl [my Disabled $TID]
  lassign [my Mc_MenuItems] list behind close closeall closeleft closeright
  switch -exact -- $mnuit [list \
    BHND {
      if {$static} {return 2}
      if {[set slen [llength [my $BID listFlag "s"]]]>1} {
        set mnuit [string map [list %n $slen] [msgcat::mc "%n tabs"]]
      } else {
        lassign [my Tab_TextEllipsed $BID [my $TID cget -text] 16] mnuit
        set mnuit "\"$mnuit\""
      }
      return [list [expr {$dsbl||$llen<2||$llen==2&&$icur==1}] {} "$mnuit $behind"]
    } \
    $close - $closeall - {} {
      if {$static} {return 2}
    } \
    $closeleft {
      if {$static} {return 2}
      return [expr {$dsbl || !$icur}]
    } \
    $closeright {
      if {$static} {return 2}
      return [expr {$dsbl || $icur==($llen-1)}]
    } \
  ]
  return $dsbl
}
#_______________________

method NeedDraw {} {
# Redraws a bar at need.

  set BID [my ID]
  lassign [my $BID cget -wproc -BWIDTH -ARRLEN] wproc bwo arrlen
  set bw [{*}[string map [list %b $BID] $wproc]]
  if {$bwo eq {} || [set need [expr {abs($bwo-$bw)>$arrlen} && $bw>10]]} {
    my $BID configure -BWIDTH $bw
  }
  if {$bwo ne {} && $need} {
    catch {after cancel $::bartabs::NewAfterID($BID)}
    set ::bartabs::NewAfterID($BID) [after 10 [list [self] $BID draw]]
  }
}

## ____________ Exported methods of Bar ____________ ##

method _runBound_ {w ev args} {
# Runs a method bound to an event occuring at a widget.
#   w - widget
#   ev - event
#   args - the bound method & its arguments

  if {[catch {my {*}$args}]} { ;# failed binding => remove it
    foreach b [split [bind $w $ev] \n] {
      if {[string first $args $b]==-1} {
        if {[incr is1]==1} {bind $w $ev $b} {my bindToEvent $w $ev $b}
      }
    }
  }
}

export _runBound_

## ____________ Auxiliary methods of Bar ____________ ##

method Aux_WidgetWidth {w} {
# Calculates a widget's width.

  if {![winfo exists $w]} {return 0}
  set wwidth [winfo width $w]
  if {$wwidth<2} {set wwidth [winfo reqwidth $w]}
  return $wwidth
}
#_______________________

method Aux_InitDraw {BID {clearpf yes}} {
# Auxiliary method used before cycles drawing tabs.

  my $BID InitColors
  lassign [my $BID cget \
    -tleft -hidearrows -LLEN -WWID -bd -wbase -wbar -ARRLEN -wproc] \
    tleft hidearr llen wwid bd wbase wbar arrlen wproc
  lassign $wwid wframe wlarr
  if {$arrlen eq {}} {
    set arrlen [winfo reqwidth $wlarr]
    my $BID configure -wbase $wbase -ARRLEN $arrlen
  }
  set bwidth [my $BID Width]
  set vislen [expr {$tleft || !$hidearr ? $arrlen : 0}]
  set tabs [my $BID cget -TABS]
  if {$clearpf} {foreach tab $tabs {my [lindex $tab 0] configure -pf {}}}
  return [list $bwidth $vislen $bd $arrlen $llen $tleft $hidearr $tabs $wframe]
}
#_______________________

method Aux_CheckTabVisible {wb wb1 wb2 i tleft trightN vislenN llen hidearr arrlen bd bwidth tabsN TID text} {
# Auxiliary method used to check if a tab is visible.

  upvar 1 $trightN tright $tabsN tabs $vislenN vislen
  incr vislen [my $TID cget -width]
  if {$i>$tleft && ($vislen+(($i+1)<$llen||!$hidearr?$arrlen:0))>$bwidth} {
    pack forget $wb
    set pf {}
  } else {
    set tright $i
    set pf p
  }
  my $TID configure -wb $wb -wb1 $wb1 -wb2 $wb2 -pf $pf
  return [string length $pf]
}
#_______________________

method Aux_EndDraw {BID tleft tright llen} {
# Auxiliary method used after cycles drawing tabs.

  my $BID ArrowsState $tleft $tright [expr {$tright < ($llen-1)}]
  my $BID configure -tleft $tleft -tright $tright
  my Tab_Bindings $BID
  my Tab_MarkBar $BID
}
#_______________________

method Aux_IndexInList {ID lst} {
# Searches ID in list.

  set i 0
  foreach it $lst {
    if {[lindex $it 0]==$ID} {return $i}
    incr i
  }
  return -1
}

## ____________ Public methods of Bar ____________ ##

method cget {args} {
# Gets values of options of bars & tabs.
#   args - list of options, e.g. {-tabcurrent -MyOpt}
# Return a list of values or one value if args is one option.

  set BID [my ID]
  variable btData
  set res [list]
  set llen [dict get $btData $BID -LLEN]
  foreach opt $args {
    if {$opt eq "-listlen"} {
      lappend res $llen
    } elseif {$opt eq "-width"} {
      lassign [dict get [dict get $btData $BID] -wbar] wbar
      lappend res [my Aux_WidgetWidth $wbar]
    } elseif {[dict exists $btData $BID $opt] && ($llen || $opt ne "-tabcurrent")} {
      lappend res [dict get $btData $BID $opt]
    } else {
      lappend res {}
    }
  }
  if {[llength $args]==1} {return [lindex $res 0]}
  return $res
}
#_______________________

method configure {args} {
# Sets values of options for bars & tabs.
#   args - list of pairs "option value"

  set BID [my ID]
  variable btData
  foreach {opt val} $args {
    dict set btData $BID $opt $val
    if {$opt eq "-TABS"} {dict set btData $BID -LLEN [llength $val]}
  }
  if {[dict exists $args -static]} {my $BID Style}
}
#_______________________

method draw {{upd yes}} {
# Draws the bar tabs at slight changes.
#   upd - if "yes", run "update" before redrawing

  if {[my Locked [set BID [my ID]]]} return
  if {$upd} update
  lassign [my Aux_InitDraw $BID] bwidth vislen bd arrlen llen tleft hidearr tabs wframe
  set tright [expr {$llen-1}]
  for {set i $tleft} {$i<$llen} {incr i} {
    lassign [my Tab_DictItem [lindex $tabs $i]] TID text wb wb1 wb2 pf
    lassign [my Tab_Create $BID $TID $wframe $text] wb wb1 wb2
    if {[my Aux_CheckTabVisible $wb $wb1 $wb2 $i $tleft tright vislen $llen $hidearr $arrlen $bd $bwidth tabs $TID $text]} {
      my Tab_Pack $BID $TID $wb $wb1 $wb2
    }
  }
  my Aux_EndDraw $BID $tleft $tright $llen
  my Tab_MarkBar $BID
}
#_______________________

method update {} {
# Updates the bar in hard way.

  if {[my Locked [set BID [my ID]]]} return
  update
  my $BID Refill 0 yes
}
#_______________________

method clear {} {
# Forgets (hides) the shown tabs.

  if {[my Locked [set BID [my ID]]]} return
  set wlist []
  foreach tab [my $BID listTab] {
    lassign $tab TID text wb wb1 wb2 pf
    if {[my Tab_Is $wb] && $pf ne {}} {
      lappend wlist $wb
      my $TID configure -pf {}
    }
  }
  if {[llength $wlist]} {pack forget {*}$wlist}
}
#_______________________

method scrollLeft {} {
  # Scrolls tabs to the left.

  set BID [my ID]
  lassign [my $BID cget -wbar -dotip] w dotip
  set wlarr $w.larr   ;# left arrow
  if {[my $BID ScrollCurr -1]} {
    if {$dotip} {catch {::baltip::repaint $wlarr}}
    return
  }
  lassign [my $BID cget -tleft -LLEN -scrollsel] tleft llen sccur
  if {![string is integer -strict $tleft]} {set tleft 0}
  if {$tleft && $tleft<$llen} {
    incr tleft -1
    set tID [lindex [my $BID listTab] $tleft 0]
    my $BID configure -tleft $tleft
    my $BID Refill $tleft yes
    if {$sccur} {my $tID Tab_BeCurrent}
    if {$dotip} {catch {::baltip::repaint $wlarr}}
  }
}
#_______________________

method scrollRight {} {
  # Scrolls tabs to the right.

  set BID [my ID]
  lassign [my $BID cget -wbar -dotip] w dotip
  set wrarr $w.rarr   ;# left arrow
  if {[my $BID ScrollCurr 1]} {
    if {$dotip} {catch {::baltip::repaint $wrarr}}
    return
  }
  lassign [my $BID cget -tright -LLEN -scrollsel] tright llen sccur
  if {![string is integer -strict $tright]} {set tright [expr {$llen-2}]}
  if {$tright<($llen-1)} {
    incr tright
    set tID [lindex [my $BID listTab] $tright 0]
    my $BID configure -tright $tright
    my $BID Refill $tright no
    if {$sccur} {my $tID Tab_BeCurrent}
    if {$dotip} {catch {::baltip::repaint $wrarr}}
  }
}
#_______________________

method listTab {} {
# Gets a list of tabs.
# Returns a list of TID, text, wb, wb1, wb2, pf.

  set res [list]
  foreach tab [my [my ID] cget -TABS] {lappend res [my Tab_DictItem $tab]}
  return $res
}
#_______________________

method comparetext {it1 it2} {
# Compares items (by -text attribute) for sort method.
#   it1 - 1st item to compare
#   it2 - 2nd item to compare
# See also: sort

  catch {set it1 [dict get $it1 -text]}
  catch {set it2 [dict get $it2 -text]}
  return [string compare -nocase $it1 $it2]
}
#_______________________

method sort {{mode -increasing} {cmd ""}} {
# Sorts a list of tabs by the tab names.
#   mode - option of sort
#   cmd - command to compare two items

  set BID [my ID]
  lassign [my $BID cget -tabcurrent -lifo] TID lifo
  set tabs [my $BID cget -TABS]
  if {$cmd eq {}} {
    set tabs [lsort $mode -index 1 -dictionary -command "[self] comparetext" $tabs]
  } else {
    set tabs [lsort $mode -dictionary -command $cmd $tabs]
  }
  my $BID configure -TABS $tabs -lifo no
  my $TID show yes
  my $BID configure -lifo $lifo
}
#_______________________

method listFlag {{filter ""}} {
# Gets a list of TID + flags "visible", "marked", "selected", "disabled".
#   filter - "" for all or "v","m","s","d" for visible, marked, selected, disabled
# Returns a list "TID, text, visible, marked, selected, disabled" for all or a list of TID for filtered.

  set BID [my ID]
  lassign [my $BID cget -mark -disable -select -tabcurrent] mark dsbl fewsel tcurr
  set res [list]
  foreach tab [my $BID listTab] {
    lassign $tab TID text wb wb1 wb2 pf
    set visibl [expr {[my Tab_Is $wb] && $pf ne {}}]
    set marked [expr {[lsearch $mark $TID]>=0}]
    set dsbled [expr {[lsearch $dsbl $TID]>=0}]
    set select [expr {$TID == $tcurr || [lsearch $fewsel $TID]>-1}]
    if {$filter eq {}} {
      lappend res [list $TID $text $visibl $marked $select $dsbled]
    } elseif {$filter eq "v" && $visibl || $filter eq "m" && $marked || \
              $filter eq "d" && $dsbled || $filter eq "s" && $select} {
      lappend res $TID
    }
  }
  return $res
}
#_______________________

method insertTab {txt {pos "end"} {img ""}} {
# Inserts a new tab into a bar.
#   txt - tab's label
#   pos - tab's position in tab list
#   img - tab's image
# Returns TID of new tab or "".

  set tabs [my [set BID [my ID]] cget -TABS]
  set tab [my Tab_Data $BID $txt]
  if {$tab eq {}} {return {}}
  if {$pos eq {end}} {
    lappend tabs $tab
  } else {
    set tabs [linsert $tabs $pos $tab]
  }
  if {$img ne {}} {
    set imagetabs [my $BID cget -IMAGETABS]
    lappend imagetabs [list [lindex $tab 0] $img]
    my $BID configure -IMAGETABS $imagetabs
  }
  my $BID configure -TABS $tabs
  my $BID Refill $pos [expr {$pos ne "end"}]
  return [lindex $tab 0]
}
#_______________________

method tabID {txt} {
# Gets TID by tab's label.
#   txt - label
# Returns TID or -1.

  set BID [my ID]
  if {[catch {set ellipse [my $BID cget -ELLIPSE]}]} {return {}}
  if {[string first $ellipse $txt]} {
    set pattern [string map [list $ellipse "*"] $txt]
  } else {
    set pattern {}
  }
  foreach tab [my $BID listTab] {
    lassign $tab tID ttxt
    if {$txt eq $ttxt} {return $tID}
    if {$pattern ne {} && [string match $pattern $ttxt]} {return $tID}
  }
  return {}
}
#_______________________

method popList {{X ""} {Y ""} {sortedList 0}} {
# Shows a menu of tabs.
#   X - x coordinate of mouse pointer
#   Y - y coordinate of mouse pointer
#   sortedList - flag "sorted list"

  set BID [my ID]
  my $BID DestroyMoveWindow
  lassign [my $BID cget -wbar -title] wbar title
  set popi $wbar.popupList
  catch {destroy $popi}
  menu $popi -tearoff 1 -title $title
  if {[set plist [my $BID FillMenuList $BID $popi -1 {} $sortedList]] eq "s"} {
    destroy $popi
  } else {
    my Bar_MenuList $BID -1 $popi $plist
    if {$X eq {}} {lassign [winfo pointerxy .] X Y}
    tk_popup $popi $X $Y
  }
}
#_______________________

method remove {} {
# Removes a bar.
# Returns "yes" at success.

  set BID [my ID]
  variable btData
  if {[dict exists $btData $BID]} {
    catch {bind [my $BID cget -wbase] <Configure> {}}
    lassign [my $BID cget -BINDWBASE] wb bnd
    if {$wb ne {}} {bind $wb <Configure> $bnd}
    set bar [dict get $btData $BID]
    foreach tab [dict get $bar -TABS] {my Tab_RemoveLinks $BID [lindex $tab 0]}
    catch {destroy {*}[dict get $bar -WWID]}
    catch {destroy [my $BID cget -UNDERWID]}
    if {[set bc [my $BID cget -BARCOM]] ne {}} {catch {rename $bc {}}}
    foreach tc [my $BID cget -TABCOM] {catch {rename [lindex $tc 1] {}}}
    dict unset btData $BID
    return yes
  }
  return no
}
#_______________________

method moveTab {TID pos} {
  # Moves a tab to a new position in the bar.
  #   pos - the new position

  set BID [my ID]
  set tabs [my $BID cget -TABS]
  if {[set i [lsearch -index 0 $tabs $TID]]>-1} {
    set tab [lindex $tabs $i]
    set tabs [lreplace $tabs $i $i]
    my $BID configure -TABS [linsert $tabs $pos $tab]
  }
}
#_______________________

method checkDisabledMenu {BID TID func} {
# Checks whether the popup menu's items are disabled.
#   func - close function
# *func* equals to:
#   1 - for "Close All"
#   2 - for "Close All at Left"
#   3 - for "Close All at Right"
# Returns "yes" if the menu's item is disabled.

  lassign [my Mc_MenuItems] list behind close closeall closeleft closeright
  switch $func {
    1 {set item $closeall}
    2 {set item $closeleft}
    3 {set item $closeright}
    default {set item $close}
  }
  return [my CheckDsblPopup $BID $TID $item]
}
#_______________________

method closeAll {BID TID func args} {
# Closes tabs of bar.
#   func - close function
# *func* equals to:
#   1 - for "Close All"
#   2 - for "Close All at Left"
#   3 - for "Close All at Right"

  switch $func {
    1 {my $BID Tab_CloseFew -1   no {*}$args}
    2 {my $BID Tab_CloseFew $TID yes}
    3 {my $BID Tab_CloseFew $TID no}
  }
}
#_______________________

method bindToEvent {w event args} {
  # Binds an event on a widget to a command.
  #   w - the widget's path
  #   event - the event
  #   args - the command

  if {[string first $args [bind $w $event]]<0} {
    bind $w $event [list + {*}$args]
  }
}

## ____________ EOC Bar ____________ ##

}

# ________________________ Bars _________________________ #

## ____________ Methods of Bars ____________ ##

oo::define bartabs::Bars {

variable btData

constructor {args} {
  set btData [dict create]
  if {[llength [self next]]} { next {*}$args }
  oo::objdefine [self] "method tab-1 {args} {return {-1}}"
  lappend bartabs::BarsList [self]
}

destructor {
  my removeAll
  unset btData
  set i [lsearch -exact $bartabs::BarsList [self]]
  set bartabs::BarsList [lreplace $bartabs::BarsList $i $i]
  if {[llength [self next]]} next
}

## ____________ Private methods of Bars ____________ ##

method Bars_Method {mtd args} {
# Executes a method for all bars.
#   mtd - method's name
#   args - method's arguments

  foreach BID [lsort -decreasing [dict keys $btData]] {my $BID $mtd {*}$args}
}
#_______________________

method MarkTab {opt args} {
# Sets option of tab(s).
#   opt - option
#   args - list of TID

  foreach TID $args {
    if {$TID ni {{} -1}} {
      set BID [lindex [my Tab_BID $TID] 0]
      set marktabs [my $BID cget $opt]
      if {[lsearch $marktabs $TID]<0} {
        lappend marktabs $TID
        my $BID configure $opt $marktabs
      }
    }
  }
  my Tab_MarkBars
}
#_______________________

method UnmarkTab {opt args} {
# Unsets option of tab(s).
#   opt - option
#   args - list of TID

  if {![llength $args]} {my Bars_Method configure $opt [list]}
  foreach TID $args {
    if {$TID ni {{} -1}} {
      set BID [lindex [my Tab_BID $TID] 0]
      set marktabs [my $BID cget $opt]
      if {[set i [lsearch $marktabs $TID]]>=0} {
        my $BID configure $opt [lreplace $marktabs $i $i]
      }
    }
  }
  my Tab_MarkBars
}
#_______________________

method TtkTheme {} {
  # Checks if a standard ttk theme is used.

  return [expr {[ttk::style theme use] in {clam alt classic default awdark awlight}}]
}

## ____________ Public methods of Bars ____________ ##

method create {barCom {barOpts ""} {tab1 ""}} {
# Creates a bar.
#   barCom - bar command's name or barOpts
#   barOpts - list of bar's options
#   tab1 - tab to show after creating the bar
# Returns BID.

  if {[set noComm [expr {$barOpts eq {}}]]} {set barOpts $barCom}
  set w [dict get $barOpts -wbar] ;# parent window
  set wframe $w.frame ;# frame
  set wlarr $w.larr   ;# left arrow
  set wrarr $w.rarr   ;# right arrow
  lappend barOpts -WWID [list $wframe $wlarr $wrarr]
  my My [set BID [my Bar_Data $barOpts]]
  my $BID InitColors
  set bgm [my $BID cget -BGMAIN]
  if {[my TtkTheme]} {
    ttk::button $wlarr -style ClButton$BID -image bts_ImgLeft \
      -command [list [self] $BID scrollLeft] -takefocus 0
    ttk::button $wrarr -style ClButton$BID -image bts_ImgRight \
      -command [list [self] $BID scrollRight] -takefocus 0
  } else {
    button $wlarr -image bts_ImgLeft -borderwidth 0 -highlightthickness 0 \
      -command [list [self] $BID scrollLeft] -takefocus 0 -background $bgm
    button $wrarr -image bts_ImgRight -borderwidth 0 -highlightthickness 0 \
      -command [list [self] $BID scrollRight] -takefocus 0 -background $bgm
  }
  if {$bgm eq {}} {set style {}} {set style "-background $bgm"}
  frame $wframe -relief flat {*}$style
  pack $wlarr -side left -padx 0 -pady 0 -anchor e
  pack $wframe -after $wlarr -side left -padx 0 -pady 0 -fill x -expand 1
  pack $wrarr -after $wframe -side right -padx 0 -pady 0 -anchor w
  if {[my $BID cget -separator]} {
    if {![winfo exists $w.under]} {
      ttk::separator $w.under -orient horizontal
      my $BID configure -UNDERWID $w.under
    }
    pack $w.under -before $wlarr -side bottom -fill x -expand 1 -padx 0 -pady 2
  }
  foreach w {wlarr wrarr} {
    bind [set $w] <Button-3> "[self] $BID popList %X %Y"
  }
  set wbase [my $BID cget -wbase]
  if {$wbase ne {}} {
    after 1 [list \
      my $BID configure -BINDWBASE [list $wbase [bind $wbase <Configure>]] ; \
      my $BID bindToEvent $wbase <Configure> [self] _runBound_ $wbase <Configure> $BID NeedDraw]
  }
  if {!$noComm} {
  ; proc $barCom {args} "return \[[self] $BID {*}\$args\]"
    my $BID configure -BARCOM $barCom
  }
  if {$tab1 eq {}} {
    after 50 [list [self] $BID NeedDraw ; [self] $BID draw]
  } else {
    set tab1 [my $BID tabID $tab1]
    if {$tab1 ne {}} {after 100 "[self] $BID clear; [self] $BID $tab1 show yes"}
  }
  return $BID
}
#_______________________

method updateAll {} {
# Updates all bars in hard way.

  my Bars_Method Refill 0 yes
}
#_______________________

method drawAll {{upd yes}} {
# Redraws all bars.
#   upd - if "yes", run "update" before redrawing

  if {$upd} update
  my Bars_Method draw no
}
#_______________________

method removeAll {} {
# Removes all bars.

  my Bars_Method remove
}
#_______________________

method markTab {args} {
# Marks tab(s).
#   args - list of TID

  my MarkTab -mark {*}$args
}
#_______________________

method unmarkTab {args} {
# Unmarks tab(s).
#   args - list of TID or {}

  my UnmarkTab -mark {*}$args
}
#_______________________

method onSelectCmd {args} {
  # Runs a command (set by "-csel3") on a list of tabs.
  #   args - list of TID

  foreach TID $args {
    if {$TID ni {{} -1}} {
      set BID [lindex [my Tab_BID $TID] 0]
      my $BID Bar_Cmd2 -csel3 $TID ;# command after the action
    }
  }
}
#_______________________

method selectTab {args} {
# Selects tab(s).
#   args - list of TID

  my MarkTab -select {*}$args
  my onSelectCmd {*}$args
}
#_______________________

method unselectTab {args} {
# Unselects tab(s).
#   args - list of TID or {}

  my UnmarkTab -select {*}$args
  my onSelectCmd {*}$args
}
#_______________________

method enableTab {args} {
# Enables tab(s).
#   args - list of TID or {}

  my UnmarkTab -disable {*}$args
}
#_______________________

method disableTab {args} {
# Disables tab(s).
#   args - list of TID

  my MarkTab -disable {*}$args
}
#_______________________

method isTab {TID} {
# Checks if a tab exists.
#   TID - tab ID
# Returns true if the tab exists.

  return [expr {[my Tab_BID $TID check] ne {}}]
}
#_______________________

method MoveTab {TID1 TID2} {
# Changes a tab's position in bar.
#   TID1 - TID of the moved tab
#   TID2 - TID of a tab to move TID1 behind
# TID1 and TID2 must be of the same bar.

  lassign [my Tab_BID $TID1] BID1 i1
  lassign [my Tab_BID $TID2] BID2 i2
  if {$i1!=$i2 && $BID1 eq $BID2} {
    set tabs [my $BID1 cget -TABS]
    set tab [lindex $tabs $i1]
    set tabs [lreplace $tabs $i1 $i1]
    set i [expr {$i1>$i2?($i2+1):$i2}]
    my $BID1 configure -TABS [linsert $tabs $i $tab]
    my $TID1 show yes
  }
}

#_______________________

method moveSelTab {TID1 TID2} {
# Changes a tab's or selected tabs' position in bar.
#   TID1 - TID of the moved tab
#   TID2 - TID of a tab to move TID1 behind
# TID1 and TID2 must be of the same bar.

  set BID [my Tab_BID $TID1 check]
  # -lifo option prevents moving, so it has to be temporarily disabled
  set lifo [my $BID cget -lifo]
  my $BID configure -lifo no
  set seltabs [my $BID listFlag "s"]
  if {[set i [llength $seltabs]]>1} {
    for {incr i -1} {$i>=0} {incr i -1} {
      set tid [lindex $seltabs $i]
      if {$tid ne $TID2} {my MoveTab $tid $TID2}
    }
  } else {
    my MoveTab $TID1 $TID2
  }
  my $BID configure -lifo $lifo  ;# restore -lifo option
}

## ____________ EOC Bars ____________ ##

}

# ________________________________ EOF __________________________________ #
#RUNF1: ../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
#RUNF0: test.tcl
#RUNF1: ../tests/test2_pave.tcl
