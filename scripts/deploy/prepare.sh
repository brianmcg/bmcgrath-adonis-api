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

  echo ${divider}
  echo ${content}
  echo ${divider}
}

function prepare () {
	APP_PATH=$1

	mkdir -p "${APP_PATH}"
	mkdir -p "${APP_PATH}/releases"
	mkdir -p "${APP_PATH}/secrets"
	
	cd ${APP_PATH}

	rm -rf repo
  git clone git@github.com:brianmcg/bmcgrath-adonis-api.git repo
}

figlet "Prepare deployment"
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

scp -r ".env.production" "${SERVER}:${APP_PATH}/secrets/.env" -v

figlet "Finished"
echo
