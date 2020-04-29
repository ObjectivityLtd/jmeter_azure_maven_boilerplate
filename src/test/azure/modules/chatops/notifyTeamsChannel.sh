#!/usr/bin/env bash

#sends a notification to Azure channel based on a given template and replace values

enabled=false
template_card=tmp/foo.json

function parseProperties() {
  local propertiesFile=$1
  printf "\nParsing properties: %s" $propertiesFile
  enabled=$(cat $propertiesFile | grep chatopsEnabled | awk -F= '{print $2}')
  printf "\n\tEnabled: $enabled"
  if [ "$enabled" != "1" ];then
    printf "\nChatOps is disabled .. skipping"
    exit 0
  fi
  hook=$(cat $propertiesFile | grep chatopsWebHook | awk -F= '{print $2}')
  printf "\n\tHook: $hook"
}

function prepareCard() {
  mkdir -p tmp
  rm tmp/*
  local template=$1
  cp $template tmp/$template
  shift 1
  printf "\n\nREPLACING template:"
  IFS=',' read -r -a array <<<"$@"
  for var in "${array[@]}"; do
    IFS='^'                 # space is set as delimiter
    read -ra READ <<<"$var" # str is read into an array as tokens separated by IFS
    k=${READ[0]}
    v=${READ[1]}
    printf "\n\t ${k} -> $v"
    sed -i "s+$k+$v+g" tmp/$template
  done

}

function notifyTeamsChannel() {
  local template_card=$1
  printf "\nNotifying teams channel"
  cat $template_card
  http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json"  --data-binary @$template_card  $hook)
  echo "Http code: $http_code"
  if [ "$http_code" != "200" ]; then
    printf "\nNotification was not sent"
    exit 1
  else
    printf "\nNotification was sent. "
  fi
}

function run_main() {
  template_card=$1
  propertiesFile=$2
  parseProperties $(dirname "${BASH_SOURCE[0]}")/$2
  shift 2
  local replaceArray=$@
  prepareCard $template_card $replaceArray
  notifyTeamsChannel tmp/$template_card
}

#if executed ./notifyTeamsChannel.sh
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_main $1 $2 $3
fi
