ARG PHP_VERSION_SET
FROM php:${PHP_VERSION_SET}-fpm-bullseye
LABEL maintainer="Osiozekhai Aliu"

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd www \
    && useradd -m -g www -s /bin/bash www \
    && mkdir -p /home/www/bin

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get upgrade -y
RUN apt-get -y install \
        mariadb-client \
        ghostscript \
        git \
        libbz2-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libfreetype6-dev \
        libgmp-dev \
        libmagickwand-dev \
        libmagickcore-dev \
        libicu-dev \
        libxslt1-dev \
        libyaml-dev \
        libzip-dev \
        zip \
        unzip \
        aspell \
        aspell-en aspell-es aspell-de aspell-fr \
        bash-completion \
        bc \
        vim \
        nano \
        cron \
        wget \
        nodejs \
        libwebp-dev \
        freetype*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp;
#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype2 --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include;

RUN docker-php-ext-configure \
  opcache --enable-opcache

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

RUN apt-get clean && apt-get autoclean && apt-get autoremove \
    && rm -rf /var/lib/apt-get/lists/* \
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis imagick apcu-5.1.20 xdebug \
    && docker-php-ext-enable redis imagick apcu xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/home/www/bin/ --filename=composer \
    && chmod +x /home/www/bin/composer \
    && curl -o /home/www/bin/n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar \
    && chmod +x /home/www/bin/n98-magerun2.phar \
    && curl -sS https://accounts.magento.cloud/cli/installer | php -- --install-dir=/home/www/bin/ --filename=magento-cloud \
    && echo "PATH=/var/www/node_modules/.bin:\$PATH" >>/home/www/.profile \
    && echo "alias ll='ls -lha'" >>/home/www/.profile \
    && chown -R www:www /home/www/bin \
    && chown -R www:www /var/www;

ADD https://github.com/rosell-dk/webp-convert/raw/master/src/Convert/Converters/Binaries/cwebp-120-linux-x86-64 /usr/local/bin/cwebp
RUN chmod +x /usr/local/bin/cwebp

COPY start.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start.sh