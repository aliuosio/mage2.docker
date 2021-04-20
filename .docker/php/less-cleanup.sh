#!/bin/bash

set -e

run() {
for var in "$@"
do
  bin/magento dev:source-theme:deploy --locale=de_DE --theme="$var"
done


  bin/magento s:s:d -f de_DE
  bin/magento ca:cl
  gulp css
  gulp watch
}

run "$@"