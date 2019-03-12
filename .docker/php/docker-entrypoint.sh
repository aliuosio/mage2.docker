#!/bin/sh

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& chmod +x /usr/local/bin/composer;

# install magerun2
curl -L https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2.phar \
&& chmod +x /usr/local/bin/n98-magerun2.phar

# composer downloader package to increase download speeds
su -c "composer global require hirak/prestissimo" -s /bin/sh $1

# go to magento root folder
cd $2;

su -c "composer update;" -s /bin/sh $1

# Xdebug Install
if [[ $3 = "true" ]]; then
    pecl install -o -f xdebug;
    docker-php-ext-enable xdebug;
    sed -i "s#xdebug.remote_enable= 0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini;
    sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini;
    sed -i "s#__xdebug_host#$9#g" /usr/local/etc/php/conf.d/xdebug.ini;
    rm -rf /tmp/pear;
fi