FROM redis:alpine

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME

ENV TZ=Europe/Berlin

COPY conf/redis.conf /etc/redis.conf

RUN apk update && apk upgrade
RUN apk add --update bash \
    && addgroup -g 3000 --system ${USERNAME} \
    && adduser -u 3000 --system -D -G ${USERNAME} ${USERNAME} \
    && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

CMD /usr/local/bin/redis-server /etc/redis.conf