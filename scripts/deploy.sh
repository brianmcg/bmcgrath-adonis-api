#!/bin/bash

APP_NAME=$(basename "$(git rev-parse --show-toplevel)")
SERVER=azure # Configured in ~/.ssh/config
APP_PATH="apps/${APP_NAME}"
DEPLOYER=$(whoami)

function echo_box_fn() {
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

function deploy_fn() {
  DEPLOYER=$1
  APP_PATH="${HOME}/$2"
  TIMESTAMP=$(date +%s)
  KEEP_RELEASES=3
  BRANCH_NAME="main"

  source "${HOME}/.nvm/nvm.sh"
  
  #-------------------#
  # Fetch latest code #
  #-------------------#
  echo_box_fn "Fetching latest code"
  echo

  if test -d "${APP_PATH}/repo"; then
    cd "${APP_PATH}/repo" || exit
    git stash && git stash clear
    git checkout main
    git pull
    git checkout "${BRANCH_NAME}"
    git pull origin "${BRANCH_NAME}"
  else
    cd "${APP_PATH}" || exit
    git clone git@github.com:brianmcg/bmcgrath-adonis-api.git repo
    cd "${APP_PATH}/repo" || exit
    git checkout "${BRANCH_NAME}"
    git pull origin "${BRANCH_NAME}"
  fi

  echo

  #-----------#
  # Run build #
  #-----------#
  echo_box_fn "Running build"
  
  npm install
  echo
  npm run build
  echo

  #-------------------------------------#
  # Run database migrations and seeders #
  #-------------------------------------#
  echo_box_fn "Updating Database"
  echo
  # sudo -u postgres psql -c "CREATE DATABASE bmcgrath_production WITH OWNER = bmcgrath;"
  ENV_PATH="${APP_PATH}/secrets" node ace migration:run --force
  ENV_PATH="${APP_PATH}/secrets" node ace db:seed
  echo

  #----------#
  # Clean up #
  #----------#
  echo_box_fn "Cleaning up"
  echo

  # Move build directory to releases/$TIMESTAMP
  mkdir -p "${APP_PATH}/releases"
  mv "${APP_PATH}/repo/dist" "${APP_PATH}/releases/${TIMESTAMP}"

  # Install production dependencies
  cd "${APP_PATH}/releases/${TIMESTAMP}" || exit
  npm ci --omit="dev"

  # Make symlink from latest build to `current` directory
  rm -f "${APP_PATH}/current"
  ln -s "${APP_PATH}/releases/${TIMESTAMP}" "${APP_PATH}/current"

  # Update revisions.log
  cd "${APP_PATH}/repo" || exit
  COMMIT=$(git log --format="%H" -n 1)
  echo
  echo "Branch ${BRANCH_NAME} (at ${COMMIT}) deployed as release ${TIMESTAMP} by ${DEPLOYER}"
  echo "Branch ${BRANCH_NAME} (at ${COMMIT}) deployed as release ${TIMESTAMP} by ${DEPLOYER}" >> "${APP_PATH}/revisions.log"
  echo

  # Keep the last n releases, remove older ones
  INDEX=$(find "${APP_PATH}/releases" -mindepth 1 -maxdepth 1 | wc -l)
 
  for DIR in "${APP_PATH}"/releases/*; do
    if [ "${INDEX}" -gt "${KEEP_RELEASES}" ]; then
      rm -rf "${DIR}"
    fi
    INDEX=$((INDEX-1))
  done

  #---------------#
  # Restart pm2   #
  #---------------#
  echo_box_fn "Restarting app"
  echo
  cd "${APP_PATH}" || exit
  pm2 startOrReload ecosystem.config.js --env production
  echo
}

npx figlet "Deploying App" | npx lolcatjs
echo

ssh "${SERVER}" "$(typeset -f); deploy_fn ${DEPLOYER} ${APP_PATH}"

npx figlet "Finished" | npx lolcatjs
echo
