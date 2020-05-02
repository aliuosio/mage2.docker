ARG IMAGE
FROM $IMAGE
LABEL maintainer="Osiozekhai Aliu"
RUN apk add --update yarn \
    && rm -rf /var/cache/apk/*
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh