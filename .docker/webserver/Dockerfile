FROM httpd:alpine

RUN apk update && apk upgrade

RUN apk add --no-cache bash

COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY conf/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

#RUN set -x \
#    && deluser www-data \
#    && addgroup -g 500 -S www-data \
#    && adduser -u 500 -D -S -G www-data www-data
