FROM redis:alpine

ARG USER
ENV USER=${USER}

COPY conf/redis.conf /etc/redis.conf

RUN apk update && apk upgrade \
    && apk add --update bash \
    && addgroup -g 3000 --system ${USER} \
    && adduser -u 3000 --system -D -G ${USER} ${USER} \
    && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

CMD /usr/local/bin/redis-server /etc/redis.conf