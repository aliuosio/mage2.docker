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

setEnvironment() {
  if [[ $1 ]]; then
    file="$1/.env"
    if [ ! -f "$file" ]; then
      runCommand "cp $1/.env.temp $file"
    fi

    # shellcheck disable=SC1090
    source "$file"
  fi
}

setEnvironment "$1"

PHP_USER="www-data"
WORKDIR_SERVER=/var/www/html
phpContainerRoot="docker exec -it -u root ${NAMESPACE}_php bash -lc"
phpContainer="docker exec -it -u ${PHP_USER} ${NAMESPACE}_php bash -lc"

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

createFolderHost() {
  dir="${HOME}/.composer"
  commands="mkdir -p $dir $WORKDIR"

  runCommand "$commands"
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
  file="./.env"
  if [[ -n "$1" ]]; then
    UID_GID="$(id -u "${USER}"):$(id -g "${USER}")";
    rePlaceIn "$UID_GID" "UID_GID" "$file"

    rePlaceIn "$1" "$2" "./.env"
    if [[ $2 == "COMPOSE_PROJECT_NAME" ]]; then
      rePlaceIn "$1" "NAMESPACE" "$file"
      rePlaceIn "$1" "MYSQL_DATABASE" "$file"
      rePlaceIn "$1" "MYSQL_USER" "$file"
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
    sed -i "" "s@$pattern@$replacement@" "$envFile"
  else
    sed -i "s@$pattern@$replacement@" "$envFile"
  fi
}

prompt() {
  if [[ -n "$2" ]]; then
    read -rp "$2" RESPONSE
    [[ $RESPONSE == '' && $3 == 'WORKDIR' ]] && VALUE=$RESPONSE || VALUE=$RESPONSE
    # shellcheck disable=SC2091
    $($1 "${VALUE}" "$3")
  fi
}

osxExtraPackages() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "brew install coreutils"
    if [[ ! -x "$(command -v brew)" ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    if [[ ! -x "$(command -v unison)" ]]; then
      runCommand "brew install unison"
    fi
    if [[ ! -d /usr/local/opt/unox ]]; then
      runCommand "brew install eugenmayer/dockersync/unox"
    fi
    if [[ ! -x "$(command -v docker-sync)" ]]; then
      runCommand "gem install docker-sync;"
    fi
  fi
}

setHostSettings() {
  sudo sysctl vm.overcommit_memory=1
  sudo echo never /sys/kernel/mm/transparent_hugepage/enabled
  sudo sysctl vm.max_map_count=262144
  sudo systemctl daemon-reload
}

sedForOs() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "sed -i '' 's@$1@$2@' $3"
  else
    runCommand "sed -i 's@$1@$2@' $3"
  fi
}

gitUpdate() {
  if [ ! -d "$WORKDIR" ] && [ "$GIT_URL" ]; then
    runCommand "git clone $GIT_URL $WORKDIR"
    sedForOs "filemode\ =\ true" "filemode\ =\ false" "$WORKDIR/.git/config"
  else
    if [ -f "$WORKDIR/.git/config" ]; then
      runCommand "git -C $WORKDIR fetch -p -a && git pull"
    fi
  fi
}

composerOptimzerWithAPCu() {
  runCommand "docker exec -u $1 $2 composer dump-autoload -o --apcu"
}

makeExecutable() {
  runCommand "chmod +x bin/*.sh;"
}

# @todo: test on OSX
dockerRefresh() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "docker-compose -f docker-compose.osx.yml down &&
                docker-sync stop &&
                docker-sync start &&
                docker-compose -f docker-compose.osx.yml up -d"
  else
    runCommand setHostSettings
    runCommand "docker-compose down && docker-compose up -d"
  fi
}

setHostSettings() {
  sudo sysctl vm.overcommit_memory=1
  sudo echo never /sys/kernel/mm/transparent_hugepage/enabled
  sudo sysctl vm.max_map_count=262144
  sudo systemctl daemon-reload
}

removeAll() {
  if [ -d "$WORKDIR" ]; then
    commands="rm -rf $WORKDIR_SERVER/*;"
    runCommand "$phpContainer '$commands'"
  fi
}

restoreAll() {
  git checkout "$WORKDIR/*"
}

magentoRefresh() {
  commands="bin/magento se:up && bin/magento ca:cl;"
  runCommand "$phpContainer '$commands'"
}

restoreGitIgnoreAfterComposerInstall() {
  runCommand "git -C $WORKDIR checkout .gitignore"
}

setMagentoPermissions() {
  commands="find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} + \
            && find var generated vendor pub/static pub/media app/etc -type d -exec chmod u+w {} + \
            && chmod u+x bin/magento"

  runCommand "$phpContainer '$commands'"
}

setPermissionsContainer() {
  commands="chown -R ${PHP_USER}:${PHP_USER} $WORKDIR_SERVER \
            && chown -R ${PHP_USER}:${PHP_USER} /home/${PHP_USER}/.composer"

  runCommand "$phpContainerRoot '$commands'"
}

showSuccess() {
  if [ -n "$2" ]; then
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

setMagentoCron() {
  commands="bin/magento cron:install"
  runCommand "$phpContainerRoot '$commands'"
}

sampleDataInstall() {
  commands="bin/magento sampledata:deploy && bin/magento se:up && bin/magento i:rei && bin/magento c:c;"
  runCommand "$phpContainer '$commands'"
}

sampleDataInstallMustInstall() {
  if [[ "$SAMPLE_DATA" == "true" ]]; then
    sampleDataInstall
  fi
}

MagentoTwoFactorAuthDisable() {
  commands="bin/magento module:disable -c Magento_TwoFactorAuth"
  runCommand "$phpContainer '$commands'"
}

findImport() {
  if [[ -f $DB_DUMP ]]; then
    runCommand "mv $DB_DUMP .docker/mysql/db_dumps/"
    message "check progress in a new terminal tab with: docker logs -f  mage2_db"
    sleep 5
  fi
}

conposerFunctions() {
  commands="composer i"
  runCommand "$phpContainer '$commands'"
}

setNginxVhost() {
  sedForOs "localhost" "$SHOPURI" ".docker/nginx/config/default.conf"
  sedForOs "/var/www/html" "$WORKDIR_SERVER" ".docker/nginx/config/default.conf"
}

composerExtraPackages() {
  commands="composer req --dev mage2tv/magento-cache-clean && composer req magepal/magento2-gmailsmtpapp yireo/magento2-webp2"
  runCommand "$phpContainer '$commands'"
}

magentoConfigImport() {
  commands="bin/magento app:config:import"
  runCommand "$phpContainer '$commands'"
}

magentoConfig() {
  commands="
      bin/magento config:set system/full_page_cache/caching_application 2
      bin/magento config:set web/secure/use_in_frontend 0 && \
      bin/magento config:set web/secure/use_in_adminhtml 0  && \
      bin/magento config:set web/seo/use_rewrites 0 && \
      bin/magento config:set catalog/search/enable_eav_indexer 1 && \
      bin/magento deploy:mode:set -s $DEPLOY_MODE"

  runCommand "$phpContainer '$commands'"
}

magentoPreInstall() {
  commands="composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${MAGENTO_VERSION} ."

  runCommand "$phpContainer '$commands'"
}

composerExtraPackages() {
  commands="composer req --dev mage2tv/magento-cache-clean && composer req magepal/magento2-gmailsmtpapp yireo/magento2-webp2"

  runCommand "$phpContainer '$commands'"
}

magentoInstall() {
  commands="bin/magento setup:install --base-url=http://$SHOPURI/ \
  --db-host=db --db-name=$MYSQL_DATABASE --db-user=root --db-password=$MYSQL_ROOT_PASSWORD \
  --admin-lastname=$ADMIN_NAME --admin-firstname=$ADMIN_SURNAME --admin-email=$ADMIN_EMAIL --admin-user=$ADMIN_USER --admin-password=$ADMIN_PASS \
  --backend-frontname=admin --language=de_DE --timezone=Europe/Berlin --currency=EUR --cleanup-database --use-rewrites=0 \
  --session-save=redis --session-save-redis-host=/var/run/redis/redis.sock --session-save-redis-db=0 --session-save-redis-password='' \
  --cache-backend=redis --cache-backend-redis-server=/var/run/redis/redis.sock --cache-backend-redis-db=1 --cache-backend-redis-port=6379 \
  --search-engine=elasticsearch7 --elasticsearch-host=elasticsearch --elasticsearch-port=9200 \
  --amqp-host=rabbitmq --amqp-ssl=false --amqp-port=5672 --amqp-user=guest --amqp-password=guest --amqp-virtualhost='/'"

  runCommand "$phpContainer '$commands'"
}

setComposerVersion() {
  commands="composer self-update --$COMPOSER_VERSION"
  runCommand "$phpContainerRoot '$commands'"
}

magentoSetup() {
  if [ -f "$WORKDIR/composer.json" ]; then
    conposerFunctions
  else
    magentoPreInstall
    composerExtraPackages
  fi

  magentoInstall
  magentoConfigImport
  magentoConfig
}
