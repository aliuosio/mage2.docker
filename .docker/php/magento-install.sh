#!/bin/sh

set -e

 if [[ $1 = "true" ]]; then
    echo 'Install Magento BEGIN';
	su -c "bin/magento setup:install \
	    --db-host=mysql \
	    --db-name=$8 \
	    --db-user=$9 \
	    --db-password=$10 \
	    --backend-frontname=admin \
	    --base-url=https://mage2.doc/ \
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
	    --use-sample-data" -s /bin/sh $2
    echo 'Install Magento END';
fi