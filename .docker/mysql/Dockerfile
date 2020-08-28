ARG MYSQL_VERSION

FROM mysql:${MYSQL_VERSION}

LABEL maintainer="Osiozekhai Aliu"

ARG TZ
ARG DB_DUMP
ARG USER

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*