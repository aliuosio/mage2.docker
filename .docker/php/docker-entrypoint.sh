#!/bin/sh

set -e

# Set xdebug
xdebugConfig() {
    if [[ $1 = "true" ]]; then \
        pecl install -o -f xdebug \
        && docker-php-ext-enable xdebug \
        && sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini \
        && sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini; \
    else
        pecl uninstall xdebug \
        && sed -i "s#xdebug.remote_enable=1#xdebug.remote_enable=0#g" /usr/local/etc/php/conf.d/xdebug.ini \
        && sed -i "s#xdebug.remote_autostart=1#xdebug.remote_autostart=0#g" /usr/local/etc/php/conf.d/xdebug.ini; \
    fi
}

xdebugConfig ${XDEBUG_ENABLE}

php-fpm -F

exec "$@"