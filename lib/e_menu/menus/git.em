[OPTIONS]

o=-1
in=1.0
pos=56.8
w=35
::EMENUTMPFILE=%mn.tmp~
%C if {![info exist ::EMENUCOMMIT]} {set ::EMENUCOMMIT ""}
%C if {![info exist ::EMENUFILE]} {set ::EMENUFILE "%f" ; if {[::iswindows]} {set ::EMENUFILE [string map [list \\ \\\\\\\\] "%f"]}}
%C if {![info exist ::EMENUGREP]} {set ::EMENUGREP ""}
%C if {{%F}=={*} && ![info exist ::EMENUFILE]} {set ::EMENUFILE "*"}
%C set ::EMENUFILETAIL [file tail {$::EMENUFILE}]
%C set ::FILETAIL {"$::EMENUFILETAIL"}

[MENU]

 ; git menu for e_menu.tcl

ITEM = git status
R: cd %PD
S: pwd\necho %PD\ngit status

ITEM = git gui
R: cd %PD
R: git gui

ITEM = gitk
R: cd %PD
R: gitk

SEP = 2

ITEM = git difftool $::FILETAIL ?
R: cd %PD
RW: git log --format=oneline -99 > $::EMENUTMPFILE
R: %I {} "DIFFTOOL" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{   File:} {} {-w 70}} {"$::EMENUFILE"} \
   fco1 {{Version:} {} {-h 10 -state readonly -retpos 0:10 -inpval "$::EMENUCOMMIT"}} \
     {@@-pos 0 -len 10 $::EMENUTMPFILE@@    INFO: @@-div1 { } $::EMENUTMPFILE@@} \
   seh {{} {-pady 3} {}} {} \
   texc {{   Hint:} {} {-h 9 -w 70 -ro 1 -wrap word}} \
   {\n Select a version from the combobox to be compared to HEAD.\n\n If it's blank, the current file is compared to HEAD.\n\n No response means no differences.\n\n (temp file: $::EMENUTMPFILE)} \
   } -head {\n This will compare a selected version of a file to its HEAD.} -weight bold == ::EMENUFILE ::EMENUCOMMIT
R: git difftool $::EMENUCOMMIT HEAD -- "$::EMENUFILE"

ITEM = git diff
S: cd %PD
RW: git log --format=oneline -99 > $::EMENUTMPFILE
R: %I {} "DIFF" { \
   v_ {{} {-pady 4} {}} {} \
   fco1 {{     Version :} {} {-h 10 -state readonly -retpos 0:10 -inpval "$::EMENUCOMMIT"}} \
     {@@-pos 0 -len 10 -list {""} $::EMENUTMPFILE@@    INFO: @@-div1 { } $::EMENUTMPFILE@@} \
   ent1 {{Regexp filter:} {} {}} {"$::EMENUGREP"} \
   seh {{} {-pady 3} {}} {} \
   texc {{        Hint :} {} {-h 9 -w 60 -ro 1 -wrap word}} \
   { Select a version from the combobox to be compared to HEAD.\
\n\n If it's blank, the current files are compared to HEAD.\
\n\n When 'regexp filter' set, an additional console shows\
\n the filtered lines.\
\n\n temp file:\n $::EMENUTMPFILE} \
   } -head {\n This will compare a selected version of \
     \n %PD\n to its HEAD.} -focus butOK -weight bold == ::EMENUCOMMIT ::EMENUGREP
S: %C set ::EMENUTMP {git diff $::EMENUCOMMIT HEAD}
R: %IF {$::EMENUGREP} eq "" %THEN %T $::EMENUTMP
RW: $::EMENUTMP | grep -n "$::EMENUGREP" > "$::EMENUTMPFILE"
SW: cat "$::EMENUTMPFILE"
R: %C file delete "$::EMENUTMPFILE"
S: $::EMENUTMP

ITEM = git add $::FILETAIL ?
S: cd %PD
R: %I {} "ADD" { \
   fil1 {{   File:} {} {-w 70}} {"$::EMENUFILE"} \
   } -head {\n This will add changes in a file\n to a local repository:} -weight bold == ::EMENUFILE
S: git add "$::EMENUFILE"

ITEM = git add *
S: cd %PD
R: %q "Adding changes" " Add all changes in\n\n  %PD\n\n to a local repository ?"
S: git add *\ngit status

ITEM = git rm $::FILETAIL ?
S: cd %PD
R: %I {} "REMOVE" { \
   fil1 {{   File:} {} {-w 70}} {"$::EMENUFILE"} \
   } -head {\n This will remove a file\n from a local repository:} -weight bold == ::EMENUFILE
S: git rm --cached "$::EMENUFILE"\ngit status

SEP = 2

ITEM = git commit
S: cd %PD
R: %q "Committing changes" " Commit with message to be edited ?"
S: git commit

ITEM = git commit -am "%s on %t2"
S: cd %PD
R: %q "Committing changes" " Add and commit with message\n\n '%s at %t2' ?"
S: git commit -am "%s on %t2"

ITEM = git commit --amend -am
S: cd %PD
S: %C if {![info exist ::EMENUCOMMIT3]} {set ::EMENUCOMMIT3 "%s %t1 #%i1"}
R: %I {} "COMMIT AMEND" { \
   v_ {{} {-pady 4} {}} {} \
   texc {{Comment:} {} {-h 9 -w 70 -wrap word}} {$::EMENUCOMMIT3} \
   } -head {\n Enter the commenting text for the commit.} -weight bold == ::EMENUCOMMIT3
R: %C if {"$::EMENUCOMMIT3" eq ""} exit
S: git commit --amend -am "$::EMENUCOMMIT3"

ITEM = git commit -a
S: cd %PD
R: %q "Add All and Commit Changes" " Add all changes\n and commit with message to be edited ?"
S: git commit -a

SEP = 2

ITEM = git log "1 hour ago"
S: cd %PD
S: git log --since="1 hour ago"

ITEM = git log "1 day ago"
S: cd %PD
S: git log --since="1 day ago"

ITEM = git log -p "1 hour ago"
S: cd %PD
S: git log -p --since="1 hour ago"

ITEM = git log -p "1 day ago"
S: cd %PD
S: git log -p --since="1 day ago"

ITEM = git log
S: cd %PD
S: git log

ITEM = git log --merges
S: cd %PD
S: git log --merges

SEP = 2

ITEM = git branch
S: cd %PD
S: git branch

ITEM = git branch "%s"
S: cd %PD
R: %q "Branch" " Create new branch\n\n '%s' ?"
S: git branch -f "%s"

ITEM = git checkout "%s"
S: cd %PD
R: %q "Checkout" " Checkout to\n\n '%s' ?"
S: git checkout "%s"

SEP = 2

ITEM = terminal here
R: cd %d
R: %TT

SEP = 2

ITEM = Next
M: m=git2.em
