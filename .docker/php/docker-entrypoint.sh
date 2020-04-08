#!/bin/sh

set -e

mainConfig() {
    ln -snf /usr/share/zoneinfo/$1 /etc/localtime \
    && echo $1 > /etc/timezone \
    && addgroup -g 1000 -S $2 \
    && adduser -u 1000 -S -D -G $2 $2 \
    && chown -R $2:$2 /home/$2 \
    && echo "export PATH=/home/$2/html/node_modules/.bin:\$PATH" >> /home/$2/.bash_profile \
    && chmod 775 $3 \
    && sed -i "s#__user#$2#g" /usr/local/etc/php-fpm.d/zz-docker.conf;
}

# get Composer
composerInstall() {
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer;
}

# Set xdebug
xdebugConfig() {
    if [[ $1 = "true" ]]; then \
        pecl install -o -f xdebug \
        && docker-php-ext-enable xdebug; \
    fi
}


mainConfig ${TZ} ${USER} ${WORKDIR_SERVER}
composerInstall
xdebugConfig ${XDEBUG_ENABLE}

php-fpm -F

exec "$@"