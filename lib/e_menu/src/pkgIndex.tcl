package ifneeded apave 3.4.12 [list source [file join $dir apaveinput.tcl]]

# A short intro (for Ruff! docs generator:)

namespace eval apave {

  set _ruff_preamble {

  The *apave* software provides a sort of geometry manager for Tcl/Tk.

  The *apave* isn't designed to replace the existing Tk geometry managers (place, pack, grid). Rather the apave tries to simplify the window layout by using their best, by means of:

   - joining the power of grid and pack
   - uniting a creation of widgets with their layout (and mostly their configuration)
   - minimizing a coder's efforts at creating / modifying / removing widgets
   - setting a natural tab order of widgets
   - providing 'mega-widgets'
   - providing 'mega-attributes', right up to the user-defined ones
   - centralizing things like icons or popup menus
   - theming both ttk and non-ttk widgets

  The *apave* is implemented as *APave oo::class*, so that you can enhance it with your own inherited / mixin-ed class.

  While *APave oo::class* allows to layout highly sophisticated windows, you can also employ its more 'earthy' descendants:

  *APaveDialog oo::class* and *APaveInput oo::class* that allow you:

   - to call a variety of dialogs, optionally using a "Don't show again" checkbox and a tagged text
   - to use a variety of widgets in dialogs, with entry, text (incl. readonly and stand-alone), combobox (incl. file content), spinbox, listbox, file listbox, option cascade, tablelist, checkbutton, radiobutton and label (incl. title)
   - to resize windows neatly (however strange, not done in Tk standard dialogs)

  The theming facility of *apave* is enabled by *ObjectTheming oo::class* which embraces both ttk and non-ttk widgets.

  Along with standard widgets, the mentioned *apave* classes provide a batch of following 'mega-widgets':

   - file picker
   - saved file picker
   - directory picker
   - font picker
   - color picker
   - date picker
   - menubar
   - toolbar
   - statusbar
   - file combobox
   - file listbox
   - file viewer/editor
   - option cascade
   - e_menu
   - bartabs
   - link
   - baltip
   - gutter
   - scrolled frame
   - switch

  At last, a CLI stand-alone dialog allows not only to ask "OK/Cancel" or "Yes/No" returning 1/0 but also to set environment variables to use in shell scripts.

  The **apave** originates from the old **pave** package, to comply with [How to build good packages](https://wiki.tcl-lang.org/page/How+to+build+good+packages) ("avoid simple, obvious names for your namespace").

  Let it be a sort of **a-pave**.

  The details are in [Description](https://aplsimple.github.io/en/tcl/pave).

  }

}
