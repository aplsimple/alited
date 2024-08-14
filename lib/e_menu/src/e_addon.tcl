
# Additional functions for e_menu.tcl.
# These are put here to source them at need only.

# ________________________ Common procs _________________________ #

proc ::em::mergePosList {none args} {
  # Merges lists of numbers that are not-coinciding and sorted.
  #   none - a number to be not allowed in the lists (e.g. less than minimal)
  #   args - list of the lists to be merged
  # Returns a list of pairs: index of list + item of list.
  # E.g.
  #   mergePosList -1 {1 5 8} {2 3 9 12} {0 6 10}
  #   => {2 0} {0 1} {1 2} {1 3} {0 5} {2 6} {0 8} {1 9} {2 10} {1 12}

  set itot [set ilist 0]
  set lind [set lout [list]]
  foreach lst $args {
    incr ilist
    incr itot [set llen [llength $lst]]
    lappend lind [list 0 $llen]
  }
  for {set i 0} {$i<$itot} {incr i} {
    set min $none
    set ind -1
    for {set k 0} {$k<$ilist} {incr k} {
      lassign [lindex $lind $k] li llen
      if {$li < $llen} {
        set e [lindex [lindex $args $k] $li]
        if {$min == $none || $min > $e} {
          set ind $k
          set min $e
          set savli [incr li]
          set savlen $llen
        }
      }
    }
    if {$ind == -1} {return -code error {Error: probably in the input data}}
    lset lind $ind [list $savli $savlen]
    lappend lout [list $ind $min]
  }
  return $lout
}
#_______________________

proc ::em::countCh {str ch {plistName ""}} {
  # Counts a character in a string.
  #   str - a string
  #   ch - a character
  #   plistName - variable name for a list of positions of *ch*
  # Returns a number of non-escaped occurences of character *ch* in
  # string *str*.
  # See also:
  # [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/Reformatting+Tcl+code+indentation)

  if {$plistName ne {}} {
    upvar 1 $plistName plist
    set plist [list]
  }
  set icnt [set begidx 0]
  while {[set idx [string first $ch $str]] >= 0} {
    set backslashes 0
    set nidx $idx
    while {[string equal [string index $str [incr nidx -1]] \\]} {
      incr backslashes
    }
    if {$backslashes % 2 == 0} {
      incr icnt
      if {$plistName ne {}} {lappend plist [expr {$begidx+$idx}]}
    }
    incr begidx [incr idx]
    set str [string range $str $idx end]
  }
  return $icnt
}
#_______________________

proc ::em::countCh2 {str ch {plistName ""}} {
  # Counts a character in a string.
  #   str - a string
  #   ch - a character
  #   plistName - variable name for a list of positions of *ch*
  # Returns a number of ANY occurences of character *ch* in string *str*.
  # See also: countCh

  if {$plistName ne {}} {
    upvar 1 $plistName plist
    set plist [list]
  }
  set icnt [set begidx 0]
  while {[set idx [string first $ch $str]] >= 0} {
    set nidx $idx
    incr icnt
    if {$plistName ne {}} {lappend plist [expr {$begidx+$idx}]}
    incr begidx [incr idx]
    set str [string range $str $idx end]
  }
  return $icnt
}
#_______________________

proc ::em::matchedBrackets {w inplist curpos schar dchar dir} {
  # Finds a match of characters (dchar for schar).
  #   w - text's path
  #   inplist - list of strings where to find a match
  #   curpos - position of schar in nl.nc form where nl=1.., nc=0..
  #   schar - source character
  #   dchar - destination character
  #   dir - search direction: 1 to the end, -1 to the beginning of list

  lassign [split $curpos .] nl nc
  if {$schar eq {"}} {
    # for plain texts:
    set npos $nl.$nc
    if {[$w search -exact \" "$npos +1 char" end] eq {}} {
      set dir -1
    } else {
      set lfnd [$w search -backwards -all -exact \" "$npos -1 char" 1.0]
      if {[llength $lfnd] % 2} {
        set dir -1
      }
    }
    incr nc $dir
  }
  if {$dir==1} {set rng1 "$nc end"} else {set rng1 "0 $nc"; set nc 0}
  set retpos {}
  set scount [set dcount 0]
  incr nl -1
  set inplen [llength $inplist]
  while {$nl>=0 && $nl<$inplen} {
    set line [lindex $inplist $nl]
    set line [string range $line {*}$rng1]
    set sc [countCh2 $line $schar slist]
    set dc [countCh2 $line $dchar dlist]
    set plen [llength [set plist [mergePosList -1 $slist $dlist]]]
    for {set i [expr {$dir>0?0:($plen-1)}]} {$i>=0 && $i<$plen} {incr i $dir} {
      lassign [lindex $plist $i] src pos
      if {$src} {incr dcount} {incr scount}
      if {$scount <= $dcount} {
        set retpos [incr nl].[incr pos $nc]
        break
      }
    }
    if {$retpos ne {}} break
    set nc 0
    set rng1 {0 end}
    incr nl $dir
  }
  return $retpos
}
#_______________________

proc ::em::IF {sel {callcommName ""}} {
  # Processes %IF wildcard.

  set sel [string range $sel 4 end]
  set pthen [string first { %THEN } $sel]
  set pelse [string first { %ELSE } $sel]
  if {$pthen > 0} {
    if {$pelse < 0} {set pelse 1000000}
    set ifcond [string trim [string range $sel 0 $pthen-1]]
    if {[catch {set res [expr $ifcond]} e]} {
      emMessage "ERROR: incorrect condition of IF:\n$ifcond\n\n($e)"
      return false
    }
    set thencomm [string trim [string range $sel $pthen+6 $pelse-1]]
    set comm     [string trim [string range $sel $pelse+6 end]]
    if {$res} {
      set comm $thencomm
    }
    set comm [string trim $comm]
    catch {set comm [subst -nobackslashes $comm]}
    set ::em::IF_exit [expr {$comm ne {}}]
    if {$callcommName ne {}} {
      upvar 2 $callcommName callcomm ;# to run in a caller
      set callcomm $comm
      return true
    }
    if {$::em::IF_exit} {
      switch -exact -- [string range $comm 0 2] {
        {%I } {
          # ::Input variable can be used for the input
          # (others can be set beforehand by "%C set varname varvalue")
          if {![info exists ::Input]} {
            set ::Input {}
          }
          return [::em::addon input $comm]
        }
        {%C } {set comm [string range $comm 3 end]}
        default {
          if {[lindex [set _ [checkForWilds comm]] 0]} {
            return [lindex $_ 1]
          } elseif {[checkForShell comm]} {
            shell0 $comm &
          } else {
            set argm [lrange $comm 1 end]
            set comm1 [lindex $comm 0]
            if {$comm1 eq {%O}} {
              ::apave::openDoc $argm
            } else {
              if {[::iswindows]} {
                set comm $::em::windowsconsole\ $comm
              }
              if {[catch {exec -- {*}$comm &} e]} {
                emMessage "ERROR: incorrect command of IF:\n$comm\n\n($e)"
              }
            }
          }
          return false ;# to run the command and exit
        }
      }
      catch {[{*}$comm]}
    }
  }
  return true
}

# ________________________ Popup menu _________________________ #

proc ::em::iconA {{icon none}} {
  # Gets -image option for popup menu.

  return "-image [::apave::iconImage $icon] -compound left"
}
#_______________________

proc ::em::createpopup {} {
  # Creates e_menu's popup menu.

  menu .em.emPopupMenu
  if {$::eh::pk ne {}} {
    .em.emPopupMenu add command {*}[iconA ok] \
      -label Select -command {::em::SelectItem}
  } else {
    .em.emPopupMenu add command {*}[iconA folder] -accelerator Ctrl+P \
      -label Project... -command ::em::changePD
  }
  .em.emPopupMenu add separator
  .em.emPopupMenu add command {*}[iconA change] -accelerator Ctrl+E \
    -label {Edit the menu} -command {after 50 ::em::editMenu}
  if {($::em::solo || [isSMenu]) && ![isChild]} {
    .em.emPopupMenu add command {*}[iconA retry] -accelerator Ctrl+R \
      -label {Restart e_menu} -command ::em::restartEMenu
  } else {
    .em.emPopupMenu add command {*}[iconA retry] -accelerator Ctrl+R \
      -label {Reread the menu} -command ::em::rereadInit
  }
  .em.emPopupMenu add command {*}[iconA delete] -accelerator Ctrl+D \
    -label {Destroy other menus} -command ::em::destroyEMenus
  .em.emPopupMenu add separator
  .em.emPopupMenu add command {*}[iconA plus] -accelerator Ctrl+> \
    -label {Increase the menu's width} -command {::em::winWidth 1}
  .em.emPopupMenu add command {*}[iconA minus] -accelerator Ctrl+< \
    -label {Decrease the menu's width} -command  {::em::winWidth -1}
  .em.emPopupMenu add separator
  .em.emPopupMenu add command {*}[iconA info] -accelerator F1 \
    -label About... -command ::em::about
  .em.emPopupMenu add separator
  .em.emPopupMenu add command {*}[iconA exit] -accelerator Esc \
    -label Close -command ::em::onExit
  .em.emPopupMenu configure -tearoff 0
}
#_______________________

proc ::em::popup {X Y} {
  # Calls e_menu's popup menu.

  set ::em::skipfocused 1
  if {[winfo exist .em.emPopupMenu]} {destroy .em.emPopupMenu}
  ::em::createpopup
  obj themePopup .em.emPopupMenu
  tk_popup .em.emPopupMenu $X $Y
}

# ________________________ Editing menus _________________________ #

proc ::em::menuTextModified {w bfont} {
  # Handles modifications of menu's text: highlights R/S/M in menu's text.
  #   w - text's path
  #   bfont - font of boldness
  # The `w` might be omitted because it's a `my TexM` of APaveDialog.
  # It's here only to provide a template for similar handlers.

  bind $w <KeyPress> [list after idle "::em::LineView $w"]
  bind $w <ButtonPress> [list after idle "::em::LineView $w"]
  after idle [list ::em::LineView $w]
  set curpos [$w index insert]
  set text [$w get 1.0 end]
  if {[obj csDark]} {
    set fg1 orange
    set fg2 black
    set bg2 #84e284
    set fg3 #848484
  } else {
    set fg1 #923B23
    set fg2 white
    set bg2 #0c560c
    set fg3 #606060
  }
  $w tag config tagNORM -font "-family {[obj basicTextFont]} -size [obj basicFontSize]"
  $w tag add tagNORM 1.0 end
  $w tag config tagRSIM -font $bfont -foreground $fg1
  $w tag config tagMARK -font $bfont -foreground $bg2
  $w tag config tagSECT -font $bfont -foreground $fg2 -background $bg2
  append bfont " -weight normal -slant italic"
  $w tag config tagCMNT -font $bfont -foreground $fg3
  # firstly, to highlight R/S/M
  foreach line [split $text \n] {
    incr il
    $w tag remove tagRSIM $il.0 $il.end
    $w tag remove tagMARK $il.0 $il.end
    $w tag remove tagSECT $il.0 $il.end
    $w tag remove tagCMNT $il.0 $il.end
    lassign [::em::getRSIM $line {ITEM\s*=|SEP\s*=|%M[^ ] |%C |\[MENU\]\s*$|\[OPTIONS\]\s*$|\[HIDDEN\]\s*$|\[DATA\]\s*$|^\s*#}] marker pg ln
    if {$marker ne {}} {
      set p1 [string first $marker $line]
      set p2 [expr {$p1+[string length $marker]}]
      if {$pg ne {-}} {
        set tag tagRSIM
      } else {
        switch -- [string index $ln 0] {
          \[ {set tag tagSECT}
          \# {set tag tagCMNT; set p2 end}
          default {
            set tag tagMARK
            if {[string first = $marker]>0} {set p2 end}
          }
        }
      }
      $w tag add $tag $il.$p1 $il.$p2
    }
  }
}
#_______________________

proc ::em::LineView {{w ""}} {
  # Highlights a current line at viewing a text.
  #   w - text's path
  # If *w* is omitted, initializes its own variable.

  if {$w eq {} || ![winfo exists $w]} {
    set ::em::lnTextView -1
    return
  }
  set pos [$w index insert]
  set ln [expr {int($pos)}]
  if {![info exists ::em::lnTextView] || $ln!=$::em::lnTextView} {
    set ::em::lnTextView $ln
    $w tag config tagCURLINE -background [lindex [obj csGet] 16]
    $w tag lower tagCURLINE
    $w tag remove tagCURLINE 1.0 end
    $w tag add tagCURLINE [list $pos linestart] [list $pos lineend]+1displayindices
  }
}
#_______________________

proc ::em::menuTextBrackets {w fg boldfont} {
  # Makes bindings to highlight brackets of menu's text: {}()[]
  #   w - text's path
  #   fg - foreground color to select {}()[]
  #   boldfont - font of boldness
  # The `w` might be omitted because it's a `my TexM` of APaveDialog.
  # It's here only to provide a template for similar handlers.

  foreach ev {Enter KeyRelease ButtonRelease} {
    ::apave::bindToEvent $w <$ev> ::em::highlightBrackets $w $fg $boldfont
  }
}
#_______________________

proc ::em::highlightBrackets {w fg boldfont} {
  # Highlights brackets in menu's text.

  $w tag delete tagBRACKET
  $w tag delete tagBRACKETERR
  $w tag configure tagBRACKET -foreground $fg -font $boldfont
  $w tag configure tagBRACKETERR -foreground white -background red
  set curpos [$w index insert]
  set curpos2 [$w index {insert -1 chars}]
  set ch [$w get $curpos]
  set lbr "\{(\[\""
  set rbr "\})\]\""
  set il [string first $ch $lbr]
  set ir [string first $ch $rbr]
  set txt [split [$w get 1.0 end] \n]
  if {$il>-1} {
    set brcpos [matchedBrackets $w $txt $curpos \
      [string index $lbr $il] [string index $rbr $il] 1]
  } elseif {$ir>-1} {
    set brcpos [matchedBrackets $w $txt $curpos \
      [string index $rbr $ir] [string index $lbr $ir] -1]
  } elseif {[set il [string first [$w get $curpos2] $lbr]]>-1} {
    set curpos $curpos2
    set brcpos [matchedBrackets $w $txt $curpos \
      [string index $lbr $il] [string index $rbr $il] 1]
  } elseif {[set ir [string first [$w get $curpos2] $rbr]]>-1} {
    set curpos $curpos2
    set brcpos [matchedBrackets $w $txt $curpos \
      [string index $rbr $ir] [string index $lbr $ir] -1]
  } else {
    return
  }
  if {$brcpos ne {}} {
    $w tag add tagBRACKET $brcpos
    $w tag add tagBRACKET $curpos
  } else {
    $w tag add tagBRACKETERR $curpos
  }
}
#_______________________

proc ::em::edit {fname {prepost ""} {istpl yes}} {
  # Edit a text file.

  set fname [string trim $fname]
  if {$istpl} {
    set buttons [list -buttons {Template ::em::template::help}]
  } else {
    set buttons {}
  }
  if {$::em::editor eq {} || $prepost ne {}} {
    ::em::LineView
    set bfont [obj boldTextFont [obj basicFontSize]]
    set dialog [::apave::APave new]
    set res [$dialog editfile $fname {} {} {} \
      $prepost -w {80 100} -h {10 24} -ro 0 -centerme .em \
      -ontop $::em::ontop {*}$buttons \
      -myown [list my TextCommandForChange %w "::em::menuTextModified %w {$bfont}"\
       true "::em::menuTextBrackets %w magenta {$bfont}"]]
    $dialog destroy
    return $res
  } else {
    if {[catch {exec -- {*}$::em::editor {*}$fname &} e]} {
      emMessage "ERROR: couldn't call $::em::editor'\n
to edit $fname.\n\nCurrent directory is [pwd]\n\nMaybe $::em::editor\n is worth including in PATH?"
      return false
    }
  }
  return true
}
#_______________________

proc ::em::prepostEdit {refdata {txt ""}} {
  # Pre and post actions for edit (e.g. get/set position of cursor).

  upvar 1 $refdata data
  set opt [set i 0]
  set attr pos=
  set datalist [split [string trimright $data] \n]
  foreach line $datalist {
    if {$line eq {[OPTIONS]}} {
      set opt 1
    } elseif {$opt && [string match "${attr}*" $line]} {
      break
    } elseif {$line eq {[MENU]} || $line eq {[HIDDEN]}} {
      set opt 0
    }
    incr i
  }
  if {!$opt && $txt eq {}} {return {}}  ;# if no OPTIONS section, nothing to do
  if {$txt eq {}} {
    # it's PRE
    lassign [regexp -inline "^${attr}(.*)" $line] line pos
    if {$line ne {}} {set line "-pos $pos"}
    return $line  ;# 'position of cursor' attribute
  } else {
    # it's POST
    set attr "${attr}[$txt index insert]"
    if {$opt} {
      lset datalist $i $attr
    } else {
      lappend datalist \n {[OPTIONS]} $attr   ;# long live OPTIONS
    }
    set data [join $datalist \n]
  }
}
#_______________________

proc ::em::editMenu {} {
  # Edits the current menu.

  if {[::em::edit $::em::menufilename ::em::prepostEdit]} {
    # colors can be changed, so "rereadMenu" with setting colors
    foreach w [winfo children .em] {  ;# remove Tcl/Tk menu items
      destroy $w
    }
    ::em::initdefaultcolors
    initcomm
    ::em::initcolorscheme
    initmenu
    mouseButton $::em::lasti
  } else {
    repaintForWindows
  }
}

# ________________________ Environment _________________________ #

proc ::em::isSMenu {} {
  # Checks if it is s_menu (stand-alone e_menu).

  expr {[file rootname [file tail $::em::Argv0]] eq "s_menu"}
}
#_______________________

proc ::em::restartEMenu {} {
  # Restarts the e_menu app.

  if {[isSMenu] && [file extension $::em::Argv0] ne ".tcl"} {
    exec -- $::em::Argv0 {*}$::em::Argv &
  } else {
    exec -- [::em::Tclexe] $::em::Argv0 {*}$::em::Argv &
  }
  onExit
}
#_______________________

proc ::em::rereadInit {} {
  # Rereads a menu and autorun.

  rereadMenu $::em::lasti
  set ::em::filecontent {}
  initauto
}
#_______________________

proc ::em::winWidth {inc} {
  # Increments / decrements window width.

  set inc [expr $inc*$::em::incwidth]
  lassign [split [wm geometry .em] +x] newwidth height
  incr newwidth $inc
  if {$newwidth > $::em::minwidth || $inc > 0} {
    wm geometry .em ${newwidth}x${height}
  }
}
#_______________________

proc ::em::destroyEMenus {} {
  # Destroys all e_menu apps.

  if {[emQuestion "Clearance - $::em::appname" \
  "\n  Destroy all e_menu applications?  \n" yesno ques NO -text 0 -ontop $::em::ontop]} {
    for {set i 0} {$i < 3} {incr i} {
      for {set nap 1} {$nap <= 64} {incr nap} {
        set app $::em::thisapp$nap
        if {$nap != $::em::appN} {::eh::destroyed $app}
      }
    }
    if {$::em::ischild || $::em::geometry eq {}} {
      destroy .  ;# do not kill self if am a parent app with geometry passed
    }
  }
  repaintForWindows
}
#_______________________

proc ::em::createEm {mnuname} {
  # Checks if a menu has to be converted for .em extension of the menu.
  #   mnuname - menu file name
  # Returns: yes, if the conversion done.

  set mnuname [menuFullname $mnuname .mnu]
  set emname [menuFullname $mnuname]
  set ismnu [file exists $mnuname]
  set isem [file exists $emname]
  if {!$ismnu || $isem} {return no} ;# nothing to convert
  set dir [file dirname $mnuname]
  set com [Tclexe]\ [file join $::em::exedir src e_mnu2em.tcl]
  if {[::Q {Converting .mnu to .em} " The [file tail $$mnuname] and other .mnu files \
    \n must be converted to .em files. \n \
    \n $::em::em_version can't do without the conversion! \n \
    \n Anyhow, you can convert .mnu to .em with these commands: \n \
    \n   cd $dir \
    \n   $com"]
  } {
    cd $dir
    shell0 $com
    return yes  ;# must be restarted
  }
  ::EXIT
}

# ________________________ About... _________________________ #

proc ::em::about {} {
  # Shows "About..." box.

  set textTags [list [list red " -font {-weight bold -size 12} \
    -foreground $::em::clractf -background $::em::clractb"] \
    [list link {::eh::browse %t@@https://%l}] \
    [list linkM {::apave::openDoc %l@@e-mail: %l}] \
    ]
  set width [expr {max(33,[string length $::em::Argv0])}]
  set doc https://aplsimple.github.io/en/tcl/e_menu
  set dialog [::apave::APave new]
  if {$::em::solo} {set mod solo} {set mod {}}
  set res [$dialog misc info {About e_menu} "\n\
    <red> $::em::em_version </red> $mod \n\n\
    [file dirname $::em::Argv0] \n\n\
    by Alex Plotnikov \n\n\
    <linkM>aplsimple@gmail.com</linkM> \n\
    <link>aplsimple.github.io</link> \n\
    <link>chiselapp.com/user/aplsimple</link> \n\n" "{Help:: $doc } 1 Close 0" \
    0 -t 1 -w $width -scroll 0 -tags textTags -head \
    "\n Menu system for editors and file managers. \n" \
    -ontop $::em::ontop -centerme .em {*}[themingPave]]
  $dialog destroy
  if {[lindex $res 0]} {::eh::browse $doc}
  repaintForWindows
}

# ________________________ Project... _________________________ #

proc ::em::changePDspx {} {
  # Gets a color scheme's attributes for 'Project...' dialogue.

  lassign [obj csGet $::em::ncolor] - fg - bg
  set labmsg [::em::dialog LabMsg]
  set font [font configure TkFixedFont]
  dict set font -size $::em::fs
  set txt [obj csGetName $::em::ncolor]
  set txt [string range [append txt [string repeat " " 20]] 0 20]
  $labmsg configure -foreground $fg -background $bg -font $font \
    -padding {16 5 16 5} -text $txt
}
#_______________________

proc ::em::none {args} {
  # A stub doing nothing.

  return {}
}
#_______________________

proc ::em::changePD {} {
  # Changes a project's directory and other parameters.

  if {![file isfile $::em::PD]} {
    set message " WARNING:\n\
      '$::em::PD' isn't a file.\n\
      \n\
      'PD=file of project directories'\n\
      should be an argument of e_menu to use %PD in menus. \n"
    set fco1 {}
  } else {
    set message "\n Select a project directory from the list of file:\n $::em::PD  \n"
    set fco1 [list \
      fco1 [list {Project:} {} \
      [list -h 10 -state readonly -inpval [getPD]]] \
      "@@-RE {^(\\s*)(\[^#\]+)\$} {$::em::PD}@@" \
      btTChange [list {} {-padx 5} "-com {::em::edit {$::em::PD} ::em::none no; \
        ::em::dialog res {} -1} -tip {Click to edit\n$::em::PD} -toprev 1"] {}]
  }
  if {[::iswindows]} {
    set dkst disabled
    set ::em::dk {}
  } else {
    set dkst "normal"
  }
  append message \
    "\n 'Color scheme' is -1 .. [::apave::cs_Max] selected with Up/Down key.  \n"
  set ncolorsav $::em::ncolor
  set fssav $::em::fs
  set geo [wm geometry .em]
  set ornams [list {-2 None} {-1 Top line only} { 0 Help/Exec/Shell} { 1 Help/Exec/Shell + Header} { 2 Help/Exec/Shell + Prompts} { 3 All}]
  switch -exact -- $::em::ornament {
    -2 - -1 - 0 - 1 - 2 - 3 {set ornam [lindex $ornams [expr {$::em::ornament+2}]]}
    default {set ornam [lindex $ornams 3]}
  }
  ::apave::APave create ::em::dialog .em
  set r -1
  while {$r == -1} {
    after 0 {after idle ::em::changePDspx}
    set tip1 "Applied anyhow\nexcept for Default CS"
    set res [::em::dialog input {} Project... [list \
      {*}$fco1 \
      seh_1 {{} {-pady 10}} {} \
      Spx [list "    Color scheme:" {} \
        [list -tvar ::em::ncolor -from -2 -to [::apave::cs_Max] -w 5 \
        -justify center -state $::em::noCS -msgLab {LabMsg {                     } \
        {-padding {16 5 16 5} -font {-family {$::apave::_CS_(textFont)} -size $::em::fs}}} \
        -command ::em::changePDspx -tooltip $tip1]] {} \
      chb1 {{} {-padx 5} {-toprev 1 -state $::em::noCS -t "Use it"}} {0} \
      spx2 [list "       Font size:" {} \
        [list -tvar ::em::fs -from 6 -to 32 -w 5 -justify center -msgLab {Lab_ {}} \
        -command ::em::changePDspx -tooltip $tip1]] {} \
      chb12 {{} {-padx 5} {-toprev 1 -t "Use it"}} {0} \
      seh_22 {{} {-pady 10}} {} \
      cbx1 [list {        Ornament:} {} \
        [list -state readonly -width 10 -tooltip $tip1]] [list $ornam {*}$ornams] \
      chb22 {{} {-padx 5} {-toprev 1 -t "Use it"}} {0} \
      seh_2 {{} {-pady 10}} {} \
      ent2 {"Geometry of menu:"} "$geo" \
      chb2 {{} {-padx 5} {-toprev 1 -t "Use it"}} {0} \
      seh_3 {{} {-pady 10}} {} \
      chbT {"    Type of menu:" {-expand 0} {-w 8 -t "topmost"}} $::em::ontop \
      rad3 [list "                 " {-fill x -expand 1} "-state $dkst"] \
        [list "$::em::dk" dialog dock desktop] \
      chb3 {{} {-padx 5} {-toprev 1 -t "Use it"}} {0} \
    ] -head $message -weight bold -family "{[obj basicTextFont]}" \
    -centerme .em {*}[themingPave]]
    set r [lindex $res 0]
  }
  set ::em::ncolor [::apave::getN $::em::ncolor $ncolorsav -2 [::apave::cs_Max]]
  if {$r} {
    if {$::em::ncolor==-2} {set ::em::ncolor -1}
    if {$fco1 eq {}} {
      lassign $res - - chb1 - chb12 orn chb22 geo chb2 chbT dk chb3
    } else {
      lassign $res - PD - - chb1 - chb12 orn chb22 geo chb2 chbT dk chb3
    }
    set orn [string trim [string range $orn 0 1]]
    # save options to menu's file
    if {$chb1} {saveOptions c= $::em::ncolor}
    if {$chb12} {saveOptions fs= $::em::fs}
    if {$chb2} {saveOptions g= $geo}
    if {$chb22} {saveOptions o= $orn}
    if {$chb3} {
      saveOptions dk= $dk
      saveOptions t= $chbT
    }
    if {($fco1 ne {}) && ([getPD] ne $PD)} {
      set ::em::prjname [file tail $PD]
      set ::em::Argv [::apave::removeOptions $::em::Argv d=* f=*]
      foreach {o v} [list d $PD f "$PD/*"] {lappend ::em::Argv "$o=\"$v\""}
    }
    set ::em::Argv [::apave::removeOptions $::em::Argv c=* fs=* o=* dk=* t=*]
    foreach {o v} [list c $::em::ncolor fs $::em::fs o $orn dk $dk t $chbT] {
      lappend ::em::Argv "$o=$v"
    }
    set ::em::Argc [llength $::em::Argv]

    # the main problems of e_menu's colorizing to solve are:
    #
    #  - e_menu allows to set a color scheme (CS) as an argument (c=)
    #
    #  - e_menu allows to set a part of CS as argument(s) (fg=, fS=...), thus
    #    the appropriate colors of CS are replaced with these ones;
    #    this is good when it's wanted to tune some color(s) of CS to be
    #    applied to the menu; however, this is not applied to dialogs
    #
    #  - e_menu allows to set a whole of CS as arguments (fg=, fS=...), thus
    #    these 'argumented' colors are applied to the menu and dialogs;
    #    this way is followed in TKE editor's e_menu plugin
    #
    #  - e_menu allows to set fI=, bI= arguments for active item's colors;
    #    it's not related to apave's CS and used by e_menu only;
    #    this way is followed in TKE editor's e_menu plugin
    wm deiconify .em
    set ::em::optsFromMenu 0
    set instead [::em::insteadCS]
    array unset ::em::ar_geany
    set ::em::insteadCSlist [list]
    if {$instead} {
      # when all colors are set as e_menu's arguments instead of CS,
      # just set the selected CS and remove the 'argumented' colors
      set ::em::Argv [::apave::removeOptions $::em::Argv \
        fg=* bg=* fE=* bE=* fS=* bS=* cc=* fI=* bI=* fM=* bM=* ht=* hh=* gr=*]
      set ::em::Argc [llength $::em::Argv]
      initcolorscheme true
      # this reads and shows the menu, with the new CS
      rereadMenu $::em::lasti
    } else {
      set ::em::Argc [llength $::em::Argv]
      unsetdefaultcolors
      initdefaultcolors
      initcolorscheme
      rereadMenu $::em::lasti
      # this takes up e_menu's arguments e.g. fS=white bS=green (as part of CS)
      initcolorscheme
    }
  } else {
    set ::em::ncolor $ncolorsav
    set ::em::fs $fssav
  }
  ::em::dialog destroy
  repaintForWindows
}

# ________________________ Input data dialogue _________________________ #

proc ::em::input {cmd} {
  # Input dialog for getting data.

  set dialog [::apave::APave new]
  set dp [string last { == } $cmd]
  if {$dp < 0} {set dp 999999}
  set data [string range $cmd $dp+4 end]
  set geo [centerme]
  set ontop $::em::ontop
  if {[info exists ::em::inputStay] && $::em::inputStay} {
    set ontop 1  ;# dialog was set topmost manually
  }
  set cmd "$dialog input [string range $cmd 2 $dp-1] $geo -ontop $ontop -stay 1"
  catch {set cmd [subst $cmd]}
  if {[set lb [countCh $cmd \{]] != [set rb [countCh $cmd \}]]} {
    dialogBox ERROR " Number of left braces : $lb\n Number of right braces: $rb \
      \n\n not equal!" ok err OK {*}$geo -ontop $ontop
  }
  set res [eval $cmd [themingPave]]
  set win [$dialog dlgPath]
  set r [lindex $res 0]
  # is the dialog set topmost manually? if yes, let it remain (with em::inputStay=1)
  set ::em::inputStay [expr {$r && !$::em::ontop && [winfo exists $win] \
    && [wm attributes $win -topmost]}]
  catch {destroy $win}
  $dialog destroy
  if {$r && $data ne {}} {
    lassign $res -> {*}$data
    foreach n [split $data " "] {
      catch {
        set value [set $n]
        set value [string map [list \n \\n \\ \\\\ \} \\\} \{ \\\{] $value]
        set $n $value
        set ::em::saveddata($n) $value ;# for next possible input dialogue
      }
    }
    saveMenuVars
  }
  set ::em::inputResult $r
  repaintForWindows
  return $r
}
#_______________________

proc ::em::writeableCmd {cmd} {
  # Gets and saves a writeable command.
  # cmd's contents:
  #   0 .. 2   - a unique mark (e.g. %#A for 'A' mark)
  #   3        - a space
  #   4 .. end - options and a command

  set mark [string range $cmd 0 2]
  set cmd  [string range $cmd [set posc 4] end]
  set pos "1.0"
  set geo +100+100
  set menudata [readMenuFile]
  for {set i [set iw [set iwd [set opt 0]]]} {$i<[llength $menudata]} {incr i} {
    set line [lindex $menudata $i]
    if {$line eq {[DATA]}} {
      set opt 1
      set iwd $i
    } elseif {$opt && [string first $mark $line]==0} {
      set iw $i
      set cmd [string range $line $posc end]
      set i1 [string first "geo=" $cmd]
      set i2 [string first ";" $cmd]
      if {$i1>=0 && $i1<$i2} {
        set geo "[string range $cmd $i1+4 $i2-1]"
        set i1 [string first "pos=" $cmd]
        set i2 [string first " " $cmd]
        if {$i1>0 && $i1<$i2} {
          set pos "[string range $cmd $i1+4 $i2-1]"
          set cmd [string range $cmd $i2+1 end]
        }
      }
    } elseif {$line eq {[MENU]} || $line eq {[HIDDEN]}} {
      set opt 0
    }
  }
  set cmd [string map {|!| "\n"} $cmd]
  if {$::em::SH ne {}} {
    # res: "true" (run without dialog), "yes" (run with dialog) or "1" (save only)
    set res true
    set cmd #\ $cmd ;# to fit a result returned by the dialog
  } else {
    set dialog [::apave::APave new]
    set res [$dialog misc {} "EDIT: $mark" "$cmd" {"Save & Run" yes Cancel 0} TEXT \
      -text 1 -ro 0 -w 70 -h 10 -pos $pos {*}[themingPave] -ontop $::em::ontop \
      -head "UNCOMMENT usable commands, COMMENT unusable ones.\nUse  \\\\\\\\ \
      instead of  \\\\  in patterns." -family Times -hsz 14 -size 12 -g $geo]
    $dialog destroy
    lassign $res res geo cmd
  }
  if {$res} {
    set cmd [string trim $cmd " \{\}\n"]
    set data [string map {"\n" |!|} $cmd]
    set data "$mark geo=$geo;pos=$data"
    set cmd [string range $cmd [string first " " $cmd]+1 end]
    if {$iw} {
      set menudata [lreplace $menudata $iw $iw "$data"]
    } else {
      if {$iwd} {
        set menudata [linsert $menudata $iwd+1 "$data"]
      } else {
        lappend menudata {[DATA]} "$data"
      }
    }
    if {$res ne {true}} {::em::writeMenuFile $menudata}
    if {$res in {true yes}} {
      set cmd [string map {"\n" "\\n"} $cmd]
      preprPN cmd
    } else {
      set cmd {}  ;# saving only: after Ctrl+W or "Save & Close" of popup menu
    }
  } else {
    set cmd {}
  }
  focusWin yes
  return $cmd
}

# ________________________ Timed tasks _________________________ #

proc ::em::Task {oper ind {inf 0} {typ 0} {c1 0} {sel 0} {tsec 0} {ipos 0} {iN 0}
{started 0}} {
  # Timed task.

  set task [list $inf $typ $c1 $sel]
  set it [list [expr [clock seconds] + abs(int($tsec))] $ipos $iN]
  switch -exact -- $oper {
    add {
      set i [lsearch -exact $::em::tasks $task]
      if {$i >= 0} {return [list $i 0]}  ;# already exists, no new adding
      lappend ::em::tasks $task
      lappend ::em::taski $it
      set started [startTasks [expr {[llength $::em::tasks] - 1}]]
    }
    upd {
      set ::em::tasks [lreplace $::em::tasks $ind $ind $task]
      set ::em::taski [lreplace $::em::taski $ind $ind $it]
    }
    del {
      set ::em::tasks [lreplace $::em::tasks $ind $ind]
      set ::em::taski [lreplace $::em::taski $ind $ind]
    }
  }
  list $ind $started
}
#_______________________

proc ::em::startSub {ind istart ipos sub typ c1 sel} {
  # Start timed subtask(s) with interval.

  set ::em::ipos $ipos
  if {$ipos == 0 || $sub eq {}} {
    shellrun "Nobutt" $typ $c1 - "&" $sel  ;# this task is current menu item
    if {$ind == $istart} {return true}  ;# safeguard from double start
  } else {
    runAH $sub
  }
  return false
}
#_______________________

proc ::em::getSub {linf ipos} {
  # Get a timed subtask info.

  split [lindex $linf $ipos] :
}
#_______________________

proc ::em::startTasks {{istart -1}} {
  # Start timed task(s).

  set istarted 0
  for {set repeat 1} {$repeat} {} {
    set repeat 0
    set ind 0
    foreach tti $::em::taski { ;# values in sec
      lassign $tti isec ipos iN
      lassign [lindex $::em::tasks $ind] inf typ c1 sel
      if {$ipos==0} {
        incr iN
      }
      set ::em::TN $iN
      set csec [clock seconds]
      if {$csec >= $isec} {
          # check for subtask e.g. -45*60/-15*60:ah=2,3/.../0
        set inf [string trim $inf /]
        set linf [split $inf /]   ;# subtasks are devided with "/"
        set ll [llength $linf]    ;# ipos is position of current subtask
        lassign [getSub $linf $ipos] isec sub ;# current subtask
        if {[startSub $ind $istart $ipos $sub $typ $c1 $sel]} {
          set istarted 1
        }
        if {[incr ipos] >= $ll} {
          set ipos 0
          lassign [getSub $linf $ipos] isec sub ;# 1st subtask
        } else {  ;# process subtask
          lassign [getSub $linf $ipos] isec sub ;# new subtask
          if {[string first TN= $isec]==0} {
            if {$iN >= [::apave::getN [string range $isec 3 end]]} {
              runAH $sub
              Task del $ind  ;# end of task if TN of cycles
              set repeat 1      ;# are completed
              break
            }
            if {[incr ipos] >= $ll} {
              set ipos 0
              set isec 0
            } else {
              lassign [getSub $linf $ipos] isec sub
            }
          } else {  ;# if interval>0, run now
            if {$isec ne {} && [string range $isec 0 0] ne {-}} {
              if {[startSub $ind $istart $ipos $sub $typ $c1 $sel]} {
                set istarted 1
              }
            }
          }
        }
          # update the current task
        Task upd $ind $inf $typ $c1 $sel $isec $ipos $iN
      }
      incr ind
    }
  }
  after [expr $::em::inttimer * 1000] ::em::startTasks
  return $istarted
}
#_______________________

proc ::em::setTask {from inf typ c1 inpsel} {
  # Push/pops timed task.

  set ::em::TN 1
  lassign [split $inf /] timer
  set timer [::apave::getN $timer]
  if {$timer == 0} {return 1}  ;# run once
  if {$timer>0} {set startnow 1} {set startnow 0}
  lassign [Task "add" -1 $inf $typ $c1 $inpsel $timer] ind started
  if {$from eq "button" && $ind >= 0} {
    if {[emQuestion "Stop timed task" "Stop the task\n\n\
        [.em.fr.win.fr$::em::lasti.butt cget -text] ?"]} {
      Task "del" $ind
    }
    return false
  }
  expr {!$started && $startnow}  ;# true if start now, repeat after
}

# ________________________ Template _________________________ #

namespace eval ::em::template {}

proc ::em::template::create {fname} {
  # Creates file.em template

  set res no
  if {[::em::emQuestion "Menu isn't open" \
  "ERROR of opening\n$fname\n\nCreate it?"]} {
    set dir [file dirname $fname]
    if {[file tail $dir] eq $::em::prjname} {
      set menu "$::em::prjname/nam3.em"
    } else {
      set menu [file join $dir "nam3.em"]
    }
    set fcont "\[OPTIONS\]

# specific for this menu, e.g.
#c=45
#om=1

\[MENU\]

ITEM = program name
R: prog

ITEM = shell script
S: command

ITEM = menu name

M: m=$menu o=1
"
    if {[set res [writeTextFile $fname fcont]]} {
      set res [::em::addon edit $fname]
      if {!$res} {file delete $fname}
    }
  }
  return $res
}
#_______________________

proc ::em::template::help {} {
  # view template.em

  obj vieweditFile [file join $::em::exedir src template.em] "" -rotext 0 -ontop $::em::ontop
}

# ________________________ EOF _________________________ #
