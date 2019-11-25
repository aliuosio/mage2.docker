FROM httpd:alpine

LABEL maintainer="Osiozekhai Aliu"

ARG WORKDIR_SERVER
ARG SHOP_URI
ARG AUTH_CONFIG
ARG AUTH_USER
ARG AUTH_PASS
ARG TZ

COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY conf/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

RUN apk update && apk upgrade --available \
    && apk add openssl tzdata curl bc nano bash bash-completion \
    && ln -sf /usr/share/zoneinfo/Etc/$TZ  /etc/localtime \
    && echo $TZ > /etc/timezone \
    && set -x \
    && addgroup -g 1000 -S ${USER} \
    && adduser -u 1000 -D -S -G ${USER} ${USER} \
    && mkdir ${WORKDIR_SERVER} \
    && chown -R  ${USER}:${USER} /home/${USER} \
    && mkdir -p /etc/apache2/ssl \
    && mkdir -p /var/log/apache2 \
    #&& openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    #    -subj "/C=DE/ST=NC/L=Local/O=Dev/CN=${SHOP_URI}" \
    #    -keyout /etc/apache2/ssl/apache.key \
    #    -out /etc/apache2/ssl/apache.crt \
    #&& chmod 444 /etc/apache2/ssl/apache.crt \
    #&& chmod 400 /etc/apache2/ssl/apache.key \
    && openssl genrsa -des3 -passout pass:passwort -out /tmp/key.tmp 2048 \
    && openssl rsa -passin pass:passwort -in /tmp/key.tmp -out /etc/apache2/ssl/apache.key \
    && rm -rf /tmp/key.tmp \
    && openssl req -new -subj "/C=DE/ST=NC/L=Local/O=Dev/CN=${SHOP_URI}" -key /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.csr \
    && openssl x509 -req -days 365 -in /etc/apache2/ssl/apache.csr -signkey /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt \
    && sed -i "s#__user#${USER}#g" /usr/local/apache2/conf/httpd.conf \
    && sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /usr/local/apache2/conf/extra/httpd-vhosts.conf \
    && sed -i "s#__shop_uri#${SHOP_URI}#g" /usr/local/apache2/conf/extra/httpd-vhosts.conf \
    && sed -i "s#__shop_uri#${SHOP_URI}#g" /usr/local/apache2/conf/httpd.conf \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && \
    if [ "$AUTH_CONFIG" = "true" ]; then \
        printf "${AUTH_USER}:$(openssl passwd -crypt ${AUTH_PASS})\n" >> /etc/apache2/.htpasswd; \
        sed -i "s/# AuthType/AuthType/g" /usr/local/apache2/conf/extra/httpd-vhosts.conf; \
        sed -i "s/# AuthName/AuthName/g" /usr/local/apache2/conf/extra/httpd-vhosts.conf; \
        sed -i "s/# AuthUserFile/AuthUserFile/g" /usr/local/apache2/conf/extra/httpd-vhosts.conf; \
        sed -i "s/# Require/Require/g" /usr/local/apache2/conf/extra/httpd-vhosts.conf; \
        sed -i "s/Require all granted/# Require all granted/g" /usr/local/apache2/conf/extra/httpd-vhosts.conf; \
    fi