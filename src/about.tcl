###########################################################
# Name:    about.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles 'About' form of alited.
# License: MIT.
###########################################################

# _________________________ Variables ________________________ #

namespace eval about {
  variable textTags  ;# text tags to highlight strings
}

# ________________________ Procedures _________________________ #

proc about::textImaged {w} {
  # Makes the feather blink.
  #  w - window's path

  obj labelFlashing [obj textLink $w 5] "" 1 \
    -data $::alited::img::_AL_IMG(feather) -pause 0.5 -incr 0.1 -after 40
}
#_______________________

proc about::About {} {
  # Shows "About" dialogue.

  # alited_checked

  namespace upvar ::alited al al DIR DIR
  variable textTags

  ## ________________________ Preparing tabs _________________________ ##

  ::alited::Source_e_menu
  ::alited::edit::MacroInit
  lassign [obj csGet] fg fg2 bg bg2 - bS fS
  ::apave::InitAwThemesPath $::alited::LIBDIR
  foreach _ {alited apave bartabs baltip hl_tcl playtkl} {
    if {[set v$_ v[package versions $_]] eq {v} \
    && [catch {set v$_ v[package require $_]}]} {
      set v$_ {}
    }
  }
  set font [obj csFontDef]
  obj initLinkFont {*}$font -underline 1 -foreground $fg2 -background $bg2
  append font " -weight bold"

  ### ________________________ Tags and links _________________________ ###

  set textTags [list \
    [list "red" "-font {$font} -foreground $fS -background $bS"] \
    [list "link1" "openDoc %t@@https://%l@@"] \
    [list "link2" "openDoc %t@@https://wiki.tcl-lang.org/recent@@"] \
    [list "linkapl" "openDoc %t@@https://aplsimple.github.io/@@"] \
    [list "linkCN" "openDoc %t@@https://www.nemethi.de/@@"] \
    [list "linkSH" "openDoc %t@@https://wiki.tcl-lang.org/page/Steve+Huntley@@"] \
    [list "linkHE" "openDoc %t@@https://wiki.tcl-lang.org/page/HE@@"] \
    [list "linkRD" "openDoc %t@@https://github.com/rdbende@@"] \
    [list "linkPO" "openDoc %t@@https://wiki.tcl-lang.org/page/Paul+Obermeier@@"] \
    [list "linkPW" "openDoc %t@@https://wiki.tcl-lang.org/page/PW@@"] \
    [list "linkRK" "openDoc %t@@https://rkeene.org/projects/info@@"] \
    [list "linkMIT" "openDoc %t@@https://en.wikipedia.org/wiki/MIT_License@@"] \
    [list "linkJS" "openDoc %t@@https://wiki.tcl-lang.org/page/Jeff+Smith@@"] \
    [list "linkRS" "openDoc %t@@http://wiki.tcl-lang.org/page/Richard+Suchenwirth@@"] \
    [list "linkAN" "openDoc %t@@https://www.magicsplat.com/@@"] \
    [list "linkDF" "openDoc %t@@https://wiki.tcl-lang.org/page/Donal+Fellows@@"] \
    [list "linkJO" "openDoc %t@@https://www.johann-oberdorfer.eu/@@"] \
    [list "linkTW" "openDoc %t@@https://github.com/phase1geo@@"] \
    [list "linkCM" "openDoc %t@@https://wiki.tcl-lang.org/page/Colin+Macleod@@"] \
    [list "linkDB" "openDoc %t@@https://wiki.tcl-lang.org/page/dbohdan"] \
    [list "linkDG" "openDoc %t@@https://wiki.tcl-lang.org/page/Detlef+Groth"] \
    [list "linkPY" "openDoc %t@@https://wiki.tcl-lang.org/page/Poor+Yorick"] \
    [list "linkMH" "openDoc %t@@https://wiki.tcl-lang.org/page/Matthias+Hoffmann"] \
    [list "linkNB" "openDoc %t@@https://github.com/sl1200mk2@@"] \
    [list "linkTZ" "openDoc %t@@https://github.com/thanoulis@@"] \
    [list "linkCW" "openDoc %t@@https://wiki.tcl-lang.org/page/chw@@"] \
    [list "linkAK" "openDoc %t@@https://wiki.tcl-lang.org/page/Andreas+Kupries@@"] \
    [list "linkAG" "openDoc %t@@https://wiki.tcl-lang.org/page/Andy+Goth@@"] \
    [list "linkDA" "openDoc %t@@https://github.com/ray2501@@"] \
    [list "linkET" "openDoc %t@@https://github.com/eht16"] \
    [list "link-apave" "openDoc %t@@https://aplsimple.github.io/en/tcl/pave"] \
    [list "link-e_menu" "openDoc %t@@https://aplsimple.github.io/en/tcl/e_menu"] \
    [list "link-baltip" "openDoc %t@@https://aplsimple.github.io/en/tcl/baltip/baltip.html"] \
    [list "link-bartabs" "openDoc %t@@https://aplsimple.github.io/en/tcl/bartabs"] \
    [list "link-hl_tcl" "openDoc %t@@https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html"] \
    [list "link-aloupe" "openDoc %t@@https://aplsimple.github.io/en/tcl/aloupe/aloupe.html"] \
    [list "link-playtkl" "openDoc %t@@https://aplsimple.github.io/en/tcl/playtkl/playtkl.html"] \
    [list "link-tkcc" "openDoc %t@@https://aplsimple.github.io/en/tcl/tkcc"] \
    [list "link-repl" "openDoc %t@@https://github.com/apnadkarni/tcl-repl"] \
    [list "link-ale_themes" "openDoc %t@@https://github.com/aplsimple/ale_themes"] \
    [list "link-tkcon" "openDoc %t@@https://wiki.tcl-lang.org/page/Tkcon"] \
    [list "link_" "openDoc %t@@https://aplsimple.github.io/en/misc/links/links.html@@"] \
    [list "linkRH" "openDoc %t@@http://www.hwaci.com/drh/@@"] \
    [list "linkBL" "openDoc %t@@https://wiki.tcl-lang.org/page/bll@@"] \
    [list "linkFF" "openDoc %t@@https://wiki.tcl-lang.org/page/FF@@"] \
    [list "linkSS" "openDoc %t@@https://github.com/antirez@@"] \
    [list "linkML" "openDoc %t@@https://wiki.tcl-lang.org/page/Martin+Lemburg@@"] \
    [list "linkDN" "openDoc %t@@https://github.com/par7133@@"] \
    [list "linkAM" "openDoc %t@@https://en.wikipedia.org/wiki/Argentina@@"] \
    [list "linkHO" "openDoc %t@@https://wiki.tcl-lang.org/page/Harald+Oehlmann@@"] \
    [list "linkJM" "openDoc %t@@https://github.com/jgm@@"] \
    [list "linkJN" "openDoc %t@@https://github.com/johannish@@"] \
    [list "linkGN" "openDoc %t@@https://github.com/gregnix@@"] \
    [list "linkGR" "openDoc %t@@https://github.com/georgtree@@"] \
    [list "linkFL" "openDoc %t@@https://wiki.tcl-lang.org/page/Docking+framework@@"] \
    ]

  ### ________________________ "General" tab _________________________ ###

  set head "alited $valited"
  set clog [readTextFile [file join $DIR CHANGELOG.md]]
  foreach line [textsplit $clog] {
    lassign [regexp -inline {Version `.+(\(.+\))`} $line] -> line
    if {$line ne {}} {
      append head " $line"
      break
    }
  }

  set long1 [msgcat::mc {And well fit for programming with it.}]
  set long2 __________________________________________
  set long3 [file nativename [info nameofexecutable]]
  set msg "  <red>$head</red>, a lite editor.\n\n \
    [msgcat::mc {Written in pure Tcl/Tk.}] \n \
    $long1\n\n \
    [msgcat::mc {Details:}] \n\n \
      \u2022 <link1>aplsimple.github.io/en/tcl/alited</link1>\n \
      \u2022 <link1>github.com/aplsimple/alited</link1>\n \
      \u2022 <link1>chiselapp.com/user/aplsimple/repository/alited</link1>\n\n \
    [msgcat::mc {Authors:}] \n\n \
      \u2022 <linkapl>Alex Plotnikov</linkapl>\n\n \
    [msgcat::mc {License:}] <linkMIT>MIT</linkMIT>\n \
    $long2\n \
    \n \
    <red> $long3 </red>\n \
    \n \
    <red> Tcl/Tk $::alited::tcltk_version </red> <link2></link2>\n \
    \n \
    <red> $::tcl_platform(os) $::tcl_platform(osVersion) </red>"

  ### ________________________ "Packages" tab _________________________ ###

  set packages [msgcat::mc {Packages used by <red>alited %ver</red>:}]
  set packages [string map [list %ver $valited] $packages]
  set vemenu   v[lindex $::em::em_version 1]
  set ::alited::AboutPack "\n $packages\n\n \
    \u2022 <link-apave>apave $vapave</link-apave>\n\n \
    \u2022 <link-e_menu>e_menu $vemenu</link-e_menu>\n\n \
    \u2022 <link-ale_themes>ale_themes</link-ale_themes>\n\n \
    \u2022 <link-baltip>baltip $vbaltip</link-baltip>\n\n \
    \u2022 <link-bartabs>bartabs $vbartabs</link-bartabs>\n\n \
    \u2022 <link-hl_tcl>hl_tcl $vhl_tcl</link-hl_tcl>\n\n \
    \u2022 <link-aloupe>aloupe v1.8.1</link-aloupe>\n\n \
    \u2022 <link-playtkl>playtkl $vplaytkl</link-playtkl>\n\n \
    \u2022 <link-tkcc>tkcc</link-tkcc>\n\n \
    \u2022 <link-repl>tcl-repl</link-repl>\n\n \
    \u2022 <link-tkcon>tkcon v2.7</link-tkcon>\n \
    \n menus/*.em v$al(MNUversion) \
    \n alited.ini v$al(INIversion)"

  ### ________________________ "Acknowledgements" tab _________________________ ###

  set ackn [msgcat::mc "Many thanks to the following people \
    \n who have contributed to this project \
    \n with their participation, advice and code"]
  set spec [msgcat::mc "Special thanks also to"]
  set ::alited::AboutAckn "\n $ackn\n\n \
    \u2022 <linkSH>Steve Huntley</linkSH>\n \
    \u2022 <linkHE>Holger Ewert</linkHE>\n \
    \u2022 <linkCN>Csaba Nemethi</linkCN>\n \
    \u2022 <linkPO>Paul Obermeier</linkPO>\n \
    \u2022 <linkAN>Ashok P. Nadkarni</linkAN>\n \
    \u2022 <linkRD>rdbende</linkRD>\n \
    \u2022 <linkBL>Brad Lanam</linkBL>\n \
    \u2022 <linkPW>Paul Walton</linkPW>\n \
    \u2022 <linkJO>Johann Oberdorfer</linkJO>\n \
    \u2022 <linkRS>Richard Suchenwirth</linkRS>\n \
    \u2022 <linkCW>Christian Werner</linkCW>\n \
    \u2022 <linkNB>Nicolas Bats</linkNB>\n \
    \u2022 <linkTZ>Thanos Zygouris</linkTZ>\n \
    \u2022 <linkFF>Federico Ferri</linkFF>\n \
    \u2022 <linkSS>Salvatore Sanfilippo</linkSS>\n \
    \u2022 <linkML>Martin Lemburg</linkML>\n \
    \u2022 <linkDN>Daniele Bonini</linkDN>\n \
    \u2022 <linkAM>Alexis Martin</linkAM>\n \
    \u2022 <linkJN>Johann</linkJN>\n \
    \u2022 <linkGN>Gregor</linkGN>\n \
    \u2022 <linkGR>George</linkGR>\n \
    \u2022 <linkFL>Flame</linkFL>\n \
    \n $spec\n\n \
    \u2022 <linkTW>Trevor Williams</linkTW>\n \
    \u2022 <linkDF>Donal K. Fellows</linkDF>\n \
    \u2022 <linkJS>Jeff Smith</linkJS>\n \
    \u2022 <linkRK>Roy Keene</linkRK>\n \
    \u2022 <linkDB>D. Bohdan</linkDB>\n \
    \u2022 <linkDG>Detlef Groth</linkDG>\n \
    \u2022 <linkCM>Colin Macleod</linkCM>\n \
    \u2022 <linkPY>Nathan Coulter</linkPY>\n \
    \u2022 <linkAK>Andreas Kupries</linkAK>\n \
    \u2022 <linkRH>D. Richard Hipp</linkRH>\n \
    \u2022 <linkMH>Matthias Hoffmann</linkMH>\n \
    \u2022 <linkAG>Andy Goth</linkAG>\n \
    \u2022 <linkDA>Danilo Chang</linkDA>\n \
    \u2022 <linkET>Enrico Troeger</linkET>\n \
    \u2022 <linkHO>Harald Oehlmann</linkHO>\n \
    \u2022 <linkJM>John MacFarlane</linkJM>\n \
    \n <link_>Excuse my memory if I omitted someone's name.</link_>\n"

  ### ________________________ Combining tabs _________________________ ###

  set wmax [expr {4+max([string length $long1], \
    [string length $long2],[string length $long3])}]
  set tab2 [list General Packages "{fra - - 1 99 {-st nsew -rw 1 -cw 1}} \
    {.TexPack - - - - {pack -side left -expand 1 -fill both} {-w $wmax -h 31 \
    -rotext ::alited::AboutPack -tags ::alited::about::textTags}}" \
    Acknowledgements "{fra - - 1 99 {-st nsew -rw 1 -cw 1}} \
    {.TexAckn - - - - {pack -side left -expand 1 -fill both} \
    {-w $wmax -h 34 -rotext ::alited::AboutAckn -tags ::alited::about::textTags}} \
    {.sbv .texAckn L - - {pack -side right}}"]

  ## ________________________ Change default options _________________________ ##

  # invert link colors
  set aopts "{-fg $::apave::FGMAIN -bg $::apave::BGMAIN}"
  obj untouchWidgets "*.texM $aopts" "*.texPack $aopts" "*.texAckn $aopts"
  lassign [obj csGet] fg fg2 bg bg2
  lappend textTags "FG $fg2" "FG2 $fg" "BG $bg2" "BG2 $bg"

  # tooltips to show in the left & bottom point from the mouse pointer
  lassign [::baltip cget -shiftX] -> shiftX
  ::baltip configure -shiftX 10

  ## ________________________ Open dialogue _________________________ ##

  ::alited::msg ok {} $msg \
    -title [msgcat::mc About] -t 1 -w $wmax -h {30 30} -scroll 0 \
    -tags ::alited::about::textTags -my "after idle {alited::about::textImaged %w}" \
    -tab2 $tab2

  ## ________________________ Restore defaults _________________________ ##

  ::baltip configure -shiftX $shiftX
  obj touchWidgets *.texM *.texPack *.texAckn
  unset -nocomplain ::alited::AboutAckn
  unset -nocomplain ::alited::AboutPack
}

# _____________________________ EOF _____________________________________ #
