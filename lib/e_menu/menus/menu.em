[OPTIONS]

in=1.0
w=25
pos=29.15
::EMENUTMPFILE=%mn.tmp~
%C if {![info exist ::EMENU_FOSGIT]} {set ::EMENU_FOSGIT Fossil}
%C if {![info exist ::EMENUFILE]} {set ::EMENUFILE [set ::EMENURUNFILE {%f}] ; if {[::iswindows]} {set ::EMENURUNFILE [string map [list \\ \\\\] {%f}]; set ::EMENUFILE [string map [list \\ \\\\\\\\] {%f}]}}
%C set ::EMENUTCLFILE  [string map [list \\ /] {%f}]
%C set ::EMENUFILETAIL [file tail {$::EMENUFILE}]
%C set ::FILETAIL {"$::EMENUFILETAIL"}
%C set ::DIRTAIL "\"[file tail {%d}]\""
%C if {{%F}=={*} && ![info exist ::EMENUFILE]} {set ::EMENUFILE "*"}
%C if {![info exist ::EMENUCOMMIT]} {set ::EMENUCOMMIT ""}
::EMENUBAKCNT=0

[MENU]


 # menu for e_menu.tcl

SEP = 3
ITEM = F4 Run me {+selection}
RE: cd %d
R: %C set ::_EM_AR_ [string map {\\$ \$} {%AR}]
R: %C set ::_EM_RF_ [string map {\\$ \$} {%RF}]
R: %C set ::_EM_EE_ [string map {\\$ \$} {%EE}]
SE: %IF {%EE} ne "" %THEN $::_EM_EE_
RE: %IF "%x" in ".tcl .tk .tm .test" && {%RF} ne "" %THEN %T tclsh $::_EM_RF_
RE: %IF "%x" in ".tcl .tk .tm .test" %THEN %T tclsh "$::EMENUTCLFILE" $::_EM_AR_
RE: %IF "%x" eq ".py"  %THEN python3 "$::EMENURUNFILE" %AR
RE: %IF "%x" in {.htm .html} %THEN %b "$::EMENURUNFILE"
SE: %IF {%RF} ne "" %THEN %RF
RE: %IF {%AR} eq "" && ![::iswindows] %THEN %O "$::EMENURUNFILE"
RE: "$::EMENURUNFILE" %AR

ITEM = Run Tcl {all selection}
S: cd %d
RE: %IF {%TF} eq {%f} || ![file exists "%TF"] %THEN %M \n Select Tcl snippet\n while editing a file in alited editor!\n
S: tclsh %m/src/ch_.tcl "%TF"

ITEM = Edit/create file "%s"
RE: cd %d
RE: %E '%s'

# RE: Open directory "%D" RE: %IF ![::iswindows] %THEN %q "CHANGE ME" "The directory:\n%d\n\nwould be open by \"caja\" file manager.\n\nYou can change it by editing:\n%mn" okcancel warn OK -ontop 1
ITEM = Open directory "%D"
RE: %IF [::iswindows] %THEN explorer.exe "%d" %ELSE %O "%d"

ITEM = Open terminal in "%D"
RE: cd %d
SE: %IF [::iswindows] %THEN %TT
RE: %TT

SEP = -3

ITEM = Open in browser "%s" site
RE: cd %d
RE: %B %s

ITEM = Search in Firefox for "%s"
RE: firefox -search "%s"
ITEM = Wikipedia for "%s"
RE: %b https://en.wikipedia.org/w/index.php?cirrusUserTesting=classic-explorer-i&search=%+
# RE: Youtube for "%s" RE:%b https://www.youtube.com/results?search_query=%+
ITEM = GoldenDict for "%s"
RE: goldendict "%s"

SEP = 3
ITEM = Search All "%s" in %D
ME: m=grep.em o=-1


ITEM = Backup of $::FILETAIL
R: %C set ::EMENUBAKCNT [expr {($::EMENUBAKCNT+1)%4}]
R: %C set ::EMENUBAK [file join [string map [list \\ /] {%PD}] .bak "$::EMENUFILETAIL-$::EMENUBAKCNT.bak"]
R/ %q "BACKUP" "The backup of\n\n%UF\n\nwould be saved to\n\n$::EMENUBAK"
R: %C file mkdir [file dirname "$::EMENUBAK"]
R: %C if [::iswindows] {set ::EMENUBAK [string map [list / \\] {$::EMENUBAK}]}
R: %C if [::iswindows] {set ::EMENUFILE [string map [list \\ \\\\] {%f}]}
S: %IF [::iswindows] %THEN copy /Y "$::EMENUFILE" "$::EMENUBAK" %ELSE cp -f "$::EMENUFILE" "$::EMENUBAK"

ITEM = Commit "%s"
R: %C if {![info exist ::EM_MSG]} {set ::EM_MSG "%s"}
R: %I {} "COMMIT" { \
   tex1 {{ Message for commit:} {} {-w 50 -h 7 -tabnext butOK}} {$::EM_MSG} \
   } -head {\n This will try to FOSSIL & GIT committing.\n\n A message for commit is required.\
   \n NOTE: quotes and newlines will be removed.\n} \
   -hfg $::em::clrhelp -weight bold == ::EM_MSG
R: %C set ::TMP_MSG [string map {\" {} ' {} \n { }} [set ::EM_MSG]]
R: %C if {"[string trim [set ::TMP_MSG]]" eq ""} {M " Enter some message to commit."; exit}
R: cd %PD
S: %IF [Q "FOSSIL COMMIT" " Add all changes and FOSSIL COMMIT\n\n with message\n\n   '$::TMP_MSG' ?"] %THEN fossil add *\n\n fossil commit -m "$::TMP_MSG"
S: %IF [Q "FOSSIL COMMIT" " Add all changes and GIT COMMIT\n\n with message\n\n   '$::TMP_MSG' ?"] %THEN git add *\n\n git commit -m "$::TMP_MSG"

ITEM = Differences of $::FILETAIL (fossil/git) ...
R: cd %PD
R: %C if {{$::EMENU_FOSGIT} eq {Fossil}} {exec fossil tim -t ci -n 99 > $::EMENUTMPFILE} {exec git log --format=oneline -99 > $::EMENUTMPFILE}
R: %C set ::EMENUBAKFILE [file join "%pd" .bak $::EMENUFILETAIL]
R: %C if {"%BF" ne {}} {set ::EMENUBAKFILE "%BF"}
R: %C if {[file exists "$::EMENUBAKFILE"]} {set ::EMENUCHBSTATE normal} {set ::EMENUCHBSTATE disabled}
R: %C set ::EMENUCHB 0
R: %I {} "GDIFF" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{   File:} {} {-w 60}} {"$::EMENUFILE"} \
   fco1 {{Version:} {} {-h 10 -state readonly -inpval "$::EMENUCOMMIT"}} \
     {@@-div1 "\[" -div2 "\]" -ret 1 $::EMENUTMPFILE@@    INFO: @@-div1 "\] " -list {{}} $::EMENUTMPFILE@@} \
   rad  {{    SCM:}} {"$::EMENU_FOSGIT" {Fossil} {Git}} \
   seh {{} {-pady 3} {}} {} \
   chb {{With .bak version:} {} {-w 6 -state $::EMENUCHBSTATE}} {"$::EMENUCHB"} \
   seh2 {{} {-pady 3} {}} {} \
   texc {{   Hint:} {} {-h 12 -w 60 -ro 1 -wrap word}} \
   {\n Select a version from the combobox to be compared to tip.\n\n If it's blank, the current file is compared to tip.\n\n No response means no differences.\n\n Or you can compare a current file with its .bak version\n saved in .bak subdirectory of project, before last changes.\n\n (temp file: $::EMENUTMPFILE)} \
   } -head {\n This will compare a selected version of\n     $::EMENUFILE\n to its tip.} -weight bold == ::EMENUFILE ::EMENUCOMMIT ::EMENU_FOSGIT ::EMENUCHB
R: %IF {$::EMENUCHB} %THEN "%DF" "$::EMENUFILE" "$::EMENUBAKFILE"
R: %C if {"$::EMENUCOMMIT" eq ""} \
   {set ::EMENUTMP ""} {set ::EMENUTMP "--from $::EMENUCOMMIT --to tip"}
R: %IF {$::EMENU_FOSGIT} eq {Fossil} %THEN \
  fossil gdiff $::EMENUTMP "$::EMENUFILE" %ELSE git difftool -y $::EMENUCOMMIT HEAD -- "$::EMENUFILE"

 # call alited/Geany with all *.tcl of current file's directory
ITEM = Edit *.tcl of $::DIRTAIL
R: %q "EDIT ALL *.tcl" "This will edit all .tcl files of\n\n%d"
R: %C set ::ALLFILES [glob -nocomplain [file join [file normalize "%d"] *.tcl]]
R: %E $::ALLFILES
RE: %C unset ::ALLFILES

SEP = 3
ITEM = Fossil
ME: m=fossil.em "u=%s" o=-1
ITEM = Git
ME: m=git.em "u=%s" o=-1
ITEM = Hg
ME: m=hg.em o=-1
ITEM = Utils
ME: m=utils.em o=-1
