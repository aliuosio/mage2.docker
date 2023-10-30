## Magento 2 installer on OSX/Linux Docker stack 
### One Stack for all Projects
**Docker containers: nginx, php, elasticsearch, mariadb, redis, rabbitmq, mailhog, watchtower, varnish**
using sockets instead of TCP/IP for redis sessions, MySQL and PHP
> rabbitmq, mailhog, Watchtower and Varnish are commented out of the docker-compose.yml
### Get Source

    git clone https://github.com/aliuosio/mage2.docker.git

### Installation
 Fresh Installation (latest magento 2 version) or your running project when located in your filesystem
    
    cd mage2.docker
    chmod +x bin/*
    bin/install

> with `bin/install config` you can use prompts to configure install (USING the command with config IS BUGGY. FEEL FREE TO CONRIBUTE)
    
> use .env to change values after installation and activate on restart of containers 

### Backend
    https://localhost/admin
    User: mage2_admin
    Password: mage2_admin123#T
    
### Frontend
    https://localhost

OSX: on first run very slow due to docker-sync update of local shop files volume in the background. 
See `.docker-sync/daemon.log` for progress
    
### next startup after reboot of Host
    bin/start

### Install sample data

    bin/sample-data

### PHP Container Usage
    
    docker exec -it mage2_php bash
    
### Elasticsearch Usage

** Configured automatically with install **

In Magento 2 Backend `stores` -`Configuration` -`Catalog` -`Catalog` -`Tab: Catalog Search`
    
    Search Engine: Elasticsearch 7.0+
    Elasticsearch Server Hostname: elasticsearch
    
You **MUST** set `sysctl -w vm.max_map_count=262144` on the docker host system or the elasticsearch container goes down
On OSX see link: https://stackoverflow.com/questions/41192680/update-max-map-count-for-elasticsearch-docker-container-mac-host?rq=1

### Mailhog Usage

> `bin/install` script configures the default magento 2.4.6 mail settings to run with mailhog

    Mail Client
    https://localhost:8025 

    
### Features
* Fresh Install or use existing magento 2 project on your file system using `bin/install config`
* alternative **OSX docker-compose** file using docker-sync **for better performance**
* set project directory to where ever you want (as configurable option in .env)
* [Mailhog](https://github.com/mailhog/MailHog) container
* **Extra Composer Packages with Magento 2 Installer**
    * [yireo/magento2-webp2](https://github.com/yireo/Yireo_Webp2) WebP Converter
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) Cache Cleaner
* Xdebug as configurable option (xdebug.idekey=PHPSTORM)

### Todos
* fix `bin/install config`
* fix SSL in node container
* switch between Mage-os and Magento 2 in config
* ~~compatibility Magento 2.4.5~~
* add Magento version choice to `bin/install config` prompt
* fix `bin/install config` WORKDIR config
* add domain to `etc/hosts` option for interactive config in `bin/install`
* create backup of `.env` after `bin/install` usage
* refactor docker-compose.osx.yml
* Exchange `docker-sync` with `Mutagen`
* reduce the number of volumes
* Docker letsencrypt certification Container
* add downloader script to clone and install App
* make Webserver(Apache or Nginx) configurable in `bin/install` and `docker-entrypoint`
* rename config_blueprints to config and move config files to .docker/config
* simplify letsencrypt certificate embedding in nginx container
* Nginx Header Config passes at https://securityheaders.com/
* ~~set permissons between host node container~~
* ~~set german locale, curreny, timezone~~
* ~~fix redis socket support~~
* ~~add PHP 8 to Dockerfile~~
* ~~add magento 2 cronjob~~
* ~~add DB Import progress bar~~
* ~~add Healtchecks to docker-compose~~
* ~~modify installer to use config flag instead of flag kickit~~
* ~~build own ElasticSearch Image with required Plugins for Magento 2~~
* ~~fix OSX Installer~~
* ~~change PHP container OS from debian to alpine~~
* ~~set Time and Zone according to host~~
* ~~map local user to php container www-data user~~ thanks to [fixuid](https://github.com/boxboat/fixuid)
* ~~add DB Import functions and logs~~
* ~~modify for running Magento 2 project~~
* ~~exchange MySQL with MariaDB as soon as Magento 2 Installer fixes Mariadb container again~~

#### Support
If you encounter any problems or bugs, please create an issue on [GitHub](https://github.com/aliuosio/mage2.docker/issues).

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://openng.de/source.org/licenses/MIT)
