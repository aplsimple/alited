#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The tools' procedures of alited.
# _______________________________________________________________________ #

# default settings of alited app:

namespace eval tool {
}

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

proc tool::_close {{fname ""}} {
  catch {destroy .em}
}

proc tool::e_menuOptions {opts} {
  namespace upvar ::alited al al
  set sel [alited::find::GetWordOfText]
  set f [alited::bar::FileName]
  set d [file dirname $f]
  return [list "md=$al(EM,menudir)" "m=$al(EM,menu)" "f=$f" "d=$d" \
    "PD=$al(EM,PD=)" "h=$al(EM,h=)" "tt=$al(EM,tt=)" "s=$sel" \
    o=-1 om=0 g=$al(EM,geometry) {*}$opts]
}

proc tool::e_menu {args} {
  if {"ex=Help" ni $args} SaveFiles
  if {$alited::al(EM,exec)} {
    e_menu1 $args
  } else {
    e_menu2 $args
  }
}

proc tool::e_menu1 {opts} {
  exec tclsh [file join $::e_menu_dir e_menu.tcl] {*}[e_menuOptions $opts] c=$alited::al(EM,CS) &
}

proc tool::e_menu2 {opts} {
  if {![info exists ::em::geometry]} {
    source [file join $::e_menu_dir e_menu.tcl]
  }
  ::em::main -prior 1 -modal 0 -remain 0 {*}[e_menuOptions $opts]
  set alited::al(EM,geometry) $::em::geometry
}

proc tool::Help {} {
  _run Help
}

proc tool::SaveFiles {} {
  namespace upvar ::alited al al
  if {$al(EM,saveall)} {
    alited::file::SaveAll
  } elseif {$al(EM,save)} {
    alited::file::SaveFile
  }
}

proc tool::_run {{what ""}} {
  namespace upvar ::alited al al
  set fpid [file join $al(EM,menudir) .pid~]
  if {[file exists $fpid]} {
    catch {
      set pid [::apave::readTextFile $fpid]
      exec kill -s SIGINT $pid
    }
  }
  if {[winfo exists .em] && [winfo ismapped .em]} {
    bell
  }
  if {$what eq ""} {
    set what "1" ;# 'Run me' e_menu item
    SaveFiles
  }
  e_menu "ex=$what"
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
