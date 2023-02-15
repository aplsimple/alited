#
# A menu can contain the following sections:
#
#   [OPTIONS]
#   [MENU]
#   [HIDDEN]
#   [DATA]
#
################################################################################
#
# [OPTIONS] section can include e_menu's options and values of global variables.
#
# The global variables are set as follows (note "::" before names) :
#   ::varname1=varvalue1
#   ::varname2=varvalue2
# The variables are used in names and commands of menu items. They are saved
# in menu files for next sessions.
#
# Any line can be ended with "\" meaning its continuation in a next line.
#
################################################################################
#
# [MENU] section is main. It contains menu items and separators as follows:
#
#   ITEM = item's title
#     R:  a command to run (without waiting its completion)
#     RW: a command to run (with waiting its completion)
#     RE: a command to run (e_menu exits)
#     S:  a command to run in a console (without waiting its completion)
#     SW: a command to run in a console (with waiting its completion)
#     SE: a command to run in a console (e_menu exits)
#     M:  m=menuname ?options? (menu is open, without waiting its closing)
#     MW: m=menuname ?options? (menu is open, with waiting its closing)
#     ME: m=menuname ?options? (menu is open, e_menu exits)
#   SEP=3 (separator, 3 is "height")
#
# The R: lines can be started with %C wildcard meaning the rest is Tcl code.
# The line of code is firstly [subst]-ed, then executed.
#
# The following line
#   R: %IF condition %THEN com1 %ELSE com2
# means that "condition" is evaluated as Tcl code and if it's true,
# "com1" is executed as OS command; otherwise "com2" will be executed.
#
# There may be macros ("procedures"), for items of similar structure.
# The macro is declared by its name + arguments, then lines of its contents:
#   %ML TITLE %ML ARG1 %ML ARG2 %ML ARG3 ...  (title and arguments)
#   %ML S: cd $ARG1
#   %ML R: %C if {$ARG2} {set ::EMENUFIND "$TITLE"}
#   %ML ...
# where ML is a name of macro, it can be M + any letter (a..z,A..Z)
# See example of %MA macro below.
#
# The following line
#   R: %I ...
# declares apave dialogue.
# Details are in apave documentation available at:
#   https://aplsimple.github.io/en/tcl/pave
#
################################################################################
#
# [HIDDEN] section can contain the same as [MENU], but its items aren't visible
# in e_menu window. Their hotkeys (1,2...) can be used in ah= option of e_menu.
#
################################################################################
#
# [DATA] section is for internal use by e_menu, for items declared as follows:
#   ITEM = %#L item name
# where %#L can be %# + any letter (a..z,A..Z)
#
# This means that shell commands would be viewed and at need edited,
# before running them in the terminal.
#
################################################################################
#
# Use the lines below as templates at editing your menus.
# You can use the whole template as menu contents, just to view how it works.
#
################################################################################

[OPTIONS]

in=8.0
bd=1
w=25
pos=117.3

# for grep
::EMENUFILES=--include=*.tcl --include=*.mnu --include=*.txt --include=*.htm* --include=*.md* --exclude-dir=.* --exclude-dir=*BAK* --exclude-dir=*TMP*
::EMENUDIR=%d

# for test
::EN1=%s
::EN2==== !!!
::V1=RE
::C1=1
::C2=1
::W1=in file
::W1LIST={in file} {in directory} {in session}
::OPT=opc widget example
::LBX=my Father
::TBL=\{cbx fco\} ttk::combobox 23 2
::TEX=and	tabs\nentered with copy-paste\n1234\n\nsome multi-line text			123

# ________________________ menu's content _________________________ #

[MENU]

## ________________________ run me _________________________ ##

ITEM = F4 Run me {+ %s}
R: cd %d
R: %C if {"%f" eq {}} {set ::EMENURUNFILE ""} {set ::EMENURUNFILE "%f"}
R: %C set ::_EM_AR_ [string map {\\$ \$} {%AR}]
R: %C set ::_EM_RF_ [string map {\\$ \$} {%RF}]
R: %C set ::_EM_EE_ [string map {\\$ \$} {%EE}]
SE: %IF {%EE}!="" %THEN $::_EM_EE_
RE: %IF "%x"==".tcl" && {%RF} ne "" %THEN %T tclsh $::_EM_RF_
RE: %IF "%x"==".tcl" %THEN %T tclsh "$::EMENURUNFILE" $::_EM_AR_
RE: %IF "%x"==".py"  %THEN %t python3 "$::EMENURUNFILE" %AR
SE: %IF {%RF}!="" %THEN %RF
RE: %IF {%AR}=="" && ![::iswindows] %THEN %O "$::EMENURUNFILE"
RE: "$::EMENURUNFILE" %AR

## ________________________ macro & grep _________________________ ##

SEP = 2

%MA TITLE %MA GREPMODE
%MA S: cd $::EMENUDIR
%MA R: %C if {![info exist ::EMENUFIND]} {set ::EMENUFIND "%s"}
%MA R: %I {} "$TITLE" { \
   ent1 {{Search for:} {} {-w 60}} {{$::EMENUFIND}} \
   ent2 {{  In files:} {} {}} {"$::EMENUFILES"} \
   dir1 {{    In dir:} {} {}} {"$::EMENUDIR"} \
   v_} -head { Enter a string to search.} -weight bold \
   == ::EMENUFIND ::EMENUFILES ::EMENUDIR
%MA R: %C \
   if {"$::EMENUFILES" eq ""} {set ::EMENU_ ""} {set ::EMENU_ "$::EMENUFILES"}
%MA R: cd $::EMENUDIR
%MA S: echo "$::EMENUDIR" \n\n grep $::EMENU_ $GREPMODE -e '$::EMENUFIND' %ls

ITEM = GREP EXACT
S: %MA GREP EXACT %MA -F -H -n -I -s -d skip *

ITEM = GREP REGEXP
S: %MA GREP REGEXP %MA -E -H -n -I -s -d skip *

## ________________________ dialogues _________________________ ##

SEP = 2

ITEM = Input dialog
R: cd %d
R: %I "" "TEST OF %I" { \
  ent1  {{   Find: }} {"$::EN1"} \
  ent2  {{Replace: }} {"$::EN2"} \
  labo  {{} {} {-t {\nOptions:} -font {-weight bold}}}  {} \
  radA  {{Match:   }} {"$::V1" {Exact} {Glob} {RE  }} \
  seh   {{} {} {}} {} \
  chb1  {{Match whole word only}} {$::C1} \
  chb2  {{Match case           }} {$::C2} \
  seh2  {} {} \
  v_    {} {} \
  cbx1  {{Where:   } {} {}} {"$::W1" $::W1LIST} \
  tex1  {{Any text:} {} {-h 3 -w 50 -wrap word -tabnext lbx1}} {$::TEX} \
  lbx1  {{Related: } {} {-h 3}} {"$::LBX" {my Father} Mother Son Daughter Brother Sister Uncle Aunt Cousin {Big Brother} "Second cousin" "1000th cousin"} \
  opc1  {{Color:   } {-fill none -anchor w}} {{$::OPT} {{color red green blue -- {{other colors} yellow magenta cyan \
        | #52CB2F #FFA500 #CB2F6A | #FFC0CB #90EE90 #8B6914}} \
        {hue dark medium light} -- {{opc widget example}} ok} {-width 16}} \
  tblSEL1  {{Table:   \n\nThe 'tbl' name\nis tblSEL* to\nreturn an item} {} {-h 4 -columns {16 {Name of widget} left \
      0 Type left 0 X right 0 Y right} }} {"$::TBL" {"but" "ttk::button" 1 1} \
      {"can" "canvas" 3 3} \
      {"chb" "ttk::checkbutton" 4 4} \
      {"cbx fco" "ttk::combobox" 23 2} \
      {"ent" "ttk::entry" 212 6}} \
  } \
  -head "Enter data:" -weight bold == ::EN1 ::EN2 ::V1 ::C1 ::C2 ::W1 ::TEX ::LBX ::OPT ::TBL
R: %M "> RESULTS:\n ::EN1= '$::EN1' \n ::EN2= '$::EN2' \n ::V1 = $::V1 \
\n ::C1 = $::C1 \n ::C2 = $::C2\n ::W1 = $::W1 \
\n ::TEX = $::TEX\n ::LBX = $::LBX\n ::OPT = $::OPT\n ::TBL = $::TBL\n"
R: %C ###################################################################
R: %C # save ::W1 to combobox values' list, restricting its size by 5
R: %C # 'catch' is necessary because of possible unmatched braces in ::W1
R: %C # also, we need to use separate %C's for saving results of commands
R: %C # ... and to test any %C with following '%M $::W1LIST'
R: %C catch {if {[set _ [lsearch -exact [list $::W1LIST] {$::W1}]]>=0} \
     {set ::W1LIST [lreplace [list $::W1LIST] [set _] [set _]]}}
R: %C catch {set ::W1LIST [linsert [list $::W1LIST] 0 {$::W1}]}
R: %C catch {set ::W1LIST [lreplace [list $::W1LIST] 5 end]}
R: %C ###################################################################

ITEM = Input dialog: choosers
R: cd %d
R: %C if {![info exists ::CHFIL]} { \
   set ::CHFIL [set ::CHFIS [set ::CHDIR [set ::CHFON [set ::CHCLR [set ::CHDAT ""]]]]]}
R: %I "" "TEST OF %I" { \
  fil1  {{        File: } {} {-w 50}} {"$::CHFIL"} \
  fis1  {{File to save: }} {"$::CHFIS"} \
  dir1  {{   Directory: }} {"$::CHDIR"} \
  fon1  {{        Font: }} {"$::CHFON"} \
  clr1  {{       Color: }} {"$::CHCLR"} \
  dat1  {{        Data: }} {"$::CHDAT"} \
  } \
  -head "Choose data\nwith clicking buttons or pressing F2:" -weight bold == ::CHFIL ::CHFIS ::CHDIR ::CHFON ::CHCLR ::CHDAT
R: %M "> RESULTS:\n ::CHFIL= $::CHFIL \n ::CHFIS= $::CHFIS\n ::CHDIR= $::CHDIR \n ::CHFON= $::CHFON\n ::CHCLR= $::CHCLR \n ::CHDAT= $::CHDAT\n"

## ________________________ modified shell script _________________________ ##

SEP = 2

ITEM = Shell script (bash)
S: %#s

## ________________________ utf-8 _________________________ ##

SEP = 2

ITEM = Test utf-8 (Пусть всегда будет солнце)
S: cd ~
S: echo "Пусть всегда будет солнце," ; echo "Пусть всегда будет мама"

## ________________________ submenu _________________________ ##

SEP = 2

ITEM = Call a menu
M: m=template.em o=-1

# ________________________ hidden items _________________________ #

[HIDDEN]

ITEM = 1. Stop working!
R: ?-33*60/-7*60:ah=3? audacious  /home/apl/PROGRAMS/C_COMM/breakon.wav

ITEM = 2. Arbeiten!
R: audacious /home/apl/PROGRAMS/C_COMM/breakoff.wav

ITEM = 3. caja
R: caja -g +0+0 /home/apl/PG/github

ITEM = 4. poApps & alited
R: tclsh /home/apl/PG/github/poApps/poApps.tcl --dirdiff
RW: sleep 4
R: tclsh /home/apl/PG/github/alited/src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG

# _________________ data of writeable commands __________________ #

[DATA]

%#s geo=969x487+295+250;pos=5.9 # this script is run with %#s wildcard in test1.mnu|!|# it does the same as the previous "Shell script"|!|# being a bash script as it is|!||!|echo ====|!|err=1|!|cd ~/FOSSIL|!|while [ $err -eq 1 ];|!|  do repo=$(find *.fossil 2>/dev/null )|!|  err=$?|!|  if [ $? -eq 1 ]; then|!|    if [ $(pwd) = '/' ]; then|!|      echo "repo non esistente" ; break|!|    fi|!|    cd ../|!|  else|!|    echo "$(pwd)/${repo}"|!|  fi|!|done

# ________________________ EOF _________________________ #

#RUNF: ~/PG/github/e_menu/e_menu.tcl PD=~/PG/github/e_menu/ d=~/PG/github/e_menu/  md=~/PG/github/e_menu/menus/ m=template.em f=%f fs=11 w=30 o=0 c=24 g=+600+300 's=selected text'
