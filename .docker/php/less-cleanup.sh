#!/bin/bash

set -e

createSource() {
  for var in "$@"; do
    bin/magento dev:source-theme:deploy --locale=de_DE --theme="$var"
  done
}

InstallPackages() {
  yarn install
  yarn upgrade
}

gulpCommands() {
  gulp css
  gulp watch
}

createStaticFiles() {
  bin/magento s:s:d -f de_DE en_US
}

cacheClear() {
  bin/magento ca:cl
}

setupUpgrade() {
  bin/magento se:up
}

run() {
  # setupUpgrade
  createSource "$@"
  createStaticFiles
  # cacheClear
  # InstallPackages
  gulpCommands
}

run "$@"
