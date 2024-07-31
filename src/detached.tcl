#! /usr/bin/env tclsh
###########################################################
# Name:    detached.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jul 10, 2024
# Brief:   Handles file detachments.
# License: MIT.
###########################################################

# _________________________ detached ________________________ #

namespace eval detached {
  variable varFind {}
}
#_______________________

proc detached::Options {} {
  # Gets options of new detached editor.
  # Returns a list of index, apave object name, window path, geometry.
  # The geometry is of some previously used window or "".

  while {[incr id]<99} {
    lassign [alited::file::DetachedInfo $id] pobj win
    if {![info exists $pobj]} {
      set geo {}  ;# vacant yet
    } elseif {![winfo exists $win]} {
      set geo [::apave::checkGeometry [set $pobj]] ;# was used
    } else {
      continue
    }
    return [list $id $pobj $win $geo]
  }
  alited::Balloon "Too many requests for detachments!"
  return {}
}
#_______________________

proc detached::Tool {pobj tool} {
  # Applies tool to text.
  #   pobj - apave object of detached editor
  #   tool - tool of toolbar

  event generate [$pobj Text] <<[string totitle $tool]>>
}
#_______________________

proc detached::Find {pobj wtxt {donext 0}} {
  # Finds string in text.
  #   pobj - apave object of detached editor
  #   wtxt - text's path
  #   donext - "1" means 'from a current position'

  variable varFind
  set cbx [$pobj CbxFind]
  if {[set varFind [$cbx get]] ne {}} {
    $pobj findInText $donext $wtxt ::alited::detached::varFind
    set values [$cbx cget -values]
    if {$varFind ni $values} {
      $cbx configure -values [linsert $values 0 $varFind]
    }
  }
  focus [$pobj Text]
}
#_______________________

proc detached::DisplayText {pobj fname} {
  # Displays file's text.
  #   pobj - apave object of detached editor
  #   fname - file name

  $pobj displayText [$pobj Text] [readTextFile $fname]
}
#_______________________

proc detached::Modified {pobj win wtxt args} {
  # Callback for modifying text.
  #   pobj - apave object of detached editor
  #   win - window's path
  #   wtxt - text's path

  catch {
    set ttl [string trimleft [wm title $win] *]
    if {[$wtxt edit modified]} {
      set ttl *$ttl
      set state normal
    } else {
      set state disabled
    }
    wm title $win $ttl
    [$pobj ToolTop].buT_alimg_SaveFile configure -state $state
    foreach do {undo redo} {
      if {[$wtxt edit can$do]} {set state normal} else {set state disabled}
      [$pobj ToolTop].buT_alimg_$do configure -state $state
    }

  }
}
#_______________________

proc detached::SaveFile {pobj fname win} {
  # Saves changed text.
  #   pobj - apave object of detached editor
  #   fname - file name
  #   win - window's path

  set wtxt [$pobj Text]
  if {[alited::file::SaveText $wtxt $fname]} {
    $wtxt edit modified no
    alited::detached::Modified $pobj $win $wtxt
  }
}
#_______________________

proc detached::Close {id pobj win fname args} {
  # Closes detached editor.
  #   id - editor's index
  #   pobj - apave object
  #   win - editor's window
  #   fname - file name

  if {$id<=8} {
    # save only first ones' geometry (avoiding fat history)
    set $pobj [wm geometry $win]
  }
  set wtxt [$pobj Text]
  if {[$wtxt edit modified]} {
    set msg [msgcat::mc {Save changes made to the text?}]
    switch [alited::msg yesnocancel warn $msg {} -centerme $win] {
      1 {SaveFile $pobj $fname $win}
      2 {}
      default {return}
    }
  }
  catch {destroy $win}
  $pobj destroy
  alited::ini::SaveIni
}
#_______________________

proc detached::_create {fname} {
  # Handles detached editor.
  #   fname - edited file's name

  namespace upvar ::alited al al
  lassign [Options] id pobj win geo
  if {$id eq {}} return
  if {![file isfile $fname]} {
    alited::Balloon1 $fname
    return
  }
  set $pobj $geo
  if {$geo ne {}} {set geo "-geometry $geo"}
  set al(detachtools) {}
  foreach icon {SaveFile undo redo cut copy paste} {
    set img [alited::ini::CreateIcon $icon]
    append al(detachtools) " $img \{{} "
    switch $icon {
      SaveFile {
        append al(detachtools) \
          "-com {alited::detached::SaveFile $pobj $fname $win} -state disabled"
        set tip $::alited::al(MC,ico$icon)
      }
      undo - redo - cut - copy - paste {
        append al(detachtools) "-com {alited::detached::Tool $pobj $icon}"
        if {$icon in {undo redo}} {append al(detachtools) " -state disabled"}
        set tip [string totitle $icon]
      }
    }
    append al(detachtools) " -tip {$tip@@ -under 4}\}"
    if {$icon in {SaveFile redo}} {
      append al(detachtools) " sev 6"
    }
  }
  append al(detachtools) " sev 16 lab1 {{Find: }} CbxFind {-font {$::apave::FONTMAIN}}"
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra $fname
  $pobj paveWindow $win.fra {
    {fra1 - - 1 1 {-st nsew -rw 1 -cw 1}}
    {.ToolTop - - - - {pack -side top -fill x} {-array {$::alited::al(detachtools)} -relief groove -borderwidth 1}}
    {.GutText - - - - {pack -side left -expand 0 -fill both}}
    {.FrAText - - - - {pack -side left -expand 1 -fill both \
      -padx 0 -pady 0 -ipadx 0 -ipady 0} {-background $::apave::BGMAIN2}}
    {.frAText.Text - - - - {pack -expand 1 -fill both} \
      {-w 50 -h 20 -gutter GutText -gutterwidth $al(ED,gutterwidth) \
      -guttershift $al(ED,guttershift)}}
    {.sbv + L - - {pack -side right -fill y}}
  }
  set wtxt [$pobj Text]
  set cbx [$pobj CbxFind]
  foreach ev {Return KP_Enter F3} {
    bind $cbx <$ev> "alited::detached::Find $pobj $wtxt"
  }
  foreach ev {f F} {bind $wtxt <Control-$ev> "focus $cbx"}
  bind $wtxt <F3> "alited::detached::Find $pobj $wtxt 1"
  foreach ev [alited::pref::BindKey2 0 -] {
    bind $win <$ev> "alited::detached::SaveFile $pobj $fname $win"
  }
  if {$al(fontdetach)} {set fsz $al(FONTSIZE,std)} {set fsz {}}
  after 50 after idle "$pobj fillGutter $wtxt;\
    alited::file::MakeThemHighlighted {} $wtxt;\
    alited::detached::DisplayText $pobj {$fname};\
    alited::main::HighlightText {} {$fname} $wtxt {alited::detached::Modified $pobj $win} {} $fsz;\
    "
  $pobj showModal $win -modal no -waitvar no -resizable 1 -minsize {300 200} \
    -onclose "alited::detached::Close $id $pobj $win {$fname}" -focus $wtxt {*}$geo
  after [expr {300+($id%9)*100}] after idle "$pobj fillGutter $wtxt" ;# for sure
}
#_______________________

proc detached::_run {fnames} {
  # Open files in detached editors.
  #   fnames - file name list

  foreach fn $fnames {
    _create $fn
  }
}
