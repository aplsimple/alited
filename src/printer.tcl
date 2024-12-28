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
  variable inifile {} iniprjfile {}
  variable tpldir {} cssdir {} filesdir {}
  variable CSS css
  variable FILES files
  variable indextpl {} indextpl2 {} csstpl {} titletpl {} csscont {}
  variable indexname index.html
  variable indexname2 index_2.html
  variable cssname style.css
  variable readmecont {}
  variable indexcont {}
  variable markedIDs [list] markedfiles [list]
  variable copyleft {<!-- Made by alited -->}
  variable copyright {<!-- Made by alited (END) -->}
  variable tmpC {}
  variable colors {}
  variable lastreadme {}
  variable prebeg "<pre class=\"code\">"
  variable preend "</pre>"
  variable paragr "</p><p>"
  # wildcards in templates
  variable wcalited ALITED_ ;# to avoid self-wildcarding
  variable leafttl "<table border=0 cellPadding=4 cellSpacing=0 width=100%> \
    <td border=0 bgColor=${wcalited}BG><div style=text-align:center> \
    <a href=\"${wcalited}BACK_REF\"><font color=${wcalited}FG size=6> \
    <b>${wcalited}TITLE</b></font></div></td></table>"
  variable wcstyle ${wcalited}STYLE
  variable wctitle ${wcalited}TITLE
  variable wctoc   ${wcalited}TABLE_CONTENTS
  variable wclink  ${wcalited}CURRENT_LINK
  variable wcrmcon ${wcalited}README_CONTENTS
  variable wcrmttl ${wcalited}README_TITLE
  variable wcbttl  ${wcalited}BODY_TITLE
  variable wcbody  ${wcalited}BODY_CONTENTS
  variable wcwidth ${wcalited}TABLE_WIDTH
  variable wcback  ${wcalited}BACK_REF
  variable wcfg    ${wcalited}FG
  variable wcbg    ${wcalited}BG
  variable wcleaft ${wcalited}LEAF_TITLE
  variable wctipw  ${wcalited}TIP_WIDTH
  variable wclt    ${wcalited}LT
  variable wcgt    ${wcalited}GT
  # saved options
  variable geometry root=$::alited::al(WIN)
  variable width1 {} width2 {}
  variable dir {}
  variable mdproc {pandoc}
  variable mdprocs [list pandoc alited]
  variable STDttlfg #fefefe STDttlbg #0b3467
  variable STDleaffg #1a1a1a STDleafbg #bdd7e7
  variable ttlfg $STDttlfg ttlbg $STDttlbg
  variable leaffg $STDleaffg leafbg $STDleafbg
  variable cwidth 10
  variable cs 1
  variable final {"%D"}
  variable dosort 0
}
#_______________________

proc printer::fetchVars {} {
  # Delivers namespace variables to a caller.

  uplevel 1 {
    namespace upvar ::alited al al obDl2 obDl2 INIDIR INIDIR PRJDIR PRJDIR DATADIR DATADIR
    foreach _ {win itemID1 inifile iniprjfile tpldir cssdir CSS indextpl indextpl2 csstpl \
    titletpl csscont indexname indexname2 cssname readmecont markedIDs markedfiles copyleft \
    wcbttl wcstyle wctitle wctoc wclink wcrmcon wcbody wcwidth wcback wcfg wcbg tmpC cs \
    geometry width1 width2 dir mdproc mdprocs ttlfg ttlbg leaffg leafbg cwidth indexcont \
    final leafttl wcleaft wctipw wcrmttl dosort wclt wcgt copyright colors lastreadme \
    filesdir FILES prebeg preend paragr} {
      variable $_
    }
  }
}
#_______________________

proc printer::Message {msg {mode 2}} {
  # Displays a message in statusbar of the dialogue.
  #   msg - message
  #   mode - mode of Message

  namespace upvar ::alited obDl2 obDl2
  alited::Message $msg $mode [$obDl2 Labstat1]
}
#_______________________

proc printer::ProcMessage {} {
  # Handles clicking on message label.

  namespace upvar ::alited obDl2 obDl2
  set msg [baltip cget [$obDl2 Labstat1] -text]
  Message $msg 3
}

# ________________________ Ini file _________________________ #

proc printer::ReadIni {} {
  # Reads ini data.

  fetchVars
  set cont [readTextFile $inifile]
  append cont \n [readTextFile $iniprjfile]
  set markedfiles [list]
  foreach line [split $cont \n] {
    set line [string trim $line]
    if {[set val [alited::edit::IniParameter file $line]] ne {}} {
      lappend markedfiles $val
    } else {
      foreach opt {geometry width1 width2 dir mdproc mdprocs \
      ttlfg ttlbg leaffg leafbg cwidth cs final dosort} {
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

  fetchVars
  set wtree [$obDl2 Tree]
  set    tmpC {}
  append tmpC "geometry=$geometry" \n
  append tmpC "width1=$width1" \n
  append tmpC "width2=$width2" \n
  append tmpC "mdproc=$mdproc" \n
  append tmpC "ttlfg=$ttlfg" \n
  append tmpC "ttlbg=$ttlbg" \n
  append tmpC "leaffg=$leaffg" \n
  append tmpC "leafbg=$leafbg" \n
  append tmpC "cwidth=$cwidth" \n
  append tmpC "cs=$cs" \n
  writeTextFile $inifile ::alited::printer::tmpC
  set    tmpC {}
  append tmpC "dir=$dir" \n
  append tmpC "final=$final" \n
  append tmpC "dosort=$dosort" \n
  foreach item [alited::tree::GetTree {} {} $wtree] {
    lassign [lindex $item 4] - fname leaf itemID
    if {$itemID in $markedIDs} {
      append tmpC \nfile=$fname
    }
  }
  writeTextFile $iniprjfile ::alited::printer::tmpC
}

# ________________________ Expand / Contract _________________________ #

proc printer::ExpandMarked {} {
  # Shows all marked tree item.

  fetchVars
  ExpandContract no
  set wtree [$obDl2 Tree]
  set parent {}
  foreach itemID $markedIDs {
    set itemParent [$wtree parent $itemID]
    if {$itemParent ne {} && $parent ne $itemParent} {
      $wtree see $itemID
      set parent $itemParent
    }
  }
  TryFocusTree $wtree
}
#_______________________

proc printer::ExpandContract {{isexp yes}} {
  # Expands or contracts the tree.
  #   isexp - yes, if to expand; no, if to contract

  fetchVars
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

  fetchVars
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

  fetchVars
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

# ________________________ alited's md processor _________________________ #

proc printer::MdInit {} {
  # Initializes a text widget for md syntax.

  fetchVars
  set wtxt [$obDl2 TexTmp2]
  set plcom [alited::HighlightAddon $wtxt .md $colors]
  ::hl_tcl::hl_init $wtxt -plaincom $plcom
}
#_______________________

proc printer::MdProc {fin fout} {
  # Makes .html version of .md file.
  #   fin - input .md file name
  #   fout - output .html file name
  # First, puts the .md file to a text widget and highlights it.
  # Then scans the text for highlighting tags to make their html counterparts.
  # See also: hl_md::init

  fetchVars
  set wtxt [$obDl2 TexTmp2]
  set cont [readTextFile $fin {} 1]
  $wtxt replace 1.0 end $cont
  ::hl_tcl::hl_text $wtxt
  lassign $colors clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC clrOPT
  foreach tag [$wtxt tag names] {
    if {![string match md* $tag]} continue
    set parts [lsort -dictionary -decreasing -stride 2 [$wtxt tag ranges $tag]]
    foreach {p1 p2} $parts {
      switch -exact $tag {
        mdCMNT {  ;# comment tag for "invisible" parts
          $wtxt replace $p1 $p2 {}
        }
        mdAPOS {  ;# apostrophe is for <code> tag
          set cont [$wtxt get $p1 $p2]
          set cont2 [Off_Html_tags $cont]
          $wtxt replace $p1 $p2 $cont2
          set addch [expr {[string length $cont2]-[string length $cont]}]
          set p2 [$wtxt index "$p2 +$addch char"]
          $wtxt insert $p2 </code>
          $wtxt insert $p1 "<code>"
        }
        mdBOIT {  ;# bold italic
          $wtxt insert $p2 </font></i></b>
          $wtxt insert $p1 "<b><i><font color=$clrVAR>"
        }
        mdITAL {  ;# italic
          $wtxt insert $p2 </font></i>
          $wtxt insert $p1 "<i><font color=$clrVAR>"
        }
        mdBOLD {  ;# bold
          $wtxt insert $p2 </font></b>
          $wtxt insert $p1 "<b><font color=$clrVAR>"
        }
        mdLIST {  ;# list
          set link [$wtxt get $p1 $p2]
          if {[set lre [lindex [regexp -inline {^\s*(\d+).\s} $link] 0]] ne {}} {
            # numbered list
            $wtxt replace $p1 $p2 "<ol start=\"$lre\"><li>"
            set endtag </li></ol>
          } else {
            # usual list
            $wtxt replace $p1 $p2 <li>
            set endtag </li>
          }
          $wtxt insert [expr {int($p2)}].end $endtag
        }
        mdLINK {  ;# link
          set tag1 {<a href=}
          set tag2 </a>
          set tag3 >
          set link [$wtxt get $p1 $p2]
          lassign [split $link \[\]()] a1 a2 a3 a4
          if {$a1 eq {!}} {
            # <img src="https://wiki.tcl-lang.org/Tcl+Editors" alt="Tcl Editors" />,
            set tag1 "<img alt=\"$a2\" src="
            set tag2 {}
            set tag3 " />"
            set a1 [set a2 {}]
          }
          if {$a1 ne {}} {
            set link "$tag1\"$link\">$link"
          } else {
            set link "$tag1\"$a4\"$tag3$a2"
          }
          $wtxt replace $p1 $p2 $link$tag2
        }
        mdHEAD1 - mdHEAD2 - mdHEAD3 - mdHEAD4 - mdHEAD5 - mdHEAD6 {  ;# headers
          set h h[string index $tag end]
          $wtxt insert $p2 </font></$h>
          $wtxt insert $p1 "<$h><font color=$clrPROC>"
        }
      }
    }
  }
  MdOutput $wtxt $fout
}
#_______________________

proc printer::MdOutput {wtxt fout} {
  # Puts out the .html made from .md (in a text buffer): final processings.
  #   wtxt - text's path
  #   fout - output file name

  fetchVars
  set tmpC {}
  set par 1
  set code 0
  foreach line [split [$wtxt get 1.0 end] \n] {
    set line [string trimright $line]
    if {[regexp "^\\s{0,3}>{1}" $line]} {
      set line <blockquote>[string trimleft $line { >}]</blockquote>
    }
    if {$line eq {```}} {
      # code snippet's start-end
      if {[set code [expr {!$code}]]} {
        set line {<pre class="code">}
      } else {
        set line </pre>
      }
    } elseif {$line eq {}} {
      # paragraph's start-end
      if {!$par} {append line $paragr}
      incr par
    } elseif {$par} {
      set par 0
    }
    append tmpC $line \n
  }
  # paragraph's end
  append tmpC </p>
  writeTextFile $fout ::alited::printer::tmpC
}
#_______________________

proc printer::Hl_html {fname} {
  # Highlights Tcl code in html file
  #   fname - file name

  fetchVars
  set cset cs=
  foreach val $colors {append cset $val,}
  set hl_tcl [file join $::alited::LIBDIR hl_tcl tcl_html.tcl]
  set com [list [alited::Tclexe] $hl_tcl $cset $fname]
  exec -- {*}$com
}
#_______________________

proc printer::Off_Html_tags {cont} {
  # Disables html tags in a code snippet.
  #   cont - the code snippet

  string map [list < "&lt;" > "&gt;"] $cont
}

# ________________________ Processing _________________________ #


## ________________________ Checks _________________________ ##

proc printer::CheckData {} {
  # Check for correctness of the dialog's data.

  fetchVars
  set dir [string trim $dir]
  if {$dir eq {}} {
    set errfoc [$obDl2 chooserPath Dir]
  } elseif {![::apave::intInRange $cwidth 5 99]} {
    set errfoc [$obDl2 SpxCwidth]
  }
  if {[info exists errfoc]} {
    bell
    focusByForce $errfoc
    return no
  }
  foreach {fld var} {Clr1 ttlfg Clr2 ttlbg Clr3 leaffg Clr4 leafbg} {
    set val [set $var]
    if {![regexp "^#\[0-9a-fA-F\]{6}\$" $val]} {
      bell
      focus [$obDl2 chooserPath $fld]
      return no
    }
  }
  return yes
}
#_______________________

proc printer::CheckFile {fname} {
  # Checks the file of contents.
  #   fname - the file name

  variable copyleft
  set fcont [readTextFile $fname]
  expr {[string first $copyleft $fcont]>=0}
}
#_______________________

proc printer::CheckDir {} {
  # Checks the output directory.

  fetchVars
  set dircont [glob -nocomplain [file join $dir *]]
  if {![llength $dircont]} {return yes}
  # possible errors:
  set err1 {Output directory cannot be cleared: alien files}
  set err2 [msgcat::mc {Output directory cannot be cleared: alien %n}]
  set err3 {Output directory cannot be cleared: alien directories}
  set cntdir [set cntfile [set aliendir 0]]
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
    } elseif {$ftail in [list $FILES $CSS]} {
      incr cntdir
    } else {
      incr aliendir
    }
  }
  if {$aliendir} {
    Message $err3 4  ;# only 1 content file with subdirectories
    return no
  }
  if {$cntdir} {
    set msg [msgcat::mc "The output directory\n  %n\ncontains %c subdirectories.\n\nAll will be replaced with the new!"]
    set msg [string map [list %n $dir %c $cntdir] $msg]
    if {![alited::msg okcancel warn $msg OK -title $al(MC,warning)]} {
      set fname [file join $dir $indexname]
      if {[file exists $fname]} {openDoc $fname}
      return no
    }
  }
  catch {file delete -force {*}$dircont}
  return yes
}
#_______________________

proc printer::CheckTemplates {} {
  # Checks alited's templates for .html files.

  fetchVars
  set csscont [readTextFile $csstpl]
  if {$csscont eq {}} {
    Message "No template file for $cssname found: alited broken?" 4
    return no
  }
  return yes
}

## ________________________ Data _________________________ ##

proc printer::GetReadme {dirfrom} {
  # Create html version of readme.md.
  #   dirfrom - directory name where to get the source readme.md

  fetchVars
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
  Message $fname 3
  set tmpname [alited::TmpFile PRINTER~.html]
  if {$lastreadme ne $fname} {
    set lastreadme $fname
    set com {}
    if {$mdproc eq {pandoc}} {
      set com [list [apave::autoexec $mdproc] -o $tmpname $fname]
    } elseif {$mdproc eq {alited}} {
      MdProc $fname $tmpname
    } else {
      set com [string map [list %i $fname %o $tmpname] $mdproc]
    }
    if {$com ne {}} {exec -- {*}$com}
  }
  set cont {}
  set iscode no
  set lsp1 0
  set lpr1 [string length $paragr]
  set lpr2 [expr {$lpr1+1}]
  # wrap the code snippets with <pre code ... /pre>
  foreach line [split [readTextFile $tmpname {} 1] \n] {
    set line [string trimright $line]
    set lsp [$obDl2 leadingSpaces $line]
    if {$lsp>3} {
      set line [Off_Html_tags $line]
      if {!$iscode} {set lsp1 $lsp}
      set line [string range $line $lsp1 end]
      if {!$iscode} {
        if {[string range $cont end-$lpr1 end] eq "$paragr\n"} {
           set cont [string range $cont 0 end-$lpr2]
        }
        set line "$prebeg$line"
      }
      set iscode yes
    } elseif {$iscode && $line ne {}} {
      if {$line eq $paragr} {
        append cont \n
        continue
      }
      set cont [string trimright $cont]
      set line "$preend$line"
      set iscode no
    }
    append cont $line \n
  }
  list $cont $fname
}
#_______________________

proc printer::GetCss {} {
  # Create style.css.

  fetchVars
  set cssdir_to  [file join $dir $CSS]
  catch {file mkdir $cssdir_to}
  set tipw [expr {$cwidth*20}]
  set csscont [string map \
    [list $wcwidth $cwidth $wctipw $tipw $wcfg $ttlfg $wcbg $ttlbg] $csscont]
  set css_to [file join $cssdir_to $cssname]
  writeTextFile $css_to ::alited::printer::csscont 1
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

proc printer::GetDirLink {dir} {
  # Gets a dir link for index.html.
  #   dir - directory name

  namespace upvar ::alited al al
  set dirtail [::apave::FileTail $al(prjroot) $dir]
  if {$dirtail eq {}} {set branch <hr>} {set branch $dirtail}
  list $dirtail [GetBranchLink # $branch]
}
#_______________________

proc printer::GetBranchLink {link title} {
  # Gets a contents branch link for index.html.
  #   link - link address
  #   title - link title

  return "<li><b><a href=\"$link\">$title</a></b></li>"
}
#_______________________

proc printer::GetLeafLink {link title {tip ""} {basepath ""}} {
  # Gets a contents leaf link for index.html.
  #   link - link address
  #   title - link title
  #   tip - tooltip's text
  #   basepath - base path for file links

  if {$basepath ne {}} {
    set link [::apave::FileTail $basepath $link]
  }
  set title [lindex [split $title :] end]
  if {$tip eq {}} {
    return "<ul class=toc><li><a href='$link'>$title</a></li></ul>"
  }
  return "<ul class=toc><li><div class=tooltip><a href=\"$link\">$title</a><span class=tooltiptext>$tip</span></div></li></ul>"
}

## ________________________ Make .html _________________________ ##

proc printer::UnitTooltip {wtxt l1 l2} {
  # Gets unit's tooltip.
  #   wtxt - text's path
  #   l1 - 1st line's number
  #   l2 - last line's number

  set tip {}
  for {incr l1} {$l1<=$l2} {incr l1} {
    set line [string trimleft [$wtxt get $l1.0 $l1.end]]
    if {[string match #* $line]} {
      append tip [string trimleft $line {#! }] \n
    } elseif {$line ne {}} {
      break
    }
  }
  set tip [string trimright $tip]
  if {$tip ne {}} {set tip " : $tip"}
  return $tip
}
#_______________________

proc printer::CompareUnits {item1 item2} {
  # Compares the unit tree items by their titles. Useful for trees without branches.
  #   item1 - 1st item
  #   item2 - 2nd item

  lassign $item1 lev1 leaf1 - title1
  lassign $item2 lev2 leaf2 - title2
  set leaf1 [expr {$title1 ne {} && $leaf1}]
  set leaf2 [expr {$title2 ne {} && $leaf2}]
  set title1 "$leaf1 [string toupper [string trimleft $title1]]"
  set title2 "$leaf2 [string toupper [string trimleft $title2]]"
  if {$title1 < $title2} {
    return -1
  } elseif {$title1 > $title2} {
    return 1
  }
  return 0
}
#_______________________

proc printer::MakeFile {fname fname2} {
  # Makes a html file or a copy of file from a source file.
  #   fname - source file's name
  #   fname2 - resulting file

  fetchVars
  set ftail [file tail $fname2]
  Message $ftail 3
  update
  if {![alited::file::IsTcl $fname2]} {
    file copy $fname $fname2
    return $fname2
  }
  set cont [readTextFile $fname]
  set TID  [alited::bar::FileTID $fname]
  set wtxt [alited::main::GetWTXT $TID]
  if {$TID ne {} && $wtxt ne {}} {
    alited::InitUnitTree $TID
  } else {
    set TID TMP
    set wtxt [$obDl2 TexTmp]
    $wtxt replace 1.0 end $cont             ;# imitate tab of bar
    alited::unit::RecreateUnits $TID $wtxt  ;# to get unit tree
  }
  if {[llength $al(_unittree,$TID)]<2} {
    set tpl [readTextFile $indextpl2]  ;# no units
  } else {
    set tpl [readTextFile $indextpl]
    set tpl [string map [list $wctoc $ftail] $tpl]
    set contlist [split $cont \n]
    if {$dosort} {
      set items [lsort -command alited::printer::CompareUnits $al(_unittree,$TID)]
    } else {
      set items $al(_unittree,$TID)
    }
    foreach item $items {
      if {[llength $item]<3} continue
      lassign $item lev leaf fl1 title l1 l2
      set title [::apave::NormalizeName $title]
      if {$title eq {}} {
        set title $ftail
        set leaf 0
      }
      set ttl [string map {" " _} $title]
      if {$leaf} {
        set tip " $title[UnitTooltip $wtxt $l1 $l2]"
        set link [GetLeafLink #$ttl $title $tip]
      } else {
        if {$dosort} {
          set title [string trimleft $title]
        } else {
          set title [string repeat {&nbsp;} [expr {$lev*2}]]$title
        }
        set link [GetBranchLink #$ttl $title]
      }
      append link \n$wclink
      set tpl [string map [list $wclink $link] $tpl]
      set l1 [expr {max(0,$l1-2)}]
      set line [lindex $contlist $l1]
      set contlist [lreplace $contlist $l1 $l1 "$line${wclt}a id=$ttl${wcgt}${wclt}/a${wcgt}"]
    }
    set cont {}
    foreach line $contlist {append cont $line\n}
  }
  lassign [GetReadme [file dirname $fname]] readme rmname
  if {$readme eq {}} {
    set bttl {}
    set rmttl $leafttl
  } else {
    set bttl $leafttl
    set rmttl [string map [list $wctitle [file tail $rmname]] $leafttl]
  }
  set rootpath [file dirname [::apave::FileRelativeTail $dir $fname2]]
  set csspath [file join $rootpath $CSS $cssname]
  set tpl [string map [list $wclink {} $wcrmcon $readme $wcrmttl $rmttl $wcbttl $bttl] $tpl]
  set tpl [string map [list $wcleaft $leafttl] $tpl]
  set tpl [string map [list $wctitle $ftail $wcstyle $csspath] $tpl]
  set tpl [string map [list $wcfg $leaffg $wcbg $leafbg] $tpl]
  set tpl [string map [list $wcback [file join $rootpath $indexname]] $tpl]
  set cont [Off_Html_tags $cont]
  set tmpC "$prebeg$cont$preend"
  set tmpC [string map [list $wcbody $tmpC] $tpl]
  set fname2 [file rootname $fname2].html
  writeTextFile $fname2 ::alited::printer::tmpC
  Hl_html $fname2
  set tmpC [readTextFile $fname2]
  set tmpC [string map [list ${wclt} < ${wcgt} >] $tmpC]
  append tmpC \n$copyright
  writeTextFile $fname2 ::alited::printer::tmpC
  return $fname2
}
#_______________________

proc printer::RunFinal {{check no}} {
  # Runs final processor.
  #   check - if yes, beeps at empty final processor.

  fetchVars
  if {$final ne {}} {
    set fname [file join $dir $indexname]
    if {$final eq {%D} || $final eq {"%D"}} {
      openDoc $fname
    } elseif {$final eq {%e}} {
      alited::file::OpenFile $fname
      return yes
    } else {
      set com [string map [list %D $dir] $final]
      if {[string first e_menu.tcl $com]>0 && [string first m=%M $com]>0} {
        # e_menu items require project name & Linux/Windows terminals
        append com " PN=$al(prjname) \"tt=$al(EM,tt=)\" \"wt=$al(EM,wt=)\""
      }
      set com [alited::MapWildCards $com]
      exec -- {*}$com &
    }
  } elseif {$check} {
    set final {"%D"}
    focusByForce [$obDl2 chooserPath Fil]
    bell
  }
  return no
}
#_______________________

proc printer::Process {wtree} {
  # Processes files to make the resulting .html.
  #   wtree - tree's path

  fetchVars
  set colors [::hl_tcl::hl_colors $cs 0]
  if {$mdproc eq {alited}} MdInit
  set index_to [file join $dir $indexname]
  set filesdir [file join $dir $FILES]
  if {![file exists $index_to]} {
    # make empty index.html, to get rid of possible error messages
    set readmecont $copyleft
    writeTextFile $index_to ::alited::printer::readmecont
  }
  if {![CheckData]} {return no}
  if {![CheckDir]} {return no}
  if {![CheckTemplates]} {return no}
  lassign [GetReadme $al(prjroot)] readmecont rmname
  set indexcont [readTextFile $indextpl]
  set indexcont [string map [list $wcrmcon $readmecont $wcbody {}] $indexcont]
  GetCss
  set curdir {}
  set fcnt [set dcnt 0]
  foreach itemID [lsort -dictionary $markedIDs] {
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
      set indexcont [string map [list $wclink $link] $indexcont]
      Message $cdir 3
      update
    }
    set fname2 [GetFileName $cdir2 $fname]
    set fname2 [file join $filesdir $fname2]
    if {$dodir} {
      catch {file mkdir [file dirname $fname2]}
    }
    set fname [MakeFile $fname $fname2]
    set link [GetLeafLink $fname [file tail $fname2] {} $dir]
    append link \n$wclink
    set indexcont [string map [list $wclink $link] $indexcont]
    incr fcnt
  }
  if {$rmname eq {}} {
    set rmttl $leafttl
  } else {
    set rmttl [string map [list $wctitle [file tail $rmname]] $leafttl]
  }
  set csspath [file join $CSS $cssname]
  set indexcont [string map [list $wcleaft $leafttl $wcrmttl $leafttl] $indexcont]
  set ttl ":: $al(prjname) ::"
  set indexcont [string map [list $wctitle $ttl $wctoc $ttl] $indexcont]
  set indexcont [string map [list $wclink {} $wcback {} $wcstyle $csspath] $indexcont]
  set indexcont [string map [list $wcfg $ttlfg $wcbg $ttlbg $wcbttl {}] $indexcont]
  append indexcont \n$copyright
  writeTextFile $index_to ::alited::printer::indexcont 1
  Hl_html $index_to
  set msg [msgcat::mc {Processed: %d directories, %f files}]
  set msg [string map [list %d $dcnt %f $fcnt] $msg]
  Message $msg
  bell
  return [RunFinal]
}

# ________________________ Buttons _________________________ #

proc printer::StdClr {fld1 var1 fld2 var2} {
  # Sets standard colors.
  #   fld1 - 1st color field (and color field to focus)
  #   var1 - 1st color variable name
  #   fld2 - 2nd color field
  #   var2 - 2nd color variable name

  fetchVars
  set $var1 [set ::alited::printer::STD$var1]
  set $var2 [set ::alited::printer::STD$var2]
  set lab1 [$obDl2 chooserPath $fld1 lab]; $lab1 configure -background [set $var1]
  set lab2 [$obDl2 chooserPath $fld2 lab]; $lab2 configure -background [set $var2]
  focus [$obDl2 chooserPath $fld1]
}
#_______________________

proc printer::Help {} {
  # Handles "Help" button.

  fetchVars
  alited::Help $win
}
#_______________________

proc printer::Ok {} {

  fetchVars
  set wtree [$obDl2 Tree]
  set geometry [wm geometry $win]
  set width1 [$wtree column #0 -width]
  set width2 [$wtree column #1 -width]
  SaveIni
  if {[Process $wtree]} {$obDl2 res $win 1}
}
#_______________________

proc printer::Cancel {} {
  # Cancel handling the dialog.

  fetchVars
  $obDl2 res $win 0
}

# ________________________ GUI _________________________ #

proc printer::FillTree {wtree} {
  # Populates the tree of project files.
  #   wtree - tree's path

  fetchVars
  $wtree heading #0 -text ":: $al(prjname) ::"
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

  fetchVars
  set tipmark "[msgcat::mc (Un)Select]\nSpace"
  lassign [alited::FgFgBold] -> fgbold
  set wden 44
  $obDl2 makeWindow $win.fra [msgcat::mc {Project Printer}]
  $obDl2 paveWindow $win.fra {
    {labh - - 1 3 {} {-t {Project Printer} -foreground $fgbold -font {$::apave::FONTMAINBOLD}}}
    {fraTop labh L 1 3 {-st ew}}
    {.btTmark - - - - {pack -padx 4 -side left} \
      {-image alimg_ok -com alited::printer::MarkUnmarkFile  -tip {$tipmark}}}
    {.sev2 - - - - {pack -side left -fill y -padx 5}}
    {.btTCtr - - - - {pack -side left -padx 4} \
      {-image alimg_minus -com {alited::printer::ExpandContract no} -tip "Contract All"}}
    {.btTExp - - - - {pack -side left} \
      {-image alimg_plus -com {alited::printer::ExpandContract} -tip "Expand All"}}
    {.btTExp2 - - - - {pack -side left -padx 4} \
      {-image alimg_add -com {alited::printer::ExpandMarked} -tip "Expand Selected"}}
    {fraBody labh T 1 3 {-st news}}
    {.lab1 - - 1 1 {-st nw} {-t {Output directory:}}}
    {.Dir + T 1 3 {-st new} {-tvar ::alited::printer::dir -w $wden}}
    {.v_1 + T 1 1 {-pady 8}}
    {.lab2 + T 1 1 {-st nw} {-t {Markdown processor:}}}
    {.cbx + T 1 3 {-st nw} {-tvar ::alited::printer::mdproc \
      -value {$::alited::printer::mdprocs} -w $wden}}
    {.v_2 + T 1 3 {-pady 8}}
    {.lfr + T 1 3 {-st nwe} {-t {Directory title colors}}}
    {.lfr.lab1 - - 1 1 {-st ne} {-t {Foreground:}}}
    {.lfr.Clr1 + L 1 1 {-st new} {-tvar ::alited::printer::ttlfg}}
    {.lfr.butClr1 + L 1 1 {-st new} {-t Standard -takefocus 0 \
      -com {alited::printer::StdClr Clr1 ttlfg Clr2 ttlbg}}}
    {.lfr.lab2 .lfr.lab1 T 1 1 {-st ne} {-t {Background:}}}
    {.lfr.Clr2 + L 1 1 {-st new} {-tvar ::alited::printer::ttlbg}}
    {.v_3 .lfr T 1 1 {-pady 8}}
    {.lfr2 + T 1 3 {-st nwe} {-t {File title colors}}}
    {.lfr2.lab1 - - 1 1 {-st ne} {-t {Foreground:}}}
    {.lfr2.Clr3 + L 1 3 {-st nw} {-tvar ::alited::printer::leaffg}}
    {.lfr2.butClr3 + L 1 1 {-st new} {-t Standard -takefocus 0 \
      -com {alited::printer::StdClr Clr3 leaffg Clr4 leafbg}}}
    {.lfr2.lab2 .lfr2.lab1 T 1 1 {-st ne} {-t {Background:}}}
    {.lfr2.Clr4 + L 1 3 {-st nw} {-tvar ::alited::printer::leafbg}}
    {.fraw .lfr2 T 1 3 {-st nw -pady 6}}
    {.fraw.labcs - - 1 1 {-st ne -pady 4} {-t {Syntax colors:}}}
    {.fraw.rad1 + L 1 1 {-st nsw -padx 4} {-var ::alited::printer::cs -value 1 -t 1}}
    {.fraw.rad2 + L 1 1 {-st nsw -padx 9} {-var ::alited::printer::cs -value 2 -t 2}}
    {.fraw.rad3 + L 1 1 {-st nsw -padx 4} {-var ::alited::printer::cs -value 3 -t 3}}
    {.fraw.rad4 + L 1 1 {-st nsw -padx 9} {-var ::alited::printer::cs -value 4 -t 4}}
    {.fraw.labst .fraw.labcs T 1 1 {-st nse} {-t {Sort units:}}}
    {.fraw.swist + L 1 1 {-st nsw -padx 4} {-var alited::printer::dosort}}
    {.fraw.labwc .fraw.labst T 1 1 {-st nse} {-t {Width of contents:}}}
    {.fraw.SpxCwidth + L 1 4 {-st nsw -padx 4} \
      {-tvar ::alited::printer::cwidth -from 5 -to 99 -w 4 -justify center}}
    {.seh .fraw T 1 3 {-pady 8}}
    {.lab4 + T 1 2 {-st nw} {-t {Final processor:}}}
    {.btT + L 1 1 {-st e -padx 3} {-image alimg_run \
      -com {alited::printer::RunFinal 1} -tip {Runs the final processor.}}}
    {.Fil .lab4 T 1 3 {-st new} {-tvar ::alited::printer::final -w $wden}}
    {fraTree fraTop T 2 1 {-st news -cw 1}}
    {.Tree - - - - {pack -side left -fill both -expand 1} \
      {-height 20 -columns {L1 L2 PRL ID LEV LEAF FL1} -displaycolumns {L1} \
      -columnoptions "#0 {-width $width1} L1 {-width $width2 -anchor e}" \
      -style TreeNoHL -selectmode browse -tip {-BALTIP {alited::tree::GetTooltip %i %c} \
      -SHIFTX 10}}}
    {.SbvTree fraTree.Tree L - - {pack -side right -fill both}}
    {fraMid fraBody T 1 3 {-st wes -rw 1 -padx 2}}
    {.seh1 - - - - {pack -side top -expand 1 -fill both -pady 4}}
    {.butHelp - - - - {pack -side left} {-t Help -com alited::printer::Help -takefocus 0}}
    {.h_ - - - - {pack -side left -expand 1 -fill both -padx 4}}
    {.butOK - - - - {pack -side left} {-t OK -com alited::printer::Ok}}
    {.butCancel - - - - {pack -side left -padx 2} {-t Cancel -com alited::printer::Cancel}}
    {.TexTmp - - - - {pack forget -side left}}
    {.TexTmp2 - - - - {pack forget -side left}}
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
  bind [$obDl2 Labstat1] <Button-1> alited::printer::ProcMessage
  alited::tree::AddTags $wtree
  FillTree $wtree
  $obDl2 showModal $win -resizable 1 -minsize {500 400} -geometry $geometry -focus Tab
  catch {destroy $win}
}
#_______________________

proc printer::_run  {} {
  # Runs Project Printer dialogue.

  fetchVars
  set dir [file join [apave::HomeDir] TMP alited $al(prjname)]
  set tpldir [file join $DATADIR printer]
  set indextpl [file join $tpldir $indexname]
  set indextpl2 [file join $tpldir $indexname2]
  set titletpl [file join $tpldir title.html]
  set cssdir [file join $tpldir $CSS]
  set csstpl [file join $cssdir $cssname]
  set inifile [file join $INIDIR printer.ini]
  set iniprjfile [file join $PRJDIR $al(prjname).prn]
  ReadIni
  _create
}

# ________________________ EOF _________________________ #
