FROM mariadb:10.5.2
LABEL maintainer="Osiozekhai Aliu"
CMD echo 10 > /proc/sys/vm/swappiness
CMD echo 1048576 > /proc/sys/fs/aio-max-nr
ADD http://mysqltuner.pl /usr/local/bin/mysqltuner.pl
RUN chmod +x /usr/local/bin/mysqltuner.pl