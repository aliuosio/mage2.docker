#!/bin/sh

if [[ $7 = "true" ]]; then
    #HOST_IP=`/sbin/ip route | awk '/default/ { print $3 }'`
    HOST_IP=host.docker.internal
    sed -i "s#__ip#$HOST_IP#g" /usr/local/etc/php/conf.d/xdebug.ini;
fi

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& chmod +x /usr/local/bin/composer;

# install magerun2
curl -L https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2.phar \
&& chmod +x /usr/local/bin/n98-magerun2.phar

# composer downloader package to increase download speeds
su -c "composer global require hirak/prestissimo" -s /bin/sh $2

# go to magento root folder
cd $3;

if [[ $6 = "true" ]]; then
    su -c "composer update" -s /bin/sh $2
fi

# download magento 2
if [[ $1 = "true" ]]; then
    su -c "
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$4 .;
    mkdir -p var/composer_home;
    cp ../.composer/auth.json ./var/composer_home/auth.json;
    composer require --dev msp/devtools --dev mage2tv/magento-cache-clean;
    " -s /bin/sh $2

    # set owner and user permissions on magento folders
    su -c "find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
        find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
        chmod u+x bin/magento;" -s /bin/sh $2
fi

# Magento Sample Data
if [[ $5 = "true" ]]; then
    su -c "bin/magento sampledata:deploy;" -s /bin/sh $2
fi