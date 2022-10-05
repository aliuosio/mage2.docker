#!/bin/bash

set -e

# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0")))
. "$project_root/bin/includes/functions.sh" "$project_root"

startAll=$(date +%s)

getLogo
dockerRefresh
setPermissionsContainer
sampleDataInstall
setMagentoPermissions
setPermissionsContainer
setPermissionsHost

endAll=$(date +%s)
message "Setup Time: $((endAll - startAll)) Sec"
showSuccess "$SHOPURI" "$DUMP"