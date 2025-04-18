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

WORKDIR_SERVER=/var/www/html
DB_CONNECT="mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"

phpContainerRoot="docker exec -it -u root ${NAMESPACE}_php bash -lc"
phpContainer="docker exec -it ${NAMESPACE}_php bash -lc"
dbContainer="docker exec -it ${NAMESPACE}_db bash -lc"

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

sedForOs() {
    runCommand "sed -i 's#$1#$2#' $3"
}

createFolderHost() {
  dir="${HOME}/.composer"
  if [ ! -d "$dir" ]; then
    commands="mkdir -p $dir"
    runCommand "$commands"
  fi
  if [ ! -d "$WORKDIR" ]; then
    commands="mkdir -p $WORKDIR"
    runCommand "$commands"
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
  file="./.env"
  if [[ -n "$1" ]]; then
    UID_GID="$(id -u "${USER}"):$(id -g "${USER}")"
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
  sed -i "s#$pattern#$replacement#" "$envFile"
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

dockerRefresh() {
    runCommand "docker network prune -f && docker compose down && docker compose up -d"
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

setPermissionsHost() {
  commands="sudo chown -R ${USER}:${USER} ${WORKDIR} \
  && sudo chown -R ${USER}:${USER} /home/${USER}/.composer"

  runCommand "$commands"
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

sampleDataInstall() {
  commands="php -d memory_limit=-1 bin/magento sampledata:deploy && bin/magento se:up && bin/magento i:rei && bin/magento c:c;"
  runCommand "$phpContainer '$commands'"
}

sampleDataInstallMustInstall() {
  if [[ "$SAMPLE_DATA" == "true" ]]; then
    sampleDataInstall
  fi
}

MagentoTwoFactorAuthDisable() {
  commands="bin/magento module:disable -c Magento_AdminAdobeImsTwoFactorAuth Magento_TwoFactorAuth"
  runCommand "$phpContainer '$commands'"
}

setMage2Env() {
  commands="cp ${PWD}/.docker/config_blueprints/* ${WORKDIR}/app/etc/"
  runCommand "$commands"

  commands="bin/magento setup:config:set --db-name=$MYSQL_DATABASE && bin/magento module:enable --all"
  runCommand "$phpContainer '$commands'"
}

DatabaseDumpCopyToContainer() {
  commands="docker cp $DB_DUMP ${NAMESPACE}_db:/$1"
  runCommand "$commands"
}

DatabaseImportFormatHandle() {
  if [[ $1 == *".gz"* ]]; then
    commands="pv /$1 | gunzip -c | $DB_CONNECT"
  else
    commands="pv /$1 | $DB_CONNECT"
  fi

  runCommand "$dbContainer '$commands'"
}

DatabaseForeignKeysDisable() {
  commands="$DB_CONNECT -e \"SET foreign_key_checks = 0;\""
  runCommand "$dbContainer '$commands'"
}

DatabaseForeignKeysEnable() {
  commands="$DB_CONNECT -e \"SET foreign_key_checks = 1;\""
  runCommand "$dbContainer '$commands'"
}

pvInstall() {
  commands="apt update && apt install pv"
  runCommand "$dbContainer '$commands'"
}

DatabaseImport() {
  FILENAME=$(basename "$DB_DUMP")
  pvInstall
  DatabaseDumpCopyToContainer "$FILENAME"
  DatabaseForeignKeysDisable
  DatabaseImportFormatHandle "$FILENAME"
  DatabaseForeignKeysEnable
}

conposerFunctions() {
  commands="composer install --ignore-platform-reqs"
  runCommand "$phpContainer '$commands'"
}

setNginxVhost() {
  sedForOs "localhost" "$SHOPURI" ".docker/nginx/config/default.conf"
  sedForOs "/var/www/html" "$WORKDIR_SERVER" ".docker/nginx/config/default.conf"
}

composerExtraPackages() {
  commands="composer req --dev mage2tv/magento-cache-clean && composer req yireo/magento2-webp2"
  runCommand "$phpContainer '$commands'"
}

magentoConfigImport() {
  commands="bin/magento app:config:import"
  runCommand "$phpContainer '$commands'"
}

magentoInstall() {
  commands="bin/magento setup:install --base-url=http://$SHOPURI/ \
  --db-host=/var/run/mysqld/mysqld.sock --db-name=$MYSQL_DATABASE --db-user=root --db-password=$MYSQL_ROOT_PASSWORD \
  --backend-frontname=admin --admin-lastname=$ADMIN_NAME --admin-firstname=$ADMIN_SURNAME --admin-email=$ADMIN_EMAIL \
  --admin-user=$ADMIN_USER --admin-password=$ADMIN_PASS \
  --search-engine=opensearch --opensearch-host=opensearch --opensearch-port=9200 --opensearch-index-prefix=$SHOPURI --opensearch-timeout=15 \
  --session-save=redis --session-save-redis-host=redis_session --session-save-redis-persistent-id=sess-db0 --session-save-redis-db=1 \
  --cache-backend=redis --cache-backend-redis-server=redis_cache --cache-backend-redis-db=0 \
  --page-cache=redis --page-cache-redis-server=redis_cache --page-cache-redis-db=1 \
  --timezone=Europe/Berlin --currency=EUR"

  runCommand "$phpContainer '$commands'"
}

magentoConfig() {
  commands="bin/magento config:set web/secure/use_in_frontend 0 && \
  bin/magento config:set web/secure/use_in_adminhtml 0 && \
  bin/magento config:set dev/caching/cache_user_defined_attributes 1 && \
  bin/magento config:set catalog/search/enable_eav_indexer 1 && \
  bin/magento config:set dev/template/minify_html 1 && \
  bin/magento config:set dev/js/merge_files 1 && \
  bin/magento config:set dev/js/enable_js_bundling 1 && \
  bin/magento config:set dev/js/minify_files 1 && \
  bin/magento config:set dev/js/move_script_to_bottom 1 && \
  bin/magento config:set dev/css/merge_css_files 1 && \
  bin/magento config:set dev/css/minify_files 1 && \
  bin/magento config:set dev/grid/async_indexing 1 && \
  bin/magento config:set system/full_page_cache/caching_application 2 && \
  bin/magento config:set system/full_page_cache/varnish/access_list localhost && \
  bin/magento config:set system/full_page_cache/varnish/backend_host localhost && \
  bin/magento config:set system/full_page_cache/varnish/grace_period 300 && \
  bin/magento config:set system/smtp/disable 0 && \
  bin/magento config:set system/smtp/transport smtp && \
  bin/magento config:set system/smtp/host mailhog && \
  bin/magento config:set system/smtp/port 1025 && \
  bin/magento config:set dev/grid/async_indexing 1 && \
  bin/magento config:set web/seo/use_rewrites 0 && \
  bin/magento deploy:mode:set -s $DEPLOY_MODE"

  runCommand "$phpContainer '$commands'"
}

magentoPreInstall() {
  commands="composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${MAGENTO_VERSION} ."
  runCommand "$phpContainer '$commands'"
}

setMagentoCron() {
  commands="cd $WORKDIR_SERVER && [ -f bin/magento ] && bin/magento cron:install || echo 'bin/magento not found'"
  runCommand "$phpContainerRoot '$commands'"
}

algoliaCron() {
  commands="echo \"*/5 * * * * /usr/local/bin/php /var/www/html/bin/magento indexer:reindex algolia_queue_runner\" >> /etc/crontabs/root"
  runCommand "$phpContainerRoot '$commands'"
}

setContainerPermissonsComposer(){
  commands="mkdir -p $COMPOSER_CACHE_DIR && chown -R $USER_PHP:$GROUP_PHP $COMPOSER_CACHE_DIR"
  runCommand "$phpContainerRoot '$commands'"
}

setContainerPermissonsWorkDir(){
  commands="chown -R $USER_PHP:$GROUP_PHP $WORKDIR_SERVER"
  runCommand "$phpContainerRoot '$commands'"
}

magentoSetup() {
  if [ -f "$WORKDIR/composer.json" ]; then
    conposerFunctions
  else
    magentoPreInstall
    composerExtraPackages
    magentoInstall
  fi

  magentoConfig
  magentoConfigImport
}

install () {
    commands="php_install"
    runCommand "$phpContainer '$commands'"
}

copyHtmlToWorkdir() {
  docker cp "${NAMESPACE}"_php:/var/www/html/. "$WORKDIR/"
}
