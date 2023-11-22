###########################################################
# Name:    tool.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/13/2021
# Brief:   Handles tools of alited.
# License: MIT.
###########################################################

namespace eval tool {
}

#_______________________

proc tool::ToolButName {img} {
  # Helper procedure to get a name of toolbar button.
  #   img - name of icon

  namespace upvar ::alited obPav obPav
  return [$obPav ToolTop].buT_alimg_$img-big
}

# ________________________ Edit functions _________________________ #

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

  namespace upvar ::alited al al PAVEDIR PAVEDIR
  lassign [alited::find::GetWordOfText 2] color pos1 pos2
  if {$color ne {}} {
    set al(chosencolor) $color
  }
  if {[info commands ::aloupe::run] eq {}} {
    catch {source [SrcPath [file join $PAVEDIR pickers color aloupe aloupe.tcl]]}
  }
  if {![string is boolean -strict $al(moveall)]} {set al(moveall) 0}
  set res [::apave::obj chooser colorChooser alited::al(chosencolor) \
    -moveall $al(moveall) -parent $al(WIN) -geometry pointer+10+10 -inifile [aloupePath]]
  catch {lassign [::tk::dialog::color::GetOptions] al(moveall)}
  if {$res ne {}} {
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
  return [clock format $date -format $al(TPL,%d) -locale $alited::al(LOCAL)]
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
    InsertInText $res
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

proc tool::aloupePath {} {
  # Gets aloupe ini file's path.

  namespace upvar ::alited USERDIR USERDIR
  return [file join $USERDIR aloupe.conf]
}
#_______________________

proc tool::Loupe {} {
  # Calls a screen loupe.

  namespace upvar ::alited al al LIBDIR LIBDIR PAVEDIR PAVEDIR
  if {$al(IsWindows)} {set le aloupe.exe} {set le aloupe}
  set loupe [file join $LIBDIR util $le]
  if {[file exists $loupe]} {
    # try to run the loupe executable from lib/util
    if {![catch {exec $loupe}]} return
  }
  set loupe [SrcPath [file join $PAVEDIR pickers color aloupe aloupe.tcl]]
  alited::Run $loupe -locale $alited::al(LOCAL) -apavedir $PAVEDIR -cs $al(INI,CS) \
  -fcgeom $::alited::FilGeometry -inifile [aloupePath]
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
  foreach {opt val} $al(tkcon,options) {
    lappend opts -apl$opt $val
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
#_______________________

proc tool::TooltipRun {} {
  # Gets a tip for "Run" tool.

  namespace upvar ::alited al al
  set res $al(MC,icorun)
  if {[ComForced]} {
    set res $al(comForce)\n[lindex [split $res \n] 1]
  }
  return $res
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
  # it's used as %ls wildcard in grep.em ("SEARCH EXACT LS=")
  set tabs [alited::bar::BAR listFlag s]
  if {[llength $tabs]>1} {
    foreach tab $tabs {
      append ls [alited::bar::FileName $tab] " "
    }
    set ls "\"ls=$ls\""
  } else {
    set ls "ls="
  }
  # get file names of left & right tabs (used in utils.em by diff items)
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

  set R [list md=$al(EM,mnudir) m=$al(EM,mnu) f=$f d=$d l=$l \
    PD=$al(EM,PD=) pd=$al(prjroot) h=$al(EM,h=) tt=$al(EM,tt=) s=$sel \
    o=-1 om=0 {*}g=$al(EM,geometry) $z6 $z7 {*}$ls $df {*}$opts {*}$srcdir \
    {*}$dirvar {*}$filvar td=$tdir ed=$ed wt=$al(EM,wt=) mp=1]
  if {[lsearch -glob $R th=*]<0} {lappend R th=$al(THEME)}
  set res {}
  foreach r $R {append res \"$r\" { }}
  return [string trim $res]
}
#_______________________

proc tool::EM_dir {} {
  # Returns a directory of e_menu's menus.

  namespace upvar ::alited al al
  if {$al(EM,mnudir) eq {}} {
    return [file join $::e_menu_dir menus]
  }
  return $al(EM,mnudir)
}
#_______________________

proc tool::EM_Structure {mnu} {
  # Gets a menu's items.
  #   mnu - the menu's file name

  namespace upvar ::alited al al
  set mnu [string trim $mnu "\" "]
  set fname [file join [EM_dir] [file tail $mnu]]
  if {[catch {set fcont [::apave::readTextFile $fname {} 1]}]} {
    return [list]
  }
  set res [list]
  set prname {}
  set mmarks [list S: R: M: S/ R/ M/ SE: RE: ME: SE/ RE/ ME/ SW: RW: MW: SW/ RW/ MW/ I:]
  set ismenu yes
  set isitem no
  foreach line [::apave::textsplit $fcont] {
    set line [string trimleft $line]
    switch $line {
      {[MENU]} {
        set ismenu yes
        set isitem no
        continue
      }
      {[HIDDEN]} - {[OPTIONS]} - {[DATA]} {
        set ismenu [set isitem no]
        continue
      }
    }
    if {!$ismenu} continue
    if {[regexp {^\s*SEP\s*=\s*} $line]} {
      set isitem no
      continue
    }
    if {[regexp {^\s*ITEM\s*=\s*} $line]} {
      set isitem yes
      set itemname [string range $line [string first = $line] end]
      set itemname [string trim $itemname { =}]
      continue
    }
    if {!$isitem} continue
    set origname $itemname
    foreach mark $mmarks {
      if {[regexp "^\s*$mark" $line]} {
        set typ [string index $mark 0]
        if {$typ eq {M}} {
          lassign [regexp -inline {.+m=([^[:blank:]]+)} $line] -> itemname
          if {$itemname ne {} && [file extension $itemname] ne {.em}} {
            set itemname [file rootname $itemname].em  ;# normalized menu filename
          }
        }
        if {$itemname ni {{} -} && $itemname ne $prname} {
          set prname $itemname
          lappend res [list $mnu "$typ-$itemname\n$origname"]
        }
        break
      }
    }
  }
  return $res
}
#_______________________

proc tool::EM_HotKey {idx} {
  # Returns e_menu's hotkeys which numerate menu items.
  #   idx - item's index

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
    lassign $mit mnu item
    if {[string match {M-*} $item]} {
      if {[lsearch -exact -index end $alited::al(EM_STRUCTURE) $item]>-1} {
        continue ;# to avoid infinite cycle
      }
      lassign [split $item \n] item
      set lev [EM_AllStructure1 [string range $item 2 end] [incr lev]]
    } else {
      lappend alited::al(EM_STRUCTURE) [list $lev $mnu [EM_HotKey $i] $item]
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
  $popm add command -label [msgcat::mc {Open bar-menu settings}] \
    -command {alited::pref::_run Emenu_Tab}
  $obPav themePopup $popm
  tk_popup $popm $X $Y
}
#_______________________

proc tool::EM_menuhere {mnu menuargs} {
  # Checks if m=$mnu is present in e_menu's arguments.
  #   mnu - menu name
  #   menuargs - e_menu's arguments

  foreach m [list $mnu.em $mnu.mnu $mnu] {
    if {[lsearch -exact $menuargs m=$m]>-1} {
      return yes
    }
  }
  return no
}
#_______________________

proc tool::EM_command {im} {
  # Gets e_menu command.
  #   im - index of the command in em_inf array

  namespace upvar ::alited::pref em_inf em_inf
  if {[catch {
    lassign $em_inf($im) mnu idx item
    if {$idx eq {-} || [regexp {^[^[:blank:].]+[.](mnu|em): } $item]} {
      # open a menu
      set mnu [string range $item 0 [string first : $item]-1]
      set ex {ex= o=-1}
    } else {
      # call a command
      set ex "ex=[alited::tool::EM_HotKey $idx] SH=1"
    }
    set res "alited::tool::e_menu \"m=$mnu\" $ex"
  } err]} then {
    puts stderr "\nalited error: $err"
    set res {}
  }
  return $res
}
#_______________________

proc tool::EM_optionTF {args} {
  # Prepares TF= option for e_menu.
  #   args - options of e_menu
  # TF= is a name of file that contains a current text's selection.
  # If there is no selection, TF= option is a current file's name.

  set sels [alited::edit::SelectedLines {} yes]
  set wtxt [lindex $sels 0]
  set sel {}
  foreach {l1 l2} [lrange $sels 1 end] {
    append sel [$wtxt get $l1.0 $l2.end] \n
  }
  if {[string length [string trimright $sel]]<2 || \
  (![is_mainmenu $args] && ![EM_menuhere tests $args])} {
    set tmpname [alited::bar::FileName]
  } else {
    set tmpname [alited::TmpFile SELECTION~]
    ::apave::writeTextFile $tmpname sel
  }
  return TF=$tmpname
}
#_______________________

proc tool::SHarg {} {
  # Gets SH= argument of e_menu (main window's geometry).

  namespace upvar ::alited al al
  if {[winfo exists $al(WIN)] && [winfo ismapped $al(WIN)]} {
    return SH=[wm geometry $al(WIN)]
  }
  return {}
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
        catch {exec -- {*}$run} e2
        append e " / $e2"
      }
      alited::info::Put "$mc\"$run\" -> $e"
      update
    }
  }
}

## ________________________ after start _________________________ ##

proc tool::AfterStartDlg {} {
  # Dialogue "Setup/For Start".

  namespace upvar ::alited al al obDl2 obDl2
  set lab [msgcat::mc " Enter commands to be run after starting alited.\n They can be Tcl or executables:"]
  set run [string map [list $alited::EOL \n] $al(afterstart)]
  lassign [$obDl2 input {} $al(MC,afterstart) [list \
    lab [list {} {-pady 8} [list -t $lab]] {} \
    tex "{} {} {-w 80 -h 16 -tabnext {butOK butCANCEL} -afteridle {alited::tool::AfterStartSyntax %w}}" "$run" ] \
    -help {alited::tool::HelpTool %w 1}] res run
  if {$res} {
    set al(afterstart) [string map [list \n $alited::EOL] [string trim $run]]
    alited::ini::SaveIni
  }
}
#_______________________

proc tool::AfterStartSyntax {w} {
  # Highlight "Setup/For Start" text's syntax, at least Tcl part of it.
  #   w - the text's path

  alited::SyntaxHighlight tcl $w [alited::SyntaxColors]
}
#_______________________

proc tool::AfterStart {} {
  # Runs commands after starting alited.

  namespace upvar ::alited al al
  Runs "$al(MC,afterstart) :" $al(afterstart)
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
  if {[string is true -strict $leaf]} {
    alited::CheckSource
    alited::info::ClearRed
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

  if {($runmode eq {} && !$alited::al(prjincons)) || $runmode eq {tkcon}} {
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

  if {![namespace exists ::alited::run]} {
    namespace eval ::alited {
      source [file join $alited::SRCDIR run.tcl]
    }
  }
  alited::run::RunDlg
}
#_______________________

proc tool::ComForced {} {
  # Checks whether a forced command is set.

  return [expr {$::alited::al(comForceCh) && \
    [string trim $::alited::al(comForce)] ni {- {}}}]
}

## ________________________ run/close _________________________ ##

proc tool::is_mainmenu {menuargs} {
  # Checks if e_menu's arguments are for the main menu (run by F4).
  #   menuargs - e_menu's arguments
  # The e_menu's arguments contain ex= or EX= for bar-menu tools only.

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
    if {[EM_menuhere grep $args]} {
      append args { NE=1}  ;# let him search till closing the search dialogue
    }
  }
  if {[EM_menuhere menu $args] && {ex=d} in $args && $al(BACKUP) ne {}} {
    # Differences of a file & its backup: get the backup's name
    set TID [alited::bar::CurrentTabID]
    lassign [alited::edit::BackupDirFileNames $TID] dir fname fname2
    #set fname2 [alited::edit::BackupFileName $fname2 0]
    append args " \"BF=$fname2\""  ;# version before 1st change
  }
  if {{EX=1} ni $args} {
    append args { AL=1}  ;# to read a current file only at "Run me"
  }
  set wtxt [alited::main::CurrentWTXT]
  lassign [::hl_tcl::hl_colors $wtxt] - - clrSTR clrVAR clrCMN clrPROC
  if {$clrSTR eq {lightgreen}} {set clrSTR #90ee90}
  if {![string match #* $clrSTR]} {set clrSTR $clrVAR}
  if {[string match #* $clrSTR]} {
    lassign [alited::edit::InvertBg $clrSTR] fg2
    append args " HC=$clrPROC,$fg2,$clrSTR,$clrCMN"
  }
  if {[set i [lsearch $args {SH=1}]]>-1} {
    set args [lreplace $args $i $i [SHarg]]
  }
  # check options for compatibility
  set itc [lsearch -glob $args tc=*]
  set iee [lsearch -glob $args ee=*]
  if {$itc>-1 && $iee>-1 && $al(prjincons)} {
    set ee [string range [lindex $args $iee] 3 end]
    if {![alited::file::IsTcl $ee]} {
      set args [lreplace $args $itc $itc] ;# not a Tcl file - can't be run with tclsh
    }
  } elseif {$itc==-1 && $iee==-1 && $al(prjincons)} {
    lappend args tc=[alited::Tclexe]  ;# for console - set "path to tclsh" argument
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
  set opts [EM_Options $opts]
  set opts "c=$cs fs=$al(FONTSIZE,std) $opts"
  set th $al(THEME)
  # cs= and fs= can be reset in EM_Options
  foreach o [list {*}$opts] {
    if {[string match c=* $o]}  {set cs [string range $o 2 end]}
    if {[string match th=* $o]} {set th [string range $o 3 end]}
  }
  set thdark [$obPav thDark $th]
  set csdark [$obPav csDark $cs]
  if {$thdark==1 && !$csdark || $thdark==0 && $csdark} {
    set opts "th=default $opts th=default" ;# default theme fits any CS
  }
  alited::Run [file join $::e_menu_dir e_menu.tcl] {*}$opts
}
#_______________________

proc tool::e_menu2 {opts} {
  # Runs e_menu.
  #   opts - options of e_menu
  # The e_menu is run as an internal procedure.

  ::alited::Source_e_menu
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

proc tool::PrepareRunCommand {com fname} {
  # prepares a command to run. The command can include wildcards.
  #   com - command
  #   fname - current file name

  namespace upvar ::alited al al
  set idi Ns7!-=
  set sel [alited::find::GetWordOfText select]
  set com [string map [list %% $idi] $com]
  set com [string map [list $alited::EOL \n %s $sel \
    %f $fname %d [file dirname $fname] %pd $al(prjroot)] $com]
  return [string map [list $idi %] $com]
}
#_______________________

proc tool::_run {{what ""} {runmode ""} args} {
  # Runs e_menu's item of menu.em.
  #   what - the item (by default, "Run me")
  #   runmode - mode of running (in console or in tkcon)

  namespace upvar ::alited al al
  if {[is_emenu]} return
  set opts "EX=$what"
  if {$what eq {}} {
    #  it is 'Run me' e_menu item
    set doit [::apave::extractOptions args -doit 0]
    lassign [alited::ExtTrans] ext istrans from to
    if {!$doit && $istrans} {
      alited::hl_trans::translateLine
      return
    }
    if {!$::alited::DEBUG} {
      if {$al(EM,exec)} {
        set fpid [alited::TmpFile .pid~]
        set pid [::apave::readTextFile $fpid]
      } else {
        ::alited::Source_e_menu ;# e_menu is "internal"
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
    set fnameCur [alited::bar::FileName]
    set com [PrepareRunCommand $al(prjbeforerun) $fnameCur]
    Runs {} $com
    if {[alited::file::IsTcl $fnameCur]} CheckTcl
    if {[ComForced]} {
      set com [PrepareRunCommand $al(comForce) $fnameCur]
      Run_in_e_menu $com $fnameCur
      return
    }
    if {[RunTcl $runmode]} return
    set opts "EX=1 PI=1 [SHarg]"
  }
  e_menu {*}$opts tc=[alited::Tclexe]
}
#_______________________

proc tool::Run_in_e_menu {com {fnameCur ""}} {
  # Runs a command with e_menu application
  #   com - the command
  #   fnameCur - currently edited file

  namespace upvar ::alited al al
  ::alited::Message "$al(MC,run): $com" 3
  set tc {}
  set tw %t
  catch {
    if {[set fname [lindex $com 0]] eq {%f}} {
      set fname $fnameCur
    }
    if {[alited::file::IsTcl $fname]} {
      if {!$al(prjincons)} {
        set tc \
          "tc=[alited::Tclexe] [alited::tool::tkconPath] [alited::tool::tkconOptions]"
        set tw {}
      } else {
        set tw "%t [alited::Tclexe] "
      }
    }
  }
  if {$fnameCur ne {}} {set fnameCur f=[string map [list \\ \\\\] $fnameCur]}
  e_menu ee=$tw[string map [list \" \\\" \\ \\\\] $com] \
    pd=[string map [list \\ \\\\] $al(prjroot)] $tc {*}$fnameCur [SHarg]
}
#_______________________

proc tool::_close {{fname ""}} {
  # Closes e_menu (being an internal procedure) by force.

  catch {destroy .em}
}

# _________________________________ EOF _________________________________ #
