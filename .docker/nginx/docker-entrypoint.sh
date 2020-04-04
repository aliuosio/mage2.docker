#!/bin/sh

set -e

# Set Auth Basic
if [[ "$AUTH_CONFIG" = "true" ]]; then \
    echo "auth basic setup START";
    printf "${AUTH_USER}:$(openssl passwd -crypt ${AUTH_PASS})\n" >> /etc/nginx/.htpasswd \
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

if [ "$SSL" = "true" ]; then \
    echo "SSL SETUP START";
    mkdir -p /etc/nginx/ssl \
    && mkdir -p /var/cache/ngx_pagespeed \
    && chown -R ${USER}:${USER} /etc/nginx/ssl/ \
    && chown -R ${USER}:${USER} /var/cache/ngx_pagespeed \
    && chmod 755 -R /var/cache/ngx_pagespeed \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/privkey.pem -out /etc/nginx/ssl/fullchain.pem -subj /CN=${SHOP_URI} \
    && sed -i "s#__default#default_ssl#g" /etc/nginx/nginx.conf; \
    echo "SSL SETUP END";
else \
    sed -i "s#__default#default#g" /etc/nginx/nginx.conf; \
fi

/usr/sbin/nginx;

tail -f /dev/null;