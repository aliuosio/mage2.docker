# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under ```.docker/.env```  
* Change PHP Versions 7.0, 7.1, 7.2 all based on php:alpine docker image in ```.docker/.env``` file

## Features
+ set project directory to where ever you want
+ setup valid ssl certificate with letsmcrypt container
+ set Shop URI
+ set Elasticsearchversion
+ install magento 2
+ install magento 2 sample data
+ set http authentication
> features can be enabled in .env
    
## Get Source
``` git clone https://github.com/aliuosio/mage2.docker.git ```
    or
``` composer require aliuosio/mage2.docker ```

## Mandatory Settings

    0.0.0.0 mage2.doc

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

### Login to PHP container (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php bash
    
### Use Composer (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php composer <command>

### Use Magerun (values set in .env)
    docker exec -it -u <USERNAME> <NAMESPACE>_php n98-magerun2 shell
    
### All outgoing mails caught by MailHog (values set in .env)
    https://<SHOP_URI>:8025

### Configure the mageplaza SMTP extension:
In Magento 2 Backend ```stores``` -> ```configuration``` -> ```Mageplaza Extensions```
    
    Enable Mageplaza SMTP: yes
    Host: mailhog
    port: 1025
    
> mandatory settings

### Contribute
Please Contribute by creating a fork of this repository.  
Follow the instructions here: https://help.github.com/articles/fork-a-repo/
> “You’ve got to bring some to get some”      

### Todos
* setup functioning elasticsearch container for magento 2.3
* ability to setup all PHP minor Versions under 7 (7.0, 7.1, 7.2 builds should work)
* add ssl_dhparam to nginx vhost config
* magento 2 cronjobs