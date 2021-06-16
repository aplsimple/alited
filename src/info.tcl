#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The info panel.
# _______________________________________________________________________ #

namespace eval ::alited::info {
  variable list [list]
  variable info [list]
  variable focustext yes
}

proc info::Get {i} {
  variable list
  variable info
  return list [[lindex $list $i] [lindex $info $i]]
}

proc info::Put {msg {inf ""} {bold no}} {
  variable list
  variable info
  lappend list $msg
  lappend info $inf
  if {$bold} {
    namespace upvar ::alited obPav obPav
    lassign [alited::FgFgBold] -> fgbold
    [$obPav LbxInfo] itemconfigure end -foreground $fgbold
  }
}


proc info::Clear {{i -1}} {
  variable list
  variable info
  if {$i == -1} {
    set list [list]
    set info [list]
  } else {
    set list [lreplace $list $i $i]
    set info [lreplace $info $i $i]
    namespace upvar ::alited obPav obPav
    lassign [alited::FgFgBold] fg
    catch {[$obPav LbxInfo] itemconfigure 0 -foreground $fg}
  }
}

proc info::ListboxSelect {w} {
  variable info
  variable focustext
  set sel [lindex [$w curselection] 0]
  if {[string is digit -strict $sel]} {
    lassign [lindex $info $sel] TID line
    if {[alited::bar::BAR isTab $TID]} {
      if {$TID ne [alited::bar::CurrentTabID]} {
        alited::bar::BAR $TID show
      }
      after idle " \
        alited::main::FocusText $TID $line.0 ; \
        alited::tree::NewSelection {} $line.0 yes"
      if {!$focustext} {
        after 100 "focus $w"
      }
    }
  }
}

proc info::FocusIn {sbhi lbxi} {
  if {![winfo ismapped $sbhi]} {
    pack $sbhi -side bottom -before $lbxi -fill both
  }
}

proc info::FocusOut {sbhi} {
  variable focustext
  if {$focustext} {
    pack forget $sbhi
  }
}

proc info::SwitchFocustext {} {
  variable focustext
  if {$focustext} {set focustext 0} {set focustext 1}
}

proc info::PopupMenu {X Y} {
  namespace upvar ::alited al al obPav obPav
  variable focustext
  set popm $al(WIN).popupInfo
  catch {destroy $popm}
  menu $popm -tearoff 0
  if {$focustext} {
    set msg [msgcat::mc {Don't focus a text after selecting in infobar}]
  } else {
    set msg [msgcat::mc {Focus a text after selecting in infobar}]
  }
  $popm add command -label $msg -command "alited::info::SwitchFocustext"
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
