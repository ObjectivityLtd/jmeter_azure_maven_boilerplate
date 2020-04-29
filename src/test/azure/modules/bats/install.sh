#!/usr/bin/env bash

#we can install that on the fly for CI systems or we can add this in docker image
function installBATSConditionally(){
  #To install run source test.sh && installBATSConditionally in any shell
  bats -version > /dev/null 2>&1
  if [ "$?" -eq "0" ];then
    version="$(bats -version)"
    printf "\nBATS already installed with version %s\n" "$version"
  else
    git clone https://github.com/ztombol/bats-core $HOME/test/test_helper/bats-core
    git clone https://github.com/ztombol/bats-assert $HOME/test/test_helper/bats-support
    source $HOME/test/test_helper/bats-core/install.sh ~
  fi
}
installBATSConditionally