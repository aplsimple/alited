# What's that

The *alited* stands for "a lite editor".

The main features of *alited* are:

  * structured code 
  * easy access to the code
  * born for Tcl/Tk development only

Edited by *alited* are Tcl/Tk files. The C code might be a next target of *alited*, still for *Tcl/Tk development only* all the same.

The *alited* facilitates the development and the maintenance of Tcl/Tk code, partly because of the unit tree being a sort of documentation.

Below is a screenshot of *alited v0.6*:

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

These comments are customized (TODO for now), e.g. #=== NAME ===  may be used instead.

The *alited* recognizes the units by these comments and presents them as a tree.

This tree of units doesn't means anything like *code folding* or *structured editing* which refer to the Tcl structural commands like *if, switch, foreach, proc* and so on. The *alited* unit tree results from the hierarchical comments only.

The unit tree includes the *code units* as the branches and the *procedures / methods* as the leaves.

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

And here the *alited* comes to help.

# Bonuses

At adding a unit, a template can be selected from a list of customized templates.

A long unit can be detected by its "red bar" icon in the unit tree, as seen in the screenshots above. The "redness" is customized (TODO for now). I.e. when a unit is too long, it's marked red.

The *alited* allows to check code units (procedures and methods) for a consistency of braces etc. By clicking a line in the list of errors, you can go to the appropriate unit.

In a session, the cursor's position of a unit is saved by *alited*, so that when you return to the unit, the cursor is at the saved position and you can continue to solve a problem of this unit.

Press Ctrl-Click on a word to go a proc/method declaration.

Press Ctrl-Shift-Click on a word to look for the word instances around the session.

The *branches* and *leaves* of the unit tree are supplied with balloon tips to view their contents (declarations). These tips can be copied to the clipboard with the popup menu.

Any unit of any file of a project can be marked/unmarked as *favorite*. Each project has its own list of favorites.

While developing a project, you deal with various types of problems and as such with various code units. So, you can need various favorite units for various problems, esp. when the problems tend to occur repeatedly.

In the utmost case, you might need subprojects inside your project. Various "child" packages inside a "parent" one and so on.

The *alited* allows you to save the current list of favorites to the *lists of favorites* under a "problem/issue/subproject name".

Thus, you can have *projects inside project*.

The *last visited* list is a comrade of the favorites. It allows fast access to the last visited units (only when they are visited through the unit tree - this is *a restriction for now*).

In a session, the visited units are highlighted in the unit tree, so that you can see which of them were visited.

When you select a file to edit, it becomes the first one (if not visible yet) in the bar of file tabs. So that you have the last edited files be first in the bar of files.

Press Ctrl-Tab to switch between *last two* edited files.

"Last visited is most needed."

The F1 key is used to call a context Tcl/Tk help. Set the cursor on a Tcl/Tk command and press F1 and you'll get the help on the command. Still, for this you should download the Tcl/Tk help into ~/DOC directory by the commands:

    mkdir ~/DOC
    cd ~/DOC
    wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/

# How that's installed

The installation of *alited* is straightforward:

  * download [alited.zip](https://chiselapp.com/user/aplsimple/repository/alited/zip/trunk/alited.zip)

  * unpack *alited.zip* to some directory, say ~/PG/alited

  * to run the installed *alited*, use the command:

    wish ~/PG/alited/src/alited.tcl

In Linux, you can run *tclsh* instead of *wish*.

Being written in pure Tcl/Tk 8.6, the *alited* needs only the core Tcl/Tk packages.

If you are a novice to Tcl/Tk 8.6, try and install it. Then try and install the  *alited* and its dependencies, noticing the messages of CLI. Let the installations be a sort of exercise in Tcl/Tk.

As noticed above, the *alited is born for Tcl/Tk development only*, so it requires a basic Tcl/Tk knowledge and the installed Tcl/Tk packages.

No need for a stand-alone *alited executable*. Also, the open sources of *alited* may be used for a further customization.

# Inevitable blah-blah

The *alited* project started 1 March 2021 and as such isn't complete, perfect etc. And in no way and in no time it will be so.

In a sense, *alited* goes Tcl/Tk way, i.e. *nothing of greatness but all you need*.

For now (15 May 2021), it's of version 0.6, which means 40% to its full aged v1.0.

As [Vasily Shukshin](https://en.wikipedia.org/wiki/Vasily_Shukshin)'s film says:

    - У меня просто не хватает...
    - И много не хватает?
    - У меня?
    - Да.
    - Процентов сорок.
    - Ого!