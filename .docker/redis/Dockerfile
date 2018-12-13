FROM redis:alpine

RUN apk update && apk upgrade

RUN apk add --update bash

# set permissions
RUN addgroup -g 3000 -S app
RUN adduser -u 3000 -S -D -G app app

# COPY ./docker-entrypoint.sh /

# RUN chmod +x /docker-entrypoint.sh

# ENTRYPOINT ["/docker-entrypoint.sh"]