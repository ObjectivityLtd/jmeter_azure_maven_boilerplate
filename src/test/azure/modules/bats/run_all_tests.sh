#!/usr/bin/env bash

function runModuleTests(){
 local here=$(pwd)
 local module=$1
 printf "\n# Running tests for module $module\n"
 cd ../$module && bats *.bats
 cd "$here"
}

function runAll(){
  runModuleTests artifacts
  runModuleTests chatops
  runModuleTests reports
  runModuleTests thresholds
  runModuleTests templates
}

runAll