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
ARG XDEBUG_HOST_IP
ARG TZ
ARG LOCALE

COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/
COPY conf/xdebug.ini conf/php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY conf/auth.json.template conf/auth.json* /home/${USERNAME}/.composer/
COPY docker-entrypoint.sh /home/${USERNAME}/

RUN apk update && apk upgrade
RUN apk add --no-cache --virtual build-dependencies \
        libc-dev \
        bash \
        libxslt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng \
        libpng-dev \
        libzip-dev \
        unzip \
        zip \
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
    && rm -rf /tmp/pear \
    && curl -L https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2.phar \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && chmod +x /usr/local/bin/n98-magerun2.phar \
    && chmod +x /home/${USERNAME}/docker-entrypoint.sh \
    && addgroup -g 1000 -S ${USERNAME} \
    && adduser -u 1000 -S -D -G ${USERNAME} ${USERNAME} \
    && mkdir ${WORKDIR_SERVER} \
    && chmod -R 775 ${WORKDIR_SERVER} \
    && sed -i "s#__user#${USERNAME}#g" /usr/local/etc/php-fpm.d/zz-docker.conf \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/

RUN if [ $(echo "$PHP_VERSION_SET < 7.2"|bc) -eq 1 ]; then apk add --no-cache libmcrypt-dev \
        && docker-php-ext-install mcrypt; \
    fi

RUN if [ "$XDEBUG_ENABLE" = "true" ]; then pecl install -o -f xdebug-2.7 \
        && docker-php-ext-enable xdebug \
        && sed -i "s#__xdebug_host#${XDEBUG_HOST_IP}#g" /usr/local/etc/php/conf.d/xdebug.ini; \
    fi

RUN apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/pear

RUN /home/${USERNAME}/docker-entrypoint.sh \
    $INSTALL_MAGENTO \
    $USERNAME \
    $WORKDIR_SERVER \
    $INSTALL_MAGENTO_VERSION \
    $INSTALL_SAMPLE_DATA \
    $FIREGENTO_MAGESETUP \
    $LOCALE