ARG MARIADB_VERSION

FROM mariadb:${MARIADB_VERSION}

LABEL maintainer="Osiozekhai Aliu"

RUN apt-get update -y && apt-get upgrade -y && apt-get install --no-install-recommends  -y wget;

RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*