#!/usr/bin/env sh

# Makefile.linode shell-script functions

EXAMPLES="
    TOKEN=<token> $0 -f getTypes
    TOKEN=<token> $0 -f getImages
    TOKEN=<token> $0 -f getImageIds
"
URI=https://api.linode.com/
VERSION=v4

getTypes()
{
    curl\
        --header "Authorization: Bearer $TOKEN"\
        $URI/$VERSION/linode/types/\
        | json_pp
}

#
# @env $TOKEN
#
getImages()
{
    curl\
        --header "Authorization: Bearer $TOKEN"\
        $URI/$VERSION/images/\
        | json_pp

}

#
# @env $TOKEN
#
getImageIds()
{
    delimiter=-d
    field=-f
    fieldSeparator=FS

    getImages\
        | grep --only-matching --extended-regexp '\s*"id"\s*:\s*"[^"]+"\s*'\
            | awk -v $fieldSeparator='\s*:\s*' '{print$2}'\
                | cut $delimiter '"' $field 2\
                    | sort --dictionary-order
}

source $(dirname $0)/main.sh
