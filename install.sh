#!/bin/bash

set -e

getLatestFromRepo() {
    echo "git fetch && git pull;";
    git fetch && git pull;
}
reMoveEnv() {
    if [ -f htdocs/app/etc/env.php ]; then
        rm htdocs/app/etc/env.php
    fi
}

exchangeEnv() {
    cp ./.docker/config_blueprints/env.php.sample htdocs/app/etc/env.php
}

dockerRefresh() {
    if [[ $(uname -s) == "Darwin" ]]; then
        sed -i "s#SSL=true#SSL=false#g" ./.env
    fi;

    echo "docker-compose build";
    docker-compose build

    if [[ $(uname -s) == "Darwin" ]]; then
        echo "gem install docker-sync";
        gem install docker-sync;

        echo "docker-sync start;";
        docker-sync start;

        echo "docker-compose -f docker-compose.osx.yml up -d";
        docker-compose -f docker-compose.osx.yml up -d;
    else
        echo "docker-compose up -d;";
        docker-compose up -d;
    fi;
}

composerPackages() {
    docker exec -it -u $1 $2 composer global require hirak/prestissimo;
    docker exec -it -u $1 $2 composer install;

    if [[ $3 == *"local"* ]]; then # remove composer packages in require-dev block
        docker exec -it -u $1 $2 composer update;
    else
        docker exec -it -u $1 $2 composer update --no-dev;
    fi;
}

getMagerun() {
    if [[ $1 == *"local"* ]]; then
        cd htdocs;

        echo "curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar;";
        curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar;

        echo "chmod +x n98-magerun2.phar";
        chmod +x n98-magerun2.phar;

        cd ..;
    fi;
}

reCreateDB() {
    DB_DROP="DROP DATABASE IF EXISTS $1;";
    DB_CREATE="CREATE DATABASE IF NOT EXISTS $1;";

    echo "DROP DATABASE $1;";
    docker exec -it $3 mysql -u root -p$2 -e "${DB_DROP}";

    echo "CREATE DATABASE $1;";
    docker exec -it $3 mysql -u root -p$2 -e "${DB_CREATE}";
}

install() {
    echo "docker exec -it -u $1 $3 chmod +x bin/magento";
    docker exec -it -u $1 $3 chmod +x bin/magento

    echo "docker exec -it -u $1 $3 bin/magento setup:install \
        --db-host='/var/run/mysqld/mysqld.sock' \
        --db-name=$4 \
        --db-user=$5 \
        --db-password=$6 \
        --backend-frontname=admin \
        --base-url=http://$2/ \
        --base-url-secure=https://$2/ \
        --use-secure=0 \
        --use-secure-admin=0 \
        --language=de_DE \
        --timezone=Europe/Berlin \
        --currency=EUR \
        --admin-lastname=Admin \
        --admin-firstname=Admin \
        --admin-email=admin@example.com \
        --admin-user=admin \
        --admin-password=admin123 \
        --cleanup-database \
        --use-rewrites=1;";
    docker exec -it -u $1 $3 bin/magento setup:install \
        --db-host='/var/run/mysqld/mysqld.sock' \
        --db-name=$4 \
        --db-user=$5 \
        --db-password=$6 \
        --backend-frontname=admin \
        --base-url=http://$2/ \
        --base-url-secure=https://$2/ \
        --use-secure=0 \
        --use-secure-admin=0 \
        --language=de_DE \
        --timezone=Europe/Berlin \
        --currency=EUR \
        --admin-lastname=Admin \
        --admin-firstname=Admin \
        --admin-email=admin@example.com \
        --admin-user=admin \
        --admin-password=admin123 \
        --cleanup-database \
        --use-rewrites=1;
}

mailHogConfig() {
    if [[ -f $1$2 ]]; then
        echo "Importing $1$2 START";
        cat $1$2 | docker exec -i $3 mysql -u root -p$4 $5;
        echo "Importing $1$2 END";
    else
        echo "$1$2 not found";
    fi;
}

magentoRefresh() {
    docker exec -it -u $1 $2 bin/magento se:up;
#    docker exec -it -u $1 $2 bin/magento i:rei;
    docker exec -it -u $1 $2 bin/magento c:c;

    if [[ $3 != *"local"* ]]; then
        docker exec -it -u $1 $2 bin/magento c:e full_page;
        docker exec -it -u $1 $2 bin/magento deploy:mode:set production;
    fi
}

permissionsSet() {
    echo "setting permissions... takes time... It took 90 sec the last time.";

    start=`date +%s`
        cd htdocs;

        echo "find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;";
        find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;

        echo "find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;";
        find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;

        echo "chmod 444 app/etc/env.php"
        chmod 444 app/etc/env.php;

        cd ..;
    end=`date +%s`
    runtime=$((end-start))

    echo $runtime "Sec";
}

setDomain() {
    SET_URL_SECURE="USE $1; UPDATE core_config_data SET value='https://$5/' WHERE path='web/secure/base_url';";
    SET_URL_UNSECURE="USE $1; UPDATE core_config_data SET value='http://$5/' WHERE path='web/unsecure/base_url';";
    SET_URL_COOKIE="USE $1; UPDATE core_config_data SET value='$5' WHERE path='web/cookie/cookie_domain';";

    echo "URL Settings and Cookie Domain START";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_SECURE}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_UNSECURE}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_COOKIE}";
    echo "URL Settings and Cookie Domain END";
}

. ${PWD}/.env;

getLatestFromRepo
reMoveEnv
dockerRefresh
composerPackages ${USER} ${NAMESPACE}_php ${SHOP_URI}
install ${USER} ${SHOP_URI} ${NAMESPACE}_php ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD}
setDomain ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db ${SHOP_URI}
exchangeEnv
magentoRefresh ${USER} ${NAMESPACE}_php ${SHOP_URI}
getMagerun ${SHOP_URI}
permissionsSet ${USER}