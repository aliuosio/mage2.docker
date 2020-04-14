#!/bin/bash

set -e

createEnv() {
    if [ ! -f ./.env ]; then
        echo "cp ./.env.template ./.env";
        cp ./.env.template ./.env
    else
        echo ".env File exists already and will be used";
    fi
}

createEnv

. ${PWD}/.env;

prompt() {
    read -p "$2" RESPONSE
    echo $($1 ${RESPONSE});
}

setPath() {
    if [[ $1 != ${WORKDIR} && -z $1 ]]; then

        if [[ ! -d "$1" ]]; then
            if ! mkdir -p "$1"; then
                return 0;
            fi
        else
            echo "Folder already exits";
        fi

        pattern=".*WORKDIR=.*";
        replacement="WORKDIR="$1;
        sed -i "s@${pattern}@${replacement}@" $PWD/.env;

        echo $(isComposerJsonAvailable $1);
    fi
}

isComposerJsonAvailable() {
    if [[ -f $1"/composer.json" ]]; then
        return "A composer.json exists in that Folder.";
    fi
}

prompt "setPath" "Shop Path (Default: ${WORKDIR})";