#!/bin/bash

. "${PWD}"/.env

phpContainerRoot="docker exec -it -u root ${NAMESPACE}_php bash -lc"
phpContainer="docker exec -it ${NAMESPACE}_php bash -lc"
dbContainer="docker exec ${NAMESPACE}_db "

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

runCommand() (
  #tput setaf 1; echo "Method in bin/install.sh: $2"
  tput setaf 6
  message "$1"
  eval "$1"
)

gitUpdate() {
  runCommand "git -C $WORKDIR fetch -p -a && git pull"
}

setHostSettings() {
  sudo sysctl vm.overcommit_memory=1
  sudo echo never /sys/kernel/mm/transparent_hugepage/enabled
  sudo sysctl vm.max_map_count=262144
  sudo systemctl daemon-reload
}

dockerRefresh() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "docker-sync start"
    runCommand "docker-compose -f docker-compose.osx.yml up -d"
  else
    setHostSettings
    runCommand "docker-compose up -d;"
  fi

  removeHTMLFolder
}

removeHTMLFolder() {
  DIR="${WORKDIR}/html"
  if [ -d ${DIR} ]; then
    $ [ "$(ls -A /tmp)" ] && echo "Not Empty" || runCommand "rm -rf ${DIR}"
  fi
}

conposerFunctions() {
  if [ -f "$WORKDIR/composer.lock" ]; then
    commands="composer i --ignore-platform-reqs"
  else
    commands="composer u"
  fi

  runCommand "$phpContainer '$commands'"
}

magentoConfigImport() {
  commands="bin/magento app:config:import"
  runCommand "$phpContainer '$commands'"
}

magentoConfig() {
  commands="
      bin/magento config:set web/secure/use_in_frontend 0 && \
      bin/magento config:set web/secure/use_in_adminhtml 0  && \
      bin/magento config:set web/seo/use_rewrites 0 && \
      bin/magento config:set catalog/search/engine elasticsearch6 && \
      bin/magento config:set catalog/search/enable_eav_indexer 1 && \
      bin/magento config:set catalog/search/elasticsearch6_server_hostname elasticsearch && \
      bin/magento config:set catalog/search/elasticsearch6_server_port 9200 && \
      bin/magento config:set catalog/search/elasticsearch6_index_prefix magento && \
      bin/magento config:set catalog/search/elasticsearch6_enable_auth 0 && \
      bin/magento deploy:mode:set -s ${DEPLOY_MODE} && \
      bin/magento admin:user:create \
        --admin-user=${ADMIN_USER} \
        --admin-password=${ADMIN_PASS} \
        --admin-email=${ADMIN_EMAIL} \
        --admin-firstname=${ADMIN_NAME} \
        --admin-lastname=${ADMIN_SURNAME} "

  runCommand "$phpContainer '$commands'"
}

magentoPreInstall() {
  if [ -f "$WORKDIR/composer.json" ]; then
    conposerFunctions
  else
    commands="composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${MAGENTO_VERSION} .;"
    runCommand "$phpContainer '$commands'"
  fi
}

magentoInstall() {
  commands="bin/magento setup:install \
    --base-url=http://${SHOPURI}/ \
    --db-host=db \
    --db-name=${MYSQL_DATABASE} \
    --db-user=root \
    --db-password=${MYSQL_ROOT_PASSWORD} \
    --backend-frontname=admin \
    --language=de_DE \
    --timezone=Europe/Berlin \
    --currency=EUR \
    --admin-lastname=${ADMIN_NAME} \
    --admin-firstname=${ADMIN_SURNAME} \
    --admin-email=${ADMIN_EMAIL} \
    --admin-user=${ADMIN_USER} \
    --admin-password=${ADMIN_PASS} \
    --cleanup-database \
    --use-rewrites=0 \
    --session-save=redis \
    --session-save-redis-host=/var/run/redis/redis.sock \
    --session-save-redis-db=0 --session-save-redis-password='' \
    --cache-backend=redis \
    --cache-backend-redis-server=/var/run/redis/redis.sock \
    --cache-backend-redis-db=1 \
    --page-cache=redis \
    --page-cache-redis-server=/var/run/redis/redis.sock \
    --page-cache-redis-db=2 \
    --search-engine=elasticsearch7 \
    --elasticsearch-host=elasticsearch \
    --elasticsearch-port=9200"

  runCommand "$phpContainer '$commands'"
}

removeAll() {
  if [ -d "$WORKDIR" ]; then
    commands="rm -rf /var/www/*; rm -rf /var/www/.*"
    runCommand "$phpContainerRoot '$commands'"
  fi
}

restoreAll() {
  git checkout "${WORKDIR}/*"
}

setCredentials() {
  if [ -d "$WORKDIR" ]; then
    runCommand "cp .docker/config_blueprints/auth.json $WORKDIR/auth.json"
  fi
}

magentoSetup() {
  dbDump=".docker/mysql/db_dumps/dev.sql.gz"
  if [ -f $dbDump ]; then
    setCredentials
    conposerFunctions
    magentoConfigImport
    magentoConfig
  else
    magentoPreInstall
    magentoInstall
  fi
}

magentoRefresh() {
  commands="bin/magento se:up && bin/magento ca:cl;"
  runCommand "$phpContainer '$commands'"
}

restoreGitIgnoreAfterComposerInstall() {
  runCommand "git -C $WORKDIR checkout .gitignore"
}

setMagentoCron() {
  commands="bin/magento cron:install"
  runCommand "$phpContainerRoot '$commands'"
}

showDockerLogs() {
  tput setaf 6
  docker logs "$1" --follow
}

setPermissions() {

  commands="
  find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} +
  && find var generated vendor pub/static pub/media app/etc -type d -exec chmod u+w {} +
  && chmod u+x bin/magento
  "
  runCommand "$phpContainerRoot '$commands'"
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

sampleDataInstall() {
  if [[ "$SAMPLE_DATA" == "true" ]]; then
    runCommand "chmod +x bin/sample-data.sh"
    runCommand "bin/sample-data.sh"
  fi
}

MagentoTwoFactorAuthDisable() {
  commands="bin/magento module:disable -c Magento_TwoFactorAuth"
  runCommand "$phpContainer '$commands'"
}

dockerRefresh
magentoSetup
MagentoTwoFactorAuthDisable
magentoRefresh
sampleDataInstall
setMagentoCron >/dev/null
setPermissions
showSuccess "$SHOPURI" "$DUMP"
showDockerLogs "${NAMESPACE}_php"
