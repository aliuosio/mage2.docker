#!/bin/bash

set -e

sampledata_install() {
	docker exec -u $1 $2 bin/magento sampledata:deploy;
	docker exec -u $1 $2 bin/magento se:up;
	# docker exec -u $1 $2 bin/magento se:di:co;
	docker exec -u $1 $2 bin/magento i:rei;
	docker exec -u $1 $2 bin/magento c:c;
	# docker exec -u $1 $2 bin/magento setup:static-content:deploy -f de_DE en_US;
}

. ${PWD}/.env;

sampledata_install ${USER} ${NAMESPACE}_php
