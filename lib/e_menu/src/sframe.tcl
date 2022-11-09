#############################################################################
# Name:    sframe.tcl
# Authors: main code by Paul Walton, portions by Alex Plotnikov
# Date:    07/04/2022
# Brief:   Handles a ttk-compatible, scrollable frame widget.
# License: Tcl/Tk.
#
# Usage:
#     sframe new <path> ?-toplevel true?  ?-anchor nsew? ?-mode x|y|xy|both?
#       -> <path>
#
#     sframe content <path>
#       -> <path of child frame where the content should go>
#############################################################################

# ________________________ sframe NS _________________________ #

namespace eval sframe {
  namespace ensemble create
  namespace export *

  ## ________________________ sframe::procedures _________________________ ##

  proc new {path args} {
    # Creates a scrollable frame or window.
    #   path - path to the frame/window
    #   args - options

    # Use the ttk theme's background for the canvas and toplevel
    set bg [ttk::style lookup TFrame -background]
    if { [ttk::style theme use] eq "aqua" } {
      # Use a specific color on the aqua theme as 'ttk::style lookup' is not accurate.
      set bg "#e9e9e9"
    }

    # Create the main frame or toplevel.
    if { [dict exists $args -toplevel]  &&  [dict get $args -toplevel] } {
      toplevel $path  -bg $bg
    } else {
      ttk::frame $path
    }

    # Create a scrollable canvas with scrollbars which will always be the same size as the main frame.
    set mode both
    if { [dict exists $args -mode] } {
      set mode [dict get $args -mode]
    }
    switch -- [string tolower $mode] {
      both - xy - yx {
        set canvas [canvas $path.canvas -bg $bg -bd 0 -highlightthickness 0 -yscrollcommand [list $path.scrolly set] -xscrollcommand [list $path.scrollx set]]
        ttk::scrollbar $path.scrolly -orient vertical   -command [list $canvas yview]
        ttk::scrollbar $path.scrollx -orient horizontal -command [list $canvas xview]
      }
      y {
        set canvas [canvas $path.canvas -bg $bg -bd 0 -highlightthickness 0 -yscrollcommand [list $path.scrolly set]]
        ttk::scrollbar $path.scrolly -orient vertical   -command [list $canvas yview]
      }
      x {
        set canvas [canvas $path.canvas -bg $bg -bd 0 -highlightthickness 0 -xscrollcommand [list $path.scrollx set]]
        ttk::scrollbar $path.scrollx -orient horizontal -command [list $canvas xview]
      }
      default {
        return -code error "-mode option is invalid: \"$mode\" (valid are x, y, xy, yx, both)"
      }
    }

    # Create a container frame which will always be the same size as the canvas or content, whichever is greater.
    # This allows the child content frame to be properly packed and also is a surefire way to use the proper ttk background.
    set container [ttk::frame $canvas.container]
    pack propagate $container 0

    # Create the content frame. Its size will be determined by its contents. This is useful for determining if the
    # scrollbars need to be shown.
    set content [ttk::frame $container.content]

    # Pack the content frame and place the container as a canvas item.
    set anchor "n"
    if { [dict exists $args -anchor] } {
      set anchor [dict get $args -anchor]
    }
    pack $content -fill both -expand 1 -anchor $anchor
    $canvas create window 0 0 -window $container -anchor nw

    # Grid the scrollable canvas sans scrollbars within the main frame.
    grid $canvas   -row 0 -column 0 -sticky nsew
    grid rowconfigure    $path 0 -weight 1
    grid columnconfigure $path 0 -weight 1

    # Make adjustments when the sframe is resized or the contents change size.
    bind $path.canvas <Configure> [list [namespace current]::resize $path]

    # Mousewheel bindings for scrolling
    set w [winfo toplevel $path]
    catch {
      if {$::tcl_platform(platform) eq {unix}} {
        ::apave::bindToEvent $w <Button-4> \
          [namespace current]::wheelDelta $w <MouseWheel> 1
        ::apave::bindToEvent $w <Button-5> \
          [namespace current]::wheelDelta $w <MouseWheel> -1
        ::apave::bindToEvent $w <Shift-Button-4> \
          [namespace current]::wheelDelta $w <Shift-MouseWheel> 1
        ::apave::bindToEvent $w <Shift-Button-5> \
          [namespace current]::wheelDelta $w <Shift-MouseWheel> -1
      }
    }
    ::apave::bindToEvent $w <MouseWheel> \
      [namespace current]::wheelScroll $w [namespace current] scroll $path yview %D
    ::apave::bindToEvent $w <Shift-MouseWheel> \
      [namespace current]::wheelScroll $w [namespace current] scroll $path xview %D
    return $path
  }
  #_______________________

  proc content {{path ""}} {
    # Gets the path of the child frame suitable for content.
    #   path - path to the scrollable window/frame

    return $path.canvas.container.content
  }
  #_______________________

  proc resize {path} {
    # Makes adjustments when the the sframe is resized or the contents change size.
    #   path - path to the scrollable window/frame

    set canvas    $path.canvas
    set container $canvas.container
    set content   $container.content

    # Set the size of the container. At a minimum use the same width & height as the canvas.
    set width  [winfo width $canvas]
    set height [winfo height $canvas]

    # If the requested width or height of the content frame is greater then use that width or height.
    if { [winfo reqwidth $content] > $width } {
      set width [winfo reqwidth $content]
    }
    if { [winfo reqheight $content] > $height } {
      set height [winfo reqheight $content]
    }
    $container configure  -width $width  -height $height

    # Configure the canvas's scroll region to match the height and width of the container.
    set bg [lindex [::apave::obj csGet] 3]
    $canvas configure -scrollregion [list 0 0 $width $height] -bg $bg

    # Show or hide the scrollbars as necessary.
    # Horizontal scrolling.
    if {[winfo exists $path.scrollx]} {
      if { [winfo reqwidth $content] > [winfo width $canvas] } {
        grid $path.scrollx  -row 1 -column 0 -sticky ew
      } else {
        grid forget $path.scrollx
      }
    }
    # Vertical scrolling.
    if {[winfo exists $path.scrolly]} {
      if { [winfo reqheight $content] > [winfo height $canvas] } {
        grid $path.scrolly  -row 0 -column 1 -sticky ns
      } else {
        grid forget $path.scrolly
      }
    }
    return
  }
  #_______________________

  proc scroll {path view D} {
    # Handles mousewheel scrolling.
    #   path - path to the scrollable window/frame
    #   view - xview or yview
    #   D - scrolling units

    if { [winfo exists $path.canvas] } {
      $path.canvas $view scroll [expr {-$D}] units
    }
    return
  }
  #_______________________

  proc checkScroll {w} {
    # Checks whether the scrolling is possible.
    #   w - window

    set res yes
    catch {
      lassign [winfo pointerxy $w] rootX rootY
      if {[set win [winfo containing $rootX $rootY]] eq {}} {
        set win [focus]
      }
      if {[winfo exists $win]} {
        set ts [string tolower [winfo class $win]]
      } else {
        set ts -
      }
      if {$ts in {tablelist text listbox treeview}} {
        set res no
      }
    }
    return $res
  }
  #_______________________

  proc wheelScroll {w args} {
    # Scrolls a window.
    #   w - window

    catch {
      if {[checkScroll $w]} {
        {*}$args
      }
    }
  }
  #_______________________

  proc wheelDelta {w ev delval} {
    # Generate mouse wheel events with deltas (for Linux).
    #   w - window
    #   ev - event
    #   delval - delta

    catch {
      if {[checkScroll $w]} {
        event generate $w $ev -delta $delval
      }
    }
  }

  ## ________________________ EONS sframe _________________________ ##

}

# _____________________________ EOF _____________________________________ #
#RUNF1: C:/PG/github/pave/tests/test2_pave.tcl alt 0 9 12 "small icons"
#RUNF1: ../../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
