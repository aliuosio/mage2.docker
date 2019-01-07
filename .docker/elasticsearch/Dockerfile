ARG ELASTICSEARCH_IMAGE

FROM ${ELASTICSEARCH_IMAGE}

MAINTAINER Osiozekhai Aliu

RUN cd /usr/share/elasticsearch \
    && bin/elasticsearch-plugin install analysis-phonetic \
    && bin/elasticsearch-plugin install analysis-icu