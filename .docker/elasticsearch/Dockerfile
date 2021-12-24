ARG ELASTICSEARCH_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}
LABEL maintainer="Osiozekhai Aliu"
RUN yum update -y
RUN elasticsearch-plugin list | grep analysis-icu || elasticsearch-plugin install -b analysis-icu
RUN elasticsearch-plugin list | grep analysis-phonetic || elasticsearch-plugin install -b analysis-phonetic