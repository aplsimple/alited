#! /usr/bin/env tclsh
###########################################################
# Name:    hl_trans.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Sep 18, 2023
# Brief:   Handles language translations.
# License: MIT.
###########################################################

package require htmlparse
package require http
package require json
package require tls

# ________________________ Configuring _________________________ #

http::register https 443 ::tls::socket
http::config -accept text/*

# _________________________ hl_trans ________________________ #
#
# Uses some links from https://github.com/LibreTranslate/LibreTranslate
#   https://libretranslate.de/translate
#   https://translate.argosopentech.com/translate
#   https://translate.terraprint.co/translate
#
# instead of
#   https://translation.googleapis.com/language/translate/v2?key=MY_KEY
#   https://libretranslate.com/translate
# which both need API key and other changes for http::geturl, like this:
#   -headers {Content-Type: application/json}
#
# See also:
#    https://wiki.tcl-lang.org/page/Google+Translation+via+http+Module

namespace eval hl_trans {
  variable postUrl https://libretranslate.de/translate
  variable from; array set from [list]
  variable to; array set to [list]
}

#_______________________

proc hl_trans::init {w font szfont args} {
  # Initializes highlighting a translation text.
  #   w - the text
  #   font - font
  #   szfont - font's size
  #   args - highlighting colors

  namespace upvar ::alited al al
  variable postUrl $al(ED,tran)
  variable from
  variable to
  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC
  $w tag config iniVAR -font $font -foreground $clrVAR
  dict set font -slant italic
  $w tag config iniCMNT -font $font -foreground $clrCMN
  foreach t {VAR CMNT} {after idle $w tag raise ini$t}
  lassign [lrange $args end-1 end] from($w) to($w)
  return [namespace current]::line
}
#_______________________

proc hl_trans::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of translation text.
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  if {[string trim $line] eq {}} {return yes}
  set tr [::hl_tcl::my::SearchTag [$w tag ranges iniVAR] $il.1]
  foreach t {VAR CMNT} {$w tag remove ini$t $il.0 $il.end}
  if {$tr!=-1} {
    $w tag add iniVAR $il.0 $il.end
  } else {
    if {[string first # [string trim $line]]==0} {
      $w tag add iniCMNT $il.0 $il.end
    }
  }
  return yes
}
#_______________________

proc hl_trans::TranslateText {txt {src en} {dest de} args} {
  # Translates a text from a source language to a destination language.
  #   txt - text
  #   src - source language
  #   dest - destination language
  #   args - additional options for http::geturl

  variable postUrl
  set query [http::formatQuery q $txt source $src target $dest format text api_key {}]
  if {[catch {
      set post [http::geturl $postUrl -query $query -method POST {*}$args]
  } err]} {
    return [list 0 $err]
  }
  set result [http::data $post]
  set result [::json::json2dict $result]
  http::cleanup $post
  if {[catch {set translation [dict get $result translatedText]}]} {
    catch {set result [dict get $result error]}
    return [list 0 $result]
  }
  set translation [encoding convertfrom utf-8 $translation]
  return [list 1 [htmlparse::mapEscapes $translation]]
}
#_______________________

proc hl_trans::translateLine {} {
  # Translates a current line of the text.

  namespace upvar ::alited al al
  variable from
  variable to
  variable errmsg
  set wtxt [alited::main::CurrentWTXT]
  set nl [expr {int([$wtxt index insert])}]
  set line [$wtxt get $nl.0 $nl.end]
  if {[string trim $line] eq {}} {
    bell
    return
  }
  lassign [alited::complete::TextCursorCoordinates $wtxt] X Y
  ::baltip::showBalloon "Working...\nDon't disturb." \
    -geometry "+$X+$Y" -fg $al(MOVEFG) -bg $al(MOVEBG)
  lassign [TranslateText $line $from($wtxt) $to($wtxt)] ok translation
  ::baltip hide
  if {$ok} {
    set nchars [::apave::obj leadingSpaces $line]
    set indent [string range $line 0 $nchars-1]
    set translation "$indent[string trimleft $translation]"
    if {$al(ED,transadd)} {
      $wtxt insert $nl.end \n$translation
      incr nl
    } else {
      $wtxt replace $nl.0 $nl.end $translation
    }
    update
    after idle [list $wtxt tag add iniVAR $nl.0 $nl.end]
    for {incr nl} {$nl<=[$wtxt index end]} {incr nl} {
      set line [string trim [$wtxt get $nl.0 $nl.end]]
      if {$line ne {}} {
        ::tk::TextSetCursor $wtxt [$wtxt index $nl.0]
        break
      }
    }
    alited::main::HighlightLine
  } else {
    alited::Message $translation 4
  }
}
# ________________________ EOF _________________________ #
