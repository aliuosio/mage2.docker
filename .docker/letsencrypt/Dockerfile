FROM debian:jessie-backports

ARG SHOP_URI
ENV TZ=Europe/Berlin

RUN apt-get update \
  && apt-get install -y letsencrypt -t jessie-backports \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/letsencrypt/live/${SHOP_URI} \
  && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/letsencrypt/live/${SHOP_URI}/privkey.pem \
    -out /etc/letsencrypt/live/${SHOP_URI}/fullchain.pem \
    -subj /CN=${SHOP_URI} \
  && ln -sf /usr/share/zoneinfo/Etc/$TZ  /etc/localtime \
  && echo $TZ > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get purge -y tzdata \
  && apt-get -y autoremove\
  && rm -rf /var/lib/apt/lists/*

