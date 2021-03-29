
The *bartabs* package provides a bar widget containing tabs that are

  - scrollable
  - markable
  - moveable
  - closeable
  - disabled and enabled
  - static and changeable
  - selectable and multi-selectable
  - configureable
  - enhanceable with popup menu

The *bartabs* defines three TclOO classes:
  - *Tab* deals with tabs
  - *Bar* deals with a bar of tabs
  - *Bars* deals with bars of tabs

However, only the *Bars* class is used to create bars along with tabs. It can be also used to deal with any bars and tabs, providing all necessary interface.

The *Bar* does not create a real TclOO object, rather it provides *syntax sugar* for a convenient access to the bar methods.

The *Tab* does not create a real TclOO object as well. It serves actually for structuring *bartabs* code as for tab methods. Thus, its methods are accessible through the *Bars* ("real" TclOO) and *Bar* ("sugar") objects.

<hr>

A common work flow with *bartabs* looks like this:

Firstly, we create a *Bars* object, e.g.

 `bartabs::Bars create NS::bars`

Then we create a *Bar* object, e.g.

 `NS::bars create NS::bar $barOptions`

If a tab of the bar should be displayed (with its possible contents), we show the bar and select the current tab:

  `set TID [NS::bar tabID "tab label"]  ;# get the tab's ID by its label`

  `NS::bar $TID show  ;# show the bar and select the tab`

or just draw the bar without mind-breaking about a tab:

  `NS::bar draw  ;# show the bar without selecting a tab`

The rest actions include:

  - responses to a selection of tab (through `-csel command` option of *Bar* object)
  - responses to a deletion of tab (through `-cdel command` option of *Bar* object)
  - responses to a reorganization of bar (through `-cmov command` option of *Bar* object)
  - inserting and renaming tabs
  - disabling and enabling tabs
  - marking tabs with colors or icons
  - processing the marked tabs
  - processing multiple tabs selected with Ctrl+click
  - scrolling tabs to left/right through key bindings
  - calling other handlers through key bindings and *bartabs* menu
  - using `cget` and `configure` methods to change the bar/tab appearance
  - redrawing bars at some events
  - removing and creating as much bars as required

<hr>

The methods of *Tab* class are called from *Bars* or *Bar* object
 and are passed: *tab ID (TID), method name, arguments*. Syntax:

`OBJECT TID method arguments`

For example: `NS::bars $TID close` or `NS::bar $TID show false`

<hr>

The methods of *Bar* class are called from *Bar* object or (more wordy) from *Bars* object. Syntax:

`BAR_OBJECT method arguments`

`BARS_OBJECT BID method arguments`

For example: `NS::bar popList $X $Y` or `NS::bars $BID popList $X $Y`

<hr>

The methods of *Bars* class need no TID nor BID, though not protesting them passed before method name. Syntax:

`BARS_OBJECT method arguments`

For example:

`NS::bars drawAll        ;# good boy`

`NS::bars tab11 drawAll  ;# bad boy uses the useless tab11 (TID)`

`NS::bars bar1 drawAll   ;# bad boy's BID is useless as well`

<hr>

There are three "virtual" methods:

* `NS::bar create NS::tab $label` creates a tab object *NS::tab* for a tab labeled $label to access the tab methods, e.g. `NS::tab show`

* `NS::tab cget $option` gets an option of tab, e.g. `NS::tab cget -text`

* `NS::tab configure $option $value` sets an option of tab, e.g. `NS::tab configure -text "new label"`  

<hr>

Few words about *BID* and *TID* mentioned throughout the *bartabs*.

These are identifiers of bars and tabs, of form `bar<index>` and `tab<index>` where `<index>` is integer increased from 0 in order of bar/tab creation. The bars and the tabs of all bars have unique IDs.

You can use these literals freely, along with BIDs and TIDs gotten from *bartabs* methods. For example, if you know that "some tab" was created third, you can show it straightforward:

  `NS::bar tab2 show ;# show the 3rd tab (TID=tab2)`

instead of

  `NS::bar [NS::bar tabID "some tab"] show ;# find and show the tab by its name`

<hr>

Links:

[Documentation](https://aplsimple.github.io/en/tcl/bartabs)

[Reference on bartabs](https://aplsimple.github.io/en/tcl/bartabs/bartabs.html)

[Reference on baltip](https://aplsimple.github.io/en/tcl/baltip/baltip.html) (package used by *bartabs*)
