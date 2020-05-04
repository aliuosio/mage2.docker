#!/bin/sh

set -ex

mainConfig() {
    if [[ $(grep -c $1 /etc/passwd) == 0 ]]; then
        adduser \
        --disabled-password \
        --gecos "" \
        --home /home/$1 \
        "$1";
    fi
}

mainConfig ${USER}
tail -f /dev/null