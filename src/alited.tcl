#! /usr/bin/env tclsh
###########################################################
# Name:    alited.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    03/01/2021
# Brief:   Starting actions, alited's common procedures.
# License: MIT.
###########################################################

package provide alited 1.0.5.4  ;# for documentation (esp. for Ruff!)

package require Tk
catch {package require comm}  ;# Generic message transport

# __________________________ alited NS _________________________ #

namespace eval alited {

  variable tcltk_version "Tcl/Tk [package versions Tk]"

  set DEBUG no  ;# debug mode
  set LOG {}    ;# log file in develop mode

  variable al; array set al [list]
  set al(WIN) .alwin  ;# main form's path

  proc raise_window {} {
    # Raises the app's window.

    variable al
    catch {
      wm withdraw $al(WIN)
      wm deiconify $al(WIN)
    }
  }

  proc open_files_and_raise {iin args} {
    # Opens files of CLI.
    #   iin - count of call
    #   args - list of file names
    # See also: bar::FillBar

    if {$iin<10} {
      # let the tab bar be filled first
      if {![info exists ::alited::al(BID)]} {
        after idle [list after 1000 [list ::alited::open_files_and_raise [incr iin] {*}$args]]
        return
      }
      foreach fname [lreverse $args] {
        if {[file isfile $fname]} {
          alited::file::OpenFile $fname
        }
      }
    }
    raise_window
  }

  proc run_remote {cmd args} {
    # Runs a command that was started by another process.

    if {[catch { $cmd {*}$args } err]} {
      puts $err
      return -code error
    }
  }

  ## _ EONS _ ##

}

# ________________________ ::argv, ::argc _________________________ #

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
      set alited::LOG [string range [lindex $::argv 0] 4 end]
      set ::argv [lreplace $::argv 0 0]
      incr ::argc -1
    }
    if {[lindex $::argv 0] eq {DEBUG}} {
      set alited::DEBUG yes
      set ::argv [lreplace $::argv 0 0]
      incr ::argc -1
    }
  }
  set ALITED_FNAMES {}
  foreach - $::argv {
    lappend ALITED_FNAMES [file normalize ${-}]
  }

# ____________________ Open an existing app __________________ #

  set comm_port 51837
  set already_running [catch { ::comm::comm config -port $comm_port }]
  if {!$alited::DEBUG && !$ALITED_NOSEND} {
    # Code borrowed from TKE editor.
    # Set the comm port that we will use
    # Change our comm port to a known value
    # (if we fail, the app is already running at that port so connect to it)
    if {$already_running} {
      # Attempt to add files or raise the existing application
      if {[llength $ALITED_FNAMES]} {
        if {![catch {::comm::comm send $comm_port ::alited::run_remote ::alited::open_files_and_raise 0 {*}$ALITED_FNAMES}]} {
          destroy .
          exit
        }
      } else {
        if {![catch { ::comm::comm send $comm_port ::alited::run_remote ::alited::::raise_window }]} {
          destroy .
          exit
        }
      }
    }
  }
  unset comm_port
  unset already_running
}

set ALITED_ONFILES [expr {$::argc>1 || ($::argc==1 && [file isfile [lindex $::argv 0]])}]

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
  if {$::argc && !$ALITED_ONFILES} {set USERDIRROOT [lindex $::argv 0]}

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
  set al(prjindent) 4     ;# current project's indentation
  set al(prjindentAuto) 1 ;# auto detection of indentation
  set al(prjmultiline) 0  ;# current project's multiline mode
  set al(prjEOL) {}       ;# current project's end of line
  set al(prjredunit) 20   ;# current project's unit lines per 1 red bar
  set al(prjbeforerun) {} ;# a command to be run before "Tools/Run"

  set al(TITLE) {%f :: %d :: %p}               ;# alited title's template
  set al(TclExtensionsDef) {.tcl .tm .msg}     ;# extensions of Tcl files
  set al(ClangExtensionsDef) {.c .h .cpp .hpp} ;# extensions of C/C++ files
  set al(TclExtensions) $al(TclExtensionsDef)
  set al(ClangExtensions) $al(ClangExtensionsDef)
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
    # Reasons for this:
    #  1. expr $p1+$p2 doesn't work, e.g. 309.10+1.4=310.5 instead of 310.14
    #  2. do it without a text widget's path (for text's arithmetic)

    lassign [split $p1 .] l11 c11
    lassign [split $p2 .] l21 c21
    foreach n {l11 c11 l21 c21} {
      if {![string is digit -strict [string trimleft [set $n] -]]} {set $n 0}
    }
    return [incr l11 $l21].[incr c11 $c21]
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
    if {$lab eq {}} {set lab [$obPav Labstat3]}
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

  proc Message2 {msg {mode 1}} {
    # Displays a message in statusbar of secondary dialogue ($obDl2).
    #   msg - message
    #   mode - mode of Message
    # See also: Message

    variable obDl2
    Message $msg $mode [$obDl2 LabMess]
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
    if {$alited::DEBUG} {
      puts "help file: $fname"
    }
    msg ok {} $msg -title Help -text 1 -geometry root=$win -scroll no -noesc 1
  }
  #_______________________

  proc Run {args} {
    # Runs Tcl/Tk script.
    #   args - script's name and arguments

    variable al
    if {$al(EM,Tcl) eq {}} {
      set Tclexe [info nameofexecutable]
    } else {
      set Tclexe $al(EM,Tcl)
    }
    exec {*}$Tclexe {*}$args &
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
  source [file join $SRCDIR edit.tcl]
}

# _________________________ Run the app _________________________ #

if {$alited::LOG ne {}} {
  ::apave::logName $alited::LOG
  ::apave::logMessage "START ------------"
}
# this "if" satisfies the Ruff doc generator "package require":
if {[info exists ALITED_NOSEND]} {
  unset ALITED_NOSEND
#  catch {source ~/PG/github/DEMO/alited/demo.tcl} ;#------------- TO COMMENT OUT
  if {$ALITED_ONFILES} {
    set ::argc 0
    set ::argv {}
    after 10 [list ::alited::open_files_and_raise 0 {*}$ALITED_FNAMES]
  }
  set alited::ARGV $::argv
  unset ALITED_FNAMES
  unset ALITED_ONFILES
  alited::ini::_init     ;# initialize GUI & data
  alited::main::_create  ;# create the main form
  alited::favor::_init   ;# initialize favorites
#  catch {source ~/PG/github/DEMO/alited/demo.tcl} ;#------------- TO COMMENT OUT
  if {[alited::main::_run]} {     ;# run the main form
    # restarting
    if {$alited::LOG ne {}} {
      set alited::ARGV [linsert $alited::ARGV 0 LOG=$alited::LOG]
    }
    if {$alited::DEBUG} {
      set alited::ARGV [linsert $alited::ARGV 0 DEBUG]
    }
    if {$alited::LOG ne {}} {
      ::apave::logMessage "QUIT ------------ $alited::SCRIPT NOSEND $alited::ARGV"
    }
    alited::Run $alited::SCRIPT NOSEND {*}$alited::ARGV
    catch {wm attributes . -alpha 0.0}
    catch {wm withdraw $alited::al(WIN)}
  } elseif {$alited::LOG ne {}} {
    ::apave::logMessage {QUIT ------------}
  }
  exit
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
