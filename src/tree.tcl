#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The unit procedures of alited.
# _______________________________________________________________________ #

namespace eval tree {
  variable doFocus yes
  variable tipID ""
}

proc tree::SwitchTree {} {
  namespace upvar ::alited al al obPav obPav
  set al(TREE,isunits) [expr {!$al(TREE,isunits)}]
  set al(TREE,units) no
  set al(TREE,files) no
  Create
}

proc tree::Create {} {

  namespace upvar ::alited al al obPav obPav
  if {$al(TREE,isunits) && $al(TREE,units) \
  || !$al(TREE,isunits) && $al(TREE,files)} return
  set TID [alited::bar::CurrentTabID]
  set wtree [$obPav Tree]
  Delete $wtree {} $TID
  lassign [$obPav csGet] - - - - fgbr - - fgred
  set fontN "-font {[font actual apaveFontDef] -size $al(FSIZE,small)}"
  append fontB $fontN " -foreground $fgred"
  $wtree tag configure tagNorm {*}$fontN
  $wtree tag configure tagBold {*}$fontB
  $wtree tag configure tagBranch -foreground $fgbr
  $wtree tag bind tagNorm <Motion> {after idle {alited::tree::Tooltip %x %y %X %Y}}
  $wtree tag bind tagNorm <ButtonRelease> {alited::tree::PopupMenu %b %x %y %X %Y}
  bind $wtree <Leave> {alited::tree::TooltipOff}
  if {$al(TREE,isunits)} {
    CreateUnitsTree $TID $wtree
  } else {
    CreateFilesTree $TID $wtree
  }
}

proc tree::CreateFilesTree {TID wtree} {

  namespace upvar ::alited al al obPav obPav
  set al(TREE,files) yes
  [$obPav BuTswitch] configure -image alimg_folder
  baltip::tip [$obPav BuTswitch] $al(MC,swfiles)
  baltip::tip [$obPav BuTAddT] $al(MC,filesadd)
  baltip::tip [$obPav BuTDelT] $al(MC,filesdel)
  $wtree heading #0 -text ":: [file tail $al(prjroot)] ::"
  $wtree heading #1 -text $al(MC,files)
  foreach item [GetDirectoryContents $al(prjroot)] {
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev isfile fname fcount iroot
    set title [file tail $fname]
    if {$iroot<0} {
      set parent {}
    } else {
      set parent [alited::tree::NewItemID [incr iroot]]
    }
    if {$isfile} {set imgopt "-image alimg_file"} {set imgopt "-image alimg_folder"}
    if {$fcount} {set fc "$fcount"} {set fc ""}
    $wtree insert $parent end \
      -id $itemID -text "$title" -values [list $fc $fname $isfile $itemID] -open yes {*}$imgopt
    $wtree tag add tagNorm $itemID
    if {!$isfile} {
      $wtree tag add tagBranch $itemID
    }
  }
}

proc tree::CreateUnitsTree {TID wtree} {
  namespace upvar ::alited al al obPav obPav
  set al(TREE,units) yes
  [$obPav BuTswitch] configure -image alimg_tree
  baltip::tip [$obPav BuTswitch] $al(MC,swunits)
  baltip::tip [$obPav BuTAddT] $al(MC,unitsadd)
  baltip::tip [$obPav BuTDelT] $al(MC,unitsdel)
  $wtree heading #0 -text [alited::bar::CurrentTab 1]
  $wtree heading #1 -text $al(MC,line)
  set parents [list {}]
  set parent {}
  set levprev -1
  foreach item $al(_unittree,$TID) {
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev leaf fl1 title l1 l2
    if {$title eq ""} {set title "Lines $l1-$l2"}
    set lev [expr {min($lev,[llength $parents])}]
    set parent [lindex $parents [expr {$lev-1}]]
    if {$leaf} {set imgopt "-image alimg_minus"} {set imgopt "-image alimg_actions"}
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $l1 $l2 "" $itemID $lev $leaf $fl1] -open yes {*}$imgopt
    $wtree tag add tagNorm $itemID
    catch {
      if {[info exists al(CPOS,"$title")]} {
        $wtree tag add tagBold $itemID
      }
    }
    if {!$leaf} {
      $wtree tag add tagBranch $itemID
      set parent $itemID
      set parents [lreplace $parents $lev end $parent]
    }
    set levprev $lev
  }
}

proc tree::NewItemID {iit} {
  return "al$iit"
}

proc tree::ShowPopupMenu {ID X Y} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set popm $wtree.popup
  catch {destroy $popm}
  menu $popm -tearoff 0
  set IDparent [$wtree parent $ID]
  if {$IDparent eq ""} {
    set parent ROOT
    set state disabled
  } else {
    set parent [$wtree item $IDparent -text]
    set state normal
  }
  if {[string length $parent]>25} {set parent "[string range $parent 0 21]..."}
  set msgsort [string map [list %t $parent] $al(MC,sort)]
  $popm add command {*}[$obPav iconA Up] -label $al(MC,moveup) \
    -accelerator F11 -command "::alited::main::MoveItem up" -image alimg_up
  $popm add command {*}[$obPav iconA Down] -label $al(MC,movedown) \
    -accelerator F12 -command "::alited::main::MoveItem down" -image alimg_down
  $popm add command {*}[$obPav iconA none] -label $msgsort \
    -command "::alited::tree::SortItems $IDparent" -state $state
  $popm add separator
  tk_popup $popm $X $Y
}

proc tree::SortItems {IDparent} {
  puts "$IDparent"
}

proc tree::PopupMenu {but x y X Y} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set ID [$wtree identify item $x $y]
  if {![$wtree exists $ID]} return
  switch $but {
    "3" {
        if {$al(TREE,isunits)} {
          NewSelection $ID
          ShowPopupMenu $ID $X $Y
        }
    }
    "1" {
      if {$al(TREE,isunits)} {
        NewSelection $ID
      } else {
        set msec [clock milliseconds]
        if {[info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]} {
          lassign [$wtree item $ID -values] -> fname isfile
          if {$isfile} {alited::file::OpenFile $fname}
        }
        $wtree selection set $ID
        set al(_MSEC) $msec
      }
    }
  }
}

proc tree::TooltipOff {} {
  namespace upvar ::alited al al
  variable tipID
  ::baltip hide $al(WIN)
  set tipID ""
}

proc tree::Tooltip {x y X Y} {
  namespace upvar ::alited al al obPav obPav
  variable tipID
  set wtree [$obPav Tree]
  set ID [$wtree identify item $x $y]
  if {[$wtree exists $ID] && $tipID ne $ID} {
    lassign [$wtree bbox $ID] x2 y2 w2 h2
    incr X 10
    if {[catch {incr Y [expr {$y2-$y+$h2}]}]} {incr Y 10}
    if {$al(TREE,isunits)} {
      # for units
      set tip [$wtree item $ID -text]
      lassign [$wtree item $ID -values] l1 l2
      catch {
        set wtxt [alited::main::CurrentWTXT]
        set tip2 [string trim [$wtxt get $l1.0 $l1.end]]
        if {[string match "*\{" $tip2]} {set tip [string trim $tip2 " \{"]}
        # find first commented line, after the proc/method declaration
        for {} {$l1<$l2} {} {
          incr l1
          set line [string trim [$wtxt get $l1.0 $l1.end]]
          if {[string index $line end] ni [list \\ \{] && \
          $line ni {"" "#"} && ![regexp $al(RE,abc) $line]} {
            if {[string match "#*" $line]} {
              append tip \n [string trim [string range $line 1 end]]
            }
            break
          }
        }
      }
    } else {
      # for files
      lassign [$wtree item $ID -values] -> tip isfile
      if {$isfile} { ;# tips for directories only
        ::baltip hide $al(WIN)
        set tipID $ID
        return
      }
    }
    ::baltip tip $al(WIN) $tip -geometry +$X+$Y -per10 4000 -pause 5 -fade 5
  }
  set tipID $ID
}

proc tree::Delete {wtree item TID} {

  foreach child [$wtree children $item] {
    alited::tree::Delete $wtree $child $TID
  }
  if {$item ne {}} {$wtree delete $item}
}

proc tree::NewSelection {{itnew ""}} {

  namespace upvar ::alited al al obPav obPav
  variable doFocus
  set TID [alited::bar::CurrentTabID]
  set wtxt [alited::main::CurrentWTXT]
  set wtree [$obPav Tree]
  # newly selected item
  if {$itnew eq ""} {set itnew [[$obPav Tree] focus]}
  $wtree tag add tagBold $itnew
  set title [$wtree item $itnew -text]
  # get saved pos
  lassign [$wtree item $itnew -values] l1 l2
  if {[catch {set pos $al(CPOS,"$title")}]} {set pos ""}
  if {$pos eq "" || $pos<$l1 || int($pos)>$l2} {
    # if not saved, get it from 1st line
    set pos $l1.0
  }
  # previously selected item
  set itold [alited::bar::BAR $TID cget --currTreeItem]
  if {$itold ne ""} {
    # if there was the previously selected item, save the cursor to it
    set savedpos [expr {[$wtxt index insert]}]
    catch {set al(CPOS,"[$wtree item $itold -text]") $savedpos}
  }
  alited::bar::BAR $TID configure --currTreeItem $itnew
  catch {set al(CPOS,"$title") $pos}
  if {$doFocus} {
    alited::main::FocusText $TID $wtxt $pos
  }
}

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

proc tree::ForEach {wtree aproc {lev 0} {branch {}}} {

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
    alited::tree::ForEach $wtree $aproc $lev $child
  }
}

proc tree::GetDirectoryContents {dirname} {
  namespace upvar ::alited al al
  set al(_dirtree) [list]
  DirContents $dirname
  return $al(_dirtree)
}

proc tree::DirContents {dirname {lev 0} {iroot -1} {globs "*"}} {

  incr lev
  set dcont [lsort -dictionary [glob [file join $dirname *]]]
  # firstly directories
  set i 0
  foreach fname $dcont {
    if {[file isdirectory $fname]} {
      set dcont [lreplace $dcont $i $i [list $fname "y"]]
      set nroot [AddToDirContents $lev 0 $fname $iroot]
      DirContents $fname $lev $nroot $globs
    }
    incr i
  }
  # then files
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

proc tree::AddToDirContents {lev isfile fname iroot} {
  namespace upvar ::alited al al
  set dllen [llength $al(_dirtree)]
  lappend al(_dirtree) [list $lev $isfile $fname 0 $iroot]
  if {$iroot>-1} {
    lassign [lindex $al(_dirtree) $iroot] lev isfile fname fcount sroot
    set al(_dirtree) [lreplace $al(_dirtree) $iroot $iroot \
      [list $lev $isfile $fname [incr fcount] $sroot]]
  }
  return $dllen
}

proc tree::GetTree {} {
  namespace upvar ::alited obPav obPav
  set wtree [$obPav Tree]
  set tree [list]
  ForEach $wtree {
    set item [list  %level %children "%item" "%text" "%values"]
    lappend tree $item
  }
  return $tree
}

proc tree::RecreateTree {pos} {
  namespace upvar ::alited al al
  if {$al(TREE,isunits)} {
    set al(TREE,units) no
  } else {
    set al(TREE,files) no
  }
  set TID [alited::bar::CurrentTabID]
  set wtxt [alited::main::CurrentWTXT]
  set al(_unittree,$TID) [alited::unit::GetUnits [$wtxt get 1.0 end]]
  Create
  ::tk::TextSetCursor $wtxt $pos.0
  alited::main::FocusText $TID $wtxt $pos
}

proc tree::UpdateUnitTree {TID} {
  # Gets the unit array from the unit tree.
  namespace upvar ::alited al al
  set tree [GetTree]
  set al(_unittree,$TID) [list]
  foreach item $tree {
    lassign $item lev cnt id title values
    lassign $values l1 l2 prl id lev leaf fl1
    lappend al(_unittree,$TID) [list $lev $leaf $fl1 $title $l1 $l2]
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
