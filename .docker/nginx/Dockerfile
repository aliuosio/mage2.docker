FROM nginx:alpine

ARG USER
ARG SHOP_URI
ARG WORKDIR_SERVER

ENV WORKDIR_SERVER=${WORKDIR_SERVER}
ENV SHOP_URI=${SHOP_URI}
ENV USER=${USER}

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

RUN apk update && apk upgrade \
   && apk add --update bash \
   && addgroup -g 3000 -S ${USER} \
   && adduser -u 3000 -S -D -G ${USER} ${USER} \
   && mkdir ${WORKDIR_SERVER} \
   && chown -R ${USER}:${USER} ${WORKDIR_SERVER} \
   && chmod -R 755 ${WORKDIR_SERVER} \
   && sed -i "s#__user#${USER}#g" /etc/nginx/nginx.conf \
   && sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /etc/nginx/conf.d/default.conf \
   && sed -i "s#__shop_uri#${SHOP_URI}#g" /etc/nginx/conf.d/default.conf