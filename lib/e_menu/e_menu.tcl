#! /usr/bin/env tclsh

#####################################################################
# Runs commands on files. Bound to editors, file managers etc.
# Scripted by Alex Plotnikov.
# License: MIT.
#####################################################################

# Test cases:

  # run doctest in console to view all debugging "puts"

  #% doctest 1
  #% exec tclsh /home/apl/PG/github/e_menu/e_menu.tcl z5=~ "s0=PROJECT" "x0=EDITOR" "x1=THEME" "x2=SUBJ" b=firefox PD=~/.tke d=~/.tke s1=~/.tke "F=*" f=/home/apl/PG/Tcl-Tk/projects/mulster/mulster.tcl md=~/.tke/plugins/e_menu/menus m=menu.mnu fs=8 w=30 o=-1 c=0 s=selected g=+0+30
  #> doctest

  #-% doctest 2
  #-% exec lxterminal -e tclsh /home/apl/PG/github/e_menu/e_menu.tcl z5=~ "s0=PROJECT" "x0=EDITOR" "x1=THEME" "x2=SUBJ" b=firefox PD=~/.tke d=~/.tke s1=~/.tke "F=*" md=~/.tke/plugins/e_menu/menus m=side.mnu o=1 c=4 fs=8 s=selected g=+200+100 &
  # ------ no result is waited here ------
  #-> doctest

#####################################################################
# DEBUG: uncomment the next line to use "bb message1 message2 ..."
# source ~/PG/bb.tcl
#####################################################################

package require Tk

namespace eval ::em {
  variable em_version "e_menu 3.4.8a4"
  variable solo [expr {[info exist ::em::executable] || ( \
  [info exist ::argv0] && [file normalize $::argv0] eq [file normalize [info script]])} ? 1 : 0]
  variable Argv0
  if {$solo} {set Argv0 [file normalize $::argv0]} {set Argv0 [info script]}
  if {[info exist ::em::executable]} {set Argv0 [file dirname $Argv0]}
  variable Argv; if {[info exist ::argv]} {set Argv $::argv} {set Argv [list]}
  variable Argc; if {[info exist ::argc]} {set Argc $::argc} {set Argc 0}
  variable exedir [file normalize [file dirname $Argv0]]
  if {[info exists ::e_menu_dir]} {set exedir $::e_menu_dir}
  variable srcdir [file join $exedir src]
  if {[info commands ::baltip::configure] eq {}} {
    source [file join $::em::srcdir baltip baltip.tcl]
  }
  if {!$solo} {append em_version " / [file tail $::em::Argv0]"}
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

set ::em::lin_console [file join $::em::srcdir run_pause.sh]  ;# (for Linux)
set ::em::win_console [file join $::em::srcdir run_pause.bat] ;# (for Windows)

set ::em::ncolor -2  ;# default color scheme
if {$::em::solo} {set ::em::ncolor 0}

# *******************************************************************
# internal trifles:
#   M - message
#   Q - question
#   T - terminal's command
#   S - OS command/program
#   IF - conditional execution
#   EXIT - close menu

proc ::M {cme args} {
  if {[regexp "^-centerme " $cme]} {
    set msg ""
  } else {
    set msg "$cme "
    set cme "-centerme .em"
  }
  if {[set ontop [::apave::getOption -ontop {*}$args]] eq {}} {set ontop $::em::ontop}
  foreach a $args {append msg "$a "}
  ::em::em_message $msg ok Info -ontop $ontop {*}$cme
}
proc ::Q {ttl mes {typ okcancel} {icon warn} {defb OK} args} {
  if {[lsearch $args -centerme]<0} {lappend args -centerme .em}
  if {[set ontop [::apave::getOption -ontop {*}$args]] eq {}} {set ontop $::em::ontop}
  return [set ::em::Q [::em::em_question $ttl $mes $typ $icon $defb {*}$args -ontop $ontop]]
}
proc ::T {args} {
  set cc ""; foreach c $args {set cc "$cc$c "}
  ::em::shell_run "Nobutt" "S:" shell1 - "&" [string map {"\\n" "\r"} $cc]
}
proc ::S {incomm} {
  foreach comm [split [string map {\\n \n} $incomm] \n] {
    if {[set comm [string trim $comm]] ne ""} {
      set comm [string map {\\\\n \\n} $comm]
      set clst [split $comm]
      set com0 [lindex $clst 0]
      if {$com0 eq "cd"} {
        ::em::vip comm
      } elseif {[set com1 [auto_execok $com0]] ne ""} {
        exec -ignorestderr -- $com1 {*}[lrange $clst 1 end] &
      } else {
        M Can't find the command: \n$com0
      }
    }
  }
}
proc ::EXIT {} {::em::on_exit}

# ________________________ em's procedures _________________________ #


namespace eval ::em {

  proc init_arrays {} {
    uplevel 1 {
      foreach ar {pars itnames bgcolr saveddata \
      ar_s09 ar_u09 ar_i09 ar_geany ar_tformat ar_macros} {
        catch {array unset ::em::$ar}
        variable $ar; array set ::em::$ar [list]
      }
    }
  }

## ________________________ Variables _________________________ ##

  variable menuttl "$::em::em_version"
  variable thisapp emenuapp
  variable appname $::em::thisapp
  variable fs 9           ;# font size
  variable font_f1 [font config TkSmallCaptionFont]
  variable font_f2 [font config TkDefaultFont]
  variable viewed 40      ;# width of item (in characters)
  variable maxitems 64    ;# maximum of menu.txt items
  variable timeafter 10   ;# interval (in sec.) for updating times/dates
  variable offline false  ;# set true for offline help
  variable ratiomin 3/5
  variable hotsall \
    {0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,./}
  variable hotkeys $::em::hotsall
  variable workdir {} PD {} pd {} prjname {} PN2 {} prjdirlist [list]
  variable ornament -1  ;# -2 none  -1 - top line only; 0 - Help/Exec/Shell 1 - +header 2 - +prompt; 3 - all
  variable inttimer 1  ;# interval to check the timed tasks
  variable bd 1 b0 0 b1 0 b2 1 b3 1 b4 1
  variable incwidth 15
  variable wc 0
  variable tf 10 tg 80x24+200+200
  variable om 1
  #---------------
  variable R_mute {*S*}
  variable R_exit {; ::em::on_exit 0}
  variable R_ampmute "&$::em::R_mute"
  variable R_ampexit "&$::em::R_exit"
  variable R_ampmuteexit "$::em::R_ampmute$::em::R_exit"
  variable IF_exit 0 ;# false when %IF performed neither %THEN nor %ELSE
  variable begin 1 begtcl 3
  variable begsel $::em::begtcl
  #---------------
  variable editor {}
  variable percent2 {}
  #---------------
  variable seltd {} useltd {} qseltd {} dseltd {} sseltd {} pseltd {}
  variable ontop 0 dotop 0
  variable extraspaces {      } extras true
  variable ncmd 0  ;# number of the current menu's commands
  variable lasti 1 savelasti -1
  variable minwidth 0
  #---------------
  init_arrays
  #---------------
  variable itviewed 0
  variable geometry {} ischild 0
  variable menufile [list 0] menufilename {} menuoptions {}
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
  variable skipfocused 0 shadowed 0
  variable back 0
  variable basedir {}
  variable conti "\\" lconti 0
  variable filecontent {}
  variable truesel 0
  variable ln 0 cn 0 yn 0 dk {}
  variable ismenuvars 0 optsFromMenu 1
  variable linuxconsole {}
  variable insteadCSlist [list]
  variable source_addons true
  variable empool [list]
  variable hili no
  variable ls {} pk {}
  variable DF kdiff3 BF {}
  variable PI 0
  variable NE 0
}
#___ creates an item for the menu pool
proc ::em::pool_item_create {} {
  set poolitem [list]
  foreach v [info vars ::em::*] {
    if {$v ne "::em::empool"} {
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
#___ checks if a menu pool is here
proc ::em::pool_level {{lev 1}} {
  return [expr {[llength $::em::empool]>$lev}]
}
#___ activates a menu pool item
proc ::em::pool_item_activate {{idx "end"}} {
  foreach pit [lindex $::em::empool $idx] {
    lassign $pit t v vval
    if {$t eq "array"} {
      array set $v $vval
    } else {
      set $v $vval
    }
  }
}
#___ changes a top item in the menu pool (1st record is basic => not changed)
proc ::em::pool_set {} {
  if {[set ok [::em::pool_level]]} {
    lset ::em::empool end [::em::pool_item_create]
  }
  return $ok
}
#___ adds an item to the menu pool
proc ::em::pool_push {} {
  if {$::em::solo} return
  lappend ::em::empool [::em::pool_item_create]
}
#___ pulls a top item from the menu pool (1st record is basic => not pulled)
proc ::em::pool_pull {} {
  if {[set ok [::em::pool_level]]} {
    ::em::pool_item_activate end
    set ::em::empool [lrange $::em::empool 0 end-1]
  }
  return $ok
}
#___ checks if the menu is a child
proc ::em::is_child {} {
  return [expr {$::em::ischild || [::em::pool_level 2]}]
}
#___ source addons and call a function of these
proc ::em::addon {func args} {
  if {$::em::source_addons} {
    set ::em::source_addons false
    source [file join $::em::srcdir e_addon.tcl]
  }
  $func {*}$args
}
#___ check a completeness of colors replacing CS (with fg=/bg=)
proc ::em::insteadCS {{replacingCS "_?_"}} {
  if {$replacingCS eq "_?_"} {set replacingCS $::em::insteadCSlist}
  return [expr {[llength $replacingCS]>=14}]
}
#___ set colors for dialogs
proc ::em::theming_pave {} {
  if {!$::em::solo} return
  # ALL colors set as arguments of e_menu: fg=, bg=, fE=, bE=, fS=, bS=, cc=, ht=
  if {[::em::insteadCS]} {
    set themecolors [list $::em::clrfg $::em::clrbg $::em::clrfE \
      $::em::clrbE $::em::clrfS $::em::clrbS grey $::em::clrbg \
      $::em::clrcc $::em::clrht $::em::clrhh $::em::fI $::em::bI \
      $::em::fM $::em::bM]
    ::apave::obj themeWindow . $themecolors false
  } else {
    set themecolors [list $::em::clrinaf $::em::clrinab $::em::clrtitf \
      $::em::clrtitb $::em::clractf $::em::clractb grey $::em::clrinab \
      $::em::clrcurs $::em::clrhotk $::em::clrhelp $::em::fI $::em::bI \
      $::em::fM $::em::bM]
  }
  ::apave::obj themeWindow . $themecolors [expr {![::em::insteadCS]}]
  foreach clr $themecolors {append thclr "-theme $clr "}
  return $thclr
}
#___ own message/question box
proc ::em::dialog_box {ttl mes {typ ok} {icon info} {defb OK} args} {
  return [::eh::dialog_box $ttl $mes $typ $icon $defb \
    -centerme .em {*}$args] ;# {*}[::em::theming_pave]
}
#___ own message box
proc ::em::em_message {mes {typ ok} {ttl "Info"} args} {
  if {[string match ERROR* [string trimleft $mes]]} {set ico err} {set ico info}
  ::em::dialog_box $ttl $mes $typ $ico OK {*}$args
}
#___ own question box
proc ::em::em_question {ttl mes {typ okcancel} {icon warn} {defb OK} args} {
  return [::em::dialog_box $ttl $mes $typ $icon $defb {*}$args]
}
#___ check is there a header of menu
proc ::em::isheader {} {
  return [expr {$::em::ornament in {1 2 3}} ? 1 : 0]
}
proc ::em::isheader_nohint {} {
  return [expr {[isheader] || $::em::ornament==0} ? 1 : 0]
}
#___ get an item's color
proc ::em::color_button {i {fgbg "fg"}} {
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
#___ get next button index
proc ::em::next_button {i} {
  if {$i>=$::em::ncmd} {set i $::em::begin}
  if {$i<$::em::begin} {set i [expr $::em::ncmd-1]}
  return $i
}
#___ get focused status of menu
proc ::em::isMenuFocused {} {
  return [expr {![winfo exists .em.fr.win] || [.em.fr.win cget -bg] ne $::em::clrgrey}]
}
#___ put i-th button in focus
proc ::em::focus_button {i {doit false}} {
  set last $::em::lasti
  set i [next_button $i]
  if {![winfo exists .em.fr.win.fr$i.butt]} return
  if {![isMenuFocused]} {
    set fg [.em.fr.win.fr$i.butt cget -fg]
    set bg $::em::clrgrey
  } else {
    if {$::em::lasti >= $::em::begin && $::em::lasti < $::em::ncmd} {
      if {[winfo exists .em.fr.win.fr$::em::lasti.arr]} {
        .em.fr.win.fr$::em::lasti.arr configure -bg [color_button $::em::lasti bg]
      }
      if {[winfo exists .em.fr.win.fr$::em::lasti.butt]} {
        .em.fr.win.fr$::em::lasti.butt configure \
          -bg [color_button $::em::lasti bg] -fg [color_button $::em::lasti]
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
#___ move mouse to i-th button
proc ::em::mouse_button {i} {
  focus_button $i
  set i [next_button $i]
  if {![winfo exists .em.fr.win.fr$i.butt]} return
  lassign [split [winfo geom .em.fr.win] +] -> x1 y1
  lassign [split [winfo geom .em.fr.win.fr$i] +x] w - x2 y2
  lassign [split [winfo geom .em.fr.win.fr$i.butt] +x] - h x3 y3
  if {$::em::solo} {
    event generate .em <Motion> -warp 1 -x [expr $x1+$x2+$x3+$w/2] \
    -y [expr $y1+$y2+$y3+$h-5]
  }
}
#___ 'proc' all buttons
proc ::em::for_buttons {proc} {
  set ::em::isep 0
  for {set j $::em::begin} {$j < $::em::ncmd} {incr j} {
    uplevel 1 "set i $j; set b .em.fr.win.fr$j.butt; $proc"
  }
}
#___ get contents of s1 argument (s=,..)
proc ::em::get_seltd {s1} {
  return [lindex [array get ::em::pars $s1] 1]
}
#___ get a calling mode
proc ::em::silent_mode {amp} {
  set silent [string first $::em::R_mute " $amp"]
  if {$silent > 0} {
    set amp [string map [list $::em::R_mute ""] "$amp"]
  }
  return [list $amp $silent]
}
#___ read and write the menu file
proc ::em::read_menufile {} {
  set ch [open $::em::menufilename]
  chan configure $ch -encoding utf-8
  set menudata [read $ch]
  set menudata [::apave::textsplit [string trimright $menudata]]
  close $ch
  return $menudata
}
proc ::em::write_menufile {menudata} {
  ::eh::write_file_untouched $::em::menufilename $menudata
}
#___ save options in the menu file (by default - current selected item)
proc ::em::save_options {{setopt "in="} {setval ""}} {
  if {$setopt eq "in="} {
    if {$::em::savelasti<0} return
    set setval $::em::lasti.$::em::begsel
  }
  set setval "$setopt$setval"
  set menudata [::em::read_menufile]
  set opt [set i [set ifnd1 [set ifndo 0]]]
  foreach line $menudata {
    if {$line eq {[OPTIONS]}} {
      set opt 1
      set ifndo [expr {$i+1}]
    } elseif {$opt} {
      if {[string match "${setopt}*" $line]} {
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
  ::em::write_menufile $menudata
}
#___ initialize values of menu's variables
proc ::em::init_menuvars {domenu options} {
  if {!($domenu && $options)} return
  set opt 0
  foreach line $::em::menufile {
    if {$line eq {[OPTIONS]}} {
      set opt 1
    } elseif {$opt && [run_Tcl_code $line true]} {
      # line of Tcl code - processed already
    } elseif {$opt && [string match {::?*=*} $line]} {
      set ::em::ismenuvars 1
      set ieq [string first = $line]
      set vname [string range $line 0 $ieq-1]
      set vvalue [string range $line $ieq+1 end]
      catch {
        if {![info exist ::$vname]} {
          set ::$vname {}
          ::em::prepr_pn vvalue
          set ::$vname [string map [list \\n \n \\ \\\\] $vvalue]
        }
      }
    } elseif {$line eq {[MENU]} || $line eq {[HIDDEN]}} {
      set opt 0
    }
  }
}
#___ save values of menu's variables in the menu file
proc ::em::save_menuvars {} {
  set menudata [::em::read_menufile]
  set opt [set i 0]
  foreach line $menudata {
    if {$line eq {[OPTIONS]}} {
      set opt 1
    } elseif {$opt && [string match {::?*=*} $line]} {
      lassign [regexp -inline "::(\[^=\]+)=\{1\}(.*)" $line] ==> vname vvalue
      catch {
        if {![regexp "^%\\S" $vvalue]} { ;# don't save for wildcarded
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
  if {$::em::ismenuvars} {::em::write_menufile $menudata}
}
#___ VIP commands need internal processing
proc ::em::vip {refcmd} {
  upvar $refcmd cmd
  if {[string first "%#" $cmd] == 0} {
    # writeable command:
    # get (possibly) saved version of the command
    if {[set cmd [::em::addon writeable_command $cmd]] eq ""} {
      return true ;# here 'cancelled' means 'processed'
    }
    return false
  }
  if {[string first "%P " $cmd] == 0} {
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
    prepr_win cmd "M/"  ;# force converting
    if {[set cd [string trim [string range $cmd 3 end]]] ne "."} {
      catch {set cd [subst -nobackslashes -nocommands $cd]}
      catch {cd $cd}
    }
    return true
  }
  if {$cmd in {"%E" "%e"} || $cd in {"%E " "%e "}} {
    return [::em::addon edit [string range $cmd 3 end]] ;# editor
  }
  return false
}
#___ start autorun lists
proc ::em::run_a_ah {sub} {
  if {[string first "a=" $sub] >= 0} {
    run_auto [string range $sub 2 end]
  } elseif {[string first "ah=" $sub] >= 0} {
    run_autohidden [string range $sub 3 end]
  }
}
#___ parse modes of run
proc ::em::s_assign {refsel {trl 1}} {
  upvar $refsel sel
  set retlist [list]
  set tmp [string trimleft $sel]
  set qpos [expr {$::em::ornament>1 ? [string first ":" $tmp]+1 : 0}]
  if {[string first "?" $tmp] == $qpos} {   ;#?...? sets modes of run
    set prom [string range $tmp 0 [expr {$qpos-1}]]
    set sel [string range $tmp $qpos end]
    lassign {"" 0} el qac
    for {set i 1}  {$i < [string len $sel]} {incr i} {
      if {[set c [string range $sel $i $i]] eq "?" || $c eq " "} {
        if {$c eq " "} {
          set sel [string range $sel [expr $i+1] end]
          if {$trl} {set sel [string trimleft $sel]}
          lappend retlist -1
          set sel $prom$sel
          break
        } else {
          lappend retlist $el
          lassign {"" 1} el qac
        }
      } else {
        set el "$el$c"
      }
    }
  }
  return $retlist
}
#___ replace first %b with browser pathname
proc ::em::checkForWilds {rsel} {
  upvar $rsel sel
  switch -glob -nocase -- $sel {
    "%B *" {
      set sel "::eh::browse [list [string range $sel 3 end]]"
      if {![catch {{*}$sel} e]} {
        return [list true true]
      }
    }
    "%Q *" {
      catch {set sel [subst -nobackslashes -nocommands $sel]}
      lassign $sel Q ttl mes typ icon defb
      set argums [lrange $sel 6 end]
      if {$typ eq ""} {set typ okcancel}
      if {$icon eq ""} {set icon warn}
      if {$defb eq ""} {set defb OK}
      if {[string first "-centerme " $argums]>=0} {
        set cme ""
      } else {
        if {[string match "%q *" $sel]} {
          set cme "-centerme .em"
        } else {
          set cme "-centerme 1"
        }
      }
      if {![catch {Q $ttl $mes $typ $icon $defb {*}$argums {*}$cme} e]} {
        if {[string is true $e]} ::em::save_menuvars
        return [list true $e]
      }
    }
    "%M *" {
      if {![regexp "^%M -centerme " $sel]} {
        set cme "-centerme .em"
      }
      catch {set sel [subst -nobackslashes -nocommands $sel]}
      set sel "M {$cme} [string range $sel 3 end]"
      if {![catch {{*}$sel} e]} {
        return [list true true]
      }
    "%U *" {
      return true ;# not used now
      }
    }
  }
  return false
}
#___ tclsh/tclkit executable
proc ::em::Tclexe {} {
  if {[set tclexe $::em::tc] eq {} && [set tclexe [info nameofexecutable]] eq {}} {
    set tclexe [auto_execok tclsh]
  }
  if {$tclexe eq {}} {
    ::em::em_message "ERROR:\n\nNo Tcl/Tk executable found."
    exit
  }
  return $tclexe
}
#___ replace first %t with terminal pathname
proc ::em::checkForShell {rsel} {
  upvar $rsel sel
  set res no
  if {[string first "%t " $sel] == 0 || \
      [string first "%T " $sel] == 0 } {
    set sel "[string range $sel 3 end]"
    set res yes
  }
  if {[string first "tclsh " $sel]==0 || [string first "wish " $sel]==0} {
    set tclexe [string map {wish.exe tclsh.exe} [Tclexe]]
    set sel [append _ $tclexe [string range $sel [string first { } $sel] end]]
  }
  return $res
}
#___ call command in xterm
proc ::em::xterm {sel amp {term ""}} {
# See also: https://wiki.archlinux.org/index.php/Xterm
  if {$term eq ""} {set term [auto_execok xterm]}
  if {[set lang [::eh::get_language]] ne ""} {set lang "-fa $lang"}
  if {[set _ [string first " " $sel]]<0} {set _ xterm} {set _ [string range $sel 0 $_]}
  set sel "### \033\[32;1mTo copy a text, select it and press Shift+PrtSc\033\[m ###\\n
    \\n[::eh::escape_quotes $sel]"
  set composite "$::em::lin_console $sel $amp"
  set tpars [string range $::em::linuxconsole 6 end]
  set ::em::_tmp "xterm"
  foreach {o v s} {-fs fs tf -geometry geo tg -title ttl _tmp} {
    if {[string first $o $tpars]>=0} {set $v ""} {set $v "$o [set ::em::$s]"}
  }
  ::em::execcom {*}$term {*}$lang {*}$fs {*}$geo {*}$ttl {*}$tpars \
    -e {*}$composite
}
#___ call command in terminal
proc ::em::term {sel amp {term ""}} {
  if {[string match "xterm *" "$::em::linuxconsole "]} {
    ::em::xterm $sel $amp
  } else {
    set sel2 [string map {\\n \n} $sel]
    if {[string match "qterminal *" "$::em::linuxconsole "]} {
      # bad style, for qterminal only
      set sel ""
      foreach l [split $sel2 \n] {
        set l2 [string trimleft $l]
        if {[string match "#*" $l2] || $l2 eq ""} continue
        if {[string match "if *" $l2] || [string match "then" $l2] || [string match "else" $l2] || [string match "while *" $l2] || [string match "for *" $l2]} {
          append sel " $l "
        } else {
          append sel " $l ; "
        }
      }
    } else {
      set sel ""
      foreach l [split $sel2 \n] {
        set l2 [string trimleft $l]
        if {[string match "#*" $l2] || $l2 eq ""} continue
        append sel " $l \\n"
      }
    }
    set composite "$::em::lin_console $sel $amp"
    ::em::execcom {*}$::em::linuxconsole -e {*}$composite
  }
}
#___ exec for ex= parameter
proc ::em::execcom {args} {
  if {$::em::EX eq {} || [string is false $::em::PI]} {
    exec -ignorestderr -- {*}$args
  } else {
    catch {
      set com [string trim "$args" &]
      set pid [pid [open "|$com"]]
      set menudir [file dirname $::em::menufilename]
      ::apave::writeTextFile "$menudir/.pid~" pid
    }
  }
}

#___ call command in shell
proc ::em::shell0 {sel amp {silent -1}} {
  set ret true
  catch {set sel [subst -nobackslashes -nocommands $sel]}
  checkForShell sel
  if {[string first "%IF " $sel] == 0} {
    if {![::em::addon IF $sel sel]} {return false}
  }
  if {[lindex [set _ [checkForWilds sel]] 0]} {
    return [lindex $_ 1]
  } elseif {[run_Tcl_code $sel]} {
    # processed
  } elseif {[::iswindows]} {
    if {[string trim "$sel"] eq ""} {return true}
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
      cmd.exe /c {*}"$composite"} e]} {
      if {$silent < 0} {
        set ret false
      }
    }
  } else {
    if {[string trim "$sel"] eq ""} {return true}
    if {$::em::linuxconsole ne ""} {
      ::em::term $sel $amp
    } elseif {[set term [auto_execok lxterminal]] ne "" } {
      set sel [string map [list "\""  "\\\""] $sel]
      set composite "$::em::lin_console $sel $amp"
      exec -ignorestderr -- {*}$term --geometry=$::em::tg -e {*}$composite
    } elseif {[set term [auto_execok xterm]] ne "" } {
      ::em::xterm $sel $amp $term
    } else {
      set ret false
      set e "Not found lxterminal nor xterm.\nInstall any."
    }
  }
  if {$silent < 0 && !$ret} {
    em_message "ERROR of running\n\n$sel\n\n$e"
  }
  return $ret
}
#___ run a code of Tcl
proc ::em::run_Tcl_code {sel {dosubst false}} {
  if {[string first "%C" $sel] == 0} {
    if {[catch {
      set sel [string range $sel 3 end]
      if {$dosubst} {
        prepr_pn sel
        set sel [subst -nobackslashes -nocommands $sel]
      }
      if {[string match "eval *" $sel]} {
        {*}$sel
      } else {
        eval $sel
      }
    } e]} {
      em_message "ERROR of running\n\n$sel\n\n$e"
      return false
    }
    return true
  }
  return false
}
#___ exec a command
proc ::em::execom {comm} {
  set argm [lrange $comm 1 end]
  set comm1 [lindex $comm 0]
  if {$comm1 eq "%O"} {
    ::apave::openDoc $argm
  } else {
    set comm2 [auto_execok $comm1]
    if {[catch {exec -- $comm2 {*}$argm} e]} {
      if {$comm2 eq ""} {
        return "couldn't execute \"$comm1\": no such file or directory"
      }
      return $e
    }
  }
  return ""
}
#___ run a program of sel
proc ::em::run0 {sel amp silent} {
  if {![vip sel]} {
    if {[lindex [set _ [checkForWilds sel]] 0]} {
      return [lindex $_ 1]
    } elseif {[run_Tcl_code $sel]} {
      # processed already
    } elseif {[string first "%I " $sel] == 0} {
      return [::em::addon input $sel]
    } elseif {[string first "%S " $sel] == 0} {
      S [string range $sel 3 end]
    } elseif {[string first "%IF " $sel] == 0} {
      return [::em::addon IF $sel]
    } elseif {[checkForShell sel]} {
      shell0 $sel $amp $silent
    } else {
      set comm "$sel $amp"
      if {[::iswindows]} {
        set comm "cmd.exe /c $comm"
      }
      catch {set comm [subst -nobackslashes -nocommands $comm]}
      if {[set e [execom $comm]] ne ""} {
        if {$silent < 0} {
          em_message "ERROR of running\n\n$sel\n\n$e"
          return false
        }
      }
    }
  }
  return true
}
#___ run a program of menu item
proc ::em::run1 {typ sel amp silent} {
  prepr_prog sel $typ  ;# prep
  prepr_idiotic sel 0
  catch {set sel [subst -nobackslashes -nocommands $sel]}
  return [run0 $sel $amp $silent]
}
#___ call command in shell
proc ::em::shell1 {typ sel amp silent} {
  prepr_prog sel $typ  ;# prep
  prepr_idiotic sel 0
  if {[vip sel]} {return true}
  if {[::iswindows] || $amp ne "&"} {focused_win false}
  set ret [shell0 $sel $amp $silent]
  if {[::iswindows] || $amp ne "&"} {focused_win true}
  return $ret
}
#___ update item name (with inc)
proc ::em::update_itname {it inc {pr ""}} {
  catch {
    if {$it > $::em::begsel} {
      set b .em.fr.win.fr$it.butt
      if {[$b cget -image] eq ""} {
        if {$::em::ornament > 1} {
          set ornam [$b cget -text]
          set ornam [string range $ornam 0 [string first ":" $ornam]]
        } else {set ornam ""}
        set itname $::em::itnames($it)
        if {$pr ne ""} {{*}$pr}
        prepr_09 itname ::em::ar_i09 "i" $inc  ;# incr N of runs
        prepr_idiotic itname 0
        $b configure -text [set comtitle $ornam$itname]
        catch {::baltip tip $b "$comtitle"}
      }
    }
  }
}
#___ update all buttons
proc ::em::update_buttons {{pr ""}} {
  for_buttons {
    update_itname $i 0 $pr
  }
}
#___ update all buttons' names
proc ::em::update_buttons_pn {} {
  update_buttons "prepr_pn itname"
}
#___ update all buttons' date/time
proc ::em::update_buttons_dt {} {
  update_buttons_pn
  repeate_update_buttons  ;# and re-run itself
}
#___ update buttons with time/date
proc ::em::repeate_update_buttons {} {
  after [expr $::em::timeafter * 1000] ::em::update_buttons_dt
}
#___ select item from a menu
proc ::em::Select_Item {{ib {}}} {
  if {$ib eq {}} {set ib $::em::lasti}
  set butt .em.fr.win.fr$ib.butt
  if {$::eh::pk ne {} && [winfo exists $butt]} {
    set ::eh::retval [list $::em::menufilename $ib [string trim [$butt cget -text]]]
    ::em::on_exit 1
  }
}
#___ repeat run/shell once in a cycle
proc ::em::Shell_Run {from typ c1 s1 amp inpsel} {
  set cpwd [pwd]
  set inc 1
  set doexit 0
  foreach n [array names ::em::saveddata] {
    # if a dialogue saved its variables, initialize them the same way as at start
    # (see ::em::init_menuvars and ::em::input)
    set $n [string map [list \\n \n \\ \\\\] $::em::saveddata($n)]
    unset ::em::saveddata($n)
  }
  if {$inpsel eq ""} {
    set inpsel [get_seltd $s1]
    lassign [silent_mode $amp] amp silent  ;# silent_mode - in 1st line
    lassign [s_assign inpsel] p1 p2
    if {$p1 ne ""} {
      if {$p2 eq ""} {
        set silent $p1
      } else {
        if {![::em::addon set_timed $from $p1 $typ $c1 $inpsel]} {return}
        set silent $p2
      }
    }
  } else {
    if {$amp eq "noamp"} {
      lassign {"" -1} amp silent
    } else {
      lassign {"&" -1} amp silent
    }
  }
  foreach seltd [split $inpsel "\n"] {
    set doexit 0
    if {[set r [string first "\r" $seltd]] > 0} {
      lassign [split $seltd "\r"] runp seltd
      if {[string first "::em::run" $runp] != -1} {
        set c1 "run1"
      } else {
        set c1 "shell1"
      }
      if {[string last $::em::R_ampmute $runp]>0 ||
          [string last $::em::R_ampexit $runp]>0} {set amp &} {set amp ""}
      if {[string last $::em::R_exit $runp]>0} {set doexit 1}
    }
    prepr_09 seltd ::em::ar_i09 "i"   ;# set N of runs in command
    set ::em::IF_exit 1
    if {![$c1 $typ "$seltd" $amp $silent] || $doexit > 0} {
      if {$::em::IF_exit} {
        set inc 0  ;# unsuccessful run
        break
      }
    }
  }
  if {$doexit > 0} {::em::on_exit 0}
  if {$inc} {                        ;# all buttons texts may need to update
    update_itname $::em::lasti $inc  ;# because all may include %s1, %s2...
  }
  update_buttons_pn
  update idletasks
  catch {cd $cpwd}  ;# may be deleted by commands
}
#___ run/shell
proc ::em::shell_run {from typ c1 s1 amp {inpsel ""}} {
  set ib [string range $s1 1 end]
  set butt .em.fr.win.fr$ib.butt
  if {$::eh::pk ne {} && [winfo exists $butt]} {
    # e_menu was called to pick an item
    ::em::Select_Item $ib
    return
  }
  # repeat input dialogues: set by ::em::NE in .mnu or by NE=1 argument of e_menu
  set ::em::inputResult 0
  while {1} {
    ::em::Shell_Run $from $typ $c1 $s1 $amp $inpsel
    if {!$::em::inputResult || !$::em::NE} break
  }
}
#___ run commands before a submenu
proc ::em::before_callmenu {pars} {
  set cpwd [pwd]
  set menupos [string last "\n::em::callmenu" $pars]
  if {$menupos>0} {  ;# there are previous commands (in M: ... M: lines)
    set commands [string range $pars 0 $menupos-1]
    foreach com [split $commands \r] {
      set com [lindex [split $com \n] 0]
      if {$com ne ""} {
        if {![run0 $com "" 0]} {
          set pars ""
          break
        }
      }
    }
    set pars [string range $pars [string last \r $pars]+1 end]
  }
  catch {cd $cpwd}  ;# may be deleted by commands
  return $pars
}
#___ call a submenu
proc ::em::callmenu {typ s1 {amp ""} {from ""}} {
  save_options
  set pars [get_seltd $s1]
  set pars [before_callmenu $pars]
  if {$pars eq ""} return
  set noME [expr {[string range $typ 0 1] ne "ME"}]
  set stay [expr {$noME || $::em::ontop}]
  set pars "ch=$stay $::em::inherited a= a0= a1= a2= ah= n= pa=0 $pars"
  set pars [string map [list "b=%b" "b=$::eh::my_browser"] $pars]
  if {$::em::ontop} {
    append pars " t=1"    ;# "ontop" means also "all menus stay on"
  } elseif {!$::em::solo} {
    set stay [expr {$::em::remain || ($noME && [::em::pool_level])}]
  }
  if {[::apave::cs_Max] > [::apave::cs_MaxBasic]} {
    append pars " \"cs=[lindex $::apave::_CS_(ALL) [::apave::cs_Max]]\""
  }
  set geo [wm geometry .em]
  set geo [string range $geo [string first + $geo] end]
  # shift the new menu if it's shown above the current one
  if {$::em::solo && ($noME || $::em::ontop)} {
    lassign [split $geo +] -> x y
    set geo +[expr 20+$x]+[expr 30+$y]
  }
  if {$::em::ex eq {}} {set pars "g=$geo $pars"}
  append pars " ex= EX= PI=0"
  prepr_1 pars "in" [string range $s1 1 end]  ;# %in is menu's index
  set sel "\"$::em::Argv0\""
  prepr_win sel "M/"  ;# force converting
  if {$::em::solo} {
    catch {exec -- [::em::Tclexe] {*}$sel {*}$pars $amp}
    if {$amp eq ""} {
      ::em::reread_menu $::em::lasti  ;# changes possible
    }
  } else {
    ::em::pool_set
    set ::em::Argv [list {*}$pars]
    set ::em::Argc [llength $::em::Argv]
    if {!$stay} {::em::pool_set}
    ::em::pool_push
    set ::em::em_win_var 1
  }
}
#___ run "seltd" as a command
proc ::em::run {typ s1 {amp ""} {from ""}} {
  save_options
  shell_run $from $typ run1 $s1 $amp
}
#___ shell "seltd" as a command
proc ::em::shell {typ s1 {amp ""} {from ""}} {
  save_options
  shell_run $from $typ shell1 $s1 $amp
}
#___ logging
proc ::em::log {oper} {
  if {$::eh::pk eq {}} {
    catch {puts "$::em::menuttl - $oper: $::em::lasti"}
  }
}
#___ procs for HELP/EXEC/SHELL/MENU items run by button pressing
proc ::em::help_button {help} {
  ::eh::browse [::eh::html $help $::em::offline]
  on_exit 0
}
proc ::em::run_button {typ s1 {amp ""}} {
  run $typ $s1 $amp "button"
  log Run
}
proc ::em::shell_button {typ s1 {amp ""}} {
  shell $typ $s1 $amp "button"
  log Shell
}
proc ::em::callmenu_button {typ s1 {amp ""}} {
  callmenu $typ $s1 $amp "button"
}
#___ run a command after keypressing
proc ::em::pr_button {ib args} {
  focus_button $ib  ;# to see the selected
  set comm "$args"
  if {[set i [string first " " $comm]] > 2} {
    set comm "[string range $comm 0 [expr $i-1]]_button
                [string range $comm $i end]"
  }
  {*}$comm
  if {[string first "?" [set txt [.em.fr.win.fr$ib.butt cget -text]]]>-1 ||
  [string match *... [string trimright $txt]]} {
    reread_menu $::em::lasti  ;# after dialogs, the menu may be changed
  } else {
    repaintForWindows
  }
}
#___ get array index of i-th menu item
proc ::em::get_s1 {i hidden} {
  if {$hidden} {return "h$i"} {return "m$i"}
}
#___ get working (project's) dir
proc ::em::get_PD {{lookdir ""} {lookP2 1}} {
  if {$lookdir eq ""} {
    set ldir $::em::workdir
  } else {
    set ldir $lookdir  ;# this mode - to get PN2 from $lookdir
  }
  set lP2 ""
  if {[llength $::em::prjdirlist]>0} {
    # workdir got from a current file (if not passed, got a current dir)
    if {$lookdir eq ""} {
      if {[catch {set ldir $::em::ar_geany(d)}] && \
          [catch {set ldir [file dirname $::em::ar_geany(f)]}]} {
        set ldir [pwd]
      }
    }
    foreach wd $::em::prjdirlist {
      lassign $wd wd p2  ;# second item may set %P2
      if {[string first [string toupper $wd] [string toupper $ldir]]==0} {
        set ldir $wd
        set lP2 $p2
        break
      }
    }
  }
  if {![file isdirectory $ldir]} {set ldir [pwd]}
  if {$lP2 eq ""} {set lP2 $ldir}
  set lP2 [::eh::get_underlined_name [file tail $lP2]]
  if {$lookdir eq ""} {
    if {$::em::prjset != 2} {
      set ::em::prjname [set ::em::PN2 $lP2]
    }
    set ::em::workdir $ldir
  } else {
    if {$lookP2} {set ldir $lP2}
  }
  return [file nativename $ldir]
}
#___ get %PD underlined
proc ::em::get_P_ {} {
  return [::eh::get_underlined_name $::em::workdir]
}
#___ get contents of %f file (supposedly, there can be only one "%f" value)
proc ::em::read_f_file {} {
  if {$::em::filecontent=={} && [info exists ::em::ar_geany(f)]} {
    if {[file isfile $::em::ar_geany(f)] && [file size $::em::ar_geany(f)]<1048576} {
      set ::em::filecontent [::apave::readTextFile $::em::ar_geany(f)]
      set ::em::filecontent [::apave::textsplit $::em::filecontent]
    }
  }
  if {[llength $::em::filecontent] < 2 && $::em::filecontent in {{} -}} {
    set ::em::filecontent - ;# no content; don't read it again
    return 0
  }
  return [llength $::em::filecontent]
}
#___ get contents of #ARGS..: or #RUNF..: line
proc ::em::get_AR {} {
  if {$::em::truesel && $::em::seltd ne {}} {
    ;# %s is preferrable for ARGS (ts= rules)
    return [list [string map {\n \\n \" \\\"} $::em::seltd]]
  }
  if {[::em::read_f_file]} {
    set ar {^[[:space:]#/*]*#[ ]?ARGS[0-9]+:[ ]*(.*)}
    set rf {^[[:space:]#/*]*#[ ]?RUNF[0-9]+:[ ]*(.*)}
    set ee {^[[:space:]#/*]*#[ ]?EXEC[0-9]+:[ ]*(.*)}
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
        if {"$AR$RF$EE" eq {OFF}} {return {}}
        return [list $AR $RF $EE]
      }
    }
  }
  return {}
}
#___ get contents of %l-th line of %f file
proc ::em::get_L {} {
  if {![catch {set p $::em::ar_geany(l)}] && \
       [string is digit $p] && $p>0 && $p<=[llength $::em::filecontent]} {
    return [lindex $::em::filecontent $p-1]
  }
  return ""
}
#___ Mr. Preprocessor of s0-9, u0-9
proc ::em::prepr_09 {refn refa t {inc 0}} {
  upvar $refn name
  upvar $refa arr
  for {set i 0} {$i<=9} {incr i} {
    set p "$t$i"
    set s "$p="
    if {[string first $p $name] != -1} {
      if {![catch {set sel $arr($s)} e]} {
        if {$t eq "i"} {
          incr sel $inc     ;# increment i1-i9 counters of runs
          set ${refa}($s) $sel
        }
        prepr_1 name $p $sel
      }
    }
  }
}
#___ get the current menu name
proc ::em::get_menuname {seltd} {
  if {$::em::basedir ne ""} {
    set seltd [file join $::em::basedir $seltd]
  }
  if {![file exists "$seltd"]} {
    set seltd [file join $::em::exedir $seltd]
  }
  return $seltd
}
#___ Mr. Preprocessor of %-wildcards
proc ::em::prepr_1 {refpn s ss} {
  upvar $refpn pn
  set pn [string map [list "%$s" $ss] $pn]
}
#___ Mr. Preprocessor of dates
proc ::em::prepr_dt {refpn} {
  upvar $refpn pn
  set oldpn $pn
  lassign [::eh::get_timedate] curtime curdate curdt curdw systime
  prepr_1 pn "t0" $curtime               ;# %t0 time
  prepr_1 pn "t1" $curdate               ;# %t1 date
  prepr_1 pn "t2" $curdt                 ;# %t2 date & time
  prepr_1 pn "t3" $curdw                 ;# %t3 week day
  foreach tw [array names ::em::ar_tformat] {
    set time [clock format $systime -format $::em::ar_tformat($tw)]
    prepr_1 pn "$tw" $time
  }
  return [expr {$oldpn ne $pn} ? 1 : 0]   ;# to update time in menu
}
#___ Mr. Preprocessor idiotic
proc ::em::prepr_idiotic {refpn start } {
  upvar $refpn pn
  set idiotic "~Fb^D~"
  if {$start} {
      # this must be done just before other preps:
    set pn [string map [list "%%" $idiotic] $pn]
    prepr_call pn
  } else {
      # this must be done just after other preps and before applying:
    set pn [string map [list $idiotic "%"] $pn]
    set pn [string map [list "%TN" $::em::TN] $pn]
    set pn [string map [list "%TI" $::em::ipos] $pn]
  }
}
#___ Mr. Preprocessor initial
proc ::em::prepr_init {refpn} {
  upvar $refpn pn
  prepr_idiotic pn 1
  prepr_1 pn "+"  $::em::pseltd ;# %+  is %s with " " as "+"
  prepr_1 pn "qq" $::em::qseltd ;# %qq is %s with quotes escaped
  prepr_1 pn "dd" $::em::dseltd ;# %dd is %s with special simbols deleted
  prepr_1 pn "ss" $::em::sseltd ;# %ss is %s trimmed
  prepr_09 pn ::em::ar_s09 "s"  ;# s1-s9 params
  prepr_09 pn ::em::ar_u09 "u"  ;# u1-u9 params underscored
  set delegator {}
  for {set i 1} {$i<=19} {incr i} {
    if {$i <= 9} {set d "s$i="} {set d "u[expr $i-10]="}
    lappend delegator $d
  }
  foreach d $delegator {             ;# delegating values:
    set i [string range $d 0 0]    ;# s0 -> s9 -> u0 -> u9
    catch {
      if {$i eq "s"} {
        set el $::em::ar_s09($d)
        prepr_09 el ::em::ar_s09 s
        prepr_09 el ::em::ar_u09 u
        set ::em::ar_s09($d) $el
      } else {
        set el $::em::ar_u09($d)
        prepr_09 el ::em::ar_s09 s
        prepr_09 el ::em::ar_u09 u
        set ::em::ar_u09($d) [string map [list " " "_"] $el]
      }
    }
  }
}
#___ initialization of selection (of %s wildcard)
proc ::em::init_swc {} {
  if {$::em::seltd ne "" || $::em::ln<=0 || $::em::cn<=0} {
    return  ;# selection is provided or ln=/cn= are not - nothing to do
  }
  if {[::em::read_f_file]} {     ;# get the selection as a word under caret
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
#___ Mr. Preprocessor of 'prog'/'name'
proc ::em::prepr_pn {refpn {dt 0}} {
  upvar $refpn pn
  prepr_idiotic pn 1
  # these replacements go before geany's to avoid replacing %D, %l
  prepr_1 pn "DF" $::em::DF                 ;# %DF is a name of diff tool
  prepr_1 pn "BF" $::em::BF                 ;# %BF is a name of backup file
  prepr_1 pn "pd" $::em::pd                 ;# %pd is a project directory
  prepr_1 pn "lg" [::eh::get_language]      ;# %lg is a locale (e.g. ru_RU.utf8)
  prepr_1 pn "ls" [nativePathes $::em::ls]  ;# %ls is a list of files
  foreach n [array names ::em::ar_geany] {
    set v $::em::ar_geany($n)
    if {$n in {f d}} {
      set v [nativePath $v]  ;# as Windows' pathes use backslash (escaping char in Tcl)
    }
    prepr_1 pn $n $v
  }
  init_swc
  set PD [get_PD]
  prepr_1 pn "PD" [nativePath $PD]    ;# %PD is passed project's dir (PD=)
  prepr_1 pn "P2" $::em::PN2          ;# %P2 is a project's nickname
  prepr_1 pn "P_" [get_P_]            ;# ...underlined PD
  prepr_1 pn "PN" $::em::prjname      ;# %PN is passed dir's tail
  prepr_1 pn "N"  $::em::appN         ;# ID of menu application
  prepr_1 pn "mn" $::em::menufilename ;# %mn is the current menu
  prepr_1 pn "ms" $::em::srcdir       ;# %ms is e_menu/src dir
  prepr_1 pn "m"  $::em::exedir       ;# %m is e_menu.tcl dir
  prepr_1 pn "s"  $::em::seltd        ;# %s is a selected text
  prepr_1 pn "u"  $::em::useltd       ;# %u is %s underscored
  prepr_1 pn "+"  $::em::pseltd ;# %+  is %s with " " as "+"
  prepr_1 pn "qq" $::em::qseltd ;# %qq is %s with quotes escaped
  prepr_1 pn "dd" $::em::dseltd ;# %dd is %s with special simbols deleted
  prepr_1 pn "ss" $::em::sseltd ;# %ss is %s trimmed
  lassign [get_AR] AR RF EE
  prepr_1 pn "AR" $AR                 ;# %AR is contents of #ARGS..: line
  prepr_1 pn "RF" $RF                 ;# %RF is contents of #RUNF..: line
  prepr_1 pn "EE" $EE                 ;# %EE is contents of #EXEC..: line
  prepr_1 pn "L"  [get_L]             ;# %L is contents of %l-th line
  prepr_1 pn "TT" [::eh::get_tty $::em::linuxconsole] ;# %TT is a terminal
  set pndt [prepr_dt pn]
  if {$dt} {return $pndt} {return $pn}
}
#___ convert all Windows' "\" to Unix' "/"
proc ::em::prepr_win {refprog typ} {
  upvar $refprog prog
  if {[string last "/" $typ] > 0} {
    set prog [string map {"\\" "/"} $prog]
  }
}
#___ Mr. Preprocessor of 'prog'
proc ::em::prepr_prog {refprog typ} {
  upvar $refprog prog
  prepr_pn prog
  prepr_win prog $typ
}
#___ Mr. Preprocessor of 'name'
proc ::em::prepr_name {refname {aft 0}} {
  upvar $refname name
  return [prepr_pn name $aft]
}
#___ Mr. Preprocessor of 'call'
proc ::em::prepr_call {refname} { ;# this must be done for e_menu call line only
  upvar $refname name
  if {$::em::percent2 ne ""} {
    set name [string map [list $::em::percent2 "%"] $name]
  }
  prepr_1 name "PD" [get_PD]
  prepr_1 name "PN" $::em::prjname
  prepr_1 name "N" $::em::appN
}
#___ toggle 'stay on top' mode
proc ::em::toggle_ontop {} {
  wm attributes .em -topmost $::em::ontop
  if {$::em::ontop} {
    .em.fr.cb configure -fg $::em::clrhelp
  } else {
    .em.fr.cb configure -fg $::em::clrinaf
  }
}
#___ get menu item
proc ::em::menuit {line lt left {a 0}} {
  set i [string first $lt $line]
  if {$i < 0} {return ""}
  if {$left} {
    return [string range $line 0 [expr $i+($a)]]
  } else {
    return [string range $line [expr $i+[string length $lt]] end]
  }
}
#___ expand $macro (%M1, %MA ...) for $line marked with $lmark (R:, R/ ...)
proc ::em::expand_macro {lmark macro line} {
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
    ::em::em_message "ERROR:\n\nMacro $mc parameters and arguments don't agree:\n  $n1 not equal $n2"
    return
  }
  set i1 [string first $lmark $line]
  set i2 [string first $lmark $line $i1+1]
  set lname [string range $line $i1+[string length $lmark] $i2-1]
  foreach line [lrange $::em::ar_macros($mc) 1 end] {
    if {[set i [string first ":" $line]]<0 && \
        [set i [string first "/" $line]]<0} {
      ::em::em_message "ERROR:\n\nMacro $mc error in line:\n  $line"
      return
    }
    set lmark [string range $line 0 $i]
    set line "$lmark$lname$lmark[string range $line $i+1 end]"
    foreach par $parlist arg $arglist {
      set par "\$[string trim $par]"
      if {$par ne "\$"} {
        set line [string map [list $par [string trim $arg]] $line]
      }
    }
    lappend ::em::menufile $line
  }
}
#___ get all markers for menu item
proc ::em::allMarkers {} {
  return [list S: R: M: S/ R/ M/ SE: RE: ME: SE/ RE/ ME/ SW: RW: MW: SW/ RW/ MW/ I:]
}
#___ check for and insert macro, if any
proc ::em::check_macro {line} {
  set line [string trimleft $line]
  set s1 I:
  if {[string first $s1 $line] != 0} {
    set s1 {}
    foreach marker [::em::allMarkers] {
      if {[string first $marker $line] == 0} {
        set s1 $marker
        break
      }
    }
  }
  if {$s1 ne ""} {
    #check for macro %M1..%M9, %Ma..%Mz, %MA..%MZ
    set im [expr {[string first $s1 $line 3]+[string length $s1]}]
    set s2 [string trimleft [string range $line $im end]]
    if {[regexp {^%M[^ ] } $s2]} {
      ::em::expand_macro $s1 $s2 $line
      return
    }
  }
  lappend ::em::menufile $line
}
#___ read menu file
proc ::em::menuof {commands s1 domenu} {
  upvar $commands comms
  set seltd [get_seltd $s1]
  if {$domenu} {
    if {$::em::basedir eq ""} {
      set ::em::basedir [file join $::em::exedir menus]
    }
    set seltd [file normalize [get_menuname $seltd]]
    set fcont [::apave::textsplit [::apave::readTextFile $seltd]]
    if {[llength $fcont]==0} {
      set cr [::em::addon create_template $seltd]
      if {!$::em::solo} {set ::em::reallyexit [expr {$cr ? 2 : 1}]}
      set ::em::start0 0  ;# no more messages
      return
    }
    set ::em::menufilename "$seltd"
    set ::em::menufile [list 0]
    set lcont [llength $fcont]
  }
  set prname ?
  set iline $::em::begsel
  set doafter false
  set lappend {lappend comms}
  set ::em::commhidden [list 0]
  set hidden [set options [set ilmenu 0]]
  set separ {}
  set icont [set isopt 0]
  while {1} {
    if {$domenu} {
      set line {}
      while {$icont<$lcont} { ;# lines ending with " \" or ::em::conti to be continued
        set tmp [lindex $fcont $icont]
        incr icont
        switch $tmp {
          {[OPTIONS]} {set isopt 1}
          {[MENU]} - {[HIDDEN]} {set isopt 0}
        }
        set skip [expr {$isopt && [string match {::?*=*} $tmp]}]
        if {!$skip && [string range $tmp end end] eq "\\"} {
          append line [string range $tmp 0 end-1]
        } elseif {!$skip && $::em::conti ne "\\" && $::em::conti ne {} && \
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
      ::em::check_macro $line
    } else {
      incr ilmenu
      if {$ilmenu >= [llength $::em::menufile]} {break}
      set line [lindex $::em::menufile $ilmenu]
    }
    set line [set origline [string trimleft $line]]
    if {$line eq {[MENU]}} {
      ::em::init_menuvars $domenu $options
      set options [set hidden 0]
      continue
    }
    if {$line eq {[OPTIONS]}} {
      set options 1
      set hidden 0
      continue
    }
    if {$line eq {[HIDDEN]}} {
      ::em::init_menuvars $domenu $options
      set hidden 1
      set options 0
      set lappend "lappend ::em::commhidden"
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
    set typ [menuit $line ":" 1]
    if {[set l [string length $typ]] < 1 || $l > 3} {
      set typ [menuit $line "/" 1]
    }
    if {[set l [string length $typ]] < 1 || $l > 3} {
      set prname "?"
      continue
    }
    set line [menuit $line $typ 0]
    set name [menuit $line $typ 1 -1]
    set prog [string trimleft [menuit $line $typ 0]]
    prepr_init name
    # prepr_init prog  ;# v1.49: don't preprocess commands till their call
    prepr_win name "//"  ;# forced 'name' without escapes
    prepr_win prog $typ
    catch {set name [subst $name]}  ;# any substitutions in names
    switch -- $typ {
      "I:" {   ;#internal (M, Q, S, T)
        prepr_pn prog
        set prom "RUN INTERNAL"
        set runp "$prog"
      }
      "R/" -
      "R:"  {set prom "RUN         "
        set runp "::em::run $typ";   set amp $::em::R_ampmute
      }
      "RE/" -
      "RE:"  {set prom "RUN & EXIT  "
        set runp "::em::run $typ"
        set amp "$::em::R_ampmuteexit $line"
      }
      "RW/" -
      "RW:" {set prom "RUN & WAIT  "
        set runp "::em::run $typ";   set amp $::em::R_mute
      }
      "S/" -
      "S:"  {set prom "SHELL       "
        set runp "::em::shell $typ"; set amp $::em::R_ampmute
      }
      "SE/" -
      "SE:"  {set prom "SHELL & EXIT"
        set runp "::em::shell $typ"
        set amp $::em::R_ampmuteexit
      }
      "SW/" -
      "SW:" {set prom "SHELL & WAIT"
        set runp "::em::shell $typ"; set amp $::em::R_mute
      }
      "MW/" -
      "MW:" -
      "M/" -
      "M:"  {set prom "MENU        "
        set runp "::em::callmenu $typ"; set amp "&"
      }
      "ME/" -
      "ME:" {set prom "MENU & EXIT "
        set runp "::em::callmenu $typ"; set amp $::em::R_ampexit
      }
      default {
        set prname "?"
        continue
      }
    }
    set hot ""
    for {set fn 1} {$fn <= 12} {incr fn} {  ;# look up to F1-F12 hotkeys
      set s "F$fn "
      if {[set p [string first $s $name]] >= 0 &&
      [string trim [set s2 [string range $name 0 [incr $p -1]]]] eq ""} {
        incr p [expr [string len $s] -1]
        set name "$s2[string range $name $p end]"
        set hot [string trimright $s]
        break
      }
    }
    set origname $name
    if {$prname eq $origname} {          ;# && $prtyp == $typ - no good, as
      set torun "$runp $s1 $amp"       ;# it doesn't unite R, E, S types
      set prog "$prprog\n$torun\r$prog"
    } else {
      if {[string trim $name "- "] eq ""} {    ;# is a separator?
        if {[string trim $name] eq "" && $::em::b0} {
          set separ "?[string trim $prog]?"    ;# yes, blank one
        } else {                               ;# ... or underlining
          set separ "?[expr {-[::apave::getN [string trim $prog] 1 1 33]}]?"
        }
        continue
      }
      if {$separ ne ""} {
        set name "$separ $name"  ;# insert separator into name
        set separ ""
      }
      set s1 [get_s1 [incr iline] $hidden]
      if {$typ eq "I:"} {
        set torun "$runp"  ;# internal command
      } else {
        set torun "$runp $s1 $amp"
      }
      if {$iline > $::em::maxitems} {
        em_message "Too much items in\n\n$seltd\n\n$::em::maxitems is maximum. \
                    Stopped at:\n\n$origline"
        on_exit
      }
      set prname $origname
      set ::em::itnames($iline) $origname   ;# - original item name
      if {[prepr_name name 1]} {
        set doafter true       ;# item names to be updated at intervals
      }
      if {$::em::ornament > 1} {
        {*}$lappend [list "$prom :$name" $torun $hot $typ]
      } else {
        {*}$lappend [list "$name" $torun $hot $typ]
      }
    }
    if {[string first $::em::extraspaces $prom]<0} {set ::em::extras false}
    set ::em::pars($s1) $prog
    set prprog $prog
  }
  if {$doafter} { ;# after N sec: check times/dates
    ::em::repeate_update_buttons
  }
  ::em::init_menuvars $domenu $options
}
#___ prepare buttons' contents
proc ::em::prepare_buttons {refcommands} {
  if {$::em::ncmd < 2} { ;# check the call string of e_menu
    if {$::em::start0} {
      puts "To run e_menu, use a command: \
      \n\033\[34;1m  tclsh e_menu.tcl \"s=%s\" m=menu \033\[m \
      \nDetails here: \
      \n\033\[32;1m  https://aplsimple.github.io/en/tcl/e_menu\033\[m"
    }
    ::em::on_exit
    return no
  }
  upvar $refcommands commands
  if {$::em::itviewed <= 0} {
    for_buttons {
      set comm [lindex $commands $i]
      set name [lindex $comm 0]
      if {$::em::extras} {
        set name [string map [list $::em::extraspaces ""] $name]
        set comm [lreplace $comm 0 0 "$name"]
        set commands [lreplace $commands $i $i $comm]
      }
      set name [prepr_idiotic name 0]
      if {[set l [string length $name]] > $::em::itviewed}  {
        set ::em::itviewed $l
      }
    }
    if {$::em::itviewed < 5} {set ::em::itviewed $::em::viewed}
  }
  set fs [expr {min(9,[::apave::obj basicFontSize])}]
  set ::em::font1a "$::em::font_f1 -size $fs"
  set ::em::font2a "$::em::font_f2 -size $::em::fs"
  set ::em::font3a "$::em::font_f2 -size [expr {$::em::fs-1}]"
  label .em.fr.win -bg $::em::clrinab -fg $::em::clrinab -state disabled \
    -takefocus 0
  checkbutton .em.fr.cb -text "On top" -variable ::em::ontop -fg $::em::clrhelp \
    -bg $::em::clrtitb -takefocus 0 -command {::em::toggle_ontop} \
    -font $::em::font1a
  if {$::eh::pk eq {} && $::em::ornament!=-2} {
    grid [label .em.fr.h0 -text [string repeat " " [expr $::em::itviewed -3]] \
      -bg $::em::clrinab] -row 0 -column 0 -sticky nsew
    grid .em.fr.cb -row 0 -column 1 -sticky ne
    if {[isheader]} {
      grid [label .em.fr.h1 -text "Use arrow and space keys to take action" \
        -font $::em::font1a -fg $::em::clrhelp -bg $::em::clrinab -anchor s] \
        -columnspan 2 -sticky nsew
      grid [label .em.fr.h2 -text "(or press hotkeys)\n" -font $::em::font1a \
        -fg $::em::clrhotk -bg $::em::clrinab -anchor n] -columnspan 2 -sticky nsew
    }
  }
  catch {
    ::baltip tip .em.fr.cb "Press Ctrl+T to toggle"
  }
  if {[isheader_nohint]} {set hlist {.em.fr.h0 .em.fr.h1 .em.fr.h2}} {set hlist {.em.fr.h0}}
  foreach l $hlist {
    if {[winfo exists $l]} {
      bind $l <ButtonPress-1>   {
        ::eh::mouse_drag .em 1 %x %y; ::em::focus_button $::em::lasti true}
      bind $l <Motion>          {::eh::mouse_drag .em 2 %x %y}
      bind $l <ButtonRelease-1> {::eh::mouse_drag .em 3 %x %y}
    }
  }
  return yes
}
#___ repaint menu's items
proc ::em::repaint_menu {} {
  catch {
    ::em::initcolorscheme
    for_buttons {
      $b configure -fg [color_button $i] -bg [color_button $i bg] \
        -borderwidth $::em::bd -relief flat
      if {[winfo exists .em.fr.win.fr$i.arr]} {
        .em.fr.win.fr$i.arr configure -bg [color_button $i bg]
      }
    }
    ::em::focus_button $::em::lasti
  }
}
#___ repainting sp. for Windows
proc ::em::repaintForWindows {} {
  update idle
  after idle [list ::em::repaint_menu; ::em::mouse_button $::em::lasti]
}
#___ re-read and update menu after Ctrl+R
proc ::em::reread_menu {{ib ""}} {
  foreach w [winfo children .em] {  ;# remove Tcl/Tk menu items
    destroy $w
  }
  initcomm
  initmenu
  if {$ib ne ""} repaintForWindows
}
#___ shadow 'w' widget
proc ::em::shadow_win {w} {
  if {![catch {set ::em::bgcolr($w) [$w cget -bg]} e]} {
    if {[::apave::shadowAllowed]} {
      $w configure -bg $::em::clrgrey
    }
  }
}
#___ focus in/out
proc ::em::focused_win {focused} {
  set ::eh::mx [set ::eh::my 0]
  if {!$::em::shadowed || ![::apave::shadowAllowed] || \
  ($::em::skipfocused && [isMenuFocused])} {
    mouse_button $::em::lasti
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
    ::em::repaint_menu  ;# important esp. for Windows
  } elseif {!$focused && [isMenuFocused]} {
    # only 2 generations of fathers & sons
    foreach w [winfo children .em.fr] {
      shadow_win $w
      foreach wc [winfo children $w] {
        shadow_win $wc
        foreach wc2 [winfo children $wc] {
          shadow_win $wc2
        }
      }
    }
    catch {.em.fr.win.fr$::em::lasti.butt configure -fg $::em::clrhotk}
    set ::eh::mx [set ::eh::my 0]
    update
  }
}
#___ Gets native names of the pathes' list.
proc ::em::nativePathes {pathes} {
  return [string map [list \\ \\\\] $pathes]
}
#___ Gets a native name of the path.
proc ::em::nativePath {path} {
  return [nativePathes [file nativename $path]]
}
proc ::em::prepare_wilds {per2} {
  if {[llength [array names ::em::ar_geany d]] != 1} { ;# it's obsolete
    set ::em::ar_geany(d) $::em::workdir             ;# (using %d as %PD)
  }
  if {$per2} {set ::em::percent2 "%"}    ;# reset the wild percent to %
  foreach _ {u p q d s} {prepr_pn ::em::${_}seltd}
  set ::em::useltd [string map {" " "_"} $::em::useltd]
  set ::em::pseltd [::eh::escape_links $::em::pseltd]
  set ::em::qseltd [::eh::escape_quotes $::em::qseltd]
  set ::em::dseltd [::eh::delete_specsyms $::em::dseltd]
  set ::em::sseltd [string trim $::em::sseltd]
}
#___ get pars
proc ::em::get_pars1 {s1 argc argv} {
  set ::em::pars($s1) ""
  for {set i $argc} {$i > 0} {} {
    incr i -1  ;# last option's value takes priority
    set s2 [string range [lindex $argv $i] 0 \
        [set l [expr [string len $s1]-1]]]
    if {$s1 eq $s2} {
      set seltd [string range [lindex $argv $i] [expr $l+1] end]
      prepr_call seltd
      set ::em::pars($s1) $seltd
      return true
    }
  }
  return false
}
#___ get "project (working) directory"
proc ::em::initPD {seltd {doit 0}} {
  if {$::em::workdir eq "" || $doit} {
    if {[file isdirectory $seltd]} {
      set ::em::workdir $seltd
    } else {
      set ::em::workdir [pwd]
    }
    prepr_win ::em::workdir "M/"  ;# force converting
    catch {cd $::em::workdir}
  }
  if {[llength $::em::prjdirlist]==0 && [file isfile $seltd]} {
      # when PD is indeed a file with projects list
    set ch [open $seltd]
    chan configure $ch -encoding utf-8
    foreach wd [split [read $ch] "\n"] {
      if {[string trim $wd] ne "" && ![string match "\#*" $wd]} {
        lappend ::em::prjdirlist $wd
      }
    }
    close $ch
  }
}
#___ initialize header of menu
proc ::em::init_header {s1 seltd} {
  set ::em::seltd [string map {\r "" \n ""} $::em::seltd]
  lassign [split $seltd \n] ::em::seltd ;# only 1st line (TF= for all)
  init_swc
  set ::em::useltd [set ::em::pseltd [set ::em::qseltd \
    [set ::em::dseltd [set ::em::sseltd $::em::seltd]]]]
  if {[isheader_nohint]} {
    set help [lindex $::em::seltd 0]  ;# 1st word is the page name
    lappend ::em::commands [list " HELP        \"$help\"" \
        "::em::help \"$help\""]
    if {[::iswindows]} {
      prepr_win seltd "M/"
      set ::em::pars($s1) $seltd
    }
    lappend ::em::commands [list " EXEC        \"$::em::seltd\"" \
        "::em::run RE: $s1 $::em::R_ampexit"]
    lappend ::em::commands [list " SHELL       \"$::em::seltd\"" \
        "::em::shell RE: $s1 $::em::R_ampexit"]
    set ::em::hotkeys "000$::em::hotsall"
  }
  set ::em::begsel [expr [llength $::em::commands] - 1]
}
#___ initialize main wildcards
proc ::em::prepare_main_wilds {{doit false}} {
  set from [file dirname $::em::ar_geany(f)]
  foreach {c attr} {d nativename D tail F tail e rootname x extension} {
    if {![info exists ::em::ar_geany($c)] || $::em::ar_geany($c) eq "" \
    || $doit} {
      set ::em::ar_geany($c) [file $attr $from]
    }
    if {$c eq "D"} {set from [file tail $::em::ar_geany(f)]}
  }
  set ::em::ar_geany(F_) [::eh::get_underlined_name $::em::ar_geany(F)]
  if {$::em::pd eq {}} {set ::em::pd $::em::ar_geany(d)}
}
#___ gets the menu's title
proc ::em::get_menutitle {} {
  if {[is_child]} {
    set ps "\u220e"
  } else {
    set ps "\u23cf"
  }
  set ::em::menuttl "$ps [file rootname [file tail $::em::menufilename]]"
}
#___ initialize ::em::commands from argv and menu
proc ::em::initcommands {lmc amc osm {domenu 0}} {
  set resetpercent2 0
  foreach s1 {tc= a0= P= N= PD= PN= F= o= ln= cn= s= u= w= sh= \
        qq= dd= ss= pa= ah= += bd= b0= b1= b2= b3= b4= dk= \
        f1= f2= f3= fs= a1= a2= ed= tf= tg= md= wc= tt= pk= \
        t0= t1= t2= t3= t4= t5= t6= t7= t8= t9= \
        s0= s1= s2= s3= s4= s5= s6= s7= s8= s9= \
        u0= u1= u2= u3= u4= u5= u6= u7= u8= u9= \
        i0= i1= i2= i3= i4= i5= i6= i7= i8= i9= \
        x0= x1= x2= x3= x4= x5= x6= x7= x8= x9= \
        y0= y1= y2= y3= y4= y5= y6= y7= y8= y9= \
        z0= z1= z2= z3= z4= z5= z6= z7= z8= z9= \
        a= d= e= f= p= l= h= b= cs= c= t= g= n= \
        fg= bg= fE= bE= fS= bS= fI= bI= fM= bM= \
        cc= gr= ht= hh= rt= DF= BF= pd= m= om= ts= \
        TF= yn= in= ex= EX= PI= NE= ls= SD=} { ;# the processing order is important
    if {($s1 in {o= s= m=}) && !($s1 in $osm)} {
      continue
    }
    if {[get_pars1 $s1 $lmc $amc]} {
      set seltd [lindex [array get ::em::pars $s1] 1]
      if {!($s1 in {m= g= in=})} {
        if {$s1 eq "s="} {
          set seltd [::eh::escape_specials $seltd]
        } elseif {$s1 in {f= d=}} {
          set seltd [string trim $seltd \'\"\`]  ;# for some FM peculiarities
        }
        set ::em::inherited "$::em::inherited \"$s1$seltd\""
      }
      set s01 [string range $s1 0 1]
      switch -- $s1 {
        P= {
          if {$seltd ne ""} {
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
          ::em::init_header $s1 $seltd
          set ::em::pseltd [::eh::escape_links $seltd]
        }
        h= {
          set ::eh::hroot [file normalize $seltd]
          set ::em::offline true
        }
        m= {
          prepare_wilds $resetpercent2
          ::em::menuof ::em::commands $s1 $domenu
        }
        b= {set ::eh::my_browser $seltd}
        sh= {set ::em::shadowed [::apave::getN $seltd 0]}
        cs= {  ;# user-defined CS
          if {[::em::insteadCS $seltd]} {
            set ::em::ncolor [::apave::obj csAdd $seltd true]
          }
        }
        c= {
          set nc [::apave::getN $seltd -2 -2 [::apave::cs_Max]]
          if {![::em::insteadCS] || $nc<0} {
            if {[set ::em::ncolor $nc]<0} {
              set ::em::insteadCSlist [list]
            }
            ::em::initdefaultcolors
          }
        }
        o= {set ::em::ornament [::apave::getN $seltd 0 -2 3]
          if {$::em::ornament>1} {
            set ::em::font_f2 "-family {[::apave::obj basicTextFont]}"
          }
        }
        g= {
          lassign [split $seltd x+] w h x y
          if {$w ne "" && $x ne "" && $y ne ""} {
            set ::em::geometry ${w}x0+$x+$y  ;# h=0 to trim the menu height
          } else {
            set ::em::geometry $seltd
          }
        }
        u= {  ;# u=... overrides previous setting (in s=)
          set ::em::useltd [string map {" " "_"} $seltd]
        }
        t= {set ::em::dotop [::apave::getN $seltd] }
        s0= - s1= - s2= - s3= - s4= - s5= - s6= - s7= - s8= - s9=
        {
          set ::em::ar_s09($s1) $seltd
        }
        u0= - u1= - u2= - u3= - u4= - u5= - u6= - u7= - u8= - u9=
        {
          set ::em::ar_u09($s1) [string map {" " "_"} $seltd]
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
          set ::em::ar_geany([string range $s1 0 0]) $seltd
        }
        n= {if {$seltd ne ""} {set ::em::menuttl $seltd}}
        ah= {set ::em::autohidden $seltd}
        a0= {if {$::em::start0} {run_tcl_commands seltd}}
        a1= {set ::em::commandA1 $seltd}
        a2= {set ::em::commandA2 $seltd}
        t0= {set ::eh::formtime $seltd }
        t1= {set ::eh::formdate $seltd }
        t2= {set ::eh::formdt   $seltd }
        t3= {set ::eh::formdw   $seltd }
        t4= - t5= - t6= - t7= - t8= -
        t9= {set ::em::ar_tformat([string range $s1 0 1]) $seltd}
        fs= {set ::em::fs [::apave::getN $seltd $::em::fs]}
        f1= - f2= {catch {
          set ::em::font_$s01 [font configure TkDefaultFont]
          set ::em::font_$s01 [dict replace [set ::em::font_$s01] -family $seltd]
        }}
        f3= {::apave::obj basicTextFont $seltd}
        qq= {set ::em::qseltd [::eh::escape_quotes $seltd]}
        dd= {set ::em::dseltd [::eh::delete_specsyms $seltd]}
        ss= {set ::em::sseltd [string trim $seltd]}
        +=  {set ::em::pseltd [::eh::escape_links $seltd]}
        pa= {set ::em::pause [::apave::getN $seltd $::em::pause]}
        wc= - bd= - b0= - b1= - b2= - b3= - b4= {
          set ::em::$s01 [::apave::getN $seltd [set ::em::$s01]]
        }
        ed= {set ::em::editor $seltd}
        tg= - om= - dk= - ls= - DF= - BF= - pd= - PI= - NE= - tc= {
          set ::em::$s01 $seltd
        }
        ex= - EX= {
          set ::em::$s01 [set ::em::ex $seltd]
        }
        pk= {set ::eh::$s01 $seltd}
        md= {set ::em::basedir $seltd}
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
            set ::em::ratiomin "$i1/$i2"
          }
        }
        tt= { ;# terminal (e.g. "tt=xterm -fs 12 -geometry 90x30+400+100")
          set ::em::linuxconsole $seltd
        }
        default {
          if {$s1 in {TF=} || [string range $s1 0 0] in {x y z}} {
            ;# x* y* z* general substitutions
            set ::em::ar_geany([string map {"=" ""} $s1]) $seltd
          }
        }
      }
    }
  }
  # get %D (dir's tail) %F (file.ext), %e (file), %x (ext) wildcards from %f
  if {![info exists ::em::ar_geany(f)]} {
    set ::em::ar_geany(f) $::em::menufilename  ;# %f wildcard is a must
  }
  prepare_main_wilds
  prepare_wilds $resetpercent2
  set ::em::ncmd [llength $::em::commands]
  initPD [pwd]
  get_menutitle
}
#___ get a list of colors used by e_menu
proc ::em::colorlist {} {
  return [list clrtitf clrinaf clrtitb clrinab clrhelp \
    clractb clractf clrcurs clrgrey clrhotk fI bI fM bM fW bW]
}
#___ clear off default colors
proc ::em::unsetdefaultcolors {} {
  foreach c {fg bg fE bE fS bS fI bI ht hh cc gr fM bM fW bW} {catch {unset ::em::clr$c}}
}
#___ set default colors from color scheme
proc ::em::initcolorscheme {{nothemed false}} {
  if {$nothemed} unsetdefaultcolors
  set clrs [::em::colorlist]
  lassign [::apave::obj csGet $::em::ncolor] {*}$clrs
  foreach clr $clrs {set ::em::$clr [set $clr]}
  ::apave::obj basicFontSize $::em::fs
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
  catch {::baltip config -fg $::em::fW -bg $::em::bW}
  if {[winfo exist .em.fr.win]} {
    .em configure -bg [.em.fr.win cget -bg]
  } else {
    . configure -bg $::em::clrinab
  }
}
#___ set default colors if not set by call of e_menu
proc ::em::initdefaultcolors {} {
  if {$::em::ncolor>=$::apave::_CS_(MINCS) && $::em::ncolor<=[::apave::cs_Max]} {
    lassign [::apave::obj csSet $::em::ncolor] \
      ::em::clrfg ::em::clrbg ::em::clrfE ::em::clrbE \
      ::em::clrfS ::em::clrbS ::em::clrhh ::em::clrgr ::em::clrcc
  }
}
#___ prepend initialization
proc ::em::initcommhead {} {
  set ::em::begsel 0
  set ::em::hotkeys $::em::hotsall
  set ::em::inherited ""
  set ::em::commands {0}
}
#___ initialize commands
proc ::em::initcomm {} {
  initcommhead
  array unset ::em::ar_macros *
  array set ::em::ar_macros [list]
  set ::em::menuoptions {0}
  if {[lsearch $::em::Argv "ch=1"]>=0} {set ::em::ischild 1}
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
  if {[lsearch -glob $::em::Argv "s=*"]<0} {
    ;# if no s=selection, make it empty to hide HELP/EXEC/SHELL
    lappend ::em::Argv s=
    incr ::em::Argc
    if {[set io [lsearch -glob $::em::Argv "o=*"]]<0} {
      lappend ::em::Argv "o=-1"
      incr ::em::Argc
    }
  }
  initcommands $::em::Argc $::em::Argv {o= s= m=} 1
  if {$::em::reallyexit} {return no}
  if {[set lmc [llength $::em::menuoptions]] > 1} {
      # o=, s=, m= options define menu contents & are processed particularly
    initcommands $lmc $::em::menuoptions {o=}
    initcommhead
    if {$::em::om} {
      initcommands $::em::Argc $::em::Argv {s= m=}
      initcommands $lmc $::em::menuoptions {o=}
    } else {
      initcommands $lmc $::em::menuoptions " "
      initcommands $::em::Argc $::em::Argv {o= s= m=}
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
#___ initialize main properties
proc ::em::initmain {} {
  if {$::em::pause > 0} {after $::em::pause}  ;# pause before main inits
  if {$::em::appN > 0} {
    set ::em::appname $::em::thisapp$::em::appN     ;# set N of application
  } else {
    ;# otherwise try to find it
    for {set ::em::appN 1} {$::em::appN < 64} {incr ::em::appN} {
      set ::em::appname $::em::thisapp$::em::appN
      if {[catch {send -async $::em::appname {update idletasks}} e]} {
        break
      }
    }
  }
  if {$::em::solo} {tk appname $::em::appname}
  set imgArr {iVBORw0KGgoAAAANSUhEUgAAAAoAAAAMCAYAAABbayygAAADAFBMVEUAAAD/AAAA/wD//wAAAP//
AP8A///////b29u2traSkpJtbW1JSUkkJCTbAAC2AACSAABtAABJAAAkAAAA2wAAtgAAkgAAbQAA
SQAAJADb2wC2tgCSkgBtbQBJSQAkJAAAANsAALYAAJIAAG0AAEkAACTbANu2ALaSAJJtAG1JAEkk
ACQA29sAtrYAkpIAbW0ASUkAJCT/29vbtra2kpKSbW1tSUlJJCT/trbbkpK2bW2SSUltJCT/kpLb
bW22SUmSJCT/bW3bSUm2JCT/SUnbJCT/JCTb/9u227aStpJtkm1JbUkkSSS2/7aS25Jttm1Jkkkk
bSSS/5Jt221JtkkkkiRt/21J20kktiRJ/0kk2yQk/yTb2/+2ttuSkrZtbZJJSW0kJEm2tv+Skttt
bbZJSZIkJG2Skv9tbdtJSbYkJJJtbf9JSdskJLZJSf8kJNskJP///9vb27a2tpKSkm1tbUlJSST/
/7bb25K2tm2SkkltbST//5Lb2222tkmSkiT//23b20m2tiT//0nb2yT//yT/2//bttu2kraSbZJt
SW1JJEn/tv/bktu2bbaSSZJtJG3/kv/bbdu2SbaSJJL/bf/bSdu2JLb/Sf/bJNv/JP/b//+229uS
trZtkpJJbW0kSUm2//+S29tttrZJkpIkbW2S//9t29tJtrYkkpJt//9J29sktrZJ//8k29sk////
27bbtpK2km2SbUltSSRJJAD/tpLbkm22bUmSSSRtJAD/ttvbkra2bZKSSW1tJElJACT/krbbbZK2
SW2SJEltACTbtv+2ktuSbbZtSZJJJG0kAEm2kv+SbdttSbZJJJIkAG222/+SttttkrZJbZIkSW0A
JEmStv9tkttJbbYkSZIAJG22/9uS27ZttpJJkm0kbUkASSSS/7Zt25JJtm0kkkkAbSTb/7a225KS
tm1tkklJbSQkSQC2/5KS221ttklJkiQkbQD/tgDbkgC2bQCSSQD/ALbbAJK2AG2SAEkAtv8AktsA
bbYASZIAAAAAAADPKgIEAAAAZUlEQVQY03XP0Q0AIQgD0GIcxWVwYFnGXXpfXBShiQnoiyJIgiRU
lV5nq+HInJMockFVLfEFxxglbnGjwi17JmIRyaFjD0n083Dv/ddmhrWWeN/jTWYGABd6ZqxQ+pkM
PbBCAPABKF9B+b41+J0AAAAASUVORK5CYII=}
  ::em::initcolorscheme
  set ::em::lin_console [file join $::em::exedir "$::em::lin_console"]
  set ::em::win_console [file join $::em::exedir "$::em::win_console"]
  set ::em::img [image create photo -data $imgArr]
  for {set i 0} {$i <=9} {incr i} {set ::em::ar_i09(i$i=) 1 }
  ::em::theming_pave
  if {[::em::insteadCS]} {
    set ::em::ncolor [::apave::obj csCurrent]
    ::em::initcolorscheme
  }
  ::apave::obj untouchWidgets .em.fr.win* .em.fr.h* .em.fr.cb
}
#___ initialize hotkeys for popup menu etc.
proc ::em::inithotkeys {} {
  foreach {t e r d g p} {t e r d g p T E R D G P} {
    bind .em <Control-$t> {.em.fr.cb invoke}
    bind .em <Control-$e> {::em::addon edit_menu}
    bind .em <Control-$r> {::em::addon reread_init}
    bind .em <Control-$d> {::em::addon destroy_emenus}
    bind .em <Control-$p> {::em::addon change_PD}
  }
  bind .em <Button-3>  {::em::addon popup %X %Y}
  bind .em <F1> {::em::addon about}
  update
}
#___ init window type
proc ::em::initdk {} {
  if {$::em::dk ne "" && ![::iswindows]} {
    wm withdraw .em
    wm attributes .em -type $::em::dk ;# desktop ;# splash ;# dock
  }
}
#___ make e_menu's menu
proc ::em::initmenu {} {
  if {![winfo exists .em]} {
    toplevel .em
    .em configure -bg $::em::clrinab
    if {[::iswindows]} { ;# maybe nice to hide all windows manipulations
      wm attributes .em -alpha 0.0
    } else {
      wm withdraw .em
    }
    ::em::initdk
    ::em::initbegin
  }
  ttk::frame .em.fr
  if {$::em::dk in {desktop splash dock}} {
    .em.fr configure -borderwidth 2 -relief solid
  }
  pack .em.fr -expand 1 -fill both
  inithotkeys
  if {![prepare_buttons ::em::commands]} return
  set capsbeg [expr {36 + $::em::begsel}]
  for_buttons {
    set hotkey [string range $::em::hotkeys $i $i]
    set comm [lindex $::em::commands $i]
    set prbutton "::em::pr_button $i [lindex $comm 1]"
    set prkeybutton [::eh::ctrl_alt_off $prbutton]  ;# for hotkeys without ctrl/alt
    set comtitle [string map {"\n" " "} [lindex $comm 0]]
    if {$i > $::em::begsel} {
      if {$i < ($::em::begsel+10)} {
        bind .em <KP_$hotkey> "$prkeybutton"
      } elseif {($capsbeg-$i)>0} {
        bind .em <KeyPress-[string toupper $hotkey]> "$prkeybutton"
      }
      bind .em <KeyPress-$hotkey> "$prkeybutton"
      set t [string trim $comtitle]
      set hotk [lindex $comm 2]
      if {[string len $hotk] > 0} {
        bind .em <$hotk> "$prbutton"
        set hotkey "$hotk, $hotkey"
      }
    } else {
      set hotkey ""
    }
    prepr_09 comtitle ::em::ar_i09 "i"
    prepr_idiotic comtitle 0
    lassign [s_assign comtitle 0] p1 p2
    if {$p2 ne ""} {
      set pady [::apave::getN $p1 0]
      if {$pady < 0} {
        if {$::eh::pk eq {} || [incr wassepany]>1} {
          grid [ttk::separator .em.fr.win.lu$i -orient horizontal] \
            -pady [expr -$pady-1] -sticky we \
            -column 0 -columnspan 2 -row [expr $i+$::em::isep]
        }
      } else {
        grid [label .em.fr.win.lu$i -font "Sans 1" -fg $::em::clrinab \
          -bg $::em::clrinab] -pady $pady -sticky nsw \
          -column 0 -columnspan 2 -row [expr $i+$::em::isep]
      }
      incr ::em::isep
    }
    ttk::frame .em.fr.win.fr$i
    if {[string first "M" [lindex $comm 3]] == 0} { ;# is menu?
      set img "-image $::em::img"     ;# yes, show arrow
      button .em.fr.win.fr$i.arr {*}$img -relief flat -overrelief flat \
        -highlightthickness $::em::b0 -bg [color_button $i bg] -command "$b invoke"
    } else {set img ""}
    button $b -text "$comtitle" -pady $::em::b1 -padx $::em::b2 -anchor nw \
      -font $::em::font2a -width $::em::itviewed -borderwidth $::em::bd \
      -relief flat -overrelief flat -highlightthickness $::em::b0 \
      -fg [color_button $i] -bg [color_button $i bg] -command "$prbutton" \
      -activeforeground [color_button $i fg] -activebackground [color_button $i bg]
    if {$img eq "" && \
    [string len $comtitle] > [expr $::em::itviewed * $::em::ratiomin]} { \
      catch {::baltip tip $b "$comtitle"}
    }
    grid [label .em.fr.win.l$i -text $hotkey -font "$::em::font3a -weight bold" -bg \
      $::em::clrinab -fg $::em::clrhotk -padx 0 -pady 0] -padx 0 -ipadx 0 \
      -column 0 -row [expr $i+$::em::isep] -sticky nsew
    grid .em.fr.win.fr$i -column 1 -row  [expr $i+$::em::isep] -sticky ew \
        -pady $::em::b3 -padx $::em::b4
    pack $b -expand 1 -fill both -side left
    if {$img ne ""} {
      pack .em.fr.win.fr$i.arr -expand 1 -fill both
      bind .em.fr.win.fr$i.arr <Motion> "::em::focus_button $i"
    }
    bind $b <Motion>   "::em::focus_button $i"
    bind $b <Down>     "::em::mouse_button [expr $i+1]"
    bind $b <Tab>      "::em::mouse_button [expr $i+1]"
    bind $b <Up>       "::em::mouse_button [expr $i-1]"
    bind $b <Home>     "::em::mouse_button 99"
    bind $b <End>      "::em::mouse_button 0"
    bind $b <Prior>    "::em::mouse_button 99"
    bind $b <Next>     "::em::mouse_button 0"
    bind $b <Return>   "$prbutton"
    bind $b <KP_Enter> "$prbutton"
    if {$img ne ""} {bind $b <Right> "$prkeybutton"}
    if {[::iswindows]} {
      bind $b <Shift-Tab> "::em::mouse_button [expr $i-1]"
    } else {
      bind $b <ISO_Left_Tab> "::em::mouse_button [expr $i-1]"
    }
  }
  grid .em.fr.win -columnspan 2 -sticky ew
  grid columnconfigure .em.fr 0 -weight 1
  grid rowconfigure    .em.fr 0 -weight 0
  grid rowconfigure    .em.fr 1 -weight 1
  grid rowconfigure    .em.fr 2 -weight 1
  grid columnconfigure .em.fr.win 1 -weight 1
  ::em::toggle_ontop
  update
  set isgeom [string len $::em::geometry]
  wm title .em "${::em::menuttl}"
  if {$::em::start0==1} {
    if {!$isgeom} {
      wm geometry .em $::em::geometry
    }
  }
  if {$::em::minwidth == 0} {
    set ::em::minwidth [expr [winfo width .em] * $::em::ratiomin]
    set minheight [winfo height .em]
  } else {
    set minheight [expr {[winfo height .em.fr.win] + 1}]
    if {[winfo exists .em.fr.cb]} {
      incr minheight [winfo height .em.fr.cb]
    }
  }
  wm minsize .em $::em::minwidth $minheight
  if {$::em::start0} {
    wm geometry .em [winfo width .em]x${minheight}
    if {$::em::wc || [::iswindows] && $::em::start0==1} {
      ::eh::center_window .em 0   ;# omitted in Linux as 'wish' is centered in it
    }
  }
}
#___ exit (end of e_menu)
proc ::em::on_exit {{really 1} args} {
  if {!$really && ($::em::ontop || $::em::remain)} return
  # remove temporary files, at closing a parent menu
  if {!$::em::ischild} {
    set menudir [file dirname $::em::menufilename]
    catch {file delete {*}[glob "$menudir/*.tmp~"]}
    catch {file delete {*}[glob "$menudir/*~.tmp"]}
  }
  if {$::em::solo} exit
  ::em::pool_pull
  set ::em::geometry [::em::geometry]
  set ::em::reallyexit $really
  set ::em::em_win_var 0
}
#___ run Tcl commands passed in a1=, a2=
proc ::em::run_tcl_commands {icomm} {
  upvar $icomm comm
  if {$comm ne ""} {
    prepr_call comm
    eval $comm
    set comm ""
  }
}
#___ run i-th menu item
proc ::em::run_it {i {hidden 0}} {
  if {$hidden} {
    lassign [lindex $::em::commhidden $i] name torun hot typ
  } else {
    lassign [lindex $::em::commands $i] name torun hot typ
    if {[set sc [string first ";" $torun]]>-1} {
      set torun [string range $torun 0 $sc-1]
    }
  }
  {*}$torun
}
#___ run auto list a=
proc ::em::run_auto {alist} {
  foreach task [split $alist ","] {
    for_buttons {
      if {$task eq [string range $::em::hotkeys $i $i]} {
        $b configure -fg $::em::clrhotk
        run_it $i
      }
    }
  }
}
#___ run auto list ah=
proc ::em::run_autohidden {alist} {
  foreach task [split $alist ","] {   ;# task=1 (2,...,a,b...)
    set i [string first $task $::em::hotsall]  ;# hotsall="012..ab..."
    if {$i>0 && $i<=[llength $::em::commhidden]} {
      run_it $i true
    }
  }
}
#___ run commands of ::em::ex list and exit
proc ::em::run_ex {{exe ""}} {
  if {$exe eq {}} {set exe $::em::ex}
  if {[llength $exe]} {
    foreach ex [split $exe ,] {
      if {$ex eq {Help}} {
        ::em::help_button $::em::pseltd
      } elseif {[string match "h*" $ex] && $ex ne "h"} {
        ::em::run_autohidden [string range $ex 1 end]
      } else {
        ::em::run_auto $ex
      }
    }
    ::em::on_exit 1
  }
}
#___ set focus on .em window
proc ::em::focus_em {} {
  after 50 {
    if {[winfo exists .em]} {
      focus -force .em
      ::em::focus_button $::em::lasti
    }
  }
}
#___ run tasks assigned in a= (by their hotkeys)
proc ::em::initauto {} {
  if {"${::em::commandA1}${::em::commandA2}" ne ""} {
    catch {wm geometry .em $::em::geometry} ;# possible messages to be centered
  }
  run_tcl_commands ::em::commandA1  ;# run the command as first init
  run_auto $::em::autorun
  run_autohidden $::em::autohidden
  run_tcl_commands ::em::commandA2  ;# run the command as last init
  run_ex                            ;# after all inits/autos, run "ex=" if any
  if {$::em::reallyexit} return
  if {!$::em::solo} {
    # only 1st start for 1st window (non-solo)
    set ::em::Argv [::apave::removeOptions $::em::Argv a=* a0=* a1=* a2=* ah=*]
    set ::em::Argc [llength $::em::Argv]
    lassign {} ::em::autorun ::em::autohidden ::em::commandA1 ::em::commandA2
  }
  if {[is_child]} {
    bind .em <Left> [::eh::ctrl_alt_off "::em::on_exit"]
  }
  if {$::em::lasti < $::em::begin} {set ::em::lasti $::em::begin}
  ::em::focus_em
}
#___ begin inits
proc ::em::initbegin {} {
  encoding system "utf-8"
  option add *Menu.tearOff 1
  set e_menu_icon {iVBORw0KGgoAAAANSUhEUgAAAFwAAAB3BAMAAAB8qjqeAAAAD1BMVEUrRF3Y2tab4+U9Oz4jKjDz
nD2xAAAAfklEQVRYw+3YsQ2AMAxEUcMGlpjgsgFMgMT+MyFRAIpEkNPETu5XFK80V0RgStJmaJUk
hsgr+KRZofhyvHLAd9VR+JPGupmsQP8q+f2tP7nkM4CLoxB5G+70Zj44V4y8742UQuRtuNOb4UaS
cyNjDMdA3NXNcCP747a3VJg6ATkQ0OkoHNcZAAAAAElFTkSuQmCC}
  if {$::em::solo} {
    ::apave::setAppIcon .em $e_menu_icon
  }
}
#___ end up inits
proc ::em::initend {} {
  ::apave::initPOP .em
  if {$::em::shadowed && [set d [expr {$::em::dk in {"" "dialog"}}]]} {
    bind .em <FocusOut> {if {"%W" eq ".em"} {::em::focused_win false}}
    bind .em <FocusIn>  {if {"%W" eq ".em"} {::em::focused_win true}}
  } else {
    if {$::em::shadowed && !$d} {
      catch {puts "dk=$::em::dk not used with sh=1"}
    }
    bind .em.fr <FocusIn> {::em::focus_button $::em::lasti}
  }
  bind .em <Control-t> {.em.fr.cb invoke}
  bind .em <Escape> {
    if {$::em::yn && ![::em::is_child] && ![Q $::em::menuttl "Quit e_menu?" \
      yesno ques YES -t 0 -a {-padx 50} -centerme .em]} break
    ::em::on_exit
  }
  bind .em <Control-Left>  {::em::addon win_width -1}
  bind .em <Control-Right> {::em::addon win_width 1}
  wm protocol .em WM_DELETE_WINDOW {::em::on_exit}
  if {$::em::dotop || $::em::ontop} {set ::em::ontop 0; .em.fr.cb invoke}
  wm geometry .em $::em::geometry
  if {[::iswindows]} {
    if {[wm attributes .em -alpha] < 0.1} {wm attributes .em -alpha 1.0}
  } else {
    catch {exec chmod a+x "$::em::lin_console"}
  }
  catch {wm deiconify .em ; raise .em}
  ::eh::checkgeometry .em
  set ::em::start0 0
  ::apave::shadowAllowed true
  repaintForWindows
}
#___ initializes all of data and runs the menu
proc ::em::initall {} {
  ::em::init_arrays
  ::em::initdefaultcolors
  ::em::initcolorscheme
  if {[::em::initcomm]} {
    ::em::initmain
    ::em::initmenu
    ::em::initauto
    if {$::em::reallyexit} return
    ::em::initend
  }
}
#___ checks if the e_menu exists
proc ::em::exists {} {
  return [winfo exists .em]
}
#___ returns the e_menu's geometry
proc ::em::geometry {} {
  return [wm geometry .em]
}
#___ main procedure to run
proc ::em::main {args} {
  if {[winfo exists .em.fr]} {destroy .em}
  lassign [::apave::parseOptions $args -prior 0 -modal 0 -remain 0 -noCS 0] \
    prior modal ::em::remain ::em::noCS
  set args [::apave::removeOptions $args -prior -modal -remain -noCS]
  if {$::em::noCS} {set ::em::noCS "disabled"} {set ::em::noCS "normal"}
  if {$prior} {
    set ::em::empool [list]  ;# continue with variables of previous session
  }
  set ::em::Argv $args
  set ::em::Argc [llength $args]
  set ::em::fs [::apave::obj basicFontSize]
  set ::em::ncolor [::apave::obj csCurrent]
  if {[llength $::em::empool]==0} {
    pool_push  ;# makes a basic item ("clean variables") in the menu pool
  } else {
    set ::em::empool [lrange $::em::empool 0 0]  ;# fetch the clean variables
    pool_item_activate 0
  }
  set ::em::reallyexit false
  set ::eh::retval [set ::eh::pk {}]
  while {!$::em::reallyexit && $::eh::retval eq {} && ![::apave::endWM ?]} {
    pool_push
    initall
    if {$::em::reallyexit} {
      pool_pull
      return 1
    }
    if {!$::em::reallyexit} {  ;# may be set in autoruns
      ::apave::obj showWindow .em $modal $::em::ontop ::em::em_win_var
      destroy .em
      if {![pool_pull]} break
    } elseif {$::em::reallyexit eq "2"} {
      set ::em::empool [list]
      set ::em::reallyexit false  ;# enter the newly created menu
    }
  }
  set ::em::empool [list]
  if {[winfo exists .em]} {destroy .em}
  if {$::eh::retval ne {}} {
    return $::eh::retval  ;# e_menu called to pick an item
  }
  return $::em::em_win_var
}

if {$::em::solo} {
  ::apave::initWM
  ::apave::iconImage -init small
  ::em::main -modal 0 -remain 0 {*}$::argv
}

# _____________________________ EOF _____________________________________ #
#RUNF1: ../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
#RUNF1: ../pave/tests/test2_pave.tcl 8 9 12 'small icons'
