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
  set geo root=$::alited::al(WIN)
  set minsize ""
}

proc find::GetCommandOfLine {line idx} {
  set i1 [set i2 [string range $idx [string first . $idx]+1 end]]
  set ldelim [list " " "\t" "\}" "\{" "\[" ""]
  set rdelim [list " " "\t" "\}" "\]" ""]
  for {set i $i1} {1} {} {
    incr i -1
    if {[string index $line $i] in $ldelim} {
      set i1 [expr {$i+1}]
      break
    }
  }
  for {set i $i1} {1} {} {
    incr i
    if {[string index $line $i] in $rdelim} {
      set i2 [expr {$i-1}]
      break
    }
  }
  return [string trim [string range $line $i1 $i2]]
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
  set idx [$wtxt index insert]
  set line [$wtxt get "$idx linestart" "$idx lineend"]
  set com1 [set com2 [GetCommandOfLine $line $idx]]
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
  variable win
  variable data
  set foc ""
  foreach i {2 1} {
    if {[set data(en$i)] ne ""} {
      if {[set f [lsearch -exact [set data(vals$i)] [set data(en$i)]]]>-1} {
        set data(vals$i) [lreplace [set data(vals$i)] $f $f]
      }
      set data(vals$i) [linsert [set data(vals$i)] 0 [set data(en$i)]]
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

proc find::Find {} {
  variable data
  if {![CheckData find]} return
  # here might be some procedures to process the input data, e.g. showing:
  if {$data(c2)} {set c ""} {set c "-nocase "}
  switch $data(v1) {
    2 {
      set r [string match {*}$c $data(en1) $data(en2)]
    }
    3 {
      if {[catch {set r [regexp {*}$c $data(en1) $data(en2)]}]} {set r 0}
    }
    default {
      set r [string match {*}$c "*$data(en1)*" $data(en2)]
    }
  }
}

proc find::FindInText {} {
  if {![CheckData find]} return
}

proc find::FindInSession {} {
  if {![CheckData find]} return
}

proc find::Replace {} {
  if {![CheckData repl]} return
}

proc find::ReplaceInText {} {
  if {![CheckData repl]} return
}

proc find::ReplaceInSession {} {
  if {![CheckData repl]} return
}

proc find::Close {} {
  namespace upvar ::alited obFND obFND
  catch {$obFND res $::alited::find::win 0}
}

proc find::Show {} {
  namespace upvar ::alited al al obFND obFND
  variable win
  variable geo
  variable minsize
  variable data
  set res 1
  while {$res} {
    $obFND makeWindow $win $al(MC,frttl)
    $obFND paveWindow $win {
      {labB1 - - 1 1    {-st e}  {-t {$alited::al(MC,frfind)}}}
      {Cbx1 labB1 L 1 9 {-st wes} {-tvar ::alited::find::data(en1) -values {$::alited::find::data(vals1)}}}
      {labB2 labB1 T 1 1 {-st e}  {-t {$alited::al(MC,frrepl)}}}
      {cbx2 labB2 L 1 9 {-st wes} {-tvar ::alited::find::data(en2) -values {$::alited::find::data(vals2)}}}
      {labBm labB2 T 1 1 {-st e}  {-t {$alited::al(MC,frmatch)}}}
      {radA labBm L 1 1 {-st ws}  {-t {$alited::al(MC,frexact)} -var ::alited::find::data(v1) -value 1}}
      {radB radA L 1 2 {-st ws}  {-t "Glob" -var ::alited::find::data(v1) -value 2 -tip {$alited::al(MC,frtip1)}}}
      {radC radB L 1 3 {-st es}  {-t "RE" -var ::alited::find::data(v1) -value 3 -tip {$alited::al(MC,frtip2)}}}
      {h_1 radC L 1 1  {-cw 1}}
      {h_2 labBm T 1 9  {-st es -rw 1}}
      {seh  h_2 T 1 9  {-st ews}}
      {chb1 seh  T 1 2 {-st w} {-t {$alited::al(MC,frword)} -var ::alited::find::data(c1)}}
      {chb2 chb1 T 1 2 {-st w} {-t {$alited::al(MC,frcase)}  -var ::alited::find::data(c2)}}
      {chb3 chb2 T 1 2 {-st w} {-t {$alited::al(MC,frblnk)} -var ::alited::find::data(c3) -tip {$alited::al(MC,frtip3)}}}
      {sev1 chb1 L 5 1 }
      {fralabB3 sev1 L 4 6 {-st nsew} {-borderwidth 1 -relief groove}}
      {.labB3 - - - - {pack -anchor w} {-t {    $alited::al(MC,frdir)}}}
      {.rad1 - - - - {pack -anchor w -padx 5} {-t {$alited::al(MC,frup)} -image alimg_up -compound left -var ::alited::find::data(v2) -value 1}}
      {.rad2 - - - - {pack -anchor w -padx 5} {-t {$alited::al(MC,frdown)} -image alimg_down -compound left -var ::alited::find::data(v2) -value 2}}
      {.chb4 - - - - {pack -anchor sw} {-t {$alited::al(MC,frwrap)} -var ::alited::find::data(c4)}}
      {chb5 fralabB3 T 1 2 {-st sw} {-t {$alited::al(MC,frontop)} -var ::alited::find::data(c5) -tip {$alited::al(MC,frtip4)} -com "$::alited::obFND res $::alited::find::win -1"}}
      {sev2 cbx1 L 10 1 }
      {but1 sev2 L 1 1 {-st we} {-t {$alited::al(MC,frfind1)} -com "::alited::find::Find" -style TButtonWestBold}}
      {but2 but1 T 1 1 {-st we} {-t {$alited::al(MC,frfind2)} -com "::alited::find::FindInText" -style TButtonWest}}
      {but3 but2 T 1 1 {-st we} {-t {$alited::al(MC,frfind3)} -com "::alited::find::FindInSession" -style TButtonWest}}
      {h_3 but3 T 2 1}
      {but4 h_3 T 1 1 {-st we} {-t {$alited::al(MC,frrepl1)}  -com "::alited::find::Replace" -style TButtonWestBold}}
      {but5 but4 T 1 1 {-st nwe} {-t {$alited::al(MC,frfind2)} -com "::alited::find::ReplaceInText" -style TButtonWest}}
      {but6 but5 T 1 1 {-st nwe} {-t {$alited::al(MC,frfind3)} -com "::alited::find::ReplaceInSession" -style TButtonWest}}
      {h_4 but6 T 1 1}
      {but0 h_4 T 1 1 {-st swe} {-t "Close" -com "$::alited::obFND res $::alited::find::win 0"}}
    }
    bind $win.cbx1 <Return> "$win.but1 invoke"  ;# the Enter key is
    bind $win.cbx2 <Return> "$win.but4 invoke"  ;# hot in comboboxes
    if {$minsize eq ""} {      ;# save default min.sizes
      after idle [list after 100 {
        set ::alited::find::minsize "-minsize {[winfo width $::alited::find::win] [winfo height $::alited::find::win]}"
      }]
    }
    set res [$obFND showModal $win -geometry $::alited::find::geo {*}$minsize -focus $win.cbx1 -modal no -ontop $data(c5)]
    set geo [wm geometry $win] ;# save the new geometry of the dialogue
    destroy $win
  }
  focus -force [alited::main::CurrentWTXT]
}

proc find::_run {} {
  namespace upvar ::alited obFND obFND
  variable win
  if {[winfo exists $win]} {
    wm withdraw $win
    wm deiconify $win
    if {[set foc [focus -lastfor $win]] ne ""} {
      focus $foc
    } else {
      focus [$obFND Cbx1]
    }
  } else {
    Show
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
