#!/usr/bin/env bash

load $HOME/test/'test_helper/bats-assert/load.bash'

function setup(){
 pip install --upgrade pip
 pip install pyyaml
}

@test "IT:YAML template should have correct format" {
   python3 -c 'import yaml, sys; print(yaml.safe_load(sys.stdin))' < azure.maven.test.template.yml
   assert_success
}