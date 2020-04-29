#!/usr/bin/env bash

load $HOME/test/'test_helper/bats-assert/load.bash'
load $HOME/test/'test_helper/bats-support/load.bash'

function setup(){
   source generateReport.sh
   definition_id=1
   artifacts_module_dir=$(pwd)/test_data
   rm -rf $(pwd)/test_data/csv/*
   cp $(pwd)/test_data/*.csv $(pwd)/test_data/csv/
   results_dir=test_data
   result_file=test_data/results.csv
   pat=any
   trend_reports_module_dir=$(pwd)/../reports
   target_dir=$(pwd)/../.././../../../target
   trend_report_dir=report
   pom_root=$(pwd)/../../../../..

}
function teardown(){
  rm -rf $(pwd)/test_data/csv/*
}
#integration test - we need network access, download is mocked
@test "IT:Report should be created" {
  #GIVEN I use test data and mock real download and mock mvn verify for Jmeter binary
  mvn compile -q -f "$pom_root"
  function downloadPipelineArtifacts(){ echo""; } #mock
  export -f downloadPipelineArtifacts
  #WHEN I ran script
  run run_main "$definition_id" "$artifacts_module_dir" "$results_dir" "$result_file" "$pat" "$trend_reports_module_dir" "$target_dir" "$trend_report_dir"
  #It is a success
  assert_success

}
