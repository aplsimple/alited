#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The ini-files procedures of alited.
# _______________________________________________________________________ #

# default settings of alited app:

namespace eval ::alited {
  set al(MAXFILES) 2000 ;# maximum size of file tree (max size of project)
  set al(ED,multiline) 0 ;# "true" only for projects of small modules
  set al(ED,EOL) {}
  set al(ED,indent) 2
  set al(TEXT,opts) "-padx 3 -spacing1 1"
  set al(TREE,isunits) yes
  set al(TREE,units) no
  set al(TREE,files) no
  set al(TREE,cw0) 200
  set al(TREE,cw1) 70
  set al(FONTSIZE,small) 10
  set al(FONTSIZE,std) 11
  set al(FONTSIZE,txt) 12
  set al(INI,CS) -1
  set al(INI,HUE) 0
  set al(INI,LINES1) 10
  set al(INI,LEAF) 0
  set al(INI,ICONS) "middle icons"
  set al(INI,save_onselect) no
  set al(INI,save_onadd) no
  set al(INI,save_onmove) no
  set al(INI,save_onclose) no
  set al(INI,save_onsave) yes
  set al(INI,maxfind) 16
  set al(INI,bartiplen) 32
  set al(INI,confirmexit) 1
  set al(RE,branch) {^\s*(#+) [_]+\s+([^_]+[^[:blank:]]*)\s+[_]+ (#+)$}         ;#  # _ lev 1 _..
  set al(RE,leaf) {^\s*##\s*[-]*([^-]*)\s*[-]*$}   ;#  # --  / # -- abc / # --abc--
  set al(RE,proc) {^\s*(((proc|method)\s+([^[:blank:]]+))|((constructor|destructor)))\s.+}
  set al(RE,leaf2) {[_]+}                       ;#  # _  / # _ abc
  set al(RE,proc2) {^\s*(proc|method|constructor|destructor)\s+} ;# proc abc {}...
  set al(FAV,current) [list]
  set al(FAV,visited) [list]
  set al(FAV,IsFavor) yes
  set al(FAV,MaxLast) 16
  set al(TPL,list) [list]
  set al(TPL,%d) "%D"
  set al(TPL,%t) "%T"
  set al(TPL,%u) "aplsimple"
  set al(TPL,%U) "Alex Plotnikov"
  set al(TPL,%m) "aplsimple@gmail.com"
  set al(TPL,%w) "https://aplsimple.github.io"
  set al(TPL,%a) "  #   %a - \\n"
  set al(KEYS,bind) [list]
  set al(EM,geometry) "240x1+10+10"
  set al(EM,save) ""
  set al(EM,PD=) "~/PG/e_menu_PD.txt"
  set al(EM,h=) "~/DOC/www.tcl.tk/man/tcl8.6"
  set al(EM,tt=) "xterm -fs 12 -geometry 90x30+1+1"
  set al(EM,menu) "menu.mnu"
  set al(EM,menudir) ""
  set al(EM,CS) 33
  set al(EM,exec) no
  set al(tablist) [list]
  set al(RECENTFILES) [list]
  set al(INI,RECENTFILES) 16
  set al(closefunc) 0
  set alited::al(chosencolor) green
}

namespace eval ini {
  variable afterID ""
}

# ________________________ read common settings _________________________ #

proc ini::ReadIni {{projectfile ""}} {

  namespace upvar ::alited al al
  namespace upvar ::alited::project prjlist prjlist prjinfo prjinfo
#TODO  set prjinfo [list]
  set prjlist [list]
  set al(TPL,list) [list]
  set al(KEYS,bind) [list]
  set al(FAV,current) [list]
  set al(FAV,visited) [list]
  set em_i 0
  lassign "" ::alited::Pan_wh ::alited::PanL_wh ::alited::PanR_wh \
    ::alited::PanBM_wh ::alited::PanTop_wh ::alited::al(GEOM)
  catch {
    puts "alited pwd    : [pwd]"
    puts "alited reading: $al(INI)"
    set chan [open $::alited::al(INI)]
    set mode ""
    while {![eof $chan]} {
      set stini [string trim [gets $chan]]
      switch -exact $stini {
        {[Geometry]} - {[Options]} - {[Projects]} - {[Templates]} - {[Keys]} - {[EM]} - {[Misc]} {
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
        {[EM]}        {ReadIniEM $nam $val em_i}
        {[Misc]}      {ReadIniMisc $nam $val}
      }
    }
  }
  catch {close $chan}
  # some options may be active outside of any project; they are set by default values
  if {$projectfile eq "" && $al(prjfile) eq ""} {
    set al(prjmultiline) $al(ED,multiline)
    set al(prjindent) $al(ED,indent)
    set al(prjEOL) $al(ED,EOL)
  } else {
    if {$projectfile eq ""} {
      set projectfile $al(prjfile)
    } else {
      set al(prjfile) $projectfile
    }
    ReadIniOptions project $projectfile
  }
  ReadIniPrj
  ::apave::setTextIndent $al(prjindent)
  ::apave::textEOL $al(prjEOL)
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
    geomfind       {set ::alited::find::geo $val}
    minsizefind    {set ::alited::find::minsize $val}
    geomproject    {set ::alited::project::geo $val}
    minsizeproject {set ::alited::project::minsize $val}
    geompref       {set ::alited::pref::geo $val}
    minsizepref    {set ::alited::pref::minsize $val}
    dirgeometry    {set ::alited::DirGeometry $val}
    filgeometry    {set ::alited::FilGeometry $val}
    treecw0        {set al(TREE,cw0) $val}
    treecw1        {set al(TREE,cw1) $val}
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
    cs            {set al(INI,CS) $val}
    hue           {set al(INI,HUE) $val}
    smallfontsize {set al(FONTSIZE,small) $val}
    stdfontsize   {set al(FONTSIZE,std) $val}
    txtfontsize   {set al(FONTSIZE,txt) $val}
    multiline     {set al(ED,multiline) $val}
    indent        {set al(ED,indent) $val}
    EOL           {set al(ED,EOL) $val}
    maxfind       {set al(INI,maxfind) $val}
    confirmexit   {set al(INI,confirmexit) $val}
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

proc ini::ReadIniEM {nam val emiName} {
  # Gets e_menu options of alited.
  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu
  upvar $emiName em_i
  switch -exact $nam {
    emgeometry {set al(EM,geometry) $val}
    emsave     {set al(EM,save) $val}
    emPD       {set al(EM,PD=) $val}
    emh        {set al(EM,h=) $val}
    emtt       {set al(EM,tt=) $val}
    emmenu     {set al(EM,menu) $val}
    emmenudir  {set al(EM,menudir) $val}
    emcs       {set al(EM,CS) $val}
    emexec     {set al(EM,exec) $val}
    em_run {
      if {$em_i < $em_Num} {
        lassign [split $val \t] em_sep($em_i) em_ico($em_i) em_inf($em_i)
        set em_mnu($em_i) [lindex $em_inf($em_i) end]
      }
      incr em_i
    }
  }
}

proc ini::ReadIniMisc {nam val} {
  # Gets miscellaneous options of alited.
  namespace upvar ::alited al al
  switch -exact $nam {
    isfavor {set al(FAV,IsFavor) $val}
    chosencolor {set alited::al(chosencolor) $val}
  }
}

# _______________________ read project settings _________________________ #

proc ini::ReadIniPrj {} {

  namespace upvar ::alited al al
  set al(tabs) [list]
  set al(curtab) ""
  alited::favor_ls::GetIni ""  ;# initializes favorites' lists
  set al(prjdirign) ".git .bak"
  if {![file exists $al(prjfile)]} {
    set al(prjfile) [file join $alited::PRJDIR [file tail $al(prjfile)]]
  }
  if {[catch {
    puts "alited project: $al(prjfile)"
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
    if {$al(prjroot) eq ""} {set al(prjroot) $alited::DIR}
  }]} then {
    puts "Not open: $al(prjfile)"
    set al(prjname) ""
    set al(prjfile) ""
    set al(prjroot) ""
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
  if {[string trim $val] ne ""} {
    switch -exact $nam {
      tab {lappend al(tabs) $val}
      recent {alited::file::InsertRecent $val end}
    }
  }
}

proc ini::ReadPrjOptions {nam val} {
  # Gets options of project.
  if {$nam in {"" "prjfile"}} return ;# to avoid resetting the current project file name
  namespace upvar ::alited al al
  set al($nam) $val
}

proc ini::ReadPrjFavorites {nam val} {
  # Gets favorites of project.
  namespace upvar ::alited al al
  switch -exact $nam {
    current - visited {lappend al(FAV,$nam) $val}
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
  # run this code after updating GUI
  catch {after cancel $afterID}
  if {$doit} {
    SaveIni
  } else {
    set afterID [after idle ::alited::ini::SaveCurrentIni yes yes]
  }
}

proc ini::SaveIni {{newproject no}} {

  namespace upvar ::alited al al obPav obPav
  namespace upvar ::alited::pref em_Num em_Num em_sep em_sep em_ico em_ico em_inf em_inf
  namespace upvar ::alited::project prjlist prjlist prjinfo prjinfo OPTS OPTS
  puts "alited storing: $al(INI)"
#  catch {file mkdir [file dirname $al(INI)]}
  set chan [open $::alited::al(INI) w]
  puts $chan {[Options]}
  puts $chan "project=$al(prjfile)"
  puts $chan "cs=$al(INI,CS)"
  puts $chan "hue=$al(INI,HUE)"
  puts $chan "smallfontsize=$al(FONTSIZE,small)"
  puts $chan "stdfontsize=$al(FONTSIZE,std)"
  puts $chan "txtfontsize=$al(FONTSIZE,txt)"
  puts $chan "multiline=$al(ED,multiline)"
  puts $chan "indent=$al(ED,indent)"
  puts $chan "EOL=$al(ED,EOL)"
  puts $chan "maxfind=$al(INI,maxfind)"
  puts $chan "confirmexit=$al(INI,confirmexit)"
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
  puts $chan "emPD=$al(EM,PD=)"
  puts $chan "emh=$al(EM,h=)"
  puts $chan "emtt=$al(EM,tt=)"
  puts $chan "emmenu=$al(EM,menu)"
  puts $chan "emmenudir=$al(EM,menudir)"
  puts $chan "emcs=$al(EM,CS)"
  puts $chan "emgeometry=$al(EM,geometry)"
  puts $chan "emexec=$al(EM,exec)"
  for {set i 0} {$i<$em_Num} {incr i} {
    if {[info exists em_sep($i)]} {
      set em_run $em_sep($i)
      append em_run \t $em_ico($i) \t $em_inf($i)
      puts $chan "em_run=$em_run"
    }
  }
  # save the geometry options
  puts $chan ""
  puts $chan {[Geometry]}
  foreach v {Pan PanL PanR PanBM PanTop} {
    if {[info exists al(width$v)]} {
      set w $al(width$v)
    } else {
      set w [winfo geometry [$::alited::obPav $v]]
    }
    puts $chan $v=$w
  }
  puts $chan "GEOM=[wm geometry $al(WIN)]"
  puts $chan "geomfind=$::alited::find::geo"
  puts $chan "minsizefind=$::alited::find::minsize"
  puts $chan "geomproject=$::alited::project::geo"
  puts $chan "minsizeproject=$::alited::project::minsize"
  puts $chan "geompref=$::alited::pref::geo"
  puts $chan "minsizepref=$::alited::pref::minsize"
  puts $chan "treecw0=[[$obPav Tree] column #0 -width]"
  puts $chan "treecw1=[[$obPav Tree] column #1 -width]"
  puts $chan "dirgeometry=$::alited::DirGeometry"
  puts $chan "filgeometry=$::alited::FilGeometry"
  # save other options
  puts $chan ""
  puts $chan {[Misc]}
  puts $chan "isfavor=$al(FAV,IsFavor)"
  puts $chan "chosencolor=$alited::al(chosencolor)"
  close $chan
  SaveIniPrj $newproject
}

proc ini::SaveIniPrj {newproject} {

  namespace upvar ::alited al al obPav obPav
  set tabs $al(tabs)
  set al(tabs) [list]
  if {$al(prjroot) eq ""} return
  set chan [open $al(prjfile) w]
  puts $chan {[Tabs]}
  lassign [alited::bar::GetBarState] TIDcur - wtxt
  if {!$newproject} {
    set tabs [alited::bar::BAR listTab]
  }
  foreach tab $tabs {
    if {!$newproject} {
      set TID [lindex $tab 0]
      set tab [alited::bar::FileName $TID]
      if {[alited::file::IsNoName $tab]} continue
      if {$TID eq $TIDcur} {
        set pos [$wtxt index insert]
      } else {
        set pos [alited::bar::GetTabState $TID --pos]
      }
      append tab \t $pos
    }
    lappend al(tabs) $tab
    puts $chan "tab=$tab"
  }
  foreach rf $al(RECENTFILES) {
    if {![alited::file::IsNoName $rf]} {
      puts $chan "recent=$rf"
    }
  }
  puts $chan ""
  puts $chan {[Options]}
  puts $chan "curtab=[alited::bar::CurrentTab 3]"
  foreach {opt val} [array get al prj*] {
    puts $chan "$opt=$val"
  }
  if {!$newproject} {
    puts $chan ""
    puts $chan {[Favorites]}
    if {$al(FAV,IsFavor)} {
      set favlist [alited::tree::GetTree {} TreeFavor]
    } else {
      set favlist $al(FAV,current)
    }
    foreach curfav $favlist {
      puts $chan "current=$curfav"
    }
    foreach savfav [::alited::favor_ls::PutIni] {
      puts $chan "saved=$savfav"
    }
    foreach visited $al(FAV,visited) {
      puts $chan "visited=$visited"
    }
    puts $chan ""
    puts $chan {[Misc]}
    puts $chan "datafind=[array get ::alited::find::data]"
  }
  close $chan
}

# ______________________ initializing alited app ______________________ #

proc ini::CheckIni {} {
  # 

  namespace upvar ::alited al al
  if {[file exists $::alited::INIDIR] && [file exists $::alited::PRJDIR]} {
    return
  }
  ::apave::APaveInput create pobj
  set head [string map [list %d $::alited::USERDIRSTD] $al(MC,chini2)]
  set res [pobj input info $al(MC,chini1) [list \
      dir1 [list $al(MC,chini3) {} [list -title $al(MC,chini3) -w 50]] "{$::alited::USERDIRSTD}" \
    ] -size 14 -weight bold -head $head]
  pobj destroy
  lassign $res ok ::alited::USERDIRROOT
  if {!$ok} exit
  CreateUserDirs
}

proc ini::GetUserDirs {} {
  namespace upvar ::alited al al
  set ::alited::USERDIR [file join $::alited::USERDIRROOT alited]
  set ::alited::INIDIR [file join $::alited::USERDIR ini]
  set ::alited::PRJDIR [file join $::alited::USERDIR prj]
  if {$al(prjroot) eq ""} {
    set ::alited::BAKDIR [file join $::alited::USERDIR .bak]
  } else {
    set ::alited::BAKDIR [file join $al(prjroot) .bak]
  }
  if {![file exists $::alited::BAKDIR]} {
    catch {file mkdir $::alited::BAKDIR}
  }
  if {$al(EM,menudir) eq ""} {
    set al(EM,menudir) [file join $::alited::USERDIR e_menu menus]
  }
  set al(INI) [file join $::alited::INIDIR alited.ini]
}

proc ini::CreateUserDirs {} {
  namespace upvar ::alited al al DATADIR DATADIR USERDIR USERDIR INIDIR INIDIR PRJDIR PRJDIR MNUDIR MNUDIR BAKDIR BAKDIR
  GetUserDirs
  foreach dir {USERDIR INIDIR PRJDIR} {
    catch {file mkdir [set $dir]}
  }
  if {![file exists $al(INI)]} {
    file copy [file join $DATADIR user ini alited.ini] $al(INI)
    file copy [file join $DATADIR user prj default.ale] \
      [file join $PRJDIR default.ale]
    file copy [file join $DATADIR user notes.txt] [file join $USERDIR notes.txt]
    ReadIni
    InitGUI
  }
  set emdir [file dirname $al(EM,menudir)]
  if {![file exists $emdir]} {
    file mkdir $emdir
    file copy $MNUDIR $emdir
    file copy [file join [file dirname $MNUDIR] em_projects] $emdir
  }
}

proc ini::CreateIcon {icon} {
  set img alimg_$icon
  catch {image create photo $img-big -data [::apave::iconData $icon]}
  catch {image create photo $img -data [::apave::iconData $icon small]}
  return $img
}
# ________________________ Main (+ bar) _________________________ #

proc ini::InitGUI {} {
  # Initializes GUI.

  namespace upvar ::alited al al
  ::apave::obj basicFontSize $al(FONTSIZE,std)
  ::apave::obj csSet $al(INI,CS) . -doit
  if {$al(INI,HUE)} {::apave::obj csToned $al(INI,CS) $al(INI,HUE)}
}

proc ini::_init {} {

  namespace upvar ::alited al al \
    obPav obPav obDlg obDlg obDl2 obDl2 obDl3 obDl3 obFND obFND
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu

  ::apave::initWM
  ::apave::iconImage -init $al(INI,ICONS)
  set ::apave::MC_NS ::alited

  GetUserDirs
  ReadIni
  InitGUI
  CheckIni
  GetUserDirs

  # get hotkeys
  alited::pref::IniKeys
  alited::pref::RegisterKeys
  alited::pref::KeyAccelerators

  # create main apave objects
  ::apave::APaveInput create $obPav $al(WIN)
  ::apave::APaveInput create $obDlg $al(WIN)
  ::apave::APaveInput create $obDl2 $al(WIN)
  ::apave::APaveInput create $obDl3 $al(WIN)
  ::apave::APaveInput create $obFND $al(WIN)

  # here, the order of icons defines their order in the toolbar
  set listIcons [::apave::iconImage]
  # the below icons' order defines their order in the toolbar
  foreach {icon} {none gulls heart add change delete up down plus minus \
  retry misc previous next folder file OpenFile box SaveFile saveall \
  undo redo help replace ok color run other e_menu} {
    set img [CreateIcon $icon]
    if {$icon in {"file" OpenFile box SaveFile saveall help ok color other \
    replace e_menu run undo redo}} {
      append al(atools) " $img-big \{{} -tip {$alited::al(MC,ico$icon)@@ -under 4} "
      switch $icon {
        "file" {
          append al(atools) "-com alited::file::NewFile\}"
        }
        OpenFile {
          append al(atools) "-com alited::file::OpenFile\}"
        }
        box {
          append al(atools) "-com alited::project::_run\} h_ 2 sev 4"
        }
        SaveFile {
          append al(atools) "-com alited::file::SaveFile -state disabled\}"
        }
        saveall {
          append al(atools) "-com alited::file::SaveAll -state disabled\} h_ 2 sev 4"
        }
        undo {
          append al(atools) "-com alited::tool::Undo -state disabled\}"
        }
        redo {
          append al(atools) "-com alited::tool::Redo -state disabled\} h_ 2 sev 4"
        }
        help {
          append al(atools) "-com alited::tool::Help\}"
        }
        replace {
          append al(atools) "-com alited::find::_run\}"
        }
        ok {
          append al(atools) "-com alited::check::_run\}"
        }
        color {
          append al(atools) "-command alited::tool::ColorPicker\} h_ 2 sev 4"
        }
        run {
          append al(atools) "-com alited::tool::_run\}"
        }
        other {
          append al(atools) "-command alited::tool::tkcon\}"
        }
        e_menu {
          image create photo $img-big -data $alited::img::_AL_IMG(e_menu)
          append al(atools) "-com alited::tool::e_menu\}"
        }
      }
    }
  }
  for {set i [set was 0]} {$i<$em_Num} {incr i} {
    if {[info exists em_ico($i)] && ($em_ico($i) ni {none {}} || $em_sep($i))} {
      if {[incr was]==1 && !$em_sep($i)} {
        append al(atools) " h_ 2 sev 4"
      }
      if {$em_sep($i)} {
        append al(atools) " h_ 2 sev 4"
      } else {
        if {[string length $em_ico($i)]==1} {
          set img _$em_ico($i)
          set txt "-t $em_ico($i)"
        } else {
          set img [CreateIcon $em_ico($i)]-big
          set txt {}
        }
        append al(atools) " $img \{{} -tip {$em_mnu($i)@@ -under 4} $txt "
        lassign $em_inf($i) mnu idx
        set ex "ex=[alited::tool::EM_HotKey $idx]"
        append al(atools) "-com {alited::tool::e_menu \"m=$mnu\" $ex}\}"
      }
    }
  }
  for {set i 0} {$i<8} {incr i} {
    image create photo alimg_pro$i -data [set alited::img::_AL_IMG($i)]
  }
  image create photo alimg_tclfile -data [set alited::img::_AL_IMG(Tcl)]
  image create photo alimg_kbd -data [set alited::img::_AL_IMG(kbd)]
  # new find/repl. geometry
  if {$al(FONTSIZE,small) ne $al(FONTSIZE,small)} {
    set ::alited::find::geo [set ::alited::find::minsize ""]
  }
  # styles & fonts used in "small" dialogues
  ::apave::initStylesFS -size $al(FONTSIZE,small)
  lassign [::apave::obj create_FontsType small -size $al(FONTSIZE,small)] \
     al(FONT,defsmall) al(FONT,monosmall)
}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
