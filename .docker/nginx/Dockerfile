FROM nginx:alpine

ARG USER
ARG SHOP_URI
ARG WORKDIR_SERVER

ENV WORKDIR_SERVER=${WORKDIR_SERVER}
ENV SHOP_URI=${SHOP_URI}
ENV USER=${USER}

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY ssl/host.key /etc/nginx/ssl/host.key
COPY ssl/host.crt /etc/nginx/ssl/host.crt
COPY ssl/dhparam.pem /etc/nginx/ssl/dhparam.pem

RUN apk update && apk upgrade \
   && apk add --update bash \
   && addgroup -g 3000 --system ${USER} \
   && adduser -u 3000 --system -D -G ${USER} ${USER} \
   && mkdir ${WORKDIR_SERVER} \
   && chown -R ${USER}:${USER} ${WORKDIR_SERVER} \
   && chmod -R 755 ${WORKDIR_SERVER} \
   # && chmod -R 400 /etc/nginx/ssl/host.key \
   # && chmod -R 400 /etc/nginx/ssl/host.crt \
   # && chmod -R 400 /etc/nginx/ssl/dhparam.pem \
   && sed -i "s#__user#${USER}#g" /etc/nginx/nginx.conf \
   && sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /etc/nginx/conf.d/default.conf \
   && sed -i "s#__shop_uri#${SHOP_URI}#g" /etc/nginx/conf.d/default.conf