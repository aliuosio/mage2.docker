ARG NODE_VERSION
FROM node:${NODE_VERSION}
LABEL maintainer="Osiozekhai Aliu"

ENV USER=node
ENV GROUP=node
ENV PATH=/home/node/node_modules/.bin:/home/node/.npm-global/bin:$PATH

RUN apk update && apk upgrade \
    && apk add --update make g++  openssl bash dirmngr bash-completion nano tzdata python3 \
    && rm -rf /var/cache/apk/* \
    && chmod +x /usr/local/bin/*

RUN  mkdir /home/$USER/node_modules \
    && mkdir /home/$USER/.npm-global \
    && mkdir /home/$USER/.npm \
    && chown -R $USER:$GROUP /home/$USER