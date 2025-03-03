###########################################################
# Name:    favor_ls.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles favorites' lists.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval ::alited::favor_ls {
  variable obFav pavedFavs
  variable win $::alited::al(WIN).fraFavs  ;# "Favorites' list" dialogue's path
  variable favlist [list]      ;# list of favorites' lists
  variable favlistsaved [list] ;# saved list of favorites' lists
  variable favcont [list]      ;# content of current favorites' list
  variable favpla  [list]      ;# list of "where to place" of current favorites' list
  variable currents [list]     ;# content of text (current favorites)
  variable fav {}              ;# current selection of treeview of list of favorites' lists
  variable place 1             ;# variable for "where to place"
}

# ________________________ Form's buttons _________________________ #

proc favor_ls::Save_favlist {{saveini yes}} {
  # Saves favorites' list.
  #   saveini - save templates in ini-file

  variable favlist
  variable favlistsaved
  set favlistsaved $favlist
  if {$saveini} alited::ini::SaveIniPrj
}
#_______________________

proc favor_ls::Restore_favlist {} {
  # Restores favorites' list.

  variable favlist
  variable favlistsaved
  set favlist $favlistsaved
}
#_______________________

proc favor_ls::Ok {{res 0}} {
  # Handles hitting OK button.
  #   res - if 0, sets the dialogue's result from a current favorites item.

  variable obFav
  variable win
  variable favcont
  variable favpla
  alited::CloseDlg
  if {!$res || $res==4} {
    if {[set isel [Selected]] eq {}} {
      focus [$obFav LbxFav]
      return
    }
    set cont [lindex $favcont $isel]
    set isfiles [alited::favor::IsFavoritesFiles [Split $cont]]
    if {$isfiles} {set res 4}
    set pla [lindex $favpla $isel]
    if {$res!=4} {
      # list of fav.units
    } else {
      # list of files of fav.units
      if {$::alited::al(FAV,IsFavor) && !$isfiles} {
        set cont [ComposeText no {*}[Split $cont]]
      } else {
        set cont [Text]
      }
    }
    set res [list [incr pla $res] [Split $cont]]
  }
  Save_favlist
  $obFav res $win $res
}
#_______________________

proc favor_ls::Cancel {args} {
  # Handles hitting Cancel button.

  variable obFav
  variable win
  alited::CloseDlg
  Save_favlist
  $obFav res $win 0
}
#_______________________

proc favor_ls::Help {args} {
  # Handles hitting Help button.

  variable win
  alited::Help $win
}
#_______________________

proc favor_ls::HelpMe {args} {
  # 'Help' for start.

  variable win
  alited::HelpMe $win
}
#_______________________

proc favor_ls::DoubleClick {} {
  # Handles double clicking on the list:
  # in "Favorites" mode, invokes "Select" button, otherwise "Open...".

  namespace upvar ::alited al al
  variable obFav
  if {$al(FAV,IsFavor)} {set but ButOK} {set but ButOpenFile}
  [$obFav $but] invoke
}

# _______________________ List events handlers _______________________ #

proc favor_ls::Text {} {
  # Gets the text widget's content.

  variable obFav
  return [[$obFav TexFav] get 1.0 {end -1 char}]
}
#_______________________

proc favor_ls::ComposeText {isfavor args} {
  # Composes a current text of favorites or files of favorites.
  #   isfavor - "yes" to get favorites, "no" to get files of favorites
  #   args - a list of favorites
  # If args is omitted, the current favorites tree's contents will be the list.

  variable currents
  set text [set currents {}]
  set prevnames [list]
  if {![llength $args]} {set args [alited::tree::GetTree {} TreeFavor]}
  set isfiles [alited::favor::IsFavoritesFiles $args]
  foreach it $args {
    if {$text ne {}} {
      append text \n
      append currents $::alited::EOL
    }
    if {$isfiles} {
      set fname [lindex $it 1]
      if {$fname ni $prevnames} {lappend prevnames $fname}
    } elseif {$isfavor} {
      append text [lindex $it 4 0]
    } else {
      set fname [lindex $it 4 1]
      if {$fname ni $prevnames} {lappend prevnames $fname}
    }
    append currents $it
  }
  if {!$isfavor || $isfiles} {
    foreach fname [lsort -dictionary $prevnames] {
      if {$text ne {}} {append text \n}
      append text $fname
    }
  }
  return $text
}
#_______________________

proc favor_ls::DisplayText {cont} {
  # Displays text of favorites or their files.
  #   cont - text's content
  # See also: DisplayFavorText

  variable obFav
  set w [$obFav TexFav]
  $obFav readonlyWidget $w no
  $obFav displayText $w $cont
  $obFav readonlyWidget $w yes
}
#_______________________

proc favor_ls::DisplayFavorText {args} {
  # Displays text of favorites or their files.
  #   args - a list of favorites
  # See also: ComposeText, DisplayText

  namespace upvar ::alited al al
  DisplayText [ComposeText $al(FAV,IsFavor) {*}$args]
}
#_______________________

proc favor_ls::Selected {} {
  # Gets a selected item of favorites list.

  variable obFav
  if {[set isel [[$obFav LbxFav] curselection]] eq {}} {
    Message $::alited::al(MC,favsel) 4
  }
  return $isel
}
#_______________________

proc favor_ls::Select {{isel ""}} {
  # Handles a selection in the list of favorites' lists.
  #   isel - a selected item of the list

  variable obFav
  variable favlist
  variable favcont
  variable favpla
  variable fav
  variable place
  set lbx [$obFav LbxFav]
  if {$isel eq {}} {set isel [$lbx curselection]}
  if {$isel eq {} && [llength $favlist]} {set isel 0}
  if {$isel ne {} && [set fav [lindex $favlist $isel]] ne {}} {
    set place [lindex $favpla $isel]
    set cont [Split [lindex $favcont $isel]]
    DisplayFavorText {*}$cont
    Focus $isel
  }
}
#_______________________

proc favor_ls::Focus {isel} {
  # Focuses on an item of the list.
  #   isel - the item to focus on

  variable obFav
  set lbx [$obFav LbxFav]
  $lbx selection clear 0 end
  $lbx selection set $isel $isel
  $lbx see $isel
}

# ________________________ Buttons to modify  _________________________ #

proc favor_ls::Add {} {
  # Handles hitting "Add favorites' list" button.

  namespace upvar ::alited al al
  variable obFav
  variable favlist
  variable favcont
  variable favpla
  variable currents
  variable fav
  variable place
  set cont $currents
  set found no
  set isel 0
  foreach f $favlist p $favpla c $favcont {
    if {$fav eq $f || ($p eq $place && $c eq $cont)} {
      set found yes
      break
    }
    incr isel
  }
  set fav [string trim $fav]
  if {$fav ne "" && $cont ne "" && $found} {
    Message $al(MC,favexists) 4
    Select $isel
    return
  } elseif {$fav eq ""} {
    focus [$obFav EntFav]
    Message $al(MC,favent1) 4
    return
  } elseif {[string trim $cont] eq ""} {
    Message $al(MC,favent3) 4
    return
  } else {
    set isel end
    lappend favlist $fav
    lappend favcont $cont
    lappend favpla $place
    set msg [string map [list %n [llength $favlist]] $al(MC,favnew)]
    Message $msg 3
  }
  Save_favlist
  Focus $isel
}
#_______________________

proc favor_ls::AddFiles {} {
  # Adds .tcl files of current session as the favorites.

  namespace upvar ::alited al al
  variable currents
  variable place
  variable fav
  variable obFav
  if {$fav eq ""} {
    focus [$obFav EntFav]
    Message $al(MC,favent1) 4
    return
  }
  set tsel [alited::SessionTclList 1]
  set tall [alited::SessionTclList 2]
  set isel [llength $tsel]
  set iall [llength $tall]
  set msgNoTcl {No .tcl files found in the session}
  if {$iall<1} {
    Message $msgNoTcl 4
    return
  }
  set msg [msgcat::mc "\n Save as favorites list: selected (%s) or all (%a) files?\n"]
  set msg [string map [list %s $isel %a $iall] $msg]
  if {$isel>1} {set res 1} {set res 2}
  set res [$obFav misc ques $al(MC,question) $msg {Selected 1 {All files} 2 Cancel 0} $res]
  switch $res {
    1 {set tabs $tsel}
    2 {set tabs $tall}
    default {return}
  }
  # scan all .tcl to get the favorites' list from them
  set fnames [list]
  foreach tab $tabs {
    set TID [lindex $tab 0]
    set wtxt [alited::main::GetWTXT $TID]
    if {$wtxt eq {}} {
      alited::main::GetText $TID no no
    }
    set it [lindex $al(_unittree,$TID) 0]
    if {$it ne {}} {
      lappend fnames [alited::bar::FileName $TID]
    }
  }
  # create the sorted list of favorite files
  set text [set currents {}]
  foreach fname [lsort -dictionary $fnames] {
    if {$text ne {}} {
      append text \n
      append currents $::alited::EOL
    }
    append text $fname
    append currents [list FILE $fname]
  }
  if {$text eq {}} {
    Message $msgNoTcl 4
  } else {
    DisplayText $text
    Add
  }
}
#_______________________

proc favor_ls::Change {} {
  # Handles hitting "Change favorites' list" button.

  namespace upvar ::alited al al
  variable favlist
  variable favpla
  variable favcont
  variable place
  variable fav
  variable currents
  if {[set isel [Selected]] eq {}} return
  if {[set isl1 [lsearch -exact $favlist $fav]]!=$isel && $isl1!=-1} {
    Message $al(MC,favexists) 4
    Select $isl1
  } else {
    set favlist [lreplace $favlist $isel $isel $fav]
    set favpla [lreplace $favpla $isel $isel $place]
    set favcont [lreplace $favcont $isel $isel $currents]
    set msg [string map [list %n [incr isel]] $al(MC,favupd)]
    Message $msg 3
    Save_favlist
  }
}
#_______________________

proc favor_ls::Delete {} {
  # Handles hitting "Delete favorites' list" button.

  namespace upvar ::alited al al
  variable favlist
  variable favcont
  variable favpla
  if {[set isel [Selected]] eq ""} return
  set nsel [expr {$isel+1}]
  set msg [string map [list %n $nsel] $al(MC,favdelq)]
  if {![alited::msg yesno warn $msg NO -title $al(MC,warning)]} {
    return
  }
  set favlist [lreplace $favlist $isel $isel]
  set favcont [lreplace $favcont $isel $isel]
  set favpla [lreplace $favpla $isel $isel]
  set llen [expr {[llength $favlist]-1}]
  if {$isel>$llen} {set isel $llen}
  if {$llen>=0} {Select $isel}
  set msg [string map [list %n $nsel] $al(MC,favrem)]
  Message $msg 3
  Save_favlist
}
#_______________________

proc favor_ls::Message {msg {mode 2}} {
  # Displays a message in statusbar of favorites dialogue.
  #   msg - message
  #   mode - mode of Message

  variable obFav
  alited::Message $msg $mode [$obFav LabMess]
}
#_______________________

proc favor_ls::ProcMessage {} {
  # Handles clicking on message label.

  variable obFav
  set msg [baltip cget [$obFav LabMess] -text]
  Message $msg 3
}

# ________________________ Ini data _________________________ #

proc favor_ls::Split {lines} {
  # Splits a saved list by the list's dividers.

  return [split [::alited::ProcEOL $lines in] \n]
}
#_______________________

proc favor_ls::IniFile {} {
  # Returns the ini file's name to store favorites' lists.

  return [file join $::alited::INIDIR favor_ls.ini]
}
#_______________________

proc favor_ls::GetIni {lines} {
  # Reads favorites' lists data, stored in the ini file.

  variable favlist
  variable favlistsaved
  variable favcont
  variable favpla
  variable currents
  variable fav
  variable place
  set lines [Split $lines]
  if {[llength $lines]<3} {
    # initialize arrays
    set favlist [list]
    set favlistsaved [list]
    set favcont [list]
    set favpla  [list]
    set currents [list]
    set fav {}
    set place 1
  } elseif {[set cont [lrange $lines 2 end]] ne {}} {
    lappend favlist [lindex $lines 0]
    lappend favpla  [lindex $lines 1]
    lappend favcont [join $cont $::alited::EOL]
  }
  Save_favlist no
}
#_______________________

proc favor_ls::PutIni {} {
  # Makes favorites' lists data to store to the ini file.

  variable favlist
  variable favcont
  variable favpla
  Restore_favlist
  set res [list]
  foreach fav $favlist pla $favpla cont $favcont {
    set r1 $fav
    append r1 $::alited::EOL
    append r1 $pla
    append r1 $::alited::EOL
    append r1 $cont
    lappend res $r1
  }
  return $res
}

# ________________________ Main _________________________ #

proc favor_ls::_create {} {
  # Creates "Favorites lists" dialogue.

  namespace upvar ::alited al al favgeometry favgeometry
  variable obFav
  variable win
  variable favlist
  variable fav
  set tipson [baltip::cget -on]
  baltip::configure -on $al(TIPS,SavedFavorites)
  if {$al(FAV,IsFavor)} {set forget {}} {set forget forget}
  ::apave::APave create $obFav $win
  $obFav makeWindow $win $al(MC,FavLists)
  $obFav paveWindow $win {
    {fraLbxFav - - 1 2 {-st nswe -rw 1 -pady 4} {}}
    {.fra - - - - {pack $forget -side right -fill both} {}}
    {.fra.btTAd - - - - {pack -side top -anchor n} {-com ::alited::favor_ls::Add
      -tip "Add a list of favorites" -image alimg_add-big}}
    {.fra.btTChg - - - - {pack -side top} {-com ::alited::favor_ls::Change
      -tip "Change a list of favorites" -image alimg_change-big}}
    {.fra.btTDel - - - - {pack -side top} {-com ::alited::favor_ls::Delete
      -tip "Delete a list of favorites" -image alimg_delete-big}}
    {.fra.v_ - - - - {pack -side top -expand 1 -fill y}}
    {.fra.btTFil - - - - {pack $forget -side top} {-com ::alited::favor_ls::AddFiles
      -tip "Add .tcl files of current session\nas the favorites"
      -image alimg_plus-big}}
    {.fra.btTCur - - - - {pack $forget -side top} {
      -com ::alited::favor_ls::DisplayFavorText
      -tip "$al(MC,currfavs)" -image alimg_heart-big}}
    {.LbxFav - - - - {pack -side left -expand 1 -fill both}
      {-h 10 -w 40 -lvar ::alited::favor_ls::favlist -onevent {
      <<ListboxSelect>> ::alited::favor_ls::Select
      <FocusIn> ::alited::favor_ls::Select
      <Double-Button-1> ::alited::favor_ls::DoubleClick
      <Return> ::alited::favor_ls::DoubleClick}}}
    {.sbvFavs + L - - {pack -side left -fill y} {}}
    {fra1 fraLbxFav T 1 2 {-st nswe}}
    {.h_ - - 1 1 {pack -side top -expand 1 -fill both -pady 10}}
    {fra1.fraEnt - - 1 1 {pack -side top -expand 1 -fill both -pady 4}}
    {.labFav - - 1 1 {pack $forget -side left -padx 4} {-t "$al(MC,currfavs):"}}
    {.EntFav - - 1 1 {pack $forget -side left -expand 1 -fill both}
      {-tvar ::alited::favor_ls::fav -tip {$al(MC,favent1)}}}
    {fratex fra1 T 1 2 {-st nswe -rw 1 -cw 1}}
    {.TexFav - - - - {pack -side left -expand 1 -fill both} {-h 10 -w 72
      -tip "Favorites of the current list" -ro 1 -wrap none}}
    {.sbvFav + L - - {pack -side left -fill y}}
    {fra2 fratex T 1 2 {-st nswe} {-padding {5 5 5 5} -relief groove}}
    {.labBA - - - - {pack $forget -side left} {-t "Non-favorite files to be:"}}
    {.radA - - - - {pack $forget -side left -padx 8}
      {-t kept -var ::alited::favor_ls::place -value 1
      -tip "Doesn't close any tab without favorites\nat choosing Favorites' list"}}
    {.radB - - - - {pack $forget -side left -padx 8}
      {-t closed -var ::alited::favor_ls::place -value 2
      -tip "Closes all tabs without favorites\nat choosing Favorites' list"}}
    {LabMess fra2 T 1 2 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {fra3 + T 1 2 {-st nswe}}
    {.ButHelp - - - - {pack -side left} {-t {$al(MC,help)} -tip F1 -com ::alited::favor_ls::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 4}}
    {.ButOK - - - - {pack $forget -side left} {-t "$al(MC,select)" -com ::alited::favor_ls::Ok}}
    {.ButOpenFile - - - - {pack -side left -padx 2} {-t Open...
      -com {alited::favor_ls::Ok 4} -tip {Opens files with current favorites.}}}
    {.butUndo - - - - {pack $forget -side left} {-t Back -com {alited::favor_ls::Ok 3}
      -tip "Sets a list of Favorites\nthat was active initially."}}
    {.butCancel - - - - {pack -side left -padx 2} {-t Cancel -com ::alited::favor_ls::Cancel}}
  }
  set fav {}
  set lbx [$obFav LbxFav]
  DisplayFavorText
  Restore_favlist
  if {!$al(FAV,IsFavor)} {after idle "alited::favor_ls::Select 0 ; focus $lbx"}
  bind $win <F1> "[$obFav ButHelp] invoke"
  bind [$obFav LabMess] <Button-1> alited::favor_ls::ProcMessage
  after 500 ::alited::favor_ls::HelpMe ;# show an introduction after a short pause
  set geo {-resizable 1 -minsize {600 400}}
  if {$favgeometry ne {}} {append geo " -geometry $favgeometry"}
  set res [$obFav showModal $win -onclose ::alited::favor_ls::Cancel \
    -focus [$obFav EntFav] {*}$geo]
  set favgeometry [wm geometry $win]
  baltip::configure {*}$tipson
  catch {destroy $win}
  $obFav destroy
  return $res
}
#_______________________

proc favor_ls::_run {} {
  # Runs "Favorites lists" dialogue.

  variable win
  if {[winfo exists $win]} {return 0}
  set res [_create]
  return $res
}

# _________________________________ EOF _________________________________ #
