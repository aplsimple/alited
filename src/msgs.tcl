###########################################################
# Name:    msgs.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/30/2021
# Brief:   Handles common localized messages.
# License: MIT.
###########################################################

namespace eval ::alited {

  proc msgcatMessages {} {
    # Sets common localized messages.

    # alited_checked

    variable al

    ## _ common _ ##
    set al(MC,nofile)      [msgcat::mc {No name}]
    set al(MC,warning)     [msgcat::mc Warning]
    set al(MC,info)        [msgcat::mc Information]
    set al(MC,wait)        [msgcat::mc {Wait a little ...}]
    set al(MC,help)        [msgcat::mc Help]
    set al(MC,select)      [msgcat::mc Select]  ;# verb
    set al(MC,notsaved)    [msgcat::mc "\"%f\" wasn't saved.\n\nSave it?"]
    set al(MC,saving)      [msgcat::mc Saving]
    set al(MC,files)       [msgcat::mc Files]
    set al(MC,moving)      [msgcat::mc Moving]
    set al(MC,run)         [msgcat::mc Run]
    set al(MC,new)         [msgcat::mc New]
    set al(MC,open...)     [msgcat::mc Open...]
    set al(MC,close)       [msgcat::mc Close]
    set al(MC,save)        [msgcat::mc Save]
    set al(MC,saveas...)   [msgcat::mc {Save as...}]
    set al(MC,saveall)     [msgcat::mc {Save All}]
    set al(MC,clall)       [msgcat::mc {... All}]
    set al(MC,clallleft)   [msgcat::mc {... All at Left}]
    set al(MC,clallright)  [msgcat::mc {... All at Right}]
    set al(MC,pref)        [msgcat::mc Preferences]
    set al(MC,pref...)     [msgcat::mc Preferences...]
    set al(MC,notrecomm)   [msgcat::mc "Not recommended for projects\nwith large files (>2000 LOC)!"]
    set al(MC,quit)        [msgcat::mc Quit]
    set al(MC,indent)      [msgcat::mc Indent]
    set al(MC,unindent)    [msgcat::mc Unindent]
    set al(MC,corrindent)  [msgcat::mc {Correct Indentation}]
    set al(MC,comment)     [msgcat::mc Comment]
    set al(MC,uncomment)   [msgcat::mc Uncomment]
    set al(MC,findreplace) [msgcat::mc {Find / Replace}]
    set al(MC,findnext)    [msgcat::mc {Find Next}]
    set al(MC,alloffile)   [msgcat::mc "All of \"%f\""]
    set al(MC,lines)       [msgcat::mc Lines]
    set al(MC,moveupU)     [msgcat::mc {Move Unit Up}]
    set al(MC,movedownU)   [msgcat::mc {Move Unit Down}]
    set al(MC,moveupF)     [msgcat::mc {Move File Up}]
    set al(MC,movedownF)   [msgcat::mc {Move File Down}]
    set al(MC,FavLists)    [msgcat::mc {Saved Lists of Favorites}]
    set al(MC,swfiles)     [msgcat::mc {Switch to Unit Tree}]
    set al(MC,swunits)     [msgcat::mc {Switch to File Tree}]
    set al(MC,filesadd)    [msgcat::mc {Create File}]
    set al(MC,filesadd2)   [msgcat::mc "Enter a name of file to create in:\n%d\n\nIf it is a directory, check 'Directory' box.\nThe directory can include subdirectories (a/b/c)."]
    set al(MC,filesdel)    [msgcat::mc {Delete File}]
    set al(MC,fileexist)   [msgcat::mc "File %f already exists in\n%d"]
    set al(MC,filenoexist) [msgcat::mc "\nFile\n  \"%f\"\ndoesn't exist.\n"]
    set al(MC,unitsdel)    [msgcat::mc {Delete Unit(s)}]
    set al(MC,favoradd)    [msgcat::mc {Add to Favorites}]
    set al(MC,favordel)    [msgcat::mc {Delete}]
    set al(MC,favorren)    [msgcat::mc {Rename}]
    set al(MC,favordelall) [msgcat::mc {Delete All}]
    set al(MC,updtree)     [msgcat::mc {Update Tree}]
    set al(MC,movefile)    [msgcat::mc "Move %f\nto\n%d\n?"]
    set al(MC,introln1)    [msgcat::mc {First Lines}]
    set al(MC,introln2)    [msgcat::mc {Can't touch the first %n lines.}]
    set al(MC,favorites)   [msgcat::mc Favorites]
    set al(MC,currfavs)    [msgcat::mc {Current list of favorites}]
    set al(MC,lastvisit)   [msgcat::mc {Last Visited}]
    set al(MC,addfavor)    [msgcat::mc "Add \"%n\" of %f\nto Favorites?"]
    set al(MC,addexist)    [msgcat::mc "Item \"%n\" of %f\nis already in Favorites."]
    set al(MC,delfavor)    [msgcat::mc "Remove \"%n\" of %f\nfrom Favorites?"]
    set al(MC,notfavor)    [msgcat::mc "\"%n\" unit of %f is not in the list."]
    set al(MC,selfavor)    [msgcat::mc "Click \"%t\""]
    set al(MC,copydecl)    [msgcat::mc {Copy Declaration}]
    set al(MC,openofdir)   [msgcat::mc "Open All Tcl Files of \"%n\""]
    set al(MC,delitem)     [msgcat::mc "Remove \"%n\"\nfrom \"%f\"?"]
    set al(MC,delfile)     [msgcat::mc "Delete \"%f\"?"]
    set al(MC,nodelopen)   [msgcat::mc {An open file can not be deleted:}]
    set al(MC,modiffile)   [msgcat::mc "File \"%f\" was modified by some application.\n\nCancel your edition and reload the file?"]
    set al(MC,wasdelfile)  [msgcat::mc "File \"%f\" was deleted by some application.\n\nSave the file?"]
    set al(MC,Row:)        [msgcat::mc {Row: }]
    set al(MC,Col:)        [msgcat::mc { Col: }]
    set al(MC,Item)        [msgcat::mc Item]
    set al(MC,errmove)     [msgcat::mc "\"%n\" contains unbalanced \{\}: %1!=%2"]
    set al(MC,afterstart)  [msgcat::mc {For Start}]
    set al(MC,locale)      [msgcat::mc "This is a language code: ru, uk, de...\nIn alited, \"en\" means American English."]
    set al(MC,noask)       [msgcat::mc {Don't show anymore}]
    set al(MC,needcs)      [msgcat::mc "These themes need\nlight / dark color schemes\naccordingly"]
    set al(MC,nocs)        [msgcat::mc {No color scheme at all}]
    set al(MC,fitcs)       [msgcat::mc {Fit for theme}]
    set al(MC,hue)         [msgcat::mc {Makes colors darker .. lighter}]
    set al(MC,maxbak)      [msgcat::mc {Maximum of backup copies per a file}]
    set al(MC,othertcl)    [msgcat::mc {Do it in other Tcl files}]
    set al(MC,otherfiles)  [msgcat::mc {Do it in other files}]
    set al(MC,inconsole)   [msgcat::mc {in console}]
    set al(MC,intkcon)     [msgcat::mc {in Tkcon}]
    set al(MC,on)          [msgcat::mc on]
    set al(MC,test)        [msgcat::mc Test]
    set al(MC,restart)     [msgcat::mc "For the settings to be active,\nalited application should be restarted."]

    ## _  menu items _ ##
    set al(MC,lookdecl)    [msgcat::mc {Look for Declaration}]
    set al(MC,lookword)    [msgcat::mc {Look for Word}]
    set al(MC,toline)      [msgcat::mc {Go to Line}]
    set al(MC,tomatched)   [msgcat::mc {To Matched Bracket}]
    set al(MC,hlcolors)    [msgcat::mc {Display colors}]

    ## _  project options _ ##
    set al(MC,Ign:)        [msgcat::mc {Skip subdirectories:}]
    set al(MC,EOL:)        [msgcat::mc {End of line:}]
    set al(MC,indent:)     [msgcat::mc {Indentation:}]
    set al(MC,indentAuto)  [msgcat::mc {Auto detection}]
    set al(MC,redunit)     [msgcat::mc {Unit lines per 1 red bar:}]
    set al(MC,multiline)   [msgcat::mc {Multi-line strings:}]
    set al(MC,trailwhite)  [msgcat::mc {Remove trailing whitespaces:}]

    ## _ templates _ ##
    set al(MC,tpl)         [msgcat::mc Templates]
    set al(MC,tpllist)     [msgcat::mc {List of Templates}]
    set al(MC,tplsel)      [msgcat::mc {Click a template}]
    set al(MC,tplnew)      [msgcat::mc {The template #%n added}]
    set al(MC,tplupd)      [msgcat::mc {The template #%n updated}]
    set al(MC,tplrem)      [msgcat::mc {The template #%n removed}]
    set al(MC,tplent1)     [msgcat::mc {Enter a name of the template}]
    set al(MC,tplent2)     [msgcat::mc {Enter a text of the template}]
    set al(MC,tplent3)     [msgcat::mc "Choose a hot key combination\nfor the template insertion."]
    set al(MC,tplaft1)     [msgcat::mc "Inserts a template\nbelow a current line"]
    set al(MC,tplaft2)     [msgcat::mc "Inserts a template\nbelow a current unit"]
    set al(MC,tplaft3)     [msgcat::mc "Inserts a template at the cursor\n(good for one-liners)"]
    set al(MC,tplaft4)     [msgcat::mc "Inserts a template after 1st line of a file\n(License, Introduction etc.)"]
    set al(MC,tplinds)     [msgcat::mc "Indents a template at inserting,\nby an insertion line's indentation."]
    set al(MC,tplexists)   [msgcat::mc {A template with the attribute(s) already exists.}]
    set al(MC,tpldelq)     [msgcat::mc {Delete a template #%n ?}]

    ## _ projects _ ##
    set al(MC,projects)    [msgcat::mc Projects]
    set al(MC,prjgoing)    [msgcat::mc {You are going to %n!}]
    set al(MC,prjadd)      [msgcat::mc {Add a project}]
    set al(MC,prjchg)      [msgcat::mc {Change a project}]
    set al(MC,prjdel1)     [msgcat::mc {Delete a project}]
    set al(MC,prjcantdel)  [msgcat::mc {Don't delete the current project!}]
    set al(MC,prjnew)      [msgcat::mc "The project \"%n\" added"]
    set al(MC,prjupd)      [msgcat::mc "The project \"%n\" updated"]
    set al(MC,prjdel2)     [msgcat::mc "The project \"%n\" removed"]
    set al(MC,prjOptions)  [msgcat::mc Options]
    set al(MC,prjName)     [msgcat::mc {Project:}]
    set al(MC,prjsavfl)    [msgcat::mc "You can\n  - add the current one to\n  - substitute with the current one\n  - delete\n  - not change\nthe file list of the project.\n"]
    set al(MC,prjaddfl)    [msgcat::mc Add]
    set al(MC,prjsubstfl)  [msgcat::mc Substitute]
    set al(MC,prjdelfl)    [msgcat::mc Delete]
    set al(MC,prjnochfl)   [msgcat::mc {Don't change}]
    set al(MC,prjsel)      [msgcat::mc {Click a project}]
    set al(MC,prjdelq)     [msgcat::mc "Delete a project \"%n\" ?"]
    set al(MC,prjexists)   [msgcat::mc "A project \"%n\" already exists."]
    set al(MC,DEFopts)     [msgcat::mc {Options for new projects are set in "Preferences/General/Projects"}]
    set al(MC,prjTdelete)  [msgcat::mc {Erase a text}]
    set al(MC,prjTpaste)   [msgcat::mc {Paste a text}]
    set al(MC,prjTundo)    [msgcat::mc {Undo changes}]
    set al(MC,prjTredo)    [msgcat::mc {Redo changes}]
    set al(MC,prjTtext)    [msgcat::mc {Text of a reminder}]
    set al(MC,prjTprevious)  [msgcat::mc {TODO previous day}]
    set al(MC,prjTprevious2) [msgcat::mc {TODO previous week}]
    set al(MC,prjTnext)    [msgcat::mc {TODO next day}]
    set al(MC,prjTnext2)   [msgcat::mc {TODO next week}]
    set al(MC,TemplPrj)    [msgcat::mc "Enter a tree of directories for the project template.\nIndent them by equal indents to mean subdirectories.\n\nFiles like README*, CHANGELOG* will be created blank.\nFiles like LICENSE* will be taken from the current project."]
    set al(MC,CrTemplPrj)  [msgcat::mc {Create a project by template}]
    set al(MC,ViewDir)     [msgcat::mc {Project directory}]
    set al(MC,com)         [msgcat::mc Command]
    set al(MC,coms)        [msgcat::mc Commands]

    ## _ favorites _ ##
    set al(MC,favsel)      [msgcat::mc {Click a list of favorites}]
    set al(MC,favnew)      [msgcat::mc {The list #%n added}]
    set al(MC,favupd)      [msgcat::mc {The list #%n updated}]
    set al(MC,favrem)      [msgcat::mc {The list #%n removed}]
    set al(MC,favent1)     [msgcat::mc {Enter a name of the list}]
    set al(MC,favent3)     [msgcat::mc {The current list is empty!}]
    set al(MC,favexists)   [msgcat::mc {This list already exists}]
    set al(MC,faverrsav)   [msgcat::mc "This list not saved to\n\"%f\"."]
    set al(MC,favdelq)     [msgcat::mc {Delete a favorites' list #%n ?}]

    ## _ find-replace dialogue _ ##
    set al(MC,frMatch) [msgcat::mc {Match: }]
    set al(MC,frWord)  [msgcat::mc {Match whole word}]
    set al(MC,frExact) [msgcat::mc {Exact}]
    set al(MC,frCase)  [msgcat::mc {Match case}]
    set al(MC,frres1)  [msgcat::mc "Found %n matches for \"%s\"."]
    set al(MC,frres2)  [msgcat::mc "Made %n replacements of \"%s\" with \"%r\" in \"%f\"."]
    set al(MC,frres3)  [msgcat::mc "Made %n replacements of \"%s\" with \"%r\" in all of session."]
    set al(MC,frdoit1) [msgcat::mc "Replace all of \"%s\"\n\nwith \"%r\"\n\nin \"%f\" ?"]
    set al(MC,frdoit2) [msgcat::mc "Replace all of \"%s\"\n\nwith \"%r\"\n\nin all%Stexts?"]

    ## _ file & directory _ ##
    set al(MC,removed)     [msgcat::mc "\"%f\" removed to \"%d\""]
    set al(MC,nottoopen)   [msgcat::mc "The file \"%f\" seems to be not of types\n%s.\n\nStill do you want to open it?"]
    set al(MC,renamefile)  [msgcat::mc {Rename File}]
    set al(MC,openselfile) [msgcat::mc {Open Selected Files}]
    set al(MC,filelist)    [msgcat::mc {File List}]

    ## _ start and update _ ##
    set al(MC,chini1)      [msgcat::mc {Choosing Directory for Settings}]
    set al(MC,chini2)      [msgcat::mc "\n The \"alited\" needs a configuration directory to store its settings.\n You can pass its name to alited as an argument.\n\n The default configuration directory is \"%d\".\n It's preferable as used to run \"alited\" without arguments.\n"]
    set al(MC,chini3)      [msgcat::mc {Choose a directory}]
    set al(MC,updateALE)   [msgcat::mc {Updating alited}]
    set al(MC,updLab1)     [msgcat::mc " You are highly recommended to accept\n these changes in order to complete updating:"]
    set al(MC,updmnu)      [msgcat::mc {.em files for "Tools"}]
    set al(MC,updini)      [msgcat::mc {.ini file for "Templates"}]
    set al(MC,updLab2)     [msgcat::mc { Your previous files will be saved to:}]

    ## _ misc _ ##
    set al(MC,notes)       [msgcat::mc "Sort of diary.\nList of TODOs etc."]
    set al(MC,checktcl)    [msgcat::mc {Check Tcl}]
    set al(MC,colorpicker) [msgcat::mc {Color Picker}]
    set al(MC,datepicker)  [msgcat::mc {Date Picker}]
    set al(checkroot)      [msgcat::mc {Checking %d. Wait a little...}]
    set al(badroot)        [msgcat::mc {Too big directory for a project: %n files or more.}]
    set al(makeroot)       [msgcat::mc "Directory \"%d\"\ndoesn't exist.\n\nCreate it?"]

    ## _ icons of toolbar _ ##
    set al(MC,icofile)     [msgcat::mc "Create a file\nCtrl+N"]
    set al(MC,icoOpenFile) [msgcat::mc "Open a file\nCtrl+O"]
    set al(MC,icoSaveFile) [msgcat::mc {Save the file}]
    set al(MC,icosaveall)  [msgcat::mc "Save all files\nCtrl+Shift+S"]
    set al(MC,icohelp)     [msgcat::mc "Tcl/Tk help on the selection\nF1"]
    set al(MC,icoreplace)  [msgcat::mc "Find / Replace\nCtrl+F"]
    set al(MC,icook)       $al(MC,checktcl)
    set al(MC,icocolor)    $al(MC,colorpicker)
    set al(MC,icodate)     $al(MC,datepicker)
    set al(MC,icoother)    Tkcon
    set al(MC,icorun)      [msgcat::mc {Run the file}]
    set al(MC,icoe_menu)   [msgcat::mc {Run e_menu}]
    set al(MC,icoundo)     [msgcat::mc "Undo changes\nCtrl+Z"]
    set al(MC,icoredo)     [msgcat::mc "Redo changes\nCtrl+Shift+Z"]
    set al(MC,icocategories) [msgcat::mc Projects]

    ## _ find units _ ##
    set al(MC,findunit)    [msgcat::mc "Use glob patterns to find units' declarations\ne.g. \"s*rt\" would find \"start\" and \"insert\".\nThe letter case is ignored."]
    set al(MC,notfndunit)  [msgcat::mc {Unit not found: %u}]
  }
}

# _________________________________ EOF _________________________________ #
