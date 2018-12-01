composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .

find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;

chmod u+x bin/magento;
bin/magento setup:install \
    --db-host=database \
    --db-name=magento2 \
    --db-user=app \
    --db-password=app \
    --backend-frontname=admin \
    --base-url=http://app.doc/ \
    --language=de_DE \
    --timezone=Europe/Berlin \
    --currency=EUR \
    --admin-lastname=Admin \
    --admin-firstname=Admin \
    --admin-email=admin@example.com \
    --admin-user=admin \
    --admin-password=admin123 \
    --cleanup-database \
    --use-rewrites=1 \
    --use-sample-data

bin/magento sampledata:deploy;
bin/magento setup:upgrade;
bin/magento indexer:reindex;
bin/magento cache:clean;
