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
  ShowMonth $p(mvis) [expr {$p(yvis)+($i)}] yes
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
  ShowMonth $m $p(yvis) yes
  if {$dobreak} {return -code break}
}
#_______________________

proc ::klnd::my::WeekNumbers {day1st ttls} {
  # Gets the list of week numbers for a month.
  #   day1st - 1st day of months
  #   ttls - list of calender button's titles

  variable p
  set res [list]
  set secw $day1st
  set incd 0
  for {set i 1} {$i<7} {incr i} {
    set dtext [clock format $secw -format %V]
    if {$p(weeks)==2} {
      # 2nd (vulgar) mode of week numeration
      set month [clock format $secw -format %m]
      if {[clock format $secw -format %Y]>[clock format $day1st -format %Y]} {
        set dtext {}
      } elseif {$i==1 && $month eq {01} && $dtext ne {01}} {
        set dtext {01}
        set incd 1
      } elseif {$month==12 && $dtext eq {01}} {
        set dtext [incr dtextprev]
      } else {
        set dtext [string range 0[expr {[string trimleft $dtext 0]+$incd}] end-1 end]
      }
      set dtextprev $dtext
    }
    if {$i==5 && [lindex $ttls 28] eq {} || $i==6 && [lindex $ttls 35] eq {}} {
      set dtext {}
    }
    lappend res $dtext
    set w [clock format $secw -format %w]
    if {$w} {set w [expr {8-$w}]} {set w 1}
    set secw [clock add $secw $w days]
  }
  return $res
}
#_______________________

proc ::klnd::my::ShowMonth {m y {dopopup no}} {
  # Displays a month's days.
  #   m - month
  #   y -year
  #   dopopup - yes, if bind a popup menu

  variable p
  set sec [CurrentDate]
  set y [expr {max($y,1753)}]
  ::baltip::tip [$p(obj) BuT_IM_KLND_0] \
    "[::msgcat::mc {Current date}]: [clock format $sec -format $p(dformat) -locale $p(loc)]\n(F3)" -under 5
  # display month & year
  [$p(obj) LabMonth] configure -text  "[lindex $p(months) [expr {$m-1}]] $y" \
    -font [::apave::obj boldDefFont [expr {[::apave::obj basicFontSize]+2}]]
  # display day names
  for {set i 1} {$i<8} {incr i} {
    [$p(obj) LabDay$i] configure -text " [lindex $p(days) $i-1] "
  }
  # 1st day of the month's first week:
  set day1st [clock scan "$m/1/$y" -format %D]
  set i0 [clock format $day1st -format %w]
  if {$p(weekday) eq "%u"} {if {$i0} {incr i0 -1} {set i0 6}}
  # get the last day of month
  if {[set yl $y] && [set ml $m]==12} {set ml 1; incr yl}
  set lday [clock format [clock scan "[incr ml]/1/$yl 1 day ago"] -format %d]
  set iday [set p(icurr) 0]
  for {set i 1} {$i<38} {incr i} {
    if {$i<=$i0 || $iday>=$lday} {
      set ttl {    }
      set att "-takefocus 0 -activebackground $p(bg1) -overrelief flat"
      set script {}
    } else {
      set ttl [incr iday]
      set att "-takefocus 1 -activeforeground $p(fg0) -activebackground $p(bg0) -overrelief raised"
      if {$iday==$p(dvis) || ($iday==$lday && $iday<$p(dvis))} {
        if {[info exists p(after)]} {set af 20} {set af 200} ;# less at key pressing tight
        catch {after cancel $p(after)}
        set p(after) [after $af "::klnd::my::Enter $i; ::klnd::my::HighlightCurrentDay"]
      }
      if {$iday==1} {set p(d1st) $i}
      if {$y==$p(y) && $m==$p(m) && $iday==$p(d)} {
        set p(icurr) $i  ;# button's index of the current date
      }
      if {$dopopup} {
        set script [MapYMD $p(popup) $y $m $iday]
      }
    }
    lappend ttls [string trim $ttl]
    set wbut [$p(obj) BuT_KLNDSTD$i]
    $wbut configure {*}$att -fg $p(fg1) -bg $p(bg1) -relief flat -text $ttl
    if {$dopopup && $p(popup) ne {}} {
      bind $wbut <Button-3> $script
    }
  }
  set wnums [WeekNumbers $day1st $ttls]
  for {set i 0} {$i<6} {} {
    set wnum [lindex $wnums $i]
    set wbut [$p(obj) BuTW[incr i]]
    $wbut configure {*}$::klnd::TMPATTW -text $wnum
  }
  set p(mvis) $m  ;# month & year currently visible
  set p(yvis) $y
}

#_______________________

proc ::klnd::my::MapYMD {script y m d} {
  # Gets a script with %y, %m, %d wildcards.

  string map [list %y $y %m $m %d $d] $script
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
#_______________________

proc ::klnd::my::ChosenDay {{show no}} {
  # Formats a chosen day and displays it at need.
  #   show - if yes, displays the result

  variable p
  set res {}
  if {$p(dvis)} {
    set res [clock format [clock scan $p(mvis)/$p(dvis)/$p(yvis) -format %D] -format $p(dformat)]
    if {$show} {[$p(obj) ButOK] configure -text $res}
  }
  return $res
}

## ________________________ Event handlers _________________________ ##

proc ::klnd::my::PickDay {{i -1} {ret ""}} {
  # Processes choosing a button.
  #   i - button index
  #   ret - returned "-code break", for double-click

  variable p
  if {$i==-1} {set i $p(ienter)}
  if {[IsDay $i]} {$p(obj) res $p(win) 1}
  return {*}$ret
}
#_______________________

proc ::klnd::my::KeyPress {i K s} {
  # Processes the key presses on buttons.
  #   i - button index
  #   K - pressed key
  #   s - key's state

  variable p
  Leave $i
  switch -glob $K {
    Left {incr i -1}
    Right {incr i}
    Up {incr i -7}
    Down {incr i 7}
    Enter - Return - space {$p(obj) res $p(win) 1}
    F3 {SetCurrentDay; return -code break}
    *Tab* {
      if {$s%2} {set b Close} {set b OK}
      focus [$p(obj) But$b]
      return -code break
    }
    default {Enter $i; return}
  }
  if {[IsDay $i]} {
    Enter $i
  } elseif {$K in {Left Up}} {
    GoMonth -1
  } else {
    GoMonth 1
  }
  return -code break
}
#_______________________

proc ::klnd::my::Enter {i {focusin 0} {ret ""}} {
  # Highlights a button and makes it current.
  #   i - button index
  #   focusin - yes, if the button is clicked and focused
  #   ret - "return -code"

  variable p
  if {![IsDay $i]} {return {*}$ret}
  Leave
  [set w [$p(obj) BuT_KLNDSTD$i]] configure -fg $p(fgsel) -bg $p(bgsel)
  set p(ienter) $i
  set p(dvis) [$w cget -text]
  catch {after cancel $p(after2)}
  set p(after2) [after 10 "if \[winfo exists $w\] {focus -force $w}"]
  if {$focusin && $p(com) ne {}} {
    eval [MapYMD $p(com) $p(yvis) $p(mvis) $p(dvis)]
  }
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
  array set p [list FINT %Y/%N/%e days {} months {} \
    d 0 m 0 y 0 dvis 0 mvis 0 yvis 0 icurr 0 ienter 0 weekday {} \
    d1st 1 width 2 loc en_uk]
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
    set ::klnd::my::Close [::msgcat::mc Close]
  }
}
#_______________________

proc ::klnd::my::InitCalendar {args} {
  # Initializes the settings of the calendar.

  variable p
  variable locales
  InitSettings
  lassign [::apave::parseOptions $args -locale [::msgcat::mclocale] \
  -title {} -value {} -tvar {} -parent {} -dateformat %D -weeks 0 \
  -weekday {} -centerme {} -geometry {} -entry {} -com {} -command {} \
  -currentmonth {} -united no -daylist {-} -hllist {} -popup {} -tip {} -width 2] \
    loc title datevalue tvar parent p(dformat) p(weeks) \
    p(weekday) centerme geo entry com1 com2 \
    p(currentmonth) p(united) p(daylist) p(hllist) p(popup) p(tip) p(width)
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
  list $title $datevalue $tvar $parent $centerme $geo $entry
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
  if {$p(weeks)} {set ::klnd::TMPPACKW {}} {set ::klnd::TMPPACKW forget}
  if {[::iswindows]} {set pady 2} {set pady 1}
  set ::klnd::TMPATTW "-font {$::apave::FONTMAIN} -padx 0 -pady $pady \
    -activeforeground $p(fgh) -activebackground $p(bg1) -foreground $p(fgh) \
    -relief flat -overrelief flat -takefocus 0 -highlightthickness 0 -width 2"
  return {
    {fra - - 1 7 {-st new} {}} \
    {.frATool - - 1 7 {-st new} {-bg $::klnd::my::p(bg1)}}
    {.frATool.tool - - - - {pack -side top} {-array {
      IM_KLND_0 {::klnd::my::SetCurrentDay} sev 2
      IM_KLND_1 {{::klnd::my::GoYear -1} -tip "$::klnd::my::prevY\n(Home)@@-under 5"} h_ 1
      IM_KLND_2 {{::klnd::my::GoMonth -1} -tip "$::klnd::my::prevM\n(PageUp)@@-under 5"} h_ 2
      LabMonth {"" {-fill x -expand 1} {-anchor center -w 14}} h_ 1
      IM_KLND_3 {{::klnd::my::GoMonth 1} -tip "$::klnd::my::nextM\n(PageDown)@@-under 5"} h_ 2
      IM_KLND_4 {{::klnd::my::GoYear 1} -tip "$::klnd::my::nextY\n(End)@@-under 5"}
      }}}
    {.frAW .frATool T - - {-padx 0} {-bg $::klnd::my::p(bg1) -w 0 -borderwidth 0}}
    {.frAW.labw - - 1 1 {pack -pady 1}}
    {.frAW.BuTW1 + T 1 1 {pack $::klnd::TMPPACKW -pady 1} {$::klnd::TMPATTW}}
    {.frAW.BuTW2 + T 1 1 {pack $::klnd::TMPPACKW -pady 1} {$::klnd::TMPATTW}}
    {.frAW.BuTW3 + T 1 1 {pack $::klnd::TMPPACKW -pady 1} {$::klnd::TMPATTW}}
    {.frAW.BuTW4 + T 1 1 {pack $::klnd::TMPPACKW -pady 1} {$::klnd::TMPATTW}}
    {.frAW.BuTW5 + T 1 1 {pack $::klnd::TMPPACKW -pady 1} {$::klnd::TMPATTW}}
    {.frAW.BuTW6 + T 1 1 {pack $::klnd::TMPPACKW -pady 1} {$::klnd::TMPATTW}}
    {.frADays .frAW L 1 1 {-st nsew} {-bg $::klnd::my::p(bg1)}}
    {.frADays.tcl {
      # make headers and buttons of days
      if {$::tcl_platform(platform) eq {windows}} {
        set att {-highlightthickness 1}
      } else {
        set att {-highlightthickness 0}
      }
      set wt -
      for {set i 1} {$i<45} {incr i} {
        if {$i<8} {set cur ".frADays.LabDay$i"} {set cur ".frADays.BuT_KLNDSTD[expr {$i-7}]"}
        if {($i%7)!=1} {set p L; set pw $pr} {set p T; set pw $wt; set wt $cur}
        if {$i<8} {
          set lwid "$cur $pw $p 1 1 {-st ew} {-anchor center -foreground $::klnd::my::p(fgh) -background $::klnd::my::p(bg1)}"
        } else {
          set lwid "$cur $pw $p 1 1 {-st ew} {-relief flat -overrelief raised -takefocus 0 -padx 8 -pady 1 -font {$::apave::FONTMAIN} -com {::klnd::my::Enter [expr {$i-7}] 1} $::klnd::TMPTIP $att -w 2 -background $::klnd::my::p(bg1)}"
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
  # Returns a list of current year, month, day.

  set cl [clock seconds]
  foreach d {Y N e} {lappend res {*}[clock format $cl -format %$d]}
  return $res
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
  list $days $wformat
}
#_______________________

proc ::klnd::clearup {} {
  # Clearance for klnd data (variable my::p).

  variable my::p
  array unset my::p *
}
#_______________________

proc ::klnd::clearArgs {args} {
  # Removes specific options from args.
  #   args - list of options

  ::apave::removeOptions $args -title -value -tvar -locale -parent -dateformat -weekday -com -command -currentmonth -united -daylist -hllist -popup -tip -weeks
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
  set my::p(obj) [::apave::APave create APAVE_CLND $win]
  $my::p(obj) makeWindow $win.fra $title
  $my::p(obj) paveWindow $win.fra [list \
    {*}[my::MainWidgets] \
    {seh fra T 1 7 {-pady 0}} \
    {fraBottom seh T 1 7 {-st ew -pady 1}} \
    {fraBottom.h_ - - - - {pack -fill both -expand 1 -side left} {}} \
    {fraBottom.ButOK - - - - {pack -side left} {-t OK -com ::klnd::my::PickDay}} \
    {fraBottom.ButClose - - - - {pack -side left} {-t "$my::Close" -com "$my::p(obj) res $win 0"}} \
  ]
  unset -nocomplain ::klnd::TMPTIP
  unset -nocomplain ::klnd::TMPPACKW
  # binds for day buttons and 'Close'
  foreach {ev prc} { <Home> "::klnd::my::GoYear -1 yes" <End> "::klnd::my::GoYear 1 yes" \
  <Prior> "::klnd::my::GoMonth -1 yes" <Next> "::klnd::my::GoMonth 1 yes"} {
    for {set i 1} {$i<38} {incr i} {
      set but [$my::p(obj) BuT_KLNDSTD$i]
      bind $but $ev $prc
      bind $but <FocusIn> "::klnd::my::Enter $i"
      bind $but <Button-1> "::klnd::my::Enter $i 0 {-code break}"
      bind $but <KeyPress> "::klnd::my::KeyPress $i %K %s"
      bind $but <Double-1> "::klnd::my::PickDay $i {-code break}"
    }
    catch {bind [$my::p(obj) ButClose] $ev $prc}
  }
  bind $win <F3> ::klnd::my::SetCurrentDay
  bind $win <KeyPress> "::klnd::my::Leave"
  set bok [$my::p(obj) ButOK]
  bind $bok <FocusIn> {::klnd::my::ChosenDay yes}
  bind $bok <FocusOut> "$bok configure -text OK"
  # show and work with the calendar
  after idle "::klnd::my::ShowMonth $my::p(m) $my::p(y) yes"
  set res [$my::p(obj) showModal $win -resizable no {*}$args {*}$geo]
  # get the result of the selection if any
  if {$res && $my::p(dvis)} {
    set res [my::ChosenDay]
    if {$tvar ne {}} {set $tvar $res}
  } else {
    set res {}
  }
  catch {$my::p(obj) destroy}
  catch {destroy $win}
  return $res
}

# _________________________________ EOF _________________________________ #
