#!/bin/bash

set -e

# Set Auth Basic
authConfig() {
  if [[ "$1" == "true" ]]; then
    echo "auth basic setup START"
    printf "$2:$(openssl passwd -crypt "$3")\n" >>/etc/nginx/.htpasswd &&
      sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default.conf &&
      sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default_ssl.conf
    echo "auth basic setup END"
  fi
}

mainConfig() {
  ln -sf /usr/share/zoneinfo/Etc/"$1" /etc/localtime &&
    echo "$1" >/etc/timezone &&
    sed -i "s#__user#$2#g" /etc/nginx/nginx.conf &&
    sed -i "s#osio#$2#g" /etc/nginx/nginx.conf &&
    sed -i "s#__working_dir#$3#g" /etc/nginx/conf.d/default.conf &&
    sed -i "s#htdocs#$3#g" /etc/nginx/conf.d/default.conf &&
    sed -i "s#__shopuri#$4#g" /etc/nginx/conf.d/default.conf &&
    sed -i "s#mage2.localhost#$4#g" /etc/nginx/conf.d/default.conf
}

setUser() {
  if [[ $(grep -c "$1" /etc/passwd) == 0 ]]; then
    addgroup -g 1001 "$1"
    adduser -D --uid 1001 --ingroup "$1" "$1"
  fi
}

mainConfig "$TZ" "$USER" "$WORKDIR_SERVER" "$SHOPURI" "$SHOPALIAS"
authConfig "$AUTH_CONFIG" "$AUTH_USER" "$AUTH_PASS"
setUser "$USER"

/usr/sbin/nginx -g "daemon off; error_log /dev/stderr info;"
# /usr/sbin/nginx -g "daemon off; error_log /dev/stderr debug;";
