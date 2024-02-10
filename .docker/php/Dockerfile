ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}
LABEL maintainer="Osiozekhai Aliu"

ENV USER=www-data
ENV GROUP=www-data
ENV XDEBUG_VERSION=2.8
ENV FIXUID_VERSION=0.6.0

COPY cwebp-120-linux-x86-64 /usr/local/bin/cwebp

RUN apk update && apk upgrade
RUN apk add --update linux-headers

RUN apk add --virtual build-dependencies libc-dev libxslt-dev freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev libwebp-dev curl
RUN set -xe
RUN apk add git bash bash-completion nano tzdata icu procps libmcrypt-dev
RUN apk add --virtual .php-deps make
RUN apk add --virtual .build-deps $PHPIZE_DEPS zlib-dev icu-dev gettext gettext-dev g++ curl-dev
RUN docker-php-ext-configure hash --with-mhash
RUN docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype
RUN docker-php-ext-install gd bcmath intl gettext pdo_mysql opcache soap sockets xsl zip mcrypt

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v$FIXUID_VERSION/fixuid-$FIXUID_VERSION-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -  \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml



RUN curl https://files.magerun.net/n98-magerun2.phar --output /usr/local/bin/magerun2 \
    && chmod +x /usr/local/bin/* \
    && mkdir -p /var/run/php/ && chown $USER:$GROUP /var/run/php

RUN cd /tmp \
	&& curl -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.0.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    &&  echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name ioncube_loader_lin_7.0.so)"  > /usr/local/etc/php/conf.d/00_ioncube_loader.ini

# RUN apk add npm
USER $USER:$GROUP