#!/bin/bash

SERVER=azure # Configured in ~/.ssh/config
APP_PATH="/home/azureuser/apps/bmcgrath-adonis-api"

function echo_box() {
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

function prepare () {
  APP_PATH=$1

  mkdir -p "${APP_PATH}" -v
  mkdir -p "${APP_PATH}/releases" -v
  mkdir -p "${APP_PATH}/secrets" -v
  echo

  cd "${APP_PATH}" || exit
  rm -rf repo
  git clone git@github.com:brianmcg/bmcgrath-adonis-api.git repo

  cd repo || exit
  # npm install
  echo
  echo_box "Copying p2 conf file"
  cp "${APP_PATH}/repo/config/deploy/p2.conf" "${APP_PATH}/ecosystem.config.js" -v
  echo
}

figlet "Preparing Deploy Dir"
echo

#-------------------------------#
# Create deployment directories #
#-------------------------------#
echo_box "Making deploy dirs"
echo

ssh "${SERVER}" "$(typeset -f); prepare ${APP_PATH}"

#--------------------------#
# Copy .env file to server #
#--------------------------#
echo_box "Copying env file"
echo

scp .env.production "${SERVER}:${APP_PATH}/secrets/.env"
echo

figlet "Finished"
echo
