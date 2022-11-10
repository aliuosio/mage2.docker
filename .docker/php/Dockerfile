ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}
LABEL maintainer="Osiozekhai Aliu"

ENV USER=www-data
ENV GROUP=www-data

RUN apk update && apk upgrade

RUN apk add --no-cache --virtual build-dependencies libc-dev libxslt-dev freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev libwebp-dev curl \
    && set -xe \
    && apk add --no-cache git bash bash-completion nano tzdata icu procps \
    && apk add --no-cache --virtual .php-deps make \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS zlib-dev icu-dev icu-data-full gettext gettext-dev g++ curl-dev \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-install gd bcmath intl gettext pdo_mysql opcache soap sockets xsl zip \
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis apcu-5.1.21 \
    && docker-php-ext-enable redis apcu \
    && rm -rf /var/cache/apk/* \
    && docker-php-source delete \
    && rm -rf /tmp/pear \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && curl -o /usr/local/bin/n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar \
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -  \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && architecture=$(uname -m) \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/$architecture/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8307\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

RUN pecl install xdebug && docker-php-ext-enable xdebug

COPY cwebp-120-linux-x86-64 /usr/local/bin/cwebp

RUN chmod +x /usr/local/bin/*

USER $USER:$GROUP
