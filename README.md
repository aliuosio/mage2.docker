# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under ```.docker/.env```  
* Change PHP Versions 7.0, 7.1, 7.2 all based on php:alpine docker image

## Features
* set project directory to where ever you want (as variable option)
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) as variable option  
(Magento 2.3 at this point does not work with PHP 7.3)
* setup valid **SSL certificates** with letsmcrypt container
* Nginx with **http2** protocol enabled
* on secure ssl_ciphers enabled
* uses openssl dhparam 
* both **PHP GD and PHP Imagick** are installed
* **PHP Xdebug** as variable option
* **PHP Opcache** enabled
* **PHP redis** enabled
* **install magento 2** as variable option
* **install magento 2 sample data** as variable option
* **Cronjob** ist setup if Magento 2 Install option was choosen
* **Extra Composer Packages** (if Magento 2 Installer is used):  
* permissions are set following [Magento 2 Install Guide](https://devdocs.magento.com/guides/v2.3/config-guide/prod/prod_file-sys-perms.html)  
[hirak/prestissimo](https://github.com/hirak/prestissimo)  
[msp/devtools](https://github.com/magespecialist/m2-MSP_DevTools)
[mage2tv/magento-cache-clean](https://github.com/mage2tv/magento-cache-clean)    
[mageplaza/module-smtp](https://github.com/mageplaza/magento-2-smtp)    
[splendidinternet/mage2-locale-de-de](https://github.com/splendidinternet/Magento2_German_LocalePack_de_DE)  
[firegento/magesetup](https://github.com/firegento/firegento-magesetup) as variable option
* **http basic authentication**
* **use mysql, redis and php over sockets** instead of ports for faster data container exchange
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

    echo -e "0.0.0.0 mage2.doc" | sudo tee -a /etc/hosts
> set host entry in ```/etc/hosts``` 

To run magento 2 installer copy the file  
```.docker/php/conf/auth.json.template``` to ```.docker/php/conf/auth.json``` and set your credentials there.  
You must set project absolute folder path ```WORKDIR``` in ```.docker/.env```   

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

#### Magento 2 Cronjobs activation (values set in .env)
    docker exec -it <NAMESPACE>_php ./bin/magento cron:install

## Magento 2 Konfiguration
Call: https://mage2.doc in your browser to configure Magento 2.  
The Database Hostname is ```mysql```  
See MySQL settings in ```.env``` for user, password and dbname 

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
    https://<SHOP_URI>:8025

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

#### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

#### License
[MIT License](LICENSE)
