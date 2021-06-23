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
  variable win $::alited::al(WIN).diaPrj
  variable OPTS [list prjname prjroot prjdirign prjEOL prjindent prjredunit prjmultiline]
  variable prjlist [list]
  variable tablist [list]
  variable geo root=$::alited::al(WIN)
  variable minsize {}
  variable ilast -1
  variable oldTab {}
  variable prjinfo; array set prjinfo [list]
  variable data; array set data [list]
  variable fnotes {}
}

# ________________________ Common _________________________ #

proc project::TabFileInfo {} {
  namespace upvar ::alited al al obDl2 obDl2
  set lbx [$obDl2 LbxFlist]
  $lbx delete 0 end
  foreach tab $al(tablist) {
    set fname [lindex [split $tab \t] 0]
    $lbx insert end $fname
  }
}

proc project::SaveCurrFileList {title {isnew no}} {
  namespace upvar ::alited al al obDl3 obDl3
  variable win
  set asks [list $al(MC,prjaddfl) add $al(MC,prjsubstfl) change $al(MC,prjdelfl) delete \
    $al(MC,prjnochfl) file Cancel cancel]
  set msg [string map [list %n [string toupper $title]] $al(MC,prjgoing)]
  append msg \n\n $al(MC,prjsavfl)
  set ans [$obDl3 misc ques $title $msg $asks file]
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
        set fname [set fn [alited::bar::BAR $TID cget -tip]]
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

proc project::Selected {what {domsg yes}} {
  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  set tree [$obDl2 TreePrj]
  if {[set isel [$tree selection]] eq "" && [set isel [$tree focus]] eq "" \
  && $domsg} {
    alited::Message2 $al(MC,prjsel) 4
  }
  if {$isel ne "" && $what eq "index"} {
    set isel [$tree index $isel]
  }
  return $isel
}

proc project::Ok {args} {
  namespace upvar ::alited al al obDl2 obDl2 obPav obPav
  variable win
  variable prjlist
  variable prjinfo
  variable data
  if {[set isel [Selected index]] eq {} || ![ValidProject]} {
    focus [$obDl2 TreePrj]
    return
  }
  if {[llength [alited::bar::BAR listFlag m]]} {
    set msg [msgcat::mc "All modified files will be saved.\n\nDo you agree?"]
    if {![alited::msg yesno ques $msg NO -geometry root=$win]} return
  }
  if {![alited::file::SaveAll]} {
    $obDl2 res $win 0
    return
  }
  set pname [string trim $al(prjname)]
  set fname [ProjectFileName $pname]
  RestoreSettings
  alited::ini::SaveIni
  alited::file::CloseAll 1
  set al(prjname) $pname
  set al(prjfile) $fname
  alited::ini::ReadIni $fname
  alited::bar::FillBar [$obPav BtsBar]
  alited::file::MakeThemReload
  set TID [lindex [alited::bar::BAR listTab] $al(curtab) 0]
  catch {alited::bar::BAR $TID show}
  alited::main::UpdateProjectInfo
  alited::ini::GetUserDirs
  $obDl2 res $win 1
  after idle alited::main::ShowText
  return
}

proc project::Cancel {args} {
  namespace upvar ::alited obDl2 obDl2
  variable win
  SaveIni
  RestoreSettings
  $obDl2 res $win 0
}

proc project::Help {} {
  variable win
  alited::Help $win
}
proc project::ReadIni {} {
  ProcEOL $::alited::EOL \n
}

proc project::SaveIni {} {
  variable ilast
  ProcEOL \n $::alited::EOL
  set ilast [Selected index no]
}

proc project::SaveSettings {} {
  namespace upvar ::alited al al
  variable data
  variable OPTS
  foreach v $OPTS {
    set data($v) $al($v)
  }
  set data(prjfile) $al(prjfile)
}

proc project::RestoreSettings {} {
  namespace upvar ::alited al al
  variable data
  variable OPTS
  foreach v $OPTS {
    set al($v) $data($v)
  }
  set al(prjfile) $data(prjfile)
  TabFileInfo
}

proc project::CurrentFileList {} {
  namespace upvar ::alited al al
  variable OPTS
  set al(tablist) ""
  foreach tab [alited::bar::BAR listTab] {
    if {$al(tablist) ne ""} {append al(tablist) $alited::EOL}
    set TID [lindex $tab 0]
    append al(tablist) [alited::bar::BAR $TID cget -tip]
  }
}

proc project::PutMiscOpts {fname} {
  GetProjectOpts $fname
  PutProjectOpts $fname $fname
}

proc project::GetProjectOpts {fname} {
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
      lappend prjinfo($pname,tablist) [alited::bar::BAR $tid cget -tip]
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

proc project::PutProjectOpts {fname oldname} {
  namespace upvar ::alited al al obDl2 obDl2
  variable prjinfo
  variable OPTS
  set filecont [::apave::readTextFile $oldname]
  set newcont ""
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

proc project::GetProjects {} {
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

proc project::SaveNotes {} {
  namespace upvar ::alited obDl2 obDl2
  variable fnotes
  if {$fnotes ne ""} {
    set fcont [[$obDl2 TexPrj] get 1.0 "end -1c"]
    ::apave::writeTextFile $fnotes fcont
  }
}

proc project::Select {{item ""}} {
  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo 
  variable OPTS
  variable fnotes
  if {$item eq ""} {set item [Selected item no]}
  if {$item ne ""} {
    set tree [$obDl2 TreePrj]
    if {[string is digit $item]} {  ;# the item is an index
      if {$item<0 || $item>=[llength $prjlist]} return
      set prj [lindex $prjlist $item]
      set item $prjinfo($prj,ID)
    } elseif {![$tree exists $item]} {
      return
    }
    set isel [$tree index $item]
    set prj [lindex $prjlist $isel]
    set fnotes [file join $::alited::PRJDIR $prj-notes.txt]
    set wtxt [$obDl2 TexPrj]
    $wtxt delete 1.0 end
    if {[file exists $fnotes]} {
      $wtxt insert end [::apave::readTextFile $fnotes]
    }
    foreach opt $OPTS {
      set al($opt) $prjinfo($prj,$opt)
    }
    set al(tablist) $prjinfo($prj,tablist)
    TabFileInfo
    if {[$tree selection] ne $item} {
      $tree selection set $item
    }
    $tree see $item
  }
}

proc project::UpdateTree {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable prjlist
  variable prjinfo
  set tree [$obDl2 TreePrj]
  $tree delete [$tree children {}]
  foreach prj $prjlist {
    set prjinfo($prj,ID) [$tree insert {} end -values [list $prj]]
  }
}

proc project::GetOptVal {line} {
  if {[set i [string first "=" $line]]>-1} {
    return [list [string range $line 0 $i-1] [string range $line $i+1 end]]
  }
  return [list]
}

proc project::ProcEOL {val mode} {
  if {$mode eq "in"} {
    return [string map [list $::alited::EOL \n] $val]
  } else {
    return [string map [list \n $::alited::EOL] $val]
  }
}

proc project::CheckProjectName {} {
  namespace upvar ::alited al al
  set oldname $al(prjname)
  set al(prjname) [string map [list \
    * _ ? _ ~ _ . _ / _ \\ _ \{ _ \} _ \[ _ \] _ \t _ \n _ \r _ \
    | _ < _ > _ & _ , _ : _ \; _ \" _ ' _ ` _] $al(prjname)]
  return [expr {$oldname eq $al(prjname)}]
}

proc project::ProjectName {fname} {
  return [file rootname [file tail $fname]]
}

proc project::ProjectFileName {name} {
  namespace upvar ::alited al al PRJDIR PRJDIR PRJEXT PRJEXT
  set name [ProjectName [string trim $name]]
  return [file normalize [file join $PRJDIR "$name$PRJEXT"]]
}

proc project::ValidProject {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable win
  if {[string trim $al(prjname)] eq {} || ![CheckProjectName]} {
    bell
    focus [$obDl2 EntName]
    return no
  }
  set al(prjroot) [file nativename $al(prjroot)]
  if {![file exists $al(prjroot)]} {
    set msg [string map [list %d $al(prjroot)] $al(makeroot)]
    if {![alited::msg yesno ques $msg NO -geometry root=$win]} {
      return no
    }
    file mkdir $al(prjroot)
  }
  if {$al(prjindent)<2 || $al(prjindent)>8} {set al(prjindent) 2}
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

proc project::Add {} {
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

proc project::Change {{askappend yes} {isel -1}} {
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

proc project::Delete {} {
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

proc project::MainFrame {} {
  namespace upvar ::alited al al obDl2 obDl2
  variable win
  return {
    {fraTreePrj - - 10 1 {-st nswe -pady 4 -rw 1} {}}
    {.TreePrj - - - - {pack -side left -expand 1 -fill both} {-h 16 -show headings -columns {C1} -displaycolumns {C1}}}
    {.sbvPrjs .TreePrj L - - {pack -side left -fill both}}
    {fraR fraTreePrj L 10 1 {-st nsew -cw 1 -pady 4}}
    {fraR.Nbk - - - - {pack -side top -expand 1 -fill both} {
      f1 {-text {$al(MC,info)}}
      f2 {-text {$al(MC,prjOptions)}}
      -traverse yes -select f1
    }}
    {fraB1 fraTreePrj T 1 1 {-st nsew} {}}
    {.buTad - - - - {pack -side left -anchor n} {-takefocus 0 -com ::alited::project::Add -tip {$alited::al(MC,prjadd)} -image alimg_add-big}}
    {.buTch - - - - {pack -side left} {-takefocus 0 -com ::alited::project::Change -tip {$alited::al(MC,prjchg)} -image alimg_change-big}}
    {.buTdel - - - - {pack -side left} {-takefocus 0 -com ::alited::project::Delete -tip {$alited::al(MC,prjdel)} -image alimg_delete-big}}
    {LabMess fraB1 L 1 1 {-st nsew -pady 0 -padx 3} {-style TLabelFS}}
    {fraB2 fraB1 T 1 2 {-st nsew} {-padding {5 5 5 5} -relief groove}}
    {.butHelp - - - - {pack -side left -anchor s -padx 2} {-t {$alited::al(MC,help)} -command ::alited::project::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 8} {-w 50}}
    {.butOK - - - - {pack -side left -anchor s -padx 2} {-t {$alited::al(MC,select)} -command ::alited::project::Ok}}
    {.butCancel - - - - {pack -side left -anchor s} {-t Cancel -command ::alited::project::Cancel}}
  }
}

proc project::Tab1 {} {
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
    {.TexPrj - - - - {pack -side left -expand 1 -fill both -padx 3} {-h 20 -w 40 -wrap word -tabnext $alited::project::win.fraB2.butOK -tip {$alited::al(MC,notes)}}}
    {.sbv .TexPrj L - - {pack -side left}}
  }
}

proc project::Tab2 {} {
  return {
    {v_ - - 1 10}
    {fra2 v_ T 1 2 {-st nsew -cw 1}}
    {.labEOL - - 1 1 {-st w -pady 1 -padx 3} {-t "End of line:"}}
    {.cbxEOL .labEOL L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjEOL) -values {{} LF CR CRLF} -w 5 -state readonly}}
    {.labIndent .labEOL T 1 1 {-st w -pady 1 -padx 3} {-t "Indentation:"}}
    {.spXIndent .labIndent L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjindent) -w 3 -from 2 -to 8 -justify center}}
    {.labRedunit .labIndent T 1 1 {-st w -pady 1 -padx 3} {-t "Unit lines per 1 red bar:"}}
    {.spXRedunit .labRedunit L 1 1 {-st sw -pady 3 -padx 3} {-tvar alited::al(prjredunit) -w 3 -from 10 -to 100 -justify center}}
    {.labMult .labRedunit T 1 1 {-st w -pady 1 -padx 3} {-t "Multi-line strings:" -tip {$alited::al(MC,notrecomm)}}}
    {.chbMult .labMult L 1 1 {-st sw -pady 3 -padx 3} {-var alited::al(prjmultiline) -tip {$alited::al(MC,notrecomm)}}}
    {.labFlist .labMult T 1 1 {-pady 3 -padx 3} {-t "List of files:"}}
    {fraFlist .labFlist T 1 2 {-st nswe -padx 3 -cw 1 -rw 1}}
    {.LbxFlist - - - - {pack -side left -fill both -expand 1}}
    {.sbvFlist .lbxFlist L - - {pack -side left}}
  }
}

proc project::_create {} {

  namespace upvar ::alited al al obDl2 obDl2
  variable win
  variable geo
  variable minsize
  variable prjlist
  variable oldTab
  variable ilast
  $obDl2 makeWindow $win "$al(MC,projects) :: $::alited::PRJDIR"
  $obDl2 paveWindow \
    $win [MainFrame] \
    $win.fraR.nbk.f1 [Tab1] \
    $win.fraR.nbk.f2 [Tab2]
  set tree [$obDl2 TreePrj]
  $tree heading C1 -text $al(MC,projects)
  if {$oldTab ne ""} {
    $win.fraR.nbk select $oldTab
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
  set oldTab [$win.fraR.nbk select]
  if {[llength $res] < 2} {set res ""}
  set geo [wm geometry $win] ;# save the new geometry of the dialogue
  destroy $win
  return $res
}

proc project::_run {} {

  SaveSettings
  GetProjects
  set res [_create]
  return $res
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
