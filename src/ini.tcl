###########################################################
# Name:    ini.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/30/2021
# Brief:   Handles settings (of alited and projects).
# License: MIT.
###########################################################

# ___________ Default settings of alited app ____________ #

namespace eval ::alited {

  # versions of mnu/ini to update to
  set al(MNUversion) 1.3.6b7
  set al(INIversion) 1.3.6b8
  # previous version of alited to update from
  set al(ALEversion) 0.0.1

  set al(MAXFILES) 5000     ;# maximum size of file tree (max size of project)
  set al(ED,sp1) 1          ;# -spacing1 option of texts
  set al(ED,sp2) 0          ;# -spacing2 option of texts
  set al(ED,sp3) 0          ;# -spacing3 option of texts
  set al(ED,TclKeyWords) {} ;# user's key words for Tcl
  set al(ED,CKeyWords) {}   ;# user's key words for C/C++
  set al(ED,gutterwidth) 5  ;# gutter's windth in chars
  set al(ED,guttershift) 3  ;# space between gutter and text
  set al(ED,btsbd) 0        ;# borderwidth for bartabs
  set al(TREE,isunits) yes  ;# current mode of tree: units/files
  set al(TREE,units) no     ;# flag "is a unit tree created"
  set al(TREE,files) no     ;# flag "is a file tree created"
  set al(TREE,cw0) 200      ;# tree column #0 width
  set al(TREE,cw1) 70       ;# tree column #1 width
  set al(TREE,showinfo) 0   ;# flag "show info on a file in tips"
  set al(FONT) {}           ;# default font
  set al(FONTSIZE,small) 9  ;# small font size
  set al(FONTSIZE,std) 10   ;# middle font size
  set al(FONT,txt) {}       ;# font for edited texts
  set al(THEME) default     ;# ttk theme
  set al(INI,CS) -1         ;# color scheme
  set al(INI,HUE) 0         ;# tint of color scheme
  set al(INI,ICONS) {middle icons} ;# sets tollbar icons' size as middle
  set al(INI,save_onselect) no ;# do saving alited configuration at tab selection
  set al(INI,save_onadd) no    ;# do saving alited configuration at tab adding
  set al(INI,save_onmove) no   ;# do saving alited configuration at tab  moving
  set al(INI,save_onclose) no  ;# do saving alited configuration at tab closing
  set al(INI,save_onsave) yes  ;# do saving alited configuration at file saving
  set al(INI,maxfind) 16       ;# size for comboboxes of "Find/Replace" dialogue
  set al(INI,barlablen) 16     ;# width of tab labels in chars
  set al(INI,bartiplen) 32     ;# size of tips for tab bar's arrows & of tabs submenu
  set al(INI,confirmexit) 1    ;# flag "confirm exiting alited"
  set al(INI,belltoll) 1       ;# flag "bell at warnings"
  set al(INI,LINES1) 10        ;# number of initial "untouched" lines (to ban moves in it)
  set al(PTP,text) {}          ;# project template's text
  set al(PTP,name) {}          ;# current template name
  set al(PTP,names) [list]     ;# all template names
  set al(PTP,list) [list]      ;# list of pairs "name contents"
  set al(moveall) 1            ;# "move all" of color chooser
  set al(tonemoves) 1          ;# "tone moves" of color chooser
  set al(checkgeo) {}          ;# geometry of "Check Tcl" window
  set al(HelpedMe) {}          ;# list of helped windows shown by HelpMe proc
  set al(cmdNum) 5             ;# number of commands on Commands tab

  # flag "use special RE for leafs of unit tree"
  set al(INI,LEAF) 0

  # RE for branches of unit tree ( # _ lev 1 _..)
  set al(RE,branchDEF) {^\s*(#+) [_]+\s+([^_]+[^[:blank:]]*)\s+[_]+ (#+)$}
  set al(RE,branch) $al(RE,branchDEF)

  # special RE for leafs (# --  / # -- abc / # --abc--)
  set al(RE,leafDEF) {^\s*##\s*[-]*([^-]*)\s*[-]*$}
  set al(RE,leaf) $al(RE,leafDEF)

  # RE for Tcl leaf units
  set al(RE,procDEF) {^\s*(((proc|method)\s+([^[:blank:]]+))|((constructor|destructor)\s+))}
  set al(RE,proc) $al(RE,procDEF)

  # RE to check for leaf units (# _  / # _ abc)
  set al(RE,leaf2DEF) {^\s*(#+) [_]+}
  set al(RE,leaf2) $al(RE,leaf2DEF)

  # RE to check for Tcl leaf units (proc abc {}...)
  set al(RE,proc2DEF) {^\s*(proc|method|constructor|destructor)\s+}
  set al(RE,proc2) $al(RE,proc2DEF)

  # list of current favorite units
  set al(FAV,current) [list]

  # list of current visited units
  set al(FAV,visited) [list]

  # flag "is now favorites (not last visited)"
  set al(FAV,IsFavor) yes

  # maximum of "last visited" items
  set al(FAV,MAXLAST) 32

  # templates' list
  set al(TPL,list) [list]

  # wildcards for templates
  set al(TPL,%d) %D
  set al(TPL,%t) %T
  set al(TPL,%u) aplsimple
  set al(TPL,%U) {Alex Plotnikov}
  set al(TPL,%m) aplsimple@gmail.com
  set al(TPL,%w) https://aplsimple.github.io
  set al(TPL,%a) {  #   %a - \\n}

  # key bindings
  set al(KEYS,bind) [list]

  # e_menu settings and arguments
  set al(EM,geometry) {}
  set al(EM,save) {}
  set al(EM,PD=) ~/.config/alited/e_menu/em_projects
  set al(EM,Tcl) {}
  set al(EM,TclList) [list]
  set al(EM,h=) ~/DOC/www.tcl.tk/man/tcl8.6
  set al(EM,tt=) x-terminal-emulator
  set al(EM,tt=List) "$al(EM,tt=)\tlxterminal --geometry=220x55\txterm\tmlterm\tqterminal\tEterm\tkonsole\txgterm"
  set al(EM,wt=) cmd.exe
  set al(EM,wt=List) "$al(EM,wt=)\tpowershell.exe"
  set al(EM,mnu) menu.em
  set al(EM,mnudir) {}
  set al(EM,CS) 33
  set al(EM,ownCS) no
  set al(EM,exec) yes
  set al(EM,DiffTool) kdiff3

  # data of tabs
  set al(tablist) [list]

  # list "Recent files" and its max length
  set al(RECENTFILES) [list]
  set al(INI,RECENTFILES) 16

  # this is used at closing tabs to disable registering in "Recent files"
  set al(closefunc) 0

  # initial color of "Choose color" dialogue
  set alited::al(chosencolor) green

  # subdirectory of project to backup files at modifications
  # and maximum of backups
  set al(BACKUP) .bak
  set al(MAXBACKUP) 1

  # enables/disables call of LastVisited in tree::NewSelection
  set al(dolastvisited) yes

  # current text's wrap words mode
  set al(wrapwords) 1

  # cursor's width
  set al(CURSORWIDTH) 2

  # defaults for projects
  foreach _ $::alited::OPTS {set prjinfo(DEFAULT,$_) $::alited::al($_)}
  set al(PRJDEFAULT) 1  ;# is Preferences/General/Projects/Default values for new projects

  # use localized messages
  set al(LOCAL) {}
  catch {set al(LOCAL) [string range [::msgcat::mclocale] 0 1]}

  # data for "Search by list"
  set al(listSBL) {}
  set al(matchSBL) {}
  set al(wordonlySBL) 0
  set al(caseSBL) 1

  # info about current unit
  set al(CURRUNIT,line) 0
  set al(CURRUNIT,line1) 0
  set al(CURRUNIT,line2) 0
  set al(CURRUNIT,wtxt) {}
  set al(CURRUNIT,itemID) {}

  # list of "Find Unit" combobox's values
  set al(findunitvals) {}

  # commands after starting alited
  set al(afterstart) {}

  # index of syntax colors
  set al(syntaxidx) 0

  # preferrable command to run
  set al(comForce) {}
  set al(comForceCh) -1
  set al(comForceLs) {}

  # flags of tip show
  set al(TIPS,Tree) 1
  set al(TIPS,TreeFavor) 1
  set al(TIPS,Projects) 1
  set al(TIPS,Preferences) 1
  set al(TIPS,Templates) 1
  set al(TIPS,SavedFavorites) 1

  # flag "sorted file list"
  set al(sortList) 0

  # modes to sort bartabs
  set al(incdecName) increasing
  set al(incdecDate) decreasing
  set al(incdecSize) decreasing
  set al(incdecExtn) increasing

  # mode "place tabs to the beginning of bar"
  set al(lifo) 1
}

# ________________________ Variables _________________________ #

namespace eval ini {
  variable afterID {}  ;# after ID used by SaveCurrentIni proc
  variable configs {}  ;# list of configurations
}

# ________________________ Reading common settings _________________________ #

proc ini::ReadIni {{projectfile ""}} {
  # Reads alited application's and project's settings.
  #   projectfile - project file's name

  namespace upvar ::alited al al
  namespace upvar ::alited::project prjlist prjlist prjinfo prjinfo
  alited::pref::Tkcon_Default
  set prjlist [list]
  set al(TPL,list) [list]
  set al(KEYS,bind) [list]
  set em_i 0
  set fontsize [expr {$al(FONTSIZE,std)+1}]
  set al(FONT,txt) "-family {[::apave::obj basicTextFont]} -size $fontsize"
  lassign "" ::alited::Pan_wh ::alited::PanL_wh ::alited::PanR_wh \
    ::alited::PanBM_wh ::alited::PanTop_wh ::alited::al(GEOM)
  catch {
    puts "alited pwd    : [pwd]"
    puts "alited reading: $al(INI)"
    if {$al(ini_file) eq {}} {
      # al(ini_file) may be already filled (see alited.tcl)
      set al(ini_file) [split [::apave::readTextFile $::alited::al(INI)] \n]
    }
    set mode ""
    foreach stini $al(ini_file) {
      switch -exact $stini {
        {[Geometry]} - {[Options]} - {[Projects]} - {[Templates]} - {[Keys]} - {[EM]} - {[Tkcon]} - {[Misc]} {
          set mode $stini
          continue
        }
      }
      if {[set i [string first = $stini]]>0} {
        set nam [string range $stini 0 $i-1]
        set val [string range $stini $i+1 end]
        switch -exact $mode {
          {[Geometry]}  {ReadIniGeometry $nam $val}
          {[Options]}   {ReadIniOptions $nam $val}
          {[Templates]} {ReadIniTemplates $nam $val}
          {[Keys]}      {ReadIniKeys $nam $val}
          {[EM]}        {ReadIniEM $nam $val em_i}
          {[Tkcon]}     {ReadIniTkcon $nam $val}
          {[Misc]}      {ReadIniMisc $nam $val}
        }
      }
    }
  }
  if {[set al(PTP,text) [lindex $al(PTP,list) 1]] eq {}} {
    set al(PTP,text) [alited::project::TplDefaultText]
    set al(PTP,list) [list Default $al(PTP,text)]
  }
  set al(PTP,name) [lindex $al(PTP,list) 0]
  set al(PTP,names) [list]
  foreach {n c} $al(PTP,list) {lappend al(PTP,names) $n}
  if {$projectfile eq {} && $al(prjfile) eq {}} {
    # some options may be active outside of any project; fill them with defaults
    foreach opt {multiline indent indentAuto EOL trailwhite} {
      set al(prj$opt) $al(DEFAULT,prj$opt)
    }
  } else {
    if {$projectfile eq {}} {
      set projectfile $al(prjfile)
    } else {
      set al(prjfile) $projectfile
    }
    ReadIniOptions project $projectfile
  }
  catch {
    lassign [split $::alited::PanR_wh] - w1 - h1
    lassign [split $::alited::PanTop_wh] - w2 - h2
    if {($h1-$h2)<60} {
      set h2 [expr {$h1-60}]
      set ::alited::PanTop_wh "-w $w2 -h $h2" ;# the status bar is wanted
    }
  }
  ReadIniPrj
  set al(TEXT,opts) "-padx 3 -spacing1 $al(ED,sp1) -spacing2 $al(ED,sp2) -spacing3 $al(ED,sp3)"
  if {!$al(INI,belltoll)} {
    ; proc ::bell args {}  ;# no bells
  }
  if {![string is digit -strict $al(INI,confirmexit)]} {
    set al(INI,confirmexit) 1
  }
  if {![info exists al(tkcon,clrbg)]} {
    alited::pref::Tkcon_Default
    alited::pref::Tkcon_Default1
  }
  set al(ini_file) {}  ;# to reread alited.ini contents, at need in next time
}
#_______________________

proc ini::ReadIniGeometry {nam val} {
  # Gets the geometry options of alited.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  switch -glob -- $nam {
    Pan* {
      lassign [::apave::splitGeometry $val] w h
      set ::alited::${nam}_wh "-w $w -h $h"
    }
    GEOM {
      lassign [::apave::splitGeometry $val] w h x y
      set ::alited::al(GEOM) "-geometry $x$y"
    }
    geomfind       {set ::alited::find::geo $val}
    geomfind2      {set ::alited::find::geo2 $val}
    geomproject    {set ::alited::project::geo $val}
    geompref       {set ::alited::pref::geo $val}
    dirgeometry    {set ::alited::DirGeometry $val}
    filgeometry    {set ::alited::FilGeometry $val}
    treecw0        {set al(TREE,cw0) $val}
    treecw1        {set al(TREE,cw1) $val}
  }
}
#_______________________

proc ini::ReadIniOptions {nam val} {
  # Gets various options of alited.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  set clrnames [::hl_tcl::hl_colorNames]
  foreach lng {{} C} {
    set nam1 [string range $nam [string length $lng] end]
    if {[lsearch $clrnames $nam1]>-1} {
      set al(ED,$nam) $val
      return
    }
  }
  switch -glob -- $nam {
    comm_port_list {set al(comm_port_list) $val}
    project {
      set al(prjfile) $val
      set al(prjname) [file tail [file rootname $val]]
    }
    theme         {set al(THEME) $val}
    cs            {set al(INI,CS) $val}
    hue           {set al(INI,HUE) $val}
    local         {set al(LOCAL) $val}
    deffont       {set al(FONT) $val}
    smallfontsize {set al(FONTSIZE,small) $val}
    stdfontsize   {set al(FONTSIZE,std) $val}
    txtfont       {set al(FONT,txt) $val}
    maxfind       {set al(INI,maxfind) $val}
    confirmexit   {set al(INI,confirmexit) $val}
    belltoll      {set al(INI,belltoll) $val}
    spacing1      {set al(ED,sp1) $val}
    spacing2      {set al(ED,sp2) $val}
    spacing3      {set al(ED,sp3) $val}
    TclKeyWords   {set al(ED,TclKeyWords) $val}
    CKeyWords     {set al(ED,CKeyWords) $val}
    clrDark       {set al(ED,Dark) $val}
    save_onadd - save_onclose - save_onsave {set al(INI,$nam) $val}
    TclExts       {set al(TclExtensions) $val}
    ClangExts     {set al(ClangExtensions) $val}
    TextExts      {set al(TextExtensions) $val}
    REbranch      {set al(RE,branch) $val}
    REproc        {set al(RE,proc) $val}
    REproc2       {set al(RE,proc2) $val}
    REleaf        {set al(RE,leaf) $val}
    REleaf2       {set al(RE,leaf2) $val}
    UseLeaf       {set al(INI,LEAF) $val}
    Lines1        {set al(INI,LINES1) $val}
    RecentFiles   {set al(INI,RECENTFILES) $val}
    MaxLast       {set al(FAV,MAXLAST) $val}
    MaxFiles      {set al(MAXFILES) $val}
    barlablen     {set al(INI,barlablen) $val}
    bartiplen     {set al(INI,bartiplen) $val}
    prjtpls       {set al(PTP,list) [string map [list $alited::EOL \n] $val]}
    backup        {
      if {$val ne {.bak}} {set val {}}
      set al(BACKUP) $val
    }
    maxbackup     {set al(MAXBACKUP) $val}
    gutterwidth   {set al(ED,gutterwidth) $val}
    guttershift   {set al(ED,guttershift) $val}
    btsbd         {set al(ED,btsbd) $val}
    cursorwidth   {set al(CURSORWIDTH) $val}
    prjdefault    {set al(PRJDEFAULT) $val}
    DEFAULT,*     {set al($nam) $val}
    findunit      {set al(findunitvals) $val}
    afterstart    {set al(afterstart) $val}
    ALEversion    {set al(ALEversion) $val}
  }
}
#_______________________

proc ini::ReadIniTemplates {nam val {updwc yes}} {
  # Sets new or updates old templates.
  #   nam - name of option
  #   val - value of option
  #   updwc - if yes, sets wild cards for templates

  namespace upvar ::alited al al
  switch -exact -- $nam {
    tpl {
      lassign $val tplname tplkey
      if {[set i [lsearch -exact -index 0 $al(TPL,list) $tplname]]<0} {
        # at inserting new, check for possible duplicate 'tplkey'
        set i [lsearch -exact -index 1 $al(TPL,list) $tplkey]
        lappend al(TPL,list) $val
        # key bindings
        if {$tplkey ne {}} {
          if {$i<0} {
            # add a new key binding, for this template
            set kbval "template {$tplname} $tplkey {[lrange $val 2 end]}"
            lappend al(KEYS,bind) $kbval
          } else {
            # duplicate 'tplkey' => clear it in the new template, no key binding
            set val [lreplace $val 1 1 {}]
            set al(TPL,list) [lreplace $al(TPL,list) end end $val]
          }
        }
      } else {
        # at updating old, replace the contents only (remaining 'tplname tplkey')
        set val2 [lindex $al(TPL,list) $i]
        set val [list {*}[lrange $val2 0 1] {*}[lrange $val 2 end]]
        set al(TPL,list) [lreplace $al(TPL,list) $i $i $val]
      }
    }
  }
  if {$updwc} {
    foreach n {%d %t %u %U %m %w %a} {
      if {$n eq $nam} {
        if {$val ne ""} {set al(TPL,$n) $val}
        break
      }
    }
  }
}
#_______________________

proc ini::ReadIniKeys {nam val} {
  # Gets keys options of alited.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  switch -exact -- $nam {
    key {lappend al(KEYS,bind) $val}
  }
}
#_______________________

proc ini::ReadIniEM {nam val emiName} {
  # Gets e_menu options of alited.
  #   nam - name of option
  #   val - value of option
  #   emiName - name of em_i (index in arrays of e_menu data)

  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu
  upvar $emiName em_i
  switch -exact $nam {
    emPD       {set al(EM,PD=) $val}
    emTcl      {set al(EM,Tcl) $val}
    emTclList  {set al(EM,TclList) $val}
    em_run {
      if {$em_i < $em_Num} {
        lassign [split $val \t] em_sep($em_i) em_ico($em_i) em_inf($em_i)
        set em_mnu($em_i) [alited::NormalizeName [lindex $em_inf($em_i) end]]
      }
      incr em_i
    }
  }
  if {[string trim $val] eq {}} return  ;# options below should be non-empty
  switch -exact $nam {
    emgeometry {set al(EM,geometry) $val}
    emsave     {set al(EM,save) $val}
    emtt       {set al(EM,tt=) $val}
    emttList   {set al(EM,tt=List) $val}
    emwt       {set al(EM,wt=) $val}
    emmenu     {if {[file exists $val]} {set al(EM,mnu) $val}}
    emmenudir  {if {[file exists $val]} {set al(EM,mnudir) $val}}
    emcs       {set al(EM,CS) $val}
    emowncs    {set al(EM,ownCS) $val}
    emdiff     {set al(EM,DiffTool) $val}
    emh        {set al(EM,h=) $val}
  }
#    emexec     #\{set al(EM,exec) $val#\}
}
#_______________________

proc ini::ReadIniTkcon {nam val} {
  # Gets tkcon options of alited.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  set al(tkcon,$nam) $val
}
#_______________________

proc ini::ReadIniMisc {nam val} {
  # Gets miscellaneous options of alited.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  switch -glob -- $nam {
    isfavor {set al(FAV,IsFavor) $val}
    showinfo {set al(TREE,showinfo) $val}
    TIPS,* {set al($nam) $val}
    listSBL - HelpedMe - checkgeo - tonemoves - moveall - chosencolor - sortList {
      set al($nam) $val
    }
    tplilast {set ::alited::unit_tpl::ilast $val}
    incdec {lassign $val al(incdecName) al(incdecDate) al(incdecSize) al(incdecExtn)}
    blifo {set al(lifo) [string is true $val]}
  }
}

# _______________________ Reading project settings _________________________ #

proc ini::ReadIniPrj {} {
  # Reads a project's settings.

  namespace upvar ::alited al al PRJEXT PRJEXT
  set al(tabs) [list]
  set al(curtab) 0
  set al(_check_menu_state_) 1
  set al(comForce) [set al(comForceLs) {}]
  set al(FAV,current) [list]
  set al(FAV,visited) [list]
  alited::favor::InitFavorites [list]
  alited::favor_ls::GetIni {}
  if {![file exists $al(prjfile)]} {
    set al(prjfile) [file join $alited::PRJDIR default$PRJEXT]
  }
  set al(prjname) [file tail [file rootname $al(prjfile)]]
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
  }]} then {
    puts "Not open: $al(prjfile)"
    set al(prjname) {}
    set al(prjfile) {}
    set al(prjroot) {}
  }
  if {$al(prjroot) eq {} && $al(prjname) eq {default}} {set al(prjroot) $alited::DIR}
  alited::favor::InitFavorites $al(FAV,current)
  catch {close $chan}
  catch {cd $al(prjroot)}
  if {![string is digit -strict $al(curtab)] || \
  $al(curtab)<0 || $al(curtab)>=[llength $al(tabs)]} {
    set al(curtab) 0
  }
  ::apave::textEOL $al(prjEOL)
}
#_______________________

proc ini::ReadPrjTabs {nam val} {
  # Gets tabs of project.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  if {[string trim $val] ne {}} {
    switch -exact -- $nam {
      tab {lappend al(tabs) $val}
      recent {alited::file::InsertRecent $val end}
      encode - eol {
        lassign [split $val \t] k v
        set al($k) $v
      }
    }
  }
}
#_______________________

proc ini::ReadPrjOptions {nam val} {
  # Gets options of project.
  #   nam - name of option
  #   val - value of option

  if {$nam in {{} prjfile prjname}} {
    return ;# to avoid resetting the current project file name
  }
  namespace upvar ::alited al al
  set al($nam) $val
}
#_______________________

proc ini::ReadPrjFavorites {nam val} {
  # Gets favorites of project.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  switch -exact -- $nam {
    current - visited {lappend al(FAV,$nam) $val}
    saved   {alited::favor_ls::GetIni $val}
  }
}
#_______________________

proc ini::ReadPrjMisc {nam val} {
  # Gets favorites of project.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  switch -exact -- $nam {
    datafind {
      catch {
        # lists of find/replace strings to be restored only
        set ::alited::find::data(en1) {}
        set ::alited::find::data(en2) {}
        array set data $val
        set ::alited::find::data(vals1) $data(vals1)
        set ::alited::find::data(vals2) $data(vals2)
      }
    }
    comforce {
      set al(comForce) $val
      if {$al(comForceCh)==-1} {set al(comForceCh) [expr {$val ne {}}]}
    }
    comforcech {set al(comForceCh) $val}
    comforcels {set al(comForceLs) $val}
  }
}

# ____________________________ Saving settings ____________________________ #

proc ini::SaveCurrentIni {{saveon yes} {doit no}} {
  # Saves a current configuration of alited on various events.
  #   saveon - flag "save on event"
  #   doit - serves to run this procedure after idle
  # See also: project::Ok

  namespace upvar ::alited al al
  # for sessions to come
  if {![expr $saveon]} return
  # al(project::Ok) is set at switching projects and closing old project's files
  if {[info exists al(project::Ok)]} return
  variable afterID
  # run this code after updating GUI
  catch {after cancel $afterID}
  if {$doit} {
    SaveIni
  } else {
    set afterID [after idle ::alited::ini::SaveCurrentIni yes yes]
  }
}
#_______________________

proc ini::SaveIni {{newproject no}} {
  # Saves a current configuration of alited.
  #   newproject - flag "for a new project"

  namespace upvar ::alited al al obPav obPav
  namespace upvar ::alited::pref em_Num em_Num em_sep em_sep em_ico em_ico em_inf em_inf
  namespace upvar ::alited::project prjlist prjlist prjinfo prjinfo
  puts "alited storing: $al(INI)"
  set chan [open $::alited::al(INI) w]
  puts $chan {[Options]}
  puts $chan "comm_port=$al(comm_port)"
  puts $chan "comm_port_list=$al(comm_port_list)"
  puts $chan "project=$al(prjfile)"
  puts $chan "theme=$al(THEME)"
  puts $chan "cs=$al(INI,CS)"
  puts $chan "hue=$al(INI,HUE)"
  puts $chan "local=$al(LOCAL)"
  puts $chan "deffont=$al(FONT)"
  puts $chan "smallfontsize=$al(FONTSIZE,small)"
  puts $chan "stdfontsize=$al(FONTSIZE,std)"
  puts $chan "txtfont=$al(FONT,txt)"
  puts $chan "maxfind=$al(INI,maxfind)"
  puts $chan "confirmexit=$al(INI,confirmexit)"
  puts $chan "belltoll=$al(INI,belltoll)"
  puts $chan "spacing1=$al(ED,sp1)"
  puts $chan "spacing2=$al(ED,sp2)"
  puts $chan "spacing3=$al(ED,sp3)"
  puts $chan "CKeyWords=$al(ED,CKeyWords)"
  puts $chan "TclKeyWords=$al(ED,TclKeyWords)"
  puts $chan "cursorwidth=$al(CURSORWIDTH)"
  set clrnams [::hl_tcl::hl_colorNames]
  foreach lng {{} C} {
    foreach nam $clrnams {puts $chan "$lng$nam=$al(ED,$lng$nam)"}
  }
  puts $chan "clrDark=$al(ED,Dark)"
  puts $chan "save_onadd=$al(INI,save_onadd)"
  puts $chan "save_onclose=$al(INI,save_onclose)"
  puts $chan "save_onsave=$al(INI,save_onsave)"
  puts $chan "TclExts=$al(TclExtensions)"
  puts $chan "ClangExts=$al(ClangExtensions)"
  puts $chan "TextExts=$al(TextExtensions)"
  puts $chan "REbranch=$al(RE,branch)"
  puts $chan "REproc=$al(RE,proc)"
  puts $chan "REproc2=$al(RE,proc2)"
  puts $chan "REleaf=$al(RE,leaf)"
  puts $chan "REleaf2=$al(RE,leaf2)"
  puts $chan "UseLeaf=$al(INI,LEAF)"
  puts $chan "Lines1=$al(INI,LINES1)"
  puts $chan "RecentFiles=$al(INI,RECENTFILES)"
  puts $chan "MaxLast=$al(FAV,MAXLAST)"
  puts $chan "MaxFiles=$al(MAXFILES)"
  puts $chan "barlablen=$al(INI,barlablen)"
  puts $chan "bartiplen=$al(INI,bartiplen)"
  puts $chan prjtpls=[string map [list \n $alited::EOL] $al(PTP,list)]
  puts $chan "backup=$al(BACKUP)"
  puts $chan "maxbackup=$al(MAXBACKUP)"
  puts $chan "gutterwidth=$al(ED,gutterwidth)"
  puts $chan "guttershift=$al(ED,guttershift)"
  puts $chan "btsbd=$al(ED,btsbd)"
  puts $chan "prjdefault=$al(PRJDEFAULT)"
  foreach k [array names al DEFAULT,*] {
    puts $chan "$k=$al($k)"
  }
  puts $chan "findunit=$al(findunitvals)"
  puts $chan "afterstart=$al(afterstart)"
  puts $chan "ALEversion=[AlitedVersion]"

  puts $chan {}
  puts $chan {[Templates]}
  foreach t $al(TPL,list) {
    puts $chan "tpl=$t"
  }
  foreach n {%d %t %u %U %m %w %a} {
    puts $chan "$n=$al(TPL,$n)"
  }
  puts $chan {}
  puts $chan {[Keys]}
  foreach k $al(KEYS,bind) {
    if {![string match template* $k] && ![string match action* $k]} {
      puts $chan "key=$k"
    }
  }
  puts $chan {}
  puts $chan {[EM]}
  puts $chan "emsave=$al(EM,save)"
  puts $chan "emPD=$al(EM,PD=)"
  puts $chan "emTcl=$al(EM,Tcl)"
  puts $chan "emTclList=$al(EM,TclList)"
  puts $chan "emh=$al(EM,h=)"
  puts $chan "emtt=$al(EM,tt=)"
  puts $chan "emttList=$al(EM,tt=List)"
  puts $chan "emwt=$al(EM,wt=)"
  puts $chan "emmenu=$al(EM,mnu)"
  puts $chan "emmenudir=$al(EM,mnudir)"
  puts $chan "emcs=$al(EM,CS)"
  puts $chan "emowncs=$al(EM,ownCS)"
  puts $chan "emgeometry=$al(EM,geometry)"
  #  puts $chan "emexec=$al(EM,exec)"
  puts $chan "emdiff=$al(EM,DiffTool)"
  for {set i 0} {$i<$em_Num} {incr i} {
    if {[info exists em_sep($i)]} {
      set em_run $em_sep($i)
      append em_run \t $em_ico($i) \t $em_inf($i)
      puts $chan "em_run=$em_run"
    }
  }
  puts $chan {}
  puts $chan {[Tkcon]}
  foreach k [array names al tkcon,*] {
    puts $chan "[string range $k 6 end]=$al($k)"
  }
  # save the geometry options
  puts $chan {}
  puts $chan {[Geometry]}
  foreach v {Pan PanL PanR PanBM PanTop} {
    if {[info exists al(width$v)]} {
      set w $al(width$v)
    } else {
      set w [winfo geometry [$obPav $v]]
    }
    puts $chan $v=$w
  }
  puts $chan "GEOM=[wm geometry $al(WIN)]"
  puts $chan "geomfind=$::alited::find::geo"
  puts $chan "geomfind2=$::alited::find::geo2"
  puts $chan "geomproject=$::alited::project::geo"
  puts $chan "geompref=$::alited::pref::geo"
  set wtree [$obPav Tree]
  set al(TREE,cw0) [$wtree column #0 -width]
  set al(TREE,cw1) [$wtree column #1 -width]
  puts $chan "treecw0=$al(TREE,cw0)"
  puts $chan "treecw1=$al(TREE,cw1)"
  puts $chan "dirgeometry=$::alited::DirGeometry"
  puts $chan "filgeometry=$::alited::FilGeometry"
  # save other options
  puts $chan {}
  puts $chan {[Misc]}
  puts $chan "isfavor=$al(FAV,IsFavor)"
  puts $chan "chosencolor=$al(chosencolor)"
  puts $chan "showinfo=$al(TREE,showinfo)"
  set al(listSBL) [string map [list \n $alited::EOL] $al(listSBL)]
  puts $chan "listSBL=$al(listSBL)"
  puts $chan "moveall=$al(moveall)"
  puts $chan "tonemoves=$al(tonemoves)"
  puts $chan "checkgeo=$al(checkgeo)"
  puts $chan "HelpedMe=$al(HelpedMe)"
  foreach k [array names al TIPS,*] {
    puts $chan "$k=$al($k)"
  }
  puts $chan "sortList=$al(sortList)"
  puts $chan "tplilast=$::alited::unit_tpl::ilast"
  puts $chan "incdec=$al(incdecName) $al(incdecDate) $al(incdecSize) $al(incdecExtn)"
  puts $chan "blifo=$al(lifo)"
  close $chan
  SaveIniPrj $newproject
  # save last directories entered
  set lastini \
    [file dirname $::alited::al(INI)]\n[file dirname $al(prjfile)]\n$::alited::CONFIGS
  ::apave::writeTextFile $::alited::USERLASTINI lastini
}
#_______________________

proc ini::SaveIniPrj {{newproject no}} {
  # Saves settings of project.
  #   newproject - flag "for a new project"

  namespace upvar ::alited al al
  if {$al(prjroot) eq {}} return
  set tabs $al(tabs)
  set al(tabs) [list]
  puts "alited storing: $al(prjfile)"
  set chan [open $al(prjfile) w]
  puts $chan {[Tabs]}
  lassign [alited::bar::GetBarState] TIDcur - wtxt
  if {!$newproject} {
    set tabs [alited::bar::BAR listTab]
  }
  foreach tab $tabs {  ;# save the current files' list & states
    if {!$newproject} {
      set TID [lindex $tab 0]
      set tab [alited::bar::FileName $TID]
      if {[alited::file::IsNoName $tab]} continue
      if {$TID eq $TIDcur} {
        set pos [$wtxt index insert]
      } else {
        set pos [alited::bar::GetTabState $TID --pos]
      }
      append tab \t $pos  ;# save the current cursor position (fit to all files)
      catch {
        set wrap [[alited::main::GetWTXT $TID] cget -wrap]
        if {$wrap ne {word}} {
          append tab \t $wrap  ;# save the current wrap!=word (fit to strange files)
        }
      }
    }
    lappend al(tabs) $tab
    puts $chan tab=$tab
  }
  foreach rf $al(RECENTFILES) {
    if {![alited::file::IsNoName $rf]} {
      puts $chan recent=$rf
    }
  }
  foreach {key1 key2} {ENCODING encode EOL eol} {
    foreach k [array names al $key1,*] {
      if {$al($k) ni {utf-8 auto}} {
        # restrict the saved with currently used files only
        set fname [string range $k [string first , $k]+1 end]
        if {$fname in $al(RECENTFILES) || [alited::bar::FileTID $fname] ne {}} {
          puts $chan "$key2=$k\t$al($k)"
        }
      }
    }
  }
  puts $chan {}
  puts $chan {[Options]}
  puts $chan curtab=[alited::bar::CurrentTab 3]
  foreach {opt val} [array get al prj*] {
    puts $chan $opt=$val
  }
  if {!$newproject} {
    puts $chan {}
    puts $chan {[Favorites]}
    if {$al(FAV,IsFavor)} {
      set favlist [alited::tree::GetTree {} TreeFavor]
    } else {
      set favlist $al(FAV,current)
    }
    foreach curfav $favlist {
      puts $chan current=$curfav
    }
    foreach savfav [::alited::favor_ls::PutIni] {
      puts $chan saved=$savfav
    }
    foreach visited $al(FAV,visited) {
      puts $chan visited=$visited
    }
    puts $chan {}
    puts $chan {[Misc]}
    puts $chan datafind=[array get ::alited::find::data]
    puts $chan comforce=$al(comForce)
    puts $chan comforcech=$al(comForceCh)
    puts $chan comforcels=$al(comForceLs)
  }
  puts \n
  close $chan
}

# ______________________ Updating alited's data ______________________ #

proc ini::AlitedVersion {} {
  # Gets current version of alited.

  return [package require alited]
}
#_______________________

proc ini::ViewUpdates {} {
  # Views changes for updating.

  namespace upvar ::alited DATADIR DATADIR
  ::apave::obj vieweditFile [file join $DATADIR to-update.txt] {} -rotext 1 -h 25
}
#_______________________

proc ini::UpdateTemplates {inideffile} {
  # Updates templates.
  #   inideffile - ini file name of default templates

  set tplmode 0
  # read new templates: from [Templates] to [Keys]
  foreach stini [split [::apave::readTextFile $inideffile {} 1] \n] {
    switch -exact $stini {
      {[Templates]} {set tplmode 1}
      {[Keys]} break
    }
    if {$tplmode && [set i [string first = $stini]]>0} {
      set nam [string range $stini 0 $i-1]
      set val [string range $stini $i+1 end]
      ReadIniTemplates $nam $val no
    }
  }
}
#_______________________

proc ini::CheckUpdates {doit} {
  # Updates significant data of current version of alited.
  #   doit - yes, if it's called from menu

  namespace upvar ::alited al al DATAUSERINIFILE DATAUSERINIFILE MNUDIR MNUDIR
  set al(_updmnu_) [expr {$doit || [package vcompare $al(ALEversion) $al(MNUversion)]<0}]
  set al(_updini_) [expr {$doit || [package vcompare $al(ALEversion) $al(INIversion)]<0}]
  if {!$al(_updmnu_) && !$al(_updini_)} return
  set head "\n [msgcat::mc {Some things have been changed in alited %v.}] \n"
  set head [string map [list %v v[AlitedVersion]] $head]
  set date _[clock format [clock seconds] -format %Y-%m-%d]
  set al(_updDirMnu_) [file normalize $al(EM,mnudir)$date]
  set inidir [file dirname $al(INI)]
  set inifile [file tail $al(INI)]
  set iniext [file extension $inifile]
  set inifile [file rootname $inifile]
  set al(_updFileIni_) [file normalize [file join $inidir $inifile$date$iniext]]
  set pobj alitedObjToDel
  ::apave::APaveInput create $pobj $al(WIN)
  set mnudo [expr {![file exists $al(_updDirMnu_)]}]
  set inido [expr {![file exists $al(_updFileIni_)]}]
  if {$doit} {
    set lab5 {}
    set ::alited::al(_updmnu_) $mnudo
    set ::alited::al(_updini_) $inido
  } else {
    set lab5 [list \
      seh2  {{} {-pady 10} {}} {} \
      lab5  {{} {-padx 5} {-t {$::alited::al(MC,restart)}}} {} \
    ]
  }
  lassign [$pobj input {} $al(MC,updateALE) [list \
    lab1  {{} {} {-t {$::alited::al(MC,updLab1)}}}  {} \
    chb1  {{} {-padx 10} {-t {$::alited::al(MC,updmnu)}}} {$::alited::al(_updmnu_)} \
    chb2  {{} {-padx 10} {-t {$::alited::al(MC,updini)}}} {$::alited::al(_updini_)} \
    seh1  {{} {-pady 10} {}} {} \
    lab2  {{} {} {-t {$::alited::al(MC,updLab2)}}} {} \
    lab3  {{} {-padx 20} {-t {$::alited::al(_updDirMnu_)}}} {} \
    lab4  {{} {-padx 20} {-t {$::alited::al(_updFileIni_)}}} {} \
    {*}$lab5 \
    ] -head $head -weight bold -buttons "butHELP {View Changes} ::alited::ini::ViewUpdates" -resizable no -focus *YES] \
    res updmnu updini
  catch {$pobj destroy}
  if {!$res} {if {$doit} return else exit}
  if {!$updmnu && !$updini} return
  set err {}
  set mnudone 0
  set inidone 0
  if {$updmnu && $mnudo && \
  ![catch {file rename $al(EM,mnudir) $al(_updDirMnu_)} err]} {
    set err {}
  }
  if {$err eq {} && $updmnu && $mnudo} {
    if {![catch {file copy $MNUDIR $al(EM,mnudir)} err]} {
      set err {}
      set mnudone 1
    }
  }
  if {$err eq {} && $updini && $inido && \
  ![catch {file copy $al(INI) $al(_updFileIni_)} err]} {
    set err {}
    set inidone 1
  }
  if {$err eq {} && $inidone} {
    UpdateTemplates $DATAUSERINIFILE
  }
  alited::ini::SaveIni
  if {!$doit} {
    alited::Exit - 1 no
  } else {
    if {$err ne {}} {
      ::apave::APaveInput create $pobj $al(WIN)
      $pobj ok err Error $err -text 1 -w 50 -h {3 5}
      catch {$pobj destroy}
    } elseif {$mnudone || $inidone} {
      set msg "$al(MC,updateALE):"
      if {$mnudone} {append msg "   $al(MC,updmnu)"}
      if {$inidone} {append msg "   $al(MC,updini)"}
      alited::Message "\n $msg \n" 3
    }
  }
}

# ______________________ Configuring alited ______________________ #

proc ini::GetConfiguration {} {
  # Gets the configuration directory's name.

  namespace upvar ::alited al al obDl2 obDl2
  variable configs
  set configs $::alited::CONFIGS
  if {![llength $configs]} {lappend configs $::alited::CONFIGDIR}
  if {[lindex $configs 0] eq {-}} {
    set configs [lreplace $configs 0 0]  ;# legacy
  }
  set head [string map [list %d $::alited::CONFIGDIRSTD] $al(MC,chini2)]
  set pobj $obDl2
  if {[info commands $pobj] eq {}} {
    # at first start, there are no apave objects bound to the main window of alited
    # -> create an independent one to be deleted afterwards
    set pobj alitedObjToDel
    ::apave::APaveInput create $pobj
  }
  set res [$pobj input {} $al(MC,chini1) \
    [list \
      diR1 [list $al(MC,chini3) {} [list -title $al(MC,chini3) -w 50 \
        -values $configs -clearcom {alited::main::ClearCbx %w ::alited::ini::configs}]] \
        "{$::alited::CONFIGDIR}" \
    ] -head $head -help alited::ini::HelpConfiguration -resizable no]
  catch {alitedObjToDel destroy}
  lassign $res ok confdir
  if {$ok} {
    set confdir [file normalize [string trim $confdir]]
    if {$confdir eq {}} {
      set ok no
    } else {
      set ::alited::CONFIGDIR $confdir
      if {[set i [::apave::lsearchFile $configs $confdir]]>-1} {
        set configs [lreplace $configs $i $i]
      }
      set ::alited::CONFIGS [linsert $configs 0 $confdir]
    }
  }
  return $ok
}
#_______________________

proc ini::HelpConfiguration {} {
  # Shows a help on Configurations dialogue.

  alited::Help [apave::dlgPath]
}
# ______________________ Initializing alited app ______________________ #

proc ini::CheckIni {} {
  # Checks if the configuration directory exists and if not asks for it.

  namespace upvar ::alited al al
  if {[file exists $::alited::INIDIR] && [file exists $::alited::PRJDIR]} {
    return
  }
  InitGUI
  catch {destroy .tex}
  if {![GetConfiguration]} exit
  ::alited::main_user_dirs
  GetUserDirs yes
  CreateUserDirs
  set al(ALEversion) [AlitedVersion]
}
#_______________________

proc ini::GetUserDirs {{initmnu no}} {
  # Gets names of user directories for settings.
  #  initmnu - yes, if called to initialize mnu dir

  namespace upvar ::alited al al
  ::alited::main_user_dirs
  if {$al(prjroot) eq {}} {
    set ::alited::BAKDIR [file join $::alited::USERDIR .bak]
  } else {
    set ::alited::BAKDIR [file join $al(prjroot) .bak]
  }
  if {![file exists $::alited::BAKDIR]} {
    catch {file mkdir $::alited::BAKDIR}
  }
  set mnudir [file join $::alited::USERDIR e_menu menus]
  if {$initmnu && ![file exists $mnudir]} {
    set al(EM,mnudir) $mnudir  ;# to have e_menu in each config dir
  }
  set al(INI) [file join $::alited::INIDIR alited.ini]
}
#_______________________

proc ini::CreateUserDirs {} {
  # Creates main directories for settings.

  namespace upvar ::alited al al USERDIR USERDIR INIDIR INIDIR PRJDIR PRJDIR MNUDIR MNUDIR DATAUSER DATAUSER DATAUSERINIFILE DATAUSERINIFILE PRJEXT PRJEXT
  foreach dir {USERDIR INIDIR PRJDIR} {
    catch {file mkdir [set $dir]}
  }
  if {![file exists $al(INI)]} {
    file copy $DATAUSERINIFILE $al(INI)
    file copy [file join $DATAUSER prj default$PRJEXT] \
      [file join $PRJDIR default$PRJEXT]
    file copy [file join $DATAUSER notes.txt] [file join $USERDIR notes.txt]
    ReadIni
  }
  set emdir [file dirname $al(EM,mnudir)]
  if {![file exists $emdir]} {
    file mkdir $emdir
    file copy $MNUDIR $emdir
    file copy [file join [file dirname $MNUDIR] em_projects] $emdir
  }
}
#_______________________

proc ini::CreateIcon {icon} {
  # Create an icon (of normal and big size).
  #   icon - name of icon

  set img alimg_$icon
  catch {image create photo $img-big -data [::apave::iconData $icon]}
  catch {image create photo $img -data [::apave::iconData $icon small]}
  return $img
}
#_______________________

proc ini::EditSettings {} {
  # Displays the settings file, just to look behind the wall.

  namespace upvar ::alited al al obPav obPav
  $obPav vieweditFile $al(INI) {} -rotext 1 -h 25
}

# ________________________ Main (+ tool bar) _________________________ #

proc ini::InitGUI {} {
  # Initializes GUI.

  namespace upvar ::alited al al
  ::apave::obj basicFontSize $al(FONTSIZE,std)
  if {$al(INI,HUE)} {::apave::obj csToned $al(INI,CS) $al(INI,HUE)}
  ::apave::obj csSet $al(INI,CS) . -doit
  if {$al(INI,HUE)} {::apave::obj csToned $al(INI,CS) $al(INI,HUE) yes}
  set Dark [::apave::obj csDark]
  if {![info exists al(ED,clrCOM)] || ![info exists al(ED,CclrCOM)] || \
  ![info exists al(ED,Dark)] || $al(ED,Dark) != $Dark} {
    alited::pref::Tcl_Default $al(syntaxidx) yes
    alited::pref::C_Default $al(syntaxidx) yes
  }
  set clrnams [::hl_tcl::hl_colorNames]
  set clrvals [list]
  foreach clr $clrnams {
    if {[info exists al(ED,$clr)]} {
      lappend clrvals [set al(ED,$clr)]
    }
  }
  if {[llength $clrvals]==[llength $clrnams]} {
    ::hl_tcl::hl_colors {-AddTags} $Dark {*}$clrvals
  }
  ::apave::obj setShowOption -resizable 0
  if {[::isKDE]} {  ;# esp. for KDE:
    # dialogue windows should be topmost, otherwise KDE hides them at losing focus
    ::apave::obj setShowOption -ontop yes
  }
  lassign [::apave::defaultAttrs spx] opts atrs
  ::apave::defaultAttrs spx $opts "$atrs -justify center -w 9"
}
#_______________________

proc ini::InitFonts {} {
  # Loads main fonts for alited to use as default and mono.

  namespace upvar ::alited al al

  if {$al(FONT) ne {}} {
    catch {
      ::apave::obj basicDefFont [dict get $al(FONT) -family]
    }
    set smallfont $al(FONT)
    catch {
      set smallfont [dict set smallfont -size $al(FONTSIZE,small)]
    }
    foreach font {TkDefaultFont TkMenuFont TkHeadingFont TkCaptionFont} {
      font configure $font {*}$al(FONT)
    }
    foreach font {TkSmallCaptionFont TkIconFont TkTooltipFont} {
      font configure $font {*}$smallfont
    }
    ::baltip::configure -font $smallfont
  }
  set statusfont [::apave::obj basicSmallFont]
  catch {
    set statusfont [dict set statusfont -size $al(FONTSIZE,small)]
  }
  ::apave::obj basicSmallFont $statusfont
  ::apave::obj basicFontSize $al(FONTSIZE,std)
  set gl [file join $alited::MSGSDIR $al(LOCAL)]
  if {[catch {glob "$gl.msg"}]} {set al(LOCAL) en}
  if {$al(LOCAL) ni {en {}}} {
    # load localized messages
    msgcat::mcload $alited::MSGSDIR
    msgcat::mclocale $al(LOCAL)
    alited::msgcatMessages
  } else {
    msgcat::mclocale en
  }
}
#_______________________

proc ini::initStyles {} {
  # Initializes widget styles for alited.

  namespace upvar ::alited al al
  ::apave::initStyles
  ::apave::initStylesFS -size $al(FONTSIZE,small)
}
#_______________________

proc ini::TipToolHotkeys {} {
  # Adds hotkeys to toolbar tips.

  namespace upvar ::alited al al
  append al(MC,icoSaveFile) \n $al(acc_0)
  append al(MC,icorun)      \n $al(acc_3)
  append al(MC,icoe_menu)   \n $al(acc_2)
}
#_______________________

proc ini::_init {} {
  # Initializes alited app.

  namespace upvar ::alited al al \
    obPav obPav obDlg obDlg obDl2 obDl2 obDl3 obDl3 obFND obFND obFN2 obFN2 obCHK obCHK
  namespace upvar ::alited::pref em_Num em_Num \
    em_sep em_sep em_ico em_ico em_inf em_inf em_mnu em_mnu

  ::apave::initBaltip
  ::apave::obj chooserGeomVars ::alited::DirGeometry ::alited::FilGeometry
  GetUserDirs
  CheckIni
  ReadIni
  InitFonts

  lassign [::apave::InitTheme $al(THEME) $::alited::LIBDIR] theme lbd
  ::apave::initWM -cursorwidth $al(CURSORWIDTH) -theme $theme -labelborder $lbd
  ::apave::iconImage -init $al(INI,ICONS) yes
  set ::apave::MC_NS ::alited
  InitGUI
  GetUserDirs

  # get hotkeys
  alited::pref::IniKeys
  alited::pref::RegisterKeys
  alited::pref::KeyAccelerators

  # create main apave objects
  ::apave::APaveInput create $obPav $al(WIN)
  foreach ob [::alited::ListPaved] {
    ::apave::APaveInput create [set $ob] $al(WIN)
  }

  # here, the order of icons defines their order in the toolbar
  set listIcons [::apave::iconImage]
  # the below icons' order defines their order in the toolbar
  TipToolHotkeys
  foreach {icon} {none gulls heart add change delete up down paste plus minus retry \
  misc previous previous2 next next2 folder file OpenFile SaveFile saveall categories \
  undo redo replace ok color date help run e_menu other trash actions paste} {
    set img [CreateIcon $icon]
    if {$icon in {file OpenFile SaveFile saveall categories undo redo replace \
    ok color date help run e_menu other}} {
      if {$icon eq {run}} {
        set com "-command alited::tool::TooltipRun"
      } else {
        set com ""
      }
      append al(atools) " $img-big \{{} -tip {$alited::al(MC,ico$icon)@@ -under 4 $com} \
        -popup {alited::tool::PopupBar %X %Y} "
      switch $icon {
        file {
          append al(atools) "-com alited::file::NewFile\}"
        }
        OpenFile {
          append al(atools) "-com alited::file::OpenFile\} sev 6"
        }
        SaveFile {
          append al(atools) "-com alited::file::SaveFile -state disabled\}"
        }
        saveall {
          append al(atools) "-com alited::file::SaveAll -state disabled\} sev 6"
        }
        categories {
          append al(atools) "-com alited::project::_run\} sev 6"
        }
        undo {
          append al(atools) "-com alited::tool::Undo -state disabled\}"
        }
        redo {
          append al(atools) "-com alited::tool::Redo -state disabled\} sev 6"
        }
        replace {
          append al(atools) "-com alited::find::_run\}"
        }
        ok {
          append al(atools) "-com alited::CheckRun\}"
        }
        color {
          append al(atools) "-com alited::tool::ColorPicker\}"
        }
        date {
          append al(atools) "-com alited::tool::DatePicker\}"
        }
        help {
          append al(atools) "-com alited::tool::Help\} sev 6"
        }
        run {
          append al(atools) "-com alited::tool::_run\}"
        }
        e_menu {
          image create photo $img-big -data $alited::img::_AL_IMG(e_menu)
          append al(atools) "-com {alited::tool::e_menu o=0}\}"
        }
        other {
          append al(atools) "-command alited::tool::tkcon\}"
        }
      }
    }
  }
  set limgs [list]
  for {set i [set was 0]} {$i<$em_Num} {incr i} {
    if {[info exists em_ico($i)] && ($em_ico($i) ni {none {}} || $em_sep($i))} {
      if {[incr was]==1 && !$em_sep($i)} {
        append al(atools) { sev 6}
      }
      if {$em_sep($i)} {
        append al(atools) { sev 6}
      } else {
        set tico [alited::TextIcon $em_ico($i) in]
        if {[string length $tico]==1 || ![string is alpha $tico]} {
          set img _$tico
          set txt "-t $em_ico($i)"
        } else {
          set img [CreateIcon $tico]-big
          set txt {}
        }
        if {[lsearch -exact $limgs $img]>-1} {
          set msg [msgcat::mc {ERROR! Duplicate tool icon: }]
          append msg [string map {-big {}} [lindex [split $img _] end]]
          after idle [list alited::Message $msg 4]
          continue
        }
        lappend limgs $img
        set tip $em_mnu($i)
        append al(atools) " $img \{{} -tip {$tip@@ -under 4 \
          -command {alited::ini::ToolbarTip $i}} $txt \
          -popup {alited::tool::PopupBar %X %Y} \
          -com {[alited::tool::EM_command $i]}\}"
      }
    }
  }
  for {set i 0} {$i<8} {incr i} {
    image create photo alimg_pro$i -data [set alited::img::_AL_IMG($i)]
  }
  image create photo alimg_tclfile -data [set alited::img::_AL_IMG(Tcl)]
  image create photo alimg_kbd -data [set alited::img::_AL_IMG(kbd)]
  # styles & fonts used in "small" dialogues
  initStyles
  lassign [::apave::obj create_FontsType small -size $al(FONTSIZE,small)] \
     al(FONT,defsmall) al(FONT,monosmall)
  lassign [alited::FgFgBold] -> al(FG,Bold)
}
#_______________________

proc ini::ToolbarTip {i} {
  # Gets a toolbar button's tip, mapping %f / %D to a current file / directory.
  #   i - index of e_menu item

  set maplist [alited::menu::MapRunItems [alited::bar::FileName]]
  return [string map $maplist $::alited::pref::em_mnu($i)]
}
# _________________________________ EOF _________________________________ #
