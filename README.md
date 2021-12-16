## Magento 2 OSX/Linux Docker

### Requirements

**MacOS:**
[Docker](https://docs.docker.com/docker-for-mac/install/), [docker-sync](http://docker-sync.io/), [Git](http://docker-sync.io/)

**Linux:** 
[Docker](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/), [Docker-compose](https://docs.docker.com/compose/install/#install-compose), [Git](https://git-scm.com/)
> on Debian based OS (Example: Ubuntu, Linux Mint) use `bin/docker.sh` to install `docker` and `docker-compose`

### Get Source

    git clone https://github.com/aliuosio/mage2.docker.git

### Installation
 Fresh Installation (latest magento 2 version) or your running project when located in your filesystem
    
    cd mage2.docker
    chmod +x bin/*.sh
    bin/install.sh

> with `bin/install config` you can use prompts to configure install
    
> use .env to change values after installation and activate on restart of containers 

> If you have a `composer.json` in th workdir these packages will be installed

> If you have a DB Dump in `.docker/mysql/db_dumps` this will be imported. Formats allowed `*.sql` of `*.gz`

### Backend
    http://localhost/admin
    User: mage2_admin
    Password: mage2_admin123#T
    
### Frontend
    http://localhost

OSX: on first run very slow due to docker-sync update of local shop files volume in the background. 
See `.docker-sync/daemon.log` for progress
    
### next startup after reboot of Host
    bin/start.sh

### Install sample data

    chmod +x sample-data.sh
    bin/sample-data.sh

### PHP Container Usage
    
    docker exec -it mage2_php bash -l
    
### Elasticsearch Usage

** Configured automatically with install.sh **

In Magento 2 Backend `stores` -`Configuration` -`Catalog` -`Catalog` -`Tab: Catalog Search`
    
    Search Engine: Elasticsearch 7.0+
    Elasticsearch Server Hostname: elasticsearch
    
You **MUST** set `sysctl -w vm.max_map_count=262144` on the docker host system or the elasticsearch container goes down
On OSX see link: https://stackoverflow.com/questions/41192680/update-max-map-count-for-elasticsearch-docker-container-mac-host?rq=1

### Mailhog Usage

    Mail Client
    http://mage2.localhost:8025 

    In Magento 2 Backend `stores` -`Configuration` -`Advanced` -`System` 
    -`Tab: SMTP Configuration and Settings (Gmail/Google/AWS/Office360 etc)`
   
    Authentication method: NONE
    SSL type: None
    SMTP Host: mailhog
    SMTP Port: 1025
    
### Features
* Fresh Install or use magento 2 project on your file system using `bin/install.sh`
* Nginx uses http2
* alternative **OSX docker-compose** file using docker-sync **for better performance**
* set Magento 2 Versions as configurable option of `bin/ìnstall.sh`
* using watchtower container to keep the containers current
* set project directory to where ever you want (as configurable option in .env)
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) as configurable option
* **http basic authentication**
* container to register SSL Cert by letsencrypt (only with valid domain)
* setup valid **SSL certificates** with [Let's Encrypt](https://en.wikipedia.org/wiki/Let%27s_Encrypt) container
* [Mailhog](https://github.com/mailhog/MailHog) container
* [Magerun2](https://github.com/netz98/n98-magerun2) netz98 magerun CLI tools for Magento 2
* **Extra Composer Packages with Magento 2 Installer**
    * [magepal/magento2-gmailsmtpapp](https://github.com/magepal/magento2-gmail-smtp-app) SMTP Module
    * [yireo/magento2-webp2](https://github.com/yireo/Yireo_Webp2) WebP Converter
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) Cache Cleaner
* both **PHP GD and PHP Imagick** are installed
* **PHP Xdebug** as configurable option (xdebug.idekey=docker)
* **PHP Opcache** enabled
* **PHP redis** enabled
* us your local User ssh keys from host in PHP container
* set Project Name and Namespace through `bin/ìnstall.sh` prompt
* create backup of `.env` after `bin/install.sh` usage
* only create `mage2_admin` user on fresh install in `install.sh`
* `bin/install.sh` creates secure MariaDB passwords and saves them to `.env` 
* added prompt for SSL to `bin/ìnstall.sh`

### Todos
* ~~move functions from `bin/start.sh` to PHP container~~
* ~~move functions from `bin/install.sh` to PHP container~~
* ~~move `sampe-data.sh` to PHP container~~
* ~~add Healtchecks to docker-compose~~
* ~~modify installer to use config flag instead of flag kickit~~
* ~~build own ElasticSearch Image with required Plugins for Magento 2~~
* fix OSX Installer
* modify for running Magento 2 project
* add downloader script to clone and install App
* add DB Import functions and logs
* set user and group ids for docker-sync
* refactor docker-compose.osx.yml
* change PHP container OS from debian to alpine
* add magento 2 version prompt
* map local user to php container www-data user
* ~~install composer version according to magento 2 version~~
* Exchange `docker-sync` with `Mutagen`
* generic solution for `bin//install.sh`to guarantee backward compatibility
* reduce the number of volumes
* set Time and Zone according to host
* Docker letsencrypt certification Container
* prompt to disable Two Factor Auth (for example in local enviroment)
* ~~exchange MySQL with MariaDB as soon as Magento 2 Installer fixes Mariadb container again~~
* make Webserver(Apache or Nginx) configurable in `bin/install.sh` and `docker-entrypoint.sh`
* rename config_blueprints to config and move config files to .docker/config
* move `bin/install.sh` methods to extra script run in php container native
* move `bin/sampledata.sh` methods to extra script run in php container native
* simplify letsencrypt certificate embedding in nginx container
* Nginx Header Config passes at https://securityheaders.com/

### Bugs
* fix SSL

#### Support
If you encounter any problems or bugs, please create an issue on [GitHub](https://github.com/aliuosio/mage2.docker/issues).

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://openng.de/source.org/licenses/MIT)
