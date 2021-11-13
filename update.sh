#!/bin/sh

update_git_repo()
{
  REPO_DIR=$1
  MAIN_BRANCH=$2
  if [ -d "${REPO_DIR}/.git" ]; then
    BASE_NAME=`basename ${REPO_DIR}`
    pushd .
    cd ${REPO_DIR}
    BRANCH=$(git branch | awk '/\*/ { print $2; }')
    if [ "${BRANCH}" = "${MAIN_BRANCH}" ]; then 
      printf "\e[36mPulling latest updates for ${BASE_NAME}\e[m\x1b[0m\n"
      git pull
    fi
    popd
  fi
}

update_git_repos()
{
  for REPO_DIR in `find . -type d -maxdepth 1`; do
    update_git_repo ${REPO_DIR} ${MAIN_BRANCH}
  done
}

MAIN_BRANCH=$1

if [ -z "${MAIN_BRANCH}" ]; then
  MAIN_BRANCH="main"
fi

pushd .
cd Repos
update_git_repos
popd
