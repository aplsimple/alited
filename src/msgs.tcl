#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The list of alited's localized messages.
# _______________________________________________________________________ #


namespace eval ::alited {

  set al(MC,about)       [msgcat::mc "About"]
  set al(MC,nofile)      [msgcat::mc "No name"]
  set al(MC,error)       [msgcat::mc "Error"]
  set al(MC,warning)     [msgcat::mc "Warning"]
  set al(MC,question)    [msgcat::mc "Question"]
  set al(MC,select)      [msgcat::mc "Select"]  ;# verb "to select"
  set al(MC,notsaved)    [msgcat::mc "\"%f\" wasn't saved.\n\nSave it?"]
  set al(MC,saving)      [msgcat::mc "Saving"]
  set al(MC,saveas)      [msgcat::mc "Save as"]
  set al(MC,files)       [msgcat::mc "Files"]
  set al(MC,line)        [msgcat::mc "Line"]
  set al(MC,moveup)      [msgcat::mc "Move Up"]
  set al(MC,movedown)    [msgcat::mc "Move Down"]
  set al(MC,FavLists)    [msgcat::mc "Lists of Favorites"]
  set al(MC,swfiles)     [msgcat::mc "Switch to Unit Tree"]
  set al(MC,swunits)     [msgcat::mc "Switch to File Tree"]
  set al(MC,filesadd)    [msgcat::mc "Create File"]
  set al(MC,filesadd2)   [msgcat::mc "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' checkbox.\nThe directory can include subdirectories (a/b/c)."]
  set al(MC,filesdel)    [msgcat::mc "Delete File"]
  set al(MC,unitsadd)    [msgcat::mc "Add Unit"]
  set al(MC,unitsdel)    [msgcat::mc "Remove Unit(s)"]
  set al(MC,favoradd)    [msgcat::mc "Add to Favorites"]
  set al(MC,favordel)    [msgcat::mc "Remove from Favorites"]
  set al(MC,nosels)      [msgcat::mc "No item selected."]
  set al(MC,updtree)     [msgcat::mc "Update Tree"]
  set al(MC,moving)      [msgcat::mc "Moving"]
  set al(MC,movefile)    [msgcat::mc "Move %f\nto\n%d\n?"]
  set al(MC,introln1)    [msgcat::mc "First Lines"]
  set al(MC,introln2)    [msgcat::mc "Can't touch the first %n lines."]
  set al(MC,favorites)   [msgcat::mc "Favorites"]
  set al(MC,addfavor)    [msgcat::mc "Add \"%n\" of %f\nto the favorites?"]
  set al(MC,addexist)    [msgcat::mc "Item \"%n\" of %f\nis already in the favorites."]
  set al(MC,delfavor)    [msgcat::mc "Remove \"%n\" of %f\nfrom the favorites?"]
  set al(MC,selfavor)    [msgcat::mc "Select \"%t\""]
  set al(MC,copydecl)    [msgcat::mc "Copy Declaration"]
  set al(MC,delitem)     [msgcat::mc "Remove \"%n\"\nfrom \"%f\"?"]
  set al(MC,delfile)     [msgcat::mc "Delete \"%f\"?"]
  set al(MC,tpl)         [msgcat::mc "Templates"]
  set al(MC,tpl1)        [msgcat::mc "Use buttons on the right to add/change/delete a template."]
  set al(MC,tpl2)        [msgcat::mc "In its text, set the cursor where it should be in the editor."]
  set al(MC,tpl4)        [msgcat::mc "Current template:"]
  set al(MC,tpl5)        [msgcat::mc "New template:"]
  set al(MC,tplhd1)      [msgcat::mc "Template"]
  set al(MC,tplhd2)      [msgcat::mc "Hot keys"]
  set al(MC,tpladd)      [msgcat::mc "Add a template"]
  set al(MC,tplchg)      [msgcat::mc "Change a template"]
  set al(MC,tpldel)      [msgcat::mc "Delete a template"]
  set al(MC,tplsel)      [msgcat::mc "Select a template"]
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
  set al(MC,tplloc4)     [msgcat::mc "1st line"]
  set al(MC,tplttloc1)   [msgcat::mc "Inserts a template\nbelow a current line"]
  set al(MC,tplttloc2)   [msgcat::mc "Inserts a template\nbelow a current unit"]
  set al(MC,tplttloc3)   [msgcat::mc "Inserts a template at the cursor\n(good for one-liners)"]
  set al(MC,tplttloc4)   [msgcat::mc "Inserts a template after 1st line of a file\n(License, Introduction etc.)"]
  set al(MC,tpldelq)     [msgcat::mc "Delete a template #%n ?"]
  set al(MC,fav1)        [msgcat::mc "Use buttons on the right to add/change/delete a favorites' list."]
  set al(MC,fav2)        [msgcat::mc "Enter a name for current favorites to add a new favorites' list."]
  set al(MC,fav3)        [msgcat::mc "Favorites' lists:"]
  set al(MC,fav4)        [msgcat::mc "Current favorites' list:"]
  set al(MC,fav5)        [msgcat::mc "New favorites' list:"]
  set al(MC,favadd)      [msgcat::mc "Add a favorites' list"]
  set al(MC,favchg)      [msgcat::mc "Change a favorites' list"]
  set al(MC,favdel)      [msgcat::mc "Delete a favorites' list"]
  set al(MC,favsel)      [msgcat::mc "Select a favorites' list"]
  set al(MC,favnew)      [msgcat::mc "The favorites' list #%n added"]
  set al(MC,favupd)      [msgcat::mc "The favorites' list #%n updated"]
  set al(MC,favrem)      [msgcat::mc "The favorites' list #%n removed"]
  set al(MC,favent1)     [msgcat::mc "Enter a name of the favorites' list"]
  set al(MC,favent2)     [msgcat::mc "Favorites of the current list"]
  set al(MC,favent3)     [msgcat::mc "The current favorites' list is empty!"]
  set al(MC,favexists)   [msgcat::mc "This favorites' list already exists"]
  set al(MC,faverrsav)   [msgcat::mc "This favorites' list not saved to\n\"%f\"."]
  set al(MC,favloc)      [msgcat::mc "Non-favorite files to be:"]
  set al(MC,favloc1)     [msgcat::mc "kept"]
  set al(MC,favloc2)     [msgcat::mc "closed"]
  set al(MC,favtip1)   [msgcat::mc "Doesn't close any tab without favorites\nat choosing the favorites' list"]
  set al(MC,favtip2)   [msgcat::mc "Closes all tabs without favorites\nat choosing the favorites' list"]
  set al(MC,favtip3)     [msgcat::mc "Sets a list of favorites\nactive before these ones."]
  set al(MC,favdelq)     [msgcat::mc "Delete a favorites' list #%n ?"]
  set al(MC,favinit)     [msgcat::mc "Initial"]
  set al(MC,errcopy)     [msgcat::mc "Can't copy \"%f\" to\n\"%d\""]
  set al(MC,removed)     [msgcat::mc "\"%f\" removed to \"%d\""]
  set al(MC,filename)    [msgcat::mc "File name:"]
  set al(MC,directory)   [msgcat::mc "Directory"]

# find-replace dialogue
  set al(MC,frttl)   [msgcat::mc "Find | Replace"]
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
  set al(MC,frfind3) [msgcat::mc "All in Session"]
  set al(MC,frtip1)  [msgcat::mc "Allows to use *, ?, \[ and \]\nin \"find\" string."]
  set al(MC,frtip2)  [msgcat::mc "Allows to use the regular expressions\nin \"find\" string."]
  set al(MC,frtip3)  [msgcat::mc "Allows replacements by the empty string,\nin fact, to erase the found ones."]
  set al(MC,frtip4)  [msgcat::mc "Keeps the dialogue above other windows."]
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
