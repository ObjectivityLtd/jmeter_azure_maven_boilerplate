#!/usr/bin/env bash

function generateReport(){
  local trend_reports_module_dir=$1
  local artifacts_module_dir=$2
  local csv_folder=$3
  local target_dir=$4
  local trend_report_dir=$5
  cd "${trend_reports_module_dir}" && /bin/bash generateTrendReport.sh "${artifacts_module_dir}"/"${csv_folder}"/ "${target_dir}" "${trend_report_dir}"
}

function downloadPipelineArtifacts(){
    artifacts_module_dir=$1
    definition_id=$2
    artifacts_module_dir=$3
    results_dir=$4
    result_file=$5
    pat=$6
    cd "${artifacts_module_dir}" && /bin/bash downloadPipelineArtifacts.sh ${definition_id} ${artifacts_module_dir} ${results_dir} ${result_file} ${pat}
}

function run_main() {
  #given all the paths set
  local definition_id=$1
  local artifacts_module_dir=$2
  local results_dir=$3
  local result_file=$4
  local pat=$5
  local trend_reports_module_dir=$6
  local target_dir=$7
  local trend_report_dir=$8
  local csv_folder=$(grep csv_folder ../../azure.properties | awk -F= '{print $2}')

  #download artifacts based on azure.properties settings for last N builds, pass only build dependent params
  downloadPipelineArtifacts "${artifacts_module_dir}" "${definition_id}" "${artifacts_module_dir}" "${results_dir}" "${result_file}" "${pat}"
  #and generate report based on downloaded jmeter results file for each buils
  generateReport "${trend_reports_module_dir}" "${artifacts_module_dir}" "${csv_folder}" "${target_dir}" "${trend_report_dir}"
}

#if executed ./
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_main $1 $2 $3 $4 $5 $6 $7 $8
fi
