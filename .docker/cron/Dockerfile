ARG PHP_VERSION_SET

ARG NAMESPACE

FROM ${NAMESPACE}/php:${PHP_VERSION_SET}-fpm-alpine

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG WORKDIR_SERVER

COPY conf/crontab /crontab.${USERNAME}

RUN sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /crontab.${USERNAME} \
    && crontab -u ${USERNAME} /crontab.${USERNAME}

#CMD ['crond']