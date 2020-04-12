#!/bin/bash

set -e

DEFAULT_PATH=$PWD/htdocs;

createEnv() {
    if [ ! -f ./.env ]; then
        echo "cp ./.env.template ./.env";
        cp ./.env.template ./.env
    else
        echo ".env File exists already";
    fi
}

prompt() {
    read -p "$2" RESPONSE
    echo $($1) ${RESPONSE};
}

setPath() {
    if [[ $1 != ${DEFAULT_PATH} && $1 != NULL ]]; then
        pattern="WORKDIR=./htdocs";
        replacement="WORKDIR="$1;
        sed -i "s@${pattern}@${replacement}@" $PWD/.env;
    fi
}

freshOrExisting() {
    echo "freshOrExisting WAS RETURNED";
}


createEnv

. ${PWD}/.env;

prompt "setPath" "Shop Path (Default: $DEFAULT_PATH)";
prompt "freshOrExisting" "[f]resh or [e]xisting Project?";