
package ifneeded klnd 1.4 [list source [file join $dir klnd.tcl]]

# A short intro (for Ruff! docs generator:)

namespace eval ::klnd {
  set _ruff_preamble {

  The *klnd* package provides a calendar widget to use along with [apave](https://aplsimple.github.io/en/tcl/pave) package.

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
  - themeable (with ttk and apave themes)
  - may be a modal (by default) or non-modal window

  The calendar looks like this:

  <img src="https://aplsimple.github.io/en/tcl/pave/files/widgdat2.png" class="media" alt="">

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

  An example of using the calendar for *apave* layout:

      {dat1 labDat1 L 1 1 {} {-tvar ::N::dat1 -title {Date of the event} -dateformat %d.%m.%Y -weekday %w}}

  This example includes `-tvar` option meaning a variable name to hold the date.

  <hr>

  The calendar provides the hotkeys Left, Right, Up, Down, PageUp, PageDown, Home, End and F3 to navigate through days, months and years.

  The Enter / Space keys or Double-Click are used to pick a date.
  }
}

namespace eval ::klnd::my {
  variable _ruff_preamble {
    The `::klnd::my` namespace contains procedures for the "internal" usage by *klnd* package.

    All of them are upper-cased, in contrast with the UI procedures of `klnd` namespace.
  }
}
