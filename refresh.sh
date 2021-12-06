#!/bin/sh

# Refreshes list of repos from GitHub

JQ=$(which jq)

if [ -z "${JQ}" ]; then
    echo "Install JQ to continue: brew install jq"
    return
fi

curl "https://api.github.com/orgs/apple/repos?per_page=100" | ${JQ} -r ".[].name" | \
    grep -v "ml-" | grep -v "ccs-" | grep -v "FHIR" | grep -v "HomeKit" | \
    grep -v "jdk" | grep -v "turicreate" \
    | sort | uniq > Apple.txt
