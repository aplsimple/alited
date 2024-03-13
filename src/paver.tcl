#! /usr/bin/env tclsh
###########################################################
# Name:    paver.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 28, 2023
# Brief:   Handles the Paver tool.
# License: MIT.
###########################################################

# _________________________ paver ________________________ #

namespace eval paver {
  variable win $::alited::al(WIN).paverwin
  variable win2 {}
  variable pobj ::alited::paver::pavedobj
  variable widgetlist {} paverttl {} paverTID {} geometry {}
  variable code {} modtime {} viewgeo {}
  variable viewpos 1.0
}
#_______________________

proc paver::Close {args} {
  # Closes paver's window.

  variable pobj
  variable win
  variable geometry
  catch {
    set geo [wm geometry $win]
    set geo [string range $geo [string first + $geo] end]
    if {$geo ne {+0+0}} {set geometry $geo}
  }
  catch {$pobj res $win 0}
  catch {destroy $win}
}
#_______________________

proc paver::Destroy {args} {
  # Destroys paver's window.

  variable pobj
  variable win
  Close
  catch {$pobj destroy}
}
#_______________________

proc paver::Help {args} {
  # Handles hitting Help button.

  namespace upvar ::alited al al
  alited::Help $al(WIN) {} -w 80 -minsize {200 100} -resizable 1
}

# ________________________ Function _________________________ #

proc paver::AutoUpdate {{dorun 0}} {
  # Auto-updates the paver.
  #   dorun - if 1, runs the paver

  namespace upvar ::alited al al
  variable pobj
  variable win
  variable paverTID
  variable modtime
  set fname [alited::bar::FileName]
  if {!$al(paverauto)} return
  if {!$dorun && [winfo exists $win]} {
    ::apave::deiconify $::alited::paver::win
    after idle alited::paver::_run
  }
  if {[file exists $fname]} {
    set TID [alited::bar::CurrentTabID]
    if {$TID eq $paverTID && [set dt [file mtime $fname]] ne $modtime} {
      set modtime $dt
      if {$dorun==1} {after idle alited::paver::_run}
      after 500 {after idle alited::main::FocusText}
    }
  }
  after 300 {::alited::paver::AutoUpdate 1}
}
#_______________________

proc paver::Viewer {} {
  # Shows the widget list.

  namespace upvar ::alited al al obDl2 obDl2
  variable paverttl
  variable code
  variable geometry
  variable viewgeo
  variable viewpos
  variable win2
  WidgetList
  if {$code eq {}} {
    MessageNotList
    return
  }
  catch {destroy $win2}
  if {$viewgeo ne {}} {
    set geo "-geometry $viewgeo"
  } else {
    set geo -geometry\ +[winfo vrootx $al(WIN)]+[winfo vrooty $al(WIN)]
  }
  after idle "catch { \
    set txt \[$obDl2 TexM\] ; \
    ::hl_tcl::hl_init \$txt -dark [$obDl2 csDark] -colors {[alited::SyntaxColors]} \
      -cmdpos ::apave::None -font {$al(FONT,txt)} ; \
    ::hl_tcl::hl_text \$txt}"
  after idle "set ::alited::paver::win2 \[$obDl2 dlgPath\]"
  $obDl2 misc info $paverttl $code \
    {OK ::alited::paver::HandleViewer Close ::alited::paver::ExitViewer} TEXT \
    -modal no -waitvar 1 -text 1 -savetext 0 -ro 0 -rotext ::alited::paver::code \
    -minsize {300 200} -w {40 80} -h {5 20} -resizable 1 -pos $viewpos {*}$geo
   catch {destroy $win2}
}
#_______________________

proc paver::HandleViewer {{act 1} args} {
  # Handles viewer's save/close actions.
  #   act - if 1, saves a code and updates the paver's window; if 0 closes the viewer

  namespace upvar ::alited obDl2 obDl2
  variable win2
  variable viewpos
  variable code
  variable viewgeo
  catch {
    set viewgeo [wm geometry $win2]
    if {$act} {
      set tex [$obDl2 TexM]
      set code [string trim [$tex get 1.0 end]]\n
      set viewpos [$tex index insert]
      after idle [list alited::paver::_create $code]
      after idle [list after 100 [list ::apave::FocusByForce $tex]]
    } else {
      $obDl2 res $win2 0
      destroy $win2
    }
  }
}
#_______________________

proc paver::ExitViewer {args} {
  # Closes the viewer.

  HandleViewer 0
}
#_______________________

proc paver::WidgetList {} {
  # Finds and gets a paveWindow's widget list from a current text.

  variable widgetlist
  variable paverttl
  variable paverTID
  variable code
  set code {}
  # 1st attempt: search the widget list in a current unit (by default)
  lassign [alited::tree::CurrentItemByLine {} 1] - - leaf - paverttl l1 l2
  set wtxt [alited::main::CurrentWTXT]
  set lcur [expr {int([$wtxt index insert])}]
  set lend [expr {int([$wtxt index end])}]
  # 2nd attempt: search the widget list edged by "# paver" comments (by force)
  set RE {^\s*#\s*paver}
  for {set l $lcur} {$l>0} {incr l -1} {
    set line [$wtxt get $l.0 $l.end]
    if {[regexp -nocase $RE $line] || [string match {* paveWindow *} $line]} {
      set l1 [incr l -1]
      set l2 $lend
      break
    }
  }
  for {set l $lcur} {$l<=$lend} {} {
    incr l
    set line [$wtxt get $l.0 $l.end]
    if {[regexp -nocase $RE $line]} {
      set l2 $l
      break
    }
  }
  if {$l1>=$l2} {return {}}
  set paverTID [alited::bar::CurrentTabID]
  set widgetlist [set com {}]
  for {set l [incr l1]} {$l<=$l2} {incr l} {
    set line [$wtxt get $l.0 $l.end]
    set line [string trimright $line " \\"]
    # search by completeness of a command the cursor is in
    append com $line \n
    if {[info complete $com]} {
      if {$l>=$lcur} {
        set widgetlist $com
        break
      }
      set com {}
    }
  }
  set widgetlist [string trim $widgetlist]
  set i1 [string first \{ $widgetlist]
  set i2 [string first \[list $widgetlist]
  if {$i1>-1 && $i2>-1 && $i1<$i2 || $i2<0} {
    set i $i1
    if {$i<0} {set i 9999999}
  } else {
    set i $i2
    if {$i<0} {set i 9999999} {incr i 5}
  }
  set widgetlist [string trim [string range $widgetlist [incr i] end-1]]
  catch {
    set wlist [list]
    foreach widitem $widgetlist {
#!      catch #\{set widitem [subst -nobackslashes -nocommands $widitem]#\}
      lappend wlist $widitem
    }
    set widgetlist $wlist
  }
  set widgetlist [string map [list "\[list " "\{" "\]" "\}" "\[" "\{" "\$" ""] $widgetlist]
  set wlist [list]
  foreach widitem $widgetlist {
    lassign $widitem wid nei pos rspan cspan gridpack attrs
    switch -glob $wid {
      {#*} - {after} - {} continue
    }
    lassign [CheckCommentedOptions $gridpack $attrs] gridpack attrs
    if {[lindex $gridpack 0] eq {pack}} {
      if {[lindex $gridpack 1] eq {forget}} {set i 2} {set i 1}
      set opts [lrange $gridpack $i end]
      foreach opt {-in} {
        lassign [::apave::extractOptions opts $opt {}] val
        if {$val ne {} && [string first . $val]==0} {
          lappend opts $opt $val
        }
      }
      set gridpack [lrange $gridpack 0 $i-1]
      lappend gridpack {*}$opts
    }
    foreach opt {-validate -validatecommand -foreground -background -fg -bg -from -to \
    -variable -textvariable -listvariable -command -var -tvar -lvar -com -array -afteridle \
    -ALL} {
      ::apave::extractOptions attrs $opt {}
    }
    set font [::apave::extractOptions attrs -font {}]
    if {$font ne "{}" && ![catch {font actual $font}]} {
      append attrs " -font $font"
    }
    set style [::apave::extractOptions attrs -style {}]
    if {![catch {set _ [ttk::style configure $style]}] && $_ ne {}} {
      append attrs " -style $style"
    }
    set attrs [RemoveVarOptions $attrs]
    set attrs2 [list]
    foreach {opt val} $attrs {
      set val [RemoveVarOptions $val]
      if {[llength $val]%2} {
        lappend attrs2 $opt $val
        continue
      }
      set val2 [list]
      foreach {o v} $val {
        set v [RemoveVarOptions $v]
        if {$v eq {}} continue
        lappend val2 $o $v
      }
      if {$val2 eq {}} continue
      lappend attrs2 $opt $val2
    }
    set attrs $attrs2
    set widitem [list $wid $nei $pos $rspan $cspan $gridpack $attrs]
    lappend wlist $widitem
    append code [list $widitem] \n
  }
  set widgetlist $wlist
}
#_______________________

proc paver::RemoveVarOptions {attrs} {
  # Removes some options with variable values.
  #   attrs - list of options/value pairs

  if {[llength $attrs]%2} {return $attrs}
  set wasvar 0
  set attrsorig $attrs
  foreach opt {-w -h -width -height} {
    lassign [::apave::extractOptions attrs $opt {}] val
    if {$val ne {}} {
      if {[string is integer -strict $val]} {
        lappend attrs $opt $val
      }
      set wasvar 1
    }
  }
  if {!$wasvar} {
    return $attrsorig
  }
  return $attrs
}
#_______________________

proc paver::CheckCommentedOptions {gridpack attrs} {
  # Checks for commented options of gridpack & attrs of widget list item
  #   gridpack - grid/pack item of widget list item
  #   attrs - attrs item of widget list item

  foreach vl {gridpack attrs} {
    # gridpack & attrs lists: check both for items commented, e.g. #-side left...
    # (not implemented in APave for the sake of performance)
    set lst [set $vl]
    if {[set i [lsearch -glob $lst #*]]>-1} {
      set $vl [lreplace $lst $i end]
    }
  }
  return [list $gridpack $attrs]
}
#_______________________

proc paver::MessageNotList {} {
  # Show a message about absent widget list.

  set msg {For paveWindow's widget list to be recognized, set the cursor inside it.}
  alited::Message [msgcat::mc $msg] 4
}

# ________________________ GUI _________________________ #

proc paver::_create {{inplist ""}} {
  # Creates and shows the paver's window.
  #   inplist - widget list to handle

  variable pobj
  variable win
  variable paverttl
  variable geometry
  variable widgetlist
  if {$inplist ne {}} {
    set widgetlist [list]
    foreach widitem $inplist {
      lassign $widitem wid nei pos rspan cspan gridpack attrs
      lassign [CheckCommentedOptions $gridpack $attrs] gridpack attrs
      if {[string index $wid 0] ne {#}} {
        lappend widgetlist [list $wid $nei $pos $rspan $cspan $gridpack $attrs]
      }
    }
  }
  Destroy
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra $paverttl
  $pobj paveWindow $win.fra $widgetlist
  if {$geometry ne {}} {set geo "-geometry $geometry"} {set geo {}}
  after 300 {::alited::paver::AutoUpdate 2}
  set res [$pobj showModal $win -modal no -waitvar 1 -resizable 1 -minsize {50 50} \
    -escape 1 -onclose ::alited::paver::Close {*}$geo]
  Destroy
}
#_______________________

proc paver::_run {} {
  # Runs the paver.

  variable widgetlist
  variable viewpos
  WidgetList
  if {$widgetlist eq {}} {
    MessageNotList
  } else {
    set viewpos 1.0
    _create
  }
}

# ________________________ EOF _________________________ #
