# _______________________________________________________________________ #
#
# Highlighting Tcl code with html tags.
#
# Scripted by Alex Plotnikov (aplsimple@gmail.com).
# License: MIT.
# _______________________________________________________________________ #

package require Tk
lappend auto_path [file dirname [info script]]
package require hl_tcl

namespace eval ::hl_tcl_html {
}

proc  ::hl_tcl_html::insertTag {pN tN lcodeN} {
  # Inserts a html tag into Tcl code.
  #   pN - variable's name for a position of the tag
  #   tN - variable's name for the tag
  #   lcodeN - variable's name for the list of code lines
  
  upvar 1 $pN p $tN t $lcodeN lcode
  lassign [split $p .] l c
  incr l -1
  set line [lindex $lcode $l]
  set line1 [string range $line 0 $c-1]
  set line2 [string range $line $c end]
  set lcode [lreplace $lcode $l $l "$line1$t$line2"]
}

proc ::hl_tcl_html::highlight {htmlfile darkedit args} {
  # Processes html file to find and highlight embedded Tcl code.
  #   htmlfile - file name
  #   darkedit - flag "the text widget has dark background" ("no" by default)
  #   args - list of tag pairs
  # A tag pair consists of:
  #   tag1 - opening tag(s) of Tcl code snippet
  #   tag2 - ending tag(s) of Tcl code snippet

  set txt .t
  text $txt
  set chan [open $htmlfile]
  chan configure $chan -encoding utf-8
  set text [read $chan]
  close $chan
  foreach {tag1 tag2} $args {
    set ic [set ic2 0]
    while {$ic>=0 && $ic2>=0} {
      set ic [string first $tag1 $text $ic]
      if {$ic>=0} {
        incr ic [string length $tag1]
        set ic2 [string first $tag2 $text $ic]
        if {$ic2>=0} {
          set code [string range $text $ic $ic2-1]
          if {[string first "<font" $code]>-1} {
            set ic [expr {$ic2+[string length $tag2]}]
            continue  ;# already processed
          }
          set code [string map [list "&quot;" \" "&amp;" &] $code]
          ::hl_tcl::hl_init $txt -dark $darkedit -seen 99999999
          lassign [::hl_tcl::hl_colors 1 $darkedit] clrCOM clrCOMTK clrSTR \
            clrVAR clrCMN clrPROC clrOPT clrBRA - clrCMN2
          $txt replace 1.0 end $code
          ::hl_tcl::hl_text $txt
          set taglist [list]
          foreach tag {tagCOM tagCOMTK tagSTR tagVAR tagCMN tagCMN2 tagPROC tagOPT} {
            foreach {p1 p2} [$txt tag ranges $tag] {
              lassign [split $p1 .] l1 c1
              lassign [split $p2 .] l2 c2
              lappend taglist [list [format %06d $l1][format %06d $c1] $tag 1 $p1]
              lappend taglist [list [format %06d $l2][format %06d $c2] $tag 2 $p2]
            }
          }
          set taglist [lsort -decreasing $taglist]
          set lcode [split $code \n]
          foreach tagdat $taglist {
            lassign $tagdat -> tag typ pos
            switch $tag {
              tagCOM {
                set t1 "<b><font color=$clrCOM>"
                set t2 "</font></b>"
              }
              tagCOMTK {
                set t1 "<b><font color=$clrCOMTK>"
                set t2 "</font></b>"
              }
              tagPROC {
                set t1 "<b><font color=$clrPROC>"
                set t2 "</font></b>"
              }
              tagSTR {
                set t1 "<font color=$clrSTR>"
                set t2 "</font>"
              }
              tagVAR {
                set t1 "<font color=$clrVAR>"
                set t2 "</font>"
              }
              tagCMN {
                set t1 "<i><font color=$clrCMN>"
                set t2 "</font></i>"
              }
              tagCMN2 {
                set t1 "<i><font color=$clrCMN2>"
                set t2 "</font></i>"
              }
              tagOPT {
                set t1 "<font color=$clrOPT>"
                set t2 "</font>"
              }
            }
            if {$typ==1} {
              insertTag pos t1 lcode
            } else {
              insertTag pos t2 lcode
            }
          }
          set code ""
          foreach lc $lcode {
            if {$code ne ""} {append code \n}
            append code $lc
          }
          set code [string map [list \" "&quot;"] $code]
          set text1 [string range $text 0 $ic-1]
          set text2 [string range $text $ic2 end]
          set text "$text1$code"
          set ic [string length $text]
          set text "$text$text2"
        }
      }
    }
  }
  set chan [open $htmlfile w]
  chan configure $chan -encoding utf-8
  puts -nonewline $chan $text
  close $chan
}
after idle exit
# _________________________________ EOF _________________________________ #
#% file copy -force .bak/index-SRC.html .bak/index.html
#% exec tclsh ./tcl_html.tcl .bak/index.html
#% exec opera .bak/index.html
