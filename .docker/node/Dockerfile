ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"

RUN apk add --no-cache curl openssl bash dirmngr bash-completion nano tzdata \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["docker-entrypoint.sh", "tail", "-f", "/dev/null"]