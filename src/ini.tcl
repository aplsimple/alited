#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The ini-files procedures of alited.
# _______________________________________________________________________ #

  set al(ED,multiline) no
  set al(INTRO_LINES) 10
  set al(LEAF) 0
  set al(TEXT,opts) "-padx 3 -spacing1 1"
  set al(TREE,isunits) yes
  set al(TREE,units) no
  set al(TREE,files) no
  set al(TREE,cw0) 200
  set al(TREE,cw1) 70
  set al(FONTSIZE,std) 11
  set al(FONTSIZE,txt) 12
  set al(FONTSIZE,small) 9
  set al(INI,CS) 25
  set al(INI,HUE) 0
  set al(INI,ICONS) "middle icons"
  set al(INI,save_onselect) no
  set al(INI,save_onadd) no
  set al(INI,save_onmove) no
  set al(INI,save_onclose) no
  set al(INI,save_onsave) yes
  set al(RE,branch) {^\s*(#+) [_]+\s+([^_]+[^[:blank:]]+)\s+[_]+ (#+)$}         ;#  # _ lev 1 _..
  set al(RE,leaf) {^\s*##\s*[-]*([^-]*)\s*[-]*$}   ;#  # --  / # -- abc / # --abc--
  set al(RE,proc) {^\s*(((proc|method)\s+([^[:blank:]]+))|((constructor|destructor)))\s.+}
  set al(RE,leaf2) {[_]+}                       ;#  # _  / # _ abc
  set al(RE,proc2) {^\s*(proc|method|constructor|destructor)\s+} ;# proc abc {}...
  set al(RESTART) no
  set al(FAV,current) [list]
  set al(FAV,saved) [list]

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
      if {$val in {"" {EOF}}} break
      switch -glob $val {
        curtab=* {set al(curtab) [string range $val 7 end]}
        prjroot=* {set al(prjroot) [string range $val 8 end]}
        default {
         if {$val eq {[Favorites]}} {ReadIniFavorites $chan}
        }
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

proc ini::ReadIniFavorites {chan} {

  namespace upvar ::alited al al
  while {1} {
    set val [string trim [gets $chan]]
    if {$val in {"" {EOF}}} break
    switch -glob $val {
      current=* {lappend al(FAV,current) [string range $val 8 end]}
      saved=* {lappend al(FAV,saved) [string range $val 6 end]}
    }
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
  puts $chan {[Favorites]}
  foreach curfav [alited::tree::GetTree {} TreeFavor] {
    puts -nonewline $chan "current="
    puts $chan $curfav
  }
  foreach savfav $al(FAV,saved) {
    puts -nonewline $chan "saved="
    puts $chan $savfav
  }
  puts $chan "EOF"
  close $chan
}

proc ini::_init {} {

  namespace upvar ::alited al al obPav obPav obDlg obDlg obDl2 obDl2

  set al(INI) [file join [file normalize $::alited::INIDIR] alited.ini]
  ReadIni

  # initialize GUI
  ::apave::initWM
  ::apave::iconImage -init $al(INI,ICONS)
  ::apave::obj basicFontSize $al(FONTSIZE,std)

  # create two main apave objects
  ::apave::APaveInput create $obPav $al(WIN)
  ::apave::APaveInput create $obDlg $al(WIN)
  ::apave::APaveInput create $obDl2 $al(WIN)
  $obPav csSet $al(INI,CS) . -doit

  # set options' values
  if {$al(INI,HUE)} {::apave::obj csToned $al(INI,CS) [expr {$al(INI,HUE)*5}]}

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
  foreach {icon} {gulls heart add delete up down plus minus file folder \
  retry} {
    set img alimg_$icon
    catch {image create photo $img -data [::apave::iconData $icon small]}
    catch {image create photo $img-small -data [::apave::iconData $icon small]}
  }
  for {set i 0} {$i<8} {incr i} {
    image create photo alimg_pro$i -data [set alited::img::_AL_IMG($i)]
  }
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
