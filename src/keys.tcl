###########################################################
# Name:    keys.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles hot keys settings & bindings.
# License: MIT.
###########################################################


namespace eval ::alited::keys {
  variable firstbind yes
}

# ________________________ Common _________________________ #

proc keys::BindKeys {wtxt type {asfind no}} {
  # Binds keys to appropriate events of text.
  #   wtxt - text's path
  #   type - type of keys (template etc.)
  #   asfind - do it for "find/replace" as well

  namespace upvar ::alited obPav obPav
  variable firstbind
  if {$firstbind || $asfind} {
    # some bindings must be active in "info" listbox, "find units" combobox and tree
    set activeForOthers [list ::tool: ::find:: ::file:: ::main::GotoLine ::bar::BAR]
    set w1 [$obPav LbxInfo]
    set w2 [$obPav CbxFindSTD]
    set w3 [$obPav Tree]
    set w4 $::alited::find::win
  }
  foreach kb [alited::keys::EngagedList $type all] {
    lassign $kb -> tpl keys tpldata
    if {[catch {
      if {[set i [string last - $keys]]>0} {
        set lt [string range $keys $i+1 end]
        if {[string length $lt]==1} {  ;# for lower case of letters
          lappend keys "[string range $keys 0 $i][string tolower $lt]"
        }
      }
      foreach k $keys {
        if {$type eq "template"} {
          lassign $tpldata tex pos place
          set tex [string map [list $::alited::EOL \n % %%] $tex]
          bind $wtxt "<$k>" [list ::alited::unit::InsertTemplate [list $tex $pos $place]]
        } elseif {$type eq "preference"} {
          set tpldata [string map [list %k $keys] $tpldata]
          {*}$tpldata
        } else {
          if {$firstbind || $asfind} {
            foreach afo $activeForOthers {
              if {[string first $afo $tpldata]>-1} {
                if {$asfind} {
                  bind $w4 "<$k>" $tpldata
                } else {
                  bind $w1 "<$k>" $tpldata
                  bind $w2 "<$k>" $tpldata
                  bind $w3 "<$k>" $tpldata
                }
                break
              }
            }
          }
          bind $wtxt "<$k>" $tpldata
        }
      }
    } err]} then {
      puts "Error of binding: $tpl <$keys> - $err"
    }
  }
  set firstbind no
}
#_______________________

proc keys::UnBindKeys {wtxt type} {
  # Clears key bindings of text.
  #   wtxt - text's path
  #   type - type of keys (template etc.)

  foreach kb [alited::keys::EngagedList $type all] {
    lassign $kb -> tpl keys tpldata
    if {[catch {
      set tpldata [::alited::ProcEOL $tpldata in]
      bind $wtxt "<$keys>" {}
    } err]} then {
      puts "Error of unbinding: $tpl <$keys> - $err"
    }
  }
}
#_______________________

proc keys::BindAllKeys {wtxt asfind} {
  # Binds all keys to appropriate events of text.
  #   wtxt - text's path
  #   asfind - do it for "find/replace" as well

  BindKeys $wtxt action $asfind
  BindKeys $wtxt template $asfind
  BindKeys $wtxt preference $asfind
}
#_______________________

proc keys::Test {klist} {
  # It's just for testing keys.
  #   klist - list of key combinations

  foreach k $klist {
    if {[catch {bind . "<$k>" "puts $k"} err]} {
      puts $err
    } else {
      puts "Valid key combination: $k"
    }
    catch {bind . "<$k>" {}}
  }
}

# _________________________ Lists of keys ________________________ #

proc keys::ReservedList {} {
  # Returns a list of keys reserved by alited.

  list \
    F1 \
    F10 \
    Control-A \
    Control-B \
    Control-C \
    Control-E \
    Control-F \
    Control-N \
    Control-O \
    Control-T \
    Control-V \
    Control-W \
    Control-X \
    Control-Z \
    Control-Alt-W \
    Control-Shift-Z \
    Control-Shift-F \
    Alt-Up \
    Alt-Down \
    Alt-Left \
    Alt-Right \
    Alt-F4
}
#_______________________

proc keys::UserList {} {
  # Returns a list of keys available to a user.

  namespace upvar ::alited al al
  set reserved [ReservedList]
  lappend reserved {*}[alited::edit::PluginAccelerator $al(MENUFORMATS)]
  foreach mod {"" Control- Alt- Shift- Control-Shift- Control-Alt-} {
    if {$mod ni {Control- Control-Alt-}} {
      foreach k {F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12} {
        set key "$mod$k"
        if {$key ni $reserved} {lappend res $key}
      }
    }
    if {$mod ni {"" "Shift-"}} {
      foreach k [split 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ {}] {
        set key "$mod$k"
        if {$key ni $reserved} {lappend res $key}
      }
    }
  }
  lappend res Control-bracketleft
  lappend res Control-bracketright
  lappend res Tab
  return $res
}
#_______________________

proc keys::EngagedList {{type ""} {mode "keyscont"}} {
  # Returns a list of keys engaged by a user.
  #   type - a type of keys ("template" etc.)
  #   mode - if "all", returns full info of keys; if "keysonly" - only key names; if "keyscont" - only key contents

  namespace upvar ::alited al al
  set res [list]
  foreach kb $al(KEYS,bind) {
    if {$type eq "" || $type eq [lindex $kb 0]} {
      switch $mode {
        all      {lappend res $kb}
        keysonly {lappend res [lindex $kb 2]}
        keyscont {lappend res [lrange $kb 2 3]}
      }
    }
  }
  return $res
}
#_______________________

proc keys::VacantList {} {
  # Returns a list of keys not yet engaged.

  set userlist [UserList]
  set englist [EngagedList {} keysonly]
  set res [list]
  foreach k $userlist {
    if {$k ni $englist} {lappend res $k}
  }
  return $res
}
# _______________________ Handling keys data _____________________ #

proc keys::ReservedAdd {} {
  # Saves reserved ("action") keys to a list of keys data.

  namespace upvar ::alited al al
  Add action exit-app     Alt-F4 {alited::Exit; break}
  Add action find-replace Control-F {alited::find::_run; break}
  Add action find-unit    Shift-Control-F {::alited::find::FindUnit; break}
  Add action new-file     Control-N {::alited::file::NewFile; break}
  Add action open-file    Control-O {::alited::file::OpenFile; break}
  Add action save-all     Shift-Control-S {::alited::file::SaveAll; break}
  Add action save-close   Control-W {::alited::file::SaveAndClose; break}
  Add action close-delete Control-Alt-W {::alited::file::CloseAndDelete; break}
  Add action help         F1 {alited::tool::Help}
  # other keys are customized in Preferences
  Add action save-file    [alited::pref::BindKey 0 - F2] ::alited::file::SaveFile
  Add action save-as      [alited::pref::BindKey 1 - Control-S] {::alited::file::SaveFileAs; break}
  Add action e_menu       [alited::pref::BindKey 2 - F4] alited::tool::e_menu3
  Add action run          [alited::pref::BindKey 3 - F5] alited::tool::_run
  Add action indent       [alited::pref::BindKey 6 - Control-I] {::alited::edit::Indent; break}
  Add action unindent     [alited::pref::BindKey 7 - Control-U] {::alited::edit::UnIndent; break}
  Add action comment      [alited::pref::BindKey 8 - Control-bracketleft] {::alited::edit::Comment; break}
  Add action uncomment    [alited::pref::BindKey 9 - Control-bracketright] {::alited::edit::UnComment; break}
  Add action find-next    [alited::pref::BindKey 12 - F3] alited::find::FindNext
  Add action look-declaration    [alited::pref::BindKey 13 - Control-L] "::alited::find::LookDecl ; break"
  Add action look-word    [alited::pref::BindKey 14 - Control-Shift-L] "::alited::find::SearchWordInSession ; break"
  Add action RESERVED     [alited::pref::BindKey 15 - F11] {+ ::apave::None}
  Add action play-macro   [alited::pref::BindKey 16 - F12] {+ ::alited::edit::DispatchMacro}
  Add action goto-line    [alited::pref::BindKey 17 - Control-G] {alited::main::GotoLine; break}
  Add action insert-line  [alited::pref::BindKey 18 - Control-P] {alited::main::InsertLine; break}
  if {$::alited::al(IsWindows)} {set i1 %s==0} {set i1 1}
  Add action autocomplete [alited::pref::BindKey 19 - Tab] [list + if $i1 {alited::complete::AutoCompleteCommand; break}]
  Add action goto-bracket [alited::pref::BindKey 20 - Alt-B] {alited::main::GotoBracket; break}
  Add action file-list [alited::pref::BindKey 21 - F9] {alited::bar::BAR popList %X %Y; break}
  Add action run-file [alited::pref::BindKey 22 - Shift-F5] $al(runAsIs)
}
#_______________________

proc keys::Add {type name keys cont} {
  # Adds an item to a list of keys data.
  #   type - type of key
  #   name - name of item
  #   keys - key combination
  #   cont - contents (data of binding)

  namespace upvar ::alited al al
  if {[string trim $keys] ne {}} {
    set item [list $type $name $keys $cont]
    if {[set i [Search $type $name]]>-1} {
      set al(KEYS,bind) [lreplace $al(KEYS,bind) $i $i $item]
    } else {
      lappend al(KEYS,bind) $item
    }
  }
}
#_______________________

proc keys::Delete {type {name ""}} {
  # Deletes an item from a list of keys data.
  #   type - type of key
  #   name - name of item

  namespace upvar ::alited al al
  set deleted 0
  while {[set i [Search $type $name]]>-1} {
    set al(KEYS,bind) [lreplace $al(KEYS,bind) $i $i]
    incr deleted
  }
  return $deleted
}
#_______________________

proc keys::Search {type name} {
  # Searches an item in a list of keys data.
  #   type - type of key
  #   name - name of item

  namespace upvar ::alited al al
  set i 0
  foreach kb $al(KEYS,bind) {
    lassign $kb t n n2
    if {($type eq {} || $t eq $type) && ($name eq {} || $name eq $n || $name eq $n2)} {
      return $i
    }
    incr i
  }
  return -1
}

# _________________________________ EOF _________________________________ #
