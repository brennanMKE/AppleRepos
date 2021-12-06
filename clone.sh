#!/bin/sh

# Clones repos from lists (Apple.txt and OSS.txt)

APPLE_REPOS=$(cat Apple.txt)
OSS_REPOS=$(cat OSS.txt)

pushd .
mkdir -p Repos
cd Repos
pwd

for APPLE_REPO in ${APPLE_REPOS}; do 
    if [ ! -d "${APPLE_REPO}" ]; then
        git clone git@github.com:apple/$APPLE_REPO.git
    fi
done

for OSS_REPO in ${OSS_REPOS}; do 
    if [ ! -d "${OSS_REPO}" ]; then
        git clone git@github.com:opensource-apple/$OSS_REPO.git
    fi
done

popd

