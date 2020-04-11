if  [ ! -x "$(command -v unison)" ]; then
    echo "brew install unison";
    #brew install unison;
fi
if  [ ! -x "$(command -v unox)" ]; then
    echo "brew install eugenmayer/dockersync/unox";
    #brew install eugenmayer/dockersync/unox;
fi
if  [ ! -x "$(command -v docker-sync)" ]; then
    echo "gem install docker-sync;";
    #sudo gem install docker-sync;
fi
