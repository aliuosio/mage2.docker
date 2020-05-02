#!/bin/bash

set -e

install() {
	docker exec -it -u $1 $2 bin/magento sampledata:deploy;
	docker exec -it -u $1 $2 bin/magento se:up;
	# docker exec -it -u $1 $2 bin/magento se:di:co;
	docker exec -it -u $1 $2 bin/magento i:rei;
	docker exec -it -u $1 $2 bin/magento c:c;
	# docker exec -it -u $1 $2 bin/magento setup:static-content:deploy -f de_DE en_US;
}

. ${PWD}/.env;

install ${USER} ${NAMESPACE}_php
