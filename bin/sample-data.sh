#!/bin/bash

set -e

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

sampledata_install() {
  phpContainer="docker exec -it ${NAMESPACE}_php"
	runCommand "$phpContainer bin/magento sampledata:deploy;"
	runCommand "$phpContainer bin/magento se:up;"
	runCommand "$phpContainer bin/magento i:rei;"
	runCommand "$phpContainer bin/magento c:c;"
}

. "${PWD}"/.env;

sampledata_install
