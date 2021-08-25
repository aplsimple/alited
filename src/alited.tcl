#! /usr/bin/env tclsh
###########################################################
# Name:    alited.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    03/01/2021
# Brief:   Starting actions, alited's common procedures.
# License: MIT.
###########################################################

package provide alited 1.0.3

package require Tk
catch {package require comm}  ;# Generic message transport

# __________________________ alited NS _________________________ #

namespace eval alited {

  variable tcltk_version "Tcl/Tk [package versions Tk]"

  variable al; array set al [list]
  set al(DEBUG) no        ;# debug mode
  set al(LOG) {}          ;# log file in develop mode
  set al(WIN) .alwin      ;# main form's path

  proc raise_window {} {
    # Raises the app's window.

    variable al
    wm withdraw $al(WIN)
    wm deiconify $al(WIN)
  }

  proc run_remote {cmd args} {
    # Runs a command that was started by another process.

    if {[catch { $cmd {*}$args }]} {
      return -code error
    }
  }

  ## _ End of alited NS _ ##

}

# ________________________ Initialize GUI _________________________ #

# this "if" satisfies the Ruff doc generator "package require":
if {[package versions alited] eq {}} {
  wm withdraw .
  if {$::tcl_platform(platform) eq {windows}} {
    wm attributes . -alpha 0.0
  }
  set ALITED_NOSEND no
  foreach - {1 2 3} {  ;# for inverted order of these arguments
    if {[lindex $::argv 0] eq {NOSEND}} {
      set ::argv [lreplace $::argv 0 0]
      incr ::argc -1
      set ALITED_NOSEND yes
    }
    if {[string match LOG=* [lindex $::argv 0]]} {
      set alited::al(LOG) [string range [lindex $::argv 0] 4 end]
      set ::argv [lreplace $::argv 0 0]
      incr ::argc -1
    }
    if {[lindex $::argv 0] eq {DEBUG}} {
      set alited::al(DEBUG) yes
      set ::argv [lreplace $::argv 0 0]
      incr ::argc -1
    }
  }
  if {$alited::al(DEBUG)} {
    # at developing alited
  } elseif {$::tcl_platform(platform) eq {unix}} {
    if {!$ALITED_NOSEND} {
      set port 48784
      if {[catch {::comm::comm config -port $port}] && \
      ![catch {::comm::comm send $port ::alited::run_remote ::alited::raise_window }]} {
        destroy .
        exit
      }
    }
  } else {
    after idle ::alited::raise_window
  }
}

# ________________________ Main variables _________________________ #

namespace eval alited {

  # main data of alited (others are in ini.tcl)

  variable SCRIPT [file normalize [info script]]
  variable DIR [file normalize [file join [file dirname $SCRIPT] ..]]

  # directories of sources
  variable SRCDIR [file join $DIR src]
  variable LIBDIR [file join $DIR lib]

  # directories of required packages
  variable PAVEDIR [file join $LIBDIR pave]
  variable BARSDIR [file join $LIBDIR bartabs]
  variable HLDIR   [file join $LIBDIR hl_tcl]
  variable BALTDIR [file join $LIBDIR baltip]

  set ::e_menu_dir [file join $LIBDIR e_menu]
  variable MNUDIR [file join $::e_menu_dir menus]

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
  variable obDlg ::alited::aliteddlg  ;# dialog of 1st level
  variable obDl2 ::alited::aliteddl2  ;# dialog of 2nd level
  variable obDl3 ::alited::aliteddl3  ;# dialog of 3rd level
  variable obFND ::alited::alitedFND

  # misc. vars
  variable DirGeometry {}  ;# saved geometry of "Choose Directory" dialogue (for Linux)
  variable FilGeometry {}  ;# saved geometry of "Choose File" dialogue (for Linux)

  # misc. consts
  variable PRJEXT .ale     ;# project file's extension
  variable EOL {@~}        ;# "end of line" for ini-files

  set al(prjname) {}      ;# current project's name
  set al(prjfile) {}      ;# current project's file name
  set al(prjroot) {}      ;# current project's directory name
  set al(prjindent) 2     ;# current project's indentation
  set al(prjmultiline) 0  ;# current project's multiline mode
  set al(prjEOL) {}       ;# current project's end of line
  set al(prjredunit) 20   ;# current project's unit lines per 1 red bar
  set al(prjbeforerun) {} ;# a command to be run before "Tools/Run"

  set al(TITLE) {%f :: %d :: %p - alited}     ;# alited title's template
  set al(TclExtensions) {.tcl .tm .msg}       ;# extensions of Tcl files
  set al(ClangExtensions) {.c .h .cpp .hpp}   ;# extensions of C/C++ files
}

# _____________________________ Packages used __________________________ #

  lappend auto_path $alited::LIBDIR

  source [file join $::alited::BALTDIR baltip.tcl]
  source [file join $::alited::BARSDIR bartabs.tcl]
  source [file join $::alited::PAVEDIR apaveinput.tcl]
  source [file join $::alited::HLDIR  hl_tcl.tcl]
  source [file join $::alited::HLDIR  hl_c.tcl]

# __________________________ Common procs ________________________ #

namespace eval alited {

  proc p+ {p1 p2} {
    # Sums two text positions straightforward: lines & columns separately.
    #   p1 - 1st position
    #   p2 - 2nd position
    # The lines may be with "-".

    lassign [split $p1 .] l11 c11
    lassign [split $p2 .] l21 c21
    foreach n {l11 c11 l21 c21} {
      if {![string is digit -strict [string trimleft [set $n] -]]} {set $n 0}
    }
    return "[incr l11 $l21].[incr c11 $c21]"
  }
  #_______________________

  proc FgFgBold {} {
    # Gets foregrounds of normal and colored text of current color scheme.

    variable obPav
    lassign [$obPav csGet] - fg - - - - - - - fgbold
    return [list $fg $fgbold]
  }

  #_______________________

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
    if {$type eq {ok}} {
      set args [linsert $args 0 $defb]
      set defb {}
    }
    lassign [::apave::extractOptions args -title {} -noesc 0] title noesc
    if {$title eq {}} {
      switch $icon {
        warn {set title $al(MC,warning)}
        err {set title [msgcat::mc Error]}
        ques {set title [msgcat::mc Question]}
        default {set title $al(MC,info)}
     }
    }
    #TODO: if {!$noesc} {set message [string map [list \\ \\\\] $message]}
    set res [$obDlg $type $icon $title "\n$message\n" {*}$defb {*}$args]
    after idle {catch alited::main::UpdateGutter}
    return [lindex $res 0]
  }
  #_______________________

  proc Message {msg {mode 1} {lab ""} {first yes}} {
    # Displays a message in statusbar.
    #   msg - message
    #   mode - 1: simple; 2: bold; 3: bold colored; 4: bold colored bell; 5: static
    #   lab - label's name to display the message in
    #   first - serves to recursively erase the message

    variable al
    variable obPav
    lassign [FgFgBold] fg fgbold
    if {$lab eq ""} {set lab [$obPav Labstat3]}
    set font [[$obPav Labstat2] cget -font]
    set fontB [list {*}$font -weight bold]
    set msg [string range [string map [list \n { } \r {}] $msg] 0 100]
    set slen [string length $msg]
    if {[catch {$lab configure -text $msg}] || !$slen} return
    $lab configure -font $font -foreground $fg
    if {$mode in {2 3 4 5}} {
      $lab configure -font $fontB
      if {$mode in {3 4 5}} {
        $lab configure -foreground $fgbold
        if {$mode eq {4} && $first} bell
      }
    }
    if {$mode eq {5}} {
      update
      return
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
  #_______________________

  proc Message2 {msg {first 1}} {
    # Displays a message in statusbar of secondary dialogue ($obDl2).
    #   msg - message
    #   first - mode of Message
    # See also: Message

    variable obDl2
    Message $msg $first [$obDl2 LabMess]
  }
  #_______________________

  proc HelpAbout {} {
    # Shows "About..." dialogue.

    source [file join $alited::SRCDIR about.tcl]
    about::About
  }
  #_______________________

  proc HelpAlited {} {
    # Shows a main help of alited.

    ::apave::openDoc [file join $alited::DIR doc index.html]
  }
  #_______________________

  proc Help {win {suff ""}} {
    # Reads and shows a help file.
    #   win - currently active window
    #   suff - suffix for a help file's name

    variable DATADIR
    variable al
    variable obDlg
    set fname [lindex [split [dict get [info frame -1] proc] :] end-2]
    set fname [file join [file join $DATADIR help] $fname$suff.txt]
    if {[file exists $fname]} {
      set msg [::apave::readTextFile $fname]
    } else {
      set msg "Here should be a text of\n\"$fname\""
    }
    if {$alited::al(DEBUG)} {
      after idle [list baltip::tip .alwin.diaaliteddlg1.fra.butOK $fname]
    }
    msg ok {} $msg -title Help -text 1 -geometry root=$win -scroll no -noesc 1
  }
  #_______________________

  proc Exit {{w ""} {res 0} {ask yes}} {
    # Closes alited application.
    #   w - not used
    #   res - result of running of main window
    #   ask - if "yes", requests the confirmation of the exit

    variable al
    variable obPav
    if {!$ask || !$al(INI,confirmexit) || \
    [msg yesno ques [msgcat::mc {Quit alited?}]]} {
      if {[alited::file::AllSaved]} {
        $obPav res $al(WIN) $res
        alited::find::_close
        alited::tool::_close
      }
    }
  }

# _______________________ Sources in alited NS _______________________ #

  source [file join $SRCDIR ini.tcl]
  source [file join $SRCDIR img.tcl]
  source [file join $SRCDIR msgs.tcl]
  msgcatMessages
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
  source [file join $SRCDIR complete.tcl]
}

# _________________________ Run the app _________________________ #

# this "if" satisfies the Ruff doc generator "package require":
if {[info exists ALITED_NOSEND]} {
  unset ALITED_NOSEND
  if {$alited::al(LOG) ne {}} {
    ::apave::logName $alited::al(LOG)
    ::apave::logMessage {start alited ------------}
  }
  catch {source ~/PG/github/DEMO/alited/demo.tcl} ;#------------- TO COMMENT OUT
  alited::ini::_init     ;# initialize GUI & data
  alited::main::_create  ;# create the main form
  alited::favor::_init   ;# initialize favorites
  catch {source ~/PG/github/DEMO/alited/demo.tcl} ;#------------- TO COMMENT OUT
  if {[alited::main::_run]} {     ;# run the main form
    # restarting
    cd $alited::SRCDIR
    if {$alited::al(LOG) ne {}} {set ::argv [linsert $::argv 0 LOG=$alited::al(LOG)]}
    if {$alited::al(DEBUG)} {set ::argv [linsert $::argv 0 DEBUG]}
    exec tclsh $alited::SCRIPT NOSEND {*}$::argv &
  }
  exit
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
