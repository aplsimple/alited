# sframe.tcl
# Paul Walton
# Create a ttk-compatible, scrollable frame widget.
#   Usage:
#       sframe new <path> ?-toplevel true?  ?-anchor nsew? ?-mode x|y|xy|both?
#       -> <path>
#
#       sframe content <path>
#       -> <path of child frame where the content should go>

namespace eval sframe {
  namespace ensemble create
  namespace export *

  # Create a scrollable frame or window.
  proc new {path args} {
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
          event generate $w <MouseWheel> -delta 1
        ::apave::bindToEvent $w <Button-5> \
          event generate $w <MouseWheel> -delta -1
        ::apave::bindToEvent $w <Shift-Button-4> \
          event generate $w <Shift-MouseWheel> -delta 1
        ::apave::bindToEvent $w <Shift-Button-5> \
          event generate $w <Shift-MouseWheel> -delta -1
      }
    }
    ::apave::bindToEvent $w <MouseWheel> [namespace current] scroll $path yview %D
    ::apave::bindToEvent $w <Shift-MouseWheel> [namespace current] scroll $path xview %D
    return $path
  }


  # Given the toplevel path of an sframe widget, return the path of the child frame suitable for content.
  proc content {path} {
    return $path.canvas.container.content
  }


  # Make adjustments when the the sframe is resized or the contents change size.
  proc resize {path} {
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

  # Handle mousewheel scrolling.
  proc scroll {path view D} {
    if { [winfo exists $path.canvas] } {
      $path.canvas $view scroll [expr {-$D}] units
    }
    return
  }
}
# _____________________________ EOF _____________________________________ #
#RUNF1: ../../../src/alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
#RUNF1: ~/PG/github/pave/tests/test2_pave.tcl 0 9 12 "middle icons"
