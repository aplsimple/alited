# LAST CHANGES:


Version `1.0.4 (29 Sep'21)`

  - TODO  : save unit's position at any switching to another unit/file
            (except for navigating inside a text, but including mouse clicks)
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
