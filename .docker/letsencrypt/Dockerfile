FROM debian:jessie-backports

ARG SHOP_URI

RUN apt-get update \
    && apt-get install -y letsencrypt -t jessie-backports \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/ssl \
    && openssl req \
        -x509 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -days 365 \
        -nodes \
        -subj /CN=${SHOP_URI} \
    && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048