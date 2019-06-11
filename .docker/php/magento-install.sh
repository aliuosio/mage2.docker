#!/bin/sh

if [[ $1 = "true" ]]; then
    set -e

    echo 'Composer Install';
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer;
    chmod +x /usr/local/bin/composer;

    echo 'Magerun2 Install';
    curl -L https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2.phar \
    && chmod +x /usr/local/bin/n98-magerun2.phar

    echo 'Composer downloader package to increase download speed';
    su -c "composer global require hirak/prestissimo" -s /bin/sh $2

    cd $3;

    echo 'Download Magento Packages';
    su -c "composer install;" -s /bin/sh $2
fi