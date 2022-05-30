#!/bin/bash
set -e

startAll=$(date +%s)
# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0" )))
. "$project_root/bin/includes/functions.sh" "$project_root"

dockerRefresh
setMagentoCron
setPermissionsContainer
endAll=$(date +%s)
message "Setup Time: $((endAll - startAll)) Sec"
showSuccess "$SHOPURI" "$DUMP"