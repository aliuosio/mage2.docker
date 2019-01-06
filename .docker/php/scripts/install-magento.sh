#!/bin/bash -x

if true = $1 ; then
    cd $3;
    composer global require hirak/prestissimo;
fi