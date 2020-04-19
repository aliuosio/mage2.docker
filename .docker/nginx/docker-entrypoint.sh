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
    && sed -i "s#__shopuri#$4#g" /etc/nginx/conf.d/default.conf \
    && sed -i "s#__working_dir#$3#g" /etc/nginx/conf.d/default_ssl.conf \
    && sed -i "s#__shopuri#$4#g" /etc/nginx/conf.d/default_ssl.conf \
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
        mkdir -p /etc/letsencrypt/live \
        && mkdir -p /var/cache/ngx_pagespeed \
        && chown -R $2:$2 /etc/letsencrypt/live/ \
        && chown -R $2:$2 /var/cache/ngx_pagespeed \
        && chmod 755 -R /var/cache/ngx_pagespeed \
        && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/privkey.pem -out /etc/nginx/ssl/fullchain.pem -subj /CN=$3 \
        && sed -i "s#__default#default_ssl#g" /etc/nginx/nginx.conf;
        echo 'SSL Config Stop';
    else \
        echo 'NON SSL Config START';
        sed -i "s#default_ssl#default#g" /etc/nginx/nginx.conf \
        && sed -i "s#__default#default#g" /etc/nginx/nginx.conf;
        echo 'NON SSL Config END';
    fi
}

Letsencrypt() {
    if [[ $1 != *"local"* ]]; then
        mkdir -p /etc/nginx/ssl/ \
            && /etc/nginx/ssl/ \
            && openssl dhparam -dsaparam -out dhparams.pem 4096;
    fi
}

certCreate() {
    acme.sh --issue -w $D -d $1 -k 4096
}

certInstall() {
    if [[ $1 != *"local"* ]]; then
        acme.sh --installcert -d $1 \
            --keypath /etc/nginx/ssl/$1.key \
            --fullchainpath /etc/nginx/ssl/$1.cer
    fi
}

mainConfig ${TZ} ${USER} ${WORKDIR_SERVER} ${SHOPURI}
sslConfig ${SSL} ${USER} ${SHOPURI}
authConfig ${AUTH_CONFIG} ${AUTH_USER} ${AUTH_PASS}
Letsencrypt ${SHOPURI}
certCreate
certInstall ${SHOPURI}

/usr/sbin/nginx -q;

tail -f /dev/null;