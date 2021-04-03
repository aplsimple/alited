#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The list of alited's localized messages.
# _______________________________________________________________________ #


namespace eval ::alited {

  set al(MC,about)       [msgcat::mc "About"]
  set al(MC,nofile)      [msgcat::mc "No name"]
  set al(MC,notsaved)    [msgcat::mc "\"%f\" wasn't saved.\n\nSave it?"]
  set al(MC,saving)      [msgcat::mc "Saving"]
  set al(MC,saveas)      [msgcat::mc "Save as"]
  set al(MC,files)       [msgcat::mc "Files"]
  set al(MC,line)        [msgcat::mc "Line"]
  set al(MC,sort)        [msgcat::mc {Sort "%t"}]
  set al(MC,moveup)      [msgcat::mc "Move Up"]
  set al(MC,movedown)    [msgcat::mc "Move Down"]
  set al(MC,FavLists)    [msgcat::mc "Lists of favorites"]
  set al(MC,swfiles)     [msgcat::mc "Switch to the unit tree"]
  set al(MC,swunits)     [msgcat::mc "Switch to the file tree"]
  set al(MC,filesadd)    [msgcat::mc "Create a file"]
  set al(MC,filesdel)    [msgcat::mc "Delete a file"]
  set al(MC,unitsadd)    [msgcat::mc "Add a unit"]
  set al(MC,unitsdel)    [msgcat::mc "Remove a unit"]
  set al(MC,favoradd)    [msgcat::mc "Add to favorites"]
  set al(MC,favordel)    [msgcat::mc "Remove from favorites"]
  set al(MC,nosels)      [msgcat::mc "No item selected."]

}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
