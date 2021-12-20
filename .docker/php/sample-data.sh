#!/bin/bash

set -e

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

runCommand() (
  message "$1"
  eval "$1"
)

sampledataInstall() {
  command="bin/magento sampledata:deploy && bin/magento se:up && bin/magento i:rei && bin/magento c:c;"

  runCommand "$command"
}

sampledataInstall