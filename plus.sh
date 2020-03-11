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


function cdpp_onenter_hook {
    if [[ -e $cdpp_onenter ]] ; then
        source $cdpp_onenter
    fi
}

function cdpp_onexit_hook {
    if [[ -e $cdpp_onexit ]] ; then
        source $cdpp_onexit
    fi
}


# arguments:
#   1. targetdirectory
# assumes argument is a valid target
function cdpp_traverse {
    IFS="/" read -a cdpp_targetfile_break <<< "$1"
    cdpp_currentdir=$PWD
    if [[ -z ${cdpp_targetfile_break[0]} ]] ; then
        # echo absolute
        # Absolute filepath
        while [[ $1 != $cdpp_currentdir* ]] ; do
            cdpp_onexit_hook
            $cdpp_builtin cd ..
            cdpp_currentdir=$PWD
        done

        IFS="/" read -a cdpp_tmp <<< "$cdpp_currentdir"
        cdpp_currentdir_depth=${#cdpp_tmp[@]}
        cdpp_targetfile_trimmed=${cdpp_targetfile_break[@]:$cdpp_currentdir_depth}

        for dir in ${cdpp_targetfile_trimmed[@]} ; do
            $cdpp_builtin cd $dir
            cdpp_onenter_hook
        done
    else
        # echo relative
        # relative filepath
        for dir in ${cdpp_targetfile_break[@]} ; do
            if [[ "$dir" == ".." ]] ; then
                cdpp_onexit_hook
            fi

            $cdpp_builtin cd $dir
            
            if [[ "$dir" != ".." ]] ; then
                cdpp_onenter_hook
            fi
        done
    fi
}



cdpp_method="$1"
cdpp_targetfile=$2

case $cdpp_method in
cd)
    if [[ ! -d $cdpp_targetfile ]] ; then
        # we want this to fail like a normal cd, so attempt without activating hooks
        $cdpp_builtin cd $cdpp_targetfile
    else 
        # we know the target is valid, so we can start activating hooks
        cdpp_traverse $cdpp_targetfile
    fi
    ;;
pop)
    # ensure there is a directory to pop to
    cdpp_stacksize=$(dirs -p | wc -l)
    if [[ $cdpp_stacksize -gt 1 ]] ; then
        cdpp_targetfile=$(dirs +1)
        # Adding eval resolves any "~" in filepath, making it always act like an absolute traversal
        cdpp_traverse $(eval echo "$cdpp_targetfile")
    fi

    # does nothing on success, generates proper error on failure
    $cdpp_builtin popd
    ;;
push)
    # fails on cdpp_targetfile being empty or invalid
    $cdpp_builtin pushd $cdpp_targetfile

    # if it worked, revert to the $OLDPWD, then traverse
    if [[ $? == 0 ]] ; then
        $cdpp_builtin cd $OLDPWD
        cdpp_traverse $cdpp_targetfile
    fi
    ;;
esac

unset ${!cdpp_@}
