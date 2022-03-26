#!/bin/sh

# Refreshes list of repos from GitHub

JQ=$(which jq)
if [ -z "${JQ}" ]; then
  echo "Install JQ to continue: brew install jq" && exit 1
fi

if [ -z "${GITHUB_USERNAME}" ]; then
  echo "Define GITHUB_USERNAME to run" && exit 1
fi

if [ -z "${GITHUB_API_READ_ACCESS_TOKEN}" ]; then
  echo "Define GITHUB_API_READ_ACCESS_TOKEN to run" && exit 1
fi

ORG=apple
PER_PAGE=100

TEMP_FILE=$(mktemp -t Apple)
PAGE=1
DONE=false

echo "" >${TEMP_FILE}

fetch_page() {
  local PAGE=$1

  curl -u "${GITHUB_USERNAME}:${GITHUB_API_READ_ACCESS_TOKEN}" \
    "https://api.github.com/orgs/${ORG}/repos?per_page=${PER_PAGE}&page=${PAGE}" |
    ${JQ} -r ".[].name"
}

append_list() {
  local LIST=$1

  echo "${LIST}" |
    grep -v "ml-" | grep -v "ccs-" | grep -v "FHIR" |
    grep -v "HomeKit" |
    grep -v "jdk" | grep -v "turicreate" >>${TEMP_FILE}
}

append_lists() {
  local PAGE=1
  local MAX_PAGE=100
  local DONE=false

  until [ $PAGE -gt $MAX_PAGE -o $DONE = true ]; do
    echo "# Page ${PAGE}" >>${TEMP_FILE}
    local LIST=$(fetch_page $PAGE)
    local COUNT=$(echo "${LIST}" | wc -l | bc)
    if [ $PER_PAGE -gt $COUNT ]; then
      DONE=true
    else
      PAGE=$(expr $PAGE + 1)
    fi

    append_list "${LIST}"
  done

  cat ${TEMP_FILE} | grep -v "#" | grep -v -e '^$' | sort | uniq >Apple.txt
  rm ${TEMP_FILE}
}

append_lists
