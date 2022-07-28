ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"

ENV USER=node
ENV GROUP=node
ENV PATH=/home/node/node_modules/.bin:/home/node/.npm-global/bin:$PATH

RUN apk add --update alpine-sdk curl openssl bash dirmngr bash-completion nano tzdata python3 \
    && rm -rf /var/cache/apk/* \
    && chmod +x /usr/local/bin/*