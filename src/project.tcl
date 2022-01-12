#! /usr/bin/env tclsh
###########################################################
# Name:    project.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    04/28/2021
# Brief:   Handles project settings.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval project {

  # "Projects" dialogue's path
  variable win $::alited::al(WIN).diaPrj

  # project options' names
  variable OPTS [list \
    prjname prjroot prjdirign prjEOL prjindent prjindentAuto prjredunit prjmultiline prjbeforerun]

  # list of projects
  variable prjlist [list]

  # initial geometry of "Projects" dialogue (centered in the main form)
  variable geo root=$::alited::al(WIN)

  # -minsize oprion of "Projects" dialogue
  variable minsize {}

  # saved index of last selected project
  variable ilast -1

  # saved tab of "Projects" dialogue
  variable oldTab {}

  # data of projects
  variable prjinfo; array set prjinfo [list]

  # data of currently open project (to save/restore)
  variable curinfo; array set curinfo [list]

  # calendar's data
  variable klnddata; array set klnddata [list]
  set klnddata(dateformat) {%Y/%m/%d}
}

# ________________________ Common _________________________ #

proc project::TabFileInfo {} {
  # Fills a listbox with a list of project files.

  namespace upvar ::alited al al obDl2 obDl2
  set lbx [$obDl2 LbxFlist]
  $lbx delete 0 end
  foreach tab [lsort -index 0 -dictionary $al(tablist)] {
    set fname [lindex [split $tab \t] 0]
    $lbx insert end $fname
  }
}
#_______________________

proc project::ProjectName {fname} {
  # Gets a project name from its file name.

  return [file rootname [file tail $fname]]
}
#_______________________

proc project::ProjectFileName {name} {
  # Gets a project file name from a project's name.

  namespace upvar ::alited al al PRJDIR PRJDIR PRJEXT PRJEXT
  set name [ProjectName [string trim $name]]
  return [file normalize [file join $PRJDIR "$name$PRJEXT"]]
}
#_______________________

proc project::CheckProjectName {} {
  # Removes spec.characters from a project name (sort of normalizing it).

  namespace upvar ::alited al al
  set oldname $al(prjname)
  set al(prjname) [string map [list \
    * _ ? _ ~ _ . _ / _ \\ _ \{ _ \} _ \[ _ \] _ \t _ \n _ \r _ \
    | _ < _ > _ & _ , _ : _ \; _ \" _ ' _ ` _] $al(prjname)]
  return [expr {$oldname eq $al(prjname)}]
}
#_______________________

proc project::GetProjects {} {
  # Reads settings of all projects.

  namespace upvar ::alited al al PRJEXT PRJEXT
  variable prjlist
  variable ilast
  set prjlist [list]
  set i [set ilast 0]
  foreach finfo [alited::tree::GetDirectoryContents $::alited::PRJDIR] {
    set fname [lindex $finfo 2]
    if {[file extension $fname] eq $PRJEXT} {
      if {[GetProjectOpts $fname] eq $al(prjname)} {
        set ilast $i
      }
      incr i
    }
  }
}

# ________________________ Ini _________________________ #

proc project::SaveData {} {
  # Saves some data.

  variable ilast
  set ilast [Selected index no]
}
#_______________________

proc project::GetOptVal {line} {
  # Gets a name and a value from a line of form "name=value".
  #   line - the line

  if {[set i [string first = $line]]>-1} {
    return [list [string range $line 0 $i-1] [string range $line $i+1 end]]
  }
  return [list]
}
#_______________________

proc project::ProcEOL {val mode} {
  # Transforms \n to "EOL chars" and vise versa.
  #   val - string to transform
  #   mode - if "in", gets \n-value; if "out", gets EOL-value.

  if {$mode eq {in}} {
    return [string map [list $::alited::EOL \n] $val]
  } else {
    return [string map [list \n $::alited::EOL] $val]
  }
}
#_______________________

proc project::SaveSettings {} {
  # Saves project settings to curinfo array.

  namespace upvar ::alited al al
  variable curinfo
  variable OPTS
  foreach v $OPTS {
    set curinfo($v) $al($v)
  }
  set curinfo(prjfile) $al(prjfile)
}
#_______________________

proc project::RestoreSettings {} {
  # Restores project settings from curinfo array.

  namespace upvar ::alited al al
  variable curinfo
  variable OPTS
  foreach v $OPTS {
    set al($v) $curinfo($v)
  }
  set al(prjfile) $curinfo(prjfile)
  TabFileInfo
}
#_______________________

proc project::GetProjectOpts {fname} {
  # Reads a project's settings from a project settings file.
  #   fname - the project settings file's name

  namespace upvar ::alited al al
  variable prjlist
  variable prjinfo
  variable OPTS
  variable curinfo
  set pname [ProjectName $fname]
  # save project names to 'prjlist' variable to display it by treeview widget
  lappend prjlist $pname
  # save project files' settings in prjinfo array
  set filecont [::apave::readTextFile $fname]
  foreach opt $OPTS {
    catch {set prjinfo($pname,$opt) $al($opt)}  ;#defaults
  }
  set prjinfo($pname,tablist) [list]
  if {[set currentprj [expr {$curinfo(prjname) eq $pname}]]} {
    foreach tab [alited::bar::BAR listTab] {
      set tid [lindex $tab 0]
      lappend prjinfo($pname,tablist) [alited::bar::FileName $tid]
    }
  }
  foreach line [::apave::textsplit $filecont] {
    lassign [GetOptVal $line] opt val
    if {[lsearch $OPTS $opt]>-1} {
      set prjinfo($pname,$opt) [ProcEOL $val in]
    } elseif {$opt eq "tab" && !$currentprj} {
      lappend prjinfo($pname,tablist) $val
    }
  }
  set prjinfo($pname,prjfile) $fname
  set prjinfo($pname,prjdirign) $al(DEFAULT,prjdirign)
  set prjinfo($pname,prjname) $pname
  set al(tablist) $prjinfo($pname,tablist)
  return $pname
}
#_______________________

proc project::PutProjectOpts {fname oldname dorename} {
  # Writes a project's settings to a project settings file.
  #   fname - the project settings file's name
  #   oldname - old name of the project file
  #   dorename - yes, if rename of old -notes/-rems

  namespace upvar ::alited al al obDl2 obDl2
  variable prjinfo
  variable OPTS
  set filecont [::apave::readTextFile $oldname]
  set newcont {}
  foreach line [::apave::textsplit $filecont] {
    lassign [GetOptVal $line] opt val
    if {$line eq {[Tabs]}} {
      foreach tab $al(tablist) {
        append line \n "tab=$tab"
      }
    } elseif {$opt in [list tab rem tablist {*}$OPTS]} {
      continue
    } elseif {$opt in {curtab}} {
      # 
    } elseif {$line eq {[Options]}} {
      foreach opt $OPTS {
        if {$opt ni {prjname tablist}} {
          set val [set alited::al($opt)]
          append line \n $opt= $val
          set prjinfo($al(prjname),$opt) [ProcEOL $val in]
        }
      }
    }
    append newcont $line \n
  }
  ::apave::writeTextFile $fname newcont
  if {$oldname ne $fname} {
    catch {file delete $oldname}
    if {$dorename} {
      foreach ftyp {notes rems} {
        set oldtyp [file rootname $oldname]-$ftyp.txt
        set newtyp [file rootname $fname]-$ftyp.txt
        catch {file rename $oldtyp $newtyp}
      }
    }
  }
}

# ________________________ Text fields _________________________ #

proc project::SaveNotesRems {} {
  # Saves notes and reminders.

  Klnd_save
  SaveNotes
}
#_______________________

proc project::CurrProject {} {
  # Gets a current project name, from a current item of project list.

  namespace upvar ::alited obDl2 obDl2
  variable prjlist
  set prj {}
  catch {
    set tree [$obDl2 TreePrj]
    set item [Selected item no]
    set isel [$tree index $item]
    set prj [lindex $prjlist $isel]
  }
  return $prj
}
#_______________________

proc project::SaveNotes {} {
  # Saves a file of notes, for a current item of project list.

  namespace upvar ::alited obDl2 obDl2
  variable klnddata
  if {[set prj $klnddata(SAVEPRJ)] ne {}} {
    set fnotes [NotesFile $prj]
    set fcont [[$obDl2 TexPrj] get 1.0 {end -1c}]
    ::apave::writeTextFile $fnotes fcont 0 0
  }
}
#_______________________

proc project::NotesFile {prj} {
  # Gets a file name of notes.

  return [file join $::alited::PRJDIR $prj-notes.txt]
}
#_______________________

proc project::RemsFile {prj} {
  # Gets a file name of reminders.

  return [file join $::alited::PRJDIR $prj-rems.txt]
}
#_______________________

proc project::ReadRems {prj} {
  # Reads a file of reminders.

  variable klnddata
  set frems [RemsFile $prj]
  if {[file exists $frems]} {
    set res [::apave::readTextFile $frems]
  } else {
    set res [list]
  }
  return $res
}
#_______________________

proc project::SortRems {rems} {
  # Sorts reminders by date.
  #   rems - list of reminders
  # Returns a list of a reminder date before a current date and a sorted list.

  variable klnddata
  set tmp [list]
  set dmin 0
  set dcur [KlndInDate]
  foreach it $rems {
    lassign $it d text
    lassign [split $d /] y m d
    if {[catch {set d [KlndInDate $y $m $d]}]} {
      set d [clock seconds]
    }
    if {$d<=$dcur && ($dmin==0 || $d<$dmin)} {
      set dmin $d
    }
    lappend tmp [list $d $text]
  }
  set rems [list]
  foreach it [lsort -index 0 $tmp] {
    lassign $it d text
    set d [clock format $d -format $klnddata(dateformat)]
    lappend rems [list $d $text]
  }
  return [list $dmin $rems]
}
#_______________________

proc project::Klnd_delete {} {
  # Clears a reminder.

  namespace upvar ::alited obDl2 obDl2
  [$obDl2 TexKlnd] replace 1.0 end {}
}
#_______________________

proc project::Klnd_save {} {
  # Saves a reminder on a date.

  namespace upvar ::alited obDl2 obDl2 al al
  variable prjinfo
  variable klnddata
  set wtxt [$obDl2 TexKlnd]
  if {$klnddata(SAVEDATE) eq {} || ![$wtxt edit canundo]} {
    return ;# no changes
  }
  if {[set prjname $klnddata(SAVEPRJ)] eq {}} return
  set text [string trim [$wtxt get 1.0 end]]
  set date $klnddata(SAVEDATE)
  set info [list $date $text "TODO opt."]  ;# + possible options for future
  set i [KlndSearch $date $prjname]
  if {$text eq {}} {
    if {$i>-1} {
      set prjinfo($prjname,prjrem) [lreplace $prjinfo($prjname,prjrem) $i $i]
    }
  } elseif {$i>-1} {
    set prjinfo($prjname,prjrem) [lreplace $prjinfo($prjname,prjrem) $i $i $info]
  } else {
    lappend prjinfo($prjname,prjrem) $info
  }
  ::klnd::update {} {} {} $prjinfo($prjname,prjrem)
  set frems [RemsFile $prjname]
  if {$frems ne {}} {
    set fcont $prjinfo($prjname,prjrem)
    ::apave::writeTextFile $frems fcont 0 0
  }
}
#_______________________

proc project::KlndBorderText {{clr {}}} {
  # Highlights/unhighlights a reminder's border.
  #   clr - color of border

  namespace upvar ::alited obDl2 obDl2
  if {$clr eq {}} {set clr [lindex [::apave::obj csGet] 8]} bell
  [$obDl2 TexKlnd] configure -highlightbackground $clr
}

# ________________________ GUI helpers _________________________ #

proc project::Select {{item ""}} {
  # Handles a selection in a list of projects.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo 
  variable OPTS
  variable klnddata
  Klnd_save
  if {$item eq {}} {set item [Selected item no]}
  if {$item ne {}} {
    set tree [$obDl2 TreePrj]
    if {[string is digit $item]} {  ;# the item is an index
      if {$item<0 || $item>=[llength $prjlist]} return
      set prj [lindex $prjlist $item]
      set item $prjinfo($prj,ID)
    } elseif {![$tree exists $item]} {
      return
    }
    set isel [$tree index $item]
    if {$isel<0 || $isel>=[llength $prjlist]} return
    set prj [lindex $prjlist $isel]
    set fnotes [NotesFile $prj]
    set wtxt [$obDl2 TexPrj]
    $wtxt delete 1.0 end
    if {[file exists $fnotes]} {
      $wtxt insert end [::apave::readTextFile $fnotes]
    }
    $wtxt edit reset; $wtxt edit modified no
    lassign [SortRems [ReadRems $prj]] dmin prjinfo($prj,prjrem)
    foreach opt $OPTS {
      set al($opt) $prjinfo($prj,$opt)
    }
    set al(tablist) $prjinfo($prj,tablist)
    TabFileInfo
    if {[$tree selection] ne $item} {
      $tree selection set $item
    }
    if {$dmin>0} {
      KlndGoto $dmin
    } else {
      KlndBorderText
    }
    $tree see $item
    $tree focus $item
    alited::Message2 {}
    ::klnd::blinking no
    set klnddata(SAVEDATE) {}
    catch {after cancel $klnddata(AFTERKLND)}
    set klnddata(AFTERKLND) [after 200 alited::project::KlndUpdate]
  }
}
#_______________________

proc project::Selected {what {domsg yes}} {
  # Gets a currently selected project's index.
  #   what - if "index", selected item's index is returned
  #   domsg - if "no", no message displayed if there is no selected project

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  set tree [$obDl2 TreePrj]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq {} && $domsg} {
    alited::Message2 $al(MC,prjsel) 4
  }
  if {$isel ne {} && $what eq {index}} {
    set isel [$tree index $isel]
  }
  return $isel
}
#_______________________

proc project::UpdateTree {} {
  # Fills a list of projects.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo
  set tree [$obDl2 TreePrj]
  $tree delete [$tree children {}]
  foreach prj $prjlist {
    set prjinfo($prj,ID) [$tree insert {} end -values [list $prj]]
  }
}
#_______________________

proc project::CheckNewDir {} {
  # Checks if the root directory exists. If no, tries to create it.
  # Returns yes, if all is OK.

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  if {![file exists $al(prjroot)]} {
    $win.fra.fraR.nbk select $win.fra.fraR.nbk.f1
    focus [::apave::precedeWidgetName [$obDl2 Dir] ent]
    set msg [string map [list %d $al(prjroot)] $al(makeroot)]
    if {![alited::msg yesno ques $msg NO -geometry root=$win]} {
      return no
    }
    if {[catch {file mkdir $al(prjroot)} err]} {
      set msg [msgcat::mc {Error at creating the directory.}]
      alited::msg ok err [append msg \n\n $err] -geometry root=$win
      return no
    }
  }
  return yes
}

#_______________________

proc project::ExistingProject {msgOnExist} {
  # Checks if a project (of entry field) exists.
  #   msgOnExist - yes, if message on existing, else on non-existing project
  # Returns a project name if it exists or {} otherwise.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  set pname $al(prjname)
  if {[lsearch -exact $prjlist $pname]>-1} {
    if {$msgOnExist} {
      focus [$obDl2 EntName]
      set msg [string map [list %n $pname] $al(MC,prjexists)]
      alited::Message2 $msg 4
    }
  } else {
    if {!$msgOnExist} {
      focus [$obDl2 EntName]
      set msg [msgcat::mc \
        "A project \"%n\" doesn't exists. Hit \[+\] button to create it."]
      set msg [string map [list %n $pname] $msg]
      alited::Message2 $msg 4
    }
    set pname {}
  }
  return $pname
}
#_______________________

proc project::ValidProject {} {
  # Checks if a project's options are valid.

  namespace upvar ::alited al al obDl2 obDl2
  set al(prjname) [string trim $al(prjname)]
  if {$al(prjname) eq {} || ![CheckProjectName]} {
    bell
    focus [$obDl2 EntName]
    return no
  }
  set al(prjroot) [file nativename $al(prjroot)]
  if {![CheckNewDir]} {return no}
  if {$al(prjindent)<0 || $al(prjindent)>8} {set al(prjindent) 2}
  if {$al(prjredunit)<10 || $al(prjredunit)>100} {set al(prjredunit) 20}
  set msg [string map [list %d $al(prjroot)] $al(checkroot)]
  alited::Message2 $msg 5
  if {[llength [alited::tree::GetDirectoryContents $al(prjroot)]] >= $al(MAXFILES)} {
    set msg [string map [list %n $al(MAXFILES)] $al(badroot)]
    alited::Message2 $msg 4
    set res no
  } else {
    alited::Message2 {} 5
    set res yes
  }
  return $res
}
#_______________________

proc project::KlndGoto {dmin} {
  # Selects a date of reminder before a current one.
  #   dmin - date in seconds to select

  variable klnddata
  set d [clock format $dmin -format $klnddata(dateformat)]
  lassign [split $d /] y m d
  set m [string trimleft $m { 0}]
  set d [string trimleft $d { 0}]
  ::klnd::selectedDay {} $y $m $d
  after idle {::alited::project::KlndBorderText red}
}
#_______________________

  proc project::SelFiles {} {
    # Checks for a selection of file listbox.
    # Returns: list of listbox's path and the selection or {}.

  namespace upvar ::alited obDl2 obDl2
  set lbx [$obDl2 LbxFlist]
  if {![llength [set selidx [$lbx curselection]]]} {
    alited::Message2 [msgcat::mc {No selected files}] 4
    return {}
  }
  return [list $lbx $selidx]
}
#_______________________

proc project::OpenSelFiles {} {
  # Opens selected files of listbox.
  # Files are open in a currently open project.

  namespace upvar ::alited al al
  variable prjinfo
  variable curinfo
  set prj $al(prjname)
  set cprj $curinfo(prjname)
  set al(prjname) $curinfo(prjname)
  lassign [SelFiles] lbx selidx
  if {$lbx ne {}} {
    set llen [llength $selidx]
    set msg [string map [list %n $llen] [msgcat::mc {Open files: %n}]]
    alited::Message2 $msg 3
    update
    foreach idx [lreverse $selidx] {
      set fn [$lbx get $idx]
      lappend fnames $fn
      if {[lsearch -index 0 -exact $prjinfo($cprj,tablist) $fn]<0} {
        set prjinfo($cprj,tablist) [linsert $prjinfo($cprj,tablist) 0 $fn]
      }
    }
    alited::file::OpenFile $fnames yes yes alited::info::Put
  }
  set al(prjname) $prj
}
#_______________________

proc project::CloseSelFiles {} {
  # Closes selected files of listbox.
  # Files are closed in a currently open project.

  namespace upvar ::alited al al
  variable prjinfo
  variable curinfo
  if {[set pname [ExistingProject no]] eq {}} return
  set prj $al(prjname)
  set cprj $curinfo(prjname)
  lassign [SelFiles] lbx selidx
  if {$lbx ne {}} {
    set closecurr no
    set fnamecurr [alited::bar::FileName]
    foreach idx $selidx {
      set fname [$lbx get $idx]
      if {[set TID [alited::bar::FileTID $fname]] ne {}} {
        if {$fname eq $fnamecurr} {
          set closecurr yes
        } else {
          alited::bar::BAR $TID close no
        }
      }
      if {$prj eq $cprj &&
      [set i [lsearch -index 0 -exact $prjinfo($cprj,tablist) $fname]]>=0} {
        set prjinfo($cprj,tablist) [lreplace $prjinfo($cprj,tablist) $i $i]
      }
    }
    if {$closecurr && [set TID [alited::bar::FileTID $fnamecurr]] ne {}} {
      alited::bar::BAR $TID close ;# this should be last to check for "No name" tab
    }
    alited::bar::BAR draw
    if {$prj eq $cprj} {
      set al(tablist) $prjinfo($cprj,tablist)
      TabFileInfo
    }
  }
}
#_______________________

proc project::SelectAllFiles {} {
  # Selects all files of listbox.

  namespace upvar ::alited obDl2 obDl2
  [$obDl2 LbxFlist] selection set 0 end
}
#_______________________

proc project::LbxPopup {X Y} {
  # Runs a popup menu on the project files listbox.
  #   X - x-coordinate of mouse pointer
  #   Y - y-coordinate of mouse pointer

  namespace upvar ::alited obDl2 obDl2 al al
  set popm [$obDl2 LbxFlist].popup
  catch {destroy $popm}
  menu $popm -tearoff 0
  $popm add command -label $al(MC,openselfile) -command alited::project::OpenSelFiles
  $popm add command -label [msgcat::mc {Close Selected File(s)}] -command alited::project::CloseSelFiles
  $popm add separator
  $popm add command -label [msgcat::mc {Select All}] -command alited::project::SelectAllFiles -accelerator Ctrl+A
  baltip::sleep 1000
  tk_popup $popm $X $Y
}

# ________________________ Buttons for project list _________________________ #

proc project::Add {} {
  # "Add project" button's handler.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo
  variable OPTS
  SaveNotesRems ;# --> old project's notes & rems
  if {![ValidProject] || [ExistingProject yes] ne {}} return
  set al(tablist) [list]
  TabFileInfo
  set pname $al(prjname)
  set al(prjfile) [ProjectFileName $pname]
  set al(prjbeforerun) {}
  if {$al(PRJDEFAULT)} {
    # use project defaults from "Setup/Common/Projects"
    foreach opt $OPTS {
      catch {set al($opt) $al(DEFAULT,$opt)}
    }
  }
  alited::ini::SaveIni yes  ;# to initialize ini-file
  foreach opt $OPTS {
    set prjinfo($pname,$opt) $al($opt)
  }
  set prjinfo($pname,prjrem) {} ;# reminders
  PutProjectOpts $al(prjfile) $al(prjfile) no
  GetProjects
  UpdateTree
  Select $prjinfo($pname,ID)
  alited::Message2 [string map [list %n $pname] $al(MC,prjnew)]
}
#_______________________

proc project::Change {} {
  # "Change project" button's handler.

  namespace upvar ::alited al al
  variable curinfo
  variable prjlist
  variable prjinfo
  SaveNotesRems
  if {[set isel [Selected index]] eq {}} return
  if {![ValidProject]} return
  for {set i 0} {$i<[llength $prjlist]} {incr i} {
    if {$i!=$isel && [lindex $prjlist $i] eq $al(prjname)} {
      set msg [string map [list %n $al(prjname)] $al(MC,prjexists)]
      alited::Message2 $msg 4
      return
    }
  }
  set oldprj [lindex $prjlist $isel]
  set newprj $al(prjname)
  set prjinfo($newprj,tablist) $prjinfo($oldprj,tablist)
  catch {unset prjinfo($oldprj,tablist)}
  set oldname [ProjectFileName $oldprj]
  set prjlist [lreplace $prjlist $isel $isel $newprj]
  set fname [ProjectFileName $newprj]
  if {$newprj eq $curinfo(prjname)} SaveSettings
  if {$oldprj eq $curinfo(prjname)} {
    set curinfo(prjname) $newprj
    set curinfo(prjfile) $fname
  }
  set prjinfo($newprj,prjrem) $prjinfo($oldprj,prjrem) ;# reminders
  PutProjectOpts $fname $oldname yes
  GetProjects
  UpdateTree
  Select $prjinfo($newprj,ID)
  alited::Message2 [string map [list %n [lindex $prjlist $isel]] $al(MC,prjupd)]
}
#_______________________

proc project::Delete {} {
  # "Delete project" button's handler.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo
  variable win
  variable curinfo
  if {[set isel [Selected index]] eq ""} return
  set geo "-geometry root=$win"
  set nametodel [lindex $prjlist $isel]
  if {$nametodel eq $curinfo(prjname)} {
    alited::msg ok err $al(MC,prjcantdel) {*}$geo
    return
  }
  set msg [string map [list %n $nametodel] $al(MC,prjdelq)]
  if {![alited::msg yesno ques $msg NO {*}$geo]} {
    return
  }
  if {[catch {file delete [ProjectFileName $nametodel]} err]} {
    alited::msg ok err $err {*}$geo
    return
  }
  catch {file delete [NotesFile $nametodel]}
  catch {file delete [RemsFile $nametodel]}
  if {[set llen [llength $prjlist]] && $isel>=$llen} {
    set isel [incr llen -1]
  }
  GetProjects
  UpdateTree
  Select $isel
  alited::Message2 [string map [list %n $nametodel] $al(MC,prjdel2)]
}

# ________________________ Buttons _________________________ #

proc project::Ok {args} {
  # 'OK' button handler.
  #   args - possible arguments

  namespace upvar ::alited al al obDl2 obDl2 obPav obPav
  variable win
  variable prjlist
  variable prjinfo
  variable curinfo
  Klnd_save
  set msec [clock milliseconds]
  if {($msec-$curinfo(_MSEC))<5000} {
    # disables entering twice (at multiple double-clicks)
    # 5 sec. of clicking seems to be enough for opening a file
    return
  }
  set curinfo(_MSEC) $msec
  if {[set isel [Selected index]] eq {} || ![ValidProject]} {
    focus [$obDl2 TreePrj]
    return
  }
  if {![ValidProject]} return
  if {[set pname [ExistingProject no]] eq {}} return
  if {[set N [llength [alited::bar::BAR listFlag m]]]} {
    set msg [msgcat::mc "All modified files (%n) will be saved.\n\nDo you agree?"]
    set msg [string map [list %n $N] $msg]
    if {![alited::msg yesno ques $msg NO -geometry root=$win]} return
  }
  if {![alited::file::SaveAll]} {
    $obDl2 res $win 0
    return
  }
  if {[set N [llength [alited::bar::BAR cget -select]]]} {
    set msg [msgcat::mc "All selected files (%n) will remain open\nin the project you are switching to.\n\nDo you agree?"]
    set msg [string map [list %n $N] $msg]
    if {![alited::msg yesno ques $msg NO -geometry root=$win]} return
  }
  set fname [ProjectFileName $pname]
  RestoreSettings
  alited::ini::SaveIni
  alited::file::CloseAll 1 -skipsel  ;# the selected tabs aren't closed 
  set selfiles [list]                ;# -> get their file names to reopen afterwards
  foreach tid [alited::bar::BAR listFlag s] {
    lappend selfiles [alited::bar::FileName $tid]
  }
  alited::file::CloseAll 1           ;# close all tabs
  set al(prjname) $pname
  set al(prjfile) $fname
  alited::ini::ReadIni $fname
  alited::bar::FillBar [$obPav BtsBar]
  for {set i [llength $selfiles]} {$i} {} { ;# reopen selected files of previous project
    incr i -1
    set fname [lindex $selfiles $i]
    if {[alited::bar::FileTID $fname] eq {}} {
      alited::file::OpenFile $fname yes
    }
  }
  set TID [lindex [alited::bar::BAR listTab] $al(curtab) 0]
  catch {alited::bar::BAR $TID show yes no}
  alited::main::UpdateProjectInfo
  alited::ini::GetUserDirs
  alited::file::MakeThemHighlighted
  alited::favor::ShowFavVisit
  [$obPav Tree] selection set {}  ;# new project - no group selected
  update
  alited::main::ShowText
  if {!$al(TREE,isunits)} {after idle alited::tree::RecreateTree}
  $obDl2 res $win 1
}
#_______________________

proc project::Cancel {args} {
  # 'Cancel' button handler.
  #   args - possible arguments

  namespace upvar ::alited obDl2 obDl2
  variable win
  SaveData
  SaveNotesRems
  RestoreSettings
  $obDl2 res $win 0
}
#_______________________

proc project::Help {} {
  # 'Help' button handler.

  variable win
  alited::Help $win
}
#_______________________

proc project::HelpMe {} {
  # 'Help' for start.

  variable win
  alited::HelpMe $win
}
#_______________________

proc project::ProjectEnter {} {
  # Processes double-clicking and pressing Enter on the project list.
  # Cancels selecting projects if there are old reminders.

  namespace upvar ::alited al al
  variable win
  variable prjinfo
  variable klnddata
  lassign [SortRems $prjinfo($al(prjname),prjrem)] dmin
  if {$dmin && $dmin<[clock seconds]} {
    set tab1 $win.fra.fraR.nbk.f1
    if {[$win.fra.fraR.nbk select] ne $tab1} {
      $win.fra.fraR.nbk select $tab1
    }
    KlndGoto $dmin
    set msg [msgcat::mc {TODO reminders for the past: %d. Delete them or try "Select".}]
    set dmin [clock format $dmin -format $klnddata(dateformat)]
    set msg [string map [list %d $dmin] $msg]
    alited::Message2 $msg 4
    return
  }
  Ok
}
#_______________________

proc project::Klnd_button {ev} {
  # Fire an event handler (paste/undo/redo) on a reminder.
  #   ev - event to fire

  namespace upvar ::alited obDl2 obDl2
  ::apave::eventOnText [$obDl2 TexKlnd] $ev
}
#_______________________

proc project::Klnd_paste {} {
  # Pastes a text to a reminder.

  Klnd_button <<Paste>>
}
#_______________________

proc project::Klnd_undo {} {
  # Undoes changes of a reminder.

  Klnd_button <<Undo>>
}
#_______________________

proc project::Klnd_redo {} {
  # Redoes changes of a reminder.

  Klnd_button <<Redo>>
}

# ________________________ Calendar _________________________ #

proc project::KlndUpdate {} {
  # Updates calendar data.

  namespace upvar ::alited al al
  variable prjinfo
  if {![info exists prjinfo($al(prjname),prjrem)]} {
    set prjinfo($al(prjname),prjrem) {}
  }
  ::klnd::update {} {} {} $prjinfo($al(prjname),prjrem)
  lassign [::klnd::selectedDay] y m d
  KlndClick $y $m $d
}
#_______________________

proc project::KlndInDate {{y {}} {m {}} {d {}}} {
  # Gets a date in seconds.
  #   y - year
  #   m - month
  #   d - day
  # If *y* is omitted or y/m/d not valid, gets a current date in seconds.

  variable klnddata
  if {$y ne {}} {
    if {[catch {set date [clock scan $y/$m/$d -format $klnddata(dateformat)]}]} {
      set y {}
    }
  }
  if {$y eq {}} {set date [clock seconds]}
  return $date
}
#_______________________

proc project::KlndOutDate {{y {}} {m {}} {d {}}} {
  # Gets a date formatted.
  #   y - year
  #   m - month
  #   d - day
  # If *y* is omitted or y/m/d not valid, gets a current date formatted.

  variable klnddata
  set date [KlndInDate $y $m $d]
  return [clock format $date -format $klnddata(dateformat)]
}
#_______________________

proc project::KlndDate {date} {
  # Formats a calendar date by alited's format (Preferences/Templates).
  #   date - the date to be formatted

  namespace upvar ::alited al al
  variable klnddata
  set seconds [clock scan $date -format $klnddata(dateformat)]
  return [alited::tool::FormatDate $seconds]
}
#_______________________

proc project::KlndText {dt} {
  # Gets a reminder text for a date.
  #   dt - date

  namespace upvar ::alited al al
  variable prjinfo
  if {[set i [KlndSearch $dt $al(prjname)]]>-1} {
    return [lindex $prjinfo($al(prjname),prjrem) $i 1]
  }
  return {}
}
#_______________________

proc project::KlndClick {y m d} {
  # Processes a click on a calendar day.
  #   y - year
  #   m - month
  #   d - day

  namespace upvar ::alited obDl2 obDl2 al al
  variable klnddata
  set klnddata(date) [KlndOutDate $y $m $d]
  # first, save a previous reminder at need
  Klnd_save
  set klnddata(SAVEDATE) $klnddata(date)
  set klnddata(SAVEPRJ) [CurrProject]
  # then display a new reminder's text
  $obDl2 displayText [$obDl2 TexKlnd] [KlndText $klnddata(date)]
  [$obDl2 LabKlndDate] configure -text [KlndDate $klnddata(date)]
}
#_______________________

proc project::KlndSearch {date prjname} {
  # Search a date in calendar data.
  # Returns index of found item or -1 if not found.

  namespace upvar ::alited al al
  variable prjinfo
  variable klnddata
  set res -1
  catch {
    set res [lsearch -index 0 -exact $prjinfo($prjname,prjrem) $date]
  }
  return $res
}

# ________________________ GUI _________________________ #

proc project::MainFrame {} {
  # Creates a main frame of "Project" dialogue.

  return {
    {fraTreePrj - - 10 1 {-st nswe -pady 4 -rw 1}}
    {.TreePrj - - - - {pack -side left -expand 1 -fill both} {-h 16 -show headings -columns {C1} -displaycolumns {C1}}}
    {.sbvPrjs .TreePrj L - - {pack -side left -fill both}}
    {fraR fraTreePrj L 10 1 {-st nsew -cw 1 -pady 4}}
    {fraR.nbk - - - - {pack -side top -expand 1 -fill both} {
      f1 {-text {$al(MC,info)}}
      f2 {-text {$al(MC,prjOptions)}}
      -traverse yes -select f1
    }}
    {fraB1 fraTreePrj T 1 1 {-st nsew}}
    {.buTad - - - - {pack -side left -anchor n} {-takefocus 0 -com ::alited::project::Add -tip {$alited::al(MC,prjadd)} -image alimg_add-big}}
    {.buTch - - - - {pack -side left} {-takefocus 0 -com ::alited::project::Change -tip {$alited::al(MC,prjchg)} -image alimg_change-big}}
    {.buTdel - - - - {pack -side left} {-takefocus 0 -com ::alited::project::Delete -tip {$alited::al(MC,prjdel1)} -image alimg_delete-big}}
    {LabMess fraB1 L 1 1 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {seh fraB1 T 1 2 {-st nsew -pady 2}}
    {fraB2 seh T 1 2 {-st nsew} {-padding {2 2}}}
    {.ButHelp - - - - {pack -side left -anchor s -padx 2} {-t {$alited::al(MC,help)} -command ::alited::project::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 50}}
    {.butOK - - - - {pack -side left -anchor s -padx 2} {-t {$alited::al(MC,select)} -command ::alited::project::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -command ::alited::project::Cancel}}
  }
}
#_______________________

proc project::Tab1 {} {
  # Creates a main tab of "Project".

  variable klnddata
  variable prjinfo
  set klnddata(SAVEDATE) [set klnddata(SAVEPRJ) {}]
  set klnddata(toobar) "labKlndProm {TODO } LabKlndDate {} sev 6"
  foreach img {delete paste undo redo} {
    # -method option for possible disable/enable BuT_alimg_delete etc.
    append klnddata(toobar) " alimg_$img \{{} \
      -tip {-BALTIP {$alited::al(MC,prjT$img)} -MAXEXP 1@@ -under 4} \
      -com alited::project::Klnd_$img -method yes \}"
  }
  set klnddata(vsbltext) yes
  set klnddata(date) [KlndOutDate]
  after idle alited::project::KlndUpdate
  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labName - - 1 1 {-st w -pady 1 -padx 3} {-t {$al(MC,prjName)}}}
    {.EntName .labName L 1 1 {-st sw -pady 5} {-tvar alited::al(prjname) -w 60}}
    {.labDir .labName T 1 1 {-st w -pady 8 -padx 3} {-t "Root directory:"}}
    {.Dir .labDir L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(prjroot) -w 60}}
    {lab fra1 T 1 2 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra2 lab T 2 1 {-st nsew -rw 1 -cw 99}}
    {.TexPrj - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 40 -wrap word -tabnext $alited::project::win.fra.fraB2.butHelp -tip {-BALTIP {$alited::al(MC,notes)} -MAXEXP 1}}}
    {.sbv .TexPrj L - - {pack -side left}}
    {fra3 fra2 L 2 1 {-st nsew} {-relief groove -borderwidth 2}}
    {.seh - - - - {pack -fill x}}
    {.daT - - - - {pack -fill both} {-tvar alited::project::klnddata(date) -com {alited::project::KlndUpdate; alited::project::KlndBorderText} -dateformat $alited::project::klnddata(dateformat) -tip {alited::project::KlndText %D}}}
    {fra3.fra - - - - {pack -fill both -expand 1} {}}
    {.seh2 - - - - {pack -side top -fill x}}
    {.too - - - - {pack -side top} {-relief flat -borderwidth 0 -array {$alited::project::klnddata(toobar)}}}
    {.TexKlnd - - - - {pack -side left -fill both -expand 1} {-wrap word -tabnext $alited::project::win.fra.fraB2.butHelp -w 4 -h 8 -tip {-BALTIP {$alited::al(MC,prjTtext)} -MAXEXP 1}}}
}
}
#_______________________

proc project::Tab2 {} {
  # Creates Options tab of "Project".

  namespace upvar ::alited al al
  lassign [alited::FgFgBold] fg al(FG,DEFopts)
  if {!$al(PRJDEFAULT)} {
    set alited::al(FG,DEFopts) "$fg -afteridle {grid forget %w}" ;# no heading message
  }
  return {
    {v_ - - 1 10}
    {lab1 v_ T 1 2 {-st nsew -pady 1 -padx 3} {-t {$alited::al(MC,DEFopts)} -foreground $alited::al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
    {fra2 lab1 T 1 2 {-st nsew -cw 1}}
    {.labIgn - - 1 1 {-st w -pady 1 -padx 3} {-t "Skip subdirectories:"}}
    {.entIgn .labIgn L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(prjdirign) -w 50}}
    {.labEOL .labIgn T 1 1 {-st w -pady 1 -padx 3} {-t "End of line:"}}
    {.cbxEOL .labEOL L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjEOL) -values {{} LF CR CRLF} -w 9 -state readonly}}
    {.labIndent .labEOL T 1 1 {-st w -pady 1 -padx 3} {-t "Indentation:"}}
    {.spxIndent .labIndent L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjindent) -w 9 -from 0 -to 8 -justify center}}
    {.chbIndAuto .spxIndent L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(prjindentAuto) -t "Auto detection"}}
    {.labRedunit .labIndent T 1 1 {-st w -pady 1 -padx 3} {-t "Unit lines per 1 red bar:"}}
    {.spxRedunit .labRedunit L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjredunit) -w 9 -from 10 -to 100 -justify center}}
    {.labMult .labRedunit T 1 1 {-st w -pady 1 -padx 3} {-t "Multi-line strings:" -tip {$alited::al(MC,notrecomm)}}}
    {.swiMult .labMult L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(prjmultiline) -tip {$alited::al(MC,notrecomm)}}}
    {.labFlist .labMult T 1 1 {-pady 3 -padx 3} {-t "List of files:"}}
    {fraFlist .labFlist T 1 2 {-st nswe -padx 3 -cw 1 -rw 1}}
    {.LbxFlist - - - - {pack -side left -fill both -expand 1} {-takefocus 0 -selectmode multiple -tip {-BALTIP {$alited::al(MC,TipLbx)} -MAXEXP 1} -popup {::alited::project::LbxPopup %X %Y}}}
    {.sbvFlist .lbxFlist L - - {pack -side left}}
  }
}

# ________________________ Main _________________________ #

proc project::_create {} {
  # Creates and opens "Projects" dialogue.

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable geo
  variable minsize
  variable prjlist
  variable oldTab
  variable ilast
  variable curinfo
  set curinfo(_MSEC) 0
  $obDl2 makeWindow $win.fra "$al(MC,projects) :: $::alited::PRJDIR"
  $obDl2 paveWindow \
    $win.fra [MainFrame] \
    $win.fra.fraR.nbk.f1 [Tab1] \
    $win.fra.fraR.nbk.f2 [Tab2]
  set tree [$obDl2 TreePrj]
  $tree heading C1 -text $al(MC,projects)
  if {$oldTab ne {}} {
    $win.fra.fraR.nbk select $oldTab
  }
  UpdateTree
  ::apave::bindToEvent $tree <<TreeviewSelect>> ::alited::project::Select
  bind $tree <Delete> ::alited::project::Delete
  bind $tree <Double-Button-1> ::alited::project::ProjectEnter
  bind $tree <Return> ::alited::project::ProjectEnter
  bind $win <F1> "[$obDl2 ButHelp] invoke"
  foreach a {a A} {
    bind [$obDl2 LbxFlist] <Control-$a> alited::project::SelectAllFiles
  }
  if {$ilast>-1} {Select $ilast}
  if {$minsize eq ""} {      ;# save default min.sizes
    after idle [list after 100 {
      set ::alited::project::minsize "-minsize {[winfo width $::alited::project::win] [winfo height $::alited::project::win]}"
    }]
  }
  after 500 ::alited::project::HelpMe ;# show an introduction after a short pause
  bind [$obDl2 TexPrj] <FocusOut> alited::project::SaveNotes
  bind [$obDl2 EntName] <FocusIn> alited::project::Klnd_save ;# before possible renaming
  set res [$obDl2 showModal $win  -geometry $geo {*}$minsize \
    -onclose ::alited::project::Cancel -focus [$obDl2 TreePrj]]
  set oldTab [$win.fra.fraR.nbk select]
  if {[llength $res] < 2} {set res ""}
  # save the new geometry of the dialogue
  set geo [wm geometry $win]
  destroy $win
  alited::main::ShowHeader yes
  return $res
}
#_______________________

proc project::_run {} {
  # Runs "Projects" dialogue.

  SaveSettings
  GetProjects
  set res [_create]
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
