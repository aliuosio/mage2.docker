FROM node:alpine

LABEL maintainer="Osiozekhai Aliu"

RUN apk update && apk upgrade

RUN npm install -g -s --no-progress yarn

# ENTRYPOINT [ "yarn", "install" ,"--non-interactive"]