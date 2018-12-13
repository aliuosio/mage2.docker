FROM nginx:alpine

RUN apk update && apk upgrade

RUN apk add --update bash

RUN addgroup -g 3000 -S app
RUN adduser -u 3000 -S -D -G app app

COPY conf/nginx.conf            /etc/nginx/nginx.conf
COPY conf/conf.d/default.conf   /etc/nginx/conf.d/default.conf