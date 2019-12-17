FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.5

LABEL maintainer="Osiozekhai Aliu"

RUN elasticsearch-plugin install analysis-phonetic && \
    elasticsearch-plugin install analysis-icu
