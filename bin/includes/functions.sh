#!/bin/bash
set -e

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

setEnvironment() {
  if [[ $1 ]]; then
    file="$1/.env"
    if [[ ! -f $file ]]; then
      cp "$1/.env.temp" "$file"
    else
      echo ".env File exists already"
    fi
    # shellcheck disable=SC1090
    source "$file"
  fi
}

setEnvironment "$1"

#if [[ -z "$var" ]]; then
   # Do what you want
#fi

GROUP_HOST="docker"
PHP_USER=www-data
phpContainerRoot="docker exec -it -u root ${NAMESPACE}_php bash -lc"
phpContainer="docker exec -it ${NAMESPACE}_php bash -lc"

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

DBDumpImport() {
  if [[ -n $1 && -f $1 ]]; then
    runCommand "docker exec -i $2_db mysql -u $3 -p<see .env for password> $5 < $1;"
  else
    message "SQL File not found"
  fi
}

createFolderHost() {
  dir="${HOME}/.composer"
  commands="mkdir -p $dir $WORKDIR"

  runCommand "$commands"
}

setPermissionsHost() {
  dir="${HOME}/.composer"
  commands="sudo chown -R $USER:$GROUP_HOST $dir && sudo chown -R $USER:$GROUP_HOST $WORKDIR"
  runCommand "$commands"
}

createComposerFolderContainer() {
  dir="/home/$PHP_USER/.composer"
  runCommand "$phpContainerRoot 'mkdir -p $dir && chown -R $PHP_USER:$PHP_USER $dir'"
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

gitUpdate() {
  if [ ! -d "$WORKDIR" ] && [ "$GIT_URL" ] && [ "$GIT_BRANCH" ]; then
    runCommand "git clone --branch $GIT_BRANCH $GIT_URL $WORKDIR"
  fi

  if [ -f "$WORKDIR/.git/config" ]; then
    if [[ $(uname -s) == "Darwin" ]]; then
      runCommand "sed -i "" 's@filemode = true@filemode = false@' $WORKDIR/.git/config"
    else
      runCommand "sed -i 's@filemode = true@filemode = false@' $WORKDIR/.git/config"
    fi
    runCommand "git -C $WORKDIR fetch -p -a && git pull"
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

setAuthConfig() {
  if [[ "$1" == "true" ]]; then
    prompt "rePlaceInEnv" "Login User Name (current: $2)" "AUTH_USER"
    prompt "rePlaceInEnv" "Login User Password (current: $3)" "AUTH_PASS"
  fi
}

showLog() {
  if [ -f ".docker/mysql/db_dumps/dev.sql.gz" ]; then
    container="${NAMESPACE}_db"
  else
    container="${NAMESPACE}_php"
  fi
  docker logs "$container" --follow
}

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

  runCommand "$phpContainerRoot '$commands'"
}

setPermissionsContainer() {
  commands="chown -R $PHP_USER:$PHP_USER $WORKDIR_SERVER \
            && chown -R $PHP_USER:$PHP_USER /home/$PHP_USER/.composer"

  runCommand "$phpContainerRoot '$commands'"
}

setUserContainer() {
  commands="chown -R $PHP_USER:$PHP_USER /var/www/html"

  runCommand "$phpContainer '$commands'"
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
  if [[ $(find "$DB_DUMP_FOLDER" -maxdepth 1 -type f -name "*.gz") ]]; then
    echo 'IS DA'
  fi
}

conposerFunctions() {
  commands="composer i"
  runCommand "$phpContainer '$commands'"
}

setNginxVhost() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "sed -i '' 's@localhost@$SHOPURI@' .docker/nginx/config/default.conf"
    runCommand "sed -i '' 's@/var/www-data/html@$WORKDIR_SERVER@' .docker/nginx/config/default.conf"
  else
    runCommand "sed -i 's@localhost@$SHOPURI@' .docker/nginx/config/default.conf"
    runCommand "sed -i 's@/var/www-data/html@$WORKDIR_SERVER@' .docker/nginx/config/default.conf"
  fi
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
  commands="bin/magento setup:install \
    --base-url=http://$SHOPURI/ \
    --db-host=db \
    --db-name=$MYSQL_DATABASE \
    --db-user=root \
    --db-password=$MYSQL_ROOT_PASSWORD \
    --backend-frontname=admin \
    --language=de_DE \
    --timezone=Europe/Berlin \
    --currency=EUR \
    --admin-lastname=$ADMIN_NAME \
    --admin-firstname=$ADMIN_SURNAME \
    --admin-email=$ADMIN_EMAIL \
    --admin-user=$ADMIN_USER \
    --admin-password=$ADMIN_PASS \
    --cleanup-database \
    --use-rewrites=0 \
    --session-save=redis \
    --session-save-redis-host=/var/run/redis/redis.sock \
    --session-save-redis-db=0 \
    --session-save-redis-password='' \
    --cache-backend=redis \
    --cache-backend-redis-server=/var/run/redis/redis.sock \
    --cache-backend-redis-db=1 \
    --cache-backend-redis-port=6379 \
    --search-engine=elasticsearch7 \
    --elasticsearch-host=elasticsearch \
    --elasticsearch-port=9200"
  runCommand "$phpContainer '$commands'"
}

magentoSetup() {
  # shellcheck disable=SC2154
  if [ -f "$composerJsonFile" ]; then
    conposerFunctions
  fi

  magentoPreInstall
  composerExtraPackages
  magentoInstall
  magentoConfigImport
  magentoConfig
}
