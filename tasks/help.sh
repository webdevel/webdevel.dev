#!/usr/bin/env sh

# Makefile.help shell-script functions

EXAMPLES="
    $0 -f printMakefileHelp -p \"Makefile tasks/help.mk tasks/docker.mk\"
    $0 -f printTargetNames -p \"Makefile tasks/help.mk tasks/docker.mk\"
    MAKEFILE_LIST=\"Makefile ...\" $0 -f printMakefileHelpTopic -p \"topic\"
"
FIELD_SEPARATOR=":.*?## "

#
# @param string $makefiles
#
printTargets()
{
    makefiles=$@

    for file in $makefiles; do
        grep --only-matching --extended-regexp '^[^:]+:[^:^?]+##\s.*$' $file;
    done\
        | sort --dictionary-order
}

#
# @param string $makefiles
#
printMakefileHelp()
{
    makefiles=$@

    printTargets $makefiles\
        | awk -v FS=$FIELD_SEPARATOR '{printf "\033[36m%-34s\033[0m %s\n", $1, $2}'
}

#
# @param string $topic
# @env $MAKEFILE_LIST
#
printMakefileHelpTopic()
{
    topic=$1

    printMakefileHelp $MAKEFILE_LIST\
        | grep --ignore-case "$topic"\
            || echo "    > No results found for topic \"$topic\""
}

source $(dirname $0)/main.sh
