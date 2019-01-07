FROM nginx:alpine

MAINTAINER Osiozekhai Aliu

ARG USER
ARG SHOP_URI
ARG WORKDIR_SERVER

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

RUN apk update && apk upgrade
RUN apk add --update bash openssl tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && addgroup -g 3000 --system ${USER} \
    && adduser -u 3000 --system -D -G ${USER} ${USER} \
    && mkdir ${WORKDIR_SERVER} \
    && chown -R ${USER}:${USER} ${WORKDIR_SERVER} \
    && chmod -R 755 ${WORKDIR_SERVER} \
    && mkdir /etc/nginx/ssl \
    && openssl req \
        -x509 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -days 365 \
        -nodes \
        -subj /CN=localhost \
    && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 \
    && sed -i "s#__user#${USER}#g" /etc/nginx/nginx.conf \
    && sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /etc/nginx/conf.d/default.conf \
    && sed -i "s#__shop_uri#${SHOP_URI}#g" /etc/nginx/conf.d/default.conf \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*