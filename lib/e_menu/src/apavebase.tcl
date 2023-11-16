###########################################################
# Name:    apavebase.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    12/09/2021
# Brief:   Handles APaveBase class, sort of geometry manager.
# License: MIT.
###########################################################

# ________________________ TCLLIBPATH _________________________ #

# use TCLLIBPATH variable (some tclkits don't see it)
catch {
  foreach _ [lreverse $::env(TCLLIBPATH)] {
    set _ [file normalize $_]
    if {[lsearch -exact $::auto_path $_]<0 && [file exists $_]} {
      set ::auto_path [linsert $::auto_path 0 $_]
    }
  }
}
unset -nocomplain _

# _____ Remove installed subpackages of apave _____ #

foreach _ {baltip bartabs hl_tcl} {
  catch {package forget $_}
  catch {namespace delete ::$_}
}
unset -nocomplain _

# ________________________ apave NS _________________________ #

namespace eval ::apave {

  variable SRCDIR [file normalize [file dirname [info script]]]

  ## ________________________ apave variables _________________________ ##

  variable ISBALTIP yes
  variable cursorwidth 1
  variable apaveDir [file dirname [info script]]
  variable _AP_ICO { none folder OpenFile SaveFile saveall print font color \
    date help home misc terminal run tools file find replace other view \
    categories actions config pin cut copy paste plus minus add delete \
    change diagram box trash double more undo redo up down previous next \
    previous2 next2 upload download tag tagoff tree lock light restricted \
    attach share mail www map umbrella gulls sound heart clock people info \
    err warn ques retry yes no ok cancel exit }
  variable _AP_IMG;  array set _AP_IMG [list]
  variable _AP_VARS; array set _AP_VARS [list]
  set _AP_VARS(.,MODALS) 0
  set _AP_VARS(TIMW) [list]
  set _AP_VARS(LINKFONT) [list -underline 1]
  set _AP_VARS(INDENT) "  "
  set _AP_VARS(KEY,F3) F3
  set _AP_VARS(KEY,CtrlA) [list Control-A Control-a]
  set _AP_VARS(KEY,CtrlD) [list Control-D Control-d]
  set _AP_VARS(KEY,CtrlY) [list Control-Y Control-y]
  set _AP_VARS(KEY,CtrlT) [list Control-T Control-t]
  set _AP_VARS(KEY,AltQ) [list Alt-Q Alt-q]
  set _AP_VARS(KEY,AltW) [list Alt-W Alt-w]
  variable _AP_VISITED;  array set _AP_VISITED [list]
  set _AP_VISITED(ALL) [list]
  variable UFF "\uFFFF"
  variable _OBJ_ {}
  variable MC_NS {}

  ## _ default options & attributes of widgets _ ##

  variable _Defaults [dict create \
    bts {{} {}} \
    but {{} {}} \
    buT {{} {-width -20 -pady 1}} \
    btT {{} {-width -20 -pady 1 -relief flat -overrelief raised -highlightthickness 0 -takefocus 0}} \
    can {{} {}} \
    chb {{} {}} \
    swi {{} {}} \
    chB {{} {-relief sunken -padx 6 -pady 2}} \
    cbx {{} {}} \
    fco {{} {}} \
    ent {{} {}} \
    enT {{} {-insertwidth $::apave::cursorwidth -insertofftime 250 -insertontime 750}} \
    fil {{} {}} \
    fis {{} {}} \
    dir {{} {}} \
    fon {{} {}} \
    clr {{} {}} \
    dat {{} {}} \
    fiL {{} {}} \
    fiS {{} {}} \
    diR {{} {}} \
    foN {{} {}} \
    clR {{} {}} \
    daT {{} {}} \
    sta {{} {}} \
    too {{} {}} \
    fra {{} {}} \
    ftx {{} {}} \
    frA {{} {}} \
    gut {{} {-width 0 -highlightthickness 1}} \
    lab {{-sticky w} {}} \
    laB {{-sticky w} {}} \
    lfr {{} {}} \
    lfR {{} {-relief groove}} \
    lbx {{} {-activestyle none -exportselection 0 -selectmode browse}} \
    flb {{} {}} \
    meb {{} {}} \
    meB {{} {}} \
    nbk {{} {}} \
    opc {{} {}} \
    pan {{} {}} \
    pro {{} {}} \
    rad {{} {}} \
    raD {{} {-padx 6 -pady 2}} \
    sca {{} {-orient horizontal -takefocus 0}} \
    scA {{} {-orient horizontal -takefocus 0}} \
    sbh {{-sticky ew} {-orient horizontal -takefocus 0}} \
    sbH {{-sticky ew} {-orient horizontal -takefocus 0}} \
    sbv {{-sticky ns} {-orient vertical -takefocus 0}} \
    sbV {{-sticky ns} {-orient vertical -takefocus 0}} \
    scf {{} {}} \
    seh {{-sticky ew} {-orient horizontal -takefocus 0}} \
    sev {{-sticky ns} {-orient vertical -takefocus 0}} \
    siz {{} {}} \
    spx {{} {}} \
    spX {{} {}} \
    tbl {{} {-selectborderwidth 1 -highlightthickness 2 \
          -labelcommand tablelist::sortByColumn -stretch all \
          -showseparators 1}} \
    tex {{} {-undo 1 -maxundo 0 -highlightthickness 2 -insertofftime 250 -insertontime 750 -insertwidth $::apave::cursorwidth -wrap word -selborderwidth 1 -exportselection 0}} \
    tre {{} {-selectmode browse}} \
    h_ {{-sticky ew -csz 3 -padx 3} {}} \
    v_ {{-sticky ns -rsz 3 -pady 3} {}}]

  ## _______________________ Helpers _____________________ ##

  proc obj {com args} {
    # Calls a method of APave class.
    #   com - a method
    #   args - arguments of the method
    # It can (and must) be used only for temporary tasks.
    # For persistent tasks, use a "normal" apave object.
    # Returns the command's result.

    variable _OBJ_
    if {$_OBJ_ eq {}} {set _OBJ_ [::apave::APave new]}
    if {[set exported [expr {$com eq "EXPORT"}]]} {
      set com [lindex $args 0]
      set args [lrange $args 1 end]
      oo::objdefine $_OBJ_ "export $com"
    }
    set res [$_OBJ_ $com {*}$args]
    if {$exported} {
      oo::objdefine $_OBJ_ "unexport $com"
    }
    return $res
  }
  #_______________________

  proc WindowStatus {w name {val ""} {defval ""}} {
    # Sets/gets a status of window. The status is a value assigned to a name.
    #   w - window's path
    #   name - name of status
    #   val - if blank, to get a value of status; otherwise a value to set
    #   defval - default value (actual if the status not set beforehand)
    # Returns a value of status.
    # See also: IntStatus

    variable _AP_VARS
    if {$val eq {}} {  ;# getting
      if {[info exist _AP_VARS($w,$name)]} {
        return $_AP_VARS($w,$name)
      }
      return $defval
    }
    return [set _AP_VARS($w,$name) $val]  ;# setting
  }
  #_______________________

  proc mainWindowOfApp {{win ""}} {
    # Sets/gets a main window of application.
    #   win - window's path
    # This should be run at application start, before opening any window.

    return [WindowStatus . MAIN_WINDOW_OF_APP $win]
  }
  #_______________________

  proc IntStatus {w {name "status"} {val ""}} {
    # Sets/gets a status of window. The status is an integer assigned to a name.
    #   w - window's path
    #   name - name of status
    #   val - if blank, to get a value of status; otherwise a value to set
    # Default value of status is 0.
    # Returns an old value of status.
    # See also: WindowStatus

    set old [WindowStatus $w $name {} 0]
    if {$val ne {}} {WindowStatus $w $name $val 1}
    return $old
  }
  #_______________________

  proc iconImage {{icon ""} {iconset "small"} {doit no}} {
    # Gets a defined icon's image or list of icons.
    # If *icon* equals to "-init", initializes apave's icon set.
    #   icon - icon's name
    #   iconset - one of small/middle/large
    #   doit - force the initialization
    # Returns the icon's image or, if *icon* is blank, a list of icons
    # available in *apave*.

    variable _AP_IMG
    variable _AP_ICO
    if {$icon eq {}} {return $_AP_ICO}
  ; proc imagename {icon} {   # Get a defined icon's image name
      return _AP_IMG(img$icon)
    }
    variable apaveDir
    if {![array size _AP_IMG] || $doit} {
      # Make images of icons
      source [file join $apaveDir apaveimg.tcl]
      if {$iconset ne "small"} {
        foreach ic $_AP_ICO {  ;# small icons best fit for menus
          set _AP_IMG($ic-small) [set _AP_IMG($ic)]
        }
        if {$iconset eq "middle"} {
          source [file join $apaveDir apaveimg2.tcl]
        } else {
          source [file join $apaveDir apaveimg2.tcl] ;# TODO
        }
      }
      foreach ic $_AP_ICO {
        if {[catch {image create photo [imagename $ic] -data [set _AP_IMG($ic)]}]} {
          # some png issues on old Tk
          image create photo [imagename $ic] -data [set _AP_IMG(none)]
        } elseif {$iconset ne "small"} {
          image create photo [imagename $ic-small] -data [set _AP_IMG($ic-small)]
        }
      }
    }
    if {$icon eq "-init"} {return $_AP_ICO} ;# just to get to icons
    if {$icon ni $_AP_ICO} {set icon [lindex $_AP_ICO 0]}
    if {$iconset eq "small" && "_AP_IMG(img$icon-small)" in [image names]} {
      set icon $icon-small
    }
    return [imagename $icon]
  }
  #_______________________

  proc iconData {{icon "info"} {iconset ""}} {
    # Gets an icon's data.
    #   icon - icon's name
    #   iconset - one of small/middle/large
    # Returns data of the icon.

    variable _AP_IMG
    iconImage -init
    if {$iconset ne {} && "_AP_IMG(img$icon-$iconset)" in [image names]} {
      return [set _AP_IMG($icon-$iconset)]
    }
    return [set _AP_IMG($icon)]
  }
  #_______________________

  proc setAppIcon {win {winicon ""}} {
    # Sets application's icon.
    #   win - path to a window of application
    #   winicon - data of icon
    # The *winicon* may be a contents of variable (as supposed by default) or
    # a file's name containing th image data.
    # If it fails to find an image in either, no icon is set.

    set appIcon {}
    if {$winicon ne {}} {
      if {[catch {set appIcon [image create photo -data $winicon]}]} {
        catch {set appIcon [image create photo -file $winicon]}
      }
    }
    if {$appIcon ne {}} {wm iconphoto $win -default $appIcon}
  }
  #_______________________

  proc precedeWidgetName {widname prename} {
    # Adds a preceding name to a tail name of widget.
    #   widname - widget's full name
    #   prename - preceding name
    # Useful at getting a entry/button name of chooser.

    # Example:
    #   set wentry [::apave::precedeWidgetName [$pobj DirToChoose] ent]
    # See also: APaveBase::Replace_chooser

    set p [string last . $widname]
    set res [string range $widname 0 $p]
    append res $prename [string range $widname $p+1 end]
    return $res
  }
  #_______________________

  proc KeyAccelerator {acc} {
    # Returns a key accelerator.
    #   acc - key name, may contain 2 items (e.g. Control-D Control-d)

    set acc [lindex $acc 0]
    return [string map {Control Ctrl - + bracketleft [ bracketright ]} $acc]
  }
  #_______________________

  proc defaultAttrs {{type ""} {opts ""} {atrs ""} {widget ""}} {
    # Sets, gets or registers default options and attributes for widget type.
    #   type - widget type
    #   opts - new default grid/pack options
    #   atrs - new default attributes
    #   widget - Tcl/Tk command for the new registered widget type
    # See also: APaveBase::defaultATTRS

    return [obj defaultATTRS $type $opts $atrs $widget]
  }
  #_______________________

  proc initBaltip {} {
    # Initializes baltip package.

    if {[info command ::baltip] eq {}} {
      if {$::apave::ISBALTIP} {
        source [file join $::apave::SRCDIR baltip baltip.tcl]
      } else {
        # disabling baltip facilities with stub proc (no source "baltip.src")
        namespace eval ::baltip {
          variable expproc [list configure cget tip update hide repaint \
            optionlist tippath clear sleep showBalloon showTip]
          foreach _ $expproc {
          ; proc $_ {args} {return {}}
            namespace export $_
          }
          namespace ensemble create
          namespace eval my {
          ; proc BindToEvent {args} {}
          }
        }
      }
    }
  }

  ## _______________________ Text little procs _________________________ ##

  proc eventOnText {w ev} {
    # Generates an event on a text, saving its current index in hl_tcl.
    #   w - text widget's path
    #   ev - event
    # The hl_tcl needs to call MemPos before any action changing the text.

    catch {::hl_tcl::my::MemPos $w}
    if {[catch {$w tag ranges sel} sels]} {set sels [list]}
    switch -exact -- $ev {
      <<Cut>> - <<Copy>> {
        if {[set llen [expr {[llength $sels]-1}]] < 2} return
        # multiple ranges of selection:
        # first, copy all selections to clipboard
        clipboard clear -displayof $w
        foreach {pos1 pos2} $sels {
          clipboard append -displayof $w [$w get $pos1 $pos2]
        }
        if {$ev eq {<<Cut>>}} {
          # for Cut event: delete all selections
          for {set i $llen} {$i>0} {incr i -2} {
            set pos1 [lindex $sels $i-1]
            set pos2 [lindex $sels $i]
            $w delete $pos1 $pos2
          }
        }
        return -code break
      }
      default {
        event generate $w $ev
      }
    }
  }
  #_______________________

  proc getTextHotkeys {key} {
    # Gets upper & lower keys for a hot key.
    #   key - the hot key

    variable _AP_VARS
    if {![info exist _AP_VARS(KEY,$key)]} {return [list]}
    set keys $_AP_VARS(KEY,$key)
    if {[llength $keys]==1} {
      if {[set i [string last - $keys]]>0} {
        set lt [string range $keys $i+1 end]
        if {[string length $lt]==1} {  ;# for lower case of letters
          set keys "[string range $keys 0 $i][string toupper $lt]"
          lappend keys "[string range $keys 0 $i][string tolower $lt]"
        }
      }
    }
    return $keys
  }
  #_______________________

  proc setTextHotkeys {key value} {
    # Sets new key combinations for some operations on text widgets.
    #   key - ctrlD for "double selection", ctrlY for "delete line" operation
    #   value - list of new key combinations

    variable _AP_VARS
    set _AP_VARS(KEY,$key) $value
  }
  #_______________________

  proc setTextIndent {len {padchar { }}} {
    # Sets an indenting for text widgets.
    #   len - length of indenting
    #   padchar - indenting character

    variable _AP_VARS
    if {$padchar ne "\t"} {set padchar { }}
    set _AP_VARS(INDENT) [string repeat $padchar $len]
  }

  ## ________________________ EONS ::apave _________________________ ##

}

# ________________________ source *.tcl _________________________ #

# Let the *.tcl be sourced here just to ensure
# that apave's stuff available for them and vice versa.

source [file join $::apave::apaveDir obbit.tcl]

# ________________________ APaveBase oo::class _________________________ #

oo::class create ::apave::APaveBase {

  mixin ::apave::ObjectTheming

  variable PV Moveall Initialcolor Modalwin Fgbut Bgbut Fgtxt Bgtxt Prepost Widgetopts Edge

  constructor {{cs -2} args} {
    # Creates APaveBase object.
    #   cs - color scheme (CS)
    #   args - additional arguments
    # If cs>-2, the appropriate CS is set for the created APaveBase object.
    # Makes few procedures in the object's namespace to access from
    # event handlers:
    #   - ListboxHandle
    #   - ListboxSelect
    #   - WinResize
    # This trick with *proc* inside an object is discussed at
    #   [proc-in-tcl-ooclass](https://stackoverflow.com/questions/54804964/proc-in-tcl-ooclass)

    # keep the 'important' data of Pave object in array
    array set PV [list]
    set Moveall 1
    set Initialcolor {}
    set Modalwin .
    set Fgbut [ttk::style lookup TButton -foreground]
    set Bgbut [ttk::style lookup TButton -background]
    set Fgtxt [ttk::style lookup TEntry -foreground]
    set Prepost [list]
    set Widgetopts [list]
    set Edge @@
    if {$Fgtxt in {black #000000}} {
      set Bgtxt white
    } else {
      set Bgtxt [ttk::style lookup TEntry -background]
    }
    # set/reset a color scheme if it is/was requested
    if {$cs>=-1} {my csSet $cs} {my initTooltip}

    # object's procedures

  ; proc ListboxHandle {W offset maxChars} {

      set list {}
      foreach index [$W curselection] { lappend list [$W get $index] }
      set text [join $list \n]
      return [string range $text $offset [expr {$offset+$maxChars-1}]]
    }

  ; proc ListboxSelect {W} {
      # This code had been taken from Tcl's wiki:
      #   https://wiki.tcl-lang.org/page/listbox+selection

      selection clear -displayof $W
      selection own -command {} $W
      selection handle -type UTF8_STRING \
        $W [list [namespace current]::ListboxHandle $W]
      selection handle \
        $W [list [namespace current]::ListboxHandle $W]
      return
    }

  ; proc WinResize {win} {
      # Restricts the window's sizes (thus fixing Tk's issue with a menubar)
      #   win - path to a window to be of restricted sizes

      if {[$win cget -menu] ne {}} {
        lassign [::apave::splitGeometry [wm geometry $win]] w h
        lassign [wm minsize $win] wmin hmin
        if {$w<$wmin && $h<$hmin} {
          set corrgeom ${wmin}x$hmin
        } elseif {$w<$wmin} {
          set corrgeom ${wmin}x$h
        } elseif {$h<$hmin} {
          set corrgeom ${w}x$hmin
        } else {
          return
        }
        wm geometry $win $corrgeom
      }
      return
    }

    # the end of APaveBase constructor
    if {[llength [self next]]} { next {*}$args }
    return
  }

  destructor {
    # Clears variables used in the object.

    array unset PV *
    if {[llength [self next]]} next
  }

  ## _______________________ Methods to be redefined ____________________ ##

  method themePopup {mnu} {
    # Applies a color scheme to a popup menu.
    #   mnu - name of popup menu
    # The method is to be redefined in descendants/mixins.
    return
  }

  method NonTtkTheme {win} {
    # Applies a current color scheme for non-ttk widgets.
    #   win - path to a window to be colored.
    # Method to be redefined in descendants/mixins.
    return
  }

  method NonTtkStyle {typ {dsbl 0}} {
    # Gets a style for non-ttk widgets.
    #   typ - the type of widget (in apave terms, i.e. but, buT etc.)
    #   dsbl - a mode to get style of disabled (1) or readonly (2) widgets
    # See also: widgetType
    # Method to be redefined in descendants/mixins.
    return
  }

  ## _______________________ Helpers for APaveBase ________________________ ##

  method paveoptionValue {opt} {
    # Gets an option's value.
    #   opt - option's name
    # Returns a value for options like "Moveall".

    if {$opt in [info object vars [self]]} {
      variable $opt
      return [set $opt]
    }
    return {}
  }
  #_______________________

  method checkXY {w h x y} {
    # Checks the coordinates of window (against the screen).
    #   w - width of window
    #   h - height of window
    #   x - window's X coordinate
    #   y - window's Y coordinate
    # Returns new coordinates in +X+Y form.

    # check for left/right edge of screen (accounting decors)
    set scrw [expr {[winfo vrootwidth .] - 12}]
    set scrh [expr {[winfo vrootheight .] - 36}]
    if {($x + $w) > $scrw } {
      set x [expr {$scrw - $w}]
    }
    if {($y + $h) > $scrh } {
      set y [expr {$scrh - $h}]
    }
    if {![string match -* $x]} {set x +[string trimleft $x +]}
    if {![string match -* $y]} {set y +[string trimleft $y +]}
    return $x$y
  }
  #_______________________

  method CenteredXY {rw rh rx ry w h} {
    # Gets the coordinates of centered window (against its parent).
    #   rw - parent's width
    #   rh - parent's height
    #   rx - parent's X coordinate
    #   ry - parent's Y coordinate
    #   w - width of window to be centered
    #   h - height of window to be centered
    # Returns centered coordinates in +X+Y form.

    set x [expr {max(0, $rx + ($rw - $w) / 2)}]
    set y [expr {max(0,$ry + ($rh - $h) / 2)}]
    return [my checkXY $w $h $x $y]
  }
  #_______________________

  method ownWName {name} {
    # Gets a tail (last part) of widget's name
    #   name - name (path) of the widget

    return [lindex [split $name .] end]
  }
  #_______________________

  method parentWName {name} {
    # Gets parent name of widget.
    #   name - name (path) of the widget

    return [string range $name 0 [string last . $name]-1]
  }
  #_______________________

  method iconA {icon {iconset small} {cmpd left}} {
    # Gets icon attributes for buttons, menus etc.
    #   icon - name of icon
    #   iconset - one of small/middle/large
    #   cmpd - value of -compound option
    # The *iconset* is "small" for menus (recommended and default).

    return "-image [::apave::iconImage $icon $iconset] -compound $cmpd"
  }
  #_______________________

  method configure {args} {
    # Configures the apave object (all of options may be changed).
    #   args - list of pairs name/value of options
    # Example:
    #     pobj configure edge "@@"

    foreach {optnam optval} $args {set $optnam $optval}
    return
  }
  #_______________________

  method ExpandOptions {options} {
    # Expands shortened options.

    set options [string map {
      { -st } { -sticky }
      { -com } { -command }
      { -t } { -text }
      { -w } { -width }
      { -h } { -height }
      { -var } { -variable }
      { -tvar } { -textvariable }
      { -lvar } { -listvariable }
      { -ro } { -readonly }
    } " $options"]
    return $options
  }
  #_______________________

  method AddButtonIcon {w attrsName} {
    # Gets the button's icon based on its text and name (e.g. butOK) and
    # appends it to the attributes of button.
    #   w - button's name
    #   attrsName - name of variable containing attributes of the button

    upvar 1 $attrsName attrs
    set com [::apave::getOption -com {*}$attrs]
    if {[string is integer -strict $com]} {
      ::apave::extractOptions attrs -com {}
      append attrs " -com {[self] res {} $com}" ;# returned integer result
    }
    if {[::apave::getOption -image {*}$attrs] ne {}} return
    set txt [::apave::getOption -t {*}$attrs]
    if {$txt eq {}} { set txt [::apave::getOption -text {*}$attrs] }
    set im {}
    set icolist [list {exit abort} {exit close} \
      {SaveFile save} {OpenFile open}]
    # ok, yes, cancel, apply buttons should be at the end of list
    # as their texts can be renamed (e.g. "Help" in e_menu's "About")
    lappend icolist {*}[::apave::iconImage] {yes apply}
    foreach icon $icolist {
      lassign $icon ic1 ic2
      # text of button is of highest priority at defining its icon
      if {[string match -nocase $ic1 $txt] || \
      [string match -nocase b*t$ic1 $w] || ($ic2 ne {} && ( \
      [string match -nocase b*t$ic2 $w] || [string match -nocase $ic2 $txt]))} {
        if {[string match -nocase btT* $w]} {
          set cmpd none
        } else {
          set cmpd left
        }
        append attrs " [my iconA $ic1 small $cmpd]"
        break
      }
    }
    return
  }
  #_______________________

  method ListboxesAttrs {w attrs} {
    # Appends selection attributes to listboxes.
    # Details:
    #   1. https://wiki.tcl-lang.org/page/listbox+selection
    #   2. https://stackoverflow.com, the question:
    #        the-tablelist-curselection-goes-at-calling-the-directory-dialog

    if {{-exportselection} ni $attrs} {
      append attrs " -ListboxSel $w -selectmode extended -exportselection 0"
    }
    return $attrs
  }
  #_______________________

  method getWidChildren {wid treeName {init yes}} {
    # Gets children of a widget.
    #   wid - widget's path
    #   treeName - name of variable to hold the result.

    upvar $treeName tree
    if {$init} {set tree [list]}
    foreach ch [winfo children $wid] {
      lappend tree $ch
      my getWidChildren $ch $treeName no
    }
  }
  #_______________________

  method findWidPath {wid {mode exact} {visible yes}} {
    # Searches a widget's path among the active widgets.
    #   w - widget name, set partially e.g. "wid" instead of ".win.wid"
    #   mode - if "exact", searches *.wid; if "globe", searches *wid*
    # Returns the widget's full path or "" if the widget isn't active.

    my getWidChildren . tree
    if {$mode eq {exact}} {
      set i [lsearch -glob $tree "*.$wid"]
    } else {
      set i [lsearch -glob $tree "*$wid*"]
    }
    if {$i>-1} {return [lindex $tree $i]}
    return {}
  }

  ## _______________________ File content widget _______________________ ##

  method FCfieldAttrs {wnamefull attrs varopt} {
    # Fills the non-standard attributes of file content widget.
    #   wnamefull - a widget name
    #   attrs - a list of all attributes
    #   varopt - a variable option
    # The *varopt* refers to a variable part such as tvar, lvar:
    #  * -inpval option means an initial value of the field
    #  * -retpos option has p1:p2 format (e.g. 0:10) to cut a substring \
    from a returned value
    # Returns *attrs* without -inpval and -retpos options.

    lassign [::apave::parseOptions $attrs $varopt {} -retpos {} -inpval {}] \
      vn rp iv
    if {[string first {-state disabled} $attrs]<0 && $vn ne {}} {
      set all {}
      if {$varopt eq {-lvar}} {
        lassign [::apave::extractOptions attrs -values {} -ALL 0] iv a
        if {[string is boolean -strict $a] && $a} {set all ALL}
        lappend Widgetopts "-lbxname$all $wnamefull $vn"
      }
      if {$rp ne {}} {
        if {$all ne {}} {set rp 0:end}
        lappend Widgetopts "-retpos $wnamefull $vn $rp"
      }
    }
    if {$iv ne {}} { set $vn $iv }
    return [::apave::removeOptions $attrs -retpos -inpval]
  }
  #_______________________

  method FCfieldValues {wnamefull attrs} {
    # Fills the file content widget's values.
    #   wnamefull - name (path) of fco widget
    #   attrs - attributes of the widget

  ; proc readFCO {fname} {
      # Reads a file's content.
      # Returns a list of (non-empty) lines of the file.
      if {$fname eq {}} {
        set retval {{}}
      } else {
        set retval {}
        foreach ln [split [::apave::readTextFile $fname {} 1] \n] {
          # probably, it's bad idea to have braces in the file of contents
          set ln [string map [list \\ \\\\ \{ \\\{ \} \\\}] $ln]
          if {$ln ne {}} {lappend retval $ln}
        }
      }
      return $retval
    }

  ; proc contFCO {fline opts edge args} {
      # Given a file's line and options,
      # cuts a substring from the line.
      lassign [::apave::parseOptionsFile 1 $opts {*}$args] opts
      lassign $opts - - - div1 - div2 - pos - len - RE - ret
      set ldv1 [string length $div1]
      set ldv2 [string length $div2]
      set i1 [expr {[string first $div1 $fline]+$ldv1}]
      set i2 [expr {[string first $div2 $fline]-1}]
      set filterfile yes
      if {$ldv1 && $ldv2} {
        if {$i1<0 || $i2<0} {return $edge}
        set retval [string range $fline $i1 $i2]
      } elseif {$ldv1} {
        if {$i1<0} {return $edge}
        set retval [string range $fline $i1 end]
      } elseif {$ldv2} {
        if {$i2<0} {return $edge}
        set retval [string range $fline 0 $i2]
      } elseif {$pos ne {} && $len ne {}} {
        set retval [string range $fline $pos $pos+[incr len -1]]
      } elseif {$pos ne {}} {
        set retval [string range $fline $pos end]
      } elseif {$len ne {}} {
        set retval [string range $fline 0 $len-1]
      } elseif {$RE ne {}} {
        set retval [regexp -inline $RE $fline]
        if {[llength $retval]>1} {
          foreach r [lrange $retval 1 end] {append retval_tmp $r}
          set retval $retval_tmp
        } else {
          set retval [lindex $retval 0]
        }
      } else {
        set retval $fline
        set filterfile no
      }
      if {$retval eq {} && $filterfile} {return $edge}
      set retval [string map [list "\}" "\\\}"  "\{" "\\\{"] $retval]
      return [list $retval $ret]
    }

    set edge $Edge
    set ldv1 [string length $edge]
    set filecontents {}
    set optionlists {}
    set tplvalues {}
    set retpos {}
    set values [::apave::getOption -values {*}$attrs]
    if {[string first $edge $values]<0} { ;# if 1 file, edge
      set values "$edge$values$edge"      ;# may be omitted
    }
    # get: files' contents, files' options, template line
    set lopts {-list {} -div1 {} -div2 {} -pos {} -len {} -RE {} -ret 0}
    while {1} {
      set i1 [string first $edge $values]
      set i2 [string first $edge $values $i1+1]
      if {$i1>=0 && $i2>=0} {
        incr i1 $ldv1
        append tplvalues [string range $values 0 $i1-1]
        set fdata [string range $values $i1 $i2-1]
        lassign [::apave::parseOptionsFile 1 $fdata {*}$lopts] fopts fname
        lappend filecontents [readFCO $fname]
        lappend optionlists $fopts
        set values [string range $values $i2+$ldv1 end]
      } else {
        append tplvalues $values
        break
      }
    }
    # fill the combobox lines, using files' contents and options
    if {[set leno [llength $optionlists]]} {
      set newvalues {}
      set ilin 0
      lassign $filecontents firstFCO
      foreach fline $firstFCO { ;# lines of first file for a base
        set line {}
        set tplline $tplvalues
        for {set io 0} {$io<$leno} {incr io} {
          set opts [lindex $optionlists $io]
          if {$ilin==0} {  ;# 1st cycle: add items from -list option
            lassign $opts - list1  ;# -list option goes first
            if {[llength $list1]} {
              foreach l1 $list1 {append newvalues "\{$l1\} "}
              lappend Widgetopts "-list $wnamefull [list $list1]"
            }
          }
          set i1 [string first $edge $tplline]
          if {$i1>=0} {
            lassign [contFCO $fline $opts $edge {*}$lopts] retline ret
            if {$ret ne "0" && $retline ne $edge && \
            [string first $edge $line]<0} {
              set p1 [expr {[string length $line]+$i1}]
              if {$io<($leno-1)} {
                set p2 [expr {$p1+[string length $retline]-1}]
              } else {
                set p2 end
              }
              set retpos "-retpos $p1:$p2"
            }
            append line [string range $tplline 0 $i1-1] $retline
            set tplline [string range $tplline $i1+$ldv1 end]
          } else {
            break
          }
          set fline [lindex [lindex $filecontents $io+1] $ilin]
        }
        if {[string first $edge $line]<0} {
          # put only valid lines into the list of values
          append newvalues "\{$line$tplline\} "
        }
        incr ilin
      }
      # replace old 'values' attribute with the new 'values'
      lassign [::apave::parseOptionsFile 2 $attrs -values \
        [string trimright $newvalues]] attrs
    }
    return "$attrs $retpos"
  }

  ## _______________________ Timeout button _______________________ ##

  method timeoutButton {w tmo lbl {lbltext ""}} {
    # Invokes a button's action after a timeout.
    #   w - button's path
    #   tmo - timeout in sec.
    #   lbl - label widget, where seconds to wait are displayed
    #   lbltext - original text of label

    if {$tmo>0} {
      catch {set lbl [my $lbl]}
      if {[winfo exist $lbl]} {
        if {$lbltext eq {}} {
          set lbltext [$lbl cget -text]
          lappend ::apave::_AP_VARS(TIMW) $w
        }
        $lbl configure -text "$lbltext $tmo sec. "
      }
      incr tmo -1
      after 1000 [list if "\[info commands [self]\] ne {}" \
        "[self] checkTimeoutButton $w $tmo $lbl {$lbltext}"]
      return
    }
    if {[winfo exist $w]} {$w invoke}
    return
  }
  #_______________________

  method checkTimeoutButton {w tmo lbl {lbltext ""}} {
    # Checks if the timeout button is alive & focused; if not, cancels the timeout.
    #   w - button's path
    #   tmo - timeout in sec.
    #   lbl - label widget, where seconds to wait are displayed
    #   lbltext - original text of label

    if {[winfo exists $lbl]} {
      if {[focus] in [list $w {}]} {
        if {$w in $::apave::_AP_VARS(TIMW)} {
          my timeoutButton $w $tmo $lbl $lbltext
        }
      } else {
        $lbl configure -text $lbltext
      }
    }

  }

  ## ________________________ Making widgets _________________________ ##

  method widgetType {wnamefull options attrs} {
    # Gets the widget type based on 3 initial letters of its name. Also
    # fills the grid/pack options and attributes of the widget.
    #   wnamefull - path to the widget
    #   options - grid/pack options of the widget
    #   attrs - attribute of the widget
    # Returns a list of items:
    #   widget - Tk/Ttk widget name
    #   options - grid/pack options of the widget
    #   attrs - attribute of the widget
    #   nam3 - 3 initial letters of widget's name
    #   disabled - flag of *disabled* state

    set disabled [expr {[::apave::getOption -state {*}$attrs] eq {disabled}}]
    set pack $options
    set name [my ownWName $wnamefull]
    if {[info exists ::apave::_AP_VARS(ProSplash,type)] && \
    $::apave::_AP_VARS(ProSplash,type) eq {}} {
      set val [my progress_Go [incr ::apave::_AP_VARS(ProSplash,curvalue)] {} $name]
    }
    set nam3 [string tolower [string index $name 0]][string range $name 1 2]
    if {[string index $nam3 1] eq "_"} {set k [string range $nam3 0 1]} {set k $nam3}
    lassign [my defaultATTRS $k] defopts defattrs newtype
    set options "$defopts $options"
    set attrs "$defattrs $attrs"
    switch -glob -- $nam3 {
      bts {
        set widget ttk::frame
        if {![info exists ::bartabs::NewBarID]} {package require bartabs}
        set attrs "-bartabs {$attrs}"
      }
      but {
        set widget ttk::button
        my AddButtonIcon $name attrs
      }
      buT - btT {
        set widget button
        my AddButtonIcon $name attrs
      }
      can {set widget canvas}
      chb {set widget ttk::checkbutton}
      swi {
        set widget ttk::checkbutton
        if {![my apaveTheme]} {
          set attrs "$attrs -style Switch.TCheckbutton"
        }
      }
      chB {set widget checkbutton}
      cbx - fco {
        set widget ttk::combobox
        if {$nam3 eq {fco}} {  ;# file content combobox
          set attrs [my FCfieldValues $wnamefull $attrs]
        }
        set attrs [my FCfieldAttrs $wnamefull $attrs -tvar]
      }
      ent {set widget ttk::entry}
      enT {set widget entry}
      fil - fiL -
      fis - fiS -
      dir - diR -
      fon - foN -
      clr - clR -
      dat - daT -
      sta -
      too -
      fra {
        # + frame for choosers and bars
        set widget ttk::frame
      }
      frA {
        set widget frame
        if {$disabled} {set attrs [::apave::removeOptions $attrs -state]}
      }
      ftx {set widget ttk::labelframe}
      gut {set widget canvas}
      lab {
        set widget ttk::label
        if {$disabled} {
          set grey [lindex [my csGet] 8]
          set attrs "-foreground $grey $attrs"
        }
        lassign [::apave::parseOptions $attrs -link {} -style {} -font {}] \
          cmd style font
        if {$cmd ne {}} {
          set attrs "-linkcom {$cmd} $attrs"
          set attrs [::apave::removeOptions $attrs -link]
        }
        if {$style eq {} && $font eq {}} {
          set attrs "-font {$::apave::FONTMAIN} $attrs"
        } elseif {$style ne {}} {
          # some themes stumble at ttk styles, so bring their attrs directly
          set attrs [::apave::removeOptions $attrs -style]
          set attrs "[ttk::style configure $style] $attrs"
        }
      }
      laB {set widget label}
      lfr {set widget ttk::labelframe}
      lfR {
        set widget labelframe
        if {$disabled} {set attrs [::apave::removeOptions $attrs -state]}
      }
      lbx - flb {
        set widget listbox
        if {$nam3 eq {flb}} {  ;# file content listbox
          set attrs [my FCfieldValues $wnamefull $attrs]
        }
        set attrs "[my FCfieldAttrs $wnamefull $attrs -lvar]"
        set attrs "[my ListboxesAttrs $wnamefull $attrs]"
        my AddPopupAttr $wnamefull attrs -entrypop 1
        foreach {ev com} {Home {::apave::LbxSelect %w 0} End {::apave::LbxSelect %w end}} {
          append attrs " -bindEC {<$ev> {$com}} "
        }
      }
      meb {set widget ttk::menubutton}
      meB {set widget menubutton}
      nbk {
        set widget ttk::notebook
        set attrs "-notebazook {$attrs}"
      }
      opc {
        ;# tk_optionCascade - example of "my method" widget
        ;# arguments: vname items mbopts precom args
        set widget {my tk_optionCascade}
        set imax [expr {min(4,[llength $attrs])}]
        for {set i 0} {$i<$imax} {incr i} {
          set atr [lindex $attrs $i]
          if {$i!=1} {
            lset attrs $i \{$atr\}
          } elseif {[llength $atr]==1 && [info exist $atr]} {
            lset attrs $i [set $atr]  ;# items stored in a variable
          }
        }
      }
      pan {set widget ttk::panedwindow
        if {[string first -w $attrs]>-1 && [string first -h $attrs]>-1} {
          # important for panes with fixed (customized) dimensions
          set attrs "-propagate {$options} $attrs"
        }
      }
      pro {set widget ttk::progressbar}
      rad {set widget ttk::radiobutton}
      raD {set widget radiobutton}
      sca {set widget ttk::scale}
      scA {set widget scale}
      sbh {set widget ttk::scrollbar}
      sbH {set widget scrollbar}
      sbv {set widget ttk::scrollbar}
      sbV {set widget scrollbar}
      scf {
        if {![namespace exists ::apave::sframe]} {
          namespace eval ::apave {
            source [file join $::apave::apaveDir sframe.tcl]
          }
        }
        # scrolledFrame - example of "my method" widget
        set widget {my scrolledFrame}
      }
      seh {set widget ttk::separator}
      sev {set widget ttk::separator}
      siz {set widget ttk::sizegrip}
      spx - spX {
        if {$nam3 eq {spx}} {set widget ttk::spinbox} {set widget spinbox}
        lassign [::apave::parseOptions $attrs \
          -command {} -com {} -from {} -to {}] cmd cmd2 from to
        append cmd $cmd2
        lassign [::apave::extractOptions attrs -tip {} -tooltip {}] t1 t2
        set t2 "$t1$t2"
        if {$from ne {} || $to ne {}} {
          if {$t2 ne {}} {set t2 "\n $t2"}
          set t2 " $from .. $to $t2"
        }
        if {$t2 ne {}} {set t2 "-tip {$t2}"}
        append attrs " -onReturn {$::apave::UFF{$cmd} {$from} {$to}$::apave::UFF} $t2"
      }
      tbl { ;# tablelist
        package require tablelist
        set widget tablelist::tablelist
        set attrs "[my FCfieldAttrs $wnamefull $attrs -lvar]"
        set attrs "[my ListboxesAttrs $wnamefull $attrs]"
      }
      tex {set widget text
        if {[::apave::getOption -textpop {*}$attrs] eq {}} {
          my AddPopupAttr $wnamefull attrs -textpop \
            [expr {[::apave::getOption -rotext {*}$attrs] ne {}}] -- disabled
        }
        lassign [::apave::parseOptions $attrs -ro {} -readonly {} -rotext {} \
          -gutter {} -gutterwidth 5 -guttershift 6] r1 r2 r3 g1 g2 g3
        set b1 [expr [string is boolean -strict $r1]]
        set b2 [expr [string is boolean -strict $r2]]
        if {($b1 && $r1) || ($b2 && $r2) || \
        ($r3 ne {} && !($b1 && !$r1) && !($b2 && !$r2))} {
          set attrs "-takefocus 0 $attrs"
        }
        set attrs [::apave::removeOptions $attrs -gutter -gutterwidth -guttershift]
        if {$g1 ne {}} {
          set attrs "$attrs -gutter {-canvas $g1 -width $g2 -shift $g3}"
        }
      }
      tre {
        set widget ttk::treeview
        foreach {ev com} {Home {::apave::TreSelect %w 0} End {::apave::TreSelect %w end}} {
          append attrs " -bindEC {<$ev> {$com}} "
        }
      }
      h_* {set widget ttk::frame}
      v_* {set widget ttk::frame}
      default {set widget $newtype}
    }
    set attrs [my GetMC $attrs]
    if {$nam3 in {cbx ent enT fco spx spX}} {
      # entry-like widgets need their popup menu
      set clearcom [lindex [::apave::parseOptions $attrs -clearcom -] 0]
      if {$clearcom eq {-}} {
        my AddPopupAttr $wnamefull attrs -entrypop 0 readonly disabled
      }
    }
    if {[string first pack [string trimleft $pack]]==0} {
      catch {
        # try to expand -after option (if set as WidgetName instead widgetName)
        if {[set i [lsearch -exact $pack {-after}]]>=0} {
          set aft [lindex $pack [incr i]]
          if {[regexp {^[A-Z]} $aft]} {
            set aft [my $aft]
            set pack [lreplace $pack $i $i $aft]
          }
        }
      }
      set options $pack
    }
    set options [string trim $options]
    set attrs   [list {*}$attrs]
    return [list $widget $options $attrs $nam3 $disabled]
  }
  #_______________________

  method defaultATTRS {{type ""} {opts ""} {atrs ""} {widget ""}} {
    # Sets, gets or registers default options and attributes for widget type.
    #   type - widget type
    #   opts - new default grid/pack options
    #   atrs - new default attributes
    #   widget - Tcl/Tk command for the new registered widget type
    # The *type* should be a three letter unique string.
    # If the *type* is absent in the registered types and *opts* and/or *atrs*
    # is not set to "", defaultATTRS registers the new *type* with its grid/pack
    # options and attributes. At that *widget* is a command for the new widget
    # type. For example, to register "toolbutton" widget:
    #   my defaultATTRS tbt {} {-style Toolbutton -compound top} ttk::button
    # Options and attributes may contain data (variables and commands)
    # to be processed by [subst].
    # Returns:
    #   - if not set *type*: a full list of options and attributes of all types
    #   - if set *type* only: a list of options, attributes and *widget*
    #   - else: a list of updated options, attributes and *widget*

    if {$type eq {}} {return $::apave::_Defaults}
    set optatr "$opts$atrs"
    if {[catch {set def1 [dict get $::apave::_Defaults $type]}]} {
      if {$optatr eq {}} {
        set err "[self method]: \"$type\" widget type not registered."
        puts -nonewline stderr $err
        return -code error $err
      }
      set def1 [list $opts $atrs $widget]
    }
    if {$optatr eq {}} {return [subst $def1]}
    lassign $def1 defopts defatrs widget
    if {[catch {set defopts [dict replace $defopts {*}$opts]}]} {
      set defopts [string trim "$defopts $opts"]
    }
    if {[catch {set defatrs [dict replace $defatrs {*}$atrs]}]} {
      set defatrs [string trim "$defatrs $atrs"]
    }
    set newval [list $defopts $defatrs $widget]
    dict set ::apave::_Defaults $type $newval
    return $newval
  }
  #_______________________

  method MC {msg} {
    # Gets localized message
    #   msg - the message

    # to use a preset namespace name, we need a fully qualified variable
    set ::apave::_MC_TEXT_ [string trim $msg \{\}]
    if {$::apave::MC_NS ne {}} {
      namespace eval $::apave::MC_NS {
        set ::apave::_MC_TEXT_ [msgcat::mc $::apave::_MC_TEXT_]
      }
    } else {
      set ::apave::_MC_TEXT_ [msgcat::mc $::apave::_MC_TEXT_]
    }
    return $::apave::_MC_TEXT_
  }
  #_______________________

  method GetMC {attrs} {
    # Gets localized -text attribute.
    #   attrs - list of attributes

    lassign [::apave::extractOptions attrs -t {} -text {}] t text
    if {$t ne {} || $text ne {}} {
      if {$text eq {}} {set text $t}
      set attrs [dict set attrs -t [my MC $text]]
    }
    return $attrs
  }
  #_______________________

  method SpanConfig {w rcnam rc rcspan opt val} {
    # The method is used by *GetIntOptions* method to configure
    # row/column for their *span* options.

    for {set i $rc} {$i < ($rc + $rcspan)} {incr i} {
      eval [grid ${rcnam}configure $w $i $opt $val]
    }
    return
  }
  #_______________________

  method GetIntOptions {w options row rowspan col colspan} {
    # Gets specific integer options. Then expands other options.
    #   w - widget's name
    #   options - grid options
    #   row, rowspan - row and its span of thw widget
    #   col, colspan - column and its span of thw widget
    # The options are set in grid options as "-rw <int>", "-cw <int>" etc.
    # Returns the resulting grid options.

    set opts {}
    foreach {opt val} [list {*}$options] {
      switch -exact -- $opt {
        -rw  {my SpanConfig $w row $row $rowspan -weight $val}
        -cw  {my SpanConfig $w column $col $colspan -weight $val}
        -rsz {my SpanConfig $w row $row $rowspan -minsize $val}
        -csz {my SpanConfig $w column $col $colspan -minsize $val}
        -ro  {my SpanConfig $w column $col $colspan -readonly $val}
        default {append opts " $opt $val"}
      }
    }
    # Get other grid options
    return [my ExpandOptions $opts]
  }
  #_______________________

  method GetAttrs {options {nam3 ""} {disabled 0} } {
    # Expands attributes' values.
    #   options - list of attributes and values
    #   nam3 - first three letters (type) of widget's name
    #   disabled - flag of "disabled" state
    # Returns expanded attributes.

    set opts [list]
    foreach {opt val} [list {*}$options] {
      switch -exact -- $opt {
        -t - -text {
          ;# these options need translating \\n to \n
          # catch {set val [subst -nocommands -novariables $val]}
          set val [string map [list \\n \n \\t \t] $val]
          set opt -text
        }
        -st {set opt -sticky}
        -com {set opt -command}
        -w {set opt -width}
        -h {set opt -height}
        -var {set opt -variable}
        -tvar {set opt -textvariable}
        -lvar {set opt -listvariable}
        -ro {set opt -readonly}
      }
      lappend opts $opt \{$val\}
    }
    if {$disabled} {
      append opts [my NonTtkStyle $nam3 1]
    }
    return $opts
  }
  #_______________________

  method menuTips {win tip {wpar {}}} {
    # Makes tip(s) for menu and its items.
    #   win - menu's path
    #   tip - tip's text
    #   wpar - path to menu's parent (for opc widget)
    # The tips for menu items are set by "-indexedtips ?idx tip...?"
    # e.g., a tip can be "parent tip -indexedtips 0 1stItem 9 {10th Item}"

    if {$tip ne {}} {
      set tip [my MC $tip]
      if {[set i [string first {-indexedtips } $tip]]>-1} {
        set indexedtips [string range $tip [string first { } $tip $i]+1 end]
        set tip [string range $tip 0 $i-1]
      } else {
        set indexedtips {}
      }
      # \indexedtips to present -indexedtips in parent tip
      set tip [string map "\\indexedtips -indexedtips" $tip]
      catch {
        # tips for indexed items of menu
        while {$indexedtips ne {}} {
          lassign $indexedtips idx itip
          if {$idx eq {}} break
          after idle [list ::baltip tip $win $itip -index $idx]
          set indexedtips [lrange $indexedtips 2 end]
        }
      }
      if {$tip ne {} && $wpar ne {}} {
        after idle [list ::baltip tip $wpar $tip]  ;# tip for the parent widget
      }
    }
  }

  ## ________________________ Option cascade _________________________ ##

  method optionCascadeText {it} {
    # Rids a tk_optionCascade item of braces.
    #   it - an item to be trimmed
    # Reason: tk_optionCascade items shimmer between 'list' and 'string'
    # so a multiline item is displayed with braces, if not got rid of them.
    # Returns the item trimmed.
    # See also: tk_optionCascade

    if {[string match "\{*\}" $it]} {
      set it [string range $it 1 end-1]
    }
    return $it
  }
  #_______________________

  method tk_optionCascade {w vname items {mbopts ""} {precom ""} args} {
    # A bit modified tk_optionCascade widget made by Richard Suchenwirth.
    #   w      - widget name
    #   vname  - variable name for current selection
    #   items  - list of items
    #   mbopts - ttk::menubutton options (e.g. "-width -4")
    #   precom - command to get entry's options (%a presents its label)
    #   args   - additional options of entries
    # Returns a path to the widget.
    # See also:
    #   optionCascadeText
    #   [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/tk_optionCascade)

    set win $w.m
    if {![info exists $vname]} {
      set it [lindex $items 0]
      while {[llength $it]>1} {set it [lindex $it 0]}
      set it [my optionCascadeText $it]
      set $vname $it
    }
    lassign [::apave::extractOptions mbopts -tip {} -tooltip {} -com {} -command {}] \
      tip tip2 com com2
    if {$tip eq {}} {set tip $tip2}
    if {$com eq {}} {set com $com2}
    if {$com ne {}} {lappend args -command $com}
    ttk::menubutton $w -menu $win -text [set $vname] -style TMenuButtonWest {*}$mbopts
    menu $win -tearoff 0
    my menuTips $win $tip $w
    my OptionCascade_add $win $vname $items $precom {*}$args
    trace var $vname w \
      "$w config -text \"\[[self] optionCascadeText \${$vname}\]\" ;\#"
    lappend ::apave::_AP_VARS(_TRACED_$w) $vname
    ::apave::bindToEvent $w <ButtonPress> focus $w
    return $win
  }
  #_______________________

  method OptionCascade_add {w vname argl precom args} {
    # Adds tk_optionCascade items recursively.
    #   w      - tk_optionCascade widget's name
    #   vname  - variable name for current selection
    #   arg1   - list of items to be added
    #   precom - command to get entry's options (%a presents its label)
    #   args   - additional options of entries

    set n [set colbreak 0]
    foreach arg $argl {
      if {$arg eq {--}} {
        $w add separator
      } elseif {$arg eq {|}} {
        if {[tk windowingsystem] ne {aqua}} { set colbreak 1 }
        continue
      } elseif {[llength $arg] == 1} {
        set label [my optionCascadeText [join $arg]]
        if {$precom eq {}} {
          set adds {}
        } else {
          set adds [eval {*}[string map [list \$ \\\$ \[ \\\[] \
            [string map [list %a $label] $precom]]]
        }
        $w add radiobutton -label $label -variable $vname {*}$args {*}$adds
      } else {
        set child [menu $w.[incr n] -tearoff 0]
        $w add cascade -label [lindex $arg 0] -menu $child
        my OptionCascade_add $child $vname [lrange $arg 1 end] $precom {*}$args
      }
      if $colbreak {
        $w entryconfigure end -columnbreak 1
        set colbreak 0
      }
    }
    return
  }
  #_______________________

  method ParentOpt {{w "."}} {
    # Gets *-parent* option for choosers.
    #   w - parent window's name (path)

    if {$Modalwin ne {.}} {set w $Modalwin}
    return "-parent $w"
  }

  ## ________________________ Mega-widgets _________________________ ##

  method fillGutter {txt {canvas ""} {width ""} {shift ""} args} {
    # Fills a gutter of text with the text's line numbers.
    #  txt - path to the text widget
    #  canvas - canvas of the gutter
    #  width - width of the gutter, in chars
    #  shift - addition to the width (to shift from the left side)
    #  args - additional arguments for tracing
    # The code is borrowed from open source tedit project.

    set savedcont [namespace current]::gc$txt
    if {![winfo exists $txt] || ![winfo ismapped $txt]} {
      unset -nocomplain $savedcont
      return
    }
    if {$canvas eq {}} {
      event generate $txt <Configure> ;# repaints the gutter
      return
    }
    set oper [lindex $args 0 1]
    if {![llength $args] || [lindex $args 0 4] eq {-elide} || \
    $oper in {configure delete insert see yview}} {
      set i [$txt index @0,0]
      set gcont [list]
      while true {
        set dline [$txt dlineinfo $i]
        if {[llength $dline] == 0} break
        set height [lindex $dline 3]
        set y [expr {[lindex $dline 1]}]
        set linenum [format "%${width}d" [lindex [split $i .] 0]]
        set i [$txt index "$i +1 lines linestart"]
        lappend gcont [list $y $linenum]
      }
      # update the gutter at changing its contents/config
      if {[::apave::cs_Active]} {
        lassign [my csGet] - - - bg - - - - fg
        ::apave::setProperty _GUTTER_FGBG [list $fg $bg]
      } else {
        lassign [::apave::getProperty _GUTTER_FGBG] fg bg
      }
      set cwidth [expr {$shift + \
        [font measure apaveFontMono -displayof $txt [string repeat 0 $width]]}]
      set newbg [expr {$bg ne [$canvas cget -background]}]
      set newwidth [expr {$cwidth ne [$canvas cget -width]}]
      if {![llength $args] || $newbg || $newwidth || ![info exists $savedcont] || \
      $gcont ne [set $savedcont]} {
        if {$newbg} {$canvas config -background $bg}
        if {$newwidth} {$canvas config -width $cwidth}
        $canvas delete all
        foreach g $gcont {
          lassign $g y linenum
          $canvas create text 2 $y -anchor nw -text $linenum -font apaveFontMono -fill $fg
        }
        set $savedcont $gcont
      }
    }
  }
  #_______________________

  method gutterContents {txt} {
    # Gets contents of a text's gutter
    #   txt - text's path

    set savedcont [namespace current]::gc$txt
    if {[info exists $savedcont]} {
      return [set $savedcont]
    }
    return {}
  }
  #_______________________

  method AuxSetChooserGeometry {vargeo vargeo2 parent widname} {
    # Auxiliary method to set some Tk choosers' geometry.
    #   vargeo - variable for geometry value
    #   vargeo2 - variable for geometry value with second type of dialogue
    #   parent - list containing a parent's path
    #   widname - name of the chooser
    # If there is no saved geometry with *vargeo*, tries to get it with *vargeo2*.
    # Returns a path to the chooser to be open.

    set wp [lindex $parent 1]
    set wchooser $wp.$widname
    set geom {}
    if {[catch {lassign [set $vargeo] -> geom}] || $geom eq {}} {
      # no saved geometry with *vargeo*, so get it with *vargeo2*
      catch {lassign [set $vargeo2] -> geom}
    }
    if {![string match *x*+*+* $geom]} {
      # chooser's default geometry centered in parent
      if {![winfo exists $wp]} {set wp .}
      set geom [set W 640]x[set H 470]
      append geom [my CenteredXY {*}[split [wm geometry $wp] x+] $W $H]
    }
    if {[::isunix] && ![package vsatisfies [package require Tk] 9.0-]} {
      # the below equilibristics provides the smooth display
      after idle "catch {wm withdraw $wchooser; wm geometry $wchooser 1x1}"
      after 0 [list after idle \
        "catch {wm withdraw $wchooser; wm geometry $wchooser $geom; wm deiconify $wchooser}; wm geometry $wchooser $geom"]
    }
    return $wchooser
  }
  #_______________________

  method validateColorChoice {lab {ent ""}} {
    # Displays a current color of color chooser's entry.
    #   lab - color chooser's label (or apave name's clr1 / Clr1)
    #   ent - color chooser's entry
    # Can be called as "validateColorChoice clr1 / Clr1".

    if {[string match -nocase clr* $lab]} {
      set lab [string tolower [string index $lab 0]][string range $lab 1 end]
      set ent Ent$lab
      set lab Lab$lab
    }
    set ent [my [my ownWName $ent]]
    set lab [my [my ownWName $lab]]
    set val [$ent get]
    catch {$lab configure -background $val}
    catch {$ent selection clear}
    return yes
  }
  #_______________________

  method scrolledFrame {w args} {
    # Retrieves the path where the scrollable contents of frame go.
    #   w - frame's path

    lassign [::apave::extractOptions args -toplevel no -anchor center -mode both] tl anc mode
    ::apave::sframe new $w -toplevel $tl -anchor $anc -mode $mode
    set path [::apave::sframe content $w]
    return $path
  }
  #_______________________

  method chooserGeomVars {{dirvar ""} {filevar ""}} {
    # Sets/gets variables to save/restore geometry of Tcl/Tk dir/file choosers (in Linux).
    #   dirvar - variable's name for geometry of directory chooser
    #   filevar - variable's name for geometry of file chooser
    # See also: chooser

    if {$dirvar eq {}} {
      return [::apave::getProperty DirFilGeoVars]
    }
    ::apave::setProperty DirFilGeoVars [list $dirvar $filevar]
  }
  #_______________________

  method chooser {nchooser tvar args} {
    # Chooser (for all available types).
    #   nchooser - name of chooser
    #   tvar - name of variable containing an input/output value
    #   args - options of the chooser
    # The chooser names are:
    #   tk_getOpenFile - choose a file to open
    #   tk_getSaveFile - choose a file to save
    #   tk_chooseDirectory - choose a directory
    #   fontChooser - choose a font
    #   dateChooser - choose a date
    #   colorChooser - choose a color
    #   ftx_OpenFile - (internal) choose a file for ftx widget
    # Returns a selected value.

    set isfilename [set rootname 0]
    lassign [::apave::extractOptions args \
      -ftxvar {} -tname {} -bname {} -parent {}] ftxvar tname bname parent
    if {$parent ne {}} {
      set parent "-parent $parent"
    } else {
      set parent [my ParentOpt]
    }
    lassign [my chooserGeomVars] dirvar filvar
    if {$dirvar eq {}} {
      set [set dirvar ::apave::APaveDirVar] {}
      set [set filvar ::apave::APaveFilVar] {}
      my chooserGeomVars $dirvar $filvar
    }
    set vargeo {}
    if {$nchooser eq {ftx_OpenFile}} {
      set nchooser tk_getOpenFile
    }
    set widname {}
    set choosname $nchooser
    if {$choosname in {fontChooser colorChooser dateChooser}} {
      set nchooser "my $choosname $tvar $parent $args"
    } elseif {$choosname in {tk_getOpenFile tk_getSaveFile}} {
      set vargeo $filvar
      set widname [my AuxSetChooserGeometry $vargeo $dirvar $parent __tk_filedialog]
      if {[set fn [set $tvar]] eq {}} {
        set dn [pwd]
      } else {
        set dn [file dirname $fn]
        set fn [file tail $fn]
      }
      set dn [::apave::extractOptions args -initialdir $dn]
      if {[string match -* $dn]} {
        set rootname 1
        set dn [string range $dn 1 end]
      }
      set args "-initialfile \"$fn\" -initialdir $dn $parent $args"
      incr isfilename
    } elseif {$nchooser eq {tk_chooseDirectory}} {
      set vargeo $dirvar
      set widname [my AuxSetChooserGeometry $vargeo $filvar $parent __tk_choosedir]
      set args "-initialdir \"[set $tvar]\" $parent $args"
      incr isfilename
    }
    if {[::isunix] && $choosname ne {dateChooser}} {
      my themeExternal *.foc.* *f1.demo  ;# don't touch tkcc's boxes
    }
    set res [{*}$nchooser {*}$args]
    if {"$res" ne {} && "$tvar" ne {}} {
      if {$rootname} {set res [file rootname [file tail $res]]}
      if {$isfilename} {
        lassign [my SplitContentVariable $ftxvar] -> txtnam wid
        if {[info exist $ftxvar] && \
        [file exist [set res [file nativename $res]]]} {
          set $ftxvar [::apave::readTextFile $res]
          if {[winfo exist $txtnam]} {
            my readonlyWidget $txtnam no
            my displayTaggedText $txtnam $ftxvar
            my readonlyWidget $txtnam yes
            set wid [string range $txtnam 0 [string last . $txtnam]]$wid
            $wid configure -text "$res"
            ::tk::TextSetCursor $txtnam 1.0
            update
          }
        }
      }
      set $tvar $res
    }
    if {$vargeo ne {} && $widname ne {} && [::isunix]} {
      catch {
        set $vargeo [list $widname [wm geometry $widname]]  ;# 1st item for possible usage only
      }
    }
    if {$tname ne {}} {
      set tname [my [my ownWName $tname]]
      if {$bname ne {}} {
        # re-focus to fire invalidation of the entry (esp. for Windows)
        set ent [my ownWName $tname]
        set but [my ownWName $bname]
        set bname [string map [list .$ent .$but] $tname]
        focus $bname
      }
      focus $tname
      after idle "$tname selection range 0 end ; $tname icursor end"
    }
    return $res
  }
  #_______________________

  method colorChooser {tvar args} {
    # Color chooser.
    #   tvar - name of variable containing a color
    #   args - options of *tk_chooseColor*
    # The *tvar* sets the value of *-initialcolor* option. Also
    # it gets a color selected in the chooser.
    # Returns a selected color.

    if {$Initialcolor eq {} && [::isunix]} {
      source [file join $::apave::apaveDir pickers color clrpick.tcl]
    }
    lassign [::apave::extractOptions args -entry {} -inifile {}] ent ini
    if {$ent ne {}} {
      set ent [my [my ownWName $ent]]
      set x [winfo rootx $ent]
      set y [expr {[winfo rooty $ent]+32}]
      dict set args -geometry +$x+$y  ;# the same as with date picker
    }
    if {[set _ [string trim [set $tvar]]] ne {}} {
      set ic $_
      set _ [. cget -background]
      if {[catch {. configure -background $ic}]} {
        set ic "#$ic"
        if {[catch {. configure -background $ic}]} {set ic black}
      }
      set Initialcolor $ic
      . configure -background $_
    } else {
      set Initialcolor black
    }
    if {[catch {lassign [tk_chooseColor -moveall $Moveall \
    -initialcolor $Initialcolor {*}$args -inifile $ini] res Moveall}]} {
      set args [::apave::removeOptions $args -moveall -tonemoves -geometry]
      set res [tk_chooseColor -initialcolor $Initialcolor {*}$args]
    }
    if {$res ne {}} {
      set Initialcolor [set $tvar $res]
    }
    return $res
  }
  #_______________________

  method sourceKlnd {{num ""}} {
    # Loads klnd package at need.
    #   num - defines which name of package file to be used

    if {[info commands ::klnd::calendar$num] eq {}} {
      # imo, it's more effective to source on request than to require on possibility
      source [file join $::apave::apaveDir pickers klnd klnd$num.tcl]
    }
  }
  #_______________________

  method dateChooser {tvar args} {
    # Date chooser (calendar widget).
    #   tvar - name of variable containing a date
    #   args - options of *::klnd::calendar*
    # Returns a selected date.

    my sourceKlnd {}
    if {![catch {set ent [my [my ownWName [::apave::getOption -entry {*}$args]]]}]} {
      dict set args -entry $ent
      set res [::klnd::calendar {*}$args -tvar $tvar -parent [winfo toplevel $ent]]
    } else {
      set res [::klnd::calendar {*}$args -tvar $tvar]
    }
    return $res
  }
  #_______________________

  method Replace_Tcl {r1 r2 r3 args} {
    # Replaces Tcl code with its resulting items in *lwidgets* list.
    #   r1 - variable name for a current index in *lwidgets* list
    #   r2 - variable name for a length of *lwidgets* list
    #   r3 - variable name for *lwidgets* list
    #   args - "tcl" and "tcl code" for "tcl" type of widget
    # The code should use the wildcard that goes first at a line:
    #   %C - a command for inserting an item into lwidgets list.
    # The "tcl" widget type can be useful to automate the inserting
    # a list of similar widgets to the list of widgets.
    # See tests/test2_pave.tcl where the "tcl" fills "Color schemes" tab.

    lassign $args _name _code
    if {[my ownWName $_name] ne {tcl}} {return $args}
    upvar 1 $r1 _ii $r2 _lwlen $r3 _lwidgets
  ; proc lwins {lwName i w} {
      upvar 2 $lwName lw
      set lw [linsert $lw $i $w]
    }
    set _lwidgets [lreplace $_lwidgets $_ii $_ii]  ;# removes tcl item
    set _inext [expr {$_ii-1}]
    eval [string map {%C {lwins $r3 [incr _inext] }} $_code]
    return {}
  }
  #_______________________

  method Replace_chooser {r0 r1 r2 r3 args} {
    # Replaces an item for a chooser with two items.
    #   r0 - variable name for a widget's name
    #   r1 - variable name for a current index in *lwidgets* list
    #   r2 - variable name for a length of *lwidgets* list
    #   r3 - variable name for *lwidgets* list
    #   args - the widget item of *lwidgets* list
    # Choosers should contain 2 fields: entry + button.
    # Here every chooser is replaced with these two widgets.

    upvar 1 $r0 w $r1 i $r2 lwlen $r3 lwidgets
    lassign $args name neighbor posofnei rowspan colspan options1 attrs1
    lassign {} wpar view addattrs addattrs2
    set tvar [::apave::getOption -tvar {*}$attrs1]
    lassign [::apave::extractOptions attrs1 \
      -takefocus 0 -showcolor {} -filetypes {} -initialdir {} -initialfile {} \
      -defaultextension {} -multiple {} -validatecommand {}] \
      takefocus showcolor filetypes initialdir initialfile \
      defaultextension multiple validatecommand
    lassign [::apave::extractOptions options1 -padx 0 -pady 0] padx pady
    set takefocus "-takefocus $takefocus"
    foreach atr {filetypes initialdir initialfile defaultextension multiple} {
      set val [set $atr]
      if {$val ne {}} {
        lset args 6 $attrs1
        append addattrs2 " -$atr {$val}"
      }
    }
    set an [set entname {}]
    lassign [my LowercaseWidgetName $name] n
    set ownname [my ownWName $n]
    set wtyp [string range $ownname 0 2]
    switch -exact $wtyp {
      daT { ;# embed calendar widgets into $ownname frame
        my sourceKlnd
        my sourceKlnd 2
        set attrs1 [subst $attrs1]
        set lwidgets2 [::klnd::calendar2 [self] $w $n {*}$attrs1]
        set lwlen2 [llength $lwidgets2]
        for {set i2 0} {$i2 < $lwlen2} {} {
          set lst2 [lindex $lwidgets2 $i2]
          if {[my Replace_Tcl i2 lwlen2 lwidgets2 {*}$lst2] ne {}} {incr i2}
        }
        incr lwlen [llength $lwidgets2]
        set lwidgets [linsert $lwidgets [expr {$i+1}] {*}$lwidgets2]
        lset args 6 [::klnd::clearArgs {*}$attrs1]
        return $args
      }
      fil - fiL {set chooser tk_getOpenFile}
      fis - fiS {set chooser tk_getSaveFile}
      dir - diR {set chooser tk_chooseDirectory}
      fon - foN {set chooser fontChooser}
      clr - clR {
        set chooser colorChooser
        if {$showcolor eq {}} {set showcolor 1} ;# default is "show color label"
        set showcolor [string is true -strict $showcolor]
        set wpar "-parent $w" ;# specific for color chooser (parent of $w)
        set entname {-entry }
      }
      dat {set chooser dateChooser; set entname {-entry }}
      ftx {
        set chooser [set view ftx_OpenFile]
        if {$tvar ne {} && [info exist $tvar]} {
          append addattrs " -t {[set $tvar]}"
        }
        set an tex
        set txtnam [my Transname $an $name]
      }
      default {
        return $args
      }
    }
    set inname [my MakeWidgetName $w $name $an]
    set name $n
    if {$view ne {}} {
      set tvname $inname
      set inname [my WidgetNameFull $w $name]
    }
    set tvar [set vv [set addopt {}]]
    set attmp [list]
    foreach {nam val} $attrs1 {
      if {$nam in {-title -parent -dateformat -weekday -modal -centerme}} {
        append addopt " $nam \{$val\}"
      } else {
        lappend attmp $nam $val
      }
    }
    set attrs1 $attmp
    catch {array set a $attrs1; set tvar "-tvar [set vv $a(-tvar)]"}
    catch {array set a $attrs1; set tvar "-tvar [set vv $a(-textvariable)]"}
    if {$vv eq {}} {
      set vv [namespace current]::$name
      set tvar "-tvar $vv"
    }
    # make a frame in the widget list
    set ispack 0
    if {![catch {set gm [lindex [lindex $lwidgets $i] 5]}]} {
      set ispack [expr [string first pack $gm]==0]
    }
    if {$ispack} {
      lassign [::apave::parseOptions $options1 -expand 0 -fill x] exp fil
      set args [list $name - - - - \
        "pack -expand $exp -fill $fil [string range $gm 5 end]" $addattrs]
    } else {
      lassign [::apave::parseOptions $options1 -st ew -sticky {} -rw {} -cw {}] st st2 rw cw
      if {$st2 ne {}} {set st $st2}
      if {$rw ne {}} {set rw "-rw $rw"}
      if {$cw ne {}} {set cw "-cw $cw"}
      set args [list $name $neighbor $posofnei $rowspan $colspan \
        "-st $st $rw $cw" $addattrs]
    }
    lset lwidgets $i $args
    set btTname [my Transname btT $name]
    if {$view ne {}} {
      append attrs1 " -callF2 {.texF .btTf .texf .btTf}"
      set tvar [::apave::getOption -tvar {*}$attrs1]
      set attrs1 [::apave::removeOptions $attrs1 -tvar]
      if {$tvar ne {} && [file exist [set $tvar]]} {
        set tcont [my SetContentVariable $tvar $tvname [my ownWName $name]]
        set wpar "-ftxvar $tcont"
        set $tcont [::apave::readTextFile [set $tvar]]
        set attrs1 [::apave::putOption -rotext $tcont {*}$attrs1]
      }
      set entf [list $txtnam - - - - "pack -side top -expand 1 -fill both -in $inname" "$attrs1"]
    } else {
      if {$wtyp in {fiL fiS diR foN clR}} {
        set field cbx
        set tname [my Transname Cbx $name]
      } else {
        set tname [my Transname Ent $name]
        set field ent
      }
      if {$entname ne {}} {append entname $tname}
      append attrs1 " -callF2 {.$field .btT}"
      append wpar " -tname $tname -bname $btTname"
      if {$chooser eq {fontChooser}} {
        append wpar " -parent \[[self] [my ownWName $tname]\]"
      }
      set entf [list $tname - - - - "pack -padx $padx -pady $pady -side left -expand 1 -fill x -in $inname" "$attrs1 $tvar"]
    }
    set icon folder
    foreach ic {OpenFile SaveFile font color date} {
      if {[string first $ic $chooser] >= 0} {set icon $ic; break}
    }
    set com "[self] chooser $chooser \{$vv\} $addopt $wpar $addattrs2 $entname"
    if {$view ne {}} {set anc n} {set anc center}
    set butf [list $btTname - - - - "pack -side right -anchor $anc -in $inname -padx 2" "-com \{$com\} -compound none -image [::apave::iconImage $icon small] -font \{-weight bold -size 5\} -fg $Fgbut -bg $Bgbut $takefocus"]
    if {$view ne {}} {
      set scrolv [list [my Transname sbv $name] $txtnam L - - "pack -in $inname -side bottom -after [my WidgetNameFull $w $btTname]" {}]
      set lwidgets [linsert $lwidgets [expr {$i+1}] $butf]
      set lwidgets [linsert $lwidgets [expr {$i+2}] $entf]
      set lwidgets [linsert $lwidgets [expr {$i+3}] $scrolv]
      incr lwlen 3
      set wrap [::apave::getOption -wrap {*}$attrs1]
      if {$wrap eq {none}} {
        set scrolh [list [my Transname sbh $name] $txtnam T - - "pack -in $inname -side bottom -after [my WidgetNameFull $w $txtnam]" {}]
        set lwidgets [linsert $lwidgets [expr {$i+3}] $scrolh]
        incr lwlen
      }
    } else {
      if {$chooser eq {colorChooser} && $showcolor} {
        set f0 [my Transname Lab $name]
        set labf [list $f0 - - - - "pack -side right -in $inname -padx 2" \
          "-t \{    \} -relief raised"]
        lassign $entf f1 - - - - f2 f3
        set com "[self] validateColorChoice $f0 $f1"
        append f3 " -afteridle \"$com; bind \[string map \{.entclr .labclr\} %w\] <ButtonPress> \{eval \[string map \{.entclr .btTclr\} %w\] invoke\}\""
        append f3 " -validate all -validatecommand \{$com ; $validatecommand\}"
        set entf [list $f1 - - - - $f2 $f3]
        set lwidgets [linsert $lwidgets [expr {$i+1}] $entf $butf $labf]
        incr lwlen 3
      } else {
        set lwidgets [linsert $lwidgets [expr {$i+1}] $entf $butf]
        incr lwlen 2
      }
    }
    return $args
  }
  #_______________________

  method Replace_bar {r0 r1 r2 r3 args} {
    # Replaces an item for a menu/tool/status bar with appropriate items.
    #   r0 - variable name for a widget's name
    #   r1 - variable name for a current index in *lwidgets* list
    #   r2 - variable name for a length of *lwidgets* list
    #   r3 - variable name for *lwidgets* list
    #   args - the widget item of *lwidgets* list
    # Bar widgets should contain N fields of appropriate type

    upvar 1 $r0 w $r1 i $r2 lwlen $r3 lwidgets
    if {[catch {set winname [winfo toplevel $w]}]} {
      return $args
    }
    lassign $args name neighbor posofnei rowspan colspan options1 attrs1
    my MakeWidgetName $w $name
    set name [lindex [my LowercaseWidgetName $name] 0]
    set wpar {}
    switch -glob -- [my ownWName $name] {
      men* {set typ menuBar}
      too* {set typ toolBar}
      sta* {set typ statusBar}
      default {
        return $args
      }
    }
    set attcur [list]
    set namvar [list]
    # get array of pairs (e.g. image-command for toolbar)
    foreach {nam val} $attrs1 {
      if {$nam eq {-array}} {
        catch {set val [subst $val]}
        set ind -1
        foreach {v1 v2} $val {
          catch {set v1 [subst -nocommand -nobackslash $v1]}
          catch {set v2 [subst -nocommand -nobackslash $v2]}
          if {$name eq {menu}} {set v2 [list [my MC $v2]]}
          lappend namvar [namespace current]::$typ[incr ind] $v1 $v2
        }
      } else {
        lappend attcur $nam $val
      }
    }
    # make a frame in the widget list
    if {$typ eq {menuBar}} {
      if {[set fillmenu [lindex $args 7]] ne {}} {
        after idle $fillmenu
      }
      set args {}
    } else {
      set ispack 0
      if {![catch {set gm [lindex [lindex $lwidgets $i] 5]}]} {
        set ispack [expr [string first pack $gm]==0]
      }
      if {$ispack} {
        set args [list $name - - - - "pack -expand 0 -fill x -side bottom [string range $gm 5 end]" $attcur]
      } else {
        set args [list $name $neighbor $posofnei $rowspan $colspan "-st ew" $attcur]
      }
      lset lwidgets $i $args
    }
    set itmp $i
    set k [set j [set j2 [set wasmenu 0]]]
    foreach {nam v1 v2} $namvar {
      if {[string first # $v1]==0} continue
      if {$v1 eq {h_}} {  ;# horisontal space
        set ntmp [my Transname fra ${name}[incr j2]]
        set wid1 [list $ntmp - - - - "pack -side left -in $w.$name -fill y"]
        set wid2 [list $ntmp.[my ownWName [my Transname h_ $name$j]] - - - - "pack -fill y -expand 1 -padx $v2"]
      } elseif {$v1 eq {sev}} {   ;# vertical separator
        set ntmp [my Transname fra ${name}[incr j2]]
        set wid1 [list $ntmp - - - - "pack -side left -in $w.$name -fill y"]
        set wid2 [list $ntmp.[my ownWName [my Transname sev $name$j]] - - - - "pack -fill y -expand 1 -padx $v2"]
      } elseif {$typ eq {statusBar}} {  ;# statusbar
        my NormalizeName name i lwidgets
        set dattr [lrange $v1 1 end]
        if {[::apave::extractOptions dattr -expand 0]} {
          set expand {-expand 1 -fill x}
        } else {
          set expand {}
        }
        set font " -font {[my basicSmallFont]}"
        # status prompt
        set wid1 [list .[my ownWName [my Transname Lab ${name}_[incr j]]] - - - - "pack -side left -in $w.$name" "-t {[lindex $v1 0]} $font $dattr"]
        # status value
        if {$::apave::_CS_(LABELBORDER)} {set relief sunken} {set relief flat}
        set wid2 [list .[my ownWName [my Transname Lab $name$j]] - - - - "pack -side left $expand -in $w.$name" "-style TLabelSTD -relief $relief -w $v2 -t { } $font $dattr"]
      } elseif {$typ eq {toolBar}} {  ;# toolbar
        set packreq {}
        switch -nocase -glob -- $v1 {
          lab* - laB* { ;# label
            lassign $v2 txt packreq att
            set v2 "-text {$txt} $att"
          }
          opc* { ;# tk_optionCascade
            lset v2 2 "[lindex $v2 2] -takefocus 0"
          }
          spx* - chb* { ;# spinbox etc.
            set v2 "$v2 -takefocus 0"
          }
          default {
            if {[string is lower [string index $v1 0]]} { ;# button with -image
              set but buT
            } else {
              set but BuT
            }
            lassign [my csGet] fga fg bga bg
            if {[string match _* $v1]} {
              set font [my boldTextFont 16]
              set img "-font {$font} -foreground $fg -background $bg -width 2 -pady 0 -padx 2"
            } else {
              set img "-image $v1 -background $bg"
            }
            set v2 "$img -command $v2 -relief flat -overrelief raised -activeforeground $fga -activebackground $bga -highlightthickness 0 -takefocus 0"
            lassign [::apave::extractOptions v2 -method {}] ismeth
            set v1 [my Transname $but _$v1]
            if {[string is true -strict $ismeth]} {
              # -method option forces making "WidgetName" method from "widgetName"
              my MakeWidgetName $w.$name [string totitle $v1 0 0]
            }
          }
        }
        set wid1 [list $name.$v1 - - - - "pack -side left $packreq" $v2]
        if {[incr wasseh]==1} {
          ;# horiz.separator for multiline toolbar
          set wid2 [list [my Transname seh $name$j] - - - - "pack -side top -fill x"]
        } else {
          ;# 1st line of toolbar
          set lwidgets [linsert $lwidgets [incr itmp] $wid1]
          continue
        }
      } elseif {$typ eq {menuBar}} {
        ;# menubar: making it here; filling it outside of 'pave window'
        if {[incr wasmenu]==1} {
          set menupath [my MakeWidgetName $winname $name]
          menu $menupath -tearoff 0
        }
        set menuitem [my MakeWidgetName $menupath $v1]
        menu $menuitem -tearoff 0
        set ampos [string first & [string trimleft $v2  \{]]
        set v2 [string map {& {}} $v2]
        $menupath add cascade -label [lindex $v2 0] {*}[lrange $v2 1 end] -menu $menuitem -underline $ampos
        continue
      } else {
        error "\npaveme.tcl: erroneous \"$v1\" for \"$nam\"\n"
      }
      set lwidgets [linsert $lwidgets [incr itmp] $wid1 $wid2]
      incr itmp
    }
    if {$wasmenu} {
      $winname configure -menu $menupath
    }
    incr lwlen [expr {$itmp - $i}]
    return $args
  }
  #_______________________

  method fontChooser {tvar args} {
    # Font chooser.
    #   tvar - name of variable containing a font
    #   args - options of *tk fontchooser*
    # The *tvar* sets the value of *-font* option. Also
    # it gets a font selected in the chooser.
    # Returns a selected font.

    set parw [::apave::parseOptions $args -parent [::apave::rootModalWindow .]]
  ; proc [namespace current]::applyFont {font} " \
      set $tvar \[font actual \$font\]; \
      focus -force $parw"
    set font [set $tvar]
    if {$font eq {}} {
      catch {font create fontchoose {*}$::apave::FONTMAIN}
    } else {
      catch {font delete fontchoose}
      catch {font create fontchoose {*}[font actual $font]}
    }
    tk fontchooser configure -font fontchoose {*}[my ParentOpt] \
      {*}$args -command [namespace current]::applyFont
    set res [tk fontchooser show]
    # core Tk font chooser is bad with focusing in and out, it isn't modal
    if {[set foc [info commands *__tk__fontchooser.ok]] ne {}} {
      after idle [list after 0 [list catch "focus -force $foc"]]
    }
    return [set $tvar] ;#$font
  }

  ## ________________________ Widget names & methods _________________________ ##

  method Transname {typ name} {
    # Transforms *name* by adding *typ* (its type).
    #   typ - type of widget in *apave* terms (but, buT etc.)
    #   name - name (path) of widget
    # Returns the transformed name.

    if {[set pp [string last . $name]]>-1} {
      set name [string range $name 0 $pp]$typ[string range $name $pp+1 end]
    } else {
      set name $typ$name
    }
    return $name
  }
  #_______________________

  method LowercaseWidgetName {name} {
    # Makes the widget name lowercased.
    #   name - widget's name
    # The widgets of widget list can have uppercased names which
    # means that the appropriate methods will be created to access
    # their full pathes with a command `my Name`.
    # This method gets a "normal" name of widget accepted by Tk.
    # See also: MakeWidgetName

    set root [my ownWName $name]
    return [list [string range $name 0 [string last . $name]][string tolower $root 0 0] $root]
  }
  #_______________________

  method NormalizeName {refname refi reflwidgets} {
    # Gets the real name of widget from *.name*.
    #   refname - variable name for widget name
    #   refi - variable name for index in widget list
    #   reflwidgets - variable name for widget list
    # The *.name* means "child of some previous" and should be normalized.
    # Example:
    #   If parent: fra.fra .....
    #      child: .but
    #   => normalized: fra.fra.but

    upvar $refname name $refi i $reflwidgets lwidgets
    set wname $name
    if {[string index $name 0] eq {.}} {
      for {set i2 [expr {$i-1}]} {$i2 >=0} {incr i2 -1} {
        lassign [lindex $lwidgets $i2] name2
        if {[string index $name2 0] ne {.}} {
          set name2 [lindex [my LowercaseWidgetName $name2] 0]
          set wname "$name2$name"
          set name [lindex [my LowercaseWidgetName $name] 0]
          set name "$name2$name"
          break
        }
      }
    }
    return [list $name $wname]
  }
  #_______________________

  method WidgetNameFull {w name {an {}}} {
    # Gets a full name of a widget.
    #   w - name of root widget
    #   name - name of widget
    #   an - additional prefix for name
    # See also: apave::sframe::content

    set wn [string trim [my parentWName $name].$an[my ownWName $name] .]
    set wnamefull $w.$wn
    set wcc canvas.container.content ;# sframe.tcl may be not sourced
    if {[set i1 [string first .scf $wnamefull]]>0 && \
    [set i2 [string first . $wnamefull $i1+1]]>0 && \
    [string first .$wcc. $wnamefull]<0} {
      # insert a container's name into a scrolled frame's child
      set wend [string range $wnamefull $i2 end]
      set wnamefull [string range $wnamefull 0 $i2]
      append wnamefull $wcc $wend
    }
    return $wnamefull
  }
  #_______________________

  method dlgPath {} {
    # Gets a window name of apave open dialogue.

    if {[catch {set res $Dlgpath}] || $Dlgpath eq {}} {
      set res $::apave::MODALWINDOW
    }
    return $res
  }
  #_______________________

  method DiaWidgetName {w} {
    # Gets a widget name of apave dialogue.
    #   w - name of widget
    # The name of widget may be partial. In this case it's prepended
    # the current dialogue's frame path.
    # Useful in "input" dialogue when -method option is present
    # or widget names are uppercased.
    # See also: MakeWidgetName, input

    if {[string index $w 0] eq {.}} {return $w}
    return $Dlgpath.fra.$w
  }
  #_______________________

  method MakeWidgetName {w name {an {}}} {
    # Makes an exported method named after root widget, if it's uppercased.
    #   w - name of root widget
    #   name - name of widget
    #   an - additional prefix for name (if "-", $w is full/partial name)
    # The created method used for easy access to the widget's path.
    # Example:
    #   fra1.fra2.fra3.Entry1
    #   => method Entry1 {} {...}
    #   ...
    #   my Entry1  ;# instead of .win.fra1.fra2.fra3.Entry1

    if {$an eq {-}} {
      set wnamefull "\[my DiaWidgetName $w\]"
    } else {
      set wnamefull [my WidgetNameFull $w $name $an]
      lassign [my LowercaseWidgetName $wnamefull] wnamefull
    }
    set method [my ownWName $name]
    set root1 [string index $method 0]
    if {[string is upper $root1]} {
      oo::objdefine [self] "method $method {} {return $wnamefull} ; \
        export $method"
    }
    return $wnamefull
  }
  #_______________________

  method AddPopupAttr {w attrsName atRO isRO args} {
    # Adds the attribute to call a popup menu for an editable widget.
    #   w - widget's name
    #   attrsName - variable name for attributes of widget
    #   atRO - "readonly" attribute (internally used)
    #   isRO - flag of readonly widget
    #   args - widget states to be checked

    upvar 1 $attrsName attrs
    lassign $args state state2
    if {$state2 ne {}} {
      if {[::apave::getOption -state {*}$attrs] eq $state2} return
      set isRO [expr {$isRO || [::apave::getOption -state {*}$attrs] eq $state}]
    }
    if {$isRO} {append atRO RO}
    append attrs " $atRO $w"
    return
  }
  #_______________________

  method clearEntry {w clearcom} {
    # Clears entry-like widget's value, after calling a command.
    #   w - widget's path
    #   clearcom - a command to call, can have %w for *w* (widget's path)

    if {$clearcom ne {}} {
      {*}[string map [list %w $w %p [self]] $clearcom]
    }
    #! perhaps, needs refactoring:
    if {[catch {$w delete 0 end}]} { ;# entry
      if {[catch {$w set {}}]} {     ;# combobox
        # others
      }
    }
  }
  #_______________________

  method makePopup {w {isRO no} {istext no} {tearoff no} {addpop ""} {clearcom ""}} {
    # Makes a popup menu for an editable widget.
    #   w - widget's name
    #   isRO - flag for "is it readonly"
    #   istext - flag for "is it a text"
    #   tearoff - flag for "-tearoff" option
    #   addpop - additional commands for popup menu
    #   clearcom - command for "Clear" item

    set pop $w.popupMenu
    catch {menu $pop -tearoff $tearoff}
    $pop delete 0 end
    if {$isRO || [$w cget -state] eq {disabled}} {
      $pop add command {*}[my iconA copy] -accelerator Ctrl+C -label Copy \
        -command "event generate $w <<Copy>>"
      if {$istext} {
        eval [my popupHighlightCommands $pop $w]
        after idle [list [self] set_highlight_matches $w]
      }
    } else {
      if {$istext} {
        ::apave::bindToEvent $w <<Copy>> ::apave::eventOnText $w <<Copy>>
        ::apave::bindToEvent $w <<Cut>> ::apave::eventOnText $w <<Cut>>
        $pop add command {*}[my iconA cut] -accelerator Ctrl+X -label Cut \
          -command "event generate $w <<Cut>>"
        $pop add command {*}[my iconA copy] -accelerator Ctrl+C -label Copy \
          -command "event generate $w <<Copy>>"
        $pop add command {*}[my iconA paste] -accelerator Ctrl+V -label Paste \
          -command "::apave::eventOnText $w <<Paste>>"
        $pop add separator
        $pop add command {*}[my iconA undo] -accelerator Ctrl+Z -label Undo \
          -command "::apave::eventOnText $w <<Undo>>"
        $pop add command {*}[my iconA redo] -accelerator Ctrl+Shift+Z -label Redo \
          -command "::apave::eventOnText $w <<Redo>>"
        catch {
          eval [my popupBlockCommands $pop $w]
          eval [my popupHighlightCommands $pop $w]
          if {$addpop ne {}} {
            lassign $addpop com par1 par2
            eval [my $com $pop $w {*}$par1 {*}$par2]
          }
          after idle [list [self] set_highlight_matches $w]
          after idle [my setTextBinds $w]
        }
      } else {
        if {$clearcom ne {}} {
          $pop add command {*}[my iconA no] -label Clear \
            -command [list [self] clearEntry $w $clearcom]
          $pop add separator
        }
        $pop add command {*}[my iconA cut] -accelerator Ctrl+X -label Cut \
          -command "event generate $w <<Cut>>"
        $pop add command {*}[my iconA copy] -accelerator Ctrl+C -label Copy \
          -command "event generate $w <<Copy>>"
        $pop add command {*}[my iconA paste] -accelerator Ctrl+V -label Paste \
          -command "event generate $w <<Paste>>"
      }
    }
    if {$istext} {
      $pop add separator
      $pop add command {*}[my iconA none] -accelerator Ctrl+A -label {Select All} \
        -command "$w tag add sel 1.0 end"
      bind $w <Control-a> "$w tag add sel 1.0 end; break"
    }
    bind $w <Button-3> "[self] themePopup $w.popupMenu; tk_popup $w.popupMenu %X %Y"
    return
  }
  #_______________________

  method Pre {refattrs} {
    # "Pre" actions for the text widget and similar
    # which all require some actions before and after their creation e.g.:
    #   the text widget's text cannot be filled if disabled
    #   so, we must act this way:
    #     1. call Pre - to get a text of widget
    #     2. create the widget
    #     3. call Post - to enable, then fill it with a text, then disable it
    # It's only possible with Pre and Post methods.
    # See also: Post

    upvar 1 $refattrs attrs
    set attrs_ret [set Prepost [list]]
    foreach {a v} $attrs {
      switch -exact -- $a {
        -disabledtext - -rotext - -lbxsel - -cbxsel - -notebazook - \
        -entrypop - -entrypopRO - -textpop - -textpopRO - -ListboxSel - \
        -callF2 - -timeout - -bartabs - -onReturn - -linkcom - -selcombobox - \
        -afteridle - -gutter - -propagate - -columnoptions - -selborderwidth -
        -selected - -popup - -bindEC - -tags - -debug - -clearcom {
          # attributes specific to apave, processed below in "Post"
          set v2 [string trimleft $v \{]
          set v2 [string range $v2 0 end-[expr {[string length $v]-[string length $v2]}]]
          lappend Prepost [list $a $v2]
        }
        -myown {
          lappend Prepost [list $a [subst $v]]
        }
        -labelwidget { ;# widget path as a method
          set v [string trim $v \{\}]
          catch {set v [my $v]}
          lappend attrs_ret $a $v
        }
        default {
          lappend attrs_ret $a $v
        }
      }
    }
    set attrs $attrs_ret
    return
  }
  #_______________________

  method Post {w attrs} {
    # Performes "post" actions after creation a widget.
    #   w - widget's path
    #   attrs - widget's attributes
    # Processes the same *apave* options that are processed in Pre method.
    # See also: Pre

    if {[set i [lsearch -exact -index 0 $Prepost -tags]]>-1} {
      set v [lindex $Prepost $i 1]
      set tags [set $v]
    } else {
      set tags {}
    }
    foreach pp $Prepost {
      lassign $pp a v
      set v [string trim $v $::apave::UFF]
      switch -exact -- $a {
        -disabledtext {
          $w configure -state normal
          my displayTaggedText $w v $tags
          $w configure -state disabled
          my readonlyWidget $w no
        }
        -rotext {
          if {[info exist v]} {
            if {[info exist $v]} {
              my displayTaggedText $w $v $tags
            } else {
              my displayTaggedText $w v $tags
            }
          }
          my readonlyWidget $w yes
        }
        -lbxsel {
          set v [lsearch -glob [$w get 0 end] "$v*"]
          if {$v>=0} {
            $w selection set $v
            $w yview $v
            $w activate $v
          }
          my UpdateSelectAttrs $w
        }
        -cbxsel {
          set cbl [$w cget -values]
          set v [lsearch -glob $cbl "$v*"]
          if {$v>=0} { $w set [lindex $cbl $v] }
        }
        -ListboxSel {
          bind $v <<ListboxSelect>> [list [namespace current]::ListboxSelect %W]
        }
        -entrypop - -entrypopRO {
          if {[winfo exists $v]} {
            my makePopup $v [expr {$a eq {-entrypopRO}}]
          }
        }
        -clearcom {
          my makePopup $w no no no {} $v   ;# popup menu with "Clear" command
        }
        -textpop - -textpopRO {
          if {[winfo exists $v]} {
            set ro [expr {$a eq {-textpopRO}}]
            my makePopup $v $ro yes
            set w $v
          } elseif {[string length $v]>5} {
            my makePopup $w no yes no $v
          }
          $w tag configure sel -borderwidth 1
        }
        -notebazook {
          foreach {fr attr} $v {
            if {[string match -tr* $fr]} {
              if {[string is boolean -strict $attr] && $attr} {
                ttk::notebook::enableTraversal $w
              }
            } elseif {[string match -sel* $fr]} {
              $w select $w.$attr
            } elseif {![string match #* $fr]} {
              set attr [my GetMC $attr]
              set attr [subst $attr]
              lassign [::apave::extractOptions attr -tip {} -tooltip {}] tip t2
              set wt $w.$fr
              $w add [ttk::frame $wt] {*}$attr
              if {[append tip $t2] ne {}} {
                set tip [my MC $tip]
                ::baltip::tip $w $tip -nbktab $wt
              }
            }
          }
        }
        -gutter {
          lassign [::apave::parseOptions $v -canvas Gut -width 5 -shift 6] canvas width shift
          if {![winfo exists $canvas]} {set canvas [my $canvas]}
          set bind [list [self] fillGutter $w $canvas $width $shift]
          bind $w <Configure> $bind
          if {[trace info execution $w] eq {}} {
            trace add execution $w leave $bind
          }
        }
        -onReturn {   ;# makes a command run at Enter key pressing
          lassign $v cmd from to
          if {[set tvar [$w cget -textvariable]] ne {}} {
            if {$from ne {}} {
              set cmd "if {\$$tvar < $from} {set $tvar $from}; $cmd"
            }
            if {$to ne {}} {
              set cmd "if {\$$tvar >$to} {set $tvar $to}; $cmd"
            }
          }
          foreach k {<Return> <KP_Enter>} {
            if {$v ne {}} {bind $w $k $cmd}
          }
        }
        -linkcom {
          lassign [my csGet] fg fg2 bg bg2
          my makeLabelLinked $w $v $fg $bg $fg2 $bg2 yes yes
        }
        -callF2 {
          if {[llength $v]==1} {set w2 $v} {set w2 [string map $v $w]}
          ::apave::bindToEvent $w <F2> $w2 invoke
        }
        -bindEC {
          set v [string map [list %w $w] $v]
          lassign $v ev com
          ::apave::bindToEvent $w $ev {*}$com
          switch -exact -- [winfo class $w] {
            Treeview {
              ::apave::bindToEvent $w <ButtonPress> selection clear
              ::apave::bindToEvent $w <KeyPress> selection clear
            }
            Listbox {
              ::apave::bindToEvent $w <ButtonPress> selection clear
              ::apave::bindToEvent $w <KeyPress> selection clear
            }
          }
        }
        -timeout {
          lassign $v timo lbl
          after idle [list [self] timeoutButton $w $timo $lbl]
        }
        -myown {
          eval {*}[string map [list %w $w] $v]
        }
        -bartabs {
          after 10 [string map [list %w $w] $v]
        }
        -afteridle {
          after idle [string map [list %w $w] $v]
        }
        -propagate {
          if {[lindex $v 0] in {add pack}} {
            pack propagate $w 0
          } else {
            grid propagate $w 0
          }
        }
        -columnoptions {
          foreach {col opts} $v {
            $w column $col {*}$opts
          }
        }
        -selborderwidth {
          $w tag configure sel -borderwidth $v
        }
        -selcombobox {
          bind $w <<ComboboxSelected>> $v
        }
        -selected {
          if {[string is true $v]} {
            after idle "$w selection range 0 end"
          }
        }
        -popup {
          after 50 "bind $w <Button-3> {$v}" ;# redefines other possible popups
        }
        -debug {
          if {$v} {
            # puts out the widget's name and (if exists) its method
            set method [string toupper [my ownWName $w] 0]
            if {$method in [info object methods [self]]} {
              set method "  METHOD: $method"
            } else {
              set method {}
            }
            puts "WIDGET: $w $method"
          }
        }
      }
    }
    return
  }
  #_______________________

  method CleanUps {{wr ""}} {
    # Performs various clean-ups before and after showing a window.
    #   wr - window's path (to clean up at closing)

    # Cleans the unused widgets from _AP_VISITED list
    for {set i [llength $::apave::_AP_VISITED(ALL)]} {[incr i -1]>=0} {} {
      if {![winfo exists [lindex $::apave::_AP_VISITED(ALL) $i 0]]} {
        set ::apave::_AP_VISITED(ALL) [lreplace $::apave::_AP_VISITED(ALL) $i $i]
      }
    }
    if {$wr ne {}} {
      for {set i [llength $::apave::_AP_VARS(TIMW)]} {[incr i -1]>=0} {} {
        set w [lindex $::apave::_AP_VARS(TIMW) $i]
        if {[string first $wr $w]==0 && ![catch {::baltip::hide $w}]} {
          set ::apave::_AP_VARS(TIMW) [lreplace $::apave::_AP_VARS(TIMW) $i $i]
        }
      }
      foreach {lst vars} [array get ::apave::_AP_VARS "_TRACED_${wr}*"] {
        foreach v $vars {
          ::apave::traceRemove $v
        }
        set ::apave::_AP_VARS($lst) [list]
      }
    }
  }
  #_______________________

  method UpdateColors {} {
    # Updates colors of widgets at changing CS.

    lassign [my csGet] fg fg2 bg bg2 - - - - - fg3
    # Visited labels:
    my CleanUps
    foreach lw $::apave::_AP_VISITED(ALL) {  ;# mark the same links
      lassign $lw w v inv
      lassign [my makeLabelLinked $w $v $fg $bg $fg2 $bg2 no $inv] fg0 bg0
      if {[info exists ::apave::_AP_VISITED(FG,$w)]} {
        set fg0 $fg3
        set ::apave::_AP_VISITED(FG,$w) $fg3
      }
      $w configure -foreground $fg0 -background $bg0
    }
  }

  ## ________________________ Links in labels _________________________ ##

  method initLinkFont {args} {
    # Gets/sets font attributes of links (labels & text tags with -link).
    #  args - font attributes ("-underline 1" by default)
    # Returns the current value of these attributes.

    if {[set ll [llength $args]]} {
      if {$ll%2} {   ;# clear the attributes, if called with ""
        set ::apave::_AP_VARS(LINKFONT) [list]
      } else {
        lassign [::apave::extractOptions args -foreground {} -background {}] \
          ::apave::_AP_VARS(LINKFG) ::apave::_AP_VARS(LINKBG)
        set ::apave::_AP_VARS(LINKFONT) $args
      }
    }
    return $::apave::_AP_VARS(LINKFONT)
  }
  #_______________________

  method labelFlashing {w1 w2 first args} {
    # Options of 'flashing' label:
    #   -file (or -data) {list of image files (or data variables)}
    #   -label {list of labels' texts}
    #   -incr {increment for -alpha option}
    #   -pause {pause in seconds for -alpha 1.0}
    #   -after {interval for 'after'}
    #   -squeeze {value for *-big.png}

    if {![winfo exists $w1]} return
    if {$first} {
      lassign [::apave::parseOptions $args \
        -file {} -data {} -label {} -incr 0.01 -pause 3.0 -after 10 -squeeze {} -static 0] \
        ofile odata olabel oincr opause oafter osqueeze ostatic
      if {$osqueeze ne {}} {set osqueeze "-subsample $osqueeze"}
      lassign {0 -2 0 1} idx incev waitev direv
    } else {
      lassign $args ofile odata olabel oincr opause oafter osqueeze ostatic \
        idx incev waitev direv
    }
    set llf [llength $ofile]
    set lld [llength $odata]
    if {[set llen [expr {max($llf,$lld)}]]==0} return
    incr incev $direv
    set alphaev [expr {$oincr*$incev}]
    if {$alphaev>=1} {
      set alpha 1.0
      if {[incr waitev -1]<0} {
        set direv -1
      }
    } elseif {$alphaev<0} {
      set alpha 0.0
      set idx [expr {$idx%$llen+1}]
      set direv 1
      set incev 0
      set waitev [expr {int($opause/$oincr)}]
    } else {
      set alpha $alphaev
    }
    if {$llf} {
      set png [list -file [lindex $ofile $idx-1]]
    } elseif {[info exists [set datavar [lindex $odata $idx-1]]]} {
      set png [list -data [set $datavar]]
    } else {
      set png [list -data $odata]
    }
    set NS [namespace current]
    if {$ostatic} {
      image create photo ${NS}::ImgT$w1 {*}$png
      $w1 configure -image ${NS}::ImgT$w1
    } else {
      image create photo ${NS}::ImgT$w1 {*}$png -format "png -alpha $alpha"
      image create photo ${NS}::Img$w1
      ${NS}::Img$w1 copy ${NS}::ImgT$w1 {*}$osqueeze
      $w1 configure -image ${NS}::Img$w1
    }
    if {$w2 ne {}} {
      if {$alphaev<0.33 && !$ostatic} {
        set fg [$w1 cget -background]
      } else {
        if {[info exists ::apave::_AP_VISITED(FG,$w2)]} {
          set fg $::apave::_AP_VISITED(FG,$w2)
        } else {
          set fg [$w1 cget -foreground]
        }
      }
      $w2 configure -text [lindex $olabel $idx-1] -foreground $fg
    }
    after $oafter [list [self] labelFlashing $w1 $w2 0 \
      $ofile $odata $olabel $oincr $opause $oafter $osqueeze $ostatic \
      $idx $incev $waitev $direv]
  }
  #_______________________

  method VisitedLab {w cmd {on ""} {fg ""} {bg ""}} {
    # Marks a label as visited/not visited
    #   w - label's path
    #   cmd - command linked
    #   on - flag "the label visited"
    #   fg - foreground of label
    #   bg - background of label

    set styl [ttk::style configure TLabel]
    if {$fg eq {}} {lassign [my csGet] - fg - bg}
    if {[info exists ::apave::_AP_VARS(LINKFG)]} {
      if {$::apave::_AP_VARS(LINKFG) ne {}} {set fg $::apave::_AP_VARS(LINKFG)}
      if {$::apave::_AP_VARS(LINKBG) ne {}} {set bg $::apave::_AP_VARS(LINKBG)}
    }
    set vst [string map {{ } _} $cmd]
    if {$on eq {}} {
      set on [expr {[info exists ::apave::_AP_VISITED($vst)]}]
    }
    if {$on} {
      set fg [lindex [my csGet] 9]
      set ::apave::_AP_VISITED($vst) 1
      set ::apave::_AP_VISITED(FG,$w) $fg
      foreach lw $::apave::_AP_VISITED(ALL) {  ;# mark the same links
        lassign $lw w2 cmd2
        if {[winfo exists $w2] && $cmd eq $cmd2} {
          $w2 configure -foreground $fg -background $bg
          set ::apave::_AP_VISITED(FG,$w2) $fg
        }
      }
    }
    $w configure -foreground $fg -background $bg
    if {[set font [$w cget -font]] eq {}} {
      set font $::apave::FONTMAIN
    } else {
      catch {set font [font actual $font]}
    }
    foreach {o v} [my initLinkFont] {dict set font $o $v}
    $w configure -font $font
  }
  #_______________________

  method HoverLab {w cmd on {fg ""} {bg ""}} {
    # Actions on entering/leaving a linked label.
    #   w - label's path
    #   cmd - command linked
    #   on - flag "now hovering on the label"
    #   fg - foreground of label
    #   bg - background of label

    if {$on} {
      if {$fg eq {}} {lassign [my csGet] fg - bg}
      $w configure -background $bg
    } else {
      my VisitedLab $w $cmd {} $fg $bg
    }
    return
  }
  #_______________________

  method textLink {w idx} {
    # Gets a label's path of a link in a text widget.
    #   w - text's path
    #   idx - index of the link

    if {[info exists ::apave::__TEXTLINKS__($w)]} {
      return [lindex $::apave::__TEXTLINKS__($w) $idx]
    }
    return {}
  }
  #_______________________

  method makeLabelLinked {lab v fg bg fg2 bg2 {doadd yes} {inv no} } {
    # Makes the linked label from a label.
    #   lab - label's path
    #   v - data of the link: command, tip, visited
    #   fg - foreground unhovered
    #   bg - background unhovered
    #   fg2 - foreground hovered
    #   bg2 - background hovered
    #   doadd - flag "register the label in the list of visited"
    #   inv - flag "invert the meaning of colors"

    set txt [$lab cget -text]
    lassign [split [string map [list $Edge $::apave::UFF] $v] $::apave::UFF] v tt vz
    set tt [string map [list %l $txt] $tt]
    set v [string map [list %l $txt %t $tt] $v]
    if {$tt ne {}} {
      set tt [my MC $tt]
      ::baltip tip $lab $tt
      lappend ::apave::_AP_VARS(TIMW) $lab
    }
    if {$inv} {
      set ft $fg
      set bt $bg
      set fg $fg2
      set bg $bg2
      set fg2 $ft
      set bg2 $bt
    }
    my VisitedLab $lab $v $vz $fg $bg
    bind $lab <Enter> "::apave::obj EXPORT HoverLab $lab {$v} yes $fg2 $bg2"
    bind $lab <Leave> "::apave::obj EXPORT HoverLab $lab {$v} no $fg $bg"
    bind $lab <Button-1> "::apave::obj EXPORT VisitedLab $lab {$v} yes $fg2 $bg2;$v"
    if {$doadd} {lappend ::apave::_AP_VISITED(ALL) [list $lab $v $inv]}
    return [list $fg $bg $fg2 $bg2]
  }
  #_______________________

  method leadingSpaces {line} {
    # Returns a number of leading spaces of a line
    #   line - the line

    return [expr {[string length $line]-[string length [string trimleft $line]]}]
  }

  ## ________________________ Text methods _________________________ ##

  method SetContentVariable {tvar txtnam name} {
    # Sets an internal text variable combining its main attributes.
    #   tvar - external variable for text
    #   txtnam - full name of widget
    #   name - short (tail) name of widget
    # The tricky thing is for further access to all of the text.
    # See also: GetContentVariable

    return [set PV(textcont,$tvar) $tvar*$txtnam*$name]
  }
  #_______________________

  method GetContentVariable {tvar} {
    # Gets an internal text variable.
    # See also: SetContentVariable

    return $PV(textcont,$tvar)
  }
  #_______________________

  method SplitContentVariable {ftxvar} {
    # Gets parts of an internal text variable.
    # See also: SetContentVariable

    return [split $ftxvar *]
  }
  #_______________________

  method getTextContent {tvar} {
    # Gets text content.
    #   tvar - text variable
    # Uses an internal text variable to extract the text contents.
    # Returns the content of text.

    lassign [my SplitContentVariable [my GetContentVariable $tvar]] \
      -> txtnam wid
    return [string trimright [$txtnam get 1.0 end]]
  }
  #_______________________

  method onKeyTextM {w K {s {}}} {
    # Processes indents and braces at pressing keys.
    #   w - text's path
    #   K - key's name
    #   s - key's state

    set lindt [string length $::apave::_AP_VARS(INDENT)]
    switch -exact $K {
      Return - KP_Enter {
        # at pressing Enter key, indent (and possibly add the right brace)
        # but shift/ctrl+Enter acts by default - without indenting
        if {$s & 1 || $s & 4} return
        set idx1 [$w index {insert linestart}]
        set idx2 [$w index {insert lineend}]
        set line [$w get $idx1 $idx2]
        set nchars [my leadingSpaces $line]
        set indent [string range $line 0 $nchars-1]
        set ch1 [string range $line $nchars $nchars+1]
        set islist [expr {$ch1 in {{* } {- } {# }}}]
        set ch2 [string index $line end]
        set idx1 [$w index insert]
        set idx2 [$w index "$idx1 +1 line"]
        set st2 [$w get "$idx2 linestart" "$idx2 lineend"]
        set ch3 [string index [string trimleft $st2] 0]
        if {$indent ne {} || $ch2 eq "\{" || $K eq {KP_Enter} || $st2 ne {} || $islist} {
          set st1 [$w get "$idx1" "$idx1 lineend"]
          if {[string index $st1 0] in [list \t { }]} {
            # if space(s) are at the right, remove them at cutting
            set n1 [my leadingSpaces $st1]
            $w delete $idx1 [$w index "$idx1 +$n1 char"]
          } elseif {$ch2 eq "\{" && $st1 eq {}} {
            # indent + closing brace
            set nchars2 [my leadingSpaces $st2]
            if {$st2 eq {} || $nchars>$nchars2 || ($nchars==$nchars2 && $ch3 ne "\}")} {
              append indent $::apave::_AP_VARS(INDENT) \n $indent "\}"
            } else {
              append indent $::apave::_AP_VARS(INDENT)
            }
            incr nchars $lindt
          } elseif {$indent eq {} && $st2 ne {}} {
            # no indent of previous line, try to get it from the next
            if {[string trim $st2] eq "\}"} {
              # add indentation for the next brace
              set st2 "$::apave::_AP_VARS(INDENT)$st2"
            }
            set nchars [my leadingSpaces $st2]
            set indent [string range $st2 0 [expr {$nchars-1}]]
          }
          # a new line supplied with "list-like pattern"
          if {$islist && ![string match *.0 $idx1] && \
          [string trim [$w get "$idx1 linestart" $idx1]] ne {}} {
            if {$ch1 eq {# } && int($idx1)>1} {
              # for comments: if only more than 1 of them, then add another
              set idx0 [$w index "$idx1 -1 line"]
              set st0 [string trimleft [$w get "$idx0 linestart" "$idx0 lineend"]]
              if {[string index $st0 0] ne {#} && $ch3 ne {#}} {
                set ch1 {}
              }
            }
            set indent "$indent$ch1"
            incr nchars [string length $ch1]
          }
          $w insert $idx1 \n$indent
          ::tk::TextSetCursor $w [$w index "$idx2 linestart +$nchars char"]
          return -code break
        }
      }
    braceright {
        # right brace pressed: shift the brace to left
        set idx1 [$w index insert]
        set st [$w get "$idx1 linestart" "$idx1 lineend"]
        set idx2 [$w index "$idx1 -1 line"]
        set st2 [$w get "$idx2 linestart" "$idx2 lineend"]
        set nchars [my leadingSpaces $st]
        set nchars2 [my leadingSpaces $st2]
        set st2 [string index $st2 end]
        if {($st2 ne "\{" && $nchars2<=$nchars || $st2 eq "\{" && $nchars2<$nchars) \
        && [string trimright $st] eq {} && [string length $st]>=$lindt} {
          if {$nchars>$nchars2} {set lindt [expr {$nchars-$nchars2}]}
          $w delete "$idx1 lineend -$lindt char" "$idx1 lineend"
        }
      }
    }
  }
  #_______________________

  method setTextBinds {wt} {
    # Returns bindings for a text widget.
    #   wt - the text's path

    if {[bind $wt <<Paste>>] eq {}} {
      set res " \
      ::apave::bindToEvent $wt <<Paste>> [self] pasteText $wt ;\
      ::apave::bindToEvent $wt <KP_Enter> [self] onKeyTextM $wt %K %s ;\
      ::apave::bindToEvent $wt <Return> [self] onKeyTextM $wt %K %s ;\
      catch {::apave::bindToEvent $wt <braceright> [self] onKeyTextM $wt %K}"
    }
    foreach k [::apave::getTextHotkeys CtrlD] {
      append res " ; ::apave::bindToEvent $wt <$k> [self] doubleText $wt"
    }
    foreach k [::apave::getTextHotkeys CtrlY] {
      append res " ; ::apave::bindToEvent $wt <$k> [self] deleteLine $wt"
    }
    foreach k [::apave::getTextHotkeys CtrlA] {
      append res " ; ::apave::bindToEvent $wt <$k> $wt tag add sel 1.0 end {;} break"
    }
    foreach k [::apave::getTextHotkeys CtrlT] {
      append res " ; ::apave::bindToEvent $wt <$k> ::apave::InsertChar $wt {\t} {;} break"
    }
    append res " ;\
      ::apave::bindToEvent $wt <Alt-Up> [self] linesMove $wt -1 ;\
      ::apave::bindToEvent $wt <Alt-Down> [self] linesMove $wt +1"
    return $res
  }
  #_______________________

  method TextCommandForChange {w com on {com2 ""}} {
    # Replaces a command of text widget for making changes
    #   w - text widget's name
    #   com - command for changes
    #   on - if "yes", replaces a text command; if "no", restores it
    # In particular, when `com` is empty, the text widget becomes readonly.

    set newcom $w.internal
    if {!$on} {
      if {[info commands ::$newcom] ne {}} {
        rename ::$w {}
        rename ::$newcom ::$w
      }
    } elseif {[info commands ::$newcom] eq {}} {
      rename $w ::$newcom
      if {$com eq {}} {
        # text to be readonly
      ; proc ::$w {args} "
          switch -exact -- \[lindex \$args 0\] \{
              insert \{\}
              delete \{\}
              replace \{\}
              default \{
                  return \[eval ::$newcom \$args\]
              \}
          \}"
      } else {
        # text to be sensible to changes
      ; proc ::$w {args} "
          set _res_of_TextCommandForChange \[eval ::$newcom \$args\]
          switch -exact -- \[lindex \$args 0\] \{
              insert \{$com\}
              delete \{$com\}
              replace \{$com\}
          \}
          return \$_res_of_TextCommandForChange"
      }
    }
    if {$com2 ne {}} {
      {*}$com2
    }
  }
  #_______________________

  method readonlyWidget {w {on yes} {popup yes}} {
    # Switches on/off a widget's readonly state for a text widget.
    #   w - text widget's path
    #   on - "on/off" boolean flag
    #   popup - "make popup menu" boolean flag
    # See also:
    #   [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/Read-only+text+widget)

    my TextCommandForChange $w {} $on
    if {$popup} {my makePopup $w $on yes}
    return
  }
  #_______________________

  method GetOutputValues {} {
    # Makes output values for some widgets (lbx, fco).
    # Some i/o widgets need a special method to get their returned values.

    foreach aop $Widgetopts {
      lassign $aop optnam vn v1 v2
      switch -glob -- $optnam {
        -lbxname* {
          # To get a listbox's value, its methods are used.
          # The widget may not exist when an apave object is used for
          # several dialogs which is a bad style (very very bad).
          if {[winfo exists $vn]} {
            lassign [$vn curselection] s1
            if {$s1 eq {}} {set s1 0}
            set w [string range $vn [string last . $vn]+1 end]
            if {[catch {set v0 [$vn get $s1]}]} {set v0 {}}
            if {$optnam eq {-lbxnameALL}} {
              # when -ALL option is set to 1, listbox returns
              # a list of 3 items - sel index, sel contents and all contents
              set $v1 [list $s1 $v0 [set $v1]]
            } else {
              set $v1 $v0
            }
          }
        }
        -retpos { ;# a range to cut from -tvar/-lvar variable
          lassign [split $v2 :] p1 p2
          set val1 [set $v1]
          # there may be -list option for this widget
          # then if the value is from the list, it's fully returned
          foreach aop2 $Widgetopts {
            lassign $aop2 optnam2 vn2 lst2
            if {$optnam2 eq {-list} && $vn eq $vn2} {
              foreach val2 $lst2 {
                if {$val1 eq $val2} {
                  set p1 0
                  set p2 end
                  break
                }
              }
              break
            }
          }
          set $v1 [string range $val1 $p1 $p2]
        }
      }
    }
    return
  }
  #_______________________

  method focusNext {w wnext {wnext0 ""}} {
    # Sets focus on a next widget (possibly, defined as `my Widget`).
    #   w - parent window name
    #   wnext - next widget's name
    #   wnext0 - core next name (used internally, for recursive search)

    if {$wnext eq {}} return
    if {[winfo exist $wnext]} {
      focus $wnext  ;# direct path to the next widget
      return
    }
    # try to find the next widget in hierarchy of widgets
    set ws $wnext
    if {$wnext0 eq {}} {
      # get the real next widget (wnext can be uppercased or calculated)
      catch {set wnext [subst $wnext]}
      if {![string match {my *} $wnext]} {
        catch {set wnext [my [my ownWName $wnext]]}
      }
      my focusNext $w $wnext $wnext
    } else {
      set wnext $wnext0
    }
    foreach wn [winfo children $w] {
      my focusNext $wn $wnext $wnext0
      if {[string match "*.$wnext" $wn] || [string match "*.$ws" $wn]} {
        focus $wn
        return
      }
    }
    return
  }
  #_______________________

  method AdditionalCommands {w wdg attrsName} {
    # Gets additional commands (for non-standard attributes).
    #   w - window name
    #   wdg - widget's full path
    #   attrsName - variable name for widget's attributes

    upvar $attrsName attrs
    set addcomms {}
    if {[set tooltip [::apave::getOption -tooltip {*}$attrs]] ne {} ||
    [set tooltip [::apave::getOption -tip {*}$attrs]] ne {}} {
      ::apave::initBaltip
      if {[set i [string first $Edge $tooltip]]>=0} {
        set tooltip [string range $tooltip 1 end-1]
        set tattrs [string range $tooltip [incr i -1]+[string length $Edge] end]
        set tooltip "{[string range $tooltip 0 $i-1]}"
      } else {
        set tattrs {}
      }
      set tooltip [my MC $tooltip]
      lappend addcomms [list ::baltip::tip $wdg $tooltip {*}$tattrs]
      set attrs [::apave::removeOptions $attrs -tooltip -tip]
    }
    if {[::apave::getOption -ro {*}$attrs] ne {} || \
    [::apave::getOption -readonly {*}$attrs] ne {}} {
      lassign [::apave::extractOptions attrs -ro 0 -readonly 0] ro readonly
      lappend addcomms [list my readonlyWidget $wdg [expr $ro||$readonly]]
    }
    if {[set wnext [::apave::getOption -tabnext {*}$attrs]] ne {}} {
      # two widgets for Tab & Shift/Tab (proc can be used to get them)
      set wnext [string trim $wnext "\{\}"]
      if {[string first \[ $wnext]==0} { ;# if [comm1] [comm2] for next/prev
        set wprev {}
        catch {lassign [subst $wnext] wnext wprev}
      } else {
        if {[catch {lassign [{*}$wnext] wnext wprev}]} {
          lassign $wnext wnext wprev
        }
      }
      if {$wnext eq {0}} {set wnext $wdg} ;# disables Tab on this widget
      if {[::iswindows]} {
        set i1 {{%s}==0}  ;# in Windows: Shift+Tab doesn't work in text
      } else {
        set i1 1
      }
      set c1 "[self] focusNext $w $wnext ; break"
      set c2 "[self] focusNext $w $wprev ; break"
      set i2 [expr {$wprev ne {}}]
      after idle [list if "\[winfo exists $wdg\]" [list bind $wdg <Key> \
        [list + if {{%K} eq {Tab}} [list if $i1 $c1 elseif $i2 $c2]]]]
      set attrs [::apave::removeOptions $attrs -tabnext]
    }
    return $addcomms
  }
  #_______________________

  method DefineWidgetKeys {wname widget} {
    # Sets some hotkeys for some widgets (e.g. Enter to work as Tab)
    #   wname - the widget's name
    #   widget - the widget's type
    # This may be disabled by including "STD" in the widget's name.

    if {[string first STD $wname]>0} return
    if {($widget in {ttk::entry entry})} {
      bind $wname <Up>  \
        "$wname selection clear ; \
        if {{$::tcl_platform(platform)} eq {windows}} {
          event generate $wname <Shift-Tab>
        } else {
          event generate $wname <Key> -keysym ISO_Left_Tab
        }"
      bind $wname <Down>  \
        "$wname selection clear ; \
        event generate $wname <Key> -keysym Tab"
    } elseif {$widget in {ttk::button button ttk::checkbutton checkbutton \
    ttk::radiobutton radiobutton "my tk_optionCascade"}} {
      foreach k {<Up> <Left>} {
        bind $wname $k [list \
          if {$::tcl_platform(platform) eq {windows}} [list \
            event generate $wname <Shift-Tab> \
          ] else [list \
            event generate $wname <Key> -keysym ISO_Left_Tab] \
          ]
      }
      foreach k {<Down> <Right>} {
        bind $wname $k \
          [list event generate $wname <Key> -keysym Tab]
      }
    }
    if {$widget in {ttk::button button \
    ttk::checkbutton checkbutton ttk::radiobutton radiobutton}} {
      foreach k {<Return> <KP_Enter>} {
        bind $wname $k \
        [list event generate $wname <Key> -keysym space]
      }
    }
    if {$widget in {ttk::entry entry spinbox ttk::spinbox ttk::combobox}} {
      foreach k {<Return> <KP_Enter>} {
        bind $wname $k \
          "+ $wname selection clear ; event generate $wname <Key> -keysym Tab"
      }
    }
  }

  ## ________________________ Paving windows _________________________ ##

  method colorWindow {win args} {
    # Initialize colors of a window.
    #   win - window's path
    #   args - arguments for csSet

    if {[my apaveTheme]} {
      my csSet [my csCurrent] $win {*}$args
      if {$args ne {-doit}} {my themeNonThemed $win}
    } else {
      my themeNonThemed $win
    }
  }
  #_______________________

  method ShowOption {name} {
    # Gets a default show option, used in showModal.
    #   name - name of option
    # See also: getShowOption, setShowOption

    return "_SHOWMODAL_$name"
  }
  #_______________________

  method getShowOption {name {defval ""}} {
    # Gets a default show option, used in showModal.
    #   name - name of option
    #   defval - default value
    # See also: showModal

    ::apave::getProperty [my ShowOption $name] $defval
  }
  #_______________________

  method setShowOption {name args} {
    # Sets / gets a default show option, used in showModal.
    #   name - name of option
    #   args - value of option
    # See also: showModal

    ::apave::setProperty [my ShowOption $name] {*}$args
  }
  #_______________________

  method Window {w inplists} {
    # Paves the window with widgets.
    #   w - window's name (path)
    #   inplists - list of widget items (lists of widget data)
    # Contents of a widget's item:
    #   name - widget's name (first 3 characters define its type)
    #   neighbor - top (T) or left (L) neighbor of the widget
    #   posofnei - position of neighbor: T (top) or L (left)
    #   rowspan - row span of the widget
    #   colspan - column span of the widget
    #   options - grid/pack options
    #   attrs - attributes of widget
    # First 3 items are mandatory, others are set at need.
    # Called by *paveWindow* method to process a portion of widgets.
    # The "portion" refers to a separate block of widgets such as
    # notebook's tabs or frames.

    set lwidgets [list]
    # comments be skipped
    foreach lst $inplists {
      if {[string index $lst 0] ne {#}} {
        lappend lwidgets $lst
      }
    }
    set lused [list]
    set lwlen [llength $lwidgets]
    if {$lwlen<2 && [string trim $lwidgets "{} "] eq {}} {
      set lwidgets [list {fra - - - - {pack -padx 99 -pady 99}}]
      set lwlen 1
    }
    for {set i 0} {$i < $lwlen} {} {
      set lst1 [lindex $lwidgets $i]
      if {[my Replace_Tcl i lwlen lwidgets {*}$lst1] ne {}} {incr i}
    }
    # firstly, normalize all names that are "subwidgets" (.lab for fra.lab)
    # also, "+" for previous neighbors
    set i [set lwlen [llength $lwidgets]]
    while {$i>1} {
      incr i -1
      set lst1 [lindex $lwidgets $i]
      lassign $lst1 name neighbor
      if {$neighbor eq {+}} {set neighbor [lindex $lwidgets $i-1 0]}
      lassign [my NormalizeName name i lwidgets] name wname
      set neighbor [lindex [my NormalizeName neighbor i lwidgets] 0]
      set lst1 [lreplace $lst1 0 1 $wname $neighbor]
      set lwidgets [lreplace $lwidgets $i $i $lst1]
    }
    for {set i 0} {$i < $lwlen} {} {
      # List of widgets contains data per widget:
      #   widget's name,
      #   neighbor widget, position of neighbor (T, L),
      #   widget's rowspan and columnspan (both optional),
      #   grid options, widget's attributes (both optional)
      set lst1 [lindex $lwidgets $i]
      set lst1 [my Replace_chooser w i lwlen lwidgets {*}$lst1]
      if {[set lst1 [my Replace_bar w i lwlen lwidgets {*}$lst1]] eq {}} {
        incr i
        continue
      }
      lassign $lst1 name neighbor posofnei rowspan colspan options1 attrs1
      lassign [my NormalizeName name i lwidgets] name wname
      set wname [my MakeWidgetName $w $wname]
      if {$colspan eq {} || $colspan eq {-}} {
        set colspan 1
        if {$rowspan eq {} || $rowspan eq {-}} {
          set rowspan 1
        }
      }
      foreach ao {attrs options} {
        if {[catch {set $ao [uplevel 2 subst -nocommand -nobackslashes [list [set ${ao}1]]]}]} {
          set $ao [set ${ao}1]
        }
      }
      lassign [my widgetType $wname $options $attrs] widget options attrs nam3 dsbl
      # The type of widget (if defined) means its creation
      # (if not defined, it was created after "makewindow" call
      # and before "window" call)
      if { !($widget eq {} || [winfo exists $widget])} {
        set attrs [my GetAttrs $attrs $nam3 $dsbl]
        set attrs [my ExpandOptions $attrs]
        # for scrollbars - set up the scrolling commands
        if {$widget in {ttk::scrollbar scrollbar}} {
          set neighbor [lindex [my LowercaseWidgetName $neighbor] 0]
          set wneigb [my WidgetNameFull $w $neighbor]
          if {$posofnei eq {L}} {
            $wneigb config -yscrollcommand "$wname set"
            set attrs "$attrs -com \\\{$wneigb yview\\\}"
            append options { -side right -fill y} ;# -after $wneigb"
          } elseif {$posofnei eq {T}} {
            $wneigb config -xscrollcommand "$wname set"
            set attrs "$attrs -com \\\{$wneigb xview\\\}"
            append options { -side bottom -fill x} ;# -before $wneigb"
          }
          set options [string map [list %w $wneigb] $options]
        }
        #% doctest 1
        #%   set a "123 \\\\\\\\ 45"
        #%   eval append b {*}$a
        #%   set b
        #>   123\45
        #> doctest
        my Pre attrs
        set addcomms [my AdditionalCommands $w $wname attrs]
        eval $widget $wname {*}$attrs
        my Post $wname $attrs
        foreach acm $addcomms {{*}$acm}
        # for buttons and entries - set up the hotkeys (Up/Down etc.)
        my DefineWidgetKeys $wname $widget
      }
      if {$neighbor eq {-} || $row < 0} {
        set row [set col 0]
      }
      # check for simple creation of widget (without pack/grid)
      if {$neighbor ne {#}} {
        set options [my GetIntOptions $w $options $row $rowspan $col $colspan]
        set pack [string trim $options]
        if {[string first add $pack]==0} {
          set comm "[winfo parent $wname] add $wname [string range $pack 4 end]"
          {*}$comm
        } elseif {[string first pack $pack]==0} {
          set opts [string trim [string range $pack 5 end]]
          if {[string first forget $opts]==0} {
            pack forget {*}[string range $opts 6 end]
          } else {
            pack $wname {*}$opts
          }
        } else {
          grid $wname -row $row -column $col -rowspan $rowspan \
             -columnspan $colspan -padx 1 -pady 1 {*}$options
        }
      }
      lappend lused [list $name $row $col $rowspan $colspan]
      if {[incr i] < $lwlen} {
        lassign [lindex $lwidgets $i] name neighbor posofnei
        set neighbor [lindex [my LowercaseWidgetName $neighbor] 0]
        set row -1
        foreach cell $lused {
          lassign $cell uname urow ucol urowspan ucolspan
          if {[lindex [my LowercaseWidgetName $uname] 0] eq $neighbor} {
            set col $ucol
            set row $urow
            if {$posofnei eq {T} || $posofnei eq {}} {
              incr row $urowspan
            } elseif {$posofnei eq {L}} {
              incr col $ucolspan
            }
          }
        }
      }
    }
    return $lwidgets
  }
  #_______________________

  method paveWindow {args} {
    # Processes "win / list_of_widgets" pairs.
    #   args - list of pairs "win / lwidgets"
    # The *win* is a window's path. The *lwidgets* is a list of widget items.
    # Each widget item contains:
    #   name - widget's name (first 3 characters define its type)
    #   neighbor - top or left neighbor of the widget
    #   posofnei - position of neighbor: T (top) or L (left)
    #   rowspan - row span of the widget
    #   colspan - column span of the widget
    #   options - grid/pack options
    #   attrs - attributes of widget
    # First 3 items are mandatory, others are set at need.
    # This method calls *paveWindow* in a cycle, to process a current "win/lwidgets" pair.

    set res [list]
    set wmain [set wdia {}]
    foreach {w lwidgets} $args {
      if {[lindex $lwidgets 0 0] eq {after}} {
        # if 1st item is "after idle" or like "after 1000", layout the window after...
        # (fit for "invisible independent" windows/frames/tabs)
        set what [lindex $lwidgets 0 1]
        if {$what eq {idle} || [string is integer -strict $what]} {
          after $what [list [self] paveWindow $w [lrange $lwidgets 1 end]]
          after $what [list [self] colorWindow $w -doit]
        }
        continue
      }
      lappend res {*}[my Window $w $lwidgets]
      if {[set ifnd [regexp -indices -inline {[.]dia\d+} $w]] ne {}} {
        set wdia [string range $w 0 [lindex $ifnd 0 1]]
      } else {
        set wmain .[lindex [split $w .] 1]
      }
    }
    # add a system Menu binding for the created window
    if {[winfo exists $wdia]} {::apave::initPOP $wdia} elseif {
        [winfo exists $wmain]} {::apave::initPOP $wmain}
    return $res
  }
  #_______________________

  method window {args} {
    # Obsolete version of paveWindow (remains for compatibility).
    # See also: paveWindow

    return [uplevel 1 [list [self] paveWindow {*}$args]]
  }
  #_______________________

  method WinVarname {win} {
    # Gets a unique varname for a window.
    #   win - window's path

    return [namespace current]::PV(_WIN_,$win)
  }
  #_______________________

  method waitWinVar {win var modal} {
    # Tk waiting for variable's change.
    #   win - the window's path
    #   var - variable's name to receive a result (tkwait's variable)
    #   modal - yes at showing the window as modal

    # first of all, wait till the window be visible
    after 1 ;# solves an issue with doubleclicking buttons
    if {![winfo viewable $win]} {
      tkwait visibility $win
    }
    set wmain [::apave::mainWindowOfApp]
    if {$modal} {      ;# for modal, grab the window
      set wgr [grab current]
      if {$wmain ne {} && $wmain ne $win} {
        if {[catch {grab set $win} e]} {
          catch {tkwait visibility $win}  ;# 2nd attempt to get the window visible, by force
          catch {grab set $win}           ;# (not sure, where it can fire, still let it be)
          puts stderr "\napave::waitWinVar - please send a note to apave developers on this catch. Error: $e"
          catch {puts stderr "apave::waitWinVar - [info level -1]\n"}
        }
      }
    }
    # at need, wait till the window associated variable be changed
    if {$var ne {}} {
      tkwait variable $var
    }
    if {$modal} {      ;# for modal, release the grab and restore the old one
      catch {grab release $win}
      if {$wgr ne {}} {
        catch {grab set $wgr}
      }
    }
  }
  #_______________________

  method showWindow {win modal ontop {var ""} {minsize ""} {waitvar 1}} {
    # Displays a windows and goes in tkwait cycle to interact with a user.
    #   win - the window's path
    #   modal - yes at showing the window as modal
    #   ontop - yes at showing the window as topmost
    #   var - variable's name to receive a result (tkwait's variable)
    #   minsize - list {minwidth minheight} or {}
    #   waitvar - if yes, force tkwait variable (mostly for non-modal windows)

    ::apave::InfoWindow [expr {[::apave::InfoWindow] + 1}] $win $modal $var yes
    ::apave::deiconify $win
    if {$minsize eq {}} {
      set minsize [list [winfo width $win] [winfo height $win]]
    }
    wm minsize $win {*}$minsize
    bind $win <Configure> "[namespace current]::WinResize $win"
    if {$ontop} {wm attributes $win -topmost 1}
    if {$modal} {
      # modal window:
      my waitWinVar $win $var $modal
      ::apave::InfoWindow [expr {[::apave::InfoWindow] - 1}] $win $modal $var
    } else {
      # non-modal window:
      if {[set wgr [grab current]] ne {}} {
        # otherwise the non-modal window is irresponsive (in Windows even at WM level):
        grab release $wgr
      }
      if {$waitvar && $var ne {}} {
        my waitWinVar $win $var $modal ;# show and wait for closing the window
      }
    }
  }
  #_______________________

  method showModal {win args} {
    # Shows a window as modal.
    #   win - window's name
    #   args - attributes of window ("-name value" pairs)

    set ::apave::MODALWINDOW [set Modalwin $win]
    ::apave::setAppIcon $win
    lassign [::apave::extractOptions args -centerme {} -ontop 0 -modal yes -minsize {} \
      -themed {} -input 0 -variable {} -waitvar {} -transient {-} -root {} -parent {}] \
      centerme ontop modal minsize themed input varname waitvar transient root parent
    $win configure -bg [lindex [my csGet] 3]  ;# removes blinking by default bg
    if {$themed in {{} {0}} && [my csCurrent] != [apave::cs_Non]} {
      my colorWindow $win
    }
    if {$centerme eq {}} {
      # obsolete options: -root, -parent
      if {$root ne {}} {set centerme $root} {set centerme $parent}
    }
    set root [winfo parent $win]
    set rooted 1
    if {$centerme ne {}} {
      ;# forced centering relative to a caller's window
      lassign [split $centerme x+] rw rh rx ry
      set rooted [expr {![regexp {[+|-]+\d+\++} $centerme]}]
      if {$rooted && [winfo exist $centerme]} {
        set root $centerme
      }
    }
    set decor [expr {$root in {{} .}}]
    foreach {o v} [list -decor $decor -focus {} -onclose {} -geometry {} \
    -resizable {} -ontop 0 -escape 1 -checkgeometry 1] {
      lappend defargs $o [my getShowOption $o $v]
    }
    if {$varname ne {}} {
      set waitvar 1
    } else {
      set waitvar [string is true $waitvar]  ;# default 1: wait for closing the window
      set varname [my WinVarname $win]
    }
    array set opt [list {*}$defargs {*}$args]
    if {$ontop eq {}} {
      if {$opt(-ontop)} {
        set ontop yes
      } else {
        set ontop no
        catch {
          set ontop [wm attributes [winfo parent $win] -topmost]
        }
        if {!$ontop} {
          # find if a window child of "." is topmost
          # if so, let this one be topmost too
          foreach w [winfo children .] {
            catch {set ontop [wm attributes $w -topmost]}
            if {$ontop} break
          }
        }
      }
    }
    if {$rooted} {
      lassign [::apave::splitGeometry [wm geometry [winfo toplevel $root]]] rw rh rx ry
    }
    if {$transient ne {-}} {
      wm transient $win $transient
    } elseif {!$opt(-decor)} {
      wm transient $win $root
    }
    if {[set destroy [expr {$opt(-onclose) eq {destroy}}]]} {
      set opt(-onclose) {}
    }
    if {$opt(-onclose) eq {}} {
      set opt(-onclose) "set $varname 0"
    } else {
      set opt(-onclose) "$opt(-onclose) $varname"  ;# $opt(-onclose) is a command
    }
    if {$destroy} {append opt(-onclose) " ; destroy $win"}
    if {$opt(-resizable) ne {}} {
      if {[string is boolean $opt(-resizable)]} {
        set opt(-resizable) "$opt(-resizable) $opt(-resizable)"
      }
      wm resizable $win {*}$opt(-resizable)
    }
    if {!($modal || $waitvar)} {
      append opt(-onclose) "; ::apave::obj EXPORT CleanUps $win"
    }
    wm protocol $win WM_DELETE_WINDOW $opt(-onclose)
    # get the window's geometry from its requested sizes
    set inpgeom $opt(-geometry)
    if {$inpgeom eq {}} {
      # this is for less blinking:
      set opt(-geometry) [my CenteredXY $rw $rh $rx $ry \
        [winfo reqwidth $win] [winfo reqheight $win]]
    } elseif {[string first pointer $inpgeom]==0} {
      lassign [split $inpgeom+0+0 +] -> x y
      set inpgeom +[expr {$x+[winfo pointerx .]}]+[expr {$y+[winfo pointery .]}]
      set opt(-geometry) $inpgeom
    } elseif {[string first root $inpgeom]==0} {
      set root .[string trimleft [string range $inpgeom 5 end] .]
      set opt(-geometry) [set inpgeom {}]
    }
    if {$opt(-geometry) ne {}} {
      lassign [::apave::splitGeometry $opt(-geometry) {} {}] - - x y
      if {$x ne {}} {wm geometry $win $x$y}
    }
    if {$opt(-focus) eq {}} {
      set opt(-focus) $win
    }
    set $varname {-}
    if {$opt(-escape)} {bind $win <Escape> $opt(-onclose)}
    update
    if {![winfo exists $win]} {
      return 0 ;# looks idiotic, yet possible at sporadic calls
    }
    set w [winfo reqwidth $win]
    set h [winfo reqheight $win]
    if {$inpgeom eq {}} {  ;# final geometrizing with actual sizes
      set geo [my CenteredXY $rw $rh $rx $ry $w $h]
      set y [lindex [split $geo +] end]
      if {!$rooted || $root ne {.} && (($h/2-$ry-$rh/2)>30 || [::iswindows] && $y>0)} {
        # ::tk::PlaceWindow needs correcting in rare cases, namely:
        # when 'root' is of less sizes than 'win' and at screen top
        wm geometry $win $geo
      } else {
        ::tk::PlaceWindow $win widget $root
      }
    } else {
      lassign [::apave::splitGeometry $inpgeom {} {}] - - x y
      if {$x ne {} && $y ne {} && [string first x $inpgeom]<0 && $opt(-checkgeometry)} {
        set inpgeom [my checkXY $w $h $x $y]
      } elseif {$x eq {} && $y eq {} && $centerme ne {} && $opt(-geometry) ne {}} {
        lassign [split $opt(-geometry) x+] w h
        lassign [split [my CenteredXY $rw $rh $rx $ry $w $h] +] -> x y
        set inpgeom ${w}x$h+$x+$y
      }
      wm geometry $win $inpgeom
    }
    after 50 [list if "\[winfo exist $opt(-focus)\]" "focus -force $opt(-focus)"]
    if {[info exists ::transpops::my::cntwait]} {
      # this specific bind - for transpops package (to hide a demo message by keys)
      bind $win <Control-Alt-0> {set ::transpops::my::cntwait 0}
    }
    my showWindow $win $modal $ontop $varname $minsize $waitvar
    set res 0
    catch {
      if {$modal || $waitvar} {my CleanUps $win}
      if {[winfo exists $win]} {
        if {$input} {my GetOutputValues}
        set res [set [set _ $varname]]
      }
    }
    return $res
  }
  #_______________________

  method res {{win {}} {result get}} {
    # Gets/sets a variable for *vwait* command.
    #   win - window's path
    #   result - value of variable
    # This method is used when
    #  - an event cycle should be stopped with changing a variable's value
    #  - a result of event cycle (the variable's value) should be got
    # In the first case, *result* is set to an integer. In *apave* dialogs
    # the integer is corresponding a pressed button's index.
    # In the second case, *result* is omitted or equal to "get".
    # Returns a value of variable that controls an event cycle.

    if {$win eq {}} {set win [my dlgPath]}
    set varname [my WinVarname $win]
    if {$result eq {get}} {
      return [set $varname]
    }
    my CleanUps $win
    return [set $varname $result]
  }
  #_______________________

  method makeWindow {w ttl args} {
    # Creates a toplevel window that has to be paved.
    #   w - window's name
    #   ttl - window's title
    #   args - options for 'toplevel' command
    # If $w matches "*.fra" then ttk::frame is created with name $w.

    my CleanUps
    set w [set wtop [string trimright $w .]]
    set withfr [expr {[set pp [string last . $w]]>0 && \
      [string match *.fra $w]}]
    if {$withfr} {
      set wtop [string range $w 0 $pp-1]
    }
    catch {destroy $wtop}
    lassign [::apave::extractOptions args -type {}] type
    toplevel $wtop {*}$args
    ::apave::withdraw $wtop ;# nice to hide all gui manipulations
    if {$type ne {} && [tk windowingsystem] eq {x11}} {
      wm attributes $wtop -type $type
    }
    if {$withfr} {
      pack [frame $w -background [lindex [my csGet] 3]] -expand 1 -fill both
    }
    wm title $wtop $ttl
    return $wtop
  }
  #_______________________

  method displayText {w conts {pos 1.0}} {
    # Sets the text widget's contents.
    #   w - text widget's name
    #   conts - contents to be set in the widget

    if {[set state [$w cget -state]] ne {normal}} {
      $w configure -state normal
    }
    $w replace 1.0 end $conts
    $w edit reset; $w edit modified no
    if {$state eq {normal}} {
      ::tk::TextSetCursor $w $pos
    } else {
      $w configure -state $state
    }
    return
  }
  #_______________________

  method resetText {w state {contsName {}}} {
    # Resets a text widget to edit/view from scratch.
    #   w - text widget's name
    #   state - widget's final state (normal/disabled)
    #   contsName - variable name for contents to be set in the widget

    if {$contsName ne {}} {
      upvar 1 $contsName conts
      $w replace 1.0 end $conts
    }
    $w edit reset
    $w edit modified no
    $w configure -state $state
  }
  #_______________________

  method displayTaggedText {w contsName {tags ""}} {
    # Sets the text widget's contents using tags (ornamental details).
    #   w - text widget's name
    #   contsName - variable name for contents to be set in the widget
    #   tags - list of tags to be applied to the text
    # The lines in *text contents* are divided by \n and can include
    # *tags* like in a html layout, e.g. <red>RED ARMY</red>.
    # The *tags* is a list of "name/value" pairs. 1st is a tag's name, 2nd
    # is a tag's value.
    # The tag's name is "pure" one (without <>) so e.g.for <b>..</b> the tag
    # list contains "b".
    # The tag's value is a string of text attributes (-font etc.).
    # If the tag's name is FG, FG2, BG or BG2, then it is really a link color.

    upvar $contsName conts
    if {$tags eq {}} {
      my displayText $w $conts
      return
    }
    lassign [my csGet] fg fg2 bg bg2
    if { [set state [$w cget -state]] ne {normal}} {
      $w configure -state normal
    }
    set taglist [set tagpos [set taglen [list]]]
    foreach tagi $tags {
      lassign $tagi tag opts
      if {$tag in {FG FG2 BG BG2} } {
        set [string tolower $tag] $opts
      } elseif {![string match link* $tag]} {
        $w tag config $tag {*}$opts
      }
      lappend tagpos 0
      lappend taglen [string length $tag]
    }
    set tLen [llength $tags]
    set disptext {}
    set irow 1
    foreach line [split $conts \n] {
      if {$irow > 1} {
        append disptext \n
      }
      set newline {}
      while 1 {
        set p [string first \< $line]
        if {$p < 0} {
          break
        }
        append newline [string range $line 0 $p-1]
        set line [string range $line $p end]
        set i 0
        set nrnc $irow.[string length $newline]
        foreach tagi $tags pos $tagpos len $taglen {
          lassign $tagi tag
          if {[string first <$tag> $line]==0} {
            if {$pos ne {0}} {
              error "\napaveme.tcl: mismatched <$tag> in line $irow.\n"
            }
            lset tagpos $i $nrnc
            set line [string range $line $len+2 end]
            break
          } elseif {[string first </$tag> $line]==0} {
            if {$pos eq {0}} {
              error "\napaveme.tcl: mismatched </$tag> in line $irow.\n"
            }
            lappend taglist [list $i $pos $nrnc]
            lset tagpos $i 0
            set line [string range $line $len+3 end]
            break
          }
          incr i
        }
        if {$i == $tLen} {
          # tag not found after "<" - shift by 1 character
          append newline [string index $line 0]
          set line [string range $line 1 end]
        }
      }
      append disptext $newline $line
      incr irow
    }
    $w replace 1.0 end $disptext
    set lfont [$w cget -font]
    catch {set lfont [font actual $lfont]}
    foreach {o v} [my initLinkFont] {dict set lfont $o $v}
    set ::apave::__TEXTLINKS__($w) [list]
    for {set it [llength $taglist]} {[incr it -1]>=0} {} {
      set tagli [lindex $taglist $it]
      lassign $tagli i p1 p2
      lassign [lindex $tags $i] tag opts
      if {[string match link* $tag] && \
      [set ist [lsearch -exact -index 0 $tags $tag]]>=0} {
        set txt [$w get $p1 $p2]
        set lab ${w}l[incr ::apave::__linklab__]
        ttk::label $lab -text $txt -font $lfont -foreground $fg -background $bg
        set ::apave::__TEXTLINKS__($w) [linsert $::apave::__TEXTLINKS__($w) 0 $lab]
        $w delete $p1 $p2
        $w window create $p1 -window $lab
        set v [lindex $tags $ist 1]
        my makeLabelLinked $lab $v $fg $bg $fg2 $bg2
      } else {
        $w tag add $tag $p1 $p2
      }
    }
    my resetText $w $state
    return
  }

# ________________________ EOC ::apave::APaveBase _________________________ #

}

# _____________________________ EOF _____________________________________ #
