#!/bin/bash

set -e

run() {
  # bin/magento se:up
  bin/magento dev:source-theme:deploy --locale=de_DE --theme="$1"
  bin/magento dev:source-theme:deploy --locale=de_DE --theme="$2"
  bin/magento s:s:d -f de_DE
  bin/magento ca:cl
  gulp css
  gulp watch
}

run "$1" "$2"
