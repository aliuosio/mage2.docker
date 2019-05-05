# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under `.env` in root folder  
* Change PHP Versions 7.0, 7.1, 7.2, 7.3 all based on php:alpine docker image

## Table of Contents
1. [Features](#features)
1. [Docker Container Overview](#docker-container-overview)
1. [Get Source](#get-source)
   * [Use Git](#use-git)
   * [Use Git Submodule](#use-git-submodule)
   * [Use Composer](#use-composer) 
1. [Mandatory Settings](#mandatory-settings)
1. [Start docker](#start-docker)
1. [Magento 2 Configuration](#magento-2-configuration)
1. [SSL Certificate Registration](#ssl-certificate-registration)
1. [PHP Container Usage](#php-container-usage)
1. [Composer Usage](#composer-usage)
1. [Magerun2 Usage](#magerun2-usage)
1. [Mailhog Usage](#mailhog-usage)
1. [Elasticsearch Usage](#elasticsearch-usage)
1. [Todos](#todos)
1. [Bugs](#bugs)
1. [Contribute](#contribute)
1. [License](#license)

## Features
* alternative **OSX docker-compose** file using docker-sync **for better perfomance**
* set project directory to where ever you want (as configurable option)
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) as configurable option  
(24.02.2019: Magento 2.3 at this point does not work with PHP 7.3)
* setup valid **SSL certificates** with letsmcrypt container
* ~~Nginx uses **Pagespeed** Module~~
* both **PHP GD and PHP Imagick** are installed
* nodejs any yarn for [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) 
* **PHP Xdebug** as configurable option
* **PHP Opcache** enabled
* **PHP redis** enabled
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
    * [msp/devtools](https://github.com/magespecialist/m2-MSP_DevTools) DevTools for Magento2  
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) 
    
> features can be enabled in .env

## Docker Container Overview
* ~~Magento Cronjobs~~
* Elasticsearch
* letsencrypt
* mailhog
* nginx
* mysql
* php
* redis


## Get Source
#### Use Git

    git clone https://github.com/aliuosio/mage2.docker.git
    
#### Use Git Submodule

    git submodule add https://github.com/aliuosio/mage2.docker.git 
    
    # to get updates afterwards
    git submodule update --remote
      
#### Use Composer  
    
    composer require aliuosio/mage2.docker
    cd /vendor/aliuosio/mage2.docker

## Mandatory Settings
    
    cp .docker/config_blueprints/.env.sample .env
    
    # the domain mage2.doc is saved to your /etc/hosts file
    echo -e "0.0.0.0 mage2.doc" | sudo tee -a /etc/hosts
    
    # only needed if you want to install Magento 2 on first build
    # the project folder has to be empty 
    cp .docker/config_blueprints/auth.json.sample .docker/php/conf/auth.json
    
## Start docker
    # Linux
    docker-compose up --build;
    
    # OSX
    docker-sync start;
    docker-compose -f docker-compose.osx.yml up --build;
    
> For OSX Users:
if `docker-sync` is missing on your OSX then 
visit the http://docker-sync.io/ website to get it

## Magento 2 Configuration
Call: https://mage2.doc in your browser to configure Magento 2.  
The Database Hostname is `mysql` or `/var/lib/mysql/mysql.sock` to use sockets
See mysql settings in `.env` for user, password and dbname before install 

### to use sockets to connect with redis, php and mysql
    
    cp config_blueprints/env.php.sample <WORKDIR>/app/etc/env.php

> works only after Magento 2 configuration

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

#### PHP Container Usage
    docker exec -it -u <USERNAME> <NAMESPACE>_php sh
    
#### Composer Usage
    docker exec -it -u <USERNAME> <NAMESPACE>_php composer <command>

#### Magerun2 Usage
    docker exec -it -u <USERNAME> <NAMESPACE>_php n98-magerun2 shell
    
#### Mailhog Usage
    http://mage2.doc:8025

#### Elasticsearch Usage:
In Magento 2 Backend `stores` -> `Configuration` -> `Catalog` -> `Catalog` -> `Tab: Catalog Search`
    
    Search Engine: Elasticsearch 5.0+
    Elasticsearch Server Hostname: elasticsearch
    Elasticsearch Server Port: 9200
> You **MUST** set `sysctl -w vm.max_map_count=262144` on the docker host system or the elasticsearch container goes down
> On OSX see link: https://stackoverflow.com/questions/41192680/update-max-map-count-for-elasticsearch-docker-container-mac-host?rq=1

#### Todos
* handle magento 2 cronjobs per docker container or add job to php container
* fix sockets for redis with magento 2
* ~~nginx with pagespeed module~~
* ~~create seperat containers for redis session and cache~~
* ~~create seperat containers for cronjob and image optimization~~
* ~~fix file permissions and ownership between containers and docker host~~
* move Magento 2 specific tools and config to post-build.sh called in docker-compose.yml
* ~~move xdebug install & config to docker-entrypoint.sh band install after magento 2 install and sampledata~~
* test with mounts instead of volumes
* ~~setup script for PHP Container to set IP for xdebug or Domain~~
* clean up alpine packages after build
* PWA Studio as variable option
* set authentification for elasticsearch
* add composer package [magenerds/smtp](https://github.com/magenerds/smtp)
* reduce the number of volumes
* optimize pagespeed caching
* bash script to set Xdebug remote IP after an restart of docker
* ~~use pagespeed with redis cache~~

#### Bugs
* ~~fix OSX version~~
* check that all commands function in post-build.sh
* cron jobs container not logging messages
* ~~sampledata deploy error on docker-compose build~~
* set timezone in containers
* secure socket connection between containers
* Nginx Header Config passes at https://securityheaders.com/
* increase vm max count for elasticsearch without system reboot

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
