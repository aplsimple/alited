
# =========================================================
#
# init.tcl is sourced at executing formatters:
#  - to set default values of variables
#  - to declare common procs
#  - to run initializing code
#
# =========================================================

# Customizing URL of translation.

namespace eval ::alited::hl_trans {
#!  variable postUrl https://libretranslate.de/translate
#!  variable postUrl https://translate.argosopentech.com/translate
  variable postUrl https://translate.terraprint.co/translate
}
