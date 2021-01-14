#!/bin/sh

set -e

addPathToBashProfile() {
    echo "export PATH=/home/$1/html/node_modules/.bin:\$PATH" >> /home/"$1"/.bash_profile ;
}

phpSettings() {
    sed -i "s#__user#$1#g" /usr/local/etc/php-fpm.d/zz-docker.conf;
    sed -i "s#osio#$1#g" /usr/local/etc/php-fpm.d/zz-docker.conf;
}

composerInstall() {
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && chmod +x /usr/bin/composer;
    composer self-update --1;
}

xdebugConfig() {
    path="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini";
    if "$1" == "true"; then
        pecl channel-update pecl.php.net
        pecl install -o -f xdebug
        docker-php-ext-enable xdebug
        sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini
        sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini
        sed -i "s#xdebug.remote_connect_back=0#xdebug.remote_connect_back=1#g" /usr/local/etc/php/conf.d/xdebug.ini
        if "$2" == "true"; then
            sed -i "s#xdebug.profiler_enable=0#xdebug.profiler_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini
        fi
    else
        pecl uninstall xdebug;
        if test  -f "$path"; then
            rm $path;
        fi
        sed -i "s#xdebug.remote_enable=1#xdebug.remote_enable=0#g" /usr/local/etc/php/conf.d/xdebug.ini;
        sed -i "s#xdebug.remote_autostart=1#xdebug.remote_autostart=0#g" /usr/local/etc/php/conf.d/xdebug.ini;
        sed -i "s#xdebug.remote_connect_back=1#xdebug.remote_connect_back=0#g" /usr/local/etc/php/conf.d/xdebug.ini;
        sed -i "s#xdebug.profiler_enable=1#xdebug.profiler_enable=0#g" /usr/local/etc/php/conf.d/xdebug.ini;
    fi
}

addPathToBashProfile "${USER}"
phpSettings "${USER}"
composerInstall
xdebugConfig "${XDEBUG_ENABLE}" "${PROFILER}"

php-fpm -F

exec "$@"
