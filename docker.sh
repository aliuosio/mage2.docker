#!/bin/bash

set -e

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# docker
sudo apt-get remove -y docker docker-engine docker.io containerd runc;
sudo apt-get update -y;
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common;

if [[ "$(grep -Ei 'debian' /etc/*release)" ]]; then
    OS="debian";
    VERSION="buster";
elif [[ "$(grep -Ei 'ubuntu|mint' /etc/*release)" ]]; then
    OS="ubuntu";
    VERSION="bionic";
fi

sudo curl -fsSL https://download.docker.com/linux/${OS}/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$OS $VERSION stable"
sudo apt-get update -y;
sudo apt-get install -y docker-ce docker-ce-cli containerd.io;
groupadd docker;
usermod -aG docker ${USER};
newgrp docker;

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(get_latest_release docker/compose)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose