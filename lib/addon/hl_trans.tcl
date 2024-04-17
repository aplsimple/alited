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
}

#_______________________

proc hl_trans::init {w font szfont args} {
  # Initializes highlighting a translation text.
  #   w - the text
  #   font - font
  #   szfont - font's size
  #   args - highlighting colors

  namespace upvar ::alited al al
  lassign $args clrCOM clrCOMTK clrSTR clrVAR clrCMN clrPROC
  $w tag config iniPROC -font $font -foreground $clrPROC
  dict set font -slant italic
  $w tag config iniCMNT -font $font -foreground $clrCMN
  foreach t {PROC CMNT} {after idle $w tag raise ini$t}
  return [namespace current]::line
}
#_______________________

proc hl_trans::line {w {pos ""} {prevQtd 0}} {
  # Highlights a line of translation text.
  #   w - the text
  #   pos - position in the line
  #   prevQtd - mode of processing a current line (0, 1, -1)

  lassign [alited::ExtTrans] ext
  if {$pos eq {}} {set pos [$w index insert]}
  set il [expr {int($pos)}]
  set line [$w get $il.0 $il.end]
  if {[string trim $line] eq {}} {return yes}
  set tr [::hl_tcl::my::SearchTag [$w tag ranges iniPROC] $il.1]
  foreach t {PROC CMNT} {$w tag remove ini$t $il.0 $il.end}
  if {$tr!=-1} {
    $w tag add iniPROC $il.0 $il.end
    return yes
  } else {
    if {[string first # [string trim $line]]==0} {
      $w tag add iniCMNT $il.0 $il.end
      return yes
    }
  }
  if {[string tolower $ext] eq {msg}} {return no}
  return yes
}
#_______________________

proc hl_trans::TranslateText {txt {src en} {dest de} args} {
  # Translates a text from a source language to a destination language.
  #   txt - text
  #   src - source language code
  #   dest - destination language code
  #   args - additional options for http::geturl

  variable postUrl
  set query [http::formatQuery q $txt source $src target $dest format text api_key {}]
  if {[catch {
    set post [http::geturl $postUrl -query $query -method POST {*}$args]
  } err]} {
    return [list 0 $err]
  }
  set result [http::data $post]
  http::cleanup $post
  if {[catch {set result [::json::json2dict $result]}]} {
    return [list 0 $result]
  }
  if {[catch {set translation [dict get $result translatedText]}]} {
    catch {set result [dict get $result error]}
    return [list 0 $result]
  }
  set translation [encoding convertfrom utf-8 $translation]
  return [list 1 [htmlparse::mapEscapes $translation]]
}

# ________________________ EOF _________________________ #
