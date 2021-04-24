#! /usr/bin/env tclsh
# _______________________________________________________________________ #
#
# The hot keys procedures.
# _______________________________________________________________________ #

namespace eval ::alited::keys {
}

proc keys::ReservedList {} {
  return [list \
    F1 \
    F2 \
    F3 \
    F4 \
    F5 \
    F11 \
    F12 \
    Control-A \
    Control-C \
    Control-D \
    Control-F \
    Control-I \
    Control-M \
    Control-N \
    Control-O \
    Control-R \
    Control-S \
    Control-U \
    Control-V \
    Control-W \
    Control-X \
    Control-Y \
    Control-Z \
    Control-Shift-Z \
    Alt-Q \
    Alt-W \
    Alt-Up \
    Alt-Down \
    Alt-Left \
    Alt-Right \
    Alt-F4 \
    Return \
    Escape \
  ]
}

proc keys::UserList {} {
  set reserved [ReservedList]
  foreach mod {"" Control- Alt- Shift- Control-Alt-} {
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
  return $res
}

proc keys::VacantList {} {
  set userlist [UserList]
  set englist [EngagedList "" keysonly]
  set res [list]
  foreach k $userlist {
    if {$k ni $englist} {lappend res $k}
  }
  return $res
}

proc keys::EngagedList {{type ""} {mode "keyscont"}} {
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

proc keys::ReservedAdd {wtxt} {
  namespace upvar ::alited obPav obPav
  Add action "find-replace" Control-F {alited::find::_run; break}
  Add action "new-file"     Control-N {::alited::file::NewFile; break}
  Add action "open-file"    Control-O {::alited::file::OpenFile; break}
  Add action "indent"       Control-I {::alited::unit::Indent; break}
  Add action "unindent"     Control-U {::alited::unit::UnIndent; break}
  Add action "comment"      Control-bracketleft {::alited::unit::Comment; break}
  Add action "uncomment"    Control-bracketright {::alited::unit::UnComment; break}
  Add action "save-as"      Control-S {::alited::file::SaveFileAs; break}
  Add action "save-all"     Shift-Control-S {::alited::file::SaveAll; break}
  Add action "save-close"   Control-W {::alited::file::SaveFileAndClose; break}
  Add action "help"         F1 {alited::tool::Help}
  Add action "save-file"    F2 {::alited::file::SaveFile}
  Add action "find-next"    F3 "$obPav findInText 1 $wtxt"
  Add action "e_menu"       F4 {alited::tool::e_menu}
  Add action "run"          F5 {alited::tool::Run}
  Add action "item-up"      F11 {+ ::alited::main::MoveItem up yes}
  Add action "item-down"    F12 {+ ::alited::main::MoveItem down yes}
}

proc keys::Add {type name keys cont} {
  namespace upvar ::alited al al
  if {[string trim $keys] ne ""} {
    set item [list $type $name $keys $cont]
    if {[set i [Search $type $name]]>-1} {
      set al(KEYS,bind) [lreplace $al(KEYS,bind) $i $i $item]
    } else {
      lappend al(KEYS,bind) $item
    }
  }
}

proc keys::Delete {type {name ""}} {
  namespace upvar ::alited al al
  set deleted 0
  while {[set i [Search $type $name]]>-1} {
    set al(KEYS,bind) [lreplace $al(KEYS,bind) $i $i]
    incr deleted
  }
  return $deleted
}

proc keys::Search {type name} {
  namespace upvar ::alited al al
  set i 0
  foreach kb $al(KEYS,bind) {
    lassign $kb t n
    if {$t eq $type && ($name eq "" || $n eq $name)} {return $i}
    incr i
  }
  return -1
}

proc keys::BindKeys {wtxt type} {
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
        } else {
          bind $wtxt "<$k>" $tpldata
        }
      }
    } err]} then {
      puts "Error of binding: $tpl <$keys> - $err"
    }
  }
}

proc keys::UnBindKeys {wtxt type} {
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

proc keys::Test {klist} {
  # testing
  foreach k $klist {
    if {[catch {bind . "<$k>" "puts $k"} err]} {
      puts $err
    } else {
      puts "Valid key combination: $k"
    }
    catch {bind . "<$k>" {}}
  }
}

# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl
