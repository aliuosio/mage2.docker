#!/bin/bash -x

if [[ $1 = "true" ]]; then

    # composer downloader anddon to increase download speeds
    su -c "composer global require hirak/prestissimo" -s /bin/sh $2

    # go to magento root folder
    cd $3;

    # download magento
    su -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$4 ." -s /bin/sh $2
    su -c "mkdir -p var/composer_home" -s /bin/sh $2
    su -c "chown -R $2:$2 ../" -s /bin/sh $2
    su -c "cp ../.composer/auth.json $3/var/composer_home/auth.json" -s /bin/sh $2

    # image-optimizer, SMTP Module
    su -c "composer require justbetter/magento2-image-optimizer;" -s /bin/sh $2

    # debug tools magento
    su -c "composer require --dev msp/devtools --dev mage2tv/magento-cache-clean;" -s /bin/sh $2

    # locales install
    case $7 in
        de_DE)
            su -c "composer require splendidinternet/mage2-locale-de-de;" -s /bin/sh $2
            ;;
        en_GB)
            su -c "composer require cubewebsites/magento2-language-en-gb;" -s /bin/sh $2
            ;;
        fr_FR)
            su -c "composer require mageplaza/magento-2-french-language-pack;" -s /bin/sh $2
            ;;
        it_IT)
            su -c "composer require mageplaza/magento-2-italian-language-pack:dev-master;" -s /bin/sh $2
            ;;
        es_ES)
            su -c "composer require mageplaza/magento-2-spanish-language-pack:dev-master;" -s /bin/sh $2
            ;;
        pt_PT)
            su -c "composer require mageplaza/magento-2-portuguese-language-pack:dev-master;" -s /bin/sh $2
            ;;
        pt_BR)
            su -c "composer require magento2translations/language_pt_br:dev-master;" -s /bin/sh $2
            ;;
    esac

    # generate static files for locale installed
    case $7 in
        de_DE|en_GB|fr_FR|it_IT|es_ES)
        su -c "bin/magento setup:static-content:deploy -f $7;" -s /bin/sh $2
        ;;
    esac

    # firegento magesetup install
    if [[ $6 = "true" ]]; then
        su -c "composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git; \
            composer require firegento/magesetup2:dev-develop;" -s /bin/sh $2
    fi

    # Magento Sample Data
    if [[ $5 = "true" ]]; then
        su -c "bin/magento sampledata:deploy;" -s /bin/sh $2
    fi

    # set owner and user permissions on magento folders
    su -c " find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
            find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
            chmod u+x bin/magento" -s /bin/sh $2

fi