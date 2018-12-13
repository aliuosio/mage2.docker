ARG PHP_VERSION_SET_IMAGE=${PHP_VERSION_SET_IMAGE}

FROM $PHP_VERSION_SET_IMAGE

ARG PHP_VERSION_SET=${PHP_VERSION_SET}
ARG PHP_BUILD_DIR=${PHP_BUILD_DIR}

# Update alpine
RUN apk update && apk upgrade

# set permissions
RUN addgroup -g 3000 -S app
RUN adduser -u 3000 -S -D -G app app

# add alpine linux Packages for PHP
RUN apk add --no-cache --virtual build-dependencies \
    go \
    git \
    aria2 \
    libc-dev \
    bash \
    libxslt-dev \
    libmcrypt-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng \
    aria2 \
    libpng-dev

# install build dependencies for PHP
RUN set -xe \
    && apk add --update \
        icu \
    && apk add --no-cache --virtual .php-deps \
        make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++

# add npm
RUN apk add --update nodejs-npm

# Install GD
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-freetype-dir=/usr/include/freetype2 \
    --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure hash --with-mhash

## install required extensions
RUN docker-php-ext-install \
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
    pcntl

# set server timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN pecl channel-update pecl.php.net

# Install phpredis and xdebug per pecl
RUN pecl install -o -f redis xdebug \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis xdebug

# set php.ini overrides
COPY /conf/php-ini-overrides.ini /usr/local/etc/php/conf.d/php-ini-overrides.ini

# set xdebug
COPY /conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# add mhsendmail (sendmail is forced to use smtp)
RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail

# Set Timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# magerun
RUN wget https://files.magerun.net/n98-magerun2.phar \
    && mv n98-magerun2.phar /usr/local/bin/n98-magerun2.phar \
    && chmod +x /usr/local/bin/n98-magerun2.phar

# Install Ioncube Loader
#RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
#    && tar xvfz ioncube_loaders_lin_x86-64.tar.gz \
#    && rm ioncube_loaders_lin_x86-64.tar.gz \
#    && cp ioncube/ioncube_loader_lin_${PHP_VERSION_SET}.so /usr/local/lib/php/extensions/no-debug-non-zts-${PHP_BUILD_DIR}/ \
#    && rm -rf ioncube \
#    && cd /usr/local/etc/php/conf.d \
#    && touch 00-ioncube.ini \
#    && echo "zend_extension=ioncube_loader_lin_${PHP_VERSION_SET}.so" > 00-ioncube.ini