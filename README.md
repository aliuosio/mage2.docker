## Docker stack with Magento 2 latest installer 
### One Stack for all Projects by adjusting .env file
**Docker containers: Varnish, Nginx, PHP, Opensearch, MariaDB, Redis, Mailhog, RabbitMQ, Watchtower**
using sockets instead of TCP/IP for redis sessions and MySQL
> RabbitMQ, MailHog, Watchtower are commented out of the docker-compose.yml
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
    http://localhost/admin
    User: mage2_admin
    Password: mage2_admin123#T
    
### Frontend
    http://localhost

OSX: on first run very slow due to docker-sync update of local shop files volume in the background. 
See `.docker-sync/daemon.log` for progress
    
### next startup after reboot of Host
    bin/start

### Install sample data

    bin/sample-data

### PHP Container Usage
    
    docker exec -it mage2_php bash
    
### Opensearch Usage

** Configured automatically with install **
    
You **MUST** set `sysctl -w vm.max_map_count=262144` on the docker host system or the elasticsearch container goes down
On OSX see link: https://stackoverflow.com/questions/41192680/update-max-map-count-for-elasticsearch-docker-container-mac-host?rq=1

### Mailhog Usage

> `bin/install` script configures the default magento 2.4.6 mail settings to run with mailhog

    Mail Client
    http://localhost:8025 

    
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
* configure mailhog with `bin/install`
* add cache warmer
* fix `bin/install config`
* reduce the number of volumes

#### Support
If you encounter any problems or bugs, please create an issue on [GitHub](https://github.com/aliuosio/mage2.docker/issues).

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://openng.de/source.org/licenses/MIT)
