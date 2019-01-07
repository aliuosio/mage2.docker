#!/bin/bash -x

if true = $1 || true = $4 ; then
    cd $3;
    su -c "composer global require hirak/prestissimo;" -s /bin/sh $2
    su -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ." -s /bin/sh $2

    if true = $4 ; then
        su -c "cp /home/$2/.composer/auth.json $3/var/composer_home/auth.json; \
                bin/magento sampledata:deploy;" -s /bin/sh $2
    fi

    su -c "composer require predis/predis \
            --dev msp/devtools \
            --dev mage2tv/magento-cache-clean \
            splendidinternet/mage2-locale-de-de;" -s /bin/sh $2

    su -c "composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git; \
           composer require firegento/magesetup2:dev-develop;" -s /bin/sh $2
fi