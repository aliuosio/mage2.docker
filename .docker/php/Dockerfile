ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}
LABEL maintainer="Osiozekhai Aliu"

ARG USER_PHP
ARG GROUP_PHP
ARG ACPU_VERSION
ARG XDEBUG_VERSION
ARG FIXUID_VERSION

COPY ./.docker/php/cwebp-120-linux-x86-64 /usr/local/bin/cwebp
COPY ./.docker/php/scripts/* /usr/local/bin/

RUN apk update && apk upgrade \
    && apk add --update linux-headers \
    && apk add --virtual build-dependencies libc-dev libxslt-dev freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev libwebp-dev curl \
    && set -xe \
    && apk add npm bash bash-completion nano tzdata icu procps git \
    && apk add --virtual .php-deps make \
    && apk add --virtual .build-deps $PHPIZE_DEPS zlib-dev icu-dev icu-data-full gettext gettext-dev g++ curl-dev \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-install gd bcmath intl gettext pdo_mysql opcache soap sockets xsl zip \
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis apcu-$ACPU_VERSION xdebug-$XDEBUG_VERSION \
    && docker-php-ext-enable redis apcu xdebug \
    && rm -rf /var/cache/apk/* \
    && docker-php-source delete \
    && rm -rf /tmp/pear \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v$FIXUID_VERSION/fixuid-$FIXUID_VERSION-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER_PHP\ngroup: $GROUP_PHP\n" > /etc/fixuid/config.yml \
    && curl https://files.magerun.net/n98-magerun2.phar --output /usr/local/bin/magerun2 \
    && mkdir -p /var/run/php/ && chown $USER_PHP:$GROUP_PHP /var/run/php

RUN chmod +x /usr/local/bin/*

USER $USER_PHP:$GROUP_PHP