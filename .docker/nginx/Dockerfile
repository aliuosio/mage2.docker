FROM nginx:alpine

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

RUN apk update && apk upgrade \
   && apk add --update bash \
   && addgroup -g 3000 -S krusty \
   && adduser -u 3000 -S -D -G krusty krusty \
   && mkdir /home/krusty/html \
   && chown -R krusty:krusty /home/krusty/html


