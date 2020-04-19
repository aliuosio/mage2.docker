FROM debian:stretch-backports

ARG SHOPURI

COPY ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ssl.sh

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y letsencrypt -t stretch-backports \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*