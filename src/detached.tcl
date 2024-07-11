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

  namespace upvar ::alited al al
  while {[incr i]<999} {
    incr id
    set pobj ::alited::al(detachedObj,$id,)
    set win $al(WIN).detachedWin$id
    set geo {}
    if {![info exists $pobj]} {
      # vacant yet
    } elseif {![winfo exists $win]} {
      set geo [::apave::checkGeometry [set $pobj]]
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

proc detached::Modified {pobj wtxt args} {
  # Callback for modifying text.
  #   pobj - apave object of detached editor
  #   wtxt - text's path

  catch {
    if {[$wtxt edit modified]} {set state normal} {set state disabled}
    [$pobj ToolTop].buT_alimg_SaveFile configure -state $state
  }
}
#_______________________

proc detached::SaveFile {pobj fname} {
  # Saves changed text.
  #   pobj - apave object of detached editor
  #   fname - file name

  set wtxt [$pobj Text]
  if {[alited::file::SaveText $wtxt $fname]} {
    $wtxt edit modified no
    alited::detached::Modified $pobj $wtxt
  }
}
#_______________________

proc detached::Cancel {pobj win fname args} {
  # Closes detached editor.
  #   pobj -apave object
  #   win - editor's window
  #   fname - file name

  lassign [split $pobj ,] -> id
  if {$id<=8} {
    # save only first ones' geometry (avoiding fat history)
    set $pobj [wm geometry $win]
  }
  set wtxt [$pobj Text]
  if {[$wtxt edit modified]} {
    set msg [msgcat::mc {Save changes made to the text?}]
    switch [alited::msg yesnocancel warn $msg {} -centerme $win] {
      1 {SaveFile $pobj $fname}
      2 {}
      default {return}
    }
  }
  catch {destroy $win}
  $pobj destroy
}
#_______________________

proc detached::_create {fname} {
  # Handles detached editor.
  #   fname - edited file's name

  namespace upvar ::alited al al
  lassign [Options] id pobj win geo
  set $pobj $geo
  if {$geo ne {}} {set geo "-geometry $geo"}
  set al(detachtools) [list]
  foreach icon {SaveFile undo redo cut copy paste} {
    set img [alited::ini::CreateIcon $icon]
    append al(detachtools) " $img \{{} "
    switch $icon {
      SaveFile {
        append al(detachtools) \
          "-com {alited::detached::SaveFile $pobj $fname} -state disabled"
        set tip $::alited::al(MC,ico$icon)
      }
      undo - redo - cut - copy - paste {
        append al(detachtools) "-com {alited::detached::Tool $pobj $icon}"
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
      {-w 50 -h 30 -gutter GutText -gutterwidth $al(ED,gutterwidth) \
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
  after 50 after idle "$pobj fillGutter $wtxt;\
    alited::file::MakeThemHighlighted {} $wtxt;\
    alited::detached::DisplayText $pobj {$fname};\
    alited::main::HighlightText {} {$fname} $wtxt {alited::detached::Modified $pobj};\
    "
  $pobj showModal $win -modal no -waitvar no -resizable 1 -minsize {300 200} \
    -onclose "alited::detached::Cancel $pobj $win {$fname}" -focus $wtxt {*}$geo
  after 200 after idle "$pobj fillGutter $wtxt"
}
#_______________________

proc detached::_run {fnames} {
  # Open files in detached editors.
  #   fnames - file name list

  foreach fn $fnames {
    _create $fn
  }
}
