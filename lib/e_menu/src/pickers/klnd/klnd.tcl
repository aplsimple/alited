#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# A calendar widget for apave package.
#
# See pkgIndex.tcl for details.
# _______________________________________________________________________ #

package require Tk
package provide klnd 1.1

namespace eval ::klnd {
  namespace export calendar
  namespace eval my {
    variable p
    variable locales
    # locale 1st day of week: %u means Mon (default), %w means Sun
    array set locales [list \
      en_uk %u \
      en_us %w \
      ru_ru %u \
      ru_ua %u \
      uk_ua %u \
      be_by %u \
    ]
    array set p [list FINT %Y/%N/%e days {} months {} \
      d 0 m 0 y 0 dvis 0 mvis 0 yvis 0 icurr 0 ienter 0 weekday "" d1st 1]
  }
}

# _______________________________________________________________________ #

proc ::klnd::my::CurrentDate {} {
  # Gets the current date.

  variable p
  set sec [clock seconds]
  lassign [split [clock format $sec -format $p(FINT)] /] p(y) p(m) p(d)
  return $sec
}

# _____________________ Internal procedures of klnd _____________________ #

proc ::klnd::my::InitCalendar {} {
  # Initializes the settings of the calendar.

  variable p
  variable locales
  # colors to be used
  lassign [::apave::obj csGet] p(fg0) p(fg1) p(bg0) p(bg1) - p(bg) p(fg) - - p(fgh) - - - - p(fg2) p(bg2)
  CurrentDate
  set p(yvis) $p(y)  ;# by default, the selected date = the current date
  set p(mvis) $p(m)
  set p(dvis) $p(d)
  # get localized setting of 1st week day
  set loc [lindex [::msgcat::mcpreferences] 0]
  if {$p(weekday) eq ""} {
    if {[array names locales $loc] ne ""} {
      set p(weekday) $locales($loc)
    } else {
      set p(weekday) %u  ;# by default, 1st day of week is Monday
    }
  }
  # get localized week day names
  set p(days) [list]
  foreach i {0 1 2 3 4 5 6} {
    lappend p(days) [clock format [clock scan "06/[expr {22+$i}]/1941" -format %D] \
      -format %a -locale $loc]
  }
  if {$p(weekday) eq "%u"} {  ;# Sunday be the last day of week
    set d1 [lindex $p(days) 0]
    set p(days) [list {*}[lrange $p(days) 1 end] $d1]
  }
  # get localized month names
  set p(months) [list]
  foreach i {01 02 03 04 05 06 07 08 09 10 11 12} {
    lappend p(months) [clock format [clock scan "$i/01/1941" -format %D] \
      -format %B -locale $loc]
  }
}
#_____

proc ::klnd::my::ShowMonth {m y} {
  # Displays a month's days.
  #   m - month
  #   y -year

  variable p
  set sec [CurrentDate]
  set y [expr {max($y,1753)}]
  ::baltip::tip [$p(obj) BuT_IM_AP_0] \
    "Current date (F3)\n[clock format $sec -format $p(dformat)]" -under 5
  # display month & year
  [$p(obj) LabMonth] configure -text  "[lindex $p(months) [expr {$m-1}]] $y" \
    -font "[$p(obj) csFontDef] -size [expr {[$p(obj) basicFontSize]+3}]"
  # display day names
  for {set i 1} {$i<8} {incr i} {
    [$p(obj) LabDay$i] configure -text " [lindex $p(days) $i-1] "
  }
  # 1st day of the month's first week:
  set i0 [clock format [clock scan "$m/1/$y" -format %D] -format %w]
  if {$p(weekday) eq "%u"} {if {$i0} {incr i0 -1} {set i0 6}}
  # get the last day of month
  if {[set yl $y] && [set ml $m]==12} {set ml 1; incr yl}
  set lday [clock format [clock scan "[incr ml]/1/$yl 1 day ago"] -format %d]
  set iday [set p(icurr) 0]
  for {set i 1} {$i<43} {incr i} {
    if {$i<=$i0 || $iday>=$lday} {
      set att "-takefocus 0 -text {    } -activebackground $p(bg1)"
    } else {
      set att "-takefocus 1 -text {[incr iday]} -activeforeground $p(fg0) -activebackground $p(bg0)"
      if {$iday==$p(dvis) || ($iday==$lday && $iday<$p(dvis))} {
        if {[info exists p(after)]} {set af 20} {set af 200} ;# less at key pressing tight
        catch {after cancel $p(after)}
        set p(after) [after $af "::klnd::my::Enter $i; ::klnd::my::HighlightCurrentDay"]
      }
      if {$iday==1} {set p(d1st) $i}
      if {$y==$p(y) && $m==$p(m) && $iday==$p(d)} {
        set p(icurr) $i  ;# button's index of the current date
      }
    }
    [$p(obj) BuTSTD$i] configure {*}$att -fg $p(fg1) -bg $p(bg1) -relief flat -overrelief flat
  }
  set p(mvis) $m  ;# month & year currently visible
  set p(yvis) $y
}
#_____

proc ::klnd::my::GoYear {i {dobreak no}} {
  # Shifts the year backward/forward.
  #   i - increment for the current year
  #   dobreak - yes when called from 'bind'

  variable p
  ShowMonth $p(mvis) [expr {$p(yvis)+($i)}]
  if {$dobreak} {return -code break}
}
#_____

proc ::klnd::my::GoMonth {i {dobreak no}} {
  # Shifts the month backward/forward.
  #   i - increment for the current month
  #   dobreak - yes when called from 'bind'

  variable p
  set m [expr {$p(mvis)+($i)}]
  if {$m>12} {set m 1; incr p(yvis)}
  if {$m<1} {set m 12; incr p(yvis) -1}
  ShowMonth $m $p(yvis)
  if {$dobreak} {return -code break}
}
#_____

proc ::klnd::my::SetCurrentDay {} {
  # Goes to the current date.

  variable p
  set p(dvis) 0
  ShowMonth $p(m) $p(y)
  Enter $p(icurr)
}
#_____

proc ::klnd::my::IsDay {i} {
  # Check if a button shows a day.
  #   i - button index

  variable p
  return [expr {![catch {set w [$p(obj) BuTSTD$i]}] && [$w cget -takefocus]}]
}
#_____

proc ::klnd::my::DoubleClick {win i} {
  # Processes double-clicking a button (to choose or ignore).
  #   win - window's path
  #   i - button index

  variable p
  if {[IsDay $i]} {$p(obj) res $win 1}
}
#_____

proc ::klnd::my::KeyPress {i K} {
  # Processes the key presses on buttons.
  #   i - button index
  #   K - pressed key

  variable p
  Leave $i
  switch -glob $K {
    Left {set n [expr {$i-1}]}
    Right {set n [expr {$i+1}]}
    Up {set n [expr {$i-7}]}
    Down {set n [expr {$i+7}]}
    Enter - Return - space {$p(obj) res $p(win) 1; return -code break}
    *Tab* {Leave; focus [$p(obj) ButClose]; return -code break}
    default {Enter $i; return}
  }
  if {[IsDay $n]} {
    Enter $n
  } elseif {$K in {Left Up}} {
    GoMonth -1
  } else {
    GoMonth 1
  }
}
#_____

proc ::klnd::my::Enter {i} {
  # Highlights a button and makes it current.
  #   i - button index

  variable p
  if {![IsDay $i]} return
  Leave
  [set w [$p(obj) BuTSTD$i]] configure -fg $p(fg) -bg $p(bg)
  set p(ienter) $i
  set p(dvis) [$w cget -text]
  catch {after cancel $p(after2)}
  set p(after2) [after 10 "if \[winfo exists $w\] {focus -force $w}"]
}
#_____

proc ::klnd::my::Leave {{i 0}} {
  # Unhighlights a button.
  #   i - button index

  variable p
  if {$i && ![[$p(obj) BuTSTD$i] cget -takefocus]} return
  foreach n [list $i $p(ienter)] {
    if {$n} {[$p(obj) BuTSTD$n] configure -fg $p(fg1) -bg $p(bg1)}
  }
  HighlightCurrentDay
}
#_____

proc ::klnd::my::HighlightCurrentDay {} {
  # Highlights the current day's button.

  variable p
  catch {[$p(obj) BuTSTD$p(icurr)] configure -fg $p(fg2) -bg $p(bg2)}
}

# _______________________________________________________________________ #

proc ::klnd::calendar {args} {
  # The main procedure of the calendar.
  #   args - options of the calendar

  variable my::p
  # get options and initialize the calendar's settings
  lassign [::apave::parseOptions $args -title "Calendar" -value "" -tvar "" \
    -parent "" -dateformat %D -weekday "" -centerme "" -geometry "" -entry ""] \
    title datevalue tvar parent my::p(dformat) my::p(weekday) centerme geo entry
  set args [::apave::removeOptions $args -title -value -tvar -parent -dateformat -weekday]
  if {$tvar ne ""} {set datevalue [set $tvar]}
  catch {unset my::p(after)} ;# to pause more at start
  my::InitCalendar
  set p(close) [::apave::mc Close]
  # make the icons
  foreach {i icon} {0 date 1 previous2 2 previous 3 next 4 next2} {
    image create photo IM_AP_$i -data [::apave::iconData $icon]
  }
  # priority of geometry options: -geometry, -entry, -parent, -centerme
  # if no geometry option, show the calendar under the mouse pointer
  if {$geo ne ""} {
    set geo "-geometry $geo"
  } elseif {$entry ne ""} {
    set x [winfo rootx $entry]
    set y [expr {[winfo rooty $entry]+32}]
    set geo "-geometry +$x+$y"
  } elseif {$parent ne ""} {
    set geo "-centerme $parent"    ;# to center in a toplevel window
  } elseif {$centerme ne ""} {
    set geo "-centerme $centerme"  ;# it's an option of apave's 
  } else {
    set geo "-geometry +[expr {[winfo pointerx .]+10}]+[expr {[winfo pointery .]+10}]"
  }
  set parent [string trimright $parent .]
  set win [set my::p(win) "$parent._apave_CALENDAR_"]
  catch {$my::p(obj) destroy}
  # create apave object and layout its window
  set my::p(obj) [::apave::APaveInput create APAVE_CLND $win]
  $my::p(obj) makeWindow $win.fra $title
  $my::p(obj) paveWindow $win.fra {
    {fraTool - - 1 10 {-st new} {}}
    {fraTool.tool - - - - {pack -side top} {-array {
      IM_AP_0 {::klnd::my::SetCurrentDay} sev 6
      IM_AP_1 {{::klnd::my::GoYear -1} -tooltip "Previous year (Home)@@-under 5"} h_ 2
      IM_AP_2 {{::klnd::my::GoMonth -1} -tooltip "Previous month (PageUp)@@-under 5"} h_ 3
      LabMonth {"" {-fill x -expand 1} {-anchor center}} h_ 2
      IM_AP_3 {{::klnd::my::GoMonth 1} -tooltip "Next month (PageDown)@@-under 5"} h_ 3
      IM_AP_4 {{::klnd::my::GoYear 1} -tooltip "Next year (End)@@-under 5"} h_ 2
    }}}
    {fraDays fraTool T - - {-st nsew}}
    {fraDays.tcl {
      # make headers and buttons of days
      if {$::tcl_platform(platform) eq "windows"} {
        set att "-highlightthickness 1 -w 6"
      } else {
        set att "-highlightthickness 0 -w 3"
      }
      set wt -
      for {set i 1} {$i<50} {incr i} {
        if {$i<8} {set cur "fraDays.LabDay$i"} {set cur "fraDays.BuTSTD[expr {$i-7}]"}
        if {($i%7)!=1} {set p L; set pw $pr} {set p T; set pw $wt; set wt $cur}
        if {$i<8} {
          set lwid "$cur $pw $p 1 1 {-st ew} {-anchor center -foreground $::klnd::my::p(fgh)}"
        } else {
          set lwid "$cur $pw $p 1 1 {-st ew} {-relief flat -overrelief flat -bd 0 -takefocus 0 -pady 2 -com {::klnd::my::Enter [expr {$i-7}]} $att}"
        }
        %C $lwid
        set pr $cur
      }
    }}
    {seh FraDays T 1 10 {-pady 4}}
    {fraBottom seh T - - {-st ew}}
    {fraBottom.h_ - - - - {pack -fill both -expand 1 -side left} {}}
    {fraBottom.ButClose - - - - {pack -side left} {-t "$::klnd::my::p(close)" -com "$::klnd::my::p(obj) res $win 0"}}
  }
  # binds for day buttons and 'Close'
  foreach {ev prc} { <Home> "::klnd::my::GoYear -1 yes" <End> "::klnd::my::GoYear 1 yes" \
  <Prior> "::klnd::my::GoMonth -1 yes" <Next> "::klnd::my::GoMonth 1 yes"} {
    for {set i 1} {$i<38} {incr i} {
      set but [$my::p(obj) BuTSTD$i]
      bind $but $ev $prc
      bind $but <FocusIn> "::klnd::my::Enter $i"
      bind $but <KeyPress> "::klnd::my::KeyPress $i %K"
      bind $but <Double-1> "::klnd::my::DoubleClick $win $i"
    }
    bind [$my::p(obj) ButClose] $ev $prc
  }
  bind $win <F3> ::klnd::my::SetCurrentDay
  bind $win <KeyPress> "::klnd::my::Leave"
  # get the day to display at start
  set m $my::p(m)
  set y $my::p(y)
  if {![catch {set ym [clock scan $datevalue -format $my::p(dformat)]}]} {
    set m [clock format $ym -format %N]
    set y [clock format $ym -format %Y]
    set my::p(dvis) [clock format $ym -format %e]
  }
  # show and work with the calendar
  after idle "::klnd::my::ShowMonth $m $y"
  set res [$my::p(obj) showModal $win -resizable {0 0} {*}$args {*}$geo]
  # get the result of the selection if any
  if {$res && $my::p(dvis)} {
    set res [clock format [clock scan $my::p(mvis)/$my::p(dvis)/$my::p(yvis) -format %D] -format $my::p(dformat)]
    if {$tvar ne ""} {set $tvar $res}
  } else {
    set res ""
  }
  $my::p(obj) destroy
  destroy $win
  return $res
}
# _________________________________ EOF _________________________________ #
#RUNF1: ../../tests/test2_pave.tcl 1 13 12 'small icons'
