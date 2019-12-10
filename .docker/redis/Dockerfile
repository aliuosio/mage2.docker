FROM redis:alpine

LABEL maintainer="Osiozekhai Aliu"

ARG TZ
ARG USER

RUN apk update && apk upgrade --available

RUN ln -sf /usr/share/zoneinfo/Etc/UTC  /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && chmod -R 777 /data \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*
