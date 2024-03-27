###########################################################
# Name:    edit.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    08/29/2021
# Brief:   Handles editing procedures.
# License: MIT.
###########################################################


namespace eval edit {
  variable hlcolors [list]
  variable ans_hlcolors 0
  variable macrosmode init
}
# ________________________ Indent _________________________ #

proc edit::SelectedLines {{wtxt ""} {strict no}} {
  # Gets a range of lines of text that are selected at least partly.
  #   wtxt - text's path
  #   strict - if yes, only a real selection is counted
  # Returns a list of the text widget's path and ranges of selected lines.

  if {$wtxt eq {}} {set wtxt [alited::main::CurrentWTXT]}
  set res [list $wtxt]
  if {[catch {$wtxt tag ranges sel} sels] || ![llength $sels]} {
    if {$strict} {
      set sels [list]
    } else {
      set pos1 [set pos2 [$wtxt index insert]]
      set sels [list $pos1 $pos2]
    }
  }
  foreach {pos1 pos2} $sels {
    if {$pos1 ne {}} {
      set pos21 [$wtxt index "$pos2 linestart"]
      if {[$wtxt get $pos21 $pos2] eq {}} {
        set pos2 [$wtxt index "$pos2 - 1 line"]
      }
    }
    set l1 [expr {int($pos1)}]
    set l2 [expr {max($l1,int($pos2))}]
    lappend res $l1 $l2
  }
  return $res
}
#_______________________

proc edit::Indent {} {
  # Indent selected lines of text.

  set indent $::apave::_AP_VARS(INDENT)
  set len [string length $::apave::_AP_VARS(INDENT)]
  set sels [SelectedLines]
  set wtxt [lindex $sels 0]
  ::apave::undoIn $wtxt
  foreach {l1 l2} [lrange $sels 1 end] {
    for {set l $l1} {$l<=$l2} {incr l} {
      set line [$wtxt get $l.0 $l.end]
      if {[string trim $line] eq {}} {
        $wtxt replace $l.0 $l.end {}
      } else {
        set leadsp [::apave::obj leadingSpaces $line]
        set sp [expr {$leadsp % $len}]
        # align by the indent edge
        if {$sp==0} {
          set ind $indent
        } else {
          set ind [string repeat " " [expr {$len - $sp}]]
        }
        $wtxt insert $l.0 $ind
      }
    }
  }
  ::apave::undoOut $wtxt
  alited::main::HighlightLine
}
#_______________________

proc edit::UnIndent {} {
  # Unindent selected lines of text.

  set len [string length $::apave::_AP_VARS(INDENT)]
  set spaces [list { } \t]
  set sels [SelectedLines]
  set wtxt [lindex $sels 0]
  ::apave::undoIn $wtxt
  foreach {l1 l2} [lrange $sels 1 end] {
    for {set l $l1} {$l<=$l2} {incr l} {
      set line [$wtxt get $l.0 $l.end]
      if {[string trim $line] eq {}} {
        $wtxt replace $l.0 $l.end {}
      } elseif {[string index $line 0] in $spaces} {
        set leadsp [::apave::obj leadingSpaces $line]
        # align by the indent edge
        set sp [expr {$leadsp % $len}]
        if {$sp==0} {set sp $len}
        $wtxt delete $l.0 "$l.0 + ${sp}c"
      }
    }
  }
  ::apave::undoOut $wtxt
}
#_______________________

proc edit::NormIndent {} {
  # Normalizes a current text's indenting.

  alited::main::CalcIndentation {} yes
  alited::main::UpdateProjectInfo
  if {![namespace exists ::alited::indent]} {
    namespace eval ::alited {
      source [file join $::alited::SRCDIR indent.tcl]
    }
  }
  alited::indent::normalize
}

# ________________________ Comment in / out _________________________ #

proc edit::SelectLines {wtxt l1 l2} {
  # Selects lines (all their contents) of text.
  #   wtxt - text's path
  #   l1 - starting line
  #   l2 - ending line

  $wtxt tag remove sel 1.0 end
  $wtxt tag add sel $l1.0 [incr l2].0 ;# $l1.0 $l2.end
}
#_______________________

proc edit::CommentChar {} {
  # Returns the commenting chars for a current file.

  set fname [alited::bar::FileName]
  if {[alited::file::IsClang $fname]} {
    return //
  }
  return #
}
#_______________________

proc edit::Comment {} {
  # Comments selected lines of text.
  # See also: UnComment

  namespace upvar ::alited obPav obPav al al
  set ch [CommentChar]
  set sels [SelectedLines]
  set wtxt [lindex $sels 0]
  ::apave::undoIn $wtxt
  foreach {l1 l2} [lrange $sels 1 end] {
    for {set l $l1} {$l<=$l2} {incr l} {
      set line [$wtxt get $l.0 $l.end]
      set col [$obPav leadingSpaces $line]
      switch $al(commentmode) {
        1 {$wtxt insert $l.0 $ch}
        2 {$wtxt insert $l.$col $ch}
        default {
          if {$ch eq "#"} {
            # comment-out with TODO comment: to see / to find / to do them afterwards
            # for Tcl code: it needs to disable also all braces with #\{ #\} patterns
            $wtxt replace $l.0 $l.end [string map [list \} #\\\} \{ #\\\{] $line]
          }
          $wtxt insert $l.0 $ch!
        }
      }
    }
  }
  ::apave::undoOut $wtxt
  SelectLines $wtxt $l1 $l2
  after idle alited::tree::RecreateTree
}
#_______________________

proc edit::UnComment {} {
  # Uncomments selected lines of text.
  # See also: Comment

  namespace upvar ::alited obPav obPav al al
  set ch [CommentChar]
  set lch [string length $ch]
  set lch0 [expr {$lch-1}]
  set sels [SelectedLines]
  set wtxt [lindex $sels 0]
  ::apave::undoIn $wtxt
  foreach {l1 l2} [lrange $sels 1 end] {
    for {set l $l1} {$l<=$l2} {incr l} {
      set line [$wtxt get $l.0 $l.end]
      set isp [$obPav leadingSpaces $line]
      if {[string range $line $isp $isp+$lch0] eq $ch} {
        set lch2 $lch
        if {[regexp "^\\s*$ch!" $line]} {incr lch2}  ;# remove TODO comment
        $wtxt delete $l.$isp "$l.$isp + ${lch2}c"
        if {$ch eq "#" && !$al(commentmode)} {
          # for Tcl code: it needs to enable also all braces with #\{ #\} patterns
          set line [$wtxt get $l.0 $l.end]
          $wtxt replace $l.0 $l.end [string map [list #\\\} \} #\\\{ \{] $line]
        }
      }
    }
  }
  ::apave::undoOut $wtxt
  SelectLines $wtxt $l1 $l2
  after idle alited::tree::RecreateTree
}

# ________________________ Color values _________________________ #

proc edit::FindColorValues {mode} {
  # Finds color values.
  #   mode - 1 for "find in all text", 2 for "find in current page", 3 "return RF"

  namespace upvar ::alited obPav obPav
  set RF {#([0-9a-fA-F]{3,6})}
  if {$mode==3} {return $RF}
  set RE {#([0-9a-f]{3}([^0-9a-z]|$)|[0-9a-f]{6}([^0-9a-z]|$))}
  set txt [alited::main::CurrentWTXT]
  set l1 1.0
  set l2 end
  if {$mode in {2 12} && \
  ![catch {set gcon [$obPav gutterContents $txt]}] && [llength $gcon]} {
    set l1 [string trim [lindex $gcon 0 1]].0
    set l2 [string trim [lindex $gcon end 1]].end
  }
  set lenList [set hlcolors [list]]
  set posList [$txt search -count lenList -regexp -nocase -all -strictlimits $RE $l1 $l2]
  foreach pos $posList len $lenList {
    if {$len eq {}} {
      set st [$txt get $pos "$pos lineend + 1 char"]
      set len [lindex [regexp -nocase -indices -inline $RE $st] 1 1]
    }
    set pos2 [$txt index "$pos + $len char"]
    set hlc [$txt get $pos $pos2]
    catch {
      lassign [InvertBg $hlc] fg bg
      $txt tag configure $hlc -foreground $fg -background $bg
      $txt tag add $hlc $pos $pos2
      lappend hlcolors $hlc
    }
  }
  return [list [llength $hlcolors] $RF]
}
#_______________________

proc edit::ShowColorValues {} {
  # Highlights color values.

  namespace upvar ::alited al al obFND obFND
  variable hlcolors
  variable ans_hlcolors
  if {$ans_hlcolors<10} {
    set ans_hlcolors [alited::msg yesnocancel ques \
      [msgcat::mc {Display colors in the whole text?}] YES \
      -title $al(MC,hlcolors) -ch $al(MC,noask)]
  }
  if {!$ans_hlcolors} return
  HideColorValues
  lassign [FindColorValues $ans_hlcolors] llen RF
  if {[winfo exists $::alited::find::win] && [winfo ismapped $::alited::find::win]} {
    set ::alited::find::data(en1) $RF  ;# if "Find/Replace" is shown, set Find = RE
    [$obFND Cbx1] selection clear
    set msg "   ([msgcat::mc {check RE in Find/Replace box}])"
    set mode 3
  } else {
    set msg {}
    set mode 1
  }
  alited::Message $al(MC,hlcolors):\ $llen\ $msg $mode
}
#_______________________

proc edit::HideColorValues {} {
  # Unhighlights color values.

  set RF [FindColorValues 3]
  set txt [alited::main::CurrentWTXT]
  foreach hlc [$txt tag names] {
    if {[regexp $RF $hlc]} {
      $txt tag remove $hlc 1.0 end
    }
  }
}
#_______________________

proc edit::InvertBg {clr} {
  # Gets a "inverted" color (white/black) for an color.
  #   clr - color (#hhh or #hhhhhh)
  # Returns a list of "inverted" color and "normalized" input color

  if {[string length $clr]==4} {
    lassign [split $clr {}] -> r g b
    set clr #$r$r$g$g$b$b
  }
  scan $clr "#%02x%02x%02x" r g b
  set c [expr {$r<100 && $g<100 || $r<100 && $b<100 || $b<100 && $g<100 ||
    ($r+$g+$b)<300 ? 255 : 0}]
  set res [string toupper [format "#%02x%02x%02x" $c $c $c]]
  return [list $res $clr]
}

# ________________________ At modifications _________________________ #

proc edit::BackupFile {TID {mode {}}} {
  # Makes a backup copy of a file after the first modification of it.
  #   TID - tab's ID of the file
  #   mode - if {orig}, makes an original copy of a file, otherwise makes .bak copy

  namespace upvar ::alited al al
  lassign [BackupDirFileNames $TID] dir fname fname2
  if {$dir ne {}} {
    if {$mode eq {}} {
      set fname2 [BackupFileName $fname2]
    }
    catch {
      file copy -force $fname $fname2
      ::apave::logMessage "backup $fname -> $fname2"
    }
  }
}
#_______________________

proc edit::BackupDirFileNames {TID} {
  # Gets directory and file names for backuping.
  #   TID - current tab's ID
  # Returns a list of names:
  #   directory, source file, target original file

  namespace upvar ::alited al al
  if {$al(BACKUP) eq {}} {return {}}
  set dir [file join $al(prjroot) $al(BACKUP)]
  set fname [alited::bar::FileName $TID]
  set fname2 [file join $dir [file tail $fname]]
  if {![file exists $dir] && [catch {file mkdir $dir} err]} {
    alited::msg ok err $err
    return {}
  }
  set fname3 [file join $dir [file tail $fname]]
  return [list $dir $fname $fname2]
}
#_______________________

proc edit::BackupFileName {fname {iincr 1}} {
  # Gets a backup name for a file (checking for backup's maximum).
  #   fname - name of target file
  #   iincr - incrementation for backup index
  # The iincr parameter is used to get the last backup's name:
  # if no backups, the empty string is returned.

  namespace upvar ::alited al al
  if {$al(MAXBACKUP)>1} {
    if {[catch {set baks [glob ${fname}*]}] || $baks eq {}} {
      set nbak 1
      if {!$iincr} {return {}} ;# no backups yet
    } else {
      foreach bak $baks {
        lappend bakdata [list [file mtime $bak] $bak]
      }
      set bakdata [lsort -decreasing $bakdata]
      set bak1 [lindex $bakdata 0 1]
      set nbak [lindex [split $bak1 -.] end-1]
      foreach delbak [lrange $bakdata $al(MAXBACKUP) end] {
        catch {file delete [lindex $delbak 1]}
      }
      if {[catch {incr nbak $iincr}] || $nbak>$al(MAXBACKUP)} {set nbak 1}
    }
    append fname -$nbak.bak
  }
  return $fname
}
#_______________________

proc edit::CheckUndoRedoIcons {wtxt TID} {
  # Checks for states of undo/redo button for a file being modified.
  #   wtxt - text's path
  #   TID - tab's ID of the file

  set TIDundo [alited::bar::BAR cget --TIDundo]
  set oldundo [alited::bar::BAR $TID cget --undo]
  set oldredo [alited::bar::BAR $TID cget --redo]
  set newundo [$wtxt edit canundo]
  set newredo [$wtxt edit canredo]
  if {$TIDundo ne $TID || $oldundo ne $newundo} {
    if {$newundo} {set stat normal} {set stat disabled}
    [alited::tool::ToolButName undo] configure -state $stat
    alited::bar::BAR $TID configure --undo $newundo
  }
  if {$TIDundo ne $TID || $oldredo ne $newredo} {
    if {$newredo} {set stat normal} {set stat disabled}
    [alited::tool::ToolButName redo] configure -state $stat
    alited::bar::BAR $TID configure --redo $newredo
  }
  if {$oldundo ne {} && !$oldundo && !$oldredo && $newundo} {
    BackupFile $TID orig
  }
  alited::bar::BAR configure --TIDundo $TID
}
#_______________________

proc edit::CheckSaveIcons {modif} {
  # Checks for states of save buttons at modifications of files.
  #   modif - yes, if a file has been modified

  namespace upvar ::alited al al
  set marked [alited::bar::BAR listFlag "m"]
  set b_save [alited::tool::ToolButName SaveFile]
  set b_saveall [alited::tool::ToolButName saveall]
  if {![llength $marked]} {
    foreach but {SaveFile saveall} {
      [alited::tool::ToolButName $but] configure -state disabled
    }
  } else {
    if {$modif} {set stat normal} {set stat disabled}
    $b_save configure -state $stat
    $b_saveall configure -state normal
  }
  $al(MENUFILE) entryconfigure 5 -state [$b_save cget -state]
  $al(MENUFILE) entryconfigure 7 -state [$b_saveall cget -state]
}
#_______________________

proc edit::Modified {TID wtxt {l1 0} {l2 0} args} {
  # Handles a modification of file, recreating the unit tree at need.
  #   TID - tab's ID
  #   wtxt - text's path
  #   l1 - 1st line of unit
  #   l2 - last line of unit

  namespace upvar ::alited al al obPav obPav
  if {[alited::bar::BAR isTab $TID]} {
    set old [alited::file::IsModified $TID]
    set new [$wtxt edit modified]
    if {$old != $new} {
      if {$new} {
        alited::bar::BAR markTab $TID
      } else {
        alited::bar::BAR unmarkTab $TID
      }
      CheckSaveIcons $new
    }
    CheckUndoRedoIcons $wtxt $TID
    if {$al(TREE,isunits)} {
      set pos [$wtxt index insert]
      set wtree [$obPav Tree]
      set todoTree no
      catch {set todoTree [$wtree tag has tagTODO [alited::tree::CurrentItem]]}
      # when text's TODO tag isn't equal to tree's, recreate the tree
      lassign [$wtxt tag nextrange tagCMN2 \
        [$wtxt index "$pos linestart"] [$wtxt index "$pos lineend"]] p1 p2
      if {$p2 ne {} && [$wtxt compare $pos >= $p1] && [$wtxt compare $pos <= $p2]} {
        set todo [expr {!$todoTree}]
      } else {
        set todo $todoTree
      }
      if {$todo} {
        alited::tree::RecreateTree
      } elseif {![info exists al(RECREATE)] || $al(RECREATE)} {
        set doit no
        if {[set llen [llength $al(_unittree,$TID)]]} {
          set lastrow [lindex $al(_unittree,$TID) $llen-1 5]
          set doit [expr {$lastrow != int([$wtxt index {end -1c}])}]
        }
        set l1 [expr {int($pos)}]
        set line [$wtxt get $l1.0 $l1.end]
        if {$doit || (![catch {set ifound [lsearch -index 4 $al(_unittree,$TID) $l1]}] \
        && $ifound>-1) || [regexp [alited::unit::UnitRegexp] $line]} {
          alited::tree::RecreateTree
        } else {
          set REtd {(#\s*(!|TODO))|(//\s*(!|TODO))} ;# RE for todo in Tcl and C
          if {$al(INI,LEAF) && [regexp $al(RE,leaf) $line] || [regexp $REtd $line] \
          || !$al(INI,LEAF) && [regexp $al(RE,proc) $line] || [regexp $al(RE,branch) $line]} {
            alited::tree::RecreateTree
          }
        }
      }
    }
  }
  alited::main::ShowHeader
}
#_______________________

proc edit::RemoveTrailWhites {{TID ""} {doit no} {skipGUI no}} {
  # Removes trailing spaces of lines - all of lines or a selection of lines.
  #   TID - tab ID
  #   doit - if yes, trimright all of text without questions
  #   skipGUI - if yes, no updating GUI

  namespace upvar ::alited al al
  set ans 1
  if {!$doit} {
    set TID [alited::bar::CurrentTabID]
    # ask about trailing all lines of a current file (with option: all of other files)
    set msg [msgcat::mc "Remove trailing whitespaces of all lines\nof \"%f\"?"]
    set msg [string map [list %f [file tail [alited::bar::FileName]]] $msg]
    set ans [alited::msg yesno ques $msg \
      YES -title {Remove trailing whitespaces} -ch $al(MC,otherfiles)]
    if {![set doit $ans]} return
  }
  set waseditcurr no
  foreach tab [alited::bar::BAR listTab] {
    set tid [lindex $tab 0]
    if {$ans==11 || $tid eq $TID} {
      if {[set curt [expr {$tid eq [alited::bar::CurrentTabID]}]]} {
        set curl [expr {int([[alited::main::GetWTXT $tid ] index insert])}]
      }
      lassign [alited::main::GetText $tid no no] -> wtxt
      set l1 1
      set l2 [expr {int([$wtxt index {end -1c}])}]
      set wasedit no
      for {set l $l1} {$l<=$l2} {incr l} {
        set line [$wtxt get $l.0 $l.end]
        if {[set trimmed [string trimright $line]] ne $line && $curt && $l!=$curl} {
          if {!$wasedit} {::apave::undoIn $wtxt}
          set wasedit yes
          $wtxt replace $l.0 $l.end $trimmed
        }
      }
      if {$wasedit} {
        ::apave::undoOut $wtxt
        alited::bar::BAR markTab $tid
        if {$wtxt eq [alited::main::CurrentWTXT]} {
          set waseditcurr yes  ;# update the current text's view only
        }
      }
    }
  }
  if {!$skipGUI} {
    if {$waseditcurr} {
      alited::main::UpdateTextGutterTreeIcons
    } else {
      alited::main::UpdateIcons
    }
  }
}

# ________________________ Macros _________________________ #

## ________________________ Preparing macros _________________________ ##

proc edit::MacroSource {} {
  # Loads playtkl package.

  if {[info command ::playtkl::play] eq {}} {
    namespace eval :: {
      source [file join $::alited::LIBDIR playtkl playtkl.tcl]
    }
  }
}
#_______________________

proc edit::MacroInit {} {
  # Initializes macro stuff.

  MacroSource
  ::playtkl::inform no
}
#_______________________

proc edit::MacroDir {} {
  # Gets a directory name of macros.

  return [file dirname [MacroFileName .]]
}
#_______________________

proc edit::MacroFileName {name {dir ""}} {
  # Gets a file name for a macro.
  #   name - macro's name
  #   dir - macro's directory

  namespace upvar ::alited al al USERDIR USERDIR
  if {[file extension $name] ne $al(macroext)} {
    append name $al(macroext)
  }
  if {$dir eq {}} {
    set dir [file join $USERDIR macro]
  }
  return [file normalize [file join $dir [file tail $name]]]
}
#_______________________

proc edit::MacroMenu {name doit} {
  # Recreate macros' menu.
  #   name - current macro
  #   doit - yes if update anyway

  namespace upvar ::alited al al
  MacroSource
  set fname [MacroFileName $name]
  if {$doit || $al(activemacro) ne $name} {
    set al(activemacro) $name
    playtkl::readcontents $fname
    alited::menu::FillMacroItems
  } elseif {$al(activemacro) eq $name} {
    playtkl::readcontents $fname
  }
}
#_______________________

proc edit::MacroExists {fname} {
  # Checks for existing macro.
  # If the macro doesn't exist, shows a message and updates the macros list menu.
  #   fname - macro file name

  if {[file exists $fname]} {return yes}
  alited::Balloon1 $fname
  after idle alited::menu::FillMacroItems
  return no
}
#_______________________

proc edit::MacroUpdate {fname} {
  # If a file is a macro, updates macros' list.
  #   fname - file name

  namespace upvar ::alited al al
  if {[file extension $fname] eq $al(macroext)} {
    after idle [list alited::edit::MacroMenu $fname yes]
  }
}

## ________________________ Handling macros _________________________ ##

proc edit::DoMacro {mode {fname ""}} {
  # Plays or records a macro.
  #   mode - play / record
  #   fname - name of recorded file

  namespace upvar ::alited al al
  variable macrosmode
  MacroInit
  if {$macrosmode eq "record"} {  ;# repeated recording?
    ::playtkl::end
    WatchMacro
    return no
  }
  set name [file rootname [file tail $fname]]
  if {$fname ne {}} {
    set fname [MacroFileName $fname]
    if {$mode eq "play"} {
      if {[MacroExists $fname]} {
        # play the macro after a pause to dismiss intervening events
        after 50 [list after idle [list after 50 [list after idle alited::edit::DoMacro $mode]]]
      }
      return no
    }
  }
  set wtxt [alited::main::CurrentWTXT]
  after idle "focus $wtxt"
  set macrosmode $mode
  switch $mode {
    "record" {
      set al(activemacro) $name
      after 100 [list ::playtkl::record $fname $al(acc_16) $al(macromouse)]
      after 200 alited::edit::WatchMacro
      alited::Message "[msgcat::mc Recording:] $name" 5; bell
      bell
    }
    "play" {
      if {$fname ne {}} {
        alited::Message "[msgcat::mc Playing:] $name" 3
      } else {
        alited::Message {}
      }
      focus $wtxt
      ::apave::undoIn $wtxt
      ::playtkl::replay $fname "::apave::undoOut $wtxt" [list *frAText.text* $wtxt] yes $wtxt
    }
  }
  return yes
}
#_______________________

proc edit::InputMacro {idx} {
  # Enters/changes a macro.
  #   idx - index in macro menu

  namespace upvar ::alited al al obDl2 obDl2
  variable macrosmode
  set win $al(WIN).macro
  if {[winfo exists $win]} {
    ::apave::FocusByForce [$obDl2 chooserPath Fil]
    return
  }
  set m $al(MENUEDIT).playtkl
  incr idx ;# for -tearoff menu
  set al(macromouse) no
  set al(_macro) [$m entrycget $idx -label]
  set al(_macroDir) {}
  set dir [MacroDir]
  ReadMacroComment $al(_macro)
  set head [msgcat::mc "The macro is updated at its recording.\nPress %s to play it."]
  set head [string map [list %s $al(acc_16)] $head]
  $obDl2 makeWindow $win.fra $al(MC,playtkl)
  $obDl2 paveWindow $win.fra { \
    {lab - - 1 4 {-padx 4} {-t {$head}}} \
    {Fil + T 1 4 {-pady 4 -padx 4 -st ew} \
      "-tvar ::alited::al(_macro) -validate all \
      -validatecommand alited::edit::ValidMacro -w 30 -initialdir {$dir} \
      -filetypes {{{Macros} $al(macroext)} {{All files} .*}}"} \
    {chb + T 1 4 {-st w -pady 4} {-t {Record mouse} -var ::alited::al(macromouse)}} \
    {seh + T 1 4 {-pady 4}} \
    {lab2 + T 1 4 {} {-t Comment:}} \
    {fra0 + T 1 4 {-rw 1 -st nsew}} \
    {.TexCmn L + - - {pack -side left -expand 1 -fill both -padx 3} \
      {-h 4 -w 40 -wrap word -tabnext *.but1 -rotext ::alited::al(macrocomment) -ro 0}} \
    {.sbvText + L - - {pack}} \
    {seh2 fra0 T 1 4 {-pady 4}} \
    {fra + T 1 1 {-st w}} \
    {.ButPlay - - 1 1 {-padx 4} {-com 1 -tip "Play Macro" -image alimg_run}} \
    {.ButRec + L 1 1 {} {-com 2 -tip "Record Macro" -image alimg_change}} \
    {.ButDel + L 1 1 {-padx 4} {-com 3 -tip "Delete Macro" -image alimg_delete}} \
    {h_ fra L 1 1 {-st we -cw 1}} \
    {buth + L 1 1 {-st e} {-t Help -com alited::edit::HelpOnMacro}} \
    {but + L 1 1 {-st e} {-com 0 -t Cancel}} \
  }
  set tex [$obDl2 TexCmn]
  bind $win <F1> alited::edit::HelpOnMacro
  set butplay [$obDl2 ButPlay]
  bind $win <$al(acc_16)> "if {\[$butplay cget -state\] eq {normal}} {$butplay invoke}"
  after 200 ::apave::MouseOnWidget $butplay
  set res [$obDl2 showModal $win -resizable 1 -focus $win.fra.entfil -geometry pointer+10+10]
  set al(macrocomment) [$tex get 1.0 end]
  catch {destroy $win}
  set name [::apave::NormalizeFileName [file root [file tail $al(_macro)]]]
  set fname [MacroFileName $name]
  if {$al(_macroDir) ni {. ""}} {
    # if chosen macro doesn't exist in user's dir, copy it there
    set fchosen [MacroFileName $name $al(_macroDir)]
    if {$fchosen ne $fname && ![file exists $fname]} {
      catch {file copy $fchosen $fname}
      after idle alited::menu::FillMacroItems
    }
    set fname $fchosen
  }
  unset al(_macro)
  unset al(_macroDir)
  if {!$res} {
    set macrosmode "init"
    return
  }
  if {[string length $name]>99 || $name eq {}} {
    alited::Msg [string map [list %n $name] $al(MC,incorrname)] err
    return
  }
  switch $res {
    1 {
      MacroMenu $name no
      if {[DoMacro play $name]} {
        set macrosmode "play"
      }
    }
    2 {
      if {[file exists $fname]} {
        if {![info exists al(macrotorew)] || ![string match *10 $al(macrotorew)]} {
          set msg [string map [list %f [file tail $fname] %d [file dirname $fname]] \
            $al(MC,fileexist)]
          set dlg [::apave::APave new]
          set al(macrotorew) [$dlg misc warn \
            $al(MC,playtkl) $msg {"Rewrite" File "Edit" Change "Cancel" 0} \
            0 -ch $al(MC,noask) -centerme $al(WIN)]
          $dlg destroy
        }
        switch -glob $al(macrotorew) {
          File* {}
          Change* {alited::file::OpenFile $fname yes; return}
          default {set al(macrotorew) {}; return}
        }
      }
      after idle [list alited::edit::DoMacro record $name]
      }
    3 {
      if {![MacroExists $fname]} return
      if {![info exists al(macrotodel)] || $al(macrotodel)<10} {
        set msg [string map [list %f [file tail $fname]] $al(MC,delfile)]
        set al(macrotodel) [alited::msg yesno warn $msg NO -ch $al(MC,noask)]
      }
      if {$al(macrotodel)} {
        file delete $fname
        if {$name eq $al(activemacro)} {
          set al(activemacro) {}
        }
        set macrosmode "init"
        after idle alited::menu::FillMacroItems
      }
    }
  }
}
#_______________________

proc edit::ValidMacro {} {
  # Validates the macro name.

  after idle alited::edit::ValidMacroReal
  return yes
}
#_______________________

proc edit::ValidMacroReal {} {
  # Gets "root tail" of the file name and saves its directory name.
  # Changes the record icon depending on the macro file exists or not.

  namespace upvar ::alited al al obDl2 obDl2
  set tmpdir [file dirname $al(_macro)]
  if {$tmpdir ni {. ""}} {set al(_macroDir) $tmpdir}
  set al(_macro) [file rootname [file tail $al(_macro)]]
  if {[file exists [MacroFileName [string trim $al(_macro)]]]} {
    set icon change
    set mstate normal
  } else {
    set icon add
    set mstate disabled
  }
  set icon alimg_$icon
  set but [$obDl2 ButRec]
  if {[$but cget -image] ne $icon} {::apave::blinkWidgetImage $but $icon}
  [$obDl2 ButPlay] configure -state $mstate
  [$obDl2 ButDel] configure -state $mstate
}
#_______________________

proc edit::DispatchMacro {{mode ""}} {
  # Dispatches macro actions.
  #   mode - what to do

  namespace upvar ::alited al al
  variable macrosmode
  MacroInit
  if {$mode ne {}} {set macrosmode $mode}
  switch -glob $macrosmode {
    "item*"    {InputMacro [string range $macrosmode 4 end]}
    "record"   {
      set fname [MacroFileName $al(activemacro)]
      if {![info exists al(macrocomment)]} {ReadMacroComment $fname}  ;# get the comment
      ::playtkl::end $al(macrocomment)
      set macrosmode {}
    }
    "quickrec" {
      set al(activemacro) $al(MC,quickmacro)
      set al(macromouse) no
      DoMacro record $al(MC,quickmacro)
    }
    "init"     {
      # the very first call of DispatchMacro: activate an old active macro
      MacroMenu $al(activemacro) yes
      DoMacro play $al(activemacro)
      set macrosmode {}
      after idle {set alited::edit::macrosmode play}
    }
    "play"     {
      DoMacro play
      set macrosmode {}
      after idle {set alited::edit::macrosmode play}
    }
  }
}
#_______________________

proc edit::WatchMacro {} {
  # Watch the end of recording.

  namespace upvar ::alited al al
  variable macrosmode
  if {[::playtkl::isend]} {
    alited::Message {Recording: done} 5; bell
    MacroMenu $al(activemacro) yes
    set macrosmode "play"
    bell
  } else {
    after 200 alited::edit::WatchMacro
  }
}
#_______________________

proc edit::ReadMacroComment {fname} {
  # Reads macro's comment.
  #  fname - the macro's file name

  namespace upvar ::alited al al
  set fcont [::apave::readTextFile [MacroFileName $fname]]
  set al(macrocomment) {}
  foreach ln [split $fcont \n] {
    set ln [string trim $ln]
    if {[string match #* $ln]} {
      append al(macrocomment) [string trimleft $ln #] \n
    }
  }
}
#_______________________

proc edit::OpenMacroFile {} {
  # Opens a file of macro.

  namespace upvar ::alited al al obDl2 obDl2
  set al(TMPfname) [MacroFileName $al(MC,quickmacro)]
  set types [list [list {Macro Files} $al(macroext)]]
  set fname [$obDl2 chooser tk_getOpenFile ::alited::al(TMPfname) \
      -initialdir [MacroDir] -filetypes $types -parent $al(WIN)]
  unset al(TMPfname)
  if {$fname ne {}} {alited::file::OpenFile $fname}
}
#_______________________

proc edit::HelpOnMacro {} {
  # Shows Play Macro help.

  alited::HelpAlited #macros
}

# ________________________ Rectangular selection _________________________ #

proc edit::RectSelection {mode} {
  # Starts, ends, does, cuts, copies and pastes a rectangular selection.
  #   mode: 0 for start/end, 1 do, 2 cut, 3 copy, 4 paste

  namespace upvar ::alited al al
  if {$mode==1 && !$al(rectSel)} return
  set TID [alited::bar::CurrentTabID]
  set wtxt [alited::main::CurrentWTXT]
  lassign [split [$wtxt index insert] .] nl nc
  if {$mode==0} {
    if {$al(rectSel)} {
      set al(rectSel,TID) $TID  ;# starts selecting
      set al(rectSel,nl) $nl
      set al(rectSel,nc) $nc
      set al(rectSel,text) [list]
      set mode 1
      alited::Message [msgcat::mc {Move the cursor to select a rectangle.}] 3
    } else {
      set al(rectSel,TID) {}    ;# ends selecting
    }
  }
  switch $mode {
    1 {
      if {$al(rectSel) && $al(rectSel,TID) eq $TID} {
        makeRect $wtxt $al(rectSel,nl) $al(rectSel,nc) $nl $nc
      } else {
        set al(rectSel,TID) {}  ;# at switching tabs
        set al(rectSel) 0
      }
    }
    2 - 3 {saveRect $mode $wtxt}
    4     {pasteRect $wtxt $nl $nc}
  }
  if {$al(rectSel)} {set ico none} {set ico run}
  $al(MENUEDIT).rectsel entryconfigure 1 -image alimg_$ico
  focus $wtxt
}
#_______________________

proc edit::makeRect {wtxt alnl alnc nl nc} {
  # Selects a rectangle.
  #   wtxt - the current text's path
  #   alnl - starting row
  #   alnc - starting column
  #   nl - current row
  #   nc - current column

  set l1 [expr {min($alnl,$nl)}]
  set l2 [expr {max($alnl,$nl)}]
  set c1 [expr {min($alnc,$nc)}]
  set c2 [expr {max($alnc,$nc)}]
  if {$c1==$c2} {set c2 end}  ;# to select "all to line ends"
  for {set l $l1} {$l<=$l2} {incr l} {
    $wtxt tag add sel $l.$c1 $l.$c2
  }
}
#_______________________

proc edit::saveRect {mode wtxt} {
  # Cuts & copies a rectangle.
  #   mode - 2 cut, 3 copy
  #   wtxt - the current text's path

  namespace upvar ::alited al al
  set selection [$wtxt tag ranges sel]
  if {[llength $selection]} {
    ::apave::undoIn $wtxt
    set ln1 999999999
    set al(rectSel,text) [list]
    foreach {from to} $selection {
      set ln2 [::apave::pint $from]
      while {[incr ln1]<$ln2} {       ;# empty intermediate lines
        lappend al(rectSel,text) {}   ;# to be included too
      }
      lappend al(rectSel,text) [$wtxt get $from $to]
      if {$mode==2} {$wtxt delete $from $to}
      set ln1 [::apave::pint $to]
    }
    if {$mode==2} {
      catch {::tk::TextSetCursor $wtxt [lindex $selection 0 0]}
    }
    ::apave::undoOut $wtxt
  }
  set al(rectSel) 0
}
#_______________________

proc edit::pasteRect {wtxt nl nc} {
  # Pastes a rectangle.
  #   wtxt - the current text's path
  #   nl - current row
  #   nc - current column

  namespace upvar ::alited al al
  if {[llength $al(rectSel,text)]} {
    ::apave::undoIn $wtxt
    $wtxt tag remove sel 1.0 end
    set sels [list]
    foreach line $al(rectSel,text) {
      if {$line ne {}} {
        $wtxt insert $nl.$nc $line
        set pos2 $nl.[expr {$nc+[string length $line]}]
        lappend sels $nl.$nc $pos2
        if {![info exists pos1]} {set pos1 $pos2}
      }
      incr nl
    }
    catch {::tk::TextSetCursor $wtxt $pos1}
    catch {$wtxt tag add sel {*}$sels}
    ::apave::undoOut $wtxt
  }
}

# ________________________ To words right / left _________________________ #

proc edit::ControlRight {txt s} {
  # Goes to a next word's start as seen from programmer's viewpoint.
  #   txt - text's path
  #   s - key state
  # The code is rather efficient with long sequences of non-word chars.
  #   [Going_on_words_with_Ctrl+arrow](https://core.tcl-lang.org/tk/tktview/168f3ef130)
  #   [text_index_{insert_wordstart}](https://core.tcl-lang.org/tk/tktview/57b821d2db)

  if {$s % 2} return
  set pos [$txt index "insert wordend"]
  lassign [split $pos .] -> col
  set linestart [expr {int([$txt index insert])}]
  set lineend [expr {int([$txt index end])}]
  while {$linestart <= $lineend} {
    set line [$txt get $linestart.0 $linestart.end]
    if {int($pos)>$linestart} {
      set col [string length $line]
    }
    set res [regexp -indices -start $col -inline "\\w{1}" $line]
    if {[llength $res]} {
      ::tk::TextSetCursor $txt $linestart.[lindex $res 0 0]
      break
    }
    set pos [incr linestart].[set col 0]
  }
  return -code break
}
#_______________________

proc edit::ControlLeft {txt s} {
  # Goes to a previous word's start/end as seen from programmer's viewpoint.
  #   txt - text's path
  #   s - key state
  # The code is rather efficient with long sequences of non-word chars.
  # See also:
  #   [Going_on_words_with_Ctrl+arrow](https://core.tcl-lang.org/tk/tktview/168f3ef130)
  #   [text_index_{insert_wordstart}](https://core.tcl-lang.org/tk/tktview/57b821d2db)

  if {$s % 2} return
  set pos [$txt index insert]
  lassign [split $pos .] -> col
  set linestart [expr {int($pos)}]
  while {$linestart>=0} {
    set line [$txt get $linestart.0 $linestart.$col]
    for {set i [string length $line]} {[incr i -1]>=0} {} {
      if {[string is wordchar -strict [string index $line $i]]} {
        if {![string is wordchar -strict [string index $line [expr {$i-1}]]]} {
          set pos1 $linestart.$i
          set pos2 [$txt index "$pos1 wordend"]
          if {[$txt compare $pos2 < $pos]} {set pos1 $pos2}
          ::tk::TextSetCursor $txt $pos1
          return -code break
        }
      }
    }
    incr linestart -1
    set col {end +1c}
  }
  return -code break
}

# ________________________ Formats _________________________ #

proc edit::IniParameter {parname line {case -nocase}} {
  # Gets parameter value from a line of ini-file.
  #   parname - parameter name (can contain several names separated with comma)
  #   line - line content
  #   case - option "-nocase" for regexp (default) or any other option

  foreach pname [split $parname ,] {
    if {[regexp {*}$case "^\\s*$pname\\s*=\\s*" $line]} {
      set i [string first = $line]
      set res [string range $line [incr i] end]
      return [string trim $res]
    }
  }
  return {}
}
#_______________________

proc edit::SourceFormatTcl {} {
  # Sources format.tcl.

  if {![namespace exists ::alited::format]} {
    namespace eval ::alited {
      source [file join $::alited::SRCDIR format.tcl]
    }
  }
}
#_______________________

proc edit::FormatUnitDesc {} {

  SourceFormatTcl
  alited::format::UnitDesc
}
#_______________________

proc edit::RunFormat {fname} {
  # Does format according to a format file.
  #   fname - format file's name

  SourceFormatTcl
  set fcont [split [::apave::readTextFile $fname] \n]
  set mode 0
  set cont [list]
  set backslashed {}
  foreach line $fcont {
    set line [string trimright $line]
    if {[string index $line end] eq "\\"} {
      append backslashed { } [string trimright $line \\]
      continue
    } elseif {$backslashed ne {}} {
      set line "$backslashed $line"
      set backslashed {}
    }
    lappend cont $line
  }
  foreach line $cont {
    incr iline
    set mode [IniParameter mode $line]
    if {$mode in {1 2 3 4 5}} {
      alited::format::Mode$mode [lrange $cont $iline end]
      break
    }
  }
}
#_______________________

proc edit::OpenFormatFile {dir} {
  # Opens file(s) from data/format directory or its subdirectories.
  #   dir - (sub)directory name

  namespace upvar ::alited al al obPav obPav DATADIR DATADIR
  set ::alited::al(TMPfname) {}
  if {[glob -nocomplain -directory $dir *] eq {}} {
    set dir [file dirname $dir]
  }
  set fnames [$obPav chooser tk_getOpenFile ::alited::al(TMPfname) \
    -initialdir $dir -parent $al(WIN) -multiple 1]
  unset ::alited::al(TMPfname)
  foreach fn [lreverse [lsort $fnames]] {
    alited::file::OpenFile $fn yes
  }
}
#_______________________

proc edit::InvertStringCase {str} {
  # Inverts cases in a string (e.g. InversE -> iNVERSe).
  #   str - the string

  set res {}
  lmap ch [split $str {}] {
    if {[string is lower $ch]} {
      set ch [string toupper $ch]
    } else {
      set ch [string tolower $ch]
    }
    append res $ch
  }
  return $res
}
#_______________________

proc edit::SqueezeString {str} {
  # Squeezes multiple spaces to one space (except for leading spaces)
  # and removes tailing spaces, e.g. "   a  b   c " => "   a b c".
  #   str - the string

  set isp [apave::obj leadingSpaces $str]
  set substring [string range $str $isp end]
  set splist [regexp -inline -all {[ ]+} $substring]
  set splist [lsort -decreasing -command alited::edit::CompareByLength $splist]
  foreach sp $splist {
    set substring [string map [list $sp { }] $substring]
  }
  set res [string repeat { } $isp]
  append res [string trimright $substring]
}
#_______________________

proc edit::ReverseString {str} {
  # The same as "string reverse", but counts escaping braces made in format::Mode2.
  #   str - the string to reverse
  # See also: format::Mode2

  set str [UnEscapeValue $str]
  set str [string reverse $str]
  EscapeValue $str
}
#_______________________

proc edit::SqueezeLines {strlist} {
  # Squeezes a list of lines.
  #   strlist - the list

  set res [list]
  foreach str $strlist {lappend res [SqueezeString $str]}
  return $res
}
#_______________________

proc edit::CompareByLength {s1 s2} {
  # Compares two string by length.
  #   s1 - 1st string
  #   s2 - 2nd string

  set l1 [string length $s1]
  set l2 [string length $s2]
  if {$l1>$l2} {
    return 1
  } elseif {$l1<$l2} {
    return -1
  }
  return 0
}
#_______________________

proc edit::EscapeValue {value} {
  # Escapes a value's backslashes and braces.
  #   value - the value

  return [string map [list \\ \\\\ \} \\\} \{ \\\{] $value]
}
#_______________________

proc edit::UnEscapeValue {value} {
  # Unescapes a value's backslashes and braces.
  #   value - the value

  return [string map [list \\\\ \\ \\\}  \} \\\{ \{] $value]
}

# _________________________________ EOF _________________________________ #
