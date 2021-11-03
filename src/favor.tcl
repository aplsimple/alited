#! /usr/bin/env tclsh
###########################################################
# Name:    favor.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/01/2021
# Brief:   Handles favorites/last visited lists.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #


namespace eval favor {
  variable tipID {}            ;# ID of item a tip is shown for
  variable initialFavs [list]  ;# favorites that exist at starting "Favorites' list"
}

# ________________________ Common _________________________ #

proc favor::LastVisited {item header} {
  # Puts an item to "Last visited" list.
  #   item - list of tree's item data (first two: -text {label})
  #   header - header of item

  namespace upvar ::alited al al obPav obPav
  # check for "All of..." - don't save it
  set allof [string range $al(MC,alloffile) 0 [string first \" $al(MC,alloffile)]]
  if {[string first $allof $header]==0} return
  # check for "Lines..." - don't save it
  if {[regexp "^$al(MC,lines) \\d+-\\d+\$" $header]} return
  # check for an empty item - don't save it
  set name [string trim [lindex $item 1]]
  if {[string trim $name] eq {}} return
  # checks done, save this last visit
  set fname [alited::bar::FileName] 
  # search an old item
  set found no
  set i 0
  set ln "[expr {int([[alited::main::CurrentWTXT] index insert])}]"
  foreach it $al(FAV,visited) {
    lassign $it - - ID - values
    lassign $values name2 fname2 header2 l1
    if {$ln eq $l1 || $fname eq $fname2 && $header eq $header2} {
      set found yes
      # if found, move it to 0th position
      set al(FAV,visited) [lreplace $al(FAV,visited) $i $i]
      break
    }
    incr i
  }
  set al(FAV,visited) [linsert $al(FAV,visited) 0 [list - - - - [list $name $fname $header $ln]]]
  # delete last items if the list's limit is exceeded
  catch {set al(FAV,visited) [lreplace $al(FAV,visited) $al(FAV,MAXLAST) end]}
  # update the tree widget
  if {!$al(FAV,IsFavor)} {
    SetFavorites $al(FAV,visited)
    set wtree [$obPav TreeFavor]
    if {[set id0 [lindex [$wtree children {}] 0]] ne {}} {
      $wtree see $id0
    }
  }
}
#_______________________

proc favor::OpenSelectedFile {fname} {
  # Opens a file from a selected item of favorites/last visited.
  #   fname - file name
  # Returns tab's ID, if the file is open successfully.

  namespace upvar ::alited al al
  set al(dolastvisited) no
  set TID [alited::file::OpenFile $fname yes]
  set al(dolastvisited) yes
  if {$TID eq {}} {
    set msg [string map [list %f $fname] [msgcat::mc {File not found: %f}]]
    alited::Message $msg 4
  }
  return $TID
}
#_______________________

proc favor::GoToUnit {TID name header {forfavor no} {it1 {}} {values {}}} {
  # Enters a unit.
  #   TID - tab's ID
  #   name - name of the unit
  #   header - header of the unit
  #   forfavor - yes, if Favorites list is clicked and must be updated
  #   it1 - item selected in Favorites (for forfavor=yes)
  #   values - values of item selected in Favorites (for forfavor=yes)
  # Returns yes, if the unit is open successfully.
  # See also: tree::SaveCursorPos

  namespace upvar ::alited al al obPav obPav
  foreach it $al(_unittree,$TID) {
    set treeID [alited::tree::NewItemID [incr iit]]
    lassign $it lev leaf fl1 title l1 l2
    if {$name eq [alited::tree::UnitTitle $title $l1 $l2]} {
      if {$forfavor} {
        set wtree [$obPav TreeFavor]
        $wtree delete $it1
        set favID [$wtree insert {} 0 -values $values]
        $wtree tag add tagNorm $favID
      }
      LastVisited [list -text $name] $header
      set pos [lindex $it 7]  ;# saved cursor position
      if {$pos ne {}} {set pos "$pos yes"}
      after idle "alited::tree::NewSelection $treeID $pos"
      return yes
    }
  }
  return no
}
#_______________________

proc favor::Select {} {
  # Handles selecting an item of "Favorites / Last visited" treeview.

  namespace upvar ::alited al al obPav obPav
  set msec [clock milliseconds]
  if {[info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<800}]} {
    return ;# disables double click
  }
  set al(_MSEC) $msec
  set wtree [$obPav TreeFavor]
  if {![IsSelected favID name fname sname header line]} {
    return
  }
  set values [$wtree item $favID -values]
  if {[set TID [OpenSelectedFile $fname]] eq {}} return
  # scan Favorites/last-visited tree, to find the selected item
  # and remake favorites and last visits; then go to the selected unit
  foreach it1 [$wtree children {}] {
    if {$name eq [lindex [$wtree item $it1 -values] 0]} {
      if {[GoToUnit $TID $name $header $al(FAV,IsFavor) $it1 $values]} return
      break
    }
  }
  set msg [string map [list %u $name] [msgcat::mc {Unit not found: %u}]]
  alited::Message $msg 4
}
#_______________________

proc favor::IsSelected {IDN nameN fnameN snameN headerN lineN} {
  # Gets data of currently selected item of favorites.
  #   IDN - variable name of item's ID
  #   nameN - variable name of item's name
  #   fnameN - variable name of item's file name
  #   snameN - variable name of item's tail file name
  #   headerN - variable name of item's header
  #   lineN - variable name of item's 1st line

  namespace upvar ::alited al al obPav obPav
  upvar 1 $IDN ID $nameN name $fnameN fname $snameN sname $headerN header $lineN line
  if {[set ID [alited::tree::CurrentItem TreeFavor]] eq {}} {return no}
  set wtree [$obPav TreeFavor]
  lassign [$wtree item $ID -values] name fname header line
  set sname [file tail $fname]
  return yes
}
# ________________________ Set favorites _________________________ #

proc favor::SetAndClose {cont} {
  # Sets favorites list, opens files from favorites list, closes other files.
  #   cont - list of favorites

  SetFavorites $cont
  set fnamecont {}
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    set fname [alited::bar::FileName $TID]
    set found no
    foreach fit $cont {
      set fnamecont [lindex $fit 4 1]
      if {$fname eq $fnamecont} {
        set found yes
        break
      }
    }
    if {!$found} {
      if {![alited::file::CloseFile $TID no]} break
      alited::bar::BAR $TID close no
    }
  }
  if {![llength [alited::bar::BAR listTab]]} {
    # no tabs open
    if {$fnamecont ne {}} {
      alited::file::OpenFile $fnamecont yes ;#  open a file from favorites
    } else {
      alited::file::CheckForNew  ;# ... or create "no name" tab
    }
  }
}
#_______________________

proc favor::SetFavorites {cont} {
  # Sets favorites/last visited list in the treeview.
  #   cont - list of favorites/last visited

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  foreach it [alited::tree::GetTree {} TreeFavor] {
    $wtree delete [lindex $it 2]
  }
  foreach curfav $cont {
    catch {
      lassign $curfav - - - - values
      if {$values ne {}} {
        set itemID [$wtree insert {} end -values $values]
        $wtree tag add tagNorm $itemID
      }
    }
  }
}
#_______________________

proc favor::Lists {} {
  # Runs "Lists of Favorites" dialogue, sets a list of favorites at a choice.

  variable initialFavs
  if {![llength $initialFavs]} {
    set initialFavs [alited::tree::GetTree {} TreeFavor]
  }
  lassign [::alited::favor_ls::_run] pla cont
  switch $pla {
    1 {SetFavorites $cont}
    2 {SetAndClose $cont}
    3 {SetFavorites $initialFavs}
  }
}

# ________________________ Display _________________________ #

proc favor::Show {} {
  # Shows a list of favorites / last visited units.

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  if {$al(FAV,IsFavor)} {
    [$obPav BuTVisitF] configure -image alimg_misc
    set tip $alited::al(MC,lastvisit)
    set state normal
    SetFavorites $al(FAV,current)
    $wtree heading #1 -text [msgcat::mc $al(MC,favorites)]

  } else {
    set al(FAV,current) [list]
    foreach it [alited::tree::GetTree {} TreeFavor] {
      lappend al(FAV,current) $it
    }
    [$obPav BuTVisitF] configure -image alimg_heart
    set tip $al(MC,favorites)
    set state disable
    SetFavorites $al(FAV,visited)
    $wtree heading #1 -text [msgcat::mc $al(MC,lastvisit)]
  }
  foreach but {BuTListF BuTAddF} {
    [$obPav $but] configure -state $state
  }
  baltip::tip [$obPav BuTVisitF] $tip
}
#_______________________

proc favor::ShowFavVisit {} {
  # Show favorites/last visits, depending on the mode.

  namespace upvar ::alited al al obPav obPav
  SetFavorites $al(FAV,current)
  if {!$al(FAV,IsFavor)} Show
}

proc favor::SwitchFavVisit {} {
  # Switches favorites / last visited units' view.

  namespace upvar ::alited al al obPav obPav
  set al(FAV,IsFavor) [expr {!$al(FAV,IsFavor)}]
  Show
}

# ________________________ Changing lists ________________________ #

proc favor::Add {{undermouse yes} {idnames {}}} {
  # Adds a unit to favorites.
  #   undermouse - if yes, run by mouse click
  #   idnames - list of unit's ID and names to add

  namespace upvar ::alited al al obPav obPav
  set fname [alited::bar::FileName]
  set sname [file tail $fname]
  if {$undermouse} {set geo {-geometry pointer+10+-100}} {set geo {}}
  set idnlen [llength $idnames]
  if {$idnlen==0} {
    lassign [CurrentName] itemID name l1 l2
    if {$name eq {}} return
    set idnames [list $itemID $name]
  }
  if {![info exists al(ANSWER,favor::Add)]} {
    set al(ANSWER,favor::Add) 0
  }
  foreach {itemID name} $idnames {
    set err no
    foreach it [alited::tree::GetTree {} TreeFavor] {
      lassign [lindex $it 4] name2 fname2
      if {$name eq $name2 && $fname eq $fname2} {
        set msg [string map [list %n $name %f $sname] $al(MC,addexist)]
        alited::Message $msg 4
        set err yes
        break
      }
    }
    if {$err} continue
    set msg [string map [list %n $name %f $sname] $al(MC,addfavor)]
    if {$al(ANSWER,favor::Add)==11 || [set al(ANSWER,favor::Add) \
    [alited::msg yesnocancel ques $msg YES -ch $al(MC,noask) {*}$geo]] \
    in {1 11}} {
      set wtree [$obPav Tree]
      set header [alited::unit::GetHeader [$obPav Tree] $itemID]
      if {$idnlen==0} {
        set pos [[alited::main::CurrentWTXT] index insert]
        set line [expr {($l1 eq {} || $l2 eq {} || $l1>$pos || $l2<$pos) ? 0 : \
          [alited::p+ $pos -$l1]}]
      } else {
        set line 0 ;# favorites added from the tree
      }
      set wt2 [$obPav TreeFavor]
      set ID2 [$wt2 insert {} 0 -values [list $name $fname $header $line]]
      $wt2 tag add tagNorm $ID2
    }
    if {!$al(ANSWER,favor::Add)} break
  }
}
#_______________________

proc favor::AddFromTree {} {
  # Adds a list of selected items of the tree to Favorites.

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set IDs [$wtree selection]
  if {$IDs eq {}} {bell; return}
  foreach ID $IDs {
    lappend idnames $ID [string trim [$wtree item $ID -text]]
  }
  Add no $idnames
}
#_______________________

proc favor::Delete {{undermouse yes}} {
  # Deletes an item from favorites.
  #   undermouse - if yes, run by mouse click

  namespace upvar ::alited al al obPav obPav
  set treelist [alited::tree::GetTree {} TreeFavor]
  if {$undermouse} {
    set name [lindex [CurrentName] 1]
    set favID {}
    foreach it $treelist {
      lassign $it - - ID2 - values
      lassign $values name2 fname header line
      if {$name2 eq $name} {
        set favID $ID2
        break
      }
    }
  } else {
    if {![IsSelected favID name fname sname header line]} return
  }
  if {![info exists fname] || $fname eq {}} {
    bell
    return  ;# for empty list
  }
  set sname [file tail $fname]
  if {$favID eq {}} {
    set msg [string map [list %n $name %f $sname] $al(MC,notfavor)]
    alited::Message $msg 4
    return
  }
  set msg [string map [list %n $name %f $sname] $al(MC,delfavor)]
  if {$undermouse} {set geo {-geometry pointer+10+-100}} {set geo {}}
  if {!$al(FAV,IsFavor) || [alited::msg yesno warn $msg NO {*}$geo]} {
    [$obPav TreeFavor] delete $favID
    if {!$al(FAV,IsFavor)} {
      set i [lsearch -exact -index 2 $treelist $favID]
      set al(FAV,visited) [lreplace $al(FAV,visited) $i $i]
    }
  }
}
#_______________________

proc favor::DeleteAll {{undermouse yes}} {
  # Deletes all items from favorites.
  #   undermouse - if yes, run by mouse click

  namespace upvar ::alited al al obPav obPav
  if {$undermouse} {set geo {-geometry pointer+10+-100}} {set geo {}}
  if {$al(FAV,IsFavor)} {
    set msg {Remove all of Favorites?}
    set listvar al(FAV,current)
  } else {
    set msg {Remove all of the last visited?}
    set listvar al(FAV,visited)
  }
  set favlist [alited::tree::GetTree {} TreeFavor]
  if {$favlist eq {}} {bell; return}
  if {[alited::msg yesno warn [msgcat::mc $msg] NO {*}$geo -title $al(MC,favordelall)]} {
    foreach curfav $favlist {
      [$obPav TreeFavor] delete [lindex $curfav 2]
    }
    set $listvar [list]
  }
}
#_______________________

proc favor::CurrentName {} {
  # Gets data of a current unit.
  # Returns a list of the unit's data: ID, title, 1st line, last line.

  lassign [alited::tree::CurrentItemByLine {} 1] itemID - - - name l1 l2
  set name [string trim $name]
  if {$name eq {}} bell
  return [list $itemID $name $l1 $l2]
}

# ________________________ Popup menus _________________________ #

proc favor::ShowPopupMenu {ID X Y} {
  # Displays a popup menu at clicking Favorites / last visited list.
  #   ID - tree item's ID
  #   X - x-coordinate of the mouse pointer
  #   Y - y-coordinate of the mouse pointer

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  set popm $wtree.popup
  catch {destroy $popm}
  menu $popm -tearoff 0
  set sname [lindex [$wtree item $ID -values] 0]
  if {[string length $sname]>25} {set sname "[string range $sname 0 21]..."}
  set msgsel [string map [list %t $sname] $al(MC,selfavor)]
  if {$al(FAV,IsFavor)} {
    set img alimg_misc
    set lab $al(MC,lastvisit)
  } else {
    set img alimg_heart
    set lab $al(MC,favorites)
  }
  $popm add command -label $lab {*}[$obPav iconA none] \
    -command alited::favor::SwitchFavVisit -image $img
  $popm add separator
  if {$al(FAV,IsFavor)} {
    $popm add command -label $al(MC,FavLists) {*}[$obPav iconA none] \
      -command ::alited::favor::Lists -image alimg_heart
    $popm add separator
    $popm add command -label $al(MC,favoradd) {*}[$obPav iconA none] \
      -command {::alited::favor::Add no} -image alimg_add
  }
  $popm add command -label $al(MC,favordel) {*}[$obPav iconA none] \
    -command {::alited::favor::Delete no} -image alimg_delete
  $popm add command -label $al(MC,favordelall) {*}[$obPav iconA none] \
    -command {::alited::favor::DeleteAll no} -image alimg_trash
  $popm add separator
  $popm add command -label $al(MC,copydecl) {*}[$obPav iconA none] \
    -command "::alited::favor::CopyDeclaration $wtree $ID"
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}
#_______________________

proc favor::PopupMenu {x y X Y} {
  # Prepares and runs a popup menu at clicking Favorites / last visited list.
  #   x - x-coordinate to identify tree item
  #   y - y-coordinate to identify tree item
  #   X - x-coordinate of the mouse pointer
  #   Y - y-coordinate of the mouse pointer

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  set ID [$wtree identify item $x $y]
  if {![$wtree exists $ID]} return
  if {[set sel [$wtree selection]] ne {}} {
    $wtree selection remove $sel
  }
  $wtree selection add $ID
  ShowPopupMenu $ID $X $Y
}

# ________________________ Tips _________________________ #

proc favor::CopyDeclaration {wtree ID} {
  # Copies a current unit's declaration to the clipboard.
  #   wtree - tree widget's path
  #   ID - tree item's ID

  clipboard clear
  clipboard append [lindex [$wtree item $ID -values] 2]
}
#_______________________

proc favor::TooltipOff {} {
  # Removes a tip of favorite / last visited unit's declaration.

  namespace upvar ::alited al al obPav obPav
  variable tipID
  ::baltip hide $al(WIN)
  set tipID {}
}
#_______________________

proc favor::Tooltip {x y X Y} {
  # Shows a tip of favorite / last visited unit's declaration.
  #   x - x-coordinate to identify tree item
  #   y - y-coordinate to identify tree item
  #   X - x-coordinate of the mouse pointer
  #   Y - y-coordinate of the mouse pointer

  namespace upvar ::alited al al obPav obPav
  variable tipID
  set wtree [$obPav TreeFavor]
  if {[$wtree identify region $x $y] ni {tree cell}} {
    TooltipOff
    return
  }
  set ID [$wtree identify item $x $y]
  if {[$wtree exists $ID] && $tipID ne $ID} {
    lassign [$wtree bbox $ID] x2 y2 w2 h2
    incr X 10
    if {[catch {incr Y [expr {$y2-$y+$h2}]}]} {incr Y 10}
    set decl [lindex [$wtree item $ID -values] 2]
    set fname [lindex [$wtree item $ID -values] 1]
    append tip $decl \n $fname
    set msec [clock milliseconds]
    if {![info exists al(FAVORTIP_MSEC)]} {
      set al(FAVORTIP_MSEC) 0
    }
    if {($msec-$al(FAVORTIP_MSEC))>200} {
      ::baltip tip $al(WIN) $tip -geometry +$X+$Y -per10 4000 -pause 5 -fade 5
      set tipID $ID
    } else {
      TooltipOff
    }
    set al(FAVORTIP_MSEC) $msec
  }
}

# ________________________ Initialization _________________________ #

proc favor::_init {} {
  # Initializes and shows favorite / last visited units' view.

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav TreeFavor]
  alited::tree::AddTags $wtree
  $wtree tag bind tagNorm <Return> {::alited::favor::Select}
  $wtree tag bind tagNorm <ButtonRelease-1> {::alited::favor::Select}
  $wtree tag bind tagNorm <ButtonPress-3> {after idle {alited::favor::PopupMenu %x %y %X %Y}}
  $wtree tag bind tagNorm <Motion> {after idle {alited::favor::Tooltip %x %y %X %Y}}
  bind $wtree <Leave> {alited::favor::TooltipOff}
  $wtree heading #1 -text [msgcat::mc $al(MC,favorites)]
  ShowFavVisit
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG