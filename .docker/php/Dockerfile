ARG PHP_VERSION_SET_IMAGE

FROM $PHP_VERSION_SET_IMAGE

LABEL maintainer="Osiozekhai Aliu"

ARG PHP_VERSION_SET

RUN apk update && apk upgrade --available \
    && apk add --virtual build-dependencies \
        libc-dev \
        libxslt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
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
    && pecl install -o -f redis imagick \
    && docker-php-ext-enable redis imagick;

RUN if [ $(echo "$PHP_VERSION_SET < 7.2"|bc) -eq 1 ]; then \
        apk add libmcrypt-dev \
        && docker-php-ext-install mcrypt; \
    fi

COPY conf/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh