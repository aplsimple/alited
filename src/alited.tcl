#! /usr/bin/env tclsh
###########################################################
# Name:    alited.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    03/01/2021
# Brief:   Starting actions, alited's common procedures.
# License: MIT.
###########################################################

package provide alited 1.3.6b2  ;# for documentation (esp. for Ruff!)

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

# __________________________ alited:: Main _________________________ #

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
  variable DATAUSER [file join $DATADIR user]
  variable DATAUSERINI [file join $DATAUSER ini]
  variable DATAUSERINIFILE [file join $DATAUSERINI alited.ini]

  # directories of user's data
  variable CONFIGDIRSTD [file normalize {~/.config}]
  variable USERLASTINI [file join $CONFIGDIRSTD alited last.ini]

  # configurations
  variable CONFIGDIR $CONFIGDIRSTD
  variable CONFIGS [list]

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
  variable pID 0

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
          Balloon1 $fname
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

  proc main_user_dirs {} {
    # Gets names of main user directories for settings.

    set ::alited::USERDIR [file join $::alited::CONFIGDIR alited]
    set ::alited::INIDIR [file join $::alited::USERDIR ini]
    set ::alited::PRJDIR [file join $::alited::USERDIR prj]
  }

  ## _ EONS: Main _ ##
}

# _____________________________ Packages used __________________________ #

lappend auto_path $alited::LIBDIR $::alited::PAVEDIR

source [file join $::alited::BARSDIR bartabs.tcl]
source [file join $::alited::PAVEDIR apaveinput.tcl]
source [file join $::alited::HLDIR  hl_tcl.tcl]
source [file join $::alited::HLDIR  hl_c.tcl]

# ________________________ ::argv, ::argc _________________________ #

set ::alited::ARGV $::argv
set ::alited::al(IsWindows) [expr {$::tcl_platform(platform) eq {windows}}]

# The following "if" counts on the Ruff! doc generator:
#   - Ruff! uses "package require" for a documented package ("alited", e.g.)
#   - alited should not be run when Ruff! sources it
#   - so, without 'package require alited', it's a regular run of alited

if {[package versions alited] eq {}} {
  wm withdraw .
  if {$::alited::al(IsWindows)} {
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
  if {[file isdirectory $::argv]} {
    # if alited run with "config dir containing spaces"
    set ::argv [list $::argv]
  } elseif {[file isdirectory [set _ [lrange $::argv 0 end-1]]]} {
    # if alited run with "config dir containing spaces" + "filename"
    set ::argv [list $_ [lindex $::argv end]]
  }

  ## ____________________ Last configuration __________________ ##

  set readalitedCONFIGS no
  set isalitedCONFIGS [file exists $alited::USERLASTINI]
  set _ [lindex $::argv 0]
  if {![llength $::argv] || ![file isdirectory $_]} {
    alited::main_user_dirs
    if {(![file exists $alited::INIDIR] || ![file exists $alited::PRJDIR]) && \
    $isalitedCONFIGS} {
      # read INIDIR & PRJDIR that were last entered
      lassign [split [::apave::readTextFile $alited::USERLASTINI] \n] \
        alited::INIDIR alited::PRJDIR alited::CONFIGS
      set alited::CONFIGDIR [file dirname [file dirname $alited::INIDIR]]
      set readalitedCONFIGS yes
    }
  } else {
    set alited::CONFIGDIR $_
    set ::argv [lrange $::argv 1 end]
  }
  if {[string index $::argv 0] eq {'} && [string index $::argv end] eq {'}} {
    # when run from menu.mnu "Edit/create file"
    set ::argv [list [string range $::argv 1 end-1]]
  } elseif {[file isfile $::argv]} {
    set ::argv [list $::argv]
  }
  set ALITED_ARGV [list]
  foreach _ $::argv {lappend ALITED_ARGV [file normalize $_]}
  if {[llength $ALITED_ARGV]==1 && [llength [split $ALITED_ARGV]]>1} {
    set ALITED_ARGV [list $ALITED_ARGV]  ;# file name contains spaces
  }
  if {!$readalitedCONFIGS && $isalitedCONFIGS} {
    # read configurations used
    set alited::CONFIGS [lindex [split [::apave::readTextFile $alited::USERLASTINI] \n] 2]
  }
  unset readalitedCONFIGS
  unset isalitedCONFIGS

  ## ____________________ Port to listen __________________ ##

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
    if {$::alited::al(IsWindows) && \
    ![catch { ::comm::comm config -port $alited::al(comm_port) }]} {
      set ALITED_PORT no ;# no running app
    }
  } else {
    set ALITED_PORT no
  }
  if {!$alited::DEBUG && $ALITED_PORT} {
    if {$::alited::al(IsWindows)} {
      if {[llength $ALITED_ARGV]} {
        # Attempt to add files & raise the existing application
        if {![catch {::comm::comm send $alited::al(comm_port) ::alited::run_remote ::alited::open_files_and_raise 0 $ALITED_ARGV}]} {
          destroy .
          exit
        }
      } else {
        # Attempt to raise the existing application
        if {![catch { ::comm::comm send $alited::al(comm_port) ::alited::run_remote ::alited::raise_window }]} {
          destroy .
          exit
        }
      }
    } else {
      if {[tk appname alited] ne "alited"} {
        send -async alited ::alited::open_files_and_raise 0 {*}$ALITED_ARGV
        destroy .
        exit
      }
    }
  }

}

# __________________________ alited:: Common ________________________ #

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

  proc IsRoundInt {i1 i2} {
    # Checks whether an integer equals roundly to other integer.
    #   i1 - integer to compare
    #   i2 - integer to be compared (rounded) to i1

    return [expr {$i1>($i2-3) && $i1<($i2+3)}]
  }
  #_______________________

  proc NormalizeName {name} {
    # Removes spec.characters from a name (sort of normalizing it).
    #   name - the name

    return [string map [list \\ {} \{ {} \} {} \[ {} \] {} \t {} \n {} \r {} \" {}] $name]
  }
  #_______________________

  proc NormalizeFileName {name} {
    # Removes spec.characters from a file/dir name (sort of normalizing it).
    #   name - the name of file/dir

    return [string map [list \
      * _ ? _ ~ _ / _ \\ _ \{ _ \} _ \[ _ \] _ \t _ \n _ \r _ \
      | _ < _ > _ & _ , _ : _ \; _ \" _ ' _ ` _] $name]
  }
  #_______________________

  proc FgFgBold {} {
    # Gets foregrounds of normal and colored text of current color scheme
    # and red color of TODOs.

    variable obPav
    lassign [$obPav csGet] - fg - bg fgbold
    lassign [::hl_tcl::addingColors] -> fgred
    return [list $fg $fgbold $fgred $bg]
  }
  #_______________________

  proc ListPaved {} {
    # Return a list of apave objects for dialogues.

    return [list obDlg obDl2 obDl3 obFND obFN2 obCHK]
  }
  #_______________________

  proc CursorAtEnd {w} {
    # Sets the cursor at the end of a field.
    #   w - the field's path

    focus $w
    $w selection clear
    $w icursor end
  }
  #_______________________

  proc SyntaxHighlight {lng wtxt colors {cs ""} args} {
    # Makes a text being syntax highlighted.
    #   lng - language (tcl, c)
    #   wtxt - text's path
    #   colors - highlighting colors
    #   cs - color scheme
    #   args - other options

    variable al
    if {$cs eq {}} {set cs [::apave::obj csCurrent]}
    ::hl_${lng}::hl_init $wtxt -dark [::apave::obj csDark $cs] -colors $colors \
      -multiline 1 -font $al(FONT,txt) -insertwidth $al(CURSORWIDTH) {*}$args
    ::hl_${lng}::hl_text $wtxt
  }
  #_______________________

  proc TextIcon {ico {to out}} {
    # Gets a picture from a character and vice versa.
    #   ico - picture or character
    #   to - "in" gets in-chars, "out" gets out-chars

# TODO: codes instead of pictures - not available in 8.6.10
#!    \U0001f4a5 = 💥
#!    \U0001f4bb = 💻
#!    \U0001f3d7 = 🏗
#!    \U0001f4f6 = 📶
#!    \U0001f4e1 = 📡
#!    \U0001f4d6 = 📖
#!    \U0001f300 = 🌀
#!    \U0001f4de = 📞
#!    \U0001f4d0 = 📐
#!    \U0001f426 = 🐦
#!    \U0001f381 = 🎁
#!    \U0001f3c1 = 🏁
#!    \U0001f511 = 🔑
#!    \U0001f4be = 💾

    set in {0 1 2 3 4 5 6 7 8 9 & ~ = @}
    set out {💥 💻 🏗 📶 📡 📖 🌀 📞 📐 🐦 🎁 🏁 🔑 💾}
    if {$to eq {out}} {
      set lfrom $in
      set lto $out
    } else {
      set lfrom $out
      set lto $in
    }
    if {[set i [lsearch -exact $lfrom $ico]]>-1} {
      set tico [lindex $lto $i]
    } else {
      set tico $ico
    }
    return $tico
  }

  ## ________________________ Messages _________________________ ##

  proc TipMessage {lab tip} {
    # Shows a tip on status message and clears the status message.
    #   lab - message label's path
    #   tip - text of tip

    if {$tip ne {}} {$lab configure -text {}}
    return $tip
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
    } elseif {$defb eq {}} {
      set defb YES
    }
    lappend defb -centerme [::apave::rootModalWindow $al(WIN)]
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
    if {[info exists al(obDlg-BUSY)]} {
      # the obDlg is engaged: no actions, just a message
      Message $message 4
      set res 0
    } else {
      set al(obDlg-BUSY) yes
      set res [$obDlg $type $icon $title "\n$message\n" {*}$defb {*}$args]
      unset -nocomplain al(obDlg-BUSY)
    }
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
    if {[catch {lassign [FgFgBold] fg fgbold fgred bg}]} {
      return  ;# at exiting app
    }
    if {$lab eq {}} {set lab [$obPav Labstat3]}
    if {!$first && $msg ne {} && [winfo exists $lab]} {
      set curmsg [$lab cget -text]
      # if a message changed or expired, don't touch it (don't cover it with old 'msg')
      if {[string first $msg $curmsg]<0} return
    }
    set font [[$obPav Labstat2] cget -font]
    set fontB [list {*}$font -weight bold]
    set msg [string range [string map [list \n { } \r {}] $msg] 0 500]
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
      if {$mode in {2 3 4 5}} {
        set opts "-font {$fontB}"
      } else {
        set opts {}
      }
      set tip [string trim [string range $msg 0 130]]
      if {[string trim [string range $msg [string length $tip] end]] ne {}} {
        append tip ...
      }
      baltip::tip $lab $tip -command [list alited::TipMessage %w %t] -per10 0 {*}$opts
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

  proc Balloon {msg {red no} {timo 100}} {
    # Displays a message in a balloon window.
    #   msg - message
    #   red - yes for red background
    #   timo - millisec. before showing the message

    variable al
    variable obPav
    if {$red} {
      set fg white
      set bg #bf0909
    } else {
      set cs [$obPav csGet]
      set fg [lindex $cs 14]  ;# colors of baltip's tips
      set bg [lindex $cs 15]
    }
    lassign [split [winfo geometry $al(WIN)] x+] w h x y
    set geo "+([expr {$w+$x}]-W-8)+$y-20"
    set msg [string map [list \n "  \n  "] $msg]
    ::baltip clear $al(WIN)
    after $timo [list ::baltip tip $al(WIN) $msg -fg $fg -bg $bg -alpha 0.9 \
        -font {-weight bold -size 11} -pause 1000 -fade 1000 \
        -geometry $geo -bell $red -on yes -relief groove]
  }
  #_______________________

  proc Balloon1 {fname} {
    # Shows a balloon about non-existing file.
    #   fname - file's name

    variable al
    Balloon [string map [list %f $fname] $al(MC,filenoexist)]
  }

  ## ________________________ Helps _________________________ ##

  proc HelpAbout {} {
    # Shows "About..." dialogue.

    if {[info commands about::About] eq {}} {
      source [file join $alited::SRCDIR about.tcl]
    }
    about::About
  }
  #_______________________

  proc HelpAlited {{ilink ""}} {
    # Shows a main help of alited.
    #   ilink - internal link

    ::apave::openDoc file://[file join $alited::DIR doc index.html]$ilink
  }
  #_______________________

  proc HelpFile {win fname args} {
    # Reads and shows a help file.
    #   win - currently active window
    #   fname - the file's name
    #   args - option of msg

    variable obDlg
    set fS [lindex [::hl_tcl::hl_colors {} [::apave::obj csDark]] 1]
    set ::alited::textTags [list \
      [list "r" "-font {-weight bold} -foreground $fS"] \
      [list "b" "-foreground $fS"] \
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
    set pobj $obDlg
    if {[info commands $pobj] eq {}} {
      # at first start, there are no apave objects bound to the main window of alited
      # -> create an independent one to be deleted afterwards
      set pobj alitedHelpObjToDel
      ::apave::APaveInput create $pobj
    }
    set res [$pobj ok {} Help "\n$msg\n" -text 1 -centerme $win -scroll no \
      -tags ::alited::textTags -w [incr wmax] -modal no -ontop yes {*}$args]
    catch {alitedHelpObjToDel destroy}
    return $res
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
    if {[lindex $ans 0]==11} {
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

  ## ________________________ Runs & exits _________________________ ##

  proc source_e_menu {} {
    # Sources e_menu.tcl at need.

    if {![info exists ::em::geometry]} {
      source [file join $::e_menu_dir e_menu.tcl]
    }
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
    return [pid [open "|\"[Tclexe]\" $com"]]
  }
  #_______________________

  proc CloseDlg {} {
    # Tries to close a Help dialogue, open non-modal aside by the current dialogue.

    variable obDlg
    catch {[$obDlg ButOK] invoke}
  }
  #_______________________

  proc CheckSource {} {
    # Sources check.tcl (at need).

    variable SRCDIR
    if {[info commands ::alited::check::_run] eq {}} {
      source [file join $SRCDIR check.tcl]
    }
  }
  #_______________________

  proc CheckRun {} {
    # Runs "Check Tcl".

    CheckSource
    check::_run
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
    if {$al(INI,confirmexit)>1} {
      set timo "-timeout {$al(INI,confirmexit) ButOK}"
    } else {
      set timo {}
    }
    if {!$ask || !$al(INI,confirmexit) || \
    [msg okcancel info [msgcat::mc {Quitting alited.}] OK {*}$timo]} {
      if {[alited::file::AllSaved]} {
        alited::find::_close
        alited::tool::_close
        catch {alited::check::Cancel}
        catch {$obFN2 res $::alited::al(FN2WINDOW) 0}
        $obPav res $al(WIN) $res
      }
    }
  }

  ## _______________________ Sources in alited:: _______________________ ##

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

  ## _ EONS: Common _ ##

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
#  catch #\{source ~/PG/github/DEMO/alited/demo.tcl#\} ;#------------- TO COMMENT OUT
  if {[llength $ALITED_ARGV]} {
    set ::argc 0
    set ::argv {}
    after 10 [list ::alited::open_files_and_raise 0 {*}$ALITED_ARGV]
  }
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
#  catch #\{source ~/PG/github/DEMO/alited/demo.tcl#\} ;#------------- TO COMMENT OUT
  if {[set res [alited::main::_run]]} {     ;# run the main form
    # restarting
    update
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
    for {set i [llength $alited::ARGV]} {$i} {} {
      incr i -1
      if {[file isfile [lindex $alited::ARGV $i]]} {  ;# remove file names passed to ALE
        set alited::ARGV [lreplace $alited::ARGV $i $i]
      }
    }
    exec -- [info nameofexecutable] $alited::SCRIPT {*}$alited::ARGV &
  } elseif {$alited::LOG ne {}} {
    ::apave::logMessage {QUIT ------------}
  }
  exit $res
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
