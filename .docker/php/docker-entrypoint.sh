#!/bin/bash -x

if [[ $1 = "true" ]]
then
    cd $3;
    su -c "composer global require hirak/prestissimo" -s /bin/sh $2
    su -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$4 ." -s /bin/sh $2
    su -c "ln -s $3/../.composer/auth.json $3/var/composer_home/auth.json" -s /bin/sh $2
    su -c "composer require mageplaza/module-smtp" -s /bin/sh $2

    su -c "composer require predis/predis \
       --dev msp/devtools \
       --dev mage2tv/magento-cache-clean \
       splendidinternet/mage2-locale-de-de;" -s /bin/sh $2

    su -c "composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git; \
       composer require firegento/magesetup2:dev-develop;" -s /bin/sh $2

    su -c "bin/magento sampledata:deploy; \
        bin/magento setup:upgrade; \
        bin/magento indexer:reindex; \
        bin/magento cache:clean;" -s /bin/sh $2
fi