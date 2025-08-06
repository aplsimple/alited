###########################################################
# Name:    ini.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/30/2021
# Brief:   Handles settings (of alited and projects).
# License: MIT.
###########################################################

# ___________ Default settings of alited app ____________ #

namespace eval ::alited {

  set al(MAXFILES) 5000     ;# maximum size of file tree (max size of project)
  set al(ED,sp1) 0          ;# -spacing1 option of texts
  set al(ED,sp2) 1          ;# -spacing2 option of texts
  set al(ED,sp3) 1          ;# -spacing3 option of texts
  set al(ED,TclKeyWords) {} ;# user's key words for Tcl
  set al(ED,CKeyWords) {}   ;# user's key words for C/C++
  set al(ED,gutterwidth) 5  ;# gutter's windth in chars
  set al(ED,guttershift) 3  ;# space between gutter and text
  set al(ED,btsbd) 0        ;# borderwidth for bartabs
  set al(ED,BlinkCurs) 1    ;# blinking cursor
  set al(TREE,isunits) yes  ;# current mode of tree: units/files
  set al(TREE,units) no     ;# flag "is a unit tree created"
  set al(TREE,files) no     ;# flag "is a file tree created"
  set al(TREE,cw0) 200      ;# tree column #0 width
  set al(TREE,cw1) 70       ;# tree column #1 width
  set al(TREE,showinfo) 0   ;# flag "show info on a file in tips"
  set al(expandUT) [dict create] ;# current mode of unit tree: expanded or not
  set al(expandFT) 0        ;# current mode of file tree: expanded or not
  set al(FONT) {}           ;# default font's options
  set al(FONT,txt)          TkFixedFont
  set al(FONT,defsmall)     TkDefaultFont
  set al(FONTSIZE,small) 9  ;# small font size
  set al(FONTSIZE,std) 10   ;# middle font size
  set al(THEME) default     ;# ttk theme
  set al(defCS) [::apave::DefaultCS]
  set al(INI,CS) $al(defCS) ;# color scheme
  set al(INI,HUE) 0         ;# tint of color scheme
  set al(INI,ICONS) {middle icons} ;# sets tollbar icons' size as middle
  set al(INI,save_onselect) no ;# do saving alited configuration at tab selection
  set al(INI,save_onadd) no    ;# do saving alited configuration at tab adding
  set al(INI,save_onmove) no   ;# do saving alited configuration at tab  moving
  set al(INI,save_onclose) no  ;# do saving alited configuration at tab closing
  set al(INI,save_onsave) yes  ;# do saving alited configuration at file saving
  set al(INI,maxfind) 32       ;# size for comboboxes of "Find/Replace" dialogue
  set al(INI,barlablen) 16     ;# width of tab labels in chars
  set al(INI,bartiplen) 32     ;# size of tips for tab bar's arrows & of tabs submenu
  set al(INI,confirmexit) 1    ;# flag "confirm exiting alited"
  set al(INI,belltoll) 1       ;# flag "bell at warnings"
  set al(INI,LINES1) 10        ;# number of initial "untouched" lines (to ban moves in it)
  set al(INI,isfindrepl) 0     ;# Find/Replace shown at starting
  set al(PTP,text) {}          ;# project template's text
  set al(PTP,name) {}          ;# current template name
  set al(PTP,names) [list]     ;# all template names
  set al(PTP,list) [list]      ;# list of pairs "name contents"
  set al(moveall) 1            ;# "move all" of color chooser
  set al(tonemoves) 1          ;# "tone moves" of color chooser
  set al(checkgeo) {}          ;# geometry of "Check Tcl" window
  set al(cmdNum) 6             ;# number of commands on Commands tab

  # flag "use special RE for leafs of unit tree"
  set al(INI,LEAF) 0

  # RE for branches of unit tree ( # _ lev 1 _..)
  set al(RE,branchDEF) {^\s*(#+) [_]+\s+([^_]+[^[:blank:]]*)\s+[_]+ (#+)$}
  set al(RE,branch) $al(RE,branchDEF)

  # special RE for leafs
  set al(RE,leafDEF) {^\s*#\s*=+\s*([^=\s]+)\s*=+$}
  set al(RE,leaf) $al(RE,leafDEF)

  # RE for Tcl leaf units
  set al(RE,procDEF) {^\s*(((proc|method|test)\s+([^[:blank:]]+))|((constructor|destructor)\s+))}
  set al(RE,proc) $al(RE,procDEF)

  # RE to check for leaf units (# _  / # _ abc)
  set al(RE,leaf2DEF) {^\s*(#+) [_]+}
  set al(RE,leaf2) $al(RE,leaf2DEF)

  # RE to check for Tcl leaf units (proc abc {}...)
  set al(RE,proc2DEF) {^\s*(proc|method|test|constructor|destructor)\s+}
  set al(RE,proc2) $al(RE,proc2DEF)

  # list of current favorite units
  set al(FAV,current) [list]

  # list of current visited units
  set al(FAV,visited) [list]

  # flag "is now favorites (not last visited)"
  set al(FAV,IsFavor) 0

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
  set al(TPL,%a) {#   %a - \n}

  # key bindings
  set al(KEYS,bind) [list]

  # e_menu settings and arguments
  set al(EM,geometry) {}
  set al(EM,save) 2
  set al(EM,PD=) [file join $::alited::CONFIGDIRSTD alited e_menu em_projects]
  set al(EM,Tcl) {}
  set al(EM,TclList) [list]
  set al(EM,h=) [file join $::alited::HOMEDIR DOC www.tcl.tk man tcl8.6]
  set al(EM,tt=) x-terminal-emulator
  set al(EM,tt=List) "$al(EM,tt=)\txfce4-terminal\tlxterminal --geometry=220x55\tgnome-terminal --wait\tkonsole\tqterminal\tEterm\tmlterm\txgterm"
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
  set al(chosencolor) green

  # subdirectory of project to backup files at modifications
  # and maximum of backups
  set al(BACKUP) .bak
  set al(MAXBACKUP) 1

  # enables/disables call of LastVisited in tree::NewSelection
  set al(dolastvisited) yes

  # current text's wrap words mode
  set al(wrapwords) 1

  # cursor's width & color
  set al(CURSORWIDTH) 2
  set al(CURSORCOLOR) {}

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
  set al(comForceCh) 1
  set al(comForceLs) {}
  set al(runGeometry) {}

  # flags of tip show
  set al(TIPS,Tree) 1
  set al(TIPS,TreeFavor) 1
  set al(TIPS,Projects) 1
  set al(TIPS,Preferences) 1
  set al(TIPS,Templates) 1
  set al(TIPS,SavedFavorites) 1
  set al(TIPS,Marks) 1

  # flag "sorted file list"
  set al(sortList) 0

  # modes to sort bartabs
  set al(incdecName) increasing
  set al(incdecDate) decreasing
  set al(incdecSize) decreasing
  set al(incdecExtn) increasing

  # mode "place tabs to the beginning of bar"
  set al(lifo) 1

  # options for macro play
  set al(activemacro) {}  ;# active macro's name
  set al(macroext) {.alm} ;# macro extension
  set al(macromouse) no   ;# use mouse actions

  # flag "Paver tool is auto-updated"
  set al(paverauto) 0

  # rectangular selection
  set al(rectSel) 0           ;# flag "it was started"
  set al(rectSel,TID) {}      ;# tab ID where it was started
  set al(rectSel,text) [list] ;# selected rectangle

  # "TODO ahead" setting of Projects
  set al(todoahead) 0

  # Handler of "Run as Is"
  set al(runAsIs) {alited::tool::RunFile; break}

  # Commenting mode: 0 - TODO, 1 - Classic, 2 - Sticky
  set al(commentmode) 0

  # options for Edit/Formats submenu
  set al(format_separ1DEF) \
    {# == N (70)=============================================================================}
  set al(format_separ2DEF) #_______________________
  set al(format_separ1) $al(format_separ1DEF)
  set al(format_separ2) $al(format_separ2DEF)

  # width of mark bar
  set al(markwidth) 8

  # switch "show week numbers in calendar"
  set al(klndweeks) 0

  # -topmost attribute of Find/Replace dialog
  set al(topFindRepl) [::asKDE]

  # flag "middle font size in detached editor"
  set al(fontdetach) 1

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
  namespace upvar ::alited::pref em_Num em_Num em_NumMax em_NumMax \
    em_ico em_ico em_inf em_inf em_mnu em_mnu
  namespace upvar ::alited::project prjlist prjlist prjinfo prjinfo
  alited::pref::Tkcon_Default
  set prjlist [list]
  set al(TPL,list) [list]
  set al(KEYS,bind) [list]
  set em_i 0
  set fontsize [expr {$al(FONTSIZE,std)+1}]
  set al(FONT,txt) "[obj basicTextFont] -size $fontsize"
  lassign "" ::alited::Pan_wh ::alited::PanL_wh ::alited::PanR_wh \
    ::alited::PanBM_wh ::alited::PanTop_wh ::alited::al(GEOM)
  puts "alited pwd    : [pwd]"
  puts "alited reading: $al(INI)"
  if {$al(ini_file) eq {}} {
    # al(ini_file) may be already filled (see alited.tcl)
    set al(ini_file) [split [readTextFile $::alited::al(INI)] \n]
  }
  set mode ""
  foreach stini $al(ini_file) {
    switch -exact $stini {
      {[Geometry]} - {[Options]} - {[Projects]} - {[Templates]} - {[Keys]} - {[EM]} - {[Tkcon]} - {[Misc]} - {[Formats]} {
        set mode $stini
        continue
      }
    }
    # any line may be potentially bad formed => catch errors
    catch {
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
          {[Formats]}   {ReadIniFormats $nam $val}
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
  set em_Num [expr {min($em_NumMax,[Em_Number $em_i]+3)}]
  while {$em_i < $em_Num} {
    lassign {} em_ico($em_i) em_inf($em_i) em_mnu($em_i)
    incr em_i
  }
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
  if {$al(RE,leaf) eq {}} {set al(RE,leaf) $al(RE,leafDEF)}
  ReadIniPrj
  lassign [::apave::defaultAttrs tex] - atrs
  set pad [expr {$al(CURSORWIDTH) + 2}]
  append atrs " -spacing1 $al(ED,sp1) -spacing2 $al(ED,sp2) -spacing3 $al(ED,sp3) -padx $pad -pady $pad -insertwidth $al(CURSORWIDTH) -bd 0"
  ::apave::defaultAttrs tex "" $atrs
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
  InitXterminal
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
    geomtodolist   {set ::alited::project::geotodolist $val}
    geompref       {set ::alited::pref::geo $val}
    dirgeometry    {set ::alited::DirGeometry $val}
    filgeometry    {set ::alited::FilGeometry $val}
    favgeometry    {set ::alited::favgeometry $val}
    tplgeometry    {set ::alited::tplgeometry $val}
    treecw0        {
      if {[info exists ::alited::al(OLDTHEME)]
      && $::alited::al(OLDTHEME) ne $::alited::al(THEME)} {
        # this adjusts unit tree column #1 to make scroll bar visible
        set val [expr {max(100,$val-20)}]
      }
      set al(TREE,cw0) $val
    }
    treecw1        {set al(TREE,cw1) $val}
    runGeometry    {set al(runGeometry) $val}
    fontdetach     {set al(fontdetach) $val}
    detach*        {
      set id [string range $nam 6 end]
      lassign [alited::file::DetachedInfo $id] pobj
      set $pobj $val
    }
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
      set al(prjfile) [::apave::UnixPath $val]
      set al(prjname) [file tail [file rootname $val]]
    }
    theme         {set al(THEME) $val}
    cs            {set al(INI,CS) $val}
    hue           {set al(INI,HUE) $val}
    local         {set al(LOCAL) $val}
    deffont       {set al(FONT) $val}
    smallfontsize {set al(FONTSIZE,small) $val}
    stdfontsize   {set al(FONTSIZE,std) $val}
    txtfont       {set al(FONT,txt) $val; obj basicTextFont $val}
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
    TclExts       {
      set al(TclExts) [split $val]
      foreach e $al(TclExtsDef) {
        if {$e ni $al(TclExts)} {lappend al(TclExts) $e}
      }
    }
    ClangExts     {set al(ClangExts) $val}
    TextExts      {set al(TextExts) $val}
    REbranch      {set al(RE,branch) $val}
    REproc        {set al(RE,proc) $val}
    REproc2       {set al(RE,proc2) $val}
    REleaf        {set al(RE,leaf) $val}
    REleaf2       {set al(RE,leaf2) $val}
    UseLeaf       {set al(INI,LEAF) [string is true -strict $val]}
    Lines1        {set al(INI,LINES1) $val}
    RecentFiles   {set al(INI,RECENTFILES) $val}
    MaxLast       {set al(FAV,MAXLAST) $val}
    MaxFiles      {set al(MAXFILES) $val}
    barlablen     {set al(INI,barlablen) $val}
    bartiplen     {set al(INI,bartiplen) $val}
    isfindrepl    {set al(INI,isfindrepl) $val}
    prjtpls       {set al(PTP,list) [::alited::ProcEOL $val in]}
    backup        {
      if {$val ne {.bak}} {set val {}}
      set al(BACKUP) $val
    }
    maxbackup     {set al(MAXBACKUP) $val}
    gutterwidth   {set al(ED,gutterwidth) $val}
    guttershift   {set al(ED,guttershift) $val}
    btsbd         {set al(ED,btsbd) $val}
    BlinkCurs     {set al(ED,BlinkCurs) $val}
    ClrCurs       {set al(CURSORCOLOR) $val}
    cursorwidth   {set al(CURSORWIDTH) $val}
    prjdefault    {set al(PRJDEFAULT) $val}
    DEFAULT,*     {set al($nam) $val}
    findunit      {set al(findunitvals) $val}
    afterstart    {set al(afterstart) $val}
    ALEversion    {set al(ALEversion) $val}
    todoahead     {set al(todoahead) $val}
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
    foreach n {%d %t %u %U %m %w} {
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
  namespace upvar ::alited::pref em_NumMax em_NumMax \
    em_ico em_ico em_inf em_inf em_mnu em_mnu
  upvar $emiName em_i
  switch -exact $nam {
    emPD       {set al(EM,PD=) [::apave::UnixPath $val]}
    emTcl      {
      set val [::apave::UnixPath $val]
      if {[string first { } $val]>0} {
        tk_messageBox -title Warning -icon warning -message \
          "The path to Tcl executable\n\n\"$val\"\n\ncontains spaces.\n \
          \nThis path doesn't fit alited. Only 'non-space' ones do.\n \
          \n==> Change this setting:\nPreferences/Tools/tclsh..."
      } else {
        set al(EM,Tcl) $val
      }
    }
    emTclList  {
      set al(EM,TclList) {}
      foreach t [split [string trim $val] \t] {
        if {[string trim $t] ne {}} {
          append al(EM,TclList) \t [::apave::UnixPath $t]
        }
      }
    }
    em_run {
      if {$em_i < $em_NumMax} {
        lassign [split $val \t] v1 v2 v3
        if {$v1 eq "1" && $v2 eq {}} {
          lassign {} em_ico($em_i) em_inf($em_i)  ;# it's a separator in alited v1.6.1
        } elseif {$v1 eq "0" && $v3 ne {}} {
          set em_ico($em_i) $v2
          set em_inf($em_i) $v3  ;# it's an item in alited v1.6.1
        } else {
          set em_ico($em_i) $v1 ;# it's a separator / item in v1.6.2
          set em_inf($em_i) $v2
        }
        set em_mnu($em_i) [::apave::NormalizeName [lindex $em_inf($em_i) end]]
        incr em_i
      }
    }
  }
  if {[string trim $val] eq {}} return  ;# options below should be non-empty
  switch -exact $nam {
    emgeometry {set al(EM,geometry) $val}
    emsave     {  ;# messy for compatibility:
      switch $val [list \
        3 - {} {set al(EM,save) 3} \
        2 - Current - {Current file} - $al(MC,currfile) {set al(EM,save) 2} \
        default {set al(EM,save) 1} \
      ]
    }
    emtt       {set al(EM,tt=) $val}
    emttList   {
      foreach tt [split $al(EM,tt=List) \t] {
        if {[string first \t$tt \t$val]<0} {
          append val \t$tt  ;# let default items be in the list
        }
      }
      set al(EM,tt=List) $val
    }
    emwt       {set al(EM,wt=) $val}
    emmenu     {set al(EM,mnu) [::apave::UnixPath $val]}
    emmenudir  {
      set val [::apave::UnixPath $val]
      if {[file exists $val]} {set al(EM,mnudir) $val}
    }
    emcs       {set al(EM,CS) $val}
    emowncs    {set al(EM,ownCS) $val}
    emdiff     {set al(EM,DiffTool) $val}
    emh        {set al(EM,h=) [::apave::UnixPath $val]}
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
    HelpedMe {set ::alited::helpedMe $val}
    listSBL - checkgeo - tonemoves - moveall - chosencolor \
    - sortList - activemacro - commentmode - format_separ1 - format_separ2 \
    - TIPS,* - MNUGEO,* - markwidth - klndweeks - topFindRepl \
    - DockGeo - DockLayout - ApaveLayout {
      set al($nam) $val
    }

    tplilast {set ::alited::unit::ilast $val}
    incdec {lassign $val al(incdecName) al(incdecDate) al(incdecSize) al(incdecExtn)}
    blifo {set al(lifo) [string is true $val]}
    InRE2 {set ::alited::find::InRE2 [::alited::ProcEOL $val in]}
    ExRE2 {set ::alited::find::ExRE2 [::alited::ProcEOL $val in]}
    chInRE2 {set ::alited::find::chInRE2 [string is true $val]}
    chExRE2 {set ::alited::find::chExRE2 [string is true $val]}
    geoRE2 {set ::alited::find::geoRE2 $val}
  }
}
#_______________________

proc ini::ReadIniFormats {nam val} {
  # Gets pluginable formatters of alited.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  switch -exact -- $nam {
    pluginable {
      lassign $val fullformname ev
      set fform [alited::edit::FormatterName $fullformname]
      set al(FORMATS,$fform,$ev) $val
    }
  }
}
#_______________________

proc ini::Em_Number {em_N} {
  # Gets a real number of e_menu items counting non-empty ones only.
  #   em_N - current number of e_menu items

  namespace upvar ::alited::pref em_inf em_inf
  for {set i $em_N} {$i>0} {} {
    set em_N $i
    incr i -1
    if {[info exists em_inf($i)] && $em_inf($i) ne {}} {
      break
    }
  }
  return $em_N
}
#_______________________

proc ini::InitXterminal {} {
  # Gets Linux terminal called by x-terminal-emulator, saves the result to al(EM,tt).
  # See also: tool::EM_Options

  namespace upvar ::alited al al
  set al(EM,tt) $al(EM,tt=)
  set tty [lindex [split $al(EM,tt)] 0]
  set xte x-terminal-emulator
  if {[::isunix] && [file tail $tty] eq $xte} {
    if {[auto_execok $tty] eq {} || [catch {set man [exec man $xte]}]} {
      # no x-terminal-emulator command ?
      return
    }
    switch -glob $man {
      GNOME-TERMINAL* {set tt {gnome-terminal --wait}}
      XFCE4-TERMINAL* {set tt xfce4-terminal}
      default {return}
    }
    set al(EM,tt) $tt[string range $al(EM,tt=) [string length $tty] end]
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
  set al(expandFT) 0
  set al(FAV,current) [list]
  set al(FAV,visited) [list]
  alited::favor::InitFavorites [list]
  alited::favor_ls::GetIni {}
  if {![file exists $al(prjfile)]} {
    set al(prjfile) [file join $::alited::PRJDIR default$PRJEXT]
  }
  set al(prjname) [file tail [file rootname $al(prjfile)]]
  puts "alited project: $al(prjfile)"
  if {[catch {
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
      # any line may be potentially bad formed => catch errors
      catch {
        switch -exact $mode {
          {[Tabs]} {ReadPrjTabs $nam $val}
          {[Options]} {ReadPrjOptions $nam $val}
          {[Favorites]} {ReadPrjFavorites $nam $val}
          {[Misc]} {ReadPrjMisc $nam $val}
        }
      }
    }
  } e]} then {
    puts "Not open: $al(prjfile)\n$e"
    set al(prjname) {}
    set al(prjfile) {}
    set al(prjroot) {}
  }
  if {$al(prjroot) eq {} && $al(prjname) eq {default}} {set al(prjroot) $::alited::DIR}
  alited::favor::InitFavorites $al(FAV,current)
  catch {close $chan}
  catch {cd $al(prjroot)}
  if {![string is digit -strict $al(curtab)] || \
  $al(curtab)<0 || $al(curtab)>=[llength $al(tabs)]} {
    set al(curtab) 0
  }
  ::apave::textEOL $al(prjEOL)
  alited::SaveRunOptions
}
#_______________________

proc ini::ReadPrjTabs {nam val} {
  # Gets tabs of project.
  #   nam - name of option
  #   val - value of option

  namespace upvar ::alited al al
  if {[string trim $val] ne {}} {
    switch -exact -- $nam {
      tab {
        set fname [lindex $val 0]
        if {[lsearch -exact -index 0 $al(tabs) $fname]<0} {
          lappend al(tabs) $val
          lassign [split $val \t] - - isexp
          if {[string is boolean -strict $isexp]} {
            dict set al(expandUT) $fname $isexp
          }
        }
      }
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
        array set data [::alited::ProcEOL $val in]
        set ::alited::find::data(vals1) $data(vals1)
        set ::alited::find::data(vals2) $data(vals2)
      }
    }
    comforce   {set al(comForce) $val}
    comforcech {set al(comForceCh) $val}
    comforcels {set al(comForceLs) $val}
    expandFT   {set al(expandFT) $val}
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
  namespace upvar ::alited::pref em_Num em_Num em_ico em_ico em_inf em_inf
  namespace upvar ::alited::project prjlist prjlist prjinfo prjinfo
  puts "alited storing: $al(INI)"
  set chan [open $::alited::al(INI) w]
  chan configure $chan -buffering full -buffersize 131072
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
  puts $chan "TclExts=$al(TclExts)"
  puts $chan "ClangExts=$al(ClangExts)"
  puts $chan "TextExts=$al(TextExts)"
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
  puts $chan "isfindrepl=$al(INI,isfindrepl)"
  puts $chan prjtpls=[::alited::ProcEOL $al(PTP,list) out]
  puts $chan "backup=$al(BACKUP)"
  puts $chan "maxbackup=$al(MAXBACKUP)"
  puts $chan "gutterwidth=$al(ED,gutterwidth)"
  puts $chan "guttershift=$al(ED,guttershift)"
  puts $chan "btsbd=$al(ED,btsbd)"
  puts $chan "BlinkCurs=$al(ED,BlinkCurs)"
  puts $chan "ClrCurs=$al(CURSORCOLOR)"
  puts $chan "prjdefault=$al(PRJDEFAULT)"
  foreach k [array names al DEFAULT,*] {
    puts $chan "$k=$al($k)"
  }
  puts $chan "findunit=$al(findunitvals)"
  puts $chan "afterstart=$al(afterstart)"
  puts $chan "ALEversion=[AlitedVersion]"
  puts $chan "todoahead=$al(todoahead)"

  puts $chan {}
  puts $chan {[Templates]}
  foreach t $al(TPL,list) {
    puts $chan "tpl=$t"
  }
  foreach n {%d %t %u %U %m %w} {
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
  set em_N [Em_Number $em_Num]
  for {set i 0} {$i<$em_N} {incr i} {
    if {[info exists em_inf($i)]} {
      set em_run em_run=
      append em_run [alited::TextIcon $em_ico($i) in] \t $em_inf($i)
      puts $chan $em_run
    }
  }
  puts $chan {}
  puts $chan {[Tkcon]}
  foreach k [array names al tkcon,*] {
    puts $chan "[string range $k 6 end]=$al($k)"
  }
  # save misc settings
  puts $chan {}
  puts $chan {[Misc]}
  puts $chan "isfavor=$al(FAV,IsFavor)"
  puts $chan "chosencolor=$al(chosencolor)"
  puts $chan "showinfo=$al(TREE,showinfo)"
  set al(listSBL) [::alited::ProcEOL $al(listSBL) out]
  puts $chan "listSBL=$al(listSBL)"
  puts $chan "moveall=$al(moveall)"
  puts $chan "tonemoves=$al(tonemoves)"
  puts $chan "checkgeo=$al(checkgeo)"
  puts $chan "HelpedMe=$::alited::helpedMe"
  foreach k [array names al -glob TIPS,*] {
    puts $chan "$k=$al($k)"
  }
  foreach k [array names al -glob MNUGEO,*] {
    puts $chan "$k=$al($k)"
  }
  puts $chan "sortList=$al(sortList)"
  puts $chan "tplilast=$::alited::unit::ilast"
  puts $chan "incdec=$al(incdecName) $al(incdecDate) $al(incdecSize) $al(incdecExtn)"
  puts $chan "blifo=$al(lifo)"
  puts $chan "activemacro=$al(activemacro)"
  puts $chan InRE2=[::alited::ProcEOL $::alited::find::InRE2 out]
  puts $chan ExRE2=[::alited::ProcEOL $::alited::find::ExRE2 out]
  puts $chan "chInRE2=$::alited::find::chInRE2"
  puts $chan "chExRE2=$::alited::find::chExRE2"
  puts $chan "geoRE2=$::alited::find::geoRE2"
  puts $chan "commentmode=$al(commentmode)"
  puts $chan "format_separ1=$al(format_separ1)"
  puts $chan "format_separ2=$al(format_separ2)"
  puts $chan "markwidth=$al(markwidth)"
  puts $chan "klndweeks=$al(klndweeks)"
  puts $chan "topFindRepl=$al(topFindRepl)"
  puts $chan "DockGeo=$al(DockGeo)"
  puts $chan "DockLayout=$al(DockLayout)"
  puts $chan "ApaveLayout=$al(ApaveLayout)"
  # save the Edit/Formats pluginables
  puts $chan {}
  puts $chan {[Formats]}
  foreach n [array names al -glob FORMATS,*] {
    puts $chan "pluginable=$al($n)"
  }
  # save the geometry options
  puts $chan {}
  puts $chan {[Geometry]}
  puts $chan "runGeometry=$al(runGeometry)"
  puts $chan "geomfind=$::alited::find::geo"
  puts $chan "geomfind2=$::alited::find::geo2"
  puts $chan "geomproject=$::alited::project::geo"
  puts $chan "geomtodolist=$::alited::project::geotodolist"
  puts $chan "geompref=$::alited::pref::geo"
  puts $chan "dirgeometry=$::alited::DirGeometry"
  puts $chan "filgeometry=$::alited::FilGeometry"
  puts $chan "favgeometry=$::alited::favgeometry"
  puts $chan "tplgeometry=$::alited::tplgeometry"
  set wtree [$obPav Tree]
  set al(TREE,cw0) [$wtree column #0 -width]
  set al(TREE,cw1) [$wtree column #1 -width]
  puts $chan "treecw0=$al(TREE,cw0)"
  puts $chan "treecw1=$al(TREE,cw1)"
  foreach v {Pan PanL PanR PanBM PanTop} {
    if {[info exists al(width$v)]} {
      set w $al(width$v)
    } else {
      set w [winfo geometry [$obPav $v]]
    }
    puts $chan $v=$w
  }
  puts $chan "GEOM=[wm geometry $al(WIN)]"
  foreach id {1 2 3 4 5 6 7 8} {
    lassign [alited::file::DetachedInfo $id] pobj win
    if {[info exists $pobj]} {
      if {[winfo exists $win]} {
        set geo [wm geometry $win]
      } else {
        set geo [set $pobj]
      }
      puts $chan "detach$id=$geo"
    } else {
      break
    }
  }
  puts $chan "fontdetach=$al(fontdetach)"
  close $chan
  SaveIniPrj $newproject
  SaveIniGlob
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
  chan configure $chan -buffering full -buffersize 262144
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
      # save the current cursor position (fit to all files)
      append tab \t $pos \t [alited::tree::IsExpandUT $tab]
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
    puts $chan datafind=[::alited::ProcEOL [array get ::alited::find::data] out]
    puts $chan comforce=$al(comForce)
    puts $chan comforcech=$al(comForceCh)
    puts $chan comforcels=$al(comForceLs)
    puts $chan expandFT=$al(expandFT)
  }
  puts \n
  close $chan
}
#_______________________

proc ini::SaveIniGlob {} {
  # Save 3 lines of global configuration of alited:
  # current .ini file, current project's path, list of config dirs

  namespace upvar ::alited al al
  set cont [file dirname $al(INI)]\n[file dirname $al(prjfile)]\n$::alited::CONFIGS
  writeTextFile $::alited::USERLASTINI cont
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
  obj vieweditFile [file join $DATADIR to-update.txt] {} -rotext 1 -h 25
}
#_______________________

proc ini::UpdateTemplates {inideffile} {
  # Updates templates.
  #   inideffile - ini file name of default templates

  set tplmode 0
  # read new templates: from [Templates] to [Keys]
  foreach stini [split [readTextFile $inideffile {} 1] \n] {
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
  set head "\n [msgcat::mc {Some things have been changed in alited %v.}] "
  set head [string map [list %v v[AlitedVersion]] $head]
  set date _[clock format [clock seconds] -format %Y-%m-%d]
  set al(_updDirMnu_) [file normalize $al(EM,mnudir)$date]
  set inidir [file dirname $al(INI)]
  set inifile [file tail $al(INI)]
  set iniext [file extension $inifile]
  set inifile [file rootname $inifile]
  set al(_updFileIni_) [file normalize [file join $inidir $inifile$date$iniext]]
  set pobj alitedObjToDel
  ::apave::APave create $pobj $al(WIN)
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
  lassign [$pobj input {} $al(MC,updateALE)\ v$al(ALEversion) [list \
    lab1  {{} {} {-t {$::alited::al(MC,updLab1)}}}  {} \
    chb1  {{} {-padx 10} {-t {$::alited::al(MC,updmnu)}}} {$::alited::al(_updmnu_)} \
    chb2  {{} {-padx 10} {-t {$::alited::al(MC,updini)}}} {$::alited::al(_updini_)} \
    seh1  {{} {-pady 10} {}} {} \
    lab2  {{} {} {-t {$::alited::al(MC,updLab2)}}} {} \
    lab3  {{} {-padx 20} {-t {$::alited::al(_updDirMnu_)}}} {} \
    lab4  {{} {-padx 20} {-t {$::alited::al(_updFileIni_)}}} {} \
    {*}$lab5 \
    ] -head $head {*}[obj basicTextFont] -weight bold -buttons "butHELP {View Changes} \
    ::alited::ini::ViewUpdates" -resizable no -focus *YES] \
    res updmnu updini
  catch {$pobj destroy}
  if {!$res} {if {$doit} return else exit}
  if {!$updmnu && !$updini} return
  CreatePossibleNewDirs ;# it's good to do it here
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
      ::apave::APave create $pobj $al(WIN)
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
    ::apave::APave create $pobj
  }
  set res [$pobj input {} $al(MC,chini1) \
    [list \
      diR1 [list $al(MC,chini3) {} [list -title $al(MC,chini3) -w 50 \
        -values $configs -clearcom {alited::main::ClearCbx %w ::alited::ini::configs}]] \
        "{$::alited::CONFIGDIR}" \
    ] -head $head -help alited::ini::Help -resizable no {*}[obj basicTextFont]]
  catch {alitedObjToDel destroy}
  lassign $res ok confdir
  if {$ok} {
    set confdir [file normalize [string trim $confdir]]
    if {$confdir eq {}} {
      set ok no
    } else {
      AddConfigDir $confdir $configs
    }
  }
  return $ok
}
#_______________________

proc ini::AddConfigDir {confdir configs} {
  # Adds a config directory to the list of all config dirs.
  #   confdir - config directory
  #   configs - list of config dirs
  # Returns -1, if *confdir* was absent in *configs*.

  set ::alited::CONFIGDIR $confdir
  if {[set res [::apave::lsearchFile $configs $confdir]]>-1} {
    set configs [lreplace $configs $res $res]
  }
  set ::alited::CONFIGS [linsert $configs 0 $confdir]
  return $res
}

# ______________________ Initializing alited app ______________________ #

proc ini::CheckIni {} {
  # Checks if the configuration directory exists and if not asks for it.

  namespace upvar ::alited al al
  if {![file exists $::alited::INIDIR] || ![file exists $::alited::PRJDIR]} {
    ::apave::initWM -cursorwidth $al(CURSORWIDTH)
    InitGUI
    catch {destroy .tex}
    if {![GetConfiguration]} exit
    ::alited::main_user_dirs
    GetUserDirs yes
    CreateUserDirs
    set al(ALEversion) [AlitedVersion]
  }
  if {[AddConfigDir $::alited::CONFIGDIR $::alited::CONFIGS]<0} {
    SaveIniGlob
  }
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

  namespace upvar ::alited al al USERDIR USERDIR INIDIR INIDIR PRJDIR PRJDIR \
    MNUDIR MNUDIR DATAUSER DATAUSER DATAUSERINIFILE DATAUSERINIFILE PRJEXT PRJEXT
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
  CreatePossibleNewDirs
}
#_______________________

proc ini::CreateMacrosDir {} {
  # Creates macros' directory.

  namespace upvar ::alited al al DATAUSER DATAUSER
  set macrodir [file dirname [alited::edit::MacroFileName -]]
  if {![file exists $macrodir]} {
    file mkdir $macrodir
    foreach f [glob -nocomplain [file join $DATAUSER macro *]] {
      file copy $f $macrodir
    }
  }
}
#_______________________

proc ini::CreatePossibleNewDirs {} {
  # Creates a user directories, possibly new after v1.4.0 (e.g. macro).

  CreateMacrosDir
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
  after idle alited::ini::HighlightFileText
  $obPav vieweditFile $al(INI) {} -rotext 1 -h 25
}
#_______________________

proc ini::HighlightFileText {{wtxt ""} {fname ""} {ro 1} args} {
  # Highlights a text of a file.
  #   wtxt - the text's path
  #   fname - the file name (extension)
  #   ro - flag "readonly text"
  #   args - additional options

  namespace upvar ::alited al al obPav obPav
  set colors [alited::Hl_Colors]
  if {$wtxt eq {}} {set wtxt [$obPav TexM]}
  if {$fname eq {}} {set fname $al(INI)}
  set plcom [alited::HighlightAddon $wtxt $fname $colors]
  ::hl_tcl::hl_init $wtxt -font $al(FONT,txt) -dark [$obPav csDark] \
    -multiline 1 -colors $colors -readonly $ro -plaintext 0 -plaincom $plcom {*}$args
  ::hl_tcl::hl_text $wtxt
  alited::main::SetTabs $wtxt [lindex [alited::main::CalcIndentation] 0]
}

# ________________________ Main (+ tool bar) _________________________ #

proc ini::InitGUI {} {
  # Initializes GUI.

  namespace upvar ::alited al al
  obj basicFontSize $al(FONTSIZE,std)
  if {$al(INI,HUE)} {obj csToned $al(INI,CS) $al(INI,HUE)}
  if {$al(CURSORCOLOR) eq {}} {
    set al(CURSORCOLOR) [lindex [obj csGet $al(INI,CS)] 7]
  }
  obj csSet $al(INI,CS) . -doit -clrcurs $al(CURSORCOLOR)
  if {$al(INI,HUE)} {obj csToned $al(INI,CS) $al(INI,HUE) yes}
  set Dark [obj csDark]
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
    ::hl_tcl::hl_colors -AddTags $Dark {*}$clrvals
  }
  ::hl_tcl::hl_colors . $Dark {*}$clrvals ;# default Tcl syntax colors
  if {!$al(ED,BlinkCurs)} {
    lassign [obj defaultATTRS tex] texopts texattrs
    obj defaultATTRS tex $texopts [dict set texattrs -insertofftime 0]
  }
  obj setShowOption -resizable 0
  if {[::asKDE]} {  ;# esp. for KDE:
    # dialogue windows should be topmost, otherwise KDE hides them at losing focus
    obj setShowOption -ontop yes
  }
  lassign [::apave::defaultAttrs spx] opts atrs
  ::apave::defaultAttrs spx $opts "$atrs -justify center -w 9"
}
#_______________________

proc ini::InitFonts {} {
  # Loads main fonts for alited to use as default and mono.

  namespace upvar ::alited al al MSGSDIR MSGSDIR

  if {$al(FONT) ne {}} {
    obj basicDefFont $al(FONT)
    set smallfont $al(FONT)
    catch {dict set smallfont -size $al(FONTSIZE,small)}
    foreach font {TkDefaultFont TkMenuFont TkHeadingFont TkCaptionFont} {
      font configure $font {*}$al(FONT)
    }
    foreach font {TkSmallCaptionFont TkIconFont TkTooltipFont} {
      font configure $font {*}$smallfont
    }
    ::baltip::configure -font $smallfont
  }
  set statusfont [obj basicSmallFont]
  catch {dict set statusfont -size $al(FONTSIZE,small)}
  obj basicSmallFont $statusfont
  obj basicFontSize $al(FONTSIZE,std)
  set gl [file join $MSGSDIR $al(LOCAL)]
  if {[catch {set flist [glob "$gl.msg"]}] || $flist eq {}} {
    set al(LOCAL) en
  }
  if {$al(LOCAL) ni {en {}}} {
    # load localized messages
    msgcat::mcload $MSGSDIR
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

  namespace upvar ::alited al al obPav obPav obDlg obDlg obDl2 obDl2 \
    obFND obFND obFN2 obFN2 obCHK obCHK obDFW obDFW obRun obRun
  namespace upvar ::alited::pref em_Num em_Num em_ico em_ico em_inf em_inf em_mnu em_mnu

  ::apave::initBaltip
  obj chooserGeomVars ::alited::DirGeometry ::alited::FilGeometry
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
  ::apave::APave create $obPav $al(WIN)
  foreach ob [::alited::ListPaved] {
    ::apave::APave create [set $ob] $al(WIN)
  }

  # here, the order of icons defines their order in the toolbar
  set listIcons [::apave::iconImage]
  # the below icons' order defines their order in the toolbar
  TipToolHotkeys
  foreach {icon} {none gulls heart add change delete up down paste plus minus retry \
  misc previous previous2 next next2 folder file OpenFile SaveFile saveall undo redo \
  box replace ok color date help run e_menu other trash actions paste copy more} {
    set img [CreateIcon $icon]
    if {$icon in {file OpenFile SaveFile saveall box undo redo replace \
    ok color date help run e_menu other}} {
      if {$icon eq {run}} {
        set com "-command alited::tool::TooltipRun"
      } else {
        set com ""
      }
      append al(atools) " $img-big \{{} -tip {$::alited::al(MC,ico$icon)@@ -under 4 $com} \
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
        undo {
          append al(atools) "-com alited::tool::Undo -state disabled\}"
        }
        redo {
          append al(atools) "-com alited::tool::Redo -state disabled\} sev 6"
        }
        box {
          append al(atools) "-com alited::project::_run\} sev 6"
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
          append al(atools) "-com {alited::tool::_run {} {} -doit yes}\}"
        }
        e_menu {
          image create photo $img-big -data $::alited::img::_AL_IMG(e_menu)
          append al(atools) "-com {alited::tool::e_menu o=0}\}"
        }
        other {
          append al(atools) "-com alited::tool::tkcon\}"
        }
      }
    }
  }
  # e_menu items for the toolbar
  set limgs [list]
  set em_N [Em_Number $em_Num]
  for {set i [set was 0]} {$i<$em_N} {incr i} {
    if {[info exists em_ico($i)] && ($em_ico($i) ni {none {}} || $em_inf($i) eq {})} {
      if {[incr was]==1 && $em_inf($i) ne {}} {
        append al(atools) { sev 6}
      }
      if {$em_inf($i) eq {}} {
        append al(atools) { sev 6}
      } else {
        set tico [alited::TextIcon $em_ico($i)]
        if {[string length $tico]==1 || ![string is ascii $tico]} {
          set em_ico($i) $tico
          set img _$i
          set txt "-t $tico"
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
        set com [alited::tool::EM_command $i]
        if {$com ne {}} {
          lappend limgs $img
          set tip $em_mnu($i)
          append al(atools) " $img \{{} -tip {$tip@@ -under 4 \
            -command {alited::ini::ToolbarTip $i}} $txt \
            -popup {alited::tool::PopupBar %X %Y} -com {$com}\}"
        }
      }
    }
  }
  for {set i 0} {$i<8} {incr i} {
    image create photo alimg_pro$i -data [set ::alited::img::_AL_IMG($i)]
  }
  image create photo alimg_tclfile -data [set ::alited::img::_AL_IMG(Tcl)]
  image create photo alimg_kbd -data [set ::alited::img::_AL_IMG(kbd)]
  # styles & fonts used in "small" dialogues
  initStyles
  lassign [obj create_FontsType small -size $al(FONTSIZE,small)] \
     al(FONT,defsmall) al(FONT,monosmall)
  lassign [alited::FgFgBold] -> al(FG,Bold)
}
#_______________________

proc ini::ToolbarTip {i} {
  # Gets a toolbar button's tip, mapping %f / %D to a current file / directory.
  #   i - index of e_menu item

  set maplist [alited::menu::MapRunItems [alited::bar::FileName]]
  string map $maplist $::alited::pref::em_mnu($i)
}
#_______________________

proc ini::Help {} {
  # Shows "Configurations" help.

  alited::Help $::alited::al(WIN)
}

# ________________________ Projects' toolbar _________________________ #

# This branch contains procedures for project::Tab5 (Projects' tab of Files).
# It uses much of the stuff found in this script.

proc ini::ProjectsToolbar {} {
  # Tool bar for Projects (subset of main toolbar).
  # See also: _init, project::Tab5

  namespace upvar ::alited al al
  namespace upvar ::alited::pref em_Num em_Num em_ico em_ico em_inf em_inf em_mnu em_mnu
  set e_menu_icon {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAADFBMVEUAAAAASZL///8Atv8UVAVH
AAAAAXRSTlMAQObYZgAAACZJREFUCNdjYA0NDQAS9ReARN4FKDdr1QQGtvz/E8AsZLHUUAJiAI6+
FtcEguWyAAAAAElFTkSuQmCC}
  set al(atools) [list]
  foreach {icon} {run e_menu other} {
    set img [CreateIcon $icon]
    if {$icon eq {run}} {
      set com "-command alited::tool::TooltipPrjRun"
    } else {
      set com ""
    }
    append al(atools) " $img \{{} -tip {$::alited::al(MC,ico$icon)@@ -under 4 $com} "
    switch $icon {
      run {
        append al(atools) "-com alited::ini::ToolPrjRun\}"
      }
      e_menu {
        image create photo $img -data $e_menu_icon
        append al(atools) "-com alited::ini::ToolPrjEM\}"
      }
      other {
        append al(atools) "-com alited::ini::ToolPrjTkcon\}"
      }
    }
  }
  # e_menu items for the toolbar
  set limgs [list]
  set em_N [Em_Number $em_Num]
  for {set i [set was 0]} {$i<$em_N} {incr i} {
    if {[info exists em_ico($i)] && ($em_ico($i) ni {none {}} || $em_inf($i) eq {})} {
      if {[incr was]==1 && $em_inf($i) ne {}} {
        append al(atools) { sev 6}
      }
      if {$em_inf($i) eq {}} {
        append al(atools) { sev 6}
      } else {
        set tico [alited::TextIcon $em_ico($i)]
        if {[string length $tico]==1 || ![string is ascii $tico]} {
          set em_ico($i) $tico
          set img _$i
          set txt "-t $tico -font {[obj boldTextFont 12]}"
        } else {
          set img [CreateIcon $tico]
          set txt {}
        }
        lappend limgs $img
        set tip $em_mnu($i)
        append al(atools) " $img \{{} -tip {$tip@@ -under 4 \
          -command {alited::ini::ToolPrjTip $i}} $txt \
          -com {alited::ini::ToolPrjCommand $i}\}"
      }
    }
  }
}
#_______________________

proc ini::TooltipPrjRun {} {
  # Gets a tip for "Projects' Run" tool.

  namespace upvar ::alited al al
  set res $al(MC,icorun)
  append res [AddTooltipRun]
}
#_______________________

proc ini::ToolPrjRun {} {
  # Runs current file from toolbar.

  alited::tool::_run 1 {} -doit yes f=[ToolPrjFilename]
}
#_______________________

proc ini::ToolPrjEM {} {
  # Calls e_menu from toolbar.

  alited::tool::e_menu o=0 f=[ToolPrjFilename] d=[ToolPrjDirname]
}
#_______________________

proc ini::ToolPrjTkcon {} {
  # Runs tkcon from toolbar.

  alited::tool::tkcon -dir [ToolPrjDirname]
}
#_______________________

proc ini::ToolPrjFilename {} {
  # Gets file name of current file.

  alited::project::CurrentFile
}
#_______________________

proc ini::ToolPrjDirname {} {
  # Gets dir name of current file.

  file dirname [ToolPrjFilename]
}
#_______________________

proc ini::ToolPrjTip {i} {
  # Gets a toolbar button's tip, mapping %f / %D to a current file / directory.
  #   i - index of e_menu item

  set maplist [alited::menu::MapRunItems [ToolPrjFilename]]
  string map $maplist $::alited::pref::em_mnu($i)
}
#_______________________

proc ini::ToolPrjCommand {im} {
  # Executes project toolbar's command.
  #   im - index in toolbar

  set com [alited::tool::EM_command $im]
  append com " \"f=[ToolPrjFilename]\" \"d=[ToolPrjDirname]\" \"TF=[ToolPrjFilename]\""
  {*}$com
}
#_______________________

proc ini::ToolByKey {nbk com} {
  # Runs a command after its hot key pressing in f5 tab of Projects.
  #   nbk - notebook's path
  #   com - command
  # See also: project::_create

  if {[$nbk select] eq "$nbk.f5"} $com
}

# _________________________________ EOF _________________________________ #
