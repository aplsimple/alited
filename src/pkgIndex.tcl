package ifneeded alited 1.6.0b3 [list source [file join $dir alited.tcl]]

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

It's quick at starting.

It's quick at switching projects.

It's quick at organizing [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It's quick at navigating [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It's quick at searching [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It's quick at writing [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It's quick at testing [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It's quick at saving [Tcl/Tk](https://wiki.tcl-lang.org/) code.

It's quick at maintaining [Tcl/Tk](https://wiki.tcl-lang.org/) code.

Briefly, [alited](https://github.com/aplsimple/alited) is totally quick, being at that *a pure [Tcl/Tk](https://wiki.tcl-lang.org/) application.*

For a quick acquaintance of [alited](https://github.com/aplsimple/alited), a few of demo videos are available:

   * [Demos of alited v1.4](https://github.com/aplsimple/alited/releases/tag/Demos_of_alited-1.4)

For a quick installation, run [an installer of alited](https://github.com/aplsimple/alited/releases/tag/install-alited-v1.4). After the installation, run its desktop shortcut.

## Links

   * [Installers](https://github.com/aplsimple/alited/releases/tag/install-alited-v1.4)

   * [Description](https://aplsimple.github.io/en/tcl/alited/index.html)
   * [Reference](https://aplsimple.github.io/en/tcl/alited/alited.html)

   * [Source #1](https://chiselapp.com/user/aplsimple/repository/alited/download)
   * [Source #2](https://github.com/aplsimple/alited)

## Inevitable blah-blah

[alited](https://github.com/aplsimple/alited) project started 1 March 2021.

In fact, [alited](https://github.com/aplsimple/alited) has been developed by its own v0.2 since 24 April 2021. Inspite of permanent overheads of this way, it turned out to be amazingly productive, more and more in the course of time.

When developing a weekend or small Tcl project, you can nicely do it with Geany or Kate or something else. The situation becomes not so nice with middle and large Tcl projects, however good and smart those editors are (they are indeed).

What is *a large Tcl project*? The [poApps by Paul Obermeier](http://www.posoft.de/index.html) may be considered a canonical large Tcl project. Its main source directories (poApplib, poTcllib, poTklib) contain about 70 Tcl scripts of size 2.5 Mb (total about 150 files, 5 Mb). Also, [alited](https://github.com/aplsimple/alited) by itself is rather large project containing about 60 main Tcl scripts of size 1.7 Mb (total about 1150 files, 5 Mb), so that no wonder its editing session includes 70-80 files.

It's with the middle and large Tcl projects that [alited](https://github.com/aplsimple/alited) reveals all its best, while it has 0 Kb of dependencies for developing Tcl/Tk 8.6.10+ and is in no way a half gigabyte monster.

The cause is obvious: those other editors aren't Tclish, while [alited](https://github.com/aplsimple/alited) is. It is intended specifically for developing Tcl/Tk projects, not for being a universal plug to every hole. Going its own way, of course. Don't forget that it has been coded in Tcl/Tk.

You'll just become more productive with [alited](https://github.com/aplsimple/alited) at developing Tcl code. Just so simple.

## Typical story

One day I decided to change [e_menu](https://aplsimple.github.io/en/tcl/e_menu/index.html)'s data format because the old .mnu files seemed to be too complex. The [e_menu](https://aplsimple.github.io/en/tcl/e_menu/index.html) project had started in 2018, when I was an active user of Geany. As a result, its main scripts (*e_menu.tcl* and *e_addon.tcl*) were seen as chaotic mixtures of procedures - no structure, no consistency, no order.

I tried and tried to implement the format change, getting in the real trouble with the task that seemed to be so hard...

Finally, in one moment, I decided to rearrange my scripts by **alited's means**, i.e. to make a proper unit tree and to place the code units in their proper branches.

It was only after this radical rearrangement of *e_menu.tcl* and *e_addon.tcl* that I felt the format change can be easily implemented. I did it in two days instead of two weeks as it threatened to be at first.

Along the way, I got two nice unit trees of code. Being two nice pieces of documentation too.

In other words, **alited is a sort of code architect and documentation generator** that organizes and documents Tcl code "on fly" along with the coding.

The alited's unit tree is so good that it by itself can drastically improve Tcl code and enhance a Tcler's productivity. Not to mention other sweets of alited.

## Screenshots

Below is a screenshot of [alited](https://github.com/aplsimple/alited), just to glance at it:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-en.png" class="media" alt="">

... and its localized and themed variant:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-ru.png" class="media" alt="">

... and its themed variant on Windows 10:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-win10.png" class="media" alt="">
  }
}
