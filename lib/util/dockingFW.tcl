#! /usr/bin/env tclsh
#############################################################
# Name:     dockingFW.tcl
# Author:   Flame  (wiki.tcl-lang.org/page/Docking+framework)
# Portions: Alex Plotnikov  (aplsimple@gmail.com)
# Date:     Mar 15, 2025
# Brief:    Handles creating paned GUI.
# License:  MIT.
#############################################################

# ______________________ Initialize _______________________ #

package require Tk

namespace eval DockingFramework {

  variable NTAB 10 ;# number of tabs

  variable solo [expr {[info exist ::argv0] && [file normalize $::argv0] eq \
    [file normalize [info script]]} ? 1 : 0]

  variable loaded 0
  variable comAdd {}
}

# If the script runs as stand-alone app, then its arguments are used
# to set the variables:
#
#   ::dockfile - file name for saved file used with docking framework
#   ::apavefile - file name for saved apave file used with apave package
#   ::apavedir - path to apave package
#   ::commands - optional command(s) for $::dockfile (e.g. comments)
#
# If the script is sourced by a script, the variables are set by the latter
# this way:
#   ::dockfile - file name for saved file used with docking framework
#   ::apavefile - -l or -load (means that $::dockfile has to be loaded)
#   ::apavedir - "" (not used)
#   ::commands - "" (not used)
# If these values are arguments of the script as stand-alone app,
# it leads also to loading the saved $::dockfile.

if {$DockingFramework::solo} {
  catch {
    lassign $::argv ::dockfile ::apavefile ::apavedir DockingFramework::comAdd
  }
  wm withdraw .
  catch {ttk::style theme use clam}
  if {![info exist ::dockfile] || $::dockfile eq {}} {
    set ::dockfile dockingFW_test1.tcl
  }
  if {![info exist ::apavefile] || $::apavefile eq {}} {
    set ::apavefile dockingFW_test2.tcl
  }
  if {![info exist ::apavedir] || $::apavedir eq {}} {
    set ::apavedir ../apave
  }
}
if {[info exist ::apavefile] && $::apavefile in {-l -load}} {
  set DockingFramework::loaded 1
}

# ________________________ DockingFramework _________________________ #

namespace eval DockingFramework {

if {!$loaded} {
  bind TNotebook <Button-1> +[namespace code {start_motion %W}]
  bind TNotebook <B1-Motion> +[namespace code {motion %X %Y}]
  bind TNotebook <ButtonRelease-1> +[namespace code {end_motion %X %Y}]
  bind TNotebook <Button-3> +[namespace code {__undock_tab %W}]
}

# tbs(tab_path)=panedwindow
# tbs(panedwindow_path)=parent_panedwindow
# tbs(path,path)=tab_path
variable tbs
variable tbcnt 0

variable c_path {}
variable s_cursor {}

# find notebook, corresponding to path
proc find_tbn {path} {
  variable tbs
  if {$path==""} { return "" }
  set top [winfo toplevel $path]
  while {$path!=$top} {
    if {[info exists tbs($path,path)]} {
      return $tbs($path,path)
    }
    if {[info exists tbs($path)]} {
      return $path
    }
    set path [winfo parent $path]
  }
  return {}
}

proc replace_tbn_with_pw {tbn anchor} {
  variable tbs
  variable tbcnt
  set pw $tbs($tbn)
  if {$tbn!=""} {
    set index [lsearch -exact [$pw panes] $tbn]
  }
  if {$anchor=="w" || $anchor=="e"} {
    set orient "horizontal"
  } else {
    set orient "vertical"
  }
  set npw [ttk::panedwindow [winfo toplevel $pw].pan$tbcnt -orient $orient]
  incr tbcnt
  set tbs($tbn) $npw
  if {$tbn==""} { # toplevel
    set grid_options [grid info $pw]
    grid forget $pw
    eval grid $npw $grid_options
    set tbn $pw
    set tbs($pw) $npw
    set tbs($npw) {}
  } else {
    $pw insert $index $npw -weight 1
    $pw forget $tbn
    set tbs($npw) $pw
  }
  set ntb [ttk::notebook [winfo toplevel $pw].nbk$tbcnt]
  incr tbcnt
  set tbs($ntb) $npw
  if {$anchor=="s" || $anchor=="e"} {
    $npw add $tbn -weight 1
    $npw add $ntb -weight 1
  } else {
    $npw add $ntb -weight 1
    $npw add $tbn -weight 1
  }
  _raise_tree $tbn
  _raise_tree $ntb
  if {[get_class $tbn]=="TPanedwindow"} {
    _cleanup_pws $tbn
  }
  return $ntb
}

proc _raise_tree {path} {
  raise $path
  switch -exact [get_class $path] {
    TPanedwindow {
      foreach pane [$path panes] {
        _raise_tree $pane
      }
    }
    TNotebook {
      foreach tab [$path tabs] {
        raise $tab
      }
    }
  }
}

# add a new notebook to the side anchor of the notebook tbn
proc get_class {path} { return [lindex [bindtags $path] 1] }

proc get_anchor {path x y} {
  variable tbs
  set tb [find_tbn $path]

  set rev {}
  if {$tb==""} {
    set tb $tbs()
    set rev -
  }
  set w [winfo width $tb]
  set h [winfo height $tb]

  set x [expr $x-[winfo rootx $tb]]
  set y [expr $y-[winfo rooty $tb]]

  set in_bbox [expr {(($x>=0 && $y>=0 && $x<=$w && $y<=$h) ? 1 : 0)}]

  if {($rev=="" && !$in_bbox) || ($rev!="" && $in_bbox) || $path==$tb} {
    return {}
  }

  if {[$tb identify [expr $x-[winfo rootx $tb]] [expr $y-[winfo rooty $tb]]]!=""} {
    set anchor "t"
  } elseif {$x>=[expr $w/3] && $x<=[expr $w*2/3] && $y>=[expr $h/3] && $y<=[expr $h*2/3]} {
    set anchor "t"
  } else {
    # determine the closest side to the cursor
    set side 1
    set rdist 1e6
    foreach {x0 y0} {0 0 0 0 $w 0 0 $h} a {w n e s} {
      set dist [expr abs($x-$x0)*$side+abs($y-$y0)*(1-$side)]
      set side [expr 1-$side]
      if {$dist<$rdist} {
        set rdist $dist
        set anchor $a
      }
    }
  }
  set rev {}
  if {$x<0 || $y<0 || $x>$w || $y>$h} {
    set rev -
  }
  array set cursors {
    s bottom_side
    w left_side
    e right_side
    n top_side
    t based_arrow_down
    {} {}
    -s top_side
    -w right_side
    -e left_side
    -n bottom_side
    -t {}
  }
  return [list $anchor $cursors($rev$anchor)]
}

proc _cleanup_pws {pw} {
  variable tbs
  while {$pw!=$tbs() && [$pw panes]==""} {
    destroy $pw
    set npw $tbs($pw)
    unset tbs($pw)
    set pw $npw
  }
}

proc create_framework {path} {
  variable tbs
  variable tbcnt
  set npw [ttk::panedwindow [winfo toplevel $path].pan$tbcnt -orient vertical]
  incr tbcnt
  set tbs($npw) {}
  set tbs() $npw
  grid $npw -in $path -sticky news
  grid columnconfigure $path 0 -weight 1
  grid rowconfigure $path 0 -weight 1
  for {set i 0} {$i<$DockingFramework::NTAB} {incr i} {
    set fra .dFW.frant$i
    if {![winfo exists $fra]} {
      set ntab [ttk::frame $fra]
      add_tab $ntab {} e -text "tab $i"
    }
  }
}

proc show_message {msg} {
  .dFW.bc.lb configure -text $msg -fg #820000
  after 5000 {.dFW.bc.lb configure -text "          "}
}

## ________________________ Motion _________________________ ##

proc start_motion {path} {
  variable c_path
  variable s_cursor
  if {$path!=$c_path} {
    set c_path [find_tbn $path]
    if {$c_path=="" || [get_class $c_path]!="TNotebook" || [llength [$c_path tabs]]==0} {
      set c_path {}
      return
    }
    set s_cursor [$c_path cget -cursor]
  }
}

proc motion {x y} {
  variable c_path
  variable s_cursor
  if {$c_path!=""} {
    set path [winfo containing $x $y]
    if {$path==$c_path} {
      $c_path configure -cursor $s_cursor
    } else {
      $c_path configure -cursor [lindex [get_anchor $path $x $y] 1]
    }
  }
}

proc end_motion {x y} {
  variable c_path
  variable s_cursor
  if {$c_path==""} { return }
  set path [winfo containing $x $y]
  set anchor [lindex [get_anchor $path $x $y] 0]
  $c_path configure -cursor $s_cursor
  set tbn [find_tbn $path]
  if {$anchor!="" && ($tbn!=$c_path || ($path!=$c_path && $anchor!="t"))} {
    if {$anchor=="t"} {
      move_tab $c_path $tbn
    } else {
      move_tab $c_path [add_tbn $tbn $anchor]
    }
  }
  set c_path {}
}

## ________________________ Tabs _________________________ ##

proc add_tbn {tbn anchor} {
  variable tbs
  variable tbcnt

  set pw $tbs($tbn)
  if {$pw==""} {return {}}
  set orient [$pw cget -orient]

  if {$anchor=="t"} {
    if {$tbn!=""} {
      return $tbn
    } else {
      set anchor [expr {$orient=="horizontal" ? "e" : "s"}]
    }
  }

  # if orientation of the uplevel panedwindow is consistent with anchor, just add the pane
  if {   ( $orient=="horizontal" && ($anchor=="w" || $anchor=="e") ) ||
         ( $orient=="vertical" && ($anchor=="n" || $anchor=="s") )      } {
    if {$tbn==""} {
      if {$anchor=="e" || $anchor=="s"} {
        set i [llength [$pw panes]]
      } else {
        set i 0
      }
    } else {
      set i [lsearch -exact [$pw panes] $tbn]
      if {$anchor=="e" || $anchor=="s"} { incr i }
    }
    set tbn [ttk::notebook [winfo toplevel $pw].nbk$tbcnt]
    incr tbcnt
    set tbs($tbn) $pw
    if {$i>=[llength [$pw panes]] || $i<0} {
      $pw add $tbn -weight 1
    } else {
      $pw insert $i $tbn -weight 1
    }
    _raise_tree $tbn
  } else {
    set tbn [replace_tbn_with_pw $tbn $anchor]
  }
  return $tbn
}

proc add_tab {tab path anchor args} {
  variable tbs
  if {$anchor=="t" && $path==""} {
    set anchor "e"
  } elseif {$anchor=="t"} {
    set tbn $tbs($path,path)
  } else {
    set tbn [add_tbn [find_tbn $path] $anchor]
  }
  eval [list $tbn add $tab] $args
  set tbs($tab,path) $tbn
  raise $tab
}

proc move_tab {srctab dsttab} {
  variable tbs
  # move tab
  set f [$srctab select]
  set o [$srctab tab $f]
  $srctab forget $f
  eval $dsttab add $f $o
  raise $f
  $dsttab select $f
  _cleanup_tabs $srctab
  set tbs($f,path) $dsttab
}

proc remove_tab {path} {
  variable tbs
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error "window $path is not managed by the framework"
  }
  catch {$tb forget $path}
  unset tbs($path,path)
  _cleanup_tabs $tb
}

proc select_tab {path} {
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error "window $path is not managed by the framework"
  }
  $tb select $path
}

proc hide_tab {path} {
  variable tbs
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error "window $path is not managed by the framework"
  }
  $tb hide $path
}

proc show_tab {path} {
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error -code "window $path is not managed by the framework"
  }
  $tb add $path
}

proc _cleanup_tabs {srctab} {
  variable tbs
  if {[llength [$srctab tabs]]==0} {
    destroy $srctab
    _cleanup_pws $tbs($srctab)
    unset tbs($srctab)
  }
}

## ________________________ Undock _________________________ ##

proc undock_tab {tab} {
  variable tbs

  set tbn $tbs($tab,path)
  set name [$tbn tab $tab -text]
  set opts [$tbn tab $tab]
  unset tbs($tab,path)
  set tbs($tab,undocked) [list $tbn $opts]

  $tbn forget $tab
  _cleanup_tabs $tbn
}

proc __undock_tab {wnd} {
  set tbn [find_tbn $wnd]
  if {$tbn=="" || [$tbn select]==""} { return }
  undock_tab [$tbn select]
}

## ________________________ Serialize _________________________ ##

proc serialize_widget {path} {
  variable tbs
  variable apavescript
  set class [get_class $path]
  upvar script script
  if {[info exists tbs($path)]} {
    switch $class {
      TNotebook {
        append script "ttk::notebook $path\n"
        lappend apavescript "2. $path"
        foreach tab [$path tabs] {
          serialize_widget $tab
          append script "$path add $tab [$path tab $tab]\n"
          append script "raise $tab\n"
        }
      }
      TPanedwindow {
        set paneopts "$path -orient [$path cget -orient]"
        append script "ttk::panedwindow $paneopts\n"
        lappend apavescript "1. $path $paneopts"
        if {$path==$tbs()} {
          append script "eval grid \$tbs() \$tbs(grid_options)\n"
        }
        set i 0
        foreach pane [$path panes] {
          serialize_widget $pane
          append script "$path add $pane [$path pane $pane]\n"
          incr i
        }
      }
      default {
        error "serialization is not supported for the class $class"
      }
    }
  } else {
    catch {::serialize $path}
  }
}

proc serialize {} {
  variable tbs
  variable tbcnt
  variable apavescript
  variable NTAB
  variable comAdd
  update
  update idletasks
  set top [winfo toplevel $tbs()]
  set script "namespace eval ::DockingFramework \{\n"
  append script "if {\[\$tbs() panes\]!=\"\"} { error \"Trying to overwrite existing layout\" }\n"
  append script "set tbs(grid_options) \[grid info \$tbs()\]\n"
  append script "destroy \$tbs()\n"
  append script "unset tbs(\$tbs())\n"
  append script "array set tbs [list [array get tbs]]\n"
  append script "set tbcnt $tbcnt\n"
  append script "set corrheight [winfo height .dFW.bc] ;# to use in detached mode\n"
  append script "wm geometry $top [wm geometry $top]\n"
  for {set i 0} {$i<$NTAB} {incr i} {
    set fra .dFW.frant$i
    set nbk [find_tbn $fra]
    if {$nbk eq {} || [$nbk select] ne $fra} continue
    set height [winfo height $fra]
    set width [winfo width $fra]
    append script "catch {$fra configure -width $width -height $height}\n"
  }
  set apavescript ""
  serialize_widget $tbs()
  append script "\}\n"
  if {$comAdd ne {}} {
    append script "$comAdd\n"
  }
  return $script
}

## ________________________ Layouts _________________________ ##

proc save_l {} {
  variable layout
  update idletasks
  set layout [serialize]
  set output "# Layout for dockingFW.tcl: \n$layout"
  puts $output
  apave_file $::dockfile $output
  apave_layout
  show_message Saved.
}

proc load_l {{isrep 0}} {
  variable layout
  variable tbs
  if {![info exists layout]} {
    if {[file exists $::dockfile]} {
      get_f
    } else {
      error "Save layout before loading"
    }
  }
  foreach w [array names tbs] {
    catch {destroy $w}
  }
  array set tbs {}
  create_framework .dFW.df
  eval $layout
  if {$isrep} {
    # 1st cycle resets window's geometry, 2nd resets layout
    after 10 after idle \
      "DockingFramework::load_l; DockingFramework::show_message Loaded."
  }
}

proc get_f {} {
  variable layout
  set chan [open $::dockfile]
  chan configure $chan -encoding utf-8
  set layout [read $chan]
  close $chan
}

proc load_f {} {
  variable layout
  get_f
  # correct window geometry by toolbar height
  set llist [split $layout \n]
  foreach ll1 $llist {
    incr i
    if {[string match "set corrheight *" $ll1]} {
      set ll2 [lindex $llist $i]
      if {[string match "wm geometry*" $ll2]} {
        lassign [split $ll1] - - ch
        lassign [split $ll2] - - top geom2
        lassign [split $geom2 x+] w2 h2 x2 y2
        if {[string is digit -strict $ch] && [string is digit -strict $h2]} {
          incr h2 -$ch
          set ll2 "wm geometry $top ${w2}x$h2+$x2+$y2"
          set llist [lreplace $llist $i $i $ll2]
          set layout {}
          foreach ll1 $llist {append layout $ll1\n}
        }
        break
      }
    }
  }
  load_l
}
#_______________________

proc get_attrs {path} {
  # Gets attributes of widget.
  #   pat - widget's path

  set attrs {}
  catch {
    foreach attr [$path configure] {
      lassign $attr att
      if {[set val [$path cget $att]] ne {}} {
        switch -- $att {
          -width  {set val [winfo width $path];  set att -w}
          -height {set val [winfo height $path]; set att -h}
        }
        append attrs " $att " [list $val]
      }
    }
  }
  return [string trim $attrs]
}
#_______________________

proc apave_layout {} {
  # Gets apave layout.

  variable apavescript
  set script $apavescript
  set output [list]
  update idletasks
  foreach ls $script {
    incr ils
    lassign [string range $ls 3 end] path
    set attrs [get_attrs $path]
    set apath [string range $path 5 end] ;# get rid of .dFW.
    switch [string range $ls 0 1] {
      1. {  ;# ttk::panedwindow
        set opts [grid info $path]
        if {[set i [lsearch $opts -in]]>=0} {
          set opts [lrange $opts $i+2 end]
        }
        if {![llength $output]} {
          lappend opts -cw 1 -rw 1
          lappend output [list $apath - - - - $opts [string trim $attrs]]
          set attrs [list]
        }
        foreach pane [$path panes] {
          set apane [winfo name $pane]
          if {[string match pan* $apane]} {
            set attrs [get_attrs $pane]
          } else {
            set attrs {}
          }
          set i 0
          set path1 [winfo parent $pane]
          foreach out $output {
            lassign $out path2
            if {[string match *.$apath $path2]} {  ;# searching its parent
              set apath $path2
              break
            }
            incr i
          }
          lappend output [list $apath.$apane - - - - add $attrs]
        }
      }
      2. {  ;# ttk::notebook
        set Attrs [list]
        set nt [winfo name $path]
        foreach fra [$path tabs] {
          set nbk [find_tbn $fra]
          if {$nbk eq {} || [$nbk select] ne $fra} {
            set att {}
          } else {
            set att [get_attrs $fra]
          }
          set tab [winfo name $fra]
          lappend Attrs $tab [list -t "tab [string range $tab 5 end]" -Attrs \
            [list {*}$att]] -traverse 1
          set i 0
          foreach out $output {
            lassign $out apath - - - - add
            if {[string match *$nt $apath]} {
              set output [lreplace $output $i $i [list $apath - - - - $add $Attrs]]
              break
            }
            incr i
          }
        }
      }
      default {continue}
    }
  }
  set apaveout \
{#! /usr/bin/env tclsh
# Layout for apave package, prepared by dockingFW.tcl.
}
  append apaveout {source } [file join $::apavedir apave.tcl]\n
  append apaveout {wm withdraw .
catch {ttk::style theme use clam}
set pobj ::apave::pavedObj1
set win .temp
::apave::APave create $pobj $win
$pobj makeWindow $win.fra {apave Layout}
$pobj paveWindow $win.fra }
  append apaveout \{\n
  foreach out $output {
    append apaveout "    [list $out]\n"
  }
  append apaveout \}\n
  lassign [split [wm geometry .dFW] x+] w h x y
  set ch [winfo height .dFW.bc]
  incr h -$ch
  append apaveout {$pobj showModal $win -escape 1 -onclose destroy -geometry } \
    ${w}x$h+$x+$y\n
  append apaveout \
{catch {destroy $win}
$pobj destroy
exit}
  apave_file $::apavefile $apaveout
}
#_______________________

proc apave_file {fname fcont} {
  # Saves file's contents.
  #   fname - file name
  #   fcont - file contents

  catch {file mkdir [file dirname $fname]}
  set chan [open $fname w]
  chan configure $chan -encoding utf-8
  puts $chan [string trim $fcont]
  close $chan
  puts "\nLayout saved to [file normalize $fname]"
}
#_______________________

proc help {} {

  set helpmsg {
Drag tabs from one notebook
to another, or place tabs aside
the existing notebook.

For this, click a tab's title
with the left mouse button
and move the tab to
left / right/ top / bottom
of a tab or the whole window.

To remove a tab, click its title
with the right mouse button.
_________________________________
}
  append helpmsg "\n\
Clicking \"Save\" button will\n\
save the current layout to\n\n\
$::dockfile\n\n\
$::apavefile"
  tk_messageBox -title Help -message $helpmsg -parent .dFW
}

## ________________________ EONS _________________________ ##
}

# ________________________ Main program / window _________________________ #

catch {toplevel .dFW}
wm title .dFW {Docking Framework}
pack [ttk::panedwindow .dFW.nbc -orient vertical -height 200] -fill both -expand true
ttk::frame .dFW.df
ttk::frame .dFW.bc
.dFW.nbc add .dFW.df -weight 99
.dFW.nbc add .dFW.bc

DockingFramework::create_framework .dFW.df

if {$DockingFramework::loaded} {
  wm title .dFW {DFW Layout}
  DockingFramework::load_f
} else {
  pack [button .dFW.bc.sl -text " Save layout " \
    -command DockingFramework::save_l] -side left -padx 4 -pady 4
  pack [button .dFW.bc.ll -text " Load layout " \
    -command {DockingFramework::load_l 2}] -side left -padx 4 -pady 4
  pack [label  .dFW.bc.lb -text "          "] -side left -fill x -expand 1
  pack [button .dFW.bc.hl -text " Help " \
    -command DockingFramework::help] -side left -padx 4 -pady 4
  pack [button .dFW.bc.qq -text " Quit " \
    -command exit] -side right -padx 4 -pady 4
}
wm protocol .dFW WM_DELETE_WINDOW exit

# After "source this-script", there follow user commands.
# ________________________ EOF _________________________ #
