#!/bin/bash

set -e


message () {
  echo "";
  echo -e "$1"
  echo "------------------------------------------------------------------------------"
}

dockerRefresh() {
    if ! [[ -x "$(command -v docker-compose)" ]]; then
        message 'Error: docker-compose is not installed.' >&2
        exit 1
    fi

    if [[ $(uname -s) == "Darwin" ]]; then
        message "docker-sync start"
        docker-sync start;

        message "docker-compose -f docker-compose.osx.yml up -d"
        docker-compose -f docker-compose.osx.yml up -d
    else
        message "docker-compose up -d;"
        docker-compose up -d
    fi
}

dockerRefresh
