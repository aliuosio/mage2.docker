FROM nginx:alpine

COPY conf/default.conf   /etc/nginx/conf.d/default.conf

RUN apk update && apk upgrade \
    && apk add --update bash \
    && addgroup -g 3000 -S app \
    && adduser -u 3000 -S -D -G app app
