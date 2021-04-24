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
  set al(FONTSIZE,small) 10
  set al(INI,CS) 19
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
  set al(FAV,visited) [list]
  set al(FAV,IsFavor) yes
  set al(TPL,list) [list]
  set al(TPL,%d) "%D"
  set al(TPL,%t) "%T"
  set al(TPL,%u) "aplsimple"
  set al(TPL,%U) "Alex Plotnikov"
  set al(TPL,%m) "aplsimple@gmail.com"
  set al(TPL,%w) "https://aplsimple.github.io"
  set al(TPL,%a) "  #   %a - \\n"
  set al(KEYS,bind) [list]
  set al(MISC,smallfont) -1
  set al(MISC,maxsaved) 16
  set al(EM,geometry) "240x1+10+10"
  set al(EM,save) yes
  set al(EM,saveall) no
  set al(EM,PD=) "~/PG/e_menu_PD.txt"
  set al(EM,h=) "~/DOC/www.tcl.tk/man/tcl8.6"
  set al(EM,tt=) "xterm -fs 12 -geometry 90x30+1+1"
  set al(EM,menu) "menu.mnu"
  set al(EM,menudir) "$::e_menu_dir/menus"
  set al(EM,cs) 33
  set al(EM,exec) no
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
    puts "alited: reading $al(INI)"
    set chan [open $::alited::al(INI)]
    set mode ""
    while {![eof $chan]} {
      set stini [string trim [gets $chan]]
      switch -exact $stini {
        {[Geometry]} - {[Options]} - {[Templates]} - {[Keys]} - {[EM]} - {[Misc]} {
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
        {[EM]}        {ReadIniEM $nam $val}
        {[Misc]}      {ReadIniMisc $nam $val}
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
  }
}

proc ini::ReadIniOptions {nam val} {
  # Gets other options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    project {
      set al(prjfile) $val
      set al(prjname) [file tail [file rootname $val]]
    }
    treecw0 {set al(TREE,cw0) $val}
    treecw1 {set al(TREE,cw1) $val}
    cs      {set al(INI,CS) $val}
  }
}

proc ini::ReadIniTemplates {nam val} {
  # Gets other options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    tpl {lappend al(TPL,list) $val}
  }
  foreach n {%d %t %u %U %m %w %a} {
    if {$n eq $nam} {
      if {$val ne ""} {set al(TPL,$n) $val}
      break
    }
  }
}

proc ini::ReadIniKeys {nam val} {
  # Gets keys options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    key {lappend al(KEYS,bind) $val}
  }
}

proc ini::ReadIniEM {nam val} {
  # Gets e_menu options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    emgeometry {set al(EM,geometry) $val}
    emsave     {set al(EM,save) $val}
    emsaveall  {set al(EM,saveall) $val}
    emPD       {set al(EM,PD=) $val}
    emh        {set al(EM,h=) $val}
    emtt       {set al(EM,tt=) $val}
    emmenu     {set al(EM,menu) $val}
    emmenudir  {set al(EM,menudir) $val}
    emcs       {set al(EM,cs) $val}
    emexec     {set al(EM,exec) $val}
  }
}

proc ini::ReadIniMisc {nam val} {
  # Gets miscellaneous options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    smallfont  {set al(MISC,smallfont) $val}
    maxsaved   {set al(MISC,maxsaved) $val}
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
        {[Tabs]} - {[Options]} - {[Favorites]} - {[Misc]} {
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
        {[Misc]} {ReadPrjMisc $nam $val}
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

proc ini::ReadPrjMisc {nam val} {
  # Gets favorites of project.
  namespace upvar ::alited al al
  switch -exact $nam {
    datafind {
      catch {
        array set ::alited::find::data $val
        set ::alited::find::data(en1) ""
        set ::alited::find::data(en2) ""
      }
    }
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
  puts "alited: storing $al(INI)"
  set chan [open $::alited::al(INI) w]
  # save the geometry options
  puts $chan {[Geometry]}
  foreach v {Pan PanL PanR PanBM PanTop} {
    puts $chan $v=[winfo geometry [$::alited::obPav $v]]
  }
  puts $chan GEOM=[wm geometry $::alited::al(WIN)]
  puts $chan geomfind=$::alited::find::geo
  puts $chan minsizefind=$::alited::find::minsize
  # save other options
  puts $chan ""
  puts $chan {[Options]}
  puts $chan "project=$al(prjfile)"
  puts $chan "treecw0=[[$obPav Tree] column #0 -width]"
  puts $chan "treecw1=[[$obPav Tree] column #1 -width]"
  puts $chan "cs=$al(INI,CS)"
  puts $chan ""
  puts $chan {[Templates]}
  foreach t $al(TPL,list) {
    puts $chan "tpl=$t"
  }
  foreach n {%d %t %u %U %m %w %a} {
    puts $chan "$n=$al(TPL,$n)"
  }
  puts $chan ""
  puts $chan {[Keys]}
  foreach k $al(KEYS,bind) {
    puts $chan "key=$k"
  }
  puts $chan ""
  puts $chan {[EM]}
  puts $chan "emsave=$al(EM,save)"
  puts $chan "emsaveall=$al(EM,saveall)"
  puts $chan "emPD=$al(EM,PD=)"
  puts $chan "emh=$al(EM,h=)"
  puts $chan "emtt=$al(EM,tt=)"
  puts $chan "emmenu=$al(EM,menu)"
  puts $chan "emmenudir=$al(EM,menudir)"
  puts $chan "emcs=$al(EM,cs)"
  puts $chan "emgeometry=$al(EM,geometry)"
  puts $chan "emexec=$al(EM,exec)"
  puts $chan ""
  puts $chan {[Misc]}
  puts $chan "smallfont=$al(FONTSIZE,small)"
  puts $chan "maxsaved=$al(MISC,maxsaved)"
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
    if {$TID eq $TIDcur} {
      set pos [$wtxt index insert]
    } else {
      set pos [alited::bar::GetTabState $TID --pos]
    }
    append line \t $pos
    puts $chan "tab=$line"
  }
  puts $chan ""
  puts $chan {[Options]}
  puts $chan "curtab=[alited::bar::CurrentTab 3]"
  puts $chan "prjroot=$al(prjroot)"
  puts $chan ""
  puts $chan {[Favorites]}
  if {!$al(FAV,IsFavor)} {alited::favor::Visited}
  foreach curfav [alited::tree::GetTree {} TreeFavor] {
    puts $chan "current=$curfav"
  }
  foreach savfav [::alited::favor_ls::PutIni] {
    puts $chan "saved=$savfav"
  }
  puts $chan ""
  puts $chan {[Misc]}
  puts $chan "datafind=[array get ::alited::find::data]"
  close $chan
}

# ______________________ initializer of alited app ______________________ #

proc ini::_init {} {

  namespace upvar ::alited al al obPav obPav obDlg obDlg obDl2 obDl2 obFND obFND obEM obEM

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

    apave::APaveInput create $obEM .win
    $obEM makeWindow .win.fra ""

  # set options' values
  if {$al(INI,HUE)} {::apave::obj csToned $al(INI,CS) [expr {$al(INI,HUE)*5}]}
  foreach {icon} {gulls heart add delete up down plus minus retry misc previous next \
  folder file OpenFile SaveFile saveall undo redo help find e_menu run} {
    set img alimg_$icon
    catch {image create photo $img-big -data [::apave::iconData $icon]}
    catch {image create photo $img -data [::apave::iconData $icon small]}
    if {$icon in {"file" OpenFile SaveFile saveall help find e_menu run undo redo}} {
      append al(tool) " $img-big \{{} -tooltip {$alited::al(MC,ico$icon)@@ -under 4} "
      switch $icon {
        "file" {
          append al(tool) "-com alited::file::NewFile\}"
        } 
        OpenFile {
          append al(tool) "-com alited::file::OpenFile\} h_ 2 sev 7"
        } 
        SaveFile {
          append al(tool) "-com alited::file::SaveFile -state disabled\}"
        } 
        saveall {
          append al(tool) "-com alited::file::SaveAll -state disabled\} h_ 2 sev 7"
        }
        undo {
          append al(tool) "-com alited::tool::Undo -state disabled\}"
        } 
        redo {
          append al(tool) "-com alited::tool::Redo -state disabled\} h_ 2 sev 7"
        }
        help {
          append al(tool) "-com alited::tool::Help\}"
        } 
        find {
          append al(tool) "-com alited::find::_run\} h_ 2 sev 7"
        }
        run {
          append al(tool) "-com alited::tool::Run\}"
        } 
        e_menu {
          image create photo $img-big -data $alited::img::_AL_IMG(e_menu)
          append al(tool) "-com alited::tool::e_menu\}"
        }
      }
    }
  }
  for {set i 0} {$i<8} {incr i} {
    image create photo alimg_pro$i -data [set alited::img::_AL_IMG($i)]
  }
  image create photo alimg_tclfile -data [set alited::img::_AL_IMG(Tcl)]
  # new find/repl. geometry
  if {$al(MISC,smallfont) ne $al(FONTSIZE,small)} {
    set ::alited::find::geo [set ::alited::find::minsize ""]
  }
  # styles & fonts used in "small" dialogues
  ::apave::initStylesFS -size $al(FONTSIZE,small)
  lassign [::apave::obj create_FontsType small -size $al(FONTSIZE,small)] \
     al(FONT,defsmall) al(FONT,monosmall)
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
