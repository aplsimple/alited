#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The list of alited's localized messages.
# _______________________________________________________________________ #

namespace eval ::alited {

  set al(MC,nofile)      [msgcat::mc "No name"]
  set al(MC,about)       [msgcat::mc "About"]
  set al(MC,error)       [msgcat::mc "Error"]
  set al(MC,warning)     [msgcat::mc "Warning"]
  set al(MC,question)    [msgcat::mc "Question"]
  set al(MC,info)        [msgcat::mc "Information"]
  set al(MC,wait)        [msgcat::mc "Wait a little ..."]
  set al(MC,help)        [msgcat::mc "Help"]
  set al(MC,mnufile)     [msgcat::mc "File"]
  set al(MC,mnuedit)     [msgcat::mc "Edit"]
  set al(MC,mnutools)    [msgcat::mc "Tools"]
  set al(MC,mnusetup)    [msgcat::mc "Setup"]
  set al(MC,mnuhelp)     [msgcat::mc "Help"]
  set al(MC,select)      [msgcat::mc "Select"]  ;# verb
  set al(MC,notsaved)    [msgcat::mc "\"%f\" wasn't saved.\n\nSave it?"]
  set al(MC,saving)      [msgcat::mc "Saving"]
  set al(MC,saveas)      [msgcat::mc "Save as"]
  set al(MC,files)       [msgcat::mc "Files"]
  set al(MC,moving)      [msgcat::mc "Moving"]
  set al(MC,run)         [msgcat::mc "Run"]
  set al(MC,new)         [msgcat::mc "New"]
  set al(MC,open...)     [msgcat::mc "Open..."]
  set al(MC,close)       [msgcat::mc "Close"]
  set al(MC,save)        [msgcat::mc "Save"]
  set al(MC,saveas...)   [msgcat::mc "Save as..."]
  set al(MC,saveall)     [msgcat::mc "Save All"]
  set al(MC,clall)       [msgcat::mc "... All"]
  set al(MC,clallleft)   [msgcat::mc "... All at Left"]
  set al(MC,clallright)  [msgcat::mc "... All at Right"]
  set al(MC,pref)        [msgcat::mc "Preferences"]
  set al(MC,pref...)     [msgcat::mc "Preferences..."]
  set al(MC,notrecomm)   [msgcat::mc "Not recommended!"]
  set al(MC,restart)     [msgcat::mc "Restart"]
  set al(MC,quit)        [msgcat::mc "Quit"]
  set al(MC,indent)      [msgcat::mc "Indent"]
  set al(MC,unindent)    [msgcat::mc "Unindent"]
  set al(MC,comment)     [msgcat::mc "Comment"]
  set al(MC,uncomment)   [msgcat::mc "Uncomment"]
  set al(MC,findreplace) [msgcat::mc "Find / Replace"]
  set al(MC,findnext)    [msgcat::mc "Find Next"]
  set al(MC,alloffile)   [msgcat::mc "All of \"%f\""]
  set al(MC,moveupU)     [msgcat::mc "Move Unit Up"]
  set al(MC,movedownU)   [msgcat::mc "Move Unit Down"]
  set al(MC,moveupF)     [msgcat::mc "Move File Up"]
  set al(MC,movedownF)   [msgcat::mc "Move File Down"]
  set al(MC,FavLists)    [msgcat::mc "Lists of Favorites"]
  set al(MC,swfiles)     [msgcat::mc "Switch to Unit Tree"]
  set al(MC,swunits)     [msgcat::mc "Switch to File Tree"]
  set al(MC,filesadd)    [msgcat::mc "Create File"]
  set al(MC,filesadd2)   [msgcat::mc "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' checkbox.\nThe directory can include subdirectories (a/b/c)."]
  set al(MC,filesdel)    [msgcat::mc "Delete File"]
  set al(MC,fileexist)   [msgcat::mc "File %f already exists in\n%d"]
  set al(MC,unitsadd)    [msgcat::mc "Add Unit by Template"]
  set al(MC,unitsdel)    [msgcat::mc "Remove Unit(s)"]
  set al(MC,favoradd)    [msgcat::mc "Add to Favorites"]
  set al(MC,favordel)    [msgcat::mc "Remove from Favorites"]
  set al(MC,updtree)     [msgcat::mc "Update Tree"]
  set al(MC,ctrtree)     [msgcat::mc "Contract All"]
  set al(MC,exptree)     [msgcat::mc "Expand All"]
  set al(MC,movefile)    [msgcat::mc "Move %f\nto\n%d\n?"]
  set al(MC,introln1)    [msgcat::mc "First Lines"]
  set al(MC,introln2)    [msgcat::mc "Can't touch the first %n lines."]
  set al(MC,favorites)   [msgcat::mc "Favorites"]
  set al(MC,lastvisit)   [msgcat::mc "Last Visited"]
  set al(MC,addfavor)    [msgcat::mc "Add \"%n\" of %f\nto the favorites?"]
  set al(MC,addexist)    [msgcat::mc "Item \"%n\" of %f\nis already in the favorites."]
  set al(MC,delfavor)    [msgcat::mc "Remove \"%n\" of %f\nfrom the favorites?"]
  set al(MC,selfavor)    [msgcat::mc "Click \"%t\""]
  set al(MC,copydecl)    [msgcat::mc "Copy Declaration"]
  set al(MC,openofdir)   [msgcat::mc "Open all Tcl files of \"%n\""]
  set al(MC,delitem)     [msgcat::mc "Remove \"%n\"\nfrom \"%f\"?"]
  set al(MC,delfile)     [msgcat::mc "Delete \"%f\"?"]
  set al(MC,nodelopen)   [msgcat::mc "An open file can not be deleted."]
  set al(MC,modiffile)   [msgcat::mc "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?"]
  set al(MC,wasdelfile)  [msgcat::mc "File \"%f\" was deleted by some application.\n\nSave the file?"]
  set al(MC,Row:)        [msgcat::mc "Row: "]
  set al(MC,Col:)        [msgcat::mc " Col: "]
  set al(MC,errmove)     [msgcat::mc "\"%n\" contains unbalanced \{\}: %1!=%2"]

  # messages for templates
  set al(MC,tpl)         [msgcat::mc "Templates"]
  set al(MC,tpl4)        [msgcat::mc "Current template:"]
  set al(MC,tpl5)        [msgcat::mc "New template:"]
  set al(MC,tplhd1)      [msgcat::mc "Template"]
  set al(MC,tplhd2)      [msgcat::mc "Hot keys"]
  set al(MC,tpladd)      [msgcat::mc "Add a template"]
  set al(MC,tplchg)      [msgcat::mc "Change a template"]
  set al(MC,tpldel)      [msgcat::mc "Delete a template"]
  set al(MC,tplsel)      [msgcat::mc "Click a template"]
  set al(MC,tplnew)      [msgcat::mc "The template #%n added"]
  set al(MC,tplupd)      [msgcat::mc "The template #%n updated"]
  set al(MC,tplrem)      [msgcat::mc "The template #%n removed"]
  set al(MC,tplent1)     [msgcat::mc "Enter a name of the template"]
  set al(MC,tplent2)     [msgcat::mc "Enter a text of the template"]
  set al(MC,tplcbx)      [msgcat::mc "Choose a hot key combination\nfor the template insertion."]
  set al(MC,tplexists)   [msgcat::mc "A template with the attribute(s) already exists."]
  set al(MC,tplloc)      [msgcat::mc "Place after:"]
  set al(MC,tplloc1)     [msgcat::mc "line"]
  set al(MC,tplloc2)     [msgcat::mc "unit"]
  set al(MC,tplloc3)     [msgcat::mc "cursor"]
  set al(MC,tplloc4)     [msgcat::mc "file's beginning"]
  set al(MC,tplttloc1)   [msgcat::mc "Inserts a template\nbelow a current line"]
  set al(MC,tplttloc2)   [msgcat::mc "Inserts a template\nbelow a current unit"]
  set al(MC,tplttloc3)   [msgcat::mc "Inserts a template at the cursor\n(good for one-liners)"]
  set al(MC,tplttloc4)   [msgcat::mc "Inserts a template after 1st line of a file\n(License, Introduction etc.)"]
  set al(MC,tpldelq)     [msgcat::mc "Delete a template #%n ?"]

  # messages for projects
  set al(MC,projects)    [msgcat::mc "Projects"]
  set al(MC,prjgoing)    [msgcat::mc "You are going to %n!"]
  set al(MC,prjadd)      [msgcat::mc "Add a project"]
  set al(MC,prjchg)      [msgcat::mc "Change a project"]
  set al(MC,prjdel)      [msgcat::mc "Delete a project"]
  set al(MC,prjcantdel)  [msgcat::mc "Don't delete the current project!"]
  set al(MC,prjnew)      [msgcat::mc "The project \"%n\" added"]
  set al(MC,prjupd)      [msgcat::mc "The project \"%n\" updated"]
  set al(MC,prjrem)      [msgcat::mc "The project \"%n\" removed"]
  set al(MC,prjOptions)  [msgcat::mc "Options"]
  set al(MC,prjName)     [msgcat::mc "Project name:"]
  set al(MC,prjsavfl)    [msgcat::mc "You can\n  - add the current one to\n  - substitute with the current one\n  - delete\n  - not change\nthe file list of the project.\n"]
  set al(MC,prjaddfl)    [msgcat::mc "Add"]
  set al(MC,prjsubstfl)  [msgcat::mc "Substitute"]
  set al(MC,prjdelfl)    [msgcat::mc "Delete"]
  set al(MC,prjnochfl)   [msgcat::mc "Don't change"]
  set al(MC,prjsel)      [msgcat::mc "Click a project"]
  set al(MC,prjdelq)     [msgcat::mc "Delete a project \"%n\" ?"]
  set al(MC,prjexists)   [msgcat::mc "A project \"%n\" already exists."]

  # messages for favorites
  set al(MC,fav3)        [msgcat::mc "Lists of favorites:"]
  set al(MC,fav4)        [msgcat::mc "Current list of favorites:"]
  set al(MC,fav5)        [msgcat::mc "New list of favorites:"]
  set al(MC,favadd)      [msgcat::mc "Add a list of favorites"]
  set al(MC,favchg)      [msgcat::mc "Change a list of favorites"]
  set al(MC,favdel)      [msgcat::mc "Delete a list of favorites"]
  set al(MC,favsel)      [msgcat::mc "Click a list of favorites"]
  set al(MC,favnew)      [msgcat::mc "The list #%n added"]
  set al(MC,favupd)      [msgcat::mc "The list #%n updated"]
  set al(MC,favrem)      [msgcat::mc "The list #%n removed"]
  set al(MC,favent1)     [msgcat::mc "Enter a name of the list"]
  set al(MC,favent2)     [msgcat::mc "Favorites of the current list"]
  set al(MC,favent3)     [msgcat::mc "The current list is empty!"]
  set al(MC,favexists)   [msgcat::mc "This list already exists"]
  set al(MC,faverrsav)   [msgcat::mc "This list not saved to\n\"%f\"."]
  set al(MC,favloc)      [msgcat::mc "Non-favorite files to be:"]
  set al(MC,favloc1)     [msgcat::mc "kept"]
  set al(MC,favloc2)     [msgcat::mc "closed"]
  set al(MC,favtip1)   [msgcat::mc "Doesn't close any tab without favorites\nat choosing the favorites' list"]
  set al(MC,favtip2)   [msgcat::mc "Closes all tabs without favorites\nat choosing the favorites' list"]
  set al(MC,favtip3)     [msgcat::mc "Sets a list of favorites\nthat was active initially."]
  set al(MC,favdelq)     [msgcat::mc "Delete a favorites' list #%n ?"]
  set al(MC,favinit)     [msgcat::mc "Back"]

# find-replace dialogue
  set al(MC,frfind)  [msgcat::mc "Find: "]
  set al(MC,frrepl)  [msgcat::mc "Replace: "]
  set al(MC,frmatch) [msgcat::mc "Match: "]
  set al(MC,frexact) [msgcat::mc "Exact"]
  set al(MC,frword)  [msgcat::mc "Match whole word only"]
  set al(MC,frcase)  [msgcat::mc "Match case"]
  set al(MC,frwrap)  [msgcat::mc "Wrap around"]
  set al(MC,frblnk)  [msgcat::mc "Replace by blank"]
  set al(MC,frdir)   [msgcat::mc "Direction:"]
  set al(MC,frdown)  [msgcat::mc "Down"]
  set al(MC,frup)    [msgcat::mc "Up"]
  set al(MC,frontop) [msgcat::mc "Stay on top"]
  set al(MC,frfind1) [msgcat::mc "Find"]
  set al(MC,frrepl1) [msgcat::mc "Replace"]
  set al(MC,frfind2) [msgcat::mc "All in Text"]
  set al(MC,frtip1)  [msgcat::mc "Allows to use *, ?, \[ and \]\nin \"find\" string."]
  set al(MC,frtip2)  [msgcat::mc "Allows to use the regular expressions\nin \"find\" string."]
  set al(MC,frtip3)  [msgcat::mc "Allows replacements by the empty string,\nin fact, to erase the found ones."]
  set al(MC,frtip4)  [msgcat::mc "Keeps the dialogue above other windows."]
  set al(MC,frres1)  [msgcat::mc "Found %n matches for \"%s\"."]
  set al(MC,frres2)  [msgcat::mc "Made %n replacements of \"%s\" with \"%r\" in \"%f\"."]
  set al(MC,frres3)  [msgcat::mc "Made %n replacements of \"%s\" with \"%r\" in all of session."]
  set al(MC,frdoit1) [msgcat::mc "Replace all of \"%s\" with \"%r\"\nin \"%f\"?"]
  set al(MC,frdoit2) [msgcat::mc "Replace all of \"%s\" with \"%r\"\nin all texts?"]

  set al(MC,errcopy)     [msgcat::mc "Can't backup \"%f\" to\n\"%d\"!\n\nDelete it anyway?"]
  set al(MC,removed)     [msgcat::mc "\"%f\" removed to \"%d\""]
  set al(MC,filename)    [msgcat::mc "File name:"]
  set al(MC,directory)   [msgcat::mc "Directory"]
  set al(MC,nottoopen)   [msgcat::mc "The file \"%f\" seems to be not of types\n%s.\n\nStill do you want to open it?"]

# checking ini directory
  set al(MC,chini1)      [msgcat::mc "Choosing Directory for Settings"]
  set al(MC,chini2)      [msgcat::mc "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n"]
  set al(MC,chini3)      [msgcat::mc "Choose a directory"]

  set al(MC,notes)       [msgcat::mc "Sort of diary.\nList of TODOs etc."]
  set al(MC,checktcl)    [msgcat::mc "Check of Tcl"]
  set al(MC,colorpicker) [msgcat::mc "Color Picker"]
  set al(checkroot)      [msgcat::mc "Checking %d. Wait a little..."]
  set al(badroot)        [msgcat::mc "Too big directory for a project: %n files or more."]
  set al(makeroot)       [msgcat::mc "Directory \"%d\"\ndoesn't exist.\n\nCreate it?"]


# icons of toolbar
  set al(MC,icofile)     [msgcat::mc "Create a file\nCtrl+N"]
  set al(MC,icoOpenFile) [msgcat::mc "Open a file\nCtrl+O"]
  set al(MC,icoSaveFile) [msgcat::mc "Save the file\nF2"]
  set al(MC,icosaveall)  [msgcat::mc "Save all files\nCtrl+Shift+S"]
  set al(MC,icohelp)     [msgcat::mc "Tcl/Tk help on the selection\nF1"]
  set al(MC,icoreplace)  [msgcat::mc "Find / Replace\nCtrl+F"]
  set al(MC,icook)       $al(MC,checktcl)
  set al(MC,icocolor)    $al(MC,colorpicker)
  set al(MC,icoother)    [msgcat::mc tkcon]
  set al(MC,icorun)      [msgcat::mc "Run the file\nF5"]
  set al(MC,icoe_menu)   [msgcat::mc "Run e_menu\nF4"]
  set al(MC,icoundo)     [msgcat::mc "Undo changes\nCtrl+Z"]
  set al(MC,icoredo)     [msgcat::mc "Redo changes\nCtrl+Shift+Z"]
  set al(MC,icobox)      [msgcat::mc "Projects"]

}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
