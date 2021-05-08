#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The info panel.
# _______________________________________________________________________ #

namespace eval ::alited::info {
  variable list [list]
  variable info [list]
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
  }
}

proc info::ListboxSelect {w} {
  variable info
  set sel [lindex [$w curselection] 0]
  if {[string is digit -strict $sel]} {
    lassign [lindex $info $sel] TID line
    if {[alited::bar::BAR isTab $TID]} {
      if {$TID ne [alited::bar::CurrentTabID]} {
        alited::bar::BAR $TID show
      }
      after idle "alited::main::FocusText $TID $line.0 ; \
        alited::tree::NewSelection {} $line.0 yes"
    }
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
