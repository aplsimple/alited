
# =========================================================
#
# init.tcl is sourced at executing formatters:
#  - to set default values of variables
#  - to declare common procs
#  - to run initializing code
#
# =========================================================

# Customizing translation.
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

if {![namespace exists ::alited::translator]} {

  package require htmlparse
  package require http
  package require json
  package require tls
  http::register https 443 ::tls::socket
  http::config -accept text/*

  namespace eval ::alited::translator {
    #!  variable postUrl https://libretranslate.de/translate
    #!  variable postUrl https://translate.argosopentech.com/translate
    variable postUrl https://translate.terraprint.co/translate

    proc TranslateText {txt {src en} {dest de} args} {
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

    proc Translate {from to what} {
      # Translates 'what' from a language to a language.
      #   from - source language code
      #   to - destination language code
      #   what - what to translate

      alited::MessageNotDisturb
      lassign [TranslateText $what $from $to] ok translation
      ::baltip hide
      if {$ok} {
        set what $translation
      } else {
        alited::Message $translation 4
      }
      return $what
    }

  ## ________________________ EONS _________________________ ##

  }
}
# ________________________ EOF _________________________ #
