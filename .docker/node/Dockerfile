ARG NODE_VERSION
ARG NPM_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"
RUN apk update && apk upgrade

RUN apk add bash bash-completion && \
    rm -rf /var/cache/apk/*

RUN npm install -g npm@${NPM_VERSION} && \
    npm install -g gulp