FROM httpd:alpine

RUN apk update && apk upgrade

RUN apk add --no-cache bash

COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY conf/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

COPY conf/certificates/server.crt /usr/local/apache/conf/server.crt
COPY conf/certificates/server.key /usr/local/apache/conf/server.key