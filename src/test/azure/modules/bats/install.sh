#!/usr/bin/env bash

#we can install that on the fly for CI systems or we can add this in docker image
function installBATS(){
  clear && rm -rf $HOME/test/test_helper/batscore  && rm -rf $HOME/test/test_helper/batsassert
  git clone https://github.com/bats-core/bats-core.git $HOME/test/test_helper/batscore
  git clone https://github.com/ztombol/bats-assert $HOME/test/test_helper/batsassert
  ls $HOME/test/test_helper/batscore
  cd $HOME/test/test_helper/batscore
  ./install.sh $HOME
}
installBATS