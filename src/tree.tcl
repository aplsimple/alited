#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The unit/file tree procedures of alited.
# _______________________________________________________________________ #

namespace eval tree {
  variable doFocus yes
  variable tipID ""
}

proc tree::SwitchTree {} {
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
  update idletasks
}

proc tree::AddTags {wtree} {
  namespace upvar ::alited al al
  lassign [::hl_tcl::hl_colors "" [::apave::obj csDarkEdit]] - fgred fgbr
  set fontN "-font $alited::al(FONT,defsmall)"
  append fontB $fontN " -foreground $fgred"
  $wtree tag configure tagNorm {*}$fontN
  $wtree tag configure tagBold {*}$fontB
  $wtree tag configure tagBranch -foreground $fgbr
}

proc tree::Create {} {

  namespace upvar ::alited al al obPav obPav
  if {$al(TREE,isunits) && $al(TREE,units) \
  || !$al(TREE,isunits) && $al(TREE,files)} return
  set TID [alited::bar::CurrentTabID]
  set wtree [$obPav Tree]
  Delete $wtree {} $TID
  AddTags $wtree
  $wtree tag bind tagNorm <ButtonPress> {after idle {alited::tree::ButtonPress %b %x %y %X %Y}}
  $wtree tag bind tagNorm <ButtonRelease> {after idle {alited::tree::ButtonRelease %b %x %y %X %Y}}
  $wtree tag bind tagNorm <Motion> {after idle {alited::tree::ButtonMotion %b %x %y %X %Y}}
  bind $wtree <ButtonRelease> {alited::tree::DestroyMoveWindow no}
  bind $wtree <Leave> {
    alited::tree::TooltipOff
    alited::tree::DestroyMoveWindow yes
  }
  if {$al(TREE,isunits)} {
    CreateUnitsTree $TID $wtree
  } else {
    CreateFilesTree $wtree
  }
}

proc tree::CreateFilesTree {wtree} {

  namespace upvar ::alited al al obPav obPav
  set al(TREE,files) yes
  [$obPav BuTswitch] configure -image alimg_gulls
  baltip::tip [$obPav BuTswitch] $al(MC,swfiles)
  baltip::tip [$obPav BuTAddT] $al(MC,filesadd)
  baltip::tip [$obPav BuTDelT] $al(MC,filesdel)
  baltip::tip [$obPav BuTUp] $al(MC,moveupF)
  baltip::tip [$obPav BuTDown] $al(MC,movedownF)
  $al(MENUEDIT) entryconfigure 0 -label $al(MC,moveupF)
  $al(MENUEDIT) entryconfigure 1 -label $al(MC,movedownF)
  $wtree heading #0 -text ":: [file tail $al(prjroot)] ::"
  $wtree heading #1 -text $al(MC,files)
  bind $wtree <Return> {::alited::tree::OpenFile}
  set selID ""
  set selfile [alited::bar::FileName]
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
    if {$isfile} {
      if {[alited::file::IsTcl $fname]} {
        set imgopt "-image alimg_tclfile"
      } else {
        set imgopt "-image alimg_file"
      }
    } else {
      set imgopt "-image alimg_folder"
    }
    if {$fcount} {set fc "$fcount"} {set fc ""}
    $wtree insert $parent end \
      -id $itemID -text "$title" -values [list $fc $fname $isfile $itemID] -open yes {*}$imgopt
    $wtree tag add tagNorm $itemID
    if {!$isfile} {
      $wtree tag add tagBranch $itemID
    } elseif {[alited::bar::FileTID $fname] ne ""} {
      $wtree tag add tagBold $itemID
    }
  }
  if {$selID ne ""} {
    $wtree see $selID
    $wtree selection set $selID
  }
}

proc tree::CreateUnitsTree {TID wtree} {
  namespace upvar ::alited al al obPav obPav
  set al(TREE,units) yes
  [$obPav BuTswitch] configure -image alimg_folder
  baltip::tip [$obPav BuTswitch] $al(MC,swunits)
  baltip::tip [$obPav BuTAddT] $al(MC,unitsadd)
  baltip::tip [$obPav BuTDelT] $al(MC,unitsdel)
  baltip::tip [$obPav BuTUp] $al(MC,moveupU)
  baltip::tip [$obPav BuTDown] $al(MC,movedownU)
  $al(MENUEDIT) entryconfigure 0 -label $al(MC,moveupU)
  $al(MENUEDIT) entryconfigure 1 -label $al(MC,movedownU)
  $wtree heading #0 -text [alited::bar::CurrentTab 1]
  $wtree heading #1 -text [msgcat::mc "Row"]
  set ctab [alited::bar::CurrentTabID]
  set parents [list {}]
  set parent {}
  set levprev -1
  foreach item $al(_unittree,$TID) {
    set itemID  [alited::tree::NewItemID [incr iit]]
    lassign $item lev leaf fl1 title l1 l2
    if {$title eq ""} {set title "[msgcat::mc Lines] $l1-$l2"}
    set lev [expr {min($lev,[llength $parents])}]
    set parent [lindex $parents [expr {$lev-1}]]
    if {$leaf} {
      set title " $title"
      set pr [expr {max(0,min(7,($l2-$l1)/20))}]
      set imgopt "-image alimg_pro$pr"
    } else {
      set imgopt "-image alimg_gulls"
    }
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $l1 $l2 "" $itemID $lev $leaf $fl1] -open yes {*}$imgopt
    $wtree tag add tagNorm $itemID
    catch {
      if {$leaf && [info exists al(CPOS,$ctab,[alited::unit::GetHeader $wtree $itemID])]} {
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

proc tree::AddItem {{ID ""}} {
  namespace upvar ::alited al al
  if {$al(TREE,isunits)} {
    alited::unit::Add
  } else {
    alited::file::Add $ID
  }
}

proc tree::DelItem {{ID ""}} {
  namespace upvar ::alited al al obPav obPav
  if {$ID eq "" && [set ID [alited::tree::CurrentItem]] eq ""} {
    bell
    return
  }
  set wtree [$obPav Tree]
  set fname [alited::bar::FileName]
  if {$al(TREE,isunits)} {
    alited::unit::Delete $wtree $fname
  } else {
    alited::file::Delete $ID $wtree
  }
}

proc tree::ShowPopupMenu {ID X Y} {
  namespace upvar ::alited al al obPav obPav
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
    set m2 $al(MC,unitsadd)
    set m3 $al(MC,unitsdel)
    set moveup $al(MC,moveupU) 
    set movedown $al(MC,movedownU)
  } else {
    set img alimg_gulls
    set m1 $al(MC,swfiles)
    set m2 $al(MC,filesadd)
    set m3 $al(MC,filesdel)
    set moveup $al(MC,moveupF) 
    set movedown $al(MC,movedownF)
  }
  if {[string length $sname]>25} {set sname "[string range $sname 0 21]..."}
  $popm add command {*}[$obPav iconA none] -label $m1 \
    -command "::alited::tree::SwitchTree" -image $img
  $popm add command {*}[$obPav iconA none] -label $al(MC,updtree) \
    -command "alited::tree::RecreateTree" -image alimg_retry
  $popm add separator
  $popm add command {*}[$obPav iconA Up] -label $moveup \
    -accelerator F11 -command "::alited::main::MoveItem up" -image alimg_up
  $popm add command {*}[$obPav iconA Down] -label $movedown \
    -accelerator F12 -command "::alited::main::MoveItem down" -image alimg_down
  $popm add separator
  $popm add command {*}[$obPav iconA none] -label $m2 \
    -command "::alited::tree::AddItem $ID" -image alimg_add
  $popm add command {*}[$obPav iconA none] -label $m3 \
    -command "::alited::tree::DelItem $ID" -image alimg_delete
  if {$al(TREE,isunits)} {
    if {$isunit} {
      $popm add separator
      $popm add command {*}[$obPav iconA none] -label $al(MC,copydecl) \
        -command "clipboard clear ; clipboard append {$header}"
    }
  } else {
    if {$isfile} {set fname [file dirname $fname]}
    set sname [file tail $fname]
    $popm add separator
    set msg [string map [list %n $sname] $al(MC,openofdir)]
    $popm add command {*}[$obPav iconA OpenFile] -label $msg \
      -command "::alited::file::OpenOfDir {$fname}"
  }
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}

proc tree::ButtonPress {but x y X Y} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set ID [$wtree identify item $x $y]
  if {![$wtree exists $ID]} return
  TooltipOff
  set al(movID) [set al(movWin) {}]
  switch $but {
    "3" {
        if {[llength [$wtree selection]]<2} {
          $wtree selection set $ID
        }
        ShowPopupMenu $ID $X $Y
    }
    "1" {
      set al(movID) $ID
      set al(movWin) ".tritem_move"
      if {$al(TREE,isunits)} {
        NewSelection $ID
      } else {
        set msec [clock milliseconds]
        if {[info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]} {
          OpenFile $ID
        }
        $wtree selection set $ID
        set al(_MSEC) $msec
      }
    }
  }
}

proc tree::ButtonRelease {but x y X Y} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav Tree]
  set ID [$wtree identify item $x $y]
  DestroyMoveWindow no
  if {[$wtree exists $ID] && [info exists al(movID)] && \
  $al(movID) ne {} && $ID ne {} && $al(movID) ne $ID} {
    if {$al(TREE,isunits)} {
      alited::unit::MoveUnits $wtree move $al(movID) $ID
    } else {
      alited::file::MoveFile $wtree move $al(movID) $ID
    }
  }
  DestroyMoveWindow yes
  set al(movID) {}
}

proc tree::ButtonMotion {but x y X Y} {
  namespace upvar ::alited al al obPav obPav
  if {![info exists al(movWin)] || $al(movWin) eq ""} {
    alited::tree::Tooltip $x $y $X $Y
    return
  }
  set wtree [$obPav Tree]
  # dragging the tab
  if {![winfo exists $al(movWin)]} {
    # make the tab's replica to be dragged
    toplevel $al(movWin)
    if {$::tcl_platform(platform) == "windows"} {
      wm attributes $al(movWin) -alpha 0.0
    } else {
      wm withdraw $al(movWin)
    }
    if {[tk windowingsystem] eq "aqua"} {
      ::tk::unsupported::MacWindowStyle style $al(movWin) help none
    } else {
      wm overrideredirect $al(movWin) 1
    }
    label $al(movWin).label -text [$wtree item $al(movID) -text] -relief solid \
      -foreground black -background #7eeeee
    pack $al(movWin).label -expand 1 -fill both -ipadx 1
  }
  set ID [$wtree identify item $x $y]
  wm geometry $al(movWin) +[expr {$X+10}]+[expr {$Y+10}]
  if {$::tcl_platform(platform) == "windows"} {
    if {[wm attributes $al(movWin) -alpha] < 0.1} {wm attributes $al(movWin) -alpha 1.0}
  } else {
    catch {wm deiconify $al(movWin) ; raise $al(movWin)}
  }
}

proc tree::DestroyMoveWindow {cancel} {
  namespace upvar ::alited al al
  catch {destroy $al(movWin)}
  if {$cancel} {lassign {} al(movWin) al(movID)}
}

proc tree::OpenFile {{ID ""}} {
  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits)} {
    set wtree [$obPav Tree]
    if {$ID eq ""} {
      if {[set ID [$wtree selection]] eq ""} return
    }
    lassign [$wtree item $ID -values] -> fname isfile
    if {$isfile} {
      alited::file::OpenFile $fname
      after idle ::alited::tree::RecreateTree
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
  set NC [$wtree identify column $x $y]
  set newTipID "$ID/$NC"
  if {[$wtree exists $ID] && $tipID ne $newTipID} {
    lassign [$wtree bbox $ID] x2 y2 w2 h2
    incr X 10
    if {[catch {incr Y [expr {$y2-$y+$h2}]}]} {incr Y 10}
    if {$al(TREE,isunits)} {
      # for units
      set tip [alited::unit::GetHeader $wtree $ID $NC]
    } else {
      # for files
      lassign [$wtree item $ID -values] -> tip isfile
      if {$isfile} { ;# tips for directories only
        ::baltip hide $al(WIN)
        set tipID $newTipID
        return
      }
    }
    ::baltip tip $al(WIN) $tip -geometry +$X+$Y -per10 4000 -pause 5 -fade 5
  }
  set tipID $newTipID
}

proc tree::Delete {wtree item TID} {

  foreach child [$wtree children $item] {
    alited::tree::Delete $wtree $child $TID
  }
  if {$item ne {}} {$wtree delete $item}
}

proc tree::CurrentItemByLine {{pos ""} {fullinfo no}} {
  namespace upvar ::alited al al
  if {$pos eq ""} {
    set pos [[alited::main::CurrentWTXT] index insert]
  }
  set l [expr {int($pos)}]
  set TID [alited::bar::CurrentTabID]
  foreach it $al(_unittree,$TID) {
    set ID [NewItemID [incr iit]]
    lassign $it lev leaf fl1 title l1 l2
    if {$l1<=$l && $l<=$l2} {
      if {$fullinfo} {
        return [list $ID $lev $leaf $fl1 $title $l1 $l2]
      }
      return $ID
    }
  }
  return ""
}

proc tree::CurrentItem {{Tree Tree}} {
  namespace upvar ::alited obPav obPav
  set wtree [$obPav $Tree]
  set it [$wtree focus]
  if {$it eq ""} {set it [lindex [$wtree selection] 0]}
  return $it
}

proc tree::NewSelection {{itnew ""} {line 0} {topos no}} {

  namespace upvar ::alited al al obPav obPav
  variable doFocus
  set TID [alited::bar::CurrentTabID]
  set wtxt [alited::main::CurrentWTXT]
  set ctab [alited::bar::CurrentTabID]
  set wtree [$obPav Tree]
  # newly selected item
  if {$itnew eq ""} {set itnew [CurrentItem]}
  set header [alited::unit::GetHeader $wtree $itnew]
  lassign [$wtree item $itnew -values] l1 l2 - - - leaf
  if {$leaf ne "" && $leaf} {
    $wtree tag add tagBold $itnew
  }
  # get saved pos
  if {[catch {set pos $al(CPOS,$ctab,$header)} e]} {
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
        set al(CPOS,$otab,$ohead) "$opos"
      }
    }
  }
  alited::bar::BAR configure --currSelTab $ctab --currSelItem $itnew
  catch {set al(CPOS,$ctab,$header) "$pos"}
  if {$doFocus} {
    alited::main::FocusText $TID $pos
  }
  if {$al(TREE,isunits)} {
    alited::favor::LastVisited [$wtree item $itnew] $header
  }
  alited::main::UpdateGutter
  return $itnew
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

proc tree::IgnoredDir {dir} {
  namespace upvar ::alited al al
  set res no
  set dir [string toupper [file tail $dir]]
  catch {    ;# there might be an incorrect list -> catch it
    foreach d $al(prjdirign) {
      set d [string toupper [string trim $d \"]]
      if {$dir eq $d} {
        set res yes
        break
      }
    }
  }
  return $res
}

proc tree::DirContents {dirname {lev 0} {iroot -1} {globs "*"}} {

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

proc tree::AddToDirContents {lev isfile fname iroot} {
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

proc tree::GetTree {{parent {}} {Tree Tree}} {
  # Gets a tree or its branch.
  #   parent - ID of the branch

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
    if {$parent eq {} || $levp>-1} {
      lappend tree [list $lev %children $item {%text} {%values}]
    }
  }
  return $tree
}

proc tree::ExpandTree {tree {isexp yes}} {
  namespace upvar ::alited al al obPav obPav
  set wtree [$obPav $tree]
  foreach item [GetTree {} $tree] {
    lassign $item lev cnt ID
    if {[llength [$wtree children $ID]]} {
      $wtree item $ID -open $isexp
    }
  }
}

proc tree::RecreateTree {{wtree ""} {headers ""}} {
  namespace upvar ::alited al al
  if {$al(TREE,isunits)} {
    set al(TREE,units) no
    set TID [alited::bar::CurrentTabID]
    set wtxt [alited::main::CurrentWTXT]
    set al(_unittree,$TID) [alited::unit::GetUnits $TID [$wtxt get 1.0 "end -1 char"]]
  } else {
    set al(TREE,files) no
  }
  Create
  # restore selections
  if {$headers ne ""} {
    set selection [list]
    foreach hd $headers {
      foreach item [alited::tree::GetTree] {
        lassign $item lev cnt ID
        if {[alited::unit::GetHeader $wtree $ID] eq $hd} {
          lappend selection $ID
          break
        }
      }
    }
    $wtree selection set $selection
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
