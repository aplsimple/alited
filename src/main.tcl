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

  namespace upvar ::alited al al obPav obPav
  set curfile [alited::bar::FileName $TID]
  # initial text and its scrollbar:
  set wtxt [$obPav Text]
  set wsbv [$obPav SbvText]
  # get data of the current tab
  lassign [alited::bar::GetBarState] TIDold fileold wold1 wold2
  lassign [alited::bar::GetTabState $TID --pos] pos
  set doreload no  ;# obsolete
  set doinit yes
  if {$TIDold eq "-1"} {
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
    set texopts [lindex [$obPav defaultAttrs tex] 1]
    lassign [::apave::extractOptions texopts -selborderwidth 1] selbw
    text $wtxt {*}$texopts {*}$al(TEXT,opts)
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
    alited::bar::SetTabState $TIDold --pos [$wold1 index insert]
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
    alited::file::DisplayFile $TID $curfile $wtxt $doreload
    if {$doshow} {
      HighlightText $TID $curfile $wtxt
    } else {
      alited::file::MakeThemHighlighted $TID  ;# postpone the highlighting till a show
    }
  } elseif {$dohighlight && [alited::file::ToBeHighlighted $wtxt]} {
    HighlightText $TID $curfile $wtxt
    if {$al(TREE,isunits)} alited::tree::RecreateTree
  }
  return [list $curfile $wtxt $wsbv $pos $doinit $dopack]
}
#_______________________

proc main::ShowText {} {
  # Displays a current text.

  namespace upvar ::alited al al obPav obPav
  set TID [alited::bar::CurrentTabID]
  lassign [GetText $TID yes] curfile wtxt wsbv pos doinit dopack
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
    [$obPav Tree] see $itemID
  }
  focus $wtxt
  # update "File" menu and app's header
  alited::menu::CheckMenuItems
  ShowHeader
}

# ________________________ Updating gutter & text _________________________ #

proc main::UpdateGutter {} {
  # Redraws the gutter.

  namespace upvar ::alited obPav obPav
  set wtxt [CurrentWTXT]
  after idle "$obPav fillGutter $wtxt"
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
  if {$alited::al(TREE,isunits) && [alited::file::IsUnitFile $fname]} {
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
  set alited::tree::doFocus no
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
    ::alited::main::CursorPos $wtxt
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
  if {![info exists al(HL,$wtxt)] || $al(HL,$wtxt) ne $ext} {
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
      ::hl_c::hl_init $wtxt -dark [$obPav csDark] \
        -multiline 1 -keywords $al(ED,CKeyWords) \
        -cmd "::alited::edit::Modified $TID" \
        -cmdpos ::alited::main::CursorPos \
        -font $al(FONT,txt) -colors $Ccolors \
        -insertwidth $al(CURSORWIDTH)
    } else {
      ::hl_tcl::hl_init $wtxt -dark [$obPav csDark] \
        -multiline $al(prjmultiline) -keywords $al(ED,TclKeyWords) \
        -cmd "::alited::edit::Modified $TID" \
        -cmdpos ::alited::main::CursorPos \
        -plaintext [expr {![alited::file::IsTcl $curfile]}] \
        -font $al(FONT,txt) -colors $colors \
        -insertwidth $al(CURSORWIDTH)
    }
    UpdateText $wtxt $curfile
  }
  set al(HL,$wtxt) $ext
}
#_______________________

proc main::HighlightLine {} {
  # Highlights a current line of a current text.

  set wtxt [alited::main::CurrentWTXT]
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
  if {$args eq {}} {set args [$wtxt index {end -1 char}]}
  lassign [split [$wtxt index insert] .] r c
  [$obPav Labstat1] configure -text "$r / [expr {int([lindex $args 0])}]"
  [$obPav Labstat2] configure -text [incr c]
  alited::tree::SaveCursorPos
}
#_______________________

proc main::InsertLine {} {
  # Puts a new line into a text, attentive to a previous line's indentation.

  set wtxt [CurrentWTXT]
  set ln [expr {int([$wtxt index insert])}]
  if {$ln==1} {
    $wtxt insert $ln.0 \n
    set pos 1.0
  } else {
    set ln0 [expr {$ln-1}]
    set line [$wtxt get $ln0.0 $ln0.end]
    set leadsp [::apave::obj leadingSpaces $line]
    $wtxt insert $ln.0 "[string repeat { } $leadsp]\n"
    set pos $ln.$leadsp
  }
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
        alited::main::FocusText [alited::bar::CurrentTabID] $pos1
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
  lassign [$obDl2 input {} $head [list \
    spx "{$prompt1} {} {-w 6 -justify center -from 1 -to $lmax -selected yes}" "{$ln}" \
    cbx "{$prompt2} {} {-tvar ::alited::main::gotoline1 -state readonly -h 16 -w 20}" "{$::alited::main::gotoline1} $::alited::main::gotoline2" \
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
    after idle " \
      alited::main::FocusText $TID $ln.0 ; \
      alited::tree::NewSelection {} $ln.0 yes"
  }
}

# ________________________ Event handlers _________________________ #

proc main::SaveVisitInfo {{wtxt ""} {K ""} {s 0}} {
  # Remembers data about current unit.
  #   wtxt - text's path
  #   K - key pressed (to check keypressings)
  #   s - key's state

  namespace upvar ::alited al al obPav obPav
  # only for unit tree and not navigation key and not Alt/Ctrl pressed
  if {!$al(TREE,isunits) || ($s!=0 && $s!=1 && $s!=8) || \
  ($K in {Up Down Left Right Next Prior Home End} && $s!=8)} {
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
  if {$K in $gokeys || $s==8} {
    set l1 -1 ;# to avoid a unit's name spawned in last visits at its change
  }
  alited::favor::LastVisited [$wtree item $itemID] $header $l1
  set selID [$wtree selection]
  if {[llength $selID]<2 && $selID ne $itemID} {
    $wtree selection set $itemID
    $wtree see $itemID
    $wtree tag add tagSel $itemID
  }
  set TID [alited::bar::CurrentTabID]
  foreach it $al(_unittree,$TID) {
    set treeID [alited::tree::NewItemID [incr iit]]
    lassign $it lev leaf fl1 title l1 l2
    if {$name eq [alited::tree::UnitTitle $title $l1 $l2]} {
      set al(CPOS,$TID,$header) [alited::p+ $pos -$l1]
      break
    }
  }
}
#_______________________

proc main::AfterUndoRedo {} {
  # Actions after undo/redo.

  HighlightLine
  after idle {alited::main::SaveVisitInfo ; alited::main::UpdateUnitTree}
}
#_______________________

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

proc main::CalcIndentation {} {
  # Check for "Auto detection of indentation" and calculates it at need.

  namespace upvar ::alited al al
  set res [list $al(prjindent) { }]
  if {$al(prjindentAuto)} {
    catch {
      set wtxt [CurrentWTXT]
      foreach line [split [$wtxt get 1.0 end] \n] {
        if {[set lsp [::apave::obj leadingSpaces $line]]>0} {
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
    }
  }
  return $res
}

proc main::UpdateProjectInfo {{indent {}}} {
  # Displays a project settings in the status bar.
  #   indent - indentation calculated for a text

  namespace upvar ::alited al al obPav obPav
  if {$al(prjroot) ne {}} {set stsw normal} {set stsw disabled}
  [$obPav BuTswitch] configure -state $stsw
  if {[set eol $al(prjEOL)] eq {}} {set eol auto}
  if {$indent eq {}} {set indent [lindex [CalcIndentation] 0]}
  set info "eol=$eol, [msgcat::mc ind]=$indent"
  if {$al(prjindentAuto)} {append info /auto}
  [$obPav Labstat4] configure -text $info
}
#_______________________

proc main::BindsForText {TID wtxt} {
  # Sets bindings for a text.
  #   TID - tab's ID
  #   wtxt - text widget's path

  if {[alited::bar::BAR isTab $TID]} {
    bind $wtxt <FocusIn> [list after 500 "::alited::main::FocusInText $TID $wtxt"]
  }
  bind $wtxt <Control-ButtonRelease-1> "::alited::find::SearchUnit ; break"
  bind $wtxt <Control-Shift-ButtonRelease-1> {::alited::find::SearchWordInSession ; break}
  bind $wtxt <Control-Tab> {::alited::bar::ControlTab}
  bind $wtxt <Alt-BackSpace> {::alited::unit::SwitchUnits ; break}
  ::apave::bindToEvent $wtxt <ButtonRelease-1> alited::main::SaveVisitInfo $wtxt
  ::apave::bindToEvent $wtxt <KeyRelease> alited::main::SaveVisitInfo $wtxt %K %s
  ::apave::bindToEvent $wtxt <<Undo>> alited::main::AfterUndoRedo
  ::apave::bindToEvent $wtxt <<Redo>> alited::main::AfterUndoRedo
  alited::keys::ReservedAdd $wtxt
  alited::keys::BindKeys $wtxt action
  alited::keys::BindKeys $wtxt template
  alited::keys::BindKeys $wtxt preference
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

proc main::InitActions {} {
  # Initializes working with a main form of alited.

  namespace upvar ::alited al al obPav obPav
  alited::bar::FillBar [$obPav BtsBar]
  # check for reminders of the past
  set rems [alited::project::ReadRems $al(prjname)]
  lassign [alited::project::SortRems $rems] dmin
  if {$dmin && $dmin<[clock seconds]} {
    alited::project::_run
  }
}

# ________________________ Main _________________________ #

proc main::_create {} {
  # Creates a main form of the alited.

  namespace upvar ::alited al al obPav obPav
  lassign [$obPav csGet] - - ::alited::FRABG - - - - - bclr
  ttk::style configure TreeNoHL {*}[ttk::style configure Treeview] -borderwidth 0
  ttk::style map TreeNoHL {*}[ttk::style map Treeview] \
    -bordercolor [list focus $bclr active $bclr] \
    -lightcolor [list focus $::alited::FRABG active $::alited::FRABG] \
    -darkcolor [list focus $::alited::FRABG active $::alited::FRABG]
  ttk::style layout TreeNoHL [ttk::style layout Treeview]
  $obPav untouchWidgets *.frAText *.lbxInfo
  # make the main apave object and populate it
  $obPav makeWindow $al(WIN).fra alited
  $obPav paveWindow $al(WIN).fra {
    {Menu - - - - - {-array {
      file File
      edit Edit
      search Search
      tool Tools
      setup Setup
      help Help
    }} alited::menu::FillMenu}
    {frat - - - - {pack -fill both}}
    {frat.ToolTop - - - - {pack -side top} {-relief flat -borderwidth 0 -array {$alited::al(atools)}}}
    {fra - - - - {pack -side top -fill both -expand 1 -pady 0}}
    {fra.Pan - - - - {pack -side top -fill both -expand 1} {-orient horizontal $alited::Pan_wh}}
    {fra.pan.PanL - - - - {add} {-orient vertical $alited::PanL_wh}}
    {.fraBot - - - - {add}}
    {.fraBot.PanBM - - - - {pack -fill both -expand 1} {$alited::PanBM_wh}}
    {.fraBot.panBM.FraTree - - - - {pack -side top -fill both -expand 1}}
    {.fraBot.panBM.fraTree.fra1 - - - - {pack -side top -fill x}}
    {.fraBot.panBM.fraTree.fra1.BuTswitch - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_gulls -command alited::tree::SwitchTree}}
    {.fraBot.panBM.fraTree.fra1.BuTUpdT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_retry -tip {$alited::al(MC,updtree)}
    -command alited::main::UpdateAll}}
    {.fraBot.panBM.fraTree.fra1.sev1 - - - - {pack -side left -fill y -padx 5}}
    {.fraBot.panBM.fraTree.fra1.BuTUp - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_up -command {alited::tree::MoveItem up}}}
    {.fraBot.panBM.fraTree.fra1.BuTDown - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_down -command {alited::tree::MoveItem down}}}
    {.fraBot.panBM.fraTree.fra1.sev2 - - - - {pack -side left -fill y -padx 5}}
    {.fraBot.panBM.fraTree.fra1.BuTAddT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_add -command alited::tree::AddItem}}
    {.fraBot.panBM.fraTree.fra1.BuTRenT - - - - {pack forget -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_change -command {::alited::file::RenameFileInTree {-geometry pointer+-100+10}}}}
    {.fraBot.panBM.fraTree.fra1.BuTDelT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_delete -command alited::tree::DelItem}}
    {.fraBot.panBM.fraTree.fra1.h_ - - - - {pack -anchor center -side left -fill both -expand 1}}
    {.fraBot.panBM.fraTree.fra1.buTCtr - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_minus -command {alited::tree::ExpandContractTree Tree no} -tip "Contract All"}}
    {.fraBot.panBM.fraTree.fra1.buTExp - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_plus -command {alited::tree::ExpandContractTree Tree} -tip "Expand All"}}
    {.fraBot.panBM.fraTree.fra1.sev3 - - - - {pack -side right -fill y -padx 0}}
    {.fraBot.panBM.fraTree.fra - - - - {pack -side bottom -fill both -expand 1} {}}
    {.fraBot.panBM.fraTree.fra.Tree - - - - {pack -side left -fill both -expand 1} 
      {-columns {L1 L2 PRL ID LEV LEAF FL1} -displaycolumns {L1} -columnoptions "#0 {-width $::alited::al(TREE,cw0)} L1 {-width $::alited::al(TREE,cw1) -anchor e}" -style TreeNoHL -takefocus 0 -selectmode extended -tip {alited::tree::GetTooltip %i %c}}}
    {.fraBot.panBM.fraTree.fra.SbvTree .fraBot.panBM.fraTree.fra.Tree L - - {pack -side right -fill both}}
    {.FraFV - - - - {add}}
    {.fraFV.v_ - - - - {pack -side top -fill x} {-h 5}}
    {.fraFV.fra1 - - - - {pack -side top -fill x}}
    {.fraFV.fra1.seh - - - - {pack -side top -fill x -expand 1 -pady 0}}
    {.fraFV.fra1.BuTVisitF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_misc -tip {$alited::al(MC,lastvisit)} -com alited::favor::SwitchFavVisit}}
    {.fraFV.fra1.sev0 - - - - {pack -side left -fill y -padx 5}}
    {.fraFV.fra1.BuTListF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_heart -tip {$alited::al(MC,FavLists)} -com alited::favor::Lists}}
    {.fraFV.fra1.sev1 - - - - {pack -side left -fill y -padx 5}}
    {.fraFV.fra1.BuTAddF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_add -tip {$alited::al(MC,favoradd)} -com alited::favor::Add}}
    {.fraFV.fra1.BuTDelF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_delete -tip {$alited::al(MC,favordel)} -com alited::favor::Delete}}
    {.fraFV.fra1.BuTDelAllF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_trash -tip {$alited::al(MC,favordelall)} -com alited::favor::DeleteAll}}
    {.fraFV.fra1.h_2 - - - - {pack -anchor center -side left -fill both -expand 1}}
    {.fraFV.fra1.sev2 - - - - {pack -side right -fill y -padx 0}}
    {.fraFV.fra - - - - {pack -fill both -expand 1} {}}
    {.fraFV.fra.TreeFavor - - - - {pack -side left -fill both -expand 1} {-h 5 -style TreeNoHL -columns {C1 C2 C3 C4} -displaycolumns C1 -show headings -takefocus 0 -tip {alited::favor::GetTooltip %i}}}
    {.fraFV.fra.SbvFavor .fraFV.fra.TreeFavor L - - {pack -side left}}
    {fra.pan.PanR - - - - {add} {-orient vertical $alited::PanR_wh}}
    {.fraTop - - - - {add}}
    {.fraTop.PanTop - - - - {pack -fill both -expand 1} {$alited::PanTop_wh}}
    {.fraTop.panTop.BtsBar  - - - - {pack -side top -fill x -pady 3}}
    {.fraTop.panTop.GutText - - - - {pack -side left -expand 0 -fill both}}
    {.fraTop.panTop.FrAText - - - - {pack -side left -expand 1 -fill both} {-background $::alited::FRABG}}
    {.fraTop.panTop.frAText.Text - - - - {pack -expand 1 -fill both} {-borderwidth 1 -w 2 -h 20 -gutter GutText -gutterwidth $::alited::al(ED,gutterwidth) -guttershift $::alited::al(ED,guttershift) $alited::al(TEXT,opts)}}
    {.fraTop.panTop.fraSbv - - - - {pack -side right -fill y}}
    {.fraTop.panTop.fraSbv.SbvText .fraTop.panTop.frAText.text L - - {pack -fill y}}
    {.fraTop.FraSbh  - - - - {pack forget -fill x}}
    {.fraTop.fraSbh.SbhText .fraTop.panTop.frAText.text T - - {pack -fill x}}
    {.fraTop.FraHead  - - - - {pack forget -side bottom -fill x} {-padding {4 4 4 4} -relief groove}}
    {.fraTop.fraHead.labFind - - - - {pack -side left} {-t "    Unit: "}}
    {.fraTop.fraHead.CbxFindSTD - - - - {pack -side left} {-tvar alited::al(findunit) -values {$alited::al(findunitvals)} -w 30 -tip {$al(MC,findunit)}}}
    {.fraTop.fraHead.buT - - - - {pack -side left -padx 4} {-t "Find: " -relief flat -com alited::find::DoFindUnit -takefocus 0 -bd 0 -highlightthickness 0 -w 8 -anchor e -tip {Find Unit}}}
    {.fraTop.fraHead.rad1 - - - - {pack -side left -padx 4} {-takefocus 0 -var alited::main::findunits -t {in all} -value 1}}
    {.fraTop.fraHead.rad2 - - - - {pack -side left -padx 4} {-takefocus 0 -var alited::main::findunits -t {in current} -value 2}}
    {.fraTop.fraHead.h_ - - - - {pack -side left -fill x -expand 1}}
    {.fraTop.fraHead.buTno - - - - {pack -side left} {-relief flat -highlightthickness 0 -takefocus 0 -command {alited::find::HideFindUnit}}}
    {.fraBot - - - - {add}}
    {.fraBot.fra - - - - {pack -fill both -expand 1}}
    {.fraBot.fra.LbxInfo - - - - {pack -side left -fill both -expand 1} {-h 1 -w 40 -lvar ::alited::info::list -font $alited::al(FONT,defsmall) -highlightthickness 0}}
    {.fraBot.fra.sbv .fraBot.fra.LbxInfo L - - {pack}}
    {.fraBot.fra.SbhInfo .fraBot.fra.LbxInfo T - - {pack -side bottom -before %w}}
    {.fraBot.stat - - - - {pack -side bottom} {-array {
      {{$alited::al(MC,Row:)}} 13
      {{$alited::al(MC,Col:)}} 4
      {{} -anchor w -expand 1} 50
      {{} -anchor e} 21
    }}}
  }
  UpdateProjectInfo
  # there should be a pause enough for FillBar got -wbar option normally sized
  after 500 {after idle alited::main::InitActions}
  bind [$obPav Pan] <ButtonRelease> ::alited::tree::AdjustWidth
  set sbhi [$obPav SbhInfo]
  set lbxi [$obPav LbxInfo]
  pack forget $sbhi
  bind $lbxi <FocusIn> "alited::info::FocusIn $sbhi $lbxi"
  bind $lbxi <FocusOut> "alited::info::FocusOut $sbhi"
  bind $lbxi <<ListboxSelect>> {alited::info::ListboxSelect %W}
  bind $lbxi <ButtonPress-3> {alited::info::PopupMenu %X %Y}
  bind [$obPav ToolTop] <ButtonPress-3> {::alited::tool::PopupBar %X %Y}
}
#_______________________

proc main::_run {} {
  # Runs the alited, displaying its main form with attributes
  # 'modal', 'not closed by Esc', 'decorated with Contract/Expand buttons',
  # 'minimal sizes' and 'saved geometry'.
  #
  # After closing the alited, saves its settings (geometry etc.).

  namespace upvar ::alited al al obPav obPav
  ::apave::setAppIcon $al(WIN) $::alited::img::_AL_IMG(ale)
  ::apave::setProperty DirFilGeoVars [list ::alited::DirGeometry ::alited::FilGeometry]
  set ans [$obPav showModal $al(WIN) -decor 1 -minsize {500 500} -escape no \
    -onclose alited::Exit {*}$al(GEOM)]
  # ans==2 means 'no saves of settings' (imaginary mode)
  if {$ans ne {2}} {alited::ini::SaveIni}
  destroy $al(WIN)
  $obPav destroy
  return $ans
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
