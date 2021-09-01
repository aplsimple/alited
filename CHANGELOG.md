# Last changes:


Version `1.0.4 (1 Sep'21)`

  - NEW   : run alited with file name(s) as argument(s)
  - NEW   : open multiple files in File/Open
  - NEW   : go to a matched bracket
  - NEW   : Preferences/Tools/Common incl. path to tclsh/wish/tclkit
  - NEW   : "auto detection of indenting" option in Projects/Options
  - NEW   : "All of..." and "Lines..." not saved in last visits
  - NEW   : Edit menu splitted to Edit and Search
  - NEW   : edit.tcl, with some procs from unit.tcl
  - NEW   : "Find by List" in Find menu
  - NEW   : switches instead some checkbuttons (for themes by rdbende)
  - CHANGE: azure, forest and sun-valley themes revised heavily
  - CHANGE: "Save as" instead "Save" at deleting file by external app
  - CHANGE: autodetection of EOL at reading files
  - CHANGE: clrpick.tcl (smooth opening)
  - CHANGE: ForestDark CS modified
  - CHANGE: apave package


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
