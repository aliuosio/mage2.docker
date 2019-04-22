ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG WORKDIR_SERVER
ARG PHP_VERSION_SET
ARG XDEBUG_ENABLE
ARG TZ
ARG INSTALL_MAGENTO
ARG INSTALL_MAGENTO_VERSION
ARG INSTALL_SAMPLE_DATA
ARG COMPOSER_UPDATE_ON_START
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD

COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/
COPY conf/xdebug.ini conf/php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY conf/auth.json /home/$USERNAME/.composer/
COPY post-build.sh /usr/local/bin/

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
	    yarn \
	    nano \
        tzdata \
        icu \
        imagemagick-dev \
        imagemagick \
        bc \
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
    && chmod +x /usr/local/bin/post-build.sh \
    && \
    if [ $(echo "$PHP_VERSION_SET < 7.2"|bc) -eq 1 ]; then \
        apk add --no-cache libmcrypt-dev \
        && docker-php-ext-install mcrypt; \
    fi \
    && \
    if [[ $XDEBUG_ENABLE = "true" ]]; then \
        pecl install -o -f xdebug \
        && docker-php-ext-enable xdebug \
        && sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini \
        && sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini; \
    fi \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/pear

RUN post-build.sh \
    $INSTALL_MAGENTO \
    $USERNAME \
    $WORKDIR_SERVER \
    $INSTALL_MAGENTO_VERSION \
    $INSTALL_SAMPLE_DATA \
    $COMPOSER_UPDATE_ON_START \
    $XDEBUG_ENABLE \
    $MYSQL_DATABASE \
    $MYSQL_USER \
    $MYSQL_PASSWORD \
    $SHOP_URI
