#! /usr/bin/env tclsh
###########################################################
# Name:    detach.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jul 10, 2024
# Brief:   Handles file detachments.
# License: MIT.
###########################################################

# _________________________ detach ________________________ #

namespace eval detached {
}
#_______________________

proc detached::Tool {pobj tool} {
  # Applies tool to text.
  #   pobj - apave object of detached editor
  #   tool - tool of toolbar

  event generate [$pobj Text] <<[string totitle $tool]>>
}
#_______________________

proc detached::DisplayText {pobj fname} {
  # Displays file's text.
  #   pobj - apave object of detached editor
  #   fname - file name

  $pobj displayText [$pobj Text] [readTextFile $fname]
}
#_______________________

proc detached::Cancel {pobj win args} {
  # Closes detached editor.
  #   pobj -apave object
  #   win - editor's window

  catch {destroy $win}
  $pobj destroy
}
#_______________________

proc detached::_create {fname} {
  # Handles detached editor.
  #   fname - edited file's name

  namespace upvar ::alited al al
  variable win
  set doid [incr al(detachedID)]
  set pobj ::alited::al::detachedObj$doid
  set win $al(WIN).detachedWin$doid
  set al(detachtools) [list]
  foreach icon {SaveFile undo redo cut copy paste} {
    set img [alited::ini::CreateIcon $icon]
    append al(detachtools) " $img \{{} "
    switch $icon {
      SaveFile {
        append al(detachtools) "-com alited::detached::SaveFile -state disabled"
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
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra $fname
  $pobj paveWindow $win.fra {
    {fra1 - - 1 1 {-st nsew -rw 1 -cw 1}}
    {.toolTop - - - - {pack -side top -fill x} {-array {$::alited::al(detachtools)} -relief groove -borderwidth 1}}
    {.GutText - - - - {pack -side left -expand 0 -fill both}}
    {.FrAText - - - - {pack -side left -expand 1 -fill both \
      -padx 0 -pady 0 -ipadx 0 -ipady 0} {-background $::apave::BGMAIN2}}
    {.frAText.Text - - - - {pack -expand 1 -fill both} \
      {-w 80 -h 30 -gutter GutText -gutterwidth $al(ED,gutterwidth) \
      -guttershift $al(ED,guttershift)}}
    {.sbv + L - - {pack -side right -fill y}}
    {fra2 fra1 T 1 1 {-st nsew}}
    {.lab - - - - {pack -side left -expand 0} {-t {Find: }}}
    {.ent - - - - {pack -side left -expand 0} {}}
    {.h_ - - - - {pack -side left -expand 1 -fill x}}
    {.but - - - - {pack -side left -expand 0} {-t Close}}
  }
  set wtxt [$pobj Text]
  $pobj fillGutter $wtxt
  after 50 [list after idle [list alited::detached::DisplayText $pobj $fname]]
  set geo {}
  set res [$pobj showModal $win -modal no -waitvar no -resizable 1 -minsize {300 200} \
    -onclose "alited::detached::Cancel $pobj $win" -focus $wtxt {*}$geo]
}
#_______________________

proc detached::_run {fnames} {
  # Open files in detached editors.
  #   fnames - file name list

  alited::Balloon "detached::_run - under development"  ;#! TODEL
  foreach fn $fnames {
    _create $fn
  }
}
