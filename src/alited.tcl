#! /usr/bin/env tclsh
###########################################################
# Name:    alited.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    03/01/2021
# Brief:   Starting actions, alited's common procedures.
# License: MIT.
###########################################################

package provide alited 1.2.4a3  ;# for documentation (esp. for Ruff!)

set _ [package require Tk]
if {![package vsatisfies $_ 8.6.10-]} {
  wm withdraw .
  tk_messageBox -message "\nalited needs Tcl/Tk v8.6.10+ \
    \n\nwhile the current is v$_\n"
  exit
}
catch {package require comm}  ;# Generic message transport

# _____ Remove installed (perhaps) packages used in alited _____ #

foreach _ {apave baltip bartabs hl_tcl} {
  set __ [package version $_]
  catch {
    package forget $_
    namespace delete ::$_
    puts "alited: clearing $_ $__"
  }
  unset __
}

# __________________________ alited NS _________________________ #

namespace eval alited {

  variable tcltk_version "Tcl/Tk [package versions Tk]"

  ## ________________________ Main variables _________________________ ##

  set DEBUG no  ;# debug mode
  set LOG {}    ;# log file in develop mode

  variable al; array set al [list]
  set al(WIN) .alwin    ;# main form's path
  set al(comm_port) 51807  ;# port to listen
  set al(comm_port_list) [list {} $al(comm_port) 51817 51827 51837] ;# ports to listen
  set al(ini_file) {}  ;# alited.ini contents

  # main data of alited (others are in ini.tcl)

  variable SCRIPT [info script]
  variable SCRIPTNORMAL [file normalize $SCRIPT]
  variable FILEDIR [file dirname [file normalize [info script]]]
  variable DIR [file dirname $FILEDIR]

  # directories of sources
  variable SRCDIR [file join $DIR src]
  variable LIBDIR [file join $DIR lib]

  # directories of required packages
  variable BARSDIR [file join $LIBDIR bartabs]
  variable HLDIR   [file join $LIBDIR hl_tcl]

  set ::e_menu_dir [file join $LIBDIR e_menu]
  variable MNUDIR [file join $::e_menu_dir menus]

  # apave & baltip packages are located in e_menu's subdirectory
  variable PAVEDIR [file join $::e_menu_dir src]
  variable BALTDIR [file join $PAVEDIR baltip]

  # directories of key data
  variable DATADIR [file join $DIR data]
  variable IMGDIR  [file join $DATADIR img]
  variable MSGSDIR [file join $DATADIR msgs]

  # directories of user's data
  variable USERDIRSTD [file normalize {~/.config}]
  variable USERDIRROOT $USERDIRSTD

  # two main objects to build forms (just some unique names)
  variable obPav ::alited::alitedpav
  variable obDlg ::alited::aliteddlg  ;# dialog of 1st level
  variable obDl2 ::alited::aliteddl2  ;# dialog of 2nd level
  variable obDl3 ::alited::aliteddl3  ;# dialog of 3rd level
  variable obCHK ::alited::alitedCHK  ;# dialog of "Check Tcl"
  variable obFND ::alited::alitedFND  ;# dialog of "Find/Replace"
  variable obFN2 ::alited::alitedFN2  ;# dialog of "Find by list"

  # misc. vars
  variable DirGeometry {}  ;# saved geometry of "Choose Directory" dialogue (for Linux)
  variable FilGeometry {}  ;# saved geometry of "Choose File" dialogue (for Linux)

  # misc. consts
  variable PRJEXT .ale     ;# project file's extension
  variable EOL {@~}        ;# "end of line" for ini-files

  # project options' names
  variable OPTS [list \
    prjname prjroot prjdirign prjEOL prjindent prjindentAuto prjredunit prjmultiline prjbeforerun prjtrailwhite]

  # project options' values
  set al(prjname) {}      ;# current project's name
  set al(prjfile) {}      ;# current project's file name
  set al(prjroot) {}      ;# current project's directory name
  set al(prjindent) 4     ;# current project's indentation
  set al(prjindentAuto) 1 ;# auto detection of indentation
  set al(prjmultiline) 0  ;# current project's multiline mode
  set al(prjEOL) {}       ;# current project's end of line
  set al(prjredunit) 20   ;# current project's unit lines per 1 red bar
  set al(minredunit) 4    ;# minimum project's unit lines per 1 red bar
  set al(prjbeforerun) {} ;# a command to be run before "Tools/Run"
  set al(prjtrailwhite) 0 ;# "remove trailing whitespaces" flag
  set al(prjdirign) {.git .bak} ;# ignored subdirectories of project
  foreach _ $OPTS {set al(DEFAULT,$_) $al($_)}

  set al(TITLE) {%f :: %d :: %p}               ;# alited title's template
  set al(TclExtensionsDef) {.tcl .tm .msg}     ;# extensions of Tcl files
  set al(ClangExtensionsDef) {.c .h .cpp .hpp} ;# extensions of C/C++ files
  set al(TextExtensionsDef) {html htm css md txt sh bat ini} ;# extensions of plain texts
  set al(TclExtensions) $al(TclExtensionsDef)
  set al(ClangExtensions) $al(ClangExtensionsDef)
  set al(TextExtensions) $al(TextExtensionsDef)


  ## __________________ Procs to raise the alited app ___________________ ##

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
          file::OpenFile $fname yes
        } else {
          set msg [msgcat::mc "File \"%f\" doesn't exist."]
          Message [string map [list %f $fname] $msg] 4
          file::NewFile $fname
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

# The following "if" counts on the Ruff! doc generator:
#   - Ruff! uses "package require" for a documented package ("alited", e.g.)
#   - alited should not be run when Ruff! sources it
#   - so, without 'package require alited', it's a regular run of alited

if {[package versions alited] eq {}} {
  wm withdraw .
  if {$::tcl_platform(platform) eq {windows}} {
    wm attributes . -alpha 0.0
  }
  set ALITED_PORT yes
  foreach _ {1 2 3} {  ;# for inverted order of these arguments
    if {[lindex $::argv 0] eq {-NOPORT}} {
      set ::argv [lreplace $::argv 0 0]
      incr ::argc -1
      set ALITED_PORT no
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
  set ALITED_ARGV [list]
  foreach _ $::argv {lappend ALITED_ARGV [file normalize $_]}

  ## ____________________ Get a port to listen __________________ ##

  set _ [lindex $ALITED_ARGV 0]
  if {![llength $ALITED_ARGV] || ![file isdirectory $_]} {
    set _ $alited::USERDIRROOT
  } else {
    set alited::USERDIRROOT $_
    set ALITED_ARGV [lrange $ALITED_ARGV 1 end]
  }
  # try to read alited.ini
  set _ [file join $_ alited ini alited.ini]
  if {![catch {set _ [open $_]}]} {
    set alited::al(ini_file) [split [read $_] \n]
    close $_
    set _ [lindex $alited::al(ini_file) 1]
    if {[string match comm_port=* $_]} {
      set alited::al(comm_port) [string range $_ 10 end]
    } else {
      set alited::al(comm_port) 51837 ;# to be compatible with old style
    }
  }
  unset _

  ## ____________________ Open an existing app __________________ ##

  if {[string is integer -strict $alited::al(comm_port)]} {
    # Code borrowed from TKE editor.
    # Set the comm port that we will use
    # Change our comm port to a known value
    # (if we fail, the app is already running at that port so connect to it)
    if {![catch { ::comm::comm config -port $alited::al(comm_port) }]} {
      set ALITED_PORT no ;# no running app
    }
  } else {
    set ALITED_PORT no
  }
  if {!$alited::DEBUG && $ALITED_PORT} {
    if {[llength $ALITED_ARGV]} {
      # Attempt to add files & raise the existing application
      if {![catch {::comm::comm send $alited::al(comm_port) ::alited::run_remote ::alited::open_files_and_raise 0 $ALITED_ARGV}]} {
        destroy .
        exit
      }
    } else {
      # Attempt to raise the existing application
      if {![catch { ::comm::comm send $alited::al(comm_port) ::alited::run_remote ::alited::::raise_window }]} {
        destroy .
        exit
      }
    }
  }
}

# _____________________________ Packages used __________________________ #

lappend auto_path $alited::LIBDIR $::alited::PAVEDIR

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
    # Gets foregrounds of normal and colored text of current color scheme
    # and red color of TODOs.

    variable obPav
    lassign [$obPav csGet] - fg - - fgbold
    lassign [::hl_tcl::addingColors] -> fgred
    return [list $fg $fgbold $fgred]
  }
  #_______________________

  proc ListPaved {} {
    # Return a list of apave objects for dialogues.

    return [list obDlg obDl2 obDl3 obFND obFN2 obCHK]
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
    } else {
      set title [msgcat::mc $title]
    }
    set message [msgcat::mc $message]
    #! if {!$noesc} {set message [string map [list \\ \\\\] $message]}
    set res [$obDlg $type $icon $title "\n$message\n" {*}$defb {*}$args]
    #! after idle {catch alited::main::UpdateGutter}
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
    if {[catch {lassign [FgFgBold] fg fgbold fgred}]} {
      return  ;# at exiting app
    }
    if {$lab eq {}} {set lab [$obPav Labstat3]}
    set font [[$obPav Labstat2] cget -font]
    set fontB [list {*}$font -weight bold]
    set msg [string range [string map [list \n { } \r {}] $msg] 0 100]
    set slen [string length $msg]
    if {[catch {$lab configure -text $msg}] || !$slen} return
    $lab configure -font $font -foreground $fg
    if {$mode in {2 3 4 5}} {
      $lab configure -font $fontB
      if {$mode eq {4}} {
        $lab configure -foreground $fgred
        if {$first} bell
      } elseif {$mode in {3 5}} {
        $lab configure -foreground $fgbold
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

  proc Message3 {msg {mode 1}} {
    # Displays a message in statusbar of tertiary dialogue ($obDl3).
    #   msg - message
    #   mode - mode of Message
    # See also: Message

    variable obDl3
    Message $msg $mode [$obDl3 LabMess]
  }
  #_______________________

  proc HelpAbout {} {
    # Shows "About..." dialogue.

    if {[info commands about::About] eq {}} {
      source [file join $alited::SRCDIR about.tcl]
    }
    about::About
  }
  #_______________________

  proc HelpAlited {} {
    # Shows a main help of alited.

    ::apave::openDoc [file join $alited::DIR doc index.html]
  }
  #_______________________

  proc HelpFile {win fname args} {
    # Reads and shows a help file.
    #   win - currently active window
    #   fname - the file's name
    #   args - option of msg

    set fS [lindex [FgFgBold] 1]
    set ::alited::textTags [list \
      [list "red" " -font {-weight bold} -foreground $fS"] \
      [list "bold" " -font {-weight bold}"] \
      [list "link" "::apave::openDoc %t@@https://%l@@"] \
      ]
    if {[file exists $fname]} {
      set msg [::apave::readTextFile $fname]
    } else {
      set msg "Here should be a text of\n\"$fname\""
    }
    if {$alited::DEBUG} {puts "help file: $fname"}
    set wmax 1
    foreach ln [split $msg \n] {
      set occ 0
      foreach tag {red bold link} {
        foreach yn {{} /} {
          set ln2 $ln
          set t <$yn$tag>
          set ln [string map [list $t {}] $ln]
          incr occ [expr {([string length $ln2]-[string length $ln])/[string length $t]}]
        }
      }
      set wmax [expr {max($wmax,[string length $ln]+$occ)}]
    }
    return [msg ok {} $msg -title Help -text 1 -geometry root=$win -scroll no \
      -tags ::alited::textTags -w [incr wmax] -modal no -ontop yes {*}$args]
  }
  #_______________________

  proc HelpFname {win {suff ""}} {
    # Gets a help file's name.
    #   win - currently active window
    #   suff - suffix for a help file's name

    variable DATADIR
    set fname [lindex [split [dict get [info frame -2] proc] :] end-2]
    set fname [file join [file join $DATADIR help] $fname$suff.txt]
    return $fname
  }
  #_______________________

  proc HelpMe {win {suff ""}} {
    # Shows a help file for a procedure with "Don't show again" checkbox.
    #   win - currently active window
    #   suff - suffix for a help file's name

    variable al
    if {[lsearch -exact $al(HelpedMe) $win]>-1} return
    set ans [HelpFile $win [HelpFname $win $suff] -ch $al(MC,noask)]
    if {$ans==11} {
      lappend al(HelpedMe) $win
    }
  }
  #_______________________

  proc Help {win {suff ""}} {
    # Shows a help file for a procedure.
    #   win - currently active window
    #   suff - suffix for a help file's name

    HelpFile $win [HelpFname $win $suff]
  }
  #_______________________

  proc CloseDlg {} {
    # Tries to close a Help dialogue, open non-modal aside by the current dialogue.

    variable obDlg
    catch {[$obDlg ButOK] invoke}
  }
  #_______________________

  proc CheckRun {} {
    # Runs "Check Tcl".

    variable SRCDIR
    if {[info commands check::_run] eq {}} {
      source [file join $SRCDIR check.tcl]
    }
    check::_run
  }
  #_______________________

  proc Tclexe {} {
    # Gets Tcl's executable file.

    variable al
    if {$al(EM,Tcl) eq {}} {
      set tclexe [info nameofexecutable]
    } else {
      set tclexe $al(EM,Tcl)
    }
    return $tclexe
  }
  #_______________________

  proc Run {args} {
    # Runs Tcl/Tk script.
    #   args - script's name and arguments

    set com [string trimright "$args" &]
    set pid [pid [open "|[Tclexe] $com"]]
    return $pid
  }
  #_______________________

  proc Exit {{w ""} {res 0} {ask yes}} {
    # Closes alited application.
    #   w - not used
    #   res - result of running of main window
    #   ask - if "yes", requests the confirmation of the exit

    variable al
    variable obPav
    variable obFN2
    if {!$ask || !$al(INI,confirmexit) || \
    [msg yesno ques [msgcat::mc {Quit alited?}]]} {
      if {[alited::file::AllSaved]} {
        alited::find::_close
        alited::tool::_close
        catch {alited::check::Cancel}
        catch {$obFN2 res $::alited::al(FN2WINDOW) 0}
        $obPav res $al(WIN) $res
      }
    }
  }

  ## _______________________ Sources in alited NS _______________________ ##

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
  source [file join $SRCDIR complete.tcl]
  source [file join $SRCDIR edit.tcl]
}

# _________________________ Run the app _________________________ #

if {$alited::LOG ne {}} {
  ::apave::logName $alited::LOG
  ::apave::logMessage "START ------------"
}

# The following "if" counts on the Ruff! doc generator:
#   - Ruff! uses "package require" for a documented package ("alited", e.g.)
#   - alited should not be run when Ruff! sources it
#   - so, without 'package require alited', it's a regular run of alited

if {[info exists ALITED_PORT]} {
  unset ALITED_PORT
#  catch {source ~/PG/github/DEMO/alited/demo.tcl} ;#------------- TO COMMENT OUT
  if {[llength $ALITED_ARGV]} {
    set ::argc 0
    set ::argv {}
    after 10 [list ::alited::open_files_and_raise 0 {*}$ALITED_ARGV]
  }
  set alited::ARGV $::argv
  unset ALITED_ARGV
  if {[catch {alited::ini::_init} _]} {
    # initialize GUI & data:
    # let a possible error of ini-file be shown, with attempt to continue
    alited::ini::GetUserDirs
    tk_messageBox -icon error -message \
      "Error of reading of alited's settings: \
      \n$_\n\nProbable reason in the file:\n$::alited::al(INI) \
      \n\nTry to rename / move it.\nThen restart alited."
  }
  unset -nocomplain _
  alited::main::_create  ;# create the main form
  alited::favor::_init   ;# initialize favorites
  alited::tool::AfterStart
#  catch {source ~/PG/github/DEMO/alited/demo.tcl} ;#------------- TO COMMENT OUT
  if {[alited::main::_run]} {     ;# run the main form
    # restarting
    update
    if {$alited::LOG ne {}} {
      set alited::ARGV [linsert $alited::ARGV 0 LOG=$alited::LOG]
    }
    if {$alited::DEBUG} {
      set alited::ARGV [linsert $alited::ARGV 0 DEBUG]
    }
    if {[file tail [file dirname $alited::DIR]] eq {alited.kit}} {
      set alited::DIR [file dirname [file dirname $alited::DIR]]
    } else {
      set alited::SCRIPT $alited::SCRIPTNORMAL
    }
    if {$alited::LOG ne {}} {
      ::apave::logMessage "QUIT :: $alited::DIR :: $alited::SCRIPT PORT $alited::ARGV"
    }
    catch {wm attributes . -alpha 0.0}
    catch {wm withdraw $alited::al(WIN)}
    cd $alited::DIR
    exec -- [info nameofexecutable] $alited::SCRIPT -NOPORT {*}$alited::ARGV &
  } elseif {$alited::LOG ne {}} {
    ::apave::logMessage {QUIT ------------}
  }
  exit
} else {
  # these scripts are sourced to include them in Ruff!'s generated docs
  namespace eval alited {
    source [file join $alited::SRCDIR about.tcl]
    source [file join $alited::SRCDIR check.tcl]
    source [file join $alited::SRCDIR indent.tcl]
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
#~EXEC1: /home/apl/PG/github/freewrap/TEST-kit/tclkit-gui-8.6.11 /home/apl/PG/github/alited/src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
