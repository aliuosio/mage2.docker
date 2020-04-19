FROM debian:stretch-backports

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y letsencrypt -t stretch-backports \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*