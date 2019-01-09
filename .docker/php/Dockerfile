ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

LABEL maintainer="Osiozekhai Aliu"

ARG USER
ARG WORKDIR_SERVER
ARG INSTALL_MAGENTO
ARG INSTALL_MAGENTO_VERSION
ARG INSTALL_SAMPLE_DATA

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV TZ=Europe/Berlin

COPY conf/zz-docker.conf conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/xdebug.ini conf/php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY conf/auth.json.template conf/auth.json* /home/${USER}/.composer/
COPY docker-entrypoint.sh /home/${USER}/
COPY conf/crontab /crontab.${USER}

RUN apk update && apk upgrade
RUN apk add --no-cache --virtual build-dependencies \
        libc-dev \
        bash \
        libxslt-dev \
        libmcrypt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng \
        zip \
        libpng-dev \
    && set -xe \
    && apk add --no-cache tzdata icu git busybox-suid \
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
        mcrypt \
        soap \
        sockets \
        pcntl \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis xdebug \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
    && wget https://files.magerun.net/n98-magerun2.phar \
    && mv n98-magerun2.phar /usr/local/bin/n98-magerun2.phar \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && chmod +x /usr/local/bin/n98-magerun2.phar \
    && chmod +x /home/${USER}/docker-entrypoint.sh \
    && addgroup -g 3000 --system ${USER} \
    && adduser -u 3000 --system -D -G ${USER} ${USER} \
    && mkdir ${WORKDIR_SERVER} \
    && chmod -R 755 ${WORKDIR_SERVER} \
    && sed -i "s#__user#${USER}#g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s#__user#${USER}#g" /usr/local/etc/php-fpm.d/zz-docker.conf \
    && sed -i "s#__WORKDIR_SERVER#${WORKDIR_SERVER}#g" /crontab.${USER} \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && crontab -u ${USER} /crontab.${USER} \
    && chown -R ${USER}:${USER} /home/${USER}/

RUN /home/${USER}/docker-entrypoint.sh $INSTALL_MAGENTO $USER $WORKDIR_SERVER $INSTALL_MAGENTO_VERSION $INSTALL_SAMPLE_DATA
