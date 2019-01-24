# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under ```.docker/.env```  
* Change PHP Versions 7.0, 7.1, 7.2 all based on php:alpine docker image in ```.docker/.env``` file

## Features
* set project directory to where ever you want (variable option)
* set PHP-FPM minor Versions under 7 (7.0, 7.1, 7.2, 7.3) variable option
> Magento 2.3 at this point does not work with PHP 7.3
* setup valid SSL certificates with letsmcrypt container
* Xdebug enable variable option
* on secure ssl_ciphers enabled
* uses openssl dhparam 
* both PHP GD and PHP Imagick are installed
* PHP Xdebug enabled
* PHP Opcache enabled
* PHP redis enabled
* install magento 2 variable option
* install magento 2 sample data  variable option
* 
* Extra Composer Packages (if Magento 2 Installer is used):
hirak/prestissimo  
msp/devtools  
mage2tv/magento-cache-clean  
mageplaza/module-smtp  
splendidinternet/mage2-locale-de-de
* http basic authentication
* use mysql, redis and php over sockets instead of ports for faster data exchange
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
``` git clone https://github.com/aliuosio/mage2.docker.git ```
    or
``` composer require aliuosio/mage2.docker ```

## Mandatory Settings

    echo -e "0.0.0.0 mage2.doc" | sudo tee -a /etc/hosts
> set host entry in ```/etc/hosts``` 

To run magento 2 installer copy the file  
```auth.json.template``` to ```auth.json``` and set your credentials there.  
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

## Magento 2 Konfiguration
Call: https://localhost in your browser to configure Magento 2.  
The Database Hostname is ```mysql```  

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

### Login to PHP container (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php bash
    
### Use Composer (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php composer <command>

### Use Magerun (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php n98-magerun2 shell
    
### All outgoing mails caught by MailHog (values set in .env)
    https://<SHOP_URI>:8025

### Configure the Elasticsearch:
In Magento 2 Backend ```stores``` -> ```Configuration``` -> ```Catalog``` -> ```Catalog``` -> ```Tab: Catalog Search```
    
    Search Engine: Elasticsearch 5.0+
    Elasticsearch Server Hostname: elasticsearch
    Elasticsearch Server Port: 9200

### Configure the mageplaza SMTP extension:
In Magento 2 Backend ```stores``` -> ```Configuration``` -> ```Mageplaza Extensions```
    
    Enable Mageplaza SMTP: yes
    Host: mailhog
    port: 1025
    Protocol: None	
    Authentication: PLAIN
    
> mandatory settings

### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/

### Todos
* nginx with pagespeed module
* magento 2 cronjob

### Licence
[GNU General Public License, version 3 (GPLv3)](http://opensource.org/licenses/gpl-3.0)

### Copyright
(c) 2019 Osiozekhai Aliu