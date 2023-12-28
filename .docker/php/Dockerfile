ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}
LABEL maintainer="Osiozekhai Aliu"

ENV USER=www-data
ENV GROUP=www-data
ENV ACPU_VERSION=5.1.23
ENV XDEBUG_VERSION=3.3.1
ENV FIXUID_VERSION=0.6.0

RUN apk update && apk upgrade
RUN apk add --update linux-headers

RUN apk add --virtual build-dependencies libc-dev libxslt-dev freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev libwebp-dev curl \
    && set -xe \
    && apk add git bash bash-completion nano tzdata icu procps \
    && apk add --virtual .php-deps make \
    && apk add --virtual .build-deps $PHPIZE_DEPS zlib-dev icu-dev icu-data-full gettext gettext-dev g++ curl-dev \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-install gd bcmath intl gettext pdo_mysql opcache soap sockets xsl zip

RUN pecl channel-update pecl.php.net \
    && pecl install -o -f redis apcu-$ACPU_VERSION xdebug-$XDEBUG_VERSION \
    && docker-php-ext-enable redis apcu xdebug \
    && rm -rf /var/cache/apk/* \
    && docker-php-source delete \
    && rm -rf /tmp/pear

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v$FIXUID_VERSION/fixuid-$FIXUID_VERSION-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -  \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

COPY cwebp-120-linux-x86-64 /usr/local/bin/cwebp

RUN curl https://files.magerun.net/n98-magerun2.phar --output /usr/local/bin/magerun2 \
    && chmod +x /usr/local/bin/* \
    && mkdir -p /var/run/php/ && chown $USER:$GROUP /var/run/php

RUN apk add npm
USER $USER:$GROUP