FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.8

LABEL maintainer="Osiozekhai Aliu"

RUN /bin/sh -c "./bin/elasticsearch-plugin install analysis-icu; ./bin/elasticsearch-plugin install analysis-phonetic;"
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh;