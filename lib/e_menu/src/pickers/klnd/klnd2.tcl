###########################################################
# Name:    klnd2.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/18/2022
# Brief:   Handles calendar widget for apave package.
# License: MIT.
###########################################################

package require Tk

# ________________________ my _________________________ #

namespace eval ::klnd {
  namespace export calendar2
  namespace eval my {}
}

## ________________________ Go month/year _________________________ ##

proc ::klnd::my::IsDay2 {obj i} {
  # Check if a button shows a day.
  #   obj - index of calendar
  #   i - button index

  variable p
  return [expr {![catch {set w [$p($obj) BuT$obj-${i}KLND]}] && \
    [string length [TrimN [$w cget -text]]]}]
}
#_______________________

proc ::klnd::my::GoYear2 {obj i {dobreak no}} {
  # Shifts the year backward/forward.
  #   obj - index of calendar
  #   i - increment for the current year
  #   dobreak - yes when called from 'bind'

  variable p
  ShowMonth2 $obj $p(mvis$obj) [expr {$p(yvis$obj)+($i)}]
  if {$dobreak} {return -code break}
}
#_______________________

proc ::klnd::my::GoMonth2 {obj i {dobreak no}} {
  # Shifts the month backward/forward.
  #   obj - index of calendar
  #   i - increment for the current month
  #   dobreak - yes when called from 'bind'

  variable p
  set m [expr {$p(mvis$obj)+($i)}]
  if {$m>12} {set m 1; incr p(yvis$obj)}
  if {$m<1} {set m 12; incr p(yvis$obj) -1}
  ShowMonth2 $obj $m $p(yvis$obj)
  if {$dobreak} {return -code break}
}
#_______________________

proc ::klnd::my::MapYMD {script y m d} {
  # Gets a script with %y, %m, %d wildcards.

  return [string map [list %y $y %m $m %d $d] $script]
}
#_______________________

proc ::klnd::my::fgMayHL {obj fg y m d} {
  # Gets a foreground color (possibly highlighting).
  #   fg - default foreground color
  #   y - year
  #   m - month
  #   d - day

  variable p
  foreach item $p(hllist$obj) {
    # date format for highlighting is %Y/%m/%d
    lassign [split [lindex $item 0] /] yh mh dh
    set dh [TrimN $dh]
    set mh [TrimN $mh]
    if {$y==$yh && $m==$mh && $d==$dh} {
      set fg red
      break
    }
  }
  return $fg
}
#_______________________

proc ::klnd::my::ShowMonth2 {obj m y {doenter yes} {dopopup no}} {
  # Displays a month's days.
  #   obj - index of calendar
  #   m - month
  #   y - year
  #   doenter - yes, if perform Enter2 proc
  #   dopopup - yes, if bind a popup menu

  variable p
  set y [expr {max($y,[::klnd::minYear])}]
  set m [TrimN $m]
  # if calendars are linked with united, no display of year in a title
  if {$p(united$obj)} {set yd {}} {set yd " $y"}
  [$p($obj) LabMonth$obj] configure -text  "[lindex $p(months$obj) [expr {$m-1}]]$yd" \
    -font [::apave::obj boldDefFont [expr {[::apave::obj basicFontSize]+2}]]
  # highlight color
  set hlcolor red ;#[lindex [::apave::obj csGet] 17]
  # display day names
  for {set i 1} {$i<8} {incr i} {
    [$p($obj) LabDay$obj$i] configure -text " [lindex $p(days$obj) $i-1] "
  }
  # 1st day of the month's first week:
  set i0 [clock format [clock scan "$m/1/$y" -format %D] -format %w]
  if {$p(weekday$obj) eq {%u}} {if {$i0} {incr i0 -1} {set i0 6}}
  # get the last day of month
  if {[set yl $y] && [set ml $m]==12} {set ml 1; incr yl}
  set lday [clock format [clock scan "[incr ml]/1/$yl 1 day ago"] -format %d]
  set iday [set p(icurr$obj) 0]
  for {set i 1} {$i<43} {incr i} {
    set fg $p(fg1)
    set bg $p(bg1)
    set wbut [$p($obj) BuT$obj-${i}KLND]
    if {$i<=$i0 || $iday>=$lday} {
      set att "-takefocus 0 -text {    } -activebackground $p(bg1)"
      set script {}
    } else {
      set att "-takefocus 0 -text {[incr iday]} -activeforeground $p(fg0) -activebackground $p(bg0)"
      if {$doenter && ($iday==$p(dvis$obj) || ($iday==$lday && $iday<$p(dvis$obj)))} {
        catch {after cancel $p(after$obj)}
        set p(after$obj) [after idle "::klnd::my::Enter2 $obj $i"]
      }
      if {$iday==1} {set p(d1st) $i}
      if {$y==$p(y) && $m==$p(m) && $iday==$p(d)} {
        set p(icurr$obj) $i  ;# button's index of the current date
      }
      set dt [FormatDay2 $obj $y $m $iday]
      if {[lsearch -exact $p(daylist$obj) $dt]>-1} {
        set fg $p(fgsel)
        set bg $p(bgsel)
      } elseif {$p(currentdate) eq "$y/$m/$iday"} {
        set fg $p(fg2)
        set bg $p(bg2)
      }
      if {$dopopup} {
        set script [MapYMD $p(popup$obj) $y $m $iday]
      }
    }
    if {$dopopup && $p(popup$obj) ne {}} {
      bind $wbut <Button-3> $script
    }
    # as last refuge: highlighting fg by hllist
    set fg [fgMayHL $obj $fg $y $m $iday]
    $wbut configure {*}$att -relief flat -overrelief flat -fg $fg -bg $bg
  }
  set p(mvis$obj) $m  ;# month & year currently visible
  set p(yvis$obj) $y
}

## ________________________ Current day _________________________ ##

proc ::klnd::my::SetCurrentDay2 {obj} {
  # Goes to the current date.
  #   obj - index of calendar

  variable p
  set p(dvis$obj) 0
  ShowMonth2 $obj $p(m) $p(y)
  Enter2 $obj $p(icurr$obj) 1
}
#_______________________

proc ::klnd::my::HighlightCurrentDay2 {obj} {
  # Highlights the current day's button.
  #   obj - index of calendar

  variable p
  if {$p(currentmonth) eq "$p(yvis$obj)/[TrimN $p(mvis$obj)]"} {
    if {![info exists p(wcurr$obj)]} {
      catch {set p(wcurr$obj) [$p($obj) BuT$obj-$p(icurr$obj)KLND]}
    }
    catch {
      set day [$p(wcurr$obj) cget -text]
      if {[$p(wcurr$obj) cget -bg] ne $p(bgsel) && [TrimN $day] ne {}} {
        set fg [fgMayHL $obj $p(fg2) $p(yvis$obj) $p(mvis$obj) $day]
        $p(wcurr$obj) configure -fg $fg -bg $p(bg2)
      }
      if {$p(united$obj)} {
        # if calendars are linked with united, one COMMON day selected for all
        set p(wcurrdate) $p(wcurr$obj)
      }
    }
    return [expr {[info exists p(wunited$obj)] && [info exists p(wcurr$obj)] && \
      $p(wunited$obj) eq $p(wcurr$obj)}]
  }
  return no
}
#_______________________

proc ::klnd::my::FormatDay2 {obj y m d} {
  # Gets a date formatted according to a current format.
  #   obj - index of calendar
  #   y - year of the date
  #   m - month of the date
  #   d - day of the date

  variable p
  return [clock format [clock scan $m/$d/$y -format %D] -format $p(dformat$obj) -locale $p(loc$obj)]
}

## ________________________ Event handlers _________________________ ##

proc ::klnd::my::Enter2 {obj i {focusin 0}} {
  # Highlights a button and makes it current.
  #   obj - index of calendar
  #   i - button index
  #   focusin - yes, if the button is clicked and focused

  variable p
  if {[catch {set isday [IsDay2 $obj $i]}]} {set isday no}
  if {!$isday} return
  set w [$p($obj) BuT$obj-${i}KLND]
  set p(dvis$obj) [$w cget -text]
  set date [FormatDay2 $obj $p(yvis$obj) $p(mvis$obj) $p(dvis$obj)]
  if {$focusin} {
    if {$p(daylist$obj) ne {-}} {
      # add/delete the date to/from the list of selected days
      if {[set di [lsearch -exact $p(daylist$obj) $date]]>-1} {
        set p(daylist$obj) [lreplace $p(daylist$obj) $di $di]
        ShowMonth2 $obj $p(mvis$obj) $p(yvis$obj) no
        return
      } else {
        lappend p(daylist$obj) $date
      }
    }
  }
  ShowMonth2 $obj $p(mvis$obj) $p(yvis$obj) no
  if {$focusin} {
    set p(olddate$obj) $date
    if {$p(united$obj)} {
      # if calendars are linked with united, unselect previously selected COMMON day
      # and then highlight the current date
      catch {
        if {$p(daylist$obj) eq {-}} {
          $p(wunited) configure -fg $p(fg1) -bg $p(bg1)
        }
        if {[$p(wcurr$obj) cget -bg] ne $p(bgsel)} {
          set fg [fgMayHL $obj $p(fg2) $p(yvis$obj) $p(mvis$obj) $p(dvis$obj)]
          $p(wcurr$obj) configure -fg $fg -bg $p(bg2)
        }
      }
    }
  }
  set p(ienter) $i
  if {$p(tvar$obj) ne {}} {
    set $p(tvar$obj) $date
    if {$p(olddate$obj) eq $date} {
      if {$p(daylist$obj) ne {-}} {
        ShowMonth2 $obj $p(mvis$obj) $p(yvis$obj) no
      } else {
        catch {
          # unselect previously selected day of THIS month
          if {![HighlightCurrentDay2 $obj]} {
            $p(wunited$obj) configure -fg $p(fg1) -bg $p(bg1)
          }
        }
        # show selected day
        set fg [fgMayHL $obj $p(fgsel) $p(yvis$obj) $p(mvis$obj) $p(dvis$obj)]
        $w configure -fg $fg -bg $p(bgsel)
      }
      # save the selected widget for THIS month
      # and as COMMON for calendars linked with united
      set p(wunited$obj) $w
      if {$p(united$obj)} {set p(wunited) $w}
    }
  }
  if {$focusin && $p(com$obj) ne {}} {
    eval [MapYMD $p(com$obj) $p(yvis$obj) $p(mvis$obj) $p(dvis$obj)]
  }
  HighlightCurrentDay2 $obj
}
#_______________________

proc ::klnd::my::BindButtons2 {obj} {
  # Binds events to buttons of a calendar.
  #   obj - index of calendar

  variable p
  for {set i 1} {$i<38} {incr i} {
    set but [$::klnd::my::p($obj) BuT$obj-${i}KLND]
    bind $but <Button-1> "::klnd::my::Enter2 $obj $i 1"
  }
}
#_______________________

proc ::klnd::my::ButtonTip {obj tipcom w} {
  # Gets a button's tip.
  #   obj - index of calendar
  #   tipcom - a caller's command returning a tip
  #   w - current day button's path
  # The tipcom command can include wildcards:
  #   %W - a current day button's path
  #   %D - a current day's value as Y/M/D

  variable p
  set res {}
  catch {
    set y $p(yvis$obj)
    set m $p(mvis$obj)
    set d [TrimN [$w cget -text]]
    set d [::klnd::my::FormatDay2 $obj $y $m $d]
    set tipcom [string map [list %W $w %D $d] $tipcom]
    set res [eval {*}$tipcom]
  }
  return $res
}

## ________________________ Widgets _________________________ ##

proc ::klnd::my::MainWidgets2 {obj ownname} {
  # Forms main widgets of calendar.
  #   obj - index of calendar
  #   ownname - frame for calendar

  variable p
  set ::klnd::TMPTIP {}
  catch {
    if {$p(tip$obj) ne {}} {
      set tipcom [list $p(tip)] ;# possible bad list
      set ::klnd::TMPTIP \
        "-tip { -BALTIP %W -COMMAND {::klnd::my::ButtonTip $obj {$tipcom} %w} }"
    }
  }
  set p(tipF3$obj) \
    "[::msgcat::mc {Current date}]: \
      [clock format [CurrentDate] -format $p(dformat$obj) -locale $p(loc$obj)]"
  set res [list "$ownname.frA - - 1 10 {-st new} {-bg $::klnd::my::p(bg1)}"]
  # if calendars are united, no display of tool bar
  if {$p(united$obj)} {
    lappend res \
      "$ownname.frA.LabMonth$obj - - - - {pack -fill x -expand 1} {-anchor center -w 14}"
  } else {
    lappend res \
    "$ownname.frA.tool - - - - {pack -side top} {-array { \
      IM_KLND_0 {{::klnd::my::SetCurrentDay2 $obj} -tip {$::klnd::my::p(tipF3$obj)@@-under 5}} sev 6 \
      IM_KLND_1 {{::klnd::my::GoYear2 $obj -1} -tip {$::klnd::my::prevY\n(Home)@@-under 5}} h_ 2 \
      IM_KLND_2 {{::klnd::my::GoMonth2 $obj -1} -tip {$::klnd::my::prevM\n(PageUp)@@-under 5}} h_ 3 \
      LabMonth$obj {{} {-fill x -expand 1} {-anchor center -w 14}} h_ 2 \
      IM_KLND_3 {{::klnd::my::GoMonth2 $obj 1} -tip {$::klnd::my::nextM\n(PageDown)@@-under 5}} h_ 3 \
      IM_KLND_4 {{::klnd::my::GoYear2 $obj 1} -tip {$::klnd::my::nextY\n(End)@@-under 5}} h_ 2 \
    }}"
  }
  lappend res "$ownname.frADays $ownname.frA T - - {-st nsew} {-bg $::klnd::my::p(bg1)}"
  lappend res \
    [list $ownname.frADays.tcl " \
      set wt - ; \
      for {set i 1} {\$i<50} {incr i} { \
        if {\$i<8} {set cur $ownname.frADays.LabDay$obj\$i} {set cur $ownname.frADays.BuT$obj-\[expr {\$i-7}\]KLND} ; \
        if {(\$i%7)!=1} {set p L; set pw \$pr} {set p T; set pw \$wt; set wt \$cur} ; \
        if {\$i<8} { \
          set lwid \"\$cur \$pw \$p 1 1 {-st ew} {-anchor center -foreground $::klnd::my::p(fgh) -background $::klnd::my::p(bg1)}\" \
        } else { \
          set lwid \"\$cur \$pw \$p 1 1 {-st ew} {-relief flat -overrelief flat -bd 0 -takefocus 0  -padx 8 -pady 4 -font {$::apave::FONTMAIN} -com {::klnd::my::Enter2 $obj \[expr {\$i-7}\]} $::klnd::TMPTIP -highlightthickness 0 -w 3 -background $::klnd::my::p(bg1)}\" \
        } ; \
        %C \$lwid ; \
        set pr \$cur \
      }"
    ]
  return $res
}

# ________________________ UI _________________________ #

proc ::klnd::labelPath {{obj {}}} {
  # Gets a title label path.
  #   obj - index of the calendar
  # Useful to change the label's attributes.
  # If *obj* omitted, returns a path of last created label.

  variable my::p
  if {$obj eq {}} {set obj $my::p(objNUM)}
  return [$my::p($obj) LabMonth$obj]
}
#_______________________

proc ::klnd::blinking {doit} {
  # Makes a calendar label blink.
  #   doit - if yes, starts blinking, else stops it

  lassign [::apave::obj csGet] - fgnorm - bgnorm
  lassign [::apave::obj csGet 45] - - - - - bgblink fgblink
  set lab [::klnd::labelPath]
  if {$doit} {
    after idle "::apave::blinkWidget $lab $fgnorm $bgnorm $fgblink $bgblink 100 4"
  } else {
    ::apave::blinkWidget $lab $fgnorm $bgnorm
  }
}
#_______________________

proc ::klnd::update {{obj {}} {year {}} {month {}} {hllist {}}} {
  # Redraws a calendar.
  #   obj - index of the calendar
  #   year - year to redraw
  #   month - month to redraw

  variable my::p
  if {$obj eq {}} {
    set obj $my::p(objNUM)
    set year $my::p(yvis$obj)
    set month $my::p(mvis$obj)
    set my::p(hllist$obj) $hllist
  }
  my::ShowMonth2 $obj $month $year yes yes
}
#_______________________

proc ::klnd::selectedDay {{obj {}} {y {}} {m {}} {d {}} {doblink yes}} {
  # Gets a selected day.
  #   obj - index of the calendar
  #   y - year
  #   m - month
  #   d - day
  #   doblink - if yes, make the month blink
  # If y/m/d are set, they define currently selected date.
  # Returns a list of year, month, day

  variable my::p
  if {$obj eq {}} {set obj $my::p(objNUM)}
  if {$y ne {}} {
    set my::p(yvis$obj) $y
    set my::p(mvis$obj) $m
    set my::p(dvis$obj) $d
    if {$my::p(tvar$obj) ne {}} {
      set p(olddate$obj) [my::FormatDay2 $obj $y $m $d]
      set $my::p(tvar$obj) $p(olddate$obj)
    }
    after idle "::klnd::my::ShowMonth2 $obj $m $y yes yes; ::klnd::blinking $doblink"
  }
  return [list $my::p(yvis$obj) $my::p(mvis$obj) $my::p(dvis$obj)]
}
#_______________________

proc ::klnd::getDaylist {pobj {min 0} {max 9999999}} {
  # Gets a day list which was set initially and possibly changed by a user.
  #   pobj - apave object
  #   min - minimal index of calendar widget
  #   max - maximal index of calendar widget
  # The pobj is the same as passed to klnd::calendar2.
  # See also: calendar2

  variable my::p
  set res [list]
  if {![catch {set objNUM $my::p(objNUM)}]} {
    for {set obj 0} {$obj<$objNUM} {} {
      incr obj
      if {$my::p($obj) eq $pobj && [info exist my::p(daylist$obj)]} {
        if {$my::p(daylist$obj) ne {-} && $min<=$obj && $obj<=$max} {
          foreach d $my::p(daylist$obj) {
            if {[lsearch -exact $res $d]<0} {
              lappend res $d
            }
          }
        }
      }
    }
  }
  return $res
}
#_______________________

proc ::klnd::calendar2 {pobj w ownname args} {
  # The main procedure of the calendar embedded widget.
  #   pobj - apave object
  #   w - container widget for *ownname*
  #   ownname - frame widget for calendar
  #   args - options of the calendar
  # Returns a list of widgets for apave layout.

  variable my::p
  set obj [incr my::p(objNUM)]
  set my::p($obj) $pobj
  my::InitSettings
  my::InitCalendar {*}$args
  if {$my::p(currentmonth) eq {}} {
    lassign [::klnd::currentYearMonthDay] year month day
    set my::p(currentmonth) "$year/$month"
    set my::p(currentdate) "$year/$month/$day"
  }
  # save options for current calendar
  foreach opt {weekday months days loc yvis mvis dvis \
  com tvar dformat united currentmonth daylist popup hllist tip} {
    set my::p($opt$obj) $my::p($opt)
  }
  if {$my::p(daylist) ne {-} && $my::p(united)} {
    # for calendars united, initialize day lists per month
    set my::p(daylist$obj) [list]
    foreach date $my::p(daylist) {
      set d [clock format [clock scan $date -format $my::p(dformat)] -format %Y/%N/%d]
      lassign [split $d /] y m
      set m [my::TrimN $m]
      lappend my::p(daylist$obj) $date
    }
  }
  # if calendars are united, it's selected at start
  # and saved as previously selected one
  set my::p(olddate$obj) {}
  # binds for day buttons and show and work with the calendar
  after idle "::klnd::my::BindButtons2 $obj; \
    ::klnd::my::ShowMonth2 $obj $my::p(m) $my::p(y) yes yes"
  set res [my::MainWidgets2 $obj $ownname]
  return $res
}

# _________________________________ EOF _________________________________ #

#RUNF1: ../../tests/test2_pave.tcl alt 24 9 12 "small icons"
#RUNF1: ~/PG/github/alited/src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
