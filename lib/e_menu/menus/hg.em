[OPTIONS]

o=-1
in=1.0
pos=69.64

[MENU]

; hg menu for e_menu.tcl

ITEM = hg summary -- hg status
R: cd %PD
S: echo %UD\nhg summary\necho ---------------\nhg status

ITEM = hg heads -- hg parents
R: cd %PD
S: echo %UD\nhg heads\necho ---------------\nhg parents

ITEM = hg commit
S: cd %PD
SW: hg status
R: %q "Committing changes" "This will COMMIT with input message in:\n\n%UD"
S: hg commit

SEP = 2

ITEM = tortoisehg - thg
R: cd %PD
R: thg

ITEM = kdiff3 of %F
R: cd %PD
R: %C if {![info exist ::FIL1] || "$::FIL1" eq ""} {set ::FIL1 "%f"}
R: %I ques "KDIFF3" {filName {{File:} {} {-w 60}} {"$::FIL1"} lab} -head "\n Enter/choose a file to kdiff3" -weight bold == ::FIL1
R: hg extdiff -p kdiff3 "$::FIL1"

ITEM = hg diff
R: cd %PD
S: hg diff

ITEM = hg extdiff %F
R: cd %d
R: %C if {![info exist ::REV]}  {set ::REV -1}
R: %C if {![info exist ::FIL]}  {set ::FIL "%f"}
R: \
  %I "" "DIFFERENCES" { \
  v_0  {{} {-pady 7} {}} {} \
  ent1    {{Revision: } {} {}} {"$::REV"} \
  filName {{ of file: } {} {-w 65}} {"$::FIL"} \
  v_1  {{} {-pady 7} {}} {} seh {{} {} {}} {} v_2 {{} {} {}} {} \
  texc {{hg help:  } {} {-h 4 -w 52 -ro 1}} {A plain integer is treated \
as a revision number.\nNegative integers are treated as sequential offsets from the \
tip, with -1 denoting the tip, -2 denoting the revision prior to the tip, and so forth.} \
  } -head "\n Enter a revision (a prior commit's number):" -weight bold == ::REV ::FIL
R: hg extdiff -r $::REV -p meld $::FIL

ITEM = hg annotate %F
R: cd %PD
R: %C if {![info exist ::FIL1] || "$::FIL1" eq ""} {set ::FIL1 "%f"}
R: %I ques "ANNOTATE" {filName {{File:} {} {-w 60}} {"$::FIL1"} lab} -head "\n Enter/choose a file to annotate" -weight bold == ::FIL1
S: hg annotate '$::FIL1'

ITEM = hg log -l 10 -v
R: cd %PD
S: hg log -l 10 -v

ITEM = hg log -p -l 2 %F
R: cd %PD
R: %C if {![info exist ::FIL1] || "$::FIL1" eq ""} {set ::FIL1 "%f"}
R: %I ques "LOG" {filName {{File(s):} {} {-w 60}} {"$::FIL1"} lab} -head "\n Enter/choose file(s) to view log patches\n (quote 'a name' if it has spaces)" -weight bold == ::FIL1
S: hg log -p -l 2 $::FIL1

ITEM = hg revert
R: cd %PD
R: %q "REVERT ALL" "This will REVERT ALL changes in\n\n%UD" yesno warn NO
R: %I warn "REVERT ALL" {lab} \
   -head "\n This will REVERT ALL changes in   \n\n %UD " -hfg ::em::clrhot -weight bold
S: hg revert -a -C

ITEM = hg revert %F
R: cd %PD
R: %C if {![info exist ::FIL1] || "$::FIL1" eq ""} {set ::FIL1 "%f"}
R: %I warn "REVERT" {filName {{File(s):} {} {-w 60}} {"$::FIL1"} lab} -head "\n Enter/choose file(s) to revert\n (quote 'a name' if it has spaces)" -hfg ::em::clrhot -weight bold == ::FIL1
R: %I warn "REVERT $::FIL1" {lab} \
   -head "\n This will REVERT ALL changes of   \n\n $::FIL1 " -hfg ::em::clrhot -weight bold
S: hg revert $::FIL1

ITEM = hg rollback
R: %q "ROLLBACK" "This will ROLL BACK the last commit in\n\n%UD" yesno warn NO
R: %I warn "ROLLBACK" {lab} \
   -head "\n This will ROLL BACK the last commit in   \n\n %UD " -hfg ::em::clrhot -weight bold
R: cd %PD
S: hg rollback

ITEM = hg commit --amend
R: %q "AMEND COMMIT" "This will AMEND the last commit in\n\n%UD"
R: cd %PD
S: hg commit --amend

SEP = 2

ITEM = hg incoming
R: cd %PD
S: hg incoming

ITEM = hg fetch
R: %q "FETCH" "This will PULL, MERGE and COMMIT changes into:\n\n%UD"
R: cd %PD
S: hg fetch

ITEM = hg pull
R: %q "PULL" "This will PULL changes into:\n\n%UD"
R: cd %PD
S: hg pull

ITEM = hg update
R: %q "UPDATE" "This will UPDATE to the tip changeset in:\n\n%UD"
R: cd %PD
S: hg update

ITEM = hg merge -P
R: %q "MERGE PREVIEW" "This will PREVIEW the merge in:\n\n%UD"
R: cd %PD
S: hg merge -P

ITEM = hg merge
R: %q "MERGE" "This will MERGE changes in:\n\n%UD"
R: cd %PD
S: hg merge
R: %q "COMMIT" "This will COMMIT with message:\n\nMerge on %t2"
S: hg commit -m "Merge on %t2"

SEP = 2

ITEM = hg outgoing
R: cd %PD
S: hg outgoing

ITEM = hg push
S: cd %PD
R: %C if {![info exist ::FPUSH]} {set ::FPUSH 0}
R: %I warn "FORCED PUSH" {chb {{Forced push:} {} {}} {$::FPUSH}} -head "You can set the forced push from \n    %UD \
  \n\nNote: \
  \n     Extra care should be taken with the -f/--force option, which will push \
  \n     all new heads on all branches, an action which will almost always cause \
  \n     confusion for collaborators.\n" -weight bold == ::FPUSH
R: %C if {$::FPUSH} {set ::FORCEDPUSH -f} {set ::FORCEDPUSH ""}
S: hg push $::FORCEDPUSH

SEP = 2

ITEM = Next
M: m=hg2.em

SEP = 2

ITEM = F1 hg help
S: cd %PD
S: %#t hg help

ITEM = hg init (in %PD)
R: %Q "MERCURIAL INIT" "Initialize the new Mercurial repository in\n\n%UD?"
R: cd %PD
R: %P echo "syntax: glob\n.*\n*~\n*.swp\n*.tmp\n*.bak\n*.log\n*.zip\n*.rar\n*.tgz\n*.cur\n*.dll\n*.dylib\n*.ico\n*.gif\n*.bmp\n*.png\n*.jpg\n*.o" > %UD/.hgignore
S: dir\necho ------------\nhg init\nhg status
ITEM = edit ~/.hgrc
R: %P %E $::env(HOME)/.hgrc
ITEM = edit .hgignore
R: %E %PD/.hgignore

[DATA]

%#t geo=839x637+200+126;pos=4.21 # hg help [topic]  - show help for a given topic or a help overview|!||!|hg help --verb forget|!|hg help --verb revert|!||!||!|############################################################################|!|# select topics from the list:|!||!|# add           add the specified files on the next commit|!|# addremove     add all new files, delete all missing files|!|# annotate      show changeset information by line for each file|!|# archive       create an unversioned archive of a repository revision|!|# backout       reverse effect of earlier changeset|!|# bisect        subdivision search of changesets|!|# bookmarks     create a new bookmark or list existing bookmarks|!|# branch        set or show the current branch name|!|# branches      list repository named branches|!|# bundle        create a changegroup file|!|# cat           output the current or given revision of files|!|# clone         make a copy of an existing repository|!|# commit        commit the specified files or all outstanding changes|!|# config        show combined config settings from all hgrc files|!|# copy          mark files as copied for the next commit|!|# diff          diff repository (or selected files)|!|# export        dump the header and diffs for one or more changesets|!|# files         list tracked files|!|# forget        forget the specified files on the next commit|!|# graft         copy changes from other branches onto the current branch|!|# grep          search revision history for a pattern in specified files|!|# heads         show branch heads|!|# help          show help for a given topic or a help overview|!|# identify      identify the working directory or specified revision|!|# import        import an ordered set of patches|!|# incoming      show new changesets found in source|!|# init          create a new repository in the given directory|!|# log           show revision history of entire repository or files|!|# manifest      output the current or given revision of the project manifest|!|# merge         merge another revision into working directory|!|# outgoing      show changesets not found in the destination|!|# paths         show aliases for remote repositories|!|# phase         set or show the current phase name|!|# pull          pull changes from the specified source|!|# push          push changes to the specified destination|!|# recover       roll back an interrupted transaction|!|# remove        remove the specified files on the next commit|!|# rename        rename files; equivalent of copy + remove|!|# resolve       redo merges or set/view the merge status of files|!|# revert        restore files to their checkout state|!|# root          print the root (top) of the current working directory|!|# serve         start stand-alone webserver|!|# status        show changed files in the working directory|!|# summary       summarize working directory state|!|# tag           add one or more tags for the current or given revision|!|# tags          list repository tags|!|# unbundle      apply one or more changegroup files|!|# update        update working directory (or switch revisions)|!|# verify        verify the integrity of the repository|!|# version       output version and copyright information|!||!|############################################################################
