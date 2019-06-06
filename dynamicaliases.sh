# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# Copyright (c) 2019, Colin Miller

# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.

#USAGE:
# c aliasname - runs the chosen alias
# cs aliasname <command> - saves the given command to the given alias
# ci aliasname - inspect (print out) the alias
# cl - list all aliases
# cdel aliasname - delete the given alias

# setup the file to store aliases
if [ ! -n "$ALIASES" ]; then
    ALIASES=~/.saliases
fi
touch $ALIASES

RED="0;31m"
GREEN="0;33m"

# save current directory to bookmarks
function cs {
    check_help_c $1
    _alias_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line_c "$ALIASES" "export ALIAS_$1="
        shift;
        COMMAND=$@
        echo "export ALIAS_$1=\"$COMMAND\"" >> $ALIASES
    fi
}

# run a given alias
function c {
    check_help_c $1
    source $ALIASES
    target="$(eval $(echo echo $(echo \$ALIAS_$1)))"
    echo "$target"
    eval $target
}

# inspect alias
function ci {
    check_help $1
    source $ALIASES
    echo "$(eval $(echo echo $(echo \$ALIAS_$1)))"
}

# delete alias
function cdel {
    check_help_c $1
    _alias_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$ALIASES" "export ALIAS_$1="
        unset "ALIAS_$1"
    fi
}

# list aliases with commands
function cl {
    check_help $1
    source $ALIASES

    env | sort | awk '/^ALIAS_.+/{split(substr($0,7),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
}

# list aliases without commands
function _cl {
    source $ALIASES
    env | grep "^ALIAS_" | cut -c7- | sort | grep "^.*=" | cut -f1 -d "="
}

# validate alias name
function _alias_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="alias name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="alias name is not valid"
        echo $exit_message
    fi
}

# completion command
function _comp_c {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_cl`' -- $curw))
    return 0
}

# ZSH completion command
function _compzsh_c {
    reply=($(_cl))
}

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
    compctl -K _compzsh_c c
    compctl -K _compzsh_c ci
    compctl -K _compzsh_c cdel
else
    shopt -s progcomp
    complete -F _comp_c c
    complete -F _comp_c ci
    complete -F _comp_c cdel
fi

# print out help for the forgetful
function check_help_c {
    if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 'cs   <alias_name> <command> - Saves the given command as "alias_name"'
        echo 'c    <alias_name>           - Runs the command associated with "alias_name"'
        echo 'ci   <alias_name>           - Inspect the alias associatd with "alias_name"'
        echo 'cdel <alias_name>           - Deletes the alias'
        echo 'cl                          - Lists all available aliases'
        kill -SIGINT $$
    fi
}

# safe delete line from saliases
function _purge_line_c {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t dynamicaliases.XXXXXX) || exit 1
        trap "rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        mv "$t" "$1"

        # cleanup temp file
        rm -f -- "$t"
        trap - EXIT
    fi
}
