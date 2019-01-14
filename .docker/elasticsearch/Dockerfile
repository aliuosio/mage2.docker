ARG ELASTICSEARCH_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}
#FROM elasticsearch:${ELASTICSEARCH_VERSION}

LABEL maintainer="Osiozekhai Aliu"

RUN cd /usr/share/elasticsearch \
    && bin/elasticsearch-plugin install analysis-phonetic \
    && bin/elasticsearch-plugin install analysis-icu