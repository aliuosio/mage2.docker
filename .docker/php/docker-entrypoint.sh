#!/bin/bash -x

if [[ $1 = "true" ]]; then
    su -c "composer global require hirak/prestissimo" -s /bin/sh $2
    cd $3;
    su -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$4 ." -s /bin/sh $2
    su -c "mkdir -p var/composer_home" -s /bin/sh $2
    su -c "chown -R $2:$2 ../" -s /bin/sh $2
    su -c "cp ../.composer/auth.json $3/var/composer_home/auth.json" -s /bin/sh $2
    su -c "composer require mageplaza/module-smtp splendidinternet/mage2-locale-de-de;" -s /bin/sh $2

    su -c "composer require --dev msp/devtools --dev mage2tv/magento-cache-clean;" -s /bin/sh $2

    #su -c "composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git; \
    #   composer require firegento/magesetup2:dev-develop;" -s /bin/sh $2

    if [[ $5 = "true" ]]; then
        su -c "bin/magento sampledata:deploy;" -s /bin/sh $2
    fi

    su -c "find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;  ;
         find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \; " -s /bin/sh $2
fi