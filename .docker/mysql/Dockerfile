FROM mysql:5.7

LABEL maintainer="Osiozekhai Aliu"

ARG TZ
ARG DB_DUMP
ARG USER

COPY conf/dev.cnf /etc/mysql/conf.d/dev.cnf

RUN addgroup --gid 1000 --system ${USER} \
    && adduser --uid 1000 --system --disabled-login --disabled-password --gid 1000 ${USER} \
    && sed -i "s#__user#${USER}#g" /etc/mysql/conf.d/dev.cnf \
    && chown -R ${USER} /var/lib/mysql \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*