
package ifneeded klnd 1.4 " \
  source [file join $dir klnd.tcl] ;\
  source [file join $dir klnd2.tcl] \
  "

# A short intro (for Ruff! docs generator:)

namespace eval ::klnd {
  set _ruff_preamble {

  The *klnd* package provides a calendar widget to use along with [apave](../pave/index.html) package.

  Features:

  - displays localized days' and months' names
  - gets a chosen day through `-value` or `-tvar` (variable name) option
  - uses arrow keys to navigate through days, months and years
  - provides hot keys to navigate through months and years
  - provides buttons to navigate through months and years
  - provides a button and a hot key to set a current date
  - buttons' tips
  - shown at +X+Y coordinates / under a widget / in a parent's center / in a screen's center or under the mouse pointer
  - customizable title, date format, first week day (Sunday/Monday)
  - themeable (with ttk and [apave](../pave/index.html) themes)
  - may be a modal (by default) or non-modal window

  The calendar looks like this:

  <img src="../pave/files/widgdat2.png" class="media" alt="">

  <hr>

  To directly call the calendar, use the following commands:

      package require klnd
      klnd::calendar ?-option value ... ?

      # or this way
      source [file join $::apave::apaveDir pickers klnd klnd.tcl]
      klnd::calendar ?-option value ... ?

  where `option` may be:

    -value - sets an input date (omittable)
    -tvar - sets a variable name to hold the input/output value (omittable)
    -dateformat - sets the input/output date format (%D by default)
    -weekday - sets a first week day: %w for Sunday, %u for Monday (default)
    -modal - `yes` if the calendar should be a modal window (default)
    -title - sets the calendar's title
    -geometry - sets the calendar's geometry
    -entry - sets a widget's path to show the calendar under
    -parent - sets a parent toplevel window to center the calendar in
    -centerme - `yes` if the calendar should be centered in the screen

  If `-value` and `-tvar` options are both set, the `-tvar` is preferred. If both omitted, a current system date is used as input.

  The calendar returns a chosen date (setting also the `-tvar` variable if any) or "" at no choice.

  The priority of geometry options: `-geometry, -entry, -parent, -centerme`. At no geometry option given, the calendar is shown under the mouse pointer.

  The `-parent` option may be used along with `-geometry, -entry`, as it allows a child window to inherit the parent's attributes.

  <hr>

  The calendar provides the hotkeys Left, Right, Up, Down, PageUp, PageDown, Home, End and F3 to navigate through days, months and years.

  The Enter / Space keys or Double-Click are used to pick a date.

## Usage in apave package

  With [apave](../pave/index.html) package, the calendar can be used in two forms: <em>date picker</em> and <em>embedded calendar</em>:

   * <em>date picker</em> presents an entry field to hold an input/output date and a button to choose a date from the picker

   * <em>embedded calendar</em> presents a full set of widgets to display a selected month of year

  An example of using <em>date picker</em> for [apave](../pave/index.html) layout:

      {dat1 labDat1 L 1 1 {} {-tvar ::N::dat1 -title {Date of the event} -dateformat %d.%m.%Y -weekday %w}}

  This example includes `-tvar` option meaning a variable name to hold the date.

The <em>embedded calendar</em> differs from this with `daT` type of widget used instead of `dat`. Also, this form of calendar doesn't allow using the keyboard; only the mouse is used in it.

  The below example is taken from [alited](../alited/index.html)'s source:

      {.daT - - - - {pack -fill both} {-tvar alited::project::klnddata(date) -com {alited::project::KlndUpdate} -dateformat $alited::project::klnddata(dateformat) -tip {alited::project::KlndTip %W %D}}}

  This example includes `-com` option to run a command at clicking a day. This command can use `::klnd::update` to highlight some days in the calendar. In [alited](../alited/index.html) these days contain  reminders of TODOs being dead-lines.

  Options of embedded calendar:

   -com, -command - a command to run at left-click
   -popup - a command to run at right-click
   -currentmonth - a current month to display, in form of "year/month"
   -united - if yes, means "united" calendars
   -daylist - a list of selected days for "united" calendars
   -hllist - a list of highlighted days
   -tip - a command to get a day's tip

A command of `-com, -command, -popup` options can use wildcards: %y, %m, %d for year, month, day, %X, %Y for mouse pointer's coordinates.

A command of `-tip` option can use wildcards: %W for a day widget's path, %D for a day.

  UI procedures of embedded calendar:

   ::klnd::labelPath - gets a title label's path, to change its attributes
   ::klnd::selectedDay - gets a selected day
   ::klnd::getDaylist - gets a list of selected days (for united calendars)
   ::klnd::update - redraws a calendar for a month

  The procedures use `obj` argument, which is just an index of a calendar (beginning with 1). If omitted or equal to {}, `obj` means a last created calendar.

  The multiple embedded calendars may be united with `-united yes` option, so that a user can select a list of days inside them.
  }
}

namespace eval ::klnd::my {
  variable _ruff_preamble {
    The `::klnd::my` namespace contains procedures for the "internal" usage by *klnd* package.

    All of them are upper-cased, in contrast with the UI procedures of `klnd` namespace.
  }
}
