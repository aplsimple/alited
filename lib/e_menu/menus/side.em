[OPTIONS]

in=1.0
pos=100.0
::EMENUTMPFILE=%mn.tmp~
%C if {![info exist ::EMENUCOMMIT]} {set ::EMENUCOMMIT [set ::EMENUCOMMIT2 ""]}
%C if {![info exist ::EMENUFILE]} {set ::EMENUFILE "%f"}
%C set ::EMENUFILE [string map {\\ /} "$::EMENUFILE"]
%C if {![info exist ::EMENUGREP]} {set ::EMENUGREP ""}
%C if {{%F}=={*} && ![info exist ::EMENUFILE]} {set ::EMENUFILE "*"}
%C set ::EMENUFILETAIL [file tail {$::EMENUFILE}]
%C set ::FILETAIL {"$::EMENUFILETAIL"}
::EMENU7ZCNT=0
::EMENU7ZCOM=zip -r
::EMENU7ZSUFF=big
::EMENU7ZARC=~/PG/github/apl-github
::EMENU7ZDIR=~/PG/github/alited/*\n~/PG/github/aloupe/*\n~/PG/github/aplsimple.github.io/*\n~/PG/github/baltip/*\n~/PG/github/bartabs/*\n~/PG/github/booksum/*\n~/PG/github/doctest/*\n~/PG/github/e_menu/*\n~/PG/github/hl_tcl/*\n~/PG/github/mulster/*\n~/PG/github/pave/*\n~/PG/github/poApps/*\n~/PG/github/screenshooter/*\n~/PG/github/tkcc/*\n~/PG/github/transpops/*\n~/PG/github/trimmer/*\n~/PG/github/DEMO/*\n~/PG/github/klnd/*\n~/PG/github/ale_themes/*\n~/PG/github/wiki.tcl-lang.org/*
::EMENU7ZSKIP=
::EMENU7ZBAK=/media/apl/KINGSTON/
::EMENU7ZGIT=1

[MENU]


ITEM = git status
R: cd %PD
S: pwd\necho %PD\ngit status

ITEM = git log
S: cd %PD
S: git log

ITEM = git gui
R: cd %PD
R: git gui

SEP = -5

ITEM = git difftool $::FILETAIL ?
R: cd %PD
RW: git log --format=oneline -10 > $::EMENUTMPFILE
R: %I {} "DIFFTOOL" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{   File:} {} {-w 70}} {"$::EMENUFILE"} \
   fco1 {{Version:} {} {-h 10 -state readonly -retpos 0:10 -inpval "$::EMENUCOMMIT"}} \
     {@@-pos 0 -len 10 $::EMENUTMPFILE@@    INFO: @@-div1 { } $::EMENUTMPFILE@@} \
   seh {{} {-pady 3} {}} {} \
   texc {{   Hint:} {} {-h 9 -w 70 -ro 1 -wrap word}} \
   {\n Select a version from the combobox to be compared to HEAD.\n\n If it's blank, the current file is compared to HEAD.\n\n No response means no differences.\n\n (temp file: $::EMENUTMPFILE)} \
   } -head {\n This will compare a selected version of\n     %f\n to its HEAD.} -weight bold == ::EMENUFILE ::EMENUCOMMIT
R: git difftool $::EMENUCOMMIT HEAD -- "$::EMENUFILE"

ITEM = git diff ?
S: cd %PD
RW: git log --format=oneline -10 > $::EMENUTMPFILE
R: %I {} "DIFF" { \
   v_ {{} {-pady 4} {}} {} \
   fco1 {{     Version :} {} {-h 10 -state readonly -retpos 0:10 -inpval "$::EMENUCOMMIT"}} \
     {@@-pos 0 -len 10 -list {""} $::EMENUTMPFILE@@    INFO: @@-div1 { } $::EMENUTMPFILE@@} \
   ent1 {{Regexp filter:} {} {-w 55}} {"$::EMENUGREP"} \
   seh {{} {-pady 3} {}} {} \
   texc {{        Hint :} {} {-h 9 -w 55 -ro 1 -wrap word}} \
   { Select a version from the combobox to be compared to HEAD. \
     \n\n If it's blank, the current files are compared to HEAD. \
     \n\n When 'regexp filter' set, an additional console shows \
     \n the filtered lines. \
     \n\n temp file:\n $::EMENUTMPFILE} \
   } -head {\n This will compare a selected version of \
     \n     %PD\n to its HEAD.} -weight bold == ::EMENUCOMMIT ::EMENUGREP
S: %C set ::EMENUTMP {git diff $::EMENUCOMMIT HEAD}
R: %IF {$::EMENUGREP} eq "" %THEN %T $::EMENUTMP
RW: $::EMENUTMP | grep -n "$::EMENUGREP" > "$::EMENUTMPFILE"
SW: cat "$::EMENUTMPFILE"
R: %C file delete "$::EMENUTMPFILE"
S: $::EMENUTMP

SEP = -5

ITEM = git merge
S: cd %PD
R: %q "Merging changes" "Merge changes in\n\n  %PD ?"
S: git merge

ITEM = git branch
S: cd %PD
S: git branch

ITEM = git checkout "%s"
S: cd %PD
R: %q "Checkout" "Checkout to\n\n'%s' ?"
S: git checkout "%s"

SEP = -5

ITEM = git add *
S: cd %PD
R: %q "Adding changes" "Add all changes in\n\n%PD\n\nto a local repository ?"
S: git add *\ngit status

ITEM = git commit
S: cd %PD
R: %q "Committing changes" "Commit with message to be edited ?"
S: git commit

ITEM = git commit -a ?
S: cd %PD
S: %C if {![info exist ::EMENUCOMMIT3]} {set ::EMENUCOMMIT3 "%s %t1 #%i1"}
R: %I {} "ADD & COMMIT" { \
   v_ {{} {-pady 4} {}} {} \
   texc {{Comments:} {} {-h 7 -w 60 -wrap word}} {$::EMENUCOMMIT3} \
   } -head {\n This will add and commit changes in:\n   %PD\n\n Enter comments for the commit.} -weight bold == ::EMENUCOMMIT3
R: %C if {"$::EMENUCOMMIT3" eq ""} exit
S: git commit -a "$::EMENUCOMMIT3"

ITEM = git pull
S: cd %PD
R: %q "Pulling changes" "Pull changes in\n\na remote repository\n\nto %PD ?"
S: git pull

ITEM = git push
S: cd %PD
R: %q "Pushing changes" "Push all changes in\n\n%PD\n\nto a remote repository ?"
S: git push

SEP = -5

ITEM = Fossil
MW: m=fossil.em w=50
ITEM = Git
M: m=git.em
ITEM = Hg
M: m=hg.em

SEP = -5

ITEM = Find by grep
M: m=grep.em w=40
ITEM = Tcl/Tk
M: m=tcltk.em w=20
ITEM = Utils
M: m=utils.em w=40
ITEM = Tests
M: m=test1.em w=40
ITEM = Misc
M: m=misc.em w=40

# utils menu for e_menu.tcl

SEP = -5

ITEM = caja %PD
R: caja "%PD"
ITEM = xterm %PD
R: cd %PD
R: xterm -fa ru_RU.utf8 -fs 11 -geometry 90x30+400+150

ITEM = meld %PD
R: cd %PD
R: meld .

ITEM = edit all %PD in TKE
R: cd %PD
R: tke "%PD"

ITEM = wget Web page
S: %#W wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/
R: %Q "CHANGE ME" "The directory %z5/WGET\n\nwould be open by \"caja\" file manager.\n\nYou can change it by editing:\n%mn"
R: cd %z5/WGET
R: %IF [::iswindows] %THEN explorer.exe "." %ELSE caja "."

ITEM = Project Gutenberg
R: %b https://www.gutenberg.org/

SEP = -5

ITEM = Save your stuff
SW: cd %PD
R: %C set ::EMENU7ZCNT [expr {($::EMENU7ZCNT+1)%4}]
R: %I {} "BACKUP" { \
   ent1 {{Archive command:}} {"$::EMENU7ZCOM"} \
   chb1 {{   Include .git:}} {"$::EMENU7ZGIT"} \
   fil1 {{ Archive file-$::EMENU7ZCNT:}} {"$::EMENU7ZARC"} \
   ent2 {{ ... its suffix:} {} {-tooltip {Add anything you think\nbe specific for this stuff\ne.g. "spec-edition"\n\navoid special characters:\nspaces, quotes, ?, *, \{, \}}}} {"$::EMENU7ZSUFF"} \
   seh1 {{} {-pady 7} {}} {} \
   tex1 {{    Directories \n      to backup:} {} {-h 8 -w 60 -tabnext tex2}} {$::EMENU7ZDIR} \
   tex2 {{    Directories \n      postponed:} {} {-h 8 -w 60 -tabnext entdir3}} {$::EMENU7ZSKIP} \
   seh2 {{} {-pady 7} {}} {} \
   dir3 {{        Save to:}} {"$::EMENU7ZBAK"} \
   } -head {\n This creates a backup of your directories.\n } -focus butOK -weight bold == ::EMENU7ZCOM ::EMENU7ZGIT ::EMENU7ZARC ::EMENU7ZSUFF ::EMENU7ZDIR ::EMENU7ZSKIP ::EMENU7ZBAK
R: %C set ::EMENUTMP "$::EMENU7ZARC-$::EMENU7ZSUFF-$::EMENU7ZCNT-N.zip"
R: %C \
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
      } \
    } \
  }
SW: $::EMENU7ZCOM $::EMENUTMP $::EMENU7ZDIR_LIST ; mplayer %ms/s1.wav
R: %C if {"$::EMENU7ZBAK" ne ""} { \
  file copy -force {$::EMENUTMP} "[file join {$::EMENU7ZBAK} [file tail {$::EMENUTMP}]]" ; \
  if {$::EMENU7ZGIT} { \
    file delete -force "[file join {$::EMENU7ZBAK} FOSSIL]" ; \
    file copy -force [file normalize ~/FOSSIL] $::EMENU7ZBAK ; \
  }}
R: mplayer %ms/s1.wav

SEP = -5

ITEM = Google
R: %b https://google.com
ITEM = Wikipedia.en
R: %b https://en.wikipedia.org
ITEM = Wikipedia.de
R: %b https://de.wikipedia.org
ITEM = Wikipedia.ru
R: %b https://ru.wikipedia.org

SEP = -5

ITEM = Pave wiki
R: %b https://aplsimple.github.io/en/tcl/pave
ITEM = E_menu wiki
R: %b https://aplsimple.github.io/en/tcl/e_menu
ITEM = Alited wiki
R: %b https://aplsimple.github.io/en/tcl/alited

[HIDDEN]

ITEM = 1. tkcon
R: tkcon
ITEM = 2. Stop working!
R: ?-33*60/-7*60:ah=3? audacious  /home/apl/PROGRAMS/C_COMM/breakon.wav
ITEM = 3. Arbeiten!
R: audacious /home/apl/PROGRAMS/C_COMM/breakoff.wav
ITEM = 4. caja
R: caja -g +0+0 /home/apl/PG/github
ITEM = 5. poApps
R: tclsh /home/apl/PG/github/poApps/poApps.tcl --dirdiff
RW: sleep 4
R: tclsh /home/apl/PG/github/alited.release/src/alited.tcl LOG=~/TMP/alited.log /home/apl/.config/alited.release
ITEM = 6. FVords
RW: sleep 4
R: wine /media/apl/KINGSTON/APLinkee.Shk/APLinkee.exe
R: ~/PROGRAMS/C_COMM/commw /media/apl/KINGSTON/FVords_Prepare fvords.exe
ITEM = 7. Edit
R: cd ~/PG/github/TKE
R: "wish" ~/PG/github/TKE/tke/lib/tke.tcl

[DATA]

%#W geo=1089x560+0+56;pos=23.62 # Below are the commands to get the Web page by wget.|!|# The downloaded pages are stored in ~/WGET directory (change this if needed).|!|#|!|# Note that .+ are used to edge "some unique string of the page address", e.g.|!|#   wget -r -k -l 2 -p --accept-regex=.+/UNIQUE/.+ https://www.some.com/UNIQUE/some|!|# would download all of https://www.some.com/UNIQUE/some|!|# excluding all external links that don't most likely match /UNIQUE/.|!|#|!|# Note also that -l option means "maximum level to dig".|!|###################################################################################|!||!|mkdir ~/WGET|!|cd ~/WGET|!||!|# wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/|!||!|# wget -r -k -l 2 -p --accept-regex=.+tablelist/.+ https://www.nemethi.de/tablelist/index.html|!|# wget -r -k -l 2 -p --accept-regex=.+mentry/.+ https://www.nemethi.de/mentry/index.html|!||!|# wget -r -k -l 2 -p --accept-regex=.+/manual3.1/.+ http://tcl.apache.org/rivet/manual3.1/|!||!|# wget -r -k -l 2 -p --accept-regex=.+letter-to-peter.+ http://catesfamily.org.uk/letter-to-peter/|!|wget -r -k -l 2 -p --accept-regex=.+/tcart.+ http://tcart.com/
