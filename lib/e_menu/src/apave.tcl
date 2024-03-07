###########################################################
# Name:    apave.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    12/09/2021
# Brief:   Handles APave class creating input dialogs.
# License: MIT.
###########################################################

package require Tk
package provide apave 4.4.0

source [file join [file dirname [info script]] apavedialog.tcl]

namespace eval ::apave {
  mainWindowOfApp .

  # ________________________ Independent procs _________________________ #

  proc None {args} {
    # Useful when to do nothing is better than to do something.

  }
  #_______________________

  proc p+ {p1 p2} {
    # Sums two text positions straightforward: lines & columns separately.
    #   p1 - 1st position
    #   p2 - 2nd position
    # The lines may be with "-".
    # Reasons for this:
    #  1. expr $p1+$p2 doesn't work, e.g. 309.10+1.4=310.5 instead of 310.14
    #  2. do it without a text widget's path (for text's arithmetic)

    lassign [split $p1 .] l11 c11
    lassign [split $p2 .] l21 c21
    foreach n {l11 c11 l21 c21} {
      if {![string is digit -strict [string trimleft [set $n] -]]} {set $n 0}
    }
    return [incr l11 $l21].[incr c11 $c21]
  }
  #_______________________

  proc pint {pos} {
    # Gets int part of text position, e.g. "4" for "4.end".
    #   pos - position in text

    if {[set i [string first . $pos]]>0} {incr i -1} {set i end}
    expr {int([string range $pos 0 $i])}
  }

  #_______________________

  proc intInRange {int min max} {
    # Checks whether an integer is in min-max range.
    #   int - the integer
    #   min - minimum of the range
    #   max - maximum of the range

    expr {[string is integer -strict $int] && $int>=$min && $int<=$max}
  }
  #_______________________

  proc IsRoundInt {i1 i2} {
    # Checks whether an integer equals roundly to other integer.
    #   i1 - integer to compare
    #   i2 - integer to be compared (rounded) to i1

    return [expr {$i1>($i2-3) && $i1<($i2+3)}]
  }
  #_______________________

  proc NormalizeName {name} {
    # Removes spec.characters from a name (sort of normalizing it).
    #   name - the name

    return [string map [list \\ {} \{ {} \} {} \[ {} \] {} \t {} \n {} \r {} \" {}] $name]
  }
  #_______________________

  proc NormalizeFileName {name} {
    # Removes spec.characters from a file/dir name (sort of normalizing it).
    #   name - the name of file/dir

    set name [string trim $name]
    return [string map [list \
      * _ ? _ ~ _ / _ \\ _ \{ _ \} _ \[ _ \] _ \t _ \n _ \r _ \
      | _ < _ > _ & _ , _ : _ \; _ \" _ ' _ ` _] $name]
  }
  #_______________________

  proc RestoreArray {arName arSave} {
    # Tries restoring an array 1:1.
    #   arName - fully qualified array name
    #   arSave - saved array's value (got with "array get")
    # At restoring, new items of $arName are deleted and existing items are updated,
    # so that after restoring *array get $arName* is equal to $arSave.
    # Note: "array unset $arName *; array set $arName $arSave" doesn't ensure this equality.

    set ar $arName
    array set artmp $arSave
    set tmp1 [array names artmp]
    set tmp2 [array names $arName]
    foreach n $tmp2 {
      if {$n ni $tmp1} {unset [set ar]($n)} {set [set ar]($n) $artmp($n)}
    }
    foreach n $tmp1 {
      # deleted items can break 1:1 equality (not the case with alited)
      if {$n ni $tmp2} {set [set ar]($n) $artmp($n)}
    }
  }
  #_______________________

  proc EnsureArray {arName args} {
    # Ensures restoring an array at calling a proc.
    #   arName - fully qualified array name
    #   args - proc name & arguments

    set arSave [array get $arName]
    {*}$args
    RestoreArray $arName $arSave
  }
  #_______________________

  proc MouseOnWidget {w1} {
    # Places the mouse pointer on a widget.
    #   w1 - the widget's path

    update
    set w2 [winfo parent $w1]
    set w3 [winfo parent $w2]
    lassign [split [winfo geometry $w1] +x] w h x1 y1
    lassign [split [winfo geometry $w2] +x] - - x2 y2
    event generate $w3 <Motion> -warp 1 \
      -x [expr {$x1+$x2+int($w/2)}] -y [expr {$y1+$y2+int($h/2)}]
  }
  #_______________________

  proc CursorAtEnd {w} {
    # Sets the cursor at the end of a field.
    #   w - the field's path

    focus $w
    $w selection clear
    $w icursor end
  }
  #_______________________

  proc UnixPath {path} {
    # Makes a path "unix-like" to be good for Tcl.
    #   path - the path

    set path [string trim $path "\{\}"]  ;# possibly braced if contains spaces
    set path [string map [list \\ / %H [::apave::HomeDir]] $path]
    return [::apave::checkHomeDir $path]
  }
  #_______________________

  proc PushInList {listName item {pos 0} {max 16}} {
    # Pushes an item in a list: deletes an old instance, inserts a new one.
    #   listName - the list's variable name
    #   item - item to push
    #   pos - position in the list to push in
    #   max - maximum length of the list

    upvar $listName ln
    if {[set i [lsearch -exact $ln $item]]>-1} {
      set ln [lreplace $ln $i $i]
    }
    set ln [linsert $ln $pos $item]
    catch {set ln [lreplace $ln $max end]}
  }
  #_______________________

  proc FocusByForce {foc {cnt 10}} {
    # Focuses a widget.
    #   foc - widget's path

    if {[incr cnt -1]>0} {
      after idle after 5 ::apave::FocusByForce $foc $cnt
    } else {
      catch {focus -force [winfo toplevel $foc]; focus $foc}
    }
  }
  #_______________________

  proc HomeDir {} {
    # For Tcl 9.0 & Windows: gets a home directory ("~").

    if {[catch {set hd [file home]}]} {
      if {[info exists ::env(HOME)]} {set hd $::env(HOME)} {set hd ~}
    }
    return $hd
  }
  #_______________________

  proc checkHomeDir {com} {
    # For Tcl 9.0 & Windows: checks a command for "~".

    set hd [HomeDir]
    set com [string map [list { ~/} " $hd/" \"~/ \"$hd/ '~/ '$hd/ \\n~/ \\n$hd/ \n~/ \n$hd/ \{~/ \{$hd/] $com]
    if {[string match ~/* $com]} {set com $hd[string range $com 1 end]}
    return $com
  }

  #_______________________

  proc FileTail {basepath fullpath} {
    # Extracts a tail path from a full file path.
    # E.g. FileTail /a/b /a/b/cd/ef => cd/ef
    #   basepath - base path
    #   fullpath - full path

    set lbase [file split $basepath]
    set lfull [file split $fullpath]
    set ll [expr {[llength $lfull] - [llength $lbase] - 1}]
    if {$ll>-1} {
      return [file join {*}[lrange $lfull end-$ll end]]
    }
    return {}
  }

  proc FileRelativeTail {basepath fullpath} {
    # Gets a base relative path.
    # E.g. FileRelativeTail /a/b /a/b/cd/ef => ../ef
    #   basepath - base path
    #   fullpath - full path

    set tail [FileTail $basepath $fullpath]
    set lev [llength [file split $tail]]
    set base {}
    for {set i 1} {$i<$lev} {incr i} {append base ../}
    append base [file tail $tail]
  }

  ## ________________________ EONS apave _________________________ ##

}

# ________________________ APave _________________________ #

oo::class create ::apave::APave {

  superclass ::apave::APaveDialog

  variable _savedvv

  constructor {args} {
    # Creates APave object.
    #   win - window's name (path)
    #   args - additional arguments

    set _savedvv [list]
    if {[llength [self next]]} { next {*}$args }
  }

  destructor {
    # Clears variables used in the object.

    my initInput
    unset _savedvv
    if {[llength [self next]]} next
  }
  #_______________________

  method initInput {} {
    # Initializes input and clears variables made in previous session.

    foreach {vn vv} $_savedvv {
      catch {unset $vn}
    }
    set _savedvv [list]
    set Widgetopts [list]
    return
  }
  #_______________________

  method varInput {} {
    # Gets variables made and filled in a previous session
    # as a list of "varname varvalue" pairs where varname
    # is of form: namespace::var$widgetname.

    return $_savedvv
  }
  #_______________________

  method valueInput {} {
    # Gets input variables' values.

    set _values {}
    foreach {vnam -} [my varInput] {
      lappend _values [set $vnam]
    }
    return $_values
  }
  #_______________________

  method input {icon ttl iopts args} {
    # Makes and runs an input dialog.
    #  icon - icon (omitted if equals to "")
    #  ttl - title of window
    #  iopts - list of widgets and their attributes
    #  args - list of dialog's attributes
    # The `iopts` contains lists of three items:
    #   name - name of widgets
    #   prompt - prompt for entering data
    #   valopts - value options
    # The `valopts` is a list specific for a widget's type, however
    # a first item of `valopts` is always an initial input value.

    if {$iopts ne {}} {
      my initInput  ;# clear away all internal vars
    }
    set pady "-pady 2"
    if {[set focusopt [::apave::getOption -focus {*}$args]] ne {}} {
      set focusopt "-focus $focusopt"
    }
    lappend inopts [list fraM + T 1 98 "-st nsew $pady -rw 1"]
    set savedvv [list]
    set frameprev {}
    foreach {name prompt valopts} $iopts {
      if {$name eq {}} continue
      lassign $prompt prompt gopts attrs
      lassign [::apave::extractOptions attrs -method {} -toprev {}] ismeth toprev
      if {[string toupper $name 0] eq $name} {
        set ismeth yes  ;# overcomes the above setting
        set name [string tolower $name 0]
      }
      set ismeth [string is true -strict $ismeth]
      set gopts "$pady $gopts"
      set typ [string tolower [string range $name 0 1]]
      if {$typ eq "v_" || $typ eq "se"} {
        lappend inopts [list fraM.$name - - - - "pack -fill x $gopts"]
        continue
      }
      set tvar "-tvar"
      switch -exact -- $typ {
        ch { set tvar "-var" }
        sp { set gopts "$gopts -expand 0 -side left"}
      }
      set framename fraM.fra$name
      if {$typ in {lb te tb}} {  ;# the widgets sized vertically
        lappend inopts [list $framename - - - - "pack -expand 1 -fill both"]
      } else {
        lappend inopts [list $framename - - - - "pack -fill x"]
      }
      set vv [my varName $name]
      set ff [my FieldName $name]
      set Name [string toupper $name 0]
      if {$ismeth && $typ ni {ra}} {
        # -method option forces making "WidgetName" method from "widgetName"
        my MakeWidgetName $ff $Name -
      }
      if {$typ ne {la} && $toprev eq {}} {
        set takfoc [::apave::parseOptions $attrs -takefocus 1]
        if {$focusopt eq {} && $takfoc} {
          if {$typ in {fi di cl fo da}} {
            set _ en*$name  ;# 'entry-like mega-widgets'
          } elseif {$typ eq "ft"} {
            set _ te*$name  ;# ftx - 'text-like mega-widget'
          } else {
            set _ $name
          }
          set focusopt "-focus $_"
        }
        if {$typ in {lb tb te}} {set anc nw} {set anc w}
        lappend inopts [list fraM.fra$name.labB$name - - - - \
          "pack -side left -anchor $anc -padx 3" \
          "-t \"$prompt\" -font \
          \"-family {[my basicTextFont]} -size [my basicFontSize]\""]
      }
      # for most widgets:
      #   1st item of 'valopts' list is the current value
      #   2nd and the rest of 'valopts' are a list of values
      if {$typ ni {fc te la}} {
        # curr.value can be set with a variable, so 'subst' is applied
        set vsel [lindex $valopts 0]
        catch {set vsel [subst -nocommands -nobackslashes $vsel]}
        set vlist [lrange $valopts 1 end]
      }
      if {[set msgLab [::apave::getOption -msgLab {*}$attrs]] ne {}} {
        set attrs [::apave::removeOptions $attrs -msgLab]
      }
      # define a current widget's info
      switch -exact -- $typ {
        lb - tb {
          set $vv $vlist
          lappend attrs -lvar $vv
          if {$vsel ni {{} -}} {
            lappend attrs -lbxsel "$::apave::UFF$vsel$::apave::UFF"
          }
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill both $gopts" $attrs]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        cb {
          if {![info exist $vv]} {catch {set $vv $vsel}}
          lappend attrs -tvar $vv -values $vlist
          if {$vsel ni {{} -}} {
            lappend attrs -cbxsel $::apave::UFF$vsel$::apave::UFF
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" $attrs]
        }
        fc {
          if {![info exist $vv]} {catch {set $vv {}}}
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" "-tvar $vv -values \{$valopts\} $attrs"]
        }
        op {
          set $vv $vsel
          lappend inopts [list $ff - - - - "pack -fill x $gopts" "$vv $vlist"]
        }
        ra {
          if {![info exist $vv]} {catch {set $vv $vsel}}
          set padx 0
          foreach vo $vlist {
            set name $name
            set FF $ff[incr nnn]
            lappend inopts [list $FF - - - - "pack -side left $gopts -padx $padx" "-var $vv -value \"$vo\" -t \"$vo\" $attrs"]
            if {$ismeth} {
              my MakeWidgetName $FF $Name$nnn -
            }
            set padx [expr {$padx ? 0 : 9}]
          }
        }
        te {
          if {![info exist $vv]} {
            set valopts [string map [list \\n \n \\t \t] $valopts]
            set $vv [string map [list \\\\ \\ \\\} \} \\\{ \{] $valopts]
          }
          if {[dict exist $attrs -state] && [dict get $attrs -state] eq "disabled"} \
          {
            # disabled text widget cannot be filled with a text, so we should
            # compensate this through a home-made attribute (-disabledtext)
            set disattr "-disabledtext \{[set $vv]\}"
          } elseif {[dict exist $attrs -readonly] && [dict get $attrs -readonly] || [dict exist $attrs -ro] && [dict get $attrs -ro]} {
            set disattr "-rotext \{[set $vv]\}"
            set attrs [::apave::removeOptions $attrs -readonly -ro]
          } else {
            set disattr {}
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill both $gopts" "$attrs $disattr"]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        la {
          if {$prompt ne {}} { set prompt "-t \"$prompt\" " } ;# prompt as -text
          lappend inopts [list $ff - - - - "pack -anchor w $gopts" "$prompt$attrs"]
          continue
        }
        bu - bt - ch {
          set prompt {}
          if {$toprev eq {}} {
            lappend inopts [list $ff - - - - \
              "pack -side left -expand 1 -fill both $gopts" "$tvar $vv $attrs"]
          } else {
            lappend inopts [list $frameprev.$name - - - - \
              "pack -side left $gopts" "$tvar $vv $attrs"]
          }
          if {$vv ne {}} {
            if {![info exist $vv]} {
              catch {
                if {$vsel eq {}} {set vsel 0}
                set $vv $vsel
              }
            }
          }
        }
        default {
          if {$vlist ne {}} {lappend attrs -values $vlist}
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill x $gopts" "$tvar $vv $attrs"]
          if {$vv ne {}} {
            if {![info exist $vv]} {catch {set $vv $vsel}}
          }
        }
      }
      if {$msgLab ne {}} {
        lassign $msgLab lab msg attlab
        set lab [my parentWName [lindex $inopts end 0]].$lab
        if {$msg ne {}} {set msg "-t {$msg}"}
        append msg " $attlab"
        lappend inopts [list $lab - - - - "pack -side left -expand 1 -fill x" $msg]
      }
      if {![info exist $vv]} {set $vv {}}
      lappend _savedvv $vv [set $vv]
      set frameprev $framename
    }
    lassign [::apave::parseOptions $args -titleHELP {} -buttons {} -comOK 1 \
      -titleOK OK -titleCANCEL Cancel -centerme {}] \
      titleHELP buttons comOK titleOK titleCANCEL centerme
    if {$titleHELP eq {}} {
      set butHelp {}
    } else {
      lassign $titleHELP title command
      set butHelp [list butHELP $title $command]
    }
    if {$titleCANCEL eq {}} {
      set butCancel {}
    } else {
      set butCancel "butCANCEL $titleCANCEL destroy"
    }
    if {$centerme eq {}} {
      set centerme {-centerme 1}
    } else {
      set centerme "-centerme $centerme"
    }
    set args [::apave::removeOptions $args \
      -titleHELP -buttons -comOK -titleOK -titleCANCEL -centerme -modal]
    lappend args {*}$focusopt
    if {[catch {
      lassign [my PrepArgs {*}$args] args
      set res [my Query $icon $ttl {} \
        "$butHelp $buttons butOK $titleOK $comOK $butCancel" \
        butOK $inopts $args {} {*}$centerme -input yes]} e]
    } then {
      catch {destroy $Dlgpath}  ;# Query's window
      set under \n[string repeat _ 80]\n\n
      ::apave::obj ok err "ERROR" "\n$e$under $inopts$under $args$under $centerme" \
        -t 1 -head "\nAPave error: \n" -hfg red -weight bold -w 80
      return 0
    }
    if {![lindex $res 0]} {  ;# restore old values if OK not chosen
      foreach {vn vv} $_savedvv {
        # tk_optionCascade (destroyed now) was tracing its variable => catch
        catch {set $vn $vv}
      }
    }
    return $res
  }
  #_______________________

  method vieweditFile {fname {prepcom ""} args} {
    # Views or edits a file.
    #   fname - name of file
    #   prepcom - a command performing before and after creating a dialog
    #   args - additional options
    # It's a sort of stub for calling *editfile* method.
    # See also: editfile

    return [my editfile $fname {} {} {} $prepcom {*}$args]
  }
  #_______________________

  method editfile {fname fg bg cc {prepcom ""} args} {
    # Edits or views a file with a set of main colors
    #   fname - name of file
    #   fg - foreground color of text widget
    #   bg - background color of text widget
    #   cc - caret's color of text widget
    #   prepcom - a command performing before and after creating a dialog
    #   args - additional options (`-readonly 1` for viewing the file).
    # If *fg* isn't empty, all three colors are used to color a text.
    # See also:
    # [aplsimple.github.io](https://aplsimple.github.io/en/tcl/pave/index.html)

    if {$fname eq {}} {
      return false
    }
    set newfile 0
    if {[catch {set filetxt [::apave::readTextFile $fname {} yes]}]} {
      return false
    }
    lassign [::apave::parseOptions $args -rotext {} -readonly 1 -ro 1] rotext readonly ro
    lassign [::apave::extractOptions args -buttons {}] buttadd
    set btns {Close 0}  ;# by default 'view' mode
    set oper VIEW
    if {$rotext eq {} && (!$readonly || !$ro)} {
      set btns {Save 1 Close 0}
      set oper EDIT
    }
    if {$fg eq {}} {
      set tclr {}
    } else {
      set tclr "-fg $fg -bg $bg -cc $cc"
    }
    if {$prepcom eq {}} {set aa {}} {set aa [$prepcom filetxt]}
    set res [my misc {} "$oper: $fname" "$filetxt" "$buttadd $btns" \
      TEXT -text 1 -w {100 80} -h 32 {*}$tclr \
      -post $prepcom {*}$aa {*}$args]
    set data [string range $res 2 end]
    if {[set res [string index $res 0]] eq "1"} {
      set data [string range $data [string first " " $data]+1 end]
      set data [string trimright $data]
      set res [::apave::writeTextFile $fname data]
    } elseif {$newfile} {
      file delete $fname
    }
    return $res
  }

# ________________________ EONS _________________________ #

}
# ________________________ EOF _________________________ #
