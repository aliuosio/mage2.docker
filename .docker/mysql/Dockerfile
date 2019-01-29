FROM mysql:5.7

LABEL maintainer="Osiozekhai Aliu"

ARG USERNAME
ARG TZ

COPY conf/dev.cnf /etc/mysql/conf.d/dev.cnf

RUN addgroup --gid 1000 --system ${USERNAME} \
    && adduser --uid 1000 --system --disabled-login --disabled-password --gid 1000 ${USERNAME} \
    && sed -i "s#__user#${USERNAME}#g" /etc/mysql/conf.d/dev.cnf \
    && chown -R ${USERNAME} /var/lib/mysql \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*