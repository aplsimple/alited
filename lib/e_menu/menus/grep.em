[OPTIONS]

o=-1
w=45
in=1.0
::EMENUFILES=--include=*.tcl --include=*.em --include=*.txt --include=*.htm* --include=*.md* --exclude-dir=.* --exclude-dir=*BAK* --exclude-dir=*TMP*
::EMENUDIR=%d
pos=41.4

[MENU]

ITEM = GREP TEMPLATE (%%s=%s) ?
S: cd %d
S: %#t grep -H -n -I -s -i -d recurse * -e '%s'

%MA TITLE %MA GREPMODE
%MA S: cd $::EMENUDIR
%MA R: %C if {![info exist ::EMENUFIND]} {set ::EMENUFIND "%s"}
%MA R: %I {} "$TITLE" { \
   ent1 {{Search for:} {} {-w 60}} {{$::EMENUFIND}} \
   ent2 {{  In files:} {} {}} {"$::EMENUFILES"} \
   dir1 {{    In dir:} {} {}} {"$::EMENUDIR"} \
   v_} -head { Enter a string to search.} -weight bold == ::EMENUFIND ::EMENUFILES ::EMENUDIR
%MA R: %C \
   if {"$::EMENUFILES" eq ""} {set ::EMENU_ ""} {set ::EMENU_ "$::EMENUFILES"}
%MA R: cd $::EMENUDIR
%MA S: echo "$::EMENUDIR" \n\n grep $::EMENU_ $GREPMODE -e '$::EMENUFIND' %ls

SEP = 3
ITEM = GREP EXACT ?
S: %MA GREP EXACT %MA -F -H -n -I -s -d skip *
ITEM = GREP REGEXP ?
S: %MA GREP REGEXP %MA -E -H -n -I -s -d skip *

SEP = 3
ITEM = GREP EXACT  ignoring case ?
S: %MA GREP EXACT ignoring case  %MA -F -H -n -I -s -i -d skip *
ITEM = GREP REGEXP ignoring case ?
S: %MA GREP REGEXP ignoring case %MA -E -H -n -I -s -i -d skip *

SEP = 3
ITEM = GREP EXACT  recursive ?
S: %MA GREP EXACT recursive  %MA -F -H -n -I -s -d recurse *
ITEM = GREP REGEXP recursive ?
S: %MA GREP REGEXP recursive %MA -E -H -n -I -s -d recurse *

SEP = 3
ITEM = GREP EXACT  recursive ignoring case ?
S: %MA GREP EXACT recursive ignoring case \
    %MA -F -H -n -I -s -i -d recurse *
ITEM = GREP REGEXP recursive ignoring case ?
S: %MA GREP REGEXP recursive ignoring case \
    %MA -E -H -n -I -s -i -d recurse *

SEP = 3
ITEM = GREP EXACT...  LS=%ls?
S: %MA GREP EXACT %MA -F -H -n -I -s
ITEM = GREP REGEXP... LS=%ls?
S: %MA GREP REGEXP %MA -E -H -n -I -s

[DATA]

%#t geo=1296x500+100+100;pos=2.0 cd %PD|!||!|echo ===============================================================================|!||!| grep -E -H -n -I -s -d recurse --include '*tcl' --include '*html' -e "%s" %ls|!||!|echo ===============================================================================|!|echo year 1900-2099|!||!| grep -E -H -n -I -s -i -d recurse * -e '(^|[^[:digit:]])(19|20)[[:digit:]]{2}([^[:digit:]]|$)'|!||!|echo ===============================================================================|!|echo email|!||!| grep -E -H -n -I -s -i -d recurse * -e '[_]*([a-z0-9]+(\\.|_*)?)+@([a-z][a-z0-9-]+(\\.|-*\\.))+[a-z]{2,6}'|!||!|echo ===============================================================================|!|echo "in: $PWD"
