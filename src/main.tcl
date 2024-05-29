###########################################################
# Name:    main.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/20/2021
# Brief:   Handles the main form of alited.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval main {
  variable findunits 1     ;# where to find units: 1 current file, 2 all
  variable gotoline1 {}    ;# line number of "Go to Line" dialogue
  variable gotoline2 {}    ;# units list of "Go to Line" dialogue
  variable gotolineTID {}  ;# tab ID last used in "Go to Line" dialogue
  variable wcan {} fgcan {} bgcan {}   ;# canvas' path and its colors
  variable saveini no      ;# flag "save alited.ini"
}

# ________________________ Common _________________________ #

proc main::CurrentWTXT {} {
  # Gets a current text widget's path.

  return [lindex [alited::bar::GetBarState] 2]
}
#_______________________

proc main::GetWTXT {TID} {
  # Gets a text widget's path of a tab.
  #   TID - ID of the tab

  return [alited::bar::GetTabState $TID --wtxt]
}
#_______________________

proc main::ClearCbx {cbx varname} {
  # Clears a combobox's value and removes it from the combobox' list.
  #   cbx - the combobox's path
  #   varname - name of variable used in the current namespace

  set val [string trim [$cbx get]]
  set values [$cbx cget -values]
  if {[set i [lsearch -exact $values $val]]>-1} {
    set values [lreplace $values $i $i]
    $cbx configure -values $values
  }
  set $varname $values
}
#_______________________

proc main::SetTabs {wtxt indent} {
  # Configures tabs of a text.
  #   wtxt - text's path
  #   indent - indentation (= tab's length)

  namespace upvar ::alited al al
  set texttabs [expr {$indent * [font measure $al(FONT,txt) 0]}]
  $wtxt configure -tabs "$texttabs left" -tabstyle wordprocessor
}

# ________________________ Get and show text widget _________________________ #

proc main::GetText {TID {doshow no} {dohighlight yes}} {
  # Creates or gets a text widget for a tab.
  #   TID - tab's ID
  #   doshow - flag "this widget should be displayed"
  #   dohighlight - flag "this text should be highlighted"
  # Returns a list of: curfile (current file name),
  # wtxt (text's path), wsbv (scrollbar's path),
  # pos (cursor's position), doinit (flag "initialized")
  # dopack (flag "packed")
  # selrange (selected text's range)

  namespace upvar ::alited al al obPav obPav
  set curfile [alited::bar::FileName $TID]
  # initial text and its scrollbar:
  set wtxt [$obPav Text]
  set wsbv [$obPav SbvText]
  # get data of the current tab
  lassign [alited::bar::GetBarState] TIDold fileold wold1 wold2
  lassign [alited::bar::GetTabState $TID --pos --selection --wrap] pos selrange wrap
  set doreload no  ;# obsolete
  set doinit yes
  if {$TIDold eq {-1} && $TID eq {tab0}} {
    ;# first text to edit in original Text widget: create its scrollbar
    BindsForText $TID $wtxt
    ::apave::logMessage "first $curfile"
  } elseif {[GetWTXT $TID] ne {}} {
    # edited text: get its widgets' data
    lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
    set doinit no
  } else {
    # till now, not edited text: create its own Text/SbvText widgets
    append wtxt "_$TID"  ;# new text
    append wsbv "_$TID"  ;# new scrollbar
  }
  if {![string is double -strict $pos]} {set pos 1.0}
  # check for previous text and hide it, if it's not the selected one
  set dopack [expr {$TID ne $TIDold}]
  alited::bar::SetTabState $TID --fname $curfile --wtxt $wtxt --wsbv $wsbv
  # create the text and the scrollbar if new
  if {![winfo exists $wtxt]} {
    lassign [GutterAttrs] canvas width shift
    set texopts [lindex [::apave::defaultAttrs tex] 1]
    lassign [::apave::extractOptions texopts -selborderwidth 1] selbw
    text $wtxt {*}$texopts
    $wtxt tag configure sel -borderwidth $selbw
    $obPav themeNonThemed [winfo parent $wtxt]
    set bind [list $obPav fillGutter $wtxt $canvas $width $shift]
    bind $wtxt <Configure> $bind
    if {[trace info execution $wtxt] eq {}} {
      trace add execution $wtxt leave $bind
    }
    ttk::scrollbar $wsbv -orient vertical -takefocus 0
    $wtxt configure -yscrollcommand "$wsbv set"
    $wsbv configure -command "$wtxt yview"
    BindsForText $TID $wtxt
  }
  if {[winfo exists $wold1]} {
    # previous text: save its state
    alited::bar::SetTabState $TIDold --pos [$wold1 index insert] --selection [$wold1 tag ranges sel]
    if {$dopack && $doshow} {
      # hide both previous
      pack forget $wold1  ;# a text
      pack forget $wold2  ;# a scrollbar
      after idle update
    }
  }
  # show the selected text
  if {$doshow} {
    alited::bar::SetBarState [alited::bar::CurrentTabID] $curfile $wtxt $wsbv
  }
  if {$doinit} {
    # if the file isn't read yet, read it and initialize its highlighting
    if {$al(prjindent)>1 && $al(prjindent)<9 && !$al(prjindentAuto)} {
      SetTabs $wtxt $al(prjindent)
    }
    alited::file::DisplayFile $TID $curfile $wtxt $doreload
    RestoreMarks $curfile $wtxt
    if {$al(prjindentAuto)} {
      SetTabs $wtxt [lindex [CalcIndentation $wtxt] 0]
    }
    if {$doshow} {
      HighlightText $TID $curfile $wtxt
    } else {
      alited::file::MakeThemHighlighted $TID  ;# postpone the highlighting till a show
    }
  } elseif {$dohighlight && [alited::file::ToBeHighlighted $wtxt]} {
    HighlightText $TID $curfile $wtxt
    if {$al(TREE,isunits)} alited::tree::RecreateTree
  }
  return [list $curfile $wtxt $wsbv $pos $doinit $dopack $selrange $wrap]
}
#_______________________

proc main::ShowText {} {
  # Displays a current text.

  namespace upvar ::alited al al obPav obPav
  set TID [alited::bar::CurrentTabID]
  lassign [GetText $TID yes] curfile wtxt wsbv pos doinit dopack selrange wrap
  if {$dopack} {
    PackTextWidgets $wtxt $wsbv
  }
  if {$doinit || $dopack} {
    # for newly displayed text: create also its unit tree
    set al(TREE,units) no
    alited::tree::Create
  }
  FocusText $TID $pos
  if {[set itemID [alited::tree::NewSelection]] ne {}} {
    # if a new unit is selected, show it in the unit tree
    set wtree [$obPav Tree]
    $wtree see $itemID
    # this code below redraws the tree's scrollbar
    $wtree configure -yscrollcommand [$wtree cget -yscrollcommand]
  }
  focus $wtxt
  if {$selrange ne {}} {
    catch {$wtxt tag add sel {*}$selrange}
  }
  if {$wrap eq {none}} {
    alited::bar::SetTabState $TID --wrap {}  ;# because it's the very first enter
    alited::file::WrapLines yes
  }
  # update "File" menu and app's header
  alited::menu::CheckMenuItems
  ShowHeader
}

# ________________________ Updating gutter & text _________________________ #

proc main::UpdateGutter {} {
  # Redraws the gutter.

  namespace upvar ::alited obPav obPav
  set wtxt [CurrentWTXT]
  after idle [list after 0 "$obPav fillGutter $wtxt"]
}
#_______________________

proc main::GutterAttrs {} {
  # Returns list of gutter's data (canvas widget, width, shift)

  namespace upvar ::alited al al obPav obPav
  return [list [$obPav GutText] $al(ED,gutterwidth) $al(ED,guttershift)]
}
#_______________________

proc main::UpdateText {{wtxt {}} {curfile {}}} {
  # Redraws a text.
  #   wtxt - the text widget's path
  #   curfile - file name of the text

  namespace upvar ::alited obPav obPav
  if {$wtxt eq {}} {set wtxt [CurrentWTXT]}
  if {$curfile eq {}} {set curfile [alited::bar::FileName]}
  if {[alited::file::IsClang $curfile]} {
    ::hl_c::hl_text $wtxt
  } else {
    ::hl_tcl::hl_text $wtxt
  }
}
#_______________________

proc main::UpdateTextGutter {} {
  # Redraws both a text and a gutter.

  UpdateGutter
  UpdateText
}
#_______________________

proc main::UpdateUnitTree {} {
  # Redraws unit tree at need.

  set fname [alited::bar::FileName]
  if {$::alited::al(TREE,isunits) && [alited::file::IsUnitFile $fname]} {
    alited::tree::RecreateTree
  }
}
#_______________________

proc main::UpdateAll {{headers {}}} {
  # Updates tree, text and gutter.
  #   headers - headers of all selected units

  alited::tree::RecreateTree {} $headers
  UpdateTextGutter
  HighlightLine
}
#_______________________

proc main::UpdateTextGutterTree {} {
  # Updates after replacements: text, gutter, unit tree.

  UpdateTextGutter
  UpdateUnitTree
}
#_______________________

proc main::UpdateIcons {} {
  # Updates after replacements: icons.

  alited::bar::OnTabSelection [alited::bar::CurrentTabID]
}
#_______________________

proc main::UpdateTextGutterTreeIcons {} {
  # Updates after replacements: text, gutter, unit tree, icons.

  UpdateTextGutterTree
  UpdateIcons
}

# ________________________ Mark bar _________________________ #

proc main::FillMarkBar {args} {
  # Fills the mark bar, makes bindings for its tags.
  #   args - if set, contains canvas' path
  # It's run from InitActions without *args*.
  # See also: InitActions

  namespace upvar ::alited al al obPav obPav
  variable wcan
  variable fgcan
  variable bgcan
  lassign [MarkOptions] N
  if {[llength $args]} {
    lassign $args wcan
    $wcan create rectangle "0 0 99 9999" -fill $bgcan -outline $bgcan
    return
  }
  lassign [split [winfo geometry [$obPav Text]] x+] -> h
  set hp [expr {int($h/$N-0.5)}]
  $wcan configure -highlightbackground $bgcan -highlightthickness 0
  for {set i 0; set y 1} {$i<($N+1)} {incr i} {
    lassign [MarkOptions $i] -> tip mark
    set y2 [expr {$y+$hp}]
    if {$i==$N} {incr y2 9999}
    set al($mark) [$wcan create rectangle "1 $y 99 $y2" -fill $bgcan -outline $fgcan]
    if {$i<$N} {
      $wcan bind $al($mark) <ButtonPress-1> "alited::main::SetMark $i"
      $wcan bind $al($mark) <ButtonPress-3> "alited::main::UnsetMark $i %X %Y"
      UnsetOneMark $i
    }
    incr y $hp
  }
}
#_______________________

proc main::UpdateMarkBar {} {
  # Updates mark bar at changing -bg color.

  namespace upvar ::alited al al
  lassign [MarkOptions] N
  for {set i 0} {$i<$N} {incr i} {
    lassign [MarkOptions $i] - - - markdata
    if {![info exists al($markdata)]} {UnsetOneMark $i}
  }
}
#_______________________

proc main::SetMark {idx} {
  # Sets a mark in the mark bar.
  #   idx - index of tag used as the mark

  namespace upvar ::alited al al
  variable wcan
  lassign [MarkOptions $idx] -> tip mark markdata colors
  $wcan itemconfigure $al($mark) -fill [lindex $colors $idx]
  set tag MARK$idx
  if {[info exists al($markdata)]} {
    lassign $al($markdata) fname pos
    set TID [alited::file::OpenFile $fname]
    if {$TID ne {}} {
      set wtxt [GetWTXT $TID]
      lassign [$wtxt tag ranges $tag] pos2
      if {[string is double -strict $pos2]} {set pos $pos2}
      after idle "::tk::TextSetCursor $wtxt $pos ; alited::main::UpdateAll"
    }
  } else {
    set fname [alited::bar::FileName]
    set wtxt [CurrentWTXT]
    set pos [$wtxt index insert]
    set nl [expr {int($pos)}]
    set al($markdata) [list $fname $pos $wtxt $tag]
    set line [string trim [$wtxt get $nl.0 $nl.end]]
    set lmax 50
    if {[string length $line]>$lmax} {
      set line [string range $line 0 $lmax]...
    }
    set tip [string trim "[file tail $fname] $nl:\n$line"]
    ::baltip::tip $wcan $tip -ctag $al($mark) -shiftX 10 -pause 0
    ::baltip repaint $wcan
  }
  catch {$wtxt tag delete $tag}
  $wtxt tag add $tag $pos
}
#_______________________

proc main::UnsetMark {idx X Y} {
  # Unsets a mark in the mark bar or call a popup menu.
  #   idx - index of tag used as the mark
  #   X - X-coordinate of pointer
  #   Y - Y-coordinate of pointer

  namespace upvar ::alited al al
  variable wcan
  set disabletips no
  lassign [MarkOptions $idx] N tip mark markdata
  if {[info exists al($markdata)]} {
    set disabletips yes
    UnsetOneMark $idx
  } else {
    set disabletips yes
    set popm $al(WIN).popmMARK
    catch {destroy $popm}
    menu $popm -tearoff 1 -title $al(MC,marks)
    $popm add command -label [msgcat::mc {Clear All}] \
      -command "alited::main::UnsetAllMarks"
    $popm add separator
    set lab [msgcat::mc Width]
    $popm add command -label "$lab +" -command "alited::main::MarkWidth 1"
    $popm add command -label "$lab -" -command "alited::main::MarkWidth -1"
    $popm add separator
    $popm add command -label $al(MC,help) -command {alited::HelpAlited #bookmark}
    tk_popup $popm $X $Y
  }
  if {$disabletips && ![info exists al(MARK_TIPOFF)]} {
    # disable all default tips on empty marks
    set al(MARK_TIPOFF) 1
    for {set i 0} {$i<$N} {incr i} {
      lassign [MarkOptions $i] - - - data
      if {![info exists al($data)]} {
        UnsetOneMark $i
      }
    }
  }
}
#_______________________

proc main::MarkWidth {i} {
  # Change the mark bar's width.
  #   i - 1/-1 to increment/decrement

  namespace upvar ::alited al al
  variable wcan
  variable saveini
  set width [$wcan cget -width]
  incr width $i
  if {$width>=5 && $width<=99} {
    $wcan configure -width $width
    set al(markwidth) $width
    set saveini yes
    after 3000 alited::main::MarkWidthSave
  } else {
    bell
  }
}
#_______________________

proc main::MarkWidthSave {} {
  # Saves alited.ini at need.

  variable saveini
  if {$saveini} {
    set saveini no
    alited::ini::SaveIni
  }
}
#_______________________

proc main::UnsetOneMark {idx} {
  # Unsets one mark in the mark bar.
  #   idx - index of tag used as the mark

  namespace upvar ::alited al al
  variable wcan
  variable bgcan
  lassign [MarkOptions $idx] N tip mark markdata
  $wcan itemconfigure $al($mark) -fill $bgcan
  ::baltip::tip $wcan $tip -ctag $al($mark) -shiftX 10
  catch {
    lassign $al($markdata) fname pos wtxt tag
    unset al($markdata)
    $wtxt tag delete $tag
  }
}
#_______________________

proc main::UnsetAllMarks {} {
  # Unsets all marks in the mark bar.

  variable wcan
  variable bgcan
  lassign [MarkOptions] N
  for {set i 0} {$i<$N} {incr i} {
    UnsetOneMark $i
  }
}
#_______________________

proc main::SaveMarks {wtxt} {
  # Saves mark data for a text to be closed.
  #   wtxt - text's path

  namespace upvar ::alited al al
  foreach tag [$wtxt tag names] {
    if {[string match MARK* $tag]} {
      set idx [string range $tag 4 end]
      lassign [MarkOptions $idx] -> tip mark markdata
      catch {
        lassign $al($markdata) fname pos
        lassign [$wtxt tag ranges $tag] pos
        set al($markdata) [list $fname $pos $wtxt $tag]
      }
    }
  }
}
#_______________________

proc main::RestoreMarks {fname wtxt} {
  # Restores mark data for a text to be shown.
  #   fname - file name
  #   wtxt - text's path

  namespace upvar ::alited al al
  lassign [MarkOptions] N
  for {set i 0} {$i<$N} {incr i} {
    lassign [MarkOptions $i] N tip mark markdata
    if {[info exists al($markdata)]} {
      lassign $al($markdata) fname2 pos
      if {$fname eq $fname2} {
        set tag MARK$i
        set al($markdata) [list $fname $pos $wtxt $tag]
        catch {$wtxt tag delete $tag}
        $wtxt tag add $tag $pos
      }
    }
  }
}
#_______________________

proc main::MarkOptions {{idx 0}} {
  # Returns options for marks.
  #   idx - index of tag

  namespace upvar ::alited al al obPav obPav
  variable fgcan
  variable bgcan
  lassign [$obPav csGet] - - - bgcan - - - - fgcan
  if {!$al(TIPS,Marks) || [info exists al(MARK_TIPOFF)]} {
    set tip {}
  } else {
    set tip [msgcat::mc "Left click sets / goes to a mark.\nRight click clears it."]
  }
  # 12 greenish
  lappend colors #00ff00 #00f500 #00eb00 #00e100 #00d700 #00cd00
  lappend colors #00c300 #00b900 #00af00 #00a500 #009b00 #009100
  # 12 reddish
  lappend colors #910000 #9b0000 #a50000 #af0000 #b90000 #c30000
  lappend colors #cd0000 #d70000 #e10000 #eb0000 #f50000 #ff0000
  list [llength $colors] $tip MARK,$idx MARKDATA,$idx $colors
}

# ________________________ Focus _________________________ #

proc main::FocusText {args} {
  # Sets a focus on a current text.
  #   args - contains tab's ID and a cursor position.

  namespace upvar ::alited al al obPav obPav
  lassign $args TID pos
  if {$pos eq {}} {
    set wtxt [CurrentWTXT]
    set TID [alited::bar::CurrentTabID]
    set pos [$wtxt index insert]
  } else {
    set wtxt [GetWTXT $TID]
  }
  # find a current unit/file in the tree
  set ::alited::tree::doFocus no
  set wtree [$obPav Tree]
  catch {
    if {$al(TREE,isunits)} {
      # search the tree for a unit with current line of text
      set itemID [alited::tree::CurrentItemByLine $pos]
    } else {
      # search the tree for a current file
      set fname [alited::bar::FileName]
      set wtree [$obPav Tree]
      while {1} {
        incr iit
        set ID [alited::tree::NewItemID $iit]
        if {![$wtree exists $ID]} break
        lassign [$wtree item $ID -values] -> tip isfile
        if {$tip eq $fname} {
          set itemID $ID
          break
        }
      }
    }
  }
  # display a current item of the tree
  catch {
    if {$itemID ni [$wtree selection]} {$wtree selection set $itemID}
    after 10 alited::tree::SeeSelection
  }
  # focus on the text
  catch {focus -force $wtxt}
  catch {::tk::TextSetCursor $wtxt $pos}
  after idle {set ::alited::tree::doFocus yes}
}
#_______________________

proc main::FocusInText {TID wtxt} {
  # Processes <FocusIn> event on the text.
  #   TID - tab's ID
  #   wtxt - text widget's path

  namespace upvar ::alited obPav obPav
  if {![alited::bar::BAR isTab $TID]} return
  catch {
    CursorPos $wtxt
    [$obPav TreeFavor] selection set {}
    alited::file::OutwardChange $TID
  }
}

# ________________________ Highlight _________________________ #

proc main::HighlightText {TID curfile wtxt} {
  # Highlights a file's syntax constructs.
  #   TID - tab's ID
  #   curfile - file name
  #   wtxt - text widget's path
  # Depending on a file name, Tcl or C highlighter is called.

  namespace upvar ::alited al al obPav obPav
  # the language (Tcl or C) is defined by the file's extension
  set ext [string tolower [file extension $curfile]]
  set itwas [info exists al(HL,$wtxt)]
  if {!$itwas || $al(HL,$wtxt) ne $ext} {
    if {$itwas} {
      # remove old syntax
      foreach tag [$wtxt tag names] {
        if {![string match hil* $tag] && $tag ni {sel fndTag}} {
          $wtxt tag delete $tag
        }
      }
    }
    set clrnams [::hl_tcl::hl_colorNames]
    set clrCURL [lindex [$obPav csGet] 16]
    # get a color list for the highlighting Tcl and C
    foreach lng {{} C} {
      foreach nam $clrnams {
        lappend "${lng}colors" $al(ED,${lng}$nam)
      }
      lappend "${lng}colors" $clrCURL
    }
    if {[alited::file::IsClang $curfile]} {
      lassign [::hl_tcl::addingColors] -> clrCMN2
      lappend Ccolors $clrCMN2
      ::hl_c::hl_init $wtxt -dark [$obPav csDark] \
        -multiline 1 -keywords $al(ED,CKeyWords) \
        -cmd "::alited::edit::Modified $TID" \
        -cmdpos ::alited::main::CursorPos \
        -font $al(FONT,txt) -colors $Ccolors
    } else {
      lassign [alited::ExtTrans $curfile] -> istrans
      set pltext [expr {$istrans || ![alited::file::IsTcl $curfile]}]
      if {$pltext} {
        set plcom [alited::HighlightAddon $wtxt $curfile $colors]
        if {$plcom ne {}} {set pltext 0}
      } else {
        set plcom {}
      }
      ::hl_tcl::hl_init $wtxt -dark [$obPav csDark] \
        -multiline $al(prjmultiline) -keywords $al(ED,TclKeyWords) \
        -cmd "::alited::edit::Modified $TID" \
        -cmdpos ::alited::main::CursorPos \
        -plaintext $pltext -plaincom $plcom \
        -font $al(FONT,txt) -colors $colors
    }
    UpdateText $wtxt $curfile
    BindsForCode $wtxt $curfile
  }
  set al(HL,$wtxt) $ext
}
#_______________________

proc main::HighlightLine {} {
  # Highlights a current line of a current text.

  set wtxt [CurrentWTXT]
  if {[alited::file::IsClang [alited::bar::FileName]]} {
    ::hl_c::hl_line $wtxt
  } else {
    ::hl_tcl::hl_line $wtxt
  }
}

# ________________________ Line _________________________ #

proc main::CursorPos {wtxt args} {
  # Displays a current text's row and column in the status bar.
  #   wtxt - text widget's path
  #   args - contains a cursor position,

  namespace upvar ::alited obPav obPav
  if {![winfo exists $wtxt]} return
  if {$args eq {}} {set args [$wtxt index {end -1 char}]}
  lassign [split [$wtxt index insert] .] r c
  set R [expr {int([lindex $args 0])}]
  set c [incr c]
  set wrow [$obPav Labstat1]
  set wcol [$obPav Labstat2]
  set textrow "$r / $R"
  set textcol "$c"
  ::baltip tip $wrow $textrow
  ::baltip tip $wcol $textcol
  if {$R>99999} {set textrow "$r / *****"}
  if {$c>9999} {set textcol ****}
  $wrow configure -text $textrow
  $wcol configure -text $textcol
  alited::tree::SaveCursorPos
  alited::edit::RectSelection 1
}
#_______________________

proc main::InsertLine {} {
  # Puts a new line into a text, attentive to a previous line's indentation.

  set wtxt [CurrentWTXT]
  set ln [expr {int([$wtxt index insert])}]
  set line [$wtxt get $ln.0 $ln.end]
  set leadsp [obj leadingSpaces $line]
  if {[string index [string trimleft $line] 0] eq "\}"} {
    incr leadsp [lindex [CalcIndentation] 0]
  }
  $wtxt insert $ln.0 "[string repeat { } $leadsp]\n"
  set pos $ln.$leadsp
  ::tk::TextSetCursor $wtxt $pos
}
#_______________________

proc main::GotoBracket {{frommenu no}} {
  # Processes Alt+B keypressing: "go to a matched bracket".
  #   frommenu - yes, if run from a menu

  # search a pair for a bracket highlighted
  set wtxt [CurrentWTXT]
  if {[llength [set tagged [$wtxt tag ranges tagBRACKET]]]==4} {
    set p [$wtxt index insert]
    set p1 [$wtxt index "$p +1c"]
    set p2 [$wtxt index "$p -1c"]
    foreach {pos1 pos2} $tagged {
      if {[incr -]==2 || ($pos1!=$p && $pos1!=$p1 && $pos1!=$p2)} {
        FocusText [alited::bar::CurrentTabID] $pos1
        if {$frommenu} SaveVisitInfo
        break
      }
    }
  }
}
#_______________________

proc main::GotoLine {} {
  # Processes Ctrl+G keypressing: "go to a line".

  namespace upvar ::alited al al obDl2 obDl2
  set head [msgcat::mc {Go to Line}]
  set prompt1 [msgcat::mc {Line number:}]
  set prompt2 [msgcat::mc {    In unit:}]
  set wtxt [CurrentWTXT]
  set ln 1 ;#[expr {int([$wtxt index insert])}]
  set lmax [expr {int([$wtxt index "end -1c"])}]
  set units [list]
  set TID [alited::bar::CurrentTabID]
  foreach it $al(_unittree,$TID) {
    lassign $it lev leaf fl1 title l1 l2
    if {$leaf && [set title [string trim $title]] ne {}} {
      lappend units $title
    }
  }
  set ::alited::main::gotoline2 [linsert [lsort -nocase $units] 0 {}]
  if {$::alited::main::gotolineTID ne $TID} {
    set ::alited::main::gotoline1 {}
    set ::alited::main::gotolineTID $TID
  }
  after 300 {catch {bind [apave::dlgPath] <F1> {alited::HelpAlited #units5}}}
  lassign [$obDl2 input {} $head [list \
    spx "{$prompt1} {} {-from 1 -to $lmax -selected yes}" "{$ln}" \
    cbx "{$prompt2} {} {-tvar ::alited::main::gotoline1 -state readonly -h 16 -w 25}" \
      "{$::alited::main::gotoline1} $::alited::main::gotoline2" \
  ]] res ln unit
  if {$res} {
    set ::alited::main::gotoline1 $unit
    if {$unit ne {}} {
      # for a chosen unit - a relative line number
      if {[set it [lsearch -index 3 $al(_unittree,$TID) $unit]] >- 1} {
        lassign [lindex $al(_unittree,$TID) $it] lev leaf fl1 title l1 l2
        set l $l1
        set fst 1
        foreach line [split [$wtxt get $l1.0 $l2.end] \n] {
          # gentlemen, use \ for continuation of long lines & strings!
          set continued [expr {[string index $line end] eq "\\"}]
          if {!$continued || $fst} {
            if {$fst} {
              set l $l1
              if {[incr ln -1]<1} break
            }
            set fst [expr {!$continued}]
          }
          incr l1
        }
        set ln $l
      }
    }
    after 200 " \
      alited::main::FocusText $TID $ln.0 ; \
      alited::tree::NewSelection {} $ln.0 yes; \
      alited::main::HighlightLine"
  }
}

# ________________________ Event handlers _________________________ #

proc main::SaveVisitInfo {{wtxt ""} {K ""} {s 0}} {
  # Remembers data about current unit.
  #   wtxt - text's path
  #   K - key pressed (to check keypressings)
  #   s - key's state

  namespace upvar ::alited al al obPav obPav
  # only for unit tree and not navigation key
  if {!$al(TREE,isunits) || [alited::favor::SkipVisited] || \
  $K in {Tab Up Down Left Right Next Prior Home End Insert} || \
  [string match *Cont* $K]} {
    return
  }
  # check for current text and current unit's lines
  set wcur [CurrentWTXT]
  if {$wtxt eq {}} {
    set wtxt $wcur
  } elseif {$wtxt ne $wcur} {
    return
  }
  set wtree [$obPav Tree]
  set pos [$wtxt index insert]
  lassign [alited::tree::CurrentItemByLine $pos 1] itemID - - - name l1
  set header [alited::unit::GetHeader $wtree $itemID]
  set gokeys [list {}]
  foreach gk {F3 AltQ AltW} {
    lappend gokeys {*}[apave::getTextHotkeys $gk]
  }
  if {$K in $gokeys || ($s & 0b1000)} {
    set l1 -1 ;# to avoid a unit's name spawned in last visits at its change
  }
  alited::favor::LastVisited [$wtree item $itemID] $header $l1
  set selID [$wtree selection]
  if {[llength $selID]<2 && $selID ne $itemID} {
    $wtree selection set $itemID
    $wtree see $itemID
    alited::tree::AddTagSel $wtree $itemID
  }
  set TID [alited::bar::CurrentTabID]
  foreach it $al(_unittree,$TID) {
    set treeID [alited::tree::NewItemID [incr iit]]
    lassign $it lev leaf fl1 title l1 l2
    if {$name eq [alited::tree::UnitTitle $title $l1 $l2]} {
      set al(CPOS,$TID,$header) [::apave::p+ $pos -$l1]
      return
    }
  }
}
#_______________________

proc main::AfterUndoRedo {} {
  # Actions after undo/redo.

  HighlightLine
  after 0 {after idle {
    alited::main::SaveVisitInfo
    alited::main::UpdateUnitTree
    alited::main::FocusText}
  }
}
#_______________________

proc main::AfterCut {} {
  # Actions after cutting text: resets the unit tree's selection.

  namespace upvar ::alited al al obPav obPav
  if {$al(TREE,isunits)} {
    [$obPav Tree] selection set {}
    after idle alited::main::FocusText
  }
}

# ________________________ GUI _________________________ #

proc main::ShowHeader {{doit no}} {
  # Displays a file's name and modification flag (*) in alited's title.
  #   doit - if yes, displays unconditionally.
  # If *doit* is *no*, displays only at changing a file name or a flag.

  namespace upvar ::alited al al
  if {[alited::file::IsModified]} {set modif "*"} {set modif " "}
  set TID [alited::bar::CurrentTabID]
  if {$doit || "$modif$TID" ne [alited::bar::BAR cget -ALmodif]} {
    alited::bar::BAR configure -ALmodif "$modif$TID"
    set f [alited::bar::CurrentTab 1]
    set d [file normalize [file dirname [alited::bar::CurrentTab 2]]]
    set ttl [string map [list %f $f %d $d %p $al(prjname)] $al(TITLE)]
    wm title $al(WIN) [string trim "$modif$ttl"]
  }
}
#_______________________

proc main::CalcIndentation {{wtxt ""} {doit no}} {
  # Check for "Auto detection of indentation" and calculates it at need.
  #   wtxt - text's path
  #   doit - if yes, recalculates the indentation

  namespace upvar ::alited al al
  set res [list $al(prjindent) { }]
  if {$al(prjindentAuto)} {
    if {$wtxt eq {}} {
      if {[catch {set wtxt [CurrentWTXT]}]} {return $res}
    }
    if {!$doit && [info exists al(_INDENT_,$wtxt)]} {return $al(_INDENT_,$wtxt)}
    foreach line [split [$wtxt get 1.0 end] \n] {
      if {[set lsp [obj leadingSpaces $line]]>0} {
        # check if the indentation is homogeneous
        if {[string first [string repeat { } $lsp] $line]==0} {
          set res [list $lsp { }]
          break
        } elseif {[string first [string repeat \t $lsp] $line]==0} {
          set res [list $lsp \t]
          break
        }
      }
    }
    set al(_INDENT_,$wtxt) $res  ;# to omit the calculation next time
  }
  return $res
}
#_______________________

proc main::CalcPad {{wtxt ""}} {
  # Calculates the indenting pad for the edited text.
  #   wtxt - text's path

  lassign [CalcIndentation $wtxt] pad padchar
  return [string repeat $padchar $pad]
}
#_______________________

proc main::UpdateProjectInfo {{indent {}}} {
  # Displays a project settings in the status bar.
  #   indent - indentation calculated for a text

  namespace upvar ::alited al al obPav obPav
  if {$al(prjroot) ne {}} {set stsw normal} {set stsw disabled}
  [$obPav BtTswitch] configure -state $stsw
  if {[catch {set eol [alited::file::EOL]}] || $eol eq {}} {
    if {[set eol $al(prjEOL)] eq {}} {set eol auto}
  } else {
    lassign [split $eol] -> eol
  }
  if {$indent eq {}} {set indent [lindex [CalcIndentation] 0]}
  if {[catch {set enc [alited::file::Encoding]}] || $enc eq {}} {
    set enc utf-8
  } else {
    lassign [split $enc] -> enc
  }
  set info "$enc, eol=$eol, ind=$indent"
  if {$al(prjindentAuto)} {append info /auto}
  [$obPav Labstat4] configure -text $info
}
#_______________________

proc main::TipStatus {} {
  # Gets a tip for a status bar's short info.

  namespace upvar ::alited al al obPav obPav
  set run "$al(MC,run)"
  if {[alited::tool::ComForced]} {
    append run ": $al(comForce)\n"
  } elseif {$al(prjincons)} {
    if {$al(IsWindows)} {set term $al(EM,wt=)} {set term $al(EM,tt=)}
    append run " Tcl: $al(MC,inconsole) $term\n"
  } else {
    append run " Tcl: $al(MC,intkcon)\n"
  }
  set tip [[$obPav Labstat4] cget -text]
  set tip [string map [list \
    eol= "$al(MC,EOL:) " \
    ind= "$al(MC,indent:) " \
    {, } \n \
    ] $tip]
  return "$run\n[msgcat::mc Encoding]: $tip"
}
#_______________________

proc main::BindsForText {TID wtxt} {
  # Sets bindings for a text.
  #   TID - tab's ID
  #   wtxt - text widget's path

  namespace upvar ::alited al al obPav obPav
  if {[alited::bar::BAR isTab $TID]} {
    bind $wtxt <FocusIn> [list after 500 "::alited::main::FocusInText $TID $wtxt"]
  }
  bind $wtxt <Control-ButtonRelease-1> "::alited::find::LookDecl ; break"
  bind $wtxt <Control-Shift-ButtonRelease-1> {::alited::find::SearchWordInSession ; break}
  bind $wtxt <Control-Tab> {::alited::bar::ControlTab}
  if {$al(IsWindows)} {
    # unlike Unix, Shift+Key doesn't work in Windows
    bind $wtxt <Tab> \
      [list + if {{%K} eq {Tab} && {%s}==1} "focus [$obPav LbxInfo]; break"]
  }
  bind $wtxt <Alt-BackSpace> {::alited::unit::SwitchUnits ; break}
  ::apave::bindToEvent $wtxt <ButtonRelease-1> alited::main::SaveVisitInfo $wtxt
  ::apave::bindToEvent $wtxt <KeyRelease> alited::main::SaveVisitInfo $wtxt %K %s
  ::apave::bindToEvent $wtxt <<Undo>> alited::main::AfterUndoRedo
  ::apave::bindToEvent $wtxt <<Redo>> alited::main::AfterUndoRedo
  ::apave::bindToEvent $wtxt <<Cut>> after 50 {after 50 alited::main::AfterCut}
  alited::keys::ReservedAdd
  alited::keys::BindAllKeys $wtxt no
  alited::edit::BindPluginables $wtxt
}
#_______________________

proc main::BindsForCode {wtxt curfile} {
  # Sets bindings for a code.
  #   wtxt - text widget's path
  #   curfile - current file's name

#  if {[alited::file::IsTcl $curfile] || [alited::file::IsClang $curfile]} {
    bind $wtxt <Control-Right> "alited::edit::ControlRight $wtxt %s"
    bind $wtxt <Control-Left> "alited::edit::ControlLeft $wtxt %s"
#  }
}
#_______________________

proc main::PackTextWidgets {wtxt wsbv} {
  # Packs a text and its scrollbar.
  #   wtxt - text widget's path
  #   wsbv - scrollbar widget's path

  namespace upvar ::alited al al obPav obPav
  pack $wtxt -side left -expand 1 -fill both
  pack $wsbv -fill y -expand 1
  lassign [GutterAttrs] canvas width shift
  # widgets created outside apave require the theming:
  $obPav csSet [$obPav csCurrent] $al(WIN) -doit
  $obPav fillGutter $wtxt $canvas $width $shift
}
#_______________________

proc main::ShowOutdatedTODO {prj date todo is} {
  # Shows a balloon with outdated TODO.
  #   prj - project's name
  #   date - date of TODO
  #   todo - text of TODO
  #   is - 1 for current day TODO, 2 for "ahead" TODO

  namespace upvar ::alited al al
  set todo "\n$al(MC,prjName) $prj\n\n$al(MC,on) $date\n\n$todo\n"
  set opts {}
  if {[string first !!! $todo]>-1 || ($is==1 && $al(todoahead))} {
    set opts {-ontop 1 -eternal 1 -fg white -bg red}
  }
  ::alited::Balloon $todo yes 2500 {*}$opts
}
#_______________________

proc main::InitActions {} {
  # Initializes working with a main form of alited.

  namespace upvar ::alited al al obPav obPav
  # fill the bars waiting for full size of text widget
  alited::bar::FillBar [$obPav BtsBar]
  FillMarkBar
  # check for outdated TODOs for current project
  lassign [alited::project::IsOutdated $al(prjname) yes] is date todo
  if {$is} {
    ShowOutdatedTODO $al(prjname) $date $todo $is
  } else {
    # check other projects
    alited::project::SaveSettings
    alited::project::GetProjects
    set prjname [alited::project::CheckOutdated]
    if {$prjname ne {}} {
      lassign [alited::project::IsOutdated $prjname yes] is date todo
      ShowOutdatedTODO $prjname $date $todo $is
    }
  }
  after idle {alited::main::UpdateGutter; alited::main::FocusText}  ;# get it for sure
  if {$al(INI,isfindrepl)} {
    after idle {after 100 {  ;# for getting a current word to find
      alited::find::_run
      focus $::alited::al(WIN); alited::main::FocusText
      after idle {after 100 {after idle {after 100 alited::main::FocusText}}}
    }}
  }
  # Ctrl-click for Run, e_menu, Tkcon buttons
  foreach ico {run e_menu other} {
    set but [alited::tool::ToolButName $ico]
    bind $but <Control-Button-1> $al(runAsIs)
    set tip [::baltip::cget $but -text][alited::tool::AddTooltipRun]
    after idle [list ::baltip::tip $but $tip]
  }
  foreach ico {undo redo} {
    set but [alited::tool::ToolButName $ico]
    bind $but <Control-Button-1> alited::tool::${ico}All
    set tip [::baltip::cget $but -text]
    append tip "\n\nCtrl+click = [msgcat::mc {All in text}]"
    after idle [list ::baltip::tip $but $tip]
  }
}

# ________________________ Main _create _________________________ #

proc main::_create {} {
  # Creates a main form of the alited.

  namespace upvar ::alited al al obPav obPav
  set al(AU!) 0
  $obPav untouchWidgets *.frAText *.lbxInfo *.lbxFlist *.too*
  # make the main apave object and populate it
  $obPav makeWindow $al(WIN).fra alited

  # alited_checked

## ________________________ Main window _________________________ ##

  $obPav paveWindow $al(WIN).fra {
    {Menu - - - - - {-array {
      file File
      edit Edit
      search Search
      tool Tools
      setup Setup
      help Help
    }} alited::menu::FillMenu}
{#
### ________________________ Main pan _________________________ ###
}
    {frat - - - - {pack -fill both}}
    {frat.ToolTop - - - - {pack -side top} \
      {-relief flat -borderwidth 0 -array {$::alited::al(atools)}}}
    {fra - - - - {pack -side top -fill both -expand 1 -pady 0}}
    {fra.Pan - - - - {pack -side top -fill both -expand 1} {-orient horizontal $::alited::Pan_wh}}
    {fra.pan.PanL - - - - {add} {-orient vertical $::alited::PanL_wh}}
    {.fraBot - - - - {add}}
{#
### ________________________ Tree pan _________________________ ###
}
    {.fraBot.PanBM - - - - {pack -fill both -expand 1} {$::alited::PanBM_wh}}
    {.fraBot.panBM.FraTree - - - - {pack -side top -fill both -expand 1}}
    {.fraBot.panBM.fraTree.fra1 - - - - {pack -side top -fill x}}
{#
#### ________________________ Tree's toolbar _________________________ ####
}
    {.fraBot.panBM.fraTree.fra1.BtTswitch - - - - {pack -side left -fill x} \
      {-image alimg_gulls -com alited::tree::SwitchTree}}
    {.fraBot.panBM.fraTree.fra1.BtTUpdT - - - - {pack -side left -fill x} \
      {-image alimg_retry -tip {$al(MC,updtree)}
    -command alited::main::UpdateAll}}
    {.fraBot.panBM.fraTree.fra1.sev1 - - - - {pack -side left -fill y -padx 5}}
    {.fraBot.panBM.fraTree.fra1.BtTUp - - - - {pack -side left -fill x} \
      {-image alimg_up -com {alited::tree::MoveItem up}}}
    {.fraBot.panBM.fraTree.fra1.BtTDown - - - - {pack -side left -fill x} \
      {-image alimg_down -com {alited::tree::MoveItem down}}}
    {.fraBot.panBM.fraTree.fra1.sev2 - - - - {pack -side left -fill y -padx 5}}
    {.fraBot.panBM.fraTree.fra1.BtTAddT - - - - {pack -side left -fill x} \
      {-image alimg_add -com alited::tree::AddItem}}
    {.fraBot.panBM.fraTree.fra1.BtTRenT - - - - {pack forget -side left -fill x} \
      {-image alimg_change -tip "$al(MC,renamefile)\nF2" \
      -com {::alited::file::RenameFileInTree 0 -geometry pointer+10+10}}}
    {.fraBot.panBM.fraTree.fra1.BtTDelT - - - - {pack -side left -fill x} \
      {-image alimg_delete -com alited::tree::DelItem}}
    {.fraBot.panBM.fraTree.fra1.BtTCloT - - - - {pack forget -side left -fill x} \
      {-image alimg_copy -com alited::file::CloneFile -tip "$al(MC,clonefile)"}}
    {.fraBot.panBM.fraTree.fra1.h_ - - - - {pack -anchor center -side left -fill both -expand 1}}
    {.fraBot.panBM.fraTree.fra1.btTCtr - - - - {pack -side left -fill x} \
      {-image alimg_minus -com {alited::tree::ExpandContractTree Tree no} -tip "Contract All"}}
    {.fraBot.panBM.fraTree.fra1.btTExp - - - - {pack -side left -fill x} \
      {-image alimg_plus -com {alited::tree::ExpandContractTree Tree} -tip "Expand All"}}
{#
#### ________________________ Tree _________________________ ####
}
    {.fraBot.panBM.fraTree.fra1.sev3 - - - - {pack -side right -fill y -padx 0}}
    {.fraBot.panBM.fraTree.fra - - - - {pack -side bottom -fill both -expand 1} {}}
    {.fraBot.panBM.fraTree.fra.Tree - - - - {pack -side left -fill both -expand 1}
      {-columns {L1 L2 PRL ID LEV LEAF FL1} -displaycolumns {L1} -columnoptions "#0 \
      {-width $al(TREE,cw0)} L1 {-width $al(TREE,cw1) -anchor e}" -style TreeNoHL \
      -takefocus 0 -selectmode extended -tip {-BALTIP {alited::tree::GetTooltip %i %c} \
      -SHIFTX 10}}}
{#
### ________________________ Favorites _________________________ ###
}
    {.fraBot.panBM.fraTree.fra.SbvTree .fraBot.panBM.fraTree.fra.Tree L - - \
      {pack -side right -fill both}}
    {.FraFV - - - - {add}}
    {.fraFV.v_ - - - - {pack -side top -fill x} {-h 5}}
    {.fraFV.fra1 - - - - {pack -side top -fill x}}
    {.fraFV.fra1.seh - - - - {pack -side top -fill x -expand 1 -pady 0}}
{#
#### ________________________ Favorites' toolbar _________________________ ####
}
    {.fraFV.fra1.BtTVisitF - - - - {pack -side left -fill x} \
      {-image alimg_misc -tip {$al(MC,lastvisit)} -com alited::favor::SwitchFavVisit}}
    {.fraFV.fra1.sev0 - - - - {pack -side left -fill y -padx 5}}
    {.fraFV.fra1.BtTListF - - - - {pack -side left -fill x} \
      {-image alimg_SaveFile -tip {$al(MC,FavLists)} -com alited::favor::Lists}}
    {.fraFV.fra1.SevF - - - - {pack -side left -fill y -padx 5}}
    {.fraFV.fra1.BtTAddF - - - - {pack -side left -fill x} \
      {-image alimg_add -tip {$al(MC,favoradd)} -com alited::favor::Add}}
    {.fraFV.fra1.BtTRenF - - - - {pack -side left -fill x} \
      {-image alimg_change -tip {$al(MC,favorren)} -command ::alited::favor::Rename}}
    {.fraFV.fra1.btTDelF - - - - {pack -side left -fill x} \
      {-image alimg_delete -tip {$al(MC,favordel)} -com alited::favor::Delete}}
    {.fraFV.fra1.btTDelAllF - - - - {pack -side left -fill x} \
      {-image alimg_trash -tip {$al(MC,favordelall)} -com alited::favor::DeleteAll}}
    {.fraFV.fra1.h_2 - - - - {pack -anchor center -side left -fill both -expand 1}}
    {.fraFV.fra1.sev2 - - - - {pack -side right -fill y -padx 0}}
    {.fraFV.fra - - - - {pack -fill both -expand 1} {}}
{#
#### ________________________ Favorites' list _________________________ ####
}
    {.fraFV.fra.TreeFavor - - - - {pack -side left -fill both -expand 1} \
      {-h 5 -style TreeNoHL -columns {C1 C2 C3 C4} -displaycolumns C1 \
      -show headings -takefocus 0 -tip {-BALTIP {alited::favor::GetTooltip %i} -SHIFTX 10}}}
    {.fraFV.fra.SbvFavor .fraFV.fra.TreeFavor L - - {pack -side left -fill both}}
    {fra.pan.PanR - - - - {add} {-orient vertical $::alited::PanR_wh}}
{#
### ________________________ Tab bar & Text _________________________ ###
}
    {.fraTop - - - - {add}}
    {.fraTop.PanTop - - - - {pack -fill both -expand 1} {$::alited::PanTop_wh}}
    {.fraTop.panTop.BtsBar  - - - - {pack -side top -fill x -pady 3}}
    {.fraTop.panTop.canmark - - - - {pack -side left -expand 0 -fill both \
      -padx 0 -pady 0 -ipadx 0 -ipady 0} {-w $al(markwidth) \
      -afteridle {alited::main::FillMarkBar %w}}}
    {.fraTop.panTop.GutText - - - - {pack -side left -expand 0 -fill both}}
    {.fraTop.panTop.FrAText - - - - {pack -side left -expand 1 -fill both \
      -padx 0 -pady 0 -ipadx 0 -ipady 0} {-background $::apave::BGMAIN2}}
    {.fraTop.panTop.frAText.Text - - - - {pack -expand 1 -fill both} \
      {-w 80 -h 30 -gutter GutText -gutterwidth $al(ED,gutterwidth) \
      -guttershift $al(ED,guttershift)}}
    {.fraTop.panTop.fraSbv - - - - {pack -side right -fill y}}
{#
### ________________________ Find units _________________________ ###
}
    {.fraTop.panTop.fraSbv.SbvText .fraTop.panTop.frAText.text L - - {pack -fill y}}
    {.fraTop.FraSbh  - - - - {pack forget -fill x}}
    {.fraTop.fraSbh.SbhText .fraTop.panTop.frAText.text T - - {pack -fill x}}
    {.fraTop.FraHead  - - - - {pack forget -side bottom -fill x} \
      {-padding {4 4 4 4} -relief groove}}
    {.fraTop.fraHead.labFind - - - - {pack -side left} {-t {    Unit: }}}
    {.fraTop.fraHead.CbxFindSTD - - - - {pack -side left} \
      {-tvar ::alited::al(findunit) -values {$al(findunitvals)} -w 30 -tip {$al(MC,findunit)}}}
    {.fraTop.fraHead.btT - - - - {pack -side left -padx 4} \
      {-t {Find: } -com alited::find::DoFindUnit -w 8 -anchor e -tip {Find Unit}}}
    {.fraTop.fraHead.rad1 - - - - {pack -side left -padx 4} \
      {-takefocus 0 -var ::alited::main::findunits -t {in all} -value 1}}
    {.fraTop.fraHead.rad2 - - - - {pack -side left -padx 4} \
      {-takefocus 0 -var ::alited::main::findunits -t {in current} -value 2}}
    {.fraTop.fraHead.h_ - - - - {pack -side left -fill x -expand 1}}
    {.fraTop.fraHead.btTno - - - - {pack -side left} {-command {alited::find::HideFindUnit}}}
{#
### ________________________ Info & status bar _________________________ ###
}
    {.fraBot - - - - {add}}
    {.fraBot.fra - - - - {pack -fill both -expand 1}}
    {.fraBot.fra.LbxInfo - - - - {pack -side left -fill both -expand 1} \
      {-h 1 -w 40 -lvar ::alited::info::list -font $al(FONT,defsmall) -highlightthickness 0}}
    {.fraBot.fra.sbv .fraBot.fra.LbxInfo L - - pack}
    {.fraBot.fra.SbhInfo .fraBot.fra.LbxInfo T - - {pack -side bottom -before %w}}
    {.fraBot.stat - - - - {pack -side bottom} {-array {
      {{$al(MC,Row:)}} 12
      {{$al(MC,Col:)}} 4
      {{} -anchor w -expand 1} 51
      {{} -anchor e} 25
    }}}
  }
  UpdateProjectInfo
  # a pause (and cycles) must be enough for FillBar to have proper -wbar option
  after idle after 50 after idle after 50 after idle after 50 after idle after 50 \
    alited::main::InitActions
  bind [$obPav Pan] <ButtonRelease> ::alited::tree::AdjustWidth
  set sbhi [$obPav SbhInfo]
  set lbxi [$obPav LbxInfo]
  pack forget $sbhi
  bind $lbxi <FocusIn> "alited::info::FocusIn $sbhi $lbxi"
  bind $lbxi <FocusOut> "alited::info::FocusOut $sbhi"
  bind $lbxi <<ListboxSelect>> {alited::info::ListboxSelect %W}
  bind $lbxi <ButtonPress-3> {alited::info::PopupMenu %X %Y}
  bind [$obPav ToolTop] <ButtonPress-3> {::alited::tool::PopupBar %X %Y}
  ::baltip tip [$obPav Labstat4] = -command ::alited::main::TipStatus -per10 0
}
# ________________________ Main _run _________________________ #

proc main::_run {} {
  # Runs the alited, displaying its main form with attributes
  # 'modal', 'not closed by Esc', 'decorated with Contract/Expand buttons',
  # 'minimal sizes' and 'saved geometry'.
  # After closing the alited, saves its settings (geometry etc.).
  # See also: menu::TearoffCascadeMenu

  namespace upvar ::alited al al obPav obPav
  ::apave::setAppIcon $al(WIN) $::alited::img::_AL_IMG(ale)
  after idle after 8 after idle after 8 after idle after 8 {incr ::alited::al(AU!)}
  after 3000 {incr ::alited::al(AU!)} ;# control shot
  after 2000 [list wm iconphoto $al(WIN) -default [::apave::getAppIcon]]
  after 1000 {alited::ini::CheckUpdates no}
  set ans [$obPav showModal $al(WIN) -decor 1 -minsize {500 500} -escape no \
    -onclose alited::Exit {*}$al(GEOM) -resizable 1 -waitme ::alited::al(AU!) \
    -ontop 0]
  # ans==2 means 'no saves of settings' (imaginary mode)
  if {$ans ne {2}} {alited::ini::SaveIni}
  destroy $al(WIN)
  $obPav destroy
  return $ans
}
# _________________________________ EOF _________________________________ #
