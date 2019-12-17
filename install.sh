#!/bin/bash

set -e

getLatestFromRepo() {
    echo "git fetch && git pull;";
    git fetch && git pull;
}

createEnv() {
    if [ ! -f ./.env ]; then
        if [ -f ./.env.template ]; then
            echo "cp ./.env.template ./.env";
            cp ./.env.template ./.env
        fi;
    fi;
}

reMoveMagentoEnv() {
    if [ -f htdocs/app/etc/env.php ]; then
        echo "rm -rf htdocs/app/etc/env.php";
        rm -rf htdocs/app/etc/env.php
    fi
}

exchangeMagentoEnv() {
    echo "mkdir -p htdocs/app/etc/;";
    mkdir -p htdocs/app/etc/;

    echo "cp ./.docker/config_blueprints/env.php.sample htdocs/app/etc/env.php";
    cp ./.docker/config_blueprints/env.php.sample htdocs/app/etc/env.php
}

dockerRefresh() {
    if [[ $(uname -s) == "Darwin" ]]; then

        echo "brew install unison";
        brew install unison;

        echo "brew install eugenmayer/dockersync/unox";
        brew install eugenmayer/dockersync/unox;

        echo "gem install --user-install docker-sync;";
        gem install --user-install docker-sync;

        if which ruby >/dev/null && which gem >/dev/null; then
            PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
            if [ -f ~/.bash_profile ]; then
                echo "source ~/.bash_profile";
                source ~/.bash_profile

                echo "source ~/.profile";
                source ~/.profile

                echo "source ~/.bashrc";
                source ~/.bashrc
            fi
        fi

        echo "sed -i '' 's/SSL=true/SSL=false/g' ${PWD}/.env";
        sed -i '' 's/SSL=true/SSL=false/g' ${PWD}/.env

        echo "docker-compose -f docker-compose.osx.yml down -v --remove-orphans";
        docker-compose -f docker-compose.osx.yml down -v --remove-orphans;

        echo "docker-sync start";
        docker-sync start;

        echo "docker-compose -f docker-compose.osx.yml build"
        docker-compose -f docker-compose.osx.yml build

        echo "docker-compose -f docker-compose.osx.yml up -d"
        docker-compose -f docker-compose.osx.yml up -d;
    else
        echo "docker-compose down -v --remove-orphans";
        docker-compose down -v --remove-orphans;

        echo "docker-compose build"
        docker-compose build

        echo "docker-compose up -d"
        docker-compose up -d;
    fi;
}

composerPackages() {
    echo "docker exec -it -u $1 $2 composer global require hirak/prestissimo;";
    docker exec -it -u $1 $2 composer global require hirak/prestissimo;

    echo "docker exec -it -u $1 $2 composer install;";
    docker exec -it -u $1 $2 composer install;

    if [[ $3 != *"local"* ]]; then # remove composer packages in require-dev block
        echo "docker exec -it -u $1 $2 composer update --no-dev;";
        docker exec -it -u $1 $2 composer update --no-dev;
    fi;
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
        --db-host=db \
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
    echo "docker exec -it -u $1 $2 bin/magento se:up;";
    docker exec -it -u $1 $2 bin/magento se:up;

    # echo docker exec -it -u $1 $2 bin/magento i:rei;";
    # docker exec -it -u $1 $2 bin/magento i:rei;

    echo "docker exec -it -u $1 $2 bin/magento c:c;";
    docker exec -it -u $1 $2 bin/magento c:c;

    if [[ $3 != *"local"* ]]; then
        echo "docker exec -it -u $1 $2 bin/magento c:e full_page;";
        docker exec -it -u $1 $2 bin/magento c:e full_page;

        echo "docker exec -it -u $1 $2 bin/magento deploy:mode:set production;";
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

getLatestFromRepo
reMoveMagentoEnv
createEnv

. ${PWD}/.env;

dockerRefresh
composerPackages ${USER} ${NAMESPACE}_php ${SHOP_URI}
install ${USER} ${SHOP_URI} ${NAMESPACE}_php ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD}
setDomain ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db ${SHOP_URI}
exchangeMagentoEnv
magentoRefresh ${USER} ${NAMESPACE}_php ${SHOP_URI}
getMagerun ${SHOP_URI}
permissionsSet ${USER}