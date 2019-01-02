FROM redis:alpine

RUN apk update && apk upgrade \
    && apk add --update bash \
    && addgroup -g 3000 -S app \
    && adduser -u 3000 -S -D -G app app