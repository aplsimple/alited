package ifneeded baltip 1.0.3 [list source [file join $dir baltip.tcl]]

namespace eval ::baltip {

  variable _ruff_preamble {
It's a Tcl/Tk tip widget inspired by:

  * [https://wiki.tcl-lang.org/page/Tklib+tooltip](https://wiki.tcl-lang.org/page/Tklib+tooltip)

  * [https://wiki.tcl-lang.org/page/balloon+help](https://wiki.tcl-lang.org/page/balloon+help)

The original code has been modified to make the tip:

  * be faded/destroyed after an interval defined by a caller
  * be enabled/disabled for all or specific widgets
  * be displayed at the screen's edges
  * be displayed under the host widget
  * be displayed as a stand-alone balloon message at given coordinates
  * be displayed with given opacity, font, paddings, colors
  * have configure/cget etc. wrapped in Tcl ensemble for convenience

The video introduction to *baltip* is presented by
 [baltip-1.0.mp4](https://github.com/aplsimple/baltip/releases/download/baltip-1.0/baltip-1.0.mp4) (11 Mb).

Below are several pictures just to glance at *baltip*.

*Under the mouse pointer*. By default, the tips are displayed just under the mouse pointer.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip3.png" class="media" alt="">

*Under the widget*. This button's tip is configured to be just under the button. As well as the text's tip. This feature is well fit for widgets positioned in a row (e.g. in toolbar, tabbar etc.).

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip1.png" class="media" alt="">

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip2.png" class="media" alt="">

*Tips of text tags*. The text tags can have their own tips.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip4.png" class="media" alt="">

*Tips of menu items*. The menu items can have their own tips. The popup menus may be *tear-off* at that.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip5.png" class="media" alt="">

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip6.png" class="media" alt="">

*Label of danger*. The labels are also tipped. This one is configured to be an alert.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip7.png" class="media" alt="">

*Configurable tips*. The tip configuration can be global or local (for a specific tip).

The configuring can include: font, colors, paddings, border, exposition time, opacity, bell.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip8.png" class="media" alt="">

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip9.png" class="media" alt="">

*Balloon*. The balloon messages aren't related to any widgets. This one is configurated to appear at the top right corner, disappearing after a while.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip10.png" class="media" alt="">

## Usage

The *baltip* usage is rather straightforward. Firstly we need `package require`:

      lappend auto_path "dir_of_baltip"
      package require baltip

Then we set tips with `::baltip::tip` command for each appropriate widget:

      ::baltip::tip widgetpath text ?-option value?
      # or this way:
      ::baltip tip widgetpath text ?-option value?

For example, having a button *.win.but1*, we can set its tip this way:

      ::baltip tip .win.but1 "It's a tip.\n2nd line of it.\n3rd."

To get all or specific settings of *baltip*:

      ::baltip::cget ?-option?
      # or this way:
      ::baltip cget ?-option?

To set some options:

      ::baltip::configure -option value ?-option value?
      # or this way:
      ::baltip config -option value ?-option value?

**Note**: the options set with `configure` command are *global*, i.e. active for all tips.
The options set with `tip` command are *local*, i.e. active for the specific tip.

To disable all tips:

      ::baltip::configure -on false

To disable some specific tip:

      ::baltip::tip widgetpath ""
      # or this way:
      ::baltip::tip widgetpath "old tip" -on false

To hide some specific (suspended) tip forcedly:

      ::baltip::hide widgetpath

To update a tip's text and options:

      ::baltip::update widgetpath text ?options?

When you click on a widget with its tip being displayed, the tip is hidden. It is the default behavior of *baltip*, but sometimes you need to re-display the hidden tip. If the widget is a button, you can include the following command in `-command` of the button:

      ::baltip::repaint widgetpath

## Balloon

The *normal* tip has no `-geometry` option because it's calculated by *baltip*, to position the tip under its host widget.

By means of `-geometry` option you get a balloon message unrelated to any visible widget: it's parented by the toplevel window. The `-geometry` option has +X+Y form where X and Y are coordinates of the balloon.

For example:

      ::baltip::tip .win "It's a balloon at +1+100 (+X+Y) coordinates" \
        -geometry +1+100 -font {-weight bold -size 12} \
        -alpha 0.8 -fg white -bg black -per10 3000 -pause 1500 -fade 1500

The `-pause` and `-fade` options make the balloon fade at appearing and disappearing. The `-per10` option defines the balloon's duration: the more the longer.

The `-geometry` value can include `W` and `H` *wildcards* meaning the width and the height of the balloon. This may be useful when you need to show a balloon at a window's edge and should use the balloon's dimensions which are available only after its creation. The X and Y coordinates are calculated by *baltip* as normal expressions. Of course, they should not include the "+" divider, but this restriction (if any) is easily overcome.

For example:

      lassign [split [winfo geometry .win] x+] w h x y
      set geom "+([expr {$w+$x}]-W-4)+$y"
      set text "The balloon at the right edge of the window"
      ::baltip tip .win $text -geometry $geom -pause 2000 -fade 2000

## Options

Below are listed the *baltip* options that are set with `tip` and `configure` and got with `cget`:

 **-on** - switches all tips on/off;
 **-per10** - a time of exposition per 10 characters (in millisec.); "0" means "eternal";
 **-fade** - a time of fading (in millisec.);
 **-pause** - a pause before displaying tips (in millisec.);
 **-alpha** - an opacity (from 0.0 to 1.0);
 **-fg** - foreground of tip;
 **-bg** - background of tip;
 **-bd** - borderwidth of tip;
 **-font** - font attributes;
 **-padx** - X padding for text;
 **-pady** - Y padding for text;
 **-padding** - padding for pack;
 **-under** - if >= 0, sets the tip under the widget, else under the pointer;
 **-bell** - if true, rings at displaying.

The following options are special:

 **-global** - if true, applies the settings to all registered tips;
 **-force** - if true, forces the display by 'tip' command;
 **-index** - index of menu item to tip;
 **-tag** - name of text tag to tip;
 **-geometry** - geometry (+X+Y) of the balloon.

If `-global yes` option is used alone, it applies all global options to all registered tips. If `-global yes` option is used along with other options, only those options are applied to all registered tips.

Of course, all global options will be applied to all tips to be created after `::baltip configuration`. For example:

      ::baltip config -global yes  ;# applies all global options to all registered and to-be-created tips
      ::baltip config -global yes -per10 2000  ;# applies `-per10` to all registered and to-be-created tips

The `-index` option may have numeric (0, 1, 2...) or symbolic form (active, end, none) to indicate a menu entry, e.g. in `-command` option. For example:

      ::baltip repaint .win.popupMenu -index active
      ::baltip::tip .menu "File actions" -index 0

As seen in the above examples, *baltip* can be used as Tcl ensemble, so that the commands may be shortened.

See more examples in *test.tcl* of [baltip.zip](https://chiselapp.com/user/aplsimple/repository/baltip/download).

Also, you can test *baltip* with *test2_pave.tcl* of [apave package](https://chiselapp.com/user/aplsimple/repository/pave/download).

## Links

  * [Demo of baltip v1.0](https://github.com/aplsimple/baltip/releases/download/baltip-1.0/baltip-1.0.mp4)

  * [Reference](https://aplsimple.github.io/en/tcl/baltip/baltip.html)

  * [Source](https://chiselapp.com/user/aplsimple/repository/baltip/download) (baltip.zip)
}
}

namespace eval ::baltip::my {
  variable _ruff_preamble {
    The `::baltip::my` namespace contains procedures for the "internal" usage by *baltip* package.

    All of them are upper-cased, in contrast with the UI procedures of `baltip` namespace.
  }
}
