[OPTIONS]

o=-1
w=25
t4==%b-%Y/%U-week
u=%s
in=1.0
pos=9.22
::FSLUSER=aplsimple
::FSLBRANCH=New_branch
::FSLBRANCHCOLOR=#0000aa
::EMENUTMPFILE=%mn.tmp~
::EMENUBRIEF=0
::EM_T_DRY=0
::EM_T_FILE=-g *,src/*,menus/*
::EM_T_TIME=none
::EM_T_VERBOSE=1
::EM_COMOPT=
::EMENUGREP=
::EMENUTF=-e .
::EMENUTFLIST={} {-e /menus -e alited.ini} {-F -e .msg -e .txt} {-F -e .png} {-e data/}
%C if {![info exist ::EMENUCOMMIT]} {set ::EMENUCOMMIT ""}
%C if {![info exist ::EMENUCOMMIT1]} {set ::EMENUCOMMIT1 tip}
%C if {![info exist ::EMENUCOMMIT2]} {set ::EMENUCOMMIT2 ""}
%C if {![info exist ::EMENUFILE]} {set ::EMENUFILE "%f" ; if {[::iswindows]} {set ::EMENUFILE [string map [list \\ \\\\\\\\] "%f"]}}
%C if {{%F}=={*} && ![info exist ::EMENUFILE]} {set ::EMENUFILE "*"}
%C set ::EMENUFILETAIL [file tail {$::EMENUFILE}]
%C set ::FILETAIL {"$::EMENUFILETAIL"}

[MENU]

ITEM = fossil status %PD
S: cd %PD
S: echo %UD\ndir\necho ------------\nfossil status

ITEM = fossil changes
S: cd %PD
S: pwd\necho ------------\ndir\necho ------------\nfossil changes

ITEM = fossil extras
S: cd %PD
S: pwd\necho ------------\ndir\necho ------------\nfossil extras

ITEM = fossil ui
R: cd %PD
R: fossil ui

SEP = 2

ITEM = fossil gdiff $::FILETAIL ?
R: cd %PD
RW: fossil tim -t ci -n 99 > $::EMENUTMPFILE
R: %I {} "GDIFF" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{   File:} {} {}} {"$::EMENUFILE"}\
   fco1 {{Version:} {} {-h 10 -state readonly -inpval "$::EMENUCOMMIT"}}\
     {@@-div1 "\[" -div2 "\]" -ret 1 $::EMENUTMPFILE@@    INFO: @@-div1 "\] " -list {{}} $::EMENUTMPFILE@@}\
   seh {{} {-pady 3} {}} {}\
   texc {{   Hint:} {} {-h 9 -w 60 -ro 1  -tabnext butOK}}\
   {\n Select a version from the combobox to be compared to tip.\n\n If it's blank, the current file is compared to tip.\n\n No response means no differences.\n\n (temp file: $::EMENUTMPFILE)}\
   } -head {\n This will compare a selected version of a file to its tip:} -weight bold == ::EMENUFILE ::EMENUCOMMIT
R: %C if {"$::EMENUCOMMIT" eq ""} \
   {set ::EMENUTMP ""} {set ::EMENUTMP "--from $::EMENUCOMMIT --to tip"}
R: fossil gdiff $::EMENUTMP "$::EMENUFILE"

ITEM = fossil diff ?
S: cd %PD
RW: fossil tim -t ci -n 99 > $::EMENUTMPFILE
R: %I {} "DIFF" { \
   v_ {{} {-pady 4} {}} {} \
   fco1  {{         From:} {} {-h 10 -state readonly -cbxsel "$::EMENUCOMMIT1"}} \
     {@@-div1 "\[" -div2 "\]" -ret 1 -list {"" tip} $::EMENUTMPFILE@@ \
     INFO: @@-div1 "\] " $::EMENUTMPFILE@@} \
   fco2  {{           To:} {} {-h 10 -state readonly -cbxsel "$::EMENUCOMMIT2"}} \
     {@@-div1 "\[" -div2 "\]" -ret 1 -list {"" tip} $::EMENUTMPFILE@@ \
     INFO: @@-div1 "\] " $::EMENUTMPFILE@@} \
   cbx1  {{Regexp filter:} {} {}} { {$::EMENUGREP} {} {^[+]} } \
   chbBr {{        Brief:} {-pady 4} {}} {$::EMENUBRIEF} \
   seh {{} {-pady 3} {}} {} \
   texc  {{         Hint:} {} {-h 11 -w 67 -ro 1 -tabnext butOK}} \
   { Select versions from the comboboxes to be compared. \
  \n\n By default, 'tip' is compared to current files. \
  \n\n A 'to' version is later than 'from'. Empty means 'current files'. \
  \n\n When 'regexp filter' set, an additional console shows \
  \n the filtered lines. \
  \n\n temp file:\n $::EMENUTMPFILE} \
   } -head {\n This will compare selected versions of\n %UD} -focus butOK \
   -weight bold == ::EMENUCOMMIT1 ::EMENUCOMMIT2 ::EMENUGREP ::EMENUBRIEF
R: %C \
   if {"$::EMENUCOMMIT1" eq ""} {set ::EMENUTMP1 ""} {set ::EMENUTMP1 "--from $::EMENUCOMMIT1"}; \
   if {"$::EMENUCOMMIT2" eq ""} {set ::EMENUTMP2 ""} {set ::EMENUTMP2 "--to $::EMENUCOMMIT2"}; \
   if {"$::EMENUCOMMIT1$::EMENUCOMMIT2" eq ""} \
     {set ::EMENUTMP1 "--from current"; set ::EMENUTMP2 "--to tip"}
R: %C if {$::EMENUBRIEF} {append ::EMENUTMP2 " -brief"}
R: %C set ::EMENUTMP "fossil diff $::EMENUTMP1 $::EMENUTMP2"
R: %IF {$::EMENUGREP} eq "" %THEN %T $::EMENUTMP
RW: $::EMENUTMP | grep -n "$::EMENUGREP" > "$::EMENUTMPFILE"
SW: cat "$::EMENUTMPFILE"
R: %C file delete "$::EMENUTMPFILE"
R: %IF !$::EMENUBRIEF %THEN %T $::EMENUTMP

%MC TITLE %MC COMMAND %MC COLOR %MC MSG1
%MC S: cd %PD
%MC R: %I {} "$TITLE" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{   File:} {} {-w 60}} {"$::EMENUFILE"} \
   } -head {\n This will \"$COMMAND\" file(s) in the Fossil repository:\n %UD $MSG1 \
   \n\n Use wildcards to $COMMAND a few.} $COLOR -weight bold == ::EMENUFILE
%MC S: fossil $COMMAND $::EMENUFILE

ITEM = fossil add $::FILETAIL ?
S: %MC ADD FILE %MC add %MC %MC

ITEM = fossil forget $::FILETAIL
S: %MC FORGET FILE %MC forget %MC -hfg $::em::clrhotk %MC

ITEM = fossil revert $::FILETAIL
S: %MC REVERT FILE %MC revert %MC -hfg $::em::clrhotk \
   %MC \n\n Thus, a last check-in of the file(s) would be restored. \
   \n You can undo this with "fossil undo".

SEP = 2

ITEM = fossil timeline
S: cd %PD
S: fossil timeline

ITEM = fossil timeline --showfiles ?
R: %I {} "TIMELINE FOR FILE(S)" { \
   v_ {{} {-pady 4} {}} {} \
   dir1 {{Directory:} {} {}} {"%UD"}\
   cbx1 {{   Filter:} {} {}} {"$::EMENUTF" $::EMENUTFLIST} \
   seh {{} {-pady 3} {}} {}\
   texc {{     Hint:} {} {-h 9 -w 60 -ro 1  -tabnext butOK}}\
   { To filter file(s), use "-e /dir -e file" pattern(s).\n\n For example:\n   -e /menus/ -e /src/\n   -e README\n   -e .\n\n Use -F option to search exactly (not by regexp):\n   -F -e .tcl -e .mnu} \
   } \
   -head {\n This will show a timeline for separate file(s):} -weight bold == ::EMENUTFDIR ::EMENUTF
R: cd $::EMENUTFDIR
R: %C catch {if {[set _ [lsearch -exact [list $::EMENUTFLIST] {$::EMENUTF}]]>=0} \
     {set ::EMENUTFLIST [lreplace [list $::EMENUTFLIST] [set _] [set _]]}}
R: %C catch {set ::EMENUTFLIST [linsert [list $::EMENUTFLIST] 0 {$::EMENUTF}]}
R: %C catch {set ::EMENUTFLIST [lreplace [list $::EMENUTFLIST] 16 end]}
RW: fossil timeline --showfiles -n 0 > "$::EMENUTMPFILE"
S: grep $::EMENUTF -e === "$::EMENUTMPFILE"

SEP = 2

ITEM = fossil commit ?
S: cd %PD
R: %I {} "TOUCH & COMMIT" { \
   lab1  {{} {} {-t {For TOUCH:} -font {-weight bold}}}  {} \
   fil1 {{   File(s):}} {"$::EM_T_FILE"} \
   opc1 {{Time stamp:} {-fill none -anchor w}} {{$::EM_T_TIME} {{none} {time --now --checkin --checkout}} {-width 10}} \
   chb1 {{   Verbose:}} {$::EM_T_VERBOSE} \
   seh {} {} v_2 {{} {-pady 2}} {} \
   lab2  {{} {} {-t {For COMMIT:} -font {-weight bold}}}  {} \
   cbx2 {{   Options:}} {"$::EM_COMOPT" --allow-conflict --allow-empty --allow-fork --allow-older --baseline {--bgcolor COLOR} {--branch NEW-BRANCH-NAME} {--branchcolor COLOR} --close --delta --integrate {--mimetype MIMETYPE} -n|--dry-run --no-prompt --nosign --override-lock --private --hash {--tag TAG-NAME} {--date-override YYYY-MM-DDTHH:MM:SS.SSS} {--user-override USER}} \
   seh2 {} {} \
   texc {{Hint:} {} {-h 13 -w 70 -ro 1 -tabnext butOK}} \
   { You can touch any file(s) before committing.\
\n If you omit file/time of touching, it will not be made.\
\n     ______________________________________________________\
\n\n The file(s) mtime will be updated to the 'Time stamp'. \
\n\n The 'File(s)' may be globs. Set '-g' before a comma-separated list\
\n of glob patterns, for example: -g *,src/*,menus/*. \
\n     ______________________________________________________\
\n\n           AFTER TOUCHING THE COMMIT WILL BE MADE.\n\n\
 --allow-conflict       allow unresolved merge conflicts\n\
 --allow-empty          allow a commit with no changes\n\
 --allow-fork           allow the commit to fork\n\
 --allow-older          allow a commit older than its ancestor\n\
 --baseline             use a baseline manifest in the commit process\n\
 --bgcolor COLOR        apply COLOR to this one check-in only\n\
 --branch BRANCH-NAME   check in to this new branch\n\
 --branchcolor COLOR    apply given COLOR to the branch\n\
 --close                close the branch being committed\n\
 --delta                use a delta manifest in the commit process\n\
 --integrate            close all merged-in branches\n\
 -m|--comment TEXT      use TEXT as commit comment\n\
 -M|--message-file FILE read the commit comment from given file\n\
 --mimetype MIMETYPE    mimetype of check-in comment\n\
 -n|--dry-run           If given, display instead of run actions\n\
 --no-prompt            This option disables prompting the user for\n\
                        input and assumes an answer of 'No' for every\n\
                        question.\n\
 --no-warnings          omit all warnings about file contents\n\
 --nosign               do not attempt to sign this commit with gpg\n\
 --override-lock        allow a check-in even though parent is locked\n\
 --private              do not sync changes and their descendants\n\
 --hash                 verify file status using hashing rather\n\
                        than relying on file mtimes\n\
 --tag TAG-NAME         assign given tag TAG-NAME to the check-in\n\
 --date-override DATE   DATE to use instead of 'now'\n\
 --user-override USER   USER to use instead of the current default\
} \
   } -head {\n This will TOUCH the file(s) of Fossil repository\n to have the file(s) time equal to the time stamp.\n\n Then this will run COMMIT on the repository:\n %UD\n} -weight bold == ::EM_T_FILE ::EM_T_TIME ::EM_T_VERBOSE ::EM_COMOPT
S: %C if $::EM_T_VERBOSE {set ::EM_T_v -v} {set ::EM_T_v ""}
SW: %IF "$::EM_T_TIME" ni {{} none} && "$::EM_T_FILE" ne "" %THEN fossil touch $::EM_T_v $::EM_T_TIME $::EM_T_FILE
S: fossil commit --allow-empty $::EM_COMOPT

ITEM = fossil commit -f -tag ?
S: cd %PD
R: %C set ::COMTAG "%s"
R: %I warn "TAG COMMIT" { \
   ent1 {{Tag for the last commit:} {} {}} {"$::COMTAG"} \
   } -head {\n This will TAG the last commit:} -weight bold == ::COMTAG
S: fossil commit -f -tag "$::COMTAG" -bgcolor '#F8A4F6'

ITEM = fossil commit -m ? --branch ?
R: cd %PD
R: %C if {"$::FSLBRANCH" eq ""} {set ::FSLBRANCH "%s"}
R: %I warn "COMMIT & BRANCH" { \
   ent {{Branch name  (1 word):}} {"$::FSLBRANCH"} \
   clr {{Branch color (1 word):\nor empty}} {"$::FSLBRANCHCOLOR"} \
   v_} -head {\n This will COMMIT and create a new BRANCH \
   \n from a current check-in.} -weight bold == ::FSLBRANCH ::FSLBRANCHCOLOR
R: %C lassign {$::FSLBRANCH} ::FSLBRANCH; if {{$::FSLBRANCH} eq {}} EXIT
R: %C lassign {$::FSLBRANCHCOLOR} ::FSLBRANCHCOLOR
R: %C if {"$::FSLBRANCHCOLOR" eq {}} {set ::TMPBG ""} {set ::TMPBG "-bgcolor $::FSLBRANCHCOLOR"}
SW: fossil commit -m $::FSLBRANCH --branch $::FSLBRANCH $::TMPBG

SEP = 2

ITEM = fossil stash
S: cd %PD
R: %q "Stash" " Stash the current project?"
S: fossil stash

ITEM = fossil stash snapshot $::FILETAIL ?
S: %MC STASH SNAPSHOT %MC stash snapshot \
   %MC -hfg $::em::clrhotk %MC

ITEM = fossil stash list -v
S: cd %PD
S: fossil stash list -v

ITEM = fossil stash show
S: cd %PD
S: fossil stash show

ITEM = fossil stash pop
S: cd %PD
R: %q "Stash pop" " Stash pop the current project?\n\n This saves the stashed changes and \n deletes a changeset from the stash."
S: fossil stash pop

ITEM = fossil stash apply
S: cd %PD
R: %q "Stash apply" " Stash apply the current project?\n\n This saves the stashed changes and \n retains the changeset in the stash."
S: fossil stash apply

ITEM = fossil stash drop --all
S: cd %PD
R: %q "Stash pop" " Stash drop the current project?\n\n This forgets the whole stash."
S: fossil stash drop --all

ITEM = fossil stash gdiff
S: cd %PD
S: fossil stash gdiff

SEP = 2
ITEM = Next
M: m=fossil2.em

SEP = 2

ITEM = fossil touch ?
S: cd %PD
R: %I {} "TOUCH" { \
   fil1 {{   File(s):}} {"$::EM_T_FILE"} \
   opc1 {{Time stamp:}} {{$::EM_T_TIME} {--now --checkin --checkout}} \
   v_ {{} {-pady 4}} {} \
   chb1 {{   Dry run:}} {$::EM_T_DRY} \
   chb2 {{   Verbose:}} {$::EM_T_VERBOSE} \
   v_2 {{} {-pady 4}} {} seh {} {} \
   texc {{Hint:} {} {-h 10 -w 64 -ro 1 -wrap word}} \
   {\n The file(s) mtime will be updated to the 'Time stamp'. \
\n\n The 'File(s)' may be globs. Set '-g' before a comma-separated \
\n list of glob patterns, for example: -g *,src/*,menus/*. \
\n\n The 'Dry run' shows the supposed changes, not doing actually. \
\n\n The 'Verbose' outputs extra information.} \
   } -head {\n This will TOUCH the file(s) of Fossil repository \
   \n to have the file(s) time equal to the time stamp. \n} \
   -hfg $::em::clrhotk -weight bold == \
   ::EM_T_FILE ::EM_T_TIME ::EM_T_DRY ::EM_T_VERBOSE
S: %C if $::EM_T_DRY {set ::EM_T_n -n} {set ::EM_T_n ""}
S: %C if $::EM_T_VERBOSE {set ::EM_T_v -v} {set ::EM_T_v ""}
S: fossil touch $::EM_T_n $::EM_T_v $::EM_T_TIME $::EM_T_FILE
