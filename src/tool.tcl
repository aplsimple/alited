###########################################################
# Name:    tool.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/13/2021
# Brief:   Handles tools of alited.
# License: MIT.
###########################################################

namespace eval tool {
  variable focusedBut {}  ;# focused button of Run query
}

#_______________________

proc tool::ToolButName {img} {
  # Helper procedure to get a name of toolbar button.
  #   img - name of icon

  namespace upvar ::alited obPav obPav
  return [$obPav ToolTop].buT_alimg_$img-big
}

# ________________________ Edit functions _________________________ #

proc tool::CtrlC {} {
  catch {event generate [alited::main::CurrentWTXT] <<Copy>>}
}

proc tool::CtrlX {} {
  catch {event generate [alited::main::CurrentWTXT] <<Cut>>}
}

proc tool::CtrlV {} {
  catch {event generate [alited::main::CurrentWTXT] <<Paste>>}
}

proc tool::Undo {} {
  catch {event generate [alited::main::CurrentWTXT] <<Undo>>}
}

proc tool::Redo {} {
  catch {event generate [alited::main::CurrentWTXT] <<Redo>>}
}
#_______________________

proc tool::InsertInText {str {pos1 {}} {pos2 {}} } {
  # Insert a string into a text possibly instead of its selection.
  #   str - the string
  #   pos1 - starting position in a current line
  #   pos2 - ending position in a current line

  set wtxt [alited::main::CurrentWTXT]
  if {$pos1 eq {}} {
    lassign [$wtxt tag ranges sel] pos1 pos2
  } else {
    set line [expr {int([$wtxt index insert])}]
    set prevch [$wtxt get $line.[expr {$pos1-1}] $line.$pos1]
    if {$prevch eq [string index $str 0]} {
      incr pos1 -1
    }
    set pos1 $line.$pos1
    set pos2 $line.[incr pos2]
  }
  if {$pos1 ne {}} {
    $wtxt delete $pos1 $pos2
  }
  $wtxt insert [$wtxt index insert] $str
}

# ________________________ Various tools _________________________ #

proc tool::ColorPicker {} {
  # Calls a color picker passing to it and getting from it a color.

  namespace upvar ::alited al al
  lassign [alited::find::GetWordOfText 2] color pos1 pos2
  if {$color ne {}} {
    set al(chosencolor) $color
  }
  set res [::apave::obj chooser colorChooser alited::al(chosencolor) \
    -moveall $al(moveall) -tonemoves $al(tonemoves) -parent $al(WIN) \
    -geometry pointer+10+10]
  if {$res ne {}} {
    set al(moveall) [::apave::obj paveoptionValue moveall]
    set al(tonemoves) [::apave::obj paveoptionValue tonemoves]
    set al(chosencolor) $res
    InsertInText $res $pos1 $pos2
  }
}
#_______________________

proc tool::FormatDate {{date {}}} {
  # Formats a date.
  #   date - date to be formatted (a current date if omitted)

  namespace upvar ::alited al al
  if {$date eq {}} {set date [clock seconds]}
  return [clock format $date -format $al(TPL,%d)]
}
#_______________________

proc tool::DatePicker {} {
  # Calls a calendar to pick a date.

  namespace upvar ::alited al al
  lassign [alited::find::GetWordOfText 2] date pos1 pos2
  if {$date ne {} \
  && ![catch {clock scan $date -format $al(TPL,%d)}]} {
    set al(klnddate) $date
  } elseif {![info exists al(klnddate)]} {
    set al(klnddate) [FormatDate]
  }
  set res [::apave::obj chooser dateChooser alited::al(klnddate) \
    -parent $al(WIN) -geometry pointer+10+10 -dateformat $al(TPL,%d)]
  if {$res ne {}} {
    set al(klnddate) $res
    InsertInText $res $pos1 $pos2
  }
}
#_______________________

proc tool::SrcPath {toolpath} {
  # Gets a path to an external tool.
  # This may be useful at calling alited by tclkit:
  # tkcon, aloupe etc. may be located in "src" subdirectory of alited.

  set srcpath [file join $::alited::FILEDIR src [file tail $toolpath]]
  if {[file exists $srcpath]} {set toolpath $srcpath}
  catch {cd [file dirname $toolpath]}
  return $toolpath
}
#_______________________

proc tool::Loupe {} {
  # Calls a screen loupe.

  namespace upvar ::alited al al LIBDIR LIBDIR PAVEDIR PAVEDIR USERDIR USERDIR
  if {$al(IsWindows)} {set le aloupe.exe} {set le aloupe}
  set loupe [file join $LIBDIR util $le]
  if {[file exists $loupe]} {
    # try to run the loupe executable from lib/util
    if {![catch {exec $loupe}]} return
  }
  set loupe [SrcPath [file join $PAVEDIR pickers color aloupe aloupe.tcl]]
  alited::Run $loupe -locale $alited::al(LOCAL) -apavedir $PAVEDIR -cs $al(INI,CS) \
  -fcgeom $::alited::FilGeometry -inifile [file join $USERDIR aloupe.conf]
}
#_______________________

proc tool::tkconPath {} {
  # Gets the path to tkcon.tcl.

  return [SrcPath [file join $::alited::LIBDIR util tkcon.tcl]]
}
#_______________________

proc tool::tkconOptions {} {
  # Gets options of tkcon.tcl.

  namespace upvar ::alited al al
  foreach opt [array names al tkcon,clr*] {
    lappend opts -color-[string range $opt 9 end] $al($opt)
  }
  foreach opt {rows cols fsize geo topmost} {
    lappend opts -apl-$opt $al(tkcon,$opt)
  }
  return $opts
}
#_______________________

proc tool::tkcon {args} {
  # Calls Tkcon application.
  #   args - additional arguments for tkcon

  set pid [alited::Run [tkconPath] {*}[tkconOptions] {*}$args]
  if {[llength $args]} {set ::alited::pID $pid}
}
#_______________________

proc tool::Help {} {
  # Calls a help on alited.

  _run Help
}
#_______________________

proc tool::HelpTool {win hidx} {
  # Handles hitting "Help" button in dialogues.
  #   win - dialogue's window name
  #   hidx - help's index

  alited::Help $win $hidx
}

# ________________________ emenu support _________________________ #

proc tool::EM_Options {opts} {
  # Returns e_menu's general options.

  namespace upvar ::alited al al SCRIPTNORMAL SCRIPTNORMAL CONFIGDIR CONFIGDIR
  set sel [string trim [alited::find::GetWordOfText]]
  set sel [lindex [split $sel \n] 0] ;# only 1st line for "selection"
  set sel [string map [list \" "" \{ "" \} "" \[ "" \] "" \\ "" \$ ""] $sel]
  set f [alited::bar::FileName]
  set d [file dirname $f]
  # get a list of selected tabs (i.e. their file names):
  # it's used as %ls wildcard in grep.mnu ("SEARCH EXACT LS=")
  set tabs [alited::bar::BAR listFlag s]
  if {[llength $tabs]>1} {
    foreach tab $tabs {
      append ls [alited::bar::FileName $tab] " "
    }
    set ls "\"ls=$ls\""
  } else {
    set ls "ls="
  }
  # get file names of left & right tabs (used in utils.mnu by diff items)
  set z6 {}
  set z7 {}
  set tabs [alited::bar::BAR listTab]
  set TID [alited::bar::CurrentTabID]
  set i [lsearch -index 0 $tabs $TID]
  if {$i>=0} {
    if {$i} {
      append z6 z6=[alited::bar::FileName [lindex $tabs $i-1 0]]
    }
    append z7 z7=[alited::bar::FileName [lindex $tabs $i+1 0]]
  }
  set srcdir [file join $::alited::FILEDIR src]
  if {[file exists [file join $srcdir e_menu.png]]} {
    set srcdir "\"SD=$srcdir\""
  } else {
    set srcdir {}
  }
  if {$al(EM,DiffTool) ne {}} {set df DF=$al(EM,DiffTool)} {set df {}}
  set l [[alited::main::CurrentWTXT] index insert]
  set l [expr {int($l)}]
  set dirvar [set filvar [set tdir {}]]
  if {$al(EM,exec)} {
    lassign [::apave::getProperty DirFilGeoVars] dirvar filvar
    if {$dirvar ne {} && [set dirvar [set $dirvar]] ne {}} {
      set dirvar "\"g1=$dirvar\""
    }
    if {$filvar ne {} && [set filvar [set $filvar]] ne {}} {
      set filvar "\"g2=$filvar\""
    }
    set tdir $::alited::LIBDIR
  }
  if {$al(EM,geometry) eq {}} {
    # at 1st exposition, center e_menu approximately
    lassign [split [wm geometry $al(WIN)] x+] w h x y
    set al(EM,geometry) [apave::obj EXPORT CenteredXY $w $h $x $y 300 [expr {$h/2}]]
  }
  set ed [info nameofexecutable]\ $SCRIPTNORMAL\ $CONFIGDIR
  set R [list "md=$al(EM,mnudir)" "m=$al(EM,mnu)" "f=$f" "d=$d" "l=$l" \
    "PD=$al(EM,PD=)" "pd=$al(prjroot)" "h=$al(EM,h=)" "tt=$al(EM,tt=)" "s=$sel" \
    o=-1 om=0 g=$al(EM,geometry) $z6 $z7 {*}$ls $df {*}$opts {*}$srcdir \
    {*}$dirvar {*}$filvar th=$al(THEME) td=$tdir ed=$ed wt=$al(EM,wt=)]
  set res {}
  foreach r $R {append res "\"$r\" "}
  return $res
}
#_______________________

proc tool::EM_dir {} {
  # Returns a directory of e_menu's menus.

  namespace upvar ::alited al al
  if {$al(EM,mnudir) eq {}} {
    return $::e_menu_dir
  }
  return [file dirname $al(EM,mnudir)]
}
#_______________________

proc tool::EM_Structure {mnu} {
  # Gets a menu's items.
  #   mnu - the menu's file name

  namespace upvar ::alited al al
  set mnu [string trim $mnu "\" "]
  set fname [file join [EM_dir] menus [file tail $mnu]]
  if {[catch {set fcont [::apave::readTextFile $fname {} 1]}]} {
    return [list]
  }
  set res [list]
  set prname {}
  set mmarks [list S: R: M: S/ R/ M/ SE: RE: ME: SE/ RE/ ME/ SW: RW: MW: SW/ RW/ MW/ I:]
  set ismenu yes
  set ishidden [set isoptions no]
  foreach line [::apave::textsplit $fcont] {
    set line [string trimleft $line]
    switch $line {
      {[MENU]} {
        set ismenu yes
        set ishidden [set isoptions no]
        continue
      }
      {[HIDDEN]} {
        set ishidden yes
        set ismenu [set isoptions no]
        continue
      }
      {[OPTIONS]} {
        set isoptions yes
        set ismenu [set ishidden no]
      }
    }
    if {$isoptions} continue
    foreach mark $mmarks {
      if {[string match "${mark}*${mark}*" $line]} {
        set i1 [string length $mark]
        set i2 [string first $mark $line 2]
        set typ [string index $mark 0]
        if {$typ eq {M}} {
          set line [string range $line $i2 end]
          lassign [regexp -inline {.+m=([^[:blank:]]+)} $line] -> itemname
        } else {
          set itemname [string trim [string range $line $i1 $i2-1]]
        }
        if {$itemname ni {{} -} && $itemname ne $prname} {
          set prname $itemname
          if {$ishidden} {set h h} {set h {}}
          lappend res [list $mnu "$typ-$itemname" $h]
        }
      }
    }
  }
  return $res
}
#_______________________

proc tool::EM_HotKey {idx} {
  # Returns e_menu's hotkeys which numerate menu items.

  set hk {0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,./}
  return [string index $hk $idx]
}
#_______________________

proc tool::EM_AllStructure1 {mnu lev} {
  # Gets recursively all items of all menus.
  #   mnu - a current menu's file name
  #   lev - a current level of menu

  foreach mit [EM_Structure $mnu] {
    incr i
    lassign $mit mnu item h
    if {[string match {M-*} $item]} {
      if {[lsearch -exact -index end $alited::al(EM_STRUCTURE) $item]>-1} {
        continue ;# to avoid infinite cycle
      }
      set lev [EM_AllStructure1 [string range $item 2 end] [incr lev]]
    } else {
      lappend alited::al(EM_STRUCTURE) [list $lev $mnu $h[EM_HotKey $i] $item]
    }
  }
  return [incr lev -1]
}
#_______________________

proc tool::EM_AllStructure {mnu} {
  # Gets all items of all menus.
  #   mnu - a root menu's file name

  set alited::al(EM_STRUCTURE) [list]
  EM_AllStructure1 $mnu 0
  return $alited::al(EM_STRUCTURE)
}
#_______________________

proc tool::EM_SaveFiles {} {
  # Saves all files before running e_menu, if this mode is set in "Preferences".
  namespace upvar ::alited al al
  if {$al(EM,save) in {All yes}} {
    alited::file::SaveAll
  } elseif {$al(EM,save) eq {Current}} {
    if {[alited::file::IsModified]} {
      alited::file::SaveFile
    }
  }
}
#_______________________

proc tool::PopupBar {X Y} {
  # Opens a popup menu in the tool bar, to enter e_menu's preferences.
  #   X - x-coordinate of clicking on the tool bar
  #   Y - y-coordinate of clicking on the tool bar

  namespace upvar ::alited al al obPav obPav
  set popm $al(WIN).popupBar
  catch {destroy $popm}
  menu $popm -tearoff 0
  $popm add command -label [msgcat::mc {Open bar/menu settings}] \
    -command {alited::pref::_run Emenu_Tab}
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}
#_______________________

proc tool::EM_command {im} {
  # Gets e_menu command.
  #   im - index of the command in em_inf array

  namespace upvar ::alited::pref em_inf em_inf
  lassign $em_inf($im) mnu idx item
  if {$idx eq {-} || [regexp {^[^[:blank:].]+[.]mnu: } $item]} {
    # open a menu
    set mnu [string range $item 0 [string first : $item]-1]
    set ex {ex= o=-1}
  } else {
    # call a command
    set ex "ex=[alited::tool::EM_HotKey $idx]"
  }
  return "alited::tool::e_menu \"m=$mnu\" $ex"
}
#_______________________

proc tool::EM_optionTF {args} {
  # Prepares TF= option for e_menu.
  #   args - options of e_menu
  # TF= is a name of file that contains a current text's selection.
  # If there is no selection, TF= option is a current file's name.

  namespace upvar ::alited al al
  set sels [alited::edit::SelectedLines {} yes]
  set wtxt [lindex $sels 0]
  set sel {}
  foreach {l1 l2} [lrange $sels 1 end] {
    append sel [$wtxt get $l1.0 $l2.end] \n
  }
  if {[string length [string trimright $sel]]<2 || \
  (![is_mainmenu $args] && {m=tests.mnu} ni $args)} {
    set tmpname [alited::bar::FileName]
  } else {
    set tmpname [file join $al(EM,mnudir) SELECTION~]
    ::apave::writeTextFile $tmpname sel
  }
  return TF=$tmpname
}

## _____________________ run Tcl/ext commands ___________________ ##

proc tool::Runs {mc runs} {
  # Runs a list of Tcl/ext commands.
  #   mc - message for infobar
  #   runs - list of commands

  set runs [string map [list $alited::EOL \n] $runs]
  foreach run [split $runs \n] {
    if {[set run [string trim $run]] ne {} && [string first # $run]!=0} {
      if {[catch {eval $run} e]} {
        catch {exec -- {*}$run} e
      }
      alited::info::Put "$mc: \"$run\" -> $e"
      update
    }
  }
}

## ________________________ after start _________________________ ##

proc tool::AfterStartDlg {} {
  # Dialogue to enter a command before running "Tools/Run"

  namespace upvar ::alited al al obDl2 obDl2
  set head [msgcat::mc "\n Enter commands to be run after starting alited.\n They can be Tcl or executables.\n"]
  set run [string map [list $alited::EOL \n] $al(afterstart)]
  lassign [$obDl2 input {} $al(MC,afterstart) [list \
    tex "{[msgcat::mc Commands:]    } {} {-w 80 -h 16 -tabnext {butOK butCANCEL}}" "$run" ] \
      -head $head -help {alited::tool::HelpTool %w 1}] res run
  if {$res} {
    set al(afterstart) [string map [list \n $alited::EOL] [string trim $run]]
    alited::ini::SaveIni
  }
}
#_______________________

proc tool::AfterStart {} {
  # Runs commands after starting alited.

  namespace upvar ::alited al al
  Runs $al(MC,afterstart) $al(afterstart)
}

## ________________________ before run _________________________ ##

#! let this commented stuff be a code snippet for tracing apave variables, huh:
#proc tool::TraceComForce {name1 name2 op} {
#  # Traces al(comForce) to enable/disable the text field in "Before Run" dialogue.
#
#  namespace upvar ::alited obDl2 obDl2
#  catch {
#    set txt [$obDl2 Tex]
#    if {[set $name1] eq {}} {set st normal} {set st disabled}
#    $txt configure -state $st
#    $obDl2 makePopup $txt no yes
#    set cbx [$obDl2 CbxfiL]
#    if {[focus] ne $cbx && $st eq {disabled}} {
#      after 300 "focus $cbx"
#    }
#  }
#  return {}
#}
##_______________________

proc tool::TestForcedRun {} {
  # Handler of "Run forced command" button.

  namespace upvar ::alited obDl2 obDl2
  $obDl2 res {} 11
}
#_______________________

proc tool::DeleteForcedRun {} {
  # Handler of "Delete forced command" button.

  namespace upvar ::alited al al obDl2 obDl2
  set cbx [$obDl2 CbxfiL]
  if {[set val [string trim [$cbx get]]] eq {}} return
  set values [$cbx cget -values]
  if {[set i [lsearch -exact $values $val]]>-1} {
    set al(comForceLs) [lreplace $values $i $i]
    $cbx configure -values $al(comForceLs)
  }
  $cbx set {}
}
#_______________________

proc tool::BeforeRunDialogue {focrun} {
  # Dialogue to enter a command before running "Tools/Run"
  #   focrun - yes, if "Forced command" should be focused.

  namespace upvar ::alited al al obDl2 obDl2
  set head [msgcat::mc "\n Enter commands to be run before running a current file with \"Tools/Run\".\n They can be Tcl or executables."]
  set run [string map [list $alited::EOL \n] $al(prjbeforerun)]
  set prompt1 [string range [msgcat::mc {Forcedly:}][string repeat { } 15] 0 15]
  set prompt2 [string range [msgcat::mc Commands:][string repeat { } 15] 0 15]
  set prompt3 [string range [msgcat::mc Run]:[string repeat { } 15] 0 15]
  if {[lindex $al(comForceLs) 0] eq {-}} {
    set al(comForceLs) [lreplace $al(comForceLs) 0 0]  ;# legacy
  }
  if {[lindex $al(comForceLs) 0] ne {}} {
    set i [lsearch $al(comForceLs) {}]
    set al(comForceLs) [lreplace $al(comForceLs) $i $i]
    set al(comForceLs) [linsert $al(comForceLs) 0 {}]  ;# to allow blank value
  }
#! let this commented stuff be a code snippet for tracing apave variables, huh:
#  after idle [list after 0 " \
#    set tvar \[$obDl2 varName cbx\] ;\
#    trace add variable \$tvar write ::alited::tool::TraceComForce ;\
#    set \$tvar \[set \$tvar\]
#  "]
  if {$focrun || [ComForced]} {set foc {-focus cbx}} {set foc {}}
  lassign [$obDl2 input {} $al(MC,beforerun) [list \
    seh1 {{} {-pady 15}} {} \
    Tex "{$prompt2} {} {-w 80 -h 16 -tabnext {*cbx* *CANCEL}}" $run \
    seh2 {{} {-pady 15}} {} \
    lab {{} {} {-t { Also, you can set "forced command" to be run by "Run" tool:}}} {} \
    fiL [list $prompt1 {-fill none -anchor w -pady 8} [list -w 80 -h 12 -cbxsel $::alited::al(comForce) -clearcom alited::tool::DeleteForcedRun]] [list $al(comForce) {*}$al(comForceLs)] \
    btT1 [list {} {-padx 5} "-com alited::tool::DeleteForcedRun -tip Delete -toprev 1 -image [::apave::iconImage no]"] {} \
    butRun "{$prompt3} {} {-com alited::tool::TestForcedRun -tip Test -tabnext *butOK}" [msgcat::mc Test] \
  ] -head $head {*}$foc -help {alited::tool::HelpTool %w 2}] \
  res run com
  return [list $res $run $com]
}

#_______________________

proc tool::BeforeRunDlg {} {
  # Runs "Before Run" dialogue and does its chosen action.

  namespace upvar ::alited al al
  set savForce $al(comForce)
  set savForceLs $al(comForceLs)
  set focrun 0
  set res 11
  while {$res==11} {
    lassign [BeforeRunDialogue $focrun] res run com
    if {!$res} {
      set al(comForce) $savForce
      set al(comForceLs) $savForceLs
      break
    }
    set al(comForce) [string trim $com]
    if {[ComForced]} {
      set i [lsearch -exact $al(comForceLs) $com]
      set al(comForceLs) [lreplace $al(comForceLs) $i $i]
      set al(comForceLs) [linsert $al(comForceLs) 1 $com]
      set al(comForceLs) [lrange $al(comForceLs) 0 $al(INI,RECENTFILES)]
    }
    if {$res==11} {
      if {[ComForced]} _run bell
      set focrun yes
    } else {
      set al(prjbeforerun) [string map [list \n $alited::EOL] [string trim $run]]
      alited::ini::SaveIniPrj
      alited::main::UpdateProjectInfo
    }
  }
}
#_______________________

proc tool::BeforeRun {} {
  # Runs commands before running "Tools/Run"

  namespace upvar ::alited al al
  Runs $al(MC,beforerun) $al(prjbeforerun)
}
#_______________________

proc tool::ComForced {} {
  # Checks whether a forced command is set.

  return [expr {[string trim $::alited::al(comForce)] ni {- {}}}]
}

## ________________________ run tcl source _________________________ ##

proc tool::RunArgs {} {
  # Gets ARGS/RUNF arguments (similar to ::em::get_AR of e_menu.tcl).
  # Returns a list of ARGS and RUNF arguments found in the current file.

  set res {}
  set ar {^[[:space:]#/*]*#[ ]?ARGS[0-9]?:[ ]*(.*)}
  set rf {^[[:space:]#/*]*#[ ]?RUNF[0-9]?:[ ]*(.*)}
  set AR [set RF {}]
  set filecontent [split [[alited::main::CurrentWTXT] get 1.0 end] \n]
  foreach st $filecontent {
    if {[regexp $ar $st] && $AR eq {}} {
      lassign [regexp -inline $ar $st] => AR
    } elseif {[regexp $rf $st] && $RF eq {}} {
      lassign [regexp -inline $rf $st] => RF
    }
    if {$AR ne {} || $RF ne {}} {
      if {"$AR$RF" ne {OFF}} {
        set res [list $AR $RF]
      }
      break
    }
  }
  return $res
}
#_______________________

proc tool::CheckTcl {} {
  # Check a current unit for errors, before running Tcl file.

  lassign [alited::tree::CurrentItemByLine {} 1] - - leaf - name l1 l2
  if {$leaf} {
    alited::CheckSource
    set wtxt [alited::main::CurrentWTXT]
    set TID [alited::bar::CurrentTabID]
    set err [alited::check::CheckUnit $wtxt $l1.0 $l2.end $TID $name yes yes]
    if {$err} {
      set msg [msgcat::mc {Errors found in unit:}]\ $name
      alited::Message $msg 4
    }
  }
}
#_______________________

proc tool::RunTcl {{runmode ""}} {
  # Try to run tcl source file by means of tkcon utility.
  #   runmode - mode of running (in console or in tkcon)
  # Returns yes if a tcl file was started.

  if {($runmode eq {} && !$alited::al(tkcon,topmost)) || $runmode eq {tkcon}} {
    lassign [RunArgs] ar rf
    set tclfile {}
    catch {  ;# ar & rf can be badly formed => catch
      set fname [alited::bar::FileName]
      if {[llength $ar] || (![llength $rf] && [alited::file::IsTcl $fname])} {
        set rf $fname
        append rf { } $ar
      }
      if {[set tclfile [lindex $rf 0]] ne {}} {
        cd [file dirname $fname]
        set tclfile [file normalize $tclfile]
        set rf [lreplace $rf 0 0]
      }
    }
    if {$tclfile ne {} && [file exists $tclfile]} {
      # run tkcon with file.tcl & argv
      EM_SaveFiles
      tkcon $tclfile -apl-topmost 0 -argv {*}$rf
      return yes
    }
  }
  return no
}
#_______________________

proc tool::RunMode {} {
  # Runs Tcl source file with choosing the mode - in console or in tkcon.

  namespace upvar ::alited al al obDl2 obDl2
  variable focusedBut
  set fname  [file tail [alited::bar::FileName]]
  if {![alited::file::IsTcl $fname] || [ComForced]} {
    _run
    return
  }
  if {![info exists al(RES,RunMode)] || ![string match *10 $al(RES,RunMode)]} {
    if {$focusedBut eq {}} {
      if {$al(tkcon,topmost)} {
        set focusedBut *Other
      } else {
        set focusedBut *Terminal
      }
    }
    set al(RES,RunMode) [$obDl2 misc ques $al(MC,run) \
      "\n $al(MC,run) $fname \n" \
      [list $al(MC,inconsole) Terminal $al(MC,intkcon) Other Cancel 0] \
      1 -focus $focusedBut -ch $al(MC,noask)]
  }
  switch -glob $al(RES,RunMode) {
    Terminal* {
      _run {} terminal
      set focusedBut *Terminal
      }
    Other* {
      _run {} tkcon
      set focusedBut *Other
      }
  }
}

## ________________________ run/close _________________________ ##

proc tool::is_mainmenu {menuargs} {
  # Checks if e_menu's arguments are for the main menu (run by F4).
  #   menuargs - e_menu's arguments
  # The e_menu's arguments contain ex= or EX= for bar/menu tools only.

  return [expr {[lsearch -glob -nocase $menuargs EX=*] == -1}]
}
#_______________________

proc tool::is_emenu {} {
  # Check for e_menu's existence.

  if {[winfo exists .em] && [winfo ismapped .em]} {
    wm withdraw .em
    wm deiconify .em
    bell
    return yes
  }
  return no
}
#_______________________

proc tool::e_menu {args} {
  # Runs e_menu.
  #   args - arguments of e_menu
  # The e_menu is run as an external application or an internal procedure,
  # depending on e_menu's preferences.

  namespace upvar ::alited al al
  lappend args [EM_optionTF {*}$args]
  if {{EX=Help} ni $args} {
    EM_SaveFiles
    if {![is_mainmenu $args]} {
      if {[set p [string first + $al(EM,geometry)]]>-1} {
        set g [string range $al(EM,geometry) $p end]
      } else {
        set g {}
      }
      append args " g=$g"  ;# should be last, to override previous settings
    }
    if {{m=grep.mnu} in $args} {
      append args { NE=1}  ;# let him search till closing the search dialogue
    }
  }
  if {{m=menu.mnu} in $args && {ex=d} in $args && $al(BACKUP) ne {}} {
    # Differences of a file & its backup: get the backup's name
    set TID [alited::bar::CurrentTabID]
    lassign [alited::edit::BackupDirFileNames $TID] dir fname fname2
    #set fname2 [alited::edit::BackupFileName $fname2 0]
    append args " \"BF=$fname2\""  ;# version before 1st change
  }
  if {{EX=1} ni $args} {
    append args { AL=1}  ;# to read a current file only at "Run me"
  }
  if {$alited::al(EM,exec)} {
    e_menu1 $args
  } else {
    e_menu2 $args
  }
}
#_______________________

proc tool::e_menu1 {opts} {
  # Runs e_menu.
  #   opts - options of e_menu
  # The e_menu is run as an external application.

  namespace upvar ::alited al al obPav obPav
  if {$al(EM,ownCS)} {
    set cs $al(EM,CS)
  } else {
    set cs $al(INI,CS)  ;# without tinting: e_menu hasn't the tint option
  }
  alited::Run [file join $::e_menu_dir e_menu.tcl] \
    {*}[EM_Options $opts] c=$cs fs=$al(FONTSIZE,std)
}
#_______________________

proc tool::e_menu2 {opts} {
  # Runs e_menu.
  #   opts - options of e_menu
  # The e_menu is run as an internal procedure.

  ::alited::source_e_menu
  ::apave::cs_Active no ;# no CS changes by e_menu
  if {[is_emenu]} return
  set options [EM_Options $opts]
  ::em::main -prior 1 -modal 0 -remain 0 -noCS 1 {*}$options
  set maingeo [::em::menuOption $::alited::al(EM,mnu) geometry]
  if {[is_mainmenu $options] && $maingeo ne {}} {
    set alited::al(EM,geometry) $maingeo
  }
  ::apave::cs_Active yes
}
#_______________________

proc tool::e_menu3 {} {
  # Prepares TF= argument for e_menu and runs e_menu's main menu.

  e_menu o=0 [EM_optionTF]
}
#_______________________

proc tool::_run {{what ""} {runmode ""}} {
  # Runs e_menu's item of menu.mnu.
  #   what - the item (by default, "Run me")
  #   runmode - mode of running (in console or in tkcon)

  namespace upvar ::alited al al
  if {[is_emenu]} return
  set opts "EX=$what"
  if {$what eq {}} {
    #  it is 'Run me' e_menu item
    if {!$::alited::DEBUG} {
      if {$al(EM,exec)} {
        set fpid [file join $al(EM,mnudir) .pid~]
        set pid [::apave::readTextFile $fpid]
      } else {
        ::alited::source_e_menu ;# e_menu is "internal"
        set pid [::em::pID]
        ::em::pID 0
      }
      catch {
        if {$pid>0} {exec kill -s SIGINT $pid}
      }
      catch {
        if {$::alited::pID>0} {exec kill -s SIGINT $::alited::pID}
      }
      set ::alited::pID 0
    }
    BeforeRun
    set fnameCur [alited::bar::FileName]
    if {[alited::file::IsTcl $fnameCur]} CheckTcl
    if {[ComForced]} {
      ::alited::Message "$al(MC,run): $al(comForce)" 3
      set tc {}
      set tw %t
      catch {
        if {[set fname [lindex $al(comForce) 0]] eq {%f}} {
          set fname $fnameCur
        }
        if {[alited::file::IsTcl $fname]} {
          if {!$al(tkcon,topmost)} {
            set tc \
              "tc=[alited::Tclexe] [alited::tool::tkconPath] [alited::tool::tkconOptions]"
            set tw {}
          } else {
            set tw "%t [alited::Tclexe] "
          }
        }
      }
      e_menu ee=$tw[string map [list \" \\\" \\ \\\\] $al(comForce)] \
        f=[string map [list \\ \\\\] [alited::bar::FileName]] \
        pd=[string map [list \\ \\\\] $al(prjroot)] $tc
      return
    }
    if {[RunTcl $runmode]} return
    set opts {EX=1 PI=1}
  }
  e_menu {*}$opts tc=[alited::Tclexe]
}
#_______________________

proc tool::_close {{fname ""}} {
  # Closes e_menu (being an internal procedure) by force.

  catch {destroy .em}
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
