ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

LABEL maintainer="Osiozekhai Aliu"

ARG WORKDIR_SERVER
ARG PHP_VERSION_SET
ARG XDEBUG_ENABLE
ARG TZ
ARG USER

COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/

RUN apk update && apk upgrade --available \
    && apk add --virtual build-dependencies \
        libc-dev \
        libxslt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng \
        libpng-dev \
        libzip-dev \
    && set -xe \
    && apk add \
        git \
        bash \
        bash-completion \
        shadow \
	    nano \
        tzdata \
        icu \
        imagemagick-dev \
        imagemagick \
        bc \
        yarn \
    && apk add --virtual .php-deps \
        make \
    && apk add --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
    && docker-php-ext-configure gd \
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
    && sed -i "s#__user#${USER}#g" /usr/local/etc/php-fpm.d/zz-docker.conf \
    && addgroup -g 1000 -S ${USER} \
    && adduser -u 1000 -S -D -G ${USER} ${USER} \
    && mkdir $WORKDIR_SERVER \
    && apk del tzdata \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && echo "export PATH=/home/${USER}/html/node_modules/.bin:\$PATH" >> /home/${USER}/.bash_profile \
    && chmod 775 $WORKDIR_SERVER;

RUN if [ $(echo "$PHP_VERSION_SET < 7.2"|bc) -eq 1 ]; then \
        apk add libmcrypt-dev \
        && docker-php-ext-install mcrypt; \
    fi

RUN if [[ $XDEBUG_ENABLE = "true" ]]; then \
        pecl install -o -f xdebug \
        && docker-php-ext-enable xdebug \
        && sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini \
        && sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini; \
    fi

RUN rm -rf /var/cache/apk/* \
    && rm -rf /tmp/pear

COPY conf/composer.json ${WORKDIR_SERVER}/composer.json

RUN chown -R ${USER}:${USER} /home/${USER}
