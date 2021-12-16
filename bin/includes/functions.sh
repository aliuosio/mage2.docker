#!/bin/bash
set -e

setEnvironment() {
  if [[ $1 ]]; then
    file="$1/.env"
    if [[ ! -f $file ]]; then
      cp "$1/.env.temp" "$file"
    else
      echo ".env File exists already"
    fi
    # shellcheck disable=SC1090
    source "$file"
  fi
}

setEnvironment "$1"

phpContainerRoot="docker exec -it -u root ${NAMESPACE}_php bash -lc"
phpContainer="docker exec -it ${NAMESPACE}_php bash -lc"

getLogo() {
  echo "                             _____      _            _             "
  echo "                            / __  \    | |          | |            "
  echo " _ __ ___   __ _  __ _  ___ \`' / /'  __| | ___   ___| | _____ _ __ "
  echo "| '_ \` _ \ / _\` |/ _\` |/ _ \  / /   / _\` |/ _ \ / __| |/ / _ \ '__|"
  echo "| | | | | | (_| | (_| |  __/./ /___| (_| | (_) | (__|   <  __/ |   "
  echo "|_| |_| |_|\__,_|\__, |\___|\_____(_)__,_|\___/ \___|_|\_\___|_|   "
  echo "                  __/ |                                            "
  echo "                 |___/                                             "
}

workDirCreate() {
  if [[ ! -d "$1" ]]; then
    if ! mkdir -p "$1"; then
      message "Folder can not be created"
    else
      message "Folder created"
    fi
  else
    message "Folder already exits"
  fi
}

DBDumpImport() {
  if [[ -n $1 && -f $1 ]]; then
    runCommand "docker exec -i $2_db mysql -u $3 -p<see .env for password> $5 < $1;"
  else
    message "SQL File not found"
  fi
}

specialPrompt() {
  if [[ -n "$1" ]]; then
    read -rp "$1" RESPONSE
    if [[ ${RESPONSE} == '' || ${RESPONSE} == 'n' || ${RESPONSE} == 'N' ]]; then
      rePlaceInEnv "false" "SAMPLE_DATA"
      rePlaceInEnv "" "DB_DUMP"
    elif [[ ${RESPONSE} == 's' || ${RESPONSE} == 'S' ]]; then
      rePlaceInEnv "true" "SAMPLE_DATA"
      rePlaceInEnv "" "DB_DUMP"
    elif [[ ${RESPONSE} == 'd' || ${RESPONSE} == 'D' ]]; then
      rePlaceInEnv "false" "SAMPLE_DATA"
      prompt "rePlaceInEnv" "Set Absolute Path to Project DB Dump (current: ${DB_DUMP})" "DB_DUMP"
    fi
  fi
}

rePlaceInEnv() {
  file="$project_root/.env"
  if [[ -n "$1" ]]; then
    rePlaceIn "$1" "$2" "./.env"
    if [[ $2 == "COMPOSE_PROJECT_NAME" ]]; then
      rePlaceIn "$1" "NAMESPACE" "$file"
      rePlaceIn "$1" "MYSQL_DATABASE" "$file"
      rePlaceIn "$1" "MYSQL_USER" "$file"
    fi
  fi

  if [[ "$MYSQL_ROOT_PASSWORD" == "" ]]; then
    # shellcheck disable=SC2046
    rePlaceIn $(openssl rand -base64 12) "MYSQL_ROOT_PASSWORD" "./.env"
  fi

  if [[ "$MYSQL_PASSWORD" == "" ]]; then
    # shellcheck disable=SC2046
    rePlaceIn $(openssl rand -base64 12) "MYSQL_PASSWORD" "./.env"
  fi
}

rePlaceIn() {
  [[ "$1" == "yes" || "$1" == "y" ]] && value="true" || value=$1
  pattern=".*$2.*"
  replacement="$2=$value"
  envFile="$3"
  if [[ $(uname -s) == "Darwin" ]]; then
    sed -i "" "s@$pattern@$replacement@" "$envFile"
  else
    sed -i "s@$pattern@$replacement@" "$envFile"
  fi
}

prompt() {
  if [[ -n "$2" ]]; then
    read -rp "$2" RESPONSE
    [[ $RESPONSE == '' && $3 == 'WORKDIR' ]] && VALUE=$RESPONSE || VALUE=$RESPONSE
    # shellcheck disable=SC2091
    $($1 "${VALUE}" "$3")
  fi
}

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

osxExtraPackages() {
  if [[ ! -x "$(command -v brew)" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  if [[ ! -x "$(command -v unison)" ]]; then
    runCommand "brew install unison"
  fi
  if [[ ! -d /usr/local/opt/unox ]]; then
    runCommand "brew install eugenmayer/dockersync/unox"
  fi
  if [[ ! -x "$(command -v docker-sync)" ]]; then
    runCommand "gem install docker-sync;"
  fi
}

setHostSettings() {
  sudo sysctl vm.overcommit_memory=1
  sudo echo never /sys/kernel/mm/transparent_hugepage/enabled
  sudo sysctl vm.max_map_count=262144
  sudo systemctl daemon-reload
}

runCommand() (
  #tput setaf 1; echo "Method in bin/install.sh: $2"
  tput setaf 6
  message "$1"
  eval "$1"
)

gitUpdate() {
  if [ ! -d "$WORKDIR" ] && [ "$GIT_URL" ] && [ "$GIT_BRANCH" ]; then
    runCommand "git clone --branch $GIT_BRANCH $GIT_URL $WORKDIR"
  fi

  if [ -f "$WORKDIR/.git/config" ]; then
    if [[ $(uname -s) == "Darwin" ]]; then
      runCommand "sed -i "" 's@filemode = true@filemode = false@' $WORKDIR/.git/config"
    else
      runCommand "sed -i 's@filemode = true@filemode = false@' $WORKDIR/.git/config"
    fi
    runCommand "git -C $WORKDIR fetch -p -a && git pull"
  fi
}

composerOptimzerWithAPCu() {
  runCommand "docker exec -u $1 $2 composer dump-autoload -o --apcu"
}

makeExecutable() {
  runCommand "chmod +x bin/*.sh;"
}

setNginxVhost() {
  if [[ $(uname -s) == "Darwin" ]]; then
    runCommand "sed -i '' 's@mage2.localhost@$SHOPURI@' .docker/nginx/conf/default.conf"
    runCommand "sed -i '' 's@listen 80;@listen $WEBSERVER_UNSECURE_PORT;@' .docker/nginx/conf/default.conf"
  else
    runCommand "sed -i 's@mage2.localhost@$SHOPURI@' .docker/nginx/conf/default.conf"
    runCommand "sed -i 's@listen 80;@listen $WEBSERVER_UNSECURE_PORT;@' .docker/nginx/conf/default.conf"
  fi
}

# @todo: test on OSX
dockerRefresh() {
  if [[ $(uname -s) == "Darwin" ]]; then
    #runCommand "docker-compose -f docker-compose.osx.yml down"
    runCommand "docker-sync stop"
    runCommand "docker-sync start"
    runCommand "docker-compose -f docker-compose.osx.yml up -d"
  else
    runCommand setHostSettings
    #runCommand "docker-compose down"
    runCommand "docker-compose up -d"
  fi
}

setAuthConfig() {
  if [[ "$1" == "true" ]]; then
    prompt "rePlaceInEnv" "Login User Name (current: $2)" "AUTH_USER"
    prompt "rePlaceInEnv" "Login User Password (current: $3)" "AUTH_PASS"
  fi
}

createComposerFolder() {
  dir="${HOME}/.composer"

  if [ ! -d $dir ]; then
    runCommand "mkdir -p $dir"
    runCommand "chown -R $USER:$GROUP $dir"
  fi

}

showLog() {
  if [ -f ".docker/mysql/db_dumps/dev.sql.gz" ]; then
    container="${NAMESPACE}_db"
  else
    container="${NAMESPACE}_php"
  fi
  docker logs "$container" --follow
}

message() {
  echo ""
  echo -e "$1"
  seq ${#1} | awk '{printf "-"}'
  echo ""
}

runCommand() (
  message "$1"
  eval "$1"
)

setHostSettings() {
  sudo sysctl vm.overcommit_memory=1
  sudo echo never /sys/kernel/mm/transparent_hugepage/enabled
  sudo sysctl vm.max_map_count=262144
  sudo systemctl daemon-reload
}

removeAll() {
  if [ -d "$WORKDIR" ]; then
    commands="rm -rf $WORKDIR_SERVER/*;"
    runCommand "$phpContainerRoot '$commands'"
  fi
}

removeHTMLFolder() {
  DIR="$WORKDIR/html"
  if [ -n "$(find "$DIR" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    runCommand "rm -rf $DIR"
  fi
}

restoreAll() {
  git checkout "$WORKDIR/*"
}

magentoRefresh() {
  commands="bin/magento se:up && bin/magento ca:cl;"
  runCommand "$phpContainer '$commands'"
}

restoreGitIgnoreAfterComposerInstall() {
  runCommand "git -C $WORKDIR checkout .gitignore"
}

setPermissionsComposer() {
  commands="chown -R www:www /home/www/.composer"

  runCommand "$phpContainerRoot '$commands'"
}

setPermissionsContainer() {
  commands="find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} + \
            && find var generated vendor pub/static pub/media app/etc -type d -exec chmod u+w {} + \
            && chown -R www:www $WORKDIR_SERVER \
            && chmod u+x bin/magento"

  runCommand "$phpContainerRoot '$commands'"
}

setPermissionsHost() {
  commands="sudo chown -R $USER:$GROUP $WORKDIR"

  runCommand "$commands"
}

showSuccess() {
  if [ -n "$2" ]; then
    message "Backend:\

http://$1/admin\

User: <Backend Users from Your DB Dump>\

Password: <Backend Users Passwords from Your DB Dump>\


Frontend:\

http://$1"
  else
    message "Backend:\

http://$1/admin\

User: mage2_admin\

Password: mage2_admin123#T\


Frontend:\

http://$1"
  fi

}

sampleDataInstall() {
  if [[ "$SAMPLE_DATA" == "true" ]]; then
    commands="/usr/local/bin/sample-data.sh"
    runCommand "$phpContainer '$commands'"
  fi
}

MagentoTwoFactorAuthDisable() {
  commands="bin/magento module:disable -c Magento_TwoFactorAuth"
  runCommand "$phpContainer '$commands'"
}

findImport() {
  if [[ $(find $DB_DUMP_FOLDER -maxdepth 1 -type f -name "*.gz") ]]; then
    echo 'IS DA'
  fi
}

starter() {
  commands="/usr/local/bin/starter.sh"
  runCommand "$phpContainer '$commands'"
}

installer() {
  commands="/usr/local/bin/installer.sh"
  runCommand "$phpContainer '$commands'"
}
