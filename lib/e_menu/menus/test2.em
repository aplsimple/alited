[OPTIONS]

in=1.0
om=1
c=45
pos=26.4

[MENU]

  * //test2.mnu//:

ITEM = echo %%s is %s
SW: echo %%s is %s

ITEM = echo %%PD is %PD
SW: echo %%PD is %PD

ITEM = git init
R: %q "Init GIT" "Are you sure to init git in\n\n%PD ?"
R: cd %PD
S: git init

ITEM = git status
R: cd %PD
S: git status

ITEM = git gui
R: cd %PD
R: git gui

ITEM = git add *
R: cd %PD
S: git add *

ITEM = git commit -am '%s'
R: %q "Committing changes" "Do you really want to commit with message\n'%s' ?"
R: cd %PD
S: git commit -am "%s"
