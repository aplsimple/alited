# _______________________________________________________________________ #
#
# This script contains a bunch of oo::classes. A bit of it.
#
# The ObjectProperty class allows to mix-in into
# an object the getter and setter of properties.
#
# The ObjectTheming class allows to change the ttk widgets' style.
#
# _______________________________________________________________________ #

package require Tk

namespace eval ::apave {

  # variables global to apave objects:
  set ::apave::FGMAIN #000000
  set ::apave::BGMAIN #d9d9d9
  set ::apave::FONTMAIN [font actual TkDefaultFont]
  set ::apave::FONTMAINBOLD [list {*}$::apave::FONTMAIN -weight bold]

  # - common options/constants of apave utils
  variable _PU_opts;       array set _PU_opts [list -NONE =NONE=]
  variable _AP_Properties; array set _AP_Properties [list]
  set _PU_opts(_ERROR_) {}
  set _PU_opts(_EOL_) {}
  set _PU_opts(_LOGFILE_) {}
  set _PU_opts(_MODALWIN_) [list]
  # - main color scheme data
  variable _CS_
  array set _CS_ [list]
  # - current color scheme data
  variable _C_
  array set _C_ [list]
  # - localized messages
  variable _MC_
  array set _MC_ [list]

# Colors for <MildDark CS> : 1) meanings 2) code names

# <CS>    itemfg  mainfg  itembg  mainbg  itemsHL  actbg   actfg  cursor  greyed   hot \
  emfg  embg   -  menubg  winfg   winbg   itemHL2 tabHL chkHL #005...reserved... #007

# <CS>    clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk \
  fI     bI  --12--  bM    fW      bW     itemHL2 tabHL chkHL #005...reserved... #007

  set ::apave::_CS_(ALL) {
{{ 0: AwLight}        "#141414" #151616 #dfdfde #d1d1d0 #28578a #85b4e7 #000 #444 grey #4776a9 #000 #97c6f9 - #bebebd #000 #FBFB96 #cacaca #a20000 #76b2f1 #005 #006 #007}

{{ 1: AzureLight}     "#050b0d" #050b0d #ffffff #e1e1e1 #0b8aa4 #7feaff #000 #444 grey #22a1bb #000 #93e8ff - #cccccc #000 #FBFB95 #e2e2e0 #ad0000 #76b2f1 #005 #006 #007}

{{ 2: ForestLight}    "#050b0d" #050b0d #ffffff #e1e1e1 #1d5d1d #A8CCA8 #000 #185818 grey #328457 #000 #b6cbb6 - #cccccc #000 #FBFB95 #e2e2e0 #ad0000 #76b2f1 #005 #006 #007}

{{ 3: SunValleyLight} "#050b0d" #050b0d #ffffff #e1e1e1 #1056af #86d2ff #000 #444 grey #1574cd #000 #7fcbff - #cccccc #000 #FBFB95 #e2e2e0 #950000 #76b2f1 #005 #006 #007}

{{ 4: Grey1}          "#050b0d" #050b0d #F8F8F8 #dadad8 #933232 #b8b8b8 #000 #444 grey #843e3e #000 #AFAFAF - #caccd0 #000 #FBFB95 #e0e0d8 #a20000 #76b2f1 #005 #006 #007}

{{ 5: Grey2}          "#050b0d" #050b0d #f4f4f4 #F8F8F8 #5c1616 #c8c8c8 #000 #444 grey #933232 #000 #c1c1c1 - #e7e7e7 #000 #FBFB95 #e5e5e5 #a20000 #76b2f1 #005 #006 #007}

{{ 6: Rosy}           "#2B122A" #000000 #FFFFFF #F6E6E9 #712371 #d0b8d3 #000 #630063 grey #954799 #000 #ceb6d1 - #e3d3d6 #000 #FBFB95 #e5e3e1 #a20000 #76b2f1 #005 #006 #007}

{{ 7: Clay}           "#000000" #000000 #fdf4ed #e6dbd4 #6e300d #bcaea2 #000 #444 grey #813b3b #000 #c6b4ac - #d5c9c1 #000 #FBFB95 #e1dfde #a20000 #76b2f1 #005 #006 #007}

{{ 8: Dawn}           "#08085D" #030358 #FFFFFF #e4fafa #794545 #a3dce5 #000 #195999 grey #ae4d4d #000 #99d2db - #d3e9e9 #000 #FBFB96 #dbe9ed #a20000 #76b2f1 #005 #006 #007}

{{ 9: Sky}            "#102433" #0A1D33 #d0fdff #bdf6ff #713d3d #95ced7 #000 #195999 grey #a94848 #000 #9ad3dc - #b1eaf3 #000 #FBFB95 #c0e9ef #a20000 #76b2f1 #005 #006 #007}

{{10: Florid}         "#000000" #004000 #e4fce4 #fff #8b4545 #93e493 #0F2D0F #185818 grey #9a481a #004000 #a7f8a7 - #d8e7d8 #000 #FBFB96 #d7e6d7 #a20000 #76b2f1 #005 #006 #007}

{{11: LightGreen}     "#122B05" #091900 #edffed #DEF8DE #764242 #A8CCA8 #000 #185818 grey #a34242 #000 #A8CCA8 - #cde7cd #000 #FBFB96 #dee9de #a20000 #76b2f1 #005 #006 #007}

{{12: InverseGreen}   "#122B05" #091900 #e5ffe1 #d7f1d7 #6d3939 #a7cba7 #000 #185818 grey #a94848 #000 #afd3af - #c9e3c9 #000 #FBFB96 #d6e8d5 #a20000 #76b2f1 #005 #006 #007}

{{13: GreenPeace}     "#001000" #001000 #e1ffdd #cfe4cf #733f3f #a5c3a1 #000 #185818 grey #af4e4e #000 #9cb694 - #c1dbc1 #000 #FBFB96 #d2e1d2 #a20000 #76b2f1 #005 #006 #007}

{{14: African}        "#000000" #000000 #ffffff #ffffe7 #8a4444 #ffd797 #000 #682800 #7e7e7e #a44a2d #000 #f7bf91 - #e7e7cf #000 #eded89 #ededd5 #a20000 #76b2f1 #005 #006 #007}

{{15: African1}       "#000000" #000000 #ffffff #ebebd3 #8a4444 #ebc383 #000 #682800 #7e7e7e #9d4326 #000 #f7bf91 - #dbdbc3 #000 #eded89 #ededd5 #a20000 #76b2f1 #005 #006 #007}

{{16: African2}       "#000000" #000000 #f7f7dc #dedbb4 #8e4848 #f2b482 #000 #682800 grey #9f4528 #000 #e6ae80 - #ccc9a2 #000 #fbfb74 #e7e7cb #a20000 #76b2f1 #005 #006 #007}

{{17: African3}       "#000000" #000000 #e2deb5 #ccc9a6 #813b3b #e1a97b #000 #682800 grey #a44a2d #000 #e6ae80 - #bbb895 #000 #fbfb74 #c9c9b0 #c10000 #76b2f1 #005 #006 #007}

{{18: Yellowstone}    "#00002f" #00003c #ffffd1 #d5d3b7 #7b3e30 #d59e6d #000 #682800 grey #93391c #000000 #cfab86 - #c2c0a4 #000 #ffff45 #e6e6bb #a30000 #76b2f1 #005 #006 #007}

{{19: Notebook}       "#000000" #000000 #e9e1c8 #d2ccb8 #692323 #d59d6f #000 #682800 #7e7e7e #92381b #000 #c09c77 - #dbd5c1 #000 #eded89 #dad2b9 #a20000 #76b2f1 #005 #006 #007}

{{20: Notebook1}      "#000000" #000000 #dad2b9 #bfb9a5 #692323 #d59d6f #000 #682800 #707070 #92381b #000 #ba9671 - #c5bfab #000 #eded89 #ccc4ab #a20000 #76b2f1 #005 #006 #007}

{{21: Notebook2}      "#000000" #000000 #d1c9b0 #b1ab97 #692323 #d59d6f #000 #682800 #606060 #92381b #000 #c38b5d - #bdb7a3 #000 #eded89 #c1b9a0 #980000 #76b2f1 #005 #006 #007}

{{22: Notebook3}      "#000000" #000000 #c2baa1 #a6a08c #793333 #cb9365 #000 #682800 #505050 #973d20 #000 #d59d6f - #b3ad99 #000 #eded89 #b2aa91 #7b1010 #76b2f1 #005 #006 #007}

{{23: Darcula}        "#ececec" #c7c7c7 #272727 #323232 #93baf6 #2F5692 #e1e1e1 #f4f49f grey #769dd9 #fff #2c538f - #444444 #000 #aaaa6d #343434 #ffc341 #76b2f1 #005 #006 #007}

{{24: Dusk}           "#ececec" #ececec #1a1f21 #262b2d #9fc99f #217346 #FFF #f4f49f #585d5f #99c399 #fff #225c3b - #363b3d #000 #9d9d60 #23282a #ffc341 #99dd99 #005 #006 #007}

{{25: AwDark}         "#F0E8E8" #E7E7E7 #1f2223 #232829 #77b3f2 #215d9c #fff #f4f49f grey #5793d2 #fff #0d4988 - #313637 #000 #9d9d60 #292e2f #ffc341 #76b2f1 #005 #006 #007}

{{26: AzureDark}      "#ececec" #c7c7c7 #272727 #393939 #7fd5ff #0a89c1 #FFF #f4f49f grey #33b2ff #ffffff #0281b9 - #4a4a4a #000 #aaaa6d #383838 #ffc341 #76b2f1 #005 #006 #007}

{{27: ForestDark}     "#ececec" #c7c7c7 #272727 #393939 #a3cda3 #217346 #FFF #42ff42 grey #84ae84 #fff #247649 - #4a4a4a #000 #aaaa6d #383838 #efaf6f #99dd99 #005 #006 #007}

{{28: SunValleyDark}  "#dfdfdf" #dddddd #131313 #252525 #83cee9 #2a627f #FFF #f4f49f #6f6f6f #63a1c3 #fff #18506d - #323232 #000 #9d9d60 #2a2a2a #efaf6f #4273eb #005 #006 #007}

{{29: Dark1}          "#E0D9D9" #C4C4C4 #212121 #292929 #de9e5e #6c6c6c #000 #f4f49f #606060 #ba8d4d #000 #767676 - #363636 #000 #9d9d60 #292929 #ffc341 #76b2f1 #005 #006 #007}

{{30: Dark2}          "#bebebe" #bebebe #1f1f1f #262626 #de9e5e #6b6b6b #000 #f4f49f #616161 #b28545 #000 #767676 - #323232 #000 #9d9d60 #262626 #ffc341 #76b2f1 #005 #006 #007}

{{31: Dark3}          "#bebebe" #bebebe #0a0a0a #232323 #de9e5e #6a6a6a #000 #f4f49f #616161 #aa7d3d #000 #767676 - #303030 #000 #9d9d60 #131313 #ffc341 #76b2f1 #005 #006 #007}

{{32: Oscuro}         "#f1f1f1" #ffffff #314242 #3e5959 #f1b479 #6c8787 #fff #42ff42 #afafaf #d3a051 #fff #5b7676 - #4d6868 #000 #aaaa6d #425353 #ffc341 #94e2b8 #005 #006 #007}

{{33: Oscuro1}        "#e3e3e3" #f7f7f7 #233434 #304b4b #e3a66b #5e7979 #fff #42ff42 #a1a1a1 #d6a354 #fff #4e6969 - #3f5a5a #000 #aaaa6d #344545 #ffcb8b #86d4aa #005 #006 #007}

{{34: Oscuro2}        "#d5d5d5" #f1f1f1 #152626 #223d3d #d5985d #506b6b #fff #42ff42 #939393 #c69344 #fff #435e5e - #314c4c #000 #9d9d60 #263737 #ffc585 #78c69c #005 #006 #007}

{{35: Oscuro3}        "#c7c7c7" #eaeaea #071818 #142f2f #dfa267 #425d5d #fff #42ff42 #858585 #ba8738 #fff #324d4d - #233e3e #000 #9d9d60 #182929 #e9ae6e #6ab88e #005 #006 #007}

{{36: MildDark}       "#d2d2d2" #ffffff #223142 #2D435B #3ddbdb #517997 #fff #00ffff grey #18b6b6 #fff #3e6684 - #3a5068 #000 #aaaa6d #324152 #ffc341 #76b2f1 #005 #006 #007}

{{37: MildDark1}      "#c8c8c8" #f7f7f7 #1a2937 #24384f #3cdada #466e8c #fff #00ffff #757575 #19b7b7 #fff #3a6280 - #31455c #000 #aaaa6d #2b3a48 #f1b171 #76b2f1 #005 #006 #007}

{{38: MildDark2}      "#e2e2e2" #f1f1f1 #0e1d2c #1B3048 #3edddd #426a88 #fff #00ffff #6c6c6c #0ba9a9 #fff #355d7b - #2a3f57 #000 #9d9d60 #1d2c3b #f4b474 #76b2f1 #005 #006 #007}

{{39: MildDark3}      "#dbdbdb" #eaeaea #000c1b #031830 #35d4d4 #375f7d #fff #00ffff #6c6c6c #019f9f #fff #2f5775 - #162b43 #000 #9d9d60 #0a1f37 #e5a565 #76b2f1 #005 #006 #007}

{{40: Inkpot}         "#d3d3ff" #AFC2FF #16161f #1E1E27 #e39f51 #525293 #fff #f4f49f #6e6e6e #b57535 #fff #4d4d8e - #292936 #000 #9d9d60 #202029 #e7b070 #7a7abb #005 #006 #007}

{{41: Quiverly}       "#cdd8d8" #cdd8d8 #2b303b #333946 #eda95b #6f7582 #fff #f4f49f #757575 #cd8d4d #000 #9197a4 - #414650 #000 #aaaa6d #323742 #ffc341 #76b2f1 #005 #006 #007}

{{42: Monokai}        "#f8f8f2" #f8f8f2 #353630 #4e5044 #ffbb6d #707070 #fff #f4f49f #9a9a9a #db9e63 #000 #777777 - #46473d #000 #b7b77a #3c3d37 #ffc888 #cd994b #005 #006 #007}

{{43: TKE Default}    "#dbdbdb" #dbdbdb #000000 #282828 #d3a85a #0a0acc #fff #f4f49f #6a6a6a #c58545 #fff #0000d3 - #383838 #000 #9d9d60 #1b1c1c #e5a565 #76b2f1 #005 #006 #007}

{{44: Magenta}        "#E8E8E8" #F0E8E8 #381e44 #4A2A4A #ffbb6d #846484 #fff #f4f49f grey #d6995e #000 #ad8dad - #573757 #000 #9d9d60 #42284e #ffc888 #ffafff #005 #006 #007}

{{45: Red}            "#ffffff" #e9e9e6 #340202 #440702 #ffbb6d #b05e5e #fff #f4f49f #828282 #ce9156 #000 #ba6868 - #521514 #000 #9d9d60 #461414 #ffcf8f #ff9a9a #005 #006 #007}

{{46: Chocolate}      "#d6d1ab" #d6d1ab #251919 #402020 #ebb474 #664D4D #fff #f4f49f #828282 #c08040 #fff #583f3f - #432a2a #000 #aaaa6d #2d2121 #eeb777 #cf9292 #005 #006 #007}

{{47: Desert}         "#ffffff" #ffffff #47382d #5a4b40 #ffbb6d #85766b #fff #f4f49f #a2a2a2 #d4975c #fff #7f7065 - #695a4f #000 #aaaa6d #503f34 #ffc341 #ead79b #005 #006 #007}
}
  set ::apave::_CS_(initall) 1
  set ::apave::_CS_(initWM) 1
  set ::apave::_CS_(isActive) 1
  set ::apave::_CS_(!FG) #000000
  set ::apave::_CS_(!BG) #b7b7b7 ;#a8bcd2 #c3c3c3 #9cb0c6 #4a6984
  set ::apave::_CS_(expo,tfg1) "-"
  set ::apave::_CS_(defFont) [font actual TkDefaultFont -family]
  set ::apave::_CS_(textFont) [font actual TkFixedFont -family]
  set ::apave::_CS_(smallFont) [font actual TkSmallCaptionFont]
  set ::apave::_CS_(fs) [font actual TkDefaultFont -size]
  set ::apave::_CS_(untouch) [list]
  set ::apave::_CS_(STDCS) [expr {[llength $::apave::_CS_(ALL)] - 1}]
  set ::apave::_CS_(NONCS) -2
  set ::apave::_CS_(MINCS) -1
  set ::apave::_CS_(old) -3
  set ::apave::_CS_(TONED) [list -2 no]
  set ::apave::_CS_(LABELBORDER) 0
  set ::apave::_CS_(CURSORWIDTH) 2
  namespace eval ::tk { ; # just to get localized messages
    foreach m {&Abort &Cancel &Copy Cu&t &Delete E&xit &Filter &Ignore &No \
    OK Open P&aste &Quit &Retry &Save "Save As" &Yes Close "To clipboard" \
    Zoom Size} {
      set m2 [string map {"&" ""} $m]
      set ::apave::_MC_($m2) [string map {"&" ""} [msgcat::mc $m]]
    }
  }
}

# _____________________________ Common procs ________________________________ #

proc ::iswindows {} {

  # Checks if the platform is MS Windows.
  return [expr {$::tcl_platform(platform) eq "windows"} ? 1: 0]
}

proc ::islinux {} {

  # Checks if the platform is Linux.
  return [expr {$::tcl_platform(platform) eq "unix"} ? 1: 0]
}
#_______________________

proc ::apave::mc {msg} {
  # Gets a localized version of a message.
  #   msg - the message

  variable _MC_
  if {[info exists _MC_($msg)]} {return $_MC_($msg)}
  return $msg
}
#_______________________

proc ::apave::getN {sn {defn 0} {min ""} {max ""}} {

  # Gets a number from a string
  #   sn - string containing a number
  #   defn - default value when sn is not a number
  #   min - minimal value allowed
  #   max - maximal value allowed

  if {$sn eq "" || [catch {set sn [expr {$sn}]}]} {set sn $defn}
  if {$max ne ""} {
    set sn [expr {min($max,$sn)}]
  }
  if {$min ne ""} {
    set sn [expr {max($min,$sn)}]
  }
  return $sn
}
#_______________________

proc ::apave::openDoc {url} {

  # Opens a document.
  #   url - document's file name, www link, e-mail etc.

  set commands {xdg-open open start}
  foreach opener $commands {
    if {$opener eq "start"} {
      set command [list {*}[auto_execok start] {}]
    } else {
      set command [auto_execok $opener]
    }
    if {[string length $command]} {
      break
    }
  }
  if {[string length $command] == 0} {
    puts "ERROR: couldn't find any opener"
  }
  # remove the tailing " &" (as e_menu can set)
  set url [string trimright $url]
  if {[string match "* &" $url]} {set url [string range $url 0 end-2]}
  set url [string trim $url]
  if {[catch {exec -- {*}$command $url &} error]} {
    puts "ERROR: couldn't execute '$command':\n$error"
  }
}
#_______________________

proc ::apave::countChar {str ch} {
  # Counts a character in a string.
  #   str - a string
  #   ch - a character
  #
  # Returns a number of non-escaped occurences of character *ch* in
  # string *str*.
  #
  # See also:
  # [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/Reformatting+Tcl+code+indentation)

  set icnt 0
  while {[set idx [string first $ch $str]] >= 0} {
    set backslashes 0
    set nidx $idx
    while {[string equal [string index $str [incr nidx -1]] \\]} {
      incr backslashes
    }
    if {$backslashes % 2 == 0} { incr icnt }
    set str [string range $str [incr idx] end]
  }
  return $icnt
}
#_______________________

proc ::apave::blinkWidget {w {fg #000} {bg #fff} {fg2 {}} {bg2 red} \
  {pause 1000} {count -1} {mode 1}} {
  # Makes a widget blink.
  #   w - the widget's path
  #   fg - normal foreground color
  #   bg - normal background color
  #   fg2 - blinking foreground color (if {}, stops the blinking)
  #   bg2 - blinking background color
  #   pause - pause in millisec between blinkings
  #   count - means how many times do blinking
  #   mode - for recursive calls

  if {![winfo exists $w]} return
  if {$count==0 || $fg2 eq {}} {
    catch {after cancel $::apave::BLINKWIDGET1}
    catch {after cancel $::apave::BLINKWIDGET2}
    after idle "$w configure -foreground $fg; $w configure -background $bg"
  } elseif {$mode==1} {
    incr count -1
    $w configure -foreground $fg2
    $w configure -background $bg2
    set ::apave::BLINKWIDGET1 [after \
      $pause ::apave::blinkWidget $w $fg $bg $fg2 $bg2 $pause $count 2]
  } elseif {$mode==2} {
    $w configure -foreground $fg
    $w configure -background $bg
    set ::apave::BLINKWIDGET2 [after \
      $pause ::apave::blinkWidget $w $fg $bg $fg2 $bg2 $pause $count 1]
  }
}

## ________________________ Inits _________________________ ##

proc ::apave::initPOP {w} {

  # Initializes system popup menu (if possible) to call it in a window.
  #   w - window's name

  bind $w <KeyPress> {
    if {"%K" eq "Menu"} {
      if {[winfo exists [set w [focus]]]} {
        event generate $w <Button-3> -rootx [winfo pointerx .] \
         -rooty [winfo pointery .]
      }
    }
  }
}
#_______________________

proc ::apave::initStyles {} {

  # Initializes miscellaneous styles, e.g. button's.

  ::apave::obj create_Fonts

  ttk::style configure TButtonWest {*}[ttk::style configure TButton]
  ttk::style configure TButtonWest -anchor w -font $::apave::FONTMAIN
  ttk::style map       TButtonWest {*}[ttk::style map TButton]
  ttk::style layout    TButtonWest [ttk::style layout TButton]

  ttk::style configure TButtonBold {*}[ttk::style configure TButton]
  ttk::style configure TButtonBold -font $::apave::FONTMAINBOLD
  ttk::style map       TButtonBold {*}[ttk::style map TButton]
  ttk::style layout    TButtonBold [ttk::style layout TButton]

  ttk::style configure TButtonWestBold {*}[ttk::style configure TButton]
  ttk::style configure TButtonWestBold -anchor w -font $::apave::FONTMAINBOLD
  ttk::style map       TButtonWestBold {*}[ttk::style map TButton]
  ttk::style layout    TButtonWestBold [ttk::style layout TButton]

  ttk::style configure TButtonWestHL {*}[ttk::style configure TButton]
  ttk::style configure TButtonWestHL -anchor w -foreground [lindex [obj csGet] 4]
  ttk::style map       TButtonWestHL {*}[ttk::style map TButton]
  ttk::style layout    TButtonWestHL [ttk::style layout TButton]

  ttk::style configure TMenuButtonWest {*}[ttk::style configure TMenubutton]
  ttk::style configure TMenuButtonWest -anchor w -font $::apave::FONTMAIN -relief raised
  ttk::style map       TMenuButtonWest {*}[ttk::style map TMenubutton]
  ttk::style layout    TMenuButtonWest [ttk::style layout TMenubutton]
}
#_______________________

proc ::apave::initStylesFS {args} {

  # Initializes miscellaneous styles, e.g. button's.
  #   args - font options ("name value" pairs)

  ::apave::obj create_Fonts
  set font  "$::apave::FONTMAIN $args"
  set fontB "$::apave::FONTMAINBOLD $args"

  ttk::style configure TLabelFS {*}[ttk::style configure TLabel]
  ttk::style configure TLabelFS -font $font
  ttk::style map       TLabelFS {*}[ttk::style map TLabel]
  ttk::style layout    TLabelFS [ttk::style layout TLabel]

  ttk::style configure TCheckbuttonFS {*}[ttk::style configure TCheckbutton]
  ttk::style configure TCheckbuttonFS -font $font
  ttk::style map       TCheckbuttonFS {*}[ttk::style map TCheckbutton]
  ttk::style layout    TCheckbuttonFS [ttk::style layout TCheckbutton]

  ttk::style configure TComboboxFS {*}[ttk::style configure TCombobox]
  ttk::style configure TComboboxFS -font $font
  ttk::style map       TComboboxFS {*}[ttk::style map TCombobox]
  ttk::style layout    TComboboxFS [ttk::style layout TCombobox]

  ttk::style configure TRadiobuttonFS {*}[ttk::style configure TRadiobutton]
  ttk::style configure TRadiobuttonFS -font $font
  ttk::style map       TRadiobuttonFS {*}[ttk::style map TRadiobutton]
  ttk::style layout    TRadiobuttonFS [ttk::style layout TRadiobutton]

  ttk::style configure TButtonWestFS {*}[ttk::style configure TButton]
  ttk::style configure TButtonWestFS -anchor w -font $font
  ttk::style map       TButtonWestFS {*}[ttk::style map TButton]
  ttk::style layout    TButtonWestFS [ttk::style layout TButton]

  ttk::style configure TButtonBoldFS {*}[ttk::style configure TButton]
  ttk::style configure TButtonBoldFS -font $fontB
  ttk::style map       TButtonBoldFS {*}[ttk::style map TButton]
  ttk::style layout    TButtonBoldFS [ttk::style layout TButton]

  ttk::style configure TButtonWestBoldFS {*}[ttk::style configure TButton]
  ttk::style configure TButtonWestBoldFS -anchor w -font $fontB
  ttk::style map       TButtonWestBoldFS {*}[ttk::style map TButton]
  ttk::style layout    TButtonWestBoldFS [ttk::style layout TButton]
}
#_______________________

proc ::apave::InitTheme {intheme libdir} {
  # Initializes app's theme.
  #   intheme - name of the theme
  #   libdir - root directory of themes (where 'theme' subdirectory is)
  # Returns a list of theme name and label's border (for status bar).
  # The returned values are used in ::apave::initWM procedure.

  set theme {}
  switch -glob -- $intheme {
    azure* - sun-valley* {
      set i [string last - $intheme]
      set name [string range $intheme 0 $i-1]
      set type [string range $intheme $i+1 end]
      catch {source [file join $libdir theme $name $name.tcl]}
      catch {set_theme $type}
      set lbd 0
    }
    forest* {
      set i [string last - $intheme]
      set name [string range $intheme 0 $i-1]
      set type [string range $intheme $i+1 end]
      catch {
        source [file join $libdir theme $name $intheme.tcl]
        set theme $intheme
      }
      set lbd 0
    }
    awdark - awlight {
      global auto_path
      lappend auto_path [file join $libdir theme awthemes-10.4.0]
      package require awthemes
      package require ttk::theme::$intheme
      set theme $intheme
      set lbd 1
    }
    default {
      set theme $intheme
      set lbd 1
    }
  }
  return [list $theme $lbd]
}
#_______________________

proc ::apave::initWM {args} {

  # Initializes Tcl/Tk session. Used to be called at the beginning of it.
  #   args - options ("name value" pairs)

  if {!$::apave::_CS_(initWM)} return
  lassign [::apave::parseOptions $args -cursorwidth $::apave::cursorwidth -theme {clam} \
    -buttonwidth -8 -buttonborder 1 -labelborder 0 -padding 1] \
    cursorwidth theme buttonwidth buttonborder labelborder padding
  set ::apave::_CS_(initWM) 0
  set ::apave::_CS_(CURSORWIDTH) $cursorwidth
  set ::apave::_CS_(LABELBORDER) $labelborder
  wm withdraw .
  if {$::tcl_platform(platform) eq {windows}} {
    wm attributes . -alpha 0.0
  }
  # for default theme: only most common settings
  set tfg1 $::apave::_CS_(!FG)
  set tbg1 $::apave::_CS_(!BG)
  if {$theme ne {}} {catch {ttk::style theme use $theme}}
  ttk::style map . \
    -selectforeground [list !focus $tfg1 {focus active} $tfg1] \
    -selectbackground [list !focus $tbg1 {focus active} $tbg1]
  ttk::style configure . -selectforeground	$tfg1 -selectbackground	$tbg1

  # configure separate widget types
  ttk::style configure TButton -anchor center -width $buttonwidth \
    -relief raised -borderwidth $buttonborder -padding $padding
  ttk::style configure TMenubutton -width 0 -padding 0
  # TLabel's standard style saved for occasional uses
  ttk::style configure TLabelSTD {*}[ttk::style configure TLabel]
  ttk::style configure TLabelSTD -anchor w
  ttk::style map       TLabelSTD {*}[ttk::style map TLabel]
  ttk::style layout    TLabelSTD [ttk::style layout TLabel]
  # ... TLabel new style
  ttk::style configure TLabel -borderwidth $labelborder -padding $padding
  # ... Treeview colors
  set twfg [ttk::style map Treeview -foreground]
  set twfg [::apave::putOption selected $tfg1 {*}$twfg]
  set twbg [ttk::style map Treeview -background]
  set twbg [::apave::putOption selected $tbg1 {*}$twbg]
  ttk::style map Treeview -foreground $twfg
  ttk::style map Treeview -background $twbg
  # ... TCombobox colors
  ttk::style map TCombobox -fieldforeground [list {active focus} $tfg1 readonly $tfg1 disabled grey]
  ttk::style map TCombobox -fieldbackground [list {active focus} $tbg1 {readonly focus} $tbg1 {readonly !focus} white]

  initPOP .
  initStyles
}
#_______________________

proc ::apave::endWM {args} {

  # Finishes the window management by apave, closing and clearing all.
  #   args - if any set, means "ask if apave's WM is finished"

  variable _PU_opts
  if {[llength $args]} {
    return [expr {[info exists _PU_opts(_ENDWM_)]}]
  }
  # Check existing windows, except for the first one.
  while {1} {
    set i [expr {[llength $_PU_opts(_MODALWIN_)] - 1}]
    if {$i>0} {
      lassign [lindex $_PU_opts(_MODALWIN_) $i] w var
      if {[winfo exists $w]} {set $var 0}
      catch {set _PU_opts(_MODALWIN_) [lreplace $_PU_opts(_MODALWIN_) $i $i]}
    } else {
      break
    }
  }
  set _PU_opts(_ENDWM_) yes
}
#_______________________

proc ::apave::cs_Active {{flag ""}} {

  # Gets/sets "is changing CS possible" flag for a whole application.

  if {[string is boolean -strict $flag]} {
    set ::apave::_CS_(isActive) $flag
  }
  return $::apave::_CS_(isActive)
}

## ________________________ Property _________________________ ##

proc ::apave::setProperty {name args} {

  # Sets a property's value as "application-wide".
  #   name - name of property
  #   args - value of property
  #
  # If *args* is omitted, the method returns a property's value.
  #
  # If *args* is set, the method sets a property's value as $args.

  variable _AP_Properties
  switch -exact [llength $args] {
    0 {return [getProperty $name]}
    1 {return [set _AP_Properties($name) [lindex $args 0]]}
  }
  puts -nonewline stderr \
    "Wrong # args: should be \"::apave::setProperty propertyname ?value?\""
  return -code error
}
#_______________________

proc ::apave::getProperty {name {defvalue ""}} {
  # Gets a property's value as "application-wide".
  #   name - name of property
  #   defvalue - default value
  #
  # If the property had been set, the method returns its value.
  #
  # Otherwise, the method returns the default value (`$defvalue`).

  variable _AP_Properties
  if {[info exists _AP_Properties($name)]} {
    return $_AP_Properties($name)
  }
  return $defvalue
}

## ________________________ Color schemes _________________________ ##

proc ::apave::cs_Non {} {

  # Gets non-existent CS index

  return -3
}
#_______________________

proc ::apave::cs_Min {} {

  # Gets a minimum index of available color schemes

  return $::apave::_CS_(MINCS)
}

proc ::apave::cs_Max {} {

  # Gets a maximum index of available color schemes

  return [expr {[llength $::apave::_CS_(ALL)] - 1}]
}

proc ::apave::cs_MaxBasic {} {

  # Gets a maximum index of basic color schemes

  return $::apave::_CS_(STDCS)
}

## ________________________ Opfions _________________________ ##

proc ::apave::parseOptionsFile {strict inpargs args} {

  # Parses argument list containing options and (possibly) a file name.
  #   strict - if 0, 'args' options will be only counted for,
  #              other options are skipped
  #   strict - if 1, only 'args' options are allowed,
  #              all the rest of inpargs to be a file name
  #          - if 2, the 'args' options replace the
  #              appropriate options of 'inpargs'
  #   inpargs - list of options, values and a file name
  #   args  - list of default options
  #
  # The inpargs list contains:
  #   - option names beginning with "-"
  #   - option values following their names (may be missing)
  #   - "--" denoting the end of options
  #   - file name following the options (may be missing)
  #
  # The *args* parameter contains the pairs:
  #   - option name (e.g., "-dir")
  #   - option default value
  #
  # If the *args* option value is equal to =NONE=, the *inpargs* option
  # is considered to be a single option without a value and,
  # if present in inpargs, its value is returned as "yes".
  #
  # If any option of *inpargs* is absent in *args* and strict==1,
  # the rest of *inpargs* is considered to be a file name.
  #
  # The proc returns a list of two items:
  #   - an option list got from args/inpargs according to 'strict'
  #   - a file name from inpargs or {} if absent
  #
  # Examples see in tests/obbit.test.

  variable _PU_opts
  set actopts true
  array set argarray "$args yes yes" ;# maybe, tail option without value
  if {$strict==2} {
    set retlist $inpargs
  } else {
    set retlist $args
  }
  set retfile {}
  for {set i 0} {$i < [llength $inpargs]} {incr i} {
    set parg [lindex $inpargs $i]
    if {$actopts} {
      if {$parg eq "--"} {
        set actopts false
      } elseif {[catch {set defval $argarray($parg)}]} {
        if {$strict==1} {
          set actopts false
          append retfile $parg " "
        } else {
          incr i
        }
      } else {
        if {$strict==2} {
          if {$defval == $_PU_opts(-NONE)} {
            set defval yes
          }
          incr i
        } else {
          if {$defval == $_PU_opts(-NONE)} {
            set defval yes
          } else {
            set defval [lindex $inpargs [incr i]]
          }
        }
        set ai [lsearch -exact $retlist $parg]
        incr ai
        set retlist [lreplace $retlist $ai $ai $defval]
      }
    } else {
      append retfile $parg " "
    }
  }
  return [list $retlist [string trimright $retfile]]
}
#_______________________

proc ::apave::parseOptions {opts args} {

  # Parses argument list containing options.
  #  opts - list of options and values
  #  args - list of "option / default value" pairs
  #
  # It's the same as parseOptionsFile, excluding the file name stuff.
  #
  # Returns a list of options' values, according to args.
  #
  # See also: parseOptionsFile

  lassign [::apave::parseOptionsFile 0 $opts {*}$args] tmp
  foreach {nam val} $tmp {
    lappend retlist $val
  }
  return $retlist
}
#_______________________

proc ::apave::extractOptions {optsVar args} {

  # Gets options' values and removes the options from the input list.
  #  optsVar - variable name for the list of options and values
  #  args  - list of "option / default value" pairs
  #
  # Returns a list of options' values, according to args.
  #
  # See also: parseOptions

  upvar 1 $optsVar opts
  set retlist [::apave::parseOptions $opts {*}$args]
  foreach {o v} $args {
    set opts [::apave::removeOptions $opts $o]
  }
  return $retlist
}
#_______________________

proc ::apave::getOption {optname args} {

  # Extracts one option from an option list.
  #   optname - option name
  #   args - option list
  # Returns an option value or "".
  # Example:
  #     set options [list -name some -value "any value" -tip "some tip"]
  #     set optvalue [::apave::getOption -tip {*}$options]

  set optvalue [lindex [::apave::parseOptions $args $optname ""] 0]
  return $optvalue
}
#_______________________

proc ::apave::putOption {optname optvalue args} {

  # Replaces or adds one option to an option list.
  #   optname - option name
  #   optvalue - option value
  #   args - option list
  # Returns an updated option list.

  set optlist {}
  set doadd true
  foreach {a v} $args {
    if {$a eq $optname} {
      set v $optvalue
      set doadd false
    }
    lappend optlist $a $v
  }
  if {$doadd} {lappend optlist $optname $optvalue}
  return $optlist
}
#_______________________

proc ::apave::removeOptions {options args} {

  # Removes some options from a list of options.
  #   options - list of options and values
  #   args - list of option names to remove
  #
  # The `options` may contain "key value" pairs and "alone" options
  # without values.
  #
  # To remove "key value" pairs, `key` should be an exact name.
  #
  # To remove an "alone" option, `key` should be a glob pattern with `*`.

  foreach key $args {
    if {[set i [lsearch -exact $options $key]]>-1} {
      catch {
        # remove a pair "option value"
        set options [lreplace $options $i $i]
        set options [lreplace $options $i $i]
      }
    } elseif {[string first * $key]>=0 && \
      [set i [lsearch -glob $options $key]]>-1} {
      # remove an option only
      set options [lreplace $options $i $i]
    }
  }
  return $options
}

## ________________________ Text file _________________________ ##

proc ::apave::error {{fileName ""}} {
  # Gets the error's message at reading/writing.
  #   fileName - if set, return a full error messageat opening file

  variable _PU_opts
  if {$fileName eq ""} {
    return $_PU_opts(_ERROR_)
  }
  return "Error of access to\n\"$fileName\"\n\n$_PU_opts(_ERROR_)"
}
#_______________________

proc ::apave::textsplit {textcont} {
  # Splits a text's contents by EOLs. Those inventors of EOLs...
  #   textcont - text's contents

  return [split [string map [list \r\n \n \r \n] $textcont] \n]
}
#_______________________

proc ::apave::textEOL {{EOL "-"}} {
  # Gets/sets End-of-Line for text reqding/writing.
  #   EOL - LF, CR, CRLF or {}
  # If EOL omitted or equals to {} or "-", return the current EOL.
  # If EOL equals to "translation", return -translation option or {}.

  variable _PU_opts
  if {$EOL eq "-"} {return $_PU_opts(_EOL_)}
  if {$EOL eq "translation"} {
    if {$_PU_opts(_EOL_) eq ""} {return ""}
    return "-translation $_PU_opts(_EOL_)"
  }
  set _PU_opts(_EOL_) [string trim [string tolower $EOL]]
}
#_______________________

proc ::apave::textChanConfigure {channel {coding {}} {eol {}}} {
  # Configures a channel for text file.
  #   channel - the channel
  #   coding - if set, defines encoding of the file
  #   eol - if set, defines EOL of the file

  if {$coding eq {}} {
    chan configure $channel -encoding utf-8
  } else {
    chan configure $channel -encoding $coding
  }
  if {$eol eq {}} {
    chan configure $channel {*}[::apave::textEOL translation]
  } else {
    chan configure $channel -translation $eol
  }
}
#_______________________

proc ::apave::logName {fname} {
  # Sets a log file's name.
  #   fname - file name
  # If fname is {}, disables logging.

  variable _PU_opts;
  set _PU_opts(_LOGFILE_) [file normalize $fname]
}
#_______________________

proc ::apave::logMessage {msg} {
  # Logs messages to a log file.
  #   msg - the message
  # A log file's name is set by _PU_opts(_LOGFILE_). If it's blank,
  # no logging is made.

  variable _PU_opts;
  if {$_PU_opts(_LOGFILE_) eq {}} return
  set chan [open $_PU_opts(_LOGFILE_) a]
  set dt [clock format [clock seconds] -format {%d%b'%y %T}]
  set msg "$dt $msg"
  foreach i {-4 -3 -2 -1} {
    catch {
      lassign [info level $i] p1 p2
      if {$p1 eq {my}} {append p1 " $p2"}
      append msg " / $p1"
    }
  }
  puts $chan $msg
  close $chan
  puts "$_PU_opts(_LOGFILE_) - $msg"
}
#_______________________

proc ::apave::readTextFile {fileName {varName ""} {doErr 0}} {

  # Reads a text file.
  #   fileName - file name
  #   varName - variable name for file content or ""
  #   doErr - if 'true', exit at errors with error message
  #
  # Returns file contents or "".

  variable _PU_opts
  if {$varName ne {}} {upvar $varName fvar}
  if {[catch {set chan [open $fileName]} _PU_opts(_ERROR_)]} {
    if {$doErr} {error [::apave::error $fileName]}
    set fvar {}
  } else {
    ::apave::textChanConfigure $chan {} auto ;# let EOL be autodetected
    set fvar [read $chan]
    close $chan
    logMessage "read $fileName"
  }
  return $fvar
}
#_______________________

proc ::apave::writeTextFile {fileName {varName ""} {doErr 0} {doSave 1}} {

  # Writes to a text file.
  #   fileName - file name
  #   varName - variable name for file content or ""
  #   doErr - if 'true', exit at errors with error message
  #   doSave - if 'true', saves an empty file, else deletes it
  #
  # Returns "yes" if the file was saved successfully.

  variable _PU_opts
  if {$varName ne {}} {
    upvar $varName contents
  } else {
    set contents {}
  }
  set res yes
  if {!$doSave && [string trim $contents] eq {}} {
    if {[catch {file delete $fileName} _PU_opts(_ERROR_)]} {
      set res no
    } else {
      logMessage "delete $fileName"
    }
  } elseif {[catch {set chan [open $fileName w]} _PU_opts(_ERROR_)]} {
    set res no
  } else {
    ::apave::textChanConfigure $chan
    puts -nonewline $chan $contents
    close $chan
    logMessage "write $fileName"
  }
  if {!$res && $doErr} {error [::apave::error $fileName]}
  return $res
}

## ________________________ Binds _________________________ ##

proc ::apave::bindToEvent {w event args} {

  # Binds an event on a widget to a command.
  #   w - the widget's path
  #   event - the event
  #   args - the command

  ::baltip::my::BindToEvent $w $event {*}$args
}
#_______________________

proc ::apave::bindTextagToEvent {w tag event args} {
  # Binds an event on a text tag to a command.
  #   w - the widget's path
  #   tag - the tag
  #   event - the event
  #   args - the command

  ::baltip::my::BindTextagToEvent $w $tag $event {*}$args
}
#_______________________

proc ::apave::bindCantagToEvent {w tag event args} {
  # Binds an event on a canvas tag to a command.
  #   w - the widget's path
  #   tag - the tag
  #   event - the event
  #   args - the command

  ::baltip::my::BindCantagToEvent $w $tag $event {*}$args
}

## ________________________ Helpers _________________________ ##

proc ::apave::InfoWindow {{val ""} {w .} {modal no} {var ""} {regist no}} {

  # Registers/unregisters windows. Also sets/gets 'count of open modal windows'.
  #   val - current number of open modal windows
  #   w - root window's path
  #   modal - yes, if the window is modal
  #   var - variable's name for tkwait
  #   regist - yes or no for registering/unregistering
  # See also: APave::showWindow

  variable _PU_opts
  if {$modal || $regist} {
    set info [list $w $var $modal]
    set i [lsearch -exact $_PU_opts(_MODALWIN_) $info]
    if {$regist} {
      lappend _PU_opts(_MODALWIN_) $info
    } else {
      catch {set _PU_opts(_MODALWIN_) [lreplace $_PU_opts(_MODALWIN_) $i $i]}
    }
    set res [IntStatus . MODALS $val]
  } else {
    set res [IntStatus . MODALS]
  }
  return $res
}
#_______________________

proc ::apave::InfoFind {w modal} {

  # Searches data of a window in a list of registered windows.
  #   w - root window's path
  #   modal - yes, if the window is modal
  # Returns: the window's path or "" if not found.
  # See also: InfoWindow

  variable _PU_opts
  foreach winfo [lrange $_PU_opts(_MODALWIN_) 1 end] {  ;# skip 1st window
    incr i
    lassign $winfo w1 var1 modal1
    if {[winfo exists $w1]} {
      if {[string first $w $w1]==0 && $modal==$modal1} {
        return $w1
      }
    } else {
      catch {set _PU_opts(_MODALWIN_) [lreplace $_PU_opts(_MODALWIN_) $i $i]}
    }
  }
  return {}
}
#_______________________

proc ::apave::TreSelect {w idx} {
  # Selects a treeview item.
  #   w - treeview's path
  #   idx - item index

  set items [$w children {}]
  catch {
    set it [lindex $items $idx]
    $w see $it
    $w focus $it
    $w selection set $it  ;# generates <<TreeviewSelect>>
  }
}
#_______________________

proc ::apave::LbxSelect {w idx} {
  # Selects a listbox item.
  #   w - listbox's path
  #   idx - item index

  $w activate $idx
  $w see $idx
  if {[$w cget -selectmode] in {single browse}} {
    $w selection clear 0 end
    $w selection set $idx
    event generate $w <<ListboxSelect>>
  }
}

# ________________________ ObjectProperty _________________________ #
#
# 1st bit: Set/Get properties of object.
#
# Call of setter:
#   oo::define SomeClass {
#     mixin ObjectProperty
#   }
#   SomeClass create someobj
#   ...
#   someobj setProperty Prop1 100
#
# Call of getter:
#   oo::define SomeClass {
#     mixin ObjectProperty
#   }
#   SomeClass create someobj
#   ...
#   someobj getProperty Alter 10
#   someobj getProperty Alter

oo::class create ::apave::ObjectProperty {

  variable _OP_Properties

  constructor {args} {
    array set _OP_Properties {}
    # ObjectProperty can play solo or be a mixin
    if {[llength [self next]]} { next {*}$args }
  }

  destructor {
    array unset _OP_Properties
    if {[llength [self next]]} next
  }

# _______________________________________________________________________ #

  method setProperty {name args} {

    # Sets a property's value as "object-wide".
    #   name - name of property
    #   args - value of property
    #
    # If *args* is omitted, the method returns a property's value.
    #
    # If *args* is set, the method sets a property's value as $args.

    switch -exact [llength $args] {
      0 {return [my getProperty $name]}
      1 {return [set _OP_Properties($name) [lindex $args 0]]}
    }
    puts -nonewline stderr \
      "Wrong # args: should be \"[namespace current] setProperty propertyname ?value?\""
    return -code error
  }
  #_______________________

  method getProperty {name {defvalue ""}} {
    # Gets an property's value as "object-wide".
    #   name - name of property
    #   defvalue - default value
    #
    # If the property had been set, the method returns its value.
    #
    # Otherwise, the method returns the default value (`$defvalue`).

    if {[info exists _OP_Properties($name)]} {
      return $_OP_Properties($name)
    }
    return $defvalue
  }

  ## _________________ EONS ObjectProperty _________________ ##

}

# ________________________ ObjectTheming _________________________ #

oo::class create ::apave::ObjectTheming {

  mixin ::apave::ObjectProperty

## ________________________ Inits _________________________ ##

  constructor {args} {

    my InitCS
    # ObjectTheming can play solo or be a mixin
    if {[llength [self next]]} { next {*}$args }
  }
  #_______________________

  destructor {
    if {[llength [self next]]} next
  }
  #_______________________

  method InitCS {} {

    # Initializes the color scheme processing.

    if {$::apave::_CS_(initall)} {
      my basicFontSize 10 ;# initialize main font size
      my basicTextFont $::apave::_CS_(textFont) ;# initialize main font for text
      my ColorScheme  ;# initialize default colors
      my untouchWidgets *_untouch_*
      set ::apave::_CS_(initall) 0
    }
    return
  }

## ________________________ Fonts _________________________ ##

  method create_FontsType {type args} {
    # Creates fonts used in apave, with additional options.
    #   type - type of the created fonts
    #   args - pairs "option value"
    # Returns a list of two created font names (default & mono).

    set name1 apaveFontDefTyped$type
    set name2 apaveFontMonoTyped$type
    catch {font delete $name1}
    catch {font delete $name2}
    font create $name1 -family $::apave::_CS_(defFont) -size $::apave::_CS_(fs) {*}$args
    font create $name2 -family $::apave::_CS_(textFont) -size $::apave::_CS_(fs) {*}$args
    return [list $name1 $name2]
  }
  #_______________________

  method create_Fonts {} {
    # Creates fonts used in apave.

    catch {font delete apaveFontMono}
    catch {font delete apaveFontDef}
    catch {font delete apaveFontMonoBold}
    catch {font delete apaveFontDefBold}
    font create apaveFontMono -family $::apave::_CS_(textFont) -size $::apave::_CS_(fs)
    font create apaveFontDef -family $::apave::_CS_(defFont) -size $::apave::_CS_(fs)
    font create apaveFontMonoBold  {*}[my boldTextFont]
    font create apaveFontDefBold {*}[my boldDefFont]
    set ::apave::FONTMAIN "[font actual apaveFontDef]"
    set ::apave::FONTMAINBOLD "[font actual apaveFontDefBold]"
  }
  #_______________________

  method basicFontSize {{fs 0} {ds 0}} {

    # Gets/Sets a basic size of font used in apave
    #    fs - font size
    #    ds - incr/decr of size
    #
    # If 'fs' is omitted or ==0, this method gets it.
    # If 'fs' >0, this method sets it.

    if {$fs} {
      set ::apave::_CS_(fs) [expr {$fs + $ds}]
      my create_Fonts
      return $::apave::_CS_(fs)
    } else {
      return [expr {$::apave::_CS_(fs) + $ds}]
    }
  }
  #_______________________

  method basicDefFont {{deffont ""}} {

    # Gets/Sets a basic default font.
    #    deffont - font
    #
    # If 'deffont' is omitted or =="", this method gets it.
    # If 'deffont' is set, this method sets it.

    if {$deffont ne ""} {
      return [set ::apave::_CS_(defFont) $deffont]
    } else {
      return $::apave::_CS_(defFont)
    }
  }
  #_______________________

  method basicTextFont {{textfont ""}} {

    # Gets/Sets a basic font used in editing/viewing text widget.
    #    textfont - font
    #
    # If 'textfont' is omitted or =="", this method gets it.
    # If 'textfont' is set, this method sets it.

    if {$textfont ne ""} {
      return [set ::apave::_CS_(textFont) $textfont]
    } else {
      return $::apave::_CS_(textFont)
    }
  }
  #_______________________

  method basicSmallFont {{smallfont ""}} {

    # Gets/Sets a basic small font used in status bar etc.
    #    smallfont - font
    #
    # If 'smallfont' is omitted or =="", this method gets it.
    # If 'smallfont' is set, this method sets it.

    if {$smallfont ne ""} {
      return [set ::apave::_CS_(smallFont) $smallfont]
    } else {
      return $::apave::_CS_(smallFont)
    }
  }
  #_______________________

  method boldDefFont {{fs 0}} {

    # Returns a bold default font.
    #    fs - font size

    if {$fs == 0} {set fs [my basicFontSize]}
    set bf [font actual basicDefFont]
    return [dict replace $bf -family [my basicDefFont] -weight bold -size $fs]
  }
  #_______________________

  method boldTextFont {{fs 0}} {

    # Returns a bold fixed font.
    #    fs - font size

    if {$fs == 0} {set fs [expr {2+[my basicFontSize]}]}
    set bf [font actual TkFixedFont]
    return [dict replace $bf -family [my basicTextFont] -weight bold -size $fs]
  }

## ________________________ Color schemes _________________________ ##

  method csFont {fontname} {
    # Returns attributes of CS font.
    if {[catch {set font [font configure $fontname]}]} {
      my create_Fonts
      set font [font configure $fontname]
    }
    return $font
  }

  method csFontMono {} {
    # Returns attributes of CS monotype font.
    return [my csFont apaveFontMono]
  }

  method csFontDef {} {
    # Returns attributes of CS default font.
    return [my csFont apaveFontDef]
  }
  #_______________________

  method csDark {{cs ""}} {

    # Returns a flag "a color scheme is dark"
    #   cs - the color scheme to be checked (the current one, if not set)

    if {$cs eq {} || $cs==-3} {set cs [my csCurrent]}
    lassign $::apave::_CS_(TONED) csbasic cstoned
    if {$cs==$cstoned} {set cs $csbasic}
    return [expr {$cs>22}]
  }
  #_______________________

  method csExport {} {

    # TODO

    set theme ""
    foreach arg {tfg1 tbg1 tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr args} {
      if {[catch {set a "$::apave::_CS_(expo,$arg)"}] || $a==""} {
        break
      }
      append theme " $a"
    }
    return $theme
  }
  #_______________________

  method csCurrent {} {

    # Gets an index of current color scheme

    return $::apave::_CS_(index)
  }
  #_______________________

  method csGetName {{ncolor 0}} {

    # Gets a color scheme's name
    #   ncolor - index of color scheme

    if {$ncolor < $::apave::_CS_(MINCS)} {
      return "-2: None"
    } elseif {$ncolor == $::apave::_CS_(MINCS)} {
      return "-1: Basic"
    }
    return [lindex [my ColorScheme $ncolor] 0]
  }
  #_______________________

  method csGet {{ncolor ""}} {

    # Gets a color scheme's colors
    #   ncolor - index of color scheme

    if {$ncolor eq ""} {set ncolor [my csCurrent]}
    return [lrange [my ColorScheme $ncolor] 1 end]
  }
  #_______________________

  method csSet {{ncolor 0} {win .} args} {

    # Sets a color scheme and applies it to Tk/Ttk widgets.
    #   ncolor - index of color scheme
    #   win - window's name
    #   args - list of colors if ncolor=""
    #
    # The `args` can be set as "-doit". In this case the method does set
    # the `ncolor` color scheme (otherwise it doesn't set the CS if it's
    # already of the same `ncolor`).

    # The clrtitf, clrinaf etc. had been designed for e_menu. And as such,
    # they can be used directly, outside of this "color scheming" UI.
    # They set pairs of related fb/bg:
    #   clrtitf/clrtitb is item's fg/bg
    #   clrinaf/clrinab is main fg/bg
    #   clractf/clractb is active (selection) fg/bg
    # and separate colors:
    #   clrhelp is "help" foreground
    #   clrcurs is "caret" background
    #   clrgrey is "shadowing" background
    #   clrhotk is "hotkey/border" foreground
    #
    # In color scheming, these colors are transformed to be consistent
    # with Tk/Ttk's color mechanics.
    #
    # Additionally, "grey" color is used as "border color/disabled foreground".
    #
    # Returns a list of colors used by the color scheme.

    if {$ncolor == -2} {
      ttk::style map Treeview -foreground [list readonly grey disabled grey selected black]
      return {}
    }
    if {$ncolor eq {}} {
      lassign $args \
        clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk tfgI tbgI fM bM tfgW tbgW tHL2 tbHL chkHL res5 res6 res7
    } else {
      foreach cs [list $ncolor $::apave::_CS_(MINCS)] {
        lassign [my csGet $cs] \
          clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk tfgI tbgI fM bM tfgW tbgW tHL2 tbHL chkHL res5 res6 res7
        if {$clrtitf ne ""} break
        set ncolor $cs
      }
      set ::apave::_CS_(index) $ncolor
    }
    set fg $clrinaf  ;# main foreground
    set bg $clrinab  ;# main background
    set fE $clrtitf  ;# fieldforeground foreground
    set bE $clrtitb  ;# fieldforeground background
    set fS $clractf  ;# active/selection foreground
    set bS $clractb  ;# active/selection background
    set hh $clrhelp  ;# (not used in cs' theming) title color
    set gr $clrgrey  ;# (not used in cs' theming) shadowing color
    set cc $clrcurs  ;# caret's color
    set ht $clrhotk  ;# hotkey color
    set grey $gr ;# #808080
    if {$::apave::_CS_(old) != $ncolor || $args eq "-doit"} {
      set ::apave::_CS_(old) $ncolor
      my themeWindow $win [list $fg $bg $fE $bE $fS $bS $grey $bg $cc $ht $hh $tfgI $tbgI $fM $bM $tfgW $tbgW $tHL2 $tbHL $chkHL $res5 $res6 $res7]
      my UpdateColors
      my initTooltip
    }
    set ::apave::FGMAIN $fg
    set ::apave::BGMAIN $bg
    catch {
      if {[my csDark $ncolor]} {::baltip::configure -relief groove}
    }
    return [list $fg $bg $fE $bE $fS $bS $hh $grey $cc $ht $tfgI $tbgI $fM $bM $tfgW $tbgW $tHL2 $tbHL $chkHL $res5 $res6 $res7]
  }
  #_______________________

  method csAdd {newcs {setnew true}} {

    # Registers new color scheme in the list of CS.
    #   newcs -  CS item
    #   setnew - if true, sets the CS as current
    #
    # Does not register the CS, if it is already registered.
    #
    # Returns an index of current CS.
    #
    # See also:
    #   themeWindow

    if {[llength $newcs]<4} {
      set newcs [my ColorScheme]  ;# CS should be defined
    }
    lassign $newcs name tfg2 tfg1 tbg2 tbg1 tfhh - - tcur grey bclr
    set found $::apave::_CS_(NONCS)
    set maxcs [::apave::cs_Max]
    for {set i $::apave::_CS_(MINCS)} {$i<=$maxcs} {incr i} {
      lassign [my csGet $i] cfg2 cfg1 cbg2 cbg1 cfhh - - ccur
      if {$cfg2 eq $tfg2 && $cfg1 eq $tfg1 && $cbg2 eq $tbg2 && \
      $cbg1 eq $tbg1 && $cfhh eq $tfhh && $ccur eq $tcur} {
        set found $i
        break
      }
    }
    if {$found == $::apave::_CS_(MINCS) && [my csCurrent] == $::apave::_CS_(NONCS)} {
      set setnew false ;# no moves from default CS to 'basic'
    } elseif {$found == $::apave::_CS_(NONCS)} {
      lappend ::apave::_CS_(ALL) $newcs
      set found [expr {$maxcs+1}]
    }
    if {$setnew} {set ::apave::_CS_(index) [set ::apave::_CS_(old) $found]}
    return [my csCurrent]
  }
  #_______________________

  method csDeleteExternal {} {
    # Removes all external CS.

    set ::apave::_CS_(ALL) [lreplace $::apave::_CS_(ALL) 48 end]

  }
  #_______________________

  method csToned {cs hue} {
    # Make an external CS that has tones (hues) of colors for a CS.
    #   cs - internal apave CS to be toned
    #   hue - a percent to get light (> 0) or dark (< 0) tones
    # This method allows only one external CS, eliminating others.
    # Returns: "yes" if the CS was toned

    if {$cs <= $::apave::_CS_(NONCS) || $cs > $::apave::_CS_(STDCS)} {
      return no
    }
    my csDeleteExternal
    set CS [my csGet $cs]
    set mainc [my csMainColors]
    set hue [expr {(100.0+$hue)/100.0}]
    foreach i [my csMapTheme] {
      set color [lindex $CS $i]
      if {$i in $mainc} {
        set color [string map {black #000000 white #ffffff grey #808080 \
          red #ff0000 yellow #ffff00 orange #ffa500 #000 #000000 #fff #ffffff} $color]
        scan $color #%2x%2x%2x R G B
        foreach valname {R G B} {
          set val [expr {int([set $valname]*$hue)}]
          set $valname [expr {max(min($val,255),0)}]
        }
        set color [format #%02x%02x%02x $R $G $B]
      }
      lappend TWargs $color
    }
    my themeWindow . $TWargs no
    set ::apave::_CS_(TONED) [list $cs [my csCurrent]]
    return yes

  }

# _______________________________________________________________________ #

  method csMainColors {} {
    # Returns a list of main colors' indices of CS.
    # See also: csMapTheme

    return [list 0 1 2 3 5 10 11 13 16]
  }
  #_______________________

  method csMapTheme {} {
    # Returns a map of CS / themeWindow method colors.
    #
    # The map is a list of indices in CS corresponding to themeWindow's args.
    #
    # CS record is:
    # 0-itemfg 1-mainfg 2-itembg 3-mainbg 4-itemsHL 5-actbg 6-actfg 7-cursor 8-greyed 9-hot \
  10-emfg 11-embg 12-- 13-menubg 14-winfg 15-winbg 16-itemHL2 ...reserved...
    #
    # See also: themeWindow

    return [list 1 3 0 2 6 5 8 3 7 9 4 10 11 1 13 14 15 16 17 18 19 20 21]
  }

# ________________________ Theming _________________________ #

## ________________________ Common procs _________________________ ##

  method ColorScheme {{ncolor ""}} {
    # Gets a full record of color scheme from a list of available ones
    #   ncolor - index of color scheme

    if {$ncolor eq {} || $ncolor<0} {
      # basic color scheme: get colors from a current ttk::style colors
      set fW black
      set bW #FBFB95
      set bg2 #e4e4e4
      if {[info exists ::apave::_CS_(def_fg)]} {
        if {$ncolor == $::apave::_CS_(NONCS)} {set bg2 #e5e5e5}
        set fg $::apave::_CS_(def_fg)
        set fg2 #2b3f55
        set bg $::apave::_CS_(def_bg)
        set fS $::apave::_CS_(def_fS)
        set bS $::apave::_CS_(def_bS)
        set bA $::apave::_CS_(def_bA)
      } else {
        set ::apave::_CS_(index) $::apave::_CS_(NONCS)
        lassign [::apave::parseOptions [ttk::style configure .] \
          -foreground #000000 -background #d9d9d9 -troughcolor #c3c3c3] fg bg tc
        set fS $::apave::_CS_(!FG)
        set bS $::apave::_CS_(!BG)
        lassign [::apave::parseOptions [ttk::style map . -background] \
          disabled #d9d9d9 active #ececec] bD bA
        if {$bA eq {#ececec}} {set bA #ffffff}
        lassign [::apave::parseOptions [ttk::style map . -foreground] \
          disabled #a3a3a3] fD
        lassign [::apave::parseOptions [ttk::style map . -selectbackground] \
          !focus #9e9a91] bclr
        set ::apave::_CS_(def_fg) [set fg2 $fg]
        set ::apave::_CS_(def_bg) $bg
        set ::apave::_CS_(def_fS) $fS
        set ::apave::_CS_(def_bS) $bS
        set ::apave::_CS_(def_fD) $fD
        set ::apave::_CS_(def_bD) $bD
        set ::apave::_CS_(def_bA) $bA
        set ::apave::_CS_(def_tc) $tc
        set ::apave::_CS_(def_bclr) $bclr
      }
      return [list default \
           $fg    $fg     $bA    $bg     $fg2    $bS     $fS    #444  grey   #4f6379 $fS $bS - $bg $fW $bW $bg2]
      # clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk fI  bI fM bM fW bW
    }
    return [lindex $::apave::_CS_(ALL) $ncolor]
  }

# _______________________________________________________________________ #

  method UpdateSelectAttrs {w} {

    # Updates attributes for selection.
    #   w - window's name
    # Some widgets (e.g. listbox) need a work-around to set
    # attributes for selection in run-time, namely at focusing in/out.

    set fD $::apave::_CS_(!FG)
    set bD $::apave::_CS_(!BG)
    set f -selectforeground
    set b -selectbackground
    lassign [::apave::parseOptions [ttk::style configure .] $f $fD $b $bD] fS bS
    ::apave::bindToEvent $w <FocusIn>  $w configure $f $fS $b $bS
    ::apave::bindToEvent $w <FocusOut> $w configure $f $fD $b $bD
    return
  }
  #_______________________

  method Ttk_style {oper ts opt val} {

    # Sets a new style options.
    #   oper - command of ttk::style ("map" or "configure")
    #   ts - type of style to be configurated
    #   opt - option's name
    #   val - option's value

    if {![catch {set oldval [ttk::style $oper $ts $opt]}]} {
      catch {ttk::style $oper $ts $opt $val}
      if {$oldval eq {} && $oper eq {configure}} {
        switch -exact -- $opt {
          -foreground - -background {
            set oldval [ttk::style $oper . $opt]
          }
          -fieldbackground {
            set oldval white
          }
          -insertcolor {
            set oldval black
          }
        }
      }
    }
    return
  }
  #_______________________

  method apaveTheme {{theme {}}} {
    # Checks if apave color scheme is used (always for standard ttk themes).
    #   theme - a theme to be checked (if omitted, a current ttk theme)

    if {$theme eq {}} {set theme [ttk::style theme use]}
    return [expr {$theme in {clam alt classic default awdark awlight}}]
  }
  #_______________________

  method initTooltip {args} {

    # Configurates colors and other attributes of tooltip.
    #  args - options of ::baltip::configure

    lassign [lrange [my csGet] 14 15] fW bW
    ::baltip config -fg $fW -bg $bW -global yes
    ::baltip config {*}$args
    return
  }

## ________________________ Theme methods _________________________ ##

  method Main_Style {tfg1 tbg1 tfg2 tbg2 tfgS tbgS bclr tc fA bA bD} {

    # Sets main colors of application
    #   tfg1 - main foreground
    #   tbg1 - main background
    #   tfg2 - not used
    #   tbg2 - not used
    #   tfgS - selectforeground
    #   tbgS - selectbackground
    #   bclr - bordercolor
    #   tc - troughcolor
    #   fA - foreground active
    #   bA - background active
    #   bD - background disabled
    #
    # The *foreground disabled* is set as `grey`.

    my create_Fonts
    ttk::style configure "." \
      -background        $tbg1 \
      -foreground        $tfg1 \
      -bordercolor       $bclr \
      -darkcolor         $tbg1 \
      -lightcolor        $tbg1 \
      -troughcolor       $tc \
      -arrowcolor        $tfg1 \
      -selectbackground  $tbgS \
      -selectforeground  $tfgS \
      ;#-selectborderwidth 0
    ttk::style map "." \
      -background       [list disabled $bD active $bA] \
      -foreground       [list disabled grey active $fA]
  }
  #_______________________

  method themeWindow {win {clrs ""} {isCS true} args} {

    # Changes a Tk style (theming a bit)
    #   win - window's name
    #   clrs - list of colors
    #   isCS - true, if the colors are taken from a CS
    #   args - other options
    #
    # The clrs contains:
    #   tfg1 - foreground for themed widgets (main stock)
    #   tbg1 - background for themed widgets (main stock)
    #   tfg2 - foreground for themed widgets (enter data stock)
    #   tbg2 - background for themed widgets (enter data stock)
    #   tfgS - foreground for selection
    #   tbgS - background for selection
    #   tfgD - foreground for disabled themed widgets
    #   tbgD - background for disabled themed widgets
    #   tcur - insertion cursor color
    #   bclr - hotkey/border color
    #   thlp - help color
    #   tfgI - foreground for external CS
    #   tbgI - background for external CS
    #   tfgM - foreground for menus
    #   tbgM - background for menus
    #
    # The themeWindow can be used outside of "color scheme" UI.
    # E.g., in TKE editor, e_menu and add_shortcuts plugins use it to
    # be consistent with TKE theme.

    if {![::apave::cs_Active]} {
      my themeMandatory $win {*}$args
      return
    }
    lassign $clrs tfg1 tbg1 tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr \
      thlp tfgI tbgI tfgM tbgM twfg twbg tHL2 tbHL chkHL res5 res6 res7
    if {$tfg1 eq {-}} return
    if {!$isCS} {
      # if 'external  scheme' is used, register it in _CS_(ALL)
      # and set it as the current CS

# <CS>    itemfg  mainfg  itembg  mainbg  itemsHL  actbg   actfg  cursor  greyed   hot \
  emfg  embg   -  menubg  winfg   winbg   itemHL2 #003...reserved...

      my csAdd [list CS-[expr {[::apave::cs_Max]+1}] $tfg2 $tfg1 $tbg2 $tbg1 \
        $thlp $tbgS $tfgS $tcur $tfgD $bclr $tfgI $tbgI $tfgM $tbgM \
        $twfg $twbg $tHL2 $tbHL $chkHL $res5 $res6 $res7]
    }
    if {$tfgI eq {}} {set tfgI $tfg2}
    if {$tbgI eq {}} {set tbgI $tbg2}
    if {$tfgM in {{} -}} {set tfgM $tfg1}
    if {$tbgM eq {}} {set tbgM $tbg1}
    my Main_Style $tfg1 $tbg1 $tfg2 $tbg2 $tfgS $tbgS $tfgD $tbg1 $tfg1 $tbg2 $tbg1
    foreach arg {tfg1 tbg1 tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr \
    thlp tfgI tbgI tfgM tbgM twfg twbg tHL2 tbHL chkHL res5 res6 res7 args} {
      if {$win eq {.}} {
        set ::apave::_C_($win,$arg) [set $arg]
      }
      set ::apave::_CS_(expo,$arg) [set $arg]
    }
    set fontdef [font actual apaveFontDef]
    # configuring themed widgets
    foreach ts {TLabel TButton TCheckbutton TRadiobutton} {
      my Ttk_style configure $ts -font $fontdef
      my Ttk_style configure $ts -foreground $tfg1
      my Ttk_style configure $ts -background $tbg1
      my Ttk_style map $ts -background [list pressed $tbg2 active $tbg2 alternate $tbg2]
      my Ttk_style map $ts -foreground [list disabled $tfgD pressed $bclr active $tfg2 alternate $tfg2 focus $tfg2 selected $tfg1]
      my Ttk_style map $ts -bordercolor [list focus $bclr pressed $bclr]
      my Ttk_style map $ts -lightcolor [list focus $bclr]
      my Ttk_style map $ts -darkcolor [list focus $bclr]
    }
    my Ttk_style configure TLabelframe.Label -foreground $thlp  ;# bclr $tfg2
    my Ttk_style configure TLabelframe.Label -background $tbg1
    my Ttk_style configure TLabelframe.Label -font $fontdef
    foreach ts {TNotebook TFrame} {
      my Ttk_style configure $ts -background $tbg1
      my Ttk_style map $ts -background [list focus $tbg1 !focus $tbg1]
    }
    foreach ts {TNotebook.Tab} {
      my Ttk_style configure $ts -font $fontdef
      if {[my apaveTheme]} {
        my Ttk_style map $ts -foreground [list {selected !active} $tfgS {!selected !active} $tfgM active $tfg2 {selected active} $tfg2]
      }
      my Ttk_style map $ts -background [list {selected !active} $tbgS {!selected !active} $tbgM {!selected active} $tbg2 {selected active} $tbg2]
    }
    foreach ts {TEntry Treeview TSpinbox TCombobox TCombobox.Spinbox TMatchbox TNotebook.Tab TScrollbar TScale} {
      my Ttk_style map $ts -lightcolor [list focus $bclr active $bclr]
      my Ttk_style map $ts -darkcolor [list focus $bclr active $bclr]
    }
    my Ttk_style map TScrollbar -troughcolor [list !active $tbg1 active $tbg2]
    my Ttk_style map TProgressbar -troughcolor [list !active $tbg2 active $tbg1]
    my Ttk_style configure TProgressbar -background $tbgS
    if {[set cs [my csCurrent]]<20} {
      ttk::style conf TSeparator -background #a2a2a2
    } elseif {$cs<23} {
      ttk::style conf TSeparator -background #656565
    } elseif {$cs<28} {
      ttk::style conf TSeparator -background #3c3c3c
    } elseif {$cs>35 && $cs<39} {
      ttk::style conf TSeparator -background #313131
    } elseif {$cs==43 || $cs>44} {
      ttk::style conf TSeparator -background #2e2e2e
    }
    foreach ts {TEntry Treeview TSpinbox TCombobox TCombobox.Spinbox TMatchbox} {
      my Ttk_style configure $ts -font $fontdef
      my Ttk_style configure $ts -selectforeground $tfgS
      my Ttk_style configure $ts -selectbackground $tbgS
      my Ttk_style map $ts -selectforeground [list !focus $::apave::_CS_(!FG)]
      my Ttk_style map $ts -selectbackground [list !focus $::apave::_CS_(!BG)]
      my Ttk_style configure $ts -fieldforeground $tfg2
      my Ttk_style configure $ts -fieldbackground $tbg2
      my Ttk_style configure $ts -insertcolor $tcur
      my Ttk_style map $ts -bordercolor [list focus $bclr active $bclr]
      my Ttk_style configure $ts -insertwidth $::apave::_CS_(CURSORWIDTH)
      if {$ts eq {TCombobox}} {
        # combobox is sort of individual
        my Ttk_style configure $ts -foreground $tfg1
        my Ttk_style configure $ts -background $tbg1
        my Ttk_style map $ts -background [list {readonly focus} $tbg2 {active focus} $tbg2]
        my Ttk_style map $ts -foreground [list {readonly focus} $tfg2 {active focus} $tfg2]
        my Ttk_style map $ts -fieldforeground [list {active focus} $tfg2 readonly $tfg2 disabled $tfgD]
        my Ttk_style map $ts -fieldbackground [list {active focus} $tbg2 {readonly focus} $tbg2 {readonly !focus} $tbg1 disabled $tbgD]
      } else {
        my Ttk_style configure $ts -foreground $tfg2
        my Ttk_style configure $ts -background $tbg2
        my Ttk_style map $ts -foreground [list readonly $tfgD disabled $tfgD selected $tfgS]
        my Ttk_style map $ts -background [list readonly $tbgD disabled $tbgD selected $tbgS]
        my Ttk_style map $ts -fieldforeground [list readonly $tfgD disabled $tfgD]
        my Ttk_style map $ts -fieldbackground [list readonly $tbgD disabled $tbgD]
      }
    }
    ttk::style configure Heading -font $fontdef -relief raised -padding 1 -background $tbg1
    option add *Listbox.font $fontdef
    option add *Menu.font $fontdef
    my Ttk_style configure TMenubutton -foreground $tfgM
    my Ttk_style configure TMenubutton -background $tbgM
    my Ttk_style configure TButton -foreground $tfgM
    my Ttk_style configure TButton -background $tbgM
    foreach {nam clr} {back tbg2 fore tfg2 selectBack tbgS selectFore tfgS} {
      option add *Listbox.${nam}ground [set $clr]
    }
    foreach {nam clr} {back tbgM fore tfgM selectBack tbgS selectFore tfgS} {
      option add *Menu.${nam}ground [set $clr]
    }
    foreach ts {TRadiobutton TCheckbutton} {
      ttk::style map $ts -background [list focus $tbg2 !focus $tbg1]
    }
    if {[my csDark]} {
      # esp. for default/alt/classic themes and dark CS:
      # checked buttons to be lighter
      foreach ts {TCheckbutton TRadiobutton} {
        ttk::style configure $ts -indicatorcolor $tbgM
        ttk::style map $ts -indicatorcolor [list pressed $tbg2 selected $chkHL]
      }
    }
    # non-themed widgets of button and entry types
    foreach ts [my NonThemedWidgets button] {
      set ::apave::_C_($ts,0) 6
      set ::apave::_C_($ts,1) "-background $tbg1"
      set ::apave::_C_($ts,2) "-foreground $tfg1"
      set ::apave::_C_($ts,3) "-activeforeground $tfg2"
      set ::apave::_C_($ts,4) "-activebackground $tbg2"
      set ::apave::_C_($ts,5) "-font {$fontdef}"
      set ::apave::_C_($ts,6) "-highlightbackground $tfgD"
      switch -exact -- $ts {
        checkbutton - radiobutton {
          set ::apave::_C_($ts,0) 8
          set ::apave::_C_($ts,7) "-selectcolor $tbg1"
          set ::apave::_C_($ts,8) "-highlightbackground $tbg1"
        }
        frame - scrollbar - scale - tframe - tnotebook {
          set ::apave::_C_($ts,0) 8
          set ::apave::_C_($ts,4) "-activebackground $bclr"
          set ::apave::_C_($ts,7) "-troughcolor $tbg1"
          set ::apave::_C_($ts,8) "-elementborderwidth 2"
        }
        menu {
          set ::apave::_C_($ts,0) 9
          set ::apave::_C_($ts,1) "-background $tbgM"
          set ::apave::_C_($ts,3) "-activeforeground $tfgS"
          set ::apave::_C_($ts,4) "-activebackground $tbgS"
          set ::apave::_C_($ts,5) "-disabledforeground $tfgD"
          set ::apave::_C_($ts,6) "-font {$fontdef}"
          if {[::iswindows]} {
            set ::apave::_C_($ts,0) 6
          } elseif {[my apaveTheme]} {
              set ::apave::_C_($ts,7) {-borderwidth 2}
              set ::apave::_C_($ts,8) {-relief raised}
          } else {
              set ::apave::_C_($ts,7) {-borderwidth 1}
              set ::apave::_C_($ts,8) {-relief groove}
          }
          if {[my csDark]} {set c white} {set c black}
          set ::apave::_C_($ts,9) "-selectcolor $c"
        }
        canvas {
          set ::apave::_C_($ts,1) "-background $tbg2"
        }
      }
    }
    foreach ts [my NonThemedWidgets entry] {
      set ::apave::_C_($ts,0) 3
      set ::apave::_C_($ts,1) "-foreground $tfg2"
      set ::apave::_C_($ts,2) "-background $tbg2"
      set ::apave::_C_($ts,3) "-highlightbackground $tfgD"
      switch -exact -- $ts {
        tcombobox - tmatchbox {
          set ::apave::_C_($ts,0) 8
          set ::apave::_C_($ts,4) "-disabledforeground $tfgD"
          set ::apave::_C_($ts,5) "-disabledbackground $tbgD"
          set ::apave::_C_($ts,6) "-highlightcolor $bclr"
          set ::apave::_C_($ts,7) "-font {$fontdef}"
          set ::apave::_C_($ts,8) "-insertbackground $tcur"
        }
        text - entry - tentry {
          set ::apave::_C_($ts,0) 11
          set ::apave::_C_($ts,4) "-selectforeground $tfgS"
          set ::apave::_C_($ts,5) "-selectbackground $tbgS"
          set ::apave::_C_($ts,6) "-disabledforeground $tfgD"
          set ::apave::_C_($ts,7) "-disabledbackground $tbgD"
          set ::apave::_C_($ts,8) "-highlightcolor $bclr"
          if {$ts eq {text}} {
            set ::apave::_C_($ts,9) "-font {[font actual apaveFontMono]}"
          } else {
            set ::apave::_C_($ts,9) "-font {$fontdef}"
          }
          set ::apave::_C_($ts,10) "-insertwidth $::apave::_CS_(CURSORWIDTH)"
          set ::apave::_C_($ts,11) "-insertbackground $tcur"
        }
        spinbox - tspinbox - listbox - tablelist {
          set ::apave::_C_($ts,0) 12
          set ::apave::_C_($ts,4) "-insertbackground $tcur"
          set ::apave::_C_($ts,5) "-buttonbackground $tbg2"
          set ::apave::_C_($ts,6) "-selectforeground $::apave::_CS_(!FG)"
          set ::apave::_C_($ts,7) "-selectbackground $::apave::_CS_(!BG)"
          set ::apave::_C_($ts,8) "-disabledforeground $tfgD"
          set ::apave::_C_($ts,9) "-disabledbackground $tbgD"
          set ::apave::_C_($ts,10) "-font {$fontdef}"
          set ::apave::_C_($ts,11) "-insertwidth $::apave::_CS_(CURSORWIDTH)"
          set ::apave::_C_($ts,12) "-highlightcolor $bclr"
        }
      }
    }
    foreach ts {disabled} {
      set ::apave::_C_($ts,0) 4
      set ::apave::_C_($ts,1) "-foreground $tfgD"
      set ::apave::_C_($ts,2) "-background $tbgD"
      set ::apave::_C_($ts,3) "-disabledforeground $tfgD"
      set ::apave::_C_($ts,4) "-disabledbackground $tbgD"
    }
    foreach ts {readonly} {
      set ::apave::_C_($ts,0) 2
      set ::apave::_C_($ts,1) "-foreground $tfg1"
      set ::apave::_C_($ts,2) "-background $tbg1"
    }
    my themeMandatory $win {*}$args
    return
  }
  #_______________________

  method themeMandatory {win args} {

    # Themes all that must be themed.
    #   win - window's name
    #   args - options

    # set the new options for nested widgets (menu e.g.)
    my themeNonThemed $win
    # other options per widget type
    foreach {typ v1 v2} $args {
      if {$typ eq "-"} {
        # config of non-themed widgets
        set ind [incr ::apave::_C_($v1,0)]
        set ::apave::_C_($v1,$ind) "$v2"
      } else {
        # style maps of themed widgets
        my Ttk_style map $typ $v1 [list {*}$v2]
      }
    }
    ::apave::initStyles
    my ThemeChoosers
    return
  }
  #_______________________

  method untouchWidgets {args} {

    # Makes non-ttk widgets to be untouched by coloring or gets their list.
    #   args - list of widget globs (e.g. {.em.fr.win.* .em.fr.h1 .em.fr.h2})
    # If args not set, returns the list of untouched widgets.
    #
    # See also:
    #   themeNonThemed

    if {[llength $args]==0} {return $::apave::_CS_(untouch)}
    foreach u $args {
      if {[lsearch -exact $::apave::_CS_(untouch) $u]==-1} {
        lappend ::apave::_CS_(untouch) $u
      }
    }
  }
  #_______________________

  method themeExternal {args} {
    # Configures an external dialogue so that its colors accord with a current CS.
    #   args - list of untouched widgets

    if {[set cs [my csCurrent]] != -2} {
      foreach untw $args {my untouchWidgets $untw}
      after idle [list [self] csSet $cs . -doit]  ;# theme the dialogue to be run
    }
  }
  #_______________________

  method themeNonThemed {win {addwid {}}} {

    # Updates the appearances of currently used widgets (non-themed).
    #   win - window path whose children will be touched
    #   addwid - additional widget(s) to be touched
    #
    # See also:
    #   untouchWidgets

    set wtypes [my NonThemedWidgets all]
    set lwid [winfo children $win]
    lappend lwid {*}$addwid
    foreach w1 $lwid {
      my themeNonThemed $w1
      set ts [string tolower [winfo class $w1]]
      set tch 1
      foreach u $::apave::_CS_(untouch) {
        if {[string match $u $w1]} {set tch 0; break}
      }
      if {$tch && [info exist ::apave::_C_($ts,0)] && \
      [lsearch -exact $wtypes $ts]>-1} {
        set i 0
        while {[incr i] <= $::apave::_C_($ts,0)} {
          lassign $::apave::_C_($ts,$i) opt val
          catch {
            if {[string first __tooltip__.label $w1]<0} {
              $w1 configure $opt $val
              switch -exact -- [$w1 cget -state] {
                disabled {
                  $w1 configure {*}[my NonTtkStyle $w1 1]
                }
                readonly {
                  $w1 configure {*}[my NonTtkStyle $w1 2]
                }
              }
            }
            set nam3 [string range [my ownWName $w1] 0 2]
            if {$nam3 in {lbx tbl flb enT spX tex}} {
              my UpdateSelectAttrs $w1
            }
          }
        }
      }
    }
    return
  }
  #_______________________

  method NonThemedWidgets {selector} {

    # Lists the non-themed widgets to process in apave.
    #   selector - sets a widget group to return as a list
    # The `selector` can be `entry`, `button` or `all`.

    switch -exact -- $selector {
      entry {
        return [list tspinbox tcombobox tentry entry text listbox spinbox tablelist tmatchbox]
      }
      button {
        return [list label button menu menubutton checkbutton radiobutton frame labelframe scale scrollbar canvas]
      }
    }
    return [list tspinbox tcombobox tentry entry text listbox spinbox label button \
      menu menubutton checkbutton radiobutton frame labelframe scale \
      scrollbar canvas tablelist tmatchbox]
  }
  #_______________________

  method NonTtkTheme {win} {

    # Calls themeWindow to color non-ttk widgets.
    #   win - window's name

    if {[info exists ::apave::_C_(.,tfg1)] &&
    $::apave::_CS_(expo,tfg1) ne "-"} {
      my themeWindow $win [list \
         $::apave::_C_(.,tfg1) \
         $::apave::_C_(.,tbg1) \
         $::apave::_C_(.,tfg2) \
         $::apave::_C_(.,tbg2) \
         $::apave::_C_(.,tfgS) \
         $::apave::_C_(.,tbgS) \
         $::apave::_C_(.,tfgD) \
         $::apave::_C_(.,tbgD) \
         $::apave::_C_(.,tcur) \
         $::apave::_C_(.,bclr) \
         $::apave::_C_(.,thlp) \
         $::apave::_C_(.,tfgI) \
         $::apave::_C_(.,tbgI) \
         $::apave::_C_(.,tfgM) \
         $::apave::_C_(.,tbgM) \
         $::apave::_C_(.,twfg) \
         $::apave::_C_(.,twbg) \
         $::apave::_C_(.,tHL2)] \
         false {*}$::apave::_C_(.,args)
    }
    return
  }
  #_______________________

  method NonTtkStyle {typ {dsbl 0}} {
    # Makes styling for non-ttk widgets.
    #   typ - widget's type (the same as in "APave::widgetType" method)
    #   dsbl - `1` for disabled; `2` for readonly; otherwise for all widgets
    # See also: APave::widgetType

    if {$dsbl} {
      set disopt {}
      if {$dsbl==1 && [info exist ::apave::_C_(disabled,0)]} {
        set typ [string range [lindex [split $typ .] end] 0 2]
        switch -exact -- $typ {
          frA - lfR {
            append disopt { } $::apave::_C_(disabled,2)
          }
          enT - spX {
            append disopt { } $::apave::_C_(disabled,1) \
                          { } $::apave::_C_(disabled,2) \
                          { } $::apave::_C_(disabled,3) \
                          { } $::apave::_C_(disabled,4)
          }
          laB - tex - chB - raD - lbx - scA {
            append disopt { } $::apave::_C_(disabled,1) \
                          { } $::apave::_C_(disabled,2)
          }
        }
      } elseif {$dsbl==2 && [info exist ::apave::_C_(readonly,0)]} {
        append disopt { } \
          $::apave::_C_(readonly,1) { } $::apave::_C_(readonly,2) \
      }
      return $disopt
    }
    set opts {-foreground -foreground -background -background}
    lassign "" ts2 ts3 opts2 opts3
    switch -exact -- $typ {
      buT {set ts TButton}
      chB {set ts TCheckbutton
        lappend opts -background -selectcolor
      }
      enT {
        set ts TEntry
        set opts  {-foreground -foreground -fieldbackground -background \
          -insertbackground -insertcolor}
      }
      tex {
        set ts TEntry
        set opts {-foreground -foreground -fieldbackground -background \
          -insertcolor -insertbackground \
          -selectforeground -selectforeground -selectbackground -selectbackground
        }
      }
      frA {set ts TFrame; set opts {-background -background}}
      laB {set ts TLabel}
      lbx {set ts TLabel}
      lfR {set ts TLabelframe}
      raD {set ts TRadiobutton}
      scA {set ts TScale}
      sbH -
      sbV {set ts TScrollbar; set opts {-background -background}}
      spX {set ts TSpinbox}
      default {
        return {}
      }
    }
    set att {}
    for {set i 1} {$i<=3} {incr i} {
      if {$i>1} {
        set ts [set ts$i]
        set opts [set opts$i]
      }
      foreach {opt1 opt2} $opts {
        if {[catch {set val [ttk::style configure $ts $opt1]}]} {
          return $att
        }
        if {$val eq {}} {
          catch { set val [ttk::style $oper . $opt2] }
        }
        if {$val ne {}} {
          append att " $opt2 $val"
        }
      }
    }
    return $att
  }

## ________________________ Popup menus _________________________ ##

  method ThemePopup {mnu args} {

    # Recursively configures popup menus.
    #   mnu - menu's name (path)
    #   args - options of configuration
    # See also: themePopup

    if {[set last [$mnu index end]] ne {none}} {
      $mnu configure {*}$args
      for {set i 0} {$i <= $last} {incr i} {
        switch -exact -- [$mnu type $i] {
          cascade {
            my ThemePopup [$mnu entrycget $i -menu] {*}$args
          }
          command {
            $mnu entryconfigure $i {*}$args
          }
        }
      }
    }
  }
  #_______________________

  method themePopup {mnu} {

    # Configures a popup menu so that its colors accord with a current CS.
    #   mnu - menu's name (path)

    if {[my csCurrent] == $::apave::_CS_(NONCS)} return
    lassign [my csGet] - fg - bg2 - bgS fgS - tfgD - - - - bg
    if {$bg eq {}} {set bg $bg2}
    set opts "-foreground $fg -background $bg -activeforeground $fgS \
      -activebackground $bgS -font {[font actual apaveFontDef]}"
    if {[catch {my ThemePopup $mnu {*}$opts -disabledforeground $tfgD}]} {
      my ThemePopup $mnu {*}$opts
    }
    my themeNonThemed $mnu $mnu
  }

## ________________________ Tk choosers _________________________ ##

  method ThemeChoosers {} {

    # Configures file/dir choosers so that its colors accord with a current CS.

    if {[info commands ::apave::_TK_TOPLEVEL] ne ""} return
    rename ::toplevel ::apave::_TK_TOPLEVEL
    proc ::toplevel {args} {
      set res [eval ::apave::_TK_TOPLEVEL $args]
      set w [lindex $args 0]
      rename $w ::apave::_W_TOPLEVEL$w
      proc ::$w {args} " \
        set cs \[::apave::obj csCurrent\] ;\
        if {{configure -menu} eq \$args} {set args {configure}} ;\
        if {\$cs>-2 && \[string first {configure} \$args\]==0} { \
          lassign \[::apave::obj csGet \$cs\] fg - bg ;\
          lappend args -background \$bg \
        } ;\
        return \[eval ::apave::_W_TOPLEVEL$w \$args\]
      "
      return $res
    }
    rename ::canvas ::apave::_TK_CANVAS
    proc ::canvas {args} {
      set res [eval ::apave::_TK_CANVAS $args]
      set w [lindex $args 0]
      if {[string match "*cHull.canvas" $w]} {
        rename $w ::apave::_W_CANVAS$w
        proc ::$w {args} " \
          set cs \[::apave::obj csCurrent\] ;\
          lassign \[::apave::obj csGet \$cs\] fg - bg ;\
          if {\$cs>-2} { \
            if {\[string first {create text} \$args\]==0 || \
            \[string first {itemconfigure} \$args\]==0 && \
            \[string first {-fill black} \$args\]>0} { \
              dict set args -fill \$fg ;\
              dict set args -font apaveFontDef \
            } \
          }  ;\
          ::apave::_W_CANVAS$w configure -bg \$bg ;\
          return \[eval ::apave::_W_CANVAS$w \$args\]
        "
      }
      return $res
    }
  }

  ## __________________ EONS ObjectTheming ___________________ ##

}

# ___________________________________ EOF _____________________________________ #

#%   DOCTEST   SOURCE   tests/obbit_1.test
#RUNF1: ../../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
#-RUNF1: ./tests/test2_pave.tcl
#RUNF1: ./tests/test2_pave.tcl 10 10 12 "small icons"
