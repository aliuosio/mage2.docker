ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG WORKDIR_SERVER
ARG INSTALL_MAGENTO
ARG INSTALL_MAGENTO_VERSION
ARG INSTALL_SAMPLE_DATA
ARG PHP_VERSION_SET
ARG XDEBUG_ENABLE
ARG TZ
ARG LOCALE
ARG COMPOSER_UPDATE_ON_START

COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/
COPY conf/xdebug.ini conf/php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY conf/auth.json /home/$USERNAME/.composer/
COPY docker-entrypoint.sh /usr/local/bin/

RUN apk update && apk upgrade
RUN apk add --no-cache --virtual build-dependencies \
        libc-dev \
        libxslt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng \
        libpng-dev \
    && set -xe \
    && apk add --no-cache \
        git \
        tzdata \
        icu \
        imagemagick-dev \
        imagemagick \
        bc \
        libmemcached-dev \
    && apk add --no-cache --virtual .php-deps \
        make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
    && docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install \
        bcmath \
        mysqli \
        gd \
        intl \
        pdo_mysql \
        opcache \
        xsl \
        zip \
        soap \
        sockets \
        pcntl \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis imagick \
    && docker-php-ext-enable redis imagick \
    && sed -i "s#__user#${USERNAME}#g" /usr/local/etc/php-fpm.d/zz-docker.conf \
    && addgroup -g 1000 -S ${USERNAME} \
    && adduser -u 1000 -S -D -G ${USERNAME} ${USERNAME} \
    && mkdir /home/${USERNAME}/html \
    && chown -R  ${USERNAME}:${USERNAME} /home/${USERNAME} \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && \
    if [ $(echo "$PHP_VERSION_SET < 7.2"|bc) -eq 1 ]; then \
        && apk add --no-cache libmcrypt-dev \
        && docker-php-ext-install mcrypt; \
    fi \
    && \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/pear