#!/bin/bash
set -e

startAll=$(date +%s)
# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0" )))
. "$project_root/bin/includes/functions.sh" "$project_root"

dockerRefresh
magentoRefresh
setPermissionsHost
setPermissionsContainer
showSuccess "$SHOPURI" "$DUMP"
endAll=$(date +%s)
message "Setup Time: runtimeAll=$((endAll - startAll)) Sec"
showLog