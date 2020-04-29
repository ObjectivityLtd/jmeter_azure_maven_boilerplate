#!/usr/bin/env bash
#Author: Gabriel Starczewski
#Merges a number of JMeter result files into 1 and creates report for trending

working_dir=$1
target_path=$2
report_dir=$3
report_params=$4

#initializes variables if not set from pipeline
function init() {
  printf "Report Generator Script Params:\n"
  if [ -z "$working_dir" ]; then
    working_dir=$(pwd)
  fi
  #working_dir=$(readlink -e "$working_dir") ||:
  printf "\t -- Working dir: %s\n" "$working_dir"

  if [ -z "$report_params" ]; then
    printf "\t -- No extra params for reporting set"
  fi
  printf "\t -- Report params: $report_params\n"

  if [ -z "$target_path" ]; then
    target_path="../../JMeter/maven/target"
  fi
  #target_path=$(readlink -e "$target_path") ||:
  printf "\t -- Target path: %s\n" "$target_path"

  if [ -z "$file_pattern_to_merge" ]; then
    file_pattern_to_merge="*.csv"
  fi
  if [ -z "$file_merge_result" ]; then
    file_merge_result="merged.csv"
  fi
  if [ -z "$report_dir" ]; then
    report_dir=report
  fi

}

#prepares workspace
function prepareWorkspace() {
  rm -Rf $working_dir/$report_dir && mkdir -p $working_dir/$report_dir
}

#finds jmeter executable
function setJMeterExecutable() {
  jmeter_path=$(find $target_path -regextype sed -regex ".*ApacheJMeter-[0-9\.]\{6\}jar" | head -n1) || :
  if [ -z "$jmeter_path" ]; then
    printf "ERROR - JMeter binary not found in $target_path"
    exit 1
  fi
  printf "\t -- JMeter path: $jmeter_path\n"
}
#merges a number of result files into 1
function mergeResultFiles() {
  cd $working_dir
  csvs=$(ls $file_pattern_to_merge | xargs)

  if [ -z "$csvs" ]; then
    echo "ERROR - no files to merge. Exiting"
    exit 1
  fi

  IFS=' ' read -r -a csv_array <<<"$csvs"
  local result_pattern="xcbv.result"
  i=1
  for file in "${csv_array[@]}"; do
    cp $file $result_pattern.$file
    if [ "$i" != "1" ]; then
      sed -i 1d $result_pattern.$file #remove headers for all but first file
    fi
    let "i=i+1"
  done
  cat $result_pattern*.csv >$file_merge_result
}
#generated report
function generateReport() {
  java -jar $jmeter_path -q $working_dir/../../../trend.report.properties -g $working_dir/$file_merge_result -o $working_dir/$report_dir $report_params
}
function displayResult() {
  printf "\nFirst rows of merged file are: \n"
  tail -n 3 ${file_merge_result}
}

function run_main() {
  init
  prepareWorkspace
  setJMeterExecutable
  mergeResultFiles
  generateReport
  displayResult
}

#if executed ./
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_main
fi
