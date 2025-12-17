###########################################################
# Name:    baltip.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    12/01/2021
# Brief:   Handles Tcl/Tk tip widget.
# License: MIT.
###########################################################

package provide baltip 1.6.5

# ________________________ Variables _________________________ #

namespace eval ::baltip {

  namespace export configure cget tip update hide repaint \
    optionlist tippath clear sleep showBalloon showTip
  namespace ensemble create

  namespace eval my {
    variable ttdata; array set ttdata [list]
    set ttdata(on) yes
    set ttdata(per10) 1600
    set ttdata(fade) 300
    set ttdata(pause) 1000
    set ttdata(fg) black
    set ttdata(bg) #FBFB95
    set ttdata(bd) 1
    set ttdata(padx) 4
    set ttdata(pady) 3
    set ttdata(padding) 0
    set ttdata(alpha) 1.0
    set ttdata(bell) no
    set ttdata(font) [font actual TkTooltipFont]
    set ttdata(under) -16
    set ttdata(image) {}
    set ttdata(compound) {}
    set ttdata(relief) {}
    set ttdata(shiftX) {}
    set ttdata(shiftY) {}
    set ttdata(ontop) no
    set ttdata(balloon) -
  }
}

# _________________________ UI ______________________ #

proc ::baltip::configure {args} {
  # Configurates the tip for all widgets or for a widget.
  #   args - options ("name value" pairs)
  # If *args* begins with a widget path, then
  # args is "w -opt val ?-opt val?", so the widget tip options are set.
  # Returns the list of special options' values or a widget's tip options.

  variable my::ttdata
  set w [lindex $args 0]
  if {[winfo exists $w]} {
    # configure a widget's tip
    return [tip $w -BALTIPSET {*}[lrange $args 1 end]]
  }
  set force no
  set index -1
  lassign {} geometry tag ctag nbktab reset command maxexp focus onmouse
  set global [expr {[dict exists $args -global] && [dict get $args -global]}]
  foreach {n v} $args {
    set n1 [string range $n 1 end]
    switch -glob -- $n {
      -SPECTIP* - -on - -shiftX - -shiftY - -ontop - -eternal - \
      -per10 - -fade - -pause - -fg - -bg - -bd - -alpha - -text - -relief - \
      -padx - -pady - -padding - -bell - -under - -font - -image - -compound {
        set my::ttdata($n1) $v
      }
      -force - -geometry - -index - -tag - -global - -ctag - -nbktab - -reset - \
      -command - -maxexp - -focus - -onmouse {
        set $n1 $v
      }
      default {return -code error "baltip: invalid option \"$n\""}
    }
    if {$global && ($n ne {-global} || [llength $args]==2)} {
      foreach k [array names my::ttdata -glob on,*] {
        set w [lindex [split $k ,] 1]
        set my::ttdata($n1,$w) $v
      }
    }
  }
  return [list \
    $force $geometry $index $tag $ctag $nbktab $reset $command $maxexp $focus $onmouse]
}
#_______________________

proc ::baltip::cget {args} {
  # Gets global option values or a widget's option value.
  #   args - option names (if empty, returns all options)
  # If *args* begins with a widget path, then args is "w -option",
  # so the widget tip option's value is returned (e.g. for -text option).
  # Returns a list of "name value" pairs or an option value of a widget's tip.

  variable my::ttdata
  if {![llength $args]} {
    lappend args {*}[optionlist]
  }
  set w [lindex $args 0]
  if {[winfo exists $w]} {
    set dic [tip $w -BALTIPGET]
    if {[set opt [lindex $args 1]] ne {}} {
      if {[dict exists $dic $opt]} {
        return [dict get $dic $opt]
      }
      return {}
    }
    return $dic
  }
  set res [list]
  foreach n $args {
    set n [string range $n 1 end]
    if {[info exists my::ttdata($n)]} {
      lappend res -$n $my::ttdata($n)
    }
  }
  return $res
}
#_______________________

proc ::baltip::optionlist {} {
  # All options of baltip.

  return [list -on -per10 -fade -pause -fg -bg -bd -padx -pady -padding -font \
    -alpha -text -index -tag -bell -under -image -compound -relief -ctag \
    -nbktab -reset -command -maxexp -focus -shiftX -shiftY -ontop -eternal -onmouse]
}
#_______________________

proc ::baltip::tippath {w} {
  # Gets a tip window's path.
  #   w - widget's path

  return [string trimright $w .].w__BALTIP
}
#_______________________

proc ::baltip::tip {w {text "-BALTIPGET"} args} {
  # Creates a tip for a widget.
  #   w - the parent widget's path
  #   text - the tip text
  #   args - options ("name value" pairs)
  # If *text* is equal to "-BALTIPGET", returns options of widget's tip
  # If *text* is equal to "-BALTIPSET", sets options of widget's tip

  variable my::ttdata
  array unset my::ttdata winGEO*
  if {[winfo exists $w] || $w eq {}} {
    if {$text in {-BALTIPGET -BALTIPSET}} {
      # "-BALTIPGET" is the same as "-BALTIPSET", just supposed not to include args
      if {![info exists my::ttdata(optvals,$w)]} {
        if {$text eq {-BALTIPGET}} {return {}}
        set my::ttdata(optvals,$w) [dict create]
      }
      set my::ttdata(optvals,$w) [dict replace $my::ttdata(optvals,$w) {*}$args]
      if {$text eq {-BALTIPGET}} {
        return $my::ttdata(optvals,$w)
      }
      if {[catch {set text [dict get $my::ttdata(optvals,$w) -text]}]} {
        return {}
      }
    }
    set arrsaved [array get my::ttdata]
    set optvals [::baltip::my::CGet {*}$args]
    # block of related lines for special options
    set specopt {forced geo index ttag ctag nbktab reset command maxexp focus onmouse}
    lassign $optvals {*}$specopt
    set optArgs [lrange $optvals [llength $specopt] end] ;# get rid of spec.options
    if {[catch {set optvals $my::ttdata(optvals,$w)}]} {
      set optvals $optArgs
    }
    # end of block
    set my::ttdata(global,$w) no
    # no redefining a command once set
    if {[info exists ttdata(command,$w)] && [string is false $reset]} {
      set command $my::ttdata(command,$w)
    } else {
      set my::ttdata(command,$w) $command
    }
    set my::ttdata(onmouse,$w) $onmouse
    if {$command ne {}} {::baltip::update $w $text}
    if {![info exists my::ttdata(maxexp,$w)]} {
      set my::ttdata(maxexp,$w) $maxexp
    }
    if {[winfo exists $focus]} {
      set my::ttdata(focus,$w) $focus
    }
    set text [my::OptionsFromText $w $text]  ;# may reset -command and -maxexp
    set ontags [string length $nbktab$ctag$ttag]
    set onopt [expr {[string length $text] && $my::ttdata(on) || $ontags}]
    set optArgs [dict replace $optArgs -text $text]
    set optvals [dict replace $optvals -text $text]
    set et 0
    catch {set et [dict get $args -eternal]}
    if {[set my::ttdata(eternal,$w) $et]} {lappend optvals -per10 1}
    set my::ttdata(optvals,$w) $optvals
    set my::ttdata(on,$w) $onopt
    if {$text ne {} || $ontags} {
      if {$forced || $geo ne {}} {::baltip::my::Show $w $text yes $geo $optvals}
      if {$geo ne {}} {
        # balloon popup message
        array set my::ttdata $arrsaved
        set my::ttdata(balloon) $w
      } else {
        set widgetclass [winfo class $w]
        set tags [bindtags $w]
        if {[lsearch -exact $tags "Tooltip$w"] == -1} {
          bindtags $w [linsert $tags end "Tooltip$w"]
        }
        bind Tooltip$w <Any-Leave>    "::baltip::hide $w"
        bind Tooltip$w <Any-KeyPress> "::baltip::hide $w"
        bind Tooltip$w <Any-Button>   "::baltip::hide $w"
        if {$index>-1} {
          # tip for menu items
          set my::ttdata(LASTMITEM) {}
          set wt [my::Clonename $w]
          foreach w2 [list $w $wt] {
            set my::ttdata(on,$w2) $onopt
            set my::ttdata($w2,$index) $optArgs
            set my::ttdata(command,$w2) $command
            set my::ttdata(global,$w2) no
          }
          my::BindToEvent Menu <<MenuSelect>> ::baltip::my::MenuTip %W
        } elseif {$ttag ne {}} {
          # tip for text tags
          set my::ttdata($w,$ttag) $text
          my::BindTextagToEvent $w $ttag <Enter> ::baltip::my::TagTip $w $ttag $optArgs
          foreach event {Leave KeyPress Button} {
            my::BindTextagToEvent $w $ttag <$event> ::baltip::my::TagTip $w
          }
        } elseif {$ctag ne {}} {
          # tip for canvas tags
          set my::ttdata($w,$ctag) $text
          my::BindCantagToEvent $w $ctag <Enter> ::baltip::my::TagTip $w $ctag $optArgs
          my::BindCantagToEvent $w $ctag <Leave> ::baltip::my::TagTip $w
        } elseif {$nbktab ne {}} {
          # tip for notebook tabs
          configure -SPECTIP$nbktab $text
          configure $nbktab -text $text ;# save as default tip
          bind Tooltip$w <Button-1> "::baltip::my::NbkInfo $w %x %y -"
          bind Tooltip$w <Motion> "::baltip::my::PrepareNbkTip $w %x %y"
        } elseif {$widgetclass eq {Listbox}} {
          # tip for listbox items
          if {[cget -SPECTIP$w] eq {} || [string is true -strict $reset]} {
            configure -SPECTIP$w $text
          }
          bind Tooltip$w <Any-Leave> \
            "::baltip hide $w; ::baltip configure -SPECTIPid$w {}"
          bind Tooltip$w <Motion> "::baltip::my::PrepareLbxTip $w %x %y"
        } elseif {$widgetclass eq {Treeview}} {
          # tip for treeview items
          if {[cget -SPECTIP$w] eq {} || [string is true -strict $reset]} {
            configure -SPECTIP$w $text
          }
          bind Tooltip$w <Any-Leave> \
            "::baltip hide $w; ::baltip configure -SPECTIPid$w {}"
          bind Tooltip$w <Motion> "::baltip::my::PrepareTreTip $w %x %y"
        } else {
          bind Tooltip$w <Enter> [list ::baltip::my::Show %W $text no $geo $optvals]
        }
      }
    }
  }
  return {}
}
#_______________________

proc ::baltip::update {w text args} {
  # Updates tip's text and settings.
  #  w - widget's path
  #  text - tip's text
  #  args - tip's settings

  variable my::ttdata
  set my::ttdata(text,$w) $text
  foreach {k v} $args {set my::ttdata([string range $k 1 end],$w) $v}
}
#_______________________

proc ::baltip::repaint {w args} {
  # Repaints a tip immediately.
  #   w - widget's path
  #  args - options (incl. -index/-tag)

  variable my::ttdata
  if {[winfo exists $w] && [info exists my::ttdata(optvals,$w)] && \
  [dict exists $my::ttdata(optvals,$w) -text]} {
    set optvals $my::ttdata(optvals,$w)
    lappend optvals {*}$args
    catch {after cancel $my::ttdata(after)}
    set win [tippath $w] ;# the tip's window
    if {[info exists my::ttdata(winGEO,$win)]} {
      set geo $my::ttdata(winGEO,$win)
    } else {
      set geo {}
    }
    set my::ttdata(after) [after idle [list ::baltip::my::Show $w \
      [dict get $my::ttdata(optvals,$w) -text] yes $geo $optvals]]
  }
}
#_______________________

proc ::baltip::hide {{w ""} {doit no}} {
  # Destroys the tip's window.
  #   w - widget's path
  #   doit - yes, if do hide by force
  # Returns 1, if the window was really hidden.

  variable my::ttdata
  my::Command $w {}
  set res 1
  if {(![my::Eternal $w] && $my::ttdata(balloon) ne $w) || $doit} {
    set res [expr {![catch {destroy [tippath $w]}]}]
    if {$w eq $my::ttdata(balloon)} {set my::ttdata(balloon) -}
  }
  return $res
}
#_______________________

proc ::baltip::clear {w args} {
  # Removes tip bindings for a widget.
  #   w - widget's path

  variable my::ttdata
  catch {unset my::ttdata(optvals,$w)}
  catch {hide $w}
  foreach ev {Any-Leave Any-KeyPress Any-Button Motion Any-Enter Leave Enter} {
    catch {bind Tooltip$w <$ev> {}}
  }
}
#_______________________

proc ::baltip::sleep {msec} {
  # Disables tips for a while.
  #   msec - time to sleep, in msec
  # This is useful esp. before calling a popup menu on listbox/treeview.

  configure -on 0
  after $msec "::baltip::configure -on 1"
}
#_______________________

proc ::baltip::showBalloon {tip args} {
  # Shows a balloon under the pointer or according to -geometry option.
  #   tip - text of tip
  #   args - miscellaneous options of baltip
  # Can be used to show tips on clicking, timeout, processing etc.
  # If there is -geometry in args, shows the balloon
  # with this geometry and a minimal pause.

  variable my::ttdata
  if {![lindex [cget -on] 1]} return
  set w .
  if {[winfo exists $tip]} { ;# when mimics the usual tip: "tip $win $text ..."
    set w $tip
    set tip [lindex $args 0]
    set args [lrange $args 1 end]
  }
  if {[set i [lsearch -exact $args -balloonwindow]]>-1} {
    set w [lindex $args $i+1]
    set args [lreplace $args $i $i+1]
  }
  if {[set isgeo [dict exists $args -geometry]]} {
    lappend args -pause 10
  } else {
    lassign [winfo pointerxy $w] x y
    lappend args -geometry \
      +[expr {$x-int($my::ttdata(under)/2)}]+[expr {$y-$my::ttdata(under)}]
  }
  tip $w $tip -pause 100 -fade 100 {*}$args
  if {$isgeo} {
    after 20
    ::update
  }
}
#_______________________

proc ::baltip::showTip {w tip args} {
  # Shows a tip under the pointer, for a specific widget.
  #   tip - text of tip
  #   args - miscellaneous options of baltip
  # Can be used to show tips on clicking the widget
  # that has no "normal" tips on hovering it.

  my::BindToEvent $w <Leave> ::baltip hide .
  showBalloon $tip {*}$args
}

# _____________________ Internals ____________________ #

proc ::baltip::my::CGet {args} {
  # Gets options' values, using local (args) and global (ttdata) settings.
  #   args - local settings ("name value" pairs)
  # Returns the full list of settings ("name value" pairs, "name" without "-") \
   in which special options go first.
  # See also: cget, configure

  variable ttdata
  set saved [array get ttdata]
  set res [::baltip::configure {*}$args]
  lappend res {*}[::baltip::cget]
  array set ttdata $saved
  return $res
}
#_______________________

proc ::baltip::my::WidCoord {w} {
  # Gets widget's coordinate data.
  #   w - path to the widget
  # Returns a list of:
  #   x - X coordinate
  #   y - Y coordinate
  #   inside - flag "mouse pointer is inside the widget"

  set x [expr {[winfo pointerx $w]-[winfo rootx $w]}]
  set y [expr {[winfo pointery $w]-[winfo rooty $w]}]
  lassign [split [winfo geometry $w] x+] width height
  set inside [expr {$x>-1 && $x<$width && $y>-1 && $y<$height}]
  return [list $x $y $inside]
}
#_______________________

proc ::baltip::my::Clonename {mnu} {
  # Gets a clone name of a menu.
  #   mnu - the menu's path
  # This procedure is borrowed from BWidget's utils.tcl.

  set path [set menupath {}]
  set found 0
  foreach widget [lrange [split $mnu .] 1 end] {
    if {$found || [winfo class "$path.$widget"] eq {Menu}} {
      set found 1
      append menupath # $widget
      append path . $menupath
    } else {
      append menupath # $widget
      append path . $widget
    }
  }
  return $path
}
#_______________________

proc ::baltip::my::OptionsFromText {w txt} {
  # Extracts options from "text" argument of baltip::tip.
  #   w - widget's path
  #   txt - "-text" option's value
  # Options can be set in the "text" argument as uppercased-name / value pairs:
  #   "-BALTIP {True tip's text} -MAXEXP 1 -COMMAND {::mycom %i %c}"
  # In this case, *txt* must be a correct list of name/value sequences.
  # Returns an original *txt* or a value of -BALTIP option from *txt*.

  variable ttdata
  if {[string first {-BALTIP } $txt] >-1 && \
  !([catch {set lst [list {*}$txt]}] || [expr {[llength $lst] % 2 }])} {
    set ol [::baltip::optionlist]
    lappend ol -baltip
    foreach o $ol {lappend OL [string toupper $o]}
    foreach {o v} $lst {
      if {[set i [lsearch -exact $OL $o]]>-1} {
        set n1 [string range [lindex $ol $i] 1 end]
        set ttdata($n1,$w) $v
        if {$o eq {-BALTIP}} {set txt $v}
      }
    }
  } else {
    if {[winfo exists ttdata(optvals,$w)]} {
      catch {
        set txt [dict get $ttdata(optvals,$w) -text]
      }
    }
  }
  return $txt
}
#_______________________

proc ::baltip::my::Eternal {w} {
  # Checks if the tip is shown till clicking.
  #   w - tip/widget's path

  variable ttdata
  set res no
  if {[catch {set res $ttdata(eternal,$w)}]} {
    catch {set res $ttdata(eternal,[winfo parent $w])}
  }
  return $res
}

## ________________________ Binds _________________________ ##

proc ::baltip::my::BindToEvent {w event args} {
  # Binds an event on a widget to a command.
  #   w - the widget's path
  #   event - the event
  #   args - the command
  # The command can be ended with " ; break".

  if {[catch {set bound [bind $w $event]}]} {set bound {}}
  if {[string first $args $bound]<0} {
    catch {
      if {[lrange $args end-1 end] eq "{;} break"} {
        set com [lrange $args 0 end-2]
        bind $w $event "$com ; break"
      } else {
        bind $w $event [list + {*}$args]
      }
    }
  }
}
#_______________________

proc ::baltip::my::BindTextagToEvent {w tag event args} {
  # Binds an event on a text tag to a command.
  #   w - the widget's path
  #   tag - the tag
  #   event - the event
  #   args - the command
  # The command can be ended with " ; break".

  if {[catch {set bound [$w tag bind $tag]}]} {set bound {}}
  if {[string first $args $bound]<0} {
    catch {
      if {[lrange $args end-1 end] eq "{;} break"} {
        set com [lrange $args 0 end-2]
        $w tag bind $tag $event "$com ; break"
      } else {
        $w tag bind $tag $event [list + {*}$args]
      }
    }
  }
}
#_______________________

proc ::baltip::my::BindCantagToEvent {w tag event args} {
  # Binds an event on a canvas tag to a command.
  #   w - the widget's path
  #   tag - the tag
  #   event - the event
  #   args - the command
  # The command can be ended with " ; break".

  if {[catch {set bound [$w bind $tag $event]}]} {set bound {}}
  if {[string first $args $bound]<0} {
    catch {
      if {[lrange $args end-1 end] eq "{;} break"} {
        set com [lrange $args 0 end-2]
        $w bind $tag $event "$com ; break"
      } else {
        $w bind $tag $event [list + {*}$args]
      }
    }
  }
}

## ________________________ Shows _________________________ ##

proc ::baltip::my::Command {w text args} {
  # Executes a command set for a window.
  #   w - the widget's path
  #   text - the tip text
  #   args - command's arguments
  # The command allows wildcards:
  #   %w - window's path
  #   %t - text of the tip
  # Returns: list of "yes/no" and a result of the command.
  # The result of the command can be a new tip if "yes" and the result ne {}.

  variable ttdata
  if {![info exists ttdata(command,$w)] || $ttdata(command,$w) eq {} ||
  [winfo class $w] eq {TNotebook} && ![llength $args]} {
    # command is not complete
    return no
  }
  set com [string map [list %w $w %t "{$text}" %a $args] $ttdata(command,$w)]
  if {[catch {set res [eval $com]} e]} {return no}
  if {$text ne {}} {
    set ttdata(text,$w) $res
  }
  return [list yes $res]
}
#_______________________

proc ::baltip::my::ShowWindow {win} {
  # Shows a window of tip.
  #   win - the tip's window

  variable ttdata
  if {![winfo exists $win] || ![info exists ttdata(winGEO,$win)]} return
  set geo $ttdata(winGEO,$win)
  set under $ttdata(winUNDER,$win)
  set shiftX $ttdata(winSHIFTX,$win)
  set shiftY $ttdata(winSHIFTY,$win)
  set w [winfo parent $win]
  set px [winfo pointerx .]
  set py [winfo pointery .]
  set width [winfo reqwidth $win.label]
  set height [winfo reqheight $win.label]
  set ady 0
  if {[catch {set wheight [winfo height $w]}]} {
    set wheight 0
  } else {
    for {set i 0} {$i<$wheight} {incr i} {  ;# find the widget's bottom
      incr py
      incr ady
      if {![string match $w* [winfo containing $px $py]]} break
    }
  }
  if {$geo eq {}} {
    if {$shiftX ne {}} {
      set x [expr {$px + $shiftX}]
    } else {
      set x [expr {max(1,$px - round($width / 2.0))}]
    }
    set y [expr {$under>=0 ? ($py + $under) : ($py - $under - $ady)}]
    if {$shiftY ne {}} {incr y $shiftY}
  } else {
    lassign [split $geo +] -> x y
    set x [expr [string map "W $width" $x]]  ;# W to shift horizontally
    set y [expr [string map "H $height" $y]] ;# H to shift vertically
  }
  # check for edges of screen incl. decors
  set scrw [winfo vrootwidth .]
  set scrh [winfo vrootheight .]
  if {($x + $width) > $scrw}  {set x [expr {$scrw - $width - 1}]}
  if {($y + $height) > $scrh} {set y [expr {$py - $height - 16}]}
  set x [expr {max(0,$x)}]
  set y [expr {max(0,$y)}]
  wm geometry $win [join  "$width x $height + $x + $y" {}]
  catch {wm deiconify $win ; raise $win}
}
#_______________________

proc ::baltip::my::Show {args} {
  # Calls DoShow catching errors.

  catch {DoShow {*}$args}
}
#_______________________

proc ::baltip::my::DoShow {w text force geo optvals} {
  # Creates and shows the tip's window.
  #   w - the widget's path
  #   text - the tip text
  #   force - if true, re-displays the existing tip
  #   geo - being +X+Y, sets the tip coordinates
  #   optvals - settings ("option value" pairs)
  # See also: Fade, ShowWindow, ::baltip::update

  variable ttdata
  if {![winfo exists $w]} return
  set win [::baltip::tippath $w]
  # keep the label's colors untouched (for apave package)
  catch {::apave::obj untouchWidgets $win.label}
  set px [winfo pointerx .]
  set py [winfo pointery .]
  array set data $optvals
  if {[info exists ttdata(optvals,$w)]} {
    catch {array set data [list {*}$ttdata(optvals,$w) {*}$optvals]}
  }
  if {$geo ne {}} {
    # balloons not related to widgets
  } elseif {$ttdata(global,$w)} {      ;# flag 'use global settings'
    array set data [::baltip::cget]
  } else {
    foreach k [array names ttdata -glob *,$w] {
      set n1 [lindex [split $k ,] 0]   ;# settings set by 'update'
      if {$n1 eq {text}} {
        if {$ttdata($k) ne {}} {
          set text $ttdata($k)         ;# tip's text
        }
      } else {
        set data(-$n1) $ttdata($k)     ;# tip's options
      }
    }
  }
  if {[catch {set widgetclass [winfo class $w]}]} {
    set widgetclass {}
  }
  if {!$force && $geo eq {}} {
    if {![info exists ttdata(on,$w)] || !$ttdata(on,$w)} return
    if {$widgetclass ne {Menu} && \
    ([winfo exists $win] || ![string match $w* [winfo containing $px $py]])} {
      return
    }
  }
  if {$geo eq {}} {::baltip::hide $w}
  set icount [string length [string trim $text]]
  if {!$icount || (!$ttdata(on) && !$data(-on))} return
  lassign [Command $w $text] ans res
  if {$ans} {
    if {$res eq {}} {
      # the command displayed the tip somewhere
      return
    }
    # the command redefined the tip's text
    set text $res
  }
  if {[info exists ttdata(maxexp,$w)] && \
  [string is integer -strict $ttdata(maxexp,$w)]} {
    if {$ttdata(maxexp,$w)<=0} return
  }
  catch {::baltip::hide $ttdata(REGISTERED)}
  set ttdata(REGISTERED) $w
  if {$data(-fg) eq {}} {set data(-fg) black}
  if {$data(-bg) eq {}} {set data(-bg) #FBFB95}
  catch {destroy $win}
  toplevel $win -bg $data(-bg) -class Tooltip$w
  catch {wm withdraw $win}
  wm overrideredirect $win 1
  if {[info exists data(-ontop)] && $data(-ontop)} {
    wm attributes $win -topmost 1
  } else {
    wm attributes $win -topmost 0 ;# maybe this would work in a new Tk
  }
  if {$data(-relief) eq {}} {set data(-relief) solid}
  if {[set imgoptions $data(-image)] ne {}} {
    set imgoptions "-image $imgoptions"
  }
  if {[set cmpdoptions $data(-compound)] ne {}} {
    set cmpdoptions "-compound $cmpdoptions"
  }
  if {$imgoptions ne {} && $cmpdoptions eq {}} {
    set cmpdoptions {-compound left}
  }
  pack [label $win.label -text $text -justify left -relief $data(-relief) \
    -bd $data(-bd) -bg $data(-bg) -fg $data(-fg) -font $data(-font) \
    {*}$imgoptions {*}$cmpdoptions -padx $data(-padx) -pady $data(-pady)] \
    -padx $data(-padding) -pady $data(-padding)
  if {[info exists ttdata(focus,$w)]} {
    set foc $ttdata(focus,$w)
    after idle "catch {focus -force \[winfo toplevel $foc\]}; catch {focus $foc}"
  }
  # defeat rare artifact by passing mouse over a tip to destroy it
  bindtags $win "Tooltip$win"
  if {$geo eq {}} {
    # balloons are hidden on click or time-out
    bind $win <Any-Enter> "::baltip::hide $w"
    bind Tooltip$win <Any-Enter>  "::baltip::hide $w"
  }
  set butcom "::baltip::hide $w 1"
  catch {if {$ttdata(onmouse,$w) ne {}} {set butcom $ttdata(onmouse,$w)}}
  bind $win <Any-Button> $butcom
  bind Tooltip$win <Any-Button> $butcom
  set aint 20
  set fint [expr {int($data(-fade)/$aint)}]
  set icount [expr {int($data(-per10)/$aint*$icount/10.0)}]
  set icount [expr {$data(-per10) ? max(1000/$aint+1,$icount) : 0}] ;# 1 sec. minimum
  set ttdata(winGEO,$win) $geo
  set ttdata(winUNDER,$win) $data(-under)
  set ttdata(winSHIFTX,$win) $data(-shiftX)
  set ttdata(winSHIFTY,$win) $data(-shiftY)
  if {$icount} {
    if {$geo eq {}} {
      catch {wm attributes $win -alpha $data(-alpha)}
    } else {
      Fade $win $aint [expr {round(1.0*$data(-pause)/$aint)}] \
        0 Un $data(-alpha) 1 $geo {} $w
    }
    if {$force} {
      Fade $win $aint $fint $icount {} $data(-alpha) 1 $geo {} $w
    } elseif {$widgetclass ne {TNotebook}} {
      catch {after cancel $ttdata(after)}
      set ttdata(after) [after $data(-pause) [list \
        ::baltip::my::Fade $win $aint $fint $icount {} $data(-alpha) 1 $geo {} $w]]
    }
  } else {
    # just showing, no fading
    catch {after cancel $ttdata(after)}
    set ttdata(after) [after $data(-pause) \
      "::baltip::my::ShowWindow $win; catch {wm attributes $win -alpha $data(-alpha)}"]
  }
  if {$data(-bell)} [list after [expr {$data(-pause)/4}] bell]
  array unset data
}

## ________________________ Fade _________________________ ##

proc ::baltip::my::Fade {win aint fint icount Un alpha show geo {geos ""} {w {}}} {
  # Fades/unfades the tip's window.
  #   win - the tip's window
  #   aint - interval for 'after'
  #   fint - interval for fading
  #   icount - counter of intervals
  #   Un - if equal to "Un", unfades the tip
  #   alpha - value of -alpha option
  #   show - flag "show the window"
  #   geo - coordinates (+X+Y) of balloon
  #   geos - saved coordinates (+X+Y) of shown tip
  #   w - a host window
  # See also: FadeNext, UnFadeNext

  variable ttdata
  if {[winfo exists $win]} {
    if {$show && [info exists ttdata(maxexp,$w)] && \
    [string is integer -strict $ttdata(maxexp,$w)]} {
      incr ttdata(maxexp,$w) -1
    }
    update
    catch {after cancel $ttdata(after)}
    set ttdata(after) [after idle [list after $aint \
      [list ::baltip::my::${Un}FadeNext $win $aint $fint $icount $alpha $show $geo $geos]]]
  }
}
#_______________________

proc ::baltip::my::FadeNext {w aint fint icount alpha show geo {geos ""}} {
  # A step to fade the tip's window.
  #   w - the tip's window
  #   aint - interval for 'after'
  #   fint - interval for fading
  #   icount - counter of intervals
  #   alpha - value of -alpha option
  #   show - flag "show the window"
  #   geo - coordinates (+X+Y) of balloon
  #   geos - saved coordinates (+X+Y) of shown tip
  # See also: Fade

  variable ttdata
  incr icount -1
  if {$show} {ShowWindow $w}
  set show 0
  if {![winfo exists $w]} return
  lassign [split [wm geometry $w] +] -> X Y
  if {$geos ne {} && $geos ne "+$X+$Y"} return
  if {$fint<=0} {set fint 10}
  if {[catch {set al [expr {min($alpha,($fint+$icount*1.5)/$fint)}]}]} {
    set al 0
  }
  if {$icount<0} {
    if {[Eternal $w]} return
    if {$al>0} {
      if {[catch {wm attributes $w -alpha $al}]} {set al 0}
    }
    if {$al<=0.001 || ![winfo exists $w]} {
      ::baltip::hide
      catch {destroy $w}
      return
    }
  } elseif {$al>0 && $geo eq {}} {
    if {![Eternal $ttdata(balloon)] && $ttdata(balloon) ne {-}} {
      ::baltip::hide $ttdata(balloon) yes  ;# non-eternal balloon be destroyed
    }
    catch {wm attributes $w -alpha $al}
  }
  Fade $w $aint $fint $icount {} $alpha $show $geo +$X+$Y
}
#_______________________

proc ::baltip::my::UnFadeNext {w aint fint icount alpha show geo {geos ""}} {
  # A step to unfade the balloon's window.
  #   w - the tip's window
  #   aint - interval for 'after'
  #   fint - interval for fading
  #   icount - counter of intervals
  #   alpha - value of -alpha option
  #   show - not used (here just for compliance with Fade)
  #   geo - not used (here just for compliance with Fade)
  #   geos - not used (here just for compliance with Fade)
  # See also: Fade

  incr icount
  set al [expr {min($alpha,$icount*1.5/$fint)}]
  if {$al<$alpha && [catch {wm attributes $w -alpha $al}]} {set al 1}
  if {$show} {
    ShowWindow $w
    set show 0
  }
  if {[winfo exists $w] && $al<$alpha} {
    Fade $w $aint $fint $icount Un $alpha 0 $geo
  }
}

## ________________________ Specific widgets _________________________ ##

### ________________________ Tags _________________________ ###

proc ::baltip::my::TagTip {w {tag ""} {optvals ""}} {
  # Shows a text tag's tip.
  #   w - the text's path
  #   tag - the tag's name
  #   optvals - settings of tip

  variable ttdata
  ::baltip::hide $w
  if {$tag eq {}} return
  ::baltip::my::Show $w $ttdata($w,$tag) no {} $optvals
}

### ________________________ Menu _________________________ ###

proc ::baltip::my::MenuTip {wt} {
  # Shows a menu's tip.
  #   wt - the menu's path (incl. cloned menu)

  variable ttdata
  if {[string match .tearoff* $wt]} {
    # not implemented for tear-offed menus
    return
  }
  ::baltip::hide $wt
  set index [$wt index active]
  set mit "$wt/$index"
  if {$index eq {none}} return
  if {[info exists ttdata($wt,$index)] && ([::baltip::hide $wt] || \
  ![info exists ttdata(LASTMITEM)] || $ttdata(LASTMITEM) ne $mit)} {
    set optvals $ttdata($wt,$index)
    set text [dict get $optvals -text]
    ::baltip::my::Show $wt $text no {} $optvals
  }
  set ttdata(LASTMITEM) $mit
}

### ________________________ Notebook _________________________ ###

proc ::baltip::my::NbkInfo {w x y {tab {}}} {
  # Gets/sets a notebook tab's data.
  #   w - the notebook's path
  #   x - X coordinate of pointer
  #   y - Y coordinate of pointer
  #   tab - a current tab
  # When getting, returns a list of a current tab and a saved tab.

  set optid -SPECTIP$w
  if {$tab eq {}} {
    set tab [$w identify tab $x $y]
    set tab2 [lindex [::baltip cget $optid] 1]
    return [list $tab $tab2]
  }
  ::baltip configure $optid $tab
}

#_______________________

proc ::baltip::my::ShowNbkTip {w tip} {
  # Shows a tip for a notebook tab.
  #   w - the notebook's path
  #   tip - text of tip

  catch {
    set x [expr {[winfo pointerx $w]-[winfo rootx $w]}]
    set y [expr {[winfo pointery $w]-[winfo rooty $w]}]
    lassign [NbkInfo $w $x $y] tab tab2
    set wt [lindex [$w tabs] $tab]
    if {$tab2 ne {-} && [lsearch -exact [$w tabs] $wt]>-1} {
      ::baltip tip $w $tip -force yes
    } else {
      ::baltip hide $w
    }
  }
}

#_______________________

proc ::baltip::my::PrepareNbkTip {w x y} {
  # Prepares a tip for a notebook tab.
  #   w - the notebook's path
  #   x - X coordinate of pointer
  #   y - Y coordinate of pointer
  # The baltip isn't directly usable with notebook tabs
  # because they have not Enter/Leave event bindings.
  # This proc tries to imitate those events, with binding to <Motion> event.

  if {![string is integer -strict $x]} return
  catch {
    lassign [::baltip cget -pause] -> pause
    lassign [NbkInfo $w $x $y] tab tab2
    set nbktab [lindex [$w tabs] $tab]
    if {$nbktab ne {} && $tab ne {} && $tab2 ni "$tab -"} {
      ::baltip hide $w
      lassign [::baltip cget -SPECTIP$nbktab] -> tip
      lassign [Command $w $tip $nbktab [winfo name $nbktab]] ans res
      if {$ans} {
        if {$res ne {}} {
          # the command should be displayed here (not somewhere else)
          set ans no
        }
        # the command redefined the tip's text
        set tip $res
      }
      if {!$ans} {
        set optafter -SPECTIPafter$w
        catch {
          after cancel [lindex [::baltip cget $optafter] 1]
        }
        set aftid [after $pause "::baltip::my::ShowNbkTip $w {$tip}"]
        ::baltip configure $optafter $aftid
      }
    } else {
      NbkInfo $w $x $y -1
    }
    NbkInfo $w $x $y $tab
  }
}

### ________________________ Listbox _________________________ ###

proc ::baltip::my::LbxCoord {w} {

  # Gets listbox's coordinate data.
  #   w - path to the listbox
  # Returns a list of:
  #   x - X coordinate
  #   y - Y coordinate
  #   idx - index of listbox's item
  #   inside - flag "mouse pointer is inside the listbox"

  lassign [WidCoord $w] x y inside
  set idx [$w index @$x,$y]
  return [list $x $y $idx $inside]
}
#_______________________

proc ::baltip::my::LbxTip {w idx whole} {
  # Gets a text of a listbox' tip.
  #   w - the listbox's path
  #   idx - index of listbox's item
  #   whole - flag "tip for a whole listbox, not per item"

  lassign [::baltip cget -SPECTIP$w] - com
  if {$whole} {
    set tip [string map "%%i %i" $com]
  } else {
    set com [string map [list %i $idx] $com]
    if {[catch {set tip [eval $com]}]} {set tip $com}
  }
  return $tip
}
#_______________________

proc ::baltip::my::ShowLbxTip {w optid idx whole} {
  # Shows a tip for a listbox.
  #   w - the listbox's path
  #   optid - option name for saving *idx*
  #   idx - index of listbox's item
  #   whole - flag "tip for a whole listbox, not per item"

  catch {
    lassign [LbxCoord $w] x y idx inside
    if {$inside} {
      set tip [LbxTip $w $idx $whole]
      ::baltip configure $optid $idx
      ::baltip tip $w $tip -force yes
    } else {
      ::baltip hide $w
      ::baltip configure $optid {}
    }
  }
}
#_______________________

proc ::baltip::my::PrepareLbxTip {w x y} {
  # Prepares a tip for a listbox.
  #   w - the listbox's path
  #   x - X coordinate of pointer
  #   y - Y coordinate of pointer
  # Imitates Enter/Leave events per items, with binding to <Motion> event.
  # If "-text" of tip doesn't contain %i, the tip is for a whole listbox.
  # If "-text" of tip contains %i, the tip is a callback with %i as item index.

  if {![string is integer -strict $x]} return
  catch {
    set idx [$w index @$x,$y]
    lassign [::baltip cget -pause] -> pause
    set optid -SPECTIPid$w
    lassign [::baltip cget $optid] -> idx2
    lassign [LbxCoord $w] x y idx inside
    if {$inside && $idx!=$idx2} {
      lassign [::baltip cget -SPECTIP$w] - com
      set com [string map "%%i \u0001" $com]
      set whole [expr {[string first %i $com]==-1}]
      set com [string map "\u0001 %i" $com]
      set text [LbxTip $w $idx $whole]
      if {$whole && $idx2 ne {}} {
        Command $w $text
        return  ;# tip for a whole listbox at entering
      }
      ::baltip hide $w
      lassign [Command $w $text] ans res
      if {$ans} {
        if {$res ne {}} {
          # the command should be displayed here (not somewhere else)
          set $ans no
        }
        # the command redefined the tip's text
        set text $res
      }
      if {!$ans} {
        set optafter -SPECTIPafter$w
        catch {after cancel [lindex [::baltip cget $optafter] 1]}
        set aftid [after $pause "::baltip::my::ShowLbxTip $w $optid $idx $whole"]
        ::baltip configure $optafter $aftid
      }
      ::baltip configure $optid $idx
    }
  }
}

### ________________________ Treeview _________________________ ###

proc ::baltip::my::TreCoord {w whole} {
  # Gets treeview's coordinate data.
  #   w - path to the treeview
  #   whole - flag "tip for a whole treeview, not per item"
  # Returns a list of:
  #   x - X coordinate
  #   y - Y coordinate
  #   id - ID of item
  #   c - column of item
  #   inside - flag "mouse pointer is inside the treeview"

  lassign [WidCoord $w] x y inside
  set id [$w identify item $x $y]
  set c [$w identify column $x $y]
  if {!$whole && [$w identify region $x $y] eq {heading}} {
    set inside no
  }
  return [list $x $y $id $c $inside]
}
#_______________________

proc ::baltip::my::TreTip {w id c whole} {
  # Gets a text of a treeview' tip.
  #   w - the treeview's path
  #   id - ID of item
  #   c - column of item
  #   whole - flag "tip for a whole treeview, not per item"

  lassign [::baltip cget -SPECTIP$w] - com
  if {$whole} {
    set tip [string map "%%i %i %%c %c" $com]
  } else {
    set tip {}
    set com [string map [list %i $id %c $c] $com]
    if {$id ne {} && [catch {set tip [eval $com]}]} {set tip $com}
  }
  return $tip
}
#_______________________

proc ::baltip::my::ShowTreTip {w optid id whole} {
  # Shows a tip for a treeview.
  #   w - the treeview's path
  #   optid - option name for saving *id*
  #   id - ID of item
  #   whole - flag "tip for a whole treeview, not per item"

  catch {
    lassign [TreCoord $w $whole] x y id c inside
    if {$inside} {
      set tip [TreTip $w $id $c $whole]
      ::baltip configure $optid [list $id $c]
      ::baltip tip $w $tip -force yes
    } else {
      ::baltip hide $w
      ::baltip configure $optid {}
    }
  }
}
#_______________________

proc ::baltip::my::PrepareTreTip {w x y} {
  # Prepares a tip for a treeview.
  #   w - the treeview's path
  #   x - X coordinate of pointer
  #   y - Y coordinate of pointer
  # Imitates Enter/Leave events per items, with binding to <Motion> event.
  # If "-text" of tip doesn't contain %i, the tip is for a whole treeview.
  # If "-text" of tip contains %i, the tip is a callback with %i as item index.

  if {![string is integer -strict $x]} return
  catch {
    set id [$w identify item $x $y]
    lassign [::baltip cget -pause] -> pause
    set optid -SPECTIPid$w
    lassign [lindex [::baltip cget $optid] 1] id2 c2
    lassign [::baltip cget -SPECTIP$w] - com
    set com [string map "%%i \u0001 %%c \u0002" $com]
    set isid [expr {[string first %i $com]>-1}]
    set isc  [expr {[string first %c $com]>-1}]
    set whole [expr {!$isid && !$isc}]
    set com [string map "\u0001 %i \u0002 %c" $com]
    lassign [TreCoord $w $whole] x y id c inside
    if {$whole || ($inside && $id ne {} && $c ne {} &&
    (($isid && $id ne $id2) || ($isc && $c ne $c2)))} {
      set text [TreTip $w $id $c $whole]
      if {$whole && $id2 ne {}} {
        Command $w $text
        return  ;# tip for a whole treeview at entering
      }
      lassign [Command $w $text] ans res
      if {$ans} {
        if {$res ne {}} {
          # the command should be displayed here (not somewhere else)
          set $ans no
        }
        # the command redefined the tip's text
        set text $res
      }
      if {!$ans} {
        ::baltip hide $w
        set optafter -SPECTIPafter$w
        catch {after cancel [lindex [::baltip cget $optafter] 1]}
        set aftid [after $pause "::baltip::my::ShowTreTip $w $optid {$id} $whole"]
        ::baltip configure $optafter $aftid
      }
      ::baltip configure $optid [list $id $c]
    } elseif {$id eq {}} {
      ::baltip hide $w
      ::baltip configure $optid {}
    }
  }
}

# ________________________________ EOF __________________________________ #
