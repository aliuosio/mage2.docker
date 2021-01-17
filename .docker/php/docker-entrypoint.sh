#!/bin/bash

set -e

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

addPathToBashProfile() {
  echo "export PATH=/home/$1/html/node_modules/.bin:\$PATH" >>/home/$1/.bash_profile
}

phpSettings() {
  sed -i "s#__user#$1#g" /usr/local/etc/php-fpm.d/zz-docker.conf
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
    sed -i "s#xdebug.mode=off#xdebug.mode=debug,develop,trace,coverage#g" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s#xdebug.idekey=docker#xdebug.idekey=$3#g" /usr/local/etc/php/conf.d/xdebug.ini
    if "$2" == "true"; then
      sed -i "s#xdebug.profiler_enable=0#xdebug.profiler_enable=1#g" /usr/local/etc/php/conf.d/xdebug.ini
    fi
    rm -rf /tmp/pear
  else
    pecl uninstall xdebug
    if test -f "$path"; then
      rm $path
    fi
    sed -i "s#xdebug.mode=debug,develop,trace,coverage#xdebug.mode=off#g" /usr/local/etc/php/conf.d/xdebug.ini
    if "$2" == "false"; then
      sed -i "s#xdebug.profiler_enable=1#xdebug.profiler_enable=0#g" /usr/local/etc/php/conf.d/xdebug.ini
    fi
  fi
}

setUser() {
  if [[ $(grep -c "$1" /etc/passwd) == 0 ]]; then
    addgroup -g 1000 "$1";
    adduser -D --uid 1000 --ingroup "$1" "$1";
    chown -R "$1":"$1" /home/"$1";
    chmod -R 755 /home/"$1";
    su "$1";
  fi
}

phpSettings "$USER"
installComposer
installMagerun
xdebugConfig "${XDEBUG_ENABLE}" "${XDEBUG_PROFILER}" "${XDEBUG_KEY}"
setUser "$USER"
addPathToBashProfile "$USER"
php-fpm -F

exec "$@"
1
