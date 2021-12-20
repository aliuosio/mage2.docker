ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}-fpm-alpine
LABEL maintainer="Osiozekhai Aliu"

ARG user=www
ARG home=/home/www

RUN addgroup -S $user \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home $home \
    --ingroup $user \
    $user \
    && apk add --virtual build-dependencies \
        libc-dev \
        libxslt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
        libwebp-dev \
    && set -xe \
    && apk add \
        git \
        bash \
        bash-completion \
	    nano \
        tzdata \
        icu \
        php7-curl \
        imagemagick-dev \
        imagemagick \
        procps \
        nodejs \
    && apk add --virtual .php-deps \
        make \
    && apk add --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-install gd bcmath intl mysqli pdo_mysql opcache soap sockets xsl zip \
    && pecl channel-update pecl.php.net && pecl install -o -f redis imagick apcu-5.1.21 \
    && docker-php-ext-enable redis imagick apcu \
    && rm -rf /var/cache/apk/* \
    && docker-php-source delete \
    && rm -rf /tmp/pear \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && curl -o /usr/local/bin/n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar \
    && chown -R www:www /var/www \
    && chmod +x /usr/local/bin/composer /usr/local/bin/n98-magerun2.phar

COPY installer.sh sample-data.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/installer.sh /usr/local/bin/sample-data.sh

ADD https://github.com/rosell-dk/webp-convert/raw/master/src/Convert/Converters/Binaries/cwebp-120-linux-x86-64 /usr/local/bin/cwebp