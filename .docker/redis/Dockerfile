FROM redis:alpine

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG TZ
ARG SOCKET

COPY conf/redis.conf /etc/redis.conf

RUN apk update && apk upgrade
RUN mkdir -p /var/redis/${SOCKET}/ \
    && addgroup -g 1000 --system ${USERNAME} \
    && adduser -u 1000 --system -D -G ${USERNAME} ${USERNAME} \
    && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf \
    && ln -sf /usr/share/zoneinfo/Etc/UTC  /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

CMD /usr/local/bin/redis-server /etc/redis.conf