#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The initializing procedures of alited.
# _______________________________________________________________________ #

namespace eval ini {
  variable afterID ""
}

proc ini::ReadIni {} {

  namespace upvar ::alited al al
  lassign "" ::alited::Pan_wh ::alited::PanL_wh ::alited::PanR_wh \
    ::alited::PanBM_wh ::alited::PanTop_wh ::alited::al(GEOM)
  catch {
    set chan [open $::alited::al(INI)]
    while {1} {
      set stini [gets $chan]
      switch -exact -- $stini {
        {} break
        {[Geometry]} {ReadIniGeometry $chan}
        {[Options]} {ReadIniOptions $chan}
      }
    }
  }
  catch {close $chan}
  ReadIniPrj
}

proc ini::ReadIniGeometry {chan} {
  # Gets the geometry options of alited.

  namespace upvar ::alited al al
  foreach v {Pan PanL PanR PanBM PanTop} {
    lassign [split [gets $chan] x+] w h
    set ::alited::${v}_wh "-w $w -h $h"
  }
  lassign [split [gets $chan] x+] - - x y
  if {[string is digit -strict "$x$y"]} {
    set ::alited::al(GEOM) "-geometry +$x+$y"
  }
}

proc ini::ReadIniOptions {chan} {
  # Gets other options of alited.
  namespace upvar ::alited al al
  while {1} {
    set st [string trim [gets $chan]]
    if {$st in {"" {[Misc]}}} break
    set val [string range $st 8 end] ;# i like the 8-)
    switch -glob -- $st {
      project=* {set al(prjfile) $val}
      treecw0=* {set al(TREE,cw0) $val}
      treecw1=* {set al(TREE,cw1) $val}
    }
  }
}

proc ini::ReadIniPrj {} {

  namespace upvar ::alited al al
  set al(tabs) [list]
  set al(curtab) ""
  catch {
    set chan [open $::alited::al(prjfile) r]
    while {1} {
      set val [string trim [gets $chan]]
      if {$val in {"" {[Options]}}} break
      lappend al(tabs) $val
    }
    while {1} {
      set val [string trim [gets $chan]]
      if {$val in {"" {[Misc]}}} break
      switch -glob $val {
        curtab=* {set al(curtab) [string range $val 7 end]}
        prjroot=* {set al(prjroot) [string range $val 8 end]}
      }
    }
  }
  catch {close $chan}
  catch {cd $al(prjroot)}
  if {![string is digit -strict $al(curtab)] || \
  $al(curtab)<0 || $al(curtab)>=[llength $al(tabs)]} {
    set al(curtab) 0
  }
}

proc ini::SaveCurrentIni {{saveon yes} {doit no}} {
  ;# for sessions to come
  if {![expr $saveon]} return
  variable afterID
  catch {after cancel $afterID}
  if {$doit} {
    SaveIni
  } else {
    set afterID [after idle ::alited::ini::SaveCurrentIni yes yes]
  }
}

proc ini::SaveIni {} {

  namespace upvar ::alited al al obPav obPav
  set chan [open $::alited::al(INI) w]
  # save the geometry options
  puts $chan {[Geometry]}
  foreach v {Pan PanL PanR PanBM PanTop} {
    puts $chan [winfo geometry [$::alited::obPav $v]]
  }
  puts $chan [wm geometry $::alited::al(WIN)]
  # save other options
  foreach opt {prjfile} {puts $chan [set al($opt)]}
  puts $chan {[Options]}
  puts $chan "treecw0=[[$obPav Tree] column #0 -width]"
  puts $chan "treecw1=[[$obPav Tree] column #1 -width]"
  close $chan
  SaveIniPrj
}

proc ini::SaveIniPrj {} {

  namespace upvar ::alited al al obPav obPav
  set chan [open $::alited::al(prjfile) w]
  lassign [alited::bar::GetBarState] TIDcur - wtxt
  foreach tab [alited::bar::BAR listTab] {
    set TID [lindex $tab 0]
    set line [alited::bar::FileName $TID]
    lassign [alited::bar::GetTabState $TID --pos --pos_S2] pos pos_S2
    if {$TID eq $TIDcur} {
      if {[alited::main::CurrentSUF $TID] eq ""} {
        set pos [$wtxt index insert]
      } else {
        set pos_S2 [$wtxt index insert]
      }
    }
    append line \t $pos \t $pos_S2
    puts $chan $line
  }
  puts $chan {[Options]}
  puts $chan "curtab=[alited::bar::CurrentTab 3]"
  puts $chan "prjroot=$al(prjroot)"
  close $chan
}

proc ini::_init {} {

  namespace upvar ::alited al al obPav obPav obDlg obDlg

  # get alited's options
  lassign [::apave::parseOptions $::argv \
    -inidir "" -icons "middle icons" -CS 23 -fontsize 12 -hue 0] \
    inidir icons cs fontsize hue

  # initialize GUI
  ::apave::initWM
  ::apave::iconImage -init $icons
  ::apave::obj basicFontSize $fontsize

  # create two main apave objects
  ::apave::APaveInput create $obPav $al(WIN)
  ::apave::APaveInput create $obDlg $al(WIN)
  $obPav csSet $cs . -doit

  # set options' values
  if {$hue} {::apave::obj csToned $cs [expr {$hue*5}]}
  if {$inidir ne ""} {set ::alited::INIDIR $inidir}
  set al(INI) [file join [file normalize $::alited::INIDIR] alited.ini]

  ReadIni

  set imgl [::apave::iconImage]
  set llen 21
  for {set i 1} {$i<$llen} {incr i} {
    set icon [lindex $imgl $i]
    set img _alited_ICN$i
    catch {image create photo $img -data [::apave::iconData $icon]}
    catch {image create photo $img-small -data [::apave::iconData $icon small]}
    if {$i<11} {
      append al(tool) " $img {{} -tooltip {Icon$i: $icon@@ -under 4}}"
    }
  }
  foreach {icon} {tree heart add delete up down plus minus file folder} {
    set img alimg_$icon
    catch {image create photo $img -data [::apave::iconData $icon small]}
    catch {image create photo $img-small -data [::apave::iconData $icon small]}
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl -CS 23 -hue 0 -fontsize 11
