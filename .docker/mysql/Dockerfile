ARG MARIADB_VERSION

FROM mariadb:${MARIADB_VERSION}

LABEL maintainer="Osiozekhai Aliu"

COPY conf/my.cnf /etc/mysql/
CMD echo 10 > /proc/sys/vm/swappiness
CMD echo 1048576 > /proc/sys/fs/aio-max-nr

ADD http://mysqltuner.pl /usr/local/bin/mysqltuner.pl
RUN chmod +x /usr/local/bin/mysqltuner.pl