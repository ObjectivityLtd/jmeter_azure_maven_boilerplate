#!/usr/bin/env bash

load $HOME/test/'test_helper/batsassert/load.bash'
load $HOME/test/'test_helper/batscore/load.bash'

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
    refute_output --partial '@INSIGHTS'
}

@test "When base.user.properties has no new line at EOF insights_url is correctly extracted " {
    #test case added due to https://github.com/ObjectivityLtd/jmeter_azure_maven_boilerplate/issues/2
    local dir=test_data
    local SECOND_INSIGHTS_URL=https://portal.azure.com/insights2/overview

    function removeEOL(){
        printf %s "$(cat $dir/base.user.properties)" > $dir/test.base.user.properties
    }
    function test(){
      insights_url=$(cat $dir/test.base.user.properties  $dir/user.properties | grep insights_url | tail -n1 | awk -F= '{print $2}')
      echo "$insights_url"
    }
    #GIVEN firt user.properties file has no new line at EOF
    removeEOL
    #WHEN I extract insights_url
    run test
    #THEN correct one is extractwd
    assert_output $SECOND_INSIGHTS_URL
}