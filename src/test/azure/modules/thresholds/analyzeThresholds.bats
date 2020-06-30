#!/usr/bin/env bats

load $HOME/test/'test_helper/batsassert/load.bash'

function setup(){
  source analyzeThresholds.sh
}

@test "Percentile for sampler name is correctly calculated" {
   function test(){
      local test_file=$1
      local sampler_name=$2
      local percentile=$3
      local EXPECTED_VALUE=$4
      run getPercentileForSampler "$test_file" "$sampler_name" "$percentile"
      assert_success
      assert_output "$EXPECTED_VALUE"
    }

  test_file=test_data/results.csv
  sampler_name="POST /api/userskills"
  test $test_file "$sampler_name" 66 352
  test $test_file "$sampler_name" 67 381
  test $test_file "$sampler_name" 1 192
  test $test_file "$sampler_name" 100 381
}

@test "Sampler results are correctly stored in temp file" {
  #GIVEN results file
  results_file=test_data/results.csv
  #AND Sampler Name
  sampler_name="POST /api/userskills"
  #WHEN I extract results for this sampler from results file to tmp file
  run extractSamplerResults $results_file "$sampler_name" 1
  #AND I display file contents
  #run cat $tmp
  #THEN All sampler times are extracted OK and they are sorted
  assert_output "192
352
381"

}

@test "Percentiles should be correctly calculated" {
    function test(){
      local percentile=$1
      local EXPECTED_VALUE=$2
      local test_file=$3
      run getPercentile $percentile $test_file
      assert_success
      assert_output $EXPECTED_VALUE
    }
    #GIVEN a test file with values 1 2 3
    test_file=test_data/sampler_results.csv
    #WHEN I count percentiles they should be properly calculated
    test 66 2 $test_file
    test 67 3 $test_file
    test 1 1 $test_file
    test 100 3 $test_file

}

@test "Results below thresholds should not raise an alarm" {
    #GIVEN results are below thresholds
    #WHEN I analyze thresholds breach based on those files
    run run_main test_data/thresholds.high.properties test_data/results.csv
    #THEN exit code should be 0
    [ "$status" -eq 0 ]
    #AND positive message shall be displayed
    assert_output --partial "ALL RESULTS ARE OK"
    #AND exit_code should be printed to terminal
    assert_output --partial "Exit code:0"
}

@test "Results above numerical thresholds should raise an alarm" {
    #GIVEN results are above thresholds
    #WHEN I analyze thresholds breach based on those files
    run run_main test_data/thresholds.low.properties test_data/results.csv
    #THEN exit code should be 1
    assert_failure
    #AND negative message shall be displayed
    assert_output --partial "ERROR, THRESHOLD BREACHED"
    #AND exit_code should be printed to terminal
    assert_output --partial "Exit code:1"
    #AND positive message should not be displayed
    refute_output --partial "ALL RESULTS ARE OK"
}

@test "Results above percentile-based thresholds should raise an alarm" {
    #GIVEN results are above thresholds for a percentile
    #WHEN I analyze thresholds breach based on those files and percentiles
    run run_main test_data/thresholds.low.percentile.properties test_data/results.csv
    #THEN exit code should be 1
    assert_failure
    #AND negative message shall be displayed
    assert_output --partial "ERROR, THRESHOLD BREACHED"
    #AND exit_code should be printed to terminal
    assert_output --partial "Exit code:1"
    #AND positive message should not be displayed
    refute_output --partial "ALL RESULTS ARE OK"
}

@test "Results below percentile-based thresholds should not raise an alarm" {
    #GIVEN results are above thresholds for a percentile
    #WHEN I analyze thresholds breach based on those files and percentiles
    run run_main test_data/thresholds.high.percentile.properties test_data/results.csv
    #THEN exit code should be 1
    assert_success
    #AND negative message shall be displayed
    refute_output --partial "ERROR, THRESHOLD BREACHED"
}

@test "All thresholds should be evaluated" {
    #GIVEN a number of thresholds that are higher than results
    thresholds_nr=$(cat test_data/thresholds.high.properties | wc -l)
    #WHEN I analyze thresholds breach based on these files
    run run_main test_data/results.csv test_data/thresholds.high.properties
    #THEN all thresholds should be checked
    checked_thresholds=$(printf $output | grep "CHECK" | wc -l)
    assert_equal "$checked_thresholds" "$thresholds_nr"
}

@test "If no files are provided script should exit with right message" {
    #GIVEN no files are provided for analysis
    #WHEN I analyze thresholds breach based on non-exisiting files
    run run_main
    #THEN exit code should be 0
    [ "$status" -eq 0 ]
    #AND missing message should be displayed
    assert_output --partial "does not exist. Skipping checks"
    #AND script should not display any test later on
    refute_output --partial "ERROR, THRESHOLD BREACHED"
    refute_output --regexp ".*Exit code:(0|1)"
    refute_output --partial "ALL RESULTS ARE OK"
}
