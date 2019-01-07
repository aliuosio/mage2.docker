ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

MAINTAINER Osiozekhai Aliu

ARG USER
ARG WORKDIR_SERVER
ARG INSTALL_MAGENTO
ARG INSTALL_MAGENTO_WITH_SAMPLE_DATA

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV TZ=Europe/Berlin
ENV PATH /usr/local/go/bin:$PATH

COPY conf/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY conf/php-ini-overrides.ini /usr/local/etc/php/conf.d/php-ini-overrides.ini
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Update alpine
RUN apk update && apk upgrade \
    && apk add --no-cache --virtual build-dependencies \
    aria2 \
    libc-dev \
    bash \
    libxslt-dev \
    libmcrypt-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng \
    zip \
    tzdata \
    libpng-dev \
    && set -xe \
    && apk add --update \
        icu \
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
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && wget https://files.magerun.net/n98-magerun2.phar \
    && mv n98-magerun2.phar /usr/local/bin/n98-magerun2.phar \
    && chmod +x /usr/local/bin/n98-magerun2.phar \
    && rm -rf /var/cache/apk/* \
    && addgroup -g 3000 --system ${USER} \
    && adduser -u 3000 --system -D -G ${USER} ${USER} \
    && mkdir ${WORKDIR_SERVER} \
    && chown -R ${USER}:${USER} ${WORKDIR_SERVER} \
    && chmod -R 755 ${WORKDIR_SERVER} \
    && sed -i "s#__user#${USER}#g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s#__user#${USER}#g" /usr/local/etc/php-fpm.d/zz-docker.conf

# <!-- mhsendmail Setup Block -->
RUN apk update && apk upgrade \
    && apk add --no-cache go git \
    && rm -rf /var/cache/apk/* \
    && curl -Lsf 'https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf - \
    && go get github.com/mailhog/mhsendmail \
    && cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
# <!-- mhsendmail Setup Block -->

# <!-- Magento 2 Setup Block -->
COPY conf/auth.json  /home/${USER}/.composer/
COPY scripts/install-magento.sh  /home/${USER}/

RUN chmod -R +x /home/${USER}/ \
    && chown -R ${USER}:${USER} /home/${USER}/ \
    && /home/${USER}/install-magento.sh $INSTALL_MAGENTO $USER $WORKDIR_SERVER $INSTALL_MAGENTO_WITH_SAMPLE_DATA
# <!-- Magento 2 Setup Block //-->