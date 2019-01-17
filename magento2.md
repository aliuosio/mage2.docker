* if you install sampledata be sure to run ```composer update``` before running bin/magento setup:upgrade to install downloaded composer sampeldata packages

```
composer global require hirak/prestissimo

composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.3.0 .

find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;

find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;

chmod u+x bin/magento;

bin/magento sampledata:deploy

bin/magento setup:install \
    --db-host=mysql \
    --db-name=mage2 \
    --db-user=mage2 \
    --db-password=mage2 \
    --backend-frontname=admin \
    --base-url=https://mage2.doc/ \
    --base-url-secure=https://mage2.doc/ \
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
    --use-sample-data

bin/magento setup:upgrade;

bin/magento indexer:reindex;

bin/magento cache:clean;

composer require predis/predis
composer require --dev msp/devtools
composer require --dev mage2tv/magento-cache-clean
composer require splendidinternet/mage2-locale-de-de

composer config repositories.firegento_magesetup vcs git@github.com:firegento/firegento-magesetup2.git
composer require firegento/magesetup2:dev-develop

```
