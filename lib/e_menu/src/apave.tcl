###########################################################
# Name:    apave.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    12/09/2021
# Brief:   Handles APave class creating input dialogs.
# License: MIT.
###########################################################

package require Tk
package provide apave 4.4.9

source [file join [file dirname [info script]] apavedialog.tcl]

# ________________________ Independent procs _________________________ #

proc ::iswindows {} {
  # Checks for "platform is MS Windows".

  expr {$::tcl_platform(platform) eq {windows}}
}

proc ::isunix {} {
  # Checks for "platform is Unix".

  expr {$::tcl_platform(platform) eq {unix}}
}

proc ::isKDE {} {
  # Checks for "desktop is KDE".

  expr {[info exists ::env(XDG_CURRENT_DESKTOP)] && $::env(XDG_CURRENT_DESKTOP) eq {KDE}}
}

proc ::asKDE {} {
  # Checks for DE behaving as weird as KDE.

  expr {[::isKDE] && ![package vsatisfies [package require Tcl] 8.6.11-]}
}
# ________________________ apave NS _________________________ #

namespace eval ::apave {

  namespace export obj openDoc textsplit focusByForce *TextFile undo* *Option*

  mainWindowOfApp .

  variable _OBJ_ {}

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

  proc None {args} {
    # Useful when to do nothing is better than to do something.

  }
  #_______________________

  proc autoexec {comm {ext ""}} {
    # Imitates Tcl's auto_execok.
    #   comm - a command to find
    #   ext - file's extension (for Windows)
    # If it doesn't get the command from Tcl's auto_execok,
    # it tries to knock at its file by itself.

    if {$ext ne {} && [::iswindows]} {append comm $ext}
    set res [auto_execok $comm]
    if {$res eq {} && [file exists $comm]} {
      set res $comm
    }
    return $res
  }
  #_______________________

  proc openDoc {url} {
    # Opens a document.
    #   url - document's file name, www link, e-mail etc.

    set commands {xdg-open open start}
    foreach opener $commands {
      if {$opener eq "start"} {
        set command [list {*}[auto_execok start] {}]
      } else {
        set command [auto_execok $opener]
      }
      if {[string length $command]} {
        break
      }
    }
    if {[string length $command] == 0} {
      puts "ERROR: couldn't find any opener"
    }
    # remove the tailing " &" (as e_menu can set)
    set url [string trimright $url]
    if {[string match "* &" $url]} {set url [string range $url 0 end-2]}
    set url [string trim $url]
    if {[catch {exec -- {*}$command $url &} error]} {
      puts "ERROR: couldn't execute '$command':\n$error"
    }
  }
  #_______________________

  proc countChar {str ch} {
    # Counts a character in a string.
    #   str - a string
    #   ch - a character
    #
    # Returns a number of non-escaped occurences of character *ch* in
    # string *str*.
    #
    # See also:
    # [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/Reformatting+Tcl+code+indentation)

    set icnt 0
    while {[set idx [string first $ch $str]] >= 0} {
      set backslashes 0
      set nidx $idx
      while {[string equal [string index $str [incr nidx -1]] \\]} {
        incr backslashes
      }
      if {$backslashes % 2 == 0} { incr icnt }
      set str [string range $str [incr idx] end]
    }
    return $icnt
  }
  #_______________________

  proc traceRemove {v} {
    # Cancels tracing of a variable.
    #   v - variable's name

    foreach t [trace info variable $v] {
      lassign $t o c
      trace remove variable $v $o $c
    }
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

  ## ________________________ Integers _________________________ ##


  proc getN {sn {defn 0} {min ""} {max ""}} {
    # Gets a number from a string
    #   sn - string containing a number
    #   defn - default value when sn is not a number
    #   min - minimal value allowed
    #   max - maximal value allowed

    if {$sn eq "" || [catch {set sn [expr {$sn}]}]} {set sn $defn}
    if {$max ne ""} {
      set sn [expr {min($max,$sn)}]
    }
    if {$min ne ""} {
      set sn [expr {max($min,$sn)}]
    }
    return $sn
  }
  #_______________________

  proc p+ {p1 p2} {
    # Sums two text positions straightforward: lines & columns separately.
    #   p1 - 1st position
    #   p2 - 2nd position
    # The lines may be with "-".
    # Reasons for this:
    #  1. expr $p1+$p2 doesn't work, e.g. 309.10+1.4=310.5 instead of 310.14
    #  2. do it without a text widget's path (for text's arithmetic)

    lassign [split $p1 .] l11 c11
    lassign [split $p2 .] l21 c21
    foreach n {l11 c11 l21 c21} {
      if {![string is digit -strict [string trimleft [set $n] -]]} {set $n 0}
    }
    return [incr l11 $l21].[incr c11 $c21]
  }
  #_______________________

  proc pint {pos} {
    # Gets int part of text position, e.g. "4" for "4.end".
    #   pos - position in text

    if {[set i [string first . $pos]]>0} {incr i -1} {set i end}
    expr {int([string range $pos 0 $i])}
  }
  #_______________________

  proc intInRange {int min max} {
    # Checks whether an integer is in min-max range.
    #   int - the integer
    #   min - minimum of the range
    #   max - maximum of the range

    expr {[string is integer -strict $int] && $int>=$min && $int<=$max}
  }
  #_______________________

  proc IsRoundInt {i1 i2} {
    # Checks whether an integer equals roundly to other integer.
    #   i1 - integer to compare
    #   i2 - integer to be compared (rounded) to i1

    expr {$i1>($i2-3) && $i1<($i2+3)}
  }

  ## _______________________ Lists, arrays _______________________ ##

  proc lsearchFile {flist fname} {
    # Searches a file name in a list, using normalized file names.
    #   flist - list of file names
    #   fname - file name to find
    # Returns an index of found file name or -1 if it's not found.

    set i 0
    set fname [file normalize $fname]
    foreach fn $flist {
      if {[file normalize $fn] eq $fname} {
        return $i
      }
      incr i
    }
    return -1
  }
  #_______________________

  proc RestoreArray {arName arSave} {
    # Tries restoring an array 1:1.
    #   arName - fully qualified array name
    #   arSave - saved array's value (got with "array get")
    # At restoring, new items of $arName are deleted and existing items are updated,
    # so that after restoring *array get $arName* is equal to $arSave.
    # Note: "array unset $arName *; array set $arName $arSave" doesn't ensure this equality.

    set ar $arName
    array set artmp $arSave
    set tmp1 [array names artmp]
    set tmp2 [array names $arName]
    foreach n $tmp2 {
      if {$n ni $tmp1} {unset [set ar]($n)} {set [set ar]($n) $artmp($n)}
    }
    foreach n $tmp1 {
      # deleted items can break 1:1 equality (not the case with alited)
      if {$n ni $tmp2} {set [set ar]($n) $artmp($n)}
    }
  }
  #_______________________

  proc EnsureArray {arName args} {
    # Ensures restoring an array at calling a proc.
    #   arName - fully qualified array name
    #   args - proc name & arguments

    set arSave [array get $arName]
    {*}$args
    RestoreArray $arName $arSave
  }
  #_______________________

  proc PushInList {listName item {pos 0} {max 16}} {
    # Pushes an item in a list: deletes an old instance, inserts a new one.
    #   listName - the list's variable name
    #   item - item to push
    #   pos - position in the list to push in
    #   max - maximum length of the list

    upvar $listName ln
    if {[set i [lsearch -exact $ln $item]]>-1} {
      set ln [lreplace $ln $i $i]
    }
    set ln [linsert $ln $pos $item]
    catch {set ln [lreplace $ln $max end]}
  }

  ## ________________________ Widgets _________________________ ##

  proc checkGeometry {geo} {
    # Checks a window's geometry.
    #   geo - the geometry
    # Returns a "normalized" geometry (+0+0 if input not correct).

    if {!([regexp {^\d+x\d+\+-?\d+\+-?\d+$} $geo] ||
    [regexp {^\+-?\d+\+-?\d+$} $geo] || [regexp {^\d+x\d+$} $geo])} {
      set geo +0+0
    }
    return $geo
  }
  #_______________________

  proc repaintWindow {win {wfoc ""}} {
    # Shows a window and, optionally, focuses on a widget of it.
    #   win - the window's path
    #   wfoc - the widget's path or a command to get it
    # Returns yes, if the window is shown successfully.

    if {[winfo exists $win]} {
      # esp. for KDE
      if {[isKDE]} { ;# KDE is KDE, Tk is Tk, and never the twain shall meet
        wm withdraw $win
        wm deiconify $win
        wm attributes $win -topmost [wm attributes $win -topmost]
      }
      update
      if {$wfoc ne {}} {
        catch {set wfoc [{*}$wfoc]}
        focus $wfoc
      }
      return yes
    }
    return no
  }
  #_______________________

  proc rootModalWindow {pwin} {
    # Gets a parent modal window for a given one.
    #   pwin - default parent

    set root $pwin
    foreach w [winfo children $pwin] {
      if {[winfo ismapped $w] && [InfoFind $w yes] ne {}} {
        set root [winfo toplevel $w]
      }
    }
    return $root
  }
  #_______________________

  proc splitGeometry {geom {X +0} {Y +0}} {
    # Gets widget's geometry components.
    #   geom - geometry
    #   X - default X-coordinate
    #   Y - default Y-coordinate
    # Returns a list of width, height, X and Y (coordinates are always with + or -)
    # and also a flag "negative coordinates, calculated from bottom right".

    lassign [split $geom x+-] w h
    lassign [regexp -inline -all {([+-][[:digit:]]+)} $geom] -> x y
    if {$geom ne {}} {
      if {$x in {"" 0} || [catch {expr {$x+0}}]} {set x $X}
      if {$y in {"" 0} || [catch {expr {$y+0}}]} {set y $Y}
    }
    set neg [expr {[string first - $geom]>=0 && [string first + $geom]<0}]
    list $w $h $x $y $neg
  }
  #_______________________

  proc focusFirst {w {dofocus yes} {res {}}} {
    # Sets a focus on a first widget of a parent widget.
    #  w - the parent widget
    #  dofocus - if no, means "only return the widget's path"
    #  res - used for recursive call
    # Returns a path to a focused widget or "".

    if {$w ne {}} {
      foreach w [winfo children $w] {
        if {[focusedWidget $w]} {
          if {$dofocus} {after 200 "catch {focus -force $w}"}
          return $w
        } else {
          if {[set res [focusFirst $w $dofocus]] ne {}} break
        }
      }
    }
    return $res
  }
  #_______________________

  proc focusedWidget {w} {
    # Gets a flag "is a widget can be focused".
    #   w - widget's path

    set wclass [string tolower [winfo class $w]]
    foreach c [list entry text button box list view] {
      if {[string match *$c $wclass]} {
        if {[catch {set state [$w cget -state]}]} {set state normal}
        if {$state ne {disabled}} {
          if {[catch {set focus [$w cget -takefocus]}]} {set focus no}
          return [expr {![string is boolean -strict $focus] || $focus}]
        }
        break
      }
    }
    return no
  }
  #_______________________

  proc MouseOnWidget {w1} {
    # Places the mouse pointer on a widget.
    #   w1 - the widget's path

    update
    set w2 [winfo parent $w1]
    set w3 [winfo parent $w2]
    lassign [split [winfo geometry $w1] +x] w h x1 y1
    lassign [split [winfo geometry $w2] +x] - - x2 y2
    event generate $w3 <Motion> -warp 1 \
      -x [expr {$x1+$x2+int($w/2)}] -y [expr {$y1+$y2+int($h/2)}]
  }
  #_______________________

  proc CursorAtEnd {w} {
    # Sets the cursor at the end of a field.
    #   w - the field's path

    focus $w
    $w selection clear
    $w icursor end
  }
  #_______________________

  proc focusByForce {foc {cnt 10}} {
    # Focuses a widget.
    #   foc - widget's path

    if {[incr cnt -1]>0} {
      after idle after 5 ::apave::focusByForce $foc $cnt
    } else {
      catch {focus -force [winfo toplevel $foc]; focus $foc}
    }
  }
  #_______________________

  proc KeyAccelerator {acc} {
    # Returns a key accelerator.
    #   acc - key name, may contain 2 items (e.g. Control-D Control-d)

    set acc [lindex $acc 0]
    string map {Control Ctrl - + bracketleft [ bracketright ]} $acc
  }
  #_______________________

  proc InvertBg {clr {B #000000} {W #FFFFFF}} {
    # Gets a "inverted" color (white/black) for an color.
    #   clr - color (#hhh or #hhhhhh)
    #   B - "black" color
    #   W - "white" color
    # Returns a list of "black/white" and normalized input color

    if {[string length $clr]==4} {
      lassign [split $clr {}] -> r g b
      set clr #$r$r$g$g$b$b
    }
    lassign [winfo rgb . $clr] r g b
    if {($r%256+$b%256)<15 && ($g%256)>180 || $r+1.5*$g+0.5*$b > 100000} {
      set res $B
    } else {
      set res $W
    }
    list $res $clr
  }

  ### ________________________ Blinking widgets _________________________ ###

  proc blinkWidget {w {fg #000} {bg #fff} {fg2 {}} {bg2 red} \
    {pause 1000} {count -1} {mode 1}} {
    # Makes a widget blink.
    #   w - the widget's path
    #   fg - normal foreground color
    #   bg - normal background color
    #   fg2 - blinking foreground color (if {}, stops the blinking)
    #   bg2 - blinking background color
    #   pause - pause in millisec between blinkings
    #   count - means how many times do blinking
    #   mode - for recursive calls

    if {![winfo exists $w]} return
    if {$count==0 || $fg2 eq {}} {
      catch {after cancel $::apave::BLINKWIDGET1}
      catch {after cancel $::apave::BLINKWIDGET2}
      after idle "$w configure -foreground $fg; $w configure -background $bg"
    } elseif {$mode==1} {
      incr count -1
      $w configure -foreground $fg2
      $w configure -background $bg2
      set ::apave::BLINKWIDGET1 [after \
        $pause ::apave::blinkWidget $w $fg $bg $fg2 $bg2 $pause $count 2]
    } elseif {$mode==2} {
      $w configure -foreground $fg
      $w configure -background $bg
      set ::apave::BLINKWIDGET2 [after \
        $pause ::apave::blinkWidget $w $fg $bg $fg2 $bg2 $pause $count 1]
    }
  }
  #_______________________

  proc blinkWidgetImage {w img1 {img2 alimg_none} {cnt 6} {ms 100}} {
    # Makes a widget's image blink.
    #   w - widget's path
    #   img1 - main image
    #   img2 - flashed image
    #   cnt - count of flashes
    #   ms - millisec between flashes

    set imgcur $img1
    if {$cnt>0} {
      if {$cnt % 2} {set imgcur $img2}
      after $ms "::apave::blinkWidgetImage $w $img1 $img2 [incr cnt -1] $ms"
    }
    $w configure -image $imgcur
  }

  ## ________________________ File names _________________________ ##

  proc HomeDir {} {
    # For Tcl 9.0 & Windows: gets a home directory ("~").

    if {[catch {set hd [file home]}]} {
      if {[info exists ::env(HOME)]} {set hd $::env(HOME)} {set hd ~}
    }
    return $hd
  }
  #_______________________

  proc checkHomeDir {com} {
    # For Tcl 9.0 & Windows: checks a command for "~".

    set hd [HomeDir]
    set com [string map [list { ~/} " $hd/" \"~/ \"$hd/ '~/ '$hd/ \\n~/ \\n$hd/ \n~/ \n$hd/ \{~/ \{$hd/] $com]
    if {[string match ~/* $com]} {set com $hd[string range $com 1 end]}
    return $com
  }
  #_______________________

  proc UnixPath {path} {
    # Makes a path "unix-like" to be good for Tcl.
    #   path - the path

    set path [string trim $path "\{\}"]  ;# possibly braced if contains spaces
    set path [string map [list \\ / %H [HomeDir]] $path]
    checkHomeDir $path
  }
  #_______________________

  proc NormalizeName {name} {
    # Removes spec.characters from a name (sort of normalizing it).
    #   name - the name

    string map [list \\ {} \{ {} \} {} \[ {} \] {} \t {} \n {} \r {} \" {}] $name
  }
  #_______________________

  proc NormalizeFileName {name} {
    # Removes spec.characters from a file/dir name (sort of normalizing it).
    #   name - the name of file/dir

    set name [string trim $name]
    string map [list \
      * _ ? _ ~ _ / _ \\ _ \{ _ \} _ \[ _ \] _ \t _ \n _ \r _ \
      | _ < _ > _ & _ , _ : _ \; _ \" _ ' _ ` _] $name
  }
  #_______________________

  proc FileTail {basepath fullpath} {
    # Extracts a tail path from a full file path.
    # E.g. FileTail /a/b /a/b/cd/ef => cd/ef
    #   basepath - base path
    #   fullpath - full path

    set lbase [file split $basepath]
    set lfull [file split $fullpath]
    set ll [expr {[llength $lfull] - [llength $lbase] - 1}]
    if {$ll>-1} {
      return [file join {*}[lrange $lfull end-$ll end]]
    }
    return {}
  }
  #_______________________

  proc FileRelativeTail {basepath fullpath} {
    # Gets a base relative path.
    # E.g. FileRelativeTail /a/b /a/b/cd/ef => ../ef
    #   basepath - base path
    #   fullpath - full path

    set tail [FileTail $basepath $fullpath]
    set lev [llength [file split $tail]]
    set base {}
    for {set i 1} {$i<$lev} {incr i} {append base ../}
    append base [file tail $tail]
  }

  ## ________________________ Borrowed from BWidget _________________________ ##

  #  Command BWidget::place ----> apave::place
  #
  # Notes:
  #  For Windows systems with more than one monitor the available screen area may
  #  have negative positions. Geometry settings with negative numbers are used
  #  under X to place wrt the right or bottom of the screen. On windows, Tk
  #  continues to do this. However, a geometry such as 100x100+-200-100 can be
  #  used to place a window onto a secondary monitor. Passing the + gets Tk
  #  to pass the remainder unchanged so the Windows manager then handles -200
  #  which is a position on the left hand monitor.
  #  I've tested this for left, right, above and below the primary monitor.
  #  Currently there is no way to ask Tk the extent of the Windows desktop in
  #  a multi monitor system. Nor what the legal co-ordinate range might be.
  #

  proc place { path w h args } {

    update idletasks

    # If the window is not mapped, it may have any current size.
    # Then use required size, but bound it to the screen width.
    # This is mostly inexact, because any toolbars will still be removed
    # which may reduce size.
    if { $w == 0 && [winfo ismapped $path] } {
      set w [winfo width $path]
    } else {
      if { $w == 0 } {
        set w [winfo reqwidth $path]
      }
      set vsw [winfo vrootwidth  $path]
      if { $w > $vsw } { set w $vsw }
    }

    if { $h == 0 && [winfo ismapped $path] } {
      set h [winfo height $path]
    } else {
      if { $h == 0 } {
        set h [winfo reqheight $path]
      }
      set vsh [winfo vrootheight $path]
      if { $h > $vsh } { set h $vsh }
    }

    set arglen [llength $args]
    if { $arglen > 3 } {
      return -code error "apave::place: bad number of argument"
    }

    if { $arglen > 0 } {
      set where [lindex $args 0]
      set list  [list at center left right above below]
      set idx   [lsearch $list $where]
      if { $idx == -1 } {
        return -code error "apave::place: bad position: $where $list"
      }
      if { $idx == 0 } {
        set err [catch {
          # purposely removed the {} around these expressions - [PT]
          set x [expr int([lindex $args 1])]
          set y [expr int([lindex $args 2])]
        } e]
        if { $err } {
          return -code error "apave::place: bad position: $e"
        }
        if {$::tcl_platform(platform) eq {windows}} {
          # handle windows multi-screen. -100 != +-100
          if {[string index [lindex $args 1] 0] ne {-}} {
            set x +$x
          }
          if {[string index [lindex $args 2] 0] ne {-}} {
            set y +$y
          }
        } else {
          if { $x >= 0 } {
            set x +$x
          }
          if { $y >= 0 } {
            set y +$y
          }
        }
      } else {
        if { $arglen == 2 } {
          set widget [lindex $args 1]
          if { ![winfo exists $widget] } {
            return -code error "apave::place: \"$widget\" does not exist"
          }
        } else {
          set widget .
        }
        set sw [winfo screenwidth  $path]
        set sh [winfo screenheight $path]
        if { $idx == 1 } {
          if { $arglen == 2 } {
            # center to widget
            set x0 [expr {[winfo rootx $widget] + ([winfo width  $widget] - $w)/2}]
            set y0 [expr {[winfo rooty $widget] + ([winfo height $widget] - $h)/2}]
          } else {
            # center to screen
            set x0 [expr {($sw - $w)/2 - [winfo vrootx $path]}]
            set y0 [expr {($sh - $h)/2 - [winfo vrooty $path]}]
          }
          set x +$x0
          set y +$y0
          if {$::tcl_platform(platform) ne {windows}} {
            if { $x0+$w > $sw } {set x {-0}; set x0 [expr {$sw-$w}]}
            if { $x0 < 0 }      {set x {+0}}
            if { $y0+$h > $sh } {set y {-0}; set y0 [expr {$sh-$h}]}
            if { $y0 < 0 }      {set y {+0}}
          }
        } else {
          set x0 [winfo rootx $widget]
          set y0 [winfo rooty $widget]
          set x1 [expr {$x0 + [winfo width  $widget]}]
          set y1 [expr {$y0 + [winfo height $widget]}]
          if { $idx == 2 || $idx == 3 } {
            set y +$y0
            if {$::tcl_platform(platform) ne {windows}} {
              if { $y0+$h > $sh } {set y {-0}; set y0 [expr {$sh-$h}]}
              if { $y0 < 0 }      {set y {+0}}
            }
            if { $idx == 2 } {
              # try left, then right if out, then 0 if out
              if { $x0 >= $w } {
                set x [expr {$x0-$w}]
              } elseif { $x1+$w <= $sw } {
                set x +$x1
              } else {
                set x {+0}
              }
            } else {
              # try right, then left if out, then 0 if out
              if { $x1+$w <= $sw } {
                set x +$x1
              } elseif { $x0 >= $w } {
                set x [expr {$x0-$w}]
              } else {
                set x {-0}
              }
            }
          } else {
            set x +$x0
            if {$::tcl_platform(platform) ne {windows}} {
              if { $x0+$w > $sw } {set x {-0}; set x0 [expr {$sw-$w}]}
              if { $x0 < 0 }      {set x {+0}}
            }
            if { $idx == 4 } {
              # try top, then bottom, then 0
              if { $h <= $y0 } {
                set y [expr {$y0-$h}]
              } elseif { $y1+$h <= $sh } {
                set y +$y1
              } else {
                set y {+0}
              }
            } else {
              # try bottom, then top, then 0
              if { $y1+$h <= $sh } {
                set y +$y1
              } elseif { $h <= $y0 } {
                set y [expr {$y0-$h}]
              } else {
                set y {-0}
              }
            }
          }
        }
      }

      ## If there's not a + or - in front of the number, we need to add one.
      if {[string is integer [string index $x 0]]} { set x +$x }
      if {[string is integer [string index $y 0]]} { set y +$y }

      wm geometry $path "${w}x${h}${x}${y}"
    } else {
      wm geometry $path "${w}x${h}"
    }
    update idletasks
  }

  ## ________________________ EONS apave _________________________ ##

}

# ________________________ APave _________________________ #

oo::class create ::apave::APave {

  superclass ::apave::APaveDialog

  variable _savedvv

  constructor {args} {
    # Creates APave object.
    #   win - window's name (path)
    #   args - additional arguments

    set _savedvv [list]
    if {[llength [self next]]} { next {*}$args }
  }

  destructor {
    # Clears variables used in the object.

    my initInput
    unset _savedvv
    if {[llength [self next]]} next
  }
  #_______________________

  method initInput {} {
    # Initializes input and clears variables made in previous session.

    foreach {vn vv} $_savedvv {
      catch {unset $vn}
    }
    set _savedvv [list]
    set Widgetopts [list]
  }
  #_______________________

  method varInput {} {
    # Gets variables made and filled in a previous session
    # as a list of "varname varvalue" pairs where varname
    # is of form: namespace::var$widgetname.

    return $_savedvv
  }
  #_______________________

  method valueInput {} {
    # Gets input variables' values.

    set _values {}
    foreach {vnam -} [my varInput] {
      lappend _values [set $vnam]
    }
    return $_values
  }
  #_______________________

  method input {icon ttl iopts args} {
    # Makes and runs an input dialog.
    #  icon - icon (omitted if equals to "")
    #  ttl - title of window
    #  iopts - list of widgets and their attributes
    #  args - list of dialog's attributes
    # The `iopts` contains lists of three items:
    #   name - name of widgets
    #   prompt - prompt for entering data
    #   valopts - value options
    # The `valopts` is a list specific for a widget's type, however
    # a first item of `valopts` is always an initial input value.

    if {$iopts ne {}} {
      my initInput  ;# clear away all internal vars
    }
    set pady "-pady 2"
    if {[set focusopt [::apave::getOption -focus {*}$args]] ne {}} {
      set focusopt "-focus $focusopt"
    }
    lappend inopts [list fraM + T 1 98 "-st nsew $pady -rw 1"]
    set savedvv [list]
    set frameprev {}
    foreach {name prompt valopts} $iopts {
      if {$name eq {}} continue
      lassign $prompt prompt gopts attrs
      lassign [::apave::extractOptions attrs -method {} -toprev {}] ismeth toprev
      if {[string toupper $name 0] eq $name} {
        set ismeth yes  ;# overcomes the above setting
        set name [string tolower $name 0]
      }
      set ismeth [string is true -strict $ismeth]
      set gopts "$pady $gopts"
      set typ [string tolower [string range $name 0 1]]
      if {$typ eq "v_" || $typ eq "se"} {
        lappend inopts [list fraM.$name - - - - "pack -fill x $gopts"]
        continue
      }
      set tvar "-tvar"
      switch -exact -- $typ {
        ch { set tvar "-var" }
        sp { set gopts "$gopts -expand 0 -side left"}
      }
      set framename fraM.fra$name
      if {$typ in {lb te tb}} {  ;# the widgets sized vertically
        lappend inopts [list $framename - - - - "pack -expand 1 -fill both"]
      } else {
        lappend inopts [list $framename - - - - "pack -fill x"]
      }
      set vv [my varName $name]
      set ff [my FieldName $name]
      set Name [string toupper $name 0]
      if {$ismeth && $typ ni {ra}} {
        # -method option forces making "WidgetName" method from "widgetName"
        my MakeWidgetName $ff $Name -
      }
      if {$typ ne {la} && $toprev eq {}} {
        set takfoc [::apave::parseOptions $attrs -takefocus 1]
        if {$focusopt eq {} && $takfoc} {
          if {$typ in {fi di cl fo da}} {
            set _ en*$name  ;# 'entry-like mega-widgets'
          } elseif {$typ eq "ft"} {
            set _ te*$name  ;# ftx - 'text-like mega-widget'
          } else {
            set _ $name
          }
          set focusopt "-focus $_"
        }
        if {$typ in {lb tb te}} {set anc nw} {set anc w}
        lappend inopts [list fraM.fra$name.labB$name - - - - \
          "pack -side left -anchor $anc -padx 3" \
          "-t \"$prompt\" -font \
          \"-family {[my basicTextFont]} -size [my basicFontSize]\""]
      }
      # for most widgets:
      #   1st item of 'valopts' list is the current value
      #   2nd and the rest of 'valopts' are a list of values
      if {$typ ni {fc te la}} {
        # curr.value can be set with a variable, so 'subst' is applied
        set vsel [lindex $valopts 0]
        catch {set vsel [subst -nocommands -nobackslashes $vsel]}
        set vlist [lrange $valopts 1 end]
      }
      if {[set msgLab [::apave::getOption -msgLab {*}$attrs]] ne {}} {
        set attrs [::apave::removeOptions $attrs -msgLab]
      }
      # define a current widget's info
      switch -exact -- $typ {
        lb - tb {
          set $vv $vlist
          lappend attrs -lvar $vv
          if {$vsel ni {{} -}} {
            lappend attrs -lbxsel "$::apave::UFF$vsel$::apave::UFF"
          }
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill both $gopts" $attrs]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        cb {
          if {![info exist $vv]} {catch {set $vv $vsel}}
          lappend attrs -tvar $vv -values $vlist
          if {$vsel ni {{} -}} {
            lappend attrs -cbxsel $::apave::UFF$vsel$::apave::UFF
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" $attrs]
        }
        fc {
          if {![info exist $vv]} {catch {set $vv {}}}
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" "-tvar $vv -values \{$valopts\} $attrs"]
        }
        op {
          set $vv $vsel
          lappend inopts [list $ff - - - - "pack -fill x $gopts" "$vv $vlist"]
        }
        ra {
          if {![info exist $vv]} {catch {set $vv $vsel}}
          set padx 0
          foreach vo $vlist {
            set name $name
            set FF $ff[incr nnn]
            lappend inopts [list $FF - - - - "pack -side left $gopts -padx $padx" "-var $vv -value \"$vo\" -t \"$vo\" $attrs"]
            if {$ismeth} {
              my MakeWidgetName $FF $Name$nnn -
            }
            set padx [expr {$padx ? 0 : 9}]
          }
        }
        te {
          if {![info exist $vv]} {
            set valopts [string map [list \\n \n \\t \t] $valopts]
            set $vv [string map [list \\\\ \\ \\\} \} \\\{ \{] $valopts]
          }
          if {[dict exist $attrs -state] && [dict get $attrs -state] eq "disabled"} \
          {
            # disabled text widget cannot be filled with a text, so we should
            # compensate this through a home-made attribute (-disabledtext)
            set disattr "-disabledtext \{[set $vv]\}"
          } elseif {[dict exist $attrs -readonly] && [dict get $attrs -readonly] || [dict exist $attrs -ro] && [dict get $attrs -ro]} {
            set disattr "-rotext \{[set $vv]\}"
            set attrs [::apave::removeOptions $attrs -readonly -ro]
          } else {
            set disattr {}
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill both $gopts" "$attrs $disattr"]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        la {
          if {$prompt ne {}} { set prompt "-t \"$prompt\" " } ;# prompt as -text
          lappend inopts [list $ff - - - - "pack -anchor w $gopts" "$prompt$attrs"]
          continue
        }
        bu - bt - ch {
          set prompt {}
          if {$toprev eq {}} {
            lappend inopts [list $ff - - - - \
              "pack -side left -expand 1 -fill both $gopts" "$tvar $vv $attrs"]
          } else {
            lappend inopts [list $frameprev.$name - - - - \
              "pack -side left $gopts" "$tvar $vv $attrs"]
          }
          if {$vv ne {}} {
            if {![info exist $vv]} {
              catch {
                if {$vsel eq {}} {set vsel 0}
                set $vv $vsel
              }
            }
          }
        }
        default {
          if {$vlist ne {}} {lappend attrs -values $vlist}
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill x $gopts" "$tvar $vv $attrs"]
          if {$vv ne {}} {
            if {![info exist $vv]} {catch {set $vv $vsel}}
          }
        }
      }
      if {$msgLab ne {}} {
        lassign $msgLab lab msg attlab
        set lab [my parentWName [lindex $inopts end 0]].$lab
        if {$msg ne {}} {set msg "-t {$msg}"}
        append msg " $attlab"
        lappend inopts [list $lab - - - - "pack -side left -expand 1 -fill x" $msg]
      }
      if {![info exist $vv]} {set $vv {}}
      lappend _savedvv $vv [set $vv]
      set frameprev $framename
    }
    lassign [::apave::parseOptions $args -titleHELP {} -buttons {} -comOK 1 \
      -titleOK OK -titleCANCEL Cancel -centerme {}] \
      titleHELP buttons comOK titleOK titleCANCEL centerme
    if {$titleHELP eq {}} {
      set butHelp {}
    } else {
      lassign $titleHELP title command
      set butHelp [list butHELP $title $command]
    }
    if {$titleCANCEL eq {}} {
      set butCancel {}
    } else {
      set butCancel "butCANCEL $titleCANCEL destroy"
    }
    if {$centerme eq {}} {
      set centerme {-centerme 1}
    } else {
      set centerme "-centerme $centerme"
    }
    set args [::apave::removeOptions $args \
      -titleHELP -buttons -comOK -titleOK -titleCANCEL -centerme -modal]
    lappend args {*}$focusopt
    if {[catch {
      lassign [my PrepArgs {*}$args] args
      set res [my Query $icon $ttl {} \
        "$butHelp $buttons butOK $titleOK $comOK $butCancel" \
        butOK $inopts $args {} {*}$centerme -input yes]} e]
    } then {
      catch {destroy $Dlgpath}  ;# Query's window
      set under \n[string repeat _ 80]\n\n
      ::apave::obj ok err "ERROR" "\n$e$under $inopts$under $args$under $centerme" \
        -t 1 -head "\nAPave error: \n" -hfg red -weight bold -w 80
      return 0
    }
    if {![lindex $res 0]} {  ;# restore old values if OK not chosen
      foreach {vn vv} $_savedvv {
        # tk_optionCascade (destroyed now) was tracing its variable => catch
        catch {set $vn $vv}
      }
    }
    return $res
  }
  #_______________________

  method vieweditFile {fname {prepcom ""} args} {
    # Views or edits a file.
    #   fname - name of file
    #   prepcom - a command performing before and after creating a dialog
    #   args - additional options
    # It's a sort of stub for calling *editfile* method.
    # See also: editfile

    my editfile $fname {} {} {} $prepcom {*}$args
  }
  #_______________________

  method editfile {fname fg bg cc {prepcom ""} args} {
    # Edits or views a file with a set of main colors
    #   fname - name of file
    #   fg - foreground color of text widget
    #   bg - background color of text widget
    #   cc - caret's color of text widget
    #   prepcom - a command performing before and after creating a dialog
    #   args - additional options (`-readonly 1` for viewing the file).
    # If *fg* isn't empty, all three colors are used to color a text.
    # See also:
    # [aplsimple.github.io](https://aplsimple.github.io/en/tcl/pave/index.html)

    if {$fname eq {}} {
      return false
    }
    set newfile 0
    if {[catch {set filetxt [::apave::readTextFile $fname {} yes]}]} {
      return false
    }
    lassign [::apave::parseOptions $args -rotext {} -readonly 1 -ro 1] rotext readonly ro
    lassign [::apave::extractOptions args -buttons {}] buttadd
    set btns {Close 0}  ;# by default 'view' mode
    set oper VIEW
    if {$rotext eq {} && (!$readonly || !$ro)} {
      set btns {Save 1 Close 0}
      set oper EDIT
    }
    if {$fg eq {}} {
      set tclr {}
    } else {
      set tclr "-fg $fg -bg $bg -cc $cc"
    }
    if {$prepcom eq {}} {set aa {}} {set aa [$prepcom filetxt]}
    set res [my misc {} "$oper: $fname" "$filetxt" "$buttadd $btns" \
      TEXT -text 1 -w {100 80} -h 32 {*}$tclr \
      -post $prepcom {*}$aa {*}$args]
    set data [string range $res 2 end]
    if {[set res [string index $res 0]] eq "1"} {
      set data [string range $data [string first " " $data]+1 end]
      set data [string trimright $data]
      set res [::apave::writeTextFile $fname data]
    } elseif {$newfile} {
      file delete $fname
    }
    return $res
  }
  #_______________________

  method onTop {wpar top {wtoplist -} {res ""}} {
    # Sets -topmost attribute for windows or gets a list of topmost windows.
    #   wpar - parent window's path
    #   top - -topmost attribute's value
    #   wtoplist - list of windows to process
    #   res - used to get the result
    # Returns a list of "topmost=$top" windows found on $wpar path.

    if {$wtoplist ne "-"} {
      # sets the attribute
      foreach w $wtoplist {wm attributes $w -topmost $top}
    } else {
      # gets a list of topmost windows
      if {$wpar ne {}} {
        set res [my onTop [winfo parent $wpar] $top - $res]
        catch {
          if {[wm attributes $wpar -topmost]==$top} {lappend res $wpar}
        }
      }
    }
    return $res
  }

# ________________________ EONS _________________________ #

}
# ________________________ EOF _________________________ #
