#!/bin/sh

set -ex

mainConfig() {
    if [[ $(grep -c $1 /etc/passwd) == 0 ]]; then
        addgroup -S $1 \
        && adduser -S $1 -G $1 \
        && chown -R $1:$1 /home/$1
    fi
}

mainConfig ${USER}
tail -f /dev/null