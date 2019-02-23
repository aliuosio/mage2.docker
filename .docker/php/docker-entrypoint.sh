#!/bin/sh

# Xdebug Install and Configure
if [[ $8 = "true" ]]; then
    pecl install -o -f xdebug-2.7;
    docker-php-ext-enable xdebug;
    sed -i "s#__xdebug_host#TEST#g" /usr/local/etc/php/conf.d/xdebug.ini;
fi

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& chmod +x /usr/local/bin/composer;

# install magerun2
curl -L https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2.phar;
chmod +x /usr/local/bin/n98-magerun2.phar

# composer downloader package to increase download speeds
composer global require hirak/prestissimo

if [[ $1 = "true" ]]; then

    # go to magento root folder
    cd $3;

    # download magento
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$4 .;
    mkdir -p var/composer_home;
    cp ../.composer/auth.json ./var/composer_home/auth.json;
    composer require --dev msp/devtools --dev mage2tv/magento-cache-clean;

    # languages
    case $7 in
        de_DE)
            composer require splendidinternet/mage2-locale-de-de;
            ;;
        en_GB)
            composer require cubewebsites/magento2-language-en-gb;
            ;;
        fr_FR)
            composer require mageplaza/magento-2-french-language-pack;
            ;;
        it_IT)
            composer require mageplaza/magento-2-italian-language-pack:dev-master;
            ;;
        es_ES)
            composer require mageplaza/magento-2-spanish-language-pack:dev-master;
            ;;
        pt_PT)
            composer require mageplaza/magento-2-portuguese-language-pack:dev-master;
            ;;
        pt_BR)
            composer require magento2translations/language_pt_br:dev-master;
            ;;
    esac

    # firegento magesetup install
    if [[ $6 = "true" ]]; then
        composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git;
        composer require firegento/magesetup2:dev-develop;
    fi

    # Magento Sample Data
    if [[ $5 = "true" ]]; then
        bin/magento sampledata:deploy;
    fi

    # set owner and user permissions on magento folders
    find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
    find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    chmod u+x bin/magento

fi

chown -R $2:$2 /home/$2;
