[OPTIONS]

w=40
in=1.0
pos=142.0
::FSLUSER=aplsimple
::FSLBRANCH=tip
::FSLBRANCHCOLOR=#004000
::EMENUTMPFILE=%mn.tmp~
::EM_T_FILE=-g *,src/*,menus/*,lib/*
::EM_T_TIME=none
::EM_T_DRY=1
::EM_T_VERBOSE=1
::EMENUBRIEF=0
::EMENUGREP=
%C set ::EMENUPRJ [file tail {%PD}]
%C if {![info exist ::EMENUCOMMIT]} {set ::EMENUCOMMIT ""}
%C if {![info exist ::EMENUCOMMIT1]} {set ::EMENUCOMMIT1 tip}
%C if {![info exist ::EMENUCOMMIT2]} {set ::EMENUCOMMIT2 ""}

[MENU]

ITEM = fossil pull
S: cd %PD
R: %C set ::FSLREPO "%PN"
R: %C if {![info exist ::FSLPASS]} {set ::FSLPASS ""}
R: \
  %I "" "FOSSIL PULL" { \
  v_0  {{} {-pady 7} {}} {} \
  ent0 {{User name : } {-fill none -anchor w} {-w 20}} {"$::FSLUSER"} \
  ent1 {{Password  : } {-fill none -anchor w} {-w 20 -show *}} {"$::FSLPASS"} \
  v_1  {{} {-pady 7} {}} {} \
  ent2 {{Repository: } {-fill none -anchor w} {-w 20}} {"$::FSLREPO"} \
  v_2  {{} {-pady 7} {}} {} seh {{} {} {}} {} \
  texc {{For example:} {} {-h 8 -w 52 -ro 1}} \
  {\n If\n   User name : Bill\n   Repository: MS\n\n the changes would be pulled from \
  \n   https://chiselapp.com/user/Bill/repository/MS} \
  } -head {\nPULL changes from https://chiselapp.com to a fossil repository.} -weight bold \
  == ::FSLUSER ::FSLPASS ::FSLREPO
SW: fossil pull \
   https://$::FSLUSER:$::FSLPASS@chiselapp.com/user/$::FSLUSER/repository/$::FSLREPO

ITEM = fossil push
S: cd %PD
R: %C set ::FSLREPO "%PN"
R: %C if {![info exist ::FSLPASS]} {set ::FSLPASS ""}
R: \
  %I "" "FOSSIL PUSH" { \
  v_0  {{} {-pady 7} {}} {} \
  ent0 {{User name : } {-fill none -anchor w} {-w 20}} {"$::FSLUSER"} \
  ent1 {{Password  : } {-fill none -anchor w} {-w 20 -show *}} {"$::FSLPASS"} \
  v_1  {{} {-pady 7} {}} {} \
  ent2 {{Repository: } {-fill none -anchor w} {-w 20}} {"$::FSLREPO"} \
  v_2  {{} {-pady 7} {}} {} seh {{} {} {}} {} \
  texc {{For example:} {} {-h 8 -w 52 -ro 1}} \
  {\n If\n   User name : Bill\n   Repository: MS\n\n the changes would be pushed to \
  \n   https://chiselapp.com/user/Bill/repository/MS} \
  } -head {\nPUSH changes from a fossil repository to https://chiselapp.com.} -weight bold \
  == ::FSLUSER ::FSLPASS ::FSLREPO
SW: fossil push \
   https://$::FSLUSER:$::FSLPASS@chiselapp.com/user/$::FSLUSER/repository/$::FSLREPO

ITEM = fossil ui
R: cd %PD
R: fossil ui

SEP = 2

ITEM = fossil uv sync
S: cd %PD/.BIN
R: %C if [file exist 4uvadd] {set ::FORUV { .BIN/4uvadd}} {set ::FORUV {}}
R: %q "UNVERSIONED FILES" " DO\n\n    fossil uv add * \
   \n    fossil uv sync\n\n for ALL$::FORUV files of\n\n    %PD/.BIN?"
SW: if test -f ./4uvadd ; then ./4uvadd ; else fossil uv add * ; fi \
  \nfossil uv ls\necho ---------------------------\necho Press Return to run UV SYNC \
  \nread\nfossil uv sync

ITEM = fossil uv sync %F
S: cd %PD/.BIN
R: %q "UNVERSIONED FILE" " DO\n\n    fossil uv add %F \
   \n    fossil uv sync\n\n ( for .BIN/%F ) ?"
SW: fossil uv add %F\nfossil uv sync

ITEM = fossil config pull shun
S: cd %PD
R: %C if {![info exist ::FSLREPO]}  {set ::FSLREPO %PN; set ::FSLPASS ""}
R: \
  %I "" "PULL SHUNS" { \
  v_0  {{} {-pady 7} {}} {} \
  ent0 {{User name : } {-fill none -anchor w} {-w 20}} {"$::FSLUSER"} \
  ent1 {{Password  : } {-fill none -anchor w} {-w 20 -show *}} {"$::FSLPASS"} \
  v_1  {{} {-pady 7} {}} {} \
  ent2 {{Repository: } {-fill none -anchor w} {-w 20}} {"$::FSLREPO"} \
  v_2  {{} {-pady 7} {}} {} seh {{} {} {}} {} \
  texc {{For example:} {} {-h 8 -w 52 -ro 1}} \
  {\n If\n   User name : Bill\n   Repository: MS\n\n the shunning list would be pulled from \
  \n   https://chiselapp.com/user/Bill/repository/MS\n} \
  } -head "\nPULL shuns from https://chiselapp.com to a fossil repository." -weight bold \
  == ::FSLUSER ::FSLPASS ::FSLREPO
SW: fossil configuration pull shun \
   https://$::FSLUSER:$::FSLPASS@chiselapp.com/user/$::FSLUSER/repository/$::FSLREPO

SEP = 2

ITEM = fossil checkout
S: cd %PD
RW: fossil tim -t ci -n 9999 > $::EMENUTMPFILE
R: %I {} "CHECKOUT" { \
   fco1 {{Version / branch / tag :} {} {-h 10 -state readonly -cbxsel "$::FSLBRANCH"}} \
     {@@-div1 "\[" -div2 "\]" -ret 1 -list {"" tip} $::EMENUTMPFILE@@ \
     INFO: @@-div1 "\] " $::EMENUTMPFILE@@} \
   butF {{Run 'fossil ui'        :} {} {-w 10 -com {exec fossil ui &}}} {{Fossil UI}} \
   v_ {{} {-pady 7} {}} {} seh {{} {} {}} {} \
   texc {{Hint:} {} {-h 10 -w 70 -ro 1 -wrap word}} \
   {\n The VERSION can be the name of a branch or tag or any abbreviation\n to the 40-character artifact ID for a check-in. \
\n\n The VERSION can be a date/time stamp, for example:\n YYYY-MM-DD, HH:MM:SS, 'YYYY-MM-DD HH:MM:SS'). \
\n\n CHECKOUT does not merge local changes,\n it prefers to overwrite them and fails if local changes exist.\n} \
   } -head {\n This will CHECKOUT a version / branch / tag \n in "$::EMENUPRJ" repository.\n} -weight bold == ::FSLBRANCH
S: fossil co --setmtime "$::FSLBRANCH"

ITEM = fossil merge
S: cd %PD
RW: fossil tim -t ci -n 99 > $::EMENUTMPFILE
R: %I warn "MERGE" { \
   fco1 {{Version / branch / tag :} {} {-h 10 -w 45 -state readonly -cbxsel "$::FSLBRANCH"}} \
     {@@-div1 "\[" -div2 "\]" -ret 1 -list {"" tip} $::EMENUTMPFILE@@ \
     INFO: @@-div1 "\] " $::EMENUTMPFILE@@} \
   butF {{Run 'fossil ui'        :} {} {-w 10 -com {exec fossil ui &}}} {{Fossil UI}} \
   v_} -head {\n This will MERGE changes from a branch in "$::EMENUPRJ" repository, \
   \n then commits (you may undo the commit afterwards). \n} -weight bold == ::FSLBRANCH
S: fossil merge "$::FSLBRANCH"\nfossil commit

ITEM = fossil update
S: cd %PD
R: %C  if {![info exist ::FSLUPD]}  {set ::FSLUPD ""}
RW: fossil tim -t ci -n 99 > $::EMENUTMPFILE
R: %I {} "UPDATE" { \
   fco1 {{Version / branch / tag :} {} {-h 10 -state readonly -cbxsel "$::FSLUPD"}} \
     {@@-div1 "\[" -div2 "\]" -ret 1 -list {"" tip} $::EMENUTMPFILE@@ \
     INFO: @@-div1 "\] " $::EMENUTMPFILE@@} \
   butF {{Run 'fossil ui'        :} {} {-w 10 -com {exec fossil ui &}}} {{Fossil UI}} \
   v_ {{} {-pady 7} {}} {} seh {{} {} {}} {} \
   texc {{Hint:} {} {-h 10 -w 70 -ro 1 -wrap word}} \
   {\n VERSION can be 'trunk' to move to the trunk branch. \
\n\n If you omit the VERSION, fossil moves you to the latest version\n of the branch your are currently on. \
\n\n VERSION can be 'tip' to select the most recent check-in. \
\n\n Any uncommitted changes are retained and applied to the new checkout.\n} \
  } -head {\n This will UPDATE to a version / branch / tag. \n in "$::EMENUPRJ" repository\n} -weight bold == ::FSLUPD
S: fossil update "$::FSLUPD"

ITEM = fossil revert
S: cd %PD
R: %q "REVERT ALL" \
   { Revert ALL changes in "$::EMENUPRJ" repository?\n\n This restores a last check-in in the repository.} yesno warn NO
S: fossil revert

ITEM = fossil undo
R: cd %PD
SW: fossil undo -n
R: %q "UNDO ALL" { Undo ALL changes in "$::EMENUPRJ" repository? \
   \n\n This cancels results of prior operations, notably \
   \n of 'update', 'merge', stash', 'revert'.} yesno warn NO
S: fossil undo

SEP = 2

ITEM = 2DOC
S: cd %PD/.BIN
R: %q "COMMIT DOC SOURCES" \
   " This will commit DOC sources in:  \
   \n\n   %PD\n\nSee details at: \
   \n\n   https://chiselapp.com/user/aplsimple/repository/HOWTO_chisel" yesno warn NO
S: ./4files\n./2DOC

ITEM = 2trunk
S: cd %PD/.BIN
R: %q "COMMIT DOC GENERATED" \
   " This will commit GENERATED docs in:  \
   \n\n   %PD\n\nSee details at: \
   \n\n   https://chiselapp.com/user/aplsimple/repository/HOWTO_chisel" yesno warn NO
S: ./2trunk

SEP = 2

ITEM = fossil init ~/FOSSIL/%PN.fossil
S: cd %PD
R: %q "FOSSIL INIT" {Initialize the fossil repository \
   \n   %H/FOSSIL/%PN.fossil\nin\n   %PD?}
S: mkdir %H/FOSSIL\necho ------------\nfossil init %H/FOSSIL/%PN.fossil\nfossil open %H/FOSSIL/%PN.fossil\nfossil status

ITEM = fossil settings
S: cd %PD
S: fossil settings

ITEM = set standard settings of fossil (ignore etc.)
S: cd %PD
R: %q "Settings" " Set in \
  \n    %PD\n the standard settings of fossil? \
  \n __________________________________ \
  \n \
  \n NOTE: Consider the installation of\n    meld\n    colordiff\n    nano" yesno warn NO
S: fossil settings diff-command 'colordiff -wu'; fossil settings ignore-glob ".*,*~,*.swp,*.tmp,*.bak,*.log,*.backup,*.*~0" ; fossil settings crnl-glob '*' ; fossil settings encoding-glob '*' ; fossil settings autosync 0 ; fossil settings gdiff meld ; fossil settings editor nano ; fossil settings binary-glob 1 ; if test -f .BIN/4init ; then .BIN/4init ; fi ; fossil settings

ITEM = fossil all list
S: cd %PD
S: fossil all list

SEP = 2
ITEM = fossil status %PD
S: cd %PD
S: echo %PD\ndir\necho ---\nfossil status

ITEM = fossil addremove
S: cd %PD
R: %I {} "ADDREMOVE" { \
   chb1 {{Dry run:} {-anchor w -fill none} {-w 3}} {$::EM_T_DRY} \
   v_2 {{} {-pady 4}} {} seh {} {} \
   texc {{   Hint:} {} {-h 11 -w 73 -ro 1 -wrap word}} \
   {\n *  All files in the checkout but not in the repository (that is,\
\n    all files displayed using the 'extras' command) are added as\
\n    if by the 'add' command.\
\n\n *  All files in the repository but missing from the checkout (that is,\
\n    all files that show as MISSING with the 'status' command) are\
\n    removed as if by the 'rm' command.\
\n\n The 'Dry run' shows the supposed changes, not doing actually.} \
   } -head {\n This will ADD the new and REMOVE the deleted\n file(s) of "$::EMENUPRJ" repository. \n} -weight bold == ::EM_T_DRY
S: %C if $::EM_T_DRY {set ::EM_T_n -n} {set ::EM_T_n ""}
S: fossil addremove $::EM_T_n

ITEM = fossil touch
S: cd %PD
R: %I {} "TOUCH" { \
   fil1 {{   File(s):}} {"$::EM_T_FILE"} \
   opc1 {{Time stamp:} {-anchor w -fill none} {-w 20}} {{$::EM_T_TIME} {--now --checkin --checkout}} \
   v_ {{} {-pady 4}} {} \
   chb1 {{   Dry run:} {-anchor w -fill none} {-w 3}} {$::EM_T_DRY} \
   chb2 {{   Verbose:} {-anchor w -fill none} {-w 3}} {$::EM_T_VERBOSE} \
   v_2 {{} {-pady 4}} {} seh {} {} \
   texc {{Hint:} {} {-h 10 -w 64 -ro 1 -wrap word}} \
   {\n The file(s) mtime will be updated to the 'Time stamp'. \
\n\n The 'File(s)' may be globs. Set '-g' before a comma-separated \
\n list of glob patterns, for example: -g *,src/*,menus/*. \
\n\n The 'Dry run' shows the supposed changes, not doing actually. \
\n\n The 'Verbose' outputs extra information.} \
   } -head {\n This will TOUCH the file(s) of "$::EMENUPRJ" repository\n to have the file(s) time equal to the time stamp. \n} -weight bold == ::EM_T_FILE ::EM_T_TIME ::EM_T_DRY ::EM_T_VERBOSE
S: %C if $::EM_T_DRY {set ::EM_T_n -n} {set ::EM_T_n ""}
S: %C if $::EM_T_VERBOSE {set ::EM_T_v -v} {set ::EM_T_v ""}
S: fossil touch $::EM_T_n $::EM_T_v $::EM_T_TIME $::EM_T_FILE

ITEM = terminal here
R: cd %d
R: %TT
