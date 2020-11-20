ARG MARIADB_VERSION

FROM mariadb:${MARIADB_VERSION}

LABEL maintainer="Osiozekhai Aliu"

RUN apt-get update -y && apt-get upgrade -y && apt-get install --no-install-recommends  -y wget;
COPY conf/my.cnf /etc/mysql/
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*
CMD echo 10 > /proc/sys/vm/swappiness \
    && echo 1048576 > /proc/sys/fs/aio-max-nr
