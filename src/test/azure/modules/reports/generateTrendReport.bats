#!/usr/bin/env bash

load $HOME/test/'test_helper/batsassert/load.bash'
load $HOME/test/'test_helper/batscore/load.bash'

function setup(){
  source generateTrendReport.sh
  working_dir=$(pwd)/working_dir #we want to give it as relative name because of ease of testing
  pom_root=$(pwd)/../../../../..
  target_path=${pom_root}/target
  report_dir=report
  result_file="merged.csv"
  rm -Rf $working_dir/*
  mkdir -p $working_dir
  cp test_data/*.csv $working_dir/
}

#integration test - we need network access, maven and all
@test "IT:Merged file should have correct number of lines and report should be created" {
  #GIVEN test data is set in setup()
  #AND EXPECTED number of lines in merged file is known
  TEST_FILES_NR=$(ls test_data/*.csv | wc -l)
  TEST_FILES_NR_WO_HEADER="$(($TEST_FILES_NR-1))"
  TOTAL_LINES_NR=$(cat test_data/*.csv | wc -l)
  EXPECTED_LINES_NR="$(($TOTAL_LINES_NR-$TEST_FILES_NR_WO_HEADER))"
  #WHEN I merge test data into 1 file
  run run_main "$working_dir" "$target_path" "$report_dir"
  #THEN
  #result file is non empty
  [ -s "$working_dir/$result_file" ]
  ##AND it has proper number of lines
  ACTUAL_LINES_NR=$(cat $working_dir/$result_file | wc -l)
  assert_equal $ACTUAL_LINES_NR $EXPECTED_LINES_NR
  #AND report folder exists and has index file inside
  report_folder=report
  test -d $working_dir/$report_folder
  test -f $working_dir/$report_folder/index.html
}

#unit test - maven not necessary
@test "Script should correctly detect JMeter binary from target" {
  #GIVEN dependencies are resolved
  #mvn compile -q -f "$pom_root"
  target_path=$(pwd)/test_data
  #WHEN setJMeterExecutable is run
  run setJMeterExecutable
  #THEN Apache JMeter binary should be detected
  assert_output --regexp ".*JMeter path:.*ApacheJMeter.*"
  assert_success
}

#integration test - maven and network required
@test "IT: Script should correctly detect JMeter binary from target" {
  #GIVEN dependencies are resolved
  mvn compile -q -f "$pom_root"
  #WHEN setJMeterExecutable is run
  run setJMeterExecutable
  #THEN Apache JMeter binary should be detected
  assert_output --regexp ".*JMeter path:.*ApacheJMeter.*"
  assert_success
}