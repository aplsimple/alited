package ifneeded baltip 1.3.7 [list source [file join $dir baltip.tcl]]

namespace eval ::baltip {
  variable _ruff_preamble {
It's a Tcl/Tk tip widget inspired by:

  * [https://wiki.tcl-lang.org/page/Tklib+tooltip](https://wiki.tcl-lang.org/page/Tklib+tooltip)

  * [https://wiki.tcl-lang.org/page/balloon+help](https://wiki.tcl-lang.org/page/balloon+help)

The original code has been modified to make the tip:

  * be faded/destroyed after an interval defined by a caller
  * be enabled/disabled for all or specific widgets
  * be disabled for a while ("sleep")
  * be usable with labels, menus, text/canvas tags, notebook tabs, listbox/treeview items etc.
  * be displayed at the screen's edges
  * be displayed under the host widget
  * be displayed as a stand-alone balloon message at given coordinates
  * be displayed with given font, colors, paddings, border, relief, opacity, bell
  * have -image and -compound options to display images
  * have -command option to be displayed in a status bar instead of a balloon
  * have -command option to be changed dynamically, with each tip's exposition
  * have -maxexp option to limit the number of tip's expositions
  * have configure/cget etc. wrapped in Tcl ensemble for convenience

The video introduction to *baltip* is presented by
 [baltip-1.3.1.mp4](https://github.com/aplsimple/baltip/releases/download/baltip-1.3.1/baltip-1.3.1.mp4) (17 Mb).

Below are several pictures just to glance at *baltip*.

*Under the mouse pointer*. By default, the tips are displayed just under the mouse pointer.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip3.png" class="media" alt="">

*Under the widget*. This button's tip is configured to be just under the button. As well as the text's tip. This feature is well fit for widgets positioned in a row (e.g. in toolbar, tabbar etc.).

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip1.png" class="media" alt="">

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip2.png" class="media" alt="">

*Tips of text tags*. The text tags can have their own tips.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip4.png" class="media" alt="">

The *tags of canvas* have tips too.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip12.png" class="media" alt="">

*Tips of menu items*. The menu items can have their own tips. The popup menus may be *tear-off* at that.

The menu tips are useful e.g. when the items are displayed as short names, while
the tips are wanted to be full names.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip6.png" class="media" alt="">

*Label of danger*. The labels are also tipped. This one is configured to be an alert shown "eternally" (i.e. till hovering over it).

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip7.png" class="media" alt="">

The *tabs of notebook* are also supplied with tips.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip13.png" class="media" alt="">

The *listbox* can have tips per item as well as for a whole listbox widget.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip14.png" class="media" alt="">

The *treeview* can have tips per item and/or column as well as for a whole treeview widget.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip15.png" class="media" alt="">

The *-command* option allows to display tips in a status bar instead of a balloon.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip16.png" class="media" alt="">

*Configurable tips*. The tip configuration can be global or local (for a specific tip).

The configuring can include: font, colors, paddings, border, relief, exposition time, opacity, image (with -compound), bell.

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip9.png" class="media" alt="">

 <img src="https://aplsimple.github.io/en/tcl/baltip/files/btip11.png" class="media" alt="">

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

The "text" for *listbox* can contain %i wildcard - and in such cases the text means a callback receiving a current index of item to tip:

      proc ::lbxTip {idx} {
        set item [lindex $::lbxlist $idx]
        return "Tip for \"$item\"\nindex=$idx"
      }
      ::baltip tip .listbox {::lbxTip %i}

The "text" for *treeview* can contain %i and/or %c wildcards - and in such cases the text means a callback receiving ID of item and/or column of item to tip:

      proc ::treTip {id c} {
        set item [.treeview item $id -text]
        return "Tip for \"$item\"\nID=$id, column=$c"
      }
      ::baltip::tip .treeview {::treTip %i %c}

If a tip for listbox and treeview widgets doesn't contain %i nor %c, it means a usual tip for a whole widget. At that, if those wildcards still need to be displayed, use %%i and %%c instead.

If you need to switch between "per item" and "per widget" tip of listbox and treeview , use `::baltip::tip` with `-reset yes` option:

      ::baltip::tip .treeview {Common tip} -reset yes      ;# sets a usual tip
      ::baltip::tip .treeview {::treTip %i %c} -reset yes  ;# sets a callback

Some GUI objects (notebook tabs, listbox items, treeview items) have not &lt;Enter&gt; nor &lt;Leave&gt; event bindings, so that those bindings are imitated by *baltip*. Hence a problem with popup menus: when you right-click those GUI objects, *baltip::tip* and *tk_popup* might both fire, which results in a mess.

To avoid this, use *::baltip::sleep* before *tk_popup*, for example:

      ::baltip::sleep 1000        ;# disables tips for 1000 milliseconds
      tk_popup $popupmenu $X $Y   ;# calls a popup menu at $X $Y coordinates

As for [tablelist](https://wiki.tcl-lang.org/page/tablelist) widget, I would like to cite an advice by [Csaba Nemethi](https://www.nemethi.de/) :

    The support for tablelist is a special case, don't waste your time with
    it.  I have already tested that the built-in tooltip support of
    Tablelist will work just fine when replacing tklib's tooltip package
    with baltip (after fixing the reported bugs), and I intend to extend the
    description of the -tooltipaddcommand option by hints showing how to use
    this option with baltip instead of BWidget and tklib's tooltip.

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


## Command

The "-command" option allows to display tips in other places, for example in a status bar. At that, the command can include %t and %w wildcards, meaning "text" and "widget path". Such tips are well fit for menu items, as seen in *test.tcl*.

The command of this option must return {}, if no tips should be displayed.

Also, it can return a new tip to display as a usual balloon tip, which fits for "dynamic tips" that are changed *at each exposition* of a tip.

For example:

      proc ::Status {tip} {
        .labelstatus configure -text $tip
        return {}  ;# no redefining the tip
      }
      ::baltip::tip .menu "File actions" -index 0 -command {::Status {%t}}
      ::baltip::tip .menu "Help, hints, Q&A, about etc." -index 1 -command {::Status {%t}}

Also, this option can be used if you need to fire some code when the mouse pointer enters or leaves a GUI object.

**Note**: the *baltip* is available for a few of GUI objects that have not &lt;Enter&gt; nor &lt;Leave&gt; bindings.

The only line

      baltip::tip $w $tip -command $command

might save you other lines to fire the command at entering/leaving a GUI object. E.g. the command might highlight a GUI object entered, save its ID and unhighlight the object at leaving it.

For example:

      proc ::SomeProc {tip} {
        lassign [split $tip] obj ID column
        if {[info exists ::OBJsaved]} {
          puts "$::OBJsaved object ID=[set ::IDsaved] is left... unhighlighted..."
          unset ::OBJsaved
        }
        if {$obj eq {}} return
        set ::OBJsaved $obj
        set ::IDsaved $ID
        puts "Now processing $obj object with ID=$ID column=$column"
      }
      ::baltip::tip .listbox {Listbox %i} -command {::SomeProc {%t}}
      ::baltip::tip .treeview {Treeview %i %c} -command {::SomeProc {%t}}
      return {}  ;# means the proc executed and no tip needed


## Options

Below are listed the *baltip* options that are set with `tip` and `configure` and got with `cget`:

 * `-on` - switches all tips on/off;
 * `-per10` - a time of exposition per 10 characters (in millisec.); "0" means "eternal";
 * `-fade` - a time of fading (in millisec.);
 * `-pause` - a pause before displaying tips (in millisec.);
 * `-alpha` - an opacity (from 0.0 to 1.0);
 * `-fg` - foreground of tip;
 * `-bg` - background of tip;
 * `-bd` - borderwidth of tip;
 * `-font` - font attributes;
 * `-padx` - X padding for text;
 * `-pady` - Y padding for text;
 * `-padding` - padding for pack;
 * `-under` - if >= 0, sets the tip under the widget, else under the pointer;
 * `-image` - image option;
 * `-compound` - compound option;
 * `-relief` - relief option;
 * `-bell` - if true, rings at displaying.

The following options are special:

 * `-global` - if true, applies the settings to all registered tips;
 * `-force` - if true, forces the display by 'tip' command;
 * `-index` - index of menu item to tip;
 * `-tag` - name of text tag to tip;
 * `-ctag` - name of canvas tag to tip;
 * `-nbktab` - path to ttk::notebook tab to tip;
 * `-geometry` - geometry (+X+Y) of the balloon;
 * `-reset` - "-reset true" may be useful to set a new tip (callback or text) for listbox and treeview;
 * `-command` - a command to be executed, with %t (tip's text) and %w (widget's path) wildcards;
 * `-maxexp` - maximum number of tip's expositions.

If `-global yes` option is used alone, it applies all global options to all registered tips. If `-global yes` option is used along with other options, only those options are applied to all registered tips.

Of course, all global options will be applied to all tips to be created after `::baltip configuration`. For example:

      ::baltip config -global yes  ;# applies all global options to all registered and to-be-created tips
      ::baltip config -global yes -per10 2000  ;# applies `-per10` to all registered and to-be-created tips

The `-index` option may have numeric (0, 1, 2...) or symbolic form (active, end, none) to indicate a menu entry, e.g. in `-command` option. For example:

      ::baltip repaint .win.popupMenu -index active
      ::baltip::tip .menu "File actions" -index 0

There may be useful to define options in *text* argument of *::baltip::tip*.

For this, provide the *text* argument as a list of pairs of uppercased options' name / value including *-BALTIP* option for *tip*. For example:

      ::baltip tip .text "-BALTIP {Sort of diary, todos etc.} -MAXEXP 1"

As seen in the above examples, *baltip* can be used as Tcl ensemble, so that the commands may be shortened.

See more examples in *test.tcl* of [baltip.zip](https://chiselapp.com/user/aplsimple/repository/baltip/download).

Also, you can test *baltip* with *test2_pave.tcl* of [apave package](https://chiselapp.com/user/aplsimple/repository/pave/download).

## Acknowledgements

The *baltip* package has been developed with help of these kind people:

  * [Nicolas Bats](https://github.com/sl1200mk2) prompted to add canvas tags' tips and tested *baltip* in MacOS

  * [Csaba Nemethi](https://www.nemethi.de/) sent several bug fixes and advices, especially on listbox, treeview and menu tips

## Links

  * [Source at chiselapp](https://chiselapp.com/user/aplsimple/repository/baltip/download) (baltip.zip)

  * [Source at github](https://github.com/aplsimple/baltip)

  * [Reference](https://aplsimple.github.io/en/tcl/baltip/baltip.html)

  * [Demo of baltip v1.3.1](https://github.com/aplsimple/baltip/releases/download/baltip-1.3.1/baltip-1.3.1.mp4)
}
}

namespace eval ::baltip::my {
  variable _ruff_preamble {
    The `::baltip::my` namespace contains procedures for the "internal" usage by *baltip* package.

    All of them are upper-cased, in contrast with the UI procedures of `baltip` namespace.
  }
}
