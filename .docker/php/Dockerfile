ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET:-8.1.29-fpm}
LABEL maintainer="Osiozekhai Aliu"

ARG USER_PHP
ARG GROUP_PHP
ARG ACPU_VERSION
ARG XDEBUG_VERSION
ARG FIXUID_VERSION
ARG WORKDIR_SERVER

# COPY cwebp-120-linux-x86-64 /usr/local/bin/cwebp
COPY ./.docker/php/cwebp-120-linux-x86-64 /usr/local/bin/cwebp

# COPY scripts/* /usr/local/bin/
COPY ./.docker/php/scripts/* /usr/local/bin/

RUN set -eux; \
    apk update && apk upgrade; \
    apk add --no-cache \
        bash \
        bash-completion \
        git \
        icu \
        mysql-client \
        nano \
        npm \
        procps \
        tzdata; \
    apk add --no-cache \
        freetype \
        gettext \
        icu-libs \
        libjpeg-turbo \
        libpng \
        libwebp \
        libxslt \
        libzip \
        zlib; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        freetype-dev \
        g++ \
        gettext-dev \
        icu-dev \
        libc-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxslt-dev \
        libzip-dev \
        linux-headers \
        make \
        zlib-dev; \
    docker-php-ext-configure hash --with-mhash; \
    docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype; \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        ftp \
        gd \
        gettext \
        intl \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip; \
    pecl channel-update pecl.php.net; \
    pecl install -o -f \
        redis \
        apcu-${ACPU_VERSION} \
        xdebug-${XDEBUG_VERSION}; \
    docker-php-ext-enable \
        redis \
        apcu \
        xdebug; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer; \
    curl -sS https://files.magerun.net/n98-magerun2.phar --output /usr/local/bin/magerun2; \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER_PHP\ngroup: $GROUP_PHP\n" > /etc/fixuid/config.yml && \
    chmod +x /usr/local/bin/* &&  \
    mkdir -p /var/run/php/ /var/www-data/.composer &&  \
    docker-php-source delete && \
    apk del .build-deps && \
    rm -rf \
        /tmp/* \
        /var/cache/apk/* \
        /var/tmp/* \
        /usr/share/doc/* \
        /usr/share/man/* \
        /usr/share/php/doc/* \
        /usr/share/php/www.php.net/*

USER $USER_PHP:$GROUP_PHP
