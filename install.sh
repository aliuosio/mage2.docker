#!/bin/bash

set -e

getLatestFromRepo() {
    echo "git fetch && git pull;";
    git fetch && git pull;
}

createEnv() {
    echo "cp ./.env.template ./.env";
    cp ./.env.template ./.env
}

reMoveMagentoEnv() {
    if [ -f htdocs/app/etc/env.php ]; then
        echo "rm -rf htdocs/app/etc/env.php";
        rm -rf htdocs/app/etc/env.php
    fi
}

exchangeMagentoEnv() {
        docker exec -it -u $1 $2 cp /home/$1/env.php /home/$1/html/app/etc/env.php
}

dockerRefresh() {
    if [[ $(uname -s) == "Darwin" ]]; then

        echo "brew install unison";
        brew install unison;

        echo "brew install eugenmayer/dockersync/unox";
        brew install eugenmayer/dockersync/unox;

        echo "gem install docker-sync;";
        sudo gem install docker-sync;

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

        echo "docker-sync start";
        docker-sync start;

        echo "docker-compose -f docker-compose.osx.yml down"
        docker-compose -f docker-compose.osx.yml down

        echo "docker-compose -f docker-compose.osx.yml build"
        docker-compose -f docker-compose.osx.yml build

        echo "docker-compose -f docker-compose.osx.yml up -d"
        docker-compose -f docker-compose.osx.yml up -d;
    else
        echo "docker-compose down"
        docker-compose down

        echo "docker-compose build"
        docker-compose build

        echo "docker-compose up -d"
        docker-compose up -d;
    fi;

    sleep 5
}

composerPackages() {
        echo "docker exec -it -u $1 $2 composer global require hirak/prestissimo;";
    docker exec -it -u $1 $2 composer global require hirak/prestissimo;

    if [[ $3 == *"local"* ]]; then
        echo "docker exec -it -u $1 $2 composer install;";
        docker exec -it -u $1 $2 composer install;

        echo "docker exec -it -u $1 $2 composer update;";
        docker exec -it -u $1 $2 composer update;
    else
        echo "docker exec -it -u $1 $2 composer install --no-dev;";
        docker exec -it -u $1 $2 composer install --no-dev;

        echo "docker exec -it -u $1 $2 composer update --no-dev;";
        docker exec -it -u $1 $2 composer update --no-dev;
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

install() {
    if [[ $7 == "true" ]]; then
        url="https://$2/";
        secure=1;
    else
        url="http://$2/";
        secure=0;
    fi

    echo "docker exec -it -u $1 $3 chmod +x bin/magento";
    docker exec -it -u $1 $3 chmod +x bin/magento

    echo "docker exec -it -u $1 $3 bin/magento setup:install \
        --db-host=db \
        --db-name=$4 \
        --db-user=$5 \
        --db-password=$6 \
        --backend-frontname=admin \
        --base-url=${url} \
        --base-url-secure=${url} \
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
        --base-url=${url} \
        --base-url-secure=${url} \
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

setDomain() {
    SET_URL_SECURE="USE $1; UPDATE core_config_data SET value='https://$5/' WHERE path='web/secure/base_url';";
    SET_URL_UNSECURE="USE $1; UPDATE core_config_data SET value='http://$5/' WHERE path='web/unsecure/base_url';";
    SET_URL_COOKIE="USE $1; INSERT core_config_data(value, path) VALUES('$5', 'web/cookie/cookie_domain');";

    echo "URL Settings and Cookie Domain START";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_SECURE}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_UNSECURE}";
    docker exec -it $4 mysql -u $2 -p$3 -e "${SET_URL_COOKIE}";
    echo "URL Settings and Cookie Domain END";
}

createHtdocs() {
    if [[ ! -d htdocs ]]; then
        echo "mkdir htdocs";
        mkdir htdocs
    fi
}

createHtdocs
getLatestFromRepo
reMoveMagentoEnv
createEnv

. ${PWD}/.env;

dockerRefresh
composerPackages ${USER} ${NAMESPACE}_php ${SHOP_URI}
install ${USER} ${SHOP_URI} ${NAMESPACE}_php ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${SSL}
setDomain ${NAMESPACE} ${MYSQL_USER} ${MYSQL_PASSWORD} ${NAMESPACE}_db ${SHOP_URI}
exchangeMagentoEnv ${USER} ${NAMESPACE}_nginx
magentoRefresh ${USER} ${NAMESPACE}_php ${SHOP_URI}
getMagerun ${SHOP_URI}
permissionsSet ${NAMESPACE}_php