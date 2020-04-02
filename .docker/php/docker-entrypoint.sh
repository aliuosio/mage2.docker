#!/bin/sh

set -e

# Set xdebug
if [[ ${XDEBUG_ENABLE} = "true" ]]; then \
    pecl install -o -f xdebug \
    && docker-php-ext-enable xdebug \
    && sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini; \
fi \

tail -f /dev/null;