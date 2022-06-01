
package ifneeded hl_tcl 0.9.40 [list source [file join $dir hl_tcl.tcl]]

# short intro (for Ruff! docs generator)

namespace eval ::hl_tcl {

  set _ruff_preamble {
The *hl_tcl* package is a syntax highlighter for Tcl/Tk code.

It can be applied to a *Tk text* widget or to a static html page.

The *Tk text* widget may be made read-only or editable. Also, the *hl_tcl* may take an argument, sort of command to watch the viewing / editing.

When applied to html pages, the *hl_tcl* highlights Tcl/Tk code snippets embedded between &lt;code&gt; &lt;/code&gt; tags.

The *hl_tcl* has highlighted its own code in [Reference](https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html).

## Some of blah-blah

The Tcl being incredibly dynamic language sets a lot of problems before any Tcl syntax highlighter. Probably, the usage of quotes and esp. the strings spanning several lines are the main challenges.

Below is a line that brings most (not *hl_tcl*, as seen in [Reference](https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html)) of Tcl highlighters in a stupor:

      if {[set i [string first {"} $line $i]]==-1} {return no}

... as well as this one:

      regsub -all {(([^A-Z@]|\\@)[.?!]("|'|'')?([])])?) } $fieldText {\1  } fieldText

Good luck for a highlighter when the second line (or similar) follows the first, giving it a matching quote and thus bringing it out of the stupor.

Those orphan quotes are often used in `regexp` and `regsub` Tcl commands, so that when a honest Tcl highlighter (like <a href="https://www.geany.org" title="Geany IDE">Geany</a>) stumbles upon an orphan quote, it tries its best to highlight the rest of code as a string, till the next unmatched quote.

Thus, we have

<img src="https://aplsimple.github.io/en/tcl/hl_tcl/files/hltcl1.png" class="media" alt="">

... instead of

<img src="https://aplsimple.github.io/en/tcl/hl_tcl/files/hltcl2.png" class="media" alt="">

There are "tricky" highlighters (like <a href="https://wiki.gnome.org/Apps/Gedit" title="Gedit editor">Gedit</a>) that behave more wisely at the stumbling an orphan quote: they permit only a one-line Tcl strings (if not continued with \\), so that the string highlighting would be most likely finished in the same line it started. No problems except for this silly line. And no delays due to the highlighting the rest of code...

... as seen in:

<img src="https://aplsimple.github.io/en/tcl/hl_tcl/files/hltcl3.png" class="media" alt="">

## Some of editors

<a href="https://www.geany.org" title="Geany IDE">Geany</a>. Probably, the best Tcl highlighter. And the great programming tool at that. Still, it has few drawbacks:

   * doesn't highlight the above mentioned Tcl lines properly
   * doesn't highlight `${var}` in contrast with `$var`
   * tries to highlight any (even hexidecimal) number it encounters, thus `set a 1fix` or `set b #abxxx` looks a bit peculiar
   * `set c {{#000} #FFF}` is quite a legal Tcl command as well as `set c {#000 #FFF}`, not for Geany
   * no highlighting TclOO (`method, mixin, my` etc.)

<a href="http://www.vim.org/" title="Vim editor">Vim</a>. Probably, the fastest Tcl highlighter. Great and awful. Nonetheless:

   * tricky with those above mentioned Tcl lines
   * doesn't highlight ttk commands (Tk only) and TclOO
   * tries to highlight every bit of Tcl, e.g. `set set set` is highlighted as three `set` commands ;)
   * as a result, much more florid than most of others

<a href="https://kate-editor.org" title="Kate editor">Kate</a>. As nearly good as Geany. As nearly florid as Vim (`set set set`). Doesn't highlight ttk and TclOO.

<a href="https://github.com/phase1geo/tke/" title="TKE editor">TKE</a>. Written in Tcl/Tk, it might be the best of all to highlight the Tcl/Tk. In spite of its suspended state it still can. Issues with highlighting strings and the performance.

<a href="http://mate-desktop.org" title="Pluma editor">Pluma</a> and <a href="https://wiki.gnome.org/Apps/Gedit" title="Gedit editor">Gedit</a> seem to use the same Tcl highlighting engine that gives rather good results. Still, the mentioned above drawbacks are here too. And no highlighting of tk, ttk, TclOO.

<a href="https://notepad-plus-plus.org/" title="Notepad++ official site">Notepad++</a>. Very fast Tcl highlighter. And very basic. All the same drawbacks. No highlighting of tk, ttk, TclOO. *Plus* an obsolete version of Tcl, i.e. no highlighting `lset, lassign` etc.

## What can we do?

To develop an ideal (correct and fast) Tcl/Tk highlighter, we would have to dive into Tcl core. Though, no hopes to achieve the ideal through repeating the core in Tcl/Tk or massively using the regular expressions.

That said, while implementing Tcl/Tk highlighter *in pure Tcl/Tk*, we might hope to achieve a reasonable compromise between the performance and the elimination of blunders.

It seems *hl_tcl* got close to this compromise. Specifically, it provides:

  * special highlighting for Tcl and TclOO commands
  * special highlighting for Tk and ttk commands
  * allowing additional commands to highlight (as Tk ones)
  * special highlighting for declarations `proc, method, oo::class` etc. as well as `return, yield`
  * special highlighting for `#comments`, `$variables`, `"strings"`, `-options`
  * in-line comments being recognized and thus highlighted only after `;#`
  * proper handling of most `regexp` and `regsub` expressions containing a quote
  * highlighting the multi-line strings, with possible switching this mode off (a-la Gedit) to improve the performance
  * customizing colors of the highlighting
  * highlighting viewable/editable *Tk text* widget and static html pages
  * good performance at editing 1000-4000 LOC and rather acceptable for 4000-9000 LOC
  * even monstrous 10000 LOC and more are handled fast at the "tricky" mode a-la Gedit

The *hl_tcl* doesn't provide the following:

  * highlighting *numbers*
  * highlighting *brackets*, except for matched ones and inside the strings

These are in no way critical drawbacks. A little less florid Tcl code might be even preferable for other tastes.

The Tcl can arrange its pitfalls for *hl_tcl* (I know where). Also, tricky practices or tastes can make a fool of *hl_tcl*. Still hopefully these pranks are few and rare to encounter.

## Use for text widget

The code below:

      package require hl_tcl

      proc ::stub {args} {puts "stub: $args"}

      ::hl_tcl::hl_init $::txt -readonly yes -cmd ::stub

      #... inserting a text into the text widget

      ::hl_tcl::hl_text $::txt

sets an example of *hl_tcl* usage. Here are the details:

  * **`::stub`** is a procedure to watch the text editing; here it simply puts out the text's last index;

  * **`hl_init`** is called *before* filling the text widget with a Tcl code; it sets the highlighting options and disables the highlighting till *hl_text* runs;

  * **`hl_text`** runs to highlight the Tcl code of the text widget and to view/edit it.

The **`hl_init`** takes arguments:

   * *txt* is the text widget's path
   * *args* contains options of text widget (omittable)

The *args* is a list of *-option "value"* where *-option* may be:

   * *-colors* - list of colors: clrCOM, clrCOMTK, clrSTR, clrVAR, clrCMN, clrPROC, clrOPT
   * *-dark* - flag "dark background of text", i.e. simplified *-colors* (default "no")
   * *-font* - attributes of text font
   * *-readonly* - flag "text is read-only" (default "no")
   * *-multiline* - flag "multi-line strings" (default "yes")
   * *-cmd* - command to watch editing/viewing (default "")
   * *-cmdpos* - command to watch cursor positioning (default "")
   * *-seen* - number of first lines seen at start (default 500)
   * *-optRE* - flag "use a regular expression to highlight options" (default "yes")
   * *-keywords* - additional commands to highlight (as Tk ones)

**Note**: `-seen 500` and `-multiline no` can improve the performance a lot. It's recommended to use `-seen 500` (or any other reasonable limit, e.g. `-seen 200`) at any rate, except for static html pages.

The rest of *hl_tcl* procedures are:

   *  **`hl_all `** updates all highlighted existing text widgets, e.g. at changing a color scheme of application
   *  **`hl_readonly`** gets/sets a read-only mode and/or a command to watch a text widget at viewing/editing it
   *  **`hl_colors`** gets a list of colors for highlighting

See details in [Reference](https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html).


## Use for static html

In the [hl_tcl.zip](https://chiselapp.com/user/aplsimple/repository/hl_tcl/download), there is a Tcl script named *tcl_html.tcl* that highlights Tcl snippets of static html page(s).

It runs as follows:

      tclsh tcl_html.tcl "glob-pattern-of-html-files"

For example:

      tclsh ~/UTILS/hl_tcl/tcl_html.tcl "~/UTILS/mulster/tasks/ruff/src/*"

In this example, the html files are located in `~/UTILS/mulster/tasks/ruff/src`.

Perhaps, you would want to modify the *tcl_html.tcl*, this way:

   * replace `"no"` with `"yes"` for dark html pages

   * replace `<code class="tcl">` with html tags *starting* the Tcl code in your html files

   * replace `</code>` with html tags *finishing* the Tcl code in your html files

These are arguments of `::hl_tcl_html::highlight` procedure.

The tag pairs can be multiple if the html pages contain them, e.g.

      ::hl_tcl_html::highlight $fhtml "no" \
          {<code class="tcl">} {</code>} \
          {<pre class="code">} {</pre>}

## Links

  * [Reference](https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html)

  * [Source](https://chiselapp.com/user/aplsimple/repository/hl_tcl/download) (hl_tcl.zip)

  * [Demo of hl_tcl v0.6.1](https://github.com/aplsimple/hl_tcl/releases/download/hl_tcl-0.6.1/hl_tcl-0.6.1.mp4) (25 Mb)

Note that [hl_tcl](https://aplsimple.github.io/en/tcl/hl_tcl/hl_tcl.html) is still disposed to update.
  }

}

namespace eval ::hl_tcl::my {

  set _ruff_preamble {
    The `::hl_tcl::my` namespace contains procedures for the "internal" usage by *hl_tcl* package.

    All of them are upper-cased, in contrast with the UI procedures of `hl_tcl` namespace.
  }
}
