#!/bin/bash

set -e

createEnv() {
    if [ ! -f ./.env ]; then
        echo "cp ./.env.template ./.env";
        cp ./.env.template ./.env
    else
        echo ".env File exists already";
    fi
}

getLatestFromRepo() {
    echo "git fetch && git pull;";
    git fetch && git pull;
}

dockerRefresh() {

    echo "docker-compose down -v --remove-orphans;";
    docker-compose down -v --remove-orphans;

    if [[ $(uname -s) == "Darwin" ]]; then
        if [ ! -x "$(command -v brew)" ]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
        if [ ! -x "$(command -v unison)" ]; then
            echo "brew install unison";
            brew install unison;
        fi
        if [ ! -d /usr/local/opt/unox ]; then
            echo "brew install eugenmayer/dockersync/unox";
            brew install eugenmayer/dockersync/unox;
        fi
        if [ ! -x "$(command -v docker-sync)" ]; then
            echo "gem install docker-sync;";
            sudo gem install docker-sync;
        fi

        echo "docker-sync stop";
        docker-sync stop;

        echo "docker-sync clean";
        docker-sync clean;

        echo "docker-sync start";
        docker-sync start;

        echo "sed -i " " 's/SSL=true/SSL=false/g' ${PWD}/.env";
        sed -i "" 's/SSL=true/SSL=false/g' ${PWD}/.env

        echo "docker-compose -f docker-compose.osx.yml up -d"
        docker-compose -f docker-compose.osx.yml up -d;
    else
        echo "docker-compose up -d;"
        docker-compose up -d;
    fi

    echo "Installer Script is put to sleep for 2min due to slow mariadb startup";
    sleep 120;
}

magentoComposerJson() {
    if test ! -f "$3/composer.json"; then
        echo "Magento 2 Fresh Install";
        echo "docker cp -a ./.docker/config_blueprints/composer.json $2:/home/$1/html/composer.json";
        docker cp -a ./.docker/config_blueprints/composer.json $2:/home/$1/html/composer.json
    else
        echo "composer.json found and will be used";
    fi
}

reMoveMagentoEnv() {
    path="$1/app/etc/env.php";
    if [[ -f ${path} ]]; then
        echo "rm ${path};";
        rm ${path};
    fi
}

composerPackages() {
    echo "docker exec -it $2 chown -R $1:$1 /home/$1;";
    docker exec -it $2 chown -R $1:$1 /home/$1;

    echo "docker exec -it -u $1 $2 composer global require hirak/prestissimo;";
    docker exec -it -u $1 $2 composer global require hirak/prestissimo;


    if [[ $3 == *"local"* ]]; then
        echo "docker exec -it -u $1 $2 composer install;";
        docker exec -it -u $1 $2 composer install;
    else
        echo "docker exec -it -u $1 $2 composer install --no-dev;";
        docker exec -it -u $1 $2 composer install --no-dev;
    fi
}

install() {
    if [ "$7" == "true" ]; then
        secure=1;
    else
        secure=0;
    fi

    url_secure="https://$2/";
    url_unsecure="http://$2/";

    echo "docker exec -it -u $1 $3 chmod +x bin/magento";
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
--use-rewrites=1;";
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
 --use-rewrites=1;
}

setDomainAndCookieName() {
    SET_URL_SECURE="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default', 'http://$5/', 'web/unsecure/base_url') ON DUPLICATE KEY UPDATE value='http://$5/', path='web/unsecure/base_url', scope='default';";
    SET_URL_UNSECURE="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default', 'https://$5/', 'web/secure/base_url') ON DUPLICATE KEY UPDATE value='https://$5/', path='web/secure/base_url', scope='default';";
    SET_URL_COOKIE="USE $1; INSERT core_config_data(scope, value, path) VALUES('default', '$5', 'web/cookie/cookie_domain') ON DUPLICATE KEY UPDATE value='$5', path='web/cookie/cookie_domain', scope='default';";

    echo "URL Settings and Cookie Domain START";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_SECURE}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_UNSECURE}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_COOKIE}";
    echo "URL Settings and Cookie Domain END";
}

exchangeMagentoEnv() {
    echo "docker cp -a ./.docker/config_blueprints/env.php $2:/home/$1/html/app/etc/env.php";
    docker cp -a ./.docker/config_blueprints/env.php $2:/home/$1/html/app/etc/env.php
}

elasticConfig() {
    CONFIG_1="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default',  'elasticsearch', 'catalog/search/elasticsearch6_server_hostname') ON DUPLICATE KEY UPDATE value='elasticsearch', path='catalog/search/elasticsearch6_server_hostname', scope='default'";
    CONFIG_2="USE $1; INSERT INTO core_config_data(scope, value, path) VALUES('default',  'elasticsearch6', 'catalog/search/engine') ON DUPLICATE KEY UPDATE value='elasticsearch6', path='catalog/search/engine', scope='default'";

    echo "Elastic Search Config START";
    docker exec -it $4 mysql -u $2 -p$3 -e "${CONFIG_1}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${CONFIG_2}";
    echo "Elastic Search Config END";
}

magentoRefresh() {
    echo "docker exec -it -u $1 $2 bin/magento se:up;";
    docker exec -it -u $1 $2 bin/magento se:up;

    echo "docker exec -it -u $1 $2 bin/magento c:c;";
    docker exec -it -u $1 $2 bin/magento c:c;

    if [[ $3 != *"local"* ]]; then
        echo "docker exec -it -u $1 $2 bin/magento c:e full_page;";
        docker exec -it -u $1 $2 bin/magento c:e full_page;

        echo "docker exec -it -u $1 $2 bin/magento deploy:mode:set production;";
        docker exec -it -u $1 $2 bin/magento deploy:mode:set production;
    fi
}

getMagerun() {
    if [[ $3 == *"local"* ]]; then
        echo "curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar";
        curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar

        echo "chmod +x n98-magerun2.phar";
        chmod +x n98-magerun2.phar

        echo "docker cp -a n98-magerun2.phar $2:/home/$1/html/n98-magerun2.phar";
        docker cp -a n98-magerun2.phar $2:/home/$1/html/n98-magerun2.phar

        echo "rm -rf ./n98-magerun2.phar;";
        rm -rf ./n98-magerun2.phar;
    fi
}

permissionsSet() {
    echo "setting permissions... takes time... It took 90 sec the last time.";

    start=`date +%s`
    echo "docker exec -it $1 find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;";
    docker exec -it $1 find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;

    echo "docker exec -it $1 find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;";
    docker exec -it $1 find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;

    echo "docker exec -it $1 chmod 644 app/etc/env.php"
    docker exec -it $1 chmod 644 app/etc/env.php;

    end=`date +%s`
    runtime=$((end - start))

    echo $runtime "Sec";
}

prompt() {
    read -p "$2" RESPONSE
    echo $($1 ${RESPONSE});
}

workDirCreate() {
    if [[ ! -d "$1" ]]; then
        if ! mkdir -p "$1"; then
            echo "Folder can not be created";
        else
            echo "Folder will be created";
        fi
    else
        echo "Folder already exits";
    fi
}

setPath() {
    if [[ $1 != ${WORKDIR} && ! -z $1 ]]; then
        workDirCreate $1;
        rePlaceInEnv $1 "WORKDIR=";
    fi
}

rePlaceInEnv() {
    pattern=".*$2.*";
    replacement=$2$1;
    envFile=$PWD/.env
    if [[ $(uname -s) == "Darwin" ]]; then
      sed -i "" "s@${pattern}@${replacement}@" "$envFile";
    else
      sed -i "" "s@${pattern}@${replacement}@" "$envFile";
    fi
}

setDomain() {
    if [[ $1 != ${SHOPURI} && ! -z $1 ]]; then
        rePlaceInEnv $1 "SHOPURI=";
    fi
}

setComposerCache() {
    mkdir -p ~/.composer;
}

importDBDump() {
    if [[ $1 != ${DB_DUMP} && ! -z $1 ]]; then
        rePlaceInEnv $1 "DB_DUMP=";
    fi
    if [[ ! -z $1 && -f $1 ]]; then
        echo "docker exec -it ${NAMESPACE}_db mysql -u ${USER} -p${MYSQL_USER} database_name < $1;";
        docker exec -it ${NAMESPACE}_db mysql -u ${USER} -p${MYSQL_USER} database_name < $1;
    fi
}

createEnv

. ${PWD}/.env;

prompt "setPath" "Shop Folder absolute path (current: ${WORKDIR})";
prompt "setDomain" "Domain Name (current: ${SHOPURI})";
setComposerCache
reMoveMagentoEnv ${WORKDIR}
dockerRefresh
magentoComposerJson ${USER} ${NAMESPACE}_nginx ${WORKDIR}
composerPackages ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET} ${SHOPURI}
install ${USER} ${SHOPURI} ${NAMESPACE}_php_${PHP_VERSION_SET} ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${SSL}
prompt "importDbDump" "Import Project DB Dump should you want to use an existing Dump (current: ${DB_DUMP})";
setDomainAndCookieName ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db ${SHOPURI}
exchangeMagentoEnv ${USER} ${NAMESPACE}_nginx
elasticConfig ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db
magentoRefresh ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET} ${SHOPURI}
getMagerun ${USER} ${NAMESPACE}_nginx ${SHOPURI}
permissionsSet ${NAMESPACE}_nginx