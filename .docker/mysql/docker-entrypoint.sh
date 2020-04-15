#!/bin/sh

set -e

apt-get update -y  \
&& apt-get install -y wget  \
&& wget http://mysqltuner.pl/ -O /usr/local/bin/mysqltuner.pl  \
&& wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O /usr/local/bin/basic_passwords.txt \
&& wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv -O /usr/local/bin/vulnerabilities.csv \
&& chmod +x /usr/local/bin/mysqltuner.pl  \
&& apt-get purge -y wget \
&& mysqld_safe;