#!/bin/bash
set -e

startAll=$(date +%s)
# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0" )))
. "$project_root/bin/includes/functions.sh" "$project_root"

dockerRefresh
showSuccess "$SHOPURI" "$DUMP"
setPermissionsContainer
setMagentoCron
endAll=$(date +%s)
message "Setup Time: $((endAll - startAll)) Sec"