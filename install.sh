#!/bin/bash

set -e

createEnv() {
    if [ ! -f ./.env ]; then
        echo "cp ./.env.template ./.env"
        cp ./.env.template ./.env
    else
        echo ".env File exists already"
    fi
}

getLatestFromRepo() {
    echo "git fetch && git pull;"
    git fetch && git pull
}

osxExtraPackages() {
    if [ ! -x "$(command -v brew)" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    if [ ! -x "$(command -v unison)" ]; then
        echo "brew install unison"
        brew install unison
    fi
    if [ ! -d /usr/local/opt/unox ]; then
        echo "brew install eugenmayer/dockersync/unox"
        brew install eugenmayer/dockersync/unox
    fi
    if [ ! -x "$(command -v docker-sync)" ]; then
        echo "gem install docker-sync;"
        sudo gem install docker-syncÌ
    fi
}

osxDockerSync() {
    echo "docker-sync stop"
    docker-sync stop;

    echo "docker-sync clean"
    docker-sync clean;

    echo "docker-sync start"
    docker-sync start;
}

dockerRefresh() {
    if [[ $(uname -s) == "Darwin" ]]; then
        osxExtraPackages
        rePlaceInEnv "false" "SSL"

        echo "docker-compose -f docker-compose.osx.yml down --remove-orphans;"
        docker-compose -f docker-compose.osx.yml down --remove-orphans

        osxDockerSync

        echo "docker-compose -f docker-compose.osx.yml up -d"
        docker-compose -f docker-compose.osx.yml up -d
    else
        echo "docker-compose down --remove-orphans;"
        docker-compose down --remove-orphans

        echo "docker-compose up -d;"
        docker-compose up -d
    fi

    echo "Installer Script is put to sleep for 3min due to slow mariadb startup"
    sleep 3m
}

magentoComposerJson() {
    if test ! -f "$3/composer.json"; then
        echo "Magento 2 Fresh Install"
        echo "docker cp -a ./.docker/config_blueprints/composer.json $2:/home/$1/html/composer.json"
        docker cp -a ./.docker/config_blueprints/composer.json $2:/home/$1/html/composer.json
    else
        echo "composer.json found and will be used"
    fi
}

reMoveMagentoEnv() {
    path="$1/app/etc/env.php"
    if [[ -f ${path} ]]; then
        echo "rm ${path};"
        rm ${path}
    fi
}

composerPackagesInstall() {
    echo "docker exec -it $2 chown -R $1:$1 /home/$1;"
    docker exec -it $2 chown -R $1:$1 /home/$1

    echo "docker exec -it -u $1 $2 composer global require hirak/prestissimo;"
    docker exec -it -u $1 $2 composer global require hirak/prestissimo

    if [[ $3 == *"local"* ]]; then
        echo "docker exec -it -u $1 $2 composer install;"
        docker exec -it -u $1 $2 composer install
    else
        echo "docker exec -it -u $1 $2 composer install --no-dev;"
        docker exec -it -u $1 $2 composer install --no-dev
    fi
}

install() {
    if [[ "$7" == "true" ]]; then
        secure=1
    else
        secure=0
    fi

    url_secure="https://$2/"
    url_unsecure="http://$2/"

    echo "docker exec -it -u $1 $3 chmod +x bin/magento"
    docker exec -it -u $1 $3 chmod +x bin/magento

    echo "docker exec -it -u $1 $3 bin/magento setup:install \
--db-host=db \
--db-name=$4 \
--db-user=$5 \
--db-password=$6 \
--backend-frontname=admin \
--base-url=${url_unsecure} \
--base-url-secure=${url_secure} \
--use-secure=${secure} \
--use-secure-admin=${secure} \
--language=de_DE \
--timezone=Europe/Berlin \
--currency=EUR \
--admin-lastname=mage2_admin \
--admin-firstname=mage2_admin \
--admin-email=admin@example.com \
--admin-user=mage2_admin \
--admin-password=mage2_admin123#T \
--cleanup-database \
--use-rewrites=1;"
    docker exec -it -u $1 $3 bin/magento setup:install  \
 --db-host=db  \
 --db-name=$4  \
 --db-user=$5  \
 --db-password=$6  \
 --backend-frontname=admin  \
 --base-url=${url_unsecure}  \
 --base-url-secure=${url_secure}  \
 --use-secure=${secure}  \
 --use-secure-admin=${secure}  \
 --language=de_DE  \
 --timezone=Europe/Berlin  \
 --currency=EUR  \
 --admin-lastname=mage2_admin  \
 --admin-firstname=mage2_admin  \
 --admin-email=admin@example.com  \
 --admin-user=mage2_admin  \
 --admin-password=mage2_admin123#T  \
 --cleanup-database  \
 --use-rewrites=1
}

setDomainAndCookieName() {
    SET_URL_SECURE="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default', 'http://$5/', 'web/unsecure/base_url') ON DUPLICATE KEY UPDATE value='http://$5/', path='web/unsecure/base_url', scope='default';"
    SET_URL_UNSECURE="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default', 'https://$5/', 'web/secure/base_url') ON DUPLICATE KEY UPDATE value='https://$5/', path='web/secure/base_url', scope='default';"
    SET_URL_COOKIE="USE $1; INSERT core_config_data(scope, value, path) VALUES('default', '$5', 'web/cookie/cookie_domain') ON DUPLICATE KEY UPDATE value='$5', path='web/cookie/cookie_domain', scope='default';"

    echo "URL Settings and Cookie Domain START"
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_SECURE}"
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_UNSECURE}"
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_COOKIE}"
    echo "URL Settings and Cookie Domain END"
}

exchangeMagentoEnv() {
    echo "docker cp -a ./.docker/config_blueprints/env.php $2:/home/$1/html/app/etc/env.php"
    docker cp -a ./.docker/config_blueprints/env.php $2:/home/$1/html/app/etc/env.php
}

elasticConfig() {
    CONFIG_1="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default',  'elasticsearch', 'catalog/search/elasticsearch6_server_hostname') ON DUPLICATE KEY UPDATE value='elasticsearch', path='catalog/search/elasticsearch6_server_hostname', scope='default'"
    CONFIG_2="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default',  'elasticsearch6', 'catalog/search/engine') ON DUPLICATE KEY UPDATE value='elasticsearch6', path='catalog/search/engine', scope='default'"

    echo "Elastic Search Config START"
    docker exec -it $4 mysql -u $2 -p$3 -e "${CONFIG_1}"
    docker exec -it $4 mysql -u $2 -p$3 -e "${CONFIG_2}"
    echo "Elastic Search Config END"
}

magentoRefresh() {
    if [[ $4 == "false" ]]; then
        echo "docker exec -it -u $1 $2 bin/magento se:up;"
        docker exec -it -u $1 $2 bin/magento se:up

        echo "docker exec -it -u $1 $2 bin/magento i:rei;"
        docker exec -it -u $1 $2 bin/magento i:rei

        echo "docker exec -it -u $1 $2 bin/magento c:c;"
        docker exec -it -u $1 $2 bin/magento c:c
    fi
    if [[ $3 != *"local"* ]]; then
        echo "docker exec -it -u $1 $2 bin/magento c:e full_page;"
        docker exec -it -u $1 $2 bin/magento c:e full_page

        echo "docker exec -it -u $1 $2 bin/magento deploy:mode:set production;"
        docker exec -it -u $1 $2 bin/magento deploy:mode:set production
    fi
}

getMagerun() {
    if [[ $3 == *"local"* ]]; then
        echo "curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar"
        curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar

        echo "chmod +x n98-magerun2.phar"
        chmod +x n98-magerun2.phar

        echo "docker cp -a n98-magerun2.phar $2:/home/$1/html/n98-magerun2.phar"
        docker cp -a n98-magerun2.phar $2:/home/$1/html/n98-magerun2.phar

        echo "rm -rf ./n98-magerun2.phar;"
        rm -rf ./n98-magerun2.phar
    fi
}

permissionsSet() {
    echo "setting permissions... takes time... It took 90 sec the last time."

    start=$(date +%s)
    echo "docker exec -it $1 find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;"
    docker exec -it $1 find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;

    echo "docker exec -it $1 find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;"
    docker exec -it $1 find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;

    echo "docker exec -it $1 chmod 644 app/etc/env.php"
    docker exec -it $1 chmod 644 app/etc/env.php

    end=$(date +%s)
    runtime=$((end - start))

    echo $runtime "Sec"
}

workDirCreate() {
    if [[ ! -d "$1" ]]; then
        if ! mkdir -p "$1"; then
            echo "Folder can not be created"
        else
            echo "Folder created"
        fi
    else
        echo "Folder already exits"
    fi
}

setAuthConfig() {
    if [[ "$1" == "true" ]]; then
        prompt "rePlaceInEnv" "Login User Name (current: ${AUTH_USER})" "AUTH_USER"
        prompt "rePlaceInEnv" "Login User Password (current: ${AUTH_PASS})" "AUTH_PASS"
    fi
}

setComposerCache() {
    mkdir -p ~/.composer
}

DBDumpImport() {
    if [[ ! -z $1 && -f $1 ]]; then
        echo "docker exec -i ${NAMESPACE}_db mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < $1;"
        docker exec -i ${NAMESPACE}_db mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < $1
    else
        echo "SQL File not found"
    fi
}

createAdminUser() {
    docker exec -it -u $1 $2 bin/magento admin:user:create  \
 --admin-lastname=mage2_admin  \
 --admin-firstname=mage2_admin  \
 --admin-email=admin@example.com  \
 --admin-user=mage2_admin  \
 --admin-password=mage2_admin123#T
}

sampleDataInstall() {
    if [[ "$1" == "true" ]]; then
        chmod +x sample-data.sh
        ./sample-data.sh
    fi
}

rePlaceInEnv() {
    if [[ ! -z "$1" ]]; then
        [[ "$1" == "yes" || "$1" == "y" ]] && value="true" || value=$1
        pattern=".*$2.*"
        replacement="$2=$value"
        envFile="./.env"
        if [[ $(uname -s) == "Darwin" ]]; then
            sed -i "" "s@${pattern}@${replacement}@" ${envFile}
        else
            sed -i "s@${pattern}@${replacement}@" ${envFile}
        fi
    fi
}

prompt() {
    if [[ ! -z "$2" ]]; then
        read -p "$2" RESPONSE
        $($1 "${RESPONSE}" "$3")
    fi
}

createEnv

. ${PWD}/.env
prompt "rePlaceInEnv" "Absolute path to empty folder(fresh install) or running project (current: ${WORKDIR})" "WORKDIR"
prompt "rePlaceInEnv" "Domain Name (current: ${SHOPURI})" "SHOPURI"
prompt "rePlaceInEnv" "Path to Project DB Dump or leave empty for fresh install (current: ${DB_DUMP})" "DB_DUMP"
prompt "rePlaceInEnv" "Which PHP 7 Version? (7.1, 7.2, 7.3) (current: ${PHP_VERSION_SET})" "PHP_VERSION_SET"
prompt "rePlaceInEnv" "Which MariaDB Version? (10.4.10, 10.5.2) (current: ${MARIADB_VERSION})" "MARIADB_VERSION"
prompt "rePlaceInEnv" "Create a login screen? (current: ${AUTH_CONFIG})" "AUTH_CONFIG"
prompt "rePlaceInEnv" "enable Xdebug? (current: ${XDEBUG_ENABLE})" "XDEBUG_ENABLE"
prompt "rePlaceInEnv" "Install Sample Data? (current: ${SAMPLE_DATA})" "SAMPLE_DATA"

. ${PWD}/.env
setAuthConfig "${AUTH_CONFIG}"
workDirCreate "${WORKDIR}"
setComposerCache
reMoveMagentoEnv ${WORKDIR}
dockerRefresh
magentoComposerJson ${USER} ${NAMESPACE}_nginx ${WORKDIR}
composerPackagesInstall ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET} ${SHOPURI}
install ${USER} ${SHOPURI} ${NAMESPACE}_php_${PHP_VERSION_SET} ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${SSL}
exchangeMagentoEnv ${USER} ${NAMESPACE}_nginx
DBDumpImport ${DB_DUMP}
setDomainAndCookieName ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db ${SHOPURI}
createAdminUser ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET}
elasticConfig ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db
sampleDataInstall ${SAMPLE_DATA}
magentoRefresh ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET} ${SHOPURI} ${SAMPLE_DATA}
getMagerun ${USER} ${NAMESPACE}_nginx ${SHOPURI}
permissionsSet ${NAMESPACE}_nginx
