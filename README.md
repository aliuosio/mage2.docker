### Howtos

#### The Docker Setup
##### Add Host Adress to your /etc/hosts
    echo -e "0.0.0.0 app.doc" | sudo tee -a /etc/hosts

##### Get Git Repository
    git clone git@github.com:aliuosio/docker-lamp.git

##### start docker first time (!! on OSX !!)
    sudo chmod -R 777 app_root/
    cd .docker
    docker-sync start
    docker-compose -f docker-compose.mac.yml up -d

##### start docker first time (!! on NONE OSX !!)
    sudo chmod -R 777 app_root/
    cd .docker
    docker-compose up -d
    
#### after first run (on the everyday bases)
    cd .docker
    docker-compose start
    
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
    http://app.doc:8025
     
#### Some Composer projects

##### Magento 2.0 Install [instructions](#magento-2.0-install)
    
##### Shopware 5.4 [further instructions](https://developers.shopware.com/developers-guide/shopware-composer/)
    docker exec -it app_php_<version> composer create-project shopware/composer-project . --no-interaction --stability=dev
    
##### Wordpress [further instructions](https://github.com/johnpbloch/wordpress)
    docker exec -it app_php_<version> composer require johnpbloch/wordpress
    
    
    
## Magento 2.0 Install

**Login to bash of php container**

     docker exec -it app_php_7.1 bash
     composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition magento_2

##### Auth Keys when asked for
      get themy from magento 2 website.
      You need optain a login

#### Make ```bin/magento``` executable    
     chmod +x bin/magento
    
     bin/magento setup:install \
        --base-url="http://app.doc/"  \
        --db-host="database"  \
        --db-name="app.doc"  \
        --db-user="app.doc"  \
        --db-password="app.doc"  \
        --admin-firstname="admin"  \
        --admin-lastname="admin"  \
        --admin-email="user@example.com"  \
        --admin-user="admin"  \
        --admin-password="password123"  \
        --language="de_DE"  \
        --currency="EUR" \
        --timezone="Europe/Berlin"  \
        --use-rewrites="1"  \
        --backend-frontname="admin";
    
##### Content: app_root/app/etc/env.php
    
    <?php
    return [
        'backend' => [
            'frontName' => 'admin'
        ],
        'crypt' => [
            'key' => 'ed7ccf5966c123fc6e9cd2d74b5d3620'
        ],
        'db' => [
            'table_prefix' => '',
            'connection' => [
                'default' => [
                    'host' => 'database',
                    'dbname' => 'app.doc',
                    'username' => 'app.doc',
                    'password' => 'app.doc',
                    'model' => 'mysql4',
                    'engine' => 'innodb',
                    'initStatements' => 'SET NAMES utf8;',
                    'active' => '1'
                ]
            ]
        ],
        'resource' => [
            'default_setup' => [
                'connection' => 'default'
            ]
        ],
        'x-frame-options' => 'SAMEORIGIN',
        'MAGE_MODE' => 'default',
        'cache' => [
            'frontend' => [
                'default' => [
                    'backend' => 'Cm_Cache_Backend_Redis',
                    'backend_options' => [
                        'server' => 'redis_cache',
                        'database' => '0',
                        'port' => '6379'
                    ]
                ],
                'page_cache' => [
                    'backend' => 'Cm_Cache_Backend_Redis',
                    'backend_options' => [
                        'server' => 'redis_cache',
                        'port' => '6379',
                        'database' => '1',
                        'compress_data' => '0'
                    ]
                ]
            ]
        ],
        'session' => [
            'save' => 'redis',
            'redis' => [
                'host' => 'redis_session',
                'port' => '6379',
                'password' => '',
                'timeout' => '2.5',
                'persistent_identifier' => '',
                'database' => '2',
                'compression_threshold' => '2048',
                'compression_library' => 'gzip',
                'log_level' => '1',
                'max_concurrency' => '6',
                'break_after_frontend' => '5',
                'break_after_adminhtml' => '30',
                'first_lifetime' => '600',
                'bot_first_lifetime' => '60',
                'bot_lifetime' => '7200',
                'disable_locking' => '0',
                'min_lifetime' => '60',
                'max_lifetime' => '2592000'
            ]
        ],
        'cache_types' => [
            'config' => 1,
            'layout' => 1,
            'block_html' => 1,
            'collections' => 1,
            'reflection' => 1,
            'db_ddl' => 1,
            'eav' => 1,
            'customer_notification' => 1,
            'config_integration' => 1,
            'config_integration_api' => 1,
            'full_page' => 1,
            'translate' => 1,
            'config_webservice' => 1
        ],
        'install' => [
            'date' => 'Sat, 08 Sep 2018 20:19:51 +0000'
        ]
    ];

##### sampledata deploy
     bin/magento sampledata:deploy

##### upgrade modules
     bin/magento  setup:upgrade

##### reindex data
     bin/magento  index:reindex

##### Flush Cache
     bin/magento  cache:flush
     
##### Set Folder / File Permissions
    find . -type f -exec chmod 644 {} \;                        // 644 permission for files
    find . -type d -exec chmod 755 {} \;                        // 755 permission for directory 
    find ./var -type d -exec chmod 777 {} \;                // 777 permission for var folder    
    find ./pub/media -type d -exec chmod 777 {} \;
    find ./pub/static -type d -exec chmod 777 {} \;
    chmod 777 ./app/etc
    chmod 644 ./app/etc/*.xml
    chown -R :<web server group> .
    chmod u+x bin/magento


