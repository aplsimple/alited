
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

# Formats sentences of selected text to title. Sentences are separated with
"." and \n.

Mode = 5

Command =

proc LINE_TOTITLE {line} {
  # Formats a line to title.
  #   line - the line

  set res {}
  set dvd .
  set idx -1
  foreach sentence [split $line $dvd] {
    if {[incr idx]} {append res $dvd}
    # skip first non-words
    set w1 [lindex [regexp -indices -inline {\w} $sentence] 0 0]
    if {$w1 ne {}} {
      set st [string range $sentence $w1 end]
      append res [string range $sentence 0 [incr w1 -1]][string totitle $st]
    } else {
      append res $sentence
    }
  }
  return $res
}

proc SELECTION_TOTITLE {seltext} {
  # Formats selected text to title.
  #   seltext - selected text

  set res {}
  set dvd \n
  set idx -1
  foreach line [split $seltext $dvd] {
    if {[incr idx]} {append res $dvd}
    append res [LINE_TOTITLE $line]
  }
  return $res
}


SELECTION_TOTITLE {%v}
