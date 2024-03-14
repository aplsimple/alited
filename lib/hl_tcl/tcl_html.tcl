#! /usr/bin/env tclsh
#############################################################
# Name:    tcl_html.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 08, 2024
# Brief:   Highlights Tcl code snippets in html files.
#          Runs from CLI as follows:
#            tclsh tcl_html.tcl ?cs=CS? file.html ?file.html?
#          where CS is c1,c2,c3,c4,c5,c6,c7 (color list).
# License: MIT.
#############################################################

source [file join [file dirname [info script]] hl_tcl_html.tcl]
set cs {}
foreach ghtml $::argv {
  if {[string match -nocase cs=* $ghtml]} {
    set cs [split $ghtml =]
  } else {
    foreach fhtml [glob $ghtml] {
      ::hl_tcl_html::highlight $fhtml no {*}$cs \
        {<code class="tcl">} </code> \
        {<pre class="code">} </pre> \
        <code> </code>
    }
  }
}
