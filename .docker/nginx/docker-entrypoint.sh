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
    else
        if [ -f /etc/nginx/.htpasswd ]; then
            rm /etc/nginx/.htpasswd
        fi
        sed -i "s/auth_basic/# auth_basic/g" /etc/nginx/conf.d/default.conf \
        && sed -i "s/auth_basic/# auth_basic/g" /etc/nginx/conf.d/default_ssl.conf;
    fi
}

sslConfig() {
    if [ "$1" = "true" ]; then \
        FILE='/etc/nginx/ssl/privkey.pem';
        if [ ! -f ${FILE} ]; then \
            echo "SSL SETUP START";
            mkdir -p /etc/nginx/ssl \
            && mkdir -p /var/cache/ngx_pagespeed \
            && chown -R $2:$2 /etc/nginx/ssl/ \
            && chown -R $2:$2 /var/cache/ngx_pagespeed \
            && chmod 755 -R /var/cache/ngx_pagespeed \
            && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${FILE} -out /etc/nginx/ssl/fullchain.pem -subj /CN=$3;
            echo "SSL SETUP END";
        fi
        sed -i "s#__default#default_ssl#g" /etc/nginx/nginx.conf;
    else \
        sed -i "s#__default#default#g" /etc/nginx/nginx.conf; \
    fi
}

authConfig ${AUTH_CONFIG} ${AUTH_USER} ${AUTH_PASS}
sslConfig ${SSL} ${USER} ${SHOP_URI}

/usr/sbin/nginx;

tail -f /dev/null;