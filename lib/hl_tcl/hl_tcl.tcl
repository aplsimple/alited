###########################################################
# Name:    hl_tcl.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/16/2021
# Brief:   Handles highlighting Tcl code.
# License: MIT.
###########################################################

package provide hl_tcl 0.9.40

# ______________________ Common data ____________________ #

namespace eval ::hl_tcl {

  namespace eval my {

    variable data;  array set data [list]

    # Tcl commands
    set data(PROC_TCL) [lsort [list \
      return proc method self my coroutine yield yieldto constructor destructor \
      namespace oo::define oo::class oo::objdefine oo::object
    ]]
    set data(CMD_TCL) [lsort [list \
      set incr if else elseif string expr list lindex lrange llength lappend \
      lreplace lsearch lassign append split info array dict foreach for while \
      break continue switch default linsert lsort lset lmap lrepeat catch variable \
      concat format scan regexp regsub upvar uplevel try throw read eval \
      after update error global puts file chan open close eof seek flush mixin \
      msgcat gets rename glob fconfigure fblocked fcopy cd pwd mathfunc then \
      mathop apply fileevent unset join next exec refchan package source \
      exit vwait binary lreverse registry auto_execok subst encoding load \
      auto_load tell auto_mkindex memory trace time clock auto_qualify \
      auto_reset socket bgerror oo::copy unload history tailcall \
      interp parray pid transchan nextto unknown dde pkg_mkIndex zlib auto_import \
      pkg::create tcl::prefix \
      http::config http::geturl http::formatQuery http::reset http::wait \
      http::status http::size http::code http::ncode http::meta http::data \
      http::error http::cleanup http::register http::unregister * \
    ]]

    # Ttk commands
    set data(CMD_TTK) [list \
      ttk::button ttk::frame ttk::label ttk::entry ttk::checkbutton \
      ttk::radiobutton ttk::combobox ttk::labelframe ttk::scrollbar \
      tk_optionMenu ttk::menubutton ttk::style ttk::notebook ttk::panedwindow \
      ttk::separator ttk::progressbar ttk::scale ttk::sizegrip ttk::spinbox \
      ttk::treeview ttk::intro ttk::widget tk_focusNext tk_getOpenFile \
    ]

    # Tk commands
    set data(CMD_TK2) [list \
      tk_popup tk tkwait tkerror tk_setPalette tk_textCut tk_textCopy tk_bisque \
      tk_chooseDirectory tk_textPaste ttk_vsapi tk_focusPrev tk_messageBox \
      tk_focusFollowsMouse tk_getSaveFile tk_menuSetFocus tk_dialog tk_chooseColor \
    ]

    # Tk/ttk commands united
    set data(CMD_TK) [concat $data(CMD_TTK) $data(CMD_TK2) [list \
      button entry checkbutton radiobutton label menubutton menu wm winfo bind \
      grid pack event bell text canvas frame listbox grab scale scrollbar \
      labelframe focus font bindtags image selection toplevel destroy \
      option options spinbox bitmap photo keysyms send lower clipboard colors \
      console message cursors panedwindow place raise \
    ]]

    # allowed edges of string (as one and only)
    set data(S_LEFT) [list \{ \[]
    set data(S_RIGHT) [list \} \]]
    # allowed edges of string (as one or both)
    set data(S_SPACE) [list {} { } \t {;}]
    set data(S_SPACE2) [concat $data(S_SPACE) [list \{]]
    set data(S_BOTH) [concat $data(S_SPACE) [list \" \}]]

#    set data(RE0) {(^|[\{\}\[;]+)\s*([:\w*]+)(\s|\]|\}|\\|$|;)}
#    set data(RE0) {(^|[\{\}\[;]+)\s*([:\w*]+)(\s|\]|\}|\\|$|;)?}
    set data(RE0) {(^|[\{\}\[;]+)\s*([:\w*]+)(\s|\]|\}|\\|$|;){0}} ;# test: pwd;pwd;pwd
    set data(RE1) {([\{\}\[;])+\s*([:\w*]+)(\s|\]|\}|\\|$)}
    set data(RE5) {(^|[^\\])(\[|\]|\$|\{|\})}

    set data(LBR) {\{(\[\"}
    set data(RBR) {\})\]\"}

    # default syntax colors arrays (for a light & black themes)
    #  COM     COMTK    STR      VAR     CMN     PROC    OPT    BRAC
    set data(SYNTAXCOLORS,0) {
      {#923B23 #7d1c00 #035103 #4A181B #4b5d50 #ca14ca #463e11 #FF0000}
      {orange #ff7e00 lightgreen #f1b479 #76a396 #fe6efe #b9b96e #ff33ff}
    }
    set data(SYNTAXCOLORS,1) {
      {#3a6797 #134070 #7d1a1a #1b1baa #4b5d50 #ca14ca #6c3e67 #FF0000}
      {#95c2f2 #73a0d0 #caca3f #a9a9f7 #76a396 #fe6efe #e2b4dd #ff33ff}
    }
    set data(SYNTAXCOLORS,2) {
      {#2b6b2b #0b4b0b #bd00bd #004080 #606060 #8a3407 #463e11 #FF0000}
      {#aad5ab #86c686 #ff86ff #96c5f8 #848484 #fab481 #b1a97c #ff33ff}
    }
    set data(SYNTAXCOLORS,3) {
      {#121212 #000000 #0c560c #4A181B #606060 #923B23 #463e11 #FF0000}
      {#e9e9e9 #ffffff #84e284 #eebabf #848484 orange #a79f72 #ff33ff}
    }
  }
}

# _________________________ STATIC highlighting _________________________ #

proc ::hl_tcl::my::AuxEnding {kName lineName iName} {
  # Auxiliary procedure to process the ending comments in the line.
  #   kName - variable's name for 'k'
  #   lineName - variable's name for 'line'
  #   iName - variable's name for 'i'
  # See also: HighlightLine

  upvar 1 $kName k $lineName line $iName i
  if {[set k [string first # $line $i]]>-1 && \
  [string index [string trimleft $line] 0] eq {#}} {
    return 1
  }
  # not found a full line comment => try to find "good" ending comments i.e. ";# ..."
  # at that even proper comments like
  #   if {cond} { #...
  #   }
  # are skipped as "bad"
  set k [lindex [regexp -inline -indices {;\s*#} [string range $line $i end]] 0 0]
  if {$k eq {}} {
    set k -1
    return 0
  }
  set k [expr {$k+$i+1}]
  return 1
}
#_____

proc ::hl_tcl::my::NotEscaped {line i} {
  # Checks if a character escaped in a line.
  #   line - line
  #   i - the character's position in 'line'
  # Returns "1" if the character not escaped.

  set cntq 0
  while {$i>0} {
    if {[string index $line [incr i -1]] ne "\\"} {
      return [expr {($cntq%2)==0}]
    }
    incr cntq
  }
  return [expr {($cntq%2)==0}]
}
#_____

proc ::hl_tcl::my::RemoveTags {txt from to} {
  # Removes tags in text.
  #   txt - text widget's path
  #   from - starting index
  #   to - ending index

  foreach tag {tagCOM tagCOMTK tagSTR tagVAR tagCMN tagCMN2 tagPROC tagOPT} {
    $txt tag remove $tag $from $to
  }
  return
}
#_____

proc ::hl_tcl::my::HighlightCmd {txt line ln pri i} {
  # Highlights Tcl/Tk commands.
  #   txt - text widget's path
  #   line - line to be highlighted
  #   ln - line number
  #   pri - column number to highlighted from
  #   i - current position in 'line'

  variable data
  $txt tag add tagSTD "$ln.$pri" "$ln.$i +1 chars"
  if {$pri} {
    incr pri -1
    set RE $data(RE1)
  } else {
    set RE $data(RE0)
  }
  set st [string range $line $pri $i-1]
  set lcom [regexp -inline -all -indices $RE $st]
  # commands
  foreach {- - lc -} $lcom {
    lassign $lc i1 i2
    set c [string trim [string range $st $i1 $i2] "\{\}\[;\t "]
    set ik [expr {$i2-$i1+1-[string length $c]}]
    if {$c ne {}} {
      incr i1 $ik
      incr i2
      if {[lsearch -exact -sorted $data(CMD_TCL) $c]>-1} {
        $txt tag add tagCOM "$ln.$pri +$i1 char" "$ln.$pri +$i2 char"
      } elseif {[lsearch -exact -sorted $data(PROC_TCL) $c]>-1} {
        if {$c eq {namespace} &&
        ![regexp {^namespace[\s]+eval([\s]|$)+} [string range $st $i1 end]]} {
          set tag tagCOM ;# let "namespace eval" only be highlighted as proc/return
        } else {
          set tag tagPROC
        }
        $txt tag add $tag "$ln.$pri +$i1 char" "$ln.$pri +$i2 char"
      } elseif {[lsearch -exact -sorted $data(CMD_TK_EXP) $c]>-1} {
        $txt tag add tagCOMTK "$ln.$pri +$i1 char" "$ln.$pri +$i2 char"
      }
    }
  }
  # $variables:
  set dlist [list]
  set slen [expr {[string length $st]-1}]
  set cnt [CountChar $st \$ dlist no]
  foreach dl $dlist {
    if {[string index $st $dl+1] eq "\{"} {
      if {[set br2 [string first \} $st $dl+2]]!=-1} {
        $txt tag add tagVAR "$ln.$pri +$dl char" "$ln.$pri +[incr br2] char"
      }
      continue
    }
    for {set i [set dl2 $dl]} {$i<$slen} {} {
      incr i
      set ch [string index $st $i]
      if {[string is wordchar $ch] || $ch eq {:}} {
        set dl2 $i
        continue
      } elseif {$ch eq {(}} {
        if {[set br2 [string first {)} $st $i+1]]>-1} {
          set dl2 $br2
        }
      }
      break
    }
    if {$dl2>$dl} {
      $txt tag add tagVAR "$ln.$pri +$dl char" "$ln.$pri +[incr dl2] char"
    }
  }
  # -options
  set dl -1
  while {[set dl [string first - $st [incr dl]]]>-1} {
    if {[string index $st $dl-1] ni $data(S_SPACE2)} continue
    if {[string index $st $dl+1] eq {-}} {
      incr dl ;# for --longoption
    }
    set i $dl
    set ch [string index $st $i+1]
    if {![string is alpha -strict $ch]} { ;# || ![string is ascii -strict $ch]
      continue ;# first, a Latin letter
    }
    set dl2 -1
    while {$i<$slen} {
      incr i
      set ch [string index $st $i]
      if {![string is wordchar $ch] && $ch ne {-}} break
      set dl2 $i
    }
    if {$dl2>-1} {
      $txt tag add tagOPT "$ln.$pri +$dl char" "$ln.$pri +[incr dl2] char"
      set dl $dl2
    }
  }
  return
}
#_____

proc ::hl_tcl::my::HighlightStr {txt p1 p2} {
  # Highlights strings.
  #   txt - text widget's path
  #   p1 - starting index of the string in 'txt'
  #   p2 - ending index of the string in 'txt'

  variable data
  set p1 [$txt index $p1]
  set p2 [$txt index $p2]
  $txt tag add tagSTR $p1 $p2
  set st [$txt get $p1 $p2]
  set lcom [regexp -inline -all -indices $data(RE5) $st]
  foreach {lc g1 g2} $lcom {
    lassign $lc i1 i2
    incr i2
    while {$i1<$i2} {
      incr i1
      if {[string first [string index $st $i1] "\[\]\$\{\}"]>-1} {
        set i12 [expr {$i1+1}]
        $txt tag add tagVAR "$p1 +$i1 char" "$p1 +$i12 char"
      }
    }
  }
  return
}
#_____

proc ::hl_tcl::my::FirstQtd {lineName iName currQtd} {
  # Searches the quote characters in line.
  #   lineName - variable's name for 'line'
  #   iName - variable's name for 'i'
  #   currQtd - yes, if searching inside the quoted
  # Returns "yes" if a quote character was found.

  variable data
  upvar 1 $lineName line $iName i
  while {1} {
    if {[set i [string first \" $line $i]]==-1} {return no}
    if {[NotEscaped $line $i]} {
      if {$currQtd||$i==0} {return yes}
      set i1 [expr {$i-1}]
      set i2 [expr {$i+1}]
      if {[NotEscaped $line $i1]} {
        set c1 [string index $line $i1]  ;# check the string ends
        set c2 [string index $line $i2]
        # not needed: $c1 in $data(S_BOTH) && $c2 ni $data(S_BOTH) ||
        if {$c1 in $data(S_LEFT) && $c2 ni $data(S_RIGHT)
        || $c1 ni $data(S_LEFT) && $c2 in $data(S_RIGHT)} {
          return yes
        }
        # last reverence: for braced expression
        set i1 $i
        while {$i1>0} {
          set c1 [string index $line $i1-1]
          set c2 [string index $line $i1]
          if {$c1 in $data(S_SPACE)} {return [expr {$c2 ne "\{"}]}
          incr i1 -1
        }
        return no
      }
      return yes
    }
    incr i
  }
}
#_____

proc ::hl_tcl::my::HighlightComment {txt line ln k} {
  # Highlights comments.
  #   txt - text widget's path
  #   line - current line
  #   ln - line's number
  #   k - comment's starting position in line

  set stcom [string range $line $k end]
  if {[regexp {^\s*#\s*(!|TODO)} $stcom]} {
    $txt tag add tagCMN2 $ln.$k $ln.end  ;# "!" and TODO comments
  } else {
    $txt tag add tagCMN $ln.$k $ln.end
  }
  return
}
#_____

proc ::hl_tcl::my::HighlightLine {txt ln prevQtd} {
  # Highlightes a line in text.
  #   txt - text widget's path
  #   ln - line's number
  #   prevQtd - flag of "being quoted" from the previous line

  variable data
  set line [$txt get $ln.0 $ln.end]
  if {$prevQtd==-1} {  ;# comments continued
    HighlightComment $txt $line $ln 0
    if {[string index $line end] ne "\\"} {set prevQtd 0}
    return $prevQtd
  }
  set currQtd $prevQtd  ;# current state of being quoted
  set i [set pri [set lasti 0]]
  set k -1
  while {1} {
    if {![FirstQtd line i $currQtd]} break
    set lasti $i
    if {$currQtd} {
      HighlightStr $txt $ln.$pri "$ln.$i +1 char"
      set currQtd 0
      incr lasti
      if {[AuxEnding j line lasti]} {
        set i $lasti
        set st [string range $line $i $j]
        set it 0
        if {[FirstQtd st it $currQtd]} continue  ;# there is a quote yet
        set k $j
        break
      }
    } else {
      if {[AuxEnding j line pri] && $j<$i} {
        set lasti $pri
        set k $j
        break
      }
      HighlightCmd $txt $line $ln $pri $i
      set currQtd 1
    }
    set pri $i
    incr i
  }
  if {$currQtd} {
    HighlightStr $txt $ln.$pri $ln.end
  } elseif {$k>-1 || [AuxEnding k line lasti]} {
    HighlightCmd $txt $line $ln $lasti $k
    HighlightComment $txt $line $ln $k
    if {[string index $line end] eq "\\"} {set currQtd -1}
  } else {
    HighlightCmd $txt $line $ln $lasti [string length $line]
  }
  if {!$data(MULTILINE,$txt) && $currQtd && [string index $line end] ne "\\"} {
    set currQtd 0
  }
  return $currQtd
}
#_____

proc ::hl_tcl::my::HighlightAll {txt} {
  # Highlights all of a text.
  #   txt - text widget's path
  # Makes a coroutine from this.
  # See also: CoroHighlightAll

  # let them work one by one:
  set coroNo [expr {[incr ::hl_tcl::my::data(CORALL)] % 10000000}]
  coroutine co_HlAll$coroNo ::hl_tcl::my::CoroHighlightAll $txt
  return
}
#_____

proc ::hl_tcl::my::CoroHighlightAll {txt} {
  # Highlights all of a text as a coroutine.
  #   txt - text widget's path
  # See also: HighlightAll

  variable data
  catch {  ;# $txt may be destroyed, so catch this
    if {!$data(PLAINTEXT,$txt)} {
      set tlen [lindex [split [$txt index end] .] 0]
      RemoveTags $txt 1.0 end
      set maxl [expr {min($data(SEEN,$txt),$tlen)}]
      set maxl [expr {min($data(SEEN,$txt),$tlen)}]
      for {set currQtd [set ln [set lnseen 0]]} {$ln<=$tlen} {} {
        set currQtd [HighlightLine $txt $ln $currQtd]
        incr ln
        if {[incr lnseen]>$data(SEEN,$txt)} {
          set lnseen 0
          after idle after 1 [info coroutine]
          yield
        }
      }
    }
  }
  set data(REG_TXT,$txt) {1}
  return
}
#_____

proc ::hl_tcl::my::BindToEvent {w event args} {
  # Binds an event on a widget to a command.
  #   w - the widget's path
  #   event - the event
  #   args - the command

  if {[string first $args [bind $w $event]]<0} {
    bind $w $event [list + {*}$args]
  }
  return
}

# _________________________ DYNAMIC highlighting ________________________ #

proc ::hl_tcl::my::CountQSH {txt ln} {
  # Counts quotes, slashes, hashes in a line
  #   txt - text widget's path
  #   ln - line's index

  set ln [expr {int($ln)}]
  set st [$txt get $ln.0 $ln.end]
  return [list [CountChar $st \"] [CountChar $st \\] [CountChar $st #]]
}
#_____

proc ::hl_tcl::my::ShowCurrentLine {txt {doit no}} {
  # Shows the current line.
  #   txt - text widget's path
  #   doit - if yes, forces updating current line's background
  # Returns a current position of cursor.

  variable data
  set pos [$txt index insert]
  set nlines [expr {int([$txt index end])}]
  lassign [split $pos .] ln cn
  if {[catch {lassign [split $data(CURPOS,$txt) .] ln2 cn2}]} {
    set ln2 $ln
    set cn2 $cn
    set data(CURPOS,$txt) [set data(NLINES,$txt) 0]
  }
  if {$doit || int($data(CURPOS,$txt))!=$ln || $data(NLINES,$txt)!=$nlines \
  || $ln!=$ln2 || abs($cn-$cn2)>1 || $cn<2} {
    $txt tag remove tagCURLINE 1.0 end
    $txt tag add tagCURLINE [list $pos linestart] [list $pos lineend]+1displayindices
  }
  set data(NLINES,$txt) $nlines
  set data(CURPOS,$txt) $pos
  return $pos
}
#_____

proc ::hl_tcl::my::MemPos1 {txt {donorm yes} {K ""} {s ""}} {
  # Checks and sets the cursor's width, depending on its position.
  #   txt - text widget's path
  #   donorm - if yes, forces "normal" cursor
  #   K - key (%K of bind)
  #   s - state (%s of bind)
  # This fixes an issue with text cursor: less width at 0th column.

  variable data
  if {$K eq {Home} && [string is digit -strict $s] && \
  [expr {$s & 4}]==0 && [expr {$s & 1}]==0} {
    # Ctrl-Home & Shift-Home are passed
    set p1 [$txt index insert]
    set line [$txt get "$p1 linestart" "$p1 lineend"]
    set p [expr {[string length $line]-[string length [string trimleft $line]]}]
    set p2 [expr {int($p1)}].$p
    if {$p && $p2 ne $p1} {
      after idle "::tk::TextSetCursor $txt $p2"
      return 0
    }
  }
  if {$data(INSERTWIDTH,$txt)==1} {
    if {[$txt cget -insertwidth]!=1} {$txt configure -insertwidth 1}
    return 0
  }
  set insLC [$txt index insert]
  lassign [split $insLC .] L C
  if {$data(_INSPOS_,$txt) eq {}} {
    set L2 [set C2 0]
  } else {
    lassign [split $data(_INSPOS_,$txt) .] L2 C2
  }
  if {$L!=$L2 || $C==0 || $C2==0} {
    if {$C || $donorm} {
      $txt configure -insertwidth $data(INSERTWIDTH,$txt)
    } else {
      $txt configure -insertwidth [expr {$data(INSERTWIDTH,$txt)*2-1}]
    }
  }
  return $insLC
}
#_____

proc ::hl_tcl::my::MemPos {txt {doit no}} {
  # Remembers the state of current line.
  #   txt - text widget's path
  #   doit - argument for ShowCurrentLine
  # See also: ShowCurrentLine

  variable data
  set data(_INSPOS_,$txt) [MemPos1 $txt no]
  set ln [ShowCurrentLine $txt $doit]
  set data(CUR_LEN,$txt) [$txt index {end -1 char}]
  lassign [CountQSH $txt $ln] \
    data(CNT_QUOTE,$txt) data(CNT_SLASH,$txt) data(CNT_COMMENT,$txt)
  if {[$txt tag ranges tagBRACKET] ne {}}    {$txt tag remove tagBRACKET 1.0 end}
  if {[$txt tag ranges tagBRACKETERR] ne {}} {$txt tag remove tagBRACKETERR 1.0 end}
  if {[set cmd $data(CMDPOS,$txt)] ne {}} {
    # run a command after changing position (with the state as arguments)
    append cmd " $txt $data(CUR_LEN,$txt) $ln $data(CNT_QUOTE,$txt) \
      $data(CNT_SLASH,$txt) $data(CNT_COMMENT,$txt)"
    catch {after cancel $data(CMDATFER,$txt)}
    set data(CMDATFER,$txt) [after idle $cmd]
  }
  return
}
#_____

proc ::hl_tcl::my::RunCoroAfterIdle {txt pos1 pos2 wait args} {
  # Runs a "modified" corotine after idle.

  variable data
  if {$wait} {
    catch {
      after cancel $data(COROAFTER,$txt)
      if {$data(COROPOS1,$txt) < $pos1} {set pos1 $data(COROPOS1,$txt)}
      if {$data(COROPOS2,$txt) > $pos2} {set pos2 $data(COROPOS2,$txt)}
    }
    set data(COROPOS1,$txt) $pos1
    set data(COROPOS2,$txt) $pos2
  }
  set data(COROAFTER,$txt) [after idle "::hl_tcl::my::CoroRun $txt $pos1 $pos2 $args"]
  return
}
#_____

proc ::hl_tcl::my::Modified {txt oper pos1 args} {
  # Handles modifications of text.
  #   txt - text widget's path
  # Makes a coroutine from this.
  # See also: CoroModified

  variable data
  set ar2 [lindex $args 0]
  set posins [$txt index insert]
  if {[catch {set pos1 [set pos2 [$txt index $pos1]]}]} {
    set pos1 [set pos2 $posins]
  }
  switch $oper {
    insert {
      set pos2 [expr {$pos1 + [llength [split $ar2 \n]]}]
    }
    delete {
      if {$ar2 eq {} || [catch {set pos2 [$txt index $ar2]}]} {
        set pos2 $posins
      }
    }
  }
  RunCoroAfterIdle $txt $pos1 $pos2 no {*}$args
  return
}
#_____

proc ::hl_tcl::my::CoroRun {txt pos1 pos2 args} {

  variable data
  if {![info exist data(REG_TXT,$txt)] || $data(REG_TXT,$txt) eq {} || \
  ![info exist data(CUR_LEN,$txt)]} {
    # skip changes till the highlighting done
    after 10 [list ::hl_tcl::my::RunCoroAfterIdle $txt $pos1 $pos2 yes {*}$args]
    return
  }
  # let them work one by one
  set i1 [expr {int($pos1)}]
  set i2 [expr {int($pos2)}]
  set coroNo [expr {[incr data(CORMOD)] % 10000000}]
  coroutine CoModified$coroNo ::hl_tcl::my::CoroModified $txt $i1 $i2 {*}$args
  return
}
#_____

proc ::hl_tcl::my::CoroModified {txt {i1 -1} {i2 -1} args} {
  # Handles modifications of text.
  #   txt - text widget's path
  # See also: Modified

  catch {
    variable data
    # current line:
    set ln [expr {int([$txt index insert])}]
    # ending line:
    set endl [expr {int([$txt index {end -1 char}])}]
    # range of change:
    if {$i1!=-1} {
      set dl [expr {abs($i2-$i1)}]
      set ln $i1
    } else {
      set dl [expr {abs(int($data(CUR_LEN,$txt)) - $endl)}]
    }
    # begin and end of changes:
    set ln1 [set lno1 [expr {max(($ln-$dl),1)}]]
    set ln2 [set lno2 [expr {min(($ln+$dl),$endl)}]]
    lassign [CountQSH $txt $ln] cntq cnts ccmnt
    # flag "highlight to the end":
    set bf1 [expr {abs($ln-int($data(CURPOS,$txt)))>1 || $dl>1 \
    || $cntq!=$data(CNT_QUOTE,$txt) \
    || $ccmnt!=$data(CNT_COMMENT,$txt)}]
    set bf2 [expr {$cnts!=$data(CNT_SLASH,$txt)}]
    if {$bf1 && !$data(MULTILINE,$txt) || $bf2} {
      set lnt1 $ln
      set lnt2 [expr {$ln+1}]
      while {$ln2<$endl && $lnt1<$endl && $lnt2<=$endl && ( \
      [$txt get "$lnt1.end -1 char" $lnt1.end] in {\\ \"} ||
      [$txt get "$lnt2.end -1 char" $lnt2.end] in {\\ \"}) || $bf2} {
        incr lnt1 ;# next lines be handled too, if ended with "\\"
        incr lnt2
        incr ln2
        set bf2 0
      }
    }
    set tSTR [$txt tag ranges tagSTR]
    set tCMN [$txt tag ranges tagCMN]
    lappend tCMN {*}[$txt tag ranges tagCMN2]
    if {$ln1==1} {
      set currQtd 0
    } else {
      set currQtd [LineState $txt $tSTR $tCMN "$ln1.0 -1 chars"]
    }
    if {$data(PLAINTEXT,$txt)} {
      $txt tag add tagSTD $ln1.0 $ln2.end
    } else {
      set lnseen 0
      while {$ln1<=$ln2} {
        if {$ln1==$ln2} {
          set bf2 [LineState $txt $tSTR $tCMN "$ln1.end +1 chars"]
        }
        RemoveTags $txt $ln1.0 $ln1.end
        set currQtd [HighlightLine $txt $ln1 $currQtd]
        if {$ln1==$ln2 && ($bf1 || $bf2!=$currQtd) && $data(MULTILINE,$txt)} {
          set ln2 $endl  ;# run to the end
        }
        if {[incr lnseen]>$data(SEEN,$txt)} {
          set lnseen 0
          catch {after cancel $data(COROATFER,$txt)}
          set data(COROATFER,$txt) [after idle after 1 [info coroutine]]
          yield
        }
        incr ln1
      }
    }
    if {[set cmd $data(CMD,$txt)] ne {}} {
      # run a command after changes done (its arguments are txt, ln1, ln2)
      append cmd " $txt $lno1 $lno2 $args"
      {*}$cmd
    }
    MemPos $txt
  }
  return
}
#_____

proc ::hl_tcl::my::InRange {p1 p2 l {c -1}} {
  # Checks if a text position is in a range of text positions.
  #   p1 - 1st position of range
  #   p2 - 2nd position of range
  #   l - line position to check (or 'l.c' if 'c' not set)
  #   c - column position to check

  if {$c==-1} {lassign [split $l .] l c}
  lassign [split $p1 .] l1 c1
  lassign [split $p2 .] l2 c2
  incr c2 -1 ;# text ranges are not right-inclusive
  return [expr { \
    ($l>=$l1 && $l<$l2 && $c>=$c1) || ($l>$l1 && $l<=$l2 && $c<=$c2) ||
    ($l==$l1 && $l1==$l2 && $c>=$c1 && $c<=$c2) || ($l>$l1 && $l<$l2)}]
}
# doctest:
#% ::hl_tcl::my::InRange 9.0 9.20 9.0
#> 1
#% ::hl_tcl::my::InRange 9.1 9.20 9.0
#> 0
#% ::hl_tcl::my::InRange 9.0 9.20 9.19
#> 1
#% ::hl_tcl::my::InRange 9.0 9.20 9.20
#> 0
#% ::hl_tcl::my::InRange 9.0 9.20 8.19
#> 0
#% ::hl_tcl::my::InRange 9.0 9.20 10.0
#> 0
#% ::hl_tcl::my::InRange 9.10 11.2 10.0
#> 1
#% ::hl_tcl::my::InRange 9.0 10.0 9 9999
#> 1
#% puts InRange:[time {::hl_tcl::my::InRange 9.0 9.20 8.20} 10000]
#_____

proc ::hl_tcl::my::SearchTag {tagpos l1} {
  # Searches a position in tag ranges.
  #   tagpos - tag position ranges
  #   l1 - the position to find
  # Returns a found range's index of -1 if not found.

  lassign [split $l1 .] l c
  set i 0
  foreach {p1 p2} $tagpos {
    if {[InRange $p1 $p2 $l $c]} {return $i}
    incr i 2
  }
  return -1
}
#_____

proc ::hl_tcl::my::LineState {txt tSTR tCMN l1} {
  # Gets an initial state of line.
  #   txt - text widget's path
  #   tSTR - ranges of string tags
  #   tCMN - ranges of comment tags
  #   l1 - the line's index
  # Returns: 0 if no tags for the line; 1 if the line is a string's continuation; -1 if the line is a comment's continuation.

  variable data
  set i1 [$txt index $l1]
  if {[set prev [string first -1 $l1]]>-1} {
    set i1 [$txt index "$i1 -1 chars"]
  }
  set ch [$txt get "$i1" "$i1 +1 chars"]
  if {[SearchTag $tCMN [$txt index "$i1 -1 chars"]]!=-1} {  ;# is a comment continues?
    if {$ch eq "\\"} {return -1}
  } elseif {$data(MULTILINE,$txt) || $ch eq "\\"} {         ;# is a string continues?
    set nl [lindex [split $l1 .] 0]
    if {$prev>-1} {
      # is the start of line quoted?
      # Tk tag ranges refer only to non-empty lines
      # => previous two non-empty chars' coordinates are needed
      # to analize whether they:
      # - end the range
      # - are inside of the range
      # - begin the range
      set co1 [set co2 {}]
      while {$nl>1} {
        incr nl -1
        if {[set line [$txt get $nl.0 $nl.end]] ne {}} {
          if {$co2 eq {}} {
            set co2 [$txt index "$nl.end -1 char"]
            if {[string length $line]>1} {
              set co1 [$txt index "$nl.end -2 char"]
              break
            }
          } else {
            set co1 [$txt index "$nl.end -1 char"]
            break
          }
        }
      }
      if {$co2 eq {}} {return 0}   {set f2 [expr {[SearchTag $tSTR $co2]!=-1}]}
      if {$co1 eq {}} {set f1 $f2} {set f1 [expr {[SearchTag $tSTR $co1]!=-1}]}
      set ch [$txt get $co2 "$co2 +1 chars"]
      set c [lindex [split [$txt index $co2] .] 1]
      if {![NotEscaped $line $c]} {set ch {}}
      return [expr {$ch ne {"} && $f2 || $ch eq {"} && !$f1}]
    }
    # is the end of line quoted?
    set line {}
    set nltot [lindex [split [$txt index end] .] 0]
    while {$nl<$nltot} {
      incr nl
      if {[set line [$txt get $nl.0 $nl.end]] ne {}} break
    }
    set i1 $nl.0
    set ch [$txt get $i1 "$i1 +1 chars"]
    set c [lindex [split [$txt index $i1] .] 1]
    if {![NotEscaped $line $c]} {set ch {}}
    set f1 [expr {[SearchTag $tSTR [$txt index $i1]]!=-1}]
    set f2 [expr {[SearchTag $tSTR [$txt index "$i1 +1 chars"]]!=-1}]
    return [expr {$ch ne {"} && $f1 || $ch eq {"} && !$f2}]
  }
  return 0
}

# __________ HEROIC EFFORTS to highlight the matching brackets __________ #

proc ::hl_tcl::my::MergePosList {none args} {
  # Merges lists of numbers that are not-coinciding and sorted.
  #   none - a number to be not allowed in the lists (e.g. less than minimal)
  #   args - list of the lists to be merged
  # Returns a list of pairs: index of list + item of list.

  set itot [set ilist 0]
  set lind [set lout [list]]
  foreach lst $args {
    incr ilist
    incr itot [set llen [llength $lst]]
    lappend lind [list 0 $llen]
  }
  for {set i 0} {$i<$itot} {incr i} {
    set min $none
    set ind -1
    for {set k 0} {$k<$ilist} {incr k} {
      lassign [lindex $lind $k] li llen
      if {$li < $llen} {
        set e [lindex [lindex $args $k] $li]
        if {$min == $none || $min > $e} {
          set ind $k
          set min $e
          set savli [incr li]
          set savlen $llen
        }
      }
    }
    if {$ind == -1} {return -code error {Error: probably in the input data}}
    lset lind $ind [list $savli $savlen]
    lappend lout [list $ind $min]
  }
  return $lout
}
# doctest:
#% ::hl_tcl::my::MergePosList -1 {11 12} 13
#> {0 11} {0 12} {1 13}
#% ::hl_tcl::my::MergePosList -1 {1 8} {2 3}
#> {0 1} {1 2} {1 3} {0 8}
#% ::hl_tcl::my::MergePosList -1 {1 5 8} {2 3 9 12} {0 6 10}
#> {2 0} {0 1} {1 2} {1 3} {0 5} {2 6} {0 8} {1 9} {2 10} {1 12}
#% puts MergePosList:[time {::hl_tcl::my::MergePosList -1 {11 12} 13} 10000]
#_____

proc ::hl_tcl::my::CountChar {str ch {plistName ""} {escaped yes}} {
  # Counts a character in a string.
  #   str - the string
  #   ch - the character
  #   plistName - variable name for a list of positions of *ch*
  #   escaped - true, if the character is escaped.
  # Returns a number of any occurences of character *ch* in string *str*
  # if the character is escaped, but if it is not escaped, only non-escaped
  # characters are counted.

  if {$plistName ne {}} {
    upvar 1 $plistName plist
    set plist [list]
  }
  set icnt [set begidx 0]
  while {[set idx [string first $ch $str]] >= 0} {
    set nidx $idx
    if {$escaped || ![Escaped $str $idx]} {
      incr icnt
      if {$plistName ne {}} {lappend plist [expr {$begidx+$idx}]}
    }
    incr begidx [incr idx]
    set str [string range $str $idx end]
  }
  return $icnt
}
#_____

proc ::hl_tcl::my::Escaped {line curpos} {
  # Checks if a character is escaped in a string.
  #   line - the string
  #   curpos - position of the character in the line
  # Returns 1 if the character is escaped in the string.

  set line [string range $line 0 $curpos-1]
  set linetrim [string trimright $line \\]
  return [expr {([string length $line]-[string length $linetrim])%2}]
}
#_____

proc ::hl_tcl::my::MatchedBrackets {w inplist curpos schar dchar dir} {
  # Finds a match of characters (dchar for schar).
  #   w - text widget's path
  #   inplist - list of strings where to find a match
  #   curpos - position of schar in nl.nc form where nl=1.., nc=0..
  #   schar - source character
  #   dchar - destination character
  #   dir - search direction: 1 to the end, -1 to the beginning of list

  lassign [split $curpos .] nl nc
  if {$schar eq {"}} {
    set npos $nl.$nc
    set hlpr [$w tag prevrange tagSTR $npos]
    if {[llength $hlpr] && [$w compare "$npos +1 char" == [lindex $hlpr 1]]} {
      set dir -1  ;# <- quotes are scanned depending on their range (for tcl/c)
    } else {
      set hlpr [$w tag nextrange tagSTR $npos]
      if {![llength $hlpr] || [$w compare $npos != [lindex $hlpr 0]]} {
        # for plain texts:
        if {[$w search -exact \" "$npos +1 char" end] eq {}} {
          set dir -1
        } else {
          set lfnd [$w search -backwards -all -exact \" $npos 1.0]
          if {[llength $lfnd] % 2} {
            set dir -1
          }
        }
      }
    }
    incr nc $dir
  }
  set escaped [Escaped [lindex $inplist $nl-1] $nc]
  if {$dir==1} {set rng1 "$nc end"} else {set rng1 "0 $nc"; set nc 0}
  set retpos {}
  set scount [set dcount 0]
  incr nl -1
  set inplen [llength $inplist]
  while {$nl>=0 && $nl<$inplen} {
    set line [lindex $inplist $nl]
    set line [string range $line {*}$rng1]
    set sc [CountChar $line $schar slist $escaped]
    set dc [CountChar $line $dchar dlist $escaped]
    set plen [llength [set plist [MergePosList -1 $slist $dlist]]]
    for {set i [expr {$dir>0?0:($plen-1)}]} {$i>=0 && $i<$plen} {incr i $dir} {
      lassign [lindex $plist $i] src pos
      if {$src} {incr dcount} {incr scount}
      if {$scount <= $dcount} {
        set retpos [incr nl].[incr pos $nc]
        break
      }
    }
    if {$retpos ne {}} break
    set nc 0
    set rng1 {0 end}
    incr nl $dir
  }
  return $retpos
}
#_____

proc ::hl_tcl::my::HighlightBrackets {w} {
  # Highlights matching brackets if any.
  #   w - text widget's path

  variable data
  set curpos [ShowCurrentLine $w]
  set curpos2 [$w index {insert -1 chars}]
  set ch [$w get $curpos]
  set il [string first $ch $data(LBR)]
  set ir [string first $ch $data(RBR)]
  set txt [split [$w get 1.0 end] \n]
  if {$il>-1} {
    set brcpos [MatchedBrackets $w $txt $curpos \
      [string index $data(LBR) $il] [string index $data(RBR) $il] 1]
  } elseif {$ir>-1} {
    set brcpos [MatchedBrackets $w $txt $curpos \
      [string index $data(RBR) $ir] [string index $data(LBR) $ir] -1]
  } elseif {[set il [string first [$w get $curpos2] $data(LBR)]]>-1} {
    set curpos $curpos2
    set brcpos [MatchedBrackets $w $txt $curpos \
      [string index $data(LBR) $il] [string index $data(RBR) $il] 1]
  } elseif {[set ir [string first [$w get $curpos2] $data(RBR)]]>-1} {
    set curpos $curpos2
    set brcpos [MatchedBrackets $w $txt $curpos \
      [string index $data(RBR) $ir] [string index $data(LBR) $ir] -1]
  } else {
    return
  }
  if {$brcpos ne {}} {
    $w tag add tagBRACKET $brcpos
    $w tag add tagBRACKET $curpos
  } else {
    $w tag add tagBRACKETERR $curpos
  }
  return
}

# _________________________ INTERFACE procedures ________________________ #

proc ::hl_tcl::hl_readonly {txt {ro -1} {com2 ""}} {
  # Makes the text widget be readonly or gets its 'read-only' state.
  #   txt - text widget's path
  #   ro - flag "the text widget is readonly"
  #   com2 - command to be called at viewing and after changes
  # If 'ro' argument is omitted, returns the widget's 'read-only' state.

  if {$ro==-1} {
    return [expr {[info exists ::hl_tcl::my::data(READONLY,$txt)] && $::hl_tcl::my::data(READONLY,$txt)}]
  }
  set ::hl_tcl::my::data(READONLY,$txt) $ro
  if {$com2 ne {}} {set ::hl_tcl::my::data(CMD,$txt) $com2}
  set newcom "::$txt.internal"
  if {[info commands $newcom] eq ""} {rename $txt $newcom}
  set com "[namespace current]::my::Modified $txt"
  #if {$com2 ne ""} {append com " ; $com2"}
  if {$ro} {proc ::$txt {args} " \
    switch -exact -- \[lindex \$args 0\] \{ \
      insert \{$com2\} \
      delete \{$com2\} \
      replace \{$com2\} \
      default \{ return \[eval $newcom \$args\] \} \
    \}"
  } else {proc ::$txt {args} " \
    switch -exact -- \[lindex \$args 0\] \{ \
      delete \{$com {*}\$args\} \
      insert \{$com {*}\$args\} \
      replace \{$com {*}\$args\} \
    \} ; \
    set _res_ \[eval $newcom \$args\] ; \
    return \$_res_"
  }
  return
}
#_____

proc ::hl_tcl::hl_init {txt args} {
  # Initializes highlighting.
  #   txt - text widget's path
  #   args - dict of options
  # The 'args' options include:
  #   -- - means that only args' options will be initialized (defaults skipped)
  #   -dark - flag "the text widget has dark background"
  #   -readonly - flag "read-only"
  #   -optRE - flag "use of RE to highlight options"
  #   -multiline - flag "allowed multi-line strings"
  #   -cmd - command to watch editing/viewing
  #   -cmdpos - command to watch cursor positioning
  #   -colors - list of colors as set in hl_tcl::hl_colorNames
  #   -font - attributes of font
  #   -seen - lines seen at start
  #   -keywords - additional commands to highlight (as Tk ones)
  # This procedure has to be called before writing a text in the text widget.
  # See also: hl_colorNames

  if {[set setonly [expr {[lindex $args 0] eq {--}}]]} {
    set args [lrange $args 1 end]
  }
  set ::hl_tcl::my::data(REG_TXT,$txt) {}  ;# disables Modified at changing the text
  set ::hl_tcl::my::data(KEYWORDS,$txt) {}
  foreach {opt val} {-dark 0 -readonly 0 -cmd {} -cmdpos {} -optRE 1 \
  -multiline 1 -seen 500 -plaintext no -insertwidth 2 -keywords {}} {
    if {[dict exists $args $opt]} {
      set val [dict get $args $opt]
    } elseif {$setonly} {
      continue  ;# only those set in args are taken into account
    }
    set ::hl_tcl::my::data([string toupper [string range $opt 1 end]],$txt) $val
  }
  set ::hl_tcl::my::data(CMD_TK_EXP) [lsort [list \
    {*}$::hl_tcl::my::data(CMD_TK) {*}$::hl_tcl::my::data(KEYWORDS,$txt)]]
  unset ::hl_tcl::my::data(KEYWORDS,$txt)
  if {[dict exists $args -colors]} {
    set colors [dict get $args -colors]
    lassign [addingColors $::hl_tcl::my::data(DARK,$txt)] clrCURL clrCMN2
    if {[set llen [llength $colors]]==8} {
      lappend colors $clrCURL  ;# add curr.line color if omitted
    }
    if {$llen==9} {
      lappend colors $clrCMN2  ;# add #TODO color if omitted
    }
    set ::hl_tcl::my::data(COLORS,$txt) $colors
    set ::hl_tcl::my::data(SETCOLORS,$txt) 1
  } else {
    if {![info exists ::hl_tcl::my::data(COLORS,$txt)]}  {
      addingColors $::hl_tcl::my::data(DARK,$txt) $txt
    }
  }
  if {!$setonly} {
    if {[dict exists $args -font]} {
      set ::hl_tcl::my::data(FONT,$txt) [dict get $args -font]
    } else {
      set ::hl_tcl::my::data(FONT,$txt) [font actual TkFixedFont]
    }
  }
  if {!$setonly || [dict exists $args -readonly]} {
    hl_readonly $txt $::hl_tcl::my::data(READONLY,$txt)
  }
  if {[string first ::hl_tcl:: [bind $txt]]<0} {
    my::BindToEvent $txt <FocusIn> ::hl_tcl::my::ShowCurrentLine $txt
  }
  set ::hl_tcl::my::data(_INSPOS_,$txt) {}
  my::MemPos $txt
  return
}
#_____

proc ::hl_tcl::hl_text {txt} {
  # Highlights Tcl code of a text widget.
  #   txt - text widget's path

  set font0 $::hl_tcl::my::data(FONT,$txt)
  set font1 [set font2 $font0]
  $txt tag configure tagSTD -font "$font0"
  $txt tag add tagSTD 1.0 end
  dict set font1 -weight bold
  dict set font2 -slant italic
  lassign $::hl_tcl::my::data(COLORS,$txt) \
    clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT clrBRA clrCURL clrCMN2
  $txt tag configure tagCOM -font "$font1" -foreground $clrCOM
  $txt tag configure tagCOMTK -font "$font1" -foreground $clrCOMTK
  $txt tag configure tagSTR -font "$font0" -foreground $clrSTR
  $txt tag configure tagVAR -font "$font0" -foreground $clrVAR
  $txt tag configure tagCMN -font "$font2" -foreground $clrCMN
  $txt tag configure tagCMN2 -font "$font2" -foreground $clrCMN2 ;#red
  $txt tag configure tagPROC -font "$font1" -foreground $clrPROC
  $txt tag configure tagOPT -font "$font0" -foreground $clrOPT
  $txt tag configure tagBRACKET -font "$font0" -foreground $clrBRA
  $txt tag configure tagBRACKETERR -font "$font0" -foreground white -background red
  $txt tag configure tagCURLINE -background $clrCURL
  $txt tag raise sel
  $txt tag raise tagBRACKETERR
  catch {$txt tag raise hilited;  $txt tag raise hilited2} ;# for apave package
  my::HighlightAll $txt
  if {![info exists ::hl_tcl::my::data(BIND_TXT,$txt)]} {
    my::BindToEvent $txt <FocusIn> ::hl_tcl::my::MemPos $txt
    my::BindToEvent $txt <KeyPress> ::hl_tcl::my::MemPos1 $txt yes %K %s
    my::BindToEvent $txt <KeyRelease> ::hl_tcl::my::MemPos $txt
    my::BindToEvent $txt <ButtonRelease-1> ::hl_tcl::my::MemPos $txt
    foreach ev {Enter KeyRelease ButtonRelease-1} {
      my::BindToEvent $txt <$ev> ::hl_tcl::my::HighlightBrackets $txt
    }
    set ::hl_tcl::my::data(BIND_TXT,$txt) yes
  }
  set ro $::hl_tcl::my::data(READONLY,$txt)
  set com2 $::hl_tcl::my::data(CMD,$txt)
  set txtattrs [list $txt $ro $com2]
  if {![info exists ::hl_tcl::my::data(LIST_TXT)] || \
  [set i [lsearch -index 0 -exact $::hl_tcl::my::data(LIST_TXT) $txt]]==-1} {
    lappend ::hl_tcl::my::data(LIST_TXT) $txtattrs
  } else {
    set ::hl_tcl::my::data(LIST_TXT) [lreplace $::hl_tcl::my::data(LIST_TXT) $i $i $txtattrs]
  }
  hl_readonly $txt $ro $com2
  return
}
#_____

proc ::hl_tcl::hl_all {args} {
  # Updates ("rehighlights") all highlighted and existing text widgets.
  #   args - dict of options
  # See also: hl_init

  if {[info exists ::hl_tcl::my::data(LIST_TXT)]} {
    foreach wattrs $::hl_tcl::my::data(LIST_TXT) {
      lassign $wattrs txt ro com2
      if {[winfo exists $txt]} {
        if {![info exists ::hl_tcl::my::data(SETCOLORS,$txt)]} {
          unset ::hl_tcl::my::data(COLORS,$txt) ;# colors defined by DARK
        }
        # args (if set) override the appropriate settings for $txt
        hl_init $txt -- {*}$args
        hl_text $txt
      }
    }
  }
  return
}
#_____

proc ::hl_tcl::hl_colorNames {} {
  # Returns a list of color names for syntax highlighting.

  return [list clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT clrBRA]
}

#_____

proc ::hl_tcl::hl_colors {txt {dark ""} args} {
  # Gets/sets the main colors for highlighting (except for "curr.line").
  #   txt - text widget's path or {} or an index of default colors
  #   dark - flag "dark scheme"
  #   args - a list of colors to set for *txt*
  # Returns a list of colors for COM COMTK STR VAR CMN PROC OPT BRAC \
   or, if the colors aren't initialized, "standard" colors.

  if {[llength $args]} {
    set ::hl_tcl::my::data(COLORS,$txt) $args
    return
  }
  if {[info exists ::hl_tcl::my::data(COLORS,$txt)]}  {
    return $::hl_tcl::my::data(COLORS,$txt)
  }
  if {$dark eq {}} {set dark $::hl_tcl::my::data(DARK,$txt)}
  if {![string is integer -strict $txt] || $txt<0 || $txt>3} {set txt 0}
  if {$dark} {set dark 1} {set dark 0}
  return [lindex $::hl_tcl::my::data(SYNTAXCOLORS,$txt) $dark]
}
#_____

proc ::hl_tcl::hl_line {txt} {
  # Updates a current line's highlighting.
  #   txt - text's path

  if {!$::hl_tcl::my::data(PLAINTEXT,$txt)} {
    set ln0 [expr {int([$txt index insert])}]
    set ln2 [expr {int([$txt index end])}]
    set ln1 [expr {max (1,$ln0-1)}]
    set ln2 [expr {min ($ln2,$ln0+1)}]
    # update lines: previous, current, next
    ::hl_tcl::my::RunCoroAfterIdle $txt $ln1 $ln2 no
  }
  ::hl_tcl::my::MemPos $txt yes
  $txt configure -insertwidth $::hl_tcl::my::data(INSERTWIDTH,$txt)
  return
}
#_____

proc ::hl_tcl::addingColors {{dark ""} {txt ""} {cs ""}} {
  # Sets/gets colors for a text syntax highlighting.
  #   dark - yes, if the current theme is dark
  #   txt - path to the text or {}
  #   cs - color scheme
  # If *txt* omitted, returns a list of resting colors.
  # The resting colors are:
  #   - current line's background
  #   - #TODO and #! comment's foreground

  variable my::data
  # try to get color options from current apave settings
  if {[catch {set clrCURL [lindex [::apave::obj csGet $cs] 16]}]} {
    set clrCURL {}
  }
  if {$dark eq {}} {
    if {[catch {set dark [::apave::obj csDark]}]} {
      set dark no
    }
  }
  if {$dark} {
    if {$clrCURL eq {}} {set clrCURL #29383c}
    set clrCMN2 #ff7272
  } else {
    if {$clrCURL eq {}} {set clrCURL #efe0cd}
    set clrCMN2 #ff0000
  }
  if {$txt eq {}} {
    return [list $clrCURL $clrCMN2]
  }
  set my::data(COLORS,$txt) [list {*}[hl_colors $txt] $clrCURL $clrCMN2]
}
#_____

proc ::hl_tcl::hl_commands {} {
  # Lists all Tcl/Tk commands registered here.

  variable my::data
  return [list {*}$my::data(PROC_TCL) {*}$my::data(CMD_TCL) {*}$my::data(CMD_TK)]
}
# _________________________________ EOF _________________________________ #
#RUNF1: ../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
#RUNF1: ~/PG/github/pave/tests/test2_pave.tcl 37 9 12
