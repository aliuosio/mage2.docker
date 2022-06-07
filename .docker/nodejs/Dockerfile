ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"

ENV USER=node
ENV GROUP=node

RUN apk add --no-cache openssl bash curl dirmngr bash-completion nano tzdata \
    && rm -rf /var/cache/apk/*

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml \
    && chmod +x /usr/local/bin/*

USER $USER:$GROUP