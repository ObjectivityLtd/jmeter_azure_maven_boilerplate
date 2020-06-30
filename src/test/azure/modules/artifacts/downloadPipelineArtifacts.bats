#!/usr/bin/env bash

load $HOME/test/'test_helper/batsassert/load.bash'

function setup(){
  mkdir -p test_data/csv && rm -rf test_data/csv/*
  source downloadPipelineArtifacts.sh
}

function teardown(){
  rm -rf test_data/csv/*
}

@test "Downloaded past result files and current should end in the same folder" {
  #GIVEN we mock real dowload
  function pip3(){
    echo "Mocking requirements install";
  }
  export -f pip3
  function python3(){
    cp test_data/*.csv test_data/csv
  }
  export -f python3
  #WHEN we run the script
  run run_main 1 . test_data/results results.csv FOO_PAT test_data/csv
  #All files should end up in the same folder
  assert_output --partial raw1.csv
  assert_output --partial raw2.csv
  assert_output --partial raw3.csv
  assert_output --partial 0current.csv
  #Clean
  unset python3
  unset pip3
}

@test "Python tests should pass" {
  function python_tests(){
    python -m pytest *Test.py
  }
  run python_tests
  assert_success
}

