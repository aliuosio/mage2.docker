# Magento 2 OSX/Linux Docker Nginx(Pagespeed)-MariaDB-PHP-Redis-Elastic Setup
* small alpine images except for MariaDB and ElasticSearch
* Change settings under `.env` in root folder  
* Change PHP Versions 7.1, 7.2, 7.3 all based on php:alpine docker image
* php, redis containers connect via sockets
* db(mariadb), redis_pagespeed, mailhog, elasticsearch containers connect via TCP/IP (Sockets in Work)

## Description
This Setup installs the basic docker containers 

**(Nginx, PHP, MariaDB, Redis, Elasticsearch, Mailhog)** for Magento 2. 

## Requirements

**MacOS:**
Install [Docker](https://docs.docker.com/docker-for-mac/install/)

**Linux:**
Install [Docker](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/) and [Docker-compose](https://docs.docker.com/compose/install/#install-compose).

## Get Source

    git clone https://github.com/aliuosio/mage2.docker.git

## Installation
>  Fresh Installation or your running project when located in your filesystem
    
    cd mage2.docker
    
    chmod +x ./install.sh
    
    ./install.sh 
    (on OSX open a new terminal tab to run ./install.sh again)
    
> Modify settings in .env.template before running `./install.sh` if needed

> use .env to change values later after installation 

## Backend in Browser
    http://mage2.localhost/admin
    User: mage2_admin
    Password: mage2_admin123#T
    
## Frontend in Browser
    http://mage2.localhost

> OSX: on first run very slow due to docker-sync update of local shop files volume in the background. See `.docker-sync/daemon.log` for progress
    
## next startup after reboot of Host
   
    OSX: 
    docker-sync start  
> (if it fails, try using`docker-sync stop;` `docker-sync clean;`before)
    
    Linux:
    docker-compose up -d

## to fix Redis Performance Issues (Linux Only)
    sudo sysctl vm.overcommit_memory=1;
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    
## to fix ElasticSearch Performance Issues (Linux Only)
    sudo sysctl vm.max_map_count=262144

## Install sample data

    chmod +x sample-data.sh
    ./sample-data.sh

## PHP Container Usage
    
    docker exec -it -u $USER mage2_php_<PHP_VERSION_SET> bash -l
    
## Elasticsearch Usage (Configured automatically with install.sh)
In Magento 2 Backend `stores` -> `Configuration` -> `Catalog` -> `Catalog` -> `Tab: Catalog Search`
    
    Search Engine: Elasticsearch 6.0+
    Elasticsearch Server Hostname: elasticsearch
    
> You **MUST** set `sysctl -w vm.max_map_count=262144` on the docker host system or the elasticsearch container goes down
> On OSX see link: https://stackoverflow.com/questions/41192680/update-max-map-count-for-elasticsearch-docker-container-mac-host?rq=1

## Mailhog Usage

    Mail Client
    http://mage2.localhost:8025 

    In Magento 2 Backend `stores` -> `Configuration` -> `Advanced` -> `System` 
    -> `Tab: SMTP Configuration and Settings (Gmail/Google/AWS/Office360 etc)`
   
    Authentication method: NONE
    SSL type: None
    SMTP Host: mailhog
    SMTP Port: 1025

## SSL Certificate Registration
    
    # register certificate
    docker-compose run --rm letsencrypt \
        letsencrypt certonly --webroot \
        --email <your_email-address> --agree-tos \
        -w /var/www/letsencrypt -d <subdomian or domain only: my.example.com>
        
    # restart webserver
    docker-compose kill -s SIGHUP nginx  
    
> **Renewal** (Quote: https://devsidestory.com/lets-encrypt-with-docker/)
> comment in the letsencrypt block in the docker-compose.yml or docker-compose.osx.yml on OSX.
> Let’s Encrypt certificates are valid for 3 months,
> they’d have to be renewed periodically with the following command:  
    
    # renew certificates which are expiring in less than 30 days,
    docker-compose run --rm letsencrypt letsencrypt renew 
    
    # restart webserver
    docker-compose kill -s SIGHUP nginx

## Features
* Nginx uses http2
* alternative **OSX docker-compose** file using docker-sync **for better performance**
* set project directory to where ever you want (as configurable option in .env)
* [Magerun2](https://github.com/netz98/n98-magerun2) netz98 magerun CLI tools for Magento 2
* [MySQLTuner Script](https://github.com/major/MySQLTuner-perl) for Mariadb Performance Testing
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) as configurable option  
* **node / yarn** is setup in PHP Container (Login into PHP Container for usage) 
* setup valid **SSL certificates** with letsencrypt container
* Nginx uses **Pagespeed** Module
* both **PHP GD and PHP Imagick** are installed
* **PHP Xdebug** as configurable option
* **PHP Opcache** enabled
* **PHP redis** enabled
* Mailhog container installed with install.sh
* ~~Alpine **Image Libraries** in PHP Docker Container: jpegoptim, optipng, pngquant, gifsicle~~
* permissions set following [Magento 2 Install Guide](https://devdocs.magento.com/guides/v2.3/config-guide/prod/prod_file-sys-perms.html)
* mysqltuner.pl for performance testing in db container
* **http basic authentication** 
* **use MariaDB, PHP and Redis over sockets** instead of ports for faster data container exchange
* **Extra Composer Packages**
    * [hirak/prestissimo](https://github.com/hirak/prestissimo) composer package
* **Extra Composer Packages with Magento 2 Installer**  
    * [magepal/magento2-gmailsmtpapp](https://github.com/magepal/magento2-gmail-smtp-app) SMTP Module
    * [vpietri/adm-quickdevbar](https://github.com/vpietri/magento2-developer-quickdevbar) Developer Toolbar
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) Cache Cleaner


### Todos
* make Webserver(Apache or Nginx) configurable in `install.sh` and `docker-entrypoint.sh`
* connect to MariaDB using sockets
* `SHOPURI` in .env should change the domain and cookie name in magento 2 DB on `docker-compose up -d`
* rename config_blueprints to config and move config files to .docker/config
* exchange install.sh with extra docker container for magento 2 installation
* exchange sampledata.sh with extra docker container for magento 2 sampledata installation
* add instructions to README for adding existing projects to this Docker Stack
* simplify letsencrypt certificate embedding in nginx container
* add mailhog configuration to install.sh
* using docker-entrypoint scripts to set user so the image can be more static
* using docker-entrypoint scripts to set user so the image can be more static
* optimize pagespeed caching
* set timezone in containers
* Nginx Header Config passes at https://securityheaders.com/
* ~~add composer volume to docker-sync on osx~~
* ~~added Elastcisearch config instructions to README.md~~
* ~~remove auth.json instructions and handling~~
* ~~Elasticsearch 6.8.5 Upgrade from 5.2~~ 
* ~~fix sockets for redis with magento 2~~
* ~~nginx with pagespeed module~~
* ~~create seperat containers for redis session and cache~~
* ~~fix file permissions and ownership between containers and docker host~~
* ~~move Magento 2 specific tools and config to post-build.sh called in docker-compose.yml~~
* ~~move xdebug install & config to magento-install.sh band install after magento 2 install and sampledata~~
* ~~setup script for PHP Container to set IP for xdebug or Domain~~
* ~~clean up alpine packages after build~~2
* ~~use pagespeed with redis cache~~
* ~~increase vm max count for elasticsearch without system reboot~~

### Bugs
* ~~Nginx certificate location reference~~
* ~~check that all commands function in post-build.sh~~
* ~~sampledata deploy error on docker-compose build~~
* ~~on first run of install.sh the MariaDB Container is not ready for connections~~ 

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://openng.de/source.org/licenses/MIT)

## Docker Container Overview
* ~~Magento Cronjobs~~
* Elasticsearch
* letsencrypt
* mailhog
* nginx
* mysql
* php
* redis

