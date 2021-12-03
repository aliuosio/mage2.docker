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

setPermissionsComposer() {
  commands="chown -R www:www /home/www/.composer"

  runCommand "$commands"
}

conposerFunctions() {
  if [ -f "$WORKDIR_SERVER/composer.lock" ]; then
    commands="composer i"
  else
    commands="composer u"
  fi

  runCommand "$commands"
}

composerExtraPackages() {
  commands="composer req --dev mage2tv/magento-cache-clean && composer req magepal/magento2-gmailsmtpapp yireo/magento2-webp2"

  runCommand "$commands"
}

magentoConfigImport() {
  commands="bin/magento app:config:import"
  runCommand "$commands"
}

magentoConfigImport() {
  commands="bin/magento app:config:import"
  runCommand "$commands"
}

magentoConfig() {
  commands="
      bin/magento config:set web/secure/use_in_frontend 0 && \
      bin/magento config:set web/secure/use_in_adminhtml 0  && \
      bin/magento config:set web/seo/use_rewrites 0 && \
      bin/magento config:set catalog/search/engine elasticsearch7 && \
      bin/magento config:set catalog/search/enable_eav_indexer 1 && \
      bin/magento config:set catalog/search/elasticsearch7_server_hostname elasticsearch && \
      bin/magento config:set catalog/search/elasticsearch7_server_port 9200 && \
      bin/magento config:set catalog/search/elasticsearch7_index_prefix magento && \
      bin/magento config:set catalog/search/elasticsearch7_enable_auth 0 && \
      bin/magento deploy:mode:set -s $DEPLOY_MODE && \
      bin/magento admin:user:create \
        --admin-user=$ADMIN_USER \
        --admin-password=$ADMIN_PASS \
        --admin-email=$ADMIN_EMAIL \
        --admin-firstname=$ADMIN_NAME \
        --admin-lastname=$ADMIN_SURNAME"

  runCommand "$commands"
}


magentoPreInstall() {
  if [ -f "$WORKDIR/composer.json" ]; then
    conposerFunctions
  else
    commands="composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${MAGENTO_VERSION} .;"

    runCommand "$commands"
  fi
}

composerExtraPackages() {
  commands="composer req --dev mage2tv/magento-cache-clean && composer req magepal/magento2-gmailsmtpapp yireo/magento2-webp2"

  runCommand "$commands"
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

  runCommand "$commands"
}

magentoSetup() {
  dbDump=".docker/mysql/db_dumps/dev.sql.gz"
  if [ -f $dbDump ]; then
    conposerFunctions
    composerExtraPackages
    magentoConfigImport
    magentoConfig
  else
    magentoPreInstall
    composerExtraPackages
    magentoInstall
  fi
}

setMagentoCron() {
  commands="bin/magento cron:install"
  runCommand "$commands"
}

magentoSetup
setPermissionsComposer
setMagentoCron