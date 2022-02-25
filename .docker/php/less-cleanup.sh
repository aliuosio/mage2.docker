#!/bin/bash

set -e

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

setupUpgrade() {
  message 'bin/magento se:up'
  bin/magento se:up
}

createSource() {
  for var in "$@"; do
    message "bin/magento dev:source-theme:deploy --locale=de_DE --theme=""$var""";
    bin/magento dev:source-theme:deploy --locale=de_DE --theme="$var"
  done
}

cacheClear() {
  message 'bin/magento ca:cl'
  bin/magento ca:cl
}

createStaticFiles() {
  message 'bin/magento s:s:d -f en_US de_DE'
  bin/magento s:s:d -f en_US de_DE
}

installPackages() {
  message 'yarn install'
  yarn install

  message 'yarn upgrade';
  yarn upgrade
}

gulpCommands() {
  message 'gulp css'
  gulp css

  message 'gulp watch'
  gulp watch
}

run() {
  setupUpgrade
  createSource "$@"
  cacheClear
  createStaticFiles
  installPackages
  gulpCommands
}

run "$@"
