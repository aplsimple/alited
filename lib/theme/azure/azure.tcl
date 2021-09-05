# Copyright © 2021 rdbende <rdbende@gmail.com>

set ::AZUREDIR [file normalize [file dirname [info script]]]
option add *tearOff 0

proc set_theme {mode} {
  if {$mode == "dark"} {

    source [file join $::AZUREDIR theme dark.tcl]
    unset ::AZUREDIR  ;# no retheming supposed

    ttk::style theme use "azure-dark"
  
    array set colors {
      -fg             "#ffffff"
      -bg             "#333333"
      -disabledfg     "#ffffff"
      -disabledbg     "#737373"
      -selectfg       "#ffffff"
      -selectbg       "#007fff"
    }
  
    ttk::style configure . \
      -background $colors(-bg) \
      -foreground $colors(-fg) \
      -troughcolor $colors(-bg) \
      -focuscolor $colors(-selectbg) \
      -selectbackground $colors(-selectbg) \
      -selectforeground $colors(-selectfg) \
      -insertcolor $colors(-fg) \
      -insertwidth 1 \
      -fieldbackground $colors(-selectbg) \
      -font {"Segoe Ui" 10} \
      -borderwidth 1 \
      -relief flat
  
    tk_setPalette background [ttk::style lookup . -background] \
      foreground [ttk::style lookup . -foreground] \
      highlightColor [ttk::style lookup . -focuscolor] \
      selectBackground [ttk::style lookup . -selectbackground] \
      selectForeground [ttk::style lookup . -selectforeground] \
      activeBackground [ttk::style lookup . -selectbackground] \
      activeForeground [ttk::style lookup . -selectforeground]
  
    ttk::style map . -foreground [list disabled $colors(-disabledfg)]
  
    option add *font [ttk::style lookup . -font]
    option add *Menu.selectcolor $colors(-fg)
    option add *Menu.background #444444
  
  } elseif {$mode == "light"} {

    source [file join $::AZUREDIR theme light.tcl]
    unset ::AZUREDIR  ;# no retheming supposed

    ttk::style theme use "azure-light"
  
    array set colors {
      -fg             "#000000"
      -bg             "#ffffff"
      -disabledfg     "#737373"
      -disabledbg     "#ffffff"
      -selectfg       "#ffffff"
      -selectbg       "#007fff"
    }
  
    ttk::style configure . \
      -background $colors(-bg) \
      -foreground $colors(-fg) \
      -troughcolor $colors(-bg) \
      -focuscolor $colors(-selectbg) \
      -selectbackground $colors(-selectbg) \
      -selectforeground $colors(-selectfg) \
      -insertcolor $colors(-fg) \
      -insertwidth 1 \
      -fieldbackground $colors(-selectbg) \
      -font {"Segoe Ui" 10} \
      -borderwidth 1 \
      -relief flat
  
    tk_setPalette background [ttk::style lookup . -background] \
      foreground [ttk::style lookup . -foreground] \
      highlightColor [ttk::style lookup . -focuscolor] \
      selectBackground [ttk::style lookup . -selectbackground] \
      selectForeground [ttk::style lookup . -selectforeground] \
      activeBackground [ttk::style lookup . -selectbackground] \
      activeForeground [ttk::style lookup . -selectforeground]
  
    ttk::style map . -foreground [list disabled $colors(-disabledfg)]
  
    option add *font [ttk::style lookup . -font]
    option add *Menu.selectcolor $colors(-fg)
    option add *Menu.background #e1e1df
  }
}
#RUNF1: ../../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
