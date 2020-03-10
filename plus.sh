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

cdpp_onexit="onexit.cd"
cdpp_onenter="onenter.cd"
cdpp_builtin=""

if [[ "$1" == "-o" ]] ; then 
    cdpp_builtin="builtin"
    shift
fi

cdpp_method="$1"
cdpp_targetfile="$2"

if [[ -z $cdpp_targetfile ]] ; then
    cdpp_targetfile=~
else 
    cdpp_targetfile=$(realpath $2)
fi

case $cdpp_method in
cd)
    if [[ -e $cdpp_targetfile && $cdpp_targetfile != $PWD* && -e $cdpp_onexit ]] ; then
        source $cdpp_onexit
    fi

    $cdpp_builtin cd $cdpp_targetfile

    if [[ $? == 0 && -e $cdpp_onenter && $OLDPWD != $PWD* ]] ; then
        source $cdpp_onenter
    fi
    ;;
pop)
    cdpp_stacksize=$(dirs -p | wc -l)
    if [[ $cdpp_stacksize -gt 1 ]] ; then
        cdpp_targetfile=$(dirs +1)
        if [[ $cdpp_targetfile != $PWD* && -e $cdpp_onexit ]] ; then
            source $cdpp_onexit
        fi
    fi

    $cdpp_builtin popd
    
    if [[ $? == 0 && -e $cdpp_onenter && $OLDPWD != $PWD* ]] ; then
        source $cdpp_onenter
    fi
    ;;
push)
    cdpp_targetfile=$2  #intentionally no quotes.
    if [[ -e $cdpp_targetfile && $cdpp_targetfile != $PWD* && -e $cdpp_onexit ]] ; then
        source $cdpp_onexit
    fi

    $cdpp_builtin pushd $cdpp_targetfile

    if [[ $? == 0 && -e $cdpp_onenter && $OLDPWD != $PWD* ]] ; then
        source $cdpp_onenter
    fi

    ;;
esac

unset ${!cdpp_@}
