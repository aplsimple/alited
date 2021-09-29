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

  # data of projects top save/restore
  variable data; array set data [list]

  # name of file containing project notes
  variable fnotes {}
}

# ________________________ Common _________________________ #

proc project::TabFileInfo {} {
  # Fills a listbox with a list of project files.

  namespace upvar ::alited al al obDl2 obDl2
  set lbx [$obDl2 LbxFlist]
  $lbx delete 0 end
  foreach tab $al(tablist) {
    set fname [lindex [split $tab \t] 0]
    $lbx insert end $fname
  }
}
#_______________________

proc project::SaveCurrFileList {title {isnew no}} {
  # Actions with a file list of project.
  #   title - title of the message box "What to do"
  #   isnew - yes, if it's a new project to be added
  # A result of action is saved to al(tablist).
  # Returns yes, if an action is chosen, no - if canceled.

  namespace upvar ::alited al al obDl3 obDl3
  variable win
  set asks [list $al(MC,prjaddfl) add $al(MC,prjsubstfl) change $al(MC,prjdelfl) delete \
    $al(MC,prjnochfl) file Cancel cancel]
  set msg [string map [list %n [string toupper $title]] $al(MC,prjgoing)]
  append msg \n\n $al(MC,prjsavfl)
  if {[info exists al(ANSWERED,SaveCurrFileList)]} {
    set ans $al(ANSWERED,SaveCurrFileList)
  } else {
    set ans [$obDl3 misc ques $title $msg $asks file -ch {Don't ask anymore}]
    if {[string last {10} $ans]>-1} {
      set ans [string map {10 {}} $ans]
      set al(ANSWERED,SaveCurrFileList) $ans
    }
  }
  switch $ans {
    "delete" {
      set al(tablist) [list]
      TabFileInfo
    }
    "add" - "change" {
      if {$ans eq "change" || $isnew} {
        set al(tablist) [list]
      }
      lassign [alited::bar::GetBarState] TIDcur - wtxt
      foreach tab [alited::bar::BAR listTab] {
        set TID [lindex $tab 0]
        if {$TID eq $TIDcur} {
          set pos [$wtxt index insert]
        } else {
          set pos [alited::bar::GetTabState $TID --pos]
        }
        set fname [set fn [alited::bar::FileName $TID]]
        append fn \t $pos
        if {$fname ne $al(MC,nofile) && [lsearch -exact $al(tablist) $fn]<0} {
          lappend al(tablist) $fn
        }
      }
      TabFileInfo
    }
    "file" {
      if {$isnew} {
        set al(tablist) [list]
        TabFileInfo
      }
    }
    default {
      return no
    }
  }
  return yes
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
  # Saves project settings to a data array.

  namespace upvar ::alited al al
  variable data
  variable OPTS
  foreach v $OPTS {
    set data($v) $al($v)
  }
  set data(prjfile) $al(prjfile)
}
#_______________________

proc project::RestoreSettings {} {
  # Restores project settings from a data array.

  namespace upvar ::alited al al
  variable data
  variable OPTS
  foreach v $OPTS {
    set al($v) $data($v)
  }
  set al(prjfile) $data(prjfile)
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
  variable data
  set pname [ProjectName $fname]
  # save project names to 'prjlist' variable to display it by treeview widget
  lappend prjlist $pname
  # save project files' settings in prjinfo array
  set filecont [::apave::readTextFile $fname]
  foreach opt $OPTS {
    catch {set prjinfo($pname,$opt) $al($opt)}  ;#defaults
  }
  set prjinfo($pname,prjfile) $fname
  set prjinfo($pname,prjname) $pname
  set prjinfo($pname,prjdirign) ".git .bak"
  set prjinfo($pname,tablist) [list]
  if {[set currentprj [expr {$data(prjname) eq $pname}]]} {
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
  set al(tablist) $prjinfo($pname,tablist)
  return $pname
}
#_______________________

proc project::PutProjectOpts {fname oldname} {
  # Writes a project's settings to a project settings file.
  #   fname - the project settings file's name
  #   oldname - old name of the project file

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
    } elseif {$opt in [list tab {*}$OPTS]} {
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
  if {$oldname ne $fname} {catch {file delete $oldname}}
}
#_______________________

proc project::SaveNotes {} {
  # Saves a file of notes.

  namespace upvar ::alited obDl2 obDl2
  variable fnotes
  if {$fnotes ne {}} {
    set fcont [[$obDl2 TexPrj] get 1.0 {end -1c}]
    ::apave::writeTextFile $fnotes fcont
  }
}

# ________________________ GUI helpers _________________________ #

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

proc project::ValidProject {} {
  # Checks if a project's options are valid.

  namespace upvar ::alited al al obDl2 obDl2
  if {[string trim $al(prjname)] eq {} || ![CheckProjectName]} {
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

proc project::Selected {what {domsg yes}} {
  # Gets a currently selected project's index.
  #   what - if "index", selected item's index is returned
  #   domsg - if "no", no message displayed if there is no selected project

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  set tree [$obDl2 TreePrj]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq "" \
  && $domsg} {
    alited::Message2 $al(MC,prjsel) 4
  }
  if {$isel ne {} && $what eq {index}} {
    set isel [$tree index $isel]
  }
  return $isel
}
#_______________________

proc project::Select {{item ""}} {
  # Handles a selection in a list of projects.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo 
  variable OPTS
  variable fnotes
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
    set fnotes [file join $::alited::PRJDIR $prj-notes.txt]
    set wtxt [$obDl2 TexPrj]
    $wtxt delete 1.0 end
    if {[file exists $fnotes]} {
      $wtxt insert end [::apave::readTextFile $fnotes]
    }
    $wtxt edit reset; $wtxt edit modified no
    foreach opt $OPTS {
      set al($opt) $prjinfo($prj,$opt)
    }
    set al(tablist) $prjinfo($prj,tablist)
    TabFileInfo
    if {[$tree selection] ne $item} {
      $tree selection set $item
    }
    $tree see $item
    $tree focus $item
  }
}

# ________________________ Buttons for project list _________________________ #

proc project::Add {} {
  # "Add project" button's handler.

  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo
  variable OPTS
  if {![ValidProject]} return
  set pname $al(prjname)
  if {[lsearch -exact $prjlist $pname]>-1} {
    focus [$obDl2 EntName]
    set msg [string map [list %n $pname] $al(MC,prjexists)]
    alited::Message2 $msg 4
    return
  }
  if {![SaveCurrFileList $al(MC,prjadd) yes]} return
  set al(tabs) $al(tablist)
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
  PutProjectOpts $al(prjfile) $al(prjfile)
  GetProjects
  UpdateTree
  Select $prjinfo($pname,ID)
  alited::Message2 [string map [list %n $pname] $al(MC,prjnew)]
}
#_______________________

proc project::Change {{askappend yes} {isel -1}} {
  # "Change project" button's handler.

  namespace upvar ::alited al al obDl2 obDl2
  variable data
  variable prjlist
  variable prjinfo
  if {$isel==-1 && [set isel [Selected index]] eq ""} return
  if {![ValidProject]} return
  for {set i 0} {$i<[llength $prjlist]} {incr i} {
    if {$i!=$isel && [lindex $prjlist $i] eq $al(prjname)} {
      set msg [string map [list %n $al(prjname)] $al(MC,prjexists)]
      alited::Message2 $msg 4
      return
    }
  }
  if {$askappend && ![SaveCurrFileList $al(MC,prjchg)]} return
  set oldprj [lindex $prjlist $isel]
  set newprj $al(prjname)
  catch {unset prjinfo($oldprj,tablist)}
  set prjinfo($newprj,tablist) $al(tablist)
  set oldname [ProjectFileName $oldprj]
  set prjlist [lreplace $prjlist $isel $isel $newprj]
  set fname [ProjectFileName $newprj]
  if {$newprj eq $data(prjname)} SaveSettings
  PutProjectOpts $fname $oldname
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
  variable data
  if {[set isel [Selected index]] eq ""} return
  set geo "-geometry root=$win"
  set nametodel [lindex $prjlist $isel]
  if {$nametodel eq $data(prjname)} {
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
  if {[set llen [llength $prjlist]] && $isel>=$llen} {
    set isel [incr llen -1]
  }
  GetProjects
  UpdateTree
  Select $isel
  alited::Message2 [string map [list %n $nametodel] $al(MC,prjrem)]
}

# ________________________ Buttons _________________________ #

proc project::Ok {args} {
  # 'OK' button handler.
  #   args - possible arguments

  namespace upvar ::alited al al obDl2 obDl2 obPav obPav
  variable win
  variable prjlist
  variable prjinfo
  variable data
  set msec [clock milliseconds]
  if {($msec-$data(_MSEC))<10000} {
    # disables entering twice (at multiple double-clicks)
    # 10 sec. of clicking seems to be enough at opening a file
    return
  }
  set data(_MSEC) $msec
  if {[set isel [Selected index]] eq {} || ![ValidProject]} {
    focus [$obDl2 TreePrj]
    return
  }
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
  set pname [string trim $al(prjname)]
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
  after idle alited::main::ShowText
  [$obPav Tree] selection set {}  ;# new project - no group selected
  if {!$al(TREE,isunits)} {after idle alited::tree::RecreateTree}
  alited::favor::ShowFavVisit
  $obDl2 res $win 1
  return
}
#_______________________

proc project::Cancel {args} {
  # 'Cancel' button handler.
  #   args - possible arguments

  namespace upvar ::alited obDl2 obDl2
  variable win
  SaveData
  RestoreSettings
  $obDl2 res $win 0
}
#_______________________

proc project::Help {} {
  # 'Help' button handler.

  variable win
  alited::Help $win
}

# ________________________ GUI _________________________ #

proc project::MainFrame {} {
  # Creates a main frame of "Project" dialogue.

  return {
    {fraTreePrj - - 10 1 {-st nswe -pady 4 -rw 1}}
    {.TreePrj - - - - {pack -side left -expand 1 -fill both} {-h 16 -show headings -columns {C1} -displaycolumns {C1}}}
    {.sbvPrjs .TreePrj L - - {pack -side left -fill both}}
    {fraR fraTreePrj L 10 1 {-st nsew -cw 1 -pady 4}}
    {fraR.Nbk - - - - {pack -side top -expand 1 -fill both} {
      f1 {-text {$al(MC,info)}}
      f2 {-text {$al(MC,prjOptions)}}
      -traverse yes -select f1
    }}
    {fraB1 fraTreePrj T 1 1 {-st nsew}}
    {.buTad - - - - {pack -side left -anchor n} {-takefocus 0 -com ::alited::project::Add -tip {$alited::al(MC,prjadd)} -image alimg_add-big}}
    {.buTch - - - - {pack -side left} {-takefocus 0 -com ::alited::project::Change -tip {$alited::al(MC,prjchg)} -image alimg_change-big}}
    {.buTdel - - - - {pack -side left} {-takefocus 0 -com ::alited::project::Delete -tip {$alited::al(MC,prjdel)} -image alimg_delete-big}}
    {LabMess fraB1 L 1 1 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {seh fraB1 T 1 2 {-st nsew -pady 2}}
    {fraB2 seh T 1 2 {-st nsew} {-padding {2 2}}}
    {.butHelp - - - - {pack -side left -anchor s -padx 2} {-t {$alited::al(MC,help)} -command ::alited::project::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 50}}
    {.butOK - - - - {pack -side left -anchor s -padx 2} {-t {$alited::al(MC,select)} -command ::alited::project::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -command ::alited::project::Cancel}}
  }
}
#_______________________

proc project::Tab1 {} {
  # Creates a main tab of "Project".

  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labName - - 1 1 {-st w -pady 1 -padx 3} {-t {$al(MC,prjName)}}}
    {.EntName .labName L 1 1 {-st sw -pady 5} {-tvar alited::al(prjname) -w 50}}
    {.labDir .labName T 1 1 {-st w -pady 8 -padx 3} {-t "Root directory:"}}
    {.Dir .labDir L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(prjroot) -w 50}}
    {.labIgn .labDir T 1 1 {-st w -pady 8 -padx 3} {-t "Skip subdirectories:"}}
    {.entIgn .labIgn L 1 9 {-st sw -pady 5 -padx 3} {-tvar alited::al(prjdirign) -w 50}}
    {lab fra1 T 1 2 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra2 lab T 1 2 {-st nsew -rw 1 -cw 1}}
    {.TexPrj - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 40 -wrap word -tabnext $alited::project::win.fra.fraB2.butHelp -tip {$alited::al(MC,notes)}}}
    {.sbv .TexPrj L - - {pack -side left}}
  }
}
#_______________________

proc project::Tab2 {} {
  # Creates Options tab of "Project".

  return {
    {v_ - - 1 10}
    {fra2 v_ T 1 2 {-st nsew -cw 1}}
    {.labEOL - - 1 1 {-st w -pady 1 -padx 3} {-t "End of line:"}}
    {.cbxEOL .labEOL L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjEOL) -values {{} LF CR CRLF} -w 9 -state readonly}}
    {.labIndent .labEOL T 1 1 {-st w -pady 1 -padx 3} {-t "Indentation:"}}
    {.spxIndent .labIndent L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjindent) -w 9 -from 2 -to 8 -justify center}}
    {.chbIndAuto .spxIndent L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(prjindentAuto) -t "Auto detection"}}
    {.labRedunit .labIndent T 1 1 {-st w -pady 1 -padx 3} {-t "Unit lines per 1 red bar:"}}
    {.spxRedunit .labRedunit L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjredunit) -w 9 -from 10 -to 100 -justify center}}
    {.labMult .labRedunit T 1 1 {-st w -pady 1 -padx 3} {-t "Multi-line strings:" -tip {$alited::al(MC,notrecomm)}}}
    {.swiMult .labMult L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(prjmultiline) -tip {$alited::al(MC,notrecomm)}}}
    {.labFlist .labMult T 1 1 {-pady 3 -padx 3} {-t "List of files:"}}
    {fraFlist .labFlist T 1 2 {-st nswe -padx 3 -cw 1 -rw 1}}
    {.LbxFlist - - - - {pack -side left -fill both -expand 1} {-takefocus 0}}
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
  variable data
  set data(_MSEC) 0
  $obDl2 makeWindow $win.fra "$al(MC,projects) :: $::alited::PRJDIR"
  $obDl2 paveWindow \
    $win.fra [MainFrame] \
    $win.fra.fraR.nbk.f1 [Tab1] \
    $win.fra.fraR.nbk.f2 [Tab2]
  set tree [$obDl2 TreePrj]
  $tree heading C1 -text $al(MC,projects)
  if {$oldTab ne ""} {
    $win.fra.fraR.nbk select $oldTab
  }
  UpdateTree
  bind $tree <<TreeviewSelect>> "::alited::project::Select"
  bind $tree <Delete> "::alited::project::Delete"
  bind $tree <Double-Button-1> "::alited::project::Ok"
  bind $tree <Return> "::alited::project::Ok"
  if {$ilast>-1} {Select $ilast}
  if {$minsize eq ""} {      ;# save default min.sizes
    after idle [list after 100 {
      set ::alited::project::minsize "-minsize {[winfo width $::alited::project::win] [winfo height $::alited::project::win]}"
    }]
  }
  bind [$obDl2 TexPrj] <FocusOut> "alited::project::SaveNotes"
  set res [$obDl2 showModal $win  -geometry $geo {*}$minsize \
    -onclose ::alited::project::Cancel -focus [$obDl2 TreePrj]]
  set oldTab [$win.fra.fraR.nbk select]
  if {[llength $res] < 2} {set res ""}
  set geo [wm geometry $win] ;# save the new geometry of the dialogue
  destroy $win
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
