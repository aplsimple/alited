#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The ini-files procedures of alited.
# _______________________________________________________________________ #

# default settings of alited app:

namespace eval ::alited {
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
  set al(TPL,list) [list]
  set al(KEYS,bind) [list]
}

namespace eval ini {
  variable afterID ""
}

# ________________________ read common settings _________________________ #

proc ini::ReadIni {} {

  namespace upvar ::alited al al
  lassign "" ::alited::Pan_wh ::alited::PanL_wh ::alited::PanR_wh \
    ::alited::PanBM_wh ::alited::PanTop_wh ::alited::al(GEOM)
  catch {
    set chan [open $::alited::al(INI)]
    set mode ""
    while {![eof $chan]} {
      set stini [string trim [gets $chan]]
      switch -exact $stini {
        {[Geometry]} - {[Options]} - {[Templates]} - {[Keys]} {
          set mode $stini
          continue
        }
      }
      set i [string first = $stini]
      set nam [string range $stini 0 $i-1]
      set val [string range $stini $i+1 end]
      switch -exact $mode {
        {[Geometry]}  {ReadIniGeometry $nam $val}
        {[Options]}   {ReadIniOptions $nam $val}
        {[Templates]} {ReadIniTemplates $nam $val}
        {[Keys]}      {ReadIniKeys $nam $val}
      }
    }
  }
  catch {close $chan}
  ReadIniPrj
}

proc ini::ReadIniGeometry {nam val} {
  # Gets the geometry options of alited.

  namespace upvar ::alited al al
  switch -glob $nam {
    Pan* {
      lassign [split $val x+] w h
      set ::alited::${nam}_wh "-w $w -h $h"
    }
    GEOM {
      lassign [split $val x+] - - x y
      set ::alited::al(GEOM) "-geometry +$x+$y"
    }
    geomfind {
      set ::alited::find::geo $val
    }
    minsizefind {
      set ::alited::find::minsize $val
    }
    datafind {
      catch {
        array set ::alited::find::data $val
        set ::alited::find::data(en1) ""
        set ::alited::find::data(en2) ""
      }
    }
  }
}

proc ini::ReadIniOptions {nam val} {
  # Gets other options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    project {set al(prjfile) $val}
    treecw0 {set al(TREE,cw0) $val}
    treecw1 {set al(TREE,cw1) $val}
  }
}

proc ini::ReadIniTemplates {nam val} {
  # Gets other options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    tpl {lappend al(TPL,list) $val}
  }
}

proc ini::ReadIniKeys {nam val} {
  # Gets other options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    key {lappend al(KEYS,bind) $val}
  }
}

# _______________________ read project settings _________________________ #

proc ini::ReadIniPrj {} {

  namespace upvar ::alited al al
  alited::favor_ls::GetIni ""  ;# initializes favorites' lists
  set al(tabs) [list]
  set al(curtab) ""
  catch {
    set chan [open $::alited::al(prjfile) r]
    set mode ""
    while {![eof $chan]} {
      set stini [string trim [gets $chan]]
      switch -exact $stini {
        {[Tabs]} - {[Options]} - {[Favorites]} {
          set mode $stini
          continue
        }
      }
      set i [string first = $stini]
      set nam [string range $stini 0 $i-1]
      set val [string range $stini $i+1 end]
      switch -exact $mode {
        {[Tabs]} {ReadPrjTabs $nam $val}
        {[Options]} {ReadPrjOptions $nam $val}
        {[Favorites]} {ReadPrjFavorites $nam $val}
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

proc ini::ReadPrjTabs {nam val} {
  # Gets tabs of project.
  namespace upvar ::alited al al
  switch -exact $nam {
    tab {lappend al(tabs) $val}
  }
}

proc ini::ReadPrjOptions {nam val} {
  # Gets options of project.
  namespace upvar ::alited al al
  switch -exact $nam {
    curtab  {set al(curtab) $val}
    prjroot {set al(prjroot) $val}
  }
}

proc ini::ReadPrjFavorites {nam val} {
  # Gets favorites of project.
  namespace upvar ::alited al al
  switch -exact $nam {
    current {lappend al(FAV,current) $val}
    saved   {alited::favor_ls::GetIni $val}
  }
}

# ____________________________ save settings ____________________________ #

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
    puts $chan $v=[winfo geometry [$::alited::obPav $v]]
  }
  puts $chan GEOM=[wm geometry $::alited::al(WIN)]
  puts $chan geomfind=$::alited::find::geo
  puts $chan minsizefind=$::alited::find::minsize
  puts $chan datafind=[array get ::alited::find::data]
  # save other options
  puts $chan ""
  puts $chan {[Options]}
  puts $chan "project=$al(prjfile)"
  puts $chan "treecw0=[[$obPav Tree] column #0 -width]"
  puts $chan "treecw1=[[$obPav Tree] column #1 -width]"
  puts $chan ""
  puts $chan {[Templates]}
  foreach t $al(TPL,list) {
    puts $chan "tpl=$t"
  }
  puts $chan ""
  puts $chan {[Keys]}
  foreach k $al(KEYS,bind) {
    puts $chan "key=$k"
  }
  close $chan
  SaveIniPrj
}

proc ini::SaveIniPrj {} {

  namespace upvar ::alited al al obPav obPav
  set chan [open $::alited::al(prjfile) w]
  puts $chan {[Tabs]}
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
    puts $chan "tab=$line"
  }
  puts $chan ""
  puts $chan {[Options]}
  puts $chan "curtab=[alited::bar::CurrentTab 3]"
  puts $chan "prjroot=$al(prjroot)"
  puts $chan ""
  puts $chan {[Favorites]}
  foreach curfav [alited::tree::GetTree {} TreeFavor] {
    puts $chan "current=$curfav"
  }
  foreach savfav [::alited::favor_ls::PutIni] {
    puts $chan "saved=$savfav"
  }
  close $chan
}

# ______________________ initializer of alited app ______________________ #

proc ini::_init {} {

  namespace upvar ::alited al al obPav obPav obDlg obDlg obDl2 obDl2 obFND obFND

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
  ::apave::APaveInput create $obFND $al(WIN)
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
  retry previous next} {
    set img alimg_$icon
    catch {image create photo $img -data [::apave::iconData $icon small]}
    catch {image create photo $img-small -data [::apave::iconData $icon small]}
  }
  for {set i 0} {$i<8} {incr i} {
    image create photo alimg_pro$i -data [set alited::img::_AL_IMG($i)]
  }
  image create photo alimg_tclfile -data [set alited::img::_AL_IMG(Tcl)]
  font create AlSmallFont {*}[font actual apaveFontDef] -size $alited::al(FONTSIZE,small)
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
