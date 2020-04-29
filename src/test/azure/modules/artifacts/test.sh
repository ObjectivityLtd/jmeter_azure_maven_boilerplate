#!/usr/bin/env bash
#you can use git bash to run this
#To test edit variables in ~/.bash_profile then run this script
#edit ~/.bash_profile
#export pat=..
#export pipeline_id=..
#you need python 3.5 or 3.7

#run this for help
#python downloadPipelineArtifacts.py -h

#run this to verify, requires all variables set in bash_profile

#GIVEN I supply valid test data
source ~/.bash_profile

#WHEN I download artifacts with config read from props file and pat from bash_profile
python downloadPipelineArtifacts.py -s $(echo $pat)


status_code=$?
zipped_files=$(ls $(echo $tmp_folder)/*.zip | wc -l)
csv_files=$(ls $(echo $csv_folder)/*.csv | wc -l)

echo "Zipped files" $zipped_files
echo "Zipped files" $csv_files
echo "Status code: " $status_code

##THEN script has correct exit code
if [ "$status_code" != "0" ]; then
    echo "ERROR - script exited with status code", $status_code
else
    echo "PASS - script exited with status code", $status_code
fi
##AND there is at least 1 extracted csv file
if [ "$csv_files" -lt "1" ]; then
    echo "ERROR - no csv files found", $csv_files
else
    echo "PASS - csv files found", $csv_files

fi