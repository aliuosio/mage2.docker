ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET:-8.1.29-fpm-alpine3.19}
LABEL maintainer="Osiozekhai Aliu"

ARG USER_PHP
ARG GROUP_PHP
ARG ACPU_VERSION
ARG XDEBUG_VERSION
ARG FIXUID_VERSION

COPY ./.docker/php/cwebp-120-linux-x86-64 /usr/local/bin/cwebp
COPY ./.docker/php/scripts/* /usr/local/bin/

# Install dependencies and PHP extensions in a single layer
RUN set -eux; \
    # Update system and install basic tools
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
    \
    # Install build dependencies
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        freetype-dev \
        g++ \
        gettext-dev \
        icu-data-full \
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
    \
    # Configure and install PHP extensions
    docker-php-ext-configure hash --with-mhash; \
    docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype; \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        gettext \
        intl \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip; \
    \
    # Install PECL extensions
    pecl channel-update pecl.php.net; \
    pecl install -o -f \
        redis \
        apcu-${ACPU_VERSION} \
        xdebug-${XDEBUG_VERSION}; \
    docker-php-ext-enable \
        redis \
        apcu \
        xdebug; \
    \
    # Install tools
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer; \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -; \
    curl -sS https://files.magerun.net/n98-magerun2.phar --output /usr/local/bin/magerun2; \
    \
    # Configure permissions and directories
    chmod 4755 /usr/local/bin/fixuid; \
    chmod +x /usr/local/bin/*; \
    mkdir -p /etc/fixuid /var/run/php/; \
    printf "user: %s\ngroup: %s\n" "$USER_PHP" "$GROUP_PHP" > /etc/fixuid/config.yml; \
    chown $USER_PHP:$GROUP_PHP /var/run/php; \
    \
    # Cleanup
    docker-php-source delete; \
    apk del .build-deps; \
    rm -rf \
        /tmp/* \
        /var/cache/apk/* \
        /var/tmp/* \
        /usr/share/doc/* \
        /usr/share/man/* \
        /usr/share/php/doc/* \
        /usr/share/php/www.php.net/* \
        /var/lib/apt/lists/* \
        /var/cache/apk/*

USER $USER_PHP:$GROUP_PHP