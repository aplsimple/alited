###########################################################
# Name:    info.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles the info listbox widget.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval ::alited::info {
  variable list [list]   ;# list of listbox items
  variable info [list]   ;# data of listbox items (file, found position etc.)
  variable focustext yes ;# if yes, focuses on a text at the listbox selections
  variable lastred -2

  # these two allow to disable text updates at constant key pressings
  variable selectmsec 0   ;# saved time at key pressing
  variable selectafter {} ;# saved after ID at key pressing
}

# ________________________ Common _________________________ #

proc info::Get {i} {
  # Gets a message of the info listbox widget by its index.
  #   i - index of message

  variable list
  variable info
  return list [[lindex $list $i] [lindex $info $i]]
}
#_______________________

proc info::Put {msg {inf ""} {bold no} {see no}} {
  # Puts a message to the info listbox widget.
  #   msg - the message
  #   inf - additional data for the message (1st line of unit etc.)
  #   bold - if yes, displays the message bolded
  #   see - if yes, makes the message seen in red color

  namespace upvar ::alited obPav obPav
  variable list
  variable info
  variable lastred
  ClearRed
  set llen [llength $list]
  lappend list $msg
  lappend info $inf
  set lbx [$obPav LbxInfo]
  lassign [alited::FgFgBold] -> fgbold fgred
  if {$see} {
    set fgbold $fgred
    $lbx see end
    set lastred $llen
  } elseif {!$bold} {
    return
  }
  $lbx itemconfigure end -foreground $fgbold
}
#_______________________

proc info::Clear {{i -1}} {
  # Clears the info listbox widget and the related data.
  #   i - index of message (if omitted, clears all messages)

  namespace upvar ::alited obPav obPav
  variable list
  variable info
  variable lastred
  if {$i == -2} {
    # no action
  } elseif {$i == -1} {
    set list [list]
    set info [list]
  } else {
    lassign [$obPav csGet] fg
    catch {[$obPav LbxInfo] itemconfigure $i -foreground $fg}
    set list [lreplace $list $i $i]
    set info [lreplace $info $i $i]
  }
  set lastred -2
}
#_______________________

proc info::ClearOut {} {
  # Clears and out of the info listbox.

  namespace upvar ::alited obPav obPav
  Clear
  alited::main::FocusText
  FocusOut [$obPav SbhInfo]
}
#_______________________

proc info::ClearRed {} {
  # Clears a red message in info bar (if it was displayed).

  variable lastred
  Clear $lastred
}

# ________________________ GUI _________________________ #

proc info::ListboxSelect {w {checkit no}} {
  # Handles a selection event of the info listbox.
  #   w - listbox's path
  #   checkit - flag to check for the repeated calls of this procedure

  variable info
  variable focustext
  variable selectmsec
  variable selectafter
  set msec [clock milliseconds]
  if {($msec-$selectmsec)<500 && $checkit} {
    # this disables updating at key pressing, let a user release the key
    catch {after cancel $selectafter}
    set selectafter [after idle "alited::info::ListboxSelect $w yes"]
  } else {
    set sel [lindex [$w curselection] 0]
    if {[string is digit -strict $sel]} {
      update
      lassign [lindex $info $sel] TID line
      if {[alited::bar::BAR isTab $TID]} {
        if {$TID ne [alited::bar::CurrentTabID]} {
          alited::favor::SkipVisited yes
          alited::bar::BAR $TID show
        }
        after idle "catch { \
          alited::main::FocusText $TID $line.0 ; \
          alited::tree::NewSelection {} $line.0 yes ; \
          alited::main::HighlightLine}"
        if {!$focustext} {after 100 "focus $w"}
      }
    }
  }
  set selectmsec $msec
}
#_______________________

proc info::FocusIn {sbhi lbxi} {
  # At focusing in the info listbox, shows its scrollbar.
  #   sbhi - scrollbar's path
  #   lbxi - listbox's path

  if {![winfo ismapped $sbhi]} {
    pack $sbhi -side bottom -before $lbxi -fill both
  }
}
#_______________________

proc info::FocusOut {sbhi} {
  # At focusing out of the info listbox, hides its scrollbar.
  #   sbhi - scrollbar's path

  variable focustext
  if {$focustext} {
    pack forget $sbhi
  }
}
#_______________________

proc info::SwitchFocustext {} {
  # Switches a variable of flag "listbox is focused".

  namespace upvar ::alited obPav obPav
  variable focustext
  if {$focustext} {
    set focustext 0
    set lbx [$obPav LbxInfo]
    focus $lbx
    catch {
      $lbx selection clear 0 end
      $lbx selection set 0
      $lbx activate 0
      $lbx see 0
    }
  } else {
    set focustext 1
    FocusOut [$obPav SbhInfo]
    alited::main::FocusText
  }
}
#_______________________

proc info::PopupMenu {X Y} {
  # Runs a popup menu on the info listbox.
  #   X - x-coordinate of mouse pointer
  #   Y - y-coordinate of mouse pointer

  namespace upvar ::alited al al obPav obPav
  variable focustext
  set popm $al(WIN).popupInfo
  catch {destroy $popm}
  menu $popm -tearoff 0
  $popm add command -label $al(MC,favordelall) -command alited::info::ClearOut
  if {$focustext} {
    set msg [msgcat::mc {Don't focus a text after selecting in infobar}]
  } else {
    set msg [msgcat::mc {Focus a text after selecting in infobar}]
  }
  $popm add command -label $msg -command alited::info::SwitchFocustext
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}

# _________________________________ EOF _________________________________ #
