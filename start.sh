#!/bin/bash

set -e

. "${PWD}"/.env
PHP="${NAMESPACE}_php"

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

dockerRefresh() {
    if ! [[ -x "$(command -v docker-compose)" ]]; then
        message 'Error: docker-compose is not installed.' >&2
        exit 1
    fi

    if [[ $(uname -s) == "Darwin" ]]; then
    docker-compose -f docker-compose.osx.yml up -d;
    mutagen daemon start
    mutagen sync create --name=ssh-keys /home/"${USER}"/.ssh docker://"$USER"@"$PHP"/home/"${USER}"/.ssh
    mutagen sync create --name=composer-cache /home/"${USER}"/.composer docker://"$USER"@"$PHP"/home/"${USER}"/.composer
    mutagen sync create --name=app-data "${WORKDIR}" docker://"$USER"@"$PHP"/home/"${USER}"/html
    else
        message "docker-compose up -d;"
        docker-compose up -d
    fi
}


dockerRefresh
