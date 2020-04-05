#!/bin/sh

set -e


mainConfig() {
    ln -snf /usr/share/zoneinfo/1 /etc/localtime \
    && echo 1 > /etc/timezone \
    && addgroup -g 1000 -S $2 \
    && adduser -u 1000 -S -D -G $2 $2 \
    && chown -R $2:$2 /home/$2 \
    && echo "export PATH=/home/$2/html/node_modules/.bin:\$PATH" >> /home/$2/.bash_profile \
    && chmod 775 $3;
}

# Set xdebug
xdebugConfig() {
    if [[ $1 = "true" ]]; then \
        pecl install -o -f xdebug \
        && docker-php-ext-enable xdebug; \
    fi
}

mainConfig ${TZ} ${USER} ${WORKDIR_SERVER}
xdebugConfig ${XDEBUG_ENABLE}

php-fpm -F

exec "$@"