# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under ```.docker/.env```
* Change PHP Versions 7.0, 7.1, 7.2 all based on php:alpine docker image in ```.docker/.env``` file

## Get Source
``` git clone https://github.com/aliuosio/mage2.docker.git ```
    or
``` composer require aliuosio/mage2.docker ```

> **mandatory**
if you want to run th magento 2 installer you need to copy the file ```auth.json.template``` to ```auth.json``` and set your credentials there
You must set project absolute folder path ```WORKDIR``` in ```.docker/.env``` 

## Start docker
    cd .docker;
    docker-sync start; # on OSX only
    docker-compose -f docker-compose.mac.yml build; # on OSX only
    docker-compose build; # on linux only
    docker-compose up -d; 

## Magento 2 Konfiguration
Call: https://localhost in your browser to configure Magento 2.
The Database Hostname is ```mysql```

> For OSX Users:
if ```docker-sync``` is missing on your OSX then 
visit the http://docker-sync.io/ website to get it

### Login to PHP container (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php bash
    
### Use Composer (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php composer <command>

### Use Magerun (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php n98-magerun2 shell
    
### All outgoing mails caught by MailHog (values set in .env)
    https://<SHOP_URI>:8025

### Configure the mageplaza SMTP extension:
In Magento 2 Backend ```stores``` -> ```configuration``` -> ```Mageplaza Extensions```
    
    Enable Mageplaza SMTP: yes
    Host: mailhog
    port: 1025
    
> mandatory settings

### Todos
* add let's encrypt/ssl key generator container to generate certificates for valid domains
