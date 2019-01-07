FROM elasticsearch:5.6-alpine

MAINTAINER Osiozekhai Aliu

RUN apk update && apk upgrade
RUN cd /usr/share/elasticsearch \
    && bin/elasticsearch-plugin install analysis-phonetic \
    && bin/elasticsearch-plugin install analysis-icu