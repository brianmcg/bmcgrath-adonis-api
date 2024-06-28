#!/bin/bash

SERVER=azure
APP_PATH="/home/azureuser/apps/bmcgrath-adonis-api"

function echo_box() {
  content="| ${1} |"
  length=${#content}-2
  divider="+"

  for ((i = 0; i < length; i++)); do
    divider="${divider}-"
  done

  divider="${divider}+"

  echo ${divider}
  echo ${content}
  echo ${divider}
}

function deploy () {
  APP_PATH=$1
  NGINX_AVAILABLE_PATH="/home/azureuser/nginx/sites-available"
  NGINX_ENABLED_PATH="/home/azureuser/nginx/sites-enabled"
  NGINX_CONFIG_FILE="bmcgrath-adonis-api.conf"
  TIMESTAMP=`date +%s`
  KEEP_RELEASES=5
  BRANCH_NAME="main"

  source ~/.nvm/nvm.sh
  
  #-------------------#
  # Fetch latest code #
  #-------------------#
  echo_box "Fetching latest code"
  echo

  if test -d "${APP_PATH}/repo"; then
    cd "${APP_PATH}/repo"
    git stash && git stash clear
    git checkout main
    git pull
    git checkout "${BRANCH_NAME}"
    git pull origin "${BRANCH_NAME}"
  else
    cd "${APP_PATH}"
    git clone git@github.com:brianmcg/bmcgrath-adonis-api.git repo
    cd "${APP_PATH}/repo"
    git checkout "${BRANCH_NAME}"
    git pull origin "${BRANCH_NAME}"
  fi

  echo

  #-----------#
  # Run build #
  #-----------#
  echo_box "Running build"
  echo
  npm install
  echo
  npm run build
  echo

  #-------------------------#
  # Run Database Migrations #
  #-------------------------#
  echo_box "Updating Database"
  echo
  # sudo -u postgres psql -c "CREATE DATABASE bmcgrath_production WITH OWNER = bmcgrath;"
  ENV_PATH=/home/azureuser/apps/bmcgrath-adonis-api/secrets node ace migration:run --force
  ENV_PATH=/home/azureuser/apps/bmcgrath-adonis-api/secrets node ace db:seed
  echo

  #----------#
  # Clean up #
  #----------#
  echo_box "Cleaning up"
  echo

  mkdir -p "${APP_PATH}/releases"
  mv "${APP_PATH}/repo/build" "${APP_PATH}/releases/${TIMESTAMP}"
  cd "${APP_PATH}/releases/${TIMESTAMP}"
  npm ci --omit="dev"

  rm -f "${APP_PATH}/current"
  ln -s "${APP_PATH}/releases/${TIMESTAMP}" "${APP_PATH}/current"

  echo

  INDEX=0

  for DIR in `ls -t ${APP_PATH}/releases`; do
    if [ $INDEX -ge $KEEP_RELEASES ]; then
      rm -rf "${APP_PATH}/releases/${DIR}"
    fi
    INDEX=$((INDEX + 1))
  done

  #---------------#
  # Restart pm2   #
  #---------------#
  echo_box "Restarting app"
  echo
  cd ${APP_PATH}
  pm2 startOrReload ecosystem.config.js --env production
  echo
}

figlet "Deploying App"
echo

# ssh "${SERVER}" "mkdir -p ${APP_PATH}/secrets/ -v" && scp -r ".env.production" "${SERVER}:${APP_PATH}/secrets/.env"

ssh "${SERVER}" "$(typeset -f); deploy ${APP_PATH}"

figlet "Finished"
echo
