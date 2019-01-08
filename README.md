# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup

##### Change settings under ```.docker/.env```
##### Available 7.0, 7.1, 7.2 all based on php:alpine docker image
##### change Vars in .env file

## Get Source (Use git clone or composer require)
``` git clone https://github.com/aliuosio/mage2.docker.git ```
    or
``` composer require aliuosio/mage2.docker ```

## Add Host Address to your /etc/hosts
    echo -e "0.0.0.0 <SHOP_URI>" | sudo tee -a /etc/hosts

## Notes: MANDATORY
* if you want to run th magento 2 installer you need to copy the file ```auth.json.template``` to ```auth.json``` and set your credentials there
* You must set project absolute folder path ```WORKDIR``` in ```.docker/.env```) 

## start docker (!! on OSX !!)
    cd .docker;
    docker-sync start; 
    docker-compose -f docker-compose.mac.yml build;
    docker-compose up -d;

## Notes: OSX Users
* if ```docker-sync``` is missing on your Mac go to (visit the docker-sync website to get it)[http://docker-sync.io/]

## start docker
    cd .docker;
    docker-compose build;
    docker-compose up -d;
    
### call: ```https:/<SHOP_URI>``` in Browser if you set the ```INSTALL_MAGENTO=true``` to configure magento 2
    Database Host Name is: mysql (just like the docker conatainer is named under services in the docker-compose.yml)
    
### Login to PHP container (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php bash
    
### Login to Web Server container (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_nginx bash
    
### Use Composer (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php composer <command>

### Use Magerun (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php n98-magerun2 shell
    
### Connect Sequel to MySQL (values set in .env)
    Host: <SHOP_URI>
    User: root
    Password: root
    port: <DATABASE_PORT_EXTERNAL>
    
### All outgoing mails are sent to MailHog
    https://<SHOP_URI>:8025

### Todo
* add let's encrypt/ssl key generator container to generate certs for valid domain servers