FROM debian:stretch-backports

ARG SHOP_URI

RUN apt-get install -y letsencrypt -t stretch-backports \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/letsencrypt/live/${SHOP_URI} \
  && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/letsencrypt/live/${SHOP_URI}/privkey.pem \
    -out /etc/letsencrypt/live/${SHOP_URI}/fullchain.pem \
    -subj /CN=${SHOP_URI}