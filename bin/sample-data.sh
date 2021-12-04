#!/bin/bash

set -e

# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0")))
. "$project_root/bin/includes/functions.sh" "$project_root"

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

runCommand() (
  #tput setaf 1; echo "Method in bin/install.sh: $2"
  tput setaf 6
  message "$1"
  eval "$1"
)

commands="/usr/local/bin/sample-data.sh"
runCommand "$phpContainer '$commands'"