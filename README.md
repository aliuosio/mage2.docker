# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup

##### Change settings under ```.docker/.env```
##### Available 7.0, 7.1, 7.2 all based on php:alpine docker image
##### change Vars in .env file

## Get Source (Use git clone or composer require)
    git clone https://github.com/aliuosio/mage2.docker.git
    composer require aliuosio/mage2.docker

## Add Host Adress to your /etc/hosts
    echo -e "0.0.0.0 <SHOP_URI>" | sudo tee -a /etc/hosts
    
## Customize (you must set project absolute folder path ```.docker/.env```)
    WORKDIR

# NOTE: if you want to run th magento 2 installer you need to copy the file auth.json.template to auth.json and set your credentials there

## start docker (!! on OSX !!)
    cd .docker;
    docker-sync start;
    docker-compose -f docker-compose.mac.yml build;
    docker-compose up -d;

## start docker
    cd .docker;
    docker-compose build;
    docker-compose up -d;
    
### call: ```https:/<SHOP_URI>``` in Browser if you set the ```INSTALL_MAGENTO=true``` to configure magento 2
    
#### DB Host Name is mysql
    
## to Install Magento2 when building php docker container
set ``` INSTALL_MAGENTO ``` in ``` .docker/.env ```
    
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
* add crontab script for magento 2
* add let's encrypt container to generate certs for valid domain servers
