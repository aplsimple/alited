package ifneeded playtkl 1.0.2 [list source [file join $dir playtkl.tcl]]

# A short intro (for Ruff! docs generator:)

namespace eval playtkl {

  set _ruff_preamble {
## What's that

It is Tcl/Tk package:

  * to make a testing scenario for a Tk application
  * to run a testing scenario for a Tk application
  * to record a macro containing mouse / keyboard actions
  * to play a macro

So, there are two working modes of *playtkl*: recording and playing. At recording, mouse / keyboard actions in a Tk application are saved to a file. At playing, the saved actions are read from the file and played back as if the actions were performed by a human.

The *playtkl* is used only with Tk applications. Other GUI Tcl libraries aren't supported.

## Testing Tk

With GUI applications, [tcltest](https://wiki.tcl-lang.org/page/tcltest) and [doctest](https://wiki.tcl-lang.org/page/doctest+for+Tcl) couldn't help you a lot.

To test a GUI application "properly", you might act this way:

   1. You *record* the key / mouse pressings in the application, supposedly at its "good" behavior. Thus, you get a testing scenario of "good" behavior.

   2. After a while, some changes are made to the application.

   3. You *play back* the testing scenario in the application, viewing this spectacle and noticing all discrepancies against the "good" behavior. Or just comparing the final state of the played to the recorded.

   4. You repeat steps 2 and 3 to keep the application consistent with the testing scenario. At need 1st step can be repeated too, if some cool features are introduced into the application. Old scenarios may be saved and rerun as well.

The *playtkl* package is rather good for this way of testing.

Of course, as usually with Tcl/Tk, there are alternative ways, see e.g.

   * [A little GUI tester](https://wiki.tcl-lang.org/page/A+little+GUI+tester)

   * [Law of Demos, tests and transpops](https://wiki.tcl-lang.org/page/Law+of+Demos%2C+tests+and+transpops)

## How's that

To enable *playtkl*, a Tk application should *source playtkl.tcl* and then run the recording or the playing part of it, for example this way:

    if 0 {
        source playtkl.tcl

        set playtklfname ./playtkl.log
        playtkl::inform no

        if 1 {

          # 1. recording
          after 4000 "playtkl::record $playtklfname F11"  ;# or just: playtkl::record $playtklfname

        } else {

          # 2. playing
          after 4000 "playtkl::play $playtklfname F12"  ;# or just: playtkl::play $playtklfname

        }
    }
    ...
    if {[info commands playtkl::end] ne {}} playtkl::end
    exit

Above, after the sourcing, a Tk application does the following:

  * sets a file name as "./playtkl.log"

  * disables info messages on begin / end (by default, they are shown in stdout)

  * depending on a current mode, runs:

    1. recording with *playtkl::record*

    2. playing with *playtkl::play*

  * before exit, *playtkl::end* is a must if no key was pressed to stop the recording

In the above example, the recording and playing are run after 4 seconds of waiting for supposed initialization done. It depends on an application.

Also note that F11 is passed as 2nd (omittable) argument to *playtkl::record* which means a key to stop the recording. This key is mostly good for a macro recording.

The stop key is also useful for testing Tk applications. If a scenario was stopped with a key, then the final state of the application after its playback should be the same as it was after the recording. It's only the final states that can be interesting: if they didn't coincide, the test failed.

In the above example, F12 is passed as 2nd (omittable) argument to *playtkl::play* which means a key to pause / resume the playing.

The example shows a use of *playtkl* in a working mode of Tk application, when the *playtkl* stuff is disabled with "if 0 ..." command (or with commenting out).

## Records

The file of records can contain empty lines and comments like this:

    #
    # It's a playtkl test for apave package.
    #
    # Run with the command:
    #
    #  tclsh ~/PG/github/apave_tests/tests/test2_pave.tcl lightbrown 4 10 12 "small icons"
    #
    # playtkl:   Recording: 11:20:26
    # playtkl:         End: 11:26:40
    #
    Motion .win.#win#menu %t=13150304 %K=?? %b=?? %x=399 %y=1 %s=16 %d=??
    Motion .win.#win#menu %t=13150312 %K=?? %b=?? %x=397 %y=6 %s=16 %d=??
    ...
    #ButtonPress .win.#win#menu.#win#menu#file %t=13455419 %K=?? %b=1 %x=46 %y=152 %s=16 %d=??
    #ButtonRelease .win.#win#menu.#win#menu#file %t=13455611 %K=?? %b=1 %x=46 %y=152 %s=272 %d=??

It begins with comments about the start / end of recording.

At need, any lines can be commented out, e.g. last ones that close the application as shown above.

## Macros

The recording and playing macros is a side effect of the *playtkl*'s main usage. However small, this effect is rather effective sometimes.

The recording and playing macros are performed inside and for a Tcl/Tk application, so that no need for "if 0 ..." to disable *playtkl*.

A stop key should be passed to *playtkl::record*. And vice versa, the key to pause / resume macros isn't of much importance.

To check if the recording is still active, *playtkl::isend* is used.

For example:

    proc NS::checkrecording {{first yes}} {
      if {[playtkl::isend]} {
        bell ;# or something like "resumeWorkFlow", or nothing at all
      } else {
        if {$first} pauseWorkFlow
        after 300 {NS::checkrecording no}
      }
    }
    ...
    playtkl::inform no
    playtkl::record $playtklfname F11
    NS::checkrecording
    ...
    playtkl::replay $playtklfname
    ...
    playtkl::replay
    ...
    playtkl::replay

To replay a macro, *playtkl::replay* is used. A recorded file's name can be passed to *playtkl::replay*. When *playtkl::replay* has no arguments, it doesn't read a file of records, it just replays what was read and played before. Other facilities of `playtkl::replay` can be seen in [Reference](https://aplsimple.github.io/en/tcl/playtkl/playtkl.html), e.g. using a callback for "text edit separator" to undo / redo at one blow.

## Issues

The initial state of a tested Tk application should be absolutely the same at recording and at playing a testing scenario. If the application uses configuration files, these files should be supplied to it in the same state at recording and at playing. It refers mostly to a geometry of Tk application as a whole and to its internal widgets which depend on a ttk theme. But an application's behavior can interfere with the playing too. Probably, OS environments should be identical, e.g. the less the loaded programs the better (esp. notifiers & schedulers).

The following two facts should be counted (i.e. appropriate uses should be avoided):

   * *playtkl* cannot catch those events that occur outside of Tk, e.g. MS Windows' file and color choosers don't provide any Tk bindings and as such aren't seen by *playtkl*

   * *playtkl* doesn't catch events related to window managers like clicking a window's title buttons

With moveable widgets like scrollbars, scales, rulers etc., there may be problems when the widgets are moved too fast at recording - then, at playing them, the mouse pointer can lag a bit, so that the replayed picture would be distorted. Though a bit annoying, this artifact isn't critical in most cases.

However, if played okay once, a recorded scenario would be played okay in all future runs as well. It isn't hard to reach.

All in all, *playtkl* allows testing the main functions of Tk apps and enhancing their facilities with macros.

## Links

  * [Reference](https://aplsimple.github.io/en/tcl/playtkl/playtkl.html)
  * [Source #1](https://chiselapp.com/user/aplsimple/repository/playtkl/download)
  * [Source #2](https://github.com/aplsimple/playtkl)
  * [Demo of recording & playing](https://github.com/aplsimple/playtkl/releases/tag/demo-playtkl-1.0)
  }
}
