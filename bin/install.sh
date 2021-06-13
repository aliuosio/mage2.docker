#!/bin/bash
set -e
export TERM=ansi

getLogo() {
  echo "                             _____      _            _             "
  echo "                            / __  \    | |          | |            "
  echo " _ __ ___   __ _  __ _  ___ \`' / /'  __| | ___   ___| | _____ _ __ "
  echo "| '_ \` _ \ / _\` |/ _\` |/ _ \  / /   / _\` |/ _ \ / __| |/ / _ \ '__|"
  echo "| | | | | | (_| | (_| |  __/./ /___| (_| | (_) | (__|   <  __/ |   "
  echo "|_| |_| |_|\__,_|\__, |\___|\_____(_)__,_|\___/ \___|_|\_\___|_|   "
  echo "                  __/ |                                            "
  echo "                 |___/                                             "
}

createEnv() {
  if [[ ! -f ./.env ]]; then
    message "cp ./.env.template ./.env"
    cp ./.env.template ./.env
  else
    message ".env File exists already"
  fi
}

specialPrompt() {
  if [[ -n "$1" ]]; then
    read -rp "$1" RESPONSE
    if [[ ${RESPONSE} == '' || ${RESPONSE} == 'n' || ${RESPONSE} == 'N' ]]; then
      rePlaceInEnv "false" "SAMPLE_DATA"
      rePlaceInEnv "" "DB_DUMP"
    elif [[ ${RESPONSE} == 's' || ${RESPONSE} == 'S' ]]; then
      rePlaceInEnv "true" "SAMPLE_DATA"
      rePlaceInEnv "" "DB_DUMP"
    elif [[ ${RESPONSE} == 'd' || ${RESPONSE} == 'D' ]]; then
      rePlaceInEnv "false" "SAMPLE_DATA"
      prompt "rePlaceInEnv" "Set Absolute Path to Project DB Dump (current: ${DB_DUMP})" "DB_DUMP"
    fi
  fi
}

rePlaceInEnv() {
  if [[ -n "$1" ]]; then
    rePlaceIn "$1" "$2" "./.env"
    if [[ $2 == "COMPOSE_PROJECT_NAME" ]]; then
      rePlaceIn "$1" "NAMESPACE" "./.env"
      rePlaceIn "$1" "MYSQL_DATABASE" "./.env"
      rePlaceIn "$1" "MYSQL_USER" "./.env"
    fi
  fi

  if [[ "$MYSQL_ROOT_PASSWORD" == "" ]]; then
    # shellcheck disable=SC2046
    rePlaceIn $(openssl rand -base64 12) "MYSQL_ROOT_PASSWORD" "./.env"
  fi

  if [[ "$MYSQL_PASSWORD" == "" ]]; then
    # shellcheck disable=SC2046
    rePlaceIn $(openssl rand -base64 12) "MYSQL_PASSWORD" "./.env"
  fi
}

rePlaceIn() {
  [[ "$1" == "yes" || "$1" == "y" ]] && value="true" || value=$1
  pattern=".*$2.*"
  replacement="$2=$value"
  envFile="$3"
  if [[ $(uname -s) == "Darwin" ]]; then
    sed -i "" "s@${pattern}@${replacement}@" "${envFile}"
  else
    sed -i "s@${pattern}@${replacement}@" "${envFile}"
  fi
}

prompt() {
  if [[ -n "$2" ]]; then
    read -rp "$2" RESPONSE
    [[ ${RESPONSE} == '' && $3 == 'WORKDIR' ]] && VALUE=${RESPONSE} || VALUE=${RESPONSE}
    # shellcheck disable=SC2091
    $($1 "${VALUE}" "$3")
  fi
}
message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}
osxExtraPackages() {
  if [[ ! -x "$(command -v brew)" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  if [[ ! -x "$(command -v unison)" ]]; then
    message "brew install unison"
    brew install unison
  fi
  if [[ ! -d /usr/local/opt/unox ]]; then
    message "brew install eugenmayer/dockersync/unox"
    brew install eugenmayer/dockersync/unox
  fi
  if [[ ! -x "$(command -v docker-sync)" ]]; then
    message "gem install docker-sync;"
    sudo gem install docker-syncÌ
  fi
}

setHostSettings() {
  sudo sysctl vm.overcommit_memory=1
  sudo echo never /sys/kernel/mm/transparent_hugepage/enabled
  sudo sysctl vm.max_map_count=262144
  sudo systemctl daemon-reload
}

runCommand() (
  #tput setaf 1; echo "Method in bin/install.sh: $2"
  tput setaf 6
  message "$1"
  eval "$1"
)

gitUpdate() {
  if [ ! -d "$WORKDIR" ]; then
    runCommand "git clone --branch $GIT_BRANCH $GIT_URL $WORKDIR"
  fi

  if [ -f "$WORKDIR/.git/config" ]; then
    runCommand "sed -i 's@filemode = true@filemode = false@' $WORKDIR/.git/config"
    runCommand "git -C $WORKDIR fetch -p -a && git pull"
  fi
}

makeExecutable() {
  runCommand "chmod +x bin/*.sh;"
}

setNginxVhost() {
  runCommand "sed -i 's@mage2.localhost@$SHOPURI@' .docker/nginx/conf/default.conf"
}

# @todo: test on OSX
dockerRefresh() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "docker-compose -f docker-compose.osx.yml down"
    runCommand "docker-sync stop"
    runCommand "docker-sync start"
    runCommand "docker-compose -f docker-compose.osx.yml up -d"
  else
    runCommand setHostSettings
    runCommand "docker-compose down"
    runCommand "docker-compose up -d"
  fi
}

magentoConfig() {
  configDir="${WORKDIR}/app/etc"
  if [ -d "$configDir" ]; then
    runCommand "cp .docker/config_blueprints/env.php ${configDir}/env.php"
  fi
}

notice() {
  dbDump=".docker/mysql/db_dumps/dev.sql.gz"
  if [ -f $dbDump ]; then
    tput setaf 3
    message "$NOTICE_INSTALL"
    echo ""
  fi
}

setAuthConfig() {
  if [[ "$1" == "true" ]]; then
    prompt "rePlaceInEnv" "Login User Name (current: $2)" "AUTH_USER"
    prompt "rePlaceInEnv" "Login User Password (current: $3)" "AUTH_PASS"
  fi
}

showDockerLogs() {
  dbDump=".docker/mysql/db_dumps/dev.sql.gz"
  if [ -f $dbDump ]; then
    tput setaf 6
    docker logs "$1" --follow
  fi
}

createComposerFolder() {
  if [ ! -d ~/.composer ]; then
    mkdir -p ~/.composer
  fi
}

callStartBash() {
  dbDump=".docker/mysql/db_dumps/dev.sql.gz"
  if [ ! -f $dbDump ]; then
    bin/start.sh
  fi
}

showSuccess() {
  if [ -n "$2" ]; then
    message "Yeah, You done !"
    message "Backend:\

http://$1/admin\

User: <Backend Users from Your DB Dump>\

Password: <Backend Users Passwords from Your DB Dump>\


Frontend:\

http://$1"
  else
    message "Backend:\

http://$1/admin\

User: mage2_admin\

Password: mage2_admin123#T\


Frontend:\

http://$1"
  fi

}

MagentoTwoFactorAuthDisable() {
  message "docker exec -u $1 $2 bin/magento module:disable -c Magento_TwoFactorAuth"
  docker exec -u "$1" "$2" bin/magento module:disable -c Magento_TwoFactorAuth
}

startAll=$(date +%s)

getLogo
createEnv

# shellcheck disable=SC1090
. "${PWD}"/.env

message "Press [ENTER] alone to keep the current values"
prompt "rePlaceInEnv" "GIT Repo (if work directory has to be cloned) (current: ${GIT_URL})" "GIT_URL"
prompt "rePlaceInEnv" "Project Name (alphanumeric only) (current: ${COMPOSE_PROJECT_NAME})" "COMPOSE_PROJECT_NAME"
prompt "rePlaceInEnv" "Absolute path to empty folder(fresh install) or running project (current: ${WORKDIR})" "WORKDIR"
prompt "rePlaceInEnv" "Domain Name (current: ${SHOPURI})" "SHOPURI"
specialPrompt "Use Project DB [d]ump, [s]ample data or [n]one of the above?"
prompt "rePlaceInEnv" "Which PHP 7 Version? (7.1, 7.2, 7.3, 7.4) (current: ${PHP_VERSION_SET})" "PHP_VERSION_SET"
prompt "rePlaceInEnv" "Enable Xdebug? (current: ${XDEBUG_ENABLE})" "XDEBUG_ENABLE"
prompt "rePlaceInEnv" "Which MariaDB Version? (10.4) (current: ${MARIADB_VERSION})" "MARIADB_VERSION"
prompt "rePlaceInEnv" "Which Elasticsearch Version? (6.8.x, 7.6.x, 7.8.x, 7.9.x) (current: ${ELASTICSEARCH_VERSION})" "ELASTICSEARCH_VERSION"

if test ! -f "${WORKDIR}/composer.json"; then
  MAGE_LATEST="latest"
  read -rp "Which Magento 2 Version? (current: ${MAGE_LATEST})" MAGENTO_VERSION
fi

prompt "rePlaceInEnv" "Create a login screen? (current: ${AUTH_CONFIG})" "AUTH_CONFIG"

. "${PWD}"/.env
createComposerFolder
makeExecutable
gitUpdate
setNginxVhost
dockerRefresh
magentoConfig
notice
showDockerLogs "${NAMESPACE}"_db
callStartBash

endAll=$(date +%s)
runtimeAll=$((endAll - startAll))
message "Setup Time: ${runtimeAll} Sec"

showSuccess "$SHOPURI" "$DUMP"
