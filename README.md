# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under ```.env``` in root folder  
* Change PHP Versions 7.0, 7.1, 7.2 all based on php:alpine docker image


## Features
* set project directory to where ever you want (as configurable option)
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) as configurable option  
(Magento 2.3 at this point does not work with PHP 7.3)
* setup valid **SSL certificates** with letsmcrypt container
* Nginx with **http2** protocol enabled
* **Nginx Header Config** passes at https://securityheaders.com/
* **Server Signature excluded**: Nginx Version Nummer and PHP Usage do not show up in Response Headers
* on secure ssl_ciphers enabled
* uses openssl dhparam 
* both **PHP GD and PHP Imagick** are installed
* **PHP Xdebug** as configurable option
* **PHP Opcache** enabled
* **PHP redis** enabled
* Alpine **Image Libraries** in PHP Docker Container: jpegoptim, optipng, pngquant, gifsicle
* **install magento 2** as configurable option
* **install magento 2 sample data** as configurable option
* permissions are set after magento 2 install  
following [Magento 2 Install Guide](https://devdocs.magento.com/guides/v2.3/config-guide/prod/prod_file-sys-perms.html)  
* **http basic authentication**
* **use mysql, redis and php over sockets** instead of ports for faster data container exchange
* **Extra Composer Packages** (if Magento 2 Installer is used):  
    * [hirak/prestissimo](https://github.com/hirak/prestissimo) composer parallel install plugin for faster downloads    
    * [justbetter/magento2-image-optimizer](https://github.com/justbetter/magento2-image-optimizer) Easily optimize images using PHP using bin/magento console  
    * [msp/devtools](https://github.com/magespecialist/m2-MSP_DevTools) DevTools for Magento2  
    * [mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean) replacement for bin/magento cache:clean with file watcher      
    * [mageplaza/module-smtp](https://github.com/mageplaza/magento-2-smtp) Magento 2 SMTP Extension  
    * [firegento/magesetup](https://github.com/firegento/firegento-magesetup) as configurable option.    
    MageSetup configures a shop for a national market:  
    Currently supported countries: Austria, France, Germany, Italy, Russia, Switzerland, United Kingdom. More to follow.  
    
> features can be enabled in .env

## Docker Containers 
* Elasticsearch
* letsencrypt
* mailhog
* memcached
* mysql
* nginx
* php
* redis

## Get Source
Using **Git**
    
    git clone https://github.com/aliuosio/mage2.docker.git
    
Already have a Magento 2 project setup with **Git**

    git submodule add https://github.com/aliuosio/mage2.docker.git 
    
    # to get updates afterwards
    git submodule update --remote
      
Using **Composer**  
    
    composer require aliuosio/mage2.docker

## Mandatory Settings
    
    cp .env.template .env

    # the domain mage2.doc is saved to your /etc/hosts file
    echo -e "0.0.0.0 mage2.doc" | sudo tee -a /etc/hosts
    
You must set project absolute folder path ```WORKDIR``` in ```.env```  

## Start docker
    # Linux
    docker-compose build;
    docker-compose -d;
    
    # MacOS
    docker-sync start;
    docker-compose -f docker-compose.mac.yml build;
    docker-compose -f docker-compose.mac.yml -d;  
    
> For OSX Users:
if ```docker-sync``` is missing on your OSX then 
visit the http://docker-sync.io/ website to get it

## Magento 2 Konfiguration
Call: https://mage2.doc in your browser to configure Magento 2.  
The Database Hostname is ```mysql```  
See MySQL settings in ```.env``` for user, password and dbname before install 

### to use sockets to connect with redis, php and mysql
    
    cp env.php.template <WORKDIR>/app/etc/env.php

#### Magento 2 Cronjobs activation (values set in .env)
    docker exec -it <NAMESPACE>_php ./bin/magento cron:install  
    
> works only after Magento 2 configuration

## SSL Certificate registration
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

#### Login to PHP container (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php bash
    
#### Use Composer (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php composer <command>

#### Use Magerun (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php n98-magerun2 shell
    
#### All outgoing mails caught by MailHog (values set in .env)
    http://mage2.doc:8025

#### Configure the Elasticsearch:
In Magento 2 Backend ```stores``` -> ```Configuration``` -> ```Catalog``` -> ```Catalog``` -> ```Tab: Catalog Search```
    
    Search Engine: Elasticsearch 5.0+
    Elasticsearch Server Hostname: elasticsearch
    Elasticsearch Server Port: 9200

#### Configure the mageplaza SMTP extension:
In Magento 2 Backend ```stores``` -> ```Configuration``` -> ```Mageplaza Extensions```
    
    Enable Mageplaza SMTP: yes
    Host: mailhog
    port: 1025
    Protocol: None	
    Authentication: PLAIN  
    
> mandatory settings

#### Todos
* nginx with pagespeed module
* Language Packs as configurable option (supported: de_DE, en_GB, fr_FR, it_IT, es_ES, pt_PT, pt_BR)  

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[MIT License](LICENSE)
