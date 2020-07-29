ARG MYSQL_VERSION

FROM mysql:${MYSQL_VERSION}

LABEL maintainer="Osiozekhai Aliu"

ARG TZ
ARG DB_DUMP
ARG USER

RUN addgroup --gid 1000 --system ${USER} \
    && adduser --uid 1000 --system --disabled-login --disabled-password --gid 1000 ${USER} \
    && chown -R ${USER} /var/lib/mysql \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*