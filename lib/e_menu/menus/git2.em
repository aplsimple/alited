[OPTIONS]


# git directory #2
x1=plugins
x2=: add_shortcut, e_menu
om=1
in=1.0
w=40

[MENU]

 ; git menu for e_menu.tcl

ITEM = git status
S: cd %PD
S: echo %PD\ndir\necho ---\ngit status

ITEM = git gui
RE: cd %PD
RE: git gui

SEP = 5

ITEM = git pull
S: cd %PD
R: %q "Pulling changes" "Pull changes in\n\na remote repository\n\nto %PD ?"
S: git pull

ITEM = git push
S: cd %PD
R: %q "Pushing changes" "Push all changes in\n\n%PD\n\nto a remote repository ?"
S: git push

SEP = 5

ITEM = git add *
S: cd %PD
R: %q "Adding changes" "Add all changes in\n\n%PD\n\nto a local repository ?"
S: git add *\ngit status

ITEM = git merge
S: cd %PD
R: %q "Merging changes" "Merge changes in\n\n  %PD ?"
S: git merge

ITEM = git commit "Empty commit"
S: cd %PD
R: %q "Empty commit" "This will make an empty commit\n(sometimes fixing the last push)."
S: git commit --allow-empty -m Empty

ITEM = git commit --amend
S: cd %PD
R: %q "Amending commit" "Amend the last commit\nwith message to be edited ?"
S: git commit --amend

SEP = 5

ITEM = git log -p "1 hour ago"
S: cd %PD
S: git log -p "--since=1 hour ago"

ITEM = git log -p "1 day ago"
S: cd %PD
S: git log -p "--since=1 day ago"

ITEM = git log --since="1 week ago"
S: cd %PD
S: git log "--since=1 week ago"

ITEM = git log
S: cd %PD
S: git log

ITEM = git branch
S: cd %PD
S: git branch

ITEM = git diff master..%s
S: cd %PD
S: git diff master..%s

SEP = 5

ITEM = git init
S: cd %PD
R: %q "INIT" "This will initialize GIT in:\n%PD"
S: git init

SEP = 5

ITEM = edit .gitignore
RE: %E %PD/.gitignore

ITEM = edit ~/.gitconfig
RE: %E %H/.gitconfig
