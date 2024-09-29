#!/bin/bash
elasticsearch-plugin list | grep analysis-phonetic || elasticsearch-plugin install -b analysis-phonetic
elasticsearch-plugin list | grep analysis-icu || elasticsearch-plugin install -b analysis-icu

exec /usr/local/bin/docker-entrypoint.sh "$@"
