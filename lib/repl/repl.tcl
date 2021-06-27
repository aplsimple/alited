#
# repl - a package for Tcl command completion
# (c) 2018 Ashok P. Nadkarni
# See file LICENSE for licensing terms
#
# Credits: thanks to tkcon and various Wiki snippets

package require Tcl 8.6

namespace eval repl {}

proc repl::complete_command {prefix {ip {}} {ns ::}} {
    # Finds all command names with the specified prefix
    #  prefix - a prefix to be matched with command names
    #  ip     - the interpreter whose context is to be used.
    #           Defaults to current interpreter.
    #  ns     - the namespace context for the command. Defaults to
    #           the global namespace if unspecified or the empty string.
    #
    # The command looks for all commands in the specified
    # interpreter and namespace context that begin with $prefix.
    #
    # The return value is a pair consisting of the longest common
    # prefix of all matching commands and a sorted list of all matching
    # commands.
    # If no commands matched, the first element is the passed in prefix
    # and the second element is an empty list.

    # Escape glob special characters in the prefix
    set esc_prefix [string map {* \\* ? \\? \\ \\\\} $prefix]

    if {$ns eq ""} {
        set ns ::
    }

    # Look for matches in the target context
    set matches [evaluate $ip $ns ::info commands ${esc_prefix}*]
    return [_return_matches $prefix $matches]
}

proc repl::complete_variable {prefix {ip {}} {ns ::}} {
    # Finds all variable names with the specified prefix
    #  prefix - a prefix to be matched with variable names
    #  ip     - the interpreter whose context is to be used.
    #           Defaults to current interpreter.
    #  ns     - the namespace context for the command. Defaults to
    #           the global namespace if unspecified or the empty string.
    #
    # The command looks for variable names in the specified
    # interpreter and namespace context that begin with $prefix.
    #
    # The return value is a pair consisting of the longest common
    # prefix of all matching commands and a sorted list of all matching
    # names.
    # If no variable names matched, the first element is the passed in prefix
    # and the second element is an empty list.

    # Escape glob special characters in the prefix
    set esc_prefix [string map {* \\* ? \\? \\ \\\\} $prefix]

    if {$ns eq ""} {
        set ns ::
    }

    # If $prefix is a partial array variable, the matching is done
    # against the array variables
    # Thanks to tkcon for this fragment
    if {[regexp {([^\(]*)\((.*)} $prefix -> arr elem_prefix]} {
        # Escape glob special characters
        set esc_elem [string map {* \\* ? \\? \\ \\\\} $elem_prefix]
        set elems [evaluate $ip $ns ::array names $arr ${esc_elem}*]
        if {[llength $elems] == 1} {
	    set var "$arr\([lindex $elems 0]\)"
            return [list $var [list $var]]
	} elseif {[llength $elems] > 1} {
            set common [tcl::prefix longest $elems $elem_prefix]
            set elems [lmap elem $elems {
                return -level 0 "$arr\($elem\)"
            }]
            return [list "$arr\($common" [lsort $elems]]
        }
        # Nothing matched
        return [list $prefix {}]
    } else {
        # Does not look like an array
        set matches [evaluate $ip $ns ::info vars ${esc_prefix}*]
        return [_return_matches $prefix $matches]
    }
}

proc repl::complete_namespace {prefix {ip {}} {ns ::}} {
    # Finds all namespace names with the specified prefix
    #  prefix - a prefix to be matched with the namespace names in target interpreter
    #  ip     - the target interpreter whose context is to be used.
    #           Defaults to current interpreter.
    #  ns     - the namespace context for the command. Defaults to
    #           the global namespace if unspecified or the empty string.
    #
    # The command looks for namespaces in the specified
    # interpreter and namespace context that begin with $prefix.
    #
    # The return value is a pair consisting of the longest common
    # prefix of all matching namespace names and a sorted list of all
    # matching names.  If no namespaces match, the first element is
    # the passed in prefix and the second element is an empty list.

    # Escape glob special characters in the prefix
    set esc_prefix [string map {* \\* ? \\? \\ \\\\} $prefix]

    if {$ns eq ""} {
        set ns ::
    }

    # Look for matches in the target context. 
    set matches [lmap fqn [evaluate $ip :: ::namespace children $ns ${esc_prefix}*] {
        namespace tail $fqn;    # We do not want fully qualified names
    }]

    return [_return_matches $prefix $matches]
}

proc repl::complete_method {oo obj prefix {ip {}} {ns ::}} {
    # Finds all method names with the specified prefix for a given TclOO object
    #  oo     - the OO subsystem, one of 'oo', 'nsf', 'xotcl'
    #  obj    - object name token
    #  prefix - a prefix to be matched with the object's method names
    #  ip     - the interpreter whose context is to be used.
    #           Defaults to current interpreter.
    #  ns     - the namespace context for the command. Defaults to
    #           the global namespace if unspecified or the empty string.
    #
    # The command looks for all methods of the object in the specified
    # interpreter and namespace context that begin with $prefix.
    #
    # The return value is a pair consisting of the longest common
    # prefix of all matching methods and a sorted list of all matching
    # methods.  If $obj is not a TclOO object or if no methods
    # matched, the first element is the passed in prefix and the
    # second element is an empty list.

    if {$ns eq ""} {
        set ns ::
    }

    #ruff
    # The $obj argument may be the object name or passed in through
    # a variable reference.
    if {[string index $obj 0] eq "\$"} {
        # Resolve the variable reference
        set obj [evaluate $ip $ns set [string range $obj 1 end]]
    }
    
    # Escape glob special characters in the prefix
    set esc_prefix [string map {* \\* ? \\? \\ \\\\} $prefix]

    set matches {}
    switch -exact $oo {
        ensemble {
            # TBD - method may not appear directly after ensemble command
            # in two cases:
            #   - when -params is configured
            #   - nested ensemble
            # Perhaps in this case "obj" should be treated as a command prefix
            # consisting of one or more words.
            if {[evaluate $ip $ns ::namespace ensemble exists $obj]} {
                set matches [_ensemble_methods $esc_prefix $obj $ip $ns]
            }
        }
        oo {
            if {![evaluate $ip $ns ::info object isa object $obj]} {
                # Not an object.
                return [list $prefix {}]
            }

            set matches [lmap meth [evaluate $ip $ns ::info object methods $obj -all] {
                if {![string match ${esc_prefix}* $meth]} continue
                set meth
            }]
        }
        snit {
            TBD
        }
        nsf {
            # Next Scripting Framework
            if {[evaluate $ip $ns ::nsf::object::exists $obj]} {
                if {[string match ::* $prefix]} {
                    # NSF allows dispatch of unregistered methods via absolute paths
                    set abs_matches [evaluate $ip $ns ::info commands ${esc_prefix}*]
                    set ns_matches  [evaluate $ip $ns ::namespace children [namespace qualifiers ${esc_prefix}] ${esc_prefix}*]
                    set matches [concat $abs_matches $ns_matches]
                } else {
                    set matches [evaluate $obj ::nsf::methods::object::info::lookupmethods -callprotection public -path -- ${esc_prefix}*]
                }
            } 
        }
        xotcl {
            # XOTcl
            if {[evaluate $ip $ns ::info exists ::xotcl::version] &&
                [evaluate $ip $ns ::xotcl::Object isobject $obj]} {
                set matches [evaluate $ip $ns $obj info methods ${esc_prefix}*]
            }
        }
    }

    return [_return_matches $prefix $matches]
}

# Just a helper proc for constructing return values from match commands
proc repl::_return_matches {prefix matches} {
    if {[llength $matches] == 1} {
        # Single element list. Only one match found
        return [list [lindex $matches 0] $matches]
    } elseif {[llength $matches] > 1} {
        # Multiple matches. Return longest common prefix.
        # Note we need to use $prefix and not $esc_prefix here.
        return [list [tcl::prefix longest $matches $prefix] [lsort $matches]]
    } else {
        return [list $prefix {}]
    }
}

# Collect ensemble methods (subcommands)
proc repl::_ensemble_methods {esc_prefix cmd {ip {}} {ns ::}} {
    set methods [evaluate $ip $ns ::namespace ensemble configure $cmd -subcommands]
    if {[llength $methods] == 0} {
        # Subcommands either defined through the map option or all exported
        # commands.
        set map [evaluate $ip $ns ::namespace ensemble configure $cmd -map]
        if {[dict size $map] == 0} {
            # No map defined. Get exported commands from namespace
            set ens_ns [evaluate $ip $ns ::namespace ensemble configure $cmd -namespace]
            set methods [evaluate $ip $ens_ns ::namespace export]
        } else {
            set methods [dict keys $map]
        }
    }

    # esc_prefix is expected to be glob-escaped
    return [lmap meth $methods {
        if {![string match ${esc_prefix}* $meth]} continue
        set meth
    }]
}

# Helper to evaluate commands in the target interpreter namespace
proc repl::evaluate {ip ns args} {
    return [interp eval $ip [list namespace eval $ns $args]]
}

namespace eval repl {
    namespace ensemble create -command complete -map {
        command complete_command
        variable complete_variable
        namespace complete_namespace
        method complete_method
    }
}
