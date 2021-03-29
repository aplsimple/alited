#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The main form of alited.
# _______________________________________________________________________ #

namespace eval main {}

proc main::ShowText {{newsuf "-1"}} {

  namespace upvar ::alited al al obPav obPav
  set curfile [alited::bar::CurrentTab 2]
  set wtxt [$obPav Text]
  set wsbv [$obPav SbvText]
  set doinit yes
  set TID [alited::bar::CurrentTabID]
  lassign [alited::bar::GetBarState] TIDold fileold wold1 wold2
  lassign [alited::bar::GetTabState $TID --pos --pos_S2] pos pos_S2
  if {$TIDold eq "-1"} {
    ;# first text to edit in original Text widget: create its scrollbar
    set additW12 "_S2"
    BindsForText $wtxt
  } elseif {[alited::bar::GetTabState $TID --wtxt] ne ""} {
    # edited text: get its widgets' data
    lassign [alited::bar::GetTabState $TID --wtxt --wsbv] wtxt wsbv
    set doinit no
  } else {
    # till now, not edited text: create its own Text/SbvText widgets
    set additW12 [list "" "_S2"]
    append wtxt "_$TID"  ;# new text
    append wsbv "_$TID"  ;# new scrollbar
  }
  if {![string is double -strict $pos]} {set pos 1.0}
  if {![string is double -strict $pos_S2]} {set pos_S2 1.0}
  # check for previous text and hide it, if it's not the selected one
  set oldsuf [CurrentSUF $TIDold]
  if {$newsuf eq "-1"} {set newsuf [CurrentSUF $TID]}
  set dopack [expr {$TID ne $TIDold || $newsuf ne $oldsuf}]
  if {$dopack && [winfo exists $wold1]} {
    if {$oldsuf eq ""} {
      alited::bar::SetTabState $TIDold --pos [$wold1 index insert]
    } else {
      alited::bar::SetTabState $TIDold --pos_S2 [$wold1 index insert]
    }
    catch {pack forget $wold1}  ;# a text
    catch {pack forget $wold2}  ;# a scrollbar
  }
  CurrentSUF $TID $newsuf
  alited::bar::SetTabState $TID --fname $curfile --wtxt $wtxt --wsbv $wsbv
  # create the text and the scrollbar if new
  if {![winfo exists "${wtxt}_S2"]} {
    lassign [GutterAttrs] canvas width shift
    foreach p $additW12 {
      set w1 $wtxt$p
      set w2 $wsbv$p
      set texopts [lindex [$obPav defaultAttrs tex] 1]
      lassign [::apave::extractOptions texopts -selborderwidth 1] selbw
      text $w1 {*}$texopts
      $w1 tag configure sel -borderwidth $selbw
      $obPav themeNonThemed [winfo parent $w1]
      set bind [list $obPav fillGutter $w1 $canvas $width $shift]
      bind $w1 <Configure> $bind
      if {[trace info execution $w1] eq ""} {
        trace add execution $w1 leave $bind
      }
      ttk::scrollbar $w2 -orient vertical -takefocus 0
      $w1 configure -yscrollcommand "$w2 set"
      $w2 configure -command "$w1 yview"
      BindsForText $w1
    }
  }
  # show the selected text
  lassign [CurrentSUF $TID $newsuf $wtxt $wsbv] wtxt wsbv
  if {$doinit} {
    alited::file::ReadFile $TID $curfile $wtxt
  }
  if {$doinit || $newsuf ne ""} {
    HighlightText $curfile $wtxt
  }
  if {$dopack} {
    PackTextWidgets $wtxt $wsbv
  }
  if {$doinit || $dopack} {
    alited::tree::Create
  }
  FocusText $TID $wtxt [set pos$newsuf]
  alited::bar::SetBarState [alited::bar::CurrentTabID] $curfile $wtxt $wsbv
  alited::file::CheckMenuItems
  focus $wtxt
  ShowHeader
}

proc main::FocusText {TID wtxt pos} {

  namespace upvar ::alited al al obPav obPav
  set alited::tree::doFocus no
  catch {
    set wtree [$obPav Tree]
    set l [expr {int($pos)}]
    foreach it $al(_unittree,$TID) {
      set itemID [alited::tree::NewItemID [incr iit]]
      lassign $it lev leaf fl1 title l1 l2
      if {$l1<=$l && $l<=$l2} {
        $wtree see $itemID
        if {$itemID ni [$wtree selection]} {
          $wtree selection set $itemID
        }
        break
      }
    }
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

proc main::HighlightText {curfile wtxt} {
  namespace upvar ::alited al al obPav obPav
  set ext [string tolower [file extension $curfile]]
  switch -- $ext {
    .tcl {
      if {![info exists al(HL,$wtxt)] || $al(HL,$wtxt) ne $ext} {
        ::hl_tcl::hl_init $wtxt -dark [$obPav csDarkEdit] \
          -multiline $al(ED,multiline) \
          -cmd "::alited::bar::TextModified [alited::bar::CurrentTabID]" \
          -cmdpos "::alited::main::CursorPos"
        ::hl_tcl::hl_text $wtxt
      }
    }
    default {
    }
  }
  set al(HL,$wtxt) $ext
}


proc main::PackTextWidgets {wtxt wsbv} {

  namespace upvar ::alited obPav obPav
  lassign [GutterAttrs] canvas width shift
  pack $wtxt -side left -expand 1 -fill both
  pack $wsbv -fill y -expand 1
  set bind [list $obPav fillGutter $wtxt $canvas $width $shift]
  {*}$bind
}

proc main::BindsForText {wtxt} {

  bind $wtxt <F2> {::alited::file::SaveFile}
  foreach s {s S} {
    bind $wtxt "<Control-$s>" {::alited::file::SaveFileAs}
    bind $wtxt "<Shift-Control-$s>" {::alited::file::SaveAll}
  }
  foreach s {n N} {bind $wtxt "<Control-$s>" {::alited::file::NewFile}}
  foreach s {o O} {bind $wtxt "<Control-$s>" {::alited::file::OpenFile; break}}
  foreach s {w W} {bind $wtxt "<Control-$s>" {::alited::file::SaveFileAndClose}}
  bind $wtxt <F11> {+ ::alited::unit::MoveItem Up}
  bind $wtxt <F12> {+ ::alited::unit::MoveItem Down}
  bind $wtxt <FocusIn> "::alited::main::CursorPos $wtxt"
}

proc main::CurrentSUF {TID {suf "-1"} {w1 ""} {w2 ""}} {

  if {![alited::bar::BAR isTab $TID]} {return ""}
  if {$suf == -1} {
    return [alited::bar::BAR $TID cget -ALSUF]
  } else {
    alited::bar::BAR $TID configure -ALSUF $suf
  }
  return [list $w1$suf $w2$suf]
}

proc main::CurrentWTXT {} {
  return [lindex [alited::bar::GetBarState] 2]
}

proc main::ShowHeader {} {
  namespace upvar ::alited al al
  if {[alited::file::IsModified]} {set modif "*"} {set modif " "}
  set TID [alited::bar::CurrentTabID]
  if {$modif ne [alited::bar::BAR $TID cget -ALmodif]} {
    alited::bar::BAR $TID configure -ALmodif $modif
    set f [alited::bar::CurrentTab 1]
    set d [file normalize [file dirname [alited::bar::CurrentTab 2]]]
    set p [file rootname $al(prjname)]
    set ttl [string map [list %f $f %d $d %p $p] $al(TITLE)]
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

proc main::_create {} {
  namespace upvar ::alited al al obPav obPav

  # these lines eliminate the background blinked at switching tabs
  $obPav untouchWidgets *.frAText
  set ::alited::FRABG [lindex [$obPav csGet] 2]
  # make the main apave object and populate it
  $obPav makeWindow $al(WIN).fra alited
  $obPav paveWindow $al(WIN).fra {
    {Menu - - - - - {-array {
      File "&File"
      edit "&Edit"
      Help "&Help"
    }} alited::file::FillMenu}
    {frat - - - - {pack -fill both}}
    {frat.toolTop - - - - {pack -side top} {-relief flat -borderwidth 0 -array {$alited::al(tool)}}}
    {fra - - - - {pack -side top -fill both -expand 1 -pady 0}}
    {fra.Pan - - - - {pack -side top -fill both -expand 1} {-orient horizontal $alited::Pan_wh}}
    {fra.pan.PanL - - - - {add} {-orient vertical $alited::PanL_wh}}
    {.fraBot - - - - {add}}
    {.fraBot.PanBM - - - - {pack -fill both -expand 1} {$alited::PanBM_wh}}
    {.fraBot.panBM.FraTree - - - - {pack -side top -fill both -expand 1}}
    {.fraBot.panBM.fraTree.v_ - - - - {pack -side top -fill x} {-h 3}}
    {.fraBot.panBM.fraTree.fra1 - - - - {pack -side top -fill x}}
    {.fraBot.panBM.fraTree.fra1.BuTswitch - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_tree -command {alited::tree::SwitchTree}}}
    {.fraBot.panBM.fraTree.fra1.BuTUp - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_up -tooltip {$alited::al(MC,moveup)}}}
    {.fraBot.panBM.fraTree.fra1.BuTDown - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_down -tooltip {$alited::al(MC,movedown)}}}
    {.fraBot.panBM.fraTree.fra1.BuTAddT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_plus}}
    {.fraBot.panBM.fraTree.fra1.BuTDelT - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_minus}}
    {.fraBot.panBM.fraTree.fra - - - - {pack -side bottom -fill both -expand 1} {}}
    {.fraBot.panBM.fraTree.fra.Tree - - - - {pack -side left -fill both -expand 1} 
      {-columns {L1 L2 PRL ID LEV LEAF FL1} -displaycolumns {L1} -columnoptions "#0 {-width $::alited::al(TREE,cw0)} L1 {-width $::alited::al(TREE,cw1) -anchor e}"}}
    {.fraBot.panBM.fraTree.fra.SbvTree .fraBot.panBM.fraTree.fra.Tree L - - {pack -side right -fill both}}
    {.fratex - - - - {add}}
    {.fratex.v_ - - - - {pack -side top -fill x} {-h 10}}
    {.fratex.fra1 - - - - {pack -side top -fill x}}
    {.fratex.fra1.BuTFavLists - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_heart -tooltip {$alited::al(MC,FavLists)}}}
    {.fratex.fra1.BuTAddF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_add -tooltip {$alited::al(MC,favoradd)}}}
    {.fratex.fra1.BuTDelF - - - - {pack -side left -fill x} {-relief flat -highlightthickness 0 -takefocus 0 -image alimg_delete -tooltip {$alited::al(MC,favordel)}}}
    {.fratex.fra1.lab - - - - {pack -side left -fill x} {-t "Favorites" -anchor center}}
    {.fratex.fra - - - - {pack -fill both -expand 1} {}}
    {.fratex.fra.Text3 - - - - {pack -side left -fill both -expand 1} {-borderwidth 0 -h 20 -w 5 -wrap none}}
    {.fratex.fra.SbvFavor .fratex.fra.Text3 L - - {pack -side left}}
    {fra.pan.PanR - - - - {add} {-orient vertical $alited::PanR_wh}}
    {.fraTop - - - - {add}}
    {.fraTop.PanTop - - - - {pack -fill both -expand 1} {$alited::PanTop_wh}}
    {.fraTop.panTop.BtsBar  - - - - {pack -side top -fill x -pady 3} {alited::bar::FillBar %w}}
    {.fraTop.panTop.fraHead  - - - - {pack -side top -fill x}}
    {.fraTop.panTop.GutText - - - - {pack -side left -expand 0 -fill both} {}}
    {.fraTop.panTop.FrAText - - - - {pack -side left -expand 1 -fill both} {-background $::alited::FRABG}}
    {.fraTop.panTop.frAText.Text - - - - {pack forget -side left -expand 1 -fill both} {-borderwidth 0 -w 2 -h 20 -gutter GutText -gutterwidth 5 -guttershift 4 -wrap word}}
    {.fraTop.panTop.fraSbv - - - - {pack -side right -fill y}}
    {.fraTop.panTop.fraSbv.SbvText .fraTop.panTop.frAText.text L - - {pack -fill y}}
    {.fraBot - - - - {add}}
    {.fraBot.fra - - - - {pack -fill both -expand 1}}
    {.fraBot.fra.Text4 - - - - {pack -side left -fill both -expand 1} {-h 1 -w 2 -wrap none}}
    {.fraBot.fra.sbv .fraBot.fra.Text4 L - - {pack}}
    {.fraBot.stat - - - - {pack -side bottom} {-array {
      {Row:       -font {-slant italic -size $alited::al(FSIZE,small)}} 12
      {" Col:" -font {-slant italic -size $alited::al(FSIZE,small)}} 5
      {"" -font {-slant italic -size $alited::al(FSIZE,small)} -anchor w} 60
      {"" -font {-slant italic -size $alited::al(FSIZE,small)} -anchor e} 40
    }}}
  }
  bind [$obPav Pan] <ButtonRelease> ::alited::tree::AdjustWidth 
}

proc main::_run {} {
  namespace upvar ::alited al al obPav obPav
  [$obPav Labstat4] configure -text "System encoding: [encoding system]"
  $obPav showModal $al(WIN) -decor 1 -minsize {500 500} -escape no \
    -onclose alited::Exit {*}$al(GEOM)
  alited::ini::SaveIni
  destroy $al(WIN)
  $obPav destroy
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl -CS 23 -hue 0 -fontsize 11
