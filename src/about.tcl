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

proc about::About {} {
  # Shows "About" dialogue.

  ::alited::source_e_menu
  namespace upvar ::alited al al
  variable textTags
  lassign [::apave::obj csGet] fg - bg - - bS fS
  set textTags [list \
    [list "red" "-font {[::apave::obj csFontDef] -weight bold} -foreground $fS -background $bS"] \
    [list "link1" "::apave::openDoc %t@@https://%l@@"] \
    [list "link2" "::apave::openDoc %t@@https://wiki.tcl-lang.org/recent@@"] \
    [list "linkapl" "::apave::openDoc %t@@https://github.com/aplsimple/@@"] \
    [list "linkCN" "::apave::openDoc %t@@https://www.nemethi.de/@@"] \
    [list "linkSH" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Steve+Huntley@@"] \
    [list "linkHE" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/HE@@"] \
    [list "linkRD" "::apave::openDoc %t@@https://github.com/rdbende@@"] \
    [list "linkPO" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Paul+Obermeier@@"] \
    [list "linkPW" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/PW@@"] \
    [list "linkRK" "::apave::openDoc %t@@https://rkeene.org/projects/info@@"] \
    [list "linkMIT" "::apave::openDoc %t@@https://en.wikipedia.org/wiki/MIT_License@@"] \
    [list "linkJS" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Jeff+Smith@@"] \
    [list "linkRS" "::apave::openDoc %t@@http://wiki.tcl-lang.org/page/Richard+Suchenwirth@@"] \
    [list "linkAN" "::apave::openDoc %t@@https://www.magicsplat.com/@@"] \
    [list "linkDF" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Donal+Fellows@@"] \
    [list "linkJO" "::apave::openDoc %t@@https://www.johann-oberdorfer.eu/@@"] \
    [list "linkTW" "::apave::openDoc %t@@https://github.com/phase1geo@@"] \
    [list "linkCM" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Colin+Macleod@@"] \
    [list "linkDB" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/dbohdan"] \
    [list "linkDG" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Detlef+Groth"] \
    [list "linkPY" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Poor+Yorick"] \
    [list "linkMH" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Matthias+Hoffmann"] \
    [list "linkNB" "::apave::openDoc %t@@https://github.com/sl1200mk2@@"] \
    [list "linkTZ" "::apave::openDoc %t@@https://github.com/thanoulis@@"] \
    [list "linkCW" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/chw@@"] \
    [list "linkAK" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Andreas+Kupries@@"] \
    [list "linkAG" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Andy+Goth@@"] \
    [list "linkDA" "::apave::openDoc %t@@https://github.com/ray2501@@"] \
    [list "linkET" "::apave::openDoc %t@@https://github.com/eht16"] \
    [list "link-apave" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/pave"] \
    [list "link-e_menu" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/e_menu"] \
    [list "link-baltip" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/baltip/baltip.html"] \
    [list "link-bartabs" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/bartabs"] \
    [list "link-hl_tcl" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html"] \
    [list "link-aloupe" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/aloupe/aloupe.html"] \
    [list "link-tkcc" "::apave::openDoc %t@@https://aplsimple.github.io/en/tcl/tkcc"] \
    [list "link-repl" "::apave::openDoc %t@@https://github.com/apnadkarni/tcl-repl"] \
    [list "link-awthemes" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/awthemes"] \
    [list "link-ale_themes" "::apave::openDoc %t@@https://github.com/aplsimple/ale_themes"] \
    [list "link-tkcon" "::apave::openDoc %t@@https://wiki.tcl-lang.org/page/Tkcon"] \
    [list "link_" "::apave::openDoc %t@@https://aplsimple.github.io/en/misc/links/links.html@@"] \
    [list "linkRH" "::apave::openDoc %t@@http://www.hwaci.com/drh/@@"] \
    ]
  ::apave::InitAwThemesPath $::alited::LIBDIR
  foreach _ {alited apave bartabs baltip hl_tcl awthemes} {
    if {[catch {set v$_ v[package require $_]}]} {
      set v$_ {}
    }
  }
  set long1 [msgcat::mc {And well fit for programming with it.}]
  set long2 __________________________________________
  set long3 [info nameofexecutable]
  set msg "  <red>alited $valited</red> [msgcat::mc {stands for}] \"a lite editor\".\n\n \
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
    <red> $alited::tcltk_version </red> <link2></link2>\n \
    \n \
    <red> $::tcl_platform(os) $::tcl_platform(osVersion) </red>"
  set wmax [expr {4+max([string length $long1], \
    [string length $long2],[string length $long3])}]
  set ackn [msgcat::mc "Many thanks to the following people\n who have contributed to this project"]
  set spec [msgcat::mc "Special thanks also to"]
  set ::alited::AboutAckn "\n $ackn\n\n \
    \u2022 <linkSH>Steve Huntley</linkSH>\n \
    \u2022 <linkHE>Holger Ewert</linkHE>\n \
    \u2022 <linkCN>Csaba Nemethi</linkCN>\n \
    \u2022 <linkPO>Paul Obermeier</linkPO>\n \
    \u2022 <linkAN>Ashok P. Nadkarni</linkAN>\n \
    \u2022 <linkRD>rdbende</linkRD>\n \
    \u2022 <linkPW>Paul Walton</linkPW>\n \
    \u2022 <linkJO>Johann Oberdorfer</linkJO>\n \
    \u2022 <linkRS>Richard Suchenwirth</linkRS>\n \
    \u2022 <linkCW>Christian Werner</linkCW>\n \
    \u2022 <linkNB>Nicolas Bats</linkNB>\n \
    \u2022 <linkTZ>Thanos Zygouris</linkTZ>\n \
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
    \u2022 <linkET>Enrico Tröger</linkET>\n \
    \n <link_>Excuse my memory if I omitted someone's name.</link_>\n"
  set packages [msgcat::mc {Packages used by <red>alited %ver</red>:}]
  set packages [string map [list %ver $valited] $packages]
  set vemenu   v[lindex $::em::em_version 1]
  set ::alited::AboutPack "\n $packages\n\n \
    \u2022 <link-apave>apave $vapave</link-apave>\n\n \
    \u2022 <link-e_menu>e_menu $vemenu</link-e_menu>\n\n \
    \u2022 <link-baltip>baltip $vbaltip</link-baltip>\n\n \
    \u2022 <link-bartabs>bartabs $vbartabs</link-bartabs>\n\n \
    \u2022 <link-hl_tcl>hl_tcl $vhl_tcl</link-hl_tcl>\n\n \
    \u2022 <link-aloupe>aloupe v0.9.5</link-aloupe>\n\n \
    \u2022 <link-tkcon>tkcon v2.7</link-tkcon>\n\n \
    \u2022 <link-awthemes>awthemes $vawthemes</link-awthemes>\n\n \
    \u2022 <link-ale_themes>ale_themes</link-ale_themes>\n\n \
    \u2022 <link-tkcc>tkcc</link-tkcc>\n\n \
    \u2022 <link-repl>tcl-repl</link-repl>\n"
  set tab2 [list General Packages "{fra - - 1 99 {-st nsew -rw 1 -cw 1}} {.TexPack - - - - {pack -side left -expand 1 -fill both} {-w $wmax -h 31 -rotext ::alited::AboutPack -tags ::alited::about::textTags}}" Acknowledgements "{fra - - 1 99 {-st nsew -rw 1 -cw 1}} {.TexAckn - - - - {pack -side left -expand 1 -fill both} {-w $wmax -h 34 -rotext ::alited::AboutAckn -tags ::alited::about::textTags}} {.sbv .texAckn L - - {pack -side right}}"]
  lassign [::baltip cget -shiftX] -> shiftX
  ::baltip configure -shiftX 10
  ::alited::msg ok {} $msg \
    -title [msgcat::mc About] -t 1 -w $wmax -h {30 30} -scroll 0 \
    -tags alited::about::textTags -my "after idle {alited::about::textImaged %w}" \
    -tab2 $tab2
  ::baltip configure -shiftX $shiftX
  unset ::alited::AboutAckn  ;# was used in this dialogue only, for readonly text
  unset ::alited::AboutPack  ;# -//-
}
#_______________________

proc about::textImaged {w} {
  # Makes the feather blink.
  #  w - window's path

  ::apave::obj labelFlashing [::apave::obj textLink $w 5] "" 1 \
    -data $::alited::img::_AL_IMG(feather) -pause 0.5 -incr 0.1 -after 40
}

# _____________________________ EOF _____________________________________ #
#RUNF1: alited.tcl DEBUG
