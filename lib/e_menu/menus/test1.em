[OPTIONS]


co=;
w=45
rt=2/5
%C if {![info exist ::EMENUFILE]} {set ::EMENUFILE "%f" ; if {[::iswindows]} {set ::EMENUFILE [string map [list \\ \\\\\\\\] "%f"]}}
%C if {![info exist ::EMENUGREP]} {set ::EMENUGREP ""}
%C if {{%F}=={*} && ![info exist ::EMENUFILE]} {set ::EMENUFILE "*"}
%C set ::EMENUFILETAIL [file tail {$::EMENUFILE}]
%C set ::FILETAIL {"$::EMENUFILETAIL"}

in=1.0
::EN1=%s
::EN2====
::V1=Glob
::C1=0
::C2=1
::W1=in file
::W1LIST={in file} {in directory} {in session}
::OPT=opc widget example
::LBX=Big Brother
::TBL=ent ttk::entry 212 6
::TEX=and	tabs	entered with copy-paste\n1234\n\nsome multi-line text			123
pos=75.18

[MENU]

# test1.mnu

# OPTIONS should go first because of "co=" (line continuator)

ITEM = Doctest Safe: $::FILETAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -v 0 %f

ITEM = Doctest Safe verbose: $::FILETAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -v 1 %f

ITEM = Doctest: $::FILETAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -s 0 -v 0 %f

ITEM = Doctest verbose: $::FILETAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -s 0 -v 1 %f

SEP = 3
ITEM = Trace $::FILETAIL with {%s} excluded
R: %C if {![info exist ::EMENUEXCL]} {set ::EMENUEXCL "%s"}
R: %I {} "TRACE" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{    File:} {} {-w 55}} {"$::EMENUFILE"} \
   ent1 {{Excluded:} {} {-w 55}} {"$::EMENUEXCL"} \
   seh {{} {-pady 3} {}} {} \
   texc {{    Hint:} {} {-h 7 -w 55 -ro 1 -wrap word}} \
   {\n This utility inserts tracing puts to a Tcl script.\n\n The puts are set below the script's proc/method declarations.\n\n There may be set a list of excluded proc/methods.} \
   } -head {\n This will set tracing 'puts' into a file.} -weight bold == ::EMENUFILE
S: tclsh %m/src/atrace.tcl trace $::EMENUFILE $::EMENUEXCL

ITEM = Untrace $::FILETAIL
R: %I {} "UNTRACE" { \
   v_ {{} {-pady 4} {}} {} \
   fil1 {{    File:} {} {-w 55}} {"$::EMENUFILE"} \
   seh {{} {-pady 3} {}} {} \
   texc {{    Hint:} {} {-h 5 -w 55 -ro 1 -wrap word}} \
   {\n This utility removes tracing puts from a Tcl script.\n\n The puts are set below the script's proc/method declarations.} \
   } -head {\n This will remove tracing 'puts' from a file.} -weight bold == ::EMENUFILE
S: tclsh %m/src/atrace.tcl untrace $::EMENUFILE

SEP = 3

ITEM = Run me (with %s)
R: cd %d
R: %IF "%x"==".htm" || "%x"==".html" %THEN %B %f
R: %IF "%x"==".tcl" %THEN %T tclsh %f %s
R: %IF "%x"==".py"  %THEN %t python3 %f %s
R: ###########################################################
R: %M "Edit this menu for file extention: %x"

ITEM = Shell script
S: ? \
    err=1 ;
    cd %H/FOSSIL ;
    while [ $err -eq 1 ];
      do repo=$(find *.fossil 2>/dev/null ) ;
      err=$? ;
      if [ $? -eq 1 ]; then \
        if [ $(pwd) = '/' ]; then \
          echo "repo non esistente" ; break;
        fi;
        cd ../ ;
      else \
        echo "$(pwd)/${repo}" ;
      fi;
    done

ITEM = Shell script (bash)
S: %#s err=1; cd %H/FOSSIL

ITEM = Input dialog
R: cd %d
R: \
  %I "" "TEST OF %I" { \
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
R: \
  %I "" "TEST OF %I" { \
  fil1  {{        File: } {} {-w 50}} {"$::CHFIL"} \
  fis1  {{File to save: }} {"$::CHFIS"} \
  dir1  {{   Directory: }} {"$::CHDIR"} \
  fon1  {{        Font: }} {"$::CHFON"} \
  clr1  {{       Color: }} {"$::CHCLR"} \
  dat1  {{        Data: }} {"$::CHDAT"} \
  } \
  -head "Choose data\nwith clicking buttons or pressing F2:" -weight bold == ::CHFIL ::CHFIS ::CHDIR ::CHFON ::CHCLR ::CHDAT
R: %M "> RESULTS:\n ::CHFIL= $::CHFIL \n ::CHFIS= $::CHFIS\n ::CHDIR= $::CHDIR \n ::CHFON= $::CHFON\n ::CHCLR= $::CHCLR \n ::CHDAT= $::CHDAT\n"

ITEM = Test utf-8 (Пусть всегда будет солнце)
S: cd ~
S: echo "Пусть всегда будет солнце," ; echo "Пусть всегда будет мама"

SEP = 3

ITEM = Test2 menu
MW: "m=test2.em" "a1=M {It's just a test}; if {![Q {DANGER!} {These commands are dangerous\nand can set the world on fire!\n\nContinue?} yesno]} EXIT"

ITEM = Test3 menu
MW: "m=test3.em"

[DATA]

%#s geo=969x487+295+250;pos=5.9 # this script is run with %#s wildcard in test1.mnu|!|# it does the same as the previous "Shell script"|!|# being a bash script as it is|!||!|echo ====|!|err=1|!|cd %H/FOSSIL|!|while [ $err -eq 1 ];|!|  do repo=$(find *.fossil 2>/dev/null )|!|  err=$?|!|  if [ $? -eq 1 ]; then|!|    if [ $(pwd) = '/' ]; then|!|      echo "repo non esistente" ; break|!|    fi|!|    cd ../|!|  else|!|    echo "$(pwd)/${repo}"|!|  fi|!|done
