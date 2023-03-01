[OPTIONS]

in=5.0
pos=7.3
o=-1
co=;
w=40
rt=2/5
%C if {![info exist ::EMENUFILE]} {set ::EMENUFILE "%f" ; if {[::iswindows]} {set ::EMENUFILE [string map [list \\ \\\\\\\\] "%f"]}}
%C if {![info exist ::EMENUFILETMP]} {set ::EMENUFILETMP "%TF" ; if {[::iswindows]} {set ::EMENUFILETMP [string map [list \\ \\\\\\\\] "%TF"]}}
%C if {![info exist ::EMENUGREP]} {set ::EMENUGREP ""}
%C if {{%F}=={*} && ![info exist ::EMENUFILE]} {set ::EMENUFILE "*"}
%C set ::EMENUFILETAIL [file tail {$::EMENUFILE}]
%C set ::FILETAIL {"$::EMENUFILETAIL"}
%C set ::EMENUFILETMPTAIL [file tail {$::EMENUFILETMP}]
%C set ::FILETMPTAIL {"$::EMENUFILETMPTAIL"}

[MENU]

# options should go first because of "co=" (line continuator)

ITEM = Doctest Safe: $::FILETMPTAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -DTv 0 %TF

ITEM = Doctest Safe verbose: $::FILETMPTAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -DTv 1 %TF

ITEM = Doctest: $::FILETMPTAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -DTs 0 -DTv 0 %TF

ITEM = Doctest verbose: $::FILETMPTAIL
R: cd %d
S: tclsh %m/src/doctest_of_emenu.tcl -DTs 0 -DTv 1 %TF

SEP = 3

ITEM = Help on doctest
R: %b http://aplsimple.github.io/en/tcl/doctest/index.html

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
   } -head {\n This will set tracing 'puts' into a file.} -weight bold == ::EMENUFILE ::EMENUEXCL
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
