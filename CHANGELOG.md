# LAST CHANGES:


Version `1.0.6 (30 Nov'21)`

  - TODO  : BUGFIX: issues with e_menu & tools in Windows

  - BUGFIX: ctrl+tab at start (no switching tab yet)
  - BUGFIX: demo 2.Units 03:15 .. 04:18 - cursor position is 309.1 instead of 309.10
  - BUGFIX: treeview in sun-valley dark theme
  - BUGFIX: diff name normalized for Windows
  - BUGFIX: populating "Last visited" at changing unit name
  - BUGFIX: running e_menu & tools at cursor on quotes & braces
  - BUGFIX: rdbende themes' scrollbars as in forest theme: hide at need
  - NEW   : "Utils / Diff to LEFT/RIGHT tab" of e_menu
  - NEW   : ru.msg, ua.msg for klnd
  - CHANGE: app's icon
  - CHANGE: add space after completed command
  - CHANGE: "Check Tcl" window be non-modal topmost
  - CHANGE: unit's cursor position saved at every Left-click (in current unit too)
  - CHANGE: use Pref's "ignore dirs" for projects (al(prjdirign))
  - CHANGE: "ignore dirs" option of projects moved to Project/Options
  - CHANGE: warning of Pref/General/Projects when defining Project/Options
  - CHANGE: ru.msg, ua.msg
  - CHANGE: apave package


Version `1.0.5 (27 Oct'21)`

  - BUGFIX: default/classic/alt theme & dark CS: selected check/radio buttons' bg
  - BUGFIX: demo 1.Start   ~01:10 : 'All #1 1-0' in tip of 'Row', if 'No name'
  - BUGFIX: demo 3.Project ~10:00 : not see for a current proc
  - BUGFIX: switching (popup menu) from file to unit tree if the latter is one line
  - BUGFIX: no updating icons at "Replace all in session"
  - BUGFIX: no updating file tree at opening files from 'File / Open'
  - BUGFIX: pressing Enter if current & next lines begin with *, -, #
  - BUGFIX: false movings in the tree (no Ctrl+click, just click & move)
  - BUGFIX: false saving modified files at "Tcl/Tk help"
  - BUGFIX: error at closing big files
  - BUGFIX: sort order at "Open all Tcl files..."
  - NEW   : more integrated with tclkits
  - NEW   : ua.msg
  - NEW   : "Open Selected File(s)" in tree's menu
  - NEW   : flags for "Preferable Locale"
  - NEW   : "Rename file" from the tree
  - NEW   : selected units to be added to Favorites (popup menu)
  - NEW   : "Don't ask again" checkbox at adding to Favorites
  - NEW   : "Your commands" for Tcl syntax
  - NEW   : "Remove" of "Last Visited" removes a current unit from the list
  - CHANGE: revised help & doc
  - CHANGE: combobox for "Find Unit" (saved list)
  - CHANGE: save/restore unit's position and last visited units at
            switching unit/file, text change, mouse click (when unit tree is active)
  - CHANGE: demo 2.Units
  - CHANGE: faster switching tabs
  - CHANGE: faster opening 'Preferences'
  - CHANGE: faster opening a file from the file tree
  - CHANGE: faster opening 'All Tcl Files' from the file tree
  - CHANGE: hl_tcl, apave, e_menu packages


Version `1.0.4 (29 Sep'21)`

  - BUGFIX: command autocompletion at 1st column failed
  - BUGFIX: e_menu could fail due to font2's multiple words
  - BUGFIX: Default buttons of Preferences didn't update colors properly
  - BUGFIX: clicking "Row/Files" cell of tree to select an item
  - BUGFIX: marking tabs as modified at "Replace in session"
  - BUGFIX: creating files from the file tree
  - BUGFIX: creating file tree at switching to other project
  - BUGFIX: undo cleared text of "notes" (projects, preferences)
  - BUGFIX: after restarting, open new instance at repeated start
  - BUGFIX: favors/last-visited at switching to other project
  - BUGFIX: issues at external modification/deletion of files
  - BUGFIX: false movings in unit tree at Ctrl/Shift+click
  - NEW   : a mark nearby a selected notebook of Preferences
  - NEW   : run alited with file name(s) as argument(s)
  - NEW   : run alited by tclkit
  - NEW   : open multiple files in File/Open
  - NEW   : go to a matched bracket
  - NEW   : Preferences/Tools/Common incl. path to tclsh/wish/tclkit (combobox)
  - NEW   : "auto detection of indenting" option in Projects/Options
  - NEW   : "All of..." and "Lines..." not saved in last visits
  - NEW   : Edit menu splitted to Edit and Search
  - NEW   : edit.tcl, with some procs from unit.tcl
  - NEW   : "Find by List" in Find menu
  - NEW   : switches instead of some checkbuttons (for rdbende themes)
  - NEW   : %F wildcard (full file name) for templates
  - NEW   : warning on "Open all Tcl files..."
  - NEW   : "Drop selected units/files here" to move a group of units/files
  - NEW   : selecting a directory after its creation in file tree
  - CHANGE: current tab's position restored at switching projects
  - CHANGE: rearranging toolbar
  - CHANGE: faster "find/replace in session"
  - CHANGE: indent normalizing applies "autodetected" indent
  - CHANGE: (un)indented blank lines become ""
  - CHANGE: theme chooser: light/dark list separated
  - CHANGE: rdbende themes revised heavily
  - CHANGE: minimal borderwidth of menus for rdbende themes
  - CHANGE: "Save as" instead of "Save" at deleting file by external app
  - CHANGE: autodetection of EOL at reading files
  - CHANGE: clrpick.tcl (smooth opening)
  - CHANGE: check for Tcl & C extensions at opening files
  - CHANGE: undo/redo's separators
  - CHANGE: by default, auto detection of indentation = yes
  - CHANGE: "- alited" removed from window title
  - CHANGE: grep.mnu items stay till closing
  - CHANGE: smoother recreating the file tree (not opening all directories)
  - CHANGE: smoother moving the units/files
  - CHANGE: 6 demo.mp4 releases
  - CHANGE: e_menu, apave, bartabs, hl_tcl, aloupe packages


Version `1.0.3 (25 Aug'21)`

  - BUGFIX: the tree updated at saving a file
  - BUGFIX: "modified" flag at changing big files
  - BUGFIX: needless reading of files at find/replace in session
  - BUGFIX: updating unit trees at find/replace in session
  - BUGFIX: eol & indent of projects
  - BUGFIX: MOST NASTY BUG: doinit to reread a modified file
  - NEW   : ttk themes in Preferences
  - NEW   : project defaults in Setup/Common
  - NEW   : logging in DEVELOP mode
  - NEW   : colorized color pickers in Preferences
  - NEW   : color/date picker replaces a current/selected word
  - NEW   : selection in unit tree at switching trees & tabs
  - NEW   : colors of tree from Tcl syntax (clrCOMTK, clrSTR) in Preferences
  - NEW   : setting default font in Preferences
  - NEW   : setting locale in Preferences
  - NEW   : demo 6.Themes-1.0.3.mp4 in github's releases
  - CHANGE: "Default" instead of "Color schemes" in CS list
  - CHANGE: color schemes revised
  - CHANGE: at file tree, faster switching tabs
  - CHANGE: background color of "Check Tcl" dialogue
  - CHANGE: backup of original and changed versions
  - CHANGE: REs to check for units
  - CHANGE: apave, e_menu, bartabs, hl_tcl, baltip packages


Version `1.0.2.1 (12 Aug'21)`

  - BUGFIX: OpenFile has to be called from favorites/last visits with reload=yes
  - BUGFIX: save/restore unit's cursor position at switching tabs
  - CHANGE: lesser width of "Favorites' lists" dialogue


Version `1.0.2 (11 Aug'21)`

  - BUGFIX: "Differences" for maximum of backups > 1
  - BUGFIX: saving / restoring cursor position in units (for current file only)
  - BUGFIX: reloading file at external changes
  - BUGFIX: cursor width at switching tabs
  - NEW   : "Cursor width" option
  - NEW   : "Remove all of the last visited"
  - NEW   : Ctrl+Tab for invisible tab of initially open (and only) file
  - NEW   : Alt+Backspace to switch between units
  - NEW   : demo 2.Units_alited-1.0.2.mp4 in github's releases


Version `1.0.1 (4 Aug'21)`

  - BUGFIX: a list of last visited
  - BUGFIX: killing 'Runme' by non-Runme item
  - BUGFIX: tips of treeviews
  - NEW   : "maximum of backups" in Preferences/General/Saving
  - NEW   : "before run" list cleared for a new project
  - NEW   : date picker
  - NEW   : index.html (alited docs)
  - NEW   : CHANGELOG.md
  - CHANGE: favorites' icons
  - CHANGE: apave, e_menu, hl_tcl, bartabs packages
  - CHANGE: README.md
