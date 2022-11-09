###########################################################
# Name:    tree.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/23/2021
# Brief:   Handles unit/file tree procedures.
# License: MIT.
###########################################################

# ________________________ Variables _________________________ #

namespace eval tree {
  variable doFocus yes  ;# flag "set focus on a text"
  variable tipID {}     ;# tree ID with shown tip
}

# ________________________ Common _________________________ #

proc tree::SwitchTree {} {
  # Switches trees - units to files and vice versa.

  namespace upvar ::alited al al obPav obPav
  if {[set al(TREE,isunits) [expr {!$al(TREE,isunits)}]]} {
    unset al(widthPanBM)  ;# the variable used to save the panel's size
    [$obPav PanL] add [$obPav FraFV]
    RecreateTree
  } else {
    set al(widthPanBM) [winfo geometry [$::alited::obPav PanBM]]
    [$obPav PanL] forget [$obPav FraFV]
    set al(TREE,files) no
    Create
  }
  alited::main::FocusText
  update idletasks
}
#_______________________

proc tree::MoveItem {to {f1112 no}} {
  # Moves items of the tree (units or files)
  #   to - direction ("up" or "down")
  #   f1112 - true, if started by keypressing (false, if by mouse)

  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits) && [alited::file::MoveExternal $f1112]} return
  set wtree [$obPav Tree]
  set itemID [$wtree selection]
  if {$itemID eq {}} {
    set itemID [$wtree focus]
  }
  if {$itemID eq {}} {
    if {$f1112} {set geo {}} {set geo {-geometry pointer+10+10}}
    alited::Message {No item selected.} 4
    return
  }
  if {$al(TREE,isunits)} {
    alited::unit::MoveUnits $wtree $to $itemID $f1112
  } else {
    alited::file::MoveFiles $wtree $to $itemID $f1112
  }
}
#_______________________

proc tree::OpenFile {{ID ""}} {
  # Opens file at clicking a file tree's item.
  #   ID - ID of unit tree

  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits)} {
    set wtree [$obPav Tree]
    if {$ID eq {}} {
      if {[set ID [$wtree selection]] eq {}} return
    }
    lassign [$wtree item $ID -values] -> fname isfile
    if {$isfile} {
      if {[set TID [alited::bar::FileTID $fname]] eq {}} {
        alited::file::OpenFile $fname
      } else {
        alited::bar::BAR $TID show
      }
      alited::bar::BAR draw
      alited::tree::UpdateFileTree
    }
  }
}
#_______________________

proc tree::CurrentItemByLine {{pos ""} {fullinfo no}} {
  # Gets item ID of unit tree for a current text position.
  #   pos - the current text position
  #  fullinfo - if yes, returns a full info for the found ID.

  namespace upvar ::alited al al
  if {$pos eq {}} {
    set pos [[alited::main::CurrentWTXT] index insert]
  }
  set l [expr {int($pos)}]
  set TID [alited::bar::CurrentTabID]
  set L 0
  set R [llength $al(_unittree,$TID)]
  while {$L<$R} {
    set m [expr {int(($L+$R)/2)}]
    lassign [lindex $al(_unittree,$TID) $m] lev leaf fl1 title l1 l2 ID
    if {$l2<$l} {
      set L [incr m]
    } elseif {$l1>$l} {
      set R $m
    } else {
      if {$fullinfo} {
        return [list $ID $lev $leaf $fl1 $title $l1 $l2]
      }
      return $ID
    }
  }
  return {}
}
#_______________________

proc tree::CurrentItem {{Tree Tree}} {
  # Gets ID of selected item of the tree.
  #   Tree - the tree widget's name

  namespace upvar ::alited obPav obPav
  set wtree [$obPav $Tree]
  set it [$wtree focus]
  if {$it eq {}} {set it [lindex [$wtree selection] 0]}
  return $it
}
#_______________________

proc tree::AddTagSel {wtree ID} {
  # Adds tagSel tag to the unit tree's item.
  #   wtree - the tree's path
  #   ID - the item's ID

  if {![$wtree tag has tagTODO $ID]} {
    $wtree tag add tagSel $ID
  }
}
#_______________________

proc tree::NewSelection {{itnew ""} {line 0} {topos no}} {
  # Selects a new item of the unit tree.
  #   itnew - ID of the new selected item
  #   line - a relative line number inside the item or an absolute position in the text
  #   topos - if yes, 'line' is an absolute position in the text
  # Returns ID of the newly selected item.

  namespace upvar ::alited al al obPav obPav
  variable doFocus
  set TID [alited::bar::CurrentTabID]
  set wtxt [alited::main::CurrentWTXT]
  set ctab [alited::bar::CurrentTabID]
  set wtree [$obPav Tree]
  # newly selected item
  if {$itnew eq {}} {
    if {$topos} {
      set itnew [CurrentItemByLine $line]
    } else {
      set itnew [CurrentItem]
    }
  }
  set header [alited::unit::GetHeader $wtree $itnew]
  lassign [$wtree item $itnew -values] l1 l2 - - - leaf
  if {[string is true -strict $leaf]} {
    AddTagSel $wtree $itnew
  }
  # get saved pos
  if {[info exists al(CPOS,$ctab,$header)]} {
    set pos [alited::p+ $l1 $al(CPOS,$ctab,$header)]
  } else {
    set pos [$wtxt index insert]
  }
  if {$topos} {
    set pos $line
  } elseif {[string is digit -strict $l1] && [string is digit -strict $l2]} {
    if {[string is double -strict $line] && $line != 0 && \
    $l1<($l1+$line) && ($l1+$line)<($l2+1)} {
      # it's coming from a saved favorite item
      set pos [expr {$l1+$line}]
    } else {
      if {$pos<$l1 || $pos>=($l2+1)} {
        # if not saved, get it from 1st line
        set pos $l1.0
      }
    }
  }
  # previously selected item
  lassign [alited::bar::BAR cget --currSelTab --currSelItem] otab itold
  if {$itold ne "" && ![catch {lassign [$wtree item $itold -values] o1 o2}]} {
    # if there was the previously selected item, save its cursor position
    catch {
      # -values at files' tree is invalid for this => 'catch'
      # (then pos=saved position for the whole file, got from --pos)
      set opos [$wtxt index insert]
      if {$o1<=$opos && $opos<($o2+1)} {
        set ohead [alited::unit::GetHeader $wtree $itold]
        set al(CPOS,$otab,$ohead) [alited::p+ $opos -$o1]
      }
    }
  }
  alited::bar::BAR configure --currSelTab $ctab --currSelItem $itnew
  catch {set al(CPOS,$ctab,$header) [alited::p+ $pos -$l1]}
  if {$doFocus} {
    alited::main::FocusText $TID $pos
  }
  if {$al(TREE,isunits) && $al(dolastvisited)} {
    alited::favor::LastVisited [$wtree item $itnew] $header
  }
  alited::main::UpdateGutter
  return $itnew
}
#_______________________

proc tree::SaveCursorPos {} {
  # Saves current unit's cursor position.
  # See also: favor::GoToUnit

  namespace upvar ::alited al al obPav obPav
  set TID [alited::bar::CurrentTabID]
  set wtxt [alited::main::CurrentWTXT]
  set pos [$wtxt index insert]
  # catch is needed at creating text, as the tree doesn't exist
  catch {
    set itnew [CurrentItemByLine $pos]
    set wtree [$obPav Tree]
    set header [alited::unit::GetHeader $wtree $itnew]
    # save the position to unit tree list, to restore it in favor::GoToUnit
    set it [lsearch -exact -index 6 $al(_unittree,$TID) $itnew]
    if {$it>-1} {
      set item [lindex $al(_unittree,$TID) $it]
      set item [lreplace $item 7 7 $pos]
      set al(_unittree,$TID) [lreplace $al(_unittree,$TID) $it $it $item]
    }
  }
  return $pos
}
#_______________________

proc tree::SeeSelection {} {
  # Sees (makes visible) a current selected item in the tree.

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set selection [$wtree selection]
  if {[llength $selection]==1} {$wtree see $selection}
}
#_______________________

proc tree::syOption {sy} {
  # Gets -geometry option of dialogues.
  #   sy - relative Y-coordinate of dialogue
  # See also: unit::Delete, file::Delete

  if {$sy eq {}} {
    set opt {}
  } else {
    set opt [list -geometry pointer+10+$sy]
  }
  return $opt
}

# ________________________ Create and handle a tree _________________________ #

proc tree::Create {} {
  # Creates a tree of units/files, at need.
  # See also: CreateFilesTree

  namespace upvar ::alited al al obPav obPav
  if {$al(TREE,isunits) && $al(TREE,units) \
  || !$al(TREE,isunits) && $al(TREE,files)} return  ;# no need
  set wtree [$obPav Tree]
  if {!$al(TREE,isunits)} {
    pack [$obPav BtTRenT] -side left -after [$obPav BtTAddT]  ;# display 'Rename' button
    # for file tree: get its current "open branch" flags
    # in order to check them in CreateFilesTree
    set al(SAVED_FILE_TREE) [list]
    foreach item [GetTree] {
      lassign $item - - ID - values
      lassign $values -> fname isfile
      if {[string is false -strict $isfile]} {
        lappend al(SAVED_FILE_TREE) [list $fname [$wtree item $ID -open]]
      }
    }
  } else {
    pack forget [$obPav BtTRenT] ;# hide 'Rename' button
  }
  set TID [alited::bar::CurrentTabID]
  Delete $wtree {} $TID
  AddTags $wtree
  $wtree tag bind tagNorm <ButtonPress> {after idle {alited::tree::ButtonPress %b %x %y %X %Y}}
  $wtree tag bind tagNorm <ButtonRelease> {after idle {alited::tree::ButtonRelease %b %s %x %y %X %Y}}
  $wtree tag bind tagNorm <Motion> {after idle {alited::tree::ButtonMotion %b %s %x %y %X %Y}}
  bind $wtree <ButtonRelease> {alited::tree::DestroyMoveWindow no}
  bind $wtree <Leave> {alited::tree::DestroyMoveWindow yes}
  bind $wtree <F2> {alited::file::RenameFileInTree 0 -}
  bind $wtree <Insert> {alited::tree::AddItem}
  bind $wtree <Delete> {alited::tree::DelItem {} {}}
  if {$al(TREE,isunits)} {
    CreateUnitsTree $TID $wtree
  } else {
    CreateFilesTree $wtree
  }
}
#_______________________

proc tree::UnitTitle {title l1 l2} {
  # Gets a title of a unit (checking for empty string).
  #   title - original title
  #   l1 - first line of the unit
  #   l2 - latst line of the unit

  if {$title eq {}} {set title "$alited::al(MC,lines) $l1-$l2"}
  return $title
}
#_______________________

proc tree::CreateUnitsTree {TID wtree} {
  # Creates a unit tree for a tab.
  #   TID - a current tab's ID
  #   wtree - the tree's path

  namespace upvar ::alited al al obPav obPav
  set al(TREE,units) yes
  [$obPav BtTswitch] configure -image alimg_folder
  baltip::tip [$obPav BtTswitch] $al(MC,swunits)
  baltip::tip [$obPav BtTAddT] $al(MC,tpllist)
  baltip::tip [$obPav BtTDelT] $al(MC,unitsdel)
  baltip::tip [$obPav BtTUp] $al(MC,moveupU)
  baltip::tip [$obPav BtTDown] $al(MC,movedownU)
  $al(MENUEDIT) entryconfigure 0 -label $al(MC,moveupU)
  $al(MENUEDIT) entryconfigure 1 -label $al(MC,movedownU)
  $wtree heading #0 -text [alited::bar::CurrentTab 1]
  $wtree heading #1 -text [msgcat::mc Row]
  set ctab [alited::bar::CurrentTabID]
  set parents [list {}]
  set parent {}
  set levprev -1
  set wtxt [alited::main::GetWTXT $TID]
  set todolist [list]
  foreach {tr1 tr2} [$wtxt tag ranges tagCMN2] {
    lappend todolist [expr {int($tr1)}]
  }
  $wtree tag remove tagTODO
  $wtree tag remove tagBranch
  $wtree tag remove tagSel
  foreach item $al(_unittree,$TID) {
    if {[llength $item]<3} continue
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev leaf fl1 title l1 l2
    set title [UnitTitle $title $l1 $l2]
    set lev [expr {min($lev,[llength $parents])}]
    set parent [lindex $parents [expr {$lev-1}]]
    if {$leaf} {
      set title " $title"
      set pr [expr {max(0,min(7,($l2-$l1-$alited::al(minredunit))/$al(prjredunit)))}]
      set imgopt "-image alimg_pro$pr"
    } else {
      set imgopt "-image alimg_gulls"
    }
    set tag tagNorm
    foreach tr $todolist {
      if {$tr>=$l1 && $tr<=$l2} {
        set tag tagTODO
        break
      }
    }
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $l1 $l2 {} $itemID $lev $leaf $fl1] -open yes {*}$imgopt
    $wtree tag add tagNorm $itemID
    catch {
      if {$leaf && \
      [info exists al(CPOS,$ctab,[alited::unit::GetHeader $wtree $itemID])]} {
        if {$tag ne {tagTODO}} {set tag tagSel}
      }
    }
    if {!$leaf} {
      if {$tag ne {tagTODO}} {set tag tagBranch}
      set parent $itemID
      catch {set parents [lreplace $parents $lev end $parent]}
    }
    if {$tag ne {tagNorm}} {
      $wtree tag add $tag $itemID
    }
    set levprev $lev
  }
}
#_______________________

proc tree::CreateFilesTree {wtree} {
  # Creates a file tree.
  #   wtree - the tree's path

  namespace upvar ::alited al al obPav obPav
  set al(TREE,files) yes
  [$obPav BtTswitch] configure -image alimg_gulls
  baltip::tip [$obPav BtTswitch] $al(MC,swfiles)
  baltip::tip [$obPav BtTAddT] $al(MC,filesadd)
  baltip::tip [$obPav BtTDelT] $al(MC,filesdel)
  baltip::tip [$obPav BtTUp] $al(MC,moveupF)
  baltip::tip [$obPav BtTDown] $al(MC,movedownF)
  $al(MENUEDIT) entryconfigure 0 -label $al(MC,moveupF)
  $al(MENUEDIT) entryconfigure 1 -label $al(MC,movedownF)
  $wtree heading #0 -text ":: [file tail $al(prjroot)] ::"
  $wtree heading #1 -text $al(MC,files)
  bind $wtree <Return> {::alited::tree::OpenFile}
  set selID ""
  if {[catch {set selfile [alited::bar::FileName]}]} {
    set selfile {} ;# at closing by Ctrl+W with file tree open: no current file
  }
  foreach item [GetDirectoryContents $al(prjroot)] {
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev isfile fname fcount iroot
    if {$selfile eq $fname} {set selID $itemID}
    set title [file tail $fname]
    if {$iroot<0} {
      set parent {}
    } else {
      set parent [alited::tree::NewItemID [incr iroot]]
    }
    set isopen no
    if {$isfile} {
      if {[alited::file::IsTcl $fname]} {
        set imgopt {-image alimg_tclfile}
      } else {
        set imgopt {-image alimg_file}
      }
    } else {
      set imgopt {-image alimg_folder}
      # get the directory's flag of expanded branch (in the file tree)
      set idx [lsearch -index 0 -exact $al(SAVED_FILE_TREE) $fname]
      if {$idx>-1} {
        set isopen [lindex $al(SAVED_FILE_TREE) $idx 1]
      }
    }
    if {$fcount} {set fc $fcount} {set fc {}}
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $fc $fname $isfile $itemID] -open $isopen {*}$imgopt
    $wtree tag add tagNorm $itemID
    if {!$isfile} {
      $wtree tag add tagBranch $itemID
    } elseif {[alited::bar::FileTID $fname] ne {}} {
      $wtree tag add tagSel $itemID
    }
  }
  if {$selID ne {}} {
    $wtree see $selID
    $wtree selection set $selID
  }
}
#_______________________

proc tree::NewItemID {iit} {
  # Gets a new ID for the tree item.
  #   iit - index of the new item.

  return "al$iit"
}
#_______________________

proc tree::AddTags {wtree} {
  # Creates tags for the tree.
  #   wtree - the tree's path

  namespace upvar ::alited al al
  lassign [::hl_tcl::addingColors {} -AddTags] - - fgbr - - fgred - - - fgtodo
  append fontN "-font $alited::al(FONT,defsmall)"
  append fontS $fontN " -foreground $fgred"
  $wtree tag configure tagNorm {*}$fontN
  $wtree tag configure tagSel  {*}$fontS
  $wtree tag configure tagBold -foreground magenta
  $wtree tag configure tagTODO -foreground $fgtodo
  $wtree tag configure tagBranch -foreground $fgbr
}
#_______________________

proc tree::AddItem {{ID ""}} {
  # Adds a new item to the tree.
  #   ID - an item's ID where the new item will be added (for the file tree).

  namespace upvar ::alited al al
  if {$al(TREE,isunits)} {
    alited::unit::Add
  } else {
    alited::file::Add $ID
  }
}
#_______________________

proc tree::DelItem {{ID ""} {sy 10}} {
  # Removes an item from the tree.
  #   ID - an item's ID to be deleted.
  #   sy - relative Y-coordinate for a query

  namespace upvar ::alited al al obPav obPav
  if {$ID eq {} && [set ID [alited::tree::CurrentItem]] eq {}} {
    bell
    return
  }
  set wtree [$obPav Tree]
  set fname [alited::bar::FileName]
  if {$al(TREE,isunits)} {
    alited::unit::Delete $wtree $fname $sy
  } else {
    alited::file::Delete $ID $wtree $sy
  }
}
#_______________________

proc tree::Delete {wtree item TID} {
  # Removes recursively an item and its children from the tree.
  #   wtree - the tree widget's path
  #   item - ID of the item to be deleted.

  foreach child [$wtree children $item] {
    alited::tree::Delete $wtree $child $TID
  }
  if {$item ne {}} {$wtree delete $item}
}
#_______________________

proc tree::AdjustWidth {} {
  # Fixes a problem with the tree scrollbar's width at resizing the panes.
  # The problem occurs if Frame's width is less than Tree's + Scrollbar's, as
  # then the scrollbar is squeezed. Thus the Tree's width should be adjusted.
  # The restart of alited will fully repair this.

  namespace upvar ::alited al al obPav obPav
  set wpf [winfo width [$obPav FraTree]]
  set ws1 [winfo width [$obPav SbvTree]]
  set ws2 [winfo width [$obPav SbvFavor]]
  set w2 [[$obPav Tree] column #1 -width]
  [$obPav Tree] column #0 -width [expr {$wpf-$w2-$ws2-4}]
}

# ________________________ Buttons handlers _________________________ #

proc tree::ShowPopupMenu {ID X Y} {
  # Creates and opens a popup menu at right clicking the tree.
  #   ID - ID of clicked item
  #   X - x-coordinate of the click
  #   Y - y-coordinate of the click

  namespace upvar ::alited al al obPav obPav
  ::baltip sleep 1000
  set wtree [$obPav Tree]
  set popm $wtree.popup
  catch {destroy $popm}
  menu $popm -tearoff 0
  set header [lindex [split [alited::unit::GetHeader $wtree $ID] \n] 0]
  set sname [$wtree item $ID -text]
  lassign [$wtree item $ID -values] -> fname isfile - - isunit
  if {$al(TREE,isunits)} {
    set img alimg_folder
    set m1 $al(MC,swunits)
    set m2 $al(MC,tpllist)
    set m3 $al(MC,unitsdel)
    set moveup $al(MC,moveupU)
    set movedown $al(MC,movedownU)
    set dropitem [msgcat::mc {Drop Selected Units Here}]
  } else {
    set img alimg_gulls
    set m1 $al(MC,swfiles)
    set m2 $al(MC,filesadd)
    set m3 $al(MC,filesdel)
    set moveup $al(MC,moveupF)
    set movedown $al(MC,movedownF)
    set dropitem [msgcat::mc {Drop Selected Files Here}]
  }
  if {[string length $sname]>25} {set sname "[string range $sname 0 21]..."}
  $popm add command {*}[$obPav iconA none] -label $m1 \
    -command ::alited::tree::SwitchTree -image $img
  $popm add command {*}[$obPav iconA none] -label $al(MC,updtree) \
    -command alited::tree::RecreateTree -image alimg_retry
  $popm add separator
  $popm add command {*}[$obPav iconA none] -label $moveup \
    -accelerator F11 -command {::alited::tree::MoveItem up} -image alimg_up
  $popm add command {*}[$obPav iconA none] -label $movedown \
    -accelerator F12 -command {::alited::tree::MoveItem down} -image alimg_down
  $popm add separator
  $popm add command {*}[$obPav iconA none] -label $m2 \
    -command "::alited::tree::AddItem $ID" -image alimg_add
  if {!$al(TREE,isunits)} {
    $popm add command {*}[$obPav iconA change] \
      -label $al(MC,renamefile) -accelerator F2 \
      -command {::alited::file::RenameFileInTree no}
  }
  $popm add command {*}[$obPav iconA none] -label $m3 \
    -command "::alited::tree::DelItem $ID -100" -image alimg_delete
  if {$al(TREE,isunits)} {
    if {$al(FAV,IsFavor)} {
      $popm add separator
      $popm add command {*}[$obPav iconA heart] -label $al(MC,favoradd) \
        -command ::alited::favor::AddFromTree
    }
    if {$isunit} {
      $popm add separator
      $popm add command {*}[$obPav iconA none] -label $al(MC,copydecl) \
        -command "clipboard clear ; clipboard append {$header}"
    }
  } else {
    if {$isfile} {set fname [file dirname $fname]}
    set sname [file tail $fname]
    $popm add separator
    $popm add command {*}[$obPav iconA OpenFile] -label $al(MC,openselfile) \
      -command ::alited::file::OpenFiles
    set msg [string map [list %n $sname] $al(MC,openofdir)]
    $popm add command {*}[$obPav iconA none] -label $msg \
      -command "::alited::file::OpenOfDir {$fname}"
  }
  set addsel {}
  if {[llength [$wtree selection]]>1} {
    $popm add separator
    $popm add command {*}[$obPav iconA none] -label $dropitem \
      -command "::alited::tree::DropItems $ID" -image alimg_paste
    if {[$wtree tag has tagSel $ID]} {
      # the added tagSel tag should be overrided
      $wtree tag remove tagSel $ID
      set addsel "; $wtree tag add tagSel $ID"
    }
  }
  bind $popm <FocusIn> "$wtree tag add tagBold $ID"
  bind $popm <FocusOut> "catch {$wtree tag remove tagBold $ID; $addsel}"
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}
#_______________________

proc tree::ButtonPress {but x y X Y} {
  # Handles a mouse clicking the tree.
  #   but - mouse button
  #   x - x-coordinate to identify an item
  #   y - y-coordinate to identify an item
  #   X - x-coordinate of the click
  #   Y - x-coordinate of the click

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set ID [$wtree identify item $x $y]
  set region [$wtree identify region $x $y]
  set al(movID) [set al(movWin) {}]
  if {![$wtree exists $ID] || $region ni {tree cell}} {
    return  ;# only tree items are processed
  }
  switch $but {
    {3} {
      if {[llength [$wtree selection]]<2} {
        $wtree selection set $ID
      }
      ShowPopupMenu $ID $X $Y
    }
    {1} {
      set al(movID) $ID
      set al(movWin) .tritem_move
      set msec [clock milliseconds]
      if {$al(TREE,isunits)} {
        NewSelection $ID
        alited::main::SaveVisitInfo
      } else {
        if {[info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]} {
          OpenFile $ID
        }
      }
      set al(_MSEC) $msec
    }
  }
}
#_______________________

proc tree::DropItems {ID} {
  # Drops (moves) selected items to a current position.
  #   ID - ID of an item to be clicked

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set selection [$wtree selection]
  if {[$wtree exists $ID] && $selection ne {} && $ID ne {} && $selection ne $ID} {
    if {$al(TREE,isunits)} {
      alited::unit::MoveUnits $wtree move $selection $ID
    } else {
      alited::file::MoveFiles $wtree move $selection $ID
    }
  }
}
#_______________________

proc tree::SelectUnits {wtree ctrl} {
  # Selects units at Ctrl/Shift clicking the unit tree.
  #   wtree - path to tree widget
  #   ctrl - 1 if pressed Ctrl/Shift key at clicking

  namespace upvar ::alited al al
  if {!$ctrl || !$al(TREE,isunits)} return
  set wtxt [alited::main::CurrentWTXT]
  $wtxt tag remove sel 1.0 end
  foreach ID [$wtree selection] {
    lassign [$wtree item $ID -values] l1 l2
    $wtxt tag add sel $l1.0 [incr l2].0
  }
}
#_______________________

proc tree::ButtonRelease {but s x y X Y} {
  # Handles a mouse button releasing on the tree, at moving an item.
  #   but - mouse button
  #   s - state (ctrl/alt/shift)
  #   x - x-coordinate to identify an item
  #   y - y-coordinate to identify an item
  #   X - x-coordinate of the click
  #   Y - x-coordinate of the click

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set ID [$wtree identify item $x $y]
  DestroyMoveWindow no
  set msec [clock milliseconds]
  set ctrl [expr {$s & 7}]
  if {([info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]) || $ctrl} {
    SelectUnits $wtree $ctrl
    set al(movWin) {}
    return
  }
  if {[$wtree exists $ID] && [info exists al(movID)] && \
  $al(movID) ne {} && $ID ne {} && $al(movID) ne $ID && \
  [$wtree identify region $x $y] eq {tree}} {
    if {$al(TREE,isunits)} {
      alited::unit::MoveUnits $wtree move $al(movID) $ID
    } else {
      alited::file::MoveFiles $wtree move $al(movID) $ID
    }
  }
  DestroyMoveWindow yes
}
#_______________________

proc tree::ButtonMotion {but s x y X Y} {
  # Starts moving an item of the tree.
  #   but - mouse button
  #   s - state (ctrl/alt/shift)
  #   x - x-coordinate to identify an item
  #   y - y-coordinate to identify an item
  #   X - x-coordinate of the click
  #   Y - x-coordinate of the click

  namespace upvar ::alited al al obPav obPav
  if {![info exists al(movWin)] || $al(movWin) eq {}} {
    return
  }
  if {$s & 7} {
    set al(movWin) {}
    return
  }
  set wtree [$obPav Tree]
  # dragging the tab
  if {![winfo exists $al(movWin)]} {
    # make the tab's replica to be dragged
    toplevel $al(movWin)
    if {$al(IsWindows)} {
      wm attributes $al(movWin) -alpha 0.0
    } else {
      wm withdraw $al(movWin)
    }
    if {[tk windowingsystem] eq {aqua}} {
      ::tk::unsupported::MacWindowStyle style $al(movWin) help none
    } else {
      wm overrideredirect $al(movWin) 1
    }
    set selection [$wtree selection]
    if {[set il [llength $selection]]>1} {
      set al(movID) $selection
      set text "$il items"
    } else {
      set text [$wtree item $al(movID) -text]
    }
    label $al(movWin).label -text $text -relief solid -foreground black -background #7eeeee
    pack $al(movWin).label -expand 1 -fill both -ipadx 1
  }
  set ID [$wtree identify item $x $y]
  wm geometry $al(movWin) +[expr {$X+10}]+[expr {$Y+10}]
  if {$al(IsWindows)} {
    if {[wm attributes $al(movWin) -alpha] < 0.1} {wm attributes $al(movWin) -alpha 1.0}
  } else {
    catch {wm deiconify $al(movWin) ; raise $al(movWin)}
  }
}
#_______________________

proc tree::DestroyMoveWindow {cancel} {
  # Destroys an item moving window.
  #   cancel - if yes, clears also the related variables.

  namespace upvar ::alited al al
  catch {destroy $al(movWin)}
  if {$cancel} {lassign {} al(movWin) al(movID)}
}
#_______________________

proc tree::GetTooltip {ID NC} {
  # Gets a tip for unit / file tree's item.
  #   ID - ID of treeview item
  #   NC - column of treeview item

  namespace upvar ::alited al al obPav obPav
  if {[info exists al(movWin)] && $al(movWin) ne {}} {
    # no tips while drag-n-dropping
    return {}
  }
  set wtree [$obPav Tree]
  if {$al(TREE,isunits)} {
    # for units
    set tip [alited::unit::GetHeader $wtree $ID $NC]
    # try to read and add TODOs for this unit
    catch {
      lassign [$wtree item $ID -values] l1 l2
      set wtxt [alited::main::CurrentWTXT]
      foreach {p1 p2} [$wtxt tag ranges tagCMN2] {
        if {[$wtxt compare $l1.0 <= $p1] && [$wtxt compare $p2 <= $l2.end]} {
          set todo [string trimleft [$wtxt get $p1 $p2] {#!}]
          switch [incr tiplines] {
            1  {append tip \n_______________________\n}
            13 {break}
          }
          append tip \n $todo
        }
      }
    }
    if {!$al(TIPS,Tree) && ![info exists todo]} {
      # no tips while switched off (excepting for TODOs)
      return {}
    }
  } else {
    # for files
    lassign [$wtree item $ID -values] -> tip isfile
    if {$isfile} {
      if {$al(TREE,showinfo)} {
        set tip [alited::file::FileStat $tip]
      } else {
        set tip {}
      }
    }
  }
  return $tip
}

# ________________________ Directories procs _________________________ #

proc tree::GetDirectoryContents {dirname} {
  # Gets a directory's contents.
  #   dirname - the directory's name
  # Returns a list containing the directory's contents.
  # See also:
  #   DirContents

  namespace upvar ::alited al al
  set al(_dirtree) [set al(_dirignore) [list]]
  catch {    ;# there might be an incorrect list -> catch it
    foreach d $al(prjdirign) {
      lappend al(_dirignore) [string toupper [string trim $d \"]]
    }
  }
  lappend al(_dirignore) [string toupper [file tail [alited::Tclexe]]]
  DirContents $dirname
  return $al(_dirtree)
}
#_______________________

proc tree::DirContents {dirname {lev 0} {iroot -1} {globs "*"}} {
  # Reads a directory's contents.
  #   dirname - a dirtectory's name
  #   lev - level in the directory hierarchy
  #   iroot - index of the directory's parent or -1
  #   globs - list of globs to filter files.
  # See also:
  #   GetDirectoryContents
  #   AddToDirContents

  namespace upvar ::alited al al
  incr lev
  if {[catch {set dcont [lsort -dictionary [glob [file join $dirname *]]]}]} {
    set dcont [list]
  }
  # firstly directories:
  # 1. skip the ignored ones
  for {set i [llength $dcont]} {$i} {} {
    incr i -1
    if {[IgnoredDir [lindex $dcont $i]]} {
      set dcont [lreplace $dcont $i $i]
    }
  }
  # 2. put the directories to the beginning of the file list
  set i 0
  foreach fname $dcont {
    if {[file isdirectory $fname]} {
      set dcont [lreplace $dcont $i $i [list $fname "y"]]
      set nroot [AddToDirContents $lev 0 $fname $iroot]
      if {[llength $al(_dirtree)] < $al(MAXFILES)} {
        DirContents $fname $lev $nroot $globs
      } else {
        break
      }
    } else {
      set dcont [lreplace $dcont $i $i [list $fname]]
    }
    incr i
  }
  # then files
  if {[llength $al(_dirtree)] < $al(MAXFILES)} {
    foreach fname $dcont {
      lassign $fname fname d
      if {$d ne "y"} {
        foreach gl [split $globs ","] {
          if {[string match $gl $fname]} {
            AddToDirContents $lev 1 $fname $iroot
            break
          }
        }
      }
    }
  }
}
#_______________________

proc tree::AddToDirContents {lev isfile fname iroot} {
  # Adds an item to a list of directory's contents.
  #   lev - level in the directory hierarchy
  #   isfile - a flag "file" (if yes) or "directory" (if no)
  #   fname - a file name to be added
  #   iroot - index of the directory's parent or -1

  namespace upvar ::alited al al
  set dllen [llength $al(_dirtree)]
  if {$dllen < $al(MAXFILES)} {
    lappend al(_dirtree) [list $lev $isfile $fname 0 $iroot]
    if {$iroot>-1} {
      lassign [lindex $al(_dirtree) $iroot] lev isfile fname fcount sroot
      set al(_dirtree) [lreplace $al(_dirtree) $iroot $iroot \
        [list $lev $isfile $fname [incr fcount] $sroot]]
    }
  }
  return $dllen
}
#_______________________

proc tree::IgnoredDir {dir} {
  # Checks if a directory is in the list of the ignored ones.
  #   dir - the directory's name

  namespace upvar ::alited al al
  set dir [string toupper [file tail $dir]]
  return [expr {[lsearch -exact $al(_dirignore) $dir]>-1}]
}

# ________________________ Tree procs _________________________ #

proc tree::ForEach {wtree aproc {lev 0} {branch {}}} {
  # Scans all items of the tree.
  #   wtree - the tree's path
  #   aproc - a procedure to run at scanning
  #   lev - level of the tree
  #   branch - ID of the branch to be scanned
  # The 'aproc' argument can include wildcards to be replaced
  # appropriate data:
  #    %level - current tree level
  #    %children - children of a current item
  #    %item - ID of a current item
  #    %text - text of a current item
  #    %values - values of a current item

  set children [$wtree children $branch]
  if {$lev} {
    set proc [string map [list \
      %level $lev \
      %children [llength $children] \
      %item $branch \
      %text [$wtree item $branch -text] \
      %values [$wtree item $branch -values]] \
      $aproc]
    uplevel [expr {$lev+1}] "$proc"
  }
  incr lev
  foreach child $children {
    ForEach $wtree $aproc $lev $child
  }
}
#_______________________

proc tree::GetTree {{parent {}} {Tree Tree}} {
  # Gets a tree or its branch.
  #   parent - ID of the branch
  #   Tree - name of the tree widget

  namespace upvar ::alited obPav obPav
  set wtree [$obPav $Tree]
  set tree [list]
  set levp -1
  ForEach $wtree {
    set item "%item"
    set lev %level
    if {$levp>-1 || $item eq $parent} {
      if {$lev<=$levp} {return -code break}  ;# all of branch fetched
      if {$item eq $parent} {set levp $lev}
    }
    catch {
      if {$parent eq {} || $levp>-1} {
        lappend tree [list $lev %children $item {%text} {%values}]
      }
    }
  }
  return $tree
}
#_______________________

proc tree::ExpandContractTree {Tree {isexp yes}} {
  # Expands or contracts the tree.
  #   Tree - the tree's name
  #   isexp - yes, if to expand; no, if to contract

  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav $Tree]
  foreach item [GetTree {} $Tree] {
    lassign $item lev cnt ID
    if {[llength [$wtree children $ID]]} {
      $wtree item $ID -open $isexp
    }
  }
}
#_______________________

proc tree::RecreateTree {{wtree ""} {headers ""}} {
  # Recreates the tree and restores its selections.
  #   wtree - the tree's path
  #   headers - a list of selected items

  namespace upvar ::alited al al obPav obPav
  if {$wtree eq {}} {set wtree [$obPav Tree]}
  if {[catch {set selection [$wtree selection]}]} {set selection [list]}
  if {$al(TREE,isunits)} {
    set al(TREE,units) no
    set TID [alited::bar::CurrentTabID]
    set wtxt [alited::main::CurrentWTXT]
    set al(_unittree,$TID) [alited::unit::GetUnits $TID [$wtxt get 1.0 {end -1 char}]]
  } else {
    set al(TREE,files) no
  }
  Create
  # restore selections
  if {$headers ne {}} {
    set selection [list]
    foreach item [alited::tree::GetTree] {
      lassign $item lev cnt ID
      foreach hd $headers {
        if {[alited::unit::GetHeader $wtree $ID] eq $hd} {
          lappend selection $ID
          break
        }
      }
    }
    $wtree selection set $selection
  } else {
    # try to restore selections
    foreach item $selection {
      catch {$wtree selection add $item}
    }
  }
  catch {$wtree see [lindex $selection 0]}
  #  alited::main::SaveVisitInfo
}
#_______________________

proc tree::UpdateFileTree {{doit no}} {
  # Updates the file tree (colors of files).
  #   doit - yes, if run after idle
  # See also: CreateFilesTree

  namespace upvar ::alited al al obPav obPav
  if {$al(TREE,isunits)} return  ;# no need
  if {$doit} {
    set wtree [$obPav Tree]
    foreach item [GetTree {} Tree] {
      lassign [lindex $item 4] - fname leaf itemID
      if {$leaf} {
        if {[alited::bar::FileTID $fname] ne {}} {
          $wtree tag add tagSel $itemID
        } else {
          $wtree tag remove tagSel $itemID
        }
      }
    }
  } else {
    catch {after cancel $al(_UPDATEFILETREE_)}
    set al(_UPDATEFILETREE_) [after idle {alited::tree::UpdateFileTree yes}]
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
