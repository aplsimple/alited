[OPTIONS]

::RGEO=568x537+0+55
::RBIN=BIN
::REV1=-3
pos=4.37
in=1.0
w=40

[MENU]


ITEM = hg addremove
R: %q "ADD" "This will ADD & REMOVE all changes in:\n\n  %PD"
R: cd %PD
SW: hg addremove -S -v\nhg status

ITEM = hg add "%F" file
R: %q "ADD" "This will add\n\n  %f\n\nto hg history of\n\n  %PD"
R: cd %PD
SW: hg add -v "%f"\nhg status

ITEM = hg add "%D" directory
R: %q "ADD" \
   "This will add ALL of directory\n\n  %d\n\nto hg history of\n\n  %PD"
R: cd %d
SW: hg add -v *\nhg status

SEP = 3

ITEM = Forget "%F" file
R: cd %d
R: %q "FORGET FILE" "This will FORGET the file \
    \n\n  %f \n\nin hg history!"
SW: hg forget -v %f\nhg status

ITEM = Forget "%D" directory
R: cd %d
R: %q "FORGET DIRECTORY" "This will FORGET the directory \
    \n\n  %d \n\nin hg history!"
SW: hg forget -v *\nhg status

ITEM = Forget newly-added binary files
R: %q "FORGET ADDED BIN" " This will FORGET \
  \n newly-added binary files!"
SW: hg forget "set:added() and binary()"\nhg status

ITEM = Forget files excluded by .hgignore
R: %q "FORGET BY .hgignore" " This will FORGET files \
  \n that are excluded by .hgignore!"
SW: hg forget "set:hgignore()"\nhg status

SEP = 3

ITEM = Remove "%F" file
R: cd %d
R: %C if {![info exist ::FREM]} {set ::FREM 0}
R: %I warn "REMOVE FILE" {chb \
    {{Forget added files, delete modified files:} {} {}} \
    {$::FREM}} -head { This will REMOVE the file \
    \n\n   %f \n\n from hg history! \
    \n\n Note: \
    \n   'hg remove' never deletes files in Added \[A\] state from the working \
    \n   directory, not even if \"--force\" is specified.\n} -weight bold == ::FREM
R: %C if {$::FREM} {set ::FORCEDREM -f} {set ::FORCEDREM -Af}
SW: hg remove $::FORCEDREM -v %f\nhg status

ITEM = Remove "%D" directory
R: cd %d
R: %C if {![info exist ::FREM]} {set ::FREM 0}
R: %I warn "REMOVE DIRECTORY" {chb \
    {{Forget added files, delete modified files:} {} {}} \
    {$::FREM}} -head { This will REMOVE all files of directory \
    \n\n   %d \n\n from hg history! \
    \n\n Note: \
    \n   'hg remove' never deletes files in Added \[A\] state from the working \
    \n   directory, not even if \"--force\" is specified.\n} -weight bold == ::FREM
R: %C if {$::FREM} {set ::FORCEDREM -f} {set ::FORCEDREM -Af}
SW: hg remove $::FORCEDREM -v *\nhg status

SEP = 3

ITEM = hg summary, status, heads
S: cd %PD
S: \n \n \
  echo "\n------------------------------------------------\n" \n  \
  echo "HG SUMMARY: \t $PWD\n" \n \
       hg summary \n \
  echo "\n------------------------------------------------\n" \n \
  echo "HG STATUS: \t $PWD\n" \n \
       hg status \n \
  echo "\n------------------------------------------------\n" \n \
  echo "HG HEADS: \t $PWD\n" \n \
       hg heads \n\n

ITEM = Push with BIN
R: cd %PD
R: %q "Push with BIN" " This will push your last commits + BIN \
  \n so that: \
  \n     * a new development cycle would begin \
  \n     * you would go on committing in:\n            %PD \
  \n     * ... till a next 'Push with BIN' \
  \n\n Please, view the messages to follow..."
SW: \
  echo "\n------------------------------------------------\n" \n  \
  echo "HG SUMMARY: \t $PWD\n" \n \
       hg summary \n \
  echo "\n------------------------------------------------\n" \n \
  echo "HG STATUS: \t $PWD\n" \n \
       hg status \n \
  echo "\n------------------------------------------------\n" \n \
  echo "HG HEADS: \t $PWD\n" \n \
       hg heads \n \
  echo "\n------------------------------------------------\n" \n \
  echo "\nVerify the previous messages C A R E F U L L Y !\n" \n\n
R: %I warn "Push with BIN" {entRev {{Tag of 'BIN' revision:} \
  {} {-w 20}} {"$::RBIN"} lab} -ontop 1 -geometry $::RGEO -head \
  "\nThis will push your last commits + BIN of \n  %PD \
\n\nSpecifically this means: \
\n  * old 'BIN' commit (if any) is stripped by 'hg strip' \
\n  * new 'bin' files are pushed as a new 'BIN' commit \
\n  * working directory is updated to a revision prior to 'BIN' \
\n\nSo you would go on committing in your essential hg head \
\nusing this 'Push with BIN' instead of regular 'hg push'. \
\n\nVIEW MESSAGES and MAKE SURE that: \
\n  1. All of 'bin' directory are stated as '?' by hg status. \
\n  2. No other changes (M,A,R...) are stated by hg status. \
\n  3. Your essential development head is the tip. \
\n  4. 'BIN' is stripped by Bitbucket/Settings/Strip commits. \n" \
  -weight bold == ::RGEO - ::RBIN
R: %C set ::rbin [string tolower "$::RBIN"]
SW: \
  echo '###################### backup $::rbin to .$::rbin.bak' ; \
  rm -f -r $::rbin.bak/* ; \
  mkdir $::rbin.bak ; \
  cp -a $::rbin/* $::rbin.bak ; \
  echo '###################### remove $::RBIN commit' ; \
  hg update $::RBIN ; \
  hg strip --no-backup $::RBIN ; \
  hg update tip ; \
  echo '###################### restore $::rbin from $::rbin.bak' ; \
  rm -f -r $::rbin/* ; \
  mkdir $::rbin ; \
  date '+Updated: %%n  %%F at %%X' 1> $::rbin.bak/README ; \
  cp -a $::rbin.bak/* $::rbin ; \
  echo '###################### CHECKING hg status' ; \
  hg status ; \
  read -n 1 -p \
  'MAKE SURE that ? $::rbin files would be committed only. Press a key to continue...' ; \
  echo '###################### add $::rbin/* and commit' ; \
  hg add $::rbin/* ; \
  hg commit -m $::RBIN ; \
  hg tag $::RBIN ; \
  echo '###################### push to Bitbucket' ; \
  hg push -f ; \
  echo '###################### REMEMBER the revision prior to $::RBIN' ; \
  hg log -l 7 ; \
  echo '###################### REMEMBER the revision prior to $::RBIN'
R: %I ques "WORKING REVISION" {entRev {{Revision prior to $::RBIN:} {} \
    {-w 20}} {"$::REV1"} lab} -head "\n Enter a revision prior to $::RBIN. \
    \n It is a main stream of development. \
    \n Most likely, it is -3 (2 level under the tip). \n" -weight bold == ::REV1
SW: \
  echo '\n\n###################### go to a revision prior to $::RBIN' ; \
  hg update -r $::REV1 ; \
  echo '\n\n###################### restore $::rbin from $::rbin.bak (possibly not-committed)' ; \
  rm -f -r $::rbin/* ; \
  mkdir $::rbin ; \
  cp -a $::rbin.bak/* $::rbin ; \
  hg status ; \
  hg summary ; \
  echo '###################### THE END'
