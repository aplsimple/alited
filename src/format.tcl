#! /usr/bin/env tclsh
###########################################################
# Name:    format.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Feb 09, 2024
# Brief:   Handles Edit/Formats menu items.
# License: MIT.
###########################################################

# _________________________ format ________________________ #

namespace eval format {
  variable win $::alited::al(WIN).formats
  variable da
  array set da [list dir 2 what 1 bgRE "" geo ""]
  set da(separSav1) $::alited::al(format_separ1)
  set da(separSav2) $::alited::al(format_separ2)
  variable valueOrig {}
  variable valueSel {}
  variable valueLines {}
  variable cont6; array set cont6 [list]
  variable bind6; array set bind6 [list]
  variable icon6; array set icon6 [list]
}

# ________________________ Move unit descriptions _________________________ #


## ________________________ Move UI _________________________ ##

proc format::UnitDesc {} {
  # Moves unit description from inner to above units.

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable da
  set da(prjlfRESav) $al(prjleafRE)
  set da(prjuselfRESav) $al(prjuseleafRE)
  set separSav1 $da(separSav1)
  set separSav2 $da(separSav2)
  lassign [Re_Colors] fgRE da(bgRE)
  set stcl [llength [alited::SessionTclList 1]]
  set atcl [llength [alited::SessionTclList 2]]
  set selected [msgcat::mc Selected]\ ($stcl)
  set allopen [msgcat::mc {All in session}]\ ($atcl)
  set REleaf [alited::unit::LeafRegexp]
  $obDl2 makeWindow $win.fra $al(MC,formatdesc)
  $obDl2 paveWindow $win.fra {
    {.lab1 - - 1 3 {-pady 8} {-t "Move proc/method descriptions:" -font {$::apave::FONTMAINBOLD}}}
    {.seh0 + T 1 6}
    {.rad1 + T 1 1 {-st w} {-t "From inside to out" -var ::alited::format::da(dir) -value 1 -com alited::format::ChangeTo -image alimg_up -compound right}}
    {.rad2 + T 1 1 {-st w} {-t "From out to inside" -var ::alited::format::da(dir) -value 2 -com alited::format::ChangeTo -image alimg_down -compound right}}
    {.sev .rad1 L 2 1 {-padx 10}}
    {.labRE1 + L 1 1 {-st sne} {-t "Leaf's regexp:"}}
    {.LabRE2 + L 1 1 {} {-t {$REleaf} -foreground $fgRE -background $da(bgRE)}}
    {.h_1 + L 1 1}
    {.butStd + L 1 1 {-st e} {-t Standard -com alited::format::StandardOptions}}
    {.labSep .labRE1 T 1 1 {-st sne} {-t "Separator:"}}
    {.EntSepar + L 1 3 {-st ew -cw 1} {-tvar ::alited::format::da(separ) -validate all -validatecommand alited::format::ValidateUnitDesc}}
    {.seh1 .rad2 T 1 6}
    {.Tex1 + T 1 6 {-st nsew -pady 4 -rw 1} {-h 11 -w 80 -wrap none -font {$al(FONT,txt)}}}
    {.fra + T 1 6}
    {.fra.LabFromTo + L 1 4 {-st nsew} {-image alimg_up-big}}
    {.fra.labdummy + L 1 1 {-st nsew} {-image alimg_none-big}}
    {.Tex2 .fra T 1 6 {-st nsew -pady 4 -rw 1} {-h 11 -w 80 -wrap none -font {$al(FONT,txt)}}}
    {.frawhat + T 1 6}
    {.frawhat.labwhat - - - - {-st e} {-t "Process .tcl file(s):"}}
    {.frawhat.rad1 + L 1 1 {-padx 20} {-t {$selected} -var ::alited::format::da(what) -value 1}}
    {.frawhat.rad2 + L 1 1 {} {-t {$allopen} -var ::alited::format::da(what) -value 2}}
    {.seh2 .frawhat T 1 6}
    {.butHelp + T 1 1 {-st w} {-t Help -com alited::format::Help}}
    {.h_ + L 1 4}
    {.frabut + L 1 1 {-st e}}
    {.frabut.butOK + L 1 1 {-st e} {-t OK -com alited::format::Ok}}
    {.frabut.butCancel + L 1 1 {-st e} {-t Cancel -com alited::format::Cancel}}
  }
  if {$da(dir)==1} {set da(separ) $da(separSav2)} {set da(separ) $da(separSav1)}
  ChangeTo
  bind $win <F1> alited::format::Help
  set res [$obDl2 showModal $win -resizable 1 -minsize {650 400} {*}$da(geo)]
  set al(prjuseleafRE) $da(prjuselfRESav)
  set al(prjleafRE) $da(prjlfRESav)
  if {$res} {
    alited::main::UpdateAll
  } else {
    set da(separSav1) $separSav1
    set da(separSav2) $separSav2
  }
  set da(geo) "-geometry [wm geometry $win]"
  catch {destroy $win}
}
#_______________________

proc format::ChangeTo {} {
  # At changing the direction, fills 2 texts with "from/to" examples.

  namespace upvar ::alited al al obDl2 obDl2
  variable da
  if {$da(dir)==1} {
    set da(separSav2) $da(separ)
    set da(separ) $da(separSav1)
    set img alimg_up-big
  } else {
    set da(separSav1) $da(separ)
    set da(separ) $da(separSav2)
    set img alimg_down-big
  }
  ::apave::blinkWidgetImage [$obDl2 LabFromTo] $img
  ShowUnitDesc
  Re_FgColor
}
#_______________________

proc format::ValidateUnitDesc {{dovalid no}} {
  # Validates the separator's entry
  #   dovalid - if yes runs the validation

  variable da
  if {$dovalid} {
    set da(separSav$da(dir)) $da(separ)
    ShowUnitDesc
  } else {
    after idle {alited::format::ValidateUnitDesc yes}
  }
  return yes
}
#_______________________

proc format::ShowUnitDesc {} {
  # Displays unit descriptions to move.

  namespace upvar ::alited obDl2 obDl2
  variable da
  set pad [alited::main::CalcPad]
  set descIn " SEPAR\n\n proc ::K {x y} {\n\n $pad# K combinator.\
    \n $pad#   x - returned value\n $pad#   y - discarded value\n\n ${pad}set x\n }"
  set descOut " SEPAR\n\n # K combinator.\
    \n #   x - returned value\n #   y - discarded value\n\n proc ::K {x y} {\n\n ${pad}set x\n }"
  lassign [Separ1 $da(separSav1)] separ1 limit
  set separ1 [string range [string map [list n ::K N ::K] $separ1] 0 $limit]
  set cont1 [string map [list SEPAR $separ1] $descOut]
  set cont2 [string map [list SEPAR $da(separSav2)] $descIn]
  set tex1 [$obDl2 Tex1]
  set tex2 [$obDl2 Tex2]
  $tex1 replace 1.0 end $cont1
  $tex2 replace 1.0 end $cont2
  set colors [alited::SyntaxColors]
  set colors [lreplace $colors end-1 end-1 [lindex [$obDl2 csGet] 2]]
  alited::SyntaxHighlight tcl $tex1 $colors
  alited::SyntaxHighlight tcl $tex2 $colors
  Re_FgColor
}
#_______________________

proc format::Help {} {
  # Handles "Help" button.

  alited::Help $::alited::format::win 1
}
#_______________________

proc format::StandardOptions {} {
  # Sets standard options of Move Descr.

  namespace upvar ::alited al al obDl2 obDl2
  variable da
  set curRE [alited::unit::LeafRegexp]
  if {$curRE ne $al(RE,leafDEF)} {
    set msg [msgcat::mc \
      " Current leaf's RE\n\n   <r>%r1</r>\n\n is not equal to standard\n\n   <r>%r2</r>\n\n as set in Projects/Options and Preferences/Units."]
    set msg [string map [list %r1 $curRE %r2 $al(RE,leafDEF)] $msg]
    set tags [alited::MessageTags]
    set ok [alited::msg okcancel warn $msg CANCEL -text 1 {*}$tags]
    if {!$ok} return
  }
  set da(separSav1) $al(format_separ1DEF)
  set da(separSav2) $al(format_separ2DEF)
  set da(separ) $da(separSav$da(dir))
  [$obDl2 LabRE2] configure -text $al(RE,leafDEF)
  ShowUnitDesc
  Re_FgColor
}
#_______________________

proc format::Re_Colors {} {
  # Gets colors for leaf's regexp (comment's fg & bg).

  namespace upvar ::alited obDl2 obDl2
  lassign [::hl_tcl::hl_colors .] - - - - fg
  lassign [$obDl2 csGet] - - bg
  list $fg $bg
}
#_______________________

proc format::Re_FgColor {} {
  # Sets foreground color for leaf's regexp.

  namespace upvar ::alited al al obDl2 obDl2
  variable da
  lassign [Re_Colors] fg
  lassign [Separ1 $da(separSav1)] separ
  if {![regexp [LeafRE] $separ]} {
    set fg [lindex [alited::FgFgBold] 2]
  }
  [$obDl2 LabRE2] configure -foreground $fg
}


## ________________________ Move actions _________________________ ##

proc format::Separ1 {title} {
  # Gets "real" separator and limit of its length (extracted from it).
  #   title - title

  if {[set limit [regexp -inline {\(\d+\)} $title]] ne {}} {
    set title [string map [list $limit {}] $title]
    set limit [string trim $limit ()]
  } else {
    set limit 9999
  }
  list $title [incr limit -1]
}
#_______________________

proc format::MoveOut {cont title l1 l2} {
  # Move a unit description outside the unit.
  #   cont - file's content
  #   title - initial comment with unit's name
  #   l1 - 1st unit line number
  #   l2 - last unit line number
  # Returns file's contents and 1 (for processed) or 0 (for not processed).

  namespace upvar ::alited al al
  set line [lindex $cont [expr {$l1-1}]]
  if {[regexp [LeafRE] $line]} {
    return [list $cont 0]  ;# already processed?
  }
  # padding (indentation) of unit's declaration
  set pad [obj leadingSpaces $line]
  set pad [string repeat { } $pad]
  set replcont [set replln [list]]
  # find the inside description
  for {set i $l1} {$i<$l2} {incr i} {
    set line [string trimleft [lindex $cont $i]]
    if {![string match #* $line]} {
      if {[llength $replcont] || $line ne {}} break
    } else {
      lappend replcont $pad$line
    }
    lappend replln $i
  }
  if {[llength $replln]} {
    set replcont [linsert $replcont 0 {}]
    # remove old description
    set i1 [lindex $replln 0]
    set i2 [lindex $replln end]
    set cont [lreplace $cont $i1 $i2]
  }
  # above the unit's declaration - find the first "meaningful" line
  for {set i [incr l1 -2]} {$i>=0} {incr i -1} {
    set line [string trimleft [lindex $cont $i]]
    if {$line ne {} && (![string match #* $line] || [regexp {[[:alnum:]]} $line])} {
      break
    }
  }
  # remove old description, insert new one
  set title $pad[string trim $title]
  set cont [lreplace $cont [incr i] $l1]
  set cont [linsert $cont $i {} $title {*}$replcont {}]
  list $cont 1
}
#_______________________

proc format::MoveInside {cont l1 l2 pad} {
  # Move a unit description outside the unit.
  #   cont - file's content
  #   l1 - 1st unit line number
  #   l2 - last unit line number
  #   pad - padding (indentation) of text

  namespace upvar ::alited al al
  variable da
  set l0 [expr {$l1-1}]
  set line [lindex $cont $l0]
  if {![regexp [LeafRE] $line]} {
    return [list $cont 0]  ;# not unit's declaraion - already processed?
  }
  set pad0 [obj leadingSpaces $line]
  set pad0 [string repeat { } $pad0]
  # get the outside description
  set replln 0
  set replcont [list]
  for {set i $l1} {$i<$l2} {incr i} {
    set line [string trimleft [lindex $cont $i]]
    if {![string match #* $line]} {
      if {$line ne {}} {
        if {[regexp $al(RE,proc2) $line]} {
          # unit's declaration found in this line
          set replln [incr i -1]
        }
        break
      }
    } else {
      # only comments included into the description
      lappend replcont $pad$line
    }
  }
  if {$replln <= 0} {
    # unit's declaration not found
    return [list $cont 0]
  }
  # insert it inside the unit's body
  if {[llength $replcont]} {
    # find the unit's body
    set body [set insln 0]
    for {set i $l1} {$i<$l2} {incr i} {
      set line [string trim [lindex $cont $i]]
      if {[regexp $al(RE,proc2) $line]} {
        incr body
      }
      if {$body && [string index $line end] ne "\\"} {
        set insln [incr i]
        break
      }
    }
    if {$insln} {
      # unit's body found - insert the description inside it
      if {[lindex $cont $insln] ne {}} {lappend replcont {}}
      set cont [linsert $cont $insln {} {*}$replcont]
    }
  }
  # replace the the outside description with 2nd separator
  set separ2 [string trim $da(separSav2)]
  if {$separ2 ne {}} {
    set separ2 $pad0$separ2\n
    # if there is a comment above, no separator
    for {set i $l0} {$i>1} {} {
      incr i -1
      set line [string trimleft [lindex $cont $i]]
      if {$line ne {}} {
        if {[string match #* $line]} {
          set separ2 {}
        }
        break
      }
    }
  }
  if {$separ2 eq {}} {
    set cont [lreplace $cont $l0 $replln]
  } else {
    set cont [lreplace $cont $l0 $replln $separ2]
  }
  list $cont 1
}
#_______________________

proc format::MoveUnitDesc {TID} {
  # Does move the unit descriptions.
  #   TID - tab's ID
  # Returns 1 if the moves done, 0 if no moves.

  namespace upvar ::alited al al
  variable da
  if {![alited::isTclScript $TID]} {return 0}
  set infdat [list $TID 1]
  set fname [file tail [alited::bar::FileName $TID]]
  set cont [alited::file::ReadFileByTID $TID]  ;# let it be read anyhow
  set wtxt [alited::main::GetWTXT $TID]
  if {$wtxt eq {}} {
    lassign [alited::main::GetText $TID no no] -> wtxt
  }
  set lfRE $al(prjuseleafRE)
  if {$da(RE_SWITCHED) || $da(dir)==1} {
    # if "Use leaf's RE" was switched or moving to outside and
    # the unit tree contains already appropriate leaf units, then no actions more
    if {$da(dir)==1} {
      # in-to-out mode: recreate the "use leafRE" tree to check it for leaf units
      set al(prjuseleafRE) 1
      alited::unit::RecreateUnits $TID $wtxt
    }
    lassign [alited::unit::UnitHeaderMode $TID] isLeafRE isProc leafRE
    foreach item [lreverse $al(_unittree,$TID)] {
      if {[llength $item]<3} continue
      lassign $item lev leaf fl1 title l1 l2
      set line [$wtxt get $l1.0 $l1.end]
      if {$isProc && [regexp $al(RE,proc) $line] || $isLeafRE && [regexp $leafRE $line]} {
        set msg [string map [list %f $fname %n 0] $al(MC,unitprocsd)]
        alited::info::Put $line [list $TID $l1]  ;# line of issue
        alited::info::Put $msg $infdat           ;# file of issue
        set al(prjuseleafRE) $lfRE
        return 0
      }
    }
  }
  set al(prjuseleafRE) $lfRE
  alited::unit::RecreateUnits $TID $wtxt
  set cont1 [$wtxt get 1.0 end]
  set cont2 [string trimright $cont1]
  set cont [split $cont2 \n]
  set moved 0
  foreach item [lreverse $al(_unittree,$TID)] {
    if {[llength $item]<3} continue
    lassign $item lev leaf fl1 title l1 l2
    if {$leaf && $title ne {}} {
      if {[string first { } $title]>0 && $l1==1} {
        continue ;# intro lines
      }
      lassign [Separ1 $da(separSav1)] separ limit
      set title [string map [list n $title N $title] $separ]
      set title [string range $title 0 $limit]
      if {$da(dir)==1} {
        # to out
        lassign [MoveOut $cont $title $l1 $l2] cont i
      } else {
        # to inside
        set pad [alited::main::CalcPad $wtxt]
        lassign [MoveInside $cont $l1 $l2 $pad] cont i
      }
      incr moved $i
    }
  }
  if {$moved} {
    alited::bar::BAR markTab $TID
    set newcont {}
    foreach c $cont {
      append newcont $c \n
    }
    if {[string length $cont1]==[string length $cont2]} {
      set newcont [string trimright $newcont]
    }
    $wtxt replace 1.0 end $newcont
    if {$wtxt eq [alited::main::CurrentWTXT]} {
      alited::main::UpdateAll
    } else {
      alited::unit::RecreateUnits $TID $wtxt
    }
    set msg [msgcat::mc {%f processed, units affected: %n}]
  } else {
    set msg $al(MC,unitprocsd)
  }
  set msg [string map [list %f $fname %n $moved] $msg]
  alited::info::Put $msg $infdat
  alited::file::MakeThemHighlighted $TID
  return [expr {$moved>0}]
}
#_______________________

proc format::LeafRE {} {
  # Gets the chosen leaf's RE (current or standard, seen by the user).

  return [[$::alited::obDl2 LabRE2] cget -text]
}
#_______________________

proc format::CheckOk {} {
  # Check options of Move Descriptions dialogue.

  namespace upvar ::alited al al obDl2 obDl2
  variable da
  set res yes
  set REleaf [LeafRE]
  if {$da(dir)==1} {
    # move from inside to out
    lassign [Separ1 $da(separ)] separ
    if {![regexp $REleaf $separ]} {
      set err [msgcat::mc "The separator doesn't match to the regexp:\n\n  "]
      append err "\"$REleaf\""
      set res no
    }
    if {![regexp {[Nn]} $da(separ)]} {
      set err {Separator must contain "n" or "N" for unit name!}
      set res no
    }
  } else {
    if {[string trimright $da(separ)] ne {} && ![string match #* $da(separ)]} {
      set err "The separator should be Tcl comment!"
      set res no
      set da(separ) #$da(separ)
    }
  }
  set da(separSav$da(dir)) $da(separ)
  if {!$res} {
    bell
    [$obDl2 Tex1] replace 1.0 end "\n#! [msgcat::mc ERROR]:\n#!\n#! [msgcat::mc $err]"
  }
  if {$res && $da(what)==2 && \
  ![alited::msg yesno ques {Were all files properly backed up?}]} {
    return 0
  }
  if {$res} {
    alited::info::Put {}
    alited::ProcessFiles alited::InitUnitTree $da(what)
    set lfRE [alited::unit::IsLeafRegexp]
    if {$da(dir)==1 && $lfRE || $da(dir)==2 && !$lfRE} {
      set al(prjuseleafRE) [expr {!$lfRE}]
      set al(prjleafRE) $REleaf
      set msg [msgcat::mc "PROJECT OPTION \"Use leaf's regexp\" SWITCHED TEMPORARILY TO "]
      append msg "\"$al(prjuseleafRE)\""
      alited::info::Put $msg {} yes
      set da(RE_SWITCHED) 1
    } else {
      set da(RE_SWITCHED) 0
    }
  }
  return $res
}
#_______________________

proc format::Ok {} {
  # Handles pressing OK button of Move Descriptions dialogue.

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable da
  if {[CheckOk]} {
    set al(format_separ1) $da(separSav1)
    set al(format_separ2) $da(separSav2)
    lassign [alited::ProcessFiles alited::format::MoveUnitDesc $da(what)] all processed
    if {$processed} alited::main::UpdateIcons
    set msg [msgcat::mc {Files processed successfully: %n}]
    set msg [string map [list %n $processed] $msg]
    alited::info::Put $msg {} yes [expr {!$processed}] yes
    $obDl2 res $win 1
  }
}
#_______________________

proc format::Cancel {} {
  # Handles pressing Cancel button of Move Descriptions dialogue.

  namespace upvar ::alited obDl2 obDl2
  variable win
  $obDl2 res $win 0
}

# ________________________ Format by modes _________________________ #

proc format::BeforeFormatting {{islines no}} {
  # Gets option for formatting - text's path, selected text and positions to process.
  #   islines - yes, if positions are lines' start and end
  # Also, sets valueOrig to the original contents of selected text.
  # See also: AfterFormatting

  variable valueOrig
  set wtxt [alited::main::CurrentWTXT]
  set selection [$wtxt tag ranges sel]
  if {[set llen [llength $selection]]>2} {
    alited::Message {Applied to one selection only!} 4
    return {}
  }
  if {$llen} {
    lassign $selection pos1 pos2
    if {[$wtxt compare $pos2 == [$wtxt index end]]} {
      set pos2 [$wtxt index "$pos2 -1c"]
    }
  } else {
    set pos [expr {int([$wtxt index insert])}]
    set pos1 $pos.0
    set pos2 $pos.end
  }
  if {$islines} {
    set pos1 [::apave::pint $pos1].0
    set pos2 [::apave::pint $pos2].end
  }
  set valueOrig [set value [$wtxt get $pos1 $pos2]]
  list $wtxt $value $pos1 $pos2
}
#_______________________

proc format::AfterFormatting {wtxt pos1 pos2 value} {
  # Actions after formatting:
  # replace & update all & select the formatted stuff.
  #   wtxt - text's path
  #   pos1 - 1st position formatted
  #   pos2 - last position formatted
  #   value - content formatted
  # See also: BeforeFormatting

  variable valueOrig
  if {$valueOrig ne $value} {
    $wtxt replace $pos1 $pos2 $value
  }
  alited::main::UpdateAll
  focusByForce $wtxt
  $wtxt tag remove sel 1.0
  set nch [string length $value]
  $wtxt tag add sel $pos1 "$pos1 +$nch chars"
}

## ________________________ map _________________________ ##


proc format::Mode1 {cont args} {
  # Maps selection by pairs taken from config.file.
  #   cont - list of config.file's lines (pairs from-to)

  lassign [BeforeFormatting] wtxt value pos1 pos2
  if {$wtxt eq {}} return
  # check the list of mapping
  set prevlist [list]
  foreach line $cont {
    set line [split [string trim $line]]
    set llen [llength $line]
    if {$llen==1 || $llen>2} {
      set msg [msgcat::mc "Incorrect mapped 'from-to' in: %l"]
      set msg [string map [list %l $line] $msg]
      alited::Message $msg 4
    } elseif {$llen} {
      lassign $line from to
      set i [lsearch -exact -index 1 $prevlist $from]
      if {$i>=0} {
        set msg [msgcat::mc "'from' refers to previous 'to' in: %l (see: %n)"]
        set msg [string map [list %l $line %n [lindex $prevlist $i]] $msg]
        alited::Message $msg 4
      }
      lappend prevlist $line
    }
  }
  foreach line $cont {
    if {[catch {
      set line [split [string trim $line]]
      if {[llength $line]==2} {
        set value [string map $line $value]
      }
    } e]} then {
      alited::Message "$e ($line)" 3
    }
  }
  AfterFormatting $wtxt $pos1 $pos2 $value
}

## ________________________ commands _________________________ ##

proc format::Mode2 {cont args} {
  # Applies a command to selection/current line.
  #   cont - list of config.file's lines

  set wtxt [alited::main::CurrentWTXT]
  set err 0
  foreach line $cont {
    if {[set com [alited::edit::IniParameter command $line]] ne {}} {
      set selection [$wtxt tag ranges sel]
      if {[llength $selection]==0} {
        set pos [expr {int([$wtxt index insert])}]
        set pos1 $pos.0
        set pos2 $pos.end
        set selection [list $pos1 $pos2]
      }
      # Mode=2 allows a rectangular selection,
      # so we should apply the command ($com)
      # to each line of the rectangular selection
      foreach {pos1 pos2} $selection {
        set value [$wtxt get $pos1 $pos2]
        if {$value ne {}} {
          set value [alited::edit::EscapeValue $value]
          set comtodo [alited::Map -nocase $com %v $value]
          if {[catch {set value [eval $comtodo]} e]} {
            alited::Message $e 4
            set err 1
            break
          }
          set value [alited::edit::UnEscapeValue $value]
          $wtxt replace $pos1 $pos2 $value
          set nch [string length $value]
          $wtxt tag add sel $pos1 "$pos1 +$nch chars"
        }
      }
      if {$err} break
    }
  }
  alited::main::UpdateAll
  focusByForce $wtxt
}

## ________________________ on line list _________________________ ##

proc format::Mode3 {cont args} {
  # Applies command(s) to lines of selection.
  #   cont - list of config.file's lines

  lassign [BeforeFormatting yes] wtxt value pos1 pos2
  if {$wtxt eq {}} return
  set value [split $value \n]
  set err 0
  foreach line $cont {
    if {[set com [alited::edit::IniParameter command $line]] ne {}} {
      set com [alited::Map {} $com %v $value]
      if {[catch {set value [eval $com]} e]} {
        alited::Message $e 4
        set err 1
        break
      }
    }
  }
  if {!$err} {
    set resvalue {}
    set was no
    foreach line $value {
      if {$was} {append resvalue \n}
      append resvalue $line
      set was yes
    }
    AfterFormatting $wtxt $pos1 $pos2 $resvalue
  }
}

## ________________________ externals _________________________ ##

proc format::Mode4 {cont args} {
  # Applies external command(s) to selection or lines of selection.
  #   cont - list of config.file's lines
  # The selection (or lines of selection) is saved to a temporary file
  # that is processed by commands.

  namespace upvar ::alited al al
  variable valueSel
  variable valueLines
  lassign [BeforeFormatting] wtxt valueSel
  if {$wtxt eq {}} return
  lassign [BeforeFormatting yes] wtxt valueLines
  set comcount 0
  set tmpname [alited::TmpFile FORMAT~]
  foreach line $cont {
    set com {}
    if {[set comu [alited::edit::IniParameter Unix,Linux $line]] ne {}} {
      if {[::isunix]} {
        set com $comu
        incr comcount
      }
    } elseif {[set comw [alited::edit::IniParameter Windows $line]] ne {}} {
      if {[::iswindows]} {
        set com $comu
        incr comcount
      }
    } elseif {[set com [alited::edit::IniParameter Command $line]] ne {}} {
      if {$comcount} break
    }
    if {$com ne {}} {
      set com [alited::MapWildCards $com]
      #   %S - file name for saved selection
      #   %L - file name for saved lines of selection
      if {[string first %S $com]>=0 && $valueSel ne {}} {
        writeTextFile $tmpname ::alited::format::valueSel
      } elseif {[string first %L $com]>=0 && $valueLines ne {}} {
        writeTextFile $tmpname ::alited::format::valueLines
      }
      set com [alited::Map -nocase $com %S $tmpname %L $tmpname]
      alited::tool::Run_in_e_menu $com
    }
  }
  alited::FocusText
}

## ________________________ insertions _________________________ ##

proc format::Mode5 {cont args} {
  # Inserts a string at the current cursor position.
  # Or does something without changing the text (if commands return "").
  #   cont - list of config.file's lines or variable name containing it
  #   args - contains the edited file name etc.

  namespace upvar ::alited al al DIR DIR
  lassign [BeforeFormatting] wtxt value
  set value [alited::edit::EscapeValue $value]
  lassign $args fn1 fn2 modal
  if {[info exists $cont]} {
    set cont [set $cont]
  }
  foreach line $cont {
    incr il
    set pos [$wtxt index insert]
    set com [alited::edit::IniParameter command $line -nocase -]
    if {$com ne {}} {
      set ending [expr {$com eq "-"}]
      if {$ending} {
        set com [join [lrange $cont $il end] \n]
      }
      set selection [$wtxt tag ranges sel]
      set lsel [llength $selection]
      if {!$lsel} {
        set value {}
      }
      # map format's own and template's woildcards
      set com [alited::Map {} \
        $com %W $wtxt %v $value %f [alited::bar::FileName] \
        %d $al(TPL,%d) \
        %t $al(TPL,%t) \
        %u $al(TPL,%u) \
        %U $al(TPL,%U) \
        %w $al(TPL,%w) \
        %A $DIR \
        %M $al(EM,mnudir)]
      set value [eval $com]
      if {$value ne {}} {
        if {$lsel} {
          lassign $selection pos1 pos2
          $wtxt replace $pos1 $pos2 $value
        } else {
          $wtxt insert $pos $value
        }
      }
      if {$ending} break
    }
  }
  if {[string is true $modal]} alited::FocusText
}

## ________________________ pluginable _________________________ ##

proc format::Mode6 {cont args} {
  # Runs a pluginable formatter.
  #   cont - list of config.file's lines
  #   args - formatter's file name etc.
  # Returns 1st event to run the formatter or {}.

  namespace upvar ::alited al al
  variable cont6
  variable bind6
  lassign $args fullformname
  set fform [alited::edit::FormatterName $fullformname]
  set com [list alited::format::Mode5 ::alited::format::cont6($fform) {*}$args]
  set wtxt [alited::main::CurrentWTXT]
  set bind6($fform) [list]
  set res [set icon {}]
  set sep 0
  set modal 1
  foreach line $cont {
    incr il
    foreach o {sep modal} {
      set v [alited::edit::IniParameter $o $line -nocase]
      if {[string is boolean -strict $v]} {set $o $v}
    }
    set ic [alited::edit::IniParameter icon $line -nocase]
    if {$ic ne {}} {set icon $ic}
    set events [alited::edit::IniParameter events $line -nocase]
    if {$events ne {}} {
      foreach ev [split $events { ,}] {
        if {$ev ne {}} {
          set wasacc [info exist cont6($fform)]
          if {[EventOK $fullformname $fform $ev $wasacc]} {
            lappend com $modal
            catch {bind $wtxt $ev $com}
            if {![llength $bind6($fform)]} {set res $ev}
            lappend bind6($fform) [list $ev $com]
          } else {
            set res {}
            break
          }
        }
        set cont6($fform) [lrange $cont $il end]
      }
      break
    }
  }
  if {$icon ne {}} {
    CreateFormatIcon $icon $sep $com $fform
  } elseif {$res eq {}} {
    # no event encountered - run the formatter once
    Mode5 $cont {*}$args $modal
  }
  return $res
}
#_______________________

proc format::EventOK {fullformname fform ev wasacc} {
  # Checks if an event is correct (not overlap alited key mapping).
  #   fullformname - full path to formatter
  #   fform - formatter's name
  #   ev - the event
  #   wasacc - if true, -accelerator of $fform menu item was made

  namespace upvar ::alited al al
  variable cont6
  set ev2 [string trim $ev <>]
  set keys [alited::keys::EngagedList]
  lappend keys {*}[alited::keys::ReservedList]
  foreach key $keys {
    lassign $key ev1
    if {$ev1 eq $ev2} {
      set fn [alited::menu::FormatsItemName $fform]
      set msg [msgcat::mc {%e is overlapped by formatter "%f"}]
      set msg [string map [list %e $ev %f $fn] $msg]
      alited::MessageError $msg
      return no
    }
  }
  if {!$wasacc} {
    # add -accelerator to Formats menu item of $fform
    set mnu $al(MENUFORMATS)
    set itemttl [alited::menu::FormatsItemName $fform]
    alited::edit::PluginAccelerator $mnu $itemttl $ev2
  }
  set al(FORMATS,$fform,$ev2) [list $fullformname $ev2]
  return yes
}
#_______________________

proc format::CreateFormatIcon {icon sep com fform} {
  # Create icon of formatter in toolbar.
  #   icon - icon name
  #   sep - true if separated
  #   com - command
  #   fform - formatter file name

  variable icon6
  if {[info exists icon6($icon)]} return
  set icon6($icon) 1
  set but [alited::tool::ToolButName $icon]_2
  if {$sep} {
    set separ [ttk::separator ${but}_sep -orient vertical]
    pack $separ -side left -fill y -padx 6
  }
  lassign [obj csGet] fga fg bga bg
  set fontB [obj boldTextFont 16]
  if {[catch {set img [alited::ini::CreateIcon $icon]-big; image inuse $img}]} {
    set txt $icon
    set istext 1
  } else {
    set txt {}
    set istext 0
  }
  set attrs [obj toolbarItem_Attrs $istext $img $fontB $fg $bg $fga $bga]
  button $but -text $txt -command $com {*}$attrs
  ::baltip tip $but [msgcat::mc Pluginable]\n[alited::menu::FormatsItemName $fform]
  bind $but <Button-3> {alited::tool::PopupBar %X %Y}
  pack $but -side left
}

# ________________________ EOF _________________________ #
