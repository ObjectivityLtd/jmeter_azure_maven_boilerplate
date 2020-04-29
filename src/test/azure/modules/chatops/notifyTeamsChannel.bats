#!/usr/bin/env bash

load $HOME/test/'test_helper/bats-assert/load.bash'
load $HOME/test/'test_helper/bats-support/load.bash'

function setup(){
  mkdir -p tmp
  #source main script
  source notifyTeamsChannel.sh
  #zero curl call so we do not send message to channel on test
  function notifyTeamsChannel(){   printf "\nNotifying teams channel"; }
  export -f notifyTeamsChannel
}
@test "Sourcing script should produce exit code 0" {
  run  run_main  templateCard.json test_data/azure.properties "@SUMMARY^Performance Tests","@ENV^TEST","@DATE^1.1.2020","@TRIGGERED^manual","@EXPLANATION^simple test","@BUILD^http://o.pl","@REPORTS^http://o.pl","@INSIGHTS^http://o.pl" test_data/azure.properties
  [ "$status" -eq 0 ]
}

@test "Output should contain 'Notifying teams channel' and 'azure.properties'" {
  run  run_main  templateCard.json test_data/azure.properties "@SUMMARY^Performance Tests","@ENV^TEST","@DATE^1.1.2020","@TRIGGERED^manual","@EXPLANATION^simple test","@BUILD^http://o.pl","@REPORTS^http://o.pl","@INSIGHTS^http://o.pl" test_data/azure.properties
  assert_output --partial 'Notifying teams channel'
  assert_output --partial 'azure.properties'
}

@test "chatopsEnabled property should be set to 0 or 1" {
  run parseProperties test_data/azure.properties
  assert_output --regexp '.*Enabled: (0|1).*'
}

@test "chatopsWebHook should be set if chatopsEnabled=1" {
   if [ ! -z "$hook" ]; then
       skip "Incoming Hook not set not set. Skipping"
   fi
  run parseProperties test_data/azure.properties
  assert_output --regexp '.*Hook: http(|s)://.*'
}

@test "Notification should be skipped if chatopsEnabled!=1" {
   if [ ! -z "$hook" ]; then
      skip "Incoming Hook not set not set. Skipping"
   fi
   run parseProperties test_data/azure.nagative.properties
   assert_output --partial 'ChatOps is disabled .. skipping'
   [ "$status" -eq 0 ]
}

@test "When I ran prepareCard all template values should be replaced in final card" {
    #GIVEN prepared value replace function
    function test(){
      rm tmp/* && \
      prepareCard templateCard.json "@SUMMARY^Performance Tests","@ENV^TEST","@DATE^1.1.2020","@TRIGGERED^manual","@EXPLANATION^simple test","@BUILD^http://o.pl","@REPORTS^http://o.pl","@INSIGHTS^http://o.pl">/dev/null && \
      cat tmp/templateCard.json
    }
    #WHEN I processs template card adn replace placeholders with values
    run test
    #THEN All values should be replaced
    refute_output --partial '@SUMMARY'
    refute_output --partial '@ENV'
    refute_output --partial '@TRIGGERED'
    refute_output --partial '@EXPLANATION'
    refute_output --partial '@BUILD'
    refute_output --partial '@REPORTS'
}

