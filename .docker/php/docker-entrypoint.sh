#!/bin/sh

set -e

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

addPathToBashProfile() {
  echo "export PATH=/var/www/node_modules/.bin:\$PATH" >>/home/php/.bash_profile
}

phpSettings() {
  sed -i "s#__user#php#g" /usr/local/etc/php-fpm.d/zz-docker.conf
}

installComposer() {
  message "Composer 1 Install"
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer &&
    chmod +x /usr/bin/composer &&
    composer self-update --1
}

installMagerun() {
  message "Magerun 2 Install"
  curl https://files.magerun.net/n98-magerun2.phar >/usr/bin/n98-magerun2.phar &&
    chmod +x /usr/bin/n98-magerun2.phar
}

xdebugConfig() {
  path="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
  if "$1" == "true"; then
    pecl channel-update pecl.php.net
    pecl install -o -f xdebug
    docker-php-ext-enable xdebug
    sed -i "s#xdebug.remote_enable=0#xdebug.remote_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s#xdebug.remote_autostart=0#xdebug.remote_autostart=1#g" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s#xdebug.remote_connect_back=0#xdebug.remote_connect_back=1#g" /usr/local/etc/php/conf.d/xdebug.ini
    if "$2" == "true"; then
      sed -i "s#xdebug.profiler_enable=0#xdebug.profiler_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini
    fi
  else
    pecl uninstall xdebug
    if test -f "$path"; then
      rm $path
    fi
    sed -i "s#xdebug.remote_enable=1#xdebug.remote_enable=0#g" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s#xdebug.remote_autostart=1#xdebug.remote_autostart=0#g" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s#xdebug.remote_connect_back=1#xdebug.remote_connect_back=0#g" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s#xdebug.profiler_enable=1#xdebug.profiler_enable=0#g" /usr/local/etc/php/conf.d/xdebug.ini
  fi
}

addPathToBashProfile
phpSettings
installComposer
installMagerun
xdebugConfig "$XDEBUG_ENABLE" "$PROFILER"

php-fpm -F

exec "$@"
