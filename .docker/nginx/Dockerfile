FROM nginx:alpine

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG SHOP_URI
ARG WORKDIR_SERVER
ARG AUTH_CONFIG
ARG AUTH_USER
ARG AUTH_PASS

ENV TZ=Europe/Berlin

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

RUN apk update && apk upgrade
RUN apk add --update bash openssl tzdata \
    && ln -sf /usr/share/zoneinfo/Etc/$TZ  /etc/localtime \
    && echo $TZ > /etc/timezone \
    && addgroup -g 3000 --system ${USERNAME} \
    && adduser -u 3000 --system -D -G ${USERNAME} ${USERNAME} \
    && mkdir ${WORKDIR_SERVER} \
    && chown -R ${USERNAME}:${USERNAME} ${WORKDIR_SERVER} \
    && chmod -R 755 ${WORKDIR_SERVER} \
    && mkdir -p /etc/letsencrypt/live/${SHOP_URI} \
    && sed -i "s#__user#${USERNAME}#g" /etc/nginx/nginx.conf \
    && sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /etc/nginx/conf.d/default.conf \
    && sed -i "s#__shop_uri#${SHOP_URI}#g" /etc/nginx/conf.d/default.conf \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

RUN if [ "$AUTH_CONFIG" = "true" ]; then \
        printf "${AUTH_USER}:$(openssl passwd -crypt ${AUTH_PASS})\n" >> /etc/nginx/.htpasswd; \
        sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/default.conf; \
    fi
