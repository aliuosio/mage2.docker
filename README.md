# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup
* Change settings under ```.docker/.env```  
* Change PHP Versions 7.0, 7.1, 7.2 all based on php:alpine docker image in ```.docker/.env``` file  

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
    docker-sync start; # on OSX only
    docker-compose -f docker-compose.mac.yml -d; # on OSX only
    docker-compose up -d; # on linux only
    
> For OSX Users:
if ```docker-sync``` is missing on your OSX then 
visit the http://docker-sync.io/ website to get it

## Magento 2 Konfiguration
Call: https://localhost in your browser to configure Magento 2.  
The Database Hostname is ```mysql```  

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
* add let's encrypt/ssl key generator container to generate certificates for valid domains
* setup functioning elasticsearch container for magento 2.3