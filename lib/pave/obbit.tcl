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

  # - common options/constants of apave utils
  variable _PU_opts
  array set _PU_opts [list -NONE =NONE=]
  set _PU_opts(_ERROR_) ""
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
  emfg  embg   -  menubg  winfg   winbg   itemHL2 #003...reserved...

# <CS>    clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk \
  fI     bI  --12--  bM    fW      bW     itemHL2 #003...reserved...

  set ::apave::_CS_(ALL) {
{{ 0: Grey} "#000" #0D0D0D #FFFFFF #DADCE0 #5c1616 #AFAFAF #000 #444 grey #933232 #000 #AFAFAF - #caccd0 #000 #FBFB95 #e0e0d8 #003 #004 #005 #006 #007}
{{ 1: Greyish} "#121212" #1A1A1A #f1f1f1 #dddddd #6c220c #bababa #000 #444 grey #933232 #000 #a9a9a9 - #cecece #000 #FBFB96 #dadada #003 #004 #005 #006 #007}
{{ 2: InverseGrey} "#000" #000 #c9cbcf #DADCE0 #5c1616 #a5a5a5 #000 #444 grey #933232 #000 #AFAFAF - #c9cbcf #000 #FBFB95 #bebebe #003 #004 #005 #006 #007}
{{ 3: AntiDark1} "#050b0d" #050b0d #F8F8F8 #dadad8 #5c1616 #AFAFAF #000 #444 grey #933232 #000 #AFAFAF - #caccd0 #000 #FBFB95 #e0e0d8 #003 #004 #005 #006 #007}
{{ 4: AntiDark2} "#050b0d" #050b0d #e9e9e7 #F8F8F8 #5c1616 #AFAFAF #000 #444 grey #933232 #000 #AFAFAF - #e1e1df #000 #FBFB95 #d5d5d3 #003 #004 #005 #006 #007}
{{ 5: Rosy} "#2B122A" #000 #FFFFFF #F6E6E9 #570957 #C5ADC8 #000 #444 grey #870287 #000 #C5ADC8 - #e3d3d6 #000 #FBFB95 #e5e3e1 #003 #004 #005 #006 #007}
{{ 6: Clay} "#000" #000 #fdf4ed #ded3cc #500a0a #bcaea2 #000 #444 grey #843500 #fff #766b5f - #d5c9c1 #000 #FBFB95 #e1dfde #003 #004 #005 #006 #007}
{{ 7: Dawn} "#08085D" #030358 #FFFFFF #e3f9f9 #562222 #a3dce5 #000 #444 grey #933232 #000 #99d2db - #d3e9e9 #000 #FBFB96 #dbe9ed #003 #004 #005 #006 #007}
{{ 8: Sky} "#102433" #0A1D33 #d0fdff #bdf6ff #562222 #95ced7 #000 #444 grey #933232 #000 #9fd8e1 - #b1eaf3 #000 #FBFB95 #c0e9ef #003 #004 #005 #006 #007}
{{ 9: Celestial} "#141414" #151616 #d1ffff #a9e2f8 #562222 #82bbd1 #000 #444 grey #933232 #000 #7fb8ce - #9dd6f9 #000 #FBFB96 #b6e4e4 #003 #004 #005 #006 #007}
{{10: Florid} "#000" #004000 #e4fce4 #fff #5c1616 #93e493 #0F2D0F #444 grey #802e00 #000 #8adb8a - #eefdee #000 #FBFB96 #d7e6d7 #003 #004 #005 #006 #007}
{{11: LightGreen} "#122B05" #091900 #edffed #DEF8DE #562222 #A8CCA8 #000 #444 grey #933232 #000 #A8CCA8 - #d0ead0 #000 #FBFB96 #dee9de #003 #004 #005 #006 #007}
{{12: InverseGreen} "#122B05" #091900 #cce6c8 #DEF8DE #562222 #9cc09c #000 #444 grey #933232 #000 #98bc98 - #cce6cc #000 #FBFB96 #bed8ba #003 #004 #005 #006 #007}
{{13: GreenPeace} "#001000" #001000 #e1ffdd #cadfca #562222 #9dbb99 #000 #444 grey #933232 #000 #9cb694 - #c1dfbd #000 #FBFB96 #d2e1d2 #003 #004 #005 #006 #007}
{{14: African} "#000" #000 #fff #ffffe7 #460000 #ffd797 #000 #6f2509 #7e7e7e #771d00 #000 #e6ae80 - #fffff9 #000 #eded89 #ededd5 #003 #004 #005 #006 #007}
{{15: African1} "#000" #000 #f5f5dd #f2ebd2 #460000 #ffc48a #000 #6f2509 #7e7e7e #771d00 #000 #e6ae80 - #fffce3 #000 #eded89 #e3e3cb #003 #004 #005 #006 #007}
{{16: African2} "#000" #000 #ffffe4 #eae7c0 #500a0a #eaac7a #000 #6f2509 grey #771d00 #00003c #e6ae80 - #f4f0ca #000 #fbfb74 #e7e7cb #003 #004 #005 #006 #007}
{{17: African3} "#000" #000 #fdf9d0 #d5d2af #500a0a #d59d6f #000 #6f2509 grey #771d00 #00003c #e6ae80 - #dedbb8 #000 #fbfb74 #e5e5cc #003 #004 #005 #006 #007}
{{18: Yellowstone} "#00002f" #00003c #cac08f #cfcdb1 #591c0e #c89160 #000 #444 grey #771d00 #3b1516 #eba969 - #c2c0a4 #000 #ffff45 #c1b690 #003 #004 #005 #006 #007}
{{19: Notebook} "#000" #000 #e9e1c8 #c2bca8 #460000 #d59d6f #000 #444 #7e7e7e #771d00 #000 #e6ae80 - #d0cab6 #000 #eded89 #dad2b9 #003 #004 #005 #006 #007}
{{20: Notebook1} "#000" #000 #dad2b9 #b5af9b #460000 #d59d6f #000 #444 #707070 #771d00 #000 #e6ae80 - #c5bfab #000 #eded89 #ccc4ab #003 #004 #005 #006 #007}
{{21: Notebook2} "#000" #000 #cdc5ac #a6a08c #460000 #d59d6f #000 #444 #606060 #771d00 #000 #e6ae80 - #b4ae9a #000 #eded89 #c1b9a0 #003 #004 #005 #006 #007}
{{22: Notebook3} "#000" #000 #beb69d #96907c #460000 #d59d6f #000 #444 #505050 #771d00 #000 #e6ae80 - #a6a08c #000 #eded89 #b2aa91 #003 #004 #005 #006 #007}
{{23: Darcula} "#ececec" #c7c7c7 #272727 #323232 #FEEFA8 #2F5692 #e1e1e1 #f4f49f grey #d18d3f #EDC881 #1e4581 - #444444 #000 #a2a23e #343434 #003 #004 #005 #006 #007}
{{24: Dark} "#F0E8E8" #E7E7E7 #272727 #323232 #FEEFA8 #707070 #000 #f4f49f grey #eda95b #000 #767676 - #454545 #000 #cdcd69 #2e2e2e #003 #004 #005 #006 #007}
{{25: Dark1} "#E0D9D9" #C4C4C4 #212121 #292929 #FEEFA8 #6c6c6c #000 #f4f49f #606060 #eda95b #000 #767676 - #363636 #000 #cdcd69 #292929 #003 #004 #005 #006 #007}
{{26: Dark2} "#bebebe" #bebebe #1f1f1f #262626 #FEEFA8 #6b6b6b #000 #f4f49f #616161 #eda95b #000 #767676 - #2b2b2b #000 #b0b04c #262626 #003 #004 #005 #006 #007}
{{27: Dark3} "#bebebe" #bebebe #0a0a0a #232323 #FEEFA8 #6a6a6a #000 #f4f49f #616161 #eda95b #000 #767676 - #1c1c1c #000 #bebe5a #131313 #003 #004 #005 #006 #007}
{{28: Oscuro} "#f1f1f1" #f1f1f1 #344545 #526d6d #FEEFA8 #728d8d #000 #f4f49f #afafaf #ffbb6d #000 #94afaf - #4f6666 #000 #cdcd69 #3d4e4e #003 #004 #005 #006 #007}
{{29: Oscuro1} "#f1f1f1" #f1f1f1 #2a3b3b #466161 #FEEFA8 #6c8787 #000 #f4f49f #a2a2a2 #ffbb6d #000 #8ba6a6 - #4a6161 #000 #cdcd69 #354646 #003 #004 #005 #006 #007}
{{30: Oscuro2} "#f1f1f1" #f1f1f1 #223333 #3e5959 #FEEFA8 #668181 #000 #f4f49f #a2a2a2 #ffbb6d #000 #819c9c - #3f5656 #000 #cdcd69 #2b3c3c #003 #004 #005 #006 #007}
{{31: Oscuro3} "#f1f1f1" #f1f1f1 #192a2a #355050 #FEEFA8 #5c7777 #000 #f4f49f #9e9e9e #ffbb6d #000 #779292 - #364d4d #000 #cdcd69 #223333 #003 #004 #005 #006 #007}
{{32: MildDark} "#d2d2d2" #fff #222323 #384e66 #FEEFA8 #79a1bf #000 #00ffff #939393 #ffbb6d #000 #668eac - #394d64 #000 #bebe5a #2b2c2c #003 #004 #005 #006 #007}
{{33: MildDark1} "#d2d2d2" #fff #151616 #2D435B #FEEFA8 #6f97b5 #000 #00ffff grey #ffbb6d #000 #668eac - #2e4259 #000 #bebe5a #1f2020 #003 #004 #005 #006 #007}
{{34: MildDark2} "#b4b4b4" #fff #0d0e0e #24384f #FEEFA8 #638ba9 #000 #00ffff #757575 #eda95b #000 #668eac - #253a52 #000 #bebe5a #161717 #003 #004 #005 #006 #007}
{{35: MildDark3} "#e2e2e2" #f1f1f1 #000 #1B3048 #FEEFA8 #5a82a0 #000 #00ffff #6c6c6c #eda95b #000 #668eac - #192e46 #000 #b0b04c #0f0f0f #003 #004 #005 #006 #007}
{{36: CoolGlow} "#e0e0e0" #e0e0e0 #06071d #1e2038 #FEEFA8 #5c6999 #000 #f4f49f #6e6e6e #ffbb6d #000 #7f8bbe - #2e3048 #000 #b0b04c #121329 #003 #004 #005 #006 #007}
{{37: Inkpot} "#d3d3ff" #AFC2FF #16161f #1E1E27 #FEEFA8 #6767a8 #000 #f4f49f #6e6e6e #ffbb6d #000 #8585c6 - #292936 #000 #a2a23e #202029 #003 #004 #005 #006 #007}
{{38: Quiverly} "#cdd8d8" #cdd8d8 #2b303b #333946 #FEEFA8 #6f7582 #000 #f4f49f #757575 #eda95b #000 #9197a4 - #414650 #000 #b0b04c #323742 #003 #004 #005 #006 #007}
{{39: Sleepy} "#fff" #fff #3c3c3c #5a5a5a #FEEFA8 #395472 #fff #f4f49f #969696 orange #fff #2d4866 - #4F4F4F #000 #cdcd69 #3b3b3b #003 #004 #005 #006 #007}
{{40: Monokai} "#f8f8f2" #f8f8f2 #353630 #4e5044 #FEEFA8 #707070 #000 #f4f49f #9a9a9a #ffbb6d #000 #777777 - #46473d #000 #cdcd69 #3c3d37 #003 #004 #005 #006 #007}
{{41: Desert} "#fff" #fff #47382d #5a4b40 #FEEFA8 #78695e #000 #f4f49f #a2a2a2 #ffbb6d #000 #7f7065 - #55463b #000 #eded89 #503f34 #003 #004 #005 #006 #007}
{{42: Magenta} "#E8E8E8" #F0E8E8 #381e44 #4A2A4A #FEEC9A #846484 #000 #f4f49f grey #ffbb6d #000 #ad8dad - #573757 #000 #cdcd69 #42284e #003 #004 #005 #006 #007}
{{43: Red} "#fff" #e9e9e6 #340202 #440702 #ffffb3 #b05e5e #000 #f4f49f #828282 #ffbb6d #000 #ba6868 - #3e0100 #000 #bebe5a #461414 #003 #004 #005 #006 #007}
{{44: Chocolate} "#d6d1ab" #d6d1ab #251919 #402020 #FEEFA8 #664D4D #fff #f4f49f #828282 #c3984a #fff #583f3f - #361d1d #000 #b0b04c #2d2121 #003 #004 #005 #006 #007}
{{45: Dusk} "#ececec" #ececec #1a1f21 #262b2d #FEEFA8 #6b7072 #000 #f4f49f #585d5f #ffbb6d #000 #6b7072 - #363b3d #000 #9e9e3a #23282a #003 #004 #005 #006 #007}
{{46: Nocturne} "#dfdfdf" #dddddd #131313 #1b1b1b #FEEFA8 #707070 #000 #f4f49f #6f6f6f #f5b163 #000 #828282 - #2d2d2d #000 #a2a23e #1b1b1b #003 #004 #005 #006 #007}
{{47: TKE Default} "#dbdbdb" #dbdbdb #000 #282828 #FEEFA8 #0a0acc #fff #f4f49f #6a6a6a #bd9244 #fff #0000d3 - #383838 #000 #b0b04c #0d0e0e #003 #004 #005 #006 #007}
}
  set ::apave::_CS_(initall) 1
  set ::apave::_CS_(initWM) 1
  set ::apave::_CS_(!FG) #000000
  set ::apave::_CS_(!BG) #c3c3c3
  set ::apave::_CS_(expo,tfg1) "-"
  set ::apave::_CS_(defFont) [font actual TkDefaultFont -family]
  set ::apave::_CS_(textFont) [font actual TkFixedFont -family]
  set ::apave::_CS_(fs) [font actual TkDefaultFont -size]
  set ::apave::_CS_(untouch) [list]
  set ::apave::_CS_(STDCS) [expr {[llength $::apave::_CS_(ALL)] - 1}]
  set ::apave::_CS_(NONCS) -2
  set ::apave::_CS_(MINCS) -1
  set ::apave::_CS_(old) $::apave::_CS_(NONCS)
  set ::apave::_CS_(TONED) [list -2 no]
  namespace eval ::tk { ; # just to get localized messages
    foreach m {&Abort &Cancel &Copy Cu&t &Delete E&xit &Filter &Ignore &No \
    OK Open P&aste &Quit &Retry &Save "Save As" &Yes Close "To clipboard" \
    Zoom Size} {
      set m2 [string map {"&" ""} $m]
      set ::apave::_MC_($m2) [string map {"&" ""} [msgcat::mc $m]]
    }
  }
}

# _______________________________________________________________________ #

proc ::iswindows {} {

  # Checks if the platform is MS Windows.
  return [expr {$::tcl_platform(platform) eq "windows"} ? 1: 0]
}

#########################################################################

proc ::apave::mc {msg} {
  # Gets a localized version of a message.
  #   msg - the message

  variable _MC_
  if {[info exists _MC_($msg)]} {return $_MC_($msg)}
  return $msg
}

#########################################################################

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

#########################################################################

proc ::apave::initStyles {args} {

  # Initializes miscellaneous styles, e.g. button's.
  #   args - options ("name value" pairs)

  ::apave::obj create_Fonts
  ttk::style configure TButtonWest {*}[ttk::style configure TButton]
  ttk::style configure TButtonWest -anchor w
  ttk::style map       TButtonWest {*}[ttk::style map TButton]
  ttk::style layout    TButtonWest [ttk::style layout TButton]

  ttk::style configure TButtonBold {*}[ttk::style configure TButton]
  ttk::style configure TButtonBold -font [font actual apaveFontDefBold]
  ttk::style map       TButtonBold {*}[ttk::style map TButton]
  ttk::style layout    TButtonBold [ttk::style layout TButton]

  ttk::style configure TButtonWestBold {*}[ttk::style configure TButton]
  ttk::style configure TButtonWestBold -anchor w -font [font actual apaveFontDefBold]
  ttk::style map       TButtonWestBold {*}[ttk::style map TButton]
  ttk::style layout    TButtonWestBold [ttk::style layout TButton]
}

#########################################################################

proc ::apave::initWM {args} {

  # Initializes Tcl/Tk session. Used to be called at the beginning of it.
  #   args - options ("name value" pairs)

  if {!$::apave::_CS_(initWM)} return
  lassign [::apave::parseOptions $args -cursorwidth $::apave::cursorwidth -theme "clam" \
    -buttonwidth -8 -buttonborder 1 -labelborder 0 -padding 1] \
    cursorwidth theme buttonwidth buttonborder labelborder padding
  set ::apave::_CS_(initWM) 0
  set ::apave::_CS_(CURSORWIDTH) $cursorwidth
  if {$::tcl_platform(platform) eq "windows"} {
    wm attributes . -alpha 0.0
  } else {
    wm withdraw .
  }
  # only most common settings, independent on themes (or no theme)
  ttk::style map "." \
    -selectforeground [list !focus $::apave::_CS_(!FG)] \
    -selectbackground [list !focus $::apave::_CS_(!BG)]
  # configure separate widget types
  try {ttk::style theme use $theme}
  ttk::style configure TButton -anchor center -width $buttonwidth \
    -relief raised -borderwidth $buttonborder -padding $padding
  ttk::style configure TMenubutton -width 0 -padding 0
  # TLabel's standard style saved for occasional uses
  ttk::style configure TLabelSTD {*}[ttk::style configure TLabel]
  ttk::style configure TLabelSTD -anchor w
  ttk::style map       TLabelSTD {*}[ttk::style map TLabel]
  ttk::style layout    TLabelSTD [ttk::style layout TLabel]
  # ... and TLabel new style
  ttk::style configure TLabel -borderwidth $labelborder -padding $padding
  initPOP .
  initStyles
  return
}

#########################################################################

proc ::apave::cs_Non {} {

  # Gets non-existent CS index

  return $::apave::_CS_(NONCS)
}

#########################################################################

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

###########################################################################

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

###########################################################################

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

###########################################################################

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

###########################################################################

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

###########################################################################

proc ::apave::getOption {optname args} {

  # Extracts one option from an option list.
  #   optname - option name
  #   args - option list
  # Returns an option value or "".
  # Example:
  #     set options [list -name some -value "any value" -tooltip "some tip"]
  #     set optvalue [::apave::getOption -tooltip {*}$options]

  set optvalue [lindex [::apave::parseOptions $args $optname ""] 0]
  return $optvalue
}

###########################################################################

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

#########################################################################

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

###########################################################################

proc ::apave::error {{fileName ""}} {
  # Gets the error's message at reading/writing.
  #   fileName - if set, return a full error messageat opening file

  variable _PU_opts
  if {$fileName eq ""} {
    return $_PU_opts(_ERROR_)
  }
  return "Error of access to\n\"$fileName\"\n\n$_PU_opts(_ERROR_)"
}

###########################################################################

proc ::apave::readTextFile {fileName {varName ""} {doErr 0}} {

  # Reads a text file.
  #   fileName - file name
  #   varName - variable name for file content or ""
  #   doErr - if 'true', exit at errors with error message
  #
  # Returns file contents or "".

  variable _PU_opts
  if {$varName ne ""} {upvar $varName fvar}
  if {[catch {set chan [open $fileName]} _PU_opts(_ERROR_)]} {
    if {$doErr} {error [::apave::error $fileName]}
    set fvar ""
  } else {
    chan configure $chan -encoding utf-8
    set fvar [read $chan]
    close $chan
  }
  return $fvar
}

###########################################################################

proc ::apave::writeTextFile {fileName {varName ""} {doErr 0}} {

  # Writes to a text file.
  #   fileName - file name
  #   varName - variable name for file content or ""
  #   doErr - if 'true', exit at errors with error message
  #
  # Returns "yes" if the file was saved successfully.

  variable _PU_opts
  if {$varName ne ""} {
    upvar $varName contents
  } else {
    set contents ""
  }
  if {[catch {set chan [open $fileName w]} _PU_opts(_ERROR_)]} {
    if {$doErr} {error [::apave::error $fileName]}
    set res no
  } else {
    chan configure $chan -encoding utf-8
    puts -nonewline $chan $contents
    close $chan
    set res yes
  }
  return $res
}

###########################################################################

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
  if {[catch {exec {*}$command $url &} error]} {
    puts "ERROR: couldn't execute '$command':\n$error"
  }
}

###########################################################################
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

    # Sets a property's value.
    #   name - name of property
    #   args - value of property
    #
    # If *args* is omitted, the method returns a property's value.
    #
    # If *args* is set, the method sets a property's value as $args.

    switch [llength $args] {
      0 {return [my getProperty $name]}
      1 {return [set _OP_Properties($name) $args]}
    }
    puts -nonewline stderr \
      "Wrong # args: should be \"[namespace current] setProperty propertyname ?value?\""
    return -code error
  }

  ###########################################################################

  method getProperty {name {defvalue ""}} {

    # Gets a property's value.
    #   name - name of property
    #   defvalue - default value
    #
    # If the property had been set, the method returns its value.
    #
    # Otherwise, the method returns the default value (`$defvalue`).

    if [info exists _OP_Properties($name)] {
      return $_OP_Properties($name)
    }
    return $defvalue
  }

}

###########################################################################
# Another bit - theming manager

oo::class create ::apave::ObjectTheming {

  mixin ::apave::ObjectProperty

  constructor {args} {
    my InitCS
    # ObjectTheming can play solo or be a mixin
    if {[llength [self next]]} { next {*}$args }
  }

  destructor {
    if {[llength [self next]]} next
  }

  ###########################################################################

  method InitCS {} {

    # Initializes the color scheme processing.

    if {$::apave::_CS_(initall)} {
      my basicFontSize 10 ;# initialize main font size
      my basicTextFont $::apave::_CS_(textFont) ;# initialize main font for text
      my ColorScheme  ;# initialize default colors
      set ::apave::_CS_(initall) 0
    }
    return
  }

  ###########################################################################

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
  }

  ###########################################################################

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

  ###########################################################################

  method ColorScheme {{ncolor ""}} {

    # Gets a full record of color scheme from a list of available ones
    #   ncolor - index of color scheme

    if {"$ncolor" eq "" || $ncolor<0} {
      # basic color scheme: get colors from a current ttk::style colors
      set fW black
      set bW #FBFB95
      set bg2 #d8d8d8
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
        set fS black
        set bS #9cb0c6
        lassign [::apave::parseOptions [ttk::style map . -background] \
          disabled #d9d9d9 active #ececec] bD bA
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

  method basicFontSize {{fs 0} {ds 0}} {

    # Gets/Sets a basic size of font used in apave
    #    fs - font size
    #    ds - incr/decr of size
    #
    # If 'fs' is omitted or ==0, this method gets it.
    # If 'fs' >0, this method sets it.

    if {$fs} {
      return [set ::apave::_CS_(fs) [expr {$fs + $ds}]]
    } else {
      return [expr {$::apave::_CS_(fs) + $ds}]
    }
  }

  ###########################################################################

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

  ###########################################################################

  method boldDefFont {{fs 0}} {

    # Returns a bold default font.
    #    fs - font size

    if {$fs == 0} {set fs [my basicFontSize]}
    set bf [font actual basicDefFont]
    return [dict replace $bf -family [my basicDefFont] -weight bold -size $fs]
  }

  ###########################################################################

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

  ###########################################################################

  method boldTextFont {{fs 0}} {

    # Returns a bold fixed font.
    #    fs - font size

    if {$fs == 0} {set fs [expr {2+[my basicFontSize]}]}
    set bf [font actual TkFixedFont]
    return [dict replace $bf -family [my basicTextFont] -weight bold -size $fs]
  }

  ###########################################################################

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

  ###########################################################################

  method csDarkEdit {{cs -3}} {

    # Returns a flag "the editor of CS is dark"
    #   cs - color scheme to be checked (the current one, if not set)

    if {$cs eq -3} {set cs [my csCurrent]}
    lassign $::apave::_CS_(TONED) csbasic cstoned
    if {$cs==$cstoned} {set cs $csbasic}
    return [expr {$cs>22}]
  }

  ###########################################################################

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

  ###########################################################################

  method csCurrent {} {

    # Gets an index of current color scheme

    return $::apave::_CS_(index)
  }

  ###########################################################################

  method csGetName {{ncolor 0}} {

    # Gets a color scheme's name
    #   ncolor - index of color scheme

    if {$ncolor < $::apave::_CS_(MINCS)} {
      return "Default"
    } elseif {$ncolor == $::apave::_CS_(MINCS)} {
      return "-1: Basic"
    }
    return [lindex [my ColorScheme $ncolor] 0]
  }

  ###########################################################################

  method csGet {{ncolor ""}} {

    # Gets a color scheme's colors
    #   ncolor - index of color scheme

    if {$ncolor eq ""} {set ncolor [my csCurrent]}
    return [lrange [my ColorScheme $ncolor] 1 end]
  }

  ###########################################################################

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

    if {$ncolor eq ""} {
      lassign $args \
        clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk tfgI tbgI fM bM tfgW tbgW tHL2 res3 res4 res5 res6 res7
    } else {
      foreach cs [list $ncolor $::apave::_CS_(MINCS)] {
        lassign [my csGet $cs] \
          clrtitf clrinaf clrtitb clrinab clrhelp clractb clractf clrcurs clrgrey clrhotk tfgI tbgI fM bM tfgW tbgW tHL2 res3 res4 res5 res6 res7
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
      my themeWindow $win [list $fg $bg $fE $bE $fS $bS $grey $bg $cc $ht $hh $tfgI $tbgI $fM $bM $tfgW $tbgW $tHL2 $res3 $res4 $res5 $res6 $res7]
      my UpdateColors
      my initTooltip
    }
    return [list $fg $bg $fE $bE $fS $bS $hh $grey $cc $ht $tfgI $tbgI $fM $bM $tfgW $tbgW $tHL2 $res3 $res4 $res5 $res6 $res7]
  }

  ###########################################################################

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

  ###########################################################################

  method csDeleteExternal {} {
    # Removes all external CS.

    set ::apave::_CS_(ALL) [lreplace $::apave::_CS_(ALL) 48 end]

  }

  ###########################################################################

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
        scan $color "#%2x%2x%2x" R G B
        foreach valname {R G B} {
          set val [expr {int([set $valname]*$hue)}]
          set $valname [expr {max(min($val,255),0)}]
        }
        set color [format "#%02x%02x%02x" $R $G $B]
      }
      lappend TWargs $color
    }
    my themeWindow . $TWargs no
    set ::apave::_CS_(TONED) [list $cs [my csCurrent]]
    return yes

  }

# _______________________________________________________________________ #

  method Ttk_style {oper ts opt val} {

    # Sets a new style options.
    #   oper - command of ttk::style ("map" or "configure")
    #   ts - type of style to be configurated
    #   opt - option's name
    #   val - option's value

    if {![catch {set oldval [ttk::style $oper $ts $opt]}]} {
      catch {ttk::style $oper $ts $opt $val}
      if {$oldval eq "" && $oper eq "configure"} {
        switch -- $opt {
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

  ###########################################################################

  method csMainColors {} {
    # Returns a list of main colors' indices of CS.
    # See also: csMapTheme

    return [list 0 1 2 3 5 13 16]
  }

  ###########################################################################

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

  ###########################################################################

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

    lassign $clrs tfg1 tbg1 tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr \
      thlp tfgI tbgI tfgM tbgM twfg twbg tHL2 res3 res4 res5 res6 res7
    if {$tfg1 eq "-"} return
    if {!$isCS} {
      # if 'external  scheme' is used, register it in _CS_(ALL)
      # and set it as the current CS

# <CS>    itemfg  mainfg  itembg  mainbg  itemsHL  actbg   actfg  cursor  greyed   hot \
  emfg  embg   -  menubg  winfg   winbg   itemHL2 #003...reserved...

      my csAdd [list CS-[expr {[::apave::cs_Max]+1}] $tfg2 $tfg1 $tbg2 $tbg1 \
        $thlp $tbgS $tfgS $tcur $tfgD $bclr $tfgI $tbgI $tfgM $tbgM \
        $twfg $twbg $tHL2 $res3 $res4 $res5 $res6 $res7]
    }
    if {$tfgI eq ""} {set tfgI $tfg2}
    if {$tbgI eq ""} {set tbgI $tbg2}
    if {$tfgM in {"" -}} {set tfgM $tfg1}
    if {$tbgM eq ""} {set tbgM $tbg1}
    my Main_Style $tfg1 $tbg1 $tfg2 $tbg2 $tfgS $tbgS $tfgD $tbg1 $tfg1 $tbg2 $tbg1
    foreach arg {tfg1 tbg1 tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr \
    thlp tfgI tbgI tfgM tbgM twfg twbg tHL2 res3 res4 res5 res6 res7 args} {
      if {$win eq "."} {
        set ::apave::_C_($win,$arg) [set $arg]
      }
      set ::apave::_CS_(expo,$arg) [set $arg]
    }
    # configuring themed widgets
    foreach ts {TLabel TLabelframe.Label TButton TCheckbutton \
    TProgressbar TRadiobutton TNotebook.Tab} {
      my Ttk_style configure $ts -font apaveFontDef
      my Ttk_style configure $ts -foreground $tfg1
      my Ttk_style configure $ts -background $tbg1
      my Ttk_style map $ts -background [list pressed $tbg1 active $tbg2 alternate $tbg2 focus $tbg2 selected $tbg2]
      my Ttk_style map $ts -foreground [list disabled $tfgD pressed $tfg1 active $tfg2 alternate $tfg2 focus $tfg2 selected $tfg2]
      my Ttk_style map $ts -bordercolor [list focus $bclr pressed $bclr]
      my Ttk_style map $ts -lightcolor [list focus $bclr]
      my Ttk_style map $ts -darkcolor [list focus $bclr]
      my Ttk_style configure $ts -fieldforeground $tfg2
      my Ttk_style configure $ts -fieldbackground $tbg2
    }
    foreach ts {TNotebook TFrame} {
      my Ttk_style configure $ts -background $tbg1
    }
    foreach ts {TNotebook.Tab} {
      my Ttk_style configure $ts -font apaveFontDef
      my Ttk_style map $ts -foreground [list selected $tfgS active $tfg2]
      my Ttk_style map $ts -background [list selected $tbgS active $tbg2]
    }
    foreach ts {TEntry Treeview TSpinbox TCombobox TCombobox.Spinbox TMatchbox TNotebook.Tab TScrollbar TScale} {
      my Ttk_style map $ts -lightcolor [list focus $bclr active $bclr]
      my Ttk_style map $ts -darkcolor [list focus $bclr active $bclr]
    }
    foreach ts {TEntry Treeview TSpinbox TCombobox TCombobox.Spinbox TMatchbox} {
      my Ttk_style configure $ts -font apaveFontDef
      my Ttk_style configure $ts -selectforeground $tfgS
      my Ttk_style configure $ts -selectbackground $tbgS
      my Ttk_style map $ts -selectforeground [list !focus $::apave::_CS_(!FG)]
      my Ttk_style map $ts -selectbackground [list !focus $::apave::_CS_(!BG)]
      my Ttk_style configure $ts -fieldforeground $tfg2
      my Ttk_style configure $ts -fieldbackground $tbg2
      my Ttk_style configure $ts -insertcolor $tcur
      my Ttk_style map $ts -bordercolor [list focus $bclr active $bclr]
      my Ttk_style configure $ts -insertwidth $::apave::_CS_(CURSORWIDTH)
      if {$ts eq "TCombobox"} {
        # combobox is sort of individual
        my Ttk_style configure $ts -foreground $tfg1
        my Ttk_style configure $ts -background $tbg1
        my Ttk_style map $ts -foreground [list {readonly focus} $tfg1 active $tfg1]
        my Ttk_style map $ts -background [list {readonly focus} $tbg1 active $tbg1]
        my Ttk_style map $ts -fieldbackground [list readonly $tbg1]
        my Ttk_style map $ts -background [list active $tbg2]
      } else {
        my Ttk_style configure $ts -foreground $tfg2
        my Ttk_style configure $ts -background $tbg2
        my Ttk_style map $ts -foreground [list disabled $tfgD readonly $tfgD selected $tfgS]
        my Ttk_style map $ts -background [list disabled $tbgD readonly $tbgD selected $tbgS]
      }
    }
    option add *Listbox.font apaveFontDef
    option add *Menu.font apaveFontDef
    my Ttk_style configure TMenubutton -foreground $tfgM
    my Ttk_style configure TMenubutton -background $tbgM
    foreach {nam clr} {back tbg1 fore tfg1 selectBack tbgS selectFore tfgS} {
      option add *Listbox.${nam}ground [set $clr]
    }
    foreach {nam clr} {back tbgM fore tfgM selectBack tbgS selectFore tfgS} {
      option add *Menu.${nam}ground [set $clr]
    }
    foreach ts {TRadiobutton TCheckbutton} {
      ttk::style map $ts -background [list focus $tbg2 !focus $tbg1]
    }
    # non-themed widgets of button and entry types
    foreach ts [my NonThemedWidgets button] {
      set ::apave::_C_($ts,0) 6
      set ::apave::_C_($ts,1) "-background $tbg1"
      set ::apave::_C_($ts,2) "-foreground $tfg1"
      set ::apave::_C_($ts,3) "-activeforeground $tfg2"
      set ::apave::_C_($ts,4) "-activebackground $tbg2"
      set ::apave::_C_($ts,5) "-font apaveFontDef"
      set ::apave::_C_($ts,6) "-highlightbackground $tfgD"
      switch -- $ts {
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
          set ::apave::_C_($ts,0) 8
          set ::apave::_C_($ts,1) "-background $tbgM"
          set ::apave::_C_($ts,3) "-activeforeground $tfgS"
          set ::apave::_C_($ts,4) "-activebackground $tbgS"
          set ::apave::_C_($ts,5) "-borderwidth 2"
          set ::apave::_C_($ts,7) "-relief raised"
          set ::apave::_C_($ts,8) "-disabledforeground $tfgD"
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
      switch -- $ts {
        tcombobox - tmatchbox {
          set ::apave::_C_($ts,0) 8
          set ::apave::_C_($ts,4) "-disabledforeground $tfgD"
          set ::apave::_C_($ts,5) "-disabledbackground $tbgD"
          set ::apave::_C_($ts,6) "-highlightcolor $bclr"
          set ::apave::_C_($ts,7) "-font apaveFontDef"
          set ::apave::_C_($ts,8) "-insertbackground $tcur"
        }
        text - entry - tentry {
          set ::apave::_C_($ts,0) 11
          set ::apave::_C_($ts,4) "-selectforeground $tfgS"
          set ::apave::_C_($ts,5) "-selectbackground $tbgS"
          set ::apave::_C_($ts,6) "-disabledforeground $tfgD"
          set ::apave::_C_($ts,7) "-disabledbackground $tbgD"
          set ::apave::_C_($ts,8) "-highlightcolor $bclr"
          if {$ts eq "text"} {
            set ::apave::_C_($ts,9) "-font {[font actual apaveFontMono]}"
          } else {
            set ::apave::_C_($ts,9) "-font {[font actual apaveFontDef]}"
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
          set ::apave::_C_($ts,10) "-font apaveFontDef"
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
    catch {::bartabs::drawAll}
    return
  }

  ###########################################################################

  method UpdateSelectAttrs {w} {

    # Updates attributes for selection.
    #   w - window's name
    # Some widgets (e.g. listbox) need a work-around to set
    # attributes for selection in run-time, namely at focusing in/out.

    if { [string first "-selectforeground" [bind $w "<FocusIn>"]] < 0} {
      set com "lassign \[::apave::parseOptions \[ttk::style configure .\] \
        -selectforeground $::apave::_CS_(!FG) \
        -selectbackground $::apave::_CS_(!BG)\] fS bS;"
      bind $w <FocusIn> "+ $com $w configure \
        -selectforeground \$fS -selectbackground \$bS"
      bind $w <FocusOut> "+ $w configure -selectforeground \
        $::apave::_CS_(!FG) -selectbackground $::apave::_CS_(!BG)"
    }
    return
  }

  ###########################################################################

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

  ###########################################################################

  method themeNonThemed {win} {

    # Updates the appearances of currently used widgets (non-themed).
    #   win - window path whose children will be touched
    #
    # See also:
    #   untouchWidgets

    set wtypes [my NonThemedWidgets all]
    foreach w1 [winfo children $win] {
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
              switch -- [$w1 cget -state] {
                "disabled" {
                  $w1 configure {*}[my NonTtkStyle $w1 1]
                }
                "readonly" {
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

  ###########################################################################

  method NonThemedWidgets {selector} {

    # Lists the non-themed widgets to process in apave.
    #   selector - sets a widget group to return as a list
    # The `selector` can be `entry`, `button` or `all`.

    switch -- $selector {
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

  ###########################################################################

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

  ###########################################################################

  method NonTtkStyle {typ {dsbl 0}} {

    # Makes styling for non-ttk widgets.
    #   typ - widget's type (the same as in "APave::widgetType" method)
    #   dsbl - `1` for disabled; `2` for readonly; otherwise for all widgets
    # See also: APave::widgetType

    if {$dsbl} {
      set disopt ""
      if {$dsbl==1 && [info exist ::apave::_C_(disabled,0)]} {
        set typ [string range [lindex [split $typ .] end] 0 2]
        switch -- $typ {
          frA - lfR {
            append disopt " " $::apave::_C_(disabled,2)
          }
          enT - spX {
            append disopt " " $::apave::_C_(disabled,1) \
                          " " $::apave::_C_(disabled,2) \
                          " " $::apave::_C_(disabled,3) \
                          " " $::apave::_C_(disabled,4)
          }
          laB - tex - chB - raD - lbx - scA {
            append disopt " " $::apave::_C_(disabled,1) \
                          " " $::apave::_C_(disabled,2)
          }
        }
      } elseif {$dsbl==2 && [info exist ::apave::_C_(readonly,0)]} {
        append disopt " " \
          $::apave::_C_(readonly,1) " " $::apave::_C_(readonly,2) \
      }
      return $disopt
    }
    set opts {-foreground -foreground -background -background}
    lassign "" ts2 ts3 opts2 opts3
    switch -- $typ {
      "buT" {set ts TButton}
      "chB" {set ts TCheckbutton
        lappend opts -background -selectcolor
      }
      "enT" {
        set ts TEntry
        set opts  {-foreground -foreground -fieldbackground -background \
          -insertbackground -insertcolor}
      }
      "tex" {
        set ts TEntry
        set opts {-foreground -foreground -fieldbackground -background \
          -insertcolor -insertbackground \
          -selectforeground -selectforeground -selectbackground -selectbackground
        }
      }
      "frA" {set ts TFrame; set opts {-background -background}}
      "laB" {set ts TLabel}
      "lbx" {set ts TLabel}
      "lfR" {set ts TLabelframe}
      "raD" {set ts TRadiobutton}
      "scA" {set ts TScale}
      "sbH" -
      "sbV" {set ts TScrollbar; set opts {-background -background}}
      "spX" {set ts TSpinbox}
      default {
        return ""
      }
    }
    set att ""
    for {set i 1} {$i<=3} {incr i} {
      if {$i>1} {
        set ts [set ts$i]
        set opts [set opts$i]
      }
      foreach {opt1 opt2} $opts {
        if {[catch {set val [ttk::style configure $ts $opt1]}]} {
          return $att
        }
        if {$val eq ""} {
          catch { set val [ttk::style $oper . $opt2] }
        }
        if {$val ne ""} {
          append att " $opt2 $val"
        }
      }
    }
    return $att
  }

# _______________________________________________________________________ #

  method ThemePopup {mnu args} {

    # Recursively configures popup menus.
    #   mnu - menu's name (path)
    #   args - options of configuration
    # See also: themePopup

    if {[set last [$mnu index end]] ne "none"} {
      $mnu configure {*}$args
      for {set i 0} {$i <= $last} {incr i} {
        switch -- [$mnu type $i] {
          "cascade" {
            my ThemePopup [$mnu entrycget $i -menu] {*}$args
          }
          "command" {
            $mnu entryconfigure $i {*}$args
          }
        }
      }
    }
  }

  ###########################################################################

  method themePopup {mnu} {

    # Configures a popup menu so that its colors accord with a current CS.
    #   mnu - menu's name (path)

    if {[my csCurrent] == $::apave::_CS_(NONCS)} return
    lassign [my csGet] - fg - bg2 - bgS fgS - tfgD - - - - bg
    if {$bg eq ""} {set bg $bg2}
    set opts "-foreground $fg -background $bg -activeforeground $fgS \
      -activebackground $bgS -font {[font actual apaveFontDef]}"
    if {[catch {my ThemePopup $mnu {*}$opts -disabledforeground $tfgD}]} {
      my ThemePopup $mnu {*}$opts
    }
  }

  ###########################################################################

  method initTooltip {args} {

    # Configurates colors and other attributes of tooltip.
    #  args - options of ::baltip::configure

    if {[info commands ::baltip::configure] eq ""} {package require baltip}
    lassign [lrange [my csGet] 14 15] fW bW
    ::baltip config -fg $fW -bg $bW -global yes
    ::baltip config {*}$args
    return
  }

  ###########################################################################

  method ThemeChoosers {} {

    # Configures file/dir choosers so that its colors accord with a current CS.

    if {[info commands ::apave::_TK_TOPLEVEL] ne ""} return
    rename ::toplevel ::apave::_TK_TOPLEVEL
    proc ::toplevel {args} {
      set res [eval ::apave::_TK_TOPLEVEL $args]
      set w [lindex $args 0]
      rename $w ::apave::_W_TOPLEVEL$w
      proc ::$w {args} "
        set cs \[::apave::obj csCurrent\]
        if {{configure -menu} eq \$args} {set args {configure}}
        if {\$cs>-2 && \[string first {configure} \$args\]==0} {
          lappend args -background \[lindex \[::apave::obj csGet\] 3\]
        }
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
        proc ::$w {args} "
          set cs \[::apave::obj csCurrent\]
          lassign \[::apave::obj csGet \$cs\] fg - bg
          if {\$cs>-2} {
            if {\[string first {create text} \$args\]==0 ||
            \[string first {itemconfigure} \$args\]==0 &&
            \[string first {-fill black} \$args\]>0} {
              dict set args -fill \$fg
              dict set args -font apaveFontDef
            }
          }
          return \[eval ::apave::_W_CANVAS$w \$args\]
        "
      }
      return $res
    }
  }

  ###########################################################################

  method themeExternal {args} {
    # Configures an external dialogue so that its colors accord with a current CS.
    #   args - list of untouched widgets

    if {[set cs [my csCurrent]] != -2} {
      foreach untw $args {my untouchWidgets $untw}
      after idle [list [self] csSet $cs . -doit]  ;# theme the dialogue to be run
    }
  }
}
################################# EOF #####################################

#%   DOCTEST   SOURCE   tests/obbit_1.test
#-RUNF1: ./tests/test2_pave.tcl
#RUNF1: ./tests/test2_pave.tcl 9 10 12 "small icons"
