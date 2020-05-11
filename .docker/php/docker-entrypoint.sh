#!/bin/sh

set -e

timezoneSet() {
    ln -snf /usr/share/zoneinfo/$1 /etc/localtime \
    && echo $1 > /etc/timezone;
}

permissionsSet() {
     if [[ $(grep -c $1 /etc/passwd) == 0 ]]; then
        adduser -D $1 $1 \
        && usermod -o -u 1000 $1 \
        && chown -R $1:$1 $2;
    fi
}

addPathToBashProfile() {
    echo "export PATH=/home/$1/html/node_modules/.bin:\$PATH" >> /home/$1/.bash_profile ;
}

phpSettings() {
    sed -i "s#__user#$1#g" /usr/local/etc/php-fpm.d/zz-docker.conf;
}

composerInstall() {
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer;
}

xdebugConfig() {
    if [[ $1 = "true" ]]; then \
        pecl install -o -f xdebug;
        docker-php-ext-enable xdebug;
        sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini;
    fi
}

timezoneSet ${TZ}
permissionsSet ${USER} ${WORKDIR_SERVER}
addPathToBashProfile ${USER}
phpSettings ${USER}
composerInstall
xdebugConfig ${XDEBUG_ENABLE}

php-fpm -F

exec "$@"
