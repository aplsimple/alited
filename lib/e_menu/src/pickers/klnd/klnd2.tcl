#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# A calendar widget for apave package.
#
# _______________________________________________________________________ #

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
    [string length [string trim [$w cget -text]]]}]
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

proc ::klnd::my::ShowMonth2 {obj m y {doenter yes}} {
  # Displays a month's days.
  #   obj - index of calendar
  #   m - month
  #   y -year
  #   doenter - yes, if perform Enter2 proc

  variable p
  set y [expr {max($y,1753)}]
  # if calendars are linked with staticdate, no display of year in a title
  if {$p(staticdate$obj) eq {}} {set yd " $y"} {set yd {}}
  [$p($obj) LabMonth$obj] configure -text  "[lindex $p(months$obj) [expr {$m-1}]]$yd" \
    -font "[$p($obj) csFontDef] -size [expr {[$p($obj) basicFontSize]+3}]"
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
    if {$i<=$i0 || $iday>=$lday} {
      set att "-takefocus 0 -text {    } -activebackground $p(bg1)"
    } else {
      set att "-takefocus 0 -text {[incr iday]} -activeforeground $p(fg0) -activebackground $p(bg0)"
      if {$doenter && ($iday==$p(dvis$obj) || ($iday==$lday && $iday<$p(dvis$obj)))} {
        if {[info exists p(after$obj)]} {set af 20} {set af 200} ;# at key pressing tight
        catch {after cancel $p(after$obj)}
        set p(after$obj) [after $af \
          "::klnd::my::Enter2 $obj $i; ::klnd::my::HighlightCurrentDay2 $obj"]
      }
      if {$iday==1} {set p(d1st) $i}
      if {$y==$p(y) && $m==$p(m) && $iday==$p(d)} {
        set p(icurr$obj) $i  ;# button's index of the current date
      }
    }
    [$p($obj) BuT$obj-${i}KLND] configure {*}$att -relief flat -overrelief flat -fg $p(fg1) -bg $p(bg1)
  }
  set p(mvis$obj) $m  ;# month & year currently visible
  set p(yvis$obj) $y
}
#_______________________

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
  if {$p(currentmonth$obj) eq "$p(yvis$obj)/$p(mvis$obj)"} {
    if {![info exists p(wcurr$obj)]} {
      catch {set p(wcurr$obj) [$p($obj) BuT$obj-$p(icurr$obj)KLND]}
    }
    catch {
      $p(wcurr$obj) configure -fg $p(fg2) -bg $p(bg2)
      if {$p(staticdate$obj) ne {}} {
        # if calendars are linked with staticdate, one COMMON day selected for all
        set p(wcurrdate) $p(wcurr$obj)
      }
    }
    return [expr {[info exists p(wstaticdate$obj)] && [info exists p(wcurr$obj)] && \
      $p(wstaticdate$obj) eq $p(wcurr$obj)}]
  }
  return no
}
#_______________________

## ________________________ Event handlers _________________________ ##

proc ::klnd::my::Enter2 {obj i {focusin 0}} {
  # Highlights a button and makes it current.
  #   obj - index of calendar
  #   i - button index
  #   focusin - yes, if the button is clicked and focused

  variable p
  if {![IsDay2 $obj $i]} return
  set w [$p($obj) BuT$obj-${i}KLND]
  set p(dvis$obj) [$w cget -text]
  set date [clock format [clock scan $p(mvis$obj)/$p(dvis$obj)/$p(yvis$obj) -format %D] -format $p(dformat$obj)]
  ShowMonth2 $obj $p(mvis$obj) $p(yvis$obj) no
  if {$focusin} {
    set p(olddate$obj) $date
    if {$p(staticdate$obj) ne {}} {
      # if calendars are linked with staticdate, unselect previously selected COMMON day
      # and then highlight the current date
      catch {
        $p(wstaticdate) configure -fg $p(fg1) -bg $p(bg1)
        $p(wcurrdate) configure -fg $p(fg2) -bg $p(bg2)
      }
    }
  }
  Leave2 $obj
  set p(ienter) $i
  if {$p(tvar$obj) ne {}} {
    set $p(tvar$obj) $date
    if {$p(olddate$obj) eq $date} {
      catch {
        # unselect previously selected day of THIS month
        if {![HighlightCurrentDay2 $obj]} {
          $p(wstaticdate$obj) configure -fg $p(fg1) -bg $p(bg1)
        }
      }
      # show selected day
      $w configure -fg $p(fgsel) -bg $p(bgsel)
      # save the selected widget for THIS month
      # and as COMMON for calendars linked with staticdate
      set p(wstaticdate$obj) $w
      if {$p(staticdate$obj) ne {}} {set p(wstaticdate) $w}
    }
  }
  if {$focusin && $p(com$obj) ne {}} {eval $p(com$obj)}
}
#_______________________

proc ::klnd::my::Leave2 {obj {i 0}} {
  # Unhighlights a button.
  #   obj - index of calendar
  #   i - button index

  variable p
  if {$i && ![[$p($obj) BuT$obj-${i}KLND] cget -takefocus]} return
  foreach n [list $i $p(ienter)] {
    if {$n} {[$p($obj) BuT$obj-${n}KLND] configure -fg $p(fg1) -bg $p(bg1)}
  }
  HighlightCurrentDay2 $obj
}
#_______________________

proc ::klnd::my::BindButtons2 {obj} {
  # Bind events to buttons of a calendar.
  #   obj - index of calendar

  variable p
  for {set i 1} {$i<38} {incr i} {
    set but [$::klnd::my::p($obj) BuT$obj-${i}KLND]
    bind $but <Button-1> "::klnd::my::Enter2 $obj $i 1"
  }
}
#_______________________

## ________________________ Widgets _________________________ ##

proc ::klnd::my::MainWidgets2 {obj ownname} {
  # Forms main widgets of calendar.
  #   obj - index of calendar
  #   ownname - frame for calendar

  variable p
  set p(tipF3$obj) \
    "[::msgcat::mc {Current date}]: \
      [clock format [CurrentDate] -format $p(dformat$obj) -locale $p(loc$obj)]"
  set res [list "$ownname.fra - - 1 10 {-st new} {}"]
  # if calendars are linked with staticdate, no display of tool bar
  if {$p(staticdate$obj) ne {}} {
    lappend res \
      "$ownname.fra.LabMonth$obj - - - - {pack -fill x -expand 1} {-anchor center -w 14}"
  } else {
    lappend res \
    "$ownname.fra.tool - - - - {pack -side top} {-array { \
      IM_KLND_0 {{::klnd::my::SetCurrentDay2 $obj} -tip {$::klnd::my::p(tipF3$obj)\n(F3)@@-under 5}} sev 6 \
      IM_KLND_1 {{::klnd::my::GoYear2 $obj -1} -tip {$::klnd::my::prevY\n(Home)@@-under 5}} h_ 2 \
      IM_KLND_2 {{::klnd::my::GoMonth2 $obj -1} -tip {$::klnd::my::prevM\n(PageUp)@@-under 5}} h_ 3 \
      LabMonth$obj {{} {-fill x -expand 1} {-anchor center -w 14}} h_ 2 \
      IM_KLND_3 {{::klnd::my::GoMonth2 $obj 1} -tip {$::klnd::my::nextM\n(PageDown)@@-under 5}} h_ 3 \
      IM_KLND_4 {{::klnd::my::GoYear2 $obj 1} -tip {$::klnd::my::nextY\n(End)@@-under 5}} h_ 2 \
    }}"
  }
  lappend res "$ownname.fraDays $ownname.fra T - - {-st nsew}"
  lappend res \
    [list $ownname.fraDays.tcl " \
      if {{$::tcl_platform(platform)} eq {windows}} { \
        set att {-highlightthickness 1 -w 6} \
      } else { \
        set att {-highlightthickness 0 -w 3} \
      } ; \
      set wt - ; \
      for {set i 1} {\$i<50} {incr i} { \
        if {\$i<8} {set cur $ownname.fraDays.LabDay$obj\$i} {set cur $ownname.fraDays.BuT$obj-\[expr {\$i-7}\]KLND} ; \
        if {(\$i%7)!=1} {set p L; set pw \$pr} {set p T; set pw \$wt; set wt \$cur} ; \
        if {\$i<8} { \
          set lwid \"\$cur \$pw \$p 1 1 {-st ew} {-anchor center -foreground $::klnd::my::p(fgh)}\" \
        } else { \
          set lwid \"\$cur \$pw \$p 1 1 {-st ew} {-relief flat -overrelief flat -bd 0 -takefocus 0 -pady 2 -com {::klnd::my::Enter2 $obj \[expr {\$i-7}\]} \$att}\" \
        } ; \
        %C \$lwid ; \
        set pr \$cur \
      }"
    ]
  return $res
}
#_______________________

# ________________________ UI _________________________ #

proc ::klnd::calendar2 {pobj w ownname args} {
  # The main procedure of the calendar embedded widget.
  #   w - container widget for *ownname*
  #   ownname - frame widget for calendar
  #   args - options of the calendar
  # Returns a list of widgets for apave layout.

  variable my::p
  set obj [incr my::p(objNUM)]
  set my::p($obj) $pobj
  my::InitSettings
  my::InitCalendar {*}$args
  if {$p(currentmonth) eq {}} {
    lassign [::klnd::currentYearMonthDay] year month
    set p(currentmonth) "$year/$month"
  }
  foreach opt {weekday months days loc yvis mvis dvis \
  com tvar dformat static staticdate currentmonth} {
    set my::p($opt$obj) $my::p($opt)
  }
  # if calendars are linked with staticdate, it's selected at start
  # and saved as previously selected one
  set p(olddate$obj) $p(staticdate)
  # binds for day buttons and show and work with the calendar
  after idle "::klnd::my::BindButtons2 $obj; \
    ::klnd::my::ShowMonth2 $obj $my::p(m) $my::p(y)"
  set res [my::MainWidgets2 $obj $ownname]
  return $res
}

# _________________________________ EOF _________________________________ #

#RUNF1: ../../tests/test2_pave.tcl 1 13 12 'small icons'
#RUNF1: ../../../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
