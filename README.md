## Docker stack with Magento 2 latest installer and Sample Data
### A single stack for all projects, configurable via the .env file.
**Docker containers: Varnish, Nginx, PHP, Opensearch, MariaDB, Redis, Mailhog, RabbitMQ**
**PHP with NodeJS (linux/amd64, linux/arm64)**
**MySQL connects via socket instead of TCP/IP**
> RabbitMQ, MailHog, Watchtower are commented out of the docker-compose.yml
> to run projects parallel you need to add a proxy like Traefik or nginx-proxy

### Get Source

    git clone https://github.com/aliuosio/mage2.docker.git

> check for updates with `git fetch && git pull`

### Installation
  Fresh installation (latest Magento 2 version) or use an existing project located in your filesystem.
    
    cd mage2.docker
    chmod +x bin/*
    cp .env.temp .env # modify path to a existing shop if you want or use default for fresh install
    bin/install

> if there is a composer.json found in this directory, it will be used instead of performing a fresh install.

> Database will be imported from .docker/mysql/db_dumps if found
    
> use .env to change values after installation; changes will be applied upon container restart with `bin/start`

> for a fresh install run `docker compose down -v` and then`bin/install`

### Backend
    http://localhost/admin
    User: mage2_admin
    Password: mage2_admin123#T
    
### Frontend
    http://localhost
    
### next startup after reboot of Host
    bin/start

### PHP Container Usage
    
    docker exec -it mage2_php bash
    
### Mailhog Usage

> `bin/install` script configures the default magento 2.4.6 mail settings to run with mailhog

    Mail Client
    http://localhost:8025 

    
### Features
* Fresh Install or use existing magento 2 project on your file system
* set project directory to where ever you want (as configurable option in .env)
* [n98-magerun2](https://github.com/netz98/n98-magerun) (accessible as `magerun2` within the PHP container)
* [Mailhog](https://github.com/mailhog/MailHog) container
* **Additional Composer Packages included with the Magento 2 Installer**
    * [yireo/magento2-webp2](https://github.com/yireo/Yireo_Webp2) WebP Converter
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) Cache Cleaner
* Xdebug as configurable option (xdebug.idekey=PHPSTORM)

### Todos
* add `bin/install config`
* reduce the number of volumes

#### Support
If you encounter any problems or bugs, please create an issue on [GitHub](https://github.com/aliuosio/mage2.docker/issues).

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://openng.de/source.org/licenses/MIT)
