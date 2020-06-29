#!/usr/bin/env bash

load $HOME/test/'test_helper/batsassert/load.bash'
load $HOME/test/'test_helper/batscore/load.bash'

function setup(){
 pip install pyyaml
}

@test "IT:YAML template should have correct format" {
   python -c 'import yaml, sys; print(yaml.safe_load(sys.stdin))' < azure.maven.test.template.yml
   assert_success
}