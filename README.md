# What's that

The *alited* stands for "a lite editor". Edited by *alited* are source files, mostly Tcl/Tk and a bit C.

The main idea of *alited* is "strict organization and light access to edited units".

The access to the required pieces of code is the main time waster at coding.

The time wastes result from a bad organization of source text, when the related parts are badly viewable and badly switchable between each other because of their inconsistent locations. The inconsistency arises after accumulating some bulk of code, IME after 40-50 editor pages.

By means of *alited*, the Tcl/Tk code is arranged in such manner that the related parts of it are located as close as possible, each in the appropriate branch of the code tree.

Thus, using *alited*, you become the architect of your own code, not only the writer of it.

The *alited* facilitates the maintenance of code as well, partly because of the code tree being a sort of documentation.

---

The code units are organized by means of special (though customized) hierarchical comments. The units are mostly procedures / methods / functions and are named accordingly. These are leaves of the code tree. However, any part of a source text may be isolated into a named branch of the tree.

No part of a source text can be outside of units, thus none of source lines is lost.

If some source lines cannot be recognized by those hierarchical comments as a unit, they are united in a unit with a generated name.

---

The units are accessible through:

   * the bar or tree of files of a current project
   * the tree of units of a current file
   * the list of favorite units of a current project

The units may be moved through the whole tree of units, to any level. The units may be deleted or added at any point of the tree. The tree facilitates a decision where to put a new procedure/method.

At adding a unit, a template can be selected from a list of customized templates (header comments, class, method, proc etc.). The unit's level is used for indenting the template.

Any unit of any file of a project can be marked/unmarked as favorite. Each project has its own list of favorites.

When developing a project, you deal with various types of problems and as such with various code units. So, you can need various favorite units for various problems, esp. when the problems tend to occur repeatedly. The *alited* allows you to save the current list of favorites under a "problem name", to return to it afterwards. Of course, you can remove a list from the saved ones.

The cursor's position in a unit is saved by *alited*, so that when you return to the unit, the cursor is at the saved position and you can continue to solve a problem related with this unit.

---

One feature is specific to Tcl, namely its treatment of braces which may spawn a stream of hardly detected errors. It can infuriate any Tcler. 

The *alited* provides facilities for a fast detection of troublesome units (procs and methods, in fact being the code tree's leaves). The troublesome units are marked with a color and a number of exceeding left/right braces.

The lines with various issues (not only inconsistent braces) can be marked in the appropriate units.

You can customize the run of Tcl/Tk files by *alited* with preliminary control of errors.

---

The [Ruff!](https://ruff.magicsplat.com) documentation generator requires the documentation comments being allocated in a proc's / method's body, right under its declaration.

There is another way of code documentation: writing the proc's / method's comments above the declaration.

The *alited* supports both methods of code documentation, which is achieved by "Settings" of

   * the hierarchical comments
   * the templates

The *alited* can serve as "code gardener" who does indenting and generating documentation comments of units.

The *proc* and *method* bodies of a "not-alited" source text can be supplied with these comments in "Initiation", to become converted to "alited".


# Features

Briefly, the *alited* allows to:

  * switch quickly between projects, files, code units, procedures and methods
  * rearrange (move/add/delete/rename/set a level) the code units as branches
  * rearrange (move/add/delete/sort) the procedures / methods as leaves of a branch
  * merge several units/leaves into one, if they are closely related 
  * divide a unit/leaf into several ones, at need
  * mark a unit as favorite
  * allow to have and choose several lists of favorites, named according to their purpose
  * for all projects, keep their own lists of favorites
  * at switching between units, restore their cursor positions
  * use a template with an appropriate indent at adding a new procedure / method / code unit
  * check code units (procedures and methods) for a consistency of braces
  * auto-check the consistency of braces at saving/leaving a currently edited procedure/method
  * employ other methods for error checking and code gardening
  * support two styles of documentation comments


# How's that

The unit separation is carried out with the hierarchical comments as follows:

`
 
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

      # These comments (# __name__ # ) are customized,
      # e.g. #=== NAME ===  may be used instead.

`

The *alited* recognizes the units by these comments and presents them as a tree.

This tree of units doesn't means anything like *code folding* or *structured editing* which refer to the Tcl structural commands like *if, switch, foreach, proc* and so on. The *alited* code tree results from the hierarchical comments only.

The code tree includes the *code units* as the branches and the *procedures / methods* as the leaves.

The *branches* and *leaves* are supplied with balloon tips to view their contents (declarations). These tips can be copied to the clipboard with the popup menu.

# Example

`

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

`

This example will produce the following code tree:

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
