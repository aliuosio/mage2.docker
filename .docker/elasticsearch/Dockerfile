ARG ELASTICSEARCH_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}

LABEL maintainer="Osiozekhai Aliu"
RUN yum update -y
RUN /bin/sh -c "./bin/elasticsearch-plugin install analysis-icu; ./bin/elasticsearch-plugin install analysis-phonetic;"
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
RUN yum clean all