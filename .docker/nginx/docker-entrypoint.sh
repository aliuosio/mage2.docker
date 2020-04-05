#!/bin/sh

set -e

# Set Auth Basic
authConfig() {
    if [[ "$1" = "true" ]]; then \
        echo "auth basic setup START";
        printf "$2:$(openssl passwd -crypt $3)\n" >> /etc/nginx/.htpasswd \
        && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default.conf \
        && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default_ssl.conf;
        echo "auth basic setup END";
    fi
}

authConfig ${AUTH_CONFIG} ${AUTH_USER} ${AUTH_PASS}

/usr/sbin/nginx;

tail -f /dev/null;