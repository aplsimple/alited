[OPTIONS]

o=-1
b1=0
b2=3
b3=1
w=30
u=%s
in=1.0
%C if {![info exist ::EMENUP2]} {set ::EMENUP2 "%PN"}
%C if {![info exist ::EMENUDIR1]} {set ::EMENUDIR1 "%PD"}
%C if {![info exist ::EMENUDIR2]} {set ::EMENUDIR2 \
  [file normalize "%PD/../release/[file tail {%PD}]"]}
%C if {![info exist ::EMENUDIR3]} {set ::EMENUDIR3 %H/TMP/alited}
::EMENUOPTS=-r -f
::EMENUMULSTER=1
::EMENUMULSTERDIR=%H/PG/github/mulster
::EMENUMULSTRES1=%H/PG/github/aplsimple.github.io/en/tcl/
::EMENUMULSTRES2=%H/PG/github/aplsimple.github.io/en/tcl/alited
::EMENUMULSTRES3=%H/PG/github/aplsimple.github.io/en/tcl
::EMENUPRINTER=%H/PG/github/aplsimple.github.io/en/tcl/printer/
::EMENURUFFDIR=%H/PG/github/apave pave\n%H/PG/github/hl_tcl\n%H/PG/github/klnd\n%H/PG/github/bartabs\n%H/PG/github/trimmer\n%H/PG/github/mulster\n%H/PG/github/transpops\n%H/PG/github/screenshooter\n%H/PG/github/baltip\n%H/PG/github/aloupe\n%H/PG/github/playtkl
::EMENURUFFIT=%H/PG/github/aplsimple.github.io/en/tcl/bartabs/index.html\n%H/PG/github/aplsimple.github.io/en/tcl/booksum/index.html\n%H/PG/github/aplsimple.github.io/en/tcl/doctest/index.html\n%H/PG/github/aplsimple.github.io/en/tcl/pave/index.html\n%H/PG/github/aplsimple.github.io/en/tcl/alited/index.html
::EMENU7ZCNT=0
::EMENU7ZCOM=zip -r
::EMENU7ZARC=%H/PG/github/apl-github
::EMENU7ZDIR=%H/PG/github/alited/*\n%H/PG/github/aloupe/*\n%H/PG/github/aplsimple.github.io/*\n%H/PG/github/baltip/*\n%H/PG/github/bartabs/*\n%H/PG/github/booksum/*\n%H/PG/github/doctest/*\n%H/PG/github/e_menu/*\n%H/PG/github/hl_tcl/*\n%H/PG/github/mulster/*\n%H/PG/github/apave/*\n%H/PG/github/apave_tests/*\n%H/PG/github/poApps/*\n%H/PG/github/screenshooter/*\n%H/PG/github/tkcc/*\n%H/PG/github/transpops/*\n%H/PG/github/trimmer/*\n%H/PG/github/DEMO/*\n%H/PG/github/klnd/*\n%H/PG/github/ale_themes/*\n%H/PG/github/wiki.tcl-lang.org/*\n%H/PG/github/tclbag/*\n%H/PG/github/osetr/*\n%H/PG/github/playtkl/*
::EMENU7ZSKIP=
::EMENU7ZBAK=/media/apl/KINGSTON/
::EMENU7ZGIT=0
%C set ::EMENU_MULST3 [set ::EMENU_MULST4 ""]
::EMENU_MULST1=%H/TMP/em_mulst.ini
::EMENU_MULST2=%H/TMP/em_mulst.txt
::EMENU_MULST5=regexp--
pos=214.0

[MENU]


ITEM = Trimmer *.tcl
R: cd $::EMENUDIR1
R: %I {} "TRIMMER" { \
   v_ {{} {-pady 4}} {} \
   dir1 {{ Input directory:}} {"$::EMENUDIR1"} \
   dir2 {{Output directory:}} {"$::EMENUDIR2"} \
   ent1 {{         Options:}} {"$::EMENUOPTS"} \
   seh {{} {-pady 3} {}} {} \
   texc {{   Hint:} {} {-h 9 -w 67 -ro 1 -tabnext butOK}} \
   {\n Select input Tcl files' directory and output directory. \
    \n\n Other options are: \
    \n   -r : if set, the input directories are processed recursively; \
    \n   -f : if set, the existing output file(s) will be rewritten; \
    \n   -n : if set, no real changes made, supposed changes shown only. \
    \n The rest of options may set a command to run after trimming. \
   }} -head {\n This removes comments and spaces from Tcl code. \
    \n The trimmer does not touch the input Tcl files.} \
   -weight bold == ::EMENUDIR1 ::EMENUDIR2 ::EMENUOPTS
R: cd $::EMENUDIR1
S: tclsh %H/UTILS/trimmer/trim.tcl \
   -i "$::EMENUDIR1" -o "$::EMENUDIR2" $::EMENUOPTS

ITEM = Ruff! $::EMENUP2 ...
R: cd $::EMENUDIR1
R: %I {} "PROJECT NAME" { \
   v_ {{} {-pady 4}} {} \
   dir1 {{ Project directory:} {} {-w 50 -validate all -validatecommand { \
     set ::EMENUP2 \[::em::get_PD {%P}\]; \
     set ::EMENUMULSTRES2 $::EMENUMULSTRES1\[file tail {%P}\]; \
     return 1}}} {"$::EMENUDIR1"} \
   ent1 {{      Project name:} {} {-tvar ::EMENUP2}} {"$::EMENUP2"} \
   v_2 {{} {-pady 6}} {} \
   chb1 {{Mulster afterwards:}} {$::EMENUMULSTER} \
   dirM {{ Mulster directory:} {} {-tvar ::EMENUMULSTERDIR}} {"$::EMENUMULSTERDIR"} \
   v_3 {{} {-pady 6}} {} \
   dir2 {{ Copy to directory:} {} {-tvar ::EMENUMULSTRES2}} {"$::EMENUMULSTRES2"} \
   seh {{} {-pady 3} {}} {} \
   } -head {\n This creates Ruff! documentation of Tcl files. \
   \n Customize ruff.tcl at need. } -weight bold == ::EMENUDIR1 ::EMENUP2 ::EMENUMULSTER EMENUMULSTERDIR ::EMENUMULSTRES2
S: cd $::EMENUDIR1
SW: tclsh %H/UTILS/ruff.tcl "$::EMENUP2"
S: %C set ::EMENUP2html $::EMENUP2.html
S: %C  \
   if {$::EMENUMULSTER} { \
     set ::EMENUMULSTERDIR2 [file join $::EMENUMULSTERDIR tasks ruff src] ; \
     if {![file exists $::EMENUP2html]} {set ::EMENUP2html [lindex [glob -nocomplain *.html] 0]} ; \
     set ::EMTMP "mv -f $::EMENUP2html $::EMENUMULSTERDIR2 ; \
     cd $::EMENUMULSTERDIR ; tclsh mulster.tcl -b 0 tasks/mulster-ruff ; \
     cp -f %H/PG/github/mulster/tasks/ruff/mulstered/$::EMENUP2html $::EMENUMULSTRES2" ; \
     set ::EMENUP2html [file normalize [file join $::EMENUMULSTRES2 $::EMENUP2html]] \
   } else {set ::EMTMP ""}
SW: $::EMTMP ; tclsh %H/UTILS/highlight_tcl/tcl_html.tcl "$::EMENUP2html"
R: %B $::EMENUP2html

ITEM = Ruff! all
R: %I {} "PROJECT DIRECTORIES TO BE PROCESSED" { \
   v_ {{} {-pady 4}} {} \
   tex1 {{ Projects to Ruff!:} {} {-h 8 -w 70 -tabnext chb1}} {$::EMENURUFFDIR} \
   chb1 {{Mulster afterwards:}} {$::EMENUMULSTER} \
   dir2 {{ Copy to directory:}} {"$::EMENUMULSTRES3"} \
   seh {{} {-pady 5} {}} {} \
   tex2 {{   Ruff! the files:} {} {-h 8 -w 70 -tabnext butOK}} {$::EMENURUFFIT} \
   } -head {\n This creates Ruff! documentation of Tcl files. \
   \n Customize ruff.tcl at need. } -focus butOK -weight bold == ::EMENURUFFDIR ::EMENUMULSTER ::EMENUMULSTRES3 ::EMENURUFFIT
SW: %C \
   set home [glob ~] ; \
   set plist [string map {\\n \n} $::EMENURUFFDIR] ; \
   foreach prj [split $plist \n] { ; \
     if {$prj eq ""} continue ; \
     lassign $prj prj prjname ; \
     set prjtail [file tail $prj] ; \
     if {$prjname eq ""} {set prjname $prjtail} ; \
     set prj [string map [list ~ $home] $prj] ; \
     set ::EMENUMULSTRES3 [string map [list ~ $home] $::EMENUMULSTRES3] ; \
     cd $prj ; \
     catch {exec tclsh $home/UTILS/ruff.tcl $prjtail} ; \
     set prjnamehtml $prjtail.html ; \
     if {$::EMENUMULSTER} { \
       if {![file exists $prjnamehtml]} {set prjnamehtml [lindex [glob -nocomplain *.html] 0]} ; \
       exec [auto_execok mv] -f $prjnamehtml ../mulster/tasks/ruff/src ; \
       cd ../mulster ; exec tclsh mulster.tcl -b 0 tasks/mulster-ruff ; \
       exec [auto_execok cp] -f $home/PG/github/mulster/tasks/ruff/mulstered/$prjnamehtml $::EMENUMULSTRES3/$prjname/$prjnamehtml ; \
       set prjnamehtml $::EMENUMULSTRES3/$prjname/$prjnamehtml \
     } ; \
     exec tclsh $home/UTILS/highlight_tcl/tcl_html.tcl $prjnamehtml \
   } ; \
   set flist [string map {\\n \n} $::EMENURUFFIT] ; \
   foreach fit [split $flist \n] { ; \
     exec tclsh $home/UTILS/highlight_tcl/tcl_html.tcl $fit ; \
     if {$::EMENUMULSTER} { \
       exec tclsh mulster.tcl -b 0 -infile $fit tasks/mulster-ruff2 \
     } \
   }
SW: %B file://$::EMENUMULSTRES3

ITEM = Freewrap Tcl
R: cd %H/PG/github/mulster
R: %q FREEWRAP " Want to get freewrapped Tcl executables?"
SW: tclsh mulster.tcl -b 0 tasks/mulster-freewrap
R: cd %H/PG/github/freewrap
RW: ./linux64.672/freewrap ./screenshooter/screenshooter.tcl -w ./linux64.672/freewrap -forcewrap -o ./screenshooter/screenshooter
RW: ./linux64.672/freewrap ./e_menu/s_menu.tcl -w ./linux64.672/freewrap -forcewrap -o ./e_menu/s_menu
RW: cp -f ./e_menu/s_menu.tcl ./TEST-kit/e_menu.vfs/e_menu/
RW: cd %H/PG/github/freewrap/TEST-kit
RW: ./e_m-linux.sh

SEP = 3

ITEM = Save your stuff
SW: cd %PD
R: %C set ::EMENU7ZCNT [expr {($::EMENU7ZCNT+1)%8}]
R: %I {} "BACKUP" { \
   v_ {{} {-pady 4}} {} \
   ent1 {{Archive command:}} {"$::EMENU7ZCOM"} \
   chb1 {{   Include .git:}} {"$::EMENU7ZGIT"} \
   fis1 {{ Archive file-$::EMENU7ZCNT:}} {"$::EMENU7ZARC"} \
   ent2 {{ ... its suffix:} {} {-tooltip {Add anything you think\nbe specific for this stuff\ne.g. "spec-edition"\n\navoid special characters:\nspaces, quotes, ?, *, \{, \}}}} {} \
   seh1 {{} {-pady 7} {}} {} \
   tex1 {{    Directories \n      to backup:} {} {-h 8 -w 60 -tabnext tex2}} {$::EMENU7ZDIR} \
   tex2 {{    Directories \n      postponed:} {} {-h 8 -w 60 -tabnext entdir3}} {$::EMENU7ZSKIP} \
   seh2 {{} {-pady 7} {}} {} \
   dir3 {{        Save to:}} {"$::EMENU7ZBAK"} \
   } -head {\n This creates a backup of your directories. } -focus butOK -weight bold == ::EMENU7ZCOM ::EMENU7ZGIT ::EMENU7ZARC ::EMENU7ZSUFF ::EMENU7ZDIR ::EMENU7ZSKIP ::EMENU7ZBAK
RW: %C set ::EMENUTMP "$::EMENU7ZARC-$::EMENU7ZSUFF-$::EMENU7ZCNT-N.zip"
RW: %C \
  file delete "$::EMENUTMP" ; \
  set ::EMENU7ZDIR_LIST "" ; \
  set flist [string map {\\n \n} $::EMENU7ZDIR] ; \
  foreach f [split $flist \n] { \
    if {"$f" ne ""} { \
      append ::EMENU7ZDIR_LIST " $f" ; \
      if {$::EMENU7ZGIT} { \
        set dirname [file dirname $f] ; \
        append ::EMENU7ZDIR_LIST " $dirname/.git/*" ; \
        append ::EMENU7ZDIR_LIST " $dirname/.gitignore" ; \
        append ::EMENU7ZDIR_LIST " $dirname/.fslckout" ; \
        append ::EMENU7ZDIR_LIST " $dirname/.bak" ; \
      } \
    } \
  }
SW: $::EMENU7ZCOM $::EMENUTMP $::EMENU7ZDIR_LIST ; mplayer %ms/s1.wav
R: %C if {"$::EMENU7ZBAK" ne ""} { \
  file copy -force {$::EMENUTMP} "[file join {$::EMENU7ZBAK} [file tail {$::EMENUTMP}]]" ; \
  if {$::EMENU7ZGIT} { \
    file delete -force "[file join {$::EMENU7ZBAK} FOSSIL]" ; \
    file copy -force [file normalize %H/FOSSIL] $::EMENU7ZBAK ; \
  }}
R: mplayer %ms/s1.wav

ITEM = Mulster %F
SW: cd %PD
R: %I {} "MULSTER" { \
   v_ {{} {-pady 4}} {} \
   ent1 {{TEMP ini file   :}} {"$::EMENU_MULST1"} \
   ent2 {{TEMP result file:}} {"$::EMENU_MULST2"} \
   tex1 {{Find strings    :} {} {-h 4 -w 60}} {$::EMENU_MULST3} \
   tex2 {{Replace to      :} {} {-h 4 -w 60}} {$::EMENU_MULST4} \
   cbx1 {{Mode            :}} {"$::EMENU_MULST5" exact exact0 glob regexp regexp--} \
   } -head {\n This replaces multiple strings in your file.\n (exact0 means "without leading/trailing spaces")} -weight bold \
   == ::EMENU_MULST1 ::EMENU_MULST2 ::EMENU_MULST3 ::EMENU_MULST4 ::EMENU_MULST5
R: %C set ch [open $::EMENU_MULST1 w] ; \
  puts $ch "IN=BEGIN" ; \
  puts $ch $::EMENU_MULST3 ; \
  puts $ch "IN=END" ; \
  puts $ch "OUT=BEGIN" ; \
  puts $ch $::EMENU_MULST4 ; \
  puts $ch "OUT=END" ; \
  close $ch
SW: tclsh %H/PG/github/mulster/mulster.tcl -backup 0 -mode $::EMENU_MULST5 -infile "%f" -outfile "$::EMENU_MULST2" $::EMENU_MULST1

SEP = 3

ITEM = Doc of Printer: $::EMENUP2 ...
R: cd $::EMENUDIR3
R: %I {} "PROJECT NAME" { \
   v_ {{} {-pady 4}} {} \
   dir1 {{ Printer directory:} {} {-w 50}} {"$::EMENUDIR3"} \
   ent1 {{      Project name:} {} {}} {"$::EMENUP2"} \
   v_2 {{} {-pady 6}} {} \
   dirM {{ Mulster directory:} {} {}} {"$::EMENUMULSTERDIR"} \
   v_3 {{} {-pady 6}} {} \
   dir2 {{ Copy to directory:} {} {}} {"$::EMENUPRINTER"} \
   seh {{} {-pady 3} {}} {} \
   } -head {\n This creates alited Printer documentation of Tcl files. \
   } -weight bold == ::EMENUDIR3 ::EMENUP2 EMENUMULSTERDIR ::EMENUPRINTER
S: %C  \
   set ::EMTMP0 [file join $::EMENUDIR3 $::EMENUP2] ; \
   set ::EMTMP1 [file join $::EMENUPRINTER $::EMENUP2] ; \
   set ::EMTMP2 [file join $::EMENUPRINTER zoo] ; \
   set ::EMTMP3 " \
     cd $::EMENUMULSTERDIR ; \
     rm -f -r tasks/printer/src/* ; \
     mkdir $::EMTMP1 ; \
     cp -f -r $::EMTMP0/* tasks/printer/src ; \
     cp -f tasks/printer/src/css/style.css $::EMTMP2 ; \
     rm -f -r tasks/printer/src/css ; \
     rm -f -r tasks/printer/mulstered/* ; \
     rm -f -r $::EMTMP1/* ; \
     tclsh mulster.tcl -b 0 tasks/mulster-alitedprinter ; \
     cp -f -r tasks/printer/mulstered/* $::EMTMP1" ; \
   set ::EMENUP2html [file normalize [file join $::EMTMP1 index.html]]
SW: $::EMTMP3
R: %B $::EMENUP2html
