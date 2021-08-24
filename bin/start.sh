#!/bin/bash
set -e

project_root=$(dirname $(dirname $(realpath "$0" )))
. "$project_root/bin/includes/functions.sh" "$project_root"

dockerRefresh
removeHTMLFolder
magentoSetup
MagentoTwoFactorAuthDisable
magentoRefresh
sampleDataInstall
setMagentoCron >/dev/null
setPermissions
showSuccess "$SHOPURI" "$DUMP"
showDockerLogs "${NAMESPACE}_php"