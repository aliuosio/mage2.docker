#!/bin/bash -x

if true = $1 ; then
    cd $3;
    su -c "composer global require hirak/prestissimo" -s /bin/sh $2
    su -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.2.7 ." -s /bin/sh $2

    #su -c "bin/magento sampledata:deploy;" -s /bin/sh $2

    # su -c "composer require smile/elasticsuite:2.6" -s /bin/sh $2

    su -c "composer require predis/predis \
                --dev msp/devtools \
                --dev mage2tv/magento-cache-clean \
                splendidinternet/mage2-locale-de-de;" -s /bin/sh $2

    su -c "composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git; \
           composer require firegento/magesetup2:dev-develop;" -s /bin/sh $2

    su -c "bin/magento setup:install \
            --db-host=mysql \
            --db-name=app \
            --db-user=app \
            --db-password=app \
            --backend-frontname=admin \
            --base-url=https://app.doc/ \
            --base-url-secure=https://app.doc/ \
            --language=de_DE \
            --timezone=Europe/Berlin \
            --currency=EUR \
            --admin-lastname=Admin \
            --admin-firstname=Admin \
            --admin-email=admin@example.com \
            --admin-user=admin \
            --admin-password=admin123 \
            --use-rewrites=1 \
            --use-secure=1 \
            --use-secure-admin=1 \
            --cleanup-database \
            --use-sample-data" -s /bin/sh $2

    su -c "bin/magento setup:upgrade; \
           bin/magento indexer:reindex; \
           bin/magento cache:clean;" -s /bin/sh $2
fi