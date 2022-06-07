ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
LABEL maintainer="Osiozekhai Aliu"

RUN apk add --no-cache openssl bash curl dirmngr bash-completion nano tzdata \
    && rm -rf /var/cache/apk/*