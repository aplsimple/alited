
# The mode=5 means that the result of Tcl command(s) will be inserted at the
# current cursor position.
#
# The command can include wildcards:
#   %w for current text's path
#   %v for selected text (or current line)
#
# The command can use "_", "__", "_1", "_2" and similar names of variables.
#
# If empty "command=" is set, the rest of file is treated as Tcl code block
# to be executed.
#
# If not empty, the result of last command is inserted at the current text
# position.

# ===========================================================================

# Formats selected text "to Title" (e.g. "war and peace" -> "War and Peace").

Mode = 5

Command =

proc SELECTION_TOTITLE {seltext} {
  # Formats selected text "to Title".
  #   seltext - selected text

  set toupper [list do be is it he me my us we ok go hi lo pc]
  set tolower [list the and for but from out off into down over under far \
    afar after before again against ago ahead alike unlike until unless till \
    among amongst behind below beneath because despite else even too about \
    above away aside not nor per with without]
  set lfound [regexp -inline -indices -all -nocase {(\w{2,})|(\w\.)} $seltext]
  foreach {p1p2 - -} $lfound {
    incr wcnt
    lassign $p1p2 p1 p2
    set word [string range $seltext $p1 $p2]
    set wlen [string length $word]
    set word [string tolower $word]
    if {$wcnt==1 || $word in $toupper || ($wlen>2 && $word ni $tolower)
    || [string index $word 1] eq {.}} {
      set word [string totitle $word]
    }
    incr p1 -1
    incr p2
    set seltext [string range $seltext 0 $p1]$word[string range $seltext $p2 end]
  }
  return $seltext
}


SELECTION_TOTITLE {%v}
