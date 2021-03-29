

# What is this?


The `doctest_of_emenu.tcl` is nearly the same as the `plugins/doctest/doctest.tcl`.

The main difference is that `doctest_of_emenu.tcl` is run from e_menu plugin, i.e. outside of TKE in a separate process from menus:

  menu.mnu --> utils.mnu --> test1.mnu

This allows you to doctest a file that cannot be tested inside TKE.

Further details:

https://aplsimple.github.io/en/tcl/doctest

