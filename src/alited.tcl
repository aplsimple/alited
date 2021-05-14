#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The starting script of alited.
# Contains a batch of alited's common procedures.
# _______________________________________________________________________ #

package provide alited 0.6

package require Tk
catch {package require comm}  ;# Generic message transport

# __________________________ Open existing app _________________________ #

namespace eval alited {

  proc raise_window {} {
    # Raises the app's window.

    variable al

    if {$::tcl_platform(platform) eq "windows"} {
      #wm attributes . -alpha 1.0
    } else {
      catch {wm deiconify . ; raise .}
      wm withdraw $al(WIN)
      wm deiconify $al(WIN)
    }
  }

  proc run_remote {cmd args} {
    # Runs a command that was started by another process.
  
    if {[catch { $cmd {*}$args }]} {
      return -code error
    }
  }
}

if {$::tcl_platform(platform) eq "windows"} {
  wm attributes . -alpha 0.0
} else {
  wm withdraw .
}
if {"DEBUG" eq [lindex $::argv 0]} {
  set ::argv [lreplace $::argv 0 0]
  incr ::argc -1
} elseif {$::tcl_platform(platform) eq "unix"} {
  set port 48784
  if {[catch {::comm::comm config -port $port}] && \
  ![catch {::comm::comm send $port ::alited::run_remote ::alited::raise_window }]} {
    destroy .
    exit
  }
} else {
  after idle ::alited::raise_window
}

# ________________________ Main variables _________________________ #

namespace eval alited {

  variable tcltk_version "Tcl/Tk [package versions Tk]"

  variable SCRIPT [info script]
  variable DIR [file normalize [file join [file dirname $SCRIPT] ..]]

  # directories of sources
  variable SRCDIR [file join $DIR src]

  variable LIBDIR [file join $DIR lib]

  # directories of required packages
  variable PAVEDIR [file join $LIBDIR pave]
  variable BARSDIR [file join $LIBDIR bartabs]
  variable HLDIR   [file join $LIBDIR hl_tcl]
  variable BALTDIR [file join $LIBDIR baltip]
  lappend ::auto_path $PAVEDIR $BARSDIR $HLDIR $BALTDIR

  set ::e_menu_dir [file join $LIBDIR e_menu]
  variable MNUDIR "$::e_menu_dir/menus"

  # directories of key data
  variable DATADIR [file join $DIR data]
  variable IMGDIR  [file join $DATADIR img]
  variable MSGSDIR [file join $DATADIR msgs]

  # directories of user's data
  variable USERDIRSTD [file normalize {~/.config}]
  variable USERDIRROOT $USERDIRSTD
  if {$::argc} {set USERDIRROOT [lindex $argv 0]}

  # two main objects to build forms (just some unique names)
  variable obPav ::alited::alitedpav
  variable obDlg ::alited::aliteddlg
  variable obDl2 ::alited::aliteddl2
  variable obFND ::alited::alitedFND

  # misc. vars
  variable DirGeometry ""
  variable FilGeometry ""

  # misc. consts
  variable PRJEXT ".ale"
  variable EOL {@~}  ;# "end of line" for ini-files

  # load localized messages
  msgcat::mcload $MSGSDIR

  # main data of alited (others are in ini.tcl)
  variable al; array set al [list]
  set al(WIN) .alwin
  set al(prjname) ""
  set al(prjfile) ""
  set al(prjroot) ""
  set al(prjindent) 2
  set al(prjmultiline) 0
  set al(prjEOL) {}
  set al(TITLE) "%f :: %d :: %p - alited"
}

# _____________________________ Packages used __________________________ #

package require bartabs
package require apave
package require hl_tcl
package require baltip

# __________________________ Common procs ________________________ #

namespace eval alited {

  proc msg {type icon message {defb ""} args} {
    # Shows a message and asks for an answer.
    #   type - ok/yesno/okcancel/yesnocancel
    #   icon - info/warn/err
    #   message - the message
    #   defb - default button (for not "ok" dialogs)
    #   args - additional arguments (-title and font's option)
    # For "ok" dialogue, 'defb' is omitted (being a part of args).

    variable obDlg
    variable al
    if {$type eq "ok"} {
      set args [linsert $args 0 $defb]
      set defb ""
    }
    lassign [::apave::extractOptions args -title ""] title
    if {$title eq ""} {
      switch $icon {
        "warn" {set title $al(MC,warning)}
        "err" {set title $al(MC,error)}
        "ques" {set title $al(MC,question)}
        default {set title $al(MC,info)}
     }
    }
    set res [$obDlg $type $icon $title "\n$message\n" {*}$defb {*}$args]
    after idle {catch alited::main::UpdateGutter}
    return [lindex $res 0]
  }

  proc Message {msg {mode 1} {lab ""} {first yes}} {
    variable al
    variable obPav
    lassign [FgFgBold] fg fgbold
    if {$lab eq ""} {set lab [$obPav Labstat3]}
    set font [[$obPav Labstat2] cget -font]
    set fontB "$font -weight bold"
    set slen [string length $msg]
    if {[catch {$lab configure -text $msg}] || !$slen} return
    $lab configure -font $font -foreground $fg
    if {$mode in {"2" "3" "4"}} {
      $lab configure -font $fontB
      if {$mode in {"3" "4"}} {
        $lab configure -foreground $fgbold
        if {$mode eq "4" && $first} bell
      }
    }
    if {$first} {
      set msec [expr {200*$slen}]
    } else {
      set msg [string range $msg 0 end-1]
      set msec 10
    }
    catch {after cancel $al(afterID)}
    if {$msec>0} {
      set al(afterID) [after $msec [list ::alited::Message $msg $mode $lab no]]
    }
  }

  proc Message2 {msg {first 1}} {
    variable obDl2
    alited::Message $msg $first [$obDl2 LabMess]
  }

  proc p+ {p1 p2} {
    # Sums two text positions straightforward: lines & columns separately.
    # The lines may be with "-".

    lassign [split $p1 .] l11 c11
    lassign [split $p2 .] l21 c21
    foreach n {l11 c11 l21 c21} {
      if {![string is digit -strict [string trimleft [set $n] -]]} {set $n 0}
    }
    return "[incr l11 $l21].[incr c11 $c21]"
  }

  proc HelpAbout {} {
    source [file join $alited::SRCDIR about.tcl]
    about::About
  }

  proc Help {win {suff ""}} {
    variable DATADIR
    set fname [lindex [split [dict get [info frame -1] proc] :] end-2]
    set fname [file join [file join $DATADIR help] $fname$suff.txt]
    if {[file exists $fname]} {
      set msg [::apave::readTextFile $fname]
    } else {
      set msg "Here should be a text of\n\"$fname\""
    }
    msg ok "" $msg -title Help -text 1 -geometry root=$win -scroll no
  }
  
  proc FgFgBold {} {
    variable obPav
    lassign [$obPav csGet] - fg - - - - - - - fgbold
    return [list $fg $fgbold]
  }

  proc Exit {{w ""} {res 0}} {
    variable al
    variable obPav
    if {[alited::file::AllSaved]} {
      $obPav res $al(WIN) $res
      alited::find::_close
      alited::tool::_close
    }
  }

# _______________________ Sources in alited NS _______________________ #

  source [file join $SRCDIR ini.tcl]
  source [file join $SRCDIR img.tcl]
  source [file join $SRCDIR msgs.tcl]
  source [file join $SRCDIR main.tcl]
  source [file join $SRCDIR bar.tcl]
  source [file join $SRCDIR file.tcl]
  source [file join $SRCDIR unit.tcl]
  source [file join $SRCDIR unit_tpl.tcl]
  source [file join $SRCDIR tree.tcl]
  source [file join $SRCDIR favor.tcl]
  source [file join $SRCDIR favor_ls.tcl]
  source [file join $SRCDIR find.tcl]
  source [file join $SRCDIR keys.tcl]
  source [file join $SRCDIR info.tcl]
  source [file join $SRCDIR tool.tcl]
  source [file join $SRCDIR menu.tcl]
  source [file join $SRCDIR pref.tcl]
  source [file join $SRCDIR project.tcl]
  source [file join $SRCDIR check.tcl]
}

# _________________________ Run the app _________________________ #

# this "if" satisfies the Ruff doc generator "package require":
if {[package versions alited] eq ""} {
  alited::ini::_init     ;# initialize GUI & data
  alited::main::_create  ;# create the main form
  alited::favor::_init   ;# initialize favorites
  if {[alited::main::_run]} {     ;# run the main form
    cd $alited::SRCDIR
    exec tclsh $alited::SCRIPT {*}$::argv &
  }
  exit
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
