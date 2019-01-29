ARG PHP_VERSION_SET

ARG NAMESPACE

FROM ${NAMESPACE}/php:${PHP_VERSION_SET}-fpm-alpine

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG WORKDIR_SERVER

COPY conf/crontab /crontab/root

RUN apk add --no-cache --update shadow busybox-suid
RUN rm -rf /var/spool/cron/crontabs \
    && mkdir -m 0644 -p /var/spool/cron/crontabs \
    && sed -i "s#__working_dir#${WORKDIR_SERVER}#g" /crontab/root \
    && sed -i "s#__user#${USERNAME}#g" /crontab/root \
    && cp -f /crontab/root /var/spool/cron/crontabs/

ENTRYPOINT ["crond"]
CMD ["-f", "-S", "-d", "8"]