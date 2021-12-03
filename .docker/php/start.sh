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

magentoRefresh() {
  commands="bin/magento se:up && bin/magento ca:cl;"

  runCommand "$commands"
}

setPermissionsContainer() {
  commands="find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} + \
            && find var generated vendor pub/static pub/media app/etc -type d -exec chmod u+w {} + \
            && chown -R www:www $WORKDIR_SERVER \
            && chmod u+x bin/magento"

  runCommand "$commands"
}

setMagentoCron() {
  commands="bin/magento cron:install"
  runCommand "$commands"
}


magentoRefresh
setPermissionsContainer
setMagentoCron