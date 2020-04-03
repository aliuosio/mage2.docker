#!/bin/sh

set -e

# Set Auth Basic
if [[ "$AUTH_CONFIG" = "true" ]]; then \
    printf "${AUTH_USER}:$(openssl passwd -crypt ${AUTH_PASS})\n" >> /etc/nginx/.htpasswd \
    && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default.conf \
    && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default_ssl.conf;
else
    if [[ -f /etc/nginx/.htpasswd ]]; then
        rm /etc/nginx/.htpasswd
    fi
    sed -i "s/auth_basic/# auth_basic/g" /etc/nginx/conf.d/default.conf \
    && sed -i "s/auth_basic/# auth_basic/g" /etc/nginx/conf.d/default_ssl.conf;
fi

/usr/sbin/nginx;

tail -f /dev/null;