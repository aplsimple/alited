#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The find/replace procedures of alited.
# _______________________________________________________________________ #

namespace eval find {
  variable win $::alited::al(WIN).winFind
  variable data; array set data [list]
  set data(c1) 0
  set data(c2) 0
  set data(c3) 0
  set data(c4) 0
  set data(c5) 0
  set data(vals1) [list exac "gl*" {\s+reg[[:alpha:]]*$}]
  set data(vals2) [list "Exact matching string" "Global subject" "Boss Regularity"]
  set data(v1) 1
  set data(v2) 2
  set data(en1) ""
  set data(en2) ""
  set data(docheck) yes
  set geo root=$::alited::al(WIN)
  set minsize ""
  variable delim1 [list " " "" ";" \n \t \$ \" ` ' @ % ^ & * ( ) # = | \\ / : , . ? ! < >]
  variable ldelim [list " " "\n" "\t" "\}" "\{" "\[" "" "#" ";"]
  variable rdelim [list " " "\n" "\t" "\}" "\]" "" "#" ";"]
  variable adelim [list "\}" "\{" "\[" "\]" {*}$delim1]
  variable counts ""
}

proc find::GetCommandOfLine {line idx {delim ""}} {
  variable ldelim
  variable rdelim
  if {$delim ne ""} {
    set delim1 $delim
    set delim2 $delim
  } else {
    set delim1 $ldelim
    set delim2 $rdelim
  }
  set i1 [set i2 [string range $idx [string first . $idx]+1 end]]
  for {set i $i1} {1} {} {
    incr i -1
    if {[string index $line $i] in $delim1} {
      set i1 [expr {$i+1}]
      break
    }
  }
  for {set i $i1} {1} {} {
    incr i
    if {[string index $line $i] in $delim2} {
      set i2 [expr {$i-1}]
      break
    }
  }
  return [string trim [string range $line $i1 $i2]]
}

proc find::GetWordOfLine {line idx} {
  variable adelim
  return [GetCommandOfLine $line $idx $adelim]
}

proc find::GetCommandOfText {wtxt} {
  set idx [$wtxt index insert]
  set line [$wtxt get "$idx linestart" "$idx lineend"]
  return [list [GetCommandOfLine $line $idx] $idx]
}

proc find::GetWordOfText {} {
  set wtxt [alited::main::CurrentWTXT]
  if {[catch {set sel [$wtxt get sel.first sel.last]}]} {
    set idx [$wtxt index insert]
    set line [$wtxt get "$idx linestart" "$idx lineend"]
    set sel [GetWordOfLine $line $idx]
  }
  return $sel
}

proc find::GetFindEntry {} {
  variable data
  set wtxt [alited::main::CurrentWTXT]
  if {[catch {set sel [$wtxt get sel.first sel.last]}]} {
    set idx [$wtxt index insert]
    set line [$wtxt get "$idx linestart" "$idx lineend"]
    set sel [GetWordOfLine $line $idx]
  }
  set sel [string trim $sel]
  if {$sel ne ""} {set data(en1) $sel}
}

proc find::SearchThisUnit {com1 TID} {
  namespace upvar ::alited al al
  set found ""
  set withNS [expr {[string first ":" $com1]>-1}]
  foreach unit $al(_unittree,$TID) {
    lassign $unit - - - comm l1 l2
    if {$com1 eq $comm || $withNS && [string match "*::$comm" $com1]} {
      set found $l1
      break
    }
  }
  return $found
}

proc find::SearchUnit {wtxt} {
  namespace upvar ::alited al al
  lassign [GetCommandOfText $wtxt] com1 idx
  set com2 $com1
  if {$com1 eq ""} return
  set withNS [expr {[string first ":" $com1]>-1}]
  if {!$withNS} {
    # try to get the current unit's namespace
    set curr [lindex [alited::tree::CurrentItemByLine $idx yes] 4]
    set com2 [string cat [string range $curr 0 [string last ":" $curr]] $com1]
  }
  set TID [alited::bar::CurrentTabID]
  if {[set found [SearchThisUnit $com1 $TID]] eq "" && ($com1 eq $com2 || \
  [set found [SearchThisUnit $com2 $TID]] eq "")} {
    foreach tab [alited::bar::BAR listTab] {
      set TID [lindex $tab 0]
      if {![info exist al(_unittree,$TID)]} {
        alited::file::ReadFile $TID [alited::bar::FileName $TID]
      }
      if {[set found [SearchThisUnit $com1 $TID]] ne "" || ($com1 ne $com2 && \
      [set found [SearchThisUnit $com2 $TID]] eq "")} {
        break
      }
    }
  }
  if {$found ne ""} {
    alited::bar::BAR $TID show
    alited::main::FocusText $TID $found.0
  }
}

proc find::CheckData {op} {
  namespace upvar ::alited al al
  variable win
  variable data
  if {!$data(docheck)} {return yes}
  set foc ""
  foreach i {2 1} {
    if {[set data(en$i)] ne ""} {
      if {[set f [lsearch -exact [set data(vals$i)] [set data(en$i)]]]>-1} {
        set data(vals$i) [lreplace [set data(vals$i)] $f $f]
      }
      set data(vals$i) [linsert [set data(vals$i)] 0 [set data(en$i)]]
      catch {set data(vals$i) [lreplace [set data(vals$i)] $al(MISC,maxsaved) end]}
      $win.cbx$i configure -values [set data(vals$i)]
    } elseif {$i==1 || ($op eq "repl" && !$data(c3))} {
      set foc $win.cbx$i
    }
  }
  if {$foc ne ""} {
    bell
    focus $foc
    return no
  }
  return yes
}

proc find::FindOptions {wtxt} {
  variable data
  $wtxt tag remove fndTag 1.0 end
  set options [set stopidx ""]
  set findstr $data(en1)
  if {!$data(c2)} {append options "-nocase "}
  switch $data(v1) {
    2 {
      append options "-regexp "
      set findstr [string map {* .* ? . . \\. \{ \\\{ \} \\\} ( \\( ) \\) ^ \\^ \$ \\\$ - \\- + \\+} $findstr]
    }
    3 {
      append options "-regexp "}
    default {
      append options "-exact "}
  }
  return [list $findstr [string trim $options] $stopidx]
}

proc find::CheckWord {wtxt index1 index2} {
  variable adelim
  variable data
  if {$data(c1)} {
    set index10 [$wtxt index "$index1 - 1c"]
    set index20 [$wtxt index "$index2 + 1c"]
    if {[$wtxt get $index10 $index1] ni $adelim} {return no}
    if {[$wtxt get $index2 $index20] ni $adelim} {return no}
  }
  return yes
}

proc find::Search {wtxt} {
  namespace upvar ::alited obPav obPav
  variable data
  variable counts
  variable win
  set idx [$wtxt index insert]
  lassign [FindOptions $wtxt] findstr options
  if {![CheckData find]} {return {}}
  $obPav set_HighlightedString $findstr
  if {[$obPav csDarkEdit]} {
    set fg white
    set bg #005a5d
  } else {
    set fg black
    set bg #78fcff
  }
  $wtxt tag configure fndTag -borderwidth 1 -relief raised -foreground $fg -background $bg
  $wtxt tag lower fndTag
  if {[catch {set fnd [$wtxt search {*}$options -count alited::find::counts -all -- $findstr 1.0]} err]} {
    alited::msg ok err $err -title $alited::al(MC,error) -ontop yes -parent $win
    return {}
  }
  set i 0
  set res [list]
  foreach index1 $fnd {
    set index2 [$wtxt index "$index1 + [lindex $counts $i]c"]
    if {[CheckWord $wtxt $index1 $index2]} {
      lappend res [list $index1 $index2]
    }
    incr i
  }
  return $res
}

proc find::Find {} {
  variable data
  set wtxt [alited::main::CurrentWTXT]
  $wtxt tag remove sel 1.0 end
  set fndlist [Search $wtxt]
  if {![llength $fndlist]} return
  set indexprev [set indexnext 0]
  set index [$wtxt index insert]
  foreach idx12 $fndlist {
    lassign $idx12 index1 index2
    $wtxt tag add fndTag $index1 $index2
    if {[$wtxt compare $index1 < $index]} {
      set indexprev $index1
      set indp2 $index2
    }
    if {[$wtxt compare $index < $index1] && $indexnext==0} {
      set indexnext $index1
      set indn2 $index2
    }
  }
  if {$data(c4) && $data(v2)==1}        {  ;# search backward & wrap around
    if {!$indexprev} {lassign [lindex $fndlist end] indexprev indp2}
    ::tk::TextSetCursor $wtxt $indexprev
    $wtxt tag add sel $indexprev $indp2

  } elseif {$data(c4) && $data(v2)==2}  {  ;# search forward & wrap around
    if {!$indexnext || [lindex $fndlist end 0]==$indexnext} {
      lassign [lindex $fndlist 0] indexnext indn2
    }
    ::tk::TextSetCursor $wtxt $indexnext
    $wtxt tag add sel $indexnext $indn2

  } elseif {!$data(c4) &&$data(v2)==1}  {  ;# search backward & not wrap around
    if {$indexprev} {
      ::tk::TextSetCursor $wtxt $indexprev
      $wtxt tag add sel $indexprev $indp2
    } else bell

  } elseif {!$data(c4) && $data(v2)==2} {  ;# search forward & not wrap around
    if {$indexnext} {
      ::tk::TextSetCursor $wtxt $indexnext
      $wtxt tag add sel $indexnext $indn2
    } else bell
  }
  ::alited::main::CursorPos $wtxt
}

proc find::FindAll {wtxt TID} {
  set fname [file tail [alited::bar::FileName $TID]]
  set l1 -1
  set allfnd [Search $wtxt]
  foreach idx12 $allfnd {
    lassign $idx12 index1 index2
    $wtxt tag add fndTag $index1 $index2
    set l2 [expr {int($index1)}]
    if {$l1 != $l2} {
      set line [$wtxt get "$index1 linestart" "$index1 lineend"]
      alited::info::Put "$fname:$l2: [string trim $line]" [list $TID $l2]
      set l1 $l2
    }
  }
  return $allfnd
}

proc find::ShowResults {msg {mode 2}} {
  alited::info::Put $msg "" yes
  alited::Message "$msg [string repeat { } 40]" $mode
}

proc find::ShowResults1 {allfnd} {
  namespace upvar ::alited al al
  variable data
  ShowResults [string map [list %n [llength $allfnd] %s $data(en1)] $alited::al(MC,frres1)]
}

proc find::ShowResults2 {rn} {
  namespace upvar ::alited al al
  variable data
  ShowResults [string map [list %n $rn %s $data(en1) %r $data(en2)] $alited::al(MC,frres2)] 3
}

proc find::FindInText {} {
  alited::info::Clear
  set wtxt [alited::main::CurrentWTXT]
  set TID [alited::bar::CurrentTabID]
  ShowResults1 [FindAll $wtxt $TID]
}

proc find::FindInSession {} {
  namespace upvar ::alited al al
  alited::info::Clear
  set currTID [alited::bar::CurrentTabID]
  set allfnd [list]
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    if {![info exist al(_unittree,$TID)]} {
      alited::file::ReadFile $TID [alited::bar::FileName $TID]
    }
    lassign [alited::main::GetText $TID] curfile wtxt
    lappend allfnd {*}[FindAll $wtxt $TID]
  }
  ShowResults1 $allfnd
}

proc find::SearchWordInSession {} {
  variable data
  set saved $data(en1)
  if {[set data(en1) [GetWordOfText]] eq ""} {
    bell
  } else {
    set data(docheck) no
    FindInSession
    set data(docheck) yes
  }
  set data(en1) $saved
}

proc find::SetCursor {wtxt idx1} {
  variable data
  set len [string length $data(en2)]
  ::tk::TextSetCursor $wtxt [$wtxt index "$idx1 + ${len}c"]
  ::alited::main::CursorPos $wtxt
}

proc find::Replace {} {
  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  Find
  set wtxt [alited::main::CurrentWTXT]
  lassign [$wtxt tag ranges sel] idx1 idx2
  if {$idx1 ne "" && $idx2 ne ""} {
    $wtxt replace $idx1 $idx2 $data(en2)
    SetCursor $wtxt $idx1
    set msg [string map [list %n 1 %s $data(en1) %r $data(en2)] $alited::al(MC,frres2)]
    ShowResults $msg 3
  }
}

proc find::ReplaceAll {wtxt allfnd} {
  variable data
  set rn 0
  for {set i [llength $allfnd]} {$i} {} {
    incr i -1
    lassign [lindex $allfnd $i] idx1 idx2
    $wtxt replace $idx1 $idx2 $data(en2)
    incr rn
  }
  if {$rn} {SetCursor $wtxt [lindex $allfnd end 0]}
  return $rn
}

proc find::ReplaceInText {} {
  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  set fname [file tail [alited::bar::FileName]]
  set msg [string map [list %f $fname %s $data(en1) %r $data(en2)] $al(MC,frdoit1)]
  if {![alited::msg yesno warn $msg NO -title $al(MC,warning)]} {
    return ""
  }
  set wtxt [alited::main::CurrentWTXT]
  set rn [ReplaceAll $wtxt [Search $wtxt]]
  ShowResults2 $rn
}

proc find::ReplaceInSession {} {
  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  set msg [string map [list %s $data(en1) %r $data(en2)] $al(MC,frdoit2)]
  if {![alited::msg yesno warn $msg NO -title $al(MC,warning)]} {
    return ""
  }
  set currTID [alited::bar::CurrentTabID]
  set rn 0
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    if {![info exist al(_unittree,$TID)]} {
      alited::file::ReadFile $TID [alited::bar::FileName $TID]
    }
    lassign [alited::main::GetText $TID] curfile wtxt
    incr rn [ReplaceAll $wtxt [Search $wtxt]]
  }
  ShowResults2 $rn

}

proc find::Next {} {
  catch {event generate [alited::main::CurrentWTXT] <F3>}
}

proc find::ClearTags {} {
  variable win
  catch {
    if {![winfo exists $win]} {
      [alited::main::CurrentWTXT] tag remove fndTag 1.0 end
    }
  }
}

proc find::_close {} {
  namespace upvar ::alited obFND obFND
  catch {$obFND res $::alited::find::win 0}
  ClearTags
}

proc find::_create {} {
  namespace upvar ::alited al al obFND obFND
  variable win
  variable geo
  variable minsize
  variable data
  set res 1
  while {$res} {
    $obFND makeWindow $win $al(MC,frttl)
    $obFND paveWindow $win {
      {labB1 - - 1 1    {-st e}  {-t {$alited::al(MC,frfind)} -style TLabelFS}}
      {Cbx1 labB1 L 1 9 {-st wes} {-tvar ::alited::find::data(en1) -values {$::alited::find::data(vals1)}}}
      {labB2 labB1 T 1 1 {-st e}  {-t {$alited::al(MC,frrepl)} -style TLabelFS}}
      {cbx2 labB2 L 1 9 {-st wes} {-tvar ::alited::find::data(en2) -values {$::alited::find::data(vals2)}}}
      {labBm labB2 T 1 1 {-st e}  {-t {$alited::al(MC,frmatch)} -style TLabelFS}}
      {radA labBm L 1 1 {-st ws}  {-t {$alited::al(MC,frexact)} -var ::alited::find::data(v1) -value 1 -style TRadiobuttonFS}}
      {radB radA L 1 2 {-st ws}  {-t "Glob" -var ::alited::find::data(v1) -value 2 -tip {$alited::al(MC,frtip1)} -style TRadiobuttonFS}}
      {radC radB L 1 3 {-st es}  {-t "RE" -var ::alited::find::data(v1) -value 3 -tip {$alited::al(MC,frtip2)} -style TRadiobuttonFS}}
      {h_1 radC L 1 1  {-cw 1}}
      {h_2 labBm T 1 9  {-st es -rw 1}}
      {seh  h_2 T 1 9  {-st ews}}
      {chb1 seh  T 1 2 {-st w} {-t {$alited::al(MC,frword)} -var ::alited::find::data(c1) -style TCheckbuttonFS}}
      {chb2 chb1 T 1 2 {-st w} {-t {$alited::al(MC,frcase)} -var ::alited::find::data(c2) -style TCheckbuttonFS}}
      {chb3 chb2 T 1 2 {-st w} {-t {$alited::al(MC,frblnk)} -var ::alited::find::data(c3) -tip {$alited::al(MC,frtip3)} -style TCheckbuttonFS}}
      {sev1 chb1 L 5 1 }
      {fralabB3 sev1 L 4 6 {-st nsew} {-borderwidth 1 -relief groove}}
      {.labB3 - - - - {pack -anchor w} {-t {    $alited::al(MC,frdir)} -style TLabelFS}}
      {.rad1 - - - - {pack -anchor w -padx 5} {-t {$alited::al(MC,frup)} -image alimg_up -compound left -var ::alited::find::data(v2) -value 1 -style TRadiobuttonFS}}
      {.rad2 - - - - {pack -anchor w -padx 5} {-t {$alited::al(MC,frdown)} -image alimg_down -compound left -var ::alited::find::data(v2) -value 2 -style TRadiobuttonFS}}
      {.chb4 - - - - {pack -anchor sw} {-t {$alited::al(MC,frwrap)} -var ::alited::find::data(c4) -style TCheckbuttonFS}}
      {chb5 fralabB3 T 1 1 {-st sw} {-t {$alited::al(MC,frontop)} -var ::alited::find::data(c5) -tip {$alited::al(MC,frtip4)} -com "$::alited::obFND res $::alited::find::win -1" -style TCheckbuttonFS}}
      {sev2 cbx1 L 10 1 }
      {but1 sev2 L 1 1 {-st we} {-t {$alited::al(MC,frfind1)} -com "::alited::find::Find" -style TButtonWestBoldFS}}
      {but2 but1 T 1 1 {-st we} {-t {$alited::al(MC,frfind2)} -com "::alited::find::FindInText" -style TButtonWestFS}}
      {but3 but2 T 1 1 {-st we} {-t {$alited::al(MC,frfind3)} -com "::alited::find::FindInSession" -style TButtonWestFS}}
      {h_3 but3 T 2 1}
      {but4 h_3 T 1 1 {-st we} {-t {$alited::al(MC,frrepl1)}  -com "::alited::find::Replace" -style TButtonWestBoldFS}}
      {but5 but4 T 1 1 {-st nwe} {-t {$alited::al(MC,frfind2)} -com "::alited::find::ReplaceInText" -style TButtonWestFS}}
      {but6 but5 T 1 1 {-st nwe} {-t {$alited::al(MC,frfind3)} -com "::alited::find::ReplaceInSession" -style TButtonWestFS}}
      {h_4 but6 T 1 1}
      {but0 h_4 T 1 1 {-st swe} {-t "Close" -com ::alited::find::_close -style TButtonWestBoldFS}}
    }
    bind $win.cbx1 <Return> "$win.but1 invoke"  ;# the Enter key is
    bind $win.cbx2 <Return> "$win.but4 invoke"  ;# hot in comboboxes
    if {$minsize eq ""} {      ;# save default min.sizes
      after idle [list after 100 {
        set ::alited::find::minsize "-minsize {[winfo width $::alited::find::win] [winfo height $::alited::find::win]}"
      }]
    }
    after idle [$win.cbx1 selection range 0 end]
    set res [$obFND showModal $win -geometry $::alited::find::geo {*}$minsize -focus $win.cbx1 -modal no -ontop $data(c5)]
    set geo [wm geometry $win] ;# save the new geometry of the dialogue
    destroy $win
    ClearTags
  }
  focus -force [alited::main::CurrentWTXT]
}

proc find::_run {} {
  namespace upvar ::alited obFND obFND
  variable win
  GetFindEntry
  if {[winfo exists $win]} {
    wm withdraw $win
    wm deiconify $win
    if {[set foc [focus -lastfor $win]] ne ""} {
      focus $foc
    } else {
      focus [$obFND Cbx1]
    }
  } else {
    _create
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
