#!/bin/bash

getLatestFromRepo() {
    echo "git fetch && git pull;";
    git fetch && git pull;
}

magentoComposerJson() {
    echo "rm -rf htdocs/.gitkeep;";
    rm -rf htdocs/.gitkeep;

    echo "cp ./.docker/config_blueprints/composer.json htdocs/;";
    cp ./.docker/config_blueprints/composer.json htdocs/;
}

reMoveMagentoEnv() {
    if [ -f htdocs/app/etc/env.php ]; then
        echo "rm -rf htdocs/app/etc/env.php";
        rm -rf htdocs/app/etc/env.php
    fi
}

createEnv() {
    if [ ! -f ./.env ]; then
        echo "cp ./.env.template ./.env";
        cp ./.env.template ./.env
    else
        echo ".env File exists already";
    fi
}

dockerRefresh() {
    if [[ $(uname -s) == "Darwin" ]]; then
        echo "brew install unison";
        brew install unison;

        echo "brew install eugenmayer/dockersync/unox";
        brew install eugenmayer/dockersync/unox;

        echo "gem install docker-sync;";
        sudo gem install docker-sync;

        echo "sed -i '' 's/SSL=true/SSL=false/g' ${PWD}/.env";
        sed -i '' 's/SSL=true/SSL=false/g' ${PWD}/.env

        echo "docker-sync start";
        docker-sync start;

        echo "docker-compose -f docker-compose.osx.yml up -d"
        docker-compose -f docker-compose.osx.yml up -d;
    else
        echo "docker-compose up -d;"
        docker-compose up -d;
    fi;

    sleep 5
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
        --base-url=${url_secure} \
        --base-url-secure=${url_unsecure} \
        --use-secure=${secure} \
        --use-secure-admin=${secure} \
        --language=de_DE \
        --timezone=Europe/Berlin \
        --currency=EUR \
        --admin-lastname=Admin \
        --admin-firstname=Admin \
        --admin-email=admin@example.com \
        --admin-user=admin \
        --admin-password=admin123#T \
        --cleanup-database \
        --use-rewrites=1;";
    docker exec -it -u $1 $3 bin/magento setup:install \
        --db-host=db \
        --db-name=$4 \
        --db-user=$5 \
        --db-password=$6 \
        --backend-frontname=admin \
        --base-url="${url}" \
        --base-url-secure="${url}" \
        --use-secure=0 \
        --use-secure-admin=0 \
        --language=de_DE \
        --timezone=Europe/Berlin \
        --currency=EUR \
        --admin-lastname=Admin \
        --admin-firstname=Admin \
        --admin-email=admin@example.com \
        --admin-user=admin \
        --admin-password=admin123#T \
        --cleanup-database \
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
    cp ./.docker/config_blueprints/env.php ./htdocs/app/etc
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
    if [[ $1 == *"local"* ]]; then
        echo "cd htdocs;";
        cd htdocs;

        echo "curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar;";
        curl -L https://files.magerun.net/n98-magerun2.phar > n98-magerun2.phar;

        echo "chmod +x n98-magerun2.phar";
        chmod +x n98-magerun2.phar;

        echo "cd ..;";
        cd ..;
    fi;
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
    runtime=$((end-start))  

    echo $runtime "Sec";
}

set -e

createEnv

. ${PWD}/.env;

getLatestFromRepo
magentoComposerJson
reMoveMagentoEnv
dockerRefresh
composerPackages ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET} ${SHOP_URI}
install ${USER} ${SHOP_URI} ${NAMESPACE}_php_${PHP_VERSION_SET} ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${SSL}
setDomainAndCookieName ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db ${SHOP_URI}
exchangeMagentoEnv ${USER} ${NAMESPACE}_nginx
magentoRefresh ${USER} ${NAMESPACE}_php_${PHP_VERSION_SET} ${SHOP_URI}
getMagerun ${SHOP_URI}
permissionsSet ${NAMESPACE}_php_${PHP_VERSION_SET}