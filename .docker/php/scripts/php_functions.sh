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

setMagentoPermissions() {
  commands="find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} + \
  && find var generated vendor pub/static pub/media app/etc -type d -exec chmod u+w {} + \
  && chmod u+x bin/magento"

  runCommand "$commands"
}

sampleDataInstall() {
  commands="php -d memory_limit=-1 bin/magento sampledata:deploy && bin/magento se:up && bin/magento i:rei && bin/magento c:c;"
  runCommand "$commands"
}

sampleDataInstallMustInstall() {
  if [[ "$SAMPLE_DATA" == "true" ]]; then
    sampleDataInstall
  fi
}

MagentoTwoFactorAuthDisable() {
  commands="bin/magento module:disable -c Magento_AdminAdobeImsTwoFactorAuth Magento_TwoFactorAuth"
  runCommand "$commands"
}

setMage2Env() {
  commands="cp ${PWD}/.docker/config_blueprints/* ${WORKDIR}/app/etc/"
  runCommand "$commands"

  commands="bin/magento setup:config:set --db-name=$MYSQL_DATABASE && bin/magento module:enable --all"
  runCommand "$commands"
}

conposerFunctions() {
  commands="composer install --ignore-platform-reqs"
  runCommand "$commands"
}

composerExtraPackages() {
  commands="composer req --dev mage2tv/magento-cache-clean && composer req yireo/magento2-webp2"
  runCommand "$commands"
}

magentoConfigImport() {
  commands="bin/magento app:config:import"
  runCommand "$commands"
}

magentoInstall() {
  commands="bin/magento setup:install --base-url=http://$SHOPURI/ \
  --db-host=/var/run/mysqld/mysqld.sock --db-name=$MYSQL_DATABASE --db-user=root --db-password=$MYSQL_ROOT_PASSWORD \
  --backend-frontname=admin --admin-lastname=$ADMIN_NAME --admin-firstname=$ADMIN_SURNAME --admin-email=$ADMIN_EMAIL \
  --admin-user=$ADMIN_USER --admin-password=$ADMIN_PASS \
  --search-engine=opensearch --opensearch-host=opensearch --opensearch-port=9200 --opensearch-index-prefix=magento --opensearch-timeout=15 \
  --session-save=redis --session-save-redis-host=redis_session --session-save-redis-persistent-id=sess-db0 --session-save-redis-db=0 \
  --cache-backend=redis --cache-backend-redis-server=redis_cache --cache-backend-redis-db=0 \
  --timezone=Europe/Berlin --currency=EUR"
  runCommand "$commands"
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

  runCommand "$commands"
}

magentoPreInstall() {
  commands="composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${MAGENTO_VERSION} ."
  runCommand "$commands"
}

magentoSetup() {
if [ -f "/var/www/html/composer.json" ]; then
    conposerFunctions
  else
    magentoPreInstall
    composerExtraPackages
  fi

  magentoInstall
  magentoConfigImport
  magentoConfig
}
