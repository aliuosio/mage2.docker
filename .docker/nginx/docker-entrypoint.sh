#!/bin/sh

set -e

# set time
ln -sf /usr/share/zoneinfo/Etc/${TZ}  /etc/localtime \
&& echo ${TZ} > /etc/timezone;

# make directories and set permissions
addgroup -g 1000 --system ${USER} \
&& adduser -u 1000 --system -D -G ${USER} ${USER} \
&& mkdir ${WORKDIR_SERVER} \
&& chown -R ${USER}:${USER} ${WORKDIR_SERVER} \
&& chmod -R 755 ${WORKDIR_SERVER} \
&& mkdir -p /etc/letsencrypt/

# nginx config
sed -i "s#__user#${USER}#g" /etc/nginx/nginx.conf \
&& sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /etc/nginx/conf.d/default.conf \
&& sed -i "s#__shop_uri#${SHOP_URI}#g" /etc/nginx/conf.d/default.conf \
&& sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /etc/nginx/conf.d/default_ssl.conf \
&& sed -i "s#__shop_uri#${SHOP_URI}#g" /etc/nginx/conf.d/default_ssl.conf \
&& apk del tzdata \
&& rm -rf /var/cache/apk/*

# set SSL
if [[ "$SSL" = "true" ]]; then \
    mkdir -p /etc/nginx/ssl \
    && mkdir -p /var/cache/ngx_pagespeed \
    && chown -R ${USER}:${USER} /etc/nginx/ssl/ \
    && chown -R ${USER}:${USER} /var/cache/ngx_pagespeed \
    && chmod 755 -R /var/cache/ngx_pagespeed \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/privkey.pem -out /etc/nginx/ssl/fullchain.pem -subj /CN=${SHOP_URI} \
    && openssl dhparam -out /etc/nginx/dhparam.pem 2048 \
    && sed -i "s#__default#default_ssl#g" /etc/nginx/nginx.conf; \
else \
    sed -i "s#__default#default#g" /etc/nginx/nginx.conf; \
fi

# Set Auth Basic
if [[ "$AUTH_CONFIG" = "true" ]]; then \
    printf "${AUTH_USER}:$(openssl passwd -crypt ${AUTH_PASS})\n" >> /etc/nginx/.htpasswd \
    && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default.conf \
    && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default_ssl.conf; \
fi

/usr/sbin/nginx;

tail -f /dev/null;