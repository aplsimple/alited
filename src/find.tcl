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

  # initial geometry of the dialogue
  variable geo root=$::alited::al(WIN)
  variable geo2 $geo

  # -minsize option of the dialogue
  variable minsize {-minsize {400 100}}

  # common data of procs
  variable data; array set data [list]

  # options of "Find/Replace" dialogue
  set data(c1) 0  ;# words only
  set data(c2) 1  ;# case
  set data(c3) 0  ;# by blank
  set data(c4) 1  ;# wrap around

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

proc find::GetWordOfText {{mode ""} {getdollar no}} {
  # Gets a word of text under the cursor.
  #   mode - if "select", try to get the word from a line with a selection
  #   getdollar - if no word found and the cursor is set on $, get "$" as the word
  #  If 'mode' ends with "2", the result includes a range of found string.

  set wtxt [alited::main::CurrentWTXT]
  if {$mode in {noselect noselect2} || \
  [catch {set sel [$wtxt get sel.first sel.last]}]} {
    set idx [$wtxt index insert]
    set line [$wtxt get "$idx linestart" "$idx lineend"]
    set sel [GetWordOfLine $line $idx $mode]
    if {$getdollar && [lindex $sel 0] eq {}} {
      set idx [$wtxt index "insert -1 c"]
      if {[$wtxt get $idx] eq "\$"} {
        set sel "\$ [lrange $sel 1 end]"
      }
    }
  } elseif {[string index $mode end] eq "2"} {
    set sel [list $sel]
  }
  return $sel
}

# ________________________ Search declaration (Ctrl-L) _________________________ #

proc find::LookDecl1 {wtxt isNS} {
  # Searches a declaration in a text.
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
  set tab [alited::bar::CurrentTabID]
  if {$isNS} {
    # search a qualified name: beginning from the current tab
    set tabs [SessionList]
    if {[set i [lsearch -exact -index 0 $tabs $tab]]>0} {
      set tabs [linsert [lreplace $tabs $i $i] 0 $tab]
    }
    if {$withNS} {set what "*$com2"} {set what " $com2"}
  } else {
    # search a non-qualified name: in the current tab only
    set what "*::$com2"
    set tabs $tab
  }
  foreach tab $tabs {
    set TID [lindex $tab 0]
    alited::main::GetText $TID no no
    foreach it $al(_unittree,$TID) {
      lassign $it lev leaf fl1 ttl l1 l2
      if {$leaf} {
        if {[string match $what $ttl] || [string match "*::$ttl" $com2] || $com2 eq $ttl} {
          return [list $l1 $TID $what]
        }
      }
    }
  }
  return [list {} {} [string range $what 1 end]]
}
#_______________________

proc find::LookDecl {{wtxt ""}} {
  # Prepares and runs searching a declaration in a text.
  #   wtxt - the text's path

  namespace upvar ::alited al al obPav obPav
  # switch to the unit tree: 1st to enable the search, 2nd to show units found & selected
  if {!$al(TREE,isunits)} alited::tree::SwitchTree
  lassign [LookDecl1 $wtxt yes] found TID what
  if {$found eq {}} {
    # if the qualified not found, try to find the non-qualified (first encountered)
    lassign [LookDecl1 $wtxt no] found TID
  }
  if {$found ne {}} {
    alited::main::SaveVisitInfo
    alited::favor::SkipVisited yes
    alited::bar::BAR $TID show
    after idle " \
      alited::main::FocusText $TID $found.0 ; \
      alited::tree::NewSelection ; \
      alited::main::SaveVisitInfo"
  } else {
    set msg [string map [list %u $what] $al(MC,notfndunit)]
    alited::Message $msg 4
  }
}

# ________________________ Search units (Ctrl-Shift-F) _________________________ #

proc find::DoFindUnit {} {
  # Runs searching units in current text / all texts.

  namespace upvar ::alited al al obPav obPav
  set ent [$obPav CbxFindSTD]
  set what [string trim [$ent get]]
  if {$what eq {} || [regexp {\s} $what]} {
    alited::Message [msgcat::mc {Incorrect name for a unit.}] 4
    return
  }
  if {[set i [lsearch -exact $al(findunitvals) $what]]>=0} {
    set al(findunitvals) [lreplace $al(findunitvals) $i $i]
  }
  set al(findunitvals) [linsert $al(findunitvals) 0 $what]
  catch {set al(findunitvals) [lreplace $al(findunitvals) $al(FAV,MAXLAST) end]}
  $ent configure -values $al(findunitvals)
  InitShowResults
  set n 0
  if {$alited::main::findunits==1} {
    set tabs [SessionList]
  } else {
    set tabs [alited::bar::CurrentTabID]
  }
  foreach tab $tabs {
    set TID [lindex $tab 0]
    alited::main::GetText $TID no no
    foreach it $al(_unittree,$TID) {
      lassign $it lev leaf fl1 title l1 l2
      set ttl [string range $title [string last : $title]+1 end] ;# pure name, no NS
      if {[string match -nocase "*$what*" $ttl]} {
        set fname [alited::bar::BAR $TID cget -text]
        PutInfo $fname $l1 $title $TID
        incr n
      }
    }
  }
  ShowResults [string map [list %n $n %s $what] $al(MC,frres1)]
}
#_______________________

proc find::FindUnit {} {
  # Displays "Find unit" frame.

  namespace upvar ::alited al al obPav obPav
  set ent [$obPav CbxFindSTD]
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
  alited::info::Put $al(MC,wait) {} yes yes
  update
}
#_______________________

proc find::PutInfo {fname line info TID} {
  # Puts a message to the info listbox widget, about a line found in a file.
  #   fname - the file's name
  #   line - the line's number
  #   info - found info
  #   TID - tab's ID of the file
  # See also: info::Put

  set msg "$fname  :$line:  $info"
  set dat [list $TID $line]
  alited::info::Put $msg $dat
}

# ________________________ Do search _________________________ #

proc find::FoundTag {wtxt} {
  # Adds a tag of found strings to a text widget.
  #   wtxt - path to the text

  namespace upvar ::alited obPav obPav
  if {[$obPav csDark]} {
    set fg white
    set bg #1c1cff
  } else {
    set fg black
    set bg #8fc7ff
  }
  $wtxt tag configure fndTag -borderwidth 1 -relief raised -foreground $fg -background $bg
  $wtxt tag lower fndTag
}
#_______________________

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
  FoundTag $wtxt
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
      PutInfo $fname $l2 [string trim $line] $TID
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
  if {![CheckData find]} return
  if {$inv>-1} {set data(lastinvoke) $inv}
  InitShowResults
  set allfnd [list]
  set data(_ERR_) no
  foreach tab [SessionList] {
    set TID [lindex $tab 0]
    lassign [alited::main::GetText $TID no no] curfile wtxt
    lappend allfnd {*}[FindAll $wtxt $TID $tagme]
    if {$data(_ERR_)} break
  }
  ShowResults1 $allfnd
}
#_______________________

proc find::FindNext {} {
  # Performs "find next" (F3 key) for the current text.

  namespace upvar ::alited al al obPav obPav
  set wtxt [alited::main::CurrentWTXT]
  if {[info exists al(findSearchByList)] && $al(findSearchByList) eq $wtxt} {
    NextFoundByList no
    return
  }
  alited::Message {}
  lassign [$obPav findInText 1 $wtxt] res what
  if {!$res} {
    set msg [msgcat::mc {Not found: %s}]
    alited::Message [string map [list %s $what] $msg] 3
  }
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
    alited::main::UpdateTextGutterTree
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
  ::apave::undoIn $wtxt
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
  ::apave::undoOut $wtxt
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
  if {![alited::msg yesno warn $msg NO]} {
    return {}
  }
  set wtxt [alited::main::CurrentWTXT]
  set TID [alited::bar::CurrentTabID]
  set rn [ReplaceAll $TID $wtxt [Search $wtxt]]
  ShowResults2 $rn $alited::al(MC,frres2)
  alited::main::UpdateTextGutterTree
}
#_______________________

proc find::ReplaceInSession {} {
  # Handles hitting "Replace in Session" button.

  namespace upvar ::alited al al
  variable data
  if {![CheckData repl]} return
  set msg [string map [list %s [FindReplStr $data(en1)] \
    %r [FindReplStr $data(en2)]] $al(MC,frdoit2)]
  if {![alited::msg yesno warn $msg NO]} {
    return {}
  }
  set rn 0
  set waseditcurr no
  set data(_ERR_) no
  foreach tab [SessionList] {
    set TID [lindex $tab 0]
    lassign [alited::main::GetText $TID no no] curfile wtxt
    if {[set rdone [ReplaceAll $TID $wtxt [Search $wtxt]]]} {
      ShowResults2 $rdone $alited::al(MC,frres2) $TID
      incr rn $rdone
      alited::bar::BAR markTab $TID
      if {$wtxt eq [alited::main::CurrentWTXT]} {
        set waseditcurr yes  ;# update the current text's view only
      }
    }
    if {$data(_ERR_)} break
  }
  ShowResults2 $rn $alited::al(MC,frres3)
  if {$waseditcurr} {
    alited::main::UpdateTextGutterTreeIcons
  } elseif {$rn} {
    alited::main::UpdateIcons

  }
}
#_______________________

proc find::btTPaste {} {
  # Copies text from "Find" to "Replace" field.

  namespace upvar ::alited obFND obFND
  variable data
  if {$data(en1) eq {}} {
    focus [$obFND Cbx1]
    bell
  } else {
    [$obFND Cbx1] selection clear
    set data(en2) $data(en1)
    alited::CursorAtEnd [$obFND Cbx2]
  }
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
#_______________________

proc find::FocusCbx1 {{aft idle} {deico ""}} {
  # Set focus on "Find" field.
  #   aft - idle/msec for "after"
  #   deico - deiconify command

  namespace upvar ::alited obFND obFND
  set cbx [$obFND Cbx1]
  after $aft " $deico ; focus $cbx ; $cbx selection range 0 end ; $cbx icursor end"
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

proc find::SearchByList_Do {{show yes}} {
  # Does searching words by list.
  #   show - if yes, shows results

  namespace upvar ::alited al al
  variable counts
  set found [set notfound [list]]
  set wtxt [alited::main::CurrentWTXT]
  set list [string map {\n { }} $al(listSBL)]
  set al(findSearchByList) $wtxt
  FoundTag $wtxt
  ClearTags
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
          $wtxt tag add fndTag $index1 $index2
        }
        incr i
      }
    } else {
      lappend notfound $findword
    }
  }
  if {$show} {
    alited::msg ok info "[msgcat::mc FOUND:]\n$found\n[string repeat _ 50]\
      \n\n[msgcat::mc {NOT FOUND:}]\n$notfound\n" -text 1 -w {40 70} -h {10 20}
  }
}
#_______________________

proc find::SearchByList {} {
  # Searches words by list.

  namespace upvar ::alited al al obFN2 obFN2
  set al(findSearchByList) {}
  variable geo2
  set head [msgcat::mc {\n Enter a list of words divided by spaces: \n}]
  while {1} {
    after 300 {catch {bind [apave::dlgPath] <F3> alited::find::NextFoundByList}}
    set text [string map [list $alited::EOL \n] $al(listSBL)]
    if {$al(matchSBL) eq {}} {set al(matchSBL) $al(MC,frExact)}
    after idle [list catch {set ::alited::al(FN2WINDOW) $::apave::MODALWINDOW}]
    lassign [$obFN2 input {} [msgcat::mc {Find by List}] [list \
      Text "{[msgcat::mc List:]} {} {-w 50 -h 8 -tabnext {*radA1 *CANCEL}}" "$text" \
      seh1  {{} {} {}} {} \
      radA  {$::alited::al(MC,frMatch)} {"$::alited::al(matchSBL)" "$::alited::al(MC,frExact)" Glob RE} \
      seh2  {{} {} {}} {} \
      chb1  {$::alited::al(MC,frWord)} {$::alited::al(wordonlySBL)} \
      chb2  {$::alited::al(MC,frCase)} {$::alited::al(caseSBL)} \
      ] -head $head -buttons {ButNxt {Find Next} ::alited::find::NextFoundByList} -weight bold -modal no -ontop [::isKDE] -geometry $geo2 -help {alited::find::HelpFind 2}] \
      res geo - values
    lassign $values list match wordonly case
    if {$res} {
      lassign [::apave::splitGeometry $geo] - - x y
      if {$x<0} {set x {+0}}
      if {$y<0} {set y {+0}}
      set geo2 $x$y
      set al(listSBL) [string trim $list]
      set al(matchSBL) $match
      set al(wordonlySBL) $wordonly
      set al(caseSBL) $case
      SearchByList_Do
    } else {
      break
    }
  }
  unset al(findSearchByList)
  ClearTags
}
#_______________________

proc find::HelpFind {suff} {
  # Helps on search by list.
  #   suff - help's suffix

  alited::Help [apave::dlgPath] $suff
}
#_______________________

proc find::NextFoundByList {{focusDLG yes}} {
  # Finds next occurence of found strings.
  #   focusDLG - if yes, focuses on "First by List" dialogue, otherwise the text is focused

  namespace upvar ::alited obFN2 obFN2
  set wtxt [alited::main::CurrentWTXT]
  set pos0 [$wtxt tag nextrange fndTag 1.0]
  if {$pos0 eq {}} {
    SearchByList_Do no
    set pos0 [$wtxt tag nextrange fndTag 1.0]
  }
  set pos [$wtxt index insert]
  set nextpos [$wtxt tag nextrange fndTag "$pos + 1c"]
  if {$nextpos eq {}} {set nextpos $pos0}
  if {$nextpos eq {}} {
    bell
  } else {
    alited::main::FocusText [alited::bar::CurrentTabID] [lindex $nextpos 0]
  }
  if {$focusDLG} {
    if {$nextpos eq {}} {
      focus [$obFN2 Text]
    } else {
      focus [$obFN2 ButNxt]
    }
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
  set data(geoDefault) 0
  set res 1
  set w $win.fra
  while {$res} {
    $obFND makeWindow $w $al(MC,findreplace) -type dialog
    $obFND paveWindow $w {
      {labB1 - - 1 1    {-st es -ipadx 0 -padx 0 -ipady 0 -pady 0}  {-t "Find: " -style TLabelFS}}
      {Cbx1 + L 1 4 {-st wes -ipadx 0 -padx 0 -ipady 0 -pady 0} {-tvar ::alited::find::data(en1) -values {$::alited::find::data(vals1)}}}
      {labB2 labB1 T 1 1 {-st es -ipadx 0 -padx 0 -ipady 0 -pady 0}  {-t "Replace: " -style TLabelFS}}
      {Cbx2 + L 1 3 {-st wes -ipadx 0 -padx 0 -ipady 0 -pady 0} {-tvar ::alited::find::data(en2) -values {$::alited::find::data(vals2)}}}
      {btTpaste + L 1 1 {-ipady 0 -pady 0} {-com alited::find::btTPaste -tip "Paste 'Find'\nCtrl+R"}}
      {labBm labB2 T 1 1 {-st ens -ipadx 0 -padx 0 -ipady 0 -pady 0}  {-t "Match: " -style TLabelFS}}
      {radA + L 1 1 {-st ens -ipadx 0 -padx 0 -ipady 0 -pady 0}  {-t "Exact" -var ::alited::find::data(v1) -value 1 -style TRadiobuttonFS}}
      {radB + L 1 1 {-st wns -padx 5 -ipady 0 -pady 0}  {-t "Glob" -var ::alited::find::data(v1) -value 2 -tip "Allows to use *, ?, \[ and \]\nin \"find\" string." -style TRadiobuttonFS}}
      {radC + L 1 1 {-st wns -ipadx 0 -padx 0 -ipady 0 -pady 0 -cw 1}  {-t "RE" -var ::alited::find::data(v1) -value 3 -tip "Allows to use the regular expressions\nin \"find\" string." -style TRadiobuttonFS}}
      {h_2 labBm T 1 5  {-st es -rw 1 -ipadx 0 -padx 0 -ipady 0 -pady 0}}
      {seh  + T 1 5  {-st ews -ipadx 0 -padx 0 -ipady 0 -pady 0}}
      {chb1 +  T 1 2 {-st w -ipadx 0 -padx 0 -ipady 0 -pady 0} {-t "Match whole word" -var ::alited::find::data(c1) -style TCheckbuttonFS}}
      {chb2 + T 1 2 {-st w -ipadx 0 -padx 0 -ipady 0 -pady 0} {-t "Match case" -var ::alited::find::data(c2) -style TCheckbuttonFS}}
      {chb3 + T 1 2 {-st w -ipadx 0 -padx 0 -ipady 0 -pady 0} {-t "Replace by blank" -var ::alited::find::data(c3) -tip "Allows replacements by the empty string,\nin fact, to erase the found ones." -style TCheckbuttonFS}}
      {sev1 chb1 L 4 1 }
      {rad1 + L 1 2 {-st w -ipadx 0 -padx 0 -ipady 0 -pady 0} {-t "Up" -image alimg_up -compound left -var ::alited::find::data(v2) -value 1 -style TRadiobuttonFS}}
      {rad2 +  T 1 2 {-st w -ipadx 0 -padx 0 -ipady 0 -pady 0} {-t "Down" -image alimg_down -compound left -var ::alited::find::data(v2) -value 2 -style TRadiobuttonFS}}
      {chb4 +  T 1 2 {-st w -ipadx 0 -padx 0 -ipady 0 -pady 0} {-t "Wrap" -var ::alited::find::data(c4) -style TCheckbuttonFS}}
      {sev2 cbx1 L 9 1}
      {But1 + L 1 1 {-st wes -pady 2} {-t "Find" -com "::alited::find::Find 1" -style TButtonWestBoldFS}}
      {But2 + T 1 1 {-st we -pady 0} {-t "All in Text" -com "::alited::find::FindInText 2" -style TButtonWestFS}}
      {But3 + T 1 1 {-st wen -pady 2} {-com "::alited::find::FindInSession add 3" -style TButtonWestFS}}
      {Chb + T 2 1 {-st en} {-var ::alited::find::data(geoDefault) -tip "Use this geometry of the dialogue\nby default" -takefocus 0}}
      {but4 + T 1 1 {-st wes -pady 2} {-t Replace -com "::alited::find::Replace" -style TButtonWestBoldFS}}
      {but5 + T 1 1 {-st we -pady 0} {-t "All in Text" -com "::alited::find::ReplaceInText" -style TButtonWestFS}}
      {But6 + T 1 1 {-st wen -pady 2} {-com "::alited::find::ReplaceInSession" -style TButtonWestFS}}
    }
    SessionButtons
    alited::keys::BindAllKeys [alited::main::CurrentWTXT] yes
    bind $win <Enter> alited::find::SessionButtons
    bind $win <F1> {alited::HelpAlited #search1}
    bind $win <F3> "$w.but1 invoke"
    bind $w.cbx1 <Return> "$w.but1 invoke"  ;# hotkeys in comboboxes
    bind $w.cbx2 <Return> "$w.but4 invoke"
    foreach k {f F} {bind $win <Control-$k> {::alited::find::LastInvoke; break}}
    foreach k {r R} {bind $win <Control-$k> {::alited::find::btTPaste; break}}
    FocusCbx1 100 "wm deiconify $win"
    set res [$obFND showModal $win -geometry $geo {*}$minsize -resizable 1 -modal no -ontop no]
    if {[string match root=* $geo] || $data(geoDefault)} {
      set geo [wm geometry $win] ;# save the new geometry of the dialogue
    }
    destroy $win
    ClearTags
  }
  focus -force [alited::main::CurrentWTXT]
}
#_______________________

proc find::_run {} {
  # Runs Find/Replace dialogue.

  variable win
  update  ;# if run from menu: there may be unupdated space under it (in some DE)
  GetFindEntry
  if {[::apave::repaintWindow $win]} {
    SessionButtons
    FocusCbx1
  } else {
    _create
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
