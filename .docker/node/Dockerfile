ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"

RUN apk --no-cache add bash bash-completion nano git openssh-client autoconf yarn
RUN rm -rf /var/cache/apk/*

RUN npm install -g gulp