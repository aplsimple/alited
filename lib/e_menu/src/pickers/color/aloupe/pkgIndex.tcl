
package ifneeded aloupe 1.3 [list source [file join $dir aloupe.tcl]]


# A short intro (for Ruff! docs generator:)

namespace eval aloupe {

  set _ruff_preamble {
The *aloupe* is a Tcl/Tk small widget / utility allowing to view the screen through a loupe.

It allows also

  * to make screenshots of magnified images
  * to pick a color from the images.

It is inspired by the Tcl/Tk wiki pages:

   [A little magnifying glass](https://wiki.tcl-lang.org/page/A+little+magnifying+glass)

   [A Screenshot Widget implemented with TclOO](https://wiki.tcl-lang.org/page/A+Screenshot+Widget+implemented+with+TclOO)

It looks like this:

<img src="https://aplsimple.github.io/en/tcl/aloupe/files/aloupe.png" class="media" alt="">

## Usage

The *aloupe* utility runs with the command:

     tclsh aloupe.tcl ?option value ...?

where `option` may be `-size, -zoom, -alpha, -background, -geometry, -ontop`.

The `Img` and `treectrl` packages have to be installed to run it. In Debian Linux the packages are titled `libtk-img` and `tktreectrl`. If *aloupe* is run by a *tclkit* that doesn't provide these packages, define an environment variable `TCLLIBPATH` before running *aloupe* so that `TCLLIBPATH` be a list of pathes to the packages.

There are also stand-alone [aloupe executables](https://github.com/aplsimple/aloupe/releases) for Linux / Windows.

The executables are started as simply as:

     aloupe ?option value ...?
     aloupe.exe ?option value ...?

After the start, two windows would be displayed: a moveable loupe (at the mouse pointer) and a displaying window.

The loupe is moved by drag-and-drop. At dropping the loupe, its underlying image is magnified in the displaying window.

To change a size/zoom of the loupe, use the appropriate spinboxes. After changing them, just click the loupe to update the windows.

To save the magnified image, use *Save* button.

The *To clipboard* button displays a current pixel's color at clicking the image. When hit, the button puts the color into the clipboard.

The `-command` option may be passed to `::aloupe::run` which will run the passed command at pressing the *To clipboard* button. The command may contain `%c` wildcard meaning the color value. Just to test, try and set `-command "puts %c"` option.

## Options

The *aloupe* can be run with the options:

  * `-size` - a size of the loupe's box (8 .. 256)
  * `-zoom` - a zoom factor (2 .. 32)
  * `-alpha` - an opacity of the loupe (0.0 .. 1.0)
  * `-background` - a background color of the loupe
  * `-geometry` - a displaying window's geometry set as +X+Y
  * `-ontop` - if *yes* (default), sets the displaying window above others
  * `-save` - if *yes* (default), saves/restores the appearance settings
  * `-inifile` - a file to save the settings (~/.config/aloupe.conf by default)
  * `-locale` - a preferable locale (e.g., ru, ua, cz)

Some options can be used at running *aloupe* from a Tcl code:

  * `-exit` - is *false* which means "don't finish Tcl/Tk session, just close the loupe"
  * `-command` - a command to be run at pressing the *To clipboard* button
  * `-commandname` - a label instead of *To clipboard*; when set it means also "no copy to clipboard"
  * `-parent` - a parent window's path (when the parent closes, its *aloupe* children do too)

From a Tcl code, *aloupe* widget is called this way:

     package require aloupe
     ::aloupe::run ?option value ...?

## Links

  * [Reference](https://aplsimple.github.io/en/tcl/aloupe/aloupe.html)

  * [Source](https://chiselapp.com/user/aplsimple/repository/aloupe/download) (aloupe.zip)

  * [Demo and executables](https://github.com/aplsimple/aloupe/releases) for Linux / Windows

## License

MIT.
  }

}

namespace eval ::aloupe::my {

  set _ruff_preamble {
    The `::aloupe::my` namespace contains procedures for the "internal" usage by *aloupe* package.

    All of them are upper-cased, in contrast with the UI procedures of `aloupe` namespace.
  }
}
