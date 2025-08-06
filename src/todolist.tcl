#! /usr/bin/env tclsh
###########################################################
# Name:    todolist.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jun 19, 2025
# Brief:   Handles pending TODOs.
# License: MIT.
###########################################################

# _________________________ todolist ________________________ #

namespace eval todolist {
  # apave object
  variable obTdl pavedTODOlist

  # "Templates" dialogue's path
  variable win $::alited::al(WIN).todolist

  # todo list
  variable tdlist [list]

  # list of original dates
  variable tdlistOrigDates [list]

  # todo filter
  variable filter {}

  # 1st item of list
  variable item1st {}
}

# ________________________ Common _________________________ #

proc todolist::Message {msg {mode 2}} {
  # Displays a message in statusbar of templates dialogue.
  #   msg - message
  #   mode - mode of Message

  variable obTdl
  alited::Message $msg $mode [$obTdl LabMess]
}
#_______________________

proc todolist::CheckEmpty {} {
  # Checks if the TODO list is empty.

  variable tdlistOrig
  variable obTdl
  if {![llength $tdlistOrig]} {
    set txt [$obTdl TexTdl]
    alited::ini::HighlightFileText $txt .md 0 -cmd ::apave::None
    $obTdl displayText $txt "\n#   [msgcat::mc {No TODO pending!}]"
    alited::ini::HighlightFileText $txt .md 1 -cmd ::apave::None
  }
}
#_______________________

proc todolist::PrjDateCont {} {
  # Gets project name, date, todo of current tree item and item's index.

  variable tdlist
  set isel [Selected index no]
  if {![string is integer -strict $isel]} {return {}}
  lassign [lindex $tdlist $isel] prjname date todo idtd
  return [list $prjname $date $todo $isel $idtd]
}
#_______________________

proc todolist::UpdateTree {{doselect yes}} {
  # Updates the list.
  #   doselect - yes for selecting & focusing current item

  variable obTdl
  variable tdlist
  variable item1st
  set tree [$obTdl TreeTdl]
  $tree delete [$tree children {}]
  set item1st {}
  foreach tdl $tdlist {
    set item "TDL[incr itdl]"
    lassign $tdl prj date todo
    if {$date eq {}} {
      # tree branch: project name
      $tree insert {} end -id $item -text $prj -open 1 -tag tagBranch
      set parent $item
    } else {
      set values [ItemValues $item $prj $date $todo]
      $tree insert $parent end -id $item -text $date -values $values -open 1 \
        {*}[TodoTag $date]
    }
    if {$item1st eq {}} {set item1st $item}
  }
  if {$doselect} {
    after 200 [list alited::todolist::Select $item1st]
  }
}
#_______________________

proc todolist::UpdateInList {isel prjname date todo idtd} {
  # Updates tdlist's item.
  #   isel - item index in tdlist
  #   prjname - project name
  #   date - item date
  #   todo - todo's text
  #   idtd - ID of item in tdlistOrig (original tdlist)

  variable tdlist
  variable tdlistOrig
  set tdlist [lreplace $tdlist $isel $isel [list $prjname $date $todo $idtd]]
  # update original tdlist
  set ilo [set dobreak 0]
  foreach tdinfo $tdlistOrig {
    lassign $tdinfo prj rems
    set newrems [list]
    foreach rem $rems {
      incr idOr
      if {$idOr == $idtd} {
        set rem [list $date $todo]
        set dobreak 1
      }
      lappend newrems $rem
    }
    if {$dobreak} {
      set tdlistOrig [lreplace $tdlistOrig $ilo $ilo [list $prj $newrems]]
      break
    }
    incr ilo
  }
}
#_______________________

proc todolist::ItemValues {item prj date todo} {
  # Gets -values option of tree item.
  #   item - item ID
  #   prj - project name
  #   date - date of todo
  #   todo - todo text

  set todo [string map [list \n { }] $todo]
  list $todo $item $prj $date
}
#_______________________

proc todolist::TodoTag {date} {
  # Gets -tag option for current todo (highlighted or normal).
  #   date - date of todo

  set datecur [alited::project::ClockFormat [clock seconds]]
  if {$date == $datecur} {
    set tag {-tag tagBold}
  } elseif {$date < $datecur} {
    set tag {-tag tagTODO}
  } else {
    set tag {}
  }
  return $tag
}
#_______________________

proc todolist::ItemIndex {item} {
  # Gets item's index from item's ID.
  #   item - ID of item

  expr {[string range $item 3 end]-1}
}
#_______________________

proc todolist::Tooltip {ID nc} {
  # Gets a tip for tree's item.
  #   ID - ID of treeview item
  #   nc - column of treeview item

  variable obTdl
  variable tdlist
  variable tdlistOrig
  variable tdlistOrigDates
  set tree [$obTdl TreeTdl]
  lassign [$tree item $ID -values] todo item prj date
  set tip {}
  switch -- $nc {
    {#0} {
      foreach td $tdlist {
        lassign $td prj2 date2 todo2 idtd2
        if {$prj2 eq $prj && $date2 eq $date} {
          set i [lsearch -index 0 $tdlistOrigDates $idtd2]
          set dateorig [lindex $tdlistOrigDates $i 1]
          if {$dateorig ne {} && $dateorig ne $date} {
            set pad [string repeat { } 26]
            set tip "$pad\n $dateorig  =>  $date \n$pad"
          }
          break
        }
      }
    }
    {#1} {
      set i [lsearch -exact -index 0 $tdlistOrig $prj]
      set rems [lindex $tdlistOrig $i 1]
      set i [lsearch -index 0 $rems $date]
      set tip [lindex $rems $i 1]
    }
  }
  return $tip
}

# ________________________ Selections _________________________ #

proc todolist::Select {{item ""}} {
  # Selects an item of the list.
  #   item - index (ID) of list item

  variable obTdl
  variable item1st
  catch {
    set tree [$obTdl TreeTdl]
    if {$item eq {}} {set item $item1st}
    focus $tree
    $tree focus $item
    $tree selection set $item
  }
}
#_______________________

proc todolist::Selected {what {domsg yes}} {
  # Gets ID or index of currently selected item of the list.
  #   what - if "index", gets a current item's index
  #   domsg - if yes, shows a message about the selection

  variable obTdl
  set tree [$obTdl TreeTdl]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq {} && $domsg} {
    Message $::alited::al(MC,prjsel) 4
  }
  if {$isel ne {} && $what eq {index}} {
    set isel [ItemIndex $isel]
  }
  return $isel
}
#_______________________

proc todolist::onSelect {} {
  # Handles event "selecting a tree item"

  variable obTdl
  lassign [PrjDateCont] prjname date todo
  if {$prjname ne {}} {
    set wtxt [$obTdl TexTdl]
    alited::ini::HighlightFileText $wtxt .md 0 -cmdpos ::apave::None -cmd ::apave::None
    $obTdl displayText $wtxt $todo
    if {$date eq {}} {
      set readonly 1
      set procModified ::apave::None
    } else {
      set readonly 0
      set procModified alited::todolist::TextModified
    }
    alited::ini::HighlightFileText $wtxt .md $readonly -cmd $procModified
  }
}

# ________________________ Modifications _________________________ #

proc todolist::TextModified {wtxt args} {
  # Processes modifications of TODO text.
  #   wtxt - text's path
  #   args - not used arguments

  namespace upvar ::alited al al
  lassign [PrjDateCont] prjname date - isel idtd
  if {$prjname ne {}} {
    set todo [string trim [$wtxt get 1.0 end]]
    UpdateInList $isel $prjname $date $todo $idtd
    set aft _TODO_TextModified
    catch {after cancel $al($aft)}
    set al($aft) [after idle alited::todolist::TODO_save]
  }
}
#_______________________

proc todolist::TODO_save {args} {
  # Saves a reminder on a date.
  #   args - may contain project name, new date, todo

  variable obTdl
  if {[llength $args]} {
    lassign $args prjname date todo
    set txt $todo
  } else {
    lassign [PrjDateCont] prjname date todo
    set txt [$obTdl TexTdl]
  }
  set item [Selected item no]
  set values [ItemValues $item $prjname $date $todo]
  [$obTdl TreeTdl] item $item -text $date -values $values
  alited::project::Klnd_Dosave $txt $prjname $date no
}

# ________________________ Filter _________________________ #

proc todolist::FilterList {args} {
  # Filters todo list.
  #   args - when called on validation, contains current filter value

  variable tdlist
  variable tdlistOrig
  variable tdlistOrigDates
  variable obTdl
  set tdlist [list]
  set filt [string trim [lindex $args 0]]
  set onvalid [llength $args]
  set wasfilter 0
  foreach tdinfo $tdlistOrig {
    lassign $tdinfo prj rems
    lappend tdlist $prj
    set dofilter 1
    foreach rem $rems {
      incr idtd
      lassign $rem date todo
      if {$filt eq {} || [string match -nocase *$filt* $todo]} {
        lappend tdlist [list $prj $date $todo $idtd]
        set dofilter 0
      }
      if {!$onvalid} {lappend tdlistOrigDates [list $idtd $date]}
    }
    if {$dofilter} {
      set tdlist [lreplace $tdlist end end]
      set wasfilter 1
    }
  }
  if {$onvalid} {  ;# called on validation -> update the list
    UpdateTree no
    set tree [$obTdl TreeTdl]
    if {$wasfilter || [$tree selection] eq {}} {
      Select
      focus [$obTdl EntFilter]
    }
  }
  return 1
}
#_______________________

proc todolist::ClearFilter {} {
  # Clears filter's entry.

  variable filter
  set filter {}
  FilterList $filter
}

# ________________________ Tool buttons _________________________ #

proc todolist::Tool_button {ev} {
  # Fire an event handler (paste/undo/redo) on a reminder.
  #   ev - event to fire

  variable obTdl
  ::apave::eventOnText [$obTdl TexTdl] $ev
}
#_______________________

proc todolist::Paste {} {
  # Pastes a text to a reminder.

  Tool_button <<Paste>>
}
#_______________________

proc todolist::Undo {} {
  # Undoes changes of a reminder.

  Tool_button <<Undo>>
}
#_______________________

proc todolist::Redo {} {
  # Redoes changes of a reminder.

  Tool_button <<Redo>>
}
#_______________________

proc todolist::Delete {} {
  # Handles "Delete template" button.

  variable obTdl
  lassign [PrjDateCont] prjname date
  if {$date ne {}} {[$obTdl TexTdl] replace 1.0 end {}}
}
#_______________________

proc todolist::MoveTo {days} {
  # Shifts current date by *days*.
  #   days - days to shift

  variable obTdl
  variable tdlistOrig
  set item [Selected item]
  lassign [PrjDateCont] prjname date todo isel idtd
  if {$date ne {}} {
    set date2 [alited::project::ClockScan $date]
    set date2 [clock add $date2 $days days]
    set date2 [alited::project::ClockFormat $date2]
    # check if new day is free of TODO
    foreach tdinfo $tdlistOrig {
      lassign $tdinfo prj1 rems
      foreach rem $rems {
        lassign $rem date1
        incr id1
        if {$prj1 eq $prjname && $date1 eq $date2 && $id1 != $idtd} {
          # there is TODO on this day
          Message $::alited::al(MC,tododupl) 4
          return
        }
      }
    }
    TODO_save $prjname $date {}
    TODO_save $prjname $date2 $todo
    UpdateInList $isel $prjname $date2 $todo $idtd
    set tree [$obTdl TreeTdl]
    CheckSwapItems $tree $item $date2 $days
    $tree tag remove tagBold $item
    $tree tag remove tagTODO $item
    lassign [TodoTag $date2] -> tag
    if {$tag ne {}} {$tree tag add $tag $item}
    Select $item
  }
}
#_______________________

proc todolist::CheckSwapItems {tree item date days} {
  # Checks and at need swaps tree items according to dates.
  #   tree - item tree
  #   item - current item's ID
  #   date - current item's date
  #   days - if positive then swap forward, otherwise backward

  set paritem [$tree parent $item]
  set items [$tree children $paritem]
  set dir [expr {$days>0? 1 : -1}]
  set i 0
  foreach it $items {
    if {$it eq $item} {
      set itSwap [lindex $items [expr {$i+$dir}]]
      if {$itSwap eq {}} return
      set dateSwap [lindex [$tree item $itSwap -values] 3]
      if {$dir>0 && $dateSwap < $date || $dir<0 && $dateSwap > $date} {
        set items [lreplace $items $i $i]
        set items [linsert $items [incr i $dir] $item]
        break
      }
    }
    lappend newitems $it
    incr i
  }
  $tree children $paritem $items
}

# ________________________ Buttons _________________________ #

proc todolist::Ok {args} {
  # Handles "OK" button.

  lassign [PrjDateCont] prjname date todo
  if {$prjname eq {}} {
    Message $::alited::al(MC,prjsel) 4
    Select
    return
  }
  after 500 [list alited::main::ShowOutdatedTODO $prjname $date $todo 1]
  QuitDialog $prjname
}
#_______________________

proc todolist::Cancel {args} {
  # Handles "Cancel" button.

  QuitDialog {}
}
#_______________________

proc todolist::Help {args} {
  # Handles "Help" button.

  variable win
  alited::Help $win
}
#_______________________

proc todolist::QuitDialog {res} {
  # Quits the dialog.
  #   res - result (1/0 for OK/Cancel)

  variable obTdl
  variable win
  set ::alited::project::geotodolist [wm geometry $win]
  $obTdl res $win $res
}

# ________________________ UI _________________________ #

proc todolist::_create {} {
  # Creates "Pending TODO list" dialogue.

  namespace upvar ::alited al al
  variable win
  variable obTdl
  variable tdlist
  ::apave::APave create $obTdl $win
  $obTdl makeWindow $win $al(MC,prjTmore)
  $obTdl paveWindow $win {
    {fraTreeTdl - - 10 10 {-st nswe -rw 3 -pady 8} {}}
    {.TreeTdl - - - - {pack -side left -expand 1 -fill both}
      {-h 12 -columns {C1 C2 C3} -displaycolumns {C1}
      -columnoptions "#0 {-minwidth 50 -width 180 -stretch 0} C1 {-stretch 1}"
      -tip {-BALTIP {alited::todolist::Tooltip %i %c} -SHIFTX 10 -PER10 4000}
      -style TreeNoHL -onevent {
      <<TreeviewSelect>> alited::todolist::onSelect
      <Delete> alited::todolist::Delete
      <Double-Button-1> alited::todolist::Ok
      <Return> alited::todolist::Ok}}}
    {.sbvTdls + L - - {pack -side left -fill both}}
    {fra1 fraTreeTdl T 10 10 {-st nsew}}
    {.btTdel - - - - {pack -side left} {-image alimg_delete
      -com alited::todolist::Delete -tip {$al(MC,prjTdelete)}}}
    {.btTpaste - - - - {pack -side left} {-image alimg_paste
      -com alited::todolist::Paste -tip Paste}}
    {.btTundo - - - - {pack -side left} {-image alimg_undo
      -com alited::todolist::Undo -tip Undo}}
    {.btTredo - - - - {pack -side left} {-image alimg_redo
      -com alited::todolist::Redo -tip Redo}}
    {.sev - - - - {pack -side left -padx 8 -fill y}}
    {.btTprevious2 - - - - {pack -side left} {-image alimg_previous2
      -com {alited::todolist::MoveTo -7} -tip {$al(MC,prjTprevious2)}}}
    {.btTprevious - - - - {pack -side left} {-image alimg_previous
      -com {alited::todolist::MoveTo -1} -tip {$al(MC,prjTprevious)}}}
    {.btTnext - - - - {pack -side left} {-image alimg_next
      -com {alited::todolist::MoveTo 1} -tip {$al(MC,prjTnext)}}}
    {.btTnext2 - - - - {pack -side left} {-image alimg_next2
      -com {alited::todolist::MoveTo 7} -tip {$al(MC,prjTnext2)}}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 8}}
    {.labFilter - - - - {pack -side left -padx 8} {-anchor center -t Filter:}}
    {.EntFilter - - - - {pack -side left}
      {-tvar ::alited::todolist::filter -w 20
      -validate key -validatecommand {alited::todolist::FilterList %P}}}
    {.btTno - - - - {pack -side left} {-com alited::todolist::ClearFilter}}
    {fratex fra1 T 10 10 {-st nsew -rw 1 -cw 1} {}}
    {.TexTdl - - - - {pack -side left -expand 1 -fill both}
      {-h 6 -w 4 -wrap none -tabnext *.butOK
      -tip {-BALTIP {$al(MC,prjTtext)} -MAXEXP 3}}}
    {.sbvTdl + L - - pack {}}
    {LabMess fratex T 1 10 {-st nsew -pady 0 -padx 3} {-style TLabelFS
      -onevent {<Button-1> alited::todolist::ProcMessage}}}
    {fra3 + T 1 10 {-st nsew}}
    {.ButHelp - - - - {pack -side left}
      {-t {$al(MC,help)} -tip F1 -com alited::todolist::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both}}
    {.butOK - - - - {pack -side left -padx 2}
      {-t "$al(MC,select)" -com alited::todolist::Ok}}
    {.butCancel - - - - {pack -side left}
      {-t Close -com alited::todolist::Cancel}}
  }
  set tree [$obTdl TreeTdl]
  $tree heading #0 -text "$al(MC,project) / [msgcat::mc Date]"
  $tree heading #1 -text [msgcat::mc Reminder]
  alited::tree::AddTags $tree
  UpdateTree
  after 250 alited::todolist::CheckEmpty
  bind $win <F1> "[$obTdl ButHelp] invoke"
  set res [$obTdl showModal $win -onclose ::alited::todolist::Cancel \
    -parent $::alited::project::win -resizable 1 -minsize {400 250} \
    -geometry $::alited::project::geotodolist -focus $tree]
  catch {destroy $win}
  $obTdl destroy
  return $res
}
#_______________________

proc todolist::_run {tdlInput} {
  # Runs "Pending TODOs" dialogue.
  #   tdlInput - todo list

  variable win
  variable tdlistOrig
  variable tdlistOrigDates
  variable filter
  if {[winfo exists $win]} {return {}}
  set filter {}
  set tdlistOrig $tdlInput
  set tdlistOrigDates [list]
  FilterList
  set res [_create]
  return $res
}
