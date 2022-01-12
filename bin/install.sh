#!/bin/bash
set -e

startAll=$(date +%s)
# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0")))
functions="$project_root/bin/includes/functions.sh"

if [ -f "$functions" ]; then
    # shellcheck disable=SC1090
    . "$functions" "$project_root"
  else
    git clone https://github.com/aliuosio/mage2.docker.git
    cd mage2.docker
    chmod +x bin/*.sh
    bin/install.sh
fi

getLogo
if [[ $1 == "config" ]]; then
  message "Press [ENTER] alone to keep the current values"
  prompt "rePlaceInEnv" "Path to empty folder(fresh install) or running project (current: $WORKDIR)" "WORKDIR"
  prompt "rePlaceInEnv" "Git Repo (if work directory has to be cloned) (current: $GIT_URL)" "GIT_URL"
  prompt "rePlaceInEnv" "Project Name (alphanumeric only) (current: $COMPOSE_PROJECT_NAME)" "COMPOSE_PROJECT_NAME"
  prompt "rePlaceInEnv" "Domain Name (current: $SHOPURI)" "SHOPURI"
  prompt "rePlaceInEnv" "Webserver Port (current: $WEBSERVER_UNSECURE_PORT)" "WEBSERVER_UNSECURE_PORT"
  specialPrompt "Use Project DB [d]ump, [s]ample data or [n]one of the above?"
  prompt "rePlaceInEnv" "Which PHP 7 Version? (7.1, 7.2, 7.3, 7.4) (current: $PHP_VERSION_SET)" "PHP_VERSION_SET"
  prompt "rePlaceInEnv" "Enable Xdebug? (current: $XDEBUG_ENABLE)" "XDEBUG_ENABLE"
  prompt "rePlaceInEnv" "Which MariaDB Version? (10.4) (current: $MARIADB_VERSION)" "MARIADB_VERSION"
  prompt "rePlaceInEnv" "Which Elasticsearch Version? (current: $ELASTICSEARCH_VERSION)" "ELASTICSEARCH_VERSION"
  prompt "rePlaceInEnv" "Create a login screen? (current: $AUTH_CONFIG)" "AUTH_CONFIG"
fi
. "$project_root/.env"

# findImport

osxExtraPackages
makeExecutable
createFolderHost
setNginxVhost
dockerRefresh
setPermissionsContainer
magentoSetup
sampleDataInstallMustInstall
MagentoTwoFactorAuthDisable
setMagentoPermissions
setPermissionsContainer
endAll=$(date +%s)
message "Setup Time: $((endAll - startAll)) Sec"
showSuccess "$SHOPURI" "$DUMP"
#setMagentoCron
