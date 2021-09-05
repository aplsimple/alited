#! /usr/bin/env tclsh
###########################################################
# Name:    find.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/25/2021
# Brief:   Handles find/replace procedures of alited.
# License: MIT.
###########################################################

# ________________________ Variables _________________________ #

namespace eval find {

  # "Find/Replace" dialogue's path
  variable win $::alited::al(WIN).winFind

  # "Search by list" dialogue's path
  variable win3 $::alited::al(WIN).winSBL

  # initial geometry of the dialogue
  variable geo root=$::alited::al(WIN)

  # -minsize option of the dialogue
  variable minsize {}

  # common data of procs
  variable data; array set data [list]

  # options of "Find/Replace" dialogue
  set data(c1) 0  ;# words only
  set data(c2) 1  ;# case
  set data(c3) 0  ;# by blank
  set data(c4) 1  ;# wrap around
  set data(c5) 0  ;# on top

  # lists for find & replace comboboxes
  set data(vals1) [list]
  set data(vals2) [list]

  # values of find & replace comboboxes
  set data(en1) {}
  set data(en2) {}

  # value for radiobutton "Match"
  set data(v1) 1

  # value for radiobutton "Direction"
  set data(v2) 2

  # enables/disables correctness of options (if "no", "Find" is run without dialogue)
  set data(docheck) yes

  # delimiters of words
  variable delim1 [list { } {} {;} \n \t \$ \" ` ' @ # % ^ & * ( ) - + = | \\ / : , . ? ! < >]

  # left delimiters of commands
  variable ldelim [list { } {} \n \t \} \{ \[ # {;} \" \\ (]

  # right delimiters of commands
  variable rdelim [list { } {} \n \t \} \] # {;} \" \\ )]

  # all delimiters of commands
  variable adelim [list \} \{ \[ \] {*}$delim1]

  # variable to count matches
  variable counts {}
}

# ________________________ Words / commands from text _________________________ #

proc find::GetCommandOfLine {line idx {delim ""} {mode ""}} {
  # Gets a command from a line.
  #   line - the line
  #   idx - a column of the line
  #   delim - list of word delimiters
  #   mode - if it ends with "2", the result includes a range of found string.

  variable ldelim
  variable rdelim
  if {$delim ne {}} {
    set delim1 $delim
    set delim2 $delim
  } else {
    set delim1 $ldelim
    set delim2 $rdelim
  }
  set i1 [set i2 [string range $idx [string first . $idx]+1 end]]
  for {set i $i1} {1} {} {
    incr i -1
    if {[string index $line $i] in $delim1} {
      set i1 [expr {$i+1}]
      break
    }
  }
  for {set i $i1} {1} {} {
    incr i
    if {[string index $line $i] in $delim2} {
      set i2 [expr {$i-1}]
      break
    }
  }
  set res [string trim [string range $line $i1 $i2]]
  if {[string index $mode end] eq "2"} {
    set res [list $res $i1 $i2]
  }
  return $res
}
#_______________________

proc find::GetWordOfLine {line idx {mode ""}} {
  # Gets a word from a line.
  #   line - the line
  #   idx - a column of the line
  #   mode - if it ends with "2", the result includes a range of found string.

  variable adelim
  return [GetCommandOfLine $line $idx $adelim $mode]
}
#_______________________

proc find::GetCommandOfText {wtxt {mode ""}} {
  # Gets a command of text under the cursor.
  #   wtxt - text widget's path
  #   mode - if it ends with "2", the result includes a range of found string.

  set idx [$wtxt index insert]
  set line [$wtxt get "$idx linestart" "$idx lineend"]
  return [list [GetCommandOfLine $line $idx "" $mode] $idx]
}
#_______________________

proc find::GetWordOfText {{mode ""}} {
  # Gets a word of text under the cursor.
  #   mode - if "select", try to get the word from a line with a selection
  #  If 'mode' ends with "2", the result includes a range of found string.

  set wtxt [alited::main::CurrentWTXT]
  if {$mode in {noselect noselect2} || \
  [catch {set sel [$wtxt get sel.first sel.last]}]} {
    set idx [$wtxt index insert]
    set line [$wtxt get "$idx linestart" "$idx lineend"]
    set sel [GetWordOfLine $line $idx $mode]
  } elseif {[string index $mode end] eq "2"} {
    set sel [list $sel]
  }
  return $sel
}

# ________________________ Search units (Ctrl-Shift-F) _________________________ #

proc find::SearchUnit1 {wtxt isNS} {
  # Searches units in a text.
  #   wtxt - the text's path
  #   isNS - flag "search a qualified unit name"

  namespace upvar ::alited al al
  if {$wtxt eq ""} {set wtxt [alited::main::CurrentWTXT]}
  lassign [GetCommandOfText $wtxt] com1 idx
  if {$com1 eq {}} {bell; return {}}
  set com2 $com1
  set withNS [expr {[set i [string last ":" $com1]]>-1}]
  if {!$isNS} {
    # try to find the pure (not qualified) name
    set com2 [string range $com1 $i+1 end]
  } elseif {!$withNS} {
    # try to get the current unit's namespace
    set curr [lindex [alited::tree::CurrentItemByLine $idx yes] 4]
    set com2 [string cat [string range $curr 0 [string last ":" $curr]] $com1]
  }
  if {$isNS} {
    set tabs [SessionList]
    set what "*$com2"
  } else {
    set what "*::$com2"
    set tabs [alited::bar::CurrentTabID]  ;# not qualified
  }
  foreach tab $tabs {
    set TID [lindex $tab 0]
    alited::file::ReadFileByTID $TID
    foreach it $al(_unittree,$TID) {
      lassign $it lev leaf fl1 ttl l1 l2
      if {[string match $what $ttl] || [string match "*::$ttl" $com2] || $com2 eq $ttl} {
        return [list $l1 $TID]
      }
    }
  }
  return {}
}
#_______________________

proc find::SearchUnit {{wtxt ""}} {
  # Prepares and runs searching units in a text.
  #   wtxt - the text's path

  namespace upvar ::alited al al obPav obPav
  # switch to the unit tree: 1st to enable the search, 2nd to show units found & selected
  if {!$al(TREE,isunits)} alited::tree::SwitchTree
  lassign [SearchUnit1 $wtxt yes] found TID
  if {$found eq {}} {
    # if the qualified not found, try to find the non-qualified (first encountered)
    lassign [SearchUnit1 $wtxt no] found TID
  }
  if {$found ne {}} {
    alited::bar::BAR $TID show
    after idle " \
      alited::main::FocusText $TID $found.0 ; \
      alited::tree::NewSelection {} $found.0 yes"
  } else {
    bell
  }
}
#_______________________

proc find::DoFindUnit {} {
  # Runs searching units in current text / all texts.

  namespace upvar ::alited al al obPav obPav
  set ent [$obPav EntFindSTD]
  set what [string trim [$ent get]]
  if {$what eq {}} {
    bell
    return
  }
  InitShowResults
  set n 0
  if {$alited::main::findunits==1} {
    set tabs [SessionList]
  } else {
    set tabs [alited::bar::CurrentTabID]
  }
  foreach tab $tabs {
    set TID [lindex $tab 0]
    alited::file::ReadFileByTID $TID
    foreach it $al(_unittree,$TID) {
      lassign $it lev leaf fl1 title l1 l2
      set ttl [string range $title [string last : $title]+1 end] ;# pure name, no NS
      if {[string match -nocase "*$what*" $ttl]} {
        set fname [alited::bar::BAR $TID cget -text]
        alited::info::Put "$fname:$l1: $title" [list $TID $l1]
        incr n
      }
    }
  }
  alited::info::Clear 0
  ShowResults [string map [list %n $n %s $what] $al(MC,frres1)]
}
#_______________________

proc find::FindUnit {} {
  # Displays "Find unit" frame.

  namespace upvar ::alited al al obPav obPav
  set ent [$obPav EntFindSTD]
  if {[set word [GetWordOfText]] ne {}} {
    set alited::al(findunit) $word
  }
  if {![info exist al(isfindunit)] || !$al(isfindunit)} {
    set al(isfindunit) true
    pack [$obPav FraHead] -side bottom -fill x -pady 3 -after [$obPav GutText]
    foreach k {f F} {bind $ent <Shift-Control-$k> {alited::find::DoFindUnit; break}}
    bind $ent <Return> alited::find::DoFindUnit
    bind $ent <Escape> {::alited::find::HideFindUnit; break}
  }
  focus $ent
  after idle "$ent selection range 0 end"
}
#_______________________

proc find::HideFindUnit {} {
  # Hides "Find unit" frame.

  namespace upvar ::alited al al obPav obPav
  set al(isfindunit) no
  pack forget [$obPav FraHead]
  focus [alited::main::CurrentWTXT]
}

# ________________________ Find word in a session (Ctrl-L) _________________________ #

proc find::SearchWordInSession {} {
  variable data
  set saven1 $data(en1)  ;# field "Find"
  set savv1 $data(v1)    ;# rad "Exact"
  set savc1 $data(c1)    ;# chb "Word only"
  set savc2 $data(c2)    ;# chb "Case Sensitive"
  if {[set data(en1) [GetWordOfText select]] eq ""} {
    bell
  } else {
    set wtxt [alited::main::CurrentWTXT]
    if {[catch {set sel [$wtxt get sel.first sel.last]}] || $sel eq ""} {
      set data(c1) 1
    } else {
      set data(c1) 0  ;# if selected, let it be looked for (at "not word only")
    }
    set data(v1) 1
    set data(c2) 1
    set data(docheck) no  ;# no checks - no usage of the dialogue's widgets
    FindInSession notag
    set data(docheck) yes
  }
  set data(en1) $saven1
  set data(v1) $savv1
  set data(c1) $savc1
  set data(c2) $savc2
}

# ________________________ Get data for search _________________________ #

proc find::GetFindEntry {} {
  # Puts a current selection of text to the "Find:" field

  variable data
  set wtxt [alited::main::CurrentWTXT]
  if {[catch {set sel [$wtxt get sel.first sel.last]}]} {
    set idx [$wtxt index insert]
    set line [$wtxt get "$idx linestart" "$idx lineend"]
    set sel [GetWordOfLine $line $idx]
  }
  if {$sel ne {}} {set data(en1) $sel}
}
#_______________________

proc find::CheckData {op} {
  # Checks if the find/replace data are valid.
  #   op - if "repl", checks for "Replace" operation
  # Return "yes", if the input data are valid.

  namespace upvar ::alited al al
  variable win
  variable data
  # this means "no checks when used outside of the dialogue":
  if {!$data(docheck)} {return yes}
  # search input data in arrays of combobox values:
  # if not found, save the data to the arrays
  set w $win.fra
  set foc {}
  foreach i {2 1} {
    if {[set data(en$i)] ne {}} {
      if {[set f [lsearch -exact [set data(vals$i)] [set data(en$i)]]]>-1} {
        set data(vals$i) [lreplace [set data(vals$i)] $f $f]
      }
      set data(vals$i) [linsert [set data(vals$i)] 0 [set data(en$i)]]
      catch {set data(vals$i) [lreplace [set data(vals$i)] $al(INI,maxfind) end]}
      $w.cbx$i configure -values [set data(vals$i)]
    } elseif {$i==1 || ($op eq "repl" && !$data(c3))} {
      set foc $w.cbx$i
    }
  }
  if {$foc ne {}} {
    # if find/replace field is empty, let the bell tolls for him
    bell
    focus $foc
    return no
  }
  return yes
}
#_______________________

proc find::FindOptions {wtxt} {
  # Gets options of search, according to the dialogue's fields.
  #   wtxt - text widget's path

  variable data
  $wtxt tag remove fndTag 1.0 end  ;# clear the text off the find tag
  set options [set stopidx {}]
  set findstr $data(en1)
  if {!$data(c2)} {append options {-nocase }}
  # glob search - through its regexp
  switch $data(v1) {
    2 {
      append options {-regexp }
      set findstr [string map {* .* ? . . \\. \{ \\\{ \} \\\} ( \\( ) \\) ^ \\^ \$ \\\$ - \\- + \\+} $findstr]
    }
    3 {
      append options {-regexp }}
    default {
      append options {-exact }}
  }
  return [list $findstr [string trim $options] $stopidx]
}

# ________________________ Show results _________________________ #

proc find::ShowResults {msg {mode 3} {TID ""}} {
  # Display a message containing results of a search.
  #   msg - the message
  #   mode - mode for alited::Message
  #   TID - tab's ID where the searches were performed in

  if {$TID eq {}} {set TID [alited::bar::CurrentTabID]}
  set fname [alited::bar::BAR $TID cget -text]
  set msg [string map [list %f $fname] $msg]
  # results in info list:
  alited::info::Put $msg {} yes
  # results in status bar:
  alited::Message "$msg [string repeat { } 40]" $mode
  # update line numbers of current file, as they are gone after the search
  after idle " \
    alited::main::CursorPos [alited::main::CurrentWTXT] ; \
    alited::main::UpdateGutter"
}
#_______________________

proc find::ShowResults1 {allfnd} {
  # Shows a message of all found strings.
  #   allfnd - list of search results

  namespace upvar ::alited al al
  variable data
  ShowResults [string map [list %n [llength $allfnd] %s $data(en1)] $alited::al(MC,frres1)]
}
#_______________________

proc find::ShowResults2 {rn msg {TID ""}} {
  # Shows a message of number of found strings.
  #   rn - number of found strings
  #   msg - messsage's template
  #   TID - tab's ID where the searches were performed in

  namespace upvar ::alited al al
  variable data
  ShowResults [string map [list %n $rn %s $data(en1) %r $data(en2)] $msg] 3 $TID
}
#_______________________

proc find::InitShowResults {} {
  # Clears the info list before any search.

  namespace upvar ::alited al al
  alited::info::Clear
  alited::info::Put $al(MC,wait) "" yes
  update
}

# ________________________ Do search _________________________ #

proc find::CheckWord {wtxt index1 index2 {wordonly {}}} {
  # Check if the found string is a word, at searching by words, 
  #   wtxt - text widget's path
  #   index1 - first index of the found string
  #   index2 - last index of the found string
  #   wordonly - flag "search word only"
  # Returns "yes" if the found string is a word.

  variable adelim
  variable data
  if {$wordonly eq {}} {set wordonly $data(c1)}
  if {$wordonly} {
    set index10 [$wtxt index "$index1 - 1c"]
    set index20 [$wtxt index "$index2 + 1c"]
    if {[$wtxt get $index10 $index1] ni $adelim} {return no}
    if {[$wtxt get $index2 $index20] ni $adelim} {return no}
  }
  return yes
}
#_______________________

proc find::Search1 {wtxt pos} {
  # Searches a text from a position for a string to find.
  #   wtxt - text widget's path
  #   pos - position to start searching from

  variable win
  variable data
  lassign [FindOptions $wtxt] findstr options
  if {[catch {set fnd [$wtxt search {*}$options -count alited::find::counts -all -- $findstr $pos]} err]} {
    alited::msg ok err $err -ontop yes -parent $win
    set data(_ERR_) yes
    return [list 1 {}]
  }
  return [list 0 $fnd]
}
#_______________________

proc find::Search {wtxt} {
  # Searches a text for a string to find.
  #   wtxt - text widget's path

  namespace upvar ::alited obPav obPav
  variable data
  variable counts
  variable win
  set idx [$wtxt index insert]
  lassign [FindOptions $wtxt] findstr options
  if {![CheckData find]} {return {}}
  $obPav set_HighlightedString $findstr
  if {[$obPav csDarkEdit]} {
    set fg white
    set bg #1c1cff
  } else {
    set fg black
    set bg #8fc7ff
  }
  $wtxt tag configure fndTag -borderwidth 1 -relief raised -foreground $fg -background $bg
  $wtxt tag lower fndTag
  lassign [Search1 $wtxt 1.0] err fnd
  if {$err} {return {}}
  set i 0
  set res [list]
  foreach index1 $fnd {
    set index2 [$wtxt index "$index1 + [lindex $counts $i]c"]
    if {[CheckWord $wtxt $index1 $index2]} {
      lappend res [list $index1 $index2]
    }
    incr i
  }
  return $res
}

# _______________________ "Find" buttons _______________________ #

proc find::Find {{inv -1}} {
  # Searches one string in a current text.
  #   inv - index of a button that was hit (1 means "Find" button)

  namespace upvar ::alited obFND obFND
  variable data
  if {$inv>-1} {set data(lastinvoke) $inv}  ;# save the hit button's index
  set wtxt [alited::main::CurrentWTXT]
  $wtxt tag remove sel 1.0 end
  set fndlist [Search $wtxt]
  if {![llength $fndlist]} {
    bell
    focus [$obFND Cbx1]
    return
  }
  set indexprev [set indexnext 0]
  set index [$wtxt index insert]
  foreach idx12 $fndlist {
    lassign $idx12 index1 index2
    $wtxt tag add fndTag $index1 $index2
    if {[$wtxt compare $index1 < $index]} {
      set indexprev $index1
      set indp2 $index2
    }
    if {[$wtxt compare $index < $index1] && $indexnext==0} {
      set indexnext $index1
      set indn2 $index2
    }
  }
  if {$data(c4) && $data(v2)==1}        {  ;# search backward & wrap around
    if {!$indexprev} {lassign [lindex $fndlist end] indexprev indp2}
    ::tk::TextSetCursor $wtxt $indexprev
    $wtxt tag add sel $indexprev $indp2

  } elseif {$data(c4) && $data(v2)==2}  {  ;# search forward & wrap around
    if {!$indexnext || ([lindex $fndlist end 0]==$indexnext && [$wtxt compare $indexnext == $index])} {
      lassign [lindex $fndlist 0] indexnext indn2
    }
    ::tk::TextSetCursor $wtxt $indexnext
    $wtxt tag add sel $indexnext $indn2

  } elseif {!$data(c4) &&$data(v2)==1}  {  ;# search backward & not wrap around
    if {$indexprev} {
      ::tk::TextSetCursor $wtxt $indexprev
      $wtxt tag add sel $indexprev $indp2
    } else {
      bell
    }

  } elseif {!$data(c4) && $data(v2)==2} {  ;# search forward & not wrap around
    if {$indexnext} {
      ::tk::TextSetCursor $wtxt $indexnext
      $wtxt tag add sel $indexnext $indn2
    } else {
      bell
    }
  }
  ::alited::main::CursorPos $wtxt
  if {$inv>-1} alited::main::HighlightLine
}
#_______________________

proc find::FindAll {wtxt TID {tagme "add"}} {
  # Searches all strings in a text.
  #   wtxt - text widget's path
  #   TID - tab's ID
  #   tagme - if "add", means "add find tag to the found strings of the text"

  set fname [alited::bar::BAR $TID cget -text]
  set l1 -1
  set allfnd [Search $wtxt]
  foreach idx12 $allfnd {
    lassign $idx12 index1 index2
    if {$tagme eq {add}} {$wtxt tag add fndTag $index1 $index2}
    set l2 [expr {int($index1)}]
    if {$l1 != $l2} {
      set line [$wtxt get "$index1 linestart" "$index1 lineend"]
      alited::info::Put "$fname:$l2: [string trim $line]" [list $TID $l2]
      set l1 $l2
    }
  }
  return $allfnd
}
#_______________________

proc find::FindInText {{inv -1}} {
  # Searches all strings in a current text.
  #   inv - index of a button that was hit (2 means "All in Text" button)

  variable data
  if {$inv>-1} {set data(lastinvoke) $inv}
  alited::info::Clear
  set wtxt [alited::main::CurrentWTXT]
  set TID [alited::bar::CurrentTabID]
  ShowResults1 [FindAll $wtxt $TID]
}
#_______________________

proc find::FindInSession {{tagme "add"} {inv -1}} {
  # Searches all strings in a session.
  #   tagme - if "add", means "add find tag to the found strings of the text"
  #   inv - index of a button that was hit (3 means "All in Session" button)

  variable data
  if {$inv>-1} {set data(lastinvoke) $inv}
  InitShowResults
  set allfnd [list]
  set data(_ERR_) no
  foreach tab [SessionList] {
    set TID [lindex $tab 0]
#    alited::file::ReadFileByTID $TID
    lassign [alited::main::GetText $TID] curfile wtxt
    lappend allfnd {*}[FindAll $wtxt $TID $tagme]
    if {$data(_ERR_)} break
  }
  alited::info::Clear 0
  ShowResults1 $allfnd
}

# _______________________ "Replace" buttons _______________________ #

proc find::FindReplStr {str} {
  # Prepares a string to find/replace for messages.
  #   str - string to prepare

  set res [string range $str 0 50]
  if {$res ne $str} {append res { ...}}
  return $res
}
#_______________________

proc find::Replace {} {
  # Replaces one string and finds next.

  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  set wtxt [alited::main::CurrentWTXT]
  set pos [$wtxt index insert]
  set isset no
  lassign [$wtxt tag ranges sel] idx1 idx2
  if {$pos eq $idx1} {
    lassign [Search1 $wtxt $pos] err fnd
    if {$err} return
    foreach index1 $fnd {
      if {$index1 eq $pos} {
        set isset yes
        break
      }
    }
  }
  if {!$isset} Find
  lassign [$wtxt tag ranges sel] idx1 idx2
  if {$idx1 ne {} && $idx2 ne {}} {
    $wtxt replace $idx1 $idx2 $data(en2)
    SetCursor $wtxt $idx1
    set msg [string map [list %n 1 %s $data(en1) %r $data(en2)] $alited::al(MC,frres2)]
    ShowResults $msg
    alited::main::UpdateTextAndGutter
  }
  Find
}
#_______________________

proc find::ReplaceAll {TID wtxt allfnd} {
  # Replaces all found strings in a text.
  #   TID - tab's ID
  #   wtxt - text's path
  #   allfnd - list of found strings data (index1, index2)

  variable data
  set rn 0
  for {set i [llength $allfnd]} {$i} {} {
    if {!$rn} {
      if {$TID ni [alited::bar::BAR listFlag m]} {
        alited::edit::BackupFile $TID orig
      }
    }
    incr i -1
    lassign [lindex $allfnd $i] idx1 idx2
    $wtxt replace $idx1 $idx2 $data(en2)
    incr rn
  }
  if {$rn} {SetCursor $wtxt [lindex $allfnd end 0]}
  return $rn
}
#_______________________

proc find::ReplaceInText {} {
  # Handles hitting "Replace in Text" button.

  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  set fname [file tail [alited::bar::FileName]]
  set msg [string map [list %f $fname %s [FindReplStr $data(en1)] \
    %r [FindReplStr $data(en2)]] $al(MC,frdoit1)]
  if {![alited::msg yesno warn $msg NO -ontop $data(c5)]} {
    return {}
  }
  set wtxt [alited::main::CurrentWTXT]
  set TID [alited::bar::CurrentTabID]
  set rn [ReplaceAll $TID $wtxt [Search $wtxt]]
  ShowResults2 $rn $alited::al(MC,frres2)
  alited::main::UpdateTextAndGutter
}
#_______________________

proc find::ReplaceInSession {} {
  # Handles hitting "Replace in Session" button.

  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  set msg [string map [list %s [FindReplStr $data(en1)] \
    %r [FindReplStr $data(en2)]] $al(MC,frdoit2)]
  if {![alited::msg yesno warn $msg NO -ontop $data(c5)]} {
    return {}
  }
  set currTID [alited::bar::CurrentTabID]
  set rn 0
  set data(_ERR_) no
  foreach tab [SessionList] {
    set TID [lindex $tab 0]
#    if {![info exist al(_unittree,$TID)]} {
#      alited::file::ReadFile $TID [alited::bar::FileName $TID]
#    }
    lassign [alited::main::GetText $TID] curfile wtxt
    if {[set rdone [ReplaceAll $TID $wtxt [Search $wtxt]]]} {
      ShowResults2 $rdone $alited::al(MC,frres2) $TID
      incr rn $rdone
    }
    alited::file::MakeThemHighlighted $TID
    if {$data(_ERR_)} break
  }
  ShowResults2 $rn $alited::al(MC,frres3)
  alited::main::UpdateTextAndGutter
}

# ________________________ Helpers _________________________ #

proc find::Next {} {
  # Generate F3 key pressing event.

  catch {event generate [alited::main::CurrentWTXT] <[alited::pref::BindKey 12 - F3]>}
}
#_______________________

proc find::ClearTags {} {
  # Clears all find tags in a current text, if Find/Replace dialogue was closed.

  variable win
  catch {
    if {![winfo exists $win]} {
      [alited::main::CurrentWTXT] tag remove fndTag 1.0 end
    }
  }
}
#_______________________

proc find::SessionList {} {
  # Returns a list of all tabs or selected tabs (if set).

  set res [alited::bar::BAR listFlag s]
  if {[llength $res]==1} {set res [alited::bar::BAR listTab]}
  return $res
}
#_______________________

proc find::SessionButtons {} {
  # Prepares buttons' label ("in all/selected tabs").

  namespace upvar ::alited al al obFND obFND
  if {[set llen [llength [alited::bar::BAR listFlag s]]]>1} {
    set btext [string map [list %n $llen] [msgcat::mc {All in %n Files}]]
  } else {
    set btext [msgcat::mc {All in Session}]
  }
  [$obFND But3] configure -text $btext
  [$obFND But6] configure -text $btext
}
#_______________________

proc find::SetCursor {wtxt idx1} {
  # Sets the cursor in a text after a replacement made.
  #   wtxt - text's path
  #   idx1 - starting index of the replacement

  variable data
  set len [string length $data(en2)]
  ::tk::TextSetCursor $wtxt [$wtxt index "$idx1 + ${len}c"]
  ::alited::main::CursorPos $wtxt
}
#_______________________

proc find::LastInvoke {} {
  # Invokes last Find button that was pressed.
  # If Ctrl-F is pressed inside Find/Replace dialogue, the last
  # pressed Find button will be invoked.

  namespace upvar ::alited obFND obFND
  variable data
  [$obFND But$data(lastinvoke)] invoke
}

# _____________________ Search by list ____________________ #

proc find::SearchByList_Options {findstr} {

  namespace upvar ::alited al al
  if {!$al(caseSBL)} {append options {-nocase }}
  # glob search - through its regexp
  switch $al(matchSBL) {
    Glob {
      append options {-regexp }
      set findstr [string map {* .* ? . . \\. \{ \\\{ \} \\\} ( \\( ) \\) ^ \\^ \$ \\\$ - \\- + \\+} $findstr]
    }
    RE {
      append options {-regexp }
    }
    default {
      append options {-exact }}
  }
  return [list $findstr $options]
}
#_______________________

proc find::SearchByList_Do {} {
  # Does searching words by list.

  namespace upvar ::alited al al
  variable counts
  set found [set notfound [list]]
  set wtxt [alited::main::CurrentWTXT]
  set list [string map {\n { }} $al(listSBL)]
  foreach findword [split $list] {
    lassign [SearchByList_Options $findword] findstr options
    if {[catch {set fnd [$wtxt search {*}$options -count alited::find::counts -all -- $findstr 1.0]} err]} {
      alited::Message $err 4
      break
    }
    if {[llength $fnd]} {
      set i 0
      foreach index1 $fnd {
        set index2 [$wtxt index "$index1 + [lindex $counts $i]c"]
        if {[CheckWord $wtxt $index1 $index2 $al(wordonlySBL)]} {
          set word [$wtxt get $index1 $index2]
          if {[lsearch -exact $found $word]==-1} {
            lappend found $word
          }
        }
        incr i
      }
    } else {
      lappend notfound $findword
    }
  }
  alited::msg ok info "[msgcat::mc FOUND:]\n$found\n[string repeat _ 50]\
    \n\n[msgcat::mc {NOT FOUND:}]\n$notfound\n" -text 1 -w {40 70} -h {10 20}
}
#_______________________

proc find::SearchByList {} {
  # Searches words by list.

  namespace upvar ::alited al al obDl3 obDl3
  set head [msgcat::mc {\n Enter a list of words divided by spaces: \n}]
  set text [string map [list $alited::EOL \n] $al(listSBL)]
  if {$al(matchSBL) eq {}} {set al(matchSBL) $al(MC,frExact)}
  lassign [$obDl3 input {} [msgcat::mc {Find by List}] [list \
    tex "{[msgcat::mc List:]} {} {-w 50 -h 8}" "$text" \
    seh1  {{} {} {}} {} \
    radA  {$::alited::al(MC,frMatch)} {"$::alited::al(matchSBL)" "$::alited::al(MC,frExact)" Glob RE} \
    seh2  {{} {} {}} {} \
    chb1  {$::alited::al(MC,frWord)} {$::alited::al(wordonlySBL)} \
    chb2  {$::alited::al(MC,frCase)} {$::alited::al(caseSBL)} \
    ] -head $head -weight bold] res list match wordonly case
  if {$res} {
    set al(listSBL) $list
    set al(matchSBL) $match
    set al(wordonlySBL) $wordonly
    set al(caseSBL) $case
    SearchByList_Do
  }
}

# _____________________ Find/Replace dialogue ____________________ #

proc find::_close {} {
  # Closes Find/Replace dialogue.

  namespace upvar ::alited obFND obFND
  catch {$obFND res $::alited::find::win 0}
  ClearTags
}
#_______________________

proc find::_create {} {
  #$ Creates Find/Replace dialogue.

  namespace upvar ::alited al al obFND obFND
  variable win
  variable geo
  variable minsize
  variable data
  set data(lastinvoke) 1
  set res 1
  set w $win.fra
  while {$res} {
    $obFND makeWindow $w $al(MC,findreplace)
    $obFND paveWindow $w {
      {labB1 - - 1 1    {-st e}  {-t "Find: " -style TLabelFS}}
      {Cbx1 labB1 L 1 9 {-st wes} {-tvar ::alited::find::data(en1) -values {$::alited::find::data(vals1)}}}
      {labB2 labB1 T 1 1 {-st e}  {-t "Replace: " -style TLabelFS}}
      {cbx2 labB2 L 1 9 {-st wes} {-tvar ::alited::find::data(en2) -values {$::alited::find::data(vals2)}}}
      {labBm labB2 T 1 1 {-st e}  {-t "Match: " -style TLabelFS}}
      {radA labBm L 1 1 {-st ws -padx 0}  {-t "Exact" -var ::alited::find::data(v1) -value 1 -style TRadiobuttonFS}}
      {radB radA L 1 1 {-st ws -padx 5}  {-t "Glob" -var ::alited::find::data(v1) -value 2 -tip "Allows to use *, ?, \[ and \]\nin \"find\" string." -style TRadiobuttonFS}}
      {radC radB L 1 5 {-st ws -padx 0 -cw 1}  {-t "RE" -var ::alited::find::data(v1) -value 3 -tip "Allows to use the regular expressions\nin \"find\" string." -style TRadiobuttonFS}}
      {h_2 labBm T 1 9  {-st es -rw 1}}
      {seh  h_2 T 1 9  {-st ews}}
      {chb1 seh  T 1 2 {-st w} {-t "Match whole word only" -var ::alited::find::data(c1) -style TCheckbuttonFS}}
      {chb2 chb1 T 1 2 {-st w} {-t "Match case" -var ::alited::find::data(c2) -style TCheckbuttonFS}}
      {chb3 chb2 T 1 2 {-st w} {-t "Replace by blank" -var ::alited::find::data(c3) -tip "Allows replacements by the empty string,\nin fact, to erase the found ones." -style TCheckbuttonFS}}
      {sev1 chb1 L 5 1 }
      {fralabB3 sev1 L 4 6 {-st nsw} {-borderwidth 0 -relief groove -padding {3 3}}}
      {.labB3 - - - - {pack -anchor w} {-t "Direction:" -style TLabelFS}}
      {.rad1 - - - - {pack -anchor w -padx 0} {-t "Up" -image alimg_up -compound left -var ::alited::find::data(v2) -value 1 -style TRadiobuttonFS}}
      {.rad2 - - - - {pack -anchor w -padx 0} {-t "Down" -image alimg_down -compound left -var ::alited::find::data(v2) -value 2 -style TRadiobuttonFS}}
      {.chb4 - - - - {pack -anchor sw} {-t "Wrap around" -var ::alited::find::data(c4) -style TCheckbuttonFS}}
      {sev2 cbx1 L 10 1 }
      {But1 sev2 L 1 1 {-st we} {-t "Find" -com "::alited::find::Find 1" -style TButtonWestBoldFS}}
      {But2 but1 T 1 1 {-st we} {-t "All in Text" -com "::alited::find::FindInText 2" -style TButtonWestFS}}
      {But3 but2 T 1 1 {-st we} {-com "::alited::find::FindInSession add 3" -style TButtonWestFS}}
      {h_3 but3 T 2 1}
      {but4 h_3 T 1 1 {-st we} {-t Replace -com "::alited::find::Replace" -style TButtonWestBoldFS}}
      {but5 but4 T 1 1 {-st nwe} {-t "All in Text" -com "::alited::find::ReplaceInText" -style TButtonWestFS}}
      {But6 but5 T 1 1 {-st nwe} {-com "::alited::find::ReplaceInSession" -style TButtonWestFS}}
    }
    SessionButtons
    foreach k {f F} {bind $w.cbx1 <Control-$k> {::alited::find::LastInvoke; break}}
    bind $w.cbx1 <Return> "$w.but1 invoke"  ;# hot in comboboxes
    bind $w.cbx2 <Return> "$w.but4 invoke"
    if {$minsize eq ""} {      ;# save default min.sizes
      after idle [list after 100 {
        set ::alited::find::minsize "-minsize {[winfo width $::alited::find::win] [winfo height $::alited::find::win]}"
      }]
    }
    after idle "$w.cbx1 selection range 0 end"
    set res [$obFND showModal $win -geometry $geo {*}$minsize -focus $w.cbx1 -modal no]
    set geo [wm geometry $win] ;# save the new geometry of the dialogue
    destroy $win
    ClearTags
  }
  focus -force [alited::main::CurrentWTXT]
}
#_______________________

proc find::_run {} {
  # Runs Find/Replace dialogue.

  namespace upvar ::alited obFND obFND
  variable win
  GetFindEntry
  if {[winfo exists $win]} {
    SessionButtons
    wm withdraw $win
    wm deiconify $win
    set cbx [$obFND Cbx1]
    focus $cbx
    $cbx selection clear
    after idle "$cbx selection range 0 end"
  } else {
    _create
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
