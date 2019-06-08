#!/bin/sh

set -e

echo 'Composer Install BEGIN';
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer;
chmod +x /usr/local/bin/composer;
echo 'Composer Install END';

echo 'Magerun2 Install BEGIN';
curl -L https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2.phar \
&& chmod +x /usr/local/bin/n98-magerun2.phar
echo 'Magerun2 Install END';

echo 'Composer downloader package to increase download speeds BEGIN';
su -c "composer global require hirak/prestissimo" -s /bin/sh $2
echo 'Composer downloader package to increase download speeds END';

# go to magento root folder
cd $3;

if [[ $1 = "true" ]]; then
	echo 'Downloading Magento 2 BEGIN';
    su -c "
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$4 .;
    mkdir -p var/composer_home;
    cp ../.composer/auth.json ./var/composer_home/auth.json;
    " -s /bin/sh $2

    echo 'Install Magento 2 Extra Packages';
    # su -c "composer require magenerds/language-de_de;" -s /bin/sh $2
    su -c "composer require --dev msp/devtools mage2tv/magento-cache-clean;" -s /bin/sh $2
    echo 'Downloading Magento 2 END';
fi

if [[ $5 = "true" ]]; then
	echo 'Downloading Sample Data BEGIN';
    su -c "bin/magento sampledata:deploy;" -s /bin/sh $2
    echo 'Downloading Sample Data END';
fi

if [[ $6 = "true" ]]; then
    echo 'Composer install and update BEGIN';
    su -c "composer install; composer update" -s /bin/sh $2
    echo 'Composer install and update END';
fi

echo 'Set owner and user permissions on magento folders';
su -c "find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chmod u+x bin/magento;" -s /bin/sh $2
echo 'Downloading Magento 2 END';
