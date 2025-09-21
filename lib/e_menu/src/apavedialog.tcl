###########################################################
# Name:    apavedialog.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    12/09/2021
# Brief:   Handles standard dialogs with advanced features.
# License: MIT.
###########################################################

source [file join [file dirname [info script]] apavebase.tcl]

# ________________________ apave NS _________________________ #

namespace eval ::apave {

variable querydlg {}
variable msgarray; array set msgarray [list]
set msgarray(savenot)  {Don't save}
set msgarray(savetext) {Save text}
set msgarray(saveask)  {Save changes made to the text?}
set msgarray(find)     {Find: }

proc dlgPath {}  {
  # Gets a current dialogue's path.
  # In fact, it does the same as [my dlgPath], but it can be
  # called outside of apave dialogue object (useful sometimes).

  return $::apave::querydlg
}
#_______________________

proc msgcatDialogs {} {
  # Prepares localized messages used in dialogues.

  variable msgarray
  foreach n [array names msgarray] {
    set msgarray($n) [msgcat::mc $msgarray($n)]
  }
}

## ________________________ EONS apave _________________________ ##

}

# ________________________ APaveDialog class _________________________ #

oo::class create ::apave::APaveDialog {

superclass ::apave::APaveBase

variable HLstring Winpath CheckNomore Foundstr Dlgpath Defb1 Defb2 Indexdlg

#_______________________

constructor {{win ""} args} {
  # Creates APaveDialog object.
  #   win - window's name (path)
  #   args - additional arguments

  set Winpath $win  ;# dialogs are bound to $win, default "" means .
  set Dlgpath {}    ;# current dialog's path
  set Foundstr {}   ;# current found string
  set HLstring {}   ;# current selected string

  # Actions on closing the editor
; proc exitEditor {w resExit} {
    upvar $resExit res
    set wtxt [my TexM]
    if {[my askForSave $wtxt] && [$wtxt edit modified]} {
      set pdlg [::apave::APaveDialog new $w]
      set r [$pdlg misc warn $::apave::msgarray(savetext) \
        "\n $::apave::msgarray(saveask) \n" \
        [list Save 1 $::apave::msgarray(savenot) Close Cancel 0] \
        1 -focusback [my TexM] -centerme $w]
      if {$r==1} {
        set res 1
      } elseif {$r eq "Close"} {
        set res 0
      }
      $pdlg destroy
    } else {
      set res 0
    }
    return
  }
  # end of APaveDialog constructor
  if {[llength [self next]]} { next {*}$args }
}
#_______________________

destructor {
  # Clears variables used in the object.

  if {[llength [self next]]} next
}

## ________________________ Standard dialogs _________________________ ##

#  ok               - dialog with button OK
#  okcancel         - dialog with buttons OK, Cancel
#  yesno            - dialog with buttons YES, NO
#  yesnocancel      - dialog with buttons YES, NO, CANCEL
#  retrycancel      - dialog with buttons RETRY, CANCEL
#  abortretrycancel - dialog with buttons ABORT, RETRY, CANCEL
#  misc             - dialog with miscellaneous buttons
#
# Called as:
#   dialog icon ttl msg ?defb? ?args?
#
# Mandatory arguments of dialogs:
#   icon   - icon name (info, warn, err, ques)
#   ttl    - title
#   msg    - message
# Optional arguments:
#   defb - default button (OK, YES, NO, CANCEL, RETRY, ABORT)
#   args - options for Query
#_______________________

method PrepArgs {args} {
  # Prepares a list of arguments.
  # Returns the list (wrapped in list) and a command for OK button.

  lassign [::apave::parseOptions $args -modal {} -ch {} -comOK {} -onclose {}] \
    modal ch comOK onclose
  if {[string is true -strict $modal]} {
    set com 1
  } elseif {$ch ne {}} {
    # some options are incompatible with -ch
    if {[string match *destroy* $onclose]} {set onclose {}}
    lappend args -modal 1 -onclose $onclose
    set com 1
  } elseif {$comOK eq {}} {
    set com destroy  ;# non-modal without -ch option
  } else {
    set com $comOK
  }
  list [list $args] $com
}
#_______________________

method enhanceTitle {optsName} {
  # Enhances dialog title font.
  #   optsName - variable for font options

  upvar $optsName opts
  set opts [linsert $opts 0 {*}[my basicTextFont] -hsz [expr {[my basicFontSize] + 1}]]
}
#_______________________

method ok {icon ttl msg args} {
  # Shows the *OK* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   args - options

  lassign [my PrepArgs {*}$args] args comOK
  my Query $icon $ttl $msg "ButOK OK $comOK" ButOK {} $args
}
#_______________________

method okcancel {icon ttl msg {defb OK} args} {
  # Shows the *OKCANCEL* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   defb - button to be selected
  #   args - options

  lassign [my PrepArgs {*}$args] args
  my Query $icon $ttl $msg \
    {ButOK OK 1 ButCANCEL Cancel 0} But$defb {} $args
}
#_______________________

method yesno {icon ttl msg {defb YES} args} {
  # Shows the *YESNO* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   defb - button to be selected
  #   args - options

  lassign [my PrepArgs {*}$args] args
  my Query $icon $ttl $msg \
    {ButYES Yes 1 ButNO No 0} But$defb {} $args
}
#_______________________

method yesnocancel {icon ttl msg {defb YES} args} {
  # Shows the *YESNOCANCEL* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   defb - button to be selected
  #   args - options

  lassign [my PrepArgs {*}$args] args
  my Query $icon $ttl $msg \
    {ButYES Yes 1 ButNO No 2 ButCANCEL Cancel 0} But$defb {} $args
}
#_______________________

method retrycancel {icon ttl msg {defb RETRY} args} {
  # Shows the *RETRYCANCEL* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   defb - button to be selected
  #   args - options

  lassign [my PrepArgs {*}$args] args
  my Query $icon $ttl $msg \
    {ButRETRY Retry 1 ButCANCEL Cancel 0} But$defb {} $args
}
#_______________________

method abortretrycancel {icon ttl msg {defb RETRY} args} {
  # Shows the *ABORTRETRYCANCEL* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   defb - button to be selected
  #   args - options

  lassign [my PrepArgs {*}$args] args
  my Query $icon $ttl $msg \
    {ButABORT Abort 1 ButRETRY Retry 2 ButCANCEL \
    Cancel 0} But$defb {} $args
}
#_______________________

method misc {icon ttl msg butts {defb ""} args} {
  # Shows the *MISCELLANEOUS* dialog.
  #   icon - icon
  #   ttl - title
  #   msg - message
  #   butts - list of buttons
  #   defb - button to be selected
  #   args - options
  # The *butts* is a list of pairs "title of button" "number/ID of button"

  foreach {nam num} $butts {
    set but But[namespace tail $num] ;# for "num" set as a command
    lappend apave_msc_bttns $but "$nam" $num
    if {$defb eq {}} {
      set defb $num
    }
  }
  my enhanceTitle args
  lassign [my PrepArgs {*}$args] args
  my Query $icon $ttl $msg $apave_msc_bttns But$defb {} $args
}

## ________________________ Progress for splash _________________________ ##

method progress_Begin {type wprn ttl msg1 msg2 maxvalue args} {
  # Creates and shows a progress window. Fit for splash screens.
  #   type - any word(s)
  #   wprn - parent window
  #   ttl - title message
  #   msg1 - top message
  #   msg2 - bottom message
  #   maxvalue - maximum value
  #   args - additional attributes of the progress bar
  # If type={}, widgetType method participates too in progress_Go, and also
  # progress_End puts out a little statistics.
  # See also: APaveBase::widgetType, progress_Go, progress_End

  set ::apave::_AP_VARS(win) .proSplashScreen
  set qdlg $::apave::_AP_VARS(win)
  lassign [::apave::extractOptions args -modal 0 -ontop 1] modal ontop
  set atr1 "-maximum 100 -value 0 -mode determinate -length 300 -orient horizontal"
  set widlist [list \
    "fra - - - - pack {-h 10}" \
    ".Lab1SplashScreen - - - - pack {-t {$msg1}}" \
    ".ProgSplashScreen - - - - pack {$atr1 $args}" \
    ".Lab2SplashScreen - - - - {pack -anchor w} {-t {$msg2}}" \
    ]
  set win [my makeWindow $qdlg.fra $ttl]
  set widlist [my paveWindow $qdlg.fra $widlist]
  ::tk::PlaceWindow $win widget $wprn
  my showWindow $win $modal $ontop
  if {$modal} {grab set $win}
  update
  set ::apave::_AP_VARS(ProSplash,type) $type
  set ::apave::_AP_VARS(ProSplash,win) $win
  set ::apave::_AP_VARS(ProSplash,wid1) [my Lab1SplashScreen]
  set ::apave::_AP_VARS(ProSplash,wid2) [my ProgSplashScreen]
  set ::apave::_AP_VARS(ProSplash,wid3) [my Lab2SplashScreen]
  set ::apave::_AP_VARS(ProSplash,val1) 0
  set ::apave::_AP_VARS(ProSplash,val2) 0
  set ::apave::_AP_VARS(ProSplash,value) 0
  set ::apave::_AP_VARS(ProSplash,curvalue) 0
  set ::apave::_AP_VARS(ProSplash,maxvalue) $maxvalue
  set ::apave::_AP_VARS(ProSplash,after) [list]
  # 'after' should be postponed, as 'update' messes it up
  rename ::after ::ProSplash_after
; proc ::after {args} {
    lappend ::apave::_AP_VARS(ProSplash,after) $args
  }
}
#_______________________

method progress_Go {value {msg1 ""} {msg2 ""}} {
  # Updates a progress window.
  #   value -  current value of the progress bar
  #   msg1 - top message
  #   msg2 - bottom message
  # Returns current percents (value) of progress.
  # If it reaches 100, the progress_Go may continue from 0.
  # See also: progress_Begin

  set ::apave::_AP_VARS(ProSplash,val1) $value
  incr ::apave::_AP_VARS(ProSplash,val2)
  set val [expr {min(100,int(100*$value/$::apave::_AP_VARS(ProSplash,maxvalue)))}]
  if {$val!=$::apave::_AP_VARS(ProSplash,value)} {
    set ::apave::_AP_VARS(ProSplash,value) $val
    catch {  ;# there might be no splash widgets, then let it run dry
      $::apave::_AP_VARS(ProSplash,wid2) configure -value $val
      if {$msg1 ne {}} {
        $::apave::_AP_VARS(ProSplash,wid1) configure -text $msg1
      }
      if {$msg2 ne {}} {
        $::apave::_AP_VARS(ProSplash,wid3) configure -text $msg2
      }
      update
    }
  }
  return $val
}
#_______________________

method progress_End {} {
  # Destroys a progress window.
  # See also: progress_Begin

  variable ::apave::_AP_VARS
  catch {
    destroy $::apave::_AP_VARS(ProSplash,win)
    rename ::after {}
    rename ::ProSplash_after ::after
    foreach aftargs $::apave::_AP_VARS(ProSplash,after) {
      after {*}$aftargs
    }
    if {$::apave::_AP_VARS(ProSplash,type) eq {}} {
      puts "Splash statistics: \
        \n  \"maxvalue\": $::apave::_AP_VARS(ProSplash,maxvalue) \
        \n  curr.value: $::apave::_AP_VARS(ProSplash,val1) \
        \n  steps made: $::apave::_AP_VARS(ProSplash,val2)"
    }
    unset ::apave::_AP_VARS(ProSplash,type)
    unset ::apave::_AP_VARS(ProSplash,win)
    unset ::apave::_AP_VARS(ProSplash,wid1)
    unset ::apave::_AP_VARS(ProSplash,wid2)
    unset ::apave::_AP_VARS(ProSplash,wid3)
    unset ::apave::_AP_VARS(ProSplash,val1)
    unset ::apave::_AP_VARS(ProSplash,val2)
    unset ::apave::_AP_VARS(ProSplash,value)
    unset ::apave::_AP_VARS(ProSplash,curvalue)
    unset ::apave::_AP_VARS(ProSplash,maxvalue)
    unset ::apave::_AP_VARS(ProSplash,after)
  }
}

## ________________________ Text utilities _________________________ ##

method pasteText {txt} {
  # Removes a selection at pasting.
  #   txt - text's path
  # The absence of this feature is very perpendicular of Tk's paste.

  set err [catch {$txt tag ranges sel} sel]
  if {!$err && [llength $sel]==2} {
    lassign $sel pos1 pos2
    set pos [$txt index insert]
    if {[$txt compare $pos >= $pos1] && [$txt compare $pos <= $pos2]} {
      $txt delete $pos1 $pos2
    }
  }
}
#_______________________

method doubleText {txt {dobreak 1}} {
  # Doubles a current line or a selection of text widget.
  #   txt - text's path
  #   dobreak - if true, means "return -code break"
  # The *dobreak=true* allows to break the Tk processing of keypresses
  # such as Ctrl+D.
  # If not set, the text widget is identified as `my TexM`.

  if {$txt eq {}} {set txt [my TexM]}
  set err [catch {$txt tag ranges sel} sel]
  if {!$err && [llength $sel]==2} {
    lassign $sel pos pos2
    set pos3 insert  ;# single selection
  } else {
    lassign [my GetLinePosition $txt insert] pos pos2  ;# current line
    set pos3 $pos2
  }
  set duptext [$txt get $pos $pos2]
  if {$pos3 ne {insert} && $pos2==[$txt index end]} {
    # current line is the last one: duplicate it properly
    set duptext \n[string range $duptext 0 end-1]
  }
  $txt insert $pos3 $duptext
  if {$dobreak} {return -code break}
}
#_______________________

method deleteLine {txt {dobreak 1}} {
  # Deletes a current line of text widget.
  #   txt - text's path
  #   dobreak - if true, means "return -code break"
  # The *dobreak=true* allows to break the Tk processing of keypresses
  # such as Ctrl+Y.
  # If not set, the text widget is identified as `my TexM`.

  if {$txt eq {}} {set txt [my TexM]}
  lassign [my GetLinePosition $txt insert] linestart lineend
  $txt delete $linestart $lineend
  if {$dobreak} {return -code break}
}
#_______________________

method linesMove {txt to {dobreak 1}} {
  # Moves a current line or lines of selection up/down.
  #   txt - text's path
  #   to - direction (-1 means "up", +1 means "down")
  #   dobreak - if true, means "return -code break"
  # The *dobreak=true* allows to break the Tk processing of keypresses
  # such as Ctrl+Y.
  # If not set, the text widget is identified as `my TexM`.

; proc NewRow {ind rn} {
    set i [string first . $ind]
    set row [string range $ind 0 $i-1]
    return [incr row $rn][string range $ind $i end]
  }
  if {$txt eq {}} {set txt [my TexM]}
  set err [catch {$txt tag ranges sel} sel]
  lassign [$txt index insert] pos  ;# position of caret
  if {[set issel [expr {!$err && [llength $sel]==2}]]} {
    lassign $sel pos1 pos2         ;# selection's start & end
    set l1 [expr {int($pos1)}]
    set l2 [expr {int($pos2)}]
    set pos21 [$txt index "$pos2 linestart"]
    if {[$txt get $pos21 $pos2] eq {}} {incr l2 -1}
    set lfrom [expr {$to>0 ? $l2+1 : $l1-1}]
    set lto   [expr {$to>0 ? $l1-1 : $l2-1}]
  } else {
    set lcurr [expr {int($pos)}]
    set lfrom [expr {$to>0 ? $lcurr+1 : $lcurr-1}]
    set lto   [expr {$to>0 ? $lcurr-1 : $lcurr-1}]
  }
  set lend [expr {int([$txt index end])}]
  if {$lfrom>0 && $lfrom<$lend} {
    incr lto
    lassign [my GetLinePosition $txt $lfrom.0] linestart lineend
    set duptext [$txt get $linestart $lineend]
    ::apave::undoIn $txt
    $txt delete $linestart $lineend
    $txt insert $lto.0 $duptext
    ::tk::TextSetCursor $txt [NewRow $pos $to]
    if {$issel} {
      $txt tag add sel [NewRow $pos1 $to] [NewRow $pos2 $to]
    }
    if {[lsearch -glob [$txt tag names] tagCOM*]>-1} {
      catch {::hl_tcl::my::Modified $txt insert $lto.0 $lto.end}
    }
    ::apave::undoOut $txt
    if {$dobreak} {return -code break}
  }
}
#_______________________

method selectedWordText {txt} {
  # Returns a word under the cursor or a selected text.
  #   txt - the text's path

  set seltxt {}
  if {![catch {$txt tag ranges sel} seltxt]} {
    if {[set forword [expr {$seltxt eq {}}]]} {
      set pos  [$txt index "insert wordstart"]
      set pos2 [$txt index "insert wordend"]
      set seltxt [string trim [$txt get $pos $pos2]]
      if {![string is wordchar -strict $seltxt]} {
        # when cursor just at the right of word: take the word at the left
        set pos  [$txt index "insert -1 char wordstart"]
        set pos2 [$txt index "insert -1 char wordend"]
      }
    } else {
      lassign $seltxt pos pos2
    }
    catch {
      set seltxt [$txt get $pos $pos2]
      if {[set sttrim [string trim $seltxt]] ne {}} {
        if {$forword} {set seltxt $sttrim}
      }
    }
  }
  return $seltxt
}
#_______________________

method InitFindInText { {ctrlf 0} {txt {}} } {
  # Initializes the search in the text.
  #   ctrlf - "1" means that the method is called by Ctrl+F
  #   txt - path to the text widget

  if {$txt eq {}} {set txt [my TexM]}
  if {$ctrlf} {  ;# Ctrl+F moves cursor 1 char ahead
    ::tk::TextSetCursor $txt [$txt index "insert -1 char"]
  }
  if {[set seltxt [my selectedWordText $txt]] ne {}} {
    set Foundstr $seltxt
  }
}
#_______________________

method findInText {{donext 0} {txt ""} {varFind ""} {dobell yes}} {
  # Finds a string in text widget.
  #   donext - "1" means 'from a current position'
  #   txt - path to the text widget
  #   varFind - variable
  #   dobell - if yes, bells
  # Returns yes, if found (or nothing to find), otherwise returns "no";
  # also, if there was a real search, the search string is added.

  if {$txt eq {}} {
    set txt [my TexM]
    set sel $Foundstr
  } elseif {$donext && [set sel [my get_HighlightedString]] ne {}} {
    # find a string got with alt+left/right
  } elseif {$varFind eq {}} {
    set sel $Foundstr
  } else {
    set sel [set $varFind]
  }
  if {$donext} {
    set pos [$txt index insert]
    if {{sel} in [$txt tag names $pos]} {
      set pos [$txt index "$pos + 1 chars"]
    }
    set pos [$txt search -- $sel $pos end]
  } else {
    set pos {}
    my set_HighlightedString {}
  }
  if {![string length "$pos"]} {
    set pos [$txt search -- $sel 1.0 end]
  }
  if {[string length "$pos"]} {
    ::tk::TextSetCursor $txt $pos
    $txt tag add sel $pos [$txt index "$pos + [string length $sel] chars"]
    focus $txt
    set res yes
  } else {
    if {$dobell} bell
    set res no
  }
  list $res $sel
}
#_______________________

method GetLinkLab {m} {
  # Gets a link for label.
  #   m - label with possible link (between <link> and </link>)
  # Returns: list of "pure" message and link for label.

  if {[set i1 [string first "<link>" $m]]<0} {
    return [list $m]
  }
  set i2 [string first "</link>" $m]
  set link [string range $m $i1+6 $i2-1]
  set m [string range $m 0 $i1-1][string range $m $i2+7 end]
  list $m [list -link $link]
}
#_______________________

method popupFindCommands {pop {txt {}} {com1 ""} {com2 ""}} {
  # Returns find commands for a popup menu on a text.
  #   pop - path to the menu
  #   txt - path to the text
  #   com1 - user's command "find first"
  #   com2 - user's command "find next"

  set accF3 [::apave::KeyAccelerator [::apave::getTextHotkeys F3]]
  if {$com1 eq {}} {set com1 "[self] InitFindInText 0 $txt; focus \[[self] Entfind\]"}
  if {$com2 eq {}} {set com2 "[self] findInText 1 $txt"}
  return "\$pop add separator
    \$pop add command [my iconA find] -accelerator Ctrl+F -label \"Find First\" \\
      -command {$com1}
    \$pop add command [my iconA none] -accelerator $accF3 -label \"Find Next\" \\
      -command {$com2}"
}
#_______________________

method popupBlockCommands {pop {txt {}}} {
  # Returns block commands for a popup menu on a text.
  #   pop - path to the menu
  #   txt - path to the text

  set accD [::apave::KeyAccelerator [::apave::getTextHotkeys CtrlD]]
  set accY [::apave::KeyAccelerator [::apave::getTextHotkeys CtrlY]]
  return "\$pop add separator
    \$pop add command [my iconA add] -accelerator $accD -label \"Double Selection\" \\
      -command \"[self] doubleText {$txt} 0\"
    \$pop add command [my iconA delete] -accelerator $accY -label \"Delete Line\" \\
      -command \"[self] deleteLine {$txt} 0\"
    \$pop add command [my iconA up] -accelerator Alt+Up -label \"Line(s) Up\" \\
      -command \"[self] linesMove {$txt} -1 0\"
    \$pop add command [my iconA down] -accelerator Alt+Down -label \"Line(s) Down\" \\
      -command \"[self] linesMove {$txt} +1 0\""
}
#_______________________

method askForSave {wtxt {doask ""}} {
  # For a text, sets/gets "ask for save changes" flag.
  #   wtxt - text's path
  #   doask - flag
  # If the flag argument omitted, returns the flag else sets it.
  # See also: constructor

  set prop _AskForSave_$wtxt
  if {$doask eq {}} {
    set res [::apave::getProperty $prop]
    if {![string is false -strict $res]} {set res 1}
  } else {
    set res [::apave::setProperty $prop $doask]
  }
  return $res
}

## ________________________ Highlighting _________________________ ##

method popupHighlightCommands {{pop ""} {txt ""}} {
  # Returns highlighting commands for a popup menu on a text.
  #   pop - path to the menu
  #   txt - path to the text

  set accQ [::apave::KeyAccelerator [::apave::getTextHotkeys AltQ]]
  set accW [::apave::KeyAccelerator [::apave::getTextHotkeys AltW]]
  set res "\$pop add separator
    \$pop add command [my iconA upload] -accelerator $accQ \\
    -label \"Highlight First\" -command \"[self] seek_highlight %w 2\"
    \$pop add command [my iconA download] -accelerator $accW \\
    -label \"Highlight Last\" -command \"[self] seek_highlight %w 3\"
    \$pop add command [my iconA previous] -accelerator Alt+Left \\
    -label \"Highlight Previous\" -command \"[self] seek_highlight %w 0\"
    \$pop add command [my iconA next] -accelerator Alt+Right \\
    -label \"Highlight Next\" -command \"[self] seek_highlight %w 1\"
    \$pop add command [my iconA none] -accelerator Dbl.Click \\
    -label \"Highlight All\" -command \"[self] highlight_matches %w\""
  if {$txt ne {}} {set res [string map [list %w $txt] $res]}
  return $res
}
#_______________________

method set_HighlightedString {sel} {
  # Saves a string got from highlighting by Alt+left/right/q/w.
  #   sel - the string to be saved

  set HLstring $sel
  if {$sel ne {}} {set Foundstr $sel}
}
#_______________________

method get_HighlightedString {} {
  # Returns a string got from highlighting by Alt+left/right/q/w.

  if {[info exists HLstring]} {
    return $HLstring
  }
  return {}
}
#_______________________

method set_highlight_matches {w} {
  # Creates bindings to highlight matches in a text.
  #   w - path to the text

  if {![winfo exists $w]} return
  $w tag configure hilited -foreground #1f0000 -background #ffa073
  $w tag configure hilited2 -foreground #1f0000 -background #ff6b85
  $w tag lower hilited sel
  bind $w <Double-ButtonPress-1> [list [self] highlight_matches $w]
  ::apave::bindToEvent $w <KeyRelease> [self] unhighlight_matches $w
  bind $w <Alt-Left> "[self] seek_highlight $w 0 ; break"
  bind $w <Alt-Right> "[self] seek_highlight $w 1 ; break"
  foreach k [::apave::getTextHotkeys AltQ] {
    bind $w <$k> [list [self] seek_highlight $w 2]
  }
  foreach k [::apave::getTextHotkeys AltW] {
    bind $w <$k> [list [self] seek_highlight $w 3]
  }
}
#_______________________

method get_highlighted {txt} {
  # Gets a selected word after double-clicking on a text.
  #   w - path to the text

  set err [catch {$txt tag ranges sel} sel]
  lassign $sel pos pos2
  if {!$err && [llength $sel]==2} {
    set sel [$txt get $pos $pos2]  ;# single selection
  } else {
    if {$err || [string trim $sel] eq {}} {
      set pos  [$txt index "insert wordstart"]
      set pos2 [$txt index "insert wordend"]
      set sel [string trim [$txt get $pos $pos2]]
      if {![string is wordchar -strict $sel]} {
        # when cursor just at the right of word: take the word at the left
        # e.g. if "_" stands for cursor then "word_" means selecting "word"
        set pos  [$txt index "insert -1 char wordstart"]
        set pos2 [$txt index "insert -1 char wordend"]
        set sel [string trim [$txt get $pos $pos2]]
      }
      set slen [string length $sel]
      if {!$slen} {incr slen; set pos2 [$txt index "$pos2 +1c"]}
      set pos [$txt index "$pos2 -$slen char"]
      set sel [string trim [$txt get $pos $pos2]]
    }
  }
  list $sel $pos $pos2
}
#_______________________

method highlight_matches {txt} {
  # Highlights matches of selected word in a text.
  #   txt - path to the text

  lassign [my get_highlighted $txt] sel pos pos2
  if {$sel eq {}} return
  after idle "[self] highlight_matches_real $txt $pos $pos2"
  my set_HighlightedString $sel
  set lenList {}
  set posList [$txt search -all -count lenList -- "$sel" 1.0 end]
  foreach pos2 $posList len $lenList {
    if {$len eq {}} {set len [string length $sel]}
    set pos3 [$txt index "$pos2 + $len chars"]
    if {$pos2 == $pos} {
      lappend matches2 $pos2 $pos3
    } else {
      lappend matches1 $pos2 $pos3
    }
  }
  catch {
    $txt tag remove hilited 1.0 end
    $txt tag remove hilited2 1.0 end
    $txt tag add hilited {*}$matches1
    $txt tag add hilited2 {*}$matches2
  }
  set ::apave::_AP_VARS(HILI,$txt) yes
}
#_______________________

method unhighlight_matches {txt} {
  # Unhighlights matches of selected word in a text.
  #   w - path to the text

  if {[info exists ::apave::_AP_VARS(HILI,$txt)] && $::apave::_AP_VARS(HILI,$txt)} {
    $txt tag remove hilited 1.0 end
    $txt tag remove hilited2 1.0 end
    set ::apave::_AP_VARS(HILI,$txt) no
  }
}
#_______________________

method seek_highlight {txt mode} {
  # Seeks the selected word forward/backward/to first/to last in a text.
  #   w - path to the text
  #   mode - 0 (search backward), 1 (forward), 2 (first), 3 (last)

  my unhighlight_matches $txt
  lassign [my get_highlighted $txt] sel pos pos2
  if {$sel eq {}} return
  my set_HighlightedString $sel
  switch $mode {
    0 { ;# backward
      set nc [expr {[string length $sel] - 1}]
      set pos [$txt index "$pos - $nc chars"]
      set pos [$txt search -backwards -- $sel $pos 1.0]
    }
    1 { ;# forward
      set pos [$txt search -- $sel $pos2 end]
    }
    2 { ;# to first
      set pos [$txt search -- $sel 1.0 end]
    }
    3 { ;# to last
      set pos [$txt search -backwards -- $sel end 1.0]
    }
  }
  if {[string length "$pos"]} {
    ::tk::TextSetCursor $txt $pos
    $txt tag add sel $pos [$txt index "$pos + [string length $sel] chars"]
  }
}
#_______________________

method highlight_matches_real {txt pos1 pos2} {
  # Highlights a selected word in a text, esp. fow Windows.
  # Windows thinks a word is edged by spaces only: not in real case.
  #   txt - path to the text
  #   pos1 - starting position of real selection
  #   pos2 - ending position of real selection

  $txt tag remove sel 1.0 end
  if {[$txt get $pos1] eq "\n"} {
    # if a word at line start, Windows select an empty line above
    lassign [split $pos1 .] l c
    set pos1 [incr l].$c
  }
  catch {::tk::TextSetCursor $txt $pos1}
  $txt tag add sel $pos1 $pos2
}

## ________________________ Query's auxiliaries _________________________ ##

method varName {wname} {
  # Gets a variable name associated with a widget's name of "input" dialogue.
  #   wname - widget's name

  return [namespace current]::var$wname
}
#_______________________

method FieldName {name} {
  # Gets a field name.

  return fraM.fra$name.$name
}
#_______________________

method GetVarsValues {lwidgets} {
  # Gets values of entries passed (or set) in -tvar.
  #   lwidgets - list of widget items

  set res [set vars [list]]
  foreach wl $lwidgets {
    set ownname [my ownWName [lindex $wl 0]]
    set vv [my varName $ownname]
    set attrs [lindex $wl 6]
    if {[string match "ra*" $ownname]} {
      # only for widgets with a common variable (e.g. radiobuttons):
      foreach t {-var -tvar} {
        if {[set v [::apave::getOption $t {*}$attrs]] ne {}} {
          array set a $attrs
          set vv $v
        }
      }
    }
    if {[info exist $vv] && [lsearch $vars $vv]==-1} {
      lappend res [set $vv]
      lappend vars $vv
    }
  }
  return $res
}
#_______________________

method SetGetTexts {oper w iopts lwidgets} {
  # Sets/gets contents of text fields.
  #   oper - "set" to set, "get" to get contents of text field
  #   w - window's name
  #   iopts - equals to "" if no operation
  #   lwidgets - list of widget items

  if {$iopts eq {}} return
  foreach widg $lwidgets {
    set wname [lindex $widg 0]
    set name [my ownWName $wname]
    if {[string range $name 0 1] eq "te"} {
      set vv [my varName $name]
      if {$oper eq "set"} {
        my displayText $w.$wname [set $vv]
      } else {
        set $vv [string trimright [$w.$wname get 1.0 end]]
      }
    }
  }
}
#_______________________

method GetLinePosition {txt ind} {
  # Gets a line's position.
  #   txt - text widget
  #   ind - index of the line
  # Returns a list containing a line start and a line end.

  set linestart [$txt index "$ind linestart"]
  set lineend   [expr {$linestart + 1.0}]
  list $linestart $lineend
}
#_______________________

method AppendButtons {widlistName buttons neighbor pos defb timeout win modal ONCLOSE} {
  # Adds buttons to the widget list from a position of neighbor widget.
  #   widlistName - variable name for widget list
  #   buttons - buttons to add
  #   neighbor - neighbor widget
  #   pos - position of neighbor widget
  #   defb - default button
  #   timeout  - timeout (to count down seconds and invoke a button)
  #   win - dialogue's path
  #   modal - yes if the window is modal
  #   ONCLOSE - command to run at closing the dialog
  # Returns list of "Help" button's name and command.

  upvar $widlistName widlist
  set Defb1 [set Defb2 [set bhlist {}]]
  foreach {but txt res} $buttons {
    set com "[self] res $Dlgpath"
    if {[info commands $res] eq {}} {
      set com "$com $res"
    } else {
      if {$res eq {destroy}} {
        # for compatibility with old modal windows
        if {$modal} {set res "$com 0"} {set res "destroy $win"}
      }
      set com $res  ;# "res" is set as a command
    }
    if {$but eq {butHELP}} {
      # Help button contains the command in "res"
      set com [string map "%w $win" $res]
      set bhlist [list $but $com]
    } elseif {$Defb1 eq {}} {
      set Defb1 $but
    } elseif {$Defb2 eq {}} {
      set Defb2 $but
    }
    if {$ONCLOSE ne {}} {append com " ; $ONCLOSE"}
    if {[set _ [string first "::" $txt]]>-1} {
      set tt " -tip {[string range $txt $_+2 end]}"
      set txt [string range $txt 0 $_-1]
    } else {
      set tt {}
    }
    if {$timeout ne {} && ($defb eq $but || $defb eq {})} {
      set tmo "-timeout {$timeout}"
    } else {
      set tmo {}
    }
    if {$but eq {butHELP}} {
      set neighbor [lindex $widlist end 1]
      set widlist [lreplace $widlist end end]
      lappend widlist [list $but $neighbor T 1 1 {-st w} \
        "-t \"$txt\" -com \"$com\"$tt $tmo -tip F1"]
      set h h_Help
      lappend widlist [list $h $but L 1 94 {-st we}]
      set neighbor $h
    } else {
      lappend widlist [list $but $neighbor $pos 1 1 {-st we} \
        "-t \"$txt\" -com \"$com\"$tt $tmo"]
      set neighbor $but
    }
    set pos L
  }
  lassign [my LowercaseWidgetName $Dlgpath.fra.$Defb1] Defb1
  lassign [my LowercaseWidgetName $Dlgpath.fra.$Defb2] Defb2
  return $bhlist
}

## ________________________ Query the terrible _________________________ ##

method Query {icon ttl msg buttons defb inopts argdia {precom ""} args} {
  # Makes a query (or a message) and gets the user's response.
  #   icon    - icon name (info, warn, ques, err)
  #   ttl     - title
  #   msg     - message
  #   buttons - list of triples "button name, text, ID"
  #   defb    - default button (OK, YES, NO, CANCEL, RETRY, ABORT)
  #   inopts  - options for input dialog
  #   argdia - list of dialog's options
  #   precom - command(s) performed before showing the dialog
  #   args - additional options (message's font etc.)
  # The *argdia* may contain additional options of the query, like these:
  #   -checkbox text (-ch text) - makes the checkbox's text visible
  #   -geometry +x+y (-g +x+y) - sets the geometry of dialog
  #   -color cval    (-c cval) - sets the color of message
  # If "-geometry" option is set (even equaling "") the Query procedure
  # returns a list with chosen button's ID and a new geometry.
  # Otherwise it returns only the chosen button's ID.
  # See also:
  # [aplsimple.github.io](https://aplsimple.github.io/en/tcl/pave/index.html)

  set wdia $Winpath.dia
  append wdia [lindex [split [self] :] end] ;# be unique per apave object
  set qdlg [set Dlgpath $wdia[incr Indexdlg]]
  # remember the focus (to restore it after closing the dialog)
  set focusback [focus]
  set focusmatch {}
  # options of dialog
  lassign {} chmsg geometry optsLabel optsMisc optsFont optsFontM optsHead \
    root rotext head hsz binds postcom onclose ONCLOSE timeout tab2 \
    tags cc themecolors optsGrid addpopup minsize savetext
  set wasgeo [set textmode [set stay [set waitvar 0]]]
  set readonly [set hidefind [set scroll [set modal 1]]]
  set wrap word
  set curpos {1.0}
  set CheckNomore 0
  foreach {opt val} {*}$argdia {
    if {$opt in {-c -color -fg -bg -fgS -bgS -cc -hfg -hbg}} {
      # take colors by their variables
      if {[info exist $val]} {set val [set $val]}
    }
    switch -- $opt {
      -H - -head {
        set head [string map {$ \$ \" \'\' \{ ( \} )} $val]
      }
      -help {
        set buttons "butHELP Help {$val} $buttons"
      }
      -ch - -checkbox {set chmsg "$val"}
      -g - -geometry {
        set geometry $val
        if {[set wasgeo [expr {[string first "pointer" $val]<0}]]} {
          lassign [::apave::splitGeometry $geometry] - - gx gy
        }
      }
      -c - -color {append optsLabel " -foreground {$val}"}
      -a { ;# additional grid options of message labels
        append optsGrid " $val" }
      -onclose {
        set ONCLOSE [string map [list %w $qdlg] $val]
        lappend args $opt $ONCLOSE
      }
      -centerme - -ontop - -themed - -resizable - -checkgeometry - -comOK - -transient {
        lappend args $opt $val ;# options delegated to showModal method
      }
      -parent - -root { ;# obsolete, used for compatibility
        lappend args -centerme $val
      }
      -t - -text {set textmode $val}
      -tags {
        upvar 2 $val _tags
        set tags $_tags
      }
      -ro - -readonly {set readonly [set hidefind $val]}
      -rotext {set hidefind 0; set rotext $val}
      -w - -width {set charwidth $val}
      -h - -height {set charheight $val}
      -fg {append optsMisc " -foreground {$val}"}
      -bg {append optsMisc " -background {$val}"}
      -fgS {append optsMisc " -selectforeground {$val}"}
      -bgS {append optsMisc " -selectbackground {$val}"}
      -cc {append optsMisc " -insertbackground {$val}"}
      -my - -myown {append optsMisc " -myown {$val}"}
      -pos {set curpos "$val"}
      -hfg {append optsHead " -foreground {$val}"}
      -hbg {append optsHead " -background {$val}"}
      -hsz {append hsz " -size $val"}
      -minsize {set minsize "-minsize {$val}"}
      -focus {set focusmatch "$val"}
      -theme {append themecolors " {$val}"}
      -post {set postcom $val}
      -popup {set addpopup [string map [list %w $qdlg.fra.texM] "$val"]}
      -timeout - -focusback - -scroll - -tab2 - -stay - -modal - -waitvar - -wrap {
        set [string range $opt 1 end] $val
      }
      -savetext {set savetext $val}
      default {
        if {$opt ne {} && $val ne {}} {
          append optsFont " $opt [list $val]"
          if {$opt ne "-family"} {
            append optsFontM " $opt [list $val]"
          }
        }
      }
    }
  }
  if {[set wprev [::apave::InfoFind $wdia $modal]] ne {}} {
    catch {
      wm withdraw $wprev
      wm deiconify $wprev
      puts "$wprev already exists: selected now"
    }
    return 0
  }
  set optsFont [string trim $optsFont]
  set optsHeadFont $optsFont
  set fs [my basicFontSize]
  set textfont [my basicTextFont]
  if {$optsFont ne {}} {
    if {[string first "-size " $optsFont]<0} {
      append optsFont " -size $fs"
    }
    if {[string first "-size " $optsFontM]<0} {
      append optsFontM " -size $fs"
    }
    if {[string first "-family " $optsFont]>=0} {
      set optsFont "-font \{$optsFont"
    } else {
      set optsFont "-font \{$optsFont [my basicDefFont]"
    }
    append optsFont "\}"
  } else {
    set optsFont "-font {[font actual apaveFontDef] -size $fs}"
    set optsFontM "-size $fs"
  }
  set msgonly [expr {$readonly || $hidefind || $chmsg ne {}}]
  if {!$textmode || $msgonly} {
    set textfont [my basicDefFont]
    if {!$textmode} {
      set msg [string map [list \\ \\\\ \{ \\\\\{ \} \\\\\}] $msg]
    }
  }
  set optsFontM [string trim $optsFontM]
  set optsFontM "-font \{$optsFontM $textfont\}"
  # layout: add the icon
  if {$icon ni {{} -}} {
    set widlist [list [list labBimg - - 99 1 \
      {-st n -pady 7} "-image [::apave::iconImage $icon]"]]
    set prevl labBimg
  } else {
    set widlist [list [list labimg - - 99 1]]
    set prevl labimg ;# this trick would hide the prevw at all
  }
  set prevw labBimg
  if {$head ne {}} {
    # set the dialog's heading (-head option)
    if {$optsHeadFont ne {} || $hsz ne {}} {
      if {$hsz eq {}} {set hsz "-size [::apave::obj basicFontSize]"}
      set optsHeadFont [string trim "$optsHeadFont $hsz"]
      set optsHeadFont "-font \"$optsHeadFont\""
    }
    set optsFont {}
    set prevp L
    set head [string map {\\n \n} $head]
    foreach lh [split $head "\n"] {
      set labh "labheading[incr il]"
      lappend widlist [list $labh $prevw $prevp 1 99 {-st we} \
        "-t \"$lh\" $optsHeadFont $optsHead"]
      set prevw [set prevh $labh]
      set prevp T
    }
  } else {
    # add the upper (before the message) blank frame
    lappend widlist [list h_1 $prevw L 1 1 {-pady 3}]
    set prevw [set prevh h_1]
    set prevp T
  }
  # add the message lines
  set il [set maxw 0]
  if {$readonly && $rotext eq {}} {
    # only for messaging (not for editing/viewing texts):
    set msg [string map {\\\\n \\n \\n \n} $msg]
  }
  foreach m [split $msg \n] {
    set m [string map {$ \$ \" \'\'} $m]
    if {[set mw [string length $m]] > $maxw} {
      set maxw $mw
    }
    incr il
    if {!$textmode} {
      lassign [my GetLinkLab $m] m link
      lappend widlist [list Lab$il $prevw $prevp 1 7 \
        "-st w -rw 1 $optsGrid" "-t \"$m \" $optsLabel $optsFont $link"]
    }
    set prevw Lab$il
    set prevp T
  }
  if {$inopts ne {}} {
    # here are widgets for input (in fraM frame)
    set io0 [lindex $inopts 0]
    lset io0 1 $prevh
    lset inopts 0 $io0
    foreach io $inopts {
      lappend widlist $io
    }
    set prevw fraM
  } elseif {$textmode} {
    # here is text widget (in fraM frame)
  ; proc vallimits {val lowlimit isset limits} {
      set val [expr {max($val,$lowlimit)}]
      if {$isset} {
        upvar $limits lim
        lassign $lim l1 l2
        set val [expr {min($val,$l1)}] ;# forced low
        if {$l2 ne {}} {set val [expr {max($val,$l2)}]} ;# forced high
      }
      return $val
    }
    set il [vallimits $il 1 [info exists charheight] charheight]
    incr maxw
    set maxw [vallimits $maxw 20 [info exists charwidth] charwidth]
    rename vallimits {}
    lappend widlist [list fraM $prevh T 10 12 {-st nswe -pady 3 -rw 1}]
    lappend widlist [list TexM - - 1 12 {pack -side left -expand 1 -fill both -in \
      $qdlg.fra.fraM} [list -h $il -w $maxw {*}$optsFontM {*}$optsMisc \
      -wrap $wrap -textpop 0 -tabnext "$qdlg.fra.[lindex $buttons 0] *but0"]]
    if {$scroll} {
      lappend widlist {sbv texM L 1 1 {pack -in $qdlg.fra.fraM}}
    }
    set prevw fraM
  }
  # add the lower (after the message) blank frame
  lappend widlist [list h_2 $prevw T 1 1 {-pady 0 -ipady 0 -csz 0}]
  # underline the message
  lappend widlist [list seh $prevl T 1 99 {-st ew}]
  # add left frames and checkbox (before buttons)
  lappend widlist [list h_3 seh T 1 1 {-pady 0 -ipady 0 -csz 0}]
  if {$textmode} {
    # binds to the special popup menu of the text widget
    set wt "\[[self] TexM\]"
    set binds "set pop $wt.popupMenu
      bind $wt <Button-3> \{[self] themePopup $wt.popupMenu; tk_popup $wt.popupMenu %X %Y \}"
    if {$msgonly} {
      append binds "
        menu \$pop
          \$pop add command [my iconA copy] -accelerator Ctrl+C -label \"Copy\" \\
          -command \"event generate $wt <<Copy>>\""
      if {$hidefind || $chmsg ne {}} {
        append binds "
          \$pop configure -tearoff 0
          \$pop add separator
          \$pop add command [my iconA none] -accelerator Ctrl+A \\
          -label \"Select All\" -command \"$wt tag add sel 1.0 end\"
            bind $wt <Control-a> \"$wt tag add sel 1.0 end; break\""
      }
    }
  }
  set appendHL no
  if {$chmsg eq {}} {
    if {$textmode} {
      set noIMG "[my iconA none]"
      if {$hidefind} {
        lappend widlist [list h__ h_3 L 1 4 {-cw 1}]
      } else {
        lappend widlist [list labfnd h_3 L 1 1 "-st e" "-t {$::apave::msgarray(find)}"]
        lappend widlist [list Entfind labfnd L 1 1 \
          {-st ew -cw 1} "-tvar [namespace current]::Foundstr -w 10"]
        lappend widlist [list labfnd2 Entfind L 1 1 "-cw 2" "-t {}"]
        lappend widlist [list h__ labfnd2 L 1 1]
        append binds "
          bind \[[self] Entfind\] <Return> {[self] findInText}
          bind \[[self] Entfind\] <KP_Enter> {[self] findInText}
          bind \[[self] Entfind\] <FocusIn> {\[[self] Entfind\] selection range 0 end}
          bind $qdlg <F3> {[self] findInText 1}
          bind $qdlg <Control-f> \"[self] InitFindInText 1; focus \[[self] Entfind\]; break\"
          bind $qdlg <Control-F> \"[self] InitFindInText 1; focus \[[self] Entfind\]; break\""
      }
      if {$readonly} {
        if {!$hidefind} {
          append binds "
            \$pop add separator
            \$pop add command [my iconA find] -accelerator Ctrl+F -label \\
            \"Find First\" -command \"[self] InitFindInText; focus \[[self] Entfind\]\"
            \$pop add command $noIMG -accelerator F3 -label \"Find Next\" \\
            -command \"[self] findInText 1\"
            $addpopup
            [[self] popupHighlightCommands \$pop $wt]
            \$pop add separator
            \$pop add command [my iconA exit] -accelerator Esc -label \"Close\" \\
            -command \"\[[self] paveoptionValue Defb1\] invoke\"
          "
          after idle "[self] set_highlight_matches $wt"
        } else {
          set appendHL yes
        }
      } else {
        # make bindings and popup menu for text widget
        after idle "[self] set_highlight_matches $wt"
        append binds "
          [my setTextBinds $wt]
          menu \$pop
            \$pop add command [my iconA cut] -accelerator Ctrl+X -label \"Cut\" \\
            -command \"event generate $wt <<Cut>>\"
            \$pop add command [my iconA copy] -accelerator Ctrl+C -label \"Copy\" \\
            -command \"event generate $wt <<Copy>>\"
            \$pop add command [my iconA paste] -accelerator Ctrl+V -label \"Paste\" \\
            -command \"event generate $wt <<Paste>>\"
            [[self] popupBlockCommands \$pop $wt]
            [[self] popupHighlightCommands \$pop $wt]
            [[self] popupFindCommands \$pop $wt]
            $addpopup
            \$pop add separator
            \$pop add command [my iconA SaveFile] -accelerator Ctrl+W \\
            -label \"Save and Close\" -command \"[self] res $qdlg 1\"
          "
      }
      set onclose "[namespace current]::exitEditor $qdlg"
      oo::objdefine [self] export InitFindInText
    } else {
      lappend widlist [list h__ h_3 L 1 4 {-cw 1}]
    }
  } else {
    lappend widlist [list chb h_3 L 1 1 \
      {-st w} "-t {$chmsg} -var [namespace current]::CheckNomore"]
    lappend widlist [list h_ chb L 1 1]
    lappend widlist [list sev h_ L 1 1 {-st nse -cw 1}]
    lappend widlist [list h__ sev L 1 1]
    set appendHL $textmode
  }
  if {$appendHL} {
    after idle "[self] set_highlight_matches $wt"
    append binds "
    [[self] popupHighlightCommands \$pop $wt]"
  }
  # add the buttons
  lassign [my AppendButtons widlist $buttons h__ L $defb $timeout $qdlg $modal $ONCLOSE] \
    bhelp bcomm
  # make the dialog's window
  set wtop [my makeWindow $qdlg.fra $ttl]
  if {$bhelp ne {}} {
    bind $qdlg <F1> $bcomm
  }
  # pave the dialog's window
  if {$tab2 eq {}} {
    set widlist [my paveWindow $qdlg.fra $widlist]
  } else {
    # pave with the notebook tabs (titl1 title2 [title3...] widlist2 [widlist3...])
    lassign $tab2 ttl1 ttl2 widlist2 ttl3 widlist3 ttl4 widlist4 ttl5 widlist5
    foreach nt {3 4 5} {
      set ttl ttl$nt
      set wdl widlist$nt
      if {[set _ [set $ttl]] ne {}} {
        set $ttl [list f$nt "-t {$_}"]
        set $wdl [list $qdlg.fra.nbk.f$nt "[set $wdl]"]
      }
    }
    set widlist0 [list [list nbk - - - - {pack -side top -expand 1 -fill both} [list \
      f1 "-t {$ttl1}" \
      f2 "-t {$ttl2}" \
      {*}$ttl3 \
      {*}$ttl4 \
      {*}$ttl5 \
    ]]]

    set widlist1 [list]
    foreach it $widlist {
      lassign $it w nei pos r c opt atr
      set opt [string map {$qdlg.fra $qdlg.fra.nbk.f1} $opt]
      lappend widlist1 [list $w $nei $pos $r $c $opt $atr]
    }
    set widlist [my paveWindow $qdlg.fra $widlist0 \
      $qdlg.fra.nbk.f1 $widlist1 \
      $qdlg.fra.nbk.f2 $widlist2 \
      {*}$widlist3 \
      {*}$widlist4 \
      {*}$widlist5 \
    ]
    set tab2 nbk.f1.
  }
  if {$precom ne {}} {
    {*}$precom  ;# actions before showModal
  }
  if {$themecolors ne {}} {
    # themed colors are set as sequentional '-theme' args
    if {[llength $themecolors]==2} {
      # when only 2 main fb/bg colors are set (esp. for TKE)
      lassign [::apave::parseOptions $optsMisc -foreground black \
        -background white -selectforeground black \
        -selectbackground gray -insertbackground black] v0 v1 v2 v3 v4
      # the rest colors should be added, namely:
      #   tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr help fI bI fM bM fW bW bHL2
      lappend themecolors $v0 $v1 $v2 $v3 $v3 $v1 $v4 $v4 $v3 $v2 $v3 $v0 $v1 black #ffff9e $v1
    }
    catch {
      my themeWindow $qdlg $themecolors no
    }
  }
  # after creating widgets - show dialog texts if any
  my SetGetTexts set $qdlg.fra $inopts $widlist
  lassign [my LowercaseWidgetName $qdlg.fra.$tab2$defb] focusnow
  if {$textmode} {
    set wtxt [my TexM]
    my displayTaggedText $wtxt msg $tags
    if {$defb eq "ButTEXT"} {
      if {$readonly} {
        lassign [my LowercaseWidgetName $Defb1] focusnow
      } else {
        set focusnow $wtxt
        catch "::tk::TextSetCursor $focusnow $curpos"
        foreach k {w W} \
          {catch "bind $focusnow <Control-$k> {[self] res $qdlg 1; break}"}
      }
    }
    if {$readonly} {
      my readonlyWidget $wtxt true false
    }
    if {$savetext ne {}} {
      my askForSave $wtxt $savetext
    }
  }
  if {$focusmatch ne {}} {
    foreach w $widlist {
      lassign $w widname
      lassign [my LowercaseWidgetName $widname] wn rn
      if {[string match -nocase $focusmatch $rn]} {
        lassign [my LowercaseWidgetName $qdlg.fra.$wn] focusnow
        break
      }
    }
  }
  catch "$binds"
  set args [::apave::removeOptions $args -focus]
  set ::apave::querydlg $qdlg
  my showModal $qdlg -modal $modal -waitvar $waitvar -onclose $onclose \
    -focus $focusnow -geometry $geometry {*}$minsize {*}$args
  if {![winfo exists $qdlg] || (!$modal && !$waitvar)} {
    return 0
  }
  set pdgeometry [wm geometry $qdlg]
  # the dialog's result is defined by "pave res" + checkbox's value
  set res [set result [my res $qdlg]]
  set chv $CheckNomore
  if { [string is integer $res] } {
    if {$res && $chv} { incr result 10 }
  } else {
    set res [expr {$result ne {} ? 1 : 0}]
    if {$res && $chv} { append result 10 }
  }
  if {$textmode && !$readonly} {
    set focusnow [my TexM]
    set textcont [$focusnow get 1.0 end]
    if {$res && $postcom ne {}} {
      {*}$postcom textcont [my TexM] ;# actions after showModal
    }
    set textcont " [$focusnow index insert] $textcont"
  } else {
    set textcont {}
  }
  if {$res && $inopts ne {}} {
    my SetGetTexts get $qdlg.fra $inopts $widlist
    set inopts " [my GetVarsValues $widlist]"
  } else {
    set inopts {}
  }
  if {$textmode && $rotext ne {}} {
    set $rotext [string trimright [[my TexM] get 1.0 end]]
  }
  if {!$stay} {
    destroy $qdlg
    update
    # pause a bit and restore the old focus
    if {$focusback ne {} && [winfo exists $focusback]} {
      set w ".[lindex [split $focusback .] 1]"
      after 50 [list if "\[winfo exist $focusback\]" "focus -force $focusback" elseif "\[winfo exist $w\]" "focus $w"]
    } else {
      after 50 list focus .
    }
  }
  if {$wasgeo} {
    lassign [::apave::splitGeometry $pdgeometry] w h x y
    catch {
      # geometry option can contain pointer/root etc.
      if {abs($x-$gx)<30} {set x $gx}
      if {abs($y-$gy)<30} {set y $gy}
    }
    return [list $result ${w}x$h$x$y $textcont [string trim $inopts]]
  }
  return "$result$textcont$inopts"
}

# ________________________ EOC APaveDialog _________________________ #

}

# _____________________________ EOF _____________________________________ #
