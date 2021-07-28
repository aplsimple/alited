# What's that

The *alited* stands for "a lite editor".

The main features of *alited* are:

  * structured code 
  * easy access to the code
  * born for Tcl/Tk development only

Edited by *alited* are Tcl/Tk files. The C/C++ code is another target of *alited*, still for *Tcl/Tk development only* all the same.

The *alited* facilitates the development and the maintenance of Tcl/Tk code, particularly because of the unit tree being a sort of documentation.

In fact, *alited* has been developed by its own means since v0.2. Inspite of inevitable overheads of this way and the raw state of *alited*, it turned out to be amazingly productive, more and more in the course of time. The time of rawness expires somehow at a little bit of efforts, huh.

Below is a screenshot of *alited*:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-en.png" class="media" alt="">

... and its localized and themed variant:

<img src="https://aplsimple.github.io/en/tcl/alited/files/alited-ru.png" class="media" alt="">


# How's that

The Tcl/Tk code is organized as a *unit tree* by means of customized hierarchical comments.

The units are mostly procedures / methods and are named accordingly. These are leaves of the *unit tree*. However, any part of a source text may be isolated into a named branch of the tree.

If some source lines cannot be recognized as a unit, they are united in the *unit tree* with a generated name ("Lines so and so").

# Units

The unit separation is carried out with the hierarchical comments as follows:
 
    # __ NAME (1st level) __ #
    ...
      # The "name1" does so and so...
      # ...
      proc name1 {} {
      ...
      }
      ...

      ## __ NAME (2nd level) __ ##
      ...
        # The "name2" does so and so...
        # ...
        proc name2 {} {
        ...
        }
        ...

        ### __ NAME (3rd level) __ ###
        ...

These comments are customized, e.g. #=== NAME ===  may be used instead.

**Note:** The first # characters define the unit tree's level: # means 1, ## means 2, ### means 3 etc. It isn't reasonable to customize and use # NAME # and ## NAME ## and ### NAME ### etc. for the unit tree's levels, because of any comment beginning with # would be treated as a unit.

Still, if you want to use # alone (without adding _ = - + ~ * . : etc.), you can customize alited so that ## will mean 1st level, ### 2nd level, #### 3rd level etc., using a branch regexp like this:

    ^\s*#(#+)\s+([^_]+[^[:blank:]]*)

thus allowing the tree comments as follows:

    ## Initialize GUI
      ...some code
      ### This widget group
        ... this code
      ### That widget group
        ... that code

The *alited* recognizes the units by these comments and presents them as a tree.

This tree of units doesn't means anything like *code folding* or *structured editing* which refer to the Tcl structural commands like *if, switch, foreach, proc* and so on. The *alited* unit tree results from the hierarchical comments only.

The unit tree includes the *unit comments* as the branches and the *procedures / methods* as the leaves.

# Example

    #! /usr/bin/env tclsh
    #
    # It's just an example.

    # ________________ Packages used _____________ #
    package require Tk

    # ________________ "example" _________________ #
    #
    # Some words about...

    namespace eval example {

      ## ___________ example's variables _________ ##

      variable var1 "value 1"
      variable var2 "value 2"

      ## __________ example's procedures _________ ##
      #
      # Below are procedure doing so and so.

      # this proc prints one
      proc one {} {puts "one"}

      # this proc prints two
      proc two {} {puts "two"}

      ## _________________ "my" __________________ ##
      #
      # Some words about...

      namespace eval my {

        ### ___________ my's variables ___________ ###
        variable var1 "val1"

        ### ___________ my's procedures __________ ###
  

        proc myone {} {puts "my one"}
        proc mytwo {} {puts "my two"}

        # this proc prints "my three"
        proc mythree {} {puts "my three"}

      ## ______________ end of "my" ______________ ##
      }

    # _____________ end of "example" _____________ #
    }
    # _____________________  EOF _________________ #

This example will produce the following unit tree:

    ROOT
      |__ Lines 1-4
      |__ Packages used
      |   "example"
      |     |__ example's variables
      |     |__ example's procedures
      |     |     |__ one
      |     |     |__ two
      |     |__ "my"
      |     |     |__ my's variables
      |     |     |__ my's procedures
      |     |           |__ myone
      |     |           |__ mytwo
      |     |           |__ mythree
      |     |__ end of "my"
      |__ end of "example"
      |__ EOF

This example is small and easy to observe. Its tree view doesn't differ greatly from the code view.

In a *real life*, a code isn't easily observed even with *bird's eye view* or with *code folding*.

And here *alited* comes to help.

# Bonuses

At adding a unit, a template can be selected from a list of customized templates.

A long unit can be detected by its "red bar" icon in the unit tree, as seen in the screenshots above. I.e. when a unit is too long, it's marked red. The "redness" is customized.

A unit or a group of units can be moved up/down a unit tree. A group of units is selected by Ctrl+Click on the unit tree. Also, a unit can be moved by drag-and-drop in the unit tree. This highly facilitates the *code gardening*, compared to the cut-paste method when an origin and a target of the cut-pasting aren't so much close.

The *alited* allows to check code units (procedures and methods) for a consistency of braces etc. By clicking a line in the list of errors, you can go to the appropriate unit.

In a session, the cursor's position of a unit is saved by *alited*, so that when you return to the unit, the cursor is at the saved position and you can continue to solve a problem of this unit.

Press Ctrl-Click on a word to go a proc/method declaration. It will be searched in a current session's files.

Press Ctrl-Shift-Click on a word to look for a word under cursor (or a selected string) instances around the session.

Another useful search is performed with Ctrl+Shift+F which means "Search a unit". It will scan all session files (or a current file) for a glob pattern, case insensible at that. E.g. when you enter "put" to find some unit, you would possibly find these units:

    InputData
    common::io::PutData
    out::Put
    Output of module

where the last found unit is obviously a branch of some level. This search mode is *very useful* when you remember only a part of the unit's name to find. Use any glob characters inside your pattern, e.g. setting it like `a*b*c` or `a[bcd]e`.

To find a proc/method by auto completion, try to press Tab at the initial characters of this proc/method which would bring up a list of all procs/methods in a current session whose names are beginning with those characters. The Tab key is a customized option of "Preferences/Keys".

The *branches* and *leaves* of the unit tree are supplied with balloon tips to view their contents (declarations). These tips can be copied to the clipboard with the popup menu.

Any unit of any file of a project can be marked/unmarked as *favorite*. Each project has its own list of favorites.

While developing a project, you deal with various types of problems and as such with various code units. So, you can need various favorite units for various problems, esp. when the problems tend to occur repeatedly.

In the utmost case, you might need subprojects inside your project. Various "child" packages inside a "parent" one and so on.

The *alited* allows you to save the current list of favorites to the *lists of favorites* under a "problem/issue/subproject name".

Thus, you can have *projects inside project*.

The *last visited* list is a comrade of the favorites. It allows fast access to the last visited units. The *last visits* are registered at clicking units in the unit tree or at clicking found lines in the info listbox.

In a session, the visited units are highlighted in the unit tree, so that you can see which of them were visited. The more observed, the more navigated.

When you select a file to edit, it becomes the first one (if not visible yet) in the bar of file tabs. So that you have the last edited files be first in the bar of files.

Press Ctrl-Tab to switch between *last two* edited files.

"Last visited is most needed."

The F1 key is used to call a context Tcl/Tk help. Set the cursor on a Tcl/Tk command and press F1 and you'll get the help on the command.

Still to have this, you should download the Tcl/Tk help into ~/DOC directory by the commands:

    mkdir ~/DOC
    cd ~/DOC
    wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/

A great deal of other tools are available through "Tools" menu, alited's toolbar and "Preferences/Tools" options. They are highly customized due to [e_menu](https://aplsimple.github.io/en/tcl/e_menu) application which is closely bound to the alited environment. At least 11 actions of alited's toolbar are provided by [e_menu](https://aplsimple.github.io/en/tcl/e_menu) as default, and you can select/ change/ add your own ones, not to mention running [e_menu](https://aplsimple.github.io/en/tcl/e_menu) by itself. This provides a lot of utilities supporting Tcl/Tk development.

# How that's installed

The installation of *alited* is straightforward:

  * download [alited.zip](https://chiselapp.com/user/aplsimple/repository/alited/zip/trunk/alited.zip)

  * unpack *alited.zip* to some directory, say ~/PG/alited

  * to run the installed *alited*, use the command:

    wish ~/PG/alited/src/alited.tcl

In Linux, you can run *tclsh* instead of *wish*.

At the first start, *alited* offers selecting a configuration directory to hold its settings. By default, it is `~/.config`, where *alited* will create its `alited` subdirectory. This choice is recommended, because *alited* would not ask it again when started without an argument. Otherwise, the configuration directory should be passed to *alited* as an argument, this way:

    wish ~/PG/alited/src/alited.tcl ~/myconfig

... so that you can have a batch of configurations of *alited* at one machine, per each type of projects: public, private, protected...

Being written in pure Tcl/Tk 8.6, the *alited* needs only the core Tcl/Tk packages.

If you are a novice to Tcl/Tk 8.6, try and install it. Then try and install the  *alited* and its dependencies, noticing the messages of CLI. Let the installations be a sort of exercise in Tcl/Tk.

Still in Windows, it's enough to install [ActiveTcl](https://www.activestate.com/products/tcl) or [Magicsplat](https://www.magicsplat.com/tcl-installer) distribution.

In Linux, possibly you need to install the packages:

    tcl8.6
    tcllib
    tk8.6
    tklib
    tcl-tls
    tcl-vfs
    tclx8.4

As noticed above, the *alited is born for Tcl/Tk development only*, so it requires a basic Tcl/Tk knowledge and the installed Tcl/Tk packages.

No need for a stand-alone *alited executable*. Also, the open sources of *alited* may be used for a further customization.

# Inevitable blah-blah

The *alited* project started 1 March 2021 and as such isn't complete, perfect etc. And in no way and in no time it will be so.

In a sense, *alited* goes Tcl/Tk way, i.e. *not greatness but simple elegance*. As for programming, of course.

For now (15 May 2021), it's of version 0.6, which means 40% to its full aged v1.0.

As [Vasily Shukshin](https://en.wikipedia.org/wiki/Vasily_Shukshin)'s film says:

    - У меня просто не хватает...
    - И много не хватает?
    - У меня?
    - Да.
    - Процентов сорок.
    - Ого!

----

ROAD MAP of alited from v0.6 to v1.0:

    + recent files
    + go to line
    + for selected tabs: find/replace
    + for selected tabs: e_menu items (fossil.mnu, grep.mnu etc.)
    + general help in "Help" menu
    + move tree items by dnd
    + command completion
    + e_menu items for toolbar/menu
    + "backup to <project subdir>" option
    + fossil/git diff of a file
    + C syntax
    + all options of Preferences & Projects
    + comments & unit tree for code of alited
    + index.html on Github
