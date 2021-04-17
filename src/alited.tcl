#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The starting script of alited.
# Contains a batch of alited's common procedures.
# _______________________________________________________________________ #

package provide alited 0.1.2.5

package require Tk

namespace eval alited {

  variable tcltk_version "Tcl/Tk [package versions Tk]"

  variable SCRIPT [info script]
  variable DIR [file normalize [file join [file dirname $SCRIPT] ..]]

  # directories of sources
  variable SRCDIR [file join $DIR src]

  #variable LIBDIR [file join $DIR lib]

# TODO: to delete
variable LIBDIR [file normalize [file join $DIR ..]]
puts "LIBDIR=$LIBDIR"

  # directories of required packages
  variable PAVEDIR [file join $LIBDIR pave]
  variable BARSDIR [file join $LIBDIR bartabs]
  variable HLDIR   [file join $LIBDIR hl_tcl]
  variable BALTDIR [file join $LIBDIR baltip]
  lappend ::auto_path $PAVEDIR $BARSDIR $HLDIR $BALTDIR

  # directories of key data
  variable DATADIR [file join $DIR data]
  variable IMGDIR  [file join $DATADIR img]
  variable MSGSDIR [file join $DATADIR msgs]

  # directories of user's data
  variable USERDIR [file join $DIR data user]
  if {[file exists {~/.config}]} {
    set USERDIR [file normalize {~/.config/alited/data}]
  }
  variable INIDIR [file join $USERDIR ini]
  variable PRJDIR [file join $USERDIR prj]
  variable BAKDIR [file join $DIR .bak]
  if {![file exists $USERDIR]} {
    file mkdir $INIDIR
    file mkdir $PRJDIR
  }

  # two main objects to build forms (just some unique names)
  variable obPav ::alited::alitedpav
  variable obDlg ::alited::aliteddlg
  variable obDl2 ::alited::aliteddl2
  variable obFND ::alited::alitedFND

  # misc. consts
  variable EOL {@~}  ;# "end of line" for ini-files

  # load localized messages
  msgcat::mcload $MSGSDIR

  # main data of alited (others are in ini.tcl)
  variable al; array set al [list]
  set al(WIN) .alwin
  set al(PRJEXT) "alited"
  set al(prjname) "myproject.$al(PRJEXT)"
  set al(prjfile) [file join $PRJDIR $al(prjname)]
  set al(prjroot) [file normalize .]
  set al(TITLE) "%f :: %d :: %p - alited"
}

# _______________________________________________________________________ #

package require bartabs
package require apave
package require hl_tcl
package require baltip

# _______________________________________________________________________ #

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
    if {$type eq "ok"} {
      set args [linsert $args 0 $defb]
      set defb ""
    }
    lassign [::apave::extractOptions args -title ""] title
    if {$title eq ""} {set title [string toupper $icon]}
    set res [$obDlg $type $icon $title "\n$message\n" {*}$defb {*}$args]
    return [lindex $res 0]
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

  proc Exit {{w ""}} {
    variable al
    variable obPav
    if {[alited::file::AllSaved]} {
      $obPav res $al(WIN) 0
      alited::find::Close
    }
  }

  proc Message {msg {first 1} {lab ""}} {
    variable al
    variable obPav
    if {$lab eq ""} {set lab [$obPav Labstat3]}
    if {[catch {$lab configure -text $msg}]} return
    set slen [string length $msg]
    if {$first} {
      lassign [$obPav csGet] - fg - - - - - - - fgbold
      if {$first eq "2"} {
        bell
        set fg $fgbold
      }
      $lab configure -foreground $fg
      set msec [expr {200*$slen}]
    } else {
      set msg [string range $msg 0 end-1]
      set msec 10
    }
    catch {after cancel $al(afterID)}
    if {$msec>0} {
      set al(afterID) [after $msec "::alited::Message {$msg} 0 $lab"]
    }
  }

}

# _______________________________________________________________________ #

  # load all sources into alited namespace
  namespace eval alited {
    source [file join $SRCDIR ini.tcl]
    source [file join $SRCDIR img.tcl]
    source [file join $SRCDIR msgs.tcl]
    source [file join $SRCDIR main.tcl]
    source [file join $SRCDIR bar.tcl]
    source [file join $SRCDIR file.tcl]
    source [file join $SRCDIR unit.tcl]
    source [file join $SRCDIR tree.tcl]
    source [file join $SRCDIR favor.tcl]
    source [file join $SRCDIR favor_ls.tcl]
    source [file join $SRCDIR find.tcl]
    source [file join $SRCDIR keys.tcl]
    source [file join $SRCDIR info.tcl]
  }
  if {[package versions alited] eq ""} {
    alited::ini::_init     ;# initialize GUI & data
    alited::main::_create  ;# create the main form
    alited::favor::_init   ;# initialize favorites
    alited::main::_run     ;# run the main form
    if {$alited::al(RESTART)} {
      cd $alited::SRCDIR
      exec tclsh $alited::SCRIPT {*}$::argv &
    }
    exit
  }
# _________________________________ EOF _________________________________ #
