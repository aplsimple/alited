###########################################################
# Name:    klnd.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    01/18/2022
# Brief:   Handles calendar picker for apave package.
# License: MIT.
###########################################################

package require Tk
package provide klnd 1.4

# ________________________ klnd _________________________ #

namespace eval ::klnd {
  namespace export calendar
  namespace eval my {
    variable msgdir [file normalize [file join [file dirname [info script]] msgs]]
    variable p
    variable locales
    # locale 1st day of week: %u means Mon (default), %w means Sun
    array set locales [list \
      en_uk %u \
      en_us %w \
      ru %u \
      ru_ru %u \
      ru_ua %u \
      uk %u \
      ua %u \
      uk_ua %u \
      ua_ua %u \
      by %u \
      be_by %u \
    ]
    array set p [list FINT %Y/%N/%e days {} months {} \
      d 0 m 0 y 0 dvis 0 mvis 0 yvis 0 icurr 0 ienter 0 weekday {} d1st 1]
  }
}


# ________________________ my _________________________ #

## ________________________ Go month/year _________________________ ##

proc ::klnd::my::TrimN {n} {
  # Strips day/month of leading 0 and space.
  #   n - day/month

  return [string trimleft $n { 0}]
}
#_______________________

proc ::klnd::my::IsDay {i} {
  # Check if a button shows a day.
  #   i - button index

  variable p
  return [expr {![catch {set w [$p(obj) BuT_KLNDSTD$i]}] && [$w cget -takefocus]}]
}
#_______________________

proc ::klnd::my::GoYear {i {dobreak no}} {
  # Shifts the year backward/forward.
  #   i - increment for the current year
  #   dobreak - yes when called from 'bind'

  variable p
  ShowMonth $p(mvis) [expr {$p(yvis)+($i)}]
  if {$dobreak} {return -code break}
}
#_______________________

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
#_______________________

proc ::klnd::my::ShowMonth {m y} {
  # Displays a month's days.
  #   m - month
  #   y -year

  variable p
  set sec [CurrentDate]
  set y [expr {max($y,1753)}]
  ::baltip::tip [$p(obj) BuT_IM_KLND_0] \
    "[::msgcat::mc {Current date}]: [clock format $sec -format $p(dformat)]\n(F3)" -under 5
  # display month & year
  [$p(obj) LabMonth] configure -text  "[lindex $p(months) [expr {$m-1}]] $y" \
    -font [::apave::obj boldDefFont [expr {[::apave::obj basicFontSize]+2}]]
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
    [$p(obj) BuT_KLNDSTD$i] configure {*}$att -fg $p(fg1) -bg $p(bg1) -relief flat -overrelief flat
  }
  set p(mvis) $m  ;# month & year currently visible
  set p(yvis) $y
}

## ________________________ Current day _________________________ ##

proc ::klnd::my::CurrentDate {} {

  # Gets the current date.

  variable p
  set sec [clock seconds]
  lassign [split [clock format $sec -format $p(FINT)] /] p(y) p(m) p(d)
  return $sec
}
#_______________________

proc ::klnd::my::SetCurrentDay {} {
  # Goes to the current date.

  variable p
  set p(dvis) 0
  ShowMonth $p(m) $p(y)
  Enter $p(icurr)
}
#_______________________

proc ::klnd::my::HighlightCurrentDay {} {
  # Highlights the current day's button.

  variable p
  catch {[$p(obj) BuT_KLNDSTD$p(icurr)] configure -fg $p(fg2) -bg $p(bg2)}
}

## ________________________ Event handlers _________________________ ##

proc ::klnd::my::DoubleClick {win i} {
  # Processes double-clicking a button (to choose or ignore).
  #   win - window's path
  #   i - button index

  variable p
  if {[IsDay $i]} {$p(obj) res $win 1}
}
#_______________________

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
    *Tab* {Leave; focus [$p(obj) But_KLNDCLOSE]; return -code break}
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
#_______________________

proc ::klnd::my::Enter {i {focusin 0}} {
  # Highlights a button and makes it current.
  #   i - button index
  #   focusin - yes, if the button is clicked and focused

  variable p
  if {![IsDay $i]} return
  Leave
  [set w [$p(obj) BuT_KLNDSTD$i]] configure -fg $p(fgsel) -bg $p(bgsel)
  set p(ienter) $i
  set p(dvis) [$w cget -text]
  catch {after cancel $p(after2)}
  set p(after2) [after 10 "if \[winfo exists $w\] {focus -force $w}"]
  if {$focusin && $p(com) ne {}} {eval $p(com)}
}
#_______________________

proc ::klnd::my::Leave {{i 0}} {
  # Unhighlights a button.
  #   i - button index

  variable p
  if {$i && ![[$p(obj) BuT_KLNDSTD$i] cget -takefocus]} return
  foreach n [list $i $p(ienter)] {
    if {$n} {[$p(obj) BuT_KLNDSTD$n] configure -fg $p(fg1) -bg $p(bg1)}
  }
  HighlightCurrentDay
}

## ________________________ Initializing _________________________ ##

proc ::klnd::my::InitSettings {} {
  # Gets initial settings, once only.

  variable p
  variable msgdir
  if {![info exists :klnd::my::prevY]} {
    foreach {i icon} {0 date 1 previous2 2 previous 3 next 4 next2} {
      image create photo IM_KLND_$i -data [::apave::iconData $icon small]
    }
    lassign [::apave::obj csGet] p(fg0) p(fg1) p(bg0) p(bg1) - p(bgsel) p(fgsel) - - p(fgh) - - - - p(fg2) p(bg2)
    # localized stuff
    catch {::msgcat::mcload $msgdir}
    set ::klnd::my::prevY [::msgcat::mc {Previous year}]
    set ::klnd::my::prevM [::msgcat::mc {Previous month}]
    set ::klnd::my::nextY [::msgcat::mc {Next year}]
    set ::klnd::my::nextM [::msgcat::mc {Next month}]
  }
}
#_______________________

proc ::klnd::my::InitCalendar {args} {
  # Initializes the settings of the calendar.

  variable p
  variable locales
  InitSettings
  lassign [::apave::parseOptions $args \
  -title {} -value {} -tvar {} -locale {} -parent {} -dateformat %D \
  -weekday {} -centerme {} -geometry {} -entry {} -com {} -command {} \
  -currentmonth {} -united no -daylist {-} -hllist {} -popup {} -tip {}] \
    title datevalue tvar loc parent p(dformat) \
    p(weekday) centerme geo entry com1 com2 \
    p(currentmonth) p(united) p(daylist) p(hllist) p(popup) p(tip)
  if {$com2 eq {}} {set p(com) $com1} {set p(com) $com2}
  # get localized week day names
  lassign [::klnd::weekdays $loc] p(days) p(weekday)
  # get localized month names
  set p(months) [::klnd::months $loc]
  set p(loc) $loc
  set p(tvar) $tvar
  if {$tvar ne {}} {
    set datevalue [set $tvar]
  } elseif {$p(daylist) ne {-}} {
    set datevalue [lindex $p(daylist) 0]
  }
  catch {unset p(after)} ;# to pause more at start
  # colors to be used
  CurrentDate
  set p(yvis) $p(y)  ;# by default, the selected date = the current date
  set p(mvis) $p(m)
  set p(dvis) $p(d)
  if {$title eq {}} {set title [::msgcat::mc Calendar]}
  catch {set p(dformat) [subst $p(dformat)]}
  # get the day to display at start
  if {![catch {set ym [clock scan $datevalue -format $p(dformat)]}]} {
    set p(m) [clock format $ym -format %N]
    set p(y) [clock format $ym -format %Y]
    set p(dvis) [clock format $ym -format %e]
  }
  ::apave::obj untouchWidgets *KLND*
  return [list $title $datevalue $tvar $parent $centerme $geo $entry]
}
#_______________________

proc ::klnd::my::MainWidgets {} {
  # Forms main widgets of calendar.

  variable p
  if {$p(tip) eq {}} {
    set ::klnd::TMPTIP {}
  } else {
    set tip [string map [list \{ ( \} )] $p(tip)] ;# for a possible bad list
    set ::klnd::TMPTIP "-tip {$tip}"
  }
  return {
    {fra - - 1 7 {-st new} {}} \
    {.frATool - - 1 7 {-st new} {-bg $::klnd::my::p(bg1)}}
    {.frATool.tool - - - - {pack -side top} {-array {
      IM_KLND_0 {::klnd::my::SetCurrentDay} sev 6
      IM_KLND_1 {{::klnd::my::GoYear -1} -tip "$::klnd::my::prevY\n(Home)@@-under 5"} h_ 2
      IM_KLND_2 {{::klnd::my::GoMonth -1} -tip "$::klnd::my::prevM\n(PageUp)@@-under 5"} h_ 3
      LabMonth {"" {-fill x -expand 1} {-anchor center -w 14}} h_ 2
      IM_KLND_3 {{::klnd::my::GoMonth 1} -tip "$::klnd::my::nextM\n(PageDown)@@-under 5"} h_ 3
      IM_KLND_4 {{::klnd::my::GoYear 1} -tip "$::klnd::my::nextY\n(End)@@-under 5"} h_ 2
    }}}
    {.frADays .frATool T - - {-st nsew} {-bg $::klnd::my::p(bg1)}}
    {.frADays.tcl {
      # make headers and buttons of days
      if {$::tcl_platform(platform) eq {windows}} {
        set att {-highlightthickness 1}
      } else {
        set att {-highlightthickness 0}
      }
      set wt -
      for {set i 1} {$i<50} {incr i} {
        if {$i<8} {set cur ".frADays.LabDay$i"} {set cur ".frADays.BuT_KLNDSTD[expr {$i-7}]"}
        if {($i%7)!=1} {set p L; set pw $pr} {set p T; set pw $wt; set wt $cur}
        if {$i<8} {
          set lwid "$cur $pw $p 1 1 {-st ew} {-anchor center -foreground $::klnd::my::p(fgh) -background $::klnd::my::p(bg1)}"
        } else {
          set lwid "$cur $pw $p 1 1 {-st ew} {-relief flat -overrelief flat -bd 0 -takefocus 0 -padx 8 -pady 4 -font {$::apave::FONTMAIN} -com {::klnd::my::Enter [expr {$i-7}] 1} $::klnd::TMPTIP $att -w 3 -background $::klnd::my::p(bg1)}"
        }
        %C $lwid
        set pr $cur
      }
    }}
  }
}
#_______________________

proc ::klnd::my::DefaultLocale {} {
  # Gets a default locale currently used in a system.

  return [lindex [::msgcat::mcpreferences] 0]
}

# ________________________ UI _________________________ #

proc ::klnd::minYear {} {
  # Gets minimal year that is correct.

  return 1753
}
#_______________________

proc ::klnd::maxYear {} {
  # Gets maximal year that is correct.

  return 9999
}
#_______________________

proc ::klnd::currentYearMonthDay {} {
  # Gets current year, month, day.
  # Return a list of  current year, month, day.

  set ym [clock seconds]
  return [list {*}"\
    [clock format $ym -format %Y] \
    [clock format $ym -format %N] \
    [clock format $ym -format %e]"]
  ]
}
#_______________________

proc ::klnd::months {{loc ""}} {
  # Gets a list of months according to a locale.
  #   loc - the locale

  if {$loc eq {}} {set loc [my::DefaultLocale]}
  set months [list]
  foreach i {01 02 03 04 05 06 07 08 09 10 11 12} {
    lappend months [clock format [clock scan "$i/01/2021" \
      -format %D -locale $loc] -format %B -locale $loc]
  }
  return $months
}
#_______________________

proc ::klnd::weekdays {{loc ""}} {
  # Gets a list of week days according to a locale.
  #   loc - the locale
  # Return list of weekdays and week format (%u or %w)

  variable my::locales
  if {$loc eq {}} {set loc [my::DefaultLocale]}
  if {[array names my::locales $loc] ne {}} {
    set wformat $my::locales($loc)
  } else {
    set wformat %u  ;# by default, 1st day of week is Monday
  }
  if {$wformat eq {%u}} {  ;# Sunday be the last day of week
    set wdays {1 2 3 4 5 6 7}
  } else {
    set wdays {0 1 2 3 4 5 6}
  }
  set days [list]
  foreach i $wdays {
    lappend days [clock format [clock scan "03/[expr {14+$i}]/2021" \
      -format %D -locale $loc] -format %a -locale $loc]
  }
  return [list $days $wformat]
}
#_______________________

proc ::klnd::clearArgs {args} {
  # Removes specific options from args.
  #   args - list of options

  return [::apave::removeOptions $args -title -value -tvar -locale -parent -dateformat -weekday -com -command -currentmonth -united -daylist -hllist -popup -tip]
}
#_______________________

proc ::klnd::calendar {args} {
  # The main procedure of the calendar's toplevel.
  #   args - options of the calendar

  variable my::p
  set my::p(isWidget) no
  # get options and initialize the calendar's settings
  lassign [my::InitCalendar {*}$args] title datevalue tvar parent centerme geo entry
  set args [clearArgs {*}$args]
  # priority of geometry options: -geometry, -entry, -parent, -centerme
  # if no geometry option, show the calendar under the mouse pointer
  if {$geo ne {}} {
    set geo "-geometry $geo"
  } elseif {$entry ne {}} {
    set x [winfo rootx $entry]
    set y [expr {[winfo rooty $entry]+32}]
    set geo "-geometry +$x+$y"
  } elseif {$parent ne {}} {
    set geo "-centerme $parent"    ;# to center in a toplevel window
  } elseif {$centerme ne {}} {
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
  $my::p(obj) paveWindow $win.fra [list \
    {*}[my::MainWidgets] \
    {seh fra T 1 7 {-pady 4}} \
    {fraBottom seh T 1 7 {-st ew}} \
    {fraBottom.h_ - - - - {pack -fill both -expand 1 -side left} {}} \
    {fraBottom.But_KLNDCLOSE - - - - {pack -side left} {-t "Close" -com "$::klnd::my::p(obj) res $win 0"}} \
  ]
  # binds for day buttons and 'Close'
  foreach {ev prc} { <Home> "::klnd::my::GoYear -1 yes" <End> "::klnd::my::GoYear 1 yes" \
  <Prior> "::klnd::my::GoMonth -1 yes" <Next> "::klnd::my::GoMonth 1 yes"} {
    for {set i 1} {$i<38} {incr i} {
      set but [$my::p(obj) BuT_KLNDSTD$i]
      bind $but $ev $prc
      bind $but <FocusIn> "::klnd::my::Enter $i"
      bind $but <KeyPress> "::klnd::my::KeyPress $i %K"
      bind $but <Double-1> "::klnd::my::DoubleClick $win $i"
    }
    catch {bind [$my::p(obj) But_KLNDCLOSE] $ev $prc}
  }
  bind $win <F3> ::klnd::my::SetCurrentDay
  bind $win <KeyPress> "::klnd::my::Leave"
  # show and work with the calendar
  after idle "::klnd::my::ShowMonth $my::p(m) $my::p(y)"
  set res [$my::p(obj) showModal $win -resizable {0 0} {*}$args {*}$geo]
  # get the result of the selection if any
  if {$res && $my::p(dvis)} {
    set res [clock format [clock scan $my::p(mvis)/$my::p(dvis)/$my::p(yvis) -format %D] -format $my::p(dformat)]
    if {$tvar ne {}} {set $tvar $res}
  } else {
    set res {}
  }
  $my::p(obj) destroy
  destroy $win
  return $res
}

# _________________________________ EOF _________________________________ #

#-RUNF1: ../../tests/test2_pave.tcl 1 13 12 'small icons'
#RUNF1: ~/PG/github/alited/src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
