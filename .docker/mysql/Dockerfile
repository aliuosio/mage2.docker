FROM mysql:5.7

ARG USER

ENV USER=${USER}
ENV TZ=Europe/Berlin

COPY conf/dev.cnf /etc/mysql/conf.d/dev.cnf

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y \
    && addgroup --gid 3000 --system ${USER} \
    && adduser --uid 3000 --system --disabled-login --disabled-password --gid 3000 ${USER} \
    && sed -i "s#__user#${USER}#g" /etc/mysql/conf.d/dev.cnf \
    && chown -R ${USER} /var/lib/mysql \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

