#!/bin/sh

set -e

mkdir -p /etc/nginx/ssl/ \
 && openssl req -x509 -nodes -days 365 -newkey rsa:2048  \
 -keyout /etc/nginx/ssl/privkey.pem  \
 -out /etc/nginx/ssl/fullchain.pem  \
 -subj /CN=${SHOPURI}