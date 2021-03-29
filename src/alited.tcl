#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The starting script of alited.
# Contains a batch of alited's common procedures.
# _______________________________________________________________________ #

package provide alited 0.1.1.5

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
  variable INIDIR  [file join $USERDIR ini]
  variable PRJDIR  [file join $USERDIR prj]
  variable TESTDIR [file join $DIR .bak]
  if {![file exists $USERDIR]} {
    file mkdir $INIDIR
    file mkdir $PRJDIR
  }

  # two main objects to build forms (just some unique names)
  variable obPav ::alited::alitedpav
  variable obDlg ::alited::aliteddlg

  # load localized messages
  msgcat::mcload $MSGSDIR

  # main data of alited
  variable al; array set al [list]
  set al(WIN) .alwin
  set al(PRJEXT) "alited"
  set al(prjname) "myproject.$al(PRJEXT)"
  set al(prjfile) [file join $PRJDIR $al(prjname)]
  set al(prjroot) [file normalize .]
  set al(TITLE) "%f :: %d :: %p - alited"
  set al(ED,multiline) no
  set al(TREE,isunits) yes
  set al(TREE,units) no
  set al(TREE,files) no
  set al(TREE,cw0) 200
  set al(TREE,cw1) 70
  set al(FSIZE,small) 9
  set al(INI,save_onselect) no
  set al(INI,save_onadd) no
  set al(INI,save_onmove) no
  set al(INI,save_onclose) no
  set al(INI,save_onsave) yes
  set al(RE,branch) {^\s*(#+) [_]+([^_]+)[_]+ (#+)}          ;#  # _ lev 1 _ #
  set al(RE,leaf) {^\s*# [_]+([^_]*)$}                       ;#  # _  / # _ abc
  set al(RE,abc) {^\s*(proc|method)\s+([[:alnum:]_:]+)\s.+}  ;# proc abc {}...
  set al(RESTART) no
}

# _______________________________________________________________________ #

package require bartabs
package require apave
package require hl_tcl
package require baltip

# _______________________________________________________________________ #

namespace eval alited {

  proc msg {type icon message args} {
    # Shows a message and asks for an answer.
    #   type - ok/yesno/okcancel/yesnocancel
    #   icon - info/warn/err
    #   message - the message
    #   args - additional arguments (-title and font's option)

    variable obDlg
    lassign [::apave::extractOptions args -title ""] title
    if {$title eq ""} {set title [string toupper $icon]}
    $obDlg $type $icon $title "\n$message\n" {*}$args
  }

  proc HelpAbout {} {
    source [file join $alited::SRCDIR about.tcl]
    about::About
  }

  proc Exit {{w ""}} {
    variable al
    variable obPav
    if {[alited::file::AllSaved]} {$obPav res $al(WIN) 0}
  }

}

# _______________________________________________________________________ #

  # load all sources into alited namespace
  namespace eval alited {
    source [file join $SRCDIR msgs.tcl]
    source [file join $SRCDIR ini.tcl]
    source [file join $SRCDIR main.tcl]
    source [file join $SRCDIR bar.tcl]
    source [file join $SRCDIR file.tcl]
    source [file join $SRCDIR unit.tcl]
    source [file join $SRCDIR tree.tcl]
  }
  if {[package versions alited] eq ""} {
    # initialize GUI & data
    alited::ini::_init
    # create & run the main form
    alited::main::_create
    alited::main::_run
    if {$alited::al(RESTART)} {
      cd $alited::SRCDIR
      exec tclsh $alited::SCRIPT {*}$::argv &
    }
    exit
  }
# _________________________________ EOF _________________________________ #
