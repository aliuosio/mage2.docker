FROM nginx:stable-alpine
LABEL maintainer="Osiozekhai Aliu"
COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade
RUN apk add --update netcat-openbsd shadow bc curl wget nano bash openssl libressl apache2-utils \
    && rm -rf /var/cache/apk/*;