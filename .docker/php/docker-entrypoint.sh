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


runWaitForIt() {
  wait-for-it.sh db:3306
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
    addgroup -g 1000 "$1"
    adduser -D --uid 1000 --ingroup "$1" "$1"
    chown -R "$1":"$1" /home/"$1"
    chmod -R 755 /home/"$1"
    chmod 600 "/home/$1/.ssh/id_rsa"
    chmod 644 "/home/$1/.ssh/id_rsa.pub"
    # shellcheck disable=SC2117
    su "$1"
  fi
}

phpSettings "$USER"
xdebugConfig "${XDEBUG_ENABLE}" "${XDEBUG_PROFILER}" "${XDEBUG_KEY}"
setUser "$USER"
addPathToBashProfile "$USER"
runWaitForIt
php-fpm -F

exec "$@"