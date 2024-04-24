package ifneeded alited 1.8.4b1 [list source [file join $dir alited.tcl]]

namespace eval ::alited {

  # A short intro (for Ruff! docs generator:)

  variable _ruff_preamble {
## What's that

[alited](https://github.com/aplsimple/alited) stands for *a lite editor*.

It satisfies most requirements of [Tcl Editors](https://wiki.tcl-lang.org/Tcl+Editors), adding its own features. It pretends to be the best of the [Tcl Editors](https://wiki.tcl-lang.org/Tcl+Editors).

The main features of [alited](https://github.com/aplsimple/alited) are:

  * structured [Tcl/Tk](https://wiki.tcl-lang.org/) code
  * easy access to [Tcl/Tk](https://wiki.tcl-lang.org/) code
  * born for development of [Tcl/Tk](https://wiki.tcl-lang.org/) projects

Edited by [alited](https://github.com/aplsimple/alited) are [Tcl/Tk](https://wiki.tcl-lang.org/) files. The C/C++ code is another target of [alited](https://github.com/aplsimple/alited), still for development of [Tcl/Tk](https://wiki.tcl-lang.org/) projects all the same.

[alited](https://github.com/aplsimple/alited) facilitates the development and the maintenance of [Tcl/Tk](https://wiki.tcl-lang.org/) code, particularly because of the [unit tree](https://aplsimple.github.io/en/tcl/alited/index.html#units) being a sort of documentation.

[alited](https://github.com/aplsimple/alited) is suspected of being very good with large [Tcl/Tk](https://wiki.tcl-lang.org/) projects, i.e. when, in one session, you deal with 30-40-50... [Tcl/Tk](https://wiki.tcl-lang.org/) scripts, to say nothing of others.

It is quick at starting.

It is quick at switching projects.

It is quick at organizing [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It is quick at navigating [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It is quick at searching [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It is quick at writing [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It is quick at testing [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It is quick at saving [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It is quick at maintaining [Tcl/Tk](https://wiki.tcl-lang.org/) code.

Briefly, [alited](https://github.com/aplsimple/alited) is totally quick, being at that *a pure [Tcl/Tk](https://wiki.tcl-lang.org/) application.*

For a quick acquaintance of [alited](https://github.com/aplsimple/alited), a few of [its demos](https://github.com/aplsimple/alited/releases/tag/Demos_of_alited-1.6) are available.

For a quick installation of [alited](https://github.com/aplsimple/alited), just run an [installer of alited](https://github.com/aplsimple/alited/releases/tag/install-alited-v1.6).

## Links

   * [Installers](https://github.com/aplsimple/alited/releases/tag/install-alited-v1.6)

   * [Source #1](https://chiselapp.com/user/aplsimple/repository/alited/download)
   * [Source #2](https://github.com/aplsimple/alited)

   * [Description](https://aplsimple.github.io/en/tcl/alited/index.html)
   * [Reference](https://aplsimple.github.io/en/tcl/alited/alited.html)
   * [Project printer](https://aplsimple.github.io/en/tcl/printer/alited/index.html)
   * [Demos](https://github.com/aplsimple/alited/releases/tag/Demos_of_alited-1.6)

## Inevitable blah-blah

[alited](https://github.com/aplsimple/alited) project started 1 March 2021.

In fact, [alited](https://github.com/aplsimple/alited) has been developed by its own v0.2 since 24 April 2021. Inspite of permanent overheads of this way, it turned out to be amazingly productive, more and more in the course of time.

When developing a weekend or small Tcl/Tk project, you can nicely do it with [Geany](https://www.geany.org) or [Kate](https://kate-editor.org) or something else. The situation becomes not so nice with middle and large Tcl/Tk projects, however good and smart those editors are (they are indeed).

What is *the large Tcl project*? The [poApps by Paul Obermeier](http://www.posoft.de/index.html) may be considered the canonical large Tcl project. Its main source directories (poApplib, poTcllib, poTklib) contain about 70 Tcl scripts of size 2.5 Mb (total about 150 files, 5 Mb). Also, [alited](https://github.com/aplsimple/alited) by itself is rather large project containing about 60 main Tcl scripts of size 1.7 Mb (total about 1150 files, 5 Mb), so that no wonder its editing session includes 70-80 files.

It is with the middle and large Tcl projects that [alited](https://github.com/aplsimple/alited) reveals all its best, while it has 0 Kb of dependencies for developing Tcl/Tk 8.6.10+ and is in no way a half gigabyte monster.

The cause is obvious: those other editors are not Tclish, while [alited](https://github.com/aplsimple/alited) is. It is intended specifically for developing Tcl/Tk projects, not for being a universal plug to every hole. Going its own way, of course. Do not forget that it has been coded in Tcl/Tk.

By the way, sometimes I still return to the good old [Geany](https://www.geany.org) or [Pluma](http://mate-desktop.org) (when my [alited](https://github.com/aplsimple/alited) is busy with an open dialogue) - just to confirm once more how good [alited](https://github.com/aplsimple/alited) is.

One just becomes more productive with [alited](https://github.com/aplsimple/alited) at developing Tcl code. Just so simple.

## Typical story

One day I decided to change the data format of [e_menu](https://aplsimple.github.io/en/tcl/e_menu/index.html) because the old .mnu files seemed to be too complex. The [e_menu](https://aplsimple.github.io/en/tcl/e_menu/index.html) project had started in 2018, when I was an active user of [Geany](https://www.geany.org). As a result, its main scripts (*e_menu.tcl* and *e_addon.tcl*) were seen as chaotic mixtures of procedures - no structure, no consistency, no order.

I tried and tried to implement the format change, getting in the real trouble with the task that seemed to be so hard...

Finally, in one moment, I decided to rearrange my scripts by **means of alited**, i.e. to make a proper unit tree and to place the code units in their proper branches.

It was only after the radical rearrangement of *e_menu.tcl* and *e_addon.tcl* that I felt the format change can be easily implemented. I did it in two days instead of two weeks as it threatened to be at first.

Along the way, I got two nice unit trees of code. Being two nice pieces of documentation too.

In other words, **alited is a sort of code architect and documentation generator** that organizes and documents Tcl code "on fly" along with the coding.

The unit tree of alited is so good that it by itself can drastically improve Tcl code and enhance the productivity of Tclers. Not to mention other sweets of alited.

## Screenshots

Below is a screenshot of [alited](https://github.com/aplsimple/alited), just to glance at it:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-en.png" class="media" alt="">

and its localized and themed variant:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-ru.png" class="media" alt="">

and its dark theme on Windows 10:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-win10.png" class="media" alt="">

and its 1.6.5 version installed 24.01.2024 on x86 machine with Debian v6.0 (Linux core v2.6.32) and GNOME v2.30.2, deployed far back in 2010:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited_in_debian6.png" class="media" alt="">

and its localized variant running [under Wine](https://www.winehq.org) of [Linux Mint DE](https://linuxmint.com/download_lmde.php) on x86 machine (with Windows console started by [alited](https://github.com/aplsimple/alited), Linux console started by [Linux Mint](https://linuxmint.com/)):

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-wine.png" class="media" alt="">
  }
}
