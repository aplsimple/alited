###########################################################
# Name:    unit.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/30/2021
# Brief:   Handles units (branches and leaves).
# License: MIT.
###########################################################

namespace eval unit {
  variable ilast -1  ;# last selection in the list of templates
  variable REtodel {#!*\s*TODEL}
}

# ________________________ Common _________________________ #

proc unit::GetDeclaration {wtxt tip l1 l2} {
  # Gets a unit's declaration.
  #   wtxt - text widget
  #   tip - unit's name
  #   l1 - 1st line of unit
  #   l2 - last line of unit

  namespace upvar ::alited al al
  set unithead $tip
  if {[IsLeafRegexp] && ![catch {set unittext [$wtxt get $l1.0 $l2.end]}]} {
    foreach t [split $unittext \n] {
      if {[regexp $al(RE,proc2) $t]} {
        set unithead $t
        break
      }
    }
  } else {
    catch {set unithead [$wtxt get $l1.0 $l1.end]}
  }
  return $unithead
}
#_______________________

proc unit::GetHeader {wtree ID {NC ""} {wtxt ""} {tip ""} {l1 0} {l2 0}} {
  # Gets a header of unit: declaration + initial comments.
  #   wtree - unit tree widget
  #   ID - ID of item in the unit tree
  #   NC - index of column of the unit tree
  #   wtxt - text widget
  #   tip - unit's name
  #   l1 - 1st line of unit
  #   l2 - last line of unit

  namespace upvar ::alited al al
  if {$wtree ne {}} {
    set tip [string trim [$wtree item $ID -text]]
    lassign [$wtree item $ID -values] l1 l2 - id
    if {!$al(TREE,isunits)} {
      return $l2  ;# for file tree, it's a full file name
    }
  }
  if {$NC eq {#1}} {
    set tip "[string map {al #} $id]\n$l1 - [expr {max($l1,$l2)}]"
    set ID {}
  } else {
    catch {
      if {$wtxt eq {}} {
        set wtxt [alited::main::CurrentWTXT]
      }
      set tip2 [GetDeclaration $wtxt $tip $l1 $l2]
      if {[string match "*\{" $tip2] || [string match "test *" $tip2]} {
        set tip [string trim $tip2 " \{\\"]
      }
      if {$NC eq {}} {
        return $tip  ;# returns a declaration only
      }
      # find first commented line, after the proc/method declaration
      set isleafRE [IsLeafRegexp]
      for {} {$l1<$l2} {} {
        incr l1
        set line [string trim [$wtxt get $l1.0 $l1.end]]
        if {[string index $line end] ni [list \\ \{] && $line ni {{} # //} \
        && ($isleafRE || ![regexp $al(RE,proc) $line])} {
          set line1 [string trimleft $line {#!;}]
          set line2 [string trimleft $line {/}]
          if {[string match #* $line] && [string trimleft $line1] ne {} && \
          ![regexp $::hl_tcl::my::data(RETODO) $line]} {
            if {[regexp {^\s+} $line1]} {set line1 [string range $line1 1 end]}
            append tip \n $line1
            break
          } elseif {[string match //* $line] && [string trimleft $line2] ne {}} {
            if {[regexp {^\s+} $line2]} {set line2 [string range $line2 1 end]}
            append tip \n $line2
            if {$al(RE,proc) ne {}} break
          } elseif {$line ne {}} {
            break
          }
        }
      }
    }
  }
  return $tip
}
#_______________________

proc unit::UnitHeaderMode {TID} {
  # Gets modes for unit tree : do use RE for leaf headers and do not.
  #   TID - tab's ID
  # Returns 2 flags: "Use leaf's RE" and "Use proc/method declaration".

  set isLeafRE [IsLeafRegexp]
  set isProc [expr {!$isLeafRE && \
    ($TID eq {TMP} || [alited::file::IsTcl [alited::bar::FileName $TID]])}]
  set leafRE [LeafRegexp]
  list $isLeafRE $isProc $leafRE
}
#_______________________

proc unit::GetUnits {TID textcont} {
  # Gets a unit structure from a text.
  #   TID - tab ID of the text
  #   textcont - contents of the text
  # Returns a list of unit items.
  # An item contains:
  #   - level
  #   - 0 (branch) or 1 (INI,LEAF)
  #   - title
  #   - line1 - first text line for the item
  #   - line2 - last text line for the item

  # The procedure searhes "branch" units in commented lines, e.g. for:
  #   # ___ level 1 _____ #
  #   ## ___ level 2 _____ ##
  #   ### ___ level 3 _____ ###
  # using regexp {^\s*(#+) [_]+([^_]+)[_]+ (#+)} $line -> cmn1 title cmn2
  # it extracts two comment marks (#, ## or ###) and a title (level 1/2/3).
  #
  # To search "leaf" units (containing procs and methods), another `regexp`
  # is used, e.g. for:
  #   # _____
  #   # _____ my leaf 1
  # regexp {^\s*# [_]+([^_]*)$} $line -> title
  # extracts a title (my leaf 1).
  #
  # If "leaf" title is empty, it's taken from the proc/method name, e.g. for
  #   proc unit::SelectUnit {} {...}
  #   method unit::SelectUnit {} {...}
  # regexp {^\s*(proc|method)\s+([[:alnum:]_:]+)\s.+} $line -> type title
  # extracts a type (proc/method) and a title (unit::SelectUnit).
  # The last non-empty group is taken for the title.

  namespace upvar ::alited al al
  set retlist [set item [set title [list]]]
  set textcont [split $textcont \n]
  set llen [llength $textcont]
  lappend textcont ""  ;# to save a last unit to the retlist
  lassign [UnitHeaderMode $TID] isLeafRE isProc leafRE
  set i [set lev [set leaf [set icomleaf -1]]]
  foreach line $textcont {
    incr i
    set flag1 0
    if {[set flag [regexp $al(RE,branch) $line -> cmn1 title]]} {
      # a branch
      set leaf [set icomleaf 0]
      set lev [expr {max(0,[string length $cmn1]-1)}]
    } elseif { \
    $isProc && [regexp $al(RE,proc) $line -> t1 t2 t3 t4 t5 t6 t7] || \
    $isLeafRE && [regexp $leafRE $line -> t1 t2 t3 t4 t5 t6 t7]} {
      set title $t1  ;# default title: just after found string
      foreach t {t7 t6 t5 t4 t3 t2} {
        if {[set _ [set $t]] ne ""} {
          set title $_  ;# last non-empty group of others is a real title
          break
        }
      }
      if {[set cl [string last :: $title]]>-1 && [set cl [string last :: $title $cl]]>-1} {
        # let only a last namespace be present in the titles
        set title [string range $title $cl+2 end]
      }
      set flag1 $al(INI,LEAF)
      set flag [set leaf 1]
    } else {
      set flag [expr {$i>=$llen}]
    }
    if {$flag} {
      if {[llength $item]} {
        set l1 [expr {[lindex $item 4]-1}]
        if {$l1>0 && ![llength $retlist]} {
          # first found at line>1 => create a starting leaf
          set treeID [alited::tree::NewItemID [incr iit]]
          lappend retlist [list $lev 1 $al(INI,LEAF) "" 1 $l1 $treeID]
        }
        lassign [lindex $retlist end] levE leafE flE namE l1E - treeIDE
        lassign $item levC leafC flC namC l1C
        if {$flE eq "1" && $flC eq "0" && $levE==$levC && $leafE==$leafC} {
          # found a named previous leaf
          if {$namE eq ""} {set namE $namC}
          # update the named leaf
          set retlist [lreplace $retlist end end \
            [list $levE $leafE $flE $namE $l1E $i $treeIDE]]
        } else {
          # add l2 (last line of unit), ID of unit
          set treeID [alited::tree::NewItemID [incr iit]]
          lappend retlist [lappend item $i $treeID]
        }
      }
      # prepare an item for saving
      set item [list \
        [expr {$lev+$leaf}] $leaf $flag1 [string trim $title " #"] [expr {$i+1}]]
    }
  }
  if {![llength $retlist]} {
    set name [file tail [alited::bar::FileName $TID]]
    set name [string map [list %f $name] $al(MC,alloffile)]
    set treeID [alited::tree::NewItemID [incr iit]]
    lappend retlist [list 1 1 1 $name 1 $llen $treeID]
  }
  return $retlist
}
#_______________________

proc unit::SwitchUnits {} {
  # Switches between last two active units.
  # See also: main::SaveLast2

  namespace upvar ::alited al al
  if {![info exists al(Last2Visited)] || [llength $al(Last2Visited)]<2} return
  lassign [lindex $al(Last2Visited) 1] TID curitem pos
  SwitchToTIDPos $TID $pos
}
#_______________________

proc unit::SwitchToTIDPos {TID pos} {
  # Switches to tab & text position.
  #   TID - tab's ID
  #   pos - text position

  alited::main::SaveVisitInfo
  alited::favor::SkipVisited yes
  alited::bar::BAR $TID show
  after idle " \
    alited::main::FocusText $TID $pos ; \
    alited::tree::NewSelection ; \
    alited::main::SaveVisitInfo"
}
#_______________________

proc unit::RecreateUnits {TID wtxt} {
  # Recreates the internal tree of units.
  #   TID - tab's ID
  #   wtxt - text's path

  namespace upvar ::alited al al
  set al(_unittree,$TID) [GetUnits $TID [$wtxt get 1.0 {end -1 char}]]
}
#_______________________

proc unit::LeafRegexp {} {
  # Gets "leaf's regexp" setting.

  namespace upvar ::alited al al
  if {$al(prjuseleafRE) && $al(prjleafRE) ne {}} {
    return $al(prjleafRE)
  }
  return $al(RE,leaf)
}
#_______________________

proc unit::IsLeafRegexp {} {
  # Checks for using "leaf's regexp" setting.

  namespace upvar ::alited al al
  set al(prjuseleafRE) [string is true -strict $al(prjuseleafRE)]
  if {$al(prjuseleafRE) && $al(prjleafRE) ne {}} {
    set res 1
  } else {
    set res [expr {$al(RE,leaf) ne {} && $al(INI,LEAF)}]
  }
  return $res
}
#_______________________

proc unit::UnitRegexp {} {
  # Gets RE to check unit's beginning.

  namespace upvar ::alited al al
  if {[IsLeafRegexp]} {
    return [LeafRegexp]
  }
  return $al(RE,proc2)
}

# ________________________ Templates _________________________ #

proc unit::TemplateMap {str} {
  # Maps a string using template wildcards.
  #   str - string to map

  namespace upvar ::alited al al DIR DIR
  set sec [clock seconds]
  set fname [alited::bar::FileName]
  return [alited::Map {} $str \
    %d [alited::tool::FormatDate $sec] \
    %t [clock format $sec -format $al(TPL,%t) -locale $::alited::al(LOCAL)] \
    %u $al(TPL,%u) \
    %U $al(TPL,%U) \
    %m $al(TPL,%m) \
    %w $al(TPL,%w) \
    %F $fname \
    %f [file tail $fname] \
    %n [file rootname [file tail $fname]] \
    %A $DIR \
    %M $al(EM,mnudir) \
    ]
}
#_______________________

proc unit::TemplateData {wtxt l1 l2 tpldata} {
  # Replaces the template wildcards with data of current text and unit.
  #   wtxt - text's path
  #   l1 - 1st line of current unit
  #   l2 - last line of current unit
  #   tpldata - template

  namespace upvar ::alited al al DIR DIR MNUDIR MNUDIR
  lassign $tpldata tex pos place
  set sec [clock seconds]
  set fname [alited::bar::FileName]
  set tex [TemplateMap $tex]
  # get a list of proc/method's arguments:
  # from "proc pr {ar1 ar2 ar3} " and a template "  # %a -\n"
  # to get
  #   # ar1 -
  #   # ar2 -
  #   # ar3 -
  set unithead [GetDeclaration $wtxt {} $l1 $l2]
  set unithead [string trim $unithead "\{ "]
  lassign [split $unithead "\{"] proc
  set iarg [string range $unithead [string length $proc] end]
  catch {
    set ipad [obj leadingSpaces [$wtxt get $l1.0 $l1.end]]
    if {![IsLeafRegexp]} {
      incr ipad [obj leadingSpaces $tex]
    }
    set pad [string repeat " " $ipad]
    set tpla $pad[string map [list \\n \n] $al(TPL,%a)]
    set oarg [set st1 ""]
    if {[string match \{*\} $iarg]} {set iarg [string range $iarg 1 end-1]}
    foreach a [list {*}$iarg] {
      lassign $a a
      set a [string trim $a "\{\} "]
      if {$a ne {}} {
        set st [string map [list %a $a] $tpla]
        if {$st1 eq ""} {set st1 $st}
        append oarg $st
      }
    }
    if {[string first %a $tex]>-1} {
      set tex $pad[string trimleft $tex]
      set place 0
      set pos 1.[string length $st1]
    }
    set tex [string map [list \\n \n %a $oarg] $tex]
  }
  set ll1 [string length $tex]
  set tex [string map [list %p [lindex $proc 1]] $tex]
  set ll2 [string length $tex]
  if {[set ll [expr {$ll2-$ll1}]]} {
    lassign [split $pos .] r c
    if {[string is digit -strict $c]} {
      set pos $r.[expr {$c+$ll}]
    }
  }
  list $tex $pos $place
}
#_______________________

proc unit::InsertTemplate {tpldata {dobreak yes}} {
  # Inserts a template into a current text.
  #   tpldata - template
  #   dobreak - if yes, means "called from bindings, should return -code break"

  # for noname file - save it beforehand, as templates refer to a file name
  if {[alited::file::IsNoName [alited::bar::FileName]]} {
    if {![alited::file::SaveFile]} {
      if {$dobreak} {return -code break}
      return
    }
  }
  set wtxt [alited::main::CurrentWTXT]
  lassign [alited::tree::CurrentItemByLine "" 1] itemID - - - - l1 l2
  lassign [TemplateData $wtxt $l1 $l2 $tpldata] tex posc place
  lassign [split $posc .] -> col0
  switch $place {
    0 { ;# returned by TemplateData: after a declaration
      set pos0 [expr {$l1+1}].0
    }
    4 { ;# after 1st line
      set pos0 1.0
    }
    3 { ;# after cursor
      set pos0 [$wtxt index insert]
    }
    2 { ;# after unit
      if {$l2 ne ""} {
        set pos0 [$wtxt index "$l2.0 +1 line linestart"]
        if {[string index $tex end] ne "\n"} {append tex \n}
        lassign [CorrectPos $wtxt $tex $posc $pos0 {}] tex pos0 posc
        lassign [split $posc .] -> col0
      } else {
        set place 1
      }
    }
    default { ;# after line
      set place 1
    }
  }
  if {$place == 1} {
    set pos0 [$wtxt index "insert +1 line linestart"]
    set posi [$wtxt index "insert linestart"]
    lassign [CorrectPos $wtxt $tex $posc $pos0 $posi] tex pos0 posc
    lassign [split $posc .] -> col0
    if {[string index $tex end] ne "\n"} {append tex \n}
  }
  set posc "[expr {int($posc)-1}].$col0"
  set posc [::apave::p+ $pos0 $posc]
  $wtxt insert $pos0 $tex
  ::tk::TextSetCursor $wtxt $posc
  alited::main::UpdateAll
  after idle alited::main::FocusText
  if {$dobreak} {return -code break}
}
#_______________________

proc unit::CorrectPos {wtxt tex posc pos0 posi} {
  # Corrects an insert position, counting the insertion point's indentation.
  #   wtxt - current text widget
  #   tex - template's text
  #   posc - relative position of cursor
  #   pos0 - position of insertion
  #   posi - cursor position

  namespace upvar ::alited al al
  variable REtodel
  set tlist [split $tex \n]
  set indent1 0
  foreach t $tlist {
    if {[set t [string trim $t]] ne {}} {
      set indent1 [obj leadingSpaces $t]  ;# indentation of the template
      break
    }
  }
  set pos1 [expr {int([$wtxt index $pos0])}]
  set line2 [$wtxt get $pos1.0 $pos1.end]
  if {$posi eq {}} {
    set indent2 [obj leadingSpaces $line2]  ;# indentation of the insert point
  } else {
    set posi [expr {int($posi)}]
    set linei [string trimright [$wtxt get $posi.0 $posi.end]]
    set indent2 [obj leadingSpaces $linei]
    if {$linei eq {}} {
      foreach i {+0 +1 +2 -1 -2} {
        set i [expr $posi$i]
        set ind [obj leadingSpaces [$wtxt get $i.0 $i.end]=]
        if {$ind} {
          set indent2 $ind
          break
        }
      }
    }
  }
  lassign [split $posc .] pl pc
  # If 1st line of the template is underlined, we place it under a previous
  # unit's closing brace. But if the insertion point is already underlined
  # or is a branch, we move 1st line of the template to its end.
  # Or remove it at all, at the end of branch.
  set line1 [lindex $tlist 0]
  set under {^\s*#\s?_+$}
  if {[regexp $under $line1]} {
    set isund [expr {[regexp $under $line2] || [regexp $al(RE,leaf2) $line2]}]
    while {[incr pos1 -1]>1} {
      set line [string trim [$wtxt get $pos1.0 $pos1.end]]
      if {$line ne {}} {
        if {[regexp $under $line] || [regexp $al(RE,leaf2) $line]} {
          set tex [string range $tex [string first \n $tex] end]
          set len1 [llength $tlist]
          set len2 [llength [split [string trimleft $tex] \n]]
          set tex \n[string trim $tex]\n
          if {!$isund} {append tex $line1 \n}
          incr pl [expr {$len2-$len1+1}]  ;# cursor position changed too
          set posc $pl.$pc
        } elseif {$line ne "\}"} {
          if {$isund} {append tex \n}
          break
        }
        set pos0 [$wtxt index "$pos1.0 + 1 line"]
        break
      }
    }
  }
  Source_unit_tpl
  # indent the template & increment the cursor position
  if {![regexp $REtodel $tex] && $indent1<$indent2} {
    incr indent2 -$indent1
    set indent [string repeat { } $indent2]
    lassign [split $posc .] pl pc
    set posc $pl.[incr pc $indent2]
    foreach t [split $tex \n] {
      if {[incr _cnt]==1} {set tex {}} {append tex \n}
      if {$t ne {}} {set t $indent$t}
      append tex $t
    }
  }
  list $tex $pos0 $posc
}
#_______________________

proc unit::Source_unit_tpl {} {
  # Sources unit_tpl.tcl.

  if {![namespace exists ::alited::unit_tpl]} {
    namespace eval ::alited {
      source [file join $SRCDIR unit_tpl.tcl]
    }
  }
}
#_______________________

proc unit::Run_unit_tpl {args} {
  # Runs Templates dialogue.

  Source_unit_tpl
  return [::alited::unit_tpl::_run {*}$args]
}
#_______________________

proc unit::Add {} {
  # Runs a dialog "Add Template" and adds a chosen template to a text.

  set res [Run_unit_tpl]
  if {$res ne {}} {InsertTemplate $res no}
  alited::keys::BindKeys [alited::main::CurrentWTXT] template
}
#_______________________

proc unit::Delete {wtree fname sy} {
  # Deletes a unit from a text.
  #   wtree - unit tree's path
  #   fname - file name
  #   sy - relative Y-coordinate for a query

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  set selection [$wtree selection]
  set wasdel no
  if {[set llen [llength $selection]]>1} {
    set dlg yesnocancel
    set dlgopts [list -ch $al(MC,noask)]
  } else {
    set dlg yesno
    set dlgopts [alited::tree::syOption $sy]
  }
  set ans 1
  for {set i $llen} {$i} {} {
    # delete units from the text's bottom (text selection is sorted by items)
    incr i -1
    set ID [lindex $selection $i]
    set name [$wtree item $ID -text]
    set msg [string map [list %n $name %f [file tail $fname]] $al(MC,delitem)]
    if {$ans<11} {
      set ans [alited::msg $dlg ques $msg YES {*}$dlgopts]
    }
    switch $ans {
      0 - 12 break
      1 - 11 {
        lassign [$wtree item $ID -values] l1 l2
        set ind2 [$wtxt index "$l2.end +1 char"]
        $wtxt delete $l1.0 $ind2
        set wasdel yes
      }
    }
  }
}

## ________________________ Type templates _________________________ ##

proc unit::PutTypeTemplate {wtxt} {
  # Inserts a type template depending on a current chars at the cursor.
  #   wtxt - text's path

  if {[set word [alited::find::GetWordOfText]] ne {}} {
    set idxr [$wtxt index insert]
    set idxl "$idxr -[string length $word] c"
    set wordleft [$wtxt get $idxl $idxr]
    if {$wordleft eq $word && [set tpl [GetTypeTemplate $word]] ne {}} {
      undoIn $wtxt
      $wtxt replace $idxl $idxr $tpl
      AfterInsertingTypeTemplate $wtxt $idxl $tpl
      return -code break
    }
  }
}
#_______________________

proc unit::InsertTypeTemplate {word} {
  # Inserts a type template at the cursor.
  #   word - template's word

  if {[set tpl [GetTypeTemplate $word]] ne {}} {
    set wtxt [alited::main::CurrentWTXT]
    set idxl [$wtxt index insert]
    undoIn $wtxt
    $wtxt insert $idxl $tpl
    AfterInsertingTypeTemplate $wtxt $idxl $tpl
  }
}
#_______________________

proc unit::AfterInsertingTypeTemplate {wtxt idxl tpl} {
  # Actions after inserting type template.
  #   wtxt - text's path
  #   idxl - insertion index
  #   tpl - template's contents

  if {[set i [string first `` $tpl]]>-1} {
    set idxl [$wtxt index "$idxl +$i c"]
    $wtxt replace $idxl [$wtxt index "$idxl +2 c"] {}
    ::tk::TextSetCursor $wtxt $idxl
  }
  undoOut $wtxt
  alited::main::UpdateAll
}
#_______________________

proc unit::GetTypeTemplate {word} {
  # Gets a template's content.
  #   word - template's word

  namespace upvar ::alited al al
  set res {}
  set ttdict [ReadTypeTemplate]
  if {[dict exists $ttdict $word]} {
    foreach line [dict get $ttdict $word] {
      if {$res ne {}} {append res \n}
      append res $line
    }
  }
  string map [list ``` {}] $res
}
#_______________________

proc unit::TypeTemplateFiles {} {
  # Lists files of type template directory.

  namespace upvar ::alited al al
  if {![info exists al(_TypeTemplateDir)]} {
    set tpldir [CreateTypeTemplateFiles]
    set al(_TypeTemplateDir) [list]
    foreach fn [glob -nocomplain [file join $tpldir *]] {
      lappend al(_TypeTemplateDir) $fn
    }
  }
  return $al(_TypeTemplateDir)
}
#_______________________

proc unit::CreateTypeTemplateFiles {} {
  # Creates type template files, if they don't exist.

  namespace upvar ::alited DATADIR DATADIR USERDIR USERDIR
  set aledir [file join $DATADIR typetpl]
  set tpldir [file join $USERDIR typetpl]
  if {![file exists $tpldir]} {
    if {[catch {file copy $aledir $tpldir} err]} {
      alited::Message $err 4
    }
  }
  return $tpldir
}
#_______________________

proc unit::ReadTypeTemplate {} {
  # Reads all template contents for the current edited file.

  namespace upvar ::alited al al
  set type [alited::EditExt]
  if {![info exists al(_TypeTemplateFile,$type)]} {
    set al(_TypeTemplateFile,$type) [dict create]
    set ttsection \[alited:
    foreach fn [TypeTemplateFiles] {
      # find the current file type among template files:
      # template file rootname can be "htm,html,css"
      if {[regexp "\(^|,\)$type\(,|$\)" [file rootname $fn]]} {
        set fcont [CheckTypeTemplate $fn]
        set tt {}
        foreach line $fcont {
          set linetr [string trim $line]
          if {[string first $ttsection $linetr]==0 \
          && [string index $linetr end] eq "\]"} {
            set tt [string range $linetr [string length $ttsection] end-1]
            set tt [set ttl [string trim $tt]]
            if {[set i [string first { } $tt]]>0} {
              set tt [string range $tt 0 $i]
            }
            set tt [string trim $tt]
            dict set al(_TypeTemplateFile,$type) $tt [list]   ;# template's contents
            dict set al(_TypeTemplateFile,$type) $tt,ttl $ttl ;# template's title
          } elseif {$tt ne {}} {
            dict lappend al(_TypeTemplateFile,$type) $tt $line
          }
        }
        break
      }
    }
  }
  return $al(_TypeTemplateFile,$type)
}
#_______________________

proc unit::CheckTypeTemplate {fname} {
  # Checks the type template's version.
  # If it's obsolete, updates it from alited's source.
  #   fname - type template file name

  namespace upvar ::alited DATADIR DATADIR
  set fcont [textsplit [string trimleft [readTextFile $fname]]]
  set fverAle 1.1
  set fverCur [string trim [lindex $fcont 0] { []}]
  set fnameAle [file join $DATADIR typetpl [file tail $fname]]
  if {$fverAle > $fverCur && [file exists $fnameAle]} {
    set fcont [textsplit [readTextFile $fnameAle]]
    if {[catch {file copy -force $fnameAle $fname} err]} {
      alited::Message $err 4
    }
  }
  return $fcont
}
#_______________________

proc unit::OpenTypeTemplate {} {
  # Opens type template(s) for editing.

  namespace upvar ::alited al al obPav obPav
  set tpldir [CreateTypeTemplateFiles]
  set ::alited::al(TMPfname) {}
  set fnames [$obPav chooser tk_getOpenFile ::alited::al(TMPfname) \
    -initialdir $tpldir -parent $al(WIN) -multiple 1]
  unset ::alited::al(TMPfname)
  foreach fn [lreverse [lsort $fnames]] {
    alited::file::OpenFile $fn yes
  }
}
#_______________________

proc unit::FillTypeTplMenu {} {
  # Fills "Type Templates" submenu.

  namespace upvar ::alited al al
  set ttdict [ReadTypeTemplate]
  set m $al(TYPETPLMENU)
  catch {$m delete 2 end}
  if {$ttdict ne {}} {
    $m add separator
    foreach ttl [lsort [dict keys $ttdict]] {
      if {[set i [string first ,ttl $ttl]]>0} {
        set tt [string range $ttl 0 [incr i -1]]
        set it [dict get $ttdict $ttl]
        if {[incr idx] % 25} {set cbr {}} {set cbr {-columnbreak 1}}
        $m add command -label $it \
          -command [list alited::unit::InsertTypeTemplate $tt] {*}$cbr
      }
    }
  }
}

# ________________________ Moving units _________________________ #

proc unit::DropUnits {wtree fromIDs toID} {
  # Moves unit(s) from one location in the unit tree to other.
  #   wtree - unit tree's path
  #   fromIDs - IDs of tree item "to move from"
  #   toID - ID of tree item "to move to"

  namespace upvar ::alited obPav obPav
  set tree [alited::tree::GetTree]
  set wtxt [alited::main::CurrentWTXT]
  set wtree [$obPav Tree]
  undoIn $wtxt
  # firstly, cut all moved lines
  set ijust 0
  set movedlines [list]
  # we must cut from below, so sort units reversely:
  set fromIDs [lsort -decreasing -dictionary $fromIDs]
  set headers [list]
  foreach fromID $fromIDs {
    if {$fromID eq $toID} continue
    # simply for each unit: find its moved lines and a destination line
    set i1 [set i2 [set io 0]]
    foreach item $tree {
      lassign $item lev cnt id title values
      lassign $values l1 l2 prl id lev leaf fl1
      if {$id eq $fromID} {
        set i1 $l1
        set i2 $l2
      } elseif {$id eq $toID} {
        set io $l1
      }
    }
    if {$i1 && $i2 && $io} {
      lappend headers [GetHeader $wtree $fromID]
      # if the unit is above the destination, the destination should be adjusted
      if {$i2<$io} {set ijust [expr {$ijust-$i2+$i1-1}]}
      set ind2 [$wtxt index "$i2.end +1 char"]
      set lines [$wtxt get $i1.0 $ind2]
      $wtxt delete $i1.0 $ind2
      # the cut lines are saved, to paste them afterwards
      lappend movedlines $lines
    }
  }
  # secondly, paste all moved lines
  if {[llength $movedlines]} {
    incr io $ijust
    foreach lines $movedlines {
      $wtxt insert $io.0 $lines
    }
    ::tk::TextSetCursor $wtxt $io.0
    alited::main::UpdateAll $headers
    alited::main::FocusText
  }
  undoOut $wtxt
}
#_______________________

proc unit::MoveL1L2 {wtxt i1 i2 io {dosep yes}} {
  # Moves a text lines to other location.
  #   wtxt - text widget's path
  #   i1 - first line to be moved
  #   i2 - last line to be moved
  #   io - destination line (to insert the moved lines before)
  #   dosep - yes, if "edit separator" is required
  # Returns a position of destination line, if the moving was successful.

  set ind2 [$wtxt index "$i2.end +1 char"]
  if {($i1<=$io && $io<=$i2) || $io<1 || $i1<1 || $i2<1 || \
  [set linesmoved [$wtxt get $i1.0 $ind2]] eq ""} {
    return "" ;# nothing to do
  }
  if {$dosep} {undoIn $wtxt}
  $wtxt delete $i1.0 $ind2
  if {$io>$i2} {
    # 3. i1    if moved below, the moved (deleted) lines change 'io', so
    # 4. i2    'io' is shifted up (by range of moved lines i.e. i1-i2-1)
    # 5.
    # 6. io    resulting io = io-(i2-i1+1) = io+i1-i2-1 (6+3-4-1=4)
    set io [expr {$io+$i1-$i2-1}]
  }
  if {$io == int([$wtxt index end])} {
    # "If index refers to the end of the text (the character after the last newline)
    # then the new text is inserted just before the last newline instead."
    # (The text manual page)
    $wtxt insert "end" \n$linesmoved
    $wtxt delete [$wtxt index "end -1 char"] end
  } else {
    $wtxt insert $io.0 $linesmoved
  }
  if {$dosep} {undoOut $wtxt}
  return $io
}
#_______________________

proc unit::MoveUnit {wtree to hd headers f1112 {dosep yes}} {
  # Moves a unit up/down the unit tree.
  #   wtree - unit tree's path
  #   to - direction (up/down)
  #   hd - header of the moved unit
  #   headers - headers of all selected units
  #   f1112 - yes, if run by F11/F12 keys
  #   dosep - yes, if "edit separator" is required

  namespace upvar ::alited al al
  set wtxt [alited::main::CurrentWTXT]
  set tree [alited::tree::GetTree]
  set itemID [SearchByHeader $hd]
  set newparent [set oldparent {}]
  set newlev [set oldlev [set iold -1]]
  set i1 [set i2 [set io 0]]
  foreach item $tree {
    lassign $item lev cnt id title values
    lassign $values l1 l2 prl id lev leaf fl1
    if {$id eq $itemID} {
      set oldlev $lev
      set i1 $l1
      set i2 $l2
      if {$to eq "up"} break
    } elseif {$to ne "up" && $oldlev>-1} {
      set io [expr {$l2+1}]
      break
    }
    set io $l1
  }
  if {$io<$al(INI,LINES1)} {
    set msg [string map [list %n $al(INI,LINES1)] $al(MC,introln2)]
    if {$f1112} {set geo ""} else {set geo "-geometry pointer+10+10"}
    alited::msg ok err $msg -title $al(MC,introln1) {*}$geo
    return no
  }
  if {[set pos [MoveL1L2 $wtxt $i1 $i2 $io $dosep]] ne {}} {
    ::tk::TextSetCursor $wtxt [expr {int($pos)}].0
    alited::tree::RecreateTree $wtree $headers
  } else {
    return no
  }
  return yes
}
#_______________________

proc unit::MoveUnits {wtree to itemIDs f1112} {
  # Moves selected units up/down the unit tree.
  #   wtree - unit tree's path
  #   to - direction (up/down)
  #   itemIDs - tree item IDs of selected units
  #   f1112 - yes, if run by F11/F12 keys

  namespace upvar ::alited al al
  # update the unit tree, to act for sure
  alited::tree::RecreateTree
  # check the moved units for the consistency of braces
  set wtxt [alited::main::CurrentWTXT]
  foreach ID $itemIDs {
    lassign [$wtree item $ID -values] l1 l2 - id
    set cc1 [set cc2 0]
    foreach line [split [$wtxt get $l1.0 $l2.end] \n] {
      incr cc1 [::apave::countChar $line \{]
      incr cc2 [::apave::countChar $line \}]
    }
    if {$cc1!=$cc2} {
      set tip [string trim [$wtree item $ID -text]]
      set msg [string map [list %n $tip %1 $cc1 %2 $cc2] $al(MC,errmove)]
      alited::Message $msg 4
      return
    }
  }
  if {$to eq {move}} {
    DropUnits $wtree $itemIDs $f1112
    return
  }
  set al(RECREATE) 0
  set headers [list]
  foreach ID $itemIDs {
    set hd [GetHeader $wtree $ID]
    if {$to eq {up}} {
      lappend headers $hd
    } else {
      set headers [linsert $headers 0 $hd]
    }
  }
  # move items one by one, by their headers
  undoIn $wtxt
  foreach hd $headers {
    if {![MoveUnit $wtree $to $hd $headers $f1112 no]} {
      break
    }
  }
  undoOut $wtxt
  set com "set ::alited::al(RECREATE) 1; alited::tree::RecreateTree"
  if {[set sel [$wtree selection]] ne {}} {
    append com "; $wtree selection set {$sel}"
  }
  after idle $com
}

# ________________________ Search _________________________ #

proc unit::SearchInBranch {unit {branch {}}} {
  # Checks whether a unit is in a branch.
  #   unit - ID of the unit
  #   branch - the branch or its ID
  # If *branch* is omitted, searches in all of the tree.
  # If *branch* is set as ID, the branch is fetched from this ID.
  # Returns the unit's index in the branch or -1 if not found.

  if {[llength $branch]<2} {
    set branch [alited::tree::GetTree $branch]
  }
  return [lsearch -exact -index 2 $branch $unit]
}
#_______________________

proc unit::SearchByHeader {header} {
  # Gets tree item ID of a units by its header (declaration+initial comment).

  namespace upvar ::alited obPav obPav
  set wtree [$obPav Tree]
  foreach item [alited::tree::GetTree] {
    set ID [lindex $item 2]
    set header2 [GetHeader $wtree $ID]
    if {$header eq $header2} {return $ID}
  }
  return {}
}

# _________________________________ EOF _________________________________ #
