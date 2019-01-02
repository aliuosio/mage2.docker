## The Docker LAMP Setup

### Change settings under ```.docker/.env``` ###
##### Available 7.0, 7.1, 7.2 all based on php:alpine docker image

##### Add Host Adress to your /etc/hosts
    echo -e "0.0.0.0 app.doc" | sudo tee -a /etc/hosts

##### Get Git Repository
    git clone git@github.com:aliuosio/docker-lamp.git

##### start docker (!! on OSX !!)
    sudo chmod -R 777 app_root/
    cd .docker
    docker-sync start
    docker-compose -f docker-compose.mac.yml up -d

##### start docker
    sudo chmod -R 777 app_root/
    cd .docker
    docker-compose up -d
    
##### Login to PHP container
    docker exec -it app_php_<version> bash
    
##### Login to Web Server container
    docker exec -it app_webserver bash
    
##### Use Composer
    docker exec -it app_php_<version> composer <command>
    
##### Connect Sequel to MySQL
    Host: 0.0.0.0
    User: root
    Password: root
    
##### All outgoing mails are sent to MailHog
    https://app.doc:8025


### Todos ###
- set permssions for webserver on php container
- use sockets instead of TCP
- make Database Data persistent