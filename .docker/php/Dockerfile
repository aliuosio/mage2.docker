ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}-fpm-alpine
LABEL maintainer="Osiozekhai Aliu"

RUN apk update && apk upgrade
RUN apk add --no-cache --virtual build-dependencies \
        libc-dev libxslt-dev freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev libwebp-dev \
    && set -xe \
    && apk add --no-cache \
        git bash bash-completion nano tzdata icu php7-curl imagemagick-dev imagemagick procps nodejs \
    && apk add --no-cache --virtual .php-deps \
        make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS zlib-dev icu-dev g++

RUN docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-install gd bcmath intl mysqli pdo_mysql opcache soap sockets xsl zip

RUN pecl channel-update pecl.php.net && pecl install -o -f redis imagick apcu-5.1.21
RUN docker-php-ext-enable redis imagick apcu

RUN rm -rf /var/cache/apk/* \
    && docker-php-source delete \
    && rm -rf /tmp/pear

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && curl -o /usr/local/bin/n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar

ADD https://github.com/rosell-dk/webp-convert/raw/master/src/Convert/Converters/Binaries/cwebp-120-linux-x86-64 /usr/local/bin/cwebp

RUN chmod +x /usr/local/bin/*