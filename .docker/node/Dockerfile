ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"

ENV USER=node
ENV GROUP=node

RUN apk update \
    && apk add curl openssl bash dirmngr bash-completion nano tzdata python3 \
    && rm -rf /var/cache/apk/* \
    && chmod +x /usr/local/bin/* \
    && mkdir /home/$USER/node_modules \
    && mkdir /home/$USER/.npm-global \
    && mkdir /home/$USER/.npm \
    && chown -R $USER:$GROUP /home/$USER \
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

RUN npm config set prefix "/home/node/.npm-global" \
    && npm install --location=global node-gyp \
    && npm install --location=global create-razzle-app

USER $USER:$GROUP

ENV PATH=/home/node/node_modules/.bin:$PATH
ENV PATH=/home/node/.npm-global/bin:$PATH