###########################################################
# Name:    hl_c.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    06/16/2021
# Brief:   Handles highlighting C code.
# License: MIT.
###########################################################

# ______________________ Common data ____________________ #

namespace eval ::hl_c {

  namespace eval my {

    variable data;  array set data [list]

    # C reserved words
    set data(PROC_C) [lsort [list goto return]]
    set data(CMD_C1) [list \
    auto break case char const continue default do double else enum extern \
    float for if inline int long register restrict short signed sizeof \
    static struct switch typedef union unsigned void volatile while \
    ]
    # other C token
    set data(CMD_C2) [list \
    ifdef endif \
    ]
    set data(CMD_C) [lsort [concat $data(CMD_C1) $data(CMD_C2)]]

    # C++ reserved words
    set data(CMD_CPP1) [list \
    and and_eq asm bitand bitor bool catch class compl const_cast delete \
    dynamic_cast explicit false friend inline  mutable namespace new \
    not not_eq operator or or_eq private public protected \
    reinterpret_cast static_cast template this throw true try typeid \
    typename using virtual wchar_t xor xor_eq \
    ]

    # C++ predefined identifiers
    set data(CMD_CPP2) [list \
    cin cout endl include INT_MAX INT_MIN iomanip iostream main MAX_RAND \
    npos NULL std string FALSE TRUE \
    ]

    # C++ united
    set data(CMD_CPP) [lsort [concat $data(CMD_CPP1) $data(CMD_CPP2)]]

    # regexp for key words and punctuation
    set data(RE0) {\w+}
    set data(RE1) {[<>(){};=!%&^*+-.,\|:/\\#]+}

    # characters of multiline comment, string and char and their counterparts
    set data(PAIR1) [list /* \" ' //]
    set data(PAIR2) [list */ \" ']
    set data(PAIR_COMMENT) 0  ;# indices for multiline comment/ string/ char
    set data(PAIR_STRING) 1
    set data(PAIR_CHAR) 2
    set data(PAIR_COMMENT1) 3
  }
}

# _________________________ STATIC highlighting _________________________ #

proc ::hl_c::my::HighlightCmd {txt line ln pri i} {
  # Highlights Tcl/Tk commands.
  #   txt - text widget's path
  #   line - line to be highlighted
  #   ln - line number
  #   pri - column number to highlighted from
  #   i - current position in 'line'

  variable data
  $txt tag add tagSTD "$ln.$pri" "$ln.$i"
  set st [string range $line $pri $i]
  set lcom [regexp -inline -all -indices $data(RE0) $st]
  foreach lc $lcom {
    lassign $lc i1 i2
    set word [string range $st $i1 $i2]
    if {$word in $data(CMD_C)} {
      $txt tag add tagCOM "$ln.$pri +$i1 char" "$ln.$pri +[incr i2] char"
    } elseif {$word in $data(PROC_C)} {
      $txt tag add tagPROC "$ln.$pri +$i1 char" "$ln.$pri +[incr i2] char"
    } elseif {$word in $data(CMD_CPP)} {
      $txt tag add tagCOMTK "$ln.$pri +$i1 char" "$ln.$pri +[incr i2] char"
    } elseif {$word in $data(KEYWORDS,$txt)} {
      $txt tag add tagOPT "$ln.$pri +$i1 char" "$ln.$pri +[incr i2] char"
    }
  }
  set lcom [regexp -inline -all -indices $data(RE1) $st]
  foreach lc $lcom {
    lassign $lc i1 i2
    $txt tag add tagVAR "$ln.$pri +$i1 char" "$ln.$pri +[incr i2] char"
  }
  return
}
#_____

proc ::hl_c::my::HighlightLine {txt ln currQtd} {
  # Highlightes a line in text.
  #   txt - text widget's path
  #   ln - line's number
  #   currQtd - 0, 1 or 2 referring to comment/string/char
  # Returns currQtd for the end of the line.

  variable data
  set line [$txt get $ln.0 $ln.end]
  set i1 [set i0 0]
  set i2 [set llen [string length $line]]
  while {$i1<$llen} {
    if {$currQtd>-1} {
      # if quoted then there follows a multiline comment or a string/char
      # => find its pair
      if {$currQtd==$data(PAIR_COMMENT)} {
        set tag tagCMN  ;# comment
      } else {
        set tag tagSTR  ;# string/char
      }
      set ch [lindex $data(PAIR2) $currQtd]
      set i2 [string first $ch $line $i1]
      while {$i2!=-1} {
        if {[::hl_tcl::my::NotEscaped $line $i2]} break
        set i2 [string first $ch $line $i2+1]
      }
      if {$i2==-1} {
        # a pair not found - the comment/string/char is not ended
        if {$currQtd!=$data(PAIR_COMMENT) && \
        ($currQtd==$data(PAIR_CHAR) || [string index $line end] ne "\\")} {
          set currQtd -1  ;# char or string not ended properly
        }
        $txt tag add $tag $ln.$i0 $ln.end
        return $currQtd
      }
      # the pair found - highlight an appropriate part of the line
      set lp [string length [lindex $data(PAIR2) $currQtd]]
      $txt tag add $tag $ln.[incr i1 -$lp] $ln.[incr i2 $lp]
      set i1 $i2
      set currQtd -1
      continue
    }
    # not quoted - find a nearest "quote" (comment/string/char)
    set i0 $llen
    set i 0
    foreach par $data(PAIR1) {
      if {[set p [string first $par $line $i1]]>-1 && $p<$i0 && [::hl_tcl::my::NotEscaped $line $p]} {
        set i0 $p
        set ip $i
      }
      incr i
    }
    if {$i0<$llen} {
      HighlightCmd $txt $line $ln $i1 [expr {$i0-1}]
      # a comment/string/char was found
      if {$ip==$data(PAIR_COMMENT1)} {
        $txt tag add tagCMN1 $ln.$i0 $ln.end
        return -1  ;# it was a one-line comment
      }
      set currQtd $ip
      set lp [string length [lindex $data(PAIR2) $currQtd]]
      set i1 [expr {$i0+$lp}]
      if {$i1>=($llen-1)} {
        if {$currQtd==$data(PAIR_COMMENT)} {
          set tag tagCMN  ;# comment
        } else {
          set tag tagSTR  ;# string/char
        }
        $txt tag add $tag $ln.$i0 $ln.end
      }
      continue
    }
    HighlightCmd $txt $line $ln $i1 [expr {$llen-1}]
    set currQtd -1
    break
  }
  return $currQtd
}
#_____

proc ::hl_c::my::HighlightAll {txt} {
  # Highlights all of a text.
  #   txt - text widget's path
  # Makes a coroutine from this.
  # See also: CoroHighlightAll

  # let them work one by one:
  set coroNo [expr {[incr ::hl_c::my::data(CORALL)] % 10000000}]
  coroutine co_HlAll$coroNo ::hl_c::my::CoroHighlightAll $txt
}
#_____

proc ::hl_c::my::CoroHighlightAll {txt} {
  # Highlights all of a text as a coroutine.
  #   txt - text widget's path
  # See also: HighlightAll

  variable data
  catch {  ;# $txt may be destroyed, so catch this
    if {!$data(PLAINTEXT,$txt)} {
      set tlen [lindex [split [$txt index end] .] 0]
      RemoveTags $txt 1.0 end
      set maxl [expr {min($::hl_c::my::data(SEEN,$txt),$tlen)}]
      set maxl [expr {min($::hl_c::my::data(SEEN,$txt),$tlen)}]
      set currQtd -1
      for {set ln [set lnseen 0]} {$ln<=$tlen} {} {
        set currQtd [HighlightLine $txt $ln $currQtd]
        incr ln
        if {[incr lnseen]>$::hl_c::my::data(SEEN,$txt)} {
          set lnseen 0
          after idle after 1 [info coroutine]
          yield
        }
      }
    }
  }
  set ::hl_c::my::data(REG_TXT,$txt) {1}
  return
}

# _________________________ DYNAMIC highlighting ________________________ #

proc ::hl_c::my::RemoveTags {txt from to} {
  # Removes tags in text.
  #   txt - text widget's path
  #   from - starting index
  #   to - ending index

  foreach tag {tagCOM tagCOMTK tagSTR tagVAR tagCMN tagCMN1 tagPROC tagOPT} {
    $txt tag remove $tag $from $to
  }
  return
}
#_____

proc ::hl_c::my::CountQSH {txt ln} {
  # Counts quotes, slashes, comments in a line
  #   txt - text widget's path
  #   ln - line's index

  set ln [expr {int($ln)}]
  set st [$txt get $ln.0 $ln.end]
  set quotes 0
  foreach spch {"\"" '} {
    incr quotes [::hl_tcl::my::CountChar $st $spch]
  }
  set slashes [::hl_tcl::my::CountChar $st "\\"]
  set comments 0
  foreach spch {/ *} {
    incr comments [::hl_tcl::my::CountChar $st $spch]
  }
  return [list $quotes $slashes $comments]
}
#_____

proc ::hl_c::my::MemPos1 {txt {donorm yes} {K ""} {s ""}} {
  # Checks and sets the cursor's width, depending on its position.
  #   txt - text widget's path
  #   donorm - if yes, forces "normal" cursor
  #   K - key (%K of bind)
  #   s - state (%s of bind)
  # This fixes an issue with text cursor: less width at 0th column.

  variable data
  if {$K eq "Home" && [string is digit -strict $s] && \
  [expr {$s & 4}]==0 && [expr {$s & 1}]==0} {
    # Ctrl-Home & Shift-Home are passed
    set p1 [$txt index insert]
    set line [$txt get "$p1 linestart" "$p1 lineend"]
    set p [expr {[string length $line]-[string length [string trimleft $line]]}]
    set p2 [expr {int($p1)}].$p
    if {$p && $p2 ne $p1} {
      after idle "::tk::TextSetCursor $txt $p2"
      return
    }
  }
  if {$data(INSERTWIDTH,$txt)==1} {
    if {[$txt cget -insertwidth]!=1} {$txt configure -insertwidth 1}
    return 0
  }
  set insLC [$txt index insert]
  lassign [split $insLC .] L C
  if {$data(_INSPOS_,$txt) eq ""} {
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

proc ::hl_c::my::MemPos {txt {doit no}} {
  # Remembers the state of current line.
  #   txt - text widget's path
  #   doit - argument for ShowCurrentLine
  # See also: ShowCurrentLine

  variable data
  set data(_INSPOS_,$txt) [MemPos1 $txt no]
  set ln [ShowCurrentLine $txt $doit]
  set data(CURPOS,$txt) $ln
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
}
#_____

proc ::hl_c::my::Modified {txt oper pos1 args} {
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
  after idle "::hl_c::my::CoroRun $txt $pos1 $pos2 $args"
}
#_____

proc ::hl_c::my::CoroRun {txt pos1 pos2 args} {

  variable data
  if {![info exist data(REG_TXT,$txt)] || $data(REG_TXT,$txt) eq {} || \
  ![info exist data(CUR_LEN,$txt)]} {
    return  ;# skip changes till the highlighting done
  }
  # let them work one by one
  set i1 [expr {int($pos1)}]
  set i2 [expr {int($pos2)}]
  set coroNo [expr {[incr ::hl_c::my::data(CORMOD)] % 10000000}]
  coroutine CoModified$coroNo ::hl_c::my::CoroModified $txt $i1 $i2 {*}$args
}
#_____

proc ::hl_c::my::CoroModified {txt {i1 -1} {i2 -1} args} {
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
    if {$ln1==1} {
      set currQtd -1
    } else {
      set currQtd [LineState $txt $tSTR $tCMN "$ln1.0 -1 chars"]
    }
    if {!$data(PLAINTEXT,$txt)} {
      set lnseen 0
      $txt tag add tagSTD $ln1.0 $ln2.end
      while {$ln1<=$ln2} {
        if {$ln1==$ln2} {
          set bf2 [LineState $txt $tSTR $tCMN "$ln1.end +1 chars"]
        }
        RemoveTags $txt $ln1.0 $ln1.end
        set currQtd [HighlightLine $txt $ln1 $currQtd]
        if {$ln1==$ln2 && ($bf1 || $bf2!=$currQtd) && $data(MULTILINE,$txt)} {
          set ln2 $endl  ;# run to the end
        }
        if {[incr lnseen]>$::hl_c::my::data(SEEN,$txt)} {
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
    return
  }
}
#_____

proc ::hl_c::my::LineState {txt tSTR tCMN l1} {
  # Gets an initial state of line.
  #   txt - text widget's path
  #   tSTR - ranges of string tags
  #   tCMN - ranges of comment tags
  #   l1 - the line's index
  # Returns: a flag of 'quoted' line or -1.

  set i1 [$txt index $l1]
  if {[set prev [string first -1 $l1]]>-1} {
    set i1 [$txt index "$i1 -1 chars"]
  }
  if {[::hl_tcl::my::SearchTag $tCMN [$txt index "$i1 -1 chars"]]!=-1} {
    if {[$txt get "$i1 -1 chars" "$i1 +1 chars"] eq {*/}} {
      return -1
    }
    return 0
  }
  set ch [$txt get "$i1" "$i1 +1 chars"]
  if {[::hl_tcl::my::SearchTag $tSTR [$txt index "$i1 -1 chars"]]!=-1} {
    if {$ch eq "\\"} {return 1}
  }
  return -1
}
#_____

proc ::hl_c::my::ShowCurrentLine {txt {doit no}} {
  # Shows the current line.
  #   txt - text widget's path
  #   doit - if yes, forces updating current line's background

  variable data
  set pos [$txt index insert]
  lassign [split $pos .] ln cn
  if {$doit || ![info exists data(CURPOS,$txt)] || int($data(CURPOS,$txt))!=$ln || $cn<2} {
    $txt tag remove tagCURLINE 1.0 end
    $txt tag add tagCURLINE [list $pos linestart] [list $pos lineend]+1displayindices
  }
  return $pos
}

# _________________________ INTERFACE procedures ________________________ #

proc ::hl_c::hl_readonly {txt {ro -1} {com2 ""}} {
  # Makes the text widget be readonly or gets its 'read-only' state.
  #   txt - text widget's path
  #   ro - flag "the text widget is readonly"
  #   com2 - command to be called at viewing and after changes
  # If 'ro' argument is omitted, returns the widget's 'read-only' state.

  if {$ro==-1} {
    return [expr {[info exists ::hl_c::my::data(READONLY,$txt)] && $::hl_c::my::data(READONLY,$txt)}]
  }
  set ::hl_c::my::data(READONLY,$txt) $ro
  if {$com2 ne {}} {set ::hl_c::my::data(CMD,$txt) $com2}
  set newcom "::$txt.internal"
  if {[info commands $newcom] eq ""} {rename $txt $newcom}
  set com "[namespace current]::my::Modified $txt"
  #if {$com2 ne ""} {append com " ; $com2"}
  if {$ro} {proc ::$txt {args} "
    switch -exact -- \[lindex \$args 0\] \{
      insert \{$com2\}
      delete \{$com2\}
      replace \{$com2\}
      default \{ return \[eval $newcom \$args\] \}
    \}"
  } else {proc ::$txt {args} "
    switch -exact -- \[lindex \$args 0\] \{
      delete \{$com {*}\$args\}
      insert \{$com {*}\$args\}
      replace \{$com {*}\$args\}
    \}
    set _res_ \[eval $newcom \$args\]
    return \$_res_"
  }
}
#_____

proc ::hl_c::hl_init {txt args} {
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
  #   -colors - list of colors: clrCOM, clrCOMTK, clrSTR, clrVAR, clrCMN, clrPROC
  #   -font - attributes of font
  #   -seen - lines seen at start
  # This procedure has to be called before writing a text in the text widget.

  if {[set setonly [expr {[lindex $args 0] eq {--}}]]} {
    set args [lrange $args 1 end]
  }
  set ::hl_c::my::data(REG_TXT,$txt) {}  ;# disables Modified at changing the text
  set ::hl_c::my::data(KEYWORDS,$txt) {}
  foreach {opt val} {-dark 0 -readonly 0 -cmd {} -cmdpos {} -optRE 1 \
  -multiline 1 -seen 500 -plaintext no -insertwidth 2 -keywords {}} {
    if {[dict exists $args $opt]} {
      set val [dict get $args $opt]
    } elseif {$setonly} {
      continue  ;# only those set in args are taken into account
    }
    set ::hl_c::my::data([string toupper [string range $opt 1 end]],$txt) $val
  }
  set ::hl_c::my::data(KEYWORDS,$txt) [lsort $::hl_c::my::data(KEYWORDS,$txt)]
  if {[dict exists $args -colors]} {
    set ::hl_c::my::data(COLORS,$txt) [dict get $args -colors]
    set ::hl_c::my::data(SETCOLORS,$txt) 1
  } else {
    if {![info exists ::hl_c::my::data(COLORS,$txt)]}  {
      set clrCURL {}
      catch {set clrCURL [lindex [::apave::obj csGet] 16]}
      if {$::hl_c::my::data(DARK,$txt)} {
        if {$clrCURL eq {}} {set clrCURL #29383c}
        set ::hl_c::my::data(COLORS,$txt) [list {*}[hl_colors $txt] $clrCURL]
      } else {
        if {$clrCURL eq {}} {set clrCURL #efe0cd}
        set ::hl_c::my::data(COLORS,$txt) [list {*}[hl_colors $txt] $clrCURL]
      }
    }
  }
  if {!$setonly} {
    if {[dict exists $args -font]} {
      set ::hl_c::my::data(FONT,$txt) [dict get $args -font]
    } else {
      set ::hl_c::my::data(FONT,$txt) [font actual TkFixedFont]
    }
  }
  if {!$setonly || [dict exists $args -readonly]} {
    hl_readonly $txt $::hl_c::my::data(READONLY,$txt)
  }
  if {[string first ::hl_c:: [bind $txt]]<0} {
    ::hl_tcl::my::BindToEvent $txt <FocusIn> ::hl_c::my::ShowCurrentLine $txt
  }
  set ::hl_c::my::data(_INSPOS_,$txt) {}
  my::MemPos $txt
}
#_____

proc ::hl_c::hl_text {txt} {
  # Highlights Tcl code of a text widget.
  #   txt - text widget's path

  set font0 $::hl_c::my::data(FONT,$txt)
  set font1 [set font2 $font0]
  $txt tag configure tagSTD -font "$font0"
  $txt tag add tagSTD 1.0 end
  dict set font1 -weight bold
  dict set font2 -slant italic
  lassign $::hl_c::my::data(COLORS,$txt) \
    clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT clrBRA clrCURL
  $txt tag configure tagCOM -font "$font1" -foreground $clrCOM
  $txt tag configure tagCOMTK -font "$font1" -foreground $clrCOMTK
  $txt tag configure tagSTR -font "$font0" -foreground $clrSTR
  $txt tag configure tagVAR -font "$font0" -foreground $clrVAR
  $txt tag configure tagCMN -font "$font2" -foreground $clrCMN
  $txt tag configure tagCMN1 -font "$font2" -foreground $clrCMN
  $txt tag configure tagPROC -font "$font1" -foreground $clrPROC
  $txt tag configure tagOPT -font "$font1" -foreground $clrOPT
  $txt tag configure tagBRACKET -font "$font0" -foreground $clrBRA
  $txt tag configure tagBRACKETERR -font "$font0" -foreground white -background red
  $txt tag configure tagCURLINE -background $clrCURL
  $txt tag raise sel
  $txt tag raise tagBRACKETERR
  catch {$txt tag raise hilited;  $txt tag raise hilited2} ;# for apave package
  my::HighlightAll $txt
  if {![info exists ::hl_c::my::data(BIND_TXT,$txt)]} {
    ::hl_tcl::my::BindToEvent $txt <FocusIn> ::hl_c::my::MemPos $txt
    ::hl_tcl::my::BindToEvent $txt <KeyPress> ::hl_c::my::MemPos1 $txt yes %K %s
    ::hl_tcl::my::BindToEvent $txt <KeyRelease> ::hl_c::my::MemPos $txt
    ::hl_tcl::my::BindToEvent $txt <ButtonRelease-1> ::hl_c::my::MemPos $txt
    foreach ev {Enter KeyRelease ButtonRelease-1} {
      ::hl_tcl::my::BindToEvent $txt <$ev> ::hl_tcl::my::HighlightBrackets $txt
    }
    set ::hl_c::my::data(BIND_TXT,$txt) yes
  }
  set ro $::hl_c::my::data(READONLY,$txt)
  set com2 $::hl_c::my::data(CMD,$txt)
  set txtattrs [list $txt $ro $com2]
  if {![info exists ::hl_c::my::data(LIST_TXT)] || \
  [set i [lsearch -index 0 -exact $::hl_c::my::data(LIST_TXT) $txt]]==-1} {
    lappend ::hl_c::my::data(LIST_TXT) $txtattrs
  } else {
    set ::hl_c::my::data(LIST_TXT) [lreplace $::hl_c::my::data(LIST_TXT) $i $i $txtattrs]
  }
  hl_readonly $txt $ro $com2
}
#_____

proc ::hl_c::hl_all {args} {
  # Updates ("rehighlights") all highlighted and existing text widgets.
  #   args - dict of options
  # See also: hl_init

  if {[info exists ::hl_c::my::data(LIST_TXT)]} {
    foreach wattrs $::hl_c::my::data(LIST_TXT) {
      lassign $wattrs txt ro com2
      if {[winfo exists $txt]} {
        if {![info exists ::hl_c::my::data(SETCOLORS,$txt)]} {
          unset ::hl_c::my::data(COLORS,$txt) ;# colors defined by DARK
        }
        # args (if set) override the appropriate settings for $txt
        hl_init $txt -- {*}$args
        hl_text $txt
      }
    }
  }
}
#_____

proc ::hl_c::hl_colors {txt {dark ""}} {
  # Gets the main colors for highlighting (except for "curr.line").
  #   txt - text widget's path or {} or an index of default colors
  #   dark - flag "dark scheme"
  # Returns a list of colors for COM COMTK STR VAR CMN PROC OPT BRAC \
   or, if the colors aren't initialized, "standard" colors.

  if {[info exists ::hl_c::my::data(COLORS,$txt)]}  {
    return $::hl_c::my::data(COLORS,$txt)
  }
  if {$dark eq {}} {set dark $::hl_c::my::data(DARK,$txt)}
  if {![string is integer -strict $txt] || $txt<0 || $txt>3} {set txt 0}
  if {$dark} {set dark 1} {set dark 0}
  set res [lindex $::hl_tcl::my::data(SYNTAXCOLORS,$txt) $dark]
  # user keywords' color = Tk color
  set res [lreplace $res 6 6 [lindex $res 1]]
  return $res
}
#_____

proc ::hl_c::hl_line {txt} {
  # Updates a current line's highlighting.
  #   txt - text's path

  if {!$::hl_c::my::data(PLAINTEXT,$txt)} {
    set ln0 [expr {int([$txt index insert])}]
    set ln2 [expr {int([$txt index end])}]
    set ln1 [expr {max (1,$ln0-1)}]
    set ln2 [expr {min ($ln2,$ln0+1)}]
    # update lines: previous, current, next 
    after idle "::hl_c::my::CoroRun $txt $ln1 $ln2"
  }
  ::hl_c::my::MemPos $txt yes
  $txt configure -insertwidth $::hl_c::my::data(INSERTWIDTH,$txt)
}

# _________________________________ EOF _________________________________ #
#RUNF1: ../../src/alited.tcl DEBUG
#RUNF1: ~/PG/github/pave/tests/test2_pave.tcl 37 9 12
