# LAST CHANGES:


Version `1.3.5b21 (10 Nov'22)`

  - BUGFIX: (esp. for Windows) checks for spaces in "config dir" & "file name"
  - BUGFIX: (esp. for Windows) Alt+F4 for exit only
  - BUGFIX: dismissing "internal" e_menu, at least temporarily
  - BUGFIX: correct colors of cursor & selection for code snippets in Preferences
  - BUGFIX: selected text for "Run Tcl" of menu.mnu
  - BUGFIX: flowing column widths of the tree
  - BUGFIX: erroneous combination CS=-1 & Tint!=0
  - NEW   : -expand option of bartabs = 9 for "smart expanding the tabs"
  - NEW   : Preferences: Windows' themes (in Windows), tabbar's border, 1st widget focused
  - NEW   : sorted and tear-offed file list
  - NEW   : update menus & templates (if touched) at updating alited's version
  - NEW   : fossil.mnu: 'fossil timeline --showfiles' allows to filter file/dirs
  - NEW   : highlight strings found by "Find by List" dialogue while it's open
  - NEW   : "Find Next" and F3 for occurences found by "Find by List" dialogue
  - NEW   : Projects: new TODO buttons; changed tips; popup menu for days
  - NEW   : helps for: "Find by List", "Find/Replace" (F1), "Go to Line" (F1)
  - NEW   : save position of "Find by List" dialogue
  - NEW   : checkbox "Use this geometry of the dialogue by default" in Find/Replace
  - NEW   : Ctrl/Shift at clicking the unit tree: multiple selections,
            which are used to: cut & copy, comment & uncomment, doctest
  - NEW   : comment-out with TODO comments: to see / to find / to do them afterwards
  - NEW   : "Pause" option for Screen Loop tool
  - NEW   : "Rename" action for favorites' list
  - NEW   : balloons at opening non-existing files (Recent files, e_menu/Edit)
  - NEW   : at deleting units/files: close to mouse pointer, don't ask anymore
  - NEW   : "Tests" menu: doctest text's selection, doctest's help, save item's index
  - NEW   : alited's installers for Linux/Windows 32/64 bit
  - NEW   : at start, show balloon of outdated TODO (instead of Projects)
  - NEW   : enhanced list of Linux terminals
  - NEW   : fill Preferences/Tools/tclsh if it's empty (for Windows console mainly)
  - NEW   : choose file button for forced command of "Setup/For Run" dialogue
  - NEW   : use tc= option of e_menu to run Tcl code
  - CHANGE: at 1st exposition, center e_menu approximately
  - CHANGE: highlightbackground for main toolbar buttons + overrelief (esp. for Windows)
  - CHANGE: saving alited's settings at changing templates & favorites' lists
  - CHANGE: "-resizable no" and other geometry things
  - CHANGE: for Windows: default Tkcon as Preferences/Tools/Run
  - CHANGE: save choice of Run query called with F5 key
  - CHANGE: only 1st line of text selection as s= option of e_menu
  - CHANGE: display tips for favorites and menu file lists at right side of pointer
  - CHANGE: checks for outward changes disabled at saving files
  - CHANGE: alited docs
  - CHANGE: packages: apave/e_menu 3.6.0, bartabs 1.5.9, baltip 1.5.1, hl_tcl 0.9.44


Version `1.3.4 (21 Sep'22)`

  - NEW   : "Setup / Tips on/off" to disable some tips
  - NEW   : "-tearoff 1" for all submenus, to use them repeatedly
  - NEW   : delete non-existing file from "Recent Files" if chosen
  - NEW   : clicking message label in Projects (restoring the message and TODO)
  - NEW   : date picker in toolbar
  - NEW   : Find/Replace dialogue: F3 key = Find button
  - NEW   : "Sort" item in tab bar's menu
  - CHANGE: save/restore e_menu's ("internal") geometry for Preferences' cancel
  - CHANGE: OutwardChange called just after saving files to avoid probable issue
  - CHANGE: undo/redo of (un)commenting in one step
  - CHANGE: delete Item# labels in Preferences/Tools/bar/menu tab
  - CHANGE: demos: "6.Themes" for dark & light bg
  - CHANGE: packages: apave/e_menu 3.5.5, baltip 1.4.1, bartabs 1.5.8


Version `1.3.3 (3 Sep'22)`

  - BUGFIX: (not critical) saving files after "Save" in Preferences -> Tcl error
  - BUGFIX: (not critical) calling e_menu as external with alited's CS tinted (CS=47)
  - BUGFIX: (not critical) in Projects: default project's dir is empty at first start
  - BUGFIX: (not critical) focus a text at add/rename/delete files from the file tree
  - NEW   : delete selected files in file tree
  - NEW   : Comment/Uncomment: escaping/unescaping braces with #\{ #\} patterns
  - NEW   : Comment/Uncomment: selecting the changed lines
  - NEW   : Projects: "Create project by template" and "Project directory" buttons
  - NEW   : Projects: "Templates" tab to set a template of project file tree
  - NEW   : Projects: check for outdated TODOs of *all projects* at starting / opening
  - NEW   : bindings F2, Ctrl+S etc. for "info" listbox, "find units" combobox and tree
  - NEW   : allow tinting CS for rdbende's themes
  - NEW   : highlight current & original tints in "Setup/Tint" menu
  - NEW   : restoring full geometry of dir/file choosers in Linux
  - CHANGE: index.html (alited docs) revised
  - CHANGE: focusing a current text after "Open all Tcl files" of file tree
  - CHANGE: in Projects: focusing appropriate fields at user's errors
  - CHANGE: scrollbars for Preferences/Editor syntax fields
  - CHANGE: remove "File/Restart" menu item (made for testing only)
  - CHANGE: in Preferences - okcancel for Save button
  - CHANGE: docs: on Tcl/Tk 8.7 help
  - CHANGE: themes: azure, forest, sunvalley
  - CHANGE: insure against double-clicks of some icons
  - CHANGE: use normalized file names at filling the file lists of alited.ini
  - CHANGE: theming Projects file list's popup menu
  - CHANGE: tips of unit tree with TODOs
  - CHANGE: check and fix widths of tree's columns (they can overlap the scrollbar)
  - CHANGE: allow to run *in console* "forced command" for "%f ..." pattern
  - CHANGE: update GUI after "Projects" dialogue's closing, anyway
  - CHANGE: About / Acknowledgements
  - CHANGE: packages: apave/e_menu 3.5.4, hl_tcl 0.9.42


Version `1.3.0 (27 Jul'22)`

  - BUGFIX: at start, forget alited's own packages & namespaces
            (big-bug making alited unusable in some Magicsplat & Bawt distros)
  - BUGFIX: Preferences/Editor: don't touch snippets' bg color at choosing colors
  - BUGFIX: update "Save all" icon at removing trail spaces & "Replace in Session"
  - BUGFIX: choose e_menu items in Preferences, when set ornament (o=1) in menu.mnu
  - BUGFIX: switch projects at running alited in tkcon (skip ini::SaveCurrentIni)
  - BUGFIX: e_menu: corrected (for Windows, esp. XP), incl. test*.mnu
  - BUGFIX: e_menu: selected text as a code snippet for "Run Tcl {all selection}" item
  - BUGFIX: check for file modifications when "internal" e_menu opens a submenu
  - BUGFIX: check for existing menu of "internal" e_menu at running tools
  - BUGFIX: customized hotkeys in tooltips of tool icons
  - NEW   : "Setup/Before Run": a "forced command" to run by "Run" tool
            in console (or in Tkcon if the command begins with %f or file.tcl)
  - NEW   : tag the unit tree items with red color for TODO comments (#!...todo...),
            these TODOs being in tooltips of the tree
  - NEW   : "Move TODO to day/week" buttons in "Projects..."
  - NEW   : MS cmd.exe & powershell.exe as choices for MS shell
  - NEW   : let ~/.config be default, last config directory be saved in last.ini
  - NEW   : "Setup/Configurations..." to switch configs
  - NEW   : "Configurations..." has combobox of configs, "Clear" of popup menu, "Help"
  - NEW   : tooltips: statusbar message; Preferences themes/CS; rename-file button;
            "Tools/Run" menu item & "Run" icon (on forced run)
  - NEW   : warning at EXEC/SHELL of e_menu
  - NEW   : "Help" button / F1 in "Setup / After Start (Before Run)"
  - NEW   : between sessions, save/restore "Wrap lines" mode for files of projects
  - NEW   : Default & Test buttons in Preferences/Tools/e_menu
  - NEW   : About / Packages
  - NEW   : "Don't show anymore" checkbutton for Open... multiple files & Open all Tcl
  - NEW   : "Setup/Favorites...": "Current favorites" button added
  - NEW   : doubleclick on Projects' file list to open a file (was declared, not done)
  - CHANGE: "save" icon instead of "heart" for saved lists of favorites
  - CHANGE: tips of the tree are X-shifted relative to the mouse pointer (better view)
  - CHANGE: #RUNF: and #EXEC: comments may be used along with old #RUNF1:, #EXEC2:
  - CHANGE: "Preferences/Tools/Diff tool" to compare left & right tabs (in utils.mnu)
  - CHANGE: font size in "external" e_menu is "middle" of Preferences/General
  - CHANGE: save geometry of main menu of "internal" e_menu, ignoring other menus
  - CHANGE: "Setup/Favorites...": "Back" button: come-back to project's initial favs
  - CHANGE: queries for Favorites/LastVisits popup menu items be close to mouse pointer
  - CHANGE: switch to Favorites at choosing "Setup/Favorites..."
  - CHANGE: killing Tcl-runs corrected
  - CHANGE: e_menu: a hot key (F4) for "Run me" item
  - CHANGE: "Lists of Favorites" dialogue's appearance
  - CHANGE: remove README of alited's own packages
  - CHANGE: check info+statusbar height: must be >50 for the layout being viable
  - CHANGE: "Find all in session": no excessive reading of all texts after "Find unit"
  - CHANGE: edit::RemoveTrailWhites: TID vs wtxtcurr (no reading of all texts)
  - CHANGE: raise existing alited app: Linux / Windows own way
  - CHANGE: create Preferences/Tools/e_menu tab (if not current) with a delay
  - CHANGE: Preferences/Tools/Run replaces "Tkcon topmost" ("in console" by default)
  - CHANGE: tips and docs corrected (country/language in locale)
  - CHANGE: About / Acknowledgements & docs
  - CHANGE: packages: apave/e_menu 3.5, bartabs 1.5.7, hl_tcl 0.9.41, baltip 1.4.0


Version `1.2.3 (8 Jun'22)`

  - BUGFIX: doctest of tests.mnu failed with vanillawish taking -v argument
  - BUGFIX: at 1st start, issues with choosing non-default config directory
  - BUGFIX: switch projects with no file or with "No name" tab
  - BUGFIX: not save "No name" of project's file list
  - BUGFIX: clear messages in status bar of Projects
  - BUGFIX: check for duplicate icons of tools
  - BUGFIX: Projects dialogue after deploying alited 1st time (vars not existing)
  - BUGFIX: evaluation of Tcl commands of "Setup / After Start (Before Run)"
  - BUGFIX: switch projects with files unsaved
  - NEW   : display numbers of selected tabs (at Ctrl+click etc.)
  - NEW   : catch errors of alited's settings
  - NEW   : e_menu's "3. Edit/create file" edits "file name" of text selection
  - NEW   : error message at passing a non-existing file name to alited
  - NEW   : status bar: info on Run; detailed tooltip
  - NEW   : "Default" & "Default 2" buttons of Preferences/Tools/tkcon; new colors
  - NEW   : "New" and "Open..." items in popup menu of tab bar
  - NEW   : checkbutton "Don't ask anymore" at closing unsaved files
  - NEW   : checkbutton "Do it in other Tcl files" at asking "Correct indentation"
  - NEW   : checkbutton "Do it in other files" at asking "Remove trailing whitespaces"
  - NEW   : in List of Templates: "Import templates" button; tiny-ups
  - NEW   : new templates in alited.ini (view variables; enter a command)
  - NEW   : look for a declaration (Ctrl+L) - at first in the current tab
  - NEW   : "Tools / Run..." to choose console/tkcon to run Tcl code
  - NEW   : in Projects, clear project name and choose its dir -> make its name
  - NEW   : (customizable) F9 key to show a list of open files, at mouse pointer
  - NEW   : "Tools / File List" menu item
  - NEW   : hint on running in console/tkcon (in Preferences/Tools/tkcon)
  - CHANGE: Find/Replace: updated "In session" buttons at entering the dialogue
  - CHANGE: git.mnu, fossil.mnu (OK button focused), tests.mnu (DT* args)
  - CHANGE: Preferences/Saving: port to listen = 51807 by default
  - CHANGE: menu labels in Setup menu (Projects... etc.)
  - CHANGE: status bar's messages with bell - in red color
  - CHANGE: "Unit lines per 1 red bar": N lines of a unit considered normal; 4 minimum
  - CHANGE: 12 rows of list in "Templates"
  - CHANGE: check start of main::UpdateTextGutterTreeIcons & alited::Message
  - CHANGE: at 1st start, geometry of "Preferences", incl. minimal dimensions
  - CHANGE: enable Edit menu items ("Correct indentation" & "Remove trailing spaces")
  - CHANGE: Help window is made non-modal, to see the help & work together
  - CHANGE: "Tools / tkcon" and "Tools / e_menu/bar" exchanged seats
  - CHANGE: at closing a file by Ctrl+W, go to a previously viewed file
  - CHANGE: simplify checking keys to save last visits
  - CHANGE: tooltips of file list with (optional) file info
  - CHANGE: save dir chooser's geometry of choosing ~/.config (the very 1st dialogue)
  - CHANGE: apave, e_menu, bartabs, hl_tcl, baltip, doctest packages


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
  - CHANGE: helps for Preferences & Projects dialogues
  - CHANGE: About / Acknowledgements
  - CHANGE: apave, e_menu, hl_tcl, klnd packages


Version `1.2.0 (8 Mar'22)`

  - BUGFIX: issue with debug & log 'puts' at using tclkits
  - BUGFIX: in "Projects", switching to other project after changing a reminder
  - BUGFIX: in alited.tcl: mistaken FILEDIR variable; mistaken exec {*}; clearances
  - BUGFIX: close "Check Tcl" and "Find by List" at closing app
  - BUGFIX: at starting, message "The file %f seems to be not of types"
  - BUGFIX: pass alited (if open) a file name containing spaces
  - BUGFIX: "update" after selection from menu (some DEs need it)
  - BUGFIX: uk.msg instead of ua.msg
  - BUGFIX: "Run me" at setting e_menu as non-external app
  - BUGFIX: failed double click on a project list in "Projects" (annoying bug)
  - BUGFIX: text selection fg/bg at tinting
  - BUGFIX: issue with ignored dirs at using tclkits
  - NEW   : "Run me" runs tcl source in tkcon (with benefits of introspection)
  - NEW   : "Run me" runs tcl source in console, if "Preferences/Tools/Tkcon/Stay on top"
  - NEW   : restore selected texts at switching tabs
  - NEW   : pass dir&file choosers' geometry to "external" e_menu
  - NEW   : pass theme name to "external" e_menu
  - NEW   : "Setup/After Start" setting to run Tcl & external commands
  - NEW   : "Setup/Before Run" setting allows Tcl commands
  - CHANGE: required version of Tcl/Tk is 8.6.10+
  - CHANGE: tkcon.tcl modified for sourcing a Tcl/Tk script
  - CHANGE: tkcon's default settings modified
  - CHANGE: minsizes for Projects & Preferences set static
  - CHANGE: save "Setup/Before Run" setting in project.ale
  - CHANGE: run e_menu faster
  - CHANGE: statusbar font size = small font size of Preferences
  - CHANGE: "Comment/Uncomment" enabled for all
  - CHANGE: reminder's saves simplified
  - CHANGE: notes and reminders got a current line highlighted
  - CHANGE: html Tcl/Tk man pages allowed along with htm
  - CHANGE: e_menu's menus shown at position of Preference/Tools/e_menu/Geometry
  - CHANGE: apave, e_menu, hl_tcl packages


Version `1.1.0 (26 Jan'22)`

  - BUGFIX: Tab key (command completion) in kubuntu, reported and fixed by Steve
  - BUGFIX: save modified files by "Preferences/Save", reported by Steve
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
  - CHANGE: sort locale items in Preferences
  - CHANGE: "wait a little"'s red foreground
  - CHANGE: apave, hl_tcl, clrpick, e_menu packages


Version `1.0.6 (29 Dec'21)`

  - BUGFIX: update file tree after closing files (colors remain as if "open")
  - BUGFIX: issues with e_menu & tools in Windows (current file name for dialogues)
  - BUGFIX: "--" added for all exec
  - BUGFIX: Ctrl+Tab at start (no switching tab yet)
  - BUGFIX: demo 2.Units 03:15 .. 04:18 - cursor position is 309.1 instead of 309.10
  - BUGFIX: treeview in sun-valley dark theme
  - BUGFIX: diff name normalized for Windows
  - BUGFIX: populate "Last visited" at changing unit name
  - BUGFIX: run e_menu & tools at cursor on quotes & braces
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
  - CHANGE: source baltip.tcl rearranged
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
  - CHANGE: warn of Pref/General/Projects when defining Project/Options
  - CHANGE: ru.msg, ua.msg
  - CHANGE: apave, klnd, baltip, bartabs, hl_tcl, e_menu package


Version `1.0.5 (27 Oct'21)`

  - BUGFIX: default/classic/alt theme & dark CS: selected check/radio buttons' bg
  - BUGFIX: demo 1.Start   ~01:10 : 'All #1 1-0' in tip of 'Row', if 'No name'
  - BUGFIX: demo 3.Project ~10:00 : not see for a current proc
  - BUGFIX: switch (popup menu) from file to unit tree if the latter is one line
  - BUGFIX: no updating icons at "Replace all in session"
  - BUGFIX: no updating file tree at opening files from 'File / Open'
  - BUGFIX: press Enter if current & next lines begin with *, -, #
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
  - NEW   : "Don't ask again" checkbutton at adding to Favorites
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
  - BUGFIX: click "Row/Files" cell of tree to select an item
  - BUGFIX: mark tabs as modified at "Replace in session"
  - BUGFIX: create files from the file tree
  - BUGFIX: create file tree at switching to other project
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
  - NEW   : warn on "Open all Tcl files..."
  - NEW   : "Drop selected units/files here" to move a group of units/files
  - NEW   : select a directory after its creation in file tree
  - CHANGE: current tab's position restored at switching projects
  - CHANGE: rearrange toolbar
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
  - BUGFIX: update unit trees at find/replace in session
  - BUGFIX: eol & indent of projects
  - BUGFIX: MOST NASTY BUG: doinit to reread a modified file
  - NEW   : ttk themes in Preferences
  - NEW   : project defaults in Setup/Common
  - NEW   : log in DEVELOP mode
  - NEW   : colorized color pickers in Preferences
  - NEW   : color/date picker replaces a current/selected word
  - NEW   : selection in unit tree at switching trees & tabs
  - NEW   : colors of tree from Tcl syntax (clrCOMTK, clrSTR) in Preferences
  - NEW   : set default font in Preferences
  - NEW   : set locale in Preferences
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
  - BUGFIX: save / restore cursor position in units (for current file only)
  - BUGFIX: reload file at external changes
  - BUGFIX: cursor width at switching tabs
  - NEW   : "Cursor width" option
  - NEW   : "Remove all of the last visited"
  - NEW   : Ctrl+Tab for invisible tab of initially open (and only) file
  - NEW   : Alt+Backspace to switch between units
  - NEW   : demo 2.Units_alited-1.0.2.mp4 in github's releases


Version `1.0.1 (4 Aug'21)`

  - BUGFIX: a list of last visited
  - BUGFIX: kill 'Runme' by non-Runme item
  - BUGFIX: tips of treeviews
  - NEW   : "maximum of backups" in Preferences/General/Saving
  - NEW   : "before run" list cleared for a new project
  - NEW   : date picker
  - NEW   : index.html (alited docs)
  - NEW   : CHANGELOG.md
  - CHANGE: favorites' icons
  - CHANGE: apave, e_menu, hl_tcl, bartabs packages
  - CHANGE: README.md
