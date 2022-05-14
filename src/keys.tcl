###########################################################
# Name:    keys.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles hot keys settings & bindings.
# License: MIT.
###########################################################


namespace eval ::alited::keys {
}

# ________________________ Common _________________________ #

proc keys::BindKeys {wtxt type} {
  # Binds keys to appropriate events of text.
  #   wtxt - text's path
  #   type - type of keys (template etc.)

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
          bind $wtxt "<$k>" $tpldata
        }
      }
    } err]} then {
      puts "Error of binding: $tpl <$keys> - $err"
    }
  }
}
#_______________________

proc keys::UnBindKeys {wtxt type} {
  # Clears key bindings of text.
  #   wtxt - text's path
  #   type - type of keys (template etc.)

  foreach kb [alited::keys::EngagedList $type all] {
    lassign $kb -> tpl keys tpldata
    if {[catch {
      set tpldata [string map [list $::alited::EOL \n] $tpldata]
      bind $wtxt "<$keys>" {}
    } err]} then {
      puts "Error of unbinding: $tpl <$keys> - $err"
    }
  }
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

  return [list \
    F1 \
    F10 \
    Control-A \
    Control-C \
    Control-F \
    Control-M \
    Control-N \
    Control-O \
    Control-R \
    Control-V \
    Control-W \
    Control-X \
    Control-Z \
    Control-Shift-Z \
    Control-Shift-F \
    Alt-Up \
    Alt-Down \
    Alt-Left \
    Alt-Right \
    Alt-F4
  ]
}
#_______________________

proc keys::UserList {} {
  # Returns a list of keys avalable to a user.

  set reserved [ReservedList]
  foreach mod {"" Control- Alt- Shift- Control-Shift- Control-Alt-} {
    if {$mod ni {Control- Control-Alt-}} {
      foreach k {F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12} {
        set key "$mod$k"
        if {$key ni $reserved} {lappend res $key}
      }
    }
    if {$mod ni {"" "Shift-"}} {
      foreach k {0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} {
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

proc keys::ReservedAdd {wtxt} {
  # Saves reserved ("action") keys to a list of keys data.

  namespace upvar ::alited obPav obPav
  Add action find-replace Control-F {alited::find::_run; break}
  Add action find-unit    Shift-Control-F {::alited::find::FindUnit; break}
  Add action new-file     Control-N {::alited::file::NewFile; break}
  Add action open-file    Control-O {::alited::file::OpenFile; break}
  Add action save-all     Shift-Control-S {::alited::file::SaveAll; break}
  Add action save-close   Control-W {::alited::file::SaveFileAndClose; break}
  Add action help         F1 {alited::tool::Help}
  # other keys are customized in Preferences
  Add action save-file    [alited::pref::BindKey 0 - F2] {::alited::file::SaveFile}
  Add action save-as      [alited::pref::BindKey 1 - Control-S] {::alited::file::SaveFileAs; break}
  Add action e_menu       [alited::pref::BindKey 2 - F4] {alited::tool::e_menu o=0}
  Add action run          [alited::pref::BindKey 3 - F5] {alited::tool::_run}
  Add action indent       [alited::pref::BindKey 6 - Control-I] {::alited::edit::Indent; break}
  Add action unindent     [alited::pref::BindKey 7 - Control-U] {::alited::edit::UnIndent; break}
  Add action comment      [alited::pref::BindKey 8 - Control-bracketleft] {::alited::edit::Comment; break}
  Add action uncomment    [alited::pref::BindKey 9 - Control-bracketright] {::alited::edit::UnComment; break}
  Add action find-next    [alited::pref::BindKey 12 - F3] "$obPav findInText 1 $wtxt"
  Add action look-declaration    [alited::pref::BindKey 13 - Control-L] "::alited::find::SearchUnit ; break"
  Add action look-word    [alited::pref::BindKey 14 - Control-Shift-L] "::alited::find::SearchWordInSession ; break"
  Add action item-up      [alited::pref::BindKey 15 - F11] {+ ::alited::tree::MoveItem up yes}
  Add action item-down    [alited::pref::BindKey 16 - F12] {+ ::alited::tree::MoveItem down yes}
  Add action goto-line    [alited::pref::BindKey 17 - Control-G] {alited::main::GotoLine; break}
  Add action insert-line  [alited::pref::BindKey 18 - Control-P] {alited::main::InsertLine; break}
  Add action autocomplete [alited::pref::BindKey 19 - Tab] {alited::complete::AutoCompleteCommand; break}
  Add action goto-bracket [alited::pref::BindKey 20 - Alt-B] {alited::main::GotoBracket; break}
  Add action file-list [alited::pref::BindKey 21 - F9] {alited::bar::BAR popList %X %Y; break}
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
    if {($type eq "" || $t eq $type) && ($name eq "" || $name eq $n || $name eq $n2)} {
      return $i
    }
    incr i
  }
  return -1
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl LOG=~/TMP/alited-DEBUG.log DEBUG
