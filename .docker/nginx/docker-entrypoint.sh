#!/bin/sh

set -e

# Set Auth Basic
authConfig() {
    if [[ "$1" == "true" ]]; then \
        echo "auth basic setup START";
        printf "$2:$(openssl passwd -crypt $3)\n" >> /etc/nginx/.htpasswd \
        && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default.conf \
        && sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default_ssl.conf;
        echo "auth basic setup END";
    fi
}

mainConfig() {
    ln -sf /usr/share/zoneinfo/Etc/$1  /etc/localtime \
    && echo $1 > /etc/timezone \
    && mkdir -p /etc/letsencrypt/ \
    && sed -i "s#__user#$2#g" /etc/nginx/nginx.conf \
    && sed -i "s#__working_dir#$3#g" /etc/nginx/conf.d/default.conf \
    && sed -i "s#__shop_uri#$4#g" /etc/nginx/conf.d/default.conf \
    && sed -i "s#__working_dir#$3#g" /etc/nginx/conf.d/default_ssl.conf \
    && sed -i "s#__shop_uri#$4#g" /etc/nginx/conf.d/default_ssl.conf \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*;

    if [[ $(grep -c $2 /etc/passwd) == 0 ]]; then
        adduser -D -u 1000 $2 $2 \
        && chown -R $2:$2 $3;
    fi
}

sslConfig() {
    if [[ "$1" == "true" ]]; then \
        echo 'SSL Config START';
        mkdir -p /etc/nginx/ssl \
        && mkdir -p /var/cache/ngx_pagespeed \
        && chown -R $2:$2 /etc/nginx/ssl/ \
        && chown -R $2:$2 /var/cache/ngx_pagespeed \
        && chmod 755 -R /var/cache/ngx_pagespeed \
        && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/privkey.pem -out /etc/nginx/ssl/fullchain.pem -subj /CN=$3 \
        && sed -i "s#__default#default_ssl#g" /etc/nginx/nginx.conf; \
        echo 'SSL Config Stop';
    else \
        echo 'NON SSL Config START';
        sed -i "s#default_ssl#default#g" /etc/nginx/nginx.conf \
        && sed -i "s#__default#default#g" /etc/nginx/nginx.conf;
        echo 'NON SSL Config END';
    fi
}

mainConfig ${TZ} ${USER} ${WORKDIR_SERVER} ${SHOP_URI}
sslConfig ${SSL} ${USER} ${SHOP_URI}
authConfig ${AUTH_CONFIG} ${AUTH_USER} ${AUTH_PASS}

/usr/sbin/nginx -q;

tail -f /dev/null;