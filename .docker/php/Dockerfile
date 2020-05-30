ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

LABEL maintainer="Osiozekhai Aliu"

ARG PHP_VERSION_SET

RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

RUN apk add --update --virtual build-dependencies \
        libc-dev \
        libxslt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libzip-dev \
    && set -xe \
    && apk add --update \
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
    && apk add --update --virtual .php-deps \
        make \
    && apk add --update --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-jpeg-dir=/usr/include \
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
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis imagick xdebug \
    && docker-php-ext-enable redis imagick;

RUN if [ $(echo "$PHP_VERSION_SET < 7.2"|bc) -eq 1 ]; then \
        apk add libmcrypt-dev \
        && docker-php-ext-install mcrypt; \
    fi

RUN rm -rf /var/cache/apk/*
COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY conf.d/php-ini-overrides.ini /usr/local/etc/php/conf.d/php-ini-overrides.ini
COPY conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN rm -rf /tmp/pear