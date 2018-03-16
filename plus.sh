#!/bin/bash
#ch.sh

# Notes for future self: 
# To delete a variable, use `unset`
# To delete a functions, use `unset -f`
#
# It is stongly recommended to not take irreversible actions without
# being completely certain of the side effects (e.g. file operations). 
# Also, to preserve the sense of flow that comes from changing directories, 
# it is highly recommended to eliminate non-critical output.
#
# It is, however, recommended that you preserve any diagnostic information.
# This includes, but is not limited to: errors and warnings. Logging and 
# debugging are also options, but are not recommended outside of testing.
# It is recommended to keep any such output to a minimum in practical 
# settings. However, this is a recommendation only, and can readily be 
# set aside, given proper reasoning.
#
####!WARNING!#######!WARNING!#######!WARNING!#######!WARNING!#######!WARNING!###
# NEVER, I repeat, NEVER run ANYTHING that requires root access. This script   #
# is intended as a convenience, and has some very obvious security holes that  #
# cannot be fixed without a great deal of effort; far more than it is possibly #
# worth. If you need a robust automation system, there are plenty out there.   #
####!WARNING!#######!WARNING!#######!WARNING!#######!WARNING!#######!WARNING!###

onexit="onexit.cd"
onenter="onenter.cd"

override=false

if [[ "$1" == "-o" ]] ; then 
    override=true
    shift
fi

# options: cd, pop, push
method="$1"

case $method in
pop)
    stack_size=$(dirs -p | wc -l)
    if [[ $stack_size -gt 1 && -e "$onexit" ]] ; then
        source "$onexit"
    fi
    
    if $override ; then
        builtin popd
    else
        popd
    fi

    if [[ $? -eq 0 && -e "$onenter" ]] ; then
        source "$onenter"
    fi
    ;;
push)
    if [[ -e "$2" && -e "$onexit" ]] ; then
        source "$onexit"
    fi

    if $override ; then
        if [[ "$2" == "" ]] ; then
            builtin pushd
        else
            builtin pushd "$2"
        fi
    else
        if [[ "$2" == "" ]] ; then
            pushd
        else
            pushd "$2"
        fi
    fi
    
    if [[ $? -eq 0 && -e "$onenter" ]] ; then
        source "$onenter"
    fi
    ;;
cd)
    if [[ -e "$2" && -e "$onexit" ]] ; then
        source "$onexit"
    fi


    if $override ; then
        if [[ "$2" == "" ]] ; then
            builtin cd
        else
            builtin cd "$2"
        fi
    else
        if [[ "$2" == "" ]] ; then
            cd
        else
            cd "$2"
        fi
    fi

    if [[ $? -eq 0 && -e "$onenter" ]] ; then
        source "$onenter"
    fi
    ;;
*)
    echo "Invalid directory change method provided" >&2
    ;;
esac
