# LAST CHANGES:


Version `1.2.2 (4 May'22)`

  - BUGFIX: save TODO of Projects at "Undo changes"
  - BUGFIX: selection of unit/file tree at file operations
  - BUGFIX: default option values for projects (ignored dirs etc.)
  - BUGFIX: line numbers in the gutter
  - NEW   : "Edit / Remove Trailing Whitespaces" to trimright line/selection/text
  - NEW   : "Preferences / Projects / Remove trailing whitespaces" option (for all texts)
  - NEW   : "Projects / Options / Remove trailing whitespaces" option (for all texts)
  - CHANGE: set the current month if no blinking TODO in Projects
  - CHANGE: %D & %f wildcards filled in bar/menu icon tips & Tools/bar/menu items
  - CHANGE: additional checking to avoid duplicates in "Last Visited"
  - CHANGE: Preferences' code snippets: curr.line & TODO comment (#!..) colors
  - CHANGE: at completion, some commands need no adding a space
  - CHANGE: separator on the undo stack for trailing spaces removed
  - CHANGE: hl_tcl, klnd packages
  - CHANGE: helps for Preferences & Projects dialogues
  - CHANGE: About / Acknowledgements
  - CHANGE: apave, e_menu packages


Version `1.2.0 (8 Mar'22)`

  - BUGFIX: issue with debug & log 'puts' at using tclkits
  - BUGFIX: in "Projects", switching to other project after changing a reminder
  - BUGFIX: in alited.tcl: mistaken FILEDIR variable; mistaken exec {*}; clearances
  - BUGFIX: closing "Check Tcl" and "Find by List" at closing app
  - BUGFIX: at starting, message "The file %f seems to be not of types"
  - BUGFIX: passing alited (if open) a file name containing spaces
  - BUGFIX: "update" after selection from menu (some DEs need it)
  - BUGFIX: uk.msg instead of ua.msg
  - BUGFIX: "Run me" at setting e_menu as non-external app
  - BUGFIX: failed double click on a project list in "Projects" (annoying bug)
  - BUGFIX: text selection fg/bg at tinting
  - BUGFIX: issue with ignored dirs at using tclkits
  - NEW   : "Run me" runs tcl source in tkcon (with benefits of introspection)
  - NEW   : "Run me" runs tcl source in console, if "Preferences/Tools/Tkcon/Stay on top"
  - NEW   : restoring selected texts at switching tabs
  - NEW   : passing dir&file choosers' geometry to "external" e_menu
  - NEW   : passing theme name to "external" e_menu
  - NEW   : "Setup/After Start" setting to run Tcl & external commands
  - NEW   : "Setup/Before Run" setting allows Tcl commands
  - CHANGE: required version of Tcl/Tk is 8.6.10+
  - CHANGE: tkcon.tcl modified for sourcing a Tcl/Tk script
  - CHANGE: tkcon's default settings modified
  - CHANGE: minsizes for Projects & Preferences set static
  - CHANGE: saving "Setup/Before Run" setting in project.ale
  - CHANGE: running e_menu faster
  - CHANGE: statusbar font size = small font size of Preferences
  - CHANGE: "Comment/Uncomment" enabled for all
  - CHANGE: reminder's saves simplified
  - CHANGE: notes and reminders got a current line highlighted
  - CHANGE: html Tcl/Tk man pages allowed along with htm
  - CHANGE: e_menu's menus shown at position of Preference/Tools/e_menu/Geometry
  - CHANGE: apave, e_menu, hl_tcl packages


Version `1.1.0 (26 Jan'22)`

  - BUGFIX: Tab key (command completion) in kubuntu, reported and fixed by Steve
  - BUGFIX: saving modified files by "Preferences/Save", reported by Steve
  - BUGFIX: catch for lreplace (this commy) at saving ini
  - BUGFIX: command completion at column=1
  - BUGFIX: false last visit from infobar/find-declaration
  - BUGFIX: cancel Projects dialogue at a changed reminder
  - BUGFIX: bells at finding in session with empty "Find" field
  - BUGFIX: potential issue with switching last visit
  - NEW   : code snippets in "Tcl/C syntax" tabs
  - NEW   : 4 default buttons in "Tcl/C syntax" tabs
  - NEW   : check for Tab character in "Correct Indentation"
  - NEW   : e_menu's "own CS" option
  - NEW   : de.msg by Holger
  - NEW   : acknowledgements tab in About
  - NEW   : at completion: put unit's declaration; sort list; "wait a little"
  - CHANGE: "small restriction" gone: at changing Preferences' CS
  - CHANGE: "Find/Replace" dialogue's min.sizes made liberal
  - CHANGE: visited units' color of tree changed to proc/return color
  - CHANGE: indentation can be from 0 (spec. for "1 Tab" indents)
  - CHANGE: install defaults: emtt=x-terminal-emulator, emcs=-1
  - CHANGE: port to listen made customizable, as suggested by Holger
  - CHANGE: no scrollbar in "Complete Command" window
  - CHANGE: sorting locale items in Preferences
  - CHANGE: "wait a little"'s red foreground
  - CHANGE: apave, hl_tcl, clrpick, e_menu packages


Version `1.0.6 (29 Dec'21)`

  - BUGFIX: updating file tree after closing files (colors remain as if "open")
  - BUGFIX: issues with e_menu & tools in Windows (current file name for dialogues)
  - BUGFIX: "--" added for all exec
  - BUGFIX: Ctrl+Tab at start (no switching tab yet)
  - BUGFIX: demo 2.Units 03:15 .. 04:18 - cursor position is 309.1 instead of 309.10
  - BUGFIX: treeview in sun-valley dark theme
  - BUGFIX: diff name normalized for Windows
  - BUGFIX: populating "Last visited" at changing unit name
  - BUGFIX: running e_menu & tools at cursor on quotes & braces
  - BUGFIX: rdbende themes: scrollbars as in forest theme (hide at need)
  - BUGFIX: tree selection seen after file saves
  - BUGFIX: more time for gaining bar's width before calling FillBar
  - BUGFIX: o=-1 for e_menu calls (instead of old o=0)
  - BUGFIX: display redefined F3/Ctrl+D/Ctrl+Y in context menu
  - NEW   : "Plain texts' extensions" setting in "Preferences"
  - NEW   : combobox of "Linux terminal" setting
  - NEW   : horizontal scrollbar for texts with lines unwrapped
  - NEW   : check for consistency of "" in "Check Tcl"
  - NEW   : "Open/Close selected files" from context menu of Project's file list
  - NEW   : show introductions on some dialogues
  - NEW   : remind on events & TODOs (calendar's option in "Projects")
  - NEW   : call a list of templates from Preferences/Templates
  - NEW   : F1 in main dialogues for calling help
  - NEW   : run alited.tcl by tclsh/tclkit, alited.kit by tclkit
  - NEW   : info on the executable in "About"
  - NEW   : user's Tcl commands autocompleted
  - NEW   : "Check Tcl" for duplicates in the unit tree
  - NEW   : tips for tab list (full file names)
  - NEW   : "Utils / Diff to LEFT/RIGHT tab" of e_menu
  - NEW   : ru.msg, ua.msg for klnd
  - CHANGE: Project's file list sorted
  - CHANGE: [info nameofexecutable] for "Restart" & "About..."
  - CHANGE: .mnu corrected for Windows
  - CHANGE: "Differences" of menu.mnu includes choosing SCM
  - CHANGE: revised add/change/delete/select in "Projects"
  - CHANGE: toolbar rearranged (date removed, tkcon moved)
  - CHANGE: sourcing baltip.tcl rearranged
  - CHANGE: Ctrl+L corrected & message if not found
  - CHANGE: tooltips of treeviews from baltip (behaving properly at that)
  - CHANGE: get rid of package duplicates (apave, baltip)
  - CHANGE: at switching projects, strings to be only restored for "Find/Replace"
  - CHANGE: colors of tips for dark CS
  - CHANGE: rdbende themes: check/radio hovered; disabled colors; combobox relief
  - CHANGE: app's icon
  - CHANGE: add space after completed command
  - CHANGE: "Check Tcl" window be non-modal topmost
  - CHANGE: unit's cursor position saved at every Left-click (in current unit too)
  - CHANGE: use Pref's "ignore dirs" for projects (al(prjdirign))
  - CHANGE: "ignore dirs" option of projects moved to Project/Options
  - CHANGE: warning of Pref/General/Projects when defining Project/Options
  - CHANGE: ru.msg, ua.msg
  - CHANGE: apave, klnd, baltip, bartabs, hl_tcl, e_menu package


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
