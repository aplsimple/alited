#! /usr/bin/env tclsh
###########################################################
# Name:    alited.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    03/01/2021
# Brief:   Starting actions, alited's common procedures.
# License: MIT.
###########################################################

package provide alited 1.8.9  ;# for documentation (esp. for Ruff!)

namespace eval alited {
  variable al; array set al [list]
  set DEBUG no  ;# debug mode
}

# firstly, remove alited's options from argv
if {[set _ [lsearch -exact $::argv -OLDTHEME]]>-1} {
  set ::alited::al(OLDTHEME) [lindex $::argv $_+1]
  set ::argv [lreplace $::argv $_ [incr _]]
}
if {[set _ [lsearch -exact $::argv DEBUG]]>-1} {
  set ::alited::DEBUG yes
  set ::argv [lreplace $::argv $_ $_]
}
set ::argc [llength $::argv]

namespace eval alited {

  variable tcltk_version [package require Tk]
  variable isTcl90 [package vsatisfies $tcltk_version 9.0-]
  if {![package vsatisfies $tcltk_version 8.6.9-]} {
    tk_messageBox -message "\nalited needs Tcl/Tk v8.6.9+ \
      \n\nwhile the current is v$tcltk_version\n"
    exit
  }
  set _ [info nameofexecutable]
  if {[string first { } $_]>0} {
    set res [tk_messageBox -title Warning -icon warning -message \
      "The Tcl runtime path\n\n\"$_\"\n\ncontains spaces.\n \
      \nThis path doesn't fit alited. Only 'non-space' ones do.\n \
      \n==> Some tools won't work." -type okcancel]
    if {$res ne {ok}} exit
  }

  variable al2; array set al2 [list] ;# alternative array, just to not touch "al"

  # versions of mnu/ini to update to
  set al(MNUversion) 1.8.7.1
  set al(INIversion) 1.8.0

  # previous version of alited to update from
  set al(ALEversion) 0.0.1
}
wm withdraw .

catch {package require comm}  ;# Generic message transport

# _____ Remove installed (perhaps) packages used in alited _____ #

foreach _ {baltip bartabs hl_tcl} {
  catch {package forget $_}
  catch {namespace delete ::$_}
}
unset -nocomplain _

# __________________________ alited:: Main _________________________ #

namespace eval alited {

  ## ________________________ Main variables _________________________ ##

  set LOG {}    ;# log file in develop mode

  set al(WIN) .alwin    ;# main form's path
  set al(comm_port) 51807  ;# port to listen
  set al(comm_port_list) [list {} $al(comm_port) 51817 51827 51837] ;# ports to listen
  set al(ini_file) {}  ;# alited.ini contents

  # main data of alited (others are in ini.tcl)

  variable SCRIPT [info script]
  variable SCRIPTNORMAL [file normalize $SCRIPT]
  variable FILEDIR [file dirname $SCRIPTNORMAL]
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
  variable HOMEDIR ~
  if {[catch {set HOMEDIR [file home]}] && [info exists ::env(HOME)]} {
    set HOMEDIR $::env(HOME)
  }

  # directories of user's data
  variable CONFIGDIRSTD [file join $HOMEDIR .config]
  if {![file exists $CONFIGDIRSTD] && \
  ($::tcl_platform(platform) eq {windows} || [info exists ::env(LOCALAPPDATA)])} {
    if {[info exists ::env(LOCALAPPDATA)]} {
      set CONFIGDIRSTD $::env(LOCALAPPDATA)
    } else {
      set CONFIGDIRSTD [file join $HOMEDIR AppData Local]
    }
  }
  set CONFIGDIRSTD [file normalize $CONFIGDIRSTD]
  variable USERLASTINI [file join $CONFIGDIRSTD alited last.ini]

  # configurations
  variable CONFIGDIR $CONFIGDIRSTD
  variable CONFIGS [list]

  # two main objects to build forms (just some unique names)
  variable obPav ::alited::alitedpav
  variable obDlg ::alited::aliteddlg  ;# dialog of 1st level
  variable obDl2 ::alited::aliteddl2  ;# dialog of 2nd level
  variable obCHK ::alited::alitedCHK  ;# dialog of "Check Tcl"
  variable obDFW ::alited::alitedDFW  ;# dialog of "DockingFW"
  variable obFND ::alited::alitedFND  ;# dialog of "Find/Replace"
  variable obFN2 ::alited::alitedFN2  ;# dialog of "Find by list"
  variable obRun ::alited::alitedRun  ;# dialog of "Run..."

  # misc. vars
  variable DirGeometry {}  ;# saved geometry of "Choose Directory" dialogue (for Linux)
  variable FilGeometry {}  ;# saved geometry of "Choose File" dialogue (for Linux)
  variable tplgeometry {}  ;# saved geometry of "Template" dialogue
  variable favgeometry {}  ;# saved geometry of "Saved favorites" dialogue
  variable pID 0

  # misc. consts
  variable PRJEXT .ale     ;# project file's extension
  variable EOL {@~}        ;# "end of line" for ini-files

  # project options' names
  variable OPTS [list \
    prjname prjroot prjdirign prjEOL prjindent prjindentAuto prjredunit prjmaxcoms \
    prjmultiline prjbeforerun prjtrailwhite prjincons prjuseleafRE prjleafRE]

  # directory tree's content
  variable _dirtree [list]
  set al(_dirignore) [list]

  # list of helped windows shown by HelpMe proc
  variable helpedMe {}

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
  set al(prjincons) 1     ;# "run Tcl scripts in console" flag
  set al(prjdirign) {.git .bak .gitignore .fslckout} ;# ignored files of project
  set al(prjmaxcoms) 20   ;# maximum of "Run..." commands
  set al(prjuseleafRE) 0  ;# "use leaf's RE"
  set al(prjleafRE) {}    ;# "leaf's RE"
  foreach _ $OPTS {set al(DEFAULT,$_) $al($_)}

  set al(TITLE) {%f :: %d :: %p} ;# alited title's template
  set al(TclExtsDef) [list .tcl .tk .tm .msg .test] ;# extensions of Tcl files
  set al(ClangExtsDef) {.c .h .cpp .hpp} ;# extensions of C/C++ files
  set al(TextExtsDef) {html htm css md txt sh bat ini alm em ale conf wiki ui} ;# ... plain texts
  set al(TclExts) $al(TclExtsDef)
  set al(ClangExts) $al(ClangExtsDef)
  set al(TextExts) $al(TextExtsDef)
  set al(MOVEFG) black
  set al(MOVEBG) #7eeeee

  set al(DockGeo) root=$al(WIN)
  set al(DockLayout) [file join $CONFIGDIR alited data dockFW.tcl]
  set al(ApaveLayout) [file join $CONFIGDIR alited data apaveFW.tcl]

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
        set fname [string trim $fname "\"\{\}"]
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

lappend auto_path $::alited::LIBDIR $::alited::PAVEDIR

source [file join $::alited::PAVEDIR apave.tcl]
source [file join $::alited::BARSDIR bartabs.tcl]
source [file join $::alited::HLDIR  hl_tcl.tcl]
source [file join $::alited::HLDIR  hl_c.tcl]

namespace import ::apave::*

::apave::mainWindowOfApp $::alited::al(WIN)

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
  if {[set _ [lsearch -exact $::argv -NOPORT]]>-1} {
    set ::argv [lreplace $::argv $_ $_]
    incr ::argc -1
    set ALITED_PORT no
  }
  if {[set _ [lsearch -glob $::argv LOG=*]]>-1} {
    set ::alited::LOG [string range [lindex $::argv $_] 4 end]
    set ::argv [lreplace $::argv $_ $_]
    incr ::argc -1
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
  set isalitedCONFIGS [file exists $::alited::USERLASTINI]
  set _ [lindex $::argv 0]
  if {![llength $::argv] || ![file isdirectory $_]} {
    alited::main_user_dirs
    if {(![file exists $::alited::INIDIR] || ![file exists $::alited::PRJDIR]) && \
    $isalitedCONFIGS} {
      # read INIDIR & PRJDIR that were last entered
      lassign [textsplit [readTextFile $::alited::USERLASTINI]] \
        ::alited::INIDIR ::alited::PRJDIR ::alited::CONFIGS
      set ::alited::CONFIGDIR [file dirname [file dirname $::alited::INIDIR]]
      set readalitedCONFIGS yes
    }
  } else {
    set ::alited::CONFIGDIR $_
    set ::argv [lrange $::argv 1 end]
  }
  if {[string index $::argv 0] eq {'} && [string index $::argv end] eq {'}} {
    # when run from menu.em "Edit/create file"
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
    set fcont [textsplit [readTextFile $::alited::USERLASTINI]]
    set ::alited::CONFIGS [lindex $fcont 2]
  }
  unset -nocomplain readalitedCONFIGS
  unset -nocomplain isalitedCONFIGS

  ## ____________________ Port to listen __________________ ##

  # try to read alited.ini
  set _ [file join $_ alited ini alited.ini]
  if {![catch {set _ [open $_]}]} {
    set ::alited::al(ini_file) [split [read $_] \n]
    close $_
    set _ [lindex $::alited::al(ini_file) 1]
    if {[string match comm_port=* $_]} {
      set ::alited::al(comm_port) [string range $_ 10 end]
    } else {
      set ::alited::al(comm_port) 51837 ;# to be compatible with old style
    }
  }
  unset -nocomplain _

  ## ____________________ Open an existing app __________________ ##

  if {[string is integer -strict $::alited::al(comm_port)]} {
    # Code borrowed from TKE editor.
    # Set the comm port that we will use
    # Change our comm port to a known value
    # (if we fail, the app is already running at that port so connect to it)
    if {$::alited::al(IsWindows) && \
    ![catch { ::comm::comm config -port $::alited::al(comm_port) }]} {
      set ALITED_PORT no ;# no running app
    }
  } else {
    set ALITED_PORT no
  }
  if {!$::alited::DEBUG && $ALITED_PORT} {
    if {$::alited::al(IsWindows)} {
      if {[llength $ALITED_ARGV]} {
        # Attempt to add files & raise the existing application
        if {![catch {::comm::comm send $::alited::al(comm_port) ::alited::run_remote \
        ::alited::open_files_and_raise 0 $ALITED_ARGV}]} {
          destroy .
          exit
        }
      } else {
        # Attempt to raise the existing application
        if {![catch { ::comm::comm send $::alited::al(comm_port) ::alited::run_remote \
        ::alited::raise_window }]} {
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

# __________________________ alited:: ________________________ #

namespace eval alited {

  proc FgAdditional {} {
    # Gets the list of additional colors: branch, red, todo.

    lassign [::hl_tcl::addingColors {} -AddTags] - - fgbr - - fgred - - - fgtodo
    list  $fgbr $fgred $fgtodo
  }
  #_______________________

  proc FgFgBold {} {
    # Gets foregrounds of normal and colored text of current color scheme
    # and red color of TODOs.

    variable obPav
    lassign [FgAdditional] -> fgred
    if {[catch {set lst [$obPav csGet]}]} {
      set fg [ttk::style lookup "." -foreground]
      set bg [ttk::style lookup "." -background]
      set fgbold $fgred
    } else {
      lassign $lst - fg - bg fgbold
    }
    list $fg $fgbold $fgred $bg
  }
  #_______________________

  proc ListPaved {} {
    # Returns a list of apave objects for dialogues.

    list obDlg obDl2 obFND obFN2 obCHK obRun obDFW
  }
  #_______________________

  proc SyntaxColors {} {
    # Gets colors for syntax highlighting.

    variable al
    foreach nam [::hl_tcl::hl_colorNames] {lappend colors $al(ED,$nam)}
    lassign [::hl_tcl::addingColors] clrCURL clrCMN2
    lappend colors $clrCURL $clrCMN2
    return $colors
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
    if {$cs eq {}} {set cs [obj csCurrent]}
    ::hl_${lng}::hl_init $wtxt -dark [obj csDark $cs] -colors $colors \
      -multiline 1 -font $al(FONT,txt) -cmdpos ::apave::None {*}$args
    ::hl_${lng}::hl_text $wtxt
  }
  #_______________________

  proc TextIcon {ico {to out}} {
    # Gets a picture from a character and vice versa.
    #   ico - picture or character
    #   to - "in" gets in-chars, "out" gets out-chars

    set in [list 0 1 2 3 4 5 6 7 8 9 & ~ = @]
    set out [list ∀ ∃ ∏ ∑ ⁂ ⊍ ⋀ ⋁ ⋈ ⋒ ⌗ ⌛ ⌬ ⏏]
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
  #_______________________

  proc Tnext {{wprev ""}} {
    # Returns "next & prev widgets" for Tab & Shift/Tab keys, just to skip "Help".
    #   wprev - widget for Shift/Tab
    # Used by obPrf & obPrj objects.

    list *.ButOK $wprev
  }
  #_______________________

  proc TmpFile {tname} {
    # Gets a temporary file's name.
    #   tname - tailing part of the name

    variable al
    return [file join $al(EM,mnudir) $tname]
  }
  #_______________________

  proc ProcEOL {val mode} {
    # Transforms \n to "EOL chars" and vise versa.
    #   val - string to transform
    #   mode - if "in", gets \n-valued; if "out", gets EOL-valued.

    variable EOL
    if {$mode eq {in}} {
      return [string map [list $EOL \n] $val]
    } else {
      return [string map [list \n $EOL] $val]
    }
  }
  #_______________________

  proc ProcessFiles {procname what} {
    # Processes files according to Selected/All choice.
    #   procname - name of command to run on files (TID passed)
    #   what - what to process: 1 - selected, 2 - all
    # Returns numbers of all and processed files.
    # See also: SessionList

    variable da
    set all [set processed 0]
    foreach tab [alited::SessionList $what] {
      incr all
      incr processed [$procname [lindex $tab 0]]
    }
    list $all $processed
  }
  #_______________________

  proc SessionList {{mode 0}} {
    # Returns a list of all tabs or selected tabs (if set).
    #   mode - 0 get selected or all, 1 force selected, 2 force all

    set res [alited::bar::BAR listFlag s]
    if {(!$mode && [llength $res]==1) || $mode==2} {
      set res [alited::bar::BAR listTab]
    }
    return $res
  }
  #_______________________

  proc isTclScript {tab} {
    # Check if the tab's file is of .tcl type.
    #   tab - tab's info

    set TID [lindex $tab 0]
    set fn [alited::bar::FileName $TID]
    expr {[string tolower [file extension $fn]] eq {.tcl}}
  }
  #_______________________

  proc SessionTclList {{mode 0}} {
    # Returns a list of all tabs or selected tabs of .tcl files.
    #   mode - 0 get selected or all, 1 force selected, 2 force all

    set ltabs [list]
    foreach tab [alited::SessionList $mode] {
      if {[alited::isTclScript $tab]} {
        lappend ltabs $tab
      }
    }
    return $ltabs
  }
  #_______________________

  proc EnsureAlArray {arName args} {
    # Ensures restoring an array at calling a proc.
    #   arName - fully qualified array name
    #   args - proc name & arguments

    set foc [focus]
    ::apave::EnsureArray $arName {*}$args
   focusByForce $foc 20
  }
  #_______________________

  proc InitUnitTree {TID} {
    # Initializes the unit tree of file to be processed.
    #   TID - tab's ID

    set wtxt [main::GetWTXT $TID]
    if {$wtxt ne {}} {unit::RecreateUnits $TID $wtxt}
    return 1
  }
  #_______________________

  proc Map {opts str args} {
  # Maps wildcards and %% in a string.
  #   opts - options of "string map" command
  #   str - string
  #   args - list of wildcards and values: {%w1 $val1 %w2 $val2 ...}

    set abra {*^e!`i@U50=|}
    set str [string map [list %% $abra] $str]
    foreach {wc val} $args {
      set str [string map {*}$opts [list $wc $val] $str]
    }
    set str [string map [list $abra %] $str]
}
  #_______________________

  proc MapWildCards {com} {
    # Maps some common wildcards in a command
    #   com - the command
    # Wildcards:
    #   %H - home directory
    #   %P - directory of current project
    #   %F - current file name
    #   %D - directory of current file
    #   %A - directory of alited
    #   %M - directory of e_menu's menus
    #   %E - Tcl/Tk executable as set in Preferences/Tools

    variable al
    variable DIR
    set filename [bar::FileName]
    set dirname [file dirname $filename]
    set com [Map {} $com \
      %H [apave::HomeDir] \
      %P $al(prjroot) \
      %F $filename \
      %D $dirname \
      %A $DIR \
      %M $al(EM,mnudir) \
      %E [Tclexe]]
  }
  #_______________________

  proc Font {} {
    # Gets editor's font.

    variable al
    return $al(FONT,txt)
  }
  #_______________________

  proc FocusText {} {
    # Focuses a current text.

    after idle after 100 {focusByForce [alited::main::CurrentWTXT]}
  }

  ## ________________________ Messages _________________________ ##

  proc MessageTags {} {
    # Gets tags for texts shown with messages.
    # Returns "-tags option" for messages.

    lassign [FgFgBold] -> fS
    set ::alited::textTags [list \
      [list "r" "-font {$::apave::FONTMAINBOLD} -foreground $fS"] \
      [list "b" "-foreground $fS"] \
      [list "link" "openDoc %t@@https://%l@@"] \
      ]
    return {-tags ::alited::textTags}
  }
  #_______________________

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
        err  {set title $al(MC,error)}
        ques {set title $al(MC,question)}
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
      set res [$obDlg $type $icon $title "\n$message\n" {*}$defb \
        -onclose destroy {*}$args]
      unset -nocomplain al(obDlg-BUSY)
    }
    return [lindex $res 0]
  }
  #_______________________

  proc Msg {inf {ic info} args} {
    # Shows a message in text box.
    #   inf - the message
    #   ic - icon

    msg ok $ic $inf -text 1 -w 50 {*}$args
  }
  #_______________________

  proc Message {msg {mode 2} {lab ""} {first yes}} {
    # Displays a message in statusbar.
    #   msg - message
    #   mode - 1: simple; 2: bold; 3: bold color; 4: bold red bell; 5: static; 6: bold red
    #   lab - label's name to display the message in
    #   first - serves to recursively erase the message

    variable al
    variable obPav
    if {[info commands $obPav] eq {} || [catch {lassign [FgFgBold] fg fgbold fgred bg}]} {
      return  ;# at exiting app
    }
    if {$lab eq {}} {set lab [$obPav Labstat3]}
    if {$first} {set msg [msgcat::mc $msg]}
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
    if {$mode > 1} {
      $lab configure -font $fontB
      if {$mode == 4} {
        $lab configure -foreground $fgred
        if {$first} bell
      } elseif {$mode == 3 || $mode == 5} {
        $lab configure -foreground $fgbold
      } elseif {$mode == 6} {
        $lab configure -foreground $fgred
      }
    }
    if {$mode == 5} {
      update
      return
    }
    if {$first} {
      set msec [expr {200*$slen}]
      if {$mode > 1} {
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

  proc MessageNotDisturb {} {
    # Shows "Don't disturb" message.

    variable al
    lassign [alited::complete::TextCursorCoordinates] X Y
    set msg "Working...\nDon't disturb."
    Message $msg 3
    ::baltip::showBalloon $msg \
      -geometry "+$X+$Y" -fg $al(MOVEFG) -bg $al(MOVEBG)
  }
  #_______________________

  proc MessageError {msg} {
  # Doubles error message: in infobar and in status bar.
  #   msg - error message

    info::Put $msg {} yes yes yes -fg
    Message $msg 4
  }
  #_______________________

  proc Balloon {msg {red no} {timo 100} args} {
    # Displays a message in a balloon window.
    #   msg - message
    #   red - yes for red background
    #   timo - millisec. before showing the message
    #   args - options of baltip::tip

    variable al
    variable obPav
    set cs [$obPav csGet]
    set fg [lindex $cs 14]  ;# colors of tips
    set bg [lindex $cs 15]
    if {$red} {set fg #6e0000}
    lassign [split [winfo geometry $al(WIN)] x+] w h x y
    set geo "+([expr {$w+$x}]-W)+$y-60"
    set msg [string map [list \n "  \n  "] $msg]
    if {[llength [split $msg \n]]==1} {set msg \n$msg\n}
    ::baltip clear $al(WIN)
    after $timo [list ::baltip tip $al(WIN) $msg -fg $fg -bg $bg -alpha 0.9 \
        -font {-weight bold -size 11} -pause 1000 -fade 1000 \
        -geometry $geo -bell $red -on yes -relief groove {*}$args]
  }
  #_______________________

  proc Balloon1 {fname} {
    # Shows a balloon about non-existing file.
    #   fname - file's name

    variable al
    Balloon [string map [list %f $fname] $al(MC,filenoexist)]
  }
  #_______________________

  proc IsTipable {} {
    # Checks if a tip on the tree/favorites can be shown.

    variable al
    if {[set foc [focus]] eq {} || [string match *tearoff* $foc]} {
      return no  ;# no tips while focusing on a tearoff menu
    }
    if {[winfo toplevel $foc] ne $al(WIN)} {
      return no  ;# no tips while focusing on a toplevel other than alited's main
    }
    return yes
  }

  ## ________________________ Helps _________________________ ##

  proc HelpAbout {} {
    # Shows "About..." dialogue.

    if {[info commands about::About] eq {}} {
      source [file join $::alited::SRCDIR about.tcl]
    }
    about::About
  }
  #_______________________

  proc HelpAlited {{ilink ""}} {
    # Shows a main help of alited.
    #   ilink - internal link

    openDoc https://aplsimple.github.io/en/tcl/alited/index.html$ilink
  }
  #_______________________

  proc AlitedSrc {} {
    # File open dialog for alited/src.

    variable SRCDIR
    set fnames [file::ChooseMultipleFiles yes $SRCDIR]
    if {[llength $fnames]} {
      file::OpenFile $fnames yes yes
    }
  }
  #_______________________

  proc HelpFile {win fname args} {
    # Reads and shows a help file.
    #   win - currently active window
    #   fname - the file's name
    #   args - option of msg

    variable obDlg
    variable al
    if {[HelpOnce 1 $fname]} return
    lassign [::apave::extractOptions args -ale1Help no -ontop 0] ale1Help ontop
    if {[::asKDE]} {set ontop 1}
    set tags [MessageTags]
    if {[file exists $fname]} {
      set msg [readTextFile $fname]
    } else {
      set msg "Here should be a text of\n\"$fname\""
    }
    if {$::alited::DEBUG} {puts "help file: $fname"}
    set wmax 1
    foreach ln [split $msg \n] {
      set oc 0
      foreach tag {r b link} {
        foreach yn {{} /} {
          set ln2 $ln
          set t <$yn$tag>
          set ln [string map [list $t {}] $ln]
          incr oc [expr {([string length $ln2]-[string length $ln])/([string length $t]+1)}]
        }
      }
      set wmax [expr {max($wmax,[string length $ln]+$oc)}]
    }
    set pobj $obDlg
    if {[info commands $pobj] eq {}} {
      # at first start, there are no apave objects bound to the main window of alited
      # -> create an independent one to be deleted afterwards
      set pobj alitedHelpObjToDel
      catch {::apave::APave create $pobj}
    }
    if {[llength [split $msg \n]]>30} {
      set args [linsert $args 0 -h 30 -scroll 1]
    }
    after 200 [list alited::HelpOnce 0 $fname]
    if {$ale1Help} {
      # if run from "Help/Context", remove its predecessor
      catch {destroy $al(DLGPREV)}
      after idle "set ::alited::al(DLGPREV) \[$pobj dlgPath\]"
    }
    set res [$pobj ok {} Help "\n$msg\n" -modal no -waitvar no \
      -onclose "alited::destroyWindow %w [focus]" -centerme $win -text 1 -scroll no \
      {*}$tags -ontop $ontop -w [incr wmax] {*}$args]
    return $res
  }
  #_______________________

  proc HelpOnce {mode fname} {
    # Handles "Help" window to have the only instance of it.
    #   mode - 1 to check for existance the help; 0 to register it
    #   fname - file of help

    variable al2
    variable obDlg
    set key _help_$fname
    if {$mode} {
      if {[info exists al2($key)] && [winfo exists $al2($key)]} {
        ::apave::deiconify $al2($key)
        return 1
      }
      return 0
    }
    if {[catch {set al2($key) [$obDlg dlgPath]}]} {set al2($key) 0}
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
    variable helpedMe
    if {[lsearch -exact $helpedMe $win]>-1} return
    set ans [HelpFile $win [HelpFname $win $suff] -ch $al(MC,noask)]
    if {[lindex $ans 0]==11} {
      lappend helpedMe $win
    }
  }
  #_______________________

  proc Help {win {suff ""} args} {
    # Shows a help file for a procedure.
    #   win - currently active window
    #   suff - suffix for a help file's name
    #   args - options of HelpFile

    HelpFile $win [HelpFname $win $suff] {*}$args
  }
  #_______________________

  proc destroyWindow {win foc args} {
    # Destroys current window and focuses on previously focused widget.
    #   win - current window passed as %w
    #   foc - previously focused widget

    catch {destroy $win}
    after idle after 100 "focusByForce $foc"
  }

  ## ________________________ Runs & exits _________________________ ##

  proc SaveRunOptions {} {
    # Saves options of "Run..." dialogue.

    variable al
    set al(_SavedRunOptions_) [list \
      $al(prjincons) $al(comForce) $al(comForceLs) $al(comForceCh) $al(prjbeforerun)]
  }
  #_______________________

  proc RestoreRunOptions {} {
    # Restores options of "Run..." dialogue.

    variable al
    lassign $al(_SavedRunOptions_) \
      al(prjincons) al(comForce) al(comForceLs) al(comForceCh) al(prjbeforerun)
  }
  #_______________________

  proc Source_e_menu {} {
    # Sources e_menu.tcl at need.

    if {![info exists ::em::geometry]} {
      source [file join $::e_menu_dir e_menu.tcl]
    }
  }
  #_______________________

  proc EditExt {{fname ""}} {
    # Gets an edited file's extention without '.'.
    #   fname - the file name

    if {$fname eq {}} {set fname [bar::FileName]}
    string trimleft [file extension $fname] .
  }
  #_______________________

  proc HighlightAddon {wtxt fname colors {fontsize ""}} {
    # Tries to highlight add-on extensions.
    #   wtxt - text's path
    #   fname - current file's name
    #   colors - colors of highlighting
    #   fontsize - font size

    namespace upvar ::alited al al LIBDIR LIBDIR
    set res {}
    set ext [EditExt $fname]
    if {$ext ne {}} {
      catch {
        switch $ext {
          htm - ui - tpl1 {set ext html}
          ale - conf - typetpl {set ext ini}
        }
        set addon hl_$ext
        lassign [glob -nocomplain [file join $LIBDIR addon $addon.tcl]] fhl
        set addon [file rootname [file tail $fhl]]
        if {![namespace exists ::alited::$addon]} {
          if {[catch {source $fhl} err]} {
            alited::Message $err 4
            return {}
          }
        }
        lappend colors [FgFgBold]
        if {$fontsize ne {}} {
          set fsz $fontsize
        } elseif {[dict exists $al(FONT,txt) -size]} {
          set fsz [dict get $al(FONT,txt) -size]
        } else {
          set fsz $al(FONTSIZE,std)
        }
        set res [${addon}::init $wtxt $al(FONT,txt) $fsz {*}$colors]
        obj set_highlight_matches $wtxt
        foreach tag {sel hilited hilited2} {after idle $wtxt tag raise $tag}
      }
    }
    return $res
  }
  #_______________________

  proc Hl_Colors {} {
    # Gets highlighting colors.

    variable al
    foreach nam [::hl_tcl::hl_colorNames] {lappend colors $al(ED,$nam)}
    return $colors
  }
  #_______________________

  proc Tclexe {} {
    # Gets Tcl's executable file.

    variable al
    if {$al(EM,Tcl) eq {}} {
      if {$al(IsWindows)} {
        # important: refer to tclsh (not wish), to run it in Windows console
        # though not good for deployed Tcl/Tk 8.6-
        if {[set tclexe [::apave::autoexec tclsh .exe]] eq {}} {
          set tclexe [info nameofexecutable]
        }
      } else {
        set tclexe [info nameofexecutable]
      }
    } else {
      set tclexe $al(EM,Tcl)
    }
    return $tclexe
  }
  #_______________________

  proc Run {args} {
    # Runs Tcl/Tk script.
    #   args - script's name and arguments

    variable al
    set com [string trimright "$args" &]
    if {{TEST_ALITED} in $args} {
      set com [string map [list { TEST_ALITED} {}] $com]
      puts [Tclexe]\ $com
    }
    if {[set i [lsearch $args -dir]]>=0} {
      set dir [lindex $args [incr i]]
    } else {
      set dir $al(prjroot)
    }
    set curdir [pwd]
    catch {cd $dir}
    set res [pid [open |[list [Tclexe] {*}$com]]]
    cd $curdir
    return $res
  }
  #_______________________

  proc Runtime {args} {
    # Runs Tcl/Tk script by alited's Tcl/Tk runtime.
    #   args - script's name and arguments

    exec -- [info nameofexecutable] {*}$args &
  }
  #_______________________

  proc CloseDlg {} {
    # Tries to close a Help dialogue, open non-modal aside by the current dialogue.

    variable obDlg
    catch {[$obDlg ButOK] invoke}
  }
  #_______________________

  proc ScriptSource {script} {
    # Sources script.tcl (at need).
    #   script - the script name

    variable SRCDIR
    if {[info commands ::alited::${script}::_run] eq {}} {
      source [file join $SRCDIR $script.tcl]
    }
  }
  #_______________________

  proc CheckSource {} {
    # Sources check.tcl (at need).

    ScriptSource check
  }
  #_______________________

  proc CheckRun {} {
    # Runs "Check Tcl".

    CheckSource
    check::_run
  }
  #_______________________

  proc PrinterRun {} {
    # Runs "Project Printer".

    ScriptSource printer
    printer::_run
  }
  #_______________________

  proc Exit {{w ""} {res 0} {ask yes}} {
    # Closes alited application.
    #   w - not used
    #   res - result of running of main window
    #   ask - if "yes", requests the confirmation of the exit

    variable al
    variable obPav
    set al(INI,isfindrepl) [expr {[winfo exist $al(WIN).winFind]}]
    if {$al(INI,confirmexit)>1} {
      set timo "-timeout {$al(INI,confirmexit) ButOK}"
    } else {
      set timo {}
    }
    if {!$ask || !$al(INI,confirmexit) || \
    [msg okcancel info [msgcat::mc {Quitting alited.}] OK {*}$timo]} {
      if {[file::AllSaved]} {
        alited::menu::SaveCascadeMenuGeo
        catch {find::CloseFind}  ;# save Find/Replace geometry
        if {$res eq {2}} {
          # save alited's settings: in main::_run not saved yet
          catch {ini::SaveIni}
        }
        tool::_close                     ;# close all of the
        catch {run::Cancel}              ;# possibly open
        catch {check::Cancel}            ;# non-modal
        catch {destroy $::alited::find::win2}    ;# windows
        catch {destroy $::alited::al(FN2WINDOW)} ;# and its possible children
        catch {paver::Destroy}
        $obPav res $al(WIN) $res
        ::apave::endWM
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

  ## _ EONS alited _ ##

}

# _________________________ Run the app _________________________ #

if {$::alited::LOG ne {}} {
  ::apave::logName $::alited::LOG
  ::apave::logMessage "START ------------"
}

# The following "if" counts on the Ruff! doc generator:
#   - Ruff! uses "package require" for a documented package ("alited", e.g.)
#   - alited should not be run when Ruff! sources it
#   - so, without 'package require alited', it's a regular run of alited

if {[info exists ALITED_PORT]} {
  unset -nocomplain ALITED_PORT
#  source [::apave::HomeDir]/PG/github/DEMO/alited/demo.tcl ;#! for demo: COMMENT OUT
  if {[llength $ALITED_ARGV]} {
    set ::argc 0
    set ::argv {}
    after 10 [list ::alited::open_files_and_raise 0 {*}$ALITED_ARGV]
  }
  if {$::alited::DEBUG} {
    alited::ini::_init
  } elseif {[catch {alited::ini::_init} _]} {
    # initialize GUI & data:
    # let a possible error of ini-file be shown, with attempt to continue
    puts \n$::errorInfo\n
    alited::ini::GetUserDirs
    tk_messageBox -title alited -icon error -message \
      "Error of reading of alited's settings: \
      \n$_\n\nProbable reason in the file:\n$::alited::al(INI) \
      \n\nTry to rename/move it or take it from alited's source. \
      \nThen restart alited.\n\nDetails are in stdout."
  }
  set OLDTHEME $::alited::al(THEME)
  alited::main::_create  ;# create the main form
  alited::favor::_init   ;# initialize favorites
  alited::tool::AfterStart
  unset -nocomplain _
  unset -nocomplain ALITED_ARGV
#  source [::apave::HomeDir]/PG/github/DEMO/alited/demo.tcl ;#! for demo: COMMENT OUT
  if {[catch {set res [alited::main::_run]} err]} {
    set res 0
    set msg "\nERROR in alited:"
    puts \n$msg\n\n$::errorInfo\n
    set msg "$msg\n\n$err\n\nPlease, inform authors.\nDetails are in stdout."
    tk_messageBox -title alited -icon error -message $msg
  }
  catch {destroy $al(WIN)}
  if {$res} {     ;# run the main form
    # restarting
    if {[file tail [file dirname $::alited::DIR]] eq {alited.kit}} {
      set ::alited::DIR [file dirname [file dirname $::alited::DIR]]
    } else {
      set ::alited::SCRIPT $::alited::SCRIPTNORMAL
    }
    if {$::alited::LOG ne {}} {
      ::apave::logMessage "QUIT :: $::alited::DIR :: $::alited::SCRIPT PORT $::alited::ARGV"
    }
    cd $::alited::DIR
    for {set i [llength $::alited::ARGV]} {$i} {} {
      incr i -1
      if {[file isfile [lindex $::alited::ARGV $i]]} {  ;# remove file names passed to ALE
        set ::alited::ARGV [lreplace $::alited::ARGV $i $i]
      }
    }
    if {{-OLDTHEME} ni $::alited::ARGV} {
      lappend ::alited::ARGV -OLDTHEME $OLDTHEME
    }
    exec -- [info nameofexecutable] $::alited::SCRIPT {*}$::alited::ARGV &
  } elseif {$::alited::LOG ne {}} {
    ::apave::logMessage {QUIT ------------}
  }
  exit $res
} else {
  # these scripts are sourced at need, here are listed:
  #  - for including them in Ruff!'s generated docs
  #  - as a useful info
  namespace eval alited {
    source [file join $::alited::SRCDIR about.tcl]
    source [file join $::alited::SRCDIR check.tcl]
    source [file join $::alited::SRCDIR indent.tcl]
    source [file join $::alited::SRCDIR run.tcl]
    source [file join $::alited::SRCDIR paver.tcl]
    source [file join $::alited::SRCDIR preview.tcl]
    source [file join $::alited::SRCDIR unit_tpl.tcl]
    source [file join $::alited::SRCDIR format.tcl]
    source [file join $::alited::SRCDIR printer.tcl]
    source [file join $::alited::SRCDIR detached.tcl]
    source [file join $::alited::LIBDIR addon hl_md.tcl]
    source [file join $::alited::LIBDIR addon hl_html.tcl]
    source [file join $::alited::LIBDIR addon hl_em.tcl]
    source [file join $::alited::LIBDIR addon hl_alm.tcl]
    source [file join $::alited::LIBDIR addon hl_ini.tcl]
    source [file join $::alited::LIBDIR addon hl_wiki.tcl]
  }
}
# _________________________________ EOF _________________________________ #
