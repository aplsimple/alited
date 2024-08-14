###########################################################
# Name:    project.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    04/28/2021
# Brief:   Handles project settings.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval project {

  # apave object of Projects
  variable obPrj pavedProject

  # Projects dialogue's path
  variable win $::alited::al(WIN).diaPrj

  # list of projects
  variable prjlist [list]

  # initial geometry of Projects dialogue (centered in the main form)
  variable geo root=$::alited::al(WIN)

  # saved index of last selected project
  variable ilast -1

  # saved tab of Projects dialogue
  variable oldTab {}

  # data of projects
  variable prjinfo; array set prjinfo [list]
  foreach _ $::alited::OPTS {
    catch {set prjinfo(*DEFAULT*,$_) $::alited::al(DEFAULT,$_)}  ;# default options
  }

  # data of currently open project (to save/restore)
  variable curinfo; array set curinfo [list]

  # calendar's data
  variable klnddata; array set klnddata [list]
  set klnddata(dateformat) {%Y/%m/%d}

  # todo message and its project
  variable msgtodo {}
  variable itemtodo {}

  # flag "projects changed"
  variable updateGUI no

  # total of project files
  variable totalfiles 0

  # separator for commands in Notes
  variable COMSEP \t

  # filter for project files
  variable filefilter {}
  variable casefilter 0
  variable savedfilefilter $filefilter
  variable savedcasefilter $casefilter

  # flag "save alited.ini"
  variable saveini no
}

# ________________________ Common _________________________ #

proc project::ProjectName {fname} {
  # Gets a project name from its file name.

  namespace upvar ::alited PRJEXT PRJEXT
  set fname [file tail $fname]
  if {[string match -nocase *$PRJEXT $fname]} {
    set fname [file rootname $fname]
  }
  return $fname
}
#_______________________

proc project::ProjectFileName {name} {
  # Gets a project file name from a project's name.

  namespace upvar ::alited PRJDIR PRJDIR PRJEXT PRJEXT
  set name [ProjectName [string trim $name]]
  return [file normalize [file join $PRJDIR "$name$PRJEXT"]]
}
#_______________________

proc project::CheckProjectName {} {
  # Removes spec.characters from a project name (sort of normalizing it).
  # Returns yes, if the name is "correct" (no char replacements made).

  namespace upvar ::alited al al
  set oldname $al(prjname)
  set al(prjname) [::apave::NormalizeFileName $al(prjname)]
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
  alited::tree::PrepareDirectoryContents
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
#_______________________

proc project::ClockFormat {secs} {
  # Formats date in seconds.
  #   secs - date in seconds

  variable klnddata
  return [clock format $secs -format $klnddata(dateformat)]
}
#_______________________

proc project::ClockScan {d} {
  # Scans date to get date in seconds.
  #   d - date

  variable klnddata
  return [clock scan $d -format $klnddata(dateformat)]
}
#_______________________

proc project::ClockYMD {d} {
  # Extracts year, month, day from date.
  #   d - date

  return [split [ClockFormat $d] /]
}
#_______________________

proc project::IsOutdated {prj {todo no}} {
  # Checks for outdated TODOs of a project.
  #   prj - project's name
  #   todo - if yes, gets also date and todo
  # Returns 0, if no todo for the project, 1 otherwise; if todo=yes, adds also date and todo outdated (if there is).

  set rems [SortRems [ReadRems $prj]]
  set res [lindex $rems 2]
  if {$todo} {
    lappend res {*}[lindex $rems 1 0]
  }
  return $res
}
#_______________________

proc project::CheckOutdated {} {
  # Checks for outdated TODOs of all projects except for the current.
  # Return {} or a name of project with outdated TODOs.

  variable prjlist
  foreach prj $prjlist {
    if {$prj ne $::alited::al(prjname)} {
      if {[IsOutdated $prj]} {return $prj}
    }
  }
  return {}
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

proc project::SaveSettings {} {
  # Saves project settings to curinfo array.

  namespace upvar ::alited al al OPTS OPTS
  variable curinfo
  foreach v $OPTS {
    set curinfo($v) $al($v)
  }
  set curinfo(prjfile) $al(prjfile)
}
#_______________________

proc project::RestoreSettings {} {
  # Restores project settings from curinfo array.

  namespace upvar ::alited al al OPTS OPTS
  variable curinfo
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

  namespace upvar ::alited al al OPTS OPTS DIR DIR
  variable prjlist
  variable prjinfo
  variable curinfo
  set pname [ProjectName $fname]
  # save project names to 'prjlist' variable to display it by treeview widget
  lappend prjlist $pname
  # save project files' settings in prjinfo array
  set filecont [readTextFile $fname]
  foreach opt $OPTS {
    catch {set prjinfo($pname,$opt) $prjinfo(*DEFAULT*,$opt)}  ;# defaults
  }
  set prjinfo($pname,tablist) [list]
  if {[set currentprj [expr {$curinfo(prjname) eq $pname}]]} {
    foreach tab [alited::bar::BAR listTab] {
      set tid [lindex $tab 0]
      if {[set val [alited::bar::FileName $tid]] ne {}} {
        lappend prjinfo($pname,tablist) $val
      }
    }
  }
  set prjinfo($pname,prjroot) $DIR
  foreach line [textsplit $filecont] {
    lassign [GetOptVal $line] opt val
    if {[lsearch $OPTS $opt]>-1} {
      set prjinfo($pname,$opt) [alited::ProcEOL $val in]
    } elseif {$opt eq {tab} && !$currentprj && $val ne {}} {
      lappend prjinfo($pname,tablist) $val
    }
  }
  set prjinfo($pname,prjfile) $fname
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

  namespace upvar ::alited al al OPTS OPTS
  variable prjinfo
  set filecont [readTextFile $oldname]
  if {$filecont eq {}} {
    alited::ini::SaveIniPrj
    set filecont [readTextFile $oldname]
  }
  set newcont {}
  foreach line [textsplit $filecont] {
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
          set val [set al($opt)]
          append line \n $opt= $val
          set prjinfo($al(prjname),$opt) [alited::ProcEOL $val in]
        }
      }
    }
    append newcont $line \n
  }
  writeTextFile $fname newcont
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

proc project::CurrProject {} {
  # Gets a current project name, from a current item of project list.

  variable obPrj
  variable prjlist
  set prj {}
  catch {
    set tree [$obPrj TreePrj]
    set item [Selected item no]
    set isel [$tree index $item]
    set prj [lindex $prjlist $isel]
  }
  return $prj
}
#_______________________

proc project::SaveNotes {{prj ""}} {
  #  For a current item of project list, saves a file of notes and Commands tab's commands.
  #   prj - project's name

  namespace upvar ::alited al al
  variable obPrj
  variable klnddata
  variable COMSEP
  if {$prj eq {}} {set prj $klnddata(SAVEPRJ)}
  if {$prj ne {}} {
    set fnotes [NotesFile $prj]
    set fcont [string trimright [[$obPrj TexPrj] get 1.0 end]]
    if {[catch {set indent [string repeat { } $::alited::al(prjindent)]}]} {set indent {    }}
    set fcont [string map [list $COMSEP $indent] $fcont]
    set fcontOrig $fcont
    for {set i 1} {$i<=$al(cmdNum)} {incr i} {
      set com [string trim $al(PTP,run$i)]
      set al(PTP,run$i) {}
      if {$com ne {}} {
        incr irun   ;# starting commands from #1
        append fcont \nrun$irun$COMSEP$al(PTP,runch$i)$COMSEP$com
        set al(PTP,run$i) $com
      }
    }
    for {set i 1} {$i<=$al(cmdNum)} {incr i} {
      set com [string trim $al(PTP,com$i)]
      set al(PTP,com$i) {}
      if {$com ne {}} {
        incr irun   ;# starting commands from #1
        append fcont \nrun$irun$COMSEP$al(PTP,comch$i)$COMSEP$COMSEP$com
        set al(PTP,com$i) $com
      }
    }
    if {$fcontOrig eq {} && $fcont ne {}} {
      set fcont __$al(MC,coms)__$fcont
    }
    writeTextFile $fnotes fcont 0 0
  }
}
#_______________________

proc project::NotesFile {prj} {
  # Gets a file name of notes.
  #   prj - project's name

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
    set res [readTextFile $frems]
  } else {
    set res [list]
  }
  return $res
}
#_______________________

proc project::SortRems {rems} {
  # Sorts reminders by date.
  #   rems - list of reminders
  # Returns a list of reminder date before current date, sorted list, flag of outdated reminder.

  set tmp [list]
  set dmin [set outdated 0]
  set dcur [clock add [KlndInDate] $::alited::al(todoahead) day]
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
    lappend rems [list [ClockFormat $d] $text]
  }
  if {$dmin} {
    if {$dmin<[clock seconds]} {
      set outdated 1 ;# current day reached
    } elseif {$dmin<$dcur} {
      set outdated 2 ;# "ahead" day reached
    }
  }
  list $dmin $rems $outdated
}
#_______________________

proc project::Klnd_save {} {
  # Saves a reminder on a date.

  variable obPrj
  variable prjinfo
  variable klnddata
  set wtxt [$obPrj TexKlnd]
  if {[set prjname $klnddata(SAVEPRJ)] eq {}} return
  set text [string trim [$wtxt get 1.0 end]]
  set date $klnddata(SAVEDATE)
  set info [list $date $text "TODO opt."]  ;# + possible options for future
  set i [KlndSearch $date $prjname]
  if {$text eq {}} {
    if {$i>-1} {
      set prjinfo($prjname,prjrem) [lreplace $prjinfo($prjname,prjrem) $i $i]
    }
    KlndBorderText
  } elseif {$i>-1} {
    set prjinfo($prjname,prjrem) [lreplace $prjinfo($prjname,prjrem) $i $i $info]
  } else {
    lappend prjinfo($prjname,prjrem) $info
  }
  ::klnd::update {} {} {} $prjinfo($prjname,prjrem)
  set fcont $prjinfo($prjname,prjrem)
  writeTextFile [RemsFile $prjname] fcont 0 0
}
#_______________________

proc project::KlndBorderText {{clr {}}} {
  # Highlights/unhighlights a reminder's border.
  #   clr - color of border

  variable obPrj
  if {$clr eq {}} {set clr [lindex [obj csGet] 8]}
  [$obPrj TexKlnd] configure -highlightbackground $clr
}

# ________________________ GUI helpers _________________________ #

proc project::ReadNotes {prj} {
  # Reads notes of a project and commands for Commands tab.
  #   prj - project's name

  namespace upvar ::alited al al
  variable obPrj
  variable COMSEP
  for {set i 1} {$i<=$al(cmdNum)} {incr i} {
    set al(PTP,run$i) [set al(PTP,com$i) {}]
    set al(PTP,runch$i) [set al(PTP,comch$i) 0]
  }
  set al(PTP,chbClearRun) 0
  set al(PTP,chbClearCom) 0
  set irun [set icom 0]
  set wtxt [$obPrj TexPrj]
  $wtxt delete 1.0 end
  set fnotes [NotesFile $prj]
  if {[file exists $fnotes]} {
    set cont [readTextFile $fnotes]
    if {[set ir [string first run1$COMSEP $cont]]>-1} {
      # get commands for Commands tab (project's and common)
      foreach com [split [string range $cont $i end] \n] {
        lassign [split $com $COMSEP] run ch com1 com2
        set ch [string is true -strict $ch]
        if {$com1 ne {}} {
          set al(PTP,run[incr irun]) $com1
          if {$ch} {set al(PTP,runch$irun) [set al(PTP,chbClearRun) 1]}
        } elseif {$com2 ne {}} {
          set al(PTP,com[incr icom]) $com2
          if {$ch} {set al(PTP,comch$icom) [set al(PTP,chbClearCom) 1]}
        }
      }
      set cont [string range $cont 0 $ir-1]
    }
    set cont [string trim $cont]
    if {$cont ne {}} {$wtxt insert end $cont}
  }
  $wtxt edit reset; $wtxt edit modified no
}
#_______________________

proc project::SelectedPrj {item} {
  # Gets a project name of selected item.
  #   item - selected item

  variable obPrj
  variable prjlist
  variable prjinfo
  set tree [$obPrj TreePrj]
  if {[string is digit $item]} {  ;# the item is an index
    if {$item<0 || $item>=[llength $prjlist]} {return {}}
    set prj [lindex $prjlist $item]
    set item $prjinfo($prj,ID)
  } elseif {![$tree exists $item]} {
    return {}
  }
  set isel [$tree index $item]
  if {$isel<0 || $isel>=[llength $prjlist]} {return {}}
  list $tree $item [lindex $prjlist $isel]
}
#_______________________

proc project::Select {{item ""}} {
  # Handles a selection in a list of projects.

  namespace upvar ::alited al al OPTS OPTS
  variable obPrj
  variable prjinfo
  variable klnddata
  if {$item eq {}} {set item [Selected item no]}
  if {$item ne {}} {
    lassign [SelectedPrj $item] tree item prj
    if {$prj eq {}} return
    ReadNotes $prj
    lassign [SortRems [ReadRems $prj]] dmin prjinfo($prj,prjrem)
    foreach opt $OPTS {
      if {[catch {set al($opt) $prjinfo($prj,$opt)} e]} {
        Message $e
        return
      }
    }
    set al(tablist) $prjinfo($prj,tablist)
    TabFileInfo
    if {[$tree selection] ne $item} {
      $tree selection set $item
    }
    if {$dmin>0} {
      KlndDayRem $dmin
    } else {
      KlndDay [clock seconds] no
      KlndBorderText
    }
    ::klnd::blinking no
    set klnddata(SAVEDATE) {}
    catch {after cancel $klnddata(AFTERKLND)}
    set klnddata(AFTERKLND) [after 200 alited::project::KlndUpdate]
    [$obPrj Labprj] configure -text [msgcat::mc {For project}]\ $al(prjname)
    set tip [string map [list %f "$al(MC,prjName) $al(prjname)"] $al(MC,alloffile)]
    ::baltip tip [$obPrj ChbClearRun] $tip
    after 200 "$tree see $item; $tree focus $item"
    CheckPrjUseLeaf
  }
}
#_______________________

proc project::Selected {what {domsg yes}} {
  # Gets a currently selected project's index.
  #   what - if "index", selected item's index is returned
  #   domsg - if "no", no message displayed if there is no selected project

  variable obPrj
  variable prjlist
  set tree [$obPrj TreePrj]
  if {[set isel [$tree selection]] eq {} && [set isel [$tree focus]] eq {} && $domsg} {
    Message $::alited::al(MC,prjsel) 4
  }
  if {$isel ne {} && $what eq {index}} {
    set isel [$tree index $isel]
  }
  return $isel
}
#_______________________

proc project::UpdateTree {} {
  # Fills a list of projects.

  variable obPrj
  variable prjlist
  variable prjinfo
  set tree [$obPrj TreePrj]
  $tree delete [$tree children {}]
  foreach prj $prjlist {
    set prjinfo($prj,ID) [$tree insert {} end -values [list $prj]]
  }
}
#_______________________

proc project::FocusInTab {tab wid} {
  # Focuses on a widget in a tab.
  #   tab - the tab's path
  #   wid - the widget's path

  variable win
  $win.fra.fraR.nbk select $win.fra.fraR.nbk.$tab
  focus $wid
}
#_______________________

proc project::CheckNewDir {} {
  # Checks if the root directory exists. If no, tries to create it.
  # Returns yes, if all is OK.

  namespace upvar ::alited al al
  variable obPrj
  variable win
  if {![file exists $al(prjroot)]} {
    FocusInTab f1 [$obPrj chooserPath Dir]
    set msg [string map [list %d $al(prjroot)] \
      [msgcat::mc "Directory \"%d\"\ndoesn't exist.\n\nCreate it?"]]
    if {![alited::msg yesno ques $msg YES -geometry root=$win]} {
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

  namespace upvar ::alited al al
  variable obPrj
  variable prjlist
  set pname $al(prjname)
  if {[lsearch -exact $prjlist $pname]>-1} {
    if {$msgOnExist} {
      FocusInTab f1 [$obPrj EntName]
      set msg [string map [list %n $pname] $al(MC,prjexists)]
      Message $msg 4
    }
  } else {
    if {!$msgOnExist} {
      FocusInTab f1 [$obPrj EntName]
      set msg [msgcat::mc \
        "A project \"%n\" doesn't exists. Hit \[+\] button to create it."]
      set msg [string map [list %n $pname] $msg]
      Message $msg 4
    }
    set pname {}
  }
  return $pname
}
#_______________________

proc project::ValidProject {} {
  # Checks if a project's options are valid.

  namespace upvar ::alited al al
  variable obPrj
  variable totalfiles
  set al(prjname) [string trim $al(prjname)]
  if {$al(prjname) eq {} || ![CheckProjectName]} {
    bell
    FocusInTab f1 [$obPrj EntName]
    return no
  }
  if {$al(prjroot) eq {}} {
    bell
    FocusInTab f1 [$obPrj chooserPath Dir]
    return no
  }
  if {$al(prjuseleafRE) && $al(prjleafRE) eq {}} {
    bell
    FocusInTab f2 [$obPrj EntLf]
    return no
  }
  set al(prjroot) [file nativename $al(prjroot)]
  if {![CheckNewDir]} {return no}
  if {$al(prjindent)<0 || $al(prjindent)>8} {set al(prjindent) 2}
  if {$al(prjredunit)<$al(minredunit) || $al(prjredunit)>100} {set al(prjredunit) 20}
  set msg [string map [list %d $al(prjroot)] \
    [msgcat::mc {Checking %d. Wait a little...}]]
  Message $msg 5
  alited::tree::PrepareDirectoryContents
  set totalfiles [llength [alited::tree::GetDirectoryContents $al(prjroot)]]
  if {$totalfiles >= $al(MAXFILES)} {
    set msg [string map [list %n $al(MAXFILES)] \
      [msgcat::mc {Too big directory for a project: %n files or more.}]]
    Message $msg 4
    set res no
  } else {
    Message {}
    set res yes
  }
  return $res
}
#_______________________

proc project::CheckPrjLeaf {} {
  # Checks "Regexp of a leaf" field.

  namespace upvar ::alited al al
  if {$al(prjleafRE) eq {}} {
    set al(prjleafRE) [string trimright $al(RE,leaf)]
  }
}
#_______________________

proc project::CheckPrjUseLeaf {} {
  # Enables/disables the "Regexp of a leaf" field.

  namespace upvar ::alited al al
  variable obPrj
  CheckPrjLeaf
  set al(prjuseleafRE) [string is true -strict $al(prjuseleafRE)]
  if {$al(prjuseleafRE)} {set _ normal} {set _ disabled}
  [$obPrj EntLf] configure -state $_
}
#_______________________

proc project::StdLeafRE {} {
  # Sets standard RE for leaf unit.

  namespace upvar ::alited al al
  set al(prjleafRE) $al(RE,leafDEF)
}
#_______________________

proc project::KlndDay {dsec {doblink yes}} {
  # Selects a date of reminder.
  #   dsec - date in seconds to select
  #   doblink - if yes, make the month blink

  lassign [ClockYMD $dsec] y m d
  set m [string trimleft $m { 0}]
  set d [string trimleft $d { 0}]
  ::klnd::selectedDay {} $y $m $d $doblink
}
#_______________________

proc project::KlndDayRem {dmin} {
  # Selects a date of reminder before a current one.
  #   dmin - date in seconds to select

  KlndDay $dmin
  after idle {::alited::project::KlndBorderText red}
}
#_______________________

proc project::Message {msg {mode 2}} {
  # Displays a message in statusbar of projects dialogue.
  #   msg - message
  #   mode - mode of Message

  variable obPrj
  alited::Message $msg $mode [$obPrj LabMess]
}
#_______________________

proc project::KeyOnTree {K} {
  # Handles key press on the tree.
  #   K - key

  variable prjlist
  Message {}
  set icur [Selected index no]
  if {![string is integer -strict $icur]} return
  foreach i [list [incr icur] 0] {
    foreach pr [lrange $prjlist $i end] {
      if {![string compare -nocase $K [string index $pr 0]]} {
        Select $i
        return
      }
      incr i
    }
  }
}
#_______________________

proc project::focusTree {} {
  # Sets focus on the treeview.

  variable win
  variable obPrj
  focus $win
  focus [$obPrj TreePrj]
}
#_______________________

proc project::ValidateIni {V} {
  # Validates values of alited.ini.
  #   V - %V wildcard of -validatecommand

  variable saveini
  set saveini yes
  if {$V eq {focusout}} {
    alited::ini::SaveIni
    set saveini no
  }
  return 1
}

# ________________________ Files tab's procs _________________________ #

proc project::SelFiles {} {
  # Checks for a selection of file listbox.
  # Returns: list of listbox's path and the selection or {}.

  variable obPrj
  set lbx [$obPrj LbxFlist]
  if {![llength [set selidx [$lbx curselection]]]} {
    Message [msgcat::mc {No selected files}] 4
    return {}
  }
  list $lbx $selidx
}
#_______________________

proc project::CurrentFile {} {
  # Gets a current file of file listbox.
  # Returns file name of first selected file or 1st in the list, if no selection.

  variable obPrj
  set lbx [$obPrj LbxFlist]
  if {[catch {
    if {[llength [set selidx [$lbx curselection]]]} {
      set idx [lindex $selidx 0]
    } else {
      set idx 0
    }
    set res [$lbx get $idx]
  }]} {
    set res {}
  }
  return $res
}
#_______________________

proc project::OpenFile {y} {
  # Opens a file of listbox after double clicking.
  #   y - y-coordinate of clicking

  variable obPrj
  set lbx [$obPrj LbxFlist]
  set selid [$lbx nearest $y]
  if {$selid != -1} {
    $lbx selection clear 0 end
    $lbx selection set $selid
    OpenSelFiles no
  }
}
#_______________________

proc project::OpenSelFiles {{showmsg yes}} {
  # Opens selected files of listbox.
  #   showmsg - if yes, shows a message
  # Files are open in a currently open project.

  namespace upvar ::alited al al
  variable prjinfo
  variable curinfo
  set prj $al(prjname)
  set cprj $curinfo(prjname)
  set al(prjname) $curinfo(prjname)
  lassign [SelFiles] lbx selidx
  if {$lbx ne {}} {
    update
    set fnames [list]
    set balloon {}
    foreach idx [lreverse $selidx] {
      set fn [$lbx get $idx]
      if {[file exists $fn]} {
        lappend fnames $fn
        if {[lsearch -index 0 -exact $prjinfo($cprj,tablist) $fn]<0} {
          set prjinfo($cprj,tablist) [linsert $prjinfo($cprj,tablist) 0 $fn]
        }
      } else {
        set balloon $fn
      }
    }
    set llen [llength $fnames]
    if {$showmsg} {
      set msg [string map [list %n $llen] [msgcat::mc {Open files: %n}]]
      Message $msg 3
    }
    if {$llen} {
      alited::file::OpenFile $fnames yes yes alited::info::Put
    }
    if {$balloon ne {}} {
      after idle alited::Balloon1 $balloon
    }
  }
  set al(prjname) $prj
  afterOpenCloseFiles
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
      if {[alited::file::IsNoName $fname]} continue
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
    set al(prjname) $cprj
    if {$closecurr && [set TID [alited::bar::FileTID $fnamecurr]] ne {}} {
      alited::bar::BAR $TID close ;# this should be last to check for "No name" tab
    }
    alited::bar::BAR draw
    if {$prj eq $cprj} {
      set al(tablist) $prjinfo($cprj,tablist)
      TabFileInfo
    }
    set al(prjname) $prj
    afterOpenCloseFiles
  }
}
#_______________________

proc project::DetachSelFiles {} {
  # Detaches selected files.

  lassign [SelFiles] lbx selidx
  set fnames [list]
  if {$lbx ne {}} {
    foreach idx $selidx {lappend fnames [$lbx get $idx]}
  }
  alited::file::Detach $fnames
}
#_______________________

proc project::afterOpenCloseFiles {} {
  # Actions after opening/closing files.

  variable obPrj
  set flist [$obPrj LbxFlist]
  set fsels [$flist curselection]
  set item [Selected index]
  GetProjects
  UpdateTree
  Select $item
  focusTree
  foreach fsel $fsels {
    after 300 $flist selection set $fsel $fsel
  }
}
#_______________________

proc project::SelectAllFiles {} {
  # Selects all files of listbox.

  variable obPrj
  [$obPrj LbxFlist] selection set 0 end
}
#_______________________

proc project::LbxPopup {X Y} {
  # Runs a popup menu on the project files listbox.
  #   X - x-coordinate of mouse pointer
  #   Y - y-coordinate of mouse pointer

  variable obPrj
  variable filefilter
  set popm [$obPrj LbxFlist].popup
  catch {destroy $popm}
  lassign [SelFiles] lbx selidx
  if {$filefilter eq {}} {set state normal} {set state disabled}
  if {[llength $selidx]} {set stateS normal} {set stateS [set state disabled]}
  menu $popm -tearoff 0
  $popm add command -label $::alited::al(MC,openselfile) -command alited::project::OpenSelFiles -state $stateS
  $popm add command -label [msgcat::mc {Close Selected Files}] \
    -command alited::project::CloseSelFiles -state $state
  $popm add separator
  $popm add command -label $::alited::al(MC,detachsel) -command alited::project::DetachSelFiles -state $stateS
  $popm add separator
  $popm add command -label [msgcat::mc {Select All}] -command alited::project::SelectAllFiles -accelerator Ctrl+A
  baltip::sleep 1000
  $obPrj themePopup $popm
  tk_popup $popm $X $Y
}
#_______________________

proc project::ValidateDir {} {
  # Tries to get a project name at choosing root dir.

  namespace upvar ::alited al al
  update idletasks ;#  update ;# a bug of ttk?
  if {$al(prjname) eq {}} {
    set al(prjname) [file tail $al(prjroot)]
  }
  return yes
}
#_______________________

proc project::TipOnFile {idx} {
  # Shows info on a file in the file list as a tooltip.
  #   idx - item index

  variable obPrj
  set lbx [$obPrj LbxFlist]
  set item [$lbx get $idx]
  return [alited::file::FileStat $item]
}
#_______________________

proc project::PopupMenu {x y X Y} {
  # Opens a popup menu in the project list.
  #   x - x-coordinate to identify an item
  #   y - y-coordinate to identify an item
  #   X - x-coordinate of the click
  #   Y - x-coordinate of the click

  namespace upvar ::alited al al
  variable obPrj
  variable win
  set popm $win.popupmenu
  catch {destroy $popm}
  menu $popm -tearoff 0
  $popm add command -label $al(MC,prjadd) \
    -command alited::project::Add {*}[$obPrj iconA add]
  $popm add command -label $al(MC,prjchg) \
    -command alited::project::Change {*}[$obPrj iconA change]
  $popm add command -label $al(MC,prjdel1) \
    -command alited::project::Delete {*}[$obPrj iconA delete]
  $popm add separator
  $popm add command -label $al(MC,CrTemplPrj) \
    -command alited::project::Template {*}[$obPrj iconA plus]
  $popm add command -label $al(MC,ViewDir) \
    -command alited::project::ViewDir {*}[$obPrj iconA OpenFile]
  $obPrj themePopup $popm
  tk_popup $popm $X $Y
}
#_______________________

proc project::TabFileHeading {} {
  # Show Files tab's heading.

  variable obPrj
  set lbx [$obPrj LbxFlist]
  set txt [msgcat::mc {List of files (%n):}]
  set txt [string map [list %n [$lbx index end]] $txt]
  [$obPrj LabFlist] configure -text $txt
}
#_______________________

proc project::TabFileFill {flist} {
  # Fills a listbox of files.
  #   flist - file list

  variable obPrj
  set lbx [$obPrj LbxFlist]
  $lbx delete 0 end
  set savfname {}
  foreach tab [lsort -index 0 -dictionary $flist] {
    set fname [lindex [split $tab \t] 0]
    if {$savfname ne $fname} {  ;# no duplicates
      $lbx insert end $fname
      set savfname $fname
    }
  }
}
#_______________________

proc project::TabFileInfo {} {
  # Fills a listbox with a list of project files.

  variable filefilter
  if {$filefilter ne {}} {
    TabFileFilter
    return
  }
  TabFileFill $::alited::al(tablist)
  TabFileHeading
}
#_______________________

proc project::TabFileFilter {} {
  # Fills a listbox with a list of filtered files of all projects.

  variable filefilter
  variable casefilter
  variable prjlist
  variable prjinfo
  if {$filefilter eq {}} {
    TabFileInfo
    return
  }
  set alltablist [list]
  if {$casefilter} {set nocase {}} {set nocase -nocase}
  foreach prj $prjlist {
    foreach tab $prjinfo($prj,tablist) {
      set fname [lindex [split $tab \t] 0]
      if {[string match {*}$nocase *$filefilter* $fname]} {
        lappend alltablist $tab
      }
    }
  }
  TabFileFill $alltablist
  TabFileHeading
}
#_______________________

proc project::postValidateFilter {} {
  # Postvalidates the file filter change.

  variable filefilter
  variable casefilter
  variable savedfilefilter
  variable savedcasefilter
  if {$savedfilefilter ne $filefilter || $savedcasefilter ne $casefilter} {
    if {$filefilter eq {}} {
      TabFileInfo
    } else {
      TabFileFilter
    }
    set savedfilefilter $filefilter
    set savedcasefilter $casefilter
  }
}
#_______________________

proc project::preValidateFilter {} {
  # Prevalidates the file filter change.

  after idle alited::project::postValidateFilter
  return 1
}

# ________________________ Buttons for project list _________________________ #

proc project::Add {{showtotals yes}} {
  # "Add project" button's handler.
  #   showtotals - if yes, shows total number of files
  # Returns yes, if the project is successfully added.

  namespace upvar ::alited al al OPTS OPTS
  variable prjlist
  variable prjinfo
  SaveNotes
  if {![ValidProject] || [ExistingProject yes] ne {}} {return no}
  set al(tablist) [list]
  TabFileInfo
  set pname $al(prjname)
  set proot $al(prjroot)
  set al(prjfile) [ProjectFileName $pname]
  set al(prjbeforerun) {}
  if {$al(PRJDEFAULT)} {
    # use project defaults from "Setup/Common/Projects", except for prjname & prjroot
    foreach opt $OPTS {
      catch {set al($opt) $al(DEFAULT,$opt)}
    }
    set al(prjname) $pname
    set al(prjroot) $proot
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
  UpdateMsg [string map [list %n $pname] $al(MC,prjnew)] $showtotals
  return yes
}
#_______________________

proc project::Change {} {
  # "Change project" button's handler.

  namespace upvar ::alited al al
  variable obPrj
  variable curinfo
  variable prjlist
  variable prjinfo
  variable updateGUI
  SaveNotes
  if {[set isel [Selected index]] eq {}} return
  if {![ValidProject]} return
  for {set i 0} {$i<[llength $prjlist]} {incr i} {
    if {$i!=$isel && [lindex $prjlist $i] eq $al(prjname)} {
      set msg [string map [list %n $al(prjname)] $al(MC,prjexists)]
      Message $msg 4
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
  set updateGUI yes
  UpdateMsg [string map [list %n [lindex $prjlist $isel]] $al(MC,prjupd)]
}
#_______________________

proc project::Delete {} {
  # "Delete project" button's handler.

  namespace upvar ::alited al al
  variable prjlist
  variable prjinfo
  variable win
  variable curinfo
  if {[set isel [Selected index]] eq {}} return
  set geo "-centerme $win"
  set nametodel [lindex $prjlist $isel]
  if {$nametodel eq $curinfo(prjname)} {
    Message $al(MC,prjcantdel) 4
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
  Message [string map [list %n $nametodel] $al(MC,prjdel2)] 3
}
#_______________________

proc project::Template {} {
  # Creates a project by template as set in Template tab.
  # The template can contain directories or files (indented for subdirectories).
  # The files satisfy glob-patterns: changelog*, license*, licence*, readme*.
  # See also: TplDefault

  namespace upvar ::alited al al
  variable obPrj
  variable curinfo
  # first, update the template list independently on errors
  UpdateTplLists
  # then check the template for correctness
  set wtpl [$obPrj TexTemplate]
  set namelist [set errmess {}]
  set margin [set indent [set spprev -1]]
  foreach name [split [$wtpl get 1.0 end] \n] {
    if {[set name [string trimright $name]] eq {}} continue
    if {[string trim $name] ne [::apave::NormalizeFileName $name]} {
      set errmess [string map [list %n $name] $al(MC,incorrname)]
      break
    }
    set sporig [$obPrj leadingSpaces $name]
    if {$margin<0} {set margin $sporig}
    set sp [$obPrj leadingSpaces [string range $name $margin end]]
    set name [string trimleft $name]
    set lastname {}  ;# root of project dir
    if {$sp || $margin>$sporig} {
      if {$indent<0} {set indent $sp}
      if {$margin>$sporig || $sp % $indent || $sp>($spprev+$indent)} {
        set errmess [string map [list %n $name] \
          [msgcat::mc {Incorrect indentation in Project template: %n}]]
        break
      }
      for {set i [llength $namelist]} {$i} {} {
        incr i -1
        lassign [lindex $namelist $i] n1 s1
        if {$s1<$sp} {
          set lastname $n1/
          break
        }
      }
    }
    lappend namelist [list [file nativename $lastname$name] $sp]
    set spprev $sp
  }
  if {"$errmess$namelist" eq {}} {
    set errmess {The project template is empty!}
  } elseif {[ExistingProject yes] ne {}} {
    return
  } elseif {[file exists $al(prjroot)]} {
    set errmess {The project directory already exists! It isn't created with templates.}
    FocusInTab f1 [$obPrj chooserPath Dir]
    Message [msgcat::mc $errmess] 4
    return
  }
  if {$errmess ne {}} {
    set namelist {}  ;# skip the following foreach
  } elseif {![Add no]} {
    return
  }
  # the template is OK -> create its dir/file tree
  foreach fn $namelist {
    set fn [lindex $fn 0]
    set fname [file join $al(prjroot) $fn]
    switch -glob -nocase -- [file tail $fn] {
      README* - CHANGELOG* {
        set err [catch {writeTextFile $fname {} 1} errmess]
      }
      LICENCE* - LICENSE* {
        set fname0 [file join $curinfo(prjroot) $fn]
        if {[file exists $fname0]} {
          set err [catch {file copy $fname0 $fname} errmess]
        } else {
          set err [catch {writeTextFile $fname {} 1} errmess]
        }
      }
      default {
        set err [catch {file mkdir $fname} errmess]
      }
    }
    if {$err} break
    set errmess {}
  }
  if {$errmess ne {}} {
    FocusInTab f3 $wtpl
    Message [msgcat::mc $errmess] 4
  }
}
#_______________________

proc project::UpdateMsg {msg {showtotals yes}} {
  # Displays a message on project updating.
  #   msg - message of action (add/change)
  #   showtotals - if yes, shows total number of files

  variable totalfiles
  if {$showtotals} {append msg " ($::alited::al(MC,files) : $totalfiles) "}
  Message $msg 3
}

# ________________________ Buttons _________________________ #

proc project::Ok {args} {
  # 'OK' button handler.
  #   args - possible arguments

  namespace upvar ::alited al al obPav obPav _dirtree _dirtree
  variable obPrj
  variable win
  variable prjlist
  variable prjinfo
  variable curinfo
  variable updateGUI
  alited::CloseDlg
  if {$curinfo(_NO2ENT)} {
    # disables entering twice (at multiple double-clicks)
    return
  }
  if {[set isel [Selected index]] eq {} || ![ValidProject]} {
    focusTree
    return
  }
  if {![ValidProject]} return
  if {[set pname [ExistingProject no]] eq {}} return
  if {[set N [llength [alited::bar::BAR listFlag m]]]} {
    set msg [msgcat::mc "All modified files (%n) will be saved.\n\nDo you agree?"]
    set msg [string map [list %n $N] $msg]
    if {![alited::msg yesno ques $msg YES -centerme $win]} return
  }
  if {![alited::file::SaveAll]} {
    $obPrj res $win 0
    return
  }
  if {[set N [llength [alited::bar::BAR cget -select]]]} {
    set msg [msgcat::mc "All selected files (%n) will remain open\nin the project you are switching to.\n\nDo you agree?"]
    set msg [string map [list %n $N] $msg]
    if {![alited::msg yesno ques $msg YES -centerme $win]} return
  }
  ::apave::withdraw $win
  set curinfo(_NO2ENT) 1
  set fname [ProjectFileName $pname]
  catch {alited::run::Cancel}  ;# possibly open Run dialogue: discard its settings
  RestoreSettings
  alited::ini::SaveIni
  # setting al(project::Ok) to skip "No name" & SaveCurrentIni at closing all
  if {[set al(project::Ok) 1]} {
    set tabs [alited::bar::BAR listTab]
    alited::file::CloseAll 1 -skipsel  ;# the selected tabs aren't closed
    set selfiles [list]                ;# -> get their file names to reopen afterwards
    foreach tid [alited::bar::BAR listFlag s] {
      lappend selfiles [alited::bar::FileName $tid]
    }
    alited::file::CloseAll 1   ;# close all tabs
    set comms [info commands]
    foreach tab $tabs {
      set tab [lindex $tab 0]
      foreach c $comms {
        if {[regexp "\[._\]$tab\(\[.\]internal\$|\$\)" $c]} {
          catch {destroy $c}
          catch {rename $c {}}
        }
      }
    }
    $obPav untouchWidgets clear *btsBar*  ;# remove bartabs references to the untouched
    set al(prjname) $pname
    set al(prjfile) $fname
    alited::ini::ReadIni $fname
    alited::bar::FillBar [$obPav BtsBar]
    set fnames [list]
    for {set i [llength $selfiles]} {$i} {} { ;# reopen selected files of previous project
      incr i -1
      set fname [lindex $selfiles $i]
      if {[alited::bar::FileTID $fname] eq {}} {
        lappend fnames $fname
      }
    }
    set TID [lindex [alited::bar::BAR listTab] $al(curtab) 0]
    catch {alited::bar::BAR $TID show no no}
    if {[llength $fnames]} {alited::file::OpenFile $fnames yes yes}
    alited::main::UpdateProjectInfo
    alited::ini::GetUserDirs
    alited::file::MakeThemHighlighted
    alited::favor::ShowFavVisit
    [$obPav Tree] selection set {}  ;# new project - no group selected
    update
  }
  unset al(project::Ok)
  alited::file::CheckForNew yes
  after 200 {after idle alited::main::FocusText}
  set _dirtree [list] ;# free its memory
  if {!$al(TREE,isunits)} {
    after 200 {after idle {alited::tree::RecreateTree; alited::tree::SeeTreeItem}}
  }
  set updateGUI no ;# GUI will be updating anyway
  $obPrj res $win 1
}
#_______________________

proc project::Cancel {args} {
  # 'Cancel' button handler.
  #   args - possible arguments

  variable obPrj
  variable win
  alited::CloseDlg
  SaveData
  SaveNotes
  RestoreSettings
  $obPrj res $win 0
}
#_______________________

proc project::Help {} {
  # 'Help' button handler.

  variable win
  set th {}
  set ts [string range [$win.fra.fraR.nbk select] end-1 end]
  switch $ts {
    f2 - f3 - f4 - f5 {set th [string index $ts end]}
  }
  alited::Help $win $th
}
#_______________________

proc project::HelpMe {} {
  # 'Help' for start.

  variable win
  alited::HelpMe $win
}
#_______________________

proc project::OnProjectEnter {} {
  # Actions on entering a project.

  variable win
  variable prjinfo
  variable msgtodo
  variable itemtodo
  lassign [SortRems $prjinfo($::alited::al(prjname),prjrem)] dmin - outdated
  if {$outdated} {
    set tab1 $win.fra.fraR.nbk.f1
    if {[$win.fra.fraR.nbk select] ne $tab1} {
      $win.fra.fraR.nbk select $tab1
    }
    KlndDayRem $dmin
    set msgtodo [msgcat::mc {TODO reminders for the past: %d.}]
    set dmin [ClockFormat $dmin]
    set msgtodo [string map [list %d $dmin] $msgtodo]
    Message $msgtodo 6
    set itemtodo [Selected item no]
  }
}
#_______________________

proc project::ProcMessage {} {
  # Handles clicking on message label.
  # Shows the message and if it is about TODO, selects the corresponding project.

  variable obPrj
  variable msgtodo
  variable itemtodo
  set msg [baltip cget [$obPrj LabMess] -text]
  if {$msgtodo eq $msg} {
    Message $msg 6
    Select $itemtodo
  } else {
    Message $msg 3
  }
}
#_______________________

proc project::ProjectEnter {} {
  # Processes double-clicking and pressing Enter on the project list.
  # Cancels selecting projects if there are old reminders.

  OnProjectEnter
  Ok
}
#_______________________

proc project::Klnd_button {ev} {
  # Fire an event handler (paste/undo/redo) on a reminder.
  #   ev - event to fire

  variable obPrj
  ::apave::eventOnText [$obPrj TexKlnd] $ev
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
#_______________________

proc project::Klnd_delete {} {
  # Clears a reminder.

  variable obPrj
  [$obPrj TexKlnd] replace 1.0 end {}
}
#_______________________

proc project::Klnd_moveTODO {wrem todo date} {
  # Moves current TODO to a new date.
  #   wrem - text widget of TODO
  #   todo - text of TODO
  #   date - new date (in seconds)

  variable klnddata
  # get TODO of new date
  lassign [ClockYMD $date] y m d
  KlndClick $y $m $d
  set todonew [string trimright [$wrem get 1.0 end]]
  if {$todonew ne {}} {append todonew \n}
  # add the moved TODO to the new TODO
  append todonew $todo
  # select the new date
  set klnddata(SAVEDATE) [ClockFormat $date]
  KlndDay $date no
  # update the new TODO
  $wrem replace 1.0 end $todonew
}
#_______________________

proc project::Klnd_next {{days 1}} {
  # Moves a reminder to *days*.
  #   days - days to move to

  variable obPrj
  variable klnddata
  set wrem [$obPrj TexKlnd]
  set todo [string trimright [$wrem get 1.0 end]]
  if {$todo eq {}} {
    bell
    FocusInTab f1 $wrem
    return
  }
  Klnd_delete
  set date [ClockScan $klnddata(SAVEDATE)]
  set date [clock add $date $days days]
  after 100 [list alited::project::Klnd_moveTODO $wrem $todo $date]
}
#_______________________

proc project::Klnd_next2 {} {
  # Moves a reminder to 7 days.

  Klnd_next 7
}
#_______________________

proc project::Klnd_previous {} {
  # Moves a reminder back to 1 day.

  Klnd_next -1
}
#_______________________

proc project::Klnd_previous2 {} {
  # Moves a reminder back to 7 days.

  Klnd_next -7
}
#_______________________

proc project::KlndPopup {w y m d X Y} {
  # Handles a popup menu for the calendar.
  #   w - day widget clicked
  #   y - year
  #   m - month
  #   d - day
  #   X - X-coordinate of pointer
  #   Y - Y-coordinate of pointer

  variable obPrj
  KlndClick $y $m $d
  ::klnd::selectedDay {} $y $m $d no
  set popm $w.popup
  catch {destroy $popm}
  menu $popm -tearoff 0
  foreach img {delete - previous2 previous - next next2} {
    if {$img eq {-}} {
      $popm add separator
    } else {
      $popm add command -image alimg_$img  -compound left \
        -label $::alited::al(MC,prjT$img) -command alited::project::Klnd_$img
    }
  }
  $obPrj themePopup $popm
  tk_popup $popm $X $Y
  KlndUpdate
}
#_______________________

proc project::ViewDir {} {
  # Shows file chooser just to view the project's dir

  alited::tool::e_menu EX=4 d=$::alited::al(prjroot)
}
#_______________________

proc project::RunComs {} {
  # Handles running commands of Commands tab.

  namespace upvar ::alited al al
  variable obPrj
  variable win
  variable prjlist
  variable prjinfo
  SaveNotes [CurrProject]
  set comtorun {}
  set comcnt 0
  # collect commands executed on the current project
  if {[info exists prjinfo($al(prjname),prjroot)]} {
    set dir $prjinfo($al(prjname),prjroot)
    for {set i 1} {$i<=$al(cmdNum)} {incr i} {
      if {$al(PTP,runch$i) && $al(PTP,run$i) ne {}} {
        if {!$comcnt} {
          append comtorun "cd $dir\n"
        }
        append comtorun "$al(PTP,run$i)\n"
        incr comcnt
      }
    }
  }
  # collect general commands executed per project
  foreach prj $prjlist {
    set dir $prjinfo($prj,prjroot)
    set com {}
    for {set i 1} {$i<=$al(cmdNum)} {incr i} {
      if {$al(PTP,comch$i) && $al(PTP,com$i) ne {}} {
        if {$com eq {}} {
          append com "cd $dir\n"
        }
        append com "$al(PTP,com$i)\n"
        incr comcnt
      }
    }
    append comtorun $com
  }
  if {$comtorun eq {}} {
    focus [$obPrj Entrun1]
    bell
  } else {
    set msg [msgcat::mc {%n commands will be executed!}]
    set msg [string map [list %n $comcnt] $msg]
    if {[alited::msg yesno ques $msg YES -centerme $win]} {
      alited::tool::Run_in_e_menu $comtorun
    }
  }
}
#_______________________

proc project::ChecksRun {} {
  # Sets checks of "Commands / Run for project".

  namespace upvar ::alited al al
  for {set i 1} {$i<=$al(cmdNum)} {incr i} {
    set al(PTP,runch$i) $al(PTP,chbClearRun)
  }
}
#_______________________

proc project::ChecksCom {} {
  # Sets checks of "Commands / Run for all".

  namespace upvar ::alited al al
  for {set i 1} {$i<=$al(cmdNum)} {incr i} {
    set al(PTP,comch$i) $al(PTP,chbClearCom)
  }
}

# ________________________ Template procs _________________________ #

proc project::TplDefaultText {} {
  # Gets default contents of project template.

  return \
{doc
data
  hlp
  img
  msg
lib
  theme
  utils
    tkcon
src
CHANGELOG.md
LICENSE
README.md}
}
#_______________________

proc project::TplDefault {} {
  # Sets default contents of project template.

  variable obPrj
  set cbx [$obPrj CbxTpl]
  $cbx set Default
  $cbx selection clear
  $obPrj displayText [$obPrj TexTemplate] [TplDefaultText]
}
#_______________________

proc project::UpdateTplLists {} {
  # Updates lists of template data, setting the current template on the top.

  namespace upvar ::alited al al
  variable obPrj
  set wtpl [$obPrj TexTemplate]
  set cbx [$obPrj CbxTpl]
  set al(PTP,name) [string trim [$cbx get]]
  RemoveFromTplList $al(PTP,name)
  if {$al(PTP,name) eq {}} {
    set al(PTP,name) Template\ #[llength $al(PTP,names)]
  }
  set tpltext [string trimright [$wtpl get 1.0 end]]
  set al(PTP,names) [linsert $al(PTP,names) 0 $al(PTP,name)]
  set al(PTP,list) [linsert $al(PTP,list) 0 $al(PTP,name) $tpltext]
  set maxlen 16
  catch {set al(PTP,names) [lreplace $al(PTP,names) $maxlen end]}
  catch {set al(PTP,list) [lreplace $al(PTP,list) $maxlen+$maxlen end]}
  set ltmp [list]
  foreach {n c} $al(PTP,list) {
    set t {}
    foreach l [lrange [split $c \n] 0 200] {append t [string trimright $l] \n}
    lappend ltmp $n [string trimright $t]
  }
  set al(PTP,list) $ltmp
  $cbx set $al(PTP,name)
  $cbx configure -values $al(PTP,names)
}
#_______________________

proc project::UpdateTplText {} {
  # Updates the template text.

  namespace upvar ::alited al al
  variable obPrj
  set i [lsearch -exact $al(PTP,list) $al(PTP,name)]
  $obPrj displayText [$obPrj TexTemplate] [lindex $al(PTP,list) $i+1]
  UpdateTplLists
}
#_______________________

proc project::RemoveFromTplList {val} {
  # Removes a template name from the lists of template data.
  #   val - name of template to be removed

  namespace upvar ::alited al al
  if {$val eq {}} return
  # remove from list of template names
  if {[set i [lsearch -exact $al(PTP,names) $val]]>-1} {
    set al(PTP,names) [lreplace $al(PTP,names) $i $i]
  }
  # remove from list of template pairs "name contents"
  if {[set i [lsearch -exact $al(PTP,list) $val]]>-1} {
    set al(PTP,list) [lreplace $al(PTP,list) $i $i+1]
  }
}
#_______________________

proc project::DeleteFromTplList {} {
  # Deletes a template name from the list of project templates.

  variable obPrj
  set cbx [$obPrj CbxTpl]
  RemoveFromTplList [string trim [$cbx get]]
  $cbx configure -values $::alited::al(PTP,names)
  $cbx set {}
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

  if {$y ne {}} {
    if {[catch {set date [ClockScan $y/$m/$d]}]} {
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

  return [ClockFormat [KlndInDate $y $m $d]]
}
#_______________________

proc project::KlndDate {date} {
  # Formats a calendar date by alited's format (Preferences/Templates).
  #   date - the date to be formatted

  set seconds [ClockScan $date]
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

  variable obPrj
  variable klnddata
  set klnddata(date) [KlndOutDate $y $m $d]
  # first, save a previous reminder at need
  set klnddata(SAVEDATE) $klnddata(date)
  set klnddata(SAVEPRJ) [CurrProject]
  # then display a new reminder's text
  set klndtex [$obPrj TexKlnd]
  $obPrj displayText $klndtex [KlndText $klnddata(date)]
  alited::ini::HighlightFileText $klndtex .md 0  -dobind 1 -cmdpos ::apave::None \
    -cmd alited::project::KlndTextModified
  [$obPrj LabKlndDate] configure -text [KlndDate $klnddata(date)]
}
#_______________________

proc project::KlndSearch {date prjname} {
  # Search a date in calendar data.
  # Returns index of found item or -1 if not found.

  variable prjinfo
  variable klnddata
  set res -1
  catch {
    set res [lsearch -index 0 -exact $prjinfo($prjname,prjrem) $date]
  }
  return $res
}
#_______________________

proc project::KlndTextModified {wtxt args} {
  # Processes modifications of calendar text.
  #   wtxt - text's path
  #   args - not used arguments

  namespace upvar ::alited al al
  set aft _KLND_TextModified
  catch {after cancel $al($aft)}
  set al($aft) [after idle alited::project::Klnd_save]
}
# ________________________ GUI _________________________ #

proc project::MainFrame {} {
  # Creates a main frame of "Project" dialogue.

  return {
    {fraTreePrj - - 10 1 {-st nswe -pady 4 -rw 1}}
    {.TreePrj - - - - {pack -side left -expand 1 -fill both} \
      {-h 16 -show headings -columns {C1} -displaycolumns {C1} \
      -popup {alited::project::PopupMenu %x %y %X %Y}}}
    {.sbvPrjs + L - - {pack -side left -fill both}}
    {fraR fraTreePrj L 10 1 {-st nsew -cw 1 -pady 4}}
    {fraR.nbk - - - - {pack -side top -expand 1 -fill both} {
      f1 {-text {$al(MC,info)}}
      f2 {-text {$al(MC,prjOptions)}}
      f3 {-text Templates}
      f4 {-text Commands}
      f5 {-text Files}
      -traverse yes -select f1
    }}
    {fraB1 fraTreePrj T 1 1 {-st nsew}}
    {.btTad - - - - {pack -side left -anchor n} \
      {-com alited::project::Add -tip {$::alited::al(MC,prjadd)} -image alimg_add-big}}
    {.btTch - - - - {pack -side left} \
      {-com alited::project::Change -tip {$::alited::al(MC,prjchg)} -image alimg_change-big}}
    {.btTdel - - - - {pack -side left} \
      {-com alited::project::Delete -tip {$::alited::al(MC,prjdel1)} \
      -image alimg_delete-big}}
    {.h_ - - - - {pack -side left -expand 1}}
    {.btTtpl - - - - {pack -side left} \
      {-com alited::project::Template -tip {$::alited::al(MC,CrTemplPrj)} \
      -image alimg_plus-big}}
    {.btTtview - - - - {pack -side left -padx 4} \
      {-image alimg_folder-big -com alited::project::ViewDir -tip {$::alited::al(MC,ViewDir)}}}
    {LabMess fraB1 L 1 1 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {seh fraB1 T 1 2 {-st nsew -pady 2}}
    {fraB2 + T 1 2 {-st nsew} {-padding {2 2}}}
    {.ButHelp - - - - {pack -side left -anchor s -padx 2} \
      {-t {$::alited::al(MC,help)} -tip F1 -com alited::project::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 50}}
    {.ButOK - - - - {pack -side left -anchor s -padx 2} \
      {-t {$::alited::al(MC,select)} -com alited::project::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -com alited::project::Cancel}}
  }
}
#_______________________

proc project::Tab1 {} {
  # Creates a main tab of "Project".

  namespace upvar ::alited al al
  variable klnddata
  set klnddata(SAVEDATE) [set klnddata(SAVEPRJ) {}]
  set monofont "[font actual apaveFontMono] -size $al(FONTSIZE,small)"
  set klnddata(toobar) "LabKlndDate {{} {} {-font {$monofont}}} sev 6"
  foreach img {delete paste undo redo - previous2 previous next next2} {
    # -method option for possible disable/enable BuT_alimg_delete etc.
    if {$img eq {-}} {
      append klnddata(toobar) " sev 4"
      continue
    }
    append klnddata(toobar) " alimg_$img \{{} \
      -tip {-BALTIP {$al(MC,prjT$img)} -MAXEXP 2@@ -under 4} \
      -com alited::project::Klnd_$img -method yes \}"
  }
  set klnddata(vsbltext) yes
  set klnddata(date) [KlndOutDate]
  after idle alited::project::KlndUpdate
  return {
    {v_ - - 1 1}
    {fra1 v_ T 1 2 {-st nsew -cw 1}}
    {.labName - - 1 1 {-st e -pady 1 -padx 3} \
      {-t {$al(MC,prjName)} -foreground $al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
    {.EntName + L 1 1 {-st sw -pady 5} {-tvar ::alited::al(prjname) -w 50}}
    {.labDir .labName T 1 1 {-st e -pady 8 -padx 3} {-t "Root directory:"}}
    {.Dir + L 1 9 {-st sw -pady 5 -padx 3} \
      {-tvar ::alited::al(prjroot) -w 50 -validate focus \
      -validatecommand alited::project::ValidateDir}}
    {lab fra1 T 1 1 {-st w -pady 4 -padx 3} {-t "Notes:"}}
    {fra2 + T 2 1 {-st nsew -rw 1 -cw 99}}
    {.TexPrj - - - - {pack -side left -expand 1 -fill both -padx 3} \
      {-h 20 -w 40 -wrap word -tabnext *.spx -tip {-BALTIP {$al(MC,notes)} -MAXEXP 1}}}
    {.sbv + L - - {pack -side left}}
    {frasp lab L 1 1 {-st nsew}}
    {.lab - - - - {pack -side left} {-t {TODO days ahead:}}}
    {.spx - - - - {pack -side left -padx 8} \
      {-tvar ::alited::al(todoahead) -from 0 -to 365 -w 5 -justify center \
      -com alited::project::Select -validate all \
      -validatecommand {alited::project::ValidateIni %V}}}
    {fra3 fra2 L 2 1 {-st nsew} {-relief groove -borderwidth 2}}
    {.seh - - - - {pack -fill x}}
    {.daT - - - - {pack -fill both} \
      {-tvar ::alited::project::klnddata(date) \
      -com {alited::project::KlndUpdate; alited::project::KlndBorderText} \
      -dateformat "$::alited::al(TPL,%d)" \
      -tip {alited::project::KlndText %D} -weeks $::alited::al(klndweeks) \
      -popup {alited::project::KlndPopup %W %y %m %d %X %Y} -width 3}}
    {fra3.fra - - - - {pack -fill both -expand 1}}
    {.seh2 - - - - {pack -side top -fill x}}
    {.too - - - - {pack -side top} \
      {-relief flat -borderwidth 0 -array {$::alited::project::klnddata(toobar)}}}
    {.TexKlnd - - - - {pack -side left -fill both -expand 1} \
      {-wrap word -tabnext {alited::Tnext *.texPrj} -w 4 -h 8 \
      -tip {-BALTIP {$al(MC,prjTtext)} -MAXEXP 1}}}
}
}
#_______________________

proc project::Tab2 {} {
  # Creates Options tab of "Project".

  namespace upvar ::alited al al
  lassign [alited::FgFgBold] fg al(FG,DEFopts)
  if {!$al(PRJDEFAULT)} {
    set al(FG,DEFopts) "$fg -afteridle {grid forget %w}" ;# no heading message
  }
  return {
    {v_ - - 1 10}
    {lab1 + T 1 2 {-st nsew -pady 1 -padx 3} \
      {-t {$al(MC,DEFopts)} -foreground $al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
    {fra2 + T 1 2 {-st nsew -cw 1}}
    {.labIgn - - 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,Ign:)}}}
    {.entIgn + L 1 8 {-st sw -pady 5 -padx 3} {-tvar ::alited::al(prjdirign) -w 50}}
    {.labEOL .labIgn T 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,EOL:)}}}
    {.cbxEOL + L 1 1 {-st sw -pady 3 -padx 3} \
      {-tvar ::alited::al(prjEOL) -values {{} LF CR CRLF} -w 9 -state readonly}}
    {.labIndent .labEOL T 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,indent:)}}}
    {.spxIndent + L 1 1 {-st sw -pady 3 -padx 3} \
      {-tvar ::alited::al(prjindent) -from 0 -to 8 -com {::alited::pref::CheckIndent ""}}}
    {.chbIndAuto + L 1 1 {-st sw -pady 3 -padx 3} \
      {-var ::alited::al(prjindentAuto) -t {$al(MC,indentAuto)}}}
    {.labRedunit .labIndent T 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,redunit)}}}
    {.spxRedunit + L 1 1 {-st sw -pady 3 -padx 3} \
      {-tvar ::alited::al(prjredunit) -from $al(minredunit) -to 100}}
    {.labmaxcom .labRedunit T 1 1 {-st e -pady 1 -padx 3} {-t {Maximum Run commands}}}
    {.spxMaxcom + L 1 1 {-st sw -pady 3 -padx 3} \
      {-tvar ::alited::al(prjmaxcoms) -from 4 -to 99 -tabnext alited::Tnext}}
    {.labMult .labmaxcom T 1 1 {-st e -pady 1 -padx 3} \
      {-t {$al(MC,multiline)} -tip {$al(MC,notrecomm)}}}
    {.swiMult + L 1 1 {-st sw -pady 3 -padx 3} \
      {-var ::alited::al(prjmultiline) -tip {$al(MC,notrecomm)}}}
    {.labTrWs .labMult T 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,trailwhite)}}}
    {.swiTrWs + L 1 1 {-st sw -pady 1} {-var ::alited::al(prjtrailwhite)}}
    {.seh .labTrWs T 1 9}
    {.labUself + T 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,useleafRE)}}}
    {.swiUself + L 1 1 {-st sw -pady 1} \
      {-var ::alited::al(prjuseleafRE) -com alited::project::CheckPrjUseLeaf}}
    {.butStd + L 1 7 {-st e} {-t Standard -com alited::project::StdLeafRE}}
    {.labLf .labUself T 1 1 {-st e -pady 1 -padx 3} {-t {$al(MC,leafRE)}}}
    {.EntLf + L 1 8 {-st sew -pady 1} {-tvar ::alited::al(prjleafRE)}}
  }
}
#_______________________

proc project::Tab3 {} {
  # Creates Templates tab of "Project".

  return {
    {v_ - - 1 9}
    {lab1 + T 1 9 {-st nsew -pady 1 -padx 3} {-t {$al(MC,TemplPrj)}}}
    {lab2 + T 1 1 {-st ew -pady 5 -padx 3} \
      {-t Template: -foreground $al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
    {CbxTpl + L 1 3 {-st ew -pady 5} \
      {-w 40 -h 12 -cbxsel {$al(PTP,name)} -tvar ::alited::al(PTP,name) \
      -values {$al(PTP,names)} -clearcom alited::project::DeleteFromTplList \
      -selcombobox alited::project::UpdateTplText}}
    {fraTlist + T 1 8 {-st nswe -padx 3 -cw 1 -rw 1}}
    {.TexTemplate - - - - {pack -side left -fill both -expand 1} \
      {-h 20 -w 40 -tabnext "*.butTplDef *.cbxTpl" -wrap none}}
    {.sbv + L - - {pack -side left}}
    {butTplDef fraTlist T 1 1 {-st w -padx 4 -pady 4} \
      {-t Standard -com alited::project::TplDefault -tabnext alited::Tnext}}
  }
}
#_______________________

proc project::Tab4 {} {
  # Creates Commands tab of "Project".

  namespace upvar ::alited al al
  set al(PTP,chbClearRun) 0
  set al(PTP,chbClearCom) 0
  set al(PTP,chbClearTip) [string map [list %f [msgcat::mc General]] $al(MC,alloffile)]
  return {
    {v_ - - 1 3}
    {Labprj + T 1 2 {} {-foreground $al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
    {ChbClearRun labprj L 1 1 {-st w} \
      {-var ::alited::al(PTP,chbClearRun) -com alited::project::ChecksRun -takefocus 0}}
    {tcl {
        set prt labprj
        set ent Entrun
        for {set i 1} {$i<=$::alited::al(cmdNum)} {incr i} {
          set lwid "lab$i $prt T 1 1 {-st nse} {-t {$::alited::al(MC,com) $i:}}"
          %C $lwid
          set lwid "$ent$i lab$i L 1 1 {-cw 1 -st ew} {-tvar ::alited::al(PTP,run$i)}"
          %C $lwid
          set lwid "chb$i $ent$i L 1 1 {} {-t {Run it} \
            -var ::alited::al(PTP,runch$i) -takefocus 0}"
          %C $lwid
          set prt lab$i
          set ent ent
        }
        set lwid {seh1 lab6 T 1 3}
        %C $lwid
        set lwid {labcom seh1 T 1 2 {} \
          {-t General -foreground $::alited::al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
        %C $lwid
        set lwid {chbClearCom labcom L 1 1 {-st w} \
          {-var ::alited::al(PTP,chbClearCom) -com alited::project::ChecksCom -takefocus 0 \
          -tip {$al(PTP,chbClearTip)}}}
        %C $lwid
        set prt labcom
        for {set i 1} {$i<=$::alited::al(cmdNum)} {incr i} {
          set lwid "labc$i $prt T 1 1 {-st nse} {-t {$::alited::al(MC,com) $i:}}"
          %C $lwid
          set lwid "entc$i labc$i L 1 1 {-cw 1 -st ew} {-tvar ::alited::al(PTP,com$i)}"
          %C $lwid
          set lwid "chbc$i entc$i L 1 1 {} {-t {Run it} -var ::alited::al(PTP,comch$i) -takefocus 0}"
          %C $lwid
          set prt labc$i
        }
      }
    }
    {seh2 labc6 T 1 3}
    {h_ seh2 T 1 1}
    {butRun h_ L 1 2 {-st ew} {-t Run -com alited::project::RunComs -tip {$al(MC,saving) & $al(MC,run)} -tabnext alited::Tnext}}
  }
}
#_______________________

proc project::Tab5 {} {
  # Creates Files tab of "Project".

  alited::ini::ProjectsToolbar
  return {
    {frat - - 1 9 {-st ew}}
    {frat.ToolTop + T - - pack {-array {$::alited::al(atools)} -relief groove -borderwidth 1}}
    {labFilter frat T 1 1 {-st se -padx 1} {-t {All files filter:}}}
    {EntFilter + L 1 1 {-st swe -padx 1 -cw 1} {-tvar ::alited::project::filefilter -validate all -validatecommand alited::project::preValidateFilter}}
    {ChbFilter + L 1 1 {-st sw -padx 1} {-var ::alited::project::casefilter -t {Match case} -com alited::project::postValidateFilter}}
    {seh_ labFilter T 1 3}
    {LabFlist + T 1 3 {-pady 3 -padx 3} {-foreground $al(FG,DEFopts) -font {$::apave::FONTMAINBOLD}}}
    {fraFlist + T 1 3 {-st nswe -padx 3 -rw 1}}
    {.LbxFlist - - - - {pack -side left -fill both -expand 1} {-takefocus 0 -selectmode multiple -popup {::alited::project::LbxPopup %X %Y}}}
    {.sbvFlist + L - - {pack -side left}}
  }
}

# ________________________ Main _________________________ #

proc project::_create {} {
  # Creates and opens Projects dialogue.

  namespace upvar ::alited al al
  variable obPrj
  variable win
  variable geo
  variable prjlist
  variable oldTab
  variable ilast
  variable curinfo
  set curinfo(_NO2ENT) 0
  set tipson [baltip::cget -on]
  baltip::configure -on $al(TIPS,Projects)
  ::apave::APave create $obPrj $win
  $obPrj makeWindow $win.fra "$al(MC,projects) :: $::alited::PRJDIR"
  set nbk $win.fra.fraR.nbk
  $obPrj paveWindow \
    $win.fra [MainFrame] \
    $nbk.f1 [Tab1] \
    $nbk.f2 [Tab2] \
    $nbk.f3 [Tab3] \
    $nbk.f4 [Tab4] \
    $nbk.f5 [Tab5]
  set tree [$obPrj TreePrj]
  $tree heading C1 -text $al(MC,projects)
  if {$oldTab ne {}} {$nbk select $oldTab}
  UpdateTree
  ::apave::bindToEvent $tree <<TreeviewSelect>> alited::project::Select
  bind $win <$al(acc_2)> "alited::ini::ToolByKey $nbk ToolPrjEM"
  bind $win <$al(acc_3)> "alited::ini::ToolByKey $nbk ToolPrjRun"
  bind $tree <Delete> alited::project::Delete
  bind $tree <Double-Button-1> alited::project::ProjectEnter
  bind $tree <Return> alited::project::ProjectEnter
  foreach ev {KeyPress ButtonPress} {
    bind $tree <$ev> {+ alited::project::KeyOnTree %K}
  }
  bind $win <F1> "[$obPrj ButHelp] invoke"
  bind [$obPrj LabMess] <Button-1> alited::project::ProcMessage
  set lbx [$obPrj LbxFlist]
  foreach a {a A} {
    bind $lbx <Control-$a> alited::project::SelectAllFiles
  }
  bind $lbx <Double-Button-1> {alited::project::OpenFile %y}
  ::baltip tip $lbx {alited::project::TipOnFile %i} -shiftX 10
  after 500 alited::project::HelpMe ;# show an introduction after a short pause
  set prjtex [$obPrj TexPrj]
  bind $prjtex <FocusOut> alited::project::SaveNotes
  if {$ilast>-1} {Select $ilast}
  $obPrj displayText [$obPrj TexTemplate] $al(PTP,text)
  alited::ini::HighlightFileText $prjtex .md 0  -dobind 1 -cmdpos ::apave::None
  set res [$obPrj showModal $win -geometry $geo -minsize {600 400} -resizable 1 \
    -onclose alited::project::Cancel -focus [$obPrj TreePrj]]
  set oldTab [$nbk select]
  set al(PTP,text) [string trimright [[$obPrj TexTemplate] get 1.0 end]]
  if {[llength $res] < 2} {set res ""}
  # save the new geometry of the dialogue
  set geo [wm geometry $win]
  alited::main::ShowHeader yes
  baltip::configure {*}$tipson
  ::klnd::clearup
  array unset curinfo *
  catch {destroy $win}
  $obPrj destroy
  return $res
}
#_______________________

proc project::_run {{checktodo yes}} {
  # Runs Projects dialogue.
  #   checktodo - if yes, checks for outdated TODOs

  namespace upvar ::alited al al
  variable win
  variable msgtodo
  variable updateGUI
  variable saveini
  if {[winfo exists $win]} return
  set updateGUI [set saveini no]
  set msgtodo {}
  update  ;# if run from menu: there may be unupdated space under it (in some DE)
  SaveSettings
  GetProjects
  if {$checktodo && ![IsOutdated $al(prjname)]} {
    after 200 {
      if {[set prj [alited::project::CheckOutdated]] ne {}} {
        alited::project::Select $::alited::project::prjinfo($prj,ID)
      }
    }
  }
  after 200 alited::project::OnProjectEnter
  set res [_create]
  if {$updateGUI} alited::main::UpdateAll ;# settings may be changed as for GUI
  if {$saveini} alited::ini::SaveIni
}

# _________________________________ EOF _________________________________ #
