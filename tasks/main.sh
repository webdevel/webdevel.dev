#!/usr/bin/env sh

# This script should ONLY contain common behavior
# used by all scripts that include/source this file.
# Specific functions should be in the corresponding <namespace>.sh.
# Why? Let's avoid maintaining the more complex shell-script in Makefile targets.
# It becomes error prone and difficult to maintain.
# Please see sub-script tasks/help.sh for example usage of this script
# Include this script at end of sub-script: source $(dirname $0)/main.sh
# Optionally define EXAMPLES="" in sub-script for self documentation.

SUCCESS=0
FAILURE=1
if test -z $function; then
    function=printHelp
fi

printHelp()
{
cat << EOF

NAME
    $(basename $0) - Makefile shell-script functions in $(basename $0 | cut -d . -f 1) namespace

SYNOPSIS
    $0 [-h] [-f <function> [-p <parameters>]]

OPTIONS
    -h              Print this help message and exit
    -f function     Execute function (default: $function)
    -p parameters   Execute function with parameters (default: $parameters)

EXAMPLES
    $0 -h
    $0 -f printHelp
    $EXAMPLES
EOF
}

while getopts "hf:p:" option; do
    case $option in
        h)
            printHelp
            exit $SUCCESS
            ;;
        f)
            function=$OPTARG
            ;;
        p)
            parameters=$OPTARG
            ;;
    esac
done

$function $parameters

exit $?
