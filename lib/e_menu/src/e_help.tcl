#! /usr/bin/env tclsh
#
# Calling help pages of Tcl/Tk from www.tcl.tk
#
# Use:
#   tclsh e_help.tcl package
# brings up www.tcl.tk/man/tcl8.6/TclCmd/package.htm
#
# You might create an offline version of Tcl/Tk help, and make it
# callable from this script.
#
# Local help is downloaded with wget:
# wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/
# _______________________________________________________________________ #

package require Tk

# for better performance, try to 'source' directly, not 'package require apave'
if {![namespace exists ::apave]} {source [file join [file normalize [file dirname [info script]]] apaveinput.tcl]}

namespace eval ::eh {

  # preferable browser: can be set by b= parameter
  variable my_browser ""

  # offline help directory
  variable hroot "$::env(HOME)/DOC/www.tcl.tk/man/tcl8.6"

  variable formtime %H:%M:%S            ;# time format
  variable formdate %Y-%m-%d            ;# date format
  variable formdt   %Y-%m-%d_%H:%M:%S   ;# date+time format
  variable formdw   %A                  ;# day of week format
  variable mx 0 my 0

  variable reginit 1
  variable solo [expr {[info exist ::argv0] && [file normalize $::argv0] eq \
    [file normalize [info script]]} ? 1 : 0]
}
#=== own message/question box
proc ::eh::dialog_box {ttl mes {typ ok} {icon info} {defb OK} args} {
  set opts [list -t 1 -w 80]
  lappend opts {*}$args
  switch -glob -- $typ {
    okcancel - yesno - yesnocancel {
      if {$defb eq {OK} && $typ ne {okcancel} } {
        set defb YES
      }
      set ans [::apave::obj $typ $icon $ttl \n$mes\n $defb {*}$opts]
    }
    default {
      set ans [::apave::obj ok $icon $ttl \n$mes\n {*}$opts]
    }
  }
  return $ans
}
#=== get terminal's name
proc ::eh::get_tty {inconsole} {
  if {[::iswindows]} {set tty "cmd.exe /K"} \
  elseif {$inconsole ne {}} {set tty $inconsole} \
  elseif {[auto_execok lxterminal] ne {}} {set tty lxterminal} \
  else {set tty xterm}
  return $tty
}
#=== get system time & date
proc ::eh::get_timedate {} {
  set systime [clock seconds]
  set curtime [clock format $systime -format $::eh::formtime]
  set curdate [clock format $systime -format $::eh::formdate]
  set curdt   [clock format $systime -format $::eh::formdt]
  set curdw   [clock format $systime -format $::eh::formdw]
  return [list $curtime $curdate $curdt $curdw $systime]
}
#=== get current language, e.g. ru_RU.utf8
proc ::eh::get_language {} {
  if {[catch {set lang "[lindex [split $::env(LANG) .] 0].utf8"}]} {
    return ""
  }
  return $lang
}
#=== maximize 'win' window
proc ::eh::zoom_window {win} {
  if {[::iswindows]} {
    wm state $win zoomed
  } else {
    wm attributes $win -zoomed 1
  }
}
#=== center window on screen
proc ::eh::center_window {win {ornament 1} {winwidth 0} {winheight 0}} {
  # to center a window regarding taskbar(s) sizes
  #  center_window win     ;# if win window has borders and titlebar
  #  center_window win 0   ;# if win window isn't ornamented with those
  if {$ornament == 0} {
    lassign {0 0} left top
    set usewidth [winfo screenwidth .]   ;# it's straightforward
    set useheight [winfo screenheight .]
  } else {
    set tw ${win}_temp_               ;# temp window path
    catch {destroy $tw}               ;# clear out
    toplevel $tw                      ;# make a toplevel window
    wm attributes $tw -alpha 0.0      ;# make it be not visible
    zoom_window $tw                   ;# maximize the temp window
    update
    set usewidth [winfo width $tw]    ;# the window width and height define
    set useheight [winfo height $tw]  ;# a useful area for all other windows
    set twgeom [split "[wm geometry $tw]" +]
    set left [lindex $twgeom 1]       ;# all ornamented windows are shifted
    set top [lindex $twgeom 2]        ;# from left and top by these values
    destroy $tw
  }
  wm deiconify $win
  if {$winwidth > 0 && $winheight > 0} {
    wm geometry $win ${winwidth}x${winheight}  ;# geometry to set
  } else {
    set winwidth [eval winfo width $win]       ;# geometry is already set
    set winheight [eval winfo height $win]
  }
  set x [expr $left + ($usewidth - $winwidth) / 2]
  set y [expr $top + ($useheight - $winheight) / 2]
  wm geometry $win +$x+$y
  wm state . normal
  update
}
#=== check and correct (if necessary) the geometry of window
proc ::eh::checkgeometry {{win .}} {
  lassign [split [winfo geometry $win] x+] w h x y
  set newgeo [::apave::obj checkXY $w $h $x $y]
  if {$newgeo ne "+$x+$y"} {wm geometry $win $newgeo}
}
#=== off ctrl/alt modificators of keystrokes
proc ::eh::ctrl_alt_off {cmd} {
  if {[::iswindows]} {
    return "if \{%s == 8\} \{$cmd\}"
  } else {
    return "if \{\[expr %s&14\] == 0\} \{$cmd\}"
  }
}
#=== try and check if 'app' destroyed
proc ::eh::destroyed {app} {
  return [expr ![catch {send -async $app {destroy .}} e]]
}
#=== drag window by snatching header
proc ::eh::mouse_drag {win mode x y} {
  switch -exact -- $mode {
    1 { lassign [list $x $y] ::eh::mx ::eh::my }
    2 -
    3 {
      if {$::eh::mx>0 && $::eh::my>0} {
        lassign [split [wm geometry $win] x+] w h wx wy
        wm geometry $win +[expr $wx+$x-$::eh::mx]+[expr $wy+$y-$::eh::my]
        if {$mode==3} {lassign {0 0} ::eh::mx ::eh::my }
      }
    }
  }
}
#=== Gets/sets file attributes
proc ::eh::fileAttributes {fname {attrs "-"} {atime ""} {mtime ""} } {
    if {$attrs eq {-}} {
      # get file attributes
      set attrs [file attributes $fname]
      return [list $attrs [file atime $fname] [file mtime $fname]]
    }
   # set file attributes
   catch {
     file atime $fname $atime
     file mtime $fname $mtime
   }
}
#=== Write data to a file with file attributes untouched
proc ::eh::write_file_untouched {fname data} {
  lassign [::eh::fileAttributes $fname] f_attrs f_atime f_mtime
  set ch [open $fname w]
  chan configure $ch -encoding utf-8
  foreach line $data { puts $ch $line }
  close $ch
  ::eh::fileAttributes $fname $f_attrs $f_atime $f_mtime
}
#=== escape double quotes
proc ::eh::escape_quotes {sel} {
  if {![::iswindows]} {
    set sel [string map [list "\"" "\\\""] $sel]
  }
  return $sel
}
#=== escape special characters
proc ::eh::escape_specials {sel} {
  return [string map [ list \" \\\" "\n" "\\n" "\\" "\\\\" "\$" "\\\$" \
    "\}" "\\\}"  "\{" "\\\{"  "\]" "\\\]"  "\[" "\\\[" ] $sel]
}
#=== prepare "search links" for browser
proc ::eh::escape_links {sel} {
  return [string map [list " " "+"] $sel]
}
#=== delete specials & underscore spaces
proc ::eh::delete_specsyms {sel {und "_"} } {
  return [string map [list \
      "\"" ""  "\%" ""  "\$" ""  "\}" ""  "\{" "" \
      "\]" ""  "\[" ""  "\>" ""  "\<" ""  "\*" ""  " " $und] $sel]
}
#=== get "underlined" name (e.g. working dir)
proc ::eh::get_underlined_name {name} {
  return [string map {/ _ \\ _ { } _ . _} $name]
}
#=== check if link exists
proc ::eh::lexists {url} {
  if {$::eh::reginit} {
    set ::eh::reginit 0
    package require http
    package require tls
    ::http::register https 443 ::tls::socket
  }
  if {[catch {set token [::http::geturl $url]} e]} {
    tk_messageBox -message "ERROR: couldn't connect to:\n\n$url\n\n$e"
    return 0
  }
  if {$::eh::solo} { exit }
  if {[string first "<title>URL Not Found" [::http::data $token]] < 0} {
    return 1
  } else {
    return 0
  }
}
#=== check if links exist
proc ::eh::links_exist {h1 h2 h3} {
  if {[lexists $h1]} {
    return $h1            ;# Tcl commands help
  } elseif {[lexists $h2]} {
    return $h2            ;# Tk commands help
  } elseif {[lexists $h3]} {
    return $h3            ;# Tcl/Tk keywords help (by first letter)
  } else {
    return {}
  }
}
#=== offline help
proc ::eh::local { {help ""} } {
  set l1 [string toupper [string range $help 0 0]]
  if {[string first http $::eh::hroot]==0} {
    set http true
    set ext htm
  } else {
    set http false
    set ext htm  ;# this extention was returned by wget, change if need
  }
  set help [string tolower $help]
  set h1 ${::eh::hroot}/TclCmd/$help.$ext
  set h2 ${::eh::hroot}/TkCmd/$help.$ext
  set h3 ${::eh::hroot}/Keywords/$l1.$ext
  if {$http} {
    set link [links_exist $h1 $h2 $h3]
    if {[string length $link] > 0} {
      return $link             ;# try local help pages
    }
  } else {
    set h0 ${::eh::hroot}/TclCmd/contents.$ext ;# Tcl index, if nothing found
    if {![file exists $h0]} {
      append h0 l ;# html
      append h1 l
      append h2 l
      append h3 l
    }
    if {[file exists $h1]} {
      return file://$h1        ;# view Tcl commands help
    } elseif {[file exists $h2]} {
      return file://$h2        ;# view Tk commands help
    } elseif {[file exists $h3]} {
      return file://$h3        ;# view Keywords help (by first letter)
    }
    set h1 $h0
  }
  return $h1
}
#=== online help, change links if need
proc ::eh::html { {help ""} {local 0}} {
  if {$help eq {}} {set help contents}
  if {$local} {
    return [local $help]
  }
  set l1 [string toupper [string range $help 0 0]]
  set h1 https://www.tcl.tk/man/tcl8.6/TclCmd/$help.htm   ;# Tcl
  set h2 https://www.tcl.tk/man/tcl8.6/TkCmd/$help.htm    ;# Tk
  set h3 https://www.tcl.tk/man/tcl8.6/Keywords/$l1.htm   ;# keywords A-Z
  set link [links_exist $h1 $h2 $h3]
  if {[string length $link] == 0} {
    return [local $help]       ;# try local help pages
  }
  return $link
}
#=== call browser
proc ::eh::browse { {help ""} } {
  if {$::eh::my_browser ne {}} {
    # my_browser may contain options, e.g. "chromium --no-sandbox" for root
    exec {*}$::eh::my_browser $help &
  } else {
    ::apave::openDoc $help
  }
}
# _______________________________________________________________________ #

if {$::eh::solo} {
  if {$argc > 0} {
    if {[lindex $::argv 0] eq {-local}} {
      set page [::eh::local [lindex $::argv 1]]
    } else {
      set page [::eh::html [lindex $::argv 0]]
    }
    ::eh::browse $page
  } else {
    puts "
Run:

  tclsh e_help.tcl \[-local\] page

to get Tcl/Tk help page:

  TclCmd/page.htm or
  TkCmd/page.htm or
  Keywords/P.htm
"}
  exit
}
# ________________________________  EOF _________________________________ #
