#!/bin/bash

SERVER=azure # Configured in ~/.ssh/config
APP_PATH="/home/azureuser/apps/bmcgrath-adonis-api"

function echo_box_fn () {
  content="| ${1} |"
  length=${#content}-2
  divider="+"

  for ((i = 0; i < length; i++)); do
    divider="${divider}-"
  done

  divider="${divider}+"

  echo "${divider}"
  echo "${content}"
  echo "${divider}"
}

function prepare_fn () {
  APP_PATH=$1

  #-------------------------------#
  # Create deployment directories #
  #-------------------------------#
  echo_box_fn "Making deploy dirs"
  echo

  mkdir -p "${APP_PATH}" -v
  mkdir -p "${APP_PATH}/releases" -v
  mkdir -p "${APP_PATH}/secrets" -v
  echo

  #------------------#
  # Clone repository #
  #------------------#
  echo_box_fn "Cloning repo"
  echo

  cd "${APP_PATH}" || exit
  rm -rf repo
  git clone git@github.com:brianmcg/bmcgrath-adonis-api.git repo
  echo

  #--------------------#
  # Copy pm2 conf file #
  #--------------------#
  echo_box_fn "Copying p2 conf file"
  echo
  
  cd repo || exit
  cp "${APP_PATH}/repo/config/deploy/p2.conf" "${APP_PATH}/ecosystem.config.js" -v
  echo
}

npx figlet "Preparing Deploy Dir"  | npx lolcatjs
echo

ssh "${SERVER}" "$(typeset -f); prepare_fn ${APP_PATH}"

#--------------------------#
# Copy .env file to server #
#--------------------------#
echo_box_fn "Copying env file"
echo

scp .env.production "${SERVER}:${APP_PATH}/secrets/.env.local"
echo

npx figlet "Finished" | npx lolcatjs
echo
