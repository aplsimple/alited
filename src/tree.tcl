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
    SeeUnit
  } else {
    set al(widthPanBM) [winfo geometry [$::alited::obPav PanBM]]
    [$obPav PanL] forget [$obPav FraFV]
    set al(TREE,files) no
    Create
    SeeFile [alited::bar::FileName]
  }
  IconContract
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
      alited::file::OpenFile $fname
      after idle {alited::bar::BAR draw; alited::tree::UpdateFileTree}
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

proc tree::CurrentItem {{Tree Tree} {wtree ""}} {
  # Gets ID of selected item of the tree.
  #   Tree - the tree widget's name
  #   wtree - full path to the tree

  namespace upvar ::alited obPav obPav
  if {$wtree eq {}} {set wtree [$obPav $Tree]}
  set it [$wtree focus]
  if {$it eq {}} {set it [lindex [$wtree selection] 0]}
  return $it
}
#_______________________

proc tree::AddTagSel {wtree ID} {
  # Adds tagSel tag to the unit tree's item.
  #   wtree - the tree's path
  #   ID - the item's ID

  set leaf [lindex [$wtree item $ID -values] 5]
  if {[string is true -strict $leaf] && ![$wtree tag has tagTODO $ID]} {
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
  lassign [$wtree item $itnew -values] l1 l2
  AddTagSel $wtree $itnew
  # get saved pos
  set issaved [info exists al(CPOS,$ctab,$header)]
  if {$issaved} {
    set pos [::apave::p+ $l1 $al(CPOS,$ctab,$header)]
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
        # if not saved, get it from 1st line or TODO
        set pos $l1.0
        if {!$issaved} {
          foreach {ltd1 ltd2} [$wtxt tag ranges tagCMN2] {
            if {$ltd1>=$l1 && $ltd1<=$l2} {
              set pos $ltd1
              break
            }
          }
        }
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
        set al(CPOS,$otab,$ohead) [::apave::p+ $opos -$o1]
      }
    }
  }
  alited::bar::BAR configure --currSelTab $ctab --currSelItem $itnew
  catch {set al(CPOS,$ctab,$header) [::apave::p+ $pos -$l1]}
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

# ________________________ Expand/contract tree _________________________ #

proc tree::IconContract {} {
  # Sets "Contract All" toolbar action's icon.

  namespace upvar ::alited obPav obPav
  if {[IsExpandedTree]} {
    set ico alimg_minus
  } else {
    set ico alimg_actions
  }
  [$obPav PanL].fraBot.panBM.fraTree.fra1.btTCtr configure -image $ico
}
#_______________________

proc tree::IsExpandUT {{fname ""}} {
  # Gets a flag "expanding unit tree of text".
  #   fname - file name

  namespace upvar ::alited al al
  if {$fname eq {}} {set fname [alited::bar::FileName]}
  expr {![dict exists $al(expandUT) $fname] || [dict get $al(expandUT) $fname]}
}
#_______________________

proc tree::ExpandedTree {isexp} {
  # Sets expanded mode of tree.
  #   isexp - new mode

  namespace upvar ::alited al al
  if {$al(TREE,isunits)} {
    dict set al(expandUT) [alited::bar::FileName] $isexp
  } else {
    set al(expandFT) $isexp
  }
}
#_______________________

proc tree::IsExpandedTree {} {
  # Gets a flag "the tree is in expanded mode".

  namespace upvar ::alited al al
  expr {$al(TREE,isunits) && [IsExpandUT] || !$al(TREE,isunits) && $al(expandFT)}
}
#_______________________

proc tree::ExpandContractTree {Tree {isexp yes}} {
  # Expands or contracts the tree.
  #   Tree - the tree's name
  #   isexp - yes, if to expand; no, if to contract

  namespace upvar ::alited al al obPav obPav
  if {!$isexp && ![IsExpandedTree]} {
    # restore expanded mode without updating tree
    ExpandedTree yes
    IconContract
    return
  }
  set wtree [$obPav $Tree]
  if {$al(TREE,isunits)} {
    set pos [[alited::main::CurrentWTXT] index insert]
    lassign [CurrentItemByLine $pos 1] itemID
  } else {
    set itemID [CurrentItem]
  }
  ExpandedTree $isexp
  IconContract
  set branch [set selbranch {}]
  foreach item [GetTree {} $Tree] {
    lassign $item lev cnt ID
    if {[llength [$wtree children $ID]]} {
      set branch $ID
      $wtree item $ID -open $isexp
    }
    if {$ID eq $itemID} {set selbranch $branch}
  }
  if {$isexp} {
    if {$itemID ne {}} {$wtree selection set $itemID}
    SeeSelection
  } elseif {$selbranch ne {}} {
    $wtree selection set $selbranch
    SeeSelection
  }
}
#_______________________

proc tree::ExpandSelection {selID {wtree ""}} {
  # Expands the tree selection, counting the tree expanded mode.
  #   selID - ID of selection
  #   wtree - tree's path

  namespace upvar ::alited obPav obPav
  if {[IsExpandedTree]} {
    if {$wtree eq {}} {set wtree [$obPav Tree]}
    catch {$wtree see $selID}
  }
}
#_______________________

proc tree::OldExpanded {wtree tree} {
  # Gets a list of old expanded branches.
  #   wtree - tree widget
  #   tree - tree contents as provided by GetTree

  set res [list]
  foreach it $tree {
    lassign $it lev children item text
    if {$children} {
      catch {
        if {[$wtree item $item -open]} {
          lappend res $text
        }
      }
    }
  }
  return $res
}
#_______________________

proc tree::IsOldExpanded {branchexp leaf title} {
  # Checks if branch was expanded.
  #   branchexp - list of old expanded branches
  #   leaf - yes if it's leaf
  #   title - item's title

  expr {!$leaf && [lsearch -exact $branchexp $title]>-1}
}

# ________________________ See tree items _________________________ #

proc tree::SeeUnit {} {
  # Sees unit name in tree.

  namespace upvar ::alited obPav obPav
  catch {[$obPav Tree] see [CurrentItemByLine]}
}
#_______________________

proc tree::SeeSelection {{wtree ""}} {
  # Sees (makes visible) a current selected item in the tree.
  #   wtree - tree's path

  namespace upvar ::alited al al obPav obPav
  if {$wtree eq {}} {set wtree [$obPav Tree]}
  set selection [$wtree selection]
  if {[llength $selection]==1} {ExpandSelection $selection $wtree}
}
#_______________________

proc tree::SeeFile {fname} {
  # Sees file name in tree.
  #   fname - file name

  namespace upvar ::alited obPav obPav
  set id [alited::file::SearchInFileTree $fname]
  if {$id ne {}} {
    set wtree [$obPav Tree]
    after idle [list after 100 "catch {$wtree selection set $id; $wtree see $id}"]
  }
}
#_______________________

proc tree::SeeTreeItem {} {
  # Sees item in tree.

  after idle {
    after 200 {
      if {$::alited::al(TREE,isunits)} {
        alited::tree::SeeUnit
      } else {
        alited::tree::SeeFile [alited::bar::FileName]
      }
    }
  }
}

# ________________________ Create and handle a tree _________________________ #

proc tree::Create {} {
  # Creates a tree of units/files, at need.
  # See also: CreateFilesTree

  namespace upvar ::alited al al obPav obPav
  if {$al(TREE,isunits) && $al(TREE,units) \
  || !$al(TREE,isunits) && $al(TREE,files)} return  ;# no need
  set wtree [$obPav Tree]
  set branchexp [OldExpanded $wtree [GetTree]]
  if {$al(TREE,isunits)} {
    pack forget [$obPav BtTRenT] ;# hide file buttons for unit tree
    pack forget [$obPav BtTCloT]
    pack forget [$obPav BtTOpen]
  } else {
    pack [$obPav BtTRenT] -side left -after [$obPav BtTAddT]  ;# show file buttons
    pack [$obPav BtTCloT] -side left -after [$obPav BtTDelT]
    pack [$obPav BtTOpen] -side left -after [$obPav BtTCloT]
    # get file tree's current "open branch" flags to check in CreateFilesTree
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
    CreateUnitsTree $TID $wtree $branchexp
  } else {
    CreateFilesTree $wtree $branchexp
  }
}
#_______________________

proc tree::UnitTitle {title l1 l2} {
  # Gets a title of a unit (checking for empty string).
  #   title - original title
  #   l1 - first line of the unit
  #   l2 - latst line of the unit

  if {$title eq {}} {set title "$::alited::al(MC,lines) $l1-$l2"}
  return $title
}
#_______________________

proc tree::CreateUnitsTree {TID wtree branchexp} {
  # Creates a unit tree for a tab.
  #   TID - a current tab's ID
  #   wtree - the tree's path
  #   branchexp - list of old expanded branches

  namespace upvar ::alited al al obPav obPav
  set al(TREE,units) yes
  [$obPav BtTswitch] configure -image alimg_folder
  baltip::tip [$obPav BtTswitch] $al(MC,swunits)
  baltip::tip [$obPav BtTAddT] $al(MC,tpl)
  baltip::tip [$obPav BtTDelT] $al(MC,unitsdel)
  baltip::tip [$obPav BtTUp] $al(MC,moveupU)
  baltip::tip [$obPav BtTDown] $al(MC,movedownU)
  $wtree heading #0 -text [alited::bar::CurrentTab 1]
  $wtree heading #1 -text [msgcat::mc Row]
  set parents [list {}]
  set parent {}
  set levprev -1
  set wtxt [alited::main::GetWTXT $TID]
  foreach item $al(_unittree,$TID) {
    incr iiuni
    if {[llength $item]<3} continue
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev leaf fl1 title l1 l2
    set title [UnitTitle $title $l1 $l2]
    set lev [expr {min($lev,[llength $parents])}]
    set parent [lindex $parents [expr {$lev-1}]]
    if {$leaf} {
      set title " $title"
      set pr [expr {max(0,min(7,($l2-$l1-$::alited::al(minredunit))/$al(prjredunit)))}]
      set imgopt "-image alimg_pro$pr"
      set isopen no
    } else {
      set imgopt "-image alimg_gulls"
      set levtmp [expr ([lindex $al(_unittree,$TID) $iiuni 0]+0)]
      set isopen [expr {$levtmp>$lev && [IsExpandUT]}]
    }
    if {!$isopen && [IsOldExpanded $branchexp $leaf $title]} {set isopen yes}
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $l1 $l2 {} $itemID $lev $leaf $fl1] -open $isopen {*}$imgopt
    $wtree tag add tagNorm $itemID
    if {!$leaf} {
      set parent $itemID
      catch {set parents [lreplace $parents $lev end $parent]}
    }
    set levprev $lev
  }
  alited::tree::ColorUnitsTree $TID $wtxt $wtree -1  ;# color without todos, then with
  after idle [list after 10 [list alited::tree::ColorUnitsTree $TID $wtxt $wtree 50]]
}
#_______________________

proc tree::ColorUnitsTree {TID wtxt wtree wait} {
  # Color units of the tree.
  #   TID - a current tab's ID
  #   wtxt - text's path
  #   wtree - tree's path
  #   wait - waiting mode: -1 no wait, >0 wait for highlighting done, 0 waiting done

  namespace upvar ::alited al al
  if {$TID ne [alited::bar::CurrentTabID]} return
  # colorizing should wait for the highlighting done
  if {$wait>0} {
    if {[alited::file::IsClang [alited::bar::FileName $TID]]} {
      set dowait [expr {![::hl_c::isdone $wtxt]}]
    } else {
      set dowait [expr {![::hl_tcl::isdone $wtxt]}]
    }
    if {$dowait} {
      incr wait -1
      after 100 [list alited::tree::ColorUnitsTree $TID $wtxt $wtree $wait]
      return
    }
  }
  set ctab [alited::bar::CurrentTabID]
  set todolist [list]
  foreach {tr1 tr2} [$wtxt tag ranges tagCMN2] {
    lappend todolist [expr {int($tr1)}]
  }
  $wtree tag remove tagTODO
  if {$wait==-1} {
    $wtree tag remove tagBranch
    $wtree tag remove tagSel
  }
  foreach item $al(_unittree,$TID) {
    if {[llength $item]<3} continue
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev leaf fl1 title l1 l2
    set tag tagNorm
    foreach tr $todolist {
      if {$tr>=$l1 && $tr<=$l2} {
        set tag tagTODO
        break
      }
    }
    catch {
      if {$leaf && \
      [info exists al(CPOS,$ctab,[alited::unit::GetHeader $wtree $itemID])]} {
        if {$tag ne {tagTODO}} {set tag tagSel}
      }
    }
    if {!$leaf} {
      if {$tag ne {tagTODO}} {set tag tagBranch}
    }
    if {$tag ne {tagNorm} && ($wait==-1 && $tag ne {tagTODO} || $tag eq {tagTODO})} {
      if {[catch {$wtree tag add $tag $itemID}]} break
    }
  }
}
#_______________________

proc tree::CreateFilesTree {wtree branchexp} {
  # Creates a file tree.
  #   wtree - the tree's path
  #   branchexp - list of old expanded branches

  namespace upvar ::alited al al obPav obPav
  set al(TREE,files) yes
  [$obPav BtTswitch] configure -image alimg_gulls
  baltip::tip [$obPav BtTswitch] $al(MC,swfiles)
  baltip::tip [$obPav BtTAddT] $al(MC,filesadd)\nInsert
  baltip::tip [$obPav BtTDelT] $al(MC,filesdel)\nDelete
  baltip::tip [$obPav BtTUp] $al(MC,moveupF)
  baltip::tip [$obPav BtTDown] $al(MC,movedownF)
  $wtree heading #0 -text ":: $al(prjname) ::"
  $wtree heading #1 -text $al(MC,files)
  bind $wtree <Return> {alited::tree::OpenFile}
  if {[catch {set selfile [alited::bar::FileName]}]} {
    set selfile {} ;# at closing by Ctrl+W with file tree open: no current file
  }
  set filesTIDs [alited::bar::FilesTIDs]
  PrepareDirectoryContents
  foreach item [GetDirectoryContents $al(prjroot)] {
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev isfile fname fcount iroot
    set title [file tail $fname]
    if {$iroot<0} {
      set parent {}
    } else {
      set parent [alited::tree::NewItemID [incr iroot]]
    }
    if {$isfile} {
      if {[alited::file::IsTcl $fname]} {
        set imgopt {-image alimg_tclfile}
      } else {
        set imgopt {-image alimg_file}
      }
    } else {
      set imgopt {-image alimg_folder}
      # get the directory's flag of expanded branch (in the file tree)
    }
    if {$fcount} {set fc $fcount} {set fc {}}
    set isopen [expr {$al(expandFT) || [IsOldExpanded $branchexp $isfile $title]}]
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $fc $fname $isfile $itemID] -open $isopen {*}$imgopt
    $wtree tag add tagNorm $itemID
    if {!$isfile} {
      $wtree tag add tagBranch $itemID
    } elseif {[alited::bar::FileTID $fname $filesTIDs] ne {}} {
      $wtree tag add tagSel $itemID
    }
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
  lassign [alited::FgAdditional] fgbr fgred fgtodo
  append fontN "-font $::alited::al(FONT,defsmall)"
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
    set m2 $al(MC,tpl)
    set m3 $al(MC,unitsdel)
    set moveup $al(MC,moveupU)
    set movedown $al(MC,movedownU)
    set dropitem [msgcat::mc {Drop Selected Units Here}]
    set accins {}
    set accdel {}
  } else {
    set img alimg_gulls
    set m1 $al(MC,swfiles)
    set m2 $al(MC,filesadd...)
    set m3 $al(MC,filesdel)
    set moveup $al(MC,moveupF)
    set movedown $al(MC,movedownF)
    set dropitem [msgcat::mc {Drop Selected Files Here}]
    set accins {-accelerator Insert}
    set accdel {-accelerator Delete}
  }
  if {[string length $sname]>25} {set sname "[string range $sname 0 21]..."}
  $popm add command {*}[$obPav iconA none] -label $m1 \
    -command ::alited::tree::SwitchTree -image $img
  $popm add command {*}[$obPav iconA none] -label $al(MC,updtree) \
    -command alited::tree::RecreateTree -image alimg_retry
  $popm add separator
  $popm add command {*}[$obPav iconA none] -label $moveup \
    -command {alited::tree::MoveItem up} -image alimg_up
  $popm add command {*}[$obPav iconA none] -label $movedown \
    -command {alited::tree::MoveItem down} -image alimg_down
  $popm add separator
  $popm add command {*}[$obPav iconA none] -label $m2 \
    -command "::alited::tree::AddItem $ID" {*}$accins -image alimg_add
  if {!$al(TREE,isunits)} {
    $popm add command {*}[$obPav iconA change] \
      -label $al(MC,renamefile...) -accelerator F2 \
      -command {alited::file::RenameFileInTree no}
  }
  $popm add command {*}[$obPav iconA none] -label $m3 \
    -command "::alited::tree::DelItem $ID -100" {*}$accdel -image alimg_delete
  if {$al(TREE,isunits)} {
    if {$al(FAV,IsFavor)} {
      $popm add separator
      $popm add command {*}[$obPav iconA heart] -label $al(MC,favoradd) \
        -command ::alited::favor::AddFromTree
    }
    if {$isunit} {
      $popm add separator
      $popm add command {*}[$obPav iconA none] -label $al(MC,copydecl) \
        -command "clipboard clear ; clipboard append {\n$header \{\n\}}"
    }
  } else {
    $popm add command {*}[$obPav iconA copy] \
      -label $al(MC,clonefile...) -command ::alited::file::CloneFile
    $popm add command {*}[$obPav iconA OpenFile] -label $al(MC,openwith) \
      -command ::alited::file::OpenWith
    $popm add separator
    if {$isfile} {set fname [file dirname $fname]}
    set sname [file tail $fname]
    $popm add command {*}[$obPav iconA none] -label $al(MC,openselfile) -command ::alited::file::OpenFiles
    set msg [string map [list %n $sname] $al(MC,openofdir)]
    $popm add command {*}[$obPav iconA none] -label $msg \
      -command "::alited::file::OpenOfDir {$fname}"
    $popm add separator
    $popm add command {*}[$obPav iconA none] -label $al(MC,detachsel) \
      -command ::alited::file::DetachFromTree
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
      set doubleclick [expr {[info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]}]
      set al(_MSEC) $msec
      if {$doubleclick} {     ;# at double click:
        DestroyMoveWindow yes ;# disable any drag-drop
      }
      if {$al(TREE,isunits)} {
        NewSelection $ID
        alited::main::SaveVisitInfo
      } elseif {$doubleclick} {
        OpenFile $ID
      }
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
  set ctrl [expr {$s & 0b100}]
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
  if {$s & 0b111} {
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
    label $al(movWin).label -text $text -relief solid \
      -foreground $al(MOVEFG) -background $al(MOVEBG)
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

proc tree::UnitTooltip {wtxt l1 l2} {
  # Gets unit's tooltip.
  #   wtxt - text's path
  #   l1 - 1st line's number
  #   l2 - last line's number

  set tip {}
  foreach {p1 p2} [$wtxt tag ranges tagCMN2] {
    if {[$wtxt compare $l1.0 <= $p1] && [$wtxt compare $p2 <= $l2.end]} {
      set todo [string trimleft [$wtxt get $p1 $p2] #!]
      switch [incr tiplines] {
        1  {append tip \n_______________________\n}
        13 {break}
      }
      append tip \n $todo
    }
  }
  return $tip
}
#_______________________

proc tree::GetTooltip {ID NC} {
  # Gets a tip for unit / file tree's item.
  #   ID - ID of treeview item
  #   NC - column of treeview item

  namespace upvar ::alited al al obPav obPav
  if {[info exists al(movWin)] && $al(movWin) ne {} || ![::alited::IsTipable]} {
    return {}  ;# no tips while drag-n-dropping or focusing somewhere else
  }
  set wtree [$obPav Tree]
  if {$al(TREE,isunits)} {
    # for units
    set tip [alited::unit::GetHeader $wtree $ID $NC]
    # try to read and add TODOs for this unit
    catch {
      lassign [$wtree item $ID -values] l1 l2
      set wtxt [alited::main::CurrentWTXT]
      append tip [UnitTooltip $wtxt $l1 $l2]
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

proc tree::PrepareDirectoryContents {} {
  # Prepares reading a directory's contents.
  # See also: GetDirectoryContents

  namespace upvar ::alited al al _dirtree _dirtree
  set _dirtree [set al(_dirignore) [list]]
  catch {    ;# there might be an incorrect list -> catch it
    foreach d $al(prjdirign) {
      lappend al(_dirignore) [string toupper [string trim $d \"]]
    }
  }
  lappend al(_dirignore) [string toupper [file tail [alited::Tclexe]]] . ..
}
#_______________________

proc tree::GetDirectoryContents {dirname} {
  # Gets a directory's contents.
  #   dirname - the directory's name
  # Returns a list containing the directory's contents.
  # See also: DirContents

  namespace upvar ::alited _dirtree _dirtree
  DirContents $dirname
  return $_dirtree
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

  namespace upvar ::alited al al _dirtree _dirtree
  incr lev
  set tpl [file join $dirname *]
  if {[catch {set dcont [glob $tpl]}]} {
    set dcont [list]
  }
  catch {
    lappend dcont {*}[glob -type hidden $tpl]
  }
  set dcont [lsort -dictionary $dcont]
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
      if {[llength $_dirtree] < $al(MAXFILES)} {
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
  if {[llength $_dirtree] < $al(MAXFILES)} {
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

  namespace upvar ::alited al al _dirtree _dirtree
  set dllen [llength $_dirtree]
  if {$dllen < $al(MAXFILES)} {
    lappend _dirtree [list $lev $isfile $fname 0 $iroot]
    if {$iroot>-1} {
      lassign [lindex $_dirtree $iroot] lev isfile fname fcount sroot
      set _dirtree [lreplace $_dirtree $iroot $iroot \
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
    catch {uplevel [expr {$lev+1}] $proc}
  }
  incr lev
  foreach child $children {
    ForEach $wtree $aproc $lev $child
  }
}
#_______________________

proc tree::GetTree {{parent ""} {Tree Tree} {wtree ""}} {
  # Gets a tree or its branch.
  #   parent - ID of the branch
  #   Tree - name of the tree widget
  #   wtree - full path to the tree

  namespace upvar ::alited obPav obPav
  if {$wtree eq {}} {set wtree [$obPav $Tree]}
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

proc tree::RecreateTree {{wtree ""} {headers ""} {clearsel no}} {
  # Recreates the tree and restores its selections.
  #   wtree - the tree's path
  #   headers - a list of selected items
  #   clearsel - if yes, clears tree's selection

  namespace upvar ::alited al al obPav obPav
  if {$wtree eq {}} {set wtree [$obPav Tree]}
  if {$clearsel || [catch {set selection [$wtree selection]}]} {
    set selection [list]
  }
  if {$al(TREE,isunits)} {
    set al(TREE,units) no
    set TID [alited::bar::CurrentTabID]
    set wtxt [alited::main::CurrentWTXT]
    alited::unit::RecreateUnits $TID $wtxt
  } else {
    set al(TREE,files) no
  }
  Create
  # restore selections
  if {$headers eq {-}} return
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
    foreach item [GetTree] {
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
