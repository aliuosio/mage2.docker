FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.8

LABEL maintainer="Osiozekhai Aliu"

CMD /bin/sh -c "./bin/elasticsearch-plugin install analysis-icu; ./bin/elasticsearch-plugin install analysis-phonetic; /usr/local/bin/docker-entrypoint.sh;"