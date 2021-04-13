ARG NODE_VERSION
FROM node:${NODE_VERSION}-buster-slim
LABEL maintainer="Osiozekhai Aliu"
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    bash bash-completion nano git openssh-client yarn

RUN rm -rf /var/cache/apk/*

RUN yarn global add gulp