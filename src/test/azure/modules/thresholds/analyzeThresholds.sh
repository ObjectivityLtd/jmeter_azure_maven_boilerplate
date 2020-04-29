#!/usr/bin/env bash
#sets exit code to 1 if a threshold defined in threshold.properties was breached
#ether if evaluation is done against a fixed threshold or based on percentile

function extractSamplerResults() {
  results_file=$1
  samplerName=$2
  print=$3
  tmp=$(mktemp)
  #command='cat $results_file | grep -e \"^[0-9]*,[0-9]*,$samplerName,\" | awk -F, '{print $2}' | sort > \"$tmp\"'
  #echo $command
  cat $results_file | grep -e "^[0-9]*,[0-9]*,$samplerName," | awk -F, '{print $2}' | sort >"$tmp"
  if [ -n "$print" ]; then
    cat $tmp #print content for tests
  else
    echo $tmp #return tmp file name
  fi
}

function getPercentile() {
  percentile=$1
  results_file=$2
  total=$(cat "$results_file" | wc -l)
  #printf "\nTotal samples: $total"
  # (n + 99) / 100 with integers is effectively ceil(n/100) with floats
  count=$(((total * percentile + 99) / 100))
  head -n $count "$results_file" | tail -n 1
}

function getPercentileForSampler() {
  results_file=$1
  samplerName=$2
  percentile=$3
  tmp=$(extractSamplerResults $results_file "$samplerName")
  getPercentile "$percentile" "$tmp"
}

function run_main() {
  #given all the paths set
  thresholds_file=$1
  results_file=$2


  if [ ! -f "$thresholds_file" ]; then
    echo "Thresholds file $thresholds_file does not exist. Skipping checks."
    exit 0
  fi

  if [ ! -f "$results_file" ]; then
    echo "$results_file does not exist. Skipping checks."
    exit 0
  fi

  exit_code=0
  while read line || [[ -n $line ]]; do #do not omit last line
    samplerName=$(echo $line | awk -F= '{print $1}')
    threshold=$(echo $line | awk -F= '{print $2}')
    percentile=$(echo $line | awk -F= '{print $3}') # we can set percentile check like this: POST /api/userskills=200=50
    if [ -z "$percentile" ]; then #check based on numerical values, all results must meet threshold
      printf "CHECK:  Threshold for $samplerName is $threshold ms. Checking for samples higher than $threshold ms\n"

      while read result || [[ -n $result ]]; do # do not omit last line, do not lose exit code
        stamp=$(echo $result | awk -F, '{print $1}')
        elapsed=$(echo "$result" | awk -F, '{print $2}')
        if [ "$elapsed" -gt "$threshold" ]; then
          printf "\tERROR, THRESHOLD BREACHED: $elapsed ms > $threshold ms for $samplerName at $stamp\n"
          exit_code=1
        fi
      done < <(cat $results_file | grep -e "^[0-9]*,[0-9]*,$samplerName,") #use this so we do not spawn a subshell
    else #percentile based check
      printf "PERCENTILE CHECK:  $samplerName is expected to have $percentile % of results below $threshold. Checking if results meet that condition\n"
      actual_percentile=$(getPercentileForSampler "$results_file" "$samplerName" "$percentile" | tr -d '\n')
      if [ ! -z "$actual_percentile" ]; then
        printf "\n$threshold percentile for $samplerName is $actual_percentile"
        if [ "$actual_percentile" -gt "$threshold" ]; then
          printf "\tERROR, THRESHOLD BREACHED $percentile percentile is $actual_percentile ms > $threshold ms for $samplerName\n"
          exit_code=1
        fi
      else
        printf "Non exisiting sample: $samplerName. Cannot calculate percentile"
      fi
    fi
  done < <(cat $thresholds_file)

  if [ "$exit_code" -eq "0" ]; then
    printf "\t ALL RESULTS ARE OK"
  fi

  echo "Exit code:${exit_code}"
  exit $exit_code
}

#if executed ./
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_main "$1" "$2"
fi
