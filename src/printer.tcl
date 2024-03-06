#! /usr/bin/env tclsh
###########################################################
# Name:    printer.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 01, 2024
# Brief:   Handles html copy of a project to be printed.
# License: MIT.
###########################################################

# _________________________ printer ________________________ #

namespace eval printer {
  variable win $::alited::al(WIN).printer
  variable itemID1 {}
  variable inifile {}
  variable tpldir {} cssdir {}
  variable indextpl {} indextpl2 {} csstpl {} titletpl {} csscont {}
  variable indexname index.html
  variable indexname2 index_2.html
  variable cssname style.css
  variable readmecont {}
  variable markedIDs [list] markedfiles [list]
  variable copyleft {<!-- Made by alited -->}
  # wildcards in templates
  variable wcalited ALITED_ ;# to avoid self-wildcarding
  variable wctitle ${wcalited}TITLE
  variable wctoc   ${wcalited}TABLE_OF_CONTENTS
  variable wclink  ${wcalited}CURRENT_LINK
  variable wcreadm ${wcalited}README_CONTENTS
  variable wcbody  ${wcalited}BODY_CONTENTS
  variable wcwidth ${wcalited}TABLE_OF_CONTENTS_WIDTH
  variable wcfg    ${wcalited}FG
  variable wcbg    ${wcalited}BG
  # saved options
  variable geometry root=$::alited::al(WIN)
  variable width1 {} width2 {}
  variable dir {}
  variable mdproc {pandoc}
  variable mdprocs [list pandoc alited]
  variable ttlfg #fefefe ttlbg #0b3467
  variable leaffg #343434 leafbg #84ade0
  variable cwidth 10
  variable final {}
}

# ________________________ Ini file _________________________ #

proc printer::ReadIni {} {
  # Reads ini data.

  namespace upvar ::alited al al
  variable inifile
  variable geometry
  variable width1
  variable width2
  variable dir
  variable mdproc
  variable mdprocs
  variable ttlfg
  variable ttlbg
  variable leaffg
  variable leafbg
  variable cwidth
  variable final
  variable markedfiles
  set cont [apave::readTextFile $inifile]
  set markedfiles [list]
  foreach line [split $cont \n] {
    set line [string trim $line]
    if {[set val [alited::edit::IniParameter file $line]] ne {}} {
      lappend markedfiles $val
    } else {
      foreach opt {geometry width1 width2 dir mdproc mdprocs \
      ttlfg ttlbg leaffg leafbg cwidth final} {
        if {[set val [alited::edit::IniParameter $opt $line]] ne {}} {
          set $opt $val
        }
      }
    }
  }
  if {$width1 eq {}} {set width1 $al(TREE,cw0)}
  if {$width2 eq {}} {set width2 $al(TREE,cw1)}
}
#_______________________

proc printer::SaveIni {} {
  # Saves ini data.

  namespace upvar ::alited obDl2 obDl2
  variable inifile
  variable geometry
  variable width1
  variable width2
  variable dir
  variable mdproc
  variable mdprocs
  variable ttlfg
  variable ttlbg
  variable leaffg
  variable leafbg
  variable cwidth
  variable final
  variable markedIDs
  set wtree [$obDl2 Tree]
  set    ::_ {}
  append ::_ "geometry=$geometry" \n
  append ::_ "width1=$width1"	\n
  append ::_ "width2=$width2"	\n
  append ::_ "dir=$dir"				\n
  append ::_ "mdproc=$mdproc"	\n
  append ::_ "mdprocs=[set mdprocs]"	\n
  append ::_ "ttlfg=$ttlfg"	\n
  append ::_ "ttlbg=$ttlbg"	\n
  append ::_ "leaffg=$leaffg"	\n
  append ::_ "leafbg=$leafbg"	\n
  append ::_ "cwidth=$cwidth"	\n
  append ::_ "final=$final"
  foreach item [alited::tree::GetTree {} {} $wtree] {
    lassign [lindex $item 4] - fname leaf itemID
    if {$itemID in $markedIDs} {
      append ::_ \nfile=$fname
    }
  }
  apave::writeTextFile $inifile ::_
  unset ::_
}

# ________________________ Expand / Contract _________________________ #

proc printer::ExpandMarked {} {
  # Shows all marked tree item.

  namespace upvar ::alited obDl2 obDl2
  variable markedIDs
  ExpandContract no
  set wtree [$obDl2 Tree]
  set taghas -1
  foreach itemID $markedIDs {
    set th [$wtree tag has tagBranch $itemID]
    if {$taghas != $th} {$wtree see $itemID}
    set taghas $th
  }
  TryFocusTree $wtree
}
#_______________________

proc printer::ExpandContract {{isexp yes}} {
  # Expands or contracts the tree.
  #   isexp - yes, if to expand; no, if to contract

  namespace upvar ::alited al al obDl2 obDl2
  set wtree [$obDl2 Tree]
  set itemID [alited::tree::CurrentItem {} $wtree]
  set branch [set selbranch {}]
  foreach item [alited::tree::GetTree {} {} $wtree] {
    lassign $item lev cnt ID
    if {[llength [$wtree children $ID]]} {
      set branch $ID
      $wtree item $ID -open $isexp
    }
    if {$ID eq $itemID} {set selbranch $branch}
  }
  if {$isexp} {
    if {$itemID ne {}} {$wtree selection set $itemID}
    alited::tree::SeeSelection $wtree
  } elseif {$selbranch ne {}} {
    $wtree selection set $selbranch
    alited::tree::SeeSelection $wtree
  }
  TryFocusTree $wtree
}

# ________________________ Mark / Unmark _________________________ #

proc printer::MarkUnmarkFile {} {
  # Marks/unmarks and item in file tree.

  namespace upvar ::alited obDl2 obDl2
  variable markedIDs
  variable itemID1
  set wtree [$obDl2 Tree]
  set itemID [$wtree focus]
  if {$itemID eq {}} {
    focus $wtree
    FocusID1 $wtree
    return 0
  }
  if {[set i [lsearch $markedIDs $itemID]]>=0} {
    set markedIDs [lreplace $markedIDs $i $i]
    set wasmarkeddir [Mark $wtree $itemID no]
  } else {
    lappend markedIDs $itemID
    set wasmarkeddir [Mark $wtree $itemID yes]
  }
  if {$wasmarkeddir} {
    ExpandMarked
    after idle "alited::printer::FocusID $wtree $itemID"
  }
  MarkTotal
  return $wasmarkeddir
}
#_______________________

proc printer::MarkTotal {} {
  # Show a number of marked items.

  namespace upvar ::alited obDl2 obDl2
  variable markedIDs
  [$obDl2 Labstat2] configure -text [llength $markedIDs]
}
#_______________________

proc printer::Mark {wtree itemID ismarked} {
  # Mark/unmark tree items.
  #   wtree - tree's path
  #   itemID - item's ID
  #   ismarked - yes if the item is marked

  set treecont [alited::tree::GetTree {} {} $wtree]
  set iit [lsearch -exact -index {4 3} $treecont $itemID]
  lassign [lindex $treecont $iit] lev
  lassign [lindex $treecont $iit 4] - fname leaf
  MarkFile $wtree $itemID $ismarked
  set wasmarkeddir no
  if {![string is true -strict $leaf]} {
    # for directory: mark/unmark its files
    foreach item [lrange $treecont [incr iit] end] {
      lassign [lindex $item] lev2
      lassign [lindex $item 4] - fname leaf itID
      if {$lev2<=$lev} break
      MarkFile $wtree $itID $ismarked
      set wasmarkeddir yes
    }
  }
  return $wasmarkeddir
}
#_______________________

proc printer::Mark1 {wtree} {
  # Mark/unmark tree item of file, with a key.
  #   wtree - tree's path

  set wd [MarkUnmarkFile]
  if {!$wd} {
    event generate $wtree <Down>
  }
}
#_______________________

proc printer::MarkFile {wtree itemID ismarked} {
  # Mark/unmark tree item of file.
  #   wtree - tree's path
  #   itemID - item's ID
  #   ismarked - yes if the item is marked

  variable markedIDs
  set i [lsearch $markedIDs $itemID]
  set markedIDs [lreplace $markedIDs $i $i]
  if {$ismarked} {
    $wtree tag add tagSel $itemID
    lappend markedIDs $itemID
  } else {
    $wtree tag remove tagSel $itemID
  }
}

# ________________________ Focus tree _________________________ #

proc printer::TryFocusTree {wtree} {
  # Tries focusing the focused item of the tree.
  #   wtree - tree's path

  set itemID [$wtree focus]
  if {$itemID ne {}} {
    focus $wtree
    FocusID $wtree $itemID
  }
}
#_______________________

proc printer::FocusID {wtree itemID {cnt 1}} {
  # Focuses an item of the tree.
  #   wtree - tree's path
  #   itemID - item's ID

  if {$cnt} {
    # will restart after idle
    after idle "alited::printer::FocusID $wtree $itemID [incr cnt -1]"
  } else {
    $wtree focus $itemID
    $wtree see $itemID
    $wtree selection set $itemID
  }
}
#_______________________

proc printer::FocusID1 {wtree} {
  # Focuses 1st item of the tree.
  #   wtree - tree's path

  variable itemID1
  if {$itemID1 ne {}} {FocusID $wtree $itemID1}
}
#_______________________

proc printer::FocusIn {wtree} {
  # Handles focusing the tree.

  set itemID [$wtree focus]
  if {$itemID eq {}} {
    FocusID1 $wtree
  } else {
    FocusID $wtree $itemID
  }
}
#_______________________

proc printer::FocusOut {wtree} {
  # Handles unfocusing the tree.

  catch {$wtree selection remove [$wtree focus]}
}

# ________________________ Processing _________________________ #

proc printer::Message {msg {mode 1}} {
  # Displays a message in statusbar of the dialogue.
  #   msg - message
  #   mode - mode of Message

  namespace upvar ::alited obDl2 obDl2
  alited::Message $msg $mode [$obDl2 Labstat1]
}
#_______________________

proc printer::CheckData {} {
  # Check for correctness of the dialog's data.

  namespace upvar ::alited obDl2 obDl2
  variable dir
  variable cwidth
  set dir [string trim $dir]
  if {$dir eq {}} {
    set errfoc [$obDl2 chooserPath Dir]
  } elseif {![::apave::intInRange $cwidth 5 99]} {
    set errfoc [$obDl2 SpxCwidth]
  }
  if {[info exists errfoc]} {
    bell
    ::apave::FocusByForce $errfoc
    return no
  }
  return yes
}
#_______________________

proc printer::CheckFile {fname} {
  # Checks the file of contents.
  #   fname - the file name

  variable copyleft
  set fcont [apave::readTextFile $fname]
  expr {[string first $copyleft $fcont]>=0}
}
#_______________________

proc printer::CheckDir {} {
  # Checks the output directory.

  namespace upvar ::alited al al
  variable dir
  variable indexname
  set dircont [glob -nocomplain [file join $dir *]]
  if {![llength $dircont]} {return yes}
  # possible errors:
  set err1 {Output directory cannot be cleared: alien files}
  set err2 [msgcat::mc {Output directory cannot be cleared: alien %n}]
  set err3 {Output directory cannot be cleared: alien directories}
  set cntdir [set cntfile 0]
  foreach fn $dircont {
    set ftail [file tail $fn]
    if {[file isfile $fn]} {
      incr cntfile
      if {$ftail ne $indexname} {
        Message $err1 4
        return no  ;# alien file
      }
      if {![CheckFile $fn]} {
        Message [string map [list %n $indexname] $err2] 4
        return no  ;# alien content file
      }
    } elseif {$ftail ne {css}} {
      incr cntdir
    }
  }
  if {$cntdir && $cntfile!=1} {
    Message $err3 4  ;# only 1 content file with subdirectories
    return no
  }
  if {$cntdir} {
    set msg [msgcat::mc "The output directory\n  %n\ncontains %c subdirectories.\n\nAll will be replaced with the new!"]
    set msg [string map [list %n $dir %c $cntdir] $msg]
    if {![alited::msg okcancel warn $msg OK -title $al(MC,warning)]} {
      return no
    }
  }
  catch {file delete -force {*}$dircont}
  return yes
}
#_______________________

proc printer::CheckTemplates {} {
  # Checks alited's templates for .html files.

  namespace upvar ::alited al al
  variable wcreadm
  variable wctitle
  variable wcbody
  variable wctoc
  variable wcwidth
  variable dir
  variable tpldir
  variable indextpl
  variable indexname
  variable cssdir
  variable csstpl
  variable cssname
  variable csscont
  variable cwidth
  variable readmecont
  set csscont [apave::readTextFile $csstpl]
  if {$csscont eq {}} {
    Message "No template file for $cssname found: alited broken?" 4
    return no
  }
  set ttl ":: $al(prjname) ::"
  set indexcont [apave::readTextFile $indextpl]
  set readmecont [string map [list $wcreadm $readmecont $wcbody {}] $indexcont]
  set readmecont [string map [list $wctitle $ttl $wctoc $ttl] $readmecont]
  set cssdir_to  [file join $dir css]
  catch {file mkdir $cssdir_to}
  set csscont [string map [list $wcwidth $cwidth] $csscont]
  set css_to [file join $cssdir_to $cssname]
  apave::writeTextFile $css_to ::alited::printer::csscont 1
  return yes
}
#_______________________

proc printer::GetReadme {dirfrom} {
  # Create html version of readme.md.
  #   dirfrom - directory name where to get the source readme.md

  variable mdproc
  if {$mdproc eq {}} {return {}}
  if {[set fname [glob -nocomplain [file join $dirfrom README*]]] eq {}} {
    if {[set fname [glob -nocomplain [file join $dirfrom ReadMe*]]] eq {}} {
      if {[set fname [glob -nocomplain [file join $dirfrom Readme*]]] eq {}} {
        if {[set fname [glob -nocomplain [file join $dirfrom readme*]]] eq {}} {
          return {}
        }
      }
    }
  }
  set fname [lindex $fname 0]
  set tmpname [alited::TmpFile PRINTER~.html]
  if {$mdproc eq {pandoc}} {
    set com [list [apave::autoexec $mdproc] -o $tmpname $fname]
  } elseif {$mdproc eq {alited}} {
    # TODO
    return {}
  } else {
    set com [string map [list %i $fname %o $tmpname] $mdproc]
  }
  exec -- {*}$com
  set res [apave::readTextFile $tmpname]
  catch {file delete $tmpname}
  return $res
}
#_______________________

proc printer::GetDirLink {dir} {
  # Gets a dir link for index.html.
  #   dir - directory name

  namespace upvar ::alited al al
  set ir [string length $al(prjroot)]
  set dirtail [string range $dir [incr ir] end]
  return [list $dirtail <li><b>$dirtail</b></li>]
}
#_______________________

proc printer::GetFileName {dir2 fname} {
  # Gets a file link for index.html.
  #   dir2 - directory name
  #   fname - file name

  namespace upvar ::alited al al
  set ftail [file tail $fname]
  return [file join $dir2 $ftail]
}
#_______________________

proc printer::GetFileLink {link ftail} {
  # Gets a file link for index.html.
  #   link - file name
  #   ftail - tail of file name

  return "<ul class=toc><li><a href=\"$link\">$ftail</a></li></ul>"
}
#_______________________

proc printer::MakeFile {fname fname2} {
  # Makes a html file or a copy of file from a source file.
  #   fname - source file's name
  #   fname2 - resulting file

  variable dir
  variable indextpl
  variable indextpl2
  variable wctitle
  variable wclink
  variable wcreadm
  variable wctoc
  variable wcbody
  variable wclink
  variable wcfg
  variable wcbg
  variable leaffg
  variable leafbg
  set ftail [file tail $fname2]
  Message $ftail 3
  update
  if {![alited::file::IsTcl $fname2]} {
    file copy $fname $fname2
    return $fname2
  }
  set cont [apave::readTextFile $fname]
  if {[set TID [alited::bar::FileTID $fname]] ne {}} {
# TODO    set tpl [apave::readTextFile $indextpl]
    set tpl [apave::readTextFile $indextpl2]
    set tpl [string map [list $wctoc $ftail $wclink {}] $tpl]
  } else {
    set tpl [apave::readTextFile $indextpl2]
  }
  set ::_ [string map [list $wctitle $ftail $wclink {} $wcreadm {} \
    $wcfg $leaffg $wcbg $leafbg $wcbody "<pre class=\"code\">$cont</pre>"] $tpl]
  set fname2 [file rootname $fname2].html
  apave::writeTextFile $fname2 ::_
  unset ::_
  Hl_html $fname2
  return $fname2
}
#_______________________

proc printer::Hl_html {fname} {
  # Highlights Tcl code in html file
  #   fname - file name

  namespace upvar ::alited LIBDIR LIBDIR
  set com [list [alited::Tclexe] [file join $LIBDIR hl_tcl tcl_html.tcl] $fname]
  exec -- {*}$com
}
#_______________________

proc printer::Process {wtree} {
  # Processes files to make the resulting .html.
  #   wtree - tree's path

  namespace upvar ::alited al al
  variable markedIDs
  variable tpldir
  variable dir
  variable readmecont
  variable indexname
  variable final
  variable wclink
  variable wcfg
  variable ttlfg
  variable wcbg
  variable ttlbg
  set readmecont [GetReadme $al(prjroot)]
  if {![CheckData]} {return no}
  if {![CheckDir]} {return no}
  if {![CheckTemplates]} {return no}
  set index_to [file join $dir $indexname]
  set curdir {}
  set fcnt [set dcnt 0]
  foreach itemID $markedIDs {
    lassign [$wtree item $itemID -values] -> fname isfile
    if {!$isfile} {
      incr dcnt
      continue
    }
    set cdir [file dirname $fname]
    set dodir no
    if {$curdir ne $cdir} {
      set dodir yes
      set curdir $cdir
      lassign [GetDirLink $cdir] cdir2 link
      append link \n$wclink
      set readmecont [string map [list $wclink $link] $readmecont]
      Message $cdir 3
      update
    }
    set fname2 [GetFileName $cdir2 $fname]
    set fname2 [file join $dir $fname2]
    if {$dodir} {
      catch {file mkdir [file dirname $fname2]}
    }
    set fname [MakeFile $fname $fname2]
    set link [GetFileLink $fname [file tail $fname2]]
    append link \n$wclink
    set readmecont [string map [list $wclink $link] $readmecont]
    incr fcnt
  }
  set readmecont [string map [list $wclink {}] $readmecont]
  set readmecont [string map [list $wcfg $ttlfg $wcbg $ttlbg] $readmecont]
  apave::writeTextFile $index_to ::alited::printer::readmecont 1
  set msg [msgcat::mc {Processed: %d directories, %f files}]
  set msg [string map [list %d $dcnt %f $fcnt] $msg]
  Message $msg
  if {$final ne {}} {
    set com [string map [list %D $dir] $final]
    exec -- {*}$com
  } else {
    bell
  }
  return yes
}

# ________________________ Buttons _________________________ #

proc printer::Help {} {
  # Handles "Help" button.

  alited::Help $::alited::printer::win
}
#_______________________

proc printer::Ok {} {

  namespace upvar ::alited obDl2 obDl2
  variable win
  variable geometry
  variable width1
  variable width2
  set wtree [$obDl2 Tree]
  set geometry [wm geometry $win]
  set width1 [$wtree column #0 -width]
  set width2 [$wtree column #1 -width]
  if {[Process $wtree]} {
    SaveIni
#!    $obDl2 res $win 1
  }
}
#_______________________

proc printer::Cancel {} {
  # Cancel handling the dialog.

  namespace upvar ::alited obDl2 obDl2
  variable win
  $obDl2 res $win 0
}

# ________________________ GUI _________________________ #

proc printer::FillTree {wtree} {
  # Populates the tree of project files.
  #   wtree - tree's path

  namespace upvar ::alited al al
  variable markedIDs
  variable markedfiles
  variable itemID1
  $wtree heading #0 -text ":: [file tail $al(prjroot)] ::"
  $wtree heading #1 -text $al(MC,files)
  alited::tree::PrepareDirectoryContents
  set markedIDs [list]
  set itemID1 {}
  foreach item [alited::tree::GetDirectoryContents $al(prjroot)] {
    set itemID [alited::tree::NewItemID [incr iit]]
    lassign $item lev isfile fname fcount iroot
    set title [file tail $fname]
    if {$iroot<0} {
      set parent {}
    } else {
      set parent [alited::tree::NewItemID [incr iroot]]
    }
    if {$isfile} {
      if {[alited::file::IsTcl $fname]} {
        set imgopt {-image alimg_tclfile}
      } else {
        set imgopt {-image alimg_file}
      }
    } else {
      set imgopt {-image alimg_folder}
    }
    if {$fcount} {set fc $fcount} {set fc {}}
    $wtree insert $parent end -id $itemID -text "$title" \
      -values [list $fc $fname $isfile $itemID] -open no {*}$imgopt
    $wtree tag add tagNorm $itemID
    if {!$isfile} {
      $wtree tag add tagBranch $itemID
    }
    if {$fname in $markedfiles} {
      lappend markedIDs $itemID
      $wtree tag add tagSel $itemID
    }
    if {$itemID1 eq {}} {set itemID1 $itemID}
  }
  ExpandMarked
  MarkTotal
  catch {$wtree see $itemID1}
}
#_______________________

proc printer::_create  {} {
  # Creates Project Printer dialogue.

  namespace upvar ::alited obDl2 obDl2
  variable win
  variable geometry
  variable width1
  variable width2
  set tipmark "[msgcat::mc (Un)Select]\nSpace"
  lassign [alited::FgFgBold] -> fgbold
  $obDl2 makeWindow $win.fra [msgcat::mc {Project Printer}]
  $obDl2 paveWindow $win.fra {
    {labh - - 1 3 {} {-t {Project Printer} -foreground $fgbold -font {$::apave::FONTMAINBOLD}}}
    {fraTop labh L 1 3 {-st ew}}
    {.btTmark - - - - {pack -padx 4 -side left} {-image alimg_ok -com alited::printer::MarkUnmarkFile  -tip {$tipmark}}}
    {.sev2 - - - - {pack -side left -fill y -padx 5}}
    {.btTCtr - - - - {pack -side left -padx 4} {-image alimg_minus -com {alited::printer::ExpandContract no} -tip "Contract All"}}
    {.btTExp - - - - {pack -side left} {-image alimg_plus -com {alited::printer::ExpandContract} -tip "Expand All"}}
    {.btTExp2 - - - - {pack -side left -padx 4} {-image alimg_add -com {alited::printer::ExpandMarked} -tip "Expand Selected"}}
    {fraBody labh T 1 3 {-st news}}
    {.v_0 - - 1 1 {-pady 8}}
    {.lab1 .v_0 T 1 1 {-st nw} {-t {Output directory:}}}
    {.Dir + T 1 3 {-st new} {-tvar ::alited::printer::dir -w 40}}
    {.v_1 + T 1 1 {-pady 8}}
    {.lab2 + T 1 1 {-st nw} {-t {Markdown processor:}}}
    {.cbx + T 1 3 {-st nw} {-tvar ::alited::printer::mdproc -value {$::alited::printer::mdprocs} -w 40}}
    {.v_2 + T 1 3 {-pady 8}}
    {.lfr + T 1 2 {-st nwe} {-t {Directory title colors}}}
    {.lfr.lab1 - - 1 1 {-st ne} {-t {Foreground:}}}
    {.lfr.clr1 + L 1 3 {-st nw} {-tvar ::alited::printer::ttlfg}}
    {.lfr.lab2 .lfr.lab1 T 1 1 {-st ne} {-t {Background:}}}
    {.lfr.clr2 + L 1 3 {-st nw} {-tvar ::alited::printer::ttlbg}}
    {.v_3 .lfr T 1 1 {-pady 8}}
    {.lfr2 + T 1 2 {-st nwe} {-t {File title colors}}}
    {.lfr2.lab1 - - 1 1 {-st ne} {-t {Foreground:}}}
    {.lfr2.clr3 + L 1 3 {-st nw} {-tvar ::alited::printer::leaffg}}
    {.lfr2.lab2 .lfr2.lab1 T 1 1 {-st ne} {-t {Background:}}}
    {.lfr2.clr4 + L 1 3 {-st nw} {-tvar ::alited::printer::leafbg}}
    {.v_4 .lfr2 T 1 3 {-pady 8}}
    {.fraw + T 1 3 {-st nw}}
    {.fraw.lab3 + T 1 1 {-st nse} {-t {Width of contents:}}}
    {.fraw.SpxCwidth + L 1 1 {-st nsw -padx 4} {-tvar ::alited::printer::cwidth -from 5 -to 99 -w 4 -justify center}}
    {.seh .fraw T 1 3 {-pady 8}}
    {.lab4 + T 1 1 {-st nw} {-t {Final processor:}}}
    {.fil + T 1 3 {-st new} {-tvar ::alited::printer::final -w 40}}
    {fraTree fraTop T 2 1 {-st news -cw 1}}
    {.Tree - - - - {pack -side left -fill both -expand 1} {-height 20 -columns {L1 L2 PRL ID LEV LEAF FL1} -displaycolumns {L1} -columnoptions "#0 {-width $width1} L1 {-width $width2 -anchor e}" -style TreeNoHL -selectmode browse -tip {-BALTIP {alited::tree::GetTooltip %i %c} -SHIFTX 10}}}
    {.SbvTree fraTree.Tree L - - {pack -side right -fill both}}
    {fraMid fraBody T 1 3 {-st wes -rw 1 -padx 2}}
    {.seh1 - - - - {pack -side top -expand 1 -fill both -pady 4}}
    {.butHelp - - - - {pack -side left} {-t Help -com alited::printer::Help}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 4}}
    {.butOK - - - - {pack -side left} {-t OK -com alited::printer::Ok}}
    {.butCancel - - - - {pack -side left -padx 2} {-t Cancel -com alited::printer::Cancel}}
    {fraBot fraMid T 1 4 {-st we}}
    {.stat - - - - {pack -side bottom} {-array {
      {{} -anchor w -expand 1} 30
      {Selected -anchor center} 4
    }}}
  }
  set wtree [$obDl2 Tree]
  bind $wtree <space> "alited::printer::Mark1 $wtree; break"
  bind $wtree <FocusIn> "alited::printer::FocusIn $wtree"
  bind $wtree <FocusOut> "alited::printer::FocusOut $wtree"
  bind $win <F1> "alited::printer::Help"
  alited::tree::AddTags $wtree
  FillTree $wtree
  $obDl2 showModal $win -resizable 1 -minsize {500 400} -geometry $geometry -focus Tab
  catch {destroy $win}
}
#_______________________

proc printer::_run  {} {
  # Runs Project Printer dialogue.

  namespace upvar ::alited al al PRJDIR PRJDIR DATADIR DATADIR
  variable inifile
  variable tpldir
  variable indextpl
  variable indextpl2
  variable titletpl
  variable indexname
  variable indexname2
  variable cssdir
  variable csstpl
  variable cssname
  set tpldir [file join $DATADIR printer]
  set indextpl [file join $tpldir $indexname]
  set indextpl2 [file join $tpldir $indexname2]
  set titletpl [file join $tpldir title.html]
  set cssdir [file join $tpldir css]
  set csstpl [file join $cssdir $cssname]
  set inifile [file join $PRJDIR $al(prjname).prn]
  ReadIni
  _create
}
