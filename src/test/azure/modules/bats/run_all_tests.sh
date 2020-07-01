#!/usr/bin/env bash

function runModuleTests(){
 local here=$(pwd)
 local module=$1
 local test_folder=$2
 printf "\n# Running tests for module $module\n"
 cd ../$module && bats -o "$test_folder" -F junit *.bats
 cd "$here"
}

function runAll(){
  result_folder=$(pwd)/tmp
  mkdir -p "$result_folder"
  runModuleTests artifacts "$result_folder" && \
  runModuleTests chatops "$result_folder" && \
  runModuleTests reports "$result_folder" && \
  runModuleTests thresholds "$result_folder" && \
  runModuleTests templates "$result_folder"
}

runAll