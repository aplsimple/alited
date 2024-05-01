#! /usr/bin/env tclsh

#####################################################################
# Runs commands on files. Bound to editors, file managers etc.
# Scripted by Alex Plotnikov.
# License: MIT.
#####################################################################

# Test cases:

  # run doctest in console to view all debugging "puts"

  #% doctest 1
  #% exec tclsh /home/apl/PG/github/e_menu/e_menu.tcl z5=~ "s0=PROJECT" "x0=EDITOR" "x1=THEME" "x2=SUBJ" b=firefox PD=~/.tke d=~/.tke s1=~/.tke "F=*" f=/home/apl/PG/Tcl-Tk/projects/mulster/mulster.tcl md=~/.tke/plugins/e_menu/menus m=menu.em fs=8 w=30 o=-1 c=0 s=selected g=+0+30
  #> doctest

  #-% doctest 2
  #-% exec lxterminal -e tclsh /home/apl/PG/github/e_menu/e_menu.tcl z5=~ "s0=PROJECT" "x0=EDITOR" "x1=THEME" "x2=SUBJ" b=firefox PD=~/.tke d=~/.tke s1=~/.tke "F=*" md=~/.tke/plugins/e_menu/menus m=side.em o=1 c=4 fs=8 s=selected g=+200+100 &
  # ------ no result is waited here ------
  #-> doctest

#####################################################################
# DEBUG: uncomment the next line to use "bb message1 message2 ..."
# source ~/PG/bb.tcl
#####################################################################

package require Tk
wm withdraw .

namespace eval ::em {
  variable em_version {e_menu 4.4.5}
  variable em_script [file normalize [info script]]
  variable solo [expr {[info exist ::em::executable] || ( \
  [info exist ::argv0] && [file normalize $::argv0] eq $em_script)} ? 1 : 0]
  variable Argv0
  if {$solo} {set Argv0 [file normalize $::argv0]} {set Argv0 [info script]}
  if {[info exist ::em::executable]} {set Argv0 [file dirname $Argv0]}
  variable Argv; if {[info exist ::argv]} {set Argv $::argv} {set Argv [list]}
  variable Argc; if {[info exist ::argc]} {set Argc $::argc} {set Argc 0}
  variable exedir [file normalize [file dirname $Argv0]]
  if {[info exists ::e_menu_dir]} {set exedir $::e_menu_dir}
  variable srcdir [file join $exedir src]
  if {$solo} {
    # remove all possible installed packages that are used by e_menu
    foreach _ {apave baltip} {
      catch {package forget $_}
      catch {namespace delete ::${_}}
    }
  } else {
    append em_version " / [file tail $::em::Argv0]"
  }
}

if {[catch {source [file join $::em::srcdir e_help.tcl]} e]} {
  set ::em::srcdir [file join [pwd] src]
  if {[catch {source [file join $::em::srcdir e_help.tcl]} e2]} {
    puts "$e\n\n$e2\n\nPossibly, an error in e_help.tcl"
    exit
  }
}

# *******************************************************************
# customized block

set ::em::ncolor -2  ;# default color scheme
if {$::em::solo} {set ::em::ncolor 0}

proc ::em::terminalPathes {} {
  # Sets pathes to terminal scripts.
  set ::em::lin_console [file join $::em::srcdir run_pause.sh]  ;# (for Linux)
  set ::em::win_console [file join $::em::srcdir run_pause.bat] ;# (for Windows)
}
::em::terminalPathes

# ________________________ internal trifles _________________________ #

#   M - message
#   Q - question
#   T - terminal's command
#   S - OS command/program
#   IF - conditional execution
#   EXIT - close menu

proc ::M {cme args} {
  if {[regexp {^-centerme } $cme]} {
    set msg {}
  } else {
    set msg "$cme "
    set cme [::em::centerme]
  }
  if {[set ontop [::apave::getOption -ontop {*}$args]] eq {}} {set ontop $::em::ontop}
  foreach a $args {append msg "$a "}
  ::em::emMessage $msg ok Info -ontop $ontop {*}$cme
}
proc ::Q {ttl mes {typ okcancel} {icon warn} {defb OK} args} {
  if {[lsearch -exact $args -centerme]<0} {lappend args {*}[::em::centerme]}
  if {[set ontop [::apave::getOption -ontop {*}$args]] eq {}} {set ontop $::em::ontop}
  return [set ::em::Q [::em::emQuestion $ttl $mes $typ $icon $defb {*}$args -ontop $ontop]]
}
proc ::T {args} {
  set cc {}; foreach c $args {set cc "$cc$c "}
  ::em::shellrun "Nobutt" "S:" shell1 - "&" [string map {"\\n" "\r"} $cc]
}
proc ::S {incomm} {
  foreach comm [split [string map {\\n \n} $incomm] \n] {
    if {[set comm [string trim $comm]] ne {}} {
      set comm [string map {\\\\n \\n} $comm]
      set clst [split $comm]
      set com0 [lindex $clst 0]
      if {$com0 eq "cd"} {
        ::em::VIP comm
      } elseif {[set com1 [::apave::autoexec $com0]] ne {}} {
        exec -ignorestderr -- $com1 {*}[lrange $clst 1 end] &
      } else {
        M Can't find the command: \n$com0
      }
    }
  }
}
proc ::EXIT {} ::em::onExit

# ________________________ em NS _________________________ #

namespace eval ::em {

  proc init_arrays {} {
    uplevel 1 {
      foreach ar {pars itnames bgcolr saveddata \
      ar_s09 ar_u09 ar_i09 arEM ar_macros} {
        if {[array exists ::em::$ar]} {array unset ::em::$ar}
        variable $ar; array set ::em::$ar [list]
      }
    }
  }

# ________________________ em variables _________________________ #

  variable menuttl "$::em::em_version"
  variable thisapp emenuapp
  variable appname $::em::thisapp
  variable fs 9           ;# font size
  variable font_f1 [font config TkSmallCaptionFont]
  variable font_f2 [font config TkDefaultFont]
  variable viewed 40    ;# width of item (in characters)
  variable maxitems 64  ;# maximum of menu.txt items
  variable timeafter 10 ;# interval (in sec.) for updating times/dates
  variable offline no   ;# set yes for offline help
  variable ratiomin 3/5
  variable hotsall \
    {0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,./}
  variable hotkeys $::em::hotsall
  variable workdir {} PD {} pd {} prjname {} PN2 {} prjdirlist [list]
  variable ornament -1 ;# -2 none; -1 top line only; 0 Help/Exec/Shell; 1 +header 2 +prompt; 3 all
  variable inttimer 1 ;# interval to check the timed tasks
  variable b1 0 b2 1 b3 1 b4 1
  variable incwidth 15
  variable wc 0
  variable tf 10 tg 80x24+200+200
  variable om 1

  variable R_mute {*S*}
  variable R_exit {; ::em::onExit 0}
  variable R_ampmute "&$::em::R_mute"
  variable R_ampexit "&$::em::R_exit"
  variable R_ampmuteexit "$::em::R_ampmute$::em::R_exit"
  variable IF_exit 0 ;# no when %IF performed neither %THEN nor %ELSE
  variable begin 1 begtcl 3
  variable begsel $::em::begtcl

  variable editor {}
  variable percent2 {}

  variable seltd {} useltd {} qseltd {} dseltd {} sseltd {} pseltd {}
  variable ontop 0 dotop 0
  variable extraspaces {      } extras yes
  variable ncmd 0  ;# number of the current menu's commands
  variable lasti 1 savelasti -1
  variable minwidth 0 minheight 0

  init_arrays

  variable itviewed 0
  variable geometry {} ischild 0
  variable menufile [list 0] menufilename {} menuoptions {} menudir {}
  variable inherited {}
  variable autorun [list] autohidden [list] commhidden [list 0]
  variable commandA1 [list] commandA2 [list]
  variable commands [list]
  variable pause 0
  variable appN 0
  variable tasks [list] taski [list] ex {} EX {} tc {} ipos 0 TN 0
  variable isep 0
  variable start0 1
  variable prjset 0
  variable skipfocused 0
  variable back 0
  variable conti "\\" lconti 0
  variable filecontent {}
  variable truesel 0
  variable ln 0 cn 0 yn 0 dk {} mp 0
  variable ismenuvars 0 optsFromMenu 1
  variable linuxconsole {} windowsconsole {cmd.exe /c}
  variable insteadCSlist [list]
  variable source_addons yes
  variable empool [list]
  variable hili no
  variable ls {} pk {}
  variable DF kdiff3 BF {}
  variable PI 0 NE 0
  variable th {alt} td {} g1 {} g2 {}
  variable ee {}
  variable SH {} isbaltip yes
}


# ________________________ messages _________________________ #

proc ::em::dialogBox {ttl mes {typ ok} {icon info} {defb OK} args} {
  # own dialog box

  ::eh::dialogBox $ttl $mes $typ $icon $defb {*}[centerme] {*}$args
}
#_______________________

proc ::em::emMessage {mes {typ ok} {ttl "Info"} args} {
  # own message box

  if {[string match ERROR* [string trimleft $mes]]} {set ico err} {set ico info}
  dialogBox $ttl $mes $typ $ico OK {*}$args
}
#_______________________

proc ::em::emQuestion {ttl mes {typ okcancel} {icon warn} {defb OK} args} {
  # own question box

  dialogBox $ttl $mes $typ $icon $defb {*}$args
}

# ________________________ common _________________________ #

proc ::em::nativePathes {pathes} {
  # Gets native names of the pathes' list.

  string map [list \\ \\\\] $pathes
}
#_______________________

proc ::em::nativePath {path} {
  # Gets a native name of the path.

  nativePathes [file nativename $path]
}
#_______________________

proc ::em::addon {func args} {
  # source addons and call a function of these

  if {$::em::source_addons} {
    set ::em::source_addons no
    source [file join $::em::srcdir e_addon.tcl]
  }
  $func {*}$args
}
#_______________________

proc ::em::log {oper} {
  # logging

  if {$::eh::pk eq {}} {
    catch {puts "$::em::menuttl - $oper: $::em::lasti"}
  }
}
#_______________________

proc ::em::initPD {seltd {doit 0}} {
  # get "project (working) directory"

  if {$::em::workdir eq {} || $doit} {
    if {[file isdirectory $seltd]} {
      set ::em::workdir $seltd
    } else {
      set ::em::workdir [pwd]
    }
    preprWU ::em::workdir M/  ;# force converting
    catch {cd $::em::workdir}
  }
  if {[llength $::em::prjdirlist]==0 && [file isfile $seltd]} {
    # when PD is indeed a file with projects list
    set ch [open $seltd]
    chan configure $ch -encoding utf-8
    foreach wd [split [read $ch] \n] {
      set wd [string trimleft $wd]
      if {$wd ne {} && ![string match #* $wd]} {
        lappend ::em::prjdirlist $wd
      }
    }
    close $ch
  }
}
#_______________________

proc ::em::exists {} {
  # checks if the e_menu window exists

  winfo exists .em
}
#_______________________

proc ::em::geometry {} {
  # returns the e_menu's geometry

  wm geometry .em
}

# ________________________ pool _________________________ #

proc ::em::poolCreateItem {} {
  # creates an item for the menu pool

  set poolitem [list]
  foreach v [info vars ::em::*] {
    if {$v ne {::em::empool}} {
      if {[array exists $v]} {
        set t array
        set vval [array get $v]
      } else {
        set t var
        set vval [set $v]
      }
      lappend poolitem [list $t $v $vval]
    }
  }
  return $poolitem
}
#_______________________

proc ::em::poolLevel {{lev 1}} {
  # checks if a menu pool is here

  expr {[llength $::em::empool]>$lev}
}
#_______________________

proc ::em::poolActivateItem {{idx "end"}} {
  # activates a menu pool item

  foreach pit [lindex $::em::empool $idx] {
    lassign $pit t v vval
    if {$t eq "array"} {
      array set $v $vval
    } else {
      set $v $vval
    }
  }
}
#_______________________

proc ::em::poolSet {} {
  # changes a top item in the menu pool (1st record is basic => not changed)

  if {[set ok [poolLevel]]} {
    lset ::em::empool end [poolCreateItem]
  }
  return $ok
}
#_______________________

proc ::em::poolPush {} {
  # adds an item to the menu pool

  if {$::em::solo} return
  lappend ::em::empool [poolCreateItem]
}
#_______________________

proc ::em::poolPull {} {
  # pulls a top item from the menu pool (1st record is basic => not pulled)

  if {[set ok [poolLevel]]} {
    poolActivateItem end
    set ::em::empool [lrange $::em::empool 0 end-1]
  }
  return $ok
}

# ________________________ "is" procs _________________________ #

proc ::em::isChild {} {
  # checks if menu is child

  expr {$::em::ischild || [poolLevel 2]}
}
#_______________________

proc ::em::isheader {} {
  # check if menu should have header

  expr {$::em::ornament in {1 2 3}} ? 1 : 0
}
#_______________________

proc ::em::isheaderShown {} {
  # check if menu header is shown

  expr {[isheader] || $::em::ornament==0} ? 1 : 0
}
#_______________________

proc ::em::isMenuFocused {} {
  # get focused status of menu

 expr {![winfo exists .em.fr.win] || [.em.fr.win cget -bg] ne $::em::clrgrey}
}

# ________________________ theming _________________________ #

proc ::em::insteadCS {{replacingCS "_?_"}} {
  # check a completeness of colors replacing CS (with fg=/bg=)

  if {$replacingCS eq "_?_"} {set replacingCS $::em::insteadCSlist}
  expr {[llength $replacingCS]>=14}
}
#_______________________

proc ::em::themingPave {} {
  # set colors for dialogs

  if {!$::em::solo} {return {}}
  # ALL colors set as arguments of e_menu: fg=, bg=, fE=, bE=, fS=, bS=, cc=, ht=
  if {[insteadCS]} {
    set themecolors [list $::em::clrfg $::em::clrbg $::em::clrfE \
      $::em::clrbE $::em::clrfS $::em::clrbS grey $::em::clrbg \
      $::em::clrcc $::em::clrht $::em::clrhh $::em::fI $::em::bI \
      $::em::fM $::em::bM]
  } else {
    set themecolors [list $::em::clrinaf $::em::clrinab $::em::clrtitf \
      $::em::clrtitb $::em::clractf $::em::clractb grey $::em::clrinab \
      $::em::clrcurs $::em::clrhotk $::em::clrhelp $::em::fI $::em::bI \
      $::em::fM $::em::bM]
  }
  lappend themecolors {*}[lrange [obj csGet] 14 end] ;# rest colors of CS
  obj themeWindow . $themecolors [expr {![insteadCS]}]
  foreach clr $themecolors {append thclr "-theme $clr "}
  return $thclr
}
#_______________________

proc ::em::colorButton {i {fgbg "fg"}} {
  # get an item's color

  if {$fgbg eq "fg"} {
    if {$i > $::em::begsel} {
      set clr $::em::clrinaf ;# common item`
    } else {
      set clr $::em::clrhelp ;# HELP/EXEC/SHELL or submenu
    }
  } else {
    set clr $::em::clrinab
  }
  return $clr
}
#_______________________

proc ::em::unsetdefaultcolors {} {
  # clear off default colors

  foreach c {fg bg fE bE fS bS fI bI ht hh cc gr fM bM fW bW} {
    unset -nocomplain ::em::clr$c
  }
}
#_______________________

proc ::em::initcolorscheme {{nothemed no}} {
  # set default colors from color scheme

  if {$nothemed} unsetdefaultcolors
  set clrs [list clrtitf clrinaf clrtitb clrinab clrhelp \
    clractb clractf clrcurs clrgrey clrhotk fI bI fM bM fW bW]
  lassign [obj csGet $::em::ncolor] {*}$clrs
  foreach clr $clrs {set ::em::$clr [set $clr]}
  obj basicFontSize $::em::fs
  # set real colors, based on fg=, bg=, fS=, bS=, gr= arguments of e_menu
  if {[info exist ::em::clrfg]} {set ::em::clrinaf $::em::clrfg}
  if {[info exist ::em::clrbg]} {set ::em::clrinab $::em::clrbg}
  if {[info exist ::em::clrfE]} {set ::em::clrtitf $::em::clrfE}
  if {[info exist ::em::clrbE]} {set ::em::clrtitb $::em::clrbE}
  if {[info exist ::em::clrfS]} {set ::em::clractf $::em::clrfS}
  if {[info exist ::em::clrbS]} {set ::em::clractb $::em::clrbS}
  if {[info exist ::em::clrhh]} {set ::em::clrhelp $::em::clrhh}
  if {[info exist ::em::clrgr]} {set ::em::clrgrey $::em::clrgr}
  if {[info exist ::em::clrcc]} {set ::em::clrcurs $::em::clrcc}
  if {[info exist ::em::clrht]} {set ::em::clrhotk $::em::clrht}
  if {[info exist ::em::clrfI]} {set ::em::fI $::em::clrfI}
  if {[info exist ::em::clrbI]} {set ::em::bI $::em::clrbI}
  if {[info exist ::em::clrfM]} {set ::em::fM $::em::clrfM}
  if {[info exist ::em::clrbM]} {set ::em::bM $::em::clrbM}
  if {[winfo exist .em.fr.win]} {
    .em configure -bg [.em.fr.win cget -bg]
  } else {
    . configure -bg $::em::clrinab
  }
}
#_______________________

proc ::em::initdefaultcolors {} {
  # set default colors if not set by call of e_menu

  if {$::em::ncolor>=$::apave::_CS_(MINCS) && $::em::ncolor<=[::apave::cs_Max]} {
    lassign [obj csSet $::em::ncolor] \
      ::em::clrfg ::em::clrbg ::em::clrfE ::em::clrbE \
      ::em::clrfS ::em::clrbS ::em::clrhh ::em::clrgr ::em::clrcc
  }
}

# ________________________ buttons _________________________ #

proc ::em::forButtons {proc} {
  # 'proc' all buttons

  set ::em::isep 0
  for {set j $::em::begin} {$j < $::em::ncmd} {incr j} {
    uplevel 1 "set i $j; set b .em.fr.win.fr$j.butt; $proc"
  }
}
#_______________________

proc ::em::nextButton {i} {
  # get next button index

  if {$i>=$::em::ncmd} {set i $::em::begin}
  if {$i<$::em::begin} {set i [expr {$::em::ncmd-1}]}
  return $i
}
#_______________________

proc ::em::focusButton {i {doit no}} {
  # put i-th button in focus

  set last $::em::lasti
  set i [nextButton $i]
  if {![winfo exists .em.fr.win.fr$i.butt]} return
  if {![isMenuFocused]} {
    set fg [.em.fr.win.fr$i.butt cget -fg]
    set bg $::em::clrgrey
  } else {
    if {$::em::lasti >= $::em::begin && $::em::lasti < $::em::ncmd} {
      if {[winfo exists .em.fr.win.fr$::em::lasti.arr]} {
        .em.fr.win.fr$::em::lasti.arr configure -bg [colorButton $::em::lasti bg]
      }
      if {[winfo exists .em.fr.win.fr$::em::lasti.butt]} {
        .em.fr.win.fr$::em::lasti.butt configure \
          -bg [colorButton $::em::lasti bg] -fg [colorButton $::em::lasti]
      }
    }
    set fg $::em::fI
    set bg $::em::bI
  }
  .em.fr.win.fr$i.butt configure -fg $fg -bg $bg \
    -activeforeground $fg -activebackground $bg
  if {[winfo exists .em.fr.win.fr$i.arr]} {
    .em.fr.win.fr$i.arr configure -bg $bg \
      -activeforeground $fg -activebackground $bg
  }
  set ::em::lasti $i
  if {$doit} {
    focus -force .em.fr.win.fr$i.butt
  } else {
    focus .em.fr.win.fr$i.butt
  }
}
#_______________________

proc ::em::mouseButton {i} {
  # move mouse to i-th button

  focusButton $i
  set i [nextButton $i]
  if {$::em::isbaltip && $::em::mp && [winfo exists .em.fr.win.fr$i.butt]} {
    lassign [split [winfo geom .em.fr.win] +] -> x1 y1
    lassign [split [winfo geom .em.fr.win.fr$i] +x] w h x2 y2
    if {$::em::solo || $::em::mp} {
      event generate .em <Motion> -warp 1 -x [expr {$x1+$x2+int($w/1.5)}] \
      -y [expr {$y1+$y2+int($h/1.2)}]
    }
  }
}
#_______________________

proc ::em::updateItname {it inc {pr ""}} {
  # update item name (with inc)

  catch {
    if {$it > $::em::begsel} {
      set b .em.fr.win.fr$it.butt
      if {[$b cget -image] eq {}} {
        if {$::em::ornament > 1} {
          set ornam [$b cget -text]
          set ornam [string range $ornam 0 [string first : $ornam]]
        } else {set ornam {}}
        set itname $::em::itnames($it)
        if {$pr ne {}} {{*}$pr}
        prepr09 itname ::em::ar_i09 i $inc  ;# incr N of runs
        preprAbra itname 0
        set comtitle [subst -nobackslashes -nocommands $ornam$itname]
        $b configure -text $comtitle
        catch {::baltip tip $b $comtitle}
      }
    }
  }
}
#_______________________

proc ::em::updateButtons {{pr ""}} {
  # update all buttons

  forButtons {updateItname $i 0 $pr}
}
#_______________________

proc ::em::updateButtonNN {} {
  # update all buttons' names

  updateButtons {preprPN itname}
}
#_______________________

proc ::em::updateButtonDT {} {
  # update all buttons' date/time

  updateButtonNN
  repeateUpdateButtons  ;# and re-run itself
}
#_______________________

proc ::em::repeateUpdateButtons {} {
  # update buttons with time/date

  set aft ::em::aft_repeate_update_buttons
  catch {after cancel $aft}
  set $aft [after [expr {$::em::timeafter * 1000}] ::em::updateButtonDT]
}
#_______________________

proc ::em::silentMode {amp} {
  # get a calling mode

  set silent [string first $::em::R_mute " $amp"]
  if {$silent > 0} {
    set amp [string map [list $::em::R_mute {}] $amp]
  }
  list $amp $silent
}
#_______________________

proc ::em::help_button {help} {
  # procs for HELP/EXEC/SHELL/MENU items run by button pressing

  ::eh::browse [::eh::html $help $::em::offline]
  onExit 0
}
#_______________________

proc ::em::run_button {typ s1 {amp ""}} {
  # handle button with "R" (run executable)

  run $typ $s1 $amp button
  log Run
}
#_______________________

proc ::em::shell_button {typ s1 {amp ""}} {
  # handle button with "S" (shell)

  shell $typ $s1 $amp button
  log Shell
}
#_______________________

proc ::em::callmenu_button {typ s1 {amp ""}} {
  # handle button with "M" (menu)

  callmenu $typ $s1 $amp button
}
#_______________________

proc ::em::doNot {s1} {
  # query for EXEC & SHELL items

  set res [::Q ATTENTION! $::em::pars($s1) okcancel warn CANCEL \
    -ro 0 -text 1 -h {5 10} -w {60 80} -head \
    "\nYou are going to execute the command(s) which can be dangerous:\n"]
  if {[string is false -strict [lindex [split $res] 0]]} {return {}}
  set i [string first { } $res 2]
  set res [string range $res $i end]
  set res [string map [list \" \\\" \\ \\\\] $res]
  return $res
}
#_______________________

proc ::em::runHead_button {typ s1 {amp ""}} {
  # handle "EXEC" header action

  if {[set res [doNot $s1]] ne {}} {
    run0 $res & -1
    if {!$::em::ontop} onExit
  }
}
#_______________________

proc ::em::shellHead_button {typ s1 {amp ""}} {
  # handle "SHELL" header action

  if {[set res [doNot $s1]] ne {}} {
    shell0 $res &
    if {!$::em::ontop} onExit
  }
}
#_______________________

proc ::em::prButton {ib args} {
  # run a command after keypressing

  focusButton $ib  ;# to see the selected
  set comm $args
  if {[set i [string first { } $comm]] > 2} {
    set comm [string range $comm 0 $i-1]_button\ [string range $comm $i end]
  }
  {*}$comm
  if {[string first ? [set txt [.em.fr.win.fr$ib.butt cget -text]]]>-1 ||
  [string match *... [string trimright $txt]]} {
    rereadMenu $::em::lasti  ;# after dialogs, the menu may be changed
  } else {
    repaintForWindows
  }
}

# ________________________ read/write menu file _________________________ #

proc ::em::readMenuFile {} {
  # read the menu file

  set ch [open $::em::menufilename]
  chan configure $ch -encoding utf-8
  set menudata [read $ch]
  set menudata [textsplit [string trimright $menudata]]
  close $ch
  return $menudata
}
#_______________________

proc ::em::writeMenuFile {menudata} {
  # write the menu file

  ::eh::write_file_untouched $::em::menufilename $menudata
}
#_______________________

proc ::em::saveOptions {{setopt "in="} {setval ""}} {
  # save options in the menu file (by default - current selected item)

  if {$setopt eq {in=}} {
    if {$::em::savelasti<0} return
    set setval $::em::lasti.$::em::begsel
  }
  set setval $setopt$setval
  set menudata [readMenuFile]
  set opt [set i [set ifnd1 [set ifndo 0]]]
  foreach line $menudata {
    if {$line eq {[OPTIONS]}} {
      set opt 1
      set ifndo [expr {$i+1}]
    } elseif {$opt} {
      if {[string match ${setopt}* $line]} {
        set ifnd1 $i
        break
      }
    } elseif {$line eq {[MENU]} || $line eq {[HIDDEN]}} {
      set opt 0
    }
    incr i
  }
  if {$ifnd1} {
    set menudata [lreplace $menudata $ifnd1 $ifnd1 $setval]
  } else {
    if {$ifndo} {
      set menudata [linsert $menudata $ifndo $setval]
    } else {
      lappend menudata \n {[OPTIONS]}
      lappend menudata $setval
    }
  }
  writeMenuFile $menudata
}

# ________________________ terminals _________________________ #

proc ::em::xterm {sel amp {term ""}} {
  # call command in xterm
  # See also: https://wiki.archlinux.org/index.php/Xterm

  if {$term eq {}} {set term [auto_execok xterm]}
  if {[set lang [::eh::get_language]] ne {}} {set lang "-fa $lang"}
  if {[set _ [string first { } $sel]]<0} {set _ xterm} {set _ [string range $sel 0 $_]}
  set sel "### \033\[32;1mTo copy a text, select it and press Shift+PrtSc\033\[m ###\\n
    \\n[::eh::escape_quotes $sel]"
  set term "$::em::lin_console $sel $amp"
  set tpars [string range $::em::linuxconsole 6 end]
  set ::em::_tmp xterm
  foreach {o v s} {-fs fs tf -geometry geo tg -title ttl _tmp} {
    if {[string first $o $tpars]>=0} {set $v {}} {set $v "$o [set ::em::$s]"}
  }
  execcom {*}$term {*}$lang {*}$fs {*}$geo {*}$ttl {*}$tpars -e {*}$term
}
#_______________________

proc ::em::term {sel amp {inconsole no}} {
  # call command in terminal

  if {[string match {xterm *} "$::em::linuxconsole "]} {
    xterm $sel $amp
  } else {
    set sel2 [string map {\\n \n} $sel]
    if {[string match {qterminal *} "$::em::linuxconsole "]} {
      # bad style, for qterminal only
      set sel {}
      foreach l [split $sel2 \n] {
        set l2 [string trimleft $l]
        if {[string match #* $l2] || $l2 eq {}} continue
        if {[string match {if *} $l2] || [string match then $l2] || \
        [string match else $l2] || [string match {while *} $l2] || \
        [string match {for *} $l2]} {
          append sel " $l "
        } else {
          append sel " $l ; "
        }
      }
    } else {
      set sel {}
      foreach l [split $sel2 \n] {
        set l2 [string trimleft $l]
        if {[string match #* $l2] || $l2 eq {}} continue
        append sel " $l \\n"
      }
    }
    set term "$::em::lin_console $sel $amp"
    if {$inconsole} {
      execWithPID $::em::linuxconsole\ -e\ $term
    } else {
      execcom {*}$::em::linuxconsole -e {*}$term
    }
  }
}

# ________________________ execute commands _________________________ #

proc ::em::VIP {refcmd} {
  # VIP commands need internal processing

  upvar $refcmd cmd
  if {[string first %# $cmd] == 0} {
    # writeable command:
    # get (possibly) saved version of the command
    if {[set cmd [addon writeableCmd $cmd]] eq {}} {
      return yes ;# here 'cancelled' means 'processed'
    }
    return no
  }
  if {[string first {%P } $cmd] == 0} {
      # prepare the command for processing
    set cmd [string range $cmd 3 end]
    set cmd [string map {"\\n" "\n"} $cmd]
    if {[string first "\$::env\(" $cmd]>=0} {
      catch {set cmd [subst $cmd]}
    }
  }
  set cd [string range $cmd 0 2]
  if {([::iswindows] && [string toupper $cd] eq "CD ") || $cd eq "cd "} {
    set ::em::IF_exit 0
    preprWU cmd M/  ;# force converting
    if {[set cd [string trim [string range $cmd 3 end]]] ne "."} {
      catch {set cd [subst -nobackslashes -nocommands $cd]}
      catch {cd $cd}
    }
    return yes
  }
  if {$cmd in {%E %e} || $cd in {"%E " "%e "}} {
    return [addon edit [string range $cmd 3 end]] ;# editor
  }
  return no
}
#_______________________

proc ::em::pAssign {refsel {trl 1}} {
  # parse modes of run

  upvar $refsel sel
  set retlist [list]
  set tmp [string trimleft $sel]
  set qpos [expr {$::em::ornament>1 ? [string first : $tmp]+1 : 0}]
  if {[string first ? $tmp] == $qpos} {   ;#?...? sets modes of run
    set prom [string range $tmp 0 [expr {$qpos-1}]]
    set sel [string range $tmp $qpos end]
    lassign {{} 0} el qac
    for {set i 1}  {$i < [string len $sel]} {incr i} {
      if {[set c [string range $sel $i $i]] eq {?} || $c eq { }} {
        if {$c eq { }} {
          set sel [string range $sel $i+1 end]
          if {$trl} {set sel [string trimleft $sel]}
          lappend retlist -1
          set sel $prom$sel
          break
        } else {
          lappend retlist $el
          lassign {{} 1} el qac
        }
      } else {
        append el $c
      }
    }
  }
  return $retlist
}
#_______________________

proc ::em::pID {{pID -1}} {
  # set/get pID of last exec

  if {$pID>-1} {set ::eh::pID $pID}
  return $::eh::pID
}
#_______________________

proc ::em::Tclexe {{tclok "tclsh"}} {
  # tclsh/tclkit executable
  # for better performance, e_menu can be called with
  # "tc=full path to tclsh" option, e.g. tc=/usr/local/bin/tclsh
  # : in this case it will not search tclsh throughout the system

  if {[set tclexe $::em::tc] eq {}} {
    set tclexe [auto_execok $tclok]
  } elseif {$::em::tc in {tclsh wish}} {
    set tclexe [::apave::autoexec $::em::tc .exe]
  }
  if {$tclexe eq {}} {
    set tclexe [info nameofexecutable]
    if {$tclexe eq {}} {
      emMessage "ERROR:\n\nTcl/Tk executable not found."
      exit
    }
  }
  return $tclexe
}
#_______________________

proc ::em::execWithPID {com} {
  # exec with getting process ID

  set ::eh::pID [pid [open |[list {*}$com]]]
  if {$::em::solo} {
    writeTextFile [file join $::em::menudir .pid~] ::eh::pID
  }
}
#_______________________

proc ::em::execcom {args} {
  # exec for ex= parameter

  if {$::em::EX eq {} || [string is false $::em::PI]} {
    exec -ignorestderr -- {*}$args
  } else {
    catch {execWithPID [string trim $args &]}
  }
}

#_______________________

proc ::em::shell0 {sel {amp {}} {silent -1}} {
  # call command in shell

  set ret yes
  catch {set sel [subst -nobackslashes -nocommands $sel]}
  checkForShell sel
  if {[string first {%IF } $sel] == 0} {
    if {![addon IF $sel sel]} {return no}
  }
  catch {
    # only for Tcl files: run them by the Tcl executable (that runs e_menu)
    lassign $sel flname
    if {[string tolower [file extension $flname]] eq {.tcl}} {
      set sel [Tclexe]\ $sel
    }
  }
  if {[lindex [set _ [checkForWilds sel]] 0]} {
    return [lindex $_ 1]
  } elseif {[runTclCode $sel]} {
    # processed
  } elseif {[::iswindows]} {
    if {[string trim $sel] eq {}} {return yes}
    set composite "$::em::win_console $sel $amp"
    catch {
      # here we construct new .bat containing all lines of the command
      set lines "@echo off\n"
      append lines [string map {"\\n" "\n"} $sel] "\npause"
      set cho [open "$::em::win_console.bat" w]
      puts $cho $lines
      close $cho
      set composite "$::em::win_console.bat $amp"
    }
    if {[catch {exec -- {*}[auto_execok start] \
      {*}$::em::windowsconsole {*}$composite} e]} {
      if {$silent < 0} {
        set ret no
      }
    }
  } else {
    if {[string trim $sel] eq {}} {return yes}
    if {$::em::linuxconsole ne {}} {
      term $sel $amp
    } elseif {[set term [auto_execok lxterminal]] ne {}} {
      set sel [string map [list "\""  "\\\""] $sel]
      set composite "$::em::lin_console $sel $amp"
      exec -ignorestderr -- {*}$term --geometry=$::em::tg -e {*}$composite
    } elseif {[set term [auto_execok xterm]] ne {}} {
      xterm $sel $amp $term
    } else {
      set ret no
      set e "Not found lxterminal nor xterm.\nInstall any."
    }
  }
  if {$silent < 0 && !$ret} {
    emMessage "ERROR of running\n\n$sel\n\n$e"
  }
  return $ret
}
#_______________________

proc ::em::runTclCode {sel {dosubst no}} {
  # run a code of Tcl

  if {[string first %C $sel] == 0} {
    if {[catch {
      if {$dosubst} {
        preprPN sel
        catch {set sel [subst -nobackslashes -nocommands $sel]}
      }
      set sel [preprHD [string range $sel 3 end]]
      if {[string match "eval *" $sel]} {
        {*}$sel
      } else {
        eval $sel
      }
    } e]} {
      emMessage "ERROR of running\n\n$sel\n\n$e"
      return no
    }
    return yes
  }
  return no
}
#_______________________

proc ::em::execom {comm} {
  # exec a command

  set argm [lrange $comm 1 end]
  set comm1 [lindex $comm 0]
  if {$comm1 eq {%O}} {
    openDoc $argm
  } elseif {![string match #* $comm1]} {
    if {[lindex $argm end-1] eq {>}} {
      # redirecting results to a file: do it here (in wish & tclkit.exe not working)
      set fname [lindex $argm end]     ;# file name
      set com2 [lrange $argm 0 end-2]  ;# command without "> file name"
      if {[lindex $com2 0] in {/c -nologo}} {
        set com2 [lrange $com2 1 end]  ;# Windows: cmd.exe/powershell.exe... command
      } else {
        set com2 [linsert $com2 0 $comm1] ;# Linux: command
      }
      if {![catch {set res [exec -- {*}$com2]}]} {
        if {[writeTextFile $fname res]} {
          return {}
        }
      }
    }
    set comm2 [::apave::autoexec $comm1]
    if {[catch {exec -- $comm2 {*}$argm} e]} {
      if {$comm2 eq {}} {
        return "couldn't execute \"$comm1\": no such file or directory"
      }
      return $e
    }
  }
  return {}
}
#_______________________

proc ::em::run {typ s1 {amp ""} {from ""}} {
  # run "seltd" as a command

  saveOptions
  shellrun $from $typ run1 $s1 $amp
}
#_______________________

proc ::em::run0 {sel amp silent} {
  # run a program of sel

  if {![VIP sel]} {
    if {[lindex [set _ [checkForWilds sel]] 0]} {
      return [lindex $_ 1]
    } elseif {[runTclCode $sel]} {
      # processed already
    } elseif {[string first {%I } $sel] == 0} {
      set sel [preprHD $sel]
      return [addon input $sel]
    } elseif {[string first {%S } $sel] == 0} {
      S [string range $sel 3 end]
    } elseif {[string first {%IF } $sel] == 0} {
      return [addon IF $sel]
    } elseif {[checkForShell sel]} {
      shell0 $sel $amp $silent
    } else {
      set comm "$sel $amp"
      if {[::iswindows]} {
        set comm $::em::windowsconsole\ $comm
      }
      catch {set comm [subst -nobackslashes -nocommands $comm]}
      if {[set e [execom $comm]] ne {}} {
        if {$silent < 0} {
          emMessage "ERROR of running\n\n$sel\n\n$e"
          return no
        }
      }
    }
  }
  return yes
}
#_______________________

proc ::em::run1 {typ sel amp silent} {
  # run a program of menu item

  preprProg sel $typ  ;# prep
  preprAbra sel 0
  catch {set sel [subst -nobackslashes -nocommands $sel]}
  run0 $sel $amp $silent
}
#_______________________

proc ::em::shell {typ s1 {amp ""} {from ""}} {
  # shell "seltd" as a command

  saveOptions
  shellrun $from $typ shell1 $s1 $amp
}
#_______________________

proc ::em::shell1 {typ sel amp silent} {
  # call command in shell

  preprProg sel $typ  ;# prep
  preprAbra sel 0
  if {[VIP sel]} {return yes}
  if {[::iswindows] || $amp ne {&}} {focusWin no}
  set ret [shell0 $sel $amp $silent]
  if {[::iswindows] || $amp ne {&}} {focusWin yes}
  return $ret
}
#_______________________

proc ::em::SelectItem {{ib {}}} {
  # select item from a menu

  if {$ib eq {}} {set ib $::em::lasti}
  set butt .em.fr.win.fr$ib.butt
  if {$::eh::pk ne {} && [winfo exists $butt]} {
    set ::eh::retval [list $::em::menufilename $ib [string trim [$butt cget -text]]]
    onExit 1
  }
}
#_______________________

proc ::em::ShellRun {from typ c1 s1 amp inpsel} {
  # repeat run/shell once in a cycle

  set cpwd [pwd]
  set inc 1
  set doexit 0
  foreach n [array names ::em::saveddata] {
    # if a dialogue saved its variables, initialize them the same way as at start
    # (see ::em::initMenuVars and ::em::input)
    set $n [string map [list \\n \n \\ \\\\] $::em::saveddata($n)]
    unset ::em::saveddata($n)
  }
  if {$inpsel eq {}} {
    set inpsel $::em::pars($s1)
    lassign [silentMode $amp] amp silent  ;# silentMode - in 1st line
    lassign [pAssign inpsel] p1 p2
    if {$p1 ne {}} {
      if {$p2 eq {}} {
        set silent $p1
      } else {
        if {![addon setTask $from $p1 $typ $c1 $inpsel]} {return}
        set silent $p2
      }
    }
  } else {
    if {$amp eq {noamp}} {
      lassign {{} -1} amp silent
    } else {
      lassign {{&} -1} amp silent
    }
  }
  foreach seltd [split $inpsel \n] {
    set doexit 0
    if {[set r [string first \r $seltd]] > 0} {
      lassign [split $seltd \r] runp seltd
      if {[string first ::em::run $runp] != -1} {
        set c1 run1
      } else {
        set c1 shell1
      }
      if {[string last $::em::R_ampmute $runp]>0 ||
          [string last $::em::R_ampexit $runp]>0} {set amp &} {set amp {}}
      if {[string last $::em::R_exit $runp]>0} {set doexit 1}
    }
    prepr09 seltd ::em::ar_i09 i   ;# set N of runs in command
    set seltd [preprHD $seltd]
    set ::em::IF_exit 1
    if {![$c1 $typ $seltd $amp $silent] || $doexit} {
      if {$::em::IF_exit} {
        set inc 0  ;# unsuccessful run
        break
      }
    }
  }
  if {$doexit > 0} {::em::onExit 0}
  if {$inc} {                       ;# all buttons texts may need to update
    updateItname $::em::lasti $inc  ;# because all may include %s1, %s2...
  }
  updateButtonNN
  update idletasks
  catch {cd $cpwd}  ;# may be deleted by commands
}
#_______________________

proc ::em::shellrun {from typ c1 s1 amp {inpsel ""}} {
  # run/shell

  set ib [string range $s1 1 end]
  set butt .em.fr.win.fr$ib.butt
  if {$::eh::pk ne {} && [winfo exists $butt]} {
    # e_menu was called to pick an item
    SelectItem $ib
    return
  }
  # repeat input dialogues: set by ::em::NE in .em or by NE=1 argument of e_menu
  set ::em::inputResult [set ::em::inputStay 0]
  while {1} {
    ShellRun $from $typ $c1 $s1 $amp $inpsel
    if {!$::em::inputStay && (!$::em::inputResult || !$::em::NE)} break
  }
}

# ________________________ call submenu _________________________ #

proc ::em::beforeCallMenu {pars} {
  # run commands before a submenu

  set cpwd [pwd]
  set menupos [string last \n::em::callmenu $pars]
  if {$menupos>0} {  ;# there are previous commands (in M: ... M: lines)
    set commands [string range $pars 0 $menupos-1]
    foreach com [split $commands \r] {
      set com [lindex [split $com \n] 0]
      if {$com ne {}} {
        if {![run0 $com {} 0]} {
          set pars {}
          break
        }
      }
    }
    set pars [string range $pars [string last \r $pars]+1 end]
  }
  catch {cd $cpwd}  ;# may be deleted by commands
  return $pars
}
#_______________________

proc ::em::callmenu {typ s1 {amp ""} {from ""}} {
  # call a submenu

  saveOptions
  set pars [beforeCallMenu $::em::pars($s1)]
  if {$pars eq {}} return
  set noME [expr {[string range $typ 0 1] ne {ME}}]
  set stay [expr {$noME || $::em::ontop}]
  set pars "ch=$stay $::em::inherited a= a0= a1= a2= ah= n= pa=0 $pars"
  set pars [string map [list "b=%b" "b=$::eh::my_browser"] $pars]
  if {$::em::ontop} {
    append pars { t=1}    ;# "ontop" means also "all menus stay on"
  } elseif {!$::em::solo} {
    set stay [expr {$::em::remain || ($noME && [poolLevel])}]
  }
  if {[::apave::cs_Max] > [::apave::cs_MaxBasic]} {
    append pars " \"cs=[lindex $::apave::_CS_(ALL) [::apave::cs_Max]]\""
  }
  set geo [wm geometry .em]
  set geo [string range $geo [string first + $geo] end]
  # shift the new menu if it's shown above the current one
  if {$::em::solo && ($noME || $::em::ontop)} {
    lassign [split $geo +] -> x y
    set geo +[expr {20+$x}]+[expr {30+$y}]
  }
  if {$::em::ex eq {}} {set pars "g=$geo $pars"}
  append pars { ex= EX= PI=0 AL=1}
  prepr1 pars in [string range $s1 1 end]  ;# %in is menu's index
  set sel "\"$::em::Argv0\""
  preprWU sel M/  ;# force converting
  if {$::em::solo} {
    repaintForWindows  ;# get rid of troubles in Windows XP
    catch {exec -- [Tclexe] {*}$sel {*}$pars $amp}
    if {$amp eq {}} {
      rereadMenu $::em::lasti  ;# changes possible
    }
  } else {
    poolSet
    set ::em::Argv [list {*}$pars]
    set ::em::Argc [llength $::em::Argv]
    if {!$stay} {::em::poolSet}
    poolPush
    set ::em::em_win_var 1
  }
}

# ________________________ wildcards _________________________ #

proc ::em::checkForWilds {rsel} {
  # replace first %b with browser pathname

  upvar $rsel sel
  switch -glob -nocase -- $sel {
    {%B *} {
      set sel [string trim [string range $sel 3 end] "\" "]
      if {![catch {::eh::browse $sel} e]} {
        return [list yes yes]
      }
    }
    {%Q *} {
      catch {set sel [subst -nobackslashes -nocommands $sel]}
      lassign $sel Q ttl mes typ icon defb
      set argums [lrange $sel 6 end]
      if {$typ eq {}} {set typ okcancel}
      if {$icon eq {}} {set icon warn}
      if {$defb eq {}} {set defb OK}
      if {[string first {-centerme } $argums]>=0} {
        set cme {}
      } else {
        if {[string match {%q *} $sel]} {
          set cme [centerme]
        } else {
          set cme {-centerme 1}
        }
      }
      if {![catch {Q $ttl $mes $typ $icon $defb {*}$argums {*}$cme} e]} {
        if {[string is true $e]} saveMenuVars
        return [list yes $e]
      }
    }
    {%M *} {
      if {![regexp {^%M -centerme } $sel]} {
        set cme [centerme]
      }
      catch {set sel [subst -nobackslashes -nocommands $sel]}
      set sel "M {$cme} [string range $sel 3 end]"
      if {![catch {{*}$sel} e]} {
        return [list yes yes]
      }
    {%U *} {
      return yes ;# not used now
      }
    }
  }
  return no
}
#_______________________

proc ::em::checkForShell {rsel} {
  # replace first %t with terminal pathname

  upvar $rsel sel
  set res no
  if {[string first {%t } $sel] == 0 || \
      [string first {%T } $sel] == 0 } {
    set sel "[string range $sel 3 end]"
    set res yes
  }
  set sel [string trimleft $sel]
  set i [string first { } $sel]
  set tclok [string range $sel 0 $i-1]
  if {$tclok in {tclsh wish}} {
    set sel [Tclexe $tclok][string range $sel $i end]
  }
  return $res
}
#_______________________

proc ::em::prepareWilds {per2} {
  if {[llength [array names ::em::arEM d]] != 1} { ;# it's obsolete
    set ::em::arEM(d) $::em::workdir             ;# (using %d as %PD)
  }
  if {$per2} {set ::em::percent2 %}    ;# reset the wild percent to %
  foreach _ {u p q d s} {preprPN ::em::${_}seltd}
  set ::em::useltd [string map {{ } _} $::em::useltd]
  set ::em::pseltd [::eh::escape_links $::em::pseltd]
  set ::em::qseltd [::eh::escape_quotes $::em::qseltd]
  set ::em::dseltd [::eh::delete_specsyms $::em::dseltd]
  set ::em::sseltd [string trim $::em::sseltd]
}
#_______________________

proc ::em::prepareMainWilds {{doit no}} {
  # initialize main wildcards

  set from [file dirname $::em::arEM(f)]
  foreach {c attr} {d nativename D tail F tail e rootname x extension} {
    if {![info exists ::em::arEM($c)] || $::em::arEM($c) eq {} \
    || $doit} {
      set ::em::arEM($c) [file $attr $from]
    }
    if {$c eq {D}} {set from [file tail $::em::arEM(f)]}
  }
  set ::em::arEM(F_) [::eh::get_underlined_name $::em::arEM(F)]
  if {$::em::pd eq {}} {set ::em::pd $::em::arEM(d)}
}
#_______________________

proc ::em::readFileF {} {
  # get contents of %f file (supposedly, there can be only one "%f" value)

  if {[llength $::em::filecontent]==0 && [info exists ::em::arEM(f)]} {
    if {[file isfile $::em::arEM(f)] && [file size $::em::arEM(f)]<1048576} {
      set ::em::filecontent [readTextFile $::em::arEM(f)]
      set ::em::filecontent [textsplit $::em::filecontent]
    }
  }
  if {[llength $::em::filecontent] < 2} {
    set ::em::filecontent - ;# no content; don't read it again
    return 0
  }
  llength $::em::filecontent
}
#_______________________

proc ::em::getPD {{lookdir ""} {lookP2 1}} {
  # get working (project's) dir

  if {$lookdir eq {}} {
    set ldir $::em::workdir
  } else {
    set ldir $lookdir  ;# this mode - to get PN2 from $lookdir
  }
  set lP2 {}
  if {[llength $::em::prjdirlist]>0} {
    # workdir got from a current file (if not passed, got a current dir)
    if {$lookdir eq {}} {
      if {[catch {set ldir $::em::arEM(d)}] && \
          [catch {set ldir [file dirname $::em::arEM(f)]}]} {
        set ldir [pwd]
      }
    }
    set Ldir [string toupper $ldir]
    foreach wd $::em::prjdirlist {
      lassign $wd wd p2  ;# second item may set %P2
      if {[string first "[string toupper $wd]/" "$Ldir/"]==0 ||
      [string first "[string toupper $wd]\\" "$Ldir\\"]==0} {
        set ldir $wd
        set lP2 $p2
        break
      }
    }
  }
  if {![file isdirectory $ldir]} {set ldir [pwd]}
  if {$lP2 eq {}} {set lP2 $ldir}
  set lP2 [::eh::get_underlined_name [file tail $lP2]]
  if {$lookdir eq {}} {
    if {$::em::prjset != 2} {
      set ::em::prjname [set ::em::PN2 $lP2]
    }
    set ::em::workdir $ldir
  } else {
    if {$lookP2} {set ldir $lP2}
  }
  file nativename $ldir
}
#_______________________

proc ::em::getPDU {} {
  # get %PD underlined

  ::eh::get_underlined_name $::em::workdir
}
#_______________________

proc ::em::getARE {} {
  # get contents of #ARGS..: or #RUNF..: line

  if {$::em::truesel && $::em::seltd ne {}} {
    ;# %s is preferrable for ARGS (ts= rules)
    return [list [string map {\n \\n \" \\\"} $::em::seltd]]
  }
  if {[lsearch -exact $::em::Argv AL=1]>-1} {
    # AL=1 option disables checking a current file for ARGS/RUNF/EXEC comments
    return {}
  }
  set res {}
  if {[readFileF]} {
    if {[info exists ::em::arEM(AR,$::em::arEM(f))]} {
      return $::em::arEM(AR,$::em::arEM(f)) ;# already got
    }
    set ar {^[[:space:]#/*]*#[ ]?ARGS[0-9]?:[ ]*(.*)}
    set rf {^[[:space:]#/*]*#[ ]?RUNF[0-9]?:[ ]*(.*)}
    set ee {^[[:space:]#/*]*#[ ]?EXEC[0-9]?:[ ]*(.*)}
    set AR [set RF [set EE {}]]
    foreach st $::em::filecontent {
      if {[regexp $ar $st] && $AR eq {}} {
        lassign [regexp -inline $ar $st] => AR
      } elseif {[regexp $rf $st] && $RF eq {}} {
        lassign [regexp -inline $rf $st] => RF
      } elseif {[regexp $ee $st] && $EE eq {}} {
        lassign [regexp -inline $ee $st] => EE
      }
      if {$AR ne {} || $RF ne {} || $EE ne {}} {
        if {"$AR$RF$EE" ne {OFF}} {
          set res [list $AR $RF $EE]
        }
        break
      }
    }
    set ::em::arEM(AR,$::em::arEM(f)) $res
  }
  return $res
}
#_______________________

proc ::em::getFL {} {
  # get contents of %l-th line of %f file

  if {[info exists ::em::arEM(l)]} {
    set p $::em::arEM(l)
    if {[string is digit $p] && $p>0 && $p<=[llength $::em::filecontent]} {
      return [lindex $::em::filecontent $p-1]
    }
  }
  return {}
}

# ________________________ Mr. Preprocessor _________________________ #

proc ::em::preprInit {refpn} {
  # Mr. Preprocessor initial

  upvar $refpn pn
  preprAbra pn 1
  prepr1 pn +  $::em::pseltd ;# %+  is %s with " " as "+"
  prepr1 pn qq $::em::qseltd ;# %qq is %s with quotes escaped
  prepr1 pn dd $::em::dseltd ;# %dd is %s with special simbols deleted
  prepr1 pn ss $::em::sseltd ;# %ss is %s trimmed
  prepr09 pn ::em::ar_s09 s  ;# s1-s9 params
  prepr09 pn ::em::ar_u09 u  ;# u1-u9 params underscored
}
#_______________________

proc ::em::preprAbra {refpn start} {
  # Mr. Preprocessor abracadabra

  upvar $refpn pn
  set abra {~Fb^D7}
  if {$start} {
    # this must be done just before other preps:
    set pn [string map [list %% $abra] $pn]
    preprCall pn
  } else {
    # this must be done just after other preps and before applying:
    set pn [string map [list %TN $::em::TN %TI $::em::ipos $abra %] $pn]
  }
}
#_______________________

proc ::em::initSWC {} {
  # initialization of selection (of %s wildcard)

  if {$::em::seltd ne {} || $::em::ln<=0 || $::em::cn<=0} {
    return  ;# selection is provided or ln=/cn= are not - nothing to do
  }
  if {[readFileF]} {     ;# get the selection as a word under caret
    set ln1 0                    ;# lines and columns are numerated from 1
    set ln2 [expr {*}$::em::ln - 1]
    set cn1 [expr {*}$::em::cn - 2]
    foreach st $::em::filecontent { ;# ~ KISS
      if {$ln1==$ln2} {
        for {set i $cn1} {$i>=0} {incr i -1} { ;# left part
          set c [string index $st $i]
          if {[string is wordchar $c]} {set ::em::seltd $c$::em::seltd} break
        }
        for {set i $cn1} {$i<[string len $st]} {} { ;# right part
          incr i
          set c [string index $st $i]
          if {[string is wordchar $c]} {set ::em::seltd $::em::seltd$c} break
        }
        break
      }
      incr ln1
    }
  }
}
#_______________________

proc ::em::preprPN {refpn {dt 0}} {
  # Mr. Preprocessor of 'prog'/'name'

  upvar $refpn pn
  preprAbra pn 1
  # these replacements go before geany's to avoid replacing %D, %l
  prepr1 pn DF $::em::DF                 ;# %DF is a name of diff tool
  prepr1 pn BF $::em::BF                 ;# %BF is a name of backup file
  prepr1 pn pd $::em::pd                 ;# %pd is a project directory
  prepr1 pn lg [::eh::get_language]      ;# %lg is a locale (e.g. ru_RU.utf8)
  prepr1 pn ls [nativePathes $::em::ls]  ;# %ls is a list of files
  foreach n [array names ::em::arEM] {
    set v $::em::arEM($n)
    if {$n in {f d}} {
      set v [nativePath $v]  ;# as Windows' pathes use backslash (escaping char in Tcl)
    }
    prepr1 pn $n $v
  }
  initSWC
  set PD [getPD]
  prepr1 pn PD [nativePath $PD]    ;# %PD is passed project's dir (PD=)
  prepr1 pn P2 $::em::PN2          ;# %P2 is a project's nickname
  prepr1 pn P_ [getPDU]            ;# ...underlined PD
  prepr1 pn PN $::em::prjname      ;# %PN is passed dir's tail
  prepr1 pn N  $::em::appN         ;# ID of menu application
  prepr1 pn mn $::em::menufilename ;# %mn is the current menu
  prepr1 pn ms $::em::srcdir       ;# %ms is e_menu/src dir
  prepr1 pn m  $::em::exedir       ;# %m is e_menu.tcl dir
  prepr1 pn s  $::em::seltd        ;# %s is a selected text
  prepr1 pn u  $::em::useltd       ;# %u is %s underscored
  prepr1 pn +  $::em::pseltd ;# %+  is %s with " " as "+"
  prepr1 pn qq $::em::qseltd ;# %qq is %s with quotes escaped
  prepr1 pn dd $::em::dseltd ;# %dd is %s with special simbols deleted
  prepr1 pn ss $::em::sseltd ;# %ss is %s trimmed
  lassign [getARE] AR RF EE
  prepr1 pn AR $AR      ;# %AR is contents of #ARGS..: line
  prepr1 pn RF $RF      ;# %RF is contents of #RUNF..: line
  prepr1 pn EE $EE      ;# %EE is contents of #EXEC..: line
  prepr1 pn L  [getFL]  ;# %L is contents of %l-th line
  prepr1 pn TT \
    [::eh::get_tty $::em::linuxconsole $::em::windowsconsole] ;# %TT is terminal
  set oldpn $pn
  lassign [::eh::get_timedate] curtime curdate curdt curdw systime
  prepr1 pn t0 $curtime  ;# %t0 time
  prepr1 pn t1 $curdate  ;# %t1 date
  prepr1 pn t2 $curdt    ;# %t2 date & time
  prepr1 pn t3 $curdw    ;# %t3 week day
  set pndt [expr {$oldpn ne $pn ? 1 : 0}]  ;# to update time in menu
  if {$dt} {return $pndt} {return $pn}
}
#_______________________

proc ::em::preprWU {refprog typ} {
  # convert all Windows' '\' to Unix '/'

  upvar $refprog prog
  if {[string last / $typ] > 0} {
    set foo1 w^Ve%`0I-=
    set foo2 9s%xD#%P_*
    set prog [string map [list \\n $foo1 \\t $foo2] $prog]
    set prog [string map [list \\ /] $prog]
    set prog [string map [list $foo1 \\n $foo2 \\t] $prog]
  }
}
#_______________________

proc ::em::preprProg {refprog typ} {
  # Mr. Preprocessor of 'prog'

  upvar $refprog prog
  preprPN prog
  preprWU prog $typ
}
#_______________________

proc ::em::preprCall {refname} {
  # Mr. Preprocessor of 'call':
  # this must be done for e_menu call line only

  upvar $refname name
  if {$::em::percent2 ne {}} {
    set name [string map [list $::em::percent2 %] $name]
  }
  prepr1 name PD [getPD]
  prepr1 name PN $::em::prjname
  prepr1 name N $::em::appN
}
#_______________________

proc ::em::preprHD {com} {
  # Mr. Preprocessor of 'home dir'.

  string map [list %H [::apave::HomeDir]] $com
}

proc ::em::prepr09 {refn refa t {inc 0}} {
  # Mr. Preprocessor of s0-9, u0-9

  upvar $refn name
  upvar $refa arr
  for {set i 0} {$i<=9} {incr i} {
    set p "$t$i"
    set s "$p="
    if {[string first $p $name] != -1 && [info exists arr($s)]} {
      set sel $arr($s)
      if {$t eq {i}} {
        incr sel $inc     ;# increment i1-i9 counters of runs
        set ${refa}($s) $sel
      }
      prepr1 name $p $sel
    }
  }
}
#_______________________

proc ::em::prepr1 {refpn s ss} {
  # Mr. Preprocessor of %-wildcards

  upvar $refpn pn
  set pn [string map [list %$s $ss] $pn]
}
#_______________________

# ________________________ auto run _________________________ #

proc ::em::runTclCommands {icomm} {
  # run Tcl commands passed in a1=, a2=

  upvar $icomm comm
  if {$comm ne {}} {
    preprCall comm
    eval $comm
    set comm {}
  }
}
#_______________________

proc ::em::runIt {i {hidden 0}} {
  # run i-th menu item

  if {$hidden} {
    lassign [lindex $::em::commhidden $i] name torun hot typ
  } else {
    lassign [lindex $::em::commands $i] name torun hot typ
    if {[set sc [string first {;} $torun]]>-1} {
      set torun [string range $torun 0 $sc-1]
    }
  }
  {*}$torun
}
#_______________________

proc ::em::runAuto {alist} {
  # run auto list a=

  foreach task [split $alist ,] {
    forButtons {
      if {$task eq [string range $::em::hotkeys $i $i]} {
        $b configure -fg $::em::clrhotk
        runIt $i
      }
    }
  }
}
#_______________________

proc ::em::runAutoHidden {alist} {
  # run auto list ah=

  foreach task [split $alist ,] {   ;# task=1 (2,...,a,b...)
    set i [string first $task $::em::hotsall]  ;# hotsall="012..ab..."
    if {$i>0 && $i<=[llength $::em::commhidden]} {
      runIt $i yes
    }
  }
}
#_______________________

proc ::em::runAH {sub} {
  # start autorun lists

  if {[string first a= $sub] >= 0} {
    runAuto [string range $sub 2 end]
  } elseif {[string first ah= $sub] >= 0} {
    runAutoHidden [string range $sub 3 end]
  }
}
#_______________________

proc ::em::initauto {} {
  # run tasks assigned in a= (by their hotkeys)

  if {"$::em::commandA1$::em::commandA2" ne {}} {
    catch {wm geometry .em $::em::geometry} ;# possible messages to be centered
  }
  runTclCommands ::em::commandA1  ;# run the command as first init
  runAuto $::em::autorun
  runAutoHidden $::em::autohidden
  runTclCommands ::em::commandA2  ;# run the command as last init
  runEx  ;# after all inits/autos, run "ex=" if any
  if {$::em::reallyexit} return
  if {!$::em::solo} {
    # only 1st start for 1st window (non-solo)
    set ::em::Argv [::apave::removeOptions $::em::Argv a=* a0=* a1=* a2=* ah=*]
    set ::em::Argc [llength $::em::Argv]
    lassign {} ::em::autorun ::em::autohidden ::em::commandA1 ::em::commandA2
  }
  if {[isChild]} {
    bind .em <Left> [::eh::ctrl_alt_off ::em::onExit]
  }
  if {$::em::lasti < $::em::begin} {set ::em::lasti $::em::begin}
  after 50 {
    if {[winfo exists .em]} {
      focus -force .em
      ::em::focusButton $::em::lasti
    }
  }
}
#_______________________

proc ::em::runEx {{exe ""}} {
  # run commands of ::em::ex list and exit

  if {$exe eq {}} {set exe $::em::ex}
  if {[llength $exe]} {
    foreach ex [split $exe ,] {
      if {$ex eq {Help}} {
        help_button $::em::pseltd
      } elseif {[string match h* $ex] && $ex ne {h}} {
        runAutoHidden [string range $ex 1 end]
      } else {
        runAuto $ex
      }
    }
    onExit 1
  }
}

# ________________________ menu variables _________________________ #

proc ::em::initMenuVars {domenu options} {
  # initialize values of menu's variables

  if {!($domenu && $options)} return
  set opt 0
  foreach line $::em::menufile {
    if {$line eq {[OPTIONS]}} {
      set opt 1
    } elseif {$opt && [runTclCode $line yes]} {
      # line of Tcl code - processed already
    } elseif {$opt && [string match {::?*=*} $line]} {
      set ::em::ismenuvars 1
      set ieq [string first = $line]
      set vname [string range $line 0 $ieq-1]
      set vvalue [string range $line $ieq+1 end]
      catch {
        if {![info exist ::$vname]} {
          set ::$vname {}
          preprPN vvalue
          set vvalue [preprHD $vvalue]
          set ::$vname [string map [list \\n \n \\ \\\\] $vvalue]
        }
      }
    } elseif {$line eq {[MENU]} || $line eq {[HIDDEN]}} {
      set opt 0
    }
  }
}
#_______________________

proc ::em::saveMenuVars {} {
  # save values of menu's variables in the menu file

  set menudata [readMenuFile]
  set opt [set i 0]
  foreach line $menudata {
    if {$line eq {[OPTIONS]}} {
      set opt 1
    } elseif {$opt && [string match {::?*=*} $line]} {
      lassign [regexp -inline "::(\[^=\]+)=\{1\}(.*)" $line] ==> vname vvalue
      catch {
        if {![regexp {^%[a-zA-GI-Z]} $vvalue]} { ;# don't save for wildcarded, except for %H (home dir)
          set var ::$vname
          set value [string map [list \n \\n] [set $var]]
          lset menudata $i [append var = $value]
        }
      }
    } elseif {$line eq {[MENU]} || $line eq {[HIDDEN]}} {
      set opt 0
    }
    incr i
  }
  if {$::em::ismenuvars} {writeMenuFile $menudata}
}

# ________________________ menu content _________________________ #

proc ::em::fillMenu {commands s1 domenu} {
  # read menu file

  upvar $commands comms
  set mnuname [menuFullname $::em::pars($s1)]
  if {$domenu} {
    if {$::em::menudir eq {}} {
      set ::em::menudir [file join $::em::exedir menus]
    }
    set fcont [textsplit [readTextFile $mnuname]]
    if {[llength $fcont]==0} {
      if {![set cr [addon createEm $mnuname]]} {
        set cr [addon template::create $mnuname]
      }
      if {$cr && $::em::solo} {
        restartEMenu
      } else {
        set ::em::reallyexit [expr {$cr ? 2 : 1}]
      }
      set ::em::start0 0  ;# no more messages
      return
    }
    set ::em::menufilename $mnuname
    set ::em::menufile [list 0]
    set lcont [llength $fcont]
  }
  set prname ?
  set iline $::em::begsel
  set doafter no
  set lapvar comms
  set ::em::commhidden [list 0]
  set hidden [set options [set ilmenu 0]]
  set name [set origname [set separ {}]]
  set icont 0
  while {1} {
    if {$domenu} {
      set line {}
      while {$icont<$lcont} { ;# lines ending with \ or ::em::conti to be continued
        set tmp [lindex $fcont $icont]
        incr icont
        if {[string index $tmp end] eq "\\"} {
          append line [string range $tmp 0 end-1]
        } elseif {$::em::conti ne "\\" && $::em::conti ne {} && \
                  [string range $tmp end-$::em::lconti end] eq $::em::conti} {
          append line $tmp
        } else {
          append line $tmp
          break
        }
      }
      if {$icont>=$lcont} {
        lappend ::em::menufile $line
        break
      }
      checkMacro $line
    } else {
      incr ilmenu
      if {$ilmenu >= [llength $::em::menufile]} {break}
      set line [lindex $::em::menufile $ilmenu]
    }
    set line [set origline [string trimleft $line]]
    if {$line eq {[MENU]}} {
      initMenuVars $domenu $options
      set options [set hidden 0]
      set name {}
      continue
    }
    if {$line in {[OPTIONS] [DATA]}} {
      set options 1
      set hidden 0
      set name {}
      continue
    }
    if {$line eq {[HIDDEN]}} {
      initMenuVars $domenu $options
      set hidden 1
      set options 0
      set name {}
      set lapvar ::em::commhidden
      continue
    }
    if {$options} {
      if {[string match co=* $line]} {
        # co= affects the current reading of continued lines of menu
        set ::em::conti [string range $line 3 end]
        set ::em::lconti [expr {[string length $::em::conti] - 1}]
      } elseif {![string match c=* $line] || $::em::optsFromMenu} {
        lappend ::em::menuoptions $line
      }
      continue
    }
    if {[regexp {^\s*(ITEM|SEP)\s*=\s*} $line]} {
      set it " [string trimleft [string range $line [string first = $line]+1 end]]"
      if {[regexp {^ (\d|-)*\s*$} $it]} {
        set separ $it
      } else {
        set name $it
        set hot {}
        foreach s {F1 F2 F3 F4 F5 F6 F7 F8 F9} {  ;# F1-F9 hotkeys
          if {[string first $s $name]==1} {
            set name [string range $name 3 end]
            set hot $s
            break
          }
        }
        set origname $name
      }
      set prname ?  ;# starting an item name, not a separator
      continue
    }
    lassign [getRSIM $line] typ prog line
    if {$typ eq {}} continue
    preprInit name
    preprWU name //  ;# forced 'name' without escapes
    preprWU prog $typ
    catch {set name [subst -nobackslashes -nocommands $name]}  ;# subst vars in names
    switch -exact -- $typ {
      I: {   ;#internal (M, Q, S, T)
        preprPN prog
        set prom {RUN INTERNAL}
        set runp $prog
      }
      R/ -
      R:  {
        set prom {RUN         }
        set runp "::em::run $typ"
        set amp $::em::R_ampmute
      }
      RE/ -
      RE: {
        set prom {RUN & EXIT  }
        set runp "::em::run $typ"
        set amp "$::em::R_ampmuteexit $line"
      }
      RW/ -
      RW: {
        set prom {RUN & WAIT  }
        set runp "::em::run $typ"
        set amp $::em::R_mute
      }
      S/ -
      S:  {
        set prom {SHELL       }
        set runp "::em::shell $typ"
        set amp $::em::R_ampmute
      }
      SE/ -
      SE: {
        set prom {SHELL & EXIT}
        set runp "::em::shell $typ"
        set amp $::em::R_ampmuteexit
      }
      SW/ -
      SW: {
        set prom {SHELL & WAIT}
        set runp "::em::shell $typ"
        set amp $::em::R_mute
      }
      MW/ -
      MW: -
      M/ -
      M:  {
        set prom {MENU        }
        set runp "::em::callmenu $typ"
        set amp &
      }
      ME/ -
      ME: {
        set prom {MENU & EXIT }
        set runp "::em::callmenu $typ"
        set amp $::em::R_ampexit
      }
      default {
        set prname ?
        continue
      }
    }
    if {$prname eq $origname} {          ;# && $prtyp == $typ - no good, as
      set torun "$runp $s1 $amp"       ;# it doesn't unite R, E, S types
      set prog $prprog\n$torun\r$prog
    } else {
      if {$separ ne {}} {    ;# is a separator?
        set n [::apave::getN [string trim $separ { -}] 1 1 33]
        set name "?-$n? $name"  ;# insert separator into name
        set separ {}
      }
      if {$hidden} {set s1 h} {set s1 m}
      append s1 [incr iline]
      if {$typ eq {I:}} {
        set torun $runp  ;# internal command
      } else {
        set torun "$runp $s1 $amp"
      }
      if {$iline > $::em::maxitems} {
        emMessage "Too much items in\n\n$mnuname\n\n$::em::maxitems is maximum. \
                    Stopped at:\n\n$origline"
        onExit
      }
      set prname $origname
      set ::em::itnames($iline) $origname   ;# - original item name
      if {[preprPN name 1]} {
        set doafter yes       ;# item names to be updated at intervals
      }
      if {$::em::ornament > 1} {
        lappend $lapvar [list "$prom :$name" $torun $hot $typ]
      } else {
        lappend $lapvar [list $name $torun $hot $typ]
      }
    }
    if {[string first $::em::extraspaces $prom]<0} {set ::em::extras no}
    set ::em::pars($s1) $prog
    set prprog $prog
  }
  if {$doafter} { ;# after N sec: check times/dates
    repeateUpdateButtons
  }
  initMenuVars $domenu $options
}
#_______________________

proc ::em::fillCommands {amc osm {domenu 0}} {
  # initialize ::em::commands from argv and menu

  # the sequence matters
  set lcoms [list tc= a0= P= N= PD= PN= F= o= ln= cn= s= u= w= qq= dd= ss= pa= ah= \
    += b1= b2= b3= b4= dk= t0= t1= t2= t3= f1= f2= f3= fs= a1= a2= ed= tf= tg= md= \
    wc= tt= wt= pk= TF= s0= s1= s2= s3= s4= s5= s6= s7= s8= s9= u0= u1= u2= u3= u4=\
    u5= u6= u7= u8= u9= i0= i1= i2= i3= i4= i5= i6= i7= i8= i9= x0= x1= x2= x3= x4=\
    x5= x6= x7= x8= x9= y0= y1= y2= y3= y4= y5= y6= y7= y8= y9= z0= z1= z2= z3= z4=\
    z5= z6= z7= z8= z9= a= d= e= f= p= l= h= b= cs= c= t= g= n= fg= bg= fE= bE= fS=\
    bS= fI= bI= fM= bM= cc= gr= ht= hh= rt= DF= BF= pd= m= om= ts= yn= in= ex= EX= \
    ee= PI= NE= ls= SD= g1= g2= th= td= SH= mp= ms=]
  foreach s1 {o= s= m=} {
    if {$s1 ni $osm} {
      set i [lsearch -exact $lcoms $s1]
      set lcoms [lreplace $lcoms $i $i]
    }
  }
  set amc [lreverse $amc] ;# to take last option's value
  set resetpercent2 0
  foreach s1 $lcoms {
    if {[getPars $s1 $amc]} {
      set seltd $::em::pars($s1)
      if {!($s1 in {m= g= in=})} {
        if {$s1 eq {s=}} {
          set seltd [::eh::escape_specials $seltd]
        } elseif {$s1 in {f= d=}} {
          set seltd [string trim $seltd \'\"\`]  ;# for some FM peculiarities
        }
        set ::em::inherited "$::em::inherited \"$s1$seltd\""
      }
      set s01 [string range $s1 0 1]
      switch -exact -- $s1 {
        tg= - om= - dk= - ls= - DF= - BF= - pd= - PI= - NE= - tc= - \
        th= - td= - ee= - SH= - mp= {
          # these are set as simply as ::em::NN
          set ::em::$s01 $seltd
        }
        P= {
          if {$seltd ne {}} {
            set ::em::percent2 $seltd  ;# set % substitution
          } else {
            set resetpercent2 1
          }   ;# must be reset to % after cycle
        }
        N= {set ::em::appN [::apave::getN $seltd 1]}
        PD= {
          set ::em::PD $seltd
          initPD $seltd
        }
        PN= {
          set ::em::prjname $seltd  ;# deliberately sets the project name
          set ::em::prjset 2
        }
        s= {
          initHeader $s1 $seltd
          set ::em::pseltd [::eh::escape_links $seltd]
        }
        h= {
          set ::eh::hroot [file normalize $seltd]
          set ::em::offline yes
        }
        m= {
          prepareWilds $resetpercent2
          fillMenu ::em::commands $s1 $domenu
        }
        b= {set ::eh::my_browser $seltd}
        cs= {  ;# user-defined CS
          if {[insteadCS $seltd]} {
            set ::em::ncolor [obj csAdd $seltd yes]
          }
        }
        c= {
          set nc [::apave::getN $seltd -2 -2 [::apave::cs_Max]]
          if {![insteadCS] || $nc<0} {
            if {[set ::em::ncolor $nc]<0} {
              set ::em::insteadCSlist [list]
            }
            initdefaultcolors
          }
        }
        o= {set ::em::ornament [::apave::getN $seltd 0 -2 3]
          if {$::em::ornament>1} {
            set ::em::font_f2 "-family {[obj basicTextFont]}"
          }
        }
        g= {
          lassign [split $seltd x+] w h x y
          if {$w ne {} && $x ne {} && $y ne {}} {
            set ::em::geometry ${w}x0+$x+$y  ;# h=0 to trim the menu height
          } else {
            set ::em::geometry $seltd
          }
        }
        u= {  ;# u=... overrides previous setting (in s=)
          set ::em::useltd [string map {{ } _} $seltd]
        }
        t= {set ::em::dotop [::apave::getN $seltd] }
        s0= - s1= - s2= - s3= - s4= - s5= - s6= - s7= - s8= - s9=
        {
          set ::em::ar_s09($s1) $seltd
        }
        u0= - u1= - u2= - u3= - u4= - u5= - u6= - u7= - u8= - u9=
        {
          set ::em::ar_u09($s1) [string map {{ } _} $seltd]
        }
        i0= - i1= - i2= - i3= - i4= - i5= - i6= - i7= - i8= - i9=
        {
          set ::em::ar_i09($s1) [::apave::getN $seltd]
        }
        w= {set ::em::itviewed [::apave::getN $seltd]}
        a= {set ::em::autorun $seltd}
        F= - f= - l= - p= - e= - d= {
          ;# d=, e=, f=, l=, p= are used as Geany wildcards
          lassign [split $seltd \n] seltd
          set ::em::arEM([string range $s1 0 0]) $seltd
        }
        n= {if {$seltd ne {}} {set ::em::menuttl $seltd}}
        ah= {set ::em::autohidden $seltd}
        a0= {if {$::em::start0} {runTclCommands seltd}}
        a1= {set ::em::commandA1 $seltd}
        a2= {set ::em::commandA2 $seltd}
        t0= {set ::eh::formtime $seltd }
        t1= {set ::eh::formdate $seltd }
        t2= {set ::eh::formdt   $seltd }
        t3= {set ::eh::formdw   $seltd }
        fs= {set ::em::fs [::apave::getN $seltd $::em::fs]}
        f1= - f2= {catch {
          set ::em::font_$s01 [font configure TkDefaultFont]
          set ::em::font_$s01 [dict replace [set ::em::font_$s01] -family $seltd]
        }}
        f3= {obj basicTextFont $seltd}
        qq= {set ::em::qseltd [::eh::escape_quotes $seltd]}
        dd= {set ::em::dseltd [::eh::delete_specsyms $seltd]}
        ss= {set ::em::sseltd [string trim $seltd]}
        +=  {set ::em::pseltd [::eh::escape_links $seltd]}
        pa= {set ::em::pause [::apave::getN $seltd $::em::pause]}
        wc= - b1= - b2= - b3= - b4= {
          set ::em::$s01 [::apave::getN $seltd [set ::em::$s01]]
        }
        ed= {set ::em::editor $seltd}
        ex= - EX= {
          set ::em::$s01 [set ::em::ex $seltd]
        }
        pk= {set ::eh::$s01 $seltd}
        md= {set ::em::menudir $seltd}
        SD= {
          set ::em::lin_console [file join $seltd [file tail $::em::lin_console]]
          set ::em::win_console [file join $seltd [file tail $::em::win_console]]
        }
        tf= {set ::em::tf [::apave::getN $seltd $::em::tf]}
        in= {
          if {[set ip [string first . $seltd]]>0} {
            # get last item number and its HELP/EXEC/SHELL shift (begsel)
            set ::em::savelasti [::apave::getN [string range $seltd $ip+1 end] -1]
            if {$::em::savelasti>-1} {
              set ::em::lasti [::apave::getN [string range $seltd 0 $ip-1] 1]
            }
          }
        }
        fg= - bg= - fE= - bE= - fS= - bS= - fI= - bI= - fM= - bM= - ht= - hh= - cc= - gr= {
          set ::em::clr$s01 $seltd
          if {[lsearch -glob $::em::insteadCSlist $s1*]<0} {
            lappend ::em::insteadCSlist $s1$seltd
          }
        }
        ts= {set ::em::truesel [::apave::getN $seltd]}
        ln= - cn= - yn= {set ::em::$s01 [::apave::getN $seltd]}
        rt= { ;# ratio "min.size / init.size"
          lassign [split $seltd /] i1 i2
          if {[string is integer $i1] &&[string is integer $i2] && \
              $i1!=0 && $i2!=0 && $i1/$i2<=1} {
            set ::em::ratiomin $i1/$i2
          }
        }
        g1= - g2= { ;# geometry of directory/file chooser
          set ::em::$s01 $seltd
          ::apave::setProperty DirFilGeoVars [list ::em::g1 ::em::g2]
        }
        tt= { ;# linux terminal (e.g. "tt=xterm -fs 12 -geometry 90x30+400+100")
          set ::em::linuxconsole $seltd
        }
        wt= { ;# windows terminal (e.g. wt=powershell, wt=cmd.exe)
          if {$seltd in {cmd.exe {start cmd.exe}}} {
            append seltd { /c}
          } elseif {$seltd eq {powershell.exe}} {
            append seltd { -nologo}
          }
          set ::em::windowsconsole $seltd
        }
        ms= {
          set ::em::srcdir $seltd
          terminalPathes
        }
        default {
          if {$s1 in {TF=} || [string range $s1 0 0] in {x y z}} {
            ;# x* y* z* general substitutions
            set ::em::arEM([string map {= {}} $s1]) $seltd
          }
        }
      }
    }
  }
  # get %D (dir's tail) %F (file.ext), %e (file), %x (ext) wildcards from %f
  if {![info exists ::em::arEM(f)]} {
    set ::em::arEM(f) $::em::menufilename  ;# %f wildcard is a must
  }
  if {[::iswindows]} {
    set ::em::arEM(UF) [string map [list \\ /] [file nativename $::em::arEM(f)]]
  } else {
    set ::em::arEM(UF) $::em::arEM(f)
  }
  set ::em::arEM(UD) [file dirname $::em::arEM(UF)]
  prepareMainWilds
  prepareWilds $resetpercent2
  set ::em::ncmd [llength $::em::commands]
  initPD [pwd]
  menuTitle
}
#_______________________

proc ::em::getPars {s1 amc} {
  # get pars array

  if {[set i [lsearch -glob $amc $s1*]]>-1} {
    set par [lindex $amc $i]
    set val [string range $par [string len $s1] end]
    preprCall val
    set ::em::pars($s1) $val
    return yes
  }
  set ::em::pars($s1) {}
  return no
}
#_______________________

proc ::em::getRSIM {line {markers {}}} {
  # Gets R:, R/ etc type from a line.

  if {[regexp {^\s*[RSIM]{1}[WE]?:\s*} $line]} {
    set div :
  } elseif {[regexp {^\s*[RSIM]{1}[WE]?/\s*} $line]} {
    set div /
  } else {
    if {$markers ne {}} {
      set marker [lindex [regexp -inline ^($markers) $line] 0]
      return [list $marker - [string trim $line]]
    }
    return {}
  }
  set line [string trim $line]
  set i [string first $div $line]
  set typ [string range $line 0 $i]
  set prog [string trimleft [string range $line $i+1 end]]
  list $typ $prog $line
}
#_______________________

proc ::em::expandMacro {lmark macro line} {
  # expand $macro (%M1, %MA ...) for $line marked with $lmark (R:, R/ ...)

  set mc [string range $macro 0 2]  ;# $macro = %M1 arg1 %M1 arg2 ...
  if {![info exist ::em::ar_macros($mc)]} {
    set ::em::ar_macros($mc) {}
    foreach st $::em::menufile {
      set st [string trimleft $st]
      if {[string match $mc* $st]} {
        lappend ::em::ar_macros($mc) [string trimleft [string range $st 4 end]]
      }
    }
  }
  set pal [string map [list $mc \n] [lindex $::em::ar_macros($mc) 0]]
  set arl [string map [list $mc \n] [string range $macro 3 end]]
  set arglist [split "$arl " \n]
  set parlist [split "$pal " \n]
  if {[set n1 [llength $parlist]] != [set n2 [llength $arglist]]} {
    emMessage "ERROR:\n\nMacro $mc parameters and arguments don't agree:\n  $n1 not equal $n2"
    return
  }
  set i1 [string first $lmark $line]
  set i2 [string first $lmark $line $i1+1]
  set lname [string range $line $i1+[string length $lmark] $i2-1]
  foreach line [lrange $::em::ar_macros($mc) 1 end] {
    if {[set i [string first : $line]]<0 && \
        [set i [string first / $line]]<0} {
      emMessage "ERROR:\n\nMacro $mc error in line:\n  $line"
      return
    }
    set lmark [string range $line 0 $i]
    set line "$lmark[string range $line $i+1 end]"
    foreach par $parlist arg $arglist {
      set par "\$[string trim $par]"
      if {$par ne {$}} {
        set line [string map [list $par [string trim $arg]] $line]
      }
    }
    lappend ::em::menufile $line
  }
}
#_______________________

proc ::em::checkMacro {line} {
  # check for and insert macro, if any

  set line [string trimleft $line]
  set s1 [regexp -inline {^[RSI]{1}[WE]?[:/]} $line]
  if {$s1 ne {}} {
    #check for macro %M1..%M9, %Ma..%Mz, %MA..%MZ
    set s2 [string trimleft [string range $line [string length $s1] end]]
    if {[regexp {^%M[^ ] } $s2]} {
      expandMacro $s1 $s2 $line
      return
    }
  }
  lappend ::em::menufile $line
}
#_______________________

proc ::em::initcommhead {} {
  # prepend initialization

  set ::em::begsel 0
  set ::em::hotkeys $::em::hotsall
  set ::em::inherited {}
  set ::em::commands {0}
}
#_______________________

proc ::em::initcomm {} {
  # initialize commands

  initcommhead
  array unset ::em::ar_macros *
  array set ::em::ar_macros [list]
  set ::em::menuoptions {0}
  if {[lsearch -exact $::em::Argv ch=1]>=0} {set ::em::ischild 1}
  # external E_MENU_OPTIONS are in the beginning of ::em::Argv (being default)
  # if "b=firefox", OR in the end (being preferrable) if "99 b=firefox"
  if {!($::em::ischild || [catch {set ext_opts $::env(E_MENU_OPTIONS)}])} {
    set inpos 0
    foreach opt [list {*}$ext_opts] {
      if [string is digit $opt] {set inpos $opt; continue}
      set ::em::Argv [linsert $::em::Argv $inpos $opt]
      incr inpos
      incr ::em::Argc
    }
  }
  if {[lsearch -glob $::em::Argv s=*]<0} {
    ;# if no s=selection, make it empty to hide HELP/EXEC/SHELL
    lappend ::em::Argv s=
    incr ::em::Argc
    if {[set io [lsearch -glob $::em::Argv o=*]]<0} {
      lappend ::em::Argv o=-1
      incr ::em::Argc
    }
  }
  fillCommands $::em::Argv {o= s= m=} 1
  if {$::em::ee ne {}} {
    set cpwd [pwd]
    catch {cd $::em::arEM(d)}
    set idiotic {~Fb^D~}
    set com [string map [list %% $idiotic] $::em::ee]
    set com [string map [list \
      %f $::em::arEM(f) \
      %d [file dirname $::em::arEM(f)] \
      %pd $::em::pd \
      ] $com]
    set com [string map [list $idiotic %] $com]
    if {[set inconsole [string match %t* $com]]} {
      set com [string range $com 2 end]
    }
    if {[::iswindows]} {
      shell0 $com &
    } elseif {$inconsole} {
      term "$::em::tc $com" {} yes
    } else {
      execWithPID "$::em::tc $com"
    }
    catch {cd $cpwd}  ;# may be deleted by commands
    set ::em::reallyexit yes
    onExit
  }
  if {![llength [array names ::em::ar_macros]] && !$::em::isbaltip} {
    return [expr {!$::em::reallyexit}]
  }
  if {$::em::reallyexit} {return no}
  if {[llength $::em::menuoptions] > 1} {
      # o=, s=, m= options define menu contents & are processed particularly
    fillCommands $::em::menuoptions {o=}
    initcommhead
    if {$::em::om} {
      fillCommands $::em::Argv {s= m=}
      fillCommands $::em::menuoptions {o=}
    } else {
      fillCommands $::em::menuoptions { }
      fillCommands $::em::Argv {o= s= m=}
    }
  }
  if {$::em::savelasti>-1} {  ;# o= s= m= options influence ::em::lasti
    if {$::em::begsel==0} {
      incr ::em::lasti -$::em::savelasti  ;# header was, now is not
    } elseif {$::em::savelasti==0} {
      incr ::em::lasti $::em::begsel      ;# header was not, now is
    }
  }
  return yes
}
#_______________________

proc ::em::initHeader {s1 seltd} {
  # initialize header of menu

  set ::em::seltd [string map {\r {} \n {}} $::em::seltd]
  lassign [split $seltd \n] ::em::seltd ;# only 1st line (TF= for all)
  initSWC
  set ::em::useltd [set ::em::pseltd [set ::em::qseltd \
    [set ::em::dseltd [set ::em::sseltd $::em::seltd]]]]
  if {[isheaderShown]} {
    set help [lindex $::em::seltd 0]  ;# 1st word is the page name
    lappend ::em::commands [list " HELP        \"$help\"" \
        "::em::help \"$help\""]
    if {[::iswindows]} {
      preprWU seltd M/
      set ::em::pars($s1) $seltd
    }
    lappend ::em::commands [list " EXEC        \"$::em::seltd\"" \
        "::em::runHead R: $s1 &"]
    lappend ::em::commands [list " SHELL       \"$::em::seltd\"" \
        "::em::shellHead S: $s1 &"]
    set ::em::hotkeys 000$::em::hotsall
  }
  set ::em::begsel [expr {[llength $::em::commands] - 1}]
}
#_______________________

proc ::em::menuFullname {menuname {ext .em}} {
  # Gets a normalized menu file name.
  #   menuname - input menu file name
  #   ext - file extension

  set fname [file rootname $menuname]$ext
  if {$::em::menudir ne {}} {
    set fname [file join $::em::menudir $fname]
  }
  if {![file exists $fname]} {
    set fname [file join $::em::exedir $fname]
  }
  file normalize $fname
}
#_______________________

proc ::em::menuTitle {} {
  # gets the menu's title

  if {[isChild]} {
    set ps \u220e
  } else {
    set ps \u23cf
  }
  set ::em::menuttl "$ps [file rootname [file tail $::em::menufilename]]"
}
#_______________________

proc ::em::menuOption {mnu opt {val {}}} {
  # set/get option for menu

  set opt em::[file normalize $mnu]/$opt
  if {$val eq {}} {
    set val [::apave::getProperty $opt]
  } else {
    ::apave::setProperty $opt $val
  }
  return $val
}

# ________________________ GUI _________________________ #


## ________________________ preparatory _________________________ ##

proc ::em::rereadMenu {{ib ""}} {
  # re-read and update menu after Ctrl+R

  wm withdraw .em
  foreach w [winfo children .em] {  ;# remove Tcl/Tk menu items
    destroy $w
  }
  initcomm
  initmenu
  if {$ib ne {}} repaintForWindows
  wm deiconify .em
}
#_______________________

proc ::em::repaintMenu {} {
  # repaint menu's items

  catch {
    initcolorscheme
    forButtons {
      $b configure -fg [colorButton $i] -bg [colorButton $i bg] -relief flat
      .em.fr.win.l$i configure -bg $::em::clrinab -fg $::em::clrhotk
      if {[winfo exists .em.fr.win.fr$i.arr]} {
        .em.fr.win.fr$i.arr configure -bg [colorButton $i bg]
      }
    }
    focusButton $::em::lasti
  }
}
#_______________________

proc ::em::toggleOntop {} {
  # toggle 'stay on top' mode

  wm attributes .em -topmost $::em::ontop
  if {$::em::ontop} {
    .em.fr.cb configure -fg $::em::clrhelp
  } else {
    .em.fr.cb configure -fg $::em::clrinaf
  }
}
#_______________________

proc ::em::focusWin {focused} {
  # focus in/out

  set ::eh::mx [set ::eh::my 0]
  if {$::em::skipfocused && [isMenuFocused]} {
    mouseButton $::em::lasti
    set ::em::skipfocused 0
    return
  }
  set ::em::skipfocused 0
  if {$focused && ![isMenuFocused]} {
    foreach wc [array names ::em::bgcolr] {
      if {[winfo exists $wc]} {
        if {![string match .em.fr.win.fr*butt $wc]} {
          catch {$wc configure -bg $::em::bgcolr($wc)}
        }
      }
    }
    set ::em::skipfocused 1  ;# to disable blinking FocusOut/FocusIn
    repaintMenu  ;# important esp. for Windows
  } elseif {!$focused && [isMenuFocused]} {
    catch {.em.fr.win.fr$::em::lasti.butt configure -fg $::em::clrhotk}
    set ::eh::mx [set ::eh::my 0]
    update
  }
}
#_______________________

proc ::em::repaintForWindows {} {
  # repainting sp. for Windows

  after idle ::em::repaintMenu
  after idle [list ::em::mouseButton $::em::lasti]
}
#_______________________

proc ::em::prepareButtons {refcommands} {
  # prepare buttons' contents

  if {$::em::ncmd < 2} { ;# check the call string of e_menu
    if {$::em::start0} {
      puts "To run e_menu, use a command: \
      \n\033\[34;1m  tclsh e_menu.tcl \"s=%s\" m=menu \033\[m \
      \nDetails here: \
      \n\033\[32;1m  https://aplsimple.github.io/en/tcl/e_menu\033\[m"
    }
    onExit
    return no
  }
  upvar $refcommands commands
  if {$::em::itviewed <= 0} {
    forButtons {
      set comm [lindex $commands $i]
      set name [lindex $comm 0]
      if {$::em::extras} {
        set name [string map [list $::em::extraspaces {}] $name]
        set comm [lreplace $comm 0 0 $name]
        set commands [lreplace $commands $i $i $comm]
      }
      set name [preprAbra name 0]
      if {[set l [string length $name]] > $::em::itviewed}  {
        set ::em::itviewed $l
      }
    }
    if {$::em::itviewed < 5} {set ::em::itviewed $::em::viewed}
  }
  set fs [expr {min(9,[obj basicFontSize])}]
  set ::em::font1a "$::em::font_f1 -size $fs"
  set ::em::font2a "$::em::font_f2 -size $::em::fs"
  set ::em::font3a "$::em::font_f2 -size [expr {$::em::fs-1}]"
  frame .em.fr.win -bg $::em::clrinab
  checkbutton .em.fr.cb -text {On top} -fg $::em::clrhelp -bg $::em::clrinab
  after idle [list .em.fr.cb configure -variable ::em::ontop \
    -activeforeground $::em::clrtitf -activebackground $::em::clrtitb \
    -takefocus 0 -command ::em::toggleOntop -font $::em::font1a]
  if {$::eh::pk eq {} && $::em::ornament!=-2} {
    grid [label .em.fr.h0 -text [string repeat { } [expr {$::em::itviewed -3}]] \
      -bg $::em::clrinab] -row 0 -column 0 -sticky nsew
    grid .em.fr.cb -row 0 -column 1 -sticky ne
    if {[isheader]} {
      grid [label .em.fr.h1 -text {Use space & arrows to take action} \
        -font $::em::font1a -fg $::em::clrhelp -bg $::em::clrinab -anchor s] \
        -columnspan 2 -sticky nsew
      grid [label .em.fr.h2 -text "(or press hot keys)\n" -font $::em::font1a \
        -fg $::em::clrhotk -bg $::em::clrinab -anchor n] -columnspan 2 -sticky nsew
    }
  }
  catch {
    ::baltip tip .em.fr.cb {Press Ctrl+T to toggle}
  }
  if {[isheaderShown]} {set hlist {.em.fr.h0 .em.fr.h1 .em.fr.h2}} {set hlist {.em.fr.h0}}
  foreach l $hlist {
    if {[winfo exists $l]} {
      bind $l <ButtonPress-1>   {
        ::eh::mouse_drag .em 1 %x %y; ::em::focusButton $::em::lasti yes}
      bind $l <Motion>          {::eh::mouse_drag .em 2 %x %y}
      bind $l <ButtonRelease-1> {::eh::mouse_drag .em 3 %x %y}
    }
  }
  return yes
}
#_______________________

proc ::em::centerme {} {
  # Gets -centerme option.

  if {$::em::SH ne {}} {
    set cm "-centerme $::em::SH"
  } elseif {[winfo exists .em] && [winfo ismapped .em]} {
    set cm {-centerme .em}
  } else {
    set cm {-centerme .}
  }
  return $cm
}

## ________________________ making GUI _________________________ ##

proc ::em::inithotkeys {} {
  # initialize hotkeys for popup menu etc.

  foreach {t e r d g p} {t e r d g p T E R D G P} {
    bind .em <Control-$t> {.em.fr.cb invoke}
    bind .em <Control-$e> {::em::addon editMenu}
    bind .em <Control-$r> {::em::addon rereadInit}
    bind .em <Control-$d> {::em::addon destroyEMenus}
    bind .em <Control-$p> {::em::addon changePD}
  }
  bind .em <Button-3>  {::em::addon popup %X %Y}
  bind .em <F1> {::em::addon about}
  if {$::em::ex eq {}} update
}
#_______________________

proc ::em::initmain {} {
  # initialize main properties

  if {$::em::pause > 0} {after $::em::pause}  ;# pause before main inits
  if {$::em::appN > 0} {
    set ::em::appname $::em::thisapp$::em::appN     ;# set N of application
  } elseif {$::em::solo} {
    ;# otherwise try to find it
    for {set ::em::appN 1} {$::em::appN < 64} {incr ::em::appN} {
      set ::em::appname $::em::thisapp$::em::appN
      if {[catch {send -async $::em::appname {update idletasks}} e]} {
        break
      }
    }
  }
  if {$::em::solo} {tk appname $::em::appname}
  set imgArr {iVBORw0KGgoAAAANSUhEUgAAAAoAAAAMAgMAAAAmBcQzAAAAAXNSR0IArs4c6QAAAAxQTFRFAAAA
SUlJkpKStra2HfYclAAAAAF0Uk5TAEDm2GYAAAABYktHRACIBR1IAAAACXBIWXMAAAsTAAALEwEA
mpwYAAAAB3RJTUUH6AQFDiQW+z8cQAAAACpJREFUCNdjYGFgYGAFYjYHBgb2CUD8BIh/AvFfoNgS
IA4AyjtA1ADVAgB/0wUkT+UKOgAAAABJRU5ErkJggg==}
  initcolorscheme
  set ::em::lin_console [file join $::em::exedir $::em::lin_console]
  set ::em::win_console [file join $::em::exedir $::em::win_console]
  set ::em::img [image create photo -data $imgArr]
  for {set i 0} {$i <=9} {incr i} {set ::em::ar_i09(i$i=) 1 }
  themingPave
  if {[insteadCS]} {
    set ::em::ncolor [obj csCurrent]
    initcolorscheme
  }
  obj untouchWidgets .em.fr.win* .em.fr.h* .em.fr.cb
}
#_______________________

proc ::em::initmenu {} {
  # make e_menu's menu

  if {![winfo exists .em]} {
    toplevel .em
    .em configure -bg $::em::clrinab
    if {[::iswindows]} { ;# maybe nice to hide all windows manipulations
      wm attributes .em -alpha 0.0
    } else {
      wm withdraw .em
    }
    initbegin
  }
  frame .em.fr -bg $::em::clrinab
  if {$::em::dk in {desktop splash dock}} {
    .em.fr configure -borderwidth 2 -relief solid
  }
  pack .em.fr -expand 1 -fill both
  inithotkeys
  if {![prepareButtons ::em::commands]} return
  set capsbeg [expr {36 + $::em::begsel}]
  set symsmap [list \n { } \[ \\\[ \] \\\] \$ \\\$]
  forButtons {
    set hotkey [string range $::em::hotkeys $i $i]
    set coSM [lindex $::em::commands $i]
    set comm [string map $symsmap $coSM]
    set prbutton "::em::prButton $i [lindex $comm 1]"
    set prkeybutton [::eh::ctrl_alt_off $prbutton]  ;# for hotkeys without ctrl/alt
    set comtitle [lindex $coSM 0]
    if {$i > $::em::begsel} {
      if {$i < ($::em::begsel+10)} {
        bind .em <KP_$hotkey> $prkeybutton
      } elseif {($capsbeg-$i)>0} {
        bind .em <KeyPress-[string toupper $hotkey]> $prkeybutton
      }
      bind .em <KeyPress-$hotkey> $prkeybutton
      set t [string trim $comtitle]
      set hotk [lindex $comm 2]
      if {[string len $hotk] > 0} {
        bind .em <$hotk> $prbutton
        set hotkey $hotk
      }
    } else {
      set hotkey {}
    }
    prepr09 comtitle ::em::ar_i09 i
    preprAbra comtitle 0
    lassign [pAssign comtitle 0] p1 p2
    if {$p2 ne {}} {
      set pady [::apave::getN $p1 0]
      if {$pady < 0} {
        if {$::eh::pk eq {} || [incr wassepany]>1} {
          grid [ttk::separator .em.fr.win.lu$i -orient horizontal] \
            -pady [expr {-$pady-1}] -sticky we \
            -column 0 -columnspan 2 -row [expr {$i+$::em::isep}]
        }
      } else {
        grid [label .em.fr.win.lu$i -font Sans -fg $::em::clrinab \
          -bg $::em::clrinab] -pady $pady -sticky nsw \
          -column 0 -columnspan 2 -row [expr {$i+$::em::isep}]
      }
      incr ::em::isep
    }
    frame .em.fr.win.fr$i -bg $::em::clrinab
    if {[string first M [lindex $comm 3]] == 0} { ;# is menu?
      set img "-image $::em::img"     ;# yes, show arrow
      button .em.fr.win.fr$i.arr {*}$img -relief flat -overrelief flat \
        -highlightthickness 0 -bg [colorButton $i bg] -command "$b invoke"
    } else {set img {}}
    button $b -text $comtitle -pady $::em::b1 -padx $::em::b2 -anchor nw \
      -font $::em::font2a -width $::em::itviewed \
      -relief flat -overrelief flat -highlightthickness 0 \
      -fg [colorButton $i] -bg [colorButton $i bg] -command $prbutton \
      -activeforeground [colorButton $i fg] -activebackground [colorButton $i bg]
    if {$img eq {} && \
    [string len $comtitle] > [expr $::em::itviewed * $::em::ratiomin]} { \
      catch {::baltip tip $b $comtitle}
    }
    grid [label .em.fr.win.l$i -text $hotkey -font "$::em::font3a -weight bold" -bg \
      $::em::clrinab -fg $::em::clrhotk -padx 0 -pady 0] -padx 0 -ipadx 0 \
      -column 0 -row [expr {$i+$::em::isep}] -sticky nsew
    grid .em.fr.win.fr$i -column 1 -row  [expr {$i+$::em::isep}] -sticky ew \
        -pady $::em::b3 -padx $::em::b4
    pack $b -expand 1 -fill both -side left
    if {$img ne {}} {
      pack .em.fr.win.fr$i.arr -expand 1 -fill both
      bind .em.fr.win.fr$i.arr <Motion> "::em::focusButton $i"
    }
    set iplus [expr {$i+1}]
    set iminus [expr {$i-1}]
    bind $b <Motion>   "::em::focusButton $i"
    bind $b <Down>     "::em::mouseButton $iplus"
    bind $b <Tab>      "::em::mouseButton $iplus"
    bind $b <Up>       "::em::mouseButton $iminus"
    bind $b <Home>     "::em::mouseButton 99"
    bind $b <End>      "::em::mouseButton 0"
    bind $b <Prior>    "::em::mouseButton 99"
    bind $b <Next>     "::em::mouseButton 0"
    bind $b <Return>   $prbutton
    bind $b <KP_Enter> $prbutton
    if {$img ne {}} {bind $b <Right> $prkeybutton}
    if {[::iswindows]} {
      bind $b <Shift-Tab> "::em::mouseButton $iminus"
    } else {
      bind $b <ISO_Left_Tab> "::em::mouseButton $iminus"
    }
  }
  if {$::em::ex ne {}} return
  grid .em.fr.win -columnspan 2 -sticky ew
  grid columnconfigure .em.fr 0 -weight 1
  grid rowconfigure    .em.fr 0 -weight 0
  grid rowconfigure    .em.fr 1 -weight 1
  grid rowconfigure    .em.fr 2 -weight 1
  grid columnconfigure .em.fr.win 1 -weight 1
  toggleOntop
  update idletasks
  set isgeom [string len $::em::geometry]
  wm title .em $::em::menuttl
  if {$::em::start0==1} {
    if {!$isgeom} {
      wm geometry .em $::em::geometry
    }
  }
  if {$::em::minwidth == 0} {
    set ::em::minwidth [expr [winfo width .em] * $::em::ratiomin]
    set ::em::minheight [winfo height .em]
  } else {
    set ::em::minheight [expr {[winfo height .em.fr.win] + 1}]
    if {[winfo exists .em.fr.cb]} {
      incr ::em::minheight [winfo height .em.fr.cb]
    }
  }
  if {$::em::start0} {
    if {$::em::wc || [::iswindows] && $::em::start0==1} {
     ::tk::PlaceWindow .em widget .
    }
  }
}
#_______________________

proc ::em::initbegin {} {
  # begin inits

  if {$::em::dk ne {} && ![::iswindows]} {
    wm withdraw .em
    wm attributes .em -type $::em::dk ;# desktop ;# splash ;# dock
  }
  encoding system utf-8
  option add *Menu.tearOff 1
  set e_menu_icon {iVBORw0KGgoAAAANSUhEUgAAAFwAAAB3BAMAAAB8qjqeAAAAD1BMVEUrRF3Y2tab4+U9Oz4jKjDz
nD2xAAAAfklEQVRYw+3YsQ2AMAxEUcMGlpjgsgFMgMT+MyFRAIpEkNPETu5XFK80V0RgStJmaJUk
hsgr+KRZofhyvHLAd9VR+JPGupmsQP8q+f2tP7nkM4CLoxB5G+70Zj44V4y8742UQuRtuNOb4UaS
cyNjDMdA3NXNcCP747a3VJg6ATkQ0OkoHNcZAAAAAElFTkSuQmCC}
  if {$::em::solo} {
    ::apave::setAppIcon .em $e_menu_icon
  }
}
#_______________________

proc ::em::initend {} {
  # end up inits

  ::apave::initPOP .em
  bind .em.fr <FocusIn> {::em::focusButton $::em::lasti}
  bind .em <Control-t> {.em.fr.cb invoke}
  bind .em <Escape> {
    if {$::em::yn && ![::em::isChild] && ![Q $::em::menuttl "Quit e_menu?" \
      yesno ques YES -t 0 -a {-padx 50} {*}[::em::centerme]]} break
    ::em::onExit
  }
  bind .em <Control-Left>  {::em::addon winWidth -1}
  bind .em <Control-Right> {::em::addon winWidth 1}
  wm protocol .em WM_DELETE_WINDOW ::em::onExit
  if {$::em::dotop || $::em::ontop} {set ::em::ontop 0; .em.fr.cb invoke}
  wm geometry .em $::em::geometry
  if {[::iswindows]} {
    if {[wm attributes .em -alpha] < 0.1} {wm attributes .em -alpha 1.0}
  } else {
    catch {exec chmod a+x $::em::lin_console}
  }
  catch {wm deiconify .em ; raise .em}
  ::eh::checkgeometry .em
  set ::em::start0 0
  repaintForWindows
}
#_______________________

proc ::em::initall {} {
  # initializes all of data and runs the menu

  init_arrays
  initdefaultcolors
  initcolorscheme
  if {[initcomm]} {
    initmain
    initmenu
    initauto
    if {$::em::reallyexit} return
    initend
    catch {::baltip config -shiftX 8 -fg $::em::fW -bg $::em::bW}
  }
}

# ________________________ run app _________________________ #

proc ::em::onExit {{really 1} args} {
  # exit (end of e_menu)

  if {!$really && ($::em::ontop || $::em::remain)} return
  # remove temporary files, at closing a parent menu
  if {!$::em::ischild} {
    if {![catch {set flist [glob [file join $::em::menudir *.tmp*]]}] && $flist ne {}} {
      catch {file delete {*}$flist}
    }
  }
  if {$::em::solo} exit
  menuOption $::em::menufilename geometry [::em::geometry]
  poolPull
  set ::em::geometry [::em::geometry]
  set ::em::reallyexit $really
  set ::em::em_win_var 0
}

proc ::em::main {args} {
  # main procedure to run

  if {[winfo exists .em.fr]} {destroy .em}
  lassign [::apave::parseOptions $args -prior 0 -modal 0 -remain 0 -noCS 0] \
    prior modal ::em::remain ::em::noCS
  set args [::apave::removeOptions $args -prior -modal -remain -noCS]
  if {$::em::noCS} {set ::em::noCS disabled} {set ::em::noCS normal}
  if {$prior} {
    set ::em::empool [list]  ;# continue with variables of previous session
  }
  unset -nocomplain ::EMENUFILE  ;# a file name to be initialized in .em
  set ::em::Argv $args
  set ::em::Argc [llength $args]
  set ::em::fs [obj basicFontSize]
  set ::em::ncolor [obj csCurrent]
  set ::em::ee {}
  if {[llength $::em::empool]==0} {
    poolPush  ;# makes a basic item ("clean variables") in the menu pool
  } else {
    set ::em::empool [lrange $::em::empool 0 0]  ;# fetch the clean variables
    poolActivateItem 0
  }
  set ::em::reallyexit no
  set ::eh::retval [set ::eh::pk {}]
  while {!$::em::reallyexit && $::eh::retval eq {} && ![::apave::endWM ?]} {
    poolPush
    initall
    if {$::em::reallyexit} {
      poolPull
      return 1
    }
    if {!$::em::reallyexit} {  ;# may be set in autoruns
      if {[set wgr [grab current]] ne {}} {
        grab release $wgr  ;# in Windows there are some issues with the grabbing
      }
      obj showWindow .em $modal $::em::ontop ::em::em_win_var \
        "$::em::minwidth $::em::minheight" yes
      destroy .em
      if {$wgr ne {}} {grab set $wgr}
      if {![poolPull]} break
    } elseif {$::em::reallyexit eq {2}} {
      set ::em::empool [list]
      set ::em::reallyexit no  ;# enter the newly created menu
    }
  }
  set ::em::empool [list]
  if {[winfo exists .em]} {destroy .em}
  if {$::eh::retval ne {}} {
    return $::eh::retval  ;# e_menu called to pick an item
  }
  return $::em::em_win_var
}
#_______________________

if {$::em::solo} {
  # theming at the app's start: th= a theme name, td= a theme directory
  foreach tmp1 {th td SH} {
    if {[set tmp2 [lsearch -glob $::argv $tmp1=*]]>-1} {
      set ::em::$tmp1 [string range [lindex $::argv $tmp2] 3 end]
    }
  }
  set ::em::isbaltip [expr {$::em::SH eq {}}]
  if {$::em::th eq {} || $::em::td eq {}} {
    ::apave::initWM -isbaltip $::em::isbaltip
  } else {
    lassign [::apave::InitTheme $::em::th $::em::td] tmp1 tmp2
    ::apave::initWM -theme $tmp1 -labelborder $tmp2 -isbaltip $::em::isbaltip
  }
  unset tmp1
  unset tmp2
  ::apave::iconImage -init small
  ::em::main -modal 0 -remain 0 {*}$::argv
}

# ________________________ EOF _________________________ #
