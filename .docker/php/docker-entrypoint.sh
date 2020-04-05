#!/bin/sh

set -e

# Set xdebug
xdebugConfig() {
    if [[ $1 = "true" ]]; then \
        pecl install -o -f xdebug \
        && docker-php-ext-enable xdebug; \
    fi
}

xdebugConfig ${XDEBUG_ENABLE}

php-fpm -F

exec "$@"