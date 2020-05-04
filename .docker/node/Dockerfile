ARG IMAGE
FROM $IMAGE
LABEL maintainer="Osiozekhai Aliu"
RUN apk add --update yarn openssl git sudo python \
    && rm -rf /var/cache/apk/*;
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh