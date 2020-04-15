ARG MARIADB_VERSION

FROM mariadb:${MARIADB_VERSION}

LABEL maintainer="Osiozekhai Aliu"

COPY conf/my.cnf /etc/mysql/
CMD echo 10 > /proc/sys/vm/swappiness
CMD echo 1048576 > /proc/sys/fs/aio-max-nr
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh