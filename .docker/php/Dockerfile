ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}-fpm-alpine
LABEL maintainer="Osiozekhai Aliu"

RUN apk add --no-cache --update --virtual  \
    build-dependencies \
    nodejs \
    libc-dev \
    bash \
    mariadb-client \
    git \
    libxslt-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng \
    libzip-dev \
    tzdata \
    libpng-dev \
    bzip2-dev \
    aspell \
    gettext-dev \
    bash-completion \
    libwebp-dev \
    wget \
    gmp-dev \
    icu-libs \
    zlib \
    openssh \
    imagemagick \
    imagemagick-libs \
    imagemagick-dev \
    && set -xe \
    && apk add --update \
        icu \
    && apk add --no-cache --virtual .php-deps \
        make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev \
        zlib-dev libxpm-dev \
        g++

RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    calendar \
    exif \
    gettext \
    gd \
    gmp \
    intl \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    zip

RUN pecl channel-update pecl.php.net \
    && pecl install -o -f redis imagick apcu-5.1.21 xdebug
RUN docker-php-ext-enable redis imagick apcu xdebug

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-configure opcache --enable-opcache
RUN apk del .build-deps && rm -rf /var/cache/apk/*

ARG user=www
ARG home=/home/www

RUN addgroup -S $user
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home $home \
    --ingroup $user \
    $user

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN curl -o /usr/local/bin/n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar
RUN chown -R www:www /var/www
COPY installer.sh sample-data.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/composer \
    /usr/local/bin/n98-magerun2.phar \
    /usr/local/bin/installer.sh \
    /usr/local/bin/sample-data.sh

ADD https://github.com/rosell-dk/webp-convert/raw/master/src/Convert/Converters/Binaries/cwebp-120-linux-x86-64 /usr/local/bin/cwebp