FROM debian:jessie-backports

ARG SHOP_URI

ENV TZ=Europe/Berlin

RUN apt-get update
RUN apt-get install -y letsencrypt -t jessie-backports \
    && mkdir -p /etc/letsencrypt/live/${SHOP_URI} \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/letsencrypt/live/${SHOP_URI}/privkey.pem \
        -out /etc/letsencrypt/live/${SHOP_URI}/fullchain.pem \
        -subj /CN=${SHOP_URI} \
    # && openssl dhparam -out /etc/letsencrypt/live/${SHOP_URI}/dhparam.pem 2048 \
    && ln -sf /usr/share/zoneinfo/Etc/$TZ  /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get purge -y tzdata \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*