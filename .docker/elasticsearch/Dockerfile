FROM ptanov/elasticsearch-5.2-cgroups2

LABEL maintainer="Osiozekhai Aliu"

ARG TZ

RUN cd /usr/share/elasticsearch \
    && bin/elasticsearch-plugin install analysis-phonetic \
    && bin/elasticsearch-plugin install analysis-icu