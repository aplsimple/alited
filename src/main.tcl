#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The main form of alited.
# _______________________________________________________________________ #

namespace eval main {
  variable findunits 1
}

proc main::GetText {TID {doshow no}} {
  namespace upvar ::alited al al obPav obPav
  set curfile [alited::bar::BAR $TID cget -tip]
  set wtxt [$obPav Text]
  set wsbv [$obPav SbvText]
  set doinit yes
  lassign [alited::bar::GetBarState] TIDold fileold wold1 wold2
  lassign [alited::bar::GetTabState $TID --pos] pos
  if {$TIDold eq "-1"} {
    ;# first text to edit in original Text widget: create its scrollbar
    BindsForText $TID $wtxt
  } elseif {[GetWTXT $TID] ne {}} {
    # edited text: get its widgets' data
    lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
    set doinit [expr {[alited::bar::BAR $TID cget --reload] ne ""}]
    if {$doinit} {
      set al(HL,$wtxt) "" ;# to highlight the loaded text
    }
    alited::bar::BAR $TID configure --reload ""
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
    if {[trace info execution $wtxt] eq ""} {
      trace add execution $wtxt leave $bind
    }
    ttk::scrollbar $wsbv -orient vertical -takefocus 0
    $wtxt configure -yscrollcommand "$wsbv set"
    $wsbv configure -command "$wtxt yview"
    BindsForText $TID $wtxt
  }
  # show the selected text
  if {$doshow} {
    alited::bar::SetBarState [alited::bar::CurrentTabID] $curfile $wtxt $wsbv
  }
  if {$doinit} {
    alited::file::DisplayFile $TID $curfile $wtxt
    HighlightText $TID $curfile $wtxt
  }
  if {[winfo exists $wold1]} {
    alited::bar::SetTabState $TIDold --pos [$wold1 index insert]
    if {$dopack && $doshow} {
      pack forget $wold1  ;# a text
      pack forget $wold2  ;# a scrollbar
    }
  }
  return [list $curfile $wtxt $wsbv $pos $doinit $dopack]
}

proc main::ShowText {} {

  namespace upvar ::alited al al obPav obPav
  set TID [alited::bar::CurrentTabID]
  lassign [GetText $TID yes] curfile wtxt wsbv pos doinit dopack
  if {$dopack} {
    PackTextWidgets $wtxt $wsbv
  }
  if {$doinit || $dopack} {
    set al(TREE,units) no
    alited::tree::Create
  }
  FocusText $TID $pos
  if {[set itemID [alited::tree::NewSelection]] ne ""} {
    [$obPav Tree] see $itemID
  }
  alited::menu::CheckMenuItems
  focus $wtxt
  ShowHeader
}

proc main::UpdateGutter {args} {
  namespace upvar ::alited obPav obPav
  set wtxt [CurrentWTXT]
  after idle "$obPav fillGutter $wtxt"
}

proc main::UpdateText {{wtxt {}} {curfile {}}} {
  namespace upvar ::alited obPav obPav
  if {$wtxt eq {}} {set wtxt [CurrentWTXT]}
  if {$curfile eq {}} {set curfile [alited::bar::FileName]}
  if {[alited::file::IsClang $curfile]} {
    ::hl_c::hl_text $wtxt
  } else {
    ::hl_tcl::hl_text $wtxt
  }
}

proc main::UpdateTextAndGutter {} {
  UpdateGutter
  UpdateText
}

proc main::FocusText {args} {

  namespace upvar ::alited al al obPav obPav
  lassign $args TID pos
  set wtxt [CurrentWTXT]
  if {$pos eq ""} {
    set TID [alited::bar::CurrentTabID]
    set pos [$wtxt index insert]
  }
  set alited::tree::doFocus no
  set wtree [$obPav Tree]
  catch {
    if {$al(TREE,isunits)} {
      # search the tree for a unit with current line of text
      set itemID [alited::tree::CurrentItemByLine $pos]
    } else {
      # search the tree for a current file
      foreach it [alited::tree::GetTree] {
        if {[lindex $it 4 1] eq [alited::bar::FileName]} {
          set itemID [lindex $it 2]
          break
        }
      }
    }
  }
  catch {
    if {$itemID ni [$wtree selection]} {$wtree selection set $itemID}
    if {$itemID ne ""} {after 10 "catch {$wtree see $itemID}"}
  }
  catch {::tk::TextSetCursor $wtxt $pos}
  catch {focus $wtxt}
  after idle {set ::alited::tree::doFocus yes}
}

proc main::GutterAttrs {} {
  # Returns list of gutter's data (canvas widget, width, shift)
  namespace upvar ::alited obPav obPav
  return [list [$obPav GutText] 5 4]
}

proc main::HighlightText {TID curfile wtxt} {
  namespace upvar ::alited al al obPav obPav
  set clrnams [::hl_tcl::hl_colorNames]
  foreach nam $clrnams {lappend colors $al(ED,$nam)}
  lappend colors [lindex [$obPav csGet] 16]
  set ext [string tolower [file extension $curfile]]
  if {![info exists al(HL,$wtxt)] || $al(HL,$wtxt) ne $ext} {
    if {[alited::file::IsClang $curfile]} {
      if {![namespace exists ::hl_c]} {
        source [file join $alited::HLDIR hl_c.tcl]
      }
      ::hl_c::hl_init $wtxt -dark [$obPav csDarkEdit] \
        -multiline 0 \
        -cmdpos "::alited::main::CursorPos" \
        -cmd "::alited::unit::Modified $TID" \
        -font "-family {[$obPav basicTextFont]} -size $al(FONTSIZE,txt)"
    } else {
      ::hl_tcl::hl_init $wtxt -dark [$obPav csDarkEdit] \
        -multiline $al(prjmultiline) \
        -cmd "::alited::unit::Modified $TID" \
        -cmdpos "::alited::main::CursorPos" \
        -font "-family {[$obPav basicTextFont]} -size $al(FONTSIZE,txt)" \
        -plaintext [expr {![alited::file::IsTcl $curfile]}] \
        -colors $colors
    }
  }
  UpdateText $wtxt $curfile
  set al(HL,$wtxt) $ext
}

proc main::PackTextWidgets {wtxt wsbv} {

  namespace upvar ::alited al al obPav obPav
  lassign [GutterAttrs] canvas width shift
  # widgets created outside apave require the theming:
  $obPav csSet [$obPav csCurrent] $al(WIN) -doit
  pack $wtxt -side left -expand 1 -fill both
  pack $wsbv -fill y -expand 1
  set bind [list $obPav fillGutter $wtxt $canvas $width $shift]
  {*}$bind
}

proc main::FocusInText {TID wtxt} {
  namespace upvar ::alited obPav obPav
  if {![alited::bar::BAR isTab $TID]} return
  ::alited::main::CursorPos $wtxt
  [$obPav TreeFavor] selection set {}
  alited::file::OutwardChange $TID
}

proc main::BindsForText {TID wtxt} {
  if {[alited::bar::BAR isTab $TID]} {
    bind $wtxt <FocusIn> [list after 200 "::alited::main::FocusInText $TID $wtxt"]
  }
  bind $wtxt <Control-ButtonRelease-1> "::alited::find::SearchUnit $wtxt ; break"
  bind $wtxt <Control-Shift-ButtonRelease-1> "::alited::find::SearchWordInSession ; break"
  bind $wtxt <Control-Tab> "::alited::bar::ControlTab ; break"
  alited::keys::ReservedAdd $wtxt
  alited::keys::BindKeys $wtxt action
  alited::keys::BindKeys $wtxt template
  alited::keys::BindKeys $wtxt preference
}

proc main::CurrentWTXT {} {
  return [lindex [alited::bar::GetBarState] 2]
}

proc main::GetWTXT {TID} {
  return [alited::bar::GetTabState $TID --wtxt]
}

proc main::ShowHeader {{doit no}} {
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

proc main::CursorPos {wtxt args} {
  namespace upvar ::alited obPav obPav
  if {$args eq ""} {set args [$wtxt index "end -1 char"]}
  lassign [split [$wtxt index insert] .] r c
  [$obPav Labstat1] configure -text "$r / [expr {int([lindex $args 0])}]"
  [$obPav Labstat2] configure -text [incr c]
}

proc main::InsertLine {} {
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

proc main::GotoLine {} {
  namespace upvar ::alited al al obDl2 obDl2
  set head [msgcat::mc "Go to Line"]
  set prompt [msgcat::mc "Line number:"]
  set wtxt [CurrentWTXT]
  set ln [expr {int([$wtxt index insert])}]
  set lmax [expr {int([$wtxt index "end -1c"])}]
  lassign [$obDl2 input "" $head [list \
    Spx "{$prompt} {} {-w 6 -justify center -from 1 -to $lmax -selected yes}" "{$ln}" \
  ]] res ln
  if {$res} {
    ::tk::TextSetCursor $wtxt $ln.0
    ::hl_tcl::hl_line $wtxt
  }
}

proc main::MoveItem {to {f1112 no}} {
  namespace upvar ::alited al al obPav obPav
  if {!$al(TREE,isunits) && [alited::file::MoveExternal $f1112]} return
  set wtree [$obPav Tree]
  set itemID [$wtree selection]
  if {$itemID eq ""} {
    set itemID [$wtree focus]
  }
  if {$itemID eq ""} {
    if {$f1112} {set geo ""} {set geo "-geometry pointer+10+10"}
    alited::Message "No item selected." 4
    return
  }
  if {$al(TREE,isunits)} {
    alited::unit::MoveUnits $wtree $to $itemID $f1112
  } else {
    alited::file::MoveFile $wtree $to $itemID $f1112
  }
}

proc main::UpdateProjectInfo {} {
  namespace upvar ::alited al al obPav obPav
  if {$al(prjroot) ne ""} {set stsw normal} {set stsw disabled}
  [$obPav BuTswitch] configure -state $stsw
  if {[set eol $al(prjEOL)] eq ""} {set eol auto}
  [$obPav Labstat4] configure -text "eol=$eol, [msgcat::mc ind]=$al(prjindent)"
}

proc main::_create {} {

  namespace upvar ::alited al al obPav obPav
  lassign [$obPav csGet] - - ::alited::FRABG - - - - - bclr
  ttk::style configure TreeNoHL {*}[ttk::style configure Treeview] -borderwidth 0
  ttk::style map TreeNoHL {*}[ttk::style map Treeview] \
    -bordercolor [list focus $bclr active $bclr] \
    -lightcolor [list focus $::alited::FRABG active $::alited::FRABG] \
    -darkcolor [list focus $::alited::FRABG active $::alited::FRABG]
  ttk::style layout    TreeNoHL [ttk::style layout Treeview]
  $obPav untouchWidgets *.frAText *.fraBot.fra.lbxInfo *.entFind
  # make the main apave object and populate it
  $obPav makeWindow $al(WIN).fra alited
  $obPav paveWindow $al(WIN).fra {
    {Menu - - - - - {-array {
      file File
      edit Edit
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
    -command alited::tree::RecreateTree}}
    {.fraBot.panBM.fraTree.fra1.sev1 - - - - {pack -side left -fill y -padx 5}}
    {.fraBot.panBM.fraTree.fra1.BuTUp - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_up -command {alited::main::MoveItem up}}}
    {.fraBot.panBM.fraTree.fra1.BuTDown - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_down -command {alited::main::MoveItem down}}}
    {.fraBot.panBM.fraTree.fra1.sev2 - - - - {pack -side left -fill y -padx 5}}
    {.fraBot.panBM.fraTree.fra1.BuTAddT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_add -command alited::tree::AddItem}}
    {.fraBot.panBM.fraTree.fra1.BuTDelT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_delete -command alited::tree::DelItem}}
    {.fraBot.panBM.fraTree.fra1.h_ - - - - {pack -anchor center -side left -fill both -expand 1}}
    {.fraBot.panBM.fraTree.fra1.buTCtr - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_minus -command {alited::tree::ExpandTree Tree no} -tip {$alited::al(MC,ctrtree)}}}
    {.fraBot.panBM.fraTree.fra1.buTExp - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_plus -command {alited::tree::ExpandTree Tree} -tip {$alited::al(MC,exptree)}}}
    {.fraBot.panBM.fraTree.fra1.sev3 - - - - {pack -side right -fill y -padx 0}}
    {.fraBot.panBM.fraTree.fra - - - - {pack -side bottom -fill both -expand 1} {}}
    {.fraBot.panBM.fraTree.fra.Tree - - - - {pack -side left -fill both -expand 1} 
      {-columns {L1 L2 PRL ID LEV LEAF FL1} -displaycolumns {L1} -columnoptions "#0 {-width $::alited::al(TREE,cw0)} L1 {-width $::alited::al(TREE,cw1) -anchor e}" -style TreeNoHL -takefocus 0}}
    {.fraBot.panBM.fraTree.fra.SbvTree .fraBot.panBM.fraTree.fra.Tree L - - {pack -side right -fill both}}
    {.FraFV - - - - {add}}
    {.fraFV.v_ - - - - {pack -side top -fill x} {-h 5}}
    {.fraFV.fra1 - - - - {pack -side top -fill x}}
    {.fraFV.fra1.seh - - - - {pack -side top -fill x -expand 1 -pady 0}}
    {.fraFV.fra1.BuTVisitF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_misc -tip {$alited::al(MC,lastvisit)} -com alited::favor::SwitchFavVisit}}
    {.fraFV.fra1.sev1 - - - - {pack -side left -fill y -padx 5}}
    {.fraFV.fra1.BuTListF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_heart -tip {$alited::al(MC,FavLists)} -com alited::favor::Lists}}
    {.fraFV.fra1.BuTAddF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_add -tip {$alited::al(MC,favoradd)} -com alited::favor::Add}}
    {.fraFV.fra1.BuTDelF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_delete -tip {$alited::al(MC,favordel)} -com alited::favor::Delete}}
    {.fraFV.fra1.h_2 - - - - {pack -anchor center -side left -fill both -expand 1}}
    {.fraFV.fra1.sev2 - - - - {pack -side right -fill y -padx 0}}
    {.fraFV.fra - - - - {pack -fill both -expand 1} {}}
    {.fraFV.fra.TreeFavor - - - - {pack -side left -fill both -expand 1} {-h 5 -style TreeNoHL -columns {C1 C2 C3 C4} -displaycolumns C1 -show headings -takefocus 0}}
    {.fraFV.fra.SbvFavor .fraFV.fra.TreeFavor L - - {pack -side left}}
    {fra.pan.PanR - - - - {add} {-orient vertical $alited::PanR_wh}}
    {.fraTop - - - - {add}}
    {.fraTop.PanTop - - - - {pack -fill both -expand 1} {$alited::PanTop_wh}}
    {.fraTop.panTop.BtsBar  - - - - {pack -side top -fill x -pady 3} {alited::bar::FillBar %w}}
    {.fraTop.panTop.GutText - - - - {pack -side left -expand 0 -fill both} {}}
    {.fraTop.panTop.CanDiff - - - - {pack -side left -expand 0 -fill y} {-w 4}}
    {.fraTop.panTop.FrAText - - - - {pack -side left -expand 1 -fill both} {-background $::alited::FRABG}}
    {.fraTop.panTop.frAText.Text - - - - {pack forget -side left -expand 1 -fill both} {-borderwidth 0 -w 2 -h 20 -gutter GutText -gutterwidth 5 -guttershift 4 $alited::al(TEXT,opts)}}
    {.fraTop.panTop.fraSbv - - - - {pack -side right -fill y}}
    {.fraTop.panTop.fraSbv.SbvText .fraTop.panTop.frAText.text L - - {pack -fill y}}
    {.fraTop.FraHead  - - - - {pack forget -side bottom -fill x} {-padding {4 4 4 4} -relief groove}}
    {.fraTop.fraHead.labFind - - - - {pack -side left} {-t "    Unit: "}}
    {.fraTop.fraHead.EntFindSTD - - - - {pack -side left} {-tvar alited::al(findunit) -w 30 -tip {$al(MC,findunit)}}}
    {.fraTop.fraHead.buT - - - - {pack -side left -padx 4} {-t Find: -relief flat -com alited::find::DoFindUnit -takefocus 0 -bd 0 -highlightthickness 0 -w 8 -anchor e}}
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
      {{$alited::al(MC,Row:)} -font {-slant italic -size $alited::al(FONTSIZE,small)}} 12
      {{$alited::al(MC,Col:)} -font {-slant italic -size $alited::al(FONTSIZE,small)}} 5
      {"" -font {-slant italic -size $alited::al(FONTSIZE,small)} -anchor w -expand 1} 50
      {"" -font {-slant italic -size $alited::al(FONTSIZE,small)} -anchor e} 25
    }}}
  }
  UpdateProjectInfo
  bind [$obPav Pan] <ButtonRelease> ::alited::tree::AdjustWidth
  set sbhi [$obPav SbhInfo]
  set lbxi [$obPav LbxInfo]
  pack forget $sbhi
  bind $lbxi <FocusIn> "alited::info::FocusIn $sbhi $lbxi"
  bind $lbxi <FocusOut> "alited::info::FocusOut $sbhi"
  bind $lbxi <<ListboxSelect>> {alited::info::ListboxSelect %W}
  bind $lbxi <ButtonPress-3> {alited::info::PopupMenu %X %Y}
  bind [$obPav ToolTop] <ButtonPress-3> "::alited::tool::PopupBar %X %Y"
}

proc main::_run {} {

  namespace upvar ::alited al al obPav obPav
  ::apave::setAppIcon $al(WIN) $::alited::img::_AL_IMG(ale)
  ::apave::setProperty DirFilGeoVars [list ::alited::DirGeometry ::alited::FilGeometry]
  set ans [$obPav showModal $al(WIN) -decor 1 -minsize {500 500} -escape no \
    -onclose alited::Exit {*}$al(GEOM)]
  if {$ans ne "2"} {alited::ini::SaveIni}
  destroy $al(WIN)
  $obPav destroy
  return $ans
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
