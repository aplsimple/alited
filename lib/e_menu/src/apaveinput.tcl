###########################################################
# Name:    apaveinput.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    12/09/2021
# Brief:   Handles APaveInput class creating input dialogs.
# License: MIT.
###########################################################

package require Tk

package provide apave 3.4.12

source [file join [file dirname [info script]] apavedialog.tcl]

namespace eval ::apave {
}

# ________________________ APaveInput _________________________ #

oo::class create ::apave::APaveInput {

  superclass ::apave::APaveDialog

  variable _pav
  variable _pdg
  variable _savedvv

  constructor {args} {
    # Creates APaveInput object.
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
    set _pav(widgetopts) [list]
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
    #
    # The `iopts` contains lists of three items:
    #   name - name of widgets
    #   prompt - prompt for entering data
    #   valopts - value options
    #
    # The `valopts` is a list specific for a widget's type, however
    # a first item of `valopts` is always an initial input value.

    if {$iopts ne {}} {
      my initInput  ;# clear away all internal vars
    }
    set pady "-pady 2"
    if {[set focusopt [::apave::getOption -focus {*}$args]] ne ""} {
      set focusopt "-focus $focusopt"
    }
    lappend inopts [list fraM + T 1 98 "-st nsew $pady -rw 1"]
    set savedvv [list]
    set frameprev ""
    foreach {name prompt valopts} $iopts {
      if {$name eq ""} continue
      lassign $prompt prompt gopts attrs
      set gopts "$pady $gopts"
      set typ [string tolower [string range $name 0 1]]
      if {$typ eq "v_" || $typ eq "se"} {
        lappend inopts [list fraM.$name - - - - "pack -fill x $gopts"]
        continue
      }
      set toprev [::apave::getOption -toprev {*}$attrs]
      set attrs [::apave::removeOptions $attrs -toprev]
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
      set vv [my VarName $name]
      set ff [my FieldName $name]
      if {$typ ne "la" && $toprev eq ""} {
        set takfoc [::apave::parseOptions $attrs -takefocus 1]
        if {$focusopt eq "" && $takfoc} {
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
      if {[set msgLab [::apave::getOption -msgLab {*}$attrs]] ne ""} {
        set attrs [::apave::removeOptions $attrs -msgLab]
      }
      # define a current widget's info
      switch -exact -- $typ {
        lb - tb {
          set $vv $vlist
          lappend attrs -lvar $vv
          if {$vsel ni {"" "-"}} {
            lappend attrs -lbxsel "$::apave::UFF$vsel$::apave::UFF"
          }
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill both $gopts" $attrs]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        cb {
          if {![info exist $vv]} {catch {set $vv ""}}
          lappend attrs -tvar $vv -values $vlist
          if {$vsel ni {"" "-"}} {
            lappend attrs -cbxsel "$::apave::UFF$vsel$::apave::UFF"
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" $attrs]
        }
        fc {
          if {![info exist $vv]} {catch {set $vv ""}}
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
            lappend inopts [list $ff[incr nnn] - - - - "pack -side left $gopts -padx $padx" "-var $vv -value \"$vo\" -t \"$vo\" $attrs"]
            set padx [expr {$padx ? 0 : 9}]
          }
        }
        te {
          if {![info exist $vv]} {set $vv [string map {\\n \n \\t \t} $valopts]}
          if {[dict exist $attrs -state] && [dict get $attrs -state] eq "disabled"} \
          {
            # disabled text widget cannot be filled with a text, so we should
            # compensate this through a home-made attribute (-disabledtext)
            set disattr "-disabledtext \{[set $vv]\}"
          } elseif {[dict exist $attrs -readonly] && [dict get $attrs -readonly] || [dict exist $attrs -ro] && [dict get $attrs -ro]} {
            set disattr "-rotext \{[set $vv]\}"
            set attrs [::apave::removeOptions $attrs -readonly -ro]
          } else {
            set disattr ""
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill both $gopts" "$attrs $disattr"]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        la {
          if {$prompt ne ""} { set prompt "-t \"$prompt\" " } ;# prompt as -text
          lappend inopts [list $ff - - - - "pack -anchor w $gopts" "$prompt$attrs"]
          continue
        }
        bu - ch {
          set prompt ""
          if {$toprev eq ""} {
            lappend inopts [list $ff - - - - \
              "pack -side left -expand 1 -fill both $gopts" "$tvar $vv $attrs"]
          } else {
            lappend inopts [list $frameprev.$name - - - - \
              "pack -side left $gopts" "$tvar $vv $attrs"]
          }
          if {$vv ne ""} {
            if {![info exist $vv]} {
              catch {
                if {$vsel eq ""} {set vsel 0}
                set $vv $vsel
              }
            }
          }
        }
        default {
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill x $gopts" "$tvar $vv $attrs"]
          if {$vv ne ""} {
            if {![info exist $vv]} {catch {set $vv $vsel}}
          }
        }
      }
      if {$msgLab ne ""} {
        lassign $msgLab lab msg
        set lab [my parentWName [lindex $inopts end 0]].$lab
        if {$msg ne ""} {set msg "-t {$msg}"}
        lappend inopts [list $lab - - - - "pack -side left -expand 1 -fill x" $msg]
      }
      if {![info exist $vv]} {set $vv ""}
      lappend _savedvv $vv [set $vv]
      set frameprev $framename
    }
    lassign [::apave::parseOptions $args -titleOK OK -titleCANCEL Cancel \
      -centerme ""] titleOK titleCANCEL centerme
    if {$titleCANCEL eq ""} {
      set butCancel ""
    } else {
      set butCancel "butCANCEL $titleCANCEL 0"
    }
    if {$centerme eq ""} {
      set centerme "-centerme 1"
    } else {
      set centerme "-centerme $centerme"
    }
    set args [::apave::removeOptions $args -titleOK -titleCANCEL -centerme]
    lappend args {*}$focusopt
    if {[catch { \
    set res [my Query $icon $ttl {} "butOK $titleOK 1 $butCancel" butOK \
    $inopts [my PrepArgs $args] "" {*}$centerme]} e]} {
      catch {destroy $_pdg(dlg)}  ;# Query's window
      ::apave::obj ok err "ERROR" "\n$e\n" \
        -t 1 -head "\nAPaveInput returned an error: \n" -hfg red -weight bold
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

  method vieweditFile {fname {prepost ""} args} {
    # Views or edits a file.
    #   fname - name of file
    #   prepost - a command performing before and after creating a dialog
    #   args - additional options
    # It's a sort of stub for calling *editfile* method.
    # See also: editfile

    return [my editfile $fname "" "" "" $prepost {*}$args]
  }
  #_______________________

  method editfile {fname fg bg cc {prepost ""} args} {
    # Edits or views a file with a set of main colors
    #   fname - name of file
    #   fg - foreground color of text widget
    #   bg - background color of text widget
    #   cc - caret's color of text widget
    #   prepost - a command performing before and after creating a dialog
    #   args - additional options (`-readonly 1` for viewing the file).
    #
    # If *fg* isn't empty, all three colors are used to color a text.
    #
    # See also:
    # [aplsimple.github.io](https://aplsimple.github.io/en/tcl/pave/index.html)

    if {$fname eq ""} {
      return false
    }
    set newfile 0
    if {[catch {set filetxt [::apave::readTextFile $fname "" yes]}]} {
      return false
    }
    lassign [::apave::parseOptions $args -rotext "" -readonly 1 -ro 1] \
      rotext readonly ro
    set btns "Exit 0"  ;# by default 'view' mode
    set oper VIEW
    if {$rotext eq "" || !$readonly || !$ro} {
      set btns "Save 1 Cancel 0"
      set oper EDIT
    }
    if {$fg eq ""} {
      set tclr ""
    } else {
      set tclr "-fg $fg -bg $bg -cc $cc"
    }
    if {$prepost eq ""} {set aa ""} {set aa [$prepost filetxt]}
    set res [my misc "" "$oper FILE: $fname" "$filetxt" $btns \
      TEXT -text 1 -w {100 80} -h 32 {*}$tclr \
      -post $prepost {*}$aa {*}$args]
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
# _________________________________ EOF _________________________________ #
#RUNF1: ~/PG/github/pave/tests/test_pavedialog.tcl
