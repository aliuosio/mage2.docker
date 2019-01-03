# The Docker Nginx-MySQL-PHP-Redis-Elastic Setup

### Change settings under ```.docker/.env``` ###
##### Available 7.0, 7.1, 7.2 all based on php:alpine docker image
##### change Vars in .env file

## Add Host Adress to your /etc/hosts
    echo -e "0.0.0.0 app.doc" | sudo tee -a /etc/hosts

## Get Git Repository
    git clone git@github.com:aliuosio/docker-lamp.git

## start docker (!! on OSX !!)
    cd .docker
    docker-sync start
    docker-compose -f docker-compose.mac.yml up --build

## start docker
    cd .docker
    docker-compose up --build
    
### Login to PHP container (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php_<PHP_VERSION_SET> bash
    
### Login to Web Server container (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_nginx bash
    
### Use Composer (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php_<PHP_VERSION_SET> composer <command>

    
### Use Magerun (values set in .env)
    docker exec -it -u <USER> <NAMESPACE>_php_<PHP_VERSION_SET> n98-magerun2 shell
    
### Connect Sequel to MySQL (values set in .env)
    Host: <SHOP_URI>
    User: root
    Password: root
    port: <DATABASE_PORT_EXTERNAL>
    
### All outgoing mails are sent to MailHog
    https://<SHOP_URI>:8025 // The User you set 


### Todos
* use sockets instead of TCP