ARG MARIADB_VERSION

FROM mariadb:${MARIADB_VERSION}

LABEL maintainer="Osiozekhai Aliu"

RUN apt-get update -y && apt-get install --no-install-recommends  -y wget tzdata;
COPY conf/my.cnf /etc/mysql/
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*
CMD echo 10 > /proc/sys/vm/swappiness \
    && echo 1048576 > /proc/sys/fs/aio-max-nr
