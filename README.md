# Magento 2 Docker Nginx(Pagespeed)-MySQL-PHP-Redis-Elastic Setup
* Change settings under `.env` in root folder  
* Change PHP Versions 7.0, 7.1, 7.2, 7.3 all based on php:alpine docker image

## Description
This Setup installs the basic docker containers 

**(Nginx, PHP, MySQL, Redis, Elasticsearch, Mailhog)** for Magento 2. 

## Get Source

    git clone https://github.com/aliuosio/mage2.docker.git

## Installation
    
    > OSX only
    docker-sync start;
> get it here before running the command: [docker-sync.io](http://docker-sync.io)
         
    # Install Magento 2
    chmod +x ./install.sh
    ./install.sh
     
> Modify settings in .env

## Backend in Browser
    https://mage2.localhost/admin
    User: admin
    Password: admin123
    
## Frontend in Browser
    https://mage2.localhost/
    
> on OSX add the keys in `.docker/nginx/ssl`  to your keychain to use https in browser  
## next startup after installation

    Linux:
    docker-compose up -d
    
    OSX:
    docker-sync start;
    docker-compose -f docker-compose.osx.yml up -d;

## PHP Container Usage
    
    docker exec -it -u $USER mage2_php bash
    
## SSL Certificate Registration
    
    # register certificate
    docker-compose run --rm letsencrypt \
        letsencrypt certonly --webroot \
        --email <your_email-address> --agree-tos \
        -w /var/www/letsencrypt -d <subdomian or domain only: my.example.com>
        
    # restart webserver
    docker-compose kill -s SIGHUP nginx  
    
>**Renewal** (Quote: https://devsidestory.com/lets-encrypt-with-docker/)  
Let’s Encrypt certificates are valid for 3 months,  
they’d have to be renewed periodically with the following command:  
    
    # renew certificates which are expiring in less than 30 days,
    docker-compose run --rm letsencrypt letsencrypt renew 
    
    # restart webserver
    docker-compose kill -s SIGHUP nginx

    #### Mailhog Usage
    
    http://mage2.localhost:8025

#### Elasticsearch Usage:
In Magento 2 Backend `stores` -> `Configuration` -> `Catalog` -> `Catalog` -> `Tab: Catalog Search`
    
    Search Engine: Elasticsearch 5.0+
    Elasticsearch Server Hostname: elasticsearch
    Elasticsearch Server Port: 9200
> You **MUST** set `sysctl -w vm.max_map_count=262144` on the docker host system or the elasticsearch container goes down
> On OSX see link: https://stackoverflow.com/questions/41192680/update-max-map-count-for-elasticsearch-docker-container-mac-host?rq=1


## Features
* Nginx uses http2
* alternative **OSX docker-compose** file using docker-sync **for better perfomance**
* set project directory to where ever you want (as configurable option)
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) as configurable option  
* setup valid **SSL certificates** with letsmcrypt container
* Nginx uses **Pagespeed** Module
* both **PHP GD and PHP Imagick** are installed
* nodejs any yarn for [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) 
* **PHP Xdebug** as configurable option
* **PHP Opcache** enabled
* **PHP redis** enabled
* Mailhog container installed with install.sh
* ~~Alpine **Image Libraries** in PHP Docker Container: jpegoptim, optipng, pngquant, gifsicle~~
* **install magento 2** as configurable option
* **install magento 2 sample data** as configurable option
* permissions are set after magento 2 install  
following [Magento 2 Install Guide](https://devdocs.magento.com/guides/v2.3/config-guide/prod/prod_file-sys-perms.html)  as configurable option
* **http basic authentication** 
* **use mysql, php over sockets** instead of ports for faster data container exchange
* **Extra Composer Packages**
    * [hirak/prestissimo](https://github.com/hirak/prestissimo) composer Package
* **Extra Composer Packages with Magento 2 Installer **  
    * [vpietri/adm-quickdevbar] (https://github.com/vpietri/magento2-developer-quickdevbar)
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) 

### Todos
* add prompt to install.sh for ssl or non-ssl config of nginx
* add instructions to README for adding existing projects to this Docker Stack
* add prompt o choose between nginx wiht pagespeed or apache without pagespeed
* add pagespeed to apache if choosen
* mount ssl certs to host directory to fix OSX SSL Localhost certificate bug
* simplify letsencrypt certificate embedding in nginx container
* mailhog configuration in install.sh
* added Elastcisearch config instructions to README.md
* ~~remove auth.json instructions and handling~~
* Elasticsearch 6.8.5 Upgrade from 5.2 
* handle magento 2 cronjobs per docker container or add job to php container
* add extra container for LESS and SASS Generation containing yarn/nodejs
* fix sockets for redis with magento 2
* using docker-entrypoint scripts to set user so the image can be more static
* ~~nginx with pagespeed module~~
* ~~create seperat containers for redis session and cache~~
* ~~create seperat containers for cronjob and image optimization~~
* ~~fix file permissions and ownership between containers and docker host~~
* ~~move Magento 2 specific tools and config to post-build.sh called in docker-compose.yml~~
* ~~move xdebug install & config to magento-install.sh band install after magento 2 install and sampledata~~
* ~~setup script for PHP Container to set IP for xdebug or Domain~~
* clean up alpine packages after build
* optimize pagespeed caching
* use pagespeed with redis cache
* increase vm max count for elasticsearch without system reboot
* Nginx Header Config passes at https://securityheaders.com/
* set timezone in containers
* secure socket connection between containers
* add varnish container and configure with magento 2

### Bugs
* Nginx certificate location reference
* ~~check that all commands function in post-build.sh~~
* ~~sampledata deploy error on docker-compose build~~
* on first run of install.sh the MySQL Container is not ready for connections 

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://openng.de
source.org/licenses/MIT)

## Docker Container Overview
* ~~Magento Cronjobs~~
* Elasticsearch
* letsencrypt
* mailhog
* nginx
* mysql
* php
* redis

