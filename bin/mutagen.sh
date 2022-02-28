#!/bin/bash
set -e

source .env

mutagen sync terminate --label-selector=app-data
mutagen sync terminate --label-selector=composer-cache

mutagen sync create \
        --name=app-data \
        --sync-mode=one-way-safe \
        --default-file-mode=0644 \
        --default-directory-mode=0755 \
        --default-owner-beta=www-data \
        --default-group-beta=www-data \
        --ignore=/.idea \
        --ignore=/.magento \
        --ignore=/.docker \
        --ignore=/.github \
        --ignore=*.sql \
        --ignore=*.gz \
        --ignore=*.zip \
        --ignore=*.bz2 \
        --ignore-vcs \
        --symlink-mode=posix-raw \
        "${WORKDIR}" docker://www-data@"${NAMESPACE}"_php/var/www/html

mutagen sync create \
        --name=composer-cache \
        --sync-mode=one-way-safe \
        --default-file-mode=0644 \
        --default-directory-mode=0755 \
        --default-owner-beta=www-data \
        --default-group-beta=www-data \
        --symlink-mode=posix-raw \
        ~/.composer docker://www-data@"${NAMESPACE}"_php/home/www-data/.composer