#!/usr/bin/env bash

#Downloads given number of pipelien artifacts (jmeter results from previous build) from azure
#copies current results to target folder for merge operation

function run_main() {
  local definition_id=$1
  local artifacts_module_dir=$2
  local results_dir=$3
  local result_file=$4
  local pat=$5
  local csv_folder=csv
  if [ -z "$6" ]; then
    echo "Using default csv folder"
  else
    echo "Using $6 csv folder"
    csv_folder=$6
  fi

  cd ${artifacts_module_dir}
  python3 -m pip install --upgrade pip
  pip3 install -r requirements.txt
  python3 downloadPipelineArtifacts.py -d ${definition_id} -s ${pat}
  printf "Copying current results too\n"
  cp ${results_dir}/${result_file} $csv_folder/0current.csv
  printf "Files to merge:\n"
  ls $csv_folder
}

#if executed ./*.sh
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_main $1 $2 $3 $4 $5 $6
fi
