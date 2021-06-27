#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The tools' procedures of alited.
# _______________________________________________________________________ #

# default settings of alited app:

namespace eval tool {
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

# ________________________ Various tools _________________________ #

proc tool::ColorPicker {} {
  # Calls a color picker passing to it and getting from it a color.

  if {[set color [alited::find::GetWordOfText]] ne {}} {
    set alited::al(chosencolor) $color
  }
  set res [::apave::obj chooser colorChooser alited::al(chosencolor)]
  if {$res ne {}} {
    set alited::al(chosencolor) $res
    set wtxt [alited::main::CurrentWTXT]
    $wtxt insert [$wtxt index insert] $res
  }
}
#_______________________

proc tool::Loupe {} {
  # Calls a screen loupe.

  exec tclsh [file join $::alited::PAVEDIR pickers color aloupe aloupe.tcl] &
}
#_______________________

proc tool::tkcon {} {
  # Calls Tkcon application.

  namespace upvar ::alited al al
  foreach opt [array names al tkcon,clr*] {
    lappend opts -color-[string range $opt 9 end] $al($opt)
  }
  foreach opt {rows cols fsize geo topmost} {
    lappend opts -apl-$opt $al(tkcon,$opt)
  }
  exec tclsh [file join $::alited::LIBDIR util tkcon.tcl] {*}$opts &
}
#_______________________

proc tool::Help {} {
  # Calls a help on alited.

  _run Help
}

# ________________________ emenu support _________________________ #

proc tool::EM_Options {opts} {
  # Returns e_menu's general options.

  namespace upvar ::alited al al
  set sel [alited::find::GetWordOfText]
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
  if {$al(EM,DiffTool) ne {}} {append ls " DF=$al(EM,DiffTool)"}
  set l [[alited::main::CurrentWTXT] index insert]
  set l [expr {int($l)}]
  return [list "md=$al(EM,menudir)" "m=$al(EM,menu)" "f=$f" "d=$d" "l=$l" \
    "PD=$al(EM,PD=)" "pd=$al(prjroot)" "h=$al(EM,h=)" "tt=$al(EM,tt=)" "s=$sel" \
    o=-1 om=0 g=$al(EM,geometry) {*}$ls {*}$opts]
}
#_______________________

proc tool::EM_dir {} {
  # Returns a directory of e_menu's menus.

  namespace upvar ::alited al al
  if {$al(EM,menudir) eq {}} {
    return $::e_menu_dir
  }
  return [file dirname $al(EM,menudir)]
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
    -command "alited::pref::_run Emenu_Tab"
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
    set ex {ex= o=0}
  } else {
    # call a command
    set ex "ex=[alited::tool::EM_HotKey $idx]"
  }
  return "alited::tool::e_menu \"m=$mnu\" $ex"
}

## ________________________ run/close _________________________ ##

proc tool::e_menu {args} {
  # Runs e_menu.
  #   args - arguments of e_menu
  # The e_menu is run as an external application or an internal procedure,
  # depending on e_menu's preferences.

  if {{ex=Help} ni $args} {
    EM_SaveFiles
    if {[lsearch -glob -nocase $args EX=*]>-1} {
      append args " g="  ;# should be last, to override previous settings
    }
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

  exec tclsh [file join $::e_menu_dir e_menu.tcl] {*}[EM_Options $opts] c=$alited::al(EM,CS) &
}
#_______________________

proc tool::e_menu2 {opts} {
  # Runs e_menu.
  #   opts - options of e_menu
  # The e_menu is run as an internal procedure.

  if {![info exists ::em::geometry]} {
    source [file join $::e_menu_dir e_menu.tcl]
  }
  ::em::main -prior 1 -modal 0 -remain 0 -noCS 1 {*}[EM_Options $opts]
  set alited::al(EM,geometry) $::em::geometry
}
#_______________________

proc tool::_run {{what ""}} {
  # Runs e_menu's item of menu.mnu.
  #   what - the item (by default, "Run me")

  namespace upvar ::alited al al
  set fpid [file join $al(EM,menudir) .pid~]
  if {!$al(DEBUG) && [file exists $fpid]} {
    catch {
      set pid [::apave::readTextFile $fpid]
      exec kill -s SIGINT $pid
    }
  }
  if {[winfo exists .em] && [winfo ismapped .em]} {
    bell
  }
  if {$what eq {}} {set what 1} ;# 'Run me' e_menu item
  e_menu "EX=$what"
}
#_______________________

proc tool::_close {{fname ""}} {
  # Closes e_menu (being an internal procedure) by force.

  catch {destroy .em}
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
